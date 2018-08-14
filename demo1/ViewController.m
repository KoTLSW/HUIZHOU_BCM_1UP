//
//  ViewController.m
//  demo1
//
//  Created by mac on 2017/8/22.
//  Copyright © 2017年 maceastwin. All rights reserved.


//  LAN:TCPIP0::169.254.85.155::5025::SOCKET
//  GPIB:GPIB0::17::INSTR
// FixtureID:TE170927T1-010C004     TE170927T1-011D006
// 33522B 33509B
#import "ViewController.h"
#import "PDCA.h"
#import "Plist.h"
#import "Table.h"
#import "Item.h"
#import "Param.h"
#import "IsNumber.h"
#import "ORSSerialPort.h"
#import "AgilentTools.h"
#import "AgilentE4980A.h"
#import "MKTimer.h"
#import "GetTimeDay.h"
#import "HiperTimer.h"
#import "MK_FileCSV.h"
#import "MK_FileFolder.h"
#import "MK_FileTXT.h"
#import "ORSSerialPort.h"
#import "AgilentB2987A.h"
//#import "Agilent33210A.h"
#import "Agilent34461A.h"
#import "Agilent3458A.h"
#import "Agilent33500B.h"
#import "TypeConverter.h"
#import "TestStep.h"
#import "Alert.h"

@interface ViewController ()<ORSSerialPortDelegate>

@end

NSString  *param_path=@"Param";
NSString  *config_path=@"Config";



@implementation ViewController
{
    // DCR 连续读取拼接
    NSMutableString *dcrAppending;
    
    
    //弹出提示框
    Alert   *  alert;
    
    NSString *op_ID;
    
    BOOL B2987_USB;
    BOOL B2987_USB1;
    BOOL B2987_USB2;
    BOOL nulltest;
    NSInteger test_type;
    
    NSString *temp_Str;
    NSString *humid_Str;
    
    NSString *config_pro;
    NSString *config_product;
    NSInteger nullTestCount;
    double sum_fix_Cap;
    double sum_fix_B2_E2_Res;
    double sum_fix_B4_E4_Res;
    double sum_fix_B_E_Res;
    double sum_fix_ABC_DEF_Res;
    
    double ave_fix_Cap;
    double ave_fix_B2_E2_Res;
    double ave_fix_B4_E4_Res;
    double ave_fix_B_E_Res;
    double ave_fix_ABC_DEF_Res;
    
    double max_fix_Cap;
    double max_fix_B2_E2_Res;
    double max_fix_B4_E4_Res;
    double max_fix_B_E_Res;
    double max_fix_ABC_DEF_Res;
    
    double min_fix_Cap;
    double min_fix_B2_E2_Res;
    double min_fix_B4_E4_Res;
    double min_fix_B_E_Res;
    double min_fix_ABC_DEF_Res;
    
    double fix_temp;
    
    NSInteger once;
    NSInteger loopTest_count;
    NSString* Rref_dc;
    NSString* Rref_ac;
    NSString *B2_E2_Ref_Max;
    NSString *B2_E2_Ref_Min;
    NSString *B2_E2_Ref_Ave;
    NSString *B4_E4_Ref_Max;
    NSString *B4_E4_Ref_Min;
    NSString *B4_E4_Ref_Ave;
    NSString *B_E_Ref_Max;
    NSString *B_E_Ref_Min;
    NSString *B_E_Ref_Ave;
    NSString *ABC_DEF_Ref_Max;
    NSString *ABC_DEF_Ref_Min;
    NSString *ABC_DEF_Ref_Ave;
    
    NSString *Cfix_Max;
    NSString *Cfix_Min;
    NSString *Cfix_Ave;
    NSString *B2_E2_Ref;
    NSString *B4_E4_Ref;
    NSString *B_E_Ref;
    NSString *ABC_DEF_Ref;
    
    NSMutableDictionary *dic_FixtureRefence;
    NSString *_Rfix;
    NSString *_Cfix;
    NSMutableDictionary *store_Dic;
    NSInteger   test_DC;
    BOOL didReceiveData;
    NSString *nest_ID;
    //************ Device *************
    TypeConverter          * typeConver;
    ORSSerialPort          * fixtureSerial;   //治具串口
    ORSSerialPort          * humitureSerial;  //温湿度串口
    AgilentTools           * aglientTools;    //安捷伦万用表
    AgilentE4980A          * agilentE4980A;   //LCR表
    AgilentB2987A          *agilentB2987A;    //静电计
    Agilent33500B          *agilent33500B;
    Agilent34461A          *agilent34461A;
    BYDSFCManager          *sfcManager;       //处理sfc的类
    unsigned long   tempNum;       //温度
    unsigned long   humitNum;      //湿度
    NSMutableData  * appendData;
    
    //************* timer *************
    NSString *start_time;               //启动测试的时间
    NSString *end_time;                 //结束测试的时间
    NSString *cost_time;                //程序测试花费的时间
    NSThread * myThrad;                  // 自定义主线程
    NSThread * secondThrad;              //温湿度线程
    NSThread *mythread;
    NSTextField *timerLab;
    dispatch_queue_t   mk_queue;
    dispatch_source_t  mk_timer;
    float ct_cnt;
    BOOL         all_Pass;          //testPDCA
    
    
    __weak IBOutlet NSTextField *OP_ID_TF;
    __weak IBOutlet NSButton *OP_ID;
    __weak IBOutlet NSPopUpButton *product_Type;
    __weak IBOutlet NSPopUpButton *test_DOE;
    __weak IBOutlet NSTextField *humit_TextF;
    __weak IBOutlet NSButton *config_Change;
    __weak IBOutlet NSPopUpButton *Fix_Reference;
    __weak IBOutlet NSButton *nullTestDone;
    __weak IBOutlet NSTextField *loopTest_Label;
    __weak IBOutlet NSTextField *looptestCount_TF;
    __weak IBOutlet NSTextField *looptestLabel;
    __weak IBOutlet NSPopUpButton *B4_E4_ref;
    __weak IBOutlet NSPopUpButton *B2_E2_ref;
    __weak IBOutlet NSPopUpButton *Cfix_ref;
    __weak IBOutlet NSPopUpButton *nestIDChoose;
    __weak IBOutlet NSButton *NestID_Change;
    __weak IBOutlet NSTextField *NestID_TF;
    __weak IBOutlet NSButton *hiddenUnlimitTest;
    __weak IBOutlet NSButton *stopBtn;
    __weak IBOutlet NSTextField *bigTitleTF;
    __weak IBOutlet NSTextField *versionTF;
    __unsafe_unretained IBOutlet NSTextView *logView_Info;
    __unsafe_unretained IBOutlet NSTextView *FailItemView;
    __weak IBOutlet NSTextField *importSN;
    
    __weak IBOutlet NSTextField *currentStateMsg;
    __weak IBOutlet NSTextField *testResult;
    __weak IBOutlet NSTextField *testFieldTimes;
    __weak IBOutlet NSTextField *testCount;
    __weak IBOutlet NSButton *PDCA_Btn;
    __weak IBOutlet NSButton *SFC_Btn;
    __weak IBOutlet NSTextField *passNumInfoTF;
    __weak IBOutlet NSTextField *passNumCalculateTF;
    __weak IBOutlet NSTextField *failNumInfoTF;
    __weak IBOutlet NSTextField *failNumCalculateTF;
    __weak IBOutlet NSTextField *totalNumInfo;
    __weak IBOutlet NSTextField *fixtureID_TF;
    __weak IBOutlet NSTextField *stationID_TF;
    __weak IBOutlet NSButton *startBtn;
    __unsafe_unretained IBOutlet NSTextView *SN_Collector;
    __weak IBOutlet NSTextField *product_Config;
    __weak IBOutlet NSPopUpButton *SNLengNumPop;
    
    
    
    int testNum;                        //测试次数
    int passNum;                        //通过次数
    
    BOOL          isUpLoadSFC;      //是否上传SFC
    BOOL          isUpLoadPDCA;     //是否上传PDCA
    MKTimer *mkTimer;               //MK 定时器对象
    
    
    NSMutableArray *failItemsArr;
    NSMutableArray *passItemsArr;
    
    Table *mk_table;                       // table类
    Plist *plist;                          // plist类
    Param *param;                          // param参数类
    NSMutableArray *itemArr;            // plist文件测试项数组
    Item *testItem ;
    NSString *itemResult; //每一个测试项的结果
    int index;                          // 测试流程下标
    int item_index;                     // 测试项下标
    int row_index;                      // table 每一行下标
    
    
    //************ testItems ************
    double num;
    NSMutableArray  *txtLogMutableArr;
    NSString        *agilentReadString;
    NSDictionary    *dic;
    NSString        *SonTestDevice;
    NSString        *SonTestCommand;
    NSString        *SonTestName;
    int             delayTime;
    NSString    *testResultStr;     //测试结果
    NSMutableArray  *testResultArr; // 返回的结果数组
    NSMutableArray  *testItemTitleArr;     //每个测试标题都加入数组中,生成数据文件要用到
    NSMutableArray  *testItemValueArr;     //每个测试结果都加入数组中,生成数据文件要用到
    NSMutableArray  *testItemMinLimitArr;  //每个测试项最小值数组
    NSMutableArray  *testItesmMaxLimitArr; //每个测试项最大值数组
    NSMutableArray  *testItemUnitArr;
    
    
    //具中返回来的
    NSString *backStr;//从治具中返回来的值
    NSMutableString * appendStr;//从治具中返回来的字符
    NSString     *humitString;      //返回来的温度数据
    NSMutableString * humitAppendString;//温湿度传感器返回来的数据
    float  Zin_RES;                           //交流电压中的电阻值
    
    
    
    /*=======================2017.08.08新增加要要求
     第一: 新增加Fixture ID
     第二: 新增加交流阻抗的校准值,即ZIN_SB_CALIBRATE
     第三: 新增加Fixture ID 和ZIN_SB_CALIBRATE上传到PDCA
     */
    Plist  * fixConfig;                            // 治具的FixTure_ID和CP
    NSString  * fixtureID;                         //从治具中返回的fixtureID
    NSDictionary * fixtureDic;                     //Config.Plist文件中的字典
    NSDictionary * sonFixtureDic;                  //获取fixtureID 和CP的字典
    //float fixture_CP;                            //Config.Plist文件中的容值
    float fixture_Zout;                            //Config.Plist文件中的容值
    
    double fixture_refDC_res;
    double fixture_refAC_res;
    
    //增加无限循环限制设定
    BOOL  unLimitTest;                               //无限循环设定
    
    //新增仪器是否掉了判断
    BOOL  isInstrument;                              //仪表是否断开连接了
    

    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //测试界面初始化
    [self viewInit];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Activate_SFC_Notification:) name:@"Activate_SFC_Notification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Activate_PDCA_and_SFC_Notification:) name:@"Activate_PDCA_and_SFC_Notification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(Show_PDCA_and_SFC_Notification:) name:@"Show_PDCA_and_SFC_Notification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SetUnLimit_Notification:) name:@"TestUnLimit_Notification" object:nil];
    
   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(SetNULLTEST_Notification:) name:@"NULLTEST" object:nil];
   
    
    
    
    //开辟测试项线程
    myThrad = [[NSThread alloc] initWithTarget:self selector:@selector(Working) object:nil];
    [myThrad start];
    
    
}


- (IBAction)test_DOE:(id)sender {
    
    
    if (index > 4 && index != 1000)
    {
        return;
    }
    if ([test_DOE.title containsString:@"TEST"])
    {
        test_type=1;
    }
    
    if ([test_DOE.title containsString:@"DOE1"])
    {
        test_type=2;
        
    }
    
    if ([test_DOE.title containsString:@"DOE2"])
    {
        test_type=3;
        
    }
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (param.scheme_1)
        {
            
            
            itemArr = [plist PlistRead:[NSString stringWithFormat:@"Station_Cr_%ld_Humid",test_type] Key:@"AllItems"];
            if (test_type==1)
            {
                param.sw_ver=[NSString stringWithFormat:@"%@A",param.sw_ver_T2];
            }
            else if (test_type==2)
            {
                param.sw_ver=[NSString stringWithFormat:@"%@B",param.sw_ver_T2];
                
            }
            else if (test_type==3)
            {
                param.sw_ver=[NSString stringWithFormat:@"%@C",param.sw_ver_T2];
                
            }
            else
            {
                param.sw_ver=param.sw_ver_T2;
            }
            
            if (nulltest)
            {
                param.sw_ver=param.sw_ver_T2;
            }
        }
        
        versionTF.stringValue =[NSString stringWithFormat:@"Version: %@",param.sw_ver];
        mk_table = [mk_table init:_tab_View DisplayData:itemArr];
        
    });
    
    
}



//空测完成，将空测的平均值和最大最小值写进Param.plist文件
- (IBAction)nullTestDone:(NSButton *)sender
{
    if (nullTestCount < 3)
    {
        nulltest=NO;
        nullTestDone.hidden=YES;
        exit(0);
        return;
    }
    ave_fix_Cap=sum_fix_Cap/nullTestCount;
    ave_fix_B_E_Res=sum_fix_B_E_Res/nullTestCount;
    ave_fix_B2_E2_Res=sum_fix_B2_E2_Res/nullTestCount;
    ave_fix_B4_E4_Res=sum_fix_B4_E4_Res/nullTestCount;
    ave_fix_ABC_DEF_Res=sum_fix_ABC_DEF_Res/nullTestCount;
    
    [param ParamWrite:@"Param" Content:[NSString stringWithFormat:@"%.3f,%.3f,%.3f",ave_fix_Cap,max_fix_Cap,min_fix_Cap] Key:@"fix_Cap"];
    
    //B-E-DCR
    if ((min_fix_B_E_Res < 0 && ave_fix_B_E_Res < 2000)||(min_fix_B_E_Res < 0 && (max_fix_B_E_Res > 5000 || max_fix_B_E_Res < 0)) || max_fix_B_E_Res < 0 )
    {
        [param ParamWrite:@"Param" Content:[NSString stringWithFormat:@"5000.000,%.3f,%.3f",max_fix_B_E_Res,min_fix_B_E_Res] Key:@"fix_B_E_Res"];
    }else
    {
        [param ParamWrite:@"Param" Content:[NSString stringWithFormat:@"%.3f,%.3f,%.3f",ave_fix_B_E_Res,max_fix_B_E_Res,min_fix_B_E_Res] Key:@"fix_B_E_Res"];
    }
    
    //B2-E2-DCR
    if ((min_fix_B2_E2_Res < 0 && ave_fix_B2_E2_Res < 2000) || (min_fix_B2_E2_Res < 0 && (max_fix_B2_E2_Res > 5000 || max_fix_B2_E2_Res < 0)) || max_fix_B2_E2_Res < 0 )
    {
        [param ParamWrite:@"Param" Content:[NSString stringWithFormat:@"5000.000,%.3f,%.3f",max_fix_B2_E2_Res,min_fix_B2_E2_Res] Key:@"fix_B2_E2_Res"];
    }else
    {
        [param ParamWrite:@"Param" Content:[NSString stringWithFormat:@"%.3f,%.3f,%.3f",ave_fix_B2_E2_Res,max_fix_B2_E2_Res,min_fix_B2_E2_Res] Key:@"fix_B2_E2_Res"];
    }
    
    //B4-E4-DCR
    if ((min_fix_B4_E4_Res < 0 && ave_fix_B4_E4_Res < 2000) || (min_fix_B4_E4_Res < 0 && (max_fix_B4_E4_Res > 5000 || max_fix_B4_E4_Res < 0)) || max_fix_B4_E4_Res < 0 )
    {
        [param ParamWrite:@"Param" Content:[NSString stringWithFormat:@"5000.000,%.3f,%.3f",max_fix_B4_E4_Res,min_fix_B4_E4_Res] Key:@"fix_B4_E4_Res"];
    }else
    {
        [param ParamWrite:@"Param" Content:[NSString stringWithFormat:@"%.3f,%.3f,%.3f",ave_fix_B4_E4_Res,max_fix_B4_E4_Res,min_fix_B4_E4_Res] Key:@"fix_B4_E4_Res"];
    }
    
    //ABC-DEF-DCR
    if ((min_fix_ABC_DEF_Res < 0 && ave_fix_ABC_DEF_Res < 2000) || (min_fix_ABC_DEF_Res < 0 && (max_fix_ABC_DEF_Res > 5000 || max_fix_ABC_DEF_Res < 0)) || max_fix_ABC_DEF_Res < 0 )
    {
        [param ParamWrite:@"Param" Content:[NSString stringWithFormat:@"5000.000,%.3f,%.3f",max_fix_ABC_DEF_Res,min_fix_ABC_DEF_Res] Key:@"fix_ABC_DEF_Res"];
    }else
    {
        [param ParamWrite:@"Param" Content:[NSString stringWithFormat:@"%.3f,%.3f,%.3f",ave_fix_ABC_DEF_Res,max_fix_ABC_DEF_Res,min_fix_ABC_DEF_Res] Key:@"fix_ABC_DEF_Res"];
    }
    
    nulltest=NO;
    nullTestDone.hidden=YES;
    sleep(2);
    exit(0);
}

- (IBAction)product_Type:(NSPopUpButton *)sender
{
    if (index > 4 && index != 1000)
    {
        return;
    }

    [self reloadPlist_Humid];
   
}
- (IBAction)OP_ID:(NSButton *)sender
{
    if (!sender.state)
    {
        OP_ID_TF.editable=NO;
    }
    else
    {
        OP_ID_TF.editable=YES;
    }
    
}

- (IBAction)Product_Config:(NSButton *)sender
{
    
    if (!sender.state)
    {
        product_Config.editable=NO;
    }
    else
    {
        product_Config.editable=YES;
    }
}

- (IBAction)Cfix_ref:(NSPopUpButton *)sender
{
    NSDictionary *tem=[[NSDictionary alloc]init];
    tem=dic_FixtureRefence[@"Fixture_cap"];
    if ([sender.title containsString:@"Ave"]) {
        _Cfix=tem[@"Ave"];
    }
    
    if ([sender.title containsString:@"Min"]) {
        _Cfix=tem[@"Min"];
    }
    
    if ([sender.title containsString:@"Max"]) {
        _Cfix=tem[@"Max"];
    }
    NSLog(@"_Cfix:%@",_Cfix);
}
- (IBAction)B2_E2_ref:(NSPopUpButton *)sender
{
    NSDictionary *tem=[[NSDictionary alloc]init];
    tem=dic_FixtureRefence[@"B2_E2_Res"];
    if ([sender.title containsString:@"Ave"]) {
        B2_E2_Ref=tem[@"Ave"];
    }
    
    if ([sender.title containsString:@"Min"]) {
        B2_E2_Ref=tem[@"Min"];
    }
    
    if ([sender.title containsString:@"Max"]) {
        B2_E2_Ref=tem[@"Max"];
    }
}
- (IBAction)B4_E4_ref:(NSPopUpButton *)sender
{
    NSDictionary *tem=[[NSDictionary alloc]init];
    tem=dic_FixtureRefence[@"B4_E4_Res"];
    if ([sender.title containsString:@"Ave"]) {
        B4_E4_Ref=tem[@"Ave"];
    }
    
    if ([sender.title containsString:@"Min"]) {
        B4_E4_Ref=tem[@"Min"];
    }
    
    if ([sender.title containsString:@"Max"]) {
        B4_E4_Ref=tem[@"Max"];
    }
}

- (IBAction)Fix_Reference:(NSPopUpButton *)sender
{
    if ([sender.title containsString:@"Ave"])
    {
        _Cfix=Cfix_Ave;
        B2_E2_Ref=B2_E2_Ref_Ave;
        B4_E4_Ref=B4_E4_Ref_Ave;
        B_E_Ref=B_E_Ref_Ave;
        ABC_DEF_Ref=ABC_DEF_Ref_Ave;
    }
    if ([sender.title containsString:@"Max"])
    {
        _Cfix=Cfix_Max;
        B2_E2_Ref=B2_E2_Ref_Max;
        B4_E4_Ref=B4_E4_Ref_Max;
        B_E_Ref=B_E_Ref_Max;
        ABC_DEF_Ref=ABC_DEF_Ref_Max;
        
    }
    if ([sender.title containsString:@"Min"])
    {
        _Cfix=Cfix_Min;
        B2_E2_Ref=B2_E2_Ref_Min;
        B4_E4_Ref=B4_E4_Ref_Min;
        B_E_Ref=B_E_Ref_Min;
        ABC_DEF_Ref=ABC_DEF_Ref_Min;
        
    }
}

- (IBAction)nestIDChoose:(NSPopUpButton *)sender
{
    NSLog(@"nest_ID:%@",sender.title);
    nest_ID=sender.title;
    
    if ([nest_ID containsString:@"BC"]) {
        
        [mk_table ClearTable];
        itemArr = [plist PlistRead:@"Station_Cr_1_Humid" Key:@"BCAllItems"];
        mk_table = [mk_table init:_tab_View DisplayData:itemArr];
    }
    else
    {
        //读取 plist 文件
        [mk_table ClearTable];
        [self reloadPlist_Humid];
        [[NSUserDefaults standardUserDefaults] setObject:@"AllItems" forKey:@"currentPlistKey"];
    }
    
    
}

- (IBAction)stopBtn:(NSButton *)sender
{
    if ([stopBtn.title isEqualToString:@"Disable"]) {
        sender.title=@"Enable";
        unLimitTest=NO;
    }else
    {
        sender.title=@"Disable";
        unLimitTest=YES;
    }
    
}
- (IBAction)hiddenUnlimitTest:(NSButton *)sender
{
    stopBtn.hidden=YES;
    hiddenUnlimitTest.hidden=YES;
    PDCA_Btn.enabled=NO;
    SFC_Btn.enabled=NO;
    unLimitTest=NO;
    looptestLabel.hidden=YES;
    looptestCount_TF.hidden=YES;
}
- (IBAction)ClickUploadPDCA:(NSButton *)sender
{
    if (sender.state)
    {
        NSLog(@"上传 PDCA");
    }else
    {
        NSLog(@"取消上传 PDCA");
    }
}
- (IBAction)clickUpLoadSFC:(NSButton *)sender
{
    if (sender.state)
    {
        NSLog(@"上传 SFC");
    }else
    {
        NSLog(@"取消上传 SFC");
    }
}

- (IBAction)startBtn:(NSButton *)sender
{
    if (index == 1000)
    {
        NSLog(@"start the action!!");
        
        [startBtn setEnabled:NO];
        
        //清除数组
        [passItemsArr removeAllObjects];
        [failItemsArr removeAllObjects];
        [testItemTitleArr removeAllObjects];
        [testItemValueArr removeAllObjects];
        [testItemMinLimitArr removeAllObjects];
        [testItesmMaxLimitArr removeAllObjects];
        [testResultArr removeAllObjects];
        [testItemUnitArr removeAllObjects];
       
        
        index = 4;
    }
    else
    {
        NSLog(@"not readly !");
        return;
    }
    
    
}

-(void)setTimer:(float)seconds
{
    timerLab = [[NSTextField alloc] init];
    mk_queue = nil;
    mk_timer= nil;
    ct_cnt = 0;
    mythread = [[NSThread alloc] initWithTarget:self selector:@selector(timeWorking) object:nil];
    
    //创建异步队列
    if (mk_queue==nil)
    {
        mk_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    if (mk_timer==nil)
    {
        mk_timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    }
    
    dispatch_source_set_timer(mk_timer, dispatch_walltime(NULL, 0), seconds * NSEC_PER_SEC, 0); //每秒执行
    // 开启定时器
    dispatch_resume(mk_timer);
}

-(void)timeWorking
{
    // 事件回调
    dispatch_source_set_event_handler(mk_timer, ^{
        // 在主线程中实现需要的功能
        dispatch_async(dispatch_get_main_queue(), ^{
            ct_cnt = ct_cnt + 1;
            testFieldTimes.stringValue =[[NSString alloc]initWithFormat:@"CT:%.1f S",ct_cnt*0.1];
        });
    });
    
}


-(void)startTimerWithTextField:(NSTextField *)TF
{
    timerLab = TF;
    [mythread start];
}

//***************** stop timer *********************
-(void)stopTimer
{
    if(!mk_timer)
    {
        return;
    }
    dispatch_suspend(mk_timer);
}

//***************** continue timer *********************
-(void)continueTimer
{
    if(!mk_timer)
    {
        return;
    }
    dispatch_resume(mk_timer);
}


-(void)endTimer
{
    if (mk_timer == nil)
    {
        return;
    }
    [mythread cancel];
    dispatch_source_cancel(mk_timer);
    //定时器对象置空
    mk_queue = nil;
    mk_timer = nil;
    timerLab = nil;
    mythread = nil;
    ct_cnt = 0;
}


- (IBAction)clickToRefreshInfoBox:(NSButton *)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        passNumInfoTF.stringValue = @"0";
        passNumCalculateTF.stringValue = @"0%";
        failNumInfoTF.stringValue = @"0";
        failNumCalculateTF.stringValue = @"0%";
        totalNumInfo.stringValue = @"0";
        testNum = 0;
        passNum = 0;
        testCount.stringValue = @"0/0";
        SN_Collector.string = @"";
    });
    
}

- (void)setRepresentedObject:(id)representedObject
{
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}



//测试界面初始化
-(void)viewInit
{
    sfcManager = [BYDSFCManager Instance];
    
    dcrAppending=[[NSMutableString alloc]initWithString:@""];
    
    B2987_USB=NO;
    B2987_USB1=NO;
    B2987_USB2=NO;
    nulltest=NO;
    test_DOE.hidden=YES;
    isInstrument = NO;
    test_type=1;
    nullTestCount=0;
    sum_fix_Cap=0;
    sum_fix_B_E_Res=0;
    sum_fix_B2_E2_Res=0;
    sum_fix_B4_E4_Res=0;
    sum_fix_ABC_DEF_Res=0;
    
    ave_fix_Cap=0;
    ave_fix_B2_E2_Res=0;
    ave_fix_B4_E4_Res=0;
    ave_fix_B_E_Res=0;
    ave_fix_ABC_DEF_Res=0;
    
    max_fix_Cap=0;
    max_fix_B2_E2_Res=0;
    max_fix_B4_E4_Res=0;
    max_fix_B_E_Res=0;
    max_fix_ABC_DEF_Res=0;
    
    min_fix_Cap=0;
    min_fix_B2_E2_Res=0;
    min_fix_B4_E4_Res=0;
    min_fix_B_E_Res=0;
    min_fix_ABC_DEF_Res=0;
    
    fix_temp=0;
    
    
    looptestCount_TF.hidden=YES;
    dic_FixtureRefence=[[NSMutableDictionary alloc]init];
    store_Dic=[[NSMutableDictionary alloc]init];
    test_DC=0;
    didReceiveData=NO;
    agilentE4980A=[[AgilentE4980A alloc]init];
    agilentB2987A=[[AgilentB2987A alloc]init];
    agilent34461A=[[Agilent34461A alloc]init];
    agilent33500B=[[Agilent33500B alloc]init];
    alert = [[Alert alloc]init];
    
    OP_ID.state=YES;
    config_Change.state=YES;
    [startBtn setEnabled:NO];
    param = [[Param alloc]init];
    [param ParamRead:param_path];
    
    
    
    appendStr=[[NSMutableString alloc]initWithCapacity:10];
    
    
    fixtureDic=[[NSDictionary alloc]init];
    fixConfig =[[Plist alloc]init];
    fixtureDic=[fixConfig PlistRead:config_path];
    
    fixtureSerial=[ORSSerialPort serialPortWithPath:param.fixture_uart_port_name];
    fixtureSerial.baudRate=@B19200;
    fixtureSerial.delegate=self;
    
    
    aglientTools =[AgilentTools Instance];
    
    
    [self redirectSTD:STDOUT_FILENO];  //冲定向log
    [self redirectSTD:STDERR_FILENO];
    
    mkTimer = [[MKTimer alloc] init];
    plist = [[Plist alloc] init];
    mk_table = [[Table alloc] init];
    itemArr = [NSMutableArray arrayWithCapacity:0];
    txtLogMutableArr = [NSMutableArray arrayWithCapacity:0];
    passItemsArr = [NSMutableArray arrayWithCapacity:0];
    failItemsArr = [NSMutableArray arrayWithCapacity:0];
    
    testItemValueArr = [NSMutableArray arrayWithCapacity:0];
    testItemTitleArr = [NSMutableArray arrayWithCapacity:0];
    testItemMinLimitArr = [NSMutableArray arrayWithCapacity:0];
    testItesmMaxLimitArr = [NSMutableArray arrayWithCapacity:0];
    testResultArr  = [NSMutableArray arrayWithCapacity:0];
    testItemUnitArr = [NSMutableArray arrayWithCapacity:0];
    
    
    all_Pass = NO;
    unLimitTest=NO;
    
    item_index = 0;
    row_index = 0;
    index= 0;
    logView_Info.editable = NO;
    testNum = 0;
    passNum = 0;
    PDCA_Btn.enabled = NO;
    SFC_Btn.enabled = NO;
    
    
    if (param.isDebug)
    {
        bigTitleTF.stringValue = @"Debug Mode";
    }
    else
    {
        bigTitleTF.stringValue = param.sw_name;
    }
    
    if (param.scheme_1)
    {
        if (param.test_type.integerValue==1)
        {
            param.sw_ver=[NSString stringWithFormat:@"%@A",param.sw_ver_T2];
        }
        else if (param.test_type.integerValue==2)
        {
            param.sw_ver=[NSString stringWithFormat:@"%@B",param.sw_ver_T2];
        }
        else if (param.test_type.integerValue==3)
        {
            param.sw_ver=[NSString stringWithFormat:@"%@C",param.sw_ver_T2];
        }
        else
        {
            param.sw_ver=param.sw_ver_T2;
        }
        
        if (nulltest)
        {
            param.sw_ver=param.sw_ver_T2;
        }
        
    }
    else
    {
        if (param.test_type.integerValue==1)
        {
            param.sw_ver=[NSString stringWithFormat:@"%@A",param.sw_ver_T1];
        }
        else if (param.test_type.integerValue==2)
        {
            param.sw_ver=[NSString stringWithFormat:@"%@B",param.sw_ver_T1];
        }
        else if (param.test_type.integerValue==3)
        {
            param.sw_ver=[NSString stringWithFormat:@"%@C",param.sw_ver_T1];
        }
        else
        {
            param.sw_ver=param.sw_ver_T1;
        }
        
        if (nulltest)
        {
            param.sw_ver=param.sw_ver_T1;
        }
        
    }
    versionTF.stringValue =[NSString stringWithFormat:@"Version: %@",param.sw_ver];
    
    NSLog(@"进入 Station 工站");
    stationID_TF.stringValue = param.sw_name;
    
    
    //读取 plist 文件
    [self reloadPlist_Humid];
    [[NSUserDefaults standardUserDefaults] setObject:@"Station" forKey:@"CurrentStationStatus"];
    
    if (nulltest)
    {
        nullTestDone.hidden=NO;
    }
    //    [param ParamWrite:@"Param" Content:@"7777" Key:@"fix_Cap"];
    
    if (!nulltest)
    {
        NSArray *fixCapArr=[param.fix_Cap componentsSeparatedByString:@","];
        
        NSArray *beResArr=[param.fix_B_E_Res componentsSeparatedByString:@","];
        
        NSArray *b2e2ResArr=[param.fix_B2_E2_Res componentsSeparatedByString:@","];
        
        NSArray *b4e4ResArr=[param.fix_B4_E4_Res componentsSeparatedByString:@","];
        
        NSArray *a_fResArr=[param.fix_ABC_DEF_Res componentsSeparatedByString:@","];
        
        
        
        Cfix_Max=fixCapArr[1];
        Cfix_Min=fixCapArr[2];
        Cfix_Ave=fixCapArr[0];
        _Cfix=Cfix_Ave;
        
        
        B2_E2_Ref_Max=b2e2ResArr[1];
        B2_E2_Ref_Min=b2e2ResArr[2];
        B2_E2_Ref_Ave=b2e2ResArr[0];
        B2_E2_Ref=B2_E2_Ref_Ave;
        
        
        B4_E4_Ref_Max=b4e4ResArr[1];
        B4_E4_Ref_Min=b4e4ResArr[2];
        B4_E4_Ref_Ave=b4e4ResArr[0];
        B4_E4_Ref=B4_E4_Ref_Ave;
        
        B_E_Ref_Max=beResArr[1];
        B_E_Ref_Min=beResArr[2];
        B_E_Ref_Ave=beResArr[0];
        B_E_Ref=B_E_Ref_Ave;
        
        
        ABC_DEF_Ref_Max=a_fResArr[1];
        ABC_DEF_Ref_Min=a_fResArr[2];
        ABC_DEF_Ref_Ave=a_fResArr[0];
        ABC_DEF_Ref=ABC_DEF_Ref_Ave;

    }
    
    
    //初始化温湿度传感器
    typeConver = [TypeConverter Instance];
    appendData = [[NSMutableData alloc]init];
    humitureSerial = [ORSSerialPort serialPortWithPath:[NSString stringWithFormat:@"%@",param.humiture_uart_port_name]];
    humitureSerial.delegate = self;
    humitureSerial.baudRate =@B115200;
    humitAppendString =  [[NSMutableString alloc]initWithCapacity:10];
    
    
}

-(void)reloadPlist_Humid
{
    //读取 plist 文件
    if (param.scheme_1)
    {
        if (nulltest)
        {
           itemArr = [plist PlistRead:@"Station_Cr_3_Humid" Key:@"AllItems"];
        }
        else
        {
           itemArr = [plist PlistRead:[NSString stringWithFormat:@"Station_Cr_%ld_Humid",test_type] Key:@"AllItems"];
        }
    }
    
    mk_table = [mk_table init:_tab_View DisplayData:itemArr];
    
}

-(void)reloadPlist_NoHUmid
{
    //读取 plist 文件
    if (param.scheme_1)
    {
        if (nulltest)
        {
            if ([product_Type.title isEqualToString:@"Cr"])
            {
                itemArr = [plist PlistRead:@"Station_Cr_3" Key:@"AllItems"];
            }
            else
            {
                itemArr = [plist PlistRead:@"Station_Ti_3" Key:@"AllItems"];
            }
        }
        else
        {
            if ([product_Type.title isEqualToString:@"Cr"])
            {
                itemArr = [plist PlistRead:[NSString stringWithFormat:@"Station_Cr_%ld",test_type] Key:@"AllItems"];
            }
            else
            {
                itemArr = [plist PlistRead:[NSString stringWithFormat:@"Station_Ti_%ld",test_type] Key:@"AllItems"];
            }
        }
    }else
    {
        if (nulltest)
        {
            itemArr = [plist PlistRead:@"Station_3" Key:@"AllItems"];
        }
        else
        {
            itemArr = [plist PlistRead:[NSString stringWithFormat:@"Station_%ld",test_type] Key:@"AllItems"];
        }
    }
    
    mk_table = [mk_table init:_tab_View DisplayData:itemArr];
    
}

-(void)Working
{
    
    if (testItem == nil)
    {
        testItem  = [[Item alloc] init];
    }
    while (fixtureSerial==nil && !param.isDebug)
    {
        fixtureSerial=[ORSSerialPort serialPortWithPath:param.fixture_uart_port_name];
        if (fixtureSerial==nil)
        {
            dispatch_sync(dispatch_get_main_queue(), ^{
                currentStateMsg.stringValue=@"fixture connect fail!";
                [currentStateMsg setTextColor:[NSColor redColor]];
            });
            sleep(2);
            NSLog(@"Please check the fixture connect!");
        }else
        {
            fixtureSerial.baudRate=@B19200;
            fixtureSerial.delegate=self;
        }
    }
    
    //NSInteger recycleCount = 0;
    
    while ([[NSThread currentThread] isCancelled]==NO) //线程未结束一直处于循环状态
    {
#pragma mark index=0 打开治具，串口通信
        if (index==0)
        {

                [fixtureSerial open];
                
                [NSThread sleepForTimeInterval:0.5];
                
                BOOL uartConnect=NO;
                //Debug mode
                if (param.isDebug)
                {
                    uartConnect = YES;
                    index = 1;
                    fixtureID_TF.stringValue=@"20170710174301.5001";
                    fixtureID=@"20170710174301.5001";
                }
                
                if ([fixtureSerial isOpen]||uartConnect==YES)
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        currentStateMsg.stringValue=@"index=0,fixture connect ok!";
                        NSLog(@"index=0,fixture connect ok!");
                        [currentStateMsg setTextColor:[NSColor blueColor]];
                    });
                    //获取治具
                    if (!param.isDebug)
                    {
                        [NSThread sleepForTimeInterval:0.5];
                        
                        [self Fixture:fixtureSerial writeCommand:@"FIXTURE ID?"];
                        while (1)
                        {
                            if (didReceiveData || param.isDebug) {
                                break;
                            }
                            
                        }
                        didReceiveData=NO;
                        NSArray * array =[backStr componentsSeparatedByString:@"\n"];
                        if ([array count]>=1)
                        {
                            
                            fixtureID=[array objectAtIndex:0];
                            fixtureID=[fixtureID stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                            fixtureID=[fixtureID stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                            //将station id
                            sfcManager.station_id = [[fixtureID componentsSeparatedByString:@"."]objectAtIndex:1];
                            NSLog(@"fixtureID_TF_backString==============%@",sfcManager.station_id);
                        }
                        
                    }
                    dispatch_sync(dispatch_get_main_queue(), ^{
                        currentStateMsg.stringValue=@"index=0,fixture connect ok!";
                        if (!param.isDebug)
                        {
                            
                            fixtureID_TF.stringValue=fixtureID;
                        }
                    });
                    
                    [NSThread sleepForTimeInterval:0.5];
                    
                    [self Fixture:fixtureSerial writeCommand:@"RESET"];
                  
                    while (1)
                    {
                        if (didReceiveData || param.isDebug) {
                            break;
                        }
                    }
                    didReceiveData=NO;
                    if ([[backStr uppercaseString ]containsString:@"OK"])
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            currentStateMsg.stringValue=@"fixture reset ok!";
                            NSLog(@"fixture reset ok!");
                            [currentStateMsg setTextColor:[NSColor blueColor]];
                        });
                        index = 1;
                    }
                    
                }
                else
                {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // sleep(1);
                        currentStateMsg.stringValue=@"index=0,fixture connect fail!";
                        
                        NSLog(@"index=0,fixture connect fail!");
                        [currentStateMsg setTextColor:[NSColor redColor]];
                    });
                    sleep(2);
                }

            
            
        }
        
        
#pragma mark 打开安捷LCR表 && 静电计
       
        if (index==1)
        {
            BOOL agilent_isOpen;
            //Debug mode
            if (param.isDebug)
            {
                agilent_isOpen = YES;
            }
            else
            {
                
                BOOL e4980A=[agilentE4980A Find:nil andCommunicateType:AgilentE4980A_USB_Type]&&[agilentE4980A OpenDevice:nil andCommunicateType:AgilentE4980A_USB_Type];
                if (!e4980A)
                {
                    NSLog(@"E4980A open fail !");
                }
                
                BOOL b2987A=[agilentB2987A Find:nil andCommunicateType:AgilentB2987A_USB_Type1]&&[agilentB2987A OpenDevice:nil andCommunicateType:AgilentB2987A_USB_Type1];
                if (!b2987A)
                {
                    NSLog(@"B2987A open fail !");
                }
                if (e4980A && b2987A) {
                    agilent_isOpen=YES;
                }
                else
                {
                    agilent_isOpen=NO;
                }
            }
            //打开连接的设备，并选择通讯模式
            
            sleep(1);
            if (agilent_isOpen)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    currentStateMsg.stringValue=@"index=1,aglient connect ok!";
                    NSLog(@"index=1,aglient connect ok!");
                    [currentStateMsg setTextColor:[NSColor blueColor]];
                });
                index = 2;
                
            }//打开成功，则index=2
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    currentStateMsg.stringValue=@"index=1,aglient connect fail!";
                    NSLog(@"index=1,aglient connect fail!");
                    [currentStateMsg setTextColor:[NSColor redColor]];
                });
                sleep(1);
                
            }
            
        }
        
#pragma mark index=2 初始化温度传感器
        if (index==2)
        {
            BOOL isConnect=[humitureSerial isOpen];
            //Debug mode
            if (param.isDebug)
            {
                isConnect = YES;
            }
            
            sleep(1);
            if (!isConnect)
            {
                [humitureSerial open];
                
                if ([humitureSerial isOpen])
                {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        currentStateMsg.stringValue=@"index=2,Humit connect ok!";
                        NSLog(@"index=2,Humit connect ok!");
                        [currentStateMsg setTextColor:[NSColor blueColor]];
                    });
                    
                    index = 3;
                }
                else
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        currentStateMsg.stringValue=@"index=2,Humit connect Fail!";
                        NSLog(@"index=2,Humit connect Fail!");
                        [currentStateMsg setTextColor:[NSColor blueColor]];
                    });
                    
                }
                
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    currentStateMsg.stringValue=@"index=2,Humit connect OK!";
                    NSLog(@"index=2,Humit connect OK!");
                    [currentStateMsg setTextColor:[NSColor redColor]];
                });
                sleep(1);
                index = 3;
            }
        }
        
        
#pragma mark index=3  准备点击Start按钮
        if (index==3)
        {
           
            [NSThread sleepForTimeInterval:0.5];
            
            if (humitureSerial.isOpen)
            {
                [self Fixture:humitureSerial writeCommand:@"READ"];
                
                while (1)
                {
                    if (didReceiveData || param.isDebug) {
                        break;
                    }
                }
                didReceiveData=NO;
                humitString = [humitString stringByReplacingOccurrencesOfString:@"\r" withString:@""];
                NSLog(@"%@",humitString);
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [humit_TextF setStringValue:humitString];
                });
            }
            if (param.isDebug)
            {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [humit_TextF setStringValue:@"26.3,52.6%"];
                });
            }
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                currentStateMsg.stringValue=@"index=3,Please Enter SN!";
                NSLog(@"index=3,Please Enter SN!");
                [currentStateMsg setTextColor:[NSColor redColor]];
                startBtn.enabled=YES;
                sleep(1);
                
            });
            
            
            sonFixtureDic =[fixtureDic objectForKey:[NSString stringWithFormat:@"PCB_%@",[fixtureID stringByReplacingOccurrencesOfString:@"." withString:@""]]];
            
            if (unLimitTest==YES)
            {
                index = 4;
            }
            else
            {
                index=1000;
                
            }
            
        }
        
        
#pragma mark index=4  输入产品sn
        if (index==4)
        {
            if (once==1)
            {
                once=0;
                loopTest_count=looptestCount_TF.stringValue.integerValue;
            }
            nest_ID=nestIDChoose.title;
            sleep(1);
            [self GetSFC_PDCAState];//获取是否上传的状态
            
            [self UpdateTextView:@"\n\n" andClear:YES andTextView:FailItemView];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
               
                
                //判断 SN 的规则
                if ([importSN.stringValue length] == [SNLengNumPop.titleOfSelectedItem intValue])
                {
                    [[NSUserDefaults standardUserDefaults] setObject:importSN.stringValue forKey:@"theSN"];
                    
                    if (![nest_ID containsString:@"BC"]) {
                        //读取 plist 文件
                        [mk_table ClearTable];
                        [self reloadPlist_Humid];
                        [[NSUserDefaults standardUserDefaults] setObject:@"AllItems" forKey:@"currentPlistKey"];;
                    }
                    currentStateMsg.stringValue = @"index=4,SN ok!";
                    NSLog(@"index=4,SN ok!");
                    [currentStateMsg setTextColor:[NSColor blueColor]];
                    sleep(1);
                    index=5;//进入正常测试中
                }
                else
                {
                    currentStateMsg.stringValue = @"index=4,SN error!";
                    NSLog(@"index=4,SN error!");
                    [currentStateMsg setTextColor:[NSColor redColor]];
                }
            });
            //cycle_test,开始测试前清空tableView
            [mk_table ClearTable];
            ct_cnt = 0;
            
            
        }
        
        
#pragma mark index=5   SFC 检验 SN 是否过站
        if (index==5)
        {
            if (isUpLoadSFC)
            {
                NSString* startTime = [[GetTimeDay shareInstance] getCurrentDayTime];
                
                if([[TestStep Instance] StepSFC_CheckUploadSN:isUpLoadSFC Option:@"isConnectServer" testResult:nil startTime:startTime testArgument:nil]){
                    
                    NSString* startTime = [[GetTimeDay shareInstance] getCurrentDayTime];
                    [TestStep Instance].strSN=importSN.stringValue;
                    if (![[TestStep Instance] StepSFC_CheckUploadSN:isUpLoadSFC Option:@"isPassOrNot" testResult:nil startTime:startTime testArgument:nil])
                    {
                        NSLog(@"index=5,SFC check fail");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            startBtn.enabled = YES;
                             currentStateMsg.stringValue = @"上一个工站检测NG";
                            [currentStateMsg setTextColor:[NSColor redColor]];
                        });
                      
                        //sleep(1);
                        index = 1000;
                    }
                    else
                    {
                        NSLog(@"index=5,SFC Check Success");
                     
                        currentStateMsg.stringValue = @"index=6,SFC Check Success";
                        [currentStateMsg setTextColor:[NSColor redColor]];
                        // sleep(1);
                        index = 6;//进入正常测试中
                    }
                    
                }
                else{
                    
                    NSLog(@"SFC Server Connect fail!");
                    currentStateMsg.stringValue = @"index=5,SFC Server Connect Fail!";
                    [currentStateMsg setTextColor:[NSColor redColor]];
                }
            }
            else
            {
                NSLog(@"index=5,SFC No check!");
                currentStateMsg.stringValue = @"index=5,SFC No check!";
                [currentStateMsg setTextColor:[NSColor redColor]];
                index = 6;
            }

            op_ID=OP_ID_TF.stringValue;
            config_product=product_Config.stringValue;
            config_pro=[NSString stringWithFormat:@"Config_%@",product_Config.stringValue];
            sfcManager.config_pro = config_product;
            
            
            if (config_Change.state==YES)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Please confirm the product config!");
                    currentStateMsg.stringValue = @"请取消 change 按钮!";
                    [currentStateMsg setTextColor:[NSColor redColor]];
                });
                sleep(1);
                index=5;
            }
            
            if (OP_ID.state==YES)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Please confirm the Operator ID!");
                    currentStateMsg.stringValue = @"请取消 Operator ID! 按钮";
                    [currentStateMsg setTextColor:[NSColor redColor]];
                });
                sleep(1);
                index=5;
            }
            
            if (op_ID.length != 17)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Operator ID length error!");
                    currentStateMsg.stringValue = @"Operator ID 长度不正确!";
                    [currentStateMsg setTextColor:[NSColor redColor]];
                });
                sleep(1);
                index=5;
            }
            
            
            
            
        }
        
        
#pragma mark index=6   检测门是否被完全关闭
        if (index==6)
        {
            [NSThread sleepForTimeInterval:0.5];
            
            [self Fixture:fixtureSerial writeCommand:@"TRAY CLOSE?"];
            while (1)
            {
                if (didReceiveData || param.isDebug) {
                    break;
                }
            }
            didReceiveData=NO;
            NSString *trayReturn;
            NSArray * arrayTRAY =[backStr componentsSeparatedByString:@"\n"];
            if ([arrayTRAY count]>=1)
            {
                trayReturn=[arrayTRAY objectAtIndex:0];
            }
            
            if ([trayReturn containsString:@"TRAY CLOSE=TRUE"] || param.isDebug)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"index=6,RAY CLOSE=TRUE!");
                    currentStateMsg.stringValue = @"index=6,RAY CLOSE=TRUE!";
                    [currentStateMsg setTextColor:[NSColor redColor]];
                });
                sleep(1);
                
                index = 7;
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"index=6,Please close the door!");
                    currentStateMsg.stringValue = @"index=6,Please close the door!";
                    [currentStateMsg setTextColor:[NSColor redColor]];
                });
                sleep(1);
                
            }
      
            config_product=product_Config.stringValue;
            config_pro=[NSString stringWithFormat:@"Config_%@",product_Config.stringValue];
            if (config_Change.state==YES)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"Please confirm the product config!");
                    currentStateMsg.stringValue = @"Please confirm the config!";
                    [currentStateMsg setTextColor:[NSColor redColor]];
                });
                sleep(1);
                index=6;
            }

        }
    
#pragma mark index=7    开始测试
        if (index==7)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                startBtn.enabled = NO;
                currentStateMsg.stringValue = @"index=7 running...";
                NSLog(@"index=7 running...");
                [currentStateMsg setTextColor:[NSColor blueColor]];
                testResult.stringValue = @"Running";
                testResult.backgroundColor = [NSColor greenColor];
            });//当前测试状态显示
            
            //========定时器开始========
            if (ct_cnt == 0)
            {
                [mkTimer setTimer:0.1];
                [mkTimer startTimerWithTextField:testFieldTimes];
                ct_cnt = 1;
            }//开启定时器，并显示到测试界面上
            //=========================
            
            //在这里加入测试的起始时间
            if (row_index == 0)
            {
                start_time = [[GetTimeDay shareInstance] getFileTime];    //启动测试的时间,csv里面用
            }//获取当前时间，作为测试起始时间start_time
            
            testItem = itemArr[item_index];
            
            //txt log
            [txtLogMutableArr addObject:[NSString stringWithFormat:@"\n\nStartTimer:%@\nTestName:%@\nUnit:%@\nLowerLimit:%@\nUpperLimit:%@\n",[[GetTimeDay shareInstance] getCurrentTime],testItem.testName,testItem.units,testItem.min,testItem.max]];
            
            //加载测试项
            BOOL boolResult = [self TestItem:testItem];
            //测试结果转为字符串格式
            if (boolResult == YES)
            {
                itemResult = @"PASS";
            }
            else
            {
                itemResult = @"FAIL";
            }
            //把测试结果加入到可变数组中
            [testResultArr addObject:itemResult];
            
            [mk_table flushTableRow:testItem RowIndex:row_index];
            
            //更新失败项内容
            if ([testItem.result isEqualToString:@"FAIL"]) {
                
                [self UpdateTextView:[NSString stringWithFormat:@"FailItem->:%@\n",testItem.testName] andClear:NO andTextView:FailItemView];
            }
            
            //给治具发送reset指令,收到 RESET_OK 后往下跑
            
            row_index++;
            item_index++;
            
            
            //走完测试流程,进入下一步
            if (item_index == itemArr.count)
            {
                nullTestCount++;
                
                //异步加载主线程显示,弹出啊 log_View
                dispatch_async(dispatch_get_main_queue(), ^{
                    //遍历测试结果,输出总测试结果
                    for (int i = 0; i< testResultArr.count; i++)
                    {
                        if ([testResultArr[i] containsString:@"FAIL"])
                        {
                            [testResult setStringValue:@"FAIL"];
                            testResult.backgroundColor = [NSColor redColor];
                            break;
                        }
                        else
                        {
                            [testResult setStringValue:@"PASS"];
                            testResult.backgroundColor = [NSColor greenColor];
                        }
                    }
                    
                    testResultStr = testResult.stringValue;
                    sleep(0.5);
                });
                
                
                index = 8;
            }
            
        }

#pragma mark index=8     生成本地数据
        if (index==8)
        {
            //========定时器结束========
            [mkTimer endTimer];
            //记录PDCA结束时间;记录测试结束时间
            // [pdca PDCA_GetEndTime];
            ct_cnt = 0;
            //========================
            test_DC=0;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                currentStateMsg.stringValue = @"index=7 create log file...";
                NSLog(@"index=7 create log file...");
                [currentStateMsg setTextColor:[NSColor blueColor]];
            });
            sleep(1);
            
            if([MK_FileCSV shareInstance]!= nil)       //生成本地数据报表
            {
                testNum++; //测试
                //文件夹路径
                NSString *currentPath=@"/vault";
                
                //测试结束并创建文件的时间
                end_time = [[GetTimeDay shareInstance] getFileTime];
                
                //产品 sn
                NSString *currentSN = importSN.stringValue;
                
                //创建总文件夹
                [[MK_FileFolder shareInstance] createOrFlowFolderWithCurrentPath:currentPath SubjectName:@"BCM_Log"];
                
                //从 json 文件获取本机工站等信息, 拼接到主文件夹中
//                NSError  * error;
//                NSData  * data=[NSData dataWithContentsOfFile:@"/vault/data_collection/test_station_config/gh_station_info.json"];
//                NSDictionary * jsonDic=[[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error] objectForKey:@"ghinfo"];
   
                //创建对应不同工站的文件夹
                
                NSString *mainFolderName = [NSString stringWithFormat:@"%@_%@",param.sw_name,param.sw_ver];
                
                [[MK_FileFolder shareInstance] createOrFlowFolderWithCurrentPath:[NSString stringWithFormat:@"%@/BCM_Log/%@/",currentPath,[[GetTimeDay shareInstance] getCurrentDay]] SubjectName:[NSString stringWithFormat:@"%@/%@/%@/%@/",mainFolderName,nest_ID,product_Type.title,config_pro]];
                
                
                
                NSString *mainfolderPath = [NSString stringWithFormat:@"%@/BCM_Log/%@/%@/",currentPath,[[GetTimeDay shareInstance] getCurrentDay],mainFolderName];
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@/%@/%@/",mainfolderPath,product_Type.title,config_pro] forKey:@"mainFolderPathKey"];
                [[NSUserDefaults standardUserDefaults] setObject:mainFolderName forKey:@"mainFolderNameKey"];
                
                //csv文件列表头,测试标题项遍历当前plisth文件的测试项(拼接),温湿度传感器
                NSString *min_Str;
                NSMutableString *minMutableStr;
                
                NSString *max_Str;
                NSMutableString *maxMutableStr;
                
                NSString *titleStr;
                NSMutableString *titleMutableStr;
                
                NSString *unitStr;
                NSMutableString *unitMutableStr;
                
                if (titleMutableStr == nil)
                {
                    titleMutableStr = [[NSMutableString alloc] init];
                }
                if (minMutableStr == nil)
                {
                    minMutableStr = [[NSMutableString alloc] init];
                }
                if (maxMutableStr == nil)
                {
                    maxMutableStr = [[NSMutableString alloc] init];
                }
                
                if (unitMutableStr == nil)
                {
                    unitMutableStr = [[NSMutableString alloc] init];
                }
                
                
                for (int i = 0; i< testItemTitleArr.count; i++)
                {
                    titleStr = [testItemTitleArr objectAtIndex:i];
                    
                    if (i==0)
                    {
                        [titleMutableStr appendString:[NSString stringWithFormat:@"%@",titleStr]];
                        min_Str = [testItemMinLimitArr objectAtIndex:i];
                        [minMutableStr appendString:[NSString stringWithFormat:@",,,,,,,,,%@",min_Str]];
                        max_Str = [testItesmMaxLimitArr objectAtIndex:i];
                        [maxMutableStr appendString:[NSString stringWithFormat:@",,,,,,,,,%@",max_Str]];
                        unitStr=[testItemUnitArr objectAtIndex:i];
                        [unitMutableStr appendString:[NSString stringWithFormat:@",,,,,,,,,%@",unitStr]];
                    }
                    else
                    {
                        [titleMutableStr appendString:[NSString stringWithFormat:@",%@",titleStr]];
                        min_Str = [testItemMinLimitArr objectAtIndex:i];
                        [minMutableStr appendString:[NSString stringWithFormat:@",%@",min_Str]];
                        max_Str = [testItesmMaxLimitArr objectAtIndex:i];
                        [maxMutableStr appendString:[NSString stringWithFormat:@",%@",max_Str]];
                        unitStr=[testItemUnitArr objectAtIndex:i];
                        [unitMutableStr appendString:[NSString stringWithFormat:@",%@",unitStr]];
                        
                    }
                    
                    
                    
                    if (i==testItemTitleArr.count-1) {
                        NSLog(@"titleMutableStr==\n%@\n\nminMutableStr==\n%@\n\nmaxMutableStr==%@\n",titleMutableStr,minMutableStr,maxMutableStr);
                    }
                    
                }
                
                //                NSString *csvTitle = [NSString stringWithFormat:@"Version:,%@\nPCB_ID:,%@\nFixtureID:,%@\nNestID:,%@\n,Max,Min,Ave\nCAP_Fixture:,%@pF,%@pF,%@pF\nB2-E2_Res:,%@GOhm,%@GOhm,%@GOhm\nB4-E4_Res:,%@GOhm,%@GOhm,%@GOhm\nB-E_Res:,%@GOhm,%@GOhm,%@GOhm\nABC-DEF_Res:,%@GOhm,%@GOhm,%@GOhm\nSN,TestResult,Operator_ID,Product_Type,Config,%@,StartTime,EndTime\nMin_Limit,%@\nMax_Limit,%@\n%@",param.sw_ver,param.PCB_id,fixtureID,nest_ID,Cfix_Max,Cfix_Min,Cfix_Ave,B2_E2_Ref_Max,B2_E2_Ref_Min,B2_E2_Ref_Ave,B4_E4_Ref_Max,B4_E4_Ref_Min,B4_E4_Ref_Ave,B_E_Ref_Max,B_E_Ref_Min,B_E_Ref_Ave,ABC_DEF_Ref_Max,ABC_DEF_Ref_Min,ABC_DEF_Ref_Ave,titleMutableStr,minMutableStr,maxMutableStr,unitMutableStr];
                //                 NSString *csvTitle = [NSString stringWithFormat:@"Version:,%@\nPCB_ID:,%@\nFixtureID:,%@\nNestID:,%@\n,Max,Min,Ave\nCAP_Fixture:,%@pF,%@pF,%@pF\nB2-E2_Res:,%@GOhm,%@GOhm,%@GOhm\nB4-E4_Res:,%@GOhm,%@GOhm,%@GOhm\nB-E_Res:,%@GOhm,%@GOhm,%@GOhm\nABC-DEF_Res:,%@GOhm,%@GOhm,%@GOhm\nStartTime,EndTime,Product_Type,Config,SN,TestResult,FixtureID,Operator_ID,%@\nMin_Limit,%@\nMax_Limit,%@\n%@",param.sw_ver,param.PCB_id,fixtureID,nest_ID,Cfix_Max,Cfix_Min,Cfix_Ave,B2_E2_Ref_Max,B2_E2_Ref_Min,B2_E2_Ref_Ave,B4_E4_Ref_Max,B4_E4_Ref_Min,B4_E4_Ref_Ave,B_E_Ref_Max,B_E_Ref_Min,B_E_Ref_Ave,ABC_DEF_Ref_Max,ABC_DEF_Ref_Min,ABC_DEF_Ref_Ave,titleMutableStr,minMutableStr,maxMutableStr,unitMutableStr];
                
                NSString *csvTitle = [NSString stringWithFormat:@"StartTime,EndTime,Version,NestID,Product_Type,Config,SN,TestResult,FixtureID,Operator_ID,%@\nMin_Limit,%@\nMax_Limit,%@\nUnit,%@",titleMutableStr,minMutableStr,maxMutableStr,unitMutableStr];
                
                //csv测试项内容,同上
                NSString *csvContentStr;
                NSMutableString *csvContentMutableStr;
                if (csvContentMutableStr == nil)
                {
                    csvContentMutableStr = [[NSMutableString alloc] init];
                }
                for (int i=0; i< testItemValueArr.count; i++)
                {
                    csvContentStr = [testItemValueArr objectAtIndex:i];
                    if (i==0)
                    {
                        //                        [csvContentMutableStr appendString:[NSString stringWithFormat:@"%@,%@,%@,%@",config_product,op_ID,product_Type.title,csvContentStr]];
                        [csvContentMutableStr appendString:[NSString stringWithFormat:@"%@",csvContentStr]];
                        
                    }
                    else
                    {
                        [csvContentMutableStr appendString:[NSString stringWithFormat:@",%@",csvContentStr]];
                        
                    }
                    
                }
                
                
                // add for DCR fourty times test
                //多生成的40个数据
//                if (!nulltest&&[test_DOE.title isEqualToString:@"TEST"]) {
//                    [csvContentMutableStr appendString:[NSString stringWithFormat:@",%@",dcrAppending]];
//                }
                
                
                //创建 csv 总文件,并写入数据
                [[MK_FileCSV shareInstance] createOrFlowCSVFileWithFolderPath:[NSString stringWithFormat:@"%@/%@/%@",mainfolderPath,nest_ID,product_Type.title] Sn:nil TestItemStartTime:start_time TestItemEndTime:end_time TestItemContent:csvContentMutableStr TestItemTitle:csvTitle TestResult:testResultStr ProductConfig:product_Config.stringValue FixtureID:fixtureID OperatorID:op_ID ProductType:product_Type.title Version:param.sw_ver NestID:nest_ID];
                
                //生成Config的总文件
                [[MK_FileCSV shareInstance] createOrFlowCSVFileWithFolderPath:[NSString stringWithFormat:@"%@%@/%@/%@",mainfolderPath,nest_ID,product_Type.title,config_pro] Sn:nil TestItemStartTime:start_time TestItemEndTime:end_time TestItemContent:csvContentMutableStr TestItemTitle:csvTitle TestResult:testResultStr ProductConfig:product_Config.stringValue FixtureID:fixtureID OperatorID:op_ID ProductType:product_Type.title Version:param.sw_ver NestID:nest_ID];
//
//                //对应每个 SN 创建 csv 文件,并写入数据
//                //                [[MK_FileCSV shareInstance] createOrFlowCSVFileWithFolderPath:[MK_FileFolder shareInstance].folderPath Sn:currentSN TestItemStartTime:start_time TestItemEndTime:end_time TestItemContent:csvContentMutableStr TestItemTitle:csvTitle TestResult:testResultStr];
//
                
                
                 [[MK_FileCSV shareInstance] createOrFlowCSVFileWithFolderPath:[MK_FileFolder shareInstance].folderPath Sn:currentSN TestItemStartTime:start_time TestItemEndTime:end_time TestItemContent:csvContentMutableStr TestItemTitle:csvTitle TestResult:testResultStr ProductConfig:product_Config.stringValue FixtureID:fixtureID OperatorID:op_ID ProductType:product_Type.title Version:param.sw_ver NestID:nest_ID];

                
                
                
                //创建一个共享文件
                [[MK_FileCSV shareInstance] createOrFlowCSVFileWithFolderPath:@"/vault/BCM_Single_Log/" Sn:currentSN TestItemStartTime:start_time TestItemEndTime:end_time TestItemContent:csvContentMutableStr TestItemTitle:csvTitle TestResult:testResultStr ProductConfig:product_Config.stringValue FixtureID:fixtureID OperatorID:op_ID ProductType:product_Type.title Version:param.sw_ver NestID:nest_ID];
                
                //txt测试项内容,同上  txt log
                NSString *txtContentStr;
                NSMutableString *failMessageStr;
                NSMutableString *txtContentMutableStr;
                if (txtContentMutableStr == nil)
                {
                    txtContentMutableStr = [[NSMutableString alloc] init];
                }
                
                if (failMessageStr == nil)
                {
                    failMessageStr = [[NSMutableString alloc] init];
                }
                
                
                for (int i=0; i< txtLogMutableArr.count; i++)
                {
                    txtContentStr = [txtLogMutableArr objectAtIndex:i];
                    
                    if ([txtContentStr containsString:@"FAIL"])
                    {
                        if ([[txtLogMutableArr objectAtIndex:i-5] containsString:@"MODE_Sine"]) {
                            
                            for (int j=i-7; j<=i; j++)
                            {
                                [failMessageStr appendString:[NSString stringWithFormat:@"%@",[txtLogMutableArr objectAtIndex:j]]];
                            }
                        }
                        else
                        {
                            for (int j=i-5; j<=i; j++)
                            {
                                [failMessageStr appendString:[NSString stringWithFormat:@"%@",[txtLogMutableArr objectAtIndex:j]]];
                            }
                        }
                    }
                    
                    [txtContentMutableStr appendString:[NSString stringWithFormat:@"%@",txtContentStr]];
                }
                
                
                
                
                
//                //创建 txt 文件,并写入数据
                [[MK_FileTXT shareInstance] createOrFlowTXTFileWithFolderPath:[MK_FileFolder shareInstance].folderPath Sn:currentSN TestItemStartTime:start_time TestItemEndTime:end_time TestItemContent:[NSString stringWithFormat:@"\nVersion:%@\nProduct_type:%@\nConfig:%@\nOperator_ID:%@\nSN:%@\n%@",param.sw_ver,product_Type.title,config_product,op_ID,importSN.stringValue,txtContentMutableStr] TestResult:testResultStr];
                
                if (failMessageStr.length>0)
                {
                    //                    [[MK_FileTXT shareInstance] createOrFlowTXTFileWithFolderPath:[MK_FileFolder shareInstance].folderPath Sn:@"failMessage" TestItemStartTime:start_time TestItemEndTime:end_time TestItemContent:[NSString stringWithFormat:@"\nVersion:%@\nSN:%@\n%@",param.sw_ver,importSN.stringValue,failMessageStr] TestResult:testResultStr];
                }
                
                
                
                
            }
            
            index = 9;
            
        }
        
#pragma mark index=9     上传PDCA和SFC
        if (index == 9) {
            
            if (isUpLoadPDCA)
            {
                [self uploadPDCA_Feicui_2];
                NSLog(@"上传PDCA");
            }
            if (isUpLoadSFC)
            {
                NSLog(@"上传SFC");
                NSString * test_upload_Result;
                NSString* startTime = [[GetTimeDay shareInstance] getCurrentDayTime];
                
                if ([testResultStr isEqualToString:@"PASS"]) {
                    
                    test_upload_Result = @"Pass";
                }
                else
                {
                    test_upload_Result = @"Fail";
                }
                
                
                if (![[TestStep Instance] StepSFC_CheckUploadSN:isUpLoadSFC Option:@"uploadLog" testResult:test_upload_Result startTime:startTime testArgument:testItemValueArr])
                {
                    NSLog(@"index=8,SFC check fail");
                    sleep(1);
                }
                else
                {
                    NSLog(@"index=8, has upload sfc");
                    currentStateMsg.stringValue = @"SFC Upload Success";
                    
                    sleep(1);
                }
                
            }
            
            index = 10;
            
        }
        
#pragma mark index=10  结束测试
        if (index==10)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                currentStateMsg.stringValue = @"index=10,test endding!";
                NSLog(@"index=10,test endding!");
                [currentStateMsg setTextColor:[NSColor blueColor]];
            });
            
            sleep(1);
            //每次结束测试都刷新主界面
            if ([testResult.stringValue isEqualToString:@"PASS"])
            {
                passNum++;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                testCount.stringValue = [NSString stringWithFormat:@"%d/%d",passNum,testNum];
                totalNumInfo.stringValue = [NSString stringWithFormat:@"%d",testNum];
                
                passNumInfoTF.stringValue = [NSString stringWithFormat:@"%d",passNum];
                passNumCalculateTF.stringValue = [NSString stringWithFormat:@"%.2f%%",((double)passNum/(double)testNum)*100];
                
                failNumInfoTF.stringValue = [NSString stringWithFormat:@"%d",(testNum - passNum)];
                failNumCalculateTF.stringValue = [NSString stringWithFormat:@"%.2f%%",((double)(testNum-passNum)/(double)testNum)*100];
                
                //录入sn 收集器
                NSString *str1 = [NSString stringWithFormat:@"%@___%@__%@",importSN.stringValue,testResultStr,[[GetTimeDay shareInstance] getCurrentTime]];
                NSString *str2 = SN_Collector.string;
                SN_Collector.string = [str2 stringByAppendingString:[NSString stringWithFormat:@"%@\n",str1]];
                [SN_Collector setTextColor:[NSColor blueColor]];
                
                //是否需要写入本地缓存
                
                if (!unLimitTest) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        importSN.stringValue = @"";
                    });
                }
                
            });
            
            index=11;
            
        }
        
        
#pragma mark index=11  跳出循环
        if (index==11)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [startBtn setEnabled:YES];
            });
            
            item_index = 0;
            row_index=0;
            
            [self Fixture:fixtureSerial writeCommand:@"RESET"];
            while (1) {
                if (didReceiveData || param.isDebug)
                {
                    break;
                }
            }
            didReceiveData=NO;
            if ([[backStr uppercaseString ]containsString:@"OK"])
            {
                index=1000;
            }
        
            //无限循环测试
            if (unLimitTest==YES)
            {
                
               
                //sleep(1);
                if (loopTest_count>1)
                {
                    index = 4;
                }
                else
                {
                    index=1000;
                    once=1;
                }
                [self removeDataFromArray];
                loopTest_count--;
            }
            else
            {
                index = 1000;
            }
            
            
        }
        
        
#pragma mark index=1000 等待状态
        if (index==1000)
        {
            
            
            
            [NSThread sleepForTimeInterval:0.5];
        }
        
        
    }

        
        

        
        
}

//================================================
//测试项指令解析
//================================================
-(BOOL)TestItem:(Item*)testitem
{
    
    
    BOOL ispass=NO;
    backStr=nil;
    NSInteger cycleTime_CMD;
    if (param.scheme_1)
    {
        cycleTime_CMD=testitem.testAllCommand.count;
    }else
    {
        
        cycleTime_CMD=testitem.testAllCommand_2.count;
    }
    
#pragma mark--------具体测试指令执行流程
    for (int i=0; i<cycleTime_CMD; i++)   //item 0
    {
        //治具===================Fixture
        //安捷伦测试仪表============Aglient
        //延迟时间================SW
        
        if (param.scheme_1)
        {
            dic=[testitem.testAllCommand objectAtIndex:i];
        }
        else
        {
            dic=[testitem.testAllCommand_2 objectAtIndex:i];
        }
        
        
        SonTestDevice=dic[@"TestDevice"];
        SonTestCommand=dic[@"TestCommand"];
        SonTestName=dic[@"TestName"];
        delayTime = [dic[@"TestDelayTime"] intValue]/1000;
        didReceiveData=NO;
        
        
        if ([SonTestDevice isEqualToString:@"Fixture"])//与治具建立通信，选取测试点
        {
            
            if (![testItem.testName isEqualToString:@"FIXTURE ID"]) {
                
                [self Fixture:fixtureSerial writeCommand:SonTestCommand];
                NSLog(@"%@ send:>>%@",SonTestDevice,SonTestCommand);
                while (1)
                {
                    
                    if (didReceiveData || param.isDebug)
                    {
                        break;
                    }
                }
                didReceiveData=NO;
                int indexTime=0;
                
                while (YES)
                {
                    
                    if ([[backStr uppercaseString ]containsString:@"OK"]||indexTime==[testitem.retryTimes intValue])
                    {
                        NSLog(@"%@ receive:<<%@",SonTestDevice,SonTestCommand);
                        break;
                    }
                    indexTime++;
                }
            }
            
        }
        
        //**************************波形发生器=WaveDevice
        else if ([SonTestDevice isEqualToString:@"WaveDevice"])
        {
            //获取频率
            NSString   * frequence =[self cutOutStringFromStr:SonTestCommand withDivisionString:@"_" andIndex:3];
            
            
            if ([SonTestCommand containsString:@"MODE_Sine"])
            {
                //                [self Fixture:fixtureSerial writeCommand:@"SEL.RLG=B2-E2"];
                //                sleep(0.1);
                [agilent33500B SetMessureMode:MODE_Sine andCommunicateType:Agilent33500B_USB_Type andFREQuency:frequence andVOLTage:param.waveVolt andOFFSet:param.waveOffset];
            }
            else if([SonTestCommand containsString:@"Mode_DC"])
            {
                
                [self Fixture:fixtureSerial writeCommand:@"SEL.RLG=B2-E2"];
                sleep(0.1);
                if (test_DC==0)
                {
                    [agilent33500B SetMessureMode:MODE_DC andCommunicateType:Agilent33500B_USB_Type andFREQuency:nil andVOLTage:@"0.001" andOFFSet:@"4.0"];
                    sleep(3);
                }
                
                [agilent33500B SetMessureMode:MODE_DC andCommunicateType:Agilent33500B_USB_Type andFREQuency:nil andVOLTage:@"0.001" andOFFSet:@"2.0"];
                test_DC++;
            }
            else if([SonTestCommand containsString:@"MODE_Square"])
            {
                [agilent33500B SetMessureMode:MODE_Square andCommunicateType:Agilent33500B_USB_Type andFREQuency:frequence andVOLTage:@"1.8" andOFFSet:@"0"];
                
            }
            else if([SonTestCommand containsString:@"MODE_Ramp"])
            {
                [agilent33500B SetMessureMode:MODE_Ramp andCommunicateType:Agilent33500B_USB_Type andFREQuency:frequence andVOLTage:param.waveVolt andOFFSet:param.waveOffset];
            }
            else if([SonTestCommand containsString:@"MODE_Pulse"])
            {
                [agilent33500B SetMessureMode:MODE_Pulse andCommunicateType:Agilent33500B_USB_Type andFREQuency:frequence andVOLTage:param.waveVolt andOFFSet:param.waveOffset];
                
            }
            else if([SonTestCommand containsString:@"MODE_Noise"])
            {
                
                [agilent33500B SetMessureMode:MODE_Noise andCommunicateType:Agilent33500B_USB_Type andFREQuency:frequence andVOLTage:param.waveVolt andOFFSet:param.waveOffset];
            }
            
            else//其它情况
            {
                NSLog(@"%@ other condition",SonTestDevice);
            }
            
            sleep(1);
            
        }
        
        //**************************万用表==Agilent或者Keithley
        else if ([SonTestDevice isEqualToString:@"Agilent"]||[SonTestDevice isEqualToString:@"Keithley"])
        {
            
            if (param.scheme_1)
            {
                if (!param.isDebug)
                {
                    [agilentE4980A Find:nil andCommunicateType:AgilentE4980A_USB_Type]&&[agilentE4980A OpenDevice:nil andCommunicateType:AgilentE4980A_USB_Type];
                }
                
                if (![SonTestName containsString:@"Read"])  //LCR表设置测试选项
                {
                    
                    if ([SonTestCommand isEqualToString:@"RES"])
                    {
                        
                        [agilentE4980A SetMessureMode:AgilentE4980A_RX andCommunicateType:AgilentE4980A_USB_Type];
                        [agilentE4980A setFrequency:testItem.freq];
                        
                    }
                    else if([SonTestCommand isEqualToString:@"CPD"])
                    {
                        [agilentE4980A SetMessureMode:AgilentE4980A_CPD andCommunicateType:AgilentE4980A_USB_Type];
                        [agilentE4980A setFrequency:testItem.freq];
                        
                    }
                    else if ([SonTestCommand isEqualToString:@"CPQ"])
                    {
                        [agilentE4980A SetMessureMode:AgilentE4980A_CPQ andCommunicateType:AgilentE4980A_USB_Type];
                        [agilentE4980A setFrequency:testItem.freq];
                        
                    }
                    else if ([SonTestCommand isEqualToString:@"CSD"])
                    {
                        [agilentE4980A SetMessureMode:AgilentE4980A_CSD andCommunicateType:AgilentE4980A_USB_Type];
                        [agilentE4980A setFrequency:testItem.freq];
                    }
                    else if ([SonTestCommand containsString:@"CSQ"])
                    {
                        
                        [agilentE4980A SetMessureMode:AgilentE4980A_CPQ andCommunicateType:AgilentE4980A_USB_Type];
                        [agilentE4980A setFrequency:testItem.freq];
                        
                    }
                    else if ([SonTestCommand isEqualToString:@"DCR"])
                    {
                        if (B2987_USB)
                        {
                            [agilentB2987A SetMessureMode:AgilentB2987A_RES andCommunicateType:AgilentB2987A_USB_Type];
                        }
                        else if (B2987_USB1)
                        {
                            [agilentB2987A SetMessureMode:AgilentB2987A_RES andCommunicateType:AgilentB2987A_USB_Type1];
                        }
                        else
                        {
                            [agilentB2987A SetMessureMode:AgilentB2987A_RES andCommunicateType:AgilentB2987A_USB_Type2];
                        }
                        
                        
                    }
                    else
                    {
                        NSLog(@"Please check the file Station.plist!");
                    }
                    
                }
                
                else    //读取测试结果
                {
                    if (![SonTestName containsString:@"DCR"])
                    {
                        [agilentE4980A WriteLine:@":FETC?" andCommunicateType:AgilentE4980A_USB_Type];
                        sleep(1);
                        agilentReadString=[agilentE4980A ReadData:16 andCommunicateType:AgilentE4980A_USB_Type];
                        [agilentE4980A CloseDevice];
                    }
                    else
                    {
                        if (nulltest)
                        {
                            if (B2987_USB)
                            {
                                [agilentB2987A WriteLine:@":MEAS:RES?" andCommunicateType:AgilentB2987A_USB_Type];
                            }
                            else if (B2987_USB1)
                            {
                                [agilentB2987A WriteLine:@":MEAS:RES?" andCommunicateType:AgilentB2987A_USB_Type1];
                            }
                            else
                            {
                                [agilentB2987A WriteLine:@":MEAS:RES?" andCommunicateType:AgilentB2987A_USB_Type2];
                            }
    
    
                            sleep(1);
    
                            if (B2987_USB)
                            {
                                agilentReadString=[agilentB2987A ReadData:16 andCommunicateType:AgilentB2987A_USB_Type];
                            }
                            else if (B2987_USB1)
                            {
                                agilentReadString=[agilentB2987A ReadData:16 andCommunicateType:AgilentB2987A_USB_Type1];
                            }
                            else
                            {
                                agilentReadString=[agilentB2987A ReadData:16 andCommunicateType:AgilentB2987A_USB_Type2];
                            }
    
    
                        [agilentB2987A WriteLine:@"*RST" andCommunicateType:AgilentB2987A_USB_Type];
                            
                        }
                        else
                        {
                            dcrAppending=[[NSMutableString alloc]init];
                            NSInteger i=1;
                            double Rdut;
                            double num1;
                            while (i>0)
                            {
                                
                                i--;
                                if (B2987_USB)
                                {
                                    
                                    [agilentB2987A WriteLine:@":MEAS:RES?" andCommunicateType:AgilentB2987A_USB_Type];
                                }
                                else if (B2987_USB1)
                                {
                                    
                                    [agilentB2987A WriteLine:@":MEAS:RES?" andCommunicateType:AgilentB2987A_USB_Type1];
                                }
                                else
                                {
                                    
                                    [agilentB2987A WriteLine:@":MEAS:RES?" andCommunicateType:AgilentB2987A_USB_Type2];
                                }
                                
                                
                                [NSThread sleepForTimeInterval:0.4];
                                
                                if (B2987_USB)
                                {
                                    
                                    agilentReadString=[agilentB2987A ReadData:16 andCommunicateType:AgilentB2987A_USB_Type];
                                    NSArray *arrResult=[agilentReadString componentsSeparatedByString:@","];
                                    num1 = [arrResult[0] floatValue];
                                    Rdut=(num1*1E-9*B4_E4_Ref.floatValue)/(B4_E4_Ref.floatValue-num1*1E-9);
                                    //                                NSLog(@"%.3f",Rdut);
                                    [dcrAppending appendString:[NSString stringWithFormat:@"%.3f,",num1*1E-9]];
                                }
                                else if (B2987_USB1)
                                {
                                    
                                    agilentReadString=[agilentB2987A ReadData:16 andCommunicateType:AgilentB2987A_USB_Type1];
                                    NSArray *arrResult=[agilentReadString componentsSeparatedByString:@","];
                                    num1 = [arrResult[0] floatValue];
                                    Rdut=(num1*1E-9*B4_E4_Ref.floatValue)/(B4_E4_Ref.floatValue-num1*1E-9);
                                    //                                NSLog(@"%.3f",Rdut);
                                    [dcrAppending appendString:[NSString stringWithFormat:@"%.3f,",num1*1E-9]];
                                    
                                }
                                else
                                {
                                    
                                    agilentReadString=[agilentB2987A ReadData:16 andCommunicateType:AgilentB2987A_USB_Type2];
                                    NSArray *arrResult=[agilentReadString componentsSeparatedByString:@","];
                                    num1 = [arrResult[0] floatValue];
                                    Rdut=(num1*1E-9*B4_E4_Ref.floatValue)/(B4_E4_Ref.floatValue-num1*1E-9);
                                    //                                NSLog(@"%.3f",Rdut);
                                    [dcrAppending appendString:[NSString stringWithFormat:@"%.3f,",num1*1E-9]];
                                    
                                }
                            }
                            
 
                            
                        }
                        
                       
                                           }
                    
                    NSArray *arrResult=[agilentReadString componentsSeparatedByString:@","];
                    
                    num = [arrResult[0] floatValue];
                }
                
            }
            else
            {
                
                //万用表发送指令
                if ([SonTestCommand isEqualToString:@"DC Volt"])
                {
                    //直流电压测试
                    [agilent34461A SetMessureMode:Agilent34461A_MODE_VOLT_DC andCommunicateType:Agilent34461A_MODE_USB_Type];
                    NSLog(@"Aglient34461A set VOLT_DC");
                    
                }
                else if([SonTestCommand isEqualToString:@"AC Volt"])
                {
                    [agilent34461A SetMessureMode:Agilent34461A_MODE_VOLT_AC andCommunicateType:Agilent34461A_MODE_USB_Type];
                    NSLog(@"Aglient34461A set AC_Volt");
                    
                }
                else if ([SonTestCommand isEqualToString:@"DC Current"])
                {
                    [agilent34461A SetMessureMode:Agilent34461A_MODE_CURR_DC andCommunicateType:Agilent34461A_MODE_USB_Type];
                    NSLog(@"Aglient34461A set DC_Current");
                    
                }
                else if ([SonTestCommand isEqualToString:@"AC Current"])
                {
                    [agilent34461A SetMessureMode:Agilent34461A_MODE_CURR_AC andCommunicateType:Agilent34461A_MODE_USB_Type];
                    
                    NSLog(@"Aglient34461A set AC_Current");
                }
                else if ([SonTestCommand containsString:@"RES"])//电阻分单位KΩ,MΩ,GΩ
                {
                    
                    [agilent34461A SetMessureMode:Agilent34461A_MODE_RES_4W andCommunicateType:Agilent34461A_MODE_USB_Type];
                    NSLog(@"Aglient34461A set RES");
                    
                }
                else//其它的值
                {
                    //5次电压递增测试
                    if ([testitem.testName containsString:@"_CURR"]) //设备
                    {
                        //  int indexTime=0;
                        
                        while (YES)
                        {
                            [agilent34461A WriteLine:@"READ?" andCommunicateType:Agilent34461A_MODE_USB_Type];
                            
                            sleep(0.5);
                            agilentReadString=[agilent34461A ReadData:16 andCommunicateType:Agilent34461A_MODE_USB_Type];
                            
                            //                            sleep(3);
                            if (param.isDebug)
                            {
                                //测试代码
                                agilentReadString = @"30.838383";
                            }
                            
                            //大于1，直接跳出，并发送reset指令
                            if (agilentReadString.length>0&&[agilentReadString floatValue]>=1)
                            {
                                [self Fixture:fixtureSerial writeCommand:@"reset"];
                                
                                break;
                            }
                        }
                        num = [agilentReadString floatValue];
                    }
                    
                    //其它正常读取情况
                    else
                    {
                        
                        [agilent34461A WriteLine:@"READ?" andCommunicateType:Agilent34461A_MODE_USB_Type];
                        
                        agilentReadString=[agilent34461A ReadData:16 andCommunicateType:Agilent34461A_MODE_USB_Type];
                        
                        if (param.isDebug)
                        {
                            //测试代码
                            agilentReadString = @"20.848484";
                        }
                    }
                    
                    num = [agilentReadString floatValue];
                }
                
            }
            
        }
        
        
        
        
        else if ([SonTestDevice isEqualToString:@"SW"]) //读取测试结果前的延时
        {
            if (!param.isDebug)
            {
                sleep(delayTime);
            }
        }
        
        //**************************获取温湿度的值
        else if ([SonTestDevice isEqualToString:@"TempHimu"])
        {
           
               [self Fixture:humitureSerial writeCommand:@"READ"];
            
                
                while (1)
                {
                    if (param.isDebug || didReceiveData) {
                        break;
                    }
                }
                didReceiveData=NO;
                humitString = [humitString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
                if ([humitString containsString:@","]&&[humitString containsString:@"%"])
                {
                    NSArray  * array =[humitString componentsSeparatedByString:@","];
                    
                    temp_Str   = [array objectAtIndex:0];
                    
                    humid_Str  = [[array objectAtIndex:1] stringByReplacingOccurrencesOfString:@"%" withString:@""];
                    
                }
                else
                {
                    temp_Str  = @"23.5";
                    
                    humid_Str = @"52.6";
                }
            
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [humit_TextF setStringValue:humitString.length?humitString:@"23.5,52.6"];
                });
            
            
        }
        else
        {
            NSLog(@"Please check the file Station.plist!");
        }
        
        [txtLogMutableArr addObject:[NSString stringWithFormat:@"%@ send command %@\n",SonTestDevice,SonTestCommand]];
    }
    
#pragma mark--------最终显示在 table 的测试项值
    
    //-------------------------------------------------------
    
    if([testItem.testName isEqualToString:@"FIXTURE ID"])//获取治具名称
    {
        
        // testitem.value=fixtureID.length>0?fixtureID:@"20170710174301.5001";
        
    }
    
    else if ([testItem.units isEqualToString:@"Ohm"])
    {
        testItem.value=[NSString stringWithFormat:@"%.2f",num];
        if (param.isDebug)
        {
            double i=arc4random()%10+100.000000;
            testItem.value=[NSString stringWithFormat:@"%.2f",i];
        }
    }
    else if ([testItem.units isEqualToString:@"GOhm"])
    {
        if (param.scheme_1)
        {
            double Rdut,Rfixture;
            NSString *largeRes=@">1TOhm";
            Rfixture=num*1E-9;
            Rdut=9999.00;
            if ([testitem.testName isEqualToString:@"B2_E2_DCR"])
            {
                if (!nulltest)
                {
                    Rfixture=B2_E2_Ref.floatValue;
                    Rdut=(num*1E-9*Rfixture)/(Rfixture-num*1E-9);
                    if (num*1E-9 >= Rfixture || Rdut > 1000 || num*1E-9 < 0)
                    {
                        [store_Dic setValue:[NSString stringWithFormat:@"%@",largeRes] forKey:@"B2_E2_DCR_Rdut"];
                    }
                    else
                    {
                        [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rdut] forKey:@"B2_E2_DCR_Rdut"];
                    }
                }
                else
                {
                    sum_fix_B2_E2_Res+=Rfixture;
                    if (nullTestCount==0)
                    {
                        max_fix_B2_E2_Res=Rfixture;
                        min_fix_B2_E2_Res=Rfixture;
                    }
                    if (max_fix_B2_E2_Res < Rfixture)
                    {
                        max_fix_B2_E2_Res=Rfixture;
                    }
                    if (min_fix_B2_E2_Res > Rfixture)
                    {
                        min_fix_B2_E2_Res=Rfixture;
                    }
                    [store_Dic setValue:[NSString stringWithFormat:@"%@",largeRes] forKey:@"B2_E2_DCR_Rdut"];
                }
                
                [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rfixture] forKey:@"B2_E2_DCR_Rfix"];
                
            }
            if ([testitem.testName isEqualToString:@"B4_E4_DCR"])
            {
                if (!nulltest)
                {
                    Rfixture=B4_E4_Ref.floatValue;
                    Rdut=(num*1E-9*Rfixture)/(Rfixture-num*1E-9);
                    if (num*1E-9 >= Rfixture || Rdut > 1000 || num*1E-9 < 0)
                    {
                        [store_Dic setValue:[NSString stringWithFormat:@"%@",largeRes] forKey:@"B4_E4_DCR_Rdut"];
                    }
                    else
                    {
                        [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rdut] forKey:@"B4_E4_DCR_Rdut"];
                    }
                }
                else
                {
                    sum_fix_B4_E4_Res+=Rfixture;
                    if (nullTestCount==0)
                    {
                        max_fix_B4_E4_Res=Rfixture;
                        min_fix_B4_E4_Res=Rfixture;
                    }
                    if (max_fix_B4_E4_Res < Rfixture)
                    {
                        max_fix_B4_E4_Res=Rfixture;
                    }
                    if (min_fix_B4_E4_Res > Rfixture)
                    {
                        min_fix_B4_E4_Res=Rfixture;
                    }
                    [store_Dic setValue:[NSString stringWithFormat:@"%@",largeRes] forKey:@"B4_E4_DCR_Rdut"];
                }
                
                [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rfixture] forKey:@"B4_E4_DCR_Rfix"];
            }
            
            
            if ([testitem.testName isEqualToString:@"B_E_DCR"])
            {
                if (!nulltest)
                {
                    Rfixture=B_E_Ref.floatValue;
                    Rdut=(num*1E-9*Rfixture)/(Rfixture-num*1E-9);
                    if (num*1E-9 >= Rfixture || Rdut > 1000 || num*1E-9 < 0)
                    {
                        [store_Dic setValue:[NSString stringWithFormat:@"%@",largeRes] forKey:@"B_E_DCR_Rdut"];
                    }
                    else
                    {
                        [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rdut] forKey:@"B_E_DCR_Rdut"];
                    }
                }
                else
                {
                    sum_fix_B_E_Res+=Rfixture;
                    if (nullTestCount==0)
                    {
                        max_fix_B_E_Res=Rfixture;
                        min_fix_B_E_Res=Rfixture;
                    }
                    if (max_fix_B_E_Res < Rfixture)
                    {
                        max_fix_B_E_Res=Rfixture;
                    }
                    if (min_fix_B_E_Res > Rfixture)
                    {
                        min_fix_B_E_Res=Rfixture;
                    }
                    [store_Dic setValue:[NSString stringWithFormat:@"%@",largeRes] forKey:@"B_E_DCR_Rdut"];
                }
                
                [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rfixture] forKey:@"B_E_DCR_Rfix"];
            }
            
            if ([testitem.testName isEqualToString:@"ABC_DEF_DCR"])
            {
                if (!nulltest)
                {
                    Rfixture=ABC_DEF_Ref.floatValue;
                    Rdut=(num*1E-9*Rfixture)/(Rfixture-num*1E-9);
                    if (num*1E-9 >= Rfixture || Rdut > 1000 || num*1E-9 < 0)
                    {
                        [store_Dic setValue:[NSString stringWithFormat:@"%@",largeRes] forKey:@"ABC_DEF_DCR_Rdut"];
                    }
                    else
                    {
                        [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rdut] forKey:@"ABC_DEF_DCR_Rdut"];
                    }
                }
                else
                {
                    sum_fix_ABC_DEF_Res+=Rfixture;
                    if (nullTestCount==0)
                    {
                        max_fix_ABC_DEF_Res=Rfixture;
                        min_fix_ABC_DEF_Res=Rfixture;
                    }
                    if (max_fix_ABC_DEF_Res < Rfixture)
                    {
                        max_fix_ABC_DEF_Res=Rfixture;
                    }
                    if (min_fix_ABC_DEF_Res > Rfixture)
                    {
                        min_fix_ABC_DEF_Res=Rfixture;
                    }
                    [store_Dic setValue:[NSString stringWithFormat:@"%@",largeRes] forKey:@"ABC_DEF_DCR_Rdut"];
                }
                
                [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rfixture] forKey:@"ABC_DEF_DCR_Rfix"];
            }
            
            
            testitem.value = [NSString stringWithFormat:@"%.3f",num*1E-9];
            
            
        }
    }
    
    
    else if ([testItem.units isEqualToString:@"MOhm"])
    {
        if (param.scheme_1)
        {
            double Cdut,Cfix,Rdut;
            NSString *smallCap=@"<1fF";
            NSString *largeACR=@">100GOhm";
            Cdut=0.0;
            Rdut=9999.00;
            if (nulltest)
            {
                Cfix=num*1E+12;
            }
            else
            {
                Cfix=_Cfix.floatValue;
            }
            if (!nulltest)
            {
                Cdut=num*1E+12-_Cfix.floatValue;
                Rdut=1E+6/(Cdut*2*3.14159*testitem.freq.integerValue);
            }
            
            testItem.value=[NSString stringWithFormat:@"%.3f",1E-6/(num*2*3.14159*testitem.freq.integerValue)];
            
            if ([testitem.testName isEqualToString:@"B2_E2_ACR_1000"])
            {
                
                if (Cdut <= 0)
                {
                    [store_Dic setValue:[NSString stringWithFormat:@"%@",smallCap] forKey:@"B2_E2_ACR_1000_Cdut"];
                    [store_Dic setValue:[NSString stringWithFormat:@"%@",largeACR] forKey:@"B2_E2_ACR_1000_Rdut"];
                }
                else
                {
                    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Cdut] forKey:@"B2_E2_ACR_1000_Cdut"];
                    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rdut] forKey:@"B2_E2_ACR_1000_Rdut"];
                }
                
                [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Cfix] forKey:@"B2_E2_ACR_1000_Cfix"];
            }
            
            if ([testitem.testName isEqualToString:@"B4_E4_ACR_1000"])
            {
                if (nulltest)
                {
                    sum_fix_Cap+=Cfix;
                    if (nullTestCount==0)
                    {
                        max_fix_Cap=Cfix;
                        min_fix_Cap=Cfix;
                    }
                    if (max_fix_Cap < Cfix)
                    {
                        max_fix_Cap=Cfix;
                    }
                    if (min_fix_Cap > Cfix)
                    {
                        min_fix_Cap=Cfix;
                    }
                }
                
                
                if (Cdut <= 0)
                {
                    [store_Dic setValue:[NSString stringWithFormat:@"%@",smallCap] forKey:@"B4_E4_ACR_1000_Cdut"];
                    [store_Dic setValue:[NSString stringWithFormat:@"%@",largeACR] forKey:@"B4_E4_ACR_1000_Rdut"];
                }
                else
                {
                    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Cdut] forKey:@"B4_E4_ACR_1000_Cdut"];
                    [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Rdut] forKey:@"B4_E4_ACR_1000_Rdut"];
                }
                
                [store_Dic setValue:[NSString stringWithFormat:@"%.3f",Cfix] forKey:@"B4_E4_ACR_1000_Cfix"];
            }
            
            
        }
    }
    
    if ([testitem.testName isEqualToString:@"TEMP"])
    {
        testitem.value = temp_Str;
    }
    
    if ([testitem.testName isEqualToString:@"HUMID"])
    {
        testitem.value = humid_Str;
    }
    
    
    if ([testitem.testName containsString:@"_Vmeas"] || [testitem.testName containsString:@"_Rref"] || [testitem.testName containsString:@"_Cfix"] || [testitem.testName containsString:@"_Vs"] || [testitem.testName containsString:@"_Cref"] || [testitem.testName containsString:@"_Rdut"] || [testitem.testName containsString:@"_Cdut"] || [testitem.testName containsString:@"_Rfix"])
    {
        testitem.value=[NSString stringWithFormat:@"%@",store_Dic[[NSString stringWithFormat:@"%@",testitem.testName]]];
        if ([testitem.testName containsString:@"_Cfix"])
        {
        }
        if ([testitem.testName containsString:@"_Rfix"])
        {
        }
    }
    
    
    
    //上下限值对比
    if (([testitem.value floatValue]>[testitem.min floatValue]&&[testitem.value floatValue]<=[testitem.max floatValue]) || ([testitem.max isEqualToString:@"--"]&&[testitem.value floatValue]>=[testitem.min floatValue]) || ([testitem.max isEqualToString:@"--"] && [testitem.min isEqualToString:@"--"]) || ([testitem.min isEqualToString:@"--"]&&[testitem.value floatValue]<=[testitem.max floatValue]) || [testitem.value isEqualToString:@">1TOhm"] || [testitem.value isEqualToString:@">100GOhm"] || [testitem.value isEqualToString:@"<1fF"])
    {
        testitem.result = @"PASS";
        testItem.messageError=nil;
        [passItemsArr addObject: @"PASS"];
        ispass = YES;
    }
    else
    {
        testitem.result = @"FAIL";
        testItem.messageError=[NSString stringWithFormat:@"%@Fail",testitem.testName];
        [failItemsArr addObject:@"FAIL"];
        ispass = NO;
    }
    
    
    if (all_Pass == YES)
    {
        testitem.result = @"PASS";
        testItem.messageError=nil;
        [passItemsArr addObject: @"PASS"];
        ispass = YES;
    }
    
    //txt log
    [txtLogMutableArr addObject:[NSString stringWithFormat:@"TestValue:%@\nTestResult:%@\nEndTimer:%@\n-------------------\n",testitem.value,testitem.result,[[GetTimeDay shareInstance] getCurrentTime]]];
    
    //每次的测试项与测试标题存入可变数组中
    if (testItem.value!=nil&&testItem.testName!=nil&&testItem.min!=nil&&testItem.max!=nil) {
        [testItemValueArr addObject:testItem.value];
        [testItemTitleArr addObject: testItem.testName];
        [testItemMinLimitArr  addObject:testItem.min];
        [testItesmMaxLimitArr addObject:testItem.max];
        [testItemUnitArr addObject: testItem.units];
        
        
    }
    else
    {
        [testItemValueArr addObject:@""];
        [testItemTitleArr addObject:@""];
        [testItemMinLimitArr  addObject:@""];
        [testItesmMaxLimitArr addObject:@""];
        [testItemUnitArr addObject:@""];
        
    }
    
    return ispass;
}



#pragma mark------------------串口代理方法
-(void)serialPort:(ORSSerialPort *)serialPort didReceiveData:(NSData *)data
{
    
    if (serialPort==fixtureSerial)
    {
        [appendStr appendString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        
        
        if ([appendStr containsString:@"OK"]||[appendStr containsString:@"\n"])
        {
            backStr =appendStr;
            appendStr=[[NSMutableString alloc]initWithString:@""];
            usleep(1000);
            didReceiveData=YES;
        }
    }
    
    if (serialPort==humitureSerial)
    {
       
        [humitAppendString appendString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        
        if ([humitAppendString containsString:@"%"]) {
            
            
            humitString=[humitAppendString copy];
            humitAppendString=[[NSMutableString alloc]initWithString:@""];
            
            usleep(1000);
            didReceiveData=YES;
        }
    }
    
}


-(unsigned long)returnNumwithString:(NSString *)hexstring andLocation:(int)index_num
{
    
    NSString  * string = [hexstring substringWithRange:NSMakeRange(index_num, 4)];
    
    unsigned long num_index = strtoul([string UTF8String], 0, 16);
    
    return num_index;
}


#pragma mark--------------------ORSSerialPort串口中发送指令
-(void)Fixture:(ORSSerialPort *)serialPort writeCommand:(NSString *)command
{
    NSString * commandString =[NSString stringWithFormat:@"%@\n",command];
    NSData    * data =[commandString dataUsingEncoding:NSUTF8StringEncoding];
    [serialPort sendData:data];
}

#pragma mark---------------------cutOutStringFromStr
-(NSString  *)cutOutStringFromStr:(NSString *)Str withDivisionString:(NSString *)diviString andIndex:(int)chooseIndex
{
    
    NSString   * numStr;
    NSArray    *   numArray =[Str componentsSeparatedByString:diviString];
    if ([numArray count] >= chooseIndex) {
        
        numStr =[numArray objectAtIndex:chooseIndex-1];
    }
    
    return numStr.length>0?numStr:@"0";
}


#pragma mark------同时激活PDCA 和 SFC,上传数据，并且不检测是否过站
-(void)Activate_PDCA_and_SFC_Notification:(NSNotification *)noti
{
    SFC_Btn.state= YES;
    SFC_Btn.enabled  = NO;
    
    PDCA_Btn.state = YES;
    PDCA_Btn.enabled = NO;

}

#pragma mark------同时激活PDCA 和 SFC,上传数据，并且检测是否过站
-(void)Activate_SFC_Notification:(NSNotification *)noti
{
    SFC_Btn.state= YES;
    SFC_Btn.enabled  = NO;
    
    PDCA_Btn.state = NO;
    PDCA_Btn.enabled = NO;
}

#pragma mark------激活PDCA和SFC,可以进行选择
-(void)Show_PDCA_and_SFC_Notification:(NSNotification *)noti
{
    SFC_Btn.enabled = YES;
    PDCA_Btn.enabled = YES;
    
}



-(void)SetNULLTEST_Notification:(NSNotification *)noti
{
    test_DOE.hidden=YES;
    
    if (index > 4 && index != 1000)
    {
        return;
    }
    nulltest=YES;
    test_type=3;
    if (param.scheme_1)
    {
        if ([product_Type.title isEqualToString:@"Cr"])
        {
          
            itemArr = [plist PlistRead:@"Station_Cr_3_Humid" Key:@"AllItems"];
            
        }
        else
        {
           
             itemArr = [plist PlistRead:@"Station_Ti_3_Humid" Key:@"AllItems"];
            
        }
        versionTF.stringValue=[NSString stringWithFormat:@"Version:%@",param.sw_ver_T2];
        
        
    }else
    {
        itemArr = [plist PlistRead:@"Station_3" Key:@"AllItems"];
        versionTF.stringValue=[NSString stringWithFormat:@"Version:%@",param.sw_ver_T1];
        
    }
    mk_table = [mk_table init:_tab_View DisplayData:itemArr];
    
    nullTestDone.hidden=!test_DOE.hidden;
    
    
}

//无限循环限制设定
-(void)SetUnLimit_Notification:(NSNotification *)noti
{
    stopBtn.hidden=NO;
    hiddenUnlimitTest.hidden=NO;
    unLimitTest=YES;
    looptestLabel.hidden=NO;
    looptestCount_TF.hidden=NO;
    once=1;
}

//获取按钮的状态
-(void)GetSFC_PDCAState
{
    dispatch_sync(dispatch_get_main_queue(),^{
        isUpLoadSFC=[SFC_Btn state]==1?YES:NO;
        isUpLoadPDCA=[PDCA_Btn state]==1?YES:NO;
    });
}

-(void)UpdateTextView:(NSString*)strMsg andClear:(BOOL)flagClearContent andTextView:(NSTextView *)textView
{
    if (flagClearContent)
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [textView setString:@""];
                       });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           if ([[textView string]length]>0)
                           {
                               [textView insertText:[NSString stringWithFormat:@"\n%@",strMsg]];;
                           }
                           else
                           {
                               [textView setString:[NSString stringWithFormat:@"\n\n%@",strMsg]];
                           }
                           
                           [textView setTextColor:[NSColor redColor]];
                       });
    }
}


#pragma mark--------------------清空数组
-(void)removeDataFromArray
{
    [dic_FixtureRefence removeAllObjects];
    [store_Dic removeAllObjects];
    [passItemsArr removeAllObjects];
    [failItemsArr removeAllObjects];
    [testItemTitleArr removeAllObjects];
    [testItemValueArr removeAllObjects];
    [testItemMinLimitArr removeAllObjects];
    [testItesmMaxLimitArr removeAllObjects];
    [testResultArr removeAllObjects];
    [testItemUnitArr removeAllObjects];
    
}

//==================== 冲定向log ============================
- (void)redirectNotificationHandle:(NSNotification *)nf{
    NSData *data = [[nf userInfo] objectForKey:NSFileHandleNotificationDataItem];
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if(logView_Info != nil)
    {
        NSRange range;
        range = NSMakeRange ([[logView_Info string] length], 0);
        [logView_Info replaceCharactersInRange: range withString: str];
        [logView_Info scrollRangeToVisible:range];
    }
    [[nf object] readInBackgroundAndNotify];
}

- (void)redirectSTD:(int )fd{
    
    NSPipe * pipe = [NSPipe pipe] ;
    NSFileHandle *pipeReadHandle = [pipe fileHandleForReading] ;
    dup2([[pipe fileHandleForWriting] fileDescriptor], fd) ;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(redirectNotificationHandle:)
                                                 name:NSFileHandleReadCompletionNotification
                                               object:pipeReadHandle] ;
    
    [pipeReadHandle readInBackgroundAndNotify];
}
//==================== 冲定向log ============================


-(void)uploadPDCA_Feicui_2
{
    /**
     * info :
     *  cfailItems     ----->    all the failItems
     *  param.sw_ver   ------>  we can get the param infomation form the (Param.plist) file, like this: param.sw_ver, param.isDebug...
     *  theSN   =   importSN.stringValue
     *  itemArr ---------> All test Items  , the way to get , itemArr = [plist PlistRead:@"Station_0" Key:@"AllItems"];
     *  testItem -------->  form Item class  ,  testItem = [itemArr objectAtIndex:i],we can get different testItem ; than we have all the item infomation like this : testItem.testName/ testItem.units / testItem.min / testItem.value /testItem.max / testItem.result
     *
     */
    
    NSError  * error;
    NSData  * data=[NSData dataWithContentsOfFile:@"/vault/data_collection/test_station_config/gh_station_info.json"];
    NSDictionary * jsonDic=[[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error] objectForKey:@"ghinfo"];
    NSString * ReStaName =[jsonDic objectForKey:@"STATION_TYPE"];
    
    
    
    NSMutableArray *cfailItems=[[NSMutableArray alloc] initWithArray:failItemsArr];
    NSString *theSN=[[NSString alloc] initWithString:importSN.stringValue];
    
    //------------------------------- nothing to change -------------------------------------------------
    
    IP_UUTHandle UID;
    Boolean APIcheck;
    IP_TestSpecHandle testSpec;
    
    IP_API_Reply reply = IP_UUTStart(&UID);
    
    if(!IP_success(reply))
    {
        
        [self showAlertMessage:[NSString stringWithCString:IP_reply_getError(reply) encoding:1]];
    }
    
    IP_reply_destroy(reply);
    
    handleReply(IP_addAttribute( UID, IP_ATTRIBUTE_STATIONSOFTWAREVERSION, [ [NSString stringWithFormat:@"%@",param.sw_ver] cStringUsingEncoding:1]  ));
    handleReply(IP_addAttribute( UID, IP_ATTRIBUTE_STATIONSOFTWARENAME, [ReStaName cStringUsingEncoding:1]  ));
    handleReply(IP_addAttribute( UID, IP_ATTRIBUTE_STATIONLIMITSVERSION, [[NSString stringWithFormat:@"%@",param.sw_ver] cStringUsingEncoding:1]));
    
    handleReply(IP_addAttribute( UID, IP_ATTRIBUTE_SERIALNUMBER, [theSN cStringUsingEncoding:1] ));
    
    //------------ 压缩并上传文件到服务器------------------------------
    NSString *raw_data_folder = [[NSUserDefaults standardUserDefaults] objectForKey:@"mainFolderPathKey"];
    NSTask *task;
    task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/sh"];
    
    NSString *cmd = [NSString stringWithFormat:@"cd %@; zip -r %@.zip %@",raw_data_folder,importSN.stringValue,importSN.stringValue];
    
    NSArray *argument = [NSArray arrayWithObjects:@"-c", [NSString stringWithFormat:@"%@", cmd], nil];
    [task setArguments: argument];
    
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    
    [task launch];
    
    NSString *ZIP_path = [NSString stringWithFormat:@"%@%@.zip",raw_data_folder,importSN.stringValue];
    NSLog(@"ZIP_FilePath == %@",ZIP_path);
    sleep(1);
    
    int FileCount = 0;
    
    while (true) {
        
        if([[NSFileManager defaultManager] fileExistsAtPath:ZIP_path]){
            
            NSLog(@"file has been existed");
            
            break;
        }
        else
        {
            NSLog(@"file has been not existed");
            FileCount++;
            
            sleep(0.5);
            if (FileCount>=3) {
                break;
            }
            
        }
        
    }
    
    IP_addBlob(UID, [[[NSString stringWithFormat:@"%@_%@",param.sw_name,param.sw_ver] stringByAppendingString:@"_ZIP_Log"] cStringUsingEncoding:1], [ZIP_path cStringUsingEncoding:1]);
    
    //==========================================================================================
    //----------------------- change the loop 2017.5.25 _MK ------------------------------------
    for(int i=0;i<[itemArr count];i++)
    {
        testItem = [itemArr objectAtIndex:i];
        //---------------------------------------
        NSString *testitemNameStr = testItem.testName;
        NSString *testitemMinStr = testItem.min;
        NSString *testitemMaxStr = testItem.max;
        NSString *testitemUnitStr = testItem.units;
        NSString *testitemValueStr = testItem.value;
        
        if ([testitemUnitStr isEqualToString:@"GΩ"])
        {
            testitemUnitStr = @"GOHM";
        }
        if ([testitemUnitStr isEqualToString:@"MΩ"])
        {
            testitemUnitStr = @"MOHM";
        }
        if ([testitemUnitStr isEqualToString:@"KΩ"])
        {
            testitemUnitStr = @"KOHM";
        }
        if ([testitemUnitStr isEqualToString:@"Ω"])
        {
            testitemUnitStr = @"OHM";
        }
        if ([testitemUnitStr isEqualToString:@"%"])
        {
            testitemUnitStr = @"PERCENT";
        }
        if ([testitemUnitStr isEqualToString:@"℃"])
        {
            testitemUnitStr = @"CELSIUS";
        }
        if ([testitemUnitStr isEqualToString:@"--"])
        {
            testitemUnitStr = @"N/A";
        }
        if(testitemMaxStr==nil || [testitemMaxStr isEqualToString:@"--"])
        {
            testitemMaxStr=@"N/A";
        }
        if(testitemMinStr==nil || [testitemMinStr isEqualToString:@"--"])
        {
            testitemMinStr=@"N/A";
        }
        if ([testitemValueStr isEqualToString:@">1TΩ"])
        {
            testitemValueStr=@"Large than 1TOHM";
        }
        if ([testitemValueStr isEqualToString:@">100GΩ"])
        {
            testitemValueStr=@"Large than 100GOHM";
        }
        if ([testitemValueStr isEqualToString:@"<1fF"])
        {
            testitemValueStr=@"Small than 1fF";
        }
        
        testitemNameStr = [testitemNameStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        testitemMinStr = [testitemMinStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        testitemMaxStr = [testitemMaxStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        testitemUnitStr = [testitemUnitStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        testitemValueStr=[testitemValueStr stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        //------------------------------------------
        
        testSpec=IP_testSpec_create();
        
        //--------------------- title---------------------------
        APIcheck=IP_testSpec_setTestName(testSpec, [testitemNameStr cStringUsingEncoding:1], [testitemNameStr length]);
        
        //----------------- limits ------------------------------
        APIcheck=IP_testSpec_setLimits(testSpec, [testitemMinStr cStringUsingEncoding:1], [testitemMinStr length], [testitemMaxStr cStringUsingEncoding:1], [testitemMaxStr length]);
        
        //----------------- unit ---------------------------
        APIcheck=IP_testSpec_setUnits(testSpec, [testitemUnitStr cStringUsingEncoding:1], [testitemUnitStr length]);
        
        //----------------- priority --------------------------------
        APIcheck=IP_testSpec_setPriority(testSpec, IP_PRIORITY_REALTIME);
        
        IP_TestResultHandle puddingResult=IP_testResult_create();
        
        if(NSOrderedSame==[testitemValueStr compare:@"Pass" options:NSCaseInsensitiveSearch] || NSOrderedSame==[testitemValueStr compare:@"Fail" options:NSCaseInsensitiveSearch])
        {
            testitemValueStr=@"";
        }
        
        const char *value=[testitemValueStr cStringUsingEncoding:1];
        
        int valueLength=(int)[testitemValueStr length];
        
        int result=IP_FAIL;
        
        if([testItem.result isEqualToString:@"PASS"])
        {
            result=IP_PASS;
        }
        
        if (stringisnumber(testitemValueStr))
        {
            APIcheck=IP_testResult_setValue(puddingResult, value,valueLength);
        }
        
        APIcheck=IP_testResult_setResult(puddingResult, result);
        
        if(!result)
        {
            NSString *failDes=@"";
            
            //==========errorcode@errormessage================
            if([testItem.result length]==0)
            {
                failDes=[failDes stringByAppendingString:@"N/A" ];
            }
            
            else
            {
                failDes=[failDes stringByAppendingString:testItem.messageError];
            }
            
            failDes=[failDes stringByAppendingString:@","];
            
            APIcheck=IP_testResult_setMessage(puddingResult, [failDes cStringUsingEncoding:1], [failDes length]);
        }
        
        reply=IP_addResult(UID, testSpec, puddingResult);
        
        if(!IP_success(reply))
        {
            
            [self showAlertMessage:[NSString stringWithCString:IP_reply_getError(reply) encoding:1]];
        }
        
        IP_reply_destroy(reply);
        
        IP_testResult_destroy(puddingResult);
        
        IP_testSpec_destroy(testSpec);
    }
    
    //------------------------ nothing change --------------------------------------
    IP_API_Reply doneReply=IP_UUTDone(UID);
    if(!IP_success(doneReply)){
        [self showAlertMessage:[NSString stringWithCString:IP_reply_getError(doneReply) encoding:1]];
        
        //        exit(-1);
        IP_API_Reply amiReply = IP_amIOkay(UID, [importSN.stringValue cStringUsingEncoding:1]);
        if (!IP_success(amiReply))
        {
            IP_reply_destroy(amiReply);
        }
    }
    
    IP_reply_destroy(doneReply);
    
    IP_API_Reply commitReply;
    
    if([cfailItems count]>0)
    {
        commitReply=IP_UUTCommit(UID, IP_FAIL);
    }
    else
    {
        commitReply=IP_UUTCommit(UID, IP_PASS);
    }
    
    if(!IP_success(commitReply)){}
    IP_reply_destroy(commitReply);
    IP_UID_destroy(UID);
}


#pragma mark-------提示框的内容
-(void)showAlertMessage:(NSString *)showMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        NSAlert * alert1 = [NSAlert new];
        alert1.messageText = @"Comfirm";
        alert1.informativeText = showMessage;
        [alert1 addButtonWithTitle:@"YES"];
        //第一种方式，以modal的方式出现
        [alert1 runModal];
    });
    
}

void handleReply( IP_API_Reply reply )
{
    if ( !IP_success( reply ) )
    {
        NSRunAlertPanel(@"Confirm",@"Upload PDCA data error", @"YES", nil,nil);
        NSLog(@"Upload PDCA data error");
        //exit(-1);
    }
    IP_reply_destroy(reply);
}


BOOL stringisnumber(NSString *stringvalues)
{
    
    NSMutableArray *arrM=[[NSMutableArray alloc]init];
    NSString *temp;
    NSInteger p=0;
    NSInteger g=0;
    if ([stringvalues length])
    {
        for(int i=0;i<[stringvalues length];i++)
        {
            temp=[[stringvalues substringFromIndex:i] substringToIndex:1];
            [arrM addObject:temp];
            if (![@"-1234567890." rangeOfString:temp].length)
            {
                return FALSE;
            }
        }
        for (NSString *str in arrM)
        {
            if ([str containsString:@"."])
            {
                p++;
            }
            if ([str containsString:@"-"]) {
                g++;
            }
        }
        if (g>1 || p>1)
        {
            return FALSE;
        }
    }
    else
    {
        return FALSE;
    }
    return TRUE;
}


-(void)viewWillDisappear
{
    //=================
    [myThrad cancel];
    myThrad = nil;
    
    //主动释放掉
    [self closeAllDevice];
    sleep(1);
    exit(0);
}

-(void)viewDidDisappear
{
    exit(0);
}

#pragma mark--------释放所有设备
-(void)closeAllDevice
{
    //主动释放掉
    [fixtureSerial close];
    [agilentB2987A CloseDevice];
    [agilentE4980A CloseDevice];
    
    
}

@end

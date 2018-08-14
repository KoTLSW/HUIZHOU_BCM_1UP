//
//  Param.h
//  BT_MIC_SPK
//
//  Created by h on 16/5/29.
//  Copyright © 2016年 h. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Param : NSObject
//=============================================
@property(readwrite,copy)NSString*   csv_path;
@property(readwrite,copy)NSString*   dut_type;
@property(readwrite,copy)NSString*   ui_title;
@property(readwrite,copy)NSString*   tester_version;

@property(readwrite,copy)NSString*   station;
@property(readwrite,copy)NSString*   stationID;
@property(readwrite,copy)NSString*   fixtureID;
@property(readwrite,copy)NSString*   lineNo;

@property(readwrite,copy)NSString*  sw_name;
@property(readwrite,copy)NSString*  sw_ver_T1;
@property(readwrite,copy)NSString*  sw_ver_T2;
@property(readwrite,copy)NSString*  sw_ver;
@property(readwrite,copy)NSString*  DCR_Vs;
@property(readwrite,copy)NSString*  DCRes;
@property(readwrite,copy)NSString*  ACRes;

@property(readwrite,copy)NSString*  test_type;
@property(readwrite,copy)NSString*  fix_Cap;
@property(readwrite,copy)NSString*  fix_B2_E2_Res;
@property(readwrite,copy)NSString*  fix_B_E_Res;
@property(readwrite,copy)NSString*  fix_B4_E4_Res;
@property(readwrite,copy)NSString*  fix_ABC_DEF_Res;




//治具相关
@property(readwrite,copy)NSString*  fixture_uart_port_name;
@property(readwrite)NSInteger       fixture_uart_baud;

@property(readwrite,copy)NSString*  pcb_uart_port_name;
@property(readwrite)NSInteger       pcb_uart_baud;

//温湿度传感器相关
@property(readwrite,copy)NSString*  humiture_uart_port_name;
@property(readwrite)NSInteger       humiture_uart_baud;


//文件路径
@property(nonatomic,strong)NSString * file_path;

//是否需要波形发生器
@property(nonatomic,assign)BOOL isWaveNeed;
@property(nonatomic,assign)BOOL isDebug;
@property(nonatomic,assign)BOOL scheme_1;
@property(nonatomic,assign)BOOL nullTest;
@property(nonatomic,strong)NSString * PCB_id;

@property(nonatomic,strong)NSString * Cfix;
@property(nonatomic,strong)NSString * Rfix;

@property(nonatomic,strong)NSString * waveFrequence;//频率
@property(nonatomic,strong)NSString * waveVolt;//电压
@property(nonatomic,strong)NSString * waveOffset;//偏

//万用表的类型===============34461A/3458A
@property(nonatomic,strong)NSString * multimeter;





//sbuid
@property(nonatomic,strong)NSString * s_build;

//特殊规则SN
@property(nonatomic,strong)NSArray  * differentSNArray;
@property(nonatomic,strong)NSDictionary  * Fixture_Refence;
@property(nonatomic,strong)NSDictionary  * Fixture_Refence2;


@property(readwrite,copy)NSString*  pcb_spi_port_name;
@property(readwrite)NSInteger       pcb_spi_baud;

@property(readwrite,copy)NSString*  fixture_id;

@property(readwrite)NSInteger       thdn;

@property(readwrite)NSInteger       spkvol;
@property(readwrite)NSInteger       spkscale;

@property(readwrite)NSInteger       out_rate;
@property(readwrite)NSInteger       in_rate;

@property(readwrite,copy)NSString*  micl_calibration_time;
@property(readwrite)CGFloat         micl_calibration_db;
@property(readwrite)CGFloat         micl_calibration_v_pa;

@property(readwrite,copy)NSString*  micr_calibration_time;
@property(readwrite)CGFloat         micr_calibration_db;
@property(readwrite)CGFloat         micr_calibration_v_pa;

@property(readwrite,copy)NSString*  mics_calibration_time;
@property(readwrite)CGFloat         mics_calibration_db;
@property(readwrite)CGFloat         mics_calibration_v_pa;

@property(readwrite,copy)NSString*  spk_calibration_time;
@property(readwrite)CGFloat         spk_calibration_db1;
@property(readwrite)CGFloat         spk_calibration_db1_v;
@property(readwrite)CGFloat         spk_calibration_db2;
@property(readwrite)CGFloat         spk_calibration_db2_v;

@property(readwrite)BOOL            pdca_is_upload;
//=============================================
- (void)ParamRead:(NSString*)filename;
- (void)ParamWrite:(NSString*)filename;
-(void)ParamWrite:(NSString *)filename Content:(NSString *)content Key:(NSString *)key;
//- (void)TmConfigWrite:(NSString *)filename Content:(NSString *)content Key:(NSString *)key;
//=============================================
@end

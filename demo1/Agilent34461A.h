//
//  Agilent34410A.h
//  X322MotorTest
//
//  Created by CW-IT-MINI-001 on 14-1-11.
//  Copyright (c) 2014年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiperTimer.h"
#import "visa.h"

enum Agilent34461AMessureMode
{
    Agilent34461A_MODE_RES_4W,     //4线电阻模式
    Agilent34461A_MODE_RES_2W,     //2线电阻模式
    Agilent34461A_MODE_DIODE,      //二极管测试
    Agilent34461A_MODE_CURR_DC,    //直流电流
    Agilent34461A_MODE_CURR_AC,    //交流电流
    Agilent34461A_MODE_VOLT_DC,    //直流电压
    Agilent34461A_MODE_VOLT_AC,    //交流电压
    Agilent34461A_MODE_TEMP_4W,    //温度 四线
    Agilent34461A_MODE_TEMP_2W,    //温度 二线
    Agilent34461A_MODE_CAP,        //电容
    Agilent34461A_MODE_DEFAULT=Agilent34461A_MODE_VOLT_DC,
};

enum Agilent34461ACommunicateType
{
    Agilent34461A_MODE_USB_Type,  //USB通信
    Agilent34461A_MODE_LAN_Type,  //网口通信
    Agilent34461A_MODE_UART_Type, //串口通信
    Agilent34461A_MODE_GPIB_Type,//GPIB通信
};




@interface Agilent34461A : NSObject
{
    char instrDescriptor[VI_FIND_BUFLEN];
    
    //2015.1.19
    BOOL _isOpen;
    
    ViUInt32 numInstrs;
    ViFindList findList;
    ViSession defaultRM, instr;
    ViStatus status;
    ViUInt32 retCount;
    ViUInt32 writeCount;
    NSString * str;
    NSString* _agilentSerial;
}


@property(readwrite) BOOL isOpen;
@property(readwrite,copy)NSString* agilentSerial;

-(BOOL) Find:(NSString *)serial andCommunicateType:(enum Agilent34461ACommunicateType)communicateType;
-(BOOL) OpenDevice:(NSString *)serial andCommunicateType:(enum Agilent34461ACommunicateType)communicateType;
-(void) CloseDevice;


-(enum Agilent34461AMessureMode)getMessureMode:(NSString*)strUnit;
//
-(void)SetMessureMode:(enum Agilent34461AMessureMode)mode andCommunicateType:(enum Agilent34461ACommunicateType)communicateType;


-(NSString*)readValueBaseModeWithinCount:(NSString*)agilentSerial
                                 andMode:(enum Agilent34461AMessureMode)mode
                    andCommunicateType:(enum Agilent34461ACommunicateType)communicateType
                                  andCmd:(NSString*)strCmd
                            andReadCount:(int)readCount;


-(NSString*)readValueBaseModeWithinTime:(enum Agilent34461AMessureMode)mode
                                 andCommunicateType:(enum Agilent34461ACommunicateType)communicateType
                                 andCmd:(NSString*)strCmd
                            andReadTime:(int)time;

-(BOOL) WriteLine:(NSString*) data andCommunicateType:(enum Agilent34461ACommunicateType)communicateType;

-(NSString*)ReadData:(int)readDataCount andCommunicateType:(enum Agilent34461ACommunicateType)communicateType;

+(NSArray *)getArratWithCommunicateType:(enum Agilent34461ACommunicateType)communicateType;


@end

//
//  Agilent33500B.h
//  33500B_Test
//
//  Created by mac on 21/09/2017.
//  Copyright © 2017 mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiperTimer.h"
#import "visa.h"

enum Agilent33500BMeasureMode
{
    MODE_Sine,
    MODE_Square,
    MODE_Ramp,
    MODE_Pulse,
    MODE_Noise,
    MODE_DC,
    
};

enum Agilent33500BCommunicateType
{
    Agilent33500B_USB_Type,
    Agilent33500B_LAN_Type,
    Agilent33500B_UART_Type,
};


@interface Agilent33500B : NSObject
{
    
    char instrDescriptor[VI_FIND_BUFLEN];
    
    BOOL _isOpen;
    ViUInt32 numInstrs;
    ViFindList findList;
    
    ViSession defaultRM, instr;
    ViStatus status;
    ViUInt32 retCount;
    ViUInt32 writeCount;
    NSString* str;
    NSString* _agilentSerial;
    
    
}

@property(readwrite) BOOL isOpen_33500B;
@property(readwrite, copy) NSString* agilentSerial_33500B;



///

-(BOOL) Find:(NSString*)serial andCommunicateType:(enum Agilent33500BCommunicateType)communicateType;
-(BOOL) OpenDevice:(NSString *)serial andCommunicateType:(enum Agilent33500BCommunicateType)communicateType;


/**
 *  波形发生器
 *
 *  @param mode            波形类型
 *  @param communicateType 通信类型
 *  @param FREQuency       频率
 *  @param VOLTage         电压
 *  @param OFFSet          偏移    ==0.4
 */
-(void)SetMessureMode:(enum Agilent33500BMeasureMode)mode andCommunicateType:(enum Agilent33500BCommunicateType)communicateType andFREQuency:(NSString*)FREQuency andVOLTage:(NSString*)VOLTage andOFFSet:(NSString*)OFFSet;

-(void)CloseDevice;



-(BOOL) WriteLine:(NSString*) data andCommunicateType:(enum Agilent33500BCommunicateType)communicateType;
-(NSString*)ReadData:(int)readDataCount andCommunicateType:(enum Agilent33500BCommunicateType)communicateType;

@end

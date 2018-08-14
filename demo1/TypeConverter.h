//
//  TypeConverter.h
//  X322MotorTest
//
//  Created by CW-IT-MINI-001 on 13-12-6.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#ifndef TYPE_CONVERTER_H_H
#define TYPE_CONVERTER_H_H



#import <Foundation/Foundation.h>
#import "string.h"
#import "stdio.h"

@interface TypeConverter : NSObject

 //定义静态实例
+(TypeConverter*)Instance;


/**
 *  将十进制装换成任意2~16进制
 *
 *  @param number 传入的数值
 *  @param digits 转化任意的进制
 *
 *  @return 转换完之后的字符串
 */
-(NSString*)ToAny:(int)number andDigits:(int)digits;

//十六进制向十进制转换
-(int)HexStrToInt:(NSString*)str;


//八进制向十进制转换
-(int)OctalStrToInt:(NSString*)octalStr;

//二进制向十进制转换
-(int)BinaryStrToInt:(NSString*)binaryStr;

//convert hex string to double
-(double)HexStrToDou:(NSString*)hexStr;

//将字符转换成AScall码形式
-(NSString*)CharToHexStr:(unsigned char*)chr Length:(int)length;

- (double) strToDouble:(NSString *)numStr isNumber:(BOOL *)isNumber;





/**
 *  十六进制字符串改为NSData类型数据
 *
 *  @param str 十六进制字符串
 *
 *  @return 返回NSData类型
 */
- (NSMutableData *)convertHexStrToData:(NSString *)str;



/**
 *  将NSData类型转化为16进制字符串
 *
 *  @param data 传入的NSData参数
 *
 *  @return 返回字符串
 */
- (NSString *)convertDataToHexStr:(NSData *)data;
    

/**
 *  十六进制的字符串转化为普通的字符串
 *
 *  @param hexString 十六进制的字符串
 *
 *  @return 返回字符串
 */
+(NSString *)stringFromHexString:(NSString *)hexString;



/**
 *  返回CRC-16校验的值
 *
 *  @param data 传入的字符串
 *
 *  @return 返回校验后的值
 */
-(NSData *)getCrcVerifyCode:(NSData *)data;


@end

#endif

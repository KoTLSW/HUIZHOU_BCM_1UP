//
//  TypeConverter.m
//  X322MotorTest
//
//  Created by CW-IT-MINI-001 on 13-12-6.
//  Copyright (c) 2013年 __MyCompanyName__. All rights reserved.
//

#import "TypeConverter.h"

static TypeConverter* typeConvert=nil;

@implementation TypeConverter

//创建静态实例，也即是单例模式
+(TypeConverter*)Instance
{
    if(typeConvert==nil)
    {
        typeConvert=[[TypeConverter alloc] init];
    }
    
    return typeConvert;
}

//字符转换成字符串
-(NSString*)CharToHexStr:(unsigned char*)chr Length:(int)length
{	
	NSMutableString* str = [NSMutableString stringWithCapacity:2];
	
	for (int i = 0; i < length; i++)
	{
		NSString* strSingle = [NSString stringWithFormat:@"%x ", chr[i]];
		
		if ([strSingle length] < 3)
		{
			[str appendString:[NSString stringWithFormat:@"0%@", strSingle]];
		}
		else
		{
			[str appendString:strSingle];
		}
	}
	
	return str;
}

//十进制向任意进制转换
-(NSString*)ToAny:(int)number andDigits:(int)digits
{
    if(digits>16 || digits<2)
    {
        return @"";
    }
    
    NSMutableString* strTemp=[[NSMutableString alloc] initWithString:@""];
    NSMutableString* strResult=[[NSMutableString alloc] initWithString:@""];
    
    while (number)
    {
        switch (number%digits)
        {
            case 15:[strTemp appendString:@"F"];
                break;
            case 14:[strTemp appendString:@"E"];
                break;
            case 13:[strTemp appendString:@"D"];
                break;
            case 12:[strTemp appendString:@"C"];
                break;
            case 11:[strTemp appendString:@"B"];
                break;
            case 10:[strTemp appendString:@"A"];
                break;
            default:[strTemp appendString:[NSString stringWithFormat:@"%d",number%digits]];
                break;
        }
        
        number=number/digits;
    }
    
    for (int i=(int)[strTemp length]; i>0; i--)
    {
        [strResult appendString:[[strTemp substringFromIndex:i-1] substringToIndex:1]];
    }
    
    return strResult;
}


//convert hex string to int
-(int)HexStrToInt:(NSString*)hexStr
{
    int result = 0;
    NSString* str = [[hexStr uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    for (int i = 0; i < [str length]; i++)
    {
        int charValue = [str characterAtIndex:i];
        
        if ((charValue >= '0') && (charValue <= '9'))
        {
            result += (charValue - '0') * pow(16, ([str length] - 1 -i));
        }
        else if ((charValue >= 'A') && (charValue <= 'F'))
        {
            result += (charValue - 'A' + 10) * pow(16, ([str length] - 1 -i));
        }
    }
    
    return result;
}

//八进制转换成十进制
-(int)OctalStrToInt:(NSString*)octalStr
{
    int result = 0;
    
    NSString* str = [[octalStr uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    for (int i = 0; i < [str length]; i++)
    {
        int charValue = [str characterAtIndex:i];
        
        if ((charValue >= '0') && (charValue <= '9'))
        {
            result += (charValue - '0') * pow(8, ([str length] - 1 -i));
        }
        else if ((charValue >= 'A') && (charValue <= 'F'))
        {
            result += (charValue - 'A' + 10) * pow(8, ([str length] - 1 -i));
        }
    }
    
    return result;
}

//二进制向十进制转换
-(int)BinaryStrToInt:(NSString*)binaryStr
{
    int result = 0;
    
    NSString* str = [[binaryStr uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    for (int i = 0; i < [str length]; i++)
    {
        int charValue = [str characterAtIndex:i];
        
        if ((charValue >= '0') && (charValue <= '9'))
        {
            result += (charValue - '0') * pow(2, ([str length] - 1 -i));
        }
        else if ((charValue >= 'A') && (charValue <= 'F'))
        {
            result += (charValue - 'A' + 10) * pow(2, ([str length] - 1 -i));
        }
    }
    
    return result;
}


//convert hex string to double
-(double)HexStrToDou:(NSString*)hexStr
{
    double result = 0;
    
    NSString* str = [[hexStr uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    for (int i = 0; i < [str length]; i++)
    {
        int charValue = [str characterAtIndex:i];
        
        if ((charValue >= '0') && (charValue <= '9'))
        {
            result += (charValue - '0') * pow(16, ([str length] - 1 -i));
        }
        else if ((charValue >= 'A') && (charValue <= 'F'))
        {
            result += (charValue - 'A' + 10) * pow(16, ([str length] - 1 -i));
        }
    }
    
    return result;
}


- (double) strToDouble:(NSString *)numStr isNumber:(BOOL *)isNumber
{
    int index = 0;
    int dotCount = 0;           // 统计点的个数
    double result = 0;          // 转换的结果
    BOOL bHexNumber = NO;
    NSString* lowercaseStr = [numStr lowercaseString];
    
    if ([lowercaseStr rangeOfString:@"0x"].length > 0) {    // 是否为十六进制字符串
        index = 2;
        bHexNumber = YES;
    }
    
    NSUInteger dotLocation = [lowercaseStr length];         // 记录小数点的位置
    NSRange range = [lowercaseStr rangeOfString:@"."];
    
    if (range.length > 0) {             // 是否有小数点
        dotLocation = range.location;
    }
    
    *isNumber = YES;
    
    for (int i = index; i < [lowercaseStr length]; i++) {
        char charValue = [lowercaseStr characterAtIndex:i];
        
        if (bHexNumber) {
            if ((charValue >= '0') && (charValue <= '9')) {
                result += (charValue - '0') * pow(16, ([lowercaseStr length] - 1 - i));
            }
            else if ((charValue >= 'a') && (charValue <= 'f')) {
                result += (charValue - 'a' + 10) * pow(16, ([lowercaseStr length] - 1 - i));
            }
            else {  // 存在非数字字符和非a ~ f字符时，转换不成功
                bHexNumber = NO;
                *isNumber = NO;
                result = 0;
                break;
            }
        }
        else {
            if ((charValue >= '0') && (charValue <= '9')) {
                if (dotCount == 0) {
                    result += (charValue - '0') * pow(10, dotLocation - i - 1);
                }
                else {
                    result += (charValue - '0') * pow(10, ((double)i - [lowercaseStr length]));
                }
            }
            else if (charValue == '.') {    // 点字符数量记录
                dotCount++;
                
                if (dotCount >= 2) {        // 点字符大于一个时，转换不成功
                    *isNumber = NO;
                    result = 0;
                    break;
                }
            }
            else {  // 存在非数字字符时，转换不成功
                *isNumber = NO;
                result = 0;
                break;
            }
        }
    }
    
    return result;
}



- (NSMutableData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] %2 == 0) {
        range = NSMakeRange(0,2);
    } else {
        range = NSMakeRange(0,1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    
    return hexData;
}




- (NSString *)convertDataToHexStr:(NSData *)data {
    if (!data || [data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    
    return string;
}




//将16进制字符串转化为普通字符串
+(NSString *)stringFromHexString:(NSString *)hexString { //
    
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    NSLog(@"------字符串=======%@",unicodeString);
    return unicodeString;
    
    
}


//CRC-16位数据校验========低位还是高位放前，实现方法中可以调试
-(NSData *)getCrcVerifyCode:(NSData *)data
{
    int  crcWord = 0x0000ffff;
    Byte * dataArray = (Byte *)[data bytes];
    
    for (int i=0; i<data.length; i++)
    {
        
        Byte  byte = dataArray[i];
        crcWord ^=(int)byte & 0x000000ff;
        for (int j=0; j<8; j++) {
            if ((crcWord & 0x00000001)==1) {
                crcWord = crcWord >>1 ;
                crcWord = crcWord ^0x0000A001;
            }
            else
            {
                crcWord = (crcWord >> 1);
            }
        }
        
    }
    
    
    Byte  crcH = (Byte)0xff&(crcWord>>8);
    Byte  crcL = (Byte)0xff&crcWord;
    //Byte  arraycrc[]={crcH,crcL};
    Byte  arraycrc[]={crcL,crcH};
    NSData  * datacrc = [[NSData alloc]initWithBytes:arraycrc length:sizeof(arraycrc)];
    return datacrc;
}





@end

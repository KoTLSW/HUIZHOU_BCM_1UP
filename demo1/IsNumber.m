//
//  IsNumber.m
//  demo1
//
//  Created by mac on 2017/9/7.
//  Copyright © 2017年 maceastwin. All rights reserved.
//

#import "IsNumber.h"

@implementation IsNumber

-(BOOL)stringisnumber:(NSString *)stringvalues
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
            //            NSLog(@"temp=%@",temp);
            [arrM addObject:temp];
            if (![@"-1234567890." rangeOfString:temp].length)
            {
                //                NSLog(@"-----%ld",[@"-1234567890." rangeOfString:temp].length);
                return FALSE;
            }
            //            NSLog(@"-----%ld",[@"-1234567890." rangeOfString:temp].length);
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

@end

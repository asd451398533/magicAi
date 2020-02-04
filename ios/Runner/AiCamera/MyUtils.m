//
//  MyUtils.m
//  Runner
//
//  Created by Apple on 2019/7/31.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyUtils.h"
@implementation MyUtils
    
    + (BOOL) isNullObject:(id)object{
        if (object == nil || [object isEqual:[NSNull class]]) {
            return YES;
        }else if ([object isKindOfClass:[NSNull class]]){
            if ([object isEqualToString:@""]) {
                return YES;
            }else{
                return NO;
            }
        }else if ([object isKindOfClass:[NSNumber class]]){
            if ([object isEqualToNumber:@0]) {
                return YES;
            }else {
                return NO;
            }
        }
        return NO;
    }
    
    + (NSString *)getNowTimeTimestamp3{
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SSS"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
            NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
            [formatter setTimeZone:timeZone];
    
            NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
            NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]*1000];
    
            return timeSp;
    }
    
    + (NSDate *)getLocateTime:(unsigned int)timeStamp {
        double dTimeStamp = (double)timeStamp;
        NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:dTimeStamp];
        return confromTimesp;
    }

@end

//
//  MyUtils.h
//  Runner
//
//  Created by Apple on 2019/7/31.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#ifndef MyUtils_h
#define MyUtils_h


#endif /* MyUtils_h */


#import <UIKit/UIKit.h>


@interface MyUtils : NSObject
    + (BOOL) isNullObject:(id)object;
    + (NSString *)getNowTimeTimestamp3;
    + (NSDate *)getLocateTime:(unsigned int)timeStamp;
@end

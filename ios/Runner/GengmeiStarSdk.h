//
//  GemgmeiStarSdk.h
//  Runner
//
//  Created by Apple on 2019/8/15.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#ifndef GemgmeiStarSdk_h
#define GemgmeiStarSdk_h


#endif /* GemgmeiStarSdk_h */
#import <UIKit/UIKit.h>
@interface GengmeiStarSdk : NSObject
+ (instancetype _Nullable )sharedSingleton;
-(void) execRectVideo:(NSString *)imageUrl videoPath:(NSString*)videoPath stepCount:(int)stepCount handler:(void(^)(NSString*_Nullable response,NSError *_Nullable error))handler;
-(void) execLongVideo:(UIImage*)background videoPath:(NSString*)videoPath handler:(void(^)(NSString* _Nullable respone , NSError*_Nullable))handler;
-(UIImage*)getSharePic;
-(void)quitStarTask;
@end

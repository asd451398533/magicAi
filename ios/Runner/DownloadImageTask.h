//
//  DownloadImageTask.h
//  Runner
//
//  Created by Apple on 2019/8/13.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#ifndef DownloadImageTask_h
#define DownloadImageTask_h


#endif /* DownloadImageTask_h */
#import <UIKit/UIKit.h>
#import "GengmeiStarItem.h"
@interface DownloadImageTask : NSObject
-(void) download:(NSMutableArray *)arr
                 handler:(void(^)(NSMutableArray<GengmeiStarItem *> *_Nullable resultArr,NSError *_Nullable error))handlerr;
-(void) drawPic:(NSMutableArray *) arr:(UIImage*)background:(NSString*)name:(NSString*)value:(NSString*)str1:(NSString*)str2 handler:(void(^)(NSMutableArray<UIImage*> *_Nullable resultArr,NSError *_Nullable error))handlerr;
- (UIImage *)createShareImage:(UIImage *)tImage :(NSString *)starName :(NSString*)value :(NSString*)des1 :(NSString*)des2;
- (UIImage *)createShareImage:(UIImage *)tImage Context:(NSString *)text;
- (UIImage *)createShareImage:(UIImage *)tImage ContextImage:(UIImage *)image2;
@end

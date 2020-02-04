//
//  NSObject+FaceDetectSdk.m
//  Runner
//
//  Created by Apple on 2019/8/28.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import "FaceDetectSdk.h"

#include "ldmarkmodel.h"
#include "opencv+parallel_for_.h"

#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgproc/imgproc_c.h>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/opencv.hpp>

@interface FaceDetectSdk ()
@property(nonatomic)ldmarkmodel* _modelt;
@property(nonatomic)std::vector<cv::Mat>* _currentShape;
@end

@implementation FaceDetectSdk
{
    
}

+ (instancetype)sharedSingleton {
    static FaceDetectSdk *_sharedSingleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSingleton = [[super allocWithZone:NULL] init];
    });
    return _sharedSingleton;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [FaceDetectSdk sharedSingleton];
}
- (id)copyWithZone:(nullable NSZone *)zone {
    return [FaceDetectSdk sharedSingleton];
}
- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [FaceDetectSdk sharedSingleton];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString* haarPath = [NSBundle.mainBundle pathForResource:@"haar_facedetection" ofType:@"xml"];
        NSString* modelPath = [NSBundle.mainBundle pathForResource:@"landmark-model" ofType:@"bin"];
        self._modelt = new ldmarkmodel([haarPath UTF8String]);
        if(!load_ldmarkmodel([modelPath UTF8String], *self._modelt)) {
            std::cout << "Modle Opening Failed." << [modelPath UTF8String] << std::endl;
        }
        
        self._currentShape = new std::vector<cv::Mat>(MAX_FACE_NUM);
    }
    return self;
}


@end

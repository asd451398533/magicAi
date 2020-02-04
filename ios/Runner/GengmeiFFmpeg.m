//
//  GengmeiFFmpeg.m
//  Runner
//
//  Created by Apple on 2019/8/11.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GengmeiFFmpeg.h"
//#import "FFmpeg/tool/ffmpeg.h"

@interface GengmeiFFmpeg ()
//    extern int ffmpeg_exec(int argc, char **argv);
@end


@implementation GengmeiFFmpeg
    {
        
    }
    
+ (instancetype)sharedSingleton {
    static GengmeiFFmpeg *_sharedSingleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSingleton = [[super allocWithZone:NULL] init];
    });
    return _sharedSingleton;
}
    
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [GengmeiFFmpeg sharedSingleton];
}
- (id)copyWithZone:(nullable NSZone *)zone {
    return [GengmeiFFmpeg sharedSingleton];
}
- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [GengmeiFFmpeg sharedSingleton];
}
    
- (instancetype)init
    {
        self = [super init];
        if (self) {
            
        }
        return self;
    }
    
    - (int) exec:(NSString* )exec{
//        NSMutableArray  *argv_array  = [exec componentsSeparatedByString:(@" ")].mutableCopy;
//        int argc = (int)argv_array.count;
//        char** argv = (char**)malloc(sizeof(char*)*argc);
//        for(int i=0; i<argc; i++)
//        {
//            NSString *codeStr = argv_array[i];
//            argv_array[i]     = codeStr;
//            argv[i] = (char *)[codeStr UTF8String];
//        }
//        
//        NSString *finalCommand = @"运行参数:";
//        for (NSString *temp in argv_array) {
//            finalCommand = [finalCommand stringByAppendingFormat:@"%@",temp];
//        }
//        NSLog(@"%@",finalCommand);
//        @try {
//            int result =ffmpeg_exec(argc, argv);
//        } @catch (NSException *exception) {
//            NSLog(@"exception%@",exception);
//        } @finally {
//            
//        }
        return 0;
    }
@end

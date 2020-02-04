//
//  FileUtil.m
//  Runner
//
//  Created by Apple on 2019/7/31.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyFileUtil.h"

@implementation MyFileUtil
    
    
    + (NSString*) GetFileName:(NSString*)pFile
    {
        NSRange range = [pFile rangeOfString:@"/"options:NSBackwardsSearch];
        return [pFile substringFromIndex:range.location + 1];
    }
    
    + (BOOL) FileExist:(NSString*)pFile
    {
        BOOL isDir = NO;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        return[fileManager fileExistsAtPath:pFile isDirectory:&isDir];
    }

+ (long long)fileSizeAtPath:(NSString*)filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

@end

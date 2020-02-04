//
//  FileUtil.h
//  Runner
//
//  Created by Apple on 2019/7/31.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#ifndef FileUtil_h
#define FileUtil_h


#endif /* FileUtil_h */

@interface MyFileUtil : NSObject
    +(NSString*) GetFileName:(NSString*)pFile;
    + (BOOL) FileExist:(NSString*)pFile;
    + (long long)fileSizeAtPath:(NSString*)filePath;
@end

//
//  MyImageManager.m
//  PhotoDemo
//
//  Created by LiynXu on 2016/10/31.
//  Copyright © 2016年 LiynXu. All rights reserved.
//

#import "MyImageManager.h"

@implementation MyImageManager
+(MyImageManager *)defaultManager{
    static MyImageManager *ImageManager = nil;
    if ( ImageManager == nil) {
        ImageManager = [[MyImageManager alloc] init];
    }
    return ImageManager;
}
- (void)requestImageForAsset:(PHAsset *)asset targetSize:(CGSize)targetSize contentMode:(PHImageContentMode)contentMode options:( PHImageRequestOptions *)options Index:(NSInteger)index resultHandler:(void (^)(UIImage * result, NSDictionary * info,NSInteger index))resultHandler{
    [ self requestImageForAsset:asset targetSize:targetSize contentMode:contentMode options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        resultHandler(result,info,index);
    }];
}

@end

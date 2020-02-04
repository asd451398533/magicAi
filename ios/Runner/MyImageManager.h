//
//  MyImageManager.h
//  PhotoDemo
//
//  Created by LiynXu on 2016/10/31.
//  Copyright © 2016年 LiynXu. All rights reserved.
//

#import <Photos/Photos.h>

@interface MyImageManager : PHImageManager
+ (MyImageManager *)defaultManager;
- (void)requestImageForAsset:(PHAsset *)asset targetSize:(CGSize)targetSize contentMode:(PHImageContentMode)contentMode options:( PHImageRequestOptions *)options Index:(NSInteger)index resultHandler:(void (^)(UIImage * result, NSDictionary * info,NSInteger index))resultHandler;
@end

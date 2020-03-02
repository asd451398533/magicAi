//
//  MyTestCameraVC.h
//  Runner
//
//  Created by Apple on 2020/1/6.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#ifndef MyTestCameraVC_h
#define MyTestCameraVC_h


#endif /* MyTestCameraVC_h */
#import <UIKit/UIKit.h>
#import <Flutter/Flutter.h>

@interface MyTestCameraVC : UIViewController
@property (nonatomic, strong) UIImage *image;
@property( nonatomic) FlutterEngine* eng;
@property(nonatomic)int now_index;
@property (nonatomic,strong)NSString* oriPath;
@property(nonatomic,strong)NSString* face;
@property(nonatomic,strong)NSString* eye;
@property(nonatomic)NSMutableArray<NSString*>*userArray;
@end

// Copyright (C) 2018 Beijing Bytedance Network Technology Co., Ltd.

#import <UIKit/UIKit.h>


@protocol BEEffectTapDelegate <NSObject>

- (void)onTap;

@end

@protocol BEDefaultEffectTapDelegate <NSObject>

- (void)onDefaultEffectTap;

@end

@interface BEVideoRecorderViewController : UIViewController

@property (nonatomic, strong) UIImage *image;

@end


// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import <UIKit/UIKit.h>
#import "BECloseableProtocol.h"
#import "BEVideoRecorderViewController.h"


NS_ASSUME_NONNULL_BEGIN


@interface BEModernEffectPickerView : UIView <BECloseableProtocol>

@property (nonatomic, weak) id<BEEffectTapDelegate> onTapDelegate;
@property (nonatomic, weak) id<BEDefaultEffectTapDelegate> onDefaultTapDelegate;
@property (nonatomic) BOOL enable;
@property (nonatomic) BOOL bodyEnable;

- (instancetype)initWithFrame:(CGRect)frame bodyEnable:(BOOL)bodyEnable;

- (void)reloadCollectionViews;
- (void)setDefaultEffect;
- (void)recoverEffect;

- (void)addObserver;
- (void)removeObserver;

@end

NS_ASSUME_NONNULL_END

// Copyright (C) 2018 Beijing Bytedance Network Technology Co., Ltd.

#import <UIKit/UIKit.h>
#import "BEVideoRecorderViewController.h"
#import "BECloseableProtocol.h"
#import "BETextSliderView.h"
@class BEGesturePropertyListViewController, BEFacePropertyListViewController, BEFaceVerifyListViewController;

@protocol BECameraContainerViewDelegate <NSObject>
@optional
- (void)onCloseClicked:(id)sender;
- (void)onSavedClicked:(id)sender;
- (void)onImageModeClicked:(id)sender;
- (void)onSwitchCameraClicked:(id)sender;
- (void)onSegmentControlChanged:(UISegmentedControl *)sender;
- (void)onRecognizeClicked:(id)sender;
- (void)onEffectButtonClicked:(id)sender;
- (void)onStickerButtonClicked:(id)sender;
- (void)onAnimojiButtonClicked:(id)sender;
- (void)onArscanButtonClicked:(id)sender;
- (void)onSaveButtonClicked:(UIButton*)sender;
- (void)onExclusiveSwitchChanged:(UISwitch *)sender;
- (void)onLightClick:(UIButton*)sender;
- (void)onMiddleClick:(UIButton*)sender;
- (void)onHighClick:(UIButton*)sender;
-(void)onallAnswerButtonClicked:(UIButton*)sender;
-(void)onBeforeClick:(UIButton*)sender;
-(void)onAfterClick:(UIButton*)sender;
-(void)ok:(UIButton*)sender;
-(void)reTake:(UIButton*)sender;

- (void)onProgressDidChange:(CGFloat)progress;
-(void)onProgressTouchEnd:(CGFloat)progress;
@end

@interface BECameraContainerView : UIView <BECloseableProtocol>

@property(nonatomic, weak) id<BECameraContainerViewDelegate> delegate;
@property(nonatomic,strong)UIButton* beforeButton;
@property(nonatomic,strong)UIButton* afterButton;
@property(nonatomic,strong)UITextView* textView;
@property (nonatomic, strong) BETextSliderView *exposureSlider;


- (instancetype)initWithFrame:(CGRect)frame imageMode:(BOOL)imageMode;

- (void)showBottomView:(UIView *)view show:(BOOL)show;
- (void)showBottomButton;
- (void)hiddenBottomButton;
- (void)setExclusive:(BOOL)exclusive;
-(void)switchHigh:(int)value;

@end

// Copyright (C) 2018 Beijing Bytedance Network Technology Co., Ltd.
#import "BECameraContainerView.h"
#import <Masonry/Masonry.h>
#import "UIViewController+BEAdd.h"
#import "UIResponder+BEAdd.h"
#import "BEStudioConstants.h"
#import "BEMacro.h"
#import "BEDeviceInfoHelper.h"
#import "BEGlobalData.h"
#import "BEButtonView.h"
#import "TestModel.h"

@interface BECameraContainerView() <UIGestureRecognizerDelegate, TextSliderViewDelegate, BEButtonViewDelegate>

@property (nonatomic, strong) UIButton *settingsButton;
@property (nonatomic, strong) UIButton *btnSwitchCamera;
@property (nonatomic, strong) UIButton *watermarkView;
@property (nonatomic, strong) UIButton* saveButton;
@property(nonatomic,strong)UIButton*allAnswerButton;
@property(nonatomic,strong)UIButton*answerButton;

@property(nonatomic,strong)UIButton* lightButton;
@property(nonatomic,strong)UIButton* middleButton;
@property(nonatomic,strong)UIButton* highButton;

@property (nonatomic, strong) UISwitch *switchExclusive;
@property (nonatomic, strong) UIButton *btnImageMode;
@property (nonatomic, strong) UIButton *btnClose;
@property (nonatomic, strong) UIButton *btnSave;
@property (nonatomic,strong)UIButton * okBtn;
@property(nonatomic,strong)UIButton *reTakeBtm;


@property (nonatomic, strong) BEButtonView *bvEffect;
@property (nonatomic, strong) BEButtonView *bvSticker;
@property (nonatomic, strong) BEButtonView *bvAnimoji;
@property (nonatomic, strong) BEButtonView *bvArscan;

@property (nonatomic, strong) UIControl *tapView;
@property (nonatomic, strong) UIView *currentShowView;


@property (nonatomic, assign) BOOL imageMode;
@end

@implementation BECameraContainerView

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (instancetype)initWithFrame:(CGRect)frame imageMode:(BOOL)imageMode {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        BOOL showAnimoji = !imageMode && BEGlobalData.animojiEnable;
        
        // [self addSubview:self.settingsButton];
        [self addSubview:self.btnClose];
        if (!imageMode) {
            //            [self addSubview:self.btnImageMode];
            [self addSubview:self.btnSwitchCamera];
        } else {
            
            [self addSubview:self.btnSave];
        }
        //        [self addSubview:self.watermarkView];
        
#if APP_IS_DEBUG
        if (!imageMode) {
            [self addSubview:self.saveButton];
        }
#endif
        
        
        NSInteger effectOffset;
        NSInteger stickerOffset;
        NSInteger animojiOffset = 35;
        NSInteger arscanOffset = 105;
        if (showAnimoji) {
            effectOffset = -105;
            stickerOffset = -35;
        } else {
            effectOffset = -50;
            stickerOffset = 50;
        }
        
        //        [self.watermarkView mas_makeConstraints:^(MASConstraintMaker *make) {
        //            if (BEDeviceInfoHelper.isIPhoneXSeries) {
        //                make.top.equalTo(self).offset(40);
        //            } else {
        //                make.top.equalTo(self).offset(30);
        //            }
        //            make.leading.equalTo(self).offset(15);
        //            make.size.mas_equalTo(CGSizeMake(30, 30));
        //        }];
        [self.btnClose mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(30, 30));
            make.top.equalTo(self).offset(30);
            make.leading.equalTo(self).offset(15);
        }];
        if (!imageMode) {
            [self.btnSwitchCamera mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.equalTo(self).offset(-15);
                make.top.equalTo(self).offset(30);
                make.size.mas_equalTo(CGSizeMake(30, 30));
            }];
            
            //            [self.btnImageMode mas_makeConstraints:^(MASConstraintMaker *make) {
            //                make.size.mas_equalTo(CGSizeMake(30, 30));
            //                make.centerY.equalTo(self.watermarkView);
            //                make.trailing.mas_equalTo(self.btnSwitchCamera.mas_leading).offset(-10);
            //            }];
        } else {
            self.watermarkView.hidden = YES;
            [self.btnSave mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(30, 30));
                make.top.equalTo(self).offset(30);
                make.trailing.mas_equalTo(self).offset(-10);
            }];
            
            
            
            //            [self.btnImageMode mas_makeConstraints:^(MASConstraintMaker *make) {
            //                make.size.mas_equalTo(CGSizeMake(30, 30));
            //                make.centerY.equalTo(self.watermarkView);
            //                make.trailing.mas_equalTo(self.btnSave.mas_leading).offset(-10);
            //            }];
        }
        
        //        [self.switchExclusive mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.centerY.equalTo(self.watermarkView);
        //            make.right.equalTo(self.switchCameraButton.mas_left).with.offset(-10);
        //        }];
        
        
//        [self addSubview:self.bvEffect];
//                [self addSubview:self.bvSticker];
//
                
////                [self addSubview:self.switchExclusive];
//                [self.bvEffect mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.centerX.mas_equalTo(self).offset(effectOffset);
//                    make.bottom.equalTo(self).offset(-50);
//                    make.size.mas_equalTo(CGSizeMake(50, 70));
//                }];
//                [self.bvSticker mas_makeConstraints:^(MASConstraintMaker *make) {
//                    make.centerX.equalTo(self).offset(stickerOffset);
//                    make.centerY.equalTo(self.bvEffect);
//                    make.size.equalTo(self.bvEffect);
//                }];
        
        
                        
        
        
#if APP_IS_DEBUG
        if (!imageMode) {
            [self.saveButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.mas_equalTo(self);
                make.bottom.mas_equalTo(self).offset(-140);
                make.size.mas_equalTo(CGSizeMake(50, 50));
            }];
        }
        
#endif
        [self addSubview:self.exposureSlider];
        [self.exposureSlider  mas_makeConstraints:^(MASConstraintMaker *make) {
                            make.centerX.mas_equalTo(self);
                            make.bottom.mas_equalTo(self).offset(-80);
                            make.size.mas_equalTo(CGSizeMake(200, 60));
                        }];
        
        
        [self addSubview:self.textView];
        [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(80);
            make.top.mas_equalTo(self).offset(30);
            make.size.mas_equalTo(CGSizeMake(150, 30));
        }];
        [self addSubview:self.afterButton];
        [self addSubview:self.beforeButton];
        [self.beforeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(10);
            make.size.mas_equalTo(CGSizeMake(60, 20));
            make.bottom.mas_equalTo(self).offset(-160);
        }];
        [self.afterButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).offset(80);
            make.size.mas_equalTo(CGSizeMake(60, 20));
            make.bottom.mas_equalTo(self).offset(-160);
        }];
        if(imageMode){
            [self addSubview:self.allAnswerButton];
            [self.allAnswerButton mas_makeConstraints:^(MASConstraintMaker *make) {
                       make.right.mas_equalTo(self).offset(-20);
                       make.size.mas_equalTo(CGSizeMake(80, 50));
                       make.bottom.mas_equalTo(self).offset(-160);
                   }];
//            [self addSubview:self.lightButton];
//            [self addSubview:self.middleButton];
//            [self addSubview:self.highButton];
            
//            [self.middleButton mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.centerX.mas_equalTo(self);
//                make.size.mas_equalTo(CGSizeMake(60, 30));
//                make.bottom.mas_equalTo(self).offset(-100);
//            }];
//            [self.highButton mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.left.mas_equalTo(self.middleButton).offset(70);
//                make.size.mas_equalTo(CGSizeMake(60, 30));
//                make.bottom.mas_equalTo(self).offset(-100);
//            }];
//            [self.lightButton mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.right.mas_equalTo(self.middleButton).offset(-70);
//                make.size.mas_equalTo(CGSizeMake(60, 30));
//                make.bottom.mas_equalTo(self).offset(-100);
//            }];

            
            [self addSubview:self.okBtn];
            [self addSubview:self.reTakeBtm];
            [self.okBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self).offset(-10);
                make.size.mas_equalTo(CGSizeMake(60, 30));
                make.top.mas_equalTo(self).offset(30);
            }];
            [self.reTakeBtm mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self).offset(-80);
                make.size.mas_equalTo(CGSizeMake(60, 30));
                make.top.mas_equalTo(self).offset(30);
            }];
        }
        
        UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
        gesture.delegate = self;
        [self addGestureRecognizer:gesture];
    }
    return self;
}

-(void)switchHigh:(int)value{
    if(value==0){
        self.lightButton.backgroundColor=UIColor.blueColor;
        self.middleButton.backgroundColor=nil;
        self.highButton.backgroundColor=nil;
    }else if (value==1){
        self.lightButton.backgroundColor=nil;
        self.middleButton.backgroundColor=UIColor.blueColor;
        self.highButton.backgroundColor=nil;
    }else{
        self.lightButton.backgroundColor=nil;
        self.middleButton.backgroundColor=nil;
        self.highButton.backgroundColor=UIColor.blueColor;
    }
}

#pragma mark - event
- (void)onTap {
    [self be_hideView];
}

#pragma mark - public

- (void)showBottomView:(UIView *)view show:(BOOL)show {
    if (show) {
        [self be_showView:view];
    } else {
        [self be_hideView];
    }
}

- (void)showBottomButton{
    self.saveButton.hidden = NO;
    
    self.bvEffect.hidden = NO;
    self.bvSticker.hidden = NO;
    self.bvAnimoji.hidden = NO;
    self.bvArscan.hidden = NO;
}

- (void)hiddenBottomButton{
    self.saveButton.hidden = YES;
    
    self.bvEffect.hidden = YES;
    self.bvSticker.hidden = YES;
    self.bvAnimoji.hidden = YES;
    self.bvArscan.hidden = YES;
}

- (void)setExclusive:(BOOL)exclusive {
    self.switchExclusive.on = exclusive;
}


#pragma mark - BECloseableProtocol
- (void)onClose {
    
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return touch.view == self;
}

#pragma mark - TextSliderViewDelegate
- (void)progressDidChange:(CGFloat)progress {
    [self.delegate onProgressDidChange:progress];
}

-(void)progressTouchEnd:(CGFloat)progress{
    [self.delegate onProgressTouchEnd:progress];
}

#pragma mark - BEButtonViewDelegate
- (void)onButtonClicked:(BEButtonView *)view {
    if (view == self.bvEffect) {
        [self.delegate onEffectButtonClicked:view];
    } else if (view == self.bvSticker) {
        [self.delegate onStickerButtonClicked:view];
    } else if (view == self.bvAnimoji) {
        [self.delegate onAnimojiButtonClicked:view];
    } else if (view == self.bvArscan) {
        [self.delegate onArscanButtonClicked:view];
    }
}

#pragma mark - private
- (void)be_showView:(UIView *)view {
    [self hiddenBottomButton];
    [self addSubview:view];
    _currentShowView = view;
    [view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.mas_bottom);
        make.height.mas_equalTo(view.frame.size.height);
    }];
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        [view mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.mas_equalTo(view.frame.size.height);
        }];
        [self layoutIfNeeded];
    }];
}

- (void)be_hideView {
    if (_currentShowView == nil) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        [_currentShowView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.top.equalTo(self.mas_bottom);
            make.height.mas_equalTo(_currentShowView.frame.size.height);
        }];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [_currentShowView removeFromSuperview];
        [self showBottomButton];
        _currentShowView = nil;
    }];
}

#pragma mark - getter && setter
- (UIButton *)btnClose {
    if (!_btnClose) {
        _btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"ic_close"];
        [_btnClose setImage:image forState:UIControlStateNormal];
        [_btnClose addTarget:self.delegate action:@selector(onCloseClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnClose;
}

- (UIButton *)btnSave {
    if (!_btnSave) {
        _btnSave = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"ic_check"];
        [_btnSave setImage:image forState:UIControlStateNormal];
        [_btnSave addTarget:self.delegate action:@selector(onSavedClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnSave;
}

- (UIButton *)btnImageMode {
    if (!_btnImageMode) {
        _btnImageMode = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"ic_add_image"];
        [_btnImageMode setImage:image forState:UIControlStateNormal];
        [_btnImageMode addTarget:self.delegate action:@selector(onImageModeClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnImageMode;
}

/*
 * 切换摄像头按键
 */
- (UIButton *)btnSwitchCamera {
    if (!_btnSwitchCamera) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage imageNamed:@"iconCameraSwitch"];
        [button setImage:image forState:UIControlStateNormal];
        [button addTarget:self.delegate action:@selector(onSwitchCameraClicked:) forControlEvents:UIControlEventTouchUpInside];
        _btnSwitchCamera = button;
    }
    return _btnSwitchCamera;
}

/*
 * 水印
 */
- (UIButton*) watermarkView{
    if (!_watermarkView){
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *logoImage = [UIImage imageNamed:@"ic_back"];
        [button addTarget:self.delegate action:@selector(onBackClick:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:logoImage forState:UIControlStateNormal];
        _watermarkView = button;
    }
    return _watermarkView;
}

/*
 * 特效按键
 */
- (BEButtonView *)bvEffect {
    if (!_bvEffect) {
        UIImage *image = [UIImage imageNamed:@"iconEffect"];
        _bvEffect = [BEButtonView new];
        [_bvEffect setSelectImg:image unselectImg:image title:NSLocalizedString(@"effect", nil) expand:NO];
        _bvEffect.selected = YES;
        _bvEffect.delegate = self;
    }
    return _bvEffect;
}

/*
 * 贴纸按键
 */
- (BEButtonView *)bvSticker {
    if (!_bvSticker) {
        UIImage *image = [UIImage imageNamed:@"iconSticker"];
        _bvSticker = [BEButtonView new];
        [_bvSticker setSelectImg:image unselectImg:image title:NSLocalizedString(@"sticker", nil) expand:NO];
        _bvSticker.selected = YES;
        _bvSticker.delegate = self;
    }
    return _bvSticker;
}

/*
 * Animoji 按钮
 */
- (BEButtonView *)bvAnimoji {
    if (!_bvAnimoji) {
        UIImage *image = [UIImage imageNamed:@"iconSticker"];
        _bvAnimoji = [BEButtonView new];
        [_bvAnimoji setSelectImg:image unselectImg:image title:NSLocalizedString(@"moji", nil) expand:NO];
        _bvAnimoji.selected = YES;
        _bvAnimoji.delegate = self;
    }
    return _bvAnimoji;
}

/**
 Arscan 按钮
 */
- (BEButtonView *)bvArscan {
    if (!_bvArscan) {
        UIImage *image = [UIImage imageNamed:@"iconSticker"];
        _bvArscan = [BEButtonView new];
        [_bvArscan setSelectImg:image unselectImg:image title:NSLocalizedString(@"ar_scan", nil) expand:NO];
        _bvArscan.selected = YES;
        _bvArscan.delegate = self;
    }
    return _bvArscan;
}

- (UIButton *) saveButton{
    if (!_saveButton){
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveButton addTarget:self.delegate action:@selector(onSaveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        UIImage* image = [UIImage imageNamed:@"iconButtonSavePhoto.png"];
        UIImage* selectedImage = [UIImage imageNamed:@"iconButtonSavePhotoSelected.png"];
        [_saveButton setImage:image forState:UIControlStateNormal];
        [_saveButton setImage:selectedImage forState:UIControlStateSelected];
    }
    return _saveButton;
}

- (UIControl *)tapView {
    if (!_tapView) {
        _tapView = [[UIControl alloc] initWithFrame:self.bounds];
        _tapView.backgroundColor = [UIColor clearColor];
        [_tapView addTarget:self action:@selector(onTap) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tapView;
}

- (BETextSliderView *) exposureSlider{
    if (!_exposureSlider){
        _exposureSlider = [[BETextSliderView alloc] init];
        _exposureSlider.backgroundColor = [UIColor clearColor];
        _exposureSlider.delegate = self;
        _exposureSlider.textColor=UIColor.blackColor;
        _exposureSlider.progress=1.0;
        
    }
    return _exposureSlider;
}

- (UISwitch *)switchExclusive {
    if (!_switchExclusive) {
        _switchExclusive = [UISwitch new];
        _switchExclusive.on = YES;
        [_switchExclusive addTarget:self.delegate action:@selector(onExclusiveSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _switchExclusive;
}

- (UIButton *) middleButton{
    if (!_middleButton){
        _middleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_middleButton addTarget:self.delegate action:@selector(onMiddleClick:) forControlEvents:UIControlEventTouchUpInside];
        [_middleButton setTitle:@"中度" forState:UIControlStateNormal];
    }
    return _middleButton;
}

- (UIButton *) lightButton{
    if (!_lightButton){
        _lightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lightButton addTarget:self.delegate action:@selector(onLightClick:) forControlEvents:UIControlEventTouchUpInside];
        [_lightButton setTitle:@"轻度" forState:UIControlStateNormal];
        _lightButton.backgroundColor=UIColor.blueColor;
    }
    return _lightButton;
}


- (UIButton *) highButton{
    if (!_highButton){
        _highButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_highButton addTarget:self.delegate action:@selector(onHighClick:) forControlEvents:UIControlEventTouchUpInside];
        [_highButton setTitle:@"重度" forState:UIControlStateNormal];
    }
    return _highButton;
}

- (UIButton *) beforeButton{
    if (!_beforeButton){
        _beforeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_beforeButton addTarget:self.delegate action:@selector(onBeforeClick:) forControlEvents:UIControlEventTouchUpInside];
        [_beforeButton setBackgroundColor:UIColor.grayColor];
        [_beforeButton setTitle:@"上一步" forState:UIControlStateNormal];
    }
    return _beforeButton;
}

- (UIButton *) afterButton{
    if (!_afterButton){
        _afterButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_afterButton addTarget:self.delegate action:@selector(onAfterClick:) forControlEvents:UIControlEventTouchUpInside];
        [_afterButton setBackgroundColor:UIColor.grayColor];
        [_afterButton setTitle:@"下一步" forState:UIControlStateNormal];
    }
    return _afterButton;
}

- (UIButton *) okBtn{
    if (!_okBtn){
        _okBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_okBtn addTarget:self.delegate action:@selector(ok:) forControlEvents:UIControlEventTouchUpInside];
        [_okBtn setBackgroundColor:UIColor.blueColor];
        [_okBtn setTitle:@"OK" forState:UIControlStateNormal];
    }
    return _okBtn;
}

-(UIButton*) reTakeBtm{
    if (!_reTakeBtm){
           _reTakeBtm = [UIButton buttonWithType:UIButtonTypeCustom];
           [_reTakeBtm addTarget:self.delegate action:@selector(reTake:) forControlEvents:UIControlEventTouchUpInside];
           [_reTakeBtm setBackgroundColor:UIColor.blueColor];
           [_reTakeBtm setTitle:@"重拍" forState:UIControlStateNormal];
       }
       return _reTakeBtm;
}


- (UIButton *) allAnswerButton{
    if (!_allAnswerButton){
        _allAnswerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_allAnswerButton setTitle:@"评论" forState:UIControlStateNormal];
        [_allAnswerButton addTarget:self.delegate action:@selector(onallAnswerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        UIImage* image = [UIImage imageNamed:@"iconFaceAttriSelected.png"];
        [_allAnswerButton setImage:image forState:UIControlStateNormal];
    }
    return _allAnswerButton;
}

-(UITextView *) textView{
    if(!_textView){
        _textView = [[UITextView alloc] init];
        _textView.font = [UIFont systemFontOfSize:13];
        _textView.textColor = [UIColor blackColor];
    }
    return _textView;
}



- (UIButton *) answerButton{
    if (!_answerButton){
        _answerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_answerButton addTarget:self.delegate action:@selector(onallAnswerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        UIImage* image = [UIImage imageNamed:@"iconFace280Selected.png"];
        [_answerButton setImage:image forState:UIControlStateNormal];
    }
    return _answerButton;
}

@end

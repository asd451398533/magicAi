//
//  PhotoSelectVC.m
//  SenseMeEffects
//
//  Created by Sunshine on 22/08/2017.
//  Copyright © 2017 SenseTime. All rights reserved.
//

#import "PhotoSelectVC.h"
#import "STParamUtil.h"
#import "PhotoProcessingVC.h"
#import <AVFoundation/AVFoundation.h>
#import "STButton.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "VideoProcessingViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>


#define ENABLE_VIDEO_TEST 1

@interface PhotoSelectVC () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *btnSelectImage;
@property (weak, nonatomic) IBOutlet UIButton *btnTakePhoto;
@property (weak, nonatomic) IBOutlet UIButton *btnSelectVideo;
@property (nonatomic, readwrite, strong) STButton *btnBack;

@property (nonatomic, readwrite, strong) UIView *photoSwitchView;
@property (nonatomic, readwrite, strong) UIView *switchContainerView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblTitleTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *takePhotoBtnTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectVideoBtnTopConstraint;
@property (nonatomic, readwrite, strong) UIActivityIndicatorView *indicatorView;
@end

@implementation PhotoSelectVC

- (void)dealloc {
    NSLog(@"photo select vc dealloc successful.");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    [self setupSubviews];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.indicatorView stopAnimating];
}

- (void)setupSubviews {
    
    [self.view addSubview:self.indicatorView];
    [self.view addSubview:self.btnBack];
    
    self.lblTitleTopConstraint.constant = [self layoutHeightWithValue:(14 + 68 + 73)];
    self.takePhotoBtnTopConstraint.constant = [self layoutHeightWithValue:50];
    
    self.btnSelectImage.layer.cornerRadius = 45 / 2.0;
    self.btnSelectImage.clipsToBounds = YES;
    CAGradientLayer *gradientLayer1 = [CAGradientLayer layer];
    gradientLayer1.frame = self.btnSelectImage.bounds;
    gradientLayer1.colors = @[(__bridge id)UIColorFromRGB(0xc460e1).CGColor, (__bridge id)UIColorFromRGB(0x7fb1ee).CGColor];
    gradientLayer1.startPoint = CGPointMake(0, 0);
    gradientLayer1.endPoint = CGPointMake(1, 0);
    [self.btnSelectImage.layer addSublayer:gradientLayer1];
    
    CAGradientLayer *gradientLayer2 = [CAGradientLayer layer];
    gradientLayer2.frame = self.btnSelectImage.bounds;
    gradientLayer2.colors = @[(__bridge id)UIColorFromRGB(0xc460e1).CGColor, (__bridge id)UIColorFromRGB(0x7fb1ee).CGColor];
    gradientLayer2.startPoint = CGPointMake(0, 0);
    gradientLayer2.endPoint = CGPointMake(1, 0);
    self.btnTakePhoto.layer.cornerRadius = 45 / 2.0;
    self.btnTakePhoto.clipsToBounds = YES;
    [self.btnTakePhoto.layer addSublayer:gradientLayer2];
    
    CAGradientLayer *gradientLayer3 = [CAGradientLayer layer];
    gradientLayer3.frame = self.btnSelectVideo.bounds;
    gradientLayer3.colors = @[(__bridge id)UIColorFromRGB(0xc460e1).CGColor, (__bridge id)UIColorFromRGB(0x7fb1ee).CGColor];
    gradientLayer3.startPoint = CGPointMake(0, 0);
    gradientLayer3.endPoint = CGPointMake(1, 0);
    self.btnSelectVideo.layer.cornerRadius = 45 / 2.0;
    self.btnSelectVideo.clipsToBounds = YES;
    [self.btnSelectVideo.layer addSublayer:gradientLayer3];
#if ENABLE_VIDEO_TEST
    self.btnSelectVideo.hidden = NO;
#else
    self.btnSelectVideo.hidden = YES;
#endif
}

#pragma mark - UI

- (UIActivityIndicatorView *)indicatorView {
    
    if (!_indicatorView) {
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        
        _indicatorView.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
        
        _indicatorView.color = [UIColor blackColor];
        
    }
    return _indicatorView;
}

- (STButton *)btnBack {
    
    if (!_btnBack) {
        
        _btnBack = [[STButton alloc] initWithFrame:CGRectMake(15, 15, 50, 50)];
        [_btnBack setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
        [_btnBack addTarget:self action:@selector(onBtnBack) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _btnBack;
}

#pragma mark - btn action

- (IBAction)onClickSelectPhotoFromAlbum:(id)sender {
    
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status != ALAuthorizationStatusAuthorized) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"相册不可用，请更改权限设置" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    } else {
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.mediaTypes = @[(__bridge NSString *)kUTTypeImage];
        imagePickerController.delegate = self;
        imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:imagePickerController animated:YES completion:nil];
        
    }

}
- (IBAction)onClickTakePhoto:(id)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        imagePicker.allowsEditing = NO;
        imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        imagePicker.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:imagePicker animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"相机不可用，请更改权限设置" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    }
}
- (IBAction)onClickSelectVideoFromAlbum:(id)sender {
    
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status != ALAuthorizationStatusAuthorized) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"相册不可用，请更改权限设置" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
    } else {
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.mediaTypes = @[(__bridge NSString *)kUTTypeMovie];
        imagePickerController.delegate = self;
        imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:imagePickerController animated:YES completion:nil];
        
    }
    
}

- (void)onBtnBack {
    [self.indicatorView startAnimating];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoSelectVCDidDismiss)]) {
        
        [self.delegate photoSelectVCDidDismiss];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    
    if ([info[UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) {
        UIImage *imageOriginal = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        if (imageOriginal.imageOrientation != UIImageOrientationUp || imageOriginal.imageOrientation != UIImageOrientationUpMirrored) {
            
            if (imageOriginal.size.height > 3000 || imageOriginal.size.width > 3000) {
                
                UIGraphicsBeginImageContext(CGSizeMake(imageOriginal.size.width * 0.5, imageOriginal.size.height * 0.5));
                
                [imageOriginal drawInRect:CGRectMake(0, 0, imageOriginal.size.width * 0.5, imageOriginal.size.height * 0.5)];
                
                imageOriginal = UIGraphicsGetImageFromCurrentImageContext();
                
                UIGraphicsEndImageContext();
            }
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            [self detectImage:imageOriginal];
        }];
    }
    
    if ([info[UIImagePickerControllerMediaType] isEqualToString:@"public.movie"]) {
        [self dismissViewControllerAnimated:YES completion:^{
            [self processMovie:info[UIImagePickerControllerReferenceURL]];
        }];
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
    picker.delegate = nil;
}

#pragma mark - layout helper

- (CGFloat)layoutHeightWithValue:(CGFloat)value {
    
    return (value / 1334) * SCREEN_HEIGHT;
}

- (CGFloat)layoutWidthWithValue:(CGFloat)value {
    
    return (value / 750) * SCREEN_WIDTH;
}

#pragma mark -

- (void)detectImage:(UIImage *)image {
    
    PhotoProcessingVC *ppvc = [[PhotoProcessingVC alloc] init];
    ppvc.imageOriginal = image;
    ppvc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:ppvc animated:YES completion:nil];
}

- (void)processMovie:(NSURL *)movieURL {
    
    VideoProcessingViewController *videoProcessVC = [[VideoProcessingViewController alloc] init];
    videoProcessVC.videoURL = movieURL;
    videoProcessVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:videoProcessVC animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self.view];
    
    if (!self.switchContainerView.isHidden) {
        
        if (!CGRectContainsPoint(self.switchContainerView.frame, point)) {
            
            self.switchContainerView.hidden = YES;
            
            self.photoSwitchView.hidden = NO;
        }
    }
    
}

#pragma mark -

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

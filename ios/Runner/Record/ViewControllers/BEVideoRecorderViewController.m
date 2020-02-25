// Copyright (C) 2018 Beijing Bytedance Network Technology Co., Ltd.
#import "BEVideoRecorderViewController.h"

#import <UIKit/UIKit.h>
#import <Masonry.h>
#import <Toast/UIView+Toast.h>
#import <TZImagePickerController.h>

#import "BEGLView.h"
#import "BEFrameProcessor.h"
#import "BEVideoCapture.h"
#import "BECameraContainerView.h"
#import "BEModernEffectPickerView.h"
#import "BEModernStickerPickerView.h"
#import "BEEffectDataManager.h"
#import "BEStudioConstants.h"
#import "BEGlobalData.h"

typedef enum : NSUInteger {
    BefEffectNone = 0,
    BefEffectFaceBeauty,
    BefEffectSticker,
    BefEffectAnimoji
}BefEffectMainStatue;


@interface BEVideoRecorderViewController ()<BEVideoCaptureDelegate, BECameraContainerViewDelegate, BEModernStickerPickerViewDelegate, BEEffectTapDelegate, BEDefaultEffectTapDelegate, BECaptureDelegate, TZImagePickerControllerDelegate>
{
    BEFrameProcessor *_processor;
    BefEffectMainStatue lastEffectStatue;
    BOOL             _hasObserver;
    BOOL             _resumed;
}

@property (nonatomic, assign) AVCaptureVideoOrientation referenceOrientation; // 视频播放方向
@property (nonatomic, strong) BEGLView *glView;
@property (nonatomic, strong) id<BEVideoCaptureProtocol> capture;
@property (nonatomic, assign) int orientation;
@property (nonatomic, copy) AVCaptureSessionPreset captureSessionPreset;
@property (nonatomic, assign) BOOL imageMode;

@property (nonatomic, strong) BECameraContainerView *cameraContainerView;
@property (nonatomic, strong) BEModernEffectPickerView *effectPickerView;
@property (nonatomic, strong) BEModernStickerPickerView *stickerPickerView;
@property (nonatomic, strong) BEModernStickerPickerView *animojiPickerView;
@property (nonatomic, strong) BEModernStickerPickerView *arscanPickerView;

@property (nonatomic, copy) NSArray<BEEffectSticker*> *stickers;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, assign) BOOL touchExposureEnable;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSString *savedStickerPath;
@property (nonatomic, strong) NSString *savedAnimojiPath;
@property (nonatomic, strong) NSString *savedArscanPath;
@end

@implementation BEVideoRecorderViewController

- (void)dealloc
{
    [self releaseTimer];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _captureSessionPreset = AVCaptureSessionPreset1280x720;
    lastEffectStatue = BefEffectNone;
    [self addObserver];
    [self setupTimer];
    [self be_createSdk];
    [self be_initData];
    [self be_setupUI];
    [self be_createCamera];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.effectPickerView setDefaultEffect];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    _resumed = YES;
    [self addObserver];
    if (_capture) {
        [_capture startRunning];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [self be_removeObserver];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self releaseTimer];
    _resumed = NO;
    if (_capture) {
        [_capture stopRunning];
    }
}

#pragma mark - Notification
- (void)addObserver {
    if (_hasObserver) {
        return;
    }
    _hasObserver = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onListenFilterChanged:)
                                                 name:BEEffectFilterDidChangeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onListenFilterIntensityChanged:)
                                                 name:BEEffectFilterIntensityDidChangeNotification
                                               object:nil];

    //授权成功
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onListenAuthorizationChanged:)
                                                 name:BEEffectCameraDidAuthorizationNotification
                                               object:nil];
    
    //返回主界面
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onListenReturnToMainUI:)
                                                 name:BEEffectDidReturnToMainUINotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNormalButton:)
                                                 name:BEEffectNormalButtonNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUpdateComposerNdoes:)
                                                 name:BEEffectUpdateComposerNodesNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUpdateComposerNodeIntensity:)
                                                 name:BEEffectUpdateComposerNodeIntensityNotification
                                               object:nil];

    //曝光补偿滑杆的值改变
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onExporsureValueChanged:)
                                                 name:BEEffectExporsureValueChangedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSdkError:)
                                                 name:BESdkErrorNotification
                                               object:nil];

//    if (![UIDevice currentDevice].generatesDeviceOrientationNotifications) {
//        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    }
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(handleDeviceOrientationChange:)
//                                                 name:UIDeviceOrientationDidChangeNotification
//                                               object:nil];
    
    [self.effectPickerView addObserver];
    [self be_checkAndRecoverEffect];
}

#pragma mark - obverser handler

- (void)onSdkError:(NSNotification *)aNote {
    NSString *msg = aNote.userInfo[BEEffectNotificationUserInfoKey];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_glView makeToast:msg duration:(NSTimeInterval)(3.0) position:CSToastPositionCenter];
    });
}

- (void)onExporsureValueChanged:(NSNotification *) aNote{
    float value = [aNote.userInfo[BEEffectNotificationUserInfoKey] floatValue];

    [_capture pause];
    [_capture setExposure:value];
    [_capture resume];
}

- (void)handleDeviceOrientationChange:(NSNotification *)notification {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            [_capture setOrientation:AVCaptureVideoOrientationPortrait];
            [self.effectPickerView reloadCollectionViews];
            break;
        case UIDeviceOrientationLandscapeLeft:
            [_capture setOrientation:AVCaptureVideoOrientationLandscapeRight];
            [self.effectPickerView reloadCollectionViews];
            break;
        case UIDeviceOrientationLandscapeRight:
            [_capture setOrientation:AVCaptureVideoOrientationLandscapeLeft];
            [self.effectPickerView reloadCollectionViews];
        default:
            break;
    }
}

- (void)onUpdateComposerNdoes:(NSNotification *)aNote {
    NSArray<NSNumber *> *nodes = aNote.userInfo[BEEffectNotificationUserInfoKey];
    
    [_capture pause];
    NSArray<NSString *> *paths = [self be_composerNodesToPaths:nodes];
    [_processor updateComposerNodes:paths];
    NSLog(@"LSSS COMPOS %@ ",paths);
    [_capture resume];
     
}

- (void)onUpdateComposerNodeIntensity:(NSNotification *)aNote {
    BEEffectNode node = [aNote.userInfo[BEEffectNotificationUserInfoKey][0] longValue];
    CGFloat intensity = [aNote.userInfo[BEEffectNotificationUserInfoKey][1] floatValue];
    [_capture pause];
    BEComposerNodeModel *model = [self be_composerNodeToNode:[NSNumber numberWithLong:node]];
    NSLog(@"LSSS MODEL %@  %@",model.key,model.path);
    if (model != nil) {
        [_processor updateComposerNodeIntensity:model.path key:model.key intensity:intensity];
    } else {
        NSLog(@"model not found, node: %ld", node);
    }
    [_capture resume];
}

- (void)onNormalButton:(NSNotification *)aNote
{
    BOOL isUp = [aNote.userInfo[BEEffectNotificationUserInfoKey] boolValue];
    [_processor setEffectOn:isUp];
}

- (void)onListenReturnToMainUI:(NSNotification *)aNote{
    [self.cameraContainerView showBottomButton];
}

- (void) onListenAuthorizationChanged:(NSNotification *)aNote{
    CGRect displayViewRect = [UIScreen mainScreen].bounds;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _glView.frame = displayViewRect;});
}

- (void)onListenFilterChanged:(NSNotification *)aNote {
    NSString *path = aNote.userInfo[BEEffectNotificationUserInfoKey];
    [_capture pause];
    NSLog(@"PATH %@",path);
    [_processor setFilterPath:path];
    
    [_capture resume];
}

- (void)onListenFilterIntensityChanged:(NSNotification *)aNote {
    float intensity = [aNote.userInfo[BEEffectNotificationUserInfoKey] floatValue];
    [_capture pause];
    [_processor setFilterIntensity:intensity];
    [_capture resume];
}

#pragma mark - BEModernStickerPickerViewDelegate
- (void)stickerPicker:(BEModernStickerPickerView *)pickerView didSelectStickerPath:(NSString *)path toastString:(NSString *)toast type:(BEEffectNode)type {
    [_capture pause];
    BOOL availablePath = [self be_availablePath:path];
    if (type == BETypeSticker || type == BETypeArscan) {
        self.effectPickerView.enable = !availablePath || ![self be_isExclusive];
        if (type == BETypeSticker) {
            if ([self be_availablePath:self.savedArscanPath]) {
                self.savedArscanPath = nil;
                [self.arscanPickerView onClose];
            }
            self.savedStickerPath = path;
        } else if (type == BETypeArscan) {
            if ([self be_availablePath:self.savedStickerPath]) {
                self.savedStickerPath = nil;
                [self.stickerPickerView onClose];
            }
            self.savedArscanPath = path;
        }
        if ([self be_isExclusive]) {
            if (!availablePath) {
                [self.effectPickerView recoverEffect];
            } else {
                [self be_cleanUpLastEffectWithCurrentStatus:BefEffectSticker];
                [_processor setStickerPath:path];
            }
        } else {
            [_processor setStickerPath:path];
        }
        [_glView hideAllToasts];
        
        if (toast.length > 0 ){
            [_glView makeToast:toast duration:(NSTimeInterval)(3.0) position:CSToastPositionCenter];
        }
    } else if (type == BETypeAnimoji) {
        self.effectPickerView.enable = !availablePath;
        if (self.savedAnimojiPath != path) {
            self.savedAnimojiPath = path;
            if (availablePath) {
                [self be_cleanUpLastEffectWithCurrentStatus:BefEffectAnimoji];
                self.stickerPickerView.enable = NO;
                [_processor setStickerPath:path];
            } else {
                [_processor setStickerPath:path];
                self.stickerPickerView.enable = YES;
                if ([self be_availablePath:self.savedStickerPath]) {
                    [self.stickerPickerView recoverState:self.savedStickerPath];
                    [_processor setStickerPath:self.savedStickerPath];
                }
                if (![self be_isExclusive] || (![self be_availablePath:self.savedStickerPath] && ![self be_availablePath:self.savedArscanPath])) {
                    [self.effectPickerView recoverEffect];
                }
            }
        }
    }
    [_capture resume];
}

#pragma mark - BECameraContainerViewDelegate

- (void) onSwitchCameraClicked:(UIButton *) sender {
    sender.enabled = NO;
    [self.capture switchCamera];
    sender.enabled = YES;
}

#pragma mark - BEDefaultTapDelegate
- (void)onDefaultEffectTap {
    [self be_cleanUpLastEffectWithCurrentStatus:BefEffectFaceBeauty];
}

#pragma mark - BETapDelegate
- (void)onTap {
    NSString *toast;
    if (self.savedAnimojiPath != nil && ![self.savedAnimojiPath isEqualToString:@""]) {
        toast = NSLocalizedString(@"tip_close_animoji_first", nil);
    } else {
        toast = NSLocalizedString(@"tip_close_sticker_first", nil);
    }
    [_glView makeToast:toast duration:(NSTimeInterval)(2.0) position:CSToastPositionCenter];
}

#pragma mark - BECaptureDelegate
- (void)onImageCapture:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void*)self);
}

- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void *)contextInfo{
    if(error) {
        NSLog(@"fail to save photo");
    } else {
        [self.view.window makeToast:NSLocalizedString(@"ablum_have_been_saved", nil) duration:(NSTimeInterval)(3.0) position:CSToastPositionCenter];
    }
    if (self.imageMode) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - TZImagePickerControllerDelegate
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    if (photos.count == 1) {
        if (isSelectOriginalPhoto) {
            [[TZImageManager manager] getOriginalPhotoWithAsset:assets[0] completion:^(UIImage *photo, NSDictionary *info) {
                if ([[info objectForKey:@"PHImageResultIsDegradedKey"] boolValue]) return;
                [self imagePickerController:picker onSelectImageAvailable:photo];
            }];
        } else {
            [self imagePickerController:picker onSelectImageAvailable:photos[0]];
        }
    }
}

- (void)imagePickerController:(TZImagePickerController *)picker onSelectImageAvailable:(UIImage *)image {
    if (![self be_checkImageAvailable:image]) {
        [picker.view makeToast:@"size of image must be less than 4096" duration:3 position:CSToastPositionCenter];
        return;
    }
    if (!self.imageMode) {
        BEVideoRecorderViewController *vc = [[BEVideoRecorderViewController alloc] init];
        vc.image = image;
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [picker pushViewController:vc animated:YES];
    } else {
        [picker dismissViewControllerAnimated:YES completion:nil];
        [_capture resetImage:image];
    }
}

- (void)tz_imagePickerControllerDidCancel:(TZImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - BECameraContainerViewDelegate

//显示特效界面
- (void)onEffectButtonClicked:(UIButton *)sender{
    [self.cameraContainerView showBottomView:self.effectPickerView show:YES];
}

//显示贴纸界面
- (void)onStickerButtonClicked:(UIButton *)sender{
    [self.cameraContainerView showBottomView:self.stickerPickerView show:YES];
}

- (void)onAnimojiButtonClicked:(UIButton *)sender{
    [self.cameraContainerView showBottomView:self.animojiPickerView show:YES];
}

- (void)onArscanButtonClicked:(id)sender {
    [self.cameraContainerView showBottomView:self.arscanPickerView show:YES];
}

- (void)onSaveButtonClicked:(UIButton*)sender{
    _processor.captureNextFrame = YES;
}

- (void)onExclusiveSwitchChanged:(UISwitch *)sender {
    BOOL exclusive = sender.isOn;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:BEFUserDefaultExclusive] == exclusive) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setBool:exclusive forKey:BEFUserDefaultExclusive];
    [_glView hideAllToasts];
    NSString *toast = NSLocalizedString(@"exclusive_tip", nil);
    if (toast.length > 0 ) {
        [_glView makeToast:toast duration:(NSTimeInterval)(3.0) position:CSToastPositionCenter];
    }
}

- (void)onImageModeClicked:(id)sender {
    TZImagePickerController *vc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    vc.autoDismiss = NO;
    vc.allowPickingVideo = NO;
    vc.allowPickingGif = NO;
    vc.allowPickingOriginalPhoto = NO;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)onCloseClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onSavedClicked:(id)sender {
    [self onSaveButtonClicked:sender];
}

#pragma mark - VideoCaptureDelegate
/*
 * 相机帧经过美化处理后再绘制到屏幕上
 */
- (void)videoCapture:(id<BEVideoCaptureProtocol>)camera didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    CVImageBufferRef imageRef = CMSampleBufferGetImageBuffer(sampleBuffer);
    CMTime sampleTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    double timeStamp = (double)sampleTime.value/sampleTime.timescale;
    [_processor setCameraPosition:[_capture devicePosition] == AVCaptureDevicePositionFront];
    BEProcessResult *result =  [_processor process:imageRef timeStamp:timeStamp];
    dispatch_sync(dispatch_get_main_queue(), ^{
        [_glView renderWithTexture:result.texture
                              size:result.size
                           flipped:YES
               applyingOrientation:_orientation
                           fitType:0];
    });
}

- (void)videoCapture:(id<BEVideoCaptureProtocol>)camera didOutputBuffer:(unsigned char *)buffer width:(int)width height:(int)height bytesPerRow:(int)bytesPerRow timeStamp:(double)timeStamp {
    if (!_resumed) return;
    [_processor setCameraPosition:[_capture devicePosition] == AVCaptureDevicePositionFront];
    BEProcessResult *result = [_processor process:buffer width:width height:height bytesPerRow:bytesPerRow timeStamp:timeStamp format:GL_RGBA];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (!_resumed) return;
        [_glView renderWithTexture:result.texture
                       size:result.size
                    flipped:YES
        applyingOrientation:_orientation
                    fitType:1];
    });
}

- (void)videoCapture:(id<BEVideoCaptureProtocol>)camera didFailedToStartWithError:(VideoCaptureError)error {

}


// 测光逻辑：
// 无人脸时，测光点默认为(0.5, 0.5), 点击屏幕可改变测光点。
// 有人脸时候，测光点为人脸中心点，通过人脸sdk计算得到，这时候点击屏幕也可以改变测光点，不过3秒后测光点会自动改回人脸中心点。继续点击屏幕，定时器重新启动
// 从无人脸到有人脸，曝光点自动设置回默认值(0.5, 0.5)
#pragma mark - VideoMetadataDelegate

-(void)captureOutput:(BEVideoCapture *)camera didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects
{
    BOOL detectedFace = 0;
    CGPoint point = CGPointMake(0.5, 0.5);
    for (AVMetadataFaceObject *face in metadataObjects)
    {
//        NSLog(@"Face detected with ID: %li", (long)face.faceID);
        NSLog(@"Face bounds: %@", NSStringFromCGRect(face.bounds));

        
        float faceMiddleWidth = (face.bounds.origin.x + face.bounds.size.width) / 2;
        float faceMiddleHeight = (face.bounds.origin.y + face.bounds.size.height) / 2;
        
        point = CGPointMake(faceMiddleWidth, faceMiddleHeight);
        detectedFace ++;
        break;
    }
   
    //半脸情况下避免测光点在过于边缘的位置导致的过曝，在靠近屏幕边缘时候测光点改回中心位置
    if(point.x > 0.8 || point.x < 0.2 || point.y< 0.05 ||point.y > 0.95)
    {
        point = CGPointMake(0.5, 0.5);
    }
    
    [self didChangeExporsureDetectPoint:point fromFace:detectedFace>0];
    
}

-(void) didChangeExporsureDetectPoint:(CGPoint)point fromFace:(BOOL)fromFace {
    if([_timer isValid]) return;
    
//    NSLog(@"detected face point x: %f, y: %f", point.x, point.y);
    
    if(!_touchExposureEnable && !fromFace)
    {
        [_capture setExposurePointOfInterest:CGPointMake(0.5f, 0.5f)];
        [_capture setFocusPointOfInterest:CGPointMake(0.5f, 0.5f)];
        _touchExposureEnable = YES;
        return;
    }
    
    _touchExposureEnable = !fromFace;
    
    if(_touchExposureEnable) return;

    if (point.x == 0 && point.y == 0) {
        return;
    }
    
//    NSLog(@"ExposurePointOfInterest: (%f, %f)", point.x, point.y);
    [_capture setExposurePointOfInterest:point];
    [_capture setFocusPointOfInterest:point];

}


#pragma mark - private

- (void)be_setupUI {
    self.cameraContainerView = [[BECameraContainerView alloc] initWithFrame:self.view.bounds imageMode:self.imageMode];
    self.cameraContainerView.delegate = self;
    [self.view addSubview:self.cameraContainerView];
    [self.cameraContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)be_createSdk {
    _glView = [[BEGLView alloc] initWithFrame: [UIScreen mainScreen].bounds];
    [self.view addSubview:_glView];
    [_glView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    
    EAGLContext *context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:self.glView.context.sharegroup];
    [EAGLContext setCurrentContext:context];
    _processor = [[BEFrameProcessor alloc] initWithContext:context resourceDelegate:nil];
    _processor.captureDelegate = self;
}


/// 根据当前的模式，选择不同的视频源
- (void)be_createCamera {
    if (self.imageMode) {
        _capture = [[BEImageCapture alloc] initWithImage:self.image];
        _capture.delegate = self;
    } else {
        _capture = [[BEVideoCapture alloc] init];
        _capture.isOutputWithYUV = NO;
        _capture.delegate = self;
        _capture.sessionPreset = self.captureSessionPreset;
    }
}

- (void)be_initData {
//    BOOL exclusive = [[NSUserDefaults standardUserDefaults] boolForKey:BEFUserDefaultExclusive];
    BOOL exclusive = NO;
    [_processor setComposerMode:exclusive ? 0 : 1];
    [_cameraContainerView setExclusive:exclusive];
    
    NSArray<NSString *> *array = [_processor availableFeatures];
    for (NSString *s in array) {
        NSLog(@"INIT DATA %@",s);
        if ([s isEqualToString:@"3DStickerV3"]) {
            BEGlobalData.animojiEnable = true;
            break;
        }
    }
}

- (void)be_removeObserver {
    _hasObserver = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.effectPickerView removeObserver];
    [self.effectPickerView onClose];
}

- (void)be_setStickerUnSelected {
    [_capture pause];
    [self.stickerPickerView onClose];
    [_processor setStickerPath:@""];
    [_capture resume];
}

//去除所有的美颜效果
- (void)be_setEffectPickerUnSelected {
    [_capture pause];
    
    //清除美妆和美颜的效果
    [_processor updateComposerNodes:@[]];
    [_processor setFilterPath:@""];
    
    [self.effectPickerView onClose];

    [_capture resume];
}

- (void)be_setAnimojiPickerUnselected {
    [_capture pause];
    
    [self.animojiPickerView onClose];
    [_processor setStickerPath:@""];
    
    [_capture resume];
}

- (BOOL)be_isExclusive {
    return _processor.composerMode == 0;
}

- (void)be_startSelectImg {
    
}

- (void)be_cleanUpLastEffectWithCurrentStatus:(BefEffectMainStatue)currentStatus{
    if (currentStatus == BefEffectFaceBeauty) {
        [self.stickerPickerView onClose];
        [self.animojiPickerView onClose];
        self.stickerPickerView.enable = YES;
        if (self.savedStickerPath != nil && ![self.savedStickerPath isEqualToString:@""]) {
            self.savedStickerPath = nil;
            [_processor setStickerPath:@""];
        }
        if (self.savedAnimojiPath != nil && ![self.savedAnimojiPath isEqualToString:@""]) {
            self.savedAnimojiPath = nil;
            [_processor setStickerPath:@""];
        }
    } else if (currentStatus == BefEffectSticker) {
        if ([self be_isExclusive]) {
            [self.effectPickerView onClose];
        }
    } else if (currentStatus == BefEffectAnimoji) {
        [self.effectPickerView onClose];
        [self.stickerPickerView onClose];
        [_processor updateComposerNodes:@[]];
    }
}

- (NSArray<NSString *> *)be_composerNodesToPaths:(NSArray<NSNumber *> *)nodes {
    NSMutableArray<NSString *> *array = [NSMutableArray array];
    for (NSNumber *node in nodes) {
        BEComposerNodeModel *model = [self be_composerNodeToNode:node];
        if (model == nil) {
            NSLog(@"model not found, node: %ld", [node longValue]);
            continue;
        }
        [array addObject:model.path];
    }
    return array;
}

- (BEComposerNodeModel *)be_composerNodeToNode:(NSNumber *)node {
    NSDictionary *dict = [BEEffectDataManager composerNodeDic];
    NSNumber *realNode = [NSNumber numberWithLong:([node longValue] & ~SUB_MASK)];
    BEComposerNodeModel *model = [dict objectForKey:realNode];
    if (model == nil) {
        return nil;
    }
    BEComposerNodeModel *tmp = [BEComposerNodeModel new];
    if (([node longValue] & SUB_MASK)) {
//        tmp.path = model.pathArray[(([node longValue] & SUB_MASK) - 1)];
//        tmp.key = model.keyArray[(([node longValue] & SUB_MASK) - 1)];
        tmp.path = model.pathArray[(([node longValue] & SUB_MASK) - 1)];
        tmp.key = model.keyArray[0];
    } else {
        tmp.path = model.path;
        tmp.key = model.key;
    }
    return tmp;
}

- (BOOL)be_checkImageAvailable:(UIImage *)image {
    return image.size.width <= 4096 && image.size.height <= 4096;
}


/// 受制于 effect 520 版本多 handle 共用 intensity，所以此处还需要切换页面前后
/// 手动保存/恢复，550 后解决
- (void)be_checkAndRecoverEffect {
    if ([self be_availablePath:self.savedAnimojiPath]) return;
    if (([self be_availablePath:self.savedStickerPath] || [self be_availablePath:self.savedArscanPath]) && [self be_isExclusive]) return;
    [self.effectPickerView recoverEffect];
}

- (BOOL)be_availablePath:(NSString *)path {
    return path != nil && ![path isEqualToString:@""];
}

#pragma mark - timer

- (void)setupTimer {
    [self releaseTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(updateTouchState) userInfo:nil repeats:NO];
    [_timer invalidate];
}

- (void)resetTimer {
    __weak typeof(self)weakSelf = self;
    [weakSelf.timer invalidate];
    weakSelf.timer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(updateTouchState) userInfo:nil repeats:NO];
}

- (void)updateTouchState {
    if(_touchExposureEnable)
    {
        _touchExposureEnable = NO;
         [_timer invalidate];
    }
}

- (void)releaseTimer {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}


-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent *)event {
    
    UITouch * touch = [[event allTouches] anyObject];
    CGPoint loc = [touch locationInView:self.view];

    if(!_touchExposureEnable )
    {
        _touchExposureEnable = YES;
        [self resetTimer];
    }
    
    CGRect bouns =  self.view.bounds;
    CGPoint point = CGPointMake(loc.x / bouns.size.width, loc.y / bouns.size.height);
    [_capture setExposurePointOfInterest:point];
    [_capture setFocusPointOfInterest:point];
    
}

#pragma mark - getter
- (BOOL)imageMode {
    return _image != nil;
}

- (BEModernEffectPickerView *)effectPickerView {
    if (!_effectPickerView) {
        _effectPickerView = [[BEModernEffectPickerView alloc] initWithFrame:(CGRect)CGRectMake(0, 0, self.view.frame.size.width, 220) bodyEnable:!self.imageMode];
        _effectPickerView.onTapDelegate = self;
        _effectPickerView.onDefaultTapDelegate = self;
    }
    return _effectPickerView;
}


- (BEModernStickerPickerView *)stickerPickerView {
    if (!_stickerPickerView) {
        _stickerPickerView = [[BEModernStickerPickerView alloc] initWithFrame:(CGRect)CGRectMake(0, 0, self.view.frame.size.width, 200)];
        _stickerPickerView.layer.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6].CGColor;
        _stickerPickerView.delegate = self;
        _stickerPickerView.onTapDelegate = self;
        [_stickerPickerView refreshWithType:BETypeSticker];
    }
    return _stickerPickerView;
}

- (BEModernStickerPickerView *)animojiPickerView{
    if (!_animojiPickerView) {
        _animojiPickerView = [[BEModernStickerPickerView alloc] initWithFrame:(CGRect)CGRectMake(0, 0, self.view.frame.size.width, 200)];
        _animojiPickerView.layer.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6].CGColor;
        _animojiPickerView.delegate = self;
        [_animojiPickerView refreshWithType:BETypeAnimoji];
    }
    return _animojiPickerView;
}

- (BEModernStickerPickerView *)arscanPickerView {
    if (!_arscanPickerView) {
        _arscanPickerView = [[BEModernStickerPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
        _arscanPickerView.layer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6].CGColor;
        _arscanPickerView.delegate = self;
        [_arscanPickerView refreshWithType:BETypeArscan];
    }
    return _arscanPickerView;
}
- (void)BEFrameProcessor:(BEFrameProcessor *)processor didDetectFaceInfo:(bef_ai_face_info)faceInfo{
    int count = faceInfo.face_count;
//    NSLog(@"FACE CIYBNt %i  %f %f",count,faceInfo.base_infos[0].points_array[0].x,faceInfo.base_infos[0].points_array[0].y);

 
}
@end

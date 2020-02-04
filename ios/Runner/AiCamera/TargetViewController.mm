#import "TargetViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgproc/imgproc_c.h>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/opencv.hpp>
#import "Face.h"
#import "FaceMtcnnWrapper.h"
#import <Photos/PHPhotoLibrary.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AssetsLibrary/ALAsset.h>
#import <AssetsLibrary/ALAssetsLibrary.h>
#import <AssetsLibrary/ALAssetsGroup.h>
#import <AssetsLibrary/ALAssetRepresentation.h>
#import "MyUtils.h"

@interface TargetViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureMetadataOutputObjectsDelegate,UIAlertViewDelegate,CAAnimationDelegate>
@property (nonatomic,strong) dispatch_queue_t sample;
@property (nonatomic,strong) dispatch_queue_t faceQueue;
@property (nonatomic,copy) NSArray *currentMetadata;
@property (nonatomic,strong) FaceMtcnnWrapper *mt;
@property (nonatomic,strong) UILabel *distance;
@property (nonatomic,strong) UIImageView *cameraView;
@property(nonatomic)AVCaptureSession *session;
@property(nonatomic)AVCaptureDevice *device;
@property(nonatomic)AVCaptureDeviceInput *input;
@property(nonatomic)AVCaptureVideoDataOutput *mOutput;
@property (nonatomic, strong) UIButton *PhotoButton;
@property (nonatomic, strong) UIButton *flashButton;
@property (nonatomic, strong) UIButton *cancleButton;
@property (nonatomic, strong) UIButton *changeButton;
@property (nonatomic, strong) UIImageView *focusView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, assign) BOOL isflashOn;
@property (nonatomic, assign) BOOL canCa;
@property (nonatomic, assign) AVCaptureFlashMode flahMode;
@property (nonatomic, assign) AVCaptureDevicePosition cameraPosition;
@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic) UIBezierPath * path;
@property (nonatomic)CAShapeLayer *layer;
@property (nonatomic)volatile Boolean takePic;
@property(nonatomic)NSString * filePath;
@property(nonatomic) NSMutableArray *imageArr;//未压缩的图片
@property(nonatomic) NSMutableArray *imageArray;
@property (nonatomic, strong) NSString *theVideoPath;
@end
#define kWidth   [UIScreen mainScreen].bounds.size.width
#define kHeight  [UIScreen mainScreen].bounds.size.height
#define kScaleX  [UIScreen mainScreen].bounds.size.width / 375.f
#define kScaleY  [UIScreen mainScreen].bounds.size.height / 667.f
#define kContentFrame CGRectMake(0, 0, kWidth, kHeight-165*kScaleY)
@implementation TargetViewController

#pragma mark - 视图加载
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.takePic=false;
    _currentMetadata = [NSMutableArray arrayWithCapacity:0];
    _sample = dispatch_queue_create("sample", NULL);
    _faceQueue = dispatch_queue_create("face", NULL);
    self->_mt = [FaceMtcnnWrapper sharedSingleton];
    if (_canCa) {
        [self customCamera];
        [self customUI];
        [self FlashOn];
    }else{
        return;
    }
}


#pragma mark - 自定义相机
- (void)customCamera{
    [self.view addSubview: self.cameraView];
    //生成会话，用来结合输入输出
    self.session = [[AVCaptureSession alloc]init];
    //    if ([self.session canSetSessionPreset:AVCaptureSessionPresetPhoto]) {
    //        self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    //    }
    [self.session beginConfiguration];
    if ([self.session canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        [self.session setSessionPreset:AVCaptureSessionPreset640x480];
    }
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    
    if ([self.session canAddOutput:self.mOutput]) {
        [self.session addOutput:self.mOutput];
    }
    [self.session commitConfiguration];
    NSString     *key           = (NSString *)kCVPixelBufferPixelFormatTypeKey;
    NSNumber     *value         = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [self.mOutput setVideoSettings:videoSettings];
    
    
    AVCaptureSession* session = (AVCaptureSession *)self.session;
    //前置摄像头一定要设置一下 要不然画面是镜像
    for (AVCaptureVideoDataOutput* output in session.outputs) {
        for (AVCaptureConnection * av in output.connections) {
            //判断是否是前置摄像头状态
            if (av.supportsVideoMirroring) {
                //镜像设置
                av.videoOrientation = AVCaptureVideoOrientationPortrait;
                av.videoMirrored = YES;
            }
        }
    }
    
    [self.mOutput setSampleBufferDelegate:self queue:self.sample];
    //开始启动
    [self.session startRunning];
    if ([self.device lockForConfiguration:nil]) {
        if ([self.device isFlashModeSupported:AVCaptureFlashModeAuto]) {
            [self.device setFlashMode:AVCaptureFlashModeAuto];
        }
        //        //自动白平衡
        //        if ([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]) {
        //            [self.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
        //        }
        
        [self.device unlockForConfiguration];
    }
    [self focusAtPoint:self.view.center];
}

#pragma mark - 改变图片的大小
-(UIImage *)compressOriginalImage:(UIImage *)image toWidth:(CGFloat)targetWidth
{
    CGSize imageSize = image.size;
    CGFloat Originalwidth = imageSize.width;
    CGFloat Originalheight = imageSize.height;
    CGFloat targetHeight = Originalheight / Originalwidth * targetWidth;
    UIGraphicsBeginImageContext(CGSizeMake(targetWidth, targetHeight));
    [image drawInRect:CGRectMake(0,0,targetWidth,  targetHeight)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark - AVCaptureSession Delegate -
//
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
        NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * fileName=[NSString stringWithFormat:@"%@.jpeg",[MyUtils getNowTimeTimestamp3]];
    NSString *filePath = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileName];
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:filePath atomically:YES];
    UIImage* scareImage=[self compressOriginalImage:image toWidth:360];
    NSString * fileNameScare=[NSString stringWithFormat:@"%@_scare.jpeg",[MyUtils getNowTimeTimestamp3]];
    NSString *filePathScare = [[paths objectAtIndex:0] stringByAppendingPathComponent:fileNameScare];
    [UIImageJPEGRepresentation(scareImage, 1.0) writeToFile:filePathScare atomically:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    NSMutableDictionary * dict=[NSMutableDictionary new];
    dict[@"path"]=filePath;
    dict[@"scare_path"]=filePathScare;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NSNotificationCenter"　object:dict];
}
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    UIImage *image = [self imageFromPixelBuffer:sampleBuffer];
    if (self.takePic) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.session stopRunning];
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
        });
    }else{
        UIImage* img=[self.mt processImage:image];
        if (img==nil) {
            self.cameraView.image = image;
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.cameraView.image = img;
        });
    }
    
}


-(void)createRect: (NSArray <Face *>*)info
{
    UIBezierPath * path1 = [UIBezierPath bezierPath];
    for (Face *face in info) {
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(face.rect.origin.x,face.rect.origin.y,face.rect.size.width,face.rect.size.height)];
        [path1 appendPath:path];
    }
    self.layer.frame = self.view.bounds;
    [self.layer setBackgroundColor:[UIColor clearColor].CGColor];
    [self.layer setContentsRect:CGRectMake(0.0, 0.0, 115.0, 112.0)];
    [self.layer setBorderWidth:2.0];
    [self.layer setBorderColor:[UIColor redColor].CGColor];
    
    [self.layer setPath:[path1 CGPath]];
    
    
    
}

- (UIImageView *)cameraView
{
    if (!_cameraView) {
        _cameraView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _cameraView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _cameraView;
}

- (UIImage*)imageFromPixelBuffer:(CMSampleBufferRef)p {
    CVImageBufferRef buffer;
    buffer = CMSampleBufferGetImageBuffer(p);
    
    CVPixelBufferLockBaseAddress(buffer, 0);
    uint8_t *base;
    size_t width, height, bytesPerRow;
    base = (uint8_t *)CVPixelBufferGetBaseAddress(buffer);
    width = CVPixelBufferGetWidth(buffer);
    height = CVPixelBufferGetHeight(buffer);
    bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);
    
    CGColorSpaceRef colorSpace;
    CGContextRef cgContext;
    colorSpace = CGColorSpaceCreateDeviceRGB();
    cgContext = CGBitmapContextCreate(base, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    
    CGImageRef cgImage;
    UIImage *image;
    cgImage = CGBitmapContextCreateImage(cgContext);
    image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGContextRelease(cgContext);
    
    CVPixelBufferUnlockBaseAddress(buffer, 0);
    return image;
}


#pragma mark - 更改闪光灯状态
-(void)setIsflashOn:(BOOL)isflashOn{
    _isflashOn = isflashOn;
    [[NSUserDefaults standardUserDefaults] setObject:@(_isflashOn) forKey:@"flashMode"];
    if (_isflashOn) {
        [self.flashButton setBackgroundImage:[UIImage imageNamed:@"flash_on"] forState:UIControlStateNormal];
    }else{
        [self.flashButton setBackgroundImage:[UIImage imageNamed:@"flash_off"] forState:UIControlStateNormal];
    }
}
#pragma mark - 上方功能区
-(UIView *)topView{
    if (!_topView ) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 70)];
        _topView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
        [_topView addSubview:self.cancleButton];
        //        [_topView addSubview:self.testButton];
    }
    return _topView;
}
#pragma mark - 取消
-(UIButton *)cancleButton{
    if (_cancleButton == nil) {
        _cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancleButton.frame = CGRectMake(20, 25, 60, 30);
        [_cancleButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancleButton addTarget:self action:@selector(cancle) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _cancleButton ;
}
#pragma mark - 闪光灯
-(UIButton *)flashButton{
    if (_flashButton == nil) {
        _flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _flashButton.frame = CGRectMake((kWidth)/4.0-10, 20, 30, 30);
        [_flashButton addTarget:self action:@selector(FlashOn) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _flashButton;
}
#pragma mark - 切换摄像头
-(UIButton *)changeButton{
    if (_changeButton == nil) {
        _changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _changeButton.frame = CGRectMake(kWidth/4.0*3.0-10, 20, 30, 30);
        [_changeButton setBackgroundImage:[UIImage imageNamed:@"cam"] forState:UIControlStateNormal];
        [_changeButton addTarget:self action:@selector(changeCamera) forControlEvents:UIControlEventTouchUpInside];
    }
    return  _changeButton;
}

#pragma mark - 下方功能区

-(UIView *)bottomView{
    if (!_bottomView) {
        _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kHeight-80, kWidth, 80)];
        _bottomView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.4];
        [_bottomView addSubview:self.PhotoButton];
        [_bottomView addSubview:self.flashButton];
        [_bottomView addSubview:self.changeButton];
    }
    return _bottomView;
}

-(UIButton *)PhotoButton{
    if (_PhotoButton == nil) {
        _PhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _PhotoButton.frame = CGRectMake(kWidth/2.0-30, 10, 60, 60);
        [_PhotoButton setImage:[UIImage imageNamed:@"photograph"] forState: UIControlStateNormal];
        [_PhotoButton setImage:[UIImage imageNamed:@"photograph_Select"] forState:UIControlStateNormal];
        [_PhotoButton addTarget:self action:@selector(shutterCamera) forControlEvents:UIControlEventTouchUpInside];
    }
    return _PhotoButton;
}


-(UIButton *)testButton{
    UIButton *_PhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _PhotoButton.frame = CGRectMake(kWidth/2.0-30, 10, 60, 60);
    [_PhotoButton setImage:[UIImage imageNamed:@"photograph"] forState: UIControlStateNormal];
    [_PhotoButton setImage:[UIImage imageNamed:@"photograph_Select"] forState:UIControlStateNormal];
    [_PhotoButton addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    return _PhotoButton;
}

-(void) test {
    
}


#pragma mark - 对焦区域
-(UIImageView *)focusView{
    if (_focusView == nil) {
        _focusView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
        _focusView.backgroundColor = [UIColor clearColor];
        _focusView.image = [UIImage imageNamed:@"foucs80pt"];
    }
    return _focusView;
}
#pragma mark - 初始化输入
-(AVCaptureDeviceInput *)input{
    if (_input == nil) {
        _input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
    }
    return _input;
}


-(AVCaptureVideoDataOutput *)mOutput{
    if (_mOutput==nil) {
        _mOutput= [[AVCaptureVideoDataOutput alloc] init];
        _mOutput.alwaysDiscardsLateVideoFrames = YES;
    }
    return _mOutput;
}

#pragma mark - 使用AVMediaTypeVideo 指明self.device代表视频，默认使用后置摄像头进行初始化
-(AVCaptureDevice *)device{
    if (_device == nil) {
        _device = [self cameraWithPosition:AVCaptureDevicePositionFront];
        //        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return _device;
}

#pragma mark - 当前视图控制器的初始化
- (instancetype)init
{
    self = [super init];
    if (self) {
        _canCa = [self canUserCamear];
    }
    return self;
}

-(void)setImageblock:(void (^)(NSDictionary *))imageblock{
    _imageblock = imageblock;
}
#pragma mark - 检查相机权限
- (BOOL)canUserCamear{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"请打开相机权限"
                                                           message:@"设置-隐私-相机"
                                                          delegate:self
                                                 cancelButtonTitle:@"确定"
                                                 otherButtonTitles:@"取消", nil];
        alertView.tag = 100;
        [alertView show];
        return NO;
    }
    else{
        return YES;
    }
    return YES;
}

#pragma mark - 自定义视图
- (void)customUI{
    [self.view addSubview:self.topView];
    [self.view addSubview:self.bottomView];
    [self.view addSubview:self.focusView];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(focusGesture:)];
    [self.view addGestureRecognizer:tapGesture];
    
}

#pragma 闪光灯
- (void)FlashOn{
    if ([self.device lockForConfiguration:nil]) {
        if (self.isflashOn) {
            if ([self.device isFlashModeSupported:AVCaptureFlashModeOff]) {
                [self.device setFlashMode:AVCaptureFlashModeOff];
                self.isflashOn = NO;
                //[self.flashButton setTitle:@"关" forState:UIControlStateNormal];
            }
        }else{
            if ([self.device isFlashModeSupported:AVCaptureFlashModeAuto]) {
                [self.device setFlashMode:AVCaptureFlashModeAuto];
                self.isflashOn = YES;
                //[self.flashButton setTitle:@"开" forState:UIControlStateNormal];
            }
        }
        
        [self.device unlockForConfiguration];
    }
}
#pragma mark - 相机切换
- (void)changeCamera{
    NSUInteger cameraCount = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
    if (cameraCount > 1) {
        self.changeButton.userInteractionEnabled = NO;
        NSError *error;
        
        CATransition *animation = [CATransition animation];
        animation.duration = 1;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.type = @"oglFlip";
        animation.delegate = self;
        AVCaptureDevice *newCamera = nil;
        AVCaptureDeviceInput *newInput = nil;
        AVCaptureDevicePosition position = [[self.input device] position];
        if (position == AVCaptureDevicePositionFront){
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            animation.subtype = kCATransitionFromLeft;
            self.cameraPosition = AVCaptureDevicePositionBack;
        }else {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            animation.subtype = kCATransitionFromRight;
            self.cameraPosition = AVCaptureDevicePositionFront;
        }
        
        newInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
        [self.view.layer addAnimation:animation forKey:nil];
        [self.cameraView addSubview:self.effectView];
        [self.view insertSubview:self.cameraView belowSubview:self.topView];
        if (newInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:self.input];
            if ([self.session canAddInput:newInput]) {
                [self.session addInput:newInput];
                self.input = newInput;
                
            } else {
                [self.session addInput:self.input];
            }
            for (AVCaptureVideoDataOutput* output in self.session.outputs) {
                for (AVCaptureConnection * av in output.connections) {
                    if (av.supportsVideoMirroring) {
                        av.videoOrientation = AVCaptureVideoOrientationPortrait;
                        if (self.cameraPosition == AVCaptureDevicePositionFront) {
                            av.videoMirrored = YES;
                        }
                    }
                }
            }
            [self.session commitConfiguration];
            
        } else if (error) {
            NSLog(@"toggle carema failed, error = %@", error);
        }
    }
}
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
        if ( device.position == position ) return device;
    return nil;
}
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    self.changeButton.userInteractionEnabled = YES;
    [self.effectView removeFromSuperview];
    if (self.cameraPosition == AVCaptureDevicePositionFront) {
        self.flashButton.alpha = 0;
    }else if (self.cameraPosition == AVCaptureDevicePositionBack){
        self.flashButton.alpha = 1;
    }
    [self.session startRunning];
}

#pragma mark - 聚焦
- (void)focusGesture:(UITapGestureRecognizer*)gesture{
    CGPoint point = [gesture locationInView:gesture.view];
    [self focusAtPoint:point];
}
- (void)focusAtPoint:(CGPoint)point{
    CGSize size = self.view.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.device setExposurePointOfInterest:focusPoint];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        [self.device unlockForConfiguration];
        self.focusView.center = point;
        
        //[self startFocusAnimation];
        self.focusView.alpha = 1;
        [UIView animateWithDuration:0.2 animations:^{
            self.focusView.transform = CGAffineTransformMakeScale(1.25f, 1.25f);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                self.focusView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
            } completion:^(BOOL finished) {
                [self hiddenFocusAnimation];
            }];
        }];
    }
    
}
#pragma mark - 拍照
- (void)shutterCamera
{
    self.takePic=true;
    
}


#pragma mark - 取消 返回上级
-(void)cancle{
    NSLog(@"取消");
    [self.session stopRunning];
    [self dismissViewControllerAnimated:YES completion:nil];
    NSMutableDictionary* dict=[NSMutableDictionary new];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NSNotificationCenter"　object:dict];
}
//#pragma - 保存至相册
//- (void)saveImageToPhotoAlbum:(UIImage*)savedImage
//    {
//        /// 此方法有自动回调 请注意
//        UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
//
//    }
//
//    /// 保存照片完成之后的回调方法
//- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo{
//    if(error != NULL){
//        NSLog(@"errro  %@",error);
//
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
//                                                        message:@"保存图片失败"
//                                                       delegate:self
//                                              cancelButtonTitle:@"确定"
//                                              otherButtonTitles:nil];
//        [alert show];
//    }else{
//         NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
//    }
//}

#pragma - 聚焦相关动画
/// 聚焦完成
- (void)focusDidFinsh{
    self.focusView.hidden = YES;
    self.focusView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    //self.focusView.transform=CGAffineTransformMakeScale(0.7f, 0.7f);
}
/// 开始聚焦动画
- (void)startFocusAnimation{
    self.focusView.hidden = NO;
    self.focusView.transform = CGAffineTransformMakeScale(1.25f, 1.25f);//将要显示的view按照正常比例显示出来
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    //[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];  //InOut 表示进入和出去时都启动动画
    //[UIView setAnimationWillStartSelector:@selector(hiddenFoucsView)];
    [UIView setAnimationDidStopSelector:@selector(hiddenFocusAnimation)];
    [UIView setAnimationDuration:0.5f];//动画时间
    self.focusView.transform = CGAffineTransformIdentity;//先让要显示的view最小直至消失
    [UIView commitAnimations]; //启动动画
    //相反如果想要从小到大的显示效果，则将比例调换
    
}
/// 聚焦完成后隐藏聚焦框
- (void)hiddenFocusAnimation{
    [UIView beginAnimations:nil context:UIGraphicsGetCurrentContext()];
    //NSDate *DATE = [NSDate date];
    //[UIView setAnimationStartDate:[NSDate date]];
    [UIView setAnimationDelay:3];
    self.focusView.alpha = 0;
    [UIView setAnimationDuration:0.5f];//动画时间
    [UIView commitAnimations];
    
}
/// 聚焦完成后隐藏聚焦框
- (void)hiddenFoucsView{
    self.focusView.alpha = !self.focusView.alpha;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

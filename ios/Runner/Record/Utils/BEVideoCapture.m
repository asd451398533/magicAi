// Copyright (C) 2018 Beijing Bytedance Network Technology Co., Ltd.
#import "BEVideoCapture.h"

#import <UIKit/UIKit.h>

#import "BEStudioConstants.h"
#import "BEMacro.h"

@interface BEVideoCapture()<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, readwrite) AVCaptureDevicePosition devicePosition; // default AVCaptureDevicePositionFront
@property (nonatomic, strong) AVCaptureDeviceInput * deviceInput;
@property (nonatomic, strong) AVCaptureVideoDataOutput * dataOutput;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) dispatch_queue_t bufferQueue;
@property (nonatomic, assign) BOOL isPaused;
@property (nonatomic, assign) BOOL isFlipped;
@property (nonatomic, assign) AVCaptureVideoOrientation videoOrientation;
@property (nonatomic, strong) NSMutableArray *observerArray;
@property (nonatomic, strong) AVCaptureMetadataOutput *metaDataOutput;

@end

@implementation BEVideoCapture

@synthesize delegate = _delegate;
@synthesize metadelegate = _metadelegate;
@synthesize devicePosition = _devicePosition;
@synthesize sessionPreset = _sessionPreset;
@synthesize isOutputWithYUV = _isOutputWithYUV;

#pragma mark - Lifetime
- (instancetype)init {
    self = [super init];
    if (self) {
        self.isPaused = YES;
        self.isFlipped = YES;
        self.videoOrientation = AVCaptureVideoOrientationPortrait;
        [self _setupCaptureSession];
        self.observerArray = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    if (!_session) {
        return;
    }
    _isPaused = YES;
    [_session beginConfiguration];
    [_session removeOutput:_dataOutput];
    [_session removeInput:_deviceInput];
    [_session commitConfiguration];
    if ([_session isRunning]) {
        [_session stopRunning];
    }
    _session = nil;
    for (id observer in self.observerArray) {
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }
}

#pragma mark - Public
- (void)startRunning {
    if (!(_dataOutput || _metaDataOutput)) {
        return;
    }
    if (_session && ![_session isRunning]) {
        [_session startRunning];
        _isPaused = NO;
    }
}

- (void)stopRunning {
    if (_session && [_session isRunning]) {
        [_session stopRunning];
        _isPaused = YES;
    }
}

- (void)pause {
    _isPaused = true;
}

- (void)resume {
    _isPaused = false;
}

- (void)switchCamera {
    if (_session == nil) {
        return;
    }
    AVCaptureDevicePosition targetPosition = _devicePosition == AVCaptureDevicePositionFront ? AVCaptureDevicePositionBack: AVCaptureDevicePositionFront;
    
    [self switchCamera:targetPosition];
}

- (void)switchCamera:(AVCaptureDevicePosition)targetPosition {
    if (_devicePosition == targetPosition) {
        return;
    }
    
    AVCaptureDevice *targetDevice = [self _cameraDeviceWithPosition:targetPosition];
    if (targetDevice == nil) {
        return;
    }
    NSError *error = nil;
    AVCaptureDeviceInput *deviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:targetDevice error:&error];
    if(!deviceInput || error) {
        [self _throwError:VideoCaptureErrorFailedCreateInput];
        NSLog(@"Error creating capture device input: %@", error.localizedDescription);
        return;
    }
    [self pause];
    [_session beginConfiguration];
    [_session removeInput:_deviceInput];
    if ([_session canAddInput:deviceInput]) {
        [_session addInput:deviceInput];
        _deviceInput = deviceInput;
        _device = targetDevice;
        _devicePosition = targetPosition;
        
        [self setOrientation:_videoOrientation];
        [self setFlip:targetPosition == AVCaptureDevicePositionFront ? YES : NO];
        
    }
    [_session commitConfiguration];
    [self resume];
}

- (void)setFlip:(BOOL)isFlip {
    if (_session == nil || _dataOutput == nil) {
        return;
    }
    AVCaptureConnection *videoConnection = [_dataOutput connectionWithMediaType:AVMediaTypeVideo];
    if (videoConnection) {
        if ([videoConnection isVideoMirroringSupported]) {
            [videoConnection setVideoMirrored:isFlip];
            _isFlipped = isFlip;
        }
    }
}

- (void)setOrientation:(AVCaptureVideoOrientation)orientation {
    if (_session == nil || _dataOutput == nil) {
        return;
    }
    AVCaptureConnection *videoConnection = [_dataOutput connectionWithMediaType:AVMediaTypeVideo];
    if (videoConnection) {
        if ([videoConnection isVideoOrientationSupported]) {
            [videoConnection setVideoOrientation:orientation];
            _videoOrientation = orientation;
        }
    }
}

- (CGFloat)maxBias {
    return 1.58;
}

- (CGFloat)minBias {
    return -1.38;
}

- (CGFloat)ratio {
    return [self maxBias] - [self minBias];
}

- (void)setExposure:(float)exposure {
    if (_device == nil) return ;
    
    NSError *error;
   
    //syn exposureTargetBias logic
    CGFloat bias = [self maxBias] - exposure * [self ratio];
    bias = MIN(MAX(bias, [self minBias]), [self maxBias]);
    
    [_device lockForConfiguration:&error];
    [_device setExposureTargetBias:bias completionHandler:nil];
    
    if ([_device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]){
        [_device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    
    [_device unlockForConfiguration];
    [_session commitConfiguration];
}

- (void) setExposurePointOfInterest:(CGPoint) point{
    if (_device == nil) return ;
    
    [_device lockForConfiguration:nil];
    if ([_device isExposurePointOfInterestSupported]) {
        [_device setExposurePointOfInterest:point];
    }
    
    if ([_device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]){
        [_device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    
    [_device unlockForConfiguration];
}

- (void) setFocusPointOfInterest:(CGPoint) point{
    if (_device == nil)  return ;
    
    [_device lockForConfiguration:nil];
    
    if ([_device isFocusPointOfInterestSupported])
        [_device setFocusPointOfInterest:point];
    
    if ([_device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]){
        [_device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    }
    
    [_device unlockForConfiguration];
}

- (void)resetImage:(UIImage *)image {
    NSLog(@"not support function");
}

#pragma mark - Private
- (void)_requestCameraAuthorization:(void (^)(BOOL granted))handler {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            handler(granted);
        }];
    } else if (authStatus == AVAuthorizationStatusAuthorized) {
        handler(true);
    } else {
        handler(false);
    }
}

// request for authorization first
- (void)_setupCaptureSession {
    [self _requestCameraAuthorization:^(BOOL granted) {
        if (granted) {
            [self __setupCaptureSession];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:BEEffectCameraDidAuthorizationNotification object:nil userInfo:nil];
        } else {
            [self _throwError:VideoCaptureErrorAuthNotGranted];
        }
    }];
}

- (void)__setupCaptureSession {
    _session = [[AVCaptureSession alloc] init];
    [_session beginConfiguration];
    
    if ([_session canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        [_session setSessionPreset:AVCaptureSessionPreset1280x720];
        _sessionPreset = AVCaptureSessionPreset1280x720;
    } else {
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        _sessionPreset = AVCaptureSessionPresetHigh;
    }
    [_session commitConfiguration];
    _device = [self _cameraDeviceWithPosition:AVCaptureDevicePositionFront];
    [self _setCameraParaments];
    [self setExposure:0.5];
    
    _devicePosition = AVCaptureDevicePositionFront;
    _bufferQueue = dispatch_queue_create("HTSCameraBufferQueue", NULL);
    
    // Input
    NSError *error = nil;
    _deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (!_deviceInput) {
        [_delegate videoCapture:self didFailedToStartWithError:VideoCaptureErrorFailedCreateInput];
        return;
    }
    
    // Output
    int iCVPixelFormatType = _isOutputWithYUV ? kCVPixelFormatType_420YpCbCr8BiPlanarFullRange : kCVPixelFormatType_32BGRA;
    _dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [_dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [_dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:iCVPixelFormatType] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    [_dataOutput setSampleBufferDelegate:self queue:_bufferQueue];
    
    [_session beginConfiguration];
    if ([_session canAddOutput:_dataOutput]) {
        [_session addOutput:_dataOutput];
    } else {
        [self _throwError:VideoCaptureErrorFailedAddDataOutput];
        NSLog( @"Could not add video data output to the session" );
    }
    if ([_session canAddInput:_deviceInput]) {
        [_session addInput:_deviceInput];
    }else{
        [self _throwError:VideoCaptureErrorFailedAddDeviceInput];
        NSLog( @"Could not add device input to the session" );
    }
    
    //支持人脸检测，取得人脸框信息测光用
    _metaDataOutput = [[AVCaptureMetadataOutput alloc] init];
    if ([_session canAddOutput:_metaDataOutput]) {
        [_session addOutput:_metaDataOutput];

        //指定对象输出的元数据类型，AV Foundation支持多种类型 这里限制使用人脸元数据
        NSArray *metadataObjectTypes = @[AVMetadataObjectTypeFace];
        _metaDataOutput.metadataObjectTypes = metadataObjectTypes;

        //人脸检测用到的硬件加速，而且许多重要的任务都在主线程，一般指定主线程
        dispatch_queue_t mainQueue = dispatch_get_main_queue();
        //指定AVCaptureMetadataOutputObjectsDelegate
        [_metaDataOutput setMetadataObjectsDelegate:self  queue:mainQueue];
    }
    
    [_session commitConfiguration];
    
    
    [self setFlip:_isFlipped];
    [self setOrientation:_videoOrientation];
    
    [self registerNotification];
    [self startRunning];
}

- (void)_setCameraParaments {
    [_device lockForConfiguration:nil];
    
    //设置自动对焦
    if ([_device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]){
        [_device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    }
    
    //设置自动曝光
    if ([_device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]){
        [_device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    
    //设置曝光补偿的值
//    [_device setExposureTargetBias:0.98 completionHandler:nil];

    [_device unlockForConfiguration];
}


- (void)registerNotification
{
    __weak typeof(self) weakSelf = self;
    [self.observerArray addObject:[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf startRunning];
    }]];
    
    [self.observerArray addObject:[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf stopRunning];
    }]];
}

- (void)_throwError:(VideoCaptureError)error {
    if (_delegate && [_delegate respondsToSelector:@selector(videoCapture:didFailedToStartWithError:)]) {
        [_delegate videoCapture:self didFailedToStartWithError:error];
    }
}

- (AVCaptureDevice *)_cameraDeviceWithPosition:(AVCaptureDevicePosition)position {
    AVCaptureDevice *deviceRet = nil;
    if (position != AVCaptureDevicePositionUnspecified) {
        NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
        for (AVCaptureDevice *device in devices) {
            if ([device position] == position) {
                deviceRet = device;
            }
        }
    }
    return deviceRet;
}

#pragma mark - Util

- (CGSize)videoSize {
    if (_dataOutput.videoSettings) {
        CGFloat width = [[_dataOutput.videoSettings objectForKey:@"Width"] floatValue];
        CGFloat height = [[_dataOutput.videoSettings objectForKey:@"Height"] floatValue];
        return CGSizeMake(width, height);
    }
    return CGSizeZero;
}

- (CGRect)getZoomedRectWithRect:(CGRect)rect scaleToFit:(BOOL)scaleToFit {
    CGRect rectRet = rect;
    if (_dataOutput.videoSettings) {
        CGFloat width = [[_dataOutput.videoSettings objectForKey:@"Width"] floatValue];
        CGFloat height = [[_dataOutput.videoSettings objectForKey:@"Height"] floatValue];
        CGFloat scaleX = width / CGRectGetWidth(rect);
        CGFloat scaleY = height / CGRectGetHeight(rect);
        CGFloat scale = scaleToFit ? fmaxf(scaleX, scaleY) : fminf(scaleX, scaleY);
        width = round(width / scale);
        height = round(height / scale);
//        CGFloat x = rect.origin.x - (width - rect.size.width) / 2.0f;
//        CGFloat y = rect.origin.y - (height - rect.size.height) / 2.0f;
        rectRet = CGRectMake(0, 0, width, height);
    }
    return rectRet;
}

#pragma mark - AVCaptureAudioDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    if (!_isPaused) {
        if (_delegate && [_delegate respondsToSelector:@selector(videoCapture:didOutputSampleBuffer:)]) {
            [_delegate videoCapture:self didOutputSampleBuffer:sampleBuffer];
        }
    }
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{

    //将人脸数据传给委托对象

    if (!_isPaused) {
        if (_metadelegate && [_metadelegate respondsToSelector:@selector(captureOutput:didOutputMetadataObjects:)]) {
            [_metadelegate captureOutput:self didOutputMetadataObjects:metadataObjects];
        }
    }
    
}

#pragma mark - getter && setter

- (void)setSessionPreset:(NSString *)sessionPreset {
    if ([sessionPreset isEqualToString:_sessionPreset]) {
        return;
    }
    if (!_session) {
        return;
    }
    [self pause];
    [_session beginConfiguration];
    if ([_session canSetSessionPreset:sessionPreset]) {
        [_session setSessionPreset:sessionPreset];
        _sessionPreset = sessionPreset;
    }
    [self.session commitConfiguration];
    [self resume];
}

- (void)setIsOutputWithYUV:(BOOL)isOutputWithYUV {
    if (_isOutputWithYUV == isOutputWithYUV) {
        return;
    }
    _isOutputWithYUV = isOutputWithYUV;
    int iCVPixelFormatType = _isOutputWithYUV ? kCVPixelFormatType_420YpCbCr8BiPlanarFullRange : kCVPixelFormatType_32BGRA;
    AVCaptureVideoDataOutput *dataOutput = [[AVCaptureVideoDataOutput alloc] init];
    [dataOutput setAlwaysDiscardsLateVideoFrames:YES];
    [dataOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:iCVPixelFormatType] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
    [dataOutput setSampleBufferDelegate:self queue:_bufferQueue];
    [self pause];
    [_session beginConfiguration];
    [_session removeOutput:_dataOutput];
    if ([_session canAddOutput:dataOutput]) {
        [_session addOutput:dataOutput];
        _dataOutput = dataOutput;
    }else{
        [self _throwError:VideoCaptureErrorFailedAddDataOutput];
        NSLog(@"session add data output failed when change output buffer pixel format.");
    }
    [_session commitConfiguration];
    [self resume];
    /// make the buffer portrait
    [self setOrientation:_videoOrientation];
    [self setFlip:_isFlipped];
}


- (void)coverToMetadataOutputRectOfInterestForRect:(CGRect)cropRect {
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = 0.0;
    
    if ([_session.sessionPreset isEqualToString:AVCaptureSessionPreset1280x720]) {
        p2 = 1280./720.;
    }
    else if ([_session.sessionPreset isEqualToString:AVCaptureSessionPreset640x480]) {
        p2 = 640./480.;
    }

    if (p1 < p2) {
        CGFloat fixHeight = size.width * p2;
        CGFloat fixPadding = (fixHeight - size.height)/2;
        _metaDataOutput.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                                    (size.width-(cropRect.size.width+cropRect.origin.x))/size.width,
                                                    cropRect.size.height/fixHeight,
                                                    cropRect.size.width/size.width);
    } else {
        CGFloat fixWidth = size.height * (1/p2);
        CGFloat fixPadding = (fixWidth - size.width)/2;
        _metaDataOutput.rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                                    (size.width-(cropRect.size.width+cropRect.origin.x)+fixPadding)/fixWidth,
                                                    cropRect.size.height/size.height,
                                                    cropRect.size.width/fixWidth);
    }
}

@end


@interface BEImageCapture() {
    unsigned char           *_imageBuffer;
    int                      _width;
    int                      _height;
    int                      _bytesPerRow;
    
    dispatch_queue_t        _queue;
    NSTimer                 *_timer;
    BOOL                     _resumed;
}

@end

@implementation BEImageCapture

@synthesize delegate = _delegate;

- (void)dealloc {
    if (_imageBuffer) {
        free(_imageBuffer);
    }
}

- (instancetype)initWithImage:(UIImage *)image {
    if (self = [super init]) {
        _queue = dispatch_queue_create("image capture", DISPATCH_QUEUE_SERIAL);
        [self resetImage:image];
    }
    return self;
}

- (void)resetImage:(UIImage *)image {
    if (_imageBuffer) {
        free(_imageBuffer);
    }
    _width = (int)CGImageGetWidth(image.CGImage);
    _height = (int)CGImageGetHeight(image.CGImage);
    _bytesPerRow = 4 * _width;
    _imageBuffer = (unsigned char *)malloc(_width * _height * 4);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(_imageBuffer, _width, _height,
                                                 bitsPerComponent, _bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);

    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, _width, _height), image.CGImage);
    CGContextRelease(context);
}

- (void)startRunning {
    _resumed = YES;
    if (_timer && _timer.isValid) {
        return;
    }
    [self be_releaseTimer];
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(be_timeRun:) userInfo:nil repeats:YES];
}

- (void)stopRunning {
    _resumed = NO;
    [self be_releaseTimer];
}

- (void)resume {
    _resumed = YES;
}

- (void)pause {
    _resumed = NO;
}

- (CGRect)getZoomedRectWithRect:(CGRect)rect scaleToFit:(BOOL)scaleToFit {
    return CGRectMake(0, 0, _width, _height);
}

- (void)setExposure:(float)exposure {
    NSLog(@"not support function");
}


- (void)setExposurePointOfInterest:(CGPoint)point {
    NSLog(@"not support function");
}


- (void)setFlip:(BOOL)isFlip {
    NSLog(@"not support function");
}


- (void)setFocusPointOfInterest:(CGPoint)point {
    NSLog(@"not support function");
}


- (void)setOrientation:(AVCaptureVideoOrientation)orientation {
    NSLog(@"not support function");
}


- (void)switchCamera {
    NSLog(@"not support function");
}


- (void)switchCamera:(AVCaptureDevicePosition)position {
    NSLog(@"not support function");
}

- (CGSize)videoSize {
    return CGSizeMake(_width, _height);
}

#pragma mark - private

- (void)be_timeRun:(NSTimer *)timer {
    if (_resumed) {
        dispatch_async(_queue, ^{
            [_delegate videoCapture:self didOutputBuffer:_imageBuffer width:_width height:_height bytesPerRow:_bytesPerRow timeStamp:[[NSDate date] timeIntervalSince1970]];
        });
    }
}

- (void)be_releaseTimer {
    if (_timer && _timer.isValid) {
        [_timer invalidate];
        _timer = nil;
    }
}

@synthesize devicePosition;

@synthesize isOutputWithYUV;

@synthesize metadelegate;

@synthesize sessionPreset;

@end

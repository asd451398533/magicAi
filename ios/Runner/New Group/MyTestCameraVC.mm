//
//  MyTestCameraVC.m
//  Runner
//
//  Created by Apple on 2020/1/6.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyTestCameraVC.h"
#import <Flutter/Flutter.h>

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
#import "STCommonObjectContainerView.h"
#import "TestModel.h"
#import "bef_effect_ai_face_detect.h"
#include "GeneratedPluginRegistrant.h"
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface MyTestCameraVC()<BECaptureDelegate,BEVideoCaptureDelegate,BECameraContainerViewDelegate
,STCommonObjectContainerViewDelegate,FlutterStreamHandler>
{
    BEFrameProcessor *_processor;
    BOOL             _hasObserver;
    BOOL             _resumed;
}
@property (nonatomic, copy) AVCaptureSessionPreset captureSessionPreset;
@property (nonatomic, strong) BEGLView *glView;
@property (nonatomic, strong) id<BEVideoCaptureProtocol> capture;
@property (nonatomic, assign) BOOL imageMode;
@property (nonatomic, strong) BECameraContainerView *cameraContainerView;
@property (nonatomic, assign) int orientation;
@property (nonatomic, assign) BOOL touchExposureEnable;
@property (nonatomic, strong) UIButton *btnSwitchCamera;
@property (nonatomic, strong) UIButton* saveButton;
@property(nonatomic)int outputStep;
@property (nonatomic,strong)NSMutableArray<TestModel*> *dataArry;

@property(retain,nonatomic) UIScrollView* scrollView;
@property (nonatomic, readwrite, strong) STCommonObjectContainerView *commonObjectContainerView;
@property (nonatomic, readwrite, strong) UIButton *btnCompare;

@property (nonatomic,strong) UIVisualEffectView *effectView;
@property(nonatomic)int picCount;
@property(nonatomic)FlutterViewController*flutterController;
@property(nonatomic)UIButton*closeFlutterBtn;
@property(nonatomic)UIButton*backButton;
@property(nonatomic)FlutterEventSink sink;
@property(nonatomic)FlutterEventChannel* chargingChannel;
@property(nonatomic)NSMutableArray<NSNumber *>*stepArr;
@property(nonatomic)int nowStep;
@property(nonatomic)NSMutableArray * recordArray;
@property(nonatomic) BOOL willAppearClose;
@property(nonatomic)NSMutableArray* itemArray;
@property(nonatomic)float nowProgress;
@end

@implementation MyTestCameraVC

- (void)loadView {
    [super loadView];
    self.dataArry=TestModel.getDemoData;
    if(self.dataArry[self.now_index]){
        if(self.dataArry[self.now_index].map
           &&self.dataArry[self.now_index].map[self.face]
           &&self.dataArry[self.now_index].map[self.face][self.eye]){
            self.itemArray=self.dataArry[self.now_index].map[self.face][self.eye];
        }else{
            self.itemArray=self.dataArry[self.now_index].arr;
        }
    }
    NSLog(@" LOG %@ %@ ",self.face,self.eye);
    
    self.stepArr=[NSMutableArray new];
    self.recordArray=[NSMutableArray new];
    if(self.imageMode){
        if(MAX(self.image.size.width, self.image.size.height)>4096){
            self.image=[self scaleImage:self.image toScale:(3096/MAX(self.image.size.width, self.image.size.height))];
        }
    }
    
    self.willAppearClose=NO;
    self.imageMode=NO;
    self.outputStep=0;
    self.picCount=0;
    self.nowProgress=1.0;
    _captureSessionPreset = AVCaptureSessionPreset1280x720;
    [self be_createSdk];
    [self be_initData];
    [self be_createCamera];
    [self be_ui];
    if(!self.imageMode){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backValue:) name:@"backValue" object:nil];
    }
    
    
    //TODO
    self.nowStep=0;
    [self.stepArr addObject:[NSNumber numberWithFloat:1.0]];
}


-(void) backValue:(NSNotification *)text{
    if(text.object==nil){
        self.willAppearClose=NO;
    }else{
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        self.willAppearClose=YES;
    }
}

- (void)be_ui{
    UIBlurEffect * effect=[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    _effectView.frame = UIScreen.mainScreen.bounds;
    _effectView.hidden=true;
    [self.view addSubview:_effectView];
    self.cameraContainerView = [[BECameraContainerView alloc] initWithFrame:self.view.bounds imageMode:self.imageMode];
    self.cameraContainerView.delegate = self;
    
    self.cameraContainerView.textView.text=[NSString stringWithFormat:@"%@-%@",self.face,self.eye];
    [self.view addSubview:self.cameraContainerView];
    [self.cameraContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.commonObjectContainerView = [[STCommonObjectContainerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.commonObjectContainerView.delegate = self;
    [self.view insertSubview:self.commonObjectContainerView atIndex:1];
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.frame = CGRectMake(0, SCREEN_HEIGHT-60, SCREEN_WIDTH, 50);
    _scrollView.contentSize = CGSizeMake(70 * TestModel.getDemoData.count+10, 50);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    for(int i = 0; i < TestModel.getDemoData.count; i++) {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button.layer setCornerRadius:10.0];
        button.frame = CGRectMake(i*70+10, 0, 60, 50);
        [button setTitle:[self.dataArry[i] name] forState:UIControlStateNormal];
        if(!self.imageMode&&i==0){
            button.backgroundColor = [UIColor redColor];
            
        }else if(self.imageMode&&i==self.now_index){
            button.backgroundColor = [UIColor redColor];
        }else{
            button.backgroundColor = [UIColor orangeColor];
        }
        [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i+100;
        [_scrollView addSubview:button];
        
    }
    [self.view addSubview:_scrollView];
    [self.view addSubview:self.btnCompare];
    
    
    if(self.imageMode){
        self.backButton=[UIButton buttonWithType:UIButtonTypeCustom];
        [self.backButton addTarget:self action:@selector(closeFlutter:) forControlEvents:UIControlEventTouchUpInside];
        [self.backButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        self.backButton.frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        [self.view addSubview:self.backButton];
        self.backButton.hidden=YES;
        FlutterViewController* vc= [[FlutterViewController alloc] init];
        [GeneratedPluginRegistrant registerWithRegistry:vc.pluginRegistry];
        [vc setInitialRoute:@"answer"];
        [self.view addSubview:vc.view];
        vc.view.frame = CGRectMake(0, SCREEN_HEIGHT/6, SCREEN_WIDTH, SCREEN_HEIGHT/6*5);
        self.flutterController=vc;
        self.flutterController.view.hidden=YES;
        self.closeFlutterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.closeFlutterBtn addTarget:self action:@selector(closeFlutter:) forControlEvents:UIControlEventTouchUpInside];
        UIImage* image = [UIImage imageNamed:@"ic_close.png"];
        [self.closeFlutterBtn setImage:image forState:UIControlStateNormal];
        self.closeFlutterBtn.frame=CGRectMake(0, SCREEN_HEIGHT/6, 30, 30);
        self.closeFlutterBtn.hidden=YES;
        [self.view addSubview:self.closeFlutterBtn];
        self.chargingChannel = [FlutterEventChannel
                                eventChannelWithName:@"answerChannel"
                                binaryMessenger:vc.binaryMessenger];
    }
    NSMutableArray<NSString*> *paths=[NSMutableArray new];
    [paths addObject:@"/reshape"];
    [paths addObject:@"/beauty_4Items"];
    //    [paths addObject:@"/beauty_IOS"];
    [_processor updateComposerNodes:paths];
    if(self.image){
        [self setParams];
    }
    
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

- (void)viewDidLoad {
    
}

-(void)dealloc{
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(self.willAppearClose){
        NSLog(@"viewWILL APP  TrUe");
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    if(self.chargingChannel){
        [self.chargingChannel setStreamHandler:self];
    }
    _effectView.hidden=YES;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    _resumed = YES;
    if (_capture) {
        [_capture startRunning];
    }
    [_processor setEffectOn:YES];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if(self.chargingChannel){
        [self.chargingChannel setStreamHandler:nil];
    }
    _resumed = NO;
    if (_capture) {
        [_capture stopRunning];
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

#pragma mark - BECaptureDelegate
- (void)onImageCapture:(UIImage *)image {
    if(self.imageMode){
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void*)self);
    }else{
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSString *tempPathBefore = NSTemporaryDirectory();
            NSFileManager *manager = [NSFileManager defaultManager];
            NSString *tempPath = [tempPathBefore stringByAppendingPathComponent:@"REALPATH"];
            [manager createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString* tempTake1= [tempPath stringByAppendingPathComponent:[self createCUID:@"gengmei_"]];
            NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
            [imageData writeToFile:tempTake1 atomically:YES];
            MyTestCameraVC*vc=[MyTestCameraVC new];
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            vc.image=image;
            vc.oriPath=tempTake1;
            vc.face=self.face;
            vc.eye=self.eye;
            vc.now_index=self.now_index;
            vc.eng=self.flutterController.engine;
            [self presentViewController:vc animated:YES completion:nil];
        });
    }
    
}

- (void)image:(UIImage*)image didFinishSavingWithError:(NSError*)error contextInfo:(void *)contextInfo{
    if(error) {
        NSLog(@"fail to save photo");
        [self.view.window makeToast:@"保存失败" duration:(NSTimeInterval)(3.0) position:CSToastPositionCenter];
    } else {
        if(self.oriPath){
            NSString *tempPathBefore = NSTemporaryDirectory();
            NSFileManager *manager = [NSFileManager defaultManager];
            NSString *tempPath = [tempPathBefore stringByAppendingPathComponent:@"REALPATH"];
            [manager createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSString* tempTake1= [tempPath stringByAppendingPathComponent:[self createCUID:@"gengmei_"]];
            NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
            [imageData writeToFile:tempTake1 atomically:YES];
            NSMutableDictionary * dict=[NSMutableDictionary new];
            [dict setObject:self.oriPath forKey:@"oriPath"];
            [dict setObject:tempTake1 forKey:@"newPath"];
            [dict setObject:[self.dataArry[self.now_index] name] forKey:@"INDEX"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"backValue" object:dict];
            [self dismissViewControllerAnimated:NO completion:nil];
        }else{
            [self.view.window makeToast:@"保存成功!" duration:(NSTimeInterval)(3.0) position:CSToastPositionCenter];
        }
        
        
    }
    //    if (self.imageMode) {
    //        [self dismissViewControllerAnimated:YES completion:nil];
    //    }
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


-(void)touchesBegan:(NSSet*)touches withEvent:(UIEvent *)event {
    
    UITouch * touch = [[event allTouches] anyObject];
    CGPoint loc = [touch locationInView:self.view];
    if(!_touchExposureEnable )
    {
        _touchExposureEnable = YES;
    }
    
    CGRect bouns =  self.view.bounds;
    CGPoint point = CGPointMake(loc.x / bouns.size.width, loc.y / bouns.size.height);
    [_capture setExposurePointOfInterest:point];
    [_capture setFocusPointOfInterest:point];
    
}

- (void) onSwitchCameraClicked:(UIButton *) sender {
    sender.enabled = NO;
    [self.capture switchCamera];
    sender.enabled = YES;
}

- (void)onSaveButtonClicked:(UIButton*)sender{
    self.effectView.hidden=false;
    [_processor setEffectOn:NO];
    [self performSelector:@selector(delayMethod) withObject:nil/*可传任意类型参数*/ afterDelay:0.3];
    
}
-(void)delayMethod {
    //    [_capture stopRunning];
    _processor.captureNextFrame = YES;
}
- (void)onCloseClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)BEFrameProcessor:(BEFrameProcessor *)processor didDetectFaceInfo:(bef_ai_face_info)faceInfo{
    int count = faceInfo.face_count;
    //    NSLog(@"FACE CIYBNt %i  %f %f",count,faceInfo.base_infos[0].points_array[0].x,faceInfo.base_infos[0].points_array[0].y);
    if(self.imageMode){
        return;
    }
    NSMutableArray * arrayFace = [NSMutableArray array];
    for (int j = 0; j < 106; ++j) {
        [arrayFace addObject:@{
            POINT_KEY: [NSValue valueWithCGPoint:CGPointMake(faceInfo.base_infos[0].points_array[j].x,faceInfo.base_infos[0].points_array[j].y)]
        }];
    }
    if(self.commonObjectContainerView){
        if(count==1){
            self.outputStep++;
            self.commonObjectContainerView.step=self.outputStep;
        }
        self.commonObjectContainerView.stepCount=120;
        self.commonObjectContainerView.faceArray = arrayFace;
        [self.commonObjectContainerView setNeedsDisplay];
    }
}


- (void)commonSetBuity:(float)progress :(NSString *)what{
    if(progress>0.9){
        progress=1.0;
    }
    NSLog(@"progress %f",progress);
    if([what isEqualToString:@"rz"]){
        [self setParamsPrivate:BETypeBeautyReshapeEyeMove :[self.itemArray[14] floatValue]*progress*self.nowProgress];
    }else if([what isEqualToString:@"eye"]){
        [self setParamsPrivate:BETypeBeautyReshapeEye :[self.itemArray[3] floatValue]*progress*self.nowProgress];
    }else if([what isEqualToString:@"nose"]){
        [self setParamsPrivate:BETypeBeautyReshapeNoseLean :[self.itemArray[7] floatValue]*progress*self.nowProgress];
    }
    else if([what isEqualToString:@"lip"]){
        [self setParamsPrivate:BETypeBeautyReshapeMouthZoom :[self.itemArray[11] floatValue]*progress*self.nowProgress];
    }
    else if([what isEqualToString:@"xb"]){
        [self setParamsPrivate:BETypeBeautyReshapeChin :[self.itemArray[9] floatValue]*progress*self.nowProgress];
    }
    else if([what isEqualToString:@"face"]){
        [self setParamsPrivate:BETypeBeautyReshapeFaceOverall :[self.itemArray[0] floatValue]*progress*self.nowProgress];
    }
}

#pragma mark - getter
- (BOOL)imageMode {
    return _image != nil;
}

-(void) clickButton:(UIButton*) btn {
    for(int i = 0; i < self.dataArry.count; i++) {
        UIButton * item=[_scrollView viewWithTag:100+i];
        [item setBackgroundColor:[UIColor orangeColor]];
    }
    UIButton * item=[_scrollView viewWithTag:btn.tag];
    self.now_index=btn.tag-100;
    if(self.dataArry[self.now_index].map
       &&self.dataArry[self.now_index].map[self.face]
       &&self.dataArry[self.now_index].map[self.face][self.eye]){
        self.itemArray=self.dataArry[self.now_index].map[self.face][self.eye];
    }else{
        self.itemArray=self.dataArry[self.now_index].arr;
    }
    if([self.recordArray containsObject:[self.dataArry[self.now_index] name]]){
        self.outputStep=2000;
    }else{
        self.outputStep=0;
        [self.recordArray addObject:[self.dataArry[self.now_index] name]];
        [self setParamsPrivate:BETypeBeautyReshapeEyeMove :0.0f];
        [self setParamsPrivate:BETypeBeautyReshapeEye :0.0f];
        [self setParamsPrivate:BETypeBeautyReshapeNoseLean :0.0f];
        [self setParamsPrivate:BETypeBeautyReshapeMouthZoom :0.0f];
        [self setParamsPrivate:BETypeBeautyReshapeChin :0.0f];
        [self setParamsPrivate:BETypeBeautyReshapeFaceOverall :0.0f];
    }
    [item setBackgroundColor:[UIColor redColor]];
    if(self.sink){
        self.sink([self.dataArry[self.now_index] name]);
    }
    [self.stepArr removeAllObjects];
    [self.stepArr addObject:[NSNumber numberWithFloat:1.0]];
    self.nowStep=0;
    self.nowProgress=1.0;
    self.cameraContainerView.exposureSlider.progress=1.0;
    [self checkColor];
    [self setParams];
    
}

-(void)setParamsPrivate:(NSInteger)inter :(float)value{
    BEComposerNodeModel *model = [self be_composerNodeToNode:[NSNumber numberWithLong:inter]];
    if (model != nil) {
        [_processor updateComposerNodeIntensity:model.path key:model.key intensity:value];
    } else {
        NSLog(@"model not found, node: %ld", inter);
    }
}


-(void) setParams{
//    [_capture pause];
    if(self.imageMode){
        [self setParamsPrivate:BETypeBeautyReshapeFaceOverall :[self.itemArray[0] floatValue]*self.nowProgress];
    }
    [self setParamsPrivate:BETypeBeautyReshapeFaceCut :[self.itemArray[1] floatValue]*self.nowProgress];
    [self setParamsPrivate:BETypeBeautyReshapeFaceSmall :[self.itemArray[2] floatValue]*self.nowProgress];
    if(self.imageMode){
        [self setParamsPrivate:BETypeBeautyReshapeEye :[self.itemArray[3] floatValue]*self.nowProgress];
    }
    [self setParamsPrivate:BETypeBeautyReshapeEyeRotate :[self.itemArray[4] floatValue]*self.nowProgress];
    [self setParamsPrivate:BETypeBeautyReshapeCheek :[self.itemArray[5] floatValue]*self.nowProgress];
    [self setParamsPrivate:BETypeBeautyReshapeJaw :[self.itemArray[6] floatValue]*self.nowProgress];
    if(self.imageMode){
        [self setParamsPrivate:BETypeBeautyReshapeNoseLean :[self.itemArray[7] floatValue]*self.nowProgress];
    }
    [self setParamsPrivate:BETypeBeautyReshapeNoseLong :[self.itemArray[8] floatValue]*self.nowProgress];
    if(self.imageMode){
        [self setParamsPrivate:BETypeBeautyReshapeChin :[self.itemArray[9] floatValue]*self.nowProgress];
    }
    [self setParamsPrivate:BETypeBeautyReshapeForehead :[self.itemArray[10] floatValue]*self.nowProgress];
    if(self.imageMode){
        [self setParamsPrivate:BETypeBeautyReshapeMouthZoom :[self.itemArray[11] floatValue]*self.nowProgress];
    }
    [self setParamsPrivate:BETypeBeautyReshapeMouthSmile :[self.itemArray[12] floatValue]*self.nowProgress];
    [self setParamsPrivate:BETypeBeautyReshapeEyeSpacing :[self.itemArray[13] floatValue]*self.nowProgress];
    if(self.imageMode){
        [self setParamsPrivate:BETypeBeautyReshapeEyeMove :[self.itemArray[14] floatValue]*self.nowProgress];
    }
    [self setParamsPrivate:BETypeBeautyReshapeMouthMove :[self.itemArray[15] floatValue]*self.nowProgress];
    [self setParamsPrivate:BETypeBeautyFaceRemovePouch :[self.itemArray[16] floatValue]*self.nowProgress];
    [self setParamsPrivate:BETypeBeautyFaceRemoveSmileFolds :[self.itemArray[17] floatValue]*self.nowProgress];
//    [_capture resume];
}


- (UIButton *)btnCompare {
    
    if (!_btnCompare) {
        
        _btnCompare = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnCompare.frame = CGRectMake(SCREEN_WIDTH - 80, SCREEN_HEIGHT - 150, 70, 35);
        [_btnCompare setTitle:@"对比" forState:UIControlStateNormal];
        [_btnCompare setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btnCompare.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _btnCompare.layer.cornerRadius = 35 / 2.0;
        [_btnCompare addTarget:self action:@selector(onBtnCompareTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_btnCompare addTarget:self action:@selector(onBtnCompareTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_btnCompare addTarget:self action:@selector(onBtnCompareTouchUpInside:) forControlEvents:UIControlEventTouchDragExit];
        
    }
    return _btnCompare;
}
- (void)onBtnCompareTouchDown:(UIButton *)sender {
    [sender setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.4] forState:UIControlStateNormal];
    [_processor setEffectOn:NO];
}

- (void)onBtnCompareTouchUpInside:(UIButton *)sender {
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_processor setEffectOn:YES];
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

- (void)onLightClick:(UIButton*)sender{
    [self.cameraContainerView switchHigh:0];
    if([self.stepArr[self.stepArr.count-1] intValue]!=0){
        [self.stepArr addObject:[NSNumber numberWithInt:0]];
        self.nowStep++;
        [self checkColor];
    }
}

- (void)onMiddleClick:(UIButton*)sender{
    [self.cameraContainerView switchHigh:1];
    if([self.stepArr[self.stepArr.count-1] intValue]!=1){
        [self.stepArr addObject:[NSNumber numberWithInt:1]];
        self.nowStep++;
        [self checkColor];
    }
}

- (void)onHighClick:(UIButton*)sender{
    [self.cameraContainerView switchHigh:2];
    if([self.stepArr[self.stepArr.count-1] intValue]!=2){
        [self.stepArr addObject:[NSNumber numberWithInt:2]];
        self.nowStep++;
        [self checkColor];
    }
}

-(void)checkColor{
    if([self.stepArr count]==0||[self.stepArr count]==1){
        self.cameraContainerView.beforeButton.backgroundColor=UIColor.grayColor;
        self.cameraContainerView.afterButton.backgroundColor=UIColor.grayColor;
    }else if(self.nowStep==[self.stepArr count]-1){
        self.cameraContainerView.beforeButton.backgroundColor=UIColor.blueColor;
        self.cameraContainerView.afterButton.backgroundColor=UIColor.grayColor;
    }else if(self.nowStep==0){
        self.cameraContainerView.beforeButton.backgroundColor=UIColor.grayColor;
        self.cameraContainerView.afterButton.backgroundColor=UIColor.blueColor;
    }else {
        self.cameraContainerView.beforeButton.backgroundColor=UIColor.blueColor;
        self.cameraContainerView.afterButton.backgroundColor=UIColor.blueColor;
    }
}

-(void)onallAnswerButtonClicked:(UIButton*)sender{
    self.flutterController.view.hidden=NO;
    self.closeFlutterBtn.hidden=NO;
    self.backButton.hidden=NO;
}
-(void)closeFlutter:(UIButton*) btn{
    self.flutterController.view.hidden=YES;
    self.closeFlutterBtn.hidden=YES;
    self.backButton.hidden=YES;
    if(self.sink){
        self.sink(@"closeKeyBoard");
    }
}

-(void)onBeforeClick:(UIButton*)sender{
    if(self.nowStep>0){
        self.nowStep--;
        self.cameraContainerView.exposureSlider.progress
        =[self.stepArr[self.nowStep] floatValue];
        [self checkColor];
        self.nowProgress=[self.stepArr[self.nowStep] floatValue];
        [self setParams];
    }
}

-(void)onAfterClick:(UIButton*)sender{
    if([self.stepArr count]>0&&self.nowStep<[self.stepArr count]-1){
        self.nowStep++;
        self.cameraContainerView.exposureSlider.progress
        =[self.stepArr[self.nowStep] floatValue];
        [self checkColor];
        self.nowProgress=[self.stepArr[self.nowStep] floatValue];
        [self setParams];
    }
}

#pragma mark - <FlutterStreamHandler>
- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)events {
    self.sink=events;
    return nil;
}

/// flutter不再接收
- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    // arguments flutter给native的参数
    NSLog(@"%@", arguments);
    return nil;
}

-(void)ok:(UIButton*)sender{
    _processor.captureNextFrame = YES;
}
-(void)reTake:(UIButton*)sender{
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}

- (NSString *)createCUID:(NSString *)prefix

{   NSString *  result;
    CFUUIDRef  uuid;
    CFStringRef uuidStr;
    uuid = CFUUIDCreate(NULL);
    uuidStr = CFUUIDCreateString(NULL, uuid);
    result =[NSString stringWithFormat:@"%@-%@", prefix,uuidStr];
    CFRelease(uuidStr);
    CFRelease(uuid);
    return result;
}
- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

-(void)onProgressDidChange:(CGFloat)progress{
    self.nowProgress=progress;
    [self setParams];
}
-(void)onProgressTouchEnd:(CGFloat)progress{
    [self.stepArr addObject:[NSNumber numberWithFloat:progress]];
    if([self.stepArr count]>0){
        self.nowStep=[self.stepArr count]-1;
    }
    [self checkColor];
}
@end

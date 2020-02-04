//
//  MyTestCameraVC.m
//  Runner
//
//  Created by Apple on 2020/1/6.
//  Copyright © 2020 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyTestCameraVC.h"


#import <AssetsLibrary/AssetsLibrary.h>
#import <CommonCrypto/CommonDigest.h>
#import <OpenGLES/ES2/glext.h>
#import "STMobileLog.h"
#import "STViewButton.h"
#import "STTriggerView.h"
#import "STScrollTitleView.h"
#import "STCommonObjectContainerView.h"
#import "STCollectionView.h"
#import "STParamUtil.h"
#import "STCamera.h"
#import "STGLPreview.h"
#import "PhotoSelectVC.h"
#import "STMovieRecorder.h"
#import "STEffectsAudioPlayer.h"
#import "STEffectsTimer.h"
#import "STAudioManager.h"
#import "STFilterView.h"
#import "STButton.h"
#import <sys/utsname.h>
#import <CoreMotion/CoreMotion.h>
#import "STVFShader.h"
#import "STBeautySlider.h"

#import <mach/mach.h>

#import "SenseArSourceService.h"
#import "STCustomMemoryCache.h"
#import "EffectsCollectionView.h"
#import "EffectsCollectionViewCell.h"

#import "STBMPCollectionView.h"
#import "STBmpStrengthView.h"
#import "TestModel.h"


//ST_MOBILE
#import "st_mobile_sticker.h"
#import "st_mobile_beautify.h"
#import "st_mobile_license.h"
#import "st_mobile_face_attribute.h"
#import "st_mobile_filter.h"
#import "st_mobile_object.h"
#import "st_mobile_animal.h"
#import "st_mobile_avatar.h"
#import "st_mobile_makeup.h"
#import "MyTestVC.h"

#import "STCamera.h"
#define DRAW_FACE_KEY_POINTS 1
#define ENABLE_FACE_ATTRIBUTE_DETECT 0
#define TEST_OUTPUT_BUFFER_INTERFACE 0
#define TEST_BODY_BEAUTY 0
#define TEST_AVATAR_EXPRESSION 0

@interface MyTestCameraVC() <STCameraDelegate, STCommonObjectContainerViewDelegate, STViewButtonDelegate, STEffectsTimerDelegate, UIGestureRecognizerDelegate, STBeautySliderDelegate, STBMPCollectionViewDelegate, STBmpStrengthViewDelegate>
{
    st_handle_t _hSticker;  // sticker句柄
    st_handle_t _hDetector; // detector句柄
    st_handle_t _hBeautify; // beautify句柄
    st_handle_t _hAttribute;// attribute句柄
    st_handle_t _hFilter;   // filter句柄
    st_handle_t _hTracker;  // 通用物体跟踪句柄
    st_handle_t _animalHandle; //猫脸
#if TEST_AVATAR_EXPRESSION
    st_handle_t _avatarHandle; //avatar expression
#endif
    st_handle_t _hBmpHandle;
    
    st_mobile_animal_face_t *_detectResult1;
    
    st_rect_t _rect;  // 通用物体位置
    float _result_score; //通用物体置信度
    
    
#if ENABLE_FACE_ATTRIBUTE_DETECT
    st_mobile_106_t *_pFacesDetection; // 检测输出人脸信息数组
#endif
    
    CVOpenGLESTextureCacheRef _cvTextureCache;
    
    CVOpenGLESTextureRef _cvTextureOrigin;
    CVOpenGLESTextureRef _cvTextureBeautify;
    CVOpenGLESTextureRef _cvTextureSticker;
    CVOpenGLESTextureRef _cvTextureFilter;
    CVOpenGLESTextureRef _cvTextureMakeup;
    
    CVPixelBufferRef _cvBeautifyBuffer;
    CVPixelBufferRef _cvStickerBuffer;
    CVPixelBufferRef _cvFilterBuffer;
    CVPixelBufferRef _cvMakeUpBuffer;
    
    GLuint _textureOriginInput;
    GLuint _textureBeautifyOutput;
    GLuint _textureStickerOutput;
    GLuint _textureFilterOutput;
    GLuint _textureMakeUpOutput;
    
    
    st_mobile_human_action_t _detectResult;
}

@property (nonatomic , assign) BOOL isFirstLaunch;

//beauty value
@property (nonatomic, assign) float fWhitenStrength;
@property (nonatomic, assign) float fReddenStrength;
@property (nonatomic, assign) float fSmoothStrength;
@property (nonatomic, assign) float fDehighlightStrength;

@property (nonatomic, assign) float fShrinkFaceStrength;
@property (nonatomic, assign) float fEnlargeEyeStrength;
@property (nonatomic, assign) float fShrinkJawStrength;
@property (nonatomic, assign) float fNarrowFaceStrength;
@property (nonatomic, assign) float fRoundEyeStrength;

@property (nonatomic, assign) float fThinFaceShapeStrength;
@property (nonatomic, assign) float fChinStrength;
@property (nonatomic, assign) float fHairLineStrength;
@property (nonatomic, assign) float fNarrowNoseStrength;
@property (nonatomic, assign) float fLongNoseStrength;
@property (nonatomic, assign) float fMouthStrength;
@property (nonatomic, assign) float fPhiltrumStrength;
@property (nonatomic, assign) float fAppleMusleStrength;
@property (nonatomic, assign) float fProfileRhinoplastyStrength;
@property (nonatomic, assign) float fEyeDistanceStrength;
@property (nonatomic, assign) float fEyeAngleStrength;
@property (nonatomic, assign) float fOpenCanthusStrength;
@property (nonatomic, assign) float fBrightEyeStrength;
@property (nonatomic, assign) float fRemoveDarkCirclesStrength;
@property (nonatomic, assign) float fRemoveNasolabialFoldsStrength;
@property (nonatomic, assign) float fWhiteTeethStrength;
@property (nonatomic) UIDeviceOrientation deviceOrientation;
@property (nonatomic, assign) float fContrastStrength;
@property (nonatomic, assign) float fSaturationStrength;
@property (nonatomic,strong) UIVisualEffectView *effectView;

@property (nonatomic) int now_index;

@property (nonatomic, strong) CMMotionManager *motionManager;

@property (nonatomic, assign) CGFloat scale;  //视频充满全屏的缩放比例
@property (nonatomic, assign) int margin;

@property (nonatomic,strong)NSMutableArray *dataArry;
@property (nonatomic, strong) STCamera *stCamera;
@property (nonatomic, strong) STGLPreview *glPreview;
@property(retain,nonatomic) UIScrollView* scrollView;

@property (nonatomic, strong) UILabel *lblAttribute;

@property (nonatomic, strong) UIImageView *focusImageView;
@property (nonatomic) double currentTime;

@property (nonatomic, strong) EAGLContext *glContext;
@property (nonatomic, strong) CIContext *ciContext;

@property (nonatomic , assign) CGPoint previewCenter;
@property (nonatomic , assign) CGRect previewFrame;

@property (nonatomic, readwrite, strong) NSString *currentSessionPreset;
@property (nonatomic, readwrite, strong) STCommonObjectContainerView *commonObjectContainerView;
@property (nonatomic, readwrite, assign) CGFloat imageWidth;
@property (nonatomic, readwrite, assign) CGFloat imageHeight;
@property (nonatomic, readwrite, assign) CMFormatDescriptionRef outputVideoFormatDescription;

@property (nonatomic, strong) UILabel *lblSaveStatus;
@property (nonatomic, readwrite, assign) BOOL needSnap;
@property (nonatomic,assign)BOOL needSave;
@property(nonatomic)int skipCount;
@property (nonatomic, readwrite, assign) BOOL pauseOutput;
@property (nonatomic, readwrite, assign) BOOL isAppActive;
@property (nonatomic, assign) double lastTimeAttrDetected;

@property (nonatomic, readwrite, assign) unsigned long long iCurrentAction;
@property (nonatomic, readwrite, assign) unsigned long long makeUpConf;
@property (nonatomic, readwrite, assign) unsigned long long stickerConf;
@property (nonatomic , strong) STCustomMemoryCache *effectsDataSource;

@property (nonatomic, assign) BOOL bExposured;

@property (nonatomic , assign) int iBufferedCount;


@property (nonatomic) dispatch_queue_t changeModelQueue;
@property (nonatomic) dispatch_queue_t changeStickerQueue;
@property (nonatomic) dispatch_queue_t renderQueue;
@property(nonatomic) BOOL willAppearClose;

@property (nonatomic, assign, getter=isCommonObjectViewAdded) BOOL commonObjectViewAdded;
@property (nonatomic, assign, getter=isCommonObjectViewSetted) BOOL commonObjectViewSetted;
@property (nonatomic, strong) NSData *licenseData;
@property(nonatomic)BOOL isComparing;
@property (nonatomic, readwrite, strong) UIButton *btnCompare;

@property(nonatomic)int outputStep;

@property(nonatomic)int radomIndex;

@property(nonatomic) NSMutableArray * selectedList;
@end

@implementation MyTestCameraVC

- (void)loadView {
    [super loadView];
    [self.view setBackgroundColor:[UIColor blackColor]];
    self.selectedList=[NSMutableArray new];
    self.now_index=0;
    self.fSmoothStrength = 0.0;
    self.fReddenStrength = 0.0;
    self.fWhitenStrength = 0.0;
    self.fDehighlightStrength = 0.0;
    
    self.fEnlargeEyeStrength = 0.0;
    self.fShrinkFaceStrength = 0.0;
    self.fShrinkJawStrength = 0.0;
    self.fNarrowFaceStrength = 0.0;
    self.fRoundEyeStrength = 0.0;
    
    self.fThinFaceShapeStrength = 0.0;
    self.fChinStrength = 0.0;
    self.fHairLineStrength = 0.0;
    self.fNarrowNoseStrength = 0.0;
    self.fLongNoseStrength = 0.0;
    self.fMouthStrength = 0.0;
    self.fPhiltrumStrength = 0.0;
    
    self.fContrastStrength = 0.0;
    self.fSaturationStrength = 0.0;
    self.imageWidth = 720;
    self.imageHeight = 1280;
    self.currentSessionPreset = AVCaptureSessionPresetHigh;
    self.renderQueue = dispatch_queue_create("com.sensetime.renderQueue", NULL);
    self.dataArry=TestModel.getDemoData;
    self.needSnap = NO;
    self.needSave=NO;
    self.willAppearClose=NO;
    self.skipCount=0;
    self.pauseOutput = NO;
    self.isComparing=NO;
    self.isAppActive = YES;
    self.outputStep=0;
    self.radomIndex=0;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self requestPermissions];
    [self setupUtilTools];
    [self setupSubviews];
    [self addGestureRecoginzer];
    
    //离线激活
    [self checkLicenseFromLocal];
    [self initResourceAndStartPreview];
    self.now_index=2;
    UIButton * btn=[self.scrollView viewWithTag:102];
    [btn setBackgroundColor:[UIColor redColor]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backValue:) name:@"backValue"object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    if(self.willAppearClose){
        NSLog(@"viewWILL APP  TrUe");
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        self.effectView.hidden=true;
        self.pauseOutput=false;
        [self setParams:[self.dataArry[self.now_index] arr]];
    }
}


-(void) backValue:(NSNotification *)text{
    if(text.object==nil){
        self.willAppearClose=NO;
    }else{
        self.willAppearClose=YES;
        [self.motionManager stopAccelerometerUpdates];
        [self.motionManager stopDeviceMotionUpdates];
        [self.stCamera stopRunning];
        [self releaseResources];

        self.stCamera = nil;
    }
}

- (void)initResourceAndStartPreview
{
    ///ST_MOBILE：设置预览时需要注意 EAGLContext 的初始化
    [self setupCameraAndPreview];
    
    // 设置SDK OpenGL 环境 , 只有在正确的 OpenGL 环境下 SDK 才会被正确初始化 .
    self.ciContext = [CIContext contextWithEAGLContext:self.glContext
                                               options:@{kCIContextWorkingColorSpace : [NSNull null]}];
    
    [EAGLContext setCurrentContext:self.glContext];
    
    // 初始化结果文理及纹理缓存
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, self.glContext, NULL, &_cvTextureCache);
    
    if (err) {
        NSLog(@"CVOpenGLESTextureCacheCreate %d" , err);
    }
    
    [self initResultTexture];
    if ([self checkActiveCodeWithData:self.licenseData]) {
        ///ST_MOBILE：初始化相关的句柄
        NSLog(@"加载呢啊");
        [self setupHandle];
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"使用 license 文件生成激活码时失败，可能是授权文件过期。" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        
        [alert show];
    }
    
    if ([self.motionManager isAccelerometerAvailable]) {
        [self.motionManager startAccelerometerUpdates];
    }
    
    if ([self.motionManager isDeviceMotionAvailable]) {
        [self.motionManager startDeviceMotionUpdates];
    }
    
    self.pauseOutput = NO;
    self.stCamera.sessionPreset = self.currentSessionPreset;
    [self.stCamera startRunning];
}


- (void)releaseResources
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if ([EAGLContext currentContext] != self.glContext) {
        [EAGLContext setCurrentContext:self.glContext];
    }
    
    if (_hSticker) {
        
        st_result_t iRet = ST_OK;
        iRet = st_mobile_sticker_remove_avatar_model(_hSticker);
        if (iRet != ST_OK) {
            NSLog(@"remove avatar model failed: %d", iRet);
        }
        st_mobile_sticker_destroy(_hSticker);
        _hSticker = NULL;
    }
    if (_hBeautify) {
        
        st_mobile_beautify_destroy(_hBeautify);
        _hBeautify = NULL;
    }
    
    if (_animalHandle) {
        st_mobile_tracker_animal_face_destroy(_animalHandle);
        _animalHandle = NULL;
    }
    
    if (_hDetector) {
        
        st_mobile_human_action_destroy(_hDetector);
        _hDetector = NULL;
    }
    
    if (_hAttribute) {
        
        st_mobile_face_attribute_destroy(_hAttribute);
        _hAttribute = NULL;
    }
    
    if (_hBmpHandle) {
        st_mobile_makeup_destroy(_hBmpHandle);
        _hBmpHandle = NULL;
    }
    
#if ENABLE_FACE_ATTRIBUTE_DETECT
    if (_pFacesDetection) {
        
        free(_pFacesDetection);
        _pFacesDetection = NULL;
    }
#endif
    
    if (_hFilter) {
        
        st_mobile_gl_filter_destroy(_hFilter);
        _hFilter = NULL;
    }
    
    if (_hTracker) {
        st_mobile_object_tracker_destroy(_hTracker);
        _hTracker = NULL;
    }
    
    [self releaseResultTexture];
    
    if (_cvTextureCache) {
        
        CFRelease(_cvTextureCache);
        _cvTextureCache = NULL;
    }
    
    //    glFinish();
    
    [EAGLContext setCurrentContext:nil];
    
    self.glContext = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{

        [self.glPreview removeFromSuperview];
        self.glPreview = nil;

        [self.commonObjectContainerView removeFromSuperview];
        self.commonObjectContainerView = nil;

        self.ciContext = nil;
    });
    
}


- (BOOL)checkLicenseFromLocal {
    self.licenseData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SENSEME" ofType:@"lic"]];
    return [self checkActiveCodeWithData:self.licenseData];
}

//验证license
- (BOOL)checkActiveCodeWithData:(NSData *)dataLicense
{
    NSString *strKeyActiveCode = @"ACTIVE_CODE_ONLINE";
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *strActiveCode = [userDefaults objectForKey:strKeyActiveCode];
    st_result_t iRet = ST_E_FAIL;
    
    iRet = st_mobile_check_activecode_from_buffer(
                                                  [dataLicense bytes],
                                                  (int)[dataLicense length],
                                                  strActiveCode.UTF8String,
                                                  (int)[strActiveCode length]
                                                  );
    
    if (ST_OK == iRet) {
        
        return YES;
    }
    
    char active_code[1024];
    int active_code_len = 1024;
    
    iRet = st_mobile_generate_activecode_from_buffer(
                                                     [dataLicense bytes],
                                                     (int)[dataLicense length],
                                                     active_code,
                                                     &active_code_len
                                                     );
    
    strActiveCode = [[NSString alloc] initWithUTF8String:active_code];
    
    
    if (iRet == ST_OK && strActiveCode.length) {
        
        [userDefaults setObject:strActiveCode forKey:strKeyActiveCode];
        [userDefaults synchronize];
        
        return YES;
    }
    
    return NO;
}

- (void)addNotifications {
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void) clickButton:(UIButton*) btn {
    for(int i = 0; i < self.dataArry.count; i++) {
        UIButton * item=[_scrollView viewWithTag:100+i];
        [item setBackgroundColor:[UIColor orangeColor]];
    }
    UIButton * item=[_scrollView viewWithTag:btn.tag];
    self.now_index=btn.tag-100;
    [item setBackgroundColor:[UIColor redColor]];
    if(self.now_index==0){
        self.radomIndex=-1;
    }else{
        self.radomIndex=[self getRandomNumber:0 to:3];
    }
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, [[self.dataArry[self.now_index] arr][13]floatValue]);
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, [[self.dataArry[self.now_index] arr][1]floatValue]);
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_NARROW_NOSE_RATIO, [[self.dataArry[self.now_index] arr][9]floatValue]);
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_MOUTH_SIZE_RATIO, [[self.dataArry[self.now_index] arr][11]floatValue]);
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_CHIN_LENGTH_RATIO, [[self.dataArry[self.now_index] arr][6]floatValue]);
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_NARROW_FACE_STRENGTH, [[self.dataArry[self.now_index] arr][3]floatValue]);
    if([self.selectedList containsObject:[NSNumber numberWithInt:self.now_index]]){
        self.outputStep=1000;
    }else{
        self.outputStep=0;
        [self.selectedList addObject:[NSNumber numberWithInt:self.now_index]];
    }
//    if(self.now_index!=0&&self.now_index!=1){
//        [self setParams:[self.dataArry[self.now_index] arr]];
//    }
//    NSLog([NSString stringWithFormat:@"INDEXXX  %d",btn.tag]);
//    [self setParams:[self.dataArry[btn.tag-100] arr]];
}



-(void) setParams:(NSArray*)arr{
    
//    if(self.now_index==0||self.now_index==1){
////        setBeautifyParam(_hBeautify, ST_BEAUTIFY_SMOOTH_MODE, 0.0);
//        setBeautifyParam(_hBeautify, ST_BEAUTIFY_SMOOTH_STRENGTH, 0.0);
//        setBeautifyParam(_hBeautify, ST_BEAUTIFY_WHITEN_STRENGTH, 0.0);
//    }else{
////        setBeautifyParam(_hBeautify, ST_BEAUTIFY_SMOOTH_MODE, 0.5);
//    }

    setBeautifyParam(_hBeautify, ST_BEAUTIFY_SMOOTH_STRENGTH, 0.4);
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_WHITEN_STRENGTH, 0.4);
    
    // 设置默认瘦脸参数
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_SHRINK_FACE_RATIO,  [arr[0] floatValue]);
    // 设置默认大眼参数
//        setBeautifyParam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, [arr[1] floatValue]);
    // 设置小脸参数
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_SHRINK_JAW_RATIO, [arr[2] floatValue]);
    //脸
//        setBeautifyParam(_hBeautify, ST_BEAUTIFY_NARROW_FACE_STRENGTH, [arr[3] floatValue]);
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_ROUND_EYE_RATIO, [arr[4] floatValue]);
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_THIN_FACE_SHAPE_RATIO, [arr[5] floatValue]);
    
    //TODO
//        setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_CHIN_LENGTH_RATIO, [arr[6] floatValue]);
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_HAIRLINE_HEIGHT_RATIO, [arr[7] floatValue]);
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_APPLE_MUSLE_RATIO, [arr[8] floatValue]);
    
//        setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_NARROW_NOSE_RATIO, [arr[9] floatValue]);
    
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_NOSE_LENGTH_RATIO, [arr[10] floatValue]);
//    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_MOUTH_SIZE_RATIO, [arr[11] floatValue]);
    
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_PHILTRUM_LENGTH_RATIO, [arr[12] floatValue]);
    
//    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, [arr[13] floatValue]);
    
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_ANGLE_RATIO, [arr[14] floatValue]);
    
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_OPEN_CANTHUS_RATIO, [arr[15] floatValue]);
    
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_REMOVE_DARK_CIRCLES_RATIO, [arr[16] floatValue]);
    
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_REMOVE_NASOLABIAL_FOLDS_RATIO, [arr[17] floatValue]);
}


- (void)setupUtilTools {
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = 0.5;
    self.motionManager.deviceMotionUpdateInterval = 1 / 25.0;
}


- (void)setupSubviews {
    
    //    NSMutableArray *dataArry=TestModel.getDemoData;
    //创建UIScrollView
    _scrollView = [[UIScrollView alloc] init];
    //设置UIScrollView的位置和宽高为控制器View的宽高
    _scrollView.frame = CGRectMake(0, SCREEN_HEIGHT-60, SCREEN_WIDTH, 50);
    //设置画布大小，一般比frame大，这里设置横向能拖动4张图片的范围
    _scrollView.contentSize = CGSizeMake(70 * self.dataArry.count+10, 50);
    //隐藏横向滚动条
    _scrollView.showsHorizontalScrollIndicator = NO;
    //隐藏竖向滚动条
    _scrollView.showsVerticalScrollIndicator = NO;
    for(int i = 0; i < self.dataArry.count; i++) {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button.layer setCornerRadius:10.0];
        button.frame = CGRectMake(i*70+10, 0, 60, 50);
        // 按钮的正常状态
        [button setTitle:[self.dataArry[i] name] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor orangeColor];
        [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i+100;
        [_scrollView addSubview:button];
        
    }
    //    NSString* imgName = @"333";
    //    UIImage* img = [UIImage imageNamed:imgName];
    //    UIImageView* imgView = [[UIImageView alloc] initWithImage:img];
    //    imgView.frame = CGRectMake(110 * 5, 0, 100, 100);
    //    [_scrollView addSubview:imgView];
    
    UIButton *btn =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(10, 20, 50, 50);
    [btn setImage:[UIImage imageNamed:@"backIcon"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(onBtnClosed:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *switchCamera =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    switchCamera.frame = CGRectMake(SCREEN_WIDTH-60, 20, 50, 50);
    [switchCamera setImage:[UIImage imageNamed:@"camera_rotate"] forState:UIControlStateNormal];
    [switchCamera addTarget:self action:@selector(onBtnChangeCamera:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *takeCamera =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    takeCamera.frame = CGRectMake(SCREEN_WIDTH/2-40, SCREEN_HEIGHT-160, 80, 80);
    takeCamera.backgroundColor=[UIColor blueColor];
    [takeCamera.layer setCornerRadius:10.0];
    [takeCamera setImage:[UIImage imageNamed:@"snap"] forState:UIControlStateNormal];
    [takeCamera addTarget:self action:@selector(onBtnTakePic:) forControlEvents:UIControlEventTouchUpInside];
    self.view.backgroundColor = [UIColor whiteColor];
    UIBlurEffect * effect=[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    _effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    _effectView.frame = UIScreen.mainScreen.bounds;
    _effectView.hidden=true;
    [self.view addSubview:_effectView];
    [self.view addSubview:_scrollView];//添加表格到视图
    [self.view addSubview:btn];
    [self.view addSubview:switchCamera];
    [self.view addSubview:self.focusImageView];
    [self.view addSubview:takeCamera];
    [self.view addSubview:_lblSaveStatus];
    [self.view bringSubviewToFront:_lblSaveStatus];
    [self.view addSubview:self.btnCompare];
}

-(void)onBtnTakePic:(UIButton*) btn {
    _needSnap = YES;
}

- (void)onBtnClosed:(UIButton*) btn {
    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopDeviceMotionUpdates];
    self.pauseOutput = YES;
    [self.stCamera stopRunning];
    dispatch_async(self.stCamera.bufferQueue, ^{
        [self releaseResources];
    });
    
    self.stCamera = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (UIImageView *)focusImageView {
    if (!_focusImageView) {
        _focusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _focusImageView.image = [UIImage imageNamed:@"camera_focus_red"];
        _focusImageView.alpha = 0;
    }
    return _focusImageView;
}



#pragma mark -

- (void)getDeviceOrientation:(CMAccelerometerData *)accelerometerData {
    if (accelerometerData.acceleration.x >= 0.75) {
        _deviceOrientation = UIDeviceOrientationLandscapeRight;
    } else if (accelerometerData.acceleration.x <= -0.75) {
        _deviceOrientation = UIDeviceOrientationLandscapeLeft;
    } else if (accelerometerData.acceleration.y <= -0.75) {
        _deviceOrientation = UIDeviceOrientationPortrait;
    } else if (accelerometerData.acceleration.y >= 0.75) {
        _deviceOrientation = UIDeviceOrientationPortraitUpsideDown;
    } else {
        _deviceOrientation = UIDeviceOrientationPortrait;
    }
}

- (void)appDidEnterBackground {
    
    self.isAppActive = NO;
}

- (void)appWillEnterForeground {
    
    self.isAppActive = YES;
}

- (void)appDidBecomeActive {
    
    self.pauseOutput = NO;
    self.isAppActive = YES;
}

- (UILabel *)lblAttribute {
    
    if (!_lblAttribute) {
        
        _lblAttribute = [[UILabel alloc] initWithFrame:CGRectMake(0, 60, SCREEN_WIDTH, 15.0)];
        _lblAttribute.textAlignment = NSTextAlignmentCenter;
        _lblAttribute.font = [UIFont systemFontOfSize:14.0];
        _lblAttribute.numberOfLines = 0;
        _lblAttribute.shadowColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        _lblAttribute.shadowOffset = CGSizeMake(0, 1.0);
        _lblAttribute.backgroundColor = [UIColor clearColor];
        _lblAttribute.textColor = [UIColor whiteColor];
    }
    
    return _lblAttribute;
}


- (double)usedMemory
{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    if (kernReturn != KERN_SUCCESS
        ) {
        return NSNotFound;
    }
    return taskInfo.resident_size / 1024.0 / 1024.0;
}

-(double)availableMemory
{
    
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);
    if(kernReturn != KERN_SUCCESS)
    {
        return NSNotFound;
    }
    
    return ((vm_page_size * vmStats.free_count)/1024.0)/1024.0;
}



#pragma mark - STCameraDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (!self.isAppActive) {
        return;
    }
    
    if (self.pauseOutput) {
        
        return;
    }
    
    if (self.iBufferedCount >= 2) {
        
        return;
    }
    
    //获取每一帧图像信息
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    unsigned char* pBGRAImageIn = (unsigned char*)CVPixelBufferGetBaseAddress(pixelBuffer);
    double dCost = 0.0;
    double dStart = CFAbsoluteTimeGetCurrent();
    
    int iBytesPerRow = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
    int iWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
    int iHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    
    size_t iTop , iBottom , iLeft , iRight;
    CVPixelBufferGetExtendedPixels(pixelBuffer, &iLeft, &iRight, &iTop, &iBottom);
    
    iWidth = iWidth + (int)iLeft + (int)iRight;
    iHeight = iHeight + (int)iTop + (int)iBottom;
    iBytesPerRow = iBytesPerRow + (int)iLeft + (int)iRight;
    
    _scale = MAX(SCREEN_HEIGHT / iHeight, SCREEN_WIDTH / iWidth);
    _margin = (iWidth * _scale - SCREEN_WIDTH) / 2;
    
    st_rotate_type stMobileRotate = [self getRotateType];
    
    st_mobile_human_action_t detectResult;
    memset(&detectResult, 0, sizeof(st_mobile_human_action_t));
    st_result_t iRet = ST_OK;
    // 如果需要做属性,每隔一秒做一次属性
    double dTimeNow = CFAbsoluteTimeGetCurrent();
    BOOL isAttributeTime = (dTimeNow - self.lastTimeAttrDetected) >= 1.0;
    if (isAttributeTime) {
        self.lastTimeAttrDetected = dTimeNow;
    }
    ///ST_MOBILE 人脸信息检测部分
    if (_hDetector) {
        BOOL needFaceDetection = true;
        if (needFaceDetection) {
#if TEST_AVATAR_EXPRESSION
            self.iCurrentAction |= ST_MOBILE_FACE_DETECT | self.avatarConfig;
#else
            self.iCurrentAction = ST_MOBILE_FACE_DETECT | self.makeUpConf | self.stickerConf;
#endif
        } else {
            
            self.iCurrentAction = self.makeUpConf | self.stickerConf;
        }
        if (self.iCurrentAction > 0) {
            TIMELOG(keyDetect);
            st_result_t iRet = st_mobile_human_action_detect(_hDetector, pBGRAImageIn, ST_PIX_FMT_BGRA8888, iWidth, iHeight, iBytesPerRow, stMobileRotate, self.iCurrentAction, &detectResult);
            
            TIMEPRINT(keyDetect, "st_mobile_human_action_detect time:");
            
            if (detectResult.face_count > 0 && !self.bExposured) {
                
                [self.stCamera setExposurePoint:self.previewCenter inPreviewFrame:self.previewFrame];
                
                [self.stCamera setISOValue:140];
                
                self.bExposured = YES;
            }
            
            if (!detectResult.face_count) {
                self.bExposured = NO;
            }
            
            if(iRet == ST_OK) {
                
                
            }else{
                STLog(@"st_mobile_human_action_detect failed %d" , iRet);
            }
        }
    }
    self.iBufferedCount ++;
    CFRetain(pixelBuffer);
    
    __block st_mobile_human_action_t newDetectResult;
    memset(&newDetectResult, 0, sizeof(st_mobile_human_action_t));
    //    copyHumanAction(&detectResult, &newDetectResult);
    st_mobile_human_action_copy(&detectResult, &newDetectResult);
    
    dispatch_async(self.renderQueue, ^{
        
        st_result_t iRet = ST_E_FAIL;
        
        // 设置 OpenGL 环境 , 需要与初始化 SDK 时一致
        if ([EAGLContext currentContext] != self.glContext) {
            [EAGLContext setCurrentContext:self.glContext];
        }
        
        // 当图像尺寸发生改变时需要对应改变纹理大小
        if (iWidth != self.imageWidth || iHeight != self.imageHeight) {
            
            [self releaseResultTexture];
            
            self.imageWidth = iWidth;
            self.imageHeight = iHeight;
            
            [self initResultTexture];
        }
        
        // 获取原图纹理
        BOOL isTextureOriginReady = [self setupOriginTextureWithPixelBuffer:pixelBuffer];
        
        GLuint textureResult = _textureOriginInput;
        
        CVPixelBufferRef resultPixelBufffer = pixelBuffer;
        
        if (isTextureOriginReady) {
            
            ///ST_MOBILE 以下为美颜部分
            if ( _hBeautify) {
                if(self.now_index!=1){
                    [self setParams:[self.dataArry[self.now_index] arr]];
                }
#if DRAW_FACE_KEY_POINTS
                    [self drawKeyPoints:newDetectResult];
#endif
                iRet = st_mobile_beautify_process_texture(_hBeautify, _textureOriginInput, iWidth, iHeight, stMobileRotate, &newDetectResult, _textureBeautifyOutput, &newDetectResult);
                if (ST_OK != iRet) {
                    STLog(@"st_mobile_beautify_process_texture failed %d" , iRet);
                } else {
                    textureResult = _textureBeautifyOutput;
                    resultPixelBufffer = _cvBeautifyBuffer;
                }
            }
            
        }

                
        //        对比
        if (self.isComparing||self.skipCount>1) {
            textureResult = _textureOriginInput;
        }
        
        st_mobile_human_action_delete(&newDetectResult);

        [self.glPreview renderTexture:textureResult];
        
        if (self.needSnap) {
            self.pauseOutput = YES;
            self.needSnap = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                self.effectView.hidden=false;
                @synchronized (self) {
                    [self setParams:[self.dataArry[0] arr]];
                }
                self.skipCount=1;
                self.pauseOutput = NO;
            });
        }
        if(self.skipCount>=1){
            if(self.skipCount>5){
                self.skipCount=0;
                self.needSave=true;
            }else{
                self.skipCount++;
            }
        }
        if(self.needSave){
            [self snapWithTexture:textureResult width:iWidth height:iHeight];
            self.needSave=NO;
            self.pauseOutput = YES;
        }
        
        //        freeHumanAction(&newDetectResult);
        
        
        if (_cvTextureOrigin) {
            
            CFRelease(_cvTextureOrigin);
            _cvTextureOrigin = NULL;
        }
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        CVOpenGLESTextureCacheFlush(_cvTextureCache, 0);
        
        CFRelease(pixelBuffer);
        self.iBufferedCount --;
    });
    
#if ENABLE_FACE_ATTRIBUTE_DETECT
    if (_pFacesDetection) {
        free(_pFacesDetection);
        _pFacesDetection = NULL;
    }
#endif
    
}



- (CGPoint)coordinateTransformation:(st_pointf_t)point {
    
    return CGPointMake(_scale * point.x - _margin, _scale * point.y);
}


- (BOOL)setupOriginTextureWithPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    CVReturn cvRet = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                                  _cvTextureCache,
                                                                  pixelBuffer,
                                                                  NULL,
                                                                  GL_TEXTURE_2D,
                                                                  GL_RGBA,
                                                                  self.imageWidth,
                                                                  self.imageHeight,
                                                                  GL_BGRA,
                                                                  GL_UNSIGNED_BYTE,
                                                                  0,
                                                                  &_cvTextureOrigin);
    
    if (!_cvTextureOrigin || kCVReturnSuccess != cvRet) {
        
        NSLog(@"CVOpenGLESTextureCacheCreateTextureFromImage %d" , cvRet);
        
        return NO;
    }
    
    _textureOriginInput = CVOpenGLESTextureGetName(_cvTextureOrigin);
    glBindTexture(GL_TEXTURE_2D , _textureOriginInput);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"MEMORY WARING");
    // Dispose of any resources that can be recreated.
}

- (void)onBtnChangeCamera:(UIButton*) btn{
    
    [self resetCommonObjectViewPosition];
    
    if (self.stCamera.devicePosition == AVCaptureDevicePositionFront) {
        self.stCamera.devicePosition = AVCaptureDevicePositionBack;
        
    } else {
        self.stCamera.devicePosition = AVCaptureDevicePositionFront;
    }
}
- (void)resetCommonObjectViewPosition {
    if (self.commonObjectContainerView.currentCommonObjectView) {
        _commonObjectViewSetted = NO;
        _commonObjectViewAdded = NO;
        self.commonObjectContainerView.currentCommonObjectView.hidden = NO;
        self.commonObjectContainerView.currentCommonObjectView.onFirst = YES;
        self.commonObjectContainerView.currentCommonObjectView.center = CGPointMake(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    }
}

- (void)releaseResultTexture {
    
    
    _textureBeautifyOutput = 0;
    _textureStickerOutput = 0;
    _textureFilterOutput = 0;
    _textureMakeUpOutput = 0;
    
    if (_cvTextureOrigin) {
        
        CFRelease(_cvTextureOrigin);
        _cvTextureOrigin = NULL;
    }
    
    CFRelease(_cvTextureBeautify);
    CFRelease(_cvTextureSticker);
    CFRelease(_cvTextureFilter);
    CFRelease(_cvTextureMakeup);
    
    CVPixelBufferRelease(_cvBeautifyBuffer);
    CVPixelBufferRelease(_cvStickerBuffer);
    CVPixelBufferRelease(_cvFilterBuffer);
    CVPixelBufferRelease(_cvMakeUpBuffer);
}


- (void)snapWithTexture:(GLuint)iTexture width:(int)iWidth height:(int)iHeight
{
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    NSString *tempPathBefore = NSTemporaryDirectory();
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *tempPath = [tempPathBefore stringByAppendingPathComponent:@"REALPATH"];
    [manager createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* tempTake1= [tempPath stringByAppendingPathComponent:[self createCUID:@"gengmei_"]];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(iWidth, iHeight), NO, 0.0);
        [self.glPreview drawViewHierarchyInRect:CGRectMake(0, 0, iWidth, iHeight) afterScreenUpdates:YES];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        NSLog(@"LOGG  %f  %f  ",image.size.width,image.size.height);
        UIGraphicsEndImageContext();
        NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
        [imageData writeToFile:tempTake1 atomically:YES];
        MyTestVC* ppvc=[MyTestVC new];
        ppvc.imageOriginal = image;
        ppvc.oriPath=tempTake1;
        ppvc.makeIndex=self.now_index;
        ppvc.modalPresentationStyle = UIModalPresentationFullScreen;
//        [self jumpViewControllerAndCloseSelf:ppvc];
//        [self.navigationController pushViewController:ppvc animated:YES];
//        [self dismissViewControllerAnimated:YES completion:nil];
        [self presentViewController:ppvc animated:YES completion:nil];
        //        [assetLibrary writeImageToSavedPhotosAlbum:image.CGImage
        //                                       orientation:ALAssetOrientationUp
        //                                   completionBlock:^(NSURL *assetURL, NSError *error) {
        //            self.lblSaveStatus.text = @"图片已保存到相册";
        //            //                                       [self showAnimationIfSaved:error == nil];
        //        }];
        
    });
    
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


- (UILabel *)lblSaveStatus {
    
    if (!_lblSaveStatus) {
        
        _lblSaveStatus = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 266) / 2, -44, 266, 44)];
        [_lblSaveStatus setFont:[UIFont systemFontOfSize:18.0]];
        [_lblSaveStatus setTextAlignment:NSTextAlignmentCenter];
        [_lblSaveStatus setTextColor:UIColorFromRGB(0xffffff)];
        [_lblSaveStatus setBackgroundColor:UIColorFromRGB(0x000000)];
        
        _lblSaveStatus.layer.cornerRadius = 22;
        _lblSaveStatus.clipsToBounds = YES;
        _lblSaveStatus.alpha = 0.6;
        
        _lblSaveStatus.text = @"图片已保存到相册";
        _lblSaveStatus.hidden = YES;
    }
    
    return _lblSaveStatus;
}

#pragma mark - handle texture

- (void)initResultTexture {
    // 创建结果纹理
    [self setupTextureWithPixelBuffer:&_cvBeautifyBuffer
                                    w:self.imageWidth
                                    h:self.imageHeight
                            glTexture:&_textureBeautifyOutput
                            cvTexture:&_cvTextureBeautify];
    
    [self setupTextureWithPixelBuffer:&_cvStickerBuffer
                                    w:self.imageWidth
                                    h:self.imageHeight
                            glTexture:&_textureStickerOutput
                            cvTexture:&_cvTextureSticker];
    
    [self setupTextureWithPixelBuffer:&_cvMakeUpBuffer
                                    w:self.imageWidth
                                    h:self.imageHeight
                            glTexture:&_textureMakeUpOutput
                            cvTexture:&_cvTextureMakeup];
    
    [self setupTextureWithPixelBuffer:&_cvFilterBuffer
                                    w:self.imageWidth
                                    h:self.imageHeight
                            glTexture:&_textureFilterOutput
                            cvTexture:&_cvTextureFilter];
}

- (BOOL)setupTextureWithPixelBuffer:(CVPixelBufferRef *)pixelBufferOut
                                  w:(int)iWidth
                                  h:(int)iHeight
                          glTexture:(GLuint *)glTexture
                          cvTexture:(CVOpenGLESTextureRef *)cvTexture {
    CFDictionaryRef empty = CFDictionaryCreate(kCFAllocatorDefault,
                                               NULL,
                                               NULL,
                                               0,
                                               &kCFTypeDictionaryKeyCallBacks,
                                               &kCFTypeDictionaryValueCallBacks);
    
    CFMutableDictionaryRef attrs = CFDictionaryCreateMutable(kCFAllocatorDefault,
                                                             1,
                                                             &kCFTypeDictionaryKeyCallBacks,
                                                             &kCFTypeDictionaryValueCallBacks);
    
    CFDictionarySetValue(attrs, kCVPixelBufferIOSurfacePropertiesKey, empty);
    
    CVReturn cvRet = CVPixelBufferCreate(kCFAllocatorDefault,
                                         iWidth,
                                         iHeight,
                                         kCVPixelFormatType_32BGRA,
                                         attrs,
                                         pixelBufferOut);
    
    if (kCVReturnSuccess != cvRet) {
        
        NSLog(@"CVPixelBufferCreate %d" , cvRet);
    }
    
    cvRet = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                         _cvTextureCache,
                                                         *pixelBufferOut,
                                                         NULL,
                                                         GL_TEXTURE_2D,
                                                         GL_RGBA,
                                                         self.imageWidth,
                                                         self.imageHeight,
                                                         GL_BGRA,
                                                         GL_UNSIGNED_BYTE,
                                                         0,
                                                         cvTexture);
    
    CFRelease(attrs);
    CFRelease(empty);
    
    if (kCVReturnSuccess != cvRet) {
        
        NSLog(@"CVOpenGLESTextureCacheCreateTextureFromImage %d" , cvRet);
        
        return NO;
    }
    
    *glTexture = CVOpenGLESTextureGetName(*cvTexture);
    glBindTexture(CVOpenGLESTextureGetTarget(*cvTexture), *glTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    return YES;
}


- (st_rotate_type)getRotateType
{
    BOOL isFrontCamera = self.stCamera.devicePosition == AVCaptureDevicePositionFront;
    BOOL isVideoMirrored = self.stCamera.videoConnection.isVideoMirrored;
    
    [self getDeviceOrientation:self.motionManager.accelerometerData];
    
    switch (_deviceOrientation) {
            
        case UIDeviceOrientationPortrait:
            return ST_CLOCKWISE_ROTATE_0;
            
        case UIDeviceOrientationPortraitUpsideDown:
            return ST_CLOCKWISE_ROTATE_180;
            
        case UIDeviceOrientationLandscapeLeft:
            return ((isFrontCamera && isVideoMirrored) || (!isFrontCamera && !isVideoMirrored)) ? ST_CLOCKWISE_ROTATE_270 : ST_CLOCKWISE_ROTATE_90;
            
        case UIDeviceOrientationLandscapeRight:
            return ((isFrontCamera && isVideoMirrored) || (!isFrontCamera && !isVideoMirrored)) ? ST_CLOCKWISE_ROTATE_90 : ST_CLOCKWISE_ROTATE_270;
            
        default:
            return ST_CLOCKWISE_ROTATE_0;
    }
}



- (void)requestPermissions {
    ALAssetsLibrary *photoLibrary = [[ALAssetsLibrary alloc] init];
    [photoLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:nil failureBlock:nil];
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {}];
    
    
    self.isFirstLaunch = [[NSUserDefaults standardUserDefaults] objectForKey:@"FIRSTLAUNCH"] == nil;
    if (self.isFirstLaunch) {
        
        [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"FIRSTLAUNCH"];
    }
}


- (void)setupCameraAndPreview {
    
    self.stCamera = [[STCamera alloc] initWithDevicePosition:AVCaptureDevicePositionFront
                                              sessionPresset:self.currentSessionPreset
                                                         fps:30
                                               needYuvOutput:NO];
    self.stCamera.delegate = self;
    
    _result_score = 0.0;
    
    CGRect previewRect = [self.stCamera getZoomedRectWithRect:CGRectMake(0 , 0 , SCREEN_WIDTH, SCREEN_HEIGHT) scaleToFit:NO];
    
    self.glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    EAGLContext *previewContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:self.glContext.sharegroup];
    
    self.glPreview = [[STGLPreview alloc] initWithFrame:previewRect context:previewContext];
    self.previewFrame = previewRect;
    self.previewCenter = self.glPreview.center;
    
    [self.view insertSubview:self.glPreview atIndex:0];
    [self.glPreview addSubview:self.focusImageView];
    
    self.commonObjectContainerView = [[STCommonObjectContainerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.commonObjectContainerView.delegate = self;
    [self.view insertSubview:self.commonObjectContainerView atIndex:1];
}



#pragma mark - setup handle

- (void)setupHandle {
    
    st_result_t iRet = ST_OK;
    
    //初始化检测模块句柄
    NSString *strModelPath = [[NSBundle mainBundle] pathForResource:@"M_SenseME_Face_Video_5.3.3" ofType:@"model"];
    
    uint32_t config = ST_MOBILE_HUMAN_ACTION_DEFAULT_CONFIG_VIDEO;
    
    TIMELOG(key);
    
    iRet = st_mobile_human_action_create(strModelPath.UTF8String, config, &_hDetector);
    
    TIMEPRINT(key,"human action create time:");
    
    if (ST_OK != iRet || !_hDetector) {
        
        NSLog(@"st mobile human action create failed: %d", iRet);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"算法SDK初始化失败，可能是模型路径错误，SDK权限过期，与绑定包名不符" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        
        [alert show];
    } else {
        
        addSubModel(_hDetector, @"M_SenseME_Face_Extra_5.23.0");
        addSubModel(_hDetector, @"M_SenseME_Iris_2.0.0");
        addSubModel(_hDetector, @"M_SenseME_Hand_5.4.0");
        addSubModel(_hDetector, @"M_SenseME_Segment_1.5.0");
        addSubModel(_hDetector, @"M_SenseME_Avatar_Help_new");
        //#if TEST_BODY_BEAUTY
        //        addSubModel(_hDetector, @"M_SenseME_Body_Contour_73_1.2.0");
        //#endif
    }
    
    //    //猫脸检测
    //    NSString *catFaceModel = [[NSBundle mainBundle] pathForResource:@"M_SenseME_CatFace_2.0.0" ofType:@"model"];
    //
    //    TIMELOG(keyCat);
    //
    //    iRet = st_mobile_tracker_animal_face_create(catFaceModel.UTF8String, ST_MOBILE_TRACKING_MULTI_THREAD, &_animalHandle);
    
    //    TIMEPRINT(keyCat, "cat handle create time:")
    
    //    if (iRet != ST_OK || !_animalHandle) {
    //        NSLog(@"st mobile tracker animal face create failed: %d", iRet);
    //    }
#if TEST_AVATAR_EXPRESSION
    //avatar expression
    //如要获取avatar表情信息，需创建avatar句柄
    NSString *strAvatarModelPath = [[NSBundle mainBundle] pathForResource:@"M_SenseME_Avatar_Core_2.0.0" ofType:@"model"];
    iRet = st_mobile_avatar_create(&_avatarHandle, strAvatarModelPath.UTF8String);
    if (iRet != ST_OK) {
        NSLog(@"st mobile avatar create failed: %d", iRet);
    } else {
        //然后获取此功能需要human action检测的参数(即st_mobile_human_action_detect接口需要传入的config参数，例如avatar需要获取眼球关键点信息，st_mobile_avatar_get_detect_config就会返回眼球检测的config，通常会返回多个检测的`|`)
        self.avatarConfig = st_mobile_avatar_get_detect_config(_avatarHandle);
    }
#endif
    
    
#if ENABLE_FACE_ATTRIBUTE_DETECT
    //初始化人脸属性模块句柄
    NSString *strAttriModelPath = [[NSBundle mainBundle] pathForResource:@"M_SenseME_Attribute_1.0.1" ofType:@"model"];
    
    iRet = st_mobile_face_attribute_create(strAttriModelPath.UTF8String, &_hAttribute);
    
    if (ST_OK != iRet || !_hAttribute) {
        
        NSLog(@"st mobile face attribute create failed: %d", iRet);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"属性SDK初始化失败，可能是模型路径错误，SDK权限过期，与绑定包名不符" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alert show];
    }
#endif
    
    
    //初始化美颜模块句柄
    iRet = st_mobile_beautify_create(&_hBeautify);
    
    if (ST_OK != iRet || !_hBeautify) {
        
        NSLog(@"st mobile beautify create failed: %d", iRet);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"美颜SDK初始化失败，可能是模型路径错误，SDK权限过期，与绑定包名不符" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        
        [alert show];
        
    }else{
        
        //        setBeautifyParam(_hBeautify, ST_BEAUTIFY_SMOOTH_MODE, 0.0);
        
        // 设置默认红润参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_REDDEN_STRENGTH, self.fReddenStrength);
        // 设置默认磨皮参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_SMOOTH_STRENGTH, 0.4);
        // 设置默认大眼参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, self.fEnlargeEyeStrength);
        // 设置默认瘦脸参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_SHRINK_FACE_RATIO, self.fShrinkFaceStrength);
        // 设置小脸参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_SHRINK_JAW_RATIO, self.fShrinkJawStrength);
        // 设置美白参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_WHITEN_STRENGTH, 0.4);
        //设置对比度参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_CONTRAST_STRENGTH, self.fContrastStrength);
        //设置饱和度参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_SATURATION_STRENGTH, self.fSaturationStrength);
        //瘦脸型
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_THIN_FACE_SHAPE_RATIO, self.fThinFaceShapeStrength);
        //窄脸
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_NARROW_FACE_STRENGTH, self.fNarrowFaceStrength);
        //圆眼
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_ROUND_EYE_RATIO, self.fRoundEyeStrength);
        //下巴
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_CHIN_LENGTH_RATIO, self.fChinStrength);
        //额头
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_HAIRLINE_HEIGHT_RATIO, self.fHairLineStrength);
        //瘦鼻翼
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_NARROW_NOSE_RATIO, self.fNarrowNoseStrength);
        //长鼻
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_NOSE_LENGTH_RATIO, self.fLongNoseStrength);
        //嘴形
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_MOUTH_SIZE_RATIO, self.fMouthStrength);
        //缩人中
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_PHILTRUM_LENGTH_RATIO, self.fPhiltrumStrength);
        
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_APPLE_MUSLE_RATIO, self.fAppleMusleStrength);
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_PROFILE_RHINOPLASTY_RATIO, self.fProfileRhinoplastyStrength);
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, self.fEyeDistanceStrength);
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_ANGLE_RATIO, self.fEyeAngleStrength);
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_OPEN_CANTHUS_RATIO, self.fOpenCanthusStrength);
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_BRIGHT_EYE_RATIO, self.fBrightEyeStrength);
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_REMOVE_DARK_CIRCLES_RATIO, self.fRemoveDarkCirclesStrength);
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_REMOVE_NASOLABIAL_FOLDS_RATIO, self.fRemoveNasolabialFoldsStrength);
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_WHITE_TEETH_RATIO, self.fWhiteTeethStrength);
    }
    
}


- (void)addGestureRecoginzer {
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScreen:)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}
- (void)tapScreen:(UITapGestureRecognizer *)tapGesture {
    
    CGPoint point = [tapGesture locationInView:self.glPreview];
    
    self.focusImageView.center = point;
    self.focusImageView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    self.focusImageView.alpha = 1.0;
    [UIView animateWithDuration:0.5 animations:^{
        self.focusImageView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusImageView.alpha = 0;
    }];
    
    self.currentTime = CFAbsoluteTimeGetCurrent();
    
    [self.stCamera setExposurePoint:point inPreviewFrame:self.glPreview.frame];
    
}

#pragma mark - STCommonObjectContainerViewDelegate

- (void)commonObjectViewStartTrackingFrame:(CGRect)frame {
    
    _commonObjectViewAdded = YES;
    _commonObjectViewSetted = NO;
    
    CGRect rect = frame;
    _rect.left = (rect.origin.x + _margin) / _scale;
    _rect.top = rect.origin.y / _scale;
    _rect.right = (rect.origin.x + rect.size.width + _margin) / _scale;
    _rect.bottom = (rect.origin.y + rect.size.height) / _scale;
    
}

- (void)commonObjectViewFinishTrackingFrame:(CGRect)frame {
    _commonObjectViewAdded = NO;
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
    self.isComparing = YES;
}

- (void)onBtnCompareTouchUpInside:(UIButton *)sender {
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.isComparing = NO;
}



#pragma mark - draw points

- (void)drawKeyPoints:(st_mobile_human_action_t)detectResult {
    NSMutableArray * arrayFace = [NSMutableArray array];
    
    for (int i = 0; i < detectResult.face_count; ++i) {
        
        for (int j = 0; j < 106; ++j) {
            [arrayFace addObject:@{
                POINT_KEY: [NSValue valueWithCGPoint:[self coordinateTransformation:detectResult.p_faces[i].face106.points_array[j]]]
            }];
        }
//
//        if (detectResult.p_faces[i].p_extra_face_points && detectResult.p_faces[i].extra_face_points_count > 0) {
//
//            for (int j = 0; j < detectResult.p_faces[i].extra_face_points_count; ++j) {
//                [arrayFace addObject:@{
//                    POINT_KEY: [NSValue valueWithCGPoint:[self coordinateTransformation:detectResult.p_faces[i].p_extra_face_points[j]]]
//                }];
//            }
//        }
//
//        if (detectResult.p_faces[i].p_eyeball_contour && detectResult.p_faces[i].eyeball_contour_points_count > 0) {
//
//            for (int j = 0; j < detectResult.p_faces[i].eyeball_contour_points_count; ++j) {
//                [arrayFace addObject:@{
//                    POINT_KEY: [NSValue valueWithCGPoint:[self coordinateTransformation:detectResult.p_faces[i].p_eyeball_contour[j]]]
//                }];
//            }
//        }
//
    }
    
//    if (detectResult.p_bodys && detectResult.body_count > 0) {
//
//        for (int j = 0; j < detectResult.p_bodys[0].key_points_count; ++j) {
//
//            if (detectResult.p_bodys[0].p_key_points_score[j] > 0.15) {
//                [arrayFace addObject:@{
//                    POINT_KEY: [NSValue valueWithCGPoint:[self coordinateTransformation:detectResult.p_bodys[0].p_key_points[j]]]
//                }];
//            }
//        }
//    }
    if([arrayFace count]>0&&self.now_index!=0){
        self.outputStep++;
    }
    if(self.now_index==0){
        self.outputStep=-1;
    }
    self.commonObjectContainerView.step=self.outputStep;
           self.commonObjectContainerView.stepCount=60;
           self.commonObjectContainerView.radomIndex=self.radomIndex;
           self.commonObjectContainerView.faceArray = arrayFace;
           dispatch_async(dispatch_get_main_queue(), ^{
               [self.commonObjectContainerView setNeedsDisplay];
           });
}

- (void)commonSetBuity:(float)progress :(NSString *)what{
    if(progress>0.9){
        progress=1.0;
    }
    float toNumber=0.98;
    float testValue=(toNumber)*progress;
    if([what isEqualToString:@"rz"]){
        if(self.now_index==1){
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, -testValue);
        }else{
            float value=([[self.dataArry[self.now_index] arr][13]floatValue])*progress;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, value);
        }
    }else if([what isEqualToString:@"eye"]){
        if(self.now_index==1){
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, -toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, testValue);
        }else{
            float value=([[self.dataArry[self.now_index] arr][1]floatValue])*progress;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, value);
        }
    }else if([what isEqualToString:@"nose"]){
        if(self.now_index==1){
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, -toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_NARROW_NOSE_RATIO, testValue);
        }else{
            float value=([[self.dataArry[self.now_index] arr][9]floatValue])*progress;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_NARROW_NOSE_RATIO, value);
        }
    }
    else if([what isEqualToString:@"lip"]){
        if(self.now_index==1){
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, -toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_NARROW_NOSE_RATIO, toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_MOUTH_SIZE_RATIO, -testValue);
        }else{
            float value=([[self.dataArry[self.now_index] arr][11]floatValue])*progress;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_MOUTH_SIZE_RATIO, value);
        }
    }
    
    else if([what isEqualToString:@"xb"]){
        if(self.now_index==1){
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, -toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_NARROW_NOSE_RATIO, toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_MOUTH_SIZE_RATIO, -toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_CHIN_LENGTH_RATIO, testValue);
        }else{
            float value=([[self.dataArry[self.now_index] arr][6]floatValue])*progress;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_CHIN_LENGTH_RATIO,value);
        }
    }
    
    else if([what isEqualToString:@"face"]){
        if(self.now_index==1){
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, -toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_NARROW_NOSE_RATIO, toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_MOUTH_SIZE_RATIO, -toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_CHIN_LENGTH_RATIO, toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_NARROW_FACE_STRENGTH, testValue);
        }else{
            float value=([[self.dataArry[self.now_index] arr][3]floatValue])*progress;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_NARROW_FACE_STRENGTH, value);
        }
    }
}

 -(int)getRandomNumber:(int)from to:(int)to
{
    return (int)(from + (arc4random() % (to-from + 1)));
}

@end

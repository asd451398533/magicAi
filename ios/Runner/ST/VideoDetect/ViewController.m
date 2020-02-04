//
//  ViewController.m
//
//  Created by HaifengMay on 16/11/7.
//  Copyright © 2016年 SenseTime. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
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

#import "SenseArSourceService.h"
#import "STCustomMemoryCache.h"
#import "EffectsCollectionView.h"
#import "EffectsCollectionViewCell.h"

#import "STBMPCollectionView.h"
#import "STBmpStrengthView.h"

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

#define DRAW_FACE_KEY_POINTS 0
#define ENABLE_FACE_ATTRIBUTE_DETECT 0
#define TEST_OUTPUT_BUFFER_INTERFACE 0
#define TEST_BODY_BEAUTY 0

#define TEST_AVATAR_EXPRESSION 0

typedef NS_ENUM(NSInteger, STViewTag) {
    
    STViewTagSpecialEffectsBtn = 10000,
    STViewTagBeautyBtn,
};

typedef NS_ENUM(NSInteger, STWriterRecordingStatus){
    STWriterRecordingStatusIdle = 0,
    STWriterRecordingStatusStartingRecording,
    STWriterRecordingStatusRecording,
    STWriterRecordingStatusStoppingRecording
};

@protocol STEffectsMessageDelegate <NSObject>

- (void)loadSound:(NSData *)soundData name:(NSString *)strName;
- (void)playSound:(NSString *)strName loop:(int)iLoop;
- (void)pauseSound:(NSString *)strName;
- (void)resumeSound:(NSString *)strName;
- (void)stopSound:(NSString *)strName;
- (void)unloadSound:(NSString *)strName;
- (void)packageEvent:(NSString *)packageName
           packageID:(int)packageID
               event:(int)event
      displayedFrame:(int)displayedFrame;
@end


@interface STEffectsMessageManager : NSObject

@property (nonatomic, readwrite, weak) id<STEffectsMessageDelegate> delegate;
@end

@implementation STEffectsMessageManager

@end

STEffectsMessageManager *messageManager = nil;

@interface ViewController () <STCameraDelegate, STCommonObjectContainerViewDelegate, STViewButtonDelegate, STMovieRecorderDelegate, STEffectsAudioPlayerDelegate, STEffectsMessageDelegate, STEffectsTimerDelegate, PhotoSelectVCDismissDelegate, STAudioManagerDelegate, UIWebViewDelegate, UIGestureRecognizerDelegate, STBeautySliderDelegate, STBMPCollectionViewDelegate, STBmpStrengthViewDelegate>
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

//bottom tab bar
@property (nonatomic, readwrite, strong) STViewButton *specialEffectsBtn;
@property (nonatomic, readwrite, strong) STViewButton *beautyBtn;
@property (nonatomic, readwrite, strong) STViewButton *snapBtn;

//resolution change btn
@property (nonatomic, readwrite, strong) UIButton *btn640x480;
@property (nonatomic, readwrite, strong) UIButton *btn1280x720;
@property (nonatomic, readwrite, strong) UIButton *btn1920x1080;
@property (nonatomic, readwrite, strong) CAShapeLayer *btn640x480BorderLayer;
@property (nonatomic, readwrite, strong) CAShapeLayer *btn1280x720BorderLayer;
@property (nonatomic, readwrite, strong) CAShapeLayer *btn1920x1080BorderLayer;

@property (nonatomic, readwrite, strong) UIButton *btnChangeCamera;
@property (nonatomic, readwrite, strong) UIButton *btnCompare;
@property (nonatomic, readwrite, strong) UIButton *btnSetting;
@property (nonatomic, readwrite, strong) STButton *btnAlbum;

@property (nonatomic, readwrite, strong) UIView *gradientView;
@property (nonatomic, readwrite, strong) UIView *specialEffectsContainerView;
@property (nonatomic, readwrite, strong) UIView *beautyContainerView;
@property (nonatomic, readwrite, strong) UIView *filterCategoryView;

@property (nonatomic, readwrite, strong) UIView *filterSwitchView;
@property (nonatomic, readwrite, strong) STFilterView *filterView;

@property (nonatomic, strong) UIView *termsOfUseView;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;

@property (nonatomic, readwrite, strong) UIView *beautyShapeView;
@property (nonatomic, readwrite, strong) UIView *beautyBaseView;
@property (nonatomic, strong) UIView *beautyBodyView;

@property (nonatomic, readwrite, strong) UIView *settingView;

@property (nonatomic, readwrite, strong) UIImageView *recordImageView;
@property (nonatomic, readwrite, strong) UIView *filterStrengthView;

@property (nonatomic, readwrite, strong) STScrollTitleView *scrollTitleView;
@property (nonatomic, strong) STScrollTitleView *beautyScrollTitleViewNew;

@property (nonatomic , strong) STCustomMemoryCache *effectsDataSource;
@property (nonatomic , strong) EffectsCollectionView *effectsList;
@property (nonatomic, readwrite, strong) STCollectionView *objectTrackCollectionView;
@property (nonatomic, readwrite, strong) STFilterCollectionView *filterCollectionView;

@property (nonatomic, strong) STTriggerView *triggerView;

@property (nonatomic, readwrite, strong) NSMutableArray *arrBeautyViews;
@property (nonatomic, readwrite, strong) NSMutableArray<STViewButton *> *arrFilterCategoryViews;



@property (nonatomic, readwrite, assign) BOOL specialEffectsContainerViewIsShow;
@property (nonatomic, readwrite, assign) BOOL beautyContainerViewIsShow;
@property (nonatomic, readwrite, assign) BOOL settingViewIsShow;

@property (nonatomic, readwrite, assign) unsigned long long iCurrentAction;
@property (nonatomic, readwrite, assign) unsigned long long makeUpConf;
@property (nonatomic, readwrite, assign) unsigned long long stickerConf;

@property (nonatomic, assign) BOOL bMakeUp;

#if TEST_AVATAR_EXPRESSION
@property (nonatomic, assign) unsigned long long avatarConfig;
#endif

@property (nonatomic, readwrite, assign) BOOL needSnap;
@property (nonatomic, readwrite, assign) BOOL pauseOutput;
@property (nonatomic, readwrite, assign) BOOL isAppActive;

@property (nonatomic, readwrite, assign) CGFloat imageWidth;
@property (nonatomic, readwrite, assign) CGFloat imageHeight;


//bottom tab bar status
@property (nonatomic, readwrite, assign) BOOL bAttribute;
@property (nonatomic, readwrite, assign) BOOL bBeauty;
@property (nonatomic, readwrite, assign) BOOL bSticker;
@property (nonatomic, readwrite, assign) BOOL bTracker;
@property (nonatomic, readwrite, assign) BOOL bFilter;

@property (nonatomic, assign) BOOL needDetectAnimal;
@property (nonatomic, assign) BOOL isComparing;

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

@property (nonatomic, assign) float fContrastStrength;
@property (nonatomic, assign) float fSaturationStrength;

//filter value
@property (nonatomic, assign) float fFilterStrength;

@property (nonatomic, strong) UILabel *lblAttribute;
@property (nonatomic, strong) UILabel *lblSpeed;
@property (nonatomic, strong) UILabel *lblCPU;
@property (nonatomic, strong) UILabel *lblSaveStatus;
@property (nonatomic, strong) UILabel *lblFilterStrength;
@property (nonatomic, strong) UILabel *lblTermsOfUse;

@property (nonatomic, readwrite, strong) UILabel *resolutionLabel;
@property (nonatomic, readwrite, strong) UILabel *attributeLabel;

@property (nonatomic, readwrite, strong) UISwitch *attributeSwitch;

@property (nonatomic, strong) STCamera *stCamera;
@property (nonatomic, strong) STGLPreview *glPreview;
@property (nonatomic, strong) STAudioManager *audioManager;
@property (nonatomic, readwrite, strong) STCommonObjectContainerView *commonObjectContainerView;

@property (nonatomic, strong) EAGLContext *glContext;
@property (nonatomic, strong) CIContext *ciContext;

@property (nonatomic, assign) CGFloat scale;  //视频充满全屏的缩放比例
@property (nonatomic, assign) int margin;
@property (nonatomic, assign, getter=isCommonObjectViewAdded) BOOL commonObjectViewAdded;
@property (nonatomic, assign, getter=isCommonObjectViewSetted) BOOL commonObjectViewSetted;

@property (nonatomic, strong) NSMutableArray *arrPersons;
@property (nonatomic, strong) NSMutableArray *arrPoints;

@property (nonatomic, assign) double lastTimeAttrDetected;


@property (nonatomic) dispatch_queue_t thumbDownlaodQueue;
@property (nonatomic, strong) NSOperationQueue *imageLoadQueue;
@property (nonatomic , strong) STCustomMemoryCache *thumbnailCache;
@property (nonatomic , strong) NSFileManager *fManager;
@property (nonatomic , copy) NSString *strThumbnailPath;


@property (nonatomic , assign) CGPoint previewCenter;
@property (nonatomic , assign) CGRect previewFrame;


@property (nonatomic , strong) NSArray *arrCurrentModels;
@property (nonatomic , strong) EffectsCollectionViewCellModel *prepareModel;
@property (nonatomic, readwrite, strong) NSArray *arrObjectTrackers;


//record
@property (nonatomic, readwrite, strong) STMovieRecorder *stRecoder;
@property (nonatomic, readwrite, strong) dispatch_queue_t callBackQueue;
@property (nonatomic, readwrite, assign, getter=isRecording) BOOL recording;
@property (nonatomic, readwrite, assign) STWriterRecordingStatus recordStatus;
@property (nonatomic, readwrite, strong) NSURL *recorderURL;
@property (nonatomic, readwrite, assign) CMFormatDescriptionRef outputVideoFormatDescription;
@property (nonatomic, readwrite, assign) CMFormatDescriptionRef outputAudioFormatDescription;
@property (nonatomic, readwrite, assign) double recordStartTime;

@property (nonatomic, readwrite, strong) STEffectsAudioPlayer *audioPlayer;

@property (nonatomic, readwrite, strong) NSString *currentSessionPreset;

@property (nonatomic, readwrite, strong) UILabel *recordTimeLabel;

@property (nonatomic, readwrite, strong) STEffectsTimer *timer;
@property (nonatomic, strong) NSTimer *ISOSliderTimer;

@property (nonatomic, readwrite, strong) UIImageView *noneStickerImageView;

@property (nonatomic, readwrite, assign) BOOL isNullSticker;
@property (nonatomic, readwrite, assign) BOOL filterStrengthViewHiddenState;

@property (nonatomic, readwrite, strong) UISlider *filterStrengthSlider;
@property (nonatomic, readwrite, strong) STCollectionViewDisplayModel *currentSelectedFilterModel;

@property (nonatomic, strong) NSMutableArray *faceArray;

@property (nonatomic) dispatch_queue_t changeModelQueue;
@property (nonatomic) dispatch_queue_t changeStickerQueue;
@property (nonatomic) dispatch_queue_t renderQueue;


@property (nonatomic, copy) NSString *preFilterModelPath;
@property (nonatomic, copy) NSString *curFilterModelPath;

@property (nonatomic, copy) NSString *strBodyAction;
@property (nonatomic, strong) UILabel *lblBodyAction;

@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic) UIDeviceOrientation deviceOrientation;

@property (nonatomic, strong) NSArray<STNewBeautyCollectionViewModel *> *microSurgeryModels;
@property (nonatomic, strong) NSArray<STNewBeautyCollectionViewModel *> *baseBeautyModels;
@property (nonatomic, strong) NSArray<STNewBeautyCollectionViewModel *> *beautyShapeModels;
@property (nonatomic, strong) NSArray<STNewBeautyCollectionViewModel *> *adjustModels;
@property (nonatomic, strong) STNewBeautyCollectionView *beautyCollectionView;
@property (nonatomic, strong) STBeautySlider *beautySlider;
@property (nonatomic, assign) STEffectsType curEffectStickerType;
@property (nonatomic, assign) STEffectsType curEffectBeautyType;
@property (nonatomic, assign) STBeautyType curBeautyBeautyType;
@property (nonatomic, strong) UIButton *resetBtn;

@property (nonatomic , assign) int iBufferedCount;
@property (nonatomic , assign) BOOL isFirstLaunch;


@property (nonatomic, strong) UIImageView *focusImageView;
@property (nonatomic, strong) UISlider *ISOSlider;
@property (nonatomic, assign) BOOL bExposured;

@property (nonatomic , strong) NSData *licenseData;
@property (nonatomic) double currentTime;

//beauty make up
@property (nonatomic, strong) STBMPCollectionView *bmpColView;
@property (nonatomic, strong) STBMPModel *bmp_Current_Model;
@property (nonatomic, strong) STBMPModel *bmp_Eye_Model;
@property (nonatomic, strong) STBMPModel *bmp_EyeLiner_Model;
@property (nonatomic, strong) STBMPModel *bmp_EyeLash_Model;
@property (nonatomic, strong) STBMPModel *bmp_Lip_Model;
@property (nonatomic, strong) STBMPModel *bmp_Brow_Model;
@property (nonatomic, strong) STBMPModel *bmp_Nose_Model;
@property (nonatomic, strong) STBMPModel *bmp_Face_Model;
@property (nonatomic, strong) STBMPModel *bmp_Blush_Model;
@property (nonatomic, strong) STBMPModel *bmp_Eyeball_Model;

@property (nonatomic, assign) float bmp_Eye_Value;
@property (nonatomic, assign) float bmp_EyeLiner_Value;
@property (nonatomic, assign) float bmp_EyeLash_Value;
@property (nonatomic, assign) float bmp_Lip_Value;
@property (nonatomic, assign) float bmp_Brow_Value;
@property (nonatomic, assign) float bmp_Nose_Value;
@property (nonatomic, assign) float bmp_Face_Value;
@property (nonatomic, assign) float bmp_Blush_Value;
@property (nonatomic, assign) float bmp_Eyeball_Value;

@property (nonatomic, strong) STBmpStrengthView *bmpStrenghView;

@end

@implementation ViewController

#pragma mark - life cycle

- (void)loadView {
    [super loadView];
    
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    [self setDefaultValue];
    
    [self setupSubviews];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self setupUtilTools];
    
    [self requestPermissions];
    
    [self addNotifications];
    
    [self addGestureRecoginzer];
    
    [self setupThumbnailCache];
    [self setupSenseArService];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setExclusiveTouchForButtons:self.view];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self resetBmp];
}

-(void)setExclusiveTouchForButtons:(UIView *)myView {
    for (UIView * v in [myView subviews]) {
        [v setExclusiveTouch:YES];
    }
}

- (void)setupUtilTools {
    
    self.audioManager = [[STAudioManager alloc] init];
    self.audioManager.delegate = self;
    
    self.audioPlayer = [[STEffectsAudioPlayer alloc] init];
    self.audioPlayer.delegate = self;
    
    messageManager = [[STEffectsMessageManager alloc] init];
    messageManager.delegate = self;
    
    self.timer = [[STEffectsTimer alloc] init];
    self.timer.delegate = self;
    
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.accelerometerUpdateInterval = 0.5;
    self.motionManager.deviceMotionUpdateInterval = 1 / 25.0;
}

- (void)setupThumbnailCache
{
    self.thumbDownlaodQueue = dispatch_queue_create("com.sensetime.thumbDownloadQueue", NULL);
    self.imageLoadQueue = [[NSOperationQueue alloc] init];
    self.imageLoadQueue.maxConcurrentOperationCount = 20;
    
    self.thumbnailCache = [[STCustomMemoryCache alloc] init];
    self.fManager = [[NSFileManager alloc] init];
    
    // 可以根据实际情况实现素材列表缩略图的缓存策略 , 这里仅做演示 .
    self.strThumbnailPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"senseme_thumbnail"];
    
    NSError *error = nil;
    BOOL bCreateSucceed = [self.fManager createDirectoryAtPath:self.strThumbnailPath
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error];
    if (!bCreateSucceed || error) {
        
        STLog(@"create thumbnail cache directory failed !");
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"创建列表图片缓存文件夹失败" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        
        [alert show];
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

- (void)addNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
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
    
    self.ISOSlider.hidden = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.focusImageView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusImageView.alpha = 0;
    }];
    
    self.currentTime = CFAbsoluteTimeGetCurrent();
    
    [self.stCamera setExposurePoint:point inPreviewFrame:self.glPreview.frame];
    
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.specialEffectsContainerView] || [touch.view isDescendantOfView:self.beautyContainerView] || [touch.view isDescendantOfView:self.settingView] || [touch.view isDescendantOfView:self.ISOSlider]) {
        return NO;
    } else {
        return YES;
    }
}

- (void)releaseResources
{
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
    
    [self resetSettings];
    
    ///ST_MOBILE：初始化句柄之前需要验证License
    if ([self checkActiveCodeWithData:self.licenseData]) {
        ///ST_MOBILE：初始化相关的句柄
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
    [self.audioManager startRunning];
    
    //默认选中cherry滤镜
    _filterView.filterCollectionView.arrModels = _filterView.filterCollectionView.arrPortraitFilterModels;
    [_filterView.filterCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:[self getBabyPinkFilterIndex] inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    _filterStrengthView.hidden = YES;
}


#pragma mark - setup subviews

- (void)setupSubviews {
    
    [self.view addSubview:self.btnChangeCamera];
    [self.view addSubview:self.lblSaveStatus];
    [self.view addSubview:self.triggerView];
    
    [self.view addSubview:self.specialEffectsContainerView];
    [self.view addSubview:self.beautyContainerView];
    [self.view addSubview:self.settingView];
    
    [self.view addSubview:self.filterStrengthView];
    
    [self.view addSubview:self.beautySlider];
    
    [self.view addSubview:self.specialEffectsBtn];
    [self.view addSubview:self.beautyBtn];
    
    [self.view addSubview:self.gradientView];
    [self.view addSubview:self.snapBtn];
    [self.view addSubview:self.btnCompare];
    [self.view addSubview:self.btnSetting];
    [self.view addSubview:self.btnAlbum];
#if ENABLE_FACE_ATTRIBUTE_DETECT
    [self.view addSubview:self.lblAttribute];
#endif
    [self.view addSubview:self.lblSpeed];
    [self.view addSubview:self.lblCPU];
    [self.view addSubview:self.recordImageView];
    [self.view addSubview:self.recordTimeLabel];
    
    [self.view addSubview:self.termsOfUseView];
    
    [self.view addSubview:self.resetBtn];
    
    //test add and remove submodels
#if ENABLE_DYNAMIC_ADD_AND_REMOVE_MODELS
    [self.view addSubview:self.lblBodyAction];
#endif
    
    [self.view addSubview:self.focusImageView];
    [self.view addSubview:self.ISOSlider];
}

- (UIImageView *)focusImageView {
    if (!_focusImageView) {
        _focusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _focusImageView.image = [UIImage imageNamed:@"camera_focus_red"];
        _focusImageView.alpha = 0;
    }
    return _focusImageView;
}

- (UISlider *)ISOSlider
{
    if (!_ISOSlider) {
        UISlider *slider = [[UISlider alloc] init];
        slider.frame = CGRectMake(0, 0, 200, 50);
        slider.transform = CGAffineTransformMakeRotation(-M_PI_2);
        slider.center= CGPointMake(SCREEN_WIDTH - 15, SCREEN_HEIGHT / 2);
        slider.maximumTrackTintColor = [UIColor whiteColor];
        slider.minimumTrackTintColor = [UIColor whiteColor];
        slider.hidden = YES;
        
        //resize image
        UIImage *imageOriginal = [UIImage imageNamed:@"亮度"];
        UIGraphicsBeginImageContext(CGSizeMake(40, 40));
        [imageOriginal drawInRect:CGRectMake(0, 0, 40, 40)];
        imageOriginal = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [slider setThumbImage:imageOriginal forState:UIControlStateNormal];
        
        slider.minimumValue = 0;
        slider.maximumValue = 280;
        slider.value = 140;
        [slider addTarget:self action:@selector(ISOSliderValueChanging:) forControlEvents:UIControlEventValueChanged];
        [slider addTarget:self action:@selector(ISOSliderValueDidChanged:) forControlEvents:UIControlEventTouchUpInside];
        _ISOSlider = slider;
    }
    return _ISOSlider;
}

- (void)ISOSliderValueChanging:(UISlider *)sender {
    self.currentTime = CFAbsoluteTimeGetCurrent();
    [self.stCamera setISOValue:sender.value];
}

- (void)ISOSliderValueDidChanged:(UISlider *)sender {
    self.currentTime = CFAbsoluteTimeGetCurrent();
}

- (void)setDefaultValue {
    
    self.bAttribute = YES;
    self.bBeauty = YES;
    self.bFilter = NO;
    self.bSticker = NO;
    self.bTracker = NO;
    self.needDetectAnimal = NO;
    
    self.bExposured = NO;
    
    self.isNullSticker = NO;
    
    self.fFilterStrength = 0.65;
    
    self.iCurrentAction = 0;
    
    self.needSnap = NO;
    self.pauseOutput = NO;
    self.isAppActive = YES;
    
    self.imageWidth = 720;
    self.imageHeight = 1280;
    self.currentSessionPreset = AVCaptureSessionPresetHigh;
    
    self.recordStatus = STWriterRecordingStatusIdle;
    self.recording = NO;
    self.recorderURL = [[NSURL alloc] initFileURLWithPath:[NSString pathWithComponents:@[NSTemporaryDirectory(), @"Movie.MOV"]]];
    
    self.outputAudioFormatDescription = nil;
    self.outputVideoFormatDescription = nil;
    
    self.changeModelQueue = dispatch_queue_create("com.sensetime.changemodelqueue", NULL);
    self.changeStickerQueue = dispatch_queue_create("com.sensetime.changestickerqueue", NULL);
    self.renderQueue = dispatch_queue_create("com.sensetime.renderQueue", NULL);
    self.filterStrengthViewHiddenState = YES;
    
    self.preFilterModelPath = nil;
    self.curFilterModelPath = nil;
    
    self.ISOSliderTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (!self.ISOSlider.isHidden && (CFAbsoluteTimeGetCurrent() - self.currentTime > 3.0)) {
            self.ISOSlider.hidden = YES;
        }
    }];
    
    self.curEffectBeautyType = STEffectsTypeBeautyBase;
    
    self.microSurgeryModels = @[
                                getModel([UIImage imageNamed:@"zhailian"], [UIImage imageNamed:@"zhailian_selected"], @"瘦脸型", 0, NO, 0, STEffectsTypeBeautyMicroSurgery, STBeautyTypeThinFaceShape),
                                getModel([UIImage imageNamed:@"xiaba"], [UIImage imageNamed:@"xiaba_selected"], @"下巴", 0, NO, 1, STEffectsTypeBeautyMicroSurgery, STBeautyTypeChin),
                                getModel([UIImage imageNamed:@"etou"], [UIImage imageNamed:@"etou_selected"], @"额头", 0, NO, 2, STEffectsTypeBeautyMicroSurgery, STBeautyTypeHairLine),
                                getModel([UIImage imageNamed:@"苹果机-白"], [UIImage imageNamed:@"苹果机-紫"], @"苹果肌", 0, NO, 3, STEffectsTypeBeautyMicroSurgery, STBeautyTypeAppleMusle),
                                getModel([UIImage imageNamed:@"shoubiyi"], [UIImage imageNamed:@"shoubiyi_selected"], @"瘦鼻翼", 0, NO, 4, STEffectsTypeBeautyMicroSurgery, STBeautyTypeNarrowNose),
                                getModel([UIImage imageNamed:@"changbi"], [UIImage imageNamed:@"changbi_selected"], @"长鼻", 0, NO, 5, STEffectsTypeBeautyMicroSurgery, STBeautyTypeLengthNose),
                                getModel([UIImage imageNamed:@"侧脸隆鼻-白"], [UIImage imageNamed:@"侧脸隆鼻-紫"], @"侧脸隆鼻", 0, NO, 6, STEffectsTypeBeautyMicroSurgery, STBeautyTypeProfileRhinoplasty),
                                getModel([UIImage imageNamed:@"zuixing"], [UIImage imageNamed:@"zuixing_selected"], @"嘴形", 0, NO, 7, STEffectsTypeBeautyMicroSurgery, STBeautyTypeMouthSize),
                                getModel([UIImage imageNamed:@"suorenzhong"], [UIImage imageNamed:@"suorenzhong_selected"], @"缩人中", 0, NO, 8, STEffectsTypeBeautyMicroSurgery, STBeautyTypeLengthPhiltrum),
                                getModel([UIImage imageNamed:@"眼睛距离调整-白"], [UIImage imageNamed:@"眼睛距离调整-紫"], @"眼距", 0, NO, 9, STEffectsTypeBeautyMicroSurgery, STBeautyTypeEyeDistance),
                                getModel([UIImage imageNamed:@"眼睛角度微调-白"], [UIImage imageNamed:@"眼睛角度微调-紫"], @"眼睛角度", 0, NO, 10, STEffectsTypeBeautyMicroSurgery, STBeautyTypeEyeAngle),
                                getModel([UIImage imageNamed:@"开眼角-白"], [UIImage imageNamed:@"开眼角-紫"], @"开眼角", 0, NO, 11, STEffectsTypeBeautyMicroSurgery, STBeautyTypeOpenCanthus),
                                getModel([UIImage imageNamed:@"亮眼-白"], [UIImage imageNamed:@"亮眼-紫"], @"亮眼", 0, NO, 12, STEffectsTypeBeautyMicroSurgery, STBeautyTypeBrightEye),
                                getModel([UIImage imageNamed:@"去黑眼圈-白"], [UIImage imageNamed:@"去黑眼圈-紫"], @"祛黑眼圈", 0, NO, 13, STEffectsTypeBeautyMicroSurgery, STBeautyTypeRemoveDarkCircles),
                                getModel([UIImage imageNamed:@"去法令纹-白"], [UIImage imageNamed:@"去法令纹-紫"], @"祛法令纹", 0, NO, 14, STEffectsTypeBeautyMicroSurgery, STBeautyTypeRemoveNasolabialFolds),
                                getModel([UIImage imageNamed:@"牙齿美白-白"], [UIImage imageNamed:@"牙齿美白-紫"], @"白牙", 0, NO, 15, STEffectsTypeBeautyMicroSurgery, STBeautyTypeWhiteTeeth),
                                ];
    
    self.baseBeautyModels = @[
                              getModel([UIImage imageNamed:@"meibai"], [UIImage imageNamed:@"meibai_selected"], @"美白", 2, NO, 0, STEffectsTypeBeautyBase, STBeautyTypeWhiten),
                              getModel([UIImage imageNamed:@"hongrun"], [UIImage imageNamed:@"hongrun_selected"], @"红润", 36, NO, 1, STEffectsTypeBeautyBase, STBeautyTypeRuddy),
                              getModel([UIImage imageNamed:@"mopi"], [UIImage imageNamed:@"mopi_selected"], @"磨皮", 74, NO, 2, STEffectsTypeBeautyBase, STBeautyTypeDermabrasion),
                              getModel([UIImage imageNamed:@"qugaoguang"], [UIImage imageNamed:@"qugaoguang_selected"], @"去高光", 0, NO, 3, STEffectsTypeBeautyBase, STBeautyTypeDehighlight),
                              ];
    self.beautyShapeModels = @[
                               getModel([UIImage imageNamed:@"shoulian"], [UIImage imageNamed:@"shoulian_selected"], @"瘦脸", 11, NO, 0, STEffectsTypeBeautyShape, STBeautyTypeShrinkFace),
                               getModel([UIImage imageNamed:@"dayan"], [UIImage imageNamed:@"dayan_selected"], @"大眼", 13, NO, 1, STEffectsTypeBeautyShape, STBeautyTypeEnlargeEyes),
                               getModel([UIImage imageNamed:@"xiaolian"], [UIImage imageNamed:@"xiaolian_selected"], @"小脸", 10, NO, 2, STEffectsTypeBeautyShape, STBeautyTypeShrinkJaw),
                               getModel([UIImage imageNamed:@"zhailian2"], [UIImage imageNamed:@"zhailian2_selected"], @"窄脸", 0, NO, 3, STEffectsTypeBeautyShape, STBeautyTypeNarrowFace),
                               getModel([UIImage imageNamed:@"round"], [UIImage imageNamed:@"round_selected"], @"圆眼", 0, NO, 4, STEffectsTypeBeautyShape, STBeautyTypeRoundEye)
                              ];
    self.adjustModels = @[
                          getModel([UIImage imageNamed:@"contrast"], [UIImage imageNamed:@"contrast_selected"], @"对比度", 0, NO, 0, STEffectsTypeBeautyAdjust, STBeautyTypeContrast),
                          getModel([UIImage imageNamed:@"saturation"], [UIImage imageNamed:@"saturation_selected"], @"饱和度", 0, NO, 1, STEffectsTypeBeautyAdjust, STBeautyTypeSaturation),
                          ];
    
    _bmp_Eye_Value = _bmp_EyeLiner_Value = _bmp_EyeLash_Value = _bmp_Lip_Value = _bmp_Brow_Value = _bmp_Nose_Value = _bmp_Face_Value =_bmp_Blush_Value = _bmp_Eyeball_Value = 0.8;
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

#pragma - mark -
#pragma - mark Setup Service

- (void)setupSenseArService {
    
//在线激活，建议在鉴权成功失败的回调中都检查license，鉴权失败时会使用sdk缓存的license
#if USE_ONLINE_ACTIVATION
    STWeakSelf;
    [[SenseArMaterialService sharedInstance]
     authorizeWithAppID:@"6dc0af51b69247d0af4b0a676e11b5ee"
     appKey:@"e4156e4d61b040d2bcbf896c798d06e3"
     onSuccess:^{
         
         [weakSelf checkLicenseFromServer];
         
         dispatch_async(dispatch_get_main_queue(), ^{
             [weakSelf initResourceAndStartPreview];
         });
         
         [[SenseArMaterialService sharedInstance] setMaxCacheSize:120000000];
         
         [weakSelf fetchLists];
     }
     onFailure:^(SenseArAuthorizeError iErrorCode) {
         
         [weakSelf checkLicenseFromServer];
         
         dispatch_async(dispatch_get_main_queue(), ^{
             
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
             
             switch (iErrorCode) {
                     
                 case AUTHORIZE_ERROR_KEY_NOT_MATCHED:
                 {
                     [alert setMessage:@"无效 AppID/SDKKey"];
                 }
                     break;
                     
                     
                 case AUTHORIZE_ERROR_NETWORK_NOT_AVAILABLE:
                 {
                     [alert setMessage:@"网络不可用"];
                 }
                     break;
                     
                 case AUTHORIZE_ERROR_DECRYPT_FAILED:
                 {
                     [alert setMessage:@"解密失败"];
                 }
                     break;
                     
                 case AUTHORIZE_ERROR_DATA_PARSE_FAILED:
                 {
                     [alert setMessage:@"解析失败"];
                 }
                     break;
                     
                 case AUTHORIZE_ERROR_UNKNOWN:
                 {
                     [alert setMessage:@"未知错误"];
                 }
                     break;
                     
                 default:
                     break;
             }
             
             [alert show];
         });
     }];
#else
    //离线激活
    [self checkLicenseFromLocal];
    [self initResourceAndStartPreview];
    [[SenseArMaterialService sharedInstance] setMaxCacheSize:120000000];
    [self fetchLists];
#endif
}

//使用服务器拉取的license进行本地鉴权
- (BOOL)checkLicenseFromServer {
    self.licenseData = [[SenseArMaterialService sharedInstance] getLicenseData];
    return [self checkActiveCodeWithData:self.licenseData];
}
//使用本地license进行本地鉴权
- (BOOL)checkLicenseFromLocal {
    self.licenseData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SENSEME" ofType:@"lic"]];
    return [self checkActiveCodeWithData:self.licenseData];
}

- (void)getLicenseDataOnline:(BOOL)online {
    
    if (online) {
        //获取在线license
        self.licenseData = [[SenseArMaterialService sharedInstance] getLicenseData];
    } else {
        //使用本地license
        self.licenseData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SENSEME" ofType:@"lic"]];
    }
    
    if ([NSThread isMainThread]) {
        [self initResourceAndStartPreview];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initResourceAndStartPreview];
        });
    }
    [[SenseArMaterialService sharedInstance] setMaxCacheSize:120000000];
    [self fetchLists];
}

- (void)fetchLists
{
    self.effectsDataSource = [[STCustomMemoryCache alloc] init];
    
    NSString *strLocalBundlePath = [[NSBundle mainBundle] pathForResource:@"my_sticker" ofType:@"bundle"];
    
    if (strLocalBundlePath) {
        
        NSMutableArray *arrLocalModels = [NSMutableArray array];
        
        NSFileManager *fManager = [[NSFileManager alloc] init];
        
        NSArray *arrFiles = [fManager contentsOfDirectoryAtPath:strLocalBundlePath error:nil];
        
        int indexOfItem = 0;
        for (NSString *strFileName in arrFiles) {
            
            if ([strFileName hasSuffix:@".zip"]) {
                
                NSString *strMaterialPath = [strLocalBundlePath stringByAppendingPathComponent:strFileName];
                NSString *strThumbPath = [[strMaterialPath stringByDeletingPathExtension] stringByAppendingString:@".png"];
                UIImage *imageThumb = [UIImage imageWithContentsOfFile:strThumbPath];
                
                if (!imageThumb) {
                    
                    imageThumb = [UIImage imageNamed:@"none"];
                }
                
                EffectsCollectionViewCellModel *model = [[EffectsCollectionViewCellModel alloc] init];
                
                model.iEffetsType = STEffectsTypeStickerMy;
                model.state = Downloaded;
                model.indexOfItem = indexOfItem;
                model.imageThumb = imageThumb;
                model.strMaterialPath = strMaterialPath;
                
                [arrLocalModels addObject:model];
                
                indexOfItem ++;
            }
        }
        
        NSString *strDocumentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        
        NSString *localStickerPath = [strDocumentsPath stringByAppendingPathComponent:@"local_sticker"];
        if (![fManager fileExistsAtPath:localStickerPath]) {
            [fManager createDirectoryAtPath:localStickerPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        NSArray *arrFileNames = [fManager contentsOfDirectoryAtPath:localStickerPath error:nil];
        
        for (NSString *strFileName in arrFileNames) {
            
            if ([strFileName hasSuffix:@"zip"]) {
                
                NSString *strMaterialPath = [localStickerPath stringByAppendingPathComponent:strFileName];
                NSString *strThumbPath = [[strMaterialPath stringByDeletingPathExtension] stringByAppendingString:@".png"];
                UIImage *imageThumb = [UIImage imageWithContentsOfFile:strThumbPath];
                
                if (!imageThumb) {
                    
                    imageThumb = [UIImage imageNamed:@"none"];
                }
                
                EffectsCollectionViewCellModel *model = [[EffectsCollectionViewCellModel alloc] init];
                
                model.iEffetsType = STEffectsTypeStickerMy;
                model.state = Downloaded;
                model.indexOfItem = indexOfItem;
                model.imageThumb = imageThumb;
                model.strMaterialPath = strMaterialPath;
                
                [arrLocalModels addObject:model];
                
                indexOfItem ++;
            }
        }
        
        [self.effectsDataSource setObject:arrLocalModels
                                   forKey:@(STEffectsTypeStickerMy)];
        
        self.arrCurrentModels = arrLocalModels;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.effectsList reloadData];
        });
    }
    
    [self fetchMaterialsAndReloadDataWithGroupID:@"ff81fc70f6c111e899f602f2be7c2171"
                                            type:STEffectsTypeStickerNew];
    [self fetchMaterialsAndReloadDataWithGroupID:@"3cd2dae0f6c211e8877702f2beb67403"
                                            type:STEffectsTypeSticker2D];
    [self fetchMaterialsAndReloadDataWithGroupID:@"46028a20f6c211e888ea020d88863a42"
                                            type:STEffectsTypeStickerAvatar];
    [self fetchMaterialsAndReloadDataWithGroupID:@"4e869010f6c211e888ea020d88863a42"
                                            type:STEffectsTypeSticker3D];
    [self fetchMaterialsAndReloadDataWithGroupID:@"5aea6840f6c211e899f602f2be7c2171"
                                            type:STEffectsTypeStickerGesture];
    [self fetchMaterialsAndReloadDataWithGroupID:@"65365cf0f6c211e8877702f2beb67403"
                                            type:STEffectsTypeStickerSegment];
    [self fetchMaterialsAndReloadDataWithGroupID:@"6d036ef0f6c211e899f602f2be7c2171"
                                            type:STEffectsTypeStickerFaceDeformation];
    [self fetchMaterialsAndReloadDataWithGroupID:@"73bffb50f6c211e899f602f2be7c2171"
                                            type:STEffectsTypeStickerFaceChange];
    [self fetchMaterialsAndReloadDataWithGroupID:@"7c6089f0f6c211e8877702f2beb67403"
                                            type:STEffectsTypeStickerParticle];
}

- (void)fetchMaterialsAndReloadDataWithGroupID:(NSString *)strGroupID
                                          type:(STEffectsType)iType
{
    __weak typeof(self) weakSelf = self;
    
    [[SenseArMaterialService sharedInstance]
     fetchMaterialsWithUserID:@"testUserID"
     GroupID:strGroupID
     onSuccess:^(NSArray<SenseArMaterial *> *arrMaterials) {
         
         NSMutableArray *arrModels = [NSMutableArray array];
         
         for (int i = 0; i < arrMaterials.count; i ++) {
             
             SenseArMaterial *material = [arrMaterials objectAtIndex:i];
             
             EffectsCollectionViewCellModel *model = [[EffectsCollectionViewCellModel alloc] init];
             
             model.material = material;
             model.indexOfItem = i;
             model.state = [[SenseArMaterialService sharedInstance] isMaterialDownloaded:material] ? Downloaded : NotDownloaded;
             model.iEffetsType = iType;
             
             if (material.strMaterialPath) {
                 
                 model.strMaterialPath = material.strMaterialPath;
             }
             
             [arrModels addObject:model];
         }
         
         [weakSelf.effectsDataSource setObject:arrModels forKey:@(iType)];
         
         if (iType == weakSelf.curEffectStickerType) {
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [weakSelf.effectsList reloadData];
             });
         }
         
         for (EffectsCollectionViewCellModel *model in arrModels) {
             
             dispatch_async(weakSelf.thumbDownlaodQueue, ^{
                 
                 [weakSelf cacheThumbnailOfModel:model];
             });
         }
     } onFailure:^(int iErrorCode, NSString *strMessage)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil];
             
//             [alert setMessage:[NSString stringWithFormat:@"获取贴纸列表失败 , %@" , strMessage]];
             [alert setMessage:@"获取贴纸列表失败"];
             
             [alert show];
         });
     }];
}

- (void)cacheThumbnailOfModel:(EffectsCollectionViewCellModel *)model
{
    NSString *strFileID = model.material.strMaterialFileID;
    
    id cacheObj = [self.thumbnailCache objectForKey:strFileID];
    
    if (!cacheObj || ![cacheObj isKindOfClass:[UIImage class]]) {
        
        NSString *strThumbnailImagePath = [self.strThumbnailPath stringByAppendingPathComponent:strFileID];
        
        if (![self.fManager fileExistsAtPath:strThumbnailImagePath]) {
            
            [self.thumbnailCache setObject:strFileID forKey:strFileID];
            
            __weak typeof(self) weakSelf = self;
            
            [weakSelf.imageLoadQueue addOperationWithBlock:^{
                
                UIImage *imageDownloaded = nil;
                
                if ([model.material.strThumbnailURL isKindOfClass:[NSString class]]) {
                    
                    NSError *error = nil;
                    
                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:model.material.strThumbnailURL] options:NSDataReadingMappedIfSafe error:&error];
                    
                    imageDownloaded = [UIImage imageWithData:imageData];
                    
                    if (imageDownloaded) {
                        
                        if ([weakSelf.fManager createFileAtPath:strThumbnailImagePath contents:imageData attributes:nil]) {
                            
                            [weakSelf.thumbnailCache setObject:imageDownloaded forKey:strFileID];
                        }else{
                            
                            [weakSelf.thumbnailCache removeObjectForKey:strFileID];
                        }
                    }else{
                        
                        [weakSelf.thumbnailCache removeObjectForKey:strFileID];
                    }
                }else{
                    
                    [weakSelf.thumbnailCache removeObjectForKey:strFileID];
                }
                
                model.imageThumb = imageDownloaded;
                
                if (weakSelf.curEffectStickerType == model.iEffetsType) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [weakSelf.effectsList reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:model.indexOfItem inSection:0]]];
                    });
                }
            }];
        }else{
            
            UIImage *image = [UIImage imageWithContentsOfFile:strThumbnailImagePath];
            
            if (image) {
                
                [self.thumbnailCache setObject:image forKey:strFileID];
                
            }else{
                
                [self.fManager removeItemAtPath:strThumbnailImagePath error:nil];
            }
        }
    }
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
#if TEST_BODY_BEAUTY
        addSubModel(_hDetector, @"M_SenseME_Body_Contour_73_1.2.0");
#endif
    }
    
    //猫脸检测
    NSString *catFaceModel = [[NSBundle mainBundle] pathForResource:@"M_SenseME_CatFace_2.0.0" ofType:@"model"];
    
    TIMELOG(keyCat);
    
    iRet = st_mobile_tracker_animal_face_create(catFaceModel.UTF8String, ST_MOBILE_TRACKING_MULTI_THREAD, &_animalHandle);
    
    TIMEPRINT(keyCat, "cat handle create time:")
    
    if (iRet != ST_OK || !_animalHandle) {
        NSLog(@"st mobile tracker animal face create failed: %d", iRet);
    }
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
    
    //初始化贴纸模块句柄 , 默认开始时无贴纸 , 所以第一个路径参数传空
    TIMELOG(keySticker);
    
    iRet = st_mobile_sticker_create(&_hSticker);
    
    TIMEPRINT(keySticker, "sticker create time:");
    
    if (ST_OK != iRet || !_hSticker) {
        
        NSLog(@"st mobile sticker create failed: %d", iRet);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"贴纸SDK初始化失败 , SDK权限过期，或者与绑定包名不符" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        
        [alert show];
    } else {
        
        iRet = st_mobile_sticker_set_param_ptr(_hSticker, -1, ST_STICKER_PARAM_SOUND_LOAD_FUNC_PTR, load_sound);
        if (iRet != ST_OK) {
            NSLog(@"st mobile set load sound func failed: %d", iRet);
        }
        
        iRet = st_mobile_sticker_set_param_ptr(_hSticker, -1, ST_STICKER_PARAM_SOUND_PLAY_FUNC_PTR, play_sound);
        if (iRet != ST_OK) {
            NSLog(@"st mobile set play sound func failed: %d", iRet);
        }
        
        iRet = st_mobile_sticker_set_param_ptr(_hSticker, -1, ST_STICKER_PARAM_SOUND_PAUSE_FUNC_PTR, pause_sound);
        if (iRet != ST_OK) {
            NSLog(@"st mobile set pause sound func failed: %d", iRet);
        }
        
        iRet = st_mobile_sticker_set_param_ptr(_hSticker, -1, ST_STICKER_PARAM_SOUND_RESUME_FUNC_PTR, resume_sound);
        if (iRet != ST_OK) {
            NSLog(@"st mobile set resume sound func failed: %d", iRet);
        }
        
        iRet = st_mobile_sticker_set_param_ptr(_hSticker, -1, ST_STICKER_PARAM_SOUND_STOP_FUNC_PTR, stop_sound);
        if (iRet != ST_OK) {
            NSLog(@"st mobile set stop sound func failed: %d", iRet);
        }
        
        iRet = st_mobile_sticker_set_param_ptr(_hSticker, -1, ST_STICKER_PARAM_SOUND_UNLOAD_FUNC_PTR, unload_sound);
        if (iRet != ST_OK) {
            NSLog(@"st mobile set unload sound func failed: %d", iRet);
        }
        
        iRet = st_mobile_sticker_set_param_ptr(_hSticker, -1, ST_STICKER_PARAM_PACKAGE_STATE_FUNC_PTR, package_event);
        
        NSString *strAvatarModelPath = [[NSBundle mainBundle] pathForResource:@"M_SenseME_Avatar_Core_2.0.0" ofType:@"model"];
        iRet = st_mobile_sticker_load_avatar_model(_hSticker, strAvatarModelPath.UTF8String);
        if (iRet != ST_OK) {
            NSLog(@"load avatar model failed: %d", iRet);
        }
    }
    
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
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_SMOOTH_STRENGTH, self.fSmoothStrength);
        // 设置默认大眼参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, self.fEnlargeEyeStrength);
        // 设置默认瘦脸参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_SHRINK_FACE_RATIO, self.fShrinkFaceStrength);
        // 设置小脸参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_SHRINK_JAW_RATIO, self.fShrinkJawStrength);
        // 设置美白参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_WHITEN_STRENGTH, self.fWhitenStrength);
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
        
#if TEST_BODY_BEAUTY
        st_mobile_beautify_set_input_source(_hBeautify, ST_BEAUTIFY_PREVIEW);
        st_mobile_beautify_set_body_ref_type(_hBeautify, ST_BEAUTIFY_BODY_REF_HEAD);
        //设置瘦身参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_BODY_WHOLE_RATIO, 0.4);
        
        //设置瘦头参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_BODY_HEAD_RATIO, 0.4);
        
        //设置瘦肩参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_BODY_SHOULDER_RATIO, 0.4);
        
        //设置瘦腰参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_BODY_WAIST_RATIO, 0.4);
        
        //设置瘦臀参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_BODY_HIP_RATIO, 0.4);
        
        //设置瘦腿参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_BODY_LEG_RATIO, 0.4);
        
        //设置长腿参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_BODY_HEIGHT_RATIO, 0.4);
#endif
    }
    
    // 初始化滤镜句柄
    iRet = st_mobile_gl_filter_create(&_hFilter);
    
    if (ST_OK != iRet || !_hFilter) {
        
        NSLog(@"st mobile gl filter create failed: %d", iRet);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"滤镜SDK初始化失败，可能是SDK权限过期或与绑定包名不符" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        
        [alert show];
    }
    
    
    // 初始化通用物体追踪句柄
    iRet = st_mobile_object_tracker_create(&_hTracker);
    
    if (ST_OK != iRet || !_hTracker) {
        
        NSLog(@"st mobile object tracker create failed: %d", iRet);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"通用物体跟踪SDK初始化失败，可能是SDK权限过期或与绑定包名不符" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        
        [alert show];
    }
    
    //create beautyMakeUp handle
    iRet = st_mobile_makeup_create(&_hBmpHandle);
    
    if (ST_OK != iRet || !_hBmpHandle) {
        
        NSLog(@"st mobile object makeup create failed: %d", iRet);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"美妆SDK初始化失败，可能是SDK权限过期或与绑定包名不符" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        
        [alert show];
    }
}

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

#pragma mark - STAudioManagerDelegate

- (void)audioCaptureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    self.outputAudioFormatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    
    @synchronized (self) {
        
        if (self.recordStatus == STWriterRecordingStatusRecording) {
            [self.stRecoder appendAudioSampleBuffer:sampleBuffer];
        }
    }
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
    
    //get pts
    CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    double current = CFAbsoluteTimeGetCurrent();
    
    //    NSLog(@"st_effects_recored_time : %f", current);
    
    if (self.recording && (current - self.recordStartTime) > 10) {
        
        [self stopRecorder];
        [self.timer stop];
        [self.timer reset];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.recordImageView.hidden = YES;
            
            self.recordTimeLabel.hidden = YES;
            
            self.filterStrengthView.hidden = self.filterStrengthViewHiddenState;
            self.specialEffectsBtn.hidden = NO;
            self.beautyBtn.hidden = NO;
            self.btnAlbum.hidden = NO;
            self.btnSetting.hidden = NO;
            self.btnChangeCamera.hidden = NO;
            self.btnCompare.hidden = NO;
            self.beautyContainerView.hidden = NO;
            self.specialEffectsContainerView.hidden = NO;
            self.settingView.hidden = NO;
            
        });
    }
    
    TIMELOG(frameCostKey);
    
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
    
#if ENABLE_FACE_ATTRIBUTE_DETECT
    int iFaceCount = 0;
#endif
    
    _faceArray = [NSMutableArray array];
    
    // 如果需要做属性,每隔一秒做一次属性
    double dTimeNow = CFAbsoluteTimeGetCurrent();
    BOOL isAttributeTime = (dTimeNow - self.lastTimeAttrDetected) >= 1.0;
    
    if (isAttributeTime) {
        
        self.lastTimeAttrDetected = dTimeNow;
    }
    
    ///ST_MOBILE 以下为通用物体跟踪部分
    if (_bTracker && _hTracker) {
        
        if (self.isCommonObjectViewAdded) {
            
            if (!self.isCommonObjectViewSetted) {
                
                iRet = st_mobile_object_tracker_set_target(_hTracker, pBGRAImageIn, ST_PIX_FMT_BGRA8888, iWidth, iHeight, iBytesPerRow, &_rect);
                
                if (iRet != ST_OK) {
                    NSLog(@"st mobile object tracker set target failed: %d", iRet);
                    _rect.left = 0;
                    _rect.top = 0;
                    _rect.right = 0;
                    _rect.bottom = 0;
                } else {
                    self.commonObjectViewSetted = YES;
                }
            }
            
            if (self.isCommonObjectViewSetted) {
                
                TIMELOG(keyTracker);
                iRet = st_mobile_object_tracker_track(_hTracker, pBGRAImageIn, ST_PIX_FMT_BGRA8888, iWidth, iHeight, iBytesPerRow, &_rect, &_result_score);
                //                NSLog(@"tracking, result_score: %f,rect.left: %d, rect.top: %d, rect.right: %d, rect.bottom: %d", _result_score, _rect.left, _rect.top, _rect.right, _rect.bottom);
                TIMEPRINT(keyTracker, "st_mobile_object_tracker_track time:");
                
                if (iRet != ST_OK) {
                    
                    NSLog(@"st mobile object tracker track failed: %d", iRet);
                    _rect.left = 0;
                    _rect.top = 0;
                    _rect.right = 0;
                    _rect.bottom = 0;
                }
                
                CGRect rectDisplay = CGRectMake(_rect.left * _scale - _margin,
                                                _rect.top * _scale,
                                                _rect.right * _scale - _rect.left * _scale,
                                                _rect.bottom * _scale - _rect.top * _scale);
                CGPoint center = CGPointMake(rectDisplay.origin.x + rectDisplay.size.width / 2,
                                             rectDisplay.origin.y + rectDisplay.size.height / 2);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (self.commonObjectContainerView.currentCommonObjectView.isOnFirst) {
                        //用作同步,防止再次改变currentCommonObjectView的位置
                        
                    } else if (_rect.left == 0 && _rect.top == 0 && _rect.right == 0 && _rect.bottom == 0) {
                        
                        self.commonObjectContainerView.currentCommonObjectView.hidden = YES;
                        
                    } else {
                        self.commonObjectContainerView.currentCommonObjectView.hidden = NO;
                        self.commonObjectContainerView.currentCommonObjectView.center = center;
                    }
                });
            }
        }
    }
    
    
    int catFaceCount = -1;
    ///cat face
    if (_needDetectAnimal && _animalHandle) {
        
        st_result_t iRet = st_mobile_tracker_animal_face_track(_animalHandle, pBGRAImageIn, ST_PIX_FMT_BGRA8888, iWidth, iHeight, iBytesPerRow, stMobileRotate, &_detectResult1, &catFaceCount);
        
        if (iRet != ST_OK) {
            NSLog(@"st mobile animal face tracker failed: %d", iRet);
        } else {
//            NSLog(@"cat face count: %d", catFaceCount);
        }
        
    }
    
    ///ST_MOBILE 人脸信息检测部分
    if (_hDetector) {
        
        BOOL needFaceDetection = ((self.fEnlargeEyeStrength != 0 || self.fShrinkFaceStrength != 0 || self.fShrinkJawStrength != 0 || self.fThinFaceShapeStrength != 0 || self.fNarrowFaceStrength != 0 || self.fRoundEyeStrength != 0 || self.fChinStrength != 0 || self.fHairLineStrength != 0 || self.fNarrowNoseStrength != 0 || self.fLongNoseStrength != 0 || self.fMouthStrength != 0 || self.fPhiltrumStrength != 0 || self.fEyeDistanceStrength != 0 || self.fEyeAngleStrength != 0 || self.fOpenCanthusStrength != 0 || self.fProfileRhinoplastyStrength != 0 || self.fBrightEyeStrength != 0 || self.fRemoveDarkCirclesStrength != 0 || self.fRemoveNasolabialFoldsStrength != 0 || self.fWhiteTeethStrength != 0 || self.fAppleMusleStrength != 0) && _hBeautify) || (self.bAttribute && isAttributeTime && _hAttribute);
        
        if (needFaceDetection) {
#if TEST_AVATAR_EXPRESSION
            self.iCurrentAction |= ST_MOBILE_FACE_DETECT | self.avatarConfig;
#else
            self.iCurrentAction = ST_MOBILE_FACE_DETECT | self.makeUpConf | self.stickerConf;
#endif
        } else {
            
            self.iCurrentAction = self.makeUpConf | self.stickerConf;
        }
        
//        NSLog(@"current config: %llx", _iCurrentAction);
        
#if TEST_BODY_BEAUTY
        self.iCurrentAction |= ST_MOBILE_BODY_KEYPOINTS | ST_MOBILE_BODY_CONTOUR;
#endif
        
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
#if TEST_AVATAR_EXPRESSION
                //获取avatar表情参数，该接口只会处理一张人脸信息，结果信息会以数组形式返回，数组下标对应的表情在ST_AVATAR_EXPRESSION_INDEX枚举中
                if (detectResult.face_count > 0) {
                    float expression[ST_AVATAR_EXPRESSION_NUM] = {0.0};
                    iRet = st_mobile_avatar_get_expression(_avatarHandle, iWidth, iHeight, stMobileRotate, detectResult.p_faces, expression);
                    if (expression[0] == 1) {
                        NSLog(@"右眼闭");
                    }
                }
#endif
                
                
#if ENABLE_FACE_ATTRIBUTE_DETECT
                
                iFaceCount = detectResult.face_count;
                
                if (iFaceCount > 0) {
                    _pFacesDetection = (st_mobile_106_t *)malloc(sizeof(st_mobile_106_t) * iFaceCount);
                    memset(_pFacesDetection, 0, sizeof(st_mobile_106_t) * iFaceCount);
                }
                
                //构造人脸信息数组
                for (int i = 0; i < iFaceCount; i++) {
                    
                    _pFacesDetection[i] = detectResult.p_faces[i].face106;
                }
                
#endif
                
            }else{
                STLog(@"st_mobile_human_action_detect failed %d" , iRet);
            }
        }
    }
    
#if ENABLE_FACE_ATTRIBUTE_DETECT
    ///ST_MOBILE 以下为attribute部分 , 当人脸数大于零且人脸信息数组不为空时每秒做一次属性检测.
    if (self.bAttribute && _hAttribute) {
        
        if (iFaceCount > 0 && _pFacesDetection && isAttributeTime) {
            
            TIMELOG(attributeKey);
            
            st_mobile_attributes_t *pAttrArray;
            
            // attribute detect
            iRet = st_mobile_face_attribute_detect(_hAttribute,
                                                   pBGRAImageIn,
                                                   ST_PIX_FMT_BGRA8888,
                                                   iWidth,
                                                   iHeight,
                                                   iBytesPerRow,
                                                   _pFacesDetection,
                                                   1, // 这里仅取一张脸也就是第一张脸的属性作为演示
                                                   &pAttrArray);
            if (iRet != ST_OK) {
                
                pFacesFinal = NULL;
                
                STLog(@"st_mobile_face_attribute_detect failed. %d" , iRet);
                
                goto unlockBufferAndFlushCache;
            }
            
            TIMEPRINT(attributeKey, "st_mobile_face_attribute_detect time: ");
            
            // 取第一个人的属性集合作为示例
            st_mobile_attributes_t attributeDisplay = pAttrArray[0];
            
            //获取属性描述
            NSString *strAttrDescription = [self getDescriptionOfAttribute:attributeDisplay];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.lblAttribute setText:[@"第一张人脸: " stringByAppendingString:strAttrDescription]];
                [self.lblAttribute setHidden:NO];
            });
        }
    }else{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.lblAttribute setText:@""];
            [self.lblAttribute setHidden:YES];
        });
    }
    
#endif
    
    self.iBufferedCount ++;
    CFRetain(pixelBuffer);

    __block st_mobile_human_action_t newDetectResult;
    memset(&newDetectResult, 0, sizeof(st_mobile_human_action_t));
//    copyHumanAction(&detectResult, &newDetectResult);
    st_mobile_human_action_copy(&detectResult, &newDetectResult);
    
    int faceCount = catFaceCount;
    st_mobile_animal_face_t *newDetectResult1 = NULL;
    if (faceCount > 0) {
        newDetectResult1 = malloc(sizeof(st_mobile_animal_face_t) * faceCount);
        memset(newDetectResult1, 0, sizeof(st_mobile_animal_face_t) * faceCount);
        copyCatFace(_detectResult1, faceCount, newDetectResult1);
    }
    
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
            if (_bBeauty && _hBeautify) {

                setBeautifyParam(_hBeautify, ST_BEAUTIFY_SHRINK_FACE_RATIO, self.fShrinkFaceStrength);
                setBeautifyParam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, self.fEnlargeEyeStrength);
                setBeautifyParam(_hBeautify, ST_BEAUTIFY_SHRINK_JAW_RATIO, self.fShrinkJawStrength);
                setBeautifyParam(_hBeautify, ST_BEAUTIFY_SMOOTH_STRENGTH, self.fSmoothStrength);
                setBeautifyParam(_hBeautify, ST_BEAUTIFY_REDDEN_STRENGTH, self.fReddenStrength);
                setBeautifyParam(_hBeautify, ST_BEAUTIFY_WHITEN_STRENGTH, self.fWhitenStrength);
                setBeautifyParam(_hBeautify, ST_BEAUTIFY_CONTRAST_STRENGTH, self.fContrastStrength);
                setBeautifyParam(_hBeautify, ST_BEAUTIFY_SATURATION_STRENGTH, self.fSaturationStrength);
                setBeautifyParam(_hBeautify, ST_BEAUTIFY_NARROW_FACE_STRENGTH, self.fNarrowFaceStrength);
                setBeautifyParam(_hBeautify, ST_BEAUTIFY_ROUND_EYE_RATIO, self.fRoundEyeStrength);

                setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_THIN_FACE_SHAPE_RATIO, self.fThinFaceShapeStrength);
                setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_CHIN_LENGTH_RATIO, self.fChinStrength);
                setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_HAIRLINE_HEIGHT_RATIO, self.fHairLineStrength);
                setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_NARROW_NOSE_RATIO, self.fNarrowNoseStrength);
                setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_NOSE_LENGTH_RATIO, self.fLongNoseStrength);
                setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_MOUTH_SIZE_RATIO, self.fMouthStrength);
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
                
                TIMELOG(keyBeautify);
                
#if TEST_OUTPUT_BUFFER_INTERFACE
                
                unsigned char * beautify_buffer_output = malloc(iWidth * iHeight * 4);
                
                iRet = st_mobile_beautify_process_and_output_texture(_hBeautify, _textureOriginInput, iWidth, iHeight, &newDetectResult, _textureBeautifyOutput, beautify_buffer_output, ST_PIX_FMT_RGBA8888, &newDetectResult);
                
                UIImage *beatifyImage = [self rgbaBufferConvertToImage:beautify_buffer_output width:iWidth height:iHeight];
                
                if (beautify_buffer_output) {
                    free(beautify_buffer_output);
                    beautify_buffer_output = NULL;
                }
                
#else
                iRet = st_mobile_beautify_process_texture(_hBeautify, _textureOriginInput, iWidth, iHeight, stMobileRotate, &newDetectResult, _textureBeautifyOutput, &newDetectResult);
                
#endif
                TIMEPRINT(keyBeautify, "st_mobile_beautify_process_texture time:");
                
                if (ST_OK != iRet) {
                    
                    STLog(@"st_mobile_beautify_process_texture failed %d" , iRet);
                    
                } else {
                    textureResult = _textureBeautifyOutput;
                    resultPixelBufffer = _cvBeautifyBuffer;
                }
            }
            
        }
    
    
        
#if DRAW_FACE_KEY_POINTS
        
        [self drawKeyPoints:newDetectResult];
#endif
        
        //makeup
        if (_hBmpHandle) {
            
            TIMELOG(bmpProcessKey);
            
            iRet = st_mobile_makeup_process_texture(_hBmpHandle, textureResult, iWidth, iHeight, stMobileRotate, &newDetectResult, _textureMakeUpOutput);
            if (iRet != ST_OK) {
                NSLog(@"st_mobile_makeup_process_texture failed: %d", iRet);
            } else {
                textureResult = _textureMakeUpOutput;
                resultPixelBufffer = _cvMakeUpBuffer;
            }

             TIMEPRINT(bmpProcessKey, "st_mobile_makeup_process_texture time:");
        }
        
        
        ///ST_MOBILE 以下为贴纸部分
        if (_bSticker && _hSticker) {
            
            TIMELOG(stickerProcessKey);
            
#if TEST_OUTPUT_BUFFER_INTERFACE
            
            unsigned char * sticker_buffer_output = malloc(iWidth * iHeight * 4);
            
            iRet = st_mobile_sticker_process_and_output_texture(_hSticker, textureResult, iWidth, iHeight, stMobileRotate, ST_CLOCKWISE_ROTATE_0, false, &newDetectResult, item_callback, _textureStickerOutput, sticker_buffer_output, ST_PIX_FMT_RGBA8888);
            
            UIImage *stickerImage = [self rgbaBufferConvertToImage:sticker_buffer_output width:iWidth height:iHeight];
            
            if (sticker_buffer_output) {
                free(sticker_buffer_output);
                sticker_buffer_output = NULL;
            }
            
#else
            st_mobile_input_params_t inputEvent;
            memset(&inputEvent, 0, sizeof(st_mobile_input_params_t));
            
            int type = ST_INPUT_PARAM_NONE;
            iRet = st_mobile_sticker_get_needed_input_params(_hSticker, &type);
            
            if (CHECK_FLAG(type, ST_INPUT_PARAM_CAMERA_QUATERNION)) {
                
                CMDeviceMotion *motion = self.motionManager.deviceMotion;
                inputEvent.camera_quaternion[0] = motion.attitude.quaternion.x;
                inputEvent.camera_quaternion[1] = motion.attitude.quaternion.y;
                inputEvent.camera_quaternion[2] = motion.attitude.quaternion.z;
                inputEvent.camera_quaternion[3] = motion.attitude.quaternion.w;
                
                if (self.stCamera.devicePosition == AVCaptureDevicePositionBack) {
                    inputEvent.is_front_camera = false;
                } else {
                    inputEvent.is_front_camera = true;
                }
            } else {
                
                inputEvent.camera_quaternion[0] = 0;
                inputEvent.camera_quaternion[1] = 0;
                inputEvent.camera_quaternion[2] = 0;
                inputEvent.camera_quaternion[3] = 1;
            }
            
//            iRet = st_mobile_sticker_process_texture(_hSticker, textureResult, iWidth, iHeight, stMobileRotate, ST_CLOCKWISE_ROTATE_0, false, &detectResult1, &inputEvent, _textureStickerOutput);
            iRet = st_mobile_sticker_process_texture_both(_hSticker, textureResult, iWidth, iHeight, stMobileRotate, ST_CLOCKWISE_ROTATE_0, false, &newDetectResult, &inputEvent, newDetectResult1, catFaceCount, _textureStickerOutput);
            
#endif
            
            TIMEPRINT(stickerProcessKey, "st_mobile_sticker_process_texture time:");
            
            if (ST_OK != iRet) {
                
                STLog(@"st_mobile_sticker_process_texture %d" , iRet);
                
            }
            
            textureResult = _textureStickerOutput;
            resultPixelBufffer = _cvStickerBuffer;
        }
        
        if (self.isNullSticker && _hSticker) {
            iRet = st_mobile_sticker_change_package(_hSticker, NULL, NULL);
            
            if (ST_OK != iRet) {
                NSLog(@"st_mobile_sticker_change_package error %d", iRet);
            }
        }
        
        ///ST_MOBILE 以下为滤镜部分
        if (_bFilter && _hFilter) {
            
            if (self.curFilterModelPath != self.preFilterModelPath) {
                iRet = st_mobile_gl_filter_set_style(_hFilter, self.curFilterModelPath.UTF8String);
                if (iRet != ST_OK) {
                    NSLog(@"st mobile filter set style failed: %d", iRet);
                }
                self.preFilterModelPath = self.curFilterModelPath;
            }
            
            TIMELOG(keyFilter);
            
#if TEST_OUTPUT_BUFFER_INTERFACE
            
            unsigned char * filter_buffer_output = malloc(iWidth * iHeight * 4);
            
            iRet = st_mobile_gl_filter_process_texture_and_output_buffer(_hFilter, textureResult, iWidth, iHeight, _textureFilterOutput, filter_buffer_output, ST_PIX_FMT_RGBA8888);
            
            UIImage *filterImage = [self rgbaBufferConvertToImage:filter_buffer_output width:iWidth height:iHeight];
            
            if (filter_buffer_output) {
                free(filter_buffer_output);
                filter_buffer_output = NULL;
            }
            
#else
            iRet = st_mobile_gl_filter_process_texture(_hFilter, textureResult, iWidth, iHeight, _textureFilterOutput);
            
#endif
            
            
            
            TIMEPRINT(keyFilter, "st_mobile_gl_filter_process_texture time:");
            
            if (ST_OK != iRet) {
                
                STLog(@"st_mobile_gl_filter_process_texture %d" , iRet);
                
            }
            
            textureResult = _textureFilterOutput;
            resultPixelBufffer = _cvFilterBuffer;
        }
        
        
        if (self.needSnap) {
            
            self.needSnap = NO;
            
            [self snapWithTexture:textureResult width:iWidth height:iHeight];
        }
        
        //对比
        if (self.isComparing) {
            
            textureResult = _textureOriginInput;
        }
        
        if (!self.outputVideoFormatDescription) {
            CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, &(_outputVideoFormatDescription));
        }
        
        //        @synchronized (self) {
        
        if (self.recordStatus == STWriterRecordingStatusRecording) {
            
            [self.stRecoder  appendVideoPixelBuffer:resultPixelBufffer withPresentationTime:timestamp];
            
        }
        
        //        }
        
//        freeHumanAction(&newDetectResult);
        st_mobile_human_action_delete(&newDetectResult);
        if (faceCount > 0) {
            freeCatFace(newDetectResult1, faceCount);
        }
    
        [self.glPreview renderTexture:textureResult];
        
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
    
    dCost = CFAbsoluteTimeGetCurrent() - dStart;
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (![self.strBodyAction isEqualToString:self.lblBodyAction.text]) {
            self.lblBodyAction.text = self.strBodyAction;
        }
        
        if (self.bAttribute) {
            
            [self.lblSpeed setText:[NSString stringWithFormat:@"单帧耗时: %.0fms" ,dCost * 1000.0]];
            [self.lblCPU setText:[NSString stringWithFormat:@"CPU占用率: %.1f%%" , [STParamUtil getCpuUsage]]];
        } else {
            
            self.lblSpeed.text = @"";
            self.lblCPU.text = @"";
        }
    });
    
    TIMEPRINT(frameCostKey, "every frame cost time");
    
    
    if (self.isFirstLaunch
        &&
        [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusAuthorized) {
        
        self.isFirstLaunch = NO;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"点击屏幕底部圆形按钮可拍照，长按可录制视频" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
            [alert show];
        });
    }
}

#pragma mark - private methods

- (void)snapWithTexture:(GLuint)iTexture width:(int)iWidth height:(int)iHeight
{
    self.pauseOutput = YES;
    
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(iWidth, iHeight), NO, 0.0);
        [self.glPreview drawViewHierarchyInRect:CGRectMake(0, 0, iWidth, iHeight) afterScreenUpdates:YES];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [assetLibrary writeImageToSavedPhotosAlbum:image.CGImage
                                       orientation:ALAssetOrientationUp
                                   completionBlock:^(NSURL *assetURL, NSError *error) {
                                       
                                       self.lblSaveStatus.text = @"图片已保存到相册";
                                       [self showAnimationIfSaved:error == nil];
                                   }];
        
    });
    
    
    
    /*
     CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
     
     CIImage *ciImage = [CIImage imageWithTexture:iTexture size:CGSizeMake(iWidth, iHeight) flipped:YES colorSpace:colorSpace];
     
     CGImageRef cgImage = [self.ciContext createCGImage:ciImage fromRect:CGRectMake(0, 0, iWidth, iHeight)];
     
     CGColorSpaceRelease(colorSpace);
     
     //保存图片
     ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
     
     dispatch_async(dispatch_get_main_queue(), ^{
     
     [assetLibrary writeImageToSavedPhotosAlbum:cgImage
     orientation:ALAssetOrientationUp
     completionBlock:^(NSURL *assetURL, NSError *error) {
     
     CGImageRelease(cgImage);
     
     [self showAnimationIfSaved:error == nil];
     }];
     });
     */
    self.pauseOutput = NO;
}

- (void)showAnimationIfSaved:(BOOL)bSaved {
    
    self.snapBtn.userInteractionEnabled = NO;
    
    self.lblSaveStatus.hidden = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        
        self.lblSaveStatus.center = CGPointMake(SCREEN_WIDTH / 2.0 , 102);
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.05 delay:2
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             
                             self.lblSaveStatus.center = CGPointMake(SCREEN_WIDTH / 2.0 , -44);
                             
                         } completion:^(BOOL finished) {
                             
                             self.lblSaveStatus.hidden = YES;
                             
                             self.snapBtn.userInteractionEnabled = YES;
                             
                         }];
    }];
}

- (NSString *)getDescriptionOfAttribute:(st_mobile_attributes_t)attribute {
    NSString *strAge , *strGender , *strAttricative = nil;
    
    for (int i = 0; i < attribute.attribute_count; i ++) {
        
        // 读取一条属性
        st_mobile_attribute_t attributeOne = attribute.p_attributes[i];
        
        // 获取属性类别
        const char *attr_category = attributeOne.category;
        const char *attr_label = attributeOne.label;
        
        // 年龄
        if (0 == strcmp(attr_category, "age")) {
            
            strAge = [NSString stringWithUTF8String:attr_label];
        }
        
        // 颜值
        if (0 == strcmp(attr_category, "attractive")) {
            
            strAttricative = [NSString stringWithUTF8String:attr_label];
        }
        
        // 性别
        if (0 == strcmp(attr_category, "gender")) {
            
            if (0 == strcmp(attr_label, "male") ) {
                
                strGender = @"男";
            }
            
            if (0 == strcmp(attr_label, "female") ) {
                
                strGender = @"女";
            }
        }
    }
    
    NSString *strAttrDescription = [NSString stringWithFormat:@"颜值:%@ 性别:%@ 年龄:%@" , strAttricative , strGender , strAge];
    
    return strAttrDescription;
}

#pragma mark -

- (void)filterSliderValueChanged:(UISlider *)sender {
    
    _fFilterStrength = sender.value;
    _lblFilterStrength.text = [NSString stringWithFormat:@"%d", (int)(sender.value * 100)];
    
    if (_hFilter) {
        
        st_result_t iRet = ST_OK;
        iRet = st_mobile_gl_filter_set_param(_hFilter, ST_GL_FILTER_STRENGTH, sender.value);
        
        if (ST_OK != iRet) {
            
            STLog(@"st_mobile_gl_filter_set_param %d" , iRet);
        }
    }
}

- (void)changePreviewSize {
    CGRect rect = [self.stCamera getZoomedRectWithRect:CGRectMake(0,
                                                                  0,
                                                                  SCREEN_WIDTH,
                                                                  SCREEN_HEIGHT)
                                            scaleToFit:NO];
    
    [self.glPreview setFrame:rect];
    self.previewFrame = rect;
    self.previewCenter = self.glPreview.center;
}

#pragma mark - draw points

- (void)drawKeyPoints:(st_mobile_human_action_t)detectResult {
    
    for (int i = 0; i < detectResult.face_count; ++i) {
        
        for (int j = 0; j < 106; ++j) {
            [_faceArray addObject:@{
                                    POINT_KEY: [NSValue valueWithCGPoint:[self coordinateTransformation:detectResult.p_faces[i].face106.points_array[j]]]
                                    }];
        }
        
        if (detectResult.p_faces[i].p_extra_face_points && detectResult.p_faces[i].extra_face_points_count > 0) {
            
            for (int j = 0; j < detectResult.p_faces[i].extra_face_points_count; ++j) {
                [_faceArray addObject:@{
                                        POINT_KEY: [NSValue valueWithCGPoint:[self coordinateTransformation:detectResult.p_faces[i].p_extra_face_points[j]]]
                                        }];
            }
        }
        
        if (detectResult.p_faces[i].p_eyeball_contour && detectResult.p_faces[i].eyeball_contour_points_count > 0) {
            
            for (int j = 0; j < detectResult.p_faces[i].eyeball_contour_points_count; ++j) {
                [_faceArray addObject:@{
                                        POINT_KEY: [NSValue valueWithCGPoint:[self coordinateTransformation:detectResult.p_faces[i].p_eyeball_contour[j]]]
                                        }];
            }
        }
        
    }
    
    if (detectResult.p_bodys && detectResult.body_count > 0) {
        
        for (int j = 0; j < detectResult.p_bodys[0].key_points_count; ++j) {
            
            if (detectResult.p_bodys[0].p_key_points_score[j] > 0.15) {
                [_faceArray addObject:@{
                                        POINT_KEY: [NSValue valueWithCGPoint:[self coordinateTransformation:detectResult.p_bodys[0].p_key_points[j]]]
                                        }];
            }
        }
    }
    
    self.commonObjectContainerView.faceArray = [_faceArray copy];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.commonObjectContainerView setNeedsDisplay];
    });
}

- (CGPoint)coordinateTransformation:(st_pointf_t)point {
    
    return CGPointMake(_scale * point.x - _margin, _scale * point.y);
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

#pragma mark - handle system notifications

- (void)appWillResignActive {
    
    self.isAppActive = NO;
    
    if (self.isComparing) {
        self.isComparing = NO;
    }
    
    if (self.recording) {
        
        [self stopRecorder];
        
        [self.timer stop];
        [self.timer reset];
        
        self.recording = NO;
        self.recordImageView.hidden = YES;
        
        self.recordTimeLabel.hidden = YES;
        
        self.filterStrengthView.hidden = self.filterStrengthViewHiddenState;
        self.specialEffectsBtn.hidden = NO;
        self.beautyBtn.hidden = NO;
        self.btnAlbum.hidden = NO;
        self.btnSetting.hidden = NO;
        self.btnChangeCamera.hidden = NO;
        self.btnCompare.hidden = NO;
        self.beautyContainerView.hidden = NO;
        self.specialEffectsContainerView.hidden = NO;
        self.settingView.hidden = NO;
    }
    self.pauseOutput = YES;
    
    //    if (self.audioPlayer.strCurrentAudioName) {
    //
    //        [self stopSound:self.audioPlayer.strCurrentAudioName];
    //        st_mobile_sticker_set_sound_completed(_hSticker, [self.audioPlayer.strCurrentAudioName UTF8String]);
    //
    //    }
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

#pragma mark - lazy load views

- (STViewButton *)specialEffectsBtn {
    if (!_specialEffectsBtn) {
        
        _specialEffectsBtn = [[[NSBundle mainBundle] loadNibNamed:@"STViewButton" owner:nil options:nil] firstObject];
        [_specialEffectsBtn setExclusiveTouch:YES];
        
        UIImage *image = [UIImage imageNamed:@"btn_special_effects.png"];
        
        _specialEffectsBtn.frame = CGRectMake([self layoutWidthWithValue:143], SCREEN_HEIGHT - 50, image.size.width, 50);
        _specialEffectsBtn.center = CGPointMake(_specialEffectsBtn.center.x, self.snapBtn.center.y);
        _specialEffectsBtn.backgroundColor = [UIColor clearColor];
        _specialEffectsBtn.imageView.image = [UIImage imageNamed:@"btn_special_effects.png"];
        _specialEffectsBtn.imageView.highlightedImage = [UIImage imageNamed:@"btn_special_effects_selected.png"];
        _specialEffectsBtn.titleLabel.textColor = [UIColor whiteColor];
        _specialEffectsBtn.titleLabel.highlightedTextColor = UIColorFromRGB(0xc086e5);
        _specialEffectsBtn.titleLabel.text = @"特效";
        _specialEffectsBtn.tag = STViewTagSpecialEffectsBtn;
        
        STWeakSelf;
        
        _specialEffectsBtn.tapBlock = ^{
            [weakSelf clickBottomViewButton:weakSelf.specialEffectsBtn];
        };
    }
    return _specialEffectsBtn;
}

- (STViewButton *)beautyBtn {
    if (!_beautyBtn) {
        _beautyBtn = [[[NSBundle mainBundle] loadNibNamed:@"STViewButton" owner:nil options:nil] firstObject];
        [_beautyBtn setExclusiveTouch:YES];
        
        UIImage *image = [UIImage imageNamed:@"btn_beauty.png"];
        
        _beautyBtn.frame = CGRectMake(SCREEN_WIDTH - [self layoutWidthWithValue:143] - image.size.width, SCREEN_HEIGHT - 50, image.size.width, 50);
        _beautyBtn.center = CGPointMake(_beautyBtn.center.x, self.snapBtn.center.y);
        _beautyBtn.backgroundColor = [UIColor clearColor];
        _beautyBtn.imageView.image = [UIImage imageNamed:@"btn_beauty.png"];
        _beautyBtn.imageView.highlightedImage = [UIImage imageNamed:@"btn_beauty_selected.png"];
        _beautyBtn.titleLabel.textColor = [UIColor whiteColor];
        _beautyBtn.titleLabel.highlightedTextColor = UIColorFromRGB(0xc086e5);
        _beautyBtn.titleLabel.text = @"美颜";
        _beautyBtn.tag = STViewTagBeautyBtn;
        
        STWeakSelf;
        
        _beautyBtn.tapBlock = ^{
            [weakSelf clickBottomViewButton:weakSelf.beautyBtn];
        };
    }
    return _beautyBtn;
}

- (UIView *)gradientView {
    
    if (!_gradientView) {
        _gradientView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 35, SCREEN_HEIGHT - 80, 70, 70)];
        _gradientView.alpha = 0.6;
        _gradientView.layer.cornerRadius = 35;
        _gradientView.layer.shadowColor = UIColorFromRGB(0x222256).CGColor;
        _gradientView.layer.shadowOpacity = 0.15;
        _gradientView.layer.shadowOffset = CGSizeZero;
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = _gradientView.bounds;
        gradientLayer.cornerRadius = 35;
        gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0xc460e1).CGColor, (__bridge id)UIColorFromRGB(0x7fd8ee).CGColor];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1, 1);
        gradientLayer.shadowColor = UIColorFromRGB(0x472b68).CGColor;
        gradientLayer.shadowOpacity = 0.1;
        gradientLayer.shadowOffset = CGSizeZero;
        [_gradientView.layer addSublayer:gradientLayer];
        
    }
    return _gradientView;
}

- (STViewButton *)snapBtn {
    if (!_snapBtn) {
        _snapBtn = [[STViewButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 28.5, SCREEN_HEIGHT - 73.5, 57, 57)];
        _snapBtn.layer.cornerRadius = 28.5;
        _snapBtn.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.6];
        
        
        STWeakSelf;
        _snapBtn.tapBlock = ^{
            //            NSLog(@"stviewbtn tap tap tap");
            weakSelf.needSnap = YES;
        };
        _snapBtn.delegate = self;
    }
    return _snapBtn;
}

- (UIView *)specialEffectsContainerView {
    if (!_specialEffectsContainerView) {
        _specialEffectsContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 230)];
        _specialEffectsContainerView.backgroundColor = [UIColor clearColor];
        
        UIView *noneStickerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 57, 40)];
        noneStickerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        noneStickerView.layer.shadowColor = UIColorFromRGB(0x141618).CGColor;
        noneStickerView.layer.shadowOpacity = 0.5;
        noneStickerView.layer.shadowOffset = CGSizeMake(3, 3);
        
        UIImage *image = [UIImage imageNamed:@"none_sticker.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((57 - image.size.width) / 2, (40 - image.size.height) / 2, image.size.width, image.size.height)];
        imageView.contentMode = UIViewContentModeCenter;
        imageView.image = image;
        imageView.highlightedImage = [UIImage imageNamed:@"none_sticker_selected.png"];
        _noneStickerImageView = imageView;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapNoneSticker:)];
        [noneStickerView addGestureRecognizer:tapGesture];
        
        [noneStickerView addSubview:imageView];
        
        UIView *whiteLineView = [[UIView alloc] initWithFrame:CGRectMake(56, 3, 1, 34)];
        whiteLineView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
        [noneStickerView addSubview:whiteLineView];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, 1)];
        lineView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
        [_specialEffectsContainerView addSubview:lineView];
        
        [_specialEffectsContainerView addSubview:noneStickerView];
        [_specialEffectsContainerView addSubview:self.scrollTitleView];
        [_specialEffectsContainerView addSubview:self.effectsList];
        [_specialEffectsContainerView addSubview:self.objectTrackCollectionView];
        
        UIView *blankView = [[UIView alloc] initWithFrame:CGRectMake(0, 181, SCREEN_WIDTH, 50)];
        blankView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [_specialEffectsContainerView addSubview:blankView];
    }
    return _specialEffectsContainerView;
}

- (UIView *)beautyContainerView {
    
    if (!_beautyContainerView) {
        _beautyContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 260)];
        _beautyContainerView.backgroundColor = [UIColor clearColor];
        [_beautyContainerView addSubview:self.beautyScrollTitleViewNew];
        
        UIView *whiteLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, 1)];
        whiteLineView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.3];
        [_beautyContainerView addSubview:whiteLineView];
        
        [_beautyContainerView addSubview:self.filterCategoryView];
        [_beautyContainerView addSubview:self.filterView];
        [_beautyContainerView addSubview:self.bmpColView];
        [_beautyContainerView addSubview:self.beautyCollectionView];
        
        [self.arrBeautyViews addObject:self.filterCategoryView];
        [self.arrBeautyViews addObject:self.filterView];
        [self.arrBeautyViews addObject:self.beautyCollectionView];
    }
    return _beautyContainerView;
}

- (STFilterView *)filterView {
    
    if (!_filterView) {
        _filterView = [[STFilterView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 41, SCREEN_WIDTH, 300)];
        _filterView.leftView.imageView.image = [UIImage imageNamed:@"still_life_highlighted"];
        _filterView.leftView.titleLabel.text = @"静物";
        _filterView.leftView.titleLabel.textColor = [UIColor whiteColor];
        
        _filterView.filterCollectionView.arrSceneryFilterModels = [self getFilterModelsByType:STEffectsTypeFilterScenery];
        _filterView.filterCollectionView.arrPortraitFilterModels = [self getFilterModelsByType:STEffectsTypeFilterPortrait];
        _filterView.filterCollectionView.arrStillLifeFilterModels = [self getFilterModelsByType:STEffectsTypeFilterStillLife];
        _filterView.filterCollectionView.arrDeliciousFoodFilterModels = [self getFilterModelsByType:STEffectsTypeFilterDeliciousFood];
        
        STWeakSelf;
        _filterView.filterCollectionView.delegateBlock = ^(STCollectionViewDisplayModel *model) {
            [weakSelf handleFilterChanged:model];
        };
        _filterView.block = ^{
            [UIView animateWithDuration:0.5 animations:^{
                weakSelf.filterCategoryView.frame = CGRectMake(0, weakSelf.filterCategoryView.frame.origin.y, SCREEN_WIDTH, 300);
                weakSelf.filterView.frame = CGRectMake(SCREEN_WIDTH, weakSelf.filterView.frame.origin.y, SCREEN_WIDTH, 300);
            }];
            weakSelf.filterStrengthView.hidden = YES;
        };
    }
    return _filterView;
}

- (UIView *)filterCategoryView {
    
    if (!_filterCategoryView) {
        
        _filterCategoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 41, SCREEN_WIDTH, 300)];
        _filterCategoryView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        
        
        STViewButton *portraitViewBtn = [[[NSBundle mainBundle] loadNibNamed:@"STViewButton" owner:nil options:nil] firstObject];
        portraitViewBtn.tag = STEffectsTypeFilterPortrait;
        portraitViewBtn.backgroundColor = [UIColor clearColor];
        portraitViewBtn.frame =  CGRectMake(SCREEN_WIDTH / 2 - 143, 58, 33, 60);
        portraitViewBtn.imageView.image = [UIImage imageNamed:@"portrait"];
        portraitViewBtn.imageView.highlightedImage = [UIImage imageNamed:@"portrait_highlighted"];
        portraitViewBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        portraitViewBtn.titleLabel.textColor = [UIColor whiteColor];
        portraitViewBtn.titleLabel.highlightedTextColor = [UIColor whiteColor];
        portraitViewBtn.titleLabel.text = @"人物";
        
        for (UIGestureRecognizer *recognizer in portraitViewBtn.gestureRecognizers) {
            [portraitViewBtn removeGestureRecognizer:recognizer];
        }
        UITapGestureRecognizer *portraitRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchFilterType:)];
        [portraitViewBtn addGestureRecognizer:portraitRecognizer];
        [self.arrFilterCategoryViews addObject:portraitViewBtn];
        [_filterCategoryView addSubview:portraitViewBtn];
        
        
        
        STViewButton *sceneryViewBtn = [[[NSBundle mainBundle] loadNibNamed:@"STViewButton" owner:nil options:nil] firstObject];
        sceneryViewBtn.tag = STEffectsTypeFilterScenery;
        sceneryViewBtn.backgroundColor = [UIColor clearColor];
        sceneryViewBtn.frame =  CGRectMake(SCREEN_WIDTH / 2 - 60, 58, 33, 60);
        sceneryViewBtn.imageView.image = [UIImage imageNamed:@"scenery"];
        sceneryViewBtn.imageView.highlightedImage = [UIImage imageNamed:@"scenery_highlighted"];
        sceneryViewBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        sceneryViewBtn.titleLabel.textColor = [UIColor whiteColor];
        sceneryViewBtn.titleLabel.highlightedTextColor = [UIColor whiteColor];
        sceneryViewBtn.titleLabel.text = @"风景";
        
        for (UIGestureRecognizer *recognizer in sceneryViewBtn.gestureRecognizers) {
            [sceneryViewBtn removeGestureRecognizer:recognizer];
        }
        UITapGestureRecognizer *sceneryRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchFilterType:)];
        [sceneryViewBtn addGestureRecognizer:sceneryRecognizer];
        [self.arrFilterCategoryViews addObject:sceneryViewBtn];
        [_filterCategoryView addSubview:sceneryViewBtn];
        
        
        
        STViewButton *stillLifeViewBtn = [[[NSBundle mainBundle] loadNibNamed:@"STViewButton" owner:nil options:nil] firstObject];
        stillLifeViewBtn.tag = STEffectsTypeFilterStillLife;
        stillLifeViewBtn.backgroundColor = [UIColor clearColor];
        stillLifeViewBtn.frame =  CGRectMake(SCREEN_WIDTH / 2 + 27, 58, 33, 60);
        stillLifeViewBtn.imageView.image = [UIImage imageNamed:@"still_life"];
        stillLifeViewBtn.imageView.highlightedImage = [UIImage imageNamed:@"still_life_highlighted"];
        stillLifeViewBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        stillLifeViewBtn.titleLabel.textColor = [UIColor whiteColor];
        stillLifeViewBtn.titleLabel.highlightedTextColor = [UIColor whiteColor];
        stillLifeViewBtn.titleLabel.text = @"静物";
        
        for (UIGestureRecognizer *recognizer in stillLifeViewBtn.gestureRecognizers) {
            [stillLifeViewBtn removeGestureRecognizer:recognizer];
        }
        UITapGestureRecognizer *stillLifeRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchFilterType:)];
        [stillLifeViewBtn addGestureRecognizer:stillLifeRecognizer];
        [self.arrFilterCategoryViews addObject:stillLifeViewBtn];
        [_filterCategoryView addSubview:stillLifeViewBtn];
        
        
        
        STViewButton *deliciousFoodViewBtn = [[[NSBundle mainBundle] loadNibNamed:@"STViewButton" owner:nil options:nil] firstObject];
        deliciousFoodViewBtn.tag = STEffectsTypeFilterDeliciousFood;
        deliciousFoodViewBtn.backgroundColor = [UIColor clearColor];
        deliciousFoodViewBtn.frame =  CGRectMake(SCREEN_WIDTH / 2 + 110, 58, 33, 60);
        deliciousFoodViewBtn.imageView.image = [UIImage imageNamed:@"delicious_food"];
        deliciousFoodViewBtn.imageView.highlightedImage = [UIImage imageNamed:@"delicious_food_highlighted"];
        deliciousFoodViewBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        deliciousFoodViewBtn.titleLabel.textColor = [UIColor whiteColor];
        deliciousFoodViewBtn.titleLabel.highlightedTextColor = [UIColor whiteColor];
        deliciousFoodViewBtn.titleLabel.text = @"美食";
        
        for (UIGestureRecognizer *recognizer in deliciousFoodViewBtn.gestureRecognizers) {
            [deliciousFoodViewBtn removeGestureRecognizer:recognizer];
        }
        UITapGestureRecognizer *deliciousFoodRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchFilterType:)];
        [deliciousFoodViewBtn addGestureRecognizer:deliciousFoodRecognizer];
        [self.arrFilterCategoryViews addObject:deliciousFoodViewBtn];
        [_filterCategoryView addSubview:deliciousFoodViewBtn];
        
    }
    return _filterCategoryView;
}

- (STBMPCollectionView *)bmpColView
{
    if (!_bmpColView) {
        _bmpColView = [[STBMPCollectionView alloc] initWithFrame:CGRectMake(0, 41, SCREEN_WIDTH, 220)];
        _bmpColView.delegate = self;
        _bmpColView.hidden = YES;
        _bmpStrenghView = [[STBmpStrengthView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 260 - 35.5, SCREEN_WIDTH, 35.5)];
        _bmpStrenghView.backgroundColor = [UIColor clearColor];
        _bmpStrenghView.hidden = YES;
        _bmpStrenghView.delegate = self;
        [self.view addSubview:_bmpStrenghView];
    }
    return _bmpColView;
}

#pragma STBmpStrengthViewDelegate
- (void)sliderValueDidChange:(float)value
{
    if (!_hBmpHandle) {
        return;
    }
    st_makeup_type makeupType;
    switch (_bmp_Current_Model.m_bmpType) {
        case STBMPTYPE_EYE:
            _bmp_Eye_Model.m_bmpStrength = value;
            _bmp_Eye_Value = value;
            makeupType = [self getMakeUpType:STBMPTYPE_EYE];
            break;
        case STBMPTYPE_EYELINER:
            _bmp_EyeLiner_Model.m_bmpStrength = value;
            _bmp_EyeLiner_Value = value;
            makeupType = [self getMakeUpType:STBMPTYPE_EYELINER];
            break;
        case STBMPTYPE_EYELASH:
            _bmp_EyeLash_Model.m_bmpStrength = value;
            _bmp_EyeLash_Value = value;
            makeupType = [self getMakeUpType:STBMPTYPE_EYELASH];
            break;
        case STBMPTYPE_LIP:
            _bmp_Lip_Model.m_bmpStrength = value;
            _bmp_Lip_Value = value;
            makeupType = [self getMakeUpType:STBMPTYPE_LIP];
            break;
        case STBMPTYPE_BROW:
            _bmp_Brow_Model.m_bmpStrength = value;
            _bmp_Brow_Value = value;
            makeupType = [self getMakeUpType:STBMPTYPE_BROW];
            break;
        case STBMPTYPE_FACE:
            _bmp_Face_Model.m_bmpStrength = value;
            _bmp_Face_Value = value;
            makeupType = [self getMakeUpType:STBMPTYPE_FACE];
            break;
        case STBMPTYPE_BLUSH:
            _bmp_Blush_Model.m_bmpStrength = value;
            _bmp_Blush_Value = value;
            makeupType = [self getMakeUpType:STBMPTYPE_BLUSH];
            break;
        case STBMPTYPE_EYEBALL:
            _bmp_Eyeball_Model.m_bmpStrength = value;
            _bmp_Eyeball_Value = value;
            makeupType = [self getMakeUpType:STBMPTYPE_EYEBALL];
            break;
        case STBMPTYPE_COUNT:
            break;
    }
    
    [_bmpStrenghView updateSliderValue:value];
    st_mobile_makeup_set_strength_for_type(_hBmpHandle, makeupType, value);
}

#pragma STBMPCollectionViewDelegate
- (void)didSelectedDetailModel:(STBMPModel *)model
{
    _bmp_Current_Model = model;
    
    if (model.m_index == 0) {
        _bmpStrenghView.hidden = YES;
        _bMakeUp = NO;
    }else{
        _bmpStrenghView.hidden = NO;
        _bMakeUp = YES;
    }
    
    st_makeup_type makeupType = [self getMakeUpType:model.m_bmpType];
    if (model.m_zipPath) {
        st_mobile_makeup_set_makeup_for_type(_hBmpHandle, makeupType, model.m_zipPath.UTF8String, NULL);
    }else{
        st_mobile_makeup_set_makeup_for_type(_hBmpHandle, makeupType, NULL, NULL);
    }
    
    unsigned long long config = 0;
    st_result_t iRet = st_mobile_makeup_get_trigger_action(_hBmpHandle, &config);
    if (iRet == ST_OK) {
        _makeUpConf = config;
    }
    
    switch (model.m_bmpType) {
        case STBMPTYPE_EYE:
            _bmp_Eye_Model = model;
            [_bmpStrenghView updateSliderValue:_bmp_Eye_Value];
            st_mobile_makeup_set_strength_for_type(_hBmpHandle, makeupType, _bmp_Eye_Value);
            break;
        case STBMPTYPE_EYELINER:
            _bmp_EyeLiner_Model = model;
            [_bmpStrenghView updateSliderValue:_bmp_EyeLiner_Value];
            st_mobile_makeup_set_strength_for_type(_hBmpHandle, makeupType, _bmp_EyeLiner_Value);
            break;
        case STBMPTYPE_EYELASH:
            _bmp_EyeLash_Model = model;
            [_bmpStrenghView updateSliderValue:_bmp_EyeLash_Value];
            st_mobile_makeup_set_strength_for_type(_hBmpHandle, makeupType, _bmp_EyeLash_Value);
            break;
        case STBMPTYPE_LIP:
            _bmp_Lip_Model = model;
            [_bmpStrenghView updateSliderValue:_bmp_Lip_Value];
             st_mobile_makeup_set_strength_for_type(_hBmpHandle, makeupType, _bmp_Lip_Value);
            break;
        case STBMPTYPE_BROW:
            _bmp_Brow_Model = model;
            [_bmpStrenghView updateSliderValue:_bmp_Brow_Value];
             st_mobile_makeup_set_strength_for_type(_hBmpHandle, makeupType, _bmp_Brow_Value);
            break;
        case STBMPTYPE_FACE:
            _bmp_Face_Model = model;
            [_bmpStrenghView updateSliderValue:_bmp_Face_Value];
            st_mobile_makeup_set_strength_for_type(_hBmpHandle, makeupType, _bmp_Face_Value);
            break;
        case STBMPTYPE_BLUSH:
            _bmp_Blush_Model = model;
            [_bmpStrenghView updateSliderValue:_bmp_Blush_Value];
            st_mobile_makeup_set_strength_for_type(_hBmpHandle, makeupType, _bmp_Blush_Value);
            break;
        case STBMPTYPE_EYEBALL:
            _bmp_Eyeball_Model = model;
            [_bmpStrenghView updateSliderValue:_bmp_Eyeball_Value];
            st_mobile_makeup_set_strength_for_type(_hBmpHandle, makeupType, _bmp_Eyeball_Value);
            break;
        case STBMPTYPE_COUNT:
            break;
    }
}

- (void)backToMainView
{
    self.bmpStrenghView.hidden = YES;
}

- (st_makeup_type)getMakeUpType:(STBMPTYPE)bmpType
{
    st_makeup_type type;
    switch (bmpType) {
        case STBMPTYPE_EYE:
            type = ST_MAKEUP_TYPE_EYE;
            break;
        case STBMPTYPE_EYELINER:
            type = ST_MAKEUP_TYPE_EYELINER;
            break;
        case STBMPTYPE_EYELASH:
            type = ST_MAKEUP_TYPE_EYELASH;
            break;
        case STBMPTYPE_LIP:
            type =  ST_MAKEUP_TYPE_LIP;
            break;
        case STBMPTYPE_BROW:
            type =  ST_MAKEUP_TYPE_BROW;
            break;
        case STBMPTYPE_FACE:
            type =  ST_MAKEUP_TYPE_NOSE;
            break;
        case STBMPTYPE_BLUSH:
            type =  ST_MAKEUP_TYPE_FACE;
            break;
        case STBMPTYPE_EYEBALL:
            type = ST_MAKEUP_TYPE_EYEBALL;
            break;
        case STBMPTYPE_COUNT:
            break;
    }
    
    return type;
}

- (void)resetBmp
{
    [self resetBmpModels];
    
    st_mobile_makeup_clear_makeups(_hBmpHandle);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"resetUIs" object:nil];
}

- (void)resetBmpModels
{
     _bmp_Eye_Value = _bmp_EyeLiner_Value = _bmp_EyeLash_Value = _bmp_Lip_Value = _bmp_Brow_Value = _bmp_Nose_Value = _bmp_Face_Value = _bmp_Blush_Value = _bmp_Eyeball_Value = 0.8;
}

- (void)switchFilterType:(UITapGestureRecognizer *)recognizer {
    
    [UIView animateWithDuration:0.5 animations:^{
        self.filterCategoryView.frame = CGRectMake(-SCREEN_WIDTH, self.filterCategoryView.frame.origin.y, SCREEN_WIDTH, 300);
        self.filterView.frame = CGRectMake(0, self.filterView.frame.origin.y, SCREEN_WIDTH, 300);
    }];
    
    if (self.currentSelectedFilterModel.modelType == recognizer.view.tag && self.currentSelectedFilterModel.isSelected) {
        self.filterStrengthView.hidden = NO;
    } else {
        self.filterStrengthView.hidden = YES;
    }
    
    //    self.filterStrengthView.hidden = !(self.currentSelectedFilterModel.modelType == recognizer.view.tag);
    
    switch (recognizer.view.tag) {
            
        case STEffectsTypeFilterPortrait:
            
            _filterView.leftView.imageView.image = [UIImage imageNamed:@"portrait_highlighted"];
            _filterView.leftView.titleLabel.text = @"人物";
            _filterView.filterCollectionView.arrModels = _filterView.filterCollectionView.arrPortraitFilterModels;
            
            break;
            
            
        case STEffectsTypeFilterScenery:
            
            _filterView.leftView.imageView.image = [UIImage imageNamed:@"scenery_highlighted"];
            _filterView.leftView.titleLabel.text = @"风景";
            _filterView.filterCollectionView.arrModels = _filterView.filterCollectionView.arrSceneryFilterModels;
            
            break;
            
        case STEffectsTypeFilterStillLife:
            
            _filterView.leftView.imageView.image = [UIImage imageNamed:@"still_life_highlighted"];
            _filterView.leftView.titleLabel.text = @"静物";
            _filterView.filterCollectionView.arrModels = _filterView.filterCollectionView.arrStillLifeFilterModels;
            
            break;
            
        case STEffectsTypeFilterDeliciousFood:
            
            _filterView.leftView.imageView.image = [UIImage imageNamed:@"delicious_food_highlighted"];
            _filterView.leftView.titleLabel.text = @"美食";
            _filterView.filterCollectionView.arrModels = _filterView.filterCollectionView.arrDeliciousFoodFilterModels;
            
            break;
            
        default:
            break;
    }
    
    [_filterView.filterCollectionView reloadData];
}

- (void)refreshFilterCategoryState:(STEffectsType)type {
    
    for (int i = 0; i < self.arrFilterCategoryViews.count; ++i) {
        
        if (self.arrFilterCategoryViews[i].highlighted) {
            self.arrFilterCategoryViews[i].highlighted = NO;
        }
    }
    
    switch (type) {
        case STEffectsTypeFilterPortrait:
            
            self.arrFilterCategoryViews[0].highlighted = YES;
            
            break;
            
        case STEffectsTypeFilterScenery:
            
            self.arrFilterCategoryViews[1].highlighted = YES;
            
            break;
            
        case STEffectsTypeFilterStillLife:
            
            self.arrFilterCategoryViews[2].highlighted = YES;
            
            break;
            
        case STEffectsTypeFilterDeliciousFood:
            
            self.arrFilterCategoryViews[3].highlighted = YES;
            
            break;
            
        default:
            break;
    }
}

- (STScrollTitleView *)beautyScrollTitleViewNew {
    if (!_beautyScrollTitleViewNew) {
        
        NSArray *beautyCategory = @[@"基础美颜", @"美形", @"微整形", @"美妆",@"滤镜", @"调整"];
        NSArray *beautyType = @[@(STEffectsTypeBeautyBase),
                                @(STEffectsTypeBeautyShape),
                                @(STEffectsTypeBeautyMicroSurgery),
                                @(STEffectsTypeBeautyMakeUp),
                                @(STEffectsTypeBeautyFilter),
                                @(STEffectsTypeBeautyAdjust)];
        
        STWeakSelf;
        _beautyScrollTitleViewNew = [[STScrollTitleView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40) titles:beautyCategory effectsType:beautyType titleOnClick:^(STTitleViewItem *titleView, NSInteger index, STEffectsType type) {
            [weakSelf handleEffectsType:type];
        }];
        _beautyScrollTitleViewNew.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _beautyScrollTitleViewNew;
}

- (STScrollTitleView *)scrollTitleView {
    if (!_scrollTitleView) {
        
        STWeakSelf;
        
        NSArray *stickerTypeArray = @[
                                      @(STEffectsTypeStickerMy),
                                      @(STEffectsTypeStickerNew),
                                      @(STEffectsTypeSticker2D),
                                      @(STEffectsTypeStickerAvatar),
                                      @(STEffectsTypeSticker3D),
                                      @(STEffectsTypeStickerGesture),
                                      @(STEffectsTypeStickerSegment),
                                      @(STEffectsTypeStickerFaceDeformation),
                                      @(STEffectsTypeStickerFaceChange),
                                      @(STEffectsTypeStickerParticle),
                                      @(STEffectsTypeObjectTrack)];
        
        NSArray *normalImages = @[
                                  [UIImage imageNamed:@"native.png"],
                                  [UIImage imageNamed:@"new_sticker.png"],
                                  [UIImage imageNamed:@"2d.png"],
                                  [UIImage imageNamed:@"avatar.png"],
                                  [UIImage imageNamed:@"3d.png"],
                                  [UIImage imageNamed:@"sticker_gesture.png"],
                                  [UIImage imageNamed:@"sticker_segment.png"],
                                  [UIImage imageNamed:@"sticker_face_deformation.png"],
                                  [UIImage imageNamed:@"face_painting.png"],
                                  [UIImage imageNamed:@"particle_effect.png"],
                                  [UIImage imageNamed:@"common_object_track.png"]
                                  ];
        NSArray *selectedImages = @[
                                    [UIImage imageNamed:@"native_selected.png"],
                                    [UIImage imageNamed:@"new_sticker_selected.png"],
                                    [UIImage imageNamed:@"2d_selected.png"],
                                    [UIImage imageNamed:@"avatar_selected.png"],
                                    [UIImage imageNamed:@"3d_selected.png"],
                                    [UIImage imageNamed:@"sticker_gesture_selected.png"],
                                    [UIImage imageNamed:@"sticker_segment_selected.png"],
                                    [UIImage imageNamed:@"sticker_face_deformation_selected.png"],
                                    [UIImage imageNamed:@"face_painting_selected.png"],
                                    [UIImage imageNamed:@"particle_effect_selected.png"],
                                    [UIImage imageNamed:@"common_object_track_selected.png"]
                                    ];
        
        
        _scrollTitleView = [[STScrollTitleView alloc] initWithFrame:CGRectMake(57, 0, SCREEN_WIDTH - 57, 40) normalImages:normalImages selectedImages:selectedImages effectsType:stickerTypeArray titleOnClick:^(STTitleViewItem *titleView, NSInteger index, STEffectsType type) {
            
            [weakSelf handleEffectsType:type];
        }];
        
        _scrollTitleView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _scrollTitleView;
}


- (EffectsCollectionView *)effectsList
{
    if (!_effectsList) {
        
        __weak typeof(self) weakSelf = self;
        _effectsList = [[EffectsCollectionView alloc] initWithFrame:CGRectMake(0, 41, SCREEN_WIDTH, 140)];
        [_effectsList registerNib:[UINib nibWithNibName:@"EffectsCollectionViewCell"
                                                 bundle:[NSBundle mainBundle]]
       forCellWithReuseIdentifier:@"EffectsCollectionViewCell"];
        _effectsList.numberOfSectionsInView = ^NSInteger(STCustomCollectionView *collectionView) {
            
            return 1;
        };
        _effectsList.numberOfItemsInSection = ^NSInteger(STCustomCollectionView *collectionView, NSInteger section) {
            
            return weakSelf.arrCurrentModels.count;
        };
        _effectsList.cellForItemAtIndexPath = ^UICollectionViewCell *(STCustomCollectionView *collectionView, NSIndexPath *indexPath) {
            
            static NSString *strIdentifier = @"EffectsCollectionViewCell";
            
            EffectsCollectionViewCell *cell = (EffectsCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:strIdentifier forIndexPath:indexPath];
            
            NSArray *arrModels = weakSelf.arrCurrentModels;
            
            if (arrModels.count) {
                
                EffectsCollectionViewCellModel *model = arrModels[indexPath.item];
                
                if (model.iEffetsType != STEffectsTypeStickerMy) {
                    
                    id cacheObj = [weakSelf.thumbnailCache objectForKey:model.material.strMaterialFileID];
                    
                    if (cacheObj && [cacheObj isKindOfClass:[UIImage class]]) {
                        
                        model.imageThumb = cacheObj;
                    }else{
                        
                        model.imageThumb = [UIImage imageNamed:@"none"];
                    }
                }
                
                cell.model = model;
                
                return cell;
            }else{
                
                cell.model = nil;
                
                return cell;
            }
        };
        _effectsList.didSelectItematIndexPath = ^(STCustomCollectionView *collectionView, NSIndexPath *indexPath) {
            
            NSArray *arrModels = weakSelf.arrCurrentModels;
            
            [weakSelf handleStickerChanged:arrModels[indexPath.item]];
        };
    }
    
    return _effectsList;
}



- (STCollectionView *)objectTrackCollectionView {
    if (!_objectTrackCollectionView) {
        
        __weak typeof(self) weakSelf = self;
        _objectTrackCollectionView = [[STCollectionView alloc] initWithFrame:CGRectMake(0, 41, SCREEN_WIDTH, 140) withModels:nil andDelegateBlock:^(STCollectionViewDisplayModel *model) {
            [weakSelf handleObjectTrackChanged:model];
        }];
        
        _objectTrackCollectionView.arrModels = self.arrObjectTrackers;
        _objectTrackCollectionView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _objectTrackCollectionView;
}


- (STNewBeautyCollectionView *)beautyCollectionView {
    
    if (!_beautyCollectionView) {
        
        STWeakSelf;
        
        _beautyCollectionView = [[STNewBeautyCollectionView alloc] initWithFrame:CGRectMake(0, 41, SCREEN_WIDTH, 220) models:self.baseBeautyModels delegateBlock:^(STNewBeautyCollectionViewModel *model) {
            
            [weakSelf handleBeautyTypeChanged:model];
            
            
        }];
        
        _beautyCollectionView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        
        [_beautyCollectionView reloadData];
    }
    return _beautyCollectionView;
}

- (void)handleBeautyTypeChanged:(STNewBeautyCollectionViewModel *)model {
    
    float preType = self.curBeautyBeautyType;
    float preValue = self.beautySlider.value;
    float curValue = -2;
    float lblVal = -2;
    
    self.curBeautyBeautyType = model.beautyType;
    
    self.beautySlider.hidden = NO;
    
    
    switch (model.beautyType) {
            
        case STBeautyTypeNone:
        case STBeautyTypeWhiten:
        case STBeautyTypeRuddy:
        case STBeautyTypeDermabrasion:
        case STBeautyTypeDehighlight:
        case STBeautyTypeShrinkFace:
        case STBeautyTypeEnlargeEyes:
        case STBeautyTypeShrinkJaw:
        case STBeautyTypeThinFaceShape:
        case STBeautyTypeNarrowNose:
        case STBeautyTypeContrast:
        case STBeautyTypeSaturation:
        case STBeautyTypeNarrowFace:
        case STBeautyTypeRoundEye:
        case STBeautyTypeAppleMusle:
        case STBeautyTypeProfileRhinoplasty:
        case STBeautyTypeBrightEye:
        case STBeautyTypeRemoveDarkCircles:
        case STBeautyTypeWhiteTeeth:
        case STBeautyTypeOpenCanthus:
        case STBeautyTypeRemoveNasolabialFolds:
            
            
            curValue = model.beautyValue / 50.0 - 1;
            lblVal = (curValue + 1) * 50.0;
            
            break;
            
            
        case STBeautyTypeChin:
        case STBeautyTypeHairLine:
        case STBeautyTypeLengthNose:
        case STBeautyTypeMouthSize:
        case STBeautyTypeLengthPhiltrum:
        case STBeautyTypeEyeAngle:
        case STBeautyTypeEyeDistance:
            
            curValue = model.beautyValue / 100.0;
            lblVal = curValue * 100.0;
            
            break;
    }
    
    if (curValue == preValue && preType != model.beautyType) {
        
        if (lblVal > 9.9 && lblVal < 10.0) {
            lblVal = 10;
        }
        
        self.beautySlider.valueLabel.text = [NSString stringWithFormat:@"%d", (int)lblVal];
    }
    self.beautySlider.value = curValue;
}

- (UIView *)settingView {
    
    if (!_settingView) {
        _settingView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 230)];
        _settingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        
        [_settingView addSubview:self.resolutionLabel];
        [_settingView addSubview:self.btn640x480];
        [_settingView addSubview:self.btn1280x720];
        [_settingView addSubview:self.btn1920x1080];
        [_settingView addSubview:self.attributeLabel];
        [_settingView addSubview:self.attributeSwitch];
        [_settingView addSubview:self.lblTermsOfUse];
    }
    return _settingView;
}

- (UIButton *)btnChangeCamera {
    
    if (!_btnChangeCamera) {
        
        UIImage *image = [UIImage imageNamed:@"camera_rotate.png"];
        
        if ([self isNotchScreen]) {
            _btnChangeCamera = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 15 - image.size.width, 35, image.size.width, image.size.height)];
        } else {
            _btnChangeCamera = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 15 - image.size.width, 7, image.size.width, image.size.height)];
        }
        [_btnChangeCamera setImage:image forState:UIControlStateNormal];
        [_btnChangeCamera addTarget:self action:@selector(onBtnChangeCamera) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _btnChangeCamera;
}

- (UIButton *)btnSetting {
    
    if (!_btnSetting) {
        
        UIImage *image = [UIImage imageNamed:@"btn_setting_gray.png"];
        
        if ([self isNotchScreen]) {
            _btnSetting = [[UIButton alloc] initWithFrame:CGRectMake(15, 35, image.size.width, image.size.height)];
        } else {
            _btnSetting = [[UIButton alloc] initWithFrame:CGRectMake(15, 7, image.size.width, image.size.height)];
        }
        
        [_btnSetting setImage:image forState:UIControlStateNormal];
        [_btnSetting addTarget:self action:@selector(onBtnSetting) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnSetting;
}

- (STButton *)btnAlbum {
    
    if (!_btnAlbum) {
        
        UIImage *image = [UIImage imageNamed:@"btn_album"];
        
        if ([self isNotchScreen]) {
            
            _btnAlbum = [[STButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - image.size.width / 2, 35, image.size.width, image.size.height)];
            
        } else {
            _btnAlbum = [[STButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - image.size.width / 2, 7, image.size.width, image.size.height)];
        }
        
        [_btnAlbum setImage:image forState:UIControlStateNormal];
        [_btnAlbum addTarget:self action:@selector(onBtnAlbum) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnAlbum;
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

- (UILabel *)resolutionLabel {
    
    CGRect bounds = [@"分辨率" boundingRectWithSize:CGSizeMake(MAXFLOAT, 0.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]} context:nil];
    
    
    if (!_resolutionLabel) {
        _resolutionLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 33, bounds.size.width, bounds.size.height)];
        _resolutionLabel.text = @"分辨率";
        _resolutionLabel.font = [UIFont systemFontOfSize:15];
        _resolutionLabel.textColor = [UIColor whiteColor];
    }
    return _resolutionLabel;
}

- (UIButton *)btn640x480 {
    
    if (!_btn640x480) {
        _btn640x480 = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.resolutionLabel.frame) + 21, 25, 64, 35)];
        
        _btn640x480.backgroundColor = [UIColor clearColor];
        _btn640x480.layer.cornerRadius = 7;
        _btn640x480.layer.borderColor = [UIColor whiteColor].CGColor;
        [_btn640x480.layer addSublayer:self.btn640x480BorderLayer];
        
        
        [_btn640x480 setTitle:@"640x480" forState:UIControlStateNormal];
        [_btn640x480 setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
        _btn640x480.titleLabel.font = [UIFont systemFontOfSize:15];
        _btn640x480.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [_btn640x480 addTarget:self action:@selector(changeResolution:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    return _btn640x480;
}

- (UIButton *)btn1280x720 {
    
    if (!_btn1280x720) {
        
        _btn1280x720 = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.btn640x480.frame) + 20, 25, 73, 35)];
        
        _btn1280x720.backgroundColor = [UIColor clearColor];
        _btn1280x720.layer.cornerRadius = 7;
        _btn1280x720.layer.borderColor = [UIColor whiteColor].CGColor;
        _btn1280x720.layer.borderWidth = 1;
        [_btn1280x720.layer addSublayer:self.btn1280x720BorderLayer];
       
        
        [_btn1280x720 setTitle:@"1280x720" forState:UIControlStateNormal];
        [_btn1280x720 setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
        _btn1280x720.titleLabel.font = [UIFont systemFontOfSize:15];
        _btn1280x720.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [_btn1280x720 addTarget:self action:@selector(changeResolution:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _btn1280x720;
}

- (UIButton *)btn1920x1080 {
    
    if (!_btn1920x1080) {
        
        _btn1920x1080 = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.btn1280x720.frame) + 20, 25, 73, 35)];
        
        _btn1920x1080.backgroundColor = [UIColor whiteColor];
        _btn1920x1080.layer.cornerRadius = 7;
        _btn1920x1080.layer.borderColor = [UIColor whiteColor].CGColor;
        _btn1920x1080.layer.borderWidth = 1;
        [_btn1920x1080.layer addSublayer:self.btn1920x1080BorderLayer];
        self.btn1920x1080BorderLayer.hidden = YES;
        
        [_btn1920x1080 setTitle:@"1920x1080" forState:UIControlStateNormal];
        [_btn1920x1080 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _btn1920x1080.titleLabel.font = [UIFont systemFontOfSize:13];
        _btn1920x1080.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        [_btn1920x1080 addTarget:self action:@selector(changeResolution:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _btn1920x1080;
}

- (UILabel *)attributeLabel {
    
    if (!_attributeLabel) {
        _attributeLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, CGRectGetMaxY(self.resolutionLabel.frame) + 30, CGRectGetMaxX(self.resolutionLabel.frame), self.resolutionLabel.frame.size.height)];
        _attributeLabel.text = @"性  能";
        _attributeLabel.textAlignment = NSTextAlignmentLeft;
        _attributeLabel.font = [UIFont systemFontOfSize:15];
        _attributeLabel.textColor = [UIColor whiteColor];
    }
    return _attributeLabel;
}

- (UILabel *)lblTermsOfUse {
    
    if (!_lblTermsOfUse) {
        _lblTermsOfUse = [[UILabel alloc] initWithFrame:CGRectMake(45, CGRectGetMaxY(self.attributeLabel.frame) + 25, 100, 20)];
        _lblTermsOfUse.userInteractionEnabled = YES;
        NSString *str = @"使用条款";
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:str];
        [attributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:NSMakeRange(0, 4)];
        [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, 4)];
        [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, 4)];
        _lblTermsOfUse.attributedText = attributedString;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTermsOfUse:)];
        [_lblTermsOfUse addGestureRecognizer:tapGesture];
        
    }
    return _lblTermsOfUse;
}

- (UISwitch *)attributeSwitch {
    
    if (!_attributeSwitch) {
        _attributeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(self.btn640x480.frame.origin.x, CGRectGetMaxY(self.btn640x480.frame) + 15, 79, 35)];
        [_attributeSwitch addTarget:self action:@selector(onAttributeSwitch:) forControlEvents:UIControlEventValueChanged];
    }
    return _attributeSwitch;
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

- (STTriggerView *)triggerView {
    
    if (!_triggerView) {
        
        _triggerView = [[STTriggerView alloc] init];
    }
    
    return _triggerView;
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

- (UILabel *)lblSpeed {
    if (!_lblSpeed) {
        
        _lblSpeed = [[UILabel alloc] initWithFrame:CGRectMake(0, 60 ,SCREEN_WIDTH, 15)];
        _lblSpeed.textAlignment = NSTextAlignmentLeft;
        [_lblSpeed setTextColor:[UIColor whiteColor]];
        [_lblSpeed setBackgroundColor:[UIColor clearColor]];
        [_lblSpeed setFont:[UIFont systemFontOfSize:15.0]];
        [_lblSpeed setShadowColor:[UIColor blackColor]];
        [_lblSpeed setShadowOffset:CGSizeMake(1.0, 1.0)];
    }
    
    return _lblSpeed;
}

- (UILabel *)lblCPU {
    
    if (!_lblCPU) {
        
        _lblCPU = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(_lblSpeed.frame), CGRectGetMaxY(_lblSpeed.frame) + 2 , CGRectGetWidth(_lblSpeed.frame), CGRectGetHeight(_lblSpeed.frame))];
        _lblCPU.textAlignment = NSTextAlignmentLeft;
        [_lblCPU setTextColor:[UIColor whiteColor]];
        [_lblCPU setBackgroundColor:[UIColor clearColor]];
        [_lblCPU setFont:[UIFont systemFontOfSize:15.0]];
        [_lblCPU setShadowColor:[UIColor blackColor]];
        [_lblCPU setShadowOffset:CGSizeMake(1.0, 1.0)];
    }
    
    return _lblCPU;
}

- (UILabel *)lblBodyAction {
    
    if (!_lblBodyAction) {
        _lblBodyAction = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.lblCPU.frame), CGRectGetMaxY(self.lblCPU.frame) + 2, SCREEN_WIDTH, 15)];
        _lblBodyAction.textAlignment = NSTextAlignmentLeft;
        [_lblBodyAction setTextColor:[UIColor whiteColor]];
        [_lblBodyAction setBackgroundColor:[UIColor clearColor]];
        [_lblBodyAction setFont:[UIFont systemFontOfSize:15.0]];
        [_lblBodyAction setShadowColor:[UIColor blackColor]];
        [_lblBodyAction setShadowOffset:CGSizeMake(1.0, 1.0)];
    }
    return _lblBodyAction;
}


- (CAShapeLayer *)btn640x480BorderLayer {
    
    if (!_btn640x480BorderLayer) {
        
        _btn640x480BorderLayer = [CAShapeLayer layer];
        
        _btn640x480BorderLayer.frame = self.btn640x480.bounds;
        _btn640x480BorderLayer.strokeColor = [UIColor whiteColor].CGColor;
        _btn640x480BorderLayer.fillColor = nil;
        _btn640x480BorderLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.btn640x480.bounds cornerRadius:7].CGPath;
        _btn640x480BorderLayer.lineWidth = 1;
        _btn640x480BorderLayer.lineDashPattern = @[@4, @2];
    }
    return _btn640x480BorderLayer;
}

- (CAShapeLayer *)btn1280x720BorderLayer {
    
    if (!_btn1280x720BorderLayer) {
        
        _btn1280x720BorderLayer = [CAShapeLayer layer];
        
        _btn1280x720BorderLayer.frame = self.btn1280x720.bounds;
        _btn1280x720BorderLayer.strokeColor = [UIColor whiteColor].CGColor;
        _btn1280x720BorderLayer.fillColor = nil;
        _btn1280x720BorderLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.btn1280x720.bounds cornerRadius:7].CGPath;
        _btn1280x720BorderLayer.lineWidth = 1;
        _btn1280x720BorderLayer.lineDashPattern = @[@4, @2];
    }
    return _btn1280x720BorderLayer;
}

- (CAShapeLayer *)btn1920x1080BorderLayer  {
    
    if (!_btn1920x1080BorderLayer) {
        
        _btn1920x1080BorderLayer = [CAShapeLayer layer];
        
        _btn1920x1080BorderLayer.frame = self.btn1920x1080.frame;
        _btn1920x1080BorderLayer.strokeColor = [UIColor whiteColor].CGColor;
        _btn1920x1080BorderLayer.fillColor = nil;
        _btn1920x1080BorderLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.btn1920x1080.bounds cornerRadius:7].CGPath;
        _btn1920x1080BorderLayer.lineWidth = 1;
        _btn1920x1080BorderLayer.lineDashPattern = @[@4, @2];
    }
    return _btn1920x1080BorderLayer;
}

- (UIImageView *)recordImageView {
    
    if (!_recordImageView) {
        
        UIImage *image = [UIImage imageNamed:@"record_video.png"];
        
        _recordImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.gradientView.center.x - image.size.width / 2, CGRectGetMinY(self.gradientView.frame) - image.size.height, image.size.width, image.size.height)];
        _recordImageView.image = image;
        _recordImageView.hidden = YES;
    }
    return _recordImageView;
}

- (UILabel *)recordTimeLabel {
    
    if (!_recordTimeLabel) {
        
        _recordTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, SCREEN_HEIGHT - 100, 70, 35)];
        _recordTimeLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _recordTimeLabel.layer.cornerRadius = 5;
        _recordTimeLabel.clipsToBounds = YES;
        _recordTimeLabel.font = [UIFont systemFontOfSize:11];
        _recordTimeLabel.textAlignment = NSTextAlignmentCenter;
        _recordTimeLabel.textColor = [UIColor whiteColor];
        _recordTimeLabel.text = @"• 00:00:00";
        _recordTimeLabel.hidden = YES;
    }
    
    return _recordTimeLabel;
}

- (UIView *)termsOfUseView {
    
    if (!_termsOfUseView) {
        
        _termsOfUseView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _termsOfUseView.backgroundColor = [UIColor whiteColor];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        titleLabel.backgroundColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = @"使用条款";
        [_termsOfUseView addSubview:titleLabel];
        
        UIButton *btnHide = [[UIButton alloc] initWithFrame:CGRectMake(5, 5, 30, 30)];
        [btnHide setImage:[UIImage imageNamed:@"btn_back.png"] forState:UIControlStateNormal];
        [btnHide addTarget:self action:@selector(hideTermsOfUseView) forControlEvents:UIControlEventTouchUpInside];
        [_termsOfUseView addSubview:btnHide];
        
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, SCREEN_HEIGHT - 40)];
        _webView.delegate = self;
        _webView.scrollView.bounces = NO;
        _webView.scrollView.showsVerticalScrollIndicator = NO;
        _webView.scrollView.showsHorizontalScrollIndicator = NO;
        [_termsOfUseView addSubview:_webView];
        
        UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 25, SCREEN_HEIGHT / 2 - 25, 50, 50)];
        indicatorView.color = [UIColor grayColor];
        [_termsOfUseView addSubview:indicatorView];
        _indicatorView = indicatorView;
        
        if ([self isNotchScreen]) {
            titleLabel.frame = CGRectMake(0, 30, SCREEN_WIDTH, 30);
            btnHide.frame = CGRectMake(5, 30, 30, 30);
            _webView.frame = CGRectMake(0, 70, SCREEN_WIDTH, SCREEN_HEIGHT - 70);
        }
        _termsOfUseView.hidden = YES;
    }
    return _termsOfUseView;
}

- (UIButton *)resetBtn {
    if (!_resetBtn) {
        
        _resetBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, SCREEN_HEIGHT - 50, 100, 30)];
        _resetBtn.center = CGPointMake(_resetBtn.center.x, self.beautyBtn.center.y);
        
        [_resetBtn setImage:[UIImage imageNamed:@"reset"] forState:UIControlStateNormal];
        [_resetBtn setTitle:@"重置" forState:UIControlStateNormal];
        _resetBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_resetBtn setTitleColor:UIColorFromRGB(0xffffff) forState:UIControlStateNormal];
        [_resetBtn addTarget:self action:@selector(resetBeautyValues:) forControlEvents:UIControlEventTouchUpInside];
        
        _resetBtn.hidden = YES;
    }
    return _resetBtn;
}

- (void)resetBeautyValues:(UIButton *)sender {
    
    switch (_curEffectBeautyType) {
        
        //reset filter to baby pink
        case STEffectsTypeBeautyFilter:
        {
            
            [self refreshFilterCategoryState:STEffectsTypeFilterPortrait];
            
            self.fFilterStrength = 0.65;
            self.lblFilterStrength.text = @"65";
            self.filterStrengthSlider.value = 0.65;
            
            if (self.filterView.filterCollectionView.selectedModel.modelType == STEffectsTypeFilterPortrait) {
                
                self.filterView.filterCollectionView.selectedModel.isSelected = NO;
                self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex]].isSelected = YES;
                [self.filterView.filterCollectionView reloadData];
                
            } else {
                
                self.filterStrengthView.hidden = YES;
                self.filterView.filterCollectionView.selectedModel.isSelected = NO;
                [self.filterView.filterCollectionView reloadData];
                self.filterView.filterCollectionView.selectedModel = nil;
                self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex]].isSelected = YES;
                
            }
            self.currentSelectedFilterModel = self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex]];
            self.filterView.filterCollectionView.selectedModel = self.currentSelectedFilterModel;
            self.curFilterModelPath = self.currentSelectedFilterModel.strPath;
            st_mobile_gl_filter_set_param(_hFilter, ST_GL_FILTER_STRENGTH, self.fFilterStrength);
        }
            
            break;
        case STEffectsTypeBeautyBase:
            
            self.fSmoothStrength = 0.74;
            self.fReddenStrength = 0.36;
            self.fWhitenStrength = 0.02;
            self.fDehighlightStrength = 0.0;
            
            self.baseBeautyModels[0].beautyValue = 2;
            self.baseBeautyModels[1].beautyValue = 36;
            self.baseBeautyModels[2].beautyValue = 74;
            self.baseBeautyModels[3].beautyValue = 0;
            
            break;
        case STEffectsTypeBeautyShape:
            
            self.fEnlargeEyeStrength = 0.13;
            self.fShrinkFaceStrength = 0.11;
            self.fShrinkJawStrength = 0.10;
            self.fNarrowFaceStrength = 0.0;
            self.fRoundEyeStrength = 0.0;
            
            self.beautyShapeModels[0].beautyValue = 11;
            self.beautyShapeModels[1].beautyValue = 13;
            self.beautyShapeModels[2].beautyValue = 10;
            self.beautyShapeModels[3].beautyValue = 0;
            self.beautyShapeModels[4].beautyValue = 0;
            
            break;
        case STEffectsTypeBeautyMicroSurgery:
            
            self.fThinFaceShapeStrength = 0.0;
            self.fChinStrength = 0.0;
            self.fHairLineStrength = 0.0;
            self.fNarrowNoseStrength = 0.0;
            self.fLongNoseStrength = 0.0;
            self.fMouthStrength = 0.0;
            self.fPhiltrumStrength = 0.0;
            
            self.fEyeDistanceStrength = 0.0;
            self.fEyeAngleStrength = 0.0;
            self.fOpenCanthusStrength = 0.0;
            self.fProfileRhinoplastyStrength = 0.0;
            self.fBrightEyeStrength = 0.0;
            self.fRemoveNasolabialFoldsStrength = 0.0;
            self.fRemoveDarkCirclesStrength = 0.0;
            self.fWhiteTeethStrength = 0.0;
            self.fAppleMusleStrength = 0.0;
            
            self.microSurgeryModels[0].beautyValue = 0;
            self.microSurgeryModels[1].beautyValue = 0;
            self.microSurgeryModels[2].beautyValue = 0;
            self.microSurgeryModels[3].beautyValue = 0;
            self.microSurgeryModels[4].beautyValue = 0;
            self.microSurgeryModels[5].beautyValue = 0;
            self.microSurgeryModels[6].beautyValue = 0;
            self.microSurgeryModels[7].beautyValue = 0;
            self.microSurgeryModels[8].beautyValue = 0;
            self.microSurgeryModels[9].beautyValue = 0;
            self.microSurgeryModels[10].beautyValue = 0;
            self.microSurgeryModels[11].beautyValue = 0;
            self.microSurgeryModels[12].beautyValue = 0;
            self.microSurgeryModels[13].beautyValue = 0;
            self.microSurgeryModels[14].beautyValue = 0;
            self.microSurgeryModels[15].beautyValue = 0;
            
            break;
        case STEffectsTypeBeautyAdjust:
            
            self.fContrastStrength = 0.0;
            self.fSaturationStrength = 0.0;
            
            self.adjustModels[0].beautyValue = 0;
            self.adjustModels[1].beautyValue = 0;
            
            break;
            
        case STEffectsTypeBeautyMakeUp:
            
            [self resetBmp];
            
             break;
        default:
            break;
        
    }
    
    [self.beautyCollectionView reloadData];
    //    self.beautySlider.value = self.beautyCollectionView.selectedModel.beautyValue / 100.0;
    
    
    switch (self.beautyCollectionView.selectedModel.beautyType) {
            
        case STBeautyTypeNone:
        case STBeautyTypeWhiten:
        case STBeautyTypeRuddy:
        case STBeautyTypeDermabrasion:
        case STBeautyTypeDehighlight:
        case STBeautyTypeShrinkFace:
        case STBeautyTypeEnlargeEyes:
        case STBeautyTypeShrinkJaw:
        case STBeautyTypeThinFaceShape:
        case STBeautyTypeNarrowNose:
        case STBeautyTypeContrast:
        case STBeautyTypeSaturation:
        case STBeautyTypeNarrowFace:
        case STBeautyTypeRoundEye:
        case STBeautyTypeAppleMusle:
        case STBeautyTypeProfileRhinoplasty:
        case STBeautyTypeBrightEye:
        case STBeautyTypeRemoveDarkCircles:
        case STBeautyTypeWhiteTeeth:
        case STBeautyTypeOpenCanthus:
        case STBeautyTypeRemoveNasolabialFolds:
            
            self.beautySlider.value = self.beautyCollectionView.selectedModel.beautyValue / 50.0 - 1;
            
            break;
            
            
        case STBeautyTypeChin:
        case STBeautyTypeHairLine:
        case STBeautyTypeLengthNose:
        case STBeautyTypeMouthSize:
        case STBeautyTypeLengthPhiltrum:
        case STBeautyTypeEyeDistance:
        case STBeautyTypeEyeAngle:
            
            self.beautySlider.value = self.beautyCollectionView.selectedModel.beautyValue / 100.0;
            
            break;
    }
}


- (void)hideTermsOfUseView {
    self.termsOfUseView.hidden = YES;
}

- (UIView *)filterStrengthView {
    
    if (!_filterStrengthView) {
        
        _filterStrengthView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 260 - 35.5, SCREEN_WIDTH, 35.5)];
        _filterStrengthView.backgroundColor = [UIColor clearColor];
        _filterStrengthView.hidden = YES;
        
        UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 10, 35.5)];
        leftLabel.textColor = [UIColor whiteColor];
        leftLabel.font = [UIFont systemFontOfSize:11];
        leftLabel.text = @"0";
        [_filterStrengthView addSubview:leftLabel];
        
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(40, 0, SCREEN_WIDTH - 90, 35.5)];
        slider.thumbTintColor = UIColorFromRGB(0x9e4fcb);
        slider.minimumTrackTintColor = UIColorFromRGB(0x9e4fcb);
        slider.maximumTrackTintColor = [UIColor whiteColor];
        slider.value = 1;
        [slider addTarget:self action:@selector(filterSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        _filterStrengthSlider = slider;
        [_filterStrengthView addSubview:slider];
        
        UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 40, 0, 20, 35.5)];
        rightLabel.textColor = [UIColor whiteColor];
        rightLabel.font = [UIFont systemFontOfSize:11];
        rightLabel.text = [NSString stringWithFormat:@"%d", (int)(self.fFilterStrength * 100)];
        _lblFilterStrength = rightLabel;
        [_filterStrengthView addSubview:rightLabel];
    }
    return _filterStrengthView;
}

- (UISlider *)beautySlider {
    if (!_beautySlider) {
        
        _beautySlider = [[STBeautySlider alloc] initWithFrame:CGRectMake(40, SCREEN_HEIGHT - 260 - 40, SCREEN_WIDTH - 90, 40)];
        _beautySlider.thumbTintColor = UIColorFromRGB(0x9e4fcb);
        _beautySlider.minimumTrackTintColor = UIColorFromRGB(0x9e4fcb);
        _beautySlider.maximumTrackTintColor = [UIColor whiteColor];
        _beautySlider.minimumValue = -1;
        _beautySlider.maximumValue = 1;
        _beautySlider.value = -1;
        _beautySlider.hidden = YES;
        _beautySlider.delegate = self;
        [_beautySlider addTarget:self action:@selector(beautySliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _beautySlider;
}

- (void)beautySliderValueChanged:(UISlider *)sender {
    
    
    //[-1,1] -> [0,1]
    float value1 = (sender.value + 1) / 2;
    
    //[-1,1]
    float value2 = sender.value;
    
    STNewBeautyCollectionViewModel *model = self.beautyCollectionView.selectedModel;
    
    //    model.beautyValue = value * 100;
    
    //    [self.beautyCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:model.modelIndex inSection:0]]];
    
    switch (model.beautyType) {
            
        case STBeautyTypeNone:
            break;
        case STBeautyTypeWhiten:
            self.fWhitenStrength = value1;
            model.beautyValue = value1 * 100;
            break;
        case STBeautyTypeRuddy:
            self.fReddenStrength = value1;
            model.beautyValue = value1 * 100;
            break;
        case STBeautyTypeDermabrasion:
            self.fSmoothStrength = value1;
            model.beautyValue = value1 * 100;
            break;
        case STBeautyTypeDehighlight:
            self.fDehighlightStrength = value1;
            model.beautyValue = value1 * 100;
            break;
        case STBeautyTypeShrinkFace:
            self.fShrinkFaceStrength = value1;
            model.beautyValue = value1 * 100;
            break;
        case STBeautyTypeNarrowFace:
            self.fNarrowFaceStrength = value1;
            model.beautyValue = value1 * 100;
            break;
        case STBeautyTypeRoundEye:
            self.fRoundEyeStrength = value1;
            model.beautyValue = value1 * 100;
            break;
        case STBeautyTypeEnlargeEyes:
            self.fEnlargeEyeStrength = value1;
            model.beautyValue = value1 * 100;
            break;
        case STBeautyTypeShrinkJaw:
            self.fShrinkJawStrength = value1;
            model.beautyValue = value1 * 100;
            break;
        case STBeautyTypeThinFaceShape:
            self.fThinFaceShapeStrength = value1;
            model.beautyValue = value1 * 100;
            break;
        case STBeautyTypeChin:
            self.fChinStrength = value2;
            model.beautyValue = value2 * 100;
            break;
        case STBeautyTypeHairLine:
            self.fHairLineStrength = value2;
            model.beautyValue = value2 * 100;
            break;
        case STBeautyTypeNarrowNose:
            self.fNarrowNoseStrength = value1;
            model.beautyValue = value1 * 100;
            break;
        case STBeautyTypeLengthNose:
            self.fLongNoseStrength = value2;
            model.beautyValue = value2 * 100;
            break;
        case STBeautyTypeMouthSize:
            self.fMouthStrength = value2;
            model.beautyValue = value2 * 100;
            break;
        case STBeautyTypeLengthPhiltrum:
            self.fPhiltrumStrength = value2;
            model.beautyValue = value2 * 100;
            break;
        case STBeautyTypeContrast:
            self.fContrastStrength = value1;
            model.beautyValue = value1 * 100;
            break;
        case STBeautyTypeSaturation:
            self.fSaturationStrength = value1;
            model.beautyValue = value1 * 100;
            break;
        case STBeautyTypeAppleMusle:
            self.fAppleMusleStrength = value1;
            model.beautyValue = value1 * 100;
            break;
        case STBeautyTypeProfileRhinoplasty:
            self.fProfileRhinoplastyStrength = value1;
            model.beautyValue = value1 * 100;
            break;
        case STBeautyTypeBrightEye:
            self.fBrightEyeStrength = value1;
            model.beautyValue = value1 * 100;
            break;
        case STBeautyTypeRemoveDarkCircles:
            self.fRemoveDarkCirclesStrength = value1;
            model.beautyValue = value1 * 100;
            break;
        case STBeautyTypeWhiteTeeth:
            self.fWhiteTeethStrength = value1;
            model.beautyValue = value1 * 100;
            break;
        case STBeautyTypeEyeDistance:
            self.fEyeDistanceStrength = value2;
            model.beautyValue = value2 * 100;
            break;
        case STBeautyTypeEyeAngle:
            self.fEyeAngleStrength = value2;
            model.beautyValue = value2 * 100;
            break;
        case STBeautyTypeOpenCanthus:
            self.fOpenCanthusStrength = value1;
            model.beautyValue = value1 * 100;
            break;
        case STBeautyTypeRemoveNasolabialFolds:
            self.fRemoveNasolabialFoldsStrength = value1;
            model.beautyValue = value1 * 100;
            break;
    }
    [self.beautyCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:model.modelIndex inSection:0]]];
}


#pragma mark - PhotoSelectVCDismissDelegate

- (void)photoSelectVCDidDismiss {
    [self initResourceAndStartPreview];
}

#pragma mark - scroll title click events

- (void)onTapNoneSticker:(UITapGestureRecognizer *)tapGesture {
    
    [self cancelStickerAndObjectTrack];
    
    self.noneStickerImageView.highlighted = YES;
}

- (void)cancelStickerAndObjectTrack {
    
    [self handleStickerChanged:nil];
    
    self.objectTrackCollectionView.selectedModel.isSelected = NO;
    [self.objectTrackCollectionView reloadData];
    self.objectTrackCollectionView.selectedModel = nil;
    
    if (_hSticker) {
        self.isNullSticker = YES;
    }
    
    if (_hTracker) {
        
        if (self.commonObjectContainerView.currentCommonObjectView) {
            
            [self.commonObjectContainerView.currentCommonObjectView removeFromSuperview];
        }
    }
    
    self.bTracker = NO;
}

- (void)showTermsOfUse:(UITapGestureRecognizer *)tapGesture {
    self.termsOfUseView.hidden = NO;
    NSString *strTermsOfUsePath = [[NSBundle mainBundle] pathForResource:@"TermsOfUse" ofType:@"htm"];
    NSString *strContentOfTerms = [NSString stringWithContentsOfFile:strTermsOfUsePath encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:strContentOfTerms baseURL:nil];
    [_indicatorView startAnimating];
}

- (void)handleEffectsType:(STEffectsType)type {
    
    switch (type) {
            
        case STEffectsTypeStickerMy:
        case STEffectsTypeSticker2D:
        case STEffectsTypeStickerAvatar:
        case STEffectsTypeSticker3D:
        case STEffectsTypeStickerGesture:
        case STEffectsTypeStickerSegment:
        case STEffectsTypeStickerFaceChange:
        case STEffectsTypeStickerFaceDeformation:
        case STEffectsTypeStickerParticle:
        case STEffectsTypeStickerNew:
        case STEffectsTypeObjectTrack:
            self.curEffectStickerType = type;
            break;
        case STEffectsTypeBeautyFilter:
        case STEffectsTypeBeautyBase:
        case STEffectsTypeBeautyShape:
        case STEffectsTypeBeautyMicroSurgery:
        case STEffectsTypeBeautyAdjust:
            self.curEffectBeautyType = type;
            break;
        case STEffectsTypeBeautyMakeUp:
            self.curEffectBeautyType = type;
            break;
        default:
            break;
    }
    
    if (type != STEffectsTypeBeautyFilter) {
        self.filterStrengthView.hidden = YES;
    }
    
    if (type == self.beautyCollectionView.selectedModel.modelType) {
        self.beautySlider.hidden = NO;
    } else {
        self.beautySlider.hidden = YES;
    }
    
    switch (type) {
            
        case STEffectsTypeStickerMy:
        case STEffectsTypeStickerNew:
        case STEffectsTypeSticker2D:
        case STEffectsTypeStickerAvatar:
        case STEffectsTypeStickerFaceDeformation:
        case STEffectsTypeStickerSegment:
        case STEffectsTypeSticker3D:
        case STEffectsTypeStickerGesture:
        case STEffectsTypeStickerFaceChange:
        case STEffectsTypeStickerParticle:
            
            self.objectTrackCollectionView.hidden = YES;
            
            self.arrCurrentModels = [self.effectsDataSource objectForKey:@(type)];
            [self.effectsList reloadData];
            
            self.effectsList.hidden = NO;
            
            break;
            
            
            
        case STEffectsTypeObjectTrack:
            if (self.stCamera.devicePosition != AVCaptureDevicePositionBack) {
                self.stCamera.devicePosition = AVCaptureDevicePositionBack;
            }
            
            [self resetCommonObjectViewPosition];
            
            self.objectTrackCollectionView.arrModels = self.arrObjectTrackers;
            self.objectTrackCollectionView.hidden = NO;
            self.effectsList.hidden = YES;
            [self.objectTrackCollectionView reloadData];
            
            break;
            
            
        case STEffectsTypeBeautyFilter:
            
            self.filterCategoryView.hidden = NO;
            self.filterView.hidden = NO;
            self.beautyCollectionView.hidden = YES;
            
            self.filterCategoryView.center = CGPointMake(SCREEN_WIDTH / 2, self.filterCategoryView.center.y);
            self.filterView.center = CGPointMake(SCREEN_WIDTH * 3 / 2, self.filterView.center.y);
            
            _bmpColView.hidden = YES;
            _bmpStrenghView.hidden = YES;
            
            break;
            
        case STEffectsTypeBeautyMakeUp:
            self.beautyCollectionView.hidden = YES;
            self.filterCategoryView.hidden = YES;
            self.filterView.hidden = YES;
            
            _bmpColView.hidden = NO;
            
        case STEffectsTypeNone:
            break;
            
        case STEffectsTypeBeautyShape:
            
            [self hideBeautyViewExcept:self.beautyShapeView];
            self.filterStrengthView.hidden = YES;
            
            self.beautyCollectionView.hidden = NO;
            self.filterCategoryView.hidden = YES;
            self.beautyCollectionView.models = self.beautyShapeModels;
            [self.beautyCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            
            _bmpColView.hidden = YES;
            _bmpStrenghView.hidden = YES;
            
            break;
            
        case STEffectsTypeBeautyBase:
            
            self.filterStrengthView.hidden = YES;
            [self hideBeautyViewExcept:self.beautyCollectionView];
            
            self.beautyCollectionView.hidden = NO;
            self.filterCategoryView.hidden = YES;
            self.beautyCollectionView.models = self.baseBeautyModels;
            [self.beautyCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            
            _bmpColView.hidden = YES;
            _bmpStrenghView.hidden = YES;
            
            break;
            
        case STEffectsTypeBeautyMicroSurgery:
            
            
            [self hideBeautyViewExcept:self.beautyCollectionView];
            self.beautyCollectionView.hidden = NO;
            self.filterCategoryView.hidden = YES;
            self.beautyCollectionView.models = self.microSurgeryModels;
            [self.beautyCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            
            _bmpColView.hidden = YES;
            _bmpStrenghView.hidden = YES;
            
            break;
            
        case STEffectsTypeBeautyAdjust:
            [self hideBeautyViewExcept:self.beautyCollectionView];
            self.beautyCollectionView.hidden = NO;
            self.filterCategoryView.hidden = YES;
            self.beautyCollectionView.models = self.adjustModels;
            [self.beautyCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            
            _bmpColView.hidden = YES;
            _bmpStrenghView.hidden = YES;
            
            break;
            
            
        case STEffectsTypeBeautyBody:
            
            self.filterStrengthView.hidden = YES;
            [self hideBeautyViewExcept:self.beautyBodyView];
            break;
            
        default:
            break;
    }
    
}

#pragma mark - collectionview click events

- (void)handleFilterChanged:(STCollectionViewDisplayModel *)model {
    
    if ([EAGLContext currentContext] != self.glContext) {
        [EAGLContext setCurrentContext:self.glContext];
    }
    
    self.currentSelectedFilterModel = model;
    
    self.bFilter = model.index > 0;
    
    if (self.bFilter) {
        self.filterStrengthView.hidden = NO;
    } else {
        self.filterStrengthView.hidden = YES;
    }
    
    // 切换滤镜
    if (_hFilter) {
        
        self.pauseOutput = YES;
        
        self.filterStrengthSlider.value = self.fFilterStrength;
        
        self.curFilterModelPath = model.strPath;
        [self refreshFilterCategoryState:model.modelType];
        st_result_t iRet = ST_OK;
        iRet = st_mobile_gl_filter_set_param(_hFilter, ST_GL_FILTER_STRENGTH, self.fFilterStrength);
        if (iRet != ST_OK) {
            STLog(@"st_mobile_gl_filter_set_param %d" , iRet);
        }
    }
    
    self.pauseOutput = NO;
}

- (void)handleObjectTrackChanged:(STCollectionViewDisplayModel *)model {
    
    //    if (self.collectionView.selectedModel || self.objectTrackCollectionView.selectedModel) {
    //        self.noneStickerImageView.highlighted = NO;
    //    } else {
    //        self.noneStickerImageView.highlighted = YES;
    //    }
    
    if (self.commonObjectContainerView.currentCommonObjectView) {
        [self.commonObjectContainerView.currentCommonObjectView removeFromSuperview];
    }
    _commonObjectViewSetted = NO;
    _commonObjectViewAdded = NO;
    
    if (model.isSelected) {
        UIImage *image = model.image;
        [self.commonObjectContainerView addCommonObjectViewWithImage:image];
        self.commonObjectContainerView.currentCommonObjectView.onFirst = YES;
        self.bTracker = YES;
    }
}

- (void)handleStickerChanged:(EffectsCollectionViewCellModel *)model {
    
    self.prepareModel = model;
    
    if (STEffectsTypeStickerMy == model.iEffetsType) {
        
        [self setMaterialModel:model];
        
        return;
    }
    
    
    STWeakSelf;
    
    BOOL isMaterialExist = [[SenseArMaterialService sharedInstance] isMaterialDownloaded:model.material];
    BOOL isDirectory = YES;
    BOOL isFileAvalible = [[NSFileManager defaultManager] fileExistsAtPath:model.material.strMaterialPath
                                                               isDirectory:&isDirectory];
    
    ///TODO: 双页面共享 service  会造成 model & material 状态更新错误
    if (isMaterialExist && (isDirectory || !isFileAvalible)) {
        
        model.state = NotDownloaded;
        model.strMaterialPath = nil;
        isMaterialExist = NO;
    }
    
    if (model && model.material && !isMaterialExist) {
        
        model.state = IsDownloading;
        [self.effectsList reloadData];
        
        [[SenseArMaterialService sharedInstance]
         downloadMaterial:model.material
         onSuccess:^(SenseArMaterial *material)
         {
             
             model.state = Downloaded;
             model.strMaterialPath = material.strMaterialPath;
             
             if (model == weakSelf.prepareModel) {
                 
                 [weakSelf setMaterialModel:model];
             }else{
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     [weakSelf.effectsList reloadData];
                 });
             }
         }
         onFailure:^(SenseArMaterial *material, int iErrorCode, NSString *strMessage) {
             
             model.state = NotDownloaded;
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 [weakSelf.effectsList reloadData];
             });
         }
         onProgress:nil];
    }else{
        
        [self setMaterialModel:model];
    }
}

- (void)setMaterialModel:(EffectsCollectionViewCellModel *)targetModel
{
    self.pauseOutput = YES;
    self.bSticker = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.triggerView.hidden = YES;
    });
    
    const char *stickerPath = [targetModel.strMaterialPath UTF8String];
    
    if (!targetModel || IsSelected == targetModel.state) {
        
        stickerPath = NULL;
    }
    
    for (NSArray *arrModels in [self.effectsDataSource allValues]) {
        
        for (EffectsCollectionViewCellModel *model in arrModels) {
            
            if (model == targetModel) {
                
                if (IsSelected == model.state) {
                    
                    model.state = Downloaded;
                }else{
                    
                    model.state = IsSelected;
                }
            }else{
                
                if (IsSelected == model.state) {
                    
                    model.state = Downloaded;
                }
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.effectsList reloadData];
    });
    
    if (self.isNullSticker) {
        self.isNullSticker = NO;
    }
    
    // 获取触发动作类型
    unsigned long long iAction = 0;
    
    st_result_t iRet = ST_OK;
    iRet = st_mobile_sticker_change_package(_hSticker, stickerPath, NULL);
    
    if (iRet != ST_OK && iRet != ST_E_PACKAGE_EXIST_IN_MEMORY) {
        
        STLog(@"st_mobile_sticker_change_package error %d" , iRet);
    } else {
        
        // 需要在 st_mobile_sticker_change_package 之后调用才可以获取新素材包的 trigger action .
        iRet = st_mobile_sticker_get_trigger_action(_hSticker, &iAction);
        
        if (ST_OK != iRet) {
            
            STLog(@"st_mobile_sticker_get_trigger_action error %d" , iRet);
            
            return;
        }
        
        NSString *triggerContent = @"";
        UIImage *image = nil;
        
        if (0 != iAction) {//有 trigger信息
            
            if (CHECK_FLAG(iAction, ST_MOBILE_BROW_JUMP)) {
                triggerContent = [NSString stringWithFormat:@"%@请挑挑眉~", triggerContent];
                image = [UIImage imageNamed:@"head_brow_jump"];
            }
            if (CHECK_FLAG(iAction, ST_MOBILE_EYE_BLINK)) {
                triggerContent = [NSString stringWithFormat:@"%@请眨眨眼~", triggerContent];
                image = [UIImage imageNamed:@"eye_blink"];
            }
            if (CHECK_FLAG(iAction, ST_MOBILE_HEAD_YAW)) {
                triggerContent = [NSString stringWithFormat:@"%@请摇摇头~", triggerContent];
                image = [UIImage imageNamed:@"head_yaw"];
            }
            if (CHECK_FLAG(iAction, ST_MOBILE_HEAD_PITCH)) {
                triggerContent = [NSString stringWithFormat:@"%@请点点头~", triggerContent];
                image = [UIImage imageNamed:@"head_pitch"];
            }
            if (CHECK_FLAG(iAction, ST_MOBILE_MOUTH_AH)) {
                triggerContent = [NSString stringWithFormat:@"%@请张张嘴~", triggerContent];
                image = [UIImage imageNamed:@"mouth_ah"];
            }
            if (CHECK_FLAG(iAction, ST_MOBILE_HAND_GOOD)) {
                triggerContent = [NSString stringWithFormat:@"%@请比个赞~", triggerContent];
                image = [UIImage imageNamed:@"hand_good"];
            }
            if (CHECK_FLAG(iAction, ST_MOBILE_HAND_PALM)) {
                triggerContent = [NSString stringWithFormat:@"%@请伸手掌~", triggerContent];
                image = [UIImage imageNamed:@"hand_palm"];
            }
            if (CHECK_FLAG(iAction, ST_MOBILE_HAND_LOVE)) {
                triggerContent = [NSString stringWithFormat:@"%@请双手比心~", triggerContent];
                image = [UIImage imageNamed:@"hand_love"];
            }
            if (CHECK_FLAG(iAction, ST_MOBILE_HAND_HOLDUP)) {
                triggerContent = [NSString stringWithFormat:@"%@请托个手~", triggerContent];
                image = [UIImage imageNamed:@"hand_holdup"];
            }
            if (CHECK_FLAG(iAction, ST_MOBILE_HAND_CONGRATULATE)) {
                triggerContent = [NSString stringWithFormat:@"%@请抱个拳~", triggerContent];
                image = [UIImage imageNamed:@"hand_congratulate"];
            }
            if (CHECK_FLAG(iAction, ST_MOBILE_HAND_FINGER_HEART)) {
                triggerContent = [NSString stringWithFormat:@"%@请单手比心~", triggerContent];
                image = [UIImage imageNamed:@"hand_finger_heart"];
            }
            if (CHECK_FLAG(iAction, ST_MOBILE_HAND_FINGER_INDEX)) {
                triggerContent = [NSString stringWithFormat:@"%@请伸出食指~", triggerContent];
                image = [UIImage imageNamed:@"hand_finger"];
            }
            if (CHECK_FLAG(iAction, ST_MOBILE_HAND_OK)) {
                triggerContent = [NSString stringWithFormat:@"%@请亮出OK手势~", triggerContent];
                image = [UIImage imageNamed:@"hand_ok"];
            }
            if (CHECK_FLAG(iAction, ST_MOBILE_HAND_SCISSOR)) {
                triggerContent = [NSString stringWithFormat:@"%@请比个剪刀手~", triggerContent];
                image = [UIImage imageNamed:@"hand_victory"];
            }
            if (CHECK_FLAG(iAction, ST_MOBILE_HAND_PISTOL)) {
                triggerContent = [NSString stringWithFormat:@"%@请比个手枪~", triggerContent];
                image = [UIImage imageNamed:@"hand_gun"];
            }
            
            if (CHECK_FLAG(iAction, ST_MOBILE_HAND_666)) {
                triggerContent = [NSString stringWithFormat:@"%@请亮出666手势~", triggerContent];
                image = [UIImage imageNamed:@"666_selected"];
            }
            if (CHECK_FLAG(iAction, ST_MOBILE_HAND_BLESS)) {
                triggerContent = [NSString stringWithFormat:@"%@请双手合十~", triggerContent];
                image = [UIImage imageNamed:@"bless_selected"];
            }
            if (CHECK_FLAG(iAction, ST_MOBILE_HAND_ILOVEYOU)) {
                triggerContent = [NSString stringWithFormat:@"%@请亮出我爱你手势~", triggerContent];
                image = [UIImage imageNamed:@"love_selected"];
            }
            if (CHECK_FLAG(iAction, ST_MOBILE_HAND_FIST)) {
                triggerContent = [NSString stringWithFormat:@"%@请举起拳头~", triggerContent];
                image = [UIImage imageNamed:@"fist_selected"];
            }
            if (CHECK_FLAG(iAction, ST_MOBILE_FACE_LIPS_POUTED)) {
                triggerContent = [NSString stringWithFormat:@"%@请嘟嘴~", triggerContent];
                image = [UIImage imageNamed:@"FACE_LIPS_POUTED"];
            }
            if (CHECK_FLAG(iAction, ST_MOBILE_FACE_LIPS_UPWARD)) {
                triggerContent = [NSString stringWithFormat:@"%@请笑一笑~", triggerContent];
                image = [UIImage imageNamed:@"FACE_LIPS_UPWARD"];
            }
            [self.triggerView showTriggerViewWithContent:triggerContent image:image];
        }
        //猫脸config
        unsigned long long animalConfig = 0;
        iRet = st_mobile_sticker_get_animal_detect_config(_hSticker, &animalConfig);
        if (iRet == ST_OK && animalConfig == ST_MOBILE_CAT_DETECT) {
            _needDetectAnimal = YES;
        } else {
            _needDetectAnimal = NO;
        }
        
    }
    
    self.stickerConf = iAction;
    self.pauseOutput = NO;
}




#pragma mark - btn click events

- (void)onBtnSnap {
    self.needSnap = YES;
}

- (void)onBtnChangeCamera {
    
    [self resetCommonObjectViewPosition];
    
    if (self.stCamera.devicePosition == AVCaptureDevicePositionFront) {
        self.stCamera.devicePosition = AVCaptureDevicePositionBack;
        
    } else {
        self.stCamera.devicePosition = AVCaptureDevicePositionFront;
    }
}

- (void)onBtnSetting {
    
    if (!_settingViewIsShow) {
        
        [self hideContainerView];
        [self hideBeautyContainerView];
        [self settingViewAppear];
        
    } else {
        [self hideSettingView];
    }
}

- (void)onBtnAlbum {
    
    [self.motionManager stopAccelerometerUpdates];
    [self.motionManager stopDeviceMotionUpdates];
    
    [self cancelStickerAndObjectTrack];
    
    self.pauseOutput = YES;
    [self.stCamera stopRunning];
    
    dispatch_async(self.stCamera.bufferQueue, ^{
        [self releaseResources];
    });
    
    self.stCamera = nil;
    
    [self hideSettingView];
    [self hideContainerView];
    [self hideBeautyContainerView];
    
    PhotoSelectVC *photoVC = [[PhotoSelectVC alloc] init];
    photoVC.delegate = self;
    
    [photoVC setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    photoVC.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self presentViewController:photoVC animated:YES completion:nil];
}

- (void)onAttributeSwitch:(UISwitch *)sender {
    self.bAttribute = sender.isOn;
}

- (void)clickBottomViewButton:(STViewButton *)senderView {
    
    switch (senderView.tag) {
            
        case STViewTagSpecialEffectsBtn:
            
            self.beautyBtn.userInteractionEnabled = NO;
            
            if (!self.specialEffectsContainerViewIsShow) {
                
                
                [self hideSettingView];
                [self hideBeautyContainerView];
                [self containerViewAppear];
                
            } else {
                
                [self hideContainerView];
            }
            
            self.beautyBtn.userInteractionEnabled = YES;
            
            break;
            
        case STViewTagBeautyBtn:
            
            self.specialEffectsBtn.userInteractionEnabled = NO;
            
            if (!self.beautyContainerViewIsShow) {
                
                
                [self hideSettingView];
                [self hideContainerView];
                [self beautyContainerViewAppear];
                
            } else {
                
                [self hideBeautyContainerView];
            }
            
            self.specialEffectsBtn.userInteractionEnabled = YES;
            
            break;
    }
    
}

- (void)onBtnCompareTouchDown:(UIButton *)sender {
    [sender setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.4] forState:UIControlStateNormal];
    self.isComparing = YES;
    self.snapBtn.userInteractionEnabled = NO;
}

- (void)onBtnCompareTouchUpInside:(UIButton *)sender {
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.isComparing = NO;
    self.snapBtn.userInteractionEnabled = YES;
}

- (void)changeResolution:(UIButton *)sender {
    
    self.pauseOutput = YES;
    
    if (sender == _btn640x480) {
        
        if (![self.stCamera.sessionPreset isEqualToString:AVCaptureSessionPreset640x480]) {
            
            [self resetCommonObjectViewPosition];
            
            [self.stCamera setSessionPreset:AVCaptureSessionPreset640x480];
            
            self.currentSessionPreset = AVCaptureSessionPreset640x480;
            
            self.btn640x480.backgroundColor = [UIColor whiteColor];
            [self.btn640x480 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            self.btn640x480.layer.borderWidth = 1;
            self.btn640x480.layer.borderColor = [UIColor whiteColor].CGColor;
            self.btn640x480BorderLayer.hidden = YES;
            
            self.btn1280x720.backgroundColor = [UIColor clearColor];
            [self.btn1280x720 setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
            self.btn1280x720.layer.borderWidth = 0;
            self.btn1280x720BorderLayer.hidden = NO;
            
            self.btn1920x1080.backgroundColor = [UIColor clearColor];
            [self.btn1920x1080 setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
            self.btn1920x1080.layer.borderWidth = 0;
            self.btn1920x1080BorderLayer.hidden = NO;
            
            self.btn1280x720.enabled = self.btn1920x1080.enabled = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.btn1280x720.enabled = self.btn1920x1080.enabled = YES;
            });
        }
    }
    else if (sender == _btn1280x720) {
        
        if (![self.stCamera.sessionPreset isEqualToString:AVCaptureSessionPreset1280x720]) {
            
            [self resetCommonObjectViewPosition];
            
            [self.stCamera setSessionPreset:AVCaptureSessionPreset1280x720];
            
            self.currentSessionPreset = AVCaptureSessionPreset1280x720;
            
            self.btn1280x720.backgroundColor = [UIColor whiteColor];
            [self.btn1280x720 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            self.btn1280x720.layer.borderWidth = 1;
            self.btn1280x720.layer.borderColor = [UIColor whiteColor].CGColor;
            self.btn1280x720BorderLayer.hidden = YES;
            
            self.btn640x480.backgroundColor = [UIColor clearColor];
            [self.btn640x480 setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
            self.btn640x480.layer.borderWidth = 0;
            self.btn640x480BorderLayer.hidden = NO;
            
            self.btn1920x1080.backgroundColor = [UIColor clearColor];
            [self.btn1920x1080 setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
            self.btn1920x1080.layer.borderWidth = 0;
            self.btn1920x1080BorderLayer.hidden = NO;
            
            self.btn640x480.enabled = self.btn1920x1080.enabled = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.btn640x480.enabled = self.btn1920x1080.enabled = YES;
            });
        }
    }
    else if (sender == _btn1920x1080){
        if (![self.stCamera.sessionPreset isEqualToString:AVCaptureSessionPresetHigh]) {
            
            [self resetCommonObjectViewPosition];
            
            [self.stCamera setSessionPreset:AVCaptureSessionPresetHigh];
            
            self.currentSessionPreset = AVCaptureSessionPresetHigh;
            
            self.btn1920x1080.backgroundColor = [UIColor whiteColor];
            [self.btn1920x1080 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            self.btn1920x1080.layer.borderWidth = 1;
            self.btn1920x1080.layer.borderColor = [UIColor whiteColor].CGColor;
            self.btn1920x1080BorderLayer.hidden = YES;
            
            self.btn640x480.backgroundColor = [UIColor clearColor];
            [self.btn640x480 setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
            self.btn640x480.layer.borderWidth = 0;
            self.btn640x480BorderLayer.hidden = NO;
            
            self.btn1280x720.backgroundColor = [UIColor clearColor];
            [self.btn1280x720 setTitleColor:UIColorFromRGB(0x999999) forState:UIControlStateNormal];
            self.btn1280x720.layer.borderWidth = 0;
            self.btn1280x720BorderLayer.hidden = NO;
            
            self.btn640x480.enabled = self.btn1280x720.enabled = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.btn640x480.enabled = self.btn1280x720.enabled = YES;
            });
        }
    }
    
    [self changePreviewSize];
    
    self.pauseOutput = NO;
}


#pragma mark - get models

- (NSArray *)getStickerModelsByType:(STEffectsType)type {
    
    NSArray *stickerZipPaths = [STParamUtil getStickerPathsByType:type];
    
    NSMutableArray *arrModels = [NSMutableArray array];
    
    for (int i = 0; i < stickerZipPaths.count; i ++) {
        
        STCollectionViewDisplayModel *model = [[STCollectionViewDisplayModel alloc] init];
        model.strPath = stickerZipPaths[i];
        
        UIImage *thumbImage = [UIImage imageWithContentsOfFile:[[model.strPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"]];
        model.image = thumbImage ? thumbImage : [UIImage imageNamed:@"none.png"];
        model.strName = @"";
        model.index = i;
        model.isSelected = NO;
        model.modelType = type;
        
        [arrModels addObject:model];
    }
    return [arrModels copy];
}

- (NSArray *)getFilterModelsByType:(STEffectsType)type {
    
    NSArray *filterModelPath = [STParamUtil getFilterModelPathsByType:type];
    
    NSMutableArray *arrModels = [NSMutableArray array];
    
    NSString *natureImageName = @"";
    switch (type) {
        case STEffectsTypeFilterDeliciousFood:
            natureImageName = @"nature_food";
            break;
            
        case STEffectsTypeFilterStillLife:
            natureImageName = @"nature_stilllife";
            break;
            
        case STEffectsTypeFilterScenery:
            natureImageName = @"nature_scenery";
            break;
            
        case STEffectsTypeFilterPortrait:
            natureImageName = @"nature_portrait";
            break;
            
        default:
            break;
    }
    
    STCollectionViewDisplayModel *model1 = [[STCollectionViewDisplayModel alloc] init];
    model1.strPath = NULL;
    model1.strName = @"original";
    model1.image = [UIImage imageNamed:natureImageName];
    model1.index = 0;
    model1.isSelected = NO;
    model1.modelType = STEffectsTypeNone;
    [arrModels addObject:model1];
    
    for (int i = 1; i < filterModelPath.count + 1; ++i) {
        
        STCollectionViewDisplayModel *model = [[STCollectionViewDisplayModel alloc] init];
        model.strPath = filterModelPath[i - 1];
        model.strName = [[model.strPath.lastPathComponent stringByDeletingPathExtension] stringByReplacingOccurrencesOfString:@"filter_style_" withString:@""];
        
        UIImage *thumbImage = [UIImage imageWithContentsOfFile:[[model.strPath stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"]];
        
        model.image = thumbImage ?: [UIImage imageNamed:@"none"];
        model.index = i;
        model.isSelected = NO;
        model.modelType = type;
        
        [arrModels addObject:model];
    }
    return [arrModels copy];
}

- (NSArray *)getObjectTrackModels {
    
    NSMutableArray *arrModels = [NSMutableArray array];
    
    NSArray *arrImageNames = @[@"object_track_happy", @"object_track_hi", @"object_track_love", @"object_track_star", @"object_track_sticker", @"object_track_sun"];
    
    for (int i = 0; i < arrImageNames.count; ++i) {
        
        STCollectionViewDisplayModel *model = [[STCollectionViewDisplayModel alloc] init];
        model.strPath = NULL;
        model.strName = @"";
        model.index = i;
        model.isSelected = NO;
        model.image = [UIImage imageNamed:arrImageNames[i]];
        model.modelType = STEffectsTypeObjectTrack;
        
        [arrModels addObject:model];
    }
    
    return [arrModels copy];
}

#pragma mark - help function

- (BOOL)isIphoneX {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([platform isEqualToString:@"iPhone10,3"] || [platform hasPrefix:@"iPhone11"]) {
        return YES;
    }
    return NO;
}

- (BOOL)isNotchScreen {
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return NO;
    }
    CGSize size = [UIScreen mainScreen].bounds.size;
    NSInteger notchValue = size.width / size.height * 100;
    if (216 == notchValue || 46 == notchValue) {
        return YES;
    }
    return NO;
}

- (CGFloat)layoutWidthWithValue:(CGFloat)value {
    
    return (value / 750) * SCREEN_WIDTH;
}

- (CGFloat)layoutHeightWithValue:(CGFloat)value {
    
    return (value / 1334) * SCREEN_HEIGHT;
}

#pragma mark - lazy load array

- (NSArray *)arrObjectTrackers {
    if (!_arrObjectTrackers) {
        _arrObjectTrackers = [self getObjectTrackModels];
    }
    return _arrObjectTrackers;
}

- (NSMutableArray *)arrBeautyViews {
    if (!_arrBeautyViews) {
        _arrBeautyViews = [NSMutableArray array];
    }
    return _arrBeautyViews;
}

- (NSMutableArray *)arrFilterCategoryViews {
    
    if (!_arrFilterCategoryViews) {
        
        _arrFilterCategoryViews = [NSMutableArray array];
    }
    return _arrFilterCategoryViews;
}

#pragma mark - touch events

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self.view];
    
    if (self.specialEffectsContainerViewIsShow) {
        
        if (!CGRectContainsPoint(CGRectMake(0, SCREEN_HEIGHT - 230, SCREEN_WIDTH, 230), point)) {
            
            [self hideContainerView];
        }
    }
    
    if (self.beautyContainerViewIsShow) {
        
        if (!CGRectContainsPoint(CGRectMake(0, SCREEN_HEIGHT - 230, SCREEN_WIDTH, 230), point)) {
            
            [self hideBeautyContainerView];
        }
    }
    
    if (self.settingViewIsShow) {
        
        if (!CGRectContainsPoint(CGRectMake(0, SCREEN_HEIGHT - 230, SCREEN_WIDTH, 230), point)) {
            
            [self hideSettingView];
        }
    }
    
    if (self.bmpColView) {
        
        [self.bmpColView backToMenu];
    }
}

#pragma mark - animations

- (void)hideContainerView {
    
    self.specialEffectsBtn.hidden = NO;
    self.beautyBtn.hidden = NO;
    
    [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.specialEffectsContainerView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 180);
        self.btnCompare.frame = CGRectMake(SCREEN_WIDTH - 80, SCREEN_HEIGHT - 150, 70, 35);
        
    } completion:^(BOOL finished) {
        self.specialEffectsContainerViewIsShow = NO;
    }];
    
    self.specialEffectsBtn.highlighted = NO;
}

- (void)containerViewAppear {
    
    self.filterStrengthView.hidden = YES;
    
    self.specialEffectsBtn.hidden = YES;
    self.beautyBtn.hidden = YES;
    
    [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.specialEffectsContainerView.frame = CGRectMake(0, SCREEN_HEIGHT - 230, SCREEN_WIDTH, 180);
        self.btnCompare.frame = CGRectMake(SCREEN_WIDTH - 80, SCREEN_HEIGHT - 250 - 35.5, 70, 35);
    } completion:^(BOOL finished) {
        self.specialEffectsContainerViewIsShow = YES;
    }];
    self.specialEffectsBtn.highlighted = YES;
}

- (void)hideBeautyContainerView {
    
    self.filterStrengthView.hidden = YES;
    self.beautySlider.hidden = YES;
    
    self.beautyBtn.hidden = NO;
    self.specialEffectsBtn.hidden = NO;
    self.resetBtn.hidden = YES;
    
    self.bmpStrenghView.hidden = YES;
    
    [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.beautyContainerView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 250);
        self.btnCompare.frame = CGRectMake(SCREEN_WIDTH - 80, SCREEN_HEIGHT - 150, 70, 35);
        
    } completion:^(BOOL finished) {
        self.beautyContainerViewIsShow = NO;
    }];
    
    self.beautyBtn.highlighted = NO;
}

- (void)beautyContainerViewAppear {
    
    if (self.curEffectBeautyType == self.beautyCollectionView.selectedModel.modelType) {
        self.beautySlider.hidden = NO;
    }
    
    self.beautyBtn.hidden = YES;
    self.specialEffectsBtn.hidden = YES;
    self.resetBtn.hidden = NO;
    
    self.filterCategoryView.center = CGPointMake(SCREEN_WIDTH / 2, self.filterCategoryView.center.y);
    self.filterView.center = CGPointMake(SCREEN_WIDTH * 3 / 2, self.filterView.center.y);
    
    [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.beautyContainerView.frame = CGRectMake(0, SCREEN_HEIGHT - 260, SCREEN_WIDTH, 260);
        self.btnCompare.frame = CGRectMake(SCREEN_WIDTH - 80, SCREEN_HEIGHT - 260 - 35.5 - 40, 70, 35);
    } completion:^(BOOL finished) {
        self.beautyContainerViewIsShow = YES;
    }];
    self.beautyBtn.highlighted = YES;
}

- (void)settingViewAppear {
    
    [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.settingView.frame = CGRectMake(0, SCREEN_HEIGHT - 230, SCREEN_WIDTH, 230);
        self.btnCompare.frame = CGRectMake(SCREEN_WIDTH - 80, SCREEN_HEIGHT - 350 - 35.5, 70, 35);
    } completion:^(BOOL finished) {
        self.settingViewIsShow = YES;
    }];
}

- (void)hideSettingView {
    
    [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.settingView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 230);
        self.btnCompare.frame = CGRectMake(SCREEN_WIDTH - 80, SCREEN_HEIGHT - 150, 70, 35);
        
    } completion:^(BOOL finished) {
        self.settingViewIsShow = NO;
    }];
}

- (void)hideBeautyViewExcept:(UIView *)view {
    
    for (UIView *beautyView in self.arrBeautyViews) {
        
        beautyView.hidden = !(view == beautyView);
    }
}

#pragma mark - STViewButtonDelegate

- (void)btnLongPressEnd {
    //    NSLog(@"stviewbtn long press ended");
    
    if (![self checkMediaStatus:AVMediaTypeVideo]) {
        return;
    }
    
    if (self.recording) {
        
        [self.timer stop];
        [self.timer reset];
        
        self.recording = NO;
        self.recordImageView.hidden = YES;
        
        self.recordTimeLabel.hidden = YES;
        
        self.filterStrengthView.hidden = self.filterStrengthViewHiddenState;
        self.specialEffectsBtn.hidden = NO;
        self.beautyBtn.hidden = NO;
        self.btnAlbum.hidden = NO;
        self.btnSetting.hidden = NO;
        self.btnChangeCamera.hidden = NO;
        self.btnCompare.hidden = NO;
        self.beautyContainerView.hidden = NO;
        self.specialEffectsContainerView.hidden = NO;
        self.settingView.hidden = NO;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self stopRecorder];
        });
    }
}

- (void)btnLongPressBegin {
    
    //    NSLog(@"stviewbtn long press begin");
    
    if (![self checkMediaStatus:AVMediaTypeVideo]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"没有相机权限无法录制视频" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    self.recordImageView.hidden = NO;
    
    self.recordTimeLabel.hidden = NO;
    
    self.filterStrengthViewHiddenState = self.filterStrengthView.isHidden;
    self.filterStrengthView.hidden = YES;
    self.specialEffectsBtn.hidden = YES;
    self.beautyBtn.hidden = YES;
    self.btnAlbum.hidden = YES;
    self.btnSetting.hidden = YES;
    self.btnChangeCamera.hidden = YES;
    self.btnCompare.hidden = YES;
    self.beautyContainerView.hidden = YES;
    self.specialEffectsContainerView.hidden = YES;
    self.settingView.hidden = YES;
    
    [self.timer start];
    
    @synchronized (self) {
        
        if (self.recordStatus != STWriterRecordingStatusIdle) {
            
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Already recording" userInfo:nil];
            return;
        }
        
        self.recordStatus = STWriterRecordingStatusStartingRecording;
        
        _callBackQueue = dispatch_queue_create("com.sensetime.recordercallback", DISPATCH_QUEUE_SERIAL);
        
        STMovieRecorder *recorder = [[STMovieRecorder alloc] initWithURL:self.recorderURL delegate:self callbackQueue:_callBackQueue];
        
        if ([self checkMediaStatus:AVMediaTypeVideo]) {
            
            [recorder addVideoTrackWithSourceFormatDescription:self.outputVideoFormatDescription transform:CGAffineTransformIdentity settings:self.stCamera.videoCompressingSettings];
        }
        
        if ([self checkMediaStatus:AVMediaTypeAudio]) {
            [recorder addAudioTrackWithSourceFormatDescription:self.outputAudioFormatDescription settings:self.audioManager.audioCompressingSettings];
        }
        
        _stRecoder = recorder;
        
        self.recording = YES;
        
        [_stRecoder prepareToRecord];
        
        self.recordStartTime = CFAbsoluteTimeGetCurrent();
        //    NSLog(@"st_effects_recored_time start: %f", self.recordStartTime);
        
    }
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

#pragma mark - STMovieRecorderDelegate

- (void)movieRecorder:(STMovieRecorder *)recorder didFailWithError:(NSError *)error {
    
    @synchronized (self) {
        
        self.stRecoder = nil;
        
        self.recordStatus = STWriterRecordingStatusIdle;
    }
    
    NSLog(@"movie recorder did fail with error: %@", error.localizedDescription);
}

- (void)movieRecorderDidFinishPreparing:(STMovieRecorder *)recorder {
    
    @synchronized(self) {
        if (_recordStatus != STWriterRecordingStatusStartingRecording) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Expected to be in StartingRecording state" userInfo:nil];
            return;
        }
        
        self.recordStatus = STWriterRecordingStatusRecording;
    }
}

- (void)movieRecorderDidFinishRecording:(STMovieRecorder *)recorder {
    
    @synchronized(self) {
        
        if (_recordStatus != STWriterRecordingStatusStoppingRecording) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Expected to be in StoppingRecording state" userInfo:nil];
            return;
        }
        
        self.recordStatus = STWriterRecordingStatusIdle;
    }
    
    _stRecoder = nil;
    
    self.recording = NO;
    
    double recordTime = CFAbsoluteTimeGetCurrent() - self.recordStartTime;
    //    NSLog(@"st_effects_recored_time end: %f", recordTime);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (recordTime < 2.0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"视频录制时间小于2s，请重新录制" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
            [alert show];
        } else {
            
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            
            [library writeVideoAtPathToSavedPhotosAlbum:_recorderURL completionBlock:^(NSURL *assetURL, NSError *error) {
                
                [[NSFileManager defaultManager] removeItemAtURL:_recorderURL error:NULL];
                
                self.lblSaveStatus.text = @"视频已存储到相册";
                [self showAnimationIfSaved:YES];
                
            }];
        }
    });
}

#pragma mark - sound
void load_sound(void* handle, void* sound, const char* sound_name, int length) {
    
    //    NSLog(@"STEffectsAudioPlayer load sound");
    
    if ([messageManager.delegate respondsToSelector:@selector(loadSound:name:)]) {
        
        NSData *soundData = [NSData dataWithBytes:sound length:length];
        NSString *strName = [NSString stringWithUTF8String:sound_name];
        
        [messageManager.delegate loadSound:soundData name:strName];
    }
}

void play_sound(void* handle, const char* sound_name, int loop) {
    
    //    NSLog(@"STEffectsAudioPlayer play sound");
    
    if ([messageManager.delegate respondsToSelector:@selector(playSound:loop:)]) {
        
        NSString *strName = [NSString stringWithUTF8String:sound_name];
        
        [messageManager.delegate playSound:strName loop:loop];
    }
}

void pause_sound(void *handle, const char *sound_name) {
    if ([messageManager.delegate respondsToSelector:@selector(pauseSound:)]) {
        NSString *strName = [NSString stringWithUTF8String:sound_name];
        [messageManager.delegate pauseSound:strName];
    }
}

void resume_sound(void *handle, const char *sound_name) {
    if ([messageManager.delegate respondsToSelector:@selector(resumeSound:)]) {
        NSString *strName = [NSString stringWithUTF8String:sound_name];
        [messageManager.delegate resumeSound:strName];
    }
}

void stop_sound(void* handle, const char* sound_name) {
    
    //    NSLog(@"STEffectsAudioPlayer stop sound");
    if ([messageManager.delegate respondsToSelector:@selector(stopSound:)]) {
        NSString *strName = [NSString stringWithUTF8String:sound_name];
        [messageManager.delegate stopSound:strName];
    }
}

void unload_sound(void *handle, const char *sound_name) {
    if ([messageManager.delegate respondsToSelector:@selector(unloadSound:)]) {
        NSString *strName = [NSString stringWithUTF8String:sound_name];
        [messageManager.delegate unloadSound:strName];
    }
}

void package_event(void* handle, const char* package_name, int packageID, int event, int displayed_frame)
{
    if ([messageManager.delegate respondsToSelector:@selector(packageEvent:packageID:event:displayedFrame:)]) {
        NSString *packageName = [NSString stringWithUTF8String:package_name];
        [messageManager.delegate packageEvent:packageName
                                    packageID:packageID
                                        event:event
                               displayedFrame:displayed_frame];
    }
}

#pragma mark - STEffectsMessageManagerDelegate

- (void)loadSound:(NSData *)soundData name:(NSString *)strName {
    
    if ([self.audioPlayer loadSound:soundData name:strName]) {
        NSLog(@"STEffectsAudioPlayer load %@ successfully", strName);
    }
}

- (void)playSound:(NSString *)strName loop:(int)iLoop {
    
    if ([self.audioPlayer playSound:strName loop:iLoop]) {
        NSLog(@"STEffectsAudioPlayer play %@ successfully", strName);
    }
}

- (void)pauseSound:(NSString *)strName {
    [self.audioPlayer pauseSound:strName];
}

- (void)resumeSound:(NSString *)strName {
    [self.audioPlayer resumeSound:strName];
}

- (void)stopSound:(NSString *)strName {
    
    [self.audioPlayer stopSound:strName];
}

- (void)unloadSound:(NSString *)strName {
    [self.audioPlayer unloadSound:strName];
}

- (void)packageEvent:(NSString *)packageName
           packageID:(int)packageID
               event:(int)event
      displayedFrame:(int)displayedFrame
{
    NSLog(@"packageName %@, packageID %d, event %d, displayedFrame %d", packageName, packageID, event, displayedFrame);
}

#pragma mark - STEffectsAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(STEffectsAudioPlayer *)player successfully:(BOOL)flag name:(NSString *)strName {
    
    if (_hSticker) {
        st_result_t iRet = ST_OK;
        iRet = st_mobile_sticker_set_param_str(_hSticker, -1, ST_STICKER_PARAM_SOUND_COMPLETED_STR, strName.UTF8String);
        if (iRet != ST_OK) {
            NSLog(@"st mobile set sound complete str failed: %d", iRet);
        }
    }
}

#pragma mark - STEffectsTimerDelegate

- (void)effectsTimer:(STEffectsTimer *)timer currentRecordHour:(int)hours minutes:(int)minutes seconds:(int)seconds {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.recordTimeLabel.text = [NSString stringWithFormat:@"• %02d:%02d:%02d", hours, minutes, seconds];
    });
}

#pragma mark - 

- (void)stopRecorder {
    
    @synchronized (self) {
        
        if (self.recordStatus != STWriterRecordingStatusRecording) {
            return;
        }
        
        self.recordStatus = STWriterRecordingStatusStoppingRecording;
        
        [_stRecoder finishRecording];
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

- (void)resetSettings {
    
    self.noneStickerImageView.highlighted = YES;
    self.lblFilterStrength.text = @"65";
    self.filterStrengthSlider.value = 0.65;
    self.fFilterStrength = 0.65;
    
    self.currentSelectedFilterModel.isSelected = NO;
    [self refreshFilterCategoryState:STEffectsTypeNone];
    
    self.fSmoothStrength = 0.74;
    self.fReddenStrength = 0.36;
    self.fWhitenStrength = 0.02;
    self.fDehighlightStrength = 0.0;
    
    self.fEnlargeEyeStrength = 0.13;
    self.fShrinkFaceStrength = 0.11;
    self.fShrinkJawStrength = 0.10;
    self.fThinFaceShapeStrength = 0.0;
    
    self.fChinStrength = 0.0;
    self.fHairLineStrength = 0.0;
    self.fNarrowNoseStrength = 0.0;
    self.fLongNoseStrength = 0.0;
    self.fMouthStrength = 0.0;
    self.fPhiltrumStrength = 0.0;
    
    self.fEyeDistanceStrength = 0.0;
    self.fEyeAngleStrength = 0.0;
    self.fOpenCanthusStrength = 0.0;
    self.fProfileRhinoplastyStrength = 0.0;
    self.fBrightEyeStrength = 0.0;
    self.fRemoveDarkCirclesStrength = 0.0;
    self.fRemoveNasolabialFoldsStrength = 0.0;
    self.fWhiteTeethStrength = 0.0;
    self.fAppleMusleStrength = 0.0;
    
    self.fContrastStrength = 0.0;
    self.fSaturationStrength = 0.0;
    
    self.baseBeautyModels[0].beautyValue = 2;
    self.baseBeautyModels[0].selected = NO;
    self.baseBeautyModels[1].beautyValue = 36;
    self.baseBeautyModels[1].selected = NO;
    self.baseBeautyModels[2].beautyValue = 74;
    self.baseBeautyModels[2].selected = NO;
    self.baseBeautyModels[3].beautyValue = 0;
    self.baseBeautyModels[3].selected = NO;
    
    self.microSurgeryModels[0].beautyValue = 0;
    self.microSurgeryModels[0].selected = NO;
    self.microSurgeryModels[1].beautyValue = 0;
    self.microSurgeryModels[1].selected = NO;
    self.microSurgeryModels[2].beautyValue = 0;
    self.microSurgeryModels[2].selected = NO;
    self.microSurgeryModels[3].beautyValue = 0;
    self.microSurgeryModels[3].selected = NO;
    self.microSurgeryModels[4].beautyValue = 0;
    self.microSurgeryModels[4].selected = NO;
    self.microSurgeryModels[5].beautyValue = 0;
    self.microSurgeryModels[5].selected = NO;
    self.microSurgeryModels[6].beautyValue = 0;
    self.microSurgeryModels[6].selected = NO;
    self.microSurgeryModels[7].beautyValue = 0;
    self.microSurgeryModels[7].selected = NO;
    self.microSurgeryModels[8].beautyValue = 0;
    self.microSurgeryModels[8].selected = NO;
    self.microSurgeryModels[9].beautyValue = 0;
    self.microSurgeryModels[9].selected = NO;
    self.microSurgeryModels[10].beautyValue = 0;
    self.microSurgeryModels[10].selected = NO;
    self.microSurgeryModels[11].beautyValue = 0;
    self.microSurgeryModels[11].selected = NO;
    self.microSurgeryModels[12].beautyValue = 0;
    self.microSurgeryModels[12].selected = NO;
    self.microSurgeryModels[13].beautyValue = 0;
    self.microSurgeryModels[13].selected = NO;
    self.microSurgeryModels[14].beautyValue = 0;
    self.microSurgeryModels[14].selected = NO;
    self.microSurgeryModels[15].beautyValue = 0;
    self.microSurgeryModels[15].selected = NO;
    
    self.beautyShapeModels[0].beautyValue = 11;
    self.beautyShapeModels[0].selected = NO;
    self.beautyShapeModels[1].beautyValue = 13;
    self.beautyShapeModels[1].selected = NO;
    self.beautyShapeModels[2].beautyValue = 10;
    self.beautyShapeModels[2].selected = NO;
    
    self.adjustModels[0].beautyValue = 0;
    self.adjustModels[0].selected = NO;
    self.adjustModels[1].beautyValue = 0;
    self.adjustModels[1].selected = NO;
    
    self.beautyCollectionView.selectedModel = nil;
    [self.beautyCollectionView reloadData];
    
    self.preFilterModelPath = nil;
    self.curFilterModelPath = nil;
}

- (BOOL)checkMediaStatus:(NSString *)mediaType {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    
    BOOL res;
    
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined:
        case AVAuthorizationStatusDenied:
        case AVAuthorizationStatusRestricted:
            res = NO;
            break;
        case AVAuthorizationStatusAuthorized:
            res = YES;
            break;
    }
    return res;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

#pragma mark -

- (UIImage *)rgbaBufferConvertToImage:(const unsigned char *)buffer width:(int)iWidth height:(int)iHeight {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, buffer, iWidth * iHeight * 4, NULL);
    CGImageRef cgImage = CGImageCreate(iWidth, iHeight, 8, 32, 4 * iWidth, colorSpace, kCGBitmapByteOrderDefault, dataProvider, NULL, NO, kCGRenderingIntentDefault);
    UIImage *finalImage = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    CGDataProviderRelease(dataProvider);
    CGColorSpaceRelease(colorSpace);
    return finalImage;
}

- (NSUInteger)getBabyPinkFilterIndex {
    
    __block NSUInteger index = 0;
    
    [_filterView.filterCollectionView.arrPortraitFilterModels enumerateObjectsUsingBlock:^(STCollectionViewDisplayModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([obj.strName isEqualToString:@"babypink"]) {
            index = idx;
            *stop = YES;
        }
    }];
    
    return index;
}

void copyCatFace(st_mobile_animal_face_t *src, int faceCount, st_mobile_animal_face_t *dst) {
    memcpy(dst, src, sizeof(st_mobile_animal_face_t) * faceCount);
    for (int i = 0; i < faceCount; ++i) {
        
        size_t key_points_size = sizeof(st_pointf_t) * src[i].key_points_count;
        st_pointf_t *p_key_points = malloc(key_points_size);
        memset(p_key_points, 0, key_points_size);
        memcpy(p_key_points, src[i].p_key_points, key_points_size);
        
        dst[i].p_key_points = p_key_points;
    }
}

void freeCatFace(st_mobile_animal_face_t *src, int faceCount) {
    if (faceCount > 0) {
        for (int i = 0; i < faceCount; ++i) {
            if (src[i].p_key_points != NULL) {
                free(src[i].p_key_points);
                src[i].p_key_points = NULL;
            }
        }
        free(src);
        src = NULL;
    }
}

void copyHumanAction(st_mobile_human_action_t *src , st_mobile_human_action_t *dst) {
    
    memcpy(dst, src, sizeof(st_mobile_human_action_t));
    
    // copy faces
    if ((*src).face_count > 0) {
        
        size_t faces_size = sizeof(st_mobile_face_t) * (*src).face_count;
        st_mobile_face_t *p_faces = malloc(faces_size);
        memset(p_faces, 0, faces_size);
        memcpy(p_faces, (*src).p_faces, faces_size);
        (*dst).p_faces = p_faces;
        
        for (int i = 0; i < (*src).face_count; i ++) {
            
            st_mobile_face_t face = (*src).p_faces[i];
            
            // p_extra_face_points
            if (face.extra_face_points_count > 0 && face.p_extra_face_points != NULL) {
                
                size_t extra_face_points_size = sizeof(st_pointf_t) * face.extra_face_points_count;
                st_pointf_t *p_extra_face_points = malloc(extra_face_points_size);
                memset(p_extra_face_points, 0, extra_face_points_size);
                memcpy(p_extra_face_points, face.p_extra_face_points, extra_face_points_size);
                (*dst).p_faces[i].p_extra_face_points = p_extra_face_points;
            }
            
            // p_tongue_points & p_tongue_points_score
            if (   face.tongue_points_count > 0
                && face.p_tongue_points != NULL
                && face.p_tongue_points_score != NULL) {
                
                size_t tongue_points_size = sizeof(st_pointf_t) * face.tongue_points_count;
                st_pointf_t *p_tongue_points = malloc(tongue_points_size);
                memset(p_tongue_points, 0, tongue_points_size);
                memcpy(p_tongue_points, face.p_tongue_points, tongue_points_size);
                (*dst).p_faces[i].p_tongue_points = p_tongue_points;
                
                size_t tongue_points_score_size = sizeof(float) * face.tongue_points_count;
                float *p_tongue_points_score = malloc(tongue_points_score_size);
                memset(p_tongue_points_score, 0, tongue_points_score_size);
                memcpy(p_tongue_points_score, face.p_tongue_points_score, tongue_points_score_size);
                (*dst).p_faces[i].p_tongue_points_score = p_tongue_points_score;
            }
            
            // p_eyeball_center
            if (face.eyeball_center_points_count > 0 && face.p_eyeball_center != NULL) {
                
                size_t eyeball_center_points_size = sizeof(st_pointf_t) * face.eyeball_center_points_count;
                st_pointf_t *p_eyeball_center = malloc(eyeball_center_points_size);
                memset(p_eyeball_center, 0, eyeball_center_points_size);
                memcpy(p_eyeball_center, face.p_eyeball_center, eyeball_center_points_size);
                (*dst).p_faces[i].p_eyeball_center = p_eyeball_center;
            }
            
            // p_eyeball_contour
            if (face.eyeball_contour_points_count > 0 && face.p_eyeball_contour != NULL) {
                
                size_t eyeball_contour_points_size = sizeof(st_pointf_t) * face.eyeball_contour_points_count;
                st_pointf_t *p_eyeball_contour = malloc(eyeball_contour_points_size);
                memset(p_eyeball_contour, 0, eyeball_contour_points_size);
                memcpy(p_eyeball_contour, face.p_eyeball_contour, eyeball_contour_points_size);
                (*dst).p_faces[i].p_eyeball_contour = p_eyeball_contour;
            }
        }
    }
    
    
    // copy hands
    if ((*src).hand_count > 0) {
        
        size_t hands_size = sizeof(st_mobile_hand_t) * (*src).hand_count;
        st_mobile_hand_t *p_hands = malloc(hands_size);
        memset(p_hands, 0, hands_size);
        memcpy(p_hands, (*src).p_hands, hands_size);
        (*dst).p_hands = p_hands;
        
        for (int i = 0; i < (*src).hand_count; i ++) {
            
            st_mobile_hand_t hand = (*src).p_hands[i];
            
            // p_key_points
            if (hand.key_points_count > 0 && hand.p_key_points != NULL) {
                
                size_t key_points_size = sizeof(st_pointf_t) * hand.key_points_count;
                st_pointf_t *p_key_points = malloc(key_points_size);
                memset(p_key_points, 0, key_points_size);
                memcpy(p_key_points, hand.p_key_points, key_points_size);
                (*dst).p_hands[i].p_key_points = p_key_points;
            }
            
            // p_skeleton_keypoints
            if (hand.skeleton_keypoints_count > 0 && hand.p_skeleton_keypoints != NULL) {
                
                size_t skeleton_keypoints_size = sizeof(st_pointf_t) * hand.skeleton_keypoints_count;
                st_pointf_t *p_skeleton_keypoints = malloc(skeleton_keypoints_size);
                memset(p_skeleton_keypoints, 0, skeleton_keypoints_size);
                memcpy(p_skeleton_keypoints, hand.p_skeleton_keypoints, skeleton_keypoints_size);
                (*dst).p_hands[i].p_skeleton_keypoints = p_skeleton_keypoints;
            }
            
            // p_skeleton_3d_keypoints
            if (hand.skeleton_3d_keypoints_count > 0 && hand.p_skeleton_3d_keypoints != NULL) {
                
                size_t skeleton_3d_keypoints_size = sizeof(st_point3f_t) * hand.skeleton_3d_keypoints_count;
                st_point3f_t *p_skeleton_3d_keypoints = malloc(skeleton_3d_keypoints_size);
                memset(p_skeleton_3d_keypoints, 0, skeleton_3d_keypoints_size);
                memcpy(p_skeleton_3d_keypoints, hand.p_skeleton_3d_keypoints, skeleton_3d_keypoints_size);
                (*dst).p_hands[i].p_skeleton_3d_keypoints = p_skeleton_3d_keypoints;
            }
        }
    }
    
    
    // copy body
    if ((*src).body_count > 0) {
        
        size_t bodys_size = sizeof(st_mobile_body_t) * (*src).body_count;
        st_mobile_body_t *p_bodys = malloc(bodys_size);
        memset(p_bodys, 0, bodys_size);
        memcpy(p_bodys, (*src).p_bodys, bodys_size);
        (*dst).p_bodys = p_bodys;
        
        for (int i = 0; i < (*src).body_count; i ++) {
            
            st_mobile_body_t body = (*src).p_bodys[i];
            
            // p_key_points & p_key_points_score
            if (   body.key_points_count > 0
                && body.p_key_points != NULL
                && body.p_key_points_score != NULL) {
                
                size_t key_points_size = sizeof(st_pointf_t) * body.key_points_count;
                st_pointf_t *p_key_points = malloc(key_points_size);
                memset(p_key_points, 0, key_points_size);
                memcpy(p_key_points, body.p_key_points, key_points_size);
                (*dst).p_bodys[i].p_key_points = p_key_points;
                
                size_t key_points_score_size = sizeof(float) * body.key_points_count;
                float *p_key_points_score = malloc(key_points_score_size);
                memset(p_key_points_score, 0, key_points_score_size);
                memcpy(p_key_points_score, body.p_key_points_score, key_points_score_size);
                (*dst).p_bodys[i].p_key_points_score = p_key_points_score;
            }
            
            
            // p_contour_points & p_contour_points_score
            if (   body.contour_points_count > 0
                && body.p_contour_points != NULL
                && body.p_contour_points_score != NULL) {
                
                size_t contour_points_size = sizeof(st_pointf_t) * body.contour_points_count;
                st_pointf_t *p_contour_points = malloc(contour_points_size);
                memset(p_contour_points, 0, contour_points_size);
                memcpy(p_contour_points, body.p_contour_points, contour_points_size);
                (*dst).p_bodys[i].p_contour_points = p_contour_points;
                
                size_t contour_points_score_size = sizeof(float) * body.contour_points_count;
                float *p_contour_points_score = malloc(contour_points_score_size);
                memset(p_contour_points_score, 0, contour_points_score_size);
                memcpy(p_contour_points_score, body.p_contour_points_score, contour_points_score_size);
                (*dst).p_bodys[i].p_contour_points_score = p_contour_points_score;
            }
        }
    }
    
    
    // p_background
    if ((*src).p_background != NULL) {
        
        st_image_t *p_background = malloc(sizeof(st_image_t));
        memcpy(p_background, (*src).p_background, sizeof(st_image_t));
        
        size_t image_data_size = sizeof(unsigned char) * (*src).p_background[0].width * (*src).p_background[0].height;
        unsigned char *data = malloc(image_data_size);
        memset(data, 0, image_data_size);
        memcpy(data, (*src).p_background[0].data, image_data_size);
        p_background[0].data = data;
        
        (*dst).p_background = p_background;
    }
    
    // p_hair
    if ((*src).p_hair != NULL) {
        
        st_image_t *p_hair = malloc(sizeof(st_image_t));
        memcpy(p_hair, (*src).p_hair, sizeof(st_image_t));
        
        size_t image_data_size = sizeof(unsigned char) * (*src).p_hair[0].width * (*src).p_hair[0].height;
        unsigned char *data = malloc(image_data_size);
        memset(data, 0, image_data_size);
        memcpy(data, (*src).p_hair[0].data, image_data_size);
        p_hair[0].data = data;
        
        (*dst).p_hair = p_hair;
    }
}


void freeHumanAction(st_mobile_human_action_t *src) {
    
    // free faces
    if ((*src).face_count > 0) {
        
        for (int i = 0; i < (*src).face_count; i ++) {
            
            st_mobile_face_t face = (*src).p_faces[i];
            
            // p_extra_face_points
            if (face.extra_face_points_count > 0 && face.p_extra_face_points != NULL) {
                
                free(face.p_extra_face_points);
                face.p_extra_face_points = NULL;
            }
            
            // p_tongue_points & p_tongue_points_score
            if (   face.tongue_points_count > 0
                && face.p_tongue_points != NULL
                && face.p_tongue_points_score != NULL) {
                
                free(face.p_tongue_points);
                face.p_tongue_points = NULL;
                
                free(face.p_tongue_points_score);
                face.p_tongue_points_score = NULL;
            }
            
            // p_eyeball_center
            if (face.eyeball_center_points_count > 0 && face.p_eyeball_center != NULL) {
                
                free(face.p_eyeball_center);
                face.p_eyeball_center = NULL;
            }
            
            // p_eyeball_contour
            if (face.eyeball_contour_points_count > 0 && face.p_eyeball_contour != NULL) {
                
                free(face.p_eyeball_contour);
                face.p_eyeball_contour = NULL;
            }
        }
        
        free((*src).p_faces);
        (*src).p_faces = NULL;
    }
    
    
    // free hands
    if ((*src).hand_count > 0) {
        
        for (int i = 0; i < (*src).hand_count; i ++) {
            
            st_mobile_hand_t hand = (*src).p_hands[i];
            
            // p_key_points
            if (hand.key_points_count > 0 && hand.p_key_points != NULL) {
                
                free(hand.p_key_points);
                hand.p_key_points = NULL;
            }
            
            // p_skeleton_keypoints
            if (hand.skeleton_keypoints_count > 0 && hand.p_skeleton_keypoints != NULL) {
                
                free(hand.p_skeleton_keypoints);
                hand.p_skeleton_keypoints = NULL;
            }
            
            // p_skeleton_3d_keypoints
            if (hand.skeleton_3d_keypoints_count > 0 && hand.p_skeleton_3d_keypoints != NULL) {
                
                free(hand.p_skeleton_3d_keypoints);
                hand.p_skeleton_3d_keypoints = NULL;
            }
        }
        
        free((*src).p_hands);
        (*src).p_hands = NULL;
    }
    
    
    // free body
    if ((*src).body_count > 0) {
        
        for (int i = 0; i < (*src).body_count; i ++) {
            
            st_mobile_body_t body = (*src).p_bodys[i];
            
            // p_key_points & p_key_points_score
            if (   body.key_points_count > 0
                && body.p_key_points != NULL
                && body.p_key_points_score != NULL) {
                
                free(body.p_key_points);
                body.p_key_points = NULL;
                
                free(body.p_key_points_score);
                body.p_key_points_score = NULL;
            }
            
            
            // p_contour_points & p_contour_points_score
            if (   body.contour_points_count > 0
                && body.p_contour_points != NULL
                && body.p_contour_points_score != NULL) {
                
                free(body.p_contour_points);
                body.p_contour_points = NULL;
                
                free(body.p_contour_points_score);
                body.p_contour_points_score = NULL;
            }
        }
        
        free((*src).p_bodys);
        (*src).p_bodys = NULL;
    }
    
    
    // p_background
    if ((*src).p_background != NULL) {
        
        if ((*src).p_background[0].data != NULL) {
            
            free((*src).p_background[0].data);
            (*src).p_background[0].data = NULL;
        }
        
        free((*src).p_background);
        (*src).p_background = NULL;
    }
    
    // p_hair
    if ((*src).p_hair != NULL) {
        
        if ((*src).p_hair[0].data != NULL) {
            
            free((*src).p_hair[0].data);
            (*src).p_hair[0].data = NULL;
        }
        
        free((*src).p_hair);
        (*src).p_hair = NULL;
    }
    
    memset(src, 0, sizeof(st_mobile_human_action_t));
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_indicatorView stopAnimating];
}

#pragma mark - STBeautySliderDelegate

- (CGFloat)currentSliderValue:(float)value slider:(UISlider *)slider {
    
    switch (self.curBeautyBeautyType) {
        
        case STBeautyTypeNone:
        case STBeautyTypeWhiten:
        case STBeautyTypeRuddy:
        case STBeautyTypeDermabrasion:
        case STBeautyTypeDehighlight:
        case STBeautyTypeShrinkFace:
        case STBeautyTypeEnlargeEyes:
        case STBeautyTypeShrinkJaw:
        case STBeautyTypeThinFaceShape:
        case STBeautyTypeNarrowNose:
        case STBeautyTypeContrast:
        case STBeautyTypeSaturation:
        case STBeautyTypeNarrowFace:
        case STBeautyTypeRoundEye:
        case STBeautyTypeAppleMusle:
        case STBeautyTypeProfileRhinoplasty:
        case STBeautyTypeBrightEye:
        case STBeautyTypeRemoveDarkCircles:
        case STBeautyTypeWhiteTeeth:
        case STBeautyTypeOpenCanthus:
        case STBeautyTypeRemoveNasolabialFolds:
            value = (value + 1) / 2.0;
            break;
            
        default:
            break;
            
    }
    
    return value;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

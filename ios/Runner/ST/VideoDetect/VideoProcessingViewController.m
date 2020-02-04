//
//  VideoProcessingViewController.m
//  SenseMeEffects
//
//  Created by Sunshine on 12/12/2017.
//  Copyright © 2017 SenseTime. All rights reserved.
//

#import "VideoProcessingViewController.h"
#import "STGLPreview2.h"
#import <CommonCrypto/CommonDigest.h>
#import <AVFoundation/AVFoundation.h>
#import "STMovieRecorder.h"
#import "STTriggerView.h"
#import "STParamUtil.h"
#import "STFilterView.h"
#import "STScrollTitleView.h"
#import "STMobileLog.h"
#import "STCommonObjectContainerView.h"
#import "STAudioManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "STCommonObjectContainerView.h"
#import "STPlayerControlBar.h"
#import "STBeautySlider.h"


#import "SenseArSourceService.h"
#import "STCustomMemoryCache.h"
#import "EffectsCollectionView.h"
#import "EffectsCollectionViewCell.h"

#import "STBMPCollectionView.h"
#import "STBmpStrengthView.h"

#import "st_mobile_common.h"
#import "st_mobile_license.h"
#import "st_mobile_filter.h"
#import "st_mobile_sticker.h"
#import "st_mobile_beautify.h"
#import "st_mobile_face_attribute.h"
#import "st_mobile_object.h"
#import "st_mobile_animal.h"
#import "st_mobile_makeup.h"

#define DRAW_FACE_KEY_POINTS 0
#define TEST_BODY_BEAUTY 0

typedef NS_ENUM(NSInteger, STWriterRecordingStatus){
    STWriterRecordingStatusIdle = 0,
    STWriterRecordingStatusStartingRecording,
    STWriterRecordingStatusRecording,
    STWriterRecordingStatusStoppingRecording
};

typedef NS_ENUM(NSInteger, STViewTag) {
    
    STViewTagSpecialEffectsBtn = 1000,
    STViewTagBeautyBtn,
};

@interface VideoProcessingViewController () <AVPlayerItemOutputPullDelegate, STMovieRecorderDelegate, STAudioManagerDelegate, STBeautySliderDelegate,STBMPCollectionViewDelegate, STBmpStrengthViewDelegate>

@property (nonatomic, strong) STGLPreview2 *glPreview;

@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayerItemVideoOutput *videoOutput;
@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic) dispatch_queue_t videoOutputQueue;
@property (nonatomic) dispatch_queue_t changeStickerQueue;
@property (nonatomic) dispatch_queue_t videoProcessingQueue;
@property (nonatomic) dispatch_queue_t recorderCallbackQueue;

@property (nonatomic, assign) CGFloat imageWidth;
@property (nonatomic, assign) CGFloat imageHeight;

@property (nonatomic, strong) EAGLContext *glContext;
@property (nonatomic) CVOpenGLESTextureCacheRef cvTextureCache;

@property (nonatomic) CVOpenGLESTextureRef cvTextureOrigin;
@property (nonatomic) GLuint textureOriginInput;

@property (nonatomic) CVOpenGLESTextureRef cvFirstFrameTexture;
@property (nonatomic) GLuint textureFirstFrame;

@property (nonatomic) CVOpenGLESTextureRef cvTextureBeautify;
@property (nonatomic) CVPixelBufferRef cvBeautifyBuffer;
@property (nonatomic) GLuint textureBeautifyOutput;

@property (nonatomic) CVOpenGLESTextureRef cvTextureMakeUp;
@property (nonatomic) CVPixelBufferRef cvMakeUpBuffer;
@property (nonatomic) GLuint textureMakeUpOutput;

@property (nonatomic) CVOpenGLESTextureRef cvTextureSticker;
@property (nonatomic) CVPixelBufferRef cvStickerBuffer;
@property (nonatomic) GLuint textureStickerOutput;

@property (nonatomic) CVOpenGLESTextureRef cvTextureFilter;
@property (nonatomic) CVPixelBufferRef cvFilterBuffer;
@property (nonatomic) GLuint textureFilterOutput;

@property (nonatomic) st_handle_t hDetector;
@property (nonatomic) st_handle_t hSticker;
@property (nonatomic) st_handle_t hBeautify;
@property (nonatomic) st_handle_t hFilter;
@property (nonatomic) st_handle_t hTracker;
@property (nonatomic) st_handle_t hAttribute;
@property (nonatomic) st_handle_t animalHandle;
@property (nonatomic) st_handle_t hBmpHandle;
@property (nonatomic) st_mobile_animal_face_t *detectResult1;

@property (nonatomic) st_mobile_106_t *pFacesDetection;

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

@property (nonatomic, assign) float fFilterStrength;
@property (nonatomic, assign) unsigned long long iCurrentAction;
@property (nonatomic, readwrite, assign) unsigned long long makeUpConf;
@property (nonatomic, assign) unsigned long long stickerConf;
@property (nonatomic, assign) BOOL bMakeUp;
@property (nonatomic, assign) int margin;
@property (nonatomic, assign) CGFloat scale;

@property (nonatomic, assign) BOOL bBeauty;
@property (nonatomic, assign) BOOL bFilter;
@property (nonatomic, assign) BOOL bSticker;
@property (nonatomic, assign) BOOL bTracker;
@property (nonatomic, assign) BOOL isNullSticker;
@property (nonatomic, assign) BOOL needSnap;
@property (nonatomic, assign) BOOL pauseOutput;
@property (nonatomic, assign) BOOL isAppActive;
@property (nonatomic, assign) BOOL recording;
@property (nonatomic, assign) BOOL filterStrengthViewHidden;
@property (nonatomic, assign) BOOL specialEffectsContainerViewIsShow;
@property (nonatomic, assign) BOOL beautyContainerViewIsShow;
@property (nonatomic, assign, getter=isCommonObjectViewAdded) BOOL commonObjectViewAdded;
@property (nonatomic, assign, getter=isCommonObjectViewSetted) BOOL commonObjectViewSetted;
@property (nonatomic, assign) BOOL needRecord;
@property (nonatomic, assign) BOOL needDetectAnimal;

@property (nonatomic, assign) BOOL isComparing;

@property (nonatomic, strong) NSURL *recorderURL;

@property (nonatomic) CMFormatDescriptionRef outputVideoFormatDescription;
@property (nonatomic) CMFormatDescriptionRef outputAudioFormatDescription;

@property (nonatomic, copy) NSString *preFilterModelPath;
@property (nonatomic, copy) NSString *curFilterModelPath;
@property (nonatomic, copy) NSString *strStickerPath;
@property (nonatomic, copy) NSString *strBodyAction;

@property (nonatomic, strong) UILabel *lblSaveStatus;
@property (nonatomic, strong) UILabel *lblCPU;
@property (nonatomic, strong) UILabel *lblSpeed;
@property (nonatomic, strong) UILabel *lblFilterStrength;

@property (nonatomic, strong) UIView *specialEffectsContainerView;
@property (nonatomic, strong) UIView *beautyContainerView;
@property (nonatomic, strong) UIView *filterCategoryView;
@property (nonatomic, strong) UIView *filterSwitchView;
@property (nonatomic, strong) UIView *filterStrengthView;
@property (nonatomic, strong) UIView *beautyShapeView;
@property (nonatomic, strong) UIView *beautyBaseView;
@property (nonatomic, strong) UIView *beautyBodyView;

@property (nonatomic, strong) UIButton *startProcessingBtn;
@property (nonatomic, strong) UIButton *btnCompare;

@property (nonatomic, strong) STTriggerView *triggerView;
@property (nonatomic, strong) STFilterView *filterView;
@property (nonatomic, assign) STWriterRecordingStatus recordStatus;
@property (nonatomic, strong) STMovieRecorder *stRecoder;
@property (nonatomic, strong) STAudioManager *audioManager;

@property (nonatomic, strong) STScrollTitleView *scrollTitleView;
@property (nonatomic, strong) STScrollTitleView *beautyScrollTitleViewNew;

@property (nonatomic , strong) STCustomMemoryCache *effectsDataSource;
@property (nonatomic , strong) EffectsCollectionView *effectsList;
@property (nonatomic, strong) STCollectionView *objectTrackCollectionView;
@property (nonatomic, strong) STFilterCollectionView *filterCollectionView;

@property (nonatomic, strong) STViewButton *specialEffectsBtn;
@property (nonatomic, strong) STViewButton *beautyBtn;

@property (nonatomic, strong) STCollectionViewDisplayModel *currentSelectedFilterModel;
@property (nonatomic, strong) STCommonObjectContainerView *commonObjectContainerView;

@property (nonatomic, strong) NSMutableArray *arrBeautyViews;
@property (nonatomic, strong) NSMutableArray<STViewButton *> *arrFilterCategoryViews;
@property (nonatomic, strong) NSMutableArray *faceArray;

@property (nonatomic) dispatch_queue_t thumbDownlaodQueue;
@property (nonatomic, strong) NSOperationQueue *imageLoadQueue;
@property (nonatomic , strong) STCustomMemoryCache *thumbnailCache;
@property (nonatomic , strong) NSFileManager *fManager;
@property (nonatomic , copy) NSString *strThumbnailPath;

@property (nonatomic , strong) NSArray *arrCurrentModels;
@property (nonatomic , strong) EffectsCollectionViewCellModel *prepareModel;

@property (nonatomic, strong) NSArray *arrObjectTrackers;

@property (nonatomic, strong) UIImageView *noneStickerImageView;
@property (nonatomic, strong) UISlider *filterStrengthSlider;
@property (nonatomic, strong) UISwitch *saveProcessedMovie;

@property (nonatomic) id notificationToken;
@property (nonatomic) id timeObserve;
@property (nonatomic, strong) AVPlayerItem *playerItem;

@property (nonatomic) st_rotate_type rotateType;
@property (nonatomic) CGAffineTransform tranform;

@property (nonatomic, strong) STPlayerControlBar *progressBar;
@property (nonatomic, strong) UIButton *btnSaveVideoToAlbum;

@property (nonatomic) CGRect previewRect;
@property (nonatomic, strong) UIButton *btnBack;

@property (nonatomic) CVPixelBufferRef pixelBufferCopy;
@property (nonatomic) BOOL isFirstFrame;
@property (nonatomic, assign) BOOL isPlaying;

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
@property (nonatomic, strong) NSData *licenseData;

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

@implementation VideoProcessingViewController

- (void)dealloc {
    
    NSLog(@"video processing view controller dealloc successfully");
}

- (void)onBtnBack:(UIButton *)sender {
    
    if (self.isPlaying) {
        sender.enabled = NO;
        
        [_avPlayer pause];
        [_avPlayer.currentItem seekToTime:kCMTimeZero];
        
        self.isPlaying = NO;
        
        if (self.recording) {
            [self stopRecorder];
            self.recording = NO;
            self.btnSaveVideoToAlbum.enabled = YES;
        }
        
        self.specialEffectsBtn.hidden = NO;
        self.beautyBtn.hidden = NO;
        self.progressBar.hidden = YES;
        self.startProcessingBtn.hidden = NO;
        self.btnSaveVideoToAlbum.hidden = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setupRecorder];
            [self prepareRecord];
            sender.enabled = YES;
        });
        
        //        [self processFirstFrame:_pixelBufferCopy needOriginImage:NO];
        
    } else {
        
        [_avPlayer pause];
        _avPlayer = nil;
        [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        _displayLink.paused = YES;
        [_displayLink invalidate];
        _displayLink = nil;
        
        _videoOutputQueue = NULL;
        _videoProcessingQueue = NULL;
        _changeStickerQueue = NULL;
        _recorderCallbackQueue = NULL;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        _notificationToken = nil;
        _timeObserve = nil;
        
        [EAGLContext setCurrentContext:self.glContext];
        
        if (_hSticker) {
            
            st_mobile_sticker_destroy(_hSticker);
            _hSticker = NULL;
        }
        if (_hBeautify) {
            
            st_mobile_beautify_destroy(_hBeautify);
            _hBeautify = NULL;
        }
        
        if (_hDetector) {
            
            st_mobile_human_action_destroy(_hDetector);
            _hDetector = NULL;
        }
        
        if (_animalHandle) {
            st_mobile_tracker_animal_face_destroy(_animalHandle);
            _animalHandle = NULL;
        }
        
        if (_hBmpHandle) {
            st_mobile_makeup_destroy(_hBmpHandle);
            _hBmpHandle = NULL;
        }
        
        if (_hAttribute) {
            
            st_mobile_face_attribute_destroy(_hAttribute);
            _hAttribute = NULL;
        }
        
        if (_pFacesDetection) {
            
            free(_pFacesDetection);
            _pFacesDetection = NULL;
        }
        
        if (_hFilter) {
            
            st_mobile_gl_filter_destroy(_hFilter);
            _hFilter = NULL;
        }
        
        if (_hTracker) {
            st_mobile_object_tracker_destroy(_hTracker);
            _hTracker = NULL;
        }
        
        _textureBeautifyOutput = 0;
        _textureStickerOutput = 0;
        _textureFilterOutput = 0;
        
        if (_cvTextureOrigin) {
            
            CFRelease(_cvTextureOrigin);
            _cvTextureOrigin = NULL;
        }
        
        if (_cvFirstFrameTexture) {
            CFRelease(_cvFirstFrameTexture);
            _cvFirstFrameTexture = NULL;
        }
        
        if (_pixelBufferCopy) {
            CFRelease(_pixelBufferCopy);
        }
        
        CVPixelBufferRelease(_cvTextureBeautify);
        CVPixelBufferRelease(_cvTextureSticker);
        CVPixelBufferRelease(_cvTextureFilter);
        CVPixelBufferRelease(_cvTextureMakeUp);
        
        CVPixelBufferRelease(_cvBeautifyBuffer);
        CVPixelBufferRelease(_cvStickerBuffer);
        CVPixelBufferRelease(_cvFilterBuffer);
        CVPixelBufferRelease(_cvMakeUpBuffer);
        
        if (_cvTextureCache) {
            
            CFRelease(_cvTextureCache);
            _cvTextureCache = NULL;
        }
        
        if (self.outputVideoFormatDescription) {
            CFRelease(self.outputVideoFormatDescription);
            self.outputVideoFormatDescription = nil;
        }
        
        if (self.outputAudioFormatDescription) {
            CFRelease(self.outputAudioFormatDescription);
            self.outputAudioFormatDescription = nil;
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addNotifications];
    [self setDefaultValue];
    [self setupSubviews];
    [self resetSettings];
    [self setupThumbnailCache];
    [self setupSenseArService];
    
    if (![self checkActiveCodeWithData:self.licenseData]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"验证license失败" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    [self setupHandle];
    [self setupPlayer];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self resetBmp];
}

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)setupPlayer {
    
    _audioManager = [[STAudioManager alloc] init];
    _audioManager.delegate = self;
    
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    _displayLink.paused = YES;
    
    _avPlayer = [[AVPlayer alloc] init];
    NSDictionary *pixelBufferAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
    _videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixelBufferAttributes];
    _videoOutputQueue = dispatch_queue_create("com.sensetime.videoOutputQueue", NULL);
    [_videoOutput setDelegate:self queue:_videoOutputQueue];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:_videoURL];
    [item addOutput:_videoOutput];
    _playerItem = item;
    [_avPlayer replaceCurrentItemWithPlayerItem:item];
    _avPlayer.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    [_videoOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:0.04];
    
    __weak __typeof(self) weakSelf = self;
    _notificationToken = [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:item queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        
        [[weakSelf.avPlayer currentItem] seekToTime:kCMTimeZero];
        [weakSelf stopRecorder];
        
    }];
    
    _timeObserve = [self.avPlayer addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:nil usingBlock:^(CMTime time) {
        
        AVPlayerItem *currentItem = weakSelf.playerItem;
        NSArray *loadedRanges = currentItem.seekableTimeRanges;
        if (loadedRanges.count > 0 && currentItem.duration.timescale != 0) {
            NSInteger currentTime = (NSInteger)CMTimeGetSeconds(currentItem.currentTime);
            CGFloat totalTime = (CGFloat)currentItem.duration.value / currentItem.duration.timescale;
            CGFloat value = CMTimeGetSeconds(currentItem.currentTime) / totalTime;
            [weakSelf.progressBar playerCurrentTime:currentTime totalTime:totalTime sliderValue:value];
        }
        
    }];
    
}

- (void)processFirstFrame:(CVPixelBufferRef)pixelBuffer needOriginImage:(BOOL)needOriginImage {
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    unsigned char * pBGRAImageIn = CVPixelBufferGetBaseAddress(pixelBuffer);
    int iBytesPerRow = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
    int iWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
    int iHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    
    size_t iTop , iBottom , iLeft , iRight;
    CVPixelBufferGetExtendedPixels(pixelBuffer, &iLeft, &iRight, &iTop, &iBottom);
    
    iWidth = iWidth + (int)iLeft + (int)iRight;
    iHeight = iHeight + (int)iTop + (int)iBottom;
    iBytesPerRow = iBytesPerRow + (int)iLeft + (int)iRight;
    
    st_result_t iRet = ST_OK;
    st_mobile_human_action_t detectResult;
    memset(&detectResult, 0, sizeof(st_mobile_human_action_t));
    
    if (_hDetector) {
        
        BOOL needFaceDetection = YES;
        
        if (needFaceDetection) {
            
            self.iCurrentAction = ST_MOBILE_FACE_DETECT | self.stickerConf | self.makeUpConf;
        } else {
            
            self.iCurrentAction = self.stickerConf | self.makeUpConf;
        }
        
        self.iCurrentAction |= ST_MOBILE_BODY_KEYPOINTS | ST_MOBILE_BODY_CONTOUR;
        
        if (self.iCurrentAction > 0) {
            
            TIMELOG(keyDetect);
            
            iRet = st_mobile_human_action_detect(_hDetector, pBGRAImageIn, ST_PIX_FMT_BGRA8888, iWidth, iHeight, iBytesPerRow, _rotateType, self.iCurrentAction, &detectResult);
            
            TIMEPRINT(keyDetect, "st_mobile_human_action_detect time:");
            
            if(iRet == ST_OK) {
                
            }else{
                
                STLog(@"st_mobile_human_action_detect failed %d" , iRet);
            }
        }
    }
    
    int catFaceCount = -1;
    ///cat face
    if (_needDetectAnimal && _animalHandle) {
        
        st_result_t iRet = st_mobile_tracker_animal_face_track(_animalHandle, pBGRAImageIn, ST_PIX_FMT_BGRA8888, iWidth, iHeight, iBytesPerRow, 0, &_detectResult1, &catFaceCount);
        
        if (iRet != ST_OK) {
            NSLog(@"st mobile animal face tracker failed: %d", iRet);
        } else {
//            NSLog(@"cat face count: %d", catFaceCount);
        }
        
    }
    
    
    // 设置 OpenGL 环境 , 需要与初始化 SDK 时一致
    if ([EAGLContext currentContext] != self.glContext) {
        [EAGLContext setCurrentContext:self.glContext];
    }
    
    GLint textureResult = _textureFirstFrame;
    
    
    ///ST_MOBILE 以下为美颜部分
    if (_bBeauty && _hBeautify) {
        
        TIMELOG(keyBeautify);
        
        iRet = st_mobile_beautify_process_texture(_hBeautify, _textureFirstFrame, iWidth, iHeight, _rotateType, &detectResult, _textureBeautifyOutput, &detectResult);
        
        TIMEPRINT(keyBeautify, "st_mobile_beautify_process_texture time:");
        
        if (ST_OK != iRet) {
            
            
            STLog(@"st_mobile_beautify_process_texture failed %d" , iRet);
            
        }
        
        textureResult = _textureBeautifyOutput;
    }
    
    
    if (self.isNullSticker) {
        iRet = st_mobile_sticker_change_package(_hSticker, NULL, NULL);
        
        if (ST_OK != iRet) {
            NSLog(@"st_mobile_sticker_change_package error %d", iRet);
        }
    }
    
    ///ST_MOBILE 以下为贴纸部分
    if (_bSticker && _hSticker) {
        
        TIMELOG(stickerProcessKey);
        
        iRet = st_mobile_sticker_process_texture(_hSticker, textureResult, iWidth, iHeight, _rotateType, _rotateType, false, &detectResult, NULL, _textureStickerOutput);
        
//        iRet = st_mobile_sticker_process_texture_both(_hSticker, textureResult, iWidth, iHeight, ST_CLOCKWISE_ROTATE_90, ST_CLOCKWISE_ROTATE_90, false, &detectResult, NULL, _detectResult1, catFaceCount, _textureStickerOutput);
        
        TIMEPRINT(stickerProcessKey, "st_mobile_sticker_process_texture time:");
        
        if (ST_OK != iRet) {
            
            STLog(@"st_mobile_sticker_process_texture %d" , iRet);
            
        }
        
        textureResult = _textureStickerOutput;
    }
    
    
    ///ST_MOBILE 以下为滤镜部分
    if (_hFilter) {
        
        if (self.curFilterModelPath != self.preFilterModelPath) {
            iRet = st_mobile_gl_filter_set_style(_hFilter, self.curFilterModelPath.UTF8String);
            if (iRet != ST_OK) {
                NSLog(@"filter set style failed: %d", iRet);
            }
            self.preFilterModelPath = self.curFilterModelPath;
        }
        
        TIMELOG(keyFilter);
        
        iRet = st_mobile_gl_filter_process_texture(_hFilter, textureResult, iWidth, iHeight, _textureFilterOutput);
        
        if (ST_OK != iRet) {
            
            STLog(@"st_mobile_gl_filter_process_texture %d" , iRet);
            
        }
        
        TIMEPRINT(keyFilter, "st_mobile_gl_filter_process_texture time:");
        
        textureResult = _textureFilterOutput;
    }
    
    if (needOriginImage) {
        textureResult = _textureFirstFrame;
    }
    
    [self.glPreview renderTexture:textureResult rotate:_rotateType];
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    CVOpenGLESTextureCacheFlush(_cvTextureCache, 0);
    
    if (_cvTextureOrigin) {
        
        CFRelease(_cvTextureOrigin);
        _cvTextureOrigin = NULL;
    }
}

#pragma mark - displaylink callback

- (void)displayLinkCallback:(CADisplayLink *)sender {
    
    CMTime outputItemTime = kCMTimeInvalid;
    CFTimeInterval nextVSync = sender.timestamp + sender.duration;
    outputItemTime = [_videoOutput itemTimeForHostTime:nextVSync];
    if ([self.videoOutput hasNewPixelBufferForItemTime:outputItemTime]) {
        
        TIMELOG(frameKey);
        
        double dStart = CFAbsoluteTimeGetCurrent();
        
        CVPixelBufferRef pixelBuffer = [_videoOutput copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:NULL];
        
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        
        unsigned char * pBGRAImageIn = CVPixelBufferGetBaseAddress(pixelBuffer);
        int iBytesPerRow = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
        int iWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
        int iHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
        
        size_t iTop , iBottom , iLeft , iRight;
        CVPixelBufferGetExtendedPixels(pixelBuffer, &iLeft, &iRight, &iTop, &iBottom);
        
        iWidth = iWidth + (int)iLeft + (int)iRight;
        iHeight = iHeight + (int)iTop + (int)iBottom;
        iBytesPerRow = iBytesPerRow + (int)iLeft + (int)iRight;
        
        if (self.isFirstFrame) {
            CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, iWidth, iHeight, kCVPixelFormatType_32BGRA, NULL, &_pixelBufferCopy);
            if (status != kCVReturnSuccess) {
                NSLog(@"create pixel buffer failed: %d", status);
            }
            CVPixelBufferLockBaseAddress(_pixelBufferCopy, 0);
            
            uint8_t *copyBaseAddress = CVPixelBufferGetBaseAddress(_pixelBufferCopy);
            memcpy(copyBaseAddress, pBGRAImageIn, iWidth * iHeight * 4);
            
            CVPixelBufferUnlockBaseAddress(_pixelBufferCopy, 0);
        }
        
        _scale = MAX(SCREEN_HEIGHT / iHeight, SCREEN_WIDTH / iWidth);
        _margin = (iWidth * _scale - SCREEN_WIDTH) / 2;
        
        st_result_t iRet = ST_OK;
        st_mobile_human_action_t detectResult;
        memset(&detectResult, 0, sizeof(st_mobile_human_action_t));
        int iFaceCount = 0;
        _faceArray = [NSMutableArray array];
        
        if (_hDetector) {

            BOOL needFaceDetection = YES;

            unsigned long long iConfig = 0;
            
            if (needFaceDetection) {
                
                iConfig = ST_MOBILE_FACE_DETECT | self.stickerConf | self.makeUpConf;
            }
            
#if TEST_BODY_BEAUTY
            iConfig |= (self.iCurrentAction | ST_MOBILE_BODY_KEYPOINTS | ST_MOBILE_BODY_CONTOUR);
#endif
            
            if (iConfig > 0) {
                
                TIMELOG(keyDetect);
                
                iRet = st_mobile_human_action_detect(_hDetector, pBGRAImageIn, ST_PIX_FMT_BGRA8888, iWidth, iHeight, iBytesPerRow, _rotateType, iConfig, &detectResult);
                
                TIMEPRINT(keyDetect, "st_mobile_human_action_detect time:");
                
                if(iRet == ST_OK) {
                    
                    iFaceCount = detectResult.face_count;
                    
                    if (iFaceCount > 0) {
                        _pFacesDetection = (st_mobile_106_t *)malloc(sizeof(st_mobile_106_t) * iFaceCount);
                        memset(_pFacesDetection, 0, sizeof(st_mobile_106_t) * iFaceCount);
                    }
                    
                    //构造人脸信息数组
                    for (int i = 0; i < iFaceCount; i++) {
                        
                        _pFacesDetection[i] = detectResult.p_faces[i].face106;
                        
                    }
                    
                }else{
                    
                    STLog(@"st_mobile_human_action_detect failed %d" , iRet);
                }
            }
        }
        
        int catFaceCount = -1;
        ///cat face
        if (_needDetectAnimal && _animalHandle) {
            
            st_result_t iRet = st_mobile_tracker_animal_face_track(_animalHandle, pBGRAImageIn, ST_PIX_FMT_BGRA8888, iWidth, iHeight, iBytesPerRow, 0, &_detectResult1, &catFaceCount);
            
            if (iRet != ST_OK) {
                NSLog(@"st mobile animal face tracker failed: %d", iRet);
            } else {
//                NSLog(@"cat face count: %d", catFaceCount);
            }
            
        }
        
        
        // 设置 OpenGL 环境 , 需要与初始化 SDK 时一致
        if ([EAGLContext currentContext] != self.glContext) {
            [EAGLContext setCurrentContext:self.glContext];
        }
        
        // 获取原图纹理
        BOOL isTextureOriginReady = [self setupOriginTextureWithPixelBuffer:pixelBuffer];
        if (self.isFirstFrame) {
            BOOL isFirstFrameOriginReady = [self getFirstFrameTexture:pixelBuffer];
            self.isFirstFrame = NO;
        }
        
        GLuint textureResult = _textureOriginInput;
        
        CVPixelBufferRef resultPixelBufffer = pixelBuffer;
        
        if (isTextureOriginReady) {
            
            ///ST_MOBILE 以下为美颜部分
            if (_bBeauty && _hBeautify) {
                
                TIMELOG(keyBeautify);
                
                iRet = st_mobile_beautify_process_texture(_hBeautify, _textureOriginInput, iWidth, iHeight, _rotateType, &detectResult, _textureBeautifyOutput, &detectResult);
                
                TIMEPRINT(keyBeautify, "st_mobile_beautify_process_texture time:");
                
                if (ST_OK != iRet) {
                    
                    
                    STLog(@"st_mobile_beautify_process_texture failed %d" , iRet);
                    
                }
                
                textureResult = _textureBeautifyOutput;
                resultPixelBufffer = _cvBeautifyBuffer;
            }
        }
#if DRAW_FACE_KEY_POINTS
        
        [self drawKeyPoints:detectResult];
#endif
        
        if (self.isNullSticker) {
            iRet = st_mobile_sticker_change_package(_hSticker, NULL, NULL);
            
            if (ST_OK != iRet) {
                NSLog(@"st_mobile_sticker_change_package error %d", iRet);
            }
        }
        
        //makeup
        if (_hBmpHandle) {
            iRet = st_mobile_makeup_process_texture(_hBmpHandle, textureResult, iWidth, iHeight, _rotateType, &detectResult, _textureMakeUpOutput);
            if (iRet != ST_OK) {
                NSLog(@"st_mobile_makeup_process_texture failed: %d", iRet);
            } else {
                textureResult = _textureMakeUpOutput;
                resultPixelBufffer = _cvMakeUpBuffer;
            }
            
        }
        
        ///ST_MOBILE 以下为贴纸部分
        if (_bSticker && _hSticker) {
            
            TIMELOG(stickerProcessKey);
            
            iRet = st_mobile_sticker_process_texture(_hSticker, textureResult, iWidth, iHeight, _rotateType, _rotateType, false, &detectResult, NULL, _textureStickerOutput);
//            iRet = st_mobile_sticker_process_texture_both(_hSticker, textureResult, iWidth, iHeight, ST_CLOCKWISE_ROTATE_90, ST_CLOCKWISE_ROTATE_90, false, &detectResult, NULL, _detectResult1, catFaceCount, _textureStickerOutput);
            
            TIMEPRINT(stickerProcessKey, "st_mobile_sticker_process_texture time:");
            
            if (ST_OK != iRet) {
                
                STLog(@"st_mobile_sticker_process_texture %d" , iRet);
                
            }
            
            textureResult = _textureStickerOutput;
            resultPixelBufffer = _cvStickerBuffer;
        }
        
        
        ///ST_MOBILE 以下为滤镜部分
        if (_hFilter) {
            if (self.curFilterModelPath != self.preFilterModelPath) {
                iRet = st_mobile_gl_filter_set_style(_hFilter, self.curFilterModelPath.UTF8String);
                if (iRet != ST_OK) {
                    NSLog(@"filter set style failed: %d", iRet);
                }
                self.preFilterModelPath = self.curFilterModelPath;
            }
            
            TIMELOG(keyFilter);
            
            iRet = st_mobile_gl_filter_process_texture(_hFilter, textureResult, iWidth, iHeight, _textureFilterOutput);
            
            if (ST_OK != iRet) {
                
                STLog(@"st_mobile_gl_filter_process_texture %d" , iRet);
                
            }
            
            TIMEPRINT(keyFilter, "st_mobile_gl_filter_process_texture time:");
            
            textureResult = _textureFilterOutput;
            resultPixelBufffer = _cvFilterBuffer;
        }
        
        if (!self.outputVideoFormatDescription) {
            CMVideoFormatDescriptionCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, &_outputVideoFormatDescription);
            
            if (self.outputVideoFormatDescription) {
                [self setupRecorder];
                [self prepareRecord];
            }
        }
        
        if (self.recording) {
            @synchronized (self) {
                if (self.recordStatus == STWriterRecordingStatusRecording) {
                    [self.stRecoder appendVideoPixelBuffer:resultPixelBufffer withPresentationTime:outputItemTime];
                }
            }
        }
        
        if (self.isComparing) {
            
            textureResult = _textureOriginInput;
        }
        
        [self.glPreview renderTexture:textureResult rotate:_rotateType];
        
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        CVOpenGLESTextureCacheFlush(_cvTextureCache, 0);
        
        if (pixelBuffer) {
            CFRelease(pixelBuffer);
        }
        
        if (_cvTextureOrigin) {
            
            CFRelease(_cvTextureOrigin);
            _cvTextureOrigin = NULL;
        }
        
        if (_pFacesDetection) {
            free(_pFacesDetection);
            _pFacesDetection = NULL;
        }
        
        TIMEPRINT(frameKey, "every frame cost time:");
        
        double dCost = (CFAbsoluteTimeGetCurrent() - dStart) * 1000;
        
        [self.lblSpeed setText:[NSString stringWithFormat:@"单帧耗时: %.0fms" ,dCost]];
        [self.lblCPU setText:[NSString stringWithFormat:@"CPU占用率: %.1f%%" , [STParamUtil getCpuUsage]]];
        
    }
}

#pragma mark - AVPlayerItemOutputPullDelegate

- (void)outputMediaDataWillChange:(AVPlayerItemOutput *)sender {
    self.displayLink.paused = NO;
}

- (void)setDefaultValue {
    
    self.bBeauty = YES;
    self.bFilter = NO;
    self.bSticker = NO;
    self.bTracker = NO;
    self.needDetectAnimal = NO;
    
    self.isFirstFrame = YES;
    self.isPlaying = NO;
    
    self.isNullSticker = NO;
    
    self.fFilterStrength = 1.0;
    
    self.iCurrentAction = 0;
    
    self.needSnap = NO;
    self.pauseOutput = NO;
    self.isAppActive = YES;
    
    self.recordStatus = STWriterRecordingStatusIdle;
    self.recording = NO;
    self.recorderURL = [[NSURL alloc] initFileURLWithPath:[NSString pathWithComponents:@[NSTemporaryDirectory(), @"Movie.MOV"]]];
    
    self.outputAudioFormatDescription = nil;
    self.outputVideoFormatDescription = nil;
    
    self.changeStickerQueue = dispatch_queue_create("com.sensetime.changestickerqueue", DISPATCH_QUEUE_SERIAL);
    self.videoProcessingQueue = dispatch_queue_create("com.sensetime.videoProcessingQueue", DISPATCH_QUEUE_SERIAL);
    self.recorderCallbackQueue = dispatch_queue_create("com.sensetime.recorderCallbackQueue", DISPATCH_QUEUE_SERIAL);
    
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

- (void)resetSettings {
    
    self.filterStrengthViewHidden = YES;
    
    self.preFilterModelPath = nil;
//    self.curFilterModelPath = nil;
    
    self.noneStickerImageView.highlighted = YES;
    self.lblFilterStrength.text = @"100";
    self.filterStrengthSlider.value = 1;
    
    self.currentSelectedFilterModel.isSelected = NO;
    [self refreshFilterCategoryState:STEffectsTypeNone];
    
    self.fSmoothStrength = 0.0;
    self.fReddenStrength = 0.0;
    self.fWhitenStrength = 0.0;
    self.fEnlargeEyeStrength = 0.0;
    self.fShrinkFaceStrength = 0.0;
    self.fShrinkJawStrength = 0.0;
    self.fNarrowFaceStrength = 0.0;
    self.fRoundEyeStrength = 0.0;
    self.fContrastStrength = 0.0;
    self.fSaturationStrength = 0.0;
    self.fDehighlightStrength = 0.0;
    
    self.filterView.filterCollectionView.arrPortraitFilterModels = [self getFilterModelsByType:STEffectsTypeFilterPortrait];
    self.filterView.filterCollectionView.arrModels = self.filterView.filterCollectionView.arrPortraitFilterModels;
    
    self.filterView.filterCollectionView.arrModels[[self getBabyPinkFilterIndex]].isSelected = YES;
    self.filterView.filterCollectionView.selectedModel = self.filterView.filterCollectionView.arrModels[[self getBabyPinkFilterIndex]];
    
    self.currentSelectedFilterModel = self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex]];
    
    [self.filterView.filterCollectionView reloadData];
    self.curFilterModelPath = self.currentSelectedFilterModel.strPath;
    //    self.fFilterStrength = 0.65;
    st_mobile_gl_filter_set_param(_hFilter, ST_GL_FILTER_STRENGTH, self.fFilterStrength);
    
    [self refreshFilterCategoryState:STEffectsTypeFilterPortrait];
}

- (void)setupHandle {
    
    st_result_t iRet = ST_OK;
    
    [EAGLContext setCurrentContext:self.glContext];
    
    
    //初始化检测模块句柄
    NSString *strModelPath = [[NSBundle mainBundle] pathForResource:@"M_SenseME_Face_Video_5.3.3" ofType:@"model"];
    
    uint32_t config = ST_MOBILE_HUMAN_ACTION_DEFAULT_CONFIG_VIDEO;
    
    TIMELOG(key);
    
    iRet = st_mobile_human_action_create(strModelPath.UTF8String,
                                         config,
                                         &_hDetector);
    
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
    
    NSString *catFaceModel = [[NSBundle mainBundle] pathForResource:@"M_SenseME_CatFace_2.0.0" ofType:@"model"];
    TIMELOG(keyCat);
    iRet = st_mobile_tracker_animal_face_create(catFaceModel.UTF8String, ST_MOBILE_TRACKING_MULTI_THREAD, &_animalHandle);
    
    if (iRet != ST_OK || !_animalHandle) {
        NSLog(@"st mobile tracker animal face create failed: %d", iRet);
    }
    TIMEPRINT(keyCat, "cat handle create time:");
    
    //初始化贴纸模块句柄 , 默认开始时无贴纸 , 所以第一个路径参数传空
    TIMELOG(keySticker);
    
    iRet = st_mobile_sticker_create(&_hSticker);
    
    TIMEPRINT(keySticker, "sticker create time:");
    
    if (ST_OK != iRet || !_hSticker) {
        
        NSLog(@"st mobile sticker create failed: %d", iRet);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"贴纸SDK初始化失败 , SDK权限过期，或者与绑定包名不符" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        
        [alert show];
    } else {
        
        st_mobile_sticker_set_waiting_material_loaded(_hSticker, true);
        
        
        NSString *strAvatarModelPath = [[NSBundle mainBundle] pathForResource:@"M_SenseME_Avatar_Core_2.0.0" ofType:@"model"];
        iRet = st_mobile_sticker_load_avatar_model(_hSticker, strAvatarModelPath.UTF8String);
        if (iRet != ST_OK) {
            NSLog(@"load avatar model failed: %d", iRet);
        }
        
    }
    
    //    st_mobile_sticker_set_sound_callback_funcs(_hSticker, load_sound, play_sound, stop_sound);
    
    //初始化美颜模块句柄
    iRet = st_mobile_beautify_create(&_hBeautify);
    
    if (ST_OK != iRet || !_hBeautify) {
        
        NSLog(@"st moible beautify create failed: %d", iRet);
        
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
        
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_NARROW_FACE_STRENGTH, self.fNarrowFaceStrength);
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
        st_mobile_beautify_set_input_source(_hBeautify, ST_BEAUTIFY_VIDEO);
        st_mobile_beautify_set_body_ref_type(_hBeautify, ST_BEAUTIFY_BODY_REF_HEAD);
        //设置美体参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_BODY_WHOLE_RATIO, 0.8);
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_BODY_HEAD_RATIO, 0.8);
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_BODY_SHOULDER_RATIO, 0.8);
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_BODY_WAIST_RATIO, 0.8);
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_BODY_HIP_RATIO, 0.8);
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_BODY_LEG_RATIO, 0.8);
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_BODY_HEIGHT_RATIO, 0.8);
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

- (void)setupRecorder {
    
    _stRecoder = [[STMovieRecorder alloc] initWithURL:_recorderURL delegate:self callbackQueue:_recorderCallbackQueue];
    
    CGFloat fWidth = self.imageWidth;
    CGFloat fHeight = self.imageHeight;
    
    int numPixels = fWidth * fHeight;
    
    float bitsPerPixel;
    
    if (numPixels < (640 * 480)) {
        bitsPerPixel = 4.05;
    } else {
        bitsPerPixel = 10.1;
    }
    
    int bitsPerSecond = numPixels * bitsPerPixel;
    
    NSDictionary *compressionProperties = @{ AVVideoAverageBitRateKey : @(bitsPerSecond),
                                             AVVideoExpectedSourceFrameRateKey : @(30),
                                             AVVideoMaxKeyFrameIntervalKey : @(30) };
    
    NSDictionary *dicVideoOption = @{ AVVideoCodecKey : AVVideoCodecH264,
                                      AVVideoWidthKey : @(fWidth),
                                      AVVideoHeightKey : @(fHeight),
                                      AVVideoCompressionPropertiesKey : compressionProperties };
    
    
    if (self.outputVideoFormatDescription) {
        [_stRecoder addVideoTrackWithSourceFormatDescription:self.outputVideoFormatDescription transform:_tranform settings:dicVideoOption];
    } else {
        NSLog(@"self.outputVideoFormatDescription is NULL, can not record.");
    }
    
    if ([self checkMediaStatus:AVMediaTypeAudio] && self.outputAudioFormatDescription) {
        [_stRecoder addAudioTrackWithSourceFormatDescription:self.outputAudioFormatDescription settings:self.audioManager.audioCompressingSettings];
    }
}

- (void)setupSubviews {
    
    [self.view addSubview:self.lblSaveStatus];
    [self.view addSubview:self.triggerView];
    
    [self.view addSubview:self.specialEffectsContainerView];
    [self.view addSubview:self.beautyContainerView];
    [self.view addSubview:self.btnCompare];
    
    [self.view addSubview:self.filterStrengthView];
    
    [self.view addSubview:self.specialEffectsBtn];
    [self.view addSubview:self.beautyBtn];
    
    [self.view addSubview:self.beautySlider];
    [self.view addSubview:self.resetBtn];
    
    //    [self.view addSubview:self.lblSpeed];
    //    [self.view addSubview:self.lblCPU];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 30, 75, 45)];
    [backBtn setImage:[UIImage imageNamed:@"btn_back"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onBtnBack:) forControlEvents:UIControlEventTouchUpInside];
    _btnBack = backBtn;
    [self.view addSubview:backBtn];
    
    UIButton *startProcessingBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 61, 100, 60, 44)];
    startProcessingBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    startProcessingBtn.layer.cornerRadius = 10;
    [startProcessingBtn setTitle:@"start" forState:UIControlStateNormal];
    [startProcessingBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [startProcessingBtn addTarget:self action:@selector(startProcessingMovie:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startProcessingBtn];
    _startProcessingBtn = startProcessingBtn;
    
    _btnSaveVideoToAlbum = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 70, 50, 60, 44)];
    _btnSaveVideoToAlbum.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    [_btnSaveVideoToAlbum setTitle:@"SAVE" forState:UIControlStateNormal];
    [_btnSaveVideoToAlbum setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [_btnSaveVideoToAlbum addTarget:self action:@selector(saveVideoToAlbum:) forControlEvents:UIControlEventTouchUpInside];
    _btnSaveVideoToAlbum.hidden = YES;
    [self.view addSubview:_btnSaveVideoToAlbum];
    
    
    _progressBar = [[STPlayerControlBar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 50, SCREEN_WIDTH, 50)];
    [self.view addSubview:_progressBar];
    _progressBar.hidden = YES;
    
    AVAsset *asset = [AVAsset assetWithURL:self.videoURL];
    NSLog(@"duration: %f", CMTimeGetSeconds(asset.duration));
    
    [self.progressBar playerCurrentTime:0 totalTime:CMTimeGetSeconds(asset.duration) sliderValue:0];
    
    NSArray<AVAssetTrack *> *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    CGSize videoSize = videoTracks[0].naturalSize;
    self.imageWidth = videoSize.width;
    self.imageHeight = videoSize.height;
    
    CGAffineTransform transform = videoTracks[0].preferredTransform;
    CGFloat videoAngleInDegree = atan2(transform.b, transform.a) * 180 / M_PI;
    NSLog(@"video orientation: %f", videoAngleInDegree);
    
    CGFloat width = self.imageWidth, height = self.imageHeight;
    
    if (videoAngleInDegree == 0.0) {
        _rotateType = ST_CLOCKWISE_ROTATE_0;
        _tranform = CGAffineTransformIdentity;
    } else if (videoAngleInDegree == 90.0) {
        _rotateType = ST_CLOCKWISE_ROTATE_90;
        _tranform = CGAffineTransformMakeRotation(M_PI / 2);
        width = self.imageHeight;
        height = self.imageWidth;
    } else if (videoAngleInDegree == -90.0) {
        _rotateType = ST_CLOCKWISE_ROTATE_270;
        _tranform = CGAffineTransformMakeRotation(-M_PI / 2);
        width = self.imageHeight;
        height = self.imageWidth;
    } else {
        _rotateType = ST_CLOCKWISE_ROTATE_180;
        _tranform = CGAffineTransformMakeRotation(M_PI);
    }
    
    self.glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    EAGLContext *previewContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:self.glContext.sharegroup];
    CGRect previewRect = [self getZoomedRectWithImageWidth:width height:height inRect:self.view.bounds scaleToFit:YES];
    _previewRect = previewRect;
    self.glPreview = [[STGLPreview2 alloc] initWithFrame:previewRect context:previewContext];
    
    [self.view insertSubview:self.glPreview atIndex:0];
    
    _commonObjectContainerView = [[STCommonObjectContainerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    //    [self.view insertSubview:_commonObjectContainerView atIndex:1];
    
    [EAGLContext setCurrentContext:self.glContext];
    
    // 初始化结果纹理及纹理缓存
    CVReturn err = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, self.glContext, NULL, &_cvTextureCache);
    if (err) {
        NSLog(@"CVOpenGLESTextureCacheCreate %d" , err);
    }
    [self initResultTexture];
}

- (void)saveVideoToAlbum:(UIButton *)sender {
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    [library writeVideoAtPathToSavedPhotosAlbum:_recorderURL completionBlock:^(NSURL *assetURL, NSError *error) {
        
        self.btnSaveVideoToAlbum.enabled = NO;
        
        [[NSFileManager defaultManager] removeItemAtURL:_recorderURL error:NULL];
        
        self.lblSaveStatus.text = @"视频已存储到相册";
        [self showAnimationIfSaved:YES];
        
    }];
}

- (void)startProcessingMovie:(UIButton *)sender {
    
    [_avPlayer replaceCurrentItemWithPlayerItem:_playerItem];
    [_avPlayer.currentItem seekToTime:kCMTimeZero];
    [_avPlayer play];
    
    [self hideBeautyContainerView];
    [self hideContainerView];
    
    self.specialEffectsBtn.hidden = YES;
    self.beautyBtn.hidden = YES;
    self.progressBar.hidden = NO;
    self.btnSaveVideoToAlbum.hidden = NO;
    
    self.btnSaveVideoToAlbum.enabled = NO;
    
    self.isPlaying = YES;
    
    sender.hidden = YES;
}

- (void)prepareRecord {
    
    if (self.recordStatus == STWriterRecordingStatusIdle) {
        @synchronized(self) {
            [_stRecoder prepareToRecord];
            self.recordStatus = STWriterRecordingStatusStartingRecording;
            self.recording = YES;
        }
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

- (NSString *)getSHA1StringWithData:(NSData *)data
{
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    
    NSMutableString *strSHA1 = [NSMutableString string];
    
    for (int i = 0 ; i < CC_SHA1_DIGEST_LENGTH ; i ++) {
        
        [strSHA1 appendFormat:@"%02x" , digest[i]];
    }
    
    return strSHA1;
}

- (CGRect)getZoomedRectWithImageWidth:(int)iWidth
                               height:(int)iHeight
                               inRect:(CGRect)rect
                           scaleToFit:(BOOL)bScaleToFit
{
    CGRect rectRet = rect;
    
    float fScaleX = iWidth / CGRectGetWidth(rect);
    float fScaleY = iHeight / CGRectGetHeight(rect);
    float fScale = bScaleToFit ? fmaxf(fScaleX, fScaleY) : fminf(fScaleX, fScaleY);
    
    
    iWidth /= fScale;
    iHeight /= fScale;
    
    CGFloat fX = rect.origin.x - (iWidth - rect.size.width) / 2.0f;
    CGFloat fY = rect.origin.y - (iHeight - rect.size.height) / 2.0f;
    
    rectRet = CGRectMake(fX, fY, iWidth, iHeight);
    
    return rectRet;
}

#pragma mark - UI

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
            self.fFilterStrength = 1;
            self.lblFilterStrength.text = @"100";
            self.filterStrengthSlider.value = 1;
            
            if (self.filterView.filterCollectionView.selectedModel.modelType == STEffectsTypeFilterPortrait) {
                
                self.filterView.filterCollectionView.selectedModel.isSelected = NO;
                self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex]].isSelected = YES;
                [self.filterView.filterCollectionView reloadData];
                
            } else {
                
                self.filterStrengthView.hidden = YES;
                self.filterView.filterCollectionView.selectedModel.isSelected = NO;
                [self.filterView.filterCollectionView reloadData];
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
    
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_REDDEN_STRENGTH, self.fReddenStrength);
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_SMOOTH_STRENGTH, self.fSmoothStrength);
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, self.fEnlargeEyeStrength);
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_SHRINK_FACE_RATIO, self.fShrinkFaceStrength);
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_SHRINK_JAW_RATIO, self.fShrinkJawStrength);
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
    
    if (!self.isPlaying) {
        [self processFirstFrame:_pixelBufferCopy needOriginImage:NO];
    }
    
}

- (UISlider *)beautySlider {
    if (!_beautySlider) {
        _beautySlider = [[STBeautySlider alloc] initWithFrame:CGRectMake(40, SCREEN_HEIGHT - 260 - 40, SCREEN_WIDTH - 90, 40)];
        _beautySlider.thumbTintColor = UIColorFromRGB(0x9e4fcb);
        _beautySlider.minimumTrackTintColor = UIColorFromRGB(0x9e4fcb);
        _beautySlider.maximumTrackTintColor = [UIColor whiteColor];
        _beautySlider.minimumValue = -1;
        _beautySlider.maximumValue = 1;
        _beautySlider.value = 0;
        _beautySlider.hidden = YES;
        _beautySlider.delegate = self;
        [_beautySlider addTarget:self action:@selector(beautySliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _beautySlider;
}

- (void)beautySliderValueChanged:(UISlider *)sender {
    
    //[-1,1]->[0,1]
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
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_WHITEN_STRENGTH, self.fWhitenStrength);
            break;
        case STBeautyTypeRuddy:
            self.fReddenStrength = value1;
            model.beautyValue = value1 * 100;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_REDDEN_STRENGTH, self.fReddenStrength);
            break;
        case STBeautyTypeDermabrasion:
            self.fSmoothStrength = value1;
            model.beautyValue = value1 * 100;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_SMOOTH_STRENGTH, self.fSmoothStrength);
            break;
        case STBeautyTypeDehighlight:
            self.fDehighlightStrength = value1;
            model.beautyValue = value1 * 100;
            break;
        case STBeautyTypeShrinkFace:
            self.fShrinkFaceStrength = value1;
            model.beautyValue = value1 * 100;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_SHRINK_FACE_RATIO, self.fShrinkFaceStrength);
            break;
        case STBeautyTypeEnlargeEyes:
            self.fEnlargeEyeStrength = value1;
            model.beautyValue = value1 * 100;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, self.fEnlargeEyeStrength);
            break;
        case STBeautyTypeShrinkJaw:
            self.fShrinkJawStrength = value1;
            model.beautyValue = value1 * 100;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_SHRINK_JAW_RATIO, self.fShrinkJawStrength);
            break;
        case STBeautyTypeNarrowFace:
            self.fNarrowFaceStrength = value1;
            model.beautyValue = value1 * 100;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_NARROW_FACE_STRENGTH, self.fNarrowFaceStrength);
            break;
        case STBeautyTypeRoundEye:
            self.fRoundEyeStrength = value1;
            model.beautyValue = value1 * 100;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_ROUND_EYE_RATIO, self.fRoundEyeStrength);
            break;
        case STBeautyTypeThinFaceShape:
            self.fThinFaceShapeStrength = value1;
            model.beautyValue = value1 * 100;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_THIN_FACE_SHAPE_RATIO, self.fThinFaceShapeStrength);
            break;
        case STBeautyTypeChin:
            self.fChinStrength = value2;
            model.beautyValue = value2 * 100;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_CHIN_LENGTH_RATIO, self.fChinStrength);
            break;
        case STBeautyTypeHairLine:
            self.fHairLineStrength = value2;
            model.beautyValue = value2 * 100;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_HAIRLINE_HEIGHT_RATIO, self.fHairLineStrength);
            break;
        case STBeautyTypeNarrowNose:
            self.fNarrowNoseStrength = value1;
            model.beautyValue = value1 * 100;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_NARROW_NOSE_RATIO, self.fNarrowNoseStrength);
            break;
        case STBeautyTypeLengthNose:
            self.fLongNoseStrength = value2;
            model.beautyValue = value2 * 100;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_NOSE_LENGTH_RATIO, self.fLongNoseStrength);
            break;
        case STBeautyTypeMouthSize:
            self.fMouthStrength = value2;
            model.beautyValue = value2 * 100;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_MOUTH_SIZE_RATIO, self.fMouthStrength);
            break;
        case STBeautyTypeLengthPhiltrum:
            self.fPhiltrumStrength = value2;
            model.beautyValue = value2 * 100;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_PHILTRUM_LENGTH_RATIO, self.fPhiltrumStrength);
            break;
        case STBeautyTypeAppleMusle:
            self.fAppleMusleStrength = value1;
            model.beautyValue = value1 * 100;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_APPLE_MUSLE_RATIO, self.fAppleMusleStrength);
            break;
        case STBeautyTypeProfileRhinoplasty:
            self.fProfileRhinoplastyStrength = value1;
            model.beautyValue = value1 * 100;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_PROFILE_RHINOPLASTY_RATIO, self.fProfileRhinoplastyStrength);
            break;
        case STBeautyTypeBrightEye:
            self.fBrightEyeStrength = value1;
            model.beautyValue = value1 * 100;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_BRIGHT_EYE_RATIO, self.fBrightEyeStrength);
            break;
        case STBeautyTypeRemoveDarkCircles:
            self.fRemoveDarkCirclesStrength = value1;
            model.beautyValue = value1 * 100;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_REMOVE_DARK_CIRCLES_RATIO, self.fRemoveDarkCirclesStrength);
            break;
        case STBeautyTypeWhiteTeeth:
            self.fWhiteTeethStrength = value1;
            model.beautyValue = value1 * 100;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_WHITE_TEETH_RATIO, self.fWhiteTeethStrength);
            break;
        case STBeautyTypeEyeDistance:
            self.fEyeDistanceStrength = value2;
            model.beautyValue = value2 * 100;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, self.fEyeDistanceStrength);
            break;
        case STBeautyTypeEyeAngle:
            self.fEyeAngleStrength = value2;
            model.beautyValue = value2 * 100;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_ANGLE_RATIO, self.fEyeAngleStrength);
            break;
        case STBeautyTypeOpenCanthus:
            self.fOpenCanthusStrength = value1;
            model.beautyValue = value1 * 100;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_OPEN_CANTHUS_RATIO, self.fOpenCanthusStrength);
            break;
        case STBeautyTypeRemoveNasolabialFolds:
            self.fRemoveNasolabialFoldsStrength = value1;
            model.beautyValue = value1 * 100;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_REMOVE_NASOLABIAL_FOLDS_RATIO, self.fRemoveNasolabialFoldsStrength);
            break;
        case STBeautyTypeContrast:
            self.fContrastStrength = value1;
            model.beautyValue = value1 * 100;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_CONTRAST_STRENGTH, self.fContrastStrength);
            break;
        case STBeautyTypeSaturation:
            self.fSaturationStrength = value1;
            model.beautyValue = value1 * 100;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_SATURATION_STRENGTH, self.fSaturationStrength);
            break;
    }
    
    [self.beautyCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:model.modelIndex inSection:0]]];
    
    if (!self.isPlaying) {
        [self processFirstFrame:_pixelBufferCopy needOriginImage:NO];
    }
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

- (STTriggerView *)triggerView {
    
    if (!_triggerView) {
        
        _triggerView = [[STTriggerView alloc] init];
    }
    
    return _triggerView;
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
        
        
        [_beautyContainerView addSubview:self.beautyCollectionView];
        [_beautyContainerView addSubview:self.filterCategoryView];
        [_beautyContainerView addSubview:self.filterView];
        [_beautyContainerView addSubview:self.bmpColView];
        
        [self.arrBeautyViews addObject:self.filterCategoryView];
        [self.arrBeautyViews addObject:self.filterView];
        [self.arrBeautyViews addObject:self.beautyCollectionView];
    }
    return _beautyContainerView;
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
        rightLabel.text = @"100";
        _lblFilterStrength = rightLabel;
        [_filterStrengthView addSubview:rightLabel];
    }
    return _filterStrengthView;
}

- (STViewButton *)specialEffectsBtn {
    if (!_specialEffectsBtn) {
        
        _specialEffectsBtn = [[[NSBundle mainBundle] loadNibNamed:@"STViewButton" owner:nil options:nil] firstObject];
        [_specialEffectsBtn setExclusiveTouch:YES];
        
        UIImage *image = [UIImage imageNamed:@"btn_special_effects.png"];
        
        _specialEffectsBtn.frame = CGRectMake([self layoutWidthWithValue:143], SCREEN_HEIGHT - 50, image.size.width, 50);
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

- (UILabel *)lblSpeed {
    if (!_lblSpeed) {
        
        _lblSpeed = [[UILabel alloc] initWithFrame:CGRectMake(0, 105 ,SCREEN_WIDTH, 15)];
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

- (STScrollTitleView *)scrollTitleView {
    if (!_scrollTitleView) {
        
        STWeakSelf;
        
        _scrollTitleView = [[STScrollTitleView alloc] initWithFrame:CGRectMake(57, 0, SCREEN_WIDTH - 57, 40) normalImages:[self getNormalImages] selectedImages:[self getSelectedImages] effectsType:@[@(STEffectsTypeStickerMy), @(STEffectsTypeStickerNew), @(STEffectsTypeSticker2D), @(STEffectsTypeSticker3D), @(STEffectsTypeStickerGesture), @(STEffectsTypeStickerSegment), @(STEffectsTypeStickerFaceDeformation), @(STEffectsTypeStickerFaceChange), @(STEffectsTypeObjectTrack)] titleOnClick:^(STTitleViewItem *titleView, NSInteger index, STEffectsType type) {
            [weakSelf handleEffectsType:type];
        }];
        
        _scrollTitleView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _scrollTitleView;
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
    
    self.beautySlider.hidden = NO;
    self.curBeautyBeautyType = model.beautyType;
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
            
            self.beautySlider.value = model.beautyValue / 50.0 - 1;
            
            break;
            
            
        case STBeautyTypeChin:
        case STBeautyTypeHairLine:
        case STBeautyTypeLengthNose:
        case STBeautyTypeMouthSize:
        case STBeautyTypeLengthPhiltrum:
        case STBeautyTypeEyeAngle:
        case STBeautyTypeEyeDistance:
            
            self.beautySlider.value = model.beautyValue / 100.0;
            
            break;
    }
    
    
}


- (EffectsCollectionView *)effectsList
{
    if (!_effectsList) {
        _effectsList = [[EffectsCollectionView alloc] initWithFrame:CGRectMake(0, 41, SCREEN_WIDTH, 140)];
        [_effectsList registerNib:[UINib nibWithNibName:@"EffectsCollectionViewCell"
                                                 bundle:[NSBundle mainBundle]]
       forCellWithReuseIdentifier:@"EffectsCollectionViewCell"];
        
        __weak typeof(self) weakSelf = self;
        
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

- (STFilterView *)filterView {
    
    if (!_filterView) {
        _filterView = [[STFilterView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 41, SCREEN_WIDTH, 260)];
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
                weakSelf.filterCategoryView.frame = CGRectMake(0, weakSelf.filterCategoryView.frame.origin.y, SCREEN_WIDTH, 260);
                weakSelf.filterView.frame = CGRectMake(SCREEN_WIDTH, weakSelf.filterView.frame.origin.y, SCREEN_WIDTH, 260);
            }];
            weakSelf.filterStrengthView.hidden = YES;
        };
    }
    return _filterView;
}

- (UIView *)filterCategoryView {
    
    if (!_filterCategoryView) {
        
        _filterCategoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 41, SCREEN_WIDTH, 260)];
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
        _makeUpConf |= config;
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
        self.filterCategoryView.frame = CGRectMake(-SCREEN_WIDTH, self.filterCategoryView.frame.origin.y, SCREEN_WIDTH, 260);
        self.filterView.frame = CGRectMake(0, self.filterView.frame.origin.y, SCREEN_WIDTH, 260);
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

#pragma mark - change sticker

- (void)handleFilterChanged:(STCollectionViewDisplayModel *)model {
    
    if ([EAGLContext currentContext] != self.glContext) {
        [EAGLContext setCurrentContext:self.glContext];
    }
    
    self.currentSelectedFilterModel = model;
    
    self.lblFilterStrength.text = @"100";
    
    self.bFilter = model.index > 0;
    
    if (self.bFilter) {
        self.filterStrengthView.hidden = NO;
    } else {
        self.filterStrengthView.hidden = YES;
    }
    
    // 切换滤镜
    if (_hFilter) {
        
        // 切换滤镜不会修改强度 , 这里根据实际需求实现 , 这里重置为1.0.
        self.fFilterStrength = 1.0;
        self.filterStrengthSlider.value = 1.0;
        
        self.curFilterModelPath = model.strPath;
        [self refreshFilterCategoryState:model.modelType];
        st_result_t iRet = ST_OK;
        iRet = st_mobile_gl_filter_set_param(_hFilter, ST_GL_FILTER_STRENGTH, self.fFilterStrength);
        if (iRet != ST_OK) {
            STLog(@"st_mobile_gl_filter_set_param %d" , iRet);
        }
        
        if (!self.isPlaying) {
            [self processFirstFrame:_pixelBufferCopy needOriginImage:NO];
        }
    }
    
}

- (void)handleObjectTrackChanged:(STCollectionViewDisplayModel *)model {
    
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
            [self.triggerView showTriggerViewWithContent:triggerContent image:image];
            
            self.stickerConf = iAction;
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self processFirstFrame:_pixelBufferCopy needOriginImage:NO];
    });
    
    self.pauseOutput = NO;
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

- (void)onTapNoneSticker:(UITapGestureRecognizer *)tapGesture {
    
    self.prepareModel = nil;
    [self setMaterialModel:nil];
    
    self.objectTrackCollectionView.selectedModel.isSelected = NO;
    [self.objectTrackCollectionView reloadData];
    self.objectTrackCollectionView.selectedModel = nil;
    
    if (_hSticker) {
        self.isNullSticker = YES;
    }
    
    if (!self.isPlaying) {
        st_mobile_sticker_change_package(_hSticker, NULL, NULL);
        [self processFirstFrame:_pixelBufferCopy needOriginImage:NO];
    }
    
    if (_hTracker) {
        
        if (self.commonObjectContainerView.currentCommonObjectView) {
            
            [self.commonObjectContainerView.currentCommonObjectView removeFromSuperview];
        }
    }
    
    self.bTracker = NO;
    
    self.noneStickerImageView.highlighted = YES;
}

#pragma mark - arrays



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

- (NSArray *)getNormalImages {
    
    return @[
             [UIImage imageNamed:@"native.png"],
             [UIImage imageNamed:@"new_sticker.png"],
             [UIImage imageNamed:@"2d.png"],
             [UIImage imageNamed:@"3d.png"],
             [UIImage imageNamed:@"sticker_gesture.png"],
             [UIImage imageNamed:@"sticker_segment.png"],
             [UIImage imageNamed:@"sticker_face_deformation.png"],
             [UIImage imageNamed:@"face_painting.png"],
             [UIImage imageNamed:@"common_object_track.png"]
             ];
}

- (NSArray *)getSelectedImages {
    
    
    return @[
             [UIImage imageNamed:@"native_selected.png"],
             [UIImage imageNamed:@"new_sticker_selected.png"],
             [UIImage imageNamed:@"2d_selected.png"],
             [UIImage imageNamed:@"3d_selected.png"],
             [UIImage imageNamed:@"sticker_gesture_selected.png"],
             [UIImage imageNamed:@"sticker_segment_selected.png"],
             [UIImage imageNamed:@"sticker_face_deformation_selected.png"],
             [UIImage imageNamed:@"face_painting_selected.png"],
             [UIImage imageNamed:@"common_object_track_selected.png"]
             ];
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

#pragma mark - click events

- (void)onBtnCompareTouchDown:(UIButton *)sender {
    [sender setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.4] forState:UIControlStateNormal];
    self.isComparing = YES;
    if (!self.isPlaying) {
        [self processFirstFrame:_pixelBufferCopy needOriginImage:YES];
    }
}

- (void)onBtnCompareTouchUpInside:(UIButton *)sender {
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.isComparing = NO;
    if (!self.isPlaying) {
        [self processFirstFrame:_pixelBufferCopy needOriginImage:NO];
    }
}


- (void)clickBottomViewButton:(STViewButton *)senderView {
    
    switch (senderView.tag) {
            
        case STViewTagSpecialEffectsBtn:
            
            self.beautyBtn.userInteractionEnabled = NO;
            
            if (!self.specialEffectsContainerViewIsShow) {
                
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
                
                [self hideContainerView];
                [self beautyContainerViewAppear];
                
            } else {
                
                [self hideBeautyContainerView];
            }
            
            self.specialEffectsBtn.userInteractionEnabled = YES;
            
            break;
    }
    
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.btnSaveVideoToAlbum.enabled = YES;
    });
    
    if (self.recording) {
        self.recording = NO;
    }
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
    
    if (self.bmpColView) {
        
        [self.bmpColView backToMenu];
    }
}


#pragma mark - animations

- (void)hideContainerView {
    
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

- (void)hideBeautyViewExcept:(UIView *)view {
    
    for (UIView *beautyView in self.arrBeautyViews) {
        
        beautyView.hidden = !(view == beautyView);
    }
}

- (void)showAnimationIfSaved:(BOOL)bSaved {
    
    self.lblSaveStatus.hidden = NO;
    
    //    [self.lblSaveStatus setText:bSaved ? @"图片已保存到相册" : @"图片保存失败"];
    
    [UIView animateWithDuration:0.5 animations:^{
        
        self.lblSaveStatus.center = CGPointMake(SCREEN_WIDTH / 2.0 , 102);
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.5 delay:2
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
                             self.lblSaveStatus.center = CGPointMake(SCREEN_WIDTH / 2.0 , -44);
                         } completion:^(BOOL finished) {
                             self.lblSaveStatus.hidden = YES;
                         }];
    }];
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
    
    
    [self setupTextureWithPixelBuffer:&_cvFilterBuffer
                                    w:self.imageWidth
                                    h:self.imageHeight
                            glTexture:&_textureFilterOutput
                            cvTexture:&_cvTextureFilter];
    
    [self setupTextureWithPixelBuffer:&_cvMakeUpBuffer
                                    w:self.imageWidth
                                    h:self.imageHeight
                            glTexture:&_textureMakeUpOutput
                            cvTexture:&_cvTextureMakeUp];
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

- (BOOL)getFirstFrameTexture:(CVPixelBufferRef)pixelBuffer {
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
                                                                  &_cvFirstFrameTexture);
    
    if (!_cvTextureOrigin || kCVReturnSuccess != cvRet) {
        
        NSLog(@"CVOpenGLESTextureCacheCreateTextureFromImage %d" , cvRet);
        
        return NO;
    }
    
    _textureFirstFrame = CVOpenGLESTextureGetName(_cvFirstFrameTexture);
    glBindTexture(GL_TEXTURE_2D , _textureFirstFrame);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    return YES;
}

#pragma mark - handle filter value

- (void)filterSliderValueChanged:(UISlider *)sender {
    
    _lblFilterStrength.text = [NSString stringWithFormat:@"%d", (int)(sender.value * 100)];
    
    if (_hFilter) {
        
        st_result_t iRet = ST_OK;
        iRet = st_mobile_gl_filter_set_param(_hFilter, ST_GL_FILTER_STRENGTH, sender.value);
        
        if (ST_OK != iRet) {
            
            STLog(@"st_mobile_gl_filter_set_param %d" , iRet);
        }
    }
    if (!self.isPlaying) {
        [self processFirstFrame:_pixelBufferCopy needOriginImage:NO];
    }
}

#pragma mark - handle system notifications

- (void)appWillResignActive {
    
    self.isAppActive = NO;
    
    if (self.recording) {
        
        //        [self stopRecorder];
        
        self.recording = NO;
        
        self.filterStrengthView.hidden = self.filterStrengthViewHidden;
        self.specialEffectsBtn.hidden = NO;
        self.beautyBtn.hidden = NO;
        self.beautyContainerView.hidden = NO;
        self.specialEffectsContainerView.hidden = NO;
    }
    self.pauseOutput = YES;
    
    [self onBtnBack:_btnBack];
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

#pragma - mark -
#pragma - mark Setup Service

- (void)setupSenseArService {
    
//在线激活，建议在成功失败的回调中都检查license，失败时使用sdk缓存的license
#if USE_ONLINE_ACTIVATION
    STWeakSelf;
    [[SenseArMaterialService sharedInstance]
     authorizeWithAppID:@"6dc0af51b69247d0af4b0a676e11b5ee"
     appKey:@"e4156e4d61b040d2bcbf896c798d06e3"
     onSuccess:^{
         
         [weakSelf checkLicenseFromServer];
         
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
    [[SenseArMaterialService sharedInstance] setMaxCacheSize:120000000];
    [self fetchLists];
#endif
}

- (BOOL)checkLicenseFromServer {
    self.licenseData = [[SenseArMaterialService sharedInstance] getLicenseData];
    return [self checkActiveCodeWithData:self.licenseData];
}

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



#pragma mark -

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

- (CGFloat)layoutWidthWithValue:(CGFloat)value {
    
    return (value / 750) * SCREEN_WIDTH;
}

- (CGFloat)layoutHeightWithValue:(CGFloat)value {
    
    return (value / 1334) * SCREEN_HEIGHT;
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
                //                NSLog(@"body[%d]: (%f, %f)", j, detectResult.p_bodys[0].p_key_points[j].x, detectResult.p_bodys[0].p_key_points[j].y);
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

#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"SenseME Effects did receive memory warning!!!");
}

@end


//
//  PhotoProcessingVC.m
//  SenseMeEffects
//
//  Created by Sunshine on 22/08/2017.
//  Copyright © 2017 SenseTime. All rights reserved.
//

#import "PhotoProcessingVC.h"
#import "STParamUtil.h"
#import "STViewButton.h"
#import "STScrollTitleView.h"
#import "STCollectionView.h"
#import <CommonCrypto/CommonDigest.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <OpenGLES/ES2/glext.h>
#import "STMobileLog.h"
#import "STCommonObjectContainerView.h"
#import "STFilterView.h"
#import "STBeautySlider.h"


#import "SenseArSourceService.h"
#import "STCustomMemoryCache.h"
#import "EffectsCollectionView.h"
#import "EffectsCollectionViewCell.h"

#import "STBMPCollectionView.h"
#import "STBmpStrengthView.h"



//ST_MOBILE 请插入此头文件
#import "st_mobile_sticker.h"
#import "st_mobile_beautify.h"
#import "st_mobile_license.h"
#import "st_mobile_filter.h"
#import "st_mobile_animal.h"
#import "st_mobile_makeup.h"
//ST_MOBILE_END
#import "TestModel.h"

#define DRAW_FACE_KEY_POINTS 0
#define TEST_BODY_BEAUTY 0

typedef NS_ENUM(NSInteger, STViewTag) {
    
    STViewTagSpecialEffectsBtn = 10000,
    STViewTagBeautyBtn,
};

@interface PhotoProcessingVC () <STBeautySliderDelegate, STBMPCollectionViewDelegate, STBmpStrengthViewDelegate>
{
    st_handle_t _hSticker;  // sticker句柄
    st_handle_t _hDetector; // detector句柄
    st_handle_t _hBeautify; // beautify句柄
    st_handle_t _hFilter;   // filter句柄
    st_handle_t _animalHandle;
    st_handle_t _hBmpHandle;
    
    st_mobile_animal_face_t *_detectResult1;
}

@property (weak, nonatomic) IBOutlet UIButton *btnSaveImage;
@property (weak, nonatomic) IBOutlet UIButton *btnClose;
@property (nonatomic, readwrite, strong) UIButton *btnCompare;

@property (weak, nonatomic) IBOutlet UIImageView *processingImageView;

@property (nonatomic, readwrite, strong) UIView *bottomContainerView;
@property (nonatomic, readwrite, strong) UIView *specialEffectsContainerView;
@property (nonatomic, readwrite, strong) UIView *beautyContainerView;
@property (nonatomic, readwrite, strong) UIView *beautyShapeView;
@property (nonatomic, readwrite, strong) UIView *beautyBaseView;
@property (nonatomic, readwrite, strong) UIView *filterCategoryView;
@property (nonatomic, readwrite, strong) UIView *filterSwitchView;
@property (nonatomic, readwrite, strong) STFilterView *filterView;
@property (nonatomic, readwrite, strong) UIView *filterStrengthView;
@property (nonatomic, strong) UIView *beautyBodyView;

@property (nonatomic, readwrite, strong) UILabel *lblSaveStatus;


@property (nonatomic, readwrite, strong) UIImage *imageProcessed;

@property (nonatomic, readwrite, strong) STViewButton *specialEffectsBtn;
@property (nonatomic, readwrite, strong) STViewButton *beautyBtn;

@property (nonatomic, readwrite, strong) STScrollTitleView *specialEffectsScrollTitleView;
@property (nonatomic, strong) STScrollTitleView *beautyScrollTitleViewNew;

@property (nonatomic , strong) STCustomMemoryCache *effectsDataSource;
@property (nonatomic , strong) EffectsCollectionView *effectsList;
@property (nonatomic, readwrite, strong) STFilterCollectionView *filterCollectionView;

@property (weak, nonatomic) IBOutlet STCommonObjectContainerView *commonObjectView;

@property (nonatomic, readwrite, assign) BOOL specialEffectsContainerViewIsShow;
@property (nonatomic, readwrite, assign) BOOL beautyContainerViewIsShow;
@property (nonatomic, readwrite, assign) BOOL isComparing;

@property (nonatomic, readwrite, assign) unsigned long long iCurrentAction;
@property (nonatomic, readwrite, assign) unsigned long long makeUpConf;
@property (nonatomic, readwrite, assign) unsigned long long stickerConf;

@property (nonatomic, assign) BOOL bMakeUp;
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

@property (nonatomic, assign) float fFilterStrength;

@property (nonatomic) dispatch_queue_t thumbDownlaodQueue;
@property (nonatomic, strong) NSOperationQueue *imageLoadQueue;
@property (nonatomic , strong) STCustomMemoryCache *thumbnailCache;
@property (nonatomic , strong) NSFileManager *fManager;
@property (nonatomic , copy) NSString *strThumbnailPath;

@property (nonatomic , strong) NSArray *arrCurrentModels;
@property (nonatomic , strong) EffectsCollectionViewCellModel *prepareModel;



@property (nonatomic, readwrite, strong) NSMutableArray *arrBeautyViews;
@property (nonatomic, readwrite, strong) NSMutableArray<STViewButton *> *arrFilterCategoryViews;

@property (nonatomic, strong) NSArray<STNewBeautyCollectionViewModel *> *microSurgeryModels;
@property (nonatomic, strong) NSArray<STNewBeautyCollectionViewModel *> *baseBeautyModels;
@property (nonatomic, strong) NSArray<STNewBeautyCollectionViewModel *> *beautyShapeModels;
@property (nonatomic, strong) NSArray<STNewBeautyCollectionViewModel *> *adjustModels;
@property (nonatomic, strong) STNewBeautyCollectionView *beautyCollectionView;
@property (nonatomic, strong) STBeautySlider *beautySlider;
@property (nonatomic, assign) STEffectsType curEffectBeautyType;
@property (nonatomic, assign) STEffectsType curEffectStickerType;
@property (nonatomic, assign) STBeautyType curBeautyBeautyType;
@property (nonatomic, strong) UIButton *resetBtn;

@property (nonatomic, readwrite, strong) EAGLContext *glContext;
@property (nonatomic, readwrite, strong) CIContext *ciContext;

@property (nonatomic, readwrite, assign) float scale;
@property (nonatomic, readwrite, assign) float topMargin;
@property (nonatomic, readwrite, assign) float leftMargin;

@property (nonatomic, readwrite, strong) NSMutableArray *arrPersons;
@property (nonatomic, readwrite, strong) NSMutableArray *arrPoints;

@property (nonatomic, readwrite, strong) UISlider *filterStrengthSlider;
@property (nonatomic, readwrite, strong) UILabel *lblFilterStrength;
@property (nonatomic, readwrite, strong) STCollectionViewDisplayModel *currentSelectedFilterModel;

@property (nonatomic, readwrite, strong) UIImageView *noneStickerImageView;

@property (nonatomic, readwrite, assign) BOOL bFilter;
@property (nonatomic, strong) NSMutableArray *faceArray;
@property (nonatomic, strong) NSData *licenseData;

@property (nonatomic, assign) BOOL needDetectAnimal;


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
@property(retain,nonatomic) UIScrollView* scrollView;
#pragma mark - 表格
@property (nonatomic,strong)UITableView *tableview;
#pragma mark - 数据 （NSMutableArray 可变数组;NSArray 数组）
@property (nonatomic,strong)NSMutableArray *dataArry;


@property (nonatomic, strong) STBmpStrengthView *bmpStrenghView;

@end

@implementation PhotoProcessingVC

- (void)dealloc {
    NSLog(@"photo processing vc dealloc successful.");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addNotifications];
    
    [self setupSubviews];
    
    [self setupThumbnailCache];
    [self checkLicenseFromLocal];
    [self initMy];
    
    //    if (![self checkActiveCodeWithData:self.licenseData]) {
    //        return;
    //    }
    
    ///ST_MOBILE：初始化相关的句柄
    [self setupHandle];
    
    [self processImageAndDisplay];
    
    //    //默认选中cherry滤镜
    //    _filterView.filterCollectionView.arrModels = _filterView.filterCollectionView.arrPortraitFilterModels;
    //    [_filterView.filterCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:[self getBabyPinkFilterIndex] inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    //    _filterStrengthView.hidden = YES;
}

-(void) initMy{
    
    
    
    self.fSmoothStrength = 0.74;
    self.fReddenStrength = 0.36;
    self.fWhitenStrength = 0.02;
    self.fDehighlightStrength = 0.0;
    
    self.fEnlargeEyeStrength = 0.13;
    self.fShrinkFaceStrength = 0.11;
    self.fShrinkJawStrength = 0.10;
    self.fNarrowFaceStrength = 0.0;
    self.fRoundEyeStrength = 0.10;
    
    self.fThinFaceShapeStrength = 0.0;
    self.fChinStrength = 0.0;
    self.fHairLineStrength = 0.0;
    self.fNarrowNoseStrength = 0.0;
    self.fLongNoseStrength = 0.0;
    self.fMouthStrength = 0.0;
    self.fPhiltrumStrength = 0.0;
    
    self.fContrastStrength = 0.0;
    self.fSaturationStrength = 0.0;
    
    self.fFilterStrength = 0.65;
    
    self.bFilter = NO;
    self.needDetectAnimal = NO;
    
    self.curEffectBeautyType = STEffectsTypeBeautyBase;
    
    
    TestModel * m0 =[[TestModel alloc]init];
    m0.name = @"原图";
    m0.arr=@[@0.0f,@0.0f,@0.0f ,@0.0f    ,@0.0f,    @0.0f    ,@0.0f    ,@0.0f ,@0.0f,@0.0f   , @0.0f   ,@0.0f    ,@0.0f   , @0.0f    ,@0.0f    ,@0.0f    ,@0.0f   ,@ 0.0f];
    
    TestModel * m1 =[[TestModel alloc]init];
    m1.name = @"幼幼脸男";
    m1.arr=@[@0.0f,@0.0f,@0.69f ,@0.0f    ,@0.54f,    @0.0f    ,@0.18f    ,@1.0f ,@1.0f,@0.0f   , @-0.53f   ,@0.0f    ,@0.36f   , @0.0f    ,@1.0f    ,@0.0f    ,@0.0f   ,@ 0.0f];
    TestModel * m2 =[[TestModel alloc]init];
    m2.name = @"幼幼脸女";
    m2.arr=@[ @0.0f,    @0.0f    ,@0.0f,    @0.0f     ,@0.35f ,@0.0f    ,@-0.87f    ,@1.0f    ,@1.0f    ,@0.0f    ,@-0.76f    ,@0.59   ,@1.0f    ,@0.0f    ,@0.72f    ,@0.0f    ,@0.0f    ,@1.0f];
    TestModel * m3 =[[TestModel alloc]init];
    m3.name = @"网红脸男";
    m3.arr=@[@0.29f,@0.10f,@0.0f,@0.74f,@0.45f,@0.41f,@0.24f,@0.0f,@1.0f,@0.22f,@0.97f,@-0.62f,@0.12f,@0.0f,@0.0f,@0.45f,@1.0f,@1.0f];
    TestModel * m4 =[[TestModel alloc]init];
    m4.name = @"网红脸女";
    m4.arr=@[@0.50f,@0.53f,@0.92f,@0.20f,@0.29f,@0.27f,@-0.15f,@0.12f,@1.0f,@0.35f,@-0.36f,@0.33f,@0.37f,@0.0f,@0.31f,@1.0f,@1.0f,@1.0f];
    TestModel * m5 =[[TestModel alloc]init];
    m5.name = @"日系脸男";
    m5.arr=@[@0.0f,@0.0f,@0.30f,@0.0f,@0.0f,@0.0f,@-1.0f,@-0.56f,@0.0f,@0.0f,@1.0f,@-0.50f,@1.0f,@0.0f,@-1.0f,@0.83f,@0.0f,@0.0f];
    TestModel * m6 =[[TestModel alloc]init];
    m6.name = @"日系脸女";
    m6.arr=@[@0.0f,@0.0f,@0.64f,@0.0f,@0.13f,@0.0f,@-0.59f,@0.46f,@1.0f,@0.0f,@0.0f,@0.69f,@0.51f,@0.0f,@1.0f,@0.0f,@0.0f,@0.49f];
    TestModel * m7 =[[TestModel alloc]init];
    m7.name = @"变年轻男";
    m7.arr=@[@0.0f,@0.31f,@0.58f,@0.0f,@0.14f,@0.0f,@-0.51f,@-1.0f,@1.0f,@0.0f,@0.0f,@0.0f,@0.68f,@0.0f,@0.0f,@0.0f,@1.0f,@1.0f];
    TestModel * m8 =[[TestModel alloc]init];
    m8.name = @"变年轻女";
    m8.arr=@[@0.0f,@0.27f,@0.13f,@0.0f,@0.0f,@0.0f,@0.15f,@0.0f,@1.0f,@0.13f,@-0.03f,@0.61f,@1.0f,@0.56f,@0.36f,@0.0f,@1.0f,@1.0f];
    [self.dataArry addObject:m0];
    [self.dataArry addObject:m1];
    [self.dataArry addObject:m2];
    [self.dataArry addObject:m3];
    [self.dataArry addObject:m4];
    [self.dataArry addObject:m5];
    [self.dataArry addObject:m6];
    [self.dataArry addObject:m7];
    [self.dataArry addObject:m8];
    
    
    CGFloat vcViewWidth = self.view.frame.size.width;
    CGFloat vcViewHeight = self.view.frame.size.height;
    
    //创建UIScrollView
    _scrollView = [[UIScrollView alloc] init];
    //设置UIScrollView的位置和宽高为控制器View的宽高
    _scrollView.frame = CGRectMake(0, vcViewHeight-200, vcViewWidth, 100);
    //设置画布大小，一般比frame大，这里设置横向能拖动4张图片的范围
    _scrollView.contentSize = CGSizeMake(110 * self.dataArry.count, 100);
    //隐藏横向滚动条
    _scrollView.showsHorizontalScrollIndicator = NO;
    //隐藏竖向滚动条
    _scrollView.showsVerticalScrollIndicator = NO;
    for(int i = 0; i < self.dataArry.count; i++) {
        UIButton* button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(i*110, 0, 100, 100);
        // 按钮的正常状态
        [button setTitle:[self.dataArry[i] name] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor redColor];
        [button addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        
        [_scrollView addSubview:button];
    }
//    NSString* imgName = @"333";
//    UIImage* img = [UIImage imageNamed:imgName];
//    UIImageView* imgView = [[UIImageView alloc] initWithImage:img];
//    imgView.frame = CGRectMake(110 * 5, 0, 100, 100);
//    [_scrollView addSubview:imgView];
    [self.view addSubview:_scrollView];//添加表格到视图
    [self.view bringSubviewToFront:_scrollView];
    
}

// 参数为调用此函数按钮对象本身
-(void) clickButton:(UIButton*) btn {
    NSLog([NSString stringWithFormat:@"INDEXXX  %d",btn.tag]);
    [self setParams:[self.dataArry[btn.tag] arr]];
}

-(NSMutableArray *)dataArry{
    if(_dataArry == nil){
        _dataArry = [NSMutableArray array];//初始化数据
    }
    return _dataArry;
}
- (void)viewDidDisappear:(BOOL)animated
{
    [self resetBmp];
}

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
}
- (void)setupHandle {
    st_result_t iRet = ST_OK;
    
    // 设置SDK OpenGL 环境 , 只有在正确的 OpenGL 环境下 SDK 才会被正确初始化 .
    self.glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    self.ciContext = [CIContext contextWithEAGLContext:self.glContext
                                               options:@{kCIContextWorkingColorSpace : [NSNull null]}];
    
    //初始化检测模块句柄
    NSString *strModelPath = [[NSBundle mainBundle] pathForResource:@"M_SenseME_Face_Video_5.3.3" ofType:@"model"];
    
    uint32_t config = ST_MOBILE_HUMAN_ACTION_DEFAULT_CONFIG_IMAGE;
    
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
    TIMEPRINT(keyCat, "cat handle create time:")
    
    //初始化贴纸模块句柄 , 默认开始时无贴纸 , 所以第一个路径参数传空
    TIMELOG(keySticker);
    
    iRet = st_mobile_sticker_create(&_hSticker);
    
    TIMEPRINT(keySticker, "sticker create time:");
    
    if (ST_OK != iRet || !_hSticker) {
        
        NSLog(@"st mobile sticker create failed: %d", iRet);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"贴纸SDK初始化失败 , SDK权限过期，或者与绑定包名不符" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        
        [alert show];
        
    } else {
        
        iRet = st_mobile_sticker_set_param_bool(_hSticker, -1, ST_STICKER_PARAM_WAIT_MATERIAL_LOADED_BOOL, true);
        
        if (iRet != ST_OK) {
            NSLog(@"st_mobile_sticker_set_waiting_material_loaded failed: %d", iRet);
        }
        
        iRet = st_mobile_sticker_set_param_int(_hSticker, -1, ST_STICKER_PARAM_MAX_IMAGE_MEMORY_INT, 30);
        
        if (iRet != ST_OK) {
            NSLog(@"st_mobile_sticker_set_max_imgmem failed: %d", iRet);
        }
        
        NSString *strAvatarModelPath = [[NSBundle mainBundle] pathForResource:@"M_SenseME_Avatar_Core_2.0.0" ofType:@"model"];
        iRet = st_mobile_sticker_load_avatar_model(_hSticker, strAvatarModelPath.UTF8String);
        if (iRet != ST_OK) {
            NSLog(@"load avatar model failed: %d", iRet);
        }
        
        //声音贴纸回调，图片版可以不设置
        //st_mobile_sticker_set_sound_callback_funcs(_hSticker, load_sound_pic, play_sound_pic, stop_sound_pic);
    }
    
    //初始化美颜模块句柄
    iRet = st_mobile_beautify_create(&_hBeautify);
    
    if (ST_OK != iRet || !_hBeautify) {
        
        NSLog(@"st mobile beautify create failed: %d", iRet);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"美颜SDK初始化失败，可能是模型路径错误，SDK权限过期，与绑定包名不符" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        
        [alert show];
    } else {
        // 设置默认红润参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_REDDEN_STRENGTH, self.fReddenStrength);
        
        // 设置默认磨皮参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_SMOOTH_STRENGTH, self.fSmoothStrength);
        
        // 设置默认大眼参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, self.fEnlargeEyeStrength);
        
        // 设置默认瘦脸参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_SHRINK_FACE_RATIO, self.fShrinkFaceStrength);
        
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_NARROW_FACE_STRENGTH, self.fNarrowFaceStrength);
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_ROUND_EYE_RATIO, self.fRoundEyeStrength);
        
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
    
    // 初始化滤镜句柄
    iRet = st_mobile_gl_filter_create(&_hFilter);
    
    if (ST_OK != iRet || !_hFilter) {
        
        NSLog(@"st mobile gl filter create failed: %d", iRet);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"滤镜SDK初始化失败，可能是SDK权限过期或与绑定包名不符" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        
        [alert show];
    }
    
    //create beautyMakeUp handle
    iRet = st_mobile_makeup_create(&_hBmpHandle);
    
    if (ST_OK != iRet || !_hBmpHandle) {
        
        NSLog(@"st mobile object makeup create failed: %d", iRet);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"通用物体跟踪SDK初始化失败，可能是SDK权限过期或与绑定包名不符" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        
        [alert show];
    }
}

-(void) setParams:(NSArray*)arr{
    
    NSLog([NSString stringWithFormat:@"VALUEE  %f %f %f %f %f %f %f ",[arr[0] floatValue]
           ,[arr[1] floatValue]
                      ,[arr[2] floatValue]
                      ,[arr[3] floatValue]
                      ,[arr[4] floatValue]
                      ,[arr[5] floatValue]           ,[arr[7] floatValue]
                      ,[arr[6] floatValue]
           
           
           ]);
    
    // 设置默认瘦脸参数
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_SHRINK_FACE_RATIO,  [arr[0] floatValue]);
    // 设置默认大眼参数
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, [arr[1] floatValue]);
    // 设置小脸参数
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_SHRINK_JAW_RATIO, [arr[2] floatValue]);
    //脸
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_NARROW_FACE_STRENGTH, [arr[3] floatValue]);
    
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_ROUND_EYE_RATIO, [arr[4] floatValue]);
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_SHRINK_FACE_RATIO, [arr[5] floatValue]);
    
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_CHIN_LENGTH_RATIO, [arr[6] floatValue]);
    
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_HAIRLINE_HEIGHT_RATIO, [arr[7] floatValue]);
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_APPLE_MUSLE_RATIO, [arr[8] floatValue]);
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_NARROW_NOSE_RATIO, [arr[9] floatValue]);
    
    
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_NOSE_LENGTH_RATIO, [arr[10] floatValue]);
    
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_MOUTH_SIZE_RATIO, [arr[11] floatValue]);
    
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_PHILTRUM_LENGTH_RATIO, [arr[12] floatValue]);
    
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, [arr[13] floatValue]);
    
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_ANGLE_RATIO, [arr[14] floatValue]);
    
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_OPEN_CANTHUS_RATIO, [arr[15] floatValue]);
    
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_REMOVE_DARK_CIRCLES_RATIO, [arr[16] floatValue]);
    
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_REMOVE_NASOLABIAL_FOLDS_RATIO, [arr[17] floatValue]);
    [self processImageAndDisplay];
}

- (void)processImageAndDisplay {
    
    if ([EAGLContext currentContext] != self.glContext) {
        [EAGLContext setCurrentContext:self.glContext];
    }
    
    self.view.userInteractionEnabled = NO;
    
    int iWidth = self.imageOriginal.size.width;
    int iHeight= self.imageOriginal.size.height;
    
    _scale = fmaxf(iWidth / CGRectGetWidth(self.processingImageView.frame), iHeight / CGRectGetHeight(self.processingImageView.frame));
    _topMargin = (SCREEN_HEIGHT - iHeight / _scale) / 2;
    _leftMargin = (SCREEN_WIDTH - iWidth / _scale) / 2;
    
    GLuint textureResult = [self processImageAndReturnTexture];
    CGImageRef cgImage = [self getCGImageWithTexture:textureResult width:self.imageOriginal.size.width height:self.imageOriginal.size.height];
    UIImage *imageResult = [UIImage imageWithCGImage:cgImage];
    
    self.imageProcessed = imageResult;
    self.processingImageView.image = self.imageProcessed;
    
    CGImageRelease(cgImage);
    
    glDeleteTextures(1, &textureResult);
    
    self.view.userInteractionEnabled = YES;
}

static void activeAndBindTexture(GLenum textureActive, GLuint *textureBind, Byte *sourceImage, GLenum sourceFormat, GLsizei iWidth, GLsizei iHeight) {
    
    glActiveTexture(textureActive);
    glBindTexture(GL_TEXTURE_2D, *textureBind);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, iWidth, iHeight, 0, sourceFormat, GL_UNSIGNED_BYTE, sourceImage);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glFlush();
}

- (GLuint)processImageAndReturnTexture
{
    TIMELOG(frameCostKey);
    if (self.imageOriginal) {
        
        if (UIImageOrientationUp != self.imageOriginal.imageOrientation) {
            
            UIGraphicsBeginImageContext(self.imageOriginal.size);
            [self.imageOriginal drawInRect:CGRectMake(0, 0, self.imageOriginal.size.width, self.imageOriginal.size.height)];
            self.imageOriginal = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
    }
    
    //    double dCost = 0.0;
    //    double dStart = CFAbsoluteTimeGetCurrent();
    
    unsigned char * pBGRAImageIn = malloc(sizeof(unsigned char) * self.imageOriginal.size.width * self.imageOriginal.size.height * 4);
    
    //获取图像数据
    [self convertUIImage:self.imageOriginal toBGRABytes:pBGRAImageIn];
    
    int iBytesPerRow = self.imageOriginal.size.width * 4;
    int iWidth = self.imageOriginal.size.width;
    int iHeight = self.imageOriginal.size.height;
    
    st_result_t iRet = ST_OK;
    st_mobile_human_action_t detectResult;
    memset(&detectResult, 0, sizeof(st_mobile_human_action_t));
    _faceArray = [NSMutableArray array];
    
    // 人脸信息检测
    if (_hDetector) {
        
        BOOL needFaceDetection = (self.fEnlargeEyeStrength != 0 || self.fShrinkFaceStrength != 0 || self.fShrinkJawStrength != 0 || self.fThinFaceShapeStrength != 0 || self.fNarrowFaceStrength != 0 || self.fRoundEyeStrength != 0 || self.fChinStrength != 0 || self.fHairLineStrength != 0 || self.fNarrowNoseStrength != 0 || self.fLongNoseStrength != 0 || self.fMouthStrength != 0 || self.fPhiltrumStrength != 0 || self.fEyeDistanceStrength != 0 || self.fEyeAngleStrength != 0 || self.fOpenCanthusStrength != 0 || self.fProfileRhinoplastyStrength != 0 || self.fBrightEyeStrength != 0 || self.fRemoveDarkCirclesStrength != 0 || self.fRemoveNasolabialFoldsStrength != 0 || self.fWhiteTeethStrength != 0 || self.fAppleMusleStrength != 0) && _hBeautify;
        
        if (needFaceDetection) {
            
            self.iCurrentAction = ST_MOBILE_FACE_DETECT | self.makeUpConf | self.stickerConf;
            
            //            NSLog(@"self.iCurrentAction = %llx",self.iCurrentAction);
        } else {
            
            self.iCurrentAction = self.makeUpConf | self.stickerConf;
            
        }
#if TEST_BODY_BEAUTY
        self.iCurrentAction |= ST_MOBILE_BODY_KEYPOINTS | ST_MOBILE_BODY_CONTOUR;
#endif
        
        if (self.iCurrentAction > 0) {
            
            _arrPoints = [NSMutableArray array];
            _arrPersons = [NSMutableArray array];
            
            TIMELOG(keyDetect);
            
            iRet = st_mobile_human_action_detect(_hDetector, pBGRAImageIn, ST_PIX_FMT_BGRA8888, iWidth, iHeight, iBytesPerRow, ST_CLOCKWISE_ROTATE_0, self.iCurrentAction, &detectResult);
            
            TIMEPRINT(keyDetect, "st_mobile_human_action_detect time:");
            
#if DRAW_FACE_KEY_POINTS
            if (detectResult.p_bodys && detectResult.body_count > 0) {
                NSLog(@"body action: %llx", detectResult.p_bodys[0].body_action);
            }
#endif
            
            if(iRet != ST_OK) {
                
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
    
    GLuint textureOriginInput = 0;
    GLuint textureBeautifyOutput = 0;
    GLuint textureStickerOutput = 0;
    GLuint textureFilterOutput = 0;
    GLuint textureMakeUpOutput = 0;
    
    GLuint textureResult = textureOriginInput;
    
    // 配置原图纹理
    glGenTextures(1, &textureOriginInput);
    activeAndBindTexture(GL_TEXTURE1, &textureOriginInput, pBGRAImageIn, GL_BGRA, iWidth, iHeight);
    
    textureResult = textureOriginInput;
    
    ///ST_MOBILE 以下为美颜部分
    if (_hBeautify) {
        
        // 配置美颜输出纹理
        glGenTextures(1, &textureBeautifyOutput);
        activeAndBindTexture(GL_TEXTURE2, &textureBeautifyOutput, NULL, GL_RGBA, iWidth, iHeight);
        
        TIMELOG(keyBeautify);
        
        iRet = st_mobile_beautify_process_texture(_hBeautify, textureOriginInput, iWidth, iHeight, ST_CLOCKWISE_ROTATE_0, &detectResult, textureBeautifyOutput, &detectResult);
        
        TIMEPRINT(keyBeautify, "st_mobile_beautify_process_texture time:");
        
        if (ST_OK != iRet) {
            
            STLog(@"st_mobile_beautify_process_texture failed %d" , iRet);
            
        }
        
        textureResult = textureBeautifyOutput;
    }
    
#if DRAW_FACE_KEY_POINTS
    [self drawKeyPoints:detectResult];
#endif
    
    //makeup
    if (_hBmpHandle) {
        
        glGenTextures(1, &textureMakeUpOutput);
        activeAndBindTexture(GL_TEXTURE5, &textureMakeUpOutput, NULL, GL_RGBA, iWidth, iHeight);
        st_mobile_makeup_prepare(_hBmpHandle, pBGRAImageIn,ST_PIX_FMT_BGRA8888, iWidth, iHeight, iBytesPerRow, &detectResult);
        iRet = st_mobile_makeup_process_texture(_hBmpHandle, textureResult, iWidth, iHeight, ST_CLOCKWISE_ROTATE_0, &detectResult, textureMakeUpOutput);
        if (iRet != ST_OK) {
            NSLog(@"st_mobile_makeup_process_texture failed: %d", iRet);
        } else {
            textureResult = textureMakeUpOutput;
        }
        
    }
    
    ///ST_MOBILE 以下为贴纸部分
    if (_hSticker) {
        
        // 配置贴纸输出纹理
        glGenTextures(1, &textureStickerOutput);
        activeAndBindTexture(GL_TEXTURE3, &textureStickerOutput, NULL, GL_RGBA, iWidth, iHeight);
        
        TIMELOG(stickerProcessKey);
        
        //        iRet = st_mobile_sticker_process_texture(_hSticker, textureResult, iWidth, iHeight, ST_CLOCKWISE_ROTATE_0, ST_CLOCKWISE_ROTATE_0, false, &detectResult, NULL, textureStickerOutput);
        iRet = st_mobile_sticker_process_texture_both(_hSticker, textureResult, iWidth, iHeight, ST_CLOCKWISE_ROTATE_0, ST_CLOCKWISE_ROTATE_0, false, &detectResult, NULL, _detectResult1, catFaceCount, textureStickerOutput);
        
        TIMEPRINT(stickerProcessKey, "st_mobile_sticker_process_texture time:");
        
        if (ST_OK != iRet) {
            
            STLog(@"st_mobile_sticker_process_texture %d" , iRet);
            
        }
        
        textureResult = textureStickerOutput;
    }
    
    
    ///ST_MOBILE 以下为滤镜部分
    if (_hFilter && self.bFilter) {
        
        // 配置滤镜输出纹理
        glGenTextures(1, &textureFilterOutput);
        activeAndBindTexture(GL_TEXTURE3, &textureFilterOutput, NULL, GL_RGBA, iWidth, iHeight);
        
        TIMELOG(keyFilter);
        
        iRet = st_mobile_gl_filter_process_texture(_hFilter, textureResult, iWidth, iHeight, textureFilterOutput);
        
        if (ST_OK != iRet) {
            
            STLog(@"st_mobile_gl_filter_process_texture %d" , iRet);
            
        }
        
        textureResult = textureFilterOutput;
        
        TIMEPRINT(keyFilter, "st_mobile_gl_filter_process_texture time:");
    }
    
    
    if (pBGRAImageIn) {
        free(pBGRAImageIn);
    }
    
    if (textureResult != textureOriginInput) {
        glDeleteTextures(1, &textureOriginInput);
    }
    
    if (textureResult != textureBeautifyOutput) {
        glDeleteTextures(1, &textureBeautifyOutput);
    }
    
    if (textureResult != textureStickerOutput) {
        glDeleteTextures(1, &textureStickerOutput);
    }
    
    if (textureResult != textureFilterOutput) {
        glDeleteTextures(1, &textureFilterOutput);
    }
    
    if (textureResult != textureMakeUpOutput) {
        glDeleteTextures(1, &textureMakeUpOutput);
    }
    
    //    dCost = CFAbsoluteTimeGetCurrent() - dStart;
    //    [self.lblSpeed setText:[NSString stringWithFormat:@"单帧耗时: %.0fms" ,dCost * 1000.0]];
    
    TIMEPRINT(frameCostKey, "every frame cost time");
    
    return textureResult;
}

- (void)convertUIImage:(UIImage *)uiImage toBGRABytes:(unsigned char *)pImage {
    
    CGImageRef cgImage = [uiImage CGImage];
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
    int iWidth = uiImage.size.width;
    int iHeight = uiImage.size.height;
    int iBytesPerPixel = 4;
    int iBytesPerRow = iBytesPerPixel * iWidth;
    int iBitsPerComponent = 8;
    
    CGContextRef context = CGBitmapContextCreate(pImage,
                                                 iWidth,
                                                 iHeight,
                                                 iBitsPerComponent,
                                                 iBytesPerRow,
                                                 colorspace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst
                                                 );
    if (!context) {
        CGColorSpaceRelease(colorspace);
        return;
    }
    
    CGRect rect = CGRectMake(0 , 0 , iWidth , iHeight);
    CGContextDrawImage(context , rect ,cgImage);
    CGColorSpaceRelease(colorspace);
    CGContextRelease(context);
}

- (CGImageRef)getCGImageWithTexture:(GLuint)iTexture width:(int)iWidth height:(int)iHeight {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CIImage *ciImage = [CIImage imageWithTexture:iTexture size:CGSizeMake(iWidth, iHeight) flipped:YES colorSpace:colorSpace];
    
    CGImageRef cgImage = [self.ciContext createCGImage:ciImage fromRect:CGRectMake(0, 0, iWidth, iHeight)];
    
    CGColorSpaceRelease(colorSpace);
    
    return cgImage;
}

- (void)releaseResources {
    
    if ([EAGLContext currentContext] != self.glContext) {
        
        [EAGLContext setCurrentContext:self.glContext];
    }
    
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
    
    if (_hFilter) {
        
        st_mobile_gl_filter_destroy(_hFilter);
        _hFilter = NULL;
    }
    
    if (_hBmpHandle) {
        st_mobile_makeup_destroy(_hBmpHandle);
        _hBmpHandle = NULL;
    }
    
    [EAGLContext setCurrentContext:nil];
}

#pragma mark - UI

- (void)setupSubviews {
    
    self.btnSaveImage.layer.cornerRadius = 17;
    self.btnSaveImage.layer.borderColor = [UIColor blackColor].CGColor;
    self.btnSaveImage.layer.borderWidth = 2;
    self.btnSaveImage.backgroundColor = [UIColor whiteColor];
    
    self.processingImageView.frame = [UIScreen mainScreen].bounds;
    self.processingImageView.image = _imageOriginal;
    self.processingImageView.backgroundColor = [UIColor clearColor];
    
    //    [self.view addSubview:self.specialEffectsContainerView];
//        [self.view addSubview:self.beautyContainerView];
    //
    //    [self.view addSubview:self.filterStrengthView];
    //
    //    [self.bottomContainerView addSubview:self.specialEffectsBtn];
    //    [self.bottomContainerView addSubview:self.beautyBtn];
    //    [self.view addSubview:self.bottomContainerView];
    //
    //    [self.view addSubview:self.btnCompare];
    [self.view addSubview:self.lblSaveStatus];
    //    [self.view addSubview:self.beautySlider];
    
    [self.view addSubview:self.resetBtn];
}

#pragma mark - notifications

- (void)appWillResignActive {
    [self onBtnCompareTouchUpInside:self.btnCompare];
}

#pragma mark - btn action

- (IBAction)onBtnClose:(id)sender {
    
    [self releaseResources];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onBtnSaveImage:(id)sender {
    
    [self.btnClose setEnabled:NO];
    [self.btnSaveImage setEnabled:NO];
    
    if (self.imageProcessed.CGImage) {
        
        //保存图片
        ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [assetLibrary writeImageToSavedPhotosAlbum:self.imageProcessed.CGImage
                                           orientation:ALAssetOrientationUp
                                       completionBlock:^(NSURL *assetURL, NSError *error) {
                
                [self showAnimationIfSaved:error == nil];
            }];
        });
    }else{
        
        [self showAnimationIfSaved:NO];
    }
    
}

- (void)showAnimationIfSaved:(BOOL)bSaved {
    
    self.btnSaveImage.enabled = NO;
    self.btnClose.enabled = NO;
    
    self.lblSaveStatus.hidden = NO;
    
    [self.lblSaveStatus setText:bSaved ? @"图片已保存到相册" : @"图片保存失败"];
    
    [UIView animateWithDuration:0.2 animations:^{
        
        self.lblSaveStatus.center = CGPointMake(SCREEN_WIDTH / 2.0 , 102);
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.2 delay:2
                            options:UIViewAnimationOptionTransitionNone
                         animations:^{
            
            self.lblSaveStatus.center = CGPointMake(SCREEN_WIDTH / 2.0 , -44);
            
        } completion:^(BOOL finished) {
            
            self.lblSaveStatus.hidden = YES;
            
            self.btnClose.enabled = YES;
            self.btnSaveImage.enabled = YES;
        }];
    }];
}

#pragma mark - UI lazy load

- (UIView *)bottomContainerView {
    
    if (!_bottomContainerView) {
        
        _bottomContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 50, SCREEN_WIDTH, 50)];
        _bottomContainerView.backgroundColor = [UIColor clearColor];
    }
    return _bottomContainerView;
}

- (STViewButton *)specialEffectsBtn {
    
    if (!_specialEffectsBtn) {
        
        _specialEffectsBtn = [[[NSBundle mainBundle] loadNibNamed:@"STViewButton" owner:nil options:nil] firstObject];
        [_specialEffectsBtn setExclusiveTouch:YES];
        _specialEffectsBtn.backgroundColor = [UIColor clearColor];
        _specialEffectsBtn.frame = CGRectMake(SCREEN_WIDTH / 6, 0, SCREEN_WIDTH / 6, 50);
        _specialEffectsBtn.imageView.image = [UIImage imageNamed:@"btn_special_effects.png"];
        _specialEffectsBtn.imageView.highlightedImage = [UIImage imageNamed:@"btn_special_effects_selected.png"];
        _specialEffectsBtn.titleLabel.textColor = UIColorFromRGB(0xffffff);
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
        _beautyBtn.backgroundColor = [UIColor clearColor];
        _beautyBtn.frame = CGRectMake(SCREEN_WIDTH / 3 * 2, 0, SCREEN_WIDTH / 6, 50);
        _beautyBtn.imageView.image = [UIImage imageNamed:@"btn_beauty.png"];
        _beautyBtn.imageView.highlightedImage = [UIImage imageNamed:@"btn_beauty_selected.png"];
        _beautyBtn.titleLabel.textColor = UIColorFromRGB(0xffffff);
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
        imageView.highlighted = YES;
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
        [_specialEffectsContainerView addSubview:self.specialEffectsScrollTitleView];
        [_specialEffectsContainerView addSubview:self.effectsList];
        
        UIView *blankView = [[UIView alloc] initWithFrame:CGRectMake(0, 181, SCREEN_WIDTH, 50)];
        blankView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        [_specialEffectsContainerView addSubview:blankView];
    }
    return _specialEffectsContainerView;
}

- (STScrollTitleView *)specialEffectsScrollTitleView {
    if (!_specialEffectsScrollTitleView) {
        
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
            @(STEffectsTypeStickerParticle)
        ];
        
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
            [UIImage imageNamed:@"particle_effect.png"]
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
            [UIImage imageNamed:@"particle_effect_selected.png"]
        ];
        
        _specialEffectsScrollTitleView = [[STScrollTitleView alloc] initWithFrame:CGRectMake(57, 0, SCREEN_WIDTH - 57, 40) normalImages:normalImages selectedImages:selectedImages effectsType:stickerTypeArray titleOnClick:^(STTitleViewItem *titleView, NSInteger index, STEffectsType type) {
            
            [weakSelf handleEffectsType:type];
        }];
        
        _specialEffectsScrollTitleView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    }
    return _specialEffectsScrollTitleView;
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
    
    
    //    self.beautySlider.value = model.beautyValue / 100.0;
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
    [self processImageAndDisplay];
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
    
    [self processImageAndDisplay];
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
        default:
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
    
    self.filterStrengthView.hidden = !(self.currentSelectedFilterModel.modelType == recognizer.view.tag);
    
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

- (UIView *)filterStrengthView {
    
    if (!_filterStrengthView) {
        
        //        _filterStrengthView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 260 - 35.5, SCREEN_WIDTH, 35.5)];
        //        _filterStrengthView.backgroundColor = [UIColor clearColor];
        //        _filterStrengthView.hidden = YES;
        //
        //        UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 10, 35.5)];
        //        leftLabel.textColor = [UIColor whiteColor];
        //        leftLabel.font = [UIFont systemFontOfSize:11];
        //        leftLabel.text = @"0";
        //        [_filterStrengthView addSubview:leftLabel];
        //
        //        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(40, 0, SCREEN_WIDTH - 90, 35.5)];
        //        slider.thumbTintColor = UIColorFromRGB(0x9e4fcb);
        //        slider.minimumTrackTintColor = UIColorFromRGB(0x9e4fcb);
        //        slider.maximumTrackTintColor = [UIColor whiteColor];
        //        slider.value = 1;
        //        [slider addTarget:self action:@selector(filterSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        //        _filterStrengthSlider = slider;
        //        [_filterStrengthView addSubview:slider];
        //
        //        UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 40, 0, 20, 35.5)];
        //        rightLabel.textColor = [UIColor whiteColor];
        //        rightLabel.font = [UIFont systemFontOfSize:11];
        //        rightLabel.text = [NSString stringWithFormat:@"%d", (int)(self.fFilterStrength * 100)];
        //        _lblFilterStrength = rightLabel;
        //        [_filterStrengthView addSubview:rightLabel];
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
        _beautySlider.value = 0;
        _beautySlider.hidden = YES;
        _beautySlider.delegate = self;
        [_beautySlider addTarget:self action:@selector(beautySliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _beautySlider;
}

- (void)beautySliderValueChanged:(UISlider *)sender {
    
    //[-1,1] -> [0,1]
    float value1 = (sender.value + 1) / 2;
    
    //[-1, 1]
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
    [self processImageAndDisplay];
}

- (UIButton *)resetBtn {
    if (!_resetBtn) {
        
        _resetBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, SCREEN_HEIGHT - 50, 100, 30)];
        
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
                self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex]].isSelected = YES;
            }
            
            self.currentSelectedFilterModel = self.filterView.filterCollectionView.arrPortraitFilterModels[[self getBabyPinkFilterIndex]];
            self.filterView.filterCollectionView.selectedModel = self.currentSelectedFilterModel;
            [EAGLContext setCurrentContext:self.glContext];
            st_mobile_gl_filter_set_style(_hFilter, self.currentSelectedFilterModel.strPath.UTF8String);
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
    
    [self processImageAndDisplay];
}


- (UIButton *)btnCompare {
    
    if (!_btnCompare) {
        
        _btnCompare = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnCompare.frame = CGRectMake(SCREEN_WIDTH - 80, SCREEN_HEIGHT - 100, 70, 35);
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

- (NSMutableArray *)arrFilterCategoryViews {
    
    if (!_arrFilterCategoryViews) {
        
        _arrFilterCategoryViews = [NSMutableArray array];
    }
    return _arrFilterCategoryViews;
}


- (NSMutableArray *)arrBeautyViews {
    if (!_arrBeautyViews) {
        _arrBeautyViews = [NSMutableArray array];
    }
    return _arrBeautyViews;
}

- (NSMutableArray *)arrPersons {
    
    if (!_arrPersons) {
        _arrPersons = [NSMutableArray array];
    }
    return _arrPersons;
}

- (NSMutableArray *)arrPoints {
    
    if (!_arrPoints) {
        _arrPoints = [NSMutableArray array];
    }
    return _arrPoints;
}

#pragma mark - click event

- (void)onTapNoneSticker:(UITapGestureRecognizer *)tapGesture {
    
    self.noneStickerImageView.highlighted = YES;
    
    self.prepareModel = nil;
    [self setMaterialModel:nil];
}

- (void)clickBottomViewButton:(STViewButton *)viewBtn {
    switch (viewBtn.tag) {
            
        case STViewTagSpecialEffectsBtn:
            
            self.beautyBtn.userInteractionEnabled = NO;
            
            
            if (!self.specialEffectsContainerViewIsShow) {
                [self hideBeautyContainerView];
                [self specialEffectsContainerViewAppear];
            } else {
                [self hideSpecialEffectsContainerView];
            }
            
            self.beautyBtn.userInteractionEnabled = YES;
            break;
            
        case STViewTagBeautyBtn:
            
            self.specialEffectsBtn.userInteractionEnabled = NO;
            
            if (!self.beautyContainerViewIsShow) {
                
                [self hideSpecialEffectsContainerView];
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
    self.processingImageView.image = self.imageOriginal;
    self.btnClose.enabled = NO;
    self.btnSaveImage.enabled = NO;
}

- (void)onBtnCompareTouchUpInside:(UIButton *)sender {
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.processingImageView.image = self.imageProcessed;
    self.btnClose.enabled = YES;
    self.btnSaveImage.enabled = YES;
}

#pragma mark - animation

- (void)specialEffectsContainerViewAppear {
    
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

- (void)hideSpecialEffectsContainerView {
    
    self.beautyBtn.hidden = NO;
    self.specialEffectsBtn.hidden = NO;
    
    [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.specialEffectsContainerView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 250);
        self.btnCompare.frame = CGRectMake(SCREEN_WIDTH - 80, SCREEN_HEIGHT - 100, 70, 35);
        
    } completion:^(BOOL finished) {
        self.specialEffectsContainerViewIsShow = NO;
    }];
    
    self.specialEffectsBtn.highlighted = NO;
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
        self.btnCompare.frame = CGRectMake(SCREEN_WIDTH - 80, SCREEN_HEIGHT - 100, 70, 35);
        
    } completion:^(BOOL finished) {
        self.beautyContainerViewIsShow = NO;
    }];
    
    self.beautyBtn.highlighted = NO;
}

#pragma mark - 

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
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.noneStickerImageView.highlighted = NO;
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
    
    
    // 获取触发动作类型
    unsigned long long iAction = 0;
    
    st_result_t iRet = ST_OK;
    iRet = st_mobile_sticker_change_package(_hSticker, stickerPath, NULL);
    
    if (iRet != ST_OK && iRet != ST_E_PACKAGE_EXIST_IN_MEMORY) {
        
        STLog(@"st_mobile_sticker_change_package error %d" , iRet);
    }else{
        
        iRet = st_mobile_sticker_get_trigger_action(_hSticker, &iAction);
        
        if (ST_OK != iRet) {
            STLog(@"st_mobile_sticker_get_trigger_action error %d" , iRet);
        } else {
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
        
        if (NULL == stickerPath) {
            
            self.noneStickerImageView.highlighted = YES;
        }
        
        [self processImageAndDisplay];
    });
    
    self.stickerConf = iAction;
}

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
        
        self.filterStrengthSlider.value = self.fFilterStrength;
        
        st_result_t iRet = ST_OK;
        iRet = st_mobile_gl_filter_set_style(_hFilter, [model.strPath UTF8String]);
        
        if (ST_OK != iRet) {
            
            STLog(@"st_mobile_gl_filter_set_style %d" , iRet);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self refreshFilterCategoryState:model.modelType];
            });
        }
        
        iRet = st_mobile_gl_filter_set_param(_hFilter, ST_GL_FILTER_STRENGTH, self.fFilterStrength);
        
        if (ST_OK != iRet) {
            
            STLog(@"st_mobile_gl_filter_set_param %d" , iRet);
        } else {
            [self processImageAndDisplay];
        }
    }
    
}





- (void)handleEffectsType:(STEffectsType)type {
    
    //    self.curEffectType = type;
    
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
            
            self.arrCurrentModels = [self.effectsDataSource objectForKey:@(type)];
            [self.effectsList reloadData];
            
            self.effectsList.hidden = NO;
            
            break;
            
        case STEffectsTypeBeautyFilter:
        {
            self.filterCategoryView.hidden = NO;
            self.filterView.hidden = NO;
            self.beautyCollectionView.hidden = YES;
            
            self.filterCategoryView.center = CGPointMake(SCREEN_WIDTH / 2, self.filterCategoryView.center.y);
            self.filterView.center = CGPointMake(SCREEN_WIDTH * 3 / 2, self.filterView.center.y);
            
            _bmpColView.hidden = YES;
            _bmpStrenghView.hidden = YES;
        }
            break;
            
        case STEffectsTypeBeautyMakeUp:
            self.beautyCollectionView.hidden = YES;
            self.filterCategoryView.hidden = YES;
            self.filterView.hidden = YES;
            
            _bmpColView.hidden = NO;
            
        case STEffectsTypeNone:
            break;
            
        case STEffectsTypeBeautyShape:
        {
            [self hideBeautyViewExcept:self.beautyShapeView];
            self.filterStrengthView.hidden = YES;
            
            self.beautyCollectionView.hidden = NO;
            self.filterCategoryView.hidden = YES;
            self.beautyCollectionView.models = self.beautyShapeModels;
            [self.beautyCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            
            _bmpColView.hidden = YES;
            _bmpStrenghView.hidden = YES;
        }
            break;
            
        case STEffectsTypeBeautyBase:
        {
            [self hideBeautyViewExcept:self.beautyCollectionView];
            self.filterStrengthView.hidden = YES;
            self.filterCategoryView.hidden = YES;
            self.beautyCollectionView.models = self.baseBeautyModels;
            [self.beautyCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            
            _bmpColView.hidden = YES;
            _bmpStrenghView.hidden = YES;
            
        }
            break;
            
        case STEffectsTypeBeautyMicroSurgery:
            
            
            [self hideBeautyViewExcept:self.beautyCollectionView];
            self.beautyCollectionView.models = self.microSurgeryModels;
            [self.beautyCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
            
            _bmpColView.hidden = YES;
            _bmpStrenghView.hidden = YES;
            break;
            
        case STEffectsTypeBeautyAdjust:
            [self hideBeautyViewExcept:self.beautyCollectionView];
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

#pragma mark - touch events

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self.view];
    
    if (self.specialEffectsContainerViewIsShow) {
        
        if (!CGRectContainsPoint(CGRectMake(0, SCREEN_HEIGHT - 230, SCREEN_WIDTH, 230), point)) {
            
            [self hideSpecialEffectsContainerView];
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



#pragma mark - help function

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


- (void)filterSliderValueChanged:(UISlider *)sender {
    
    self.fFilterStrength = sender.value;
    self.lblFilterStrength.text = [NSString stringWithFormat:@"%d", (int)(sender.value * 100)];
    
    if (_hFilter) {
        
        st_result_t iRet = ST_OK;
        iRet = st_mobile_gl_filter_set_param(_hFilter, ST_GL_FILTER_STRENGTH, sender.value);
        
        if (ST_OK != iRet) {
            
            STLog(@"st_mobile_gl_filter_set_param %d" , iRet);
        }
        
        [self processImageAndDisplay];
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

- (void)hideBeautyViewExcept:(UIView *)view {
    for (UIView *beautyView in self.arrBeautyViews) {
        beautyView.hidden = !(view == beautyView);
    }
}

#pragma mark - check license 

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
    self.commonObjectView.faceArray = [_faceArray copy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.commonObjectView setNeedsDisplay];
    });
    
}

- (CGPoint)coordinateTransformation:(st_pointf_t)point {
    
    return CGPointMake(point.x / _scale + _leftMargin, point.y / _scale + _topMargin);
}

#pragma mark - sticker call back

void load_sound_pic(void* sound, const char* sound_name, int length) {
    
}

void play_sound_pic(const char* sound_name, int loop) {
    
}

void stop_sound_pic(const char* sound_name) {
    
}

#pragma mark -

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
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

@end

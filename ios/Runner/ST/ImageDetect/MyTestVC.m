//
//  MyTestVC.m
//  Runner
//
//  Created by Apple on 2019/12/26.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>

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
#import "MyTestVC.h"
#import "TestModel.h"
#import "STGLPreview.h"

@interface MyTestVC
()<STBeautySliderDelegate, STBMPCollectionViewDelegate, STBmpStrengthViewDelegate>{
    st_handle_t _hSticker;  // sticker句柄
    st_handle_t _hDetector; // detector句柄
    st_handle_t _hBeautify; // beautify句柄
    st_handle_t _hFilter;   // filter句柄
    st_handle_t _animalHandle;
    st_handle_t _hBmpHandle;
    
    st_mobile_animal_face_t *_detectResult1;
}
@property (strong, nonatomic) UIButton *btnSaveImage;
@property (strong, nonatomic) UIButton *btnClose;
@property (strong, nonatomic) UIImageView *processingImageView;
@property (nonatomic, readwrite, strong) UILabel *lblSaveStatus;
@property (nonatomic, strong) UIButton *resetBtn;
@property(retain,nonatomic) UIScrollView* scrollView;
@property (nonatomic, strong) NSData *licenseData;

@property (nonatomic, readwrite, assign) float scale;
@property (nonatomic, readwrite, assign) float topMargin;
@property (nonatomic, readwrite, assign) float leftMargin;

@property (nonatomic, readwrite, strong) EAGLContext *glContext;
@property (nonatomic, readwrite, strong) CIContext *ciContext;

@property (nonatomic, readwrite, strong) UIImage *imageProcessed;

@property (nonatomic, readwrite, assign) unsigned long long iCurrentAction;
@property (nonatomic, readwrite, assign) unsigned long long makeUpConf;
@property (nonatomic, readwrite, assign) unsigned long long stickerConf;

@property (nonatomic, readwrite, strong) NSMutableArray *arrPersons;
@property (nonatomic, readwrite, strong) NSMutableArray *arrPoints;
@property (nonatomic, readwrite, assign) BOOL bFilter;

@property (nonatomic, assign) BOOL needDetectAnimal;
@property (nonatomic, assign) int margin;

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

@property (nonatomic, strong) STBeautySlider *beautySlider;
@property (nonatomic, assign) STEffectsType curEffectBeautyType;
@property (nonatomic, assign) STEffectsType curEffectStickerType;

@property (nonatomic,strong)NSMutableArray *dataArry;
@property (nonatomic, strong) STGLPreview *glPreview;
@property (nonatomic)int outputStep;
@property(nonatomic)int noFaceCount;
@property (nonatomic)dispatch_queue_t serialQueue;
@property(nonatomic)BOOL isAlive;
@property(nonatomic) int maxData;
@property(nonatomic) NSMutableArray * selectedList;
@property(nonatomic)BOOL STSDK;
@property (nonatomic, readwrite, strong) STCommonObjectContainerView *commonObjectContainerView;

@property (nonatomic, readwrite, strong) UIButton *btnCompare;

@property(nonatomic)BOOL isComparing;
@end

@implementation MyTestVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isAlive=true;
    self.serialQueue=dispatch_queue_create("myThreadQueue1", DISPATCH_QUEUE_SERIAL);
    [self setupSubviews];
    [self checkLicenseFromLocal];
    [self setupHandle];
    self.maxData=50;
    if(self.makeIndex==-10086){
        self.STSDK=true;
        self.makeIndex=0;
        
        UIButton * item=[_scrollView viewWithTag:100];
        [item setBackgroundColor:[UIColor redColor]];
        [self setParams:[self.dataArry[0] arr]];
    }else{
        self.STSDK=false;
        UIButton * item=[_scrollView viewWithTag:100+self.makeIndex];
        [item setBackgroundColor:[UIColor redColor]];
        [self setParams:[self.dataArry[self.makeIndex] arr]];
    }
    if(!self.STSDK){
        [self.view addSubview:self.btnCompare];
    }
    //if(self.makeIndex!=nil){
//        self.makeIndex=0;
    //}
    
    
    [self processImageAndDisplay];
    
}

-(void)viewWillAppear:(BOOL)animated{
    self.isAlive=true;
}

- (void)viewWillDisappear:(BOOL)animated{
    self.isAlive=false;
}

- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

- (void)setupSubviews {
    
    self.selectedList=[NSMutableArray new];
    
    
    self.isComparing=NO;
    self.fSmoothStrength = 0.0;
    self.fReddenStrength = 0.0;
    self.fWhitenStrength = 0.0;
    self.fDehighlightStrength = 0.0;
    
    self.fEnlargeEyeStrength = 0.0;
    self.fShrinkFaceStrength = 0.0;
    self.fShrinkJawStrength = 0.00;
    self.fNarrowFaceStrength = 0.0;
    self.fRoundEyeStrength = 0.00;
    
    self.fThinFaceShapeStrength = 0.0;
    self.fChinStrength = 0.0;
    self.fHairLineStrength = 0.0;
    self.fNarrowNoseStrength = 0.0;
    self.fLongNoseStrength = 0.0;
    self.fMouthStrength = 0.0;
    self.fPhiltrumStrength = 0.0;
    
    self.fContrastStrength = 0.0;
    self.fSaturationStrength = 0.0;
    
    self.fFilterStrength = 0.0;
    
    self.outputStep=0;
    self.noFaceCount=0;
    
    self.bFilter = NO;
    self.needDetectAnimal = NO;
    
    self.curEffectBeautyType = STEffectsTypeBeautyBase;
    CGFloat vcViewWidth = self.view.frame.size.width;
    CGFloat vcViewHeight = self.view.frame.size.height;
    if(!_btnSaveImage){
        _btnSaveImage=[[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-100, 50, 50, 50)];
    }
    self.btnSaveImage.layer.cornerRadius = 17;
    self.btnSaveImage.layer.borderColor = [UIColor blackColor].CGColor;
    self.btnSaveImage.layer.borderWidth = 2;
    self.btnSaveImage.backgroundColor = [UIColor whiteColor];
    NSLog(@"LOGG2  %f %f",_imageOriginal.size.width,_imageOriginal.size.height);
    
    if(MAX(_imageOriginal.size.width, _imageOriginal.size.height)>4096){
        _imageOriginal=[self scaleImage:_imageOriginal toScale:(3096/MAX(_imageOriginal.size.width, _imageOriginal.size.height))];
    }
    
    double scare=_imageOriginal.size.width/ SCREEN_WIDTH;
    double topBuffer= (SCREEN_HEIGHT-(_imageOriginal.size.height/scare))/2;
    NSLog(@"SCARE  TOP BUFF  %f %f %f %f",scare,topBuffer,SCREEN_HEIGHT
          ,_imageOriginal.size.height/scare);
    if (!_processingImageView) {
        _processingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0 , topBuffer, SCREEN_WIDTH, _imageOriginal.size.height/scare)];
    }
    
    self.processingImageView.image = _imageOriginal;
    //    self.processingImageView.backgroundColor = [UIColor clearColor];
    self.dataArry=TestModel.getDemoData;
    //    NSMutableArray *dataArry=TestModel.getDemoData;
    //创建UIScrollView
    _scrollView = [[UIScrollView alloc] init];
    //设置UIScrollView的位置和宽高为控制器View的宽高
    _scrollView.frame = CGRectMake(0, vcViewHeight-60, vcViewWidth, 50);
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
    [btn addTarget:self action:@selector(onBtnClose:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *saveImageBtn =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [saveImageBtn.layer setCornerRadius:10.0];
    //SCREEN_WIDTH  SCREEN_HEIGHT
    saveImageBtn.frame=CGRectMake(SCREEN_WIDTH-90, 20, 80, 50);
    [saveImageBtn setBackgroundColor:[UIColor grayColor]];
    [saveImageBtn setTitle:@"保存图片" forState:UIControlStateNormal];
    [saveImageBtn addTarget:self action:@selector(saveImageButton:) forControlEvents:UIControlEventTouchUpInside];
    [saveImageBtn setTintColor:[UIColor whiteColor]];
    
    UIButton *reImageBtn =[UIButton buttonWithType:UIButtonTypeRoundedRect];
    [reImageBtn.layer setCornerRadius:10.0];
    reImageBtn.frame=CGRectMake(SCREEN_WIDTH-180, 20, 80, 50);
    [reImageBtn setBackgroundColor:[UIColor grayColor]];
    [reImageBtn setTitle:@"重新拍照" forState:UIControlStateNormal];
    [reImageBtn addTarget:self action:@selector(reImageButton:) forControlEvents:UIControlEventTouchUpInside];
    [reImageBtn setTintColor:[UIColor whiteColor]];
    self.commonObjectContainerView = [[STCommonObjectContainerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    self.commonObjectContainerView.delegate = self;
    //    [self.view insertSubview:self.commonObjectContainerView atIndex:1];
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    EAGLContext *previewContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2 sharegroup:self.glContext.sharegroup];
    
//    self.glPreview = [[STGLPreview alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) context:previewContext];
    
    //    [self.view addSubview:self.glPreview];
    [self.view addSubview:self.processingImageView];
    [self.view addSubview:self.commonObjectContainerView];
    [self.view addSubview:self.lblSaveStatus];
    [self.view addSubview:_scrollView];//添加表格到视图
    //    [self.view addSubview:self.btnSaveImage];
    [self.view addSubview:btn];

    [self.view addSubview:saveImageBtn];
    [self.view addSubview:reImageBtn];
    
//
    
    //    [self.view bringSubviewToFront:_scrollView];
    
}

-(void) saveImageButton:(UIButton*) btn{
    [self.btnClose setEnabled:NO];
    [self.btnSaveImage setEnabled:NO];
    NSString *tempPathBefore = NSTemporaryDirectory();
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *tempPath = [tempPathBefore stringByAppendingPathComponent:@"REALPATH"];
    [manager createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* tempTake1= [tempPath stringByAppendingPathComponent:[self createCUID:@"gengmei_"]];
    NSData *imageData = UIImageJPEGRepresentation(self.imageProcessed, 0.9);
    [imageData writeToFile:tempTake1 atomically:YES];
    if (self.imageProcessed.CGImage) {
        ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
        dispatch_async(dispatch_get_main_queue(), ^{
            [assetLibrary writeImageToSavedPhotosAlbum:self.imageProcessed.CGImage
                                           orientation:ALAssetOrientationUp
                                       completionBlock:^(NSURL *assetURL, NSError *error) {
                //                [self showAnimationIfSaved:error == nil];
                //                [self showAnimationIfSaved:error == nil];
                if(error!=nil){
                    [self showAnimationIfSaved:NO];
                }else{
                    if(self.STSDK){
                        [self showAnimationIfSaved:YES];
                    }else{
                        NSMutableDictionary * dict=[NSMutableDictionary new];
                        [dict setObject:self.oriPath forKey:@"oriPath"];
                        [dict setObject:tempTake1 forKey:@"newPath"];
                        [dict setObject:[self.dataArry[self.makeIndex] name] forKey:@"INDEX"];
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"backValue" object:dict];
                        [self dismissViewControllerAnimated:NO completion:nil];
                    }
                }
            }];
        });
    }else{
        [self showAnimationIfSaved:NO];
    }
    
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

-(void) reImageButton:(UIButton*) btn{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"backValue" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) clickButton:(UIButton*) btn {
    for(int i = 0; i < self.dataArry.count; i++) {
        UIButton * item=[_scrollView viewWithTag:100+i];
        [item setBackgroundColor:[UIColor orangeColor]];
    }
    self.makeIndex=btn.tag-100;
    UIButton * item=[_scrollView viewWithTag:btn.tag];
    [item setBackgroundColor:[UIColor redColor]];

    if([self.selectedList containsObject:[NSNumber numberWithInt:self.makeIndex]]){
        self.outputStep=6000;
    }else{
        self.outputStep=0;
        [self.selectedList addObject:[NSNumber numberWithInt:self.makeIndex]];
    }
    if(self.STSDK){
        [self processImageAndDisplay];
    }
//    [self processImageAndDisplay];
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
    
    //    iRet = st_mobile_sticker_create(&_hSticker);
    //
    //
    //    TIMEPRINT(keySticker, "sticker create time:");
    //
    //    if (ST_OK != iRet || !_hSticker) {
    //
    //        NSLog(@"st mobile sticker create failed: %d", iRet);
    //
    //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"贴纸SDK初始化失败 , SDK权限过期，或者与绑定包名不符" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
    //
    //        [alert show];
    //
    //    } else {
    //
    //        iRet = st_mobile_sticker_set_param_bool(_hSticker, -1, ST_STICKER_PARAM_WAIT_MATERIAL_LOADED_BOOL, true);
    //
    //        if (iRet != ST_OK) {
    //            NSLog(@"st_mobile_sticker_set_waiting_material_loaded failed: %d", iRet);
    //        }
    //
    //        iRet = st_mobile_sticker_set_param_int(_hSticker, -1, ST_STICKER_PARAM_MAX_IMAGE_MEMORY_INT, 30);
    //
    //        if (iRet != ST_OK) {
    //            NSLog(@"st_mobile_sticker_set_max_imgmem failed: %d", iRet);
    //        }
    //
    //        NSString *strAvatarModelPath = [[NSBundle mainBundle] pathForResource:@"M_SenseME_Avatar_Core_2.0.0" ofType:@"model"];
    //        iRet = st_mobile_sticker_load_avatar_model(_hSticker, strAvatarModelPath.UTF8String);
    //        if (iRet != ST_OK) {
    //            NSLog(@"load avatar model failed: %d", iRet);
    //        }
    //
    //        //声音贴纸回调，图片版可以不设置
    //        //st_mobile_sticker_set_sound_callback_funcs(_hSticker, load_sound_pic, play_sound_pic, stop_sound_pic);
    //    }
    
    //初始化美颜模块句柄
    iRet = st_mobile_beautify_create(&_hBeautify);
    NSLog(@"  STEP 3  ");
    
    if (ST_OK != iRet || !_hBeautify) {
        
        NSLog(@"st mobile beautify create failed: %d", iRet);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误提示" message:@"美颜SDK初始化失败，可能是模型路径错误，SDK权限过期，与绑定包名不符" delegate:nil cancelButtonTitle:@"好的" otherButtonTitles:nil, nil];
        
        [alert show];
    } else {
        // 设置默认红润参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_REDDEN_STRENGTH, self.fReddenStrength);
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_SMOOTH_STRENGTH, 0.4);
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_WHITEN_STRENGTH, 0.4);
        
        if(self.makeIndex!=0&&self.makeIndex!=1){
             
                   
        }
        // 设置默认磨皮参数
       
        
        // 设置默认大眼参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, self.fEnlargeEyeStrength);
        
        // 设置默认瘦脸参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_SHRINK_FACE_RATIO, self.fShrinkFaceStrength);
        
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_NARROW_FACE_STRENGTH, self.fNarrowFaceStrength);
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_ROUND_EYE_RATIO, self.fRoundEyeStrength);
        
        // 设置小脸参数
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_SHRINK_JAW_RATIO, self.fShrinkJawStrength);
        
        // 设置美白参数
       
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
        //        [self setParams:TestModel.getDemoData[1]];
    }
    NSLog(@"  STEP 4  ");
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
    NSLog(@"  STEP 5  ");
}



-(void) setParams:(NSArray*)arr{
    
    
//    if(self.makeIndex==0||self.makeIndex==1){
////        setBeautifyParam(_hBeautify, ST_BEAUTIFY_SMOOTH_MODE, 0.0);
//        setBeautifyParam(_hBeautify, ST_BEAUTIFY_SMOOTH_STRENGTH, 0.0);
//        setBeautifyParam(_hBeautify, ST_BEAUTIFY_WHITEN_STRENGTH, 0.0);
//    }else{
////        setBeautifyParam(_hBeautify, ST_BEAUTIFY_SMOOTH_MODE, 0.5);
//
//    }
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_SMOOTH_STRENGTH, 0.4);
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_WHITEN_STRENGTH, 0.4);
    
    // 设置默认瘦脸参数
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_SHRINK_FACE_RATIO,  [arr[0] floatValue]);
    if(self.STSDK){
        // 设置默认大眼参数
         setBeautifyParam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, [arr[1] floatValue]);
    }
    
    // 设置小脸参数
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_SHRINK_JAW_RATIO, [arr[2] floatValue]);
    //脸
    if(self.STSDK){
         setBeautifyParam(_hBeautify, ST_BEAUTIFY_NARROW_FACE_STRENGTH, [arr[3] floatValue]);
    }
//
    
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_ROUND_EYE_RATIO, [arr[4] floatValue]);
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_SHRINK_FACE_RATIO, [arr[5] floatValue]);
    if(self.STSDK){
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_CHIN_LENGTH_RATIO, [arr[6] floatValue]);
    }
//
    
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_HAIRLINE_HEIGHT_RATIO, [arr[7] floatValue]);
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_APPLE_MUSLE_RATIO, [arr[8] floatValue]);
    if(self.STSDK){
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_NARROW_NOSE_RATIO, [arr[9] floatValue]);
    }
//
    
    
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_NOSE_LENGTH_RATIO, [arr[10] floatValue]);
    if(self.STSDK){
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_MOUTH_SIZE_RATIO, [arr[11] floatValue]);
    }
//
//
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_PHILTRUM_LENGTH_RATIO, [arr[12] floatValue]);
    if(self.STSDK){
        setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, [arr[13] floatValue]);
    }
//
    
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_ANGLE_RATIO, [arr[14] floatValue]);
    
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_OPEN_CANTHUS_RATIO, [arr[15] floatValue]);
    
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_REMOVE_DARK_CIRCLES_RATIO, [arr[16] floatValue]);
    
    setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_REMOVE_NASOLABIAL_FOLDS_RATIO, [arr[17] floatValue]);
}


- (void)processImageAndDisplay {
    if(!self.isAlive){
        return;
    }
    
    if ([EAGLContext currentContext] != self.glContext) {
        [EAGLContext setCurrentContext:self.glContext];
    }
    int iWidth = self.imageOriginal.size.width;
    int iHeight= self.imageOriginal.size.height;
    _scale = fmaxf(iWidth / CGRectGetWidth(self.processingImageView.frame), iHeight / CGRectGetHeight(self.processingImageView.frame));
    _topMargin = (SCREEN_HEIGHT - iHeight / _scale) / 2;
    _leftMargin = (SCREEN_WIDTH - iWidth / _scale) / 2;
    
    if(self.STSDK){
        self.view.userInteractionEnabled = NO;
        GLuint textureResult = [self processImageAndReturnTexture];
                   //    [self.glPreview renderTexture:textureResult];
        CGImageRef cgImage = [self getCGImageWithTexture:textureResult width:self.imageOriginal.size.width height:self.imageOriginal.size.height];
        UIImage *imageResult = [UIImage imageWithCGImage:cgImage];
        self.imageProcessed = imageResult;
        self.processingImageView.image = self.imageProcessed;
        NSLog(@"outStep  %d",self.outputStep);
        CGImageRelease(cgImage);
        glDeleteTextures(1, &textureResult);
        self.view.userInteractionEnabled = YES;
    }else{
        dispatch_async(self.serialQueue, ^{
            //    self.view.userInteractionEnabled = NO;
            GLuint textureResult = [self processImageAndReturnTexture];
            //    [self.glPreview renderTexture:textureResult];
            CGImageRef cgImage = [self getCGImageWithTexture:textureResult width:self.imageOriginal.size.width height:self.imageOriginal.size.height];
            UIImage *imageResult = [UIImage imageWithCGImage:cgImage];
            dispatch_sync(dispatch_get_main_queue(), ^{
                self.imageProcessed = imageResult;
                self.processingImageView.image = self.imageProcessed;
                NSLog(@"outStep  %d",self.outputStep);
                    //if(self.outputStep<6*self.maxData){
                if(self.isAlive&&!self.STSDK){
                    [self processImageAndDisplay];
                }
                CGImageRelease(cgImage);
                glDeleteTextures(1, &textureResult);
            });
        });
    }
    
    
    
    //    self.view.userInteractionEnabled = YES;
    
    
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

- (CGImageRef)getCGImageWithTexture:(GLuint)iTexture width:(int)iWidth height:(int)iHeight {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CIImage *ciImage = [CIImage imageWithTexture:iTexture size:CGSizeMake(iWidth, iHeight) flipped:YES colorSpace:colorSpace];
    
    CGImageRef cgImage = [self.ciContext createCGImage:ciImage fromRect:CGRectMake(0, 0, iWidth, iHeight)];
    
    CGColorSpaceRelease(colorSpace);
    
    return cgImage;
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
    
    // 人脸信息检测
    if (_hDetector) {
        
        //        BOOL needFaceDetection = (self.fEnlargeEyeStrength != 0 || self.fShrinkFaceStrength != 0 || self.fShrinkJawStrength != 0 || self.fThinFaceShapeStrength != 0 || self.fNarrowFaceStrength != 0 || self.fRoundEyeStrength != 0 || self.fChinStrength != 0 || self.fHairLineStrength != 0 || self.fNarrowNoseStrength != 0 || self.fLongNoseStrength != 0 || self.fMouthStrength != 0 || self.fPhiltrumStrength != 0 || self.fEyeDistanceStrength != 0 || self.fEyeAngleStrength != 0 || self.fOpenCanthusStrength != 0 || self.fProfileRhinoplastyStrength != 0 || self.fBrightEyeStrength != 0 || self.fRemoveDarkCirclesStrength != 0 || self.fRemoveNasolabialFoldsStrength != 0 || self.fWhiteTeethStrength != 0 || self.fAppleMusleStrength != 0) && _hBeautify;
        BOOL needFaceDetection=true;
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
        if(self.STSDK){
            [self setParams:[self.dataArry[self.makeIndex] arr]];
        }
        
        
        // 配置美颜输出纹理
        glGenTextures(1, &textureBeautifyOutput);
        activeAndBindTexture(GL_TEXTURE2, &textureBeautifyOutput, NULL, GL_RGBA, iWidth, iHeight);
        
        TIMELOG(keyBeautify);
        
        
        iRet = st_mobile_beautify_process_texture(_hBeautify, textureOriginInput, iWidth, iHeight, ST_CLOCKWISE_ROTATE_0, &detectResult, textureBeautifyOutput, &detectResult);
        
        TIMEPRINT(keyBeautify, "st_mobile_beautify_process_texture time:");
        
        if (ST_OK != iRet) {
            
            STLog(@"st_mobile_beautify_process_texture failed %d" , iRet);
            
        }
        if(!self.isComparing){
            textureResult = textureBeautifyOutput;
        }
    }
    if(!self.STSDK){
        if(self.makeIndex!=1){
            if(self.outputStep==0){
                setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, 0);
                setBeautifyParam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, 0);
                setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_NARROW_NOSE_RATIO, 0);
                setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_MOUTH_SIZE_RATIO, 0);
                setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_CHIN_LENGTH_RATIO, 0);
                setBeautifyParam(_hBeautify, ST_BEAUTIFY_NARROW_FACE_STRENGTH, 0);
            }
            [self setParams:[self.dataArry[self.makeIndex] arr]];
            if(self.outputStep>self.maxData*6){
                setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, [[self.dataArry[self.makeIndex] arr][13]floatValue]);
                setBeautifyParam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, [[self.dataArry[self.makeIndex] arr][1]floatValue]);
                setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_NARROW_NOSE_RATIO, [[self.dataArry[self.makeIndex] arr][9]floatValue]);
                setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_MOUTH_SIZE_RATIO, [[self.dataArry[self.makeIndex] arr][11]floatValue]);
                setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_CHIN_LENGTH_RATIO, [[self.dataArry[self.makeIndex] arr][6]floatValue]);
                setBeautifyParam(_hBeautify, ST_BEAUTIFY_NARROW_FACE_STRENGTH, [[self.dataArry[self.makeIndex] arr][3]floatValue]);
            }
        }
    }
    if(self.makeIndex!=0&&!self.STSDK){
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self drawKeyPoints:detectResult];
        });
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

#pragma mark - btn action

- (void)onBtnClose:(id)sender {
    [self releaseResources];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"backValue" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - draw points
- (CGPoint)coordinateTransformation:(st_pointf_t)point {
    return CGPointMake(point.x / _scale + _leftMargin, point.y / _scale + _topMargin);
}

- (void)drawKeyPoints:(st_mobile_human_action_t)detectResult {
    NSMutableArray * arrayFace = [NSMutableArray array];
    for (int i = 0; i < detectResult.face_count; ++i) {
        for (int j = 0; j < 106; ++j) {
            [arrayFace addObject:@{
                POINT_KEY: [NSValue valueWithCGPoint:[self coordinateTransformation:detectResult.p_faces[i].face106.points_array[j]]]
            }];
        }
    }
    if([arrayFace count]>0){
        self.outputStep++;
    }else{
        self.noFaceCount++;
    }
    self.commonObjectContainerView.step=self.outputStep;
    self.commonObjectContainerView.stepCount=self.maxData;
    self.commonObjectContainerView.radomIndex=0;
    self.commonObjectContainerView.faceArray = arrayFace;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.commonObjectContainerView setNeedsDisplay];
    });
}

- (void)commonSetBuity:(float)progress :(NSString *)what{
    if(progress>0.9){
        progress=1.0;
    }
    NSLog(@"HERE %f",progress);
    float toNumber=0.98;
    float testValue=(toNumber)*progress;
    if([what isEqualToString:@"rz"]){
        if(self.makeIndex==1){
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, -testValue);
        }else{
            float value=([[self.dataArry[self.makeIndex] arr][13]floatValue])*progress;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, value);
        }
    }else if([what isEqualToString:@"eye"]){
        if(self.makeIndex==1){
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, -toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, testValue);
        }else{
            float value=([[self.dataArry[self.makeIndex] arr][1]floatValue])*progress;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, value);
        }
    }else if([what isEqualToString:@"nose"]){
        if(self.makeIndex==1){
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, -toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_NARROW_NOSE_RATIO, testValue);
        }else{
            float value=([[self.dataArry[self.makeIndex] arr][9]floatValue])*progress;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_NARROW_NOSE_RATIO, value);
        }
    }
    else if([what isEqualToString:@"lip"]){
        if(self.makeIndex==1){
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, -toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_NARROW_NOSE_RATIO, toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_MOUTH_SIZE_RATIO, -testValue);
        }else{
            float value=([[self.dataArry[self.makeIndex] arr][11]floatValue])*progress;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_MOUTH_SIZE_RATIO, value);
        }
    }
    
    else if([what isEqualToString:@"xb"]){
        if(self.makeIndex==1){
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, -toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_NARROW_NOSE_RATIO, toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_MOUTH_SIZE_RATIO, -toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_CHIN_LENGTH_RATIO, testValue);
        }else{
            float value=([[self.dataArry[self.makeIndex] arr][6]floatValue])*progress;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_CHIN_LENGTH_RATIO,value);
        }
    }
    
    else if([what isEqualToString:@"face"]){
        if(self.makeIndex==1){
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_EYE_DISTANCE_RATIO, -toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_ENLARGE_EYE_RATIO, toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_NARROW_NOSE_RATIO, toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_MOUTH_SIZE_RATIO, -toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_3D_CHIN_LENGTH_RATIO, toNumber);
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_NARROW_FACE_STRENGTH, testValue);
        }else{
            float value=([[self.dataArry[self.makeIndex] arr][3]floatValue])*progress;
            setBeautifyParam(_hBeautify, ST_BEAUTIFY_NARROW_FACE_STRENGTH, value);
            
        }
    }
}

@end

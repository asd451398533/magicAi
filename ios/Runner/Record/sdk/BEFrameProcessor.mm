// Copyright (C) 2018 Beijing Bytedance Network Technology Co., Ltd.
#import "BEFrameProcessor.h"

#import <OpenGLES/ES2/glext.h>
#import "RenderMsgDelegate.h"

#import "BERender.h"
#import "BEEffectManager.h"
#import "BEResourceHelper.h"
#import "BEDetect.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@implementation BEProcessResult
@end

@interface BEFrameProcessor() <RenderMsgDelegate> {
    
    EAGLContext *_glContext;
    
    BOOL                    _effectOn;
    BEEffectManager         *_effectManager;
    BERender                *_render;
    BEResourceHelper        *_resourceHelper;
    IRenderMsgDelegateManager *_manager;
    BEDetect                *_detect;
    
    BOOL                    _shouldResetComposer;
    BOOL                    _detectFaceOn;
}

@end

@implementation BEFrameProcessor

/**
 * license有效时间2019-03-01到2019-04-30
 * license只是为了追踪使用情况，可以随时申请无任何限制license
 */
static NSString *LICENSE_NAME = @"/gengmei_20200221_20200305_com.example.gengmeiAppFaceL_gengmei_v3.8.0.licbag";

- (instancetype)initWithContext:(EAGLContext *)context resourceDelegate:(id<BEResourceHelperDelegate>)delegate {
    self = [super init];
    if (self) {
        _glContext = context;
        [EAGLContext setCurrentContext:context];
        
        _effectOn = YES;
        _shouldResetComposer = YES;
        _detectFaceOn=YES;
        
        _effectManager = [[BEEffectManager alloc] init];
        _render = [[BERender alloc] init];
        _resourceHelper = [[BEResourceHelper alloc] init];
        _resourceHelper.delegate = delegate;
        _detect = [[BEDetect alloc] init];
        
        [_detect setupEffectDetectSDKWithLicenseVersion:LICENSE_NAME];
        
        [self be_setupEffectSDK:[_resourceHelper licensePath] model:[_resourceHelper modelDirPath]];
        
        //        _manager = [[IRenderMsgDelegateManager alloc] init];
        //        [_manager addDelegate:self];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"BEFrameProcessor dealloc %@", NSStringFromSelector(_cmd));
    [EAGLContext setCurrentContext:_glContext];
    [self be_releaseSDK];
    [_detect releaseEffcetDetectSDK];
}

/*
 * 帧处理流程
 */
- (BEProcessResult *)process:(CVPixelBufferRef)pixelBuffer timeStamp:(double)timeStamp{
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    unsigned char *baseAddress = (unsigned char *) CVPixelBufferGetBaseAddress(pixelBuffer);
    int bytesPerRow = (int) CVPixelBufferGetBytesPerRow(pixelBuffer);
    int width = (int) CVPixelBufferGetWidth(pixelBuffer);
    int height = (int) CVPixelBufferGetHeight(pixelBuffer);
    
    size_t iTop, iBottom, iLeft, iRight;
    CVPixelBufferGetExtendedPixels(pixelBuffer, &iLeft, &iRight, &iTop, &iBottom);
    width = width + (int) iLeft + (int) iRight;
    height = height + (int) iTop + (int) iBottom;
    bytesPerRow = bytesPerRow + (int) iLeft + (int) iRight;
    
    BEProcessResult *result = [self process:baseAddress width:width height:height bytesPerRow:bytesPerRow timeStamp:timeStamp format:GL_BGRA];
    
    //    GLuint textureResult;
    //
    //    textureResult = [_effectManager genOutputTexture:baseAddress width:width height:height];
    
    
    
    if (_processorResult == BECVPixelBuffer) {
        result.pixelBuffer = [_render transforTextureToCVPixelBuffer:result.texture pixelBuffer:pixelBuffer width:width height:height bytesPerRow:bytesPerRow];
    }
    
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    return result;
}

- (BEProcessResult *)process:(unsigned char *)buffer width:(int)width height:(int)height bytesPerRow:(int)bytesPerRow timeStamp:(double)timeStamp format:(GLenum)format {
    
    buffer = [_render preProcessBuffer:buffer width:width height:height bytesPerRow:bytesPerRow];
    //设置后续美颜以及其他识别功能的基本参数
    [_effectManager setWidth:width height:height orientation:[self getDeviceOrientation]];
    
    // 设置 OpenGL 环境 , 需要与初始化 SDK 时一致
    if ([EAGLContext currentContext] != _glContext) {
        [EAGLContext setCurrentContext:_glContext];
    }
    
    GLuint inputTexture = [_render genInputTexture:buffer width:width height:height format:format];
    
    return [self process:inputTexture width:width height:height timeStamp:timeStamp bytesPerRow:(int)bytesPerRow];
}

- (BEProcessResult *)process:(GLuint)texture width:(int)width height:(int)height timeStamp:(double)timeStamp bytesPerRow:(int)bytesPerRow{
    BEProcessResult *result = [[BEProcessResult alloc] init];
    
    // 设置 OpenGL 环境 , 需要与初始化 SDK 时一致
    if ([EAGLContext currentContext] != _glContext) {
        [EAGLContext setCurrentContext:_glContext];
    }
    
    GLuint textureResult;
    if (_effectOn) {
        GLuint outputTexutre = [_render genOutputTexture:width height:height];
        textureResult = [_effectManager processTexture:texture outputTexture:outputTexutre timeStamp:timeStamp];
        int resizeWidth = width * 1;
        int resizeHeight = height * 1;
        unsigned char* buffer = NULL;
        buffer = (unsigned char*)malloc(resizeWidth * resizeHeight * 4);
        if (buffer == 0)
            NSLog(@"BEFrameProcessor malloc memory failed");
        [_render transforTextureToImage:outputTexutre buffer:buffer width:resizeWidth height:resizeHeight];
        bef_ai_pixel_format imageFormat = BEF_AI_PIX_FMT_RGBA8888;
        [_detect setSDKWidth:resizeWidth height:resizeHeight bytePerRow:bytesPerRow];
        [_render renderHelperSetWidth:width height:height resizeRatio:1.0];
        if (_detectFaceOn){
            bef_ai_face_info faceInfo;
            memset(&faceInfo, 0, sizeof(bef_ai_face_info));
            [_detect faceDetect:&faceInfo buffer:buffer format:imageFormat deviceOrientation:[self getDeviceOrientation]];
            for(int i=0 ; i<106 ;i ++){
                faceInfo.base_infos[0].points_array[i].x=
                faceInfo.base_infos[0].points_array[i].x/(width/SCREEN_WIDTH);
                faceInfo.base_infos[0].points_array[i].y=
                faceInfo.base_infos[0].points_array[i].y/(width/SCREEN_WIDTH);
            };
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.captureDelegate BEFrameProcessor:self didDetectFaceInfo:faceInfo];
                //                    }
            });
        }
        free(buffer);
    } else {
        textureResult = texture;
    }
    
    result.size  = CGSizeMake(width, height);
    result.texture = textureResult;
    if (_processorResult == BERawData) {
        result.rawData = [_render transforTextureToBuffer:textureResult width:width height:height];
    }
    
    if (_captureNextFrame) {
        UIImage *image = [_render transforTextureToUIImage:textureResult width:width height:height];
        if (self.captureDelegate) {
            [self.captureDelegate onImageCapture:image];
        }
        _captureNextFrame = NO;
    }
    return result;
}


- (float)_getModelResizeRatioWithWidth:(int)width height:(int)height{
    float xRatio = 0.0, yRatio = 0.0;
    float retRatio = 0.0;
    if (_detectFaceOn){
        xRatio = MAX(xRatio, CGSizeMake(128, 224).width / width);
        yRatio = MAX(yRatio, CGSizeMake(128, 224).height / height);
        retRatio = MAX(retRatio, MAX(xRatio, yRatio));
    }
    
    return retRatio;
}
/*
 * 设置滤镜强度
 */
-(void)setFilterIntensity:(float)intensity{
    [_effectManager setFilterIntensity:intensity];
}

/*
 * 设置贴纸资源
 */
- (void)setStickerPath:(NSString *)path {
    if (path != nil && ![path isEqualToString:@""]) {
        _shouldResetComposer = true;
        path = [_resourceHelper stickerPath:path];
    }
    [_effectManager setStickerPath:path];
}

- (void)setComposerMode:(int)mode {
    _composerMode = mode;
    [_effectManager setComposerMode:mode];
}

- (void)updateComposerNodes:(NSArray<NSString *> *)nodes {
    [self be_checkAndSetComposer];
    
    NSMutableArray<NSString *> *paths = [NSMutableArray arrayWithCapacity:nodes.count];
    for (int i = 0; i < nodes.count; i++) {
        [paths addObject:[_resourceHelper composerNodePath:nodes[i]]];
    }
    
    [_effectManager updateComposerNodes:paths];
}

- (void)updateComposerNodeIntensity:(NSString *)node key:(NSString *)key intensity:(CGFloat)intensity {
    [_effectManager updateComposerNodeIntensity:[_resourceHelper composerNodePath:node] key:key intensity:intensity];
}

/*
 * 设置滤镜资源路径和系数
 */
- (void)setFilterPath:(NSString *)path {
    if (path != nil && ![path isEqualToString:@""]) {
        path = [_resourceHelper filterPath:path];
    }
    [_effectManager setFilterPath:path];
}

- (void)setEffectOn:(BOOL)on
{
    _effectOn = on;
}

- (NSArray<NSString *> *)availableFeatures {
    return [_effectManager availableFeatures];
}

- (NSString *)sdkVersion {
    return [_effectManager sdkVersion];
}

- (BOOL)setCameraPosition:(BOOL)isFront {
    return [_effectManager setCameraPosition:isFront];
}

#pragma mark - RenderMsgDelegate
- (BOOL)msgProc:(unsigned int)unMsgID arg1:(int)nArg1 arg2:(int)nArg2 arg3:(const char *)cArg3 {
    NSLog(@"msg proc: %d, arg: %d in processor: %lu", unMsgID, nArg1, self.hash);
    return NO;
}

#pragma mark - private

/*
 * 初始化SDK
 */
- (void)be_setupEffectSDK:(NSString *)license model:(NSString *)model {
    [_effectManager setupEffectManagerWithLicense:license model:model];
}

- (void)be_releaseSDK {
    // 要在opengl上下文中调用
    [_effectManager releaseEffectManager];
}

- (void)be_checkAndSetComposer {
    if ([self be_shouldResetComposer]) {
        [_effectManager initEffectCompose:[_resourceHelper composerPath]];
        _shouldResetComposer = false;
    }
}

- (BOOL)be_shouldResetComposer {
    return _shouldResetComposer && _composerMode == 0;
}

/*
 * 获取设备旋转角度
 */
- (int)getDeviceOrientation {
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    switch (orientation) {
        case UIDeviceOrientationPortrait:
            return BEF_AI_CLOCKWISE_ROTATE_0;
            
        case UIDeviceOrientationPortraitUpsideDown:
            return BEF_AI_CLOCKWISE_ROTATE_180;
            
        case UIDeviceOrientationLandscapeLeft:
            return BEF_AI_CLOCKWISE_ROTATE_270;
            
        case UIDeviceOrientationLandscapeRight:
            return BEF_AI_CLOCKWISE_ROTATE_90;
            
        default:
            return BEF_AI_CLOCKWISE_ROTATE_0;
    }
}



@end


// Copyright (C) 2018 Beijing Bytedance Network Technology Co., Ltd.
#import <GLKit/GLKit.h>
#import "BEResourceHelper.h"
#import "bef_effect_ai_face_detect.h"

@class BEFrameProcessor;

/// output of (BEProcessResult *)process:(CVPixelBufferRef)pixelBuffer timeStamp:(double)timeStamp and (BEProcessResult *)process:(unsigned char *)buffer width:(int)width height:(int)height bytesPerRow:(int)bytesPerRow timeStamp:(double)timeStamp
@interface BEProcessResult : NSObject
/// always set
@property (nonatomic, assign) GLuint texture;
/// avaliable when set BERawData to BEFrameProcessor's processorResult
@property (nonatomic, assign) unsigned char *rawData;
/// available when set BECVPixelBuffer to BEFrameProcessor's processorResult and invoke (BEProcessResult *)process:(CVPixelBufferRef)pixelBuffer timeStamp:(double)timeStamp
@property (nonatomic, assign) CVPixelBufferRef pixelBuffer;
@property (nonatomic, assign) CGSize size;
@end

/// result type of process
typedef NS_ENUM(NSInteger, BEProcessorResult) {
    BERawData,
    BECVPixelBuffer
};

/// capture image delegate, will be invoked when set BEFrameProcessor's captureNextFrame YES
@protocol BECaptureDelegate <NSObject>

- (void)onImageCapture:(UIImage *)image;

- (void)BEFrameProcessor:(BEFrameProcessor *)processor didDetectFaceInfo:(bef_ai_face_info)faceInfo;
@end

@interface BEFrameProcessor : NSObject

/// process result type, buffer/CVPixelBuffer
@property (nonatomic, assign) BEProcessorResult processorResult;

/// get composer Mode, 0/1
@property (nonatomic, readonly) int composerMode;


/// capture next frame when set YES
@property (nonatomic, assign) BOOL captureNextFrame;

/// capture frame delegate
@property (nonatomic, weak) id<BECaptureDelegate> captureDelegate;

/// init function
/// @param context gl context
/// @param delegate resource delegate, nullable
- (instancetype)initWithContext:(EAGLContext *)context resourceDelegate:(id<BEResourceHelperDelegate>)delegate;

/// process CVPixelBuffer
/// @param pixelBuffer original pixelBuffer
/// @param timeStamp current time
- (BEProcessResult *)process:(CVPixelBufferRef)pixelBuffer timeStamp:(double)timeStamp;

/// process buffer
/// @param buffer original buffer
/// @param width with of buffer
/// @param height height of buffer
/// @param bytesPerRow bytesPerRow of buffer
/// @param timeStamp current time
/// @param format pixel format, such as GL_RGBA,GL_BGRA...
- (BEProcessResult *)process:(unsigned char *)buffer width:(int)width height:(int)height bytesPerRow:(int)bytesPerRow timeStamp:(double)timeStamp format:(GLenum)format;

/// process texture
/// @param texture original texture
/// @param width width of texture
/// @param height height of texture
/// @param timeStamp current time
- (BEProcessResult *)process:(GLuint)texture width:(int)width height:(int)height timeStamp:(double)timeStamp;

/// set filter path
/// @param path relative path
- (void)setFilterPath:(NSString *)path;

/// set filter intensity
/// @param intensity 0-1
- (void)setFilterIntensity:(float)intensity;

/// set sticker path
/// @param path relative path
- (void)setStickerPath:(NSString *)path;

/// set composer mode
/// @param mode 0: exclusive between composer and sticker, 1: not exclusive between composer and sticker
- (void)setComposerMode:(int)mode;

/// update composer nodes
/// @param nodes relative path of nodes
- (void)updateComposerNodes:(NSArray<NSString *> *)nodes;

/// update composer node intensity
/// @param node relative path of node
/// @param key key of feature, such as smooth,white...
/// @param intensity 0-1
- (void)updateComposerNodeIntensity:(NSString *)node key:(NSString *)key intensity:(CGFloat)intensity;

/// set if effect is on
/// @param on YES: do render NO: not do render, just return origin texture/buffer/CVPixelBuffer
- (void)setEffectOn:(BOOL)on;

/// get available features in sdk
- (NSArray<NSString *> *)availableFeatures;

/// get sdk version
- (NSString *)sdkVersion;

/// set camera position
/// @param isFront YES: texture/buffer/CVPxielBuffer is from front camera
- (BOOL)setCameraPosition:(BOOL)isFront;

@end

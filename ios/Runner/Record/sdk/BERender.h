// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.
#import "bef_effect_ai_public_define.h"
#import <OpenGLES/ES2/glext.h>
#import <UIKit/UIKit.h>

@interface BERender : NSObject

@property (nonatomic, strong) NSMutableDictionary* composeNodeDict;

/// pre process buffer for remove align
/// @param buffer buffer to process
/// @param width with of buffer
/// @param height height of buffer
/// @param bytesPerRow bytes per row of buffer
- (unsigned char *)preProcessBuffer:(unsigned char *)buffer width:(int)width height:(int)height bytesPerRow:(int)bytesPerRow;

/// transfor texture to buffer
/// @param texture texture
/// @param width width of texture
/// @param height height of texture
- (unsigned char *)transforTextureToBuffer:(GLuint)texture width:(int)width height:(int)height;

/// transfor texture to CVPixelBuffer
/// @param texture texture
/// @param pixelBuffer original pixelBuffer
/// @param width with of texture
/// @param height height of texture
/// @param bytesPerRow bytes per row
- (CVPixelBufferRef)transforTextureToCVPixelBuffer:(GLuint)texture pixelBuffer:(CVPixelBufferRef)pixelBuffer width:(int)width height:(int)height bytesPerRow:(int)bytesPerRow;

/// transfor texture to UIImage
/// @param texture texture
/// @param width width of texture
/// @param height height of texture
- (UIImage *)transforTextureToUIImage:(GLuint)texture width:(int)width height:(int)height;

/// transfor buffer to texture
/// @param buffer buffer
/// @param iWidth width of buffer
/// @param iHeight height of buffer
- (GLuint)transforBufferToTexture:(unsigned char*)buffer imageWidth:(int)iWidth height:(int)iHeight;

/// transfor texture to buffer
/// @param texture texture
/// @param buffer buffer pointer
/// @param iWidth with of buffer
/// @param iHeight height of buffer
- (void)transforTextureToBuffer:(GLuint)texture buffer:(unsigned char*)buffer width:(int)iWidth height:(int)iHeight;
- (void)transforTextureToImage:(GLuint)texture buffer:(unsigned char*)buffer width:(int)iWidth height:(int)iHeight;
- (void) renderHelperSetWidth:(int)width height:(int)height resizeRatio:(float)ratio;

/// transfor texture to buffer
/// @param texture texture
/// @param buffer buffer pointer
/// @param iWidth with of buffer
/// @param iHeight height of buffer
/// @param format pixel format, such as GL_RGBA,GL_BGRA...
- (void)transforTextureToBuffer:(GLuint)texture buffer:(unsigned char*)buffer width:(int)iWidth height:(int)iHeight format:(GLenum)format;

/// generate input texture with buffer
/// @param buffer original buffer
/// @param width width of buffer
/// @param height height of buffer
- (GLuint)genInputTexture:(unsigned char *)buffer width:(int)width height:(int)height;

/// generate input texture with buffer and pixel format
/// @param buffer original buffer
/// @param width with of buffer
/// @param height height of buffer
/// @param format pixel format, such as GL_RGBA,GL_GBRA...
- (GLuint)genInputTexture:(unsigned char *)buffer width:(int)width height:(int)height format:(GLenum)format;

/// generate output texture
/// @param width with of texture
/// @param height height of texture
- (GLuint)genOutputTexture:(int)width height:(int)height;


@end

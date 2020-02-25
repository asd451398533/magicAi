// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.
#import "BERender.h"

#import "bef_effect_ai_public_define.h"
#import "bef_effect_ai_api.h"

#import "BERenderHelper.h"

#import "bef_effect_ai_hand.h"
#import "bef_effect_ai_face_detect.h"
#import "bef_effect_ai_skeleton.h"
@interface BERender () {
    BERenderHelper          *_renderHelper;
    GLuint                  _frameBuffer;
    GLuint                  _textureInput;
    GLuint                  _textureOutput;
    
    unsigned char           *_pixelBuffPointer;
    unsigned char           *_buffOutPointer;
    unsigned int            _pixelBufferPointerLength;
    unsigned int            _buffOutPointerLength;
}

@property (nonatomic, readwrite) NSString *triggerAction;
@property (nonatomic, assign) BOOL effectEnable;

@property (nonatomic, assign) GLuint currentTexture;
@end

@implementation BERender

static NSString* LICENSE_PATH;

- (instancetype)init {
    self = [super init];
    if (self){
        _renderHelper = [[BERenderHelper alloc] init];
        glGenFramebuffers(1, &_frameBuffer);
        
        _pixelBuffPointer = NULL;
        _buffOutPointer = NULL;
    }
    return self;
}

- (void)dealloc {
    free(_pixelBuffPointer);
    free(_buffOutPointer);
    glDeleteFramebuffers(1, &_frameBuffer);
    glDeleteTextures(1, &_textureInput);
    glDeleteTextures(1, &_textureOutput);
}

- (unsigned char *)preProcessBuffer:(unsigned char *)buffer width:(int)width height:(int)height bytesPerRow:(int)bytesPerRow {
    int realBytesPerRow = width * 4;
    if (bytesPerRow == realBytesPerRow) {
        return buffer;
    }

    if(_pixelBuffPointer == NULL) {
        _pixelBuffPointer = (unsigned char*)malloc(width*height*4*(sizeof(unsigned char)));
        _pixelBufferPointerLength = width * height * 4;
    } else if (width * height * 4 != _pixelBufferPointerLength) {
        free(_pixelBuffPointer);
        _pixelBuffPointer = (unsigned char *)malloc(width * height * 4);
        _pixelBufferPointerLength = width * height * 4;
    }

    unsigned char* to = _pixelBuffPointer;
    unsigned char* from = buffer;
    for(int i =0; i<height; i++) {
        memcpy(to, from, realBytesPerRow);
        to = to  + realBytesPerRow;
        from = from + bytesPerRow;
    }
    return _pixelBuffPointer;
}

- (unsigned char *)transforTextureToBuffer:(GLuint)texture width:(int)width height:(int)height {
    if(_buffOutPointer == NULL) {
        _buffOutPointer = (unsigned char *)malloc(width * height * 4 * sizeof(unsigned char));
        _buffOutPointerLength = width * height * 4;
    } else if (_buffOutPointerLength != width * height * 4) {
        free(_buffOutPointer);
        _buffOutPointer = (unsigned char *)malloc(width * height * 4 * sizeof(unsigned char));
        _buffOutPointerLength = width * height * 4;
    }

    [self transforTextureToBuffer:texture buffer:_buffOutPointer width:width height:height format:GL_RGBA];
    return _buffOutPointer;
}

- (CVPixelBufferRef)transforTextureToCVPixelBuffer:(GLuint)texture pixelBuffer:(CVPixelBufferRef)pixelBuffer width:(int)width height:(int)height bytesPerRow:(int)bytesPerRow {
    if(_buffOutPointer == NULL) {
        _buffOutPointer = (unsigned char *)malloc(width * height * 4 * sizeof(unsigned char));
        _buffOutPointerLength = width * height * 4;
    } else if (_buffOutPointerLength != width * height * 4) {
        free(_buffOutPointer);
        _buffOutPointer = (unsigned char *)malloc(width * height * 4 * sizeof(unsigned char));
        _buffOutPointerLength = width * height * 4;
    }

    [self transforTextureToBuffer:texture buffer:_buffOutPointer width:width height:height format:GL_BGRA];
    unsigned char *baseAddres = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
    unsigned char *from = _buffOutPointer;
    int realBytesPerRow = width * 4;
    if (bytesPerRow == realBytesPerRow) {
        memcpy(baseAddres, from, realBytesPerRow * height);
    } else {
        for (int i = 0; i < height; i++) {
            memcpy(baseAddres, from, realBytesPerRow);
            baseAddres += bytesPerRow;
            from += realBytesPerRow;
        }
    }

    return pixelBuffer;
}

- (UIImage *)transforTextureToUIImage:(GLuint)texture width:(int)width height:(int)height {
    unsigned char *buffer = [self transforTextureToBuffer:texture width:width height:height];
    CGDataProviderRef provider = CGDataProviderCreateWithData(
                                                              NULL,
                                                              buffer,
                                                              width * height * 4,
                                                              NULL);
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    CGImageRef imageRef = CGImageCreate(width,
                                        height,
                                        8,
                                        4 * 8,
                                        4 * width,
                                        colorSpaceRef,
                                        bitmapInfo,
                                        provider,
                                        NULL,
                                        NO,
                                        renderingIntent);

    UIImage *uiImage = [UIImage imageWithCGImage:imageRef];
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(imageRef);
    return uiImage;
}

- (GLuint)transforBufferToTexture:(unsigned char*)buffer imageWidth:(int)iWidth height:(int)iHeight{
    GLuint textureInput;
    
    glGenTextures(1, &textureInput);
    glBindTexture(GL_TEXTURE_2D, textureInput);
    
    // 加载相机数据到纹理
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, iWidth, iHeight, 0, GL_BGRA, GL_UNSIGNED_BYTE, buffer);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    return textureInput;
}

- (GLuint)genInputTexture:(unsigned char *)buffer width:(int)width height:(int)height {
    GLuint textureInput = _textureInput;
    
    if (!glIsTexture(textureInput)) {
        NSLog(@"gen input texture");
        glGenTextures(1, &textureInput);
    }
    glBindTexture(GL_TEXTURE_2D, textureInput);
    
    // 加载相机数据到纹理
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_BGRA, GL_UNSIGNED_BYTE, buffer);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    _textureInput = textureInput;
    return textureInput;
}

- (GLuint)genInputTexture:(unsigned char *)buffer width:(int)width height:(int)height format:(GLenum)format {
    GLuint textureInput = _textureInput;
    
    if (!glIsTexture(textureInput)) {
        NSLog(@"gen input texture");
        glGenTextures(1, &textureInput);
    }
    glBindTexture(GL_TEXTURE_2D, textureInput);
    
    // 加载相机数据到纹理
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, format, GL_UNSIGNED_BYTE, buffer);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    _textureInput = textureInput;
    return textureInput;
}

- (GLuint)genOutputTexture:(int)width height:(int)height {
    GLuint textureOutput = _textureOutput;;
    
    if (!glIsTexture(textureOutput)) {
        NSLog(@"gen output texture");
        glGenTextures(1, &textureOutput);
    }
    glBindTexture(GL_TEXTURE_2D, textureOutput);
    
    // 为输出纹理开辟空间
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    _textureOutput = textureOutput;
    return textureOutput;
}

//将texture转换为另一种大小的buffer
- (void)transforTextureToBuffer:(GLuint)texture buffer:(unsigned char*)buffer width:(int)iWidth height:(int)iHeight{
    [_renderHelper textureToImage:texture withBuffer:buffer Width:iWidth height:iHeight];
}

//将texture转换为另一种大小的buffer
- (void)transforTextureToImage:(GLuint)texture buffer:(unsigned char*)buffer width:(int)iWidth height:(int)iHeight{
    [_renderHelper textureToImage:texture withBuffer:buffer Width:iWidth height:iHeight];
}

- (void) renderHelperSetWidth:(int)width height:(int)height resizeRatio:(float)ratio{
    [_renderHelper setViewWidth:width height:height];
    [_renderHelper setResizeRatio:ratio];
}

- (void)transforTextureToBuffer:(GLuint)texture buffer:(unsigned char*)buffer width:(int)iWidth height:(int)iHeight format:(GLenum)format {
    [_renderHelper textureToImage:texture withBuffer:buffer Width:iWidth height:iHeight format:format];
}


- (void)checkGLError {
    int error = glGetError();
    if (error != GL_NO_ERROR) {
        NSLog(@"%d", error);
        @throw [NSException exceptionWithName:@"GLError" reason:@"error " userInfo:nil];
    }
}

- (BERenderHelper*)renderHelper {
    if (!_renderHelper){
        _renderHelper = [[BERenderHelper alloc] init];
    }
    return _renderHelper;
}


@end


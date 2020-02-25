//  Copyright © 2019 ailab. All rights reserved.

#ifndef BEEffectManager_h
#define BEEffectManager_h

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/glext.h>

@interface BEEffectManager : NSObject

/// set filter path
/// @param path absolute path
- (void)setFilterPath:(NSString*) path;

/// set filter intensity
/// @param intensity 0-1
- (void)setFilterIntensity:(float)intensity;

/// set sticker path
/// @param path absolute path
- (void)setStickerPath:(NSString*) path;

/// set composer mode
/// @param mode 0: exclusive between composer and sticker, 1: not exclusive between composer and sticker
- (void)setComposerMode:(int)mode;

/// update composer nodes
/// @param nodes absolute path of nodes
- (void)updateComposerNodes:(NSArray<NSString *> *)nodes;

/// update composer node intensity
/// @param node absolute path of node
/// @param key key of feature, such as smooth,white...
/// @param intensity 0-1
- (void)updateComposerNodeIntensity:(NSString *)node key:(NSString *)key intensity:(float)intensity;

/// init effect manager
/// @param license absolute path of license
/// @param model absolute path of mode dir
- (void)setupEffectManagerWithLicense:(NSString *)license model:(NSString *)model;

/// init effect composer
/// @param composer absolute path of composer
- (void)initEffectCompose:(NSString *)composer;

/// set texture/buffer with/height/orientation
/// @param iWidth int
/// @param iHeight int
/// @param orientation look up bef_ai_rotate_type
- (void)setWidth:(int) iWidth height:(int)iHeight orientation:(int)orientation;

/// process texture
/// @param inputTexture input
/// @param outputTexture output
/// @param timeStamp current time
- (GLuint)processTexture:(GLuint)inputTexture outputTexture:(GLuint)outputTexture timeStamp:(double)timeStamp;

/// release effect manager
- (void)releaseEffectManager;

/// get available features in sdk
- (NSArray<NSString *> *)availableFeatures;

/// get version of sdk
- (NSString *)sdkVersion;

/// set camera position
/// @param isFront YES: texture/buffer/CVPxielBuffer is from front camera
- (BOOL)setCameraPosition:(BOOL)isFront;
- (GLuint)genOutputTexture:(unsigned char *)buffer width:(int)width height:(int)height;
@end


#endif /* BEEffectManager_h */

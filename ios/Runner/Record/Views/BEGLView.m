// Copyright (C) 2018 Beijing Bytedance Network Technology Co., Ltd.
#import "BEGLView.h"
#import "BERenderHelper.h"

@interface BEGLView () {
    GLuint _displayTextureID;
    
    GLuint _renderProgram;
    GLuint _renderLocation;
    GLuint _renderInputImageTexture;
    GLuint _renderTextureCoordinate;
    GLfloat vertex[8];
    
    CGSize _savedSize;
}
@property (nonatomic, strong) CIContext *ciContext;
@property (nonatomic, strong) EAGLContext *glContext;
@property (nonatomic, assign) unsigned int screenWidth;
@property (nonatomic, assign) unsigned int screenHeight;
@property (nonatomic, strong) UIImageView *imageView;

@end

static float TEXTURE_FLIPPED[] = {0.0f, 1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f,};
static float CUBE[] = {-1.0f, -1.0f, 1.0f, -1.0f, -1.0f, 1.0f, 1.0f, 1.0f,};

#define TTF_STRINGIZE(x) #x
#define TTF_STRINGIZE2(x) TTF_STRINGIZE(x)
#define TTF_SHADER_STRING(text) @ TTF_STRINGIZE2(text)

static NSString *const RENDER_VERTEX = TTF_SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 varying vec2 textureCoordinate;
 void main(){
    float scale = 1.05;
    mat4 s = mat4(scale, 0.0, 0.0, 0.0,
                  0.0, scale, 0.0, 0.0,
                  0.0, 0.0, scale, 0.0,
                  0.0, 0.0, 0.0, 1.0);
     textureCoordinate = inputTextureCoordinate.xy;
     gl_Position = s * position;
 }
 );

static NSString *const RENDER_FRAGMENT = TTF_SHADER_STRING
(
 precision mediump float;
 varying highp vec2 textureCoordinate;
 uniform sampler2D inputImageTexture;
 void main()
 {
     gl_FragColor = texture2D(inputImageTexture, textureCoordinate);
 }
 );

@implementation BEGLView

- (void)dealloc
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        self.ciContext = [CIContext contextWithEAGLContext:self.glContext];
        self.context = self.glContext;
        
        if ([EAGLContext currentContext] != self.glContext) {
            [EAGLContext setCurrentContext:self.glContext];
        }
        [self loadRenderShader];
        CGFloat scale = [UIScreen mainScreen].scale;
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation == UIInterfaceOrientationPortrait
            || orientation == UIInterfaceOrientationPortraitUpsideDown) {
            _screenWidth = [UIScreen mainScreen].bounds.size.width * scale;
            _screenHeight = [UIScreen mainScreen].bounds.size.height * scale;
        } else {
            _screenHeight = [UIScreen mainScreen].bounds.size.width * scale;
            _screenWidth = [UIScreen mainScreen].bounds.size.height * scale;
        }
        [self be_resetVertex:720 imageHeight:1280 fitType:0];
        
//        [CSToastManager setQueueEnabled:YES];
    }
    return self;
}

- (void)resetWidthAndHeight {
    _screenWidth = (int)self.drawableWidth;
    _screenHeight = (int)self.drawableHeight;
}

/*
 * 将纹理绘制到屏幕上
 */
- (void)renderWithTexture:(unsigned int)name
                     size:(CGSize)size
                  flipped:(BOOL)flipped
      applyingOrientation:(int)orientation
                  fitType:(int)fitType {
    if (!glIsTexture(name)) {
        NSLog(@"texture %d is invalide", name);
    }
    [self be_resetVertex:size.width imageHeight:size.height fitType:fitType];
    _displayTextureID = name;
    [self display];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGSize size = self.bounds.size;
    if (!CGSizeEqualToSize(size, _savedSize)) {
        [self resetWidthAndHeight];
        _savedSize = size;
    }
    
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT| GL_DEPTH_BUFFER_BIT);
    
    glUseProgram(_renderProgram);
    
    glVertexAttribPointer(_renderLocation, 2, GL_FLOAT, false, 0, vertex);
    glEnableVertexAttribArray(_renderLocation);
    glVertexAttribPointer(_renderTextureCoordinate, 2, GL_FLOAT, false, 0, TEXTURE_FLIPPED);
    glEnableVertexAttribArray(_renderTextureCoordinate);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _displayTextureID);
    glUniform1i(_renderInputImageTexture, 0);
    glViewport(0, 0, _screenWidth, _screenHeight);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glDisableVertexAttribArray(_renderLocation);
    glDisableVertexAttribArray(_renderTextureCoordinate);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glUseProgram(0);
    glFlush();
}

/*
 * load resize shader
 */
- (void) loadRenderShader{
    GLuint vertexShader = [BERenderHelper compileShader:RENDER_VERTEX withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [BERenderHelper compileShader:RENDER_FRAGMENT withType:GL_FRAGMENT_SHADER];
    
    _renderProgram = glCreateProgram();
    glAttachShader(_renderProgram, vertexShader);
    glAttachShader(_renderProgram, fragmentShader);
    glLinkProgram(_renderProgram);
    
    GLint linkSuccess;
    glGetProgramiv(_renderProgram, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE){
        NSLog(@"BERenderHelper link shader error");
    }
    
    glUseProgram(_renderProgram);
    _renderLocation = glGetAttribLocation(_renderProgram, "position");
    _renderTextureCoordinate = glGetAttribLocation(_renderProgram, "inputTextureCoordinate");
    _renderInputImageTexture = glGetUniformLocation(_renderProgram, "inputImageTexture");
    
    if (vertexShader)
        glDeleteShader(vertexShader);
    
    if (fragmentShader)
        glDeleteShader(fragmentShader);
}


- (void)releaseContext {
    [EAGLContext setCurrentContext:nil];
}

#pragma mark - private

/// 计算 texture vertex
/// @param imageWidth texture 宽度
/// @param imageHeight texture 高度
/// @param fitType 填充方式，0: 铺满 1: 留白
- (void)be_resetVertex:(int)imageWidth imageHeight:(int)imageHeight fitType:(int)fitType {
    float ratio[2] = {1.0, 1.0};
    
    int outputWidth = _screenWidth;
    int outputHeight = _screenHeight;
    
    float finalRatio;
    if (fitType == 0) {
        finalRatio = MIN((float)outputWidth / imageWidth, (float)outputHeight / imageHeight);
    } else {
        finalRatio = MAX((float)outputWidth / imageWidth, (float)outputHeight / imageHeight);
    }
    
    int imageNewHeight = round(imageHeight * finalRatio);
    int imageNewWidth = round(imageWidth * finalRatio);
    
    ratio[0] = imageNewHeight / (float)outputHeight;
    ratio[1] = imageNewWidth / (float)outputWidth;
    
    for (int i = 0; i < 4; i ++){
        vertex[i * 2] = CUBE[i * 2] / ratio[0];
        vertex[i * 2 + 1] = CUBE[i * 2 + 1] / ratio[1];
    }
}

- (void)checkGLError {
    int error = glGetError();
    if (error != GL_NO_ERROR) {
        NSLog(@"%d", error);
        @throw [NSException exceptionWithName:@"GLError" reason:@"error " userInfo:nil];
    }
}
@end

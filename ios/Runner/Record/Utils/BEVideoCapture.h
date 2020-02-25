// Copyright (C) 2018 Beijing Bytedance Network Technology Co., Ltd.
#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>

#define AVCaptureSessionPreset NSString*

@protocol BEVideoCaptureProtocol;
@class BEVideoCapture;
typedef NS_ENUM(NSInteger, VideoCaptureError) {
    VideoCaptureErrorAuthNotGranted = 0,
    VideoCaptureErrorFailedCreateInput = 1,
    VideoCaptureErrorFailedAddDataOutput = 2,
    VideoCaptureErrorFailedAddDeviceInput = 3,
};

@protocol BEVideoCaptureDelegate <NSObject>
- (void)videoCapture:(id<BEVideoCaptureProtocol>)camera didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)videoCapture:(id<BEVideoCaptureProtocol>)camera didOutputBuffer:(unsigned char *)buffer width:(int)width height:(int)height bytesPerRow:(int)bytesPerRow timeStamp:(double)timeStamp;
- (void)videoCapture:(id<BEVideoCaptureProtocol>)camera didFailedToStartWithError:(VideoCaptureError)error;
@end

@protocol BEVideoMetadataDelegate <NSObject>
- (void)captureOutput:(BEVideoCapture *)camera didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects;
@end

@protocol BEVideoCaptureProtocol <NSObject>

@property (nonatomic, assign) id <BEVideoCaptureDelegate> delegate;
@property (nonatomic, assign) id <BEVideoMetadataDelegate> metadelegate;
@property (nonatomic, readonly) AVCaptureDevicePosition devicePosition; // default AVCaptureDevicePositionFront
@property (nonatomic, copy) AVCaptureSessionPreset sessionPreset;  // default 1280x720
@property (nonatomic, assign) BOOL isOutputWithYUV; // default NO

- (CGSize)videoSize;
- (void)startRunning;
- (void)stopRunning;
- (void)pause;
- (void)resume;
- (void)switchCamera;
- (void)switchCamera:(AVCaptureDevicePosition)position;
- (CGRect)getZoomedRectWithRect:(CGRect)rect scaleToFit:(BOOL)scaleToFit;
- (void)setFlip:(BOOL)isFlip;
- (void)setOrientation:(AVCaptureVideoOrientation)orientation;
- (void) setExposure:(float) exposure;
- (void) setExposurePointOfInterest:(CGPoint) point;
- (void) setFocusPointOfInterest:(CGPoint) point;

- (void)resetImage:(UIImage *)image;
@end

@interface BEVideoCapture : NSObject <BEVideoCaptureProtocol>

@end

@interface BEImageCapture : NSObject <BEVideoCaptureProtocol>

- (instancetype)initWithImage:(UIImage *)image;

@end

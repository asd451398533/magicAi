//
//  GengmeiStarSdk.m
//  Runner
//
//  Created by Apple on 2019/8/15.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GengmeiStarSdk.h"
//#import "Faceapp.pbrpc.h"
//#import "Faceapp.pbobjc.h"
//#import <GRPCClient/GRPCCall.h>
//#import <GRPCClient/GRPCCall+Tests.h>
#import "DownloadImageTask.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GengmeiStarItem.h"

@interface GengmeiStarSdk ()
@property (nonatomic,strong) NSString *KHostFaceAddress;
//@property(nonatomic,strong) FaceAgingService *faceService;
@property(nonatomic,strong) DownloadImageTask * downloadTask;
@property(nonatomic,strong)NSString * rectVideoPath;
@property(nonatomic,strong)NSString * longVideoPath;
@property (nonatomic,strong) dispatch_queue_t queue;
@property(atomic)NSString*taskId;
typedef void (^RectListener)(NSString*_Nullable value,NSError*_Nullable errorOrNil);
@property(nonatomic) RectListener rectListener;
typedef void (^LongListener)(NSString*_Nullable value,NSError*_Nullable errorOrNil);
@property(nonatomic) LongListener longListener;
@property(atomic) Boolean haveError;
@property(nonatomic,strong) NSString* downloadfilePath;
@property(nonatomic) volatile NSString* name;
@property(nonatomic) volatile NSString*value;
@property(nonatomic) volatile NSString* str1;
@property(nonatomic) volatile NSString*str2;
@property(atomic,strong) NSMutableArray * aiList;
@property(nonatomic)int requestCount;
@property(atomic) Boolean quit;
@end
@implementation GengmeiStarSdk
{
    
}

+ (instancetype)sharedSingleton {
    static GengmeiStarSdk *_sharedSingleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSingleton = [[super allocWithZone:NULL] init];
    });
    return _sharedSingleton;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [GengmeiStarSdk sharedSingleton];
}
- (id)copyWithZone:(nullable NSZone *)zone {
    return [GengmeiStarSdk sharedSingleton];
}
- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [GengmeiStarSdk sharedSingleton];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.KHostFaceAddress=@"140.143.179.96:50031";
//        [GRPCCall useInsecureConnectionsForHost:self.KHostFaceAddress];
//        self.faceService=[FaceAgingService serviceWithHost:self.KHostFaceAddress];
        self.queue =  dispatch_queue_create("com.xxcc", DISPATCH_QUEUE_SERIAL);
        self.downloadTask=[[DownloadImageTask alloc] init];
        NSString *tmpDir =  NSTemporaryDirectory();
        self.downloadfilePath = [NSString stringWithFormat:@"%@/lsy",tmpDir];
        self.aiList=[[NSMutableArray alloc]init];
    }
    return self;
}


-(void) execRectVideo:(NSString *)imageUrl videoPath:(NSString*)videoPath stepCount:(int)stepCount handler:(void(^)(NSString*_Nullable response,NSError *_Nullable error))handler{
    self.rectVideoPath=videoPath;
    self.rectListener=handler;
    self.requestCount=stepCount;
    self.quit=false;
//    dispatch_async(self.queue, ^{
//        AsyncStarGenerateRequest * request=[AsyncStarGenerateRequest message];
//        [request setURL:imageUrl];
//        [request setStepCount:stepCount];
//        [self.faceService asyncStarGenerateWithRequest:request handler:^(AsyncStarGenerateResponse * _Nullable response, NSError * _Nullable error) {
//            if (error==nil) {
//                NSLog(@"search!! ");
//                self.taskId=response.taskId;
//                [self performSelector:@selector(searchMethod) withObject:nil afterDelay:0.5];
//            }else{
//                handler(nil,error);
//            }
//        }];
//    });
}

-(void) execLongVideo:(UIImage*)background videoPath:(NSString*)videoPath handler:(void(^)(NSString* _Nullable respone , NSError*_Nullable))handler{
    self.longVideoPath=videoPath;
    self.longListener = handler;
    dispatch_async(self.queue, ^{
        [self.downloadTask drawPic:self.aiList :background :self.name :self.value :self.str1 :self.str2 handler:^(NSMutableArray<UIImage *> * _Nullable resultArr, NSError * _Nullable error) {
            if (error!=nil||resultArr==nil) {
                NSLog(@"FAIL @~~~~~~  %@",error);
                NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:4 userInfo:@"合成照片失败 "];
                self.rectListener(nil, error);
            }else{
                NSLog(@"Success @~~~~~~");
                @try {
                    NSMutableArray * arr=[[NSMutableArray alloc]init];
                    for (int i = 0; i<resultArr.count; i++) {
                        UIImage *imageNew = resultArr[i];
                        //设置image的尺寸
                        CGSize imagesize = imageNew.size;
                        imagesize.height =1440;
                        imagesize.width =960;
                        //对图片大小进行压缩--
                        imageNew = [self imageWithImage:imageNew scaledToSize:imagesize];
                        [arr addObject:imageNew];
                    }
                    CGSize size =CGSizeMake(960,1440);
//                    CGSize size =CGSizeMake(512,512);
                    [self CompressionSession:arr :false:self.longVideoPath:size];
                } @catch (NSException *exception) {
                    NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:4 userInfo:[exception userInfo]];
                    self.longListener(nil, error);
                }
            }
        }];
    });
}

-(UIImage*)getSharePic{
    return nil;
}

-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

-(void)quitStarTask{
    self.quit=true;
}


- (void)searchMethod{
//    if(self.quit){
//        return;
//    }
//    NSLog(@"search!! ");
//        PollStarGenerateRequest *request=[PollStarGenerateRequest message];
//        request.taskId=self.taskId;
//        [self.faceService pollAsyncStarGenerateWithRequest:request handler:^(PollStarGenerateResponse * _Nullable response, NSError * _Nullable error) {
//            NSLog(@"search!! %@",response.taskStatus);
//            if (error==nil) {
//                if ([response.taskStatus isEqual:@"success"]){
//                    NSFileManager *fileManager = [NSFileManager defaultManager];
//                    BOOL existed = [fileManager fileExistsAtPath:self.self.downloadfilePath isDirectory:NO];
//                    if ( !(existed == YES) ) {//如果文件夹不存在
//                        [ fileManager createDirectoryAtPath:self.downloadfilePath withIntermediateDirectories:YES attributes:nil error:nil];
//                    }
//                    NSArray *fileListArray = [ fileManager contentsOfDirectoryAtPath:self.downloadfilePath error:nil];
//                    for (NSString *file in fileListArray)
//                    {
//                        NSString *path = [self.downloadfilePath stringByAppendingPathComponent:file];
//                        [ fileManager removeItemAtPath:path error:nil];
//                    }
//                    NSMutableArray* array=response.generateURLArray;
//                    self.name=@"name";
//                    self.value=@"value";
//                    self.str1=@"str1";
//                    self.str2=@"str2";
//
//                    [self.downloadTask download:array handler:^(NSMutableArray<GengmeiStarItem *> * _Nullable resultArr, NSError * _Nullable error) {
//                        if (resultArr==nil||error!=nil) {
//                            self.rectListener(nil, error);
//                        }else{
//                            [self.aiList removeAllObjects];
//                            [self.aiList addObjectsFromArray:resultArr];
//                            NSMutableArray * videoArr=[[NSMutableArray alloc]init];
//                            for (int i=0; i<resultArr.count; i++) {
//                                NSData *data = [NSData dataWithContentsOfFile:resultArr[i].img];
//                                UIImage * image=[UIImage imageWithData:data];
//                                [videoArr addObject:image];
//                            }
//                             CGSize size =CGSizeMake(512,512);
//                            [self CompressionSession:videoArr:true:self.rectVideoPath:size];
//                        }
//                    }];
//                }else if([response.taskStatus isEqual:@"pending"]){
//                     [self performSelector:@selector(searchMethod) withObject:nil afterDelay:0.5];
//                }else if([response.taskStatus isEqual:@"failed"]){
//                    self.rectListener(nil,error);
//                }
//            }else{
//                self.rectListener(nil,error);
//            }
//        }];
}


-(void)CompressionSession:(NSMutableArray<UIImage *> *)imageArray :(Boolean)isRect :(NSString*)videoPath :(CGSize) size
{
    self.haveError=false;
    //        [selfwriteImages:imageArr ToMovieAtPath:moviePath withSize:sizeinDuration:4 byFPS:30];//第2中方法
    NSError *error =nil;
    //    转成UTF-8编码
    unlink([videoPath UTF8String]);
    NSLog(@"path->%@",videoPath);
    //     iphone提供了AVFoundation库来方便的操作多媒体设备，AVAssetWriter这个类可以方便的将图像和音频写成一个完整的视频文件
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:videoPath] fileType:AVFileTypeQuickTimeMovie error:&error];
    NSParameterAssert(videoWriter);
    if(error)
        NSLog(@"error =%@", [error localizedDescription]);
    //mov的格式设置 编码格式 宽度 高度
    NSDictionary *videoSettings =[NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecTypeH264,AVVideoCodecKey,
                                  [NSNumber numberWithInt:size.width],AVVideoWidthKey,
                                  [NSNumber numberWithInt:size.height],AVVideoHeightKey,nil];
    
    AVAssetWriterInput *writerInput =[AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    NSDictionary*sourcePixelBufferAttributesDictionary =[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:kCVPixelFormatType_32ARGB],kCVPixelBufferPixelFormatTypeKey,nil];
    AVAssetWriterInputPixelBufferAdaptor *adaptor =[AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    
    NSParameterAssert(writerInput);
    NSParameterAssert([videoWriter canAddInput:writerInput]);
    
    if ([videoWriter canAddInput:writerInput])
    {
        NSLog(@"11111");
    }
    else
    {
        NSLog(@"22222");
    }
    [videoWriter addInput:writerInput];
    [videoWriter startWriting];
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    dispatch_queue_t dispatchQueue =dispatch_queue_create("mediaInputQueue",NULL);
    int __block frame =0;
    [writerInput requestMediaDataWhenReadyOnQueue:dispatchQueue usingBlock:^{
        while([writerInput isReadyForMoreMediaData]){
            if(frame >=[imageArray count]){
                [writerInput markAsFinished];
                [videoWriter finishWriting];
                if (self.haveError) {
                    NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:4 userInfo:@"合成失败"];
                    self.rectListener(nil, error);
                    return ;
                }
                if (isRect) {
                    self.rectListener(self.rectVideoPath,nil);
                }else{
                    NSLog(@"  LONGGGG  %@",self.longVideoPath);
                    self.longListener(self.longVideoPath, nil);
                }
                //              [videoWriterfinishWritingWithCompletionHandler:nil];
                break;
            }
            CVPixelBufferRef buffer =NULL;
            int idx =frame;
            NSLog(@"idx==%d",idx);
            UIImage * item=[imageArray objectAtIndex:idx];
            buffer = (CVPixelBufferRef)[self pixelBufferFromCGImage:[item CGImage] size:size];
            if (buffer) {
                if(![adaptor appendPixelBuffer:buffer withPresentationTime:CMTimeMake(frame,10)])
                {
                    NSLog(@"FAIL");
                    self.haveError=true;
                    NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:4 userInfo:@"合成失败"];
                    self.rectListener(nil, error);
                }else{
                    frame++;
                    NSLog(@"OK");
                }
                CFRelease(buffer);
            }
        }
    }];
}



- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image size:(CGSize)size {
    NSDictionary *options =[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:YES],kCVPixelBufferCGImageCompatibilityKey,
                            [NSNumber numberWithBool:YES],kCVPixelBufferCGBitmapContextCompatibilityKey,nil];
    CVPixelBufferRef pxbuffer =NULL;
    CVReturn status =CVPixelBufferCreate(kCFAllocatorDefault,size.width,size.height,kCVPixelFormatType_32ARGB,(__bridge CFDictionaryRef) options,&pxbuffer);
    
    NSParameterAssert(status ==kCVReturnSuccess && pxbuffer !=NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer,0);
    
    void *pxdata =CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata !=NULL);
    CGColorSpaceRef rgbColorSpace=CGColorSpaceCreateDeviceRGB();
    CGContextRef context =CGBitmapContextCreate(pxdata,size.width,size.height,8,4*size.width,rgbColorSpace,kCGImageAlphaPremultipliedFirst);
    NSParameterAssert(context);
    CGContextDrawImage(context,CGRectMake(0,0,CGImageGetWidth(image),CGImageGetHeight(image)), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    CVPixelBufferUnlockBaseAddress(pxbuffer,0);
    return pxbuffer;
}

@end

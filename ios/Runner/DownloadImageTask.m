//
//  DownloadImageTask.m
//  Runner
//
//  Created by Apple on 2019/8/13.
//  Copyright © 2019 The Chromium Authors. All rights reserved.
//
#import "DownloadImageTask.h"
#import <Foundation/Foundation.h>
#import "GengmeiStarItem.h"

@interface DownloadImageTask()
@property (atomic, strong) NSMutableArray<GengmeiStarItem*> *listOfDownLoadImageArr;
@property(nonatomic)int size;
@property(atomic)UIImage * backImg;
@property(nonatomic) dispatch_queue_t queue;
@property(nonatomic,strong)NSMutableArray<GengmeiStarItem*>*sortPackageResListArr;
@property(atomic,strong)NSMutableArray<UIImage*> * longArr;
@property(nonatomic,strong) NSString *path;
@property(atomic)int count;
@end

@implementation DownloadImageTask


- (instancetype)init
{
    self = [super init];
    if (self) {
       self.longArr=[[NSMutableArray alloc] init];
        self.path= NSTemporaryDirectory();
        
    }
    return self;
}

-(void)getAiStarPic:(NSString*)url{
    
    
}


-(void) drawPic:(NSMutableArray *) arr:(UIImage*)background:(NSString*)name:(NSString*)value:(NSString*)str1:(NSString*)str2 handler:(void(^)(NSMutableArray<UIImage*> *_Nullable resultArr,NSError *_Nullable error))handlerr{
    if (self.queue==nil) {
        self.queue = dispatch_queue_create("com.lsy", DISPATCH_QUEUE_CONCURRENT);
    }
    @try {
        NSString * dir=[NSString stringWithFormat:@"%@/GengmeiAiLong",self.path];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        BOOL existed = [fileManager fileExistsAtPath:dir isDirectory:NO];
        if ( !(existed == YES) ) {//如果文件夹不存在
            [ fileManager createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        dispatch_async(self.queue, ^{
            UIImage *backImg=[self createShareImage:background:name:value:str1:str2];
            [self.longArr removeAllObjects];
            for(int j=0;j<arr.count ; j++){
                NSData *data = [NSData dataWithContentsOfFile:[arr[j] img]];
                UIImage * image=[UIImage imageWithData:data];
                UIImage* finalImg=[self createShareImage:backImg ContextImage:image];
                [self.longArr addObject:finalImg];
            }
            handlerr(self.longArr,nil);
        });
    } @catch (NSException *exception) {
        NSLog(@"ERROR ???>!>  %@",exception);
        NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:4 userInfo:[exception userInfo]];
        handlerr(nil,error);
    }
}


-(void) download:(NSMutableArray *)arr
                 handler:(void(^)(NSMutableArray<GengmeiStarItem *> *_Nullable resultArr,NSError *_Nullable error))handlerr{
    if (self.queue==nil) {
        self.queue = dispatch_queue_create("com.lsy", DISPATCH_QUEUE_CONCURRENT);
    }
    if (self.listOfDownLoadImageArr==nil) {
        self.listOfDownLoadImageArr=[[NSMutableArray alloc] init];
    }
    NSString *path = NSTemporaryDirectory();
    [self.listOfDownLoadImageArr removeAllObjects];
    self.size=arr.count;
    CFAbsoluteTime startTime =CFAbsoluteTimeGetCurrent();
    @try {
            for (int i = 0; i < arr.count; i++) {
                
                dispatch_async(self.queue, ^{
                NSString * tempUrl=[NSString stringWithFormat:@"%@%@",arr[i],@"?imageMogr2/quality/60?imageMogr2/thumbnail/!50p"];
                NSData *data = [NSData dataWithContentsOfURL:[NSURL  URLWithString:tempUrl]];
                UIImage *image = [UIImage imageWithData:data]; // 取得图片
                NSString *imageFilePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"image%02ld.jpg",i]];
                BOOL success = [UIImageJPEGRepresentation(image, 1) writeToFile:imageFilePath  atomically:YES];
                if (success){
                    NSLog(@"写入本地成功");
                    GengmeiStarItem * item=[[GengmeiStarItem alloc] init];
                    NSString* copy=imageFilePath;
                    item.img=copy;
                    item.count=i;
                    [self.listOfDownLoadImageArr addObject:item];
                    if (self.listOfDownLoadImageArr.count==self.size) {
                            NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"count" ascending:YES];
                             self.sortPackageResListArr = [self.listOfDownLoadImageArr sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                        NSLog(@"count : %d",self.sortPackageResListArr.count);
                        for (int i=0; i<self.sortPackageResListArr.count; i++) {
                            NSLog(@"PATH !! %@",self.sortPackageResListArr[i]);
                            
                        }
                            handlerr(self.sortPackageResListArr,nil);
                    }
                }else{
                    NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:4 userInfo:@"write To phone wrong "];
                    handlerr(nil,error);
                }
                });
        }
    } @catch (NSException *exception) {
         NSError *error = [[NSError alloc] initWithDomain:NSCocoaErrorDomain code:4 userInfo:[exception userInfo]];
        handlerr(nil,error);
        NSLog(@"Error :",exception);
    }
}


- (UIImage *)createShareImage:(UIImage *)tImage ContextImage:(UIImage *)image2
{
    UIImage *sourceImage = tImage;
    CGSize imageSize; //画的背景 大小
    imageSize = [sourceImage size];
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    [sourceImage drawAtPoint:CGPointMake(0, 0)];
    //获得 图形上下文
    CGContextRef context=UIGraphicsGetCurrentContext();
    //画 自己想要画的内容(添加的图片)
    CGContextDrawPath(context, kCGPathStroke);
    float x=0.2923;
    float x_=0.4154;
    float y=0.2814;
    CGRect rect = CGRectMake( imageSize.width*x,imageSize.height*y, imageSize.width*x_, imageSize.width*x_);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    [image2 drawInRect:rect];
    NSLog(@"share !!  ");
    //返回绘制的新图形
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)createShareImage:(UIImage *)tImage :(NSString *)starName :(NSString*)value :(NSString*)des1 :(NSString*)des2
{
    UIImage *sourceImage = tImage;
    CGSize imageSize; //画的背景 大小
    imageSize = [sourceImage size];
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    [sourceImage drawAtPoint:CGPointMake(0, 0)];
    //获得 图形上下文
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextDrawPath(context, kCGPathStroke);
     NSLog(@"图片: %f %f",imageSize.width,imageSize.height);
    if (starName!=nil) {
        CGFloat nameFont = 42.f;
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:nameFont]};
        CGRect sizeToFit = [starName boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, nameFont) options:NSStringDrawingUsesDeviceMetrics attributes:attributes context:nil];
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:51/255 green:51/255 blue:51/255 alpha:1.0].CGColor);
        float x=0.3015;
        float y=0.15614;
         [starName drawAtPoint:CGPointMake(imageSize.width*x,imageSize.height*y) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:nameFont]}];
    }
    if(value!=nil){
        CGFloat nameFont = 42.f;
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:nameFont]};
        CGRect sizeToFit = [value boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, nameFont) options:NSStringDrawingUsesDeviceMetrics attributes:attributes context:nil];
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:51/255 green:51/255 blue:51/255 alpha:1.0].CGColor);
        float x=0.6615;
        float y=0.15614;
        [value drawAtPoint:CGPointMake(imageSize.width*x,imageSize.height*y) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:nameFont]}];
    }
    
    if (des1!=nil) {
        CGFloat nameFont = 28.f;
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:nameFont]};
        CGRect sizeToFit = [des1 boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, nameFont) options:NSStringDrawingUsesDeviceMetrics attributes:attributes context:nil];
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:70/255 green:70/255 blue:70/255 alpha:1.0].CGColor);
        float x=0.1759;
        float y=0.6073;
        [des1 drawAtPoint:CGPointMake(imageSize.width*x,imageSize.height*y) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:nameFont]}];
    }
    
    if (des2!=nil) {
        CGFloat nameFont = 28.f;
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:nameFont]};
        CGRect sizeToFit = [des2 boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, nameFont) options:NSStringDrawingUsesDeviceMetrics attributes:attributes context:nil];
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:70/255 green:70/255 blue:70/255 alpha:1.0].CGColor);
        float x=0.1759;
        float y=0.6463;
        [des2 drawAtPoint:CGPointMake(imageSize.width*x,imageSize.height*y) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:nameFont]}];
    }
    
    NSLog(@"图片!!!!: %f %f",imageSize.width,imageSize.height);
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

// 1.将文字添加到图片上;imageName 图片名字， text 需画的字体
- (UIImage *)createShareImage:(UIImage *)tImage Context:(NSString *)text
{
    UIImage *sourceImage = tImage;
    CGSize imageSize; //画的背景 大小
    imageSize = [sourceImage size];
    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
    [sourceImage drawAtPoint:CGPointMake(0, 0)];
    //获得 图形上下文
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextDrawPath(context, kCGPathStroke);
    CGFloat nameFont = 8.f;
    //画 自己想要画的内容
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:nameFont]};
    CGRect sizeToFit = [text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, nameFont) options:NSStringDrawingUsesDeviceMetrics attributes:attributes context:nil];
    NSLog(@"图片: %f %f",imageSize.width,imageSize.height);
    NSLog(@"sizeToFit: %f %f",sizeToFit.size.width,sizeToFit.size.height);
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    [text drawAtPoint:CGPointMake((imageSize.width-sizeToFit.size.width)/2,0) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:nameFont]}];
    //返回绘制的新图形
    
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return newImage;
}
@end

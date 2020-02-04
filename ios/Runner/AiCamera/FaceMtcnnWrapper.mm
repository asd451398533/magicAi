#import "FaceMtcnnWrapper.h"

#include "ldmarkmodel.h"
#include "opencv+parallel_for_.h"
#import <opencv2/imgcodecs/ios.h>

@interface FaceMtcnnWrapper()
@property(atomic)Boolean isInit;
@end

@implementation FaceMtcnnWrapper
{
   ldmarkmodel* _modelt;
   std::vector<cv::Mat>* _currentShape;
}

+ (instancetype)sharedSingleton {
    static FaceMtcnnWrapper *_sharedSingleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedSingleton = [[super allocWithZone:NULL] init];
    });
    return _sharedSingleton;
}
    
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [FaceMtcnnWrapper sharedSingleton];
}
- (id)copyWithZone:(nullable NSZone *)zone {
    return [FaceMtcnnWrapper sharedSingleton];
}
- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    return [FaceMtcnnWrapper sharedSingleton];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.isInit=false;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSString* haarPath = [NSBundle.mainBundle pathForResource:@"haar_facedetection" ofType:@"xml"];
            NSString* modelPath = [NSBundle.mainBundle pathForResource:@"landmark-model" ofType:@"bin"];
            _modelt = new ldmarkmodel([haarPath UTF8String]);
            if(!load_ldmarkmodel([modelPath UTF8String], *_modelt)) {
                std::cout << "Modle Opening Failed." << [modelPath UTF8String] << std::endl;
            }
            _currentShape = new std::vector<cv::Mat>(MAX_FACE_NUM);
            self.isInit=true;
        });
    }
    return self;
}

-(cv::Mat)UIImageMat:(UIImage*)image{
    cv::Mat mat;
    UIImageToMat(image,mat);
    return mat;
}


- (int) decectImg:(UIImage *)image{
    if (!self.isInit) {
        return -1;
    }
    cv::Mat mat;
    UIImageToMat(image,mat);
    _modelt->track(mat, *_currentShape);
    parallel_for_(cv::Range(0, MAX_FACE_NUM), [&](const cv::Range& range){

    });
    if ((*_currentShape)[0].empty()) {
        return 0;
    }else if(!(*_currentShape)[0].empty()&&(*_currentShape)[1].empty()&&(*_currentShape)[2].empty()) {
        return 1;
    }else if(!(*_currentShape)[0].empty()&&!(*_currentShape)[1].empty()&&(*_currentShape)[2].empty()){
        return 2;
    }else{
        return 3;
    }
}

- (UIImage* )processImage:(UIImage*)mat
{
    if (!self.isInit) {
        return nil;
    }
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    cv::Mat image;
    UIImageToMat(mat,image);
    _modelt->track(image, *_currentShape);
    //    cv::Vec3d eav;
    //    self._modelt->EstimateHeadPose((*self._currentShape)[0], eav);
    //    self._modelt->drawPose(image, (*self._currentShape)[0], 50);
    parallel_for_(cv::Range(0, MAX_FACE_NUM), [&](const cv::Range& range){
        for (int i = range.start; i < range.end; i++){
            if (!(*_currentShape)[i].empty()){
                int numLandmarks = (*_currentShape)[i].cols / 2;
                for (int j = 0; j < numLandmarks; j++){
                    int x = (*_currentShape)[i].at<float>(j);
                    int y = (*_currentShape)[i].at<float>(j + numLandmarks);
                    cv::circle(image, cv::Point(x, y), 2, cv::Scalar(0, 0, 255), -1);
                }
            }
        }
    });
    NSLog(@"RANGE!!!!  %d",(*_currentShape)[0].empty());
    NSTimeInterval end = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@">>>> FPS: %f", 1.0f/(end - start));
    return MatToUIImage(image);
    
}
@end

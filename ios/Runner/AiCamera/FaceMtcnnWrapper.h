#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Face.h"



@interface FaceMtcnnWrapper : NSObject
- (NSArray <Face *>*)detectFace:(UIImage *)image;
+ (instancetype)sharedSingleton;
- (int) decectImg:(UIImage *)image;
- (UIImage* )processImage:(UIImage*)mat;
@end

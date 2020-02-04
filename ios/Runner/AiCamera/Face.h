#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Face : NSObject

@property (nonatomic,assign) CGRect rect;
@property (nonatomic,assign) NSArray *landmarks;

@end

#import <UIKit/UIKit.h>

typedef void(^ImageBlock)(NSDictionary *imageDictionary);
@interface TargetViewController : UIViewController
@property(nonatomic, strong)NSString *parames;
    
@property (nonatomic, copy) ImageBlock imageblock;
@end

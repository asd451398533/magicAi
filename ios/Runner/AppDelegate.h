#import <Flutter/Flutter.h>
#import <UIKit/UIKit.h>

@interface AppDelegate : FlutterAppDelegate

@property (nonatomic, strong) FlutterMethodChannel *pushChannel;
@property (nonatomic,strong) NSString*  kHostAddress;
@property (nonatomic,strong) NSString *KHostFaceAddress;
@property (strong) NSData* _expirTime;
@property (strong) NSString * uploadId;
@property (strong) NSString * key;
@property (strong) NSString * token;
@property (nonatomic,strong) dispatch_queue_t queue;
@property (nonatomic,strong) FlutterResult _result;
@end

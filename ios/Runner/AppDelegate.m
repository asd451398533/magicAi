#include "AppDelegate.h"
#include "GeneratedPluginRegistrant.h"
#import <Flutter/Flutter.h>
#import "QCloudCore.h"
#import "QCloudCOSXML/QCloudCOSXML.h"
//#import <GRPCClient/GRPCCall+Tests.h>
//#import "Cos.pbrpc.h"
//#import "Cos.pbobjc.h"
//#import "Faceapp.pbrpc.h"
//#import "Faceapp.pbobjc.h"
#import <Photos/Photos.h>
#import "Utils.h"
//#import <GRPCClient/GRPCCall.h>
#import "MyFileUtil.h"
#import "GengmeiStarSdk.h"
#import "TargetViewController.h"
#import "FaceMtcnnWrapper.h"
#import "MyTestCameraVC.h"

#import "WXApi.h"
#import "BEVideoRecorderViewController.h"



@interface AppDelegate () <QCloudSignatureProvider,WXApiDelegate>
//    @property(atomic,strong) FaceAgingService *faceService;
//    @property(atomic,strong) HLWCosService *service;
@property(nonatomic,strong)GengmeiStarSdk* sdk;
@property(nonatomic,strong)NSString *tmpPath ;
@property(atomic) NSString * taskId;
@property(nonatomic)int reDetectCount;
@property(nonatomic)FaceMtcnnWrapper * mtcnn;
@property(nonatomic) long loginKey;
@property(nonatomic)FlutterEventSink sink;
@property(nonatomic)FlutterViewController* flutterController;
@end

@implementation AppDelegate
UIViewController *viewController;
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return  [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [WXApi handleOpenURL:url delegate:self];
}
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler {
return [WXApi handleOpenUniversalLink:userActivity delegate:self];
}
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [WXApi registerApp:@"wxa51215876ed98f9e"
    universalLink:@"https://magicai.igengmei.com/apple-app-site-association/"];
    PHAuthorizationStatus auth = [PHPhotoLibrary authorizationStatus];
    if (auth == PHAuthorizationStatusDenied || auth == PHAuthorizationStatusRestricted) {
        
    }else if (auth == PHAuthorizationStatusNotDetermined){
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            NSLog(@"PHAuthorizationStatus  %ld",(long)status);
        }];
    }
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied)
    {
        // 无权限
        // do something...
    }else if (status == AVAuthorizationStatusNotDetermined){
        
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            NSLog(@"AVAuthorizationStatus  %d",granted);
        }];
    }
#if ENABLE_FABRIC
    [Fabric with:@[[Crashlytics class]]];
#endif
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
    
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    
//    [SenseArMaterialService switchToServerType:DomesticServer];
    self.mtcnn=[FaceMtcnnWrapper sharedSingleton];
    self.tmpPath= NSTemporaryDirectory();
    self.sdk= [GengmeiStarSdk sharedSingleton];
    [GeneratedPluginRegistrant registerWithRegistry:self];
    [self setupCOSXMLShareService];
    self.kHostAddress=@"154.8.188.247:10030";
    self.KHostFaceAddress=@"140.143.212.49:50031";
    //        [GRPCCall useInsecureConnectionsForHost:self.KHostFaceAddress];
    //        [GRPCCall useInsecureConnectionsForHost:self.kHostAddress];
    //        self.faceService=[FaceAgingService serviceWithHost:self.KHostFaceAddress];
    //        self.service= [HLWCosService serviceWithHost:self.kHostAddress];
     self.flutterController =
    (FlutterViewController*)self.window.rootViewController;
    
    viewController =
    [UIApplication sharedApplication].delegate.window.rootViewController;
    self.queue =  dispatch_queue_create("com.xxcc", DISPATCH_QUEUE_SERIAL);
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backValue:) name:@"backValue"object:nil];
    
    NSLog(@"ID %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"]);
    FlutterMethodChannel* batteryChannel = [FlutterMethodChannel
                                            methodChannelWithName:@"samples.flutter.io/startFaceAi"
                                            binaryMessenger:self.flutterController];
    
    [batteryChannel setMethodCallHandler:^(FlutterMethodCall* call,
                                           FlutterResult result) {
        self._result=result;
        if ([@"uploadImg" isEqualToString:call.method]){
            NSDictionary* array=call.arguments;
            NSString * img=array[@"imagepath"];
            [self uploadImg:[NSURL fileURLWithPath:img]:[MyFileUtil GetFileName:img]];
        }else  if([@"startFaceAi" isEqualToString:call.method]){
            //                NSDictionary *args = call.arguments;
            //                NSString * url=args[@"URL"];
            //                NSNumber* age=args[@"AGE"];
            //                NSNumber* wantAge=args[@"WANT_AGE"];
            //                NSNumber* male=args[@"IS_MALE"];
            //                NSLog(@"face %@  %@  %@ %@",url,age,wantAge,male);
            //                dispatch_async(self.queue, ^{
            //                    AsyncAgingRequest * faceRequest=[AsyncAgingRequest message];
            //                    if (wantAge < 10) {
            //                        faceRequest.type = AgingType_Young0;
            //                    } else if (wantAge < 20) {
            //                        faceRequest.type = AgingType_Young1;
            //                    } else if (wantAge < 30) {
            //                        faceRequest.type = AgingType_Young2;
            //                    } else if (wantAge < 40) {
            //                        faceRequest.type = AgingType_Young3;
            //                    } else if (wantAge < 50) {
            //                        faceRequest.type = AgingType_Young4;
            //                    } else if (wantAge < 60) {
            //                        faceRequest.type = AgingType_Young5;
            //                    } else if (wantAge < 70) {
            //                        faceRequest.type = AgingType_Young6;
            //                    } else if (wantAge < 80) {
            //                        faceRequest.type = AgingType_Young7;
            //                    } else if (wantAge < 90) {
            //                        faceRequest.type = AgingType_Young8;
            //                    } else if (wantAge < 100) {
            //                        faceRequest.type = AgingType_Young0;
            //                    } else {
            //                        faceRequest.type = AgingType_Old;
            //                    }
            //                    faceRequest.algorithmModel=AsyncAgingRequest_AlgorithmModel_Model1;
            //                    if (male) {
            //                        faceRequest.gender=AsyncAgingRequest_Gender_Male;
            //                    }else{
            //                        faceRequest.gender=AsyncAgingRequest_Gender_Female;
            //                    }
            //                    faceRequest.age=age;
            //                    faceRequest.URL=url;
            //                    faceRequest.userId=url;
            ////                    [faceRequest setURL:url];
            //                    faceRequest.checkFace=true;
            //                    [self.faceService asyncGenerateWithRequest:faceRequest handler:^(AsyncAgingResponse * _Nullable response,NSError * _Nullable error) {
            //                        if (![Utils isNullObject:error]) {
            //                            NSLog(@"face Error %@",error);
            //                            self._result([FlutterError errorWithCode:@"11" message:@"AI FACE接口失败 " details:@".,."]);
            //                        }else{
            //                            self.taskId=[response taskId];
            //                            [self performSelector:@selector(delayMethod) withObject:nil afterDelay:0.5];
            //                        }
            //                    }];
            //                });
        }else if([@"aiCamera" isEqualToString:call.method]){
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationCenter:) name:@"NSNotificationCenter" object:nil];
            NSString *mediaType = AVMediaTypeVideo;//读取媒体类型
            AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];//读取设备授权状态
            if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied){
                NSString *errorStr = @"应用相机权限受限,请在iPhone的“设置-隐私-相机”选项中，允许好享玩访问你的相机。";
                NSLog(@"相机不可用");
            } else {
                NSLog(@"相机可用");
                [self aiCamera];
            }
        }else if([@"execStar" isEqualToString:call.method]){
            NSDictionary *args = call.arguments;
            NSString * url=args[@"filePath"];
            [self ffmp:url];
        }else if ([@"detectPic" isEqualToString:call.method]){
            NSDictionary *args = call.arguments;
            NSLog(@"flutter传给原生的参数：%@", args);
            NSString *img=args[@"imagepath"];
            NSURL* url = [NSURL fileURLWithPath:img];
            UIImage *image =  [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            //      [mtcnn decectImg:image];
            self.reDetectCount=0;
            [self dectImg:image];
        }else if([@"execStarLong" isEqualToString:call.method]){
            UIImage* thumbimage = [UIImage imageNamed:@"ios"];
            NSString *path22 = [[NSBundle mainBundle] bundlePath];
            NSString * filePath = [NSString stringWithFormat:@"%@%@",path22,@"/ios"];
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            UIImage * image=[UIImage imageWithData:data];
            NSLog(@"path !! %@",filePath);
            [self.sdk execLongVideo:thumbimage videoPath:[NSString   stringWithFormat:@"%@temp1.mp4",self.tmpPath] handler:^(NSString * _Nullable res,  NSError * _Nullable error) {
                if (error!=nil||res==nil) {
                    NSLog(@"error %@",error);
                }else{
                    result(res);
                }
            }];
        }else if([@"quitStarTask" isEqualToString:call.method]){
            [self.sdk quitStarTask];
            self._result(0);
        }else if([@"senSDK" isEqualToString:call.method]){
            NSString* path = call.arguments[0];
            NSString* face =call.arguments[1];
            NSString* eye=call.arguments[2];
            NSData *data = [NSData dataWithContentsOfFile:path];
            UIImage * printerImg = [UIImage imageWithData:data];
            MyTestCameraVC*vc=[MyTestCameraVC new];
//            BEVideoRecorderViewController *vc=[BEVideoRecorderViewController new];
            vc.image=printerImg;
            vc.face=face;
            vc.eye=eye;
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [viewController presentViewController:vc animated:YES completion:nil];
//            MyTestVC* ppvc=[MyTestVC new];
//            ppvc.makeIndex=-10086;
//            ppvc.imageOriginal = printerImg;
//            ppvc.modalPresentationStyle = UIModalPresentationFullScreen;
//            [viewController presentViewController:ppvc animated:YES completion:nil];
        }else if ([@"demo" isEqualToString:call.method]){
//            BEVideoRecorderViewController *vc=[BEVideoRecorderViewController new];
            NSString* face =call.arguments[0];
            NSString* eye=call.arguments[1];
            MyTestCameraVC*vc=[MyTestCameraVC new];
            vc.face=face;
            vc.eye=eye;
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [viewController presentViewController:vc animated:YES completion:nil];
        }else if([@"loginWX" isEqualToString:call.method] ){
            [self sendAuthRequest];
        }else if([@"jrSDK" isEqualToString:call.method]){
//                BEVideoRecorderViewController *recordVC = [[BEVideoRecorderViewController alloc] init];
        }
    }];
    FlutterEventChannel* chargingChannel = [FlutterEventChannel
                                            eventChannelWithName:@"samples.flutter.io/startFaceAi_flutter"
                                            binaryMessenger:self.flutterController];
    [chargingChannel setStreamHandler:self];
    
//        [self performSelector:@selector(delaa) withObject:nil/*可传任意类型参数*/ afterDelay:5];
    
    
    return [super application:application didFinishLaunchingWithOptions:launchOptions];
    
}

-(void)delaa{
    NSLog(@"DELAA ");
    if(self.sink){
        self.sink(@"哈wqewqewqe");
    }
}

-(void) backValue:(NSNotification *)text{
    NSMutableDictionary* dict=[text object];
    NSString *ori=dict[@"oriPath"];
    NSString *newPath=dict[@"newPath"];
    NSString *indexText=dict[@"INDEX"];
    NSMutableArray*arr=[NSMutableArray new];
    if(ori!=nil&&newPath!=nil&&indexText!=nil){
        [arr addObject:newPath];
        [arr addObject:indexText];
        [arr addObject:ori];
        self._result(arr);
    }
}

-(void)sendAuthRequest
{
    //构造SendAuthReq结构体
    
    SendAuthReq* req =[[SendAuthReq alloc]init];
    req.scope = @"snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";
    req.state = @"123";
    req.openID=@"wxa51215876ed98f9e";
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendAuthReq:req viewController:viewController delegate:self completion:^(BOOL success) {
        
    }];
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {

    } else if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *response=(SendAuthResp *)resp;
        NSString *strTitle = [NSString stringWithFormat:@"Auth结果"];
        NSString *strMsg = [NSString stringWithFormat:@"code:%@,state:%@,errcode:%d", response.code, response.state, response.errCode];
        NSMutableDictionary *dict=[NSMutableDictionary new];
        [dict setObject:response.code forKey:@"code"];
        [dict setObject:response.state forKey:@"state"];
        [dict setObject:[NSNumber numberWithInt:response.errCode] forKey:@"errcode"];
        NSLog(strTitle);
        NSLog(strMsg);
        self._result(dict);
    }
}

-(void)aiCamera{
    TargetViewController* col=[[TargetViewController alloc]init];
    col.modalPresentationStyle = 0;
    [viewController presentViewController:col animated:YES completion:nil];
    
}

- (void)notificationCenter :(NSNotification *)notification{
    NSMutableDictionary * path= [notification object];
    NSLog([NSString stringWithFormat:@"%@",path]);
    if(path !=nil){
        self._result(path);
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSLog(@"%@",info);
    UIImage *image= info[@"UIImagePickerControllerEditedImage"];
    UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(100, 100, 200, 200)];
    iv.image = image;
    [viewController.view addSubview:iv];
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void) setupCOSXMLShareService {
    @try {
        QCloudServiceConfiguration* configuration = [QCloudServiceConfiguration new];
        configuration.signatureProvider = self;
        QCloudCOSXMLEndPoint* endpoint = [[QCloudCOSXMLEndPoint alloc] init];
        endpoint.regionName = @"ap-beijing";
        configuration.endpoint = endpoint;
        [QCloudCOSXMLService registerDefaultCOSXMLWithConfiguration:configuration];
        [QCloudCOSTransferMangerService registerDefaultCOSTransferMangerWithConfiguration:configuration];
    } @catch (NSException *exception) {
        NSLog(@"exception%@",exception);
    } @finally {
        
    }
}


-(void) dectImg:(UIImage*)image{
    if (self.reDetectCount>30) {
        self._result(@"没有检测到人脸");
        return;
    }
    NSLog(@"第几次？？%d",self.reDetectCount);
    self.reDetectCount++;
    int faceCount=[self.mtcnn decectImg:image];
    if (faceCount==-1) {
        self._result(@"模型未加载成功");
    }else if (faceCount==0) {
        [self dectImg:image];
    }else if(faceCount==1){
        self._result(@"success");
    }else{
        self._result(@"检测到多张人脸！！");
    }
}


#pragma mark - <FlutterStreamHandler>
- (FlutterError* _Nullable)onListenWithArguments:(id _Nullable)arguments
                                       eventSink:(FlutterEventSink)events {
    self.sink=events;
    return nil;
}

/// flutter不再接收
- (FlutterError* _Nullable)onCancelWithArguments:(id _Nullable)arguments {
    // arguments flutter给native的参数
    NSLog(@"%@", arguments);
    return nil;
}


-(void)uploadImg:(NSURL*)imgPathUrl:(NSString*)imgName{
    //        dispatch_async(self.queue, ^{
    //            HLWGetCredentialRequest *request = [HLWGetCredentialRequest message];
    //            [self.service getCredentialWithRequest:(request) handler:^(HLWGetCredentialResponse * _Nullable response, NSError * _Nullable error) {
    //                NSLog(@"error  %@",error);
    //                if (![Utils isNullObject:error] ) {
    //                    self._result([FlutterError errorWithCode:@"11" message:@"上传获取key接口 出错 ！！！ " details:@".,."]);
    //                    return ;
    //                }
    //                //            NSLog(@" time %@, %@ , %@, %@  ",[NSString stringWithFormat:@"%d", response.expiredTime],response.credential.tmpSecretId,response.credential.tmpSecretKey,response.credential.sessionToken);
    //                self.uploadId=response.credential.tmpSecretId;
    //                self.key=response.credential.tmpSecretKey;
    //                self.token=response.credential.sessionToken;
    //                self._expirTime=[Utils getLocateTime:response.expiredTime];
    //                QCloudCOSXMLUploadObjectRequest* put = [QCloudCOSXMLUploadObjectRequest new];
    //                put.object =[NSString stringWithFormat:@"%@%@%@",@"/cos/",[Utils getNowTimeTimestamp3],imgName];
    //                put.bucket = @"lab-1258538551";
    //                put.body =  imgPathUrl;
    //                put.uploadid=nil;
    //                [put.customHeaders setObject:@"image/jpeg" forKey:@"Content-Type"];
    //                [put setSendProcessBlock:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
    //                    NSLog(@"upload %lld totalSend %lld aim %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
    //                }];
    //                [put setFinishBlock:^(id outputObject, NSError* error) {
    //                    dispatch_async(dispatch_get_main_queue(), ^{
    //                        if ([Utils isNullObject:error]) {
    //                            NSString* url=[((QCloudUploadObjectResult*)outputObject) location];
    //                            NSLog(@"url %@",url);
    //                            self._result(url);
    //                        }else{
    //                            self._result([FlutterError errorWithCode:@"11" message:@"上传失败" details:@"11"]);
    //                        }
    //                    });
    //                }];
    //                [[QCloudCOSTransferMangerService defaultCOSTransferManager] UploadObject:put];
    //            }];
    //        });
}

- (void)delayMethod {
    //        dispatch_async(self.queue, ^{
    //            PollGenerateRequest *request=[PollGenerateRequest message];
    //            request.taskId=self.taskId;
    //            [self.faceService pollAsyncGenerateWithRequest:request handler:^(PollGenerateResponse * _Nullable response, NSError * _Nullable error) {
    //                if (![Utils isNullObject:error]) {
    //                    NSLog(@"face Error %@",error);
    //                    self._result([FlutterError errorWithCode:@"11" message:error details:@"11"]);
    //                }else{
    //                    dispatch_async(dispatch_get_main_queue(), ^{
    ////                        self._result([response generateURL]);
    //                        if ([response.taskStatus isEqual:@"success"]){
    //                            NSLog(@"face success %@。%@",[response generateURL],[response sourceURL]);
    //                            self._result([response generateURL]);
    //                        }else if([response.taskStatus isEqual:@"pending"]){
    //                            NSLog(@"face loading ");
    //                            [self performSelector:@selector(delayMethod) withObject:nil afterDelay:0.5];
    //                        }else {
    //                            NSLog(@"face error  %@",response.taskStatus);
    //                            self._result([FlutterError errorWithCode:@"11" message:@"AI FACE接口失败 " details:@".,."]);
    //                        }
    //                    });
    //                }
    //            }];
    //        });
}

- (void) signatureWithFields:(QCloudSignatureFields*)fileds
                     request:(QCloudBizHTTPRequest*)request
                  urlRequest:(NSMutableURLRequest*)urlRequst
                   compelete:(QCloudHTTPAuthentationContinueBlock)continueBlock
{
    QCloudCredential* credential = [QCloudCredential new];
    credential.secretID =self.uploadId;
    credential.secretKey = self.key;
    credential.token = self.token;
    credential.experationDate= self._expirTime;
    QCloudAuthentationV5Creator* creator = [[QCloudAuthentationV5Creator alloc] initWithCredential:credential];
    QCloudSignature* signature =  [creator signatureForData:urlRequst];
    continueBlock(signature, nil);
}
-(void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    [[[viewController navigationController] navigationBar] setHidden:NO];
}

-(void)ffmp:(NSString*) url{
    
    [self.sdk execRectVideo:url videoPath:[NSString stringWithFormat:@"%@temp.mp4",self.tmpPath] stepCount:20 handler:^(NSString * _Nullable response, NSError * _Nullable error) {
        if (error!=nil||response==nil) {
            
            self._result([FlutterError errorWithCode:@"11" message:error details:@"11"]);
        }else{
            self._result(response);
        }
    }];
}
@end

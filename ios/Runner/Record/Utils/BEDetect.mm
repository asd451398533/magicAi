// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.

#import <Foundation/Foundation.h>
#import "BEDetect.h"
#import "bef_effect_ai_hand.h"
#import "bef_effect_ai_face_detect.h"
#import "bef_effect_ai_skeleton.h"
#import "bef_effect_ai_public_define.h"
#import "bef_effect_ai_face_attribute.h"
#import "bef_effect_ai_hairparser.h"
#import "bef_effect_ai_portrait_matting.h"
#import "bef_effect_ai_face_verify.h"
#import "bef_effect_ai_yuv_process.h"
//#import "bef_effect_ai_human_distance.h"
#import <UIKit/UIKit.h>
#import "bef_effect_ai_face_clustering.h"
#include <vector>
#include <map>

@interface BEDetect() {
    bef_effect_handle_t faceDetectHandle;
    bef_effect_handle_t skeletonDetectHandle;
    bef_ai_hand_sdk_handle handDetectHandle;
    bef_effect_handle_t faceAttributeDetectHandle;
    bef_effect_handle_t hairparserDetectHandle;
    bef_effect_handle_t portraitDetectHandle;
    
    bef_effect_handle_t faceVerifyDetectHandle;
    bef_effect_handle_t faceVerifyHandle;
    
    bef_effect_handle_t faceDistanceFaceDetectHandle;
    bef_effect_handle_t faceDistanceFaceAttribyteDetectHandle;
    bef_effect_handle_t faceDistanceDetectHandle;
    
    //handle
    bef_effect_handle_t faceClusteringFaceDetectHandle;
    bef_effect_handle_t faceClusteringFaceExtractFeatureHandle;
    bef_effect_handle_t faceClusteringHandle;
    
    bef_effect_handle_t petFaceHandle;
    bef_effect_handle_t lightClsHandle;
    
    float               _currentFaceVerifyFeature[BEF_AI_FACE_FEATURE_DIM];
}

@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) int bytersPerRow;

@end

@implementation BEDetect

static NSString *LICENSE_PATH;
static NSString *const FACE_MODEL = @"/ttfacemodel/tt_face_v6.0.model";
static NSString *const FACE_MODEL_EXTRA = @"/ttfacemodel/tt_face_extra_v9.0.model";
static NSString *const FACE_ATTRIBUTE_MODEL = @"/ttfaceattri/tt_face_attribute_v4.1.model";
static NSString *const FACE_VERIFY_MODEL = @"/ttfaceverify/tt_faceverify_v5.0.model";
static NSString *const SKELETON_MODEL = @"/skeleton_model/tt_skeleton_v5.0.model";
static NSString *const HAND_DET_MODEL = @"/handmodel/tt_hand_det_v7.0.model";
static NSString *const HAND_GESTURE_MODEL = @"/handmodel/tt_hand_gesture_v8.0.model";
static NSString *const HAND_SEG_MODEL = @"/handmodel/tt_hand_seg_v1.0.model";
static NSString *const HAND_KP_MODEL = @"/handmodel/tt_hand_kp_v5.0.model";
static NSString *const HAND_BOX_MODEL = @"/handmodel/tt_hand_box_reg_v8.0.model";
static NSString *const HAIR_PARSER_MODEL = @"/hairparser/tt_hair_v7.0.model";
static NSString *const PORTRAIT_MODEL = @"/mattingmodel/tt_matting_v9.0.model";
static NSString *const PET_FACE_MODEL = @"/ttpetface/tt_petface_v2.4.model";
static NSString *const LIGHTCLS_MODEL = @"/lightcls/tt_lightcls_v1.0.model";


- (void) RBGToYVU:(unsigned char* )buffer dst:(unsigned char *)dst srcFormat:(bef_ai_pixel_format)format
          inWidth:(int)iWidth inHeight:(int)iHeight outWidth:(int)oWidth outHeight:(int)oHeight oirentation:(bef_ai_rotate_type)orientation flipped:(bool)flipped
{
    cvt_yuv2rgba(buffer, dst, format, iWidth, iHeight, oWidth, oHeight, orientation, flipped);
}

-(instancetype) init{
    self = [super init];
    if (self){
        _width = 0;
        _height = 0;
        _bytersPerRow = 0;
        
    }
    return self;
}

- (void) setSDKWidth:(int)width height:(int)height bytePerRow:(int)bytes
{
    _width = width;
    _height = height;
    _bytersPerRow = bytes;
}

-(void)setupEffectDetectSDKWithLicenseVersion:(NSString*)path{
    LICENSE_PATH = [path mutableCopy];
    
    [self _setupFaceModel];
    [self _setupHandModel];
    [self _setupSkeletonModel];
    [self _setupHairParserModel];
    [self _setupPortraitModel];
    [self _setupFaceVerifyModel];
//    [self _setupFaceDistanceModel];
    [self _setupFaceClusteringHandle];
    [self _setupPetFaceModel];
    [self _setupLightclsModel];
}

- (void) releaseEffcetDetectSDK{
    LICENSE_PATH = @"";
    bef_effect_ai_hand_detect_destroy(handDetectHandle);
    bef_effect_ai_skeleton_destroy(skeletonDetectHandle);
    bef_effect_ai_hand_detect_destroy(handDetectHandle);
    bef_effect_ai_hairparser_destroy(hairparserDetectHandle);
    bef_effect_ai_portrait_matting_destroy(portraitDetectHandle);
    
    bef_effect_ai_face_attribute_destroy(faceAttributeDetectHandle);
    bef_effect_ai_face_verify_destroy(faceVerifyHandle);
    bef_effect_ai_face_detect_destroy(faceVerifyDetectHandle);
    bef_effect_ai_face_detect_destroy(faceDetectHandle);
    bef_effect_ai_hand_detect_destroy(faceDistanceFaceDetectHandle);
    
    //人脸距离检测句柄的销毁
//    bef_effect_ai_human_distance_destroy(faceDistanceDetectHandle);
//    bef_effect_ai_face_attribute_destroy(faceDistanceFaceAttribyteDetectHandle);
    
    //人脸聚类句柄的销毁
    bef_effect_ai_face_detect_destroy(faceClusteringFaceDetectHandle);
    bef_effect_ai_face_verify_destroy(faceClusteringFaceExtractFeatureHandle);
    bef_effect_ai_fc_release(faceClusteringHandle);
    
    // release pet face handle
    bef_effect_ai_pet_face_release(petFaceHandle);
}

/**
 设置宠物脸模型
 */
- (void)_setupPetFaceModel {
    NSString *licensePath = [self be_licensePath];
    NSString *modelPath = [self be_modelPath];
    NSString *petFaceModel = [modelPath stringByAppendingString:PET_FACE_MODEL];

    bef_effect_result_t result;
    // create pet face detect model
    result = bef_effect_ai_pet_face_create(petFaceModel.UTF8String, BEF_DetCat|BEF_DetDog, AI_MAX_PET_NUM, &petFaceHandle);
    if (result != BEF_RESULT_SUC) {
        NSLog(@"bef_effect_ai_pet_face_create error: %d", result);
    }

    result = bef_effect_ai_pet_face_check_license(petFaceHandle, licensePath.UTF8String);
    if (result != BEF_RESULT_SUC) {
        NSLog(@"bef_effect_ai_pet_face_check_license error: %d", result);
    }
}

/*
 *设置人脸比对的模型
 */

- (void)_setupFaceVerifyModel{
    NSString *licbag = [self be_licensePath];
    NSString *resourceBundleName = [self be_modelPath];
    
    NSString *faceModel = [resourceBundleName stringByAppendingString:FACE_MODEL];
    NSString *faceVerifyModel = [resourceBundleName stringByAppendingString:FACE_VERIFY_MODEL];
    
    bef_effect_result_t result;
    
    //创建人脸检测模型
    result = bef_effect_ai_face_detect_create(BEF_DETECT_MODE_IMAGE_SLOW|BEF_DETECT_SMALL_MODEL|BEF_FACE_DETECT, faceModel.UTF8String, &faceVerifyDetectHandle);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_face_verify_detect_create error: %d", result);
    }
    
    //检测人脸检测模型license
    result = bef_effect_ai_face_check_license(faceVerifyDetectHandle, licbag.UTF8String);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_face_verify_check_license error: %d", result);
    }
    
    //创建人脸比对模型
    result = bef_effect_ai_face_verify_create(faceVerifyModel.UTF8String, BEF_AI_MAX_FACE_VERIFY_NUM, &faceVerifyHandle);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_face_verify_create error: %d", result);
    }
    
    //检测人脸比对模型lincese
    result = bef_effect_ai_face_verify_check_license(faceVerifyHandle, licbag.UTF8String);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_face_verify_check_license error: %d", result);
    }

}

/*
 *设置人体分割的模型
 */
- (void) _setupPortraitModel{
    NSString *licbag = [self be_licensePath];
    
    NSString *resourceBundleName = [self be_modelPath];
    NSString *portraitModel = [resourceBundleName stringByAppendingString:PORTRAIT_MODEL];
    
    bef_effect_result_t result;
    
    //人体分割检测模型的初始化
    result = bef_effect_ai_portrait_matting_create(&portraitDetectHandle);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_portrait_matting_create error: %d", result);
    }
    
    //检测人体的模型license
    result = bef_effect_ai_matting_check_license(portraitDetectHandle, licbag.UTF8String);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_matting_check_license error: %d", result);
    }
    
    //传入参数模型,这里可以选择模型的大小
    result = bef_effect_ai_portrait_matting_init_model(portraitDetectHandle, BEF_MP_LARGE_MODEL, portraitModel.UTF8String);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_hairparser_init_model error: %d", result);
    }
    
    //设置模型参数
    result = bef_effect_ai_portrait_matting_set_param(portraitDetectHandle, BEF_MP_EdgeMode, 1);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_portrait_matting_set_param edge error: %d", result);
    }
    
    //设置模型参数
    result = bef_effect_ai_portrait_matting_set_param(portraitDetectHandle, BEF_MP_FrashEvery, 15);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_portrait_matting_set_param frash evevy error: %d", result);
    }
}

/*
 *设置头发分割的模型
 */
- (void) _setupHairParserModel{
    NSString *licbag = [self be_licensePath];
    
    NSString *resourceBundleName = [self be_modelPath];
    NSString *hairparserModel = [resourceBundleName stringByAppendingString:HAIR_PARSER_MODEL];
    
    bef_effect_result_t result;
    
    //头发检测模型初始化
    result = bef_effect_ai_hairparser_create(&hairparserDetectHandle);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_hairparser_create error: %d", result);
    }
    
    //检测头发模型license
    result = bef_effect_ai_hairparser_check_license(hairparserDetectHandle, licbag.UTF8String);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_hairparser_check_license error: %d", result);
    }
    
    //传入参数模型
    result = bef_effect_ai_hairparser_init_model(hairparserDetectHandle, hairparserModel.UTF8String);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_hairparser_init_model error: %d", result);
    }
    
    //设置头发模型 width = 124 height = 224 后面两个传入TRUE即可
    result = bef_effect_ai_hairparser_set_param(hairparserDetectHandle, 128, 224, TRUE, TRUE);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_hairparser_set_param error: %d", result);
    }
}

/*
 *初始化人脸检测模型
 */
- (void) _setupFaceModel {
    NSString *licbag = [self be_licensePath];
    
    NSString *resourceBundleName = [self be_modelPath];
    NSString *faceModel = [resourceBundleName stringByAppendingString:FACE_MODEL];
    
    bef_effect_result_t result;
    // 人脸检测初始化，传入算法模型文件路径
    // 这里使用了 BEF_DETECT_FULL, 因此会加载嘟嘴和眨眼模块
    result = bef_effect_ai_face_detect_create(BEF_DETECT_SMALL_MODEL | BEF_DETECT_FULL | BEF_DETECT_MODE_VIDEO, faceModel.UTF8String, &faceDetectHandle);
    if (result != BEF_RESULT_SUC) {
        NSLog(@"byted_effect_face_detect_create error: %d", result);
    }
    
    // 检查人脸检测license
    result = bef_effect_ai_face_check_license(faceDetectHandle, licbag.UTF8String);
    if (result != BEF_RESULT_SUC) {
        NSLog(@"byted_effect_face_check_license error: %d", result);
    }
    
    result = bef_effect_ai_face_detect_setparam(faceDetectHandle, BEF_FACE_PARAM_FACE_DETECT_INTERVAL, 15);
    if (result != BEF_RESULT_SUC) {
        NSLog(@"byted_effect_face_detect_setparam error: %d", result);
    }
    
    result = bef_effect_ai_face_detect_setparam(faceDetectHandle, BEF_FACE_PARAM_MAX_FACE_NUM, 10);
    if (result != BEF_RESULT_SUC) {
        NSLog(@"byted_effect_face_detect_setparam error: %d", result);
    }
    
    // 传入人脸检测280模型
    NSString* faceExtraModel = [resourceBundleName stringByAppendingString:FACE_MODEL_EXTRA];
    result = bef_effect_ai_face_detect_add_extra_model(faceDetectHandle, TT_MOBILE_FACE_280_DETECT , faceExtraModel.UTF8String);
    
    if (result != BEF_RESULT_SUC) {
        NSLog(@"byted_effect_face_detect_add_extra_model error: %d", result);
    }
    
    //人脸属性检测模型
    NSString* faceAttriModel = [resourceBundleName stringByAppendingString:FACE_ATTRIBUTE_MODEL];
    
    result = bef_effect_ai_face_attribute_create(0, faceAttriModel.UTF8String, &faceAttributeDetectHandle);
    if (result != BEF_RESULT_SUC) {
        NSLog(@"byted_effect_face_ai_attribute_model error: %d", result);
    }
    
    //人脸属性检测模型检测license
    result = bef_effect_ai_face_attribute_check_license(faceAttributeDetectHandle, licbag.UTF8String);
    
    if (result != BEF_RESULT_SUC) {
        NSLog(@"byted_effect_face_ai_check_license error: %d", result);
    }
}

/*
 * 设置人体关键点检测的模型
 */
- (void) _setupSkeletonModel {
    NSString *resourceBundleName = [self be_modelPath];
    NSString *licbag = [self be_licensePath];
    
    bef_effect_result_t result;
    
    //人体骨骼点检测初始化，传入算法模型文件路径
    //创建模型
    NSString *skeletonModel = [resourceBundleName stringByAppendingString:SKELETON_MODEL];
    
    result = bef_effect_ai_skeleton_create(skeletonModel.UTF8String, &skeletonDetectHandle);
    
    if (result != BEF_RESULT_SUC) {
        NSLog(@"byted_effect_skeleton_detect_create error: %d", result);
    }
    
    //检测llicense
    result = bef_effect_ai_skeleton_check_license(skeletonDetectHandle, licbag.UTF8String);
    
    if (result != BEF_RESULT_SUC){
        NSLog(@"byted_effect_skeleton_check_license error: %d", result);
    }
    
//    //设置人体骨骼点检测的参数
//    result = bef_effect_ai_skeleton_setparam(skeletonDetectHandle, 128, 224);
//    if (result != BEF_RESULT_SUC){
//        NSLog(@"byted_effect_skeleton_detect_setparam error: %d", result);
//    }
    
    //设置人体最大骨骼点检测参数
    result = bef_effect_ai_skeleton_set_targetnum(skeletonDetectHandle, 1);
    
    if (result != BEF_RESULT_SUC) {
        NSLog(@"byted_effect_skeleton_detect_targetnum error: %d", result);
    }
}

- (void) _setupHandModel{
    NSString *resourceBundleName = [self be_modelPath];
    NSString *licbag = [self be_licensePath];
    
    bef_effect_result_t result;
    result = bef_effect_ai_hand_detect_create(&handDetectHandle, 0);
    if (result != BEF_RESULT_SUC){
        NSLog(@"byted_effect_hand_detect_init error: %d", result);
    }
    
    //手掌license检测
    result = bef_effect_ai_hand_check_license(handDetectHandle, licbag.UTF8String);
    if (result != BEF_RESULT_SUC){
        NSLog(@"byted_effect_hand_detect_check_license error: %d", result);
    }
    
    //手掌检测初始化
    NSString *handDetectModelPath = [resourceBundleName stringByAppendingString:HAND_DET_MODEL];
    result = bef_effect_ai_hand_detect_setmodel(handDetectHandle, BEF_HAND_MODEL_DETECT, handDetectModelPath.UTF8String);
    if (result != BEF_RESULT_SUC){
        NSLog(@"byted_effect_hand_detect_set_detect_model error: %d", result);
    }

    //手掌框检测初始化
    NSString *handDetectBoxModelPath = [resourceBundleName stringByAppendingString:HAND_BOX_MODEL];
    result = bef_effect_ai_hand_detect_setmodel(handDetectHandle, BEF_HAND_MODEL_BOX_REG, handDetectBoxModelPath.UTF8String);
    if (result != BEF_RESULT_SUC){
        NSLog(@"byted_effect_hand_detect_set_detect_box_model error: %d", result);
    }
    
    //手势检测初始化
    NSString *handDetectGesModelPath = [resourceBundleName stringByAppendingString:HAND_GESTURE_MODEL];
    result = bef_effect_ai_hand_detect_setmodel(handDetectHandle, BEF_HAND_MODEL_GESTURE_CLS, handDetectGesModelPath.UTF8String);
    if (result != BEF_RESULT_SUC){
        NSLog(@"byted_effect_hand_detect_set_detect_ges_model error: %d", result);
    }
    
    //手掌关键点检测初始化
    NSString *handDetectKeyModelPath = [resourceBundleName stringByAppendingString:HAND_KP_MODEL];
    result = bef_effect_ai_hand_detect_setmodel(handDetectHandle, BEF_HAND_MODEL_KEY_POINT, handDetectKeyModelPath.UTF8String);
    if (result != BEF_RESULT_SUC){
        NSLog(@"byted_effect_hand_detect_set_detect_key_point_model error: %d", result);
    }
    
    //设置最大检测手掌数量
    result = bef_effect_ai_hand_detect_setparam(handDetectHandle, BEF_HAND_MAX_HAND_NUM, 1);
    if (result != BEF_RESULT_SUC){
        NSLog(@"byted_effect_hand_detect_set_max_hand_count error: %d", result);
    }
    
    result = bef_effect_ai_hand_detect_setparam(handDetectHandle, BEF_HAND_NARUTO_GESTURE, 1);
    if (result != BEF_RESULT_SUC){
        NSLog(@"byted_effect_hand_detect_set_max_hand_count error: %d", result);
    }
    
    //设置回归模型的输入初始框的放大比列
    result = bef_effect_ai_hand_detect_setparam(handDetectHandle, BEF_HNAD_ENLARGE_FACTOR_REG, 2.0);
    if (result != BEF_RESULT_SUC){
        NSLog(@"byted_effect_hand_detect_set_max_hand_count error: %d", result);
    }
}

/*
 * 人脸距离估计初始化
 */
//- (void) _setupFaceDistanceModel{
//    NSString *licbag = [self be_licensePath];
//
//    NSString *resourceBundleName = [self be_modelPath];
//    NSString *faceModel = [resourceBundleName stringByAppendingString:FACE_MODEL];
//    NSString *faceAttriModel = [resourceBundleName stringByAppendingString:FACE_ATTRIBUTE_MODEL];
//
//    bef_effect_result_t result;
//
//    //创建人脸检测模型
//    result = bef_effect_ai_face_detect_create(BEF_DETECT_SMALL_MODEL|BEF_FACE_DETECT, faceModel.UTF8String, &faceDistanceFaceDetectHandle);
//    if (result != BEF_RESULT_SUC){
//        NSLog(@"bef_effect_ai_face_verify_detect_create error: %d", result);
//    }
//
//    //检测人脸检测模型license
//    result = bef_effect_ai_face_check_license(faceDistanceFaceDetectHandle, licbag.UTF8String);
//    if (result != BEF_RESULT_SUC){
//        NSLog(@"bef_effect_ai_face_verify_check_license error: %d", result);
//    }
//
//    //人脸属性检测模型
//    result = bef_effect_ai_face_attribute_create(0, faceAttriModel.UTF8String, &faceDistanceFaceAttribyteDetectHandle);
//    if (result != BEF_RESULT_SUC) {
//        NSLog(@"bef_effect_ai_face_attribute_create error: %d", result);
//    }
//
//    //人脸属性检测模型检测license
//    result = bef_effect_ai_face_attribute_check_license(faceDistanceFaceAttribyteDetectHandle, licbag.UTF8String);
//
//    if (result != BEF_RESULT_SUC) {
//        NSLog(@"bef_effect_ai_face_attribute_check_license error: %d", result);
//    }
//
//    //人脸距离估计创建
//    result = bef_effect_ai_human_distance_create(&faceDistanceDetectHandle);
//    if (result != BEF_RESULT_SUC) {
//        NSLog(@"bef_effect_ai_human_distance_create error: %d", result);
//    }
//
//    result = bef_effect_ai_human_distance_check_license(faceDistanceDetectHandle, licbag.UTF8String);
//    if (result != BEF_RESULT_SUC) {
//        NSLog(@"bef_effect_ai_human_distance_check_license error: %d", result);
//    }
//
//    //人脸距离参数设置
//    result = bef_effect_ai_human_distance_setparam(faceDistanceDetectHandle, BEF_HumanDistanceCameraFov, 60);
//    if (result != BEF_RESULT_SUC) {
//        NSLog(@"bef_effect_ai_human_distance_setparam error: %d", result);
//    }
//
//}


/*
 * 设置模型聚类的handle
 */

- (void)_setupFaceClusteringHandle{
    NSString *licbag = [self be_licensePath];
    
    NSString *resourceBundleName = [self be_modelPath];
    NSString *faceModel = [resourceBundleName stringByAppendingString:FACE_MODEL];
    NSString *faceVerifyModel = [resourceBundleName stringByAppendingString:FACE_VERIFY_MODEL];
    
    bef_effect_result_t result;
    
    //创建人脸检测模型
    result = bef_effect_ai_face_detect_create(BEF_DETECT_MODE_IMAGE_SLOW|BEF_DETECT_SMALL_MODEL|BEF_FACE_DETECT, faceModel.UTF8String, &faceClusteringFaceDetectHandle);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_face_clustering_detect_create error: %d", result);
    }
    
    //检测人脸检测模型license
    result = bef_effect_ai_face_check_license(faceClusteringFaceDetectHandle, licbag.UTF8String);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_face_clustering_face_detect_check_license error: %d", result);
    }
    
    //创建人脸比对模型
    result = bef_effect_ai_face_verify_create(faceVerifyModel.UTF8String, BEF_AI_MAX_FACE_VERIFY_NUM, &faceClusteringFaceExtractFeatureHandle);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_face_clustering_verify_create error: %d", result);
    }
    
    //检测人脸比对模型lincese
    result = bef_effect_ai_face_verify_check_license(faceClusteringFaceExtractFeatureHandle, licbag.UTF8String);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_face_clustering_verify_check_license error: %d", result);
    }
    
    //人脸聚类创建
    result = bef_effect_ai_fc_create(&faceClusteringHandle);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_fc_create error: %d", result);
    }
    
    result = bef_effect_ai_face_cluster_check_license(faceClusteringHandle, [licbag UTF8String]);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_face_cluster_check_license error: %d", result);
    }
    
}

- (void)_setupLightclsModel {
    NSString *licbag = [self be_licensePath];
    NSString *resourceBundleName = [self be_modelPath];
    NSString *modelPath = [resourceBundleName stringByAppendingString:LIGHTCLS_MODEL];
    
    bef_effect_result_t result;
    result = bef_effect_ai_lightcls_create(&lightClsHandle, [modelPath UTF8String], 5);
    if (result != BEF_RESULT_SUC) {
        NSLog(@"bef_effect_ai_lightcls_create error: %d", result);
    }
    
    result = bef_effect_ai_lightcls_check_license(lightClsHandle, [licbag UTF8String]);
    if (result != BEF_RESULT_SUC) {
        NSLog(@"bef_effect_ai_lightcls_check_license error: %d", result);
    }
}

- (void) handDetect:(bef_ai_hand_info*)gestureDetectResult buffer:(unsigned char*) buffer format:(bef_ai_pixel_format)format deviceOrientation:(int)orientation {
    bef_effect_result_t result;
    
    result = bef_effect_ai_hand_detect(handDetectHandle, buffer, (bef_ai_pixel_format)format, _width, _height, _bytersPerRow, (bef_ai_rotate_type)orientation,
                                       BEF_HAND_MODEL_DETECT | BEF_HAND_MODEL_BOX_REG |
                                       BEF_HAND_MODEL_GESTURE_CLS| BEF_HAND_MODEL_KEY_POINT, gestureDetectResult, 4);
    
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_hand_detect error: %d", result);
    }
}

- (void) skeletonDetect:(bef_skeleton_info*) skeletonDetectResult validCount:(int*)count buffer:(unsigned char*) buffer format:(bef_ai_pixel_format)format deviceOrientation:(int)orientation{
    bef_effect_result_t result;
    
    result = bef_effect_ai_skeleton_detect(skeletonDetectHandle, buffer, (bef_ai_pixel_format)format, _width, _height, _bytersPerRow, (bef_ai_rotate_type)orientation, count, &skeletonDetectResult);
    
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_skeletion_detect error: %d", result);
    }
}

- (void) faceDetect:(bef_ai_face_info*) faceInfo buffer:(unsigned char*) buffer format:(bef_ai_pixel_format)format deviceOrientation:(int)orientation {
     bef_effect_result_t result;
    
    result = bef_effect_ai_face_detect(faceDetectHandle, buffer, (bef_ai_pixel_format)format, _width, _height, _bytersPerRow, (bef_ai_rotate_type)orientation, BEF_DETECT_MODE_VIDEO | BEF_DETECT_FULL, faceInfo);
    
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_face_detect error: %d", result);
    }
}

- (void)faceDetect280:(bef_ai_face_info *)faceInfo buffer:(unsigned char *)buffer format:(bef_ai_pixel_format)format deviceOrientation:(int)orientation{
    bef_effect_result_t result;
    
    result = bef_effect_ai_face_detect(faceDetectHandle, buffer, (bef_ai_pixel_format)format, _width, _height, _bytersPerRow, (bef_ai_rotate_type)orientation, BEF_DETECT_MODE_VIDEO | BEF_DETECT_FULL | TT_MOBILE_FACE_280_DETECT, faceInfo);
    
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_face_detect error: %d", result);
    }
}

-(void) faceAttributeDetect:(bef_ai_face_attribute_result*)faceAttrResult buffer:(unsigned char*) buffer faceInfo:(bef_ai_face_106 *)faceInfo faceCount:(int)faceCount format:(bef_ai_pixel_format)format{
    
    bef_effect_result_t result;
    unsigned long long attriConfig = BEF_FACE_ATTRIBUTE_AGE | BEF_FACE_ATTRIBUTE_HAPPINESS                                |BEF_FACE_ATTRIBUTE_EXPRESSION|BEF_FACE_ATTRIBUTE_GENDER
        |BEF_FACE_ATTRIBUTE_RACIAL|BEF_FACE_ATTRIBUTE_ATTRACTIVE;
    
    //多个人脸属性检测
    result = bef_effect_ai_face_attribute_detect_batch(faceAttributeDetectHandle, buffer, (bef_ai_pixel_format)format, _width, _height, _bytersPerRow, faceInfo, faceCount, attriConfig, faceAttrResult);
    
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_face_attribute_detect_batch error: %d", result);
    }
}
- (void) cvtYUV2RGBA:(unsigned char*) buffer dst:(unsigned char*)dst dst_width:(int) dst_width dst_height:(int) dst_height format:(bef_ai_pixel_format)format deviceOrientation:(int)orientation is_front:(bool) is_front{
    cvt_yuv2rgba(buffer, dst, (bef_ai_pixel_format)format, _width, _height, dst_width, dst_height, (bef_ai_rotate_type)orientation, is_front);
}
- (void) cvtRGBA2YUV:(unsigned char*) buffer dst:(unsigned char*)dst format:(bef_ai_pixel_format)format {
    cvt_rgba2yuv(buffer, dst, (bef_ai_pixel_format)format, _width, _height);
}


/*
 * 头发分割模型的检测,这里需要得到返回的是一个模型的alpha的纹理，这里需要分配一定大小的空间来放这个问题,函数的使用方需要释放返回值的内存
 */
- (unsigned char* ) hairparseDetect:(unsigned char*) buffer format:(bef_ai_pixel_format)format deviceOrientation:(int)orientation size:(int *)size{
    bef_effect_result_t result;
    
    result = bef_effect_ai_hairparser_get_output_shape(hairparserDetectHandle, size, size + 1, size + 2);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_hairparser_get_output_shape error: %d", result);
    }
    
    unsigned char* destAlpha = (unsigned char*)malloc(size[0] * size[1] * size[2]);
    
    result = bef_effect_ai_hairparser_do_detect(hairparserDetectHandle, buffer, format, _width, _height, _bytersPerRow, (bef_ai_rotate_type)orientation, destAlpha, false);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_hairparser_do_detect error: %d", result);
    }
    
    return destAlpha;
}

/*
 * 人体分割模型的检测
 */
- (unsigned char*) prortraitDetect:(unsigned char*) buffer format:(bef_ai_pixel_format)format deviceOrientation:(int)orientation size:(int*)size{
    //    int width = 0, height = 0;
    bef_effect_result_t result;
    
    unsigned char* ret = (unsigned char*)malloc(_width * _height);
    if (ret == NULL)
        NSLog(@"prortraitDetect malloc memory error");
    
    bef_ai_matting_ret mattingRet = {ret, _width, _height};
    
    result = bef_effect_ai_portrait_matting_do_detect(portraitDetectHandle, buffer, format, _width, _height, _bytersPerRow, (bef_ai_rotate_type)orientation, false, &mattingRet);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_portrait_matting_do_detect error: %d", result);
    }
    
    *size = mattingRet.width;;
    *(size + 1) = mattingRet.height;
    *(size + 2) = 1;
    return ret;
}

/*
 * 检测单个人脸的特征,并保存起特征，用于以后比对
 */
- (int)setfaceVerifySourceFeature:(unsigned char* )buffer format:(bef_ai_pixel_format)format width:(int)iWidth height:(int)iHeight bytesPerRow:(int)bytesPerRow{
    bef_effect_result_t result;
    
    bef_ai_face_info faceInfo;
    result = bef_effect_ai_face_detect(faceVerifyDetectHandle, buffer, format, iWidth, iHeight, bytesPerRow, BEF_AI_CLOCKWISE_ROTATE_0, BEF_DETECT_MODE_IMAGE_SLOW|BEF_DETECT_SMALL_MODEL|BEF_FACE_DETECT, &faceInfo);
    
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_face_verify_detect error: %d", result);
    }
    
    if (faceInfo.face_count == 0) return 0;
    
    result = bef_effect_ai_face_extract_feature_single(faceVerifyHandle, buffer, format, iWidth, iHeight, bytesPerRow, BEF_AI_CLOCKWISE_ROTATE_0, &faceInfo.base_infos[0], _currentFaceVerifyFeature);

    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_face_extract_feature_single error: %d", result);
    }
    
    return  faceInfo.face_count;
}

/*
 * 人脸特征检测，并进行比对,处理单帧图像
 */

- (void)faceVerifyDetectSingle:(unsigned char*) buffer format:(bef_ai_pixel_format)format deviceOrientation:(int)orientation similarity:(double*)similarity{
    bef_effect_result_t result;
    bef_ai_face_info faceInfo;
    
    result = bef_effect_ai_face_detect(faceDetectHandle, buffer, format, _width, _height, _bytersPerRow, (bef_ai_rotate_type)orientation, BEF_DETECT_SMALL_MODEL | BEF_FACE_DETECT | BEF_DETECT_MODE_VIDEO, &faceInfo);
    
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_face_verify_detect error: %d", result);
    }
    
    if (faceInfo.face_count == 0){
        *similarity = 0.0;
        return ;
    }
    
    float destFaceVerifyFeature[BEF_AI_FACE_FEATURE_DIM];
    
    result = bef_effect_ai_face_extract_feature_single(faceVerifyHandle, buffer, format, _width, _height, _bytersPerRow, (bef_ai_rotate_type)orientation, &faceInfo.base_infos[0], destFaceVerifyFeature);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_face_extract_feature_single error: %d", result);
    }
    
    double featureDistance = bef_effect_ai_face_verify(_currentFaceVerifyFeature, destFaceVerifyFeature, BEF_AI_FACE_FEATURE_DIM);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_face_verify error:x %d", result);
    }
    
    *similarity = bef_effect_ai__dist2score(featureDistance);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai__dist2score error: %d", result);
    }
}

/*
 * 人脸距离估计
 */
- (void)faceDistanceFaceDetect:(unsigned char*) buffer format:(bef_ai_pixel_format)format deviceOrientation:(int)orientation faceDetectResult:(bef_ai_face_info*)faceInfo{
    bef_effect_result_t result;
    
    result = bef_effect_ai_face_detect(faceDistanceFaceDetectHandle, buffer, (bef_ai_pixel_format)format, _width, _height, _bytersPerRow, (bef_ai_rotate_type)orientation, BEF_DETECT_SMALL_MODEL | BEF_FACE_DETECT, faceInfo);
    
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_face_distance_face_detect error: %d", result);
    }
}

//- (void)faceDistanceDetect:(unsigned char*) buffer format:(bef_ai_pixel_format)format deviceOrientation:(int)orientation faceInfo:(bef_ai_face_info*)faceInfo faceDistanceResult:(bef_ai_human_distance_result*)distanceResult{
//    bef_effect_result_t result;
//    bef_ai_face_attribute_result faceAttrResult;
//
//    int faceCount = faceInfo->face_count;
//    unsigned long long attriConfig = BEF_FACE_ATTRIBUTE_AGE|BEF_FACE_ATTRIBUTE_GENDER;
//    
//    //人脸属性检测
//    result = bef_effect_ai_face_attribute_detect_batch(faceDistanceFaceAttribyteDetectHandle, buffer, (bef_ai_pixel_format)format, _width, _height, _bytersPerRow, faceInfo->base_infos, faceCount, attriConfig, &faceAttrResult);
//    
//    if (result != BEF_RESULT_SUC){
//        NSLog(@"bef_effect_ai_face_distance_face_attribute_detect_batch error: %d", result);
//    }
//    
//    //人脸距离检测
//    result = bef_effect_ai_human_distance_detect(faceDistanceDetectHandle, buffer, (bef_ai_pixel_format)format, _width, _height, _bytersPerRow, (bef_ai_rotate_type)orientation, faceInfo, &faceAttrResult, distanceResult);
//    if (result != BEF_RESULT_SUC){
//        NSLog(@"bef_effect_ai_human_distance_detect error: %d", result);
//    }
//}

/*
 * 生成人脸聚类的feature，返回检测到的人脸的个数，如果没有人脸，feature里面的内容不会被填充
 */
- (int)_faceClusteringGenFeatures:(UIImage *)image featureInfo:(bef_ai_face_verify_info*)features{
    size_t width = 0, height = 0, bytesPerRow = 0;
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    const uint8_t *data = CFDataGetBytePtr(pixelData);
    
    width = CGImageGetWidth(image.CGImage);
    height = CGImageGetHeight(image.CGImage);
    bytesPerRow = CGImageGetBytesPerRow(image.CGImage);
    
    bef_effect_result_t result;
    bef_ai_face_info faceInfo;
    
    result = bef_effect_ai_face_detect(faceClusteringFaceDetectHandle, data, BEF_AI_PIX_FMT_RGBA8888, width, height, bytesPerRow, (bef_ai_rotate_type)BEF_AI_CLOCKWISE_ROTATE_0, BEF_DETECT_MODE_IMAGE_SLOW|BEF_DETECT_SMALL_MODEL|BEF_FACE_DETECT, &faceInfo);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_face_clustering_detect error: %d", result);
    }
    
    if (faceInfo.face_count == 0) {
        CFRelease(pixelData);
        return 0;
    }
    
    result = bef_effect_ai_face_extract_feature(faceClusteringFaceExtractFeatureHandle, data, BEF_AI_PIX_FMT_RGBA8888, width, height, bytesPerRow, (bef_ai_rotate_type)BEF_AI_CLOCKWISE_ROTATE_0, &faceInfo, features);
    if (result != BEF_RESULT_SUC){
        NSLog(@"bef_effect_ai_face_extract_feature error: %d", result);
    }
    
    CFRelease(pixelData);
    return features->valid_face_num;
}

/*
 * 对一组uiimage进行特征提取，images 的index 在返回的array中表示了种类
 */

- (NSMutableDictionary<NSNumber*, NSMutableArray*> *)faceClusteringWithImages:(NSArray<UIImage*> *)images {
    std::vector<float *> features; //保存所有临时malloc的feature空间的地址
    std::vector<std::vector<int>> faceClusterFeatures(images.count, std::vector<int>());
    NSMutableDictionary<NSNumber*, NSMutableArray*> *clusterDictResult = [NSMutableDictionary dictionary];
    
    int validFeatureCnt = 0;
    for (int index = 0; index < images.count; index++){
        bef_ai_face_verify_info featureInfo;
        int valid_count = [self _faceClusteringGenFeatures:images[index] featureInfo:&featureInfo];
        
        if (valid_count == 0) faceClusterFeatures[index] = {-1};
        
        //特征的index放入到数组中
        for (int featureIndex = 0; featureIndex < valid_count; featureIndex++){
            //每个image的特征 index放在一起
            faceClusterFeatures[index].push_back(validFeatureCnt++);
            
            float* feature = featureInfo.features[featureIndex];
            float* tmpAddress = (float*)malloc(BEF_AI_FACE_FEATURE_DIM * sizeof(float));
            
            memcpy(tmpAddress, feature, BEF_AI_FACE_FEATURE_DIM * sizeof(float));
            features.push_back(tmpAddress);
        }
    }
    
    //存放最终保存的聚类结果的地方
    int *finalResult = (int*)malloc(validFeatureCnt * sizeof(int));
    //传入SDK的地址，保存形式为连续的features
    float *totalFeatures = (float*)malloc(validFeatureCnt * sizeof(float) * BEF_AI_FACE_FEATURE_DIM);
    
    //把原来的每一个临时保存的内存move过来，然后释放临时的
    for (int index = 0; index < validFeatureCnt; index++){
        memmove(totalFeatures + (index * BEF_AI_FACE_FEATURE_DIM),
                features[index],
                BEF_AI_FACE_FEATURE_DIM * sizeof(float));
        
        //释放临时分配的内存
        free(features[index]);
    }
    
    bef_effect_result_t result = bef_effect_ai_fc_do_clustering(faceClusteringHandle, totalFeatures, validFeatureCnt, finalResult);
    if (result != BEF_RESULT_SUC){
         NSLog(@"bef_effect_ai_fc_do_clustering error: %d", result);
    }
    
    //当前的result array 存放的是对一个的feature的index， 现在吧index换成对应的result中的聚类结果
    for (int preImageIndex = 0; preImageIndex < faceClusterFeatures.size(); preImageIndex++){
        for (int preFeatureIndex = 0; preFeatureIndex < faceClusterFeatures[preImageIndex].size(); preFeatureIndex++){
//            if (faceClusterResult[preImageIndex][preFeatureIndex] >= 0){
//                faceClusterResult[preImageIndex][preFeatureIndex] = finalResult[faceClusterResult[preImageIndex][preFeatureIndex]];
//            }
            //没有检测到人脸
            if (faceClusterFeatures[preImageIndex][preFeatureIndex] == -1){
                //没有就创建
                if ([clusterDictResult objectForKey:[NSNumber numberWithInteger:-1]] == nil){
                    NSMutableArray *array = [NSMutableArray array];
                    [clusterDictResult setObject:array forKey:[NSNumber numberWithInteger:-1]];
                }
                
                [clusterDictResult[[NSNumber numberWithInteger:-1]] addObject:[NSNumber numberWithInt:preImageIndex]];
                break;
            }else {
                if ([clusterDictResult objectForKey:
                     [NSNumber numberWithInteger:finalResult[faceClusterFeatures[preImageIndex][preFeatureIndex]]]] == nil){
                    
                    NSMutableArray *array = [NSMutableArray array];
                    [clusterDictResult setObject:array forKey:[NSNumber numberWithInteger:finalResult[faceClusterFeatures[preImageIndex][preFeatureIndex]]]];
                }
                
                [clusterDictResult[[NSNumber numberWithInteger:finalResult[faceClusterFeatures[preImageIndex][preFeatureIndex]]]] addObject:[NSNumber numberWithInt:preImageIndex]];
            }
        }
            
    }
    
    NSLog(@"%@", clusterDictResult);
    
    free (finalResult);
    free (totalFeatures);
    return clusterDictResult;
}

- (void)petFaceDetect:(unsigned char *)buffer format:(bef_ai_pixel_format)format deviceOrientation:(int)orientation petFaceDetectResult:(bef_ai_pet_face_result *)faceInfo {
    bef_effect_result_t result = bef_effect_ai_pet_face_detect(petFaceHandle, buffer, (bef_ai_pixel_format)format, _width, _height, _bytersPerRow, (bef_ai_rotate_type)orientation, faceInfo);
    if (result != BEF_RESULT_SUC) {
        NSLog(@"bef_effect_ai_pet_face_detect error: %d", result);
    }
}

- (void)lightClsDetect:(unsigned char *)buffer format:(bef_ai_pixel_format)format devidceOrientation:(int)orientation lightClsResult:(bef_ai_light_cls_result *)lightInfo {
    bef_effect_result_t result = bef_effect_ai_lightcls_detect(lightClsHandle, buffer, (bef_ai_pixel_format)format, _width, _height, _bytersPerRow, (bef_ai_rotate_type)orientation, lightInfo);
    if (result != BEF_RESULT_SUC) {
        NSLog(@"bef_effect_ai_lightcls_detect error: %d", result);
    }
}

#pragma mark - util
- (NSString *)be_licensePath {
    NSString *licBundleName = [[NSBundle mainBundle] pathForResource:@"LicenseBag" ofType:@"bundle"];
    NSString *licbag = [licBundleName stringByAppendingString:LICENSE_PATH];
    return licbag;
}

- (NSString *)be_modelPath {
    NSString *resourceBundleName = [[NSBundle mainBundle] pathForResource:@"ModelResource" ofType:@"bundle"];
    return resourceBundleName;
}

@end

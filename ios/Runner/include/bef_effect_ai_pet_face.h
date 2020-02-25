//
// Created by zhengyanxin on 2019-08-12.
//

#ifndef ANDROIDDEMO_BEF_EFFECT_AI_PET_FACE_H
#define ANDROIDDEMO_BEF_EFFECT_AI_PET_FACE_H

#if defined(__ANDROID__) || defined(TARGET_OS_ANDROID)
#include<jni.h>
#endif

#include "bef_effect_ai_public_define.h"

#define AI_PET_MAX_POINT_NUM 90                     // 宠物脸的关键点的最大点数     max key point of pet face
#define AI_CAT_POINT_NUM 82                         // 猫：82点        cat: 82 pints
#define AI_DOG_POINT_NUM 76                         // 狗：76点（不加耳朵）      dog: 76 points (without ears)
#define AI_OTHER_POINT_NUM 4                        // 其它动物：4点(目前不支持)       other animals: four point (not supported currently)
#define AI_MAX_PET_NUM 10

#define AI_PET_OPEN_LEFT_EYE          0x00000001    // 左眼睛是否睁开      if left eye opening
#define AI_PET_OPEN_RIGHT_EYE         0x00000002    // 右眼睛是否睁开      if right eye opening
#define AI_PET_OPEN_MOUTH             0x00000004    // 嘴巴是否张开        if mouth opening

typedef void *PetFaceHandle;                        ///< 关键点检测句柄        handle of key points detect

typedef enum {
    BEF_CAT                 =                       1,   // 猫       cat
    BEF_DOG                 =                       2,   // 狗       dog
    BEF_HUMAN               =                       3,   // 人（目前不支持）    human (not supported currently)
    BEF_OTHERS              =                      99,   // 其它宠物类型（目前不支持）   other pet (not supported currently)
}bef_ai_pet_face_type;


typedef enum {
    BEF_DetCat              =             0x00000001,  // 开启猫脸检测    cat face detect on
    BEF_DetDog              =             0x00000002,  // 开启狗脸检测    dog face detect on
    BEF_QuickMode           =             0x00000004,  // 开启快速版本    quick mode on
}bef_ai_pet_face_config_type;

typedef struct bef_ai_pet_info_st {
    bef_ai_pet_face_type type;                          /// < 宠物类型  pet type
    bef_ai_rect rect;                            /// < 代表面部的矩形区域     face rect
    float score;                            /// < 宠物脸检测的置信度     credibility of face detect
    bef_ai_fpoint points_array[AI_PET_MAX_POINT_NUM]; /// < 宠物脸关键点的数组     array of pet face key points
    float yaw;                              /// < 水平转角,真实度量的左负右正        yaw, negative if left and positive right
    float pitch;                            /// < 俯仰角,真实度量的上负下正         pitch, negative if up and positive down
    float roll;                             /// < 旋转角,真实度量的左负右正         roll, negative if left and positive right
    int id;                                 /// < faceID: 每个检测到的宠物脸拥有唯一id，跟踪丢失以后重新被检测到,会有一个新的id     face id, each detected pet face has a unique id, when lose track of one face and re-detect a face, it's considered as a new face
    unsigned int action;                    /// < 脸部动作，目前只包括：左眼睛睁闭，右眼睛睁闭，嘴巴睁闭   face action, including left-eye/right-eye/mouth opening/closing,
    /// < action 的第1，2，3位分别编码： 左眼睛睁闭，右眼睛睁闭，嘴巴睁闭，其余位数预留      the 1st,2nd,3rd respectively represent left eye, right eye and mouth, and 1 for opening, 0 for closing
} bef_ai_pet_face_info, *p_bef_ai_pet_face_info;

/// @brief 检测结果 detect result
typedef struct bef_ai_pet_face_result_st {
    bef_ai_pet_face_info p_faces[AI_MAX_PET_NUM];       ///< 检测到的宠物脸信息      detected pet face information
    int face_count;                        ///< 检测到的宠物脸数目，p_faces 数组中，只有face_count个结果是有效的；     detected pet face count, representing valid count of info in p_faces
} bef_ai_pet_face_result, *p_bef_ai_pet_face_result;



/**
 * @brief 创建宠物脸检测的句柄    create pet face detect handle
 *
 * @param [in] strModelPath 模型文件所在路径     path of model file
 *
 * @param [in] config Config of pet face detect algorithm 宠物脸检测算法的配置
 *  可以配置只检测猫，只检测狗，或者同时检测猫狗
 *  例如：只检测狗：detect_config = bef_ai_pet_face_config_type::BEF_DetDog
 *       只检测猫：detect_config = bef_ai_pet_face_config_type::BEF_DetCat
 *       同时检测猫狗： detect_config = bef_ai_pet_face_config_type::BEF_DetDog|bef_ai_pet_face_config_type::BEF_DetCat
 *  sample: only dog: detect_config = bef_ai_pet_face_config_type::BEF_DetDog
 *          only cat: detect_config = bef_ai_pet_face_config_type::BEF_DetCat
 *          both dog and cat: detect_config = bef_ai_pet_face_config_type::BEF_DetDog|bef_ai_pet_face_config_type::BEF_DetCat
 *
 * @param: max_face_num：指定最多能够检测到的宠物脸数目；    max pet face can be detected
 *
 * @param [out] handle Created face detect handle
 *                     创建的宠物脸检测句柄
 * @return If succeed return BEF_RESULT_SUC, other value please see bef_effect_ai_public_define.h
 *         成功返回 BEF_RESULT_SUC, 失败返回相应错误码, 具体请参考 bef_effect_ai_public_define.h
 */
BEF_SDK_API
bef_effect_result_t
bef_effect_ai_pet_face_create(
                              const char * strModelPath,
                              long long config,
                              unsigned int maxNum,
                              bef_effect_handle_t *handle
                              );



/**
 * @brief 宠物脸检测     detect pet face
 * @param [in] handle Created face detect handle
 *                    已创建的宠物脸检测句柄
 * @param [in] image Image base address
 *                   输入图片的数据指针
 * @param [in] pixel_format Pixel format of input image
 *                          输入图片的格式
 * @param [in] image_width  Image width
 *                          输入图像的宽度 (以像素为单位)
 * @param [in] image_height Image height
 *                          输入图像的高度 (以像素为单位)
 * @param [in] image_stride Image stride in each row
 *                          输入图像每一行的步长 (以像素为单位)
 * @param [in] orientation Image orientation
 *                         输入图像的转向，具体请参考 bef_effect_ai_public_define.h 中的 bef_rotate_type
 * @param [out] p_pet_face_result  存放结果信息，需外部分配好内存，需保证空间大于等于设置的最大检测宠物脸数
 * @return If succeed return BEF_RESULT_SUC, other value please see bef_effect_ai_public_define.h
 *         成功返回 BEF_RESULT_SUC, 失败返回相应错误码, 具体请参考 bef_effect_ai_public_define.h
 */
BEF_SDK_API
bef_effect_result_t bef_effect_ai_pet_face_detect(
                                                  bef_effect_handle_t handle,
                                                  const unsigned char *image,
                                                  bef_ai_pixel_format pixel_format,
                                                  int image_width,
                                                  int image_height,
                                                  int image_stride,
                                                  bef_ai_rotate_type orientation,
                                                  bef_ai_pet_face_result *p_pet_face_result
                                                  );



/**
 * @param [in] handle Destroy the created pet face detect handle
 *                    销毁创建的宠物脸检测句柄
 */
BEF_SDK_API
bef_effect_result_t bef_effect_ai_pet_face_release(bef_effect_handle_t handle);



/**
 * @brief 宠物脸授权     check and get license for pet face detect
 * @param [in] handle Created pet face handle
 *                    已创建的宠物脸检测句柄
 * @param [in] license 授权文件字符串
 * @param [in] length  授权文件字符串长度
 * @return If succeed return BEF_RESULT_SUC, other value please refer bef_effect_ai_public_define.h
 *         成功返回 BEF_RESULT_SUC, 授权码非法返回 BEF_RESULT_INVALID_LICENSE ，其它失败返回相应错误码, 具体请参考 bef_effect_ai_public_define.h
 */
#if defined(__ANDROID__) || defined(TARGET_OS_ANDROID)
BEF_SDK_API bef_effect_result_t bef_effect_ai_pet_face_check_license(JNIEnv *env, jobject context,
                                                                     bef_effect_handle_t handle,
                                                                     const char *licensePath);
#else
#ifdef __APPLE__
BEF_SDK_API bef_effect_result_t bef_effect_ai_pet_face_check_license(bef_effect_handle_t handle, const char *licensePath);
#endif
#endif

#endif //ANDROIDDEMO_BEF_EFFECT_AI_PET_FACE_H

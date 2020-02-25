// Copyright (C) 2019 Beijing Bytedance Network Technology Co., Ltd.
#ifndef _BEF_EFFECT_HAND_DETECT_AI_H_
#define _BEF_EFFECT_HAND_DETECT_AI_H_


#if defined(__ANDROID__) || defined(TARGET_OS_ANDROID)
#include<jni.h>
#endif

#include "bef_effect_ai_public_define.h"

//bef_effect_public_hand_define
#define BEF_TT_HAND_GESTURE_HEART_A 0
#define BEF_TT_HAND_GESTURE_HEART_B 1
#define BEF_TT_HAND_GESTURE_HEART_C 2
#define BEF_TT_HAND_GESTURE_HEART_D 3
#define BEF_TT_HAND_GESTURE_OK 4
#define BEF_TT_HAND_GESTURE_HAND_OPEN 5
#define BEF_TT_HAND_GESTURE_THUMB_UP 6
#define BEF_TT_HAND_GESTURE_THUMB_DOWN 7
#define BEF_TT_HAND_GESTURE_ROCK 8
#define BEF_TT_HAND_GESTURE_NAMASTE 9
#define BEF_TT_HAND_GESTURE_PLAM_UP 10
#define BEF_TT_HAND_GESTURE_FIST 11
#define BEF_TT_HAND_GESTURE_INDEX_FINGER_UP 12
#define BEF_TT_HAND_GESTURE_DOUBLE_FINGER_UP 13
#define BEF_TT_HAND_GESTURE_VICTORY 14
#define BEF_TT_HAND_GESTURE_BIG_V 15
#define BEF_TT_HAND_GESTURE_PHONECALL 16
#define BEF_TT_HAND_GESTURE_BEG 17
#define BEF_TT_HAND_GESTURE_THANKS 18
#define BEF_TT_HAND_GESTURE_UNKNOWN 19
#define BEF_TT_HAND_GESTURE_CABBAGE 20
#define BEF_TT_HAND_GESTURE_THREE 21
#define BEF_TT_HAND_GESTURE_FOUR 22
#define BEF_TT_HAND_GESTURE_PISTOL 23
#define BEF_TT_HAND_GESTURE_ROCK2 24
#define BEF_TT_HAND_GESTURE_SWEAR 25
#define BEF_TT_HAND_GESTURE_HOLDFACE 26
#define BEF_TT_HAND_GESTURE_SALUTE 27
#define BEF_TT_HAND_GESTURE_SPREAD 28
#define BEF_TT_HAND_GESTURE_PRAY 29
#define BEF_TT_HAND_GESTURE_QIGONG 30
#define BEF_TT_HAND_GESTURE_SLIDE 31
#define BEF_TT_HAND_GESTURE_PALM_DOWN 32
#define BEF_TT_HAND_GESTURE_PISTOL2 33
#define BEF_TT_HAND_GESTURE_NARUTO1 34
#define BEF_TT_HAND_GESTURE_NARUTO2 35
#define BEF_TT_HAND_GESTURE_NARUTO3 36
#define BEF_TT_HAND_GESTURE_NARUTO4 37
#define BEF_TT_HAND_GESTURE_NARUTO5 38
#define BEF_TT_HAND_GESTURE_NARUTO7 39
#define BEF_TT_HAND_GESTURE_NARUTO8 40
#define BEF_TT_HAND_GESTURE_NARUTO9 41
#define BEF_TT_HAND_GESTURE_NARUTO10 42
#define BEF_TT_HAND_GESTURE_NARUTO11 43
#define BEF_TT_HAND_GESTURE_NARUTO12 44

#define BEF_MAX_HAND_NUM 2
#define BEF_HAND_KEY_POINT_NUM 22
#define BEF_HAND_KEY_POINT_NUM_EXTENSION 2


typedef struct bef_ai_hand_st {
    int id;                           ///< 手的id       id of hand
    bef_ai_rect rect;                      ///< 手部矩形框      rect of hand
    unsigned int action;              ///< 手部动作 bef_hand_types[]的index [0--20)        action of hand
    float rot_angle;                  ///< 手部旋转角度， 仅手张开是比较准确      rotate of hand, only accurate when hand opening
    float score;                      ///< 手部动作置信度        crediility of hand action
    float rot_angle_bothhand;  ///< 双手夹角                   angle of two hands
    // 手部关键点, 如果没有检测到，则置为0              key point of hand, 0 if no hand
    struct bef_ai_tt_key_point key_points[BEF_HAND_KEY_POINT_NUM];
    // 手部扩展点，如果没有检测到，则置为0              extra key point of hand, 0 if no hand
    struct bef_ai_tt_key_point key_points_extension[BEF_HAND_KEY_POINT_NUM_EXTENSION];
    unsigned int seq_action;   // 0 如果没有序列动作设置为0， 其他为有效值        sequence of action, 0 if unavailable
    unsigned char *segment;         ///< 手掌分割mask 取值范围 0～255 默认: nullptr        palm segment, default nullptr
    int segment_width;              ///< 手掌分割宽 默认: 0        width of palm segment, default 0
    int segment_height;             ///< 手掌分割高 默认: 0        height of palm segment, default 0
} bef_ai_hand, *ptr_bef_ai_hand;

/// @brief 检测结果
typedef struct bef_ai_hand_info_st {
    bef_ai_hand p_hands[BEF_MAX_HAND_NUM];    ///< 检测到的手部信息       information of hand detected
    int hand_count;                       ///< 检测到的手部数目，p_hands 数组中，只有hand_count个结果是有效的；      count of hand detected, represent available info of p_hands
} bef_ai_hand_info, *ptr_bef_ai_hand_info;

typedef void *bef_ai_hand_sdk_handle;

typedef enum {
    BEF_HAND_REFRESH_FRAME_INTERVAL = 1,      // 设置检测刷新帧数, 暂不支持     set detect refresh rate, not available currently
    BEF_HAND_MAX_HAND_NUM = 2,                // 设置最多的手的个数，默认为1，目前最多设置为2；       set max hand, default 1, max 2
    BEF_HAND_DETECT_MIN_SIDE = 3,             // 设置检测的最短边长度, 默认192      set min length of detect, default 192
    BEF_HAND_CLS_SMOOTH_FACTOR = 4,           // 设置分类平滑参数，默认0.7， 数值越大分类越稳定      set classification smoothing parameter, default 0.7, more value big, more stable
    BEF_HAND_USE_ACTION_SMOOTH = 5,           // 设置是否使用类别平滑，默认1，使用类别平滑；不使用平滑，设置为0       set whether using classification smoothing, default 1, 1 if yes, 0 if not
    BEF_HAND_ALGO_LOW_POWER_MODE = 6,         // 降级模式，默认走高级的版本。       downgrade mode, default advanced version
    BEF_HAND_ALGO_AUTO_MODE = 7,              // 降级模式，默认走高级的版本。       downgrade mode, default advanced version
    // 如果设置为 HAND_ALGO_AUTO_MODE 模式，则可以以下参数来设置算法降级的阈值       if in HAND_ALGO_AUTO_MODE mode, using following param set algorithm downgrade threshold
    BEF_HAND_ALGO_TIME_ELAPSED_THRESHOLD = 8, // 算法耗时阈值，默认为 20ms        threshold of time consuming, default 20ms
    BEF_HAND_ALGO_MAX_TEST_FRAME = 9,         // 设置运行时测试算法的执行的次数, 默认是 150 次     set times of test algorithm running in runtime, default 150
    BEF_HAND_IS_USE_DOUBLE_GESTURE = 10,      // 设置是否使用双手手势， 默认为true        set if using double gesture, default true
    BEF_HNAD_ENLARGE_FACTOR_REG = 11,         // 设置回归模型的输入初始框的放大比列        set enlarge factor of input rectangle
    BEF_HAND_NARUTO_GESTURE = 12,             // 设置支持火影忍者手势，默认为false，如果开启，则支持包括火影在内的45类手势识别     set if using naruto gesture, default false
} bef_ai_hand_param_type;

typedef enum {
    BEF_HAND_MODEL_DETECT = 0x0001,       // 检测手，必须加载       detect hand, required
    BEF_HAND_MODEL_BOX_REG = 0x0002,      // 检测手框，必须加载      detect hand rect, required
    BEF_HAND_MODEL_GESTURE_CLS = 0x0004,  // 手势分类，可选        classification gesture, optional
    BEF_HAND_MODEL_KEY_POINT = 0x0008,    // 手关键点，可选        key point of hand, optional
    BEF_HAND_MODEL_SEGMENT = 0x0010,    // 可见性点，可选          visible point, optional
} bef_ai_hand_model_type;


/**
 * @brief 创建手势检测的名柄     create hand detect handle
 * @param [out] handle Created hand detect handle
 *                     创建的人手检测句柄
 * @param [unsigned int] 目前无效       unavailable currently
 * @return If succeed return BEF_RESULT_SUC, other value please see bef_effect_ai_public_define.h
 *         成功返回 BEF_RESULT_SUC, 失败返回相应错误码, 具体请参考 bef_effect_ai_public_public_define.h
 */
BEF_SDK_API bef_effect_result_t
bef_effect_ai_hand_detect_create(
                                 bef_ai_hand_sdk_handle *handle,
                                 unsigned int config
                                 );

/**
 * @brief 传入检测图片    input detecting image
 * @param [in] handle Created hand detect handle
 *                    已创建的人手检测句柄
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
 *                         输入图像的转向，具体请参考 bef_effect_ai_public_public_define.h 中的 bef_ai_rotate_type
 * @param [in] detection_config 请求检测的模块，为 hand_model_type 的按位与操作，目前只有HAND_MODEL_GESTURE_CLS 和 HAND_MODEL_KEY_POINT 是可选的
 * @return If succeed return BEF_RESULT_SUC, other value please see bef_effect_ai_public_public_define.h
 *         成功返回 BEF_RESULT_SUC, 失败返回相应错误码, 具体请参考 bef_effect_ai_public_public_define.h
 */
BEF_SDK_API bef_effect_result_t
bef_effect_ai_hand_detect(
                          bef_ai_hand_sdk_handle handle,
                          const unsigned char *image,
                          bef_ai_pixel_format pixel_format,
                          int image_width,
                          int image_height,
                          int image_stride,
                          bef_ai_rotate_type orientation,
                          unsigned long long detection_config,
                          bef_ai_hand_info *p_hand_info,
                          int delayframecount
                          );

/**
 * @brief 设置检测模型 set detect model
 * @param [in] handle 已创建的人手检测句柄 created hand detect handle
 * @param [in] type 模型类型    type of model
 * @param [in] strModelPath 模型文件路径  path of model file
 */
BEF_SDK_API bef_effect_result_t
bef_effect_ai_hand_detect_setmodel(bef_effect_handle_t handle,
                                   bef_ai_hand_model_type type,
                                   const char * strModelPath);

/**
 * @brief 设置检测参数 set detect model
 * @param [in] handle 已创建的人手检测句柄 created hand detect handle
 * @param [in] type 参数类型    type of param
 * @param [in] float 参数值  value of param
 */
BEF_SDK_API bef_effect_result_t
bef_effect_ai_hand_detect_setparam(bef_effect_handle_t handle,
                                   bef_ai_hand_param_type type,
                                   float value);


/**
 * @param [in] handle Destroy the created hand detect handle
 *                    销毁创建的人手检测句柄
 */
BEF_SDK_API void
bef_effect_ai_hand_detect_destroy(
                                  bef_ai_hand_sdk_handle handle
                                  );


/**
 * @brief 人手检测授权    check and get license of hand detect
 * @param [in] handle Created hand detect handle
 *                    已创建的人手检测句柄
 * @param [in] license 授权文件字符串
 * @param [in] length  授权文件字符串长度
 * @return If succeed return BEF_RESULT_SUC, other value please refer bef_effect_ai_public_public_define.h
 *         成功返回 BEF_RESULT_SUC, 授权码非法返回 BEF_RESULT_INVALID_LICENSE ，其它失败返回相应错误码, 具体请参考 bef_effect_ai_public_public_define.h
 */

#if defined(__ANDROID__) || defined(TARGET_OS_ANDROID)
BEF_SDK_API bef_effect_result_t bef_effect_ai_hand_check_license(JNIEnv* env, jobject context,
                                                                 bef_effect_handle_t handle, const char *licensePath);
#else
#ifdef __APPLE__
BEF_SDK_API bef_effect_result_t bef_effect_ai_hand_check_license(bef_effect_handle_t handle,
                                                                 const char *licensePath);
#endif
#endif


#endif // _BEF_EFFECT_FACE_DETECT_H_

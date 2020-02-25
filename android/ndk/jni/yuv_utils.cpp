#include <jni.h>
#include "bef_effect_ai_public_define.h"
#include "bef_effect_ai_yuv_process.h"
#ifdef __cplusplus
extern "C" {
#endif

JNIEXPORT void JNICALL
Java_com_bytedance_labcv_effectsdk_YUVUtils_YUV2RGBA(
        JNIEnv *env, jclass thiz, jbyteArray data, jbyteArray dst, jint format, jint image_width, jint image_height, jint dst_width, jint dst_height,
        jint orientation, jboolean is_front) {

    uint8_t * data_ptr = (uint8_t*)env->GetByteArrayElements(data, NULL);
    uint8_t * dst_ptr = (uint8_t*)env->GetByteArrayElements(dst, NULL);

    cvt_yuv2rgba(data_ptr, dst_ptr, (bef_ai_pixel_format)format, image_width, image_height,dst_width, dst_height, (bef_ai_rotate_type)orientation, is_front );

    env->ReleaseByteArrayElements(data,(jbyte*)data_ptr, 0);
    env->ReleaseByteArrayElements(dst,(jbyte*)dst_ptr, 0);
}

JNIEXPORT void JNICALL
        Java_com_bytedance_labcv_effectsdk_YUVUtils_RGBA2YUV(
                JNIEnv *env, jclass thiz, jbyteArray data, jbyteArray dst, jint format, jint image_width, jint image_height
                ) {
    uint8_t * data_ptr = (uint8_t*)env->GetByteArrayElements(data, NULL);
    uint8_t * dst_ptr = (uint8_t*)env->GetByteArrayElements(dst, NULL);

    cvt_rgba2yuv(data_ptr, dst_ptr, (bef_ai_pixel_format)format, image_width, image_height);

    env->ReleaseByteArrayElements(data,(jbyte*)data_ptr, 0);
    env->ReleaseByteArrayElements(dst,(jbyte*)dst_ptr, 0);


}



#ifdef __cplusplus
}
#endif

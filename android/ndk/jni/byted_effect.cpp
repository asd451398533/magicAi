// Copyright (C) 2018 Beijing Bytedance Network Technology Co., Ltd.

#include <jni.h>
#include <string.h>
#include <malloc.h>
#include <string>
#include "byted_effect.h"
#include "bef_effect_ai_api.h"
#include "bef_effect_ai_version.h"
#include "bef_effect_ai_public_define.h"

static const char *CLASS = "com/bytedance/labcv/effectsdk/RenderManager";


typedef struct {
    jlong handle;
} PACK;


static jint
nativeInit(JNIEnv *env, jobject thiz, jobject context, jstring algorithmResourceDir_,
           jstring license_) {
    PACK *pack = new PACK;

    bef_effect_result_t ret;

    jclass clazz = env->FindClass(CLASS);
    jfieldID field = env->GetFieldID(clazz, "mNativePtr", "J");

    const char *algorithmResourceDir = env->GetStringUTFChars(algorithmResourceDir_, 0);
    const char *license = env->GetStringUTFChars(license_, 0);
    //const char *version = env->GetStringUTFChars(version_, 0);

    bef_effect_handle_t handle;
    if ((ret = bef_effect_ai_create(&handle)) != BEF_RESULT_SUC) {
        goto fail;
    }


    ret = bef_effect_ai_check_license(env, context, handle, license);
    if (ret != BEF_RESULT_SUC) {
        goto fail;
    }
    // 此处只需要传入一个非0的宽高即可，真实的宽高在processTexure中传入即可
    if ((ret = bef_effect_ai_init(handle, 10, 10, algorithmResourceDir, "")) !=
        BEF_RESULT_SUC) {
        goto fail;
    }


    pack->handle = (jlong) handle;

    env->SetLongField(thiz, field, (jlong) pack);

    fail:
    if (ret != BEF_RESULT_SUC) {
        delete (pack);
    }
    env->ReleaseStringUTFChars(algorithmResourceDir_, algorithmResourceDir);
    env->ReleaseStringUTFChars(license_, license);
    env->DeleteLocalRef(clazz);
    return ret;
}

static jstring nativeGetSDKVersion(JNIEnv *env, jobject thiz){
    char *res = new char[10];
    int ret = bef_effect_ai_get_version(res, 10);

    if (ret ==BEF_RESULT_SUC && res != NULL) {
        jstring str = env->NewStringUTF(res);
        delete[] (res);
        return str;
    }
    return NULL;
}

static jint
nativeGetAvailableFeatures(JNIEnv *env, jobject thiz, jobjectArray array) {
    jclass clazz = env->FindClass(CLASS);
    jfieldID field = env->GetFieldID(clazz, "mNativePtr", "J");
    env->DeleteLocalRef(clazz);

    PACK *pack = (PACK *) env->GetLongField(thiz, field);

    if (pack == NULL) {
        return BEF_RESULT_FAIL;
    }

    int featureLength = env->GetArrayLength(array);
    char features[featureLength][BEF_EFFECT_FEATURE_LEN];
    bef_effect_result_t ret = bef_effect_available_features((bef_effect_handle_t) pack->handle,
                                                            features, &featureLength);
    if (ret != BEF_RESULT_SUC) {
        return ret;
    }

    for (int i = 0; i < featureLength; i++) {
        env->SetObjectArrayElement(array, i, env->NewStringUTF(features[i]));
    }

    return BEF_RESULT_SUC;
}

static jint nativeSetCameraPosition(JNIEnv *env, jobject thiz,jboolean isFront){
    jclass clazz = env->FindClass(CLASS);
    jfieldID field = env->GetFieldID(clazz, "mNativePtr", "J");
    env->DeleteLocalRef(clazz);

    PACK *pack = (PACK *) env->GetLongField(thiz, field);

    if (pack == NULL) {
        return BEF_RESULT_FAIL;
    }
    return  bef_effect_ai_set_camera_device_position((bef_effect_handle_t) pack->handle,
                                                     isFront?bef_ai_camera_position_front:bef_ai_camera_position_back);


}

static jint
nativeCheckLicense(JNIEnv *env, jobject thiz, jobject context, jstring license_) {
    jclass clazz = env->FindClass(CLASS);
    jfieldID field = env->GetFieldID(clazz, "mNativePtr", "J");
    env->DeleteLocalRef(clazz);
    bef_effect_result_t ret;

    PACK *pack = (PACK *) env->GetLongField(thiz, field);

    if (pack == NULL) {
        return BEF_RESULT_FAIL;
    }

    bef_effect_handle_t handle = (bef_effect_handle_t) pack->handle;
    const char *license = env->GetStringUTFChars(license_, 0);

    ret = bef_effect_ai_check_license(env, context, handle, license);

    env->ReleaseStringUTFChars(license_, license);

    return ret;
}

static void
nativeRelease(JNIEnv *env, jobject thiz) {
    jclass clazz = env->FindClass(CLASS);
    jfieldID field = env->GetFieldID(clazz, "mNativePtr", "J");

    PACK *pack = (PACK *) env->GetLongField(thiz, field);

    if (pack != NULL) {
        bef_effect_ai_destroy((bef_effect_handle_t) pack->handle);
    }

    env->SetLongField(thiz, field, 0);
    env->DeleteLocalRef(clazz);
}

static jint
nativeSetBeauty(JNIEnv *env, jobject thiz, jstring beautyType_) {
    jclass clazz = env->FindClass(CLASS);
    jfieldID field = env->GetFieldID(clazz, "mNativePtr", "J");
    env->DeleteLocalRef(clazz);

    PACK *pack = (PACK *) env->GetLongField(thiz, field);

    if (pack == NULL) {
        return BEF_RESULT_FAIL;
    }

    const char *beautyType = env->GetStringUTFChars(beautyType_, 0);

    bef_effect_handle_t handle = (bef_effect_handle_t) pack->handle;
    bef_effect_result_t ret = bef_effect_ai_set_beauty(handle, beautyType);
    env->ReleaseStringUTFChars(beautyType_, beautyType);
    return ret;
}

static jint
nativeProcess(JNIEnv *env, jobject thiz, jint srcTextureId, jint dstTextureId, jint width,
              jint height, jint rotation, jdouble timeStamp) {
    jclass clazz = env->FindClass(CLASS);
    jfieldID field = env->GetFieldID(clazz, "mNativePtr", "J");
    env->DeleteLocalRef(clazz);

    PACK *pack = (PACK *) env->GetLongField(thiz, field);

    if (pack == NULL) {
        return BEF_RESULT_FAIL;
    }

    bef_effect_handle_t handle = (bef_effect_handle_t) pack->handle;
    bef_effect_result_t ret = bef_effect_ai_set_width_height(handle, width, height);

    if (ret != BEF_RESULT_SUC) {
        LOGD("nativeProcess bef_effect_ai_set_width_height: handle = %p, width = %d, height = %d, error %d",
             handle, width, height, ret);
    }

    ret = bef_effect_ai_set_orientation(handle, (bef_ai_rotate_type) rotation);
    if (ret != BEF_RESULT_SUC) {
        LOGE("nativeProcess bef_effect_ai_set_orientation: error %d", ret);
    }

    ret = bef_effect_ai_algorithm_texture(handle, srcTextureId, timeStamp);
    if (ret != BEF_RESULT_SUC) {
        if (ret != -11)
            LOGE("nativeProcess bef_effect_ai_algorithm_texture: error %d", ret);
    }

    return bef_effect_ai_process_texture(handle, srcTextureId, dstTextureId, timeStamp);
}


static jint
nativeProcessBuffer(JNIEnv *env, jobject thiz, jobject inbuffer, jint rotation, jint pixel_format,
                    jint image_width, jint image_height,
                    jint image_stride, jbyteArray outbuffer, jint out_pixel_format,
                    jdouble timeStamp) {

    jclass clazz = env->FindClass(CLASS);
    jfieldID field = env->GetFieldID(clazz, "mNativePtr", "J");
    env->DeleteLocalRef(clazz);

    PACK *pack = (PACK *) env->GetLongField(thiz, field);

    if (pack == NULL) {
        return BEF_RESULT_FAIL;
    }

    bef_effect_handle_t handle = (bef_effect_handle_t) pack->handle;

    if (handle == NULL) {
        return BEF_RESULT_INVALID_EFFECT_HANDLE;
    }
    bef_effect_result_t ret = bef_effect_ai_set_width_height(handle, image_width, image_height);

    if (ret != BEF_RESULT_SUC) {
        LOGE("nativeProcess bef_effect_ai_set_width_height: handle = %p, width = %d, height = %d, error %d",
             handle, image_width, image_height, ret);
    }

    ret = bef_effect_ai_set_orientation(handle, (bef_ai_rotate_type) rotation);
    if (ret != BEF_RESULT_SUC) {
        LOGE("nativeProcess bef_effect_ai_set_orientation: error %d", ret);
    }
    const unsigned char *image = (const unsigned char *) env->GetDirectBufferAddress(inbuffer);

    ret = bef_effect_ai_algorithm_buffer(handle, image,
                                         (bef_ai_pixel_format) pixel_format,
                                         image_width, image_height,
                                         image_stride, timeStamp);
    if (ret != BEF_RESULT_SUC) {
        if (ret != -11)
            LOGE("nativeProcess bef_effect_ai_algorithm_texture: error %d", ret);
    }


    unsigned char *outimage = (unsigned char *) env->GetByteArrayElements(outbuffer, NULL);

    bef_effect_result_t result = bef_effect_ai_process_buffer(handle, image,
                                                              (bef_ai_pixel_format) pixel_format,
                                                              image_width, image_height,
                                                              image_stride,
                                                              outimage,
                                                              (bef_ai_pixel_format) out_pixel_format,
                                                              timeStamp);

    if (result != BEF_RESULT_SUC) {
        LOGE("nativeProcessBuffer bef_effect_ai_process_buffer: error %d", ret);
        return ret;
    }

    env->ReleaseByteArrayElements(outbuffer, (jbyte *) outimage, 0);
    return result;
}


static jint
nativeSetFilter(JNIEnv *env, jobject thiz, jstring filterPath_) {
    jclass clazz = env->FindClass(CLASS);
    jfieldID field = env->GetFieldID(clazz, "mNativePtr", "J");
    env->DeleteLocalRef(clazz);

    PACK *pack = (PACK *) env->GetLongField(thiz, field);

    if (pack == NULL) {
        return BEF_RESULT_FAIL;
    }

    bef_effect_handle_t handle = (bef_effect_handle_t) pack->handle;

    const char *filterPath = env->GetStringUTFChars(filterPath_, 0);

    bef_effect_result_t ret = bef_effect_ai_set_color_filter_v2(handle, filterPath);
    if (ret != BEF_RESULT_SUC) {
        goto fail;
    }

    fail:
    env->ReleaseStringUTFChars(filterPath_, filterPath);
    return ret;
}

static jint
nativeSetReshape(JNIEnv *env, jobject thiz, jstring reshapePath_) {
    jclass clazz = env->FindClass(CLASS);
    jfieldID field = env->GetFieldID(clazz, "mNativePtr", "J");
    env->DeleteLocalRef(clazz);

    PACK *pack = (PACK *) env->GetLongField(thiz, field);

    if (pack == NULL) {
        return BEF_RESULT_FAIL;
    }

    bef_effect_handle_t handle = (bef_effect_handle_t) pack->handle;

    const char *reshapePath = env->GetStringUTFChars(reshapePath_, 0);

    bef_effect_result_t ret = bef_effect_ai_set_reshape_face(handle, reshapePath);
    if (ret != BEF_RESULT_SUC) {
        LOGE("bef_effect_ai_set_reshape_face error: %d", ret);
        goto fail;
    }


    fail:
    env->ReleaseStringUTFChars(reshapePath_, reshapePath);
    return ret;
}

static jint
nativeSetMakeUp(JNIEnv *env, jobject thiz, jstring makeUpPath_) {
    jclass clazz = env->FindClass(CLASS);
    jfieldID field = env->GetFieldID(clazz, "mNativePtr", "J");
    env->DeleteLocalRef(clazz);

    PACK *pack = (PACK *) env->GetLongField(thiz, field);

    if (pack == NULL) {
        return BEF_RESULT_FAIL;
    }

    bef_effect_handle_t handle = (bef_effect_handle_t) pack->handle;

    const char *makeUpPath = env->GetStringUTFChars(makeUpPath_, 0);

    bef_effect_result_t ret = bef_effect_ai_set_buildin_makeup(handle, makeUpPath);
    if (ret != BEF_RESULT_SUC) {
        LOGE("bef_effect_ai_set_buildin_makeup error: %d", ret);
        goto fail;
    }


    fail:
    env->ReleaseStringUTFChars(makeUpPath_, makeUpPath);
    return ret;
}

static jint
nativeSetSticker(JNIEnv *env, jobject thiz, jstring stickerPath_) {
    jclass clazz = env->FindClass(CLASS);
    jfieldID field = env->GetFieldID(clazz, "mNativePtr", "J");
    env->DeleteLocalRef(clazz);

    PACK *pack = (PACK *) env->GetLongField(thiz, field);

    if (pack == NULL) {
        return BEF_RESULT_FAIL;
    }

    bef_effect_handle_t handle = (bef_effect_handle_t) pack->handle;

    const char *stickerPath = env->GetStringUTFChars(stickerPath_, 0);

    bef_effect_result_t ret = bef_effect_ai_set_effect(handle, stickerPath);
    if (ret != BEF_RESULT_SUC) {
        LOGE("bef_effect_ai_set_effect error: %d", ret);
        goto fail;
    }


    fail:
    env->ReleaseStringUTFChars(stickerPath_, stickerPath);
    return ret;
}


static jint nativeUpdateIntensity(JNIEnv *env, jobject thiz, jint itype, jfloat intensity) {
    jclass clazz = env->FindClass(CLASS);
    jfieldID field = env->GetFieldID(clazz, "mNativePtr", "J");
    env->DeleteLocalRef(clazz);

    PACK *pack = (PACK *) env->GetLongField(thiz, field);

    if (pack == NULL) {
        return BEF_RESULT_FAIL;
    }

    bef_effect_handle_t handle = (bef_effect_handle_t) pack->handle;
    bef_effect_result_t ret =
            bef_effect_ai_set_intensity(handle, itype, intensity);
    if (ret != BEF_RESULT_SUC) {
        LOGE("nativeUpdateIntensity %d set value = %f error: %d", itype, intensity, ret);
    }
    return ret;
}

static jint
nativeUpdateReshape(JNIEnv *env, jobject thiz, float cheekintensity, float eyeintensity) {
    jclass clazz = env->FindClass(CLASS);
    jfieldID field = env->GetFieldID(clazz, "mNativePtr", "J");
    env->DeleteLocalRef(clazz);

    PACK *pack = (PACK *) env->GetLongField(thiz, field);

    if (pack == NULL) {
        return BEF_RESULT_FAIL;
    }

    bef_effect_handle_t handle = (bef_effect_handle_t) pack->handle;
    bef_effect_result_t ret =
            bef_effect_ai_update_reshape_face_intensity(handle, eyeintensity, cheekintensity);

    if (ret != BEF_RESULT_SUC) {
        LOGE("face reshape idensity update   error: %d", ret);
    }
    return ret;
}

static jint
nativeSetComposer(JNIEnv *env, jobject thiz, jstring jcomposerPath) {
    jclass clazz = env->FindClass(CLASS);
    jfieldID field = env->GetFieldID(clazz, "mNativePtr", "J");
    env->DeleteLocalRef(clazz);

    PACK *pack = (PACK *) env->GetLongField(thiz, field);

    if (pack == NULL) {
        return BEF_RESULT_FAIL;
    }
    const char *composerPath = env->GetStringUTFChars(jcomposerPath, 0);

    bef_effect_handle_t handle = (bef_effect_handle_t) pack->handle;
    bef_effect_result_t ret = 0;
    ret = bef_effect_ai_set_composer(handle, composerPath);
    env->ReleaseStringUTFChars(jcomposerPath, composerPath);
    return ret;
}

static jint
nativeSetComposerMode(JNIEnv *env, jobject thiz, jint mode, jint orderType) {
    jclass clazz = env->FindClass(CLASS);
    jfieldID field = env->GetFieldID(clazz, "mNativePtr", "J");
    env->DeleteLocalRef(clazz);

    PACK *pack = (PACK *) env->GetLongField(thiz, field);

    if (pack == NULL) {
        return BEF_RESULT_FAIL;
    }

    bef_effect_handle_t handle = (bef_effect_handle_t) pack->handle;
    bef_effect_result_t ret;
    ret = bef_effect_ai_composer_set_mode(handle, mode, orderType);
    return ret;
}

static jint
nativeSetComposerNodes(JNIEnv *env, jobject thiz, jobjectArray jcomposerNodePaths) {
    jclass clazz = env->FindClass(CLASS);
    jfieldID field = env->GetFieldID(clazz, "mNativePtr", "J");
    env->DeleteLocalRef(clazz);

    PACK *pack = (PACK *) env->GetLongField(thiz, field);

    if (pack == NULL) {
        return BEF_RESULT_FAIL;
    }
    jsize size = env->GetArrayLength(jcomposerNodePaths);
    char **nodePaths = (char **) malloc(size * sizeof(char *));


    if (NULL == nodePaths) {
        LOGE("nodePaths malloc error!!");
        return BEF_RESULT_FAIL;
    }
    for (int i = 0; i < size; ++i) {
        jstring nodePath = (jstring) env->GetObjectArrayElement(jcomposerNodePaths, i);
        const char *ptr_nodePath = env->GetStringUTFChars(nodePath, 0);
        size_t length = env->GetStringLength(nodePath) + 1;

        nodePaths[i] = (char *) malloc(sizeof(char) * length);
        if (nodePaths[i] == NULL) {
            LOGE("nodePaths[i] malloc error!!");
            return BEF_RESULT_FAIL;
        }
        memcpy(nodePaths[i], ptr_nodePath, length);
        env->ReleaseStringUTFChars(nodePath, ptr_nodePath);
    }
    bef_effect_handle_t handle = (bef_effect_handle_t) pack->handle;
    bef_effect_result_t ret = bef_effect_ai_composer_set_nodes(handle, (const char **) nodePaths,
                                                               size);
    if (ret != BEF_RESULT_SUC) {
        LOGE("bef_effect_ai_composer_set_nodes error!! ret =%d", ret);
    }
    for (int i = 0; i < size; ++i) {
        free(nodePaths[i]);
    }
    free(nodePaths);

    return ret;
}

static jint
nativeUpdateComposeNodes(JNIEnv *env, jobject thiz, jstring jcomposeNodePath,
                         jstring jcomposeNodeKey, jfloat value) {
    jclass clazz = env->FindClass(CLASS);
    jfieldID field = env->GetFieldID(clazz, "mNativePtr", "J");
    env->DeleteLocalRef(clazz);

    PACK *pack = (PACK *) env->GetLongField(thiz, field);
    if (pack == NULL) {
        return BEF_RESULT_FAIL;
    }
    bef_effect_handle_t handle = (bef_effect_handle_t) pack->handle;

    const char *composeNodePath = env->GetStringUTFChars(jcomposeNodePath, 0);
    const char *composeNodeKey = env->GetStringUTFChars(jcomposeNodeKey, 0);

    int ret = bef_effect_ai_composer_update_node(handle, composeNodePath, composeNodeKey, value);
    if (ret != BEF_RESULT_SUC) {
        LOGE("bef_effect_ai_composer_update_node error!! ret = %d", ret);
    }

    env->ReleaseStringUTFChars(jcomposeNodePath, composeNodePath);
    env->ReleaseStringUTFChars(jcomposeNodeKey, composeNodeKey);

    return ret;
}


static JNINativeMethod gMethods[] = {
        {"nativeInit",             "(Landroid/content/Context;Ljava/lang/String;Ljava/lang/String;)I", (void *) nativeInit},
        {"nativeGetSDKVersion",         "()Ljava/lang/String;", (void *) nativeGetSDKVersion},
        {"nativeSetCameraPosition","(Z)I",                                                              (void *) nativeSetCameraPosition},
        {"nativeRelease",          "()V",                                                                (void *) nativeRelease},
        {"nativeSetBeauty",        "(Ljava/lang/String;)I",                                              (void *) nativeSetBeauty},
        {"nativeSetFilter",        "(Ljava/lang/String;)I",                                              (void *) nativeSetFilter},
        {"nativeSetReshape",       "(Ljava/lang/String;)I",                                              (void *) nativeSetReshape},
        {"nativeSetMakeUp",        "(Ljava/lang/String;)I",                                              (void *) nativeSetMakeUp},
        {"nativeSetSticker",       "(Ljava/lang/String;)I",                                              (void *) nativeSetSticker},
        {"nativeProcess",          "(IIIIID)I",                                                          (void *) nativeProcess},
        {"nativeProcessBuffer",    "(Ljava/nio/ByteBuffer;IIIII[BID)I",                                  (void *) nativeProcessBuffer},
        {"nativeUpdateIntensity",  "(IF)I",                                                              (void *) nativeUpdateIntensity},
        {"nativeUpdateReshape",    "(FF)I",                                                              (void *) nativeUpdateReshape},
        {"nativeSetComposer",      "(Ljava/lang/String;)I",                                              (void *) nativeSetComposer},
        {"nativeSetComposerNodes", "([Ljava/lang/String;)I",                                             (void *) nativeSetComposerNodes},
        {"nativeUpdateComposer",   "(Ljava/lang/String;Ljava/lang/String;F)I",                           (void *) nativeUpdateComposeNodes},
        {"nativeSetComposerMode",  "(II)I",                                                              (void *) nativeSetComposerMode},
        {"nativeGetAvailableFeatures", "([Ljava/lang/String;)I",                                         (void *) nativeGetAvailableFeatures}
};


jint initRenderContext(JavaVM *vm);

void releaseRenderContext(JavaVM *vm);

extern "C" jint JNI_OnLoad(JavaVM *vm, void *reserved) {
    jint result = -1;
    JNIEnv *env = NULL;

    if (vm->GetEnv((void **) &env, JNI_VERSION_1_4) != JNI_OK) {
        return -1;
    }

    initRenderContext(vm);

    jclass clazz = env->FindClass(CLASS);
    if (env->RegisterNatives(clazz, gMethods, NELEMS(gMethods)) < 0) {
        LOGE("RegisterNatives failed");
        return result;
    }

    result = JNI_VERSION_1_4;

    return result;
}

extern "C" JNIEXPORT void JNI_OnUnload(JavaVM *vm, void *reserved) {
    releaseRenderContext(vm);
}

JavaVM *g_vm;
jclass g_opengGlUtilClass = nullptr;
jmethodID g_loadBitmapMethodId = nullptr;

bool buildJniCache(JNIEnv *env) {
    bool res = false;
    if (nullptr == env) {
        return res;
    }
    g_opengGlUtilClass = env->FindClass("com/bef/effectsdk/OpenGLUtils");
    g_opengGlUtilClass = static_cast<jclass>(env->NewGlobalRef(g_opengGlUtilClass));
    jmethodID methodId = env->GetStaticMethodID(g_opengGlUtilClass, "loadBitmap",
                                                "(Ljava/lang/String;)Landroid/graphics/Bitmap;");
    if (nullptr == methodId) {
        LOGE("buildJniCache: find java loadBitmap method failed");
        return res;
    }
    g_loadBitmapMethodId = methodId;
    res = true;
    return res;
}


jint initRenderContext(JavaVM *vm) {
    JNIEnv *env = nullptr;
    jint result = -1;
    if (vm->GetEnv((void **) &env, JNI_VERSION_1_4) != JNI_OK) {
        return result;
    }
    g_vm = vm;

    buildJniCache(env);
    // 返回jni的版本
    return 0;
}

void releaseRenderContext(JavaVM *vm) {
    JNIEnv *env;

    if (vm->GetEnv((void **) &env, JNI_VERSION_1_4) != JNI_OK) {
        // Something is wrong but nothing we can do about this :(
        return;
    } else {
        // delete global references so the GC can collect them
        if (nullptr != g_opengGlUtilClass) {
            env->DeleteGlobalRef(g_opengGlUtilClass);
        }
    }
}

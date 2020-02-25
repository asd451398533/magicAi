LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := effect
LOCAL_SRC_FILES :=  $(LOCAL_PATH)/../../libs/$(TARGET_ARCH_ABI)/libeffect.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := effect_proxy

ifdef MODULE_FLAG # 通过脚本进行编译
    BUILD_MODULE_FLAG := $(MODULE_FLAG)
    $(info In Build Scripts)
    $(info BUILD_MODULE: =====> $(MODULE_FLAG))
else
    BUILD_MODULE_FLAG := LABCV_TOB_FULL
    #BUILD_MODULE_FLAG := LABCV_TOB_BEAUTY_FILTER

    $(info In Build Projects)
    $(info BUILD_MODULE: =====> $(BUILD_MODULE_FLAG))
endif

LOCAL_SRC_FILES :=  $(LOCAL_PATH)/byted_effect.cpp \
$(LOCAL_PATH)/yuv_utils.cpp \



LOCAL_C_INCLUDES +=   \
$(LOCAL_PATH)/include

LOCAL_CFLAGS += -std=c++11 -fexceptions -frtti -D$(BUILD_MODULE_FLAG)
LOCAL_LDLIBS += -llog
LOCAL_LDLIBS += -lGLESv2
LOCAL_SHARED_LIBRARIES := libeffect

include $(BUILD_SHARED_LIBRARY)

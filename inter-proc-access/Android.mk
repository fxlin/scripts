LOCAL_PATH:= $(call my-dir)
include $(CLEAR_VARS)
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE := false-sharing-contention-org
LOCAL_SRC_FILES := false-sharing-contention-org.c
LOCAL_LDLIBS += -lpthread

include $(BUILD_EXECUTABLE)

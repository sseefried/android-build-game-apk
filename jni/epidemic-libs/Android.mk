LOCAL_PATH := $(call my-dir)

# The libmain that SDL enters

include $(CLEAR_VARS)
LOCAL_MODULE     := main
LOCAL_C_INCLUDES := $(LOCAL_PATH)/include
LOCAL_SRC_FILES  := src/SDL_android_main.c main.c

#
# sseefried:
# Even though the Android makefile infrastructure protests
# 'non-system libraries in linker flags' when you cram all
# the 'local static libraries' into LOCAL_LDLIBS I prefer
# this method since I can also pass the --start-group and
# --end-group linker flags meaning that the order in which
# the libraries are listed is not important. Working out
# the dependency order is not something I think I should have
# to do!
#

LOCAL_LDFLAGS += -Wl,--export-dynamic

LOCAL_LDLIBS := -L$(LOCAL_PATH)/$(TARGET_ARCH_ABI) \
 -Wl,--start-group \
 -llog \
 -lEpidemic \
 -lSDL2_mixer \
 -lSDL2 \
 -landroid \
 -lGLESv1_CM \
 -lGLESv2 \
 -liconv \
 -lvorbisfile \
 -lvorbis \
 -logg \
 -lfreetype \
 -lcairo \
 -lpixman-1 \
 -lpng \
 -lz \
 -lgmp \
 -lcpufeatures \
 -Wl,--end-group

include $(BUILD_SHARED_LIBRARY)
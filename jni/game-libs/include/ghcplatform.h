#ifndef __GHCPLATFORM_H__
#define __GHCPLATFORM_H__

#define BuildPlatform_TYPE  i386_unknown_linux
#define HostPlatform_TYPE   arm_unknown_linux_android

#define i386_unknown_linux_BUILD  1
#define arm_unknown_linux_android_HOST  1

#define i386_BUILD_ARCH  1
#define arm_HOST_ARCH  1
#define BUILD_ARCH  "i386"
#define HOST_ARCH  "arm"

#define linux_BUILD_OS  1
#define linux_android_HOST_OS  1
#define BUILD_OS  "linux"
#define HOST_OS  "linux_android"

#define unknown_BUILD_VENDOR  1
#define unknown_HOST_VENDOR  1
#define BUILD_VENDOR  "unknown"
#define HOST_VENDOR  "unknown"

/* These TARGET macros are for backwards compatibility... DO NOT USE! */
#define TargetPlatform_TYPE arm_unknown_linux_android
#define arm_unknown_linux_android_TARGET  1
#define arm_TARGET_ARCH  1
#define TARGET_ARCH  "arm"
#define linux_android_TARGET_OS  1
#define TARGET_OS  "linux_android"
#define unknown_TARGET_VENDOR  1

#endif /* __GHCPLATFORM_H__ */

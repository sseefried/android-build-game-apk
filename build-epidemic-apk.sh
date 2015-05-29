#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
####################################################################################################

BUILD_VARS=$THIS_DIR/build-vars.rc
BUILD_VARS_BASE=$(basename $BUILD_VARS)
APK=com.declarative.games.epidemic.beta-release.apk
CABAL=arm-linux-androideabi-cabal
EPIDEMIC_C_LIBS="cairo cpufeatures freetype gmp iconv ogg pixman-1 png vorbis vorbisfile SDL2_mixer SDL2"

####################################################################################################

#
# Check for $BUILD_VARS file
#
if [ ! -f $BUILD_VARS ]; then
  echo "You must create a file called $BUILD_VARS_BASE"
  echo "See '$BUILD_VARS_BASE.example'"
  exit 1
fi

source $BUILD_VARS

#
# Check for $CABAL
#
which $CABAL > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Could not find $CABAL"
  exit 1
fi

if [ "$EPIDEMIC_REPO" = "" ]; then
  echo
  echo "$(basename $BUILD_VARS) does not defined EPIDEMIC_REPO variable."
  echo "It must be set to the full path of the Epidemic game git repo."
  exit 1
fi

if [ "$EPIDEMIC_C_LIB_DIR" = "" ]; then
  echo
  echo "$(basename $BUILD_VARS) does not defined EPIDEMIC_C_LIB_DIR variable."
  echo "It must be set to the full path of the dir containing the following files: "
  for i in $EPIDEMIC_C_LIBS; do
    echo "  lib$i.a"
  done
  exit 1
fi

for i in $EPIDEMIC_C_LIBS; do
  if [ ! -f $EPIDEMIC_C_LIB_DIR/lib$i.a ]; then
    echo "Could not find required library file 'lib$i.a'"
    exit 1
  fi
done

if [ "$NDK" = "" ]; then
  echo
  echo "$(basename $BUILD_VARS) does not defined NDK variable."
  echo "It must be set to the Android NDK directory containing file 'ndk-build'"
  exit 1
fi


cd $EPIDEMIC_REPO
$CABAL install -fandroid $@
[ $? -eq 0 ] || exit 1

cd $THIS_DIR

echo "[+] Copy across assets"
mkdir -p assets
cp $EPIDEMIC_REPO/assets/* assets

LIBS=`$THIS_DIR/resolve-libs arm-unknown-linux-androideabi-ghc-pkg Epidemic`
rm -rf libEpidemic.a
ar crsT libEpidemic.a $LIBS

TGT=jni/epidemic-libs/armeabi
mkdir -p $TGT


for i in $EPIDEMIC_C_LIBS; do
  cp $EPIDEMIC_C_LIB_DIR/lib$i.a $TGT || exit 1
done

cp libEpidemic.a $TGT

$NDK/ndk-build clean && $NDK/ndk-build -j9 && ant debug
[ $? -eq 0 ] || exit 1
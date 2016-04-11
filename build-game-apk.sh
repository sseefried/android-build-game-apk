#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
####################################################################################################

cd $THIS_DIR
for i in `find . -name '*.j2'`; do
  j2 "$i" config.json > "$(dirname $i)/$(basename $i .j2)"
done
####################################################################################################

source build-vars.rc

CABAL="arm-linux-androideabi-cabal"
GAME_C_LIBS="cairo cpufeatures freetype gmp iconv ogg pixman-1 png vorbis vorbisfile SDL2_mixer SDL2"


#
# Check for $CABAL
#
which $CABAL > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Could not find $CABAL"
  exit 1
fi

if [ "$GAME_REPO" = "" ]; then
  echo
  echo "$(basename $BUILD_VARS) does not defined GAME_REPO variable."
  echo "It must be set to the full path of the Epidemic game git repo."
  exit 1
fi

if [ "$GAME_C_LIB_DIR" = "" ]; then
  echo
  echo "$(basename $BUILD_VARS) does not defined GAME_C_LIB_DIR variable."
  echo "It must be set to the full path of the dir containing the following files: "
  for i in $GAME_C_LIBS; do
    echo "  lib$i.a"
  done
  exit 1
fi

for i in $GAME_C_LIBS; do
  if [ ! -f $GAME_C_LIB_DIR/lib$i.a ]; then
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


cd $GAME_REPO
echo `pwd`
$CABAL install -fandroid $@
[ $? -eq 0 ] || exit 1

cd $THIS_DIR

if [ "$ASSETS_DIR" != "" -a "$ASSETS_DIR" != "None" ]; then
  echo "[+] Copy across assets (if any)"
  mkdir -p assets
  cp $ASSETS_DIR/* assets
else
  rm -rf assets
fi

LIBS=`$THIS_DIR/resolve-libs arm-unknown-linux-androideabi-ghc-pkg $HASKELL_PACKAGE`
ar crsT libhaskell_game.a $LIBS

TGT=jni/game-libs/armeabi
rm -rf $TGT
mkdir -p $TGT


for i in $GAME_C_LIBS; do
  cp $GAME_C_LIB_DIR/lib$i.a $TGT || exit 1
done

cp libhaskell_game.a $TGT

$NDK/ndk-build clean && $NDK/ndk-build -j9 && ant $BUILD_TYPE
[ $? -eq 0 ] || exit 1
#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
####################################################################################################

cd "$THIS_DIR/jinja2-templates"
for i in $(find . -name '*.j2'); do
  mkdir -p $THIS_DIR/$(dirname $i)
  j2 "$i" $THIS_DIR/config.json > "$THIS_DIR/$(dirname $i)/$(basename $i .j2)"
done

cd $THIS_DIR

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

#
# Remove icons
#
for typ in mdpi hdpi xhdpi xxhdpi; do
  rm -rf res/drawable-$typ
done

if [ "$ICONS_DIR" != "" -a "$ICONS_DIR" != "None" ]; then
  for typ in mdpi hdpi xhdpi xxhdpi; do
    if [ -d "$ICONS_DIR/drawable-$typ" ]; then
      cp -r "$ICONS_DIR/drawable-$typ" res
    fi
  done
else
  mkdir -p res/drawable-xxhdpi
  cp lambda-icon.png res/drawable-xxhdpi/ic_launcher.png
fi

LIBS=`$THIS_DIR/resolve-libs arm-unknown-linux-androideabi-ghc-pkg $HASKELL_PACKAGE`
[ $? -eq 0 ] || exit 1
rm -f libhaskell_game.a && ar crsT libhaskell_game.a $LIBS

TGT=jni/game-libs/armeabi
rm -rf $TGT && mkdir -p $TGT

for i in $GAME_C_LIBS; do
  cp $GAME_C_LIB_DIR/lib$i.a $TGT || exit 1
done

cp libhaskell_game.a $TGT

$NDK/ndk-build clean && $NDK/ndk-build -j9 && ant $BUILD_TYPE
[ $? -eq 0 ] || exit 1

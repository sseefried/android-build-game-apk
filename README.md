# Scripts to build Epidemic for Android

## Introduction

[Epidemic](https://github.com/sseefried/open-epidemic-game) is a game written for mobile
devices in Haskell. (Want to help beta test? Please [subscribe](http://eepurl.com/boW1vz).)

This repo contains a script called `build-epidemic-apk.sh` to build the game for Android
devices using ARMv7 (or compatible) chipsets. The repo contains a thin Java wrapper that
calls into the natively compiled code of the game.

## Setting up a development environment

This won't just work out of the box. You will require a GHC cross compiler targetting
ARMv7 and will need to build all the associated libraries. This isn't straightforward at all!

However, I've done all the work for you with the help of Docker. Please see the repo
[`docker-epidemic-build-env`](https://github.com/sseefried/docker-epidemic-build-env.git)
for more details.

## Setting up the build script

You will need to create a file called `build-vars.rc`. See
[`build-vars-rc.example`](https://github.com/sseefried/android-build-epidemic-apk/blob/master/build-vars.rc.example)

You will need to set paths for:

* The [Epidemic](https://github.com/sseefried/open-epidemic-game) repo
* The Android NDK
* the directory containing static C libraries that Epidemic requires.

If you have used the `Dockerfile` in the repo
[`docker-epidemic-build-env`](https://github.com/sseefried/docker-epidemic-build-env.git)
(mentioned above), then you can just

    $ cp build-vars.rc.example build-vars.rc

## Build

Now you can build it:

    $ ./build-android-apk.sh


## Installing the APK on Android devices

Once you have run the build script you should find the file:

    bin/com.declarative.games.epidemic.beta-debug.apk

You can install this file on your Android device with [`adb`](http://developer.android.com/tools/help/adb.html).

    adb install -r com.declarative.games.epidemic.beta-debug.apk

On your device you will need to tick "Unknown Sources" in "Settings -> Security".


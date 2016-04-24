# Scripts to build games for Android

## Introduction

This repo contains a script called `build-game-apk.sh` to build games written
in Haskell for Android devices using ARMv7 (or compatible) chipsets. The repo
contains a thin Java wrapper that calls into the natively compiled code of the game.

## Setting up a development environment

This won't just work out of the box. You will require a GHC cross compiler targetting
ARMv7 and will need to build all the associated libraries. This isn't straightforward at all!

However, I've done all the work for you with the help of Docker. Please see the repo
[`docker-build-game-env`](https://github.com/sseefried/docker-build-game-env.git)
for more details.

Once you have created the Docker container and followed its instructions
return here and then you can build your game.

## Requirements of the game repo

The game repo must satisfy a few requirements.

0. The game must be built on top of the SDL2 library or at least utilise it.

1. The game repo must have a Cabal build flag `android` that builds the
   game as a static library. i.e. `cabal install -fandroid` will build this
   library.


2. The library must expose a function called `haskell_main` via the 
   GHC FFI (Foreign Function Interface). It must have the type `CString -> IO ()`
   An example appears below:

    foreign export ccall "haskell_main" main :: CString -> IO ()

    main :: CString -> IO ()
    main cstr = do
	  ... code ...
	  
The `CString` passed in is the path to the assets directory (if your game
uses any assets).

## Configuring the build script with `config.json`

You will need to create a file called `config.json`. See
[`config.json.example`](https://github.com/sseefried/android-build-game-apk/blob/master/config.json.example)

The JSON file _must_ contain all the fields found in `config.json.example`. 

* `repo`: Full path to the repo of your game
* `haskell_package`: The name of Haskell package. This is the name you would 
   see when you run `ghc-pkg list` (actually `arm-unknown-linux-androideabi-ghc-pkg list`).
* `title`: The title of the game. This is the text you will see below the icon for the
   game once it's installed on your Android device.
* `package`: The name of the app package. Should be a unique full qualified domain name (FQDN)
   e.g. `com.test.game.epidemic`
* `version`: A JSON value containing two sub-values
   - `code`: a numeric value
   - `name`: a free text string for the build name
   These versions are important for when you are trying to release games on the
   Google Play app store. The "code" must be incremented each time.
* `build_type`: Can be either `"debug"` or `"release"`. Use `"debug"` for 
   now since releases must be signed with certificates.
* `orientation`: Screen orientation of game. Can be either `"landscape"` or `"portrait"`
* `assets_dir`: Full path to a directory containing assets for the game.
* `icons_dir`: Full path to a directory containing sub-directories containing icons
   This directory must contain at least one of `drawable-hdpi`, `drawable-mdpi`,
   `drawable-xhdpi` or `drawable-xxhdpi` and these directories must contain an
   image called `ic_launcher.png`. These are the various icons for the installed
   app.

A completed `config.json` file is below. (This one is for
[Epidemic](https://github.com/sseefried/open-epidemic-game)).

    { "repo": "/home/androidbuilder/host-code/open-epidemic-game",
      "haskell_package": "Epidemic",
      "title": "Epidemic",
      "package": "com.test.game.epidemic",
      "version": { "code": "1", "name": "Build 1" },
      "build_type": "debug",
      "orientation": "landscape",
      "assets_dir": "/home/androidbuilder/host-code/open-epidemic-game/assets",
      "icons_dir": "/home/androidbuilder/host-code/open-epidemic-game/android-icons"
    }

## Build

Now you can build it, inside the running Docker container, with: 

    $ ./build-game-apk.sh


## Installing the APK on Android devices

Once you have run the build script you should find the file in `bin/<package>-debug.apk`

You can install this file on your Android device with [`adb`](http://developer.android.com/tools/help/adb.html).

    $ adb install -r <package>.apk

You must do this from the host machine not the running Docker container.
See instructions in
[docker-build-game-env](https://github.com/sseefried/docker-build-game-env)
for more information.

#!/bin/sh -l

PLATFORM=$1
KEY=$2
SCONS_FLAGS=warnings=no progress=no productions=yes profile=custom.py build_feature_profile=feature_profile.build
SCONS_CACHE=/github/workspace/.scons-cache/
BIN_DIR=/github/workspace/bin

echo Building $PLATFORM

cd godot-4.0

mkdir -p $BIN_DIR
mkdir -p $SCONS_CACHE

export SCONS_CACHE=$SCONS_CACHE
if [ ${#KEY} -ge 5 ]; then
  export SCRIPT_AES256_ENCRYPTION_KEY=$KEY
fi

if [ "$PLATFORM" == "windows" ]; then
  scons platform=windows ${SCONS_FLAGS} arch=x86_64 use_mingw=yes target=template_releasev
  
  mv bin/godot.windows.template_release.x86_64.exe $BIN_DIR/windows_release_x86_64.exe
  mv bin/godot.windows.template_release.x86_64.console.exe $BIN_DIR/windows_release_x86_64_console.exe
  
  #scons platform=windows ${SCONS_FLAGS} arch=x86_64 use_mingw=yes target=template_debug
  #mv bin/godot.windows.template_debug.x86_64.exe $BIN_DIR/windows_debug_x86_64.exe
  #mv bin/godot.windows.template_debug.x86_64.console.exe $BIN_DIR/windows_debug_x86_64_console.exe
  
  strip $BIN_DIR/windows*.exe
  
elif [ "$PLATFORM" == "linuxbsd" ]; then
  scons platform=linuxbsd ${SCONS_FLAGS} arch=x86_64 target=template_release
  scons platform=linuxbsd ${SCONS_FLAGS} arch=x86_64 target=template_debug
  
  mv bin/godot.linuxbsd.template_release.x86_64 $BIN_DIR/linux_release.x86_64
  mv bin/godot.linuxbsd.template_debug.x86_64 $BIN_DIR/linux_debug.x86_64
  
  strip $BIN_DIR/linux*
  
elif [ "$PLATFORM" == "web" ]; then
  scons platform=web ${SCONS_FLAGS} optimize=size target=template_release
  scons platform=web ${SCONS_FLAGS} optimize=size target=template_release dlink_enabled=yes
  scons platform=web ${SCONS_FLAGS} optimize=size target=template_debug
  scons platform=web ${SCONS_FLAGS} optimize=size target=template_debug dlink_enabled=yes

  mv bin/godot.web.template_release.wasm32.zip $BIN_DIR/web_release.zip
  mv bin/godot.web.template_debug.wasm32.zip $BIN_DIR/web_debug.zip

  mv bin/godot.web.template_release.wasm32.dlink.zip $BIN_DIR/web_dlink_release.zip
  mv bin/godot.web.template_debug.wasm32.dlink.zip $BIN_DIR/web_dlink_debug.zip
  
elif [ "$PLATFORM" == "android" ]; then
  scons platform=android ${SCONS_FLAGS} target=template_release arch=arm32
  scons platform=android ${SCONS_FLAGS} target=template_release arch=arm64
  scons platform=android ${SCONS_FLAGS} target=template_release arch=x86_32
  scons platform=android ${SCONS_FLAGS} target=template_release arch=x86_64
  scons platform=android ${SCONS_FLAGS} target=template_debug arch=arm32
  scons platform=android ${SCONS_FLAGS} target=template_debug arch=arm64
  scons platform=android ${SCONS_FLAGS} target=template_debug arch=x86_32
  scons platform=android ${SCONS_FLAGS} target=template_debug arch=x86_64 

  pushd platform/android/java
  ./gradlew generateGodotTemplates
  popd

  mv bin/android_source.zip $BIN_DIR/
  mv bin/android_debug.apk $BIN_DIR/
  mv bin/android_release.apk $BIN_DIR/
  mv bin/godot-lib.template_release.aar $BIN_DIR/
else
  echo hmm
fi

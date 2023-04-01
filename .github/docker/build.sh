#!/bin/sh -l

KEY=$1
SCONS_FLAGS=productions=yes lto=full profile=custom.py build_feature_profile=feature_profile.build 
BIN_DIR=/godot/templates

export SCONS_CACHE=/godot/.scons-cache
if [ ${#KEY} -ge 1 ]; then
  export SCRIPT_AES256_ENCRYPTION_KEY=$KEY
fi

cd /godot/source
  
if [ "$PLATFORM" == "windows" ]; then
  scons platform=windows arch=x86_64 productions=yes lto=full use_mingw=yes $SCONS_FLAGS target=template_release
  scons platform=windows arch=x86_64 use_mingw=yes $SCONS_FLAGS target=template_debug
  
  mv bin/godot.windows.template_release.x86_64.exe $BIN_DIR/windows_release_x86_64.exe
  mv bin/godot.windows.template_release.x86_64.console.exe $BIN_DIR/windows_release_x86_64_console.exe
  mv bin/godot.windows.template_debug.x86_64.exe $BIN_DIR/windows_debug_x86_64.exe
  mv bin/godot.windows.template_debug.x86_64.console.exe $BIN_DIR/windows_debug_x86_64_console.exe
  
  scons platform=windows arch=x86_32 use_mingw=yes $SCONS_FLAGS target=template_release
  scons platform=windows arch=x86_32 use_mingw=yes $SCONS_FLAGS target=template_debug
  
  mv bin/godot.windows.template_release.x86_32.exe $BIN_DIR/windows_release_x86_32.exe
  mv bin/godot.windows.template_release.x86_32.console.exe $BIN_DIR/windows_release_x86_32_console.exe
  mv bin/godot.windows.template_debug.x86_32.exe $BIN_DIR/windows_debug_x86_32.exe
  mv bin/godot.windows.template_debug.x86_32.console.exe $BIN_DIR/windows_debug_x86_32_console.exe
  
  strip --strip-all $BIN_DIR/windows*.exe
  
elif [ "$PLATFORM" == "linuxbsd" ]; then
  sed -i ${GODOT_SDK_LINUX_X86_64}/x86_64-godot-linux-gnu/sysroot/usr/lib/pkgconfig/dbus-1.pc -e "s@/lib@/lib64@g"
  export PATH="${GODOT_SDK_LINUX_X86_64}/bin:${BASE_PATH}"
  
  scons platform=linuxbsd arch=x86_64 $SCONS_FLAGS target=template_release
  scons platform=linuxbsd arch=x86_64 $SCONS_FLAGS target=template_debug
  
  mv bin/godot.linuxbsd.template_release.x86_64 $BIN_DIR/linux_release.x86_64
  mv bin/godot.linuxbsd.template_debug.x86_64 $BIN_DIR/linux_debug.x86_64
  
  export PATH="${GODOT_SDK_LINUX_X86}/bin:${BASE_PATH}"
  
  scons platform=linuxbsd arch=x86_32 $SCONS_FLAGS target=template_release
  scons platform=linuxbsd arch=x86_32 $SCONS_FLAGS target=template_debug
  
  mv bin/godot.linuxbsd.template_release.x86_32 $BIN_DIR/linux_release.x86_32
  mv bin/godot.linuxbsd.template_debug.x86_32 $BIN_DIR/linux_debug.x86_32
  
  strip --strip-all $BIN_DIR/linux*
  
elif [ "$PLATFORM" == "web" ]; then
  source "/emsdk/emsdk_env.sh"

  scons platform=web optimize=size $SCONS_FLAGS target=template_release
  scons platform=web optimize=size $SCONS_FLAGS target=template_release dlink_enabled=yes
  scons platform=web optimize=size $SCONS_FLAGS target=template_debug
  scons platform=web optimize=size $SCONS_FLAGS target=template_debug dlink_enabled=yes
  
  mv bin/godot.web.template_release.wasm32.zip $BIN_DIR/web_release.zip
  mv bin/godot.web.template_debug.wasm32.zip $BIN_DIR/web_debug.zip
  
  mv bin/godot.web.template_release.wasm32.dlink.zip $BIN_DIR/web_dlink_release.zip
  mv bin/godot.web.template_debug.wasm32.dlink.zip $BIN_DIR/web_dlink_debug.zip
  
elif [ "$PLATFORM" == "android" ]; then
  scons platform=android $SCONS_FLAGS target=template_release arch=arm32
  scons platform=android $SCONS_FLAGS target=template_release arch=arm64
  scons platform=android $SCONS_FLAGS target=template_release arch=x86_32
  scons platform=android $SCONS_FLAGS target=template_release arch=x86_64
  scons platform=android $SCONS_FLAGS target=template_debug arch=arm32
  scons platform=android $SCONS_FLAGS target=template_debug arch=arm64
  scons platform=android $SCONS_FLAGS target=template_debug arch=x86_32
  scons platform=android $SCONS_FLAGS target=template_debug arch=x86_64 
  
  pushd platform/android/java
    ./gradlew generateGodotTemplates
  popd
  
  mv bin/android_source.zip $BIN_DIR/
  mv bin/android_debug.apk $BIN_DIR/
  mv bin/android_release.apk $BIN_DIR/
  #mv bin/godot-lib.template_release.aar $BIN_DIR/
  
elif [ "$PLATFORM" == "osx" ]; then
  # https://github.com/godotengine/godot-build-scripts/blob/main/build-macos/
  ls -la
elif [ "$PLATFORM" == "ios" ]; then
  # https://github.com/godotengine/godot-build-scripts/tree/main/build-ios/
  ls -la
fi

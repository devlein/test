#!/bin/sh -l

PLATFORM=$1
KEY=$2
SCONS_FLAGS=warnings=no progress=no productions=yes profile=custom.py build_feature_profile=feature_profile.build
SCONS_CACHE=/github/workspace/.scons-cache/
BIN_DIR=/github/workspace/bin
export TERM=xterm

echo Building $PLATFORM

cd godot-4.0
rm -rf editor

mkdir -p $BIN_DIR
mkdir -p $SCONS_CACHE

export SCONS_CACHE=$SCONS_CACHE
if [ ${#KEY} -ge 5 ]; then
  export SCRIPT_AES256_ENCRYPTION_KEY=$KEY
fi

if [ "$PLATFORM" == "windows" ]; then
  gcc -v
  ld -v
  python -c "import sys; print(sys.version)"
  scons --version
  scons platform=windows ${SCONS_FLAGS} arch=x86_64 lto=full use_mingw=yes target=template_release
  mv bin/godot.windows.template_release.x86_64.exe $BIN_DIR/windows_release_x86_64.exe
  mv bin/godot.windows.template_release.x86_64.console.exe $BIN_DIR/windows_release_x86_64_console.exe
  
  #scons platform=windows ${SCONS_FLAGS} arch=x86_64 use_mingw=yes target=template_debug
  #mv bin/godot.windows.template_debug.x86_64.exe $BIN_DIR/windows_debug_x86_64.exe
  #mv bin/godot.windows.template_debug.x86_64.console.exe $BIN_DIR/windows_debug_x86_64_console.exe
  
  strip $BIN_DIR/windows*.exe
  
elif [ "$PLATFORM" == "linuxbsd" ]; then
  #sed -i ${GODOT_SDK_LINUX_X86_64}/x86_64-godot-linux-gnu/sysroot/usr/lib/pkgconfig/dbus-1.pc -e "s@/lib@/lib64@g"
  #export PATH="${GODOT_SDK_LINUX_X86_64}/bin:${BASE_PATH}"
  
  scons platform=linuxbsd ${SCONS_FLAGS} arch=x86_64  lto=full target=template_release
  #scons platform=linuxbsd ${SCONS_FLAGS} arch=x86_64 target=template_debug
  
  mv bin/godot.linuxbsd.template_release.x86_64 $BIN_DIR/linux_release.x86_64
  #mv bin/godot.linuxbsd.template_debug.x86_64 $BIN_DIR/linux_debug.x86_64
  ls -la $BIN_DIR
  strip $BIN_DIR/linux*
  ls -la $BIN_DIR
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

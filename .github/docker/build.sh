#!/bin/sh -l

PLATFORM=$1
KEY=$2
SCONS=warnings=no progress=no productions=yes profile=custom.py build_feature_profile=feature_profile.build

echo Building ${PLATFORM}

mkdir -p bin/out
mkdir -p .scons-cache

export SCONS_CACHE=/github/workspace/.scons-cache/
if [ ${#KEY} -ge 5 ]; then
  export SCRIPT_AES256_ENCRYPTION_KEY=$KEY
fi

if [ "$PLATFORM" == "windows" ]; then
  scons platform=windows ${SCONS} arch=x86_64 use_mingw=yes target=template_release
  scons platform=windows ${SCONS} arch=x86_64 use_mingw=yes target=template_debug
  
  mv bin/godot.windows.template_release.x86_64.exe bin/out/windows_release_x86_64.exe
  mv bin/godot.windows.template_debug.x86_64.exe bin/out/windows_debug_x86_64.exe
  mv bin/godot.windows.template_release.x86_64.console.exe bin/out/windows_release_x86_64_console.exe
  mv bin/godot.windows.template_debug.x86_64.console.exe bin/out/windows_debug_x86_64_console.exe
  
  strip bin/windows*.exe
  
elif [ "$PLATFORM" == "linuxbsd" ]; then
  scons platform=linuxbsd ${SCONS} arch=x86_64 target=template_release
  scons platform=linuxbsd ${SCONS} arch=x86_64 target=template_debug
  
  mv bin/godot.linuxbsd.template_release.x86_64 bin/out/linux_release.x86_64
  mv bin/godot.linuxbsd.template_debug.x86_64 bin/out/linux_debug.x86_64
  
  strip bin/linux*
  
elif [ "$PLATFORM" == "web" ]; then
  scons platform=web ${SCONS} optimize=size target=template_release
  scons platform=web ${SCONS} optimize=size target=template_release dlink_enabled=yes
  scons platform=web ${SCONS} optimize=size target=template_debug
  scons platform=web ${SCONS} optimize=size target=template_debug dlink_enabled=yes

  mv bin/godot.web.template_release.wasm32.zip bin/out/web_release.zip
  mv bin/godot.web.template_debug.wasm32.zip bin/out/web_debug.zip

  mv bin/godot.web.template_release.wasm32.dlink.zip bin/out/web_dlink_release.zip
  mv bin/godot.web.template_debug.wasm32.dlink.zip bin/out/web_dlink_debug.zip
  
elif [ "$PLATFORM" == "android" ]; then
  scons platform=android ${SCONS} target=template_release arch=arm32
  scons platform=android ${SCONS} target=template_release arch=arm64
  scons platform=android ${SCONS} target=template_release arch=x86_32
  scons platform=android ${SCONS} target=template_release arch=x86_64
  scons platform=android ${SCONS} target=template_debug arch=arm32
  scons platform=android ${SCONS} target=template_debug arch=arm64
  scons platform=android ${SCONS} target=template_debug arch=x86_32
  scons platform=android ${SCONS} target=template_debug arch=x86_64 

  pushd platform/android/java
  ./gradlew generateGodotTemplates
  popd

  mv bin/android_source.zip bin/out/
  mv bin/android_debug.apk bin/out/
  mv bin/android_release.apk bin/out/
  mv bin/godot-lib.template_release.aar bin/out/
else
  echo hmm
fi

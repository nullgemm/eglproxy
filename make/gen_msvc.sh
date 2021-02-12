#!/bin/bash

# get into the right folder
cd "$(dirname "$0")"
cd ..

# versions
ver_windows=10
ver_windows_sdk=10.0.19041.0
ver_msvc=14.28.29333
ver_visual_studio=2019

# generate makefile
cc="\"/c/Program Files (x86)/Microsoft Visual Studio/\
$ver_visual_studio/BuildTools/VC/Tools/MSVC/\
$ver_msvc/bin/Hostx64/x64/cl.exe\""

lib="\"/c/Program Files (x86)/Microsoft Visual Studio/\
$ver_visual_studio/BuildTools/VC/Tools/MSVC/\
$ver_msvc/bin/Hostx64/x64/lib.exe\""

src+=("src/eglproxy.c")
src+=("src/egl_proc.c")
src+=("src/egl_wgl.c")

flags+=("-Z7 -Zc:inline")

flags+=("-Isrc")
flags+=("-Iinc")

flags+=("-I\"/c/Program Files (x86)/Windows Kits/\
$ver_windows/Include/$ver_windows_sdk/ucrt\"")
flags+=("-I\"/c/Program Files (x86)/Windows Kits/\
$ver_windows/Include/$ver_windows_sdk/um\"")
flags+=("-I\"/c/Program Files (x86)/Windows Kits/\
$ver_windows/Include/$ver_windows_sdk/shared\"")
flags+=("-I\"/c/Program Files (x86)/Microsoft Visual Studio/\
$ver_visual_studio/BuildTools/VC/Tools/MSVC/$ver_msvc/include\"")

defines+=("-DGLOBOX_COMPILER_MSVC")
defines+=("-DUNICODE")
defines+=("-D_UNICODE")
defines+=("-DWINVER=0x0A00")
defines+=("-D_WIN32_WINNT=0x0A00")
defines+=("-DCINTERFACE")
defines+=("-DCOBJMACROS")

ldflags+=("-DEBUG:FULL")
ldflags+=("-LIBPATH:\"/c/Program Files (x86)/Windows Kits/\
$ver_windows/Lib/$ver_windows_sdk/um/x64\"")
ldflags+=("-LIBPATH:\"/c/Program Files (x86)/Microsoft Visual Studio/\
$ver_visual_studio/BuildTools/VC/Tools/MSVC/$ver_msvc/lib/spectre/x64\"")
ldflags+=("-LIBPATH:\"/c/Program Files (x86)/Windows Kits/\
$ver_windows/Lib/$ver_windows_sdk/ucrt/x64\"")

ldlibs+=("Gdi32.lib")
ldlibs+=("User32.lib")
ldlibs+=("opengl32.lib")

makefile=makefile_msvc

make/scripts/egl_get.sh

# create empty makefile
echo ".POSIX:" > $makefile
echo "NAME = eglproxy" >> $makefile

# generate linking info
echo "" >> $makefile
echo "CC = $cc" >> $makefile
echo "LIB = $lib" >> $makefile
echo "LDFLAGS+= ${ldflags[@]}" >> $makefile
echo "LDLIBS+= ${ldlibs[@]}" >> $makefile

# generate compiler flags
echo "" >> $makefile
for file in "${flags[@]}"; do
	echo "CFLAGS+= $file" >> $makefile
done

echo "" >> $makefile
for file in ${defines[@]}; do
	echo "CFLAGS+= $file" >> $makefile
done

# generate object list
echo "" >> $makefile
for file in ${src[@]}; do
	folder=$(dirname "$file")
	name=$(basename "$file" .c)
	echo "OBJ+= $folder/$name.obj" >> $makefile
done

# generate binary targets
echo "" >> $makefile
cat make/templates/targets_msvc.make >> $makefile

# generate object targets
echo "" >> $makefile
for file in ${src[@]}; do
	x86_64-w64-mingw32-gcc $defines -MM -MG $file >> $makefile
done

# .obj auto-target replacement
echo "" >> $makefile
cat make/templates/targets_msvc_obj.make >> $makefile

# generate utilitary targets
echo "" >> $makefile
cat make/templates/targets_extra.make >> $makefile

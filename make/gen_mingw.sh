#!/bin/bash

# get into the right folder
cd "$(dirname "$0")"
cd ..

# generate makefile
cc=x86_64-w64-mingw32-gcc

src+=("src/eglproxy.c")
src+=("src/egl_proc.c")
src+=("src/egl_wgl.c")

flags+=("-std=c99" "-pedantic")
flags+=("-Wall" "-Wextra" "-Werror=vla" "-Werror")
flags+=("-Wno-address-of-packed-member")
flags+=("-Wno-unused-parameter")
flags+=("-Wno-implicit-fallthrough")
flags+=("-Wno-cast-function-type")
flags+=("-Wno-incompatible-pointer-types")

flags+=("-Isrc")
flags+=("-Iinc")

defines+=("-DUNICODE")
defines+=("-D_UNICODE")
defines+=("-DWINVER=0x0A00")
defines+=("-D_WIN32_WINNT=0x0A00")
defines+=("-DCINTERFACE")
defines+=("-DCOBJMACROS")

ldlibs+=("-lgdi32")
ldlibs+=("-lopengl32")

makefile=makefile_mingw

make/scripts/egl_get.sh

# build type
read -p "optimize? ([1] optimize | [2] debug): " optimize

if [ $optimize -eq 1 ]; then
flags+=("-O2")
else
flags+=("-g")
fi

# create empty makefile
echo ".POSIX:" > $makefile
echo "NAME = eglproxy" >> $makefile

# generate linking info
echo "" >> $makefile
echo "CC = $cc" >> $makefile
echo "LDFLAGS+= ${ldflags[@]}" >> $makefile
echo "LDLIBS+= ${ldlibs[@]}" >> $makefile

# generate compiler flags
echo "" >> $makefile
for file in ${flags[@]}; do
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
	echo "OBJ+= $folder/$name.o" >> $makefile
done

echo "" >> $makefile
cat make/templates/targets_mingw.make >> $makefile

# generate object targets
echo "" >> $makefile
for file in ${src[@]}; do
	$cc $defines -MM -MG $file >> $makefile
done

# generate utilitary targets
echo "" >> $makefile
cat make/templates/targets_extra.make >> $makefile

#!/usr/bin/env bash
basedir=$(dirname "$(realpath "$0")")
cd "${basedir}"

# install prerequisites:
# sudo apt-get install libglvnd-dev libx11-dev
# sudo dnf install libglvnd-devel libX11-devel

baseurl="https://gitlab.freedesktop.org/mesa/demos/-/raw/e307f4faff491d36aed1e513d4e1ad58e85e57a3/src"

CC=gcc
STRIP=strip
OBJDUMP=objdump

set -e
set -x

if [ ! -f gears_colors.c ];then curl -fsSLo "gears_colors.c" "${baseurl}/util/gears_colors.c?inline=false";fi
if [ ! -f gears_colors.h ];then curl -fsSLo "gears_colors.h" "${baseurl}/util/gears_colors.h?inline=false";fi
if [ ! -f glxgears.c ];then curl -fsSLo "glxgears.c" "${baseurl}/xdemos/glxgears.c?inline=false";fi

for out in gears-colors-rainbow gears-colors glxgears-rainbow glxgears;do
    if [ -f $out ];then rm -f $out;fi
    if [[ $out == *-rainbow ]];then
        CFLAGS="-DUSE_RAINBOW_GEARS_COLORS"
        src="${out%-*}"
    else
        CFLAGS=""
        src="$out"
    fi
    if [[ $out == glxgears* ]];then
        LIBS="-lpthread -lGLX -lX11 -lGL -lm"
    else
        LIBS=""
    fi
    src="${src//-/_}.c"
    #echo "src=$src"
    $CC $CFLAGS -o $out $src $LIBS
    $STRIP $out
    file $out
    $OBJDUMP -p $out|grep NEEDED
done

#gcc -DUSE_RAINBOW_GEARS_COLORS -o gears-colors-rainbow gears_colors.c
#gcc -o gears-colors gears_colors.c
#gcc -DUSE_RAINBOW_GEARS_COLORS -o glxgears-rainbow glxgears.c -lpthread -lGLX -lX11 -lGL -lm
#gcc -o glxgears glxgears.c -lpthread -lGLX -lX11 -lGL -lm

#for file in gears-colors-rainbow gears-colors glxgears-rainbow glxgears;do
#    strip $file
#done

#for file in gears-colors-rainbow gears-colors glxgears-rainbow glxgears;do
#    file $file;objdump -p $file|grep NEEDED
#done

exit

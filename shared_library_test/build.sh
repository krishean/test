#!/usr/bin/env bash
basedir=$(dirname "$(realpath "$0")")
cd "${basedir}"

# remove build files
find . ! -type d -and ! -iname '*.c' -and ! -iname '*.h' -and ! -iname '*.sh' -exec rm -f {} \;

# https://www.cprogramming.com/tutorial/shared-libraries-linux-gcc.html

# compile normally with gcc
gcc -c -Wall -Werror -fpic hello.c
gcc -shared -o libhello.so hello.o
gcc -L$(pwd) -Wall -o test main.c -lhello

# show file info and linked libraries
file test
objdump -p test | grep NEEDED

# run gcc version
LD_LIBRARY_PATH=$(pwd) ./test

echo ""

# remove build files
find . ! -type d -and ! -iname '*.c' -and ! -iname '*.h' -and ! -iname '*.sh' -exec rm -f {} \;

# compile with libtool
libtool --mode=compile gcc -g -O -c hello.c
libtool --mode=compile gcc -g -O -c main.c
libtool --mode=link gcc -g -O -o libhello.la hello.lo -rpath /tmp
libtool --mode=link gcc -g -O -o test main.lo -lhello

echo ""

# show libtool version file info and linked libraries
file .libs/test
objdump -p .libs/test | grep NEEDED

# run libtool version of test
LD_LIBRARY_PATH=$(pwd)/.libs ./.libs/test

echo ""

exit

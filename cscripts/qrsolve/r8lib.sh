#! /bin/bash
#
cp r8lib.h ./include
#
gcc -c -Wall -I./include r8lib.c
if [ $? -ne 0 ]; then
  echo "Compile error."
  exit
fi
#
mv r8lib.o ./libc/r8lib.o
#
echo "Normal end of execution."

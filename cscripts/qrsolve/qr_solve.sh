#! /bin/bash
#
cp qr_solve.h ./include
#
gcc -c -Wall -I ./include qr_solve.c
if [ $? -ne 0 ]; then
  echo "Compile error."
  exit
fi
#
mv qr_solve.o ./libc/qr_solve.o
#
echo "Normal end of execution."

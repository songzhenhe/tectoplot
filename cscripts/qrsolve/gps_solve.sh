#! /bin/bash
#
gcc -c -Wall -I./include gps_solve.c
if [ $? -ne 0 ]; then
  echo "Compile error."
  exit
fi
#
gcc gps_solve.o ./libc/qr_solve.o \
                   ./libc/test_lls.o  \
                   ./libc/r8lib.o -lm
if [ $? -ne 0 ]; then
  echo "Load error."
  exit
fi
#
rm gps_solve.o
#
mv a.out gps_solve


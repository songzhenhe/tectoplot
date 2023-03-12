#! /bin/bash
#
gcc -c -Wall -I./include qr_solve_test.c
if [ $? -ne 0 ]; then
  echo "Compile error."
  exit
fi
#
gcc qr_solve_test.o ./libc/qr_solve.o \
                   ./libc/test_lls.o  \
                   ./libc/r8lib.o -lm
if [ $? -ne 0 ]; then
  echo "Load error."
  exit
fi
#
rm qr_solve_test.o
#
mv a.out qr_solve_test
./qr_solve_test > qr_solve_test.txt
if [ $? -ne 0 ]; then
  echo "Run error."
  exit
fi
# rm qr_solve_test
#
echo "Normal end of execution."

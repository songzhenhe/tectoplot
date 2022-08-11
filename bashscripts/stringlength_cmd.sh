#!/usr/bin/env bash

# Takes as arguments a font name, font size, and any number of input strings
# and returns the length of each string in cm
LETTERDATA="/Users/kylebradley/Dropbox/blender/globe/lettersizes.txt"

THIS_FONT=$1
shift
THIS_FONTSIZE=$1
shift
THIS_STRING="${@}"

rm -f stringlength.txt
while [[ $# -gt 0 ]]; do
  echo $1 >> stringlength.txt
  shift
done

gawk -F'\t' -v font=${THIS_FONT} -v fontsize=${THIS_FONTSIZE} '
 BEGIN {
   fontcol=0
 }
 (NR == FNR) {
   if (NR == 1) {
     for(i=2; i<=NF; ++i) {
       if ($(i) == font) {
         fontcol=i
       }
     }
     if (fontcol == 0) {
       print "Font", font, "not found in letter size file" > "/dev/stderr"
       exit
     }
   } else {
     fsize[$1] = $(fontcol)
   }
 }
 (NR != FNR) {
   totallength=0
   for(i=1;i<=length($0);++i) {
     letter=substr($0,i,1)
     # print "letter", letter, "has size", fsize[letter] > "/dev/stderr"
     totallength+=fsize[letter]
   }
   print totallength*fontsize
 }
 END {
   # for (key in fsize) {
   #   print key, fsize[key]
   # }
 }
 ' ${LETTERDATA} stringlength.txt

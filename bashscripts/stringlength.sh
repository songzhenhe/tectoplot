#!/usr/bin/env bash

# Takes as arguments a font name, font size, and a file in OGR GMT format that
# contains point data following header lines of the format > -L"Label text"
# or -LSingleLabel. Outputs the file with an additional field in the header


THIS_FONT=$1
shift
THIS_FONTSIZE=$1
shift
THIS_FILE=$1
shift
LETTERDATA=$1
shift

#
# rm -f stringlength.txt
# while [[ $# -gt 0 ]]; do
#   echo $1 >> stringlength.txt
#   shift
# done

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

   # If we find a header line
   if (substr($0,0,1) == ">") {
     # If the has quotation marks surrounding, remove them
     thislabel=substr($0,5,length($0)-1)
     if (substr(thislabel, 1, 1) == "\"") {
       thislabel=substr(thislabel, 2, length(thislabel)-1)
     }
     # Now add up the total length of the label
     for(i=1;i<=length(thislabel);++i) {
       letter=substr(thislabel,i,1)
       # print "letter", letter, "has size", fsize[letter] > "/dev/stderr"
       totallength+=fsize[letter]
     }
     print $0, totallength*fontsize
   } else {
     # Otherwise, print data lines directly
     print
   }
 }
 END {
   # for (key in fsize) {
   #   print key, fsize[key]
   # }
 }
 ' ${LETTERDATA} ${THIS_FILE}

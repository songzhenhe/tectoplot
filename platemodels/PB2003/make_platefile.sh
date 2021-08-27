#!/bin/bash

# Note: To fix the PB plates, I had to manually edit the platesref.gmt file generate by plate_fixer.sh
# in order to have the NA and AN plates extend to include the poles. Then I ran the final commands of
# plate_fixer.sh again to generate the output plate file. Yay.

RS='\r\n' gawk < PB2002_poles.dat.txt '
  {
    sub(/\r/,"")
    print($1, $2, $3, $4)
  }
' > PB2003_poles.txt

gawk < PB2002_plates.dig.txt -F, '
  BEGIN {
    off=0
  }
  {
    sub(/\r/,"")
    if (substr($0,1,1)!=" " && substr($0,1,1)!="*") {
      if (substr($0,1,2) == "9a" || substr($0,1,2) == "99") {
        off=1
      } else {
        off=0
      }
      if (off==0) {
        printf("> %s\n", $1)
      }
    }
    if (substr($0,1,1)==" ") {
      if (off==0) {
        printf("%.02f %.02f\n", $1, $2)
      }
    }
  }' > PB2003_boundaries.txt

#!/usr/bin/env bash

GMTFonts=(
  "Helvetica"
  "Helvetica-Bold"
)

if [[ ${#@} -gt 0 ]]; then
  inputstring="${@}"
else
  inputstring="This is a test string"
fi

# Initial findings are that we can estimate the scaling of text by multiplying the
# scale at font size = 1 by the font size. So we only need to compile the width
# of each character for font size = 1

# GMT letter width table
FONT="AvantGarde-Book"

FONTSIZE=12
# alphabet="A"
alphabet="!#\$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_\`abcdefghijklmnopqrstuvwxyz{|}~ "

for FONTSIZE in $(seq 1 1); do

  letterfile=$(printf "letters_${FONT}_%03d.txt" ${FONTSIZE})
  echo letterfile is $letterfile

  if [[ ! -s ${letterfile} ]]; then
    echo "Generating text sizes for ${FONT} at ${FONTSIZE}p"
    for (( i=0; i<${#alphabet}; i++ )); do
      letter=${alphabet:$i:1}

cat <<-EOF > letter.txt
>-L"${letter}${letter}${letter}${letter}${letter}${letter}"
0 0
1 0
EOF
      gmt psxy letter.txt -P -Sqn1:+Lh+f${FONTSIZE}p,${FONT}+i+v+c0+gred -R-2/2/-2/2 -JQ0/5i > map_${i}_${FONTSIZE}.ps
ls -l map_${i}_${FONTSIZE}.ps

      if [[ ${letter} == "\\" || ${letter} == "\@" ]]; then
        numletters=3
      else
        numletters=6
      fi
      echo $(gmt psconvert map_${i}_${FONTSIZE}.ps -A+m0i -Tef -V 2>&1 | grep "Width" | gawk '{print substr($8,2,length($8)-1), "/'${numletters}'" }' | bc -l) >> ${letterfile}

    done
  fi

  echo $inputstring > line.txt

cat <<-EOF > input.txt
>-L"$inputstring"
-10 0
10 0
EOF

  gmt psxy input.txt -P -Sqn1:+Lh+f${FONTSIZE}p,${FONT}+i+v+c0+gred -R-20/20/-20/20 -JQ0/5i > map2.ps
  echo "input.txt length is" $(gmt psconvert map2.ps -A+m0i -Tef -V 2>&1 | grep "Width" | gawk '{print substr($8,2,length($8)-1) }' | bc -l)

  gawk '
    (NR==FNR) {
      if (substr($0,1,1) == " ") {
        letter=" "
        size[letter]=$1
      } else {
        size[$1]=$2
      }
    }
    (NR!=FNR) {
      totallength=0
      for(i=1;i<=length($0);++i) {
        letter=substr($0,i,1)
        # print "letter", letter, "has size", size[letter] > "/dev/stderr"
        totallength+=size[letter]
      }
      print totallength
    }' ${letterfile} line.txt
done # iterate over font sizes

#!/usr/bin/env bash

# Create a text file containing the width, in centimeters, contributed by each
# ASCII letter for each of the GMT default fonts. When added together, these
# widths closely approximate the width of a 1p text string, which can be
# scaled directly by multiplying by the font size.

# This approach assumes plotting of text over lines using gmt psxy

# Output is lettersizes.txt. The first column contains the letter. A header
# line gives the font for each data column.

GMTFONTS=(
"AvantGarde-Book"
"Helvetica"
"Helvetica-Bold"
"Helvetica-Bold"
"Helvetica-Oblique"
"Helvetica-BoldOblique"
"Times-Roman"
"Times-Bold"
"Times-Italic"
"Times-Boldltalic"
"Courier"
"Courier-Bold"
"Courier-Oblique"
"Courier-Boldoblique"
"Symbol"
"AvantGarde-Book"
"AvantGarde-BookOblique"
"AvantGarde-Demi"
"AvantGarde-DemiOblique"
"Bookman-Demi"
"Bookman-Demiltalic"
"Bookman-Light"
"Bookman-LightItalic"
"Helvetica-Narrow"
"Helvetica-Narrow-Bold"
"Helvetica-Narrow-Oblique"
"Helvetica-Narrow-BoldOblique"
"NewCenturySchlbk-Roman"
"NewCenturySchlbk-Italic"
"NewCenturySchlbk-Bold"
"NewCenturySchlbk-BoldItalic"
"Palatino-Roman"
"Palatino-Italic"
"Palatino-Bold"
"Palatino-Boldltalic"
"ZapfChancery-MediumItalic"
"ZapfDingbats"
)

# Initial findings are that we can estimate the scaling of text by multiplying the
# scale at font size = 1 by the font size. So we only need to compile the width
# of each character for font size = 1

FONTSIZE=1

alphabet="!#\$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_\`abcdefghijklmnopqrstuvwxyz{|}~ "

if [[ ! -s letterlist.txt ]]; then
  echo "letter" > letterlist.txt
  for (( i=0; i<${#alphabet}; i++ )); do
    letter=${alphabet:$i:1}
    echo "${letter}" >> letterlist.txt
  done
fi

for FONT in ${GMTFONTS[@]}; do

  letterfile=$(printf "letters_${FONT}_%03d.txt" ${FONTSIZE})

  if [[ ! -s ${letterfile} ]]; then
    echo "Generating text sizes for ${FONT} at ${FONTSIZE}p"
    echo ${FONT} > ${letterfile}
    for (( i=0; i<${#alphabet}; i++ )); do
      letter=${alphabet:$i:1}

cat <<-EOF > letter.txt
>-L"${letter}${letter}${letter}${letter}${letter}${letter}"
0 0
1 0
EOF
      gmt psxy letter.txt -P -Sqn1:+Lh+f${FONTSIZE}p,${FONT}+i+v+c0+gred -R-2/2/-2/2 -JQ0/5i > map_${i}_${FONT}.ps
ls -l map_${i}_${FONT}.ps

      if [[ ${letter} == "\\" || ${letter} == "\@" ]]; then
        numletters=3
      else
        numletters=6
      fi
      echo $(gmt psconvert map_${i}_${FONT}.ps -A+m0i -Tef -V 2>&1 | grep "Width" | gawk '{print substr($8,2,length($8)-1), "/'${numletters}'" }' | bc -l) >> ${letterfile}

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
done # iterate over fonts

paste letterlist.txt letters_*.txt > lettersizes.txt

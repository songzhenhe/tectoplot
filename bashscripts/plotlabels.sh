
# Script to plot text labels on a GMT map while trying to avoid overlaps and
# also keeping labels entirely within the map frame.

# Usage: source plotlabels

# These following variable must be set prior to sourcing this script:

# RJSTRING[@] contains the -R and -J GMT region and projection string

# LABEL_FILE points to an input label file in the format:
# lon lat font rotation justification text comprising label text
# 154.034	-8.42	10p,Helvetica,black	0	BL	usp00008hm(7.2)

# LABEL_DIST is a distance in units of inches (e.g. 0.1i)

# MAP_PS_WIDTH_NOLABELS_IN
# MAP_PS_HEIGHT_NOLABELS_IN
# These variables contain the width and height of the map area in inches

# LABEL_FONTSIZE is a font size e.g. 10p
# LABEL_BOXLINE is a line width and color e.g. 0.5p,black

# LABEL_PSFILE
# The output PS file

# Calculate from the input variables
LABEL_DIST_P=$(echo "${EQ_LABEL_DISTX}" | gawk '{print ($1+0)*72}')
LABEL_FONTSIZE_P=$(echo ${LABEL_FONTSIZE} | gawk '{print $1+0}')
LABEL_DIST_2=$(echo "${LABEL_DIST}" | gawk '{print ($1+0)*1.5 "i"}')
LABEL_WIDTH_P=$(echo "${MAP_PS_WIDTH_NOLABELS_IN} * 72" | bc -l)
LABEL_HEIGHT_P=$(echo "${MAP_PS_HEIGHT_NOLABELS_IN} * 72" | bc -l)
if [[ $LABEL_BOXLINE != "" ]]; then
  LABEL_BOXLINE_DEF="-W${LABEL_BOXLINE}"
fi
if [[ $LABEL_BOXCOLOR != "" ]]; then
  LABEL_BOXCOLOR_DEF="-G${LABEL_BOXCOLOR}"
fi

if [[ $shiftlabelsflag -eq 1 ]]; then


  gmt mapproject ${LABEL_FILE} ${RJSTRING[@]} -Dp -i0,1 | gawk 'BEGIN{OFS="\t"} { print $1, $2 }' > labels.xy
  paste labels.xy ${LABEL_FILE} > labels.combined

  python ${SHIFTLABELS} labels.combined ${LABEL_WIDTH_P} ${LABEL_HEIGHT_P} ${LABEL_DIST_P} ${LABEL_FONTSIZE_P}

  # uniq -u ${F_SEIS}eq.labels | gmt pstext -DJ${EQ_LABEL_DISTX}/${EQ_LABEL_DISTY}+v0.7p,black -Gred  -F+f+a+j -W0.5p,black $RJOK $VERBOSE >> map.ps

  gawk < newlabels.txt -v fontsize=${LABEL_FONTSIZE_P} '
    BEGIN {
      IFS="\t"
      OFS="\t"
    }
    {
      id=$1
      outstring=$2
      shadowoutstring=$2
      for(i=3; i<=NF; i++) {
        outstring=sprintf("%s\t%s", outstring, $(i))
        shadowoutstring=sprintf("%s\t%s", shadowoutstring, (i==4)? $(i) "=~" fontsize/20 ",white":$(i))

      }
      print outstring >> "newlabels_" id ".txt"
      print shadowoutstring >> "newlabels_shadow_" id ".txt"
    }
  '

  # Plot the labels
  if [[ -s newlabels_1.txt ]]; then
    uniq -u newlabels_shadow_1.txt | gmt pstext -Dj${LABEL_DIST}+v0.7p,black ${LABEL_BOXCOLOR_DEF} -F+f+a+j ${LABEL_BOXLINE_DEF} $RJOK $VERBOSE >> ${LABEL_PSFILE}
  fi
  if [[ -s newlabels_2.txt ]]; then
    uniq -u newlabels_shadow_2.txt | gmt pstext -Dj${LABEL_DIST_2}/${LABEL_DIST_2}+v0.7p,black ${LABEL_BOXCOLOR_DEF} -F+f+a+j ${LABEL_BOXLINE_DEF} $RJOK $VERBOSE >> ${LABEL_PSFILE}
  fi
else
  uniq -u ${LABEL_FILE} | gmt pstext -DJ${LABEL_DIST}+v0.7p,black ${LABEL_BOXCOLOR_DEF} -F+f+a+j ${LABEL_BOXLINE_DEF} $RJOK $VERBOSE >> ${LABEL_PSFILE}
fi

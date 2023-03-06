
TECTOPLOT_MODULES+=("labels")

# UPDATED
# NEW OPTS

function tectoplot_defaults_labels() {
  MODULE_LABEL_PLOTLINE="+i"  # +i option suppresses line plotting
}

function tectoplot_args_labels()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

    -labels)
  tectoplot_get_opts_inline '
des -label plot labels along paths
req m_label_file file
  input file containing lines and label text
opt font m_label_font string "Helvetica"
  GMT builtin font name
opt color m_label_fontcolor string "black"
  fill color
opt maxsize m_label_maxsize float 12
  font size larger than this will be set to this
opt minsize m_label_minsize float 3
  text with font smaller than this will not plot
opt setsize m_label_setsize float 0
  try to plot all labels at set font size
opt outline m_label_outline float 0
  outline proportion of character size
opt outlinecolor m_label_outlinecolor string "white"
  outline color
opt trans m_label_trans float 0
  label text transparency
opt case m_label_case string "none"
  change case of label text ( upper | lower | title | none )
opt maxspace m_label_maxspace float 4
  maximum number of spaces to add to texopt t
opt line m_label_plotline flag 0
  plot the path line along with the each string
mes GMT fonts
mes
mes SERIF FONTS
mes --------------------------------------------------------------------------------
mes Bookman-Demi  Bookman-Demiltalic  Bookman-Light  Bookman-LightItalic
mes NewCenturySchlbk-Roman  NewCenturySchlbk-Italic  NewCenturySchlbk-Bold
mes    NewCenturySchlbk-BoldItalic
mes Palatino-Roman Palatino-Italic Palatino-Bold Palatino-Boldltalic
mes Symbol
mes Times-Roman  Times-Bold  Times-Italic  Times-Boldltalic
mes ZapfChancery-MediumItalic
mes
mes SANS SERIF FONTS
mes --------------------------------------------------------------------------------
mes AvantGarde-Book  AvantGarde-BookOblique  AvantGarde-Demi  AvantGarde-DemiOblique
mes Courier  Courier-Bold  Courier-Oblique  Courier-Boldoblique
mes Helvetica  Helvetica-Bold  Helvetica-Oblique  Helvetica-BoldOblique
mes Helvetica-Narrow  Helvetica-Narrow-Bold  Helvetica-Narrow-Oblique
mes    Helvetica-Narrow-BoldOblique
mes ZapfDingbats
mes
mes This module can be called multiple times with different options to plot multiple
mes types of labels with different symbologies
exa tectoplot -r FR -gsrm -a
' "${@}" || return

  # Set the default values

  plots+=("labels")
  ;;

  esac
}

# function tectoplot_calculate_labels()  {
#
# }

# function tectoplot_cpt_labels() {
#   case $1 in
#   labels)
#     tectoplot_cpt_caught=1
#     ;;
#   esac
# }

function tectoplot_plot_labels() {
  case $1 in
    labels)
      info_msg "Plotting labels from ${m_label_file[$tt]} with these options: font ${m_label_font[$tt]} color ${m_label_fontcolor[$tt]} maxsize ${m_label_maxsize[$tt]]} minsize ${m_label_minsize[$tt]} trans ${m_label_trans[$tt]} outline ${m_label_outline[$tt]} maxspace ${m_label_maxspace[$tt]}"

      if [[ ${m_label_setsize[$tt]} -ne 0 ]]; then
        m_label_maxsize[$tt]=${m_label_setsize[$tt]}
        m_label_minsize[$tt]=${m_label_setsize[$tt]}
      fi

      m_label_textfont=${m_label_font[$tt]},${m_label_fontcolor[$tt]}

      rm -f TextLabels.gmt
      # Convert KML paths to GMT OGR format
      ogr2ogr -f "OGR_GMT" TextLabels.gmt ${m_label_file[$tt]}

      # Parse the KML file to extract the paths and labels
      gawk < TextLabels.gmt '
        ($1==">") {
          # skip lines starting with a >
        }
        # Extract the @D values which are the quoted labels followed by a |
        # The problem is to get the string either between the first two quotes
        # or between the D and the first | character

# @D"continental plateau"||||||1|0|-1||        @
# @Dslope||||||1|0|-1||

        (substr($0,0,4) == "# @D") {
            if (substr($0,5,1) == "\"") {
              split($0,a,"\"")
              out=a[2]
            } else {
              split($0,a,"|")
              out=substr(a[1],5,length(a[1])-4)
            }
            print "> -L\""  out "\""
        }
        # Print the longitude and latitude values with an increment used for splining
        ($1+0==$1) {
          # print $1, $2, incr++
          print
        }' > data_pre.txt

      # Clip the input lines to the AOI
      gmt spatial data_pre.txt -Fl -T -R | gawk '
      {
        if ($1+0==$1) {
          print $1, $2, incr++
        } else {
          print
        }
      }'> data_clipped.txt

      # Should I separate the paths with only two points to ensure they are not smoothed?
      case ${m_label_caseflag[$tt]} in
        upper)
          tr '[:lower:]' '[:upper:]' < data_clipped.txt > tmp.txt
          mv tmp.txt data_clipped.txt
        ;;
        lower)
          tr '[:upper:]' '[:lower:]' < data_clipped.txt > tmp.txt
          mv tmp.txt data_clipped.txt
        ;;
        title)
          gawk < data_clipped.txt '{
              for(j=1;j<=NF;j++) {
                if (toupper($j)=="THE") {
                  if (j==1) {
                    $j="The"   # First word stays capitalized
                  } else {
                    $j="the"
                  }
                } else if (toupper($j)=="OF") {
                  $j="of"
                } else {
                  $j=toupper(substr($j,1,1)) tolower(substr($j,2))
                }
              }
              print
            }' > tmp.txt
          mv tmp.txt data_clipped.txt
        ;;
      esac

      # Resample the paths using the 'time' increment to smooth them out
      gmt sample1d data_clipped.txt -Fc -T2 -I0.1 > data_resampled.txt

      # Calculate the lengths of the paths in map coordinates (centimeters)
      gmt mapproject data_clipped.txt -i0,1 -G+uC+a -R -J  > data_proj_dist.txt

      # Calculate the lengths of the labels for fontsize 1
      ${BASHSCRIPTDIR}stringlength.sh ${m_label_font[$tt]} 1 data_proj_dist.txt ${BASHSCRIPTDIR}lettersizes.txt > data_proj_dist_labelcalc.txt

      #gmt mapproject data_pre.txt -i0,1 -G+ud+a > data_dist.txt

      # We can adjust the font size, which makes letters taller and wider, and we
      # can add spaces between letters, which makes the label wider only.

      # Input files are the data_proj_dist.txt containing GMT and calculated widths
      # and the resampled data file containing the same labels in the same order

      shopt -s nullglob
      rm -f text*.gmt

      gawk -v maxfontsize=${m_label_maxsize[$tt]} -v maxspacing=${m_label_maxspace[$tt]} '
        function max(a,b) { return (a>b)?a:b }
        function min(a,b) { return (a<b)?a:b }
        function rd(n, multipleOf)
        {
          if (n % multipleOf == 0) {
            num = n
          } else {
             if (n > 0) {
                num = n - n % multipleOf;
             } else {
                num = n + (-multipleOf - n % multipleOf);
             }
          }
          return num
        }
        BEGIN {
          changesize=1
          minfontsize=1
        }
        (NR==FNR) {
         if ($1+0==$1) {
            current_dist=$3
         }

         # When we hit a header, we immediately read the calculated cm distance
         # and then assign the GMT path length for the previous label header
         if (substr($0,0,1)==">") {
            # Assign and increment curnum (dist[0] will be 0)
            dist[curnum++]=current_dist
            # The calculated cm distance is the last field of the header
            calcdist[curnum]=$(NF)
         }
        }
        (NR != FNR) {
          if (doneend==0) {
            dist[curnum]=current_dist
            doneend=1
            curout=1
          }
          # Process a label
          if (substr($0,0,1) == ">") {
            thisdistance=dist[curout]
            thiscalcdist=calcdist[curout++]
            thislabel=substr($0,5,length($0)-1)
            textlength=length($0)-6

            # print "For label:", thislabel, "GMT dist is", thisdistance, "and width at fontsize=1 is", thiscalcdist, "and at max font size", maxfontsize, "is", maxfontsize*thiscalcdist > "/dev/stderr"

            # fontsize_t is the font size that should fill the line almost completely
            fontsize_t = thisdistance/thiscalcdist*0.9

            # lenbiggest is the length of the label at the maximum font size
            lenatbiggest=thiscalcdist*maxfontsize
            # print "lenatbiggest is", lenatbiggest > "/dev/stderr"

            if (substr(thislabel, 1, 1) != "\"") {
              thislabel=sprintf("\"%s\"", thislabel)
            }
            reducefont=0
            spacing=0
            if (changesize==1 && fontsize_t > maxfontsize) {
              fontsize_t = maxfontsize
              origlength=length(thislabel)

              while (spacing < maxspacing) {
                  j=1
                  textlength=0
                  newlabel=""
                  spacing++
                  for (i=1;i<=length(thislabel);i++) {
                    # Do not add spaces before or after a quotation mark or a space
                    if (substr(thislabel, i, 1) == "\"" || substr(thislabel, i+1, 1) == "\"") {
                      newlabel=sprintf("%s%s", newlabel, substr(thislabel, i, 1))
                      textlength++
                    } else {
                      # Add n spaces after each character where n=spacing
                      newlabel=sprintf("%s%s", newlabel, substr(thislabel, i, 1))
                      textlength+=1
                      for (k=1;k<=spacing;k++) {
                        newlabel=sprintf("%s ", newlabel)
                        textlength+=1
                      }
                    }
                  }
                  #           (number_spaces*0.01+thiscalcdist)*fontsize
                  newcalcdist=((textlength-origlength)*0.01+thiscalcdist)*fontsize_t

                  if (newcalcdist < thisdistance) {
                    # print "Estimated length with spacing=" spacing, "is", newcalcdist > "/dev/stderr"
                    thislabel=newlabel
                  } else {
                    # print "No adjust as", newcalcdist, ">=", thisdistance > "/dev/stderr"
                    break
                  }
              }
              # if (fontsize_t < minfontsize) {
              #   print "Label", thislabel, "has font size too small:", fontsize_t > "/dev/stderr"
              # }
            } # changesize==1
            if (fontsize_t > 1 && fontsize_t < minfontsize) {
              filename=sprintf("text_%0.1f_file.gmt", 1)
            } else {
              filename=sprintf("text_%0.1f_file.gmt", rd(fontsize_t, 0.5))
            }
            print "> -L" thislabel >> filename
          } else {
            if ($1 > 180) { $1=$1-360 }
            print $1, $2 >> filename
          }
        }
        ' data_proj_dist_labelcalc.txt data_resampled.txt > data.txt

      # Plot the text along the smoothed curves
      #gmt psxy data.txt -Sqn1:+v+Lh+i $RJOK >> map.ps

      if [[ ${m_label_plotline[$tt]} -eq 1 ]]; then
        local plotlinecmd=""
      else
        local plotlinecmd="+i"
      fi

      for textfile in text*.gmt; do
        fontsize=$(basename $textfile | gawk -F_ '{print $2}')
        if [[ $(echo "$fontsize >= ${m_label_minsize[$tt]}" | bc) -eq 1 ]]; then
          if [[ $(echo "${m_label_outline[$tt]} == 0" | bc) != 1 ]]; then
            widthval=$(echo "$fontsize * ${m_label_outline[$tt]}" | bc -l)
            m_label_textfont_outline=${m_label_font[$tt]},${m_label_fontcolor[$tt]}"=${widthval}p,${m_label_outlinecolor[$tt]}"
            gmt psxy $textfile -N -Sqn1:+Lh+f${fontsize}p,${m_label_textfont_outline}${plotlinecmd}+v $RJOK >> map.ps
          fi
          gmt psxy $textfile -N -Sqn1:+Lh+f${fontsize}p,${m_label_textfont}${plotlinecmd}+v $RJOK >> map.ps
        fi
      done

      tectoplot_plot_caught=1
    ;;
  esac
}

# function tectoplot_legendbar_labels() {
#   case $1 in
#     labels)
#       echo "G 0.2i" >> ${LEGENDDIR}legendbars.txt
#       echo "B $POPULATION_CPT 0.2i 0.1i+malu -W0.00001 ${LEGENDBAR_OPTS} -Bxaf+l\"City population (100k)\"" >> ${LEGENDDIR}legendbars.txt
#       barplotcount=$barplotcount+1
#       tectoplot_legendbar_caught=1
#       ;;
#   esac
# }

# function tectoplot_legend_labels() {
#   case $1 in
#   labels)
#     init_legend_item "labels"
#
#     echo "${CENTERLON} ${CENTERLAT} 10000" | gmt psxy -S${CITIES_SYMBOL}${CITIES_SYMBOL_SIZE} -W${CITIES_SYMBOL_LINEWIDTH},${CITIES_SYMBOL_LINECOLOR} -C$POPULATION_CPT $RJOK $VERBOSE -X.175i >> ${LEGFILE}
#     echo "${CENTERLON} ${CENTERLAT} City with population > ${CITIES_MINPOP}" | gmt pstext -F+f6p,Helvetica,black+jLM -X0.15i ${RJOK} $VERBOSE >> ${LEGFILE}
#
#     # Plot the symbol and accompanying text at the CENTERLON/CENTERLAT point (known to be on the map)
#     close_legend_item "labels"
#   ;;
#   esac
# }

# function tectoplot_post_labels() {
#   echo "none"
# }

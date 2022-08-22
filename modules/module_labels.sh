
TECTOPLOT_MODULES+=("labels")

function tectoplot_defaults_labels() {
  MODULE_LABEL_FONT_DEFAULT="Helvetica"
  MODULE_LABEL_FONTCOLOR_DEFAULT="black"
  MODULE_LABEL_MAXFONTSIZE_DEFAULT=12
  MODULE_LABEL_MINFONTSIZE_DEFAULT=3
  MODULE_LABEL_TRANS_DEFAULT=0
  MODULE_LABEL_OUTLINE_DEFAULT=""
  MODULE_LABEL_OUTLINE_COLOR_DEFAULT=white

  MODULE_LABEL_PLOTLINE="+i"  # +i option suppresses line plotting


  cuglab=1   # Start at the first position
}

function tectoplot_args_labels()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

    -labels)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
modules/module_labels.sh
-label:          plot labels along lines defined in KML file
-label [labelfile] [[options...]]

Options:

font                                 GMT builtin font name
color                                fill color
maxsize                              font size larger than this will be set to this
minsize                              text with font smaller than this will not plot
setsize                              try to plot all labels at set font size
outline  [proportion] [color]        activate outline
trans                                label text transparency
upper | lower | title                change case of label text
maxspace                             maximum number of spaces to add to text

GMT fonts

SERIF FONTS
--------------------------------------------------------------------------------
Bookman-Demi  Bookman-Demiltalic  Bookman-Light  Bookman-LightItalic
NewCenturySchlbk-Roman  NewCenturySchlbk-Italic  NewCenturySchlbk-Bold
   NewCenturySchlbk-BoldItalic
Palatino-Roman Palatino-Italic Palatino-Bold Palatino-Boldltalic
Symbol
Times-Roman  Times-Bold  Times-Italic  Times-Boldltalic
ZapfChancery-MediumItalic

SANS SERIF FONTS
--------------------------------------------------------------------------------
AvantGarde-Book  AvantGarde-BookOblique  AvantGarde-Demi  AvantGarde-DemiOblique
Courier  Courier-Bold  Courier-Oblique  Courier-Boldoblique
Helvetica  Helvetica-Bold  Helvetica-Oblique  Helvetica-BoldOblique
Helvetica-Narrow  Helvetica-Narrow-Bold  Helvetica-Narrow-Oblique
   Helvetica-Narrow-BoldOblique
ZapfDingbats

This module can be called multiple times with different options to plot multiple
types of labels with different symbologies

--------------------------------------------------------------------------------
EOF
  fi

  shift

  # Check if this is the first time we are calling -label
  if [[ $labfirst -ne 1 ]]; then
    uglab=0
    labfirst=1
  fi

  if arg_is_flag $1; then
    info_msg "[-label]: Must specify a label file and optional arguments"
    exit 1
  else
    uglab=$(echo "${uglab} + 1" | bc)

    if [[ ! -s ${1} ]]; then
      info_msg "[-label]: Label file $1 does not exist or is empty"
      exit 1
    fi
    MODULE_LABEL_FILE[$uglab]=$(abs_path $1)
    shift
    ((tectoplot_module_shift++))
  fi

  # Set the default values

  MODULE_LABEL_FONT[$uglab]=${MODULE_LABEL_FONT_DEFAULT}
  MODULE_LABEL_FONTCOLOR[$uglab]=${MODULE_LABEL_FONTCOLOR_DEFAULT}
  MODULE_LABEL_MAXFONTSIZE[$uglab]=${MODULE_LABEL_MAXFONTSIZE_DEFAULT}
  MODULE_LABEL_MINFONTSIZE[$uglab]=${MODULE_LABEL_MINFONTSIZE_DEFAULT}
  MODULE_LABEL_TRANS[$uglab]=${MODULE_LABEL_TRANS_DEFAULT}
  MODULE_LABEL_OUTLINE[$uglab]=${MODULE_LABEL_OUTLINE_DEFAULT}
  MODULE_LABEL_OUTLINE_COLOR[$uglab]=${MODULE_LABEL_OUTLINE_COLOR_DEFAULT}
  MODULE_LABEL_CASEFLAG[$uglab]=""
  MODULE_LABEL_MAXSPACING[$uglab]=4

  while ! arg_is_flag $1; do
    case $1 in
      # font
      # color
      # maxsize
      # minsize
      # outline
      # trans
      font)
        shift
        ((tectoplot_module_shift++))
        if ! arg_is_flag $1; then
          MODULE_LABEL_FONT[$uglab]="${1}"
          shift
          ((tectoplot_module_shift++))
        else
          echo "[-label]: option font requires a GMT font name argument"
          exit 1
        fi
      ;;
      color)
        shift
        ((tectoplot_module_shift++))
        if ! arg_is_flag $1; then
          MODULE_LABEL_FONTCOLOR[$uglab]="${1}"
          shift
          ((tectoplot_module_shift++))
        else
          echo "[-label]: option color requires argument"
          exit 1
        fi
      ;;
      maxsize)
        shift
        ((tectoplot_module_shift++))
        if ! arg_is_flag $1; then
          MODULE_LABEL_MAXFONTSIZE[$uglab]="${1}"
          shift
          ((tectoplot_module_shift++))
        else
          echo "[-label]: option maxsize requires argument"
          exit 1
        fi
      ;;
      minsize)
        shift
        ((tectoplot_module_shift++))
        if ! arg_is_flag $1; then
          MODULE_LABEL_MINFONTSIZE[$uglab]="${1}"
          shift
          ((tectoplot_module_shift++))
        else
          echo "[-label]: option minsize requires argument"
          exit 1
        fi
      ;;
      setsize)
        shift
        ((tectoplot_module_shift++))
        if ! arg_is_flag $1; then
          MODULE_LABEL_MINFONTSIZE[$uglab]="${1}"
          MODULE_LABEL_MAXFONTSIZE[$uglab]="${1}"
          shift
          ((tectoplot_module_shift++))
        else
          echo "[-label]: option setsize requires argument"
          exit 1
        fi
      ;;
      maxspace)
        shift
        ((tectoplot_module_shift++))
        if ! arg_is_flag $1; then
          MODULE_LABEL_MAXSPACING[$uglab]="${1}"
          shift
          ((tectoplot_module_shift++))
        else
          echo "[-label]: option maxspace requires argument"
          exit 1
        fi
      ;;
      outline)
      # Outline should be a percentage of font size rather than a fixed number
        shift
        ((tectoplot_module_shift++))
        if ! arg_is_flag $1; then
          MODULE_LABEL_OUTLINE[$uglab]="${1}"
          shift
          ((tectoplot_module_shift++))
        else
          echo "[-label]: option outline requires argument"
          exit 1
        fi
        if ! arg_is_flag $1; then
          MODULE_LABEL_OUTLINE_COLOR[$uglab]="${1}"
          shift
          ((tectoplot_module_shift++))
        fi
      ;;
      upper|lower|title)
        MODULE_LABEL_CASEFLAG[$uglab]="${1}"
        shift
        ((tectoplot_module_shift++))
      ;;
      *)
        echo "[-label]: argument ${1} not recognized"
        exit 1
      ;;
    esac
  done

  plots+=("labels")

  tectoplot_module_caught=1
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
      info_msg "Plotting labels from ${MODULE_LABEL_FILE[$cuglab]} with these options: ${MODULE_LABEL_FONT[$cuglab]} ${MODULE_LABEL_FONTCOLOR[$cuglab]} ${MODULE_LABEL_MAXFONTSIZE[$cuglab]} ${MODULE_LABEL_MINFONTSIZE[$cuglab]} ${MODULE_LABEL_TRANS[$cuglab]} ${MODULE_LABEL_OUTLINE[$cuglab]}"

      #TEXT_KMLFILE=/Users/kylebradley/Dropbox/scripts/tectoplot/labels/TextLabels.kml
      TEXT_FONT=${MODULE_LABEL_FONT[$cuglab]},${MODULE_LABEL_FONTCOLOR[$cuglab]}

      # TEXT_FONT_OUTLINE=${MODULE_LABEL_FONT[$cuglab]},${MODULE_LABEL_FONTCOLOR[$cuglab]}${MODULE_LABEL_OUTLINE[$cuglab]}

      rm -f TextLabels.gmt
      # Convert KML paths to GMT OGR format
      ogr2ogr -f "OGR_GMT" TextLabels.gmt ${MODULE_LABEL_FILE[$cuglab]}

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
      case ${MODULE_LABEL_CASEFLAG[$cuglab]} in
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
      ${BASHSCRIPTDIR}stringlength.sh ${MODULE_LABEL_FONT[$cuglab]} 1 data_proj_dist.txt ${BASHSCRIPTDIR}lettersizes.txt > data_proj_dist_labelcalc.txt

      #gmt mapproject data_pre.txt -i0,1 -G+ud+a > data_dist.txt

      # We can adjust the font size, which makes letters taller and wider, and we
      # can add spaces between letters, which makes the label wider only.

      # Input files are the data_proj_dist.txt containing GMT and calculated widths
      # and the resampled data file containing the same labels in the same order

      shopt -s nullglob
      rm -f text*.gmt

      gawk -v maxfontsize=${MODULE_LABEL_MAXFONTSIZE[$cuglab]} -v maxspacing=${MODULE_LABEL_MAXSPACING[$cuglab]} '
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

      for textfile in text*.gmt; do
        fontsize=$(basename $textfile | gawk -F_ '{print $2}')
        if [[ $(echo "$fontsize >= ${MODULE_LABEL_MINFONTSIZE[$cuglab]}" | bc) -eq 1 ]]; then
          #echo gmt psxy $textfile -Sqn1:+Lh+f${fontsize}p,$TEXT_FONT${PLOTLINE}+v $RJOK
          if [[ ${MODULE_LABEL_OUTLINE[$cuglab]} != "" ]]; then
            widthval=$(echo "$fontsize * ${MODULE_LABEL_OUTLINE[$cuglab]}" | bc -l)
            TEXT_FONT_OUTLINE=${MODULE_LABEL_FONT[$cuglab]},${MODULE_LABEL_FONTCOLOR[$cuglab]}"=${widthval}p,${MODULE_LABEL_OUTLINE_COLOR[$cuglab]}"
            gmt psxy $textfile -N -Sqn1:+Lh+f${fontsize}p,${TEXT_FONT_OUTLINE}${MODULE_LABEL_PLOTLINE}+v $RJOK >> map.ps
          fi
          gmt psxy $textfile -N -Sqn1:+Lh+f${fontsize}p,${TEXT_FONT}${MODULE_LABEL_PLOTLINE}+v $RJOK >> map.ps
        fi
      done

      cuglab=$(echo "$cuglab + 1" | bc -l)

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

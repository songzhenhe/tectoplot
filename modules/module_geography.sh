
TECTOPLOT_MODULES+=("geography")

# plot geographic elements like coastlines, country borders

function tectoplot_defaults_geography() {

################################################################################
##### Coastlines and land/sea colors
COAST_QUALITY="-Da"          # pscoast quality
COAST_SIZELIMIT=0
FILLCOASTS=""                # pscoast option for filling land areas
COAST_LINEWIDTH="0.5p"       # pscoast line width
COAST_LINECOLOR="black"      # pscoast line color

LAKE_LINEWIDTH="0.2p"
LAKE_LINECOLOR="black"

RIVER_LINEWIDTH=0.4p
RIVER_LINECOLOR="blue"
RIVER_COMMAND=""

COAST_KM2="100"              # minimum size (im km^2) of feature
LANDCOLOR="gray"             # color of land areas
SEACOLOR="lightblue"         # color of sea areas
FILLCOASTS=""                # empty by default = don't fill anything

################################################################################
##### Country borders and labels
BORDER_LINEWIDTH="1.3p"      # National border linewidth
BORDER_LINECOLOR="red"       # National border linecolor

BORDER_QUALITY="-Da"
BORDER_LINEWIDTH="0.5p"
BORDER_LINECOLOR="red"

COUNTRY_LABEL_FONTSIZE="8p"
COUNTRY_LABEL_FONT="Helvetica"
COUNTRY_LABEL_FONTCOLOR="red"

BORDER_STATE_QUALITY="-Da"
BORDER_STATE_LINEWIDTH="0.3p"
BORDER_STATE_LINECOLOR="red"

}

function tectoplot_args_geography()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -a) # args: none || string
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-a:            plot ocean/land coastlines
-a [[quality=${COAST_QUALITY}]] [[sizelimit=${COAST_SIZELIMIT}]]
  Plot ocean coastlines with a given quality (option descriptions from GMT:)
  a - auto: select best resolution given map scale.
  f - full resolution (may be very slow for large regions).
  h - high resolution (may be slow for large regions).
  i - intermediate resolution.
  l - low resolution [Default].
  c - crude resolution, for busy plots that need crude continent outlines only.
Example:
  tectoplot -r g -a l
--------------------------------------------------------------------------------
EOF
fi

    shift

    if arg_is_flag $1; then
			info_msg "[-a]: No quality specified. Using GMT flag ${COAST_QUALITY}"
		else
			COAST_QUALITY="-D${1}"
			shift
      ((tectoplot_module_shift++))
		fi
    if arg_is_flag $1; then
      info_msg "[-a]: No coast element size limit specified. Using ${COAST_KM2} km*km"
    else
      COAST_KM2="${1}"
      shift
      ((tectoplot_module_shift++))
    fi
    plots+=("coasts")

    echo $COASTS_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $COASTS_SOURCESTRING >> ${LONGSOURCES}

    tectoplot_module_caught=1
    ;;

  -ac) # args: landcolor seacolor
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ac:           plot land/water color (requires -a)
-ac [[land color]] [[sea color]]
  Set options to fill land and water areas with a solid color when using -a
Example: Plot global land/sea areas
  tectoplot -r g -a l -ac lightbrown lightblue
--------------------------------------------------------------------------------
EOF
fi
    shift
    filledcoastlinesflag=1
    if arg_is_flag $1; then
      info_msg "[-ac]: No land/sea color specified. Using defaults"
      FILLCOASTS="-G${LANDCOLOR} -S${SEACOLOR}"
    else
      LANDCOLOR="${1}"
      shift
      ((tectoplot_module_shift++))
    fi
    if arg_is_flag $1; then
      info_msg "[-ac]: No sea color specified. Not filling sea areas"
      FILLCOASTS="-G${LANDCOLOR}"
    else
      SEACOLOR="${1}"
      shift
      ((tectoplot_module_shift++))
      FILLCOASTS="-G$LANDCOLOR -S$SEACOLOR"
    fi

    echo $COASTS_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $COASTS_SOURCESTRING >> ${LONGSOURCES}

    tectoplot_module_caught=1
    ;;

  -acb)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-acb:          plot country borders
-acb [[line color=${BORDER_LINECOLOR}]] [[line width${BORDER_LINEWIDTH}]] [[border quality=${BORDER_QUALITY}]]
  a - auto: select best resolution given map scale.
  f - full resolution (may be very slow for large regions).
  h - high resolution (may be slow for large regions).
  i - intermediate resolution.
  l - low resolution [Default].
  c - crude resolution, for busy plots that need crude continent outlines only.
Example: Plot global country borders and coastline
  tectoplot -r g -a l -acb red 0.2p a
--------------------------------------------------------------------------------
EOF
fi

    shift
    if arg_is_flag $1; then
      info_msg "[-acb]: No border line color specified. Using $BORDER_LINECOLOR"
    else
      BORDER_LINECOLOR="${1}"
      shift
      ((tectoplot_module_shift++))
    fi
    if arg_is_flag $1; then
      info_msg "[-acb]: No border line width specified. Using $BORDER_LINEWIDTH"
    else
      BORDER_LINEWIDTH="${1}"
      shift
      ((tectoplot_module_shift++))
    fi
    if arg_is_flag $1; then
      info_msg "[-acb]: No border quality specified [a,l,f]. Using $BORDER_QUALITY"
    else
      BORDER_QUALITY="-D${1}"
      shift
      ((tectoplot_module_shift++))
    fi

    echo $COASTS_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $COASTS_SOURCESTRING >> ${LONGSOURCES}

    plots+=("countryborders")
    tectoplot_module_caught=1
    ;;

    -acl)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-acl:          label countries
-acl [labelcolor]
Example: Outline and label the countries of Africa
  tectoplot -r =AF -a l -acb red 0.2p a -acl
--------------------------------------------------------------------------------
EOF
  fi

    shift
    if arg_is_flag $1; then
      info_msg "[-acl]: No font color specified. Using $COUNTRY_LABEL_FONTCOLOR"
    else
      COUNTRY_LABEL_FONTCOLOR="${1}"
      shift
    fi

    echo $COASTS_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $COASTS_SOURCESTRING >> ${LONGSOURCES}

    plots+=("countrylabels")
    tectoplot_module_caught=1

    ;;

    -acs)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-acb:          plot state borders
-acb [[line color=${BORDER_STATE_LINECOLOR}]] [[line width${BORDER_STATE_LINEWIDTH}]] [[border quality=${BORDER_STATE_QUALITY}]]
  a - auto: select best resolution given map scale.
  f - full resolution (may be very slow for large regions).
  h - high resolution (may be slow for large regions).
  i - intermediate resolution.
  l - low resolution [Default].
  c - crude resolution, for busy plots that need crude continent outlines only.
Example: Plot state borders and coastline
  tectoplot -r g -a l -acs red 0.2p a
--------------------------------------------------------------------------------
EOF
  fi
    shift

    if arg_is_flag $1; then
      info_msg "[-acs]: No border line color specified. Using $BORDER_STATE_LINECOLOR"
    else
      BORDER_STATE_LINECOLOR="${1}"
      shift
      ((tectoplot_module_shift++))
    fi
    if arg_is_flag $1; then
      info_msg "[-acs]: No border line width specified. Using $BORDER_STATE_LINEWIDTH"
    else
      BORDER_STATE_LINEWIDTH="${1}"
      shift
      ((tectoplot_module_shift++))

    fi
    if arg_is_flag $2; then
      info_msg "[-acs]: No border quality specified [a,l,f]. Using $BORDER_STATE_QUALITY"
    else
      BORDER_STATE_QUALITY="-D${1}"
      shift
      ((tectoplot_module_shift++))
    fi

    echo $COASTS_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $COASTS_SOURCESTRING >> ${LONGSOURCES}

    plots+=("stateborders")
    tectoplot_module_caught=1

    ;;

    -countries)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-countries:    print randomly colored country polygons
-countries [trans] [[cpt]]
  trans is percent in 0-100
  cpt is any GMT recognized CPT file

  Currently, the colors change each time the plot is produced!

Example:
   tectoplot -r =AF -countries 0 wysiwyg -a
--------------------------------------------------------------------------------
EOF
  fi

    shift
    if arg_is_positive_float $2; then
      COUNTRIES_TRANS="${2}"
      shift
      ((tectoplot_module_shift++))
    fi
    if ! arg_is_flag $2; then
      COUNTRIESCPT="${2}"
      shift
      ((tectoplot_module_shift++))
    fi

    echo $COASTS_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $COASTS_SOURCESTRING >> ${LONGSOURCES}

    plots+=("countries")
    tectoplot_module_caught=1
  ;;

  -rivers)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-rivers:       plot rivers if -a command is called
-rivers

Example:
   tectoplot -r BR -a -rivers
--------------------------------------------------------------------------------
EOF
fi

    shift
    RIVER_COMMAND="-I1/${RIVER_LINEWIDTH},${RIVER_LINECOLOR} -I2/${RIVER_LINEWIDTH},${RIVER_LINECOLOR}"

    echo $COASTS_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $COASTS_SOURCESTRING >> ${LONGSOURCES}

    tectoplot_module_caught=1
    ;;


  esac
}

# tectoplot_cpts_geography() {
#
# }

# function tectoplot_calculate_geography()  {
# }

# function tectoplot_cpt_geography() {
# }

function tectoplot_plot_geography() {
  case $1 in

  coasts)
    gmt pscoast $COAST_QUALITY ${RIVER_COMMAND} -W1/$COAST_LINEWIDTH,$COAST_LINECOLOR -W2/$LAKE_LINEWIDTH,$LAKE_LINECOLOR $FILLCOASTS -A$COAST_KM2 $RJOK $VERBOSE >> map.ps
    tectoplot_plot_caught=1
    ;;

  countries)
    gmt pscoast -Df -E+l -Vn | gawk -F'\t' '{print $1}' > ${F_MAPELEMENTS}countries.txt
    NUMCOUNTRIES=$(wc -l < ${F_MAPELEMENTS}countries.txt | gawk '{print $1+0}')
    gmt makecpt -N -T0/${NUMCOUNTRIES}/1 -C${COUNTRIESCPT} -Vn  | gawk '{print $2}' | sort -R > ${F_MAPELEMENTS}country_colors.txt
    paste ${F_MAPELEMENTS}countries.txt ${F_MAPELEMENTS}country_colors.txt | gawk '{printf("-E%s+g%s ", $1, $2)}' > ${F_MAPELEMENTS}combined.txt
    string=($(cat ${F_MAPELEMENTS}combined.txt))
    gmt pscoast -Df ${string[@]} ${RJOK} ${VERBOSE} -t${COUNTRIES_TRANS} -Slightblue >> map.ps
    tectoplot_plot_caught=1
    ;;

  countryborders)
    gmt pscoast ${BORDER_QUALITY} -N1/${BORDER_LINEWIDTH},${BORDER_LINECOLOR} $RJOK $VERBOSE >> map.ps
    tectoplot_plot_caught=1
    ;;

  stateborders)
    gmt pscoast ${BORDER_STATE_QUALITY} -N2/${BORDER_STATE_LINEWIDTH},${BORDER_STATE_LINECOLOR} $RJOK $VERBOSE >> map.ps
    tectoplot_plot_caught=1
    ;;

  countrylabels)
    gawk -F, < $COUNTRY_CODES '{ print $3, $2, $4}' | gmt pstext -F+f${COUNTRY_LABEL_FONTSIZE},${COUNTRY_LABEL_FONT},${COUNTRY_LABEL_FONTCOLOR}+jLM $RJOK ${VERBOSE} >> map.ps
    tectoplot_plot_caught=1
    ;;

  esac
}

# function tectoplot_legend_geography() {
#   echo "none"
# }

# function tectoplot_legendbar_geography() {
#   echo "none"
# }

# function tectoplot_post_geography() {
#   echo "none"
# }

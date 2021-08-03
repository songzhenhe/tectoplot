
# Commands for plotting GIS files

# Register the module with tectoplot
TECTOPLOT_MODULES+=("gis")

# Description of the module goes here

# Variables that expected to be defined are listed here:
# VARIABLE_1
# VARIABLE_2

# Defaults are variabls or paths that need to be defined for this module but
# which may be shared with the tectoplot primary code.

function tectoplot_defaults_example() {
  SCRIPTPATH=${BASHSCRIPTDIR}"example_script.sh"
  THIS_VARIABLE=145
}

# Argument processing function defines the flag (-example) and parses arguments

function tectoplot_args_example()  {
  # The following lines are required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

    -pt|--point)
  if [[ $USAGEFLAG -eq 1 ]]; then
  cat <<-EOF
-pt:           plot point dataset with specified size, fill, cpt
-pt [filename] [[symbol=${POINT_SYMBOL}]] [[size=${POINTSIZE}]] [[@ color]]
-pt [filename] [[symbol=${POINT_SYMBOL}]] [[size=${POINTSIZE}]] [[cpt_filename]]

  symbol is a GMT psxy -S code:
    +(plus), st(a)r, (b|B)ar, (c)ircle, (d)iamond, (e)llipse,
 	  (f)ront, octa(g)on, (h)exagon, (i)nvtriangle, (j)rotated rectangle,
 	  pe(n)tagon, (p)oint, (r)ectangle, (R)ounded rectangle, (s)quare,
    (t)riangle, (x)cross, (y)dash,

  Multiple calls to -pt can be made; they will plot in map layer order.

Example: None
--------------------------------------------------------------------------------
EOF

  fi
      shift

      # COUNTER userpointfilenumber
      # Required arguments
      userpointfilenumber=$(echo "$userpointfilenumber + 1" | bc -l)
      POINTDATAFILE[$userpointfilenumber]=$(abs_path $1)
      shift
      ((tectoplot_module_shift++))
      if [[ ! -e ${POINTDATAFILE[$userpointfilenumber]} ]]; then
        info_msg "[-pt]: Point data file ${POINTDATAFILE[$userpointfilenumber]} does not exist."
        exit 1
      fi
      # Optional arguments
      # Look for symbol code
      if arg_is_flag $1; then
        info_msg "[-pt]: No symbol specified. Using $POINTSYMBOL."
        POINTSYMBOL_arr[$userpointfilenumber]=$POINTSYMBOL
      else
        POINTSYMBOL_arr[$userpointfilenumber]="${1:0:1}"
        shift
        ((tectoplot_module_shift++))
        info_msg "[-pt]: Point symbol specified. Using ${POINTSYMBOL_arr[$userpointfilenumber]}."
      fi

      # Then look for size
      if arg_is_flag $1; then
        info_msg "[-pt]: No size specified. Using $POINTSIZE."
        POINTSIZE_arr[$userpointfilenumber]=$POINTSIZE
      else
        POINTSIZE_arr[$userpointfilenumber]="${1}"
        shift
        ((tectoplot_module_shift++))
        info_msg "[-pt]: Point size specified. Using ${POINTSIZE_arr[$userpointfilenumber]}."
      fi

      # Finally, look for CPT file
      if arg_is_flag $1; then
        info_msg "[-pt]: No cpt specified. Using ${POINTCOLOR} fill for -G"
        pointdatafillflag[$userpointfilenumber]=1
        pointdatacptflag[$userpointfilenumber]=0
      elif [[ ${1:0:1} == "@" ]]; then
        shift
        ((tectoplot_module_shift++))
        POINTCOLOR=${1}
        info_msg "[-pt]: No cpt specified using @. Using POINTCOLOR for -G"
        shift
        ((tectoplot_module_shift++))
        pointdatafillflag[$userpointfilenumber]=1
        pointdatacptflag[$userpointfilenumber]=0
      else
        POINTDATACPT[$userpointfilenumber]=$(abs_path $1)
        shift
        ((tectoplot_module_shift++))
        if [[ ! -e ${POINTDATACPT[$userpointfilenumber]} ]]; then
          info_msg "[-pt]: CPT file $POINTDATACPT does not exist. Using default $POINTCPT"
          POINTDATACPT[$userpointfilenumber]=$(abs_path $POINTCPT)
        else
          info_msg "[-pt]: Using CPT file $POINTDATACPT"
        fi
        pointdatacptflag[$userpointfilenumber]=1
        pointdatafillflag[$userpointfilenumber]=0
      fi

      info_msg "[-pt]: PT${userpointfilenumber}: ${POINTDATAFILE[$userpointfilenumber]}"
      plots+=("points")

      tectoplot_module_caught=1
    ;;
  esac
}

# function tectoplot_calculate_example()  {
#   echo "This function contains any calculations to be done before plotting"
#   echo "Functions will be run in alphabetical order!"
# }

# function tectoplot_cpt_example() {
#   echo "This section contains code to generate CPT files in ${F_CPTS} for plotting"
#   echo "This function will only be run if the module contains cpts+=(...)"
# }

# function tectoplot_plot_example() {
#   echo "This function contains the logic to plot elements onto the active map"
#   echo "\$RJOK is -R -J -O -K and \${VERBOSE} is the active verbosity setting"
#   echo "Concatenate PS data onto map.ps"
#
#   gmt GMT_MODULE GMT_COMMANDS $RJOK ${VERBOSE} >> map.ps
# }

# This function is taken from module_volcanoes.sh and shows how to add an entry
# to the legend

# function tectoplot_legend_example() {
#   # Create a new blank map with the same -R -J as our main map
#   gmt psxy -T -X0i -Yc $OVERLAY $VERBOSE -K ${RJSTRING[@]} > volcanoes.ps
#
#   # Plot the symbol and accompanying text at the CENTERLON/CENTERLAT point (known to be on the map)
#   echo "$CENTERLON $CENTERLAT" | gmt psxy -W"${V_LINEW}","${V_LINECOLOR}" -G"${V_FILL}" -S${V_SYMBOL}${V_SIZE} $RJOK $VERBOSE >> volcanoes.ps
#   echo "$CENTERLON $CENTERLAT Volcano" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE -J -R -Y0.1i -O >> volcanoes.ps
#
#   # Calculate the width and height of the graphic with a margin of 0.05i
#   PS_DIM=$(gmt psconvert volcanoes.ps -Te -A0.05i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
#   PS_WIDTH_IN=$(echo $PS_DIM | gawk  '{print $1/2.54}')
#   PS_HEIGHT_IN=$(echo $PS_DIM | gawk  '{print $2/2.54}')
#
#   # Place the graphic onto the legend PS file, appropriately shifted. Then shift up.
#   # If we run past the width of the map, then we shift all the way left; otherwise we shift right.
#   # (The typewriter approach)
#
#   gmt psimage -Dx"${LEG2_X}i/${LEG2_Y}i"+w${PS_WIDTH_IN}i volcanoes.eps $RJOK ${VERBOSE} >> $LEGMAP
#   LEG2_Y=$(echo "$LEG2_Y + $PS_HEIGHT_IN + 0.02" | bc -l)
#   count=$count+1
#   NEXTX=$(echo $PS_WIDTH_IN $NEXTX | gawk  '{if ($1>$2) { print $1 } else { print $2 } }')
#   cleanup volcanoes.ps volcanoes.eps
# }

# function tectoplot_post_example() {
#   echo "This function contains logic that is executed after the map document is finalized."
#   echo "Extra figures, 3D models, etc. can be processed at this point"
# }

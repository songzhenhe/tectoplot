
# Commands for plotting GIS point files

# Register the module with tectoplot
TECTOPLOT_MODULES+=("gis_point")

function tectoplot_defaults_gis_point() {
  POINTSYMBOL="c"
  POINTCOLOR="black"
  POINTSIZE="0.02i"
  POINTLINECOLOR="black"
  POINTLINEWIDTH="0.5p"
  POINTCPT=$CPTDIR"defaultpt.cpt"
}

# Argument processing function defines the flag (-example) and parses arguments

function tectoplot_args_gis_point()  {
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
      plots+=("gis_point")

      tectoplot_module_caught=1
    ;;
  esac
}

# function tectoplot_calculate_gis_point()  {
# }

# function tectoplot_cpt_gis_point() {
# }

function tectoplot_plot_gis_point() {
  info_msg "Plotting point dataset $current_userpointfilenumber: ${POINTDATAFILE[$current_userpointfilenumber]}"
  if [[ ${pointdatacptflag[$current_userpointfilenumber]} -eq 1 ]]; then
    gmt psxy ${POINTDATAFILE[$current_userpointfilenumber]} -W$POINTLINEWIDTH,$POINTLINECOLOR -C${POINTDATACPT[$current_userpointfilenumber]} -G+z -S${POINTSYMBOL_arr[$current_userpointfilenumber]}${POINTSIZE_arr[$current_userpointfilenumber]} $RJOK $VERBOSE >> map.ps
  else
    gmt psxy ${POINTDATAFILE[$current_userpointfilenumber]} -G$POINTCOLOR -W$POINTLINEWIDTH,$POINTLINECOLOR -S${POINTSYMBOL_arr[$current_userpointfilenumber]}${POINTSIZE_arr[$current_userpointfilenumber]} $RJOK $VERBOSE >> map.ps
  fi
  current_userpointfilenumber=$(echo "$current_userpointfilenumber + 1" | bc -l)
}

# function tectoplot_legend_gis_point() {
# }

# function tectoplot_post_gis_point() {
# }


TECTOPLOT_MODULES+=("volcanoes")

# Plot volcanoes

# Flags respected:
# polygonselectflag : 1==select from $POLYGONOI

function tectoplot_defaults_volcanoes() {
  V_SYMBOL="t"                  # volcano symbol; t=triangle    kvolcano/=volcano
  V_FILL="red"                  # volcano symbol, fill
  V_SIZE="0.075i"               # volcano symbol, size
  V_LINEW="0.3p"                # volcano symbol, edge line width
  V_LINECOLOR="black"           # volcano symbol, edge line color

  VOLC_SOURCESTRING="Volcano data from Smithsonian GVP (https://volcano.si.edu/), Whelley et al. 2015 doi:10.1007/s00445-014-0893-8"
  VOLC_SHORT_SOURCESTRING="GVP"

  SMITHVOLC=$DATAROOT"Smithsonian/GVP_4.8.8_lat_lon_elev.txt"
  WHELLEYVOLC=$DATAROOT"Smithsonian/Whelley_2015_volcanoes.txt"
  JAPANVOLC=$DATAROOT"Smithsonian/japan_volcanoes.lonlatname"

}

function tectoplot_args_volcanoes()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -vc|--volc) # args: none
    if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
modules/module_volcanoes.sh
-vc:           plot volcanoes
-vc [[fill color=${V_FILL}]] [[line width=${V_LINEW}]] [[size=${V_SIZE}]]

  Data from a variety of sources; Smithsonian, Whelley 2015, Japan
  Currently uses the GMT custom volcano symbol.

Example: Volcanoes of Japan
  tectoplot -r JP -a -vc
--------------------------------------------------------------------------------
EOF
    fi
    shift

    if ! arg_is_flag $1 ; then
      V_FILL="${1}"
      shift
      ((tectoplot_module_shift++))
    fi
    if ! arg_is_flag $1 ; then
      V_LINEW="${1}"
      shift
      ((tectoplot_module_shift++))
    fi
    if ! arg_is_flag $1; then
      V_SIZE="${1}"
      shift
      ((tectoplot_module_shift++))
    fi

    plots+=("volcanoes")

    echo $VOLC_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $VOLC_SOURCESTRING >> ${LONGSOURCES}

    tectoplot_module_caught=1
    ;;
  esac
}

function tectoplot_calculate_volcanoes()  {
    # lat lon elevation
    cat $SMITHVOLC $WHELLEYVOLC | gawk -v minlon=${MINLON} -v maxlon=${MAXLON} -v minlat=${MINLAT} -v maxlat=${MAXLAT} '
    @include "tectoplot_functions.awk"
    {
      lat=$1
      lon=$2
      elev=$3
      if (minlat <= lat && lat <= maxlat) {
        if (test_lon(minlon, maxlon, lon)==1) {
          print lon, lat, elev
        }
      }
    }' >> ${F_VOLC}volcanoes.dat

    # lon lat elevation elevation
    cat $JAPANVOLC | gawk -v minlon=${MINLON} -v maxlon=${MAXLON} -v minlat=${MINLAT} -v maxlat=${MAXLAT} '
    @include "tectoplot_functions.awk"
    {
      lon=$1
      lat=$2
      elev=$3
      if (minlat <= lat && lat <= maxlat) {
        if (test_lon(minlon, maxlon, lon)==1) {
          print lon, lat, elev
        }
      }
    }' >> ${F_VOLC}volcanoes.dat

    # Polygon select

    if [[ $polygonselectflag -eq 1 ]]; then
      info_msg "Selecting volcanoes within AOI polygon ${POLYGONAOI}"
      mv ${F_VOLC}volcanoes.dat ${F_VOLC}volcanoes_preselect.dat
      gmt select ${F_VOLC}volcanoes_preselect.dat -F${POLYGONAOI} -Vn | tr '\t' ' ' > ${F_VOLC}volcanoes.dat
      cleanup ${F_SEIS}eqs_preselect.txt
    fi

    # gmt select $JAPANVOLC -R$MINLON/$MAXLON/$MINLAT/$MAXLAT $VERBOSE  >> ${F_VOLC}volctmp.dat
    # gawk < ${F_VOLC}volctmp.dat '{
    #   printf "%s %s ", $2, $1
    #   for (i=3; i<=NF; i++) {
    #     printf "%s ", $(i)
    #   }
    #   printf("\n")
    # }' > ${F_VOLC}volcanoes.dat
    # cleanup ${F_VOLC}volctmp.dat
}

function tectoplot_plot_volcanoes() {
  case $1 in
  volcanoes)
    info_msg "[-vc]: Plotting volcanoes"
    gmt psxy ${F_VOLC}volcanoes.dat -W"${V_LINEW}","${V_LINECOLOR}" -G"${V_FILL}" -S${V_SYMBOL}${V_SIZE}  $RJOK $VERBOSE >> map.ps
    ;;
  esac
}

# This legend code is a good example of how we manage graphic legend entries.

function tectoplot_legend_volcanoes() {

  case $1 in
  volcanoes)
    info_msg "[-vc]: plotting volcanoes on legend"

    # Create a new blank map with the same -R -J as our main map
    gmt psxy -T -X0i -Yc $OVERLAY $VERBOSE -K ${RJSTRING[@]} > volcanoes.ps

    # Plot the symbol and accompanying text at the CENTERLON/CENTERLAT point (known to be on the map)
    echo "$CENTERLON $CENTERLAT" | gmt psxy -W"${V_LINEW}","${V_LINECOLOR}" -G"${V_FILL}" -S${V_SYMBOL}${V_SIZE} $RJOK $VERBOSE >> volcanoes.ps
    echo "$CENTERLON $CENTERLAT Volcano" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE -J -R -Y0.1i -O >> volcanoes.ps

    # Calculate the width and height of the graphic with a margin of 0.05i
    PS_DIM=$(gmt psconvert volcanoes.ps -Te -A0.05i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
    PS_WIDTH_IN=$(echo $PS_DIM | gawk  '{print $1/2.54}')
    PS_HEIGHT_IN=$(echo $PS_DIM | gawk  '{print $2/2.54}')

    # Place the graphic onto the legend PS file, appropriately shifted. Then shift up.
    # If we run past the width of the map, then we shift all the way left; otherwise we shift right.
    # (The typewriter approach)

    gmt psimage -Dx"${LEG2_X}i/${LEG2_Y}i"+w${PS_WIDTH_IN}i volcanoes.eps $RJOK ${VERBOSE} >> $LEGMAP
    LEG2_Y=$(echo "$LEG2_Y + $PS_HEIGHT_IN + 0.02" | bc -l)
    count=$count+1
    NEXTX=$(echo $PS_WIDTH_IN $NEXTX | gawk  '{if ($1>$2) { print $1 } else { print $2 } }')
    cleanup volcanoes.ps volcanoes.eps
    tectoplot_legend_caught=1
    ;;
  esac
}

function tectoplot_post_volcanoes() {

  # If Slab2.0 is loaded and at least one slab exists, sample the slab data at volcano positions and
  # output a file into volcanoes/
    for i in $(seq 1 $numslab2inregion); do
      echo "Sampling earthquake events on ${slab2inregion[$i]}"
      depthfile=$(echo ${SLAB2_GRIDDIR}${slab2inregion[$i]}.grd | sed 's/clp/dep/')
      strikefile=$(echo ${SLAB2_GRIDDIR}${slab2inregion[$i]}.grd | sed 's/clp/str/')
      dipfile=$(echo ${SLAB2_GRIDDIR}${slab2inregion[$i]}.grd | sed 's/clp/dip/')

      [[ ! -s $depthfile ]] && echo "Slab depth file $depthfile is empty or does not exist"

      echo $depthfile $strikefile $dipfile

      # -N flag is needed in case events fall outside the domain
      gmt grdtrack -G$depthfile -G$strikefile -G$dipfile -N ${F_VOLC}volcanoes.dat ${VERBOSE} >> ${F_VOLC}volcano_slab2.txt
    done
}

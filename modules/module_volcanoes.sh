
TECTOPLOT_MODULES+=("volcanoes")

# Plot volcanoes

# NEW OPTS

# Flags respected:
# polygonselectflag : 1==select from $POLYGONOI

function tectoplot_defaults_volcanoes() {
  VOLC_SOURCESTRING="Volcano data from Smithsonian GVP (https://volcano.si.edu/), Whelley et al. 2015 doi:10.1007/s00445-014-0893-8"
  VOLC_SHORT_SOURCESTRING="GVP"

  SMITHVOLC=$DATAROOT"Smithsonian/GVP_4.8.8_lat_lon_elev.txt"
  WHELLEYVOLC=$DATAROOT"Smithsonian/Whelley_2015_volcanoes.txt"
  JAPANVOLC=$DATAROOT"Smithsonian/japan_volcanoes.lonlatname"
  HARISVOLC=${TECTFABRICSDIR}"HarisVolcElev.txt"
}

function tectoplot_args_volcanoes()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -vc) # args: none
  tectoplot_get_opts_inline '
des -vc plot global volcano locations data
opt fill m_volcanoes_fill word "red"
  fill color of volcano symbols
opt line m_volcanoes_line word "0.3p,black"
  line definition for volcano symbol
opt size m_volcanoes_size word "0.075i"
  size of volcano symbols, in points
opt symbol m_volcanoes_symbol word "t"
  GMT symbol code
mes Data from a variety of sources; Smithsonian, Whelley 2015, Japan
exa tectoplot -r JP -a -vc
' "${@}" || return

    plots+=("volcanoes")

    echo $VOLC_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $VOLC_SOURCESTRING >> ${LONGSOURCES}
    ;;
  esac
}

function tectoplot_calculate_volcanoes()  {

    # Create directory
    mkdir -p "${TMP}${F_VOLC}"

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

    # lat lon elevation
    cat $HARISVOLC | gawk -v minlon=${MINLON} -v maxlon=${MAXLON} -v minlat=${MINLAT} -v maxlat=${MAXLAT} '
    @include "tectoplot_functions.awk"
    {
      lat=$2
      lon=$1
      elev=$3
      if (minlat <= lat && lat <= maxlat) {
        if (test_lon(minlon, maxlon, lon)==1) {
          print lon, lat, elev
        }
      }
    }' >> ${F_VOLC}volcanoes.dat


    # Experimental work with GeoJSON converted from Smithsonian databases

    # Select the volcanoes within the map region
    ogr2ogr -sql 'SELECT * from GVP_Volcano_List_Holocene where (lon >= '${MINLON}' and lon <= '${MAXLON}' and lat <= '${MAXLAT}' and lat >= '${MINLAT}')' holocene.geojson /Users/kylebradley/Dropbox/TectoplotData/Volcanoes/GVP_5.0.2_Holocene.geojson
    ogr2ogr -sql 'SELECT * from GVP_Volcano_List_Pleistocene where (lon >= '${MINLON}' and lon <= '${MAXLON}' and lat <= '${MAXLAT}' and lat >= '${MINLAT}')' pleistocene.geojson /Users/kylebradley/Dropbox/TectoplotData/Volcanoes/GVP_5.0.2_Pleistocene.geojson


    # # lon lat elevation elevation
    # cat $JAPANVOLC | gawk -v minlon=${MINLON} -v maxlon=${MAXLON} -v minlat=${MINLAT} -v maxlat=${MAXLAT} '
    # @include "tectoplot_functions.awk"
    # {
    #   lon=$1
    #   lat=$2
    #   elev=$3
    #   if (minlat <= lat && lat <= maxlat) {
    #     if (test_lon(minlon, maxlon, lon)==1) {
    #       print lon, lat, elev
    #     }
    #   }
    # }' >> ${F_VOLC}volcanoes.dat

    # Map region select
    select_in_gmt_map ${F_VOLC}volcanoes.dat ${RJSTRING}

    # Polygon select
    if [[ $polygonselectflag -eq 1 ]]; then
      info_msg "Selecting volcanoes within AOI polygon ${POLYGONAOI}"
      mv ${F_VOLC}volcanoes.dat ${F_VOLC}volcanoes_preselect.dat
      gmt select ${F_VOLC}volcanoes_preselect.dat -F${POLYGONAOI} -Vn | tr '\t' ' ' > ${F_VOLC}volcanoes.dat
      cleanup ${F_SEIS}eqs_preselect.txt
    fi
}

function tectoplot_plot_volcanoes() {
  case $1 in
  volcanoes)
    info_msg "[-vc]: Plotting volcanoes >${tt}<"
    gmt psxy ${F_VOLC}volcanoes.dat -W${m_volcanoes_line[$tt]} -G${m_volcanoes_fill[$tt]} -S${m_volcanoes_symbol[$tt]}${m_volcanoes_size[$tt]}  $RJOK $VERBOSE >> map.ps
    ;;
  esac
}

# This legend code is a good example of how we manage graphic legend entries.

function tectoplot_legend_volcanoes() {

  case $1 in
  volcanoes)
    info_msg "[-vc]: plotting volcanoes on legend"

    init_legend_item "volcanoes"

    # Plot the symbol and accompanying text at the CENTERLON/CENTERLAT point (known to be on the map)
    echo "$CENTERLON $CENTERLAT" | gmt psxy -W${m_volcanoes_line[$tt]} -G${m_volcanoes_fill[$tt]} -S${m_volcanoes_symbol[$tt]}${m_volcanoes_size[$tt]} $RJOK $VERBOSE >> ${LEGFILE}
    echo "$CENTERLON $CENTERLAT Volcano" | gmt pstext -F+f6p,Helvetica,black+jLM $VERBOSE ${RJOK} -Y0.01i -X0.15i >> ${LEGFILE}

    close_legend_item "volcanoes"

    tectoplot_legend_caught=1
    ;;
  esac
}

function tectoplot_post_volcanoes() {

  # If Slab2.0 is loaded and at least one slab exists, sample the slab data at volcano positions and
  # output a file into volcanoes/
    if [[ $numslab2inregion -gt 0 ]]; then
      for i in $(seq 1 $numslab2inregion); do
        info_msg "Sampling volcanoes on ${slab2inregion[$i]}"
        depthfile=$(echo ${SLAB2_GRIDDIR}${slab2inregion[$i]}.grd | sed 's/clp/dep/')
        strikefile=$(echo ${SLAB2_GRIDDIR}${slab2inregion[$i]}.grd | sed 's/clp/str/')
        dipfile=$(echo ${SLAB2_GRIDDIR}${slab2inregion[$i]}.grd | sed 's/clp/dip/')

        [[ ! -s $depthfile ]] && echo "Slab depth file $depthfile is empty or does not exist"

        sample_grid_360 ${F_VOLC}volcanoes.dat $depthfile $strikefile $dipfile | grep -v NaN >>  ${F_VOLC}volcano_slab2.txt
      done
    fi
}


TECTOPLOT_MODULES+=("landscan")

# Plotting of Gridded Population of the World v 4

# UPDATED
# NEW OPTS

function tectoplot_defaults_landscan() {
    # Thicknesses are in points

    # Download of LANDSCAN requires a NASA EarthData login
    LANDSCAN_SOURCEURL="https://landscan.ornl.gov"
    LANDSCANDIR=${DATAROOT}"LandScanGlobal/"
    LANDSCANDATA=${LANDSCANDIR}"landscan-global-2021.nc"

    LANDSCAN_SOURCESTRING="Population density data from LandScan"
    LANDSCAN_SHORT_SOURCESTRING="LANDSCAN"
}

function tectoplot_args_landscan()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -landscan)

  tectoplot_get_opts_inline '
des -landscan plot population density from LandScan
opt lowcut m_landscan_lowcut float 0.1
    minimum population density; lower is transparent
opt cpt m_landscan_cpt string "hot"
    cpt to color the grid
opt trans m_landscan_trans float 0
    transparency
opt res m_landscan_res posinteger 150
    plotted grid resolution (dpi)
opt noplot m_landscan_noplot flag 0
    do not plot the population grid
' "${@}" || return

  plots+=("m_landscan")
  cpts+=("m_landscan")
  ;;
  esac
}

function tectoplot_calculate_landscan()  {
  LANDSCAN_PSSIZE_ALT=$(gawk -v size=${PSSIZE} -v minlon=${MINLON} -v maxlon=${MAXLON} -v minlat=${MINLAT} -v maxlat=${MAXLAT} '
    BEGIN {
      print size*(minlat-maxlat)/(minlon-maxlon)
    }')
}

function tectoplot_cpt_landscan()  {
  case $1 in
    m_landscan)
      gmt makecpt -C${m_landscan_cpt[$tt]} -T1/175000/1+l -Z -I --COLOR_BACKGROUND="white" --COLOR_FOREGROUND="white" --COLOR_NAN="white" > ${F_CPTS}landscan_${tt}.cpt
    ;;
  esac
}

function tectoplot_plot_landscan() {
  case $1 in
  m_landscan)

    RSTRING=$(echo ${RJSTRING} | gawk '{print $1}')

    landscan_rj+=("-R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}")
    landscan_rj+=("-JX${PSSIZE}i/${LANDSCAN_PSSIZE_ALT}id")

    gmt_init_tmpdir
    gmt grdclip ${LANDSCANDATA} -Sb${m_landscan_lowcut[$tt]}/NaN -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} ${VERBOSE} -Glandscan_${tt}.nc
    gmt grdimage landscan_${tt}.nc -E${m_landscan_res[$tt]} -C${F_CPTS}landscan_${tt}.cpt -t${m_landscan_trans[$tt]} -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} -Alandscan_image_${tt}.tif ${VERBOSE}
    gdal_edit.py -a_ullr ${MINLON} ${MAXLAT} ${MAXLON} ${MINLAT} landscan_image_${tt}.tif
    gmt_remove_tmpdir

    if [[ ${m_landscan_noplot[$tt]} -eq 0 ]]; then
      gmt grdimage landscan_${tt}.nc -E${m_landscan_res[$tt]} -C${F_CPTS}landscan_${tt}.cpt -Q -t${m_landscan_trans[$tt]} ${RJOK} ${VERBOSE} >> map.ps
      echo ${LANDSCAN_SOURCESTRING} >> ${LONGSOURCES}
      echo ${LANDSCAN_SHORT_SOURCESTRING} >> ${SHORTSOURCES}
    fi

    tectoplot_plot_caught=1
  ;;
  esac
}
#
# function tectoplot_legend_landscan() {
#   echo "Doing stereonet legend"
# }

function tectoplot_legendbar_landscan() {
  case $1 in
    m_landscan)
      echo "G 0.2i" >> ${LEGENDDIR}legendbars.txt
      echo "B ${F_CPTS}landscan_${tt}.cpt 0.2i ${LEGEND_BAR_HEIGHT}+malu ${LEGENDBAR_OPTS} -Q -Bxaf+l\"Population density (people/km^2)\"" >> ${LEGENDDIR}legendbars.txt
      barplotcount=$barplotcount+1
      tectoplot_caught_legendbar=1
    ;;
  esac
}

# function tectoplot_post_landscan() {
#   echo "no post"
# }

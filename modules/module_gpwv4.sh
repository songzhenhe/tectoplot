
TECTOPLOT_MODULES+=("gpwv4")

# Plotting of Gridded Population of the World v 4

# UPDATED

function tectoplot_defaults_gpwv4() {
    # Thicknesses are in points

    GPWV4DIR=${DATAROOT}"gpw-v4-population-density-rev11_2020_30_sec_nc/"
    GPWV4DATA=${GPWV4DIR}"gpw_v4_population_density_rev11_2020_30_sec.nc"

    GPWV4_SOURCESTRING="Population density data from Gridded Population of the World, Version 4 (GPWv4): Population Density, Revision 11,  https://doi.org/10.7927/H49C6VHW"
    GPWV4_SHORT_SOURCESTRING="GPWV4"
}

function tectoplot_args_gpwv4()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -popdens)

    cat <<-EOF > popdens
des -popdens plot river channels from GLORIC database
opt lowcut m_gpwv4_popdens_lowcut float 0
    minimum population density; lower is transparent
opt trans m_gpwv4_popdens_trans float 0
    transparency
opt res m_gpwv4_popdens_res posinteger 150
    plotted grid resolution (dpi)
opt noplot m_gmwv4_popdens_noplot flag 0
    do not plot the population grid
EOF

  if [[ $USAGEFLAG -eq 1 ]]; then
    tectoplot_usage_opts popdens
  else
    tectoplot_get_opts popdens "${@}"

    plots+=("m_gpwv4_popdens")
    cpts+=("m_gpwv4_popdens")

    tectoplot_module_caught=1
  fi
  ;;
  esac
}

function tectoplot_calculate_gpwv4()  {
  GPWV4_PSSIZE_ALT=$(gawk -v size=${PSSIZE} -v minlon=${MINLON} -v maxlon=${MAXLON} -v minlat=${MINLAT} -v maxlat=${MAXLAT} '
    BEGIN {
      print size*(minlat-maxlat)/(minlon-maxlon)
    }')
}



function tectoplot_cpt_gpwv4()  {
  case $1 in
    m_gpwv4_popdens)
      gmt makecpt -Chot -T1/175000/1+l -Z -I --COLOR_BACKGROUND="white" --COLOR_FOREGROUND="white" --COLOR_NAN="white" > ${F_CPTS}gpwv4_${tt}.cpt
    ;;
  esac
}


function tectoplot_plot_gpwv4() {
  case $1 in
  m_gpwv4_popdens)

    RSTRING=$(echo ${RJSTRING[@]} | gawk '{print $1}')

    gpwv4_rj+=("-R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}")
    gpwv4_rj+=("-JX${PSSIZE}i/${GPWV4_PSSIZE_ALT}id")

    gmt_init_tmpdir
    gmt grdclip ${GPWV4DATA} -Sb${m_gpwv4_popdens_lowcut[$tt]}/NaN -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} ${VERBOSE} -Gpopdens_${tt}.nc
    gmt grdimage popdens_${tt}.nc -E${m_gpwv4_popdens_res[$tt]} -C${F_CPTS}gpwv4_${tt}.cpt -t${m_gpwv4_popdens_trans[$tt]} -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} -Apopdensity_${tt}.tif ${VERBOSE}
    gdal_edit.py -a_ullr ${MINLON} ${MAXLAT} ${MAXLON} ${MINLAT} popdensity_${tt}.tif
    gmt_remove_tmpdir

    if [[ ${m_gpwv4_popdens_noplot[$tt]} -eq 0 ]]; then
      gmt grdimage popdens_${tt}.tif -E${m_gpwv4_popdens_res[$tt]} -C${F_CPTS}gpwv4_${tt}.cpt -Q -t${m_gpwv4_popdens_trans[$tt]} ${RJOK} ${VERBOSE} >> map.ps
      echo ${GPWV4_SOURCESTRING} >> ${LONGSOURCES}
      echo ${GPWV4_SHORT_SOURCESTRING} >> ${SHORTSOURCES}
    fi

    tectoplot_plot_caught=1
  ;;
  esac
}
#
# function tectoplot_legend_gpwv4() {
#   echo "Doing stereonet legend"
# }

function tectoplot_legendbar_gpwv4() {
  case $1 in
    m_gpwv4_popdens)
      echo "G 0.2i" >> ${LEGENDDIR}legendbars.txt
      echo "B ${F_CPTS}gpwv4_${tt}.cpt 0.2i ${LEGEND_BAR_HEIGHT}+malu ${LEGENDBAR_OPTS} -Q -Bxaf+l\"Population density (people/km^2)\"" >> ${LEGENDDIR}legendbars.txt
      barplotcount=$barplotcount+1
      tectoplot_caught_legendbar=1
    ;;
  esac
}

# function tectoplot_post_gpwv4() {
#   echo "no post"
# }

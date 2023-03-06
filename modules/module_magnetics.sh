
TECTOPLOT_MODULES+=("magnetics")

# NEW OPTS

function tectoplot_defaults_magnetics() {

  MAG_SOURCESTRING="Magnetic data from EMAG2_V2 (USGW), https://catalog.data.gov/dataset/emag2-earth-magnetic-anomaly-grid-2-arc-minute-resolution"
  MAG_SHORT_SOURCESTRING="EMAG2_V2"

  EMAG_V2_DIR=$DATAROOT"EMAG_V2/"
  EMAG_V2=$EMAG_V2_DIR"EMAG2_V2.tif"
  EMAG_V2_CPT=$EMAG_V2_DIR"EMAG2_V2.cpt"
  EMAG_V2_SOURCEURL="http://geomag.colorado.edu/images/EMAG2/EMAG2_V2.tif"
  EMAG_V2_CHECKFILE="EMAG2_V2.tif"

  F_MAG="./modules/magnetics/"

  MAG_CPT=${F_CPTS}"mag.cpt"
  DEF_MAG_CPT="vik"
}

function tectoplot_args_magnetics()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

    -m)
  tectoplot_get_opts_inline '
des -m plot EMAG2_V2 crustal magnetization
opt trans m_magnetics_trans float 0
    transparency
opt grad m_magnetics_nograd flag 0
    plot data gradient as dark/light shading
' "${@}" || return

  plots+=("m_magnetics")
  cpts+=("m_magnetics")
  ;;
  esac
}

function tectoplot_download_magnetics()  {

  check_and_download_dataset $EMAG_V2_SOURCEURL $EMAG_V2_DIR $EMAG_V2_CHECKFILE

}

function tectoplot_calculate_magnetics() {
  # Cut out and store the magnetics data
  # This makes a terrible hash of it (GMT 6.1.1):
  # gmt grdcut $EMAG_V2 -G${F_MAG}/mag.nc -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} ${VERBOSE}

  mkdir -p ${F_MAG}
  [[ ! -s ${F_MAG}crustal_magnetization.nc ]] && gdal_translate -projwin ${MINLON} ${MAXLAT} ${MAXLON} ${MINLAT} -of NetCDF $EMAG_V2 ${F_MAG}crustal_magnetization.nc
}

function tectoplot_cpt_magnetics() {
  case $1 in
  m_magnetics)
    touch $MAG_CPT
    MAG_CPT=$(abs_path $MAG_CPT)
    gmt makecpt -C${DEF_MAG_CPT} -Z -Do -T-250/250/1 $VERBOSE > $MAG_CPT
    tectoplot_cpt_caught=1
    ;;
  esac
}

function tectoplot_plot_magnetics() {

  case $1 in
  m_magnetics)
    local maggradcmd

    info_msg "[-m]: Plotting magnetic data"
    if [[ ${m_magnetics_grad[$tt]} == 1 ]]; then
      maggradcmd="-I+d"
    else
      maggradcmd=""
    fi
    gmt grdimage ${F_MAG}crustal_magnetization.nc ${maggradcmd} $GRID_PRINT_RES -C$MAG_CPT -t${m_magnetics_trans[$tt]} $RJOK -Q $VERBOSE >> map.ps

    echo $MAG_SOURCESTRING >> ${LONGSOURCES}
    echo $MAG_SHORT_SOURCESTRING >> ${SHORTSOURCES}

    tectoplot_plot_caught=1
    ;;
  esac

}

function tectoplot_legendbar_magnetics() {
  case $1 in
    magnetics)
      echo "G 0.2i" >>${LEGENDDIR}legendbars.txt
      echo "B $MAG_CPT 0.2i 0.1i+malu -Bxa100f50+l\"Magnetization (nT)\"" >>${LEGENDDIR}legendbars.txt
      barplotcount=$barplotcount+1
      tectoplot_caught_legendbar=1
    ;;
  esac
}

# function tectoplot_legend_magnetics() {
# }

# function tectoplot_post_magnetics() {
#   echo "none"
# }

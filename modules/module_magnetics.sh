
TECTOPLOT_MODULES+=("magnetics")

# Calculate residual grid by removing along-line average, using da-dt formulation
# Builtin support for gravity grids

# Variables needed:


function tectoplot_defaults_magnetics() {

  MAG_SOURCESTRING="Magnetic data from EMAG2_V2 (USGW), https://catalog.data.gov/dataset/emag2-earth-magnetic-anomaly-grid-2-arc-minute-resolution"
  MAG_SHORT_SOURCESTRING="EMAG2_V2"

  EMAG_V2_DIR=$DATAROOT"EMAG_V2/"
  EMAG_V2=$EMAG_V2_DIR"EMAG2_V2.tif"
  EMAG_V2_CPT=$EMAG_V2_DIR"EMAG2_V2.cpt"
  EMAG_V2_SOURCEURL="http://geomag.colorado.edu/images/EMAG2/EMAG2_V2.tif"
  EMAG_V2_BYTES="233388712"

  MAGTRANS=0
  F_MAG="./magnetics/"

  MAG_CPT=${F_CPTS}"mag.cpt"
  DEF_MAG_CPT="vik"

  MAGGRAD="-I+d"



}

function tectoplot_args_magnetics()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

    -m|--mag) # args: transparency%
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
modules/module_magnetics.sh
-m:            plot global crustal magnetization
-m [[transparency]] [[nograd]]

  Plots EMAG_V2 crustal magnetization.
  nograd: Don't plot gradient intensity

Example: Magnetization surrounding the East Pacific Rise
  tectoplot -r -95 -85 -45 -35 -m
--------------------------------------------------------------------------------
EOF

  fi
      shift

  		plotmag=1
  		if arg_is_positive_float $1; then
  			MAGTRANS="${1}"
  			shift
        ((tectoplot_module_shift++))
  		fi

      if [[ $1 == "nograd" ]]; then
        MAGGRAD=""
        shift
        ((tectoplot_module_shift++))
      fi

  		info_msg "[-m]: Magnetic data to plot is ${MAGMODEL}, transparency is ${MAGTRANS}"
  		plots+=("magnetics")
      cpts+=("magnetics")

      echo $MAG_SOURCESTRING >> ${LONGSOURCES}
      echo $MAG_SHORT_SOURCESTRING >> ${SHORTSOURCES}

      # Signal to tectoplot that the current command was processed by this module
      tectoplot_module_caught=1

  	  ;;

      # -magtile)
      # shift
      #
      # CUSTOMGRIDFILE=${F_MAG}"mag.tif"
      # plotcustomtopo=1
      # USE_SHADED_RELIEF_TOPTILE=1
      # tectoplot_module_caught=1

      # ;;

  esac
}

# We download the relevant data in the _calculate_ function as this is the first time we should
# be accessing the data itself.

function tectoplot_calculate_magnetics()  {

  [[ ! -d ${F_MAG} ]] && mkdir -p ${F_MAG}

  if [[ ! -s $EMAG_V2 ]]; then

    read -r -p "EMAG_V2 magnetic data not downloaded: download now? (enter for y) [y|n] " response

    case $response in
      Y|y|yes|"")
        if ! check_and_download_dataset "EMAG_V2" $EMAG_V2_SOURCEURL "no" $EMAG_V2_DIR $EMAG_V2 "none" $EMAG_V2_BYTES "none"; then
          info_msg "EMAG_V2 data could not be downloaded."
          return 0
        fi
      ;;
      N|n|*)
        return 0
      ;;
    esac
  fi

  # Cut out and store the magnetics data
  # This makes a terrible hash of it (GMT 6.1.1):
  # gmt grdcut $EMAG_V2 -G${F_MAG}/mag.nc -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} ${VERBOSE}

  # This works
  [[ ! -s ${F_MAG}mag.nc ]] && gdal_translate -projwin ${MINLON} ${MAXLAT} ${MAXLON} ${MINLAT} -of NetCDF $EMAG_V2 ${F_MAG}mag.nc > /dev/null 2>&1
}

function tectoplot_cpt_magnetics() {
  case $1 in
  magnetics)
    touch $MAG_CPT
    MAG_CPT=$(abs_path $MAG_CPT)
    gmt makecpt -C${DEF_MAG_CPT} -Z -Do -T-250/250/1 $VERBOSE > $MAG_CPT
    tectoplot_cpt_caught=1
    ;;
  esac
}

function tectoplot_plot_magnetics() {
  case $1 in
  magnetics)
    info_msg "Plotting magnetic data"
    gmt grdimage ${F_MAG}mag.nc $GRID_PRINT_RES $MAGGRAD -C$MAG_CPT -t$MAGTRANS $RJOK -Q $VERBOSE >> map.ps
  #   [[ ! -s ${F_MAG}mag.tif ]] && gmt grdimage ${F_MAG}mag.nc $MAGGRAD -C$MAG_CPT -t$MAGTRANS -A${F_MAG}mag.tif -R -J
  # echo out
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

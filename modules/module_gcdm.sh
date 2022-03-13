
TECTOPLOT_MODULES+=("gcdm")

# Calculate residual grid by removing along-line average, using da-dt formulation
# Builtin support for gravity grids

# Variables needed:


function tectoplot_defaults_gcdm() {

  GCDM_SOURCESTRING="Global Curie Depth Map, Li et al., 2017, doi:10.1038/srep45129"
  GCDM_SHORT_SOURCESTRING="GCDM"

  GCDMDIR=$DATAROOT"GCDM/"
  GCDMDATA=$GCDMDIR"GCDM.nc"
  GCDMDATA_ORIG=$GCDMDIR"gcdm.txt"
  GCDM_SOURCEURL="https://static-content.springer.com/esm/art%3A10.1038%2Fsrep45129/MediaObjects/41598_2017_BFsrep45129_MOESM71_ESM.txt"
  GCDM_BYTES="123810173"

  GCDM_CPT=${F_CPTS}"gcdm.cpt"

}

function tectoplot_args_gcdm()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -gcdm)

  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
modules/module_gcdm.sh
-gcdm:         plot Global Curie Depth Map
-gcdm

  Data are from Li et al., 2017
  The Curie depth is the depth at which magnetic minerals lose their permanent
  remanence and is sensitive to both mineral composition and temperature.

Example: Plot GCDM of Greece and Turkey
  tectoplot -r GR,TR -gcdm -a f -acb
--------------------------------------------------------------------------------
EOF
  fi

      shift

      plots+=("gcdm")
      cpts+=("gcdm")

      echo $GCDM_SHORT_SOURCESTRING >> ${SHORTSOURCES}
      echo $GCDM_SOURCESTRING >> ${LONGSOURCES}

      # Signal to tectoplot that the current command was processed by this module
      tectoplot_module_caught=1

  	  ;;

  esac
}

# We download the relevant data in the _calculate_ function as this is the first time we should
# be accessing the data itself.

function tectoplot_calculate_gcdm()  {

  if [[ ! -s $GCDMDATA ]]; then

    read -r -p "GCDM data not downloaded: download now? (enter for y) [y|n] " response

    case $response in
      Y|y|yes|"")
        if ! check_and_download_dataset "GlobalCurieDepthMap" $GCDM_SOURCEURL "no" $GCDMDIR $GCDMDATA_ORIG "none" $GCDM_BYTES "none"; then
          info_msg "GCDM data could not be downloaded."
          return 0
        fi
      ;;
      N|n|*)
        return 0
      ;;
    esac
  fi

}

function tectoplot_cpt_gcdm() {
  gmt makecpt -Cseis -T$GCDMMIN/$GCDMMAX -Z ${VERBOSE} > $GCDM_CPT
}

function tectoplot_plot_gcdm() {
  case $1 in
    gcdm)
      gmt grdimage $GCDMDATA $GRID_PRINT_RES -C$GCDM_CPT $RJOK $VERBOSE >> map.ps
      tectoplot_plot_caught=1
    ;;
  esac
}

function tectoplot_legendbar_gcdm() {
  case $1 in
  gcdm)
    echo "G 0.2i" >> ${LEGENDDIR}legendbars.txt
    echo "B $GCDM_CPT 0.2i 0.1i+malu -Bxa10f2+l\"Curie Depth (km)\"" >> ${LEGENDDIR}legendbars.txt
    barplotcount=$barplotcount+1
    tectoplot_legendbar_caught=1
    ;;
  esac
}

# function tectoplot_legend_gcdm() {
# }

# function tectoplot_post_gcdm() {
#   echo "none"
# }

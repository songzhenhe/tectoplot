
TECTOPLOT_MODULES+=("gcdm")

# UPDATED


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
  cat <<-EOF > gcdm
des -gcdm plot gridded earthquake slip model (or any grid...) with clipping
opt cpt m_gcdm_cpt cpt "seis"
    CPT used to color grid
EOF

  if [[ $USAGEFLAG -eq 1 ]]; then
    tectoplot_usage_opts gcdm
  else
    tectoplot_get_opts gcdm "${@}"

    plots+=("m_gcdm")
    cpts+=("m_gcdm")

    # Signal to tectoplot that the current command was processed by this module
    tectoplot_module_caught=1
  fi
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
  case $1 in
    m_gcdm)
      gmt makecpt -C${m_gcdm_cpt[$tt]} -T$GCDMMIN/$GCDMMAX -Z ${VERBOSE} > ${F_CPTS}gcdm_${tt}.cpt
    ;;
  esac
}

function tectoplot_plot_gcdm() {

  case $1 in
    m_gcdm)
      gmt grdimage ${GCDMDATA} $GRID_PRINT_RES -C${F_CPTS}gcdm_${tt}.cpt $RJOK $VERBOSE >> map.ps

      echo $GCDM_SHORT_SOURCESTRING >> ${SHORTSOURCES}
      echo $GCDM_SOURCESTRING >> ${LONGSOURCES}

      tectoplot_plot_caught=1
    ;;
  esac
}

function tectoplot_legendbar_gcdm() {
  case $1 in
    m_gcdm)
      echo "G 0.2i" >> ${LEGENDDIR}legendbars.txt
      echo "B ${F_CPTS}gcdm_${tt}.cpt 0.2i 0.1i+malu -Bxa10f2+l\"Curie Depth (km)\"" >> ${LEGENDDIR}legendbars.txt
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

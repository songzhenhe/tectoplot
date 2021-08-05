
TECTOPLOT_MODULES+=("gsrm")

# Plotting of Global Strain Rate Model data (Kreemer et al., 2014)
# Source data is distributed with tectoplot under platemodels/GSRM/

# Variables expected:
# GSRMDATA = full path to GSRM data file

function tectoplot_args_gsrm()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -gsrm)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
modules/module_gsrm.sh
-gsrm:     plot Global Strain Rate Model data from Kreemer et al., (2014)
-gsrm

Example: None
--------------------------------------------------------------------------------
EOF
fi

    plots+=("gsrm")

    tectoplot_module_shift=0
    tectoplot_module_caught=1
    ;;
  esac
}

# function tectoplot_calculate_gsrm()  {
#   echo "Doing stereonet calculations"
# }
#
function tectoplot_plot_gsrm() {
  gmt makecpt -Cturbo -T-2/12/0.01 > ${F_CPTS}gsrm.cpt
  gawk < ${GSRMDATA} '
  function abs(v) { return (v>0)?v:-v }
  ($1+0==$1) {
    print $2, $1, log(abs($3*$4)) # -$5*$5
  }' | gmt xyz2grd -I0.25d -Ggsrm.nc -R -J ${VERBOSE}
  # echo gmt psxy ${GSRMDATA} -i1,0,11 -Sc0.01i -W+cf -C${F_CPTS}gsrm.cpt ${RJOK}
  # gmt psxy ${GSRMDATA} -i1,0,11 -Sc0.01i -W+cf -C${F_CPTS}gsrm.cpt ${RJOK} >> map.ps
  gmt grdimage gsrm.nc -C${F_CPTS}gsrm.cpt -Q ${RJOK} ${VERBOSE} >> map.ps
  echo "GSRM plot"
}
#
# function tectoplot_legend_gsrm() {
#   echo "Doing stereonet legend"
# }

# function tectoplot_post_gsrm() {
#   echo "no post"
# }

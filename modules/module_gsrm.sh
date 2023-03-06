
TECTOPLOT_MODULES+=("gsrm")

# Plotting of Global Strain Rate Model data (Kreemer et al., 2014)
# Source data is distributed with tectoplot under platemodels/GSRM/

# Variables expected:
# GSRMDATA = full path to GSRM data file
# NEW OPTS

function tectoplot_args_gsrm()  {
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  case "${1}" in

  -gsrm)
  tectoplot_get_opts_inline '
des -gsrm plot Global Strain Rate Map raster
exa tectoplot -r FR -gsrm -a
' "${@}" || return

  plots+=("m_gsrm_plot")
  ;;

  esac
}

# function tectoplot_calculate_gsrm()  {
# }

function tectoplot_plot_gsrm() {

  case $1 in
  m_gsrm_plot)
    mkdir -p ./modules/gsrm/
    gmt makecpt -Cturbo -T-0.1/5/0.01 > ${F_CPTS}gsrm.cpt
    gmt_init_tmpdir
    gawk < ${GSRMDATA} '
    function abs(v) { return (v>0)?v:-v }
    ($1+0==$1 && $3!=0 && $4!=0) {
      print $2, $1, log(abs($3*$4))/log(10) # -$5*$5
    }' > ./modules/gsrm/gsrm.dat
    cat ./modules/gsrm/gsrm.dat | gmt nearneighbor -S2d -I0.5d -G./modules/gsrm/gsrm.nc -R-180/180/-90/90 ${VERBOSE}
  # }' | gmt xyz2grd -I1d -Ggsrm.nc -R -J ${VERBOSE}
    # echo gmt psxy ${GSRMDATA} -i1,0,11 -Sc0.01i -W+cf -C${F_CPTS}gsrm.cpt ${RJOK}
    # gmt psxy ${GSRMDATA} -i1,0,11 -Sc0.01i -W+cf -C${F_CPTS}gsrm.cpt ${RJOK} >> map.ps
    gmt_remove_tmpdir

    gmt grdimage ./modules/gsrm/gsrm.nc -C${F_CPTS}gsrm.cpt -Q ${RJOK} ${VERBOSE} >> map.ps

    tectoplot_plot_caught=1
  ;;
  esac
}
#
# function tectoplot_legend_gsrm() {
#   echo "Doing stereonet legend"
# }

function tectoplot_legendbar_gsrm() {
  case $1 in
    gsrm)
      echo "G 0.2i" >>${LEGENDDIR}legendbars.txt
      echo "B ${F_CPTS}gsrm.cpt 0.2i 0.1i+malu -Bxaf+l\"log10(second invariant of strain rate)\"" >>${LEGENDDIR}legendbars.txt
      barplotcount=$barplotcount+1
      tectoplot_caught_legendbar=1
    ;;
  esac
}

# function tectoplot_post_gsrm() {
#   echo "no post"
# }

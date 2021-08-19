
TECTOPLOT_MODULES+=("eqslip")

# Calculate residual grid by removing along-line average, using da-dt formulation
# Builtin support for gravity grids

# Variables needed:
# GRID_PRINT_RES
# GRAVCPT

function tectoplot_defaults_eqslip() {
  EQSLIPTRANS=50
}

function tectoplot_args_eqslip()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

    -eqslip)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-eqslip:       plot gridded earthquake slip model (or any grid...) with clipping
-eqslip [gridfile] [clippath]

  Plot colored grid of slip model, contoured, and masked by clip path.
  Multiple calls to -eqslip can be made and they will plot in the order
  specified. Clipping files are XY (LON LAT) polygons.

Example: (no data files are provided yet... hypothetical example)
  tectoplot -r IN -t -eqslip slip1.grd clip1.xy slip2.grd clip2.xy
--------------------------------------------------------------------------------
EOF
  fi

    shift

    if arg_is_flag $1; then
      info_msg "[-eqslip]: grid file and clip path required"
    else
      numeqslip=0
      while : ; do
        arg_is_flag $1 && break
        numeqslip=$(echo "$numeqslip + 1" | bc)
        E_GRDLIST[$numeqslip]=$(abs_path "${1}")
        E_CLIPLIST[$numeqslip]=$(abs_path "${2}")
        shift
        ((tectoplot_module_shift++))
        shift
        ((tectoplot_module_shift++))
      done
    fi

    plots+=("eqslip")
    cpts+=("eqslip")

    tectoplot_module_caught=1
    ;;
  esac
}

# tectoplot_cpts_eqslip() {
#
# }

# function tectoplot_calculate_eqslip()  {
# }

function tectoplot_cpt_eqslip() {
    gmt makecpt -T10/500/10 -Clajolla -Z ${VERBOSE} > ${F_CPTS}slip.cpt
}

function tectoplot_plot_eqslip() {

  case $1 in

  eqslip)
    # Find the maximum slip value in the submitted grid files
    cur_zmax=0
    for eqindex in $(seq 1 $numeqslip); do
      zrange=($(grid_zrange ${E_GRDLIST[$eqindex]} -C -Vn))
      cur_zmax=$(echo ${zrange[1]} $cur_zmax | gawk '{print ($1>$2)?$1:$2}')
    done

    for eqindex in $(seq 1 $numeqslip); do
      gmt grdclip ${E_GRDLIST[$eqindex]} -Sb10/NaN -Geqslip_${eqindex}.grd ${VERBOSE}
      gmt psclip ${E_CLIPLIST[$eqindex]} $RJOK ${VERBOSE} >> map.ps
      gmt grdimage -C${F_CPTS}slip.cpt eqslip_${eqindex}.grd -t${EQSLIPTRANS} -Q $RJOK ${VERBOSE} >> map.ps
      gmt grdcontour eqslip_${eqindex}.grd -S3 -C50 -L50/${cur_zmax} -W0.35p,black  $RJOK ${VERBOSE} >> map.ps
      gmt psxy ${E_CLIPLIST[$eqindex]} -W0.2p,black,- ${RJOK} ${VERBOSE} >> map.ps
      gmt psclip -C $RJOK ${VERBOSE} >> map.ps
    done
    tectoplot_plot_caught=1
    ;;
  esac

}

# function tectoplot_legend_eqslip() {
#   echo "none"
# }

# function tectoplot_legendbar_eqslip() {
#   echo "none"
# }


# function tectoplot_post_eqslip() {
#   echo "none"
# }


TECTOPLOT_MODULES+=("slab2")

# Calculate residual grid by removing along-line average, using da-dt formulation
# Builtin support for gravity grids

# Variables needed:


function tectoplot_defaults_slab2() {

  ##### SLAB2.0
  SLAB2_SOURCESTRING="Slab geometries from Slab 2.0, Hayes et al. 2018, doi:10.1126/science.aat4723"
  SLAB2_SHORT_SOURCESTRING="SLAB2"

  SLAB2_DATADIR=$DATAROOT"SLAB2/"
  SLAB2_SOURCEURL="https://www.sciencebase.gov/catalog/file/get/5aa1b00ee4b0b1c392e86467"
  SLAB2_CHECKFILE=$SLAB2_DATADIR"Slab2Distribute_Mar2018.tar.gz"
  SLAB2_CHECK_BYTES="140213438"
  SLAB2_ZIP_BYTES="93730583"

  SLAB2DIR=$SLAB2_DATADIR"Slab2Distribute_Mar2018/"
  SLAB2_CLIPDIR=$SLAB2DIR"Slab2Clips/"
  SLAB2_CONTOURDIR=$SLAB2DIR"Slab2_CONTOURS/"
  SLAB2_GRIDDIR=$SLAB2DIR

  SLAB2STR="c"

}

function tectoplot_args_slab2()  {

  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -b|--slab2) # args: none || strong
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-b:            plot slab2.0 data
-b [[commandstring=${SLAB2STR}]]
  If commandstring contains 'c', plot Slab2.0 depth contours
  In the future, this option will implement depth grids, strike grids, etc.

Example: Plot Slab2.0 around Japan
  tectoplot -r JP -b -a
--------------------------------------------------------------------------------
EOF
  fi

    shift
		if arg_is_flag $1; then
			info_msg "[-b]: Slab2 control string not specified. Using c"
		else
			SLAB2STR="${1}"
			shift
      ((tectoplot_module_shift++))
		fi
    plotslab2=1

		plots+=("slab2")
    cpts+=("seisdepth")
    legendbarwords+=("slab2")


    makeplyslab2meshflag=1
    echo $SLAB2_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $SLAB2_SOURCESTRING >> ${LONGSOURCES}

    tectoplot_module_caught=1
    ;;

  esac
}

# We download the relevant data in the _calculate_ function as this is the first time we should
# be accessing the data itself.

# function tectoplot_calculate_slab2()  {
#
# }

function tectoplot_cpt_slab2() {
  touch $FAULTSLIP_CPT
  FAULTSLIP_CPT=$(abs_path $FAULTSLIP_CPT)
  gmt makecpt -Chot -I -Do -T$SLIPMINIMUM/$SLIPMAXIMUM/0.1 -N $VERBOSE > $FAULTSLIP_CPT
}

function tectoplot_plot_slab2() {

  case $1 in

  slab2)

    if [[ ${SLAB2STR} =~ .*d.* ]]; then
      info_msg "Plotting SLAB2 depth grids"
      SLAB2_CONTOUR_BLACK=1
      for i in $(seq 1 $numslab2inregion); do
        gridfile=$(echo ${SLAB2_GRIDDIR}${slab2inregion[$i]}.grd | sed 's/clp/dep/')
        if [[ -e $gridfile ]]; then
          gmt grdmath ${VERBOSE} $gridfile -1 MUL = tmpgrd.grd
          gmt grdimage tmpgrd.grd -Q -t${SLAB2GRID_TRANS} -C$SEISDEPTH_CPT $RJOK $VERBOSE >> map.ps
          rm -f tmpgrd.grd
        fi
      done
    else
      SLAB2_CONTOUR_BLACK=0
    fi

		if [[ ${SLAB2STR} =~ .*c.* ]]; then
			info_msg "Plotting SLAB2 contours"
      for i in $(seq 1 $numslab2inregion); do
        contourfile=$(echo ${SLAB2_CONTOURDIR}${slab2inregion[$i]}_contours.in | sed 's/clp/dep/')
        if [[ -s $contourfile ]]; then
          gawk < $contourfile '{
            if ($1 == ">") {
              print $1, "-Z" 0-$2
            } else {
              print $1, $2, 0 - $3
            }
          }' > contourtmp.dat
          if [[ -s contourtmp.dat ]]; then
            if [[ $SLAB2_CONTOUR_BLACK -eq 0 ]]; then
              gmt psxy contourtmp.dat -C$SEISDEPTH_CPT -W0.5p+z $RJOK $VERBOSE >> map.ps
            else
              gmt psxy contourtmp.dat -W0.5p,black+z $RJOK $VERBOSE >> map.ps
            fi
          fi
        fi
      done
      rm -f contourtmp.dat
		fi

    tectoplot_plot_caught=1
    ;;
  esac

}

# function tectoplot_legendbar_slab2() {
# }

function tectoplot_legendbar_slab2() {
  case $1 in
    slab2)
    # Don't plot a color bar if we already have plotted one OR the seis CPT is a solid color
    if [[ $plottedneiscptflag -eq 0 && ! $seisfillcolorflag -eq 1 ]]; then
      plottedneiscptflag=1
      echo "G 0.2i" >> legendbars.txt
      echo "B $SEISDEPTH_NODEEPEST_CPT 0.2i 0.1i+malu+e -Bxaf+l\"Earthquake / slab depth (km)\"" >> legendbars.txt
      barplotcount=$barplotcount+1
    fi
    tectoplot_caught_legendbar=1
    ;;
  esac
}


# function tectoplot_legend_slab2() {
# }

# function tectoplot_post_slab2() {
# }

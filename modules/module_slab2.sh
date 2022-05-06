
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

  SLAB2_CPT=${F_CPTS}slab2depth.cpt

  SLAB2STR="c"
}

function tectoplot_args_slab2()  {

  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -b) # args: none || strong
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-b:            Load and visualize slab2.0 data
-b [[commandstring=${SLAB2STR}]] [[slabID1 slabID2 ...]]
  If commandstring contains 'c', plot Slab2.0 depth contours
  In the future, this option will implement depth grids, strike grids, etc.

  If slabIDs are specified, restrict selection to specified slabs

  slab list:
  alu cal cam car cas cot hal hel him hin izu ker kur mak man mue pam phi png
  puy ryu sam sco sol sul sum van

Example: Plot Slab2.0 around Japan
  tectoplot -r JP -b -a
--------------------------------------------------------------------------------
EOF
  fi

    shift
		# if arg_is_flag $1; then
		# 	info_msg "[-b]: Slab2 control string not specified. Using c"
		# else
		# 	SLAB2STR="${1}"
		# 	shift
    #   ((tectoplot_module_shift++))
		# fi

    slab2list=" alu cal cam car cas cot hal hel him hin izu ker kur mak man mue pam phi png
    puy ryu sam sco sol sul sum van "

    while ! arg_is_flag $1; do
      if [[ " ${slab2list} " =~ " ${1} " ]]; then
        SLAB2SELECT+=("$1")
        slab2selectflag=1
    # whatever you want to do when array contains value
      else
        echo "[-b]: SlabID $1 not recognized. Run tectoplot -usage -b for a list"
        exit 1
      fi
      shift
      ((tectoplot_module_shift++))
    done

    plotslab2=1

		plots+=("slab2")
    cpts+=("slab2")
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
  touch $SLAB2_CPT
  SLAB2_CPT=$(abs_path $SLAB2_CPT)

  gmt makecpt -Fr -C${SEIS_CPT} ${SEIS_CPT_INV} > ${F_CPTS}origseis.cpt
  gmt makecpt -N -C${SEIS_CPT} ${SEIS_CPT_INV} -Fr -Do -T"${EQMINDEPTH_COLORSCALE}"/"${EQMAXDEPTH_COLORSCALE}"/1 -Z $VERBOSE > $SLAB2_CPT

  CPTBOUNDS=($(gawk < $SLAB2_CPT '
  BEGIN {
    hasfirst=0
  }
  ($1+0==$1) {
    if (hasfirst==0) {
      hasfirst=1
      firstval=$1
      firstrgb=$2
    }
    lastrgb=$2
    if ($3+0==$3) {
      lastval=$3
      lastrgb=$4
    }
  }
  END {
    print firstval, firstrgb, lastval, lastrgb
  }'))

  # echo CPT bounds ${CPTBOUNDS[@]}

  # This needs to be customized!
  # echo "${CPTBOUNDS[2]}	${CPTBOUNDS[3]}	6370	${CPTBOUNDS[3]}" >> $SLAB2_CPT
  # echo "B	${CPTBOUNDS[1]}" >> $SLAB2_CPT
  # echo "F	${CPTBOUNDS[3]}" >> $SLAB2_CPT
  # echo "N	127.5" >> $SLAB2_CPT
  echo "B	${CPTBOUNDS[1]}" >>  $SLAB2_CPT
  echo "F	${CPTBOUNDS[3]}" >>  $SLAB2_CPT
  echo "N	127.5" >>  $SLAB2_CPT
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
          gmt grdimage tmpgrd.grd -Q -t${SLAB2GRID_TRANS} -C$SLAB2_CPT $RJOK $VERBOSE >> map.ps
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
              gmt psxy contourtmp.dat -C$SLAB2_CPT -W0.5p+z $RJOK $VERBOSE >> map.ps
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

    # we plot the slab2 depth colorbar under these conditions:
    # Earthquakes are plotted and colored by zctime or zccluster or zfill: YES
    # Earthquakes are colored by depth and we have not already plotted the bar: MERGED
    # We are not plotting earthquakes at all: SOLO
    [[ $slab2barplotflag -eq 1 ]] && return
    slab2barplotflag=1

    # Figure out if we are plotting seis
    areweplottingseisflag=0
    for thisplot in ${plots[@]}; do
      if [[ $thisplot == "seis" || $thisplot == "cmt" ]]; then
        areweplottingseisflag=1
        break
      fi
    done

    if [[ $areweplottingseisflag -eq 0 ]]; then
      slab2bartype="solo"
    else
      # Plotting either earthquakes or CMT
      if [[ $zctimeflag -eq 1 || $zcclusterflag -eq 1 || $seisfillcolorflag -eq 1 ]]; then
        slab2bartype="solo"
      else
        if [[ $plottedneiscptflag -eq 1 ]]; then
          # We already plotted the depth bar in the call to seis)
          slab2bartype="none"
        else
          slab2bartype="merged"
        fi
      fi
    fi


    case ${slab2bartype} in
       solo)
        plottedneiscptflag=1
        echo "G 0.2i" >>${LEGENDDIR}legendbars.txt
        echo "B $SLAB2_CPT 0.2i 0.1i+malu+e ${LEGENDBAR_OPTS} -Bxaf+l\"Slab 2.0 plate interface depth (km)\"" >>${LEGENDDIR}legendbars.txt
        barplotcount=$barplotcount+1
       ;;
       merged)
        plottedneiscptflag=1
        echo "G 0.2i" >>${LEGENDDIR}legendbars.txt
        echo "B $SLAB2_CPT 0.2i 0.1i+malu+e ${LEGENDBAR_OPTS} -Bxaf+l\"Earthquake/Slab 2.0 depth (km)\"" >>${LEGENDDIR}legendbars.txt
        barplotcount=$barplotcount+1
       ;;
    esac

    tectoplot_caught_legendbar=1
    ;;
  esac
}


# function tectoplot_legend_slab2() {
# }

# function tectoplot_post_slab2() {
# }

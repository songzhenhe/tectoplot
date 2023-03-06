
TECTOPLOT_MODULES+=("slab2")

# UPDATED
# NEW OPTS
# DOWNLOAD

# /catalog/file/get/5aa1b00ee4b0b1c392e86467?f=__disk__d5%2F91%2F39%2Fd591399bf4f249ab49ffec8a366e5070fe96e0ba

function tectoplot_defaults_slab2() {
  ##### SLAB2.0
  SLAB2_SOURCESTRING="Slab geometries from Slab 2.0, Hayes et al. 2018, doi:10.1126/science.aat4723"
  SLAB2_SHORT_SOURCESTRING="SLAB2"

  SLAB2_DATADIR=${DATAROOT}"SLAB2/"
  SLAB2_SOURCEURL="https://www.sciencebase.gov/catalog/file/get/5aa1b00ee4b0b1c392e86467?f=__disk__d5%2F91%2F39%2Fd591399bf4f249ab49ffec8a366e5070fe96e0ba"
  SLAB2_ALTNAME="Slab2Distribute_Mar2018.tar.gz"
  SLAB2_CHECKFILE="Slab2Distribute_Mar2018/alu_slab2_dep_02.23.18.grd"

  SLAB2DIR="${SLAB2_DATADIR}Slab2Distribute_Mar2018/"
  SLAB2_CLIPDIR="${SLAB2DIR}Slab2Clips/"
  SLAB2_CONTOURDIR="${SLAB2DIR}Slab2_CONTOURS/"
  SLAB2_GRIDDIR=$SLAB2DIR
}

function tectoplot_args_slab2()  {

  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -b) # args: none || strong
  tectoplot_get_opts_inline '
des -b Plot cumulative frequency number distribution of seismicity
opt type m_slab2_type string "depth"
  select data type to plot: depth | strike | dip
opt grid m_slab2_grid flag 0
  plot image of selected grid type
opt contour m_slab2_contour flag 1
  contour the selected grid type
opt select m_slab2_list list ""
  plot only slabs with specified slab2 IDs
opt line m_slab2_line string ""
  plot slab contours without CPT
opt width m_slab2_linewidth string "0.5p"
  line width
mes slab2.0 ID list:
mes alu cal cam car cas cot hal hel him hin izu ker kur mak man mue pam phi png
mes puy ryu sam sco sol sul sum van
exa tectoplot -b
' "${@}" || return

  plotslab2=1

  plots+=("m_slab2")
  cpts+=("m_slab2")
  cpts+=("seisdepth")

  legendbarwords+=("m_slab2")

  makeplyslab2meshflag=1
  ;;

  esac
}

function tectoplot_download_slab2() {

  # Provide an altname as the URL does not contain the ZIP file name
  check_and_download_dataset "${SLAB2_SOURCEURL}" "${SLAB2_DATADIR}" "${SLAB2_CHECKFILE}" "${SLAB2_ALTNAME}"

}

# function tectoplot_calculate_slab2()  {
#
# }

function tectoplot_cpt_slab2() {
  case $1 in
    m_slab2)
      # Currently only makes depth CPT
      case ${m_slab2_type[$tt]} in
        depth)
          gmt makecpt -Fr -C${SEIS_CPT} ${SEIS_CPT_INV} > ${F_CPTS}origseis.cpt
          gmt makecpt -N -C${SEIS_CPT} ${SEIS_CPT_INV} -Fr -Do -T"${EQMINDEPTH_COLORSCALE}"/"${EQMAXDEPTH_COLORSCALE}"/1 -Z ${VERBOSE} > ${F_CPTS}slab2depth.cpt
          SLAB2_CPT=${F_CPTS}slab2depth.cpt
        ;;
        strike)
        echo making strike cPT
          gmt makecpt -Ccyclic -T0/360/1 > ${F_CPTS}slab2strike.cpt
          SLAB2_CPT=${F_CPTS}slab2strike.cpt
        ;;
        dip)
        gmt makecpt -Cturbo -T0/90/1 > ${F_CPTS}slab2dip.cpt
        SLAB2_CPT=${F_CPTS}slab2dip.cpt
        ;;
      esac

      CPTBOUNDS=($(gawk < ${SLAB2_CPT} '
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

      echo "B	${CPTBOUNDS[1]}" >>  ${SLAB2_CPT}
      echo "F	${CPTBOUNDS[3]}" >>  ${SLAB2_CPT}
      echo "N	127.5" >>  ${SLAB2_CPT}

      tectoplot_cpt_caught=1
    ;;
  esac
}

function tectoplot_plot_slab2() {

  case $1 in

  m_slab2)

    if [[ $numslab2inregion -gt 0 ]]; then
      echo $SLAB2_SHORT_SOURCESTRING >> ${SHORTSOURCES}
      echo $SLAB2_SOURCESTRING >> ${LONGSOURCES}
    fi

    case ${m_slab2_type[$tt]} in
      depth)
        m_slab2_code[$tt]="dep"
        m_slab2_label[$tt]="Slab 2.0 plate interface depth (km)"
      ;;
      strike)
        m_slab2_code[$tt]="str"
        m_slab2_label[$tt]="Slab 2.0 plate interface strike (degrees)"
      ;;
      dip)
        m_slab2_code[$tt]="dip"
        m_slab2_label[$tt]="Slab 2.0 plate interface dip (degrees)"
      ;;
    esac

    if [[ ${m_slab2_grid[$tt]} -eq 1 ]]; then
      for i in $(seq 1 $numslab2inregion); do
        m_slab2_gridfile=$(echo "${SLAB2_GRIDDIR}${slab2inregion[$i]}.grd" | sed "s/clp/${m_slab2_code[$tt]}/")
        if [[ -s ${m_slab2_gridfile} ]]; then
          if [[ ${m_slab2_code[$tt]} == "dep" ]]; then
            gmt grdmath ${VERBOSE} ${m_slab2_gridfile} -1 MUL = tmpgrd.grd
            gmt grdimage tmpgrd.grd -Q -t${SLAB2GRID_TRANS} -C${SLAB2_CPT} ${RJOK} ${VERBOSE} >> map.ps
            rm -f tmpgrd.grd
          else
            gmt grdimage ${m_slab2_gridfile} -Q -t${SLAB2GRID_TRANS} -C${SLAB2_CPT} ${RJOK} ${VERBOSE} >> map.ps
          fi
        fi
      done
    fi

		if [[ ${m_slab2_contour[$tt]} -eq 1 ]]; then
      for i in $(seq 1 $numslab2inregion); do
        m_slab2_contourfile=$(echo "${SLAB2_CONTOURDIR}${slab2inregion[$i]}_contours.in" | sed "s/clp/${m_slab2_code[$tt]}/")
        if [[ -s "${m_slab2_contourfile}" ]]; then
          if [[ ${m_slab2_code[$tt]} == "dep" && -s $m_slab2_contourfile ]]; then
            gawk < "${m_slab2_contourfile}" '{
              if ($1 == ">") {
                print $1, "-Z" 0-$2
              } else {
                print $1, $2, 0 - $3
              }
            }' > contourtmp.dat
          else
            cp "${m_slab2_contourfile}" contourtmp.dat
          fi

          if [[ -s contourtmp.dat ]]; then
            # If coloring by CPT, do so. Otherwise, plot with specified line symbol.
            if [[ -z ${m_slab2_line[$tt]} ]]; then
              gmt psxy contourtmp.dat -C${SLAB2_CPT} -W${m_slab2_linewidth[$tt]}+z ${RJOK} ${VERBOSE} >> map.ps
            else
              gmt psxy contourtmp.dat -W${m_slab2_line[$tt]} ${RJOK} ${VERBOSE} >> map.ps
            fi
          fi
        else
          echo "Can't find contour file "
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
    m_slab2)

    # we plot the slab2 depth colorbar under these conditions:
    # Earthquakes are plotted and colored by zctime or zccluster or zfill: YES
    # Earthquakes are colored by depth and we have not already plotted the bar: MERGED
    # We are not plotting earthquakes at all: SOLO
    [[ $slab2barplotflag -eq 1 ]] && return
    slab2barplotflag=1

    # Figure out if we are plotting seismicity as well
    areweplottingseisflag=0
    if [[ ${m_slab2_code[$tt]} == "dep" ]]; then
      for thisplot in ${plots[@]}; do
        if [[ $thisplot == "seis" || $thisplot == "cmt" ]]; then
          areweplottingseisflag=1
          break
        fi
      done
    fi

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
        echo "B ${SLAB2_CPT} 0.2i 0.1i+malu+e ${LEGENDBAR_OPTS} -Bxaf+l\"${m_slab2_label[$tt]}\"" >>${LEGENDDIR}legendbars.txt
        barplotcount=$barplotcount+1
       ;;
       merged)
        plottedneiscptflag=1
        echo "G 0.2i" >>${LEGENDDIR}legendbars.txt
        echo "B ${SLAB2_CPT} 0.2i 0.1i+malu+e ${LEGENDBAR_OPTS} -Bxaf+l\"Depth (km)\"" >>${LEGENDDIR}legendbars.txt
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

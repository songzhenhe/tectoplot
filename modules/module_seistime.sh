
TECTOPLOT_MODULES+=("seistime")

# EXPECTS THESE VARIABLES TO BE SET
# zcclusterflag : flag to plot colors by cluster ID
# SEIS_CPT      : CPT for plotting seismicity

function tectoplot_defaults_seistime() {
  SEISTIME_H_SIZE="7i"
  SEISTIME_V_SIZE="2i"
}


function tectoplot_args_seistime()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in
  -seistime)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
modules/module_seistime.sh
-seistime:     create a seismicity vs. time plot, colored by depth OR cluster
-seistime

  plotdim [h_inch] [v_inch]             Set dimension of plot
  magrange [min_mag] [max_mag]          Use fixed magnitude range
  timerange [min_time] [max_time]       Use fixed time range


  Output is seistime.pdf
  fixscale: use fixed 0 to 10 magnitude scale

Example: None
--------------------------------------------------------------------------------
EOF
fi
    shift

    while ! arg_is_flag "${1}"; do
      case "${1}" in
        onmap)
          shift
          ((tectoplot_module_shift++))
          seistime_onmap=1
        ;;
        plotdim)
          shift
          ((tectoplot_module_shift++))

          if ! arg_is_flag "${1}"; then
            SEISTIME_H_SIZE="${1}"
            shift
            ((tectoplot_module_shift++))
          fi
          if ! arg_is_flag "${1}"; then
            SEISTIME_V_SIZE="${1}"
            shift
            ((tectoplot_module_shift++))
          fi
        ;;
        magrange)
          shift
          ((tectoplot_module_shift++))

          if arg_is_float "${1}"; then
            seistimefixminz=1
            seistimeminz="${1}"
            ((tectoplot_module_shift++))
            shift
          fi
          if arg_is_float "${1}"; then
            seistimefixmaxz=1
            seistimemaxz="${1}"
            ((tectoplot_module_shift++))
            shift
          fi
        ;;

        timerange)
          shift
          ((tectoplot_module_shift++))
          if ! arg_is_flag "${1}"; then
            seistimefixminx=1
            seistimeminx="${1}"
            ((tectoplot_module_shift++))
            shift
          fi
          if ! arg_is_flag "${1}"; then
            seistimefixmaxx=1
            seistimemaxx="${1}"
            ((tectoplot_module_shift++))
            shift
          fi
        ;;
        addcmt)
          echo "Adding CMT data"
        ;;
      esac
    done
    doseistimeflag=1
    tectoplot_module_caught=1

    ;;
  esac
}

# The following functions are not necessary for this module

# function tectoplot_calculate_seistime()  {
#   echo "Doing seistime calculations"
# }
#
# function tectoplot_plot_seistime() {
#   echo "Doing seistime plot"
# }
#
# function tectoplot_legend_seistime() {
#   echo "Doing seistime legend"
# }

function tectoplot_post_seistime() {
  if [[ -s ${F_SEIS}eqs.txt && $doseistimeflag -eq 1 ]]; then
    date_and_mag_range=($(gawk < ${F_SEIS}eqs.txt '
      BEGIN {
        getline
        maxdate=$5
        mindate=$5
        maxmag=$4
        minmag=$4
      }
      {
        maxdate=($5>maxdate)?$5:maxdate
        mindate=($5<mindate)?$5:mindate
        if ($4>0) {
          maxmag=($4>maxmag)?$4:maxmag
          minmag=($4<minmag)?$4:minmag
        }
      }
      END {
        print mindate, maxdate, minmag-0.1, maxmag+0.1
      }'))

      # Default source file
      SEISTIMEFILE=${F_SEIS}eqs.txt

      if [[ $SCALEEQS -eq 1 ]]; then

        # We actually need to combine the eqs.txt and eqs_scaled.txt so
        # we can plot the true magnitude on the y-axis but scale the same
        # as the map.


        if [[ $zctimeflag -eq 1 ]]; then
          SEIS_INPUTORDER="-i4,3,6,3+s0.015"
          SEIS_CPT=${F_CPTS}"eqtime.cpt"

        elif [[ $zcclusterflag -eq 1 ]]; then
          SEIS_INPUTORDER="-i4,3,7,3+s0.015"
          SEIS_CPT=${F_CPTS}"eqcluster.cpt"
        else
          # SEIS_INPUTORDER="-i4,3,2,3+s0.015"
          SEIS_CPT=$SEISDEPTH_CPT
          gawk < ${F_SEIS}eqs.txt '{ print $5, $4, $3 }' > seistime.cut1
          gawk < ${F_SEIS}eqs_scaled.txt '{ print $4 }' > seistime.cut2
          paste seistime.cut1 seistime.cut2 > seistime.merged
          SEISTIMEFILE="seistime.merged"
          SEIS_INPUTORDER="-i0,1,2,3+s0.03"

        fi
      else
        if [[ $zctimeflag -eq 1 ]]; then
          SEIS_INPUTORDER="-i4,3,6"
          SEIS_CPT=${F_CPTS}"eqtime.cpt"
        elif [[ $zcclusterflag -eq 1 ]]; then
          SEIS_INPUTORDER="-i4,3,7"
          SEIS_CPT=${F_CPTS}"eqcluster.cpt"
        else
          SEIS_INPUTORDER="-i4,3,2"
          SEIS_CPT=$SEISDEPTH_CPT
        fi
      fi

      [[ $seistimefixminx -eq 1 ]] && date_and_mag_range[0]=$seistimeminx
      [[ $seistimefixmaxx -eq 1 ]] && date_and_mag_range[1]=$seistimemaxx

      [[ $seistimefixminz -eq 1 ]] && date_and_mag_range[2]=$seistimeminz
      [[ $seistimefixmaxz -eq 1 ]] && date_and_mag_range[3]=$seistimemaxz

      gmt gmtset PS_MEDIA 100ix100i
      if [[ $SCALEEQS -eq 1 ]]; then
        gmt psxy ${SEISTIMEFILE} ${SEIS_INPUTORDER} -t${SEISTRANS} -R${date_and_mag_range[0]}/${date_and_mag_range[1]}/${date_and_mag_range[2]}/${date_and_mag_range[3]} ${EQWCOM} -Sc  -C${SEIS_CPT} -JX${SEISTIME_H_SIZE}T/${SEISTIME_V_SIZE} ${VERBOSE} -K > seistime.ps
      else
        gmt psxy ${SEISTIMEFILE} ${SEIS_INPUTORDER} -t${SEISTRANS} -R${date_and_mag_range[0]}/${date_and_mag_range[1]}/${date_and_mag_range[2]}/${date_and_mag_range[3]} ${EQWCOM} -Sc${SEISSCALE}  -C${SEIS_CPT} -JX${SEISTIME_H_SIZE}T/${SEISTIME_V_SIZE} -K ${VERBOSE} > seistime.ps
      fi

      gmt psbasemap -R -J -Bpaf -BtrSW -Bx+l"Date" -By+l"Magnitude" -O --MAP_FRAME_PEN=thinner,black --FONT_LABEL=12p,Helvetica,black --FONT_ANNOT_PRIMARY=10p,Helvetica,black --ANNOT_OFFSET_PRIMARY=4p --LABEL_OFFSET=12p >>  seistime.ps

      gmt psconvert seistime.ps -Tf -A+m0.5i

      if [[ $seistime_onmap -eq 1 ]]; then

        # Expects the variable PS_HEIGHT_IN to contain the current vertical offset below the map
        # origin to allow concatenation of figure parts below the map.

        # echo "Map height is currently ${PS_HEIGHT_IN}"
        SEISTIME_PS_DIM=($(gmt psconvert seistime.ps -Fseistime -Te -A+m0i -V 2> >(grep Width) | gawk  -F'[ []' -v mapwidth=${MAP_PS_WIDTH_NOLABELS_IN} -v prevheight=$PS_HEIGHT_IN '{print $10/2.54, $17/2.54+0.5+prevheight, $10/2.54-(mapwidth+0) }'))

        # echo "It is" ${SEISTIME_PS_DIM[@]}
        gmt psimage -Dx"-${SEISTIME_PS_DIM[2]}i/-${SEISTIME_PS_DIM[1]}i"+w${SEISTIME_PS_DIM[0]}i seistime.eps $RJOK ${VERBOSE} >> map.ps

        # Set PS_HEIGHT_IN so another module can concatenate a panel
        PS_HEIGHT_IN=${SEISTIME_PS_DIM[1]}
      fi

  fi


}

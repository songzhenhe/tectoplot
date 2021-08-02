
TECTOPLOT_MODULES+=("seistime")

# EXPECTS THESE VARIABLES TO BE SET
# zcclusterflag : flag to plot colors by cluster ID
# SEIS_CPT      : CPT for plotting seismicity

function tectoplot_args_seistime()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -seistime)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-seistime:     create a seismicity vs. time plot, colored by depth OR cluster
-seistime

  Output is seistime.pdf

Example: None
--------------------------------------------------------------------------------
EOF
fi
    tectoplot_module_shift=1
    tectoplot_module_caught=1
    ;;
  esac
}

# The following functions are not necessary for this module

# function tectoplot_calculate_stereonet()  {
#   echo "Doing stereonet calculations"
# }
#
# function tectoplot_plot_stereonet() {
#   echo "Doing stereonet plot"
# }
#
# function tectoplot_legend_stereonet() {
#   echo "Doing stereonet legend"
# }

function tectoplot_post_seistime() {
  if [[ -s ${F_SEIS}eqs.txt ]]; then
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

      if [[ $zctimeflag -eq 1 ]]; then
        SEIS_INPUTORDER="-i4,3,6+s${SEISSCALE}"
        SEIS_CPT=${F_CPTS}"eqtime.cpt"
      elif [[ $zcclusterflag -eq 1 ]]; then
        SEIS_INPUTORDER="-i4,3,7+s${SEISSCALE}"
        SEIS_CPT=${F_CPTS}"eqcluster.cpt"
      else
        SEIS_INPUTORDER="-i4,3,2+s${SEISSCALE}"
        SEIS_CPT=$SEISDEPTH_CPT
      fi

      gmt psxy ${F_SEIS}eqs.txt ${SEIS_INPUTORDER} -t40 -R${date_and_mag_range[0]}/${date_and_mag_range[1]}/${date_and_mag_range[2]}/${date_and_mag_range[3]} -Sc0.05i  -C${SEIS_CPT} -JX6iT/2i -Bpaf > seistime.ps

      gmt psconvert seistime.ps -Tf -A+m0.5i
  fi
}

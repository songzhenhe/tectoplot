
TECTOPLOT_MODULES+=("stereonet")

function tectoplot_args_stereonet()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0


  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  # The flag must not conflict with an existing tectoplot option or another module
  -cs) # args: none

  # The following usage statement is required for tectoplot -usage to work with this module.
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-cs:           plot focal mechanism principal axes on a stereonet
-cs

 Module "stereonet"

 Requires -c option to select focal mechanism data.
 Output file is stereo.pdf in temporary directory.

Example:
 tectoplot -r PY -c -cs
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

function tectoplot_post_stereonet() {
  ##### PLOT STEREONET OF FOCAL MECHANISM PRINCIPAL AXES

  # Expects the following variables to be set
  # CMTFILE : The file of focal mechanisms in tectoplot format
  # VERBOSE : VERBOSITY LEVEL
  # RJOK : -R -J -O -K

  if [[ -s ${CMTFILE} ]]; then
    echo "Making stereonet of focal mechanism axes"
    gmt psbasemap -JA0/-89.999/3i -Rg -Bxa10fg10 -Bya10fg10 -K ${VERBOSE} > stereo.ps

    axestflag=1
    axespflag=1
    axesnflag=1
    axescmtthrustflag=1
    axescmtssflag=1
    axescmtnormalflag=1

    if [[ $axescmtthrustflag -eq 1 ]]; then
      [[ $axestflag -eq 1 ]] && gawk  < ${CMTFILE}  '(substr($1,2,1)=="T"){ print $24, -$25 }' | gmt psxy -Sc0.05i -W0.25p,black -Gred -R -J -O -K ${VERBOSE} >> stereo.ps
      [[ $axespflag -eq 1 ]] && gawk  < ${CMTFILE}  '(substr($1,2,1)=="T"){ print $30, -$31 }' | gmt psxy -Sc0.05i -W0.25p,black -Gblue -R -J -O -K ${VERBOSE} >> stereo.ps
      [[ $axesnflag -eq 1 ]] && gawk  < ${CMTFILE}  '(substr($1,2,1)=="T"){ print $27, -$28 }' | gmt psxy -Sc0.05i -W0.25p,black -Ggreen -R -J -O -K ${VERBOSE} >> stereo.ps
    fi
    if [[ $axescmtnormalflag -eq 1 ]]; then
      [[ $axestflag -eq 1 ]] && gawk  < ${CMTFILE}  '(substr($1,2,1)=="N"){ print $24, -$25 }' | gmt psxy -Ss0.05i -W0.25p,black -Gred -R -J -O -K ${VERBOSE} >> stereo.ps
      [[ $axespflag -eq 1 ]] && gawk  < ${CMTFILE}  '(substr($1,2,1)=="N"){ print $30, -$31 }' | gmt psxy -Ss0.05i -W0.25p,black -Gblue -R -J -O -K ${VERBOSE} >> stereo.ps
      [[ $axesnflag -eq 1 ]] && gawk  < ${CMTFILE}  '(substr($1,2,1)=="N"){ print $27, -$28 }' | gmt psxy -Ss0.05i -W0.25p,black -Ggreen -R -J -O -K ${VERBOSE} >> stereo.ps
    fi
    if [[ $axescmtssflag -eq 1 ]]; then
      [[ $axestflag -eq 1 ]] && gawk  < ${CMTFILE}  '(substr($1,2,1)=="S"){ print $24, -$25 }' | gmt psxy -St0.05i -W0.25p,black -Gred -R -J -O -K ${VERBOSE} >> stereo.ps
      [[ $axespflag -eq 1 ]] && gawk  < ${CMTFILE}  '(substr($1,2,1)=="S"){ print $30, -$31 }' | gmt psxy -St0.05i -W0.25p,black -Gblue -R -J -O -K ${VERBOSE} >> stereo.ps
      [[ $axesnflag -eq 1 ]] && gawk  < ${CMTFILE}  '(substr($1,2,1)=="S"){ print $27, -$28 }' | gmt psxy -St0.05i -W0.25p,black -Ggreen -R -J -O -K ${VERBOSE} >> stereo.ps
    fi
    gmt psxy -T -R -J -O ${VERBOSE} >> stereo.ps
    gmt psconvert stereo.ps -Tf -A0.5i ${VERBOSE}
  fi
}


TECTOPLOT_MODULES+=("stereonet")

# function tectoplot_defaults_stereonet() {
# }

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
modules/module_stereonet.sh
-cs:           plot focal mechanism principal axes on a stereonet
-cs [[options]]

 Requires -c option to select focal mechanism data.
 Output file is stereo.pdf in temporary directory.

 Options

 np          plot fault nodal planes and poles

Example:
 tectoplot -r PY -c -cs
--------------------------------------------------------------------------------
EOF
  fi
    tectoplot_module_shift=0

    shift

    while ! arg_is_flag $1; do
      case $1 in
        np)
          shift
          ((tectoplot_module_shift++))
          cstereonodalflag=1
        ;;
        nogrid)
          shift
          ((tectoplot_module_shift++))
          cstereonogridflag=1
        ;;
        *)
          echo "[-cs]: Option $1 not recognized"
          exit 1
        ;;
      esac
    done

    if [[ $1 == "np" ]]; then
      shift
      ((tectoplot_module_shift++))
      cstereonodalflag=1
    fi

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

    # We use Lambert azimuthal equal-area, lower hemisphere
    if [[ $cstereonogridflag -eq 1 ]]; then
      csgridcmd="-Bxa -Bya"
    else
      csgridcmd="-Bxafg10 -Byafg10"
    fi

    gmt psbasemap -JA0/-89.99999/5i -Rg $csgridcmd -K ${VERBOSE} > stereo.ps

    axestflag=1
    axespflag=1
    axesnflag=1
    axescmtthrustflag=1
    axescmtssflag=1
    axescmtnormalflag=1
    symbolsize=0.1i
    symbolsize_np=0.15i

    if [[ $cstereonodalflag -eq 1 ]]; then
      echo "Plotting nodal plane poles"
      gawk < ${F_CMT}cmt.dat '{$1=0; $2=-90; print}' | gmt psmeca -Gwhite@100 -Ewhite@100 -T -W0.2p,gray -Sm5i+m -R -J -O -K ${VERBOSE} >> stereo.ps

      gawk < ${CMTFILE} '{ if ($17>0) { print $16-90, $17-90 } else { print $16-90, $17 } }' | gmt psxy -Sd${symbolsize_np} -W0.25p,black -Gred -R -J -O -K ${VERBOSE} >> stereo.ps
      gawk < ${CMTFILE} '{ if ($20>0) { print $19-90, $20-90 } else { print $19-90, $20 } }' | gmt psxy -Sd${symbolsize_np} -W0.5p,red -Gwhite -R -J -O -K ${VERBOSE} >> stereo.ps
    fi

    if [[ $axescmtthrustflag -eq 1 ]]; then
      [[ $axestflag -eq 1 ]] && gawk  < ${CMTFILE}  '(substr($1,2,1)=="T"){ print $24, -$25 }' | gmt psxy -Sc${symbolsize} -W0.25p,black -G${T_AXIS_COLOR} -R -J -O -K ${VERBOSE} >> stereo.ps
      [[ $axespflag -eq 1 ]] && gawk  < ${CMTFILE}  '(substr($1,2,1)=="T"){ print $30, -$31 }' | gmt psxy -Sc${symbolsize} -W0.25p,black -G${P_AXIS_COLOR} -R -J -O -K ${VERBOSE} >> stereo.ps
      [[ $axesnflag -eq 1 ]] && gawk  < ${CMTFILE}  '(substr($1,2,1)=="T"){ print $27, -$28 }' | gmt psxy -Sc${symbolsize} -W0.25p,black -G${N_AXIS_COLOR} -R -J -O -K ${VERBOSE} >> stereo.ps
    fi
    if [[ $axescmtnormalflag -eq 1 ]]; then
      [[ $axestflag -eq 1 ]] && gawk  < ${CMTFILE}  '(substr($1,2,1)=="N"){ print $24, -$25 }' | gmt psxy -Ss${symbolsize} -W0.25p,black -G${T_AXIS_COLOR} -R -J -O -K ${VERBOSE} >> stereo.ps
      [[ $axespflag -eq 1 ]] && gawk  < ${CMTFILE}  '(substr($1,2,1)=="N"){ print $30, -$31 }' | gmt psxy -Ss${symbolsize} -W0.25p,black -G${P_AXIS_COLOR} -R -J -O -K ${VERBOSE} >> stereo.ps
      [[ $axesnflag -eq 1 ]] && gawk  < ${CMTFILE}  '(substr($1,2,1)=="N"){ print $27, -$28 }' | gmt psxy -Ss${symbolsize} -W0.25p,black -G${N_AXIS_COLOR} -R -J -O -K ${VERBOSE} >> stereo.ps
    fi
    if [[ $axescmtssflag -eq 1 ]]; then
      [[ $axestflag -eq 1 ]] && gawk  < ${CMTFILE}  '(substr($1,2,1)=="S"){ print $24, -$25 }' | gmt psxy -St${symbolsize} -W0.25p,black -G${T_AXIS_COLOR} -R -J -O -K ${VERBOSE} >> stereo.ps
      [[ $axespflag -eq 1 ]] && gawk  < ${CMTFILE}  '(substr($1,2,1)=="S"){ print $30, -$31 }' | gmt psxy -St${symbolsize} -W0.25p,black -G${P_AXIS_COLOR} -R -J -O -K ${VERBOSE} >> stereo.ps
      [[ $axesnflag -eq 1 ]] && gawk  < ${CMTFILE}  '(substr($1,2,1)=="S"){ print $27, -$28 }' | gmt psxy -St${symbolsize} -W0.25p,black -G${N_AXIS_COLOR} -R -J -O -K ${VERBOSE} >> stereo.ps
    fi

    gmt psxy -T -R -J -K -O ${VERBOSE} >> stereo.ps

cat<<-EOF > stereonet_legend.txt
G 0.5i
H 12 Times-Roman Moment tensor principal axes
D 0i 1p
N 3
L 10p Helvetica LB T-axis
L 10p Helvetica LB P-axis
L 10p Helvetica LB N-axis
S 0.01i c ${symbolsize} ${T_AXIS_COLOR} 0.25p 0.3i Thrust
S 0.01i c ${symbolsize} ${P_AXIS_COLOR} 0.25p 0.3i Thrust
S 0.01i c ${symbolsize} ${N_AXIS_COLOR} 0.25p 0.3i Thrust
S 0.01i s ${symbolsize} ${T_AXIS_COLOR} 0.25p 0.3i Normal
S 0.01i s ${symbolsize} ${P_AXIS_COLOR} 0.25p 0.3i Normal
S 0.01i s ${symbolsize} ${N_AXIS_COLOR} 0.25p 0.3i Normal
S 0.01i t ${symbolsize} ${T_AXIS_COLOR} 0.25p 0.3i Strike-slip
S 0.01i t ${symbolsize} ${P_AXIS_COLOR} 0.25p 0.3i Strike-slip
S 0.01i t ${symbolsize} ${N_AXIS_COLOR} 0.25p 0.3i Strike-slip
D 0i 1p
P
EOF
    gmt pslegend stereonet_legend.txt --FONT_ANNOT_PRIMARY=10p,Helvetica,black -Dx0i/-1.35i+w5i+jBL+l1.2 -C0.1i/0.1i -B5f1 -R -J -O ${VERBOSE} >> stereo.ps
    gmt psconvert stereo.ps -Tf -A0.5i ${VERBOSE}
  fi
}

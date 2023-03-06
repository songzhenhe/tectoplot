
TECTOPLOT_MODULES+=("eqslip")

# UPDATED
# NEW OPTS

# function tectoplot_defaults_eqslip() {
# }

function tectoplot_args_eqslip()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in
    -eqslip)

  tectoplot_get_opts_inline '
des -eqslip plot gridded earthquake slip model (or any grid...) with clipping
req m_eqslip_file file
    input grid file
opt clip m_eqslip_clip file /dev/null/
    path to a file containing a XY (lon lat) clipping polygon
opt cpt m_eqslip_cpt cpt "lajolla"
    CPT used to color grid
opt showclip m_eqslip_showclip flag 0
    plot the clipping polygon as a line
opt min m_eqslip_min float 0
    minimum slip value; below this, replace with NaN
opt int m_eqslip_int float 0
    contour interval for slip model (in units of input grid)
opt color m_eqslip_color string "gray"
    color of contours (major and minor)
opt ltrans m_eqslip_linetrans float 0
    transparency of contour lines
opt gtrans m_eqslip_gridtrans float 50
    transparency of gridded slip
opt smooth m_eqslip_smooth float 3
    smoothing factor
opt font m_eqslip_font string "3p,Helvetica,black"
    font of contour annotations
opt minwidth m_eqslip_minwidth string "0.2p"
    line width of minor contours
opt maxwidth m_eqslip_majwidth string "0.5p"
    line width of major contours
opt label m_eqslip_labelstr string "Coseismic_slip"
    label used in legend
mes If int is not specified for a model, uses a contour interval that will
mes work with all specified models. Note: the range of slip in ALL models
mes specified to -eqslip is used to scale ALL CPTs and contours.
' "${@}" || return


  plots+=("eqslip")
  cpts+=("eqslip")

  ;;
  esac
}

# tectoplot_cpts_eqslip() {
#
# }

function tectoplot_calculate_eqslip()  {

  # Do the calculations all at once to get the total slip range for the CPT

  if [[ $m_eqslip_calculated_eqslip -eq 0 ]]; then

    # # cur_zmin and cur_zmax are used to restrict the levels plotted using -L option
    cur_zmax=0
    cur_zmin=99999
    for eqindex in $(seq 1 $(echo "${#m_eqslip_file[@]}" | bc)); do
      zrange=($(grid_zrange ${m_eqslip_file[$eqindex]}))

      cur_zmax=$(echo ${zrange[1]} $cur_zmax | gawk '{print ($1+0>$2+0)?$1+0:$2+0}')
      cur_zmin=$(echo ${zrange[2]} $cur_zmin | gawk '{print ($1+0<$2+0)?$1+0:$2+0}')
    done
    cur_zint=$(echo $cur_zmin $cur_zmax | gawk '
    function abs(x) { return (x>0)?x:-x }
    {
      zdiff=abs($2-$1)
      interval=zdiff/10
      print interval
    }')
    m_eqslip_calculated_eqslip=1

    for eqindex in $(seq 1 $(echo "${#m_eqslip_file[@]}" | bc)); do
      gmt makecpt -T${cur_zmin}/${cur_zmax} -C${m_eqslip_cpt[$eqindex]} -Z ${VERBOSE} > ${F_CPTS}slip_${m_eqslip_cpt[$eqindex]}.cpt
    done

    for eqindex in $(seq 1 $(echo "${#m_eqslip_file[@]}" | bc)); do
      # N A pen - annotate
      # N c pen - draw without annotation, minor
      gawk -v minz=${cur_zmin} -v maxz=${cur_zmax} -v minwidth=${m_eqslip_minwidth[$eqindex]} -v maxwidth=${m_eqslip_majwidth[$eqindex]} -v mincolor=${m_eqslip_color[$eqindex]} -v majcolor=${m_eqslip_color[$eqindex]} -v majorspace=5 '
        function abs(x) { return (x>0)?x:-x }
        BEGIN {
          ind=1
          # Make an array like 0.001, 0.005, etc up to 1000, 5000
          for(i=-3; i<=3; ++i) {
            intervalarray[ind++]=10^i
            # intervalarray[ind++]=2*(10^i)
            intervalarray[ind++]=5*(10^i)
          }

          # Find the general spacing of the contours needed
          diffz=abs(maxz-minz)
          cint=diffz/5

          # Assign the largest number beneath diffz from the interval array
          for(j=1; j<ind; j++) {
            if (intervalarray[j] < cint) {
              cinttemp=intervalarray[j]
            }
          }
          cint=cinttemp

          ismaj=0
          minz=minz-minz%cint
          for(i=minz; i<maxz; i+=cint) {
            if (++ismaj == majorspace) {
              print i, "A", maxwidth "," majcolor
              ismaj=0
            } else {
              print i, "A", minwidth "," mincolor
            }
          }
        }' > eqslip_${eqindex}.contourdef
    done
  fi
}

# function tectoplot_cpt_eqslip() {
# }

function tectoplot_plot_eqslip() {

  case $1 in
  eqslip)

    # Find the maximum and minimum slip values in all of the the submitted grid files

    # Set contour interval to the appropriate rounded value that gives N contours between
    # cur_zmax and cur_zmin

    m_eqslip_gridfile=${m_eqslip_file[$tt]}

    # If we have a minimum value to mask out, do that here
    if [[ $(echo "${m_eqslip_min[$tt]} > 0" | bc) -eq 1 ]]; then
      gmt grdclip ${m_eqslip_file[$tt]} -Sb${m_eqslip_min[$tt]}/NaN -Geqslip_${tt}.grd ${VERBOSE}
      m_eqslip_gridfile=eqslip_${tt}.grd
    fi

    # If we are using a clipping polygon for this event, activate it here
    if [[ ${m_eqslip_clip[$tt]} != "None" ]]; then
      gmt psclip ${m_eqslip_clip[$tt]} $RJOK ${VERBOSE} >> map.ps
    fi

    # If we specified a contour interval
    if [[ ${m_eqslip_int[$tt]} -ne 0 ]]; then
      EQCONTOURCMD="-C${m_eqslip_int[$tt]}"
    else
    # If we are using the derived contour interval from all input slip models
      EQCONTOURCMD="-A+f${m_eqslip_font[$tt]} -Ceqslip_${tt}.contourdef"
    fi

    gmt grdimage -C${F_CPTS}slip_${m_eqslip_cpt[$tt]}.cpt ${m_eqslip_gridfile} -t${m_eqslip_gridtrans[$tt]} -Q $RJOK ${VERBOSE} >> map.ps
    gmt grdcontour ${m_eqslip_gridfile} -t${m_eqslip_linetrans[$tt]} -S${m_eqslip_smooth[$tt]} ${EQCONTOURCMD} $RJOK ${VERBOSE} >> map.ps

# -L${cur_zmin}/${cur_zmax}

    if [[ ${m_eqslip_clipshow[$tt]} -eq 1 ]]; then
      gmt psxy ${m_eqslip_clip[$tt]} -W0.2p,black,- ${RJOK} ${VERBOSE} >> map.ps
    fi

    # Release the clipping mask if necessary
    if [[ ${m_eqslip_clip[$tt]} != "None" ]]; then
      gmt psclip -C $RJOK ${VERBOSE} >> map.ps
    fi

    tectoplot_plot_caught=1
    ;;
  esac

}

# function tectoplot_legend_eqslip() {
#   echo "none"
# }

function tectoplot_legendbar_eqslip() {
  case $1 in
    eqslip)

    # Only create legend scale bars for each individual CPT used

    if [[ ! " ${m_eqslip_plotted[*]} " =~ " ${m_eqslip_cpt[$tt]} " ]]; then
      m_eqslip_plotted+=(${m_eqslip_cpt[$tt]})

      echo "G 0.2i" >> ${LEGENDDIR}legendbars.txt
      echo "B ${F_CPTS}slip_${m_eqslip_cpt[$tt]}.cpt  0.2i 0.1i+malu+e -Bxaf+l\"${m_eqslip_labelstr[$tt]}\"" >> ${LEGENDDIR}legendbars.txt
      barplotcount=$barplotcount+1
    fi

    tectoplot_caught_legendbar=1
    ;;
  esac
}


# function tectoplot_post_eqslip() {
#   echo "none"
# }

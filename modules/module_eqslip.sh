
TECTOPLOT_MODULES+=("eqslip")

# Calculate residual grid by removing along-line average, using da-dt formulation
# Builtin support for gravity grids

# Variables needed:
# GRID_PRINT_RES
# GRAVCPT

function tectoplot_defaults_eqslip() {
  EQSLIPTRANS=50
  EQSLIPMIN=50
  numeqslip=0
  thiseqslip=0
  calculated_eqslip=0
  customint_eqslip=0
  EQSLIP_CONTOURMINORWIDTH=0.2p
  EQSLIP_CONTOURMAJORWIDTH=0.5p
  EQSLIP_CONTOURMINORCOLOR=25/25/25
  EQSLIP_CONTOURMAJORCOLOR=black
  EQSLIP_TEXTSIZE=3p           # size in font points of annotations on major contours
  EQSLIP_TEXTFONT=Helvetica
  EQSLIP_TEXTCOLOR=black
  EQSLIP_CONTOURTRANS=25       # transparency of contours
  EQSLIP_CONTOURSMOOTH=3       # smoothing factor for contours
  plottedeqslipcptflag=0       # Did we already add to the legend?
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
-eqslip [gridfile] [[options]]

  -eqslip can be called multiple times to plot multiple slip models

  Options:
  clip [filename]      Path to a file containing a XY (lon lat) clipping polygon
  min [number]         Minimum slip value; below this, replace with NaN
  int [number]         Specify the contour interval for this slip model
  color [color]        Set color of the contours (major and minor)

  If int is not specified for a model, uses a contour interval that will
  work with all specified models.

Example: (no data files are provided yet... hypothetical example)
  tectoplot -r IN -t -eqslip slip1.grd clip1.xy slip2.grd clip2.xy
--------------------------------------------------------------------------------
EOF
  fi

    shift

    if [[ -s "${1}" ]]; then
      E_GRDLIST[$numeqslip]=$(abs_path "${1}")
      shift
      ((tectoplot_module_shift++))
    else
      echo "[-eqslip]: grid file $1 does not exist or is empty"
      exit 1
    fi

    # Default is no clipping polygon, no minimum cut, default contour interval
    E_CLIPLIST[$numeqslip]="None"
    E_MINLIST[$numeqslip]=0
    E_INTLIST[$numeqslip]="None"
    E_MAJORCOLOR[$numeqslip]=${EQSLIP_CONTOURMAJORCOLOR}
    E_MINORCOLOR[$numeqslip]=${EQSLIP_CONTOURMINORCOLOR}

    while ! arg_is_flag $1; do
      case $1 in
        color)
          shift
          ((tectoplot_module_shift++))
          if arg_is_flag $1; then
            echo "[-eqslip]: color option requires argument"
            exit 1
          fi
          E_MINORCOLOR[$numeqslip]=$1
          E_MAJORCOLOR[$numeqslip]=$1
          shift
          ((tectoplot_module_shift++))
          ;;
        clip)
          shift
          ((tectoplot_module_shift++))
          if [[ -s ${1} ]]; then
            E_CLIPLIST[$numeqslip]=$(abs_path "${1}")
            shift
            ((tectoplot_module_shift++))
          else
            echo "[-eqslip]: clip file $1 does not exist or is empty"
            exit 1
          fi
          if [[ $1 == "show" ]]; then
            E_CLIPSHOW[$numeqslip]=1
          else
            E_CLIPSHOW[$numeqslip]=0
          fi
        ;;
        min)
          shift
          ((tectoplot_module_shift++))
          if arg_is_positive_float $1; then
            E_MINLIST[$numeqslip]=$1
            shift
            ((tectoplot_module_shift++))
          else
            echo "[-eqslip]: minimum value must be a positive number"
            exit 1
          fi
        ;;
        int)
          shift
          ((tectoplot_module_shift++))
          if arg_is_positive_float $1; then
            E_INTLIST[$numeqslip]=$1
            shift
            ((tectoplot_module_shift++))
            customint_eqslip=1
          else
            echo "[-eqslip]: contour interval must be a positive number"
            exit 1
          fi
        ;;
      esac
    done

    numeqslip=$(echo "$numeqslip + 1" | bc)

    plots+=("eqslip")
    cpts+=("eqslip")

    tectoplot_module_caught=1
    ;;
  esac
}

# tectoplot_cpts_eqslip() {
#
# }

function tectoplot_calculate_eqslip()  {
  if [[ $calculated_eqslip -eq 0 ]]; then
    numeqslipend=$(echo "$numeqslip - 1" | bc)

    # # cur_zmin and cur_zmax are used to restrict the levels plotted using -L option
    cur_zmax=0
    cur_zmin=99999
    for eqindex in $(seq 0 $numeqslipend); do
      zrange=($(grid_zrange ${E_GRDLIST[$eqindex]}))
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
    calculated_eqslip=1

    gmt makecpt -T${cur_zmin}/${cur_zmax} -Clajolla -Z ${VERBOSE} > ${F_CPTS}slip.cpt


    for eqindex in $(seq 0 $numeqslipend); do
      # N A pen - annotate
      # N c pen - draw without annotation, minor
      gawk -v minz=${cur_zmin} -v maxz=${cur_zmax} -v minwidth=${EQSLIP_CONTOURMINORWIDTH} -v maxwidth=${EQSLIP_CONTOURMAJORWIDTH} -v mincolor=${E_MAJORCOLOR[$eqindex]} -v majcolor=${E_MINORCOLOR[$eqindex]} -v majorspace=5 '
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
    # ((thiseqslip++))

    eqindex=$thiseqslip
    EQGRIDFILE=${E_GRDLIST[$eqindex]}

    # If we have a minimum value to mask out, do that here
    if [[ $(echo "${E_MINLIST[$eqindex]} > 0" | bc) -eq 1 ]]; then
      gmt grdclip ${E_GRDLIST[$eqindex]} -Sb${E_MINLIST[$eqindex]}/NaN -Geqslip_${eqindex}.grd ${VERBOSE}
      EQGRIDFILE=eqslip_${eqindex}.grd
    fi

    # If we are using a clipping polygon for this event, activate it here
    if [[ ${E_CLIPLIST[$eqindex]} != "None" ]]; then
      gmt psclip ${E_CLIPLIST[$eqindex]} $RJOK ${VERBOSE} >> map.ps
    fi

    # If we specified a contour interval
    if [[ ${E_INTLIST[$eqindex]} != "None" ]]; then
      EQCONTOURCMD="-C${E_INTLIST[$eqindex]}"
    else
    # If we are using the derived contour interval from all input slip models
      EQCONTOURCMD="-A+f${EQSLIP_TEXTSIZE},${EQSLIP_TEXTFONT},${EQSLIP_TEXTCOLOR} -Ceqslip_${eqindex}.contourdef"
    fi

    gmt grdimage -C${F_CPTS}slip.cpt ${EQGRIDFILE} -t${EQSLIPTRANS} -Q $RJOK ${VERBOSE} >> map.ps
    gmt grdcontour ${EQGRIDFILE} -t${EQSLIP_CONTOURTRANS} -S${EQSLIP_CONTOURSMOOTH} ${EQCONTOURCMD} $RJOK ${VERBOSE} >> map.ps

# -L${cur_zmin}/${cur_zmax}

    if [[ ${E_CLIPSHOW[$eqindex]} -eq 1 ]]; then
      gmt psxy ${E_CLIPLIST[$eqindex]} -W0.2p,black,- ${RJOK} ${VERBOSE} >> map.ps
    fi

    # Release the clipping mask if necessary
    if [[ ${E_CLIPLIST[$eqindex]} != "None" ]]; then
      gmt psclip -C $RJOK ${VERBOSE} >> map.ps
    fi

    ((thiseqslip++))
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
    # Don't plot a color bar if we already have plotted one OR the seis CPT is a solid color
    if [[ $plottedeqslipcptflag -eq 0 ]]; then
      plottedeqslipcptflag=1
      echo "G 0.2i" >> legendbars.txt
      echo "B ${F_CPTS}slip.cpt  0.2i 0.1i+malu+e -Bxaf+l\"Coseismic slip\"" >> legendbars.txt
      barplotcount=$barplotcount+1
    fi
    tectoplot_caught_legendbar=1
    ;;
  esac
}


# function tectoplot_post_eqslip() {
#   echo "none"
# }

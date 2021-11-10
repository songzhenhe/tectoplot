
TECTOPLOT_MODULES+=("kostrov")

# Geological data (ocean age, transform fault, etc.)


function tectoplot_defaults_kostrov() {
  KOSTOROV_WIDTH=1   # Width/height of cells
}

function tectoplot_args_kostrov()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -kostrov)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-kostrov:         Do Kostorov summation of focal mechanisms
-kostrov [[cell_width=${KOSTOROV_WIDTH}]]

  Replaces focal mechanisms with Kostorov sum located at bin center

Example:
--------------------------------------------------------------------------------
EOF
fi
  shift

  if arg_is_positive_float $1; then
    KOSTOROV_WIDTH=${1}
    shift
    ((tectoplot_module_shift++))
  fi
  tectoplot_module_caught=1
  ;;
  esac

}

function tectoplot_calculate_kostrov()  {

  # Uses MINLON, MAXLON, MINLAT, MAXLAT to generate bins

  if [[ -s ${CMTFILE} ]]; then

    echo "Doing Kostorov sum:"
    gawk < ${CMTFILE} -v gridsize=${KOSTOROV_WIDTH} -v minlon=${MINLON} -v maxlon=${MAXLON} -v minlat=${MINLAT} -v maxlat=${MAXLAT} -v cmttype=${CMTTYPE} '
      @include "tectoplot_functions.awk"
      {
        if (cmttype=="ORIGIN") {
          lon=$8
          lat=$9
        } else {
          lon=$5
          lat=$6
        }
        gridx=sprintf("%f", rd(lon,gridsize))
        gridy=sprintf("%f", rd(lat,gridsize))
        moment_mantissa=$14
        moment_exponent=$15
        Mrr_e=$33
        Mtt_e=$34
        Mpp_e=$35
        Mrt_e=$36
        Mrp_e=$37
        Mtp_e=$38

        # Add the moment to the relevant cell

        Mrr[gridx][gridy]+=Mrr_e*moment_mantissa*10^moment_exponent
        Mtt[gridx][gridy]+=Mtt_e*moment_mantissa*10^moment_exponent
        Mpp[gridx][gridy]+=Mpp_e*moment_mantissa*10^moment_exponent
        Mrt[gridx][gridy]+=Mrt_e*moment_mantissa*10^moment_exponent
        Mrp[gridx][gridy]+=Mrp_e*moment_mantissa*10^moment_exponent
        Mtp[gridx][gridy]+=Mtp_e*moment_mantissa*10^moment_exponent

      }
      END {
        for (gridx in Mrr) {
          for (gridy in Mrr[gridx]) {
            maxscale=max(rd(log(abs(Mrr[gridx][gridy]))/log(10),1), rd(log(abs(Mtt[gridx][gridy]))/log(10),1))
            maxscale=max(maxscale, rd(log(abs(Mpp[gridx][gridy]))/log(10),1))
            maxscale=max(maxscale, rd(log(abs(Mrt[gridx][gridy]))/log(10),1))
            maxscale=max(maxscale, rd(log(abs(Mrp[gridx][gridy]))/log(10),1))
            maxscale=max(maxscale, rd(log(abs(Mtp[gridx][gridy]))/log(10),1))

#        X Y depth mrr mtt mff mrt mrf mtf exp [newX newY] [event_title] [newdepth] [timecode]

            print gridx, gridy, gridx+gridsize/2, gridy+gridsize/2 > "/dev/stderr"
            print gridx+gridsize/2, gridy+gridsize/2, 0, Mrr[gridx][gridy]/10^maxscale, Mtt[gridx][gridy]/10^maxscale, Mpp[gridx][gridy]/10^maxscale, Mrt[gridx][gridy]/10^maxscale, Mrp[gridx][gridy]/10^maxscale, Mtp[gridx][gridy]/10^maxscale, maxscale
          }
        }
      }
    ' > ${F_CMT}kostrov_moment.txt

    if [[ -s ${F_CMT}kostrov_moment.txt ]]; then
      if [[ $CMTTYPE=="CENTROID" ]]; then
        CMTSWITCH="switch"
      else
        CMTSWITCH=""
      fi
      ${CMTSLURP} ${F_CMT}kostrov_moment.txt m K ${CMTSWITCH} > ${F_CMT}kostrov_final.txt
      if [[ -s ${F_CMT}custom_cmt_${this_customcmtnum}.txt ]]; then
        CMTFILE=$(abs_path ${F_CMT}kostrov_final.txt)
      fi
    fi
  fi

}



# function tectoplot_cpt_kostrov() {
#   case $1 in
#   ;;
#   esac
# }

# function tectoplot_plot_kostrov() {
#   case $1 in
#   tectoplot_plot_caught=1
#   ;;
#   esac
# }

# function tectoplot_legendbar_kostrov() {
#   case $1 in
#         tectoplot_caught_legendbar=1
#       fi
#       ;;
#   esac
# }

# function tectoplot_legend_kostrov() {
# }

# function tectoplot_post_kostrov() {
#   echo "none"
# }

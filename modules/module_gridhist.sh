
TECTOPLOT_MODULES+=("gridhist")


# NEW OPTS

function tectoplot_defaults_gridhist() {
  gridhist_weighted=1  # If set to 0, don't weight histogram by actual cell area - dangerous!
}

function tectoplot_args_gridhist()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  # -gridhistbin)
  # shift
  # if arg_is_positive_float ${1}; then
  #   GRIDHIST_BINWIDTH="${1}"
  #   shift
  #   ((tectoplot_module_shift++))
  # fi
  # tectoplot_module_caught=1
  # ;;

#   -gridhistclip)
# if [[ $USAGEFLAG -eq 1 ]]; then
# cat <<-EOF
# modules/module_gridhist.sh
#
# -gridhistclip:   define a clipping region for the grid histogram calculation
# -gridhistclip [file]
#
#   File can be a KML with a polygon or an XY (lon lat) file.
#   The first object in the KML file will be closed if necessary, so a line path
#     will work.
#   The clipping polygon will be plotted as a black, dashed line.
#
# Example: None
# --------------------------------------------------------------------------------
# EOF
# fi
#   shift
#   if ! arg_is_flag ${1}; then
#     if [[ -s ${1} ]]; then
#       GRIDHIST_CLIPFILE=$(abs_path "${1}")
#       if [[ ${m_gridhist_clip} == *".kml" ]]; then
#         kml_to_first_poly ${m_gridhist_clip} gridhist_clip.xy
#         GRIDHIST_CLIPFILE=$(abs_path gridhist_clip.xy)
#       fi
#       gridhistclipflag=1
#     else
#       echo "[-gridhistclip]: Clipping file ${1} not found or is empty"
#       exit 1
#     fi
#     shift
#     ((tectoplot_module_shift++))
#   fi
#
#   tectoplot_module_caught=1
#   ;;

  -gridhist)

  tectoplot_get_opts_inline '
des -gridhist plot histogram of raster cell values
opn file m_gridhist_file string "topo"
    target grid file (default is topography from -t)
opn clip m_gridhist_clip string "none"
    clipping path (can be KML polyline)
opn width m_gridhist_width string "2i"
    width of plotted panel in inches
opn height m_gridhist_height string "5i"
    height of plotted panel in inches
opn cpt m_gridhist_cpt cpt "${F_CPTS}topo.cpt"
    CPT file
opn bin m_gridhist_binwidth float 100
    width of data bins
opn label m_gridhist_label string "Elevation (m)"
    y-axis label
mes gridhist can only be called once
' "${@}" || return

    plots+=("m_gridhist")
    clipdemflag=1
    ;;

#
#   -gridhistfile)
# if [[ $USAGEFLAG -eq 1 ]]; then
# cat <<-EOF
# modules/module_gridhist.sh
#
# -gridhistfile:   Change the file that is subjected to the histogram analysis
# -gridhistfile [grid_file_path] [bin_width] [cpt_file] [[label label text here]]
#
# Example: None
# --------------------------------------------------------------------------------
# EOF
# fi
#   shift

  # if ! arg_is_flag "${1}"; then
  #   if [[ -s "${1}" ]]; then
  #     GRIDHIST_FILE=$(abs_path ${1})
  #     gridhistfileflag=1
  #   else
  #     info_msg "[-gridhistfile]: Input file ${1} not found... assuming it will be created"
  #     GRIDHIST_FILE="${1}"
  #     gridhistfileflag=1
  #   fi
  #   shift
  #   ((tectoplot_module_shift++))
  # fi
  #
  # if arg_is_positive_float "${1}"; then
  #   GRIDHIST_BINWIDTH="${1}"
  #   shift
  #   ((tectoplot_module_shift++))
  # fi
  #
  # if ! arg_is_flag "${1}"; then
  #   GRIDHIST_CPT="${1}"
  #   shift
  #   ((tectoplot_module_shift++))
  # fi
  #
  # if [[ $1 == "label" ]]; then
  #   GRIDHIST_YLABEL=""
  #   shift
  #   ((tectoplot_module_shift++))
  #   while ! arg_is_flag "${1}"; do
  #     GRIDHIST_YLABEL=${GRIDHIST_YLABEL}" ${1}"
  #     shift
  #     ((tectoplot_module_shift++))
  #   done
  # fi


  -gridhistint)
  tectoplot_get_opts_inline '
des -gridhistint query histogram to report total surface area between min/max
opn min m_gridhist_intmin float 0
  low cut-off value
opn max m_gridhist_intmax float 250
  high cut-off value
' "${@}" || return

  gridhistintflag=1
  ;;
  esac
}

function tectoplot_plot_gridhist() {
  if [[ ${m_gridhist_clip} != "none" ]]; then
    if [[ ${m_gridhist_clip} == *".kml" ]]; then
      kml_to_first_poly ${m_gridhist_clip} gridhist_clip.xy
      m_gridhist_clip=$(abs_path gridhist_clip.xy)
    fi
    gridhistclipflag=1
    gmt psxy ${m_gridhist_clip} -W1p,black,- ${VERBOSE} ${RJOK} >> map.ps
  fi
}

function tectoplot_post_gridhist() {
  # case $1 in
  # gridhist

    if [[ ${m_gridhist_file} == "topo" ]]; then
      m_gridhist_file=${TOPOGRAPHY_DATA}  # Default is dem
    fi

    if [[ -s ${m_gridhist_file} && ${gridhist_hasrun} -eq 0 ]]; then
      gridhist_hasrun=1
      # Non-cumulative data
      # Bin centers using -F

      mkdir module_gridhist/

      gmt grdcut ${m_gridhist_file} -R -J -Gmodule_gridhist/gridhistcut.nc

      gmt grd2xyz module_gridhist/gridhistcut.nc > module_gridhist/histdata_pre.txt
      GRIDDETAILS=($(gmt grdinfo -C ${m_gridhist_file}))
      GRIDRES_X=${GRIDDETAILS[7]}
      GRIDRES_Y=${GRIDDETAILS[8]}

      # histdata.txt is lon lat Z

      # we need to weight the histogram by the area of the observation points.

      if [[ -s ${m_gridhist_clip} ]]; then
        gmt gmtselect module_gridhist/histdata_pre.txt -F${m_gridhist_clip} > module_gridhist/histdata.txt

        # But what if the
        if [[ ! -s module_gridhist/histdata.txt ]]; then
          info_msg "[-gridhistclip]: Shifting polygon by +360 degrees and re-trying clip."
          gawk < ${m_gridhist_clip} '
          {
            print $1+360, $2
          }' > gridhistclipregion_fixed.txt
          m_gridhist_clip=gridhistclipregion_fixed.txt

          gmt gmtselect module_gridhist/histdata_pre.txt -F${m_gridhist_clip} > module_gridhist/histdata.txt
        fi
      else
        cp module_gridhist/histdata_pre.txt module_gridhist/histdata.txt
      fi

      if [[ $gridhist_weighted -eq 1 ]]; then

        # Assumes grid registered points
        gawk < module_gridhist/histdata.txt -v gridresx=${GRIDRES_X} -v gridresy=${GRIDRES_Y} '

        function sqr(x)        { return x*x                     }
        function max(x,y)      { return (x>y)?x:y               }
        function min(x,y)      { return (x<y)?x:y               }
        function getpi()       { return atan2(0,-1)             }
        function abs(v)        { return v < 0 ? -v : v          }
        function tan(x)        { return sin(x)/cos(x)           }
        function atan(x)       { return atan2(x,1)              }
        function asin(x)       { return atan2(x, sqrt(1-x*x))   }
        function acos(x)       { return atan2(sqrt(1-x*x), x)   }
        function rad2deg(rad)  { return (180 / getpi()) * rad   }
        function deg2rad(deg)  { return (getpi() / 180) * deg   }
        function hypot(x,y)    { return sqrt(x*x+y*y)           }
        function ddiff(u)      { return u > 180 ? 360 - u : u   }
        function ceil(x)       { return int(x)+(x>int(x))       }
        function sinsq(x)      { return sin(x)*sin(x)           }
        function cossq(x)      { return cos(x)*cos(x)           }
        function d_atan2d(y,x) { return (x == 0.0 && y == 0.0) ? 0.0 : rad2deg(atan2(y,x)) }

          function ellipsoidal_gridcell_area(a,b,e,lon1,lon2,lat1,lat2,     j,k) {
            # Bagratuni, 1967
            j=sin(deg2rad(lat1))
            k=sin(deg2rad(lat2))
            return b*b/2*(deg2rad(lon2-lon1))*( (k/(1-e*e*k*k)+1/(2*e)*log((1+e*k)/(1-e*k))) - (j/(1-e*e*j*j)+1/(2*e)*log((1+e*j)/(1-e*j)))  )

          }
          function spherical_gridcell_area(r,lon1,lon2,lat1,lat2,     j,k) {
            j=sin(deg2rad(lat1))
            k=sin(deg2rad(lat2))
            return r*r*deg2rad(lon2-lon1)*(sin(deg2rad(lat2))-sin(deg2rad(lat1)))

          }
          BEGIN {
            r=6378200

            a=6378137
            b=6356752.3142
            e=0.0818191908426215

            # The unit grid area is one centered at the equator
            lon1=0-gridresx/2
            lon2=0+gridresx/2
            lat1=0-gridresy/2
            lat2=0+gridresy/2

            ref_area=ellipsoidal_gridcell_area(a,b,e,lon1,lon2,lat1,lat2)
            # ref_area=spherical_gridcell_area(r,lon1,lon2,lat1,lat2)

          }
          {
            lon1=$1-gridresx/2
            lon2=$1+gridresx/2
            lat1=$2-gridresy/2
            lat2=$2+gridresy/2

            # area=ellipsoidal_gridcell_area(a,b,e,lon1,lon2,lat1,lat2)
            area=spherical_gridcell_area(r,lon1,lon2,lat1,lat2)

            print $1, $2, $3, area/ref_area, area/1000000
          }' > module_gridhist/histdata_weighted.txt
      else

        # Assumes grid registered points
        gawk < module_gridhist/histdata.txt  -v gridresx=${GRIDRES_X} -v gridresy=${GRIDRES_Y} '
        function sqr(x)        { return x*x                     }
        function max(x,y)      { return (x>y)?x:y               }
        function min(x,y)      { return (x<y)?x:y               }
        function getpi()       { return atan2(0,-1)             }
        function abs(v)        { return v < 0 ? -v : v          }
        function tan(x)        { return sin(x)/cos(x)           }
        function atan(x)       { return atan2(x,1)              }
        function asin(x)       { return atan2(x, sqrt(1-x*x))   }
        function acos(x)       { return atan2(sqrt(1-x*x), x)   }
        function rad2deg(rad)  { return (180 / getpi()) * rad   }
        function deg2rad(deg)  { return (getpi() / 180) * deg   }
        function hypot(x,y)    { return sqrt(x*x+y*y)           }
        function ddiff(u)      { return u > 180 ? 360 - u : u   }
        function ceil(x)       { return int(x)+(x>int(x))       }
        function sinsq(x)      { return sin(x)*sin(x)           }
        function cossq(x)      { return cos(x)*cos(x)           }
        function d_atan2d(y,x) { return (x == 0.0 && y == 0.0) ? 0.0 : rad2deg(atan2(y,x)) }

          function ellipsoidal_gridcell_area(a,b,e,lon1,lon2,lat1,lat2,     j,k) {
            # Bagratuni, 1967
            j=sin(deg2rad(lat1))
            k=sin(deg2rad(lat2))
            return b*b/2*(deg2rad(lon2)-deg2rad(lon1))*( (k/(1-e*e*k*k)+1/(2*e)*log((1+e*k)/(1-e*k))) - (j/(1-e*e*j*j)+1/(2*e)*log((1+e*j)/(1-e*j)))  )

          }
          BEGIN {
            a=6378137
            b=6356752.3142
            e=0.0818191908426215

            # The unit grid area is one centered at the equator
            lon1=0-gridresx/2
            lon2=0+gridresx/2
            lat1=0-gridresy/2
            lat2=0+gridresy/2
            ref_area=ellipsoidal_gridcell_area(a,b,e,lon1,lon2,lat1,lat2)
          }
          {
            print $1, $2, $3, 1, ref_area/1000000
          }' > module_gridhist/histdata_weighted.txt
      fi

      HISTRANGE=($(gmt pshistogram module_gridhist/histdata_weighted.txt -Z1+w -T${m_gridhist_binwidth} -F -i2,3 -Vn -I))
      CUMHISTRANGE=($(gmt pshistogram module_gridhist/histdata_weighted.txt -Z1+w -Q -T${m_gridhist_binwidth} -F -i2,3 -Vn -I))

      # echo ${HISTRANGE[@]}

      HISTXDIFF=$(echo "${HISTRANGE[1]} - ${HISTRANGE[0]}" | bc -l)
      # echo ${HISTRANGE[1]} ${HISTXDIFF}
      HISTRANGE[1]=$(echo "${HISTRANGE[1]} - ${HISTXDIFF}/20" | bc -l)
      # echo ${HISTRANGE[1]} ${HISTXDIFF}

      HISTYDIFF=$(echo "${HISTRANGE[3]} - ${HISTRANGE[2]}" | bc -l)
      HISTRANGE[3]=$(echo "${HISTRANGE[3]} + ${HISTYDIFF}/3" | bc -l)
      CUMHISTRANGE[3]=$(echo "${CUMHISTRANGE[3]}*11/10" | bc -l)

      if [[ ! -z ${m_gridhist_cpt} ]]; then
        GRIDHIST_CPTCMD="-C${m_gridhist_cpt}"
      else
        GRIDHIST_CPTCMD="-Ggray"
      fi

      # Adding -N to the following command will draw the equivalent normal distribution

      gmt pshistogram module_gridhist/histdata_weighted.txt -T${m_gridhist_binwidth} -R${HISTRANGE[0]}/${HISTRANGE[1]}/${HISTRANGE[2]}/${HISTRANGE[3]} -JX${m_gridhist_width}/${m_gridhist_height} -Z1+w -BSW -Bxaf+l"${m_gridhist_label}" --FONT_LABEL=10p,black -Byaf+l"Relative frequency" ${GRIDHIST_CPTCMD} -F -i2,3 -Vn -A -K > module_gridhist/gridhist.ps
      gmt pshistogram module_gridhist/histdata_weighted.txt -Q -T${m_gridhist_binwidth} -JX${m_gridhist_width}/${m_gridhist_height} -R${HISTRANGE[0]}/${HISTRANGE[1]}/0/100 -Z1+w -BNE -Bxaf -Byaf+l"Cumulative frequency" --FONT_LABEL=10p,red -W0.05p,red,- -i2,3 -Vn -A -S -O >> module_gridhist/gridhist.ps
      gmt psconvert module_gridhist/gridhist.ps -Tf -A+m0.5i

      if [[ -s module_gridhist/histdata_weighted.txt && ${gridhistintflag} -eq 1 ]]; then
        # for gridind in $(seq 1 ${#GRIDHIST_INT_LOW[@]}); do
          # thisgrid=$(echo "$gridind - 1" | bc)
          LC_ALL=en_US.UTF-8 gawk < module_gridhist/histdata_weighted.txt -v low=${m_gridhist_intmin} -v high=${m_gridhist_intmax} '
          BEGIN {
            sumarea=0
          }
          ($3 >= low && $3 <= high) {
            sumarea+=$5
          }
          END {
            print "There are", sprintf("%'"'"'d", sumarea ), "square kilometers between", low, "and", high
          }
          '
        # done
      fi
    else
      [[ $gridhist_hasrun -eq 0 ]] && echo "[-gridhist]: Target file ${GRIDHIST_FILE} does not exist or is empty." && gridhist_hasrun=1
    fi

    # ;;
    # esac
}

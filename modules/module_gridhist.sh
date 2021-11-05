
TECTOPLOT_MODULES+=("gridhist")


function tectoplot_defaults_gridhist() {
  GRIDHIST_WIDTH="2i"
  GRIDHIST_HEIGHT="5i"
  GRIDHIST_CPT=${F_CPTS}topo.cpt
  GRIDHIST_YLABEL="Elevation (m)"
  GRIDHIST_BINWIDTH=100

  gridhist_weighted=1  # If set to 0, don't weight histogram by actual cell area - dangerous!
}

function tectoplot_args_gridhist()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -gridhistbin)
  shift
  if arg_is_positive_float ${1}; then
    GRIDHIST_BINWIDTH="${1}"
    shift
    ((tectoplot_module_shift++))
  fi
  tectoplot_module_caught=1
  ;;

  -gridhistclip)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
modules/module_gridhist.sh

-gridhistclip:   define a clipping region for the grid histogram calculation
-gridhistclip [file]

  File can be a KML with a polygon or an XY (lon lat) file.
  The first object in the KML file will be closed if necessary, so a line path
    will work.

Example: None
--------------------------------------------------------------------------------
EOF
fi
  shift
  if ! arg_is_flag ${1}; then
    if [[ -s ${1} ]]; then
      GRIDHIST_CLIPFILE=$(abs_path "${1}")
      if [[ $GRIDHIST_CLIPFILE == *".kml" ]]; then
        kml_to_first_poly ${GRIDHIST_CLIPFILE} gridhist_clip.xy
        GRIDHIST_CLIPFILE=$(abs_path gridhist_clip.xy)
      fi
      gridhistclipflag=1
    else
      echo "[-gridhistclip]: Clipping file ${1} not found or is empty"
      exit 1
    fi
    shift
    ((tectoplot_module_shift++))
  fi
  tectoplot_module_caught=1
  ;;

  -gridhist)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
modules/module_gridhist.sh

-gridhist:     plot a histogram of values of the topography grid
-gridhist [[width_in=${GRIDHIST_WIDTH}]] [[height_in=${GRIDHIST_HEIGHT}]]

  Will be extended to include custom grid

Example: None
--------------------------------------------------------------------------------
EOF
fi
    shift

    if ! arg_is_flag ${1}; then
      GRIDHIST_WIDTH="${1}"
      shift
      ((tectoplot_module_shift++))
    fi
    if ! arg_is_flag ${1}; then
      GRIDHIST_HEIGHT="${1}"
      shift
      ((tectoplot_module_shift++))
    fi
    plots+=("gridhist")
    clipdemflag=1

    tectoplot_module_caught=1
    ;;


  -gridhistfile)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
modules/module_gridhist.sh

-gridhistfile:   Change the file that is subjected to the histogram analysis
-gridhistfile [grid_file_path] [bin_width] [cpt_file] [[label label text here]]

Example: None
--------------------------------------------------------------------------------
EOF
fi
  shift

  if ! arg_is_flag "${1}"; then
    if [[ -s "${1}" ]]; then
      GRIDHIST_FILE="${1}"
      gridhistfileflag=1
    else
      echo "[-gridhistfile]: Input file ${1} not found"
      exit 1
    fi
    shift
    ((tectoplot_module_shift++))
  fi

  if arg_is_positive_float "${1}"; then
    GRIDHIST_BINWIDTH="${1}"
    shift
    ((tectoplot_module_shift++))
  fi

  if ! arg_is_flag "${1}"; then
    GRIDHIST_CPT="${1}"
    shift
    ((tectoplot_module_shift++))
  fi

  if [[ $1 == "label" ]]; then
    GRIDHIST_YLABEL=""
    shift
    ((tectoplot_module_shift++))
    while ! arg_is_flag "${1}"; do
      GRIDHIST_YLABEL=${GRIDHIST_YLABEL}" ${1}"
      shift
      ((tectoplot_module_shift++))
    done
  fi


  tectoplot_module_caught=1
  ;;

  -gridhistint)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
modules/module_gridhist.sh

-gridhistint:   Report total percent area between upper and lower intervals.
-gridhistint [interval1_low] [interval1_high]

  After -gridhist has been run, report the total surface area contained between
  the given upper and lower interval bounds.

Example: None
--------------------------------------------------------------------------------
EOF
fi

  shift

  while ! arg_is_flag "${1}"; do
    if arg_is_float "${1}"; then
      GRIDHIST_INT_LOW+=("${1}")
      shift
      ((tectoplot_module_shift++))
    fi
    if arg_is_float "${1}"; then
      GRIDHIST_INT_HIGH+=("${1}")
      shift
      ((tectoplot_module_shift++))
      gridhist_dointcalc=1
    fi
  done
  gridhistintflag=1
  tectoplot_module_caught=1
  ;;

  esac
}

function tectoplot_plot_gridhist() {
  if [[ $gridhistclipflag -eq 1 ]]; then
    gmt psxy ${GRIDHIST_CLIPFILE} -W1p,black,- ${VERBOSE} ${RJOK} >> map.ps
  fi
}

function tectoplot_post_gridhist() {
  # case $1 in
  # gridhist

    if [[ $gridhistfileflag -eq 0 ]]; then
      GRIDHIST_FILE=${TOPOGRAPHY_DATA}  # Default is dem
    fi

    if [[ -s ${GRIDHIST_FILE} && $gridhist_hasrun -eq 0 ]]; then
      gridhist_hasrun=1
      # Non-cumulative data
      # Bin centers using -F

      mkdir module_gridhist/

      gmt grdcut ${GRIDHIST_FILE} -R -J -Gmodule_gridhist/gridhistcut.nc

      gmt grd2xyz module_gridhist/gridhistcut.nc > module_gridhist/histdata_pre.txt
      DEMDETAILS=($(gmt grdinfo -C ${GRIDHIST_FILE}))
      GRIDRES_X=${DEMDETAILS[7]}
      GRIDRES_Y=${DEMDETAILS[8]}

      # histdata.txt is lon lat Z

      # we need to weight the histogram by the area of the observation points.


      if [[ $gridhistclipflag -eq 1 ]]; then
        gmt gmtselect module_gridhist/histdata_pre.txt -F${GRIDHIST_CLIPFILE} > module_gridhist/histdata.txt

        # But what if the
        if [[ ! -s module_gridhist/histdata.txt ]]; then
          info_msg "[-gridhistclip]: Shifting polygon by +360 degrees and re-trying clip."
          gawk < ${GRIDHIST_CLIPFILE} '
          {
            print $1+360, $2
          }' > gridhistclipregion_fixed.txt
          GRIDHIST_CLIPFILE=gridhistclipregion_fixed.txt

          gmt gmtselect module_gridhist/histdata_pre.txt -F${GRIDHIST_CLIPFILE} > module_gridhist/histdata.txt
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

      HISTRANGE=($(gmt pshistogram module_gridhist/histdata_weighted.txt -Z1+w -T${GRIDHIST_BINWIDTH} -F -i2,3 -Vn -I))
      CUMHISTRANGE=($(gmt pshistogram module_gridhist/histdata_weighted.txt -Z1+w -Q -T${GRIDHIST_BINWIDTH} -F -i2,3 -Vn -I))

      # echo ${HISTRANGE[@]}

      HISTXDIFF=$(echo "${HISTRANGE[1]} - ${HISTRANGE[0]}" | bc -l)
      # echo ${HISTRANGE[1]} ${HISTXDIFF}
      HISTRANGE[1]=$(echo "${HISTRANGE[1]} - ${HISTXDIFF}/20" | bc -l)
      # echo ${HISTRANGE[1]} ${HISTXDIFF}

      HISTYDIFF=$(echo "${HISTRANGE[3]} - ${HISTRANGE[2]}" | bc -l)
      HISTRANGE[3]=$(echo "${HISTRANGE[3]} + ${HISTYDIFF}/3" | bc -l)
      CUMHISTRANGE[3]=$(echo "${CUMHISTRANGE[3]}*11/10" | bc -l)

      if [[ -s ${GRIDHIST_CPT} ]]; then
        GRIDHIST_CPTCMD="-C${GRIDHIST_CPT}"
      else
        GRIDHIST_CPTCMD="-Ggray"
      fi

      gmt pshistogram module_gridhist/histdata_weighted.txt -T${GRIDHIST_BINWIDTH} -R${HISTRANGE[0]}/${HISTRANGE[1]}/${HISTRANGE[2]}/${HISTRANGE[3]} -JX${GRIDHIST_WIDTH}/${GRIDHIST_HEIGHT} -Z1+w -BSW -Bxaf+l"${GRIDHIST_YLABEL}" --FONT_LABEL=12p,black -Byaf+l"Relative frequency" ${GRIDHIST_CPTCMD} -F -i2,3 -Vn -A -N -K > module_gridhist/gridhist.ps

      gmt pshistogram module_gridhist/histdata_weighted.txt -Q -T${GRIDHIST_BINWIDTH} -JX${GRIDHIST_WIDTH}/${GRIDHIST_HEIGHT} -R${HISTRANGE[0]}/${HISTRANGE[1]}/0/100 -Z1+w -BNE -Bxaf -Byaf+l"Cumulative frequency" --FONT_LABEL=12p,red -W0.05p,red,- -i2,3 -Vn -A -S -O >> module_gridhist/gridhist.ps

      gmt psconvert module_gridhist/gridhist.ps -Tf -A+m0.5i
    # ;;
    #
      if [[ -s module_gridhist/histdata_weighted.txt && $gridhistintflag -eq 1 ]]; then
        for gridind in $(seq 1 ${#GRIDHIST_INT_LOW[@]}); do
          thisgrid=$(echo "$gridind - 1" | bc)
          LC_ALL=en_US.UTF-8 gawk < module_gridhist/histdata_weighted.txt -v low=${GRIDHIST_INT_LOW[$thisgrid]} -v high=${GRIDHIST_INT_HIGH[$thisgrid]} '
          BEGIN {
            sumarea=0
          }
          ($3 >= low && $3 <= high) {
            sumarea+=$5
          }
          END {
            print "There are", sprintf("%'"'"'d", sumarea ), "square kilometers between", low, "and", high, "meters elevation (" sprintf("%0.01f", sumarea * 100 / 511217755) "% of Earth surface)"
          }
          '
        done
      fi
    else
      [[ $gridhist_hasrun -eq 0 ]] && echo "[-gridhist]: Target file ${GRIDHIST_FILE} does not exist or is empty." && gridhist_hasrun=1
    fi

    # ;;
    # esac
}


# Commands for plotting GIS datasets like points, lines, and grids
# To add: polygons

# Regloricter the module with tectoplot
TECTOPLOT_MODULES+=("gloric")

function tectoplot_defaults_gloric() {
    # Thicknesses are in points
    GLORIC_SMALL_WIDTH=0.25
    GLORIC_MEDIUM_WIDTH=0.5
    GLORIC_LARGE_WIDTH=0.75
    GLORIC_VERYLARGE_WIDTH=1.25
    GLORIC_TRANS=0
    GLORIC_COLOR="blue"
    gloric_nosmallflag=0

    GLORICDIR=${DATAROOT}"GloRiC_v10_shapefile/GloRiC_v10_shapefile/"
    GLORICDATA=${GLORICDIR}"GloRiC_v10.shp"
}

#############################################################################
### Argument processing function defines the flag (-example) and parses arguments

function tectoplot_args_gloric()  {
  # The following lines are required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -gloric)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-gloric:          plot river channels from GLORIC database
-gloric [[options]]

  Plots rivers scaled by size.

  Options:
  nosmall           Don't plot the small rivers
  color [color]     Change the color of the rivers
  scale [number]    Scale widths by given factor

--------------------------------------------------------------------------------
EOF
fi
    shift


    if [[ ! -s ${GLORICDATA} ]]; then
      echo "[-gloric]: GLORIC data not found at ${GLORICDATA}. Use tectoplot -getdata."
    else
      while ! arg_is_flag $1; do
        case $1 in
          nosmall)
            gloric_nosmallflag=1
            shift
            ((tectoplot_module_shift++))
            ;;
          color)
            shift
            ((tectoplot_module_shift++))
            if arg_is_flag $1; then
              echo "[-gloric]: color option requires argument"
              exit 1
            else
              GLORIC_COLOR=$1
              shift
              ((tectoplot_module_shift++))
            fi
            ;;
          scale)
            shift
            ((tectoplot_module_shift++))
            if arg_is_positive_float $1; then
              GLORIC_SCALE=$1
              shift
              ((tectoplot_module_shift++))
              GLORIC_SMALL_WIDTH=$(echo "${GLORIC_SMALL_WIDTH} * ${GLORIC_SCALE}" | bc -l)
              GLORIC_MEDIUM_WIDTH=$(echo "${GLORIC_MEDIUM_WIDTH} * ${GLORIC_SCALE}" | bc -l)
              GLORIC_LARGE_WIDTH=$(echo "${GLORIC_LARGE_WIDTH} * ${GLORIC_SCALE}" | bc -l)
              GLORIC_VERYLARGE_WIDTH=$(echo "${GLORIC_VERYLARGE_WIDTH} * ${GLORIC_SCALE}" | bc -l)
            else
              echo "[-gloric]: scale option requires positive number argument"
              exit 1
            fi
            ;;
          # trans)
          #   shift
          #   ((tectoplot_module_shift++))
          #   if arg_is_positive_float $1; then
          #     GLORIC_TRANS=$1
          #     shift
          #     ((tectoplot_module_shift++))
          #   else
          #     echo "[-gloric]: trans option requires positive number argument"
          #     exit 1
          #   fi
          #  ;;
          *)
            echo "[-gloric]: Argument $1 not recognized"
            exit 1
            ;;
        esac
      done

      plots+=("gloric")
    fi
    tectoplot_module_caught=1

    ;;
  esac
}

# function tectoplot_calculate_gloric()  {
# }

# function tectoplot_cpt_gloric() {
# }

function tectoplot_plot_gloric() {

  case $1 in

  gloric)
    info_msg "[-gloric]: Clipping GLORIC data"
    mkdir ./gloric/
    ogr2ogr -clipsrc ${MINLON} ${MINLAT} ${MAXLON} ${MAXLAT} ./gloric/clip.shp ${GLORICDATA}
    info_msg "[-gloric]: Separating GLORIC rivers by size"

    export CPL_LOG="/dev/null"
    if [[ $gloric_nosmallflag -eq 0 ]]; then
        ogr2ogr -sql "SELECT * FROM clip WHERE CAST(Reach_type as character(10)) like '%1_' OR CAST(Reach_type as character(10)) like '0'" ./gloric/small.shp ./gloric/clip.shp >/dev/null 2>&1
    fi
    ogr2ogr -sql "SELECT * FROM clip WHERE CAST(Reach_type as character(10)) like '%2_'" ./gloric/medium.shp ./gloric/clip.shp >/dev/null 2>&1
    ogr2ogr -sql "SELECT * FROM clip WHERE CAST(Reach_type as character(10)) like '%3_'" ./gloric/large.shp ./gloric/clip.shp >/dev/null 2>&1
    ogr2ogr -sql "SELECT * FROM clip WHERE CAST(Reach_type as character(10)) like '%4_'" ./gloric/verylarge.shp ./gloric/clip.shp >/dev/null 2>&1


    [[ -s ./gloric/small.shp ]] && gmt psxy ./gloric/small.shp -W${GLORIC_SMALL_WIDTH}p,${GLORIC_COLOR} -t${GLORIC_TRANS} --PS_LINE_CAP=round $RJOK $VERBOSE >> map.ps
    [[ -s ./gloric/medium.shp ]] && gmt psxy ./gloric/medium.shp -W${GLORIC_MEDIUM_WIDTH}p,${GLORIC_COLOR} -t${GLORIC_TRANS} --PS_LINE_CAP=round $RJOK $VERBOSE >> map.ps
    [[ -s ./gloric/large.shp ]] && gmt psxy ./gloric/large.shp -W${GLORIC_LARGE_WIDTH}p,${GLORIC_COLOR} -t${GLORIC_TRANS} --PS_LINE_CAP=round $RJOK $VERBOSE >> map.ps
    [[ -s ./gloric/verylarge.shp ]] && gmt psxy ./gloric/verylarge.shp -W${GLORIC_VERYLARGE_WIDTH}p,${GLORIC_COLOR} -t${GLORIC_TRANS} --PS_LINE_CAP=round $RJOK $VERBOSE >> map.ps

    # info_msg "[-gloric]: Plotting GLORIC rivers"
    # tectoplot -r ${MINLON} ${MAXLON} ${MINLAT} ${MAXLAT} -setvars { GIS_LINEEND_STYLE round } -RJ B -t -t0 -li ./gloric/small.shp ${GLORIC_COLOR} ${GLORIC_SMALL_WIDTH}p -li ./gloric/medium.shp ${GLORIC_COLOR} ${GLORIC_MEDIUM_WIDTH}p -li ./gloric/large.shp ${GLORIC_COLOR} ${GLORIC_LARGE_WIDTH}p -li ./gloric/verylarge.shp ${GLORIC_COLOR} ${GLORIC_VERYLARGE_WIDTH}p

    tectoplot_plot_caught=1
    ;;
  esac

}

# function tectoplot_legend_gloric() {
# }

# function tectoplot_legendbar_gloric() {
#   case $1 in
#     gloric_grid)
#       echo "G 0.2i" >> legendbars.txt
#       echo "B ${GRIDADDCPT[$current_usergridnumber]} 0.2i 0.1i+malu -Q -Bxaf+l\"$(basename ${GRIDADDFILE[$current_usergridnumber]})\"" >> legendbars.txt
#       barplotcount=$barplotcount+1
#       current_usergridnumber=$(echo "$current_usergridnumber + 1" | bc -l)
#       tectoplot_caught_legendbar=1
#       ;;
#   esac
# }

# function tectoplot_post_gloric() {
# }

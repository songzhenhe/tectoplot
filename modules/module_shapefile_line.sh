
# Plot polyline shapefiles (or any other format recognized by ogr2ogr)

# UPDATED

TECTOPLOT_MODULES+=("shapefile_line")

# function tectoplot_defaults_shapefile_line() {
#   # declare -A m_shapefile_line_thiswidth
# }

#############################################################################
### Argument processing function defines the flag (-example) and parses arguments

function tectoplot_args_shapefile_line()  {
  # The following lines are required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -shp_q)
  cat <<-EOF > shp_q
des -shp_q query a shapefile and report all field names
req m_shapefile_query_file file
    shapefile to query
  ;;
EOF

  if [[ $USAGEFLAG -eq 1 ]]; then
    tectoplot_usage_opts shp_q
  else
    tectoplot_get_opts shp_q "${@}"

    plots+=("m_shapefile_shp_q")

    tectoplot_module_caught=1
  fi
  export CPL_LOG="/dev/null"
  ;;


  -shp_l)
  cat <<-EOF > shp_l
des -shp_l plot a polyline shapefile, color using CPT and possibly vary line width
req m_shapefile_line_file file
    shapefile to plot
opt color m_shapefile_line_color string "black"
    line color if not using CPT
opt data m_shapefile_line_data string "none"
    Field name for coloring using CPT
opt cpt m_shapefile_line_cpt cpt turbo
    CPT to use when coloring by data value
opt widthbin m_shapefile_line_widthbin int 0
    separate input into specified number of bins based on data min/max values
opt widthmin m_shapefile_line_widthmin float 0.1
    minimum width of line, points
opt widthmax m_shapefile_line_widthmax float 3
    maximum width of line, points
opt minmax m_shapefile_line_minmax string "region"
    calculate auto CPT stretch from "region" or "dataset"
opn clip m_shapefile_line_clipflag flag 1
    clip shapefile to AOI before plotting; default is on
opt inv m_shapefile_line_cptinv flag 0
    invert CPT
mes Default CPT stretching is calculated using min/max from region
mes Data are reprojected to WGS1984 when clipping happens
EOF

  if [[ $USAGEFLAG -eq 1 ]]; then
    tectoplot_usage_opts shp_l
  else
    tectoplot_get_opts shp_l "${@}"

    plots+=("m_shapefile_shp_l")

    tectoplot_module_caught=1
  fi
  export CPL_LOG="/dev/null"
  ;;

  esac
}

function tectoplot_calculate_shapefile_line()  {

  [[ ! -d ./shapefile_line/ ]] && mkdir ./shapefile_line/

  for ship_ind in $(seq 1 ${#m_shapefile_line_clipflag}); do
    if [[ ${m_shapefile_line_clipflag} -eq 1 ]]; then
      info_msg "[-shp_l]: Clipping shapefile ${m_shapefile_line_file[$ship_ind]} to AOI"

      echo ${MINLON} ${MINLAT} > clip.txt
      echo ${MINLON} ${MAXLAT} >> clip.txt
      echo ${MAXLON} ${MAXLAT} >> clip.txt
      echo ${MAXLON} ${MINLAT} >> clip.txt
      echo ${MINLON} ${MINLAT} >> clip.txt

      ogr2ogr -skipfailures -t_srs "EPSG:4326" -clipsrclayer clip.txt ./shapefile_line/clip_${ship_ind}.shp ${m_shapefile_line_file[$ship_ind]} >/dev/null 2>&1
      m_shapefile_line_file[$ship_ind]=./shapefile_line/clip_${ship_ind}.shp
    fi
  done

}

# function tectoplot_cpt_shapefile_line() {
# }

function tectoplot_plot_shapefile_line() {

  case $1 in

  m_shapefile_shp_q)
    echo "Information for ${m_shapefile_query_file[$tt]}:"
    ogrinfo -so -al ${m_shapefile_query_file[$tt]}
  ;;

  m_shapefile_shp_l)

    info_msg "[-shp_l]: Extracting data from ${m_shapefile_line_file[$tt]}"
    m_shapefile_line_scaletitle[$tt]=$(basename ${m_shapefile_line_file[$tt]})

    # If we are coloring by an attribute, do so
    if [[ ${m_shapefile_line_data[$tt]} != "none" ]]; then

      m_shapefile_line_selectfile=${m_shapefile_line_file[$tt]}
      case ${m_shapefile_line_minmax[$tt]} in
        region)
          [[ -s ./shapefile_line/clip_${tt}.shp ]] && m_shapefile_line_selectfile=./shapefile_line/clip_${tt}.shp
        ;;
        dataset)
          m_shapefile_line_selectfile=${m_shapefile_line_file[$tt]}
        ;;
        *)
          echo "[-shp_l]: minmax data region ${m_shapefile_line_minmax[$tt]} should be region or dataset"
          exit 1
        ;;
      esac

      ogr2ogr -f CSV -sql "SELECT MIN(${m_shapefile_line_data[$tt]}) as min_value, MAX(${m_shapefile_line_data[$tt]}) as max_value FROM $(basename ${m_shapefile_line_selectfile} | sed 's/\(.*\)\..*/\1/')" ./shapefile_line/minmax_${tt}.csv ${m_shapefile_line_selectfile}
      m_shapefile_line_range=($(tail -n 1 ./shapefile_line/minmax_${tt}.csv | gawk -F, '{print $1+0, $2+0}'))

      m_shapefile_line_cptmin[$tt]=${m_shapefile_line_range[0]}
      m_shapefile_line_cptmax[$tt]=${m_shapefile_line_range[1]}

      info_msg "[-shp_l]: ${m_shapefile_line_data[$tt]} has range ${m_shapefile_line_cptmin[$tt]} / ${m_shapefile_line_cptmax[$tt]}"

      if [[ $(echo "${m_shapefile_line_cptmin[$tt]} == ${m_shapefile_line_cptmax[$tt]}" | bc -l ) -eq 1 ]]; then

        echo "[-shp_l]: CPT plotting of ${m_shapefile_line_file[$tt]} not possible because data ${m_shapefile_line_data[$tt]} has 0 range"
        exit 1
      fi

      if [[ ${m_shapefile_line_cptinv[$tt]} == 1 ]]; then
        m_shapefile_line_cptinvcmd="-I"
      else
        m_shapefile_line_cptinvcmd=""
      fi

      gmt makecpt -C${m_shapefile_line_cpt[$tt]} -T${m_shapefile_line_cptmin[$tt]}/${m_shapefile_line_cptmax[$tt]} ${m_shapefile_line_cptinvcmd} > ${F_CPTS}shapefile_line_${tt}.cpt

      m_shapefile_line_cptcmd="-C${F_CPTS}shapefile_line_${tt}.cpt -aZ=${m_shapefile_line_data[$tt]}"

    else
      m_shapefile_line_cptcmd=""
      m_shapefile_line_selectfile=${m_shapefile_line_file[$tt]}
    fi

    if [[ $(echo "${m_shapefile_line_widthbin[$tt]} > 0" | bc) -eq 1 && ${m_shapefile_line_data[$tt]} != "none" ]]; then
      m_shapefile_line_widthflag=1
      # echo "Separating into ${m_shapefile_line_widthbin[$tt]} bins"
      for this_bin in $(seq 0 $((${m_shapefile_line_widthbin[$tt]} - 1 )) ); do

        # Find the width

        m_shapefile_line_thiswidth[$tt,$this_bin]=$(echo "${m_shapefile_line_widthmin[$tt]} + (${this_bin}) * (${m_shapefile_line_widthmax[$tt]} - ${m_shapefile_line_widthmin[$tt]})/(${m_shapefile_line_widthbin[$tt]} - 1)" | bc -l)

        m_shapefile_lowbound[$tt,$this_bin]=$(echo "${m_shapefile_line_cptmin[$tt]} + (${this_bin}) * (${m_shapefile_line_cptmax[$tt]} - ${m_shapefile_line_cptmin[$tt]})/(${m_shapefile_line_widthbin[$tt]} - 1)" | bc -l | awk '{printf "%f", $0}')
        m_shapefile_upbound[$tt,$this_bin]=$(echo "${m_shapefile_line_cptmin[$tt]} + (${this_bin} + 1) * (${m_shapefile_line_cptmax[$tt]} - ${m_shapefile_line_cptmin[$tt]})/(${m_shapefile_line_widthbin[$tt]} - 1)" | bc -l | awk '{printf "%f", $0}')

        # echo width is ${m_shapefile_line_thiswidth} and bounds are ${m_shapefile_lowbound} "/" ${m_shapefile_upbound}

        # echo         ogr2ogr -sql "SELECT * from $(basename ${m_shapefile_line_file[$tt]} | sed 's/\(.*\)\..*/\1/') where ((${m_shapefile_line_data[$tt]} >= ${m_shapefile_lowbound}) and (${m_shapefile_line_data[$tt]} < ${m_shapefile_upbound}))" ./shapefile_line/selected_${tt}_${this_bin}.shp ${m_shapefile_line_file[$tt]}

        ogr2ogr -sql "SELECT * from $(basename ${m_shapefile_line_file[$tt]} | sed 's/\(.*\)\..*/\1/') where ((${m_shapefile_line_data[$tt]} >= ${m_shapefile_lowbound[$this_bin]}) and (${m_shapefile_line_data[$tt]} < ${m_shapefile_upbound[$this_bin]}))" ./shapefile_line/selected_${tt}_${this_bin}.shp ${m_shapefile_line_file[$tt]}

        gmt psxy ./shapefile_line/selected_${tt}_${this_bin}.shp -W${m_shapefile_line_thiswidth[$tt,$this_bin]}p,${m_shapefile_line_color[$tt]} ${m_shapefile_line_cptcmd} --PS_LINE_CAP=round --PS_LINE_JOIN=round $RJOK $VERBOSE >> map.ps
  # echo gmt psxy ./shapefile_line/selected_${tt}_${this_bin}.shp -W${m_shapefile_line_thiswidth}p,${m_shapefile_line_color[$tt]} ${m_shapefile_line_cptcmd} --PS_LINE_CAP=round --PS_LINE_JOIN=round $RJOK $VERBOSE \>\> map.ps

      done

    else
      info_msg "[-shapefile_line]: plotting ${m_shapefile_line_file[$tt]} for instance ${tt} without width"
      gmt psxy ${m_shapefile_line_file[$tt]} -W1p,${m_shapefile_line_color[$tt]} ${m_shapefile_line_cptcmd} --PS_LINE_CAP=round $RJOK $VERBOSE >> map.ps
      # echo gmt psxy ${m_shapefile_line_file[$tt]} -W1p,${m_shapefile_line_color[$tt]} ${m_shapefile_line_cptcmd} --PS_LINE_CAP=round $RJOK $VERBOSE \>\> map.ps
    fi

    tectoplot_plot_caught=1
    ;;
  esac

}

function tectoplot_legend_shapefile_line() {

  case $1 in

  m_shapefile_shp_l)
    local this_ind

    # Plot all lines at one time
    if [[ $m_shapefile_line_widthflag -eq 1 ]]; then
      for this_ind in $(seq 0 $((${m_shapefile_line_widthbin[$tt]} - 1 )) ); do
        init_legend_item "m_shapefile_shp_l_${this_ind}"

        # Make a line
        EXTRALON=$(echo "$CENTERLON + (${MAXLON} - ${CENTERLON})/20" | bc -l)
        EXTRALON_M=$(echo "$CENTERLON - (${MAXLON} - ${CENTERLON})/20" | bc -l)

        echo $EXTRALON_M $CENTERLAT > line.txt
        echo $EXTRALON $CENTERLAT >> line.txt

        gmt psxy line.txt -W${m_shapefile_line_thiswidth[$tt,$this_ind]}p,black -R -J -O -K ${VERBOSE} >> ${LEGFILE}
        echo "$CENTERLON $CENTERLAT ${m_shapefile_lowbound[$tt,$this_ind]} <= ${m_shapefile_line_data[$tt]} < ${m_shapefile_upbound[$tt,$this_ind]}" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE ${RJOK} -Y0.10i >> ${LEGFILE}

        close_legend_item "m_shapefile_shp_l_${this_ind}"
      done

      init_legend_item "m_shapefile_shp_l_title"
        echo "$CENTERLON $CENTERLAT ${m_shapefile_line_file[$tt]}: ${m_shapefile_line_data[$tt]}" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE ${RJOK} -Y0.10i >> ${LEGFILE}
      close_legend_item "m_shapefile_shp_l_title"

    fi
    tectoplot_legend_caught=1
    ;;
  esac
}

function tectoplot_legendbar_shapefile_line() {
  case $1 in
    m_shapefile_shp_l)
      if [[ -s ${F_CPTS}shapefile_line_${tt}.cpt ]]; then
        echo "G 0.2i" >> ${LEGENDDIR}legendbars.txt
        echo "B ${F_CPTS}shapefile_line_${tt}.cpt 0.2i 0.1i+malu -Bxaf+l\"${m_shapefile_line_scaletitle[$tt]}\"" >> ${LEGENDDIR}legendbars.txt
        barplotcount=$barplotcount+1
        tectoplot_caught_legendbar=1
      fi
      ;;
  esac
}

# function tectoplot_post_shapefile_line() {
# }

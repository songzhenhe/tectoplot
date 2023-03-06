
TECTOPLOT_MODULES+=("gps")

# UPDATED
# DOWNLOAD
# NEW OPT

function tectoplot_defaults_gps() {

  m_gps_sourcestring="GPS velocity data from compilation of Kreemer et al., 2014 doi:10.1002/2014GC005407"
  m_gps_short_sourcestring="GPS-GSRM"

  # GPS data is distributed with plate motion data alongside tectoplot
  m_gps_dir="${PLATEMODELSDIR}GSRM"
  m_midas_dir="${DATAROOT}midas/"

  # A listing of the various files in format midas.XXX.txt on the UNR server at URL http://geodesy.unr.edu/velocities/
m_gps_midasfiles=(
"IGS08"
"IGS14"
"AF"
"AN"
"AR"
"AU"
"BU"
"CA"
"CO"
"EU"
"IN"
"MA"
"NA"
"NB"
"NZ"
"OK"
"ON"
"PA"
"PM"
"PS"
"SA"
"SB"
"SC"
"SL"
"SO"
"SU"
"WL")


}

function tectoplot_args_gps()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -g2)
  tectoplot_get_opts_inline '
des -g2 plot GPS velocities
opt file m_gps_userfile file "none"
  use a custom data file
opt ref m_gps_ref string "NNR"
  set plate with given ID as reference plate, or use no-net-rotation (NNR)
opt noplot m_gps_noplotflag flag 0
  prevent plotting of the GPS velocities
opt fill m_gps_fill string "black"
  set the fill color
opt linewidth m_gps_linewidth float 0
  set the line stroke width (p)
opt linewidth m_gps_linecolor string "black"
  set the line stroke color
opt cpt m_gps_cpt string "none"
  color GPS vectors by velocity
opt legvel m_gps_legvel float 0
  set the scale of the velocity arrow shown in the legend
opt text m_gps_textflag flag 0
  plot velocity text (mm/yr) for each arrow
opt sitetext m_gps_sitetextflag flag 0
  plot site ID text next to each arrow
opt fontsize m_gps_fontsize string 6
  set font size for plotted velocity text
opt font m_gps_font string "Helvetica"
  set font for plotted velocity text
opt fontcolor m_gps_fontcolor string "black"
  set font color for plotted velocity text
opt zcol m_gps_zcolumn float 0
  set column number for Z values used to color arrows (first column is 1)
opt colorunit m_gps_cptunit string "mm/yr"
  define the units used to label colorbar and arrows
opt addword m_gps_addword string ""
  add a word between GPS and velocity in colorbar legend (e.g. vertical)
opt arrow m_gps_arrow string "default"
  set arrow format (same arguments as -arrow)
opt vertbar m_gps_vertscale float 0
  if nonzero, plot vertical bars only (can layer -g2 calls) from
opt circle m_gps_circleflag flag 0
  plot a white circle with black stroke at site location
mes GPS velocity data are plain text with whitespace separated columns:
mes Lon Lat E N SE SN corr ID Reference
mes   E, N are velocities to the East and North, in mm/yr
mes   SE, SN are uncertainties of E,N components in mm/yr
mes   corr is the correlation between SE and SN
mes   ID is the site ID
mes   Reference is a string, usually a reference to the data source
mes   Note: If -pg is active then data are cropped using polygon
exa tectoplot -r =EU -a -g2 AF
' "${@}" || return

  plots+=("m_gps_g2")
  cpts+=("m_gps_g2")
  ;;

  -gx)
    tectoplot_get_opts_inline '
des -gx plot along-profile and across-profile GPS velocities
mes plot gps projected onto profiles
  ' "${@}" || return
  after_plots+=("m_gps_gx")
  ;;
  esac
}


# function tectoplot_download_gps() {

  # if [[ ! -s ${m_midas_dir}midas.gpkg ]]; then
  #   if [[ ! -d ${m_midas_dir} ]]; then
  #     mkdir -p ${m_midas_dir}
  #   fi
  #   echo "Getting MIDAS dataset"
  #   local this_id
  #   for this_id in ${m_gps_midasfiles[@]}; do
  #     curl "http://geodesy.unr.edu/velocities/midas.${this_id}.txt" > ${m_midas_dir}midas.${this_id}.txt
  #   done
  # fi
# }

function tectoplot_calculate_gps()  {

  # Only perform calculations if we are loading a dataset

  if [[ ! -z ${m_gps_ref[$tt]} ]] ; then
    if [[ -s ${m_gps_userfile[$tt]} ]]; then

      if [[ ${m_gps_userfile[$tt]} == *.vel ]]; then
        echo "Found .vel format GPS file"

        # Parse the file into the gmt psvelo format
        gawk < ${m_gps_userfile[$tt]} '
          BEGIN {
            readdata=0
          }
          {
            if ($1==dN/dt) {
              readdata=1
            }

          }'
      fi

      m_gps_file[$tt]=${m_gps_userfile[$tt]}
    elif [[ -s ${m_gps_dir}/GPS_${m_gps_ref[$tt]}.gmt ]]; then
      m_gps_file[$tt]=${m_gps_dir}/GPS_${m_gps_ref[$tt]}.gmt
    else
      echo "[-g2]: no data file ${m_gps_dir}/GPS_${m_gps_ref[$tt]}.gmt found"
      exit 1
    fi

    # Select by polygon if specified
    if [[ -s ${POLYGONAOI} ]]; then
      gmt select ${m_gps_file[$tt]} -F${POLYGONAOI} -Vn | tr '\t' ' ' > ${F_GPS}gps_polygon_${tt}.txt
      m_gps_file[$tt]=${F_GPS}gps_polygon_${tt}.txt
    else
      gmt select ${m_gps_file[$tt]} -R -fg > ${F_GPS}gps_aoi_${tt}.txt
      m_gps_file[$tt]=${F_GPS}gps_aoi_${tt}.txt
    fi

    # Rotate the data if asked

    if [[ $gpscorflag -eq 1 ]]; then
      echo "Rotating GPS data"
      gawk '
        @include "tectoplot_functions.awk"
        ($1+0==$1) {
          eulervec('${gpscorlat}', '${gpscorlon}', '${gpscorw}', 0, 0, 0, $1, $2)
          print $1, $2, $3-eulervec_E, $4-eulervec_N, $5, $6, $7, $8, $9
        }
      ' ${m_gps_file[$tt]} > gps_rotated_${tt}.dat 
      m_gps_file[$tt]=gps_rotated_${tt}.dat 
      echo "new file is ${m_gps_file[$tt]}"
    fi

    # Create the XY file
    gawk '
    {
      az=atan2($3, $4) * 180 / 3.14159265358979
      if (az > 0) {
        print $1, $2, az, sqrt($3*$3+$4*$4), $8
      } else {
        print $1, $2, az+360, sqrt($3*$3+$4*$4), $8
      }
    }' < ${m_gps_file[$tt]} > ${F_GPS}gps_${tt}.xy
    m_gps_xyfile[$tt]=${F_GPS}gps_${tt}.xy

    local minval
    local maxval

    if [[ ${m_gps_zcolumn[$tt]} -ne 0 ]]; then
      # We use the data column from the original file
      echo vert
      m_gps_minvel[$tt]=$(gawk < ${m_gps_file[$tt]} 'BEGIN{ minv=9999 } {if ($'${m_gps_zcolumn[$tt]}'<minv) {minv=$'${m_gps_zcolumn[$tt]}' } } END {print minv}')
      m_gps_maxvel[$tt]=$(gawk < ${m_gps_file[$tt]} 'BEGIN{ maxv=-9999 } {if ($'${m_gps_zcolumn[$tt]}'>maxv) { maxv=$'${m_gps_zcolumn[$tt]}' } } END {print maxv}')
      m_gps_legvel[$tt]=$(gawk '
        function abs(v)        { return v < 0 ? -v : v          }
        function max(x,y)      { return (x>y)?x:y               }
        BEGIN {
          print max(abs('${m_gps_maxvel[$tt]}'), abs('${m_gps_minvel[$tt]}'))
        }')
    else
      # We use the derived velocity from the XY file
      m_gps_minvel[$tt]=0
      m_gps_maxvel[$tt]=$(gawk < ${m_gps_xyfile[$tt]}  'BEGIN{ maxv=0 } {if ($4>maxv) { maxv=$4 } } END {print maxv+1}')
      m_gps_legvel[$tt]=${m_gps_maxvel[$tt]}
    fi

    echo "D ${m_gps_file[$tt]} 1 -Sc0.1i -Gblack" >>  ${F_PROFILES}profile_commands.txt
  fi
}

function tectoplot_cpt_gps() {
  case $1 in
  m_gps_g2)

    if [[ ${m_gps_cpt[$tt]} != "none" ]]; then

      gmt makecpt -C${m_gps_cpt[$tt]} -I -Do -T${m_gps_minvel[$tt]}/${m_gps_maxvel[$tt]} -Z -N $VERBOSE > ${F_CPTS}gps_${tt}.cpt
      m_gps_cpt_used[$tt]=${F_CPTS}gps_${tt}.cpt

      tectoplot_cpt_caught=1
    fi
    ;;
  esac
}

function tectoplot_plot_gps() {
  case $1 in
    m_gps_g2)

    info_msg "[-g2]: Plotting GPS velcocities: ${m_gps_file[$tt]}"
    echo GPS_ELLIPSE is ${GPS_ELLIPSE}

    unset m_gps_cmd

    case ${m_gps_arrow[$tt]} in
      default)
        m_gps_arrowfmt[$tt]=${ARROWFMT}
        ;;
      narrower)
        m_gps_arrowfmt[$tt]="0.01/0.14/0.06"
        ;;
      narrow)
        m_gps_arrowfmt[$tt]="0.02/0.14/0.06"
        ;;
      normal)
        m_gps_arrowfmt[$tt]="0.06/0.12/0.06"
        ;;
      wide)
        m_gps_arrowfmt[$tt]="0.08/0.14/0.1"
        ;;
      wider)
        m_gps_arrowfmt[$tt]="0.1/0.3/0.2"
        ;;
      *)
        m_gps_arrowfmt[$tt]=${ARROWFMT}
        ;;
    esac

    if [[ ${m_gps_linewidth[$tt]} -ne 0 ]]; then
      m_gps_strokecmd[$tt]="-W${m_gps_linewidth[$tt]}p,${m_gps_linecolor[$tt]}"
    fi

    if [[ ${m_gps_cpt[$tt]} != "none" ]]; then
      m_gps_fillcmd[$tt]="-C${m_gps_cpt_used[$tt]}"
    else
      m_gps_fillcmd[$tt]="-G${m_gps_fill[$tt]}"
    fi

    if [[ ${m_gps_noplot[$tt]} -ne 1 ]]; then

      if [[ ${m_gps_vertscale[$tt]} -eq 0 ]]; then

        if [[ ${m_gps_zcolumn[$tt]} -eq 0 ]]; then
          gmt psvelo ${m_gps_file[$tt]} ${m_gps_fillcmd[$tt]} ${m_gps_strokecmd[$tt]} -A${m_gps_arrowfmt[$tt]} -Se${VELSCALE}/${GPS_ELLIPSE}/0 $RJOK ${VERBOSE} >> map.ps
        else
          gawk < ${m_gps_file[$tt]} '{print $1, $2, $3, $4, $5, $6, $7, $'${m_gps_zcolumn[$tt]}'}' | gmt psvelo ${m_gps_fillcmd[$tt]} ${m_gps_strokecmd[$tt]} -Zu -A${m_gps_arrowfmt[$tt]} -Se${VELSCALE}/${GPS_ELLIPSE}/0 $RJOK ${VERBOSE} >> map.ps
        fi

        echo $m_gps_short_sourcestring >> ${SHORTSOURCES}
        echo $m_gps_sourcestring >> ${LONGSOURCES}

        if [[ ${m_gps_textflag[$tt]} -eq 1 ]]; then
          gawk < ${m_gps_xyfile[$tt]} '{printf("%s %s %.1f\n", $1, $2, $4)}' | gmt pstext -Dj2p -F+f${m_gps_fontsize[$tt]}p,${m_gps_font[$tt]},${m_gps_fontcolor[$tt]}+jBL ${RJOK} ${VERBOSE} >> map.ps
        fi
        if [[ ${m_gps_sitetextflag[$tt]} -eq 1 ]]; then
          gawk < ${m_gps_xyfile[$tt]} '{printf("%s %s %s\n", $1, $2, $5)}' | gmt pstext -Dj2p -F+f${m_gps_fontsize[$tt]}p,${m_gps_font[$tt]},${m_gps_fontcolor[$tt]}+jTR ${RJOK} ${VERBOSE} >> map.ps
        fi
      else
        info_msg "[-g2]: plotting verticals from column ${m_gps_zcolumn[$tt]}"
        # Velocity ellipses: in X,Y,Vx,Vy,SigX,SigY,CorXY,name format
        local projw=$(gmt mapproject -Ww ${RJSTRING})
        local projh=$(gmt mapproject -Wh ${RJSTRING})

        if [[ ${m_gps_cpt[$tt]} == "none" ]]; then
          # Draw arrows colored blue for down, red for up
          gawk < ${m_gps_file[$tt]} 'BEGIN { OFMT="%.12f" } ($'${m_gps_zcolumn[$tt]}'>=0){print $1, $2, 0, $'${m_gps_zcolumn[$tt]}', 0, 0, 0, "id"}' > toplot_pos.txt
          gawk < ${m_gps_file[$tt]} 'BEGIN { OFMT="%.12f" } ($'${m_gps_zcolumn[$tt]}'<0){print $1, $2, 0, $'${m_gps_zcolumn[$tt]}', 0, 0, 0, "id"}' > toplot_neg.txt
          gmt mapproject toplot_pos.txt -R -J > toplot_project_pos.txt
          gmt mapproject toplot_neg.txt -R -J > toplot_project_neg.txt
          # | gmt psxy -Sv12p -W2p,black ${RJOK} ${VERBOSE} >> map.ps


          gmt_init_tmpdir
            gmt psvelo toplot_project_pos.txt -Se${m_gps_vertscale[$tt]}p/0/0 -A+bc+et+n+p -W0.2p,red -Gred -R0/${projw}/0/${projh} -JX${projw}/${projh} -O -K >> map.ps
            gmt psvelo toplot_project_pos.txt -Se${m_gps_vertscale[$tt]}p/0/0 -A+e+n+p -W2p,red -Gred -R0/${projw}/0/${projh} -JX${projw}/${projh} -O -K >> map.ps
            gmt psvelo toplot_project_neg.txt -Se${m_gps_vertscale[$tt]}p/0/0 -A+bc+et+n+p -W0.2p,blue -Gblue -R0/${projw}/0/${projh} -JX${projw}/${projh} -O -K >> map.ps
            gmt psvelo toplot_project_neg.txt -Se${m_gps_vertscale[$tt]}p/0/0 -A+e+n+p -W2p,blue -Gblue -R0/${projw}/0/${projh} -JX${projw}/${projh} -O -K >> map.ps
          gmt_remove_tmpdir
        else
          # Draw arrows using CPT
          gawk < ${m_gps_file[$tt]} 'BEGIN { OFMT="%.12f" } {print $1, $2, 0, $'${m_gps_zcolumn[$tt]}', 0, 0, 0, "id"}' > toplot.txt
          gmt mapproject toplot.txt -R -J > toplot_project.txt

          gmt_init_tmpdir
          echo gmt psvelo toplot_project.txt -Se${m_gps_vertscale[$tt]}p/0/0 -A+bc+et+n+p -W0.2p+c ${m_gps_fillcmd[$tt]} -Zn -R0/${projw}/0/${projh} -JX${projw}/${projh} -O -K
            gmt psvelo toplot_project.txt -Se${m_gps_vertscale[$tt]}p/0/0 -A+bc+et+n+p -W0.2p+c ${m_gps_fillcmd[$tt]} -Zn -R0/${projw}/0/${projh} -JX${projw}/${projh} -O -K >> map.ps
            gmt psvelo toplot_project.txt -Se${m_gps_vertscale[$tt]}p/0/0 -A+e+n+p -W2p+c ${m_gps_fillcmd[$tt]} -Zn -R0/${projw}/0/${projh} -JX${projw}/${projh} -O -K >> map.ps
          gmt_remove_tmpdir
        fi

        # Vector: -Sv|V<size>[+a<angle>][+b][+e][+h<shape>][+j<just>][+l][+m][+n[<norm>[/<min>]]][+o<lon>/<lat>][+q][+r][+s][+t[b|e]<trim>][+z]
       # Direction and length must be in columns 3-4. If -SV rather than -Sv is selected, psxy will expect azimuth and length and convert azimuths based on the chosen map projection.
       # Append length of vector head. Note: Left and right sides are defined by looking from start to end of vector. Optional modifiers:
       # +a Set <angle> of the vector head apex [30]
       # +b Place a vector head at the beginning of the vector [none]. Append t for terminal, c for circle, s for square, a for arrow [Default], i for tail, A for plain arrow, and I for plain tail. Append l|r to only draw left or right side of this head [both sides].
       # +e Place a vector head at the end of the vector [none]. Append t for terminal, c for circle, s for square, a for arrow [Default], i for tail, A for plain arrow, and I for plain tail. Append l|r to only draw left or right side of this head [both sides].
       # +h Set vector head shape in -2/2 range [0].
       # +j Justify vector at (b)eginning [Default], (e)nd, or (c)enter.

      fi
    fi

    tectoplot_plot_caught=1
    ;;

    m_gps_gx)
      # xdist, comp1, err1, comp2, err2, lon, lat, projlon, projlat, azss, az[fracint], comp1_vn, comp1_ve, comp2_vn, comp2_ve, id, source

      for this_data in ${F_PROFILES}*gps_data.txt; do
        echo plotting file ${this_data}
        gmt psxy $this_data -Sc0.05i -i7,8 -W1p,red ${RJOK} ${VERBOSE} >> map.ps

        # psvelo is lon, lat, ve, vn, sve, svn
        gawk < $this_data '{print $8, $9, $12, $13, $3, $3, 0, $16}' | gmt psvelo -W0.1p,black -Gred -A"0.06/0.12/0.06" -Se${VELSCALE}/${GPS_ELLIPSE}/0 $RJOK ${VERBOSE} >> map.ps
        gawk < $this_data '{print $8, $9, $14, $15, $5, $5, 0, $16}' | gmt psvelo -W0.1p,black -Gblue -A"0.06/0.12/0.06" -Se${VELSCALE}/${GPS_ELLIPSE}/0 $RJOK ${VERBOSE} >> map.ps
      done
      tectoplot_plot_caught=1
    ;;
  esac
}

function tectoplot_legendbar_gps() {
  case $1 in
    m_gps_g2)
      if [[ ${m_gps_cpt[$tt]} != "none" ]]; then
        if [[ ${m_gps_vertscale[$tt]} -eq 0 ]]; then
          echo "G 0.2i" >> ${LEGENDDIR}legendbars.txt
          echo "B ${m_gps_cpt_used[$tt]} 0.2i 0.1i+malu ${LEGENDBAR_OPTS} -Bxaf+l\"GPS horizontal velocity (${m_gps_cptunit[$tt]})\"" >> ${LEGENDDIR}legendbars.txt
        else
          echo "G 0.2i" >> ${LEGENDDIR}legendbars.txt
          echo "B ${m_gps_cpt_used[$tt]} 0.2i 0.1i+malu ${LEGENDBAR_OPTS} -Bxaf+l\"GPS vertical velocity (${m_gps_cptunit[$tt]})\"" >> ${LEGENDDIR}legendbars.txt
        fi
        barplotcount=$barplotcount+1
      fi
      tectoplot_legendbar_caught=1
    ;;
  esac
}

function tectoplot_legend_gps() {
  case $1 in
  m_gps_g2)

    init_legend_item "gps_${tt}"

    if [[ ${m_gps_vertscale[$tt]} -eq 0 ]]; then
      local GPSMAXVEL_INT=$(echo "scale=0;(${m_gps_legvel[$tt]})/1" | bc)
      local GPSMESSAGE="GPS ($GPSMAXVEL_INT ${m_gps_cptunit[$tt]} / ${GPS_ELLIPSE_TEXT})"
      local GPSoffset=$(echo "(${#GPSMESSAGE} + 2)* 6 * 0.5" | bc -l)
      echo "$CENTERLON $CENTERLAT ${GPSMESSAGE}" | gmt pstext -F+f6p,Helvetica,black+jLM -X0.15i ${RJOK} ${VERBOSE} >> ${LEGFILE}
      echo "$CENTERLON $CENTERLAT $GPSMAXVEL_INT 0 1 1 0 ID" | gmt psvelo ${m_gps_fillcmd[$tt]} ${m_gps_strokecmd[$tt]} -A${m_gps_arrowfmt[$tt]} -Se${VELSCALE}/${GPS_ELLIPSE}/0 -X${GPSoffset}p -L ${RJOK} $VERBOSE >> ${LEGFILE} 2>/dev/null
    else
      local GPSMAXVEL_INT=$(echo "scale=0;(${m_gps_legvel[$tt]})/1" | bc)
      local GPSMESSAGE="Vertical GPS ($GPSMAXVEL_INT ${m_gps_cptunit[$tt]})"
      local GPSoffset=$(echo "(${#GPSMESSAGE} + 4)* 6 * 0.5" | bc -l)
      echo "$CENTERLON $CENTERLAT ${GPSMESSAGE}" | gmt pstext -F+f6p,Helvetica,black+jLM -X0.15i ${RJOK} ${VERBOSE} >> ${LEGFILE}
      # echo "$CENTERLON $CENTERLAT $GPSMAXVEL_INT 0 1 1 0 ID" | gmt psvelo ${m_gps_fillcmd[$tt]} ${m_gps_strokecmd[$tt]} -A${m_gps_arrowfmt[$tt]} -Se${VELSCALE}/${GPS_ELLIPSE}/0 -X${GPSoffset}p -L ${RJOK} $VERBOSE >> ${LEGFILE} 2>/dev/null

      local projw=$(gmt mapproject -Ww ${RJSTRING})
      local projh=$(gmt mapproject -Wh ${RJSTRING})

      if [[ ${m_gps_cpt[$tt]} != "none" ]]; then

        gawk < ${m_gps_file[$tt]} 'BEGIN { OFMT="%.12f" } {print $1, $2, 0, $'${m_gps_zcolumn[$tt]}', 0, 0, 0, "id"}' > toplot.txt
        gmt mapproject toplot.txt -R -J > toplot_project.txt

        gmt_init_tmpdir
          echo "$CENTERLON $CENTERLAT $GPSMAXVEL_INT 0 0 0 0 ID" | gmt mapproject ${RJSTRING} | gmt psvelo -Se${m_gps_vertscale[$tt]}p/0/0 -A+bc+et+n+p -W0.2p+c ${m_gps_fillcmd[$tt]} -Zn -R0/${projw}/0/${projh} -JX${projw}/${projh} -O -K ${VERBOSE} -Xa${GPSoffset}p >> ${LEGFILE} 2>/dev/null
          echo "$CENTERLON $CENTERLAT $GPSMAXVEL_INT 0 0 0 0 ID" | gmt mapproject ${RJSTRING} | gmt psvelo -Se${m_gps_vertscale[$tt]}p/0/0 -A+e+n+p -W2p+c ${m_gps_fillcmd[$tt]} -Zn -R0/${projw}/0/${projh} -JX${projw}/${projh} -O -K -Xa${GPSoffset}p >> ${LEGFILE} 2>/dev/null
        gmt_remove_tmpdir
      else
        echo "$CENTERLON $CENTERLAT up" | gmt pstext -F+f4p,Helvetica,black+jRM -Xa${GPSoffset}p -Ya0.05i -Dj4p ${RJOK} ${VERBOSE} >> ${LEGFILE}
        echo "$CENTERLON $CENTERLAT down" | gmt pstext -F+f4p,Helvetica,black+jRM -Xa${GPSoffset}p -Ya-0.05i -Dj4p ${RJOK} ${VERBOSE} >> ${LEGFILE}


        gmt_init_tmpdir
          echo "$CENTERLON $CENTERLAT $GPSMAXVEL_INT 0 0 0 0 up" | gmt mapproject ${RJSTRING} | gmt psvelo -Se${m_gps_vertscale[$tt]}p/0/0 -A+bc+et+n+p -W0.2p,red -Gred -R0/${projw}/0/${projh} -JX${projw}/${projh} -O -K ${VERBOSE} -Xa${GPSoffset}p -Ya0.05i >> ${LEGFILE} 2>/dev/null
          echo "$CENTERLON $CENTERLAT $GPSMAXVEL_INT 0 0 0 0 up" | gmt mapproject ${RJSTRING} | gmt psvelo -Se${m_gps_vertscale[$tt]}p/0/0 -A+e+n+p -W2p,red -Gred -R0/${projw}/0/${projh} -JX${projw}/${projh} -O -K -Xa${GPSoffset}p -Ya0.05i >> ${LEGFILE} 2>/dev/null
          echo "$CENTERLON $CENTERLAT $GPSMAXVEL_INT 0 0 0 0 down" | gmt mapproject ${RJSTRING} | gmt psvelo -Se${m_gps_vertscale[$tt]}p/0/0 -A+bc+et+n+p -W0.2p,blue -Gblue -R0/${projw}/0/${projh} -JX${projw}/${projh} -O -K ${VERBOSE} -Xa${GPSoffset}p -Ya-0.05i >> ${LEGFILE} 2>/dev/null
          echo "$CENTERLON $CENTERLAT $GPSMAXVEL_INT 0 0 0 0 down" | gmt mapproject ${RJSTRING} | gmt psvelo -Se${m_gps_vertscale[$tt]}p/0/0 -A+e+n+p -W2p,blue -Gblue -R0/${projw}/0/${projh} -JX${projw}/${projh} -O -K -Xa${GPSoffset}p -Ya-0.05i >> ${LEGFILE} 2>/dev/null
        gmt_remove_tmpdir
      fi
    fi

    close_legend_item "gps_${tt}"

    tectoplot_legend_caught=1
  ;;
  esac
}

# function tectoplot_post_gps() {
#   # Add the file to the profiles
# }

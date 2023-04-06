
TECTOPLOT_MODULES+=("geography")

# UPDATED
# NEW OPTS

# plot geographic elements like coastlines, country borders

function tectoplot_defaults_geography() {

################################################################################

################################################################################
##### Country borders and labels

COUNTRY_LABEL_FONTSIZE="8p"
COUNTRY_LABEL_FONT="Helvetica-bold"
COUNTRY_LABEL_FONTCOLOR="black"

BORDER_STATE_QUALITY="-Da"
BORDER_STATE_LINEWIDTH="0.3p"
BORDER_STATE_LINECOLOR="red"

################################################################################
##### OpenStreetMap coastline data

OSMCOASTDIR=${DATAROOT}"OSMCoasts/"
# These files exist in the original download and processing workflow but not
# in the data distributed with tectoplot
# OSMCOASTORIGFILE=${OSMCOASTDIR}"land_polygons.shp"
# OSMCOASTGMTFILE=${OSMCOASTDIR}"land_polygons_osm_planet.gmt"
OSMCOASTBF2FILE=${OSMCOASTDIR}"land_polygons_osm_planet.bf2"

OSMCOAST_SHORT_SOURCESTRING="OpenStreetMap"
OSMCOAST_SOURCESTRING="Coastlines are from OpenStreetMap (www.openstreetmap.org/copyright) via FOSSGIS (https://osmdata.openstreetmap.de/data/land-polygons.html)"


GLOBALROADSDIR=${DATAROOT}"GlobalRoads/"
GLOBALROADSFILE=${GLOBALROADSDIR}"ne_10m_roads.gmt"

ROADS_SHORT_SOURCESTRING="GlobalRoads"
ROADS_SOURCESTRING="Roads are from Patterson, Tom. Kelso, Nathaniel Vaughn. World Roads, 1:10 million (2012). [Shapefile]. North American Cartographic Information Society. Retrieved from https://maps.princeton.edu/catalog/stanford-vs175mk0273"
}

function tectoplot_args_geography()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -roads)
  tectoplot_get_opts_inline '
des -roads plot global road network
' "${@}" || return
  plots+=("m_geography_roads")
  ;;

  -lakes)
  tectoplot_get_opts_inline '
des -lakes plot lakes
opt fill m_geography_lakes_fill string "lightblue"
  fill color
opt stroke m_geography_lakes_line string ""
  line stroke definition (e.g. 1p,black)
opt res m_geography_lakes_res string "f"
  resolution: a=auto f=full h=high i=intermediate l=low c=crude
' "${@}" || return
  plots+=("m_geography_lakes")

  ;;


  -aosm)
  tectoplot_get_opts_inline '
des -aosm plot high quality coastlines from Open Street Map database
opn simplify m_geography_aosm_simplify string "none"
    simplify coastlines: 01 or 001
opn width m_geography_aosm_width string "0.2p"
    width of coastline lines
opn color m_geography_aosm_color string "black"
    color of coastline lines
opn fill m_geography_aosm_fill string "none"
    fill land areas with specified color
opn trans m_geography_aosm_trans float 0
    transparency of coastlines
opn fixdem m_geography_aosm_fixdem flag 0
    repair DEM so that land/sea areas match OSM coastlines
opn noplot m_geography_aosm_noplot flag 0
    do not plot coastlines
opn seg m_geography_aosm_seg flag 0
    plot line segments as great circles
mes -aosm should only be called once; subsequent calls will overwrite all options
exa tectoplot -aosm width 1p fill green
' "${@}" || return

  if [[ ${m_geography_aosm_noplot} -ne 1 ]]; then
    plots+=("m_geography_aosm")
  fi
  ;;

  -tissot)

  tectoplot_get_opts_inline '
des -tissot plot circles of specified radius at evenly spaced points given by -pf
opn width m_geography_tissot_width posfloat 100
    width of Tissot-type
opn line m_geography_tissot_line string "0.2p,black"
    line symbology; use none for no line
opn fill m_geography_tissot_fill string "none"
    fill color
mes Note that this is a false Tissot plot that is commonly used but is not
mes actually plotting Tissots indicatrices.
mes -tissot should only be called once.
exa tectoplot -r g -a -pf 1000 -tissot
' "${@}" || return

  plots+=("m_geography_tissot")

  if [[ $m_geography_tissot_fill == "none" ]]; then
    m_geography_tissot_fillcmd=""
  else
    m_geography_tissot_fillcmd="-G${m_geography_tissot_fill}"
  fi

  if [[ $m_geography_tissot_line == "none" ]]; then
    m_geography_tissot_linecmd=""
  else
    m_geography_tissot_linecmd="-W${m_geography_tissot_line}"
  fi
  ;;

  -a)
  tectoplot_get_opts_inline '
des -a plot ocean and land coastlines from GHSSG
opt res m_geography_a_res string "a"
    resolution: a=auto f=full h=high i=intermediate l=low c=crude
opt line m_geography_a_line string "0.2p,black"
    line symbology; use none for no line
opt fill m_geography_a_fill string "none"
    fill color for land areas; use none for no fill
opt seafill m_geography_a_seafill string "none"
    fill color for sea areas; use none for no fill
opt size m_geography_a_size string "none"
    minimum size of plotted object: number with k = size in km^2
opt trans m_geography_a_trans float 0
    transparency (percent)
opt raster m_geography_a_rasterize flag 0
    rasterize the plot and plot the raster
exa tectoplot -r g -a
' "${@}" || return

  plots+=("m_geography_a")
  ;;

  -ac) # args: landcolor seacolor

  tectoplot_get_opts_inline '
des -ac plot land/water areas with specified colors
opt res m_geography_ac_res string "a"
    resolution: a=auto f=full h=high i=intermediate l=low c=crude
opt line m_geography_ac_line string "0.2p,black"
    line symbology; use none for no line
opt fill m_geography_ac_fill string "none"
    fill color; use none for no fill
opt size m_geography_ac_size string "none"
    minimum size of plotted object: number with k = size in km^2
opt trans m_geography_ac_trans float 0
    transparency (percent)
exa tectoplot -r g -ac
' "${@}" || return

  plots+=("m_geography_ac")
  ;;

  -acb)
  tectoplot_get_opts_inline '
des -acb plot country border lines
opt res m_geography_acb_res string "a"
    resolution: a=auto f=full h=high i=intermediate l=low c=crude
opt line m_geography_acb_line string "0.2p,black"
    line symbology; use none for no line
opt fill m_geography_acb_fill string "none"
    fill color; use none for no fill
opt trans m_geography_acb_trans float 0
    transparency (percent)
exa tectoplot -r g -acb
' "${@}" || return

  plots+=("m_geography_acb")
  ;;

  -acs)
  tectoplot_get_opts_inline '
des -acs plot state border lines
opt res m_geography_acs_res string "a"
    resolution: a=auto f=full h=high i=intermediate l=low c=crude
opt line m_geography_acs_line string "0.2p,black"
    line symbology; use none for no line
opt fill m_geography_acs_fill string "none"
    fill color; use none for no fill
opt trans m_geography_acs_trans float 0
    transparency (percent)
exa tectoplot -r g -acs
' "${@}" || return

  plots+=("m_geography_acs")
  ;;

  -acl)
tectoplot_get_opts_inline '
des -acl label all or only selected countries
opt font m_geography_acl_font string "8p,Helvetica,black"
    font of country labels
opt list m_geography_acl_list list
    list of countries to label
exa tectoplot -r =AF -a l -acb red 0.2p a -acl
' "${@}" || return

  plots+=("m_geography_acl")
  ;;

  -countries)
tectoplot_get_opts_inline '
des -countries plot randomly colored country polygons
opt line m_geography_countries_line string "0.2p,black"
    line symbology; use none for no line
opt cpt m_geography_countries_cpt cpt "wysiwyg"
    fill color CPT
opt trans m_geography_countries_trans float 0
    transparency (percent)
opt res m_geography_countries_res string "d"
    resolution: a=auto f=full h=high i=intermediate l=low c=crude
exa tectoplot -r g -a l
' "${@}" || return

  plots+=("m_geography_countries")
  ;;

  -countryid)
tectoplot_get_opts_inline '
des -countryid print list of countries in map area
exa tectoplot -r g -countryid
' "${@}" || return

  plots+=("m_geography_countryid")
  ;;

  -rivers)

tectoplot_get_opts_inline '
des -rivers plot rivers from GHSSG
opt trans m_geography_rivers_trans integer 0
  transparency (not recommended due to overlapping segments)
opt line m_geography_rivers_line string "1p,blue"
  river line width and color definition
exa tectoplot -r FR -a -rivers
' "${@}" || return

  plots+=("m_geography_rivers")
  ;;

  esac
}

# tectoplot_cpts_geography() {
#
# }

function tectoplot_calculate_geography()  {

  # # Check for OSM high quality coast data
  # if [[ -d ${OSMCOASTDIR} ]]; then
  #   # If the directory exists and has the source data, but no transformed file,
  #   if [[ -s ${OSMCOASTORIGFILE} ]]; then
  #     if [[ ! -s ${OSMCOASTGMTFILE} ]]; then
  #       echo "[-aosm]: Converting OSM coast data to BF2 format"
  #       ogr2ogr -f OGR_GMT ${OSMCOASTGMTFILE} ${OSMCOASTORIGFILE}
  #       gmt convert ${OSMCOASTGMTFILE} -bo2f > ${OSMCOASTBF2FILE}
  #     fi
  #   fi
  # fi

  # Only do the calculations once for options using opn ren etc.
  if [[ $m_geography_calc_once -ne 1 ]]; then
    m_geography_calc_once=1
    if [[ ${m_geography_aosm_simplify} != "none" ]]; then
      OSMCOASTBF2FILE=${OSMCOASTDIR}"land_polygons_simplified_${m_geography_aosm_simplify}.bf2"
    fi

    if [[ ${m_geography_aosm_fill} != "none" ]]; then
      OSMCOAST_PLOTFILLCMD="-G${m_geography_aosm_fill}"
    fi

    # Extract the data for the current AOI
    if [[ -s ${OSMCOASTBF2FILE} ]]; then
      gmt spatial ${OSMCOASTBF2FILE} -bi2f -bo2f -R$MINLON/$MAXLON/$MINLAT/$MAXLAT -C > osmcoasts.bf2
      gmt spatial ${OSMCOASTBF2FILE} -bi2f -R$MINLON/$MAXLON/$MINLAT/$MAXLAT -C -F > osmcoasts.gmt
      # gmt select ${OSMCOASTBF2FILE} -bi2f -bo2f -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} > osmcoasts.bf2
    fi

    if [[ -s osmcoasts.gmt && ${m_geography_aosm_fixdem} -eq 1 && -s ${F_TOPO}dem.tif ]]; then
      info_msg "[-aosm]: Setting land polygons in DEM to positive"
      ogr2ogr -a_srs "EPSG:4326" -s_srs "EPSG:4326" -nlt POLYGON osmcoasts.shp osmcoasts.gmt
      rasterpixelsize=($(grid_pixelsize ${F_TOPO}dem.tif))
      # rasterinfo=($(gdalinfo ${F_TOPO}dem.tif | grep "Pixel Size" | gawk 'function abs(a) { return (a>$1)?a:-a } {str1=substr($4,2,length($4)-2); split(str1,a,","); if (substr(a[2],1,1)=="-") { a[2]=substr(a[2],2,length(a[2])); print a[1], a[2]} }'))
      # gdal_rasterize -a_srs "EPSG:4326" -at -te ${MINLON} ${MINLAT} ${MAXLON} ${MAXLAT} -burn 1 -tr ${rasterinfo[0]} ${rasterinfo[1]} osmcoasts.shp shapemask.tif
      rasterdomain=($(grid_xyrange ${F_TOPO}dem.tif))

      # echo ${MINLON} ${MAXLON} ${MINLAT} ${MAXLAT}
      # echo ${rasterdomain[@]}

      gdal_rasterize -q -a_srs "EPSG:4326" -at -te ${rasterdomain[0]} ${rasterdomain[2]} ${rasterdomain[1]} ${rasterdomain[3]} -burn 1 -ts ${rasterpixelsize[0]} ${rasterpixelsize[1]} osmcoasts.shp shapemask.tif

      # Set pixels below sea level but inside the land polygon to sea level
      # gdal_calc.py --quiet --format=GTiff -A shapemask.tif -B ${F_TOPO}dem.tif --calc="((A==1)*(B>=0)*B + (A==1)*(B<0)*1 + (A==0)*B)" --outfile=fixeddem.tif

      # Set pixels below sea level but inside the land polygon to above sea level, and pixels outside land polygon above sea level to below sea level
      # A==1 : land in OSM dataset
      # A==0 : sea in OSM dataset
      # B : elevation in DEM dataset
      #                                                                                OSM land/DEM land    OSM land/DEM Sea     OSM sea / DEM sea       OSM SEA / DEM land
      gdal_calc.py --quiet --format=GTiff -A shapemask.tif -B ${F_TOPO}dem.tif --calc="((A==1)*(B>=0)*B   + (A==1)*(B<=0)*1   +   (A==0)*(B<0)*B     +    (A==0)*(B>=0)*-0.3)" --outfile=fixeddem.tif

      # gdal_calc.py --overwrite --type=Float32 --format=GTiff --quiet -A ${BATHY} -B neg.tif --calc="((A>=${GMRT_MERGELEVEL})*A + (A<${GMRT_MERGELEVEL})*B)" --outfile=merged.tif
      [[ -s fixeddem.tif ]] && cp fixeddem.tif ${F_TOPO}dem.tif 2>/dev/null
    fi
  fi
}

# function tectoplot_cpt_geography() {
# }

function tectoplot_plot_geography() {

  case $1 in

  m_geography_lakes)

    if [[ ! -z ${m_geography_lakes_line[$tt]} ]]; then
      m_geography_lakes_linecmd="-W2/${m_geography_lakes_line[$tt]}"
    else
      m_geography_lakes_linecmd=""
    fi

    gmt pscoast ${m_geography_lakes_linecmd} -A0/2/2 -S${m_geography_lakes_fill[$tt]} -D${m_geography_lakes_res[$tt]} $RJOK $VERBOSE >> map.ps

    echo $COASTS_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $COASTS_SOURCESTRING >> ${LONGSOURCES}

  ;;


  m_geography_roads)
    echo $ROADS_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $ROADS_SOURCESTRING >> ${LONGSOURCES}

    ogr2ogr -f OGR_GMT -clipsrc ${MINLON} ${MINLAT} ${MAXLON} ${MAXLAT} cliproads.gmt ${GLOBALROADSFILE} >/dev/null 2>&1
    gmt psxy cliproads.gmt -W1p,black ${RJOK} >> map.ps

  ;;

  m_geography_rivers)
    gmt pscoast -Ia/${m_geography_rivers_line[$tt]} -t${m_geography_rivers_trans[$tt]} $RJOK $VERBOSE >> map.ps

    echo $COASTS_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $COASTS_SOURCESTRING >> ${LONGSOURCES}
  ;;

  m_geography_tissot)

    if [[ -s gridswap.txt ]]; then
      while read p; do
        p_parse=($p)
        polelat=${p_parse[0]}
        polelon=${p_parse[1]}

        TISSOT_STEP=$(echo "${m_geography_tissot_width} / 600" | bc -l)
        gmt project -C${polelon}/${polelat} -G${TISSOT_STEP}k+h -Z${m_geography_tissot_width}k -L-360/0 $VERBOSE | gawk '{print $1, $2}' >> ${F_MAPELEMENTS}tissot.txt
      done < gridswap.txt

      gmt psxy ${F_MAPELEMENTS}tissot.txt ${m_geography_tissot_fillcmd} ${m_geography_tissot_linecmd} ${RJOK} >> map.ps
    fi
    tectoplot_plot_caught=1
  ;;

  m_geography_a)

    if [[ ${m_geography_a_fill[$tt]} != "none" ]]; then
      m_geography_a_fillcmd="-G${m_geography_a_fill[$tt]}"
    else
      m_geography_a_fillcmd=""
    fi

    if [[ ${m_geography_a_seafill[$tt]} != "none" ]]; then
      m_geography_a_seafillcmd="-S${m_geography_a_seafill[$tt]}"
    else
      m_geography_a_seafillcmd=""
    fi

    if [[ ${m_geography_a_size[$tt]} != "none" ]]; then
      m_geography_a_sizecmd="-A${m_geography_a_size[$tt]}"
    else
      m_geography_a_sizecmd=""
    fi

    if [[ ${m_geography_a_rasterize[$tt]} -eq 1 ]]; then
      gmt_init_tmpdir

      M_GEOGRAPHY_A_PSSIZE_ALT=$(gawk -v size=${PSSIZE} -v minlon=${MINLON} -v maxlon=${MAXLON} -v minlat=${MINLAT} -v maxlat=${MAXLAT} '
        BEGIN {
          print size*(minlat-maxlat)/(minlon-maxlon)
        }')

      m_geography_a_rj+=("-R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}")
      m_geography_a_rj+=("-JX${PSSIZE}i/${M_GEOGRAPHY_A_PSSIZE_ALT}id")
      # Plot the map in Cartesian coordinates
      gmt pscoast -D${m_geography_a_res[$tt]} -W1/${m_geography_a_line[$tt]} ${m_geography_a_seafillcmd} ${m_geography_a_fillcmd} ${m_geography_a_sizecmd} -t${m_geography_a_trans[$tt]} ${m_geography_a_rj[@]} -Bxaf -Byaf -Btlrb -Xc -Yc --MAP_FRAME_PEN=0p,black --GMT_HISTORY=false > module_a_tmp.ps 2>/dev/null
      # Convert to a TIFF file at specified resolution
      gmt psconvert module_a_tmp.ps -A+m0i -Tt -W+g ${VERBOSE}
      rm -f module_a_tmp.tiff
      # Update the coordinates in basin.tif to be correct
      gdal_edit.py -a_ullr ${MINLON} ${MAXLAT} ${MAXLON} ${MINLAT} module_a_tmp.tif
      # rm -f module_a_tmp.ps
      gmt_remove_tmpdir

      gmt grdimage module_a_tmp.tif ${RJOK} ${VERBOSE} >> map.ps
    else
      gmt pscoast -D${m_geography_a_res[$tt]} -W1/${m_geography_a_line[$tt]} ${m_geography_a_seafillcmd} ${m_geography_a_fillcmd} ${m_geography_a_sizecmd} -t${m_geography_a_trans[$tt]} $RJOK $VERBOSE >> map.ps
    fi

    echo $COASTS_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $COASTS_SOURCESTRING >> ${LONGSOURCES}
    tectoplot_plot_caught=1
    ;;

  m_geography_aosm)

    if [[ -s osmcoasts.bf2 ]]; then

      if [[ ${m_geography_aosm_seg} -eq 0 ]]; then
        m_geography_aosm_segcmd=""
      else 
        m_geography_aosm_segcmd="-A"
      fi
      gmt psxy osmcoasts.bf2 ${m_geography_aosm_segcmd} -bi2f -t${m_geography_aosm_trans} ${OSMCOAST_PLOTFILLCMD} -W${m_geography_aosm_width},${m_geography_aosm_color}  ${RJOK} ${VERBOSE} >> map.ps
      echo $OSMCOAST_SHORT_SOURCESTRING >> ${SHORTSOURCES}
      echo >> ${SHORTSOURCES}
      echo $OSMCOAST_SOURCESTRING >> ${LONGSOURCES}
    fi
    tectoplot_plot_caught=1
    ;;

  m_geography_countries)

    m_geography_countriesres="-D${m_geography_countries_res[$tt]}"

    # Create a list of country names
    gmt pscoast ${m_geography_countriesres} -E+l -Vn 2>/dev/null | gawk -F'\t' '{print $1}' > ${F_MAPELEMENTS}countries.txt
    NUMCOUNTRIES=$(wc -l < ${F_MAPELEMENTS}countries.txt | gawk '{print $1+0}')
    gmt makecpt -N -T0/${NUMCOUNTRIES}/1 -C${m_geography_countries_cpt[$tt]} -Vn  | gawk '{print $2}' > ${F_MAPELEMENTS}country_colors.txt

    RANDOM=2  # Confirmed to produce unique numbers for at least 300 calls
    unset a
    while IFS= read -r line; do a+=("$line"); done < ${F_MAPELEMENTS}countries.txt
    for i in ${!a[@]}; do a[$((RANDOM+${#a[@]}))]="${a[$i]}"; unset a[$i]; done
    for i in ${!a[@]}; do
      echo ${a[${i}]} >> ${F_MAPELEMENTS}countries_shuffled.txt
    done

    paste ${F_MAPELEMENTS}countries_shuffled.txt ${F_MAPELEMENTS}country_colors.txt | gawk '{printf("-E%s+g%s+p'${m_geography_countries_line[$tt]}' ", $1, $2)}' > ${F_MAPELEMENTS}combined.txt
    m_geography_countries_string=($(cat ${F_MAPELEMENTS}combined.txt))
    gmt pscoast ${m_geography_countriesres} ${m_geography_countries_string[@]} ${RJOK} -t${m_geography_countries_trans[$tt]} -Vn 2>/dev/null  >> map.ps
    # -Slightblue
    tectoplot_plot_caught=1
    ;;

  m_geography_countryid) # report country ID codes
      gawk -F, < $COUNTRY_CODES '{ print $3, $2, $1, $4 }' | gmt select ${rj[0]} | grep -v "NaN"
    # else
    #   while ! arg_is_flag $2; do
    #     gawk -F, < $COUNTRY_CODES '{ print $1, $4 }' | grep "${2}"
    #     shift
    #   done
    # fi
    ;;

  m_geography_acb)

    m_geography_acb_rescmd="-D${m_geography_acb_res[$tt]}"

    gmt pscoast ${m_geography_acb_rescmd} -N1/${m_geography_acb_line[$tt]} -t${m_geography_acb_trans[$tt]} $RJOK $VERBOSE --PS_LINE_JOIN=round >> map.ps

    echo $COASTS_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $COASTS_SOURCESTRING >> ${LONGSOURCES}

    tectoplot_plot_caught=1
    ;;

  m_geography_acs)

    m_geography_acs_rescmd="-D${m_geography_acs_res[$tt]}"

    gmt pscoast ${m_geography_acs_rescmd} -N2/${m_geography_acs_line[$tt]} $RJOK $VERBOSE >> map.ps

    echo $COASTS_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $COASTS_SOURCESTRING >> ${LONGSOURCES}

    tectoplot_plot_caught=1
    ;;

  m_geography_acl)
    if [[ ${#m_geography_acl_list[@]} -gt 1 ]]; then
      echo list is here ${#m_geography_acl_list[@]}
      echo ${m_geography_acl_list[@]} | tr ' ' ',' > ${F_MAPELEMENTS}selected_country_ids.txt
      gawk -F, '
        BEGIN {
          ind=0
        }
        (NR==FNR) {
          # mark each input ID in the associative array
          for(i=1;i<=NF;i++) {
            inputs[$(i)]=1
          }
        }
        (NR!=FNR) {
          if (inputs[$1]==1) {
            print $3, $2, $4
          }
        }
      ' ${F_MAPELEMENTS}selected_country_ids.txt $COUNTRY_CODES | gmt pstext -F+f${m_geography_acl_font[$tt]}=~0.6p,white+jCM $RJOK ${VERBOSE} >> map.ps
    else
      gawk -F, < $COUNTRY_CODES '{ print $3, $2, $4}' | gmt pstext -F+f${m_geography_acl_font[$tt]}=~0.6p,white+jCM $RJOK ${VERBOSE} >> map.ps
    fi
    tectoplot_plot_caught=1
    ;;

  esac
}

# function tectoplot_legend_geography() {
#   echo "none"
# }

# function tectoplot_legendbar_geography() {
#   echo "none"
# }

# function tectoplot_post_geography() {
#   echo "none"
# }

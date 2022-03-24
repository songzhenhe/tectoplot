
TECTOPLOT_MODULES+=("geography")

# plot geographic elements like coastlines, country borders

function tectoplot_defaults_geography() {

################################################################################
##### Coastlines and land/sea colors
COAST_QUALITY="-Da"          # pscoast quality
COAST_SIZELIMIT=0
FILLCOASTS=""                # pscoast option for filling land areas
COAST_LINEWIDTH="0.5p"       # pscoast line width
COAST_LINECOLOR="black"      # pscoast line color

LAKE_LINEWIDTH="0.2p"
LAKE_LINECOLOR="black"

RIVER_LINEWIDTH=0.4p
RIVER_LINECOLOR="blue"
RIVER_COMMAND=""

COAST_KM2="100"              # minimum size (im km^2) of feature
LANDCOLOR="gray"             # color of land areas
SEACOLOR="lightblue"         # color of sea areas
FILLCOASTS=""                # empty by default = don't fill anything

################################################################################
##### Country borders and labels
BORDER_LINEWIDTH="1.3p"      # National border linewidth
BORDER_LINECOLOR="red"       # National border linecolor

BORDER_QUALITY="-Da"
BORDER_LINEWIDTH="0.5p"
BORDER_LINECOLOR="red"

COUNTRY_LABEL_FONTSIZE="8p"
COUNTRY_LABEL_FONT="Helvetica"
COUNTRY_LABEL_FONTCOLOR="red"

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

OSMCOAST_LINEWIDTH="0.1p"       # pscoast line width
OSMCOAST_LINECOLOR="black"      # pscoast line color
OSMCOAST_POLYFILL="lightbrown"
OSMCOAST_TRANS=0

osmcoast_extract=0

OSMCOAST_SHORT_SOURCESTRING="OpenStreetMap"
OSMCOAST_SOURCESTRING="Coastlines are from OpenStreetMap (www.openstreetmap.org/copyright) via FOSSGIS (https://osmdata.openstreetmap.de/data/land-polygons.html)"

}

function tectoplot_args_geography()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -aosm)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-aosm:  plot high quality coastlines from OSM database
Usage: -aosm [[options]]

Options:
width [width=${OSMCOAST_LINEWIDTH}]              Width of coastline (e.g. 0.5p)
color [color=${OSMCOAST_LINECOLOR}]             Color of coastline
fill [[color=${OSMCOAST_POLYFILL}]]          Fill color of land polygons
trans [transparency]                              Percent transparency
fixdem                             Ensure ${F_TOPO}dem.tif is positive on land
noplot                             Do not plot the coastlines/polygons

Example:
tectoplot -aosm
ExampleEnd
--------------------------------------------------------------------------------
EOF
fi

  shift
  OSMCOAST_PLOTFILLCMD=""

  while ! arg_is_flag $1; do
    case $1 in
      width)
        shift
        ((tectoplot_module_shift++))
        if ! arg_is_flag $1; then
          OSMCOAST_LINEWIDTH="${1}"
          shift
          ((tectoplot_module_shift++))
        else
          echo "[-aosm]: width option requires argument"
          exit 1
        fi
      ;;
      color)
        shift
        ((tectoplot_module_shift++))
        if ! arg_is_flag $1; then
          OSMCOAST_LINECOLOR="${1}"
          shift
          ((tectoplot_module_shift++))
        else
          echo "[-aosm]: color option requires argument"
          exit 1
        fi
      ;;
      fixdem)
        shift
        ((tectoplot_module_shift++))
        OSM_FIXDEMFLAG=1
      ;;
      trans)
        shift
        ((tectoplot_module_shift++))
        if arg_is_positive_float $1; then
          OSMCOAST_TRANS="${1}"
          shift
          ((tectoplot_module_shift++))
        else
          echo "[-aosm]: trans option requires argument"
          exit 1
        fi
      ;;
      fill)
        shift
        ((tectoplot_module_shift++))
        if ! arg_is_flag $1; then
          OSMCOAST_POLYFILL="${1}"
          shift
          ((tectoplot_module_shift++))
        else
          echo "[-aosm]: fill option requires argument"
          exit 1
        fi
        OSMCOAST_PLOTFILLCMD="-G${OSMCOAST_POLYFILL}"
      ;;
      noplot)
        shift
        ((tectoplot_module_shift++))
        OSM_NOPLOTFLAG=1
      ;;
      *)
        echo "[-aosm]: option $2 not recognized"
        exit 1
      ;;
    esac
  done


  [[ $OSM_NOPLOTFLAG -ne 1 ]] && plots+=("osmcoasts")
  osmcoast_extract=1

  echo $OSMCOAST_SHORT_SOURCESTRING >> ${SHORTSOURCES}
  echo $OSMCOAST_SOURCESTRING >> ${LONGSOURCES}

  tectoplot_module_caught=1
  ;;

  -a) # args: none || string
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-a:   plot ocean and land coastlines
Usage: -a [[quality=${COAST_QUALITY}]] [[sizelimit=${COAST_SIZELIMIT}]]
  Plot ocean coastlines with a given quality (option descriptions from GMT:)
  a - auto: select best resolution given map scale.
  f - full resolution (may be very slow for large regions).
  h - high resolution (may be slow for large regions).
  i - intermediate resolution.
  l - low resolution [Default].
  c - crude resolution, for busy plots that need crude continent outlines only.

Example:
  tectoplot -r g -a l -o example_a
ExampleEnd
--------------------------------------------------------------------------------
EOF
fi

    shift

    if arg_is_flag $1; then
			info_msg "[-a]: No quality specified. Using GMT flag ${COAST_QUALITY}"
		else
			COAST_QUALITY="-D${1}"
			shift
      ((tectoplot_module_shift++))
		fi
    if arg_is_flag $1; then
      info_msg "[-a]: No coast element size limit specified. Using ${COAST_KM2} km*km"
    else
      COAST_KM2="${1}"
      shift
      ((tectoplot_module_shift++))
    fi
    plots+=("coasts")

    echo $COASTS_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $COASTS_SOURCESTRING >> ${LONGSOURCES}

    tectoplot_module_caught=1
    ;;

  -ac) # args: landcolor seacolor
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ac:           plot land/water color
Usage: -ac [[land color]] [[sea color]]
  Set options to fill land and water areas with a solid color when using -a

Example: Plot global land/sea areas
  tectoplot -r g -a l -ac lightbrown lightblue
ExampleEnd
--------------------------------------------------------------------------------
EOF
fi
    shift
    filledcoastlinesflag=1
    if arg_is_flag $1; then
      info_msg "[-ac]: No land/sea color specified. Using defaults"
      FILLCOASTS="-G${LANDCOLOR} -S${SEACOLOR}"
    else
      LANDCOLOR="${1}"
      shift
      ((tectoplot_module_shift++))
    fi
    if arg_is_flag $1; then
      info_msg "[-ac]: No sea color specified. Not filling sea areas"
      FILLCOASTS="-G${LANDCOLOR}"
    else
      SEACOLOR="${1}"
      shift
      ((tectoplot_module_shift++))
      FILLCOASTS="-G$LANDCOLOR -S$SEACOLOR"
    fi

    echo $COASTS_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $COASTS_SOURCESTRING >> ${LONGSOURCES}

    tectoplot_module_caught=1
    ;;

  -acb)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-acb:          plot country borders
Usage: -acb [[line color=${BORDER_LINECOLOR}]] [[line width${BORDER_LINEWIDTH}]] [[border quality=${BORDER_QUALITY}]]
  a - auto: select best resolution given map scale.
  f - full resolution (may be very slow for large regions).
  h - high resolution (may be slow for large regions).
  i - intermediate resolution.
  l - low resolution [Default].
  c - crude resolution, for busy plots that need crude continent outlines only.

Example: Plot global country borders and coastline
tectoplot -r g -a l -acb red 0.2p a
ExampleEnd
--------------------------------------------------------------------------------
EOF
fi

    shift
    if arg_is_flag $1; then
      info_msg "[-acb]: No border line color specified. Using $BORDER_LINECOLOR"
    else
      BORDER_LINECOLOR="${1}"
      shift
      ((tectoplot_module_shift++))
    fi
    if arg_is_flag $1; then
      info_msg "[-acb]: No border line width specified. Using $BORDER_LINEWIDTH"
    else
      BORDER_LINEWIDTH="${1}"
      shift
      ((tectoplot_module_shift++))
    fi
    if arg_is_flag $1; then
      info_msg "[-acb]: No border quality specified [a,l,f]. Using $BORDER_QUALITY"
    else
      BORDER_QUALITY="-D${1}"
      shift
      ((tectoplot_module_shift++))
    fi

    echo $COASTS_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $COASTS_SOURCESTRING >> ${LONGSOURCES}

    plots+=("countryborders")
    tectoplot_module_caught=1
    ;;

    -acl)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-acl:          label countries
-acl [labelcolor]
Example: Outline and label the countries of Africa
  tectoplot -r =AF -a l -acb red 0.2p a -acl
--------------------------------------------------------------------------------
EOF
  fi

    shift
    if arg_is_flag $1; then
      info_msg "[-acl]: No font color specified. Using $COUNTRY_LABEL_FONTCOLOR"
    else
      COUNTRY_LABEL_FONTCOLOR="${1}"
      shift
    fi

    echo $COASTS_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $COASTS_SOURCESTRING >> ${LONGSOURCES}

    plots+=("countrylabels")
    tectoplot_module_caught=1

    ;;

    -acs)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-acs:          plot state borders
Usage: -acs [[line color=${BORDER_STATE_LINECOLOR}]] [[line width${BORDER_STATE_LINEWIDTH}]] [[border quality=${BORDER_STATE_QUALITY}]]

  a - auto: select best resolution given map scale.
  f - full resolution (may be very slow for large regions).
  h - high resolution (may be slow for large regions).
  i - intermediate resolution.
  l - low resolution [Default].
  c - crude resolution, for busy plots that need crude continent outlines only.

Example: Plot state borders and coastline
tectoplot -r g -a l -acs red 0.2p a
ExampleEnd
--------------------------------------------------------------------------------
EOF
  fi
    shift

    if arg_is_flag $1; then
      info_msg "[-acs]: No border line color specified. Using $BORDER_STATE_LINECOLOR"
    else
      BORDER_STATE_LINECOLOR="${1}"
      shift
      ((tectoplot_module_shift++))
    fi
    if arg_is_flag $1; then
      info_msg "[-acs]: No border line width specified. Using $BORDER_STATE_LINEWIDTH"
    else
      BORDER_STATE_LINEWIDTH="${1}"
      shift
      ((tectoplot_module_shift++))

    fi
    if arg_is_flag $1; then
      info_msg "[-acs]: No border quality specified [a,l,f]. Using $BORDER_STATE_QUALITY"
    else
      BORDER_STATE_QUALITY="-D${1}"
      shift
      ((tectoplot_module_shift++))
    fi

    echo $COASTS_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $COASTS_SOURCESTRING >> ${LONGSOURCES}

    plots+=("stateborders")
    tectoplot_module_caught=1

    ;;

    -countries)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-countries:    print randomly colored country polygons
-countries [trans] [[cpt]]
  trans is percent in 0-100
  cpt is any GMT recognized CPT file

  Currently, the colors change each time the plot is produced!

Example:
   tectoplot -r =AF -countries 0 wysiwyg -a
--------------------------------------------------------------------------------
EOF
  fi

    shift
    if arg_is_positive_float $1; then
      COUNTRIES_TRANS="${1}"
      shift
      ((tectoplot_module_shift++))
    fi
    if ! arg_is_flag $1; then
      COUNTRIESCPT="${1}"
      shift
      ((tectoplot_module_shift++))
    fi

    echo $COASTS_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $COASTS_SOURCESTRING >> ${LONGSOURCES}

    plots+=("countries")
    tectoplot_module_caught=1
  ;;

  -rivers)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-rivers:       plot rivers if -a command is called
-rivers

Example:
   tectoplot -r BR -a -rivers
--------------------------------------------------------------------------------
EOF
fi

    shift
    RIVER_COMMAND="-I1/${RIVER_LINEWIDTH},${RIVER_LINECOLOR} -I2/${RIVER_LINEWIDTH},${RIVER_LINECOLOR}"

    echo $COASTS_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $COASTS_SOURCESTRING >> ${LONGSOURCES}

    tectoplot_module_caught=1
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

  # Extract the data for the current AOI
  if [[ -s ${OSMCOASTBF2FILE} && $osmcoast_extract -eq 1 ]]; then
    gmt spatial ${OSMCOASTBF2FILE} -bi2f -bo2f -R$MINLON/$MAXLON/$MINLAT/$MAXLAT -C > osmcoasts.bf2
    gmt spatial ${OSMCOASTBF2FILE} -bi2f -R$MINLON/$MAXLON/$MINLAT/$MAXLAT -C -F > osmcoasts.gmt
    # gmt select ${OSMCOASTBF2FILE} -bi2f -bo2f -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} > osmcoasts.bf2
  fi

  if [[ -s osmcoasts.gmt && ${OSM_FIXDEMFLAG} -eq 1 ]]; then
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
    gdal_calc.py --quiet --format=GTiff -A shapemask.tif -B ${F_TOPO}dem.tif --calc="((A==1)*(B>=0)*B + (A==1)*(B<0)*1 + (A==0)*(B<0)*B + (A==0)*(B>=0)*-0.1)" --outfile=fixeddem.tif


    # gdal_calc.py --overwrite --type=Float32 --format=GTiff --quiet -A ${BATHY} -B neg.tif --calc="((A>=${GMRT_MERGELEVEL})*A + (A<${GMRT_MERGELEVEL})*B)" --outfile=merged.tif
    [[ -s fixeddem.tif ]] && cp fixeddem.tif ${F_TOPO}dem.tif 2>/dev/null
  fi



}

# function tectoplot_cpt_geography() {
# }

function tectoplot_plot_geography() {
  case $1 in

  coasts)
    gmt pscoast $COAST_QUALITY ${RIVER_COMMAND} -W1/$COAST_LINEWIDTH,$COAST_LINECOLOR -W2/$LAKE_LINEWIDTH,$LAKE_LINECOLOR $FILLCOASTS -A$COAST_KM2 $RJOK $VERBOSE >> map.ps
    tectoplot_plot_caught=1
    ;;

  osmcoasts)
    [[ -s osmcoasts.bf2 ]] && gmt psxy osmcoasts.bf2 -bi2f -t${OSMCOAST_TRANS} ${OSMCOAST_PLOTFILLCMD} -W${OSMCOAST_LINEWIDTH},${OSMCOAST_LINECOLOR}  ${RJOK} ${VERBOSE} >> map.ps
    tectoplot_plot_caught=1
    ;;

  countries)
    gmt pscoast -Df -E+l -Vn | gawk -F'\t' '{print $1}' > ${F_MAPELEMENTS}countries.txt
    NUMCOUNTRIES=$(wc -l < ${F_MAPELEMENTS}countries.txt | gawk '{print $1+0}')
    gmt makecpt -N -T0/${NUMCOUNTRIES}/1 -C${COUNTRIESCPT} -Vn  | gawk '{print $2}' | sort -R > ${F_MAPELEMENTS}country_colors.txt
    paste ${F_MAPELEMENTS}countries.txt ${F_MAPELEMENTS}country_colors.txt | gawk '{printf("-E%s+g%s ", $1, $2)}' > ${F_MAPELEMENTS}combined.txt
    string=($(cat ${F_MAPELEMENTS}combined.txt))
    gmt pscoast -Df ${string[@]} ${RJOK} ${VERBOSE} -t${COUNTRIES_TRANS} -Slightblue >> map.ps
    tectoplot_plot_caught=1
    ;;

  countryborders)
    gmt pscoast ${BORDER_QUALITY} -N1/${BORDER_LINEWIDTH},${BORDER_LINECOLOR} $RJOK $VERBOSE >> map.ps
    tectoplot_plot_caught=1
    ;;

  stateborders)
    gmt pscoast ${BORDER_STATE_QUALITY} -N2/${BORDER_STATE_LINEWIDTH},${BORDER_STATE_LINECOLOR} $RJOK $VERBOSE >> map.ps
    tectoplot_plot_caught=1
    ;;

  countrylabels)
    gawk -F, < $COUNTRY_CODES '{ print $3, $2, $4}' | gmt pstext -F+f${COUNTRY_LABEL_FONTSIZE},${COUNTRY_LABEL_FONT},${COUNTRY_LABEL_FONTCOLOR}+jLM $RJOK ${VERBOSE} >> map.ps
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

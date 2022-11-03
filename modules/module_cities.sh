
TECTOPLOT_MODULES+=("cities")

# UPDATED

function tectoplot_defaults_cities() {

  m_cities_sourcestring="City data from geonames (CC-BY)"
  m_cities_short_sourcestring="geonames"

  m_cities_dir=$DATAROOT"WorldCities/"
  m_cities_500=$m_cities_dir"cities500.txt"
  CITIES=$m_cities_dir"geonames_cities_500.txt"
  m_cities_sourceurl="http://download.geonames.org/export/dump/cities500.zip"
  m_cities_zip_bytes="10353983"
  m_cities_bytes="31818630"

  m_cities_default_minpop=500000
}

function tectoplot_args_cities()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -pp)
  cat <<-EOF > pp
des -pp plot locations of populated places (cities)
opt min m_cities_minpop float ${m_cities_default_minpop}
    minimum population of plotted cities
opt max m_cities_maxpop float 0
    maximum population of plotted cities
opt cpt m_cities_cpt cpt gray
    CPT for coloring city shapes
opt label m_cities_labelmin float 10000000000
    label cities larger than specified population
opt font m_cities_font string "8p,Helvetica,black"
    font for city labels
opt symbol m_cities_symbol string "c"
    symbol code for city points
opt size m_cities_size string "0.1i"
    size of city points
opt fill m_cities_fill string "none"
    color for symbol fill if CPT not used
opt string m_cities_stroke string "0.25p,black"
    stroke definition for city symbols
mes Populated places data
mes URL: ${m_cities_sourceurl}
exa tectoplot -r =EU -a -pp min 500000
EOF

  if [[ $USAGEFLAG -eq 1 ]]; then
    tectoplot_usage_opts pp
  else
    tectoplot_get_opts pp "${@}"

    plots+=("m_cities_pp")
    cpts+=("m_cities_pp")

    tectoplot_module_caught=1
  fi

  ;;

  esac
}

# We download the relevant data in the _calculate_ function as this is the first time we should
# be accessing the data itself.

function tectoplot_calculate_cities()  {

  if [[ ! -s $CITIES ]]; then

    read -r -p "Geonames city data not downloaded: download now? (enter for y) [y|n] " response

    case $response in
      Y|y|yes|"")
        if check_and_download_dataset "Geonames-Cities" $m_cities_sourceurl "yes" $m_cities_dir $m_cities_500 $m_cities_dir"data.zip" "none" "none"; then
          info_msg "Processing cities data to correct format"
          gawk  < $m_cities_dir"cities500.txt" -F'\t' '{print $6 "," $5 "," $2 "," $15}' > $CITIES
        else
          info_msg "Cities data could not be downloaded"
          return 0
        fi
      ;;
      N|n|*)
        return 0
      ;;
    esac

  fi

}

function tectoplot_cpt_cities() {
  case $1 in
  m_cities_pp)

    m_cities_maxcpt=${m_cities_maxpop[$tt]}
    if [[ $(echo "(${m_cities_minpop[$tt]} == ${m_cities_default_minpop}) && (${m_cities_maxpop[$tt]} != 0)" | bc -l) -eq 1 ]]; then
      m_cities_minpop[$tt]=0
    elif [[ $(echo "(${m_cities_minpop[$tt]} > ${m_cities_maxpop[$tt]})" | bc -l) -eq 1 ]]; then
      m_cities_maxpop[$tt]=100000000
      m_cities_maxcpt=1000000
    elif [[ $(echo "(${m_cities_minpop[$tt]} == 0) && (${m_cities_maxpop[$tt]} == 0)" | bc -l) -eq 1 ]]; then
      m_cities_maxpop[$tt]=100000000
      m_cities_maxcpt=1000000
    fi

    gmt makecpt -C${m_cities_cpt[$tt]} -I -Do -T${m_cities_minpop[$tt]}/${m_cities_maxcpt} -Z -N $VERBOSE > ${F_CPTS}population_${tt}.cpt
    m_cities_cpt_used[$tt]=${F_CPTS}population_${tt}.cpt

    if [[ ${m_cities_fill[$tt]} != "none" ]]; then
       m_cities_fillcmd[$tt]="-G${m_cities_fill[$tt]}"
       m_cities_cpt[$tt]="none"
    else
      m_cities_fillcmd[$tt]="-C${m_cities_cpt_used[$tt]}"
    fi

    tectoplot_cpt_caught=1
    ;;
  esac
}

function tectoplot_plot_cities() {
  case $1 in
    m_cities_pp)

    info_msg "[-pp]: Plotting cities with minimum population ${m_cities_minpop[$tt]} and maximum population ${m_cities_maxpop[$tt]}"

    gawk < $CITIES -F, -v minpop=${m_cities_minpop[$tt]} -v maxpop=${m_cities_maxpop[$tt]} -v minlat="$MINLAT" -v maxlat="$MAXLAT" -v minlon="$MINLON" -v maxlon="$MAXLON"  '
      BEGIN {
        OFS=","
        maxpop=(maxpop==0)?100000000:maxpop
      }
      ((($1 <= maxlon && $1 >= minlon) || ($1+360 <= maxlon && $1+360 >= minlon)) && $2 >= minlat && $2 <= maxlat && $4>=minpop && $4<=maxpop) {
          print $1 "\t" $2 "\t" $3 "\t" $4
      }' > cities_${tt}.dat

    # Select cities within actual map region

    # tab delimited with spaces in city names
    tr ' ' '_' < cities_${tt}.dat > cities_${tt}_pre.dat
    # tab delimited with _ in names
    select_in_gmt_map cities_${tt}_pre.dat ${RJSTRING[@]}
    # space delimited with _ in names
    tr ' ' '\t' < cities_${tt}_pre.dat > cities_${tt}_post.dat
    # tab delimited with _ in names

    tr '_' ' ' < cities_${tt}_post.dat > cities_${tt}.dat
    # tab delimited with space in names

    # Sort the cities so that dense areas plot on top of less dense areas
    # Could also do some kind of symbol scaling
    # gmt set PS_CHAR_ENCODING Standard1+

    gawk < cities_${tt}.dat -F'\t' '{print $1 "\t" $2 "\t" $4}' | sort -n -k 3 | gmt psxy -S${m_cities_symbol[$tt]}${m_cities_size[$tt]} -W${m_cities_stroke[$tt]} ${m_cities_fillcmd[$tt]} $RJOK $VERBOSE >> map.ps
    gawk < cities_${tt}.dat -F'\t' -v minpop=${m_cities_labelmin[$tt]} '($4>=minpop){print $1 "\t" $2 "\t" $3}' \
       | sort -n -k 3  \
       | gmt pstext -DJ${m_cities_size[$tt]}/${m_cities_size[$tt]} -F+f${m_cities_font[$tt]}+jLM  $RJOK $VERBOSE >> map.ps

    echo $m_cities_short_sourcestring >> ${SHORTSOURCES}
    echo $m_cities_sourcestring >> ${LONGSOURCES}

    tectoplot_plot_caught=1
    ;;
  esac
}

function tectoplot_legendbar_cities() {
  case $1 in
    m_cities_pp)
      if [[ ${m_cities_cpt[$tt]} != "none" ]]; then

        echo "G 0.2i" >> ${LEGENDDIR}legendbars.txt
        echo "B ${m_cities_cpt_used[$tt]} 0.2i 0.1i+malu -W0.00001 ${LEGENDBAR_OPTS} -Bxaf+l\"City population (100k)\"" >> ${LEGENDDIR}legendbars.txt
        barplotcount=$barplotcount+1
      fi
      tectoplot_legendbar_caught=1
      ;;
  esac
}

function tectoplot_legend_cities() {
  case $1 in
  m_cities_pp)

    init_legend_item "cities_${tt}"

    if [[ ${m_cities_minpop[$tt]} -eq 0 ]]; then
      m_cities_legendstring="City with population <= ${m_cities_maxpop[$tt]}"
    elif [[ ${m_cities_maxpop[$tt]} -eq 0 ]]; then
      m_cities_legendstring="City with population >= ${m_cities_minpop[$tt]}"
    else
      m_cities_legendstring="City with population ${m_cities_minpop[$tt]}-${m_cities_maxpop[$tt]}"
    fi

    echo "${CENTERLON} ${CENTERLAT} 10000" | gmt psxy -S${m_cities_symbol[$tt]}${m_cities_size[$tt]} -W${m_cities_stroke[$tt]} ${m_cities_fillcmd[$tt]} $RJOK $VERBOSE -X.175i >> ${LEGFILE}
    echo "${CENTERLON} ${CENTERLAT} ${m_cities_legendstring}" | gmt pstext -F+f6p,Helvetica,black+jLM -X0.15i ${RJOK} $VERBOSE >> ${LEGFILE}

    # Plot the symbol and accompanying text at the CENTERLON/CENTERLAT point (known to be on the map)
    close_legend_item "cities_${tt}"
    tectoplot_legend_caught=1
  ;;
  esac
}

# function tectoplot_post_cities() {
#   echo "none"
# }

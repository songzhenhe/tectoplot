
TECTOPLOT_MODULES+=("cities")

# Calculate residual grid by removing along-line average, using da-dt formulation
# Builtin support for gravity grids

# Variables needed:


function tectoplot_defaults_cities() {

  CITIES_SOURCESTRING="City data from geonames (CC-BY)"
  CITIES_SHORT_SOURCESTRING="geonames"

  CITIESDIR=$DATAROOT"WorldCities/"
  CITIES500=$CITIESDIR"cities500.txt"
  CITIES=$CITIESDIR"geonames_cities_500.txt"
  CITIES_SOURCEURL="http://download.geonames.org/export/dump/cities500.zip"
  CITIES_ZIP_BYTES="10353983"
  CITIES500_BYTES="31818630"

  CITIES_SYMBOL="c"
  CITIES_SYMBOL_SIZE="0.1i"
  CITIES_SYMBOL_LINEWIDTH="0.25p"
  CITIES_SYMBOL_LINECOLOR="black"
  CITIES_SYMBOL_FILLCOLOR="white"
  CITIES_MINPOP=5000
  CITIES_CPT="gray"
  CITIES_LABEL_MINPOP=100000
  CITIES_LABEL_FONTSIZE="8p"
  CITIES_LABEL_FONT="Helvetica"
  CITIES_LABEL_FONTCOLOR="black"

  POPULATION_CPT=${F_CPTS}"population.cpt"

}

function tectoplot_args_cities()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

    -pp|--cities)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
modules/module_cities.sh
-pp:           plot populated places above a specified population
-pp [[population=${CITIES_MINPOP}]]

  Source data is from Geonames.
  Label populated places using -ppl

Example:
  tectoplot -r =EU -a -pp 500000
--------------------------------------------------------------------------------
EOF
  fi

      shift
      if arg_is_flag $1; then
        info_msg "[-pp]: No minimum population specified. Using ${CITIES_MINPOP}"
      else
        CITIES_MINPOP="${1}"
        shift
        ((tectoplot_module_shift++))
      fi
      if ! arg_is_flag $1; then
        CITIES_CPT="${1}"
        shift
        ((tectoplot_module_shift++))
      fi

      plots+=("cities")
      cpts+=("cities")

      echo $CITIES_SHORT_SOURCESTRING >> ${SHORTSOURCES}
      echo $CITIES_SOURCESTRING >> ${LONGSOURCES}

      tectoplot_module_caught=1

      ;;

    -ppl)

    tectoplot_module_shift=0
    tectoplot_module_caught=0

  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ppl:          label populated places above a specified population
-ppl [[population=${CITIES_LABEL_MINPOP}]]

  Use -pp to plot cities.
  Source data is from Geonames

Example:
  tectoplot -r =EU -pp 500000 -ppl 500000
--------------------------------------------------------------------------------
EOF
  fi
      shift
      if arg_is_flag $1; then
        info_msg "[-pp]: No minimum population for labeling specified. Using ${CITIES_LABEL_MINPOP}"
      else
        CITIES_LABEL_MINPOP="${1}"
        shift
        ((tectoplot_module_shift++))
      fi
      citieslabelflag=1

      tectoplot_module_caught=1
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
        if check_and_download_dataset "Geonames-Cities" $CITIES_SOURCEURL "yes" $CITIESDIR $CITIES500 $CITIESDIR"data.zip" "none" "none"; then
          info_msg "Processing cities data to correct format"
          gawk  < $CITIESDIR"cities500.txt" -F'\t' '{print $6 "," $5 "," $2 "," $15}' > $CITIES
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

  gawk < $CITIES -F, -v minpop=${CITIES_MINPOP} -v minlat="$MINLAT" -v maxlat="$MAXLAT" -v minlon="$MINLON" -v maxlon="$MAXLON"  '
    BEGIN{OFS=","}
    # LON EDIT TEST
    ((($1 <= maxlon && $1 >= minlon) || ($1+360 <= maxlon && $1+360 >= minlon)) && $2 >= minlat && $2 <= maxlat && $4>=minpop) {
        print $1, $2, $3, $4
    }' > cities.dat

  if [[ $polygonselectflag -eq 1 ]]; then
    # GMT accepts comma delimited but only splits first few fields...
    gmt select cities.dat -F${POLYGONAOI} ${VERBOSE} | tr '\t' ',' > selected_cities.dat
    [[ -s selected_cities.dat ]] && cp selected_cities.dat cities.dat
  fi

}

function tectoplot_cpt_cities() {
  case $1 in
  cities)
    touch $POPULATION_CPT
    POPULATION_CPT=$(abs_path $POPULATION_CPT)
    gmt makecpt -C${CITIES_CPT} -I -Do -T0/1000000/100000 -N $VERBOSE > $POPULATION_CPT
    tectoplot_cpt_caught=1
    ;;
  esac
}

function tectoplot_plot_cities() {
  case $1 in
    cities)
      info_msg "Plotting cities with minimum population ${CITIES_MINPOP}"

      # We curate the cities plot by choosing the largest city within a given
      # map distance to avoid overlaying many cities.

      # Sort the cities so that dense areas plot on top of less dense areas
      # Could also do some kind of symbol scaling
      gawk < cities.dat -F, '{print $1, $2, $4}' | sort -n -k 3 | gmt psxy -S${CITIES_SYMBOL}${CITIES_SYMBOL_SIZE} -W${CITIES_SYMBOL_LINEWIDTH},${CITIES_SYMBOL_LINECOLOR} -C$POPULATION_CPT $RJOK $VERBOSE >> map.ps
      if [[ $citieslabelflag -eq 1 ]]; then
        gawk < cities.dat -F, -v minpop=${CITIES_LABEL_MINPOP} '($4>=minpop){print $1, $2, $3}' | sort -n -k 3 | gmt pstext -F+f${CITIES_LABEL_FONTSIZE},${CITIES_LABEL_FONT},${CITIES_LABEL_FONTCOLOR}+jLM $RJOK $VERBOSE >> map.ps
      fi
      tectoplot_plot_caught=1
    ;;
  esac
}

function tectoplot_legendbar_cities() {
  case $1 in
    cities)
      echo "G 0.2i" >> legendbars.txt
      echo "B $POPULATION_CPT 0.2i 0.1i+malu -W0.00001 -Bxa10f1+l\"City population (100k)\"" >> legendbars.txt
      barplotcount=$barplotcount+1
      tectoplot_legendbar_caught=1
      ;;
  esac
}

function tectoplot_legend_cities() {
  case $1 in
  cities)
    # Create a new blank map with the same -R -J as our main map
    gmt psxy -T -X0i -Yc $OVERLAY $VERBOSE -K ${RJSTRING[@]} > cities.ps

    echo "${CENTERLON} ${CENTERLAT} 10000" | gmt psxy -Xa0.35i -S${CITIES_SYMBOL}${CITIES_SYMBOL_SIZE} -W${CITIES_SYMBOL_LINEWIDTH},${CITIES_SYMBOL_LINECOLOR} -C$POPULATION_CPT $RJOK $VERBOSE >> cities.ps
    echo "${CENTERLON} ${CENTERLAT} City > ${CITIES_MINPOP}" | gmt pstext -Y0.15i -F+f${CITIES_LABEL_FONTSIZE},${CITIES_LABEL_FONT},${CITIES_LABEL_FONTCOLOR}+jLM -R -J -O $VERBOSE >> cities.ps

    # Plot the symbol and accompanying text at the CENTERLON/CENTERLAT point (known to be on the map)

    # Calculate the width and height of the graphic with a margin of 0.05i
    PS_DIM=$(gmt psconvert cities.ps -Te -A+m0.05i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
    PS_WIDTH_IN=$(echo $PS_DIM | gawk  '{print $1/2.54}')
    PS_HEIGHT_IN=$(echo $PS_DIM | gawk  '{print $2/2.54}')

    # Place the graphic onto the legend PS file, appropriately shifted. Then shift up.
    # If we run past the width of the map, then we shift all the way left; otherwise we shift right.
    # (The typewriter approach)

    gmt psimage -Dx"${LEG2_X}i/${LEG2_Y}i"+w${PS_WIDTH_IN}i cities.eps $RJOK ${VERBOSE} >> $LEGMAP
    LEG2_Y=$(echo "$LEG2_Y + $PS_HEIGHT_IN + 0.02" | bc -l)
    count=$count+1
    NEXTX=$(echo $PS_WIDTH_IN $NEXTX | gawk  '{if ($1>$2) { print $1 } else { print $2 } }')
    # cleanup cities.ps cities.eps
  ;;
  esac
}

# function tectoplot_post_cities() {
#   echo "none"
# }

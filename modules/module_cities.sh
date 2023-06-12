
TECTOPLOT_MODULES+=("cities")

# UPDATED
# DOWNLOAD
# NEW OPT

function tectoplot_defaults_cities() {
  m_cities_sourcestring="City data from OpenStreetmap (CC-BY)"
  m_cities_short_sourcestring="OSM"
  m_cities_dir="${DATAROOT}OpenStreetmap/"
  m_cities_osm="${m_cities_dir}osm_places.gpkg"
  m_cities_font="Arial,bold"
  m_cities_default_minpop=500000
}

function tectoplot_args_cities()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -pp)
  tectoplot_get_opts_inline '
des -pp plot locations of populated places (cities)
opt min m_cities_minpop float ${m_cities_default_minpop}
    minimum population of plotted cities
opt max m_cities_maxpop float 0
    maximum population of plotted cities
opt cpt m_cities_cpt cpt "none"
    CPT for coloring city shapes
opt label m_cities_labelmin float 10000000000
    label cities larger than specified population
opt font m_cities_font string "Helvetica"
    font for city labels, as a name recognizable by fontconfig
opt fontscale m_cities_psfontscale float 1
    set scale factor for city labels
opt fontcolor m_cities_fontcolor string "black"
    font fill color
opt symbol m_cities_symbol string "c"
    symbol code for city points
opt size m_cities_size string "0.05i"
    size of city points
opt fill m_cities_fill string "none"
    color for symbol fill if CPT not used
opt stroke m_cities_stroke string "0.25p,black"
    stroke definition for city symbols
opt trans m_cities_trans float 0
    transparency of labels (text OR tiff)
opt outline m_cities_outline string "none"
    specify color for text outline - turns option on
opt outwidth m_cities_outlinewidth float 0.3
    specify width of font outline (units are arbitrary)
opt outtrans m_cities_outline_trans float 0
    transparency of label outlines
opt bin m_cities_bin float 0
    hexagonal bin size for plotting only largest cities within cells
opt plaintext m_cities_plaintext flag 0
    use GMT pstext to plot ASCII city names, if available
opt gmtfont m_cities_gmtfont string "8p,Helvetica,black"
    font for tiff rendering
opt noclip m_cities_noclip flag 0
    do not clip city labels at map boundaries (GMT text only)
opt tiff m_cities_tiffflag flag 0
    use gnuplot to plot UTF8 names, rendered as a transparent GeoTIFF overlay
opt lang m_cities_language word "none"
    select an alternative name based on a language string (e.g. el for Modern Greek)
opt only m_cities_langonlyflag flag 0
    only select cities that have a name in the specified language (lang option)
opt just m_cities_just word "left"
    set justification for tiff map labels (left, right, center)
opt nolegend m_cities_nolegendflag flag 0
    do not plot city information in map legend
mes By default, uses gnuplot to create an EPS layer with UTF8 fonts that GMT
mes does not support. For plain GMT text, use the plaintext option which will
mes filter cities that (hopefully) have ASCII names plottable by GMT.
mes URL: ${m_cities_sourceurl}
exa tectoplot -r =EU -a -pp min 500000
' "${@}" || return

  calcs+=("m_cities_pp")
  plots+=("m_cities_pp")
  cpts+=("m_cities_pp")
  ;;

  esac
}

function tectoplot_download_cities() {

  check_and_download_dataset "${m_cities_sourceurl}" "${m_cities_dir}" "${m_cities_checkfile}"

}

# function tectoplot_calculate_cities()  {
#
#
# }

function tectoplot_cpt_cities() {

  case $1 in
  m_cities_pp)

    if [[ ${m_cities_cpt[$tt]} == "none" && ${m_cities_fill[$tt]} == "none" ]]; then
      m_cities_fill[$tt]="white"
    fi

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


    if [[ ${m_cities_fill[$tt]} != "none" ]]; then
       m_cities_fillcmd[$tt]="-G${m_cities_fill[$tt]}"
       m_cities_cpt[$tt]="none"
    else
      m_cities_fillcmd[$tt]="-C${m_cities_cpt_used[$tt]}"
      gmt makecpt -C${m_cities_cpt[$tt]} -I -Do -T${m_cities_minpop[$tt]}/${m_cities_maxcpt} -Z -N $VERBOSE > ${F_CPTS}population_${tt}.cpt
      m_cities_cpt_used[$tt]=${F_CPTS}population_${tt}.cpt
    fi

    tectoplot_cpt_caught=1
    ;;
  esac
}

function tectoplot_plot_cities() {
  case $1 in
    # m_cities_pd)
    # echo "[-pd]: Plotting cities and place names downloaded from geonames"
    #
    # echo curl "http://api.geonames.org/citiesJSON?north=${MAXLAT}&south=${MINLAT}&east=${MAXLON}&west=${MINLON}&lang=en&username=tectoplot"
    # curl "http://api.geonames.org/citiesJSON?north=${MAXLAT}&south=${MINLAT}&east=${MAXLON}&west=${MINLON}&lang=en&username=tectoplot" > geonames.json
    # tectoplot_plot_caught=1
    #
    # ;;
    #

    m_cities_pp)

    info_msg "[-pp]: Plotting cities with minimum population ${m_cities_minpop[$tt]} and maximum population ${m_cities_maxpop[$tt]}"

    # select all populated places within area, over the minimum population, sorted by population with largest cities last

    if [[ -s ${m_cities_osm} ]]; then
      ogr2ogr_spat ${MINLON} ${MAXLON} ${MINLAT} ${MAXLAT} osm_selected.gpkg ${m_cities_osm} 
      ogr2ogr -f "CSV" -dialect sqlite -lco SEPARATOR=TAB -sql "SELECT lon, lat, name, englishname, CAST(allnames as VARCHAR), population FROM osm_places WHERE population >= '${m_cities_minpop[$tt]}' AND population <= '${m_cities_maxpop[$tt]}' ORDER BY population" osm_selected.csv osm_selected.gpkg

      # osm_selected.csv contains escaped characters such as &apos;

      sed < osm_selected.csv "s/&apos;/\'/g" > osm_selected_clean.csv
      mv osm_selected_clean.csv osm_selected.csv

    else
      echo "City data file ${m_cities_osm} not found... attempting to download data from overpass-api.de" 
        # echo "Trying to get OSM populated place data"
      # curl --output textcities.csv  "https://overpass-api.de/api/interpreter?data=%5Bout%3Acsv%28%3A%3Alon%2C%3A%3Alat%2C%22name%22%2C%20%22name%3Aen%22%2C%20%22int_name%22%2C%20%22population%22%3B%20false%3B%20%22%5Ct%22%29%5D%5Btimeout%3A300%5D%3B%0A%28%0Anode%5Bname%5D%5Bpopulation%5D%5Bplace~%22city%7Ctown%7Cvillage%7Chamlet%22%5D%28${MINLAT}%2C${MINLON}%2C${MAXLAT}%2C${MAXLON}%29%3B%0A%29%3B%0Aout%3B"

        # if [[ -s textcities.csv ]]; then
        #   val=$(gawk < textcities.csv -F'\t' '(NR==1) {print $1 > "/dev/stderr"; print ($1+0==$1)?"yes":"no"}')
        #   echo val is ${val}
        #   if [[ $val == "yes" ]]; then
        #     echo got at least one city
        #     gawk -F'\t' < textcities.csv '{print $1 "\t" $2 "\t" $3 "\t" $6 "\t" NR }' > osmresult_${tt}.txt
        #     m_cities_toplotfile[$tt]=osmresult_${tt}.txt
        #   else
        #     echo "no cities obtained"
        #   fi
        # fi
        echo "failed to download OSM city data from overpass"
        return
    fi

    if [[ ${m_cities_plaintext[$tt]} -eq 1 ]]; then
      # If we are not plotting with a UTF8-aware method, accept only places with an English/International name
      gawk -F'\t' < osm_selected.csv '(NR>1){ if ($4 != "null") { print $1 "\t" $2 "\t" $4 "\t" $6 }}' > cities_${tt}.dat
    elif [[ ${m_cities_language[$tt]} == "none" ]]; then
      # If we haven't asked for a specific language, then use the OSM local name
      gawk -F'\t' < osm_selected.csv '(NR>1){ print $1 "\t" $2 "\t" $3 "\t" $6}' > cities_${tt}.dat
    else
      # If we ask for a specific language, then get that. If we are asking for only cities with a name
      # in that language, return those; otherwise return all cities, preferring that language and
      # substituting the OSM local name if that language doesn't exist
      # echo "selecting language ${m_cities_language[$tt]}"
      gawk -F'\t' < osm_selected.csv '
      (NR>1) { 
        # Split out the different comma-delimited entries
        split($5,langarray,",")
        # If we are willing to plot a name NOT in a requested language, initialize it
        if ('${m_cities_langonlyflag[$tt]}'==0) {
          langname=$3
        }
        for (key in langarray) {
          # Split the language ID and the name
          split(langarray[key], a, ":")
          if (a[1]=="'${m_cities_language[$tt]}'") {
            langname=a[2]
            break
          }
        }
        if (langname != "") {
          print $1 "\t" $2 "\t" langname "\t" $6
        }
      }' > cities_${tt}.dat
    fi

    if [[ -s cities_${tt}.dat ]]; then

      # Note that RTL text (Arabic) will appear strangely in files (column order
      # flipped, etc) but that the files themselves are fine.
      select_in_gmt_map_tab cities_${tt}.dat ${RJSTRING}

      m_cities_toplotfile[$tt]=cities_${tt}.dat

      # If reqeusted, cull the cities by proximity, keeping largest cities
      if [[ $(echo "${m_cities_bin[$tt]} > 0" | bc -l) -eq 1 ]]; then
        gawk < ${m_cities_toplotfile[$tt]} -F$'\t' '{
          # We want to ensure unique population values for all cities
          # so that we can uniquely join the binstats result back to the cities.
          # So add an increasing decimal to each population value
          printf("%s\t%s\t%d\n", $1, $2, NR)
        }' > cities_binprep_${tt}.txt 
        
        m_cities_usedbinflag=1

        gmt_init_tmpdir
          gmt binstats cities_binprep_${tt}.txt -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} -Th -I${m_cities_bin[$tt]} -Cu -i0,1,2 ${VERBOSE} > cities_bin_${tt}.dat 2>/dev/null
        gmt_remove_tmpdir
        
        gawk -F$'\t' '
          function abs(v) { return (v>0)?v:-v }
          # Load the binstats data with maximum population in each bin
          (NR==FNR) {
            line[$3]=1
          }
          # Load the original city data including name
          (NR!=FNR) {
            if (line[FNR]==1) {
              print
            }
          }' cities_bin_${tt}.dat cities_${tt}.dat > cities_sel_${tt}.dat

        # Based on the exact location of corner tiles, we can have cities that are
        # too close to each other to plot comfortably. So, knockout any city
        # that is closer to another than some fraction of the bin distance, retaining
        # the larger city

        # We actually want to knock out cities where labels overlap, so closeness in y
        # is less important than closeness in X. But we need a heuristic to estimate
        # how wide a label will be.

        gawk < cities_sel_${tt}.dat -F'\t' '
        @include "tectoplot_functions.awk"
        {
          data[NR]=$0
          lon[NR]=$1
          lat[NR]=$2
          pop[NR]=$4
        } 
        END {
          for(i=1; i<=NR; ++i) {
            for(j=i+1; j<=NR; ++j) {
              # Do not knockout points based on already knocked out points
              if (knockout[i] != 1 && knockout[j] != 1) {
                dist=angulardistance_m(lon[i],lat[i],lon[j],lat[j])
                # print "Dist between", lon[i], lat[i], "and", lon[j], lat[j], "is", dist > "/dev/stderr"
                if (dist < '${m_cities_bin[$tt]}'/4) {
                  if (pop[i]>pop[j]) {
                    knockout[j]=1
                  } else {
                    knockout[i]=1
                  }
                }
              }
            }
          }
          for(i=1;i<=NR;++i) {
            if (knockout[i]!=1) {
              printf("%s\n", data[i])
            } else {
              printf("%s\n", data[i]) >> "./knockout.txt"
            }
          }
        }' > cities_sel_knockout_${tt}.dat

        m_cities_toplotfile[$tt]=cities_sel_knockout_${tt}.dat
      fi


      # Plot the city symbols, largest cities on top
      if [[ "${m_cities_size[$tt]}" != "0" ]]; then      
        gawk < ${m_cities_toplotfile[$tt]} -F'\t' '{print $1 "\t" $2 "\t" $4}' | sort -n -k 3 | gmt psxy -S${m_cities_symbol[$tt]}${m_cities_size[$tt]} -W${m_cities_stroke[$tt]} ${m_cities_fillcmd[$tt]} $RJOK $VERBOSE >> map.ps
      fi

      # Plot city labels using gnuplot to enable UTF8 text
      if [[ ${m_cities_plaintext[$tt]} -eq 0 ]]; then

        # # Get the bounding box of the rectangle encompassing the map area - different from minlon/etc if we have an oblique projection
        llcoord_map=($(gmt mapproject -R -J -We --FORMAT_FLOAT_OUT="%.12f" | gmt mapproject -R -J -i0,2 --FORMAT_FLOAT_OUT="%.12f"))
        urcoord_map=($(gmt mapproject -R -J -We --FORMAT_FLOAT_OUT="%.12f" | gmt mapproject -R -J -i1,3 --FORMAT_FLOAT_OUT="%.12f"))
        lrcoord_map=($(gmt mapproject -R -J -We --FORMAT_FLOAT_OUT="%.12f" | gmt mapproject -R -J -i1,2 --FORMAT_FLOAT_OUT="%.12f"))
        ulcoord_map=($(gmt mapproject -R -J -We --FORMAT_FLOAT_OUT="%.12f" | gmt mapproject -R -J -i0,3 --FORMAT_FLOAT_OUT="%.12f"))

        max_xcoord=$(echo ${urcoord_map[0]} ${lrcoord_map[0]} | gawk '{
          print ($1 < $2)?$1:$2
        }')
        min_xcoord=$(echo ${ulcoord_map[0]} ${llcoord_map[0]} | gawk '{
          print ($1 > $2)?$1:$2
        }')
        max_ycoord=$(echo ${urcoord_map[1]} ${lrcoord_map[1]} | gawk '{
          print ($1 < $2)?$1:$2
        }')
        min_ycoord=$(echo ${ulcoord_map[1]} ${llcoord_map[1]} | gawk '{
          print ($1 > $2)?$1:$2
        }')

        max_cutoff_xcoord=$(echo ${max_xcoord} ${min_xcoord} | gawk '{print ($1-$2)*0.8+$2}')
        min_cutoff_xcoord=$(echo ${max_xcoord} ${min_xcoord} | gawk '{print ($1-$2)*0.2+$2}')
        min_cutoff_ycoord=$(echo ${max_ycoord} ${min_ycoord} | gawk '{print ($1-$2)*0.9+$2}')
        max_cutoff_ycoord=$(echo ${max_ycoord} ${min_ycoord} | gawk '{print ($1-$2)*0.1+$2}')

        # echo max_ycoord is ${max_ycoord} min_ycoord is ${min_ycoord} max_cutoff is ${max_cutoff_xcoord} min_cutoff is ${min_cutoff_xcoord} max_cutoffy is ${max_cutoff_ycoord} min_cutoffy is ${min_cutoff_ycoord}

        gmt mapproject -R -J ${m_cities_toplotfile[$tt]} -i0,1,t -f0x,1y,s | gawk -F'\t' -v pssize=${m_cities_size[$tt]} -v scale=${m_cities_psfontscale[$tt]} '
          ($4>='${m_cities_labelmin[$tt]}') {
              if (pssize+0==0) {
                yoffset=0
                if ($2 > '${max_cutoff_ycoord}') {
                  yoffset=0-'${m_cities_psfontscale[$tt]}'*1/10
                }
              } else {
                yoffset='${m_cities_psfontscale[$tt]}'*2/10
                if ($2 > '${max_cutoff_ycoord}') {
                  yoffset=0-'${m_cities_psfontscale[$tt]}'*2/10
                }
              }
              if ($1 > '${max_cutoff_xcoord}') {
                print $3 "\t" $5 "\t" $4 "\t" $1-0.1 "\t" $2+yoffset > "cities_right.dat"
              } else if ($1 < '${min_cutoff_xcoord}') {
                print $3 "\t" $5 "\t" $4 "\t" $1+0.1 "\t" $2+yoffset > "cities_left.dat"
              } else {
                print $3 "\t" $5 "\t" $4 "\t" $1 "\t" $2+yoffset > "cities.dat"
              }
          }' 


        if [[ ! -s cities.dat && ! -s cities_left.dat  && ! -s cities_right.dat ]]; then
          return
        fi

        touch cities.dat cities_left.dat cities_right.dat

        cat cities.dat cities_left.dat cities_right.dat > cities_combined.dat 

        # Use the range of the points to establish the range of plot

        projrange=($(cat cities_combined.dat | gawk -F'\t' '
          BEGIN {
              getline;
              minX=$4; maxX=$4; minY=$5; maxY=$5
          }
          {
            minX=($4<minX)?$4:minX;
            maxX=($4>maxX)?$4:maxX;
            minY=($5<minY)?$5:minY;
            maxY=($5>maxY)?$5:maxY
          }
          END {
            print minX, maxX, minY, maxY
          }'))

        # Don't care about resolution now that we are using EPS instead of TIFF
        # llcoord[0]=${projrange[0]}
        # urcoord[0]=${projrange[1]}
        # llcoord[1]=${projrange[2]}
        # urcoord[1]=${projrange[3]}

        llcoord[0]=${llcoord_map[0]}
        urcoord[0]=${urcoord_map[0]}
        llcoord[1]=${llcoord_map[1]}
        urcoord[1]=${urcoord_map[1]}

  # We want to right justify any points that are too far to the right of the figure
  # 
  # lon1 lat2    lon2 lat2            0 3      1 3
  #
  #
  #
  # lon1 lat1    lon2 lat1         0 2               1 2
  #
  #
  #

        # Add a buffer around this box (in page coordinates) so that we don't chop off labels at the map boundary
        llcoordP[0]=$(echo "${llcoord[0]} - 0.2*(${urcoord[0]} - ${llcoord[0]})" | bc -l)
        urcoordP[0]=$(echo "${urcoord[0]} + 0.2*(${urcoord[0]} - ${llcoord[0]})" | bc -l)

        llcoordP[1]=$(echo "${llcoord[1]} - 0.2*(${urcoord[1]} - ${llcoord[1]})" | bc -l)
        urcoordP[1]=$(echo "${urcoord[1]} + 0.2*(${urcoord[1]} - ${llcoord[1]})" | bc -l)

        # Set the width in pixels of the PNG containing the label text
        labelres=10000

        # Calculate the height in pixels of the PNG, given the shape of the AOI
        ypix=$(echo "${labelres}*(${urcoordP[1]} - ${llcoordP[1]})/(${urcoordP[0]} - ${llcoordP[0]})" | bc)

         # echo ypix is $ypix


if [[ -s cities.dat ]]; then
        cat <<-EOF > cities.dem
#!/usr/local/bin/gnuplot -persist
set terminal pngcairo background "0xffffff" font "${m_cities_font[$tt]}" fontscale 8 size ${labelres}, ${ypix}
set output 'cities.1.png'
unset border
unset key
set datafile separator "	"
set style data lines
set style line 1 lc rgb 'black' pt 5   # square
unset xtics
unset ytics
# Set the margins to 0 so that there is no extra whitespace around the map
set lmargin 0
set rmargin 0
set tmargin 0
set bmargin 0
# Use the expanded map area
set xrange [ ${llcoordP[0]} : ${urcoordP[0]} ] noreverse writeback
set x2range [  ${llcoordP[0]} : ${urcoordP[0]} ] noreverse writeback
set yrange [ ${llcoordP[1]} : ${urcoordP[1]} ] noreverse writeback
set y2range [ ${llcoordP[1]} : ${urcoordP[1]} ] noreverse writeback
set zrange [ * : * ] noreverse writeback
set cbrange [ * : * ] noreverse writeback
set rrange [ * : * ] noreverse writeback
# set colorbox vertical origin screen 0, 0 size screen 0.05, 0.6 front  noinvert bdefault
# Set the scaling rule for the size of the labels
Scale(size) = log(column(size)>100?column(size):100)
# Connect the size and text together
CityName(String,Size) = sprintf("{/=%d %s}", Scale(Size), stringcolumn(String))
NO_ANIMATION = 1
# UTF8 is important so that labels come out looking right
save_encoding = "utf8"
plot 'cities.dat' using 4:5:(CityName(1,3)) with labels ${m_cities_just[$tt]} tc "${m_cities_fontcolor[$tt]}"
EOF
gnuplot cities.dem

        cat <<-EOF > cities_eps.dem
#!/usr/local/bin/gnuplot -persist
set terminal eps font "${m_cities_font[$tt]}" fontscale ${m_cities_psfontscale[$tt]} size $(echo "${urcoordP[0]} - ${llcoordP[0]}" | bc -l), $(echo "${urcoordP[1]} - ${llcoordP[1]}" | bc -l)
set output 'cities.1.eps'
unset border
unset key
set datafile separator "	"
set style data lines
set style line 1 lc rgb 'black' pt 5   # square
unset xtics
unset ytics
# Set the margins to 0 so that there is no extra whitespace around the map
set lmargin 0
set rmargin 0
set tmargin 0
set bmargin 0
# Use the expanded map area
set xrange [ ${llcoordP[0]} : ${urcoordP[0]} ] noreverse writeback
set x2range [  ${llcoordP[0]} : ${urcoordP[0]} ] noreverse writeback
set yrange [ ${llcoordP[1]} : ${urcoordP[1]} ] noreverse writeback
set y2range [ ${llcoordP[1]} : ${urcoordP[1]} ] noreverse writeback
set zrange [ * : * ] noreverse writeback
set cbrange [ * : * ] noreverse writeback
set rrange [ * : * ] noreverse writeback
# Set the scaling rule for the size of the labels
Scale(size) = log(column(size)>100?column(size):100)
# Connect the size and text together
CityName(String,Size) = sprintf("{/=%d %s}", Scale(Size), stringcolumn(String))
NO_ANIMATION = 1
# UTF8 is important so that labels come out looking right
save_encoding = "utf8"
## Last datafile plotted: "cities.dat"
# plot "cities.dat" using 4:5 with points pt 5
# Plot it
plot 'cities.dat' using 4:5:(CityName(1,3)) with labels ${m_cities_just[$tt]} tc "${m_cities_fontcolor[$tt]}"
EOF
gnuplot cities_eps.dem

  if [[ ${m_cities_outline[$tt]} != "none" ]]; then
        cat <<-EOF > cities_eps_stroke.dem
#!/usr/local/bin/gnuplot -persist
set terminal eps font "${m_cities_font[$tt]}" fontscale ${m_cities_psfontscale[$tt]} size $(echo "${urcoordP[0]} - ${llcoordP[0]}" | bc -l), $(echo "${urcoordP[1]} - ${llcoordP[1]}" | bc -l)
set output 'cities_stroke.eps'
unset border
unset key
set datafile separator "	"
set style data lines
set style line 1 lc rgb 'black' pt 5   # square
unset xtics
unset ytics
# Set the margins to 0 so that there is no extra whitespace around the map
set lmargin 0
set rmargin 0
set tmargin 0
set bmargin 0
# Use the expanded map area
set xrange [ ${llcoordP[0]} : ${urcoordP[0]} ] noreverse writeback
set x2range [  ${llcoordP[0]} : ${urcoordP[0]} ] noreverse writeback
set yrange [ ${llcoordP[1]} : ${urcoordP[1]} ] noreverse writeback
set y2range [ ${llcoordP[1]} : ${urcoordP[1]} ] noreverse writeback
set zrange [ * : * ] noreverse writeback
set cbrange [ * : * ] noreverse writeback
set rrange [ * : * ] noreverse writeback
# Set the scaling rule for the size of the labels
Scale(size) = log(column(size)>100?column(size):100)
# Connect the size and text together
CityName(String,Size) = sprintf("{/=%d %s}", Scale(Size), stringcolumn(String))
NO_ANIMATION = 1
# UTF8 is important so that labels come out looking right
save_encoding = "utf8"
## Last datafile plotted: "cities.dat"
# plot "cities.dat" using 4:5 with points pt 5
# Plot it
plot 'cities.dat' using 4:5:(CityName(1,3)) with labels ${m_cities_just[$tt]} tc "${m_cities_outline[$tt]}"
EOF
    
    gnuplot cities_eps_stroke.dem

    if [[ -s cities_stroke.eps ]]; then 
      gawk < cities_stroke.eps '
      {
        if ($1=="/PaintType") {
          print "/PaintType 2 def"
          print "/StrokeWidth '${m_cities_outlinewidth[$tt]}' def"
        } else if ($1=="%%EndPageSetup") {
          print "%%EndPageSetup"
          print "2 setlinecap"
          print "1 setlinejoin"
        } else if ($(NF) == "rectclip") {
          # do not print the rectclip command to avoid clipping the wider outline
        } else {
          print
        }
      }' > cities_stroke_fixed.eps
    fi
  fi
fi

if [[ -s cities_right.dat ]]; then

cat <<-EOF > cities_eps_right.dem
#!/usr/local/bin/gnuplot -persist
set terminal eps font "${m_cities_font[$tt]}" fontscale ${m_cities_psfontscale[$tt]} size $(echo "${urcoordP[0]} - ${llcoordP[0]}" | bc -l), $(echo "${urcoordP[1]} - ${llcoordP[1]}" | bc -l)
set output 'cities_right.eps'
unset border
unset key
set datafile separator "	"
set style data lines
set style line 1 lc rgb 'black' pt 5   # square
unset xtics
unset ytics
# Set the margins to 0 so that there is no extra whitespace around the map
set lmargin 0
set rmargin 0
set tmargin 0
set bmargin 0
# Use the expanded map area
set xrange [ ${llcoordP[0]} : ${urcoordP[0]} ] noreverse writeback
set x2range [  ${llcoordP[0]} : ${urcoordP[0]} ] noreverse writeback
set yrange [ ${llcoordP[1]} : ${urcoordP[1]} ] noreverse writeback
set y2range [ ${llcoordP[1]} : ${urcoordP[1]} ] noreverse writeback
set zrange [ * : * ] noreverse writeback
set cbrange [ * : * ] noreverse writeback
set rrange [ * : * ] noreverse writeback
# Set the scaling rule for the size of the labels
Scale(size) = log(column(size)>100?column(size):100)
# Connect the size and text together
CityName(String,Size) = sprintf("{/=%d %s}", Scale(Size), stringcolumn(String))
NO_ANIMATION = 1
# UTF8 is important so that labels come out looking right
save_encoding = "utf8"
## Last datafile plotted: "cities.dat"
# plot "cities.dat" using 4:5 with points pt 5
# Plot it
plot 'cities_right.dat' using 4:5:(CityName(1,3)) with labels right tc "${m_cities_fontcolor[$tt]}"
EOF
gnuplot cities_eps_right.dem

  if [[ ${m_cities_outline[$tt]} != "none" ]]; then
cat <<-EOF > cities_eps_right_stroke.dem
#!/usr/local/bin/gnuplot -persist
set terminal eps font "${m_cities_font[$tt]}" fontscale ${m_cities_psfontscale[$tt]} size $(echo "${urcoordP[0]} - ${llcoordP[0]}" | bc -l), $(echo "${urcoordP[1]} - ${llcoordP[1]}" | bc -l)
set output 'cities_right_stroke.eps'
unset border
unset key
set datafile separator "	"
set style data lines
set style line 1 lc rgb 'black' pt 5   # square
unset xtics
unset ytics
# Set the margins to 0 so that there is no extra whitespace around the map
set lmargin 0
set rmargin 0
set tmargin 0
set bmargin 0
# Use the expanded map area
set xrange [ ${llcoordP[0]} : ${urcoordP[0]} ] noreverse writeback
set x2range [  ${llcoordP[0]} : ${urcoordP[0]} ] noreverse writeback
set yrange [ ${llcoordP[1]} : ${urcoordP[1]} ] noreverse writeback
set y2range [ ${llcoordP[1]} : ${urcoordP[1]} ] noreverse writeback
set zrange [ * : * ] noreverse writeback
set cbrange [ * : * ] noreverse writeback
set rrange [ * : * ] noreverse writeback
# Set the scaling rule for the size of the labels
Scale(size) = log(column(size)>100?column(size):100)
# Connect the size and text together
CityName(String,Size) = sprintf("{/=%d %s}", Scale(Size), stringcolumn(String))
NO_ANIMATION = 1
# UTF8 is important so that labels come out looking right
save_encoding = "utf8"
## Last datafile plotted: "cities.dat"
# plot "cities.dat" using 4:5 with points pt 5
# Plot it
plot 'cities_right.dat' using 4:5:(CityName(1,3)) with labels right tc "${m_cities_outline[$tt]}"
EOF
    gnuplot cities_eps_right_stroke.dem

    if [[ -s cities_right_stroke.eps ]]; then 
      gawk < cities_right_stroke.eps '
      {
        if ($1=="/PaintType") {
          print "/PaintType 2 def"
          print "/StrokeWidth 0.3 def"
        } else if ($1=="%%EndPageSetup") {
          print "%%EndPageSetup"
          print "2 setlinecap"
          print "1 setlinejoin"
        } else if ($(NF) == "rectclip") {
          # do not print the rectclip command to avoid clipping the wider outline
        } else {
          print
        }
      }' > cities_right_stroke_fixed.eps
    fi
  fi
fi

if [[ -s cities_left.dat ]]; then

cat <<-EOF > cities_eps_left.dem
#!/usr/local/bin/gnuplot -persist
set terminal eps font "${m_cities_font[$tt]}" fontscale ${m_cities_psfontscale[$tt]} size $(echo "${urcoordP[0]} - ${llcoordP[0]}" | bc -l), $(echo "${urcoordP[1]} - ${llcoordP[1]}" | bc -l)
set output 'cities_left.eps'
unset border
unset key
set datafile separator "	"
set style data lines
set style line 1 lc rgb 'black' pt 5   # square
unset xtics
unset ytics
# Set the margins to 0 so that there is no extra whitespace around the map
set lmargin 0
set rmargin 0
set tmargin 0
set bmargin 0
# Use the expanded map area
set xrange [ ${llcoordP[0]} : ${urcoordP[0]} ] noreverse writeback
set x2range [  ${llcoordP[0]} : ${urcoordP[0]} ] noreverse writeback
set yrange [ ${llcoordP[1]} : ${urcoordP[1]} ] noreverse writeback
set y2range [ ${llcoordP[1]} : ${urcoordP[1]} ] noreverse writeback
set zrange [ * : * ] noreverse writeback
set cbrange [ * : * ] noreverse writeback
set rrange [ * : * ] noreverse writeback
# Set the scaling rule for the size of the labels
Scale(size) = log(column(size)>100?column(size):100)
# Connect the size and text together
CityName(String,Size) = sprintf("{/=%d %s}", Scale(Size), stringcolumn(String))
NO_ANIMATION = 1
# UTF8 is important so that labels come out looking right
save_encoding = "utf8"
## Last datafile plotted: "cities.dat"
# plot "cities.dat" using 4:5 with points pt 5
# Plot it
plot 'cities_left.dat' using 4:5:(CityName(1,3)) with labels left tc "${m_cities_fontcolor[$tt]}"
EOF
  gnuplot cities_eps_left.dem

  if [[ ${m_cities_outline[$tt]} != "none" ]]; then
cat <<-EOF > cities_eps_left_stroke.dem
#!/usr/local/bin/gnuplot -persist
set terminal eps font "${m_cities_font[$tt]}" fontscale ${m_cities_psfontscale[$tt]} size $(echo "${urcoordP[0]} - ${llcoordP[0]}" | bc -l), $(echo "${urcoordP[1]} - ${llcoordP[1]}" | bc -l)
set output 'cities_left_stroke.eps'
unset border
unset key
set datafile separator "	"
set style data lines
set style line 1 lc rgb 'black' pt 5   # square
unset xtics
unset ytics
# Set the margins to 0 so that there is no extra whitespace around the map
set lmargin 0
set rmargin 0
set tmargin 0
set bmargin 0
# Use the expanded map area
set xrange [ ${llcoordP[0]} : ${urcoordP[0]} ] noreverse writeback
set x2range [  ${llcoordP[0]} : ${urcoordP[0]} ] noreverse writeback
set yrange [ ${llcoordP[1]} : ${urcoordP[1]} ] noreverse writeback
set y2range [ ${llcoordP[1]} : ${urcoordP[1]} ] noreverse writeback
set zrange [ * : * ] noreverse writeback
set cbrange [ * : * ] noreverse writeback
set rrange [ * : * ] noreverse writeback
# Set the scaling rule for the size of the labels
Scale(size) = log(column(size)>100?column(size):100)
# Connect the size and text together
CityName(String,Size) = sprintf("{/=%d %s}", Scale(Size), stringcolumn(String))
NO_ANIMATION = 1
# UTF8 is important so that labels come out looking right
save_encoding = "utf8"
## Last datafile plotted: "cities.dat"
# plot "cities.dat" using 4:5 with points pt 5
# Plot it
plot 'cities_left.dat' using 4:5:(CityName(1,3)) with labels left tc "${m_cities_outline[$tt]}"
EOF
        gnuplot cities_eps_left_stroke.dem


        if [[ -s cities_left_stroke.eps ]]; then 
          gawk < cities_left_stroke.eps '
          {
            if ($1=="/PaintType") {
              print "/PaintType 2 def"
              print "/StrokeWidth 0.3 def"
            } else if ($1=="%%EndPageSetup") {
              print "%%EndPageSetup"
              print "2 setlinecap"
              print "1 setlinejoin"
            } else if ($(NF) == "rectclip") {
              # do not print the rectclip command to avoid clipping the wider outline
            } else {
              print
            }
          }' > cities_left_stroke_fixed.eps
        fi
    fi
fi

        gmt_init_tmpdir

          # convert cities.1.png  \( +clone -alpha extract -morphology edge square:5 -threshold 50% -fill red -opaque white -transparent black \) -composite result.png
          # gmt grdfilter -Fg9 cities.1.png -Gcities.filter.nc -D2

          # We need to plot the image over the map, but in an XY coordinate system matching the page size and shifted to make the origin fall at 0,0
          if [[ ${m_cities_tiffflag} -eq 1 ]]; then
             gmt grdimage cities.1.png -R${llcoordP[0]}/${urcoordP[0]}/${llcoordP[1]}/${urcoordP[1]} -JX$(echo "${urcoordP[0]} - ${llcoordP[0]}" | bc -l)/$(echo "${urcoordP[1]} - ${llcoordP[1]}" | bc -l) -Xa${llcoordP[0]} -Ya${llcoordP[1]} -t${m_cities_trans[$tt]} -O -K >> map.ps
          else
            if [[ ${m_cities_outline[$tt]} != "none" ]]; then
              [[ -s cities_stroke_fixed.eps ]] && gmt psimage cities_stroke_fixed.eps -Dx0/0+w$(echo "${urcoordP[0]} - ${llcoordP[0]}" | bc -l)/$(echo "${urcoordP[1]} - ${llcoordP[1]}" | bc -l)  -Xa${llcoordP[0]} -Ya${llcoordP[1]} -O -K -t${m_cities_outline_trans[$tt]} >> map.ps
              [[ -s cities_left_stroke_fixed.eps ]] && gmt psimage cities_left_stroke_fixed.eps -Dx0/0+w$(echo "${urcoordP[0]} - ${llcoordP[0]}" | bc -l)/$(echo "${urcoordP[1]} - ${llcoordP[1]}" | bc -l)  -Xa${llcoordP[0]} -Ya${llcoordP[1]} -O -K -t${m_cities_outline_trans[$tt]} >> map.ps
              [[ -s cities_right_stroke_fixed.eps ]] && gmt psimage cities_right_stroke_fixed.eps -Dx0/0+w$(echo "${urcoordP[0]} - ${llcoordP[0]}" | bc -l)/$(echo "${urcoordP[1]} - ${llcoordP[1]}" | bc -l)  -Xa${llcoordP[0]} -Ya${llcoordP[1]} -O -K -t${m_cities_outline_trans[$tt]} >> map.ps
            fi

            [[ -s cities.1.eps ]] && gmt psimage cities.1.eps -Dx0/0+w$(echo "${urcoordP[0]} - ${llcoordP[0]}" | bc -l)/$(echo "${urcoordP[1]} - ${llcoordP[1]}" | bc -l)  -Xa${llcoordP[0]} -Ya${llcoordP[1]} -O -K -t${m_cities_trans[$tt]} >> map.ps
            [[ -s cities_left.eps ]] && gmt psimage cities_left.eps -Dx0/0+w$(echo "${urcoordP[0]} - ${llcoordP[0]}" | bc -l)/$(echo "${urcoordP[1]} - ${llcoordP[1]}" | bc -l)  -Xa${llcoordP[0]} -Ya${llcoordP[1]} -O -K -t${m_cities_trans[$tt]} >> map.ps
            [[ -s cities_right.eps ]] && gmt psimage cities_right.eps -Dx0/0+w$(echo "${urcoordP[0]} - ${llcoordP[0]}" | bc -l)/$(echo "${urcoordP[1]} - ${llcoordP[1]}" | bc -l)  -Xa${llcoordP[0]} -Ya${llcoordP[1]} -O -K -t${m_cities_trans[$tt]} >> map.ps
          fi
        gmt_remove_tmpdir        

      else
        if [[ ${m_cities_noclip[$tt]} -eq 1 ]]; then
          local citiesclip="-N"
        else
          local citiesclip=""
        fi
        local citiesjust
        case ${m_cities_just[$tt]} in
          left) citiesjust="LM" ;;
          right) citiesjust="RM" ;;
          center) citiesjust="CM" ;;
        esac

        gawk < ${m_cities_toplotfile[$tt]} -F'\t' -v minpop=${m_cities_labelmin[$tt]} '($4>=minpop){print $1 "\t" $2 "\t" $3}' \
          | sort -n -k 3  \
          | gmt pstext -DJ${m_cities_size[$tt]}/${m_cities_size[$tt]} -F+f${m_cities_gmtfont[$tt]}+j${citiesjust} ${citiesclip} $RJOK $VERBOSE >> map.ps
      fi
    fi

    echo $m_cities_short_sourcestring >> ${SHORTSOURCES}
    echo $m_cities_sourcestring >> ${LONGSOURCES}

    tectoplot_plot_caught=1
    ;;
  esac
}

function tectoplot_legendbar_cities() {
  case $1 in
    m_cities_pp)
      if [[ ${m_cities_nolegendflag[$tt]} -ne 1 ]]; then
        if [[ ${m_cities_cpt[$tt]} != "none" ]]; then
          echo "G StrokeWidth 0.1i" >> ${LEGENDDIR}legendbars.txt
          echo "B ${m_cities_cpt_used[$tt]} 0.2i 0.1i+malu -W0.00001 ${LEGENDBAR_OPTS} -Bxaf+l\"City population (100k)\"" >> ${LEGENDDIR}legendbars.txt
          barplotcount=$barplotcount+1
        fi
      fi
      tectoplot_legendbar_caught=1
      ;;
  esac
}

function tectoplot_legend_cities() {
  case $1 in
  m_cities_pp)

    if [[ ${m_cities_nolegendflag[$tt]} -ne 1 ]]; then

      init_legend_item "cities_${tt}"

      if [[ ${m_cities_usedbinflag} -eq 1 ]]; then 
        m_cities_cityname="Selected cities"
      else
        m_cities_cityname="Cities"
      fi

      if [[ ${m_cities_minpop[$tt]} -eq 0 ]]; then
        m_cities_legendstring="${m_cities_cityname} with population <= ${m_cities_maxpop[$tt]}"
      elif [[ ${m_cities_maxpop[$tt]} -eq 100000000 ]]; then
        m_cities_legendstring="${m_cities_cityname}with population >= ${m_cities_minpop[$tt]}"
      else
        m_cities_legendstring="${m_cities_cityname} with population ${m_cities_minpop[$tt]}-${m_cities_maxpop[$tt]}"
      fi

      echo "${CENTERLON} ${CENTERLAT} 10000" | gmt psxy -S${m_cities_symbol[$tt]}${m_cities_size[$tt]} -W${m_cities_stroke[$tt]} ${m_cities_fillcmd[$tt]} $RJOK $VERBOSE -X.175i >> ${LEGFILE}
      echo "${CENTERLON} ${CENTERLAT} ${m_cities_legendstring}" | gmt pstext -F+f6p,Helvetica,black+jLM -X0.15i ${RJOK} $VERBOSE >> ${LEGFILE}

      # Plot the symbol and accompanying text at the CENTERLON/CENTERLAT point (known to be on the map)
      close_legend_item "cities_${tt}"
    fi
    tectoplot_legend_caught=1
  ;;
  esac
}

# function tectoplot_post_cities() {
#   echo "none"
# }

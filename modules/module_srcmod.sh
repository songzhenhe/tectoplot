
TECTOPLOT_MODULES+=("srcmod")

# Calculate residual grid by removing along-line average, using da-dt formulation
# Builtin support for gravity grids

# Variables needed:


function tectoplot_defaults_srcmod() {

  ##### SRCMOD slip distribution folder
  SRCMOD_SOURCESTRING="SRCMOD, http://equake-rc.info/srcmod/"
  SRCMOD_SHORT_SOURCESTRING="SRCMOD"

  SRCMODFSPFOLDER=$DATAROOT"SRCMOD/"
  SRCMODFSPLOCATIONS=$DATAROOT"SRCMOD/FSPLocations.txt"

  ################################################################################
  ### SRCMOD slip distributions
  SLIPMINIMUM=3                # SRCMOD minimum slip that is colored (m)
  SLIPMINPCT=10                # SLIPMIN=SLIPMINPCT*SLIP"MAX
  SLIPMAXIMUM=25               # SRCMOD maximum slip that is colored (m)

  SLIPRESOL=300
  SRCMOD_TRANS=40
  SRCMOD_NOGRID=0
}

function tectoplot_args_srcmod()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -s)

  cat <<-EOF > s
des -s plot earthquake slip data from SRCMOD
opn update m_srcmod_s_update flag 0
    try to update SRCMOD catalog
opt all m_srcmod_s_all flag 0
    plot all SRCMOD events within AOI
opt nogrid m_srcmod_s_nogrid flag 0
    do not plot the grid raster
opt id m_srcmod_s_filter string "none"
    strings that are used to filter events based on ID info
opt strike m_srcmod_s_strike float -9999
    plot slip vectors relative to the specified strike direction
opt strike m_srcmod_s_dip float -9999
    plot slip vectors relative to the specified dip value
opt int m_srcmod_s_int float 2
    contour interval for drawn contours
opt min m_srcmod_s_min float 3
    minimum slip magnitude that is considered for plotting contours/grid
opt max m_srcmod_s_max float 25
    maximum slip magnitude that is considered for CPT
exa tectoplot -r JP -s
EOF

  if [[ $USAGEFLAG -eq 1 ]]; then
    tectoplot_usage_opts s
  else
    tectoplot_get_opts s "${@}"

    plots+=("m_srcmod_s")
    cpts+=("m_srcmod_s")

    tectoplot_module_caught=1
  fi

    ;;

  esac
}

# We download the relevant data in the _calculate_ function as this is the first time we should
# be accessing the data itself.

function tectoplot_calculate_srcmod()  {

  # SRCMOD updates with a new ZIP file name every time.... yaaay

  if [[ $m_srcmod_s_update -eq 1 ]]; then

    if URL="http://equake-rc.info"$(curl http://equake-rc.info/SRCMOD/download/ | grep ">FSP files " | gawk -F\" '{print $2}'); then
      local oldurl=$(head -n 1 ${SRCMODFSPFOLDER}oldurl.txt)

      if [[ $URL == ${oldurl} ]]; then
        echo "SRCMOD: no new zip file exists, not downloading"
      else
        echo "SRCMOD: zip with different URL  exists, trying to download"

        local retryflag=1
        local downloadedflag=0
        while [[ $retryflag -eq 1 ]]; do
          if ! curl $URL -o ${SRCMODFSPFOLDER}srcmod.zip; then
            read -r -p "SRCMOD download failed. Retry? [Y/n]: " response
            case $response in
              Y|y|"")
                retryflag=1
              ;;
              *)
                retryflag=0
              ;;
            esac
          else
            downloadedflag=1
            retryflag=0
          fi
        done
      fi
    else
      echo "Could not locate current SRCMOD zip file; check http://equake-rc.info/SRCMOD/download/"
    fi

    if [[ $downloadedflag -eq 1 ]]; then
      echo "Extracting SRCMOD FSP files: "
      rm -f ${SRCMODFSPFOLDER}/*.fsp
      rm -f ${SRCMODFSPLOCATIONS}
      unzip ${SRCMODFSPFOLDER}/srcmod.zip -d ${SRCMODFSPFOLDER}
      echo $URL > ${SRCMODFSPFOLDER}oldurl.txt
    fi
  fi
}

function tectoplot_cpt_srcmod() {
  gmt makecpt -Chot -I -Do -T0/${m_srcmod_s_max[$tt]}/0.1 -N $VERBOSE > ${F_CPTS}faultslip.cpt
}

function tectoplot_plot_srcmod() {

  case $1 in
  m_srcmod_s)

    if [[ ${m_srcmod_s_strike[$tt]} -ne -9999 && ${m_srcmod_s_dip[$tt]} -ne -9999 ]]; then
      srcmodrakeflag=1
    else
      srcmodrakeflag=0
    fi

    ##########################################################################################
    # Calculate and plot a 'fused' large earthquake slip distribution from SRCMOD events
    # We need to determine a resolution for gmt surface, but in km. Use width of image
    # in degrees

    # NOTE that SRCMODFSPLOCATIONS needs to be generated using extract_fsp_locations.sh

    # ALSO NOTE that this doesn't really work well right now...

    if [[ -e $SRCMODFSPLOCATIONS ]]; then
      info_msg "SRCMOD FSP data file exists"
    else
      # Extract locations of earthquakes and output filename,Lat,Lon to a text file
      info_msg "Building SRCMOD FSP location file"
      comeback=$(pwd)
      cd ${SRCMODFSPFOLDER}
      eval "grep -H 'Loc  :' *" | gawk  -F: '{print $1, $3 }' | gawk  '{print $7 "	" $4 "	" $1}' > $SRCMODFSPLOCATIONS
      cd $comeback
    fi

    info_msg "Identifying SRCMOD results falling within the AOI"
    # LON EDIT
      gawk < $SRCMODFSPLOCATIONS -v minlat="$MINLAT" -v maxlat="$MAXLAT" -v minlon="$MINLON" -v maxlon="$MAXLON" '
      @include "tectoplot_functions.awk"
      {
        if (test_lon(minlon, maxlon, $1) && ($2 < maxlat) && ($2 > minlat)) {
          print $3
        }
      }' > srcmod_eqs.txt
    [[ $narrateflag -eq 1 ]] && cat srcmod_eqs.txt

    LONDIFF=$(echo $MAXLON - $MINLON | bc -l)
    LONKM=$(echo "$LONDIFF * 110 * c( ($MAXLAT - $MINLAT) * 3.14159265358979 / 180 / 2)"/$SLIPRESOL | bc -l)
    info_msg "LONDIFF is $LONDIFF"
    info_msg "LONKM is $LONKM"

    # Add all earthquake model slips together into a fused slip raster.
    # Create an empty 0 raster with a resolution of LONKM
    #echo | gmt xyz2grd -di0 -R -I"$LONKM"km -Gzero.nc

    gmt grdmath $VERBOSE -R -I"$LONKM"k 0 = slip.nc
    #rm -f slip2.nc
    v=($(cat srcmod_eqs.txt | tr ' ' '\n'))
    i=0

    # If any earthquakes exist within the AOI, then:
    if [[ ${#v[@]} -gt 0 ]]; then

      # If we are plotting all, populate the array
      if [[ ${m_srcmod_s_all[$tt]} -eq 1 ]]; then
        responsearr=($(seq 0 $(echo "${#v[@]}-1" | bc)))
      else
        # Otherwise, check each potential earthquake for match to a grepstring
        while [[ $i -lt ${#v[@]} ]]; do
          thiseq=$(grep "Event : " "$SRCMODFSPFOLDER"${v[$i]} | gawk -F'\t' '{print $3, $5}')

          if [[ ${#srcmodgrep[@]} -ge 1 ]]; then
            grepinclude=1
            for grepstring in ${srcmodgrep[@]}; do
              if [[ $thiseq != *"$grepstring"* ]]; then
                grepinclude=0
              fi
            done
            if [[ $grepinclude -eq 1 ]]; then
              responsearr+=("$i")
            fi
          else
            echo "$i : $thiseq"
          fi
          i=$(echo "$i+1" | bc)
        done

        if [[ ${#responsearr[@]} -eq 0 ]]; then
          read -r -p "Enter earthquake ID numbers to plot, space separated (or enter all or none): " response
          if [[ $response == "all" ]]; then
            responsearr=($(seq 0 $(echo "${#v[@]}-1" | bc)))
          elif [[ $response == "none" ]]; then
            unset responsearr
          else
            responsearr=($(echo $response))
          fi
        fi
      fi

      # Process each earthquake selected datafile
      for thiseq in ${responsearr[@]}; do
        cp "$SRCMODFSPFOLDER"${v[$thiseq]} srcmod${v[$thiseq]}.dat
        grep "^[^%;]" "$SRCMODFSPFOLDER"${v[$thiseq]} | gawk  '{print $2, $1, $6}' > temp1.xyz

        if [[ $srcmodrakeflag -eq 1 ]]; then
          grep "^[^%;]" "$SRCMODFSPFOLDER"${v[$thiseq]} | gawk -v strike=${m_srcmod_s_strike[$tt]} -v dip=${m_srcmod_s_dip[$tt]} '
            @include "tectoplot_functions.awk"
            {
              rake=$7
              RHRrake=180-rake
              tanR=tan(deg2rad(RHRrake))
              cosD=cos(deg2rad(dip))
              beta=abs(rad2deg(atan(tanR*cosD)))
              traw=180+((RHRrake>90)?strike+180-beta:strike+beta)
              while(traw>360) {
                traw=traw-360
              }
              print $2, $1, traw, $6/100
            }' > temp1sliprake.xyz
        fi

        # VERBOSE="-V"
        gmt blockmean temp1.xyz -I"$LONKM"k $VERBOSE -R > temp.xyz
        gmt triangulate temp.xyz -I"$LONKM"k -Gtemp2.nc -R $VERBOSE
        gmt surface temp.xyz -Ll0 -Gtemp.nc -Rtemp2.nc $VERBOSE
        gmt grdmath $VERBOSE temp2.nc ${m_srcmod_s_min[$tt]} LE 1 NAN = mask.grd
        gmt grdmath $VERBOSE temp.nc mask.grd OR = slipfinal.grd
        if [[ ${m_srcmod_s_nogrid[$tt]} -eq 0 ]]; then
          gmt grdimage slipfinal.grd ${RJSTRING} -C${F_CPTS}faultslip.cpt -t${SRCMOD_TRANS} -Q -O -K $VERBOSE >> map.ps
        fi
        gmt grdcontour slipfinal.grd -A5 -S3 -C${m_srcmod_s_int[$tt]} ${RJSTRING} -O -K $VERBOSE >> map.ps
        if [[ $srcmodrakeflag -eq 1 ]]; then
          gmt psxy temp1sliprake.xyz -Gblack -SV0.05i+jb+e -W0.5p,black ${RJSTRING} -O -K $VERBOSE >> map.ps
        fi
        echo $SRCMOD_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        echo $SRCMOD_SOURCESTRING >> ${LONGSOURCES}

      done

    fi
    tectoplot_plot_caught=1
    ;;
  esac

}

function tectoplot_legendbar_srcmod() {
  case $1 in
    m_srcmod_s)
      echo "G 0.2i" >>${LEGENDDIR}legendbars.txt
      echo "B ${F_CPTS}faultslip.cpt 0.2i 0.1i+malu -Bxa5f1+l\"Slip (m)\"" >>${LEGENDDIR}legendbars.txt
      barplotcount=$barplotcount+1
      tectoplot_caught_legendbar=1
    ;;
  esac
}

# function tectoplot_legend_srcmod() {
#   # Create a new blank map with the same -R -J as our main map
#   gmt psxy -T -X0i -Yc $OVERLAY $VERBOSE -K ${RJSTRING} > srcmod.ps
#
#   echo "${CENTERLON} ${CENTERLAT} 10000" | gmt psxy -Xa0.35i -S${CITIES_SYMBOL}${CITIES_SYMBOL_SIZE} -W${CITIES_SYMBOL_LINEWIDTH},${CITIES_SYMBOL_LINECOLOR} -C$POPULATION_CPT $RJOK $VERBOSE >> srcmod.ps
#   echo "${CENTERLON} ${CENTERLAT} City > ${CITIES_MINPOP}" | gmt pstext -Y0.15i -F+f${CITIES_LABEL_FONTSIZE},${CITIES_LABEL_FONT},${CITIES_LABEL_FONTCOLOR}+jLM -R -J -O $VERBOSE >> srcmod.ps
#
#   # Plot the symbol and accompanying text at the CENTERLON/CENTERLAT point (known to be on the map)
#
#   # Calculate the width and height of the graphic with a margin of 0.05i
#   PS_DIM=$(gmt psconvert srcmod.ps -Te -A+m0.05i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
#   PS_WIDTH_IN=$(echo $PS_DIM | gawk  '{print $1/2.54}')
#   PS_HEIGHT_IN=$(echo $PS_DIM | gawk  '{print $2/2.54}')
#
#   # Place the graphic onto the legend PS file, appropriately shifted. Then shift up.
#   # If we run past the width of the map, then we shift all the way left; otherwise we shift right.
#   # (The typewriter approach)
#
#   gmt psimage -Dx"${LEG2_X}i/${LEG2_Y}i"+w${PS_WIDTH_IN}i srcmod.eps $RJOK ${VERBOSE} >> $LEGMAP
#   LEG2_Y=$(echo "$LEG2_Y + $PS_HEIGHT_IN + 0.02" | bc -l)
#   count=$count+1
#   NEXTX=$(echo $PS_WIDTH_IN $NEXTX | gawk  '{if ($1>$2) { print $1 } else { print $2 } }')
#   # cleanup srcmod.ps srcmod.eps
# }

# function tectoplot_post_srcmod() {
#   echo "none"
# }

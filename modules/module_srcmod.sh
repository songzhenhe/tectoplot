
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
  SLIPMINIMUM=1                # SRCMOD minimum slip that is colored (m)
  SLIPMAXIMUM=25               # SRCMOD maximum slip that is colored (m)
  SLIPCONTOURINTERVAL=2        # SRCMOD contour interval (m)

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

    -s|--srcmod) # args: none
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-s:            plot earthquake slip data from SRCMOD
-s [[arguments]]

  arguments:
  update        Try to update SRCMOD catalog of events
  all           Plot all events within AOI
  nogrid        Only plot slip contours
  *             Any other strings are used to filter events based on ID info

  This function has not been tested in a loooooong time!

Example: None
--------------------------------------------------------------------------------
EOF
  fi

    shift

    updatesrcmod=0

    while ! arg_is_flag $1; do
      case $1 in
        update)
          updatesrcmod=1
          shift
          ((tectoplot_module_shift++))
          ;;
        all)
          allsrcmod=1
          shift
          ((tectoplot_module_shift++))
          ;;
        nogrid)
          shift
          ((tectoplot_module_shift++))
          SRCMOD_NOGRID=1
          ;;
        *)
          # Assume this is a grep target
          srcmodgrep+=("$1")
          shift
          ((tectoplot_module_shift++))
          ;;
        esac
    done

		info_msg "[-s]: Plotting SRCMOD fused slip data"
		plots+=("srcmod")
    cpts+=("srcmod")
    echo $SRCMOD_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $SRCMOD_SOURCESTRING >> ${LONGSOURCES}

    tectoplot_module_caught=1
    ;;

  esac
}

# We download the relevant data in the _calculate_ function as this is the first time we should
# be accessing the data itself.

function tectoplot_calculate_srcmod()  {

  # SRCMOD updates with a new ZIP file name every time.... yaaay

  if [[ $updatesrcmod -eq 1 ]]; then

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
  touch $FAULTSLIP_CPT
  FAULTSLIP_CPT=$(abs_path $FAULTSLIP_CPT)
  gmt makecpt -Chot -I -Do -T0/$SLIPMAXIMUM/0.1 -N $VERBOSE > $FAULTSLIP_CPT
}

function tectoplot_plot_srcmod() {

  case $1 in
  srcmod)

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
        if (test_lon(minlon, maxlon, $1) && ($2 < maxlat-1) && ($2 > minlat+1)) {
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
      if [[ $allsrcmod -eq 1 ]]; then
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

      # echo "array is ${responsearr[@]}"
      for thiseq in ${responsearr[@]}; do
        grep "^[^%;]" "$SRCMODFSPFOLDER"${v[$thiseq]} | gawk  '{print $2, $1, $6}' > temp1.xyz
        gmt blockmean temp1.xyz -I"$LONKM"k $VERBOSE -R > temp.xyz
        gmt triangulate temp.xyz -I"$LONKM"k -Gtemp2.nc -R $VERBOSE
        gmt surface temp.xyz -I"$LONKM"k -Ll0 -Gtemp.nc -R $VERBOSE
        gmt grdmath $VERBOSE temp2.nc $SLIPMINIMUM LE 1 NAN = mask.grd
        gmt grdmath $VERBOSE temp.nc mask.grd OR = slipfinal.grd
        if [[ $SRCMOD_NOGRID -eq 0 ]]; then
          gmt grdimage slipfinal.grd -R$MINLON/$MAXLON/$MINLAT/$MAXLAT -C$FAULTSLIP_CPT -t${SRCMOD_TRANS} -Q -J -O -K $VERBOSE >> map.ps
        fi
        gmt grdcontour slipfinal.grd -A5 -S3 -C$SLIPCONTOURINTERVAL $RJOK $VERBOSE >> map.ps
      done

      # Leftovers from the old 'fused' style
      # if [[ -e slip2.nc ]]; then
      #   gmt grdmath $VERBOSE slip.nc $SLIPMINIMUM GT slip.nc MUL = slipfinal.grd
      #   gmt grdmath $VERBOSE slip.nc $SLIPMINIMUM LE 1 NAN = mask.grd
      #   #This takes the logical grid file from the previous step (mask.grd)
      #   #and replaces all of the 1s with the original conductivities from interpolated.grd
      #   gmt grdmath $VERBOSE slip.nc mask.grd OR = slipfinal.grd
      #   gmt grdimage slipfinal.grd -R$MINLON/$MAXLON/$MINLAT/$MAXLAT -C$FAULTSLIP_CPT -t40 -Q -J -O -K $VERBOSE >> map.ps
      #   gmt grdcontour slipfinal.grd -C$SLIPCONTOURINTERVAL $RJOK $VERBOSE >> map.ps
      # fi
      #
      # gmt grdmath $VERBOSE temp.nc ISNAN 0 temp.nc IFELSE = slip2.nc
      # gmt grdmath $VERBOSE slip2.nc slip.nc MAX = slip3.nc
      # mv slip3.nc slip.nc

    fi
    tectoplot_plot_caught=1
    ;;
  esac

}

function tectoplot_legendbar_srcmod() {
  case $1 in
    srcmod)
      echo "G 0.2i" >> legendbars.txt
      echo "B $FAULTSLIP_CPT 0.2i 0.1i+malu -Bxa5f1+l\"Slip (m)\"" >> legendbars.txt
      barplotcount=$barplotcount+1
      tectoplot_caught_legendbar=1
    ;;
  esac
}

# function tectoplot_legend_srcmod() {
#   # Create a new blank map with the same -R -J as our main map
#   gmt psxy -T -X0i -Yc $OVERLAY $VERBOSE -K ${RJSTRING[@]} > srcmod.ps
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

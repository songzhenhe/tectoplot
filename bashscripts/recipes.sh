## RECIPES

while [[ $# -gt 0 ]]
do
  key="${1}"
  case ${key} in

  -recenteq) # -recenteq: plot earthquakes that occurred recently
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-recenteq:     plot earthquakes that occurred recently
Usage: -recenteq      [[number_of_days=${LASTDAYNUM}]] [[print]]

  Sets options -a a -z -c -time date1 date2 where date1 is number_of_days ago
  and date2 is current date and time (both in UTC).
  Specification of -r is required, or the default region will be used.

Example: Plot last 1 month of earthquakes in USA
tectoplot -r US -t 01d -recenteq 31 -o example_recenteq
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  if arg_is_flag $2; then
    info_msg "[-recenteq]: No day number specified, using last 7 days"
  else
    info_msg "[-recenteq]: Using start of day ${2} days ago to end of today"
    LASTDAYNUM="${2}"
    shift
  fi

  # Turn on time select
  timeselectflag=1
  STARTTIME=$(date_shift_utc -${LASTDAYNUM} 0 0 0)
  ENDTIME=$(date_shift_utc)    # COMPATIBILITY ISSUE WITH GNU date
  shift
  set --  "-a" "a" "-z" "-c" "-time" "${STARTTIME}" "${ENDTIME}" "$@"
  break
  ;;

  -latesteqs)
  LATESTEQSORTTYPE="mag"
  if arg_is_flag $2; then
    info_msg "[-latesteqs]: No day number specified, using last 7 days"
  else
    info_msg "[-latesteqs]: Using start of day ${2} days ago to end of today"
    LASTDAYNUM="${2}"
    shift
  fi
  if arg_is_flag $2; then
    info_msg "[-latesteqs]: No sort type specified. Using ${LATESTEQSORTTYPE}"
  else
    if [[ $2 =~ "date" || $2 =~ "mag" ]]; then
      LATESTEQSORTTYPE="${2}"
    fi
    shift
  fi

  timeselectflag=1
  recenteqprintandexitflag=1
  STARTTIME=$(date_shift_utc -${LASTDAYNUM} 0 0 0)
  ENDTIME=$(date_shift_utc)    # COMPATIBILITY ISSUE WITH GNU date
  shift
  set --  "-r" "g" "-z" "-time" "${STARTTIME}" "${ENDTIME}" "$@"
  break
  ;;

  -seismo)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-seismo:       plot a basic seismotectonic map
Usage: -seismo

  Plot a basic seismotectonic map for a region using default options
  Sets options -t -b c -z -c
  Specification of -r is required, or the default region will be used.

Example: Plot a seismotectonic map of Iran
tectoplot -r IR -seismo -o example_seismo
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    shift
    set --  "-t" "-b" "-z" "-c" "$@"
    break
    ;;

  -topo)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-topo:        plot a basic topographic map
Usage: -topo
  Plot a basic topographic map for a region and make an oblique view
  Sets options -t -ob 45 20 3
  Specification of -r is required, or the default region will be used.
  The oblique view PDF is stored in \${TMP}/oblique.pdf and script to adjust
  is in \${TMP}/make_oblique.sh [vexag] [az] [inc]

Example: Plot a topographic map
tectoplot -topo -o example_topo
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    shift
    set --  "-t" "-t0" "-ob" "45" "20" "3" "$@"
    break
    ;;

    -topoprof)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-topoprof:     plot -t0 topo with a single topo profile, with scale and inset
Usage: -topoprof [aprofcodes] [[scalelength]]

Example: Plot a topographic map of Ryukyu
tectoplot -r CH -topoprof
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  aprofcode=$2
  shift

  if ! arg_is_flag $2; then
    scalelen="length $2"
    shift
  else
    scalelen=""
  fi

  shift
  set --  "-t" "-t0" "-tr" "-scale" ${scalelen} "inlegend" "horz" "-aprof" "${aprofcode}" "50k" "1k" "-inset" "topo" "size" "1.5i" "onmap" "BL" "-legend" "onmap" "TL" "-showprof" "all" "-RJ" "B" "-rect" "$@"
  ;;

    -tgl) # -tgl: recipe for slopeshade terrain visualization
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tgl:          recipe for blue ocean and white land shaded relief
Usage: -tgl

  Plot topography using a white color stretch for land

Example: Slopeshade map
tectoplot -t -t0 -o example_t0
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    topoctrlstring="msg"
    useowntopoctrlflag=1
    fasttopoflag=0
    SLOPE_FACT=0.5
    HS_GAMMA=1.4
    HS_ALT=45
    shift

    set --  "-tmult" "-tsl" "-tcpt" "grayland" -tca "0.3" "$@"
    break
    ;;

  -sunlit)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-sunlit:       plot topo with unidirectional hillshade and cast shadows
Usage: -sunlit

  Plot a basic topographic map for a region with cast shadows, and oblique view
  Sets options -t -tuni -tshad -ob 45 20 3
  Specification of -r is required, or the default region will be used.
  The oblique view PDF is stored in \${TMP}/oblique.pdf and script to adjust
  is in \${TMP}/make_oblique.sh [vexag] [az] [inc]

Example: Plot a topographic map of Switzerland with cast shadows
tectoplot -r CH -sunlit -o example_sunlit
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    shift
    set --  "-t" "-tuni" "-tshad" "-ob" "45" "20" "3" "$@"
    break
    ;;

-veryclosereport)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-closereport:       create a very local report map for a given earthquake
Usage: -veryclosereport [earthquake_id]
--------------------------------------------------------------------------------
EOF
shift && continue
fi
      EQID=$2
      shift
      start_time="1970-01-01"
      end_time=$(date -u +"%Y-%m-%d")
      if ! arg_is_flag $2; then
        start_time=$2
        shift
      fi
      if ! arg_is_flag $2; then
        end_time=$2
        shift
      fi
      SENTINEL_TYPE="s2cloudless-2019"
      SENTINEL_FACT=0.5

      touch ./sentinel_img.jpg
      sentineldownloadflag=1

      set --  "-timeme" "-r" "eq" "${EQID}" "5k" "-RJ" "UTM" "-rect" \
            "-t" "-t0" "-timg" "img" "sentinel_img.jpg" "0.3" \
            "-ob" \
            "-z" "1" "50" "-zmag" "2" "-zline" "0" "-zcat" "ANSS" "ISC" "GHEC" "-ztarget" "${EQID}" "-zcsort" "mag" "down" \
            "-legend" "onmap" "BR" "BL" "horiz" "bars" \
            "-inset" "country" "offmap" "RT" "degw" "5" "size" "2.5i" "args" "\"-z -zcat ${F_SEIS}eqs_highlight.txt -zhigh ${EQID} \"" \
            "-aosm" "fixdem" "color" "black" "width" "0.25p"  \
            "-pp" "label" "1" "fill" "black" "font" "10p,Helvetica-Bold,black" \
            "-scale" "inlegend" "horz" "length" "2k" "divs" "4" "skiplabel" "5" "height" "20" \
            "-zbox" "${EQID}" "-zhigh" "${EQID}" \
            "-preview" "300" \
            "-tpct" "1" "99"
      break
;;

-closereport)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-closereport:       create a local report map for a given earthquake
Usage: -closereport [earthquake_id]
--------------------------------------------------------------------------------
EOF
shift && continue
fi
      EQID=$2
      shift
      start_time="1970-01-01"
      end_time=$(date -u +"%Y-%m-%d")
      if ! arg_is_flag $2; then
        start_time=$2
        shift
      fi
      if ! arg_is_flag $2; then
        end_time=$2
        shift
      fi
      SENTINEL_TYPE="s2cloudless-2019"
      SENTINEL_FACT=0.5

      touch ./sentinel_img.jpg
      sentineldownloadflag=1

      set --  "-timeme" "-r" "eq" "${EQID}" "50k" "-RJ" "UTM" "-rect" \
            "-t" "-t0" "-timg" "img" "sentinel_img.jpg" "0.3" \
            "-ob" \
            "-z" "1" "50" "-zmag" "2" "-zline" "0" "-zcat" "ANSS" "ISC" "GHEC" "-ztarget" "${EQID}" "-zcsort" "mag" "down" \
            "-legend" "onmap" "BR" "BL" "horiz" "bars" \
            "-inset" "country" "offmap" "RT" "degw" "20" "size" "2.5i" "args" "\"-z -zcat ${F_SEIS}eqs_highlight.txt -zhigh ${EQID} \"" \
            "-aosm" "fixdem" "color" "black" "width" "0.25p"  \
            "-pp" "label" "1" "fill" "black" "font" "10p,Helvetica-Bold,black" \
            "-scale" "inlegend" "horz" "length" "20k" "divs" "4" "skiplabel" "5" "height" "20" \
            "-zbox" "${EQID}" "-zhigh" "${EQID}" \
            "-preview" "300" \
            "-arrow" "wide" \
            "-tpct" "1" "99"
      break
;;

-report)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-report:       create a report map for a given earthquake
Usage: -report [earthquake_id]
--------------------------------------------------------------------------------
EOF
shift && continue
fi
      EQID=$2
      shift
      start_time="1970-01-01"
      end_time=$(date -u +"%Y-%m-%d")
      if ! arg_is_flag $2; then
        start_time=$2
        shift
      fi
      if ! arg_is_flag $2; then
        end_time=$2
        shift
      fi

      set --  "-timeme" "-r" "eq" "${EQID}" "750k" "-RJ" "UTM" "-rect" \
            "-t" "GEBCO20" "-t0" \
            "-acb" "line" "0.5p,white" "trans" "30" \
            "-b" \
            "-af" \
            "-p" "MORVEL" "-pf" "300" "-i" "2" \
            "-z" "1" "50" "-zmag" "3.5" "-zline" "0" "-zcat" "ANSS" "ISC" "GHEC" "-ztarget" "${EQID}" "-zcsort" "mag" "down" \
            "-seistimeline_c" "${start_time}" "today" "4" \
            "-seistimeline_eq" "${EQID}" "30" \
            "-noframe" "right" \
            "-legend" "onmap" "BR" "BL" "horiz" "bars" \
            "-inset" "country" "offmap" "BR" "xoff" "9.5" "yoff" "-1" "degw" "90" "size" "2.7i" "args" "\"-z -zcat ${F_SEIS}eqs_highlight.txt -zhigh ${EQID} \"" \
            "-pe" \
            "-pa" "notext" \
            "-aosm" "fixdem" "color" "white" "width" "0.25p"  \
            "-pl" "13p,Bookman-Demi,black" "full" \
            "-pp" "min" "100000" "bin" "4" "label" "1" "fill" "white" "stroke" "0.25p,black" "outline" "white" "lang" "en" "only" \
            "-scale" "inlegend" "horz" "length" "250k" "divs" "5" "skiplabel" "75" "height" "20" \
            "-zbox" "${EQID}" "-zhigh" "${EQID}" \
            "-cprof" "eq" "eq" "slab2" "1000" "2k" "-pw" "50k" "-oto" "change_h" "-proftopo" "-profdepth" "-350" "10" "-showprof" "all" \
            "-preview" "300" \
            "-arrow" "wide" \
            "-watermark" "Earthquake Insights 2023" \
            "-tpct" "1" "99"

            # "-author" "Figure by Earthquake Insights" "font" "10p,Helvetica-Bold,black" "date" \

            # "-tcycle" "num" "10"
            # "-time" "eq" "${EQID}" "30" \
      break
    ;;

  -eventmap)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-eventmap:     plot an earthquake summary map using a USGS event code
Usage: -eventmap [earthquakeID] [[degrees]] [[options]]

  degrees is the width/height of the map centered on the event

  options:
  deg [degrees]      define width/height of AOI
  mmi                plot colored contours of MMI using the USGS color scheme
  topo [dataset]     plot topography; dataset is argument to -t

  Plot a basic seismotectonic map and cross section centered on an earthquake
  Includes topography, Slab2.0, seismicity, focal mechanisms (ORIGIN location).
  Labels the selected earthquake on map and cross-section.
  Plots a 1:1 (V=H) E-W profile, or orients the profile along the dip-direction
  if a Slab2.0 grid exists beneath the event.
  Plots a legend and sets the title to the earthquake ID.

Example: Plot a seismotectonic map of the M7.8 2015 Gorkha, Nepal earthquake
tectoplot -eventmap us20002926 -o example_eventmap
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if arg_is_flag $2; then
      info_msg "[-eventmap]: Needs earthquakeID"
      exit 1
    else
      EVENTMAP_ID=$(eq_event_parse "${2}")
      shift
    fi
    EVENTMAP_DEGBUF=2
    EVENTMAP_TOPO="SRTM30"
    shift
    while ! arg_is_flag $1; do
      case $1 in
        deg)
          shift
          if arg_is_positive_float $1; then
            EVENTMAP_DEGBUF="${1}"
            shift
          else
            echo "[-eventmap]: deg option requires positive float argument"
            exit 1
          fi
          ;;
        topo)
          shift
          if ! arg_is_flag $1; then
            EVENTMAP_TOPO="${1}"
            shift
          else
            echo "[-eventmap]: topo option requires topo datset argument"
          fi
          ;;
        mmi)
          EVENTMAP_MMI=("-mmi", ${EVENTMAP_ID})
          shift
          ;;
        *)
          echo "[-eventmap]: unrecognized option ${2}"
          exit 1
        ;;
      esac
    done

    set -- "-r" "eq" "usgs" ${EVENTMAP_DEGBUF} "-usgs" "${EVENTMAP_ID}"  "-t" "${EVENTMAP_TOPO}" "-t0" "-b" ${EVENTMAP_APROF[@]} "-z" "-zcat" "usgs" "ANSS" "ISC" "-zcrescale" "2"  "-c" "-ccat" "usgs" "GCMT" ${EVENTMAP_MMI[@]} "-eqlist" "{" "${EVENTMAP_ID}" "}" "-eqlabel" "list" "datemag" "-legend" "onmap" "-inset" "topo" "1i" "45" "0.1i" "0.1i" "-oto" "change_h" "$@"
    # echo $@
    break
    ;;
  esac
  shift
done

echo out args are $@
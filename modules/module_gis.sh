
# Commands for plotting GIS datasets like points, lines, and grids
# To add: polygons

# Register the module with tectoplot
TECTOPLOT_MODULES+=("gis")

function tectoplot_defaults_gis() {

  #############################################################################
  ### GIS point options
  POINTSYMBOL="c"
  # POINTCOLOR="black"
  POINTSIZE="0.02i"
  POINTLINECOLOR="black"
  POINTLINEWIDTH="0.5p"
  POINTCPT=$CPTDIR"defaultpt.cpt"

  #############################################################################
  ### GIS line options
  USERLINECOLOR=black           # GIS line data file, line color
  USERLINEWIDTH="0.5p"          # GIS line data file, line width
  GIS_LINEEND_STYLE=butt

  #############################################################################
  ### Contoured grid options
  CONTOURNUMDEF=20             # Number of contours to plot
  GRIDCONTOURWIDTH=0.1p
  GRIDCONTOURCOLOUR="black"
  GRIDCONTOURFONT="5p,Helvetica,black"
  GRIDCONTOURSMOOTH=100
  GRIDCONTOURLABELS="on"
  GRIDCONTOURLABELSSKIPINT=1   # Plot only every nth label
  gridcontourusecptflag=0

  GRIDCONTOURMAJORSPACE=5
  GRIDCONTOURSPACE=""

  GRIDCONTOURMINORWIDTH=0.1
  GRIDCONTOURMAJORWIDTH=0.25
  GRIDCONTOURMINORCOLOR="black"
  GRIDCONTOURMAJORCOLOR="black"



  current_userlinefilenumber=1
  current_usersymbollinefilenumber=1
  current_userpointfilenumber=1
  cugfn=1
  cugcn=1
  current_smallcirclenumber=1

  ugfn=0
  userlinefilenumber=0
  userpointfilenumber=0
  userpolyfilenumber=0
  smallcnumber=0
  greatcnumber=0

  #############################################################################
  ### Small circle options

  SMALLCWIDTH_DEF="1p"
  SMALLCCOLOR_DEF="black"

}

#############################################################################
### Argument processing function defines the flag (-example) and parses arguments

function tectoplot_args_gis()  {
  # The following lines are required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -cn)
  GRIDCONTOURINT=100
  GRIDCONTOURSMOOTH=3

if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-cn:           plot contours of a grid
-cn [gridfile] [[options]] [[ { GMT GRID COMMANDS } ]]

  Options:

  int [number]          Contour interval
  cpt [cptID]           CPT to color contours
  inv                   Invert the sign of the data (positive <> negative)

  Contour a grid using GMT format options.

  Can be called multiple times.

Example:
   None yet
--------------------------------------------------------------------------------
EOF
fi
    shift

    if [[ $cnfirst -ne 1 ]]; then
      ugcn=0
      cnfirst=1
    fi

    if arg_is_flag $1; then
      info_msg "[-cn]: Grid file not specified"
      exit 1
    else
      ugcn=$(echo "${ugcn} + 1" | bc)

      CONTOURGRID[$ugcn]=$(abs_path $1)
      shift
      ((tectoplot_module_shift++))
    fi

    GRIDCONTOUR_MINDIST[$ugcn]=""

    while ! arg_is_flag $1; do
      case $1 in
        len)
          shift
          ((tectoplot_module_shift++))
          if ! arg_is_flag $1; then
            GRIDCONTOUR_MINDIST[$ugcn]="-Q${1}"
            shift
            ((tectoplot_module_shift++))
          else
            echo "[-cn]: option len requires length/distance argument (e.g. 100k)"
            exit 1
          fi
        ;;
        skip)
          shift
          ((tectoplot_module_shift++))
          GRIDCONTOURLABELSSKIPINT=$1
          shift
          ((tectoplot_module_shift++))
        ;;
        inv)
          shift
          ((tectoplot_module_shift++))
          gridcontourinvertflag[$ugcn]=1
          ;;
        int)
          shift
          ((tectoplot_module_shift++))
          GRIDCONTOURINT[$ugcn]=$1
          shift
          ((tectoplot_module_shift++))
        ;;
        cpt)
          shift
          ((tectoplot_module_shift++))
          GRIDCONTOURCPT[$ugcn]=$1
          gridcontourusecptflag[$ugcn]=1
          shift
          ((tectoplot_module_shift++))
        ;;
        *)
          echo "[-cn]: argument ${1} not recognized"
          exit 1
        ;;
      esac
    done
    # if [[ ${1:0:1} == [{] ]]; then
    #   info_msg "[-cn]: GMT argument string detected"
    #   shift
    #   ((tectoplot_module_shift++))
    #   while : ; do
    #       [[ ${1:0:1} != [}] ]] || break
    #       gridvars+=("${1}")
    #       shift
    #       ((tectoplot_module_shift++))
    #   done
    #   shift
    #   ((tectoplot_module_shift++))
    #   CONTOURGRIDVARS="${gridvars[@]}"
    # fi
    # info_msg "[-cn]: Custom GMT grid contour commands: ${CONTOURGRIDVARS[@]}"
    plots+=("gis_grid_contour")

    tectoplot_module_caught=1
    ;;

  -gr) #      [gridfile] [[cpt]] [[trans%]]
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-gr:           plot grid file
-gr [grid1] [[options]]

  Multiple instances of -gr can be specified and the plotting order versus other
  map layers will be respected.NaN cells are plotted as fully transparent (grdimage -Q)

  This command creates a GeoTiff of the rendered grid with the name grid_N.tif
  where N indicates the Nth grid given - usefult for e.g. -timg img grid_1.tif

  Options:
  cpt [cptid]          select CPT for grid
  log
  noplot               do not actually plot the grid. Useful with tiff option
  trans [percent]      set transparency of plotted grid
  tiff                 make a GeoTiff file called grid_N.tif in the temporary folder

Example:
  tectoplot -t -r BR -gr grid1.grd cpt1.cpt -a -gr grid2.grd cpt2.cpt 50
ExampleEnd
--------------------------------------------------------------------------------
EOF
fi
    shift

    ugfn=$(echo "$ugfn+1" | bc)  # user grid file number
    if arg_is_flag $1; then
      info_msg "[-gr]: Grid file must be specified"
    else
      GRIDADDFILE[$ugfn]=$(abs_path $1)
      if [[ ! -e "${GRIDADDFILE[$ugfn]}" ]]; then
        info_msg "GRID file ${GRIDADDFILE[$ugfn]} does not exist"
      fi
      shift
      ((tectoplot_module_shift++))
    fi

    # Set defaults before reading options
    GRIDADDCPT[$ugfn]="turbo"
    GRIDLOGCPT[$ugfn]=0
    GRIDADDTRANS[$ugfn]=0
    GRIDPLOT[$ugfn]=1
    GRIDTIFF[$ugfn]=0

    while ! arg_is_flag $1; do
      case $1 in
        cpt)
          shift
          ((tectoplot_module_shift++))
          ISGMTCPT="$(is_gmt_cpt $1)"
          if [[ ${ISGMTCPT} -eq 1 ]]; then
            info_msg "[-gr]: Using GMT CPT file ${1}."
            GRIDADDCPT[$ugfn]="${1}"
            gmt grd2cpt ${GRIDADDFILE[$ugfn]} -C${1} -Z > ${TMP}${F_CPTS}gis_grid_${ugfn}.cpt
            GRIDADDCPT[$ugfn]=${TMP}${F_CPTS}gis_grid_${ugfn}.cpt
          elif [[ -e ${1} ]]; then
            info_msg "[-gr]: Copying user defined CPT ${1}"
            TMPNAME=$(abs_path $1)
            cp $TMPNAME ${TMP}${F_CPTS}
            GRIDADDCPT[$ugfn]="${TMP}${F_CPTS}"$(basename "$1")
          else
            info_msg "CPT file ${1} cannot be found directly. Looking in CPT dir: ${CPTDIR}${2}."
            if [[ -e ${CPTDIR}${1} ]]; then
              cp "${CPTDIR}${1}" ${TMP}${F_CPTS}
              info_msg "Copying CPT file ${CPTDIR}${1} to temporary holding space"
              GRIDADDCPT[$ugfn]="./${F_CPTS}${1}"
            else
              info_msg "Using default CPT (turbo)"
              GRIDADDCPT[$ugfn]="turbo"
            fi
          fi
          shift
          ((tectoplot_module_shift++))

        ;;
        log)
          GRIDLOGCPT[$ugfn]=1
          shift
          ((tectoplot_module_shift++))
        ;;
        noplot)
          shift
          ((tectoplot_module_shift++))
          GRIDPLOT[$ugfn]=0
        ;;
        trans)
          shift
          ((tectoplot_module_shift++))
          if ! arg_is_positive_float $1; then
            info_msg "[-gr]: trans option requires number argument"
            exit 1
          else
            GRIDADDTRANS[$ugfn]="${1}"
            shift
            ((tectoplot_module_shift++))
          fi
        ;;
        tiff)
          shift
          ((tectoplot_module_shift++))
          GRIDTIFF[$ugfn]=1
        ;;
        *)
          echo $1
          exit 1
        ;;
      esac
    done

    GRIDIDCODE[$ugfn]="c"   # custom ID
    addcustomusergridsflag=1

    plots+=("gis_grid")

    # cpts+=("gis_grid")

    tectoplot_module_caught=1

    ;;

  -im) # args: file { arguments }
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-im:           plot a referenced RGB grid file
-im [filename] { GMT OPTIONS }

  gmt options (to psimage) might include { -t50 }

Example: None
--------------------------------------------------------------------------------
EOF
fi
    shift

    if [[ -s $1 ]]; then
      IMAGENAME=$(abs_path $1)
      shift
      ((tectoplot_module_shift++))
    else
      IMAGENAME=${1}
      shift
      ((tectoplot_module_shift++))
    fi

    # Args come in the form $ { -t50 -cX.cpt }
    if [[ ${1:0:1} == [{] ]]; then
      info_msg "[-im]: image argument string detected"
      shift
      ((tectoplot_module_shift++))

      while : ; do
          [[ ${1:0:1} != [}] ]] || break
          imageargs+=("${1}")
          shift
          ((tectoplot_module_shift++))

      done
      shift
      ((tectoplot_module_shift++))

      info_msg "[-im]: Found image args ${imageargs[@]}"
      IMAGEARGS="${imageargs[@]}"
    fi
    plotimageflag=1

    plots+=("gis_image")

    tectoplot_module_caught=1
    ;;

  -lis)
  usersymbollinefilenumber=0
  USERsymbolLINESYMBOL="t"
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-lis:           plot one or more polyline files as ticked faults
-lis [filename] [faulttype] [[linecolor]] [[linewidth]]

--------------------------------------------------------------------------------
EOF
fi
  shift

  echo "a"

  if [[ $1 == *kml ]]; then
    usersymbollinefilenumber=$(echo "$usersymbollinefilenumber + 1" | bc -l)
    kml_to_all_xy ${1} gis_line_${usersymbollinefilenumber}.txt
    ls -l gis_line_${usersymbollinefilenumber}.txt
    USERsymbolLINEDATAFILE[$usersymbollinefilenumber]=$(abs_path gis_line_${usersymbollinefilenumber}.txt)
  else
    usersymbollinefilenumber=$(echo "$usersymbollinefilenumber + 1" | bc -l)
    USERsymbolLINEDATAFILE[$usersymbollinefilenumber]=$(abs_path $1)
  fi

  echo "b"

  shift
  ((tectoplot_module_shift++))

  if [[ ! -e ${USERsymbolLINEDATAFILE[$usersymbollinefilenumber]} ]]; then
    info_msg "[-lis]: User line data file ${USERsymbolLINEDATAFILE[$usersymbollinefilenumber]} does not exist."
    exit 1
  fi

  echo "c"

  if arg_is_flag $1; then
    info_msg "[-lis]: No type specified. Using $USERsymbolLINESYMBOL"
    USERsymbolLINESYMBOL_arr[$usersymbollinefilenumber]=$USERsymbolLINESYMBOL
  else
    USERsymbolLINESYMBOL_arr[$usersymbollinefilenumber]="${1}"
    shift
    ((tectoplot_module_shift++))
    info_msg "[-lis]: User line type specified. Using ${USERsymbolLINECOLOR_arr[$usersymbollinefilenumber]}."
  fi

  plots+=("gis_symbol_line")
  tectoplot_module_caught=1

  ;;

  -li) # args: file color width
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-li:           plot one or more polyline files
-li [filename] [[linecolor]] [[linewidth]]

  Can be called multiple times to plot multiple datasets.
  Currently does not handle complex symbologies (ornamented, CPT, etc.)

Example: Plot a few lines across Romania
  printf ">\n21 44\n26 48\n>\n22 46\n27 45\n" > ./xy.dat
  tectoplot -r RO -t -li xy.dat red 1p
  rm -f ./xy.dat
--------------------------------------------------------------------------------
EOF
fi
    shift
    # Required arguments

    if [[ $1 == *kml ]]; then
      userlinefilenumber=$(echo "$userlinefilenumber + 1" | bc -l)
      kml_to_all_xy ${1} gis_line_${userlinefilenumber}.txt
      ls -l gis_line_${userlinefilenumber}.txt
      USERLINEDATAFILE[$userlinefilenumber]=$(abs_path gis_line_${userlinefilenumber}.txt)
    else
      userlinefilenumber=$(echo "$userlinefilenumber + 1" | bc -l)
      USERLINEDATAFILE[$userlinefilenumber]=$(abs_path $1)
    fi

    shift
    ((tectoplot_module_shift++))

    if [[ ! -e ${USERLINEDATAFILE[$userlinefilenumber]} ]]; then
      info_msg "[-li]: User line data file ${USERLINEDATAFILE[$userlinefilenumber]} does not exist."
      exit 1
    fi
    # Optional arguments
    # Look for symbol code
    if arg_is_flag $1; then
      info_msg "[-li]: No color specified. Using $USERLINECOLOR."
      USERLINECOLOR_arr[$userlinefilenumber]=$USERLINECOLOR
    else
      USERLINECOLOR_arr[$userlinefilenumber]="${1}"
      shift
      ((tectoplot_module_shift++))
      info_msg "[-li]: User line color specified. Using ${USERLINECOLOR_arr[$userlinefilenumber]}."
    fi

    # Then look for width
    if arg_is_flag $1; then
      info_msg "[-li]: No width specified. Using $USERLINEWIDTH."
      USERLINEWIDTH_arr[$userlinefilenumber]=$USERLINEWIDTH
    else
      USERLINEWIDTH_arr[$userlinefilenumber]="${1}"
      shift
      ((tectoplot_module_shift++))

      info_msg "[-li]: Line width specified. Using ${USERLINEWIDTH_arr[$userlinefilenumber]}."
    fi

    if [[ "${1}" == "fill" ]]; then
      info_msg "[-li]: Fillling polygon"
      USERLINEFILL_arr[$userlinefilenumber]="-Gred"
      shift
      ((tectoplot_module_shift++))

    else
      USERLINEFILL_arr[$userlinefilenumber]=""
    fi

    info_msg "[-li]: LINE${userlinefilenumber}: ${USERLINEDATAFILE[$userlinefilenumber]}"

    plots+=("gis_line")
    tectoplot_module_caught=1

  ;;

    -pt)
  if [[ $USAGEFLAG -eq 1 ]]; then
  cat <<-EOF
modules/module_gis.sh
-pt:           plot point dataset with specified size, fill, cpt
-pt [filename] [[symbol=${POINT_SYMBOL}]] [[size=${POINTSIZE}]] [[@ color]]
-pt [filename] [[symbol=${POINT_SYMBOL}]] [[size=${POINTSIZE}]] [[cpt_filename]]

  symbol is a GMT psxy -S code:
    +(plus), st(a)r, (b|B)ar, (c)ircle, (d)iamond, (e)llipse,
 	  (f)ront, octa(g)on, (h)exagon, (i)nvtriangle, (j)rotated rectangle,
 	  pe(n)tagon, (p)oint, (r)ectangle, (R)ounded rectangle, (s)quare,
    (t)riangle, (x)cross, (y)dash,

  Multiple calls to -pt can be made; they will plot in map layer order.

Example: None
--------------------------------------------------------------------------------
EOF

  fi
      shift

      # COUNTER userpointfilenumber
      # Required arguments
      userpointfilenumber=$(echo "$userpointfilenumber + 1" | bc -l)
      POINTDATAFILE[$userpointfilenumber]=$(abs_path $1)
      shift
      ((tectoplot_module_shift++))
      if [[ ! -e ${POINTDATAFILE[$userpointfilenumber]} ]]; then
        info_msg "[-pt]: Point data file ${POINTDATAFILE[$userpointfilenumber]} does not exist."
        exit 1
      fi
      # Optional arguments
      # Look for symbol code
      if arg_is_flag $1; then
        info_msg "[-pt]: No symbol specified. Using $POINTSYMBOL."
        POINTSYMBOL_arr[$userpointfilenumber]=$POINTSYMBOL
      else
        POINTSYMBOL_arr[$userpointfilenumber]="${1:0:1}"
        shift
        ((tectoplot_module_shift++))
        info_msg "[-pt]: Point symbol specified. Using ${POINTSYMBOL_arr[$userpointfilenumber]}."
      fi

      # Then look for size
      if arg_is_flag $1; then
        info_msg "[-pt]: No size specified. Using $POINTSIZE."
        POINTSIZE_arr[$userpointfilenumber]=$POINTSIZE
      else
        POINTSIZE_arr[$userpointfilenumber]="${1}"
        shift
        ((tectoplot_module_shift++))
        info_msg "[-pt]: Point size specified. Using ${POINTSIZE_arr[$userpointfilenumber]}."
      fi
      POINTCOLOR[$userpointfilenumber]="black"

      # Finally, look for CPT file
      if arg_is_flag $1; then
        info_msg "[-pt]: No cpt specified. Using ${POINTCOLOR} fill for -G"
        pointdatafillflag[$userpointfilenumber]=1
        pointdatacptflag[$userpointfilenumber]=0
      elif [[ ${1:0:1} == "@" ]]; then
        shift
        ((tectoplot_module_shift++))
        POINTCOLOR[$userpointfilenumber]=${1}
        info_msg "[-pt]: No cpt specified using @. Using POINTCOLOR for -G"
        shift
        ((tectoplot_module_shift++))
        pointdatafillflag[$userpointfilenumber]=1
        pointdatacptflag[$userpointfilenumber]=0
      else
        POINTDATACPT[$userpointfilenumber]=$(abs_path $1)
        shift
        ((tectoplot_module_shift++))
        if [[ ! -e ${POINTDATACPT[$userpointfilenumber]} ]]; then
          info_msg "[-pt]: CPT file $POINTDATACPT does not exist. Using default $POINTCPT"
          POINTDATACPT[$userpointfilenumber]=$(abs_path $POINTCPT)
        else
          info_msg "[-pt]: Using CPT file $POINTDATACPT"
        fi
        pointdatacptflag[$userpointfilenumber]=1
        pointdatafillflag[$userpointfilenumber]=0
      fi

      info_msg "[-pt]: PT${userpointfilenumber}: ${POINTDATAFILE[$userpointfilenumber]}"
      plots+=("gis_point")

      tectoplot_module_caught=1
    ;;

    # Plot small circle with given angular radius, color, linewidth
    -smallc)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
modules/module_gis.sh
-smallc:       plot small circle centered on a geographic point
-smallc [lon] [lat] [radius] [[argid arg]] ...

  argid:
  color     Color of small circle line
  pole      Activate plotting of pole location as point
  stroke    Pen width (e.g. 1p)
  dash      Activate dashed line style

  Multiple calls to -smallc can be made; they will plot in map layer order.

Example: None
--------------------------------------------------------------------------------
EOF
  fi
      shift


      smallcnumber=$(echo "$smallcnumber + 1" | bc -l)
      smallcirclekmflag=0

      if arg_is_float $1; then
        SMALLCLON[$smallcnumber]=$1
        shift
        ((tectoplot_module_shift++))
      fi

      if arg_is_float $1; then
        SMALLCLAT[$smallcnumber]=$1
        shift
        ((tectoplot_module_shift++))
      fi

      if arg_is_float $1; then
        SMALLCDEG[$smallcnumber]=$1
        shift
        ((tectoplot_module_shift++))
      elif ! arg_is_flag $1; then

        # If argument is not a pure number, assume it is a kilometer value and convert to appropriate degree value
        # We use GMT project to find the interior angle corresponding to projecting east at the equator
        # This will technically be incorrect
        smallcirclekmflag=1
        SMALLCKM[$smallcnumber]=$1
        SMALLCDEG[$smallcnumber]=$(gmt project -C0/0 -A90 -Q -G${1}k -L0/${1} | gawk '(NR==2){print $1}')
        shift
        ((tectoplot_module_shift++))
      fi

      SMALLCPOLE[$smallcnumber]=0
      SMALLCDASH[$smallcnumber]=""

      while ! arg_is_flag $1; do
        case $1 in
          dash)
            SMALLCDASH[$smallcnumber]=",-"
            ;;
          pole)
            SMALLCPOLE[$smallcnumber]="1"
            ;;
          color)
            shift
            ((tectoplot_module_shift++))
            if ! arg_is_flag $1; then
              SMALLCCOLOR[$smallcnumber]="${1}"
            else
              SMALLCCOLOR[$smallcnumber]=${SMALLCCOLOR_DEF}
            fi
            ;;
          stroke)
            shift
            ((tectoplot_module_shift++))
            if ! arg_is_flag $1; then
              SMALLCWIDTH[$smallcnumber]="${1}"
            else
              SMALLCWIDTH[$smallcnumber]=${SMALLCWIDTH_DEF}
            fi
            ;;
          label)
            SMALLC_PLOTLABEL[$smallcnumber]=1
            if [[ $smallcirclekmflag -eq 1 ]]; then
              SMALLCLABEL[$smallcnumber]="${SMALLCKM[$smallcnumber]} km"
            else
              SMALLCLABEL[$smallcnumber]="${SMALLCDEG[$smallcnumber]} deg"
            fi
            ;;
        esac
        shift
        ((tectoplot_module_shift++))
      done

      info_msg "[-smallc]: Small circle defined: ${SMALLCLON[$smallcnumber]} ${SMALLCLAT[$smallcnumber]} ${SMALLCWIDTH[$smallcnumber]} ${SMALLCCOLOR[$smallcnumber]} ${SMALLCDASH[$smallcnumber]}"

      plots+=("gis_small_circle")
      tectoplot_module_caught=1
    ;;

    # Plot small circle with given angular radius, color, linewidth
    -greatc)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
modules/module_gis.sh
-greatc:       plot great circles passing through points with given azimuths
-greatc [[files ...]] [lon1] [lat1] [azimuth1] [[lon2]] [[lat2]] [[azimuth2]] ..

  If files are specified, read them in first. Format: lon(°) lat(°) azimuth(°)

Example: None
--------------------------------------------------------------------------------
EOF
  fi
      shift
      greatcnumber=0
      # Check if there is an input file
      while [[ -s "${1}" ]]; do
        greatcfile="${1}"
        shift
        ((tectoplot_module_shift++))
        #
        while read p; do
          ((greatcnumber++))
          d=($(echo $p))
          GREATCLON[$greatcnumber]=${d[0]}
          GREATCLAT[$greatcnumber]=${d[1]}
          GREATCAZ[$greatcnumber]=${d[2]}
        done < $greatcfile
      done
      while ! arg_is_flag $1; do
        ((greatcnumber++))

        if arg_is_float $1; then
          GREATCLON[$greatcnumber]=$1
          shift
          ((tectoplot_module_shift++))
        fi

        if arg_is_float $1; then
          GREATCLAT[$greatcnumber]=$1
          shift
          ((tectoplot_module_shift++))
        fi

        if arg_is_float $1; then
          GREATCAZ[$greatcnumber]=$1
          shift
          ((tectoplot_module_shift++))
        fi
      done

      if [[ ${greatcnumber} -gt 0 ]]; then
        info_msg "[-greatc]: ${greatcnumber} great circles defined"
        plots+=("gis_great_circle")
      else
        echo "[-greatc]: No circles defined"
      fi

      tectoplot_module_caught=1
    ;;



  esac
}

# function tectoplot_calculate_gis()  {
# }

# function tectoplot_cpt_gis() {
# }

function tectoplot_plot_gis() {

  case $1 in

  gis_grid)
    # Each time gis_grid is called, plot the grid and increment to the next
    info_msg "Plotting user grid $cugfn: ${GRIDADDFILE[$cugfn]} with CPT ${GRIDADDCPT[$cugfn]}"

    if [[ ${GRIDLOGCPT[$cugfn]} -eq 1 ]]; then
      LOGFLAG="-Q"
    else
      LOGFLAG=""
    fi


    if [[ ${GRIDTIFF[$cugfn]} -eq 1 ]]; then
      gmt_init_tmpdir
        gmt grdimage ${GRIDADDFILE[$cugfn]} -Q ${LOGFLAG} -C${GRIDADDCPT[$cugfn]} $GRID_PRINT_RES -t${GRIDADDTRANS[$cugfn]} -JX5i -Agrid_${cugfn}.tif
      gmt_remove_tmpdir
    fi

    if [[ ${GRIDPLOT[$cugfn]} -eq 1 ]]; then
      gmt grdimage ${GRIDADDFILE[$cugfn]} -Q ${LOGFLAG} -C${GRIDADDCPT[$cugfn]} $GRID_PRINT_RES -t${GRIDADDTRANS[$cugfn]} $RJOK ${VERBOSE} >> map.ps
    fi

    cugfn=$(echo "$cugfn + 1" | bc -l)

    tectoplot_plot_caught=1
    ;;

  gis_grid_contour)
    # Exclude options that are contained in the ${CONTOURGRIDVARS[@]} array

    AFLAG=-A${GRIDCONTOURINT[${cugcn}]}
    CFLAG=-C${GRIDCONTOURINT[$cugcn]}
    [[ ! -z ${GRIDCONTOURSMOOTH[$cugcn]} ]] && SFLAG=-S${GRIDCONTOURSMOOTH[$cugcn]} || SFLAG=""

    # for i in ${CONTOURGRIDVARS[@]}; do
    #   if [[ ${i:0:2} =~ "-A" ]]; then
    #     AFLAG=""
    #   fi
    #   if [[ ${i:0:2} =~ "-C" ]]; then
    #     CFLAG=""
    #   fi
    #   if [[ ${i:0:2} =~ "-S" ]]; then
    #     SFLAG=""
    #   fi
    # done

    # Currently we run this strange program but only use the contour intervals that
    # come out. This could be further modified to plot major/minor contours.

    zrange=($(grid_zrange ${CONTOURGRID[$cugcn]} -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} -fg))

    gawk -v minz=${zrange[0]} -v maxz=${zrange[1]} -v cint=${GRIDCONTOURINT[$cugcn]} -v majorspace=${GRIDCONTOURMAJORSPACE} -v minwidth=${GRIDCONTOURMINORWIDTH} -v maxwidth=${GRIDCONTOURMAJORWIDTH} -v mincolor=${GRIDCONTOURMINORCOLOR} -v maxcolor=${GRIDCONTOURMAJORCOLOR} '
      BEGIN {
        # If the range straddles 0, ensure 0 is a major contour
        if (minz<0 && maxz>0) {
          ismaj=0

          print 0, "A", maxwidth "p," maxcolor
          for(i=0-cint; i>=minz; i-=cint) {
            if (++ismaj == majorspace) {
              print i, "A", maxwidth "p," maxcolor
              ismaj=0
            } else {
              print i, "c", minwidth "p," mincolor
            }
          }
          ismaj=0
          for(i=cint; i<=maxz; i+=cint) {
            if (++ismaj == majorspace) {
              print i, "A", maxwidth "p," maxcolor
              ismaj=0
            } else {
              print i, "c", minwidth "p," mincolor
            }
          }
        } else {
        # If the range does not straddle 0, just make contours
          ismaj=1
          minz=minz-minz%cint
          for(i=minz; i<maxz; i+=cint) {
            if (++ismaj == majorspace) {
              print i, "A", maxwidth "p," maxcolor
              ismaj=0
            } else {
              print i, "c", minwidth "p," mincolor
            }
          }
        }
      }' > grid.contourdef

    gawk < grid.contourdef '{print $1}' | tr '\n' ',' | gawk '{print substr($0, 1, length($0)-1)}' > grid_clevels.txt

    echo     gmt grdcontour ${CONTOURGRID[$cugcn]} $AFLAG $SFLAG ${GRIDCONTOUR_MINDIST[$cugcn]} -C$(cat grid_clevels.txt) ${RJSTRING[@]} -Dgrid_contours.txt

    gmt grdcontour ${CONTOURGRID[$cugcn]} $AFLAG $SFLAG ${GRIDCONTOUR_MINDIST[$cugcn]} -C$(cat grid_clevels.txt) ${RJSTRING[@]} -Dgrid_contours.txt

    gawk < grid_contours.txt -v skipint=${GRIDCONTOURLABELSSKIPINT} -v inv=${gridcontourinvertflag[$cugcn]} '
    BEGIN {
      gotline=0
      thisskip=1
    }
    {
      if (substr($4,1,2) == "-Z") {
        thisnum=substr($4,3,length($4)-2)
        if (skipint == 0) {
          if (thisnum % skipint == 0) {
            if (inv==1) {
              $4=sprintf("-L%s -Z%s", 0-thisnum, 0-thisnum)
            } else {
              $4=sprintf("-L%s -Z%s", thisnum, thisnum)
            }
          } else {
            $4=""
          }
        } else {
          if (inv==1) {
            $4=sprintf("-L%s -Z%s", 0-thisnum, 0-thisnum)
          } else {
            $4=sprintf("-L%s -Z%s", thisnum, thisnum)
          }
        }
        print $1, $4
      } else {
        print
      }
    }' > grid_replaced.txt


    # gmt psxy grid_replaced.txt -W0.2p,black ${RJOK} ${VERBOSE} >> map.ps

    if [[ ${gridcontourusecptflag[$cugcn]} -eq 1 ]]; then
      gmt psxy grid_replaced.txt -Sqn1:+f${GRIDCONTOURFONT}+Lh+i+e --FONT_ANNOT_PRIMARY="4p,Helvetica,black" -C${GRIDCONTOURCPT[$cugcn]} ${RJOK} >> map.ps
      gmt psxy grid_replaced.txt -W+z -C${GRIDCONTOURCPT[$cugcn]} ${RJOK} >> map.ps
    else
      gmt psxy grid_replaced.txt -Sqn1:+f${GRIDCONTOURFONT}+Lh+i+e --FONT_ANNOT_PRIMARY="4p,Helvetica,black" ${RJOK} >> map.ps
      gmt psxy grid_replaced.txt -W+z ${RJOK} >> map.ps
    fi
    gmt psclip -C ${RJOK} >> map.ps
    # gmt grdcontour $CONTOURGRID $AFLAG $CFLAG $SFLAG -W$GRIDCONTOURWIDTH,$GRIDCONTOURCOLOUR ${CONTOURGRIDVARS[@]} $RJOK ${VERBOSE} >> map.ps

    cugcn=$(echo "$cugcn + 1" | bc -l)

    tectoplot_plot_caught=1
  ;;

  gis_point)
    info_msg "Plotting point dataset $current_userpointfilenumber: ${POINTDATAFILE[$current_userpointfilenumber]}"
    if [[ ${pointdatacptflag[$current_userpointfilenumber]} -eq 1 ]]; then
      gmt psxy ${POINTDATAFILE[$current_userpointfilenumber]} -W$POINTLINEWIDTH,$POINTLINECOLOR -C${POINTDATACPT[$current_userpointfilenumber]} -G+z -S${POINTSYMBOL_arr[$current_userpointfilenumber]}${POINTSIZE_arr[$current_userpointfilenumber]} $RJOK $VERBOSE >> map.ps
    else
      gmt psxy ${POINTDATAFILE[$current_userpointfilenumber]} -G${POINTCOLOR[$current_userpointfilenumber]} -W$POINTLINEWIDTH,$POINTLINECOLOR -S${POINTSYMBOL_arr[$current_userpointfilenumber]}${POINTSIZE_arr[$current_userpointfilenumber]} $RJOK $VERBOSE >> map.ps
    fi
    current_userpointfilenumber=$(echo "$current_userpointfilenumber + 1" | bc -l)
    tectoplot_plot_caught=1
  ;;

  gis_line)  # Should we use -A or not? Unclear!!!
    info_msg "Plotting line dataset $current_userlinefilenumber"
    gmt psxy ${USERLINEDATAFILE[$current_userlinefilenumber]} ${USERLINEFILL_arr[$current_userlinefilenumber]} -W${USERLINEWIDTH_arr[$current_userlinefilenumber]},${USERLINECOLOR_arr[$current_userlinefilenumber]} --PS_LINE_CAP=${GIS_LINEEND_STYLE} $RJOK $VERBOSE >> map.ps
    current_userlinefilenumber=$(echo "$current_userlinefilenumber + 1" | bc -l)
    tectoplot_plot_caught=1
  ;;


#Front: -Sf<spacing>[/<ticklen>][+r|l][+f|t|s|c|b|v][+o<offset>][+p<pen>]
       # If <spacing> is negative it means the number of gaps instead. If <spacing> has a leading + then <spacing> is used exactly [adjusted to fit line length]. If not given, <ticklen> defaults to 15% of <spacing>. Append
       # various modifiers:
       # +l Plot symbol to the left of the front [centered].
       # +r Plot symbol to the right of the front [centered].
       # +i Make main front line invisible [drawn using pen settings from -W].
       # +b Plot square when centered, half-square otherwise.
       # +c Plot full circle when centered, half-circle otherwise.
       # +f Plot centered cross-tick or tick only in specified direction [Default].
       # +s Plot left-or right-lateral strike-slip arrows. Optionally append the arrow angle [20].
       # +S Same as +s but with curved arrow-heads.
       # +t Plot diagonal square when centered, directed triangle otherwise.
       # +o Plot first symbol when along-front distance is <offset> [0].
       # +p Append <pen> for front symbol outline; if no <pen> then no outline [Outline with -W pen].
       # +v Plot two inverted triangles, directed inverted triangle otherwise.
       # Only one of +b|c|f|i|s|S|t|v may be selected.
  gis_symbol_line)
    info_msg "Plotting line dataset $current_usersymbollinefilenumber"
    gmt psxy -Sf1c/3p+l+${USERsymbolLINESYMBOL_arr[$current_usersymbollinefilenumber]} ${USERsymbolLINEDATAFILE[$current_usersymbollinefilenumber]} -W1p,black -Gblack $RJOK $VERBOSE >> map.ps
    current_usersymbollinefilenumber=$(echo "$current_usersymbollinefilenumber + 1" | bc -l)
    tectoplot_plot_caught=1
  ;;

  gis_image)
    # echo gmt grdimage ${IMAGEARGS[@]}  ${IMAGENAME} -Q ${RJSTRING[@]} -O -K $VERBOSE
    gmt grdimage ${IMAGENAME} ${IMAGEARGS[@]} -Q ${RJSTRING[@]} -O -K $VERBOSE >> map.ps
    tectoplot_plot_caught=1
  ;;

  gis_great_circle)

    for this_gc in $(seq 1 $greatcnumber); do
      gmt project -C${GREATCLON[$this_gc]}/${GREATCLAT[$this_gc]} -A${GREATCAZ[$this_gc]} -G0.5 -L-360/0 > great_circle_${this_gc}.txt
      gmt psxy great_circle_${this_gc}.txt -W1p,black $RJOK $VERBOSE >> map.ps
      echo "${GREATCLON[$this_gc]} ${GREATCLAT[$this_gc]}" | gmt psxy -Sc3p -Gblack ${RJOK} ${VERBOSE} >> map.ps
      newlon=$(echo "${GREATCLON[$this_gc]} + 180" | bc -l)
      newlat=$(echo "0 - ${GREATCLAT[$this_gc]}" | bc -l)
      echo "$newlon $newlat" | gmt psxy -Sc3p -Gblack ${RJOK} ${VERBOSE} >> map.ps

    done
  ;;

  gis_small_circle)
    info_msg "Creating small circle ${current_smallcirclenumber}"

    # Somehow, lon=38 lat=32 FAILS but lon=38 lat=32.0001 doesn't (GMT 6.1.1) ?????
    polelat=${SMALLCLAT[$current_smallcirclenumber]}
    polelon=${SMALLCLON[$current_smallcirclenumber]}

    poleantilat=$(echo "0 - (${polelat}+0.0000001)" | bc -l)
    poleantilon=$(echo "${polelon}" | gawk  '{if ($1 < 0) { print $1+180 } else { print $1-180 } }')

    gmt_init_tmpdir
      gmt project -T${polelon}/${polelat} -C${poleantilon}/${poleantilat} -G0.5/${SMALLCDEG[$current_smallcirclenumber]} -L-360/0 $VERBOSE | gawk '{print $1, $2}' > ${F_MAPELEMENTS}smallcircle_${current_smallcirclenumber}.txt
    gmt_remove_tmpdir


    # SMALLC_PLOTLABEL[$smallcnumber]=1
    # if [[ $smallcirclekmflag -eq 1 ]]; then
    #   SMALLCLABEL[$smallcnumber]="${SMALLCDEG[$smallcnumber]} km"
    # else
    #   SMALLCLABEL[$smallcnumber]="${SMALLCDEG[$smallcnumber]} deg"

    if [[ ${SMALLC_PLOTLABEL[$current_smallcirclenumber]} -eq 1 ]]; then
      gmt psxy ${F_MAPELEMENTS}smallcircle_${current_smallcirclenumber}.txt -Sqn1:+f8p,Helvetica,${SMALLCCOLOR[$current_smallcirclenumber]}+l"${SMALLCLABEL[$current_smallcirclenumber]}"+v -W${SMALLCWIDTH[$current_smallcirclenumber]},${SMALLCCOLOR[$current_smallcirclenumber]}${SMALLCDASH[$current_smallcirclenumber]} $RJOK $VERBOSE >> map.ps
    else
      gmt psxy ${F_MAPELEMENTS}smallcircle_${current_smallcirclenumber}.txt -W${SMALLCWIDTH[$current_smallcirclenumber]},${SMALLCCOLOR[$current_smallcirclenumber]}${SMALLCDASH[$current_smallcirclenumber]} $RJOK $VERBOSE >> map.ps
    fi

    if [[ ${SMALLCPOLE[$current_smallcirclenumber]} -eq 1 ]]; then
      echo "$polelon $polelat" | gmt psxy -Sc0.1i -G${SMALLCCOLOR[$current_smallcirclenumber]} $RJOK $VERBOSE >> map.ps
    fi

    current_smallcirclenumber=$(echo "$current_smallcirclenumber + 1" | bc -l)
    tectoplot_plot_caught=1
  ;;
  esac

}

# function tectoplot_legend_gis() {
# }

function tectoplot_legendbar_gis() {
  case $1 in
    gis_grid)
      echo "G 0.2i" >> ${LEGENDDIR}legendbars.txt
      echo "B ${GRIDADDCPT[$cugfn]} 0.2i ${LEGEND_BAR_HEIGHT}+malu ${LEGENDBAR_OPTS} -Bxaf+l\"$(basename ${GRIDADDFILE[$cugfn]})\"" >> ${LEGENDDIR}legendbars.txt
      barplotcount=$barplotcount+1
      cugfn=$(echo "$cugfn + 1" | bc -l)
      tectoplot_caught_legendbar=1
      ;;
  esac
}

# function tectoplot_post_gis() {
# }

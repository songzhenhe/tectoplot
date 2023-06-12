TECTOPLOT_MODULES+=("mapopts")

# Map options
# Set up map, determine map parameters, etc.


# Global variables that this module expects to be correctly set:
# PROJDIM[0-3]
# MINLON, MAXLON, MINLAT, MAXLAT

# Global variables that this module can set/modify:
# MAPMARGIN
# ARROWFMT
# KEEPOPEN, keepopenflag
# GRID_PRINT_RES (-Edpi)
# GRIDCALL      (-Bxxxx)
# CLEANUP_FILES (0=off)
# noplotflag (1=do not plot)
#  OUTPUTDIRECTORY, outputdirflag, MAPOUT, outflag
#  openflag (1=open map, 0=do not)
#  openallflag=0
# GRIDCALL (definition of map frame eg -Btlbr)

# function tectoplot_defaults_mapopts() {
# }

function tectoplot_args_mapopts()  {
  # The following lines are required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

    -whichutm)  
  tectoplot_get_opts_inline '
des -whichutm report UTM zone for map region or specified longitude, then exit
opn lon m_mapopts_whichutm_lon float 9999
  longitude of interest
mes If the lon option is not specified, attempt to use the active map region
' "${@}" || return

    if [[ ${m_mapopts_whichutm_lon} -eq 9999 ]]; then
      if arg_is_float ${MINLON} && arg_is_float ${MAXLON}; then
        whichutm_thislon=$(echo "(${MAXLON} + ${MINLON}) / 2" | bc -l)
      else
        echo "[-whichutm]: specify region using -r or give longitude argument"
        exit 1
      fi
    else
      whichutm_thislon=${m_mapopts_whichutm_lon}
    fi

    AVELONp180o6=$(echo "(($whichutm_thislon) + 180)/6" | bc -l)
    UTMZONE=$(echo $AVELONp180o6 1 | gawk  '{val=int($1)+($1>int($1)); print (val>0)?val:1}')

    echo "UTM Zone for longitude ${whichutm_thislon}: ${UTMZONE}"

    unset AVELONp180o6  
    
    exit 0

    tectoplot_module_caught=1
    ;;
  
    -bigbar)
  tectoplot_get_opts_inline '
des -bigbar plot a single large colorbar beneath the map
ren m_mapopts_bigbar_cpt cpt 
    CPT file or CPT name
ren m_mapopts_bigbar_min float
    Minimum value for colorbar range
ren m_mapopts_bigbar_max float
    Maximum value for colorbar range
ren m_mapopts_bigbar_anno string 
    Annotation string for colorbar
opn width m_mapopts_bigbar_width word "map"
    Width of color bar; default is same width as map
' "${@}" || return

    plots+=("m_mapopts_bigbar")
    ;;
  
    -margin)
  tectoplot_get_opts_inline '
des -margin set the width of the blank margin surrounding the map 
ren m_mapopts_margin word
    margin width, with unit (e.g. 0.5i)
' "${@}" || return

    MAPMARGIN=${m_mapopts_margin}
  ;;

    -arrow)
  tectoplot_get_opts_inline '
des -arrow change the width of arrow vectors 
ren m_mapopts_arrow word
    arrow format: narrower | narrow | normal | wide | wider
exa tectoplot -a -g2 ref PA -arrow wide -o arrow
' "${@}" || return

    case ${m_mapopts_arrow} in
        narrower) ARROWFMT="0.01/0.14/0.06" ;;
        narrow)   ARROWFMT="0.02/0.14/0.06" ;;
        normal)   ARROWFMT="0.06/0.12/0.06" ;;
        wide)     ARROWFMT="0.08/0.14/0.1"  ;;
        wider)    ARROWFMT="0.1/0.3/0.2"    ;;
        *)
            echo "[-arrow]: option $m_mapopts_arrow not recognized; choose from narrower|narrow|normal|wide|wider"
            exit 1
        ;;
    esac
  ;;


  -i) # args: number
    tectoplot_get_opts_inline '
des -i rescale all velocity vectors (GPS, plate motion, etc.)
ren m_mapopts_i_val float
    rescaling factor (positive float)
' "${@}" || return

    if arg_is_positive_float ${m_mapopts_i_val}; then 
      VELSCALE=$(echo "${m_mapopts_i_val} * $VELSCALE" | bc -l)
    else 
      echo "[-i]: argument was not a positive float"
      exit 1
    fi
    ;;


  -watermark)
  tectoplot_get_opts_inline '
des -watermark place a semi-transparent watermark on map
ren m_mapopts_watermark_str string
    watermark text
exa tectoplot -t -watermark Map Watermark
' "${@}" || return

    plots+=("m_mapopts_watermark")
    ;;

  -author)
  tectoplot_get_opts_inline '
des -author place author information / timestamp near the map
ren m_mapopts_author_str string 
    text string containing author information
opn date m_mapopts_author_time flag 0
    add a date-time string to the author information
opn font m_mapopts_author_font font "12p,Helvetica,black"
    define the font used for author info
opn shiftx m_mapopts_author_shiftx float 0
    shift reference point in the X direction (units are inches)
opn shifty m_mapopts_author_shifty float 0 
    shift reference point in the Y direction (units are inches)
' "${@}" || return

    plots+=("m_mapopts_author")
    ;;

  -exec)
  tectoplot_get_opts_inline '
des -exec run a bash script with any number of non-quoted arguments
ren m_mapopts_execute_script file
    path of bash script to execute
opn args m_mapopts_execute_args list 
    arguments 
mes Execute a script via bash sourcing (. script.sh). The script will run in the
mes current tectoplot environment and will have access to all variables/data.
mes Following arguments are passed to the script as arguments. Please be careful 
mes about running scripts in this fashion. This function can be called multiple
mes times.
' "${@}" || return

    plots+=("m_mapopts_execute")
    ;;

  -pagegrid)
  tectoplot_get_opts_inline '
des -pagegrid plot an inch- or cm-spaced grid 
opn unit m_mapopts_pagegrid_unit word "i" 
    select i for inches, c for cm
' "${@}" || return

    plots+=("m_mapopts_pagegrid")
    ;;

  -navticks)
  tectoplot_get_opts_inline '
des -navticks plot navigation ticks on the map
' "${@}" || return

  plots+=("m_mapopts_navticks")

  ;;

  -gmtvars)
  tectoplot_get_opts_inline '
des -gmtvars set internal gmt variable
req m_mapopts_gmtvars_str string ""
    sequence of GMT variable names and values e.g. MAP_ANNOT_OFFSET_PRIMARY 4p MAP_FRAME_TYPE fancy
mes Note that GMT variables are updated at time of plotting and that multiple calls to -gmtvars
mes can be used to change GMT variables during plotting.
' "${@}" || return
    plots+=("m_mapopts_gmtvars")
    ;;

  -gridlabels) 
 tectoplot_get_opts_inline '
des -gridlabels specify how map axes are presented and labeled
ren m_mapopts_gridlabels_str string ""
    GMT format command string
mes This option is used to set map axis labeling. Lower case
mes letters indicate no labelling, upper case letters indicate labeling.
mes b/S: bottom unlabeled / bottom labeled
mes l/W: left unlabeled / left labeled
mes t/N: top unlabeled / top labeled
mes r/E: right unlabeled / right labeled
' "${@}" || return

    if [[ ! -z "${m_mapopts_gridlabels_str}" ]]; then
        GRIDCALL="${m_mapopts_gridlabels_str}"
    fi
    ;;

  -gres)
 tectoplot_get_opts_inline '
des -gres specify dpi of most grid plotting options
ren m_mapopts_gres_dpi float ""
    grid resolution (integer, dpi)
mes GMT plots grids at their native resolution, creating very large files in some
mes cases. Use this option to set the dpi of plotted grids. Resampling is done at
mes the plotting step.
mes Note: Does not affect many grids currently! 
' "${@}" || return

    if arg_is_positive_float ${m_mapopts_gres_dpi}; then
        GRID_PRINT_RES="-E${m_mapopts_gres_dpi}"
    else
        GRID_PRINT_RES=""
    fi
    ;;

  -keepopenps) 
   tectoplot_get_opts_inline '
des -keepopenps keep map Postscript file open for subsequent overplotting
' "${@}" || return

    keepopenflag=1
    KEEPOPEN="-K"
    ;;

  -megadebug)
  tectoplot_get_opts_inline '
des -megadebug prints all processes and script commands with line/time stamps
mes To save an exhaustive log to the file out.txt:
mes   tectoplot [options] -megadebug > out.txt 2>&1
' "${@}" || return

    set -x
    ;;

  -nocleanup)
  tectoplot_get_opts_inline '
des -nocleanup keep many intermediate files generated during tectoplot run
mes tectoplot usually deletes various intermediate files; this option keep them.
' "${@}" || return

    CLEANUP_FILES=0
    ;;


  -noplot)
  tectoplot_get_opts_inline '
des -noplot do not plot anything - exit after initial data management
mes NOTE: CURRENTLY NOT ACTIVE AS AN OPTION (DOES NOTHING)
' "${@}" || return

    noplotflag=1
    ;;

	-o)
    tectoplot_get_opts_inline '
des -o specify basename of output pdf
ren m_mapopts_o_file string
  file name without .pdf extension
opn m_mapopts_o_dir string ""
  output directory name
' "${@}" || return

    if [[ ! -z "${m_mapopts_o_file}" ]]; then
		  MAPOUT="${m_mapopts_o_file}"
      outflag=1
      info_msg "[-o]: Output file is ${MAPOUT}"
		else
      echo "[-o]: output PDF base name not specified"
      exit 1
    fi

    if [[ ! -z "${m_mapopts_o_dir}" ]]; then
      if [[ -d "${m_mapopts_o_dir}" ]]; then
        outputdirflag=1
        OUTPUTDIRECTORY=$(abs_path "${m_mapopts_o_dir}")
      else
        echo "[-o]: output directory ${m_mapopts_o_dir} does not exist"
        exit 1
      fi
	else
      OUTPUTDIRECTORY=""
    fi
  ;;

    -maponly)
    tectoplot_get_opts_inline '
des -maponly only open map PDF at end of processing, not all created PDFs
' "${@}" || return

    openflag=1
    openallflag=0
  ;;

  -noopen)
  tectoplot_get_opts_inline '
des -noopen do not open any PDFs at end of processing
' "${@}" || return

    openflag=0
    openallflag=0
    ;;

  -whiteframe)
  tectoplot_get_opts_inline '
des -whiteframe plot a thick colored map frame below all map layers
opn color m_mapopts_whiteframe_color word "white"
    color of the background map frame
opn width m_mapopts_whiteframe_width word "10p"
    width of the background map frame
' "${@}" || return

    WHITEFRAME_WIDTH=${m_mapopts_whiteframe_width}
    WHITEFRAME_COLOR=${m_mapopts_whiteframe_color}
    whiteframeflag=1
  ;;

  -noframe) 
  tectoplot_get_opts_inline '
des -noframe do not plot coordinate grid or map frame, as specified
opn top m_mapopts_noframe_top flag 0
    do not plot top border
opn bottom m_mapopts_noframe_bottom flag 0
    do not plot bottom border
opn left m_mapopts_noframe_left flag 0
    do not plot left border
opn right m_mapopts_noframe_right flag 0
    do not plot right border
' "${@}" || return

    GRIDCALL="NESW"

    echo right is ${m_mapopts_noframe_right}
    if [[ ${m_mapopts_noframe_top} -eq 0 && ${m_mapopts_noframe_bottom} -eq 0 && ${m_mapopts_noframe_left} -eq 0 && ${m_mapopts_noframe_right} -eq 0 ]]; then
      echo hhd
      GRIDCALL="blrt"
      dontplotgridflag=1
    else
      [[ ${m_mapopts_noframe_top} -eq 1 ]]    && GRIDCALL=$(echo $GRIDCALL | tr 'N' 't')
      [[ ${m_mapopts_noframe_bottom} -eq 1 ]] && GRIDCALL=$(echo $GRIDCALL | tr 'S' 'b')
      [[ ${m_mapopts_noframe_left} -eq 1 ]]   && GRIDCALL=$(echo $GRIDCALL | tr 'W' 'l')
      [[ ${m_mapopts_noframe_right} -eq 1 ]]  && GRIDCALL=$(echo $GRIDCALL | tr 'E' 'r')
    fi
    ;;

    -title) 
    tectoplot_get_opts_inline '
des -title set and display plot title
ren m_mapopts_title_str string
    map title string
opn font m_mapopts_title_font string "20p,Helvetica,black"
    map title font
' "${@}" || return
    plots+=("m_mapopts_maptitle")
    ;;

  -cutframe) # -cutframe: plot a frame element to facilitate cutting
    tectoplot_get_opts_inline '
des -cutframe plot an offset frame element to facilitate layering  
opn offset m_mapopts_cutframe_distance float 2
    separation of cutframe from map frame, inches
mes Places an unadorned rectangular frame around the map beyond the label extent
mes in order to allow uniform cropping of the page to make superimposition of
mes layers in PDF format easier.
' "${@}" || return

    plots+=("m_mapopts_cutframe")
    ;;

  esac
}

# tectoplot_cpts_mapopts() {
#
# }

# function tectoplot_calculate_mapopts()  {
# }

# function tectoplot_cpt_mapopts() {
# }

function tectoplot_plot_mapopts() {
  case $1 in
    m_mapopts_bigbar)
        if [[ ${m_mapopts_bigbar_width} == "map" ]]; then
            m_mapopts_bigbar_width=${PSSIZE}i
        fi
        gmt psscale -DJCB+w${m_mapopts_bigbar_width}+o0/1c+h+e -C${m_mapopts_bigbar_cpt} -Bxaf+l"${m_mapopts_bigbar_anno}" -G${m_mapopts_bigbar_min}/${m_mapopts_bigbar_max} $RJOK ${VERBOSE} >> map.ps
        tectoplot_plot_caught=1
    ;;
    m_mapopts_watermark)
        echo "H 14p,Helvetica-Bold,white ${m_mapopts_watermark_str}" | gmt pslegend -DjTR+w$(echo "$MAP_PS_WIDTH_IN / 2" | bc -l)i+jTR -t20 $RJOK $VERBOSE >> map.ps
        tectoplot_plot_caught=1
    ;;
    m_mapopts_author)

        if [[ ${m_mapopts_author_time} -eq 1 ]]; then
            echo "T ${m_mapopts_author_str} | $(date -u)" >> author.txt
        else
            echo "T ${m_mapopts_author_str}" >> author.txt
        fi
        AUTHOR_W=$(echo "$MAP_PS_WIDTH_IN * 8 / 10" | bc -l)
        gmt pslegend author.txt -Dx0/0+w$(echo "$MAP_PS_WIDTH_IN * 8 / 10" | bc -l)i+jTL+l1.1 $RJOK $VERBOSE -Xa${m_mapopts_author_shiftx}i -Ya${m_mapopts_author_shifty}i --FONT_ANNOT_PRIMARY=${m_mapopts_author_font} >> map.ps
        gmt psxy -T -Y${OFFSETV}i $RJOK $VERBOSE >> map.ps

        tectoplot_plot_caught=1
    ;;
    m_mapopts_execute)
        info_msg "Executing script $m_mapopts_execute_script with arguments ${m_mapopts_execute_args}. Be Careful!"
        source "${m_mapopts_execute_script}" ${m_mapopts_execute_args}
        tectoplot_plot_caught=1
    ;;
    m_mapopts_pagegrid)
        case ${m_mapopts_pagegrid_unit} in
          i)
            PAGE_GRID_XSIZE=$(echo ${PROJDIM[0]} | gawk '
              @include "tectoplot_functions.awk"
              {
                print ru($1/2.54+1,1)
              }')
            PAGE_GRID_YSIZE=$(echo ${PROJDIM[1]} | gawk '
              @include "tectoplot_functions.awk"
              {
                print ru($1/2.54+1,1)
              }')
            PAGE_GRID_XSIZE_P2=$(echo ${PROJDIM[0]} | gawk '
              @include "tectoplot_functions.awk"
              {
                print ru(($1)/2.54+1,1)
              }')
            PAGE_GRID_YSIZE_P2=$(echo ${PROJDIM[1]} | gawk '
              @include "tectoplot_functions.awk"
              {
                print ru(($1)/2.54+1,1)
              }')
          ;;
          c)
            PAGE_GRID_XSIZE=$(echo ${PROJDIM[0]} | gawk '
              @include "tectoplot_functions.awk"
              {
                print ru($1+1,1)
              }')
            PAGE_GRID_YSIZE=$(echo ${PROJDIM[1]} | gawk '
              @include "tectoplot_functions.awk"
              {
                print ru($1+1,1)
              }')
            PAGE_GRID_XSIZE_P2=$(echo ${PROJDIM[0]} | gawk '
              @include "tectoplot_functions.awk"
              {
                print ru($1+1,1)
              }')
            PAGE_GRID_YSIZE_P2=$(echo ${PROJDIM[1]} | gawk '
              @include "tectoplot_functions.awk"
              {
                print ru($1+1,1)
              }') 
            ;;
          esac

  # Plot -1 X and -i Y
          gmt_init_tmpdir

          gmt psbasemap -R0/1/0/1 -JX0${m_mapopts_pagegrid_unit}/${PAGE_GRID_YSIZE_P2}${m_mapopts_pagegrid_unit} -Xa-1${m_mapopts_pagegrid_unit} -Ya-1${m_mapopts_pagegrid_unit} -Br  -O -K --MAP_FRAME_PEN=0.1p,gray,4_8 >> map.ps

          gmt psbasemap -R0/1/0/1 -JX${PAGE_GRID_XSIZE_P2}${m_mapopts_pagegrid_unit}/0${m_mapopts_pagegrid_unit} -Ya-1${m_mapopts_pagegrid_unit} -Xa-1${m_mapopts_pagegrid_unit} -Bt  -O -K --MAP_FRAME_PEN=0.1p,gray,4_8 >> map.ps

          pagegrid_ind=0
          while [[ $(echo "$pagegrid_ind <= $PAGE_GRID_XSIZE_P2" | bc) -eq 1 ]]; do
            textoff=$(echo "$pagegrid_ind - 1" | bc )
            echo "0 0 ${textoff}${m_mapopts_pagegrid_unit}" | gmt pstext -R0/1/0/1 -C0.1+t -F+f10p,Helvetica,gray+jLB -JX${pagegrid_ind}${m_mapopts_pagegrid_unit}/${PAGE_GRID_YSIZE_P2}${m_mapopts_pagegrid_unit} -Xa${textoff}${m_mapopts_pagegrid_unit} -Ya-1${m_mapopts_pagegrid_unit} $VERBOSE -O -K >> map.ps

            gmt psbasemap -R0/1/0/1 -JX${pagegrid_ind}${m_mapopts_pagegrid_unit}/${PAGE_GRID_YSIZE_P2}${m_mapopts_pagegrid_unit} -Xa-1${m_mapopts_pagegrid_unit} -Ya-1${m_mapopts_pagegrid_unit} -Br  -O -K --MAP_FRAME_PEN=0.1p,gray,4_8_5_8 >> map.ps
            ((pagegrid_ind++))
          done

          pagegrid_ind=0
          while [[ $(echo "$pagegrid_ind < $PAGE_GRID_YSIZE_P2" | bc) -eq 1 ]]; do
            textoff=$(echo "$pagegrid_ind - 1" | bc )

            echo "0 0 ${textoff}${m_mapopts_pagegrid_unit}" | gmt pstext -R0/1/0/1 -C0.1+t -F+f10p,Helvetica,gray+jLB -JX${pagegrid_ind}${m_mapopts_pagegrid_unit}/${PAGE_GRID_YSIZE_P2}${m_mapopts_pagegrid_unit} -Xa-1${m_mapopts_pagegrid_unit} -Ya${textoff}${m_mapopts_pagegrid_unit} $VERBOSE -O -K >> map.ps

            gmt psbasemap -R0/1/0/1 -JX${PAGE_GRID_XSIZE_P2}${m_mapopts_pagegrid_unit}/${pagegrid_ind}${m_mapopts_pagegrid_unit} -Xa-1${m_mapopts_pagegrid_unit} -Bt  -O -K --MAP_FRAME_PEN=0.1p,gray,4_8_5_8 >> map.ps
            ((pagegrid_ind++))
          done
          gmt_remove_tmpdir
        tectoplot_plot_caught=1
    ;;  
    m_mapopts_gmtvars)
        gmt gmtset ${m_mapopts_gmtvars_str[$tt]}
        tectoplot_plot_caught=1
    ;;
    m_mapopts_navticks)
        gmt psbasemap -Bg ${RJOK} >> map.ps
        gmt psbasemap -Bsg5d -Bpg1d --MAP_GRID_CROSS_SIZE_PRIMARY=-3p --MAP_GRID_CROSS_SIZE_SECONDARY=+5p --MAP_GRID_PEN_PRIMARY=default,blue --MAP_GRID_PEN_SECONDARY=default,red ${RJOK} >> map.ps
    ;;
    m_mapopts_maptitle)
        gmt psbasemap "-B+t${m_mapopts_title_str}" --FONT_TITLE=${m_mapopts_title_font} $RJOK $VERBOSE >> map.ps
    ;;
    m_mapopts_cutframe)

        MINPROJ_X=$(echo "(0 - ${m_mapopts_cutframe_distance})" | bc -l)
        MAXPROJ_X=$(echo "(${PROJDIM[0]}/2.54 + 2*${m_mapopts_cutframe_distance})" | bc -l)
        MINPROJ_Y=$(echo "(0 - ${m_mapopts_cutframe_distance})" | bc -l)
        MAXPROJ_Y=$(echo "(${PROJDIM[1]}/2.53 + 2*${m_mapopts_cutframe_distance})" | bc -l)

        gmt_init_tmpdir

        gmt psbasemap -R0/${MAXPROJ_X}/0/${MAXPROJ_Y} -JX${MAXPROJ_X}i/${MAXPROJ_Y}i -Xa-${m_mapopts_cutframe_distance}i -Ya-${m_mapopts_cutframe_distance}i  -Bltrb -O -K --MAP_FRAME_PEN=0.1p,black >> map.ps

        gmt_remove_tmpdir
    ;;
  esac
}

# function tectoplot_legend_mapopts() {
# }

# function tectoplot_legendbar_mapopts() {
#   case $1 in
#     mapopts)
#       barplotcount=$barplotcount+1
#       tectoplot_caught_legendbar=1
#     ;;
#   esac
# }

# function tectoplot_post_mapopts() {
#   echo "none"
# }


# Commands for plotting GIS datasets like points, lines, and grids

# module_gis has been fully updated to utilize tectoplot_get_opts


# Register the module with tectoplot
TECTOPLOT_MODULES+=("gis")

function tectoplot_defaults_gis() {

  #############################################################################
  ### GIS line options
  GIS_LINEEND_STYLE=butt

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
    cat <<-EOF > cn
des -cn Plot contours of gridded dataset
req module_gis_cn_file file
    input grid file
opt list module_gis_cn_levels floatlist ""
    list of contour levels
opt skip module_gis_cn_skipint posint 1
    interval skipping factor
opt space module_gis_cn_space posint 5
    interval of major contours
opt inv module_gis_cn_inv flag 0
    invert the contour interval?
opt int module_gis_cn_int float 100
    contour interval
opt cpt module_gis_cn_cpt cpt ""
    color lines according to CPT
opt sep module_gis_cn_mindist string 0.5i
    minimum distance between labels
opt smooth module_gis_cn_smooth float 3
    smoothing factor
opt fontsize module_gis_cn_fontsize float 4
    font size for contour labels
opt fontcolor module_gis_cn_fontcolor string "black"
    font color for contour labels
opt index module_gis_cn_index float 0
    specified contour level is a major contour
opt minsize module_gis_cn_minsize string ""
    specify minimum number of points (e.g. 500) or length (e.g. 10k)
opt major module_gis_cn_major_app string "1p,black"
    appearance of major contours
opt minor module_gis_cn_minor_app string "0.5p,black"
    appearance of minor contours
opt trans module_gis_cn_trans float 0
    transparency of all contours
mes -cn can be called multiple times with different grid files and options
exa tectoplot -t -cn topo/dem.tif int 1000
EOF

    if [[ $USAGEFLAG -eq 1 ]]; then
      tectoplot_usage_opts cn
    else
      shift
      tectoplot_get_opts cn "${@}"

      plots+=("module_gis_cn")

      tectoplot_module_caught=1
    fi

  ;;

  -gr)
  cat <<-EOF > gr
des -gr Plot a grid (raster) datafile
req module_gis_gr_file file
    input grid file
opt cpt module_gis_gr_cpt cpt turbo
    specify CPT name or file path
opt stretch module_gis_gr_stretch flag 0
    stretch the CPT to the input values
opt log module_gis_gr_logflag flag 0
    specify that CPT is log
opt noplot module_gis_gr_noplot flag 0
    do not plot the grid
opt trans module_gis_gr_trans posint 0
    set grid transparency
opt tiff module_gis_gr_tiff flag 0
    output TIFF file grid_N.tif in temporary folder
opt code module_gis_gr_code string "c"
    grid ID code
opt list module_gis_gr_list list ""
    test list
mes -gr can be called multiple times with different grid files and options
exa tectoplot -t -ts -gr topo/dem.tif cpt cmocean/topo
EOF

  if [[ $USAGEFLAG -eq 1 ]]; then
    tectoplot_usage_opts gr
  else
    shift
    tectoplot_get_opts gr "${@}"

    plots+=("module_gis_gr")

    tectoplot_module_caught=1
  fi
  ;;

  -im) # args: file { arguments }

  cat <<-EOF > im
des -im Plot a rendered grid image datafile
req module_gis_im_file file
    input grid file
opt args module_gis_im_args list ""
    GMT grdimage arguments
mes -im can be called multiple times with different grid files and options
EOF

  if [[ $USAGEFLAG -eq 1 ]]; then
    tectoplot_usage_opts im
  else
    shift
    tectoplot_get_opts im "${@}"

    plots+=("module_gis_im")

    tectoplot_module_caught=1
  fi
  ;;

  -lis)

  cat <<-EOF > lis
des -lis Plot decorated lines (like ticked faults)
req module_gis_lis_file file
    input line file
opt sym module_gis_lis_symbol string "t"
    line decoration type
opt stroke module_gis_lis_stroke string "1p,black"
    line width and color
mes -lis can be called multiple times with different input files and options
EOF

  if [[ $USAGEFLAG -eq 1 ]]; then
    tectoplot_usage_opts lis
  else
    shift
    tectoplot_get_opts lis "${@}"

    plots+=("module_gis_lis")

    tectoplot_module_caught=1
  fi

  ;;

  -li) # args: file color width
  cat <<-EOF > li
des -li Plot a polyline file
req module_gis_li_file file
    input polyline file
opt stroke module_gis_li_stroke string "1p,black"
    line width and color
opt fill module_gis_li_fill string ""
    polygon fill color (off)
opt cpt module_gs_li_cpt cpt ""
    CPT to color lines by attribute
opt att module_gs_li_att string ""
    attribute to color lines using cpt option
mes -li can be called multiple times with different input files and options
mes att option requires field name in shapefile/OGR_GMT file
mes To fill polygons with CPT values, use cpt [] att [] fill cpt
EOF

  if [[ $USAGEFLAG -eq 1 ]]; then
    tectoplot_usage_opts li
  else
    shift
    tectoplot_get_opts li "${@}"

    plots+=("module_gis_li")

    tectoplot_module_caught=1
  fi

  ;;

  -pt)
  cat <<-EOF > pt
des -pt Plot a point dataset
req module_gis_pt_file file
    input point file
opt sym module_gis_pt_sym string "c"
    point symbol shape
opt size module_gis_pt_size string "0.1i"
    point symbol size
opt fill module_gis_pt_fill string black
    point fill color
opt str module_gis_pt_str string "0.3p,black"
    point stroke width and color
opt cpt module_gis_pt_cpt cpt ""
    cpt to symbolize third column values
mes symbol is a GMT psxy -S code
mes  +(plus), st(a)r, (b|B)ar, (c)ircle, (d)iamond, (e)llipse,
mes	  (f)ront, octa(g)on, (h)exagon, (i)nvtriangle, (j)rotated rectangle,
mes	  pe(n)tagon, (p)oint, (r)ectangle, (R)ounded rectangle, (s)quare,
mes   (t)riangle, (x)cross, (y)dash,
EOF

  if [[ $USAGEFLAG -eq 1 ]]; then
    tectoplot_usage_opts pt
  else
    shift
    tectoplot_get_opts pt "${@}"

    plots+=("module_gis_pt")

    tectoplot_module_caught=1
  fi
  ;;

  # Plot small circle with given angular radius, color, linewidth
  -smallc)
  cat <<-EOF > smallc
des -small Plot small circle around a given pole at given angular distance
req module_gis_smallc_file file
    Input file with fields lon(°) lat(°) dist(°)
opt stroke module_gis_smallc_stroke string "1p,black"
    Width and color of line
opt dash module_gis_smallc_dash flag 0
    Activate dashed line style
opt pole module_gis_smallc_pole flag 0
    Activate plotting of origin location as filled circle
opt list module_gis_smallc_list floatlist ""
    List of small circles in lon lat dist ... format
EOF

  if [[ $USAGEFLAG -eq 1 ]]; then
    tectoplot_usage_opts smallc
  else
    shift
    tectoplot_get_opts smallc "${@}"

    plots+=("module_gis_smallc")

    tectoplot_module_caught=1
  fi
  ;;

  # Plot great circle
  -greatc)
  cat <<-EOF > greatc
des -greatc Plot great circle passing through given point with given azimuth
req module_gis_greatc_file file
    Input point file
opt stroke module_gis_greatc_stroke string "1p,black"
    Width and color of line
opt dash module_gis_greatc_dash flag 0
    Activate dashed line style
opt dot module_gis_greatc_dot flag 0
    Activate plotting of origin location as filled circle
opt label module_gis_greatc_label flag 0
    Activate labelling of great circle
opt list module_gis_greatc_list floatlist ""
    List of great circles in lon lat az ... format
EOF

  if [[ $USAGEFLAG -eq 1 ]]; then
    tectoplot_usage_opts greatc
  else
    shift
    tectoplot_get_opts greatc "${@}"

    plots+=("module_gis_greatc")

    tectoplot_module_caught=1
  fi
  ;;
  esac
}

# function tectoplot_calculate_gis()  {
# }

# function tectoplot_cpt_gis() {
# }

function tectoplot_plot_gis() {

  case $1 in

  module_gis_gr)

    local LOGFLAG=""

    ((module_gis_gr_callnum++))
    tt=${module_gis_gr_callnum}

    # Each time module_gis_gr is called, plot the grid and increment to the next
    info_msg "Plotting user grid $tt: ${module_gis_gr_file[$tt]} with CPT ${module_gis_gr_cpt[$tt]}"

    if [[ ${module_gis_gr_logflag[$tt]} -eq 1 ]]; then
      LOGFLAG="-Q"
    else
      LOGFLAG=""
    fi

    if [[ ${module_gis_gr_stretch[$tt]} -eq 1 ]]; then
      gmt grd2cpt ${module_gis_gr_file[$tt]} -Z -C${module_gis_gr_cpt[$tt]} ${LOGFLAG} > ${F_CPTS}grid_${tt}.cpt
      module_gis_gr_cpt[$tt]=${F_CPTS}grid_${tt}.cpt
    fi

    if [[ ${module_gis_gr_tiff[$tt]} -eq 1 ]]; then
      gmt_init_tmpdir
        gmt grdimage ${module_gis_gr_file[$tt]} -Q -C${module_gis_gr_cpt[$tt]} $GRID_PRINT_RES -t${module_gis_gr_trans[$tt]} -JX5i -Agrid_${tt}.tif
      gmt_remove_tmpdir
    fi

    if [[ ${module_gis_gr_noplot[$tt]} -ne 1 ]]; then
      gmt grdimage ${module_gis_gr_file[$tt]} -Q -C${module_gis_gr_cpt[$tt]} $GRID_PRINT_RES -t${module_gis_gr_trans[$tt]} $RJOK ${VERBOSE} >> map.ps
    fi

    tectoplot_plot_caught=1
    ;;

  module_gis_cn)

    ((module_gis_cn_callnum++))
    tt=$module_gis_cn_callnum

    local AFLAG=-A${module_gis_cn_int[$tt]}
    local CFLAG=-C${module_gis_cn_int[$tt]}

    [[ ! -z ${module_gis_cn_mindist[$tt]} ]] && QFLAG=-Q${module_gis_cn_mindist[$tt]} || QFLAG=""
    [[ ! -z ${module_gis_cn_smooth[$tt]} ]] && SFLAG=-S${module_gis_cn_smooth[$tt]} || SFLAG=""

    # echo AFLAG ${AFLAG} SFLAG ${SFLAG} QFLAG ${QFLAG} CFLAG ${CFLAG}

    # Currently we run this strange program but only use the contour intervals that
    # come out. This could be further modified to plot major/minor contours.

    local module_gis_gcmw=$(echo ${module_gis_cn_major_app[$tt]} | gawk -F, '{print $1}' )
    local module_gis_gcmc=$(echo ${module_gis_cn_major_app[$tt]} | gawk -F, '{print $2}' )

    local module_gis_gciw=$(echo ${module_gis_cn_minor_app[$tt]} | gawk -F, '{print $1}' )
    local module_gis_gcic=$(echo ${module_gis_cn_minor_app[$tt]} | gawk -F, '{print $2}' )

    if [[ ! -z ${module_gis_cn_levels[$tt]} ]]; then
      local levellist=$(echo ${module_gis_cn_levels[$tt]} | tr ' ' ',' > grid_clevels.txt)

    else

      local zrange=($(grid_zrange ${module_gis_cn_file[$tt]} -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} -fg))

      gawk -v minz=${zrange[0]} -v maxz=${zrange[1]} -v cint=${module_gis_cn_int[$tt]} -v majorspace=${module_gis_cn_space[$tt]} \
           -v minwidth=${module_gis_gciw} -v maxwidth=${module_gis_gcmw} -v mincolor=${module_gis_gcic} \
           -v maxcolor=${module_gis_gcmc} -v annotate=0 -v indexval=${module_gis_cn_index[$tt]} '
        BEGIN {
          if (annotate==1) {
            annotateflag="A"
          } else {
            annotateflag="c"
          }

          while (indexval <= maxz) {
            indexval+=majorspace*cint
          }
          while (indexval >= minz) {
            indexval-=majorspace*cint
          }

        # Ensure indexval is a major contour
          ismaj=0

          print indexval, annotateflag, maxwidth "," maxcolor >> "grid.major.contourdef"
          for(i=indexval-cint; i>=minz; i-=cint) {
            if (++ismaj == majorspace) {
              print i, annotateflag, maxwidth "," maxcolor >> "grid.major.contourdef"
              ismaj=0
            } else {
              print i, "c", minwidth "," mincolor >> "grid.minor.contourdef"
            }
          }
          ismaj=0
          for(i=indexval+cint; i<=maxz; i+=cint) {
            if (++ismaj == majorspace) {
              print i, annotateflag, maxwidth "," maxcolor >> "grid.major.contourdef"
              ismaj=0
            } else {
              print i, "c", minwidth "," mincolor >> "grid.minor.contourdef"
            }
          }
        }'
    fi

    if [[ -s grid.major.contourdef ]]; then
       gmt grdcontour ${module_gis_cn_file[$tt]} -Cgrid.major.contourdef -D ${AFLAG} ${SFLAG} ${QFLAG} ${VERBOSE} > majorcontourlines.dat
    fi

    if [[ -s grid.minor.contourdef ]]; then
       gmt grdcontour ${module_gis_cn_file[$tt]} -Cgrid.minor.contourdef -D ${AFLAG} ${SFLAG} ${QFLAG} ${VERBOSE} > minorcontourlines.dat
    fi

    if [[ -s majorcontourlines.dat ]]; then
       # Adobe Illustrator only draws the first 32,000 points in a path for SOME STUPID REASON
       gawk < majorcontourlines.dat -v maxpts=2000 '
       BEGIN {
         curcount=0
         linecount=0
       }
       ($1+0!=$1) {
         header=$0
         curcount=0
         linecount++
       }
       ($1+0==$1) {

         curcount++
         if (curcount==maxpts) {
           print header
           print lastline
           curcount=0
         }
         lastline=$0
       }
       {
         print
       }' > splitmajorcontourlines.dat
    fi

    if [[ -s minorcontourlines.dat ]]; then
       gawk < minorcontourlines.dat -v maxpts=2000 '
       BEGIN {
         curcount=0
         linecount=0
       }
       ($1+0!=$1) {
         header=$0
         curcount=0
         linecount++
       }
       ($1+0==$1) {

         curcount++
         if (curcount==maxpts) {
           print header
           print lastline
           curcount=0
         }
         lastline=$0
       }
       {
         print
       }' > splitminorcontourlines.dat
    fi

    # If we aren't coloring using a CPT, then just plot the contour lines using major/minor symbology

    if [[ -z ${module_gis_cn_cpt[$tt]} ]]; then
      [[ -s splitminorcontourlines.dat ]] && gmt psxy splitminorcontourlines.dat -W${module_gis_gciw},${module_gis_gcic} -t${module_gis_cn_trans[$tt]} ${RJOK} >> map.ps
      [[ -s splitmajorcontourlines.dat ]] && gmt psxy splitmajorcontourlines.dat -Sqn1+r${module_gis_cn_mindist[$tt]}:+f${module_gis_cn_fontsize[$tt]},Helvetica,${module_gis_cn_fontcolor[$tt]}+Lh+e -W${module_gis_gcmw},${module_gis_gcmc} -t${module_gis_cn_trans[$tt]} ${RJOK} >> map.ps
    else

      if [[ -s splitminorcontourlines.dat ]]; then
        gawk < splitminorcontourlines.dat -v skipint=${module_gis_cn_skipint[$tt]} -v inv=${module_gis_cn_inv[$tt]} '
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
        }' > grid_contours_replaced_minor.txt
        gmt psxy grid_contours_replaced_minor.txt -Sqn1+r${module_gis_cn_mindist[$tt]}:+f${module_gis_cn_fontsize[$tt]},Helvetica,${module_gis_cn_fontcolor[$tt]}+Lh+i+e -C${module_gis_cn_cpt[$tt]} ${RJOK} >> map.ps
        gmt psxy grid_contours_replaced_minor.txt -W${module_gis_gciw},${module_gis_gcic}+z -C${module_gis_cn_cpt[$tt]} ${RJOK} >> map.ps
      fi
      if [[ -s splitmajorcontourlines.dat ]]; then
        gawk < splitmajorcontourlines.dat -v skipint=${module_gis_cn_skipint[$tt]} -v inv=${module_gis_cn_inv[$tt]} '
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
        }' > grid_contours_replaced_major.txt

        gmt psxy grid_contours_replaced_major.txt -Sqn1+r${module_gis_cn_mindist[$tt]}:+f${module_gis_cn_fontsize[$tt]},Helvetica,${module_gis_cn_fontcolor[$tt]}+Lh+i+e -C${module_gis_cn_cpt[$tt]} ${RJOK} >> map.ps
        gmt psxy grid_contours_replaced_major.txt -W${module_gis_gcmw},${module_gis_gcmc}+z -C${module_gis_cn_cpt[$tt]} ${RJOK} >> map.ps
      fi

    # Not sure why we need to do this
    gmt psclip -C ${RJOK} >> map.ps

    fi

    tectoplot_plot_caught=1
  ;;

  module_gis_pt)
    ((module_gis_pt_callnum++))
    tt=$module_gis_pt_callnum

    info_msg "Plotting point dataset $tt: ${module_gis_pt_file[$tt]}"
    if [[ ${module_gis_pt_cpt[$tt]} != "" ]]; then
      gmt psxy ${module_gis_pt_file[$tt]} -W${module_gis_pt_str[$tt]}  -C${module_gis_pt_cpt[$tt]} -G+z -S${module_gis_pt_sym[$tt]}${module_gis_pt_size[$tt]} $RJOK $VERBOSE >> map.ps
    else
      gmt psxy ${module_gis_pt_file[$tt]} -G${module_gis_pt_fill[$tt]} -W${module_gis_pt_str[$tt]} -S${module_gis_pt_sym[$tt]}${module_gis_pt_size[$tt]} $RJOK $VERBOSE >> map.ps
    fi
    tectoplot_plot_caught=1
  ;;

  module_gis_li)  # Should we use -A or not? Unclear!!!
    ((module_gis_li_callnum++))
    tt=$module_gis_li_callnum

    info_msg "[-li]: Plotting line dataset $tt"

    if [[ ${module_gis_li_file[$tt]} == *kml ]]; then
      kml_to_all_xy ${module_gis_li_file[$tt]} module_gis_line_${tt}.txt
      ls -l module_gis_line_${tt}.txt
      module_gis_li_file[$tt]=$(abs_path module_gis_line_${tt}.txt)
    elif [[ ${module_gis_li_file[$tt]} == *shp ]]; then
      CPL_LOG=/dev/null ogr2ogr -f "OGR_GMT" module_gis_line_${tt}.gmt ${module_gis_li_file[$tt]}
      module_gis_li_file[$tt]=$(abs_path module_gis_line_${tt}.gmt)
    fi

    if [[ ! -z ${module_gis_li_fill[$tt]} ]]; then
      if [[ ! -z ${module_gs_li_cpt[$tt]} && ! -z ${module_gs_li_att[$tt]} ]]; then
        module_gis_li_fillcmd="-G+z"
      else
        module_gis_li_fillcmd="-G${module_gis_li_fill[$tt]}"
      fi
    else
      module_gis_li_fillcmd=""
    fi

    if [[ ! -z ${module_gs_li_cpt[$tt]} && ! -z ${module_gs_li_att[$tt]} ]]; then
      gmt psxy ${module_gis_li_file[$tt]} -C${module_gs_li_cpt[$tt]} -aZ=${module_gs_li_att[$tt]} ${module_gis_li_fillcmd} -W${module_gis_li_stroke[$tt]} --PS_LINE_CAP=${GIS_LINEEND_STYLE} $RJOK $VERBOSE >> map.ps
    else
      gmt psxy ${module_gis_li_file[$tt]} ${module_gis_li_fillcmd} -W${module_gis_li_stroke[$tt]} --PS_LINE_CAP=${GIS_LINEEND_STYLE} $RJOK $VERBOSE >> map.ps
    fi
    tectoplot_plot_caught=1
  ;;

  module_gis_lis)
    ((module_gis_lis_callnum++))
    tt=$module_gis_lis_callnum

    if [[ ${module_gis_lis_file[$tt]} == *kml ]]; then
      kml_to_all_xy ${module_gis_lis_file[$tt]} module_gis_lis_${tt}.txt
      ls -l module_gis_lis_${tt}.txt
      module_gis_lis_file[$tt]=$(abs_path module_gis_lis_${tt}.txt)
    fi

    info_msg "Plotting decorated line dataset $tt"
    fillcolor=$(echo ${module_gis_lis_stroke[$tt]} | gawk -F, '{print $2}')
    gmt psxy -Sf1c/3p+l+${module_gis_lis_symbol[$tt]} ${module_gis_lis_file[$tt]} -W${module_gis_lis_stroke[$tt]} -G$fillcolor $RJOK $VERBOSE >> map.ps

    tectoplot_plot_caught=1
  ;;

  module_gis_im)
    ((module_gis_im_callnum++))
    tt=${module_gis_im_callnum}

    gmt grdimage ${module_gis_im_file[$tt]} ${module_gis_im_args[$tt]} -Q ${RJSTRING[@]} -O -K $VERBOSE >> map.ps

    tectoplot_plot_caught=1
  ;;

  module_gis_greatc)

    ((module_gis_greatc_callnum++))
    tt=${module_gis_greatc_callnum}

    local GREATCLON
    local GREATCLAT
    local GREATCAZ
    local GREATC_NUMSET
    greatcnumber=0

    # Read all of the great circles from the file
    while IFS= read -r p <&3 || [ -n "$p" ] ; do
      d=($(echo $p))
      if arg_is_float ${d[0]}; then
        ((greatcnumber++))
        GREATCLON[$greatcnumber]=${d[0]}
        GREATCLAT[$greatcnumber]=${d[1]}
        GREATCAZ[$greatcnumber]=${d[2]}
        GREATC_NUMSET="${GREATC_NUMSET} ${greatcnumber}"
      else
        echo "[-greatc]: skipping line $p"
      fi
    done 3< ${module_gis_greatc_file[$tt]}

    # Read any great circles from the list
    # This isn't very elegant... and bugs out if not multiples of 3!
    while [[ ! -z ${module_gis_greatc_list[$tt]} ]]; do
      ((greatcnumber++))
      # First word
      GREATCLON[$greatcnumber]=${module_gis_greatc_list[$tt]%% *}
      # All but first word
      module_gis_greatc_list[$tt]=${module_gis_greatc_list[$tt]#* }
      # First word
      GREATCLAT[$greatcnumber]=${module_gis_greatc_list[$tt]%% *}
      # All but first word
      module_gis_greatc_list[$tt]=${module_gis_greatc_list[$tt]#* }
      # First word
      GREATCAZ[$greatcnumber]=${module_gis_greatc_list[$tt]%% *}
      # All but first word
      module_gis_greatc_list[$tt]=${module_gis_greatc_list[$tt]#* }
      if [[ ${module_gis_greatc_list[$tt]} == ${module_gis_greatc_list[$tt]#* } ]]; then
        GREATC_NUMSET="${GREATC_NUMSET} ${greatcnumber}"
        break
      fi
      GREATC_NUMSET="${GREATC_NUMSET} ${greatcnumber}"
    done

    # This is the list of indices for great circles
    p=(${GREATC_NUMSET})

    if [[ ${module_gis_greatc_dash[$tt]} -ne 0 ]]; then
      module_gis_greatc_dashcmd=",-"
    else
      module_gis_greatc_dashcmd=""
    fi

    for this_gc in ${p[@]}; do
      gmt project -C${GREATCLON[$this_gc]}/${GREATCLAT[$this_gc]} -A${GREATCAZ[$this_gc]} -G0.5 -L-360/0 > ${F_MAPELEMENTS}great_circle_${tt}_${this_gc}.txt

      if [[ ${module_gis_greatc_label[$tt]} -eq 1 ]]; then
        gmt psxy ${F_MAPELEMENTS}great_circle_${tt}_${this_gc}.txt -Sqn1:+f8p,Helvetica,${GREATCCOLOR[$this_gc]}+l"${GREATCAZ[$this_gc]} azimuth"+v -W${module_gis_greatc_stroke[$tt]}${module_gis_greatc_dashcmd} $RJOK $VERBOSE >> map.ps
      else
        gmt psxy ${F_MAPELEMENTS}great_circle_${tt}_${this_gc}.txt -W${module_gis_greatc_stroke[$tt]}${module_gis_greatc_dashcmd} $RJOK $VERBOSE >> map.ps
      fi

      # Need to calculate the pole to the great circle
      fillcolor=$(echo ${module_gis_greatc_stroke[$tt]} | gawk -F, '{print $2}')

      if [[ ${module_gis_greatc_dot[$tt]} -eq 1 ]]; then
        echo "${GREATCLON[$this_gc]} ${GREATCLAT[$this_gc]}" | gmt psxy -Sc0.1i -G${fillcolor} $RJOK $VERBOSE >> map.ps
      fi
    done
    tectoplot_plot_caught=1

  ;;

  module_gis_smallc)

    ((module_gis_smallc_callnum++))
    tt=${module_gis_smallc_callnum}

    local smallc_lon
    local smallc_lat
    local smallc_dist
    local smallc_numset
    smallcnumber=0

    # Read all of the small circles from the file
    if [[ -s ${module_gis_smallc_file[$tt]} ]]; then
      while IFS= read -r p <&3 || [ -n "$p" ] ; do
        d=($(echo $p))
        if arg_is_positive_float ${d[2]}; then
          ((smallcnumber++))
          smallc_lon[$smallcnumber]=${d[0]}
          smallc_lat[$smallcnumber]=${d[1]}
          smallc_dist[$smallcnumber]=${d[2]}
          smallc_numset="${smallc_numset} ${smallcnumber}"
        else
          echo "[-smallc]: skipping line $p"
        fi
      done 3< ${module_gis_smallc_file[$tt]}
    fi

    # Read any great circles from the list
    # This isn't very elegant... and bugs out if not multiples of 3!
    while [[ ! -z ${module_gis_smallc_list[$tt]} ]]; do
      ((smallcnumber++))
      # First word
      smallc_lon[$smallcnumber]=${module_gis_smallc_list[$tt]%% *}
      # All but first word
      module_gis_smallc_list[$tt]=${module_gis_smallc_list[$tt]#* }
      # First word
      smallc_lat[$smallcnumber]=${module_gis_smallc_list[$tt]%% *}
      # All but first word
      module_gis_smallc_list[$tt]=${module_gis_smallc_list[$tt]#* }
      # First word
      smallc_dist[$smallcnumber]=${module_gis_smallc_list[$tt]%% *}
      if ! arg_is_positive_float ${module_gis_smallc_list[$tt]%% *}; then
        echo "[-smallc]: degree radius value ${module_gis_smallc_list[$tt]%% *} is not a positive float"
        exit 1
      fi
      # All but first word
      module_gis_smallc_list[$tt]=${module_gis_smallc_list[$tt]#* }
      if [[ ${module_gis_smallc_list[$tt]} == ${module_gis_smallc_list[$tt]#* } ]]; then
        smallc_numset="${smallc_numset} ${smallcnumber}"
        break
      fi
      smallc_numset="${smallc_numset} ${smallcnumber}"
    done

    # This is the list of indices for great circles
    p=(${smallc_numset})

    if [[ ${module_gis_smallc_dash[$tt]} -ne 0 ]]; then
      module_gis_smallc_dashcmd=",-"
    else
      module_gis_smallc_dashcmd=""
    fi

    for this_sc in ${p[@]}; do
      polelat=${smallc_lat[$this_sc]}
      polelon=${smallc_lon[$this_sc]}

      poleantilat=$(echo "0 - (${polelat})+0.00000000001" | bc -l)
      poleantilon=$(echo "${polelon}" | gawk  '{if ($1 < 0) { print $1+180 } else { print $1-180 } }')

      gmt_init_tmpdir
        gmt project -T${polelon}/${polelat} -C${poleantilon}/${poleantilat} \
          -G0.5/${smallc_dist[$this_sc]} -L-360/0 $VERBOSE \
          | gawk '{print $1, $2}' \
          > ${F_MAPELEMENTS}smallcircle_${tt}_${this_sc}.txt
      gmt_remove_tmpdir

      if [[ ${SMALLC_PLOTLABEL[$this_sc]} -eq 1 ]]; then
        gmt psxy ${F_MAPELEMENTS}smallcircle_${tt}_${this_sc}.txt \
          -Sqn1:+f8p,Helvetica,${SMALLCCOLOR[$this_sc]}+l"${smallc_dist[$this_sc]}°"+v \
          -W${module_gis_smallc_stroke[$tt]}${module_gis_smallc_dashcmd} $RJOK $VERBOSE \
          >> map.ps
      else
        gmt psxy ${F_MAPELEMENTS}smallcircle_${tt}_${this_sc}.txt \
          -W${module_gis_smallc_stroke[$tt]}${module_gis_smallc_dashcmd} $RJOK $VERBOSE \
          >> map.ps
      fi

      if [[ ${SMALLCPOLE[$this_sc]} -eq 1 ]]; then
        echo "$polelon $polelat" | gmt psxy -Sc0.1i -G${SMALLCCOLOR[$this_sc]} $RJOK $VERBOSE >> map.ps
      fi

      fillcolor=$(echo ${module_gis_smallc_stroke[$tt]} | gawk -F, '{print $2}')

      if [[ ${module_gis_smallc_pole[$tt]} -eq 1 ]]; then
        echo "${smallc_lon[$this_sc]} ${smallc_lat[$this_sc]}" | gmt psxy -Sc0.1i -G${fillcolor} $RJOK $VERBOSE >> map.ps
      fi
    done
    tectoplot_plot_caught=1

  ;;

  esac
}

# function tectoplot_legend_gis() {
# }

function tectoplot_legendbar_gis() {
  case $1 in
    module_gis_gr)
      echo "G 0.2i" >> ${LEGENDDIR}legendbars.txt
      echo "B ${module_gis_gr_cpt[$module_gis_gr_callnum]} 0.2i ${LEGEND_BAR_HEIGHT}+malu ${LEGENDBAR_OPTS} -Bxaf+l\"$(basename ${module_gis_gr_file[$module_gis_gr_callnum]})\"" >> ${LEGENDDIR}legendbars.txt
      barplotcount=$barplotcount+1
      tectoplot_caught_legendbar=1
      ;;
  esac
}

# function tectoplot_post_gis() {
# }

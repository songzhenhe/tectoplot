
# Commands for plotting GIS datasets like points, lines, and grids

# UPDATED
# NEW OPTS

# Register the module with tectoplot
TECTOPLOT_MODULES+=("gis")

function tectoplot_defaults_gis() {

# GIS line end style option: round, square, butt
  GIS_LINEEND_STYLE=butt
# GIS line segment join: round, miter, bevel
  GIS_LINEJOIN_STYLE=miter

}

#############################################################################
### Argument processing function defines the flag (-example) and parses arguments

function tectoplot_args_gis()  {
  # The following lines are required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -nangrid)
  tectoplot_get_opts_inline '
des -nangrid plot NaN cells from grid as colored cells
req m_gis_nangrid_file file
    input grid file
' "${@}" || return

  plots+=("m_gis_nangrid")
  ;;

  -cn)
  tectoplot_get_opts_inline '
des -cn Plot contours of gridded dataset
req m_gis_cn_file file
    input grid file
opt list m_gis_cn_levels floatlist ""
    list of contour levels
opt skip m_gis_cn_skipint posint 1
    interval skipping factor
opt space m_gis_cn_space posint 5
    interval of major contours
opt inv m_gis_cn_inv flag 0
    invert the contour interval?
opt int m_gis_cn_int float 100
    contour interval
opt cpt m_gis_cn_cpt cpt ""
    color lines according to CPT
opt sep m_gis_cn_mindist string 0.5i
    minimum distance between labels
opt smooth m_gis_cn_smooth float 3
    smoothing factor
opt fontsize m_gis_cn_fontsize float 4
    font size for contour labels
opt fontcolor m_gis_cn_fontcolor string "black"
    font color for contour labels
opt index m_gis_cn_index float 0
    specified contour level is a major contour
opt minsize m_gis_cn_minsize string ""
    specify minimum number of points (e.g. 500) or length (e.g. 10k)
opt major m_gis_cn_major_app string "1p,black"
    appearance of major contours
opt minor m_gis_cn_minor_app string "0.5p,black"
    appearance of minor contours
opt trans m_gis_cn_trans float 0
    transparency of all contours
mes -cn can be called multiple times with different grid files and options
exa tectoplot -t -cn topo/dem.tif int 1000
' "${@}" || return

  plots+=("m_gis_cn")
  ;;

  -gr)
  tectoplot_get_opts_inline '
des -gr Plot a grid (raster) datafile
req m_gis_gr_file file
    input grid file
opt cpt m_gis_gr_cpt cpt turbo
    specify CPT name or file path
opt stretch m_gis_gr_stretch flag 0
    stretch the CPT to the input values
opt log m_gis_gr_logflag flag 0
    specify that CPT is log
opt noplot m_gis_gr_noplot flag 0
    do not plot the grid
opt trans m_gis_gr_trans posint 0
    set grid transparency
opt tiff m_gis_gr_tiff flag 0
    output TIFF file grid_N.tif in temporary folder
opt code m_gis_gr_code string "c"
    grid ID code
opt list m_gis_gr_list list ""
    test list
mes -gr can be called multiple times with different grid files and options
exa tectoplot -t -ts -gr topo/dem.tif cpt cmocean/topo
' "${@}" || return

  plots+=("m_gis_gr")
  ;;

  -im) # args: file { arguments }

  tectoplot_get_opts_inline '
des -im Plot a rendered grid image datafile
req m_gis_im_file file
    input grid file
opt args m_gis_im_args list ""
    GMT grdimage arguments
opt clip m_gis_im_clip file ""
    clipping polygon file (inside clipping only, alternatively use -clipoff)
mes -im can be called multiple times with different grid files and options
' "${@}" || return

  plots+=("m_gis_im")
  ;;

  -lis)
  tectoplot_get_opts_inline '
des -lis Plot decorated lines (like ticked faults)
req m_gis_lis_file file
    input line file
opt sym m_gis_lis_symbol string "t"
    line decoration type
opt stroke m_gis_lis_stroke string "1p,black"
    line width and color
mes -lis can be called multiple times with different input files and options
' "${@}" || return

  plots+=("m_gis_lis")
  ;;

  -li) # args: file color width
  tectoplot_get_opts_inline '
des -li Plot a polyline file
req m_gis_li_file file
    input polyline file
opt stroke m_gis_li_stroke string "1p,black"
    line width and color
opt fill m_gis_li_fill string ""
    polygon fill color (off)
opt cpt m_gis_li_cpt cpt ""
    CPT to color lines by attribute
opt att m_gis_li_att string ""
    attribute to color lines using cpt option
opt trans m_gis_li_trans float 0
    transparency (0-100)
mes -li can be called multiple times with different input files and options
mes att option requires field name in shapefile/OGR_GMT file
mes To fill polygons with CPT values, use cpt [] att [] fill cpt
' "${@}" || return

  plots+=("m_gis_li")
  ;;

  -pt)
  tectoplot_get_opts_inline '
des -pt Plot a point dataset
req m_gis_pt_file file
    input point file
opt sym m_gis_pt_sym string "c"
    point symbol shape
opt size m_gis_pt_size string "0.1i"
    point symbol size
opt fill m_gis_pt_fill string black
    point fill color
opt str m_gis_pt_str string "0.3p,black"
    point stroke width and color
opt cpt m_gis_pt_cpt cpt ""
    cpt to symbolize Z column values
opt cptfield m_gis_pt_cptfield int 3
    field number to use for Z data (cpt coloring)
opt legend m_gis_pt_legend string "Point data"
    text string for map legend entry
opt label m_gis_pt_label int -1
    beginning field for label text (-1 = labels off)
opt labelend m_gis_pt_labelend int -1 
    end field for label text (-1 = last field in line)
opt offsetx m_gis_pt_offsetx float 6
    X offset for labels (pts)
opt offsety m_gis_pt_offsety float 0
    Y ofset for labels (pts)
opt font m_gis_pt_labelfont string "6p,Helvetica,black"
    font for point labels
opt just m_gis_pt_just word "L"
    justification for point labels (L=left, R=right, C=center)
mes symbol is a GMT psxy -S code
mes  +(plus), st(a)r, (b|B)ar, (c)ircle, (d)iamond, (e)llipse,
mes	  (f)ront, octa(g)on, (h)exagon, (i)nvtriangle, (j)rotated rectangle,
mes	  pe(n)tagon, (p)oint, (r)ectangle, (R)ounded rectangle, (s)quare,
mes   (t)riangle, (x)cross, (y)dash,
' "${@}" || return

  plots+=("m_gis_pt")
  ;;

  # Plot small circle with given angular radius, color, linewidth
  -smallc)
  tectoplot_get_opts_inline '
des -small Plot small circle around a given pole at given angular distance
opt m_gis_smallc_file file
    Input file with fields lon(°) lat(°) dist(°)
opt stroke m_gis_smallc_stroke string "1p,black"
    Width and color of line
opt dash m_gis_smallc_dash flag 0
    Activate dashed line style
opt pole m_gis_smallc_pole flag 0
    Activate plotting of origin location as filled circle
opt list m_gis_smallc_list floatlist ""
    List of small circles in lon lat dist ... format
' "${@}" || return

  plots+=("m_gis_smallc")
  ;;

  # Plot great circle
  -greatc)
  tectoplot_get_opts_inline '
des -greatc Plot great circle passing through given point with given azimuth
opt file m_gis_greatc_file file /dev/null
    Input point file
opt stroke m_gis_greatc_stroke string "1p,black"
    Width and color of line
opt dash m_gis_greatc_dash flag 0
    Activate dashed line style
opt dot m_gis_greatc_dot flag 0
    Activate plotting of origin location as filled circle
opt label m_gis_greatc_label flag 0
    Activate labelling of great circle
opt list m_gis_greatc_list floatlist ""
    List of great circles in lon lat az ... format
' "${@}" || return

  plots+=("m_gis_greatc")
  ;;
  esac
}

function tectoplot_calculate_gis()  {
  if [[ ${m_gis_im_add} -ne 1 ]]; then
    for thisfile in ${m_gis_im_file[@]}; do
      echo "Adding grid file to profile: ${thisfile}"
    done
    m_gis_im_add=1
  fi
}

# function tectoplot_cpt_gis() {
# }

function tectoplot_plot_gis() {

  case $1 in

  m_gis_gr)

    local LOGFLAG=""

    # Each time m_gis_gr is called, plot the grid and increment to the next
    echo "Plotting user grid $tt: ${m_gis_gr_file[$tt]} with CPT ${m_gis_gr_cpt[$tt]}"

    if [[ ${m_gis_gr_logflag[$tt]} -eq 1 ]]; then
      LOGFLAG="-Q"
    else
      LOGFLAG=""
    fi

    if [[ ${m_gis_gr_stretch[$tt]} -eq 1 ]]; then
      gmt grd2cpt ${m_gis_gr_file[$tt]} -Z -C${m_gis_gr_cpt[$tt]} ${LOGFLAG} > ${F_CPTS}grid_${tt}.cpt
      m_gis_gr_cpt[$tt]=${F_CPTS}grid_${tt}.cpt
    fi

    if [[ ${m_gis_gr_tiff[$tt]} -eq 1 ]]; then
      gmt_init_tmpdir
        gmt grdimage ${m_gis_gr_file[$tt]} -Q -C${m_gis_gr_cpt[$tt]} $GRID_PRINT_RES -t${m_gis_gr_trans[$tt]} -JX5i -Agrid_${tt}.tif
      gmt_remove_tmpdir
    fi

    if [[ ${m_gis_gr_noplot[$tt]} -ne 1 ]]; then
      gmt grdimage ${m_gis_gr_file[$tt]} -Q -C${m_gis_gr_cpt[$tt]} $GRID_PRINT_RES -t${m_gis_gr_trans[$tt]} $RJOK ${VERBOSE} >> map.ps
    fi

    tectoplot_plot_caught=1
    ;;

  m_gis_nangrid)

    gmt grdmath ${m_gis_nangrid_file[$tt]} ISNAN = isnangrid_${tt}.tif
    tectoplot_plot_caught=1

  ;;

  m_gis_cn)

    local AFLAG=-A${m_gis_cn_int[$tt]}
    local CFLAG=-C${m_gis_cn_int[$tt]}
    local SFLAG
    local QFLAG

    [[ ! -z ${m_gis_cn_minsize[$tt]} ]] && QFLAG=-Q${m_gis_cn_minsize[$tt]} || QFLAG=""
    [[ ! -z ${m_gis_cn_smooth[$tt]} ]] && SFLAG=-S${m_gis_cn_smooth[$tt]} || SFLAG=""

    local m_gis_gcmw=$(echo ${m_gis_cn_major_app[$tt]} | gawk -F, '{print $1}' )
    local m_gis_gcmc=$(echo ${m_gis_cn_major_app[$tt]} | gawk -F, '{print $2}' )

    local m_gis_gciw=$(echo ${m_gis_cn_minor_app[$tt]} | gawk -F, '{print $1}' )
    local m_gis_gcic=$(echo ${m_gis_cn_minor_app[$tt]} | gawk -F, '{print $2}' )

    if [[ ! -z ${m_gis_cn_levels[$tt]} ]]; then
      local levellist=$(echo ${m_gis_cn_levels[$tt]} | tr ' ' ',' > grid_clevels.txt)

    else

      local zrange=($(grid_zrange ${m_gis_cn_file[$tt]} -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} -fg))

      gawk -v minz=${zrange[0]} -v maxz=${zrange[1]} -v cint=${m_gis_cn_int[$tt]} -v majorspace=${m_gis_cn_space[$tt]} \
           -v minwidth=${m_gis_gciw} -v maxwidth=${m_gis_gcmw} -v mincolor=${m_gis_gcic} \
           -v maxcolor=${m_gis_gcmc} -v annotate=0 -v indexval=${m_gis_cn_index[$tt]} '
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
       gmt grdcontour ${m_gis_cn_file[$tt]} -Cgrid.major.contourdef -D ${AFLAG} ${SFLAG} ${QFLAG} ${VERBOSE} > majorcontourlines.dat
    fi

    if [[ -s grid.minor.contourdef ]]; then
       gmt grdcontour ${m_gis_cn_file[$tt]} -Cgrid.minor.contourdef -D ${AFLAG} ${SFLAG} ${QFLAG} ${VERBOSE} > minorcontourlines.dat
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

    if [[ -z ${m_gis_cn_cpt[$tt]} ]]; then
      [[ -s splitminorcontourlines.dat ]] && gmt psxy splitminorcontourlines.dat -W${m_gis_gciw},${m_gis_gcic} -t${m_gis_cn_trans[$tt]} ${RJOK} >> map.ps
      [[ -s splitmajorcontourlines.dat ]] && gmt psxy splitmajorcontourlines.dat -Sqn1+r${m_gis_cn_mindist[$tt]}:+f${m_gis_cn_fontsize[$tt]},Helvetica,${m_gis_cn_fontcolor[$tt]}+Lh+e -W${m_gis_gcmw},${m_gis_gcmc} -t${m_gis_cn_trans[$tt]} ${RJOK} >> map.ps
    else

      if [[ -s splitminorcontourlines.dat ]]; then
        gawk < splitminorcontourlines.dat -v skipint=${m_gis_cn_skipint[$tt]} -v inv=${m_gis_cn_inv[$tt]} '
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
        gmt psxy grid_contours_replaced_minor.txt -Sqn1+r${m_gis_cn_mindist[$tt]}:+f${m_gis_cn_fontsize[$tt]},Helvetica,${m_gis_cn_fontcolor[$tt]}+Lh+i+e -C${m_gis_cn_cpt[$tt]} ${RJOK} >> map.ps
        gmt psxy grid_contours_replaced_minor.txt -W${m_gis_gciw},${m_gis_gcic}+z -C${m_gis_cn_cpt[$tt]} ${RJOK} >> map.ps
      fi
      if [[ -s splitmajorcontourlines.dat ]]; then
        gawk < splitmajorcontourlines.dat -v skipint=${m_gis_cn_skipint[$tt]} -v inv=${m_gis_cn_inv[$tt]} '
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

        gmt psxy grid_contours_replaced_major.txt -Sqn1+r${m_gis_cn_mindist[$tt]}:+f${m_gis_cn_fontsize[$tt]},Helvetica,${m_gis_cn_fontcolor[$tt]}+Lh+i+e -C${m_gis_cn_cpt[$tt]} ${RJOK} >> map.ps
        gmt psxy grid_contours_replaced_major.txt -W${m_gis_gcmw},${m_gis_gcmc}+z -C${m_gis_cn_cpt[$tt]} ${RJOK} >> map.ps
      fi

    # Not sure why we need to do this
    gmt psclip -C ${RJOK} >> map.ps

    fi

    tectoplot_plot_caught=1
  ;;

  m_gis_pt)

    if [[ ${m_gis_pt_legend[$tt]} == "Point data" ]]; then
      m_gis_pt_legend[$tt]="Point data ${tt}"
    fi

    local cptcol=$(echo "${m_gis_pt_cptfield[$tt]} - 1" | bc)

    info_msg "Plotting point dataset $tt: ${m_gis_pt_file[$tt]}"
    if [[ ${m_gis_pt_cpt[$tt]} != "" ]]; then
      gmt psxy ${m_gis_pt_file[$tt]} -i0,1,${cptcol} -W${m_gis_pt_str[$tt]} -C${m_gis_pt_cpt[$tt]} -G+z -S${m_gis_pt_sym[$tt]}${m_gis_pt_size[$tt]} $RJOK $VERBOSE >> map.ps
    else
      gmt psxy ${m_gis_pt_file[$tt]} -G${m_gis_pt_fill[$tt]} -W${m_gis_pt_str[$tt]} -S${m_gis_pt_sym[$tt]}${m_gis_pt_size[$tt]} $RJOK $VERBOSE >> map.ps
    fi

    if [[ ${m_gis_pt_label[$tt]} -ne -1 ]]; then
      gawk < ${m_gis_pt_file[$tt]} -v field=${m_gis_pt_label[$tt]} -v fieldend=${m_gis_pt_labelend[$tt]} '
      BEGIN {
        OFMT="%.12f"
      }
      {
        printf("%s %s ", $1, $2)
        if (fieldend == -1) {
          this_fieldend = NF
        } else if (fieldend < field) {
          this_fieldend = field
        } else {
          this_fieldend = fieldend
        }
        for(i=field; i<=this_fieldend; ++i) {
          printf("%s ", $(i))
        }
        printf("\n")
      }
      ' | gmt pstext -F+f${m_gis_pt_labelfont[$tt]}+j${m_gis_pt_just[$tt]}M -D${m_gis_pt_offsetx[$tt]}p/${m_gis_pt_offsety[$tt]}p ${RJOK} ${VERBOSE} >> map.ps
    fi

    tectoplot_plot_caught=1
  ;;

  m_gis_li)  # Should we use -A or not? Unclear!!!

    info_msg "[-li]: Plotting line dataset $tt"

    if [[ ${m_gis_li_file[$tt]} == *kml ]]; then
      kml_to_all_xy ${m_gis_li_file[$tt]} m_gis_line_${tt}.txt
      m_gis_li_file[$tt]=$(abs_path m_gis_line_${tt}.txt)
    elif [[ ${m_gis_li_file[$tt]} == *shp ]]; then
      CPL_LOG=/dev/null ogr2ogr -f "OGR_GMT" m_gis_line_${tt}.gmt ${m_gis_li_file[$tt]}
      m_gis_li_file[$tt]=$(abs_path m_gis_line_${tt}.gmt)
    fi

    if [[ ! -z ${m_gis_li_fill[$tt]} ]]; then
      if [[ ! -z ${m_gis_li_cpt[$tt]} && ! -z ${m_gis_li_att[$tt]} ]]; then
        m_gis_li_fillcmd="-G+z"
      else
        m_gis_li_fillcmd="-G${m_gis_li_fill[$tt]}"
      fi
    else
      m_gis_li_fillcmd=""
    fi

    if [[ ! -z ${m_gis_li_cpt[$tt]} && ! -z ${m_gis_li_att[$tt]} ]]; then
      gmt psxy ${m_gis_li_file[$tt]} -C${m_gis_li_cpt[$tt]} -aZ=${m_gis_li_att[$tt]} ${m_gis_li_fillcmd} -W${m_gis_li_stroke[$tt]} -t${m_gis_li_trans[$tt]} --PS_LINE_CAP=${GIS_LINEEND_STYLE} $RJOK $VERBOSE >> map.ps
    else
      gmt psxy ${m_gis_li_file[$tt]} ${m_gis_li_fillcmd} -W${m_gis_li_stroke[$tt]} -t${m_gis_li_trans[$tt]} --PS_LINE_CAP=${GIS_LINEEND_STYLE} $RJOK $VERBOSE >> map.ps
    fi
    tectoplot_plot_caught=1
  ;;

  m_gis_lis)

    if [[ ${m_gis_lis_file[$tt]} == *kml ]]; then
      kml_to_all_xy ${m_gis_lis_file[$tt]} m_gis_lis_${tt}.txt
      ls -l m_gis_lis_${tt}.txt
      m_gis_lis_file[$tt]=$(abs_path m_gis_lis_${tt}.txt)
    fi

    info_msg "Plotting decorated line dataset $tt"
    fillcolor=$(echo ${m_gis_lis_stroke[$tt]} | gawk -F, '{print $2}')
    gmt psxy -Sf1c/3p+l+${m_gis_lis_symbol[$tt]} ${m_gis_lis_file[$tt]} -W${m_gis_lis_stroke[$tt]} -G$fillcolor $RJOK $VERBOSE >> map.ps

    tectoplot_plot_caught=1
  ;;

  m_gis_im)

    if [[ -s ${m_gis_im_clip[$tt]} ]]; then
      gmt psclip ${m_gis_im_clip[$tt]} ${RJOK} ${VERBOSE} >> map.ps
    fi
    gmt grdimage ${m_gis_im_file[$tt]} ${m_gis_im_args[$tt]} ${RJSTRING} -O -K $VERBOSE >> map.ps
    if [[ -s ${m_gis_im_clip[$tt]} ]]; then
      gmt psclip -C -K -O ${VERBOSE} >> map.ps
    fi
    tectoplot_plot_caught=1
  ;;

  m_gis_greatc)

    local GREATCLON
    local GREATCLAT
    local GREATCAZ
    local GREATC_NUMSET
    greatcnumber=0

    if [[ -s ${m_gis_greatc_file[$tt]} ]]; then
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
      done 3< ${m_gis_greatc_file[$tt]}
    fi

    # Read any great circles from the list
    # This isn't very elegant... and bugs out if not multiples of 3!
    while [[ ! -z ${m_gis_greatc_list[$tt]} ]]; do
      ((greatcnumber++))
      # First word
      GREATCLON[$greatcnumber]=${m_gis_greatc_list[$tt]%% *}
      # All but first word
      m_gis_greatc_list[$tt]=${m_gis_greatc_list[$tt]#* }
      # First word
      GREATCLAT[$greatcnumber]=${m_gis_greatc_list[$tt]%% *}
      # All but first word
      m_gis_greatc_list[$tt]=${m_gis_greatc_list[$tt]#* }
      # First word
      GREATCAZ[$greatcnumber]=${m_gis_greatc_list[$tt]%% *}
      # All but first word
      m_gis_greatc_list[$tt]=${m_gis_greatc_list[$tt]#* }
      if [[ ${m_gis_greatc_list[$tt]} == ${m_gis_greatc_list[$tt]#* } ]]; then
        GREATC_NUMSET="${GREATC_NUMSET} ${greatcnumber}"
        break
      fi
      GREATC_NUMSET="${GREATC_NUMSET} ${greatcnumber}"
    done

    # This is the list of indices for great circles
    p=(${GREATC_NUMSET})

    if [[ ${m_gis_greatc_dash[$tt]} -ne 0 ]]; then
      m_gis_greatc_dashcmd=",-"
    else
      m_gis_greatc_dashcmd=""
    fi

    for this_gc in ${p[@]}; do
      gmt project -C${GREATCLON[$this_gc]}/${GREATCLAT[$this_gc]} -A${GREATCAZ[$this_gc]} -G0.5 -L-360/0 > ${F_MAPELEMENTS}great_circle_${tt}_${this_gc}.txt

      if [[ ${m_gis_greatc_label[$tt]} -eq 1 ]]; then
        gmt psxy ${F_MAPELEMENTS}great_circle_${tt}_${this_gc}.txt -Sqn1:+f8p,Helvetica,${GREATCCOLOR[$this_gc]}+l"${GREATCAZ[$this_gc]} azimuth"+v -W${m_gis_greatc_stroke[$tt]}${m_gis_greatc_dashcmd} $RJOK $VERBOSE >> map.ps
      else
        gmt psxy ${F_MAPELEMENTS}great_circle_${tt}_${this_gc}.txt -W${m_gis_greatc_stroke[$tt]}${m_gis_greatc_dashcmd} $RJOK $VERBOSE >> map.ps
      fi

      # Need to calculate the pole to the great circle
      fillcolor=$(echo ${m_gis_greatc_stroke[$tt]} | gawk -F, '{print $2}')

      if [[ ${m_gis_greatc_dot[$tt]} -eq 1 ]]; then
        echo "${GREATCLON[$this_gc]} ${GREATCLAT[$this_gc]}" | gmt psxy -Sc0.1i -G${fillcolor} $RJOK $VERBOSE >> map.ps
      fi
    done
    tectoplot_plot_caught=1

  ;;

  m_gis_smallc)

    local smallc_lon
    local smallc_lat
    local smallc_dist
    local smallc_numset
    smallcnumber=0

    # Read all of the small circles from the file
    if [[ -s ${m_gis_smallc_file[$tt]} ]]; then
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
      done 3< ${m_gis_smallc_file[$tt]}
    fi

    # Read any great circles from the list
    # This isn't very elegant... and bugs out if not multiples of 3!
    while [[ ! -z ${m_gis_smallc_list[$tt]} ]]; do
      ((smallcnumber++))
      # First word
      smallc_lon[$smallcnumber]=${m_gis_smallc_list[$tt]%% *}
      # All but first word
      m_gis_smallc_list[$tt]=${m_gis_smallc_list[$tt]#* }
      # First word
      smallc_lat[$smallcnumber]=${m_gis_smallc_list[$tt]%% *}
      # All but first word
      m_gis_smallc_list[$tt]=${m_gis_smallc_list[$tt]#* }
      # First word
      smallc_dist[$smallcnumber]=${m_gis_smallc_list[$tt]%% *}
      if ! arg_is_positive_float ${m_gis_smallc_list[$tt]%% *}; then
        echo "[-smallc]: degree radius value ${m_gis_smallc_list[$tt]%% *} is not a positive float"
        exit 1
      fi
      # All but first word
      m_gis_smallc_list[$tt]=${m_gis_smallc_list[$tt]#* }
      if [[ ${m_gis_smallc_list[$tt]} == ${m_gis_smallc_list[$tt]#* } ]]; then
        smallc_numset="${smallc_numset} ${smallcnumber}"
        break
      fi
      smallc_numset="${smallc_numset} ${smallcnumber}"
    done

    # This is the list of indices for great circles
    p=(${smallc_numset})

    if [[ ${m_gis_smallc_dash[$tt]} -ne 0 ]]; then
      m_gis_smallc_dashcmd=",-"
    else
      m_gis_smallc_dashcmd=""
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
          -W${m_gis_smallc_stroke[$tt]}${m_gis_smallc_dashcmd} $RJOK $VERBOSE \
          >> map.ps
      else
        gmt psxy ${F_MAPELEMENTS}smallcircle_${tt}_${this_sc}.txt \
          -W${m_gis_smallc_stroke[$tt]}${m_gis_smallc_dashcmd} $RJOK $VERBOSE \
          >> map.ps
      fi

      if [[ ${SMALLCPOLE[$this_sc]} -eq 1 ]]; then
        echo "$polelon $polelat" | gmt psxy -Sc0.1i -G${SMALLCCOLOR[$this_sc]} $RJOK $VERBOSE >> map.ps
      fi

      fillcolor=$(echo ${m_gis_smallc_stroke[$tt]} | gawk -F, '{print $2}')

      if [[ ${m_gis_smallc_pole[$tt]} -eq 1 ]]; then
        echo "${smallc_lon[$this_sc]} ${smallc_lat[$this_sc]}" | gmt psxy -Sc0.1i -G${fillcolor} $RJOK $VERBOSE >> map.ps
      fi
    done
    tectoplot_plot_caught=1

  ;;

  esac
}

function tectoplot_legend_gis() {

  case $1 in
  m_gis_pt)
    info_msg "[-pt]: Adding point [$tt] to legend, ${m_gis_pt_file[$tt]} = ${m_gis_pt_sym[$tt]}"

    init_legend_item "m_gis_pt_${tt}"


    if [[ ${m_gis_pt_cpt[$tt]} != "" ]]; then
      cptval=$(gawk < ${m_gis_pt_file[$tt]} -v cptfield=${m_gis_pt_cptfield[$tt]} '(NR==1) {print $(cptfield)}')
      echo "$CENTERLON $CENTERLAT $cptval" | gmt psxy -W${m_gis_pt_str[$tt]} -C${m_gis_pt_cpt[$tt]} -G+z -S${m_gis_pt_sym[$tt]}${m_gis_pt_size[$tt]} $RJOK $VERBOSE >> ${LEGFILE}
      echo "$CENTERLON $CENTERLAT ${m_gis_pt_legend[$tt]}" | gmt pstext -F+f${m_gis_pt_labelfont[$tt]}+jLM $VERBOSE ${RJOK} -Y0.01i -X0.15i >> ${LEGFILE}
    else
      echo "$CENTERLON $CENTERLAT" | gmt psxy -G${m_gis_pt_fill[$tt]} -W${m_gis_pt_str[$tt]} -S${m_gis_pt_sym[$tt]}${m_gis_pt_size[$tt]} $RJOK $VERBOSE >> ${LEGFILE}
      echo "$CENTERLON $CENTERLAT ${m_gis_pt_legend[$tt]}" | gmt pstext -F+f${m_gis_pt_labelfont[$tt]}+jLM $VERBOSE ${RJOK} -Y0.01i -X0.15i >> ${LEGFILE}
    fi

    # Plot the symbol and accompanying text at the CENTERLON/CENTERLAT point (known to be on the map)

    close_legend_item "m_gis_pt_${tt}"

    tectoplot_legend_caught=1
    ;;
  esac
}

function tectoplot_legendbar_gis() {
  case $1 in
    m_gis_pt)
      if [[ ${m_gis_pt_cpt[$tt]} != "" ]]; then
        echo "G 0.2i" >> ${LEGENDDIR}legendbars.txt
        echo "B ${m_gis_pt_cpt[$tt]} 0.2i ${LEGEND_BAR_HEIGHT}+malu ${LEGENDBAR_OPTS} -Bxaf+l\"${m_gis_pt_legend[$tt]}\"" >> ${LEGENDDIR}legendbars.txt
        barplotcount=$barplotcount+1
      fi
      tectoplot_caught_legendbar=1
    ;;
    m_gis_gr)

      # Is this reference to m_gis_gr_callnum warranted? Or should it be [$tt]

      echo "G 0.2i" >> ${LEGENDDIR}legendbars.txt
      echo "B ${m_gis_gr_cpt[$tt]} 0.2i ${LEGEND_BAR_HEIGHT}+malu ${LEGENDBAR_OPTS} -Bxaf+l\"$(basename ${m_gis_gr_file[$tt]})\"" >> ${LEGENDDIR}legendbars.txt
      barplotcount=$barplotcount+1
      tectoplot_caught_legendbar=1
      ;;
  esac
}

# function tectoplot_post_gis() {
# }

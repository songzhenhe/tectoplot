
# Commands for plotting GIS datasets like points, lines, and grids
# To add: polygons

# Rebasinatlaster the module with tectoplot
TECTOPLOT_MODULES+=("basinatlas")

function getmonth() {
  case $1 in
    s01) echo "January" ;;
    s02) echo "February" ;;
    s03) echo "March" ;;
    s04) echo "April" ;;
    s05) echo "May" ;;
    s06) echo "June" ;;
    s07) echo "July" ;;
    s08) echo "August" ;;
    s09) echo "September" ;;
    s10) echo "October" ;;
    s11) echo "November" ;;
    s12) echo "December" ;;
  esac
}

function tectoplot_defaults_basinatlas() {

    BASINATLASDIR=${DATAROOT}"BasinATLAS_Data_v10_shp/BasinATLAS_v10_shp/"
    BASINATLASDATA=${BASINATLASDIR}"BasinATLAS_v10_lev01.shp"
    BASINATLAS_TRANS=0
    basinatlascptflag=0
    basinatlas_slurped=0
    BASINATLAS_CPTLABEL="BasinAtlas dataset"
    BASINATLAS_DIM="snw_pc"
    BASINATLAS_RES=300
    basinatlas_noplot=0
}

#############################################################################
### Argument processing function defines the flag (-example) and parses arguments

function tectoplot_args_basinatlas()  {
  # The following lines are required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -basinatlas)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-basinatlas:          plot datasets from BasinAtlas
-basinatlas [[options]]

  BasinAtlas is a collection of Earth surface variables discretized by drainage
  basin, distributed under HydroATLAS (https://hydrosheds.org/page/hydroatlas).

  Data level indicates the number of drainage subidivision steps. The higher
  the data level number [1-12], the more polygons there are and the longer a
  plot will take.

  Options:
  level [number]              Data level [0-12]
  data [id_code]              Plot data dimension specified by ID code
  trans [number]              Percent transparency [0-100]
  cpt [filename] [[string]]   Use a custom CPT file with specified legend string
  res [number]                Resolution of rendered image (dpi)
  noplot                      Make GeoTIFF but don't plot to map

  Common suffixes:
      syr       sub-basin annual average
      smx       sub-basen annual maximum
      s01-s12   sub-basin monthly average
      uyr       annual average in watershed above sub-basin pour point
      sse       in sub-basin
      use       in watershed above sub-basin pour point
      sav       in sub-basin average
      uav       in watershed above sub-basin pour point average

  Available datasets:
  >>> Climate Moisture Index (index value x 100) <<<
    cmi_ix_[suf]
      syr | s01-s12 | uyr
  >>> Population Density (people/square km)
    ppd_pk_[suf]
      sav | uav
  >>> Snow Cover (percent area) <<<
    snw_pc_[suf]
      syr | smx | s01-s12 | uyr
  >>> Soil Water Content (percent of max SWC) <<<
    swc_pc_[suf]
      syr | s01-s12 | uyr
  >>> Urban Cover (percent area) <<<
    urb_pc_[suf]
      sse | use


--------------------------------------------------------------------------------
EOF
fi
    shift

    if [[ ! -s ${BASINATLASDATA} ]]; then
      echo "[-basinatlas]: BasinAtlas data not found at ${BASINATLASDATA}. Use tectoplot -getdata."
    else
      while ! arg_is_flag $1; do
        case $1 in
          cpt)
            shift
            ((tectoplot_module_shift++))
            if arg_is_flag $1; then
              echo "[-basinatlas]: cpt option requires filename argument"
              exit 1
            else
              BASINATLAS_CPT=$(abs_path $1)
              basinatlascptflag=1
              shift
              ((tectoplot_module_shift++))
              while ! arg_is_flag $1; do
                basinatlas_slurped=1
                BASINATLAS_LABELSLURP+=("$1")
                shift
                ((tectoplot_module_shift++))
              done
              if [[ $basinatlas_slurped -eq 1 ]]; then
                BASINATLAS_CPTLABEL="${BASINATLAS_LABELSLURP[@]}"
              fi
            fi
            ;;
          data)
            shift
            ((tectoplot_module_shift++))
            if arg_is_flag $1; then
              echo "[-basinatlas]: data option requires argument"
              exit 1
            else
              BASINATLAS_DIM=$1
              shift
              ((tectoplot_module_shift++))
            fi
            ;;
          level)
            shift
            ((tectoplot_module_shift++))
            if arg_is_positive_float $1; then
              BASINATLAS_LEVEL=$(printf "%02d" $1)
              BASINATLASDATA="${BASINATLASDIR}BasinATLAS_v10_lev${BASINATLAS_LEVEL}.shp"
              shift
              ((tectoplot_module_shift++))
            else
              echo "[-basinatlas]: level option requires positive number argument"
              exit 1
            fi
            ;;
          noplot)
            shift
            ((tectoplot_module_shift++))
            basinatlas_noplot=1
            ;;
          res)
            shift
            ((tectoplot_module_shift++))
            if arg_is_positive_float $1; then
              BASINATLAS_RES="${1}"
              shift
              ((tectoplot_module_shift++))
            else
              echo "[-basinatlas]: res option requires positive integer argument"
              exit 1
            fi
            ;;
          trans)
            shift
            ((tectoplot_module_shift++))
            if arg_is_positive_float $1; then
              BASINATLAT_TRANS=$1
              shift
              ((tectoplot_module_shift++))
            else
              echo "[-basinatlas]: trans option requires positive number argument"
              exit 1
            fi
           ;;

          *)
            echo "[-basinatlas]: Argument $1 not recognized"
            exit 1
            ;;
        esac
      done

      plots+=("basinatlas")
      cpts+=("basinatlas")
      echo "BasinAtlas: Linke, S., Lehner, B., Ouellet Dallaire, C., Ariwi, J., Grill, G., Anand, M., Beames, P., Burchard-Levine, V., Maxwell, S., Moidu, H., Tan, F., Thieme, M. (2019). Global hydro-environmental sub-basin and river reach characteristics at high spatial resolution. Scientific Data 6: 283. DOI: 10.1038/s41597-019- 0300-6" >> ${LONGSOURCES}
      echo "HydroAtlas: http://www.hydrosheds.org/page/hydroatlas" >> ${LONGSOURCES}
      echo "BasinAtlas" >> ${SHORTSOURCES}
    fi
    tectoplot_module_caught=1

    ;;
  esac
}

# function tectoplot_calculate_basinatlas()  {
# }

function tectoplot_cpt_basinatlas() {

    # echo "making cpt for ${BASINATLAS_DIM}"

    if [[ $basinatlascptflag -eq 1 ]]; then
      cp ${BASINATLAS_CPT} ${F_CPTS}${BASINATLAS_DIM}.cpt
      BASINATLAS_LEGENDLABEL=${BASINATLAS_CPTLABEL}
    else
      BASINPREFIX=${BASINATLAS_DIM:0:6}
      BASINSUFFIX=${BASINATLAS_DIM:7:3}
      case ${BASINPREFIX} in
        cmi_ix) # syr | s01-s12 | uyr
          gmt makecpt -T-100/100 -Cturbo -I > ${F_CPTS}${BASINPREFIX}.cpt
          # BASINATLAS_LEGENDLABEL="Climate Moisture Index (x100)"
          case ${BASINSUFFIX} in
            s01|s02|s03|s04|s05|s06|s07|s08|s09|s10|s11|s12)
              BASINATLAS_LEGENDLABEL="Climate Moisture Index - basin mean for $(getmonth ${BASINSUFFIX}) (x100)"
            ;;
            syr)
              BASINATLAS_LEGENDLABEL="Climate Moisture Index - basin annual mean (x100)"
            ;;
            uyr)
              BASINATLAS_LEGENDLABEL="Climate Moisture Index - above-pour point annual mean (x100)"
            ;;
          esac
        ;;
        ppd_pk)

cat<<-EOF > ${F_CPTS}${BASINPREFIX}.cpt
0     023/012/101       5  023/012/101  L
5     087/083/177      10  087/083/177  L
10    136/133/204      50  136/133/204  L
50    202/195/243     100  202/195/243  L
100   255/255/191     250  255/255/191  L
250   255/211/128     500  255/211/128  L
500   230/152/0      1000  230/152/000  L
1000  232/0/0      100000  232/000/000  L
B     255/255/255
F     255/255/255
N     127/127/127
EOF

          BASINATLAS_LEGENDLABEL="Population density (people/square km)"
        ;;
        snw_pc)
          gmt makecpt -T0/100 -Cdevon -I > ${F_CPTS}${BASINPREFIX}.cpt
          case ${BASINSUFFIX} in
            s01|s02|s03|s04|s05|s06|s07|s08|s09|s10|s11|s12)
              BASINATLAS_LEGENDLABEL="Snow Cover - basin mean for $(getmonth ${BASINSUFFIX}) (%)"
            ;;
            syr)
              BASINATLAS_LEGENDLABEL="Snow Cover - basin annual mean (%)"
            ;;
            smx)
              BASINATLAS_LEGENDLABEL="Snow Cover - basin annual max (%)"
            ;;
            uyr)
              BASINATLAS_LEGENDLABEL="Snow Cover - above-pour point annual mean (%)"
            ;;
          esac
        ;;
        swc_pc)
          gmt makecpt -T0/100 -Cseis > ${F_CPTS}${BASINPREFIX}.cpt
          case ${BASINSUFFIX} in
            s01|s02|s03|s04|s05|s06|s07|s08|s09|s10|s11|s12)
              BASINATLAS_LEGENDLABEL="Soil Water Content - basin mean for $(getmonth ${BASINSUFFIX}) (% of max SWC)"
            ;;
            syr)
              BASINATLAS_LEGENDLABEL="Soil Water Content - basin annual mean (% of max SWC)"
            ;;
            uyr)
              BASINATLAS_LEGENDLABEL="Soil Water Content - above-pour point annual mean (% of max SWC)"
            ;;
          esac
        ;;
        urb_pc)
          gmt makecpt -T0/100 -Chot -I > ${F_CPTS}${BASINPREFIX}.cpt
          BASINATLAS_LEGENDLABEL="Urban Cover (percent area)"
        ;;
      esac
    fi
}


function tectoplot_plot_basinatlas() {

  case $1 in

  basinatlas)

    # Create a raster image of the polygon data to avoid nasty polygon edges and YUUUUGE PDF files
    gmt_init_tmpdir
      # X and Y spacing are uniform
      BASINATLAS_PSSIZE_ALT=$(gawk -v size=${PSSIZE} -v minlon=${MINLON} -v maxlon=${MAXLON} -v minlat=${MINLAT} -v maxlat=${MAXLAT} '
        BEGIN {
          print size*(minlat-maxlat)/(minlon-maxlon)
        }')

      # echo selecting data
      # gmt spatial ${BASINATLASDATA} -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} > basinsel.shp

      echo done
      basinatlas_rj+=("-R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}")
      basinatlas_rj+=("-JX${PSSIZE}i/${BASINATLAS_PSSIZE_ALT}id")
      # Plot the map in Cartesian coordinates
      gmt psxy ${BASINATLASDATA} -G+z -C${F_CPTS}${BASINPREFIX}.cpt -t${BASINATLAS_TRANS} -aZ=${BASINATLAS_DIM} ${basinatlas_rj[@]} --PS_MEDIA=${PSSIZE}ix${BASINATLAS_PSSIZE_ALT}i -fg -Bxaf -Byaf -Btlrb -Xc -Yc --GMT_HISTORY=false  > basin.ps 2>/dev/null
      # Convert to a TIFF file at specified resolution
      gmt psconvert basin.ps -Tt -E${BASINATLAS_RES} -W+g ${VERBOSE}
      # Update the coordinates in basin.tif to be correct
      gdal_edit.py -a_ullr ${MINLON} ${MAXLAT} ${MAXLON} ${MINLAT} basin.tif

    gmt_remove_tmpdir

    [[ $basinatlas_noplot -ne 1 ]] && gmt grdimage basin.tif ${RJOK} ${VERBOSE} >> map.ps

    # This plots the polygon data directly making YUUUGE TIFF file
    # gmt psxy ${BASINATLASDATA} -G+z -C${F_CPTS}${BASINPREFIX}.cpt -t${BASINATLAS_TRANS} -aZ=${BASINATLAS_DIM} ${RJOK} -Vn >> map.ps 2>/dev/null
    tectoplot_plot_caught=1
    ;;
  esac

}

# function tectoplot_legend_basinatlas() {
# }

function tectoplot_legendbar_basinatlas() {
  case $1 in
    basinatlas)

      echo "G 0.2i" >> legendbars.txt
      echo "B ${F_CPTS}${BASINPREFIX}.cpt 0.2i 0.1i+malu -Bxaf+l\"${BASINATLAS_LEGENDLABEL}\"" >> legendbars.txt
      barplotcount=$barplotcount+1
      tectoplot_caught_legendbar=1
      ;;
  esac
}

# function tectoplot_post_basinatlas() {
# }

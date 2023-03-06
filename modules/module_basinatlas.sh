
# Commands for plotting GIS datasets like points, lines, and grids
# To add: polygons

# UPDATED

# NEW OPTS

# Register the module with tectoplot
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
    m_basinatlas_datapath=${BASINATLASDIR}"BasinATLAS_v10_lev01.shp"

    # m_basinatlas_trans=0
    # basinatlascptflag=0
    m_basinatlas_cptLABEL="BasinAtlas dataset"
    # m_basinatlas_data="snw_pc"
    # m_basinatlas_res=300
    # m_basinatlas_noplot=0
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

  tectoplot_get_opts_inline '
des -basinatlas plot datasets from BasinAtlas
opt level m_basinatlas_datalevel int 6
    data level [0-12]
opt data m_basinatlas_data string ppd_pk_uav
    data dimension specified by ID code
opt trans m_basinatlas_trans float 0
    transparency level [0-100]
opt cpt m_basinatlas_cpt cpt cpts/ppd_pk.cpt
    CPT for displaying data
opt log m_basinatlas_cptlog flag 0
    plot CPT scale bar with logarithmic intervals
opt res m_basinatlas_res float 300
    resolution of rendered image (dpi)
opt noplot m_basinatlas_noplot flag 0
    make GeoTIFF but do not plot to the map
opt psplot m_basinatlas_psplot flag 0
    plot SHP directly to map PS file (can be very large)
mes BasinAtlas is a collection of Earth surface variables discretized by drainage
mes basin, distributed under HydroATLAS (https://hydrosheds.org/page/hydroatlas).
mes
mes Data level indicates the number of drainage subidivision steps. The higher
mes the data level number [1-12], the more polygons there are and the longer a
mes plot will take.
mes
mes Common suffixes:
mes     syr       sub-basin annual average
mes     smx       sub-basen annual maximum
mes     s01-s12   sub-basin monthly average
mes     uyr       annual average in watershed above sub-basin pour point
mes     sse       in sub-basin
mes     use       in watershed above sub-basin pour point
mes     sav       in sub-basin average
mes     uav       in watershed above sub-basin pour point average
mes
mes Available datasets:
mes >>> Climate Moisture Index (index value x 100) <<<
mes   cmi_ix_[suf]
mes     syr | s01-s12 | uyr
mes >>> Population Density (people/square km)
mes   ppd_pk_[suf]
mes     sav | uav
mes >>> Snow Cover (percent area) <<<
mes   snw_pc_[suf]
mes     syr | smx | s01-s12 | uyr
mes >>> Soil Water Content (percent of max SWC) <<<
mes   swc_pc_[suf]
mes     syr | s01-s12 | uyr
mes >>> Urban Cover (percent area) <<<
mes   urb_pc_[suf]
mes     sse | use
exa tectoplot -r IT -basinatlas level 6
' "${@}" || return

  [[ -s ${m_basinatlas_cpt} ]] && basinatlascptflag=1

  plots+=("basinatlas")
  cpts+=("basinatlas")
  ;;

  esac
}

# function tectoplot_calculate_basinatlas()  {
# }

function tectoplot_cpt_basinatlas() {

    if [[ -s ${m_basinatlas_used_cpt[$tt]} ]]; then
      m_basinatlas_legendlabel[$tt]=${m_basinatlas_cptLABEL}
      m_basinatlas_used_cpt[$tt]=${m_basinatlas_cpt[$tt]}
    else
      m_basinatlas_prefix[$tt]=${m_basinatlas_data[$tt]:0:6}
      m_basinatlas_suffix[$tt]=${m_basinatlas_data[$tt]:7:3}

      case ${m_basinatlas_prefix[$tt]} in
        cmi_ix)
          gmt makecpt -T-100/100 -Cturbo -I > ${F_CPTS}${m_basinatlas_prefix[$tt]}.cpt
          case ${m_basinatlas_suffix[$tt]} in
            s01|s02|s03|s04|s05|s06|s07|s08|s09|s10|s11|s12)
              m_basinatlas_legendlabel[$tt]="Climate Moisture Index - basin mean for $(getmonth ${m_basinatlas_suffix[$tt]}) (x100)"
            ;;
            syr)
              m_basinatlas_legendlabel[$tt]="Climate Moisture Index - basin annual mean (x100)"
            ;;
            uyr)
              m_basinatlas_legendlabel[$tt]="Climate Moisture Index - above-pour point annual mean (x100)"
            ;;
          esac
        ;;
        ppd_pk)

cat<<-EOF > ${F_CPTS}${m_basinatlas_prefix[$tt]}.cpt
0.01     023/012/101       5  023/012/101  L
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

          m_basinatlas_legendlabel[$tt]="Population density (people/square km)"
          m_basinatlas_cptlog[$tt]=1
        ;;
        snw_pc)
          gmt makecpt -T0/100 -Cdevon -I > ${F_CPTS}${m_basinatlas_prefix[$tt]}.cpt
          case ${m_basinatlas_suffix[$tt]} in
            s01|s02|s03|s04|s05|s06|s07|s08|s09|s10|s11|s12)
              m_basinatlas_legendlabel[$tt]="Snow Cover - basin mean for $(getmonth ${m_basinatlas_suffix[$tt]}) (%)"
            ;;
            syr)
              m_basinatlas_legendlabel[$tt]="Snow Cover - basin annual mean (%)"
            ;;
            smx)
              m_basinatlas_legendlabel[$tt]="Snow Cover - basin annual max (%)"
            ;;
            uyr)
              m_basinatlas_legendlabel[$tt]="Snow Cover - above-pour point annual mean (%)"
            ;;
          esac
        ;;
        swc_pc)
          gmt makecpt -T0/100 -Cseis > ${F_CPTS}${m_basinatlas_prefix[$tt]}.cpt
          case ${m_basinatlas_suffix[$tt]} in
            s01|s02|s03|s04|s05|s06|s07|s08|s09|s10|s11|s12)
              m_basinatlas_legendlabel[$tt]="Soil Water Content - basin mean for $(getmonth ${m_basinatlas_suffix[$tt]}) (% of max SWC)"
            ;;
            syr)
              m_basinatlas_legendlabel[$tt]="Soil Water Content - basin annual mean (% of max SWC)"
            ;;
            uyr)
              m_basinatlas_legendlabel[$tt]="Soil Water Content - above-pour point annual mean (% of max SWC)"
            ;;
          esac
        ;;
        urb_pc)
          gmt makecpt -T0/100 -Chot -I > ${F_CPTS}${m_basinatlas_prefix[$tt]}.cpt
          m_basinatlas_legendlabel[$tt]="Urban Cover (percent area)"
        ;;
      esac
      m_basinatlas_used_cpt[$tt]=${F_CPTS}${m_basinatlas_prefix[$tt]}.cpt

    fi
}


function tectoplot_plot_basinatlas() {

  case $1 in

  basinatlas)

    m_basinatlas_thislevel=$(printf %02d ${m_basinatlas_datalevel[$tt]})
    m_basinatlas_datapath[$tt]="${BASINATLASDIR}BasinATLAS_v10_lev${m_basinatlas_thislevel}.shp"

    if [[ $m_basinatlas_psplot -eq 0 ]]; then
      # Create a raster image of the polygon data to avoid nasty polygon edges and large PDF files
      gmt_init_tmpdir
        # X and Y spacing are uniform
        BASINATLAS_PSSIZE_ALT=$(gawk -v size=${PSSIZE} -v minlon=${MINLON} -v maxlon=${MAXLON} -v minlat=${MINLAT} -v maxlat=${MAXLAT} '
          BEGIN {
            print size*(minlat-maxlat)/(minlon-maxlon)
          }')

        # echo selecting data
        # gmt spatial ${m_basinatlas_datapath} -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} > basinsel.shp

        basinatlas_rj+=("-R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}")
        basinatlas_rj+=("-JX${PSSIZE}i/${BASINATLAS_PSSIZE_ALT}id")
        # Plot the map in Cartesian coordinates
        gmt psxy ${m_basinatlas_datapath[$tt]} -G+z -C${m_basinatlas_used_cpt[$tt]} -t${m_basinatlas_trans[$tt]} -aZ=${m_basinatlas_data[$tt]} ${basinatlas_rj[@]} --PS_MEDIA=${PSSIZE}ix${BASINATLAS_PSSIZE_ALT}i -fg -Bxaf -Byaf -Btlrb -Xc -Yc --MAP_FRAME_PEN=0p,black --GMT_HISTORY=false  > basin.ps 2>/dev/null
        # Convert to a TIFF file at specified resolution
        gmt psconvert basin.ps -A+m0i -Tt -E${m_basinatlas_res[$tt]} -W+g ${VERBOSE}
        # Update the coordinates in basin.tif to be correct
        gdal_edit.py -a_ullr ${MINLON} ${MAXLAT} ${MAXLON} ${MINLAT} basin.tif

      gmt_remove_tmpdir

      [[ ${m_basinatlas_noplot[$tt]} -ne 1 ]] && gmt grdimage basin.tif ${RJOK} ${VERBOSE} >> map.ps
    else
    # This plots the polygon data directly making a potentially very large PS file
      gmt psxy ${m_basinatlas_datapath} -G+z -C${m_basinatlas_used_cpt[$tt]} -t${m_basinatlas_trans} -aZ=${m_basinatlas_data} ${RJOK} -Vn >> map.ps 2>/dev/null
    fi

    echo "BasinAtlas: Linke, S., Lehner, B., Ouellet Dallaire, C., Ariwi, J., Grill, G., Anand, M., Beames, P., Burchard-Levine, V., Maxwell, S., Moidu, H., Tan, F., Thieme, M. (2019). Global hydro-environmental sub-basin and river reach characteristics at high spatial resolution. Scientific Data 6: 283. DOI: 10.1038/s41597-019- 0300-6" >> ${LONGSOURCES}
    echo "HydroAtlas: http://www.hydrosheds.org/page/hydroatlas" >> ${LONGSOURCES}
    echo "BasinAtlas" >> ${SHORTSOURCES}

    tectoplot_plot_caught=1
    ;;
  esac

}

# function tectoplot_legend_basinatlas() {
# }

function tectoplot_legendbar_basinatlas() {
  case $1 in
    basinatlas)
      if [[ ${m_basinatlas_cptlog[$tt]} -eq 1 ]]; then
        m_basinatlas_logcmd="-Q"
      else
        m_basinatlas_logcmd=""
      fi

      echo "G 0.2i" >> ${LEGENDDIR}legendbars.txt
      echo "B ${m_basinatlas_used_cpt[$tt]} 0.2i 0.1i+malu ${m_basinatlas_logcmd} -Bxaf+l\"${m_basinatlas_legendlabel[$tt]}\"" >> ${LEGENDDIR}legendbars.txt
      barplotcount=$barplotcount+1
      tectoplot_caught_legendbar=1
      ;;
  esac
}

# function tectoplot_post_basinatlas() {
# }

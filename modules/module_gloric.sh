
# Plot Global Rivers Classification shapefiles

# UPDATED
# DOWNLOAD
# NEW OPTS

# This module has been extended to be a generic shapefile plotter using psxy: module_shapefile_line.sh


TECTOPLOT_MODULES+=("gloric")

function tectoplot_defaults_gloric() {
    # Thicknesses are in points
    GLORIC_SMALL_WIDTH_DEF=0.25
    GLORIC_MEDIUM_WIDTH_DEF=0.5
    GLORIC_LARGE_WIDTH_DEF=0.75
    GLORIC_VERYLARGE_WIDTH_DEF=1.25

    GLORICDIR=${DATAROOT}"GloRiC/"
    GLORICDATA=${GLORICDIR}"GloRiC_v10_shapefile/GloRiC_v10.shp"

    GLORIC_SOURCEURL="https://data.hydrosheds.org/file/hydrosheds-associated/gloric/GloRiC_v10_shapefile.zip"
    GLORIC_CHECKFILE="GloRiC_TechDoc_v10.pdf"

    GLORIC_SOURCESTRING="Global Rivers Classification: https://www.hydrosheds.org/products/gloric"
    GLORIC_SHORT_SOURCESTRING="GLoRiC"
}

#############################################################################
### Argument processing function defines the flag (-example) and parses arguments

function tectoplot_args_gloric()  {
  # The following lines are required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in
  -gloric)
  tectoplot_get_opts_inline '
des -gloric plot river channels from GLORIC database
opt minsize m_gloric_sizestring string "small"
    minimum river size: small, medium, large, verylarge
opt color m_gloric_color string "blue"
    river color
opt minq m_gloric_minq float 0
    minimum average Q of plotted reaches
opt cpt m_gloric_cpt cpt "none"
    CPT if coloring by data value per reach
opt cptmin m_gloric_cptmin float -999999
    minimum value for CPT stretch (auto determined)
opt cptmax m_gloric_cptmax float -999999
    maximum value for CPT stretch (auto determined)
opt minmax m_gloric_minmax string "region"
    calculate auto CPT stretch from "region" or "dataset"
opt inv m_gloric_cptinv flag 0
    invert CPT
opt data m_gloric_data string Log_Q_avg
    Log_Q_avg | CMI_indx
opn scale m_gloric_scale float 1
    scale widths by given factor
mes A default CPT is created unless the cpt option is specified
mes Default CPT stretching is calculated using min/max from region
mes Data types:
mes Log_Q_ave [-3.00000000000,1.33064000000]
' "${@}" || return

  plots+=("m_gloric")
  export CPL_LOG="/dev/null"
  ;;

  esac
}

function tectoplot_download_gloric() {

  check_and_download_dataset "${GLORIC_SOURCEURL}" "${GLORICDIR}" "${GLORIC_CHECKFILE}"

}

function tectoplot_calculate_gloric()  {

  GLORIC_SMALL_WIDTH[$tt]=$(echo "${GLORIC_SMALL_WIDTH_DEF} * ${m_gloric_scale}" | bc -l)
  GLORIC_MEDIUM_WIDTH[$tt]=$(echo "${GLORIC_MEDIUM_WIDTH_DEF} * ${m_gloric_scale}" | bc -l)
  GLORIC_LARGE_WIDTH[$tt]=$(echo "${GLORIC_LARGE_WIDTH_DEF} * ${m_gloric_scale}" | bc -l)
  GLORIC_VERYLARGE_WIDTH[$tt]=$(echo "${GLORIC_VERYLARGE_WIDTH_DEF} * ${m_gloric_scale}" | bc -l)

  [[ ! -d ./gloric/ ]] && mkdir ./gloric/
  if [[ ! -s ./gloric/clip.shp ]]; then
    info_msg "[-gloric]: Clipping GLORIC data"
    ogr2ogr -clipsrc ${MINLON} ${MINLAT} ${MAXLON} ${MAXLAT} ./gloric/clip.shp ${GLORICDATA} >/dev/null 2>&1
  fi

}

# function tectoplot_cpt_gloric() {
# }

function tectoplot_plot_gloric() {

  case $1 in

  m_gloric)

    info_msg "[-gloric]: Extracting rivers by size for call instance [$tt]"

    ogr2ogr -sql "SELECT * from clip where (${m_gloric_data[$tt]} >= ${m_gloric_minq[$tt]})" ./gloric/minqsel_${tt}.shp ./gloric/clip.shp

    # If we are coloring by an attribute, do so
    if [[ ${m_gloric_data[$tt]} != "none" ]]; then

      case ${m_gloric_data[$tt]} in
        Log_Q_avg)
          m_gloric_scaletitle[$tt]="Average discharge (log10, m^3/s)"
          [[ ${m_gloric_cpt[$tt]} == "none" ]] && m_gloric_cpt[$tt]="ibcso -I"
        ;;
        *)
          m_gloric_scaletitle[$tt]="GloRiC"
        ;;
      esac


      if [[ ${m_gloric_cptmin[$tt]} -eq -999999 || ${m_gloric_cptmax[$tt]} -eq -999999 ]]; then

        case ${m_gloric_minmax[$tt]} in
          region)
            m_gloric_selectfile=./gloric/clip.shp
          ;;
          dataset)
            m_gloric_selectfile=${GLORICDATA}
          ;;
          *)
            echo "[-gloric]: minmax data region ${m_gloric_minmax[$tt]} should be region or dataset"
            exit 1
          ;;
        esac

        ogr2ogr -f CSV -sql "SELECT MIN(${m_gloric_data[$tt]}) as min_value, MAX(${m_gloric_data[$tt]}) as max_value FROM $(basename ${m_gloric_selectfile} | sed 's/\(.*\)\..*/\1/')" ./gloric/minmax.csv ${m_gloric_selectfile}
        m_gloric_range=($(tail -n 1 ./gloric/minmax.csv | gawk -F, '{print $1, $2}'))
      fi

      [[ ${m_gloric_cptmin[$tt]} -eq -999999 ]] && m_gloric_cptmin[$tt]=${m_gloric_range[0]}
      [[ ${m_gloric_cptmax[$tt]} -eq -999999 ]] && m_gloric_cptmax[$tt]=${m_gloric_range[1]}


      if [[ ${m_gloric_cptinv[$tt]} == 1 ]]; then
        m_gloric_cptinvcmd="-I"
      else
        m_gloric_cptinvcmd=""
      fi

      gmt makecpt -C${m_gloric_cpt[$tt]} -T${m_gloric_cptmin[$tt]}/${m_gloric_cptmax[$tt]} ${m_gloric_cptinvcmd} > ${F_CPTS}gloric_${tt}.cpt

      m_gloric_cptcmd="-C${F_CPTS}gloric_${tt}.cpt -aZ=${m_gloric_data[$tt]}"


    else
      m_gloric_cptcmd=""
      m_gloric_scaletitle[$tt]="River reach type"
    fi

    ogr2ogr -sql "SELECT * FROM clip WHERE CAST(Reach_type as character(10)) like '%4_'" ./gloric/verylarge_${tt}.shp ./gloric/clip.shp >/dev/null 2>&1
    m_gloric_makelarge=0
    m_gloric_makemedium=0
    m_gloric_makesmall=0

    case ${m_gloric_sizestring[$tt]} in
      small)
        m_gloric_makelarge=1
        m_gloric_makemedium=1
        m_gloric_makesmall=1
      ;;
      medium)
        m_gloric_makemedium=1
        m_gloric_makelarge=1
      ;;
      large)
        m_gloric_makelarge=1
      ;;
      verylarge)
        # nothing
      ;;
      *)
        echo "[-gloric]: minsize option ${m_gloric_sizestring[$tt]} not recognized"
        exit 1
      ;;
    esac
    if [[ ${m_gloric_makelarge} -eq 1 ]]; then
        ogr2ogr -sql "SELECT * FROM clip WHERE CAST(Reach_type as character(10)) like '%1_' OR CAST(Reach_type as character(10)) like '0'" ./gloric/small_${tt}.shp ./gloric/clip.shp >/dev/null 2>&1
    fi
    if [[ ${m_gloric_makemedium} -eq 1 ]]; then
      ogr2ogr -sql "SELECT * FROM clip WHERE CAST(Reach_type as character(10)) like '%2_'" ./gloric/medium_${tt}.shp ./gloric/clip.shp >/dev/null 2>&1
    fi
    if [[ ${m_gloric_makesmall} -eq 1 ]]; then
      ogr2ogr -sql "SELECT * FROM clip WHERE CAST(Reach_type as character(10)) like '%3_'" ./gloric/large_${tt}.shp ./gloric/clip.shp >/dev/null 2>&1
    fi
    [[ -s ./gloric/small_${tt}.shp ]] && gmt psxy ./gloric/small_${tt}.shp -W${GLORIC_SMALL_WIDTH[$tt]}p,${m_gloric_color[$tt]} ${m_gloric_cptcmd} --PS_LINE_CAP=round $RJOK $VERBOSE >> map.ps
    [[ -s ./gloric/medium_${tt}.shp ]] && gmt psxy ./gloric/medium_${tt}.shp -W${GLORIC_MEDIUM_WIDTH[$tt]}p,${m_gloric_color[$tt]} ${m_gloric_cptcmd} --PS_LINE_CAP=round $RJOK $VERBOSE >> map.ps
    [[ -s ./gloric/large_${tt}.shp ]] && gmt psxy ./gloric/large_${tt}.shp -W${GLORIC_LARGE_WIDTH[$tt]}p,${m_gloric_color[$tt]} ${m_gloric_cptcmd} --PS_LINE_CAP=round $RJOK $VERBOSE >> map.ps
    [[ -s ./gloric/verylarge_${tt}.shp ]] && gmt psxy ./gloric/verylarge_${tt}.shp -W${GLORIC_VERYLARGE_WIDTH[$tt]}p,${m_gloric_color[$tt]} ${m_gloric_cptcmd} --PS_LINE_CAP=round $RJOK $VERBOSE >> map.ps

    info_msg "[-gloric]: plotting for instance ${tt}"


    echo $GLORIC_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $GLORIC_SOURCESTRING >> ${LONGSOURCES}

    tectoplot_plot_caught=1
    ;;
  esac

}

# function tectoplot_legend_gloric() {
# }

function tectoplot_legendbar_gloric() {
  case $1 in
    m_gloric)

      if [[ -s ${F_CPTS}gloric_${tt}.cpt ]]; then
        echo "G 0.2i" >> ${LEGENDDIR}legendbars.txt
        echo "B ${F_CPTS}gloric_${tt}.cpt 0.2i 0.1i+malu -Bxaf+l\"${m_gloric_scaletitle[$tt]}\"" >> ${LEGENDDIR}legendbars.txt
        barplotcount=$barplotcount+1
        tectoplot_caught_legendbar=1
      fi
      ;;
  esac
}

# function tectoplot_post_gloric() {
# }

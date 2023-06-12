TECTOPLOT_MODULES+=("seis")

# Earthquake hypocenter data


# Global variables that this module expects to be correctly set:

# Global variables that this module can set/modify:

# function tectoplot_defaults_seis() {
# }









function tectoplot_args_seis()  {
  # The following lines are required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

    -z2)  
  tectoplot_get_opts_inline '
des -z2 load and plot seis dataset
opt cat m_seis_z_catalogs string "ANSS,ISC,EMSC"
  selected seismicity catalogs
opt cpt m_seis_z_cpt cpt "${CPTDIR}seis.cpt"
  CPT 
opt minm m_seis_z_minm float 0
  minimum magnitude
opt maxm m_seis_z_maxm float 10
  maximum magnitude
opt mint m_seis_z_mint word "min"
  minimum time ("min" is 0000-01-01T00:00:00)
opt maxt m_seis_z_maxt word "now"
  maximum time ("now" uses current UTC time)
opt mind m_seis_z_mind float -10
  minimum depth
opt maxd m_seis_z_maxd float 6371
  maximum depth
opt fill m_seis_z_fill word "none"
  fill color (replaces CPT coloring)
opt line m_seis_z_line word "0.1p,black"
  line width and color ("none" to turn off)
' "${@}" || return

    plots+=("m_seis_z")
    tectoplot_module_caught=1
    ;;
  
  esac
}

tectoplot_download_seis() {
    echo "Downloading seis [${tt}]"
}

function tectoplot_calculate_seis()  {
    # echo "Performing seismicity calculations (${tt} ${m_seis_z_catalogs[@]}) "
    local cat_ind
    for cat_ind in $(seq 1 ${#m_seis_z_catalogs[@]}); do
        # echo "Selecting raw data from seismicity catalog ${m_seis_z_catalogs[${cat_ind}]} in region ${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}"

        local catalog_array
        catalog_array=($(echo ${m_seis_z_catalogs[${cat_ind}]} | sed 's/,/\n/g' | tr '[:upper:]' '[:lower:]' ))

        for this_catalog in ${catalog_array[@]}; do
            if [[ -e ${TECTOPLOTDIR}sql/${this_catalog}_select.sh ]]; then
                # echo "Running extraction script: ${TECTOPLOTDIR}/sql/${this_catalog}_select.sh"

                # Preparatory variables common to all extraction procedures

                if [[ $notearthquakeflag -eq 1 ]]; then
                  noteqstring="NOT "
                else
                  noteqstring=""
                fi

                if [[ ${m_seis_z_maxt[${cat_ind}]} != "now" || ${m_seis_z_mint[${cat_ind}]} != "min" ]]; then
                    if [[ ${m_seis_z_maxt[${cat_ind}]} == "now" ]]; then
                        m_seis_z_maxt[${cat_ind}]=$(date -u +"%FT%T")
                    fi
                    if [[ ${m_seis_z_mint[${cat_ind}]} == "min" ]]; then
                        m_seis_z_maxt[${cat_ind}]="0000-01-01T00:00:00"
                    fi
                    timeselectflag=1
                fi  

                if [[ $timeselectflag -eq 1 ]]; then
                  timeselstring="AND time <= '${m_seis_z_maxt[${cat_ind}]}' AND time >= '${m_seis_z_mint[${cat_ind}]}'"
                else
                  timeselstring=""
                fi
                magselstring="AND mag <= ${m_seis_z_maxm[${cat_ind}]} AND mag >= ${m_seis_z_minm[${cat_ind}]}"
                depselstring="AND Z(geom) <= ${m_seis_z_maxd[${cat_ind}]} AND Z(geom) >= ${m_seis_z_mind[${cat_ind}]}"

                # echo strings are ${timeselstring} ${magselstring} ${depselstring}

                source ${TECTOPLOTDIR}/sql/${this_catalog}_select.sh
            fi
        done

    done
}

# function tectoplot_cpt_seis() {
# }

function tectoplot_plot_seis() {
  case $1 in
    m_seis_z)
        echo "plotting earthquakes eq_${tt}.txt from catalog ${m_seis_z_catalogs[$tt]}"
        tectoplot_plot_caught=1
    ;;
  esac
}

# function tectoplot_legend_seis() {
# }

# function tectoplot_legendbar_seis() {
#   case $1 in
#     seis)
#       barplotcount=$barplotcount+1
#       tectoplot_caught_legendbar=1
#     ;;
#   esac
# }

# function tectoplot_post_seis() {
#   echo "none"
# }

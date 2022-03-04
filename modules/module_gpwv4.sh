
TECTOPLOT_MODULES+=("gpwv4")

# Plotting of Global Strain Rate Model data (Kreemer et al., 2014)
# Source data is distributed with tectoplot under platemodels/GSRM/

# Variables expected:
# GSRMDATA = full path to GSRM data file

function tectoplot_defaults_gpwv4() {
    # Thicknesses are in points
    GPWV4_TRANS=0
    GPWV4_LOWCUT=1
    GPWV4_DPI=1200   # Default DPI of the plotted grid
    gpwv4_noplot=0

    GPWV4DIR=${DATAROOT}"gpw-v4-population-density-rev11_2020_30_sec_nc/"
    GPWV4DATA=${GPWV4DIR}"gpw_v4_population_density_rev11_2020_30_sec.nc"

    GPWV4_SOURCESTRING="Population density data from Gridded Population of the World, Version 4 (GPWv4): Population Density, Revision 11,  https://doi.org/10.7927/H49C6VHW"
    GPWV4_SHORT_SOURCESTRING="GPWV4"
}

function tectoplot_args_gpwv4()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -popdens)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
modules/module_gpwv4.sh
-popdens:    Plot global population density raster at 30s resolution
-popdens [[options]]

Options:

lowcut [number]   Minimum population density; lower is transparent
trans [number]    Transparency

Example: None
--------------------------------------------------------------------------------
EOF
fi

    shift

    if [[ ! -s ${GPWV4DATA} ]]; then
      echo "[-popdens]: GPWV4 data not found at ${GPWV4DATA}. Use tectoplot -getdata dropbox"
    else
      while ! arg_is_flag $1; do
        case $1 in
          lowcut)
            shift
            ((tectoplot_module_shift++))
            if arg_is_positive_float $1; then
              GPWV4_LOWCUT=$1
              shift
              ((tectoplot_module_shift++))
            else
              echo "[-popdens]: lowcut option requires argument"
              exit 1
            fi
            ;;
          trans)
            shift
            ((tectoplot_module_shift++))
            if arg_is_flag $1; then
              echo "[-popdens]: trans option requires argument"
              exit 1
            else
              GPWV4_TRANS=$1
              shift
              ((tectoplot_module_shift++))
            fi
            ;;
          noplot)
            shift
            ((tectoplot_module_shift++))
            gpwv4_noplot=1
            ;;
          *)
            echo "[-popdens]: Argument $1 not recognized"
            exit 1
            ;;
        esac
      done

      plots+=("gpwv4")

      echo ${GPWV4_SOURCESTRING} >> ${LONGSOURCES}
      echo ${GPWV4_SHORT_SOURCESTRING} >> ${SHORTSOURCES}
    fi
    tectoplot_module_caught=1
    ;;
  esac
}

# function tectoplot_calculate_gpwv4()  {
#   echo "Doing stereonet calculations"
# }
#
function tectoplot_plot_gpwv4() {
  case $1 in
  gpwv4)
    gmt makecpt -Chot -T1/175000/1+l -Z -I --COLOR_BACKGROUND="white" --COLOR_FOREGROUND="white" --COLOR_NAN="white" > ${F_CPTS}gpwv4.cpt


    RSTRING=$(echo ${RJSTRING[@]} | gawk '{print $1}')

    gpwv4_rj+=("-R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}")
    gpwv4_rj+=("-JX${PSSIZE}i/${BASINATLAS_PSSIZE_ALT}id")

    gmt grdclip ${GPWV4DATA} -Sb${GPWV4_LOWCUT}/NaN ${RSTRING} ${VERBOSE} -Gpopdens.nc
    [[ $gpwv4_noplot -eq 0 ]] && gmt grdimage popdens.nc -E${GPWV4_DPI} -C${F_CPTS}gpwv4.cpt -Q -t${GPWV4_TRANS} ${RJOK} ${VERBOSE} >> map.ps
    gmt_init_tmpdir
    gmt grdimage popdens.nc -E${GPWV4_DPI} -C${F_CPTS}gpwv4.cpt -t${GPWV4_TRANS} -Apopdensity.tif ${VERBOSE}
    gdal_edit.py -a_ullr ${MINLON} ${MAXLAT} ${MAXLON} ${MINLAT} popdensity.tif

    gmt_remove_tmpdir
    tectoplot_plot_caught=1

  ;;
  esac
}
#
# function tectoplot_legend_gpwv4() {
#   echo "Doing stereonet legend"
# }

function tectoplot_legendbar_gpwv4() {
  case $1 in
    gpwv4)
      echo "G 0.2i" >> legendbars.txt
      echo "B ${F_CPTS}gpwv4.cpt 0.2i 0.1i+malu -Q -Bxaf+l\"Population density (people/km^2)\"" >> legendbars.txt
      barplotcount=$barplotcount+1
      tectoplot_caught_legendbar=1
    ;;
  esac
}

# function tectoplot_post_gpwv4() {
#   echo "no post"
# }

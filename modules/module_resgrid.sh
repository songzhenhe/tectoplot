
TECTOPLOT_MODULES+=("resgrid")

# Calculate residual grid by removing along-line average, using da-dt formulation
# Builtin support for gravity grids

# Variables needed:
# GRID_PRINT_RES
# GRAVCPT

function tectoplot_defaults_resgrid() {
  SWATH=${BASHSCRIPTDIR}"swath.sh"
  GRAVCPT=${CPTDIR}"grav2.cpt"
  RESGRID_CPT=${F_CPTS}"resgrav.cpt"
  RESGRID_CPTRANGE=145
}

function tectoplot_args_resgrid()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -vres)  # Calculate residual gravity or other grid within specified distance of a provided XY line

  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
modules/module_resgrid.sh
-vres:         create grid swath profile residual using signed distance method
-vres [file or modelID] [xy_file] [width_km] [along_ave_km] [across_ave_km] [[flag1]] ...

  This function takes as input a grid file or gravity model, and an XY line.
  It calculates an along-profile and across-profile running average, where data
  are projected into a da-dt space (da=distance along profile of nearest point,
  dt=distance from nearest point on profile). This projection avoids artifacts
  from kinks in profiles. The along-profile smoothing is done over a running
  window with a specified along-profile width, and across-profile smoothing is
  done in dt space.

  The input grid is first subsampled at a specified along-and-cross profile
  interval using GMT grdtrack. The resulting XY points are projected into da-dt
  space where the smoothing is applied. The resulting data are projected back
  into XY space where a smoothed raster is interpolated from the points. This
  raster is then subtracted from the original grid at the original resolution,
  producing a residual data grid.

  flags: specified as strings
    contour   Plot contours of the smoothed average grid
    path      Plot the profile path
    relief    Plot shaded relief of residual grid

  Gravity models:
    BG        WGM2012 Bouguer
    FA        WGM2012 Free Air
    IS        WGM2012 Isostatic
    SW        Sandwell 2019 Free Air

  TOPOGRAPHY:
    TP        Use topography file created with -t

Example: None
--------------------------------------------------------------------------------
EOF
  fi

    # Check the number of arguments
    if [[ ! $(number_nonflag_args "${@}") -ge 5 ]]; then
      echo "[-vres]: Requires 5-7 arguments. tectoplot usage -vres"
      exit 1
    fi

    shift

    GRAVMODEL="${1}"
    GRAVXYFILE=$(abs_path "${2}")
    GRAVWIDTHKM="${3}"
    GRAVALONGAVKM="${4}"
    GRAVACROSSAVKM="${5}"
    shift 5
    ((tectoplot_module_shift+=5))

    if ! arg_is_positive_float $GRAVWIDTHKM; then
      echo "[-vres]: Argument ${GRAVWIDTHKM} should be a positive number without unit character."
      exit 1
    fi
    if ! arg_is_positive_float $GRAVALONGAVKM; then
      echo "[-vres]: Argument ${GRAVALONGAVKM} should be a positive number without unit character."
      exit 1
    fi
    if ! arg_is_positive_float $GRAVACROSSAVKM; then
      echo "[-vres]: Argument ${GRAVACROSSAVKM} should be a positive number without unit character."
      exit 1
    fi

    while ! arg_is_flag $1; do
      case "${1}" in
        contour)
          GRAVCONTOURFLAG=1
        ;;
        path)
          GRAVPATHFLAG=1
        ;;
        relief)
          GRAVRELIEFFLAG=1
          echo setting here ${GRAVRELIEFFLAG}
        ;;
        plotav)
          PLOTAVGRID=1
        ;;
        *)
          info_msg "[-vres]: Unknown option ${1}... skipping"
        ;;
      esac
      shift
      ((tectoplot_module_shift++))
    done

    if [[ ! -s ${GRAVXYFILE} ]]; then
      info_msg "[-vres]: XY file ${GRAVXYFILE} does not exist."
      exit 1
    else
      if [[ ${GRAVXYFILE} =~ ".kml" ]]; then
        info_msg "[-vres]: KML file specified for XY file. Converting to XY format and using first line only."
        ogr2ogr -f "OGR_GMT" vres_profile.gmt ${GRAVXYFILE}
        gawk < vres_profile.gmt '
          BEGIN {
            count=0
          }
          ($1==">") {
            count++
            if (count>1) {
              exit
            }
          }
          ($1+0==$1) {
            print $1, $2
          }' >  ${TMP}${F_MAPELEMENTS}vres_profile.xy
          GRAVXYFILE=$(abs_path ${TMP}${F_MAPELEMENTS}vres_profile.xy)
      fi
    fi

    case $GRAVMODEL in
      FA)
        GRAVDATA=$WGMFREEAIR
        GRAVCPT=$WGMFREEAIR_CPT
        echo $GRAV_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        echo $GRAV_SOURCESTRING >> ${LONGSOURCES}
        ;;
      BG)
        GRAVDATA=$WGMBOUGUER
        GRAVCPT=$WGMBOUGUER_CPT
        echo $GRAV_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        echo $GRAV_SOURCESTRING >> ${LONGSOURCES}
        ;;
      IS)
        GRAVDATA=$WGMISOSTATIC
        GRAVCPT=$WGMISOSTATIC_CPT
        echo $GRAV_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        echo $GRAV_SOURCESTRING >> ${LONGSOURCES}
        ;;
      SW)
        GRAVDATA=$SANDWELLFREEAIR
        GRAVCPT=$WGMFREEAIR_CPT
        echo $SANDWELL_SOURCESTRING >> ${LONGSOURCES}
        echo $SANDWELL_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        ;;
      TP)
        GRAVDATA=${TMP}${F_TOPO}dem.nc
        GRAVCPT=${TMP}${F_CPTS}topo.cpt
        RESGRID_CPTRANGE=2500
        ;;
      *)
        if [[ ! -s $GRAVMODEL ]]; then
          echo "Gravity model $GRAVMODEL not recognized."
          exit 1
        else
          info_msg "Using custom grid file ${GRAVMODEL}"
          GRAVDATA=${GRAVMODEL}
        fi
        ;;
    esac

    plots+=("resgrid")
    cpts+=("resgrid")

    tectoplot_module_caught=1
    ;;
  esac
}

# tectoplot_cpts_resgrid() {
#
# }

function tectoplot_calculate_resgrid()  {
  info_msg "Making residual gravity along ${GRAVXYFILE}"
  mkdir -p ./resgrav
  cd ./resgrav
  ${SWATH} ${GRAVWIDTHKM} ${GRAVALONGAVKM} ${GRAVACROSSAVKM} ${GRAVXYFILE} ${GRAVDATA} 0.1
  cd ..
}

function tectoplot_cpt_resgrid() {
  if [[ $PLOTAVGRID -eq 1 ]]; then
    [[ ! -s $RESGRID_CPT ]] && gmt makecpt -C$GRAVCPT -T0/500 -Z $VERBOSE > $RESGRID_CPT
  else
    [[ ! -s $RESGRID_CPT ]] && gmt makecpt -C$GRAVCPT -T-${RESGRID_CPTRANGE}/${RESGRID_CPTRANGE} -Z $VERBOSE > $RESGRID_CPT
  fi
}

function tectoplot_plot_resgrid() {
  case $1 in
  resgrid)
    if [[ -e ./resgrav/grid_residual.nc ]]; then
      if [[ $GRAVRELIEFFLAG -eq 1 ]]; then
        GRAVICMD="-I+d"
      else
        GRAVICMD=""
      fi
      if [[ $PLOTAVGRID -eq 1 ]]; then
        gmt grdimage ./resgrav/grid_smoothed.nc ${GRAVICMD} $GRID_PRINT_RES -Q -C${RESGRID_CPT} $RJOK $VERBOSE >> map.ps
      else
        gmt grdimage ./resgrav/grid_residual.nc ${GRAVICMD} $GRID_PRINT_RES -Q -C${RESGRID_CPT} $RJOK $VERBOSE >> map.ps
      fi
      [[ $GRAVCONTOURFLAG -eq 1 ]] && gmt grdcontour ./resgrav/gridwindowed_resample.nc -W0.3p,white,- -C50 $RJOK ${VERBOSE} >> map.ps
    fi
    if [[ $GRAVPATHFLAG -eq 1 ]]; then
      [[ -s ${GRAVXYFILE} ]] && gmt psxy ${GRAVXYFILE} -W0.6p,black,- $RJOK ${VERBOSE} >> map.ps
    fi
    tectoplot_plot_caught=1
    ;;
  esac
}

# function tectoplot_legend_resgrid() {
#   echo "none"
# }

function tectoplot_legendbar_resgrid() {
  case $1 in
    resgrid)
      # echo "G 0.2i" >> legendbars.txt
      # echo "B $MAG_CPT 0.2i 0.1i+malu -Bxa100f50+l\"Magnetization (nT)\"" >> legendbars.txt
      # barplotcount=$barplotcount+1
      tectoplot_caught_legendbar=1
    ;;
  esac
}

# function tectoplot_post_resgrid() {
#   echo "none"
# }

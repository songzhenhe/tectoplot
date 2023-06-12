TECTOPLOT_MODULES+=("resgrid")

# Calculate residual grid by removing along-line and across-line averages,
# using a da-dt formulation
# da is the distance along the path of the closest point on the path to any
# point of the grid
# dt is the distance from that closest point to the grid point

# Variables needed:
# GRID_PRINT_RES

function tectoplot_defaults_resgrid() {
  SWATH=${BASHSCRIPTDIR}"swath.sh"
  GRAVCPT=${CPTDIR}"grav2.cpt"
  RESGRID_CPT=${F_CPTS}"resgrav.cpt"
  VRES_CPTRANGE=400
  calcvresflag=0
}

function tectoplot_args_resgrid()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -vres)  # Calculate residual gravity or other grid within specified distance of a provided XY line
  tectoplot_get_opts_inline '
des -vres create grid swath profile residual using signed distance method
ren m_vres_data word
  source data, file or default data string
ren m_vres_xy file
  XY line file
ren m_vres_width word
  profile width in km
ren m_vres_alongave word
  along-profile averaging distance
ren m_vres_acrossave word
  across-profile averaging distance
opn trans m_vres_trans float 0
  transparency of plotted rasters
opn contour m_vres_contourflag flag 0
  plot contours of the smoothed average grid
opn path m_vres_pathflag flag 0
  plot the profile path
opn relief m_vres_reliefflag flag 0
  plot shaded relief of residual grid
opn plotave m_vres_plotaveflag flag 0
  plot the average grid rather than the residual grid; contour residual
opn res m_vres_res float 0.1
  resolution of subsampled grid, in degrees without unit
opn outline m_vres_outlineflag flag 0
  plot the outline of the swath
mes This function takes as input a grid file or gravity model, and an XY line.
mes It calculates an along-profile and across-profile running average, where data
mes are projected into a da-dt space (da=distance along profile of nearest point,
mes dt=distance from nearest point on profile). This projection avoids artifacts
mes from kinks in profiles. The along-profile smoothing is done over a running
mes window with a specified along-profile width, and across-profile smoothing is
mes done in dt space.
mes
mes The input grid is first subsampled at a specified along-and-cross profile
mes interval using GMT grdtrack. The resulting XY points are projected into da-dt
mes space where the smoothing is applied. The resulting data are projected back
mes into XY space where a smoothed raster is interpolated from the points. This
mes raster is then subtracted from the original grid at the original resolution,
mes producing a residual data grid.
mes Default datasets
mes     BG        WGM2012 Bouguer gravity
mes     FA        WGM2012 Free Air gravity
mes     IS        WGM2012 Isostatic gravity
mes     SW        Sandwell 2019 Free Air gravity
mes     CV        Sandwell 2019 Free Air gravity curvature
mes     TP        Topography created with -t
' "${@}" || return

    if [[ ! -s ${m_vres_xy} ]]; then
      info_msg "[-vres]: XY file ${m_vres_xy} does not exist."
      exit 1
    else
      if [[ ${m_vres_xy} =~ ".kml" ]]; then
        info_msg "[-vres]: KML file specified for XY file. Converting to XY format and using first line only."
        ogr2ogr -f "OGR_GMT" vres_profile.gmt ${m_vres_xy}
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
          m_vres_xy=$(abs_path ${TMP}${F_MAPELEMENTS}vres_profile.xy)
      fi
    fi

    case ${m_vres_data} in
      FA)
        VRES_DATA=$WGMFREEAIR
        VRES_CPT=$WGMFREEAIR_CPT
        echo $GRAV_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        echo $GRAV_SOURCESTRING >> ${LONGSOURCES}
        ;;
      BG)
        VRES_DATA=$WGMBOUGUER
        VRES_CPT=$WGMBOUGUER_CPT
        echo $GRAV_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        echo $GRAV_SOURCESTRING >> ${LONGSOURCES}
        ;;
      IS)
        VRES_DATA=$WGMISOSTATIC
        VRES_CPT=$WGMISOSTATIC_CPT
        echo $GRAV_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        echo $GRAV_SOURCESTRING >> ${LONGSOURCES}
        ;;
      SW)
        VRES_DATA=$SANDWELLFREEAIR
        VRES_CPT=$WGMFREEAIR_CPT
        echo $SANDWELL_SOURCESTRING >> ${LONGSOURCES}
        echo $SANDWELL_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        ;;
      TP)
        VRES_DATA=${TMP}${F_TOPO}dem.tif
        VRES_CPT=${TMP}${F_CPTS}topo.cpt
        VRES_CPTRANGE=2500
        ;;
      CV)
        VRES_DATA=${SANDWELLFREEAIR_CURV}
        VRES_CPT=gray
        ;;
      *)
        if [[ ! -s $GRAVMODEL ]]; then
          echo "Gravity model $GRAVMODEL not recognized."
          exit 1
        else
          info_msg "Using custom grid file ${GRAVMODEL}"
          VRES_DATA=${GRAVMODEL}
        fi
        ;;
    esac

    plots+=("resgrid")
    cpts+=("resgrid")
    cpts+=("grav")
    calcvresflag=1

    tectoplot_module_caught=1
    ;;
  esac
}

# tectoplot_cpts_resgrid() {
#
# }

function tectoplot_calculate_resgrid()  {
  if [[ $calcvresflag -eq 1 ]]; then
    info_msg "Making residual gravity along ${m_vres_xy}"
    mkdir -p ./resgrav
    cd ./resgrav
    ${SWATH} ${m_vres_width} ${m_vres_alongave} ${m_vres_acrossave} ${m_vres_xy} ${VRES_DATA} ${m_vres_res}
    cd ..
  fi
}

function tectoplot_cpt_resgrid() {
  if [[ ${m_vres_plotaveflag} -eq 1 ]]; then
  echo cpt here
    [[ ! -s ${VRES_CPT} ]] && gmt makecpt -C${VRES_CPT} -T0/500 -Z $VERBOSE > ${GRAV_CPT}
  else
  echo cpt there
    [[ ! -s ${VRES_CPT} ]] && gmt makecpt -C${VRES_CPT} -T-${VRES_CPTRANGE}/${VRES_CPTRANGE} -Z $VERBOSE > ${GRAV_CPT}
  fi
}

function tectoplot_plot_resgrid() {
  case $1 in
  resgrid)

    local illumination

    if [[ -e ./resgrav/grid_residual.tif ]]; then
      if [[ ${m_vres_reliefflag} -eq 1 ]]; then
        illumination="-I+d"
      else
        illumination=""
      fi
      if [[ ${m_vres_plotaveflag} -eq 1 ]]; then
        cp ${GRAV_CPT} residgrav.cpt
        gmt grdimage ./resgrav/grid_smoothed.tif ${illumination} -t${m_vres_trans} $GRID_PRINT_RES -Q -C${GRAV_CPT} $RJOK $VERBOSE >> map.ps
        [[ ${m_vres_contourflag} -eq 1 ]] && gmt grdcontour ./resgrav/grid_residual.tif -W0.3p,white -T -C50 $RJOK ${VERBOSE} >> map.ps
      else
        gmt makecpt -Fr -C$GRAVCPT -T-200/200 -Z $VERBOSE > residgrav.cpt
        gmt grdimage ./resgrav/grid_residual.tif ${illumination} -t${m_vres_trans} $GRID_PRINT_RES -Q -Cresidgrav.cpt $RJOK $VERBOSE >> map.ps
        [[ ${m_vres_contourflag} -eq 1 ]] && gmt grdcontour ./resgrav/grid_smoothed.tif -W0.3p,white,- -T -C50 $RJOK ${VERBOSE} >> map.ps
      fi
    fi
    if [[ ${m_vres_pathflag} -eq 1 ]]; then
      [[ -s ${m_vres_xy} ]] && gmt psxy ${m_vres_xy} -W0.6p,black,- $RJOK ${VERBOSE} >> map.ps
    fi

    if [[ ${m_vres_outlineflag} -eq 1 ]]; then
      gmt psxy ./resgrav/trackfile_final_buffer.txt -W0.6p,black,- $RJOK ${VERBOSE} >> map.ps
    fi
    # gmt psxy ./resgrav/trackfile_final_buffer.txt -W0.6p,black,- $RJOK ${VERBOSE} >> map.ps
    # gawk < ./resgrav/trackfile_merged_buffers.gmt '($1+0==$1) { print} ' | gmt psxy -W0.6p,black $RJOK ${VERBOSE} >> map.ps
    # gmt psxy ./resgrav/end_profile_cutbox.gmt -W0.6p,brown,. $RJOK ${VERBOSE} >> map.ps

    tectoplot_plot_caught=1
    ;;
  esac
}

# function tectoplot_legend_resgrid() {
#   echo "none"
# }

function tectoplot_legendbar_resgrid() {
  local gridname
  local gridtype
  case $1 in
    resgrid)
      if [[ ${m_vres_plotaveflag} -eq 1 ]]; then
        gridtype="Average"
      else
        gridtype="Residual"
      fi
      case ${m_vres_data} in
        BG|FA|IS|SW)
          gridname="gravity (mGal)"
        ;;
        CV)
          gridname="gravity curvature"
        ;;
        TP)
          gridname="topography (km)"
        ;;
        *)
          gridname="grid"
        ;;
      esac
      echo "G 0.2i" >>${LEGENDDIR}legendbars.txt
      echo "B residgrav.cpt 0.2i 0.1i+malu -Bxaf+l\"${gridtype} ${gridname}\"" >>${LEGENDDIR}legendbars.txt
      barplotcount=$barplotcount+1
      tectoplot_caught_legendbar=1
    ;;
  esac
}

# function tectoplot_post_resgrid() {
#   echo "none"
# }

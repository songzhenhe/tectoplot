
TECTOPLOT_MODULES+=("geology")

# Geological data (ocean age, transform fault, etc.)

# UPDATED
# NEW OPTS

function tectoplot_defaults_geology() {

  ##
  GEOAGE_CPT=${F_CPTS}"geoage.cpt"
  GEOAGE_COLORBAR_MAX=250
  GEOAGE_COLORBAR_MIN=0

  ##### Oceanic crustal age data (Seton et al. 2020)
  OC_AGE_DIR=$DATAROOT"OC_AGE/"
  OC_AGE=$OC_AGE_DIR"age.2020.1.GTS2012.1m.nc"
  OC_AGE_URL="https://www.earthbyte.org/webdav/ftp/earthbyte/agegrid/2020/Grids/age.2020.1.GTS2012.1m.nc"

  OC_AGE_CPT=$OC_AGE_DIR"age_2020.cpt"
  OC_AGE_CPT_URL="https://www.earthbyte.org/webdav/ftp/earthbyte/agegrid/2020/Grids/cpt/age_2020.cpt"
  OC_AGE_CPT_CHECKFILE="age_2020.cpt"

  OC_AGE_SOURCESTRING="Oceanic crustal age from Seton et al., 2020, https://www.earthbyte.org/webdav/ftp/earthbyte/agegrid/2020/Grids/age.2020.1.GTS2012.1m.nc"
  OC_AGE_SHORT_SOURCESTRING="OCA"

  # Tectonic fabrics data re-distributed alongside tectoplot

  TECTFABRICSDIR=${PLATEMODELSDIR}"TectonicFabrics/"

  GLOBAL_GEO=${TECTFABRICSDIR}"Global_Geology.tif"
  GLOBAL_GEO_TRANS=0

  EARTHBYTE_SOURCESTRING="EarthByte data from GPlates2.2.0, converted to GMT format using GPlates: https://www.earthbyte.org/gplates-2-2-software-and-data-sets/"
  EARTHBYTE_SHORT_SOURCESTRING="EarthByte"

  # Discordant zones
  GSFML_DZ=${TECTFABRICSDIR}"DZ.gmt"

  # Extinct Ridges (not used)
  GSFML_ER=${TECTFABRICSDIR}"ER.gmt"

  # Fracture Zones
  GSFML_FZ=${TECTFABRICSDIR}"FZ.gmt"
  GSFML_FZLC=${TECTFABRICSDIR}"FZLC.gmt"

  # Pseudofaults
  GSFML_PF=${TECTFABRICSDIR}"PF.gmt"

  # Propagating ridges
  GSFML_PR=${TECTFABRICSDIR}"PR.gmt"

  # Unclassified V-anomalies
  GSFML_UNCV=${TECTFABRICSDIR}"UNCV.gmt"

  # V-shaped structures
  GSFML_VANOM=${TECTFABRICSDIR}"VANOM.gmt"

  # Isochrons
  EARTHBYTE_ISO=${TECTFABRICSDIR}"Muller_etal_AREPS_2016_Isochrons.gmt"

  # Hotspots

  EARTHBYTE_HOT=${TECTFABRICSDIR}"Hotspots_Compilation_Whittaker_etal.gmt"

  #EARTHBYTE_ISOCHRONS_SOURCESTRING="Müller, R.D., Seton, M., Zahirovic, S., Williams, S.E., Matthews, K.J., Wright, N.M., Shephard, G.E., Maloney, K.T., Barnett-Moore, N., Hosseinpour, M., Bower, D.J. & Cannon, J. 2016. Ocean Basin Evolution and Global-Scale Plate Reorganization Events Since Pangea Breakup, Annual Review of Earth and Planetary Sciences, vol. 44, pp. 107 . DOI: 10.1146/annurev-earth-060115-012211."
  #EARTHBYTE_ISOCHRONS_SHORT_SOURCESTRING="EarthByte"

  # Additional datasets from GPlates2.2.0 converted to .gmt format
  # See source directory for README and licensing files

  TECTFABRICS_SR=${TECTFABRICSDIR}"Muller_etal_AREPS_2016_Ridges.gmt"

  TECTFABRICS_SR_SOURCESTRING="Seafloor fabrics: Müller et al., 2016 10.1146/annurev-earth-060115-012211"
  TECTFABRICS_SR_SHORT_SOURCESTRING="M2016"

  TECTFABRICS_VP=${TECTFABRICSDIR}"Johansson_etal_2018_VolcanicProvinces_v2.gmt"

  TECTFABRICS_VP_SOURCESTRING="Volcanic provinces: Johansson et al., 2018 doi:10.1029/2017GL076691"
  TECTFABRICS_VP_SHORT_SOURCESTRING="VP/JH2018"

  TECTFABRICS_CP=${TECTFABRICSDIR}"Matthews_etal_GPC_2016_ContinentalPolygons.gmt"
  TECTFABRICS_CP_SOURCESTRING="Continental polygons: Matthews et al., 2016"
  TECTFABRICS_CP_SHORT_SOURCESTRING="CP/M2016"

  EBISOWIDTH=0.5p
}

function tectoplot_args_geology()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -geo)
  tectoplot_get_opts_inline '
des -geo plot global geology map
exa tectoplot -r g -geo
' "${@}" || return

  plots+=("m_geology_geo")
  ;;

  -oca)

  tectoplot_get_opts_inline '
des -oca plot oceanic crust age map
opt trans m_geology_oca_trans float 50
  transparency
opt cpt m_geology_oca_cpt cpt "${F_CPTS}geoage.cpt"
  CPT to use for color
opt stripe m_geology_oca_stripeage float 0
  grayscale stripe frequency (Ma)
exa tectoplot -RJ S 120 20 -t 01d -oca
' "${@}" || return

    plots+=("m_geology_oca")
    cpts+=("geoage")
    legendbarwords+=("geoage")
    ;;

  # Plot tectonic fabrics
  -tf)

  tectoplot_get_opts_inline '
des -tf plot tectonic fabrics
ren m_geology_tf_comstring string
  list of tectonic fabrics to plot, in map layer order
mes   codes
mes   all: Plot all codes except cp
mes
mes   cp: continental polygons (Matthews et al., 2016; via Gplates2.2.0)
mes   dz: discordant zones (EarthByte)
mes   fz: fracture zones (EarthByte)
mes   ht: hotspots (EarthByte)
mes   is: oceanic isochrons (EarthByte)
mes       [[linewidth=${EBISOWIDTH}]] [[color=geoage]]
mes   pf: pseudo faults (EarthByte)
mes   pr: propagating ridges (EarthByte)
mes   sr: spreading ridges (active and extinct) (Muller et al., 2016; via Gplates2.2.0)
mes   va: v-anomalies, classified and unclassified (EarthByte)
mes   vp: volcanic provinces (Johansson et al., 2018; via Gplates2.2.0)
' "${@}" || return

  local comstringargs=($(echo $m_geology_tf_comstring))
  local this_arg

  if [[ " ${comstringargs[@]} " =~ " all " ]]; then
    comstringargs=($(echo "vp dz fz ht pf pr sr va is"))
  fi

  plots+=("tectonic_fabrics")

  for this_arg in ${comstringargs[@]}; do
    case $this_arg in
      cp)
        tectonic_fabrics+=("cp")
        echo $TECTFABRICS_CP_SOURCESTRING >> ${LONGSOURCES}
        echo $TECTFABRICS_CP_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        cpts+=("plateid")
      ;;
      dz)
        tectonic_fabrics+=("dz")
        echo $EARTHBYTE_SOURCESTRING >> ${LONGSOURCES}
        echo $EARTHBYTE_SHORT_SOURCESTRING >> ${SHORTSOURCES}
      ;;
      fz)
        tectonic_fabrics+=("fz")
        echo $EARTHBYTE_SOURCESTRING >> ${LONGSOURCES}
        echo $EARTHBYTE_SHORT_SOURCESTRING >> ${SHORTSOURCES}
      ;;
      ht)
        tectonic_fabrics+=("ht")
        echo $EARTHBYTE_SOURCESTRING >> ${LONGSOURCES}
        echo $EARTHBYTE_SHORT_SOURCESTRING >> ${SHORTSOURCES}
      ;;
      is)
        tectonic_fabrics+=("is")
        cpts+=("geoage")

        echo $EARTHBYTE_SOURCESTRING >> ${LONGSOURCES}
        echo $EARTHBYTE_SHORT_SOURCESTRING >> ${SHORTSOURCES}

        if [[ $2 =~ ^[+-]?([0-9]+\.?[0-9]*|\.[0-9]+)$p ]]; then
          EBISOWIDTH="${2}"
          shift
          ((tectoplot_module_shift++))

          if ! arg_is_flag $2; then
            if [[ ${#2} -gt 2 ]]; then
              EBISOCOLOR="-W${EBISOWIDTH},${2}"
              shift
              ((tectoplot_module_shift++))
            fi
          else
            EBISOCOLOR="-aZ=FROMAGE -W${EBISOWIDTH}+cl -C${GEOAGE_CPT}"
          fi
        else
          EBISOCOLOR="-aZ=FROMAGE -W${EBISOWIDTH}+cl -C${GEOAGE_CPT}"
        fi
      ;;
      pf)
        tectonic_fabrics+=("pf")
        echo $EARTHBYTE_SOURCESTRING >> ${LONGSOURCES}
        echo $EARTHBYTE_SHORT_SOURCESTRING >> ${SHORTSOURCES}
      ;;
      pr)
        tectonic_fabrics+=("pr")
        echo $EARTHBYTE_SOURCESTRING >> ${LONGSOURCES}
        echo $EARTHBYTE_SHORT_SOURCESTRING >> ${SHORTSOURCES}
      ;;
      sr)
        tectonic_fabrics+=("sr")
        echo $TECTFABRICS_SR_SOURCESTRING >> ${LONGSOURCES}
        echo $TECTFABRICS_SR_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        # plots+=("spreadingridges")
      ;;
      va)
        tectonic_fabrics+=("va")
        echo $EARTHBYTE_SOURCESTRING >> ${LONGSOURCES}
        echo $EARTHBYTE_SHORT_SOURCESTRING >> ${SHORTSOURCES}
      ;;
      vp)
        tectonic_fabrics+=("vp")
        # plots+=("volcanicprovinces")
        echo $TECTFABRICS_VP_SOURCESTRING >> ${LONGSOURCES}
        echo $TECTFABRICS_VP_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        makegeoageflag=1
      ;;
      *)
        echo "[-tf]: option $this_arg is not recognized"
        exit 1
      ;;
    esac
  done
  ;;

  esac
}

function tectoplot_download_geology() {
  OC_AGE_DIR=$DATAROOT"OC_AGE/"
  OC_AGE=$OC_AGE_DIR"age.2020.1.GTS2012.1m.nc"
  OC_AGE_URL="https://www.earthbyte.org/webdav/ftp/earthbyte/agegrid/2020/Grids/age.2020.1.GTS2012.1m.nc"
  OC_AGE_CHECKFILE="age.2020.1.GTS2012.1m.nc"

  OC_AGE_CPT=$OC_AGE_DIR"age_2020.cpt"
  OC_AGE_CPT_URL="https://www.earthbyte.org/webdav/ftp/earthbyte/agegrid/2020/Grids/cpt/age_2020.cpt"
  OC_AGE_CPT_CHECKFILE="age_2020.cpt"

  if [[ " ${plots[@]} " =~ "oceanage" ]]; then
    check_and_download_dataset "${OC_AGE_URL}" "${OC_AGE_DIR}" "${OC_AGE_CHECKFILE}"
    check_and_download_dataset "${OC_AGE_CPT_URL}" "${OC_AGE_DIR}" "${OC_AGE_CPT_CHECKFILE}"
  fi

}

function tectoplot_calculate_geology()  {
  mkdir -p ./modules/geology/
}

function tectoplot_cpt_geology() {
  case $1 in
    geoage)
      if [[ $customocagecpt -eq 1 ]]; then
        gmt makecpt -C${OC_AGE_CPT} -Z ${VERBOSE} > ${GEOAGE_CPT}
      else
        cp ${CPTDIR}geoage.cpt ${GEOAGE_CPT}
        tectoplot_cpt_caught=1
      fi
    ;;
  esac
}

function tectoplot_plot_geology() {
  case $1 in

    # ebiso)
    #   echo gmt psxy ${EARTHBYTE_ISO} ${EBISOCOLOR} $RJOK ${VERBOSE}
    #   gmt psxy ${EARTHBYTE_ISO} ${EBISOCOLOR} $RJOK ${VERBOSE} >> map.ps
    #   tectoplot_plot_caught=1
    #   ;;

    # ebhot)
    #   gmt psxy ${EARTHBYTE_HOTSPOTS_GMT} -Sc0.1i -Gred $RJOK ${VERBOSE} >> map.ps
    #   tectoplot_plot_caught=1
    #   ;;

    m_geology_geo)

      gmt grdimage ${GLOBAL_GEO} $GRID_PRINT_RES -Q -t$GLOBAL_GEO_TRANS -fg $RJOK $VERBOSE >> map.ps

      tectoplot_plot_caught=1
      ;;

    m_geology_oca)

      gmt_init_tmpdir
      gmt grdcut ${OC_AGE} -R$MINLON/$MAXLON/$MINLAT/$MAXLAT -G./modules/geology/oceanage.nc -Vn
      gmt_remove_tmpdir

      zrange=($(grid_zrange ./modules/geology/oceanage.nc -C -Vn))

      # Set the range of the colorbar based on the range of the data

      # GEOAGE_COLORBAR_MIN=$(gawk -v endval="${zrange[0]}" '
      #   @include "tectoplot_functions.awk"
      #   BEGIN {
      #     print max(rd(endval, 10), 0)
      #   }')

      GEOAGE_COLORBAR_MAX=$(gawk -v endval="${zrange[1]}" '
        @include "tectoplot_functions.awk"
        BEGIN {
          print ru(endval, 10)
        }')

      if [[ ${m_geology_oca_stripeage[$tt]} -ne 0 ]]; then
        # Make a grayscale CPT from categorical and use for the intensity to show the color bars...?
        gmt makecpt -Ccategorical -T${GEOAGE_COLORBAR_MIN}/${GEOAGE_COLORBAR_MAX}/${m_geology_oca_stripeage[$tt]} ${VERBOSE} > ${F_CPTS}categ.cpt

        clean_cpt ${F_CPTS}categ.cpt > ${F_CPTS}cleangeoage.cpt
        grayscale_cpt ${F_CPTS}cleangeoage.cpt > ${F_CPTS}geogray.cpt

        gawk < ${F_CPTS}geogray.cpt '(NR==1) { oldx=$1; oldc=$2 } (NR>1 && $1+0==$1) { print oldx, oldc, $1, oldc; oldx=$1; oldc=$2 } ($1+0!=$1) { print }'  > ${F_CPTS}geoage_gray.cpt

        gmt grdimage ./modules/geology/oceanage.nc $GRID_PRINT_RES -C${F_CPTS}geoage_gray.cpt -t${m_geology_oca_trans[$tt]} -Q $RJOK $VERBOSE >> map.ps
      fi

      gmt grdimage ./modules/geology/oceanage.nc $GRID_PRINT_RES -C${GEOAGE_CPT} -Q -t${m_geology_oca_trans[$tt]} $RJOK $VERBOSE  >> map.ps

      echo $OC_AGE_SOURCESTRING >> ${LONGSOURCES}
      echo $OC_AGE_SHORT_SOURCESTRING >> ${SHORTSOURCES}

      tectoplot_plot_caught=1
      ;;

    tectonic_fabrics)
      for this_fabric in ${tectonic_fabrics[@]}; do
        case $this_fabric in
          cp)
            info_msg "[-tf]: Plotting continental polygons"
            gmt psxy ${TECTFABRICS_CP} -W0.1p,black+cf -aZ=PLATEID1 -C${PLATEID_CPT} $RJOK ${VERBOSE} >> map.ps
          ;;
          dz)
            info_msg "[-tf]: Plotting discordant zones"
            gmt psxy ${GSFML_DZ} -W0.5p,green $RJOK ${VERBOSE} >> map.ps
          ;;
          fz)
            info_msg "[-tf]: Plotting fracture zones"
            gmt psxy ${GSFML_FZ} -W0.5p,black $RJOK ${VERBOSE} >> map.ps
            gmt psxy ${GSFML_FZLC} -W0.3p,black $RJOK ${VERBOSE} >> map.ps
          ;;
          ht)
            info_msg "[-ht]: Plotting hotspots"
            gmt psxy ${EARTHBYTE_HOT} -Sc0.1i -Gred $RJOK ${VERBOSE} >> map.ps
          ;;
          is)
            info_msg "[-tf]: Plotting oceanic isochrons"
            gmt psxy ${EARTHBYTE_ISO} ${EBISOCOLOR} $RJOK ${VERBOSE} >> map.ps
          ;;
          pf)
            info_msg "[-tf]: Plotting pseudofaults"
            gmt psxy ${GSFML_PF} -W0.5p,orange $RJOK ${VERBOSE} >> map.ps
          ;;
          pr)
            info_msg "[-tf]: Plotting propagating ridges"
            gmt psxy ${GSFML_PR} -W0.5p,yellow $RJOK ${VERBOSE} >> map.ps
          ;;
          sr)
            info_msg "[-tf]: Plotting spreading ridges"
            gmt psxy ${TECTFABRICS_SR} -W0.5p,red $RJOK ${VERBOSE} >> map.ps
          ;;
          va)
            info_msg "[-tf]: Plotting v-shaped anomalies"
            gmt psxy ${GSFML_UNCV} -W0.5p,white $RJOK ${VERBOSE} >> map.ps
            gmt psxy ${GSFML_VANOM} -W0.5p,pink $RJOK ${VERBOSE} >> map.ps
          ;;
          vp)
            info_msg "[-tf]: Plotting volcanic provinces" # including extinct ridges"
            gmt psxy ${TECTFABRICS_VP} -W0.1p,black+cf -aZ=FROMAGE -C${GEOAGE_CPT} $RJOK ${VERBOSE} >> map.ps
          ;;
        esac
      done
      tectoplot_plot_caught=1
      ;;

  esac

}

function tectoplot_legendbar_geology() {
  case $1 in
    geoage)
      if [[ -e $GEOAGE_CPT && $madegeolegendbar -ne 1 ]]; then
        madegeolegendbar=1
        # Reduce the CPT to the used scale range

        # if [[ -s ${F_CPTS}geogray.cpt ]]; then
        #   gmt makecpt -C${F_CPTS}geogray.cpt -A${OC_TRANS} -Fr -G${GEOAGE_COLORBAR_MIN}/${GEOAGE_COLORBAR_MAX} -T${GEOAGE_COLORBAR_MIN}/${GEOAGE_COLORBAR_MAX}/${OC_STRIPE_AGE} ${VERBOSE} > ${F_CPTS}geoage_gray_colorbar.cpt
        #   echo "G 0.2i" >> ${LEGENDDIR}legendbars.txt
        #   echo "B ${F_CPTS}geoage_gray_colorbar.cpt 0.2i ${LEGEND_BAR_HEIGHT}+malu ${LEGENDBAR_OPTS} -Btlbr -Bxa1000" >> ${LEGENDDIR}legendbars.txt
        # fi

        gmt makecpt -C$GEOAGE_CPT -A${OC_TRANS} -Fr -G${GEOAGE_COLORBAR_MIN}/${GEOAGE_COLORBAR_MAX} -T${GEOAGE_COLORBAR_MIN}/${GEOAGE_COLORBAR_MAX}/10 ${VERBOSE} > ${F_CPTS}geoage_colorbar.cpt
        echo "G -0.195i" >> ${LEGENDDIR}legendbars.txt
        echo "B ${F_CPTS}geoage_colorbar.cpt 0.2i ${LEGEND_BAR_HEIGHT}+malu ${LEGENDBAR_OPTS} -Bx100f50+l\"Age (Ma)\"" >> ${LEGENDDIR}legendbars.txt
        barplotcount=$barplotcount+1
        tectoplot_caught_legendbar=1
      fi
      ;;
  esac
}

function tectoplot_legend_geology() {
  case $1 in
    tectonic_fabrics)
    for this_fabric in ${tectonic_fabrics[@]}; do
      init_legend_item "tectonic_fabrics_${this_fabric}"
      # Create a new blank map with the same -R -J as our main map

      EXTRALON=$(echo "$CENTERLON + (${MAXLON} - ${CENTERLON})/20" | bc -l)
      EXTRALON_M=$(echo "$CENTERLON - (${MAXLON} - ${CENTERLON})/20" | bc -l)

      EXTRALON2=$(echo "$CENTERLON + (${MAXLON} - ${CENTERLON})/20" | bc -l)
      EXTRALON3=$(echo "$CENTERLON - (${MAXLON} - ${CENTERLON})/2" | bc -l)


      echo $EXTRALON_M $CENTERLAT > line.txt
      echo $EXTRALON $CENTERLAT >> line.txt

      case $this_fabric in

        cp)
          gmt psxy line.txt -W0.1p,black -R -J -O -K ${VERBOSE} >> ${LEGFILE}
          echo "$CENTERLON $CENTERLAT Continental polygon" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE ${RJOK} -Y0.10i >> ${LEGFILE}
        ;;

        dz)
          gmt psxy line.txt  -W0.5p,green -R -J -O -K ${VERBOSE} >> ${LEGFILE}
          echo "$CENTERLON $CENTERLAT Discordant zone" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE ${RJOK} -Y0.10i >> ${LEGFILE}
        ;;

        fz)
          gmt psxy line.txt  -W0.5p,black -R -J -O -K ${VERBOSE} >> ${LEGFILE}
          echo "$CENTERLON $CENTERLAT Fracture zone" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE ${RJOK} -Y0.10i >> ${LEGFILE}
        ;;
        ht)
          echo ${CENTERLON} ${CENTERLAT} | gmt psxy -Sc0.1i -Gred -R -J -O -K ${VERBOSE} >> ${LEGFILE}
          echo "$CENTERLON $CENTERLAT Hotspot" | gmt pstext -F+f6p,Helvetica,black+jCM $VERBOSE ${RJOK} -X0.5i >> ${LEGFILE}
        ;;

        is)

C1=$(echo "$CENTERLON + 1*(${MAXLON} - ${CENTERLON})/100" | bc -l)
C5=$(echo "$CENTERLON + 5*(${MAXLON} - ${CENTERLON})/100" | bc -l)
C10=$(echo "$CENTERLON + 10*(${MAXLON} - ${CENTERLON})/100" | bc -l)
C15=$(echo "$CENTERLON + 15*(${MAXLON} - ${CENTERLON})/100" | bc -l)
C20=$(echo "$CENTERLON + 20*(${MAXLON} - ${CENTERLON})/100" | bc -l)

cat <<-EOF > isochron.txt
# @VGMT1.0 @GLINESTRING
# @R-180/180/-74.9045/89.8197
# @Je4326
# @Jp"+proj=longlat +datum=WGS84 +no_defs"
# @Jw"GEOGCS[\"WGS 84\",DATUM[\"WGS_1984\",SPHEROID[\"WGS 84\",6378137,298.257223563,AUTHORITY[\"EPSG\",\"7030\"]],AUTHORITY[\"EPSG\",\"6326\"]],PRIMEM[\"Greenwich\",0,AUTHORITY[\"EPSG\",\"8901\"]],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]],AXIS[\"Latitude\",NORTH],AXIS[\"Longitude\",EAST],AUTHORITY[\"EPSG\",\"4326\"]]"
# @NPLATEID1|FROMAGE
# @Tinteger|double
# FEATURE_DATA
>
# @D205|1
${CENTERLON} ${CENTERLAT}
${C1} ${CENTERLAT}
>
# @D206|30
${C1} ${CENTERLAT}
${C5} ${CENTERLAT}
>
# @D207|75
${C5} ${CENTERLAT}
${C10} ${CENTERLAT}
>
# @D208|150
${C10} ${CENTERLAT}
${C15} ${CENTERLAT}
>
# @D838|250
${C15} ${CENTERLAT}
${C20} ${CENTERLAT}
EOF

          gmt psxy isochron.txt ${EBISOCOLOR} $RJOK ${VERBOSE}  >> ${LEGFILE}
          echo "$EXTRALON2 $CENTERLAT Isochron" | gmt pstext -F+f6p,Helvetica,black+jLM $VERBOSE ${RJOK} -Y0.1i >> ${LEGFILE}
        ;;
        pf)
          gmt psxy line.txt -W0.5p,orange -R -J -O -K ${VERBOSE} >> ${LEGFILE}
          echo "$EXTRALON2 $CENTERLAT Psuedofault" | gmt pstext -F+f6p,Helvetica,black+jLM $VERBOSE ${RJOK} -Y0.10i >> ${LEGFILE}
        ;;
        pr)
          gmt psxy line.txt -W0.5p,yellow -R -J -O -K ${VERBOSE} >> ${LEGFILE}
          echo "$EXTRALON2 $CENTERLAT Propagating ridge" | gmt pstext -F+f6p,Helvetica,black+jLM $VERBOSE ${RJOK} -Y0.10i >> ${LEGFILE}
        ;;
        sr)
          gmt psxy line.txt -W0.5p,red -R -J -O -K ${VERBOSE} >> ${LEGFILE}
          echo "$EXTRALON2 $CENTERLAT Spreading ridge" | gmt pstext -F+f6p,Helvetica,black+jLM $VERBOSE ${RJOK} -Y0.10i >> ${LEGFILE}
        ;;
        va)
          gmt psxy line.txt -W0.5p,pink -R -J -O -K ${VERBOSE} >> ${LEGFILE}
          echo "$EXTRALON2 $CENTERLAT V-shaped anomaly" | gmt pstext -F+f6p,Helvetica,black+jLM $VERBOSE ${RJOK} -Y0.10i >> ${LEGFILE}
        ;;
        vp)

cat <<-EOF > blob.txt
0.003769102	0.017664679
-0.00148757	0.01959869
-0.007516059	0.023869588
-0.018242991	0.026997658
-0.034873152	0.029838496
-0.037934259	0.029323951
-0.048422736	0.02333353
-0.053559472	0.020709266
-0.057927704	0.015748257
-0.062950532	0.008564149
-0.060976418	0.005372509
-0.056257278	-0.003347142
-0.047165466	-0.00710556
-0.035442958	-0.011830659
-0.021642011	-0.014444581
-0.013099994	-0.015122902
-0.002143928	-0.017508586
0.003117723	-0.019442396
0.008380082	-0.021375791
0.015283567	-0.022680385
0.024600375	-0.024120388
0.035947838	-0.024755926
0.042275527	-0.023689734
0.048409776	-0.021564252
0.051186982	-0.018912929
0.052983691	-0.016184238
0.05006764	-0.013296432
0.046443645	-0.010735894
0.043036046	-0.007434098
0.036782353	-0.003907169
0.028115643	0.00132758
0.020658202	0.005709269
0.017254498	0.009012116
0.013775542	0.010924301
0.010016089	0.014135665
0.003769102	0.017664679
0.003769102	0.017664679
EOF

cat <<-EOF > volcprov.txt
# @VGMT1.0 @GMULTIPOLYGON
# @R-180/180/-86.1611995695/86.6826992038
# @Je4326
# @Jp"+proj=longlat +datum=WGS84 +no_defs "
# @Jw"GEOGCS[\"WGS 84\",DATUM[\"WGS_1984\",SPHEROID[\"WGS 84\",6378137,298.257223563,AUTHORITY[\"EPSG\",\"7030\"]],AUTHORITY[\"EPSG\",\"6326\"]],PRIMEM[\"Greenwich\",0,AUTHORITY[\"EPSG\",\"8901\"]],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]],AUTHORITY[\"EPSG\",\"4326\"]]"
# @NPLATEID1|FROMAGE
# @Tinteger|double
# FEATURE_DATA
EOF

scale=$(echo "(${MAXLON} - ${MINLON})/360 / 0.02" | bc -l)

gawk < blob.txt -v date=1 -v scale=${scale} -v xshift=0.1 -v clon=${CENTERLON} -v clat=${CENTERLAT} '
  BEGIN {
    print ">"
    print "# @D" int(date) "|" date
  }
  {
    print ($1+xshift)*scale+clon, $2*scale+clat
  }' >> volcprov.txt

gawk < blob.txt -v date=30 -v scale=${scale} -v xshift=0.3 -v clon=${CENTERLON} -v clat=${CENTERLAT} '
  BEGIN {
    print ">"
    print "# @D" int(date) "|" date
  }
  {
    print ($1+xshift)*scale+clon, $2*scale+clat
  }' >> volcprov.txt

  gawk < blob.txt -v date=75 -v scale=${scale} -v xshift=0.5 -v clon=${CENTERLON} -v clat=${CENTERLAT} '
  BEGIN {
    print ">"
    print "# @D" int(date) "|" date
  }
  {
    print ($1+xshift)*scale+clon, $2*scale+clat
  }' >> volcprov.txt

  gawk < blob.txt -v date=150 -v scale=${scale} -v xshift=0.7 -v clon=${CENTERLON} -v clat=${CENTERLAT} '
  BEGIN {
    print ">"
    print "# @D" int(date) "|" date
  }
  {
    print ($1+xshift)*scale+clon, $2*scale+clat
  }' >> volcprov.txt

  gawk < blob.txt -v date=250 -v scale=${scale} -v xshift=0.9 -v clon=${CENTERLON} -v clat=${CENTERLAT} '
  BEGIN {
    print ">"
    print "# @D" int(date) "|" date
  }
  {
    print ($1+xshift)*scale+clon, $2*scale+clat
  }' >> volcprov.txt


          gmt psxy volcprov.txt -W0.1p,black+cf -aZ=FROMAGE -C${GEOAGE_CPT} $RJOK ${VERBOSE} >> ${LEGFILE}
          echo "$EXTRALON2 $CENTERLAT Volcanic province" | gmt pstext -F+f6p,Helvetica,black+jLM $VERBOSE ${RJOK} -Y0.13i >> ${LEGFILE}

        ;;

      esac

      close_legend_item "tectonic_fabrics_${this_fabric}"

    done
    tectoplot_legend_caught=1
    ;;
  esac


}

# function tectoplot_post_geology() {
#   echo "none"
# }

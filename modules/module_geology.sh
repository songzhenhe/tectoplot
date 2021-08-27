
TECTOPLOT_MODULES+=("geology")

# Geological data (ocean age, transform fault, etc.)


function tectoplot_defaults_geology() {

  ##### Oceanic crustal age data (Seton et al. 2020)
  OC_AGE_DIR=$DATAROOT"OC_AGE/"
  OC_AGE=$OC_AGE_DIR"age.2020.1.GTS2012.1m.nc"
  OC_AGE_URL="https://www.earthbyte.org/webdav/ftp/earthbyte/agegrid/2020/Grids/age.2020.1.GTS2012.1m.nc"
  OC_AGE_BYTES="215659543"

  OC_AGE_CPT=$OC_AGE_DIR"age_2020.cpt"
  OC_AGE_CPT_URL="https://www.earthbyte.org/webdav/ftp/earthbyte/agegrid/2020/Grids/cpt/age_2020.cpt"
  OC_AGE_CPT_BYTES="1062"

  OC_AGE_SOURCESTRING="Oceanic crustal age from Seton et al., 2020, https://www.earthbyte.org/webdav/ftp/earthbyte/agegrid/2020/Grids/age.2020.1.GTS2012.1m.nc"
  OC_AGE_SHORT_SOURCESTRING="OCA"

  TECTFABRICSDIR=${PLATEMODELSDIR}"TectonicFabrics/"

  GLOBAL_GEO=${TECTFABRICSDIR}"Global_Geology/Global_Geology.tif"
  GLOBAL_GEO_TRANS=0

  EARTHBYTE_SOURCESTRING="EarthByte data from GPlates2.2.0, converted to GMT format using GPlates: https://www.earthbyte.org/gplates-2-2-software-and-data-sets/"
  EARTHBYTE_SHORT_SOURCESTRING="EarthByte"

  # Discordant zones
  EARTHBYTE_DZ=${TECTFABRICSDIR}"DZ.gmt"

  # Extinct Ridges (not used)
  EARTHBYTE_ER=${TECTFABRICSDIR}"ER.gmt"

  # Fracture Zones
  EARTHBYTE_FZ=${TECTFABRICSDIR}"FZ.gmt"
  EARTHBYTE_FZLC=${TECTFABRICSDIR}"FZLC.gmt"

  # Pseudofaults
  EARTHBYTE_PF=${TECTFABRICSDIR}"PF.gmt"

  # Propagating ridges
  EARTHBYTE_PR=${TECTFABRICSDIR}"PR.gmt"

  # Unclassified V-anomalies
  EARTHBYTE_UNCV=${TECTFABRICSDIR}"UNCV.gmt"

  # V-shaped structures
  EARTHBYTE_VANOM=${TECTFABRICSDIR}"VANOM.gmt"

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
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-geo:          plot global geology raster file as image
-geo

Example:
  tectoplot -r g -geo
--------------------------------------------------------------------------------
EOF
fi
  shift
  plots+=("globalgeo")
  tectoplot_module_caught=1
  ;;

  -oca)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-oca:          plot ocean crust age raster
-oca [[transparency]] [[cpt]]

  transparency is in percent
  cpt is the filename of a CPT file to use (default is geoage)

Example:
  tectoplot -RJ S 120 20 -t 01d -oca
--------------------------------------------------------------------------------
EOF
fi

    shift

    echo $OC_AGE_SOURCESTRING >> ${LONGSOURCES}
    echo $OC_AGE_SHORT_SOURCESTRING >> ${SHORTSOURCES}

    if arg_is_flag $1; then
      info_msg "[-oc]: No transparency set. Using default $OC_TRANS"
    else
      OC_TRANS="${1}"
      shift
      ((tectoplot_module_shift++))
    fi
    if arg_is_flag $1; then
      info_msg "[-oc]: No ocean age CPT specified. Using $OCA_CPT"
    else
      customocagecpt=1
      OC_AGE_CPT="${1}"
        # cp $(abs_path ${1}) custom_oca.cpt
        # OCA_CPT=custom_oca.cpt
      shift
      ((tectoplot_module_shift++))
    fi

    plots+=("oceanage")
    cpts+=("geoage")

    legendbarwords+=("geoage")
    tectoplot_module_caught=1
    ;;

  # Plot tectonic fabrics
  -tf)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tf:           plot tectonic fabrics
-tf [code1] [[code2]] ...

  codes
  all: Plot all codes except cp

  cp: continental polygons (Matthews et al., 2016; via Gplates2.2.0)
  dz: discordant zones (EarthByte)
  fz: fracture zones (EarthByte)
  ht: hotspots (EarthByte)
  is: oceanic isochrons (EarthByte)
      [[linewidth]] [[color]]
  pf: pseudo faults (EarthByte)
  pr: propagating ridges (EarthByte)
  sr: spreading ridges (active and extinct) (Muller et al., 2016; via Gplates2.2.0)
  va: v-anomalies, classified and unclassified (EarthByte)
  vp: volcanic provinces (Johansson et al., 2018; via Gplates2.2.0)

Example: None
--------------------------------------------------------------------------------
EOF
fi

  shift
  unset tectonic_fabrics
  if [[ "${1}" == "all" ]]; then
    tectonic_fabrics+=("vp")
    tectonic_fabrics+=("dz")
    tectonic_fabrics+=("fz")
    tectonic_fabrics+=("ht")
    tectonic_fabrics+=("pf")
    tectonic_fabrics+=("pr")
    tectonic_fabrics+=("sr")
    tectonic_fabrics+=("va")
    tectonic_fabrics+=("is")

    cpts+=("geoage")
    plots+=("geoage")  # Fake

    echo $EARTHBYTE_SOURCESTRING >> ${LONGSOURCES}
    echo $EARTHBYTE_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $TECTFABRICS_SR_SOURCESTRING >> ${LONGSOURCES}
    echo $TECTFABRICS_SR_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $TECTFABRICS_VP_SOURCESTRING >> ${LONGSOURCES}
    echo $TECTFABRICS_VP_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    shift
    ((tectoplot_module_shift++))
  else
    while ! arg_is_flag "${1}"; do
        case "${1}" in
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
            # plots+=("fracturezones")
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

            if ! arg_is_flag "${2}"; then
              EBISOWIDTH="${2}"
              shift
              ((tectoplot_module_shift++))
            fi

            if ! arg_is_flag "${2}"; then
              EBISOCOLOR="-W${EBISOWIDTH},${2}"
              shift
              ((tectoplot_module_shift++))
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
        esac
    shift
    ((tectoplot_module_shift++))
    done
  fi

  if [[ $makegeoageflag -eq 1 ]]; then
    cpts+=("geoage")
    plots+=("geoage")  # Fake
  fi

  plots+=("tectonic_fabrics")

  tectoplot_module_caught=1
  ;;

  esac
}

# We download the relevant data in the _calculate_ function as this is the first time we should
# be accessing the data itself.

# function tectoplot_calculate_geology()  {
#
# }

function tectoplot_cpt_geology() {
  case $1 in
  geoage)
    if [[ $customocagecpt -eq 1 ]]; then
      gmt makecpt -C${OC_AGE_CPT} -T${GEOAGE_COLORBAR_MIN}/${GEOAGE_COLORBAR_MAX}/1 -Z > ${GEOAGE_CPT}
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

    globalgeo)
      gmt grdimage ${GLOBAL_GEO} $GRID_PRINT_RES -t$GLOBAL_GEO_TRANS $RJOK $VERBOSE >> map.ps

      tectoplot_plot_caught=1
      ;;

    oceanage)
      gmt grdimage $OC_AGE $GRID_PRINT_RES -C${GEOAGE_CPT} -Q -t$OC_TRANS $RJOK $VERBOSE >> map.ps
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
            gmt psxy ${EARTHBYTE_DZ} -W0.5p,green $RJOK ${VERBOSE} >> map.ps
          ;;
          fz)
            info_msg "[-tf]: Plotting fracture zones"
            gmt psxy ${EARTHBYTE_FZ} -W0.5p,black $RJOK ${VERBOSE} >> map.ps
            gmt psxy ${EARTHBYTE_FZLC} -W0.3p,black $RJOK ${VERBOSE} >> map.ps
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
            gmt psxy ${EARTHBYTE_PF} -W0.5p,orange $RJOK ${VERBOSE} >> map.ps
          ;;
          pr)
            info_msg "[-tf]: Plotting propagating ridges"
            gmt psxy ${EARTHBYTE_PR} -W0.5p,yellow $RJOK ${VERBOSE} >> map.ps
          ;;
          sr)
            info_msg "[-tf]: Plotting spreading ridges"
            gmt psxy ${TECTFABRICS_SR} -W0.5p,red $RJOK ${VERBOSE} >> map.ps
          ;;
          va)
            info_msg "[-tf]: Plotting v-shaped anomalies"
            gmt psxy ${EARTHBYTE_UNCV} -W0.5p,white $RJOK ${VERBOSE} >> map.ps
            gmt psxy ${EARTHBYTE_VANOM} -W0.5p,pink $RJOK ${VERBOSE} >> map.ps
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
      if [[ -e $GEOAGE_CPT ]]; then

        # Reduce the CPT to the used scale range
        # cp $GEOAGE_CPT ${F_CPTS}geoage_colorbar.cpt
        gmt makecpt -C$GEOAGE_CPT -G${GEOAGE_COLORBAR_MIN}/${GEOAGE_COLORBAR_MAX} -T${GEOAGE_COLORBAR_MIN}/${GEOAGE_COLORBAR_MAX}/10 ${VERBOSE} > ${F_CPTS}geoage_colorbar.cpt
        #

        echo "G 0.2i" >> legendbars.txt
        echo "B ${F_CPTS}geoage_colorbar.cpt 0.2i 0.1i+malu -Bxa100f50+l\"Age (Ma)\"" >> legendbars.txt
        barplotcount=$barplotcount+1
        tectoplot_caught_legendbar=1
      fi
      ;;
  esac
}

# function tectoplot_legend_geology() {
# }

# function tectoplot_post_geology() {
#   echo "none"
# }

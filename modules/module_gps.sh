# We want to plot GPS data, drawing from a variety of datasets:

# 1. User-specified GPS datasets
# 2. MIDAS data which is updated often and is consistently treated
# 3. Compilations of interseismic velocitiy (Kreemer et al., 2014)

# We should be able to plot multiple datasets with different styling
# We should handle vertical velocities and errors for all data

# We should handle reference frame transformations ourselves when possible

# All GPS datasets need to be transformed to the following format:
# lon lat elev ve vn vu sve svn svu encorr nucorr eucorr id refstring

# <---- gmt psvelo format ------> <---- extended format ------->
# 1   2   3  4  5   6   7      8  9  10  11     12     13
# lon lat ve vn sve svn encorr id vu svu nucorr eucorr refstring

TECTOPLOT_MODULES+=("gps")

# UPDATED
# DOWNLOAD
# NEW OPT

function tectoplot_defaults_gps() {
  m_gps_midas_sourcestring="MIDAS GPS velocity data retrieved from http://geodesy.unr.edu/velocities/: Blewitt, G., W. C. Hammond, and C. Kreemer (2018), doi:10.1029/2018EO104623. Plate rotation poles are from Kreemer et al., 2014 doi:10.1002/2014GC005407."
  m_gps_midas_short_sourcestring="MIDAS"
  m_gps_midas_dir="${DATAROOT}midas/"
  m_gps_midas_file="${m_gps_midas_dir}midas.gpkg"

  m_gps_gsrm_sourcestring="GPS velocities from GSRM: Kreemer et al., 2014 doi:10.1002/2014GC005407."
  m_gps_gsrm_short_sourcestring="GSRM"
  m_gps_gsrm_dir="${PLATEMODELSDIR}/GSRM/"
  m_gps_gsrm_file="${m_gps_gsrm_dir}GPS_ITRF08.gmt"
}

function tectoplot_args_gps()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -gref)
  tectoplot_get_opts_inline '
des -gref list available reference plates (assuming data are in IGS08 or IGS14)
' "${@}" || return

  ;;

  -g2)
  tectoplot_get_opts_inline '
des -g2 plot GPS velocities
opt file m_gps_userfile file "none"
  use a custom data file instead of default (MIDAS) dataset
opt ref m_gps_ref word "none"
  use plate with specified ID as the reference plate; "none": no transformation; "plate":use plate at plot reference point
opt maxerr m_gps_maxerror float 9999
  remove velocities with N or E uncertainty larger than given value (mm/yr)
opt noplot m_gps_noplotflag flag 0
  prevent plotting of the GPS velocities
opt fill m_gps_fill string "black"
  set the fill color
opt linewidth m_gps_linewidth float 0
  set the line stroke width (p)
opt linewidth m_gps_linecolor string "black"
  set the line stroke color
opt cpt m_gps_cpt word "none"
  color GPS vectors by velocity
opt legvel m_gps_legvel float 0
  set the scale of the velocity arrow shown in the legend
opt text m_gps_textflag flag 0
  plot velocity text (mm/yr) for each arrow
opt sitetext m_gps_sitetextflag flag 0
  plot site ID text next to each arrow
opt fontsize m_gps_fontsize string 6
  set font size for plotted velocity text
opt font m_gps_font string "Helvetica"
  set font for plotted velocity text
opt fontcolor m_gps_fontcolor string "black"
  set font color for plotted velocity text
opt zcol m_gps_zcolumn float 0
  set column number for Z values used to color arrows (first column is 1)
opt colorunit m_gps_cptunit string "mm/yr"
  define the units used to label colorbar and arrows
opt addword m_gps_addword string ""
  add a word between GPS and velocity in colorbar legend (e.g. vertical)
opt arrow m_gps_arrow string "default"
  set arrow format (same arguments as -arrow)
opt vertbar m_gps_vertscale float 0
  if nonzero, plot vertical bars only (can layer -g2 calls) 
opt circle m_gps_circleflag flag 0
  plot a white circle with black stroke at site location
mes User-specified GPS velocity data are plain text with whitespace separated columns:
mes Lon Lat E N SE SN corr ID Reference
mes   E, N are velocities to the East and North, in mm/yr
mes   SE, SN are uncertainties of E,N components in mm/yr
mes   corr is the correlation between SE and SN
mes   ID is the site ID string
mes   Reference is a string, usually a reference to the data source
mes   Note: If -pg is active then data are selected inside that polygon
exa tectoplot -r =EU -a -g2
' "${@}" || return

  calcs+=("m_gps_g2")   
  plots+=("m_gps_g2")
  cpts+=("m_gps_g2")

  ;;

  -gx)
    tectoplot_get_opts_inline '
des -gx plot along-profile and across-profile GPS velocities
mes plot gps projected onto profiles
  ' "${@}" || return
  after_plots+=("m_gps_gx")
  ;;

  -gmat)
    tectoplot_get_opts_inline '
des -gmat construct matrix and vector for least squares estimation of Euler pole
opn list m_gps_lsq_list list ""
  list of sites
  ' "${@}" || return
  after_plots+=("m_gps_gmat")
  ;;

    -gg2)
    tectoplot_get_opts_inline '
des -gg2 interpolate GPS velocities using GMT gpsgridder module
opt res m_gps_gg2_res word "2m"
    spacing of interpolation points
opt poisson m_gps_gg2_poisson float 0.5
    Poissons ration for elasting Greens functions (0 to 1)
opt residuals m_gps_gg2_residflag flag 0
    plot GPS residual velocities (data - prediction)
opt noave m_gps_gg2_noaveflag flag 0
    do not plot interpolated velocity vectors
opt noave0 m_gps_gg2_noave0flag flag 0
    do not plot interpolated velocity vectors with 0 nearby data points
opt subsample m_gps_gg2_subsample float 1
    subsample velocity arrows by the specified factor
opt maxshear m_gps_gg2_maxshearflag flag 0
    plot grid of maximum shear strain rate
opt secinv m_gps_gg2_secinvflag flag 0
    plot grid of second invariant of strain rate tensor
opt strdil m_gps_gg2_strdilflag flag 0
    plot dilatation of strain rate tensor grid
opt rot m_gps_gg2_rot flag 0
    plot rotation rate grid 
opt cross m_gps_gg2_cross flag 0
    plot strain crosses
opt grdtrans m_gps_gg2_trans float 0
    transparency of grid plots
mes  poisson is Poissons ratio for the elastic Greens functions (0-1)
mes  Duplicated GPS sites are culled, keeping first
  ' "${@}" || return

  calcs+=("m_gps_gg2")
  cpts+=("m_gps_gg2")
  plots+=("m_gps_gg2")
  ;;

  esac

}

# We create GPKG databases out of some global GPS datasets

function tectoplot_download_gps() {

  if [[ ! -d "${m_gps_midas_dir}" ]]; then
    echo "Creating MIDAS data directory ${m_gps_midas_dir}"
    mkdir -p "${m_gps_midas_dir}"
  fi

  if [[ ! -s "${m_gps_midas_dir}midas.gpkg" ]]; then 
    echo "Downloading global MIDAS IGS14 dataset"
    if [[ ! -s "${m_gps_midas_dir}midas.IGS14.txt" ]]; then
      if ! curl "http://geodesy.unr.edu/velocities/midas.IGS14.txt" > "${m_gps_midas_dir}midas.IGS14.txt"; then
        echo "Error downloading file. Removing."
        rm -f "${m_gps_midas_dir}midas.IGS14.txt"
        return
      fi
    fi

# The MIDAS velocity files are automatically updated weekly from the GPS time series generated by the Nevada Geodetic Laboratory.
# Columns on the MIDAS velocity files are as follows:
# column 1 - 4 character station ID
# column 2 - MIDAS version label 
# column 3 - time series first epoch, in decimal year format. 
# column 4 - time series last epoch, in decimal year format (See http://geodesy.unr.edu/NGLStationPages/decyr.txt for translation to YYMMMDD format).
# column 5 - time series duration (years).
# column 6 - number of epochs of data, used or not
# column 7 - number of epochs of good data, i.e. used in at least one velocity sample 
# column 8 - number of velocity sample pairs used to estimate midas velocity
# column 9-11 - east, north, up mode velocities (m/yr)
# column 12-14 - east, north, up mode velocity uncertainties (m/yr)
# column 15-17 - east, north, up offset at at first epoch (m)
# column 18-20 - east, north, up fraction of outliers
# colums 21-23 - east, north, up standard deviation velocity pairs 
# column 24 - number of steps assumed, determined from our steps database
# column 25-27 - latitude (degrees), longitude (degrees) and height (m) of station.

cat <<-EOF > "${m_gps_midas_dir}"midas.vrt
<OGRVRTDataSource>
    <OGRVRTLayer name="midas">
        <SrcDataSource>midas.csv</SrcDataSource>
        <GeometryField encoding="PointFromColumns" x="lon" y="lat" z="elev"/>
        <GeometryType>wkbPoint</GeometryType>
        <LayerSRS>EPSG:4979</LayerSRS>
        <Field name="name" type="String"/>
        <Field name="version" type="String"/>
        <Field name="epochstart" type="Real"/>
        <Field name="epochend" type="Real"/>
        <Field name="epochdur" type="Real"/>
        <Field name="epochnum" type="Integer"/>
        <Field name="epochgood" type="Integer"/>
        <Field name="sumsamples" type="Integer"/>
        <Field name="e_m_yr" type="Real"/>
        <Field name="n_m_yr" type="Real"/>
        <Field name="u_m_yr" type="Real"/>
        <Field name="se_m_yr" type="Real"/>
        <Field name="sn_m_yr" type="Real"/>
        <Field name="su_m_yr" type="Real"/>
        <Field name="e_offset1_m" type="Real"/>
        <Field name="n_offset1_m" type="Real"/>
        <Field name="u_offset1_m" type="Real"/>
        <Field name="e_outlier_frac" type="Real"/>
        <Field name="n_outlier_fram" type="Real"/>
        <Field name="u_outlier_frac" type="Real"/>
        <Field name="e_sd_vpair" type="Real"/>
        <Field name="n_sd_vpair" type="Real"/>
        <Field name="u_sd_vpair" type="Real"/>
        <Field name="nsteps" type="Integer"/>
        <Field name="lat" type="Real"/>
        <Field name="lon" type="Real"/>
        <Field name="elev" type="Real"/>
    </OGRVRTLayer>
</OGRVRTDataSource>
EOF

    echo "name,version,epochstart,epochend,epochdur,epochnum,epochgood,sumsamples,e_m_yr,n_m_yr,u_m_yr,se_m_yr,sn_m_yr,su_m_yr,e_offset1_m,n_offset1_m,u_offset1_m,e_outlier_frac,n_outlier_fram,u_outlier_frac,e_sd_vpair,n_sd_vpair,u_sd_vpair,nsteps,lat,lon,elev" > "${m_gps_midas_dir}"midas.csv
    gawk < "${m_gps_midas_dir}midas.IGS14.txt" '{OFS=","; $26=$26+0; while($26<-180) { $26=$26+360 }; while($26>180) {$26=$26-360}; print $0}' >> "${m_gps_midas_dir}"midas.csv
    rm -f "${m_gps_midas_dir}"midas.gpkg

    (
      cd "${m_gps_midas_dir}"
      ogr2ogr -f "GPKG" -nln midas midas.gpkg midas.vrt 
    )
  fi

  if [[ ! -s "${m_gps_midas_dir}poles.IGS08" ]]; then
    echo "Downloading MIDAS Euler poles"
    if ! curl "http://geodesy.unr.edu/GSRM/poles.IGS08" > "${m_gps_midas_dir}poles.IGS08"; then
      echo "Error downloading file. Removing."
      rm -f "${m_gps_midas_dir}poles.IGS08"
    fi
  fi
}

# function tectoplot_calculate_gps()  {
# }

function tectoplot_calc_gps()  {

  case $1 in
    m_gps_g2)
    tectoplot_calc_caught=1

  # This section transforms default (MIDAS) or user-specified data into plottable GPS velocities
  # $REFPLATE is the reference plate set by -p MORVEL 
  # If we have requested a reference frame conversion

  if [[ -s ${m_gps_userfile[$tt]} ]]; then
    m_gps_file[$tt]=$(abs_path ${m_gps_userfile[$tt]})
    info_msg "Selected user GPS file ${m_gps_userfile[$tt]}"
  elif [[ -s ${m_gps_midas_file} || -s ${m_gps_gsrm_file} ]]; then

    # By default, we select MIDAS data and then add the Kreemer 2014 data

    if [[ -s ${m_gps_midas_file} ]]; then
      info_msg "Selecting data within AOI from MIDAS GPS file"
      ogr2ogr_spat ${MINLON} ${MAXLON} ${MINLAT} ${MAXLAT} midas_selected_${tt}.gpkg ${m_gps_midas_file} 
      ogr2ogr -f "CSV" -lco SEPARATOR=TAB -dialect sql -sql "SELECT lon, lat, e_m_yr*1000, n_m_yr*1000, se_m_yr*1000, sn_m_yr*1000, 0, name, u_m_yr*1000, su_m_yr*1000, elev FROM midas WHERE ABS(n_m_yr) < 1 AND ABS(e_m_yr) < 1 AND ABS(u_m_yr) < 1" /vsistdout/ midas_selected_${tt}.gpkg | gawk '
        BEGIN {
          OFS="\t"
        }
        (NR>1) {
          name=sprintf("0\t0\t%s\tMIDAS", $(NF))
          $(NF)=name
          print $0
        }' > midas_${tt}.txt
    fi
    # <---- gmt psvelo format ------> <---- extended format ------->
    # 1   2   3  4  5   6   7      8  9  10  11   12     13     14
    # lon lat ve vn sve svn encorr id vu svu elev nucorr eucorr refstring

    if [[ -s ${m_gps_gsrm_file} ]]; then
      info_msg "Selecting data within AOI from GSRM GPS file"
      gmt select ${m_gps_gsrm_file} ${rj[0]} -Vn -f0x,1y,s | gawk '
      {
        #     lon lat ve  vn  sve svn encorr id           vu svu elev nucorr eucorr refstring      
        print $1, $2, $3, $4, $5, $6, $7,    tolower($8), 0, 0,  0,   0,     0,     $9
      }' > gsrm_${tt}.txt
    fi

    # For now, combine the files into a standard PSVELO format file, filtering based on uncertainties and preferring MIDAS sites
    touch midas_${tt}.txt gsrm_${tt}.txt
    cat midas_${tt}.txt  | gawk '
        {
          if (id[tolower($8)]!=1) {
            id[tolower($8)]=1
            if ($5 <= '${m_gps_maxerror[$tt]}' && $6 <= '${m_gps_maxerror[$tt]}') {
              print
            }
          }
        }' > combined_midas.txt

      cat gsrm_${tt}.txt  | gawk '
        {
          if (id[tolower($8)]!=1) {
            id[tolower($8)]=1
            if ($5 <= '${m_gps_maxerror[$tt]}' && $6 <= '${m_gps_maxerror[$tt]}') {
              print
            }
          }
        }' > combined_gsrm.txt

    if [[ $(echo "$(wc -l < combined_midas.txt) > 0" | bc -l) -eq 1 ]]; then
      echo ${m_gps_midas_short_sourcestring} >> $SHORTSOURCES
      echo ${m_gps_midas_sourcestring} >> $LONGSOURCES
    fi

    if [[ $(echo "$(wc -l < combined_gsrm.txt) > 0" | bc -l) -eq 1 ]]; then
      echo ${m_gps_gsrm_short_sourcestring} >> $SHORTSOURCES
      echo ${m_gps_gsrm_sourcestring} >> $LONGSOURCES
    fi

    cat combined_midas.txt combined_gsrm.txt > combined_${tt}.txt
    rm -f combined_midas.txt combined_gsrm.txt
    m_gps_file[$tt]=combined_${tt}.txt

  else
    echo "[-g2]: no data files found"
    return
  fi

  # Select by polygon if specified
  if [[ -s ${POLYGONAOI} ]]; then
    info_msg "[-g2]: Selecting sites within ${POLYGONAOI}"
    gmt select ${m_gps_file[$tt]} -F${POLYGONAOI} -Vn -f0x,1y,s | tr '\t' ' ' > ${F_GPS}gps_polygon_${tt}.txt
    m_gps_file[$tt]=${F_GPS}gps_polygon_${tt}.txt
  fi

  m_gps_pole[$tt]="none"
  if [[ ${m_gps_ref[$tt]} != "none" ]]; then
    info_msg "[-g2]: Searching for Euler pole ${m_gps_ref[$tt]} in file ${m_gps_midas_dir}poles.IGS08"
    m_gps_pole[$tt]=$(gawk < ${m_gps_midas_dir}poles.IGS08 '
      ( tolower($4)==tolower("'${m_gps_ref[$tt]}'") ) {
        print $1, $2, $3
      }')
  fi

  # If calculating least squares Euler pole for selected sites, do that

  if [[ ! -z ${m_gps_lsq_list[0]} && m_gps_gotsites -ne 1 ]]; then
    m_gps_gotsites=1
    if [[ ${m_gps_lsq_list[0]} == "all" ]]; then
      m_gps_lsq_list=($(gawk < ${m_gps_file[$tt]} '{print $8}'))
    fi
    info_msg "Calculating Euler pole using least squares on: ${m_gps_lsq_list[@]}"
    for this_site in ${m_gps_lsq_list[@]}; do
      gawk < ${m_gps_file[$tt]} -v site=${this_site} '
      @include "tectoplot_functions.awk"
      { 
        if ($8==site) {
          # Lon Lat E N SE SN corr ID Reference

          # We read the site latitude and longitude
          tLat_r_adj=deg2rad($2)
          tLon_r=deg2rad($1)
          
          # Site velocities are in mm/yr
          E1=$3
          N1=$4

          # Rotation matrix to transform NEU to ECEF coordinates
          R11 = -sin(tLat_r_adj)*cos(tLon_r)
          R12 = -sin(tLat_r_adj)*sin(tLon_r)
          R13 = cos(tLat_r_adj)
          R21 = -sin(tLon_r)
          R22 = cos(tLon_r)
          R23 = 0
          R31 = cos(tLat_r_adj)*cos(tLon_r)
          R32 = cos(tLat_r_adj)*sin(tLon_r)
          R33 = sin(tLat_r_adj)

          # N1 is NORTH and E1 is east and U1 is UP
          # Vx1 = R11*N1 + R21*E1 + R31 * U1
          # Vy1 = R12*N1 + R22*E1 + R32 * U1
          # Vz1 = R13*N1 + R23*E1 + R33 * U1

          # We do not consider vertical motions for Euler pole fitting, so L3 = 0

          Vx1 = R11*N1 + R21*E1
          Vy1 = R12*N1 + R22*E1
          Vz1 = R13*N1 + R23*E1

          r=6378

          X1 = r*R31
          Y1 = r*R32
          Z1 = r*R33

          # |Vx1|      |0    Z1  -Y1|  
          # |Vy1|      |-Z1   0   X1|  
          # |Vz1|      |Y1  -X1    0|  

          print Vx1 >> "gps_gmat_vec.txt"
          print Vy1 >> "gps_gmat_vec.txt"
          print Vz1 >> "gps_gmat_vec.txt"

          print 0  >> "gps_gmat_mat.txt"
          print Z1  >> "gps_gmat_mat.txt"
          print 0-Y1 >> "gps_gmat_mat.txt"
          print 0-Z1 >> "gps_gmat_mat.txt"
          print 0 >> "gps_gmat_mat.txt"
          print X1 >> "gps_gmat_mat.txt"
          print Y1 >> "gps_gmat_mat.txt"
          print 0-X1 >> "gps_gmat_mat.txt"
          print 0 >> "gps_gmat_mat.txt"
        }
      }
      END {
        print "1" >> "gps_gmat_mn.txt"
      }' 
    done

    # Number of rows is the number of sites times 3
    wc -l < gps_gmat_mn.txt | gawk '{print $1*3}' > gps_gmat_mn_actual.txt
    # Number of columns is 3
    echo "3" >> gps_gmat_mn_actual.txt
    cat gps_gmat_mn_actual.txt gps_gmat_vec.txt gps_gmat_mat.txt | ${TECTOPLOTDIR}cscripts/qrsolve/gps_solve > euler_bestfit.txt
    gawk < euler_bestfit.txt '
    @include "tectoplot_functions.awk"
    {
      a1=$1
      a2=$2
      a3=$3
      eVA = sqrt(a1*a1+a2*a2+a3*a3)

      if (eVA == 0) {
        elat_rA = 0
        elon_rA = 0
      }
      else {
        elat_rA = asin(a3/eVA)
        elon_rA = atan2(a2,a1)
      }
      print rad2deg(elat_rA), rad2deg(elon_rA), rad2deg(eVA)
    }' > euler_pole_${tt}.txt
    m_gps_pole[$tt]=$(cat euler_pole_${tt}.txt) 
  fi

  # Rotate the data into the desired reference frame
  if [[ $gpscorflag -eq 1 ]]; then
    m_gps_pole[$tt]=$(echo ${gpscorlat} ${gpscorlon} ${gpscorw})
  fi

  if [[ ${m_gps_pole[$tt]} != "none" ]]; then
    polevec=($(echo ${m_gps_pole[$tt]}))
    gawk '
      @include "tectoplot_functions.awk"
      ($1+0==$1) {
        eulervec('${polevec[0]}', '${polevec[1]}', '${polevec[2]}', 0, 0, 0, $1, $2)
        print $1, $2, $3-eulervec_E, $4-eulervec_N, $5, $6, $7, $8, $9
      }
    ' ${m_gps_file[$tt]} > gps_rotated_${tt}.dat 
    m_gps_file[$tt]=gps_rotated_${tt}.dat 
    info_msg "[-g2]: Applied Euler pole ${polevec[0]} ${polevec[1]} ${polevec[2]} to GPS data ${m_gps_file[$tt]}, new file is ${m_gps_file[$tt]}"
  fi

  # Create the XY file
  gawk '
  {
    az=atan2($3, $4) * 180 / 3.14159265358979
    if (az > 0) {
      print $1, $2, az, sqrt($3*$3+$4*$4), $8
    } else {
      print $1, $2, az+360, sqrt($3*$3+$4*$4), $8
    }
  }' ${m_gps_file[$tt]} > ${F_GPS}gps_${tt}.xy
  m_gps_xyfile[$tt]=${F_GPS}gps_${tt}.xy

  if [[ ${m_gps_zcolumn[$tt]} -ne 0 ]]; then
    # We use the data column from the original file
    m_gps_minvel[$tt]=$(gawk < ${m_gps_file[$tt]} 'BEGIN{ minv=9999 } {if ($'${m_gps_zcolumn[$tt]}'<minv) {minv=$'${m_gps_zcolumn[$tt]}' } } END {print minv}')
    m_gps_maxvel[$tt]=$(gawk < ${m_gps_file[$tt]} 'BEGIN{ maxv=-9999 } {if ($'${m_gps_zcolumn[$tt]}'>maxv) { maxv=$'${m_gps_zcolumn[$tt]}' } } END {print maxv}')
    m_gps_legvel[$tt]=$(gawk '
      function abs(v)        { return v < 0 ? -v : v          }
      function max(x,y)      { return (x>y)?x:y               }
      BEGIN {
        print max(abs('${m_gps_maxvel[$tt]}'), abs('${m_gps_minvel[$tt]}'))
      }')
  else
    # We use the derived velocity from the XY file
    m_gps_minvel[$tt]=0
    m_gps_maxvel[$tt]=$(gawk < ${m_gps_xyfile[$tt]}  'BEGIN{ maxv=0 } {if ($4>maxv) { maxv=$4 } } END {print maxv+1}')
    m_gps_legvel[$tt]=${m_gps_maxvel[$tt]}
  fi

  # Interface to old GPS code to keep other things working for now
  GPS_FILE=${m_gps_file[$tt]}
  plotgps=1

  # Add GPS data to the profile request
  echo "D ${m_gps_file[$tt]} 1 -Sc0.1i -Gblack" >>  ${F_PROFILES}profile_commands.txt

  ;;
  esac
}

function tectoplot_cpt_gps() {
  case $1 in
    m_gps_g2)
    if [[ ${m_gps_cpt[$tt]} != "none" ]]; then
      gmt makecpt -C${m_gps_cpt[$tt]} -I -Do -T${m_gps_minvel[$tt]}/${m_gps_maxvel[$tt]} -Z -N $VERBOSE > ${F_CPTS}gps_${tt}.cpt
      m_gps_cpt_used[$tt]=${F_CPTS}gps_${tt}.cpt
      tectoplot_cpt_caught=1
    fi
    ;;
    m_gps_gg2)
      if [[ ${m_gps_gg2_maxshearflag[$tt]} -eq 1 ]]; then
        gmt makecpt -Fr -T0/300/0.1 -Z -Cjet > shear.cpt
      elif [[ ${m_gps_gg2_secinvflag[$tt]} -eq 1 ]]; then
        gmt makecpt -Fr -T1/2000/1+l -Q -Z -D -Cjet > ${F_CPTS}secinv.cpt
      fi
      tectoplot_cpt_caught=1
    ;;
  esac
}

function tectoplot_plot_gps() {
  case $1 in
    m_gps_g2)

      info_msg "[-g2]: Plotting GPS velcocities: ${m_gps_file[$tt]}"

      unset m_gps_cmd

      case ${m_gps_arrow[$tt]} in
        default)
          m_gps_arrowfmt[$tt]=${ARROWFMT}
          ;;
        narrower)
          m_gps_arrowfmt[$tt]="0.01/0.14/0.06"
          ;;
        narrow)
          m_gps_arrowfmt[$tt]="0.02/0.14/0.06"
          ;;
        normal)
          m_gps_arrowfmt[$tt]="0.06/0.12/0.06"
          ;;
        wide)
          m_gps_arrowfmt[$tt]="0.08/0.14/0.1"
          ;;
        wider)
          m_gps_arrowfmt[$tt]="0.1/0.3/0.2"
          ;;
        *)
          m_gps_arrowfmt[$tt]=${ARROWFMT}
          ;;
      esac

      if [[ ${m_gps_linewidth[$tt]} -ne 0 ]]; then
        m_gps_strokecmd[$tt]="-W${m_gps_linewidth[$tt]}p,${m_gps_linecolor[$tt]}"
      fi

      if [[ ${m_gps_cpt[$tt]} != "none" ]]; then
        m_gps_fillcmd[$tt]="-C${m_gps_cpt_used[$tt]}"
      else
        m_gps_fillcmd[$tt]="-G${m_gps_fill[$tt]}"
      fi

      if [[ ${m_gps_noplot[$tt]} -ne 1 ]]; then

        if [[ ${m_gps_vertscale[$tt]} -eq 0 ]]; then

          if [[ ${m_gps_zcolumn[$tt]} -eq 0 ]]; then
            gmt psvelo ${m_gps_file[$tt]} ${m_gps_fillcmd[$tt]} ${m_gps_strokecmd[$tt]} -A${m_gps_arrowfmt[$tt]} -Se${VELSCALE}/${GPS_ELLIPSE}/0 $RJOK ${VERBOSE} >> map.ps
          else
            gawk < ${m_gps_file[$tt]} '{print $1, $2, $3, $4, $5, $6, $7, $'${m_gps_zcolumn[$tt]}'}' | gmt psvelo ${m_gps_fillcmd[$tt]} ${m_gps_strokecmd[$tt]} -Zu -A${m_gps_arrowfmt[$tt]} -Se${VELSCALE}/${GPS_ELLIPSE}/0 $RJOK ${VERBOSE} >> map.ps
          fi

          echo $m_gps_short_sourcestring >> ${SHORTSOURCES}
          echo $m_gps_sourcestring >> ${LONGSOURCES}

          if [[ ${m_gps_textflag[$tt]} -eq 1 ]]; then
            gawk < ${m_gps_xyfile[$tt]} '{printf("%s %s %.1f\n", $1, $2, $4)}' | gmt pstext -Dj2p -F+f${m_gps_fontsize[$tt]}p,${m_gps_font[$tt]},${m_gps_fontcolor[$tt]}+jBL ${RJOK} ${VERBOSE} >> map.ps
          fi
          if [[ ${m_gps_sitetextflag[$tt]} -eq 1 ]]; then
            gawk < ${m_gps_xyfile[$tt]} '{printf("%s %s %s\n", $1, $2, $5)}' | gmt pstext -Dj2p -F+f${m_gps_fontsize[$tt]}p,${m_gps_font[$tt]},${m_gps_fontcolor[$tt]}+jTR ${RJOK} ${VERBOSE} >> map.ps
          fi
        else
          info_msg "[-g2]: plotting verticals from column ${m_gps_zcolumn[$tt]}"
          # Velocity ellipses: in X,Y,Vx,Vy,SigX,SigY,CorXY,name format
          local projw=$(gmt mapproject -Ww ${RJSTRING})
          local projh=$(gmt mapproject -Wh ${RJSTRING})

          if [[ ${m_gps_cpt[$tt]} == "none" ]]; then
            # Draw arrows colored blue for down, red for up
            gawk < ${m_gps_file[$tt]} 'BEGIN { OFMT="%.12f" } ($'${m_gps_zcolumn[$tt]}'>=0){print $1, $2, 0, $'${m_gps_zcolumn[$tt]}', 0, 0, 0, "id"}' > toplot_pos.txt
            gawk < ${m_gps_file[$tt]} 'BEGIN { OFMT="%.12f" } ($'${m_gps_zcolumn[$tt]}'<0){print $1, $2, 0, $'${m_gps_zcolumn[$tt]}', 0, 0, 0, "id"}' > toplot_neg.txt
            gmt mapproject toplot_pos.txt -R -J > toplot_project_pos.txt
            gmt mapproject toplot_neg.txt -R -J > toplot_project_neg.txt
            # | gmt psxy -Sv12p -W2p,black ${RJOK} ${VERBOSE} >> map.ps


            gmt_init_tmpdir
              gmt psvelo toplot_project_pos.txt -Se${m_gps_vertscale[$tt]}p/0/0 -A+bc+et+n+p -W0.2p,red -Gred -R0/${projw}/0/${projh} -JX${projw}/${projh} -O -K >> map.ps
              gmt psvelo toplot_project_pos.txt -Se${m_gps_vertscale[$tt]}p/0/0 -A+e+n+p -W2p,red -Gred -R0/${projw}/0/${projh} -JX${projw}/${projh} -O -K >> map.ps
              gmt psvelo toplot_project_neg.txt -Se${m_gps_vertscale[$tt]}p/0/0 -A+bc+et+n+p -W0.2p,blue -Gblue -R0/${projw}/0/${projh} -JX${projw}/${projh} -O -K >> map.ps
              gmt psvelo toplot_project_neg.txt -Se${m_gps_vertscale[$tt]}p/0/0 -A+e+n+p -W2p,blue -Gblue -R0/${projw}/0/${projh} -JX${projw}/${projh} -O -K >> map.ps
            gmt_remove_tmpdir
          else
            # Draw arrows using CPT
            gawk < ${m_gps_file[$tt]} 'BEGIN { OFMT="%.12f" } {print $1, $2, 0, $'${m_gps_zcolumn[$tt]}', 0, 0, 0, "id"}' > toplot.txt
            gmt mapproject toplot.txt -R -J > toplot_project.txt

            gmt_init_tmpdir
            echo gmt psvelo toplot_project.txt -Se${m_gps_vertscale[$tt]}p/0/0 -A+bc+et+n+p -W0.2p+c ${m_gps_fillcmd[$tt]} -Zn -R0/${projw}/0/${projh} -JX${projw}/${projh} -O -K
              gmt psvelo toplot_project.txt -Se${m_gps_vertscale[$tt]}p/0/0 -A+bc+et+n+p -W0.2p+c ${m_gps_fillcmd[$tt]} -Zn -R0/${projw}/0/${projh} -JX${projw}/${projh} -O -K >> map.ps
              gmt psvelo toplot_project.txt -Se${m_gps_vertscale[$tt]}p/0/0 -A+e+n+p -W2p+c ${m_gps_fillcmd[$tt]} -Zn -R0/${projw}/0/${projh} -JX${projw}/${projh} -O -K >> map.ps
            gmt_remove_tmpdir
          fi

          # Vector: -Sv|V<size>[+a<angle>][+b][+e][+h<shape>][+j<just>][+l][+m][+n[<norm>[/<min>]]][+o<lon>/<lat>][+q][+r][+s][+t[b|e]<trim>][+z]
        # Direction and length must be in columns 3-4. If -SV rather than -Sv is selected, psxy will expect azimuth and length and convert azimuths based on the chosen map projection.
        # Append length of vector head. Note: Left and right sides are defined by looking from start to end of vector. Optional modifiers:
        # +a Set <angle> of the vector head apex [30]
        # +b Place a vector head at the beginning of the vector [none]. Append t for terminal, c for circle, s for square, a for arrow [Default], i for tail, A for plain arrow, and I for plain tail. Append l|r to only draw left or right side of this head [both sides].
        # +e Place a vector head at the end of the vector [none]. Append t for terminal, c for circle, s for square, a for arrow [Default], i for tail, A for plain arrow, and I for plain tail. Append l|r to only draw left or right side of this head [both sides].
        # +h Set vector head shape in -2/2 range [0].
        # +j Justify vector at (b)eginning [Default], (e)nd, or (c)enter.

        fi
      fi

    tectoplot_plot_caught=1
    ;;

    m_gps_gx)

      # xdist, comp1, err1, comp2, err2, lon, lat, projlon, projlat, azss, az[fracint], comp1_vn, comp1_ve, comp2_vn, comp2_ve, id, source

      for this_data in ${F_PROFILES}*gps_data.txt; do
        info_msg "[-gx]: plotting file ${this_data}"
        gmt psxy $this_data -Sc0.05i -i7,8 -W1p,red ${RJOK} ${VERBOSE} >> map.ps

        # psvelo is lon, lat, ve, vn, sve, svn
        gawk < $this_data '{print $8, $9, $12, $13, $3, $3, 0, $16}' | gmt psvelo -W0.1p,black -Gred -A"0.06/0.12/0.06" -Se${VELSCALE}/${GPS_ELLIPSE}/0 $RJOK ${VERBOSE} >> map.ps
        gawk < $this_data '{print $8, $9, $14, $15, $5, $5, 0, $16}' | gmt psvelo -W0.1p,black -Gblue -A"0.06/0.12/0.06" -Se${VELSCALE}/${GPS_ELLIPSE}/0 $RJOK ${VERBOSE} >> map.ps
      done
      tectoplot_plot_caught=1
    ;;

    m_gps_gg2)

      if [[ -s ${m_gps_file[$tt]} ]]; then

        gawk < ${m_gps_file[$tt]} '
          {
            seen[$1,$2]++
            if(seen[$1,$2]==1) {
              if (NF<5) {
                $5=0
                $6=0
                $7=0
              }
              print $1, $2, $3, $4, $5, $6, $7
            }
          }' > ${F_GPS}gps_init_${tt}.txt

        gmt_init_tmpdir

        # Use blockmean to avoid aliasing
        gmt blockmean -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} -I1m ${F_GPS}gps_init_${tt}.txt -fg -i0,1,2,4 -W -Vn > blk.llu 2>/dev/null
        gmt blockmean -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} -I1m ${F_GPS}gps_init_${tt}.txt -fg -i0,1,3,5 -W -Vn > blk.llv  2>/dev/null
        gmt convert -A blk.llu blk.llv -o0-2,6,3,7 > ${F_GPS}gps_cull_${tt}.txt

        # cp ${F_GPS}gps_init_${tt}.txt ${F_GPS}gps_cull_${tt}.txt

        num_eigs=$(wc -l < ${F_GPS}gps_cull_${tt}.txt | gawk '{print $1/2}')

        gmt gpsgridder ${F_GPS}gps_cull_${tt}.txt -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} -Cn$num_eigs+eigen.txt -S${m_gps_gg2_poisson[$tt]} -I${m_gps_gg2_res[$tt]} -Fd4 -fg -W -r -G${F_GPS}gps_strain_${tt}_%s.nc -Vn 2>/dev/null

        # The following code is from Hackl et al., 2009; it generates various strain rate grids

        crosssize=0.0001					# scaling factor for direction of max shear strain
        orderofmagnitude=1000000	# scaling factor for colorbar of strain rate magnitude

        # ---------------------------------------------------
        # calculate velo gradient
        #-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        gmt grdgradient ${F_GPS}gps_strain_${tt}_u.nc -Gtmp.grd -A270 ${VERBOSE} -M
        gmt grdmath ${VERBOSE} tmp.grd $orderofmagnitude MUL = e_e_${tt}.grd
        gmt grdgradient ${F_GPS}gps_strain_${tt}_u.nc -Gtmp.grd -A180 ${VERBOSE} -M
        gmt grdmath ${VERBOSE} tmp.grd $orderofmagnitude MUL = e_n_${tt}.grd
        gmt grdgradient ${F_GPS}gps_strain_${tt}_v.nc -Gtmp.grd -A270 ${VERBOSE} -M
        gmt grdmath ${VERBOSE} tmp.grd $orderofmagnitude MUL = n_e_${tt}.grd
        gmt grdgradient ${F_GPS}gps_strain_${tt}_v.nc -Gtmp.grd -A180 ${VERBOSE} -M
        gmt grdmath ${VERBOSE} tmp.grd $orderofmagnitude MUL = n_n_${tt}.grd

        # i,j component of strain tensor (mean of e_n and n_e component):
        gmt grdmath ${VERBOSE} e_n_${tt}.grd n_e_${tt}.grd ADD 0.5 MUL = mean_e_n_${tt}.grd

        # second invariant of strain rate tensor is
        # ell = (exx^2 + eyy^2 + 2*exy^2)^(1/2)
        gmt grdmath ${VERBOSE} e_e_${tt}.grd SQR n_n_${tt}.grd SQR ADD mean_e_n_${tt}.grd SQR 2 MUL ADD SQRT = second_inv_${tt}.grd

        #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        # calc eigenvalues, max shear strain rate, and dilatational strain rate
        #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        gmt grdmath ${VERBOSE} e_e_${tt}.grd n_n_${tt}.grd ADD e_e_${tt}.grd n_n_${tt}.grd SUB 2 POW mean_e_n_${tt}.grd 2 POW 4 MUL ADD SQRT ADD 2 DIV = lambda1_${tt}.grd
        gmt grdmath ${VERBOSE} e_e_${tt}.grd n_n_${tt}.grd ADD e_e_${tt}.grd n_n_${tt}.grd SUB 2 POW mean_e_n_${tt}.grd 2 POW 4 MUL ADD SQRT SUB 2 DIV = lambda2_${tt}.grd
        gmt grdmath ${VERBOSE} lambda1_${tt}.grd lambda2_${tt}.grd SUB 2 DIV = max_shear_${tt}.grd

        gmt grdmath ${VERBOSE} lambda1_${tt}.grd lambda2_${tt}.grd ADD = str_dilatational_${tt}.grd

        #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        # calc strain crosses
        #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

        gmt grdmath ${VERBOSE} 90 0.5 2 mean_e_n_${tt}.grd MUL e_e_${tt}.grd n_n_${tt}.grd SUB DIV 1 ATAN2 MUL 180 MUL 3.14 DIV SUB 45 ADD = phi1_${tt}.grd
        gmt grdmath ${VERBOSE} 90 lambda2_${tt}.grd e_e_${tt}.grd SUB mean_e_n_${tt}.grd DIV 1 ATAN2 180 MUL 3.14 DIV SUB = phi2_${tt}.grd

        if [[ ${m_gps_gg2_subsample[$tt]} -gt 1 ]]; then

          GG_SUBSAMPLE_VAL=$(echo "${m_gps_gg2_res[$tt]} ${m_gps_gg2_subsample[$tt]}" | gawk '{print (($1+0)*$2) substr($1, length($1), 1)}')

          gmt grdsample max_shear_${tt}.grd -I${GG_SUBSAMPLE_VAL}/${GG_SUBSAMPLE_VAL} -Gmax_shear_resample_${tt}.grd -Vn 2>/dev/null
          gmt grdsample lambda1_${tt}.grd -I${GG_SUBSAMPLE_VAL}/${GG_SUBSAMPLE_VAL} -Glambda1_resample_${tt}.grd -Vn 2>/dev/null
          gmt grdsample lambda2_${tt}.grd -I${GG_SUBSAMPLE_VAL}/${GG_SUBSAMPLE_VAL} -Glambda2_resample_${tt}.grd -Vn 2>/dev/null
          gmt grdsample phi1_${tt}.grd -I${GG_SUBSAMPLE_VAL}/${GG_SUBSAMPLE_VAL} -Gphi1_resample_${tt}.grd -Vn 2>/dev/null
          gmt grdsample phi2_${tt}.grd -I${GG_SUBSAMPLE_VAL}/${GG_SUBSAMPLE_VAL} -Gphi2_resample_${tt}.grd -Vn 2>/dev/null

          gmt grd2xyz max_shear_resample_${tt}.grd > max_shear_${tt}.xyz
          gmt grd2xyz phi1_resample_${tt}.grd > phi1_${tt}.xyz
          gmt grd2xyz phi2_resample_${tt}.grd > phi2_${tt}.xyz
          gmt grd2xyz lambda1_resample_${tt}.grd > lambda1_${tt}.xyz
          gmt grd2xyz lambda2_resample_${tt}.grd > lambda2_${tt}.xyz


        else

          gmt grd2xyz max_shear_${tt}.grd > max_shear_${tt}.xyz
          gmt grd2xyz phi1_${tt}.grd > phi1_${tt}.xyz
          gmt grd2xyz phi2_${tt}.grd > phi2_${tt}.xyz
          gmt grd2xyz lambda1_${tt}.grd > lambda1_${tt}.xyz
          gmt grd2xyz lambda2_${tt}.grd > lambda2_${tt}.xyz

        fi


        paste lambda1_${tt}.xyz lambda2_${tt}.xyz phi2_${tt}.xyz | gawk '{print($1, $2, $3/100, $6/100, $9)}'  > phi_shear_${tt}.xyl1l2p

        # paste max_shear.xyz phi1.xyz | awk '{print($1, $2, $3, $6)}'  > phi_shear.xysp
        # 	gawk '
        # 		function acos(x) { return atan2((1.-x^2)^0.5,x) }
        # 		function asin(x) { return atan2(x,(1.-x^2)^0.5) }
        # 		{
        # 		    pi = atan2(0,-1)
        #         lat = $2
        #         lon = $1
        #         alpha = $4*pi/180
        #         a = $3*'${crosssize}';
        # 		    lat_right = 90 - acos(cos(a)*cos((90 - lat)*pi/180) + sin(a)*sin((90 - lat)*pi/180)*cos(alpha)) *180/pi
        # 		    lon_right = lon + asin(sin(a)/sin((90-lat_right)*pi/180) * sin(alpha)) * 180/pi
        # 		    lat_left = 90 - acos(cos(a)*cos((90 - lat)*pi/180) + sin(a)*sin((90 - lat)*pi/180)*cos(alpha-pi)) *180/pi
        # 		    lon_left = lon - asin(sin(a)/sin((90-lat_right)*pi/180) * sin(alpha)) * 180/pi
        #     }
        # 		{
        #       printf ("> -Z%.2f\n %9.5f %9.5f \n %9.5f %9.5f \n %9.5f %9.5f \n", a, lon_left, lat_left, lon, lat, lon_right, lat_right)
        #     }' phi_shear.xysp > dir1
        # 	gawk '
        # 		function acos(x) { return atan2((1.-x^2)^0.5,x) }
        # 		function asin(x) { return atan2(x,(1.-x^2)^0.5) }
        # 		{
        # 		    pi = atan2(0,-1)
        #         lat = $2; lon = $1
        #         alpha = $4*pi/180+pi/2
        #         a = $3*'${crosssize}'
        # 		    lat_right = 90 - acos(cos(a)*cos((90 - lat)*pi/180) + sin(a)*sin((90 - lat)*pi/180)*cos(alpha)) *180/pi
        # 		    lon_right = lon + asin(sin(a)/sin((90-lat_right)*pi/180) * sin(alpha)) * 180/pi
        # 		    lat_left = 90 - acos(cos(a)*cos((90 - lat)*pi/180) + sin(a)*sin((90 - lat)*pi/180)*cos(alpha-pi)) *180/pi
        # 		    lon_left = lon - asin(sin(a)/sin((90-lat_right)*pi/180) * sin(alpha)) * 180/pi;
        #     }
        # 		{
        #         printf ("> -Z%.2f\n %9.5f %9.5f \n %9.5f %9.5f \n %9.5f %9.5f \n", a, lon_left, lat_left, lon, lat, lon_right, lat_right)
        #     }' phi_shear.xysp > dir2
        #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        # calc rotational strain rate
        #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        gmt grdmath ${VERBOSE} n_e_${tt}.grd e_n_${tt}.grd SUB 0.5 MUL = omega_${tt}.grd

        gmt_remove_tmpdir

        # gmt psxy dir1 -W2p,black ${RJOK} ${VERBOSE} >> map.ps
        # gmt psxy dir2 -W2p,red ${RJOK} ${VERBOSE} >> map.ps


        if [[ ${m_gps_gg2_rot[$44]} -eq 1 ]]; then
          gmt grdimage omega_${tt}.grd -Ccyclic -t${m_gps_gg2_trans[$tt]} ${RJOK} ${VERBOSE} >> map.ps
        fi
        if [[ ${m_gps_gg2_strdilflag[$tt]} -eq 1 ]]; then
          gmt grdimage str_dilatational_${tt}.grd -Cturbo -t${m_gps_gg2_trans[$tt]} ${RJOK} ${VERBOSE} >> map.ps
        fi

        if [[ ${m_gps_gg2_maxshearflag[$tt]} -eq 1 ]]; then
          gmt makecpt -Fr -T0/300/0.1 -Z -Cjet > shear.cpt
          gmt grdimage max_shear_${tt}.grd -Q -Cjet -t${m_gps_gg2_trans[$tt]} ${RJOK} ${VERBOSE} >> map.ps
        fi

        if [[ ${m_gps_gg2_secinvflag[$tt]} -eq 1 ]]; then
          gmt makecpt -Fr -T1/2000/1+l -Q -Z -D -Cjet > ${F_CPTS}secinv.cpt
          gmt grdimage second_inv_${tt}.grd -Q -C${F_CPTS}secinv.cpt -t${m_gps_gg2_trans[$tt]} ${RJOK} ${VERBOSE} >> map.ps
          m_gps_gg2_bars+=("m_gps_secinv")
        fi

        # Plot strain crosses

        if [[ ${m_gps_gg2_cross[$tt]} -eq 1 ]]; then
          gmt psvelo phi_shear_${tt}.xyl1l2p -Sx0.15i -W0.2p,black -Gblack ${RJOK} ${VERBOSE} >> map.ps
        fi


        # Plot velocity arrows
        if [[ -s ${F_GPS}gps_strain_${tt}_u.nc && -s ${F_GPS}gps_strain_${tt}_v.nc ]]; then

          gmt_init_tmpdir

          gmt grdmath ${F_GPS}gps_strain_${tt}_u.nc SQR ${F_GPS}gps_strain_${tt}_v.nc SQR ADD SQRT = ${F_GPS}gps_vel_${tt}.nc
          # gmt grdimage ${F_GPS}gps_vel.nc -Cturbo ${RJOK} ${VERBOSE} >> map.ps

          # Recover the GPS velocity components
          gmt grd2xyz ${F_GPS}gps_strain_${tt}_u.nc > ${F_GPS}gps_strain_${tt}_u.txt
          gmt grd2xyz ${F_GPS}gps_strain_${tt}_v.nc | gawk '{print $3, 0, 0, 0}' > ${F_GPS}gps_strain_${tt}_v.txt

          if [[ ${m_gps_gg2_subsample[$tt]} -gt 1 ]]; then

          GG_SUBSAMPLE_VAL=$(echo "${m_gps_gg2_res[$tt]} ${m_gps_gg2_subsample[$tt]}" | gawk '{print (($1+0)*$2) substr($1, length($1), 1)}')

            gmt grdsample ${F_GPS}gps_strain_${tt}_u.nc -I${GG_SUBSAMPLE_VAL}/${GG_SUBSAMPLE_VAL} -G${F_GPS}gps_strain_${tt}_u_resample.nc -Vn 2>/dev/null
            gmt grdsample ${F_GPS}gps_strain_${tt}_v.nc -I${GG_SUBSAMPLE_VAL}/${GG_SUBSAMPLE_VAL} -G${F_GPS}gps_strain_${tt}_v_resample.nc -Vn 2>/dev/null
            gmt grd2xyz ${F_GPS}gps_strain_${tt}_u_resample.nc > ${F_GPS}gps_strain_${tt}_u_resample.txt
            gmt grd2xyz ${F_GPS}gps_strain_${tt}_v_resample.nc > ${F_GPS}gps_strain_${tt}_v_resample.txt

            paste ${F_GPS}gps_strain_${tt}_u_resample.txt ${F_GPS}gps_strain_${tt}_v_resample.txt | gawk '{print $1, $2, $3, $6, 0, 0, 0} '> ${F_GPS}gps_strain_${tt}.txt

            # gmt blockmean ${F_GPS}gps_cull_${tt}.txt -Sn -R${F_GPS}gps_strain_${tt}_v_resample.nc -C -E -fg | gawk '{print $1, $2, $3}' > ${F_GPS}gps_ptnum.txt
            gmt xyz2grd ${F_GPS}gps_cull_${tt}.txt -R${F_GPS}gps_strain_${tt}_v_resample.nc -An -G${F_GPS}gps_number_${tt}.nc

          else
            paste ${F_GPS}gps_strain_${tt}_u.txt ${F_GPS}gps_strain_${tt}_v.txt > ${F_GPS}gps_strain_${tt}.txt

            # Get the number of GPS velocities within each cell
            # gmt blockmean ${F_GPS}gps_cull_${tt}.txt -Sn -R${F_GPS}gps_strain_${tt}_v.nc -C -E -fg | gawk '{print $1, $2, $3}' > ${F_GPS}gps_ptnum.txt
            gmt xyz2grd ${F_GPS}gps_cull_${tt}.txt -R${F_GPS}gps_strain_${tt}_v.nc -An -G${F_GPS}gps_number_${tt}.nc
          fi

          gmt grdtrack ${F_GPS}gps_strain_${tt}.txt -G${F_GPS}gps_number_${tt}.nc -Z -N | gawk '
            {
              if ($1=="NaN") {
                $1=0
              }
              printf("%.0f\n", $1)
            } '> ${F_GPS}near_num_${tt}.txt

          rm -f ./gps_g_withdata.txt
          rm -f ./gps_g_withonedata.txt
          rm -f ./gps_g_withoutdata.txt

          paste ${F_GPS}near_num_${tt}.txt ${F_GPS}gps_strain_${tt}.txt | gawk '
            {
              if ($1>1) {
                $1=""
                print $0 > "./gps_g_withdata.txt"
              } else if ($1==1){
                $1=""
                print $0 > "./gps_g_withonedata.txt"
              } else {
                $1=""
                print $0 > "./gps_g_withoutdata.txt"
              }
            }'

          mv gps_g_* ${F_GPS}

          gmt_remove_tmpdir

          if [[ ${m_gps_gg2_noaveflag[$tt]} -ne 1 ]]; then
            [[ -s ${F_GPS}gps_g_withdata.txt ]] && gmt psvelo ${F_GPS}gps_g_withdata.txt -W${GPS_LINEWIDTH},${GPS_LINECOLOR} -Gblack -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 -L $RJOK $VERBOSE >> map.ps
            [[ -s ${F_GPS}gps_g_withonedata.txt ]] && gmt psvelo ${F_GPS}gps_g_withonedata.txt -W${GPS_LINEWIDTH},${GPS_LINECOLOR} -Ggray -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 -L $RJOK $VERBOSE >> map.ps

            if [[ ${m_gps_gg2_noave0flag[$tt]} -ne 1 ]]; then
              [[ -s ${F_GPS}gps_g_withoutdata.txt ]] && gmt psvelo ${F_GPS}gps_g_withoutdata.txt -W${GPS_LINEWIDTH},${GPS_LINECOLOR} -Gwhite -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 -L $RJOK $VERBOSE >> map.ps
            fi
          fi
          # gmt grdvector -Ix10/10 ${F_GPS}gps_strain_${tt}_u.nc ${F_GPS}gps_strain_${tt}_v.nc ${RJOK} ${VERBOSE} -Q0.03i+e -Gblue -W.4,blue -S120i --MAP_VECTOR_SHAPE=0.2  >> map.ps
        fi

        if [[ ${m_gps_gg2_residflag[$tt]} -eq 1 ]]; then
          # Calculate and plot the residuals
          gmt grdtrack ${F_GPS}gps_cull_${tt}.txt -G${F_GPS}gps_strain_${tt}_u.nc -G${F_GPS}gps_strain_${tt}_v.nc -Z > ${F_GPS}gps_extract.txt
          paste ${F_GPS}gps_cull_${tt}.txt ${F_GPS}gps_extract.txt | gawk '{ print $1, $2, $3-$8, $4-$9, 0, 0, 0}' > ${F_GPS}gps_g_residual.txt

          if [[ -s ${F_GPS}gps_g_residual.txt ]]; then
            gmt psvelo ${F_GPS}gps_g_residual.txt -W${GPS_LINEWIDTH},${GPS_LINECOLOR} -Ggreen -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 -L $RJOK $VERBOSE >> map.ps
          fi
        fi
      fi
      tectoplot_plot_caught=1

      ;;
  esac
}

function tectoplot_legendbar_gps() {
  case $1 in
    m_gps_g2)
      if [[ ${m_gps_cpt[$tt]} != "none" ]]; then
        if [[ ${m_gps_vertscale[$tt]} -eq 0 ]]; then
          echo "G 0.2i" >> ${LEGENDDIR}legendbars.txt
          echo "B ${m_gps_cpt_used[$tt]} 0.2i 0.1i+malu ${LEGENDBAR_OPTS} -Bxaf+l\"GPS horizontal velocity (${m_gps_cptunit[$tt]})\"" >> ${LEGENDDIR}legendbars.txt
        else
          echo "G 0.2i" >> ${LEGENDDIR}legendbars.txt
          echo "B ${m_gps_cpt_used[$tt]} 0.2i 0.1i+malu ${LEGENDBAR_OPTS} -Bxaf+l\"GPS vertical velocity (${m_gps_cptunit[$tt]})\"" >> ${LEGENDDIR}legendbars.txt
        fi
        barplotcount=$barplotcount+1
      fi
      tectoplot_legendbar_caught=1
    ;;
    m_gps_gg2)
      for this_bar in ${m_gps_gg2_bars[@]}; do
        case $this_bar in
          m_gps_secinv)
            echo "G ${LEGEND_BAR_GAP}" >> ${LEGENDDIR}legendbars.txt
            echo "B ${F_CPTS}secinv.cpt 0.2i ${LEGEND_BAR_HEIGHT}+malu ${LEGENDBAR_OPTS} -Bxaf+l\"Second invariant of strain rate\"" >> ${LEGENDDIR}legendbars.txt
            barplotcount=$barplotcount+1
          ;;
        esac
      done
      tectoplot_legendbar_caught=1

    ;;
  esac
}

function tectoplot_legend_gps() {
  case $1 in
  m_gps_g2)

    init_legend_item "gps_${tt}"

    if [[ ${m_gps_vertscale[$tt]} -eq 0 ]]; then
      local GPSMAXVEL_INT=$(echo "scale=0;(${m_gps_legvel[$tt]})/1" | bc)
      local GPSMESSAGE="GPS ($GPSMAXVEL_INT ${m_gps_cptunit[$tt]} / ${GPS_ELLIPSE_TEXT})"
      local GPSoffset=$(echo "(${#GPSMESSAGE} + 2)* 6 * 0.5" | bc -l)
      echo "$CENTERLON $CENTERLAT ${GPSMESSAGE}" | gmt pstext -F+f6p,Helvetica,black+jLM -X0.15i ${RJOK} ${VERBOSE} >> ${LEGFILE}
      echo "$CENTERLON $CENTERLAT $GPSMAXVEL_INT 0 1 1 0 ID" | gmt psvelo ${m_gps_fillcmd[$tt]} ${m_gps_strokecmd[$tt]} -A${m_gps_arrowfmt[$tt]} -Se${VELSCALE}/${GPS_ELLIPSE}/0 -X${GPSoffset}p -L ${RJOK} $VERBOSE >> ${LEGFILE} 2>/dev/null
    else
      local GPSMAXVEL_INT=$(echo "scale=0;(${m_gps_legvel[$tt]})/1" | bc)
      local GPSMESSAGE="Vertical GPS ($GPSMAXVEL_INT ${m_gps_cptunit[$tt]})"
      local GPSoffset=$(echo "(${#GPSMESSAGE} + 4)* 6 * 0.5" | bc -l)
      echo "$CENTERLON $CENTERLAT ${GPSMESSAGE}" | gmt pstext -F+f6p,Helvetica,black+jLM -X0.15i ${RJOK} ${VERBOSE} >> ${LEGFILE}
      # echo "$CENTERLON $CENTERLAT $GPSMAXVEL_INT 0 1 1 0 ID" | gmt psvelo ${m_gps_fillcmd[$tt]} ${m_gps_strokecmd[$tt]} -A${m_gps_arrowfmt[$tt]} -Se${VELSCALE}/${GPS_ELLIPSE}/0 -X${GPSoffset}p -L ${RJOK} $VERBOSE >> ${LEGFILE} 2>/dev/null

      local projw=$(gmt mapproject -Ww ${RJSTRING})
      local projh=$(gmt mapproject -Wh ${RJSTRING})

      if [[ ${m_gps_cpt[$tt]} != "none" ]]; then

        gawk < ${m_gps_file[$tt]} 'BEGIN { OFMT="%.12f" } {print $1, $2, 0, $'${m_gps_zcolumn[$tt]}', 0, 0, 0, "id"}' > toplot.txt
        gmt mapproject toplot.txt -R -J > toplot_project.txt

        gmt_init_tmpdir
          echo "$CENTERLON $CENTERLAT $GPSMAXVEL_INT 0 0 0 0 ID" | gmt mapproject ${RJSTRING} | gmt psvelo -Se${m_gps_vertscale[$tt]}p/0/0 -A+bc+et+n+p -W0.2p+c ${m_gps_fillcmd[$tt]} -Zn -R0/${projw}/0/${projh} -JX${projw}/${projh} -O -K ${VERBOSE} -Xa${GPSoffset}p >> ${LEGFILE} 2>/dev/null
          echo "$CENTERLON $CENTERLAT $GPSMAXVEL_INT 0 0 0 0 ID" | gmt mapproject ${RJSTRING} | gmt psvelo -Se${m_gps_vertscale[$tt]}p/0/0 -A+e+n+p -W2p+c ${m_gps_fillcmd[$tt]} -Zn -R0/${projw}/0/${projh} -JX${projw}/${projh} -O -K -Xa${GPSoffset}p >> ${LEGFILE} 2>/dev/null
        gmt_remove_tmpdir
      else
        echo "$CENTERLON $CENTERLAT up" | gmt pstext -F+f4p,Helvetica,black+jRM -Xa${GPSoffset}p -Ya0.05i -Dj4p ${RJOK} ${VERBOSE} >> ${LEGFILE}
        echo "$CENTERLON $CENTERLAT down" | gmt pstext -F+f4p,Helvetica,black+jRM -Xa${GPSoffset}p -Ya-0.05i -Dj4p ${RJOK} ${VERBOSE} >> ${LEGFILE}


        gmt_init_tmpdir
          echo "$CENTERLON $CENTERLAT $GPSMAXVEL_INT 0 0 0 0 up" | gmt mapproject ${RJSTRING} | gmt psvelo -Se${m_gps_vertscale[$tt]}p/0/0 -A+bc+et+n+p -W0.2p,red -Gred -R0/${projw}/0/${projh} -JX${projw}/${projh} -O -K ${VERBOSE} -Xa${GPSoffset}p -Ya0.05i >> ${LEGFILE} 2>/dev/null
          echo "$CENTERLON $CENTERLAT $GPSMAXVEL_INT 0 0 0 0 up" | gmt mapproject ${RJSTRING} | gmt psvelo -Se${m_gps_vertscale[$tt]}p/0/0 -A+e+n+p -W2p,red -Gred -R0/${projw}/0/${projh} -JX${projw}/${projh} -O -K -Xa${GPSoffset}p -Ya0.05i >> ${LEGFILE} 2>/dev/null
          echo "$CENTERLON $CENTERLAT $GPSMAXVEL_INT 0 0 0 0 down" | gmt mapproject ${RJSTRING} | gmt psvelo -Se${m_gps_vertscale[$tt]}p/0/0 -A+bc+et+n+p -W0.2p,blue -Gblue -R0/${projw}/0/${projh} -JX${projw}/${projh} -O -K ${VERBOSE} -Xa${GPSoffset}p -Ya-0.05i >> ${LEGFILE} 2>/dev/null
          echo "$CENTERLON $CENTERLAT $GPSMAXVEL_INT 0 0 0 0 down" | gmt mapproject ${RJSTRING} | gmt psvelo -Se${m_gps_vertscale[$tt]}p/0/0 -A+e+n+p -W2p,blue -Gblue -R0/${projw}/0/${projh} -JX${projw}/${projh} -O -K -Xa${GPSoffset}p -Ya-0.05i >> ${LEGFILE} 2>/dev/null
        gmt_remove_tmpdir
      fi
    fi

    close_legend_item "gps_${tt}"

    tectoplot_legend_caught=1
  ;;
  esac
}

# function tectoplot_post_gps() {
#   # Add the file to the profiles
# }

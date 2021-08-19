
TECTOPLOT_MODULES+=("tdefnode")

# Calculate residual grid by removing along-line average, using da-dt formulation
# Builtin support for gravity grids

# Variables needed:


function tectoplot_defaults_tdefnode() {
  ################################################################################
  ##### TDEFNODE model options
  MINCOUPLING=0.2              # cutoff of coupling value to display, TDEFNODE
  SVBIG=0.1i                   # slip vectors, length, large
  SVBIGW="1p"                  # slip vectors, width, large
  SVSMALL=0.05i                # slip vectors, length, small
  SVSMALLW="0.65p"             # slip vectors, width, small
  SMALLRES=0.02i               # residual velocities, scale

  TD_OGPS_LINEWIDTH="0.25p"
  TD_OGPS_LINECOLOR="black"
  TD_OGPS_FILLCOLOR="red"

  TD_VGPS_LINEWIDTH="0.25p"
  TD_VGPS_LINECOLOR="black"
  TD_VGPS_FILLCOLOR="white"

  TD_RGPS_LINEWIDTH="0.25p"
  TD_RGPS_LINECOLOR="black"
  TD_RGPS_FILLCOLOR="green"

  ##### TDEFNODE FAULT MIDPOINT VECTORS

  SLIP_DIST=2                 # Cutoff distance, in degrees lat/lon

  SLIP_LINEWIDTH="0.25p"
  SLIP_LINECOLOR="black"
  SLIP_FILLCOLOR="lightbrown"

  SLIP_FONTSIZE="5"
  SLIP_FONT="Helvetica"
  SLIP_FONTCOLOR="brown"
}

function tectoplot_args_tdefnode()  {
  # The following line is required for all modules
  # tectoplot_module_caught=0
  # tectoplot_module_shift=0
  #

  # # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

    -tdeffaults)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tdeffaults:   select tdefnode faults to display
-tdeffaults fault1,fault2,fault3,...

  Argument is a comma-delimites list of fault numbers

Example: None
--------------------------------------------------------------------------------
EOF
  fi

      shift
      # Expects a comma-delimited list of numbers
      tdeffaultlistflag=1
      FAULTIDLIST="${2}"
      shift
      ((tectoplot_module_shift++))
      tectoplot_module_caught=1
      ;;

  -tdefnode)

    tectoplot_module_caught=0
    tectoplot_module_shift=0

    if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tdefnode:     plot results of tdefnode model
-tdefnode [results_directory] [commandstring]

  commandstring: [ to be completed ]

  a: block labels
  b: blocks
  g: faults, nodes, etc
  l: dashed line along base of coupling
  c: coupling (slip rate deficit)
  x: faults
  s: slip vector azimuths (modeled + observed)
  o: observed GPS velocity
  v: modeled GPS velocity
  r: residual GPS velocity
  f: fault segment midpoint slip rates
  q: fault segment midpoint slip, subsampled by distance
  e: elastic component of block velocity
  t: rotation component of block velocity

Example: None
--------------------------------------------------------------------------------
EOF
fi

    shift
		tdefnodeflag=1
		TDPATH="${1}"
		TDSTRING="${2}"
		shift
    ((tectoplot_module_shift++))
		shift
    ((tectoplot_module_shift++))

    plots+=("tdefnode")
    cpts+=("slipratedeficit")

    tectoplot_module_caught=1
  	;;


  -tdefpm)

    tectoplot_module_caught=0
    tectoplot_module_shift=0

if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tdefpm:       use tdefnode model results as plate model
-tdefpm [results_directory]

Example: None
--------------------------------------------------------------------------------
EOF
fi

    shift
    plotplates=1
    tdefnodeflag=1
    if arg_is_flag $1; then
      info_msg "[-tdefpm]: No path specified for TDEFNODE results folder"
      exit 2
    else
      TDPATH="${1}"
      TDFOLD=$(echo $TDPATH | xargs -n 1 dirname)
      TDMODEL=$(echo $TDPATH | xargs -n 1 basename)
      BASENAME="${TDFOLD}/${TDMODEL}/${TDMODEL}"
      ! [[ -e "${BASENAME}_blk.gmt" ]] && echo "TDEFNODE block file does not exist... exiting" && exit 2
      ! [[ -e "${BASENAME}.poles" ]] && echo "TDEFNODE pole file does not exist... exiting" && exit 2
      ! [[ -d "${TDFOLD}/${TDMODEL}/"def2tecto_out/ ]] && mkdir "${TDFOLD}/${TDMODEL}/"def2tecto_out/
      rm -f "${TDFOLD}/${TDMODEL}/"def2tecto_out/*.dat
      # echo "${TDFOLD}/${TDMODEL}/"def2tecto_out/
      str1="G# P# Name      Lon.      Lat.     Omega     SigOm    Emax    Emin      Az"
      str2="Relative poles"
      cat "${BASENAME}.poles" | sed '1,/G# P# Name      Lon.      Lat.     Omega     SigOm    Emax    Emin      Az     VAR/d;/ Relative poles/,$d' | sed '$d' | gawk  '{print $3, $5, $4, $6}' | grep '\S' > ${TDPATH}/def2tecto_out/poles.dat
      cat "${BASENAME}_blk.gmt" | gawk  '{ if ($1 == ">") print $1, $6; else print $1, $2 }' > ${TDPATH}/def2tecto_out/blocks.dat
      POLESRC="TDEFNODE"
      PLATES="${TDFOLD}/${TDMODEL}/"def2tecto_out/blocks.dat
      POLES="${TDFOLD}/${TDMODEL}/"def2tecto_out/poles.dat
      info_msg "[-tdefpm]: TDEFNODE block model is ${PLATEMODEL}"
      TDEFRP="${2}"
      DEFREF=$TDEFRP
      shift
      ((tectoplot_module_shift++))
      shift
      ((tectoplot_module_shift++))

    fi

    tectoplot_module_caught=1

    ;;

  esac
}

# We download the relevant data in the _calculate_ function as this is the first time we should
# be accessing the data itself.

# function tectoplot_calculate_tdefnode()  {
#
# }

# function tectoplot_cpt_tdefnode() {
# }

function tectoplot_plot_tdefnode() {

  case $1 in

  tdefnode)

    info_msg "TDEFNODE folder is at $TDPATH"
    TDMODEL=$(echo $TDPATH | xargs -n 1 basename | gawk  -F. '{print $1}')
    info_msg "$TDMODEL"

    if [[ ${TDSTRING} =~ .*l.* || ${TDSTRING} =~ .*c.* || ${TDSTRING} =~ .*d.* ]]; then
      # Plot a dashed line along the contour of coupling = 0
      info_msg "TDEFNODE coupling"
      gawk '{
        if ($1 ==">") {
          carat=$1
          faultid=$3
          z=$2
          val=$5
          getline
          p1x=$1; p1y=$2
          getline
          p2x=$1; p2y=$2
          getline
          p3x=$1; p3y=$2
          geline
          p4x=$1; p4y=$2
          xav=(p1x+p2x+p3x+p4x)/4
          yav=(p1y+p2y+p3y+p4y)/4
          print faultid, xav, yav, val
        }
      }' ${TDPATH}${TDMODEL}_flt_atr.gmt > tdsrd_faultids.xyz

      if [[ $tdeffaultlistflag -eq 1 ]]; then
        echo $FAULTIDLIST | gawk  '{
          n=split($0,groups,":");
          for(i=1; i<=n; i++) {
             print groups[i]
          }
        }' | tr ',' ' ' > faultid_groups.txt
      else # Extract all fault IDs as Group 1 if we don't specify faults/groups
        gawk < tdsrd_faultids.xyz '{
          seen[$1]++
          } END {
            for (key in seen) {
              printf "%s ", key
          }
        } END { printf "\n"}' > faultid_groups.txt
      fi

      groupd=0
      while read p; do
        groupd=$(echo "$groupd+1" | bc)

        echo "Processing fault group $groupd"
        gawk < tdsrd_faultids.xyz -v idstr="$p" 'BEGIN {
            split(idstr,idarray," ")
            for (i in idarray) {
              idcheck[idarray[i]]
            }
          }
          {
            if ($1 in idcheck) {
              print $2, $3, $4
            }
        }' > faultgroup_$groupd.xyz
        # May wish to process grouped fault data here

        mkdir -p tmpgrd
        cd tmpgrd
          gmt nearneighbor ../faultgroup_$groupd.xyz -S0.2d -R$MINLON/$MAXLON/$MINLAT/$MAXLAT -I0.1d -Gfaultgroup_${groupd}.grd
        cd ..

        # May wish to process grouped fault data here
      done < faultid_groups.txt
    fi

    while IFS='' read -r -d '' -n 1 char; do
      case $char in
        a)
          info_msg "TDEFNODE block labels"
          gawk < ${TDPATH}${TDMODEL}_blocks.out '{ print $2,$3,$1 }' | gmt pstext -F+f8,Helvetica,orange+jBL $RJOK $VERBOSE >> map.ps
        ;;
        b)
          info_msg "TDEFNODE blocks"
          gmt psxy ${TDPATH}${TDMODEL}_blk.gmt -W1p,black -L $RJOK $VERBOSE >> map.ps 2>/dev/null
        ;;
        g)
          # Faults, nodes, etc.
          # Find the number of faults in the model
          info_msg "TDEFNODE faults, nodes, etc"
          numfaults=$(gawk 'BEGIN {min=0} { if ($1 == ">" && $3 > min) { min = $3} } END { print min }' ${TDPATH}${TDMODEL}_flt_atr.gmt)
          gmt makecpt -Ccategorical -T0/$numfaults/1 $VERBOSE > faultblock.cpt
          gawk '{ if ($1 ==">") printf "%s %s%f\n",$1,$2,$3; else print $1,$2 }' ${TDPATH}${TDMODEL}_flt_atr.gmt | gmt psxy -L -Cfaultblock.cpt $RJOK $VERBOSE >> map.ps
          gmt psxy ${TDPATH}${TDMODEL}_blk3.gmt -Wfatter,red,solid $RJOK $VERBOSE >> map.ps
          gmt psxy ${TDPATH}${TDMODEL}_blk3.gmt -Wthickest,black,solid $RJOK $VERBOSE >> map.ps
          #gmt psxy ${TDPATH}${TDMODEL}_blk.gmt -L -R -J -Wthicker,black,solid -O -K $VERBOSE  >> map.ps
          gawk '{if ($4==1) print $7, $8, $2}' ${TDPATH}${TDMODEL}.nod | gmt pstext -F+f10p,Helvetica,lightblue $RJOK $VERBOSE >> map.ps
          gawk '{print $7, $8}' ${TDPATH}${TDMODEL}.nod | gmt psxy -Sc.02i -Gblack $RJOK $VERBOSE >> map.ps
        ;;
        c)
          for thisd in $(seq 1 $groupd); do
            gmt psxy faultgroup_$thisd.xyz -Sc0.015i -C$SLIPRATE_DEF_CPT $RJOK $VERBOSE >> map.ps
          done
          ;;
        d)
          for thisd in $(seq 1 $groupd); do
            gmt grdimage tmpgrd/faultgroup_${thisd}.grd -C$SLIPRATE_DEF_CPT $RJOK $VERBOSE -Q >> map.ps
          done
          ;;
        l)
          for thisd in $(seq 1 $groupd); do
            gmt grdcontour tmpgrd/faultgroup_${thisd}.grd -S5 -C+0.7 -W0.1p,black,- $RJOK $VERBOSE >> map.ps
          done
          ;;
        X)
          # FAULTS ############
          info_msg "TDEFNODE faults"
          gmt psxy ${TDPATH}${TDMODEL}_blk0.gmt -R -J -W1p,red -O -K $VERBOSE >> map.ps 2>/dev/null
          gawk < ${TDPATH}${TDMODEL}_blk0.gmt '{ if ($1 == ">") print $3,$4, $5 " (" $2 ")" }' | gmt pstext -F+f8,Helvetica,black+jBL $RJOK $VERBOSE >> map.ps

          # PSUEDOFAULTS ############
          gmt psxy ${TDPATH}${TDMODEL}_blk1.gmt -R -J -W1p,green -O -K $VERBOSE >> map.ps 2>/dev/null
          gawk < ${TDPATH}${TDMODEL}_blk1.gmt '{ if ($1 == ">") print $3,$4,$5 }' | gmt pstext -F+f8,Helvetica,brown+jBL $RJOK $VERBOSE >> map.ps
          ;;

        s)
          # SLIP VECTORS ######
          legendwords+=("slipvectors")
          info_msg "TDEFNODE slip vectors (observed and predicted)"
          gawk < ${TDPATH}${TDMODEL}.svs -v size=$SVBIG '(NR > 1) {print $1, $2, $3, size}' > ${TDMODEL}.svobs
          gawk < ${TDPATH}${TDMODEL}.svs -v size=$SVSMALL '(NR > 1) {print $1, $2, $5, size}' > ${TDMODEL}.svcalc
          gmt psxy -SV"${PVHEAD}"+jc -W"${SVBIGW}",black ${TDMODEL}.svobs $RJOK $VERBOSE >> map.ps
          gmt psxy -SV"${PVHEAD}"+jc -W"${SVSMALLW}",lightgreen ${TDMODEL}.svcalc $RJOK $VERBOSE >> map.ps
          ;;

        o)
          # GPS ##############
          # observed vectors
          # lon, lat, ve, vn, sve, svn, xcor, site
          # gmt psvelo $GPS_FILE -W${GPS_LINEWIDTH},${GPS_LINECOLOR} -G${GPS_FILLCOLOR} -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 -L $RJOK $VERBOSE >> map.ps 2>/dev/null
          info_msg "TDEFNODE observed GPS velocities"
          legendwords+=("TDEFobsgps")
          echo "" | gawk  '{ if ($5==1 && $6==1) print $8, $9, $12, $17, $15, $20, $27, $1 }' ${TDPATH}${TDMODEL}.vsum > ${TDMODEL}.obs
          gmt psvelo ${TDMODEL}.obs -W${TD_OGPS_LINEWIDTH},${TD_OGPS_LINECOLOR} -G${TD_OGPS_FILLCOLOR} -Se$VELSCALE/${GPS_ELLIPSE}/0 -A${ARROWFMT} -L $RJOK $VERBOSE >> map.ps 2>/dev/null
          # gawk  -v gpsscalefac=$VELSCALE '{ az=atan2($3, $4) * 180 / 3.14159265358979; if (az > 0) print $1, $2, az, sqrt($3*$3+$4*$4)*gpsscalefac; else print $1, $2, az+360, sqrt($3*$3+$4*$4)*gpsscalefac; }' ${TDMODEL}.obs > ${TDMODEL}.xyobs
          # gmt psxy -SV$ARROWFMT -W0.25p,white -Gblack ${TDMODEL}.xyobs $RJOK $VERBOSE >> map.ps
          ;;

        v)
          # calculated vectors  UPDATE TO PSVELO
          info_msg "TDEFNODE modeled GPS velocities"
          legendwords+=("TDEFcalcgps")
          gawk '{ if ($5==1 && $6==1) print $8, $9, $13, $18, $15, $20, $27, $1 }' ${TDPATH}${TDMODEL}.vsum > ${TDMODEL}.vec
          gmt psvelo ${TDMODEL}.vec -W${TD_VGPS_LINEWIDTH},${TD_VGPS_LINECOLOR} -D0 -G${TD_VGPS_FILLCOLOR} -Se$VELSCALE/${GPS_ELLIPSE}/0 -A${ARROWFMT} -L $RJOK $VERBOSE >> map.ps 2>/dev/null

          #  Generate AZ/VEL data
          echo "" | gawk  '{ az=atan2($3, $4) * 180 / 3.14159265358979; if (az > 0) print $1, $2, az, sqrt($3*$3+$4*$4); else print $1, $2, az+360, sqrt($3*$3+$4*$4); }' ${TDMODEL}.vec > ${TDMODEL}.xyvec
          # gawk  '(sqrt($3*$3+$4*$4) <= 5) { print $1, $2 }' ${TDMODEL}.vec > ${TDMODEL}_smallcalc.xyvec
          # gmt psxy -SV$ARROWFMT -W0.25p,black -Gwhite ${TDMODEL}.xyvec $RJOK $VERBOSE >> map.ps
          # gmt psxy -SC$SMALLRES -W0.25p,black -Gwhite ${TDMODEL}_smallcalc.xyvec $RJOK $VERBOSE >> map.ps
          ;;

        r)
          legendwords+=("TDEFresidgps")
          #residual vectors UPDATE TO PSVELO
          info_msg "TDEFNODE residual GPS velocities"
          gawk '{ if ($5==1 && $6==1) print $8, $9, $14, $19, $15, $20, $27, $1 }' ${TDPATH}${TDMODEL}.vsum > ${TDMODEL}.res
          # gmt psvelo ${TDMODEL}.res -W${TD_VGPS_LINEWIDTH},${TD_VGPS_LINECOLOR} -G${TD_VGPS_FILLCOLOR} -Se$VELSCALE/${GPS_ELLIPSE}/0 -A${ARROWFMT} -L $RJOK $VERBOSE >> map.ps 2>/dev/null
          gmt psvelo ${TDMODEL}.obs -W${TD_OGPS_LINEWIDTH},${TD_OGPS_LINECOLOR} -G${TD_OGPS_FILLCOLOR} -Se$VELSCALE/${GPS_ELLIPSE}/0 -A${ARROWFMT} -L $RJOK $VERBOSE >> map.ps 2>/dev/null

          #  Generate AZ/VEL data
          echo "" | gawk  '{ az=atan2($3, $4) * 180 / 3.14159265358979; if (az > 0) print $1, $2, az, sqrt($3*$3+$4*$4)*gpsscalefac; else print $1, $2, az+360, sqrt($3*$3+$4*$4)*gpsscalefac; }' ${TDMODEL}.res > ${TDMODEL}.xyres
          # gmt psxy -SV$ARROWFMT -W0.1p,black -Ggreen ${TDMODEL}.xyres $RJOK $VERBOSE >> map.ps
          # gawk  '(sqrt($3*$3+$4*$4) <= 5) { print $1, $2 }' ${TDMODEL}.res > ${TDMODEL}_smallres.xyvec
          # gmt psxy -SC$SMALLRES -W0.25p,black -Ggreen ${TDMODEL}_smallres.xyvec $RJOK $VERBOSE >> map.ps
          ;;

        f)
          # Fault segment midpoint slip rates
          # CONVERT TO PSVELO ONLY
          info_msg "TDEFNODE fault midpoint slip rates - all "
          legendwords+=("TDEFsliprates")
          gawk '{ print $1, $2, $3, $4, $5, $6, $7, $8 }' ${TDPATH}${TDMODEL}_mid.vec > ${TDMODEL}.midvec
          # gmt psvelo ${TDMODEL}.midvec -W${SLIP_LINEWIDTH},${SLIP_LINECOLOR} -G${SLIP_FILLCOLOR} -Se$VELSCALE/${GPS_ELLIPSE}/0 -A${ARROWFMT} -L $RJOK $VERBOSE >> map.ps 2>/dev/null
          gmt psvelo ${TDMODEL}.midvec -W${SLIP_LINEWIDTH},${SLIP_LINECOLOR} -G${SLIP_FILLCOLOR} -Se$VELSCALE/${GPS_ELLIPSE}/0 -A${ARROWFMT} -L $RJOK $VERBOSE >> map.ps 2>/dev/null

          # Generate AZ/VEL data
          gawk '{ az=atan2($3, $4) * 180 / 3.14159265358979; if (az > 0) print $1, $2, az, sqrt($3*$3+$4*$4); else print $1, $2, az+360, sqrt($3*$3+$4*$4); }' ${TDMODEL}.midvec > ${TDMODEL}.xymidvec

          # Label
          gawk '{ printf "%f %f %.1f\n", $1, $2, sqrt($3*$3+$4*$4) }' ${TDMODEL}.midvec > ${TDMODEL}.fsliplabel

          gmt pstext -F+f"${SLIP_FONTSIZE}","${SLIP_FONT}","${SLIP_FONTCOLOR}"+jBM $RJOK ${TDMODEL}.fsliplabel $VERBOSE >> map.ps
          ;;
        q)              # Fault segment midpoint slip rates, only plot when the "distance" between the point and the last point is larger than a set value
          # CONVERT TO PSVELO ONLY
          info_msg "TDEFNODE fault midpoint slip rates - near cutoff = ${SLIP_DIST} degrees"
          legendwords+=("TDEFsliprates")

          gawk -v cutoff=${SLIP_DIST} 'BEGIN {dist=0;lastx=9999;lasty=9999} {
              newdist = sqrt(($1-lastx)*($1-lastx)+($2-lasty)*($2-lasty));
              if (newdist > cutoff) {
                lastx=$1
                lasty=$2
                print $1, $2, $3, $4, $5, $6, $7, $8
              }
          }' < ${TDPATH}${TDMODEL}_mid.vec > ${TDMODEL}.midvecsel
          gmt psvelo ${TDMODEL}.midvecsel -W${SLIP_LINEWIDTH},${SLIP_LINECOLOR} -G${SLIP_FILLCOLOR} -Se$VELSCALE/${GPS_ELLIPSE}/0 -A${ARROWFMT} -L $RJOK $VERBOSE >> map.ps 2>/dev/null
          # Generate AZ/VEL data
          gawk '{ az=atan2($3, $4) * 180 / 3.14159265358979; if (az > 0) print $1, $2, az, sqrt($3*$3+$4*$4); else print $1, $2, az+360, sqrt($3*$3+$4*$4); }' ${TDMODEL}.midvecsel > ${TDMODEL}.xymidvecsel
          gawk '{ printf "%f %f %.1f\n", $1, $2, sqrt($3*$3+$4*$4) }' ${TDMODEL}.midvecsel > ${TDMODEL}.fsliplabelsel
          gmt pstext -F+f${SLIP_FONTSIZE},${SLIP_FONT},${SLIP_FONTCOLOR}+jCM $RJOK ${TDMODEL}.fsliplabelsel $VERBOSE >> map.ps
          ;;
        y)              # Fault segment midpoint slip rates, text on fault only, only plot when the "distance" between the point and the last point is larger than a set value
          info_msg "TDEFNODE fault midpoint slip rates, label only - near cutoff = 2"
          gawk -v cutoff=${SLIP_DIST} 'BEGIN {dist=0;lastx=9999;lasty=9999} {
              newdist = sqrt(($1-lastx)*($1-lastx)+($2-lasty)*($2-lasty));
              if (newdist > cutoff) {
                lastx=$1
                lasty=$2
                print $1, $2, $3, $4, $5, $6, $7, $8
              }
          }' < ${TDPATH}${TDMODEL}_mid.vec > ${TDMODEL}.midvecsel
          gawk '{ printf "%f %f %.1f\n", $1, $2, sqrt($3*$3+$4*$4) }' ${TDMODEL}.midvecsel > ${TDMODEL}.fsliplabelsel
          gmt pstext -F+f6,Helvetica-Bold,white+jCM $RJOK ${TDMODEL}.fsliplabelsel $VERBOSE >> map.ps
          ;;
        e)              # elastic component of velocity CONVERT TO PSVELO
          info_msg "TDEFNODE elastic component of velocity"
          legendwords+=("TDEFelasticvelocity")

          gawk '{ if ($5==1 && $6==1) print $8, $9, $28, $29, 0, 0, 1, $1 }' ${TDPATH}${TDMODEL}.vsum > ${TDMODEL}.elastic
          gawk -v gpsscalefac=$VELSCALE '{ az=atan2($3, $4) * 180 / 3.14159265358979; if (az > 0) print $1, $2, az, sqrt($3*$3+$4*$4)*gpsscalefac; else print $1, $2, az+360, sqrt($3*$3+$4*$4)*gpsscalefac; }' ${TDMODEL}.elastic > ${TDMODEL}.xyelastic
          gmt psxy -SV$ARROWFMT -W0.1p,black -Ggray ${TDMODEL}.xyelastic  $RJOK $VERBOSE >> map.ps
          ;;
        t)              # rotation component of velocity; CONVERT TO PSVELO
          info_msg "TDEFNODE block rotation component of velocity"
          legendwords+=("TDEFrotationvelocity")

          gawk '{ if ($5==1 && $6==1) print $8, $9, $38, $39, 0, 0, 1, $1 }' ${TDPATH}${TDMODEL}.vsum > ${TDMODEL}.block
          gawk -v gpsscalefac=$VELSCALE '{ az=atan2($3, $4) * 180 / 3.14159265358979; if (az > 0) print $1, $2, az, sqrt($3*$3+$4*$4)*gpsscalefac; else print $1, $2, az+360, sqrt($3*$3+$4*$4)*gpsscalefac; }' ${TDMODEL}.block > ${TDMODEL}.xyblock
          gmt psxy -SV$ARROWFMT -W0.1p,black -Ggreen ${TDMODEL}.xyblock $RJOK $VERBOSE >> map.ps
          ;;
      esac
    done < <(printf %s "${TDSTRING}")
    tectoplot_plot_caught=1
    ;;
  esac
}

# function tectoplot_legendbar_tdefnode() {
# }

# function tectoplot_legend_tdefnode() {
# }

# function tectoplot_post_tdefnode() {
#   echo "none"
# }

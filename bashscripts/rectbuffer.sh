#!/bin/bash

# tectoplot
# bashscripts/rectubuffer.sh
# Copyright (c) 2021 Kyle Bradley, all rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


# rectbuffer.sh
# Generate a 'rectangular' style buffer around a polyline by connecting the
# endpoints of angle bisectors passing through vertices. The buffer distance
# is in km and angles are calculated at the vertex. This is an approximation
# to a true distance buffer with 'flat' ends.
#
# Input: polyline.xy buffer_dist(km)
# Output: buffer.xy

# function tecto_tac() {
#   gawk '{
#     data[NR]=$0
#   }
#   END {
#     num=NR
#     for(i=num;i>=1;i--) {
#       print data[i]
#     }
#   }' "$@"
# }
#
# # Track file is lon lat whitespace delimited columns
# TRACK=$1
# [[ ! -e $TRACK ]] && exit 1
# cp $TRACK trackfile.txt
# WIDTHKM=$2
#
# NLINES=$(wc -l < trackfile.txt)
# gawk < trackfile.txt -v numlines="${NLINES}" '
#   @include "tectoplot_functions.awk"
#   # function acos(x)       { return atan2(sqrt(1-x*x), x)   }
#   # function getpi()       { return atan2(0,-1)             }
#   # function deg2rad(deg)  { return (getpi() / 180) * deg   }
#   # function rad2deg(rad)  { return (180 / getpi()) * rad   }
#   # function ave_dir(d1, d2) {
#   #   sumcos=cos(deg2rad(d1))+cos(deg2rad(d2))
#   #   sumsin=sin(deg2rad(d1))+sin(deg2rad(d2))
#   #   val=rad2deg(atan2(sumsin, sumcos))
#   #   return val
#   # }
#   (NR==1) {
#     prevlon=$1
#     prevlat=$2
#     lonA=deg2rad($1)
#     latA=deg2rad($2)
#   }
#   (NR==2) {
#     lonB = deg2rad($1)
#     latB = deg2rad($2)
#     thetaA = (rad2deg(atan2(sin(lonB-lonA)*cos(latB), cos(latA)*sin(latB)-sin(latA)*cos(latB)*cos(lonB-lonA)))+90)%360;
#     printf "%.5f %.5f %.3f\n", prevlon, prevlat, thetaA;
#     prevlat=$2
#     prevlon=$1
#   }
#   (NR>2 && NR<numlines) {
#     lonC = deg2rad($1)
#     latC = deg2rad($2)
#
#     thetaB = (rad2deg(atan2(sin(lonC-lonB)*cos(latC), cos(latB)*sin(latC)-sin(latB)*cos(latC)*cos(lonC-lonB)))+90)%360;
#     printf "%.5f %.5f %.3f\n", prevlon, prevlat, ave_dir(thetaA,thetaB);
#
#     thetaA=thetaB
#     prevlon=$1
#     prevlat=$2
#     lonB=lonC
#     latB=latC
#   }
#   (NR==numlines){
#     lonC = deg2rad($1)
#     latC = deg2rad($2)
#
#     thetaB = (rad2deg(atan2(sin(lonC-lonB)*cos(latC), cos(latB)*sin(latC)-sin(latB)*cos(latC)*cos(lonC-lonB)))+90)%360;
#
#     printf "%.5f %.5f %.3f\n", prevlon, prevlat, ave_dir(thetaB,thetaA);
#
#     printf "%.5f %.5f %.3f\n", $1, $2, thetaB;
#   }' > az_trackfile.txt
#
# rm -f track_buffer.txt rectbuf_back.txt
#
# while read d; do
#   p=($(echo $d))
#   ANTIAZ=$(echo "${p[2]} - 180" | bc -l)
#   gmt project -C${p[0]}/${p[1]} -A${p[2]} -Q -G${WIDTHKM}k -L0/${WIDTHKM} -Vn | tail -n 1 | gawk  '{print $1, $2}' >> track_buffer.txt
#   gmt project -C${p[0]}/${p[1]} -A${ANTIAZ} -Q -G${WIDTHKM}k -L0/${WIDTHKM} -Vn | tail -n 1 | gawk  '{print $1, $2}' >> rectbuf_back.txt
# done < az_trackfile.txt
#
# # Create and close the polygon
# tecto_tac rectbuf_back.txt >> track_buffer.txt
# head -n 1 track_buffer.txt >> track_buffer.txt

function fix_dateline_poly() {
  gawk < $1 '
  function abs(x) { return (x>0)?x:-x }
  BEGIN {
    OFMT="%.12f"
    modifier=0
    getline
    oldlon=$1+0
    oldlat=$2+0
    print (oldlon+modifier+360)%360, oldlat+modifier
  }

  ($1+0==$1) {
    lon=$1+0
    lat=$2+0

    # Check to see if we crossed the dateline
    if (abs(lon-oldlon)>350) {
      if (oldlon > lon) {
        modifier=modifier+360.0
      } else {
        modifier=modifier-360.0
      }
    }
    oldlon=lon
    oldlat=lat
    print (lon+modifier+360)%360, lat
  }'
}

  # Create the profile trackfile
  cat $1 > tmp_trackfile.txt
  MAXWIDTH_KM=$2

  # Calculate the incremental length along profile between points
  gmt mapproject tmp_trackfile.txt -G+uk+i | gawk '{print $3}' > tmp_dist_km.txt

  # Calculate the total along-track length of the profile
  PROFILE_LEN_KM=$(gawk < tmp_dist_km.txt 'BEGIN{val=0}{val=val+$1}END{print val}')
  PROFILE_XMIN=0
  PROFILE_XMAX=$PROFILE_LEN_KM

  if [[ $(echo "${PROFILE_LEN_KM} > 500" | bc) -eq 1 ]]; then
    # echo "Need to subsample track in order to buffer track"
    gmt sample1d tmp_trackfile.txt -Af -T500k > trackfile_subsample.txt
    trackfiletouse=trackfile_subsample.txt
  else
    trackfiletouse=tmp_trackfile.txt
  fi

    # We need to create buffers for each polyline segment and merge them together
    # because ogr2ogr is giving a Bus Error: 10 with my current installation
cat <<-EOF > trackfile_merged_buffers.gmt
# @VGMT1.0
# REGION_STUB
# @Je4326
# @Jp"+proj=longlat +datum=WGS84 +no_defs"
# @Jw"GEOGCS[\"WGS 84\",DATUM[\"WGS_1984\",SPHEROID[\"WGS 84\",6378137,298.257223563,AUTHORITY[\"EPSG\",\"7030\"]],AUTHORITY[\"EPSG\",\"6326\"]],PRIMEM[\"Greenwich\",0,AUTHORITY[\"EPSG\",\"8901\"]],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]],AXIS[\"Latitude\",NORTH],AXIS[\"Longitude\",EAST],AUTHORITY[\"EPSG\",\"4326\"]]"
# @GPOLYGON
# FEATURE_DATA
EOF

      numprofpts=$(wc -l < ${trackfiletouse})
      numsegs=$(echo "$numprofpts - 1" | bc)

      for segind in $(seq 1 $numsegs); do
        # echo segment $segind
        segind_p=$(echo "$segind + 1" | bc -l)

        p1_x=$(cat ${trackfiletouse} | head -n ${segind} | tail -n 1 | gawk 'BEGIN { OFMT="%.12f"} {print $1}')
        p1_z=$(cat ${trackfiletouse} | head -n ${segind} | tail -n 1 | gawk 'BEGIN { OFMT="%.12f"} {print $2}')
        p2_x=$(cat ${trackfiletouse} | head -n ${segind_p} | tail -n 1 | gawk 'BEGIN { OFMT="%.12f"} {print $1}')
        p2_z=$(cat ${trackfiletouse} | head -n ${segind_p} | tail -n 1 | gawk 'BEGIN { OFMT="%.12f"} {print $2}')

        echo ${p1_x} ${p1_z} > piece_${segind}.txt
        echo ${p2_x} ${p2_z} >> piece_${segind}.txt

        # cat piece_${segind}.txt

        # Determine the UTM zone from the track file centroid
        trackcentroid=($(gmt spatial piece_${segind}.txt -Q))

        # echo centroid is ${trackcentroid[0]}

        UTMZONE_EPSG=$(gawk -v v=${trackcentroid[0]} '
          BEGIN {
            while (v>180) { v=v-360 }
            u=(v+180)/6
            val=int(u)+(u>int(u))
            printf("326%02d\n", (val>0)?val:1, val)
          }')

        # echo "segment ${segind} is UTM Zone ${UTMZONE_EPSG}"
        # cat piece_${segind}.txt | gdaltransform -s_srs EPSG:4326 -t_srs EPSG:${UTMZONE_EPSG} -output_xy | gmt spatial -i0,1 -Sb$(echo ${MAXWIDTH_KM} | gawk '{print ($1+0)/2*1000}') | tr '\t' ' ' | gdaltransform -s_srs EPSG:${UTMZONE_EPSG} -t_srs EPSG:4326 -output_xy > piece_${segind}_trackfile_buffer.txt

        gdaltransform -s_srs EPSG:4326 -t_srs EPSG:${UTMZONE_EPSG} -output_xy < piece_${segind}.txt > piece_${segind}_trackfile_utm.txt
        gmt spatial piece_${segind}_trackfile_utm.txt -i0,1 -Sb$(echo ${MAXWIDTH_KM} | gawk '{print ($1+0)/2*1000}') | tr '\t' ' ' > piece_${segind}_trackfile_utm_buffer.txt
        gdaltransform -s_srs EPSG:${UTMZONE_EPSG} -t_srs EPSG:4326 -output_xy < piece_${segind}_trackfile_utm_buffer.txt > piece_${segind}_trackfile_buffer.txt

        echo ">" >> trackfile_merged_buffers.gmt
        fix_dateline_poly piece_${segind}_trackfile_buffer.txt >> trackfile_merged_buffers.gmt
        # rm -f piece_${segind}_trackfile_buffer.txt
      done

      cat trackfile_merged_buffers.gmt 
      fix_dateline_trackfile trackfile_merged_buffers.gmt > trackfile_merged_buffers_2.gmt
      mv trackfile_merged_buffers_2.gmt trackfile_merged_buffers.gmt
      echo now
      cat trackfile_merged_buffers.gmt
      ogr2ogr -f "GeoJSON" trackfile_buffer.json trackfile_merged_buffers.gmt
      
      gawk < trackfile_merged_buffers.gmt '($1+0==$1 || $1==">") { print }' > trackfile_buffer.txt

      cp trackfile_buffer.txt trackfile_final_buffer.txt

      ogr2ogr -f "GeoJSON" trackfile_merged_buffers.json trackfile_merged_buffers.gmt

      ogr2ogr trackfile_dissolved_buffers.json trackfile_merged_buffers.json -dialect sqlite -sql "SELECT ST_MakeValid(ST_Union(geometry)) as trackfile_dissolved_buffers FROM trackfile_merged_buffers"

      ogr2ogr -f "OGR_GMT" trackfile_dissolved_buffers.gmt trackfile_dissolved_buffers.json
      gawk < trackfile_dissolved_buffers.gmt '($1+0==$1) { print }' > track_buffer.txt

      gmt mapproject -fg -Af ${trackfiletouse} | gawk '
      BEGIN {
        getline
        lon1=$1
        lat1=$2
      }
      (NR==2) {
        print lon1, lat1, $3-90
      }
      (NR>2) {
        lonend=$1
        latend=$2
        azend=$3-90
      }
      END {
        print lonend, latend, azend
      }' > my_end_points.txt

      p=($(tail -n 1 my_end_points.txt))

      # echo END POINT ${p[0]}/${p[1]} azimuth ${p[2]} width ${p[3]} color ${p[4]}
      CUTBOX_ANTIAZ=$(echo "${p[2]} - 180" | bc -l)
      CUTBOX_FOREAZ=$(echo "${p[2]} - 90" | bc -l)
      CUTBOX_ANTIFOREAZ=$(echo "${p[2]} + 90" | bc -l)
      CUTBOX_WIDTHKM=$(echo "${MAXWIDTH_KM}*1.1 / 2" | bc -l) # Half width plus 5 percent
      CUTBOX_SUBWIDTH=$(echo "${CUTBOX_WIDTHKM}*1.05" | bc -l) # Full width plus 5 percent
      CUTBOX_ADDWIDTH=$(echo "${CUTBOX_WIDTHKM}*0.01" | bc -l) # Full width plus 5 percent

      echo ">" >> end_profile_cutbox.gmt

      # The first point is offset from the origin in the direction of the
      gmt project -C${p[0]}/${p[1]} -A${p[2]} -Q -G${CUTBOX_WIDTHKM}k -L0/${CUTBOX_WIDTHKM} | tail -n 1 | gawk  '{print $1, $2}' > endpoint1.txt
      gmt project -C${p[0]}/${p[1]} -A${CUTBOX_ANTIAZ} -Q -G${CUTBOX_WIDTHKM}k -L0/${CUTBOX_WIDTHKM} | tail -n 1 | gawk  '{print $1, $2}' > endpoint2.txt

      cat endpoint1.txt | gmt vector -Tt${CUTBOX_ANTIFOREAZ}/${CUTBOX_ADDWIDTH}k > closepoint1.txt
      cat endpoint2.txt | gmt vector -Tt${CUTBOX_ANTIFOREAZ}/${CUTBOX_ADDWIDTH}k > closepoint2.txt
      cat endpoint1.txt | gmt vector -Tt${CUTBOX_ANTIFOREAZ}/${CUTBOX_SUBWIDTH}k > farpoint1.txt
      cat endpoint2.txt | gmt vector -Tt${CUTBOX_ANTIFOREAZ}/${CUTBOX_SUBWIDTH}k > farpoint2.txt

      # Build the box
      # Start with the endpoint itself
      echo "${p[0]} ${p[1]}" > end_profile_cutbox_pre.txt
      cat closepoint1.txt >> end_profile_cutbox_pre.txt
      cat farpoint1.txt >> end_profile_cutbox_pre.txt
      cat farpoint2.txt >> end_profile_cutbox_pre.txt
      cat closepoint2.txt >> end_profile_cutbox_pre.txt
      echo "${p[0]} ${p[1]}" >> end_profile_cutbox_pre.txt

      fix_dateline_poly end_profile_cutbox_pre.txt >> end_profile_cutbox.gmt


      # gmt psxy ${F_PROFILES}end_profile_lines.txt -W${PROFILE_TRACK_WIDTH},${p[4]} $RJOK $VERBOSE >> map.ps

      p=($(head -n 1 my_end_points.txt))
      # echo END POINT ${p[0]}/${p[1]} azimuth ${p[2]} width ${p[3]} color ${p[4]}
      CUTBOX_ANTIAZ=$(echo "${p[2]} - 180" | bc -l)
      CUTBOX_FOREAZ=$(echo "${p[2]} - 90" | bc -l)
      CUTBOX_ANTIFOREAZ=$(echo "${p[2]} + 90" | bc -l)
      CUTBOX_WIDTHKM=$(echo "${MAXWIDTH_KM}*1.1 / 2" | bc -l) # Half width plus 5 percent
      CUTBOX_SUBWIDTH=$(echo "${CUTBOX_WIDTHKM}*1.05" | bc -l) # Full width plus 5 percent
      CUTBOX_ADDWIDTH=$(echo "${CUTBOX_WIDTHKM}*0.01" | bc -l) # Full width plus 5 percent

      echo ">" >> end_profile_cutbox.gmt

      # The first point is offset from the origin in the direction of the
      gmt project -C${p[0]}/${p[1]} -A${p[2]} -Q -G${CUTBOX_WIDTHKM}k -L0/${CUTBOX_WIDTHKM} | tail -n 1 | gawk  '{print $1, $2}' > endpoint1.txt
      gmt project -C${p[0]}/${p[1]} -A${CUTBOX_ANTIAZ} -Q -G${CUTBOX_WIDTHKM}k -L0/${CUTBOX_WIDTHKM} | tail -n 1 | gawk  '{print $1, $2}' > endpoint2.txt

      cat endpoint1.txt | gmt vector -Tt${CUTBOX_FOREAZ}/${CUTBOX_ADDWIDTH}k > closepoint1.txt
      cat endpoint2.txt | gmt vector -Tt${CUTBOX_FOREAZ}/${CUTBOX_ADDWIDTH}k > closepoint2.txt
      cat endpoint1.txt | gmt vector -Tt${CUTBOX_FOREAZ}/${CUTBOX_SUBWIDTH}k > farpoint1.txt
      cat endpoint2.txt | gmt vector -Tt${CUTBOX_FOREAZ}/${CUTBOX_SUBWIDTH}k > farpoint2.txt

      # Build the box
      # Start with the endpoint itself
      echo "${p[0]} ${p[1]}" > end_profile_cutbox_pre.txt
      cat closepoint1.txt >> end_profile_cutbox_pre.txt
      cat farpoint1.txt >> end_profile_cutbox_pre.txt
      cat farpoint2.txt >> end_profile_cutbox_pre.txt
      cat closepoint2.txt >> end_profile_cutbox_pre.txt
      echo "${p[0]} ${p[1]}" >> end_profile_cutbox_pre.txt

      fix_dateline_poly end_profile_cutbox_pre.txt >> end_profile_cutbox.gmt

      ogr2ogr -f "GeoJSON" end_profile_cutbox.json end_profile_cutbox.gmt

      # Subsample the buffer track to 1 km minimum point spacing, keeping points
      gmt sample1d track_buffer.txt -Af -T1k > track_buffer_resample.txt

      gmt select track_buffer.txt -fg -Fend_profile_cutbox.gmt -If > trackfile_final_buffer.txt

      # Cut the buffer and joing the first and last points if necessary
      fix_dateline_poly track_buffer_resample.txt | gmt select -Fend_profile_cutbox.gmt -If | gawk '
      BEGIN {
        saw=0
      }
      {
        print
        if ($1+0==$1) {
          if (saw==0) {
            saw=1
            firstlon=$1
            firstlat=$2
          } else {
            lastlon=$1
            lastlon=$2
          }
        }
      }
      END {
        if (firstlon != lastlon || firstlat != lastlat) {
          print firstlon, firstlat
        }
      }' > trackfile_final_buffer.txt

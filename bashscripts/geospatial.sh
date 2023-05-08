# tectoplot

# bashscripts/geospatial.sh
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

#########
# geod / GMT functions

# Find a point located a given distance and azimuth from an input point, using
# the WGS84 ellipsoid. Note: path is not a rhumbline!!!
# args: 1=lon 2=lat 3=azimuth (deg, CW from N), 4=distance 5=unit
function project_point_dist_az() {
  echo "$2 $1 $3 $4" | geod +ellps=WGS84 +units=${5} -f "%f" | gawk '{print $2, $1}'
}

# Use GMT to find location of a point projected eastward along a parallel
# args: 1=lon 2=lat 3=distance 5=unit. Note: seems to be imprecise!!!

function project_point_parallel_dist() {
  local POLEPOS="0/-90"
  if [[ $(echo "$2 >= 0" | bc -l) -ne 1 ]]; then
    POLEPOS="0/90"
  fi
  local nounits=$(echo $3 | gawk '{print $1+0}')
  # gmt project -C${p[0]}/${p[1]} -A${p[2]} -Q -G${WIDTHKM}k -L0/${WIDTHKM} | tail -n 1 | gawk  '{print $1, $2}'
  # echo gmt project -C$1/$2 -T${POLEPOS} -G${3} -L0/5000 -Q
  # gmt project -C$1/$2 -T${POLEPOS} -G${3} -L0/5000 -Q

  # Somehow, lon=38 lat=32 FAILS but lon=38 lat=32.0001 doesn't (GMT 6.1.1) ?????
  local lon=$1
  local lat=$2

  #
  # local poleantilat=$(echo "0 - (${polelat}+0.0000001)" | bc -l)
  # local poleantilon=$(echo "${polelon}" | gawk  '{if ($1 < 0) { print $1+180 } else { print $1-180 } }')

  # Distance needs to be distance in km
  # -G requires the angular distance from the north pole to the site
  local poledist=$(echo "90 - ${lat}" | bc -l)
  gmt project -T0/90 -C${lon}/${lat} -G${nounits}/${poledist} -L0/${nounits} -Q -Ve | gawk '{print $1, $2}' | tail -n 1
}

# Calculate the location of a point displaced eastward along a parallel from
# a given point by a given number of kilometers

# args: 1:lon 2:lat 3:dist (km)
function project_point_parallel_wgs84() {
  local LON=$1
  local LAT=$2
  # WGS84 parameters
  local L1=6378137
  local A1=297257223563
  local A2=298257223563
  local dist=$3 # km
  local deltalon=$(gawk -v l1=$L1 -v a1=$A1 -v a2=$A2 -v lat=$LAT -v dist=${dist} '
  function getpi()       { return atan2(0,-1)             }
  function tan(x)        { return sin(x)/cos(x)           }
  function atan(x)       { return atan2(x,1)              }
  function deg2rad(deg)  { return (getpi() / 180) * deg   }
  BEGIN {
    # radius of the parallel circle
    rlat=l1*cos(atan(a1/a2 * tan(deg2rad(lat))))
    # change in longitude corresponding to a given along-arc distance in km
    deltalon=(dist * 1000) / (2 * getpi() * rlat) * 360
    printf("%f", deltalon)
  }')
  echo $(echo "$LON + $deltalon" | bc -l) $LAT
}

# Find the coordinates of a point on the map that correspond to an X and Y
# offset in projected coordinates (points) from a specified lon/lat point.
# expects RJSTRING to be correctly set
# args: 1=lon 2=lat 3=xoffset 4=yoffset

function point_map_offset() {
  echo "$1 $2" | gmt mapproject ${RJSTRING} | gawk -v xoffset=$3 -v yoffset=$4 '{print $1+xoffset/72, $2+yoffset/72}' |  gmt mapproject -I ${RJSTRING}
}

# Same as before but rotate by theta degrees, clockwise
function point_map_offset_rotate_m90() {
  echo "$1 $2" | gmt mapproject ${RJSTRING} | gawk -v xoffset=$3 -v yoffset=$4 -v theta=$5 '
    @include "tectoplot_functions.awk"
    {
      xoff=xoffset*cos(deg2rad(0-theta+90))-yoffset*sin(deg2rad(0-theta+90))
      yoff=xoffset*sin(deg2rad(0-theta+90))+yoffset*cos(deg2rad(0-theta+90))
      print $1+xoff/72, $2+yoff/72
    }' |  gmt mapproject -I ${RJSTRING}
}

# return the azimuth on the map (projected units) between two geographic points
# args: 1=lon1 2=lat1 3=lon2 4=lat2
function onmap_angle_between_points() {
  mapcoords1=($(echo "$1 $2" | gmt mapproject ${RJSTRING}))
  mapcoords2=($(echo "$3 $4" | gmt mapproject ${RJSTRING}))

  echo ${mapcoords1[@]} ${mapcoords2[@]} | gawk '
  @include "tectoplot_functions.awk"
  {
    print azimuth_from_en($3-$1, $4-$2)
  }'
}

# args: 1=lon1 2=lat1 3=lon2 4=lat2
function onmap_distance_between_points() {
  mapcoords1=($(echo "$1 $2" | gmt mapproject ${RJSTRING}))
  mapcoords2=($(echo "$3 $4" | gmt mapproject ${RJSTRING}))

  echo ${mapcoords1[@]} ${mapcoords2[@]} | gawk '
  @include "tectoplot_functions.awk"
  {
    print sqrt(($3-$1)^2 + ($4-$2)^2)
  }'
}

function azimuth_to_justcode() {
  echo $1 | gawk '
  {
    if ($1>337.5 || $1<22.5) {
      j="TC"
    } else if ($1>292.5) {
      j="TL"
    } else if ($1>247.5) {
      j="ML"
    } else if ($1>202.5) {
      j="BL"
    } else if ($1>157.5) {
      j="BC"
    } else if ($1>112.5) {
      j="BR"
    } else if ($1>67.5) {
      j="MR"
    } else {
      j="TR"
    }
    print j
  }'
}

################################################################################
# Text processing functions using GMT

# select_in_gmt_map()
# Takes in a text file with first columns lon lat and a GMT region/projection.
# Removes any rows for points that fall on the map.
# Note: The original file is modified in place.

# args: 1=input file 2,3=RJSTRING{@} (e.g. "-R0/1/0/1 -JX5i")
function select_in_gmt_map {
  gmt select ${@} -f0x,1y,2s -i0,1,t -o0,1,t ${VERBOSE} > a.tmp
  mv a.tmp "${1}"
}

function select_in_gmt_map_tab {
  inputfile="${1}"
  shift
  gawk < "${inputfile}" '{
    print $1, $2, NR
  }' | gmt select ${@} -f0x,1y,s -i0,1,t ${VERBOSE} > preselect.tmp

  gawk '
  (NR==FNR) {
    id[$3]=1
  }
  (NR!=FNR) {
    if(id[FNR]==1) {
      print
    }
  }' preselect.tmp "${inputfile}" > postselect.tmp
  cp postselect.tmp "${inputfile}"
}


# select_in_gmt_map_by_columns()
# Takes in a text file and removes rows for which the points indicated in
# specified X,Y columns do not fall on the map.
# Column numbers start with 1 not 0
# Note: the original file is modified in place.
# args: 1 = X coord column number, 2 = Y coord column number
#       3 = file 4... = region (-R) or region and projection (-R -J)

function select_in_gmt_map_by_columns() {
    xcol=$(echo "$1" | bc)
    ycol=$(echo "$2" | bc)
    infile="${3}"
    shift
    shift
    shift
    # Switch columns xcol and ycol with columns 1 and 2
    gawk < $infile -v xc=$xcol -v yc=$ycol '
    {
      for(i=1;i<=NF;i++) {
        if (i==1) {
          printf("%s ", $(xc))
        } else if (i==2) {
          printf("%s ", $(yc))
        } else if (i==xc) {
          printf("%s ", $1)
        } else if (i==yc) {
          printf("%s ", $2)
        } else if (i==NF) {
          printf("%s\n", $(i))
        } else {
          printf("%s ", $(i))
        }
      }
    }' | gmt select ${@} -f0x,1y,s -i0,1,t -o0,1,t ${VERBOSE} | gawk -v xc=$xcol -v yc=$ycol '
    {
      for(i=1;i<=NF;i++) {
        if (i==1) {
          printf("%s ", $(xc))
        } else if (i==2) {
          printf("%s ", $(yc))
        } else if (i==xc) {
          printf("%s ", $1)
        } else if (i==yc) {
          printf("%s ", $2)
        } else if (i==NF) {
          printf("%s\n", $(i))
        } else {
          printf("%s ", $(i))
        }
      }
    }' > a.tmp
    mv a.tmp $infile
}

# select_in_gmt_map_by_columns()
# Takes in a text file and removes rows for which the points indicated in
# specified X,Y columns do not fall on the map.
# Column numbers start with 1 not 0
# Note: the output is piped to stdout
# args: 1 = X coord column number, 2 = Y coord column number
#       3 = file 4... = region (-R) or region and projection (-R -J)

function select_in_gmt_map_by_columns_stdout() {
    xcol=$(echo "$1" | bc)
    ycol=$(echo "$2" | bc)
    infile="${3}"
    shift
    shift
    shift
    # Switch columns xcol and ycol with columns 1 and 2
    gawk < $infile -v xc=$xcol -v yc=$ycol '
    {
      for(i=1;i<=NF;i++) {
        if (i==1) {
          printf("%s ", $(xc))
        } else if (i==2) {
          printf("%s ", $(yc))
        } else if (i==xc) {
          printf("%s ", $1)
        } else if (i==yc) {
          printf("%s ", $2)
        } else if (i==NF) {
          printf("%s\n", $(i))
        } else {
          printf("%s ", $(i))
        }
      }
    }' | gmt select ${@} -f0x,1y,s -i0,1,t -o0,1,t ${VERBOSE} | gawk -v xc=$xcol -v yc=$ycol '
    {
      for(i=1;i<=NF;i++) {
        if (i==1) {
          printf("%s ", $(xc))
        } else if (i==2) {
          printf("%s ", $(yc))
        } else if (i==xc) {
          printf("%s ", $1)
        } else if (i==yc) {
          printf("%s ", $2)
        } else if (i==NF) {
          printf("%s\n", $(i))
        } else {
          printf("%s ", $(i))
        }
      }
    }' 
}

################################################################################
# Grid (raster) file functions

# Grid z range query function. Try to avoid querying the full grid when determining the range of Z values

# A new function
function grid_zrange() {
  gdalinfo $1 -stats 2>/dev/null | grep "Minimum=" | tr '=' ' ' | tr ',' ' ' | gawk '{print $2, $4}'
}

function grid_pixelsize() {
  gdalinfo $1 | grep "Size is" | gawk '{print substr($3,1,length($3)-1), $4}'
}

function grid_xyrange() {
  echo $(gdalinfo $1 | grep "Upper Left" | tr '(' ' ' | tr ')' ' ' | tr ',' ' ' | gawk '{printf("%s %s ", $3, $4)}') $(gdalinfo $1 | grep "Lower Right" | tr '(' ' ' | tr ')' ' ' | tr ',' ' ' | gawk '{printf("%s %s\n", $3, $4)}') | gawk '{print $1, $3, $4, $2}'
}

# Old function that failed for some grids
# function grid_zrange() {
#    output=$(gmt grdinfo -C -Vn $@)
#    zmin=$(echo "${output}" | gawk  '{printf "%f", $6+0}')
#    zmax=$(echo "${output}" | gawk  '{printf "%f", $7+0}')
#    if [[ $(echo "$zmin == 0 && $zmax == 0" | bc) -eq 1 ]]; then
#       output=$(gmt grdinfo -C -L0 $@)
#    fi
#    echo "${output}" | gawk  '{printf "%f %f", $6+0, $7+0}'
# }

################################################################################
# XY (point and line) file functions

# XY range query function from a delimited text file
# variable=($(xy_range data_file.txt [[delimiter]]))
# Ignores lines that do not have numerical first and second columns

function xy_range() {
  local IFSval=""
  if [[ $2 == "" ]]; then
    IFSval=" "
  else
    IFSval="-F${2:0:1}"
  fi
  gawk < "${1}" ${IFSval} '
    BEGIN {
      minlon="NaN"
      while (minlon=="NaN") {
        getline
        if ($1 == ($1+0) && $2 == ($2+0)) {
          minlon=($1+0)
          maxlon=($1+0)
          minlat=($2+0)
          maxlat=($2+0)
        }
      }
    }
    {
      if ($1 == ($1+0) && $2 == ($2+0)) {
        minlon=($1<minlon)?($1+0):minlon
        maxlon=($1>maxlon)?($1+0):maxlon
        minlat=($2<minlat)?($2+0):minlat
        maxlat=($2>maxlat)?($2+0):maxlat
      }
    }
    END {
      print minlon, maxlon, minlat, maxlat
    }'
}

# Randomize the lines in a text file with a given random seed
# args 1:seed 2:infile 3:outfile
function randomize_lines() {
  RANDOM=$1  # Confirmed to produce unique numbers for at least 300 calls

  gawk -v seed=${1} '
    BEGIN {
      srand(seed); 
      OFMT="%.17f"
    } 
    { 
      print rand(), $0 
    }' "${2}" | sort -k1,1n | cut -d ' ' -f2- > "${3}"
}

  # rm -f "${3}"
  # local a
  # while IFS= read -r line; do a+=("$line"); done < $2
  # for i in ${!a[@]}; do a[$((RANDOM+${#a[@]}))]="${a[$i]}"; unset a[$i]; done
  # for i in ${!a[@]}; do
  #   echo ${a[${i}]} >> "${3}"
  # done


# function that takes in file of lon lat polyline/polygons and removes large
# jumps in longitude across the dateline

function fix_dateline_poly() {
  OFMT='%f' gawk < $1 '
  function abs(x) { return (x>0)?x:-x }
  function addf(u,v, a, b) {
    split(u,a,".")
    split(v,b,".")
    return sprintf("%d.%d", a[1]+b[1], a[2]+b[2])
  }

  BEGIN {
    getmore=1
    while (getmore==1) {
      getline
      if ($1+0==$1) {
        oldlon=$1+0
        oldlat=$2+0
        getmore=0
      }
      print
    }
    modifier=0
  }

  ($1+0!=$1) {
    getmore=1
    print
    while (getmore==1) {
      getline
      if ($1+0==$1) {
        oldlon=$1+0
        oldlat=$2+0
        getmore=0
      }
      print
      modifier=0
    }
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
    print addf(lon,modifier), lat
  }'
}

# Updated to return longitudes > 0 for all points
function fix_dateline_trackfile() {
  OFMT='%f' gawk < $1 '
  function abs(x) { return (x>0)?x:-x }
  function addf(u,v, a, b) {
    split(u,a,".")
    split(v,b,".")
    return sprintf("%d.%d", a[1]+b[1], a[2]+b[2])
  }

  BEGIN {
    getmore=1
    while (getmore==1) {
      getline
      if ($1+0==$1) {
        oldlon=$1+0
        oldlat=$2+0
        getmore=0
      }
      print
    }
    modifier=0
  }

  ($1+0!=$1) {
    getmore=1
    print
    while (getmore==1) {
      getline
      if ($1+0==$1) {
        oldlon=$1+0
        oldlat=$2+0
        getmore=0
      }
      print
      modifier=0
    }
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
    print (addf(lon,modifier)+360), lat
  }'
}


function poly_crosses_dateline() {
  OFMT='%f' gawk < $1 '
  function abs(x) { return (x>0)?x:-x }

  BEGIN {
    returncode=0
    getmore=1
    while (getmore==1) {
      getline
      if ($1+0==$1) {
        if (abs(lon-oldlon)>330) {
          returncode=1
          exit
        }
        oldlon=$1+0
        oldlat=$2+0
        getmore=0
      }
    }
    modifier=0
  }

  ($1+0!=$1) {
    getmore=1
    while (getmore==1) {
      getline
      if ($1+0==$1) {
        lon=$1+0
        lat=$2+0
        if (abs(lon-oldlon)>330) {
          returncode=1
          exit
        }
        oldlon=$1+0
        oldlat=$2+0
        getmore=0
      }
      modifier=0
    }
  }
  ($1+0==$1) {
    lon=$1+0
    lat=$2+0
    # Check to see if we crossed the dateline
    if (abs(lon-oldlon)>330) {
      returncode=1
      exit
    }
    oldlon=lon
    oldlat=lat
  }
  END {
    print returncode
  }'
}

function fix_dateline_poly_plusfields() {
  OFMT='%f' gawk < $1 '
  function abs(x) { return (x>0)?x:-x }
  function addf(u,v, a, b) {
    split(u,a,".")
    split(v,b,".")
    return sprintf("%d.%d", a[1]+b[1], a[2]+b[2])
  }

  BEGIN {
    getmore=1
    while (getmore==1) {
      getline
      if ($1+0==$1) {
        oldlon=$1+0
        oldlat=$2+0
        getmore=0
      }
      print
    }
    modifier=0
  }

  ($1+0!=$1) {
    getmore=1
    print
    while (getmore==1) {
      getline
      if ($1+0==$1) {
        oldlon=$1+0
        oldlat=$2+0
        getmore=0
      }
      print
      modifier=0
    }
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
    $1=""
    $2=""
    print addf(lon,modifier)%360, lat, $0
  }'
}

# gawk code inspired by lat_lon_parser.py by Christopher Barker
# https://github.com/NOAA-ORR-ERD/lat_lon_parser

# This function will take a string in the (approximate) form
# +-[deg][chars][min][chars][sec][chars][north|*n*]|[south|*s*]|[east|*e*]|[west|*w*][chars]
# and return the appropriately signed decimal degree
# -125°12'18" -> -125.205
# 125 12 18 WEST -> -125.205


function coordinate_parse() {
  echo "${1}" | gawk '
  @include "tectoplot_functions.awk"
  {
    printf("%.10f\n", coordinate_decimal($0))
  }'
}

# Convert first line/polygon element in KML file $1, store output XY file in $2

function kml_to_first_xy() {
  ogr2ogr -f "OGR_GMT" ./tectoplot_tmp.gmt "${1}"
  gawk < ./tectoplot_tmp.gmt '
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
    }' > "${2}"
    rm -f ./tectoplot_tmp.gmt
}

# Convert first line/polygon element in KML file $1, store output XY file in $2

function kml_to_all_xy() {
  ogr2ogr -f "OGR_GMT" ./tectoplot_tmp.gmt "${1}"
  gawk < ./tectoplot_tmp.gmt '
    BEGIN {
      count=0
    }
    ($1==">") {
      print
      # getline
      # if (substr($0,1,1)=="#") {
      #   print ">", $2
      # } else {
      #   print ">"
      # }
    }
    ($1+0==$1) {
      print $1, $2
    }' > "${2}"
    rm -f ./tectoplot_tmp.gmt
}

function kml_to_all_gmt() {
  ogr2ogr -f "OGR_GMT" ${2} ${1}
}

# Convert first line/polygon element in KML file $1, store output XY file in $2
# Close the polygon if necessary

function kml_to_first_poly() {
  ogr2ogr -f "OGR_GMT" ./tectoplot_tmp.gmt "${1}"
  gawk < ./tectoplot_tmp.gmt '
    BEGIN {
      count=0
      printcount=0
    }
    ($1==">") {
      count++
      if (count>1) {
        exit
      }
    }
    ($1+0==$1) {
      if (printcount==0) {
        first_x=$1
        first_y=$2
      }
      print $1, $2
      last_x=$1
      last_y=$2
      printcount=1

    }
    END {
      if (first_x != last_x || first+y != last_y) {
        print first_x, first_y
      }
    }' > "${2}"
    rm -f ./tectoplot_tmp.gmt
}


function kml_to_points() {
  ogr2ogr -f "OGR_GMT" ./tectoplot_tmp.gmt "${1}"
  gawk < ./tectoplot_tmp.gmt '
    BEGIN {
      count=0
    }
    ($1+0==$1) {
      print $1, $2
    }' > "${2}"
    rm -f ./tectoplot_tmp.gmt
}

# Sample one or more grids at point locations using gmt grdtrack, accounting
# for the possibility that the grid is in an incorrect 360 degree range.
# Only returns the Z values and not the original points_file

# sample_grid_360 points_file grid1 grid2 ... gridN

# Output is piped to stdout.

function sample_grid_360() {
  local gridlist
  num_args=${#@}

  points_file=$1
  shift

  rm -f collated.tmp

  gmt_init_tmpdir

  while [[ ${#@} -gt 0 ]]; do
    grid_file=$1
    shift

    gmt grdtrack $points_file -G"${grid_file}" ${VERBOSE} -fg -Z -N > output.tmp

    # Check whether we just got NaNs

    shouldredo=$(gawk < output.tmp '
      BEGIN {
        redo=1
      }
      ($(NF) != "NaN") {
        redo=0
        exit
      }
      END {
        print redo
      }
    ')

    if [[ $shouldredo -eq 1 ]]; then
      gawk < $points_file '
      {
        $1=$1+360
        print $0
      }' > newfile.txt

      gmt grdtrack newfile.txt -G"${grid_file}" ${VERBOSE} -fg -Z -N > output.tmp

      shouldredo=$(gawk < output.tmp '
        BEGIN {
          redo=1
        }
        ($(NF) != "NaN") {
          redo=0
          exit
        }
        END {
          print redo
        }
      ')

      if [[ $shouldredo -eq 1 ]]; then
        gawk < $points_file '
        {
          $1=$1-360
          print $0
        }' > newfile.txt

        gmt grdtrack newfile.txt -G"${grid_file}" ${VERBOSE} -fg -Z -N > output.tmp

        shouldredo=$(gawk < output.tmp '
          BEGIN {
            redo=1
          }
          ($(NF) != "NaN") {
            redo=0
            exit
          }
          END {
            print redo
          }
        ')

        if [[ $shouldredo -eq 1 ]]; then
          echo "Warning: Could not sample Slab2 with input points... all NaN in output."
        fi
      fi
    fi
    if [[ -s collated.tmp ]]; then
      paste collated.tmp output.tmp > collated_new.tmp
      mv collated_new.tmp collated.tmp
    else
      mv output.tmp collated.tmp
    fi
  done
  cat collated.tmp
  rm -f collated.tmp output.tmp collated_new.tmp

  gmt_remove_tmpdir
}

# CPT-related functions

# CPT is a four column CPT with R/G/B or H-S-V or colorname colors
# Prints minimum, maximum values indicated in CPT and also checks for a 0 slice
function cptinfo {
 gawk < $1 '
  BEGIN {
    haszero=0
    breakout=0
    while (breakout==0) {
      getline
      if ($1+0==$1) {
        minz=($1<$3)?$1:$3
        maxz=($1>$3)?$1:$3
        breakout=1
      }
    }
  }
  ($1+0==$1){
    minz=($1<minz)?$1:minz
    minz=($3<minz)?$3:minz

    maxz=($1>maxz)?$1:maxz
    maxz=($3>maxz)?$3:maxz
  }
  ($1==0) {
    haszero=1
  }
  END {
    print minz, maxz, haszero
  }'
}

# GPKG
# ogr2ogr -spat does not work across datelines... so split into two queries and merge
# if necessary
# arg1=minlon
# arg2=maxlon
# arg3=minlat
# arg4=maxlat
# arg5=sourcefile.gpkg
# arg6=outfile_name.gpkg

function ogr2ogr_spat() {
  local SPAT_MINLON_1
  local SPAT_MAXLON_1
  local SPAT_TYPE
  local MINLON="${1}"
  shift
  local MAXLON="${1}"
  shift
  local MINLAT="${1}"
  shift
  local MAXLAT="${1}"
  shift
  local output_file="${1}"
  shift
  local input_file="${1}"
  shift

  local wherecmd
  if [[ -s ogr2ogr_spat.where ]]; then
    wherecmd="-where @ogr2ogr_spat.where"
  else
    wherecmd=""
  fi

  # All remaining arguments are in "${@}"


  if [[ -s ${output_file} ]]; then
    echo "[geospatial:ogr2ogr_spat]: output file ${output_file} exists; not overwriting"
    return
  fi

  if [[ $(echo "${MAXLON} > 180 && ${MINLON} > 180" | bc -l) -eq 1  ]]; then
    #             220      290
    # ----------|--------------#
    #              <         >
    #            -140      -70
    SPAT_MINLON_1=$(echo "${MINLON} - 360" | bc -l)
    SPAT_MAXLON_1=$(echo "${MAXLON} - 360" | bc -l)
    SPAT_TYPE=1
  elif [[ $(echo "${MAXLON} < -180 && ${MINLON} < -180" | bc -l) -eq 1  ]]; then
    # -220 -190
    # ----------|--------------#
    # <       >
    # 140   170
    SPAT_MINLON_1=$(echo "${MINLON} + 360" | bc -l)
    SPAT_MAXLON_1=$(echo "${MAXLON} + 360" | bc -l)
    SPAT_TYPE=1
  elif [[ $(echo "${MAXLON} > -180 && ${MINLON} < -180" | bc -l) -eq 1  ]]; then
    # -220             -120
    # ----------|--------------#
    # <                   >
    # 140    180 -180  -120
    SPAT_MINLON_1=$(echo "${MINLON}+360" | bc -l)
    SPAT_MAXLON_1=180
    SPAT_MINLON_2=-180
    SPAT_MAXLON_2=${MAXLON}
    SPAT_TYPE=2
  elif [[ $(echo "${MAXLON} > 180 && ${MINLON} < 180" | bc -l) -eq 1  ]]; then
    #    140            240
    # ----------|--------------#
    #    <                >
    #    140 180 -180  -120
    SPAT_MINLON_1=${MINLON}
    SPAT_MAXLON_1=180
    SPAT_MINLON_2=-180
    SPAT_MAXLON_2=$(echo "${MAXLON} - 360" | bc -l)
    SPAT_TYPE=2
  else
    SPAT_MINLON_1=${MINLON}
    SPAT_MAXLON_1=${MAXLON}
    SPAT_TYPE=1
  fi

  case ${SPAT_TYPE} in
    1)
      # echo "ogr2ogr_spat one only"
      # echo ogr2ogr -spat ${SPAT_MINLON_1} ${MINLAT} ${SPAT_MAXLON_1} ${MAXLAT} -f "GPKG" ${wherecmd} ${output_file} ${input_file}
      ogr2ogr -spat ${SPAT_MINLON_1} ${MINLAT} ${SPAT_MAXLON_1} ${MAXLAT} -f "GPKG" ${wherecmd} ${output_file} ${input_file}
    ;;
    2)
      # echo "ogr2ogr_spat twice"
      # echo ogr2ogr -spat ${SPAT_MINLON_1} ${MINLAT} ${SPAT_MAXLON_1} ${MAXLAT} -f "GPKG" ${wherecmd} ${output_file} ${input_file}
      # echo ogr2ogr -spat ${SPAT_MINLON_2} ${MINLAT} ${SPAT_MAXLON_2} ${MAXLAT} -f "GPKG" ${wherecmd} selected_2.gpkg ${input_file}

      ogr2ogr -spat ${SPAT_MINLON_1} ${MINLAT} ${SPAT_MAXLON_1} ${MAXLAT} -f "GPKG" ${wherecmd} ${output_file} ${input_file}
      ogr2ogr -spat ${SPAT_MINLON_2} ${MINLAT} ${SPAT_MAXLON_2} ${MAXLAT} -f "GPKG" ${wherecmd} selected_2.gpkg ${input_file}
      ogr2ogr -f "GPKG" -upsert ${output_file} selected_2.gpkg && rm -f selected_2.gpkg
    ;;
  esac
}
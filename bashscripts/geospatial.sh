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

################################################################################
# Text processing functions using GMT

# select_in_gmt_map()
# Takes in a text file with first columns lon lat and a GMT region/projection.
# Removes any rows for points that fall on the map.
# Note: The original file is modified in place.

# args: 1=input file 2,3=RJSTRING{@} (e.g. "-R0/1/0/1 -JX5i")
function select_in_gmt_map {
  gmt select ${@} -f0x,1y,s -i0,1,t -o0,1,t ${VERBOSE} | tr '\t' ' ' > a.tmp
  mv a.tmp "${1}"
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

################################################################################
# Grid (raster) file functions

# Grid z range query function. Try to avoid querying the full grid when determining the range of Z values

# A new function
function grid_zrange() {
  gdalinfo $1 -stats | grep "Minimum=" | tr '=' ' ' | tr ',' ' ' | gawk '{print $2, $4}'
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
    }
    ($1+0==$1) {
      print $1, $2
    }' > "${2}"
    rm -f ./tectoplot_tmp.gmt
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

  while [[ ${#@} -gt 0 ]]; do
    grid_file=$1
    shift

    gmt grdtrack $points_file -G"${grid_file}" ${VERBOSE} -Z -N > output.tmp

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

      gmt grdtrack newfile.txt -G"${grid_file}" ${VERBOSE} -Z -N > output.tmp

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

        gmt grdtrack newfile.txt -G"${grid_file}" ${VERBOSE} -Z -N > output.tmp

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
}

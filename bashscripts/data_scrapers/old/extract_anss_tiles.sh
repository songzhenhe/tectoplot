#!/bin/bash

# tectoplot
# bashscripts/extract_anss.sh
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

# extract_anss.sh ZIPPATH_OLD ZIPPATH_NEW MINLON MAXLON MINLAT MAXLAT MINTIME MAXTIME MINMAG MAXMAG MINDEPTH MAXDEPTH OUTFILE

# This script will print all events from a tiled ANSS catalog directory (tile_lon_lat.cat) to OUTFILE
# The tile files are in Comcat CSV format without a header line.

# Additionally, this script will filter out some non-natural events by excluding lines
# containing the words: blast quarry explosion

# CSV format is:
# 1    2        3         4     5   6       7   8   9    10  11  12 13      14    15   16              17         18       19     20     21             22
# time,latitude,longitude,depth,mag,magType,nst,gap,dmin,rms,net,id,updated,place,type,horizontalError,depthError,magError,magNst,status,locationSource,magSource

# Epoch time calculation doesn't work for events before 1900 (mktime returns -1) so return 1900-01-01T00:00:00 time instead

# NOTE: OSX has a strange problem, probably with libc? that makes gawk/awk mktime fail for a few specific
# dates: 1941-09-01, 1942-02-16, and 1982-01-01. This is not a problem on a tested linux machine...

# Reads stdin, converts each item in a column and outputs same column format

# $EXTRACT_ANSS_TILES $ANSS_TILEOLDZIP $ANSS_TILENEWZIP $MINLON $MAXLON $MINLAT $MAXLAT $STARTTIME $ENDTIME $EQ_MINMAG $EQ_MAXMAG $EQCUTMINDEPTH $EQCUTMAXDEPTH ${F_SEIS_FULLPATH}anss_extract_tiles.cat

ANSS_TILEOLDZIP="${1}"
ANSS_TILENEWZIP="${2}"
ARG_OLDDATE="${3}"
MINLON="${4}"
MAXLON="${5}"
MINLAT="${6}"
MAXLAT="${7}"
STARTTIME="${8}"
ENDTIME="${9}"
EQ_MINMAG="${10}"
EQ_MAXMAG="${11}"
EQCUTMINDEPTH="${12}"
EQCUTMAXDEPTH="${13}"
OUTPUTFILE="${14}"


if ! [[ -s $ANSS_TILEOLDZIP ]]; then
  echo "Seismicity tile ZIP file $ANSS_TILEOLDZIP does not exist." > /dev/stderr
  if ! [[ -s $ANSS_TILEOLDZIP ]]; then
    echo "Seismicity tile new ZIP file $ANSS_TILENEWZIP does not exist either!" > /dev/stderr
    exit 1
  fi
fi

# # Initial selection of files based on the input latitude and longitude range
selected_files=($(gawk -v minlon=${MINLON} -v maxlon=${MAXLON} -v minlat=${MINLAT} -v maxlat=${MAXLAT} '
  @include "tectoplot_functions.awk"
  BEGIN   {
    newminlon=minlon
    newmaxlon=maxlon
    if (maxlon > 180) {
      tilesabove180flag=1
      maxlon2=maxlon-360
      maxlon=180
    }
    if (minlon < -180) {
      tilesbelowm180flag=1
      minlon2=minlon+360
      minlon=-180
    }
    minlattile=rd(minlat,5);
    minlontile=rd(minlon,5);
    maxlattile=rd(maxlat,5);
    maxlontile=rd(maxlon,5);
    maxlattile=(maxlattile>85)?85:maxlattile;
    maxlontile=(maxlontile>175)?175:maxlontile;
    # print "Selecting tiles covering domain [" newminlon, newmaxlon, minlat, maxlat "] -> [" minlontile, maxlontile+5, minlattile, maxlattile+5 "]"  > "/dev/stderr"
    for (i=minlontile; i<=maxlontile; i+=5) {
      for (j=minlattile; j<=maxlattile; j+=5) {
        printf("tile_%d_%d.cat\n", i, j)
      }
    }

    if (tilesabove180flag == 1) {
      minlattile=rd(minlat,5);
      minlontile=rd(-180,5);
      maxlattile=rd(maxlat,5);
      maxlontile=rd(maxlon2,5);
      maxlattile=(maxlattile>85)?85:maxlattile;
      maxlontile=(maxlontile>175)?175:maxlontile;
      # print ":+: Selecting additional tiles covering domain [" newminlon, newmaxlon, minlat, maxlat "] -> [" minlontile, maxlontile+5, minlattile, maxlattile+5 "]"  > "/dev/stderr"
      for (i=minlontile; i<=maxlontile; i+=5) {
        for (j=minlattile; j<=maxlattile; j+=5) {
          printf("tile_%d_%d.cat\n", i, j)
        }
      }
    }

    if (tilesbelowm180flag == 1) {
      minlattile=rd(minlat,5);
      minlontile=rd(minlon2,5);
      maxlattile=rd(maxlat,5);
      maxlontile=rd(175,5);
      maxlattile=(maxlattile>85)?85:maxlattile;
      maxlontile=(maxlontile>175)?175:maxlontile;
      print ":-: Selecting additional tiles covering domain [" newminlon, newmaxlon, minlat, maxlat "] -> [" minlontile, maxlontile+5, minlattile, maxlattile+5 "]"  > "/dev/stderr"
      for (i=minlontile; i<=maxlontile; i+=5) {
        for (j=minlattile; j<=maxlattile; j+=5) {
          printf("tile_%d_%d.cat\n", i, j)
          printf("tile_%d_%d.cat... ", i, j) > "/dev/stderr"
        }
      }
    }


  }'))

# The CSV files can have commas within the ID string messing up fields.
# Remove these and also the quotation marks in ID strings to give a parsable CSV file

# Old method reading from non-zipped tiles.
# gawk < $this_file -F'"' -v OFS='' '{ for (i=2; i<=NF; i+=2) gsub(",", "", $i) } 1' | sed 's/\"//g' | \

# New method reading from zipped tiles.
for this_file in ${selected_files[@]}; do
    # echo unzip -p $ANSS_TILEZIP ${this_file}


    rm -f ${F_SEIS}anss_extract.txt
    # If the start time is earlier than the break between old and new
    if [[ "${STARTTIME}" < "${ARG_OLDDATE}" ]]; then
      unzip -p $ANSS_TILEOLDZIP ${this_file} 2>/dev/null > ${F_SEIS}anss_extract.txt
    fi
    # If the end time is later than the break between old and new

    if [[  "${ENDTIME}" > "${ARG_OLDDATE}" ]]; then
      unzip -p $ANSS_TILENEWZIP ${this_file} 2>/dev/null >> ${F_SEIS}anss_extract.txt
    fi

    gawk < ${F_SEIS}anss_extract.txt -F'"' -v OFS='' '{ for (i=2; i<=NF; i+=2) gsub(",", "", $i) } 1' | sed 's/\"//g' | \
    gawk -F, -v minlon=${MINLON} -v maxlon=${MAXLON} -v minlat=${MINLAT} -v maxlat=${MAXLAT} -v mindate=${STARTTIME} -v maxdate=${ENDTIME} -v minmag=${EQ_MINMAG} -v maxmag=${EQ_MAXMAG} -v mindepth=${EQCUTMINDEPTH} -v maxdepth=${EQCUTMAXDEPTH} '
    @include "tectoplot_functions.awk"
    ($1 != "time" && $15 == "earthquake" && mindate <= $1 && $1 <= maxdate && $2 <= maxlat && $2 >= minlat && $5 >= minmag && $5 <= maxmag && $4 >= mindepth && $4 <= maxdepth) {
      if (test_lon(minlon, maxlon, $3)==1) {
        print
      }
    }' >> ${OUTPUTFILE}

    rm -f anss_extract.txt
done

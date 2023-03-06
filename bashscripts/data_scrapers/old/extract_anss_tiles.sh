#!/bin/bash

# tectoplot
# bashscripts/extract_anss_tiles.sh
# Copyright (c) 2021 Kyle Bradley, all rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following dansslaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following dansslaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DANSSLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# extract_anss_tiles.sh DATADIR MINLON MAXLON MINLAT MAXLAT MINTIME MAXTIME MINMAG MAXMAG MINDEPTH MAXDEPTH OUTFILE

# extract_anss_tiles.sh $ANSSTILEDIR $MINLON $MAXLON $MINLAT $MAXLAT $STARTTIME $ENDTIME $EQ_MINMAG $EQ_MAXMAG $EQCUTMINDEPTH $EQCUTMAXDEPTH ${F_SEIS_FULLPATH}anss_extract_tiles.cat
# This script will print all events from a tiled ANSS catalog directory (tile_lon_lat.cat)
# where the files are in tiled ANSS CSV format without a header line.

# Additionally, the script will filter out some non-natural events by excluding lines
# containing: blast quarry explosion

# CSV format is:
# 1       2         3           4          5        6         7     8      9         10     11   12+
# EVENTID,AUTHOR   ,DATE      ,TIME       ,LAT     ,LON      ,DEPTH,DEPFIX,AUTHOR   ,TYPE  ,MAG  [, extra...]

# Epoch time calculation doesn't work for events before 1900 (mktime returns -1) so return 1900-01-01T00:00:00 time instead

# OSX Catalina 10.15.7 (19H15) has a strange problem, probably with libc? that makes gawk/awk mktime fail for a few specific
# dates: 1941-09-01, 1942-02-16, and 1982-01-01. This is not a problem on a tested linux machine. Odd..

# Reads stdin, converts each item in a column and outputs same column format

# ANSS_TILEOLDZIP="${1}"
# ANSS_TILENEWZIP="${2}"
ANSSTILEDIR="${1}" # Path to the directory containing tiled ANSS events
MINLON="${2}"
MAXLON="${3}"
MINLAT="${4}"
MAXLAT="${5}"
STARTTIME="${6}"
ENDTIME="${7}"
EQ_MINMAG="${8}"
EQ_MAXMAG="${9}"
EQCUTMINDEPTH="${10}"
EQCUTMAXDEPTH="${11}"
OUTPUTFILE="${12}"

# # Initial selection of files based on the input latitude and longitude range
# Include the temporary catalog in the tiles directory for all searches

# If minimum magnitude is 5.0 or larger, only query the catalog file with those events.

if [[ $(echo "${EQ_MINMAG} >= 5.0" | bc -l) -eq 1 ]]; then
  selected_files=($(gawk '
    BEGIN {
      print "anss_m_largerthan_5.cat"
    }'))
else
  selected_files=($(gawk -v minlon=${MINLON} -v maxlon=${MAXLON} -v minlat=${MINLAT} -v maxlat=${MAXLAT} '
    @include "tectoplot_functions.awk"
    BEGIN   {
      print "anss_m_largerthan_5.cat"
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
          }
        }
      }
    }'))
fi

# echo ${selected_files[@]}

for this_file in ${selected_files[@]}; do
    # echo unzip -p $ANSS_TILEZIP ${this_file}
    if [[ -s ${ANSSTILEDIR}$this_file ]]; then
      # Replace string elements before extracting
      gawk < ${ANSSTILEDIR}$this_file -F'"' -v OFS='' '{ for (i=2; i<=NF; i+=2) gsub(",", "", $i) } 1' | sed 's/\"//g' | \
      gawk -F, -v minlon=${MINLON} -v maxlon=${MAXLON} -v minlat=${MINLAT} -v maxlat=${MAXLAT} -v mindate=${STARTTIME} -v maxdate=${ENDTIME} -v minmag=${EQ_MINMAG} -v maxmag=${EQ_MAXMAG} -v mindepth=${EQCUTMINDEPTH} -v maxdepth=${EQCUTMAXDEPTH} '
      @include "tectoplot_functions.awk"
      ($1 != "time" && $15 == "earthquake" && mindate <= $1 && $1 <= maxdate && $2 <= maxlat && $2 >= minlat && $5 >= minmag && $5 <= maxmag && $4 >= mindepth && $4 <= maxdepth) {
        if (test_lon(minlon, maxlon, $3)==1) {
          print
        }
      }' >> ${OUTPUTFILE}
    fi
done

#!/bin/bash

# tectoplot
# bashscripts/extract_isc_tiles.sh
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

# extract_isc_tiles.sh DATADIR MINLON MAXLON MINLAT MAXLAT MINTIME MAXTIME MINMAG MAXMAG MINDEPTH MAXDEPTH OUTFILE

# extract_isc_tiles.sh $ISCTILEDIR $MINLON $MAXLON $MINLAT $MAXLAT $STARTTIME $ENDTIME $EQ_MINMAG $EQ_MAXMAG $EQCUTMINDEPTH $EQCUTMAXDEPTH ${F_SEIS_FULLPATH}isc_extract_tiles.cat
# This script will print all events from a tiled ISC catalog directory (tile_lon_lat.cat)
# where the files are in tiled ISC CSV format without a header line.

# Additionally, the script will filter out some non-natural events by excluding lines
# containing: blast quarry explosion

# CSV format is:
# 1       2         3           4          5        6         7     8      9         10     11   12+
# EVENTID,AUTHOR   ,DATE      ,TIME       ,LAT     ,LON      ,DEPTH,DEPFIX,AUTHOR   ,TYPE  ,MAG  [, extra...]

# Reads stdin, converts each item in a column and outputs same column format

# ISC_TILEOLDZIP="${1}"
# ISC_TILENEWZIP="${2}"
ISCTILEDIR="${1}" # Path to the directory containing tiled ISC events
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
      print "isc_m_largerthan_5.cat"
    }'))
else
  selected_files=($(gawk -v minlon=${MINLON} -v maxlon=${MAXLON} -v minlat=${MINLAT} -v maxlat=${MAXLAT} '
    @include "tectoplot_functions.awk"
    BEGIN   {
      print "isc_m_largerthan_5.cat"
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

for this_file in ${selected_files[@]}; do
  if [[ -s ${ISCTILEDIR}${this_file} ]]; then
      gawk -F, < ${ISCTILEDIR}${this_file} -v minlon=${MINLON} -v maxlon=${MAXLON} -v minlat=${MINLAT} -v maxlat=${MAXLAT} -v mindate=${STARTTIME} -v maxdate=${ENDTIME} -v minmag=${EQ_MINMAG} -v maxmag=${EQ_MAXMAG} -v mindepth=${EQCUTMINDEPTH} -v maxdepth=${EQCUTMAXDEPTH} '
      @include "tectoplot_functions.awk"
      {
        lat=$6+0
        lon=$7+0
        depth=$8+0
        mag=$12+0
        if ($6+0==$6 && $7+0==$7 && $8+0==$8 && $12+0==$12) {
          if (lat <= maxlat && lat >= minlat && mag >= minmag && mag <= maxmag && depth >= mindepth && depth <= maxdepth) {
            if (test_lon(minlon, maxlon, lon)==1) {
              # Now we check if the event actually falls inside the specified time window
              timecode=sprintf("%sT%s", $4, substr($5, 1, 8))
              if (mindate <= timecode && timecode <= maxdate) {
                print
              }
            }
          }
        }
      }' >> ${OUTPUTFILE}
  fi
done

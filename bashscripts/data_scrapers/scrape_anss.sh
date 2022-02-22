#!/bin/bash

# Catalog files are separated into 4 segments per month. A list of possible catalog
# files is generated each time this scraper is run: anss_list.txt

# Each time this scraper is run, catalog files younger than or overlapping with the date
# stored in anss_last_downloaded_event.txt are downloaded. Catalog files without a STOP
# line are considered failed and are deleted upon download.

# After downloads are complete

# tectoplot
# bashscripts/scrape_anss_seismicity.sh
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

# Download the entire global ANSS seismicity catalog and store in weekly data files,
# then process into 5x5 degree tiles for quicker plotting.

# Most of the download time is the pull request, but making larger chunks leads
# to some failures due to number of events. The script can be run multiple times
# and will not re-download files that already exist. Some error checking is done
# to look for empty files and delete them.

# Example curl command (broken onto multiple lines)
# curl "${ANSS_MIRROR}/cgi-bin/web-db-v4?request=COMPREHENSIVE&out_format=CATCSV
#       &searchshape=RECT&bot_lat=-90&top_lat=90&left_lon=-180&right_lon=180
#       &ctr_lat=&ctr_lon=&radius=&max_dist_units=deg&srn=&grn=&start_year=${year}
#       &start_month=${month}&start_day=01&start_time=00%3A00%3A00&end_year=${year}
#       &end_month=${month}&end_day=7&end_time=23%3A59%3A59&min_dep=&max_dep=
#       &min_mag=&max_mag=&req_mag_type=Any&req_mag_agcy=prime" > anss_seis_2019_01_week1.dat

# Note that ANSS queries require the correct final day of the month, including leap years!

# Reverse the order of lines in each file, printing the files in order specified
# tac preferred over tail -r preferred over gawk

# This is the date that separates old catalog from new (more rapidly updated) catalog
ANSS_MIRROR="https://earthquake.usgs.gov"

# Set ANSS_VERBOSE=1 for more illuminating messages
ANSS_VERBOSE=0
[[ $ANSS_VERBOSE -eq 1 ]] && CURL_QUIET="" || CURL_QUIET="-s"
# Not needed anymore
# function tecto_tac() {
#   if hash tac 2>/dev/null; then
#     tac $@
#   elif echo "a" | tail -r >/dev/null 2>&1; then
#     tail -r $@
#   else
#     gawk '{
#       data[NR]=$0
#     }
#     END {
#       num=NR
#       for(i=num;i>=1;i--) {
#         print data[i]
#       }
#     }' $@
#   fi
# }

function anss_update_catalog() {

  [[ $ANSS_VERBOSE -eq 1 ]] && echo "Scraping ANSS data in directory $(pwd)"
  TILEDIR="${1}"

  if [[ ! -d ${TILEDIR} ]]; then
    echo "ANSS catalog cannot be updated because tile directory ${TILEDIR} does not exist"
    exit 1
  fi

  # Determine the latest anss catalog file
  latest_anss_file=$(ls anss_*.cat | sort -n -k 3 -t '_' | tail -n 1)

  # If the file exists, then determine the date of the latest event and start
  # scraping from there.

  while [[ ! -s $latest_anss_file ]]; do
    [[ $ANSS_VERBOSE -eq 1 ]] && echo "Removing empty catalog file $latest_anss_file; probably leftover from previous scrape"
    rm -f $latest_anss_file
    latest_anss_file=$(ls anss_*.cat | sort -n -k 3 -t '_' | tail -n 1)
  done

  if [[ -s $latest_anss_file ]]; then
    # determine the catalog number of the next file to create
    # filename of latest file is anss_index_N.cat where N is an integer

    file_ind=$(echo $latest_anss_file | gawk '
      (NR==1) {
        split($0,a,"_")
        split(a[3],b,".")
        print b[1] + 1
      }')

    lastevent=$(tail -n 1 $latest_anss_file | gawk -F, '{split($1, a, "."); print a[1]}')

    # Initialize the
    new_time=$(echo $lastevent | gawk '
      {
        date = substr($1,1,10);
        split(date,dstring,"-");
        time = substr($1,12,8);
        split(time,tstring,":");
        the_time = sprintf("%i %i %i %i %i %i",dstring[1],dstring[2],dstring[3],tstring[1],tstring[2],int(tstring[3]+0.5));
        secs = mktime(the_time);
        newtime = strftime("%FT%T", secs+2);
        print newtime
      }')
      [[ $ANSS_VERBOSE -eq 1 ]] && echo "Looking for events following last downloaded event at: ${new_time}"
      s_year=${new_time:0:4}
      s_month=${new_time:5:2}
      s_day=${new_time:8:2}
      s_hour=${new_time:11:2}
      s_minute=${new_time:14:2}
      s_second=${new_time:17:2}
      # It's OK to request future events
      e_year=$(echo "$s_year + 1" | bc -l)
      e_month=${s_month}
      e_day=${s_day}
      e_hour=${s_hour}
      e_minute=${s_minute}
      e_second=${s_second}
  else
    # If there is no catalog, download the first two large chunks before going
    # to year/20000 event files

    # 1000       1959     18804
    # 1959       1969     19639
    if [[ ! -s anss_index_1.cat ]]; then
      [[ $ANSS_VERBOSE -eq 1 ]] && echo "Downloading events from 1000 AD to 1959 AD"

      curl ${CURL_QUIET} "${ANSS_MIRROR}/fdsnws/event/1/query?format=csv&starttime=1000-01-01T00:00:00&endtime=1959-12-31T23:59:59&minlatitude=-90&maxlatitude=90&minlongitude=-180&maxlongitude=180&limit=20000&orderby=time-asc" | sed '1d' > anss_index_1.cat

      lastevent=$(tail -n 1 anss_index_1.cat | gawk -F, '{split($1, a, "."); print a[1]}')

      if [[ $lastevent == "" ]]; then
        echo "Error: could not download events from 1000 to 1959"
        rm -f anss_index_1.cat
        exit 1
      fi
    fi
    if [[ ! -s anss_index_2.cat ]]; then
      [[ $ANSS_VERBOSE -eq 1 ]] && echo "Downloading events from 1960 AD to 1969 AD"
      curl ${CURL_QUIET} "${ANSS_MIRROR}/fdsnws/event/1/query?format=csv&starttime=1960-01-01T00:00:00&endtime=1969-12-31T23:59:59&minlatitude=-90&maxlatitude=90&minlongitude=-180&maxlongitude=180&limit=20000&orderby=time-asc" | sed '1d' > anss_index_2.cat
      lastevent=$(tail -n 1 anss_index_2.cat | gawk -F, '{split($1, a, "."); print a[1]}')
      if [[ $lastevent == "" ]]; then
        echo "Error: could not download events from 1960 to 1969"
        rm -f anss_index_2.cat
        exit 1
      fi
    fi

    # Initialize the downloads which will be by year or by 20000 increment, whichever is smaller

    s_year=1970
    s_month=01
    s_day=01
    s_hour=00
    s_minute=00
    s_second=00
    e_year=1971
    e_month=12
    e_day=31
    e_hour=23
    e_minute=59
    e_second=59

    file_ind=3
  fi

  got_events=1
  # Download events by increments of 20000 events

  # download the first several increments

  while [[ $got_events -eq 1 ]]; do
    [[ $ANSS_VERBOSE -eq 1 ]] && echo "Downloading 20000 events starting at ${s_year}-${s_month}-${s_day}T${s_hour}:${s_minute}:${s_second} into anss_index_${file_ind}.cat"

    [[ $ANSS_VERBOSE -eq 1 ]] && echo curl ${CURL_QUIET} "${ANSS_MIRROR}/fdsnws/event/1/query?format=csv&starttime=${s_year}-${s_month}-${s_day}T${s_hour}:${s_minute}:${s_second}&endtime=${e_year}-${e_month}-${e_day}T${e_hour}:${e_minute}:${e_second}&minlatitude=-90&maxlatitude=90&minlongitude=-180&maxlongitude=180&limit=20000&orderby=time-asc"

    curl ${CURL_QUIET} "${ANSS_MIRROR}/fdsnws/event/1/query?format=csv&starttime=${s_year}-${s_month}-${s_day}T${s_hour}:${s_minute}:${s_second}&endtime=${e_year}-${e_month}-${e_day}T${e_hour}:${e_minute}:${e_second}&minlatitude=-90&maxlatitude=90&minlongitude=-180&maxlongitude=180&limit=20000&orderby=time-asc" | sed '1d' > anss_index_${file_ind}.cat

    # Read the date string of the last downloaded event
    lastevent=$(tail -n 1 anss_index_${file_ind}.cat | gawk -F, '{split($1, a, "."); print a[1]}')

    if [[ $lastevent == "" || $lastevent == "</BODY></HTML>" ]]; then
      got_events=0

      # Remove the file that is empty
      rm -f anss_index_${file_ind}.cat
    else

      # The downloaded file will have only new events that can be added to the tiles.
      tile_catalog_file $TILEDIR anss_index_${file_ind}.cat

      # Parse the timestring of the last downloaded event and add two seconds to the timestring
      # before starting the next download chunk.

      new_time=$(echo $lastevent | gawk '
        {
          date = substr($1,1,10);
          split(date,dstring,"-");
          time = substr($1,12,8);
          split(time,tstring,":");
          the_time = sprintf("%i %i %i %i %i %i",dstring[1],dstring[2],dstring[3],tstring[1],tstring[2],int(tstring[3]+0.5));
          secs = mktime(the_time);
          newtime = strftime("%FT%T", secs+2);
          print newtime
        }')
        [[ $ANSS_VERBOSE -eq 1 ]] && echo "newtime is ${new_time}"
        s_year=${new_time:0:4}
        s_month=${new_time:5:2}
        s_day=${new_time:8:2}
        s_hour=${new_time:11:2}
        s_minute=${new_time:14:2}
        s_second=${new_time:17:2}
        e_year=$(echo "$s_year + 1" | bc -l)
        ((file_ind++))
    fi
  done
}

# Add events from CATALOGFILE to spatial tiles and M5+ catalog file, in the
# specified TILEDIR

# 2018-12-27T20:00:43.897Z,61.3785,-150.0251,41.9,1.2,ml,,,,0.61,ak,ak018glcx1r9,2019-10-24T20:25:36.028Z,"3 km NW of Point MacKenzie, Alaska",earthquake,,0.3,,,reviewed,ak,ak
# lat=$2
# lon=$3
# mag=$5

function tile_catalog_file {
  TILEDIR=$1
  CATALOGFILE=$2

  [[ $ANSS_VERBOSE -eq 1 ]] && echo "Processing ANSS file $CATALOGFILE into tile files"
  gawk < ${CATALOGFILE} -F, -v tiledir=${TILEDIR} '
    BEGIN { added=0 }
    function rd(n, multipleOf)
    {
      if (n % multipleOf == 0) {
        num = n
      } else {
         if (n > 0) {
            num = n - n % multipleOf;
         } else {
            num = n + (-multipleOf - n % multipleOf);
         }
      }
      return num
    }
    {

      if($5 >= 5) {
        tilestr=sprintf("%sanss_m_largerthan_5.cat", tiledir)
      } else {
        tilestr=sprintf("%stile_%d_%d.cat", tiledir, rd($3,5), rd($2,5));
      }
      print $0 >> tilestr
      added++
    }
    END {
      print ">>>> Added", added, "events to ANSS tiles <<<<"
    }'
}

# Change into the ANSS directory and update the catalog there

ANSSDIR="${1}"

if [[ -d $ANSSDIR ]]; then
  [[ $ANSS_VERBOSE -eq 1 ]] && echo "ANSS tile directory exists."
else
  [[ $ANSS_VERBOSE -eq 1 ]] && echo "Creating ANSS seismicity directory ${ANSSDIR}"
  mkdir -p ${ANSSDIR}
fi

cd $ANSSDIR

if [[ ! -d ./tiles ]]; then
  mkdir -p ./tiles || echo "Cannot create tile directory ${ANSSDIR}/tiles/. Exiting" && exit 1
fi

# Update and tile the ANSS catalog data

anss_update_catalog "./tiles/"

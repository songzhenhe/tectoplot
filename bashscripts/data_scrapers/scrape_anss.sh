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

# Download the entire global ANSS seismicity catalog,
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

# Note that ANSS queries require the correct final day of the month, including
# leap years! Whyyyy.....

# This is the URL of the mirror to use
ANSS_MIRROR="https://earthquake.usgs.gov"

# Set ANSS_VERBOSE=1 for more illuminating messages
ANSS_VERBOSE=1
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

function repair_anss_time_json() {
  gawk -F, '
  BEGIN {
    OFS=","
    OFMT="%.3f"
    ENVIRON["TZ"] = "UTC"
  }
  {
    for(i=1;i<=NF;++i) {
      if (substr($(i),2,4) == "time") {
        split($(i), a, ":")
        $(i)=sprintf("\"time\":\"%s\",\"epochtime\":%.2f", strftime("%FT%T", a[2]/1000), a[2]/1000)
      }
    }
    print
  }'
}

function add_one_second() {
  gawk '
    {
      date = substr($1,1,10);
      split(date,dstring,"-");
      time = substr($1,12,8);
      split(time,tstring,":");
      the_time = sprintf("%i %i %i %i %i %i",dstring[1],dstring[2],dstring[3],tstring[1],tstring[2],int(tstring[3]+0.5));
      secs = mktime(the_time);
      newtime = strftime("%FT%T", secs+1);
      print newtime
    }'
}

function anss_update_catalog() {

  [[ $ANSS_VERBOSE -eq 1 ]] && echo "Scraping ANSS data in directory $(pwd)"

  if [[ ! -s anss.gpkg ]]; then
    echo "Earthquakes GPKG does not exist. Initializing."

    # Make a fake entry that we know will have the appropriate data types in each field
cat <<EOF > event1.json
{"type":"FeatureCollection","metadata":{"generated":1677207254000,"url":"https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&starttime=2020-01-01T00:00:00&endtime=2020-02-01T23:59:59&minlatitude=-90&maxlatitude=90&minlongitude=-180&maxlongitude=180&limit=20000","title":"USGS Earthquakes","status":200,"api":"1.13.6","limit":20000,"offset":1,"count":17228},"features":[{"type":"Feature","properties":{"mag":2.6,"place":"83 km NW of San Antonio, Puerto Rico","time":"2020-02-01T23:58:58","epochtime":1580601538.17,"updated":1587247811040,"tz":0,"url":"https://earthquake.usgs.gov/earthquakes/eventpage/us60007me5","detail":"https://earthquake.usgs.gov/fdsnws/event/1/query?eventid=us60007me5&format=geojson","felt":100,"cdi":5.0,"mmi":1.1,"alert":"green","status":"reviewed","tsunami":0,"sig":104,"net":"us","code":"60007me5","ids":",us60007me5,","sources":",us,","types":",origin,phase-data,","nst":10,"dmin":0.758,"rms":0.51,"gap":213.5,"magType":"ml","type":"earthquake","title":"M 2.6 - 83 km NW of San Antonio, Puerto Rico"},"geometry":{"type":"Point","coordinates":[-67.6777,19.0062,10]},"id":"us60007me5"}],"bbox":[-179.9907,-61.461,-3.66,179.9993,86.2275,621.81]}
EOF

    # Download the first batch of data
    # As of March 2023, 1000AD to 1950-02-13T05:55:11.000 is 20,000 events

    echo "Downloading first batch of events"
    while [[ ! -s batch1.json ]]; do
      curl -0 "${ANSS_MIRROR}/fdsnws/event/1/query?format=geojson&starttime=1000-01-01T00:00:00&endtime=1950-02-13T05:55:11&minlatitude=-90&maxlatitude=90&minlongitude=-180&maxlongitude=180&limit=20000&orderby=time-asc" > batch1.json
      if [[ ! -s batch1.json ]]; then
        echo "No data downloaded... retrying after 30 seconds"
        sleep 30
      fi
      if grep -i "<HTML>" batch1.json; then
        echo "Got actual error message... retrying after 30 seconds"
        sleep 30
        rm batch1.json
      fi
    done

    # batch1.json must exist to get here
    cat batch1.json | repair_anss_time_json > batch1_fixed.json


    # Make the geopackage
    # Create the geopackage with the anss table
    if ogr2ogr -f GPKG -nln anss -t_srs EPSG:4979 anss.gpkg event1.json; then
      echo "Created GPKG: anss.gpkg"
    else
      echo "Creation of anss GPKG failed"
      rm -f anss.gpkg event1.json
      exit 1
    fi

    # Delete the row, leaving a pristine file
    ogrinfo -update -dialect sqlite -sql "DELETE FROM anss WHERE id=='us60007me5'" anss.gpkg

    ogr2ogr -f GPKG -append -nln anss anss.gpkg batch1_fixed.json
    echo "Added $(wc -l < batch1_fixed.json) events"
    rm -f batch1.json batch1_fixed.json

    mintime=$(ogr2ogr -f CSV -dialect spatialite -sql "SELECT MAX(time) FROM anss" /vsistdout/ anss.gpkg | sed '1d; s/\"//g' | cut -f 1 -d '.')

    # Download the second batch of data
    echo "Downloading second batch of events"

    while [[ ! -s batch2.json ]]; do
      curl -0 "${ANSS_MIRROR}/fdsnws/event/1/query?format=geojson&starttime=$(echo ${mintime} | add_one_second)&endtime=1966-01-01T00:00:00&minlatitude=-90&maxlatitude=90&minlongitude=-180&maxlongitude=180&limit=20000&orderby=time-asc" > batch2.json
      if [[ ! -s batch2.json ]]; then
        echo "No data downloaded... retrying after 30 seconds"
        sleep 30
      fi
      if grep -i "<HTML>" batch2.json; then
        echo "Got actual error message... retrying after 30 seconds"
        sleep 30
        rm batch2.json
      fi
    done

    cat batch2.json | repair_anss_time_json > batch2_fixed.json

    # batch1.json must exist to get here
    ogr2ogr -f GPKG -append -nln anss anss.gpkg batch2_fixed.json
    echo "Added $(wc -l < batch2_fixed.json) events"
    rm -f batch2.json batch2_fixed.json

    echo "Adding indexes to GPKG"
    ogrinfo -sql "CREATE INDEX time_index ON anss (time)" anss.gpkg
    ogrinfo -sql "CREATE INDEX id_index ON anss (id)" anss.gpkg
  fi

  if [[ ! -s anss.gpkg ]]; then
    echo "anss.gpkg could not be created... exiting"
    exit 1
  fi

  # From this point on, we will request one year of data at a time, in increments
  # of 20,000 events
  echo "Downloading new events"
  got_events=1
  while [[ ${got_events} -eq 1 ]]; do

    # Find the time of the latest event in the database, plus one second
    mintime=$(ogr2ogr -f CSV -dialect spatialite -sql "SELECT MAX(time) FROM anss" /vsistdout/ anss.gpkg | sed '1d; s/\"//g' | cut -f 1 -d '.' | add_one_second)

    # Add days so that leap days cannot mess us up!
    maxtime=$(echo $mintime | gawk '
      {
        date = substr($1,1,10);
        split(date,dstring,"-");
        time = substr($1,12,8);
        split(time,tstring,":");

        the_time = sprintf("%i %i %i %i %i %i",dstring[1],dstring[2],dstring[3]+10,0,0,0);
        secs = mktime(the_time);
        newtime = strftime("%FT%T", secs);
        print newtime
      }')

    rm -f batchN.json
    while [[ ! -s batchN.json ]]; do
      echo "Downloading events between ${mintime} and ${maxtime}"

      echo curl "-0 \"${ANSS_MIRROR}/fdsnws/event/1/query?format=geojson&starttime=$(echo ${mintime} | add_one_second)&endtime=${maxtime}&minlatitude=-90&maxlatitude=90&minlongitude=-180&maxlongitude=180&orderby=time-asc&limit=20000\"" \> output.json
      if ! curl -0 "${ANSS_MIRROR}/fdsnws/event/1/query?format=geojson&starttime=$(echo ${mintime} | add_one_second)&endtime=${maxtime}&minlatitude=-90&maxlatitude=90&minlongitude=-180&maxlongitude=180&orderby=time-asc&limit=20000" > batchN.json; then
        echo "curl error:"
        cat batchN.json
        rm -f batchN.json
        continue
      fi

      if grep -m 1 "{\"type\":\"Feature" batchN.json >/dev/null; then
        echo "Got JSON"
        break
      else
        echo "Returned file does not contain JSON header. Sleeping for 60 seconds and trying again"
        cat batchN.json
        rm -f batchN.json
        sleep 60
      fi
    done

    # If there is an empty bracket [] then data came out but no events were returned
    if grep "\[\]" batchN.json; then
      got_events=0
      echo "No new events found between ${mintime} and requested ${maxtime}"
      # If the
      if [[ $(echo ${maxtime} $(date -u +"%FT%T") | gawk '{print ($1>=$2)?1:0}') -eq 1 ]]; then
        echo "Reached current date - ending download"
        return
      fi
    else
      cat batchN.json | repair_anss_time_json > batchN_fixed.json
      ogr2ogr -f GPKG -append -nln anss anss.gpkg batchN_fixed.json

      maxtime2=$(ogr2ogr -f CSV -dialect spatialite -sql "SELECT MAX(time) FROM anss" /vsistdout/ anss.gpkg | sed '1d; s/\"//g' | cut -f 1 -d '.')

      echo "Added $(wc -l < batchN_fixed.json) events between ${mintime} and ${maxtime2} (requested until ${maxtime})"
    fi
  done
}

# Change into the ANSS directory and update the catalog there

ANSSDIR="${1}"

if [[ -d $ANSSDIR ]]; then
  [[ $ANSS_VERBOSE -eq 1 ]] && echo "ANSS directory exists."
else
  [[ $ANSS_VERBOSE -eq 1 ]] && echo "Creating ANSS seismicity directory ${ANSSDIR}"
  mkdir -p ${ANSSDIR}
fi

cd $ANSSDIR

# Update the ANSS catalog data

anss_update_catalog

#!/bin/bash

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

# Download the entire global ANSS seismicity catalog and create a GPKG database

# Example curl command (broken onto multiple lines)
# curl "${ANSS_MIRROR}/cgi-bin/web-db-v4?request=COMPREHENSIVE&out_format=CATCSV
#       &searchshape=RECT&bot_lat=-90&top_lat=90&left_lon=-180&right_lon=180
#       &ctr_lat=&ctr_lon=&radius=&max_dist_units=deg&srn=&grn=&start_year=${year}
#       &start_month=${month}&start_day=01&start_time=00%3A00%3A00&end_year=${year}
#       &end_month=${month}&end_day=7&end_time=23%3A59%3A59&min_dep=&max_dep=
#       &min_mag=&max_mag=&req_mag_type=Any&req_mag_agcy=prime"

# This is the URL of the mirror to use
ANSS_MIRROR="https://earthquake.usgs.gov"

# Set ANSS_VERBOSE=1 for more illuminating messages
ANSS_VERBOSE=1
[[ $ANSS_VERBOSE -eq 1 ]] && CURL_QUIET="" || CURL_QUIET="-s"


# The ANSS JSON file comes with an inconvenient time format: milliseconds since 
# the 1970 epoch. We want an iso8601 timestring (YYYY-MM-DDTHH:MM:SS). So we
# simply alter the JSON file directly after downloading it.

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

# The granularity of the web request is one second, so to avoid downloading duplicate events,
# add one second to the input datetime string.

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

function anss_repair_catalog() {
  echo "Repairing anss.gpkg by deleting events with update time after ${1}"
  if [[ -s anss.gpkg ]]; then
      beforecount=$(ogrinfo -so anss.gpkg anss | grep Count | gawk '{print $(NF)}')
      local fixtime=$(echo $1 | iso8601_from_partial)

      local updatedtime_pre=$(iso8601_to_epoch ${fixtime})


      local updatedtime=$(echo "1000 * ${updatedtime_pre}" | bc -l)

      echo "updatedtime is ${updatedtime}"
      if arg_is_float ${updatedtime}; then
        ogrinfo -dialect sqlite -sql "DELETE FROM anss WHERE updated > '${updatedtime}'" anss.gpkg

        aftercount=$(ogrinfo -so anss.gpkg anss | grep Count | gawk '{print $(NF)}')

        addedcount=$(echo "$aftercount - $beforecount" | bc)

        echo "Operation changed number of events by ${addedcount}"

        echo "Recreating ID index"
        ogrinfo -sql "DROP INDEX id_index" anss.gpkg
        ogrinfo -sql "CREATE UNIQUE INDEX id_index ON anss (id)" anss.gpkg
      fi
  fi  
}

# Download any events that span the existing catalog epoch, and apply any updates
# to those events, from the last event up to the present moment.

function anss_update_catalog() {

  # If anss.gpkg does not exist, we will create it in anss_download_catalog
  if [[ -s anss.gpkg ]]; then

    # The time of interest is the time range of the existing catalog
    # The update period is the time between the last catalog event and now

    # Upserting (update + insert) plus the use of a unique id index means
    # we cannot somehow delete or duplicate an event - only add/replace 

    mintime=$(ogr2ogr -f CSV -dialect sqlite -sql "SELECT MIN(time) FROM anss" /vsistdout/ anss.gpkg | sed '1d; s/\"//g' | cut -f 1 -d '.')
    maxtime=$(ogr2ogr -f CSV -dialect sqlite -sql "SELECT MAX(time) FROM anss" /vsistdout/ anss.gpkg | sed '1d; s/\"//g' | cut -f 1 -d '.')

    # info_msg "Downloading events added or update for period ${mintime} to ${maxtime}, if updates occurred after ${maxtime}"

    rm -f update.json
    while [[ ! -s update.json ]]; do
      curl -0 "${ANSS_MIRROR}/fdsnws/event/1/query?format=geojson&starttime=${mintime}&endtime=${maxtime}&updatedafter=${maxtime}" > update.json
      if [[ ! -s update.json ]]; then
        echo "No update data downloaded... retrying after 30 seconds"
        sleep 30
      fi
      if grep -i "<HTML>" update.json; then
        echo "Got actual error message when downloading update data... retrying after 30 seconds"
        sleep 30
        rm update.json
      fi
    done

    # Entries can be upserted (updated or inserted) because we have a single UNIQUE id index
    if grep -m 1 "{\"type\":\"Feature" update.json >/dev/null; then
      ogr2ogr -nln anss -upsert anss.gpkg update.json
      echo "Updated or added $(wc -l < update.json | gawk '{print $1}') events"
    fi
  fi
}


function anss_download_catalog() {

  # [[ $ANSS_VERBOSE -eq 1 ]] && echo "Scraping ANSS data in directory $(pwd)"

  if [[ ! -s anss.gpkg ]]; then
    echo "ANSS GPKG file does not exist. Initializing."

    # Make a fake entry that we know will have the appropriate data types in each field
cat <<EOF > event1.json
{"type":"FeatureCollection","metadata":{"generated":1677207254000,"url":"https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&starttime=2020-01-01T00:00:00&endtime=2020-02-01T23:59:59&minlatitude=-90&maxlatitude=90&minlongitude=-180&maxlongitude=180&limit=20000","title":"USGS Earthquakes","status":200,"api":"1.13.6","limit":20000,"offset":1,"count":17228},"features":[{"type":"Feature","properties":{"mag":2.6,"place":"83 km NW of San Antonio, Puerto Rico","time":"2020-02-01T23:58:58","epochtime":1580601538.17,"updated":1587247811040,"tz":0,"url":"https://earthquake.usgs.gov/earthquakes/eventpage/us60007me5","detail":"https://earthquake.usgs.gov/fdsnws/event/1/query?eventid=us60007me5&format=geojson","felt":100,"cdi":5.0,"mmi":1.1,"alert":"green","status":"reviewed","tsunami":0,"sig":104,"net":"us","code":"60007me5","ids":",us60007me5,","sources":",us,","types":",origin,phase-data,","nst":10,"dmin":0.758,"rms":0.51,"gap":213.5,"magType":"ml","type":"earthquake","title":"M 2.6 - 83 km NW of San Antonio, Puerto Rico"},"geometry":{"type":"Point","coordinates":[-67.6777,19.0062,10]},"id":"us60007me5"}],"bbox":[-179.9907,-61.461,-3.66,179.9993,86.2275,621.81]}
EOF

    # Download the first batch of data
    # As of March 2023, 1000AD to 1950-02-13T05:55:11.000 is 20,000 events

    while [[ ! -s batch1.json ]]; do
      curl -0 "${ANSS_MIRROR}/fdsnws/event/1/query?format=geojson&starttime=1000-01-01T00:00:00&endtime=1950-02-13T05:55:11&minlatitude=-90&maxlatitude=90&minlongitude=-180&maxlongitude=180&limit=20000&orderby=time-asc" > batch1.json
      if [[ ! -s batch1.json ]]; then
        echo "No data downloaded when getting first batch... retrying after 30 seconds"
        sleep 30
      fi
      if grep -i "<HTML>" batch1.json; then
        echo "Got actual error message when getting first batch... retrying after 30 seconds"
        sleep 30
        rm batch1.json
      fi
    done

    # batch1.json must exist to get here
    cat batch1.json | repair_anss_time_json > batch1_fixed.json

    # Create the geopackage with the table anss containing the initial data entry
    if ogr2ogr -f GPKG -nln anss -t_srs EPSG:4979 anss.gpkg event1.json; then
      echo "Created GPKG: anss.gpkg"
      rm -f event1.json
    else
      echo "Creation of anss GPKG failed"
      rm -f anss.gpkg event1.json
      exit 1
    fi

    # Delete the artificial entry, leaving an empty table
    ogrinfo -update -dialect sqlite -sql "DELETE FROM anss WHERE id=='us60007me5'" anss.gpkg

    # Append the first batch of data to the table
    ogr2ogr -f GPKG -append -nln anss anss.gpkg batch1_fixed.json
    echo "Added $(wc -l < batch1_fixed.json | gawk '{print $1}') events to table anss"
    rm -f batch1.json batch1_fixed.json

    # Figure out the time of the last downloaded event so we can start the second batch
    mintime=$(ogr2ogr -f CSV -dialect sqlite -sql "SELECT MAX(time) FROM anss" /vsistdout/ anss.gpkg | sed '1d; s/\"//g' | cut -f 1 -d '.')

    # Download the second batch of data
    while [[ ! -s batch2.json ]]; do
      curl -0 "${ANSS_MIRROR}/fdsnws/event/1/query?format=geojson&starttime=$(echo ${mintime} | add_one_second)&endtime=1966-01-01T00:00:00&minlatitude=-90&maxlatitude=90&minlongitude=-180&maxlongitude=180&limit=20000&orderby=time-asc" > batch2.json
      if [[ ! -s batch2.json ]]; then
        echo "No data downloaded for second event batch... retrying after 30 seconds"
        sleep 30
      fi
      if grep -i "<HTML>" batch2.json; then
        echo "Got actual error message when downloading second event batch... retrying after 30 seconds"
        sleep 30
        rm batch2.json
      fi
    done

    cat batch2.json | repair_anss_time_json > batch2_fixed.json

    # batch1.json must exist to get here
    ogr2ogr -f GPKG -append -nln anss anss.gpkg batch2_fixed.json
    echo "Added $(wc -l < batch2_fixed.json | gawk '{print $1}') events"
    rm -f batch2.json batch2_fixed.json

    # Configure the geopackage
    # info_msg "Creating indexes for anss GPKG"
    ogrinfo -sql "CREATE INDEX time_index ON anss (time)" anss.gpkg
    ogrinfo -sql "CREATE UNIQUE INDEX id_index ON anss (id)" anss.gpkg

    # Record the time of last modification
    date -u +"%FT%T" > anss.time

  fi

  if [[ ! -s anss.gpkg ]]; then
    echo "anss.gpkg could not be created... exiting"
    exit 1
  fi

  # From this point on, we will request one year of data at a time, in increments
  # of 20,000 events
  # echo "Downloading new events"
  got_events=1
  while [[ ${got_events} -eq 1 ]]; do

    # Find the time of the latest event in the database, plus one second
    mintime=$(ogr2ogr -f CSV -dialect sqlite -sql "SELECT MAX(time) FROM anss" /vsistdout/ anss.gpkg | sed '1d; s/\"//g' | cut -f 1 -d '.' | add_one_second)

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

      # echo curl "-0 \"${ANSS_MIRROR}/fdsnws/event/1/query?format=geojson&starttime=$(echo ${mintime} | add_one_second)&endtime=${maxtime}&minlatitude=-90&maxlatitude=90&minlongitude=-180&maxlongitude=180&orderby=time-asc&limit=20000\"" \> output.json
      if ! curl -0 "${ANSS_MIRROR}/fdsnws/event/1/query?format=geojson&starttime=$(echo ${mintime} | add_one_second)&endtime=${maxtime}&minlatitude=-90&maxlatitude=90&minlongitude=-180&maxlongitude=180&orderby=time-asc&limit=20000" > batchN.json; then
        # echo "curl error:"
        # cat batchN.json
        rm -f batchN.json
        continue
      fi

      if grep -m 1 "{\"type\":\"Feature" batchN.json >/dev/null; then
        # echo "Got JSON"
        break
      else
        # echo "Returned file does not contain JSON header. Sleeping for 60 seconds and trying again"
        # cat batchN.json
        rm -f batchN.json
        sleep 60
      fi
    done

    # If there is an empty bracket [] then data came out but no events were returned
    if grep "\[\]" batchN.json >/dev/null; then
      got_events=0
      #  echo "No new events found between ${mintime} and requested ${maxtime}"
      # If the
      if [[ $(echo ${maxtime} $(date -u +"%FT%T") | gawk '{print ($1>=$2)?1:0}') -eq 1 ]]; then
        #  echo "Reached current date - ending download"
        return
      fi
    else
      cat batchN.json | repair_anss_time_json > batchN_fixed.json
      ogr2ogr -f GPKG -append -nln anss anss.gpkg batchN_fixed.json
      maxtime2=$(ogr2ogr -f CSV -dialect sqlite -sql "SELECT MAX(time) FROM anss" /vsistdout/ anss.gpkg | sed '1d; s/\"//g' | cut -f 1 -d '.')
      echo "Added $(wc -l < batchN_fixed.json | gawk '{print $1}') events between ${mintime} and ${maxtime2} (requested until ${maxtime})"
    fi
  done
}

# Change into the ANSS directory and update the catalog there

ANSSDIR="${1}"

if [[ ! -d $ANSSDIR ]]; then
  [[ $ANSS_VERBOSE -eq 1 ]] && echo "Creating ANSS seismicity directory ${ANSSDIR}"
  mkdir -p ${ANSSDIR}
fi

cd $ANSSDIR

if [[ ${2} == "rebuild" && ! -z ${3} ]]; then
  echo "Repairing ANSS catalog with backdate to ${3}"
  anss_repair_catalog ${3}
else 

# Download and apply any updates done between the previous scrape time and the current time
echo "Finding updates for existing ANSS catalog..."
anss_update_catalog

echo "Scraping new ANSS events..."
# Update the ANSS catalog with newly scraped data
anss_download_catalog
fi




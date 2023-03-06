#!/bin/bash

# Catalog files are separated into 4 segments per month. A list of possible catalog
# files is generated each time this scraper is run: emsc_list.txt

# Each time this scraper is run, catalog files younger than or overlapping with the date
# stored in emsc_last_downloaded_event.txt are downloaded. Catalog files without a STOP
# line are considered failed and are deleted upon download.

# After downloads are complete

# tectoplot
# bashscripts/scrape_emsc_seismicity.sh
# Copyright (c) 2021 Kyle Bradley, all rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following demsclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following demsclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DEMSCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Download the entire global EMSC seismicity catalog,
# then process into 5x5 degree tiles for quicker plotting.

# Most of the download time is the pull request, but making larger chunks leads
# to some failures due to number of events. The script can be run multiple times
# and will not re-download files that already exist. Some error checking is done
# to look for empty files and delete them.

# Example curl command (broken onto multiple lines)
# curl "${EMSC_MIRROR}/cgi-bin/web-db-v4?request=COMPREHENSIVE&out_format=CATCSV
#       &searchshape=RECT&bot_lat=-90&top_lat=90&left_lon=-180&right_lon=180
#       &ctr_lat=&ctr_lon=&radius=&max_dist_units=deg&srn=&grn=&start_year=${year}
#       &start_month=${month}&start_day=01&start_time=00%3A00%3A00&end_year=${year}
#       &end_month=${month}&end_day=7&end_time=23%3A59%3A59&min_dep=&max_dep=
#       &min_mag=&max_mag=&req_mag_type=Any&req_mag_agcy=prime" > emsc_seis_2019_01_week1.dat

# Note that EMSC queries require the correct final day of the month, including
# leap years! Whyyyy.....

# This is the URL of the mirror to use
EMSC_MIRROR="https://www.seismicportal.eu"

# Set EMSC_VERBOSE=1 for more illuminating messages
EMSC_VERBOSE=1
[[ $EMSC_VERBOSE -eq 1 ]] && CURL_QUIET="" || CURL_QUIET="-s"
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

function repair_emsc_time_json() {
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

range="minlatitude=-90&maxlatitude=90&minlongitude=-180&maxlongitude=180"


function emsc_update_catalog() {

  [[ $EMSC_VERBOSE -eq 1 ]] && echo "Scraping EMSC data in directory $(pwd)"

  if [[ ! -s emsc.gpkg ]]; then
    echo "Earthquakes GPKG does not exist. Initializing."

    echo "Downloading first batch of events"
    while [[ ! -s batch1.json ]]; do
      curl -0 "https://www.seismicportal.eu/fdsnws/event/1/query?format=json&starttime=1998-01-01T00:00:00&endtime=1998-02-02T00:00:00&${range}&limit=4000&orderby=time-asc" > batch1.json
      cat batch1.json
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

    # Make the geopackage
    # Create the geopackage with the emsc table
    if ogr2ogr -f GPKG -nln emsc -t_srs EPSG:4979 emsc.gpkg batch1.json; then
      echo "Created GPKG: emsc.gpkg"
    else
      echo "Creation of emsc GPKG failed"
      rm -f emsc.gpkg batch1.json
      exit 1
    fi

    echo "Adding indexes to GPKG"
    ogrinfo -sql "CREATE INDEX time_index ON emsc (time)" emsc.gpkg
    ogrinfo -sql "CREATE INDEX id_index ON emsc (id)" emsc.gpkg
  fi

  if [[ ! -s emsc.gpkg ]]; then
    echo "emsc.gpkg could not be created... exiting"
    exit 1
  fi

  # From this point on, we will request one year of data at a time, in increments
  # of 20,000 events
  echo "Downloading new events"
  got_events=1

  timeinc=2678400   # seconds in 31 days

  while [[ ${got_events} -eq 1 ]]; do

    # Find the time of the latest event in the database, plus one second
    mintime=$(ogr2ogr -f CSV -dialect spatialite -sql "SELECT MAX(time) FROM emsc" /vsistdout/ emsc.gpkg | sed '1d; s/\"//g' | cut -f 1 -d '.' | add_one_second)

    # Add days so that leap days cannot mess us up!
        maxtime=$(echo $mintime | gawk -v increment=${timeinc} '
          function ceil(x)       { return int(x)+(x>int(x))       }
          function floor(x)      { return ceil(x)-1               }
          {
            date = substr($1,1,10);
            split(date,dstring,"-");
            time = substr($1,12,8);
            split(time,tstring,":");
            the_time = sprintf("%i %i %i %i %i %i",dstring[1],dstring[2],dstring[3],tstring[1],tstring[2],tstring[3]+increment);
            secs = mktime(the_time);
            # print "the_time", the_time > "/dev/stderr"
            newtime = strftime("%FT%T", secs);
            print newtime
          }')
    echo maxtime is ${maxtime}
    rm -f batchN.json
    while [[ ! -s batchN.json ]]; do
      echo "Downloading events between ${mintime} and ${maxtime}, increment is ${timeinc}"

      echo curl -0 "\"${EMSC_MIRROR}/fdsnws/event/1/query?format=json&starttime=$(echo ${mintime} | add_one_second)&endtime=${maxtime}&${range}&orderby=time-asc\"" \> output.json
      if ! curl -0 "${EMSC_MIRROR}/fdsnws/event/1/query?format=json&starttime=$(echo ${mintime} | add_one_second)&endtime=${maxtime}&${range}&orderby=time-asc" > batchN.json; then
        echo "curl error:"
        cat batchN.json
        rm -f batchN.json
        continue
      fi

      # Failure modes are:
      # 1. Error HTML is returned
      # 2. Nothing is returned
      # 3. Too many events requested

      if grep -m 1 "{\"type\":\"Feature" batchN.json >/dev/null; then
        echo "Got JSON"
        timeinc=$(echo "$timeinc * 1.3" | bc -l)
        break
      else
        echo "Returned file does not contain JSON header"
        cat batchN.json
        if grep "Error 413" batchN.json; then
          timeinc=$(echo "$timeinc / 2" | bc -l)
        fi
        maxtime=$(echo $mintime | gawk -v increment=${timeinc} '
          function ceil(x)       { return int(x)+(x>int(x))       }
          function floor(x)      { return ceil(x)-1               }
          {
            date = substr($1,1,10);
            split(date,dstring,"-");
            time = substr($1,12,8);
            split(time,tstring,":");

            the_time = sprintf("%i %i %i %i %i %i",dstring[1],dstring[2],dstring[3],tstring[1],tstring[2],tstring[3]+increment);
            secs = mktime(the_time);
            print "the_time", the_time > "/dev/stderr"
            newtime = strftime("%FT%T", secs);
            print newtime
          }')
        # echo "new maxtime is ${maxtime} (${mintime} + ${timeinc}days is ${maxtime})"
        rm -f batchN.json

        if [[ $(echo ${maxtime} $(date -u +"%FT%T") | gawk '{print ($1>=$2)?1:0}') -eq 1 ]]; then
          echo "Reached current date - ending download"
          return
        fi
      fi
    done


    # If there is an empty bracket [] then data came out but no events were returned
    if grep "\[\]" batchN.json; then
      got_events=0
      echo "No new events found between ${mintime} and requested ${maxtime}"
    else
      ogr2ogr -f GPKG -append -nln emsc emsc.gpkg batchN.json

      maxtime2=$(ogr2ogr -f CSV -dialect spatialite -sql "SELECT MAX(time) FROM emsc" /vsistdout/ emsc.gpkg | sed '1d; s/\"//g' | cut -f 1 -d '.')

      echo "Added some events between ${mintime} and ${maxtime2} (requested until ${maxtime})"
      ogrinfo -so emsc.gpkg emsc | grep Count

    fi
  done
}



# Change into the EMSC directory and update the catalog there

EMSCDIR="${1}"

if [[ -d $EMSCDIR ]]; then
  [[ $EMSC_VERBOSE -eq 1 ]] && echo "EMSC directory exists."
else
  [[ $EMSC_VERBOSE -eq 1 ]] && echo "Creating EMSC seismicity directory ${EMSCDIR}"
  mkdir -p ${EMSCDIR}
fi

cd $EMSCDIR

# Update the EMSC catalog data

emsc_update_catalog

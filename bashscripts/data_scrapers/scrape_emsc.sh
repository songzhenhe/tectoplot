#!/bin/bash

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

# NOTE: As of March 2023, EMSC events from source catalog EMSC-RTS have NEGATIVE
# depths (Z=-40 is equivalent to 40 km below sea level) which must be corrected
# upon download rather than upon selection in order to keep the catalog sane.

# This is the URL of the mirror to use
EMSC_MIRROR="https://www.seismicportal.eu"

# Set EMSC_VERBOSE=1 for more illuminating messages
EMSC_VERBOSE=1
[[ $EMSC_VERBOSE -eq 1 ]] && CURL_QUIET="" || CURL_QUIET="-s"

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

  # If emsc.gpkg does not exist, we will create it in emsc_download_catalog
  if [[ -s emsc.gpkg ]]; then

    # The time of interest is the time range of the existing catalog
    # The update period is the time between the last catalog event and now

    # Upserting (update + insert) plus the use of a unique id index means
    # we cannot somehow delete or duplicate an event - only add/replace 

    mintime=$(ogr2ogr -f CSV -dialect sqlite -sql "SELECT MIN(time) FROM emsc" /vsistdout/ emsc.gpkg | sed '1d; s/\"//g' | cut -f 1 -d '.')
    maxtime=$(ogr2ogr -f CSV -dialect sqlite -sql "SELECT MAX(time) FROM emsc" /vsistdout/ emsc.gpkg | sed '1d; s/\"//g' | cut -f 1 -d '.')

    echo "Downloading events added or update for period ${mintime} to ${maxtime}, but only if updates occurred after ${maxtime}"

    rm -f update.json
    while [[ ! -s update.json ]]; do

      curl -0 "https://www.seismicportal.eu/fdsnws/event/1/query?format=json&starttime=${mintime}&endtime=${maxtime}&updatedafter=${maxtime}&limit=20000&orderby=time-asc" > update.json
      if [[ ! -s update.json ]]; then
        echo "No update data downloaded. Likely too long between updates."
        break
      fi
      if grep -i "<HTML>" update.json; then
        echo "Got actual error message when downloading update data... retrying after 30 seconds"
        sleep 30
        rm update.json
      fi
    done

    # Entries can be upserted (updated or inserted) because we have a single UNIQUE id index
    if grep -m 1 "{\"type\":\"Feature" update.json >/dev/null; then
      ogr2ogr -nln emsc -upsert emsc.gpkg update.json
      echo "Updated or added $(wc -l < update.json | gawk '{print $1}') events"
    fi
    # rm -f update.json
  fi
}

# Delete events in the emsc catalog that have a lastupdated datetime later than the given datetime
# Delete the ID index and add a new UNIQUE index on id

function emsc_repair_catalog() {
  echo "Repairing emsc.gpkg be deleting events with update time after ${1}"
  if [[ -s emsc.gpkg ]]; then
      beforecount=$(ogrinfo -so emsc.gpkg emsc | grep Count | gawk '{print $(NF)}')

      ogrinfo -dialect sqlite -sql "DELETE FROM emsc WHERE lastupdate > '${1}'" emsc.gpkg

      # ogrinfo -dialect sqlite -sql "DELETE FROM emsc WHERE lastupdate > CAST(\"${1}\" AS DateTime)" emsc.gpkg
      aftercount=$(ogrinfo -so emsc.gpkg emsc | grep Count | gawk '{print $(NF)}')

      addedcount=$(echo "$aftercount - $beforecount" | bc)

      echo "Operation changed number of events by ${addedcount}"

      echo "Recreating ID index"
      ogrinfo -sql "DROP INDEX id_index" emsc.gpkg
      ogrinfo -sql "CREATE UNIQUE INDEX id_index ON emsc (id)" emsc.gpkg

  fi  
}


function emsc_download_catalog() {

  [[ $EMSC_VERBOSE -eq 1 ]] && echo "Scraping EMSC data in directory $(pwd)"

  if [[ ! -s emsc.gpkg ]]; then
    echo "Earthquakes GPKG does not exist. Initializing."

    echo "Downloading first batch of events"
    while [[ ! -s batch1.json ]]; do
      curl -0 "https://www.seismicportal.eu/fdsnws/event/1/query?format=json&starttime=1998-01-01T00:00:00&endtime=1998-02-02T00:00:00&${range}&limit=20000&orderby=time-asc" > batch1.json
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
    ogrinfo -sql "CREATE UNIQUE INDEX id_index ON emsc (id)" emsc.gpkg
    ogrinfo -sql "CREATE INDEX mag_index ON emsc (mag)" emsc.gpkg

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


      beforecount=$(ogrinfo -so emsc.gpkg emsc | grep Count | gawk '{print $(NF)}')

      ogr2ogr -f GPKG -upsert -nln emsc emsc.gpkg batchN.json

      aftercount=$(ogrinfo -so emsc.gpkg emsc | grep Count | gawk '{print $(NF)}')

      addedcount=$(echo "$aftercount - $beforecount" | bc)

      maxtime2=$(ogr2ogr -f CSV -dialect spatialite -sql "SELECT MAX(time) FROM emsc" /vsistdout/ emsc.gpkg | sed '1d; s/\"//g' | cut -f 1 -d '.')

      echo "Added $addedcount events between ${mintime} and ${maxtime2} (requested until ${maxtime})"

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


  echo 2 is $2 3 is $3
if [[ ${2} == "rebuild" && ! -z ${3} ]]; then
  echo "Repairing EMSC catalog with backdate to ${3}"
  emsc_repair_catalog ${3}
else 

  # Update events in the catalog 
  emsc_update_catalog

  # Download new events to the EMSC catalog

  emsc_download_catalog
fi

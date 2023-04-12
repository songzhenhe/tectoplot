#!/bin/bash

# Catalog files are separated into 4 segments per month. A list of possible catalog
# files is generated each time this scraper is run: isc_list.txt

# Each time this scraper is run, catalog files younger than or overlapping with the date
# stored in isc_last_downloaded_event.txt are downloaded. Catalog files without a STOP
# line are considered failed and are deleted upon download.

# After downloads are complete

# tectoplot
# bashscripts/scrape_isc_seismicity.sh
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

# Download the entire global ISC seismicity catalog and store in weekly data files,
# then process into 5x5 degree tiles for quicker plotting.

# Most of the download time is the pull request, but making larger chunks leads
# to some failures due to number of events. The script can be run multiple times
# and will not re-download files that already exist. Some error checking is done
# to look for empty files and delete them.

# Example curl command (broken onto multiple lines)
# curl "${ISC_MIRROR}/cgi-bin/web-db-v4?request=COMPREHENSIVE&out_format=CATCSV
#       &searchshape=RECT&bot_lat=-90&top_lat=90&left_lon=-180&right_lon=180
#       &ctr_lat=&ctr_lon=&radius=&max_dist_units=deg&srn=&grn=&start_year=${year}
#       &start_month=${month}&start_day=01&start_time=00%3A00%3A00&end_year=${year}
#       &end_month=${month}&end_day=7&end_time=23%3A59%3A59&min_dep=&max_dep=
#       &min_mag=&max_mag=&req_mag_type=Any&req_mag_agcy=prime" > isc_seis_2019_01_week1.dat

# Note that ISC queries require the correct final day of the month, including leap years!

# Reverse the order of lines in each file, printing the files in order specified
# tac preferred over tail -r preferred over gawk

ISC_VERBOSE=0
[[ $ISC_VERBOSE -eq 1 ]] && CURL_QUIET="" || CURL_QUIET="-s"
# Set ISC_VERBOSE=1 to enable various messages about the scraping process

function tecto_tac() {
  if hash tac 2>/dev/null; then
    tac $@
  elif echo "a" | tail -r >/dev/null 2>&1; then
    tail -r $@
  else
    gawk '{
      data[NR]=$0
    }
    END {
      num=NR
      for(i=num;i>=1;i--) {
        print data[i]
      }
    }' $@
  fi
}

function explode_iso8601() {
  echo $1 | gawk ' {
    date = substr($1,1,10);
    split(date,dstring,"-");
    time = substr($1,12,8);
    split(time,tstring,":");

    printf("%04d %02d %02d %s%s%s%s%02d\n",dstring[1],dstring[2],dstring[3],tstring[1],"%3A",tstring[2],"%3A",tstring[3]);
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


ISCDIR="$1"

if [[ ! -d $ISCDIR ]]; then
  [[ $ISC_VERBOSE -eq 1 ]] && echo "Creating ISC seismicity directory ${ISCDIR}"
  mkdir -p ${ISCDIR}
fi

cd $ISCDIR

ISC_MIRROR="http://www.isc.ac.uk"

if [[ $2 == "wash" ]]; then
  ISC_MIRROR="http://isc-mirror.iris.washington.edu"
elif [[ $2 == "uk" ]]; then
  ISC_MIRROR="http://www.isc.ac.uk"
fi

function iscseis_update_catalog() {

  [[ $ISC_VERBOSE -eq 1 ]] && echo "Scraping ISC data in directory $(pwd)"

  if [[ ! -s iscseis.gpkg ]]; then
    echo "Earthquakes GPKG does not exist. Initializing."

    # Download the first batch of data
    # 1900 01 01 00 00 00 1968 06 18 07 38 15
    echo "Downloading first batch of events"
    while [[ ! -s batch1.csv ]]; do
      curl -0 "${ISC_MIRROR}/cgi-bin/web-db-v4?request=COMPREHENSIVE&out_format=CATCSV&searchshape=GLOBAL&start_year=1900&start_month=01&start_day=01&start_time=00%3A00%3A00&end_year=1940&end_month=06&end_day=18&end_time=23%3A59%3A59&req_mag_type=Any&req_mag_agcy=prime" > batch1.csv
      if [[ ! -s batch1.csv ]]; then
        echo "No data downloaded... retrying after 30 seconds"
        sleep 30
      fi
      if ! grep -m 1 "STOP" batch1.csv >/dev/null; then
        echo "Did not receive CSV events... retrying after 30 seconds"
        sleep 30
        rm batch1.csv
      fi
    done

    echo "EVENTID,TYPE,AUTHOR,DATE,LAT,LON,DEPTH,DEPFIX,ORIGAUTHOR,MAGTYPE,MAG " > iscseis.csv
    cat batch1.csv | sed -n '/^  EVENTID/,/^STOP/p' | sed '1d;$d' | sed '$d' | sed 's/^\(.\{35\}\)./\1T/' | cut -b 1-101 | gawk -F '[[:space:]]*,[[:space:]]*' '{$1=$1}1' OFS=, | sed 's/^ *//g' >> iscseis.csv

    if ogr2ogr -f "GPKG" -nln iscseis iscseis.gpkg iscseis.vrt; then
      echo "Created GPKG: iscseis.gpkg"
    else
      echo "Creation of iscseis GPKG failed"
      rm -f iscseis.gpkg event1.csv
      exit 1
    fi

    mintime=$(ogr2ogr -f CSV -dialect spatialite -sql "SELECT MAX(time) FROM iscseis" /vsistdout/ iscseis.gpkg | sed '1d; s/\"//g' | cut -f 1 -d '.')

    echo "Adding indexes to GPKG"
    ogrinfo -sql "CREATE INDEX time_index ON iscseis (time)" iscseis.gpkg
    ogrinfo -sql "CREATE INDEX id_index ON iscseis (id)" iscseis.gpkg
    ogrinfo -sql "CREATE INDEX mag_index ON iscseis (mag)" iscseis.gpkg

  fi

  if [[ ! -s iscseis.gpkg ]]; then
    echo "iscseis.gpkg could not be created... exiting"
    exit 1
  fi

  # From this point on, we will request one year of data at a time, in increments
  # of 20,000 events
  echo "Downloading new events from ISC"
  got_events=1
  while [[ ${got_events} -eq 1 ]]; do

    # Find the time of the latest event in the database, plus one second
    if [[ $keepgoingflag -eq 1 ]]; then
      mintime=${keepgoingtime}
    else
      mintime=$(ogr2ogr -f CSV -dialect sqlite -sql "SELECT MAX(time) FROM iscseis" /vsistdout/ iscseis.gpkg | sed '1d; s/\"//g' | cut -f 1 -d '.' | add_one_second)
    fi

    keepgoingflag=0
    # Add days so that leap days cannot mess us up! Two weeks should be OK for all time intervals thus far.

    maxtime=$(echo $mintime | gawk '
      {
        date = substr($1,1,10);
        split(date,dstring,"-");
        time = substr($1,12,8);
        split(time,tstring,":");

        the_time = sprintf("%i %i %i %i %i %i",dstring[1],dstring[2],dstring[3]+14,0,0,0);
        secs = mktime(the_time);
        newtime = strftime("%FT%T", secs);
        print newtime
      }')

    rm -f batchN.csv

    while [[ ! -s batchN.csv ]]; do
      echo "Downloading events between ${mintime} and ${maxtime}"
      stexp=($(explode_iso8601 $(echo $mintime | add_one_second)))
      etexp=($(explode_iso8601 $maxtime))

      echo curl "${ISC_MIRROR}/cgi-bin/web-db-v4?request=COMPREHENSIVE&out_format=CATCSV&searchshape=GLOBAL&start_year=${stexp[0]}&start_month=${stexp[1]}&start_day=${stexp[2]}&start_time=${stexp[3]}&end_year=${etexp[0]}&end_month=${etexp[1]}&end_day=${etexp[2]}&end_time=${etexp[3]}&req_mag_type=Any&req_mag_agcy=prime"
      if ! curl -0 "${ISC_MIRROR}/cgi-bin/web-db-v4?request=COMPREHENSIVE&out_format=CATCSV&searchshape=GLOBAL&start_year=${stexp[0]}&start_month=${stexp[1]}&start_day=${stexp[2]}&start_time=${stexp[3]}&end_year=${etexp[0]}&end_month=${etexp[1]}&end_day=${etexp[2]}&end_time=${etexp[3]}&req_mag_type=Any&req_mag_agcy=prime" > batchN.csv; then
        echo "curl error:"
        cat batchN.csv
        rm -f batchN.csv
        continue
      fi

      if grep -m 1 "Events found:" batchN.csv >/dev/null; then
        break
      elif grep "No events were found" batchN.csv >/dev/null; then
        echo "No events were found within time window."
        if [[ $(echo ${maxtime} $(date -u +"%FT%T") | gawk '{print ($1>=$2)?1:0}') -eq 1 ]]; then
          echo "Reached current date - ending download"
          return
        else
          # No events in time window, but not yet up to present day
          keepgoingflag=1
          keepgoingtime=${maxtime}
          continue
        fi
      else
        echo "Returned file does not contain CSV data - likely a server error. Sleeping for 10 seconds and trying again"
        cat batchN.csv
        rm -f batchN.csv
        sleep 10
      fi
    done

    echo "EVENTID,TYPE,AUTHOR,DATE,LAT,LON,DEPTH,DEPFIX,ORIGAUTHOR,MAGTYPE,MAG " > iscseis.csv
    cat batchN.csv | sed -n '/^  EVENTID/,/^STOP/p' | sed '1d;$d' | sed '$d' | sed 's/^\(.\{35\}\)./\1T/' | cut -b 1-101 | gawk -F '[[:space:]]*,[[:space:]]*' '{$1=$1}1' OFS=, | sed 's/^ *//g' >> iscseis.csv

    ogr2ogr -f GPKG -upsert -nln iscseis iscseis.gpkg iscseis.vrt

    maxtime2=$(ogr2ogr -f CSV -dialect spatialite -sql "SELECT MAX(time) FROM iscseis" /vsistdout/ iscseis.gpkg | sed '1d; s/\"//g' | cut -f 1 -d '.')

    echo "Added some events between ${mintime} and ${maxtime2} (requested until ${maxtime})"
  done
}

# Change into the ISC directory and update the catalog there

ISCDIR="${1}"

if [[ -d $ISCDIR ]]; then
  [[ $ISC_VERBOSE -eq 1 ]] && echo "ISC directory exists."
else
  [[ $ISC_VERBOSE -eq 1 ]] && echo "Creating ISC seismicity directory ${ISCDIR}"
  mkdir -p ${ISCDIR}
fi

cd $ISCDIR

cat <<-EOF > iscseis.vrt
<OGRVRTDataSource>
    <OGRVRTLayer name="iscseis">
        <SrcDataSource>iscseis.csv</SrcDataSource>
        <GeometryField encoding="PointFromColumns" x="LON" y="LAT" z="DEPTH"/>
        <GeometryType>wkbPoint</GeometryType>
        <LayerSRS>EPSG:4979</LayerSRS>
        <OpenOptions>
            <OOI key="EMPTY_STRING_AS_NULL">YES</OOI>
        </OpenOptions>
        <Field name="id" type="String" src="EVENTID" nullable="true"/>
        <Field name="type" type="String" src="TYPE" nullable="true"/>
        <Field name="title" type="String" src="AUTHOR" nullable="true"/>
        <Field name="time" type="DateTime" src="DATE" nullable="true"/>
        <Field name="latitude" type="Real" src="LAT" nullable="true"/>
        <Field name="longitude" type="Real" src="LON" nullable="true"/>
        <Field name="depth" type="Real" src="DEPTH" nullable="true"/>
        <Field name="depthfix" type="Real" src="DEPFIX" nullable="true"/>
        <Field name="net" type="String" src="ORIGAUTHOR" nullable="true"/>
        <Field name="magType" type="String" src="MAGTYPE" nullable="true"/>
        <Field name="mag" type="Real" src="MAG" nullable="true"/>
    </OGRVRTLayer>
</OGRVRTDataSource>
EOF


# Update the ISC catalog data

iscseis_update_catalog

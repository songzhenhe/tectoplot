#!/bin/bash

# tectoplot
# bashscripts/scrape_anss_data.sh
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

# scrape_anss_data.sh [directory]

# Download the entire global ANSS (Advanced National Seismic System) event
# catalog and store in semi-monthly data files in [directory]/, then process
# into 5 degree tiles in [directory]/Tiles/. The total download size is currently
# ~650 Mb (2020) and takes a LONG time.

# This script will only download files that have not been marked as COMPLETE,
# as indicated by their presence in anss_complete.txt, and will only add events
# to tiles if their date is later than the date of the most recently added
# event stored in anss_last_downloaded_event.txt. A file is marked as complete
# if a file with a later date is successfully downloaded during the same session.

# Example curl command:
# curl "https://earthquake.usgs.gov/fdsnws/event/1/query?format=csv&starttime=${year}-${month}-${day}&endtime=${year}-${month}-${day}&minlatitude=-90&maxlatitude=90&minlongitude=-180&maxlongitude=180"

# The arbitrary moment that divides the catalog into old and new events, to speed
# up data scraping and data access when looking at recent events.

function tecto_tac() {
  gawk '{
    data[NR]=$0
  }
  END {
    num=NR
    for(i=num;i>=1;i--) {
      print data[i]
    }
  }' "$@"
}

# iso8601 is YYYY-MM-DDTHH:MM:SS = 19 characters
function lastday_of_month() {
  month=$(printf "%02d" $1)
  case $month in
      0[13578]|10|12) days=31;;
      0[469]|11)	    days=30;;
      02) days=$(echo $year | gawk '{
          jul=strftime("%j",mktime($1 " 12 31 0 0 0 "));
          if (jul==366) {
            print 29
          } else {
            print 28
          }
         }')
  esac
  echo $days
}

function has_a_line() {
  if [[ -e $1 ]]; then
    gawk '
    BEGIN {
      x=0
    }
    {
      if(NR>2) {
        x=1;
        exit
      }
    }
    END {
      if(x>0) {
        print 1
      } else {
        print 0
      }
    }' < $1
  else
    echo 0
  fi
}

# input: name of file anss_events_year_month_index.cat
function download_anss_file() {
  local parsed=($(echo $1 | gawk -F_ '{ split($5, d, "."); print $3, $4, d[1]}'))
  local year=${parsed[0]}
  local month=${parsed[1]}
  local segment=${parsed[2]}

  if [[ $1 =~ "anss_events_1000_to_1950.cat" ]]; then
    echo "Downloading seismicity for $1: Year=1000 to 1950"
    curl "https://earthquake.usgs.gov/fdsnws/event/1/query?format=csv&starttime=1000-01-01T00:00:00&endtime=1950-12-31T23:59:59&minlatitude=-90&maxlatitude=90&minlongitude=-180&maxlongitude=180&orderby=time-asc" > $1
  else
    echo "Downloading seismicity for $1: Year=${year} Month=${month} Segment=${segment}"

    case ${parsed[2]} in
      1)
      curl "https://earthquake.usgs.gov/fdsnws/event/1/query?format=csv&starttime=${year}-${month}-01T00:00:00&endtime=${year}-${month}-10T23:59:59&minlatitude=-90&maxlatitude=90&minlongitude=-180&maxlongitude=180&orderby=time-asc" > $1
      ;;
      2)
      curl "https://earthquake.usgs.gov/fdsnws/event/1/query?format=csv&starttime=${year}-${month}-11T00:00:00&endtime=${year}-${month}-20T23:59:59&minlatitude=-90&maxlatitude=90&minlongitude=-180&maxlongitude=180&orderby=time-asc" > $1
      ;;
      3)
      last_day=$(lastday_of_month $month)
      echo curl "https://earthquake.usgs.gov/fdsnws/event/1/query?format=csv&starttime=${year}-${month}-21T00:00:00&endtime=${year}-${month}-${last_day}T23:59:59&minlatitude=-90&maxlatitude=90&minlongitude=-180&maxlongitude=180&orderby=time-asc"
      curl "https://earthquake.usgs.gov/fdsnws/event/1/query?format=csv&starttime=${year}-${month}-21T00:00:00&endtime=${year}-${month}-${last_day}T23:59:59&minlatitude=-90&maxlatitude=90&minlongitude=-180&maxlongitude=180&orderby=time-asc" > $1
      ;;
    esac
  fi
  # If curl returned a non-zero exit code or doesn't contain at least two lines, delete the file we just created
  if ! [ 0 -eq $? ]; then
    echo "File $1 had download error. Deleting."
    # rm -f $1
  elif [[ $(has_a_line $1) -eq 0 ]]; then
    echo "File $1 was empty. Deleting."
    # rm -f $1
  fi
}

# Change into the ANSS data directory, creating if needed, and check Tiles directory
# Create tile files using touch

ANSSDIR="${1}"

[[ ! -d $ANSSDIR ]] && mkdir -p $ANSSDIR

ANSSDIR=$ANSSDIR

if [[ ! -d $ANSSDIR ]]; then
  echo "Creating ANSS directory ${ANSSDIR}"
  mkdir -p ${ANSSDIR}
fi

cd $ANSSDIR

# Sort the anss_complete.txt file to preserve the order of earliest->latest
if [[ -e anss_complete.txt ]]; then
  sort < anss_complete.txt -t '_' -n -k 3 -k 4 -k 5 > anss_complete.txt.sort
  mv anss_complete.txt.sort anss_complete.txt
fi

if ! [[ $2 =~ "rebuild" ]]; then

  rm -f anss_just_downloaded.txt

  if [[ -e anss_last_downloaded_event.txt ]]; then
    lastevent_epoch=$(tail -n 1 anss_last_downloaded_event.txt | gawk -F, '{print substr($1,1,19)}' | iso8601_to_epoch)
    lastevent_date=$(tail -n 1 anss_last_downloaded_event.txt | gawk -F, '{print substr($1,1,19)}')
  else
    lastevent_epoch=$(echo "1900-01-01T00:00:01" | iso8601_to_epoch)
    lastevent_date="1900-01-01T00:00:01"
  fi
  # echo "Last event from previous scrape has epoch $lastevent_epoch"
  # echo "Last event from previous scrape has data $lastevent_date"


  this_year=$(date -u +"%Y")
  this_month=$(date -u +"%m")
  this_day=$(date -u +"%d")
  this_datestring=$(date -u +"%Y-%m-%dT%H:%M:%S")

  # Generate a list of all possible catalog files that can be downloaded
  # This takes a while and could be done differently with a persistent file

  # Look for the last entry in the list of catalog files
  final_cat=($(tail -n 1 ./anss_list.txt 2>/dev/null | gawk -F_ '{split($5, a, "."); print $3, $4, a[1]}'))

  # If there is no last entry (no file), regenerate the list
  if [[ -z ${final_cat[0]} ]]; then
    # echo "Generating new catalog file list..."
    echo "anss_events_1000_to_1950.cat" > ./anss_list.txt
    for year in $(seq 1951 $this_year); do
      for month in $(seq 1 12); do
        if [[ $(echo "($year == $this_year) && ($month > $this_month)" | bc) -eq 1 ]]; then
          break 1
        fi
        for segment in $(seq 1 3); do
          if [[ $(echo "($year == $this_year) && ($month == $this_month)" | bc) -eq 1 ]]; then
            [[ $(echo "($segment == 2) && ($this_day < 11)"  | bc) -eq 1 ]] && break
            [[ $(echo "($segment == 3) && ($this_day < 21)"  | bc) -eq 1 ]] && break
          fi
          echo "anss_events_${year}_${month}_${segment}.cat" >> ./anss_list.txt
        done
      done
    done
  else
  # Otherwise, add the events that postdate the last catalog file.
    # echo "Adding new catalog files to file list..."
    final_year=${final_cat[0]}
    final_month=${final_cat[1]}
    final_segment=${final_cat[2]}

    for year in $(seq $final_year $this_year); do
      for month in $(seq 1 12); do
        if [[  $(echo "($year == $this_year) && ($month > $this_month)" | bc) -eq 1 ]]; then
          break 1
        fi
        for segment in $(seq 1 3); do
          # Determine when to exit the loop as we have gone into the future
          if [[ $(echo "($year >= $this_year) && ($month >= $this_month)" | bc) -eq 1 ]]; then
             [[ $(echo "($segment == 2) && ($this_day < 11)"  | bc) -eq 1 ]] && break
             [[ $(echo "($segment == 3) && ($this_day < 21)"  | bc) -eq 1 ]] && break
          fi
          # Determine whether to suppress printing of the catalog ID as it already exists
          if ! [[ $(echo "($year <= $final_year) && ($month < $final_month)" | bc) -eq 1 ]]; then
            if [[ $(echo "($year == $final_year) && ($month == $final_month) && ($segment <= $final_segment)" | bc) -eq 0 ]]; then
              echo "anss_events_${year}_${month}_${segment}.cat" >> ./anss_list.txt
            fi
          fi
        done
      done
    done
  fi

  # Get a list of files that should exist but are not marked as complete
  cat anss_complete.txt anss_list.txt | sort -r -n -t "_" -k 3 -k 4 -k 5 | uniq -u > anss_incomplete.txt

  anss_list_files=($(tecto_tac anss_incomplete.txt))

  # echo ${anss_list_files[@]}

  # For each of these files, in order from oldest to most recent, download the file.
  # Keep track of the last complete download made. If a younger file is downloaded
  # successfully, mark the older file as complete. Keep track of which files we
  # downloaded (potentially new) data into.

  last_index=-1
  for d_file in ${anss_list_files[@]}; do
    download_anss_file ${d_file}
    if [[ ! -e ${d_file} || $(has_a_line ${d_file}) -eq 0 ]]; then
      echo "File ${d_file} was not downloaded or has no events. Not marking as complete"
    else
      echo ${d_file} >> anss_just_downloaded.txt
      if [[ $last_index -ge 0 ]]; then
        # Need to check whether the last file exists still before marking as complete (could have been deleted)
        echo "File ${d_file} had events... marking earlier file ${anss_list_files[$last_index]} as complete."
        if [[ -e ${anss_list_files[$last_index]} ]]; then
          echo ${anss_list_files[$last_index]} >> anss_complete.txt
          # echo "Zipping file ${anss_list_files[$last_index]} into storage"
          # zip ${ANSS_ARCHIVEZIP} ${anss_list_files[$last_index]} && rm -f ${anss_list_files[$last_index]}
        fi
      fi
    fi
    last_index=$(echo "$last_index + 1" | bc)
  done

else
  # Completely rebuild the tiles directory from the downloaded catalog datasets
  echo "Rebuilding ANSS tiles is no longer possible - delete manually and rescrape."
fi

# Add downloaded data to Tiles.

# If we downloaded a file (should always happen as newest file is never marked complete)
if [[ -e anss_just_downloaded.txt ]]; then

  selected_files=$(cat anss_just_downloaded.txt)

  # For each candidate file, examine events and see if they are younger than the
  # last event that has been added to a tile file. Keep track of the youngest
  # event added to tiles and record that for future scrapes.

  for anss_file in $selected_files; do
    # echo "Processing file $anss_file into tile files"

    gawk < $anss_file -F, -v tiledir=${ANSSDIR} -v mindate=$lastevent_date -v oldcatdate=${OLDCAT_DATE} '
    @include "tectoplot_functions.awk"

    BEGIN { added=0 }
    (NR>1) {
      eventdate=substr($1, 1, 19)

      if (eventdate > mindate) {

        if (eventdate > oldcatdate) {
          catstr="_new"
        } else {
          catstr="_old"
        }

        tilestr=sprintf("%stile_%d_%d%s.cat", tiledir, rd($3,5), rd($2,5), catstr);
        print $0 >> tilestr
        added++
      } else {
        print $0 >> "./not_tiled.cat"
      }
    }
    END {
      print "Added", added, "events to ANSS tiles."
    }'

  done

  # Don't match tile_*.cat as a file...
  shopt -s nullglob
  newfiles=(${ANSSDIR}tile_*_old.cat)

  # The tile files are the new data that needs to be added into the ZIP file
  for newfile in ${newfiles[@]}; do
    thisname=$(basename $newfile | sed 's/_old//')
    # echo unzip -p ${ANSS_TILEZIP} ${thisname}
    # ls -l ${ANSSDIR}${thisname}
    unzip -p ${ANSS_TILEOLDZIP} ${thisname} > temp.cat 2>/dev/null
    cat temp.cat ${newfile} > temp2.cat
    mv temp2.cat ${thisname}
    # ls -l ${ANSSDIR}${thisname}
    # Update the zip file as needed
    # echo zip ${ANSS_TILEZIP} ${ANSSDIR}${thisname}
    zip ${ANSS_TILEOLDZIP} ${thisname} && rm -f ${thisname}
  done

  shopt -s nullglob
  newfiles=(${ANSSDIR}tile_*_new.cat)
  # The tile files are the new data that needs to be added into the ZIP file
  for newfile in ${newfiles[@]}; do
    thisname=$(basename $newfile | sed 's/_new//')
    # echo unzip -p ${ANSS_TILEZIP} ${thisname}
    # ls -l ${ANSSDIR}${thisname}
    unzip -p ${ANSS_TILENEWZIP} ${thisname} > temp.cat
    cat temp.cat ${newfile} > temp2.cat
    mv temp2.cat ${thisname}
    # ls -l ${ANSSDIR}${thisname}
    # Update the zip file as needed
    # echo zip ${ANSS_TILEZIP} ${ANSSDIR}${thisname}
    zip ${ANSS_TILENEWZIP} ${thisname} && rm -f ${thisname}
  done
  # echo "After updating, tile files in the directory are:"
  # ls -l ${ANSSDIR}tile_*.cat
  #
  # # Update the zip file as needed
  # zip -u ${ANSS_TILEZIP}${thisname}
  # Remove the tile files


  last_downloaded_file=$(tail -n 1 anss_just_downloaded.txt)
  last_downloaded_event=$(tail -n 1 $last_downloaded_file)

  # Update last_downloaded_event.txt

  # Should we perform a sanity check here for last downloaded event?

  # Check whether the event latest event exists and if so, mark it
  if [[ ! -z ${last_downloaded_event} ]]; then
    echo "Marking last downloaded event: $last_downloaded_event"
    echo $last_downloaded_event > anss_last_downloaded_event.txt
    # Update last_downloaded_event.txt
  fi

fi

# Cleanup

rm -f *.cat
rm -f anss_incomplete.txt anss_just_downloaded.txt

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

# This is the date that separates old catalog from new (more rapidly updated) catalog
ISC_MIRROR="http://isc-mirror.iris.washington.edu"

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

function epoch_ymdhms() {
  echo "$1 $2 $3 $4 $5 $6" | gawk '{
    the_time=sprintf("%i %i %i %i %i %i",$1,$2,$3,$4,$5,$6);
    print mktime(the_time);
  }'
}

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

function generate_isc_list() {
  startyear=$1
  thisdate=$2

  gawk -v startyear=$startyear -v thisdate=$thisdate '
  BEGIN {
    split(thisdate, a, ":")
    thisyear=a[1]
    thismonth=a[2]
    for (year=startyear; year<=thisyear; year++) {
      for (month=1; month<=12; month++) {
        if (year==thisyear && month > thismonth) {
          break
        }
        for (segment=1; segment<=4; segment++) {
          if (year==thisyear && month > thismonth) {
            if ((segment==1 && thisday < 7) || (segment==2 && thisday < 14) || (segment==3 && thisday < 21)) {
              break
            }
          }
          print "isc_events_" year "_" month "_" segment "_.cat"
        }
      }
    }
  }'
}

# This function will manage downloading of an ISC seismicity catalog file spanning the given
# date range. If the date range is valid, the function will check whether such a file already
# exists, and if so whether it is a valid catalog file containing events. If the date range
# spans the current date, it will delete the file and redownload because new events are likely.

# arguments: startyear startmonth startday endyear endmonth endday today_epoch segmentnumber

function download_and_check() {
  local s_year=$1
  local s_month=$2
  local s_day=$3
  local e_year=$4
  local e_month=$5
  local e_day=$6
  local today_epoch=$7

  
  local mark_as_complete=1

  start_epoch=$(epoch_ymdhms $s_year $s_month $s_day 0 0 0)
  end_epoch=$(epoch_ymdhms $e_year $e_month $e_day 23 59 59)

  # Test whether the file is entirely within the future. If so, don't download.
  if [[ $start_epoch -ge $today_epoch ]]; then
    echo "s" $start_epoch "t" $today_epoch
    echo "Requested begin date ${s_year}-${s_month}-${s_day} is in the future. Not downloading anything."
  else
    # Generate the filename
    local OUTFILE=$(printf "isc_events_%d_%d_%d_.cat" $s_year $s_month $segment)

    # Test whether the file time spans the current date. If so, delete it so we can redownload.
    if [[ $start_epoch -le $today_epoch && $end_epoch -gt $today_epoch ]]; then
      echo "Requested end date ${s_year}-${s_month}-${s_day} is in the future. Removing existing file."
      rm -f $OUTFILE
      mark_as_complete=0
    fi

    # If the file already exists, check to see if it in the completed downloads file list.
    if [[ -s "$OUTFILE" ]]; then
        # Search from the end of the file toward the beginning, stop at first match
        local iscomplete=$(grep -m 1 ${OUTFILE} isc_complete.txt)
        if [[ $iscomplete == "${OUTFILE}" ]]; then
          echo "${OUTFILE} is in the completed download list. Not redownloading"
          return
        else
          echo "${OUTFILE} exists but is not marked as complete. Deleting and redownloading."
          rm -f "${OUTFILE}"
        fi
    fi

    echo "Dowloading seismicity from ${s_year}-${s_month}-${s_day} to ${e_year}-${e_month}-${e_day}"

    curl "${ISC_MIRROR}/cgi-bin/web-db-v4?request=COMPREHENSIVE&out_format=CATCSV&searchshape=RECT&bot_lat=-90&top_lat=90&left_lon=-180&right_lon=180&ctr_lat=&ctr_lon=&radius=&max_dist_units=deg&srn=&grn=&start_year=${s_year}&start_month=${s_month}&start_day=${s_day}&start_time=00%3A00%3A00&end_year=${e_year}&end_month=${e_month}&end_day=${e_day}&end_time=23%3A59%3A59&min_dep=&max_dep=&min_mag=&max_mag=&req_mag_type=Any&req_mag_agcy=prime" > $OUTFILE

    CURL_EXIT=$?
    echo "CURL returned exit code ${CURL_EXIT}"
    # Test for STOP line
    local iscomplete=$(tecto_tac "${OUTFILE}" | grep -m 1 STOP)  # == 1 is complete, == 0 is not
    if [[ $iscomplete != "STOP" ]]; then
      echo "Newly downloaded ${OUTFILE} does not have STOP line and is not a complete/valid ISC SEIS file. Deleting."
      # rm -f "${OUTFILE}"
    else
      if [[ $mark_as_complete -eq 1 ]]; then
        echo "Newly downloaded ${OUTFILE} does have STOP line and mark_as_complete is 1: marking as complete"
        echo "${OUTFILE}" >> isc_complete.txt
      fi
    fi
  fi
}


# This is the logic for downloading an ISC file

# Input is the filename of the catalog to be downloaded although it could also just be
# year month segment today_epoch

# Arguments
#   year
#   month
#   segment
#   today_epoch
#   start_epoch

function download_isc_file() {
  local year=${1}
  local month=${2}
  local segment=${3}
  local today_epoch=${4}

  if [[ $year -eq 1900 ]]; then
    echo "Downloading seismicity for years 1900 to 1953"
    download_and_check 1900 01 01 1953 12 31 $today_epoch 0
  else

    case ${segment} in
      1)
        s_day=01
        e_day=07
        ;;
      2)
        s_day=08
        e_day=14
      ;;
      3)
        s_day=15
        e_day=21
      ;;
      4)
        s_day=22
        e_day=$(lastday_of_month $month)
      ;;
    esac

    echo "Downloading seismicity for $1: Year=${year} Month=${month} Segment=${segment}"
    download_and_check ${year} ${month} ${s_day} ${year} ${month} ${e_day} ${today_epoch} ${segment}
  fi
}

# Change into the ISC data directory, creating if needed, and check Tiles directory
# Create tile files using touch

function download_isc_main {
  # isc_complete.txt contains the names of catalog files that are verified to be
  # complete (the catalog contains a STOP line and the end date is not in the future)

  # Sort the isc_complete.txt file to preserve the order of earliest->latest
  if [[ -s isc_complete.txt ]]; then
    sort < isc_complete.txt -t '_' -n -k 3 -k 4 -k 5 > isc_complete.txt.sort
    mv isc_complete.txt.sort isc_complete.txt
  fi

  this_year=$(date -u +"%Y")
  this_month=$(date -u +"%m")
  this_day=$(date -u +"%d")
  this_hour=$(date -u +"%H")
  this_minute=$(date -u +"%M")
  this_second=$(date -u +"%S")

  thisdate=$(date -u +"%Y:%m:%d:%H:%M:%S")

  today_epoch=$(epoch_ymdhms $this_year $this_month $this_day $this_hour $this_minute $this_second)

  # new format for isc is isc_events_year_month_segment.cat

  # Look for the last entry in the list of catalog files
  startyear=1954

  # Generate the list of files
  echo "Generating list of ISC catalog files"
  echo "isc_events_1900_1_0_.cat" > ./isc_list.txt
  generate_isc_list $startyear $thisdate >> ./isc_list.txt

  echo "Getting list of catalog files to download"
  # Get a list of files that should exist but are not already marked as complete
  cat isc_complete.txt isc_list.txt | sort -r -n -t "_" -k 3 -k 4 -k 5 | uniq -u > isc_incomplete.txt

  isc_list_files=($(tecto_tac isc_incomplete.txt))

  for d_file in ${isc_list_files[@]}; do
    datearr=($(echo $d_file | gawk '{ split($0,a,"_"); print a[3]; print a[4]; print a[5]; }'))
    echo "Downloading ${d_file}"
    # year month segment today_epoch
    download_isc_file ${datearr[0]} ${datearr[1]} ${datearr[2]} ${today_epoch}
  done
}

function tile_downloaded_catalogs {
  # Don't match tile_*.cat as a file...
  TILEDIR=$1
  COMPLETEDIR=$2

  shopt -s nullglob

  echo "Getting list of complete catalog files to add to tiles"
  ls isc_events_*.cat > isc_catalog_files.txt 2>/dev/null
  # Get a list of files that should exist but are not already marked as complete
  # If a name is in BOTH the complete list AND the files in directory, tile it
  cat isc_complete.txt isc_catalog_files.txt | sort -r -n -t "_" -k 3 -k 4 -k 5 | uniq -d > isc_catalogs_to_tile.txt

  echo "Getting list of incomplete catalog files to add to temporary catalog file"
  # Get a list of files that should exist but are not already marked as complete
  cat isc_complete.txt isc_list.txt | sort -r -n -t "_" -k 3 -k 4 -k 5 | uniq -u  > isc_temporary_catalogs.txt

  # For each candidate file, examine events and see if they are younger than the
  # last event that has been added to a tile file. Keep track of the youngest
  # event added to tiles and record that for future scrapes.
  selected_files=$(cat isc_catalogs_to_tile.txt)

  for isc_file in $selected_files; do
    echo "Processing file $isc_file into tile files"
    sed -n '/^  EVENTID/,/^STOP/p' $isc_file | sed '1d;$d' | sed '$d' | gawk -F, -v tiledir=${TILEDIR} -v mindate=$lastevent_date -v oldcatdate=${OLDCAT_DATE} '
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
      tilestr=sprintf("%stile_%d_%d.cat", tiledir, rd($7,5), rd($6,5));
      print $0 >> tilestr
      added++
    }
    END {
      print "Added", added, "events to ISC tiles."
    }'
    mv $isc_file $COMPLETEDIR
  done

  selected_files=$(cat isc_temporary_catalogs.txt)

  rm -f ${TILEDIR}isc_temporary.cat
  for isc_file in $selected_files; do
    if [[ -s $isc_file ]]; then
      echo "Processing temporary file $isc_file into temporary file"
      sed -n '/^  EVENTID/,/^STOP/p' $isc_file | sed '1d;$d' | sed '$d' >> ${TILEDIR}isc_temporary.cat
      echo "Deleting temporary catalog file $isc_file"
      rm -f $isc_file
    fi
  done
  echo "Temporary catalog contains $(wc -l < ${TILEDIR}isc_temporary.cat) events"
}

ISCDIR="$1"

if [[ -d $ISCDIR ]]; then
  echo "ISC tile directory exists."
else
  echo "Creating ISC seismicity directory ${ISCDIR}"
  mkdir -p ${ISCDIR}
fi

cd $ISCDIR

if [[ ! -d ./tiles ]]; then
  mkdir -p ./tiles
fi

if [[ ! -d ./savedcats ]]; then
  mkdir -p ./savedcats
fi

# First we download ISC catalog files

download_isc_main

# Then we process any complete .cat files into tile files and delete them,
# and put the contents of any incomplete .cat files into the isc_temporary.cat file

tile_downloaded_catalogs "./tiles/" "./savedcats/"

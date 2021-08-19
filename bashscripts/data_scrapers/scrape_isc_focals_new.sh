#!/bin/bash

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
# The

# Example curl command (broken onto multiple lines)
# curl "${ISC_MIRROR}/cgi-bin/web-db-v4?request=COMPREHENSIVE&out_format=CATCSV
#       &searchshape=RECT&bot_lat=-90&top_lat=90&left_lon=-180&right_lon=180
#       &ctr_lat=&ctr_lon=&radius=&max_dist_units=deg&srn=&grn=&start_year=${year}
#       &start_month=${month}&start_day=01&start_time=00%3A00%3A00&end_year=${year}
#       &end_month=${month}&end_day=7&end_time=23%3A59%3A59&min_dep=&max_dep=
#       &min_mag=&max_mag=&req_mag_type=Any&req_mag_agcy=prime" > isc_seis_2019_01_week1.dat

# Note that ISC queries require the correct final day of the month, including leap years!

# tac not available in all environments but tail usually is.

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


function download_isc_focals_file() {
  local parsed=($(echo $1 | gawk -F_ '{ split($4, d, "."); print $3, d[1]}'))
  local year=${parsed[0]}
  # local month=${parsed[1]}
  local segment=${parsed[1]}

  echo "Downloading data for $1: Year=${year} Segment=${segment}"

  # Segment 1 is January - April 01-04
  # Segment 2 is May - August 05-08
  # Segment 3 is September-December - 09-12

  case ${parsed[1]} in
    1)
      curl "${ISC_MIRROR}/cgi-bin/web-db-v4?request=COMPREHENSIVE&out_format=FMCSV&bot_lat=-90&top_lat=90&left_lon=-180&right_lon=180&ctr_lat=&ctr_lon=&radius=&max_dist_units=deg&searchshape=GLOBAL&srn=&grn=&start_year=${year}&start_month=01&start_day=01&start_time=00%3A00%3A00&end_year=${year}&end_month=04&end_day=30&end_time=23%3A59%3A59" > $1
    ;;
    2)
      curl "${ISC_MIRROR}/cgi-bin/web-db-v4?request=COMPREHENSIVE&out_format=FMCSV&bot_lat=-90&top_lat=90&left_lon=-180&right_lon=180&ctr_lat=&ctr_lon=&radius=&max_dist_units=deg&searchshape=GLOBAL&srn=&grn=&start_year=${year}&start_month=05&start_day=01&start_time=00%3A00%3A00&end_year=${year}&end_month=08&end_day=31&end_time=23%3A59%3A59" > $1
    ;;
    3)
      curl "${ISC_MIRROR}/cgi-bin/web-db-v4?request=COMPREHENSIVE&out_format=FMCSV&bot_lat=-90&top_lat=90&left_lon=-180&right_lon=180&ctr_lat=&ctr_lon=&radius=&max_dist_units=deg&searchshape=GLOBAL&srn=&grn=&start_year=${year}&start_month=09&start_day=01&start_time=00%3A00%3A00&end_year=${year}&end_month=12&end_day=31&end_time=23%3A59%3A59" > $1
    ;;
  esac

  # If curl returned a non-zero exit code or doesn't contain at least two lines, delete the file we just created
  if ! [ 0 -eq $? ]; then
    echo "File $1 had download error. Deleting."
    rm -f $1
    return 1
  elif [[ $(has_a_line $1) -eq 0 ]]; then
    echo "File $1 was empty. Deleting."
    rm -f $1
    return 1
  fi
  return 0
  # fsize=$(wc -c < $1)

  # # Currently the file size for no events is 160 bytes
  # if [[ -e $1 && $fsize -lt 2000 ]]; then
  #   echo "File $1 was too small to be valid. Deleting."
  #   rm -f $1
  # fi

}

# Change into the ISC data directory, creating if needed, and check Tiles directory
# Create tile files using touch

ISC_FOCALS_DIR="${1}"

if [[ -d $ISC_FOCALS_DIR ]]; then
  echo "ISC focals directory exists."
else
  echo "Creating IS focals directory: ${ISC_FOCALS_DIR}"
  mkdir -p ${ISC_FOCALS_DIR}
fi

cd $ISC_FOCALS_DIR

# Sort the isc_focals_complete.txt file to preserve the order of earliest->latest
if [[ -e isc_focals_complete.txt ]]; then
  sort < isc_focals_complete.txt -t '_' -n -k 3 -k 4 -k 5 > isc_focals_complete.txt.sort
  mv isc_focals_complete.txt.sort isc_focals_complete.txt
fi


if ! [[ $2 =~ "rebuild" ]]; then

  rm -f isc_focals_just_downloaded.txt

  # if [[ -e isc_focals_last_downloaded_event.txt ]]; then
  #   lastevent_epoch=$(tail -n 1 isc_last_downloaded_event.txt | gawk -F, '{ printf("%sT%s", $3, substr($4, 1, 8)) }' | iso8601_to_epoch)
  #   lastevent_date=$(tail -n 1 isc_last_downloaded_event.txt | gawk -F, '{ printf("%sT%s", $3, substr($4, 1, 8)) }')
  # else
  #   lastevent_epoch=$(echo "1900-01-01T00:00:01" | iso8601_to_epoch)
  #   lastevent_date="1900-01-01T00:00:01"
  # fi
  # echo "Last event from previous scrape has epoch $lastevent_epoch"
  # echo "Last event from previous scrape has date $lastevent_date"

  this_year=$(date -u +"%Y")
  this_month=$(date -u +"%m")
  this_day=$(date -u +"%d")
  this_hour=$(date -u +"%H")
  this_minute=$(date -u +"%M")
  this_second=$(date -u +"%S")

  # this_date=$(date -u "+%Y-%m-%dT%H:%M:%S")
  # this_time=$(date -u "%H:%M:%S")

  # new format for isc is isc_focals_year_segment.cat

  # Look for the last entry in the list of catalog files
  last_cat=($(tail -n 1 ./isc_focals_list.txt 2>/dev/null | gawk -F_ '{split($4, a, "."); print $3, a[1]}'))

  # If there is no last entry (no file), regenerate the list
  if [[ -z ${last_cat[0]} ]]; then
    echo "Generating new focal catalog file list..."
    for year in $(seq 1951 $this_year); do
        for segment in $(seq 1 3); do
          if [[ $(echo "($year == $this_year)" | bc) -eq 1 ]]; then
            [[ $(echo "($segment == 2) && ($this_month <= 4)"  | bc) -eq 1 ]] && break
            [[ $(echo "($segment == 3) && ($this_month <= 8)"  | bc) -eq 1 ]] && break
          fi
          echo "isc_focals_${year}_${segment}.cat" >> ./isc_focals_list.txt
        done
    done
  else
  # Otherwise, only add the events that postdate the last catalog file.
    echo "Adding new catalog files to file list..."
    last_year=${last_cat[0]}
    last_segment=${last_cat[1]}

    for year in $(seq $last_year $this_year); do
      for segment in $(seq 1 3); do
        # Determine when to exit the loop as we have gone into the future
        # echo "$year $segment $final"
        # If the year is the same as this current year, we might want to break
        if [[ $(echo "($year == $this_year)" | bc) -eq 1 ]]; then
           # If the segment indicates month 5+ but month <= 4, we don't need the segment; break
           [[ $(echo "($segment == 2) && ($this_month <= 4)"  | bc) -eq 1 ]] && break
           # If the segment indicates month 9+ but month <= 8, we don't need the segment; break
           [[ $(echo "($segment == 3) && ($this_month <= 8)"  | bc) -eq 1 ]] && break
        fi
        # If year is the same as the last year, we might want to break for a low segment number
        if [[ $(echo "($year == $last_year)" | bc) -eq 1 ]]; then
          if [[ $(echo "($segment > $last_segment)" | bc) -eq 0 ]]; then
            continue
          fi
        fi
        echo "isc_focals_${year}_${segment}.cat" >> isc_focals_list.txt

      done
    done
  fi

  # isc_focals_list now contains the list of all possible download files.
  touch isc_focals_complete.txt
  # Get a list of files that should exist but are not yet marked as complete
  cat isc_focals_complete.txt isc_focals_list.txt | sort -r -n -t "_" -k 3 -k 4 -k 5 | uniq -u > isc_focals_incomplete.txt

  isc_focals_list_files=($(tecto_tac isc_focals_incomplete.txt))

  # echo ${isc_focals_list_files[@]}

  testcount=0
  last_index=-1
  for d_file in ${isc_focals_list_files[@]}; do

    # If we download the focals file successfully, then
    if download_isc_focals_file ${d_file}; then

      echo "Downloaded ${d_file}"
      echo ${d_file} >> isc_focals_just_downloaded.txt
      if [[ $last_index -ge 0 ]]; then
        # Need to check whether the last file exists still before marking as complete (could have been deleted)
        echo "File ${d_file} downloaded succesfully. Marking earlier file ${isc_focals_list_files[$last_index]} as complete, if it exists."
        [[ -e ${isc_focals_list_files[$last_index]} ]] && echo ${isc_focals_list_files[$last_index]} >> isc_focals_complete.txt
      fi

    fi
    last_index=$(echo "$last_index + 1" | bc)
    testcount=$(echo "$testcount + 1" | bc)
  done
else
  # Rebuild the tile from the downloaded
  echo "Rebuilding ISC tiles no longer supported - remove manually and rescrape"
  # rm -f ${ISC_FOCALS_DIR}tile*.cat
  # cp isc_focals_complete.txt isc_focals_just_downloaded.txt
  # lastevent_epoch=$(echo "1900-01-01T00:00:01" | iso8601_to_epoch)
  # lastevent_date="1900-01-01T00:00:01"
  #
  # for long in $(seq -180 5 175); do
  #   for lati in $(seq -90 5 85); do
  #     touch ${ISC_FOCALS_DIR}"tile_${long}_${lati}.cat"
  #   done
  # done
fi

# If we downloaded a file (should always happen as newest file is never marked complete)

#   EVENTID,AUTHOR   ,DATE      ,TIME       ,LAT     ,LON      ,DEPTH,DEPFIX,AUTHOR   ,TYPE  ,MAG

if [[ -e isc_focals_just_downloaded.txt ]]; then

  last_added_event_date=$(tail -n 1 isc_extract.cat | gawk '{print $3}')
  echo "Date of last ISC focal mechanism in catalog is: ${last_added_event_date}"
  selected_files=$(cat isc_focals_just_downloaded.txt)

  # For each candidate file, examine events and see if they are younger than the
  # last event that has been added the catalog. Keep track of the youngest event.

  rm -f  to_clean.cat
  for foc_file in $selected_files; do
    echo "Processing newly downloaded file $foc_file into ISC CMT database"

    cat $foc_file | sed -n '/N_AZM/,/^STOP/p' | sed '1d;$d' | sed '$d' | \
                    grep -v "PNSN" | grep -v "EVBIB" | gawk -F, -v lastdate=${last_added_event_date} '
                    BEGIN {
                      count=0
                    }
                    {
                      thisdate=sprintf("%sT%s", $3, $4)
                      if (thisdate > lastdate) {
                        print
                        count++
                      }
                    }
                    END {
                      print "Added", count, "events to ISC focals catalog" > "/dev/stderr"
                    }'> isc.toadd
    # echo   ${CMTTOOLS} ${ISC_FOCALS_DIR}isc.toadd I I
    ${CMTTOOLS} isc.toadd I I >> isc_extract.cat
  done

  # Sanitize the focal mechanism database before concatenating to the main database file
  # The ISC catalog will have multiple entries for some events, some of which are origin
  # and some of which are centroid locations.

  # We also want to remove GCMT events in general as the official GCMT catalog has the
  # GCMT ID codes which the ISC database does not provide.

  # But do we want to keep non-GCMT events that are equivalent to GCMT?

  # gawk < ${ISC_FOCALS_DIR}"to_clean.cat" 'BEGIN{lastlastid="YYY"; lastid="XXX"; storage[1]=""; groupind=1; groupnum=1}
  # {
  #   newid=$2
  #
  #   if ($2!=lastid) {     # If we encounter a new ID code
  #     # print "Group", lastid, "--->"
  #     for (i=0; i<groupind; i++) {  # test the previous group for centroid=GCMT.
  #       if (NR != 1) {
  #         if (centroidauthorid[i]=="GCMT") {
  #           isgcmt=1
  #         }
  #         # print i, centroidauthorid[i]
  #
  #       }
  #     }
  #
  #     # Only print out the group if it has no GCMT member
  #     if (isgcmt==0) {
  #
  #       # Now we need to prioritize the solutions so we can print a single solution
  #       has_cmt=0
  #       has_origin=0
  #       for (i=0; i<groupind; i++) {
  #         split(storage[i], tmplist, " ")
  #         if (tmplist[11]!="none") { has_cmt=1; cmttmp=storage[i] }
  #         if (tmplist[10]!="none") { has_origin=1; origintmp=storage[i] }
  #       }
  #       if (NR != 1) {
  #         if (has_origin==1 && has_cmt==1) {
  #           split(cmttmp, cmtlist, " ")
  #           split(origintmp, originlist, " ")
  #           cmtlist[8]=originlist[8]
  #           cmtlist[9]=originlist[9]
  #           cmtlist[10]=originlist[10]
  #           cmtlist[12]=originlist[12]
  #           for (j=1; j<=NF; j++) {
  #             printf "%s ", cmtlist[j]
  #           }
  #           printf("\n")
  #         }
  #         if (has_origin==1 && has_cmt==0) {
  #           print origintmp
  #         }
  #         if (has_cmt==1 && has_origin==0) {
  #           print cmttmp
  #         }
  #       }
  #     } else {
  #       # GCMT events
  #
  #     }
  #
  #     groupnum=groupnum+1
  #     # print "End group", lastid, "<-----"
  #     # the new group starts with an index of 0 which will pre-increment to 1
  #     storage[0]=$0
  #     centroidauthorid[0]=$11
  #     if ($11=="GCMT") {
  #       isgcmt=1
  #     } else {
  #       isgcmt=0
  #     }
  #     groupind=1
  #   }
  #
  #   if ($2==lastid) {   # if the current ID is the same as the lastid, add to the new group
  #     storage[groupind]=$0
  #     centroidauthorid[groupind]=$11
  #     groupind=groupind+1
  #   }
  #   lastlastid=lastid
  #   lastid=$2
  # }' > ${ISC_FOCALS_DIR}"isc_clean.cat"
  #
  # # Replace "GCMT" events from
  # sed -i '' 's/GCMT     /G_CMTpre  /g' ${ISC_FOCALS_DIR}"isc_clean.cat"

  # wc -l < ${ISC_FOCALS_DIR}"isc_clean.cat"
  # cat to_clean.cat >> isc_extract.cat

  # not_tiled.cat is a file containing old events that have alread been tiled
  # It is kept for inspection purposes but is deleted with each scrape
  #
  # last_downloaded_file=$(tail -n 1 isc_focals_just_downloaded.txt)
  # last_downloaded_event=$(cat $last_downloaded_file | sed -n '/^  EVENTID/,/^STOP/p' | sed '1d;$d' | sed '$d' | tail -n 1)
  #
  # # Check whether the latest event exists, and if so mark it
  # if [[ ! -z ${last_downloaded_event} ]]; then
  #   echo "Marking last downloaded event: $last_downloaded_event"
  #   echo $last_downloaded_event > isc_last_downloaded_event.txt
  #   # Update last_downloaded_event.txt
  # fi
fi

rm -f isc_focals_*.cat not_tiled.cat cmt_tools_rejected.dat isc.toadd
rm -f isc_focals_incomplete.txt isc_focals_just_downloaded.txt

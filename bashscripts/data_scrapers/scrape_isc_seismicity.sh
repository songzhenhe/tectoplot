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

function download_by_code {
  # 214 2021 10 05 05 16 47 2022 02 12 08 36 35
  OUTFILE="isc_events_${1}.cat"
  echo "Dowloading seismicity for catalog file number {1}"
  echo curl "${ISC_MIRROR}/cgi-bin/web-db-v4?request=COMPREHENSIVE&out_format=CATCSV&searchshape=RECT&bot_lat=-90&top_lat=90&left_lon=-180&right_lon=180&ctr_lat=&ctr_lon=&radius=&max_dist_units=deg&srn=&grn=&start_year=${2}&start_month=${3}&start_day=${4}&start_time=${5}%3A${6}%3A${7}&end_year=${8}&end_month=${9}&end_day=${10}&end_time=${11}%3A${12}%3A${13}&min_dep=&max_dep=&min_mag=&max_mag=&req_mag_type=Any&req_mag_agcy=prime" \| sed -n '/^  EVENTID/,/^STOP/p' \| sed '1d;$d' \| sed '$d' \> $OUTFILE
  curl "${ISC_MIRROR}/cgi-bin/web-db-v4?request=COMPREHENSIVE&out_format=CATCSV&searchshape=RECT&bot_lat=-90&top_lat=90&left_lon=-180&right_lon=180&ctr_lat=&ctr_lon=&radius=&max_dist_units=deg&srn=&grn=&start_year=${2}&start_month=${3}&start_day=${4}&start_time=${5}%3A${6}%3A${7}&end_year=${8}&end_month=${9}&end_day=${10}&end_time=${11}%3A${12}%3A${13}&min_dep=&max_dep=&min_mag=&max_mag=&req_mag_type=Any&req_mag_agcy=prime" | sed -n '/^  EVENTID/,/^STOP/p' | sed '1d;$d' | sed '$d' > $OUTFILE
}

# Change into the ISC data directory, creating if needed, and check Tiles directory
# Create tile files using touch

function download_isc_catalogs {


if [[ -e isc_catalogs_completed.txt ]]; then
  return
fi

TILEDIR=${1}

if [[ ! -d ${TILEDIR} ]]; then
  echo "download_isc_catalogs: no tile directory ${TILEDIR}"
  return
fi

# Create the list of 39000 event catalog files
# 1 1900 01 01 00 00 00 1968 06 18 07 38 15
# 2 1968 06 18 07 38 15 1973 05 25 16 28 58
# 3 1973 05 25 16 28 58 1978 04 22 13 30 51
# 4 1978 04 22 13 30 51 1981 07 24 16 37 29
# 5 1981 07 24 16 37 29 1984 05 14 10 00 35
# 6 1984 05 14 10 00 35 1986 06 18 14 10 47
# 7 1986 06 18 14 10 47 1988 06 30 15 15 50
# 8 1988 06 30 15 15 50 1990 02 01 05 18 53
# 9 1990 02 01 05 18 53 1991 06 20 21 15 08
# 10 1991 06 20 21 15 08 1992 07 11 17 21 58
# 11 1992 07 11 17 21 58 1993 04 30 20 04 29
# 12 1993 04 30 20 04 29 1993 12 16 01 30 38
# 13 1993 12 16 01 30 38 1994 08 08 10 07 12
# 14 1994 08 08 10 07 12 1995 02 09 21 24 35
# 15 1995 02 09 21 24 35 1995 09 05 07 44 01
# 16 1995 09 05 07 44 01 1996 02 02 07 02 26
# 17 1996 02 02 07 02 26 1996 08 09 09 40 27
# 18 1996 08 09 09 40 27 1997 03 01 11 37 58
# 19 1997 03 01 11 37 58 1997 09 27 08 59 14
# 20 1997 09 27 08 59 14 1998 04 07 23 37 08
# 21 1998 04 07 23 37 08 1998 10 07 21 02 17
# 22 1998 10 07 21 02 17 1999 03 10 09 51 04
# 23 1999 03 10 09 51 04 1999 06 27 06 30 40
# 24 1999 06 27 06 30 40 1999 09 23 06 08 39
# 25 1999 09 23 06 08 39 1999 11 02 03 57 59
# 26 1999 11 02 03 57 59 2000 01 24 23 47 13
# 27 2000 01 24 23 47 13 2000 05 04 23 14 45
# 28 2000 05 04 23 14 45 2000 07 15 21 09 01
# 29 2000 07 15 21 09 01 2000 10 04 17 24 01
# 30 2000 10 04 17 24 01 2000 12 19 06 42 44
# 31 2000 12 19 06 42 44 2001 03 11 23 17 59
# 32 2001 03 11 23 17 59 2001 06 05 20 54 57
# 33 2001 06 05 20 54 57 2001 08 24 08 02 38
# 34 2001 08 24 08 02 38 2001 11 15 02 26 48
# 35 2001 11 15 02 26 48 2002 01 30 11 37 23
# 36 2002 01 30 11 37 23 2002 04 10 22 57 09
# 37 2002 04 10 22 57 09 2002 06 12 23 38 26
# 38 2002 06 12 23 38 26 2002 08 20 15 58 36
# 39 2002 08 20 15 58 36 2002 10 22 06 38 48
# 40 2002 10 22 06 38 48 2002 12 29 19 43 45
# 41 2002 12 29 19 43 45 2003 03 13 12 07 19
# 42 2003 03 13 12 07 19 2003 05 23 19 20 04
# 43 2003 05 23 19 20 04 2003 07 12 15 13 27
# 44 2003 07 12 15 13 27 2003 09 09 00 54 47
# 45 2003 09 09 00 54 47 2003 11 08 23 51 35
# 46 2003 11 08 23 51 35 2004 01 05 18 05 28
# 47 2004 01 05 18 05 28 2004 03 13 08 21 54
# 48 2004 03 13 08 21 54 2004 05 14 21 14 30
# 49 2004 05 14 21 14 30 2004 07 16 20 33 52
# 50 2004 07 16 20 33 52 2004 09 18 21 47 18
# 51 2004 09 18 21 47 18 2004 11 19 03 25 10
# 52 2004 11 19 03 25 10 2005 01 12 21 20 51
# 53 2005 01 12 21 20 51 2005 03 14 12 28 31
# 54 2005 03 14 12 28 31 2005 05 02 00 07 02
# 55 2005 05 02 00 07 02 2005 06 23 22 41 17
# 56 2005 06 23 22 41 17 2005 08 19 17 11 44
# 57 2005 08 19 17 11 44 2005 10 16 14 37 32
# 58 2005 10 16 14 37 32 2005 12 18 03 40 45
# 59 2005 12 18 03 40 45 2006 02 22 03 34 03
# 60 2006 02 22 03 34 03 2006 04 21 17 05 59
# 61 2006 04 21 17 05 59 2006 06 16 23 46 36
# 62 2006 06 16 23 46 36 2006 08 20 16 59 03
# 63 2006 08 20 16 59 03 2006 10 27 10 58 15
# 64 2006 10 27 10 58 15 2006 12 30 17 44 46
# 65 2006 12 30 17 44 46 2007 03 03 13 17 05
# 66 2007 03 03 13 17 05 2007 04 25 09 04 31
# 67 2007 04 25 09 04 31 2007 06 21 10 00 35
# 68 2007 06 21 10 00 35 2007 08 15 07 15 53
# 69 2007 08 15 07 15 53 2007 10 12 20 47 14
# 70 2007 10 12 20 47 14 2007 12 14 22 05 38
# 71 2007 12 14 22 05 38 2008 02 11 20 18 54
# 72 2008 02 11 20 18 54 2008 04 09 11 23 45
# 73 2008 04 09 11 23 45 2008 05 26 03 33 31
# 74 2008 05 26 03 33 31 2008 07 03 08 47 08
# 75 2008 07 03 08 47 08 2008 08 16 08 48 56
# 76 2008 08 16 08 48 56 2008 10 02 06 34 28
# 77 2008 10 02 06 34 28 2008 11 11 09 21 48
# 78 2008 11 11 09 21 48 2008 12 28 06 32 39
# 79 2008 12 28 06 32 39 2009 02 11 13 40 29
# 80 2009 02 11 13 40 29 2009 03 30 23 21 45
# 81 2009 03 30 23 21 45 2009 05 06 22 04 38
# 82 2009 05 06 22 04 38 2009 06 17 09 16 56
# 83 2009 06 17 09 16 56 2009 07 26 05 31 52
# 84 2009 07 26 05 31 52 2009 09 03 20 36 56
# 85 2009 09 03 20 36 56 2009 10 15 16 08 40
# 86 2009 10 15 16 08 40 2009 12 03 09 16 57
# 87 2009 12 03 09 16 57 2010 01 14 16 24 37
# 88 2010 01 14 16 24 37 2010 02 28 23 35 12
# 89 2010 02 28 23 35 12 2010 04 10 07 20 51
# 90 2010 04 10 07 20 51 2010 05 20 21 11 03
# 91 2010 05 20 21 11 03 2010 07 01 12 05 22
# 92 2010 07 01 12 05 22 2010 08 09 04 46 51
# 93 2010 08 09 04 46 51 2010 09 16 06 37 02
# 94 2010 09 16 06 37 02 2010 10 24 11 19 15
# 95 2010 10 24 11 19 15 2010 12 05 19 09 26
# 96 2010 12 05 19 09 26 2011 01 18 20 57 37
# 97 2011 01 18 20 57 37 2011 03 01 04 08 58
# 98 2011 03 01 04 08 58 2011 03 23 10 37 34
# 99 2011 03 23 10 37 34 2011 04 16 08 22 56
# 100 2011 04 16 08 22 56 2011 05 15 18 11 06
# 101 2011 05 15 18 11 06 2011 06 12 20 26 10
# 102 2011 06 12 20 26 10 2011 07 13 10 52 47
# 103 2011 07 13 10 52 47 2011 08 14 22 23 02
# 104 2011 08 14 22 23 02 2011 09 17 14 13 30
# 105 2011 09 17 14 13 30 2011 10 20 20 18 54
# 106 2011 10 20 20 18 54 2011 11 20 15 00 38
# 107 2011 11 20 15 00 38 2011 12 23 06 58 16
# 108 2011 12 23 06 58 16 2012 01 26 13 29 07
# 109 2012 01 26 13 29 07 2012 02 29 15 32 39
# 110 2012 02 29 15 32 39 2012 04 02 17 33 09
# 111 2012 04 02 17 33 09 2012 05 06 08 24 47
# 112 2012 05 06 08 24 47 2012 06 08 18 21 02
# 113 2012 06 08 18 21 02 2012 07 12 08 51 23
# 114 2012 07 12 08 51 23 2012 08 19 04 56 04
# 115 2012 08 19 04 56 04 2012 09 24 17 31 12
# 116 2012 09 24 17 31 12 2012 11 01 11 18 15
# 117 2012 11 01 11 18 15 2012 12 13 01 44 28
# 118 2012 12 13 01 44 28 2013 01 23 08 39 55
# 119 2013 01 23 08 39 55 2013 02 28 00 13 01
# 120 2013 02 28 00 13 01 2013 04 04 20 34 23
# 121 2013 04 04 20 34 23 2013 05 09 15 05 18
# 122 2013 05 09 15 05 18 2013 06 13 23 44 10
# 123 2013 06 13 23 44 10 2013 07 18 18 18 15
# 124 2013 07 18 18 18 15 2013 08 24 05 57 11
# 125 2013 08 24 05 57 11 2013 10 01 14 07 03
# 126 2013 10 01 14 07 03 2013 11 09 07 14 52
# 127 2013 11 09 07 14 52 2013 12 20 02 25 18
# 128 2013 12 20 02 25 18 2014 01 25 15 34 45
# 129 2014 01 25 15 34 45 2014 03 02 08 37 22
# 130 2014 03 02 08 37 22 2014 04 06 10 47 34
# 131 2014 04 06 10 47 34 2014 05 09 23 35 53
# 132 2014 05 09 23 35 53 2014 06 12 03 16 38
# 133 2014 06 12 03 16 38 2014 07 19 04 51 15
# 134 2014 07 19 04 51 15 2014 08 24 10 43 33
# 135 2014 08 24 10 43 33 2014 09 29 23 40 46
# 136 2014 09 29 23 40 46 2014 11 09 18 38 23
# 137 2014 11 09 18 38 23 2014 12 14 19 17 32
# 138 2014 12 14 19 17 32 2015 01 23 19 17 50
# 139 2015 01 23 19 17 50 2015 03 05 23 36 27
# 140 2015 03 05 23 36 27 2015 04 14 20 14 07
# 141 2015 04 14 20 14 07 2015 05 21 00 38 13
# 142 2015 05 21 00 38 13 2015 06 29 17 23 52
# 143 2015 06 29 17 23 52 2015 08 07 18 19 11
# 144 2015 08 07 18 19 11 2015 09 16 08 08 48
# 145 2015 09 16 08 08 48 2015 10 22 03 31 06
# 146 2015 10 22 03 31 06 2015 11 29 14 55 16
# 147 2015 11 29 14 55 16 2016 01 09 08 57 50
# 148 2016 01 09 08 57 50 2016 02 17 04 06 03
# 149 2016 02 17 04 06 03 2016 03 25 20 48 38
# 150 2016 03 25 20 48 38 2016 04 28 16 50 57
# 151 2016 04 28 16 50 57 2016 05 27 16 56 28
# 152 2016 05 27 16 56 28 2016 06 27 03 42 47
# 153 2016 06 27 03 42 47 2016 07 27 15 02 23
# 154 2016 07 27 15 02 23 2016 08 23 22 50 53
# 155 2016 08 23 22 50 53 2016 09 14 11 07 51
# 156 2016 09 14 11 07 51 2016 10 09 02 52 36
# 157 2016 10 09 02 52 36 2016 10 28 23 00 01
# 158 2016 10 28 23 00 01 2016 11 16 21 11 07
# 159 2016 11 16 21 11 07 2016 12 03 06 37 09
# 160 2016 12 03 06 37 09 2016 12 22 19 45 15
# 161 2016 12 22 19 45 15 2017 01 11 11 33 19
# 162 2017 01 11 11 33 19 2017 02 03 06 54 40
# 163 2017 02 03 06 54 40 2017 02 26 09 09 13
# 164 2017 02 26 09 09 13 2017 03 22 17 11 31
# 165 2017 03 22 17 11 31 2017 04 16 18 44 19
# 166 2017 04 16 18 44 19 2017 05 10 17 24 06
# 167 2017 05 10 17 24 06 2017 06 04 22 28 36
# 168 2017 06 04 22 28 36 2017 06 29 04 45 03
# 169 2017 06 29 04 45 03 2017 07 20 17 22 33
# 170 2017 07 20 17 22 33 2017 08 11 04 51 18
# 171 2017 08 11 04 51 18 2017 09 03 23 27 22
# 172 2017 09 03 23 27 22 2017 09 30 20 45 14
# 173 2017 09 30 20 45 14 2017 10 29 05 21 04
# 174 2017 10 29 05 21 04 2017 11 24 16 39 22
# 175 2017 11 24 16 39 22 2017 12 23 17 42 58
# 176 2017 12 23 17 42 58 2018 01 22 05 00 50
# 177 2018 01 22 05 00 50 2018 02 14 12 46 48
# 178 2018 02 14 12 46 48 2018 03 13 02 12 11
# 179 2018 03 13 02 12 11 2018 04 09 16 19 29
# 180 2018 04 09 16 19 29 2018 05 05 18 01 40
# 181 2018 05 05 18 01 40 2018 05 31 14 30 08
# 182 2018 05 31 14 30 08 2018 06 28 12 58 43
# 183 2018 06 28 12 58 43 2018 07 26 10 52 33
# 184 2018 07 26 10 52 33 2018 08 22 02 23 40
# 185 2018 08 22 02 23 40 2018 09 17 10 37 34
# 186 2018 09 17 10 37 34 2018 10 15 06 32 07
# 187 2018 10 15 06 32 07 2018 11 12 05 12 26
# 188 2018 11 12 05 12 26 2018 12 07 18 41 38
# 189 2018 12 07 18 41 38 2019 01 05 20 36 20
# 190 2019 01 05 20 36 20 2019 02 03 08 57 04
# 191 2019 02 03 08 57 04 2019 03 03 02 22 47
# 192 2019 03 03 02 22 47 2019 04 01 00 48 47
# 193 2019 04 01 00 48 47 2019 04 28 11 09 36
# 194 2019 04 28 11 09 36 2019 05 28 07 10 53
# 195 2019 05 28 07 10 53 2019 06 25 09 33 46
# 196 2019 06 25 09 33 46 2019 07 24 23 14 20
# 197 2019 07 24 23 14 20 2019 08 24 21 11 28
# 198 2019 08 24 21 11 28 2019 09 25 22 52 38
# 199 2019 09 25 22 52 38 2019 10 27 03 56 58
# 200 2019 10 27 03 56 58 2019 11 28 18 53 23
# 201 2019 11 28 18 53 23 2019 12 28 12 50 17
# 202 2019 12 28 12 50 17 2020 01 24 19 04 37
# 203 2020 01 24 19 04 37 2020 02 18 08 00 12
# 204 2020 02 18 08 00 12 2020 03 16 02 58 09
# 205 2020 03 16 02 58 09 2020 04 14 09 41 46
# 206 2020 04 14 09 41 46 2020 05 15 01 05 47
# 207 2020 05 15 01 05 47 2020 06 16 02 13 58
# 208 2020 06 15 01 05 47 2020 07 16 02 13 58
# 209 2020 07 16 02 13 58 2020 09 09 03 49 43
# 210 2020 09 09 03 49 43 2020 10 31 23 28 01
# 211 2020 10 31 23 28 01 2020 12 20 19 42 06
# 212 2020 12 20 19 42 06 2021 03 04 22 32 00
# 213 2021 03 04 22 32 00 2021 06 08 08 19 43
# 214 2021 06 08 08 19 43 2021 10 05 05 16 47
# 215 2021 10 05 05 16 47 2022 02 12 08 36 35

cat<<-EOF > isc_program.txt
1 1900 01 01 00 00 00 1968 06 18 07 38 15
2 1968 06 18 07 38 15 1973 05 25 13 17 24
3 1973 05 25 13 17 24 1978 04 22 12 18 21
4 1978 04 22 12 18 21 1981 07 24 12 23 00
5 1981 07 24 12 23 00 1984 05 14 05 37 19
6 1984 05 14 05 37 19 1986 06 18 07 10 12
7 1986 06 18 07 10 12 1988 06 30 07 00 54
8 1988 06 30 07 00 54 1990 02 01 01 03 57
9 1990 02 01 01 03 57 1991 06 20 15 39 14
10 1991 06 20 15 39 14 1992 07 11 13 41 44
11 1992 07 11 13 41 44 1993 04 30 16 04 24
12 1993 04 30 16 04 24 1993 12 16 00 21 44
13 1993 12 16 00 21 44 1994 08 08 04 58 34
14 1994 08 08 04 58 34 1995 02 09 19 14 12
15 1995 02 09 19 14 12 1995 09 05 02 43 14
16 1995 09 05 02 43 14 1996 02 02 02 50 35
17 1996 02 02 02 50 35 1996 08 09 04 57 19
18 1996 08 09 04 57 19 1997 03 01 08 30 25
19 1997 03 01 08 30 25 1997 09 27 06 19 32
20 1997 09 27 06 19 32 1998 04 07 19 11 36
21 1998 04 07 19 11 36 1998 10 07 16 58 02
22 1998 10 07 16 58 02 1999 03 10 07 45 42
23 1999 03 10 07 45 42 1999 06 27 02 37 02
24 1999 06 27 02 37 02 1999 09 23 05 36 22
25 1999 09 23 05 36 22 1999 11 02 00 40 31
26 1999 11 02 00 40 31 2000 01 24 20 15 34
27 2000 01 24 20 15 34 2000 05 04 20 56 04
28 2000 05 04 20 56 04 2000 07 15 18 46 55
29 2000 07 15 18 46 55 2000 10 04 15 01 49
30 2000 10 04 15 01 49 2000 12 19 03 59 36
31 2000 12 19 03 59 36 2001 03 11 20 15 14
32 2001 03 11 20 15 14 2001 06 05 17 55 46
33 2001 06 05 17 55 46 2001 08 24 03 53 05
34 2001 08 24 03 53 05 2001 11 14 22 31 55
35 2001 11 14 22 31 55 2002 01 30 08 12 55
36 2002 01 30 08 12 55 2002 04 10 20 28 53
37 2002 04 10 20 28 53 2002 06 12 20 53 39
38 2002 06 12 20 53 39 2002 08 20 13 19 05
39 2002 08 20 13 19 05 2002 10 22 03 25 56
40 2002 10 22 03 25 56 2002 12 29 16 51 01
41 2002 12 29 16 51 01 2003 03 13 07 54 41
42 2003 03 13 07 54 41 2003 05 23 15 19 12
43 2003 05 23 15 19 12 2003 07 12 12 08 43
44 2003 07 12 12 08 43 2003 09 08 20 34 00
45 2003 09 08 20 34 00 2003 11 08 19 47 16
46 2003 11 08 19 47 16 2004 01 05 15 43 45
47 2004 01 05 15 43 45 2004 03 13 04 26 29
48 2004 03 13 04 26 29 2004 05 14 16 57 28
49 2004 05 14 16 57 28 2004 07 16 17 13 08
50 2004 07 16 17 13 08 2004 09 18 19 06 02
51 2004 09 18 19 06 02 2004 11 18 22 43 12
52 2004 11 18 22 43 12 2005 01 12 17 58 20
53 2005 01 12 17 58 20 2005 03 14 09 34 00
54 2005 03 14 09 34 00 2005 05 01 21 05 37
55 2005 05 01 21 05 37 2005 06 23 18 49 40
56 2005 06 23 18 49 40 2005 08 19 13 32 24
57 2005 08 19 13 32 24 2005 10 16 10 23 54
58 2005 10 16 10 23 54 2005 12 17 20 59 28
59 2005 12 17 20 59 28 2006 02 21 22 42 10
60 2006 02 21 22 42 10 2006 04 21 15 12 20
61 2006 04 21 15 12 20 2006 06 16 19 41 19
62 2006 06 16 19 41 19 2006 08 20 12 05 10
63 2006 08 20 12 05 10 2006 10 27 06 28 17
64 2006 10 27 06 28 17 2006 12 30 13 34 35
65 2006 12 30 13 34 35 2007 03 03 08 28 13
66 2007 03 03 08 28 13 2007 04 25 04 22 29
67 2007 04 25 04 22 29 2007 06 21 03 42 23
68 2007 06 21 03 42 23 2007 08 15 01 53 24
69 2007 08 15 01 53 24 2007 10 12 15 12 30
70 2007 10 12 15 12 30 2007 12 14 15 50 51
71 2007 12 14 15 50 51 2008 02 11 14 47 09
72 2008 02 11 14 47 09 2008 04 09 06 55 18
73 2008 04 09 06 55 18 2008 05 25 22 50 22
74 2008 05 25 22 50 22 2008 07 03 04 21 39
75 2008 07 03 04 21 39 2008 08 16 04 22 02
76 2008 08 16 04 22 02 2008 10 02 03 53 46
77 2008 10 02 03 53 46 2008 11 11 04 17 56
78 2008 11 11 04 17 56 2008 12 28 02 41 27
79 2008 12 28 02 41 27 2009 02 11 10 49 53
80 2009 02 11 10 49 53 2009 03 30 18 50 07
81 2009 03 30 18 50 07 2009 05 06 17 40 47
82 2009 05 06 17 40 47 2009 06 17 04 22 31
83 2009 06 17 04 22 31 2009 07 26 00 33 10
84 2009 07 26 00 33 10 2009 09 03 15 55 48
85 2009 09 03 15 55 48 2009 10 15 12 28 17
86 2009 10 15 12 28 17 2009 12 03 02 38 35
87 2009 12 03 02 38 35 2010 01 14 12 10 36
88 2010 01 14 12 10 36 2010 02 28 19 27 05
89 2010 02 28 19 27 05 2010 04 10 02 42 52
90 2010 04 10 02 42 52 2010 05 20 17 00 08
91 2010 05 20 17 00 08 2010 07 01 07 59 22
92 2010 07 01 07 59 22 2010 08 08 23 00 03
93 2010 08 08 23 00 03 2010 09 16 02 45 08
94 2010 09 16 02 45 08 2010 10 24 06 54 45
95 2010 10 24 06 54 45 2010 12 05 14 43 36
96 2010 12 05 14 43 36 2011 01 18 15 52 26
97 2011 01 18 15 52 26 2011 02 28 22 06 09
98 2011 02 28 22 06 09 2011 03 23 08 27 42
99 2011 03 23 08 27 42 2011 04 16 04 11 26
100 2011 04 16 04 11 26 2011 05 15 14 49 46
101 2011 05 15 14 49 46 2011 06 12 18 09 25
102 2011 06 12 18 09 25 2011 07 13 07 09 38
103 2011 07 13 07 09 38 2011 08 14 18 13 31
104 2011 08 14 18 13 31 2011 09 17 10 25 16
105 2011 09 17 10 25 16 2011 10 20 16 13 26
106 2011 10 20 16 13 26 2011 11 20 11 38 15
107 2011 11 20 11 38 15 2011 12 23 03 23 45
108 2011 12 23 03 23 45 2012 01 26 10 21 44
109 2012 01 26 10 21 44 2012 02 29 11 30 10
110 2012 02 29 11 30 10 2012 04 02 13 44 40
111 2012 04 02 13 44 40 2012 05 06 03 52 32
112 2012 05 06 03 52 32 2012 06 08 13 36 04
113 2012 06 08 13 36 04 2012 07 12 03 30 36
114 2012 07 12 03 30 36 2012 08 18 23 54 22
115 2012 08 18 23 54 22 2012 09 24 12 02 34
116 2012 09 24 12 02 34 2012 11 01 05 05 16
117 2012 11 01 05 05 16 2012 12 12 19 04 17
118 2012 12 12 19 04 17 2013 01 23 01 20 40
119 2013 01 23 01 20 40 2013 02 27 19 06 25
120 2013 02 27 19 06 25 2013 04 04 15 29 02
121 2013 04 04 15 29 02 2013 05 09 09 57 16
122 2013 05 09 09 57 16 2013 06 13 19 05 58
123 2013 06 13 19 05 58 2013 07 18 13 15 45
124 2013 07 18 13 15 45 2013 08 23 23 24 54
125 2013 08 23 23 24 54 2013 10 01 08 13 16
126 2013 10 01 08 13 16 2013 11 09 00 39 56
127 2013 11 09 00 39 56 2013 12 19 18 51 14
128 2013 12 19 18 51 14 2014 01 25 09 48 34
129 2014 01 25 09 48 34 2014 03 02 02 41 00
130 2014 03 02 02 41 00 2014 04 06 04 10 55
131 2014 04 06 04 10 55 2014 05 09 17 18 40
132 2014 05 09 17 18 40 2014 06 11 21 03 59
133 2014 06 11 21 03 59 2014 07 18 22 26 01
134 2014 07 18 22 26 01 2014 08 24 04 56 08
135 2014 08 24 04 56 08 2014 09 29 17 26 40
136 2014 09 29 17 26 40 2014 11 09 12 36 55
137 2014 11 09 12 36 55 2014 12 14 14 22 32
138 2014 12 14 14 22 32 2015 01 23 13 55 02
139 2015 01 23 13 55 02 2015 03 05 16 14 22
140 2015 03 05 16 14 22 2015 04 14 13 54 06
141 2015 04 14 13 54 06 2015 05 20 16 43 02
142 2015 05 20 16 43 02 2015 06 29 12 01 17
143 2015 06 29 12 01 17 2015 08 07 11 40 49
144 2015 08 07 11 40 49 2015 09 16 02 59 27
145 2015 09 16 02 59 27 2015 10 21 21 02 43
146 2015 10 21 21 02 43 2015 11 29 08 56 32
147 2015 11 29 08 56 32 2016 01 08 23 51 59
148 2016 01 08 23 51 59 2016 02 16 21 10 25
149 2016 02 16 21 10 25 2016 03 25 14 19 19
150 2016 03 25 14 19 19 2016 04 28 11 31 14
151 2016 04 28 11 31 14 2016 05 27 11 56 44
152 2016 05 27 11 56 44 2016 06 26 22 33 05
153 2016 06 26 22 33 05 2016 07 27 10 41 35
154 2016 07 27 10 41 35 2016 08 23 17 39 32
155 2016 08 23 17 39 32 2016 09 14 07 55 52
156 2016 09 14 07 55 52 2016 10 08 22 27 29
157 2016 10 08 22 27 29 2016 10 28 19 19 27
158 2016 10 28 19 19 27 2016 11 16 18 24 35
159 2016 11 16 18 24 35 2016 12 03 03 09 48
160 2016 12 03 03 09 48 2016 12 22 15 10 33
161 2016 12 22 15 10 33 2017 01 11 07 16 28
162 2017 01 11 07 16 28 2017 02 03 01 44 42
163 2017 02 03 01 44 42 2017 02 26 03 48 36
164 2017 02 26 03 48 36 2017 03 22 12 21 12
165 2017 03 22 12 21 12 2017 04 16 15 01 25
166 2017 04 16 15 01 25 2017 05 10 12 47 58
167 2017 05 10 12 47 58 2017 06 04 17 26 43
168 2017 06 04 17 26 43 2017 06 28 23 41 00
169 2017 06 28 23 41 00 2017 07 20 12 59 46
170 2017 07 20 12 59 46 2017 08 11 00 03 18
171 2017 08 11 00 03 18 2017 09 03 17 36 57
172 2017 09 03 17 36 57 2017 09 30 15 06 11
173 2017 09 30 15 06 11 2017 10 28 21 29 52
174 2017 10 28 21 29 52 2017 11 24 11 22 36
175 2017 11 24 11 22 36 2017 12 23 12 02 31
176 2017 12 23 12 02 31 2018 01 21 20 56 05
177 2018 01 21 20 56 05 2018 02 14 08 19 29
178 2018 02 14 08 19 29 2018 03 12 18 51 19
179 2018 03 12 18 51 19 2018 04 09 11 36 35
180 2018 04 09 11 36 35 2018 05 05 12 07 21
181 2018 05 05 12 07 21 2018 05 31 08 48 54
182 2018 05 31 08 48 54 2018 06 28 07 52 25
183 2018 06 28 07 52 25 2018 07 26 05 32 21
184 2018 07 26 05 32 21 2018 08 21 19 33 59
185 2018 08 21 19 33 59 2018 09 17 04 39 47
186 2018 09 17 04 39 47 2018 10 14 23 49 29
187 2018 10 14 23 49 29 2018 11 11 22 59 21
188 2018 11 11 22 59 21 2018 12 07 12 06 46
189 2018 12 07 12 06 46 2019 01 05 15 04 23
190 2019 01 05 15 04 23 2019 02 03 02 28 58
191 2019 02 03 02 28 58 2019 03 02 18 54 56
192 2019 03 02 18 54 56 2019 03 31 19 10 34
193 2019 03 31 19 10 34 2019 04 28 03 31 35
194 2019 04 28 03 31 35 2019 05 27 23 33 43
195 2019 05 27 23 33 43 2019 06 25 03 00 01
196 2019 06 25 03 00 01 2019 07 24 16 23 18
197 2019 07 24 16 23 18 2019 08 24 12 38 02
198 2019 08 24 12 38 02 2019 09 25 15 32 30
199 2019 09 25 15 32 30 2019 10 27 00 02 29
200 2019 10 27 00 02 29 2019 11 28 15 11 36
201 2019 11 28 15 11 36 2019 12 28 09 16 12
202 2019 12 28 09 16 12 2020 01 24 16 00 44
203 2020 01 24 16 00 44 2020 02 18 04 31 15
204 2020 02 18 04 31 15 2020 03 15 22 48 10
205 2020 03 15 22 48 10 2020 04 14 06 07 07
206 2020 04 14 06 07 07 2020 05 14 17 49 49
207 2020 05 14 17 49 49 2020 07 01 14 05 27
208 2020 07 01 14 05 27 2020 08 25 19 26 53
209 2020 08 25 19 26 53 2020 10 20 01 03 33
210 2020 10 20 01 03 33 2020 12 06 16 57 33
211 2020 12 06 16 57 33 2021 02 09 11 20 06
212 2021 02 09 11 20 06 2021 05 09 13 04 12
213 2021 05 09 13 04 12 2021 09 01 11 16 09
214 2021 09 01 11 16 09 2022 01 26 16 57 03
215 2022 01 26 16 57 03 2022 02 12 15 13 19
EOF

# Test whether we have recorded that all catalogs are completed
  added_catalog=0
  while read this_cat; do
    catargs=($(echo $this_cat))
    echo "Looking at catargs: ${catargs[@]}"
    OUTFILE="isc_catalog_${catargs[0]}.cat"

    if [[ ! -s "isc_catalog_${catargs[0]}.cat" ]]; then
      added_catalog=1
      keep_going=1
      while [[ $keep_going -eq 1 ]]; do
        # download_by_code ${catargs[@]}
        echo "Dowloading seismicity for catalog file number ${catargs[0]}"
        echo curl "${ISC_MIRROR}/cgi-bin/web-db-v4?request=COMPREHENSIVE&out_format=CATCSV&searchshape=RECT&bot_lat=-90&top_lat=90&left_lon=-180&right_lon=180&ctr_lat=&ctr_lon=&radius=&max_dist_units=deg&srn=&grn=&start_year=${catargs[1]}&start_month=${catargs[2]}&start_day=${catargs[3]}&start_time=${catargs[4]}%3A${catargs[5]}%3A${catargs[6]}&end_year=${catargs[7]}&end_month=${catargs[8]}&end_day=${catargs[9]}&end_time=${catargs[10]}%3A${catargs[11]}%3A${catargs[12]}&min_dep=&max_dep=&min_mag=&max_mag=&req_mag_type=Any&req_mag_agcy=prime" \| sed -n '/^  EVENTID/,/^STOP/p' \| sed '1d;$d' \| sed '$d' \> $OUTFILE
        curl "${ISC_MIRROR}/cgi-bin/web-db-v4?request=COMPREHENSIVE&out_format=CATCSV&searchshape=RECT&bot_lat=-90&top_lat=90&left_lon=-180&right_lon=180&ctr_lat=&ctr_lon=&radius=&max_dist_units=deg&srn=&grn=&start_year=${catargs[1]}&start_month=${catargs[2]}&start_day=${catargs[3]}&start_time=${catargs[4]}%3A${catargs[5]}%3A${catargs[6]}&end_year=${catargs[7]}&end_month=${catargs[8]}&end_day=${catargs[9]}&end_time=${catargs[10]}%3A${catargs[11]}%3A${catargs[12]}&min_dep=&max_dep=&min_mag=&max_mag=&req_mag_type=Any&req_mag_agcy=prime" > $OUTFILE

        iscomplete=$(tecto_tac "${OUTFILE}" | grep -m 1 STOP)
        if [[ $iscomplete != "STOP" ]]; then
          # cannotbecompleted=$(grep -c -m 1 "cannot be completed" ${OUTFILE})
          # if [[ $cannotbecompleted -eq 1 ]]; then
          # cat ${OUTFILE}

            rm -f ${OUTFILE}
          # fi
          echo "Did not find any events. Waiting for two minutes and trying to download again!"
          sleep 120
          keep_going=1
        else
          keep_going=0
        fi
      done
      tile_catalog ${TILEDIR} ${OUTFILE}
    else
      echo "File isc_catalog_${catargs[0]}.cat exists already"
    fi
  done < isc_program.txt

  # If we have all of the recorded catalogs, then save a marker file
  numcats=$(wc -l < isc_program.txt)
  catfiles=($(ls -1 *.cat))
  if [[ $(echo "$numcats == ${#catfiles[@]}") ]]; then
    # Test whether all catalog files have a STOP command
    catalog_files=($(ls -1 isc_catalog*.cat | sort -n -k 3 -t '_'))
    endnum=$(echo "${#catalog_files[@]} - 1" | bc)
    # Delete any empty catalog files until we find one that isn't empty
    iscomplete=1
    for fileind in $(seq $endnum -1 0); do
      latest_catalog_file=${catalog_files[$fileind]}
      echo "Verifying catalog file ${latest_catalog_file}"
      if [[ $(tecto_tac $latest_catalog_file | grep -m 1 "STOP") != "STOP" ]]; then
        echo "Deleting catalog file without STOP line: $latest_catalog_file"
        iscomplete=0
      fi
    done
    # Mark the catalogs as complete
    [[ $iscomplete -eq 1 ]] && touch isc_catalogs_completed.txt && echo "Marking catalogs as complete"
  fi
}

function scrape_latest_events {

    TILEDIR="${1}"
    shopt -s nullglob
    # Expects catalog files in the format isc_events_N.cat
    catalog_files=($(ls -1 *.cat | sort -n -k 3 -t '_'))
    endnum=$(echo "${#catalog_files[@]} - 1" | bc)
    # Delete any empty catalog files until we find one that isn't empty
    for fileind in $(seq $endnum -1 0); do
      latest_catalog_file=${catalog_files[$fileind]}
      echo $latest_catalog_file
      if [[ $(grep "STOP" $latest_catalog_file) != "STOP" ]]; then
        echo "Deleting catalog file without STOP: $latest_catalog_file"
        rm -f $latest_catalog_file
      else
        break
      fi
    done

    if [[ $file_ind -lt 0 ]]; then
      echo "No catalogs exist."
      return
    fi

    echo "Last file with a recorded event is ${catalog_files[$fileind]}"

    latest_catalog_num=$(echo ${catalog_files[$fileind]} | cut -f 3 -d '_' | cut -f 1 -d '.')

    # Get the latest event from the latest catalog
    lastline=$(grep -B 2 "STOP" $latest_catalog_file | head -n 1 )

    if [[ $(echo "$latest_catalog_num > 2" | bc) -eq 1 ]]; then
      # We will create a new catalog file with each new scrape
      new_catalog_num=$(echo "$latest_catalog_num + 1" | bc)
    else
      return
    fi

    lastdatetime=($(echo $lastline | gawk -F, '{
      split($4,a,"-")
      split(substr($5,1,8),b,":")

      # Add 1 second to the time so that we can begin AFTER the last event
      the_time = sprintf("%i %i %i %i %i %i",a[1],a[2],a[3],b[1],b[2],b[3]);
      secs = mktime(the_time);
      newdate = strftime("%F", secs+1);
      newtime = strftime("%T", secs+1);
      split(newdate,c,"-")
      split(newtime,d,":")
      print c[1], c[2], c[3], d[1], d[2], d[3]
    }'))

    # Get the current time
    this_year=$(date -u +"%Y")
    this_month=$(date -u +"%m")
    this_day=$(date -u +"%d")
    this_hour=$(date -u +"%H")
    this_minute=$(date -u +"%M")
    this_second=$(date -u +"%S")

    echo mirror is ${ISC_MIRROR}
    OUTFILE="newisc_catalog_${new_catalog_num}.cat"

    echo "Dowloading seismicity after latest saved event: $lastline"
    echo       curl "${ISC_MIRROR}/cgi-bin/web-db-v4?request=COMPREHENSIVE&out_format=CATCSV&searchshape=RECT&bot_lat=-90&top_lat=90&left_lon=-180&right_lon=180&ctr_lat=&ctr_lon=&radius=&max_dist_units=deg&srn=&grn=&start_year=${lastdatetime[0]}&start_month=${lastdatetime[1]}&start_day=${lastdatetime[2]}&start_time=${lastdatetime[3]}%3A${lastdatetime[4]}%3A${lastdatetime[5]}&end_year=${this_year}&end_month=${this_month}&end_day=${this_day}&end_time=${this_hour}%3A${this_minute}%3A${this_second}&min_dep=&max_dep=&min_mag=&max_mag=&req_mag_type=Any&req_mag_agcy=prime" \> $OUTFILE

    curl "${ISC_MIRROR}/cgi-bin/web-db-v4?request=COMPREHENSIVE&out_format=CATCSV&searchshape=RECT&bot_lat=-90&top_lat=90&left_lon=-180&right_lon=180&ctr_lat=&ctr_lon=&radius=&max_dist_units=deg&srn=&grn=&start_year=${lastdatetime[0]}&start_month=${lastdatetime[1]}&start_day=${lastdatetime[2]}&start_time=${lastdatetime[3]}%3A${lastdatetime[4]}%3A${lastdatetime[5]}&end_year=${this_year}&end_month=${this_month}&end_day=${this_day}&end_time=${this_hour}%3A${this_minute}%3A${this_second}&min_dep=&max_dep=&min_mag=&max_mag=&req_mag_type=Any&req_mag_agcy=prime" > $OUTFILE

    # Delete the new catalog file if it is empty
    if [[ -e ${OUTFILE} && ! -s ${OUTFILE} ]]; then
      rm -f ${OUTFILE}
    fi

    if [[ -s ${OUTFILE} ]]; then
      tile_catalog ${TILEDIR} ${OUTFILE}
    fi
}

function tile_catalog {
  # Don't match tile_*.cat as a file...
  TILEDIR=${1}
  CATALOGFILE=${2}

  if [[ -s "${2}" ]]; then
    echo "Processing file ${2} into tile files"
    sed < "${2}" -n '/^  EVENTID/,/^STOP/p' | sed '1d;$d' | sed '$d' | gawk -F, -v tiledir=${TILEDIR} '
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

      if($12 >= 5) {
        tilestr=sprintf("%sisc_m_largerthan_5.cat", tiledir)
      } else {
        tilestr=sprintf("%stile_%d_%d.cat", tiledir, rd($7,5), rd($6,5));
      }
      print $0 >> tilestr
      added++
    }
    END {
      print ">>>> Added", added, "events to ISC seismicity tiles <<<<"
    }'
  fi
}

ISCDIR="$1"

if [[ -d $ISCDIR ]]; then
  echo "ISC tile directory exists."
else
  echo "Creating ISC seismicity directory ${ISCDIR}"
  mkdir -p ${ISCDIR}
fi

cd $ISCDIR

if [[ $2 == "rebuild" ]]; then
  echo "Rebuilding tiles from saved catalogs"
  rm -f ./tiles/*.cat
  for i in *.cat; do
    tile_catalog ./tiles/ $i
  done
  exit
fi

ISC_MIRROR="http://www.isc.ac.uk"


if [[ $2 == "wash" ]]; then
  ISC_MIRROR="http://isc-mirror.iris.washington.edu"
elif [[ $2 == "uk" ]]; then
  ISC_MIRROR="http://www.isc.ac.uk"
fi

if [[ ! -d ./tiles ]]; then
  mkdir -p ./tiles
fi

# First we download the permanent ISC catalog files
download_isc_catalogs "./tiles/"

scrape_latest_events "./tiles/"

# Then we scrape the data after the latest event. If this returns more than
# 40000 events, then the permanent tiles need to be updated with the recent
# year(s) worth of data.

###
###
# Code to create the optimum download plan for ISC catalog where we request
# 39000 events per curl call. This requires a previously downloaded catalog
# with events in files named isc_events_YYYY_MM_SEG.txt, latest events toward
# # file end. This shouldn't need to be updated often!
# #
# filelist=($(ls | sort -n -k3 -k4 -k5 -t '_'))
# rm -f orderedevents.txt
# for f in ${filelist[@]}; do   sed < $f -n '/^  EVENTID/,/^STOP/p' | sed '1d;$d' | sed '$d' >> orderedevents.txt; done
#
# # Run this in the catalog directory to generate the efficient 39k files list
#
# this_year=$(date -u +"%Y")
# this_month=$(date -u +"%m")
# this_day=$(date -u +"%d")
# this_hour=$(date -u +"%H")
# this_minute=$(date -u +"%M")
# this_second=$(date -u +"%S")
#
#
# gawk < orderedevents.txt -F, -v this_year=${this_year} -v this_month=${this_month} -v this_day=${this_day} -v this_hour=${this_hour} -v this_minute=${this_minute} -v this_second=${this_second} '
#   BEGIN {
#     catnum=2
#     hasprinted=0
#   }
#   (NR==1) {
#     printf("1 1900 01 01 00 00 00")
#   }
#   (NR==1 || NR % 39000 == 0) {
#     datestr=$4
#     timestr=$5
#     split(datestr,a,"-")
#     split(timestr,b,":")
#     split(b[3],g,".")
#     # # Add 1 second to the time so that we can begin AFTER the last event
#     #
#     # the_time = sprintf("%i %i %i %i %i %i",a[1],a[2],a[3],b[1],b[2],g[1]);
#     # secs = mktime(the_time);
#     # newdate = strftime("%F", secs+1);
#     # newtime = strftime("%T", secs+1);
#     #
#     # split(newdate,c,"-")
#     # split(newtime,d,":")
#     if (hasprinted==1) {
#       printf(" %s %s %s %s %s %s\n%d %s %s %s %s %s %s", a[1], a[2], a[3], b[1], b[2], substr(g[1],1,2), catnum++, a[1], a[2], a[3], b[1], b[2],  substr(g[1],1,2))
#     } else {
#       hasprinted=1
#     }
#   }
#   END {
#     printf(" %s %s %s %s %s %s\n", this_year, this_month, this_day, this_hour, this_minute, this_second)
#   }'

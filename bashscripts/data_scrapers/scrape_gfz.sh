#!/bin/bash

# tectoplot
# bashscripts/scrape_gfz.sh
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

# Scrape the GFZ focal mechanism catalog

# GFZ web scrape returns latest events first, so we have to scrape until we
# encounter an event that already exists on the disk. Then, we need to add
# all earlier events to the local catalog and download their moment tensor
# file.

GFZDIR=${1}

[[ ! -d $GFZDIR ]] && mkdir -p $GFZDIR

cd $GFZDIR

GFZCATALOG=${GFZDIR}"gfz_extract.cat"
GFZSTORED=${GFZDIR}"GFZStored.zip"

GFZ_LATESTEVENT=${GFZDIR}"gfz_latest.txt"

# Set up a fake string that won't be matchable
[[ ! -s ${GFZ_LATESTEVENT} ]] && echo "noevents00000noevents" > ${GFZ_LATESTEVENT}
[[ ! -e ${GFZCATALOG} ]] && touch ${GFZCATALOG}

# if [[ $2 =~ "rebuild" ]]; then
#   echo "Rebuilding GFZ focal mechanism catalog from downloaded _mt files..."
#   rm -f ${GFZCATALOG}
#   rm -f gfz_rebuild.txt
#
#   for gfz_file in gfz*_mt.txt; do
#     echo "${gfz_file%_*}" >> gfz_rebuild.txt
#   done
#   sort -r gfz_rebuild.txt > gfz_latest_sort.txt
#   head -n 1 gfz_latest_sort.txt > ${GFZ_LATESTEVENT}
#
#   echo "Rebuilding... "
#   while read mtfile; do
#     echo -n "$mtfile "
#     ${CMTTOOLS} ${mtfile}_mt.txt Z Z >> ${GFZCATALOG}
#   done < gfz_latest_sort.txt
#
#   echo
#   echo -n "Note: scraping will not download any missing MT files earlier than: " ${GFZ_LATESTEVENT}
#   rm gfz_latest_sort.txt gfz_rebuild.txt
#
#   exit
# fi

# gfz_complete.txt contains file names of downloaded HTML pages that have
# been marked complete when a following file was successfully downloaded
rm -f gfz_list_*.txt

pagenum=1
while : ; do
  echo "Scraping GFZ moment tensor page $pagenum"
  curl "https://geofon.gfz-potsdam.de/eqinfo/list.php?page=${pagenum}&datemin=&datemax=&latmax=&lonmin=&lonmax=&latmin=&magmin=&mode=mt&fmt=txt&nmax=1000" > gfz_list_$pagenum.txt
  result=$(wc -l < gfz_list_$pagenum.txt)
  if [[ $result -eq 0 ]]; then
    rm -f gfz_list_$pagenum.txt
    break
  fi

  # Find a list of new events (more recent than the last stored event)
  if gawk '
    # Load the latest event
    (NR==FNR) {
      searchfor=$1
    }
    (NR != FNR) {
      if ($1 == searchfor) {
        print "Found event", searchfor > "/dev/stderr"
        exit 1
      } else {
        print $1
      }
    }
    ' "${GFZ_LATESTEVENT}" gfz_list_$pagenum.txt >> gfz_list_newevents.txt
  then
    echo "File gfz_list_$pagenum.txt completely downloaded and included"
  else
    echo "Found event in gfz_list_$pagenum.txt... stopping download"
    break
  fi
  pagenum=$(echo "$pagenum + 1 " | bc)
done
pagenum=$(echo "$pagenum - 1 " | bc)

# Download the _mt.txt files of the new events
added=0
while read p; do
  if ! [[ -s "${p}_mt.txt" ]]; then
    echo "Trying to download ${p}_mt.txt"
    event_id=$p
    event_yr=$(echo $p | gawk  '{print substr($1,4,4); }')
    echo ":${event_id}:${event_yr}:"
    curl "https://geofon.gfz-potsdam.de/data/alerts/${event_yr}/${event_id}/mt.txt" > ${event_id}_mt.txt
    linelen=$(wc -l < ${event_id}_mt.txt)
    if [[ $linelen -lt 20 ]]; then
      echo "Event report ${event_id}_mt.txt is not at least 20 lines long. Marking and excluding."
      mv ${event_id}_mt.txt ${event_id}_mtbad.txt
    else
      ${CMTTOOLS} ${event_id}_mt.txt Z Z >> ${GFZCATALOG}
      zip ${GFZ_STORED} ${event_id}_mt.txt
      rm -f ${event_id}_mt.txt
      ((added++))
    fi
  fi
done < gfz_list_newevents.txt
echo ">>>> Added ${added} events to GFZ database <<<<"

rm -f gfz_list_*.txt
rm -f cmt_tools_rejected.dat

# Example GFZ event report (line numbers added)
# https://geofon.gfz-potsdam.de/data/alerts/2020/gfz2020xnmx/mt.txt


#1 GFZ Event gfz2020xrlv
#2 20/12/02 20:36:23.00
#3 Sulawesi, Indonesia
#4 Epicenter: -3.46 123.28
#5 MW 5.1
#6
#7 GFZ MOMENT TENSOR SOLUTION
#8 Depth  10         No. of sta: 93
#9 Moment Tensor;   Scale 10**16 Nm
#10   Mrr= 5.31       Mtt=-0.72
#11   Mpp=-4.60       Mrt=-1.02
#12   Mrp= 1.29       Mtp= 2.41
#13 Principal axes:
#14   T  Val=  5.57  Plg=81  Azm=217
#15   N        0.41       3      333
#16   P       -5.98       8       63
#17
#18 Best Double Couple:Mo=5.8*10**16
#19  NP1:Strike=158 Dip=37 Slip=  96
#20  NP2:       330     53        85

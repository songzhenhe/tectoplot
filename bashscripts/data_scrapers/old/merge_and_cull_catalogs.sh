#!/bin/bash

# tectoplot
# bashscripts/merge_and_cull_catalogs.sh
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


# Assumes existence of GCMT, ISC, and GFZ scraped focal mechanism databases.
# Run tectoplot -scrapedata to generate these if you are merging manually.

# This script will merge and simplify several focal mechanism catalogs to try
# to achieve the greatest number of events while trying to avoid conflicting
# solutions for individual events. GCMT are prioritized due to having both
# origin/centroid data. ISC events with GCMT IDs after 1976 are removed, along
# with non-GCMT events with the same event_id (often origin, etc). ISC GCMT
# solutions do not contain the origin information and are incomplete.

# GFZ solutions in the ISC catalog do not contain magnitude information. The
# GFZ focal mechanisms have a different NTP convention (?) and also report the
# magnitude differently (NTP, Moment tensor, SDR exponents can be different!)

# There are ~470+ GFZ events that are not in the GCMT catalog using a 60 second
# time difference. Use 40 seconds just to catch most of the events in case the
# origin/centroid times are being compared.

echo "Merging focal mechanism catalogs into $FOCALCATALOG"
if [[ ! -d $FOCALDIR ]]; then
  mkdir -p $FOCALDIR
fi

# Clean up ISC catalog to yield unique events per EQ.
# Select the largest magnitude from the alternative magnitudes
# Match CENTROID+ORIGIN for some non-GCMT events.
# Keep only the last event out of a group.

# gawk < $ISCCATALOG 'BEGIN{lastlastid="YYY"; lastid="XXX"; storage[1]=""; groupind=1; groupnum=1}
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
# }' > $CLEANISC

cat $ISCCATALOG $GCMTCATALOG $GFZCATALOG | sort -n -k4,4 > $FOCALDIR"mergecat.cat"

# Remove any GFZ focal mechanisms that match GCMT/ISC events and build the catalog.
gawk < $FOCALDIR"mergecat.cat" -v tdiffmin=40 -v outfile=$FOCALDIR"gfz_reject.cat" '
  function abs(v) { return (v<0)?-v:v }
  BEGIN {
      getline
      twolast=$0
      twolastid=$1
      print
      twolastsec=$4
      getline
      onelast=$0
      onelastsec=$4
  }
  {
      newline=$0
      newsec=$4

      if (substr(onelast,1,1) == "Z") {
         # print onelastsec-twolastsec, "|", newsec-onelastsec
         # Middle line is a GFZ mechanism
        if (onelastsec-twolastsec < tdiffmin || newsec-onelastsec < tdiffmin) {
         # nothing. Could print to gfz_conflict.cat file.
        } else {
          print onelast
        }
      } else {
        print onelast
      }
      twolast=onelast
      twolastsec=onelastsec
      onelast=newline
      onelastsec=newsec
} END {
  print
}' > $FOCALCATALOG

gawk < $FOCALCATALOG '{if (substr($0,1,1)=="Z") { print }} ' > ${FOCALDIR}nongcmt.txt

# Cleanup the intermediate file
rm -f $CLEANISC

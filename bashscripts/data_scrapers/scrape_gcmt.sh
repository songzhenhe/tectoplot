#!/bin/bash

# tectoplot
# bashscripts/scrape_gcmt.sh
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

# This script will download GCMT data in ndk format and produce an event catalog
# in tectoplot CMT format. That catalog will be merged with other catalogs to
# produce a final joined catalog.

# Output is a file containing centroid (gcmt_centroid.txt) and origin (gcmt_origin.txt) location focal mechanisms in tectoplot 27 field format:

[[ ! -d $GCMTDIR ]] && mkdir -p $GCMTDIR

cd $GCMTDIR

if [[ ! -s gcmt_extract.cat ]]; then
  BEFORE=0
else
  BEFORE=$(wc -l < gcmt_extract.cat)
fi

[[ ! -e jan76_dec17.ndk ]] && curl "https://www.ldeo.columbia.edu/~gcmt/projects/CMT/catalog/jan76_dec17.ndk" > jan76_dec17.ndk

years=("2018" "2019" "2020")
months=("jan" "feb" "mar" "apr" "may" "jun" "jul" "aug" "sep" "oct" "nov" "dec")

for year in ${years[@]}; do
  YY=$(echo $year | tail -c 3)
  for month in ${months[@]}; do
    if [[ ! -s ${month}${YY}.ndk ]]; then
      if curl "https://www.ldeo.columbia.edu/~gcmt/projects/CMT/catalog/NEW_MONTHLY/${year}/${month}${YY}.ndk" > ${month}${YY}.ndk; then
        echo ${month}${YY}.ndk >> gcmt_complete_ndk.txt
      fi
    fi
  done
done

# Delete the Quick CMT file
rm -f gcmt_quick.cmt

for ndkfile in *.ndk; do
  if [[ $ndkfile == "quick.ndk" ]]; then
    echo "Skipping QuickCMT"
    continue
  fi
  res=$(grep 404 $ndkfile)
  if [[ $res =~ "<title>404" ]]; then
    echo "ndk file $ndkfile was not correctly downloaded... deleting."
    rm -f $ndkfile
  else
    if ! grep $ndkfile gcmt_extracted.txt > /dev/null; then
      echo "Extracting $ndkfile to pre-catalog"
      ${CMTTOOLS} $ndkfile K G >> gcmt_extract_pre.cat
      echo $ndkfile >> gcmt_extracted.txt
    fi
  fi
done

echo "Downloading Quick CMTs"

if ! curl "https://www.ldeo.columbia.edu/~gcmt/projects/CMT/catalog/NEW_QUICK/qcmt.ndk" > quick.ndk; then
  echo "Quick CMT download failed... deleting partial file"
  rm quick.ndk
else
  echo "Extracting Quick CMT file"
  ${CMTTOOLS} quick.ndk K G > gcmt_quick.cat
fi

# Go through the catalog and remove Quick CMTs (PDEQ) that have a PDEW equivalent
echo "Combining catalogs and filtering out PDEQ QuickCMTs with equivalent PDEW solutions"
cat gcmt_extract_pre.cat gcmt_quick.cat | gawk '
 {
   seen[$2]++
   id[NR]=$2
   catalog[NR]=$12
   data[NR]=$0
 }
 END {
   for(i=1;i<=NR;i++) {
     if (seen[id[i]] > 1 && catalog[i]=="PDEQ") {
       print data[i] > "./gcmt_pdeq_removed.cat"
     } else {
       print data[i]
     }
   }
 }' > gcmt_extract.cat

AFTER=$(wc -l < gcmt_extract.cat)
GCMT_ADDED=$(echo "$AFTER - $BEFORE" | bc)
echo ">>>> Added $GCMT_ADDED GCMT focal mechanisms <<<<"

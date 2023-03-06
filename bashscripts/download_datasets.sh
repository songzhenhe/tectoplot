# tectoplot

# bashscripts/download_datasets.sh
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

# This function will check whether a specified directory contains a named file.
# If the file exists, nothing is done. If not, the target file (given as a URL)
# is downloaded into the specified direcory. If the target file is an archive
# file, it is automatically extracted into the download directory.
#
# Failed downloads are recognized and the user is prompted to continue or abort.
# Incompletely downloaded archive files will be automatically continued. If the
# target file is a non-archive file, we can't detect failed downloads and
# instead rely on curl outputting an error so we can delete the partial file.

# Recognized archive formats: .zip .gz .tar .bz2

function check_and_download_dataset() {

  ALWAYS_DOWNLOAD="N"

  DOWNLOAD_SOURCEURL=$1     # The URL of the file to download
  DOWNLOADDIR=$2            # Target directory that will hold file or archive
  CHECKFILE=$3              # File in DOWNLOADDIR that must exist and have data
  SLAB2_ALTNAME=$4          # If the URL file needs to be renamed after DLing
  returncode=0

  # Execute this section in a subshell to avoid cd out of pwd
  (
  trytounzipflag=0
  testfileflag=0
  gotdownload=0

  # Check if the target file exists. This could be a target file or a file
  # within a unzipped folder.

  if [[ -s "${DOWNLOADDIR}/${CHECKFILE}" ]]; then
    return 0
  else

    if [[ $ALWAYS_DOWNLOAD != "Y" ]]; then
      read -r -p "Download online dataset ${DOWNLOAD_SOURCEURL} to folder ${DOWNLOADDIR}? [Y|n] " response
      case $response in
        Y|y|yes|"")
          response="Y"
        ;;
        N|n|*)
          return 0
        ;;
      esac
    else
      response="Y"
    fi

    if [[ ! -d "${DOWNLOADDIR}" ]]; then
      mkdir -p "${DOWNLOADDIR}"
    fi

    cd ${DOWNLOADDIR}

    response="Y"
    filename=$(basename "${DOWNLOAD_SOURCEURL}")

    while : ; do
      if ! curl --fail -L -C - -O "${DOWNLOAD_SOURCEURL}"; then
        read -r -p "Download failed for ${DOWNLOAD_SOURCEURL}. Retry? [Y|n] " response
        case $response in
          Y|y|yes|"")
            response="Y"
          ;;
          N|n|*)
            gotdownload=0
            [[ -s ${filename} ]] && rm -f ${filename} && echo "Deleted incomplete file ${filename}"
            returncode=1
            break
          ;;
        esac
      else
        gotdownload=1
        if [[ ! -z ${SLAB2_ALTNAME} ]]; then
          mv ${filename} ${SLAB2_ALTNAME}
          filename=${SLAB2_ALTNAME}
        fi
        returncode=0
        break
      fi
    done
  fi

  if [[ $gotdownload -eq 1 ]]; then
    case ${filename} in
      *.zip)
        if unzip ${filename}; then
          deletezipflag=1
        else
          echo "Unzip of ${filename} failed."
          returncode=1
        fi
      ;;
      *.gz)
        if tar -zxvf ${filename}; then
          deletezipflag=1
        else
          echo "untar/inflate of ${filename} failed."
          returncode=1
        fi
      ;;
      *.tar)
        if tar -xvf ${filename}; then
          deletezipflag=1
        else
          echo "untar of ${filename} failed."
          returncode=1
        fi
      ;;
      *.bz2)
        if bunzip2 ${filename}; then
          deletezipflag=1
        else
          echo "inflation of BZ2 archive ${filename} failed."
          returncode=1
        fi
      ;;
      *)
        deletezipflag=0
      ;;
    esac
  fi

  if [[ -s $CHECKFILE && $deletezipflag -eq 1 ]]; then
    rm -f ${filename}
  fi
  )

  return $returncode

}

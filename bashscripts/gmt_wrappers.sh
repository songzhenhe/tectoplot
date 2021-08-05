# gmt_module_interface.sh
# Source this file

# tectoplot
# bashscripts/gmt_wrappers.sh
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



# In an attempt to support old GMT versions and protect against future changes to GMT, these
# wrapper functions translate inputs and parameters into GMT calls for different versions/modules
# that have had significant recent changes in GMT syntax

# gmt psmeca -E"${CMT_SSCOLOR}" -C$SEIS_CPT ${CMTEXTRA} ${CMT_INPUTORDER} -S${CMTLETTER}"$CMTRESCALE"i/0 ${CMT_STRIKESLIPPLOT} -L${FMLPEN} $RJOK $VERBOSE >> map.ps

# assumes $RJOK $VERBOSE for all calls

# psmeca between v6.1 and v6.2 saw some changes (-Z -> -C)
# gmt_psmeca CPT_FILE options...

function gmt_version() {
  gawk -v vers=${GMTVERSION} '
  BEGIN {
    if (vers >= "6.2.0") {
      if (vers > "6.2.0") {
        print "newer_6.2"
      } else {
        print 6.2
      }
    } else {
      print "older"
    }
  }'
}

# < 6.2 : -Z for colors; >= 6.2 : -C for same effect
# usage:
# gmt_psmeca CPT_FILE {All options other than -Z/-C}

function gmt_psmeca() {
  local CPT_FILE="${1}"
  shift

  case $(gmt_version) in
    6.2|newer_6.2)
      gmt psmeca -C${CPT_FILE} ${@}
      ;;
    older)
      gmt psmeca -Z${CPT_FILE} ${@}
      ;;
    *)
      echo "unknown"
      ;;
  esac
}

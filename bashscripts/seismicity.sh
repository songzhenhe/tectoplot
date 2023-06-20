# tectoplot

# bashscripts/seismicity.sh
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

## Functions to manage seismicity data

# GMT psxy wrapper for plotting earthquakes scaled by a nonlinear stretch
# factor. Expects plain text piped to stdin and outputs PS code to stdout

# Scaling by magnitude is done using the following formula:

# Mw_new=(Mw^seisstretch)/(refmag^(seisstretch-1))

# The symbol size is defined such that an event with Mw=refmag will be
# scale*refmag points in diameter, on the printed page.

# To plot all events at the same size (scale*refmag points), set seisstretch=0
# so that the scale equation reduces to: Mw_new=1/(refmag^-1) = refmag. Then
# all events will be scale*refmag points in diameter.


# Usage: gmt_psxy [[option1 arg1]] ...

# fill, stroke option can be "none" to deactivate fill/stroke

# xmul, ymul, zmul factors are multiplied to X,Y,Z values before plotting. This
# is useful for turning depth positive to depth negative (zmul -1) for instance.
# scale is multiplied vs magnitude before plotting (to adjust symbol size).

# Last tested with GMT 6.4.0

function gmt_psxy() {

  local symbol="c"
  local trans=0
  local scale=1
  local stretch=3
  local refmag=6
  local xcol=1
  local ycol=2
  local zcol=3
  local magcol=4
  local cpt="none"
  local fill="black"
  local stroke="0.1p,black"
  local gmt_psxy_args
  local strokeargs
  local fillargs
  local xmul=1
  local ymul=1
  local zmul=1

  while [[ ! -z $1 ]]; do
    case $1 in
      zmul)
        shift
        if ! arg_is_float $1; then
          echo "[gmt_psxy]: zmul option requires float argument (read $1)" > /dev/stderr
          exit 1
        fi
        zmul=$1
        shift
      ;;
      ymul)
        shift
        if ! arg_is_float $1; then
          echo "[gmt_psxy]: ymul option requires float argument (read $1)" > /dev/stderr
          exit 1
        fi
        ymul=$1
        shift
      ;;
      xmul)
        shift
        if ! arg_is_float $1; then
          echo "[gmt_psxy]: xmul option requires float argument (read $1)" > /dev/stderr
          exit 1
        fi
        xmul=$1
        shift
      ;;
      trans)
        shift
        if [[ -z $1 ]]; then
          echo "[gmt_psxy]: trans option requires argument (read empty string)" > /dev/stderr
          exit 1
        fi
        trans=$1
        shift
      ;;
      symbol)
        shift
        if [[ -z $1 ]]; then
          echo "[gmt_psxy]: symbol option requires string argument (read empty string)" > /dev/stderr
          exit 1
        fi
        symbol=$1
        shift
      ;;
      scale)
        shift
        if ! arg_is_positive_float $1; then
          echo "[gmt_psxy]: scale option requires positive float argument (read $1)" > /dev/stderr
          exit 1
        fi
        scale=$1
        shift
      ;;
      stretch)
        shift
        if ! arg_is_positive_float $1; then
          echo "[gmt_psxy]: stretch option requires positive float argument (read $1)" > /dev/stderr
          exit 1
        fi
        stretch=$1
        shift
      ;;
      refmag)
        shift
        if ! arg_is_float $1; then
          echo "[gmt_psxy]: refmag option requires float argument (read $1)" > /dev/stderr
          exit 1
        fi
        refmag=$1
        shift
      ;;
      xcol)
        shift
        if ! arg_is_positive_integer $1; then
          echo "[gmt_psxy]: xcol option requires positive integer argument (read $1)" > /dev/stderr
          exit 1
        fi
        xcol=$1
        shift
      ;;
      ycol)
        shift
        if ! arg_is_positive_integer $1; then
          echo "[gmt_psxy]: ycol option requires positive integer argument (read $1)" > /dev/stderr
          exit 1
        fi
        ycol=$1
        shift
      ;;
      zcol)
        shift
        if ! arg_is_positive_integer $1; then
          echo "[gmt_psxy]: zcol option requires positive integer argument (read $1)" > /dev/stderr
          exit 1
        fi
        zcol=$1
        shift
      ;;
      magcol)
        shift
        if ! arg_is_positive_integer $1; then
          echo "[gmt_psxy]: magcol option requires positive integer argument (read $1)" > /dev/stderr
          exit 1
        fi
        magcol=$1
        shift
      ;;
      cpt)
        shift
        if [[ -z $1 ]]; then
          echo "[gmt_psxy]: cpt option requires string argument (read empty string)" > /dev/stderr
          exit 1
        fi
        cpt=$1
        shift
      ;;
      fill)
        shift
        if [[ -z $1 ]]; then
          echo "[gmt_psxy]: fill option requires string argument (read empty string)" > /dev/stderr
          exit 1
        fi
        fill=$1
        shift
      ;;
      stroke)
        shift
        if [[ -z $1 ]]; then
          echo "[gmt_psxy]: stroke option requires string argument (read empty string)" > /dev/stderr
          exit 1
        fi
        stroke=$1
        shift
      ;;
      *)
        gmt_psxy_args+=("$1")
        shift
      ;;
    esac
  done

  local colorargs=""

  local strokewidth=$(echo ${stroke} | gawk '{ split($1,a,","); print $1+0}')

  if [[ ${stroke} == "none" || $(echo "$strokewidth == 0" | bc) -eq 1 ]]; then
    strokeargs=""
  else
    strokeargs="-W${stroke}"
  fi

  if [[ ${fill} == "none" ]]; then
    fillargs=""
  else
    fillargs="-G${fill}"
  fi

  if [[ ${cpt} == "none" ]]; then
    colorargs="-t${trans} ${strokeargs} ${fillargs} -i0+s${xmul},1+s${ymul},2+s${scale}"
    zcol=0
  else
    colorargs="-t${trans} ${strokeargs} -C${cpt} -i0+s${xmul},1+s${ymul},2+s${zmul},3+s${scale}"
  fi

  # echo colorargs=${colorargs}

  gawk -v str=$stretch -v sref=$refmag -v xcol=${xcol} -v ycol=${ycol} -v zcol=${zcol} -v magcol=${magcol} '
  BEGIN {
    OFMT="%.12f"
  }
  {
    x=$(xcol)
    y=$(ycol)
    z=$(zcol)
    # Original stretch: M=0 -> Mnew=0
    # If str=1, then mw=magcol
    # If str>1, then mw=magcol if magcol=sref
    # mw=($(magcol)^str)/(sref^(str-1))
    
    # Jun 18, 2023: New stretch accommodating Mw >= -3
    mw=((($(magcol)+3)/3)^str)/(((sref+3)/3)^(str-1))

    if (zcol==0) {
      print x, y, mw
    } else {
      print x, y, z, mw
    }
  }' | gmt psxy -S${symbol} ${colorargs} ${gmt_psxy_args[@]} --PROJ_LENGTH_UNIT=p
}

# This function takes a Mw magnitude (e.g. 6.2) and prints the mantissa and
# exponent of the moment magnitude, scaled by a nonlinear stretch factor.

function stretched_m0_from_mw () {
  echo $1 | gawk  -v str=$SEISSTRETCH -v sref=$SEISSTRETCH_REFMAG '{
            # mwmod = ($1^str)/(sref^(str-1))
            # June 18, 2023 updated formula
            mwmod = ((($1+3)/3)^str)/(((sref+3)/3)^(str-1))
            a=sprintf("%E", 10^((mwmod + 10.7)*3/2))
            split(a,b,"+")
            split(a,c,"E")
            print c[1], b[2] }'
}

# function stretched_mw_from_mw [magnitude] [seisstretch] [refmag]
# argument 1: magnitude (mw)
# argu
# Stretch a Mw value from a Mw value

# On failure, prints -1

function stretched_mw_from_mw () {
  if ! arg_is_float $1; then
    echo "[stretched_mw_from_mw]: magnitude ($1) is not a float" > "/dev/stderr"
    echo "-1" && return 1
  fi
  if ! arg_is_float $1; then
    echo "[stretched_mw_from_mw]: seisstretch ($1) is not a float" > "/dev/stderr"
    echo "-1" && return 1
  fi
  if ! arg_is_float $1; then
    echo "[stretched_mw_from_mw]: refmag ($1) is not a float" > "/dev/stderr"
    echo "-1" && return 1
  fi

  # Updated formula June 18, 2023
  gawk -v mag=${1} -v str=${2} -v sref=${3} 'BEGIN{print (((mag+3)/3)^str)/(((sref+3)/3)^(str-1))}'

}

# Take a string as argument and return an earthquake ID
# Currently just removes whitespace because USGS sometimes has spaces in IDs

function eq_event_parse() {
    echo ${1} | gawk '{val=$0; gsub(/\s/,"",val); print val}'
}

# expects lines in the tectoplot CMT format
# 161.104 -10.0564 64.5 1.14754 0.595994 -1.74404 -0.358607 -0.19092 0.873788 21 none none 621112211 none 1625621059 0 2021-07-07T01:24:19
# outputs the original line followed by the Mw value

function mw_from_tensor_and_exponent() {
  gawk '
  {
    m0=sqrt(($4^2+$5^2+$6^2+2*$7^2+2*$8^2+2*$9^2)/2)*10^$10
    print $0, 2/3*log(m0)/log(10)-10.7
  }'
}


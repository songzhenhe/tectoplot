# tectoplot

# bashscripts/make3d.sh
# Copyright (c) 2023 Kyle Bradley, all rights reserved.
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

# GLOBAL variables and functions for plotting profiles

profile_alphabet=( {A..Z} {1..99} ) 
profile_alphabet_index=0
function get_automatic_profile_name() { 
  automatic_profile_name=${profile_alphabet[${profile_alphabet_index:-0}]}
  ((profile_alphabet_index++)); 
}

# global variables that are used to keep track of the current profile data bounds

function reset_profile_bounds() {
  profile_minx=99999
  profile_maxx=-99999
  profile_minz=99999
  profile_maxz=-99999
}


# Generic function to project XYZ data onto a multisegment track

function project_xyz_pts_onto_track() {
  local trackfile
  local xyzfile
  local outfile
  local xoffset
  local zoffset
  local zscale
  local noremoveflag=0
  local selectswath=0
  local swathwidth=0
  local closesttrackflag=0
  local gridzfile
  local gridzflag=0
  local numtrackpts
  local selectout
  local selectoutflag=0

  trackfile=$1
  if [[ ! -s ${trackfile} ]]; then
    echo "[project_xyz_pts_onto_track]: track file ${trackfile} does not exist; returning without doing anything"
    return 1
  fi
  shift


  xyzfile=$1
  if [[ ! -s ${xyzfile} ]]; then
    echo "[project_xyz_pts_onto_track]: XYZ file ${xyzfile} does not exist; returning without doing anything"
    return 1
  fi
  shift

  outfile=$1
  # if [[ -s ${outfile} ]]; then
  #   echo "[project_xyz_pts_onto_track]: output file ${outfile} already exists"
  #   return 1
  # fi
  shift

  xoffset=$1
  # if ! arg_is_float $xoffset; then
  #   echo "[project_xyz_pts_onto_track]: X offset ${xoffset} should be a float"
  #   return 1
  # fi
  shift

  zoffset=$1
  # if ! arg_is_float $zoffset; then
  #   echo "[project_xyz_pts_onto_track]: Z offset ${zoffset} should be a float"
  #   return 1
  # fi
  shift

  zscale=$1
  # if ! arg_is_float $xoffset; then
  #   echo "[project_xyz_pts_onto_track]: Z scale ${zscale} should be a float"
  #   return 1
  # fi
  shift

  while [[ ! -z $1 ]]; do
    case $1 in
      grid_z)
        shift
        if [[ ! -s $1 ]]; then
          echo "[project_xyz_pts_onto_track]: grid Z file $1 is empty or missing"
          return 1
        else
          gridzfile=$(abs_path $1)
          shift
          gridzflag=1
        fi

      ;;
      no_remove)
        noremoveflag=1
        shift
      ;;
      select_swath)
        selectswathflag=1
        shift
        swathwidth=$1
        shift
      ;;
      remove_w)
        removewflag=1
        shift
      ;;
      closest_track)
        closesttrackflag=1
        shift
        if ! arg_is_positive_int $1; then
          echo "[project_xyz_pts_onto_track]: closest track number should be integer (was $1)"
          return 1
        else
          closesttracknum=$1
        fi
        shift
        if [[ ! -s $1 ]]; then
          echo "[project_xyz_pts_onto_track]: closest tracks file $1 is empty or missing"
          return 1
        else
          closesttrackfile=$(abs_path $1)
        fi
        shift
      ;;
      select_out)
        shift
        while [[ ! -z ${1} ]]; do
          if [[ -z ${selectout} ]]; then
            selectout=$1
          else
            selectout=${selectout}"_$1"
          fi
          shift
        done

        if [[ ! -z ${selectout} ]]; then
          selectoutflag=1
        fi
        ;;

      *)
        echo "[project_xyz_pts_onto_track]: option $1 not recognized"
        return 1
      ;;
    esac

  done

  # Extract the points that are within the swath width of the trackfile

  # xyzfile
  # 160 -10 10 7.20 1901-05-25T00:32:01 1901.0525000 -2165034204

  # if noremoveflag is 1, output ALL events
  # otherwise, if swath>0, select based on swath distance AND remove end-projecting points
  #            if swath<=0, just remove the end-projecting points

  gmt mapproject ${xyzfile} -L${trackfile}+p+uk -f0x,1y,2s --FORMAT_FLOAT_OUT="%.12f" | gawk -v width=${swathwidth} -v numpts="$(wc -l < ${trackfile})" -v noremove=${noremoveflag} '
    {
      if (noremove==1) {
        print
      } else {
        if (width+0 > 0) {
          if ($3+0 < width+0 && $5+0!=0 && $5+0 != numpts-1) {
            print
          }
        } else {
          if ($5+0!=0 && $5+0 != numpts-1) {
            print
          }
        }
      }
    }' > project_tmp.txt

  # tmp.txt contains points that project along, and are close to, the track line
  # 158.365100000000	-8.152000000000	12.161432705494	0.000000000000	0.557061468002	97.68 4.3 2021-08-19T13:07:56 us7000f5ru 1629378476
  # x                 y               w (km)          line segment    fractional pt   trailing text

  # Find the projected location of each remaining point
  gmt mapproject project_tmp.txt -L${trackfile}+uk -f0x,1y,2s --FORMAT_FLOAT_OUT="%.12f" > project_tmp2.txt

  # Sample Z grid if asked and splice the results into the tmp2.txt file

  if [[ $gridzflag -eq 1 ]]; then
    gmt grdtrack project_tmp2.txt -G${gridzfile} -N -Z > project_tmp2_z.txt
    paste project_tmp2.txt project_tmp2_z.txt | gawk '
    {
      if (NF>9) {
        for(i=1;i<NF;++i) {
          if(i==9) {
            printf("%s ", ($NF))
          }
          printf("%s ", ($i))
        }
      } else {
        for(i=1;i<=NF;++i) {
          printf("%s ", ($i))
        }
      }
      printf("\n")
    }' > project_joined.txt
    mv project_joined.txt project_tmp2.txt
  fi

  # 157.332000000000	-8.512000000000	27.484181247334	157.332417461225	-8.262164183505	27.484181247334	0.000000000000	0.395692323006	15 7.628472 1926-07-28T08:52:26 iscgem909959 -1370531254
  # x                 y               w               xproj              yproj          w               line segment    fractional pt   trailing text (begins with Z)

  # Concatenate the track points to the data points
  gawk < "${trackfile}" '{
      printf("%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\t%.12f\tREMOVEME\n", $1, $2, 0, $1, $2, 0, 0, NR-1)
    }' >> project_tmp2.txt

# 154.720000000000	-6.260000000000	8.843726839112	154.800000000000	-6.260006053655	8.843726839112	0.000000000000	0.663369557899	50.000000 7.61344 -4.26512 -3.34832 2.11263 0 5.26165 25 154.55 -6.49 C031376A 47.7 195542564 0 1976-03-13T05:22:44
# lon               lat             w               lonproj           latproj         w               segmentnum      fractional pt   trailing text (begins with Z)

  # Sort the track points by fractional point order and calculate distance along combined track for each point

  sort -n -k 8,8 < project_tmp2.txt > project_tmp3.txt

# 154.080000000000	-9.220000000000	132.861782310308	154.800000000000	-8.250011248590	132.861782310308	0.000000000000	0.000000000000	10.000000 -0.364241 -0.926832 1.29468 -2.07005 -2.13857 8.65524 20 154.15 -9.32 C200909020037A 15.2 1251851814 0 2009-09-02T00:36:54
# lon               lat             w                 lonproj           latproj         w                 segmentnum      fractional pt   trailing text (begins with Z)

  gmt mapproject project_tmp3.txt -i3,4 -G+uk+a -o2 --FORMAT_FLOAT_OUT="%.12f" > project_tmp3_Xprime.txt

# 0.000000000000
# X'

  # We want to be able to output any of the available fields in any order, so
  # that modules calling this function do not have to do any further processing.

  # Field names

  # lon lat lonproj latproj w segnum frac xprime zprime z

  gawk -v xoff=${xoffset} -v zoff=${zoffset} -v zscale=${zscale} -v selectflag=${selectoutflag} -v selectcmd=${selectout} '
    BEGIN {
      OFMT="%.12f"
      if (selectflag != 1) {
        selectcmd="lon_lat_lonproj_latproj_w_segnum_frac"
      }
      split(selectcmd,selectarray,"_")
    }
    (NR==FNR) {
      xprime[NR]=$1
    }
    (NR!=FNR) {
        if ($9 != "REMOVEME") {
          old1=$1
          old2=$2
          old3=$3
          old4=$4
          old5=$5
          old6=$6
          old7=$7
          old8=$8
          old9=$9
          $1=""
          $2=""
          $3=""
          $4=""
          $5=""
          $6=""
          $7=""
          $8=""
          $9=""

          for(i=1; i<=length(selectarray); ++i) {
            # print "setting val", selectarray[i] > "/dev/stderr"
            if (selectarray[i]=="lon") {
              $(i)=old1
            } else if (selectarray[i]=="lat") {
              $(i)=old2
            } else if (selectarray[i]=="w") {
              $(i)=old3
            } else if (selectarray[i]=="lonproj") {
              $(i)=old4
            } else if (selectarray[i]=="latproj") {
              $(i)=old5
            } else if (selectarray[i]=="segnum") {
              $(i)=old7
            } else if (selectarray[i]=="frac") {
              $(i)=old8
            } else if (selectarray[i]=="fracint") {
              $(i)=int(old8)+1
            } else if (selectarray[i]=="xprime") {
              $(i)=xprime[FNR]-xoff
            } else if (selectarray[i]=="zprime") {
              $(i)=old9*zscale-zoff
            } else if (selectarray[i]=="z") {
              $(i)=old9
            }
          }

          print $0
        }
    }' project_tmp3_Xprime.txt project_tmp3.txt | sed -e 's/[.]0[0]* / /g; /\./ s/\.\{0,1\}0\{1,\}$//g; s/ [\ ]*/ /g' > ${outfile}

#

# default output format is
# 154.060000000000 -8.210000000000 81.459382449604 154.800000000000 -8.210675460048 4.35519 -35 0.013113903797 35 1.74996 6.75365 -8.51692 0.622134 -1.45719 -0.505692 20 154.50 -8.19 C201201071123A 19 1325935409 0 2012-01-07T11:23:29
# lon               lat            w               lonproj          latproj         X'      Z'  frac  pt       trailing text (begins with Z)

  rm -f project_tmp.txt project_tmp2.txt project_tmp3.txt project_tmp3_Xprime.txt

}

# Update profile bounds
# Accepts two arguments indicating the columns of the X and Z data. Multiple
# columns can be specified for X/Z (e.g. 1,2 55,12)
# The function reads data from stdin

function update_profile_bounds() {
  updated_bounds=($(cat < /dev/stdin | gawk -v xcol=$1 -v zcol=$2 -v minx=${profile_minx} -v maxx=${profile_maxx} -v minz=${profile_minz} -v maxz=${profile_maxz} '
  BEGIN {
    split(xcol,xcols,",")
    split(zcol,zcols,",")
  }
  {
    for(i=1;i<=length(xcols);++i) {
      ind=xcols[i]
      if ($ind+0==$ind) { minx=($ind+0)<minx?($ind+0):minx }
      if ($ind+0==$ind) { maxx=($ind+0)>maxx?($ind+0):maxx }
    }
    for(i=1;i<=length(zcols);++i) {
      ind=zcols[i]
      if ($ind+0==$ind) { minz=($ind+0)<minz?($ind+0):minz }
      if ($ind+0==$ind) { maxz=($ind+0)>maxz?($ind+0):maxz }
    }
  }
  END {
    print minx,maxx,minz,maxz
  }'))
  profile_minx=${updated_bounds[0]}
  profile_maxx=${updated_bounds[1]}
  profile_minz=${updated_bounds[2]}
  profile_maxz=${updated_bounds[3]}
}

function report_profile_bounds() {
  echo $profile_minx $profile_maxx $profile_minz $profile_maxz
}


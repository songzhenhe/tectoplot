#!/bin/bash

axeslabelcmd="tESW"

# axeslabelcmd="trSW"

# tectoplot
# bashscripts/profile.sh
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

# Usage: source profile.sh
#
# VARIABLES REQUIRED (in environment or set prior to sourcing using . bash command):
#
# MPROFFILE           - path to profile control file
# PROFILE_WIDTH_IN    - expected width of profile, with unit (7i)
# PROFILE_HEIGHT_IN   - expected height of profile, with unit (7i)
# PROFILE_X           - horizontal shift of profile relative to current plot origin (0i)
# PROFILE_Z           - vertical shift of profile relative to current plot origin (0i)

# PLOT_SECTIONS_PROFILEFLAG   {=1 means plot section PDFs in perpective, =0 means do not}

# Modularity breakers: (need to be fixed to be more modular)

# litho1profileflag   (=1 means extract and plot litho1 cross section, =0 means do not)
#
# FILES EXPECTED to exist:
# cmt_normal.txt, cmt_strikeslip.txt, cmt_thrust.txt (for focal mechanisms)
# cmt_alt_lines.xyz, cmt_alt_pts.xyz                 (if -cc flag is used)
#
# End of modularity breakers section

# Currently overplots data in a profile-by-profile order and not a dataset-by-dataset order
# You can modify the plot.sh file to adjust as you like.
#
# The challenge of this script is that we can't simply start plotting using GMT directly, as we
# need to know the extents for psbasemap before we can plot anything. So we have to create a
# script with the appropriate GMT commands (plot.sh) that can be run AFTER we process the data.

# Profile control file format:
# header line
# control lines
# [whitespace and empty lines are ignored]
# profile lines
#

# Header line begins with a lone @ symbol followed by options
# @ XMIN[auto] XMAX[auto] ZMIN[auto] ZMAX[auto] CROSSINGZEROLINE_FILE ZMATCH_FLAG[match|null]
#
# XMIN, XMAX, ZMIN and ZMAX are either integer kilometer values, or the text string 'auto'
# - If a variable is 'auto', it is determined by the extent of all plotted data
# - If CROSSINGZEROLINE_FILE is a file that exists, it is used as a zero-crossing
#   point for all profiles

# Control lines are specified by a letter code followed by any required arguments
#   and in some cases further optional arguments

# COMMON OPTIONS
# - ZSCALE is a float that is multiplied to Z values before projecting (e.g. -1)
#   This is usually used to transform km depth (+ down) to km depth (- down),
#   or to transform meters to kilometers (0.001)
# - GMT_arguments is a list of arguments passed directly to the relevant GMT
#   module. An example is -St0.03i -Gred for plotting red filled triangles.
#   The main tectoplot script uses this argument list to customize display of
#   different data types. GMT_arguments is often used to specify the CPT (using
#   -C)
# - CPT is a CPT file or GMT built-in CPT that is used to color data based on Z
#   values
#
# Swath profile sampling parameters
#
# |           |C            |A     AB is SWATH_WIDTH  (Z flag) (e.g. 10k)
# |           |D            |      AC is SWATH_D_SPACING       (e.g. 0.1k)
# |-----------|E------------|      CD, DE, EF, FG are SWATH_SUBSAMPLE_DISTANCE
# |           |F            |
# |           |G            |B     Often SWATH_D_SPACING = SWATH_SUBSAMPLE_DISTANCE


# A
# - This option does some kind of cross-profile thingy

# EARTHQUAKE LABELS
# B FILE ZSCALE FONTSTRING
# - This option plots labels for earthquake data plotted using -z or -c
# - File format is:
# lon lat depth map datestring ID epoch fontstring justificationcode
# e.g. (154.72 -6.26 50.000000 6.1 1976-03-13T05:22:44 C031376A 195542564 10p,Helvetica,black TL)
# - FONTSTRING is a GMT format font string (e.g. 12p,Helvetica,black)

# FOCAL MECHANISMS
# C FILE ZSCALE GMT_arguments
# - This option projects focal mechanisms onto the profile using gmt psmeca
# - FILE is a text file in GMT psmeca -Sm format, extended for tectoplot:
#   X Y depth mrr mtt mff mrt mrf mtf exp newX newY ID newdepth epoch clusterID timecode
# - CMTs are plotted by calling psmeca for each track segment
# - To avoid double plotting in cases where a mechanism projects onto two
#   profile segments (as with a kinked profile), the mechanism is either plotted
#   on the first segment, or on the segment to which it is closest.

# GPS VECTORS
# D PSVELOFILE ZSCALE GMT_arguments
# - This option projects vector data onto profiles and plots data points with
#   Z equal to the profile-perpendicular component of motion.
# - Input data are in the GMT psevelo -Se format:
#   Lon Lat Vx Vy SigX SigY CorXY ID

# SCALED XYZM DATA
# E FILE ZSCALE GMT_arguments
# - This option plots XYZ data points which are scaled by M using the seismicity
#   scaling formula of tectoplot
# - FILE is a text file with columns: X(lon) Y(lat) Z(depth) M(magnitude)

# TOP TILE GRID
# G FILE ZSCALE SWATH_SUBSAMPLE_DISTANCE SWATH_D_SPACING CPT
# - This option samples a grid file along a swath and constructs a new grid
#   from the X-Y-Z samples. This grid is used to create the top tile (usually
#   terrain but could be anything) that is displayed above oblique profiles.

# REGRIDDED XYZV DATA
# I FILE ZSCALE SWATH_SUBSAMPLE_DISTANCE SWATH_D_SPACING CPT
# - This option projects XYZV data from a text file and then interpolates the
#   projected data in X'-Z' projected coordinates, displaying the result as an
#   image that is colored by the V values of the data.

# AXES LABELS
# L |Label X|Label Y|Label Z
# - This option replaces the default axes labels with those specified.
#   The labels cannot contain the | symbol

# CONTROL FLAGS
# # Various flags to affect plotting behavior e.g. USE_SHADED_RELIEF_TOPTILE or Y_UNITS
# M FLAG_NAME
# - This option sets various control flags affecting profile behavior
# - This option can be called multiple times
# Options:
# USE_SHADED_RELIEF_TOPTILE  :  Use rendered shaded relief as top tile image
# Y_UNITS                    :  Set the unit of the Y axes (REPLACED WITH L OPTION)

# PROFILE LINE DEFINITIONS
# P PROFILE_ID COLOR XOFFSET ZOFFSET LON1 LAT1 ... ... LONN LATN
# - XOFFSET/ZOFFSET can be:  non-zero float value (shift by this amount) OR
#                            0 (allow shifting to match crossing line) OR
#                            null (0 and don't allow shifting)
# - COLOR can be a R/G/B triplet or any color name recognized by GMT

# SLICE THROUGH DATA CUBE
# Q FILE NETCDFVAR RES CPT
# - This option plots an image of data sampled by cutting a data cube in
#   the specified variable (common for tomographic data, etc.)
# - NETCDFVAR is the name of a NetCDF variable in the data cube (e.g. Vs)
# - RES is output image resolution in km
# - CPT is the CPT used to color the image based on NETCDFVAR

# # RGB IMAGE PROJECTED USING DEM Z VALUES
# R DEMFILE RGBFILE ZSCALE
# - This option samples an RGB image and projects the pixels as colored circles
#   using the Z values of a colocated DEM
# - This option requires SWATH_WIDTH to be set
# - DEMFILE is a DEM
# - RGBFILE is a GeoTIFF with R,G,B as bands 0,1,2

# GRID SWATH
# S FILE ZSCALE SWATH_SUBSAMPLE_DISTANCE SWATH_D_SPACING
# - This option samples a grid file along an along-track swath and plots
#   the quantile envelopes of the binned across-track data

# GRID LINE
# T FILE ZSCALE SAMPLE_SPACING GMT_arguments
# - This option samples an input grid file along the track and plots the
#   resulting projected line.
# - SAMPLE_SPACING is the along-track sampling distance (e.g 0.1k)

# VERTICAL EXAGGERATION
# V EXAG
# - This option specifies the vertical exaggeration factor (V/H) for all profiles
# EXAG is a float without units (e.g. 1)

# GRID BOX-AND-WHISKER
# W FILE ZSCALE SWATH_SUBSAMPLE_DISTANCE SWATH_D_SPACING CPT
# - This option samples a grid file along an along-track swath and plots
#   box and whisker diagrams for the binned across-track data

# XYZ DATA
# X FILE ZSCALE GMT_arguments
# - This option plots XYZ data points without any scaling applied
# - FILE is a text file with columns: X(lon) Y(lat) Z(depth)

# XYZ POINTS CONNECTED BY LINES
# Y FILE ZSCALE GMT_arguments
# - This option projects XYZ line segments onto each profile and if all vertices
#   are within the swath draws filled circles connected by a line.

# SWATH WIDTH
# Z SWATH_WIDTH
# - This option sets the swath width for all data types and profiles
# - Argument is kilometers with the unit letter (e.g. 100k)





# PROFILE.SH FUNCTION DEFINITIONS

# project_xyz_pts_onto_track $1 $2 $3 [[$4]] [[$5]] [[$6]] [[options ...]]
#
# Arguments
# $1 = track file
# $2 = XYZ file, first 3 columns are space delimited X Y Z in geographic coordinates
# $3 = filename of output file to be written (FILE WILL BE OVERWRITTEN)
# $4 = x offset to apply to data (to align profiles)
# $5 = z offset to apply to data (to align profiles)
# $6 = zscale to multiply z values by before projecting

# If the fourth argument is a float, set xoffset (default=0)
# If the fifth argument is a float, set zoffset (default=0)
# If the sixth argument is a float, set zscale (default=1)

# This function takes a multi-segment track file, a text data file, and
# offset/scale arguments. It projects the offset/scaled XYZ data onto the trackline
# and creates a new text file with the original XYZ data replaced with the
# projected X' W' Z' coordinates.

# Options are a flag followed be required option arguments, if any

# Flag: 'remove_ends' (no arguments)
# Points that project onto either endpoint of the profile are removed.

# Flag: 'select_swath' (one argument)
# Return only points within specified distance of the track line.
# Argument is in kilometers without unit letter (e.g. 100)

# NOT IMPLEMENTED
# Flag: 'remove_w' (no arguments)
# Output is X'(km) Z'(km) [trailing fields]
# END NOT IMPLEMENTED

# Flag: 'grid_z' (one argument)
# For each point, sample grid to get Z value (prior to any Z scaling)
# This will assume input is in the form X Y [[trailing columns]] and will add
# Z value to the first column of the trailing columns.

# Flag: 'select_out' list of fields
# This flag must come LAST in the call to this function
# Set the fields that will be output before trailing text (assuming Z value is
# first part of 'trailing text'.
# Fields are:
# lon lat lonproj latproj w segnum frac xprime zprime z
# and can be in any order or repeated. If this argument is not given, then the
# previous fields are output in that order.

# NOT IMPLEMENTED
# Flag: 'nearest_profile' (two arguments)
# Project points only onto the nearest track out of a collection of tracks.
# The first argument is the current track number. The second argument is a
# multisegment line text file containing all the tracks.
# END NOT IMPLEMENTED

# INPUT: Text file with first three whitespace separated columns as
#        X(lon) Y(lat) Z(depth) [[trailing columns]]

# OUTPUT: Text file with whitespace separated columns:
#        X'(km) Z'(km) W(km) [[trailing columns]]
# X' is the offset along-track distance of the closest point
# Z' is the scaled and offset Z value
# W is the distance of a point from its closest point

# The data rows are in the same order as the input file. All data are returned
# unless 'remove_ends' or 'select_swath' options are given.

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
    echo "[project_xyz_pts_onto_track]: track file ${trackfile} does not exist"
    return 1
  fi
  shift


  xyzfile=$1
  if [[ ! -s ${xyzfile} ]]; then
    echo "[project_xyz_pts_onto_track]: XYZ file ${xyzfile} does not exist"
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


# global variables are used to keep track of the data bounds

function reset_profile_bounds() {
  profile_minx=99999
  profile_maxx=-99999
  profile_minz=99999
  profile_maxz=-99999
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


######## Start of main script logic ############################################

PROFILE_WIDTH_MAX_IN=${PROFILE_WIDTH_IN}
PROFILE_AXIS_FONT=10p,Helvetica,black
PROFILE_TITLE_FONT=10p,Helvetica,black
PROFILE_NUMBERS_FONT=10p,Helvetica,black

cat <<-EOF > ./plot_perspective_profiles.sh
#!/bin/bash
PERSPECTIVE_AZ=\${1}
PERSPECTIVE_INC=\${2}
PERSPECTIVE_EXAG=\${3}

if [[ \$# -lt 3 ]]; then
  echo "Usage: ./plot_perspective_profiles.sh [azimuth] [inclination] [vexag]"
  exit 1
fi

EOF

# THIS IS VERY DANGEROUS AND BAD AS IT AFFECTS GMT TEXT OUTPUT AS WELL AS PS OUTPUT!!!!!
OLD_FORMAT_FLOAT_OUT=$(gmt gmtget FORMAT_FLOAT_OUT)
gmt gmtset FORMAT_FLOAT_OUT "%.12f"

# Overplot all profiles onto one profile.
PSFILE="${F_PROFILES}"stacked_profiles.ps
gmt psxy -T -R -J -K -Vn > "${PSFILE}"

PFLAG="-px\${PERSPECTIVE_AZ}/\${PERSPECTIVE_INC}"
PXFLAG="-px\${PERSPECTIVE_AZ}/\${PERSPECTIVE_INC}"
RJOK="-R -J -O -K"

zeropointflag=0
xminflag=0
xmaxflag=0
zminflag=0
zmaxflag=0
ZOFFSETflag=0

XOFFSET=0
ZOFFSET=0

# Interpret the first line of the profile control file
TRACKFILE_ORIG="${MPROFFILE}"
TRACKFILE=$(echo "$(cd "$(dirname "${F_PROFILES}control_file.txt")"; pwd)/$(basename "${F_PROFILES}control_file.txt")")

# transfer the control file to the temporary directory and remove commented, blank lines
# Remove leading whitespace

grep . "${TRACKFILE_ORIG}" | grep -v "^[#]" | gawk '{$1=$1};1' > $TRACKFILE

# If we have specified profile IDS, remove lines where the second column is not one of the profiles in PSEL_LIST

if [[ $selectprofilesflag -eq 1 ]]; then
  gawk < "${TRACKFILE}" '{ if ($1 != "P") { print } }' > $TRACKFILE.tmp1
  for i in ${PSEL_LIST[@]}; do
    # echo "^[P ${i}]"
    grep "P ${i} " "${TRACKFILE}" >> "${TRACKFILE}".tmp1
  done
  cp "${TRACKFILE}".tmp1 "${TRACKFILE}"
fi

# Read the first line and check whether it is a control line
firstline=($(head -n 1 "${TRACKFILE}"))

if [[ ${firstline[0]:0:1} == "@" ]]; then
  info_msg "Found hash at start of control line"
else
  info_msg "Control file does not have @ at beginning of the first line";
  exit 1
fi

min_x="${firstline[1]}"
max_x="${firstline[2]}"
min_z="${firstline[3]}"
max_z="${firstline[4]}"


ZEROFILE="${firstline[5]}"
ZEROZ="${firstline[6]}"

if [[ -e $ZEROFILE ]]; then
  ZEROFILE_ORIG=$(echo "$(cd "$(dirname "$ZEROFILE")"; pwd)/$(basename "$ZEROFILE")")
  # rm -f /var/tmp/tectoplot/xy_intersect.txt
  ZEROFILE="${F_PROFILES}xy_intersect.txt"
  cp $ZEROFILE_ORIG $ZEROFILE
  zeropointflag=1;
fi

if [[ $min_x =~ "auto" ]]; then
  findauto=1
  xminflag=1
fi

if [[ $max_x =~ "uto" ]]; then
  findauto=1
  xmaxflag=1
fi

if [[ $min_z =~ "uto" ]]; then
  findauto=1
  zminflag=1
  zmin1to1flag=1
fi

if [[ $max_z =~ "uto" ]]; then
  findauto=1
  zmaxflag=1
  zmax1to1flag=1
fi

if [[ $ZEROZ =~ "match" ]]; then
  ZOFFSETflag=1
  info_msg "ZOFFSETflag is set... matching Z values at X=0"
fi

THIS_DIR=$(pwd)/

# PROFHEIGHT_OFFSET=$(echo "${PROFILE_HEIGHT_IN}" | gawk '{print ($1+0)/2 + 4/72}')

# Each profile is specified by an ID, an X offset, and a set of lon,lat vertices.
# ID COLOR XOFFSET lon1 lat1 lon2 lat2 ... lonN latN
# FIX: color needs to be a GMT color with a 'lightcolor' variant.

# Probably should be using -- instead of gmtset
# gmt gmtset MAP_FRAME_PEN thin,black GMT_VERBOSE n
# gmt gmtset FONT_ANNOT_PRIMARY 5p,Helvetica,black GMT_VERBOSE e

xyzfilelist=()
xyzcommandlist=()

# Default units are X=Y=Z=km. Use L command to update labels.
x_axis_label="${PROFILE_X_LABEL}"
y_axis_label="${PROFILE_Y_LABEL}"
z_axis_label="${PROFILE_Z_LABEL}"

# This is for  the old way of looping through the file
k=$(wc -l < $TRACKFILE)

# Determine the swath width from the Z command while also constructing the
# buffer file containing all tracks

while read thisline; do
  thisarray=($(echo $thisline))
  case ${thisline:0:1} in
    P|A)
      # Construct a file containing all profile lines for use in data selection
      echo ">" >> ${F_PROFILES}line_buffer.txt
      echo $thisline | cut -f 6- -d ' ' | xargs -n 2 >> ${F_PROFILES}line_buffer.txt
    ;;
    Z)
      if arg_is_km ${thisarray[1]}; then
        MAXWIDTH_KM=$(gawk -v v=${thisarray[1]} 'BEGIN{ print v+0 }')
      fi
      # echo ${thisarray[1]} >> ${F_PROFILES}widthlist.txt
    ;;
    #
    # S|G)
    #   echo ${thisarray[4]} >> ${F_PROFILES}widthlist.txt
    # ;;
    # X|E|C|B)
    #   echo ${thisarray[2]} >> ${F_PROFILES}widthlist.txt
    # ;;
  esac
done < ${TRACKFILE}

# If there are no swath-type data requests, set a nominal width of 1 km
if [[ -z ${MAXWIDTH_KM} ]]; then
  info_msg "No swath data in profile control file; setting to 1 km"
  MAXWIDTH_KM=1
fi


# Search for, parse, and pre-process datasets to be plotted

i=0
while read thisline; do
  ((i++))
  comcode=${thisline:0:1}
  myarr=($(echo $thisline))

  case $comcode in
    R) # Project georeferenced RGB image cells onto profile using specified DEM heights
      imageidnum[$i]=$(echo "image${i}")
      imagedemlist[$i]=$(echo "$(cd "$(dirname "${myarr[1]}")"; pwd)/$(basename "${myarr[1]}")")
      imagefilelist[$i]=$(echo "$(cd "$(dirname "${myarr[2]}")"; pwd)/$(basename "${myarr[2]}")")
      imagefilesellist[$i]=$(echo "cut_${i}_$(basename "${myarr[1]}")")
      imagezscalelist[$i]="${myarr[3]}"
      # imagewidthlist[$i]="${myarr[4]}"
      imagewidthlist[$i]="${MAXWIDTH_KM}"
    ;;
    L)
      # L changes aspects of plot axis labels
      # Remove leading and trailing whitespaces from the axis labels
      x_axis_label=$(echo $thisline | gawk -F'|' '{gsub(/^[ \t]+/,"",$2);gsub(/[ \t]+$/,"",$2); split($1,a," "); print substr($1,2, length($1)-1)}')
      echo x_axis_label is ${x_axis_label}
      y_axis_label=$(echo $thisline | tail -n 1 | gawk -F'|' '{gsub(/^[ \t]+/,"",$2);gsub(/[ \t]+$/,"",$2);print $2}')
      echo y_axis_label is ${y_axis_label}

      z_axis_label=$(echo $thisline | tail -n 1 | gawk -F'|' '{gsub(/^[ \t]+/,"",$2);gsub(/[ \t]+$/,"",$2);print $3}')
      echo z_axis_label is ${z_axis_label}

      right_z_axis_label=$(echo $thisline | tail -n 1 | gawk -F'|' '{gsub(/^[ \t]+/,"",$2);gsub(/[ \t]+$/,"",$2);print $4}')
      echo right axis label is ${right_z_axis_label}
    ;;
    V)
      # V changes the vertical exaggeration of perspective plots
      PERSPECTIVE_EXAG="${myarr[1]}"
    ;;
    M)
      case ${myarr[1]} in
        USE_SHADED_RELIEF_TOPTILE) USE_SHADED_RELIEF_TOPTILE=1 ;;
        Y_UNITS) Y_UNIT_LABEL=1; Y_UNITS="${myarr[2]}"
      esac
      # # M sets various flags
      # if [[ "${myarr[1]}" =~ "USE_SHADED_RELIEF_TOPTILE" ]]; then
      #   USE_SHADED_RELIEF_TOPTILE=1
      # fi
      # if [[ "${myarr[1]}" =~ "Y_UNITS" ]]; then
      #   Y_UNIT_LABEL=1
      #   Y_UNITS="${myarr[2]}"
      # fi

    ;;
    B)
      # B plots labels from an XYZ+text format file

      LABEL_FILE_P=$(echo "$(cd "$(dirname "${myarr[1]}")"; pwd)/$(basename "${myarr[1]}")")
      LABEL_FILE_SEL=$(echo "${F_PROFILES}label_$(basename "${myarr[1]}")")

      # Remove lines that don't start with a number or a minus sign. Doesn't handle plus signs...
      # Store in a file called label_X where X is the basename of the source data file.

      # This command is screwing up for eqlist somehow...
      gawk < $LABEL_FILE_P '
      {
        printf("%s %s \"", $1, $2)
        for(i=3;i<=NF;i++) {
          printf("%s ", $(i))
        }
        printf("\"\n")
      }' | gmt select -fg -L${F_PROFILES}line_buffer.txt+d"${myarr[2]}" | sed 's/\"//g' > $LABEL_FILE_SEL

      info_msg "Selecting labels in file $LABEL_FILE_P within buffer distance ${myarr[2]}: to $LABEL_FILE_SEL"
      labelfilelist[$i]=$LABEL_FILE_SEL

      # In this case, the width given must be divided by two.
      labelwidthlistfull[$i]="${myarr[2]}"
      labelwidthlist[$i]=$(echo "${myarr[2]}" | gawk '{ print ($1+0)/2 substr($1,length($1),1) }')
      labelunitlist[$i]="${myarr[3]}"
      labelfontlist[$i]=$(echo "${myarr[@]:4}")
    ;;
    Q)
      # Q defines a 3D NetCDF grid that will be cut using grdinterpolate
      # Q 3DGRIDFILE DATATYPE RES CPT
      threedgrididnum[$i]=$(echo "3dgrid${i}")
      threedgridfilelist[$i]=$(echo "$(cd "$(dirname "${myarr[1]}")"; pwd)/$(basename "${myarr[1]}")")
      threeddatatype[$i]="${myarr[2]}"      # The name of the NetCDF z variable (e.g. vs)
      threedres[$i]="${myarr[3]}"           # Sampling resolution for the vertical profile (e.g. 1k)
      threedcptlist[$i]="${myarr[4]}"           # Optional CPT file or cpt name
    ;;
    S|G|W)
      # S is swath profile visualized as quantile envelopes
      # G is a grid displayed at a top tile on oblique profiles
      # W is a box-and-whisker visualization
      # 1        2     3   4
      # GRIDFILE 0.001 .1k 0.1k
      grididnum[$i]=$(echo "grid${i}")
      gridfilelist[$i]=$(echo "$(cd "$(dirname "${myarr[1]}")"; pwd)/$(basename "${myarr[1]}")")
      gridfilesellist[$i]=$(echo "cut_${i}_$(basename "${myarr[1]}")")
      gridzscalelist[$i]="${myarr[2]}"
      gridspacinglist[$i]=$(echo "${myarr[3]}" | gawk '{print $1+0}')
      # gridwidthlist[$i]="${myarr[4]}"
      gridwidthlist[$i]="${MAXWIDTH_KM}"
      gridsamplewidthlist[$i]=$(echo "${myarr[4]}" | gawk '{print $1+0}')
      # gridsamplewidthlist[$i]="${myarr[5]}"

      # Record the type of grid being used
      gridtypelist[$i]=$comcode

      # If this is a top tile grid, we can specify its cpt here and scale its values by gridzscalelist[$i].
      if [[ $comcode == "G" ]]; then
        istopgrid[$i]=1
        if [[ -z "${myarr[5]}" ]]; then
          info_msg "No CPT specified for topgrid..."
        else
          replace_gmt_colornames_rgb "${myarr[5]}" > ${F_CPTS}topgrid_${i}.cpt
          if [[ "${myarr[6]}" =~ "scale" ]]; then
            info_msg "Scaling CPT Z values for topgrid."
            scale_cpt ${F_CPTS}topgrid_${i}.cpt ${gridzscalelist[$i]} > ${F_CPTS}topgrid_${i}_scale.cpt
            gridcptlist[$i]=${F_CPTS}topgrid_${i}_scale.cpt
          else
            gridcptlist[$i]=${F_CPTS}topgrid_${i}.cpt
          fi
        fi
        info_msg "Loading top grid: ${gridfilelist[$i]}: Zscale ${gridzscalelist[$i]}, Spacing: ${gridspacinglist[$i]}, Width: ${gridwidthlist[$i]}, SampWidth: ${gridsamplewidthlist[$i]}"
      elif [[ $comcode == "W" ]]; then
        if [[ -z "${myarr[5]}" ]]; then
          info_msg "No CPT specified for box and whisker grid."
          gridcptlist[$i]="None"
        else
          replace_gmt_colornames_rgb "${myarr[5]}" > ${F_CPTS}boxgrid_${i}.cpt
          if [[ "${myarr[6]}" =~ "scale" ]]; then
            info_msg "Scaling CPT Z values for boxgrid."
            scale_cpt ${F_CPTS}boxgrid_${i}.cpt ${gridzscalelist[$i]} > ${F_CPTS}boxgrid_${i}_scale.cpt
            gridcptlist[$i]=${F_CPTS}boxgrid_${i}_scale.cpt
          else
            gridcptlist[$i]=${F_CPTS}boxgrid_${i}.cpt
          fi
        fi
        info_msg "Loading box grid: ${gridfilelist[$i]}: Zscale ${gridzscalelist[$i]}, Spacing: ${gridspacinglist[$i]}, Width: ${gridwidthlist[$i]}, SampWidth: ${gridsamplewidthlist[$i]}"
      else
        info_msg "Loading non-top grid: ${gridfilelist[$i]}: Zscale ${gridzscalelist[$i]}, Spacing: ${gridspacinglist[$i]}, Width: ${gridwidthlist[$i]}, SampWidth: ${gridsamplewidthlist[$i]}"
      fi
    ;;
    T)
      # T is a grid sampled along a track line
      ptgrididnum[$i]=$(echo "ptgrid${i}")
      ptgridfilelist[$i]=$(echo "$(cd "$(dirname "${myarr[1]}")"; pwd)/$(basename "${myarr[1]}")")
      ptgridfilesellist[$i]=$(echo "cut_$(basename "${myarr[1]}")")
      ptgridzscalelist[$i]="${myarr[2]}"
      ptgridspacinglist[$i]="${myarr[3]}"
      ptgridcommandlist[$i]=$(echo "${myarr[@]:4}")

      info_msg "Loading single track sample grid: ${ptgridfilelist[$i]}: Zscale: ${ptgridzscalelist[$i]} Spacing: ${ptgridspacinglist[$i]}"

      # If the AOI has a MAXLON which is less than 180°, grdedit -L+n the source file.
      # This is likely bad practice as we don't want to edit original data, but for Slab2.0
      # this seems to be needed and copying grids is annoying.

      if [[ $(echo "${MAXLON} < 180" | bc) -eq 1 ]]; then
        gmt grdedit -L+n ${ptgridfilelist[$i]}
        changebackflag=1
      else
        gmt grdedit -L+p ${ptgridfilelist[$i]}
      fi

      # Cut the grid to the AOI and multiply by its ZSCALE
      # If the grid doesn't fall within the buffer AOI, there will be no result but it won't be a problem, so pipe error to /dev/null

      rm -f ${F_PROFILES}tmp.nc

      if [[ $changebackflag -eq 1 ]]; then
        gmt grdedit -L+p ${ptgridfilelist[$i]}
      fi

      # Record the data type
      echo "T grid: ${F_PROFILES}${ptgridfilesellist[$i]} (now ${ptgridfilelist[$i]}) " >> ${F_PROFILES}data_id.txt
    ;;
    X|E|I)
      # X is a generic xyz dataset
      # E is an earthquake XYZM dataset
      # D is a vector dataset in GMT psvelo format (extended)
      # I is XYZV data that will be gridded and displayed using grdimage (e.g. tomography)

      FILE_P=$(echo "$(cd "$(dirname "${myarr[1]}")"; pwd)/$(basename "${myarr[1]}")")
      FILE_SEL=$(echo "${F_PROFILES}crop_$(basename "${myarr[1]}")")

      # Remove lines that don't start with a number or a minus sign before processing.
      grep "^[-*0-9]" $FILE_P | gmt select -f0x,1y,s -o0,1,t -L${F_PROFILES}line_buffer.txt+d"${MAXWIDTH_KM}k" > $FILE_SEL

      info_msg "Selecting data in file $FILE_P within buffer distance ${MAXWIDTH_KM}k: to $FILE_SEL"
      xyzfilelist[$i]=$FILE_SEL

      # In this case, the width given must be divided by two.
      # xyzwidthlistfull[$i]="${myarr[2]}"
      # xyzwidthlist[$i]=$(echo "${myarr[2]}" | gawk '{ print ($1+0)/2 substr($1,length($1),1) }')

      xyzwidthlist[$i]="${MAXWIDTH_KM}"

      xyzunitlist[$i]="${myarr[2]}"
      xyzcommandlist[$i]=$(echo "${myarr[@]:3}")

      # We mark the seismic data that are subject to rescaling (or any data with a scalable fourth column...)
      [[ $comcode == "E" ]] && xyzscaleeqsflag[$i]=1
      # We mark the data that we want to grid for display (tomography)
      if [[ $comcode == "I" ]]; then
        xyzgridflag[$i]=1
        if [[ "${myarr[4]}" == *.cpt ]]; then
          xyzgridcptflag[$i]=1
          xyzgridcptlist[$i]="${myarr[4]}"
        fi
      fi
    ;;
    C)
      # C loads a focal mechanism dataset
      cmtfileflag=1
      cmtfilelist[$i]=$(echo "$(cd "$(dirname "${myarr[1]}")"; pwd)/$(basename "${myarr[1]}")")
      cmtwidthlist[$i]="${MAXWIDTH_KM}"
      cmtscalelist[$i]="${myarr[2]}"
      cmtcommandlist[$i]=$(echo "${myarr[@]:3}")
    ;;
    D)
      echo loading vector file ${myarr[1]} for profiling
      vectorfilelist[$i]=$(echo "$(cd "$(dirname "${myarr[1]}")"; pwd)/$(basename "${myarr[1]}")")
      vectorwidthlist[$i]="${MAXWIDTH_KM}"
      vectorscalelist[$i]="${myarr[2]}"
      vectorcommandlist[$i]=$(echo "${myarr[@]:3}")
    ;;
  esac
done < $TRACKFILE


################################################################################
################################################################################
# Profile plotting

# Process the profile tracks one by one, in the order that they appear in the
# control file. Keep track of which profile we are working on. (first=0)

PROFILE_INUM=0

while read thisline; do
  comcode=${thisline:0:1}
  myarray=($(echo $thisline))

  # Perform tasks common to both types of profile

  case $comcode in
    P|A)
    LINEID=${myarray[1]}
    COLOR=${myarray[2]}
    XOFFSET=${myarray[3]}
    ZOFFSET=${myarray[4]}

    COLOR=$(grep ^"$COLOR " $GMTCOLORS | head -n 1 | gawk '{print $2}')

    LIGHTCOLOR=$(echo $COLOR | gawk -F/ '{
      printf "%d/%d/%d", (255-$1)*0.25+$1,  (255-$2)*0.25+$2, (255-$3)*0.25+$3
    }')
    LIGHTERCOLOR=$(echo $COLOR | gawk -F/ '{
      printf "%d/%d/%d", (255-$1)*0.5+$1,  (255-$2)*0.5+$2, (255-$3)*0.5+$3
    }')

    # Initialize the profile plot script
    echo "#!/bin/bash" > ${F_PROFILES}${LINEID}_profile.sh

    # Create the profile trackfile
    echo $thisline | cut -f 6- -d ' ' | xargs -n 2 > ${F_PROFILES}${LINEID}_trackfile.txt
    echo ${F_PROFILES}${LINEID}_trackfile.txt >> ${F_PROFILES}tracklist.txt

    # Calculate the incremental length along profile between points
    gmt mapproject ${F_PROFILES}${LINEID}_trackfile.txt -G+uk+i | gawk '{print $3}' > ${F_PROFILES}${LINEID}_dist_km.txt

    cleanup ${F_PROFILES}${LINEID}_dist_km.txt

    # Calculate the total along-track length of the profile
    PROFILE_LEN_KM=$(gawk < ${F_PROFILES}${LINEID}_dist_km.txt 'BEGIN{val=0}{val=val+$1}END{print val}')
    PROFILE_XMIN=0
    PROFILE_XMAX=$PROFILE_LEN_KM

    # Pair the data points using a shift and paste.
  	sed 1d < ${F_PROFILES}${LINEID}_trackfile.txt > ${F_PROFILES}shift1_${LINEID}_trackfile.txt
  	paste ${F_PROFILES}${LINEID}_trackfile.txt ${F_PROFILES}shift1_${LINEID}_trackfile.txt | grep -v "\s>" > ${F_PROFILES}geodin_${LINEID}_trackfile.txt

    cleanup ${F_PROFILES}shift1_${LINEID}_trackfile.txt
    cleanup ${F_PROFILES}geodin_${LINEID}_trackfile.txt

    # Script to return azimuth and midpoint between a pair of input points.
    # Comes within 0.2 degrees of geod() results over large distances, while being symmetrical which geod isn't
    # We need perfect midpoint symmetry in order to create exact point pairs in adjacent polygons

    # Note: this calculates the NORMAL DIRECTION to the profile and not its AZIMUTH

    gawk < ${F_PROFILES}geodin_${LINEID}_trackfile.txt -v width="${MAXWIDTH_KM}" -v color="${COLOR}" -v lineid=${LINEID} '
        function acos(x) { return atan2(sqrt(1-x*x), x) }
        {
            lon1 = $1*3.14159265358979/180
            lat1 = $2*3.14159265358979/180
            lon2 = $3*3.14159265358979/180
            lat2 = $4*3.14159265358979/180
            Bx = cos(lat2)*cos(lon2-lon1);
            By = cos(lat2)*sin(lon2-lon1);
            latMid = atan2(sin(lat1)+sin(lat2), sqrt((cos(lat1)+Bx)*(cos(lat1)+Bx)+By*By));
            lonMid = lon1+atan2(By, cos(lat1)+Bx);
            theta = atan2(sin(lon2-lon1)*cos(lat2), cos(lat1)*sin(lat2)-sin(lat1)*cos(lat2)*cos(lon2-lon1));
            printf "%.5f %.5f %.3f\n", lonMid*180/3.14159265358979, latMid*180/3.14159265358979, (theta*180/3.14159265358979+360-90)%360;
            # Print the back-projection to end_points.txt
            theta = atan2(sin(lon1-lon2)*cos(lat1), cos(lat2)*sin(lat1)-sin(lat2)*cos(lat1)*cos(lon1-lon2))
            print $3, $4, (theta*180/3.14159265358979+180-90)%360, width, color, lineid >> "my_end_points.txt"
        }' > ${F_PROFILES}az_${LINEID}_trackfile.txt

        if [[ -s my_end_points.txt ]]; then
          tail -n 2 my_end_points.txt | head -n 1 > ${F_PROFILES}${LINEID}_end.txt
          tail -n 2 my_end_points.txt | head -n 1 >> end_points.txt
          # rm -f my_end_points.txt
        fi

    paste ${F_PROFILES}${LINEID}_trackfile.txt ${F_PROFILES}az_${LINEID}_trackfile.txt > ${F_PROFILES}jointrack_${LINEID}.txt

    # The azimuth of the profile is the azimuth of its first segment.

    THISP_AZ=$(head -n 1 ${F_PROFILES}az_${LINEID}_trackfile.txt | gawk '{print $3}')

    LINETOTAL=$(wc -l < ${F_PROFILES}jointrack_${LINEID}.txt)
    cat ${F_PROFILES}jointrack_${LINEID}.txt | gawk -v width="${MAXWIDTH_KM}" -v color="${COLOR}" -v lineval="${LINETOTAL}" -v folderid=${F_PROFILES} -v lineid=${LINEID} '
      (NR==1) {
        print $1, $2, $5, width, color, lineid >> "start_points.txt"
        lastval=$5
      }
      (NR>1 && NR<lineval) {
        diff = ( ( $5 - lastval + 180 + 360 ) % 360 ) - 180
        angle = (360 + lastval + ( diff / 2 ) ) % 360
        print $1, $2, angle, width, color, lineid >> "mid_points.txt"
        lastval=$5
      }
      # END {
      #   filename=sprintf("%s%s_end.txt", folderid, lineid)
      #   print $1, $2, $5, width, color, folderid >> filename
      #   print $1, $2, $5, width, color, lineid >> "end_points.txt"
      # }
      '

      tail -n 1 start_points.txt > ${F_PROFILES}${LINEID}_begin.txt


      # We build profile buffers by buffering individual segments projected into
      # the UTM Zone of their centroid location, merging the buffers, and
      # cutting off the rounded endcaps.

      # If a profile segment spans too much longitude range, the UTM buffer will
      # likely be distorted.

#
#
#
#     # We use a UTM projection to accomplish the buffering unless the track spans
#     # a greater longitude range than a certain amount. In that case, we should use
#     # a different projection or split the line segment into smaller parts and
#     # project each one separately and then dissolve the resulting polygons?
#
#     # Determine the UTM zone from the track file centroid
#     trackcentroid=($(gmt spatial ${F_PROFILES}${LINEID}_trackfile.txt -Q))
#
#     UTMZONE_EPSG=$(gawk -v v=${trackcentroid[0]} '
#       BEGIN {
#         while (v>180) { v=v-360 }
#         u=(v+180)/6
#         val=int(u)+(u>int(u))
#         printf("326%02d\n", (val>0)?val:1, val)
#       }')
#
#
#
#
#     # Create the trackfile buffer polygon in JSON format to use as a cutline
#
# cat <<-EOF > ${F_PROFILES}${LINEID}_trackfile.gmt
# # @VGMT1.0
# # REGION_STUB
# # @Je4326
# # @Jp"+proj=longlat +datum=WGS84 +no_defs"
# # @Jw"GEOGCS[\"WGS 84\",DATUM[\"WGS_1984\",SPHEROID[\"WGS 84\",6378137,298.257223563,AUTHORITY[\"EPSG\",\"7030\"]],AUTHORITY[\"EPSG\",\"6326\"]],PRIMEM[\"Greenwich\",0,AUTHORITY[\"EPSG\",\"8901\"]],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]],AXIS[\"Latitude\",NORTH],AXIS[\"Longitude\",EAST],AUTHORITY[\"EPSG\",\"4326\"]]"
# # @GLINESTRING
# # FEATURE_DATA
# >
# EOF
#
#     cat ${F_PROFILES}${LINEID}_trackfile.txt >> ${F_PROFILES}${LINEID}_trackfile.gmt
#     ogr2ogr -f "GeoJSON" ${F_PROFILES}${LINEID}_trackfile.json ${F_PROFILES}${LINEID}_trackfile.gmt
#
#     # This currently works with miniconda environment (14 Jan 2022) but fails with a fresh homebrew installation with Bus Error: 10
#     ogr2ogr -f "GeoJSON" ${F_PROFILES}${LINEID}_trackfile_buffer.json ${F_PROFILES}${LINEID}_trackfile.json -dialect sqlite -sql "SELECT ST_transform(ST_buffer(ST_transform(geometry, ${UTMZONE_EPSG}), $(echo ${MAXWIDTH_KM} | gawk '{print ($1+0)/2*1000}'), 30), 4326) as geometry FROM ${LINEID}_trackfile"
#
#
#     # TEST alternative
#
#     rm ${F_PROFILES}${LINEID}_trackfile_buffer.json

    # # if [[ -s ${F_PROFILES}${LINEID}_trackfile_buffer.json ]]; then
    #   ogr2ogr -f "OGR_GMT" ${F_PROFILES}${LINEID}_trackfile_buffer.gmt ${F_PROFILES}${LINEID}_trackfile_buffer.json
    #   gawk < ${F_PROFILES}${LINEID}_trackfile_buffer.gmt '($1+0==$1) { print }' > ${F_PROFILES}${LINEID}_trackfile_buffer.txt
    #
    #   # Calculate the incremental distance between points along the buffer line
    #   gmt mapproject ${F_PROFILES}${LINEID}_trackfile_buffer.txt -G+i > ${F_PROFILES}${LINEID}_trackfile_buffer_incdist.txt
    #
    #     # Calculate the distance of each point from the first profile point
    #   firstpoint=($(head -n 1 ${F_PROFILES}${LINEID}_trackfile.txt))
    #   lastpoint=($(tail -n 1 ${F_PROFILES}${LINEID}_trackfile.txt))
    #
    #   gmt mapproject ${F_PROFILES}${LINEID}_trackfile_buffer.txt -G${firstpoint[0]}/${firstpoint[1]} -o2 > ${F_PROFILES}${LINEID}_trackfile_buffer_dist1.txt
    #   gmt mapproject ${F_PROFILES}${LINEID}_trackfile_buffer.txt -G${lastpoint[0]}/${lastpoint[1]} -o2 > ${F_PROFILES}${LINEID}_trackfile_buffer_distN.txt
    #
    #   paste ${F_PROFILES}${LINEID}_trackfile_buffer_incdist.txt ${F_PROFILES}${LINEID}_trackfile_buffer_dist1.txt ${F_PROFILES}${LINEID}_trackfile_buffer_distN.txt > ${F_PROFILES}${LINEID}_trackfile_buffer_calc.txt
    #
    #   # Remove the end cap circles. Assumes the GMT behavior which is that the
    #   # first point is always adjacent to a long segment and should be kept
    #
    #   gawk < ${F_PROFILES}${LINEID}_trackfile_buffer_calc.txt '
    #     function ceil(x)       { return int(x)+(x>int(x))       }
    #     BEGIN {
    #       firstprint=1
    #     }
    #     {
    #       # inc is the increment between the previous point and this one
    #       lon[FNR]=$1
    #       lat[FNR]=$2
    #       inc[FNR]=$3;
    #       incsac[FNR]=$3
    #       distsac[FNR]=$4
    #       dist1[FNR]=$4
    #       dist2[FNR]=$5
    #     }
    #     END {
    #       # Find the typical spacing between arc points, which will depend on
    #       # the buffer width and the number of points per quadrant
    #       asort(incsac)
    #       asort(distsac)
    #       # First increment is 0, so use
    #       minval=incsac[2]
    #
    #       # Instead we expect many more small segments than large so we use
    #       # the lower first quantile
    #       # print "NR", NR , "NR/2", NR/2, "ceil", ceil(NR/2) > "/dev/stderr"
    #       thiskey=ceil(NR/2)
    #       # print thiskey > "/dev/stderr"
    #
    #       # for (key in incsac) {
    #       #   print key, incsac[key] > "/dev/stderr"
    #       # }
    #       minval=incsac[thiskey]
    #
    #       # minimum distance is approximately the buffer width
    #       mindist=distsac[1]
    #
    #       # print "minval:", minval, "mindist:", mindist > "/dev/stderr"
    #
    #       for(i=1;i<NR;++i) {
    #         # If the point has a long segment on either side, print it
    #         # print minval*1.5, inc[i], mindist*1.5, dist1[i], dist2[i] > "/dev/stderr"
    #         if (inc[i]>minval*1.5 || inc[i+1]>minval*1.5 || inc[i]+0==0) {
    #           # print "has large segment or is first point" > "/dev/stderr"
    #           if (firstprint==1) {
    #             firstlon=lon[i]
    #             firstlat=lat[i]
    #             firstprint=0
    #           }
    #           print lon[i], lat[i]
    #         } else {
    #           # If the point has short side segments but is farther than
    #           # the buffer distance from both of the end points
    #           if (dist1[i]>=mindist*1.1 && dist2[i]>=mindist*1.1) {
    #             # print "is far enough from both end points" > "/dev/stderr"
    #             if (firstprint==1) {
    #               firstlon=lon[i]
    #               firstlat=lat[i]
    #               firstprint=0
    #             }
    #             print lon[i], lat[i]
    #           }
    #         # else {
    #         #     print "didnt pass print requirements" > "/dev/stderr"
    #         #   }
    #         }
    #       }
    #       # Connect the first and last plotted points to close the polygon
    #       print firstlon, firstlat
    #
    #     }' > ${F_PROFILES}${LINEID}_trackfile_final_buffer.txt
    #
    #
    # else
    #
    # echo "Calculation of buffer polygon for ${LINEID} failed. Trying segmentation approach."

    # If the track is too long, then a single UTM zone cannot be used,
    # so split it into 500 km long segments.

    if [[ $(echo "${PROFILE_LEN_KM} > 500" | bc) -eq 1 ]]; then
      info_msg "Need to subsample track in order to buffer ${LINEID}"
      gmt sample1d ${F_PROFILES}${LINEID}_trackfile.txt -Af -T500k > ${F_PROFILES}${LINEID}_trackfile_subsample.txt
      trackfiletouse=${F_PROFILES}${LINEID}_trackfile_subsample.txt
    else
      trackfiletouse=${F_PROFILES}${LINEID}_trackfile.txt
    fi

    # We need to create buffers for each polyline segment and merge them together
    # because ogr2ogr is giving a Bus Error: 10 with my current installation
cat <<-EOF > ${F_PROFILES}${LINEID}_trackfile_merged_buffers.gmt
# @VGMT1.0
# REGION_STUB
# @Je4326
# @Jp"+proj=longlat +datum=WGS84 +no_defs"
# @Jw"GEOGCS[\"WGS 84\",DATUM[\"WGS_1984\",SPHEROID[\"WGS 84\",6378137,298.257223563,AUTHORITY[\"EPSG\",\"7030\"]],AUTHORITY[\"EPSG\",\"6326\"]],PRIMEM[\"Greenwich\",0,AUTHORITY[\"EPSG\",\"8901\"]],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]],AXIS[\"Latitude\",NORTH],AXIS[\"Longitude\",EAST],AUTHORITY[\"EPSG\",\"4326\"]]"
# @GPOLYGON
# FEATURE_DATA
EOF

      numprofpts=$(wc -l < ${trackfiletouse})
      numsegs=$(echo "$numprofpts - 1" | bc)

      for segind in $(seq 1 $numsegs); do
        segind_p=$(echo "$segind + 1" | bc -l)

        p1_x=$(cat ${trackfiletouse} | head -n ${segind} | tail -n 1 | gawk 'BEGIN { OFMT="%.12f"} {print $1}')
        p1_z=$(cat ${trackfiletouse} | head -n ${segind} | tail -n 1 | gawk 'BEGIN { OFMT="%.12f"} {print $2}')
        p2_x=$(cat ${trackfiletouse} | head -n ${segind_p} | tail -n 1 | gawk 'BEGIN { OFMT="%.12f"} {print $1}')
        p2_z=$(cat ${trackfiletouse} | head -n ${segind_p} | tail -n 1 | gawk 'BEGIN { OFMT="%.12f"} {print $2}')

        echo ${p1_x} ${p1_z} > piece_${segind}.txt
        echo ${p2_x} ${p2_z} >> piece_${segind}.txt

        # Determine the UTM zone from the track file centroid
        trackcentroid=($(gmt spatial piece_${segind}.txt -Q))

        UTMZONE_EPSG=$(gawk -v v=${trackcentroid[0]} '
          BEGIN {
            while (v>180) { v=v-360 }
            u=(v+180)/6
            val=int(u)+(u>int(u))
            printf("326%02d\n", (val>0)?val:1, val)
          }')

        # echo "segment ${segind} is UTM Zone ${UTMZONE_EPSG}"
        gdaltransform -s_srs EPSG:4326 -t_srs EPSG:${UTMZONE_EPSG} -output_xy < piece_${segind}.txt > piece_${segind}_trackfile_utm.txt
        gmt spatial piece_${segind}_trackfile_utm.txt -i0,1 -Sb$(echo ${MAXWIDTH_KM} | gawk '{print ($1+0)/2*1000}') | tr '\t' ' ' > piece_${segind}_trackfile_utm_buffer.txt
        gdaltransform -s_srs EPSG:${UTMZONE_EPSG} -t_srs EPSG:4326 -output_xy < piece_${segind}_trackfile_utm_buffer.txt > piece_${segind}_trackfile_buffer.txt

        echo ">" >> ${F_PROFILES}${LINEID}_trackfile_merged_buffers.gmt
        cat piece_${segind}_trackfile_buffer.txt >> ${F_PROFILES}${LINEID}_trackfile_merged_buffers.gmt
        rm -f piece_${segind}_trackfile_buffer.txt
      done

      ogr2ogr -f "GeoJSON" ${F_PROFILES}${LINEID}_trackfile_buffer.json ${F_PROFILES}${LINEID}_trackfile_merged_buffers.gmt
      gawk < ${F_PROFILES}${LINEID}_trackfile_merged_buffers.gmt '($1+0==$1 || $1==">") { print }' > ${F_PROFILES}${LINEID}_trackfile_buffer.txt

      cp ${F_PROFILES}${LINEID}_trackfile_buffer.txt ${F_PROFILES}${LINEID}_trackfile_final_buffer.txt

      ogr2ogr -f "GeoJSON" ${F_PROFILES}${LINEID}_trackfile_merged_buffers.json ${F_PROFILES}${LINEID}_trackfile_merged_buffers.gmt

      ogr2ogr ${F_PROFILES}${LINEID}_trackfile_dissolved_buffers.json ${F_PROFILES}${LINEID}_trackfile_merged_buffers.json -dialect sqlite -sql "SELECT ST_Union(geometry) FROM ${LINEID}_trackfile_merged_buffers"

      ogr2ogr -f "OGR_GMT" ${F_PROFILES}${LINEID}_trackfile_dissolved_buffers.gmt ${F_PROFILES}${LINEID}_trackfile_dissolved_buffers.json
      gawk < ${F_PROFILES}${LINEID}_trackfile_dissolved_buffers.gmt '($1+0==$1) { print }' > ${F_PROFILES}${LINEID}_trackfile_dissolved_buffers.txt

cleanup ${F_PROFILES}${LINEID}_trackfile_buffer.txt ${F_PROFILES}${LINEID}_trackfile_dissolved_buffers.gmt ${F_PROFILES}${LINEID}_trackfile_dissolved_buffers.json ${F_PROFILES}${LINEID}_trackfile_merged_buffers.gmt


      # # One method is to try to remove points that are in the endcap vs points
      # # that are not.
      #
      #
      #
      # # Calculate the incremental distance between points along the buffer line
      # gmt mapproject ${F_PROFILES}${LINEID}_trackfile_dissolved_buffers.txt -G+i > ${F_PROFILES}${LINEID}_trackfile_buffer_incdist.txt
      #
      #   # Calculate the distance of each point from the first profile point
      # firstpoint=($(head -n 1 ${F_PROFILES}${LINEID}_trackfile.txt))
      # lastpoint=($(tail -n 1 ${F_PROFILES}${LINEID}_trackfile.txt))
      #
      # gmt mapproject ${F_PROFILES}${LINEID}_trackfile_dissolved_buffers.txt -G${firstpoint[0]}/${firstpoint[1]} -o2 > ${F_PROFILES}${LINEID}_trackfile_buffer_dist1.txt
      # gmt mapproject ${F_PROFILES}${LINEID}_trackfile_dissolved_buffers.txt -G${lastpoint[0]}/${lastpoint[1]} -o2 > ${F_PROFILES}${LINEID}_trackfile_buffer_distN.txt
      #
      # paste ${F_PROFILES}${LINEID}_trackfile_buffer_incdist.txt ${F_PROFILES}${LINEID}_trackfile_buffer_dist1.txt ${F_PROFILES}${LINEID}_trackfile_buffer_distN.txt > ${F_PROFILES}${LINEID}_trackfile_buffer_calc.txt
      #
      # gawk < ${F_PROFILES}${LINEID}_trackfile_buffer_calc.txt '
      #   function ceil(x)       { return int(x)+(x>int(x))       }
      #   BEGIN {
      #     firstprint=1
      #   }
      #   {
      #     # inc is the increment between the previous point and this one
      #     lon[FNR]=$1
      #     lat[FNR]=$2
      #     inc[FNR]=$3;
      #     incsac[FNR]=$3
      #     distsac[FNR]=$4
      #     dist1[FNR]=$4
      #     dist2[FNR]=$5
      #   }
      #   END {
      #     # Find the typical spacing between arc points, which will depend on
      #     # the buffer width and the number of points per quadrant
      #     asort(incsac)
      #     asort(distsac)
      #     # First increment is 0, so use
      #     minval=incsac[2]
      #
      #     # Instead we expect many more small segments than large so we use
      #     # the lower first quantile
      #     # print "NR", NR , "NR/2", NR/2, "ceil", ceil(NR/2) > "/dev/stderr"
      #     thiskey=ceil(NR/2)
      #     # print thiskey > "/dev/stderr"
      #
      #     # for (key in incsac) {
      #     #   print key, incsac[key] > "/dev/stderr"
      #     # }
      #     minval=incsac[thiskey]
      #
      #     # minimum distance is approximately the buffer width
      #     mindist=distsac[1]
      #
      #     # print "minval:", minval, "mindist:", mindist > "/dev/stderr"
      #
      #     for(i=1;i<NR;++i) {
      #       # If the point has a long segment on either side, print it
      #       # print minval*1.5, inc[i], mindist*1.5, dist1[i], dist2[i] > "/dev/stderr"
      #       if (inc[i]>minval*1.5 || inc[i+1]>minval*1.5 || inc[i]+0==0) {
      #         # print "has large segment or is first point" > "/dev/stderr"
      #         if (firstprint==1) {
      #           firstlon=lon[i]
      #           firstlat=lat[i]
      #           firstprint=0
      #         }
      #         print lon[i], lat[i]
      #       } else {
      #         # If the point has short side segments but is farther than
      #         # the buffer distance from both of the end points
      #         if (dist1[i]>=mindist*1.1 && dist2[i]>=mindist*1.1) {
      #           # print "is far enough from both end points" > "/dev/stderr"
      #           if (firstprint==1) {
      #             firstlon=lon[i]
      #             firstlat=lat[i]
      #             firstprint=0
      #           }
      #           print lon[i], lat[i]
      #         }
      #       # else {
      #       #     print "didnt pass print requirements" > "/dev/stderr"
      #       #   }
      #       }
      #     }
      #     # Connect the first and last plotted points to close the polygon
      #     print firstlon, firstlat
      #
      #   }' > ${F_PROFILES}${LINEID}_trackfile_final_buffer.txt


      # Another method is to construct two chop polygons and remove any points
      # that fall inside them



      if [[ -s ${F_PROFILES}${LINEID}_end.txt ]]; then
        while read d; do
          p=($(echo $d))
          # echo END POINT ${p[0]}/${p[1]} azimuth ${p[2]} width ${p[3]} color ${p[4]}
          CUTBOX_ANTIAZ=$(echo "${p[2]} - 180" | bc -l)
          CUTBOX_FOREAZ=$(echo "${p[2]} - 90" | bc -l)
          CUTBOX_ANTIFOREAZ=$(echo "${p[2]} + 90" | bc -l)
          CUTBOX_WIDTHKM=$(echo "${p[3]}*1.1 / 2" | bc -l) # Half width plus 5 percent
          CUTBOX_SUBWIDTH=$(echo "${p[3]}*1.05" | bc -l) # Full width plus 5 percent
          CUTBOX_ADDWIDTH=$(echo "${p[3]}*0.01" | bc -l) # Full width plus 5 percent

          echo ">" >> ${F_PROFILES}${LINEID}_end_profile_cutbox.txt

          # The first point is offset from the origin in the direction of the
          gmt project -C${p[0]}/${p[1]} -A${p[2]} -Q -G${CUTBOX_WIDTHKM}k -L0/${CUTBOX_WIDTHKM} | tail -n 1 | gawk  '{print $1, $2}' > endpoint1.txt
          gmt project -C${p[0]}/${p[1]} -A${CUTBOX_ANTIAZ} -Q -G${CUTBOX_WIDTHKM}k -L0/${CUTBOX_WIDTHKM} | tail -n 1 | gawk  '{print $1, $2}' > endpoint2.txt

          cat endpoint1.txt | gmt vector -Tt${CUTBOX_ANTIFOREAZ}/${CUTBOX_ADDWIDTH}k > closepoint1.txt
          cat endpoint2.txt | gmt vector -Tt${CUTBOX_ANTIFOREAZ}/${CUTBOX_ADDWIDTH}k > closepoint2.txt
          cat endpoint1.txt | gmt vector -Tt${CUTBOX_ANTIFOREAZ}/${CUTBOX_SUBWIDTH}k > farpoint1.txt
          cat endpoint2.txt | gmt vector -Tt${CUTBOX_ANTIFOREAZ}/${CUTBOX_SUBWIDTH}k > farpoint2.txt

          # Build the box
          # Start with the endpoint itself
          echo "${p[0]} ${p[1]}" >> ${F_PROFILES}${LINEID}_end_profile_cutbox.txt
          # Add the
          cat closepoint1.txt >> ${F_PROFILES}${LINEID}_end_profile_cutbox.txt
          cat farpoint1.txt >> ${F_PROFILES}${LINEID}_end_profile_cutbox.txt
          cat farpoint2.txt >> ${F_PROFILES}${LINEID}_end_profile_cutbox.txt
          cat closepoint2.txt >> ${F_PROFILES}${LINEID}_end_profile_cutbox.txt
          echo "${p[0]} ${p[1]}" >> ${F_PROFILES}${LINEID}_end_profile_cutbox.txt
          # gmt psxy ${F_PROFILES}end_profile_lines.txt -W${PROFILE_TRACK_WIDTH},${p[4]} $RJOK $VERBOSE >> map.ps
        done < ${F_PROFILES}${LINEID}_end.txt
      fi

      if [[ -s ${F_PROFILES}${LINEID}_begin.txt ]]; then
        while read d; do
          p=($(echo $d))
          # echo END POINT ${p[0]}/${p[1]} azimuth ${p[2]} width ${p[3]} color ${p[4]}
          CUTBOX_ANTIAZ=$(echo "${p[2]} - 180" | bc -l)
          CUTBOX_FOREAZ=$(echo "${p[2]} - 90" | bc -l)
          CUTBOX_ANTIFOREAZ=$(echo "${p[2]} + 90" | bc -l)
          CUTBOX_WIDTHKM=$(echo "${p[3]}*1.1 / 2" | bc -l) # Half width plus 5 percent
          CUTBOX_SUBWIDTH=$(echo "${p[3]}*1.05" | bc -l) # Full width plus 5 percent
          CUTBOX_ADDWIDTH=$(echo "${p[3]}*0.01" | bc -l) # Full width plus 5 percent

          echo ">" >> ${F_PROFILES}${LINEID}_end_profile_cutbox.txt

          # The first point is offset from the origin in the direction of the
          gmt project -C${p[0]}/${p[1]} -A${p[2]} -Q -G${CUTBOX_WIDTHKM}k -L0/${CUTBOX_WIDTHKM} | tail -n 1 | gawk  '{print $1, $2}' > endpoint1.txt
          gmt project -C${p[0]}/${p[1]} -A${CUTBOX_ANTIAZ} -Q -G${CUTBOX_WIDTHKM}k -L0/${CUTBOX_WIDTHKM} | tail -n 1 | gawk  '{print $1, $2}' > endpoint2.txt

          cat endpoint1.txt | gmt vector -Tt${CUTBOX_FOREAZ}/${CUTBOX_ADDWIDTH}k > closepoint1.txt
          cat endpoint2.txt | gmt vector -Tt${CUTBOX_FOREAZ}/${CUTBOX_ADDWIDTH}k > closepoint2.txt
          cat endpoint1.txt | gmt vector -Tt${CUTBOX_FOREAZ}/${CUTBOX_SUBWIDTH}k > farpoint1.txt
          cat endpoint2.txt | gmt vector -Tt${CUTBOX_FOREAZ}/${CUTBOX_SUBWIDTH}k > farpoint2.txt

          # Build the box
          # Start with the endpoint itself
          echo "${p[0]} ${p[1]}" >> ${F_PROFILES}${LINEID}_end_profile_cutbox.txt
          # Add the
          cat closepoint1.txt >> ${F_PROFILES}${LINEID}_end_profile_cutbox.txt
          cat farpoint1.txt >> ${F_PROFILES}${LINEID}_end_profile_cutbox.txt
          cat farpoint2.txt >> ${F_PROFILES}${LINEID}_end_profile_cutbox.txt
          cat closepoint2.txt >> ${F_PROFILES}${LINEID}_end_profile_cutbox.txt
          echo "${p[0]} ${p[1]}" >> ${F_PROFILES}${LINEID}_end_profile_cutbox.txt
          # gmt psxy ${F_PROFILES}end_profile_lines.txt -W${PROFILE_TRACK_WIDTH},${p[4]} $RJOK $VERBOSE >> map.ps
        done < ${F_PROFILES}${LINEID}_begin.txt
      fi

      # Subsample the buffer track to 1 km minimum point spacing, keeping points
      gmt sample1d ${F_PROFILES}${LINEID}_trackfile_dissolved_buffers.txt -Af -T1k > ${F_PROFILES}${LINEID}_trackfile_dissolved_buffers_resample.txt

      gmt select ${F_PROFILES}${LINEID}_trackfile_dissolved_buffers.txt -F${F_PROFILES}${LINEID}_end_profile_cutbox.txt -If > ${F_PROFILES}${LINEID}_trackfile_final_buffer.txt

      # Cut the buffer and joing the first and last points if necessary
      gmt select ${F_PROFILES}${LINEID}_trackfile_dissolved_buffers_resample.txt -F${F_PROFILES}${LINEID}_end_profile_cutbox.txt -If | gawk '
      BEGIN {
        saw=0
      }
      {
        print
        if ($1+0==$1) {
          if (saw==0) {
            saw=1
            firstlon=$1
            firstlat=$2
          } else {
            lastlon=$1
            lastlon=$2
          }
        }
      }
      END {
        if (firstlon != lastlon || firstlat != lastlat) {
          print firstlon, firstlat
        }
      }' > ${F_PROFILES}${LINEID}_trackfile_final_buffer.txt

    # fi
    ;;
  esac

  case $comcode in
  P)
  # Process the 'normal' type tracks.
    # LINEID=${myarray[1]}
    # COLOR=${myarray[2]}
    # XOFFSET=${myarray[3]}
    # ZOFFSET=${myarray[4]}

    # P type tracks can be aligned to a cross-profile

    if [[ ${XOFFSET:0:1} == "N" ]]; then
      info_msg "N flag: XOFFSET and X alignment is overridden for line $LINEID"
      doxflag=0
      XOFFSET_NUM=0
    else
      doxflag=1
      XOFFSET_NUM=$XOFFSET
    fi
    if [[ ${ZOFFSET:0:1} == "N" ]]; then
      info_msg "N flag: ZOFFSET and Z alignment is overridden for line $LINEID"
      dozflag=0
      ZOFFSET_NUM=0
    else
      ZOFFSET_NUM=$ZOFFSET
      dozflag=1
    fi

    # Reset the profile data extent
    reset_profile_bounds

    # COLOR=$(grep ^"$COLOR " $GMTCOLORS | head -n 1 | gawk '{print $2}')
    #
    # LIGHTCOLOR=$(echo $COLOR | gawk -F/ '{
    #   printf "%d/%d/%d", (255-$1)*0.25+$1,  (255-$2)*0.25+$2, (255-$3)*0.25+$3
    # }')
    # LIGHTERCOLOR=$(echo $COLOR | gawk -F/ '{
    #   printf "%d/%d/%d", (255-$1)*0.5+$1,  (255-$2)*0.5+$2, (255-$3)*0.5+$3
    # }')

    if [[ $profilematchmaplengthflag -eq 1 ]]; then
      # Project the trackfile into document coordinates
      gmt mapproject ${F_PROFILES}${LINEID}_trackfile.txt ${RJSTRING} > ${F_PROFILES}${LINEID}_projected_trackfile.txt

      # Calculate the incremental length along profile between points
      PROFILE_LEN_IN=$(gawk < ${F_PROFILES}${LINEID}_projected_trackfile.txt '
        BEGIN {
          val=0
          getline
          prevx=$1
          prevy=$2
        }
        {
          dinc=sqrt(($1-prevx)^2+($2-prevy)^2)/2.54
          prevx=$1
          prevy=$2
          val=val+dinc
        }
        END {
          print val
        }')

      # echo profile length is ${PROFILE_LEN_IN}
      # gmt mapproject ${F_PROFILES}${LINEID}_trackfile.txt ${RJSTRING} -G+i+uc
      # echo done

      PROFILE_WIDTH_MAX=$(echo $PROFILE_WIDTH_MAX $PROFILE_LEN_IN | gawk '{print ($1>$2)?$1:$2}')
      PROFILE_WIDTH_MAX_IN=${PROFILE_WIDTH_MAX}"i"

      # TEST: set to the length of the profile in map units
      PROFILE_WIDTH_IN=${PROFILE_LEN_IN}"i"
    fi


####vvvv These steps seem relevant to the P tracks only
    xoffsetflag=0
    # Set XOFFSET to the distance from our first point to the crossing point of zero_point_file.txt
    if [[ $zeropointflag -eq 1 && $doxflag -eq 1 ]]; then
      head -n 1 ${F_PROFILES}${LINEID}_trackfile.txt > ${F_PROFILES}intersect.txt
      gmt spatial -Vn -fg -Ie -Fl ${F_PROFILES}${LINEID}_trackfile.txt $ZEROFILE | head -n 1 | gawk '{print $1, $2}' >> ${F_PROFILES}intersect.txt
      INTNUM=$(wc -l < ${F_PROFILES}intersect.txt)
      if [[ $INTNUM -eq 2 ]]; then
        XOFFSET_NUM=$(gmt mapproject -Vn -G+uk+i ${F_PROFILES}intersect.txt | tail -n 1 | gawk '{print 0-$3}')
        xoffsetflag=1
        PROFILE_XMIN=$(echo "$PROFILE_XMIN + ${XOFFSET_NUM}" | bc -l)
        PROFILE_XMAX=$(echo "$PROFILE_XMAX + ${XOFFSET_NUM}" | bc -l)
        info_msg "Updated line $LINEID by shifting ${XOFFSET_NUM} km to match $ZEROFILE"
        tail -n 1 ${F_PROFILES}intersect.txt >> ${F_PROFILES}all_intersect.txt
      fi
    fi

    cleanup ${F_PROFILES}intersect.txt

    # Find the cross profile locations
    p=($(head -n 1 ${F_PROFILES}${LINEID}_end.txt))
    # Determine profile of the oblique block end
    ANTIAZ=$(echo "${p[2]} - 180" | bc -l)
    FOREAZ=$(echo "${p[2]} - 90" | bc -l)
    SUBWIDTH=$(echo "${p[3]} * 0.1" | bc -l)

    if [[ $PERSPECTIVE_TOPO_HALF == "+l" ]]; then
      # If we are doing the half profile, go from the profile and don't correct
      XOFFSET_CROSS=0
      echo "${p[0]} ${p[1]}" > ${F_PROFILES}${LINEID}_endprof.txt
      gmt project -C${p[0]}/${p[1]} -A${p[2]} -Q -G${p[3]}k -L0/${p[3]} | gawk '{print $1, $2}' >> ${F_PROFILES}${LINEID}_endprof.txt
    else
      # echo "full"
      # If we are doing the full profile, we have to go from endpoint to endpoint
      gmt project -C${p[0]}/${p[1]} -A${ANTIAZ} -Q -G${p[3]}k -L0/${p[3]} | gawk '{print $1, $2}' > ${F_PROFILES}${LINEID}_endprof.txt
      gmt project -C${p[0]}/${p[1]} -A${p[2]} -Q -G${p[3]}k -L0/${p[3]} | gawk '{print $1, $2}' >> ${F_PROFILES}${LINEID}_endprof.txt
      # Get the distance between the points, in km
    fi

    cleanup ${F_PROFILES}${LINEID}_endprof.txt

    TMPDIST=$(gmt mapproject ${F_PROFILES}${LINEID}_endprof.txt -G+uk+i | tail -n 1 | gawk '{print $3}')
    XOFFSET_CROSS=$(echo "0 - ($TMPDIST / 2)" | bc -l)
####^^^^ These steps seem relevant to the P tracks only



    # Process the various kinds of data. The order of these sections will
    # determine the order of the data plotted on the profile; last is on top

    ##### BEGIN data plotting section

    # Litho1
    if [[ $litho1profileflag -eq 1 ]]; then
      info_msg "Extracting LITHO1.0 data for profile ${LINEID}"

      ##########################################################################
      # Extract LITHO1.0 data to plot on profile.
      # 1. depth(m)
      # 2. density(kg/m3)  [1000-3300]
      # 3. Vp(m/s)         [2500-8500]
      # 4. Vs(m/s)         [1000-5000]
      # 5. Qkappa          0?
      # 6. Qmu             [0 1000]
      # 7. Vp2(m/s)
      # 8. Vs2(m/s)
      # 9. eta

      # First, do the main profile, honoring the XOFFSET_NUM shift

      gmt sample1d ${F_PROFILES}${LINEID}_trackfile.txt -Af -fg -I${LITHO1_INC}k  > ${F_PROFILES}${LINEID}_litho1_track.txt
      rm -f ${F_PROFILES}lab.xy
      ptcount=0
      while read p; do
        lon=$(echo $p | gawk '{print $1}')
        lat=$(echo $p | gawk '{print $2}')
        ${LITHO1_PROG} -p $lat $lon -l ${LITHO1_LEVEL} 2>/dev/null | gawk -v extfield=$LITHO1_FIELDNUM -v xoff=${XOFFSET_NUM} -v ptcnt=$ptcount -v dinc=${LITHO1_INC} '
          BEGIN {
            widthfactor=1
            getline;
            lastz=-$1/1000
            lastval=$(extfield)
            dist=ptcnt*dinc+xoff
            print "> -Z" lastval
            print dist-dinc*widthfactor/2, -6000000/1000
            print dist+dinc*widthfactor/2, -6000000/1000
            print dist+dinc*widthfactor/2, lastz
            print dist-dinc*widthfactor/2, lastz
            print dist-dinc*widthfactor/2, -6000000/1000
          }
          {
            # print $10>>"/dev/stderr"
            dist=ptcnt*dinc+xoff
            if (lastz==-$1/1000 || $(extfield)<=1030) {
              # do not print empty boxes or water velocity boxes
            } else {
              print "> -Z" $(extfield)
              print dist-dinc*widthfactor/2, lastz
              print dist+dinc*widthfactor/2, lastz
              print dist+dinc*widthfactor/2, -$1/1000
              print dist-dinc*widthfactor/2, -$1/1000
              print dist-dinc*widthfactor/2, lastz
            }
            if ($10 == "LID-BOTTOM") {
              print dist-dinc*1/2, -$1/1000 >> "./lab.xy"
              print dist+dinc*1/2, -$1/1000 >> "./lab.xy"
            }
            if ($10 == "CRUST3-BOTTOM") {
              print dist-dinc*1/2, -$1/1000 >> "./moho.xy"
              print dist+dinc*1/2, -$1/1000 >> "./moho.xy"
            }
            lastz=-$1/1000
            lastval=$(extfield)
          }' >> ${F_PROFILES}${LINEID}_litho1_poly.dat

        ptcount=$(echo "$ptcount + 1" | bc)
      done < ${F_PROFILES}${LINEID}_litho1_track.txt
      mv lab.xy ${F_PROFILES}${LINEID}_lab.xy
      mv moho.xy ${F_PROFILES}${LINEID}_moho.xy

      # Then, do the cross-profile to go on the end of the block diagram.

      if [[ $PLOT_SECTIONS_PROFILEFLAG -eq 1 ]]; then
        gmt sample1d ${F_PROFILES}${LINEID}_endprof.txt -Af -fg -I${LITHO1_INC}k  > ${F_PROFILES}${LINEID}_litho1_cross_track.txt
        rm -f lab.xy
        rm -f moho.xy
        ptcount=0
        while read p; do
          lon=$(echo $p | gawk '{print $1}')
          lat=$(echo $p | gawk '{print $2}')

          ${LITHO1_PROG} -p $lat $lon -l ${LITHO1_LEVEL} 2>/dev/null | gawk -v extfield=$LITHO1_FIELDNUM -v xoff=${XOFFSET_CROSS} -v ptcnt=$ptcount -v dinc=${LITHO1_INC} '
            BEGIN {
              getline;
              widthfactor=1
              lastz=-$1/1000
              lastval=$(extfield)
              dist=ptcnt*dinc+xoff
              print "> -Z" lastval
              print dist-dinc*widthfactor/2, -6000000/1000
              print dist+dinc*widthfactor/2, -6000000/1000
              print dist+dinc*widthfactor/2, lastz
              print dist-dinc*widthfactor/2, lastz
              print dist-dinc*widthfactor/2, -6000000/1000
            }
            {
              # print $10>>"/dev/stderr"
              dist=ptcnt*dinc+xoff
              if (lastz==-$1/1000 || $(extfield)<=1030) {
                # do not print empty boxes or water velocity boxes
              } else {
                print "> -Z" $(extfield)
                print dist-dinc*widthfactor/2, lastz
                print dist+dinc*widthfactor/2, lastz
                print dist+dinc*widthfactor/2, -$1/1000
                print dist-dinc*widthfactor/2, -$1/1000
                print dist-dinc*widthfactor/2, lastz
              }
              if ($10 == "LID-BOTTOM") {
                print dist-dinc*1/2, -$1/1000 >> "./lab.xy"
                print dist+dinc*1/2, -$1/1000 >> "./lab.xy"
              }
              if ($10 == "CRUST3-BOTTOM") {
                print dist-dinc*1/2, -$1/1000 >> "./moho.xy"
                print dist+dinc*1/2, -$1/1000 >> "./moho.xy"
              }
              lastz=-$1/1000
              lastval=$(extfield)
            }' >> ${F_PROFILES}${LINEID}_litho1_cross_poly.dat
          ptcount=$(echo "$ptcount + 1" | bc)
        done < ${F_PROFILES}${LINEID}_litho1_cross_track.txt
        mv lab.xy ${F_PROFILES}${LINEID}_cross_lab.xy
        mv moho.xy ${F_PROFILES}${LINEID}_cross_moho.xy
      fi

      # PLOT ON THE COMBINED PROFILE PS

      # echo "gmt psxy -L ${F_PROFILES}${LINEID}_litho1_poly.dat -G+z -C$LITHO1_CPT -t${LITHO1_TRANS} -Vn -R -J -O -K >> ${PSFILE}" >> plot.sh
      [[ $litho1plotlabflag -eq 1 ]] && echo "gmt psxy ${F_PROFILES}${LINEID}_lab.xy -W0.5p,black,- -Vn -R -J -O -K >> ${PSFILE}" >> plot.sh
      [[ $litho1plotmohoflag -eq 1 ]] && echo "gmt psxy ${F_PROFILES}${LINEID}_moho.xy -W0.5p,black -Vn -R -J -O -K >> ${PSFILE}" >> plot.sh

      # PLOT ON THE FLAT PROFILE PS

      # We create a TIFF of the rendered polygons and plot that to remove faint
      # lines between the polygons

      echo "gmt psxy -L ${F_PROFILES}${LINEID}_litho1_poly.dat -G+z -C$LITHO1_CPT -Vn -R -J -B+gwhite > ${F_PROFILES}${LINEID}_litho1.ps" >> ${LINEID}_temp_plot.sh
      echo "gmt psconvert -Tt -A+m0i ${F_PROFILES}${LINEID}_litho1.ps" >> ${LINEID}_temp_plot.sh
      [[ $litho1nogridflag -ne 1 ]] && echo "gmt grdimage ${F_PROFILES}${LINEID}_litho1.tif -t${LITHO1_TRANS} -R -J -O -K >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh
      [[ $litho1plotlabflag -eq 1 ]] && echo "gmt psxy ${F_PROFILES}${LINEID}_lab.xy -W0.5p,black,- -Vn -R -J -O -K >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh
      [[ $litho1plotmohoflag -eq 1 ]] && echo "gmt psxy ${F_PROFILES}${LINEID}_moho.xy -W0.5p,black -Vn -R -J -O -K >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh

      # echo "gmt psxy -L ${F_PROFILES}${LINEID}_litho1_poly.dat -G+z -C$LITHO1_CPT -t${LITHO1_TRANS} -Vn -R -J -O -K >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh
      # echo "gmt psxy ${F_PROFILES}${LINEID}_lab.xy -W0.5p,black -Vn -R -J -O -K >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_temp_plot.sh

      # PLOT ON THE OBLIQUE PROFILE PS
      if [[ $PLOT_SECTIONS_PROFILEFLAG -eq 1 ]]; then

        echo "[[ ! -s ${F_PROFILES}${LINEID}_litho1.tif ]] && gmt psxy -L ${F_PROFILES}${LINEID}_litho1_poly.dat -G+z -C$LITHO1_CPT -Vn -R -J -B+gwhite > ${F_PROFILES}${LINEID}_litho1.ps" >> ${LINEID}_plot.sh
        echo "[[ ! -s ${F_PROFILES}${LINEID}_litho1.tif ]] && gmt psconvert -Tt -A+m0i ${F_PROFILES}${LINEID}_litho1.ps" >> ${LINEID}_plot.sh
        [[ $litho1nogridflag -ne 1 ]] && echo "gmt grdimage -p ${F_PROFILES}${LINEID}_litho1.tif -t${LITHO1_TRANS} -R -J -O -K >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_plot.sh
        [[ $litho1plotlabflag -eq 1 ]] && echo "gmt psxy -p ${F_PROFILES}${LINEID}_lab.xy -W0.5p,black,- -Vn -R -J -O -K >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_plot.sh
        [[ $litho1plotmohoflag -eq 1 ]] && echo "gmt psxy -p ${F_PROFILES}${LINEID}_moho.xy -W0.5p,black -Vn -R -J -O -K >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_plot.sh

        # echo "gmt psxy -L -p ${F_PROFILES}${LINEID}_litho1_poly.dat -t${LITHO1_TRANS} -G+z -C$LITHO1_CPT -Vn -R -J -O -K >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_plot.sh
        # echo "gmt psxy -p ${F_PROFILES}${LINEID}_lab.xy -W0.5p,black -Vn -R -J -O -K >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_plot.sh
      fi
    fi

    # 3D grids (NetCDF)
    for i in ${!threedgridfilelist[@]}; do

      numprofpts=$(cat ${F_PROFILES}${LINEID}_trackfile.txt | wc -l)
      numsegs=$(echo "$numprofpts - 1" | bc -l)

      # Manage the CPTs

      # Determine the resolution and extents of the data cube
      zinfo=($(gmt grdinfo -Q -C ${threedgridfilelist[$i]} | gawk '{print $6, $7, $12}'))
      if [[ ${zinfo[2]} -eq 0 ]]; then
        zinfo[2]=${zinfo[0]}
        echo "[-prof3dgrid]: Warning: changed zinfo to ${zinfo[0]}"
      fi

      # For each segment of the track
      cur_x=0
      for segind in $(seq 1 $numsegs); do
        segind_p=$(echo "$segind + 1" | bc -l)
        p1_x=$(cat ${F_PROFILES}${LINEID}_trackfile.txt | head -n ${segind} | tail -n 1 | gawk '{print $1}')
        p1_z=$(cat ${F_PROFILES}${LINEID}_trackfile.txt | head -n ${segind} | tail -n 1 | gawk '{print $2}')
        p2_x=$(cat ${F_PROFILES}${LINEID}_trackfile.txt | head -n ${segind_p} | tail -n 1 | gawk '{print $1}')
        p2_z=$(cat ${F_PROFILES}${LINEID}_trackfile.txt | head -n ${segind_p} | tail -n 1 | gawk '{print $2}')
        add_x=$(cat ${F_PROFILES}${LINEID}_dist_km.txt | head -n $segind_p | tail -n 1)

        # Slice the 3D grid
        # echo gmt grdinterpolate ${threedgridfilelist[$i]}?vs -E${p1_x}/${p1_z}/${p2_x}/${p2_z}+i${threedres[$i]} -T${zinfo[0]}/${zinfo[1]}/${zinfo[2]} -Gvs_${segind}.nc ${VERBOSE}
        INTERPTYPE="-Fa"

        # echo gmt grdinterpolate ${threedgridfilelist[$i]}?${threeddatatype[$i]} ${INTERPTYPE} -E${p1_x}/${p1_z}/${p2_x}/${p2_z}+i${threedres[$i]} -T${zinfo[0]}/${zinfo[1]}/${zinfo[2]} -G${threeddatatype[$i]}_${segind}.nc ${VERBOSE}
        echo "Interpolating 3D grid"
        gmt grdinterpolate ${threedgridfilelist[$i]}?${threeddatatype[$i]} ${INTERPTYPE} -E${p1_x}/${p1_z}/${p2_x}/${p2_z}+i${threedres[$i]} -T${zinfo[0]}/${zinfo[1]}/${zinfo[2]} -G${threeddatatype[$i]}_${segind}.nc ${VERBOSE}

        # Convert to text, adjust to add X offset and make Z negative (assuming grid is in depth)
        gmt grd2xyz ${threeddatatype[$i]}_${segind}.nc | gawk -v curx=${cur_x} '{print $1+curx, 0-$2, $3}' >> ${LINEID}_threed.txt

        # echo "Segment ${segind}: slicing 3d grid from ${p1_x}/${p1_z} to ${p2_x}/${p2_z}, X=[${cur_x}, $(echo "$cur_x + ${add_x}" | bc -l)]"
        add_x=$(cat ${F_PROFILES}${LINEID}_dist_km.txt | head -n $segind_p | tail -n 1)
        cur_x=$(echo "$cur_x + $add_x" | bc -l)
      done

      # Reconstruct a grid from the combined segments
      neg1=$(echo "0 - ${zinfo[1]}" | bc -l)
      neg2=$(echo "0 - ${zinfo[0]}" | bc -l)

      # This removes the horizontal average from each profile. Not really a great way to do this
      # We should probably just allow people to correct their own data beforehand.
      if [[ $threedresidflag -eq 1 ]]; then
        # file is X Z V
        gawk < ${LINEID}_threed.txt '
        {
          x[NR]=$1
          z[NR]=$2
          v[NR]=$3
          if ($2 != "NaN") {
            sum[$2]+=$3
            num[$2]++
          }
        }
        END {
          for (key in sum) {
            ave[key]=sum[key]/num[key]
            print "Average of level", key, "is", ave[key] "from", sum[key], "over", num[key] > "/dev/stderr"
          }
          for (i=1; i<=NR; i++) {
            if (v[$i]=="NaN") {
              print x[$i], z[$i], "NaN"
            } else {
              print x[$i], z[$i], (v[$i]-ave[z[$i]])/ave[z[$i]]
            }
          }
        }' > ${LINEID}_threed_resid.txt
        TRIANGFILE=${LINEID}_threed_resid.txt
      else
        TRIANGFILE=${LINEID}_threed.txt
      fi

      gmt triangulate ${TRIANGFILE} -R0/${cur_x}/${neg1}/${neg2} -I$(echo ${threedres[$i]} | gawk '{print $1+0}')+e -G${F_PROFILES}${LINEID}_threed.nc

      # Create this CPT only once as there may be different data ranges on different profiles
      if [[ ${threedcptlist[$i]} == "" && ! -s ${F_CPTS}prof3d.cpt ]]; then
        echo "#D grid: making own cpt"
        gmt grd2cpt -C${THREED_DEFAULTCPT} ${F_PROFILES}${LINEID}_threed.nc > ${F_CPTS}prof3d.cpt
      else
        THREEDCPT=${threedcptlist[$i]}
      fi

      # Plot the grid
      echo "gmt grdimage ${F_PROFILES}${LINEID}_threed.nc -Q -Vn -R -J -O -K -C${THREEDCPT} >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh
    done

    # Point grid files (e.g. slab2, fault model, etc.)
    for i in ${!ptgridfilelist[@]}; do

      gridfileflag=1

      echo "PTGRID ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_data.txt" >> ${F_PROFILES}data_id.txt

      # if [[ -s ${F_PROFILES}${ptgridfilesellist[$i]} ]]; then
      if [[ -s ${ptgridfilelist[$i]} ]]; then

        # Resample the track at the specified X increment.
        gmt sample1d ${F_PROFILES}${LINEID}_trackfile.txt -Af -fg -I${ptgridspacinglist[$i]} > ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_trackinterp.txt
        # gmt sample1d ${F_PROFILES}${LINEID}_trackfile.txt -Af -fg -I${ptgridspacinglist[$i]} > ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_trackinterp_pre.txt
        #
        # # Need to fix the track if it spans the prime meridian
        # fix_dateline_poly ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_trackinterp_pre.txt | gawk '{print $1+360, $2}' > ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_trackinterp.txt
        # # cleanup ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_trackinterp.txt

        # Calculate the X coordinate of the resampled track, accounting for any X offset due to profile alignment
        gmt mapproject -G+uk+a ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_trackinterp.txt | gawk -v xoff="${XOFFSET_NUM}" '{ print $1, $2, $3 + xoff }' > ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_trackdist.txt

        # cleanup ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_trackdist.txt

        # Sample the grid at the points.  Note that -N is needed to avoid paste problems.

        # October 29, 2021:
        # Following this command, we would multiply the grdtrack results by the relevant ZSCALE
        # gmt grdtrack -N -Vn -G${F_PROFILES}${ptgridfilesellist[$i]} ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_trackinterp.txt > ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_sample.txt

        # Sample the grid accounting for potential 360 degree shifts and paste onto original data
        sample_grid_360 ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_trackinterp.txt ${ptgridfilelist[$i]} > tmpsample.txt

        paste ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_trackinterp.txt tmpsample.txt > ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_sample.txt

        rm -f tmpsample.txt
        # gmt grdtrack -N -Vn -G${ptgridfilelist[$i]} ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_trackinterp.txt > ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_sample.txt

        # *_sample.txt is a file containing lon,lat,val
        # We want to reformat to a multisegment polyline that can be plotted using psxy -Ccpt
        # > -Zval1
        # Lon1 lat1
        # lon2 lat2
        # > -Zval2
        paste ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_trackdist.txt ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_sample.txt > ${F_PROFILES}dat.txt
        sed 1d < ${F_PROFILES}dat.txt > ${F_PROFILES}dat1.txt
      	paste ${F_PROFILES}dat.txt ${F_PROFILES}dat1.txt | gawk -v zscale=${ptgridzscalelist[$i]} '
          {
            if ($7 && $6 != "NaN" && $12 != "NaN") {
              print "> -Z"($6+$12)/2*zscale; print $3, $6*zscale*-1; print $9, $12*zscale*-1
            }
          }' > ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_data.txt

        echo "PTGRID ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_data.txt" >> ${F_PROFILES}data_id.txt


# Normal style for plotting grid swath - within the XZ data domain
        # PLOT ON THE COMBINED PROFILE PS
        echo "gmt psxy -Vn -R -J -O -K -L ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_data.txt ${ptgridcommandlist[$i]} >> "${PSFILE}"" >> plot.sh

        # PLOT ON THE FLAT PROFILE PS
        echo "gmt psxy -Vn -R -J -O -K -L ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_data.txt ${ptgridcommandlist[$i]} >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh

        # PLOT ON THE OBLIQUE PROFILE PS
        [[ $PLOT_SECTIONS_PROFILEFLAG -eq 1 ]] &&  echo "gmt psxy -p -Vn -R -J -O -K -L ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_data.txt ${ptgridcommandlist[$i]} >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_plot.sh
#

# Test style for plotting grid swath - above the XZ data domain, but vertically exaggerated

        echo "gmt psxy -Vn -R -J -O -K -L ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_data.txt ${ptgridcommandlist[$i]} >> "${PSFILE}"" >> plot.sh

        # grep "^[-*0-9]" ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_data.txt >> ${F_PROFILES}${LINEID}_all_data.txt

        update_profile_bounds 1 2,6 < ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_data.txt

        # update_profile_bounds 1 2,6 < ${F_PROFILES}${LINEID}_${ptgrididnum[$i]}_data.txt
      else
        echo "Can't find source ptgrid file: ${F_PROFILES}${ptgridfilesellist[$i]}"
      fi
    done

    # Swath grids (swath, top tile, box-and-whisker)
    for i in ${!gridfilelist[@]}; do
      gridfileflag=1

      # Sample the input grid along space cross-profile
      # echo gmt grdtrack -N -Vn -G${gridfilelist[$i]} ${F_PROFILES}${LINEID}_trackfile.txt -C${gridwidthlist[$i]}k/${gridsamplewidthlist[$i]}/${gridspacinglist[$i]}${PERSPECTIVE_TOPO_HALF} -Af \> ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiletable.txt
      gmt grdtrack -N -Vn -G${gridfilelist[$i]} ${F_PROFILES}${LINEID}_trackfile.txt -C${gridwidthlist[$i]}k/${gridsamplewidthlist[$i]}/${gridspacinglist[$i]}${PERSPECTIVE_TOPO_HALF} -Af > ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiletable.txt

# cleanup ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiletable.txt

      if [[ ${istopgrid[$i]} -eq 1 ]]; then
        # echo "Trying to figure out what to do about top tile"
        # echo "USE_SHADED_RELIEF_TOPTILE=${USE_SHADED_RELIEF_TOPTILE}"
        if [[ $USE_SHADED_RELIEF_TOPTILE -eq 1 ]]; then
          COLOR_SOURCE=${COLORED_RELIEF}
          gdal_translate -q -b 1 ${COLOR_SOURCE} ${F_PROFILES}colored_relief_red.tif
          gdal_translate -q -b 2 ${COLOR_SOURCE} ${F_PROFILES}colored_relief_green.tif
          gdal_translate -q -b 3 ${COLOR_SOURCE} ${F_PROFILES}colored_relief_blue.tif
        else
          if [[ ! -s ${F_PROFILES}topgrid_relief.tif ]]; then
            info_msg "Making new colored grid for toptile extraction"
            # gmt_init_tmpdir
            replace_gmt_colornames_rgb ${gridcptlist[$i]} > ./cpttmp.cpt
            cpt_to_gdalcolor ./cpttmp.cpt > ${F_CPTS}gdal_topocolor.dat
            gdaldem color-relief -q ${F_PROFILES}${gridfilesellist[$i]} ${F_CPTS}gdal_topocolor.dat ${F_PROFILES}topgrid_relief.tif
          fi
          COLOR_SOURCE="${F_PROFILES}topgrid_relief.tif"
          gdal_translate -q -b 1 ${COLOR_SOURCE} ${F_PROFILES}colored_relief_red.tif
          gdal_translate -q -b 2 ${COLOR_SOURCE} ${F_PROFILES}colored_relief_green.tif
          gdal_translate -q -b 3 ${COLOR_SOURCE} ${F_PROFILES}colored_relief_blue.tif
        fi

        # echo gmt grdtrack -N -Vn -G${F_PROFILES}colored_relief_red.tif -G${F_PROFILES}colored_relief_green.tif  -G${F_PROFILES}colored_relief_blue.tif ${F_PROFILES}${LINEID}_trackfile.txt -C${gridwidthlist[$i]}k/${gridsamplewidthlist[$i]}/${gridspacinglist[$i]}${PERSPECTIVE_TOPO_HALF} -Af \> ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiletable_rgb.txt
        gmt grdtrack -N -Vn -G${F_PROFILES}colored_relief_red.tif -G${F_PROFILES}colored_relief_green.tif  -G${F_PROFILES}colored_relief_blue.tif ${F_PROFILES}${LINEID}_trackfile.txt -C${gridwidthlist[$i]}k/${gridsamplewidthlist[$i]}/${gridspacinglist[$i]}${PERSPECTIVE_TOPO_HALF} -Af > ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiletable_rgb.txt

cleanup ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiletable_rgb.txt

        if [[ -s ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiletable_rgb.txt ]]; then
          topgridcoloredreliefflag=1
        fi
      fi


      # ${LINEID}_${grididnum[$i]}_profiletable.txt: FORMAT is grdtrack (> profile data), columns are lon, lat, distance_from_profile, back_azimuth, value

      # Extract the profile ID numbers.
      # !!!!! This could easily be simplified to be a list of numbers starting with 0 and incrementing by 1!

      grep ">" ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiletable.txt | gawk -F- '{print $3}' | gawk -F" " '{print $1}' > ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilepts.txt
cleanup ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilepts.txt

      # Shift the X coordinates of each cross-profile according to XOFFSET_NUM value
      # In gawk, adding +0 to dinc changes "0.3k" to "0.3"
      gawk -v xoff="${XOFFSET_NUM}" -v dinc="${gridspacinglist[$i]}" '{ print ( $1 * (dinc + 0) + xoff ) }' < ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilepts.txt > ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilekm.txt
cleanup ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilekm.txt

      # Construct the profile data table. This is where we can correct by ZSCALE
      gawk -v zscale=${gridzscalelist[$i]} '{
        if ($1 == ">") {
          printf("\n")
        } else {
          printf("%s ", $5*zscale)
        }
      }' < ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiletable.txt | sed '1d' > ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledata.txt

      # If we are doing an oblique section and the current grid is a top grid
      if [[ $PLOT_SECTIONS_PROFILEFLAG -eq 1 && ${istopgrid[$i]} -eq 1 ]]; then

        # Export the along-profile DEM, resampled to the specified resolution.
        # Then estimate the coordinate extents and the z data range, to allow vertical exaggeration

        if [[ $DO_SIGNED_DISTANCE_DEM -eq 0 ]]; then
          # Just export the profile data to a CSV without worrying about profile kink problems. Faster.

          # First find the maximum value of X. We want X to be negative or zero for the block plot. Not sure what happens otherwise...
          MAX_X_VAL=$(gawk < ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiletable.txt 'BEGIN{maxx=-999999} { if ($1 != ">" && $1 > maxx) {maxx = $1 } } END{print maxx}')

          # Generate X,Y,Z data file in CSV format AND a file containing the X,Y,Z data ranges (min/max)

          # For some reason yval of the DEM needs to be sampled negatively (yval=-$3) for the DEM
          # but positively for the shaded relief raster....?

          gawk -v xoff="${XOFFSET_NUM}" -v dinc="${gridspacinglist[$i]}" -v maxx=$MAX_X_VAL '
            BEGIN{offset=0;minX=99999999;maxX=-99999999; minY=99999999; maxY=-99999999; minZ=99999999; maxZ=-99999999}
            {
              if ($1 == ">") {
                split($5, vec, "-");
                offset=vec[3]
              } else {
                yval=-$3
                xval=(offset * (dinc + 0) + xoff);
                zval=$5
                if (zval == "NaN") {
                  print xval "," yval "," zval
                } else {
                  print xval "," yval "," zval
                  if (xval < minX) {
                    minX=xval
                  }
                  if (xval > maxX) {
                    maxX=xval
                  }
                  if (yval < minY) {
                    minY=yval
                  }
                  if (yval > maxY) {
                    maxY=yval
                  }
                  if (zval < minZ) {
                    minZ=zval
                  }
                  if (zval > maxZ) {
                    maxZ=zval
                  }
                }
              }
            }
            END {
              printf "%f %f %f %f %f %f", minX, maxX, minY, maxY, minZ, maxZ > "./profilerange.txt"
            }' < ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiletable.txt | sed '1d' > ${F_PROFILES}${LINEID}_${grididnum[$i]}_data.csv

            # If we are plotting the colored relief image, make the XYR, XYG, XYB text files
            if [[ $topgridcoloredreliefflag -eq 1 ]]; then
              gawk -v xoff="${XOFFSET_NUM}" -v dinc="${gridspacinglist[$i]}" -v maxx=$MAX_X_VAL '
                BEGIN{offset=0;minX=99999999;maxX=-99999999; minY=99999999; maxY=-99999999; minZ=99999999; maxZ=-99999999}
                {
                  if ($1 == ">") {
                    split($5, vec, "-");
                    offset=vec[3]+0
                  } else {
                    yval=-$3
                    xval=(offset * (dinc + 0) + xoff);
                    redval=$5
                    greenval=$6
                    blueval=$7
                    print xval "," yval "," redval > "./red.csv"
                    print xval "," yval "," greenval > "./green.csv"
                    print xval "," yval "," blueval > "./blue.csv"
                  }
                }' < ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiletable_rgb.txt
                mv ./red.csv ${F_PROFILES}red.csv
                mv ./green.csv ${F_PROFILES}green.csv
                mv ./blue.csv ${F_PROFILES}blue.csv
            fi

            # NOTE: Didn't use sed 1d on the above files... important or not???
        else

          # DO_SIGNED_DISTANCE_DEM is 1, so calculate a signed distance DEM for the swath
          # Turn the gridded profile data into dt, da, Z data, shifted by X offset

          # Output the lon, lat, Z, and the sign of the cross-profile distance (left vs right)
          gawk < ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiletable.txt '{
            if ($1 != ">") {
              print $1, $2, $5, ($3>0)?-1:1
            }
          }' > ${F_PROFILES}${LINEID}_${grididnum[$i]}_prepdata.txt
cleanup ${F_PROFILES}${LINEID}_${grididnum[$i]}_prepdata.txt

          # I need a file with LON, LAT, Z
          # Interpolate at a spacing of ${gridspacinglist[$i]} (spacing between cross track profiles)
          gmt sample1d ${F_PROFILES}${LINEID}_trackfile.txt -Af -fg -I${gridspacinglist[$i]} > ${F_PROFILES}line_trackinterp.txt
cleanup ${F_PROFILES}line_trackinterp.txt

          # If this function can be sped up that would be great.
          info_msg "Doing signed distance calculation... (takes some time!)"
          gmt mapproject ${F_PROFILES}${LINEID}_${grididnum[$i]}_prepdata.txt -L${F_PROFILES}line_trackinterp.txt+p -fg -Vn > ${F_PROFILES}${LINEID}_${grididnum[$i]}_dadtpre.txt
# cleanup ${F_PROFILES}${LINEID}_${grididnum[$i]}_dadtpre.txt
          # Output is Lon, Lat, Z, DistSign, DistX, ?, DecimalID
          # DecimalID * ${gridspacinglist[$i]} = distance along track

          # Generate the X,Y,Z data file AND a file containing the range for X,Y,Z (min/max)

          gawk < ${F_PROFILES}${LINEID}_${grididnum[$i]}_dadtpre.txt -v xoff="${XOFFSET_NUM}" -v dinc="${gridspacinglist[$i]}" '
              BEGIN{
                offset=0;minX=99999999;maxX=-99999999; minY=99999999; maxY=-99999999; minZ=99999999; maxZ=-99999999
              }
              {
                xval=($7 * (dinc + 0) + xoff)
                yval=$4*$5/1000
                zval=$3
                print xval "," yval "," zval
                if (zval != "NaN") {
                  if (xval < minX) {
                    minX=xval
                  }
                  if (xval > maxX) {
                    maxX=xval
                  }
                  if (yval < minY) {
                    minY=yval
                  }
                  if (yval > maxY) {
                    maxY=yval
                  }
                  if (zval < minZ) {
                    minZ=zval
                  }
                  if (zval > maxZ) {
                    maxZ=zval
                  }
                }
              }
              END {
                printf "%f %f %f %f %f %f", minX, maxX, minY, maxY, minZ, maxZ > "./profilerange.txt"
              } ' | sed '1d' > ${F_PROFILES}${LINEID}_${grididnum[$i]}_data.csv

            if [[ $topgridcoloredreliefflag -eq 1 ]]; then
              gawk < ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiletable_rgb.txt '($1!=">"){print}' > tmp1.txt
              paste ${F_PROFILES}${LINEID}_${grididnum[$i]}_dadtpre.txt tmp1.txt | gawk -v xoff="${XOFFSET_NUM}" -v dinc="${gridspacinglist[$i]}" '
              {
                xval=($7 * (dinc + 0) + xoff)
                yval=$4*$5/1000
                redval=$12
                greenval=$13
                blueval=$14
                print xval "," yval "," redval > "./red.csv"
                print xval "," yval "," greenval > "./green.csv"
                print xval "," yval "," blueval > "./blue.csv"
              }'
              mv ./red.csv ${F_PROFILES}red.csv
              mv ./green.csv ${F_PROFILES}green.csv
              mv ./blue.csv ${F_PROFILES}blue.csv
              # rm -f tmp1.txt
            fi
        fi

        # We have created a da-dt dataset that needs to be turned into a DEM.
        # We use some gdal tricks to construct a raster
        mv profilerange.txt ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilerange.txt

# We use a random UTM Zone as the projected coordinate system for the da-dt data.
# This is because I don't know how to create/use a simple local X-Y system with
# meters as the XY unit...

cat << EOF > ${F_PROFILES}${LINEID}_${grididnum[$i]}_data.vrt
<OGRVRTDataSource>
    <OGRVRTLayer name="${LINEID}_${grididnum[$i]}_data">
        <SrcDataSource>${LINEID}_${grididnum[$i]}_data.csv</SrcDataSource>
        <GeometryType>wkbPoint</GeometryType>
        <LayerSRS>EPSG:3857</LayerSRS>
        <GeometryField encoding="PointFromColumns" x="field_1" y="field_2" z="field_3"/>
    </OGRVRTLayer>
</OGRVRTDataSource>
EOF

        if [[ $topgridcoloredreliefflag -eq 1 ]]; then
cat << EOF > ${F_PROFILES}red.vrt
<OGRVRTDataSource>
    <OGRVRTLayer name="red">
        <SrcDataSource>red.csv</SrcDataSource>
        <GeometryType>wkbPoint</GeometryType>
        <LayerSRS>EPSG:3857</LayerSRS>
        <GeometryField encoding="PointFromColumns" x="field_1" y="field_2" z="field_3"/>
    </OGRVRTLayer>
</OGRVRTDataSource>
EOF

cat << EOF > ${F_PROFILES}green.vrt
<OGRVRTDataSource>
    <OGRVRTLayer name="green">
        <SrcDataSource>green.csv</SrcDataSource>
        <GeometryType>wkbPoint</GeometryType>
        <LayerSRS>EPSG:3857</LayerSRS>
        <GeometryField encoding="PointFromColumns" x="field_1" y="field_2" z="field_3"/>
    </OGRVRTLayer>
</OGRVRTDataSource>
EOF

cat << EOF > ${F_PROFILES}blue.vrt
<OGRVRTDataSource>
    <OGRVRTLayer name="blue">
        <SrcDataSource>blue.csv</SrcDataSource>
        <GeometryType>wkbPoint</GeometryType>
        <LayerSRS>EPSG:3857</LayerSRS>
        <GeometryField encoding="PointFromColumns" x="field_1" y="field_2" z="field_3"/>
    </OGRVRTLayer>
</OGRVRTDataSource>
EOF
        fi
        # dem_minx,y are in units of km
        dem_minx=$(gawk < ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilerange.txt '{print $1}')
        dem_maxx=$(gawk < ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilerange.txt '{print $2}')
        dem_miny=$(gawk < ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilerange.txt '{print $3}')
        dem_maxy=$(gawk < ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilerange.txt '{print $4}')
        dem_minz=$(gawk < ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilerange.txt -v zs=${gridzscalelist[$i]} '{print $5*zs}')
        dem_maxz=$(gawk < ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilerange.txt -v zs=${gridzscalelist[$i]} '{print $6*zs}')
        # echo dem_minx $dem_minx dem_maxx $dem_maxx dem_miny $dem_miny dem_maxy $dem_maxy dem_minz $dem_minz dem_maxz $dem_maxz

        dem_xtoyratio=$(echo "($dem_maxx - $dem_minx)/($dem_maxy - $dem_miny)" | bc -l)
        dem_ztoxratio=$(echo "($dem_maxz - $dem_minz)/($dem_maxx - $dem_minx)" | bc -l)

        # Calculate zsize from xsize
        xsize=$(echo $PROFILE_WIDTH_IN | gawk '{print $1+0}')
        zsize=$(echo "$xsize * $dem_ztoxratio" | bc -l)

        numx=$(echo "($dem_maxx - $dem_minx)/$PERSPECTIVE_RES" | bc)
        numy=$(echo "($dem_maxy - $dem_miny)/$PERSPECTIVE_RES" | bc)

        cd ${F_PROFILES}

          gdal_grid -q -of "netCDF" -txe $dem_minx $dem_maxx -tye $dem_maxy $dem_miny  -outsize $numx $numy -zfield field_3 -a nearest -l ${LINEID}_${grididnum[$i]}_data ${LINEID}_${grididnum[$i]}_data.vrt ${LINEID}_${grididnum[$i]}_newgrid.nc

          if [[ $topgridcoloredreliefflag -eq 1 ]]; then
            gdal_grid -q -of "GTiff" -txe $dem_minx $dem_maxx -tye $dem_maxy $dem_miny -outsize $numx $numy -zfield field_3 -a nearest -l red red.vrt red.tif
            gdal_grid -q -of "GTiff" -txe $dem_minx $dem_maxx -tye $dem_maxy $dem_miny -outsize $numx $numy -zfield field_3 -a nearest -l green green.vrt green.tif
            gdal_grid -q -of "GTiff" -txe $dem_minx $dem_maxx -tye $dem_maxy $dem_miny -outsize $numx $numy -zfield field_3 -a nearest -l blue blue.vrt blue.tif

            gdal_merge.py -q -separate red.tif green.tif blue.tif -ot Byte -o ${LINEID}_${grididnum[$i]}_colored_hillshade.tif
            # rm -f ./red.tif ./green.tif ./blue.tif ./red.csv ./green.csv ./blue.csv ./red.vrt ./green.vrt ./blue.vrt
          fi
        cd ..

        # From here on, only the zsize and dem_miny, dem_maxy variables are needed for plotting

###     The following script fragment will require the following variables to be defined in the script:
###     PERSPECTIVE_AZ, PERSPECTIVE_INC, line_min_x, line_max_x, line_min_z, line_max_z, PROFILE_HEIGHT_IN, PROFILE_WIDTH_IN, yshift

        echo "VEXAG=\$(echo \"\${3} * ${gridzscalelist[$i]}\" | bc -l)" > ${LINEID}_topscript.sh
        echo "ZSIZE_PRE=${zsize}" >> ${LINEID}_topscript.sh
        echo "ZSIZE=\$(echo \"\$VEXAG * \$ZSIZE_PRE\" | bc -l)" >> ${LINEID}_topscript.sh
        echo "dem_miny=${dem_miny}" >> ${LINEID}_topscript.sh
        echo "dem_maxy=${dem_maxy}" >> ${LINEID}_topscript.sh
        echo "dem_minz=${dem_minz}" >> ${LINEID}_topscript.sh
        echo "dem_maxz=${dem_maxz}" >> ${LINEID}_topscript.sh
        echo "PROFILE_DEPTH_RATIO=\$(echo \"(\$dem_maxy - \$dem_miny) / (\$line_max_x - \$line_min_x)\" | bc -l)"  >> ${LINEID}_topscript.sh
        echo "PROFILE_DEPTH_IN=\$(echo \$PROFILE_DEPTH_RATIO \$PROFILE_WIDTH_IN | gawk '{print (\$1*(\$2+0))}' )i"  >> ${LINEID}_topscript.sh

        echo "GUESS=\$(echo \"\$PROFILE_HEIGHT_IN \$PROFILE_DEPTH_IN\" | gawk '{ print (\$1+0)-(\$2+0) }')" >> ${LINEID}_topscript.sh
        echo "if [[ \$(echo \"\${PERSPECTIVE_AZ} > 180\" | bc -l) -eq 1 ]]; then" >> ${LINEID}_topscript.sh
        echo "  xshift=\$(gawk -v height=\${GUESS} -v az=\$PERSPECTIVE_AZ 'BEGIN{print cos((270-az)*3.1415926/180)*(height+0)}')"  >> ${LINEID}_topscript.sh
        echo "else" >> ${LINEID}_topscript.sh
        echo "  xshift=0" >> ${LINEID}_topscript.sh
        echo "fi" >> ${LINEID}_topscript.sh

        echo "yshift=\$(gawk -v height=\${PROFILE_HEIGHT_IN} -v inc=\$PERSPECTIVE_INC 'BEGIN{print cos(inc*3.1415926/180)*(height+0)}')" >> ${LINEID}_topscript.sh

        echo "gmt psbasemap -p\${PERSPECTIVE_AZ}/\${PERSPECTIVE_INC}/\${line_max_z} -R\${line_min_x}/\${dem_miny}/\${line_max_x}/\${dem_maxy}/\${line_min_z}/\${line_max_z}r -JZ\${PROFILE_HEIGHT_IN} -JX\${PROFILE_WIDTH_IN}/\${PROFILE_DEPTH_IN} -Byaf+l\"${y_axis_label}\" -X\${xshift}i --MAP_FRAME_PEN=thinner,black -K -O >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_topscript.sh

        # If we have an end-cap plot (e.g. litho1), plot that here.
        # Data needs to be plottable by psxyz
        # There's a weird world where we project seismicity and CMTs onto this plane.....

        if [[ $litho1profileflag -eq 1 ]]; then

cat<<-EOF >> ${LINEID}_topscript.sh
gawk < ${F_PROFILES}${LINEID}_litho1_cross_poly.dat -v xval=\$line_max_x -v zval=\$line_min_z '{
if (\$1 == ">") {
print
} else {
  if (\$2 < zval) {
    print xval, \$1, zval
  } else {
    print xval, \$1, \$2
  }
}
}' > ${F_PROFILES}${LINEID}_litho1_cross_poly_xyz.dat
EOF

          # echo "gmt psxy -L ${F_PROFILES}${LINEID}_litho1_cross_poly_xyz.dat -G+z -C$LITHO1_CPT -Vn -R -J -B+gwhite > ${F_PROFILES}${LINEID}_litho1_cross.ps" >> ${LINEID}_topscript.sh
          # echo "gmt psconvert -Tt -A+m0i ${F_PROFILES}${LINEID}_litho1_cross.ps" >> ${LINEID}_topscript.sh
          # echo "gmt grdimage -p ${F_PROFILES}${LINEID}_litho1_cross.tif -t${LITHO1_TRANS} -R -J -O -K >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_topscript.sh
          [[ $litho1plotlabflag -eq 1 ]] && echo "gmt psxy -p ${F_PROFILES}${LINEID}_cross_lab.xy -W0.5p,black,- -Vn -R -J -O -K >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_topscript.sh
          [[ $litho1plotmohoflag -eq 1 ]] && echo "gmt psxy -p ${F_PROFILES}${LINEID}_cross_moho.xy -W0.5p,black -Vn -R -J -O -K >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_topscript.sh
          [[ $litho1nogridflag -ne 1 ]] && echo "gmt psxyz -p ${F_PROFILES}${LINEID}_litho1_cross_poly_xyz.dat -L -G+z -C$LITHO1_CPT -t${LITHO1_TRANS} -Vn -R -J -JZ -O -K >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_topscript.sh
        fi

        # Draw the box at the end of the profile. For other view angles, should draw the other box?

        echo "if [[ \$(echo \"\${PERSPECTIVE_AZ} > 180\" | bc -l) -eq 1 ]]; then" >> ${LINEID}_topscript.sh
        echo "  echo \"\$line_min_x \$dem_maxy \$line_max_z\" > ${F_PROFILES}${LINEID}_endbox.xyz" >> ${LINEID}_topscript.sh
        echo "  echo \"\$line_min_x \$dem_maxy \$line_min_z\" >> ${F_PROFILES}${LINEID}_endbox.xyz" >> ${LINEID}_topscript.sh
        echo "  echo \"\$line_min_x \$dem_miny \$line_min_z\" >> ${F_PROFILES}${LINEID}_endbox.xyz" >> ${LINEID}_topscript.sh
        echo "  echo \"\$line_min_x \$dem_miny \$line_max_z\" >> ${F_PROFILES}${LINEID}_endbox.xyz" >> ${LINEID}_topscript.sh
        echo "else" >> ${LINEID}_topscript.sh
        echo "  echo \"\$line_max_x \$dem_maxy \$line_max_z\" > ${F_PROFILES}${LINEID}_endbox.xyz" >> ${LINEID}_topscript.sh
        echo "  echo \"\$line_max_x \$dem_maxy \$line_min_z\" >> ${F_PROFILES}${LINEID}_endbox.xyz" >> ${LINEID}_topscript.sh
        echo "  echo \"\$line_max_x \$dem_miny \$line_min_z\" >> ${F_PROFILES}${LINEID}_endbox.xyz" >> ${LINEID}_topscript.sh
        echo "  echo \"\$line_max_x \$dem_miny \$line_max_z\" >> ${F_PROFILES}${LINEID}_endbox.xyz" >> ${LINEID}_topscript.sh
        echo "fi" >> ${LINEID}_topscript.sh

        echo "gmt psxyz ${F_PROFILES}${LINEID}_endbox.xyz -p -R -J -JZ -Wthinner,black -K -O >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_topscript.sh

        echo "gmt psbasemap -p\${PERSPECTIVE_AZ}/\${PERSPECTIVE_INC}/\${dem_minz} -R\${line_min_x}/\${dem_miny}/\${line_max_x}/\${dem_maxy}/\${dem_minz}/\${dem_maxz}r -JZ\${ZSIZE}i -J -Bzaf -Bxaf --MAP_FRAME_PEN=thinner,black -K -O -Y\${yshift}i >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_topscript.sh

        # I think this could be done with gmt makecpt -C+Uk but technical questions exist
        # This assumes topo is in m and needs to be in km... not applicable for other grids

        gawk < ${gridcptlist[$i]} -v sc=${gridzscalelist[$i]} '{ if ($1 ~ /^[-+]?[0-9]*\.?[0-9]+$/) { print $1*sc "\t" $2 "\t" $3*sc "\t" $4} else {print}}' > ${F_PROFILES}${LINEID}_topokm.cpt
        echo "gmt grdview ${F_PROFILES}${LINEID}_${grididnum[$i]}_newgrid.nc  -G${F_PROFILES}${LINEID}_${grididnum[$i]}_colored_hillshade.tif -p -Qi${PERSPECTIVE_IM_RES} -R -J -JZ -O  >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_topscript.sh

      fi


      # For grids that are not top grids, they are swath grids. So calculate and plot the swaths.
      if [[ ! ${istopgrid[$i]} -eq 1 ]]; then

        # profiledata.txt contains space delimited rows of data.

        # Swath profile

        # We should probably check for multiples with the same X,Y,Z values as
        # these will affect quartile calculations.

        # This function calculates the 0, 25, 50, 75, and 100 quartiles of the data. First strip out the NaN values which are in the data.


        cat ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledata.txt | sed 's/NaN//g' |  gawk '{
          q1=-1;
          q2=-1;
          q3=-1
          split( $0 , a, " " );

          asort( a );
          n=length(a);

          p[1] = 0;
          for (i = 2; i<=n; i++) {
            p[i] = (i-1)/(n-1);
            if (p[i] >= .25 && q1 == -1) {
              f = (p[i]-.25)/(p[i]-p[i-1]);
              q1 = a[i-1]*(f)+a[i]*(1-f);
            }
            if (p[i] >= .5 && q2 == -1) {
              f = (p[i]-.5)/(p[i]-p[i-1]);
              q2 = a[i-1]*(f)+a[i]*(1-f);
            }
            if (p[i] >= .75 && q3 == -1) {
              f = (p[i]-.75)/(p[i]-p[i-1]);
              q3 = a[i-1]*(f)+a[i]*(1-f);
            }
          }
          printf("%g %g %g %g %g\n", a[1], q1, q2, q3, a[n])
        }' > ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilesummary_pre.txt

        # Find the value of Z at X=0 and subtract it from the entire dataset
        if [[ $ZOFFSETflag -eq 1 && $dozflag -eq 1 ]]; then
          # echo ZOFFSETflag is set
          XZEROINDEX=$(gawk < ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilekm.txt '{if ($1 > 0) { exit } } END {print NR}')
          # echo "XZEROINDEX is" ${XZEROINDEX}

          ZOFFSET_NUM=$(head -n $XZEROINDEX ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilesummary_pre.txt | tail -n 1 | gawk '{print 0-$3}')
        fi
        # echo "Z offset is" ${ZOFFSET_NUM}
        cat ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilesummary_pre.txt | gawk -v zoff="${ZOFFSET_NUM}" '{print $1+zoff, $2+zoff, $3+zoff, $4+zoff, $5+zoff}' > ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilesummary.txt

        # profilesummary.txt is min q1 q2 q3 max
        #           1  2   3  4  5   6
        # gmt wants X q2 min q1 q3 max

        paste ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilekm.txt ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilesummary.txt | tr '\t' ' ' | gawk '{print $1, $4, $2, $3, $5, $6}' > ${F_PROFILES}${LINEID}_${grididnum[$i]}_quantile_data.txt

        # quantile_data.txt has 6 elements: X min q1 q2 q3 max

cleanup ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilesummary.txt
        gawk '{print $1, $2}' < ${F_PROFILES}${LINEID}_${grididnum[$i]}_quantile_data.txt > ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledatamedian.txt
        gawk '{print $1, $3}' < ${F_PROFILES}${LINEID}_${grididnum[$i]}_quantile_data.txt > ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledatamin.txt
        gawk '{print $1, $6}' < ${F_PROFILES}${LINEID}_${grididnum[$i]}_quantile_data.txt > ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledatamax.txt
# cleanup ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledatamedian.txt
cleanup ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledatamin.txt ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledatamax.txt
        # Makes an envelope plottable by GMT
        gawk '{print $1, $4}' < ${F_PROFILES}${LINEID}_${grididnum[$i]}_quantile_data.txt > ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledataq13min.txt
        gawk '{print $1, $5}' < ${F_PROFILES}${LINEID}_${grididnum[$i]}_quantile_data.txt > ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledataq13max.txt
cleanup ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledataq13min.txt ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledataq13max.txt

        cat ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledatamax.txt > ${F_PROFILES}${LINEID}_${grididnum[$i]}_profileenvelope.txt
        tecto_tac ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledatamin.txt >> ${F_PROFILES}${LINEID}_${grididnum[$i]}_profileenvelope.txt
# cleanup ${F_PROFILES}${LINEID}_${grididnum[$i]}_profileenvelope.txt

        cat ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledataq13min.txt > ${F_PROFILES}${LINEID}_${grididnum[$i]}_profileq13envelope.txt
        tecto_tac ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledataq13max.txt >> ${F_PROFILES}${LINEID}_${grididnum[$i]}_profileq13envelope.txt
# cleanup ${F_PROFILES}${LINEID}_${grididnum[$i]}_profileq13envelope.txt

        if [[ ${gridtypelist[$i]} == "S" ]]; then
          # PLOT ON THE COMBINED PS
          echo "gmt psxy -Vn ${F_PROFILES}${LINEID}_${grididnum[$i]}_profileenvelope.txt -t$SWATHTRANS -R -J -O -K -G${LIGHTERCOLOR}  >> "${PSFILE}"" >> plot.sh
          echo "gmt psxy -Vn -R -J -O -K -t$SWATHTRANS -G${LIGHTCOLOR} ${F_PROFILES}${LINEID}_${grididnum[$i]}_profileq13envelope.txt >> "${PSFILE}"" >> plot.sh
          echo "gmt psxy -Vn -R -J -O -K -W$SWATHLINE_WIDTH,$COLOR ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledatamedian.txt >> "${PSFILE}"" >> plot.sh

          # PLOT ON THE FLAT PROFILE PS
          echo "gmt psxy -Vn ${F_PROFILES}${LINEID}_${grididnum[$i]}_profileenvelope.txt -t$SWATHTRANS -R -J -O -K -G${LIGHTERCOLOR}  >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh
          echo "gmt psxy -Vn -R -J -O -K -t$SWATHTRANS -G${LIGHTCOLOR} ${F_PROFILES}${LINEID}_${grididnum[$i]}_profileq13envelope.txt >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh
          echo "gmt psxy -Vn -R -J -O -K -W$SWATHLINE_WIDTH,$COLOR ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledatamedian.txt >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh

          # This is where the -proftopo option is implemented. If a third argument is passed to
          # plot_flat_profiles.sh, then use that as the height of the flat profile.

          echo "if [[ \$3 != \"\" ]]; then" >> ${LINEID}_temp_profiletop.sh

            topoprofiletype="median"
            topoprofiletype="max"

            # Set the elevation range for the topo topper; make zmax be zero if everything is under water.
            echo "LINERANGE=(\$(gawk < ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledata${topoprofiletype}.txt 'BEGIN { getline; minz=\$2; maxz=\$2 } { minz=(\$2<minz)?\$2:minz; maxz=(\$2>maxz)?\$2:maxz } END { if (maxz<0) { maxz=0 }; print minz-(maxz-minz)/5, maxz+(maxz-minz)/10 }'))" >> ${LINEID}_temp_profiletop.sh
            echo "gmt psxy -T -R\${line_min_x}/\${line_max_x}/\${LINERANGE[0]}/\${LINERANGE[1]} -Y\${PROFILE_HEIGHT_IN} -JX\${PROFILE_WIDTH_IN}/\${PROFILE_TOPPER_HEIGHT_IN} -O -K >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_profiletop.sh

            # If the minimum elevation of the profile is below sea level and the maximum is above sea level
            echo "echo \"\${line_min_x} 0T\${line_max_x} 0T\${line_max_x} \${LINERANGE[0]}T\${line_max_x} \${LINERANGE[0]}T\${line_min_x} \${LINERANGE[0]}T\${line_min_x} 0\" | tr 'T' '\n' | gmt psxy -Vn -L+yb -Glightblue -R -J -O -K -W0.25p,0/0/0 >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_profiletop.sh
            # echo "if [[ \$(echo \"\${LINERANGE[0]} < 0 && \${LINERANGE[1]} > 0\" | bc) -eq 1 ]]; then echo \"\${line_min_x} 0T\${line_max_x} 0T\${line_max_x} \${LINERANGE[0]}T\${line_max_x} \${LINERANGE[0]}T\${line_min_x} \${LINERANGE[0]}T\${line_min_x} 0\" | tr 'T' '\n' | gmt psxy -Vn -L+yb -Glightblue -R -J -O -K -W0.25p,0/0/0 >> ${F_PROFILES}${LINEID}_flat_profile.ps; fi" >> ${LINEID}_temp_profiletop.sh
            # echo "if [[ \$(echo \"\${LINERANGE[0]} < 0 && \${LINERANGE[1]} < 0\" | bc) -eq 1 ]]; then echo \"\${line_min_x} \${LINERANGE[1]}T\${line_max_x} \${LINERANGE[1]}T\${line_max_x} \${LINERANGE[0]}T\${line_max_x} \${LINERANGE[0]}T\${line_min_x} \${LINERANGE[0]}T\${line_min_x} \${LINERANGE[1]}\" | tr 'T' '\n' | gmt psxy -Vn -L+yb -Glightblue -R -J -O -K -W0.25p,0/0/0 >> ${F_PROFILES}${LINEID}_flat_profile.ps; fi" >> ${LINEID}_temp_profiletop.sh

            echo "gmt psxy -Vn -L+yb -Gtan -R -J -O -K -W0.25p,0/0/0 ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledata${topoprofiletype}.txt >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_profiletop.sh
            echo "gmt psbasemap -J -R -BWEb -O -K -Byaf --MAP_FRAME_PEN=thinner,black --FONT_ANNOT_PRIMARY=\"6p,Helvetica,black\" >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_profiletop.sh
          echo "fi" >> ${LINEID}_temp_profiletop.sh


          # PLOT ON THE OBLIQUE PROFILE PS
          [[ $PLOT_SECTIONS_PROFILEFLAG -eq 1 ]] &&  echo "gmt psxy -p -Vn ${F_PROFILES}${LINEID}_${grididnum[$i]}_profileenvelope.txt -t$SWATHTRANS -R -J -O -K -G${LIGHTERCOLOR}  >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_plot.sh
          [[ $PLOT_SECTIONS_PROFILEFLAG -eq 1 ]] &&  echo "gmt psxy -p -Vn -R -J -O -K -t$SWATHTRANS -G${LIGHTCOLOR} ${F_PROFILES}${LINEID}_${grididnum[$i]}_profileq13envelope.txt >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_plot.sh
          [[ $PLOT_SECTIONS_PROFILEFLAG -eq 1 ]] &&  echo "gmt psxy -p -Vn -R -J -O -K -W$SWATHLINE_WIDTH,$COLOR ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledatamedian.txt >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_plot.sh

        # Box-and-whisker diagram
        fi
        if [[ ${gridtypelist[$i]} == "W" ]]; then
          # PLOT ON THE COMBINED PS

          if [[ ${gridcptlist[$i]} == "None" ]]; then
            boxcptcmd="-Ggray"
            boxfile=${F_PROFILES}${LINEID}_${grididnum[$i]}_quantile_data.txt
          else
            boxcptcmd="-C${gridcptlist[$i]}"
            gawk < ${F_PROFILES}${LINEID}_${grididnum[$i]}_quantile_data.txt -v zscale=${gridzscalelist[$i]} '{print $1, $2, $2/zscale, $3, $4, $5, $6}' > ${F_PROFILES}${LINEID}_${grididnum[$i]}_quantile_cpt.txt
            boxfile=${F_PROFILES}${LINEID}_${grididnum[$i]}_quantile_cpt.txt
          fi

          # To set the bin width, we determine the number of bins and the width of the image in points
          numboxbins=$(wc -l < ${boxfile})

          echo "width_p=\$(echo \"\${PROFILE_WIDTH_IN}\" | gawk '{print (\$1+0)*72}')" >> plot.sh
          echo "binwidth_p=\$(echo \"(\${width_p} / ${numboxbins})*0.9\" | bc -l)" >> plot.sh
          # echo "echo $numboxbins bins over \${width_p} = \$binwidth_p" >> plot.sh
          echo "gmt psxy  ${boxfile} -EY+p0.1p+w\${binwidth_p}p ${boxcptcmd} -Sp -R -J -O -K >> "${PSFILE}"" >> plot.sh

          # PLOT ON THE FLAT PROFILE PS
          echo "width_p=\$(echo \"\${PROFILE_WIDTH_IN}\" | gawk '{print (\$1+0)*72}')" >> ${LINEID}_temp_plot.sh
          echo "binwidth_p=\$(echo \"(\${width_p} / ${numboxbins})*0.9\" | bc -l)" >> ${LINEID}_temp_plot.sh
          echo "gmt psxy  ${boxfile} -EY+p0.1p+w\${binwidth_p}p -Sp ${boxcptcmd} -R -J -O -K >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh

          # PLOT ON THE OBLIQUE PROFILE PS
          echo "width_p=\$(echo \"\${PROFILE_WIDTH_IN}\" | gawk '{print (\$1+0)*72}')" >> ${LINEID}_plot.sh
          echo "binwidth_p=\$(echo \"(\${width_p} / ${numboxbins})*0.9\" | bc -l)" >> ${LINEID}_plot.sh
          [[ $PLOT_SECTIONS_PROFILEFLAG -eq 1 ]] &&  echo "gmt psxy -p -Vn ${boxfile} -EY+p0.1p+w\${binwidth_p}p -Sp ${boxcptcmd} -R -J -O -K >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_plot.sh

        fi

        update_profile_bounds 1 100 < ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilekm.txt
        update_profile_bounds 100 1,5 < ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilesummary.txt
      fi
    done

    # RGB image data

    for i in ${!imagefilelist[@]}; do

      # Clip the image using the profile path
      crop_name="crop_${LINEID}_$(basename ${imagefilelist[$i]})"
      gdalwarp -cutline ${F_PROFILES}${LINEID}_trackfile_buffer.json -crop_to_cutline ${imagefilelist[$i]} ${crop_name}
      gdal2xyz.py -skipnodata -allbands ${crop_name} ${F_PROFILES}tmp2.txt

      # ogr2ogr -f "GeoJSON" -dialect SQLite -sql "ST_Transform(ST_Buffer(ST_Transform(geometry,${UTMZONE}), ${bufdistance}, ST_Buffer_Strategy('end_flat')), 4326)"
      # ogr2ogr -f "GeoJSON" out.json ${F_PROFILES}${LINEID}_trackfile_buffer.json -dialect sqlite -sql "select ST_buffer(geometry, [1000]) as geometry FROM [${F_PROFILES}${LINEID}_trackfile_buffer]"

      # ST_Buffer(@ls, 5, @end_strategy, @join_strategy))
      # Take a point, cast it to EPSG3857 (web mercator), buffer 200 meters, cast it back to WGS84
      # ogr2ogr -f "GeoJSON" out.json -dialect sqlite -sql "SELECT ST_Transform(ST_Buffer(ST_Transform(MakePoint(5.7245, 45.1885,4326),3857), 200, 8), 4326);"

      project_xyz_pts_onto_track ${F_PROFILES}${LINEID}_trackfile.txt ${F_PROFILES}tmp2.txt ${F_PROFILES}projpts_projected_${imageidnum[$i]}.txt ${XOFFSET_NUM} ${ZOFFSET_NUM} ${imagezscalelist[$i]} grid_z ${F_TOPO}dem.tif select_swath $(echo ${imagewidthlist[$i]} | gawk '{print ($1+0)/2}') select_out xprime zprime

      gawk < ${F_PROFILES}projpts_projected_${imageidnum[$i]}.txt '{rgb = $3; rgb = lshift(rgb,8) + $4; rgb = lshift(rgb,8) + $5; print $1, $2, rgb}' > ${F_PROFILES}a.txt

      if [[ ! -s ${F_CPTS}rgb_from_int.cpt ]]; then
        gawk 'BEGIN {
          for(i=0;i<256*256*256;++i) {
            print i, and(rshift(i,16), 0x0ff) "/" and(rshift(i,8),0x0ff) "/" and(i,0x0ff)
          }
        }' > ${F_CPTS}rgb_from_int.cpt
      fi

      [[ -e ${F_PROFILES}a.txt ]] && echo "gmt psxy ${F_PROFILES}a.txt -Sc0.03i -t50 -C${F_CPTS}rgb_from_int.cpt $RJOK $VERBOSE  >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh
    done

    # XYZ data
    for i in ${!xyzfilelist[@]}; do

      FNAME=$(echo -n "${LINEID}_"$i"projdist.txt")
      FNAME_alt=$(echo -n "${LINEID}_"$i"projdist_alt.txt")

      # Width is half of the full track width, in km
      project_xyz_pts_onto_track ${F_PROFILES}${LINEID}_trackfile.txt ${xyzfilelist[$i]} ${F_PROFILES}${FNAME_alt} ${XOFFSET_NUM} ${ZOFFSET_NUM} ${xyzunitlist[$i]} select_swath $(echo ${xyzwidthlist[$i]} | gawk '{print ($1+0)/2}') select_out xprime zprime z

      # # Can select points to right or left of line using azimuths
      #
      # # We need to calculate the azimuths of the trackfile segments
      # # ${F_PROFILES}az_${LINEID}_trackfile.txt
      #
      # # The following code is not currently used:
      #       #
      #       # gawk < ${F_PROFILES}$FNAME '{print $1, $2, $(NF-1), $(NF)}' | gawk  '
      #       # @include "tectoplot_functions.awk"
      #       # # function acos(x) { return atan2(sqrt(1-x*x), x) }
      #       #     {
      #       #       if ($1 == ">") {
      #       #         print $1, $2;
      #       #       }
      #       #       else {
      #       #         lon1 = deg2rad($1)
      #       #         lat1 = deg2rad($2)
      #       #         lon2 = deg2rad($3)
      #       #         lat2 = deg2rad($4)
      #       #         Bx = cos(lat2)*cos(lon2-lon1);
      #       #         By = cos(lat2)*sin(lon2-lon1);
      #       #         latMid = atan2(sin(lat1)+sin(lat2), sqrt((cos(lat1)+Bx)*(cos(lat1)+Bx)+By*By));
      #       #         lonMid = lon1+atan2(By, cos(lat1)+Bx);
      #       #         theta = atan2(sin(lon2-lon1)*cos(lat2), cos(lat1)*sin(lat2)-sin(lat1)*cos(lat2)*cos(lon2-lon1));
      #       #         d = acos(sin(lat1)*sin(lat2) + cos(lat1)*cos(lat2)*cos(lon2-lon1) ) * 6371;
      #       #         printf "%.5f %.5f %.3f %.3f\n", rad2deg(lonMid), rad2deg(latMid), (rad2deg(theta)+360-90)%360, d;
      #       #       };
      #       #     }' > ${F_PROFILES}azimuths_$FNAME

      # gawk < ${F_PROFILES}${FNAME_alt} '{print $1, $2, $2, $2, $2, $2 }' >> ${F_PROFILES}${LINEID}_all_data.txt

      if [[ ! -s ${F_PROFILES}${FNAME_alt} ]]; then
        echo empty
        continue
      fi

      update_profile_bounds 1 2 < ${F_PROFILES}${FNAME_alt}

      # SEIS_INPUTORDER="-i0,1,2,3+s${SEISSCALE}"
      # SEIS_CPT=$SEISDEPTH_CPT

      if [[ ${xyzscaleeqsflag[$i]} -eq 1 ]]; then

        ##########################################################################
        # Plot earthquake data scaled by magnitude


        # PLOT ON THE STACKED PROFILE PS
        echo "cat ${F_PROFILES}${FNAME_alt} | gmt_psxy ${xyzcommandlist[$i]} ${RJOK} ${VERBOSE} >> ${PSFILE}"  >> plot.sh

        # PLOT ON THE FLAT PROFILE PS
        echo "cat ${F_PROFILES}${FNAME_alt} | gmt_psxy ${xyzcommandlist[$i]} ${RJOK} ${VERBOSE} >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh

        # echo "gmt psxy ${F_PROFILES}${FNAME_alt} --PROJ_LENGTH_UNIT=p -G${COLOR} ${SEIS_INPUTORDER} -S${SEISSYMBOL} ${xyzcommandlist[$i]} -C$SEIS_CPT $RJOK ${VERBOSE}  >> ${PSFILE}" >> plot.sh
        #
        # echo "gmt psxy ${F_PROFILES}${FNAME_alt} --PROJ_LENGTH_UNIT=p -G${COLOR} ${SEIS_INPUTORDER} -S${SEISSYMBOL} ${xyzcommandlist[$i]} -C$SEIS_CPT $RJOK ${VERBOSE}  >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh

        # PLOT ON THE OBLIQUE SECTION PS
        [[ $PLOT_SECTIONS_PROFILEFLAG -eq 1 ]] && echo "cat ${F_PROFILES}${FNAME_alt} | gmt_psxy ${xyzcommandlist[$i]} -p ${RJOK} ${VERBOSE} >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_plot.sh
        # [[ $PLOT_SECTIONS_PROFILEFLAG -eq 1 ]] &&  echo "gmt psxy ${F_PROFILES}${FNAME_alt} --PROJ_LENGTH_UNIT=p -G${COLOR} ${SEIS_INPUTORDER} -S${SEISSYMBOL} ${xyzcommandlist[$i]} -C$SEIS_CPT $RJOK ${VERBOSE} >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_plot.sh

      else

        # Interpolate 3D data projected onto profile surface

        if [[ ${xyzgridflag[$i]} -eq 1 && -s ${F_PROFILES}${FNAME_alt} ]]; then
            # Discover the distance and depth ranges of the projected data
            PROJRANGE=($(xy_range ${F_PROFILES}finaldist_${FNAME}))
            MAXXRANGE=$(echo "${PROJRANGE[1]}+100" | bc -l)

            # Generate the gridded image over the relevant XY range

            # What is the resolution we want from gmt surface? Calculate it from
            # the input data using the difference between the first two unique
            # sorted coordinates

            if [[ ${gridresautoflag} -eq 1 ]]; then
              gridresolutionX=$(cut -f 1 -d ' ' ${F_PROFILES}finaldist_${FNAME} | sort -n | gawk 'BEGIN {diff=0; getline; oldval=$1} ($1 != oldval) { print (($1-oldval)>0)?($1-oldval):(oldval-$1); exit }')
              gridresolutionY=$(cut -f 2 -d ' ' ${F_PROFILES}finaldist_${FNAME} | sort -n | gawk 'BEGIN {diff=0; getline; oldval=$1} ($1 != oldval) { print (($1-oldval)>0)?($1-oldval):(oldval-$1); exit }')
            fi

            # change resolution by subsampling factor here
            gridsubsampleX=1
            gridsubsampleY=1

            gridresolutionX=$(echo "${gridresolutionX} / ${gridsubsampleX}" | bc -l)
            gridresolutionY=$(echo "${gridresolutionY} / ${gridsubsampleY}" | bc -l)

            gmt surface ${F_PROFILES}${FNAME_alt} -R0/${MAXXRANGE}/${PROJRANGE[2]}/${PROJRANGE[3]} -Gxyzgrid_${FNAME}.nc -i0,1,3 -I${gridresolutionX}k/${gridresolutionY}k ${VERBOSE} >/dev/null 2>&1

            # PLOT ON THE COMBINED PROFILE PS

            if [[ ${xyzgridcptflag[$i]} -eq 1 ]]; then
              CPTSTRING="${xyzgridcptlist[$i]}"
            else
              CPTSTRING="${F_CPTS}tomography.cpt"
            fi
            # interp="-nl"
            interp=""

            echo "gmt grdimage xyzgrid_${FNAME}.nc ${interp} -C${CPTSTRING} -R -J -O -K  -Vn >> "${PSFILE}"" >> plot.sh

            # PLOT ON THE FLAT SECTION PS
            echo "gmt grdimage xyzgrid_${FNAME}.nc ${interp} -C${CPTSTRING} -R -J -O -K  -Vn >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh
            # echo "gmt psxy ${F_PROFILES}finaldist_${FNAME} -Sc0.01i -Gblack -R -J -O -K >> ${PSFILE}" >> plot.sh

            # PLOT ON THE OBLIQUE SECTION PS
            [[ $PLOT_SECTIONS_PROFILEFLAG -eq 1 ]] &&  echo "gmt grdimage xyzgrid_${FNAME}.nc -p ${interp} -C${CPTSTRING} -R -J -O -K  -Vn >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_plot.sh

            # gmt grdimage tomography.nc -Cseis
        else

          # If it's just a generic psxy call

          # PLOT ON THE COMBINED PROFILE PS
          echo "gmt psxy ${F_PROFILES}${FNAME_alt} -G$COLOR ${xyzcommandlist[$i]} -R -J -O -K  -Vn  >> "${PSFILE}"" >> plot.sh

          # PLOT ON THE FLAT SECTION PS
          echo "gmt psxy ${F_PROFILES}${FNAME_alt} -G$COLOR ${xyzcommandlist[$i]} -R -J -O -K  -Vn >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh

          # PLOT ON THE OBLIQUE SECTION PS
          [[ $PLOT_SECTIONS_PROFILEFLAG -eq 1 ]] &&  echo "gmt psxy ${F_PROFILES}${FNAME_alt} -p -G$COLOR ${xyzcommandlist[$i]} -R -J -O -K  -Vn  >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_plot.sh
        fi
      fi

      rm -f presort_${FNAME}
    done # XYZ data

    # Focal mechanisms

    for i in ${!cmtfilelist[@]}; do
      CMT_HALFWIDTH=$(echo "${cmtwidthlist[$i]} / 2" | bc -l)

      # Project CMT data onto the current track
      project_xyz_pts_onto_track ${F_PROFILES}${LINEID}_trackfile.txt ${cmtfilelist[$i]} ${F_PROFILES}${LINEID}_cmt1.txt ${XOFFSET_NUM} ${ZOFFSET_NUM} -1  select_swath ${CMT_HALFWIDTH} select_out fracint lon lat z xprime zprime

      if [[ -s ${F_PROFILES}${LINEID}_cmt1.txt ]]; then

        update_profile_bounds 5 6 < ${F_PROFILES}${LINEID}_cmt1.txt

        numprofpts=$(wc -l < ${F_PROFILES}${LINEID}_trackfile.txt)
        numsegs=$(echo "$numprofpts - 1" | bc)

        shopt -s nullglob

        # Note that psmeca projects to a slightly different location than gmt mapproject
        # psmeca uses a local UTM zone calculation while mapproject is more general
        mkdir -p savedAa

        cur_x=0
        for segind in $(seq 1 $numsegs); do
          segind_p=$(echo "$segind + 1" | bc -l)

          p1_x=$(cat ${F_PROFILES}${LINEID}_trackfile.txt | head -n ${segind} | tail -n 1 | gawk 'BEGIN { OFMT="%.12f"} {print $1}')
          p1_z=$(cat ${F_PROFILES}${LINEID}_trackfile.txt | head -n ${segind} | tail -n 1 | gawk 'BEGIN { OFMT="%.12f"} {print $2}')
          p2_x=$(cat ${F_PROFILES}${LINEID}_trackfile.txt | head -n ${segind_p} | tail -n 1 | gawk 'BEGIN { OFMT="%.12f"} {print $1}')
          p2_z=$(cat ${F_PROFILES}${LINEID}_trackfile.txt | head -n ${segind_p} | tail -n 1 | gawk 'BEGIN { OFMT="%.12f"} {print $2}')
          add_x=$(cat ${F_PROFILES}${LINEID}_dist_km.txt | head -n $segind_p | tail -n 1)

          gawk < ${F_PROFILES}${LINEID}_cmt1.txt -v num=${segind} '
          {
            if ($1+0==num+0) {
              $1=""
              print $0
            }
          }' > seg_$segind.txt

          # pscoupe only projects orthogonally onto lines, whereas mapproject will
          # project at any angle. This will result in some focal mechanisms not
          # being projected onto line segments if they fall along a tight outside
          # angle of a kinked profile. Because the strike of the profile is not
          # well defined for these points, it is hard to imagine how to put them
          # onto a profile in any case. There are two options:
          # 1. omit the points the way pscoupe wants to
          # 2. somehow determine how to project the points so that the mapproject
          #    and pscoupe locations/strikes are self consistent and the strike
          #    of the profile is meaningful

          # 161.120000000000 -10.140000000000 33 722.287 -33 7.78206 -6.33816 -1.4439 -0.465227 3.40303 5.20411 24 160.52 -9.95 B101889C+usp00040w6 53.8 624714048 0 1989-10-18T11:40:48
          # 0                1                2  3       4   5       6        7       8         9       10      11 12     13    14
          # X Y depth mrr mtt mff mrt mrf mtf exp [newX newY] [event_title]

          # 0         1         2         3        4        5         6        7        8        9  10 11 12                        13   14         15   16
          # 35.436849 10.000000 10.000000 0.045802 0.689186 -0.734427 0.068807 0.185450 0.672789 21 0  0  C201511112053A+us10003xm9 19.2 1447275185 0    2015-11-11T20:53:05


          # When the alternative location fields are "none", then pscoupe craps out and passes those as
          # trailing text that gets confused with the ID field. So we need to filter those events out
          # by replacing those values with 0 
          gawk < seg_${segind}.txt '{
            if ($13=="none" && $14=="none") {
              $13="0"
              $14="0"
            }
            print $0
          }' |  gmt pscoupe -i0,1,2,5-11,t -R-100000/100000/-100/7000 -JX5i/-2i -Aa$p1_x/$p1_z/$p2_x/$p2_z+d90 -S${CMTLETTER}0.05i -Xc -Yc > /dev/null

          rm -f Aa*_map

          projected_focals=$(ls Aa* | head -n 1)
          cp ${projected_focals} ${LINEID}projfoc_${segind}.txt
          projected_focals_num=$(wc -l < ${projected_focals})
          startnum=$(wc -l < seg_$segind.txt)

          if [[ $(echo "$startnum == $projected_focals_num" | bc) != 1 ]]; then
            info_msg "[-c]: Lost $(echo "$startnum - $projected_focals_num" | bc) focal mechanisms during projection onto profile segment ${LINEID}_${segid}"
          fi

          # lon lat z xprime zprime
          gawk '
          # Look first at the file of ALL focal mechanisms projected using mapproject
          (ARGIND==1) {
            # Save the index number based on the ID code
            projid[$15]=FNR
            xprime[FNR]=$4
            zprime[FNR]=$5
            z[FNR]=$3
          }
          (ARGIND==2) {
          # Look at the focal mechanisms projected by pscoupe
            # get the saved index number based on the ID code
            id=projid[$13]
            $1=xprime[id]
            $2=zprime[id]
            $3=z[id]
            print $0
          }' seg_$segind.txt ${projected_focals} > fix_$segind.txt

          rm -f Aa*

          # We can plot the alternative locations of ALL events, even the ones
          # that pscoupe cannot project
          if [[ $connectalternatelocflag -eq 1 ]]; then
            rm -f ./cmt_alt_pts_1.txt
            rm -f ./cmt_alt_pts_2.txt
  # 155.890000000000 -7.860000000000 26 119.73 -26 2.94849 0.404695 -3.35319 1.18518  -2.22582 2.05238 v22 none   none  gfz2014btds    none 1390669212 0 2014-01-25T17:00:12
  # 1                2               3  4       5   6      7        8        9        10       11       12 13     14    15             16   17

            gawk < seg_$segind.txt '{
              # If the event has an alternative position
              if ($13 != "none" && $14 != "none")  {
                print $1, $2, $3, NR, $15   >> "./cmt_alt_pts_1.txt"
                print $13, $14, $16, NR, $15 >> "./cmt_alt_pts_2.txt"
              }
            }'

            project_xyz_pts_onto_track ${F_PROFILES}${LINEID}_trackfile.txt ./cmt_alt_pts_1.txt cmt_altpts_1_${segind}.txt ${XOFFSET_NUM} ${ZOFFSET_NUM} -1 no_remove select_out xprime zprime
            project_xyz_pts_onto_track ${F_PROFILES}${LINEID}_trackfile.txt ./cmt_alt_pts_2.txt cmt_altpts_2_${segind}.txt ${XOFFSET_NUM} ${ZOFFSET_NUM} -1 no_remove select_out xprime zprime

            sort < cmt_altpts_1_${segind}.txt -n -k3,3 > sort_tmp1.txt
            sort < cmt_altpts_2_${segind}.txt -n -k3,3 > sort_tmp2.txt

            paste -d '\n' sort_tmp1.txt sort_tmp2.txt | gawk '(NR==1 || NR%2==1) {printf(">\n"); } { print }' > cmt_altlines_${segind}.txt

            rm -f sort_tmp1.txt sort_tmp2.txt

            if [[ $segind -eq 1 ]]; then
              echo "[[ -s ${F_PROFILES}${LINEID}_${i}cmt_altpts_1.txt ]] && gmt psxy ${F_PROFILES}${LINEID}_${i}cmt_altpts_1.txt -Sc0.03i -Gblack $RJOK ${VERBOSE} >> ${PSFILE}" >> plot.sh
              echo "[[ -s ${F_PROFILES}${LINEID}_${i}cmt_altpts_2.txt ]] && gmt psxy ${F_PROFILES}${LINEID}_${i}cmt_altpts_2.txt -Sc0.03i -Gblack $RJOK ${VERBOSE} >> ${PSFILE}" >> plot.sh
              echo "[[ -s ${F_PROFILES}${LINEID}_${i}cmt_altlines.txt ]] && gmt psxy ${F_PROFILES}${LINEID}_${i}cmt_altlines.txt -W0.21p,red $RJOK ${VERBOSE} >> ${PSFILE}" >> plot.sh

              echo "[[ -s ${F_PROFILES}${LINEID}_${i}cmt_altpts_1.txt ]] && gmt psxy ${F_PROFILES}${LINEID}_${i}cmt_altpts_1.txt -Sc0.03i -Gblack $RJOK ${VERBOSE} >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh
              echo "[[ -s ${F_PROFILES}${LINEID}_${i}cmt_altpts_2.txt ]] && gmt psxy ${F_PROFILES}${LINEID}_${i}cmt_altpts_2.txt -Sc0.03i -Gblack $RJOK ${VERBOSE} >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh
              echo "[[ -s ${F_PROFILES}${LINEID}_${i}cmt_altlines.txt ]] && gmt psxy ${F_PROFILES}${LINEID}_${i}cmt_altlines.txt -W0.22p,black $RJOK ${VERBOSE} >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh
            fi
          fi
        done

        cat fix_*.txt > ${F_PROFILES}${LINEID}_${i}cmt_fixed.txt

        if [[ $connectalternatelocflag -eq 1 ]]; then
          cat cmt_altpts_1_*.txt > ${F_PROFILES}${LINEID}_${i}cmt_altpts_1.txt
          cat cmt_altpts_2_*.txt > ${F_PROFILES}${LINEID}_${i}cmt_altpts_2.txt
          cat cmt_altlines_*.txt > ${F_PROFILES}${LINEID}_${i}cmt_altlines.txt
        fi

        rm -f ./savedAa/*
        rmdir ./savedAa/

        if [[ $zctimeflag -eq 1 ]]; then
            gawk < ${F_PROFILES}${LINEID}_${i}cmt_fixed.txt '{temp=$3; $3=$17; print}' > ${F_PROFILES}${LINEID}_${i}cmt_fixed_time.txt
            mv ${F_PROFILES}${LINEID}_${i}cmt_fixed.txt ${F_PROFILES}${LINEID}_${i}cmt_fixed_save.txt
            mv ${F_PROFILES}${LINEID}_${i}cmt_fixed_time.txt ${F_PROFILES}${LINEID}_${i}cmt_fixed.txt
        elif [[ $zcclusterflag -eq 1 ]]; then
            gawk < ${F_PROFILES}${LINEID}_${i}cmt_fixed.txt '{temp=$3; $3=$16; print}' > ${F_PROFILES}${LINEID}_${i}cmt_fixed_time.txt
            mv ${F_PROFILES}${LINEID}_${i}cmt_fixed.txt ${F_PROFILES}${LINEID}_${i}cmt_fixed_save.txt
            mv ${F_PROFILES}${LINEID}_${i}cmt_fixed_time.txt ${F_PROFILES}${LINEID}_${i}cmt_fixed.txt
        fi

        echo "gmt psmeca ${F_PROFILES}${LINEID}_${i}cmt_fixed.txt -N -Tn/${CMT_LINEWIDTH},${CMT_LINECOLOR} -S${CMTLETTER}"${CMTRESCALE}"i/0 -L${CMT_LINEWIDTH},${CMT_LINECOLOR} ${cmtcommandlist[$i]} -C${CMT_CPT} $RJOK "${VERBOSE}" >> "${PSFILE}"" >> plot.sh
        echo "gmt psmeca ${F_PROFILES}${LINEID}_${i}cmt_fixed.txt -N -Tn/${CMT_LINEWIDTH},${CMT_LINECOLOR} -S${CMTLETTER}"${CMTRESCALE}"i/0 -L${CMT_LINEWIDTH},${CMT_LINECOLOR} ${cmtcommandlist[$i]} -C${CMT_CPT} $RJOK "${VERBOSE}" >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh


        # PLOT ON THE OBLIQUE SECTION PS
        [[ $PLOT_SECTIONS_PROFILEFLAG -eq 1 ]] &&  echo "gmt psmeca ${F_PROFILES}${LINEID}_${i}cmt_fixed.txt -p -N -Tn/${CMT_LINEWIDTH},${CMT_LINECOLOR} -S${CMTLETTER}${CMTRESCALE}i/0 -L${CMT_LINEWIDTH},${CMT_LINECOLOR} ${cmtcommandlist[$i]} -C${CMT_CPT} $RJOK ${VERBOSE} >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_plot.sh

      fi
    done
    # fi

    # GPS data
    for i in ${!vectorfilelist[@]}; do
      FNAME=$(echo -n "${LINEID}_"$i"_vector_projdist.txt")
      FNAME_alt=$(echo -n "${LINEID}_"$i"_vector_projdist_alt.txt")

      # Width is half of the full track width, in km
      project_xyz_pts_onto_track ${F_PROFILES}${LINEID}_trackfile.txt ${vectorfilelist[$i]} ${F_PROFILES}${FNAME_alt} ${XOFFSET_NUM} ${ZOFFSET_NUM} ${vectorscalelist[$i]} select_swath $(echo ${vectorwidthlist[$i]} | gawk '{print ($1+0)/2}') select_out lon lat lonproj latproj fracint xprime z
      # 24.071000000000 35.533000000000 23.810419000000 35.533280250951 3.20484 8.603 -10.522 0.34 0.311 0 TUC2 UNR

      # Project the velocity vectors onto the relevant profile segments, accounting
      # for the orientation of the uncertainty ellipses versus the profiles

      gawk '
        @include "tectoplot_functions.awk"
        # Load the azimuths of each profile segment and calculate the back-azimuth to the profile
        BEGIN {
          OFMT="%.12f"
        }
        (NR==FNR) {
          az[NR]=($3+90)%360
        }
        (NR!=FNR) {
          lon=$1
          lat=$2
          projlon=$3
          projlat=$4
          fracint=$5
          xdist=$6
          ve=$7
          vn=$8
          sve=$9
          svn=$10
          corr=$11
          id=$12
          source=$13
          azss=azimuth_2pt(projlon, projlat, lon, lat)
          az1=(-az[fracint] + 450)%360
          azrad=deg2rad(az[fracint])
          azradp=deg2rad(az[fracint]+90)

          # v is the total velocity
          v=sqrt(ve*ve+vn*vn)

          # azss is the azimuth back to the projected point on the profile, CW from North
          # az[fracint] is the azimuth of the profile segment, CW from North,
          #   pointing from the beginning point to end point of the segment
          # az1 is the azimuth of the profile, CCW from East
          # ang is the angle of the a axis of the ellise CCW from East

          # print "Az of segment", fracint, "is", az[fracint], "and az from pt", lon, lat, "to projpt", projlon, projlat, "is", azss

          # az is deg CW from N, we need degrees CCW from east

          # comp1 is the along-profile component of velocity, positive in the
          # direction of the drawn profile

          comp1=(ve*sin(azrad)+vn*cos(azrad))
          comp1_ve=comp1*cos(azrad)
          comp1_vn=comp1*sin(azrad)

          # comp2 is the across-profile component of velocity, positive when
          # the motion is to the right while looking forward along the profile

          comp2=(ve*sin(azradp)+vn*cos(azradp))
          comp2_ve=comp2*cos(azradp)
          comp2_vn=comp2*sin(azradp)

          # Calculate the projected along-profile and across-profile uncertainties
          # These are the widths of the error ellipse, in mm/yr, along the
          # azimuth of the profile line.

          a = square(svn*svn - sve*sve)
          b = 4 * square(corr*sve*svn)
          c = square(sve) + square(svn)
          eigen1 = sqrt ((c + sqrt(a + b))/2.0)
          eigen2 = sqrt ((c - sqrt(a + b))/2.0)
        	d = 2 * corr * sve * svn
        	e = square(sve) - square(svn)

          # ang is the angle of the a axis of the ellipse, measured
          # counter-clockwise from the X axis (East)

        	ang = rad2deg(atan2(d, e)/2)

          # the error interval is the half-distance between two lines
          # perpendicular to the profile and tangent to the ellipse

          # err1 is the along-profile uncertainty interval
          err1=sqrt(square(eigen1*cos(deg2rad(ang-az1))) + square(eigen2*sin(deg2rad(ang-az1))))

          # err2 is the across-profile uncertainty interval
          err2=sqrt(square(eigen1*cos(deg2rad(ang-az1+90))) + square(eigen2*sin(deg2rad(ang-az1+90))))

          print xdist, comp1, err1, comp2, err2, lon, lat, projlon, projlat, azss, az[fracint], comp1_vn, comp1_ve, comp2_vn, comp2_ve, id, source

        }
      ' ${F_PROFILES}az_${LINEID}_trackfile.txt ${F_PROFILES}${FNAME_alt} > ${F_PROFILES}${LINEID}_gps_data.txt

      update_profile_bounds 1 2,4 < ${F_PROFILES}${LINEID}_gps_data.txt

      echo "gmt psxy ${F_PROFILES}${LINEID}_gps_data.txt -Gwhite -W0.5p,blue -Sc0.05i -Ey -i0,3,4 -R -J -O -K  -Vn >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh
      echo "gmt psxy ${F_PROFILES}${LINEID}_gps_data.txt -Gwhite -W0.5p,red -Sc0.05i -Ey -i0,1,2 -R -J -O -K  -Vn >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh
    done


    # Labels
    for i in ${!labelfilelist[@]}; do
      FNAME=$(echo -n "${LINEID}_"$i"projdist.txt")

      # Calculate distance from data points to the track, using only first two columns
      gawk < ${labelfilelist[$i]} '{print $1, $2}' | gmt mapproject -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} -L${F_PROFILES}${LINEID}_trackfile.txt -fg -Vn | gawk '{print $3, $4, $5}' > ${F_PROFILES}tmpA_${LINEID}.txt
      gawk < ${labelfilelist[$i]} '{print $1, $2}' | gmt mapproject -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} -L${F_PROFILES}line_buffer.txt+p -fg -Vn | gawk '{print $4}'> ${F_PROFILES}tmpbuf_${LINEID}.txt

      # Paste result onto input lines and select the points that are closest to current track out of all tracks
      paste ${F_PROFILES}tmpbuf_${LINEID}.txt ${labelfilelist[$i]} ${F_PROFILES}tmpA_${LINEID}.txt  > ${F_PROFILES}joinbuf.txt

      if [[ $PROFILE_USE_CLOSEST -eq 1 ]]; then
        info_msg "[profile.sh]: labels ARE using closest profile method ( -setvars { PROFILE_USE_CLOSEST 1 })"
        gawk < ${F_PROFILES}joinbuf.txt -v lineid=$PROFILE_INUM ' {
          if ($1==lineid) {
            for (i=2;i<=NF;++i) {
              printf "%s ", $(i)
            }
            printf("\n")
          }
        }' > ${F_PROFILES}$FNAME
      else
        info_msg "[profile.sh]: labels NOT using closest profile method (-setvars { PROFILE_USE_CLOSEST 0 })"
        gawk < ${F_PROFILES}joinbuf.txt -v lineid=$PROFILE_INUM ' {
           for (i=2;i<=NF;++i) {
             printf "%s ", $(i)
           }
           printf("\n")
       }' > ${F_PROFILES}$FNAME
      fi

      # cat ${F_PROFILES}joinbuf.txt | gawk -v lineid=$PROFILE_INUM '{
      #   if ($1==lineid) {
      #     for (i=2;i<=NF;++i) {
      #       printf "%s ", $(i)
      #     }
      #     printf("\n")
      #   }
      # }' > ${F_PROFILES}$FNAME

      # output is lon lat ... fields ... dist_to_track lon_at_track lat_at_track

      # Calculate distance from data points to any profile line, using only first two columns, then paste onto input file.

      pointsX=$(head -n 1 ${F_PROFILES}${LINEID}_trackfile.txt | gawk '{print $1}')
      pointsY=$(head -n 1 ${F_PROFILES}${LINEID}_trackfile.txt | gawk '{print $2}')
      pointeX=$(tail -n 1 ${F_PROFILES}${LINEID}_trackfile.txt | gawk '{print $1}')
      pointeY=$(tail -n 1 ${F_PROFILES}${LINEID}_trackfile.txt | gawk '{print $2}')

      # Exclude points that project onto the endpoints of the track, or are too far away. Distances are in meters in FNAME
      # echo "$pointsX $pointsY / $pointeX $pointeY"
      # rm -f ./cull.dat

      cat ${F_PROFILES}$FNAME | gawk -v x1=$pointsX -v y1=$pointsY -v x2=$pointeX -v y2=$pointeY -v w=${labelwidthlist[$i]} '{
        if (($(NF-1) == x1 && $(NF) == y1) || ($(NF-1) == x2 && $(NF) == y2) || $(NF-2) > (w+0)*1000) {
          # Nothing. My gawk skills are poor.
          printf "%s %s", $(NF-1), $(NF) >> "./cull.dat"
          for (i=3; i < (NF-2); i++) {
            printf " %s ", $(i) >> "./cull.dat"
          }
          printf("\n") >> "./cull.dat"
        } else {
          printf "%s %s", $(NF-1), $(NF)
          for (i=3; i < (NF-2); i++) {
            printf " %s ", $(i)
          }
          printf("\n")
        }
      }' > ${F_PROFILES}projpts_${FNAME}
      cleanup cull.dat

      # To ensure the profile path is perfect, we have to add the points on the profile back, and then remove them later
      NUMFIELDS=$(head -n 1 ${F_PROFILES}projpts_${FNAME} | gawk '{print NF}')

      gawk < ${F_PROFILES}${LINEID}_trackfile.txt -v fnum=$NUMFIELDS '{
        printf "%s %s REMOVEME", $1, $2
        for(i=3; i<fnum; i++) {
          printf " 0"
        }
        printf("\n")
      }' >> ${F_PROFILES}projpts_${FNAME}

      # This gets the points into a general along-track order by calculating their true distance from the starting point
      # Tracks that loop back toward the first point might fail (but who would do that anyway...)

      gawk < ${F_PROFILES}projpts_${FNAME} '{print $1, $2}' | gmt mapproject -G$pointsX/$pointsY+uk -Vn | gawk '{print $3}' > ${F_PROFILES}tmp_${FNAME}
      paste ${F_PROFILES}projpts_${FNAME} ${F_PROFILES}tmp_${FNAME} > ${F_PROFILES}tmp2_${FNAME}
      NUMFIELDS=$(head -n 1 ${F_PROFILES}tmp2_${FNAME} | gawk '{print NF}')
      sort -n -k $NUMFIELDS < ${F_PROFILES}tmp2_${FNAME} > ${F_PROFILES}presort_${FNAME}

      # Calculate true distances along the track line. "REMOVEME" is output as "NaN" by GMT.
      gawk < ${F_PROFILES}presort_${FNAME} '{print $1, $2}' | gmt mapproject -G+uk -Vn | gawk '{print $3}' > ${F_PROFILES}tmp3_${FNAME}

      # NF is the true distance along profile that needs to be the X coordinate, modified by XOFFSET_NUM
      # NF-1 is the distance from the zero point and should be discarded
      # $3 is the Z value that needs to be modified by zscale and ZOFFSET_NUM

      paste ${F_PROFILES}presort_${FNAME} ${F_PROFILES}tmp3_${FNAME} | gawk -v xoff=${XOFFSET_NUM} -v zoff=${ZOFFSET_NUM} -v zscale=${labelunitlist[$i]} '{
        if ($3 != "REMOVEME") {
          printf "%s %s %s", $(NF)+xoff, ($3)*zscale+zoff, (($3)*zscale+zoff)/(zscale)
          if (NF>=4) {
            for(i=4; i<NF-1; i++) {
              printf " %s", $(i)
            }
          }
          printf("\n")
        }
      }' > ${F_PROFILES}finaldist_${FNAME}

      # 297.8 108.72 108.72 4.1 2021-02-19T11:49:05 us6000diw5 1613706545 ${PROFILE_NUMBERS_FONT} TL

# echo "before:"
# head -n 1 ${F_PROFILES}finaldist_${FNAME}
# 7.41567 80 80 4.1 1998-03-01T05:57:56 1079449 888703076 0.138888888889 Helvetica,black TL

      [[ $EQ_LABELFORMAT == "idmag"    ]] && gawk  < ${F_PROFILES}finaldist_${FNAME} '{ printf "%s\t%s\t%s\t%s\t%s\t%s(%0.1f)\n", $1, 0-$2, $8, 0, $9, $6, $4  }' >> ${F_PROFILES}labels_preadjust_${FNAME}
      [[ $EQ_LABELFORMAT == "datemag"  ]] && gawk  < ${F_PROFILES}finaldist_${FNAME} '{ split($5,tmp,"T"); printf "%s\t%s\t%s\t%s\t%s\t%s(%0.1f)\n", $1, 0-$2, $8, 0, $9, tmp[1], $4 }' >> ${F_PROFILES}labels_preadjust_${FNAME}
      [[ $EQ_LABELFORMAT == "dateid"   ]] && gawk  < ${F_PROFILES}finaldist_${FNAME} '{ split($5,tmp,"T"); printf "%s\t%s\t%s\t%s\t%s\t%s(%s)\n", $1, 0-$2, $8, 0, $9, tmp[1], $6 }' >> ${F_PROFILES}labels_preadjust_${FNAME}
      [[ $EQ_LABELFORMAT == "id"       ]] && gawk  < ${F_PROFILES}finaldist_${FNAME} '{ printf "%s\t%s\t%s\t%s\t%s\t%s\n", $1, 0-$2, $8, 0, $9, $6  }' >> ${F_PROFILES}labels_preadjust_${FNAME}
      [[ $EQ_LABELFORMAT == "date"     ]] && gawk  < ${F_PROFILES}finaldist_${FNAME} '{ split($5,tmp,"T"); printf "%s\t%s\t%s\t%s\t%s\t%s\n", $1, 0-$2, $8, 0, $9, tmp[1] }' >> ${F_PROFILES}labels_preadjust_${FNAME}
      [[ $EQ_LABELFORMAT == "year"     ]] && gawk  < ${F_PROFILES}finaldist_${FNAME} '{ split($5,tmp,"T"); split(tmp[1],tmp2,"-"); printf "%s\t%s\t%s\t%s\t%s\t%s\n", $1, 0-$2, $8, 0, $9, tmp2[1] }' >> ${F_PROFILES}labels_preadjust_${FNAME}
      [[ $EQ_LABELFORMAT == "yearmag"  ]] && gawk  < ${F_PROFILES}finaldist_${FNAME} '{ split($5,tmp,"T"); split(tmp[1],tmp2,"-"); printf "%s\t%s\t%s\t%s\t%s\t%s(%s)\n", $1, 0-$2, $8, 0, $9, tmp2[1], $4 }' >> ${F_PROFILES}labels_preadjust_${FNAME}
      [[ $EQ_LABELFORMAT == "mag"      ]] && gawk  < ${F_PROFILES}finaldist_${FNAME} '{ printf "%s\t%s\t%s\t%s\t%s\t%0.1f\n", $1, 0-$2, $8, 0, $9, $4  }' >> ${F_PROFILES}labels_preadjust_${FNAME}

      # Recalculate the justification of each label based on its position on the profile?

      # CENTERX=$()

cat <<-EOF > tmpscript.txt
PROFILE_ZCENTER=\$(echo "(\${line_max_z} + \${line_min_z})/2" | bc -l)
PROFILE_XCENTER=\$(echo "(\${line_max_x} + \${line_min_x})/2" | bc -l)
gawk < ${F_PROFILES}labels_preadjust_${FNAME} -v cx=\$PROFILE_XCENTER -v cz=\$PROFILE_ZCENTER '{
if (\$1 > cx) {
hpos="R"
} else {
hpos="L"
}
if (\$2 < cz) {
vpos="B"
} else {
vpos="T"
}
\$5=sprintf("%s%s", hpos, vpos)
print
}' > ${F_PROFILES}labels_${FNAME}
EOF

      # PLOT ON THE COMBINED PROFILE PS
      cat tmpscript.txt >> plot.sh

      echo "uniq -u ${F_PROFILES}labels_${FNAME} | gmt pstext -Dj${EQ_LABEL_DISTX}/${EQ_LABEL_DISTY}+v0.7p,black -Gwhite  -F+f+a+j -W0.5p,black -R -J -O -K -Vn >> "${PSFILE}"" >> plot.sh

      # PLOT ON THE FLAT SECTION PS
      cat tmpscript.txt >> ${LINEID}_temp_plot.sh

      echo "uniq -u ${F_PROFILES}labels_${FNAME} | gmt pstext -Dj${EQ_LABEL_DISTX}/${EQ_LABEL_DISTY}+v0.7p,black -Gwhite  -F+f+a+j -W0.5p,black -R -J -O -K -Vn>> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh

      # PLOT ON THE OBLIQUE SECTION PS
      cat tmpscript.txt >> ${LINEID}_plot.sh
      [[ $PLOT_SECTIONS_PROFILEFLAG -eq 1 ]] &&  echo "uniq -u ${F_PROFILES}labels_${FNAME} | gmt pstext -Dj${EQ_LABEL_DISTX}/${EQ_LABEL_DISTY}+v0.7p,black -p -Gwhite  -F+f+a+j -W0.5p,black -R -J -O -K -Vn >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_plot.sh

      rm -f presort_${FNAME}
      rm -f tmpscript.txt
    done

    ##### END data plotting section


    # Set up IDfile.txt which is used when plotting an automatic title
    echo -n "@;${COLOR};${LINEID}@;; " >> ${F_PROFILES}IDfile.txt
    if [[ $xoffsetflag -eq 1 && $ZOFFSETflag -eq 1 ]]; then
      printf "@:8: (%+.02g km/%+.02g) @::" ${XOFFSET_NUM} ${ZOFFSET_NUM} >> ${F_PROFILES}IDfile.txt
      echo -n " " >> ${F_PROFILES}IDfile.txt
    elif [[ $xoffsetflag -eq 1 && $ZOFFSETflag -eq 0 ]]; then
      printf "@:8: (%+.02g km (X)) @::" ${XOFFSET_NUM} >> ${F_PROFILES}IDfile.txt
      echo -n " " >> ${F_PROFILES}IDfile.txt
    elif [[ $xoffsetflag -eq 0 && $ZOFFSETflag -eq 1 ]]; then
      printf "@:8: (%+.02g km (Z)) @::" ${ZOFFSET_NUM} >> ${F_PROFILES}IDfile.txt
      echo -n " " >> ${F_PROFILES}IDfile.txt
    fi

    # Plot the locations of profile points above the profile, adjusting for XOFFSET
    # and summing the incremental distance if necessary.

    # ON THE STACKED PROFILES
    PROFHEIGHT_OFFSET=$(echo "${PROFILE_HEIGHT_IN_TMP}" | gawk '{print ($1+0)/2 + 4/72}')

    echo "gawk < ${F_PROFILES}xpts_${LINEID}_dist_km.txt -v z=\$halfz '(NR==1) { print \$1 + ${XOFFSET_NUM}, z}' | gmt psxy -J -R -K -O -N -Si0.1i -Ya\${Ho2} -W0.5p,${COLOR} -G${COLOR} >> ${PSFILE}" >> plot.sh
    echo "gawk < ${F_PROFILES}xpts_${LINEID}_dist_km.txt -v z=\$halfz 'BEGIN {runtotal=0} (NR>1) { print \$1+runtotal+${XOFFSET_NUM}, z; runtotal=\$1+runtotal; }' | gmt psxy -J -R -K -O -N -Si0.1i -Ya\${Ho2} -W0.5p,${COLOR} >> ${PSFILE}" >> plot.sh

    # ON THE FLAT PROFILES
    if [[ $PROFTOPOHEIGHT == "" ]]; then
      echo "Ho2=\$(echo \$PROFILE_HEIGHT_IN | gawk '{print (\$1+0)/2 + 4/72 \"i\"}')" >> ${LINEID}_temp_plot.sh
    else
      echo "Ho2=\$(echo \$PROFILE_HEIGHT_IN ${PROFTOPOHEIGHT} | gawk '{print (\$1+0)/2 + \$2 + 4/72 \"i\"}')" >> ${LINEID}_temp_plot.sh
    fi

    echo "halfz=\$(echo \"(\$line_max_z + \$line_min_z)/2\" | bc -l)" >> ${LINEID}_temp_plot.sh

    echo "gawk < ${F_PROFILES}xpts_${LINEID}_dist_km.txt -v z=\$halfz '(NR==1) { print \$1 + ${XOFFSET_NUM}, z}' | gmt psxy -J -R -K -O -N -Si0.1i -Ya\${Ho2} -W0.5p,${COLOR} -G${COLOR} >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh
    plotlineidflag=1
    if [[ $plotlineidflag -eq 1 ]]; then
      echo "gawk < ${F_PROFILES}xpts_${LINEID}_dist_km.txt -v z=\$halfz '(NR==1) { print \$1 + ${XOFFSET_NUM}, z, \"${LINEID}\"}' | gmt pstext -F+f10p,Helvetica,black+a0+jBL -D8p/0 -N -Ya\${Ho2} -J -R -O -K >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh
    fi
    echo "gawk < ${F_PROFILES}xpts_${LINEID}_dist_km.txt -v z=\$halfz 'BEGIN {runtotal=0} (NR>1) { print \$1+runtotal+${XOFFSET_NUM}, z; runtotal=\$1+runtotal; }' | gmt psxy -J -R -K -O -N -Si0.1i -Ya\${Ho2} -W0.5p,${COLOR}>> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh

    # ON THE OBLIQUE PLOTS
    echo "Ho2=\$(echo \$PROFILE_HEIGHT_IN | gawk '{print (\$1+0)/2 + 4/72 \"i\"}')" >> ${LINEID}_plot.sh
    echo "halfz=\$(echo \"(\$line_max_z + \$line_min_z)/2\" | bc -l)" >> ${LINEID}_plot.sh

    [[ $PLOT_SECTIONS_PROFILEFLAG -eq 1 ]] &&  echo "gawk < ${F_PROFILES}xpts_${LINEID}_dist_km.txt -v z=\$halfz '(NR==1) { print \$1 + ${XOFFSET_NUM}, z}' | gmt psxy -p -J -R -K -O  -N -Si0.1i -Ya\${Ho2} -W0.5p,${COLOR} -G${COLOR} >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_plot.sh
    [[ $PLOT_SECTIONS_PROFILEFLAG -eq 1 ]] &&  echo "gawk < ${F_PROFILES}xpts_${LINEID}_dist_km.txt -v z=\$halfz 'BEGIN {runtotal=0} (NR>1) { print \$1+runtotal+${XOFFSET_NUM}, z; runtotal=\$1+runtotal; }' | gmt psxy -p -J -R -K -O -N -Si0.1i -Ya\${Ho2} -W0.5p,${COLOR} >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_plot.sh

    if [[ $PLOT_SECTIONS_PROFILEFLAG -eq 1 ]]; then

      PROFILE_HEIGHT_IN_TMP=${PROFILE_HEIGHT_IN}

      if [[ $setprofautodepthflag -eq 1 ]]; then
        echo "$PROFILE_XMIN $SPROF_MINELEV_AUTO" > tmp.txt
        echo "$PROFILE_XMAX $SPROF_MINELEV_AUTO" >> tmp.txt
        echo "$PROFILE_XMIN $SPROF_MAXELEV_AUTO" >> tmp.txt
        echo "$PROFILE_XMAX $SPROF_MAXELEV_AUTO" >> tmp.txt
        update_profile_bounds 1 2 < tmp.txt
        rm -f tmp.txt
      fi

      report_profile_bounds > ${F_PROFILES}${LINEID}_limits.txt

      if [[ $xminflag -eq 1 ]]; then
        line_min_x=$(gawk < ${F_PROFILES}${LINEID}_limits.txt '{print $1}')
      else
        line_min_x=$min_x
      fi
      if [[ $xmaxflag -eq 1 ]]; then
        line_max_x=$(gawk < ${F_PROFILES}${LINEID}_limits.txt '{print $2}')
      else
        line_max_x=$max_x
      fi
      if [[ $zminflag -eq 1 ]]; then
        line_min_z=$(gawk < ${F_PROFILES}${LINEID}_limits.txt '{print $3}')
      else
        line_min_z=$min_z
      fi
      if [[ $zmaxflag -eq 1 ]]; then
        line_max_z=$(gawk < ${F_PROFILES}${LINEID}_limits.txt '{print $4}')
      else
        line_max_z=$max_z
      fi

      # Set minz to ensure that H=W
      if [[ $profileonetooneflag -eq 1 ]]; then
        if [[ ${OTO_METHOD} =~ "change_z" ]]; then
          info_msg "(-mob) Setting vertical aspect ratio to H=W for profile ${LINEID} by changing Z range"
          line_diffx=$(echo "$line_max_x - $line_min_x" | bc -l)
          line_hwratio=$(gawk -v vertex=${PROFILE_VERT_EX} -v h=${PROFILE_HEIGHT_IN} -v w=${PROFILE_WIDTH_IN} 'BEGIN { print 1/vertex*(h+0)/(w+0) }')
          line_diffz=$(echo "$line_hwratio * $line_diffx" | bc -l)
          line_min_z=$(echo "$line_max_z - $line_diffz" | bc -l)
          info_msg "Profile ${LINEID} new min_z is $line_min_z"
        else
          info_msg "(-mob) Setting vertical aspect ratio to H=W for profile ${LINEID} by changing profile height (currently PROFILE_HEIGHT_IN=${PROFILE_HEIGHT_IN})"

          # calculate X range
          line_diffx=$(echo "$line_max_x - $line_min_x" | bc -l)
          # calculate Z range
          line_diffz=$(echo "$line_max_z - $line_min_z" | bc -l)

          # calculate new PROFILE_HEIGHT_IN
          PROFILE_HEIGHT_IN_TMP=$(gawk -v vertex=${PROFILE_VERT_EX} -v dx=${line_diffx} -v dz=${line_diffz} -v w=${PROFILE_WIDTH_IN} 'BEGIN { print vertex*(w+0)*(dz+0)/(dx+0) }')"i"
          info_msg "New profile height for ${LINEID} is $PROFILE_HEIGHT_IN_TMP"
        fi

        # Buffer with equal width based on Z range
        if [[ $BUFFER_PROFILES -eq 1 ]]; then
          zrange_buf=$(echo "($line_max_z - $line_min_z) * ($BUFFER_WIDTH_FACTOR)" | bc -l)
          line_max_x=$(echo "$line_max_x + $zrange_buf" | bc -l)
          line_min_x=$(echo "$line_min_x - $zrange_buf" | bc -l)
          line_max_z=$(echo "$line_max_z + $zrange_buf" | bc -l)
          line_min_z=$(echo "$line_min_z - $zrange_buf" | bc -l)
        fi
        info_msg "After buffering, range is $line_min_x $line_max_x $line_min_z $line_max_z"
      else
        # Buffer X and Z ranges separately
        if [[ $BUFFER_PROFILES -eq 1 ]]; then
          xrange_buf=$(echo "($line_max_x - $line_min_x) * ($BUFFER_WIDTH_FACTOR)" | bc -l)
          line_max_x=$(echo "$line_max_x + $xrange_buf" | bc -l)
          line_min_x=$(echo "$line_min_x - $xrange_buf" | bc -l)
          zrange_buf=$(echo "($line_max_z - $line_min_z) * ($BUFFER_WIDTH_FACTOR)" | bc -l)
          line_max_z=$(echo "$line_max_z + $zrange_buf" | bc -l)
          line_min_z=$(echo "$line_min_z - $zrange_buf" | bc -l)
        fi
      fi

cat <<-EOF > ${LINEID}_perspective.sh
#!/bin/bash

# perspective profile plotting script generated by tectoplot
# $(date -u)

PERSPECTIVE_AZ=\${1}
PERSPECTIVE_INC=\${2}
line_min_x=${PROFILE_XMIN}
line_max_x=${PROFILE_XMAX}
line_min_z=${line_min_z}
line_max_z=${line_max_z}
PROFILE_HEIGHT_IN=${PROFILE_HEIGHT_IN_TMP}
PROFILE_WIDTH_IN=${PROFILE_WIDTH_IN}
GUESS=\$(echo \"\$PROFILE_HEIGHT_IN \$PROFILE_WIDTH_IN\" | gawk '{ print 2.5414*(\$1+0) -0.5414*(\$2+0) - 0.0000  }')
if [[ \$(echo \"\${PERSPECTIVE_AZ} \> 180\" | bc -l) -eq 1 ]]; then
  xshift=\$(gawk -v height=\${GUESS} -v az=\$PERSPECTIVE_AZ 'BEGIN{print cos((270-az)*3.1415926/180)*(height+0)}')
else
  xshift=0
fi

gmt gmtset PS_MEDIA 100ix100i
EOF
echo "gmt psbasemap -py\${PERSPECTIVE_AZ}/\${PERSPECTIVE_INC} -Vn -JX\${PROFILE_WIDTH_IN}/\${PROFILE_HEIGHT_IN} -Bxaf+l\"${x_axis_label}\" -Byaf+l\"${z_axis_label}\" -BSEW -R\$line_min_x/\$line_max_x/\$line_min_z/\$line_max_z -Xc -Yc --MAP_FRAME_PEN=thinner,black --FONT_TITLE=\"${PROFILE_TITLE_FONT}\" --FONT_ANNOT_PRIMARY=\"${PROFILE_NUMBERS_FONT}\" --FONT_LABEL=\"${PROFILE_AXIS_FONT}\" -K > ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_perspective.sh

      # Concatenate the cross section plotting commands onto the script
      cat ${LINEID}_plot.sh >> ${LINEID}_perspective.sh
      cleanup ${LINEID}_plot.sh

      # Concatenate the terrain plotting commands onto the script.
      # If there is no top tile, we need to create some commands to allow a plot to be made correctly.

      if [[ -e ${LINEID}_topscript.sh ]]; then
        echo "# Top tile plotting script..." >> ${LINEID}_perspective.sh
        cat ${LINEID}_topscript.sh >> ${LINEID}_perspective.sh
        cleanup ${LINEID}_topscript.sh
      else
        echo "# Top tile plotting script... alternative mode" >> ${LINEID}_perspective.sh
        echo "VEXAG=\${3}" > ${LINEID}_topscript.sh
        echo "dem_miny=-${MAXWIDTH_KM}" >> ${LINEID}_topscript.sh
        echo "dem_maxy=${MAXWIDTH_KM}" >> ${LINEID}_topscript.sh
        echo "dem_minz=10" >> ${LINEID}_topscript.sh
        echo "dem_maxz=-10" >> ${LINEID}_topscript.sh
        echo "PROFILE_DEPTH_RATIO=1" >> ${LINEID}_topscript.sh
        echo "PROFILE_DEPTH_IN=\$(echo \$PROFILE_DEPTH_RATIO \$PROFILE_HEIGHT_IN | gawk '{print (\$1*(\$2+0))}' )i"  >> ${LINEID}_topscript.sh

        echo "GUESS=\$(echo \"\$PROFILE_HEIGHT_IN \$PROFILE_DEPTH_IN\" | gawk '{ print (\$1+0)-(\$2+0) }')" >> ${LINEID}_topscript.sh
        echo "if [[ \$(echo \"\${PERSPECTIVE_AZ} > 180\" | bc -l) -eq 1 ]]; then" >> ${LINEID}_topscript.sh
        echo "  xshift=\$(gawk -v height=\${GUESS} -v az=\$PERSPECTIVE_AZ 'BEGIN{print cos((270-az)*3.1415926/180)*(height+0)}')"  >> ${LINEID}_topscript.sh
        echo "else" >> ${LINEID}_topscript.sh
        echo "  xshift=0" >> ${LINEID}_topscript.sh
        echo "fi" >> ${LINEID}_topscript.sh

        echo "yshift=\$(gawk -v height=\${PROFILE_HEIGHT_IN} -v inc=\$PERSPECTIVE_INC 'BEGIN{print cos(inc*3.1415926/180)*(height+0)}')" >> ${LINEID}_topscript.sh
        echo "gmt psbasemap -p\${PERSPECTIVE_AZ}/\${PERSPECTIVE_INC}/\${line_max_z} -R\${line_min_x}/\${dem_miny}/\${line_max_x}/\${dem_maxy}/\${line_min_z}/\${line_max_z}r -JZ\${PROFILE_HEIGHT_IN} -JX\${PROFILE_WIDTH_IN}/\${PROFILE_DEPTH_IN} -Byaf+l\"${y_axis_label}\" -X\${xshift}i --MAP_FRAME_PEN=thinner,black -K -O >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_topscript.sh

        # Draw the box at the end of the profile. For other view angles, should draw the other box?

#        echo "gmt psbasemap -p\${PERSPECTIVE_AZ}/\${PERSPECTIVE_INC}/\${dem_minz} -R\${line_min_x}/\${dem_miny}/\${line_max_x}/\${dem_maxy}/\${dem_minz}/\${dem_maxz}r -JZ\${ZSIZE}i -J -Bzaf -Bxaf --MAP_FRAME_PEN=thinner,black -K -O -Y\${yshift}i >> ${LINEID}_perspective_profile.ps" >> ${LINEID}_topscript.sh

      if [[ $litho1profileflag -eq 1 ]]; then

# Change limits based on profile limits, in the script itself.

cat<<-EOF >> ${LINEID}_topscript.sh
gawk < ${F_PROFILES}${LINEID}_litho1_cross_poly.dat -v xval=\$line_max_x -v zval=\$line_min_z '{
if (\$1 == ">") {
print
} else {
  if (\$2 < zval) {
    print xval, \$1, zval
  } else {
    print xval, \$1, \$2
  }
}
}' > ${F_PROFILES}${LINEID}_litho1_cross_poly_xyz.dat
EOF
        echo "gmt psxyz -p ${F_PROFILES}${LINEID}_litho1_cross_poly_xyz.dat -L -G+z -C$LITHO1_CPT -t${LITHO1_TRANS} -Vn -R -J -JZ -O -K >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_topscript.sh
      fi
        cat ${LINEID}_topscript.sh >> ${LINEID}_perspective.sh
        cleanup ${LINEID}_topscript.sh
      fi

      echo "if [[ \$(echo \"\${PERSPECTIVE_AZ} > 180\" | bc -l) -eq 1 ]]; then" >> ${LINEID}_topscript.sh
      echo "  echo \"\$line_min_x \$dem_maxy \$line_max_z\" > ${F_PROFILES}${LINEID}_endbox.xyz" >> ${LINEID}_topscript.sh
      echo "  echo \"\$line_min_x \$dem_maxy \$line_min_z\" >> ${F_PROFILES}${LINEID}_endbox.xyz" >> ${LINEID}_topscript.sh
      echo "  echo \"\$line_min_x \$dem_miny \$line_min_z\" >> ${F_PROFILES}${LINEID}_endbox.xyz" >> ${LINEID}_topscript.sh
      echo "  echo \"\$line_min_x \$dem_miny \$line_max_z\" >> ${F_PROFILES}${LINEID}_endbox.xyz" >> ${LINEID}_topscript.sh
      echo "else" >> ${LINEID}_topscript.sh
      echo "  echo \"\$line_max_x \$dem_maxy \$line_max_z\" > ${F_PROFILES}${LINEID}_endbox.xyz" >> ${LINEID}_topscript.sh
      echo "  echo \"\$line_max_x \$dem_maxy \$line_min_z\" >> ${F_PROFILES}${LINEID}_endbox.xyz" >> ${LINEID}_topscript.sh
      echo "  echo \"\$line_max_x \$dem_miny \$line_min_z\" >> ${F_PROFILES}${LINEID}_endbox.xyz" >> ${LINEID}_topscript.sh
      echo "  echo \"\$line_max_x \$dem_miny \$line_max_z\" >> ${F_PROFILES}${LINEID}_endbox.xyz" >> ${LINEID}_topscript.sh
      echo "fi" >> ${LINEID}_topscript.sh

      # NO -K
      echo "gmt psxyz ${F_PROFILES}${LINEID}_endbox.xyz -p -R -J -JZ -Wthinner,black -O >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_topscript.sh

      echo "gmt psconvert ${F_PROFILES}${LINEID}_perspective_profile.ps -A+m1i -Tf -F${F_PROFILES}${LINEID}_perspective_profile >/dev/null 2>&1 " >> ${LINEID}_perspective.sh

      # Execute plot script
      chmod a+x ${LINEID}_perspective.sh
      echo ". ./${LINEID}_perspective.sh \${PERSPECTIVE_AZ} \${PERSPECTIVE_INC} \${PERSPECTIVE_EXAG}" >> ./plot_perspective_profiles.sh

    fi # Finalize individual profile plots

    ### Complete bookkeeping for this profile.

    echo "$PROFILE_XMIN" > tmp.txt
    echo "$PROFILE_XMAX" >> tmp.txt
    update_profile_bounds 1 100 < tmp.txt
    rm -f tmp.txt

    # Create the flat profile plot

    # Profiles will be plotted by a master script that feeds in the appropriate parameters based on all profiles.
    echo "# profile plotting script generated by tectoplot on $(date -u)" >> ${LINEID}_profile.sh
    echo "line_min_x=${PROFILE_XMIN}" >> ${LINEID}_profile.sh
    echo "line_max_x=${PROFILE_XMAX}" >> ${LINEID}_profile.sh
    echo "line_min_z=\$1" >> ${LINEID}_profile.sh
    echo "line_max_z=\$2" >> ${LINEID}_profile.sh
    echo "PROFILE_HEIGHT_IN=${PROFILE_HEIGHT_IN_TMP}" >> ${LINEID}_profile.sh
    echo "PROFILE_WIDTH_IN=${PROFILE_WIDTH_IN}" >>${LINEID}_profile.sh

    echo "PROFILE_TOPPER_HEIGHT_IN=0"  >>${LINEID}_profile.sh
    echo "if [[ \$3 != \"\" ]]; then PROFILE_TOPPER_HEIGHT_IN=\$3; fi" >>${LINEID}_profile.sh

    # Center the frame on the new PS document
    echo "gmt psbasemap -Vn -JX\${PROFILE_WIDTH_IN}/\${PROFILE_HEIGHT_IN} -Bltrb -R\${line_min_x}/\${line_max_x}/\${line_min_z}/\${line_max_z} --MAP_FRAME_PEN=thinner,black -K -Xc -Yc > ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_profile.sh
    cat ${LINEID}_temp_plot.sh >> ${LINEID}_profile.sh
    cleanup ${LINEID}_temp_plot.sh

    echo "gmt psbasemap -Vn -B${axeslabelcmd} -Baf -Bx+l\"${x_axis_label}\" -By+l\"${z_axis_label}\" --FONT_TITLE=\"${PROFILE_TITLE_FONT}\" --FONT_ANNOT_PRIMARY=\"${PROFILE_NUMBERS_FONT}\" --FONT_LABEL=\"${PROFILE_AXIS_FONT}\" --MAP_FRAME_PEN=thinner,black -R -J -O -K >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_profile.sh

    if [[ ! -z ${right_z_axis_label} ]]; then
      echo "gmt psbasemap -Vn -BE -By+l\"${right_z_axis_label}\" --MAP_FRAME_TYPE="inside" --FONT_TITLE=\"${PROFILE_TITLE_FONT}\" --FONT_ANNOT_PRIMARY=\"${PROFILE_NUMBERS_FONT}\" --FONT_LABEL=\"${PROFILE_AXIS_FONT}\" --MAP_FRAME_PEN=thinner,black -R -J -O -K >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_profile.sh
    fi

    echo "grep \") sh mx\" ${F_PROFILES}${LINEID}_flat_profile.ps | gawk '{val[NR]=substr(\$1,2,length(\$1)-2)} END {print val[2]-val[1]}' > ${F_PROFILES}${LINEID}_interval.txt" >> ${LINEID}_profile.sh

    # Bring in the code to plot the top swath profile panel, if necessary
    [[ -s ${LINEID}_temp_profiletop.sh ]] && cat ${LINEID}_temp_profiletop.sh >> ${LINEID}_profile.sh && cleanup ${LINEID}_temp_profiletop.sh

    # Finalize the profile and convert to PDF
    echo "gmt psxy -T -R -J -O >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_profile.sh
    echo "gmt psconvert -Tf -A+m0.5i ${F_PROFILES}${LINEID}_flat_profile.ps >/dev/null 2>&1" >> ${LINEID}_profile.sh

    echo ". ./${LINEID}_profile.sh ${line_min_z} ${line_max_z} \${3}" >> ./plot_flat_profiles.sh
    chmod a+x ./${LINEID}_profile.sh

    # Increment the profile number
    PROFILE_INUM=$(echo "$PROFILE_INUM + 1" | bc)
  ;; # P)
  A) # A style tracks have not been tested in a LOOOOOONG time
    info_msg "Processing A style track ${LINEID}"

    sed 1d < ${F_PROFILES}${LINEID}_trackfile.txt > ${F_PROFILES}shift1_${LINEID}_trackfile.txt
  	paste ${F_PROFILES}${LINEID}_trackfile.txt ${F_PROFILES}shift1_${LINEID}_trackfile.txt | grep -v "\s>" > ${F_PROFILES}geodin_${LINEID}_trackfile.txt

    cleanup ${F_PROFILES}shift1_${LINEID}_trackfile.txt
    cleanup ${F_PROFILES}geodin_${LINEID}_trackfile.txt

    # Script to return azimuth and midpoint between a pair of input points.
    # Comes within 0.2 degrees of geod() results over large distances, while being symmetrical which geod isn't
    # We need perfect midpoint symmetry in order to create exact point pairs in adjacent polygons

    # Note: this calculates the NORMAL DIRECTION to the profile and not its AZIMUTH

    gawk < ${F_PROFILES}geodin_${LINEID}_trackfile.txt -v width="${MAXWIDTH_KM}" -v color="${COLOR}" -v lineval="${LINETOTAL}" -v folderid=${F_PROFILES} -v lineid=${LINEID} '
        function acos(x) { return atan2(sqrt(1-x*x), x) }
        {
            lon1 = $1*3.14159265358979/180
            lat1 = $2*3.14159265358979/180
            lon2 = $3*3.14159265358979/180
            lat2 = $4*3.14159265358979/180
            Bx = cos(lat2)*cos(lon2-lon1);
            By = cos(lat2)*sin(lon2-lon1);
            latMid = atan2(sin(lat1)+sin(lat2), sqrt((cos(lat1)+Bx)*(cos(lat1)+Bx)+By*By));
            lonMid = lon1+atan2(By, cos(lat1)+Bx);
            theta = atan2(sin(lon2-lon1)*cos(lat2), cos(lat1)*sin(lat2)-sin(lat1)*cos(lat2)*cos(lon2-lon1));
            printf "%.5f %.5f %.3f\n", lonMid*180/3.14159265358979, latMid*180/3.14159265358979, (theta*180/3.14159265358979+360-90)%360;
            # Print the back-projection to end_points.txt
            theta = atan2(sin(lon1-lon2)*cos(lat1), cos(lat2)*sin(lat1)-sin(lat2)*cos(lat1)*cos(lon1-lon2))
            print $3, $4, (theta*180/3.14159265358979+180-90)%360, width, color, lineid >> "my_end_points.txt"
        }' > ${F_PROFILES}az_${LINEID}_trackfile.txt

        if [[ -s my_end_points.txt ]]; then
          tail -n 2 my_end_points.txt | head -n 1 > ${F_PROFILES}${LINEID}_end.txt
          tail -n 2 my_end_points.txt | head -n 1 >> end_points.txt
          rm -f my_end_points.txt
        fi

    paste ${F_PROFILES}${LINEID}_trackfile.txt ${F_PROFILES}az_${LINEID}_trackfile.txt > ${F_PROFILES}jointrack_${LINEID}.txt

    # The azimuth of the profile is the azimuth of its first segment.

    THISP_AZ=$(head -n 1 ${F_PROFILES}az_${LINEID}_trackfile.txt | gawk '{print $3}')

    LINETOTAL=$(wc -l < ${F_PROFILES}jointrack_${LINEID}.txt)
    cat ${F_PROFILES}jointrack_${LINEID}.txt | gawk -v width="${MAXWIDTH_KM}" -v color="${COLOR}" -v lineval="${LINETOTAL}" -v folderid=${F_PROFILES} -v lineid=${LINEID} '
      (NR==1) {
        print $1, $2, $5, width, color, lineid >> "start_points.txt"
        lastval=$5
      }
      (NR>1 && NR<lineval) {
        diff = ( ( $5 - lastval + 180 + 360 ) % 360 ) - 180
        angle = (360 + lastval + ( diff / 2 ) ) % 360
        print $1, $2, angle, width, color, lineid >> "mid_points.txt"
        lastval=$5
      }
      # END {
      #   filename=sprintf("%s%s_end.txt", folderid, lineid)
      #   print $1, $2, $5, width, color, folderid >> filename
      #   print $1, $2, $5, width, color, lineid >> "end_points.txt"
      # }
      '

    # Swath grids (swath, box-and-whisker)
    for i in ${!gridfilelist[@]}; do
      gridfileflag=1

      # For A type we do not process top grids
      if [[ ! ${istopgrid[$i]} -eq 1 ]]; then
        if [[ ${gridtypelist[$i]} == "S" || ${gridtypelist[$i]} == "W" ]]; then
          # Sample the input grid along space cross-profile

          gmt grdtrack -N -Vn -G${gridfilelist[$i]} ${F_PROFILES}${LINEID}_trackfile.txt -C${gridwidthlist[$i]}/${gridsamplewidthlist[$i]}/${gridspacinglist[$i]}${PERSPECTIVE_TOPO_HALF} -Af > ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiletable.txt

          # 155.803640934	-7.80036540577	-49.7851845097	180.459136873	-4559.69582333

          # Calculate the incremental length along profile between points
          gmt mapproject ${F_PROFILES}${LINEID}_trackfile.txt -G+uk+i | gawk '{print $3}' > ${F_PROFILES}${LINEID}_dist_km.txt

          gawk < ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiletable.txt -v zscale=${gridzscalelist[$i]} '
          BEGIN {
              level=-1
          }
          {
            if (substr($0,1,1)==">") {
              i=0
              level++
            } else {
              x[level][i]=$1
              y[level][i]=$2
              dist[level][i]=$3
              az[level][i]=$4
              val[level][i]=$5
              i++
            }
          }
          # Calculate the quantiles of each val bin
          END {
            # Output the val data in a format useful for quantile calculation
            for (k=0; k<i; k++) {
              for (j=0;j<=level;j++) {
                printf("%s ", val[j][k] * zscale)
              }
              printf("\n")
            }
            # Output the distance data where 0 is start of profile
            for(k=0;k<i;k++) {
              print dist[0][k] > "profilekm.txt"
            }
          }' > ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledata.txt

          mv profilekm.txt ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilekm.txt

          # Determine the length of the profile
          PROFILE_XMIN=$(head -n 1 ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilekm.txt)
          PROFILE_XMAX=$(tail -n 1 ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilekm.txt)
          PROFILE_LEN_KM=$(echo ${PROFILE_XMIN} ${PROFILE_XMAX} | gawk '{print $2 + $1}')

          # This function calculates the 0, 25, 50, 75, and 100 quartiles of the data. First strip out the NaN values which are in the data.
          cat ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledata.txt | sed 's/NaN//g' |  gawk '
          {
            q1=-1;
            q2=-1;
            q3=-1
            split( $0 , a, " " );

            asort( a );
            n=length(a);

            p[1] = 0;
            for (i = 2; i<=n; i++) {
              p[i] = (i-1)/(n-1);
              if (p[i] >= .25 && q1 == -1) {
                f = (p[i]-.25)/(p[i]-p[i-1]);
                q1 = a[i-1]*(f)+a[i]*(1-f);
              }
              if (p[i] >= .5 && q2 == -1) {
                f = (p[i]-.5)/(p[i]-p[i-1]);
                q2 = a[i-1]*(f)+a[i]*(1-f);
              }
              if (p[i] >= .75 && q3 == -1) {
                f = (p[i]-.75)/(p[i]-p[i-1]);
                q3 = a[i-1]*(f)+a[i]*(1-f);
              }
            }
            printf("%g %g %g %g %g\n", a[1], q1, q2, q3, a[n])
          }' > ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilesummary.txt

          # cat ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilesummary_pre.txt
  #
  #         # Find the value of Z at X=0 and subtract it from the entire dataset
  #         if [[ $ZOFFSETflag -eq 1 && $dozflag -eq 1 ]]; then
  #           # echo ZOFFSETflag is set
  #           XZEROINDEX=$(gawk < ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilekm.txt '{if ($1 > 0) { exit } } END {print NR}')
  #           # echo "XZEROINDEX is" ${XZEROINDEX}
  #           ZOFFSET_NUM=$(head -n $XZEROINDEX ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilesummary_pre.txt | tail -n 1 | gawk '{print 0-$3}')
  #         fi
  #         # echo "Z offset is" ${ZOFFSET_NUM}
  #         cat ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilesummary_pre.txt | gawk -v zoff="${ZOFFSET_NUM}" '{print $1+zoff, $2+zoff, $3+zoff, $4+zoff, $5+zoff}' > ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilesummary.txt
  #
  #         # profilesummary.txt is min q1 q2 q3 max
  #         #           1  2   3  4  5   6
  #         # gmt wants X q2 min q1 q3 max
  #
          paste ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilekm.txt ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilesummary.txt | tr '\t' ' ' | gawk '{print $1, $4, $2, $3, $5, $6}' > ${F_PROFILES}${LINEID}_${grididnum[$i]}_quantile_data.txt
  #
  #         # quantile_data.txt has 6 elements: X min q1 q2 q3 max
  #
  # cleanup ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilesummary.txt
          gawk '{print $1, $2}' < ${F_PROFILES}${LINEID}_${grididnum[$i]}_quantile_data.txt > ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledatamedian.txt
          gawk '{print $1, $3}' < ${F_PROFILES}${LINEID}_${grididnum[$i]}_quantile_data.txt > ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledatamin.txt
          gawk '{print $1, $6}' < ${F_PROFILES}${LINEID}_${grididnum[$i]}_quantile_data.txt > ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledatamax.txt
  # # cleanup ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledatamedian.txt
  # cleanup ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledatamin.txt ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledatamax.txt
  #         # Makes an envelope plottable by GMT
          gawk '{print $1, $4}' < ${F_PROFILES}${LINEID}_${grididnum[$i]}_quantile_data.txt > ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledataq13min.txt
          gawk '{print $1, $5}' < ${F_PROFILES}${LINEID}_${grididnum[$i]}_quantile_data.txt > ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledataq13max.txt
  # cleanup ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledataq13min.txt ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledataq13max.txt
  #
          cat ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledatamax.txt > ${F_PROFILES}${LINEID}_${grididnum[$i]}_profileenvelope.txt
          tecto_tac ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledatamin.txt >> ${F_PROFILES}${LINEID}_${grididnum[$i]}_profileenvelope.txt
  # # cleanup ${F_PROFILES}${LINEID}_${grididnum[$i]}_profileenvelope.txt
  #
          cat ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledataq13min.txt > ${F_PROFILES}${LINEID}_${grididnum[$i]}_profileq13envelope.txt
          tecto_tac ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledataq13max.txt >> ${F_PROFILES}${LINEID}_${grididnum[$i]}_profileq13envelope.txt
  # # cleanup ${F_PROFILES}${LINEID}_${grididnum[$i]}_profileq13envelope.txt
  #
          if [[ ${gridtypelist[$i]} == "S" ]]; then
            # PLOT ON THE COMBINED PS
  #           echo "gmt psxy -Vn ${F_PROFILES}${LINEID}_${grididnum[$i]}_profileenvelope.txt -t$SWATHTRANS -R -J -O -K -G${LIGHTERCOLOR}  >> "${PSFILE}"" >> plot.sh
  #           echo "gmt psxy -Vn -R -J -O -K -t$SWATHTRANS -G${LIGHTCOLOR} ${F_PROFILES}${LINEID}_${grididnum[$i]}_profileq13envelope.txt >> "${PSFILE}"" >> plot.sh
  #           echo "gmt psxy -Vn -R -J -O -K -W$SWATHLINE_WIDTH,$COLOR ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledatamedian.txt >> "${PSFILE}"" >> plot.sh
  #
            # PLOT ON THE FLAT PROFILE PS
            echo "gmt psxy -Vn ${F_PROFILES}${LINEID}_${grididnum[$i]}_profileenvelope.txt -t$SWATHTRANS -R -J -O -K -G${LIGHTERCOLOR}  >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh
            echo "gmt psxy -Vn -R -J -O -K -t$SWATHTRANS -G${LIGHTCOLOR} ${F_PROFILES}${LINEID}_${grididnum[$i]}_profileq13envelope.txt >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh
            echo "gmt psxy -Vn -R -J -O -K -W$SWATHLINE_WIDTH,$COLOR ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledatamedian.txt >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh
  #
  #           echo "if [[ \$3 != \"\" ]]; then" >> ${LINEID}_temp_profiletop.sh
  #             echo "LINERANGE=(\$(gawk < ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledatamedian.txt 'BEGIN { getline; minz=\$2; maxz=\$2 } { minz=(\$2<minz)?\$2:minz; maxz=(\$2>maxz)?\$2:maxz } END { print minz-(maxz-minz)/10, maxz+(maxz-minz)/10 }'))" >> ${LINEID}_temp_profiletop.sh
  #             echo "gmt psxy -T -R\${line_min_x}/\${line_max_x}/\${LINERANGE[0]}/\${LINERANGE[1]} -Y\${PROFILE_HEIGHT_IN} -JX\${PROFILE_WIDTH_IN}/\${PROFILE_TOPPER_HEIGHT_IN} -O -K >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_profiletop.sh
  #             echo "if [[ \$(echo \"\${LINERANGE[0]} < 0 && \${LINERANGE[1]} > 0\" | bc) -eq 1 ]]; then echo \"\${line_min_x} 0T\${line_max_x} 0T\${line_max_x} \${LINERANGE[0]}T\${line_max_x} \${LINERANGE[0]}T\${line_min_x} \${LINERANGE[0]}T\${line_min_x} 0\" | tr 'T' '\n' | gmt psxy -Vn -L+yb -Glightblue -R -J -O -K -W0.25p,0/0/0 >> ${F_PROFILES}${LINEID}_flat_profile.ps; fi" >> ${LINEID}_temp_profiletop.sh
  #             echo "gmt psxy -Vn -L+yb -Gtan -R -J -O -K -W0.25p,0/0/0 ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledatamedian.txt >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_profiletop.sh
  #             echo "gmt psbasemap -J -R -BWEb -O -K -Byaf --MAP_FRAME_PEN=thinner,black --FONT_ANNOT_PRIMARY=\"6p,Helvetica,black\" >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_profiletop.sh
  #           echo "fi" >> ${LINEID}_temp_profiletop.sh
  #
  #
  #           # PLOT ON THE OBLIQUE PROFILE PS
  #           [[ $PLOT_SECTIONS_PROFILEFLAG -eq 1 ]] &&  echo "gmt psxy -p -Vn ${F_PROFILES}${LINEID}_${grididnum[$i]}_profileenvelope.txt -t$SWATHTRANS -R -J -O -K -G${LIGHTERCOLOR}  >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_plot.sh
  #           [[ $PLOT_SECTIONS_PROFILEFLAG -eq 1 ]] &&  echo "gmt psxy -p -Vn -R -J -O -K -t$SWATHTRANS -G${LIGHTCOLOR} ${F_PROFILES}${LINEID}_${grididnum[$i]}_profileq13envelope.txt >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_plot.sh
  #           [[ $PLOT_SECTIONS_PROFILEFLAG -eq 1 ]] &&  echo "gmt psxy -p -Vn -R -J -O -K -W$SWATHLINE_WIDTH,$COLOR ${F_PROFILES}${LINEID}_${grididnum[$i]}_profiledatamedian.txt >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_plot.sh
  #
  #         # Box-and-whisker diagram
          fi
  #         if [[ ${gridtypelist[$i]} == "W" ]]; then
  #           # PLOT ON THE COMBINED PS
  #
  #           if [[ ${gridcptlist[$i]} == "None" ]]; then
  #             boxcptcmd="-Ggray"
  #             boxfile=${F_PROFILES}${LINEID}_${grididnum[$i]}_quantile_data.txt
  #           else
  #             boxcptcmd="-C${gridcptlist[$i]}"
  #             gawk < ${F_PROFILES}${LINEID}_${grididnum[$i]}_quantile_data.txt -v zscale=${gridzscalelist[$i]} '{print $1, $2, $2/zscale, $3, $4, $5, $6}' > ${F_PROFILES}${LINEID}_${grididnum[$i]}_quantile_cpt.txt
  #             boxfile=${F_PROFILES}${LINEID}_${grididnum[$i]}_quantile_cpt.txt
  #           fi
  #
  #           # To set the bin width, we determine the number of bins and the width of the image in points
  #           numboxbins=$(wc -l < ${boxfile})
  #
  #           echo "width_p=\$(echo \"\${PROFILE_WIDTH_IN}\" | gawk '{print (\$1+0)*72}')" >> plot.sh
  #           echo "binwidth_p=\$(echo \"(\${width_p} / ${numboxbins})*0.9\" | bc -l)" >> plot.sh
  #           # echo "echo $numboxbins bins over \${width_p} = \$binwidth_p" >> plot.sh
  #           echo "gmt psxy  ${boxfile} -EY+p0.1p+w\${binwidth_p}p ${boxcptcmd} -Sp -R -J -O -K >> "${PSFILE}"" >> plot.sh
  #
  #           # PLOT ON THE FLAT PROFILE PS
  #           echo "width_p=\$(echo \"\${PROFILE_WIDTH_IN}\" | gawk '{print (\$1+0)*72}')" >> ${LINEID}_temp_plot.sh
  #           echo "binwidth_p=\$(echo \"(\${width_p} / ${numboxbins})*0.9\" | bc -l)" >> ${LINEID}_temp_plot.sh
  #           echo "gmt psxy  ${boxfile} -EY+p0.1p+w\${binwidth_p}p -Sp ${boxcptcmd} -R -J -O -K >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_temp_plot.sh
  #
  #           # PLOT ON THE OBLIQUE PROFILE PS
  #           echo "width_p=\$(echo \"\${PROFILE_WIDTH_IN}\" | gawk '{print (\$1+0)*72}')" >> ${LINEID}_plot.sh
  #           echo "binwidth_p=\$(echo \"(\${width_p} / ${numboxbins})*0.9\" | bc -l)" >> ${LINEID}_plot.sh
  #           [[ $PLOT_SECTIONS_PROFILEFLAG -eq 1 ]] &&  echo "gmt psxy -p -Vn ${boxfile} -EY+p0.1p+w\${binwidth_p}p -Sp ${boxcptcmd} -R -J -O -K >> ${F_PROFILES}${LINEID}_perspective_profile.ps" >> ${LINEID}_plot.sh
  #
  #         fi
  #
          # Paste data for data range calculation
          paste ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilekm.txt ${F_PROFILES}${LINEID}_${grididnum[$i]}_profilesummary.txt > tmp.txt
          update_profile_bounds 1 2,6 < tmp.txt

        fi
      fi
    done

    # Add profile X limits to all_data in case plotted data does not span profile.
    # echo "$PROFILE_XMIN NaN NaN NaN NaN NaN" >> ${F_PROFILES}${LINEID}_all_data.txt
    # echo "$PROFILE_XMAX NaN NaN NaN NaN NaN" >> ${F_PROFILES}${LINEID}_all_data.txt

    echo "$PROFILE_XMIN" > tmp.txt
    echo "$PROFILE_XMAX" >> tmp.txt
    update_profile_bounds 1 100 < tmp.txt
    rm -f tmp.txt

    # COMEBACK: If auto+min is set using -profauto, add relevant points to all_data.txt

    if [[ $setprofautodepthflag -eq 1 ]]; then
      # echo "$PROFILE_XMIN $SPROF_MINELEV_AUTO NaN NaN NaN NaN" >> ${F_PROFILES}${LINEID}_all_data.txt
      # echo "$PROFILE_XMAX $SPROF_MINELEV_AUTO NaN NaN NaN NaN" >> ${F_PROFILES}${LINEID}_all_data.txt
      # echo "$PROFILE_XMIN $SPROF_MAXELEV_AUTO NaN NaN NaN NaN" >> ${F_PROFILES}${LINEID}_all_data.txt
      # echo "$PROFILE_XMAX $SPROF_MAXELEV_AUTO NaN NaN NaN NaN" >> ${F_PROFILES}${LINEID}_all_data.txt

      echo "$PROFILE_XMIN $SPROF_MINELEV_AUTO" > tmp.txt
      echo "$PROFILE_XMAX $SPROF_MINELEV_AUTO" >> tmp.txt
      echo "$PROFILE_XMIN $SPROF_MAXELEV_AUTO" >> tmp.txt
      echo "$PROFILE_XMAX $SPROF_MAXELEV_AUTO" >> tmp.txt

      update_profile_bounds 1 2 < tmp.txt
      rm -f tmp.txt

    fi

    # gawk < ${F_PROFILES}${LINEID}_all_data.txt '{
    #     if ($1 ~ /^[-+]?[0-9]*\.?[0-9]+$/) { km[++c]=$1; }
    #     if ($2 ~ /^[-+]?[0-9]*\.?[0-9]+$/) { val[++d]=$2; }
    #     if ($6 ~ /^[-+]?[0-9]*\.?[0-9]+$/) { val[++d]=$6; }
    #   } END {
    #     asort(km);
    #     asort(val);
    #     print km[1], km[length(km)], val[1], val[length(val)]
    #   #  print km[1]-(km[length(km)]-km[1])*0.01,km[length(km)]+(km[length(km)]-km[1])*0.01,val[1]-(val[length(val)]-val[1])*0.1,val[length(val)]+(val[length(val)]-val[1])*0.1
    # }' > ${F_PROFILES}${LINEID}_limits.txt

    report_profile_bounds > ${F_PROFILES}${LINEID}_limits.txt


    if [[ $xminflag -eq 1 ]]; then
      line_min_x=$(gawk < ${F_PROFILES}${LINEID}_limits.txt '{print $1}')
    else
      line_min_x=$min_x
    fi
    if [[ $xmaxflag -eq 1 ]]; then
      line_max_x=$(gawk < ${F_PROFILES}${LINEID}_limits.txt '{print $2}')
    else
      line_max_x=$max_x
    fi
    if [[ $zminflag -eq 1 ]]; then
      line_min_z=$(gawk < ${F_PROFILES}${LINEID}_limits.txt '{print $3}')
    else
      line_min_z=$min_z
    fi
    if [[ $zmaxflag -eq 1 ]]; then
      line_max_z=$(gawk < ${F_PROFILES}${LINEID}_limits.txt '{print $4}')
    else
      line_max_z=$max_z
    fi

    PROFILE_HEIGHT_IN_TMP=${PROFILE_HEIGHT_IN}

    # Set minz to ensure that H=W
    if [[ $profileonetooneflag -eq 1 ]]; then
      if [[ ${OTO_METHOD} =~ "change_z" ]]; then
        info_msg "(-mob) Setting vertical aspect ratio to H=W for profile ${LINEID} by changing Z range"
        line_diffx=$(echo "$line_max_x - $line_min_x" | bc -l)
        line_hwratio=$(gawk -v vertex=${PROFILE_VERT_EX} -v h=${PROFILE_HEIGHT_IN} -v w=${PROFILE_WIDTH_IN} 'BEGIN { print 1/vertex*(h+0)/(w+0) }')
        line_diffz=$(echo "$line_hwratio * $line_diffx" | bc -l)
        line_min_z=$(echo "$line_max_z - $line_diffz" | bc -l)
        info_msg "Profile ${LINEID} new min_z is $line_min_z"
      else
        info_msg "(-mob) Setting vertical aspect ratio to H=W for profile ${LINEID} by changing profile height (currently PROFILE_HEIGHT_IN=${PROFILE_HEIGHT_IN})"

        # calculate X range
        line_diffx=$(echo "$line_max_x - $line_min_x" | bc -l)
        # calculate Z range
        line_diffz=$(echo "$line_max_z - $line_min_z" | bc -l)

        # calculate new PROFILE_HEIGHT_IN
        PROFILE_HEIGHT_IN_TMP=$(gawk -v vertex=${PROFILE_VERT_EX} -v dx=${line_diffx} -v dz=${line_diffz} -v w=${PROFILE_WIDTH_IN} 'BEGIN { print vertex*(w+0)*(dz+0)/(dx+0) }')"i"
        info_msg "New profile height for ${LINEID} is $PROFILE_HEIGHT_IN_TMP"
      fi

      # Buffer with equal width based on Z range
      if [[ $BUFFER_PROFILES -eq 1 ]]; then
        zrange_buf=$(echo "($line_max_z - $line_min_z) * ($BUFFER_WIDTH_FACTOR)" | bc -l)
        line_max_x=$(echo "$line_max_x + $zrange_buf" | bc -l)
        line_min_x=$(echo "$line_min_x - $zrange_buf" | bc -l)
        line_max_z=$(echo "$line_max_z + $zrange_buf" | bc -l)
        line_min_z=$(echo "$line_min_z - $zrange_buf" | bc -l)
      fi
      info_msg "After buffering, range is $line_min_x $line_max_x $line_min_z $line_max_z"
    else
      # Buffer X and Z ranges separately
      if [[ $BUFFER_PROFILES -eq 1 ]]; then
        xrange_buf=$(echo "($line_max_x - $line_min_x) * ($BUFFER_WIDTH_FACTOR)" | bc -l)
        line_max_x=$(echo "$line_max_x + $xrange_buf" | bc -l)
        line_min_x=$(echo "$line_min_x - $xrange_buf" | bc -l)
        zrange_buf=$(echo "($line_max_z - $line_min_z) * ($BUFFER_WIDTH_FACTOR)" | bc -l)
        line_max_z=$(echo "$line_max_z + $zrange_buf" | bc -l)
        line_min_z=$(echo "$line_min_z - $zrange_buf" | bc -l)
      fi
    fi

    x_axis_label_cross="Across-profile distance (km)"

    # Create the flat profile plot
    # Profiles will be plotted by a master script that feeds in the appropriate parameters based on all profiles.
    echo "line_min_x=${PROFILE_XMIN}" >> ${LINEID}_profile.sh
    echo "line_max_x=${PROFILE_XMAX}" >> ${LINEID}_profile.sh
    echo "line_min_z=\$1" >> ${LINEID}_profile.sh
    echo "line_max_z=\$2" >> ${LINEID}_profile.sh
    echo "PROFILE_HEIGHT_IN=${PROFILE_HEIGHT_IN_TMP}" >> ${LINEID}_profile.sh
    echo "PROFILE_WIDTH_IN=${PROFILE_WIDTH_IN}" >> ${LINEID}_profile.sh

    # Center the frame on the new PS document
    echo "gmt psbasemap -Vn -JX\${PROFILE_WIDTH_IN}/\${PROFILE_HEIGHT_IN} -Bltrb -R\${line_min_x}/\${line_max_x}/\${line_min_z}/\${line_max_z} --MAP_FRAME_PEN=thinner,black -K -Xc -Yc > ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_profile.sh
    cat ${LINEID}_temp_plot.sh >> ${LINEID}_profile.sh
    cleanup ${LINEID}_temp_plot.sh

    echo "gmt psbasemap -Vn -B${axeslabelcmd} -Baf -Bx+l\"${x_axis_label_cross}\" -By+l\"${z_axis_label}\" --FONT_TITLE=\"${PROFILE_TITLE_FONT}\" --FONT_ANNOT_PRIMARY=\"${PROFILE_NUMBERS_FONT}\" --FONT_LABEL=\"${PROFILE_AXIS_FONT}\" --MAP_FRAME_PEN=thinner,black -R -J -O -K >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_profile.sh

    echo "grep \") sh mx\" ${F_PROFILES}${LINEID}_flat_profile.ps | gawk '{val[NR]=substr(\$1,2,length(\$1)-2)} END {print val[2]-val[1]}' > ${F_PROFILES}${LINEID}_interval.txt" >> ${LINEID}_profile.sh

    # # Bring in the code to plot the top swath profile panel, if necessary
    # [[ -s ${LINEID}_temp_profiletop.sh ]] && cat ${LINEID}_temp_profiletop.sh >> ${LINEID}_profile.sh && cleanup ${LINEID}_temp_profiletop.sh

    # Finalize the profile and convert to PDF
    echo "gmt psxy -T -R -J -O >> ${F_PROFILES}${LINEID}_flat_profile.ps" >> ${LINEID}_profile.sh
    echo "gmt psconvert -Tf -A+m0.5i ${F_PROFILES}${LINEID}_flat_profile.ps >/dev/null 2>&1" >> ${LINEID}_profile.sh

    echo ". ./${LINEID}_profile.sh ${line_min_z} ${line_max_z} \${3}" >> ./plot_flat_profiles.sh
    chmod a+x ./${LINEID}_profile.sh

    # Increment the profile number
    PROFILE_INUM=$(echo "$PROFILE_INUM + 1" | bc)

  ;;
esac # case looking for profile types, e.g. P,A
done < $TRACKFILE

[[ -e end_points.txt ]] && mv end_points.txt ${F_PROFILES}
[[ -e mid_points.txt ]] && mv mid_points.txt ${F_PROFILES}
[[ -e start_points.txt ]] && mv start_points.txt ${F_PROFILES}

# # Set a buffer around the data extent to give a nice visual appearance when setting auto limits
# cat ${F_PROFILES}*_all_data.txt > ${F_PROFILES}all_data.txt
#
# gawk < ${F_PROFILES}all_data.txt '{
#     if ($1 ~ /^[-+]?[0-9]*\.?[0-9]+$/) { km[++c]=$1; }
#     if ($2 ~ /^[-+]?[0-9]*\.?[0-9]+$/) { val[++d]=$2; }
#     if ($6 ~ /^[-+]?[0-9]*\.?[0-9]+$/) { val[++d]=$6; }
#   } END {
#     asort(km);
#     asort(val);
#     print km[1], km[length(km)], val[1], val[length(val)]
#   #  print km[1]-(km[length(km)]-km[1])*0.01,km[length(km)]+(km[length(km)]-km[1])*0.01,val[1]-(val[length(val)]-val[1])*0.1,val[length(val)]+(val[length(val)]-val[1])*0.1
# }' > ${F_PROFILES}limits.txt

# Calculate the overall max extents from data (mainly for Z range)
reset_profile_bounds
for this_file in ${F_PROFILES}*_limits.txt; do
  update_profile_bounds 1,2 3,4 < ${this_file}
done

# stacked profiles need to respect X bounds of all profiles regardless of
# data spread
for this_file in ${F_PROFILES}*_dist_km.txt; do
  update_profile_bounds 1 < ${this_file}
done

report_profile_bounds > ${F_PROFILES}limits.txt
# These are hard data limits.

# If we haven't manually specified a limit, set it using the buffered data limit
# But for deep data sets, this will add a buffer to max_z that once one-to-one is applied
# will cause the section to be way too low. So we need to do the buffer after the one-to-one.

if [[ $xminflag -eq 1 ]]; then
  min_x=$(gawk < ${F_PROFILES}limits.txt '{print $1}')
fi
if [[ $xmaxflag -eq 1 ]]; then
  max_x=$(gawk < ${F_PROFILES}limits.txt '{print $2}')
fi
if [[ $zminflag -eq 1 ]]; then
  min_z=$(gawk < ${F_PROFILES}limits.txt '{print $3}')
fi
if [[ $zmaxflag -eq 1 ]]; then
  max_z=$(gawk < ${F_PROFILES}limits.txt '{print $4}')
fi

PROFILE_HEIGHT_IN_TMP=${PROFILE_HEIGHT_IN}

# Set the scaling for the combined profiles

# Set minz/maxz to ensure that H=W
if [[ $profileonetooneflag -eq 1 ]]; then
  if [[ ${OTO_METHOD} =~ "change_z" ]]; then
    info_msg "All profiles: Setting vertical aspect ratio to H=W by changing Z range"
    diffx=$(echo "$max_x - $min_x" | bc -l)
    hwratio=$(gawk -v h=${PROFILE_HEIGHT_IN_TMP} -v w=${PROFILE_WIDTH_MAX_IN} 'BEGIN { print (h+0)/(w+0) }')
    diffz=$(echo "$hwratio * $diffx" | bc -l)
    min_z=$(echo "$max_z - $diffz" | bc -l)
    info_msg "new min_z is $min_z"
  else
    info_msg "(-mob) Setting vertical aspect ratio to H=W for profile ${LINEID} by changing profile height (currently PROFILE_HEIGHT_IN=${PROFILE_HEIGHT_IN})"
    # calculate X range
    line_diffx=$(echo "$max_x - $min_x" | bc -l)
    # calculate Z range
    line_diffz=$(echo "$max_z - $min_z" | bc -l)
    # calculate new PROFILE_HEIGHT_IN
    PROFILE_HEIGHT_IN_TMP=$(gawk -v dx=${line_diffx} -v dz=${line_diffz} -v w=${PROFILE_WIDTH_MAX_IN} 'BEGIN { print (w+0)*(dz+0)/(dx+0) }')"i"
    info_msg "All profiles: New profile height for ${LINEID} is $PROFILE_HEIGHT_IN_TMP"
  fi
fi

# Add a buffer around the data if we haven't asked for hard limits.

# Create the data files that will be used to plot the profile vertex points above the profile
# Strategery: plot at mid-z level and add half profile height + buffer using -Ya

cd ${F_PROFILES}
for distfile in *_dist_km.txt; do
  gawk < $distfile -v maxz=$max_z -v minz=$min_z -v profheight=${PROFILE_HEIGHT_IN} '{
    print $1, (maxz+minz)/2
  }' > xpts_$distfile
done
cd ..

maxzval=$(gawk -v maxz=$max_z -v minz=$min_z 'BEGIN {print (maxz+minz)/2}')

PROFHEIGHT_OFFSET=$(echo "${PROFILE_HEIGHT_IN_TMP}" | gawk '{print ($1+0)/2 + 4/72}')

echo "echo \"0 $maxzval\" | gmt psxy -J -R -K -O -N -St0.1i -Ya${PROFHEIGHT_OFFSET}i -W0.7p,black -Gwhite >> ${PSFILE}" >> plot.sh


if [[ $plotprofiletitleflag -eq 1 ]]; then
  LINETEXT=$(cat ${F_PROFILES}IDfile.txt)
else
  LINETEXT=""
fi

# FOR THE COMBINED PROFILE
# First, define variables and plot the frame. This sets -R and -J for the
# actual plotting script commands in plot.sh

# echo "#!/usr/bin/env bash" > plot_combined_profiles.sh
echo "rm -f ${PSFILE}" > plot_combined_profiles.sh
echo "line_min_x=${min_x}" >> plot_combined_profiles.sh
echo "line_max_x=${max_x}" >> plot_combined_profiles.sh
echo "line_min_z=${min_z}" >> plot_combined_profiles.sh
echo "line_max_z=${max_z}" >> plot_combined_profiles.sh
echo "PROFILE_WIDTH_IN=${PROFILE_WIDTH_MAX_IN}" >> plot_combined_profiles.sh
echo "PROFILE_HEIGHT_IN=${PROFILE_HEIGHT_IN_TMP}" >> plot_combined_profiles.sh
PROFILE_Y_C=$(echo ${PROFILE_HEIGHT_IN} ${PROFILE_WIDTH_IN} | gawk '{print ($1+0)+($2+0)  "i"}')
echo "Ho2=\$(echo \$PROFILE_HEIGHT_IN | gawk '{print (\$1+0)/2 + 4/72 \"i\"}')"  >> plot_combined_profiles.sh
echo "halfz=\$(echo \"(\$line_max_z + \$line_min_z)/2\" | bc -l)"  >> plot_combined_profiles.sh
echo "PROFILE_Y_C=\$(echo \${PROFILE_HEIGHT_IN} \${PROFILE_WIDTH_IN} | gawk '{print (\$1+0)+(\$2+0)  \"i\"}')"  >> plot_combined_profiles.sh
# Update March 25 2022: we just plot in the center of the area as we will cut with psconvert -A+m later
# echo "gmt psbasemap -Vn -JX\${PROFILE_WIDTH_IN}/\${PROFILE_HEIGHT_IN} -X${PROFILE_X} -Y\${PROFILE_Y_C} -Bltrb -R\$line_min_x/\$line_max_x/\$line_min_z/\$line_max_z --MAP_FRAME_PEN=thinner,black -K >> ${PSFILE}" >> plot_combined_profiles.sh
echo "gmt psbasemap -Vn -JX\${PROFILE_WIDTH_IN}/\${PROFILE_HEIGHT_IN} -Xc -Yc -Bltrb -R\$line_min_x/\$line_max_x/\$line_min_z/\$line_max_z --MAP_FRAME_PEN=thinner,black -K >> ${PSFILE}" >> plot_combined_profiles.sh
cat plot.sh >> plot_combined_profiles.sh
echo "gmt psbasemap -Vn -B${axeslabelcmd}+t\"${LINETEXT}\" -Baf -Bx+l\"${x_axis_label}\" -By+l\"${z_axis_label}\" --FONT_TITLE=\"${PROFILE_TITLE_FONT}\" --FONT_ANNOT_PRIMARY=\"${PROFILE_NUMBERS_FONT}\" --FONT_LABEL=\"${PROFILE_AXIS_FONT}\" --MAP_FRAME_PEN=thinner,black $RJOK >> ${PSFILE}" >> plot_combined_profiles.sh
echo "gmt psxy -T -R -J -O -Vn >> ${PSFILE}" >> plot_combined_profiles.sh
echo "gmt psconvert -Tf -A+m0.5i ${PSFILE} >/dev/null 2>&1" >> plot_combined_profiles.sh

# Execute plot script
chmod a+x ./plot_combined_profiles.sh
. ./plot_combined_profiles.sh

cleanup plot.sh


# FOR THE FLAT PROFILES
mv ./plot_flat_profiles.sh ./tmp.sh
# echo "#!/bin/bash" > ./plot_flat_profiles.sh
cat ./tmp.sh >> ./plot_flat_profiles.sh
chmod a+x ./plot_flat_profiles.sh
. ./plot_flat_profiles.sh $min_z $max_z ${PROFTOPOHEIGHT}

# FOR THE OBLIQUE SECTIONS
if [[ $MAKE_OBLIQUE_PROFILES -eq 1 ]]; then
   chmod a+x ./plot_perspective_profiles.sh
   . ./plot_perspective_profiles.sh ${PERSPECTIVE_AZ} ${PERSPECTIVE_INC} ${PERSPECTIVE_EXAG}
fi


# Not sure this is needed anymore?

# Pass intersection points, profile data back to tectoplot
#
# if [[ $gridfileflag -eq 1 ]]; then
#   cp *_profiletable.txt /var/tmp/tectoplot
# fi
# cp projpts_* /var/tmp/tectoplot
# cp buf_poly.txt /var/tmp/tectoplot
# [[ $zeropointflag -eq 1 && $doxflag -eq 1 ]] && cp all_intersect.txt /var/tmp/tectoplot/all_intersect.txt

# gmt psbasemap -Vn -B${axeslabelcmd}+t"${LINETEXT}" -Baf -Bx+l"Distance (km)" --FONT_TITLE="${PROFILE_NUMBERS_FONT}" --MAP_FRAME_PEN=0.5p,black $RJOK >> "${PSFILE}"


# The idea here is to return to the correct X,Y position to allow further
# plotting on the map by tectoplot, if mprof) was called in the middle of
# plotting for some reason.


if [[ ${PROFILE_X:0:1} == "-" ]]; then
  PROFILE_X="${PROFILE_X:1}"
elif [[ ${PROFILE_WIDTH_IN:0:1} == "+" ]]; then
  PROFILE_X=$(echo "-${PROFILE_X:1}")
else
  PROFILE_X=$(echo "-${PROFILE_X}")
fi

if [[ ${PROFILE_Y:0:1} == "-" ]]; then
  PROFILE_Y="${PROFILE_Y:1}"
elif [[ ${PROFILE_Y:0:1} == "+" ]]; then
  PROFILE_Y=$(echo "-${PROFILE_Y:1}")
else
  PROFILE_Y=$(echo "-${PROFILE_Y}")
fi

# Changed from a different call to psxy ... not fully tested
if [[ $MAKE_MAP_PROFILE_NO_NEED_TO_DO_THIS_NOW -eq 1 ]]; then
  PROFILE_Y_C_M=$(echo ${PROFILE_Y_C} | gawk '{print 0-$1 "i"}')
  gmt psxy -T -J -R -O -K -X$PROFILE_X -Y$PROFILE_Y_C_M -Vn >> "${PSFILE}"
fi

gmt gmtset FORMAT_FLOAT_OUT ${OLD_FORMAT_FLOAT_OUT}

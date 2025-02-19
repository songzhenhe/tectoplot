#!/bin/bash

# tectoplot
# bashscripts/cmt_tools.sh
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

# Awk tools ingest focal mechanism data into tectoplot format

# Usage
# cmt_tools.sh FILE FORMATCODE IDCODE SWITCH

# If FILE is a single hyphen - , then read from stdin

# We want to be able to ingest focal mechanism data in different formats. Note that [newdepth] is
# accepted as an extra field tacked onto the end of GMT's standard input formats. That is followed
# by a [timecode] in the format YYYY-MM-DDTHH:MM:SS

# FOR GMT FORMATS,
# We assume that X Y depth are ORIGIN locations and newX newY newdepth are CENTROID locations.
# If SWITCH=="switch" then we switch this assignment ***AT THE OUTPUT STEP***

# tectoplot focal mechanisms have a 2 letter ID with a source character (A-Z) and a mechanism type (TSN)
# I=ISC G=GCMT. All other characters can be used.

# Includes a fix for moment for ASIES (Taiwan) mechanisms in the ISC catalog
# that are reported in dynes-cm and not N-m

#
#  Fields without a value should contain "none" if subsequent fields need to be used.
#  e.g. for format a
#  109 -10 12 120 20 87 4.5 none none none none 1973-12-01T05:04:22
#

# Code   GMT or other format info
# ----   -----------------------------------------------------------------------
#   a    psmeca Aki and Richards format (mag= 28. MW)
#         X Y depth strike dip rake mag [newX newY] [event_title] [newdepth] [timecode]
#   c    psmeca GCMT format
#         X Y depth strike1 dip1 rake1 aux_strike dip2 rake2 moment [newX newY] [event_title] [newdepth] [timecode]
#   x    psmeca principal axes
#         X Y depth T_value T_azim T_plunge N_value N_azim N_plunge P_value P_azim P_plunge exp [newX newY] [event_title] [newdepth] [timecode]
#   m    psmeca moment tensor format
#         X Y depth mrr mtt mff mrt mrf mtf exp [newX newY] [event_title] [newdepth] [timecode]
#   I    ISC focal mechanism, CSV format
#        EVENT_ID,AUTHOR, DATE, TIME, LAT, LON, DEPTH, CENTROID, AUTHOR, EX,MO, MW, EX,MRR, MTT, MPP, MRT, MTP, MPR, STRIKE1, DIP1, RAKE1, STRIKE2, DIP2, RAKE2, EX,T_VAL, T_PL, T_AZM, P_VAL, P_PL, P_AZM, N_VAL, N_PL, N_AZM
#   K    NDK format (e.g. GCMT)
#  ---   -----------------------------------------------------------------------

# OUTPUT FORMAT
#  idcode event_code id epoch lon_centroid lat_centroid depth_centroid lon_origin lat_origin depth_origin author_centroid author_origin MW mantissa exponent strike1 dip1 rake1 strike2 dip2 rake2 exponent Tval Taz Tinc Nval Naz Ninc Pval Paz Pinc exponent Mrr Mtt Mpp Mrt Mrp Mtp centroid_dt

# Assumes that these variables are set (as environment variables or when this script is sourced using . bash command)

if [[ $1 == "format" ]]; then
  echo "idcode event_code id epoch lon_centroid lat_centroid depth_centroid lon_origin lat_origin depth_origin author_centroid author_origin MW mantissa exponent strike1 dip1 rake1 strike2 dip2 rake2 exponent Tval Taz Tinc Nval Naz Ninc Pval Paz Pinc exponent Mrr Mtt Mpp Mrt Mrp Mtp centroid_dt"
  exit
fi

INFILE=$1
# if [[ $INFILE == "stdin" ]]; then
#   INFILE=$(cat -)
# fi

# ISC data are comma delimited.
if [[ $2 == "I" ]]; then
  DELIM="-F,"
else
  DELIM=""
fi


# The main problem here is that DIAGSCRIPT gets called many times which is VERY
# SLOW. We can make diagscript work on a file but can't make that work on the
# line-by-line basis that this script currently takes...

gawk < "${INFILE}" ${DELIM} -v FMT="${2}" -v INID="${3}" '
@include "tectoplot_functions.awk"

######### CODE BLOCK TO RUN BEFORE PROCESSING LINES GOES HERE ##################
BEGIN {

  ###### For each input format, we define which components we need to calculate.

  calc_ntp_from_moment_tensor=0
  calc_mantissa_from_exp_and_mt=0
  calc_sdr_from_ntp=0
  calc_sdr2=0
  calc_moment_tensor_from_sdr1=0
  calc_mant_exp_from_M=0
  calc_principal_axes_from_sdr1=0
  calc_M_from_mantissa_exponent=0
  calc_epoch=0

  # Aki and Richard  psmeca -Sa
  if (FMT=="a"||FMT=="A") {
    calc_ntp_from_moment_tensor=0
    calc_mantissa_from_exp_and_mt=0
    calc_sdr_from_ntp=0
    calc_sdr2=1
    calc_moment_tensor_from_sdr1=1
    calc_mant_exp_from_M=1
    calc_principal_axes_from_sdr1=1
    calc_M_from_mantissa_exponent=0
    calc_epoch=1
    determine_calcs_needed_each_step=0
  }

  #  X Y depth strike1 dip1 rake1 aux_strike dip2 rake2 mantissa exponent [newX newY] [event_title]
  # Global CMT   psmeca -Sc
  if (FMT=="c"||FMT=="C") {
    calc_ntp_from_moment_tensor=0
    calc_mantissa_from_exp_and_mt=0
    calc_sdr_from_ntp=0
    calc_sdr2=0
    calc_moment_tensor_from_sdr1=1
    calc_mant_exp_from_M=0
    calc_principal_axes_from_sdr1=1
    calc_M_from_mantissa_exponent=1
    calc_epoch=1
    determine_calcs_needed_each_step=0

  }

  #  X Y depth mrr mtt mff mrt mrf mtf exp [newX newY event_id newdepth epoch cluster_id iso8601_code]
  # Moment tensor   psmeca -Sm
  if (FMT=="m"||FMT=="M") {
    calc_ntp_from_moment_tensor=1
    calc_mantissa_from_exp_and_mt=1
    calc_sdr_from_ntp=1
    calc_sdr2=0
    calc_moment_tensor_from_sdr1=0
    calc_mant_exp_from_M=0
    calc_principal_axes_from_sdr1=0
    calc_M_from_mantissa_exponent=1
    calc_epoch=1
    determine_calcs_needed_each_step=0
  }

  # NDK
  if (FMT=="K") {
    calc_ntp_from_moment_tensor=0
    calc_mantissa_from_exp_and_mt=0
    calc_sdr_from_ntp=0
    calc_sdr2=0
    calc_moment_tensor_from_sdr1=0
    calc_mant_exp_from_M=0
    calc_principal_axes_from_sdr1=0
    calc_M_from_mantissa_exponent=1
    calc_epoch=1
    determine_calcs_needed_each_step=0
  }

  # ISC CSV
  # Note that moments are in N-m and not dynes-cm (factor of 10^7 apparently)
  if (FMT=="I") {
    calc_ntp_from_moment_tensor=0
    calc_mantissa_from_exp_and_mt=0
    calc_sdr_from_ntp=0
    calc_sdr2=0
    calc_moment_tensor_from_sdr1=0
    calc_mant_exp_from_M=0
    calc_principal_axes_from_sdr1=0
    calc_M_from_mantissa_exponent=0
    calc_epoch=1
    determine_calcs_needed_each_step=1
  }

  # GFZ focal mechanisms.
  if (FMT=="Z") {
    calc_ntp_from_moment_tensor=0
    calc_mantissa_from_exp_and_mt=0
    calc_sdr_from_ntp=0
    calc_sdr2=0
    calc_moment_tensor_from_sdr1=0

    # GFZ has weird exponent and very weird TNP axes. Just recalc from MW and SDR
    calc_mant_exp_from_M=1
    calc_principal_axes_from_sdr1=1
    calc_M_from_mantissa_exponent=0
    calc_epoch=1
    determine_calcs_needed_each_step=0
  }


}
################# END OF BEGIN BLOCK ###########################################

########## CODE BLOCK TO PROCESS EACH LINE GOES HERE ###########################
{

  # Skip blank lines and lines that begin with a # (comments)
  if(($1!="") && (substr($1,1,1)!="#")) {

    idcode="none"
    event_code="none"
    id="none"
    epoch="none"
    lon_centroid="none"
    lat_centroid="none"
    depth_centroid="none"
    lon_origin="none"
    lat_origin="none"
    depth_origin="none"
    author_centroid="none"
    author_origin="none"
    MW="none"
    mantissa="none"
    exponent="none"
    strike1=0
    dip1=0
    rake1=0
    strike2=0
    dip2=0
    rake2=0


    Tval=1
    Nval=0
    Pval=-1
    Taz=0
    Tinc=0
    Naz=0
    Ninc=0
    Paz=0
    Pinc=0
    Mrr=0
    Mtt=0
    Mpp=0
    Mrt=0
    Mrp=0
    Mtp=0

    centroid_dt=0
    skip_this_entry=0

    np1_exists=0
    np2_exists=0
    tensor_exists
    ntp_axes_exist=0

    SDR[1]=0
    SDR[2]=0
    SDR[3]=0
    SDR[4]=0
    SDR[5]=0
    SDR[6]=0
    TNP[1]=0
    TNP[2]=0
    TNP[3]=0
    TNP[4]=0
    TNP[5]=0
    TNP[6]=0
    TNP[7]=0
    TNP[8]=0
    TNP[9]=0
    MT2[1]=0
    MT2[2]=0
    MT2[3]=0
    MT2[4]=0
    MT2[5]=0
    MT2[6]=0

    ##### Read the input lines based on the input format

    # ------------------------------#
    # FMT=a or FMT==A is Aki and Richards (a=ORIGIN, A=CENTROID)
    if (FMT=="a"||FMT=="A") {
      # X Y depth strike dip rake mag [newX newY] [event_title] [newZ]
      if (FMT=="a") {
        lon_origin=$1
        lat_origin=$2
        depth_origin=$3
        strike1=$4
        dip1=$5
        rake1=$6
        MW=$7

        ### Optional fields
        if (NF > 7) {
          lon_centroid=$8
        } else {
          lon_centroid="none"
        }
        if (NF > 8) {
          lat_centroid=$9
        } else {
          lat_centroid="none"
        }
        if (NF > 10) {
          depth_centroid=$11
        } else {
          depth_centroid="none"
        }
      } else {
        lon_centroid=$1
        lat_centroid=$2
        depth_centroid=$3

        ### Optional fields
        if (NF > 7) {
          lon_origin=$8
        } else {
          lon_origin="none"
        }
        if (NF > 8) {
          lat_origin=$9
        } else {
          lat_origin="none"
        }
        if (NF > 10) {
          depth_origin=$11
        } else {
          depth_origin="none"
        }
      }


      ### Optional fields
      # if (NF > 7) {
      #   lon_centroid=$8
      # } else {
      #   lon_centroid="none"
      # }
      # if (NF > 8) {
      #   lat_centroid=$9
      # } else {
      #   lat_centroid="none"
      # }
      # if (NF > 10) {
      #   depth_centroid=$11
      # } else {
      #   depth_centroid="none"
      # }

      if (NF > 9) {
        event_code=$10
      } else {
        event_code="nocode"
      }

      if (NF > 11) {
        id=make_tectoplot_id($12)
      } else {
        id=make_tectoplot_id("")
      }
      ### End optional fields
    } # FMT = a|A
    # ------------------------------#

    # ------------------------------#
    # FMT=c is GCMT
    if (FMT=="c"||FMT=="C") {
      # X Y depth strike1 dip1 rake1 strike2 dip2 rake2 mantissa exponent [newX newY] [event_title] [depth_centroid]

      if (FMT=="c") {
        lon_origin=$1
        lat_origin=$2
        depth_origin=$3
        if (NF > 11) {
          lon_centroid=$12
        } else {
          lon_centroid="none"
        }
        if (NF > 12) {
          lat_centroid=$13
        } else {
          lat_centroid="none"
        }
        if (NF > 14) {
          depth_centroid=$15
        } else {
          depth_centroid="none"
        }


      } else {
        lon_centroid=$1
        lat_centroid=$2
        depth_centroid=$3
        if (NF > 11) {
          lon_origin=$12
        } else {
          lon_origin="none"
        }
        if (NF > 12) {
          lat_origin=$13
        } else {
          lat_origin="none"
        }
        if (NF > 14) {
          depth_origin=$15
        } else {
          depth_origin="none"
        }

      }

      strike1=$4
      dip1=$5
      rake1=$6
      strike2=$7
      dip2=$8
      rake2=$9
      mantissa=$10
      exponent=$11

      ### Optional fields
      # if (NF > 11) {
      #   lon_centroid=$12
      # } else {
      #   lon_centroid="none"
      # }
      # if (NF > 12) {
      #   lat_centroid=$13
      # } else {
      #   lat_centroid="none"
      # }
      if (NF > 13) {
        event_code=$14
      } else {
        event_code="nocode"
      }
      # if (NF > 14) {
      #   depth_centroid=$15
      # } else {
      #   depth_centroid="none"
      # }
      if (NF > 15) {
        id=make_tectoplot_id($16)
      } else {
        id=make_tectoplot_id("")
      }
    } # FMT = c
    #---------------------------------#

    #----------------------------------#
    # X Y depth mrr mtt mpp mrt mrp mtp exp [newX newY] [event_title] [newdepth]
    # FMT=m is moment tensor   psmeca -Sm
    # m indicates origin location, M indicates centroid location
    if (FMT=="m"||FMT=="M") {
      if (FMT=="m") {
        lon_origin=$1
        lat_origin=$2
        depth_origin=$3
        if (NF > 10) {
          lon_centroid=$11
        } else {
          lon_centroid="none"
        }
        if (NF > 11) {
          lat_centroid=$12
        } else {
          lat_centroid="none"
        }
        if (NF > 13) {
          depth_centroid=$14
        } else {
          depth_centroid="none"
        }
      } else {
        lon_centroid=$1
        lat_centroid=$2
        depth_centroid=$3
        if (NF > 10) {
          lon_origin=$11
        } else {
          lon_origin="none"
        }
        if (NF > 11) {
          lat_origin=$12
        } else {
          lat_origin="none"
        }
        if (NF > 13) {
          depth_origin=$14
        } else {
          depth_origin="none"
        }
      }
      Mrr=$4
      Mtt=$5
      Mpp=$6
      Mrt=$7
      Mrp=$8
      Mtp=$9
      exponent=$10

      ### Optional fields
      if (NF > 12) {
        event_code=$13
      } else {
        event_code="nocode"
      }
      if (NF > 14) {
        id=make_tectoplot_id($15)
      } else {
        id=make_tectoplot_id("")
      }
      if (NF > 15) {
        cluster_id=$16
      } else {
        cluster_id=0
      }
      if (NF > 16) {
        id=$17
      } else {
        id=make_tectoplot_id("")
      }
    } # FMT = m
    #------------------------------#

    #----------------------------------#
    # NDK files will always have every entry defined (at least for GCMT NDK)
    if (FMT=="K") {
      ###### Each NDK entry consists of five lines. We enter with the first line in $0

      #First line: Hypocenter line
      #[1-4]   Hypocenter reference catalog (e.g., PDE for USGS location, ISC for
      #        ISC catalog, SWE for surface-wave location, [Ekstrom, BSSA, 2006])
      #[6-15]  Date of reference event
      #[17-26] Time of reference event
      #[28-33] Latitude
      #[35-41] Longitude
      #[43-47] Depth
      #[49-55] Reported magnitudes, usually mb and MS
      #[57-80] Geographical location (24 characters)

      # Determine the catalog the provided the origin information
      author_origin=substr($0,1,4);

      # Determine the origin date and time.
      date=substr($0,6,10);
      split(date,dstring,"/");
      month=dstring[2];
      day=dstring[3];
      year=dstring[1];
      time=substr($0,17,10);
      split(time,tstring,":");
      hour=tstring[1];
      minute=tstring[2];
      second=tstring[3];

      # convert to seconds since epoch
      # the_time=sprintf("%i %i %i %i %i %i",year,month,day,hour,minute,int(second+0.5));
      # secs = mktime(the_time);

      # tectoplot uses this event ID/timecode format: YYYY-MM-DD:HH-MM-SS
      id=make_tectoplot_id(sprintf("%04d-%02d-%02dT%02d:%02d:%02d",year,month,day,hour,minute,second))

      secs=iso8601_to_epoch(id)

      # The origin location
      lat_origin=sprintf("%lf",substr($0,28,6));
      lon_origin=sprintf("%lf",substr($0,35,7));
      if(lon_origin > 180) {
         lon_origin-=360.0;
      }
      depth_origin=sprintf("%lf",substr($0,43,5));

      # mb=sprintf("%lf",substr($0,49,3)); # Mb

      ###### Load the second line. If we cannot, die
      if (getline <= 0) {
        print("unexpected EOF or error:", ERRNO) > "/dev/stderr"
        exit
      }
      #[1-16]  CMT event name. This string is a unique CMT-event identifier. Older
      #        events have 8-character names, current ones have 14-character names.
      #        See note (1) below for the naming conventions used.
      #[18-61] Data used in the CMT inversion. Three data types may be used:
      #        Long-period body waves (B), Intermediate-period surface waves (S),
      #        and long-period mantle waves (M). For each data type, three values
      #        are given: the number of stations used, the number of components
      #        used, and the shortest period used.
      #[63-68] Type of source inverted for: "CMT: 0" - general moment tensor;
      #        "CMT: 1" - moment tensor with constraint of zero trace (standard);
      #        "CMT: 2" - double-couple source.
      #[70-80] Type and duration of moment-rate function assumed in the inversion.
      #        "TRIHD" indicates a triangular moment-rate function, "BOXHD" indicates
      #        a boxcar moment-rate function. The value given is half the duration
      #        of the moment-rate function. This value is assumed in the inversion,
      #        following a standard scaling relationship (see note (2) below),
      #        and is not derived from the analysis.

      event_code=substr($0,1,17);
      # remove leading and trailing whitespace from the event_code
      gsub(/^[ \t]+/,"",event_code);gsub(/[ \t]+$/,"",event_code)

      ###### Load the third line. If we cannot, die
      if (getline <= 0) {
        print("unexpected EOF or error:", ERRNO) > "/dev/stderr"
        exit
      }
      #[1-58]  Centroid parameters determined in the inversion. Centroid time, given
      #        with respect to the reference time, centroid latitude, centroid
      #        longitude, and centroid depth. The value of each variable is followed
      #        by its estimated standard error. See note (3) below for cases in
      #        which the hypocentral coordinates are held fixed.
      #[60-63] Type of depth. "FREE" indicates that the depth was a result of the
      #        inversion; "FIX " that the depth was fixed and not inverted for;
      #        "BDY " that the depth was fixed based on modeling of broad-band
      #        P waveforms.
      #[65-80] Timestamp. This 16-character string identifies the type of analysis that
      #        led to the given CMT results and, for recent events, the date and
      #        time of the analysis. This is useful to distinguish Quick CMTs ("Q-"),
      #        calculated within hours of an event, from Standard CMTs ("S-"), which
      #        are calculated later. The format for this string should not be
      #        considered fixed.
      centroid_dt=$2
      lat_centroid = $4;
      lon_centroid = $6;
      if(lon_centroid > 180) {
        lon_centroid =- 360;
      }
      depth_centroid=$8;

      ###### Load the fourth line. If we cannot, die
      if (getline <= 0) {
        print("unexpected EOF or error:", ERRNO) > "/dev/stderr"
        exit
      }
      #[1-2]   The exponent for all following moment values. For example, if the
      #        exponent is given as 24, the moment values that follow, expressed in
      #        dyne-cm, should be multiplied by 10**24.
      #[3-80]  The six moment-tensor elements: Mrr, Mtt, Mpp, Mrt, Mrp, Mtp, where r
      #        is up, t is south, and p is east. See Aki and Richards for conversions
      #        to other coordinate systems. The value of each moment-tensor
      #	  element is followed by its estimated standard error. See note (4)
      #	  below for cases in which some elements are constrained in the inversion.

      exponent=$1;
      for(i=1;i<=6;i++){
        m[i]=  $(2+(i-1)*2)
        msd[i]=$(3+(i-1)*2);
      }
      Mrr=m[1]
      Mtt=m[2]
      Mpp=m[3]
      Mrt=m[4]
      Mrp=m[5]
      Mtp=m[6]

      ###### Load the fifth line. If we cannot, die
      if (getline <= 0) {
        print("unexpected EOF or error:", ERRNO) > "/dev/stderr"
        exit
      }
      #[1-3]   Version code. This three-character string is used to track the version
      #        of the program that generates the "ndk" file.
      #[4-48]  Moment tensor expressed in its principal-axis system: eigenvalue,
      #        plunge, and azimuth of the three eigenvectors. The eigenvalue should be
      #        multiplied by 10**(exponent) as given on line four.
      #[50-56] Scalar moment, to be multiplied by 10**(exponent) as given on line four.
      #[58-80] Strike, dip, and rake for first nodal plane of the best-double-couple
      #        mechanism, repeated for the second nodal plane. The angles are defined
      #        as in Aki and Richards.

      # Eigenvectors and principal axes
      for(i=1;i <= 3;i++) { # eigenvectors
         e_val[i]=   $(2+(i-1)*3);
         e_plunge[i]=$(3+(i-1)*3);
         e_strike[i]=$(4+(i-1)*3);
      }
      Tval=e_val[1]
      Tinc=e_plunge[1]
      Taz=e_strike[1]
      Nval=e_val[2]
      Ninc=e_plunge[2]
      Naz=e_strike[2]
      Pval=e_val[3]
      Pinc=e_plunge[3]
      Paz=e_strike[3]

      # Best double couple
      mantissa=$11;# in units of 10**24
      for(i=1;i <= 2;i++){
         strike[i]=$(12+(i-1)*3);# first and second nodal planes
         dip[i]=$(13+(i-1)*3);
         rake[i]=$(14+(i-1)*3);
      }
      strike1=strike[1]
      dip1=dip[1]
      rake1=rake[1]
      strike2=strike[2]
      dip2=dip[2]
      rake2=rake[2]

      author_centroid="GCMT"

    } # FMT = K
    #------------------------------#

    #------------------------------#
    if (FMT=="I") {
      # ISC FOCAL MECHANISMS CSV FORMAT
      # UPDATED FOR NEW FIELD2=
      # 1       , 2   , 3            , 4   , 5   , 6  , 7  , 8    , 9         ,    10          ,
      # EVENT_ID, TYPE, ORIGIN_AUTHOR, DATE, TIME, LAT, LON, DEPTH, ISCENTROID, CENTROID_AUTHOR,
      #
      # 11, 12, 13, 14,  15,  16,  17,  18,  19,  20,     21,  22,   23,     24,  25,   26,
      # EX, MO, MW, EX, MRR, MTT, MPP, MRT, MTP, MPR, STRIKE, DIP, RAKE, STRIKE, DIP, RAKE,
      #
      # 27,    28,   29,    30,    31,   32,    33,    34,   35,    36
      # EX, T_VAL, T_PL, T_AZM, P_VAL, P_PL, P_AZM, N_VAL, N_PL, N_AZM
      #
      # Because the fields are comma delimited and fixed width, the field entries will contain whitespace.
      # We have to chop out the whitespace on read to make the data processable.

      # idcode	event_code	id	epoch	lon_centroid	lat_centroid	depth_centroid	lon_origin	lat_origin	depth_origin
      # author_centroid	author_origin	MW	mantissa	exponent	strike1	dip1	rake1	strike2	dip2	rake2	exponent	Tval
      # Taz	Tinc	Nval	Naz	Ninc	Pval	Paz	Pinc	exponent	Mrr	Mtt	Mpp	Mrt	Mrp	Mtp	centroid_dt


      # Reinitialize the calculation commands as the ISC format varies quite a lot
      # and each line needs its own approach

      calc_ntp_from_moment_tensor=0
      calc_moment_tensor_from_sdr1=0
      calc_principal_axes_from_sdr1=0
      calc_ntp_from_moment_tensor=0
      calc_mantissa_from_exp_and_mt=0
      calc_sdr_from_ntp=0
      calc_sdr2=0
      calc_mant_exp_from_M=0
      calc_M_from_mantissa_exponent=0

      event_code=$1;      gsub(/^[ \t]+/,"",event_code);gsub(/[ \t]+$/,"",event_code)
      author_origin=$3; gsub(/^[ \t]+/,"",author_origin);gsub(/[ \t]+$/,"",author_origin)
      date=$4;          gsub(/^[ \t]+/,"",date);gsub(/[ \t]+$/,"",date)
      time=substr($5,1,8)
      id=sprintf("%sT%s", date, time)
      is_centroid=$9;   gsub(/^[ \t]+/,"",is_centroid);gsub(/[ \t]+$/,"",is_centroid)

      lat_tmp=$6+0;
      lon_tmp=$7+0;
      depth_tmp=$8+0;

      # This entry is for a centroid location
      if (is_centroid == "TRUE") {
        lat_centroid=lat_tmp
        lon_centroid=lon_tmp
        depth_centroid=depth_tmp
        lat_origin="none"
        lon_origin="none"
        depth_origin="none"
        author_centroid=$10; gsub(/^[ \t]+/,"",author_centroid);gsub(/[ \t]+$/,"",author_centroid);
        author_origin="none"
      } else {
        lat_centroid="none"
        lon_centroid="none"
        depth_centroid="none"
        lat_origin=lat_tmp
        lon_origin=lon_tmp
        depth_origin=depth_tmp
        author_origin=$3;     gsub(/^[ \t]+/,"",author_origin);gsub(/[ \t]+$/,"",author_origin)
        author_centroid="none"
      }

      # Read and check SDR values
      strike1=$21+0;
      dip1=$22+0;
      rake1=$23+0;
      strike2=$24+0;
      dip2=$25+0;
      rake2=$26+0;

      # 11, 12, 13, 14,  15,  16,  17,  18,  19,  20,
      # EX, MO, MW, EX, MRR, MTT, MPP, MRT, MTP, MPR,

      # N-m to dynes-cm is a factor of 10^7
      moment_exponent=$14+7
      # Adopt the moment tensor exponent if M0 exponent is not already set
      if (exponent==0 && moment_moment>0)  { exponent=moment_exponent }
      Mrr=$15+0;
      Mtt=$16+0
      Mpp=$17+0
      Mrt=$18+0
      Mtp=$19+0
      Mrp=$20+0

      # 27,    28,   29,    30,    31,   32,    33,    34,   35,    36
      # EX, T_VAL, T_PL, T_AZM, P_VAL, P_PL, P_AZM, N_VAL, N_PL, N_AZM

      # Read and check principal axes values
      # N-m to dynes-cm is a factor of 10^7

      axes_moment=$27+7
      if (exponent==0 && axes_moment>0) { exponent=moment_exponent }

      Tval=$28+0
      Tinc=$29+0
      Taz=$30+0
      Pval=$31+0
      Pinc=$32+0
      Paz=$33+0
      Nval=$34+0
      Ninc=$35+0
      Naz=$36+0

      if (Tval==0 && Pval==0 && Nval==0) {
        Tval=1
        Nval=0
        Pval=-1
      }

      # isnumber does not work to detect 0, 0, 0, 0, ... data which is what we
      # see now that we are converting using +0


      if (((isnumber(strike1) && strike1<=360 && strike1 >= -360)   &&
          (isnumber(dip1) && dip1<=90 && dip1 >= 0)                 &&
          (isnumber(rake1) && rake1<=180 && rake1 >= -180))         &&
          (!(strike1==0 && dip1==0 && rake1==0))                     )
      {
        np1_exists=1
      } else {
        np1_exists=0
      }

      if ((isnumber(strike2) && strike2<=360 && strike2 >= -360)   &&
          (isnumber(dip2) && dip2<=90 && dip2 >= 0)                &&
          (isnumber(rake2) && rake2<=180 && rake2 >= -180)         &&
          (!(strike2==0 && dip2==0 && rake2==0))                    )
      {
        np2_exists=1
      } else {
        np2_exists=0
      }

	    # Read and check moment tensor values. Tricky as ISC switches the typical order of Mrp Mtp
      #

      if ( (isnumber(Mrr) && isnumber(Mtt) && isnumber(Mpp)               &&
            isnumber(Mrt) && isnumber(Mtp) && isnumber(Mrp))              &&
            (!(Mrr==0 && Mtt==0 && Mpp==0 && Mrt==0 && Mtp==0 && Mrp==0))  )
      {
        tensor_exists=1
      } else {
        tensor_exists=0
      }

      if ((isnumber(Taz) && isnumber(Tinc) && isnumber(Paz)                 &&
           isnumber(Pinc) && isnumber(Naz) && isnumber(Ninc))               &&
           (!(Taz==0 && Tinc==0 && Paz==0 && Pinc==0 && Naz==0 && Ninc==0))  )
      {
        ntp_axes_exist=1
      } else {
        ntp_axes_exist=0
      }

      if ( isnumber(Tval) && isnumber(Pval) && isnumber(Nval) )
      {
        ntp_vals_exist=1
      } else {
        ntp_vals_exist=0
      }

      # There are no ISC examples with exponent defined but not mantissa.
      # All EX fields are always the same when they are defined.

      # N-m to dynes-cm is a factor of 10^7

      exponent=$11+7
      mantissa=$12+0
      MW=$13+0

      # ASIES mechanism in the ISC catalog are in the wrong units (dynes-cm) vs ISC
      if (author_centroid == "ASIES" || author_origin == "ASIES") {
        exponent=$11
        calc_M_from_mantissa_exponent=1
      }

      if (exponent<8 || mantissa < 1e-10) {
        skip_this_entry=1
      }


      # Currently the script is failing hard for np1 and np2 existing but not other things.

      # Logic to complete the entries if possible.
      # FLAGS: np1_exists np2_exists ntp_axes_exist ntp_vals_exist tensor_exists get_moment_from_either_tensor_or_ntp
      #
      # FUNCTIONS: calc_ntp_from_moment_tensor  calc_mantissa_from_exp_and_mt calc_sdr_from_ntp calc_sdr2 calc_mant_exp_from_M
      #            calc_M_from_mantissa_exponent calc_moment_tensor_from_sdr1 calc_principal_axes_from_sdr1


      # TODO: Check that the following functions go in the order mt->ntp ntp->sdr
      #


      # If we DO have the moment tensor, calculate the NTP and SDR as needed.
      if (tensor_exists==1) {
        if (ntp_axes_exist==0 || ntp_vals_exist==0) {
          calc_ntp_from_moment_tensor=1
        }
        if (np1_exists==0 || np2_exists==0) {
          calc_sdr_from_ntp=1
        }
      }

      # If we DO NOT have the moment tensor...
      if (tensor_exists==0) {
        if (np1_exists==1 && np2_exists==1) {
          # If we DO have both nodal planes, calculate MT and NTP from the nodal planes
          calc_moment_tensor_from_sdr1=1
          calc_principal_axes_from_sdr1=1
        } else {
            # If we have none of MT, SDR, or NTP, we skip the record
            skip_this_entry=1
        }
      }

      if (mantissa==0) { skip_this_entry=1 }

      # BYKL reports ~462 entries from 199-2015 with ONLY TNP + exponent!

      # skip_this_entry=0

    }
    #------------------------------#

    #------------------------------#
    # GFZ moment tensor, accepts multiple events reports concatenated together
    # Each event needs to be the 44 line standard format

    if (FMT=="Z") {
      # Detect the first line of an event entry
      if ($1=="GFZ" && $2=="Event") {
        # Line 1
        event_code=$3

        # Line 2
        if (getline <= 0) {print("unexpected EOF or error:", ERRNO) > "/dev/stderr"; exit 0}
          split($1,ymd,"/")
          year=ymd[1]+2000
          month=sprintf("%02d", ymd[2]+0)
          day=sprintf("%02d", ymd[3]+0)
          split($2,hmsd,".")
          split(hmsd[1], hms, ":")
          hour=hms[1]+0
          minute=hms[2]+0
          second=hms[3]+0
          id=sprintf("%s-%s-%sT%02d:%02d:%02d", year, month, day, hour, minute, second)

        # Line 3
        if (getline <= 0) {print("unexpected EOF or error:", ERRNO) > "/dev/stderr"; exit 0}

        # Line 4
        if (getline <= 0) {print("unexpected EOF or error:", ERRNO) > "/dev/stderr"; exit 0}
          lon_centroid="none"
          lat_centroid="none"
          author_centroid="none"

          lon_origin=$3
          lat_origin=$2
          depth_origin="none"
          author_origin="GFZ"

        # Line 5
        if (getline <= 0) {print("unexpected EOF or error:", ERRNO) > "/dev/stderr"; exit 0}
          MW=$2

        # Line 6
        if (getline <= 0) {print("unexpected EOF or error:", ERRNO) > "/dev/stderr"; exit 0}

        # Line 7
        if (getline <= 0) {print("unexpected EOF or error:", ERRNO) > "/dev/stderr"; exit 0}

        if ($2 == "CENTROID") {
          # Line 8
          getline
          # Line 9
          getline
          lat_centroid=$2
          lon_centroid=$3
          author_centroid="GFZ"

          getline
          depth_centroid=$2

          # GFZ does not give depth of origin for Centroid solutions so set all to none
          lat_origin="none"
          lon_origin="none"
          depth_origin="none"
          author_origin="none"

        } else {
          # Line 8
          if (getline <= 0) {print("unexpected EOF or error:", ERRNO) > "/dev/stderr"; exit 0}
            depth_origin=$2
        }

        # Lines after this are origin; +2 if it was centroid
        # Line 9
        if (getline <= 0) {print("unexpected EOF or error:", ERRNO) > "/dev/stderr"; exit 0}

        # Line 10
        if (getline <= 0) {print("unexpected EOF or error:", ERRNO) > "/dev/stderr"; exit 0}
           Mrr=sprintf("%g", substr($0,7,5))
           Mtt=sprintf("%g", substr($0,23,5))

        # Line 11
        if (getline <= 0) {print("unexpected EOF or error:", ERRNO) > "/dev/stderr"; exit 0}
           Mpp=sprintf("%g", substr($0,7,5))
           Mrt=sprintf("%g", substr($0,23,5))

        # Line 12
        if (getline <= 0) {print("unexpected EOF or error:", ERRNO) > "/dev/stderr"; exit 0}
           Mrp=sprintf("%g", substr($0,7,5))
           Mtp=sprintf("%g", substr($0,23,5))

        # Line 13
        if (getline <= 0) {print("unexpected EOF or error:", ERRNO) > "/dev/stderr"; exit 0}

        # Line 14
        if (getline <= 0) {print("unexpected EOF or error:", ERRNO) > "/dev/stderr"; exit 0}
           Tval=sprintf("%g", substr($0,10,6))
           Tinc=sprintf("%g", substr($0,22,4))
           Taz=sprintf("%g", substr($0,30,4))

        # Line 15
        if (getline <= 0) {print("unexpected EOF or error:", ERRNO) > "/dev/stderr"; exit 0}
           Nval=sprintf("%g", substr($0,10,6))
           Ninc=sprintf("%g", substr($0,22,4))
           Naz=sprintf("%g", substr($0,30,4))

        # Line 16
        if (getline <= 0) {print("unexpected EOF or error:", ERRNO) > "/dev/stderr"; exit 0}
           Pval=sprintf("%g", substr($0,10,6))
           Pinc=sprintf("%g", substr($0,22,4))
           Paz=sprintf("%g", substr($0,30,4))

        # Line 17
        if (getline <= 0) {print("unexpected EOF or error:", ERRNO) > "/dev/stderr"; exit 0}
        # Line 18
        if (getline <= 0) {print("unexpected EOF or error:", ERRNO) > "/dev/stderr"; exit 0}


        # Line 19
        if (getline <= 0) {print("unexpected EOF or error:", ERRNO) > "/dev/stderr"; exit 0}
           strike1=sprintf("%g", substr($0,13,3))
           dip1=sprintf("%g", substr($0,21,3))
           rake1=sprintf("%g", substr($0,29,4))

        # Line 20
        if (getline <= 0) {print("unexpected EOF or error:", ERRNO) > "/dev/stderr"; exit 0}
            strike2=sprintf("%g", substr($0,13,3))
            dip2=sprintf("%g", substr($0,21,3))
            rake2=sprintf("%g", substr($0,29,4))

        # GFZ files must be truncated at line 20 if they are contatenated

        INID="Z"
        focaltype=mechanism_type_from_TNP(Tinc, Ninc, Pinc)
      } else {
        skip_this_entry=1
      }
    }


    ########## Perform the required calculations to fill in missing info #########

    if (skip_this_entry==0) {

      if (calc_mantissa_from_exp_and_mt==1) {
        # printf "%s-", "calc_mantissa_from_exp_and_mt"
        mantissa = sqrt(Mrr*Mrr+Mtt*Mtt+Mpp*Mpp + 2.*(Mrt*Mrt + Mrp*Mrp + Mtp*Mtp))/sqrt(2)
      }

      # Testing...

      if (calc_ntp_from_moment_tensor==1) {
        # printf "%s-", "calc_ntp_from_moment_tensor"

        Tval=0
        Taz=0
        Tinc=0
        Nval=0
        Naz=0
        Ninc=0
        Pval=0
        Paz=0
        Pinc=0

        moment_tensor_diagonalize_ntp(Mrr, Mtt, Mpp, Mrt, Mrp, Mtp);

        # d_E00, d_E01, d_E02 : Eigenvector components of eigenvalue 0   (largest)
        # d_E10, d_E11, d_E12 : Eigenvector components of eigenvalue 1   (intermediate)
        # d_E20, d_E21, d_E22 : Eigenvector components of eigenvalue 2   (smallest)
        # d_EV0, d_EV1, d_EV2 : Eigenvalues (0=largest, 2=smallest)
        # d_AZ0, d_AZ1, d_AZ2 : Azimuths of eigenvectors
        # d_PL0, d_PL1, d_PL2 : Plunges of eigenvectors

        Tval=d_EV0
        Taz=d_AZ0
        Tinc=d_PL0
        Nval=d_EV1
        Naz=d_AZ1
        Ninc=d_PL1
        Pval=d_EV2
        Paz=d_AZ2
        Pinc=d_PL2

        if (Tval==0 && Taz==0 && Tinc==0 && Nval==0 && Naz==0 && Ninc==0 && Pval==0 && Paz==0) {
          skip_this_entry=1
        }
      }

      if (calc_sdr_from_ntp==1) {
        # printf "%s-", "calc_sdr_from_ntp"

        ntp_to_sdr(Taz, Tinc, Paz, Pinc, SDR)
        strike1=SDR[1]
        dip1=SDR[2]
        rake1=SDR[3]
        strike2=SDR[4]
        dip2=SDR[5]
        rake2=SDR[6]
      }

      if (calc_sdr2==1) {
        # printf "%s-", "calc_sdr2"

        aux_sdr(strike1, dip1, rake1, SDR)
        strike2=SDR[1]
        dip2=SDR[2]
        rake2=SDR[3]
      }

      if (calc_mant_exp_from_M==1) {
        # printf "%s-", "calc_mant_exp_from_M"

        tmpval=sprintf("%e", 10^((MW+10.7)*3/2));
        split(tmpval, tmparr, "e")
        mantissa=tmparr[1]
        split(tmparr[2], newtmparr, "+")
        exponent=newtmparr[2]
      }

      if (calc_M_from_mantissa_exponent==1) {
        # printf "%s-", "calc_M_from_mantissa_exponent"
         if (mantissa<=0) {
            skip_this_entry=1
         } else {
            MW=(2/3)*log(mantissa*(10**exponent))/log(10)-10.7
         }
      }

      if (calc_moment_tensor_from_sdr1==1) {

        sdr_mantissa_exponent_to_full_moment_tensor(strike1, dip1, rake1, mantissa, exponent, MT2)
        Mrr=MT2[1]
        Mtt=MT2[2]
        Mpp=MT2[3]
        Mrt=MT2[4]
        Mrp=MT2[5]
        Mtp=MT2[6]
        # print "---" > "/dev/stderr"
        # print "SDR1=", strike1, dip1, rake1 > "/dev/stderr"
        # print "MT=", Mrr, Mtt, Mpp, Mrt, Mrp, Mtp > "/dev/stderr"

        moment_tensor_diagonalize_ntp(Mrr,Mtt,Mpp,Mrt,Mrp,Mtp)
        # print "NTP=", d_AZ0, d_PL0, d_AZ1, d_PL1, d_AZ2, d_PL2 > "/dev/stderr"
        ntp_to_sdr(d_AZ1, d_PL1, d_AZ2, d_PL2, SDR)
        # print "SDRout=", SDR[1], SDR[2], SDR[3], "|", SDR[4], SDR[5], SDR[6] > "/dev/stderr"
      }

      # Principal axes returned this way have TPN eigenvalues of 1, 0, -1
      if (calc_principal_axes_from_sdr1==1) {
        # printf "%s-", "calc_principal_axes_from_sdr1"

        sdr_to_tnp(strike1, dip1, rake1, TNP)

        Tval=TNP[1]*mantissa
        Taz=TNP[2]
        Tinc=TNP[3]
        Nval=TNP[4]*mantissa
        Naz=TNP[5]
        Ninc=TNP[6]
        Pval=TNP[7]*mantissa
        Paz=TNP[8]
        Pinc=TNP[9]
      }

      if (calc_epoch==1) {
        # printf "%s-", "calc_epoch"
        epoch=iso8601_to_epoch(id)
        # split_num=split(id, epoch_a1, "-")
        # if (split_num!=3) {
        #   epoch=0
        # } else {
        #   year=epoch_a1[1]
        #   month=epoch_a1[2]
        #   split_num=split(epoch_a1[3],epoch_b1,"T")
        #   if (split_num!=2) {
        #     epoch=0
        #   } else {
        #     day=epoch_b1[1]
        #     split_num=split(epoch_b1[2],epoch_c1,":")
        #     if (split_num!=3) {
        #       epoch=0
        #     } else {
        #       hour=epoch_c1[1]
        #       minute=epoch_c1[2]
        #       second=epoch_c1[3]
        #       the_time=sprintf("%i %i %i %i %i %i",year,month,day,hour,minute,int(second+0.5));
        #       epoch=mktime(the_time);
        #     }
        #   }
        # }
      }

      # Always calculate the type of focal mechanism and append to ID code
      focaltype=mechanism_type_from_TNP(Tinc, Ninc, Pinc)
      idcode=sprintf("%s%s", INID, focaltype)

      # Sanitize longitudes
      if (lon_centroid+0 == lon_centroid) {
        while (lon_centroid > 180) {
          lon_centroid = lon_centroid-360
        }
        while (lon_centroid < -180) {
          lon_centroid = lon_centroid+360
        }
      }
      if (lon_origin+0 == lon_origin) {
        while (lon_origin > 180) {
          lon_origin = lon_origin-360
        }
        while (lon_origin < -180) {
          lon_origin = lon_origin+360
        }
      }

      # # Fix rake==0 to rake=0.01 because of strange GMT psmeca behavior?
      # if (rake1==0) {
      #   print "Fixed rake1" > "/dev/stderr"
      #   rake1=0.01
      # }
      # if (rake2==0) {
      #   print "Fixed rake2" > "/dev/stderr"
      #   rake2=0.01
      # }

      if (skip_this_entry==0) {
        # Record checks out as OK, print to stdout
        # print "-"
        print idcode, event_code, id, epoch, lon_centroid, lat_centroid, depth_centroid, lon_origin, lat_origin, depth_origin, author_centroid, author_origin, MW, mantissa, exponent, strike1, dip1, rake1, strike2, dip2, rake2, exponent, Tval, Taz, Tinc, Nval, Naz, Ninc, Pval, Paz, Pinc, exponent, Mrr, Mtt, Mpp, Mrt, Mrp, Mtp, centroid_dt
      } else {
        # Something is wrong. Print to stderr
        # print "Error:"
        print $0 >> "./cmt_tools_rejected.dat"
      }
    } else {
      print $0 >> "./cmt_tools_rejected.dat"
    }# end skip of entries that are determined to be bad during processing
  } # end skip of blank or commented lines
}

# CODE BLOCK AT THE END GOES HERE
# END
# {
#
# }
'
# tectoplot focal mechanism format:
# Tectoplot format: (first 15 fields are psmeca format)
# 1: code             Code G=GCMT I=ISC
# 2: lon_origin              Longitude (°)
# 3: lat_origin              Latitude (°)
# 4: depth_origin            Depth (km)
# 5: strike1          Strike of nodal plane 1
# 6: dip1             Dip of nodal plane 1
# 7: rake1            Rake of nodal plane 1
# 8: strike2       Strike of nodal plane 2
# 9: dip2             Dip of nodal plane 2
# 10: rake2           Rake of nodal plane 2
# 11: mantissa        Mantissa of M0
# 12: exponent        Exponent of M0
# 13: lon_centroid          Longitude alternative (col1=origin, col13=centroid etc) (°)
# 14: lat_centroid          Longitude alternative (col1=origin, col13=centroid etc) (°)
# 15: newid           tectoplot ID code: YYYY-MM-DDTHH:MM:SS
# 16: TAz             Azimuth of T axis
# 17: TInc            Inclination of T axis
# 18: Naz             Azimuth of N axis
# 19: Ninc            Inclination of N axis
# 20: Paz             Azimuth of P axis
# 21: Pinc            Inclination of P axis
# 22: Mrr             Moment tensor
# 23: Mtt             Moment tensor
# 24: Mpp             Moment tensor
# 25: Mrt             Moment tensor
# 26: Mrp             Moment tensor
# 27: Mtp             Moment tensor
# 28: MW
# 29: depth_centroid
# (30: seconds)

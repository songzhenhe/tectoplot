
# bashscripts/time.sh
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

## Time management functions

# Call without arguments will return current UTC time in the format YYYY-MM-DDTHH:MM:SS
# Call with arguments will add the specified number of
# days hours minutes seconds
# from the current time.
# Example: date_shift_utc -7 0 0 0
# Returns: current date minus seven days

function date_shift_utc() {
  TZ=UTC0     # use UTC
  export TZ

  gawk 'BEGIN  {
      exitval = 0

      daycount=0
      hourcount=0
      minutecount=0
      secondcount=0

      if (ARGC > 1) {
          daycount = ARGV[1]
      }
      if (ARGC > 2) {
          hourcount = ARGV[2]
      }
      if (ARGC > 3) {
          minutecount = ARGV[3]
      }
      if (ARGC > 4) {
          secondcount = ARGV[4]
      }
      timestr = strftime("%FT%T")
      date = substr(timestr,1,10);
      split(date,dstring,"-");
      time = substr(timestr,12,8);
      split(time,tstring,":");
      the_time = sprintf("%i %i %i %i %i %i",dstring[1],dstring[2],dstring[3],tstring[1],tstring[2],int(tstring[3]+0.5));
      secs = mktime(the_time);
      newtime = strftime("%FT%T", secs+daycount*24*60*60+hourcount*60*60+minutecount*60+secondcount);
      print newtime
      exit exitval
  }' "$@"
}

# Same as date_shift_utc but takes a date as the first argument and applies shift to that

function date_shift_utc_given() {
  TZ=UTC0     # use UTC
  export TZ

  gawk 'BEGIN  {
      exitval = 0

      daycount=0
      hourcount=0
      minutecount=0
      secondcount=0

      timestr=ARGV[1]
      if (ARGC > 2) {
          daycount = ARGV[2]
      }
      if (ARGC > 3) {
          hourcount = ARGV[3]
      }
      if (ARGC > 4) {
          minutecount = ARGV[4]
      }
      if (ARGC > 5) {
          secondcount = ARGV[5]
      }
      date = substr(timestr,1,10);
      split(date,dstring,"-");
      time = substr(timestr,12,8);
      split(time,tstring,":");
      the_time = sprintf("%i %i %i %i %i %i",dstring[1],dstring[2],dstring[3],tstring[1],tstring[2],int(tstring[3]+0.5));
      secs = mktime(the_time);
      newtime = strftime("%FT%T", secs+daycount*24*60*60+hourcount*60*60+minutecount*60+secondcount);
      print newtime
      exit exitval
  }' "$@"
}

### Epoch

function iso8601_to_epoch() {
  TZ=UTC
   gawk '
   @include "tectoplot_functions.awk"
   BEGIN {
     ENVIRON["TZ"] = "UTC"
     print iso8601_to_epoch("'$1'")
   }'
}

function epoch_to_iso8601() {
  TZ=UTC
   gawk '
   @include "tectoplot_functions.awk"
   BEGIN {
     ENVIRON["TZ"] = "UTC"
     print epoch_to_iso8601("'$1'")
   }'
}
# Report the local time, including daylight savings, for a given UTC date and time zone
# Input date is in ISO8601 format YYYY-MM-DDTHH-MM-SS.sss

function utc_from_localtime() {
  TZ=$1 gawk '{
    split($0,a,"-")
    if (a[1]+0<1970) {
      shiftyear=1
      oldyear=a[1]+0
      datestring=sprintf("2000%s", substr($1,5, length($1)-4))
    } else {
      datestring=$1
    }
    # remove whitespace and then replace -, :, T with spaces
    dt=gensub(/\s+\S+$/,"",1,datestring); gsub(/[-:T]/," ", dt)
    epochsecs=mktime(dt)
    ENVIRON["TZ"] = "UTC"
    outstring=strftime("%FT%T\n", epochsecs)
    if (shiftyear==1) {
      newyear=substr(outstring, 1, 4)+0
      if (newyear==2000) {
        print outstring
      } else if (newyear == 1999) {
        printf("%4d%s", oldyear-1, substr(outstring,5, length(outstring)-4))
      } else if (newyear == 2001) {
        printf("%4d%s", oldyear+1substr(outstring,5, length(outstring)-4))
      }
    }
 }'
}

# Note that mktime uses epoch seconds starting at 1970, so we need to use 2000
# as a substitute year for anything prior to 1970.

function localtime_from_utc() {
  TZ=UTC gawk -v tz=${1} '{
    split($0,a,"-")
    if (a[1]+0<1970) {
      shiftyear=1
      oldyear=a[1]+0
      datestring=sprintf("2000%s", substr($1,5, length($1)-4))
    } else {
      datestring=$1
    }
    # remove whitespace and then replace -, :, T with spaces
    dt=gensub(/\s+\S+$/,"",1,datestring); gsub(/[-:T]/," ", dt)
    epochsecs=mktime(dt)
    ENVIRON["TZ"] = tz
    outstring=strftime("%FT%T", epochsecs)
    if (shiftyear==1) {
      newyear=substr(outstring, 1, 4)+0
      if (newyear==2000) {
        printf("%4d%s\n", oldyear, substr(outstring,5, length(outstring)-4))
      } else if (newyear == 1999) {
        printf("%4d%s\n", oldyear-1, substr(outstring,5, length(outstring)-4))
      } else if (newyear == 2001) {
        printf("%4d%s\n", oldyear+1substr(outstring,5, length(outstring)-4))
      }
    } else {
      print outstring
    }
 }'
}

# This function returns a full ISO8601 datetime (YYYY-MM-DDTHH:MM:SS) from a
# potentially partial datetime (eg. YYYY-MM-DD  or YYYY)

function iso8601_from_partial() {
      gawk '{
        date = substr($1,1,10);
        split(date,dstring,"-");
        time = substr($1,12,8);
        split(time,tstring,":");
        end = substr($1, 20, 5);
        printf("%04d-%02d-%02dT%02d:%02d:%02d%s\n", dstring[1]+0, dstring[2]+0, dstring[3]+0, tstring[1]+0, tstring[2]+0, tstring[3]+0, end)
      }'
}

# Read in a whitespace separated text file and replace the specified datetime column with the day of the week

function day_of_week_UTC() {
  TZ=UTC0     # use UTC
  export TZ

  gawk -v datecol=$2 '
      {
      timestr=$(datecol)
      date = substr(timestr,1,10);
      split(date,dstring,"-");
      time = substr(timestr,12,8);
      split(time,tstring,":");
      the_time = sprintf("%i %i %i %i %i %i",dstring[1],dstring[2],dstring[3],tstring[1],tstring[2],int(tstring[3]+0.5));
      secs = mktime(the_time);
      newtime = strftime("%u", secs);
      $(datecol)=newtime
      print $0
  }' "${1}"
}

function hour_of_day_UTC() {
  TZ=UTC0     # use UTC
  export TZ

  gawk -v datecol=$2 '
      {
      timestr=$(datecol)
      date = substr(timestr,1,10);
      split(date,dstring,"-");
      time = substr(timestr,12,8);
      split(time,tstring,":");
      $(datecol)=int(tstring[1])
      print $0
  }' "${1}"
}
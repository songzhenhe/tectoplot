
TECTOPLOT_MODULES+=("seistime")

# NEW OPTS

function tectoplot_defaults_seistime() {
  m_seistime_width="7i"
  m_seistime_height="2i"
}

function tectoplot_args_seistime()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -seistime)
  tectoplot_get_opts_inline '
des -seistime create a seismicity vs time plot
opn width m_seistime_width word "7i"
  width of plot in inches
opn height m_seistime_height word "2i"
  height of plot in inches
opn minmag m_seistime_minmag word "auto"
  minimum magnitude
opn maxmag m_seistime_maxmag word "auto"
  maximum magnitude
opn mintime m_seistime_mintime word "auto"
  start time, ISO8601 format
opn maxtime m_seistime_maxtime word "auto"
  end time, ISO8601 format
opn dateformat m_seistime_dateformat string "none"
  GMT format string for date, e.g. "o dd"
opn timeformat m_seistime_timeformat string "none"
  GMT format string for time, e.g. "hh:mm"
opn onmap m_seistime_onmapflag flag 0
  place timeline onto map below map frame
opn shiftx m_seistime_shiftx string "0i"
  shift plot horizontally by this amount when using onmap
' "${@}" || return
    doseistimeflag=1
    ;;

  -seistimehist)
  tectoplot_get_opts_inline '
des -seistime_hist create a histogram of seismicity vs time
opn width m_seistimehist_width word "7i"
  width of plot in inches
opn height m_seistimehist_height word "2i"
  height of plot in inches
opn mintime m_seistimehist_mintime word "auto"
  start time, ISO8601 format
opn maxtime m_seistimehist_maxtime word "auto"
  end time, ISO8601 format
opn onmap m_seistimehist_onmapflag flag 0
  place histogram onto map below map frame
opn timecode m_seistimehist_timecode word "none"
  timecode for bin width: e.g. 1y or 1d (y=year, o=month, d=day, h=hour, m=minute, s=second)
opn type m_seistimehist_counttype float 0
  count type: 0=count 2=log(1+count) 4=log10(1+count)
opn shiftx m_seistimehist_shiftx string "0i"
  shift plot horizontally by this amount when using onmap
' "${@}" || return
    doseistimehistflag=1
    ;;
  esac
}


# The following functions are not necessary for this module

# function tectoplot_calculate_seistime()  {
#   echo "Doing seistime calculations"
# }
#
# function tectoplot_plot_seistime() {
#   echo "Doing seistime plot"
# }
#
# function tectoplot_legend_seistime() {
#   echo "Doing seistime legend"
# }

# Return GMT -B strings appropriate for range between two dates
# Makes no assumptions about the width of the plot however

function bstring_from_two_dates() {
  local st_date=$1
  local en_date=$2

  local epoch1=$(iso8601_to_epoch $st_date)
  local epoch2=$(iso8601_to_epoch $en_date)

  local epoch_diff=$(echo "${epoch2} - ${epoch1}" | bc -l)

  # echo "st_date ${st_date} en_date ${en_date} epoch2 ${epoch2} epoch1 ${epoch1} epoch_diff is ${epoch_diff}"

  gawk -v epoch_diff=${epoch_diff} '
  BEGIN {

    # print "label" if we need to indicate the time range using the label
    # print "nolabel" otherwise
    if (epoch_diff < 60) {
      # less than one minute - annotate in seconds
      # -- FORMAT_CLOCK_MAP="H:M:S"
      # -Bp         primary
      #    a        major tick
      #     10S     10 seconds (FORMAT_CLOCK_MAP)
      #       f     minor tick
      #        1s   1 second
      #
      print "label -Bpxa10Sf1s"
    } else if (epoch_diff < 60*60) {
      # less than one hour - annotate in minutes  
      # -Bp         primary
      #    a        major tick
      #     5M      5 minutes (FORMAT_CLOCK_MAP)
      #       f     minor tick
      #        1m   1 minute
      print "label -Bpxa5Mf1m"
    } else if (epoch_diff < 60*60*24) {
      # less than one day - annotate in hours
            print "day"
      # -Bp         primary
      #    a        major tick
      #     1H      1 hour (FORMAT_CLOCK_MAP)
      #       f     minor tick
      #        10m  1 minutes  (0-24)
      print "label -Bpxa1Hf10m"
    } else if (epoch_diff < 60*60*24*7) {
      # less than one week - annotate in days
      # -Bp         primary
      #    a        major tick
      #     6H      6 hours (FORMAT_CLOCK_MAP)
      #       f     minor tick
      #        1h   1 hour  (0-24)
      #
      # -Bs         secondary
      #    a        major tick
      #     1K      name of weekday

      print "nolabel -Bpa6hf1h -Bsa1D"
    } else if (epoch_diff < 60*60*24*31) {
      # less than one month - annotate in weeks+days
      print "nolabel -Bpa3df12h -Bsa1O"
    } else if (epoch_diff < 60*60*24*31*6) {
      # less than half a year - annotate in months
      print "nolabel -Bpa7Rf1R -Bsa1O --FORMAT_DATE_MAP=yyyy-mm"
    } else if (epoch_diff < 60*60*24*31*12) {
      # less than a full year - annotate in months
      print "nolabel -Bpa14R -Bsa1O --FORMAT_DATE_MAP=yyyy-mm"
    } else if (epoch_diff < 60*60*24*365*10) {
      # less than ten years - annotate in years
      print "nolabel -Bpa1Y --FORMAT_DATE_MAP=yyyy"
    } else {
      print "nolabel -Bpaf --FORMAT_DATE_MAP=yyyy"
    } 
  }'
  
}


function unitstring_from_two_dates_and_bincount() {
  local st_date=$1
  local en_date=$2
  local bincount=$3

  local epoch1=$(iso8601_to_epoch $st_date)
  local epoch2=$(iso8601_to_epoch $en_date)

  echo epoch1 ${epoch1} > "/dev/stderr"
  echo epoch2 ${epoch2} > "/dev/stderr"

  local epoch_diff=$(echo "${epoch2} - ${epoch1}" | bc -l)

  echo epochdiff ${epoch_diff} > "/dev/stderr"

  # echo "st_date ${st_date} en_date ${en_date} epoch2 ${epoch2} epoch1 ${epoch1} epoch_diff is ${epoch_diff}"

  gawk -v epoch_diff=${epoch_diff} -v bincount=${bincount} '
  BEGIN {
    count=1
    secv[count]=0;              intv[count++]="1s"
    secv[count]=1;              intv[count++]="1s"
    secv[count]=10;             intv[count++]="10s"
    secv[count]=60;             intv[count++]="1m"
    secv[count]=60*60;          intv[count++]="1h"
    secv[count]=60*60*24;       intv[count++]="1d"
    secv[count]=60*60*24*14;    intv[count++]="14d"
    secv[count]=60*60*24*30;    intv[count++]="1o"
    secv[count]=60*60*24*30*6;  intv[count++]="6o"
    secv[count]=60*60*24*30*12;   intv[count++]="1y"
    secv[count]=60*60*24*30*12*10;   intv[count++]="10y"
    secv[count]=60*60*24*30*12*20;   intv[count++]="20y"
    secv[count]=60*60*24*30*12*50;   intv[count++]="50y"
    secv[count]=60*60*24*30*12*100;   intv[count++]="100y"

    for (thisc=2; thisc<count; thisc++) {
      if ( epoch_diff/bincount < secv[thisc]) {
        print intv[thisc-1]
        break
      } 
      if (thisc==count-1) {
        print intv[thisc]
      }
    }
  }'
}

function tectoplot_post_seistime() {

  echo 1 is $1
  case $1 in

  seistime)

  if [[ -s ${F_SEIS}eqs.txt && $doseistimeflag -eq 1 ]]; then
    date_and_mag_range=($(gawk < ${F_SEIS}eqs.txt '
      BEGIN {
        getline
        maxdate=$5
        mindate=$5
        maxmag=$4
        minmag=$4
      }
      {
        maxdate=($5>maxdate)?$5:maxdate
        mindate=($5<mindate)?$5:mindate
        if ($4>0) {
          maxmag=($4>maxmag)?$4:maxmag
          minmag=($4<minmag)?$4:minmag
        }
      }
      END {
        print mindate, maxdate, minmag-0.1, maxmag+0.1
      }'))

      # Default source file
      SEISTIMEFILE=${F_SEIS}eqs.txt

      if [[ $m_seistime_minmag == "auto" ]]; then
        m_seistime_minmag=${date_and_mag_range[2]}
      fi
      if [[ $m_seistime_maxmag == "auto" ]]; then
        m_seistime_maxmag=${date_and_mag_range[3]}
      fi

      if [[ $m_seistime_mintime == "auto" ]]; then
        m_seistime_mintime=$(echo ${date_and_mag_range[0]} | iso8601_from_partial )
      else
        tmpval=$(echo  ${m_seistime_mintime} | iso8601_from_partial)
        m_seistime_mintime=${tmpval}
      fi

      if [[ $m_seistime_maxtime == "auto" ]]; then
        m_seistime_maxtime=$(echo ${date_and_mag_range[1]} | iso8601_from_partial)
      else
        tmpval=$(echo ${m_seistime_maxtime} | iso8601_from_partial)
        m_seistime_maxtime=${tmpval}
      fi
      if [[ $m_seistime_maxtime == "now" ]]; then
        m_seistime_maxtime=$(date -u +"%FT%T")
      fi

      local bopts=($(bstring_from_two_dates ${m_seistime_mintime} ${m_seistime_maxtime}))

      cp ${F_SEIS}eqs.txt ${F_SEIS}seistimeline.txt

      if [[ -s ${F_CMT}usgs_foc.cat ]]; then
        gawk < ${F_CMT}usgs_foc.cat '{print $5, $6, $7, $13, $3}' >> ${F_SEIS}seistimeline.txt
        # cat ${F_CMT}usgs_foc.cat | gmt_psxy zcol 7 ycol 13 xcol 3 scale ${SEISSCALE} stretch ${SEISSTRETCH} refmag ${SEISSTRETCH_REFMAG} cpt ${SEIS_CPT} trans ${SEISTRANS} stroke ${EQLINEWIDTH},${EQLINECOLOR} -R${m_seistime_mintime}/${m_seistime_maxtime}/${m_seistime_minmag}/${m_seistime_maxmag} -JX${m_seistime_width}T/${m_seistime_height} -K -O ${VERBOSE} >> m_seistime.ps
      fi
      if [[ -s ${F_CMT}cmt_global_aoi.dat ]]; then
        gawk < ${F_CMT}cmt_global_aoi.dat -v cent=${CENTROIDFLAG} '
          {
            if (cent==1) {
              lon=$5
              lat=$6
              depth=$7
            } else {
              lon=$8
              lat=$9
              depth=$10
            }
            print lon, lat, depth, $13, $3, $2, $4
          }' >> ${F_SEIS}seistimeline.txt
        # cat ${F_CMT}usgs_foc.cat | gmt_psxy zcol 7 ycol 13 xcol 3 scale ${SEISSCALE} stretch ${SEISSTRETCH} refmag ${SEISSTRETCH_REFMAG} cpt ${SEIS_CPT} trans ${SEISTRANS} stroke ${EQLINEWIDTH},${EQLINECOLOR} -R${m_seistime_mintime}/${m_seistime_maxtime}/${m_seistime_minmag}/${m_seistime_maxmag} -JX${m_seistime_width}T/${m_seistime_height} -K -O ${VERBOSE} >> m_seistime.ps
      fi

      cat ${F_SEIS}seistimeline.txt | gmt_psxy zcol ${SEIS_ZCOL} ycol 4 xcol 5 scale ${SEISSCALE} stretch ${SEISSTRETCH} refmag ${SEISSTRETCH_REFMAG} cpt ${SEIS_CPT} trans ${SEISTRANS} stroke ${EQLINEWIDTH},${EQLINECOLOR} -R${m_seistime_mintime}/${m_seistime_maxtime}/${m_seistime_minmag}/${m_seistime_maxmag} -JX${m_seistime_width}T/${m_seistime_height} -B+gwhite -K ${VERBOSE} > m_seistime.ps

      m_seistime_datecmd=""
      m_seistime_timecmd=""
      if [[ ${m_seistime_dateformat} != "none" ]]; then
        m_seistime_datecmd="--FORMAT_DATE_MAP=${m_seistime_dateformat}"
      fi
      if [[ ${m_seistime_timeformat} != "none" ]]; then
        m_seistime_timecmd="--FORMAT_CLOCK_MAP=${m_seistime_timeformat}"
      fi

      labelflag=1

      # echo read bopts ${bopts[@]}

      if [[ ${bopts[0]} == "label" ]]; then
        gmt psbasemap ${bopts[1]}+l"${m_seistime_mintime}   to   ${m_seistime_maxtime}" ${bopts[2]} ${bopts[3]} -BS -R${m_seistime_mintime}/${m_seistime_maxtime}/${m_seistime_minmag}/${m_seistime_maxmag} -JX${m_seistime_width}T/${m_seistime_height} -Byaf+lMagnitude --MAP_FRAME_PEN=1p,black --FONT_LABEL=10p,Helvetica,black --FONT_ANNOT_PRIMARY=8p,Helvetica,black --ANNOT_OFFSET_PRIMARY=4p --MAP_TICK_LENGTH_PRIMARY=4p --LABEL_OFFSET=10p  --GMT_HISTORY=false --FONT_ANNOT_SECONDARY=8p,Helvetica,black -O -K ${VERBOSE} >>  m_seistime.ps

        gmt psbasemap -BtEbW -Byaf+l"Magnitude" -R${m_seistime_mintime}/${m_seistime_maxtime}/${m_seistime_minmag}/${m_seistime_maxmag} -JX${m_seistime_width}T/${m_seistime_height} -Byaf+lMagnitude --MAP_FRAME_PEN=1p,black --FONT_LABEL=10p,Helvetica,black --FONT_ANNOT_PRIMARY=8p,Helvetica,black --ANNOT_OFFSET_PRIMARY=4p --MAP_TICK_LENGTH_PRIMARY=4p --LABEL_OFFSET=10p  --GMT_HISTORY=false --FONT_ANNOT_SECONDARY=8p,Helvetica,black -O ${VERBOSE} >>  m_seistime.ps
      else
        gmt psbasemap ${bopts[1]} ${bopts[2]} ${bopts[3]} -BS -R${m_seistime_mintime}/${m_seistime_maxtime}/${m_seistime_minmag}/${m_seistime_maxmag} -JX${m_seistime_width}T/${m_seistime_height} -Byaf+lMagnitude --MAP_FRAME_PEN=1p,black --FONT_LABEL=10p,Helvetica,black --FONT_ANNOT_PRIMARY=8p,Helvetica,black --ANNOT_OFFSET_PRIMARY=4p --MAP_TICK_LENGTH_PRIMARY=4p --LABEL_OFFSET=10p  --GMT_HISTORY=false --FONT_ANNOT_SECONDARY=8p,Helvetica,black -O -K ${VERBOSE} >>  m_seistime.ps

        gmt psbasemap -BtrbW -Byaf+l"Magnitude" -R${m_seistime_mintime}/${m_seistime_maxtime}/${m_seistime_minmag}/${m_seistime_maxmag} -JX${m_seistime_width}T/${m_seistime_height} -Byaf+lMagnitude --MAP_FRAME_PEN=1p,black --FONT_LABEL=10p,Helvetica,black --FONT_ANNOT_PRIMARY=8p,Helvetica,black --ANNOT_OFFSET_PRIMARY=4p --MAP_TICK_LENGTH_PRIMARY=4p --LABEL_OFFSET=10p  --GMT_HISTORY=false --FONT_ANNOT_SECONDARY=8p,Helvetica,black -O ${VERBOSE} >>  m_seistime.ps
      fi
# --FORMAT_DATE_MAP="o dd" --FORMAT_CLOCK_MAP="hh:mm"
      # gmt psbasemap ${bopts[1]}'${timelabel}' ${bopts[2]} -BtESW -Byaf+l"Magnitude" -R${m_seistime_mintime}/${m_seistime_maxtime}/${m_seistime_minmag}/${m_seistime_maxmag} -JX${m_seistime_width}T/${m_seistime_height} -Byaf+lMagnitude --MAP_FRAME_PEN=1p,black --FONT_LABEL=10p,Helvetica,black --FONT_ANNOT_PRIMARY=8p,Helvetica,black --ANNOT_OFFSET_PRIMARY=4p --MAP_TICK_LENGTH_PRIMARY=4p --LABEL_OFFSET=10p  --GMT_HISTORY=false --FONT_ANNOT_SECONDARY=6p,Helvetica,black -O ${VERBOSE} >>  m_seistime.ps

      # gmt psbasemap -R -J -Bxaf+sD -BtrSW -Bxaf+l"Date" -By+l"Magnitude" -O --MAP_FRAME_PEN=thinner,black --FONT_LABEL=12p,Helvetica,black --FONT_ANNOT_PRIMARY=10p,Helvetica,black --ANNOT_OFFSET_PRIMARY=4p --LABEL_OFFSET=12p --GMT_HISTORY=false >>  m_seistime.ps

       gmt psconvert m_seistime.ps -Tf -A+m0.5i

      if [[ ${m_seistime_onmapflag} -eq 1 ]]; then

        # Expects the variable PS_HEIGHT_IN to contain the current vertical offset below the map
        # origin to allow concatenation of figure parts below the map.

        # echo "Map height is currently ${PS_HEIGHT_IN}"
        SEISTIME_PS_DIM=($(gmt psconvert m_seistime.ps -Fseistime -Te -A+m0i -V 2> >(grep Width) | gawk  -F'[ []' -v mapwidth=${MAP_PS_WIDTH_NOLABELS_IN} -v prevheight=$PS_HEIGHT_IN '{print $10/2.54, $17/2.54+0.5+prevheight, $10/2.54-(mapwidth+0) }'))

        # echo "It is" ${SEISTIME_PS_DIM[@]}
        gmt psimage -Dx"-${SEISTIME_PS_DIM[2]}i/-${SEISTIME_PS_DIM[1]}i"+w${SEISTIME_PS_DIM[0]}i seistime.eps -Xa${m_seistime_shiftx} $RJOK ${VERBOSE} --GMT_HISTORY=false >> map.ps

        # Set PS_HEIGHT_IN so another module can concatenate a panel
        PS_HEIGHT_IN=${SEISTIME_PS_DIM[1]}
      fi
  fi

  if [[ -s ${F_SEIS}eqs.txt && $doseistimehistflag -eq 1 ]]; then
    date_and_mag_range=($(gawk < ${F_SEIS}eqs.txt '
      BEGIN {
        getline
        maxdate=$5
        mindate=$5
        maxmag=$4
        minmag=$4
      }
      {
        maxdate=($5>maxdate)?$5:maxdate
        mindate=($5<mindate)?$5:mindate
        if ($4>0) {
          maxmag=($4>maxmag)?$4:maxmag
          minmag=($4<minmag)?$4:minmag
        }
      }
      END {
        print mindate, maxdate, minmag-0.1, maxmag+0.1
      }'))

      # Default source file

      if [[ $m_seistimehist_mintime == "auto" ]]; then
        m_seistimehist_mintime=$(echo ${date_and_mag_range[0]} | iso8601_from_partial)
      else
        tmpval=$(echo ${m_seistimehist_mintime} | iso8601_from_partial)
        m_seistimehist_mintime=${tmpval}
      fi

      if [[ $m_seistimehist_maxtime == "auto" ]]; then
        m_seistimehist_maxtime=$(echo ${date_and_mag_range[1]} | iso8601_from_partial)
      else
        tmpval=$(echo  ${m_seistimehist_maxtime} | iso8601_from_partial)
        m_seistimehist_maxtime=${tmpval}
      fi
      if [[ $m_seistimehist_maxtime == "now" ]]; then
        m_seistimehist_maxtime=$(date -u +"%FT%T")
      fi

      local bopts=($(bstring_from_two_dates ${m_seistimehist_mintime} ${m_seistimehist_maxtime}))

      gawk < ${F_SEIS}eqs.txt '
      {
        # timestring, magnitude
        print $5, $4
      }' > ${F_SEIS}seistimehist.txt

      # if [[ -s ${F_CMT}usgs_foc.cat ]]; then
      #   gawk < ${F_CMT}usgs_foc.cat '{print $5, $6, $7, $13, $3}' >> ${F_SEIS}seistimehist.txt
      # fi
      # if [[ -s ${F_CMT}cmt.dat ]]; then
      #   gawk < ${F_CMT}cmt.dat '
      #     @include "tectoplot_functions.awk"
      #     {
            
      #     }' >> ${F_SEIS}seistimehist.txt
      # fi

      # Histogram

      # M0 = 1/sqrt(2)  sqrt( sum over all i,j { Mij^2 }) 

      seistimehist_colors=(green yellow orange red black)
      seistimehist_mags=(2 3 4 5 6)

      if [[ ${m_seistimehist_timecode} == "none" ]]; then
        timeunit=$(unitstring_from_two_dates_and_bincount ${m_seistimehist_mintime} ${m_seistimehist_maxtime} 50)
      else
        timeunit=${m_seistimehist_timecode}
      fi

      case ${m_seistimehist_counttype} in
        0) m_seistimehist_ylabel="Earthquake count" ;;
        1) m_seistimehist_ylabel="Earthquake freq%" ;;
        2) m_seistimehist_ylabel="Earthquake count (log)" ;;
        3) m_seistimehist_ylabel="Earthquake freq% (log)" ;;
        4) m_seistimehist_ylabel="Earthquake count (log10)" ;;
        5) m_seistimehist_ylabel="Earthquake freq% (log10)" ;;
      esac

      maxcount=($(gmt pshistogram ${F_SEIS}seistimehist.txt -Z${m_seistimehist_counttype} -T${m_seistimehist_mintime}/${m_seistimehist_maxtime}/${timeunit}  -i0,1 -Vn -I))

      maxc=$(echo "${maxcount[3]} * 1.1" | bc -l)

      gmt pshistogram ${F_SEIS}seistimehist.txt -Z${m_seistimehist_counttype} -R${m_seistimehist_mintime}/${m_seistimehist_maxtime}/0/${maxc} -T${m_seistimehist_mintime}/${m_seistimehist_maxtime}/${timeunit}  -i0,1 -Vn -Gblue -W0.5p,black -JX7i/2i -K > m_seistimehist.ps
      
      for i in $(seq 0 4); do
        gawk < ${F_SEIS}seistimehist.txt -v cut=${seistimehist_mags[$i]} '
          ($2 > cut) {
            print
          }' > seistimehist_tmpcut.txt
        [[ -s seistimehist_tmpcut.txt ]] && gmt pshistogram seistimehist_tmpcut.txt -R${m_seistimehist_mintime}/${m_seistimehist_maxtime}/0/${maxc} -JX7i/2i  -Z${m_seistimehist_counttype} -T${m_seistimehist_mintime}/${m_seistimehist_maxtime}/${timeunit}  -i0,1 -Vn -G${seistimehist_colors[$i]} -W0.5p,black -O -K >> m_seistimehist.ps
      done


      if [[ ${bopts[0]} == "label" ]]; then
        gmt psbasemap ${bopts[1]}+l"${m_seistime_mintime}   to   ${m_seistime_maxtime}" ${bopts[2]} ${bopts[3]} -BS -R${m_seistimehist_mintime}/${m_seistimehist_maxtime}/0/${maxc} -JX7i/2i -Byaf+l"${m_seistimehist_ylabel}" --MAP_FRAME_PEN=1p,black --FONT_LABEL=10p,Helvetica,black --FONT_ANNOT_PRIMARY=8p,Helvetica,black --ANNOT_OFFSET_PRIMARY=4p --MAP_TICK_LENGTH_PRIMARY=4p --LABEL_OFFSET=10p  --GMT_HISTORY=false --FONT_ANNOT_SECONDARY=8p,Helvetica,black -O -K ${VERBOSE} >>  m_seistimehist.ps
        gmt psbasemap -BtEbW -Byaf+l"Magnitude" -R${m_seistimehist_mintime}/${m_seistimehist_maxtime}/0/${maxc} -JX7i/2i -Byaf+l"${m_seistimehist_ylabel}" --MAP_FRAME_PEN=1p,black --FONT_LABEL=10p,Helvetica,black --FONT_ANNOT_PRIMARY=8p,Helvetica,black --ANNOT_OFFSET_PRIMARY=4p --MAP_TICK_LENGTH_PRIMARY=4p --LABEL_OFFSET=10p  --GMT_HISTORY=false --FONT_ANNOT_SECONDARY=8p,Helvetica,black -O -K ${VERBOSE} >>  m_seistimehist.ps
      else
        gmt psbasemap ${bopts[1]} ${bopts[2]} ${bopts[3]} -BS -R${m_seistimehist_mintime}/${m_seistimehist_maxtime}/0/${maxc} -JX7i/2i -Byaf+l"${m_seistimehist_ylabel}" --MAP_FRAME_PEN=1p,black --FONT_LABEL=10p,Helvetica,black --FONT_ANNOT_PRIMARY=8p,Helvetica,black --ANNOT_OFFSET_PRIMARY=4p --MAP_TICK_LENGTH_PRIMARY=4p --LABEL_OFFSET=10p  --GMT_HISTORY=false --FONT_ANNOT_SECONDARY=8p,Helvetica,black -O -K ${VERBOSE} >>  m_seistimehist.ps

        gmt psbasemap -BtrbW -Byaf+l"${m_seistimehist_ylabel}" -R${m_seistimehist_mintime}/${m_seistimehist_maxtime}/0/${maxc} -JX7i/2i -Byaf+l"${m_seistimehist_ylabel}" --MAP_FRAME_PEN=1p,black --FONT_LABEL=10p,Helvetica,black --FONT_ANNOT_PRIMARY=8p,Helvetica,black --ANNOT_OFFSET_PRIMARY=4p --MAP_TICK_LENGTH_PRIMARY=4p --LABEL_OFFSET=10p  --GMT_HISTORY=false --FONT_ANNOT_SECONDARY=8p,Helvetica,black -O -K ${VERBOSE} >>  m_seistimehist.ps
      fi

      # worked before
      # gmt psbasemap -R -J -Bxaf -Byaf+l"${m_seistimehist_ylabel}" -BW -K -O --MAP_FRAME_PEN=1p,black --FONT_LABEL=10p,Helvetica,black --FONT_ANNOT_PRIMARY=8p,Helvetica,black --ANNOT_OFFSET_PRIMARY=4p --MAP_TICK_LENGTH_PRIMARY=4p --LABEL_OFFSET=10p  --FONT_ANNOT_SECONDARY=8p,Helvetica,black >> m_seistimehist.ps
      # gmt psbasemap -R -J -Bxaf -BrlSt -O -K --MAP_FRAME_PEN=1p,black --FONT_LABEL=10p,Helvetica,black --FONT_ANNOT_PRIMARY=8p,Helvetica,black --ANNOT_OFFSET_PRIMARY=4p --MAP_TICK_LENGTH_PRIMARY=4p --LABEL_OFFSET=10p  --FONT_ANNOT_SECONDARY=8p,Helvetica,black >> m_seistimehist.ps
      




      # echo gmt pshistogram ${F_SEIS}seistimehist.txt -Z${m_seistimehist_counttype} -T${m_seistimehist_mintime}/${m_seistimehist_maxtime}/50+n -F -i0,1 -Vn -Gblack -IO 

      # CUMHISTRANGE=($(gmt pshistogram ${F_SEIS}seistimehist.txt -Z1+w -Q -T1d -F -i0,1 -Vn -I))

      # echo histrange ${HISTRANGE[@]}
      # echo cumhistrange ${CUMHISTRANGE[@]}

      # HISTYDIFF=$(echo "${HISTRANGE[3]} - ${HISTRANGE[2]}" | bc -l)
      # HISTRANGE[3]=$(echo "${HISTRANGE[3]} + ${HISTYDIFF}/3" | bc -l)

      # Adding -N to the following command will draw the equivalent normal distribution

      # gmt pshistogram ${F_SEIS}seistimehist.txt -T1d -R${m_seistimehist_mintime}/${m_seistimehist_maxtime}/${HISTRANGE[2]}/${HISTRANGE[3]} -JX7i/2i -Z1+w -BtSEW -Bxaf+l"Time" --FONT_LABEL=10p,black -Byaf+l"Relative frequency" -F -i0,1 -Vn -A -K > m_seistimehist.ps
      # gmt pshistogram ${F_SEIS}seistimehist.txt -Q -T1d -JX${m_gridhist_width}/${m_gridhist_height} -R${HISTRANGE[0]}/${HISTRANGE[1]}/0/100 -Z1+w -BNE -Bxaf -Byaf+l"Cumulative frequency" --FONT_LABEL=10p,red -W0.05p,red,- -i2,3 -Vn -A -S -O >> module_gridhist/gridhist.ps
      # -R${m_seistime_mintime}/${m_seistime_maxtime}/${m_seistime_minmag}/${m_seistime_maxmag} -JX${m_seistime_width}T/${m_seistime_height} -B+gwhite -K ${VERBOSE} > m_seistimehist.ps

      # Make the legend
      timetext=$(echo ${timeunit} | gawk '{
         num=$1+0
         code=substr($1, length(num)+1, length($1)-length(num)) 

         if (num==1) {
            plural=""
         } else {
            plural="s"
         }
         if (code=="y" || code=="Y") {
            code="year"
         } else if (code=="O" || code=="o") {
            code="month"
         } else if (code=="U" || code=="u") {
            code="week"
         } else if (code=="K" || code=="k" || code=="d" || code=="R") {
            code="day"
         } else if (code=="H" || code=="h") {
            code="hour"
         } else if (code=="M" || code=="m") {
            code="minute"
         } else if (code=="S" || code=="s") {
            code="second"
         } else {
            num=$1
            code=""
            plural=""
         }
         print num, code plural
      }')


      echo "N 7" > m_seistimehist_legend.txt
      echo "S 0.1i s 0.15i black 0.25p 0.3i M > 6" >> m_seistimehist_legend.txt
      echo "S 0.1i s 0.15i red 0.25p 0.3i M 5-6" >> m_seistimehist_legend.txt
      echo "S 0.1i s 0.15i orange 0.25p 0.3i M 4-5" >> m_seistimehist_legend.txt
      echo "S 0.1i s 0.15i yellow 0.25p 0.3i M 3-4" >> m_seistimehist_legend.txt
      echo "S 0.1i s 0.15i green 0.25p 0.3i M 2-3" >> m_seistimehist_legend.txt
      echo "S 0.1i s 0.15i blue 0.25p 0.3i 2 > M" >> m_seistimehist_legend.txt
      echo "S 0i s 0.i white 0p,white 0.i Bin: ${timetext}" >> m_seistimehist_legend.txt
      # Close the PS file


      gmt pslegend m_seistimehist_legend.txt -Dn0/1+w7i -R -J -O -K >> m_seistimehist.ps

      gmt psxy -T -R -O >> m_seistimehist.ps

      gmt psconvert m_seistimehist.ps -Tf -A+m0.5i

      if [[ ${m_seistimehist_onmapflag} -eq 1 ]]; then

        # Expects the variable PS_HEIGHT_IN to contain the current vertical offset below the map
        # origin to allow concatenation of figure parts below the map.

        # echo "Map height is currently ${PS_HEIGHT_IN}"
        SEISTIME_PS_DIM=($(gmt psconvert m_seistimehist.ps -Fm_seistimehist -Te -A+m0i -V 2> >(grep Width) | gawk  -F'[ []' -v mapwidth=${MAP_PS_WIDTH_NOLABELS_IN} -v prevheight=$PS_HEIGHT_IN '{print $10/2.54, $17/2.54+0.5+prevheight, $10/2.54-(mapwidth+0) }'))

        # echo "It is" ${SEISTIME_PS_DIM[@]}
        gmt psimage -Dx"-${SEISTIME_PS_DIM[2]}i/-${SEISTIME_PS_DIM[1]}i"+w${SEISTIME_PS_DIM[0]}i m_seistimehist.eps -Xa${m_seistimehist_shiftx} $RJOK ${VERBOSE} --GMT_HISTORY=false >> map.ps

        # Set PS_HEIGHT_IN so another module can concatenate a panel
        PS_HEIGHT_IN=${SEISTIME_PS_DIM[1]}
      fi
  fi
  ;;
  esac

}


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


function tectoplot_post_seistime() {
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
        m_seistime_mintime=${date_and_mag_range[0]}
      fi
      if [[ $m_seistime_maxtime == "auto" ]]; then
        m_seistime_maxtime=${date_and_mag_range[1]}
      elif [[ $m_seistime_maxtime == "now" ]]; then
        m_seistime_maxtime=$(date -u +%s)
      fi

      local bopts=($(bstring_from_two_dates ${m_seistime_mintime} ${m_seistime_maxtime}))

      cp ${F_SEIS}eqs.txt ${F_SEIS}seistimeline.txt

      if [[ -s ${F_CMT}usgs_foc.cat ]]; then
        gawk < ${F_CMT}usgs_foc.cat '{print $5, $6, $7, $13, $3}' >> ${F_SEIS}seistimeline.txt
        # cat ${F_CMT}usgs_foc.cat | gmt_psxy zcol 7 ycol 13 xcol 3 scale ${SEISSCALE} stretch ${SEISSTRETCH} refmag ${SEISSTRETCH_REFMAG} cpt ${SEIS_CPT} trans ${SEISTRANS} stroke ${EQLINEWIDTH},${EQLINECOLOR} -R${m_seistime_mintime}/${m_seistime_maxtime}/${m_seistime_minmag}/${m_seistime_maxmag} -JX${m_seistime_width}T/${m_seistime_height} -K -O ${VERBOSE} >> seistime.ps
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
        # cat ${F_CMT}usgs_foc.cat | gmt_psxy zcol 7 ycol 13 xcol 3 scale ${SEISSCALE} stretch ${SEISSTRETCH} refmag ${SEISSTRETCH_REFMAG} cpt ${SEIS_CPT} trans ${SEISTRANS} stroke ${EQLINEWIDTH},${EQLINECOLOR} -R${m_seistime_mintime}/${m_seistime_maxtime}/${m_seistime_minmag}/${m_seistime_maxmag} -JX${m_seistime_width}T/${m_seistime_height} -K -O ${VERBOSE} >> seistime.ps
      fi

      cat ${F_SEIS}seistimeline.txt | gmt_psxy zcol ${SEIS_ZCOL} ycol 4 xcol 5 scale ${SEISSCALE} stretch ${SEISSTRETCH} refmag ${SEISSTRETCH_REFMAG} cpt ${SEIS_CPT} trans ${SEISTRANS} stroke ${EQLINEWIDTH},${EQLINECOLOR} -R${m_seistime_mintime}/${m_seistime_maxtime}/${m_seistime_minmag}/${m_seistime_maxmag} -JX${m_seistime_width}T/${m_seistime_height} -B+gwhite -K ${VERBOSE} > seistime.ps

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
        gmt psbasemap ${bopts[1]}+l"${m_seistime_mintime}   to   ${m_seistime_maxtime}" ${bopts[2]} ${bopts[3]} -BS -R${m_seistime_mintime}/${m_seistime_maxtime}/${m_seistime_minmag}/${m_seistime_maxmag} -JX${m_seistime_width}T/${m_seistime_height} -Byaf+lMagnitude --MAP_FRAME_PEN=1p,black --FONT_LABEL=10p,Helvetica,black --FONT_ANNOT_PRIMARY=8p,Helvetica,black --ANNOT_OFFSET_PRIMARY=4p --MAP_TICK_LENGTH_PRIMARY=4p --LABEL_OFFSET=10p  --GMT_HISTORY=false --FONT_ANNOT_SECONDARY=8p,Helvetica,black -O -K ${VERBOSE} >>  seistime.ps

        gmt psbasemap -BtEbW -Byaf+l"Magnitude" -R${m_seistime_mintime}/${m_seistime_maxtime}/${m_seistime_minmag}/${m_seistime_maxmag} -JX${m_seistime_width}T/${m_seistime_height} -Byaf+lMagnitude --MAP_FRAME_PEN=1p,black --FONT_LABEL=10p,Helvetica,black --FONT_ANNOT_PRIMARY=8p,Helvetica,black --ANNOT_OFFSET_PRIMARY=4p --MAP_TICK_LENGTH_PRIMARY=4p --LABEL_OFFSET=10p  --GMT_HISTORY=false --FONT_ANNOT_SECONDARY=8p,Helvetica,black -O ${VERBOSE} >>  seistime.ps
      else
        gmt psbasemap ${bopts[1]} ${bopts[2]} ${bopts[3]} -BS -R${m_seistime_mintime}/${m_seistime_maxtime}/${m_seistime_minmag}/${m_seistime_maxmag} -JX${m_seistime_width}T/${m_seistime_height} -Byaf+lMagnitude --MAP_FRAME_PEN=1p,black --FONT_LABEL=10p,Helvetica,black --FONT_ANNOT_PRIMARY=8p,Helvetica,black --ANNOT_OFFSET_PRIMARY=4p --MAP_TICK_LENGTH_PRIMARY=4p --LABEL_OFFSET=10p  --GMT_HISTORY=false --FONT_ANNOT_SECONDARY=8p,Helvetica,black -O -K ${VERBOSE} >>  seistime.ps

        gmt psbasemap -BtEbW -Byaf+l"Magnitude" -R${m_seistime_mintime}/${m_seistime_maxtime}/${m_seistime_minmag}/${m_seistime_maxmag} -JX${m_seistime_width}T/${m_seistime_height} -Byaf+lMagnitude --MAP_FRAME_PEN=1p,black --FONT_LABEL=10p,Helvetica,black --FONT_ANNOT_PRIMARY=8p,Helvetica,black --ANNOT_OFFSET_PRIMARY=4p --MAP_TICK_LENGTH_PRIMARY=4p --LABEL_OFFSET=10p  --GMT_HISTORY=false --FONT_ANNOT_SECONDARY=8p,Helvetica,black -O ${VERBOSE} >>  seistime.ps
      fi
# --FORMAT_DATE_MAP="o dd" --FORMAT_CLOCK_MAP="hh:mm"
      # gmt psbasemap ${bopts[1]}'${timelabel}' ${bopts[2]} -BtESW -Byaf+l"Magnitude" -R${m_seistime_mintime}/${m_seistime_maxtime}/${m_seistime_minmag}/${m_seistime_maxmag} -JX${m_seistime_width}T/${m_seistime_height} -Byaf+lMagnitude --MAP_FRAME_PEN=1p,black --FONT_LABEL=10p,Helvetica,black --FONT_ANNOT_PRIMARY=8p,Helvetica,black --ANNOT_OFFSET_PRIMARY=4p --MAP_TICK_LENGTH_PRIMARY=4p --LABEL_OFFSET=10p  --GMT_HISTORY=false --FONT_ANNOT_SECONDARY=6p,Helvetica,black -O ${VERBOSE} >>  seistime.ps

      # gmt psbasemap -R -J -Bxaf+sD -BtrSW -Bxaf+l"Date" -By+l"Magnitude" -O --MAP_FRAME_PEN=thinner,black --FONT_LABEL=12p,Helvetica,black --FONT_ANNOT_PRIMARY=10p,Helvetica,black --ANNOT_OFFSET_PRIMARY=4p --LABEL_OFFSET=12p --GMT_HISTORY=false >>  seistime.ps

       gmt psconvert seistime.ps -Tf -A+m0.5i

      if [[ ${m_seistime_onmapflag} -eq 1 ]]; then

        # Expects the variable PS_HEIGHT_IN to contain the current vertical offset below the map
        # origin to allow concatenation of figure parts below the map.

        # echo "Map height is currently ${PS_HEIGHT_IN}"
        SEISTIME_PS_DIM=($(gmt psconvert seistime.ps -Fseistime -Te -A+m0i -V 2> >(grep Width) | gawk  -F'[ []' -v mapwidth=${MAP_PS_WIDTH_NOLABELS_IN} -v prevheight=$PS_HEIGHT_IN '{print $10/2.54, $17/2.54+0.5+prevheight, $10/2.54-(mapwidth+0) }'))

        # echo "It is" ${SEISTIME_PS_DIM[@]}
        gmt psimage -Dx"-${SEISTIME_PS_DIM[2]}i/-${SEISTIME_PS_DIM[1]}i"+w${SEISTIME_PS_DIM[0]}i seistime.eps -Xa${m_seistime_shiftx} $RJOK ${VERBOSE} --GMT_HISTORY=false >> map.ps

        # Set PS_HEIGHT_IN so another module can concatenate a panel
        PS_HEIGHT_IN=${SEISTIME_PS_DIM[1]}
      fi
  fi

}

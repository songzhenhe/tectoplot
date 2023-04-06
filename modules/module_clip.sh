
TECTOPLOT_MODULES+=("clip")

# UPDATED
# NEW OPTS

function tectoplot_defaults_clip() {
  CLIP_POLY_PEN="1p,blue"
}

function tectoplot_args_clip()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -clipon)
  tectoplot_get_opts_inline '
des -clipon activate an inside clipping mask
req m_clip_cliponfile file
    clipping polygon file or country ID (see tectoplot -r g -countryid)
' "${@}" || return

  plots+=("m_clip_clipon")
  ;;

  -clipout)
  tectoplot_get_opts_inline '
des -clipout activate an outside clipping mask
req m_clip_clipoutfile string
    clipping polygon file or country ID (see tectoplot -r g -countryid)
' "${@}" || return

  plots+=("m_clip_clipout")
  ;;

  -clipoff)
  tectoplot_get_opts_inline '
des -clipoff turn off current clipping mask
' "${@}" || return

  plots+=("m_clip_clipoff")
  ;;

  -clipline)
  tectoplot_get_opts_inline '
des -clipoff plot outline of current clipping mask
' "${@}" || return
    plots+=("m_clip_clipline")
  ;;
  esac
}

# function tectoplot_download_clip() {
# }

# function tectoplot_calculate_clip()  {
# }

# function tectoplot_cpt_clip() {
#   case $1 in
#     ;;
#   esac
# }

function tectoplot_plot_clip() {
  case $1 in
    m_clip_clipon)

    echo clipon file is ${m_clip_cliponfile[$tt]}

      if [[ -s ${m_clip_cliponfile[$tt]} ]]; then

        if [[ ${m_clip_cliponfile[$tt]} == *.kml ]]; then
          kml_to_first_xy ${m_clip_cliponfile[$tt]} clip_poly_${tt}.txt
        else
          cp ${m_clip_cliponfile[$tt]} clip_poly_${tt}.txt
        fi
      else
        # Extract the DCW borders and fix the longitude range if necessary
        gmt_init_tmpdir
        gmt pscoast -E${m_clip_cliponfile[$tt]} -M ${VERBOSE} | gawk '
        BEGIN {ind=1}
        {
          if ($1+0>180) {
            print $1-360, $2
          } else if ($1+0<-180) {
            print $1+360, $2
          }
          else if ($1==">"){
           print "0 x"
          }
          else {
            print
          }
        }' > clip_poly_${tt}.txt
        gmt_remove_tmpdir
      fi

      if [[ -s clip_poly_${tt}.txt ]]; then
        gmt psclip clip_poly_${tt}.txt ${RJOK} ${VERBOSE} >> map.ps
        m_clip_currentclip=clip_poly_${tt}.txt
      fi
      tectoplot_plot_caught=1
    ;;

    m_clip_clipout)

      if [[ -s ${m_clip_clipoutfile[$tt]} ]]; then

        if [[ ${m_clip_clipoutfile[$tt]} == *.kml ]]; then
          kml_to_first_xy ${m_clip_cliponfile[$tt]} clip_poly_${tt}.txt
        else
          cp ${m_clip_clipoutfile[$tt]} clip_poly_${tt}.txt
        fi
      else
        gmt_init_tmpdir
        # Extract the DCW borders and fix the longitude range if necessary
        gmt pscoast -E${m_clip_clipoutfile[$tt]} -M ${VERBOSE} | gawk '
        BEGIN {ind=1}
        {
          if ($1+0>180) {
            print $1-360, $2
          } else if ($1+0<-180) {
            print $1+360, $2
          }
          else if ($1==">"){
           print "0 x"
          }
          else {
            print
          }
        }' > clip_poly_${tt}.txt
        gmt_remove_tmpdir
      fi
      if [[ -s clip_poly_${tt}.txt ]]; then
        gmt psclip clip_poly_${tt}.txt -N ${RJOK} ${VERBOSE} >> map.ps
        m_clip_currentclip=clip_poly_${tt}.txt
      fi

      tectoplot_plot_caught=1
    ;;
    m_clip_clipoff)
      gmt psclip -C -K -O ${VERBOSE} >> map.ps
      tectoplot_plot_caught=1
    ;;
    m_clip_clipline)
      [[ -s ${m_clip_currentclip} ]] && gmt psxy ${m_clip_currentclip} -W${CLIP_POLY_PEN} ${RJOK} ${VERBOSE} >> map.ps
      tectoplot_plot_caught=1
    ;;
  esac
}

# function tectoplot_legendbar_clip() {
#   case $1 in
#       ;;
#   esac
# }

# function tectoplot_legend_clip() {
#   case $1 in
#     tectoplot_legend_caught=1
#   ;;
#   esac
# }

# function tectoplot_post_clip() {
#   echo "none"
# }

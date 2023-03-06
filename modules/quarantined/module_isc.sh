
TECTOPLOT_MODULES+=("isc")

function tectoplot_defaults_isc() {
  ISC_REPORT_MINMAG=5
}

function tectoplot_args_isc()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in
  -iscreport)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
modules/module_isc.sh
-iscreport:    create a HTML page with links to ISC events
-iscreport [[minmag=${ISC_REPORT_MINMAG}]]

Example: None
--------------------------------------------------------------------------------
EOF
fi
    shift

    if arg_is_float $1; then
      ISC_REPORT_MINMAG=$1
      ((tectoplot_module_shift++))
      shift
    fi

    doiscflag=1
    tectoplot_module_caught=1
    ;;
  esac
}

# The following functions are not necessary for this module

# function tectoplot_calculate_isc()  {
#   echo "Doing isc calculations"
# }
#
# function tectoplot_plot_isc() {
#   echo "Doing isc plot"
# }
#
# function tectoplot_legend_isc() {
#   echo "Doing isc legend"
# }

function tectoplot_post_isc() {
  echo "post ISC"
}

# module_test.sh

TECTOPLOT_MODULES+=("test")


function tectoplot_defaults_test() {
  numtest=0
  thistest=0
  calculated_test=0
  customint_test=0
  EQSLIP_CONTOURTRANS=25       # transparency of contours
  EQSLIP_CONTOURSMOOTH=3       # smoothing factor for contours
  plottedtestcptflag=0       # Did we already add to the legend?
}

function tectoplot_args_test()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in
    -test)

  cat <<-EOF > test
des -test test module argument processing
req m_test_file file
    required input file
req m_test_string string "default"
    required string
opt myfloat m_test_float float 0
    optional number
mes Module is used to test argument processing only
EOF


  if [[ $USAGEFLAG -eq 1 ]]; then
    tectoplot_usage_opts test
  else
    tectoplot_get_opts test "${@}"

    tectoplot_module_caught=1
  fi

  ;;
  esac
}

# tectoplot_cpts_test() {
# }

function tectoplot_calculate_test()  {

  echo "Invocation ${tt}"
  echo "  Required file: ${m_test_file[$tt]}"
  echo "  Required string: ${m_test_string[$tt]}"
  echo "  Option myfloat: ${m_test_float[$tt]}"


  # echo "Required args:"
  # numvars=$(echo "${#m_test_reqs[@]} - 1" | bc)
  # for i in $(seq 0 ${numvars}); do
  #   key=${m_test_reqs[$i]}"[@]"
  #   echo "   ${m_test_reqs[$i]} = ${!key}"
  # done
  # echo "Optional args (array): ${m_test_opts[@]}"
  # echo "Optional args (vars ): ${m_test_opns[@]}"

}



# function tectoplot_cpt_test() {
# }

#function tectoplot_plot_test() {
#}

# function tectoplot_legend_test() {
# }

# function tectoplot_legendbar_test() {
# }

# function tectoplot_post_test() {
# }

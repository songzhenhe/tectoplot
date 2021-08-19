
# This script contains a template describing the functionality of tectoplot
# modules.

# tectoplot modules must be saved to a script called module_XXXX.sh
# in the tectoplot/modules/ folder.

# Register the module with tectoplot
TECTOPLOT_MODULES+=("example_module")

# Description of the module goes here

# Variables that expected to be defined are listed here:
# VARIABLE_1
# VARIABLE_2

# Defaults are variabls or paths that need to be defined for this module but
# which may be shared with the tectoplot primary code.

function tectoplot_defaults_example() {
  SCRIPTPATH=${BASHSCRIPTDIR}"example_script.sh"
  THIS_VARIABLE=145
}

# Argument processing function defines the flag (-example) and parses arguments

function tectoplot_args_example()  {
  # The following lines are required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  # The flag (or set of flags) defined by the module
  -example)

  # A usage statement with the following format:
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
modules.template.sh
-example:      short explanatory text
-example [required_arg] [[optional_arg1]] ...

  This is a text description of the module and its arguments.

  flags: (both can be specified)
    good    plot a good example
    bad     plot a bad example

Example: Make a good and bad example
 tectoplot -example bad good
--------------------------------------------------------------------------------
EOF
  fi

    # This is the way to check the number of arguments
    if [[ ! $(number_nonflag_args "${@}") -ge 5 ]]; then
      echo "[-vres]: Requires 5-7 arguments. tectoplot usage -vres"
      exit 1
    fi

    # The first shift clears the -example flag from the command list
    shift

    VARIABLE1="${1}"
    PATH1=$(abs_path "${2}")
    VARIABLE2="${3}"
    VARIABLE3="${4}"
    VARIABLE4="${5}"

    # Shift the arguments away in order to allow further argument parsing in this function
    shift 5

    # tectoplot_module_shift must be incremented for each argument to the module
    ((tectoplot_module_shift+=5))

    # Check the arguments as necessary
    if ! arg_is_positive_float $VARIABLE1; then
      echo "[-example]: Argument ${VARIABLE1} should be a positive number without unit character."
      exit 1
    fi
    if ! arg_is_float $VARIABLE3; then
      echo "[-example]: Argument ${VARIABLE3} should be a float."
      exit 1
    fi

    # Further argument parsing is possible

    while ! arg_is_flag $1; do
      case "${1}" in
        flag1)
          FLAG1VARIABLE=1
        ;;
        flag2)
          FLAG2VARIABLE=1
        ;;

        # Handle unknown arguments
        *)
          info_msg "[-example]: Unknown option ${1}... skipping"
        ;;
      esac
      shift
    done

    # Check if the input file exists
    if [[ ! -s ${PATH1} ]]; then
      info_msg "[-example]: Input file ${PATH1} does not exist."
      exit 1
    fi

    # Add the module to the FIFO stack of plotting commands tectoplot will execute
    # If no plotting is to be done, this can be left out and the tectoplot_calculate etc
    # functions will still run if defined.
    plots+=("example")

    # Add the module to the FIFO stack of commands tectoplot will execute
    cpts+=("example")

    # Signal to tectoplot that the current command was processed by this module
    tectoplot_module_caught=1
    ;;
  esac
}

function tectoplot_calculate_example()  {
  echo "This function contains any calculations to be done before plotting"
  echo "Functions will be run in alphabetical order!"
}

function tectoplot_cpt_example() {
  echo "This section contains code to generate CPT files in ${F_CPTS} for plotting"
  echo "This function will only be run if the module contains cpts+=(...)"
  case $1 in
    example)
      gmt makecpt -T0/1/0.1 -Cturbo > ${F_CPTS}example.cpt
      tectoplot_cpt_caught=1
      ;;
  esac
}

function tectoplot_plot_example() {
  echo "This function contains the logic to plot elements onto the active map"
  echo "\$RJOK is -R -J -O -K and \${VERBOSE} is the active verbosity setting"
  echo "Concatenate PS data onto map.ps"

  case $1 in
  example)
    gmt GMT_MODULE GMT_COMMANDS $RJOK ${VERBOSE} >> map.ps
    tectoplot_plot_caught=1
    ;;
  esac
}

# This function is taken from module_volcanoes.sh and shows how to add an entry
# to the legend using the 'typewriter' method.

function tectoplot_legend_example() {
  case $1 in
  example)
    # Create a new blank map with the same -R -J as our main map
    gmt psxy -T -X0i -Yc $OVERLAY $VERBOSE -K ${RJSTRING[@]} > volcanoes.ps

    # Plot the symbol and accompanying text at the CENTERLON/CENTERLAT point (known to be on the map)
    echo "$CENTERLON $CENTERLAT" | gmt psxy -W"${V_LINEW}","${V_LINECOLOR}" -G"${V_FILL}" -S${V_SYMBOL}${V_SIZE} $RJOK $VERBOSE >> volcanoes.ps
    echo "$CENTERLON $CENTERLAT Volcano" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE -J -R -Y0.1i -O >> volcanoes.ps

    # Calculate the width and height of the graphic with a margin of 0.05i
    PS_DIM=$(gmt psconvert volcanoes.ps -Te -A0.05i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
    PS_WIDTH_IN=$(echo $PS_DIM | gawk  '{print $1/2.54}')
    PS_HEIGHT_IN=$(echo $PS_DIM | gawk  '{print $2/2.54}')

    # Place the graphic onto the legend PS file, appropriately shifted. Then shift up.
    # If we run past the width of the map, then we shift all the way left; otherwise we shift right.
    # (The typewriter approach)

    gmt psimage -Dx"${LEG2_X}i/${LEG2_Y}i"+w${PS_WIDTH_IN}i volcanoes.eps $RJOK ${VERBOSE} >> $LEGMAP
    LEG2_Y=$(echo "$LEG2_Y + $PS_HEIGHT_IN + 0.02" | bc -l)
    count=$count+1
    NEXTX=$(echo $PS_WIDTH_IN $NEXTX | gawk  '{if ($1>$2) { print $1 } else { print $2 } }')
    cleanup volcanoes.ps volcanoes.eps

    tectoplot_legend_caught=1
    ;;
  esac

}

# Colorbars are specified using a pslegend format such as the following:

function tectoplot_legendbar_example() {
    case $1 in
      example)
        echo "G 0.2i" >> legendbars.txt
        echo "B $EXAMPLE_CPT 0.2i 0.1i+malu -W0.00001 -Bxa10f1+l\"Example units (100k)\"" >> legendbars.txt
        barplotcount=$barplotcount+1
        tectoplot_legendbar_caught=1
        ;;
    esac
}


function tectoplot_post_example() {
  echo "This function contains logic that is executed after the map document is finalized."
  echo "Extra figures, 3D models, etc. can be processed at this point"
}

# Source this script

# tectoplot
# bashscripts/args_cleanup.sh
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


## This script contains variable definitions and routines for argument processing, 
## data management, and cleanup

################################################################################
# Messaging and debugging routines

# args_DEBUG=1

# Returns true if argument is empty or starts with a hyphen but is not a float;
# else returns false. Not sure this is the best way to code this test... bash...
# if arg_is_flag "${1}"; then ... ; fi
function arg_is_flag() {
  if ! arg_is_float "${1}"; then
    [[ ${1:0:1} == [-] || -z ${1} ]] && return
  else
    [[ 1 -eq 0 ]] && return
  fi
}

# Returns the opposite of arg_is_flag
function arg_is_string() {
   if arg_is_flag $1; then
    [[ 1 -eq 0 ]] && return
  else
    [[ 1 -eq 1 ]] && return
  fi
}

# Returns true if argument is a (optionally signed, optionally decimal) number
function arg_is_float() {
  [[ "${1}" =~ ^[+-]?([0-9]+\.?|[0-9]*\.[0-9]+)$ ]]
}

# Returns true if argument is a (optionally signed, optionally decimal) positive number
function arg_is_positive_float() {
  [[ "${1}" =~ ^[+]?([0-9]+\.?|[0-9]*\.[0-9]+)$ ]]
}

# Returns true if argument is a (optionally signed, optionally decimal) positive number followed by the letter k

function arg_is_km() {
  [[ "${1}" =~ ^[+]?([0-9]+\.?|[0-9]*\.[0-9]+)k$ ]]
}

# Returns true if argument is a (optionally decimal) negative number
function arg_is_negative_float() {
  [[ "${1}" =~ ^[-]([0-9]+\.?|[0-9]*\.[0-9]+)$ ]]
}

# Returns true if argument is a (optionally signed) integer
function arg_is_integer() {
  [[ "${1}" =~ ^[+-]?([0-9]+)$ ]]
}

# Returns true if argument is a (optionally signed, optionally decimal) positive number
function arg_is_positive_integer() {
  [[ "${1}" =~ ^[+]?([0-9]+)$ ]]
}

# Returns true if argument is a negative integer
function arg_is_negative_integer() {
  [[ "${1}" =~ ^[-]([0-9]+)$ ]]
}

# Returns true if argument is a file that contains data
function arg_is_file() {
  if [[ -s $1 ]]; then
    return 1
  fi
  return 0
}

# Report the number of arguments remaining before the next flag argument
# Assumes the first argument in ${@} is current flag (eg -xyz) and ignores it
# num_left=$(number_nonflag_args "${@}")
function number_nonflag_args() {
  THESE_ARGS=("${@}")
  for index_a in $(seq 2 ${#THESE_ARGS[@]}); do
    if arg_is_flag "${THESE_ARGS[$index_a]}"; then
      break
    fi
  done
  echo $(( index_a - 1 ))
}

function error_msg() {
  printf "%s[%s]: %s\n" "${BASH_SOURCE[1]##*/}" ${BASH_LINENO[0]} "${@}" > /dev/stderr
  exit 1
}

function info_msg() {
  if [[ $narrateflag -eq 1 ]]; then
    printf "TECTOPLOT %05s: " ${BASH_LINENO[0]}
    printf "%s\n" "${@}"
  fi
  printf "TECTOPLOT %05s: " ${BASH_LINENO[0]} >> "${INFO_MSG}"
  printf "%s\n" "${@}" >> "${INFO_MSG}"
}

# Exit cleanup code from Mitch Frazier
# https://www.linuxjournal.com/content/use-bash-trap-statement-cleanup-temporary-files

function cleanup_on_exit()
{
      for i in "${on_exit_items[@]}"; do
        if [[ $CLEANUP_FILES -eq 1 ]]; then
          info_msg "rm -f $i"
          rm -f "${i}"
        else
          info_msg "Not cleaning up file $i"
        fi
      done
}

function move_on_exit()
{
      for i in "${on_exit_move_items[@]}"; do
        if [[ -d ${OUTPUTDIRECTORY} ]]; then
          info_msg "mv $i ${OUTPUTDIRECTORY}"
          mv $i ${OUTPUTDIRECTORY}
        else
          info_msg "Not moving file $i"
        fi
      done
}

# Be sure to only cleanup files that are in the temporary directory
function cleanup()
{
    local n=${#on_exit_items[*]}
    on_exit_items[$n]="$*"
    if [[ $n -eq 0 ]]; then
        info_msg "Setting EXIT trap function cleanup_on_exit()"
        trap cleanup_on_exit EXIT
    fi
}

# Be sure to only cleanup files that are in the temporary directory
function move_exit()
{
    local n=${#on_exit_move_items[*]}
    on_exit_move_items[$n]="$*"
    if [[ $n -eq 0 ]]; then
        info_msg "Setting EXIT trap function move_on_exit()"
        trap move_on_exit EXIT
    fi
}


###########




########### File path routines

# Return the full path to a file or directory
function abs_path() {

    # If it's an existing directory, return the full path with / at the end
    if [ -d "${1}" ]; then
        (cd "${1}"; echo "$(pwd)/")
    # If it's an existing file, return the full path with / at the end
    elif [ -f "${1}" ]; then
        if [[ $1 = /* ]]; then
            echo "${1}"
        elif [[ $1 == */* ]]; then
            echo "$(cd "${1%/*}"; pwd)/${1##*/}"
        else
            echo "$(pwd)/$1"
        fi
    # Special case to parse to the temporary data directory
    elif [[ $1 =~ TEMP/* ]]; then
      echo "${TMP}"/"${1##*/}"
    else
      echo $1
    fi
}

# Return the full path to the directory containing a file, or the directory itself
function abs_dir() {
    if [ -d "${1}" ]; then
        (cd "${1}"; echo "$(pwd)/")
    elif [ -f "${1}" ]; then
        if [[ $1 == */* ]]; then
            echo "$(cd "${1%/*}"; pwd)/"
        else
            echo "$(pwd)/"
        fi
    # Assume it's a directory that does not yet exist
    else
      if [[ $1 == */ ]]; then
        echo "${1}"
      else
        echo "${1}"/
      fi
    fi
}

# Compares the first word (arg1) to a list of other words (${@})
# Returns true if the first word is in the list OR if the first word starts with "-"

function is_arg() {
  local arg1=$1
  shift
  # echo "Searching for ${arg1} within list >${@}<"
  if [[ -z "${@}" ]]; then
    # If there is no list of other words
    # echo "case 1: >${@}<  is empty; comparing with ${arg1}" 
    [[ ${arg1:0:1} == [-] || -z ${arg1} ]] && return
  else
    [[ " ${@} " =~ " $arg1 " || ${arg1:0:1} == [-] || -z ${arg1} ]] && return
  fi
}

########### Data processing routines 

# Replacement for tac and tail -r (bad compliance across different systems!)
# Outputs the input file in reverse line order.
function tecto_tac() {
  gawk '{
    data[NR]=$0
  }
  END {
    num=NR
    for(i=num;i>=1;i--) {
      print data[i]
    }
  }' "$@"
}

########### Module routines

# tectoplot_get_opts_inline takes a block of text as the first argument,
# which is used to produce a control file that dictates argumetn parsing. 
# The block of text is followed by the current tectoplot command line arguments.

# The variables are stored in associative arrays keyed by the number of times
# the given option is called: OPT_VAR[1] vs OPT_VAR[2] etc. This allows the
# plotting section of modules to handle multiple calls to the same command.

# Optional variables are initialized using specified default values

# The command block must start with a des command"

function tectoplot_get_opts_inline() {

  words=($(echo "${1}"))
  echo "${1}" | gawk '($1!=""){print}' > tectoplot_opts

  if [[ ${words[0]} != "des" ]]; then
    echo "tectoplot_get_opts_inline: no des line at start of control block text:"
    echo "${1}"
    exit 1
  else
    thiscall=${words[1]}
    # Shift away the -XXXX option
    if [[ ${thiscall:0:1} != "-" ]]; then
      echo "Expected command starting with -, instead found: $thiscall; exiting"
      exit 1
    else
      call="${thiscall:1}"
      shift

      # Remaining arguments are the command line arguments
    fi
  fi

  # Get rid of the flag
  shift

  # Print usage if asked, then return 1 indicating no options were processed

  if [[ $USAGEFLAG -eq 1 ]]; then
    tectoplot_usage_opts_inline $call
    return 1
  fi

  # Read in the control file and look for required arguments, then options

  local tectoplot_options_count
  local tectoplot_opts_argument
  local tectoplot_opts_variable
  local tectoplot_opts_type
  local tectoplot_opts_default
  tectoplot_options_count=0
  # tectoplot_module_shift=0

  # Get the name of the correct variable; reference using ${!}
  local tectoplot_opts_exp
  tectoplot_opts_exp=${call}_opt_count

  eval "((${call}_opt_count++))"

  variable_list="${variable_list} ${call}_opt_count"

  # This is necessary to activate the [N] suffix for variables in multi-call
  # scenarios.
  bracketstr="[${!tectoplot_opts_exp}]"

  # ren creates a single variable referenced by its name only
  # req creates a new entry in a variable array, referenced by name[n], where [n]
  #  is the number of times get_opts has been called on this function

  # opn creates a single optional variable
  # opt creates an entry in an array of optional variables

  # des defines the description of the module

  [[ $args_DEBUG -eq 1 ]] && echo "tectoplot_get_opts_inline: $@"


  [[ $args_DEBUG -eq 1 ]] && echo "$call: Reading list of optional parameters"

  unset optstr

  # Read in the optional parameters list

  while IFS= read -r p <&3 || [ -n "$p" ] ; do
    d=($(echo $p))
    [[ $args_DEBUG -eq 1 ]] && echo " Read control string: ${p}"
    # [[ $args_DEBUG -eq 1 ]] && echo "Preload args are $@"
    # d[0] is the command type: req/ren/opt/opn

    case ${d[0]} in
      opt)
        [[ $args_DEBUG -eq 1 ]] && echo " Found opt argument: m_${call}_opts+=(\"${d[1]}\")"

        eval "m_${call}_opts+=(\"${d[1]}\")"
        optstr=" ${optstr} ${d[1]} "
      ;;
      opn)
      [[ $args_DEBUG -eq 1 ]] && echo " Found opn argument: m_${call}_opns+=(\"${d[1]}\")"

        eval "m_${call}_opns+=(\"${d[1]}\")"
        optstr=" ${optstr} ${d[1]} "
      ;;
    esac
  done 3< tectoplot_opts

  # Read in required parameters while also loading optional parameter list. This allows us to 
  # determine whether an argument (e.g. a word in a string) is actually a command option.

  [[ $args_DEBUG -eq 1 ]] && echo "Reading required parameters and loading list of optional parameters"

  while IFS= read -r p <&3 || [ -n "$p" ] ; do
    d=($(echo $p))
    [[ $args_DEBUG -eq 1 ]] && echo "  Read control string: ${p}"
    [[ $args_DEBUG -eq 1 ]] && echo "  Remaining command line arguments are: $@"
    # d[0] is the command type: req/ren/opt/opn
    case ${d[0]} in
      req|ren)
        [[ $args_DEBUG -eq 1 ]] && echo "  Read ${d[0]} command: evaluating argument now"
        if [[ ${d[0]} == "ren" ]]; then
          bracketstr=""
        else
          bracketstr="[${!tectoplot_opts_exp}]"
        fi
        eval "m_${call}_reqs+=(\"${d[1]}\")"
        case ${d[2]} in
          word)
            if arg_is_string ${1}; then
              eval "${d[1]}${bracketstr}=${1}"
              variable_list=$(echo "${variable_list} ${d[1]}${bracketstr}")
              shift
              ((tectoplot_module_shift++))
            else
              echo "[-$call]: argument ${1} is not a word"
              exit 1
            fi
          ;;
          cpt)
              get_cpt_path "${1}"
              eval "${d[1]}${bracketstr}=${CPT_PATH}"
              shift
              ((tectoplot_module_shift++))
            ;;
          dir)
            if [[ -d ${1} ]]; then
              eval "${d[1]}${bracketstr}=$(abs_path ${1})"
              variable_list=$(echo "${variable_list} ${d[1]}${bracketstr}")
              shift
              ((tectoplot_module_shift++))
            else
              echo "[-$call]: directory $1 does not exist"
              exit 1
            fi
          ;;
          file)
            if ! arg_is_flag $1; then
              eval "${d[1]}${bracketstr}=$(abs_path ${1})"
              variable_list=$(echo "${variable_list} ${d[1]}${bracketstr}")
              shift
              ((tectoplot_module_shift++))
            else
              echo "[-$call]: file option requires argument"
              exit 1
            fi
          ;;
          float)
            if arg_is_float ${1}; then
              eval "${d[1]}${bracketstr}=${1}"
              variable_list=$(echo "${variable_list} ${d[1]}${bracketstr}")
              shift
              ((tectoplot_module_shift++))
            else
              echo "[-$call]: required float argument not found; found $1 instead."
              exit 1
            fi
          ;;
          positive_float)
            if arg_is_positive_float ${1}; then
              eval "${d[1]}${bracketstr}=${1}"
              variable_list=$(echo "${variable_list} ${d[1]}${bracketstr}")
              shift
              ((tectoplot_module_shift++))
            else
              echo "[-$call]: required positive float argument not found; found $1 instead."
              exit 1
            fi
          ;;
          string)
            if arg_is_string ${1}; then
              [[ $args_DEBUG -eq 1 ]] && echo "  -> Reading string argument"

              unset argstring
              [[ $args_DEBUG -eq 1 ]]  && echo "optstr is >${optstr}<"
              while ! is_arg $1 ${optstr}; do
                
                [[ $args_DEBUG -eq 1 ]] && echo "Arg is >$1<, optstr is >${optstr}<"

                if [[ -z $argstring ]]; then
                  argstring=$1
                else
                  argstring="${argstring} ${1}"
                  [[ $args_DEBUG -eq 1 ]] && echo "argstring is ${argstring}"
                fi
                ((tectoplot_module_shift++))
                shift
                # If we have read past the end of the command string, break
                [[ -z $1 ]] && break
              done

              eval "${d[1]}${bracketstr}=\"${argstring}\""
              variable_list=$(echo "${variable_list} ${d[1]}${bracketstr}")
              # shift
              # ((tectoplot_module_shift++))
              [[ $args_DEBUG -eq 1 ]] && echo "  --> Read ${argstring}"
            else
              echo "[-$call]: required string argument not found; found $1 instead."
              exit 1
            fi
          ;;
        esac
      ;;
      opt)
        ((tectoplot_options_count++))
        tectoplot_opts_optopn[${tectoplot_options_count}]="opt"
        tectoplot_opts_argument[${tectoplot_options_count}]=${d[1]}
        tectoplot_opts_variable[${tectoplot_options_count}]=${d[2]}
        tectoplot_opts_type[${tectoplot_options_count}]=${d[3]}
        # tectoplot_opts_default[${tectoplot_options_count}]=${d[4]}
        # Set the default value for the option variable
        [[ $args_DEBUG -eq 1 ]] && echo "  Setting opt variable ${d[2]}${bracketstr}=${d[@]:4}"
        eval "${d[2]}${bracketstr}=${d[@]:4}"
        # Add to the list of created variables
        variable_list=$(echo "${variable_list} ${d[2]}${bracketstr}")
      ;;
      opn)
        ((tectoplot_options_count++))
        tectoplot_opts_optopn[${tectoplot_options_count}]="opn"
        tectoplot_opts_argument[${tectoplot_options_count}]=${d[1]}
        tectoplot_opts_variable[${tectoplot_options_count}]=${d[2]}
        tectoplot_opts_type[${tectoplot_options_count}]=${d[3]}
        # tectoplot_opts_default[${tectoplot_options_count}]=${d[4]}
      #  Add to the list of created variables
        [[ $args_DEBUG -eq 1 ]] && echo "  Setting opn variable ${d[2]}=${d[@]:4}"

        variable_list=$(echo "${variable_list} ${d[1]}")
        eval "${d[2]}=${d[@]:4}"
      ;;
      nam|des)
        # Ignore these for this part of processing
      ;;
      # *)
      #   info_msg "[-$call]: Ignoring unrecognized control line: $p"
      # ;;
    esac
  done 3< tectoplot_opts


  [[ $args_DEBUG -eq 1 ]] && echo "Before shifting arg1 is $1"
  # Read in optional parameters
  while ! arg_is_flag $1; do
    [[ $args_DEBUG -eq 1 ]] && echo "loading optional parameter $1"

    # We have remaining arguments
    if [[ $tectoplot_options_count -gt 0 ]]; then
      opts_found=0
      for opt_i in $(seq 1 $tectoplot_options_count); do
        if [[ ${tectoplot_opts_argument[$opt_i]} == $1 ]]; then

          # opn sets variable without [], opt sets with []
          if [[ ${tectoplot_opts_optopn[$opt_i]} == "opt" ]]; then
            bracketstr="[${!tectoplot_opts_exp}]"
          else
            bracketstr=""
          fi

          shift
          ((tectoplot_module_shift++))

          case ${tectoplot_opts_type[$opt_i]} in
          word)
            if arg_is_string ${1}; then
              eval "${tectoplot_opts_variable[$opt_i]}${bracketstr}=${1}"
              shift
              ((tectoplot_module_shift++))
            else
              echo "[-$call]: argument ${1} is not a word"
              exit 1
            fi
            ;;
            # list is a list of any kinds of words contained within { } brackets
            list)
              unset argument_list
              if [[ $1 != "{" ]]; then
                echo "[tectoplot_get_opts]: list variable expected list starting with {"
                exit 1
              fi
              shift
              ((tectoplot_module_shift++))
              while [[ $1 != "}" && ! -z $1 ]]; do
                if [[ -z ${argument_list} ]]; then
                  argument_list=${1}
                else
                  argument_list="${argument_list} $1"
                fi
                shift
                ((tectoplot_module_shift++))
              done
              if [[ $1 != "}" ]]; then
                echo "[tectoplot_get_opts]: list variable expected list ending with }"
                exit 1
              else
                shift
                ((tectoplot_module_shift++))
              fi
              eval "${tectoplot_opts_variable[$opt_i]}${bracketstr}=\"${argument_list}\""
            ;;
            # cpt is a filename or name of a builtin (tectoplot or GMT) CPT
            cpt)
              get_cpt_path $1
              eval "${tectoplot_opts_variable[$opt_i]}${bracketstr}=${CPT_PATH}"
              shift
              ((tectoplot_module_shift++))
            ;;
            # dir is an exsiting directory
            dir)
              if [[ -d ${1} ]]; then
                eval "${tectoplot_opts_variable[$opt_i]}${bracketstr}=$(abs_path ${1})"
                shift
                ((tectoplot_module_shift++))
              else
                echo "[-$call]: directory $1 does not exist"
                exit 1
              fi
            ;;

            # file is an existing, non-empty file
            file)
              if [[ -s ${1} ]]; then
                eval "${tectoplot_opts_variable[$opt_i]}${bracketstr}=$(abs_path ${1})"
                shift
                ((tectoplot_module_shift++))
              else
                echo "[-$call]: file $1 does not exist or is empty"
                exit 1
              fi
            ;;
            # flag is 0 (off) or 1 (on); invoking argument switches flag on/off
            flag)
              if [[ $1 == "off" ]]; then
                eval "${tectoplot_opts_variable[$opt_i]}${bracketstr}=0"
                shift
                ((tectoplot_module_shift++))
              elif [[ $1 == "on" ]]; then
                eval "${tectoplot_opts_variable[$opt_i]}${bracketstr}=1"
                shift
                ((tectoplot_module_shift++))
              else
                # Get the name of the variable
                str="${tectoplot_opts_variable[$opt_i]}${bracketstr}"
                # Check its value using ${!}
                case ${!str} in
                  0) eval "${tectoplot_opts_variable[$opt_i]}${bracketstr}=1";;
                  1) eval "${tectoplot_opts_variable[$opt_i]}${bracketstr}=0";;
                esac
              fi
            ;;
            # float is any floating point number in decimal form
            float)
              if arg_is_float ${1}; then
                eval "${tectoplot_opts_variable[$opt_i]}${bracketstr}=${1}"
                shift
                ((tectoplot_module_shift++))
              else
                echo "[-$call]: required float argument not found; found $1 instead."
                exit 1
              fi
            ;;
            # floatlist is a list of floats
            floatlist)
              unset temp_floatlist
              while arg_is_float ${1}; do
                if [[ $temp_floatlist == "" ]]; then
                  temp_floatlist=$1
                else
                  temp_floatlist="$temp_floatlist $1"
                fi
                shift
                ((tectoplot_module_shift++))
              done
              eval "${tectoplot_opts_variable[$opt_i]}${bracketstr}=\"${temp_floatlist}\""
            ;;
            # int is any integer
            int)
              if arg_is_integer ${1}; then
                eval "${tectoplot_opts_variable[$opt_i]}${bracketstr}=${1}"
                shift
                ((tectoplot_module_shift++))
              else
                echo "[-$call]: required integer argument not found; found $1 instead."
                exit 1
              fi
            ;;
            # posint is any positive integer
            posint)
              if arg_is_positive_integer ${1}; then
                eval "${tectoplot_opts_variable[$opt_i]}${bracketstr}=${1}"
                shift
                ((tectoplot_module_shift++))
              else
                echo "[-$call]: required positive integer argument not found; found $1 instead."
                exit 1
              fi
            ;;
            # posfloat is any positife float
            posfloat)
              if arg_is_positive_float ${1}; then
                eval "${tectoplot_opts_variable[$opt_i]}${bracketstr}=${1}"
                shift
                ((tectoplot_module_shift++))
              else
                echo "[-$call]: required positive float argument not found; found $1 instead."
                exit 1
              fi
            ;;
            # string is anything that is not an arg_is_flag flag (-c, -t, etc)
            # or another control code
            string)
              if arg_is_string ${1}; then

                unset argstring
                while ! is_arg $1 ${tectoplot_opts_argument[@]}; do
                  if [[ -z $1 ]]; then
                    break
                  fi
                  if [[ -z $argstring ]]; then
                    argstring=$1
                  else
                    argstring="${argstring} ${1}"
                  fi
                  ((tectoplot_module_shift++))
                  shift
                  # If we have read past the end of the command string, break
                  [[ -z $1 ]] && break
                done
                eval "${tectoplot_opts_variable[$opt_i]}${bracketstr}=\"${argstring}\""
                # shift
                # ((tectoplot_module_shift++))
              else
                echo "[-$call]: required string argument not found; found $1 instead."
                exit 1
              fi
            ;;
            *)  # ignore it we don't know whats up
                shift
                ((tectoplot_module_shift++))
            ;;
          esac
          opts_found=1
        fi
      done
      # Handle case where this option was not registered
      if [[ $opts_found -eq 0 ]]; then
        echo "[-$call]: Optional argument $1 not recognized"
        exit 1
      fi
    fi

    # shift
    # ((tectoplot_module_shift++))
  done

  # Delete the opts file
  rm -f tectoplot_opts

  # Set the flag for the module being caught
  tectoplot_module_caught=1

  info_msg "[tectoplot_get_opts -$call]: set variables: ${variable_list}"
}


function resolve() {
  local mystr=$1
  echo ${!mystr}
}

# Print out a usage message based on the contents of an opts file

function tectoplot_usage_opts() {
  if [[ ${#@} -lt 1 ]]; then
    echo "tectoplot_usage_opts: no file or function name provided"
    exit 1
  else
    call=$1
    shift
  fi

  # First, print the name of the command and its description
  gawk < $call '
    ($1=="des") {
      nam=$2
      # Print the name of the function
      printf("%-15s", nam)
      # followed by the description string
      printf("%s\n", substr($0, length($1)+length($2)+3))
      # start a new line with the function name
      printf("%s ", nam)
    }
    # store the arguments list, print required arguments in order
    ($1=="req"||$1=="ren") {
      printf("[%s] ", $3)
    }
    ($1=="opt"||$1=="opn") {
      optflag=1
    }
    # Print if we have optional arguments
    END {
      if (optflag==1) {
        print "[[options ...]]"
      }
    }'

  # Print the required arguments
  gawk < $call -v uflag=${USAGEVARSFLAG} '
    BEGIN {
      doneopts=0
    }
    ($1=="req"||$1=="ren") {
      if (doneopts==0) {
        printf("\n\n")
        print "Required arguments:"
      }
      a=sprintf("%s", $3)
      printf "%-25s", a
      c=$2
      getline
      printf("%s", $0)
      if (uflag==1) {
        printf("\t%s", c)
      }
      doneopts=1
    }
    END {
      if(doneopts==1) {
        printf("\n")
      }
    }'

  # Print the optional arguments
  gawk < $call -v uflag=${USAGEVARSFLAG} '
    BEGIN {
      doneopts=0
    }
    ($1=="opt"||$1=="opn") {
      if (doneopts==0) {
        print ""
        print "Optional arguments:"
      }
      if ($4!="flag") {
        if (substr($4,length($4)-3,4)=="list") {
          pvar=" { val ... }"
        } else {
          pvar=" [val]"
        }
      } else {
        pvar=" [[val]]"
        flagmessage=1
      }
      a=sprintf("%s%s", $2, pvar)
      if ($4=="flag" && $5=="0") {
        b=sprintf("[%s=%s] ", $4, "off")
      } else {
        b=sprintf("[%s=%s] ", $4, $5)
      }
      c=$3
      printf "%-25s", a
      getline
      printf("%s %s", $0, b)
      if (uflag==1) {
        printf("\t%s", c)
      }
      printf("\n")

      doneopts=1
    }
    END {
      if (flagmessage==1) {
        print "\nFor flag options, [[val]] can be off or on; no argument means flip default value "
      }
    }'

    # Print any messages
    gawk < $call '
    BEGIN {
      printedmes=0
    }
    ($1=="mes") {
      str=substr($0,4,length($0)-3)
      if (printedmes==0) { printf("\n"); printedmes=1 }
      print str
    }'

    # Print examples
    gawk < $call '
    BEGIN {
      printedexa=0
    }
    ($1=="exa") {
      $1=""
      if (printedexa==0) { printf("\nExample: "); printedexa=1 }
      printf("%s\n", $0)
    }
    END {
      printf("\n----------------------------------------------------------------------------------------------------\n")
    }' | gawk '{$1=$1;print}'
}


# tectoplot_usage_opts_inline() expects a file tectoplot_opts in ${PWD} 
# This function prints the -usage message for a specified option

function tectoplot_usage_opts_inline() {
  if [[ ${#@} -lt 1 ]]; then
    echo "tectoplot_usage_opts: no file or function name provided"
    exit 1
  else
    call=$1
    shift
  fi

  # First, print the name of the command and its description
  gawk < tectoplot_opts '
    ($1=="des") {
      nam=$2
      # Print the name of the function
      printf("\nOption: %-15s", nam)
      # followed by the description string
      printf("%s\n", substr($0, length($1)+length($2)+3))
      # start a new line with the function name
      printf("Module: '${TECTOPLOTDIR}'modules/module_'${tecoplot_current_module}'.sh\n\nUsage:  %s ", nam)
    }
    # store the arguments list, print required arguments in order
    ($1=="req"||$1=="ren") {
      printf("[%s] ", $3)
    }
    ($1=="opt"||$1=="opn") {
      optflag=1
    }
    # Print if we have optional arguments
    END {
      if (optflag==1) {
        print "[[options ...]]"
      }
    }'

  # Print the required arguments
  gawk < tectoplot_opts -v uflag=${USAGEVARSFLAG} '
    BEGIN {
      doneopts=0
    }
    ($1=="req"||$1=="ren") {
      if (doneopts==0) {
        printf("\n\n")
        print "Required arguments:"
      }
      a=sprintf("%s", $3)
      printf "%-25s", a
      c=$2
      getline
      printf("%s", $0)
      if (uflag==1) {
        printf("\t%s", c)
      }
      printf("\n")
      doneopts=1
    }
    END {
      if(doneopts==1) {
        printf("\n")
      }
    }'

  # Print the optional arguments
  gawk < tectoplot_opts -v uflag=${USAGEVARSFLAG} '
    BEGIN {
      doneopts=0
    }
    ($1=="opt"||$1=="opn") {
      if (doneopts==0) {
        print ""
        print "Optional arguments:"
      }
      if ($4!="flag") {
        if (substr($4,length($4)-3,4)=="list") {
          pvar=" { val ... }"
        } else {
          pvar=" [val]"
        }
      } else {
        pvar=" [[val]]"
        flagmessage=1
      }
      a=sprintf("%s%s", $2, pvar)
      if ($4=="flag" && $5=="0") {
        b=sprintf("[%s=%s] ", $4, "off")
      } else {
        b=sprintf("[%s=%s] ", $4, $5)
      }
      c=$3
      printf "%-25s", a
      getline
      printf("%s %s", $0, b)
      if (uflag==1) {
        printf("\t%s", c)
      }
      printf("\n")

      doneopts=1
    }
    END {
      if (flagmessage==1) {
        print "\nFor flag options, [[val]] can be off or on; no argument means flip default value "
      }
    }'

    # Print any messages
    gawk < tectoplot_opts '
    BEGIN {
      printedmes=0
    }
    ($1=="mes") {
      str=substr($0,4,length($0)-3)
      if (printedmes==0) { printf("\n"); printedmes=1 }
      print str
    }'

    # Print examples
    gawk < tectoplot_opts '
    BEGIN {
      printedexa=0
    }
    ($1=="exa") {
      $1=""
      if (printedexa==0) { printf("\nExample: "); printedexa=1 }
      printf("%s\n", $0)
    }
    END {
      printf("\n----------------------------------------------------------------------------------------------------\n")
    }' | gawk '{$1=$1;print}'
}

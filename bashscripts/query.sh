
# tectoplot
# bashscripts/check_and_run_query.sh
# Copyright (c) 2023 Kyle Bradley, all rights reserved.
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

# This script should be sourced from the main tectoplot script.

# It is expected that the current command line arguments are in ${1} ${2} ... etc
# 

# If the first argument (${1}) is -query, OR if the first argument is
# -tm|--tempdir, the second argument is a file, and the third argument is -query,
# then process the query request and exit the tectoplot run directly. This will
# leave the original tectoplot output folder in place.

if [[ $# -ge 3 && ${1} == "-tm" && ${3} == "-query" ]]; then
  # echo "Processing query request"
  if [[ ! -d ${2} ]]; then
    info_msg "[-query]: Temporary directory ${2} does not exist"
    exit 1
  else

    # Change into the indicated directory and shift args, leaving -query in $1
    tempdirqueryflag=1
    cd "${2}"
    shift
    shift
  fi
fi

# The -query option is a special option that needs to be handled here
# Note that the query metadata is currently not up to date / complete!

if [[ $1 == "-query" ]]; then
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
--------------------------------------------------------------------------------
-query:        query and print from files produced by prior call to tectoplot
-query [[tmpdir]] [filename] [options...] [field1] ... [fieldn]

Options:
  tmpdir:      path to a temporary directory within which the query is run
  noheader:    don't print field ID/units
  nounits:     don't print units
  csv:         print in CSV format          (activates data)
  json:        print data in GeoJSON format (activates data, nounits)
  data:        print data from file, space delimited
  fieldnum:    print field number instead of units in a trailing bracket [n]

field1 ... fieldn are field IDs of fields to be selected

A field id is either a number (field number, starting from 1) or a field name.
Field names are case sensitive.

Example:
  tectoplot -r GR -z
  tectoplot -query eqs.txt csv data latitude magnitude
--------------------------------------------------------------------------------
EOF
  else
    USAGEFLAG=1
  fi
  shift

  if [[ -d $1 ]]; then
    TMP=$(abs_path $1)
    shift
  fi

  # echo "Entered query processing block"
  if [[ ! $tempdirqueryflag -eq 1 ]]; then
    if [[ ! -d ${TMP} ]]; then
      echo "Temporary directory $TMP does not exist"
      exit 1
    else
      # Change into the temporary directory
      cd ${TMP}
    fi
  fi
  query_headerflag=1

  # Search for the specified file within the temporary directory

  if [[ ! -e $1 ]]; then
    # IF the file doesn't exist in the temporary directory, search for it in any
    # subdirectory.
    searchname=$(find . -name $1 -print)
    if [[ -e $searchname ]]; then
      fullpath=$(abs_path $searchname)
      QUERYFILE=$fullpath
      QUERYID=$(basename "$searchname")
      shift
    else
      echo "[-query]: Requested file $1 does not exist within any subdirectory of $(pwd)"
      exit 1
    fi
  else
    QUERYFILE=$(abs_path $1)
    QUERYID=$(basename "$1")
    shift
  fi

  # Search the header information file for the specified filename
  gawk < $TECTOPLOT_HEADERS -F' ' -v key="${QUERYID}" 'BEGIN{OFS="\n"} ($1==key){$1=$1; print $0; exit}' > my.file
  unset headerline
  i=0
  while read p; do
    headerline[$i]="${p}"
    ((++i))
  done < my.file
  rm -f my.file
  unset i

  if [[ -z ${headerline[0]} || ${headerline[0]} != $QUERYID ]]; then
    echo "query ID $QUERYID not found in headers file $TECTOPLOT_HEADERS"
    exit 1
  fi

  if [[ $# -eq 0 ]]; then
    echo "${headerline[@]:1}"
    exit 1
  fi

  while [[ $# -gt 0 ]]; do
    key="${1}"
    case ${key} in
      # If a number, select the field with that number
      [0-9]*)
        keylist+=("$key")
        if [[ "${headerline[$key]}" == "" ]]; then
          fieldlist+=("none")
        else
          fieldlist+=("${headerline[$key]}")
        fi
        ;;
      # Do not print the header
      noheader)
        query_headerflag=0
        ;;
      # Do not print units in the header
      nounits)
        query_nounitsflag=1
        ;;
      # Output fields separated by commas
      csv)
        query_dataflag=1
        query_csvflag=1
        ;;
      # We could add an option to output a GeoJSON format file
      json)
        query_dataflag=1
        query_jsonflag=1
        query_csvflag=1
        query_headerflag=1
        query_nounitsflag=1

        ;;
      # Print the selected data
      data)
        query_dataflag=1
        ;;
      # Print the field number in the header
      fieldnum)
        query_fieldnumberflag=1
        ;;
      # Select a field with the supplied name
      *)
        ismatched=0
        for ((i=1; i < ${#headerline[@]}; ++i)); do
          lk=${#key}
          if [[ "${headerline[$i]:0:$lk}" == "${key}" && "${headerline[$i]:$lk:1}" == "[" ]]; then
            keylist+=("$i")
            fieldlist+=("${headerline[$i]}")
            ismatched=1
          fi
        done
        if [[ $ismatched -eq 0 ]]; then
          echo "[-query]: Could not find field named $key"
          exit 1
        fi
        ;;
    esac
    shift
  done

  # If no fields are selected, then the field list is all fields in the header line
  if [[ ${#fieldlist[@]} -eq 0 ]]; then
    fieldlist=("${headerline[@]:1}")
  fi

  # Figure out how to print fields
  if [[ $query_headerflag -eq 1 ]]; then
    if [[ $query_nounitsflag -eq 1 ]]; then
      if [[ $query_csvflag -eq 1 ]]; then
        echo "${fieldlist[@]}" | sed 's/\[[^][]*\]//g' | tr ' ' ',' > queryheader.out
      else
        echo "${fieldlist[@]}" | sed 's/\[[^][]*\]//g' > queryheader.out
      fi
    else
      if [[ $query_csvflag -eq 1 ]]; then
        echo "${fieldlist[@]}" | tr ' ' ',' > queryheader.out
      else
        echo "${fieldlist[@]}" > queryheader.out
      fi
    fi
    cleanup queryheader.out
  fi


  if [[ $query_jsonflag -eq 1 ]]; then 
    outputfile="query_tmp.csv"
    cleanup query_tmp.csv
  else
    outputfile="/dev/stdout"
  fi

  # Print the field numbers if asked
  if [[ -s queryheader.out && $query_headerflag -eq 1 ]]; then 

    if [[ $query_csvflag -eq 1 ]]; then
      query_sep=","
    else
      query_sep=" "
    fi
    
    gawk < queryheader.out -F"${query_sep}" -v sep="${query_sep}" -v fnf=$query_fieldnumberflag '{
      if (fnf != 1) {
         print $0
      } else {
         for(i=1;i<NF;i++) {
           printf("%s[%s]%s", $(i), i, sep)
         }
        printf("%s[%s]\n", $(NF), NF)
      }
    }' > ${outputfile}
  fi

  # If we are printing the data, do so
  if [[ $query_dataflag -eq 1 ]]; then
    keystr="$(echo ${keylist[@]})"
    gawk < ${QUERYFILE} -v keys="$keystr" -v csv=$query_csvflag '
    BEGIN {
      if (csv==1) {
        sep=","
      } else {
        sep=" "
      }
      numkeys=split(keys, keylist, " ")
      if (numkeys==0) {
        getline
        numkeys=NF
        for(i=1; i<=NF; i++) {
          keylist[i]=i
        }
        for(i=1; i<=numkeys-1; i++) {
          printf "%s%s", $(keylist[i]), sep
        }
        printf("%s\n", $(keylist[numkeys]))
      }
    }
    {
      for(i=1; i<=numkeys-1; i++) {
        printf "%s%s", $(keylist[i]), sep
      }
      printf("%s\n", $(keylist[numkeys]))
    }' >> ${outputfile}
    if [[ $query_jsonflag -eq 1 ]]; then
      ogr2ogr -f GeoJSON -a_srs "EPSG:4326" -oo X_POSSIBLE_NAMES="lon*" -oo Y_POSSIBLE_NAMES="lat*" /vsistdout/ ${outputfile}
    fi
  fi


  exit 1
fi

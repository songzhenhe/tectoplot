#!/usr/bin/env bash

function usage() {
cat<<-EOF
Usage: auto_tectoplot [[noopen]] [[combine]] "shared arguments" "[id1] -arg ..." "[id2] -arg ..." ...
  or
Usage: auto_tectoplot.sh [[noopen]] [[combine]] argument_file

auto_tectoplot.sh runs multiple instances of tectoplot in parallel to create
map layers that can be combined into a PDF or opened using Adobe Illustrator.

[id] tags layer names and are strings not starting with "-" that have no
internal whitespace. Layers that do not have ID tags specified are given default
names of the form "layer_N"

If the "noopen" option is given, suppress opening of intermediate PDF files by
tectoplot.

If the "combine" option is given, a merged PDF will be created from all layers
(requires pdftk). The PDF is stored in combined.pdf and is opened automatically.

An argument string consisting of "wait" will require all prior layers to be
fully completed before running any following commands. This allows direct access
to derived datasets like topo/dem.tif or seismicity/eqs.txt that may take a long
time to initially extract.

argument_file is a plain text file with the first line containing the shared
arguments and the subsequent lines containing each layer argument string.

Example with layer names:
  auto_tectoplot.sh "-r g -RJ W" "topo -t 01d -t0" "seis1 -z -zmag 7"
Example without layer names:
  auto_tectoplot.sh "-r g -RJ W" "-t 01d -t0" "-z -zmag 7" "-c -cmag 8"



EOF
    exit 1
}

if [[ ${#@} -lt 1 ]]; then
  usage
fi

if [[ "${1}" == "noopen" ]]; then
  noopenflag=1
  shift
  if [[ ${#@} -lt 1 ]]; then
    usage
  fi
else
  noopenflag=0
fi

if [[ "${1}" == "combine" ]]; then
  combineflag=1
  shift
  if [[ ${#@} -lt 1 ]]; then
    usage
  fi
else
  combineflag=0
fi

MYTMP=$(mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir')/

if [[ ${#@} -eq 1 ]]; then
  if [[ ! -s "${1}" ]]; then
    echo "Error: Input file does not exist or is empty: ${1}"
    exit 1
  else
    cp "${1}" ${MYTMP}control.txt
  fi
else
  while [[ ${#@} -gt 0 ]]; do
    echo "${1}" >> ${MYTMP}control.txt
    shift
  done
fi

gawk < ${MYTMP}control.txt '
  {
    if (substr($1,0,1) != "#") {
      print
    }
  }' > ${MYTMP}control2.txt

mv ${MYTMP}control2.txt ${MYTMP}control.txt

i=0
noframe=""
cutframe="-cutframe 6"

while read p; do
  if [[ $i -eq 0 ]]; then
    shared_args="${p}"
    # shared_args="${p} -noopen"
  else
    if [[ ${p:0:1} != "-" ]]; then
      layername=$(echo $p | gawk '{print $1}')
      argstring=$(echo $p | gawk '{$1=""; print $0}')
    else
      argstring="${p}"
      layername="layer_${i}"
    fi
    if [[ $layername == "wait" ]]; then
      wait
    else
      if [[ $noopenflag -eq 0 ]]; then
        echo tectoplot ${shared_args} ${argstring} ${noframe} ${cutframe} -o ${layername} -tm ${layername} \&
        tectoplot ${shared_args} ${argstring} ${noframe} ${cutframe} -o ${layername} -tm ${layername} &
      else
        echo tectoplot -noopen ${shared_args} ${argstring} ${noframe} ${cutframe} -o ${layername} -tm ${layername} \&
        tectoplot -noopen ${shared_args} ${argstring} ${noframe} ${cutframe} -o ${layername} -tm ${layername} &
      fi
      # ((i++))
      pslayers+=("${layername}/map.ps")
      noframe="-noframe"
    fi
  fi
  ((i++))
done < ${MYTMP}control.txt

wait

cp ${MYTMP}control.txt ./auto_tectoplot.control.txt

# Currently using pdftk to layer the PDFs onto one page, with the first created
# PDF being the lowermost layer.

if [[ $combineflag -eq 1 ]]; then
  if command -v pdftk > /dev/null; then
    index=1
    for thisps in ${pslayers[@]}; do
      gmt psconvert ${thisps} -Tf -A+m0i -Fout_${index}
      if [[ $index -eq 1 ]]; then
        mv out_${index}.pdf combined.pdf
      else
        pdftk out_${index}.pdf background combined.pdf output underlay.pdf
        mv underlay.pdf combined.pdf
      fi
      ((index++))
    done
    # Clean up intermediate PDFs
    rm -f out_*.pdf
  else
    echo "pdftk not found... not merging PDFs"
  fi
  [[ -s combined.pdf ]] && open combined.pdf
fi

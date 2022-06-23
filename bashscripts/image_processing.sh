# tectoplot

# bashscripts/image_processing.sh
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

### Image processing functions, mostly using gdal_calc.py
### This functions file is sourced by tectoplot

function multiply_combine() {
  if [[ ! -e "${2}" ]]; then
    info_msg "Multiply combine: Raster $2 doesn't exist. Copying $1 to $3."
    cp "${1}" "${3}"
  else
    info_msg "Executing multiply combine of $1 and $2 (1st can be multi-band) . Result=$3."
    gdal_calc.py --overwrite --quiet -A "${1}" -B "${2}" --allBands=A --calc="uint8( ( \
                   (A/255.)*(B/255.)
                   ) * 255 )" --outfile="${3}"
  fi
}

function alpha_value() {
  info_msg "Executing alpha transparency of $1 by factor $2 [0-1]. Result=$3."

  # if [[ $GDAL_VERSION_GT_3_2 -eq 1 ]]; then
  #   gdal_calc.py --overwrite --quiet -A "${1}" --allBands=A --calc="uint8( ( \
  #                  ((A/255.)*(1-${2})+(255/255.)*(${2}))
  #                  ) * 255 )" --outfile="${3}"
  # else
  #   gdal_calc.py --NoDataValue=none --overwrite --quiet -A "${1}" --allBands=A --calc="uint8( ( \
  #                  ((A/255.)*(1-${2})+(255/255.)*(${2}))
  #                  ) * 255 )" --outfile="${3}"
  #   gdal_edit.py -unsetnodata "${3}"
  # fi
  if [[ $(echo "${2} != 0" | bc) -eq 1 ]]; then

    # If nodata is set then any pixel in any band with value==NoData causes the
    # output image to have a NoData pixel. So a saturated color (R=255) kills.
    # Solution is to unset the nodata option before alpha and then reset it
    # to 255 after.
    gdal_edit.py -unsetnodata ${1}
    gdal_calc.py --overwrite --quiet -A "${1}" --allBands=A --calc "uint8( ( \
                  ((A/255.)*(1-${2})+(255/255.)*(${2}))
                  ) * 255 )" --outfile "${3}"
    gdal_edit.py -a_nodata 255 "${3}"
  else
    cp ${1} ${3}
  fi
}

# function alpha_multiply_combine() {
#   info_msg "Executing alpha $2 on $1 then multiplying with $3 (1st can be multi-band) . Result=$3."
#
# }

function lighten_combine() {
  info_msg "Executing lighten combine of $1 and $2 (1st can be multi-band) . Result=$3."
  gdal_calc.py --overwrite --quiet -A "${1}" -B "${2}" --allBands=A --calc="uint8( ( \
                 (A>=B)*A/255. + (A<B)*B/255.
                 ) * 255 )" --outfile="${3}"
}

function lighten_combine_alpha() {
  info_msg "Executing lighten combine of $1 and $2 (1st can be multi-band)at alpha=$3 . Result=$4."
  gdal_calc.py --overwrite --quiet -A "${1}" -B "${2}" --allBands=B --calc="uint8( ( \
                 (A>=B)*(B/255. + (A/255.-B/255.)*${3}) + (A<B)*B/255.
                 ) * 255 )" --outfile="${4}"
}

function darken_combine_alpha() {
  info_msg "Executing lighten combine of $1 and $2 (1st can be multi-band) . Result=$3."
  gdal_calc.py --overwrite --quiet -A "${1}" -B "${2}" --allBands=A --calc="uint8( ( \
                 (A<=B)*A/255. + (A>B)*B/255.
                 ) * 255 )" --outfile="${3}"
}

function weighted_average_combine() {
  if [[ ! -e $2 ]]; then
    info_msg "Weighted average combine: Raster $2 doesn't exist. Copying $1 to $4."
    cp "${1}" "${4}"
  else
    info_msg "Executing weighted average combine of $1(x$3) and $2(x1-$3) (1st can be multi-band) . Result=$4."
    gdal_calc.py --overwrite --quiet -A "${1}" -B "${2}" --allBands=A --calc="uint8( ( \
                   ((A/255.)*(${3})+(B/255.)*(1-${3}))
                   ) * 255 )" --outfile="${4}"
  fi
}

function rgb_to_grayscale() {
  gdal_calc.py  --overwrite --quiet -A "${1}" --A_band=1 -B "${1}" --B_band=2 -C "${1}" \
              --C_band=3 --outfile="${2}" --calc="A*0.2989+B*0.5870+C*0.1140"
}

# Create an alpha mask where all near-black colors (lighter than $3 and A~B~C)
# are set to white, all others are black

function rgb_to_alpha() {
  gdal_calc.py  --overwrite --quiet -A "${1}" --A_band=1 -B "${1}" --B_band=2 -C "${1}" \
  --C_band=3 --outfile="${2}" --calc="uint8( ((A-B<10)*(A-C<10)*(A*0.2989+B*0.5870+C*0.1140)<${3}) * 255.)"
}

# Create an alpha mask from a PNG alpha channel (Band 4)

function png_to_alpha() {
  gdal_calc.py  --overwrite --quiet -A "${1}" --A_band=4 --outfile="${2}" \
  --calc="uint8((A>0)*255.)"
}

# Prints (space separated): raster maximum, mean, minimum, standard deviation
function gdal_stats() {
  gdalinfo -stats "${1}" | grep "Minimum=" | awk -F, '{print $1; print $2; print $3; print $4}' | awk -F= '{print $2}'
}

# Apply a gamma stretch to an 8 bit image
function gamma_stretch() {
  info_msg "Executing gamma stretch of ($1^(1/(gamma=$2))). Output file is $3"
  gdal_calc.py --overwrite --quiet -A "${1}" --allBands=A --calc="uint8( ( \
          (A/255.)**(1/${2})
          ) * 255 )" --outfile="${3}"
}

# Linearly rescale an image $1 from ($2, $3) to ($4, $5) output to $6
function histogram_rescale() {
  gdal_translate -q "${1}" "${6}" -scale "${2}" "${3}" "${4}" "${5}"
}


# Rescale image $1 to remove values below $2% and above $3%, output to $4
function histogram_percentcut_byte() {
  # gdalinfo -hist produces a 256 bucket equally spaced histogram
  # Every integer after the first blank line following the word "buckets" is a histogram value

  cutrange=($(gdalinfo -hist "${1}" | tr ' ' '\n' | awk -v mincut="${2}" -v maxcut="${3}" '
    BEGIN {
      outa=0
      outb=0
      ind=0
      sum=0
      cum=0
    }
    {
      if($1=="buckets") {
        outa=1
        getline # from
        getline # minimum
        minval=$1+0
        getline # to
        getline # maximum:
        maxval=$1+0
      }
      if (outb==1 && $1=="NoData") {
        exit
      }
      if($1=="" && outa==1) {
        outb=1
      }
      if (outb==1 && $1==int($1)) {
        vals[ind]=$1
        cum=cum+$1
        cums[ind++]=cum*100
        sum+=$1
      }
    }
    # Now calculate the percentiles
    END {
      print minval
      print maxval
      for (key in vals) {
        range[key]=(maxval-minval)/255*key+minval
      }
      foundmin=0
      for (key in cums) {
        if (cums[key]/sum >= mincut && foundmin==0) {
          print range[key]
          foundmin=1
        }
        if (cums[key]/sum >= maxcut) {
          print range[key]
          exit
        }
        # print key, cums[key]/sum, range[key]
      }
    }'))
    echo gdal_translate -overwrite -q "${1}" "${4}" -scale "${cutrange[2]}" "${cutrange[3]}" 1 254 -ot Byte
    gdal_translate -overwrite -q "${1}" "${4}" -scale "${cutrange[2]}" "${cutrange[3]}" 1 254 -ot Byte
    gdal_edit.py -unsetnodata "${4}"
}

# If raster $2 has value $3, outval=$4, else outval=raster $1, put into $5
function image_setval() {
  gdal_calc.py --type=Byte --overwrite --quiet -A "${1}" -B "${2}" --calc="uint8(( (B==${3})*$4.+(B!=${3})*A))" --outfile="${5}"
}

# If raster $2 has value above $3, outval=$4, else outval=raster $1, put into $5
function image_setabove() {
  gdal_calc.py --type=Byte --overwrite --quiet -A "${1}" -B "${2}" --allBands=A --calc="uint8(( (B>${3})*$4.+(B<=${3})*A))" --outfile="${5}"
}

# Linearly rescale an image $1 from ($2, $3) to ($4, $5), stretch by $6>0, output to $7
function histogram_rescale_stretch() {
  gdal_translate -q "${1}" "${7}" -scale "${2}" "${3}" "${4}" "${5}" -exponent "${6}"
}

# histogram_rescale_stretch topo/intensity.tif 15.000000 237.000000 0.621513 1 254 2 topo/intensity_cor.tif

# Select cells from $1 within a [$2 $3] value range; else set to $4. Output to $5
function histogram_select() {
   gdal_calc.py --overwrite --quiet -A "${1}" --allBands=A --calc="uint8(( \
           (A>=${2})*(A<=${3})*(A-$4) + $4
           ))" --outfile="${5}"
}

# Select cells from $1 within a [$2 $3] value range; set to $4 if so, else set to $5. Output to $6
function histogram_select_set() {
   gdal_calc.py --overwrite --quiet -A "${1}" --allBands=A --calc="uint8(( \
           (A>=${2})*(A<=${3})*(${4}-${5}) + $5
           ))" --outfile="${6}"
}

function overlay_combine() {
  info_msg "Overlay combining $1 and $2. Output is $3"
  gdal_calc.py --overwrite --quiet -A "${1}" -B "${2}" --allBands=A --calc="uint8( ( \
          (2 * (A/255.)*(B/255.)*(A<128) + \
          (1 - 2 * (1-(A/255.))*(1-(B/255.)) ) * (A>=128))/2 \
          ) * 255 )" --outfile="${3}"
}

# usage: gdal_calc.py [--help] --calc [expression ...] [-a [filename ...]] [--a_band [n ...]] [-b [filename ...]] [--b_band [n ...]] [-c [filename ...]] [--c_band [n ...]] [-d [filename ...]]
#                     [--d_band [n ...]] [-e [filename ...]] [--e_band [n ...]] [-f [filename ...]] [--f_band [n ...]] [-g [filename ...]] [--g_band [n ...]] [-h [filename ...]] [--h_band [n ...]]
#                     [-i [filename ...]] [--i_band [n ...]] [-j [filename ...]] [--j_band [n ...]] [-k [filename ...]] [--k_band [n ...]] [-l [filename ...]] [--l_band [n ...]] [-m [filename ...]]
#                     [--m_band [n ...]] [-n [filename ...]] [--n_band [n ...]]

function white_pixels_combine() {
  # Find the pixels in the first image that are white and outputs a uint8 TIFF with values 1 (white) and 0 (not white)
  gdal_edit.py -unsetnodata ${2}
  gdal_calc.py --overwrite --quiet -A "${2}" --A_band 1 -B "${2}" --B_band 2 -C "${2}" --C_band 3 --calc="uint8( ( \
          ((A==255)*(B==255)*(C==255))*100/255. \
          ) * 255 )" --outfile=whitegrid.tif
  gdal_translate -q -b 1 ${1} grid1band1.tif
  gdal_translate -q -b 2 ${1} grid1band2.tif
  gdal_translate -q -b 3 ${1} grid1band3.tif
  gdal_translate -q -b 1 ${2} grid2band1.tif
  gdal_translate -q -b 2 ${2} grid2band2.tif
  gdal_translate -q -b 3 ${2} grid2band3.tif

# (A>0) means the SECOND input image (the overlay) is white
  gdal_calc.py --overwrite --quiet -A whitegrid.tif --A_band 1 -B grid1band1.tif --B_band 1 -C grid2band1.tif --C_band 1 --calc="uint8( ( \
          (A>0)*B/255. + (A==0)*C/255. \
          ) * 254 )" --outfile=fusedgrid1.tif
          # If the overlay is white, the value will be the base image; otherwise, the overlay
  gdal_calc.py --overwrite --quiet -A whitegrid.tif --A_band 1 -B grid1band2.tif --B_band 1 -C grid2band2.tif --C_band 1 --calc="uint8( ( \
          (A>0)*B/255. + (A==0)*C/255. \
          ) * 254 )" --outfile=fusedgrid2.tif
  gdal_calc.py --overwrite --quiet -A whitegrid.tif --A_band 1 -B grid1band3.tif --B_band 1 -C grid2band3.tif --C_band 1 --calc="uint8( ( \
          (A>0)*B/255. + (A==0)*C/255. \
          ) * 254 )" --outfile=fusedgrid3.tif
  gdal_merge.py -q -separate -o "${3}" fusedgrid1.tif fusedgrid2.tif fusedgrid3.tif
}

function flatten_sea() {
  if [[ -z ${3} ]]; then
    setval=0
  else
    setval=${3}
  fi
  info_msg "Setting DEM elevations less than or equal to 0 to ${setval}"

  gdal_calc.py --overwrite --type=Float32 --quiet -A "${1}" --calc="((A>0)*A + (A<=0)*${setval})" --outfile="${2}"
}

function quickreport() {
  echo "Image report: $1"
  gdalinfo $1 | tail
}

function smooth_rgb_tiff() {
  # Gaussian smoothing of RGB image using gdal VRT tools
  gdalbuildvrt smooth.vrt ${1}

  sed < smooth.vrt | sed -e 's/SimpleSource/KernelFilteredSource/g' -e 's/SimpleSource/KernelFilteredSource/g' | gawk '
  {
    print
    if (substr($1,1,5)=="<DstR") {
      print "    <Kernel normalized=\"1\">"
      print "      <Size>5</Size>"
      print "      <Coefs>"
      print "        0.0036630037 0.0146520147 0.0256410256 0.0146520147 0.0036630037"
      print "        0.0146520147 0.0586080586 0.0952380952 0.0586080586 0.0146520147"
      print "        0.0256410256 0.0952380952 0.1501831502 0.0952380952 0.0256410256"
      print "        0.0146520147 0.0586080586 0.0952380952 0.0586080586 0.0146520147"
      print "        0.0036630037 0.0146520147 0.0256410256 0.0146520147 0.0036630037"
      print "      </Coefs>"
      print "    </Kernel>"
    }
  }' > smooth2.vrt

  gdal_translate smooth2.vrt $2
  rm -f smooth2.vrt smooth.vrt

}


# Create a white TIFF based on input raster

function white_tiff() {

  gdal_calc.py --overwrite --quiet -A "${1}" --A_band=1 --calc  "uint8(254)" --type=Byte --outfile=outA.tif
  # merge the out files
  rm -f "${2}"
  gdal_merge.py -q -co "PHOTOMETRIC=RGB" -separate -o "${2}" outA.tif outA.tif outA.tif
}


# Takes a RGB tiff ${1} and a DEM ${2} and sets R=${3} G=${4} B=${5} for cells where DEM<=0, output to ${6}

function recolor_sea() {

  gdal_calc.py --overwrite --quiet -A "${1}" -B "${2}" --B_band=1 --calc  "uint8(254*((A>0)*B/255. + (A<=0)*${3}/255.))" --type=Byte --outfile=outA.tif
  gdal_calc.py --overwrite --quiet -A "${1}" -B "${2}" --B_band=2 --calc  "uint8(254*((A>0)*B/255. + (A<=0)*${4}/255.))" --type=Byte --outfile=outB.tif
  gdal_calc.py --overwrite --quiet -A "${1}" -B "${2}" --B_band=3 --calc  "uint8(254*((A>0)*B/255. + (A<=0)*${5}/255.))" --type=Byte --outfile=outC.tif

  # merge the out files
  rm -f "${6}"
  gdal_merge.py -q -co "PHOTOMETRIC=RGB" -separate -o "${6}" outA.tif outB.tif outC.tif
}

function is_gmtcpt() {
  gawk -v key=$1 < ${GMTCPTS} '($1==key) { found=1; exit } END { exit (found==1)?0:1 }'
}

# Sets global variable CPT_PATH to the absolute path to a CPT file from
# several possible locations
function get_cpt_path() {
  local cptarg="${1}"
  if [[ -s ${cptarg} ]]; then
    CPT_PATH=$(abs_path ${cptarg})
    info_msg "[-tcpt]: Setting CPT to ${CPT_PATH}"
  elif gmt makecpt -C${cptarg} > /dev/null 2>&1; then
    info_msg "[-tcpt]: CPT ${cptarg} is a builtin GMT CPT."
    CPT_PATH="${cptarg}"
  elif [[ -s ${CPTDIR}${cptarg} ]]; then
    info_msg "[-tcpt]: CPT ${cptarg} is a builtin tectoplot CPT in ${CPTDIR}."
    CPT_PATH=$(abs_path ${CPTDIR}${cptarg})
  elif [[ -s ${CPTDIR}${cptarg}.cpt ]]; then
    info_msg "[-tcpt]: CPT ${cptarg}.cpt is a builtin tectoplot CPT in ${CPTDIR}."
    CPT_PATH=$(abs_path ${CPTDIR}${cptarg}.cpt)
  elif [[ -s ${CPTDIR}colorcet/CET-${cptarg}.cpt ]]; then
    info_msg "[-tcpt]: CET-${cptarg}.cpt is colorcet CPT in ${CPTDIR}/colorcet/"
    CPT_PATH=$(abs_path ${CPTDIR}colorcet/CET-${cptarg}.cpt)
  elif [[ -s ${CPTDIR}colorcet/${cptarg} ]]; then
    info_msg "[-tcpt]: CPT ${cptarg} is colorcet CPT in ${CPTDIR}/colorcet/"
    CPT_PATH=$(abs_path ${CPTDIR}"colorcet/"${cptarg})
  else
    echo "${cptarg} is not a valid CPT"
    CPT_PATH=""
    return 1
  fi
  return 0
}


# This function takes a CPT file in a variety of input formats and turns it
# into a tectoplot standard CPT:
# # any commented line is reproduced as-is


function clean_cpt() {

gawk '{
  if(NR == FNR){
    colors[$1] = $2
  } else {
    if (substr($1,1,1)=="#") {
      print
    } else {

      beforelabel=1
      # Process the CPT lines
      for(i=1;i<=NF;i++) {
        if ($(i)==";") {
          beforelabel=0
        }
        if (beforelabel==1) {
          if ($(i) in colors) {
            $(i)=colors[$(i)]
          }
          # split($(i),j,"/")
          # for(k=1;k<=length(j);k++) {
          #   printf("%s ", j[k])
          # }
        }
        printf("%s ", $(i))
      }
      printf("\n")
    }
  }
}' ${GMTCOLORS} $1
}

# This function reformats an input CPT file to be in r/g/b (or h/s/v) format,
# replacing GMT color names (e.g. seashell4) with r/g/b colors. Comments, BFN,
# and trailing annotation fields are also printed.

# Currently fails if first line is a color name

function replace_gmt_colornames_rgb() {
  gawk '
  BEGIN {
    firstline=0
  }
  {
    if(NR == FNR){
      colors[$1] = $2
    } else {
      if (substr($0,0,1)!="#") {
        firstline++
        if (firstline==1) {
          if (NF==4 || NF==5) {
            format="a/b/c"
          } else if (NF==8 || NF==9) {
            format="a b c"
          } else {
            format="none"
          }
        }

        if (format=="none") {
          print
        } else if (format=="a/b/c") {
          if ($2 in colors) {
            $2=colors[$2]
          }
          if (NF==2) {  # B colorname or B 3/4/5
            print $1 "\t" $2
          } else {
            num1=split($2, c1, "/")
            if (num1 != 3) {
              print("CPT format inconsistent - expecting Z1 A/B/C Z2 A/B/C [N]") > "/dev/stderr"
              exit
            }
            if ($4 in colors) {
              $4=colors[$4]
            } else {
              num2=split($4, c2, "/")
              if (num1 != 3) {
                print("CPT format inconsistent - expecting Z1 A/B/C Z2 A/B/C [N]") > "/dev/stderr"
                exit
              }
            }
            print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5
          }
        } else {
          if (NF==2) {
            if ($2 in colors) {
              $2=colors[$2]
            }
          }
          print $1, $2 "/" $3 "/" $4, $5, $6 "/" $7 "/" $8, $9
        }
      } else {
        print
      }
    }
  }' ${GMTCOLORS} "$1"
}

function gmt_colorname_to_rgb() {
  grep ^"${1} " $GMTCOLORS | head -n 1 | gawk '{print $2}'
}

# This function takes a GMT CPT file in R/G/B format and prints a gdal color
# interval file, respecting the input hinge value. Comments and BFN are removed.

function cpt_to_gdalcolor () {
  if [[ "$2" == "" ]]; then
    gawk < "$1" '{
      if ($1 != "B" && $1 != "F" && $1 != "N" && substr($0,0,1) != "#") {
        print $1, $2
      }
    }' | tr '/' ' ' | gawk '{
      if ($2==255) {$2=254.9}
      if ($3==255) {$3=254.9}
      if ($4==255) {$4=254.9}
      print
    }'
  else
    gawk < "$1" -v hinge="${2}" '{
      if ($1 != "B" && $1 != "F" && $1 != "N" && substr($0,0,1) != "#") {
        if (count==1) {
          print $1+0.01, $2
          count=2
        } else {
          print $1, $2
        }
        if ($3 == hinge) {
          if (count==0) {
            print $3-0.0001, $4
            count=1
          }
        }
      }
    }' | tr '/' ' ' | gawk '{
      if ($2==255) {$2=254.9}
      if ($3==255) {$3=254.9}
      if ($4==255) {$4=254.9}
      print
    }'
  fi
}

# This function takes a clean RGB CPT and scales the z values by the input factor
# Comments, annotation letters, and BFN are preserved.

function scale_cpt() {
  gawk < "${1}" -v scale="${2}" '
  BEGIN {
    firstline=0
  }
  {
    if (substr($0,0,1)!="#") {
      if (NF >2) {
        $1=$1*scale
        $3=$3*scale
        print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5
      } else {
        print
      }
    } else {
      print
    }
  }'
}

function multiply_scale_cpt() {
  gawk < "${1}" -v scale_below="${2}" -v scale_above="${3}" '
  BEGIN {
    firstline=0
  }
  {
    if (substr($0,0,1)!="#") {
      if (NF > 2) {
        scale=($1 < 0)?scale_below:scale_above
        $1=$1*scale
        scale=($3 < 0)?scale_below:scale_above
        $3=$3*scale
        print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $5
      } else {
        print
      }
    } else {
      print
    }
  }'
}


# This function takes a clean RGB CPT (ARG1) and stretches the z values
# between ARG2 and ARG3, keeping the relative spacing between z slices.
# Comments, annotation letters, and BFN are preserved. The zero hinge is
# not respected

# CPT format is
# # comment
# z R/G/B z R/G/B
# B R/G/B
# F R/G/B
# N R/G/B

function rescale_cpt() {
  gawk < "${1}" -v scale_min="${2}" -v scale_max="${3}" '
  @include "tectoplot_functions.awk"
  BEGIN {
    max_z=-9999999
    min_z=9999999
  }
  {
    if ($1+0==$1) {
      max_z=($3>max_z)?$3:max_z
      min_z=($1<min_z)?$1:min_z
      isslice[NR]=1
      slice_minz[NR]=$1
      slice_mincolor[NR]=$2
      slice_maxz[NR]=$3
      slice_maxcolor[NR]=$4
    } else {
      isslice[NR]=0
      nonslice[NR]=$0
    }
  }
  END {
    for(i=1;i<=NR;i++) {
      if (isslice[i]==1) {
        new_minz=rescale_value(slice_minz[i], min_z, max_z, scale_min, scale_max)
        new_maxz=rescale_value(slice_maxz[i], min_z, max_z, scale_min, scale_max)
        print new_minz, slice_mincolor[i], new_maxz, slice_maxcolor[i]
      } else {
        print nonslice[i]
      }
    }
  }'
}

# This function takes a clean CPT (no color words, R/G/B format) and converts it
# to grayscale using the luminosity method

function grayscale_cpt() {
  gawk < "${1}" '
  {
    if ($1+0==$1) {
      split($2,rgb,"/")
      gray1=0.299*rgb[1] + 0.587*rgb[2] + 0.114*rgb[3]
      printf("%s %s/%s/%s ", $1, gray1, gray1, gray1)
      if ($3+0==$3) {
        split($4,rgb,"/")
        gray2=0.299*rgb[1] + 0.587*rgb[2] + 0.114*rgb[3]
        printf("%s %s/%s/%s", $3, gray2, gray2, gray2)
      }
      printf("\n")
    } else {
      print
    }
  }
  '
}

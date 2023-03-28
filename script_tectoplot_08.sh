#!/bin/bash
#
TESTBOXCMD="-F+p+c0"

shopt -s nullglob

SCRIPT_START_TIME="$(date -u +%s)"
last=0

CUSTOMEQCREDIT=""

# NOTE: pscoupe projects onto each profile segment using a local UTM zone
# calculation. This is different than the method used to by mapproject.
# Therefore for long profiles, the focal mechanism X' value may differ for
# these two methods. Perhaps we should use mapproject to get the focal
# mechanism locations and replace the X' values calculated by pscoupe?


# tectoplot
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

source ${TECTOPLOTDIR}tectoplot.version

# Specific issues:
# use gmt mapproject -W to get rectangular region of oblique projections
# use gmtbinstats (6.2)?
# 6.2 changed many -C arguments (grdimage, psmeca, etc)

# July   0,    2021: Added PLY_MAXSIZE=800 to defaults

# CHANGELOG - stopped updating in May

# May    9,    2021: Added -zccluster to profiles, including CMT
#                  : Updated earthquake culling code, fixed eqlabels on profiles
# May    7,    2021: Many updates, added -zctime to profiles, remade git repo
#                  : Updated installation script, miniconda+homebrew install, etc
#                  : Updated -mprof to plot non-topo top tile
# April 30,    2021: Fixed -cc on profiles, cleanup more files in profiles/
# April 29,    2021: Added -bigbar, general fixes
# April 26,    2021: Fixed legend, updated awk->gawk calls, added -checkdeps
# April 25,    2021: Updated profile /legend plotting on map: -legend onmap / -showprof
#                  : Updated mechanisms for -oto
# April 20,    2021: Fixed ANSS scraper to use last day of month, avoid duplicates
# April 10,    2021: Many updates, code reorganization, added -usage details
# March 25,    2021: Added usage (or -usage) option and started to fill in details of commands
#                  : Significant updates to data scraping tools to avoid epoch calculation
# Pi Day,      2021: Added GMT country ID option to -clipon, -clipout, added -clipline, updated -clipoff
#                  : Added full GMT country/continent/etc codes for -r regionID
# March    13, 2021: Moved some AWK functions to library script
#                  : Basic fix for plate models across -180/180 degree meridian
# March    11, 2021: Incorporated smart_swath_update.sh as option -vres
# March    10, 2021: ANSS catalog excludes some anthropogenic events
#                  : Added Ms>Mw, mb>Mw, Ml>Mw conversion rules on ISC/ANSS data import
#                  : Added -tsea flag to recolor sea areas of Sentinel imagery (z<=0)
# March    08, 2021: Added -cprof option including Slab2 cross-strike azimuth
#                  : Added -zdep option to set max/min EQ depths
# March    02, 2021: Bug fixes, updated earthquake selection for 360° maps
#                  : Added -pc option to plot colored plate polygons
# March    01, 2021: Added TEMP/* option for paths which resolves to the absolute ${TMP}/* path
# February 26, 2021: Updated topo visualizations, added grid plotting onto topo, clipping
# February 19, 2021: Added -eventmap option, labels on profiles
# February 17, 2021: Added -r lonlat and -r latlon, and coordinate_parse function
# February 15, 2021: Added -tflat option to set below-sea-level cells to 0 elevation
#                  : Added -topog, -seismo, -sunlit recipes
# February 12, 2021: Large update to terrain visualizations
#                  : Added -rdel, -rlist, and -radd for custom regions
# February 04, 2021: Incomplete rework of DEM/hillshade/etc visualizations
#                    Added -gls to list GPS plates; fixed path to GPS data
# January  22, 2021: Added DEM shadowing option (-shade) in shadow_nc.sh, cleaned up code
# January  13, 2021: Fixed 255>NaN in making topocolor.dat ()
# January  06, 2021: Updated aprofcodes to work with any projection
# January  05, 2021: Fixed SEISDEPTH_CPT issue, added -grid, updated -inset
# January  05, 2021: Added Oblique Mercator (-RJ OA,OC) and updated -inset to show real AOI
# December 31, 2020: Updated external dataset routines (Seis+Cmt), bug fixes
# December 30, 2020: Fixed a bug in EQ culling that dropped earliest seismic events
# December 30, 2020: Added -noplot option to skip plotting and just output data
# December 30, 2020: Updated info_msg to save file, started building subdirectory structure
# December 29, 2020: Updated -inset and -acb to take options
# December 28, 2020: Added aprofcode option to locate scale bar.
# December 28, 2020: Profile width indicators were 2x too wide...! Fixed.
# December 28, 2020: Fixes to various parts of code, added -authoryx, -alignxy
# December 28, 2020: Fixed bug in ANSS scraper that was stopping addition of most recent events
# December 26, 2020: Fixed some issues with BEST topography, updated example script
# December 26, 2020: Added -author, -command options. Reset topo raster range if lon<-180, lon>180 {maybe make a function?}
# December 22, 2020: Significant update to projection options via -RJ. Recalc AOI as needed.
# December 21, 2020: Solstice update (and great confluence) - defined THISP_HS_AZ to get hillshading correct on top tiles
# December 20, 2020: Added -aprof and -aprofcodes options to allow easier -sprof type profile selection
# December 19, 2020: Updated profile to include texture shading for top tile (kind of strange but seems to work...)
# December 18, 2020: Added -tshade option to use Leland Brown's texture shading (added C code in tectoplot dir)
# December 17, 2020: Removed buffering from profile script, as it is not needed and sqlite has annoying messages
# December 17, 2020: Fixed -scale to accept negative lats/lons, creat EARTHRELIEF dir if it doesn't exist on load
# December 17, 2020: Fixed LITHO1 path issue. Note that we need to recompile access_litho if its path changes after -getdata
# December 16, 2020: Fixed issue where Slab2 was not found for AOI entirely within a slab clip polygon
# December 15, 2020: Added -query option and data file headers in {DEFDIR}tectoplot.headers
# December 13, 2020: Testing installation on a different machine (OSX Catalina)
#  Updated -addpath to actually work and also check for empty ~/.profile first
#  Changed tac to tail -r to remove a dependency
# December 13, 2020: Added -zcat option to select ANSS/ISC seismicity catalog
#  Note that earthquake culling may not work well for ISC catalog due to so many events?
# December 12, 2020: Updated ISC earthquake scraping to download full ISC catalog in CSV format
# December 10, 2020: Updated ANSS earthquake scraping to be faster
# December  9, 2020: Added LITHO1.0 download and plotting on cross sections (density, Vp, Vs)
# December  7, 2020: Updated -eqlabel options
# December  7, 2020: Added option to center map on a hypocenter/CMT based on event_id (-r eq EVENT_ID).
# December  7, 2020: Added GFZ focal mechanism scraping / reconciliation with GCMT/ISC
# December  4, 2020: Added option to filter EQ/CMT by magnitude: -zmag
# December  4, 2020: Added CMT/hypocenter labeling by provided list (file/cli) or by magnitude range, with some format options
#                   -eqlist -eqlabel
# December  4, 2020: Added ISC_MIRROR variable to tectoplot.paths to possibly speed up focal mechanism scraping
# December  4, 2020: Major update to CMT data format, scraping, input formats, etc.
#                    We now calculate all SDR/TNP/Moment tensor fields as necessary and do better filtering
# November 30, 2020: Added code to input and process CMT data from several formats (cmt_tools.sh)
# November 28, 2020: Added output of flat profile PDFs, V option in profile.control files
# November 28, 2020: Updated 3d perspective diagram to plot Z axes of exaggerated top tile
# November 26, 2020: Cleaned up usage, help messages and added installation/setup info
# November 26, 2020: Fixed a bug whereby CMTs were selected for profiles from too large of an AOI
# November 26, 2020: Added code to plot -cc alternative locations on profiles and oblique views
# November 25, 2020: Added ability of -sprof to plot Slab2 and revamped Slab2 selection based on AOI
# November 24, 2020: Added code to plot -gdalt style topo on oblique plots if that option is active for the map
# November 24, 2020: Added -msl option to only plot the left half of the DEM for oblique profiles, colocating slice with profile
# November 24, 2020: Added -msd option to use signed distance for profile DEM generation to avoid kink problems.
# November 22, 2020: Added -mob option to set parameters for oblique profile component outputs
# November 20, 2020: Added -psel option to plot only identified profiles from a profile.control file
# November 19, 2020: Label profiles at their start point
# November 16, 2020: Added code to download and verify online datasets, removed SLAB2 seismicity+CMTs
# November 15, 2020: Added BEST option for topography that merges 01s resampled to 2s and GMRT tiles.
# November 15, 2020: Added -gdalt option to use gdal to plot nice hillshade/slope shaded relief, with flexible options
# November 13, 2020: Added -zs option to include supplemental seismic dataset (cat onto eqs.txt)
# November 13, 2020: Fixed a bug in gridded data profile that added bad info to all_data.txt
# November 12, 2020: Added -rect option for -RJ UTM to plot rectangular map (updating AOI as needed)
# November 11, 2020: Added -zcsort option to sort EQs before plotting
# November 11, 2020: Added ability to plot scale bar of specified length centered on lon/lat point
# November 11, 2020: Fixed a bug in ISC focal mechanism scraper that excluded all Jan-April events! (!!!), also adds pre-1976 GCMT/ISC mechanisms, mostly deep focus
# November 10, 2020: Updated topo contour plotting and CPT management scheme
# November  9, 2020: Adjusted GMRT tile size check, added -countries and edited country selection code
# November  3, 2020: Updated GMRT raster tile scraping and merging to avoid several crash issues
# November  2, 2020: Fixed DEM format problem (save as .nc and not .tif). Use gdal_translate to convert if necessary.
# October  28, 2020: Added -tt option back to change transparency of topo basemap
# October  28, 2020: Added -cn option to plot contours from an input grid file (without plotting grid)
# October  24, 2020: Range can be defined by a raster argument to -r option
# October  23, 2020: Added GMRT 1° tile scraping option for DEM (best global bathymetry data)
# October  23, 2020: Added -scrapedata, -reportdates, -recentglobaleq options
# October  21, 2020: Added -oto option to ensure 1:1 vertical exaggeration of profile plot
# October  21, 2020: Added -cc option to plot alternative location of CMT (centroid if plotting origin, origin if plotting centroid)
# October  20, 2020: Updated CMT file format and updated scrape_gcmt and scrape_isc focal mechanism scripts
# October  20, 2020: Added -clipdem to save a ${F_TOPO}dem.tif file in the temporary data folder, mainly for in-place profile control
# October  19, 2020: Initial git commit at kyleedwardbradley/tectoplot
# October  10, 2020: Added code to avoid double plotting of XYZ and CMT data on overlapping profiles.
# October   9, 2020: Project data only onto the closest profile from the whole collection.
# October   9, 2020: Add a date range option to restrict seismic/CMT data
# October   9, 2020: Add option to rotate CMTs based on back azimuth to a specified lon/lat point
# October   9, 2020: Update seismicity for legend plot using SEISSTRETCH

# FUN FACTS:
# You can make a Minecraft landscape in oblique perspective diagrams if you
# undersample the profile relative to the top grid.
# tectoplot -t -aprof HX 250k 5k -mob 130 20 5 0.1
#
# I have finally figured out how to call GMT without plotting anything: gmt psxy -T
# I need to change a few places in the script where I am calling something like psxy/pstext instead
#
# # KNOWN BUGS:
# tectoplot remake seems broken?
# -command and -aprof do not get along
#
# DREAM LEVEL:
# Generate a map_plot.sh script that contains all GMT/etc commands needed to replicate the plot.
# This script would be editable and would quite quickly rerun the plotting as the
# relevant data files would already be generated.
# Not 100% sure that the script is linear enough to do this without high complexity...

# TO DO:
#
# HIGHER PRIORITY:
#
# Litho1 end cap profile needs to go on one end or the other depending on view azimuth
#
# Update legend to include more plot elements
# Update multi_profile to plot data in 3D on oblique block plots? Need X',Y',Z,mag for eqs.
# Add option to plot GPS velocity vectors at the surface along profiles?
#     --> e.g. sample elevation at GPS point; project onto profile, plot horizontal velocity since verticals are not usually in the data
# Add option to profile.control to plot 3D datasets within the box?

# Need to change program structure so that multiple grids can be overlaid onto shaded relief.
# Add option to plot stacked data across a profile swath
# Add option to take a data selection polygon from a plate model?
# add option to plot NASA Blue Marble / day/night images, and crustal age maps, from GMT online server
#
# LOW PRIORITY
#
# add a box-and-whisker option to the -mprof command, taking advantage of our quantile calculations and gmt psxy -E
# Check behavior for plots with areas that cross the Lon=0/360 meridian [general behavior is to FAIL HARD]
# Add option to color/transparentify data based on distance from profile?
#
# Update script to apply gmt.conf at start and also at various other points
# Update commands to use --GMT_HISTORY=false when necessary, rather than using extra tmp dirs
# Add option to plot Euler poles of rotation with confidence ellipses. May need to specify a region or a list of plates, as poles will by anywhere on the globe
# Add color and scaling options for -kg
# Perform GPS velocity calculations from Kreemer2014 ITRF08 to any reference frame
#     using Kreemer2014 Euler poles OR from other data using Model/ModelREF - ModelREF-ITRF08?
# Find way to make accurate distance buffers (without contouring a distance grid...)
# Develop a better description of scaling of map elements (line widths, arrow sizes, etc).
# 1 point = 1/72 inches = 0.01388888... inches

# if ((maxlon < 180 && (minlon <= $3 && $3 <= maxlon)) || (maxlon > 180 && (minlon <= $3+360 || $3+360 <= maxlon)))

# Replacement for tac and tail -r (bad compliance across different systems!)
# Outputs the input file in reverse line order
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

# $1 is the program call, $2 is the file path
function open_pdf() {
  # echo open_pdf $1 $2
  if [[ "${1}" == "wslview" ]]; then
    nohup wslview $(wslpath -w $2) &>/dev/null &
  else
    nohup ${OPENPROGRAM} $1 &>/dev/null &
  fi
}

# Strategy for overlaying map elements on 3D Sketchfab model
# 1. make map with a specific color background, output as TIF
# 2. Create a smoothed OBJ terrain mesh displaced upward by some distance
# 3. Add that map as a texture file
# 4. Convert the map to 0/255 grayscale using background color as 0, 255 otherwise
# 5. Add the alpha image to the Alphamap for the texture

##
# Load

DATAPROCESSINGFLAG=1
BOOKKEEPINGFLAG=1
DATAPLOTTINGFLAG=1

# Check if we mistakenly didn't activate conda in the tectoplot environment and
# if we think so, query and activate

if ! command -v gmt >/dev/null && command -v conda > /dev/null; then
  if [[ -d ${HOME}/miniconda/ ]]; then
    read -r -p "Can't find gmt but conda environment exists. Activate? [y|n] " actresponse
    case $actresponse in
      Y|y|yes|"")
        echo activating...
        eval "$(conda shell.bash hook)"
        conda activate tectoplot
        ;;
      *)
        ;;
    esac
  fi
fi


# Load GMT shell functions
source gmt_shell_functions.sh

# gmt gmtset D_FORMAT "%.12f"

################################################################################
# Define paths and defaults

THISDIR=$(pwd)

GMTREQ="6.2"
GAWKREQ="5"

RJOK="-R -J -O -K"

# TECTOPLOTDIR is where the actual script resides
SOURCE="${BASH_SOURCE[0]}"

if [[ ${SOURCE//[^[:space:]]} ]]; then
    echo "Error: tectoplot script resides in a path containing a space. Out of caution, exiting."
    exit 1
fi

# if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
TECTOPLOTDIR="$(cd -P "$(dirname "$SOURCE")" >/dev/null 2>&1 && pwd )"/


if [[ "${THISDIR}"/ == "${TECTOPLOTDIR}"* ]]; then
  echo "Cannot run tectoplot from a subdirectory of $TECTOPLOTDIR"
  exit 1
fi

DEFDIR=$TECTOPLOTDIR"tectoplot_defs/"

# OPTDIR contains personal definitions (tectoplot.author, tectoplot.regions, etc) that do no

OPTDIR=$TECTOPLOTDIR"tectoplot_opts/"

[[ ! -d ${OPTDIR} ]] && mkdir -p ${OPTDIR}

# These files are sourced using the . command, so they should be valid bash
# scripts but without #!/bin/bash

TECTOPLOT_DEFAULTS_FILE=$DEFDIR"tectoplot.defaults"
TECTOPLOT_PATHS_FILE=$DEFDIR"tectoplot.paths"
TECTOPLOT_PATHS_MESSAGE=$DEFDIR"tectoplot.paths.message"
TECTOPLOT_CPTDEFS=$DEFDIR"tectoplot.cpts"

# These files are personal definitions stored in OPTDIR

TECTOPLOT_AUTHOR=${OPTDIR}"tectoplot.author"

if [[ -s ${OPTDIR}"tectoplot.pdfviewer" ]]; then
  OPENPROGRAM=$(head -n 1 ${OPTDIR}"tectoplot.pdfviewer")
else
  case "$OSTYPE" in
   # cygwin*)
   #    OPENPROGRAM="cmd /c start"
   #    ;;
   linux*)
      OPENPROGRAM_TRY="xdg-open"
      ;;
   darwin*)
      OPENPROGRAM_TRY="open -a Preview"
      ;;
  esac
fi

if ! command -v ${OPENPROGRAM} &> /dev/null; then
    echo "PDF viewing command ${OPENPROGRAM} doesn't work. Setting default based on OS."
    case "$OSTYPE" in
     # cygwin*)
     #    OPENPROGRAM="cmd /c start"
     #    ;;
     linux*)
        OPENPROGRAM_TRY="xdg-open"
        ;;
     darwin*)
        OPENPROGRAM_TRY="open -a Preview"
        ;;
    esac
    if ! command -v ${OPENPROGRAM_TRY} &> /dev/null; then
      echo "Default PDF viewing command ${OPENPROGRAM_TRY} doesn't work."
      openprogramflag=0
    else
      echo ${OPENPROGRAM_TRY} > ${OPTDIR}"tectoplot.pdfviewer"
      openprogramflag=1
    fi
else
  openprogramflag=1
fi

GMTVERSION=$(gmt --version)

GDAL_VERSION_GT_3_2=$(gdalinfo --version | gawk -F, '{split($1, a, " "); if (a[2] > "3.2.0") { print 1 } else { print 0 }}')

if [[ ! -s ${OPTDIR}"tectoplot.dataroot" ]]; then
  echo "/dev/null/" > ${OPTDIR}"tectoplot.dataroot"
  DATAROOT="/dev/null/"
else
  DATAROOT=$(head -n 1 ${OPTDIR}"tectoplot.dataroot")
  if [[ ! -d ${DATAROOT} ]]; then
    echo "Data directory ${DATAROOT} does not exist... using /dev/null/ for safety"
    DATAROOT="/dev/null/"
  fi
fi

CUSTOMREGIONSDIR=$OPTDIR"customregions/"
CUSTOMREGIONS=$CUSTOMREGIONSDIR"tectoplot.customregions"
[[ ! -d ${CUSTOMREGIONSDIR} ]] && mkdir -p ${CUSTOMREGIONSDIR}

################################################################################
# Load CPT defaults, paths, and defaults

if [[ -e "${TECTOPLOT_CPTDEFS}" ]]; then
  source "${TECTOPLOT_CPTDEFS}"
else
  error_msg "CPT definitions file does not exist: $TECTOPLOT_CPTDEFS"
  exit 1
fi

if [[ -e "${TECTOPLOT_PATHS_FILE}" ]]; then
  source "${TECTOPLOT_PATHS_FILE}"
else
  # No paths file exists! Warn and exit.
  error_msg "Paths file does not exist: ${TECTOPLOT_PATHS_FILE}"
  exit 1
fi

if [[ -e "${TECTOPLOT_DEFAULTS_FILE}" ]]; then
  source "${TECTOPLOT_DEFAULTS_FILE}"
else
  # No defaults file exists! Warn and exit.
  error_msg "Defaults file does not exist: ${TECTOPLOT_DEFAULTS_FILE}"
  exit 1
fi

if [[ -e ${TECTOPLOT_COMPILERS_FILE} ]]; then
  source ${TECTOPLOT_COMPILERS_FILE}
fi

# Awk functions are stored here. Necessary for @include
export AWKPATH=${AWKSCRIPTDIR}

# Get rid of gmt.conf as it is likely to mess up our plots
[[ -s ~/gmt.conf ]] && mv ~/gmt.conf ~/gmt.conf.tectoplot.saved

################################################################################
################################################################################
##### FUNCTION DEFINITIONS

# Source various bash functions
source $ARGS_CLEANUP_SH
source $IMAGE_SH
source $TIME_SH
source $DOWNLOAD_DATASETS_SH
source $GEOSPATIAL_SH
source $SEISMICITY_SH
source $INFO_SH
source $GMT_WRAPPERS

FULL_TMP=$(abs_path ${TMP})

##### Set up temporary directory to contain some files before moving to ${TMP}

FILETMP=$(mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir')/



# Set up the source listing files that will be moved to ${TMP}
SHORTSOURCES=${FILETMP}${SHORTSOURCES_FILE}
LONGSOURCES=${FILETMP}${LONGSOURCES_FILE}

touch ${SHORTSOURCES}
touch ${LONGSOURCES}

# Record the command
echo $COMMAND > ${FILETMP}tectoplot.last

INFO_MSG=${FILETMP}${INFO_MSG_NAME}
touch ${INFO_MSG}

################################################################################
# These variables are array indices used to plot multiple versions of the same
# data type and MUST be equal to ZERO at start

cmtfilenumber=0
seisfilenumber=0
usergpsfilenumber=0
cprofnum=0

################################################################################
################################################################################
# MAIN BODY OF SCRIPT

# Startup code that runs every time the script is called
#
# function open_prog() {
#   nohup ${OPENPROGRAM} "${1}" &>/dev/null &
# }

# Declare the associative array of items to be removed on exit
# Those files are declared with the cleanup function

declare -a on_exit_items
declare -a on_exit_move_items

cleanup gmt.conf gmt.history

# DEFINE FLAGS
  calccmtflag=0
  cptdirectflag=0
  defnodeflag=0
  defaultrefflag=0
  doplateedgesflag=0
  dontplottopoflag=0
  euleratgpsflag=0
  eulervecflag=0
  filledcoastlinesflag=0
  gpsoverride=0
  keepopenflag=0
  legendovermapflag=0
  makelegendflag=0
  makegridflag=0
  makelatlongridflag=0
  manualrefplateflag=0
  narrateflag=0
  numslab2inregion=0
  openflag=0
  outflag=0
  outputplatesflag=0
  overplotflag=0
  overridegridlinespacing=0
  platerotationflag=0
  plotcustomtopo=0
  ploteulerobsresflag=0
  plotmag=0
  plotplateazdiffsonly=0
  plotplates=0
  plotshiftflag=0
  plotsrcmod=0
  plottopo=0
  psscaleflag=0
  refptflag=0
  remakecptsflag=0
  replotflag=0
  strikedipflag=0
  svflag=0
  tdeffaultlistflag=0
  tdefnodeflag=0
  twoeulerflag=0
  usecustombflag=0
  usecustomgmtvars=0
  usecustomrjflag=0
  closeglobeflag=0

  clipdemflag=0

  # Flags that start with a value of 1

  openflag=1
  cmtnormalflag=1
  cmtssflag=1
  cmtthrustflag=1
  kinnormalflag=1
  kinssflag=1
  kinthrustflag=1
  normalstyleflag=1
  np1flag=1
  np2flag=1
  platediffvcutoffflag=1

sprofnumber=0

###### The list of things to plot starts empty

plots=()

# Argument arrays that are slurped

customtopoargs=()
imageargs=()
topoargs=()

# The full command is output into the ps file and .history file. We don't
# include the full path to the script anymore.

COMMANDBASE=$(basename $0)
C2=${@}
COMMAND="${COMMANDBASE} ${C2}"

# Load modules by sourcing in their files
#
for f in ${TECTOPLOTDIR}modules/module_*.sh; do
  # echo "Loading module ${f}"
  source "$f"
done

### MODULE DEFAULTS

for this_mod in ${TECTOPLOT_MODULES[@]}; do
  if type "tectoplot_defaults_${this_mod}" >/dev/null 2>&1; then
    cmd="tectoplot_defaults_${this_mod}"
    "$cmd"
  fi
done

# Exit if no arguments are given
if [[ $# -eq 0 ]]; then
  print_usage
  exit 1
fi

# SPECIAL CASE 1: If only one argument is given and it is '-remake', rerun
# the command in file tectoplot.last and exit
if [[ $# -eq 1 && ${1} =~ "-remake" ]]; then
  info_msg "Rerunning last tectoplot command executed in the temporary directory"
  [[ -s ${TMP}tectoplot.last ]] && cat ${TMP}tectoplot.last && source ${TMP}tectoplot.last
  exit 1
fi

# SPECIAL CASE 2: If two arguments are given and the first is -remake, then
# use the first line in the file given as the second argument as the command
if [[ $# -eq 2 && ${1} =~ "-remake" ]]; then
  if [[ ! -e ${2} ]]; then
    error_msg "Error: no file ${2}"
  fi
  head -n 1 ${2} > tectoplot.cmd
  info_msg "Rerunning last tectoplot command from first line in file ${2}"
  cat tectoplot.cmd
  . tectoplot.cmd
  exit 0
fi

if [[ "${@}" =~ "-usage" ]]; then
  USAGEFLAG=1
fi

# SPECIAL CASE 3: If the first argument is -query, OR if the first argument is
# -tm|--tempdir, the second argument is a file, and the third argument is -query,
# then process the query request and exit.
# tectoplot -tm this_dir/ -query seismicity/eqs.txt

if [[ $# -ge 3 && ${1} == "-tm" && ${3} == "-query" ]]; then
  # echo "Processing query request"
  if [[ ! -d ${2} ]]; then
    info_msg "[-query]: Temporary directory ${2} does not exist"
    exit 1
  else
    tempdirqueryflag=1
    cd "${2}"
    shift
    shift
  fi
fi

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
  csv:         print in CSV format
  data:        print data from file
  fieldnum:    print field number in an additional trailing bracket [n]

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

  # First argument to -query needs to be a filename.

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
      exit 1
    fi
  else
    QUERYFILE=$(abs_path $1)
    QUERYID=$(basename "$1")
    shift
  fi

  headerline=($(grep "^$QUERYID" $TECTOPLOT_HEADERS))
  # echo ${headerline[@]}
  if [[ ${headerline[0]} != $QUERYID ]]; then
    echo "query ID $QUERYID not found in headers file $TECTOPLOT_HEADERS"
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
        query_csvflag=1
        ;;
      # Print the selected data
      data)
        query_dataflag=1
        ;;
      # Print the field number in the header
      fieldnumber)
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
    fieldlist=(${headerline[@]:1})
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
  fi

  # Print the field numbers if asked
  [[ -s queryheader.out ]] && gawk < queryheader.out -v fnf=$query_fieldnumberflag '{
    if (fnf != 1) {
      print $0
    } else {
      for(i=1;i<NF;i++) {
        printf("%s[%s] ", $(i), i)
      }
      printf("%s[%s]\n", $(NF), NF)
    }
  }'

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
    }'
  fi
  exit 1
fi

DONTRESETCOMSFLAG=0

##### Look for high priority arguments that need to be executed first
saved_args=( "$@" );
while [[ $# -gt 0 ]]
do
  key="${1}"
  case ${key} in

 -version|--version)
  echo "tectoplot v.${TECTOPLOT_VERSION}"
  exit 0
  ;;

 -ips) # args: file
   overplotflag=1
   PLOTFILE=$(abs_path $2)
   shift
   info_msg "[-ips]: Plotting over previous PS file: $PLOTFILE"
   ;;

  -debug)
    trap 'now=$SECONDS; dur=$(echo "$now - $last" | bc -l); printf "Line $LINENO, time: $dur\n";' DEBUG
    DEBUGFLAG="-debug"
  ;;

  -megadebug)
    PS4=' \e[33m$(date +"%H:%M:%S"): $LINENO ${FUNCNAME[0]} -> \e[0m'
    set -x
    MEGADEBUGFLAG="-megadebug"
    ;;

  -n)
    narrateflag=1
    info_msg "${COMMAND}"
    ;;

  -pss)
    # Set size of the postscript page
    if arg_is_positive_float $2; then
      PSSIZE="${2}"
      shift
    else
      error_msg "[-pss]: PSSIZE $2 is not a positive number."
    fi
    ;;

  -tm)
    TMP="${2}"
    info_msg "[-tm]: Setting temporary directory: ${THISDIR}/${2}"
    shift
    ;;

  -verbose) # args: none
    VERBOSE="-Vd"
    ;;

  esac
  shift

done

if [[ $DONTRESETCOMSFLAG -eq 0 ]]; then
  set -- "${saved_args[@]}"
fi
##### End parse special command line arguments


##### Parse command line arguments that always end with exit

while [[ $# -gt 0 ]]
do
  key="${1}"
  case ${key} in

  -usage)
    USAGEFLAG=1
  ;;

  -history) # Print/search tectoplot history and exit
    if [[ ! $USAGEFLAG -eq 1 ]]; then
      if [[ $2 == "archive" ]]; then
        echo "Archive history? Will overwrite previous archive. [y/n]"
        read -r -p "" response
        case $response in
         y)
           echo "Archiving history to ${OPTDIR}tectoplot.history.archive"
           cp ${OPTDIR}tectoplot.history ${OPTDIR}tectoplot.history.archive
         ;;
        esac
      elif [[ $2 == "delete" ]]; then
        echo "Delete history? [y/n]"
        read -r -p "" response
        case $response in
         y)
           echo "Deleting history from ${OPTDIR}tectoplot.history"
           rm -f ${OPTDIR}tectoplot.history
           touch ${OPTDIR}tectoplot.history
         ;;
        esac
      elif [[ $2 == "restore" ]]; then
        echo "Restore history? Will append archive to current history [y/n]"
        read -r -p "" response
        case $response in
         y)
           echo "Restoring history. Appending to ${OPTDIR}tectoplot.history"
           [[ -s ${OPTDIR}tectoplot.history.archive ]] && cat ${OPTDIR}tectoplot.history.archive >> ${OPTDIR}tectoplot.history
         ;;
        esac
      elif arg_is_integer $2; then
         tail -n $2 ${OPTDIR}tectoplot.history
      elif [[ ! -z $2 ]]; then
         grep -- $2 ${OPTDIR}tectoplot.history
      else
         cat ${OPTDIR}tectoplot.history
      fi
      exit
    fi
  ;;

  -addpath) # Add tectoplot source directory to ~/.profile and exit

    if [[ ! $USAGEFLAG -eq 1 ]]; then
      if [[ ! -e ~/.profile ]]; then
        info_msg "[-addpath]: ~/.profile does not exist. Creating."
      else
        val=$(grep "tectoplot" ~/.profile | gawk  'END{print NR}')
        info_msg "[-addpath]: Backing up ~/.profile file to ${OPTDIR}".profile_old""

        if [[ ! $val -eq 0 ]]; then
          echo "[-addpath]: Warning: found $val lines containing tectoplot in ~/.profile. Remove manually."
        fi
        cp ~/.profile ${OPTDIR}".profile_old"
      fi
      echo >> ~/.profile
      echo "# tectoplot " >> ~/.profile
      echo "export PATH=${TECTOPLOTDIR}:\$PATH" >> ~/.profile
      exit
    fi
    ;;

  -checkdep) # report status of tectoplot dependencies
    if [[ ! $USAGEFLAG -eq 1 ]]; then
      source ${BASHSCRIPTDIR}"test_dependencies.sh" verbose
      exit
    fi
    ;;

  -compile) # compile companion codes
    if [[ ! $USAGEFLAG -eq 1 ]]; then
      echo "Compiling texture shading code in ${TEXTUREDIR}"
      ${TEXTURE_COMPILE_SCRIPT} ${TEXTUREDIR} ${CCOMPILER}

      echo "Compiling Reasenberg declustering tool"
      if [[ -x $(which ${F90COMPILER}) ]]; then
        # This seems to work with OSX gfortran but not with GCC on miniconda/Linux...
        ${F90COMPILER} ${REASENBERG_SCRIPT} -w -std=legacy -o ${REASENBERG_EXEC}
      fi

      echo "Compiling mdenoise"
      if [[ ! -x ${MDENOISE} ]]; then
        echo ${CXXCOMPILER} -o ${MDENOISE} ${MDENOISEDIR}mdenoise.cpp ${MDENOISEDIR}triangle.c
        ${CXXCOMPILER} -o ${MDENOISE} ${MDENOISEDIR}mdenoise.cpp ${MDENOISEDIR}triangle.c
        # ${CXXCOMPILER} -o ${MDENOISE}_svf ${MDENOISEDIR}mdenoise_svf.cpp ${MDENOISEDIR}triangle.c
      fi

      echo "Compiling QRSOLVE"
      if [[ ! -x ${QRSOLVE} ]]; then
        rm -rf ${CSCRIPTDIR}qrsolve/libc/
        rm -rf ${CSCRIPTDIR}qrsolve/include/

        (
        cd ${CSCRIPTDIR}qrsolve/
        mkdir -p ${CSCRIPTDIR}qrsolve/libc/
        mkdir -p ${CSCRIPTDIR}qrsolve/include/
        bash ${CSCRIPTDIR}qrsolve/qr_solve.sh
        bash ${CSCRIPTDIR}qrsolve/r8lib.sh
        bash ${CSCRIPTDIR}qrsolve/test_lls.sh
        bash ${CSCRIPTDIR}qrsolve/gps_solve.sh
        )
      fi

      if [[ -s ${LITHO1FILE} ]]; then

        echo "Compiling LITHO1 extract tool"
        ${CXXCOMPILER} -c ${CSCRIPTDIR}access_litho.cc -DMODELLOC=\"${LITHO1DIR_2}\" -o ${CSCRIPTDIR}access_litho.o
        ${CXXCOMPILER}  ${CSCRIPTDIR}access_litho.o -lm -DMODELLOC=\"${LITHO1DIR_2}\" -o ${LITHO1_PROG}

        echo "Testing LITHO1 extract tool"
        res=$(${LITHO1_PROG} -p 20 20 2>/dev/null | gawk  '(NR==1) { print $3 }')
        if [[ $(echo "$res == 8060.22" | bc) -eq 1 ]]; then
          echo "access_litho returned correct value"
        else
          echo "access_litho returned incorrect result. Deleting executable. Check compiler, paths, etc."
          rm -f ${LITHO1_PROG}
        fi
        exit 0
      else
        echo "LITHO1 file cannot be found at ${LITHO1FILE}. Not compiling access code."
      fi
    fi
    ;;

  # -countryid) # report country ID codes
  #   if [[ ! $USAGEFLAG -eq 1 ]]; then
  #
  #     if arg_is_flag $2; then
  #       gawk -F, < $COUNTRY_CODES '{ print $2, $3, $4 }' | gmt select ${RJSTRING}
  #     else
  #       while ! arg_is_flag $2; do
  #         gawk -F, < $COUNTRY_CODES '{ print $1, $4 }' | grep "${2}"
  #         shift
  #       done
  #     fi
  #
  #     exit
  #   fi
  #   ;;

  -data) # report datasets
    if [[ ! $USAGEFLAG -eq 1 ]]; then
      datamessage
      exit 1
    fi
    ;;

  -defaults) # report defaults
    if [[ ! $USAGEFLAG -eq 1 ]]; then
      defaultsmessage
      exit 1
    fi
    ;;

  -formats) # report data formats
    if [[ ! $USAGEFLAG -eq 1 ]]; then
      formats
      exit 1
    fi
    ;;

  -getdata) # download online datasets
    if [[ ! $USAGEFLAG -eq 1 ]]; then
      narrateflag=1

      # To download a ZIP file:
      # Checks whether the destination file exists within the destination directory and is the right size.
      # If so, skip. If not, check the ZIP file exists and is the right size. If so, unzip check. If not, try to
      # redownload the ZIP file.
      # CHECKFILE path needs to include DESTDIR
      # check_and_download_dataset "IDCODE" $SOURCEURL "yes" $DESTDIR $CHECKFILE $DESTDIR"data.zip" $CHECKFILE_BYTES $ZIP_BYTES

      if [[ "${2}" == "dropbox" || "${2}" == "Dropbox" ]]; then
        shift
        echo "Looking up index of ZIP files on Dropbox..."
        if curl "https://dl.dropboxusercontent.com/s/t8atcpw9dhkamtn/ziplinks_new.txt" | gawk '(substr($1,1,1) != "#"){print}' > ziplinks.txt; then
          while read p; do
              echo "Adding url ${p} to download list"
              dropbox_urls+=("${p}")
          done < ziplinks.txt
        else
          echo "[-getdata dropbox]: Can't download link index file ziplinks.txt from Dropbox"
          exit 1
        fi

        echo "Found the following URLs: ${dropbox_urls[@]}"

        for this_zip in ${dropbox_urls[@]}; do
          zip_name=$(echo $this_zip | gawk -F/ '{print $(NF)}')
          zip_id=$(echo $zip_name | gawk -F. '{print $1}')
          if [[ -d ${DATAROOT}${zip_id} ]]; then
            echo "Folder $zip_id already exists in ${DATAROOT}. Not downloading or extracting ${zip_name}."
            echo "Delete ${DATAROOT}${zip_name} and ${DATAROOT}${zip_id} and call tectoplot -getdata dropbox again to re-download"
          else
            echo "Getting ${zip_name} from Dropbox"
            echo curl "${this_zip}" -o ${DATAROOT}${zip_name}
            if curl "${this_zip}" -o ${DATAROOT}${zip_name}; then
              echo "ZIP file downloaded. Testing extraction."
              if unzip -t ${DATAROOT}${zip_name} >/dev/null; then
                echo "File is OK. Removing potential __MACOSX directories."
                zip -d ${DATAROOT}${zip_name} "__MACOSX*" >/dev/null 2>&1
                if unzip -u ${DATAROOT}${zip_name} -d ${DATAROOT}; then
                  echo "Unzip succeeded."
                  rm -f ${DATAROOT}${zip_name}
                else
                  echo "Unzip operation failed. Removing zip file."
                  rm -f ${DATAROOT}${zip_name}
                fi
              fi
            else
              echo "curl download failed. Removing archive"
              rm -f ${DATAROOT}${zip_name}
            fi
          fi
        done
        exit 0
      else
        # check_and_download_dataset "IDCODE" $SOURCEURL "yes" $DESTDIR $CHECKFILE $DESTDIR"data.zip" $CHECKFILE_BYTES $ZIP_BYTES

        check_and_download_dataset "TimeZoneBuilder" $TIMEZONESHP_SOURCE_URL "yes" ${TIMEZONEDIR} ${TIMEZONESHP} ${TIMEZONEDIR}data.zip ${TIMEZONE_CHECK_BYTES} ${TIMEZONE_ZIP_BYTES}
        check_and_download_dataset "MULLER_OCAGE" $MULLER_OCAGE_SOURCEURL "no" $MULLER_DIR $MULLER_OCAGE "none" $MULLER_OCAGE_BYTES "none"
        check_and_download_dataset "GEBCO1" $GEBCO1_SOURCEURL "yes" $GEBCO1DIR $GEBCO1FILE $GEBCO1DIR"data.zip" $GEBCO1_BYTES $GEBCO1_ZIP_BYTES
        check_and_download_dataset "EMAG_V2" $EMAG_V2_SOURCEURL "no" $EMAG_V2_DIR $EMAG_V2 "none" $EMAG_V2_BYTES "none"
        check_and_download_dataset "WGM2012-Bouguer" $WGMBOUGUER_SOURCEURL "no" $WGMDIR $WGMBOUGUER_ORIG "none" $WGMBOUGUER_BYTES "none"
        check_and_download_dataset "WGM2012-Isostatic" $WGMISOSTATIC_SOURCEURL "no" $WGMDIR $WGMISOSTATIC_ORIG "none" $WGMISOSTATIC_BYTES "none"
        check_and_download_dataset "WGM2012-FreeAir" $WGMFREEAIR_SOURCEURL "no" $WGMDIR $WGMFREEAIR_ORIG "none" $WGMFREEAIR_BYTES "none"

        [[ ! -e $WGMBOUGUER ]] && echo "Reformatting WGM Bouguer..." && gmt grdsample ${WGMBOUGUER_ORIG} -R-180/180/-80/80 -I2m -G${WGMBOUGUER} -fg
        [[ ! -e $WGMISOSTATIC ]] && echo "Reformatting WGM Isostatic..." && gmt grdsample ${WGMISOSTATIC_ORIG} -R-180/180/-80/80 -I2m -G${WGMISOSTATIC} -fg
        [[ ! -e $WGMFREEAIR ]] && echo "Reformatting WGM Free air..." && gmt grdsample ${WGMFREEAIR_ORIG} -R-180/180/-80/80 -I2m -G${WGMFREEAIR} -fg

        check_and_download_dataset "WGM2012-Bouguer-CPT" $WGMBOUGUER_CPT_SOURCEURL "no" $WGMDIR $WGMBOUGUER_CPT "none" $WGMBOUGUER_CPT_BYTES "none"
        check_and_download_dataset "WGM2012-Isostatic-CPT" $WGMISOSTATIC_CPT_SOURCEURL "no" $WGMDIR $WGMISOSTATIC_CPT "none" $WGMISOSTATIC_CPT_BYTES "none"
        check_and_download_dataset "WGM2012-FreeAir-CPT" $WGMFREEAIR_CPT_SOURCEURL "no" $WGMDIR $WGMFREEAIR_CPT "none" $WGMFREEAIR_CPT_BYTES "none"

        # # Change the format of the Slab2 grids so that longitudes go from -180:180
        # # If we don't do this now, some regions will have profiles/maps fail.
        # for slab2file in $SLAB2DIR/*.grd; do
        #   echo gmt grdedit -L $slab2file
        # done

        # check_and_download_dataset "GMT_DAY" $GMT_EARTHDAY_SOURCEURL "no" $GMT_EARTHDIR $GMT_EARTHDAY "none" $GMT_EARTHDAY_BYTES "none"
        # check_and_download_dataset "GMT_NIGHT" $GMT_EARTHNIGHT_SOURCEURL "no" $GMT_EARTHDIR $GMT_EARTHNIGHT "none" $GMT_EARTHNIGHT_BYTES "none"

        # check_and_download_dataset "OC_AGE" $OC_AGE_URL "no" $OC_AGE_DIR $OC_AGE "none" $OC_AGE_BYTES "none"
        # check_and_download_dataset "OC_AGE_CPT" $OC_AGE_CPT_URL "no" $OC_AGE_DIR $OC_AGE_CPT "none" $OC_AGE_CPT_BYTES "none"

        check_and_download_dataset "LITHO1.0" $LITHO1_SOURCEURL "yes" $LITHO1DIR $LITHO1FILE $LITHO1DIR"data.tar.gz" $LITHO1_BYTES $LITHO1_ZIP_BYTES

        check_and_download_dataset "SW2019_GRAV" $SANDWELL2019_SOURCEURL "no" $SANDWELLDIR $SANDWELLFREEAIR "none" $SANDWELL2019_bytes "none"
        check_and_download_dataset "SW2019_CURV" $SANDWELL2019_CURV_SOURCEURL "no" $SANDWELLDIR $SANDWELLFREEAIR_CURV "none" $SANDWELL2019_CURV_bytes "none"

        # Save the biggest downloads for last.
        check_and_download_dataset "GEBCO20" $GEBCO20_SOURCEURL "yes" $GEBCO20DIR $GEBCO20FILE $GEBCO20DIR"data.zip" $GEBCO20_BYTES $GEBCO20_ZIP_BYTES

        check_and_download_dataset "SRTM30" $SRTM30_SOURCEURL "yes" $SRTM30DIR $SRTM30FILE "none" $SRTM30_BYTES "none"
        check_and_download_dataset "SRTM25" $SRTM15_SOURCEURL "yes" $SRTM15DIR $SRTM15FILE "none" $SRTM15_BYTES "none"

        exit 0
      fi
    fi
    ;;

  -h|--help|-help) # print usage information
    if [[ ! ${USAGEFLAG} -eq 1 ]]; then
      print_usage
    	exit 1
    fi
    ;;

  -setup) # print setup information
    if [[ ! $USAGEFLAG -eq 1 ]]; then
      print_setup
      exit 1
    fi
    ;;

  -variables) # print information about variables
    if [[ ! $USAGEFLAG -eq 1 ]]; then
      print_help_header
      print_variables
      exit 1
    fi
    ;;
  esac
  shift
done

set -- "${saved_args[@]}"
##### End command line arguments that always end with exit

# Create the temporary directory and subdirectory structure

if [[ ! ${USAGEFLAG} -eq 1 ]]; then

  OVERLAY=""
  if [[ $overplotflag -eq 1 ]]; then
     info_msg "Overplotting onto ${PLOTFILE} as copy. Ensure base ps is not closed using -keepopenps"
     cp "${PLOTFILE}" "${THISDIR}"/tmpmap.ps
     OVERLAY="-O"
  fi

  if [[ ${TMP::1} == "/" ]]; then
    info_msg "Temporary directory path ${TMP} is an absolute path from root."
    if [[ -d $TMP ]]; then
      info_msg "Not deleting absolute path ${TMP}. Using ${DEFAULT_TMP}"
      TMP=$(abs_path "${DEFAULT_TMP}")
    fi
  else
    if [[ -d $TMP ]]; then
      info_msg "Temp dir $TMP exists. Deleting."
      rm -rf "${TMP}"
    fi
    info_msg "Creating temporary directory $TMP."
  fi

  # Make the temporary directory

  mkdir -p "${TMP}"

  TMP=$(abs_path "${TMP}")

  # Copy the tectoplot command into the temporary directory.
  # Note: this will remove any quotation marks in the command, which can mess up some commands!

  echo $COMMAND > "${TMP}/tectoplot.cmd"

  # Move the messages into the data folder
  [[ -s ${INFO_MSG} ]] && mv ${INFO_MSG} ${TMP}${INFO_MSG_NAME}
  INFO_MSG=${TMP}${INFO_MSG_NAME}

  # Create the subdirectories

  mkdir -p "${TMP}${F_MAPELEMENTS}"
  mkdir -p "${TMP}${F_SEIS}"
  mkdir -p "${TMP}${F_CPTS}"     # Defined in tectoplot.cpts
  mkdir -p "${TMP}${F_TOPO}"
  mkdir -p "${TMP}${F_GRAV}"
  mkdir -p "${TMP}${F_SLAB}"
  mkdir -p "${TMP}${F_PROFILES}"
  mkdir -p "${TMP}${F_GPS}"
  mkdir -p "${TMP}${F_KIN}"
  mkdir -p "${TMP}${F_CMT}"
  mkdir -p "${TMP}${F_PLATES}"
  mkdir -p "${TMP}${F_3D}"
  mkdir -p "${TMP}rasters/"
  mkdir -p "${TMP}legend/"

  LEGENDDIR=$(abs_path "${TMP}legend/")
fi

##### Parse main command line arguments
USAGEFLAG=0  # Reset to 0... if -usage is called it will work again.

while [[ $# -gt 0 ]]
do
  key="${1}"
  case ${key} in

# Options from high priority suite above need to be skipped intelligently
# The options from the above parsing just need to be skipped...?
  -n) # High priority option parsed earlier.
    # none
  ;;

  -addpath) # High priority option parsed earlier.
    # none

  ;;

  -whichutm) # -whichutm: report UTM zone for specified longitude
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-whichutm:      report UTM zone for specified longitude
Usage: -whichutm [longitude]

--------------------------------------------------------------------------------
EOF
  shift && continue
  fi

  if arg_is_float $2; then
    AVELONp180o6=$(echo "(($2) + 180)/6" | bc -l)
    UTMZONE=$(echo $AVELONp180o6 1 | gawk  '{val=int($1)+($1>int($1)); print (val>0)?val:1}')
    echo "UTM Zone for longitude ${2}: ${UTMZONE}"
  fi
  exit 0
  ;;

  -checkdep) # High priority option parsed earlier.
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-checkdep:     check program dependencies
Usage: -checkdep

  Runs tests to check primary dependencies, then exits
--------------------------------------------------------------------------------
EOF
  shift && continue
fi
  ;;

  -colorblind)  # -colorblind: use colorblind-friendlier CPTs from Colorcet or other sources
    if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-colorblind:   use colorblind-friendlier CPTs from Colorcet or other sources
Usage: -colorblind

--------------------------------------------------------------------------------
EOF
shift && continue
fi
  colorblindflag=1
  # Do the required changes now
    SEIS_CPT=${CPTDIR}"colorcet/CET-CBL2.cpt"
    SEIS_CPT_INV="-I"
  ;;

  -compile) # High priority option parsed earlier
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-compile:      compile accompanying codes
Usage: -compile

  Compiles:
    access_litho (C)
    texture_shader (C)
      texture
      sky
      shadow
    reasenberg (Fortran)

--------------------------------------------------------------------------------
EOF
shift && continue
fi
  ;;

#   -countryid) # High priority option parsed earlier
#   if [[ $USAGEFLAG -eq 1 ]]; then
# cat <<-EOF
# -countryid:    print list of recognized country codes and exit
# Usage: -countryid [[string ...]]
#
#   If no argument is given, print all country ID codes. If arguments are given,
#   then print country codes containing each string.
#
#   Exits.
#
# --------------------------------------------------------------------------------
# EOF
#     shift && continue
#   fi
#   ;;

  -data) # High priority option parsed earlier
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-data:         list data source info
Usage: -data

--------------------------------------------------------------------------------
EOF
    shift && continue
  fi
  ;;

  -defaults) # High priority option parsed earlier
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-defaults:     print tectoplot defaults
Usage: -defaults

--------------------------------------------------------------------------------
EOF
shift && continue
fi
  ;;

  -formats) # High priority option parsed earlier
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-formats:      print information about file formats (input and output) and exit
Usage: -formats

--------------------------------------------------------------------------------
EOF
  shift && continue
  fi
  ;;

  -getdata) # High priority option parsed earlier
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-getdata:      download datasets and compile c / Fortran programs
Usage: -getdata

    This option will attempt to download and minimally process data files.
    It will download files or compressed archives and verify the expected byte
    count. If the byte count is wrong due to updates, the download may fail.
    The function will extract archives and will try to redownload data if it
    is not marked as complete. Several basic C programs are compiled using gcc.

--------------------------------------------------------------------------------
EOF
shift && continue
  fi
  ;;

  -ips) # High priority option parsed earlier
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ips:          plot over an existing, non-closed ps file
Usage: -ips [filename]

 Complex or multi-component maps can be created by calling tectoplot with the
 -keepopenps option, which prevents closing of the Postscript file. The -ips
 option can then be used to load that PS file and plot over it. The refrence
 point of the second map can be shifted using the -pos option.

 The input PS file can be inside the temporary directory as it is copied before
 the temporary directory is deleted.

 To avoid overwriting map components, use the -tm option to name different
 temporary directories.

Example: Plot a two-panel map.
tectoplot -r PA -a -inset 1i 30 4i 0.15i -keepopenps
tectoplot -r PA -t -ips tempfiles_to_delete/map.ps -pos 0i 3.7i -o example_ips
ExampleEnd
--------------------------------------------------------------------------------
EOF
  shift && continue
  fi
  while ! arg_is_flag $2; do
    shift
  done


  ;;

  -query)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-query:        print information from data files in temp directory
-query
--------------------------------------------------------------------------------
EOF
shift && continue
  fi
  while ! arg_is_flag $2; do
    shift
  done
  ;; # High priority option parsed earlier

  -setup) # High priority option parsed earlier
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-setup:        print setup information and exit
-setup
--------------------------------------------------------------------------------
EOF
shift && continue
  fi
  ;;

  -variables) # High priority option parsed earlier
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-variables:    print information about tectoplot variables
-variables
--------------------------------------------------------------------------------
EOF
shift && continue
  fi
  ;;

  -usage) # High priority option parsed earlier
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-usage:        basic description of tools
Usage: -usage   [command containing any number of -flags and arguments]
Usage: -usage   [all|what|args]
Usage: -usage   [topo]

Print explanations of options, arguments, and outputs for commands.

General:
 all:  Print usage messages for all commands
 what: Print short descriptions of commands
 args: Print information about arguments, for all commands

Collections of related commands:
 topo: Print short descriptions of topo-related commands

Outputs:
 None

EOF
fi
USAGEFLAG=1

 if [[ $2 == "vars" ]]; then
   USAGEVARSFLAG=1
   shift
 fi

 if [[ $2 =~ "all" ]]; then
   shift
   SCRIPTFILE="${BASH_SOURCE[0]}"
   # COMMANDLIST=$(grep "^-" ${SCRIPTFILE} | grep -v -- "---" | gawk '(substr($1,length($1),1) != ":" && substr($1,length($1),1) != ")") { print $1 }' | uniq | sort -f)

   # grep "^-" ${SCRIPTFILE} | grep -v -- "---" | gawk '(substr($1,length($1),1) != ":" && substr($1,length($1),1) != ")") { print $1 }' > commandlist.txt

     grep "^-" ${SCRIPTFILE} | grep -v -- "---" | gawk '{ if (substr($1,length($1),1) == ":") {print substr($1,1,length($1)-1) }}' > commandlist.txt

   # COMEBACK turned off for webpage development to skip modules for now
   # Uncomment!
   # for f in ${TECTOPLOTDIR}modules/module_*.sh; do
   #   grep "^-" ${f} | grep -v -- "---" | gawk '{ if (substr($1,length($1),1) == ":") {print substr($1,1,length($1)-1) }}' >> commandlist.txt
   # done

   COMMANDLIST=$(cat commandlist.txt | uniq | sort -f)

   echo "tectoplot commands:"
   echo ${COMMANDLIST[@]} | fold -s
   echo "end tectoplot commands"
   echo "--------------------------------------------------------------------------------"
   set -- "blank" ${COMMANDLIST[@]}
   DONTRESETCOMSFLAG=1
 elif [[ $2 =~ "what" ]]; then
   shift
   SCRIPTFILE="${BASH_SOURCE[0]}"
   grep "^-" ${SCRIPTFILE} | grep -v -- "---" | gawk '(substr($1,length($1),1) == ":") { print }' | uniq | sort -f

   echo "Modules:"
   for f in ${TECTOPLOTDIR}modules/module_*.sh; do
     echo "$(basename ${f}):"
     grep "^des " ${f} | cut -f2- -d ' ' | gawk '{ $1=sprintf("%s:", $1); print }' | uniq | sort -f
   done
   exit
 elif [[ $2 =~ "args" ]]; then
   shift
   SCRIPTFILE="${BASH_SOURCE[0]}"
   grep "^-" ${SCRIPTFILE} | grep -v -- "---" | gawk '(substr($1,length($1),1) != ":" && substr($1,length($1),1) != ")") { print }' | uniq | sort -f > ./tectoplot.tmp.file
   rm -f ./tectoplot.tmp2.file
   while read p; do
     echo $(eval "echo ${p}") >> ./tectoplot.tmp2.file
   done < ./tectoplot.tmp.file
   gawk < ./tectoplot.tmp2.file '{$1 = sprintf("%-16s", $1); print }'
   rm -f ./tectoplot.tmp.file ./tectoplot.tmp2.file
   exit
 elif [[ $2 =~ "topo" ]]; then
   shift
   usageskipflag=1
   COMMANDLIST=($(echo "-t -t -ti -ts -tr -tc -tx -tt -clipdem -tflat -tshad -ttext -tmult -tuni -tsky -tgam -timg -tsent -tblue -tsent -tunsetflat -tsea -tclip -tsave -tload -tdelete -tn -tquant -tca"))
   echo topo commands: ${COMMANDLIST[@]} | fold -s
   echo "--------------------------------------------------------------------------------"
   set -- "blank" ${COMMANDLIST[@]}
   DONTRESETCOMSFLAG=1
 elif [[ $2 =~ "module" ]]; then
   shift
   usageskipflag=1

   while ! arg_is_flag $2; do
     MODULE_NAME=$2
     shift
     if [[ -s ${TECTOPLOTDIR}modules/module_${MODULE_NAME}.sh ]]; then
       m_commands=($(gawk < ${TECTOPLOTDIR}modules/module_${MODULE_NAME}.sh '{print $1}' | grep "^[-].*)$" | tr ')' '\0'))
       m_commands_2+=($(echo ${m_commands[@]} | tr ' ' '\n' | sort))
     fi
   done
   set -- "blank" ${m_commands_2[@]}
 else
   # Assume we will read flags one by one

   usageskipflag=1
   echo "--------------------------------------------------------------------------------"
 fi

  ;;

  -tm) # High priority option parsed earlier
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tm:           define a custom temporary results directory
Usage: -tm [directory_path]

--------------------------------------------------------------------------------
EOF
shift && continue
fi
  shift
  ;;

  -recenteq) # -recenteq: plot earthquakes that occurred recently
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-recenteq:     plot earthquakes that occurred recently
Usage: -recenteq      [[number_of_days=${LASTDAYNUM}]] [[print]]

  Sets options -a a -z -c -time date1 date2 where date1 is number_of_days ago
  and date2 is current date and time (both in UTC).
  Specification of -r is required, or the default region will be used.

Example: Plot last 1 month of earthquakes in USA
tectoplot -r US -t 01d -recenteq 31 -o example_recenteq
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi


  if arg_is_flag $2; then
    info_msg "[-recenteq]: No day number specified, using last 7 days"
  else
    info_msg "[-recenteq]: Using start of day ${2} days ago to end of today"
    LASTDAYNUM="${2}"
    shift
  fi

  # Turn on time select
  timeselectflag=1
  STARTTIME=$(date_shift_utc -${LASTDAYNUM} 0 0 0)
  ENDTIME=$(date_shift_utc)    # COMPATIBILITY ISSUE WITH GNU date
  shift
  set -- "blank" "-a" "a" "-z" "-c" "-time" "${STARTTIME}" "${ENDTIME}" "$@"
  ;;

  -latesteqs)
  LATESTEQSORTTYPE="mag"
  if arg_is_flag $2; then
    info_msg "[-latesteqs]: No day number specified, using last 7 days"
  else
    info_msg "[-latesteqs]: Using start of day ${2} days ago to end of today"
    LASTDAYNUM="${2}"
    shift
  fi
  if arg_is_flag $2; then
    info_msg "[-latesteqs]: No sort type specified. Using ${LATESTEQSORTTYPE}"
  else
    if [[ $2 =~ "date" || $2 =~ "mag" ]]; then
      LATESTEQSORTTYPE="${2}"
    fi
    shift
  fi

  timeselectflag=1
  recenteqprintandexitflag=1
  STARTTIME=$(date_shift_utc -${LASTDAYNUM} 0 0 0)
  ENDTIME=$(date_shift_utc)    # COMPATIBILITY ISSUE WITH GNU date
  shift
  set -- "blank" "-r" "g" "-z" "-time" "${STARTTIME}" "${ENDTIME}" "$@"
  ;;

  -seismo)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-seismo:       plot a basic seismotectonic map
Usage: -seismo

  Plot a basic seismotectonic map for a region using default options
  Sets options -t -b c -z -c
  Specification of -r is required, or the default region will be used.

Example: Plot a seismotectonic map of Iran
tectoplot -r IR -seismo -o example_seismo
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    shift
    set -- "blank" "-t" "-b" "c" "-z" "-c" "$@"
    ;;

  -topo)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-topo:        plot a basic topographic map
Usage: -topo
  Plot a basic topographic map for a region and make an oblique view
  Sets options -t -ob 45 20 3
  Specification of -r is required, or the default region will be used.
  The oblique view PDF is stored in \${TMP}/oblique.pdf and script to adjust
  is in \${TMP}/make_oblique.sh [vexag] [az] [inc]

Example: Plot a topographic map
tectoplot -topo -o example_topo
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    shift
    set -- "blank" "-t" "-t0" "-ob" "45" "20" "3" "$@"
    ;;

    -topoprof)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-topoprof:     plot -t0 topo with a single topo profile, with scale and inset
Usage: -topoprof [aprofcodes] [[scalelength]]

Example: Plot a topographic map of Ryukyu
tectoplot -r CH -topoprof
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  aprofcode=$2
  shift

  if ! arg_is_flag $2; then
    scalelen="length $2"
    shift
  else
    scalelen=""
  fi

  shift
  set -- "blank" "-t" "-t0" "-tr" "-scale" ${scalelen} "inlegend" "horz" "-aprof" "${aprofcode}" "50k" "1k" "-inset" "topo" "size" "1.5i" "onmap" "BL" "-legend" "onmap" "TL" "-showprof" "all" "-RJ" "B" "-rect" "$@"
  ;;

    -tgl) # -tgl: recipe for slopeshade terrain visualization
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tgl:          recipe for blue ocean and white land shaded relief
Usage: -tgl

  Plot topography using a white color stretch for land

Example: Slopeshade map
tectoplot -t -t0 -o example_t0
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    topoctrlstring="msg"
    useowntopoctrlflag=1
    fasttopoflag=0
    SLOPE_FACT=0.5
    HS_GAMMA=1.4
    HS_ALT=45
    shift

    set -- "blank" "-tmult" "-tsl" "-tcpt" "grayland" -tca "0.3" "$@"
    ;;

  -sunlit)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-sunlit:       plot topo with unidirectional hillshade and cast shadows
Usage: -sunlit

  Plot a basic topographic map for a region with cast shadows, and oblique view
  Sets options -t -tuni -tshad -ob 45 20 3
  Specification of -r is required, or the default region will be used.
  The oblique view PDF is stored in \${TMP}/oblique.pdf and script to adjust
  is in \${TMP}/make_oblique.sh [vexag] [az] [inc]

Example: Plot a topographic map of Switzerland with cast shadows
tectoplot -r CH -sunlit -o example_sunlit
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    shift
    set -- "blank" "-t" "-tuni" "-tshad" "-ob" "45" "20" "3" "$@"
    ;;

-veryclosereport)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-closereport:       create a very local report map for a given earthquake
Usage: -veryclosereport [earthquake_id]
--------------------------------------------------------------------------------
EOF
shift && continue
fi
      EQID=$2
      shift
      start_time="1970-01-01"
      end_time=$(date -u +"%Y-%m-%d")
      if ! arg_is_flag $2; then
        start_time=$2
        shift
      fi
      if ! arg_is_flag $2; then
        end_time=$2
        shift
      fi
      SENTINEL_TYPE="s2cloudless-2019"
      SENTINEL_FACT=0.5

      touch ./sentinel_img.jpg
      sentineldownloadflag=1

      set -- "blank" "-timeme" "-r" "eq" "${EQID}" "5k" "-RJ" "UTM" "-rect" \
            "-t" "-t0" "-timg" "img" "sentinel_img.jpg" "0.3" \
            "-ob" \
            "-z" "1" "50" "-zmag" "2" "-zline" "0" "-zcat" "ANSS" "ISC" "GHEC" "-ztarget" "${EQID}" "-zcsort" "mag" "down" \
            "-legend" "onmap" "BR" "BL" "horiz" "bars" \
            "-inset" "country" "offmap" "RT" "degw" "5" "size" "2.5i" "args" "\"-z -zcat ${F_SEIS}eqs_highlight.txt -zhigh ${EQID} \"" \
            "-aosm" "fixdem" "color" "black" "width" "0.25p"  \
            "-pp" "label" "1" "fill" "black" "font" "10p,Helvetica-Bold,black" \
            "-scale" "inlegend" "horz" "length" "2k" "divs" "4" "skiplabel" "5" "height" "20" \
            "-zbox" "${EQID}" "-zhigh" "${EQID}" \
            "-preview" "300" \
            "-tpct" "1" "99"
;;

-closereport)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-closereport:       create a local report map for a given earthquake
Usage: -closereport [earthquake_id]
--------------------------------------------------------------------------------
EOF
shift && continue
fi
      EQID=$2
      shift
      start_time="1970-01-01"
      end_time=$(date -u +"%Y-%m-%d")
      if ! arg_is_flag $2; then
        start_time=$2
        shift
      fi
      if ! arg_is_flag $2; then
        end_time=$2
        shift
      fi
      SENTINEL_TYPE="s2cloudless-2019"
      SENTINEL_FACT=0.5

      touch ./sentinel_img.jpg
      sentineldownloadflag=1

      set -- "blank" "-timeme" "-r" "eq" "${EQID}" "50k" "-RJ" "UTM" "-rect" \
            "-t" "-t0" "-timg" "img" "sentinel_img.jpg" "0.3" \
            "-ob" \
            "-z" "1" "50" "-zmag" "2" "-zline" "0" "-zcat" "ANSS" "ISC" "GHEC" "-ztarget" "${EQID}" "-zcsort" "mag" "down" \
            "-legend" "onmap" "BR" "BL" "horiz" "bars" \
            "-inset" "country" "offmap" "RT" "degw" "20" "size" "2.5i" "args" "\"-z -zcat ${F_SEIS}eqs_highlight.txt -zhigh ${EQID} \"" \
            "-aosm" "fixdem" "color" "black" "width" "0.25p"  \
            "-pp" "label" "1" "fill" "black" "font" "10p,Helvetica-Bold,black" \
            "-scale" "inlegend" "horz" "length" "20k" "divs" "4" "skiplabel" "5" "height" "20" \
            "-zbox" "${EQID}" "-zhigh" "${EQID}" \
            "-preview" "300" \
            "-arrow" "wide" \
            "-tpct" "1" "99"
;;

-report)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-report:       create a report map for a given earthquake
Usage: -report [earthquake_id]
--------------------------------------------------------------------------------
EOF
shift && continue
fi
      EQID=$2
      shift
      start_time="1970-01-01"
      end_time=$(date -u +"%Y-%m-%d")
      if ! arg_is_flag $2; then
        start_time=$2
        shift
      fi
      if ! arg_is_flag $2; then
        end_time=$2
        shift
      fi

      set -- "blank" "-timeme" "-r" "eq" "${EQID}" "750k" "-RJ" "UTM" "-rect" \
            "-t" "GEBCO20" "-t0" \
            "-b" \
            "-af" \
            "-p" "MORVEL" "-pf" "300" "-i" "2" \
            "-z" "1" "50" "-zmag" "3.5" "10" "-zline" "0" "-zcat" "ANSS" "ISC" "GHEC" "-ztarget" "${EQID}" "-zcsort" "mag" "down" \
            "-seistimeline_c" "${start_time}" "today" "4" \
            "-seistimeline_eq" "${EQID}" "30" \
            "-noframe" "right" \
            "-legend" "onmap" "BR" "BL" "horiz" "bars" \
            "-inset" "country" "offmap" "BR" "xoff" "9.5" "yoff" "-1" "degw" "90" "size" "2.7i" "args" "\"-z -zcat ${F_SEIS}eqs_highlight.txt -zhigh ${EQID} \"" \
            "-pe" \
            "-pa" "notext" \
            "-aosm" "fixdem" "color" "black" "width" "0.25p"  \
            "-pl" "13p,Bookman-Demi,black"  \
            "-pp" "min" "100000" "bin" "5" "label" "1" "fill" "black" "outline" \
            "-scale" "inlegend" "horz" "length" "250k" "divs" "5" "skiplabel" "75" "height" "20" \
            "-zbox" "${EQID}" "-zhigh" "${EQID}" \
            "-cprof" "eq" "eq" "slab2" "1000" "2k" "-pw" "50k" "-oto" "change_h" "-proftopo" "-profdepth" "-250" "10" "-showprof" "all" \
            "-preview" "300" \
            "-arrow" "wide" \
            "-tpct" "1" "99"

            # "-tcycle" "num" "10"
            # "-time" "eq" "${EQID}" "30" \

    ;;

  -eventmap)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-eventmap:     plot an earthquake summary map using a USGS event code
Usage: -eventmap [earthquakeID] [[degrees]] [[options]]

  degrees is the width/height of the map centered on the event

  options:
  deg [degrees]      define width/height of AOI
  mmi                plot colored contours of MMI using the USGS color scheme
  topo [dataset]     plot topography; dataset is argument to -t

  Plot a basic seismotectonic map and cross section centered on an earthquake
  Includes topography, Slab2.0, seismicity, focal mechanisms (ORIGIN location).
  Labels the selected earthquake on map and cross-section.
  Plots a 1:1 (V=H) E-W profile, or orients the profile along the dip-direction
  if a Slab2.0 grid exists beneath the event.
  Plots a legend and sets the title to the earthquake ID.

Example: Plot a seismotectonic map of the M7.8 2015 Gorkha, Nepal earthquake
tectoplot -eventmap us20002926 -o example_eventmap
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if arg_is_flag $2; then
      info_msg "[-eventmap]: Needs earthquakeID"
      exit 1
    else
      EVENTMAP_ID=$(eq_event_parse "${2}")
      shift
    fi
    EVENTMAP_DEGBUF=2
    EVENTMAP_TOPO="SRTM30"
    shift
    while ! arg_is_flag $1; do
      case $1 in
        deg)
          shift
          if arg_is_positive_float $1; then
            EVENTMAP_DEGBUF="${1}"
            shift
          else
            echo "[-eventmap]: deg option requires positive float argument"
            exit 1
          fi
          ;;
        topo)
          shift
          if ! arg_is_flag $1; then
            EVENTMAP_TOPO="${1}"
            shift
          else
            echo "[-eventmap]: topo option requires topo datset argument"
          fi
          ;;
        mmi)
          EVENTMAP_MMI=("-mmi", ${EVENTMAP_ID})
          shift
          ;;
        *)
          echo "[-eventmap]: unrecognized option ${2}"
          exit 1
        ;;
      esac
    done

    set -- "blank" "-r" "eq" "usgs" ${EVENTMAP_DEGBUF} "-usgs" "${EVENTMAP_ID}"  "-t" "${EVENTMAP_TOPO}" "-t0" "-b" ${EVENTMAP_APROF[@]} "-z" "-zcat" "usgs" "ANSS" "ISC" "-zcrescale" "2"  "-c" "-ccat" "usgs" "GCMT" ${EVENTMAP_MMI[@]} "-eqlist" "{" "${EVENTMAP_ID}" "}" "-eqlabel" "list" "datemag" "-legend" "onmap" "-inset" "topo" "1i" "45" "0.1i" "0.1i" "-oto" "change_h" "$@"
    # echo $@
    ;;

  -mmi) # args: eventID
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-mmi:         plot Shakemap MMI contours for USGS event
Usage: -mmi [eventID] [[eventID2 ...]] [[grid]] [[label color]]

  eventIDs are ANSS ID codes
  If eventID is a path to an existing ZIP file, use that instead of downloading.

  Options:
  grid             Plot the MMI raster beneath the contours
  label [color]    Change the color of the contour label text
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  MMI_LABELCOLOR="black"
  while ! arg_is_flag $2; do
    case $2 in
      grid)
        MMI_PLOTGRID=1
        shift
      ;;
      clip)
        MMI_CLIPGRID=1
        shift
      ;;
      label)
        shift
        if ! arg_is_flag $2; then
          MMI_LABELCOLOR="${2}"
          shift
        else
          echo "[-mmi]: label option requires color argument"
          exit 1
        fi
      ;;
      *)
        if [[ -s ${2} ]]; then
          MMI_EVENTID+="$(abs_path ${2})"
        else
          MMI_EVENTID+=("${2}")
        fi
        shift
      ;;
    esac
  done
  plots+=("mmi")
  ;;

  -af) # args: string string
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-af:           plot global earthquake model (gem) active faults
Usage: -af [[line width=${AFLINEWIDTH}]] [[line color=${AFLINECOLOR}]]

Example: Plot a map of GEM active faults around India
tectoplot -r IN -a -af 0.5p red -o example_af
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if arg_is_flag $2; then
      info_msg "[-af]: No line width specified. Using $AFLINEWIDTH"
    else
      AFLINEWIDTH="${2}"
      shift
      if arg_is_flag $2; then
        info_msg "[-af]: No line color specified. Using $AFLINECOLOR"
      else
        AFLINECOLOR="${2}"
        shift
      fi
    fi
    plots+=("gemfaults")
    ;;

  -alignz)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-alignz:      Allow profiles to be aligned in Z value at XY line intersection
Usage: -alignz [filename]

  Use -alignxy to set the intersection line.

Example: Stack topographic profiles across SE Indian continental margin
echo "80 16" > line.xy && echo "88 22" >> line.xy
tectoplot -r IN -t 01m -alignxy line.xy -aprof QM LH 20k 1k -alignz -showprof all -o example_alignz
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  PROFILE_ALIGNZ="0"
  ;;

  -alignxy)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-alignxy:      align profiles to intersection with xy (lon lat) path
Usage: -alignxy [filename]

Example: Stack topographic profiles across SE Indian continental margin
echo "80 16" > line.xy && echo "88 22" >> line.xy
tectoplot -r IN -t 01m -alignxy line.xy -aprof QM LH 20k 1k -showprof all -o example_alignxy
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    if arg_is_flag $2; then
      info_msg "[-alignxy]: No XY dataset specified. Not aligning profiles."
    else
      ALIGNXY_FILE=$(abs_path $2)
      shift
      if [[ ! -e $ALIGNXY_FILE ]]; then
        info_msg "[-alignxy]: XY file $ALIGNXY_FILE does not exist."
      else
        info_msg "[-alignxy]: Aligning profiles to $ALIGNXY_FILE."
        if [[ ${ALIGNXY_FILE} == *".kml" ]]; then
          kml_to_first_xy ${ALIGNXY_FILE} profile_align.xy
          ALIGNXY_FILE=$(abs_path profile_align.xy)
        fi
        alignxyflag=1
      fi
    fi
    ;;

  -bigbar)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-bigbar:       plot a single large colorbar beneath the map
Usage: -bigbar [cpt_name] [["Explanation string"]]
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  if ! arg_is_flag ${2}; then
    BIGBARCPT=${2}
    shift
  fi
  if ! arg_is_flag ${2}; then
    BIGBARANNO=${2}
    shift
  fi
  if ! arg_is_flag ${2}; then
    BIGBARLOW=${2}
    shift
  fi
  if ! arg_is_flag ${2}; then
    BIGBARHIGH=${2}
    shift
  fi
  plotbigbarflag=1
    ;;

  -cprof) # args lon lat azimuth(degrees) length(km) width(km) res(km)

  # Should take arguments in the form lon lat az 100k 10k 20k
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-cprof:        specify automatic profiles using center point, azimuth, length
Usage: -cprof [centerlon or "eq"] [centerlat or "eq"] [azimuth or "slab2"] [length] [resolution] [[flip]]

  [centerlon]/[centerlat] are coordinates at profile center (degrees)
    eq = use earthquake ID location
  [azimuth] is profile azimuth (CW from north, degrees)
    slab2 = use slab2 down-dip direction
  [length] is profile length in km (no units specified on command line)
  [width] is profile swath width with k units specified (e.g. 25k)
  [resolution] is sampling resolution with k units specified (e.g 1k)

  [[flip]] option will flip the orientation of the input line

Example: Create a topographic swath profile across the Straits of Gibraltar
tectoplot -r -6.5 -4.5 35 37 -t -a -cprof -5.5 36 350 100 0.05k -pw 10k \
    -setvars { SPROF_MAXELEV 2 SPROF_MINELEV -4 } -showprof 1 -o example_cprof
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  # Create profiles by constructing a new mprof) file with relevant data types
  # where the profile is specified by central point and azimuth

    if arg_is_float $2; then
      CPROFLON="${2}"
      shift
    else
      if [[ $2 =~ "eq" ]]; then
        CPROFLON="eqlon"
        shift
      else
        info_msg "[-cprof]: No central longitude specified."
        exit
      fi
    fi

    if arg_is_float $2; then
      CPROFLAT="${2}"
      shift
    else
      if [[ $2 =~ "eq" ]]; then
        CPROFLAT="eqlat"
        shift
      else
        info_msg "[-cprof]: No central latitude specified."
        exit
      fi
    fi

    if arg_is_float $2; then
      CPROFAZ="${2}"
      shift
    else
      if [[ $2 =~ "slab2" ]]; then
        shift
        CPROFAZ="slab2"
      else
        info_msg "[-cprof]: No profile azimuth specified."
        exit
      fi
    fi

    if arg_is_float $2; then
      CPROFLEN="${2}"
      CPROFHALFLEN=$(echo "${CPROFLEN}" | gawk '{ print ($1+0)/2 }')
      shift
    else
      if [[ $2 =~ "map" ]]; then
        shift
        CPROFHALFLEN="map"
      else
        CPROFHALFLEN=$(echo "${CPROFLEN}" | gawk '{ print ($1+0)/2 }')
      fi
    fi

    if arg_is_flag $2; then
      info_msg "[-cprof]: No resolution specified. Using 1k"
      SPROF_RES="1k"
    else
      SPROF_RES="${2}"
      shift
    fi

    cprofflag=1
    clipdemflag=1


    if [[ $2 == "flip" ]]; then
      cprofflipflag=1
    fi
    # Create the template file that will be used to generate the cprof_profs.txt file
    # antiaz foreaz centerlon|eqlon centerlat|eqlat cprofhalflen
    echo $CPROFAZ $CPROFLON $CPROFLAT $CPROFHALFLEN >> ${TMP}${F_PROFILES}cprof_prep.txt
    # Calculate the profile start and end points based on the given information
  ;;

  -margin)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-margin:    set the width of the blank margin surrounding the map document
Usage: -margin [length]

--------------------------------------------------------------------------------
EOF
shift && continue
fi
  if ! arg_is_flag $2; then
    MAPMARGIN=$2
    shift
  else
    echo "[-margin]: requires a map length argument (e.g. 0.5i)"
    exit 1
  fi

  ;;

  -profopts)
  cat <<-EOF > profopts
des -profopts Set options for profile plotting
opn width PROFILE_TRACK_WIDTH string ${PROFILE_TRACK_WIDTH}
    line width for profile lines drawn on map
EOF

  if [[ $USAGEFLAG -eq 1 ]]; then
    tectoplot_usage_opts profopts
  else
    tectoplot_get_opts profopts "${@}"
    # In main script we have to do the shifting ourselves; 1 fewer as we shift
    # at the end of this case statement
    [[ $tectoplot_module_shift -gt 0 ]] && shift $(echo "${tectoplot_module_shift} - 1" | bc)

  fi
  ;;

  -pw) # Set swath width for profiles
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pw:        specify swath width for profiles
Usage: -pw [[width]]

  [width] is profile swath width with k units specified (e.g. 25k)
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  profwidthflag=1

  if arg_is_km $2; then
    PROFWIDTH=$2
    shift
  else
    echo "[-pw]: profile width must be kilometers with unit (e.g. 10k)"
    exit 1
  fi

  ;;

  -aprof) # args: aprofcode1 aprofcode2 ... width res
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-aprof:        specify automatic profiles using a coordinate grid on the map
Usage: -aprof [code1] [[code2...]] [resolution]

  [codeN] are [A-Y][A-Y] (e.g. CW, AE) letter pairs denoting profile start/end
    -> (you can plot letters on the map using -aprofcodes)
  [width] is profile swath width with k units specified (e.g. 25k)
  [resolution] is sampling resolution with k units specified (e.g 1k)
  Profile vertical range is fixed to ${SPROF_MINELEV}/${SPROF_MAXELEV}

Example: Create a topographic swath profile across Guatemala
tectoplot -r GT -t -aprof AS 1k -pw 10k -showprof 1 -o example_aprof
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    # Create profiles by constructing a new mprof) file with relevant data types
    aprofflag=1

    while [[ "${2}" == [A-Y]*[A-Y] ]]; do
      aproflist+=("${2}")
      shift
    done

    if arg_is_flag $2; then
      info_msg "[-aprof]: No sampling interval specified. Using 1k"
      SPROF_RES="1k"
    else
      SPROF_RES="${2}"
      shift
    fi

    clipdemflag=1
    ;;

  -aprofcodes)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-aprofcodes:   plot letter coordinate grid for -aprof
Usage: -aprofcodes

Example: Plot letter coordinates for a map of Guatemala
tectoplot -r GT -t -aprofcodes -o example_aprofcodes
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if arg_is_flag $2; then
      info_msg "[-aprofcodes]: No character string given. Plotting all codes."
      APROFCODES="ABCDEFGHIJKLMNOPQRSTUVWXY"
    else
      APROFCODES="${2}"
      shift
    fi
      plots+=("aprofcodes")
    ;;

  -arrow)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-arrow:        change the width of arrow vectors
Usage: -arrow [narrower | narrow | normal | wide | wider]

Example: Plot GPS velocities with wide arrows
tectoplot -a -g pa -arrow wide -o example_arrow
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  case "${2}" in
    # GMT 4 arrow format
    # tailwidth/headlength/halfheadwidth
    narrower)
      ARROWFMT="0.01/0.14/0.06"
      shift
      ;;
    narrow)
      ARROWFMT="0.02/0.14/0.06"
      shift
      ;;
    normal)
      ARROWFMT="0.06/0.12/0.06"
      shift
      ;;
    wide)
      ARROWFMT="0.08/0.14/0.1"
      shift
      ;;
    wider)
      ARROWFMT="0.1/0.3/0.2"
      shift
      ;;
    *)
      info_msg "[-arrow]: wide | ... "
  esac
  ;;

  -datareport)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-datareport:   plot footprints of downloaded data
Usage: -datareport [[dataset ...]]

  If one or more datasets are specified, only report on them

  GMRT            GMRT cut tiles; blue
  EARTHRELIEF     Topo tiles from GMT server: reds
  sentinel        Sentinel cloud free images; green
  cuttopo         Cut topography tiles; shaded gray
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  plots+=("datareport")

  while ! arg_is_flag $2; do
    datareport_ids+=("$2")
    shift
  done

  if [[ -z $datareport_ids ]]; then
    datareport_ids+=("EARTHRELIEF")
  fi

  ;;

  -regionreport)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-regionreport: plot and label footprints of custom regions / saved shaded relief
Usage: -regionreport

  Saved shaded relif: shaded gray
  Custom map region: red line
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  plots+=("regionreport")
  ;;

  -author)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-author:       update or plot stored author information

  This option stores and prints author information to facilitate map
  attribution. There are several formats:

Usage: -author "Author ID"
  Store author information
Usage: -author
  Plot stored author and datestring at lower left corner of map
Usage: -author nodate
  Plot stored author but not timestamp on map.
Usage: -author print
  Print stored author information and then exit
Usage: -author reset
  Delete stored author information and then exit

Example: Reset a stored author ID and then update it to "Author 1"
tectoplot -author print -noplot
tectoplot -author reset -noplot
tectoplot -author "Author 1" -o example_author
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    authortimestampflag=1
    authorflag=1
    if arg_is_flag $2; then
      info_msg "[-author]: No author indicated."
      if [[ -e $TECTOPLOT_AUTHOR ]]; then
        info_msg "Using author info in ${OPTDIR}tectoplot.author"
        AUTHOR_ID=$(head -n 1 $OPTDIR"tectoplot.author")
      else
        info_msg "No author in ${OPTDIR}tectoplot.author and no author indicated"
        AUTHOR_ID=""
      fi
    else
      AUTHOR_ID="${2}"
      shift
      if [[ $AUTHOR_ID == "reset" ]]; then
        info_msg "Resetting ${OPTDIR}tectoplot.author"
        rm -f $TECTOPLOT_AUTHOR
        touch $TECTOPLOT_AUTHOR
        AUTHOR_ID=""
        exit
      elif [[ $AUTHOR_ID == "print" ]]; then
        info_msg "Printing ${OPTDIR}tectoplot.author"
        cat ${OPTDIR}tectoplot.author
        exit
      elif [[ $AUTHOR_ID == "nodate" ]]; then
        info_msg "[-author]: Not printing timestamp"
        AUTHOR_ID=$(head -n 1 $OPTDIR"tectoplot.author")
        authortimestampflag=0
      else
        info_msg "Setting author information in ${OPTDIR}tectoplot.author: ${2}"
        echo "$AUTHOR_ID" > $TECTOPLOT_AUTHOR
      fi
    fi
    DATE_ID=$(date -u $DATE_FORMAT)
    ;;

  -authoryx)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-authoryx:     shift -author text by specified inches on plot
Usage: -authoryx [YSHIFT] [XSHITY]

Example: Shift -author text to the right and up
tectoplot -r GT -a -author -authoryx 3 3 -o example_authoryx
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    if arg_is_float $2; then
      AUTHOR_YSHIFT="${2}"
      info_msg "[-authoryx]: Shifting author info (Y) by $AUTHOR_YSHIFT"
      shift
    else
      info_msg "[-authoryx]: No Y shift indicated. Using $AUTHOR_YSHIFT (i)"
    fi
    if arg_is_float $2; then
      AUTHOR_XSHIFT="${2}"
      info_msg "[-authoryx]: Shifting author info (X) by $AUTHOR_XSHIFT"
      shift
    else
      info_msg "[-authoryx]: No X shift indicated. Using $AUTHOR_XSHIFT (i)"
    fi
    ;;

  -B) # args: { ... }
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-B:            use GMT -b command to directly set map frame parameters
Usage: -B { opt1 opt2 ... }

  This option is not well tested!

Example: Plot Slab2.0 around Japan with custom longitude markings.
tectoplot -r JP -a -B { -Bxa1f1 } -o example_B
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    if [[ ${2:0:1} == [{] ]]; then
      info_msg "[-B]: B argument string detected"
      shift
      while : ; do
          [[ ${2:0:1} != [}] ]] || break
          bj+=("${2}")
          shift
      done
      shift
      BSTRING="${bj[@]}"
    fi
    usecustombflag=1
    info_msg "[-B]: Custom map frame string: ${BSTRING[@]}"
    ;;

  -usgs)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-usgs:    download QuakeML for events and make focal mechanism file
Usage: -usgs [event_id1] [[event_id2]] ...

  event_id are USGS ID codes, e.g. us7000fxq2

  Output is a tectoplot format focal mechanism file: ${TMP}${F_CMT}usgs_foc.dat
  If origin exists, also outputs origin event to ${TMP}${F_SEIS}usgs.cat

Example: Plot a USGS event focal mechanism
tectoplot -usgs us7000fxq2 -c -a -o example_usgsfoc
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  while ! arg_is_flag $2; do
    info_msg "Attempting to retrieve USGS event ${2}"
    python3 ${USGSQUAKEML} ${2} >> ${TMP}${F_CMT}usgs_foc.cat
    if [[ -s ${TMP}${F_CMT}usgs_foc.cat ]]; then
      gawk < ${TMP}${F_CMT}usgs_foc.cat '{print $5, $6, $7, $13, $3, $11 $2, $4 }' > ${TMP}${F_SEIS}usgs.cat
    else
      echo "[-usgs]: No such event $2"
      exit 1
    fi
    shift
  done
  ;;

  -d) # args: filename
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-d:            load options from file
Usage: -d [file1] [[file2 ...]]

  Adds first line from file as options on the command line
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  unset vals
  while ! arg_is_flag $2; do
    if [[ -s $2 ]]; then
      vals=($(echo ${vals[@]}) $(head -n 1 ${2}))
    else
      echo "[-d]: File $2 does not exist or is empty"
      exit 1
    fi
    shift
  done
  shift
  set -- "blank" ${vals[@]} "$@"
  echo -n "[-d]: arguments expanded to"
  echo ${@} | gawk '{$1=""; print}'
  ;;

	-c) # args: none || number
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-c:            plot focal mechanisms
Usage: -c [[TYPE=${CMTTYPE}]] [[scale=${CMTSCALE}]]

  Plots focal mechanisms from combined catalog (or custom file using -ccat)
  Scraped catalog includes harmonized GCMT, ISC, and GFZ solutions
  TYPE: CENTROID or ORIGIN  (reflecting XYZ location)
  scale: multiplication factor on the default seismicity scale ${SEISSCALE}

Example: Plot focal mechanisms
tectoplot -c -a -o example_c
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

		calccmtflag=1
		plotcmtfromglobal=1
    cmtsourcesflag=1

    # Select focal mechanisms from GCMT, ISC, GCMT+ISC
    if [[ "${2}" == "ORIGIN" || "${2}" == "CENTROID" ]]; then
      CMTTYPE="${2}"
      shift
    fi
    if arg_is_flag $2; then
      info_msg "[-c]: No scaling for CMTs specified... using default $CMTSCALE"
    else
      CMTSCALE="${2}"
      info_msg "[-c]: CMT scale updated to $CMTSCALE"
      shift
    fi

    [[ $CMTTYPE =~ "ORIGIN" ]] && ORIGINFLAG=1 && CENTROIDFLAG=0
    [[ $CMTTYPE =~ "CENTROID" ]] && ORIGINFLAG=0 && CENTROIDFLAG=1

		plots+=("cmt")
    cpts+=("seisdepth")
    #
    # echo $ISC_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    # echo $ISC_SOURCESTRING >> ${LONGSOURCES}
    # echo $GCMT_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    # echo $GCMT_SOURCESTRING >> ${LONGSOURCES}
    # echo $GFZ_SOURCESTRING >> ${LONGSOURCES}
    # echo $GFZ_SHORT_SOURCESTRING >> ${SHORTSOURCES}
	  ;;

  -ca) #  [nts] [tpn] plot selected P/T/N axes for selected EQ types
  CMT_AXESSCALE=0.007
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ca:           plot CMT kinematic axes of focal mechanisms
Usage: -ca [[axesstring=${CMTAXESSTRING}]] [[cmttypestring=${CMTAXESTYPESTRING}]] [[color Tcolor Pcolor Ncolor]]

  Plots principal axes
  axesstring characters: t = T axis (tensional)     color = ${T_AXIS_COLOR}
                         p = P axis (compressional) color = ${P_AXIS_COLOR}
                         n = N axis (neutral)       color = ${N_AXIS_COLOR}
  cmttypestring:         t = thrust, n = normal, s = strike slip

  If axesstring and cmttypestring are BOTH not specified, then colors
  can still be specified.

Example: Plot P axes for thrust-type focal mechanisms
tectoplot -a -ca t t -o example_ca
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    calccmtflag=1
    cmtsourcesflag=1
    plotcmtfromglobal=1

    if arg_is_flag $2; then
      info_msg "[-ca]: CMT axes eq type not specified. Using default ($CMTAXESSTRING)"
    elif [[ $2 != "color" ]]; then
      CMTAXESSTRING="${2}"
      shift
      if arg_is_flag $2; then
        info_msg "[-ca]: CMT axes selection string not specfied. Using default ($CMTAXESTYPESTRING)"
      else
        CMTAXESTYPESTRING="${2}"
        shift
      fi
    fi

    # Change the colors, in T P N order
    if [[ $2 == "color" ]]; then
      shift
      if ! arg_is_flag $2; then
        T_AXIS_COLOR=$2
        shift
      fi
      if ! arg_is_flag $2; then
        P_AXIS_COLOR=$2
        shift
      fi
      if ! arg_is_flag $2; then
        N_AXIS_COLOR=$2
        shift
      fi
    fi


    [[ "${CMTAXESTYPESTRING}" =~ .*n.* ]] && axescmtnormalflag=1
    [[ "${CMTAXESTYPESTRING}" =~ .*t.* ]] && axescmtthrustflag=1
    [[ "${CMTAXESTYPESTRING}" =~ .*s.* ]] && axescmtssflag=1
    [[ "${CMTAXESSTRING}" =~ .*p.* ]] && axespflag=1
    [[ "${CMTAXESSTRING}" =~ .*t.* ]] && axestflag=1
    [[ "${CMTAXESSTRING}" =~ .*n.* ]] && axesnflag=1
    plots+=("caxes")
    ;;

  -cc) # args: none
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-cc:           connect focal mechanisms to alternate location
USage: -cc
  Plots a line connecting focal mechanism to a dot at the alternate location,
  on both map and cross section plots.

Example: Show shift of CENTROID and ORIGIN locations near New Zealand
tectoplot -r NZ -c -cc -a -o example_cc
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    connectalternatelocflag=1
    ;;

# Filter focal mechanisms by various criteria
# maxdip: at least one nodal plane dip is lower than this value
  -cfilter)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-cfilter:      filter CMT by nodal plane dip or rake range
Usage: -cfilter [command1] [arg1] [[command2]] [[arg2]] ...

The criteria are evaluated separately, and an event is rejected only
if neither nodal plane meets each criterion. rakerange takes two
arguments.

commands (all arguments are in degrees)

  maxdip    [dip]
  mindip    [dip]
  maxstrike [strike]
  minstrike [strike)]
  rakerange [minrake] [maxrake]

Example: Plot CMT data having a nodal plane with rake between 160 and 130
tectoplot -a -c -cfilter rakerange 130 160 -o example_cfilter
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    cfilterflag=1

    while ! arg_is_flag "${2}"; do
      case "${2}" in
        maxdip)
          cfiltercommand+=("${2}")
          shift
          if arg_is_positive_float $2; then
            CF_MAXDIP="$2"
            shift
          else
            info_msg "[-cfilter]: maxdip requires positive float argument"
            exit
          fi
        ;;
        mindip)
          cfiltercommand+=("${2}")
          shift
          if arg_is_positive_float $2; then
            CF_MINDIP="$2"
            shift
          else
            info_msg "[-cfilter]: mindip requires positive float argument"
            exit
          fi
        ;;
        maxstrike)
          cfiltercommand+=("${2}")
          shift
          if arg_is_positive_float $2; then
            CF_MAXSTRIKE="$2"
            shift
          else
            info_msg "[-cfilter]: maxstrike requires positive float argument"
            exit
          fi
        ;;
        minstrike)
          cfiltercommand+=("${2}")
          shift
          if arg_is_positive_float $2; then
            CF_MINSTRIKE="$2"
            shift
          else
            info_msg "[-cfilter]: minstrike requires positive float argument"
            exit
          fi
        ;;
        rakerange)
          cfiltercommand+=("${2}")
          shift
          if arg_is_float $2; then
            CF_MINRAKE="$2"
            shift
            if arg_is_float $2; then
              CF_MAXRAKE="$2"
              shift
            else
              info_msg "[-cfilter]: rakerange requires two float arguments"
              exit
            fi
          else
            info_msg "[-cfilter]: rakerange requires two float arguments"
            exit
          fi
        ;;

      esac
    done
    ;;

  -clipdem)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-clipdem:      save clipped dem file as dem.nc
Usage: -clipdem

  This process is done for virtually all plots anyway.

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    clipdemflag=1
    ;;

#   -clipon|-clipout)
# if [[ $USAGEFLAG -eq 1 ]]; then
# cat <<-EOF
# -clipon:       activate clipping polygon, inside
# Usage: -clipon [ polygonFile or regionID ]
#
#   Turn on PS clipping to mask areas that are subsequently plotted into.
#
#   polygonFile is a potentially multisegment (> dividing lines) LON LAT file.
#   regionID is any GMT region recognized by pscoast (e.g. =NA ; FR,ES ; etc.)
#   -clipline [ polygonFile | regionID ] will plot the clipping line
#   -clipoff is necessary to release clipping before closing the PS file.
#
# Example: Use -clipon, -clipout, -clipoff to make a composite map of New Zealand
# tectoplot -r NZ -clipon NZ -t -clipoff -clipout NZ -v BG 0 rescale -clipoff -clipline -o example_clipon
# ExampleEnd
# --------------------------------------------------------------------------------
# -clipout:      activate clipping polygon, outside
# Usage: -clipout [ polygonFile or regionID ]
#
#   Turn on PS clipping to mask areas that are subsequently plotted into.
#
#   polygonFile is a potentially multisegment (> dividing lines) LON LAT file.
#   regionID is any GMT region recognized by pscoast (e.g. =NA ; FR,ES ; etc.)
#
# Related: -clipon -clipline -clipoff
# --------------------------------------------------------------------------------
# EOF
# shift && continue
# fi
#
#     clipcmd=$1
#     CLIP_POLY_FILE=$(abs_path $2)
#     if [[ -s ${CLIP_POLY_FILE} ]]; then
#
#       if [[ ${CLIP_POLY_FILE} == *.kml ]]; then
#         echo "Making KML into poly"
#         kml_to_first_xy ${CLIP_POLY_FILE} ${TMP}clip_poly.txt
#         CLIP_POLY_FILE=$(abs_path ${TMP}clip_poly.txt)
#         info_msg "[-clipon|clipout]: Using polygon file ${CLIP_POLY_FILE}"
#       else
#         cp $2 ${TMP}clip_poly.txt
#         CLIP_POLY_FILE=$(abs_path ${TMP}clip_poly.txt)
#       fi
#       shift
#       [[ $clipcmd =~ "-clipon" ]] && plots+=("clipon")
#       [[ $clipcmd =~ "-clipout" ]] && plots+=("clipout")
#     else
#       info_msg "[-clipon|clipout]: No polygon file ${CLIP_POLY_FILE} found. Interpreting as GMT ID"
#       # Extract the DCW borders and fix the longitude range if necessary
#       gmt pscoast -E${2} -M ${VERBOSE} | gawk '
#       BEGIN {ind=1}
#       {
#         if ($1+0>180) {
#           print $1-360, $2
#         } else if ($1+0<-180) {
#           print $1+360, $2
#         }
#         else if ($1==">"){
#          print "0 x"
#         }
#         else {
#           print
#         }
#       }' > ${TMP}tectoplot_path.clip
#
#       CLIP_POLY_FILE=$(abs_path ${TMP}tectoplot_path.clip)
#
#       # gmt pscoast -E${2} -M ${VERBOSE}  > tectoplot_path.clip
#       shift
#       if [[ -s ${TMP}tectoplot_path.clip ]]; then
#         copyandsetclippolyfileflag=1
#         [[ $clipcmd =~ "-clipon" ]] && plots+=("clipon")
#         [[ $clipcmd =~ "-clipout" ]] && plots+=("clipout")
#       fi
#     fi
#     ;;
#
#   -clipoff)
# if [[ $USAGEFLAG -eq 1 ]]; then
# cat <<-EOF
# -clipoff:      deactivate clipping polygon
# Usage: -clipoff
#
#   Turn off all PS clipping.
#
# --------------------------------------------------------------------------------
# EOF
# shift && continue
# fi
#
#     plots+=("clipoff")
#     ;;
#
#   -clipline)
# if [[ $USAGEFLAG -eq 1 ]]; then
# cat <<-EOF
# -clipline:      plot line along clipping polygon boundary
#
#   Plot previously defined clipping polygon as a line.
#
# --------------------------------------------------------------------------------
# EOF
# shift && continue
# fi
#
#     plots+=("clipline")
#     ;;

  -cmag) # args: number number
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-cmag:         set magnitude range for focal mechanisms
Usage: -cmag [minmag] [[maxmag]]

  Select focal mechanisms between specified magnitudes.

Example: Plot a map of focal mechanisms in Albania between M5 and M6
tectoplot -r AL -t -c -cmag 5 6 -o example_cmag
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if arg_is_flag $2; then
      info_msg "[-cmag]: No magnitudes speficied. Using $CMT_MINMAG - $CMT_MAGMAG"
    else
      CMT_MINMAG="${2}"
      shift
    fi
    if arg_is_flag $2; then
      info_msg "[-cmag]: No maximum magnitude speficied. Using $CMT_MAGMAG"
    else
      CMT_MAXMAG="${2}"
      shift
    fi
    cmagflag=1
    ;;

  -command)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-command:      print the complete tectoplot command on the map
Usage: -command

  If -author is specified, justify lower right. If not, lower left.

Example:
tectoplot -a -command -o example_command
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    printcommandflag=1
    ;;

  -cpts)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-cpts:         rebuilt internal tectoplot cpts
Usage: -cpts

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    remakecptsflag=1
    ;;

  -cr) # args: number number
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-cr:    rotate focal mechanisms based on back-azimuth to pole
Usage: -cr [pole lon] [pole lat] [reference azimuth]

   Rotate focal mechanisms by the back-azimuth to a lon/lay point, relative
   to a reference azimuth.

Example:
tectoplot -c -cr 120 20 90 -o example_cr
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    # Nothing yet
    cmtrotateflag=1
    CMT_ROTATELON="${2}"
    CMT_ROTATELAT="${3}"
    CMT_REFAZ="${4}"
    shift
    shift
    shift
    ;;

  -cslab2)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-cslab2:       select thrust CMTs consistent with rupture of slab2.0 surface
Usage: -cslab2 [[distance]] [[strike_diff]] [[dip_diff]]

  From CMT catalog, for already selected thrust mechanisms, retain only those
  within a specified vertical distance from slab2, and with at least one nodal
  plane with similar strike and dip.

  distance is in km
  strike_diff and dip_diff are in degrees

Example:
tectoplot -b -z -c -cslab2 -o example_cslab2
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  if arg_is_float $2; then
    CMTSLAB2VERT=${2}
    shift
  fi
  if arg_is_float $2; then
    CMTSLAB2STR=${2}
    shift
  fi
  if arg_is_float $2; then
    CMTSLAB2DIP=${2}
    shift
  fi

  cmtslab2filterflag=1
  ;;

  -cunfold)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-cunfold:      back-rotate focal mechanisms based on slab2 strike and dip
Usage: -cunfold

  Rotate focal mechanisms around a horizontal axis parallel to local slab strike
  by an angle equal to slab dip. This is an approximate correction to restore
  subducted faults to their pre-subduction orientation.

Example:
tectoplot -b -c -cdeep -cunfold -o example_cunfold
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  slab2_unfold_focalsflag=1
  ;;

  -cdeep)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-cdeep:        select focal mechanisms in lower plate below slab2 model
Usage: -cdeep [[buffer_distance=${CMTSLAB2VERT}]] [[incout]]

  Buffer distance shifts the Slab2 model up (negative) or down (positive) [km]
  For this option only, buffer_distance also applies to Earth's surface so
  buffer_distance=-30 will select only regional events (not below Slab2 model)
  below depths of 30 km.

  [[incout]]: Include any focal mechanisms falling outside of slab region

Example:
tectoplot -b -c -cdeep -o example_cdeep
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  cmtslab2_deep_filterflag=1
  if arg_is_float $2; then
    CMTSLAB2VERT=${2}
    shift
  fi
  if [[ $2 == "incout" ]]; then
    SLAB2_INCLUDEOUT=1
    shift
  fi
  ;;

  -cshallow)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-cshallow:     select focal mechanisms in upper plate above slab2 model
Usage: -cshallow [[buffer_distance=${CMTSLAB2VERT}]]

  Buffer distance shifts the Slab2 model down (negative) or up (positive) [km]

Example:
tectoplot -b -c -cshallow -o example_cshallow
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  cmtslab2_shallow_filterflag=1
  if arg_is_float $2; then
    CMTSLAB2VERT=${2}
    shift
  fi
  ;;

  -ct) # args: string
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ct:           choose focal mechanism classes
Usage: -ct [optstring]
   n: Select normal mechanisms
   t: Select thrust mechanisms
   s: Select strike-slip mechanisms

Example: Plot strike-slip focal mechanisms
tectoplot -c -ct s -o example_ct
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
		calccmtflag=1
		cmtnormalflag=0
		cmtthrustflag=0
		cmtssflag=0
		if arg_is_flag $2; then
			info_msg "[-ct]: CMT eq type string is malformed"
		else
			[[ "${2}" =~ .*n.* ]] && cmtnormalflag=1
			[[ "${2}" =~ .*t.* ]] && cmtthrustflag=1
			[[ "${2}" =~ .*s.* ]] && cmtssflag=1
			shift
		fi
		;;

  -cw) # args: none
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-cw:           plot white compressive quadrants for focal mechanisms
Usage: -cw

Example: Plot focal mechanisms with white compressive quadrants
tectoplot -c -cw -o example_cw
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    CMT_THRUSTCOLOR="gray100"
    CMT_NORMALCOLOR="gray100"
    CMT_SSCOLOR="gray100"
    ;;

  -e) # args: file
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-e:            execute custom script
Usage: -e [scriptfile] [arg1] [...]

  Execute a script via bash sourcing (. script.sh). The script will run in the
  current tectoplot environment and will have access to its variables.
  Please be careful about running scripts in this fashion as there are no checks
  on whether the script is safe.

  All following non-flag arguments are passed to the script as arguments.

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    EXECUTEFILE=$(abs_path $2)
    shift

    while ! arg_is_flag $2; do
      EXEC_ARGS+=("$2")
      shift
    done

    plots+=("execute")
    ;;

  -eps)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-eps:          overlay eps file when producing final pdf
Usage: -eps [filename.eps]

  Overlay an existing EPS file. This option currently doesn't work reliably.

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    epsoverlayflag=1
    EPSOVERLAY=$(abs_path $2)
    shift
    ;;

  -shiftlabels)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-shiftlabels:  automatically adjust label locations
Usage: -shiftlabels

  This option uses a genetic algorithm to try to find a good justification for
  the input labels, avoiding covering the input data points, having labels
  extend off the map, and having overlapping labels. Can take a long time
  with a very large number of labels.

  There is a random nature to the algorithm so running again will likely
  produce a slightly different label position.

Example: Label focal mechanisms of earthquakes larger than Mw=7
tectoplot -z -zmag 7 -eqlabel 7.5 yearmag -shiftlabels
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  shiftlabelsflag=1
  ;;

  -eqlabel)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-eqlabel:      label earthquake events using various criteria
Usage: -eqlabel [selectoptions] [formatoptions]

  [selectoptions] are: { list min_magnitude r }
    list:           label events with IDS from -eqlist
    min_magnitude:  label events with magnitude larger than this (e.g. 7.5)
    r:              use the earthquake specified by -eventmap [earthquakeID]

  [displayoptions] are: { idmag datemag dateid id date mag year yearmag }
    date:           YYYY-MM-DD
    datetime:       YYYY-MM-DD HH:MM:SS
    mag:            Magnitude (1 decimal place)
    id:             ID code
    year:           YYYY

  This option attempts to label all earthquake events on maps and cross sections
  that comply with specified criteria, using different label formats.

  The direction of box offset is governed by the coordinate quadrant to ensure
  that labels don't extent off of the map area (as much as possible).

Example: Label focal mechanisms of earthquakes larger than Mw=7
tectoplot -a -c -eqlabel 7 mag -o example_eqlabel
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
      labeleqminmag=0
      while [[ ${2:0:1} != [-] && ! -z $2 ]]; do
        if [[ $2 == "list" ]]; then
          labeleqlistflag=1
          shift
        elif arg_is_float $2; then
          labeleqmagflag=1
          labeleqlistflag=0
          labeleqminmag="${2}"
          shift
        elif [[ $2 == "r" ]]; then
          eqlistarray+=("${REGION_EQ}")
          labeleqlistflag=1
          shift
        elif [[ $2=="time" || $2 == "idmag" || $2 == "datemag" || $2 == "datetime" || $2 == "dateid" || $2 == "id" || $2 == "date" || $2 == "mag" || $2 == "year" || $2 == "yearmag" ]]; then
          EQ_LABELFORMAT="${2}"
          shift
        else
          info_msg "[-eqlabel]: Label class $2 not recognized."
          EQ_LABELFORMAT="datemag"
          shift
        fi
      done
      # If we don't specify a source type, use the list assuming that -r eq or similar was used
      if [[ $labeleqlistflag -eq 0 && $labeleqmagflag -eq 0 ]]; then
        labeleqlistflag=1
      fi
      [[ $eqlabelflag -ne 1 ]]  && plots+=("eqlabel")
      eqlabelflag=1
    ;;

  -eqlist)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-eqlist:       select earthquake events by id code
Usage: -eqlist  [filename] { eqID1 eqID2 ... }

  Populate a list from a file of earthquake IDs and/or a bracketed list.
  Use with -eqlabel and -eqselect.

--------------------------------------------------------------------------------
EOF
shift && continue
fi

    if [[ ${2:0:1} == [{] ]]; then
      info_msg "[-eqlist]: EQ array but no file specified."
      shift
      while : ; do
        [[ ${2:0:1} != [}] ]] || break
        eqlistarray+=("${2}")
        shift
      done
      shift
    else
      if arg_is_flag $2; then
        info_msg "[-eqlist]: Specify a file or { list } of events"
      else
        EQLISTFILE=$(abs_path $2)
        shift
        eqlistarray=($(gawk < $EQLISTFILE '{print $1}'))
      fi
      if [[ ${2:0:1} == [{] ]]; then
        info_msg "[-eqlist]: EQ array but no file specified."
        shift
        while : ; do
          [[ ${2:0:1} != [}] ]] || break
          eqlistarray+=("${2}")
          shift
        done
        shift
      fi
    fi
    if [[ ${#eqlistarray[@]} -gt 0 ]]; then
      eqlistflag=1
    fi
    ;;

  -eqselect)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-eqselect:     only plot earthquake events from -eqlist {...} list
Usage: -eqselect

  Use this option to select earthquakes using a list.

Example:
tectoplot -a -c -eqlist { C201701220430A M081695P } -eqselect -eqlabel list -o example_eqselect
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    eqlistselectflag=1;
    ;;

  -faultgrid)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-faultgrid:     specify files containing gridded fault surfaces
Usage: -faultgrid gridfile [[options]]

  Plots a gridded fault dataset as colored contours (using the seismicity CPT)
  and adds the faults to any profiles.

  Options:
  inv                          invert the sign of depth
  res [resolution]             sample spacing for -mprof, e.g. 5k for Slab2
  int [number]                 contour interval
  skip [number]                only label contours a multiple of this number

  -faultgrid can be called multiple times

--------------------------------------------------------------------------------
EOF
shift && continue
fi

  if [[ $faultgridfirst -ne 1 ]]; then
    faultgridnum=0
    faultgridfirst=1
  fi

  if [[ -s $2 ]]; then
    plotfaultgridflag=1
    ((faultgridnum++))
    FAULTGRIDFILES[$faultgridnum]=$(abs_path $2)
    shift
  else
    echo "[-faultgrid]: grid file $2 does not exist or is empty"
    exit 1
  fi
  FAULTGRIDFILERES[$faultgridnum]="1k"
  FAULTGRIDFILECONTOUR[$faultgridnum]=1
  FAULTGRIDFILECONTOURSKIP[$faultgridnum]=1
  FAULTGRIDFILEMUL[$faultgridnum]=1  # Multiplication factor

  while ! arg_is_flag $2; do
    case $2 in
    mul)
      shift
      if arg_is_float $2; then
        FAULTGRIDFILEMUL[$faultgridnum]=$2
        shift
      else
        echo "[-faultgrid]: mul option requires number argument"
        exit 1
      fi
      ;;
    int)
      shift
      if arg_is_positive_float $2; then
        FAULTGRIDFILECONTOUR[$faultgridnum]=$2
        shift
      else
        echo "[-faultgrid]: int option requires positive float argument"
        exit 1
      fi
    ;;
    skip)
      shift
      if arg_is_positive_float $2; then
        FAULTGRIDFILECONTOURSKIP[$faultgridnum]=$2
        shift
      else
        echo "[-faultgrid]: int option requires positive float argument"
        exit 1
      fi
      ;;
    res)
      shift
      if ! arg_is_flag $2; then
        FAULTGRIDFILERES[$faultgridnum]=$2
        shift
      else
        echo "[-faultgrid]: res option requires resolution argument (eg 1k)"
        exit 1
      fi
    ;;
    esac
  done

  cpts+=("seisdepth")
  shift

  # Add the command to plot the grid contour lines
  set -- "blank" "-cn" "${FAULTGRIDFILES[$faultgridnum]}" "inv" "int" "${FAULTGRIDFILECONTOUR[$faultgridnum]}" "skip" "${FAULTGRIDFILECONTOURSKIP[$faultgridnum]}" "cpt" "cpts/seisdepth.cpt" "$@"
  ;;

  -front)
  FRONTSCALE=1
  FRONTSMOOTHINC="10k"
  FRONTTRANS=0
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-front:           plot ticked lines using a front control file
-front [file_path] [[options]]

  Options:
  smooth [distance]        subsample using given distance increment, spline
  scale [factor]           rescale line width and tick size by this factor
  space [pageunit]         spacing of decorations (e.g. 1i); overrides control
  trans [percent]          line transparency

  The input file is a control file with the format:

# Comments begin with #, empty lines are ignored
absolute_file_path symbol side tickspacing ticklength linecolor linewidth fillcolor
...


The file_path argument is required and must be an absolute path.
Argument options are as follows (first listed option is the default value):
  symbol=t|f|s|c|v|b
  side=l|r
  tickspacing=1c
  ticklength=3p
  linecolor=black
  linewidth=1p
  fillcolor=black

--------------------------------------------------------------------------------
EOF
shift && continue
fi

  if [[ ! -s ${2} ]]; then
    echo "[-front]: Control file ${2} does not exist or is empty"
    exit 1
  else
    FRONTFILE=$(abs_path $2)
    shift
  fi

  while ! arg_is_flag $2; do
    case $2 in
      space)
        shift
        if ! arg_is_flag $2; then
          FRONTSPACE="${2}"
          shift
          frontspaceflag=1  # override input file
        else
          echo "[-front]: space option requires page distance argument (e.g. 1i)"
          exit 1
        fi
      ;;
      smooth)
        shift
        if [[ $2 != "scale" && $2 != "trans" && $2 != "space" ]]; then
          if ! arg_is_flag $2; then
            FRONTSMOOTHINC="${2}"
            shift
            frontsmoothflag=1
          else
            echo "[-front]: smooth option requires km distance argument (using default 10k)"
          fi
        fi
      ;;
      scale)
        shift
        if arg_is_positive_float $2; then
          FRONTSCALE="${2}"
          frontscaleflag=1
          shift
        else
          echo "[-front]: scale option requires positive number (e.g. 2.5)"
          exit 1
        fi
      ;;
      trans)
        shift
        if arg_is_positive_float $2; then
          FRONTTRANS="${2}"
          shift
        else
          echo "[-front]: trans option requires percentage argument (e.g. 50)"
          exit 1
        fi
      ;;
      *)
        echo "[-front]: option $2 not recognized"
        exit 1
      ;;
    esac
  done

  plots+=("front")
  ;;

	-f)   # args: number number
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-f:            specify reference point for plate motion models
Usage: -f [lon] [lat]

  The stationary plate will be set to the one containing the reference point.
  A circled triangle will be plotted at the reference point.

Example: Plate motions around Puerto Rico and Cuba, Puerto Rico fixed
tectoplot -r PR,CU -t -p MORVEL -pe -pf 100 -pa -f -74 19 -o example_f
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
		refptflag=1
    if arg_is_float $2; then
      REFPTLON="${2}"
      shift
    fi
    if arg_is_float $2; then
		  REFPTLAT="${2}"
      shift
      info_msg "[-f]: Reference point is ${REFPTLON}/${REFPTLAT}"
    fi
    plots+=("refpoint")
	   ;;

  -fe)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-fe:           plot Flinn-Engdahl geographic or seismic regions
Usage: -fe [[seismic]]

  By default, plots and labels Flinn-Engdahl regions

  seismic: plot seismic regions instead of geographic regions

Example:
tectoplot -a -r =AF -fe seismic -o example_fe
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  FE_TYPE="region"

  if [[ $2 == "seismic" ]]; then
    FE_TYPE="seismic"
    shift
  fi


  plots+=("flinn-engdahl")
    ;;

  -pstrain)

  PSTRAIN_SIZE=16       # points
  PSTRAIN_COLOR_MAX=black
  PSTRAIN_COLOR_MIN=black
  PSTRAIN_WIDTH=1p
  PSTRAIN_TYPE="Principal strain"

if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pstrain:       plot principal strains as orthogonal arrows
Usage: -pstrain [file] [[options]]

Input file has format: lon lat e11 e33 az_e11

Options:
size [size]         size of largest symbol. Give units [p | c | i]
type [string]       data type of principal axes (e.g. "strain" | "strain rate")
color [color_max] [color_min]      symbol line color for max/min axes
width [width]       symbol line width

--------------------------------------------------------------------------------
EOF
shift && continue
fi

  if [[ -s ${2} ]]; then
    PSTRAIN_FILE=$(abs_path $2)
    shift
  else
    echo "[-pstrain]: input file $2 is empty or does not exist"
    exit 1
  fi

  while ! arg_is_flag $2; do
    case $2 in
      type)
        if ! arg_is_flag $2; then
          shift
          PSTRAIN_TYPE=$2
          shift
        else
          echo "[-pstraint]: type option requires string argument"
          exit 1
        fi
      ;;
      size)
        shift
        if arg_is_float $2; then
          PSTRAIN_SIZE=$2
        elif [[ $2 == *p ]]; then
          PSTRAIN_SIZE=$(echo $2 | gawk '{print $1+0}')
        elif  [[ $2 == *c ]]; then
          PSTRAIN_SIZE=$(echo $2 | gawk '{print ($1+0)*72/2.54}')
        elif [[ $2 == *i ]]; then
          PSTRAIN_SIZE=$(echo $2 | gawk '{print ($1+0)*72}')
        else
          echo "[-pstrain]: size argument $2 not recognized"
        fi
        shift
      ;;
      color)
        shift
        PSTRAIN_COLOR_MAX=$2
        shift
        PSTRAIN_COLOR_MIN=$2
        shift
      ;;
      width)
        shift
        PSTRAIN_WIDTH=$2
        shift
      ;;
      *)
        echo "[-pstrain]: option $2 not recognized"
        exit 1
      ;;
    esac

  done

  plots+=("pstrain")

;;

  -gg)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-gg:         interpolate GPS velocities using GMT gpsgridder
Usage: -gg [[resolution=${GPS_GG_RES}]] [[poisson=${GPS_GG_VAL}]] [[option ...]]

  resolution requires unit (e.g. 2m for 2 minute)
  poisson is Poisson's ratio for the elastic Greens functions (0-1)

  arrows are black if >1 GPS in cell, gray if 1 in cell, white if none

  flags:
    residuals  =  plot GPS residuals
    noave      =  don't plot the average velocities
    noave0     =  don't plot average velocities with 0 nearby data points
    subsample [factor]  = subsample velocity arrows by factor
    maxshear   =  plot grid of maximum shear strain rate
    secinv     =  plot second invariant of strain rate tensor
    strdil     =  plot dilatation of strain rate tensor
    rot        =  plot rotation rate grid

  Requires -g option
  Duplicated GPS site locations will be culled, retaining first site.

Example:
tectoplot -r 30 40 30 42 -a -g ref EU -gg 0.1d 0.5 subsample 10 -i 4 -o example_gg
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  if ! arg_is_flag $2; then
    GPS_GG_RES=$2
    shift
  fi

  if arg_is_positive_float $2; then
    GPS_GG_VAL=$2
    shift
  fi

  while ! arg_is_flag $2; do
    case $2 in
      residuals)
        GG_PLOT_RESIDUALS=1
        shift
        ;;
      noave)
        GG_NO_AVE=1
        shift
        ;;
      noave0)
        GG_NO_AVE_0=1
        shift
        ;;
      subsample)
        GG_SUBSAMPLE=1
        shift
        if arg_is_positive_float $2; then
          GG_SUBSAMPLE_NUM=$(echo $2 | gawk '{print int($1)}')
          shift
        else
          GG_SUBSAMPLE_NUM=10
        fi
        ;;
      maxshear)
        GG_PLOT_MAX_SHEAR=1
        shift
        ;;
      secinv)
        GG_PLOT_2INV=1
        shift
        ;;
      strdil)
        GG_PLOT_STR_DIL=1
        shift
        ;;
      rot)
        GG_PLOT_ROT=1
        shift
        ;;
      cross)
        GG_PLOT_CROSS=1
        shift
        ;;
      *)
        echo "[-gg]: Flag $2 not recognized"
        exit 1
        ;;
    esac
  done

  plots+=("gps_gg")
  ;;

  -pagegrid)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pagegrid:     plot an inch- or cm-spaced grid around the map document
Usage: -pagegrid [[unit=${PAGE_GRID_UNIT}]]

  Plot an inch- or cm-spaced grid around the map document

  Units:
    i    inches
    c    centimeters

Example: Plot a page grid
tectoplot -a -pagegrid c -o example_pagegrid
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    case $2 in
      i|c)
        PAGE_GRID_UNIT=$2
        shift
      ;;
    esac
    plots+=("pagegrid")
  ;;

	-g) # args: none || string
  gpsfontsize=6
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-g:            plot gps velocities from builtin catalog
Usage: -g [[options ...]]

  GPS velocities exist for all plates in Kreemer et al., 2014 supplementary
  database. If -p is used, -g will assume the same plate ID as -p unless it is
  overridden using -g [refplate]. Note that plate IDs must match exactly.

  ref [id]          : set plate with given ID as reference plate
  noplot            : prevent plotting of the GPS velocities.
  minsig [value]    : set minimum uncertainty of GPS velocity
  color [colorID]   : set the fill color
  maxvel [value]    : set the velocity shown in the legend
  text [fontsize]   : plot velocity text (mm/yr) for each arrow

  Velocity vector lengths can be scaled using -i.

Example: Plate motions and GPS velocities around Puerto Rico and Cuba (plate na)
tectoplot -r PR,CU -t -p MORVEL -pe -pl -pf 100 -g -o example_g
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
		plotgps=1
		info_msg "[-g]: Plotting GPS velocities"

    while ! arg_is_flag $2; do
      case $2 in
        ref)
          shift
          if ! arg_is_flag "${2}"; then
            GPSID="${2}"
            info_msg "[-g]: Ovveriding GPS plate ID = ${GPSID}"
            gpsoverride=1
            GPS_FILE=`echo $GPSDIR"/GPS_$GPSID.gmt"`
            shift
          else
            echo "[-g]: ref requires a plate ID argument"
            exit 1
          fi
        ;;
        noplot)
          GPS_NOPLOT=1
          shift
        ;;
        text)
          shift
          gpstextflag=1
          if ! arg_is_flag "${2}"; then
            gpsfontsize=$2
            shift
          fi
        ;;
        minsig)
          shift
          if arg_is_positive_float $2; then
            GPS_MINSIG=$2
            shift
          else
            GPS_MINSIG=0.6
          fi
        ;;
        color)
          shift
          GPS_FILLCOLOR=${2}
          shift
        ;;
        maxvel)
          shift
          if arg_is_float $2; then
            GVEL=${2}
            shift
          else
            echo "[-g]: maxvel option requires number argument"
            exit 1
          fi
        ;;
        *)
          echo "[-g]: Argument ${2} not recognized."
          exit 1
        ;;
      esac
    done

		plots+=("gps")
    echo $GPS_SOURCESTRING >> ${LONGSOURCES}
    echo $GPS_SHORT_SOURCESTRING >> ${SHORTSOURCES}
		;;

  -gadd) # args: file
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-gadd:         plot custom gps velocity file in gmt psvelo format
Usage: -gadd [velocityFile] [[color colorID=$EXTRAGPS_FILLCOLOR]] [[merge]]

  GPS velocities are plotted with filled arrows. The reference frame
  is assumed to be correct for the given map.

  This command can be called multiple times

  merge             :  add GPS velocities to gps.txt file
  color [colorID]   :  set fill color of plotted GPS (won't work with noplot)
  noplot            :  don't plot this GPS dataset on the map

  NOTE: psvelo format is:
  lon lat VE VN SVE SVN XYCOR SITEID INFO

Example: Plot a hypothetical plate velocity in Turkey
echo "39 39 -45 45 1 1 0.1 KEB Fake-GPS" > tectoplot_gps.dat
tectoplot -r TR -t -p MORVEL -pe -pl -pf 100 -g eu -gadd tectoplot_gps.dat -o example_gadd
rm -f tectoplot_gps.dat
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    # Required arguments
    usergpsfilenumber=$(echo "$usergpsfilenumber + 1" | bc -l)
    USERGPSDATAFILE[$usergpsfilenumber]=$(abs_path $2)
    shift
    if [[ ! -e ${USERGPSDATAFILE[$usergpsfilenumber]} ]]; then
      info_msg "[-gadd]: User gps data file ${USERGPSDATAFILE[$usergpsfilenumber]} does not exist."
      exit 1
    fi
    # Optional arguments

    USERGPSCOLOR_arr[$usergpsfilenumber]=$EXTRAGPS_FILLCOLOR
    USERGPSLOG_arr[$usergpsfilenumber]=0

    # Look for other arguments
    while ! arg_is_flag $2; do
      case $2 in
        color)
          shift
          if ! arg_is_flag $2; then
            info_msg "[-gadd]: Using color ${2}."
            USERGPSCOLOR_arr[$usergpsfilenumber]="${2}"
            shift
          else
            info_msg "[-gadd]: color command should be followd by a color"
          fi
        ;;
        # not used
        # log)
        #   shift
        #   USERGPSLOG_arr[$usergpsfilenumber]=1
        # ;;
        merge)
          USERGPSMERGE_arr[$usergpsfilenumber]=1
          shift
        ;;
        noplot)
          USERGPSNOPLOT_arr[$usergpsfilenumber]=1
          shift
        ;;
      esac
    done

    plots+=("extragps")
    ;;

  -fixcpt)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-fixcpt:     fix a CPT file and print to stdout, then exit
-fixcpt [cptfile]

--------------------------------------------------------------------------------
EOF
shift && continue
fi

  replace_gmt_colornames_rgb $2
  exit
;;

  -gebcotid)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-gebcotid:     plot GEBCO tid raster
Usage: -gebcotid

  GEBCO includes both observed and interpolated data. The TID map indicates
  which type of data populates each raster cell.

  Progress needs to be made to create an effective legend for this option.

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    plots+=("gebcotid")
    clipdemflag=1
    ;;

  -graticulefont)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-graticulefont:    set font for graticule labels
Usage: -graticulefont [font]

--------------------------------------------------------------------------------
EOF
shift && continue
fi
  graticulefontflag=1
  if ! arg_is_flag $2; then
    graticulefont=$2
    shift
  else
    echo "[-graticulefont]: font argument required"
    exit 1
  fi
  ;;

  -whitegraticule)
  whitegraticulewidth=1p
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-whitegraticule:     plot white graticule beneath regular graticule
Usage: -whitegraticule [[linewidth=${whitegraticulewidth}]]

  Creates a white outline to graticule text, useful for -insideframe over topo

--------------------------------------------------------------------------------
EOF
shift && continue
fi
  whitegraticuleflag=1
  if ! arg_is_flag $2; then
    whitegraticulewidth=$2
    shift
  fi
  ;;

  -insideframe)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-insideframe:     label graticule inside the map frame
Usage: -insideframe

--------------------------------------------------------------------------------
EOF
shift && continue
fi
  insideframeflag=1
  ;;

  -geotiff)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-geotiff:      create a georeferenced rgb geotiff from the map document
Usage: -geotiff [[resolution]]

    This option will reset the map projection and region to the Cartesian
    projection required for export to GeoTIFF using gmt psconvert.

    The output file is saved with the same name as the output PDF, but as .tif

    resolution: the resolution (in dpi) of the output GeoTIFF file.

--------------------------------------------------------------------------------
EOF
shift && continue
fi

    if [[ $regionsetflag -ne 1 ]]; then
      info_msg "[-geotiff]: WARNING: Region should be set with -r before -geotiff flag is set. Using default region."
    fi
    gmt gmtset MAP_FRAME_TYPE inside

    # insideframeflag=1
    tifflag=1

    if [[ $2 == "square" ]]; then
      shift
      RJSTRING="-R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} -JX${PSSIZE}id"
      usecustomrjflag=1
    fi

    if arg_is_positive_float $2; then
      GEOTIFFRES="${2}"
      shift
    fi
    ;;

  -gls)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-gls:          list all gps reference frames
Usage: -gls

--------------------------------------------------------------------------------
EOF
shift && continue
fi
      for gpsfile in $(ls ${GPSDIR}/GPS_*.gmt); do
        echo "$(basename $gpsfile)" | gawk -F_ '{print $2}' | gawk -F. '{print $1}'
      done
    ;;

  -gmtvars)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-gmtvars:      set internal gmt variables
Usage: -gmtvars { PARAMETER1 value1 PARAMETER2 val2 ... }

  Changes the state of a GMT variable (e.g. MAP_FRAME_PEN) using gmtset

Example:
tectoplot -gmtvars { MAP_ANNOT_OFFSET_PRIMARY 4p MAP_FRAME_TYPE fancy } -a -o example_gmtvars
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if [[ ${2:0:1} == [{] ]]; then
      info_msg "[-gmtvars]: GMT argument string detected"
      shift
      while : ; do
          [[ ${2:0:1} != [}] ]] || break
          gmtv+=("${2}")
          shift
      done
      shift
      GMTVARS="${gmtv[@]}"
    fi
    usecustomgmtvars=1
    info_msg "[-gmtvars]: Custom GMT variables: ${GMVARS[@]}"
    ;;

  -gridlabels) # args: string (quoted)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-gridlabels:   specify how map axes are presented and labeled
Usage: -gridlabels [optstring]

  This option is used to set map axis labeling. Lower case
  letters indicate no labelling, upper case letters indicate labeling.
  b/S: bottom unlabeled / bottom labeled
  l/W: left unlabeled / left labeled
  t/N: top unlabeled / top labeled
  r/E: right unlabeled / right labeled


Example:
tectoplot -r CR -gridlabels EWns -a -o example_gridlabels
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    GRIDCALL="${2}"
    shift
    ;;

  -gres)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-gres:         specify dpi of most grid plotting options
Usage: -gres [dpi]

  GMT plots grids at their native resolution, creating very large files in some
  cases. Use this option to set the dpi of plotted grids. Resampling is done at
  the plotting step.

  Note: Doesn't affect many grids currently!

--------------------------------------------------------------------------------
EOF
shift && continue
fi

    if arg_is_positive_float $2; then
      info_msg "[-gres]: Set grid output resolution to ${2} dpi"
      GRID_PRINT_RES="-E${2}"
    else
      info_msg "[-gres]: Cannot understand dpi value ${2}. Using native resolution."
      GRID_PRINT_RES=""
    fi
    shift
    ;;

  -i) # args: number
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-i:            rescale velocity vectors
Usage: -i [factor]

  Rescale GPS, plate motion, and other velocity vectors by the given factor.

Example:
tectoplot -a -g PA -i 3 -a -arrow wider -o example_i
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    VELSCALE=$(echo "${2} * $VELSCALE" | bc -l)
    info_msg "[-i]: Vectors scaled by factor of ${2}, result is ${VELSCALE}"
    shift
    ;;

  -inset)
  INSET_ONOFFCODE="j"
  INSET_JUST_CODE="TR"
  INSET_LINE_COLOR="black"
  INSET_LINE_WIDTH="2p"
  insetplacedflag=1
  INSET_FILL=""
  INSET_TRANS=0
  INSET_SIZE="1.5i"
  INSET_BOX_COLOR="white"
  INSET_BOX_TRANS=0
  insetfillflag=0
  INSET_XOFF=0
  INSET_YOFF=0
  INSET_DH=30
  INSET_DV=50

if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-inset:        place an inset globe showing map aoi
Usage: -inset [formula] [[options]
Usage: -inset [[options]]

  formulas:
  country              inset map or colored countries and white sea
                       Useful options: onmap, -pgs, degw

  topo                 inset map of GMT shaded relief, high saturation
  topot0               inset map of -t0 shaded relief, low saturation
  plates               inset map of tectonic plates (MORVEL56), motions, etc.

  Plot an inset globe. Default location is lower left of map; can be modified
  with x_shift and y_shift values.

  [[options]]
  onmap  [[just]]      place inset within map area
  offmap [[just]]      place inset outside of map area
  size [inches]        size of inset in inches [${INSET_SIZE}]
  degw [number]        radius of inset area in degrees
  xoff [number]        shift in X direction by number of inches
  yoff [number]        shift in Y direction by number of inches
  line [color] [width] symbology of box outlining map region
  args [args]          quoted string with tectoplot arguments for inset map
  proj [args]          quoted string with -r and -RJ tectoplot arguments for inset
  dh [number]          horizontal offset of inset, points [${INSET_DH}]
  dv [number]          vertical offset of inset, points [${INSET_DV}]
  frame [size] [color] plot a thick frame line behind inset frame

Example:
tectoplot -a -inset size 2i onmap TR -o example_inset
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    if [[ $2 == "country" ]]; then
      shift
      shift
      set -- "blank" "size" "2i" "args" "-pgo -t -tdc -countries cpt categorical trans 10 -a -whiteframe 10p -pss 3" "$@" "-tcycle"
    elif [[ $2 == "topo" ]]; then
      shift
      shift
      set -- "blank" "size" "2i" "args" "-t 01m -t0 -tdc -whiteframe 10p -pss 3" "$@"
    elif [[ $2 == "topot0" ]]; then
      shift
      shift
    elif [[ $2 == "plates" ]]; then
      shift
      shift
      set -- "blank" "size" "2i" "args" "\"-setvars { PLATEVEC_COLOR white } -t 10m -t0 -tx -tpct 2 90 -p MORVEL -a -pc random 60 -pf 1000 -pa notext -pvl -whiteframe 10p -pss 3\"" "$@"
    fi



    while ! arg_is_flag $2; do
      case $2 in
        frame)
          shift
          INSET_WHITEFRAME_SIZE=10p
          INSET_WHITEFRAME_COLOR="white"
          if ! arg_is_flag $2; then
            INSET_WHITEFRAME_SIZE="${2}"
            shift
          else
            echo "[-inset]: option frame requires size argument (e.g. 10p)"
            exit 1
          fi
          if ! arg_is_flag $2; then
            INSET_WHITEFRAME_COLOR="${2}"
            shift
          else
            echo "[-inset]: option frame requires color argument (e.g. white)"
            exit 1
          fi
          INSET_ARGS="${INSET_ARGS} -whiteframe ${INSET_WHITEFRAME_SIZE} ${INSET_WHITEFRAME_COLOR}"
        ;;
        onmap|offmap)
          insetplacedflag=1
          offmapflag=0
          [[ ${2} == "offmap" ]] && offmapflag=1
          shift
          if [[ ${2:0:1} =~ [B,M,T,L,C,R,U] && ${2:1:1} =~ [B,M,T,L,C,R] ]]; then
            INSET_JUST_CODE="${2:0:2}"
            shift
          fi
          [[ $offmapflag -eq 1 ]] && INSET_ONOFFCODE="J" || INSET_ONOFFCODE="j"
        ;;
        size)
          shift
          if ! arg_is_flag $2; then
            INSET_SIZE="${2}"
            shift
          else
            echo "[-inset]: option size requires argument (e.g. 2i)"
            exit 1
          fi
        ;;
        box)
          shift
          insetfillflag=1
        ;;
        trans)
          shift
          if ! arg_is_positive_float $2; then
            echo "[-inset]: trans option requires number argument"
            exit 1
          else
            INSET_TRANS=$2
            shift
          fi
        ;;
        args)

          # We have to account for situations where the tectoplot command looks
          # like args "arg1 arg2" args "a b c" where "a is an argument, b is
          # and argument, and c" is an argument. This is due to auto_tectoplot.sh
          # passing quoted strings to tectoplot

          shift
          if [[ "${2:0:1}" != "\"" ]]; then
            if [[ $INSET_ARGS == "" ]]; then
              INSET_ARGS="${2}"
            else
              INSET_ARGS="${INSET_ARGS} ${2}"
            fi
          elif [[ "${2:0:1}" == "\"" && "${2: -1}" == "\"" ]]; then
            if [[ $INSET_ARGS == "" ]]; then
              INSET_ARGS="${2:1:${#2}-2}"
            else
              INSET_ARGS="${INSET_ARGS} ${2:1:${#2}-2}"
            fi
          elif [[ "${2:0:1}" == "\"" && "${2: -1}" != "\"" ]]; then
            this_arg=$2
            shift
            while [[ "${2: -1}" != "\"" && $2 != "" ]]; do
              this_arg="${this_arg} ${2}"
              shift
            done
            this_arg="${this_arg} ${2}"
            cut_arg=${this_arg:1:${#this_arg}-2}
            if [[ $INSET_ARGS == "" ]]; then
              INSET_ARGS="${cut_arg}"
            else
              INSET_ARGS="${INSET_ARGS} ${cut_arg}"
            fi
          fi
          shift
        ;;
        proj)
          shift
          INSET_PROJ="${2}"
          insetprojflag=1
          shift
        ;;
        degw)
          shift
          if ! arg_is_flag $2; then
            INSET_DEGWIDTH="${2}"
            shift
          else
            echo "[-inset]: option degwidth requires argument (e.g. 20)"
            exit 1
          fi
        ;;
        line)
          shift
          if ! arg_is_flag $2; then
            INSET_LINE_COLOR="${2}"
            shift
          else
            echo "[-inset]: option line requires color argument (e.g. black)"
            exit 1
          fi
          if ! arg_is_flag $2; then
            INSET_LINE_WIDTH="${2}"
            shift
          else
            echo "[-inset]: option line requires width argument (e.g. 2p)"
            exit 1
          fi
        ;;
        xoff)
          shift
          if ! arg_is_flag $2; then
            INSET_XOFF="${2}"
            shift
          else
            echo "[-inset]: option xoff requires argument (e.g. 2i)"
            exit 1
          fi
        ;;
        yoff)
          shift
          if ! arg_is_flag $2; then
            INSET_YOFF="${2}"
            shift
            else
            echo "[-inset]: option yoff requires argument (e.g. 2i)"
            exit 1
          fi
        ;;
        dh)
          shift
          if ! arg_is_flag $2; then
            INSET_DV="${2}"
            inset_customdvflag=1
            shift
            else
            echo "[-inset]: option dh requires argument in points"
            exit 1
          fi
        ;;
        dv)
          shift
          if ! arg_is_flag $2; then
            INSET_DH="${2}"
            inset_customdhflag=1
            shift
            else
            echo "[-inset]: option dh requires argument in points"
            exit 1
          fi
        ;;
        *)
          echo "[-inset]: option $2 not recognized."
          exit 1
        ;;
      esac
    done

    addinsetplotflag=1
    [[ $insetfillflag -eq 1 ]] && INSET_FILL="-F+c2p+gwhite@${INSET_TRANS}" || INSET_FILL=""

    case ${INSET_ONOFFCODE} in
      j)
        [[ $inset_customdhflag -ne 1 ]] && INSET_DH=10
        [[ $inset_customdvflag -ne 1 ]] && INSET_DV=10
      ;;
      J)
        [[ $inset_customdhflag -ne 1 ]] && INSET_DH=50
        [[ $inset_customdvflag -ne 1 ]] && INSET_DV=30
      ;;
    esac

    if [[ $INSET_ARGS == "" ]]; then
      INSET_ARGS="-t -tdc -a -pgo -pss $(echo ${INSET_SIZE} -whiteframe 10p | gawk '{print $1+0}')"
    fi


    ;;

  -keepopenps) # args: none
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-keepopenps:    keep ps file open for subsequent plotting
Usage: -keepopenps

  Allow subsequent plotting and don't attempt to convert unclosed PS to PDF.

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    keepopenflag=1
    KEEPOPEN="-K"
    ;;

	-kg) # args: none
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-kg:           plot strike and dip symbols for focal mechanism nodal planes
Usage: -kg

  Currently only works for thrust type focal mechanisms. [TO UPDATE]

  The N1 nodal plan has the lower dip value; N2 has a higher dip. The N1/N2
  planes can be selected using the option -kl.

Example:
tectoplot -a -kg -kl 1 -o example_kg
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
		calccmtflag=1
    plotcmtfromglobal=1

		strikedipflag=1
		plots+=("kingeo")
		;;

  -kl) # args: string
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-kl:           select nodal planes 1 or 2
Usage: -kl [number]

  The N1 nodal plan has the lower dip value; N2 has a higher dip.
  1: Use only the N1 nodal planes
  2: Use only the N2 nodal planes
  3: Use both N1 and N2 nodal planes (Default)

Example:
tectoplot -kg -kl 2 -a -o example_kl
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
		calccmtflag=1
		np1flag=1
		np2flag=1
		if arg_is_flag $2; then
			info_msg "[-kl]: Nodal plane selection string is malformed"
		else
			[[ "${2}" =~ .*1.* ]] && np2flag=0
			[[ "${2}" =~ .*2.* ]] && np1flag=0
			shift
		fi
		;;

  -km) # args: number number
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-km:           set magnitude range of cmt kinematics events
Usage: -km [minmag] [maxmag]

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    KIN_MINMAG="${2}"
    KIN_MAXMAG="${3}"
    shift
    shift
    ;;

  -kml)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-kml:          output kml file of map for google earth
Usage: -kml [[kmlres=${KMLRES}]]

  Use -noframe to exclude frame and ensure correct geolocation

  File is output to map/doc.kml in the temporary directory.

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    # KML files need maps to be output in Cartesian coordinates
    # Need to replicate the following commands to plot a geotiff: -Jx projection, -RMINLON/MAXLON/MINLAT/MAXLAT
    #   -geotiff -RJ { -R88/98/17/30 -Jx5i } -gmtvars { MAP_FRAME_TYPE inside }
    if arg_is_flag $2; then
      info_msg "[-kml]: No resolution specified. Using $KMLRES"
    else
      KMLRES="${2}"
      shift
      info_msg "[-kml: KML resolution set to $KMLRES"
    fi
    if [[ $regionsetflag -ne 1 ]]; then
      info_msg "[-kml]: Region should be set with -r before -geotiff flag is set. Using default region."
    fi
    gmt gmtset MAP_FRAME_TYPE inside

    RJSTRING="-R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} -JQ${PSSIZE}i"

    GRIDCALL="bltr"
    dontplotgridflag=1

    usecustomrjflag=1
    insideframeflag=1
    kmlflag=1
    ;;

	-ks)  # args: number
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ks:           set the scale of kinematic objects
Usage: -ks [scale=${KINSCALE}]

  Scale units are currently in default map units (cm???)

Example:
tectoplot -a -kg -ks 0.25 -kl 1 -o example_ks
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
		calccmtflag=1
		KINSCALE="${2}"
		shift
    info_msg "[-ks]: CMT kinematics scale updated to $KINSCALE"
	  ;;

	-kt) # args: string
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-kt:           select focal mechanism kinematic data based on earthquake type
Usage: -kt [typestring]

  Mechanisms are classified by N-T-P axes plunges.

  typestring:
  n: Select normal type mechanisms
  t: Select thrust type mechanisms
  s: Select strike-slip type mechanisms

Example:
tectoplot -a -kv -kt n -kl 2 -o example_kt
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
		calccmtflag=1
		kinnormalflag=0
		kinthrustflag=0
		kinssflag=0
		if arg_is_flag $2; then
			info_msg "[-kt]: kinematics eq type string is malformed"
		else
			[[ "${2}" =~ .*n.* ]] && kinnormalflag=1
			[[ "${2}" =~ .*t.* ]] && kinthrustflag=1
			[[ "${2}" =~ .*s.* ]] && kinssflag=1
			shift
		fi
		;;

 	-kv)  # args: none
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-kv:           plot focal mechanism slip vectors
Usage: -kv [typestring]

  The slip vector of a nodal plane is oriented 90° from the strike of the other
  nodal plane, and represents the horizontal component of motion. It is directly
  related to rake, but is a directional azimuth. Each focal mechanism has two
  slip vectors, only one of which represents the actual earthquake slip.

Example:
tectoplot -t -kv -kt t -kl 1 -o example_kv
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
 		calccmtflag=1
    plotcmtfromglobal=1
 		svflag=1
		plots+=("kinsv")
 		;;

  -legendonly) # args: none
  GVEL=100     # GPS velocity mm/yr
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-legendonly:    plot only the map legend with some variables preset
Usage: -legendonly { [[VAR val]] ... }

  Plots the legend only, skipping the data plotting parts of
  the code. Legend items that require input values (MINELEV, MAXELEV) will use
  default values, or those variables can be specified as arguments.

  Variables recognized by the legend:
  -t: TMIN=${TMIN} TMAX=${TMAX}           Extremal elevation values
  -g: GVEL=${GVEL}                        Maximum GPS velocity
  -v: GMIN=${GMIN} GMAX=${GMAX}    Extremal gravity values
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    makelegendflag=1
    # legendovermapflag=0
    legendonlyflag=1

    # Turn off data plotting
    DATAPROCESSINGFLAG=1
    BOOKKEEPINGFLAG=1
    DATAPLOTTINGFLAG=0

    if [[ ${2:0:1} == [{] ]]; then
      shift
      while : ; do
        [[ ${2:0:1} != [}] ]] || break
        VARIABLE="${2}"
        shift
        VAL="${2}"
        shift
        export $VARIABLE=$VAL
      done
      shift
    fi

    GPSMAXVEL=$GVEL
  ;;

  -legend) # args: none
  LEGEND_JUST_CODES+=("BL")
  LEGEND_ONOFFCODES+=("j")
  legendovermapflag=1
  LEGEND_BORDERON+=("yes")
  LEGEND_BORDERON+=("yes")
  LEGEND_MARGIN=0.1  # inches
  LEGEND_BORDER_WIDTH="0.5p"
  LEGEND_BORDER_COLOR="black"
  LEGEND_FONTSIZE="6p"
  LEGEND_FONT="Helvetica"
  LEGEND_FONTCOLOR="black"
  LEGEND_BAR_HEIGHT="0.1i"
  LEGEND_BAR_GAP="0.175i"
  LEGEND_WIDTH="2i"
  LEGEND_TICK_LENGTH="1p"
  LEGEND_FRAME_WIDTH="0.5p"
  LEGEND_FRAME_COLOR="black"
  colorbarshorizontalflag=0
  noncolorbarhorizontalflag=0

  LEGEND_FONTDEF=${LEGEND_FONTSIZE},${LEGEND_FONT},${LEGEND_FONTCOLOR}
  LEGEND_BORDER="+p${LEGEND_BORDER_WIDTH},${LEGEND_BORDER_COLOR}"
  LEGEND_FRAME_PEN="${LEGEND_FRAME_WIDTH},${LEGEND_FRAME_COLOR}"

if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-legend:       plot a legend drawn from the various map layers
Usage: -legend [width_in=${LEGEND_WIDTH}] [[onmap just=${LEGEND_JUST}]] [[notext]]

  Plots legend entries for layers included on the map.
  bars = colorbar legend items
  nonbars = non-colorbar legend itemst

  Options:
  barsonly                          Only plot colorbars
  nonbarsonly                       Do not plot colorbars
  horiz  [[bars | nonbars]]         Plot legend horizontally (both | bars | nonbars)
  border [none | bars | nonbars]    Set legend border off or on only for bars/nonbars
  font [${LEGEND_FONT}]             Set font [size | size,font | size,font,color]
  barwidth [number]                 Width of color bars, in inches without unit

  onmap [[just=${LEGEND_JUST_CODES[0]}]] [[just2]]     Place the legend(s)
    If two justifications are given, split the legend and use the first code to
    place the color bars and the second code to place the non-colorbars.

    justification codes are two capital letters ()
      B: Bottom M: Center T: Top
      L: Left   C: Middle R: Right

      --------------
      | TL  TM  TR |
      |            |
      | CL  CM  CR |
      |            |
      | BL  BM  BR |
      --------------

   offmap [[just=${LEGEND_JUST_CODES[0]}]] [[just2]]: Place legend outside of the map area
    justification codes are to capital letters

      TL    TM    TR
      --------------
   LT |            | RT
      |            |
   LC |            | RC
      |            |
   LB |            | RB
      --------------
      BL    BM    BR

    Color bars can be placed on/off the map separately from the non-colorbar by
    calling onmap [just1] offmap [just2] or vice versa.

Example:
tectoplot -t -g -pp -ppl 100000 -vc -c -legend offmap BM onmap TR horiz bars border nonbars width 2.5 font 8p
cp tempfiles_to_delete/maplegend.pdf ./example_legend.pdf
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    makelegendflag=1
    # legendovermapflag=0

    makecolorbarsflag=1
    makenoncolorbarsflag=1

    while ! arg_is_flag "${2}"; do
      case "${2}" in
        horiz)
          shift
          colorbarshorizontalflag=1
          noncolorbarhorizontalflag=1
          if [[ $2 == "bars" ]]; then
            noncolorbarhorizontalflag=0
            shift
          elif [[ $2 == "nonbars" ]]; then
            colorbarshorizontalflag=0
            shift
          fi
        ;;
        barsonly)
          shift
          makecolorbarsflag=1
          makenoncolorbarsflag=0
        ;;
        nonbarsonly)
          shift
          makecolorbarsflag=0
          makenoncolorbarsflag=1
        ;;
        border)
          shift
          unset LEGEND_BORDERON
          if [[ $2 == "none" ]]; then
            LEGEND_BORDERON+=("no")
            LEGEND_BORDERON+=("no")
            shift
          elif [[ $2 == "bars" ]]; then
            LEGEND_BORDERON+=("yes")
            LEGEND_BORDERON+=("no")
            shift
          elif [[ $2 == "nonbars" ]]; then
            LEGEND_BORDERON+=("no")
            LEGEND_BORDERON+=("yes")
            shift
          fi
        ;;
        font)
          shift
          if ! arg_is_flag $2; then

            fontargs=($(echo "${2}" | gawk -F, '{print $1, $2, $3}'))
            case ${#fontargs} in
              1)
                LEGEND_FONTSIZE=${fontargs[0]}
              ;;
              2)
                LEGEND_FONTSIZE=${fontargs[0]}
                LEGEND_FONT=${fontargs[1]}
              ;;
              3)
                LEGEND_FONTSIZE=${fontargs[0]}
                LEGEND_FONT=${fontargs[1]}
                LEGEND_FONTCOLOR=${fontargs[2]}
              ;;
              *)
                echo "[-legend]: font option requires size | size,font | size,font,color argument"
                exit 1
              ;;
            esac
            shift
            LEGEND_FONTDEF=${LEGEND_FONTSIZE},${LEGEND_FONT},${LEGEND_FONTCOLOR}
          fi
          ;;
        onmap|offmap)
          # The first time we call this, reset the default
          offmapflag=0
          [[ $usedonoffmapflag -ne 1 ]] && unset LEGEND_JUST_CODES && unset LEGEND_ONOFFCODES && usedonoffmapflag=1
          [[ ${2} == "offmap" ]] && offmapflag=1
          shift
          legendovermapflag=1
          if [[ ${2:0:1} =~ [B,M,T,L,C,R] && ${2:1:1} =~ [B,M,T,L,C,R] ]]; then
            LEGEND_JUST_CODES+=("${2:0:2}")
            [[ $offmapflag -eq 1 ]] && LEGEND_ONOFFCODES+=("J") || LEGEND_ONOFFCODES+=("j")
            shift
          else
            LEGEND_JUST_CODES+=("TL")
            [[ $offmapflag -eq 1 ]] && LEGEND_ONOFFCODES+=("J") || LEGEND_ONOFFCODES+=("j")
          fi
          if [[ ${2:0:1} =~ [B,M,T,L,C,R] && ${2:1:1} =~ [B,M,T,L,C,R] ]]; then
            LEGEND_JUST_CODES+=("${2:0:2}")
            [[ $offmapflag -eq 1 ]] && LEGEND_ONOFFCODES+=("J") || LEGEND_ONOFFCODES+=("j")
            shift
          fi
          ;;
      notext)
        shift
        legendnotextflag=1
        ;;
      width)
        shift
        LEGEND_WIDTH="${2}"
        shift
        # Very wide bars should be made slightly taller and the gap should be made wider
        LEGEND_BAR_HEIGHT=($(echo ${LEGEND_WIDTH} | gawk '{w=$1+0; printf("%si", (w/40>0.1)?w/40:0.1)}'))
        LEGEND_BAR_GAP=($(echo ${LEGEND_WIDTH} | gawk '{w=$1+0; printf("%si", 0.1+(w/20>=0.15)?w/20:0.1)}'))
        LEGEND_TICK_LENGTH=($(echo ${LEGEND_BAR_HEIGHT} | gawk '{w=$1+0; printf("%sp", 72*w/5)}'))
        LEGEND_FRAME_WIDTH=($(echo ${LEGEND_BAR_HEIGHT} | gawk '{w=$1+0; printf("%sp", 72*w/20)}'))
        LEGEND_FRAME_PEN="${LEGEND_FRAME_WIDTH},${LEGEND_FRAME_COLOR}"
        ;;
      *)
        echo "[-legend]: Argument ${2} not recognized"
        exit 1
        ;;
      esac
    done

    ;;

  -litho1)
  LITHO1_TRANS=0
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-litho1:       plot litho1 3d data on cross section
Usage: -litho1 [type] [[options]]

  [type]: "density" | "Vp" | "Vs"

  options:
  trans [percent]        transparency of litho1 data


Example: Plot litho1 cross section
tectoplot -t -aprof CW 10k 1k -litho1 density -profdepth -100 0 -o example_litho1
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    litho1profileflag=1

    if [[ ! -e ${LITHO1_PROG} ]]; then
      echo "[-litho1]: access program ${LITHO1_PROG} is not compiled. Run tectoplot -compile"
      exit 1
    fi
    if arg_is_flag $2; then
      info_msg "[-litho1]: No type specified. Using default $LITHO1_TYPE"
    else
      LITHO1_TYPE="${2}"
      shift
      info_msg "[-litho1]: Using data type $LITHO1_TYPE"
    fi

    [[ $LITHO1_TYPE == "density" ]] && LITHO1_FIELDNUM=2 && LITHO1_CPT=$LITHO1_DENSITY_CPT
    [[ $LITHO1_TYPE == "Vp" ]] && LITHO1_FIELDNUM=3 && LITHO1_CPT=$LITHO1_VELOCITY_CPT
    [[ $LITHO1_TYPE == "Vs" ]] && LITHO1_FIELDNUM=4 && LITHO1_CPT=$LITHO1_VELOCITY_CPT

    while ! arg_is_flag $2; do
      case $2 in
        trans)
          shift
          if arg_is_positive_float $2; then
            LITHO1_TRANS=$2
            shift
          else
            echo "[-litho1]: trans option requires percent argument"
            exit 1
          fi
        ;;
        lab)
          shift
          litho1plotlabflag=1
        ;;
        moho)
          shift
          litho1plotmohoflag=1
        ;;
        nogrid)
          shift
          litho1nogridflag=1
        ;;
        *)
        echo "[-litho1]: option $2 not recognized."
        exit 1
        ;;
      esac
    done

    cpts+=("litho1")
    plots+=("litho1")
    ;;

  -litho1_depth)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-litho1_depth: plot a depth slice of litho1
Usage: -litho1_depth [type=${LITHO1_TYPE}] [depth=${LITHO1_DEPTH}]

  Plots a colored depth slice across LITHO1. Not really tested at all.

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    litho1depthsliceflag=1
    if arg_is_flag $2; then
      info_msg "[-litho1_depth]: No type specified. Using default $LITHO1_TYPE and depth $LITHO1_DEPTH"
    else
      LITHO1_TYPE="${2}"
      shift
      info_msg "[-litho1_depth: Using data type $LITHO1_TYPE"
      if arg_is_flag $2; then
        info_msg "[-litho1_depth]: No depth specified. Using default $LITHO1_DEPTH"
      else
        LITHO1_DEPTH=${2}
        shift
      fi
    fi

    [[ $LITHO1_TYPE == "density" ]] && LITHO1_FIELDNUM=2 && LITHO1_CPT=$LITHO1_DENSITY_CPT
    [[ $LITHO1_TYPE == "Vp" ]] && LITHO1_FIELDNUM=3 && LITHO1_CPT=$LITHO1_VELOCITY_CPT
    [[ $LITHO1_TYPE == "Vs" ]] && LITHO1_FIELDNUM=4 && LITHO1_CPT=$LITHO1_VELOCITY_CPT
    cpts+=("litho1")
    plots+=("litho1_depth")
    ;;

  -debug)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-debug:    print line numbers as they are executed
Usage: -debug

--------------------------------------------------------------------------------
EOF
shift && continue
fi

  ;;

  -megadebug)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-megadebug:    turn on set -x option in bash to see EVERYTHING
Usage: -megadebug

  Prints all processes and script commands with line and time stamps.

  To save an exhaustive log to the file out.txt:
    tectoplot [options] -megadebug > out.txt 2>&1

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    set -x
    ;;

  -mob)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-mob:          create oblique perspective diagrams of all profiles
Usage: -mob [[az=${PERSPECTIVE_AZ}]] [[inc=${PERSPECTIVE_INC}]] [[exag=${PERSPECTIVE_EXAG}]] [[res=${PERSPECTIVE_RES}]]

  Outputs: Profile PDFS are stored in ${TMP}/profiles/*.pdf

  If -showprof is used, place oblique profiles onto the map document instead
  of the flat profiles.

Example: Make oblique perspective cross section the Eastern Mediterranean
tectoplot -r 21 37 23 39 -t -aprof LT 10k 1k -litho1 Vp -mob -profdepth -30 5 -o example_mob
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    clipdemflag=1
    PLOT_SECTIONS_PROFILEFLAG=1
    MAKE_OBLIQUE_PROFILES=1

    if arg_is_flag $2; then
      if [[ $2 =~ ^[-+]?[0-9]*.*[0-9]+$ || $2 =~ ^[-+]?[0-9]+$ ]]; then
        PERSPECTIVE_AZ="${2}"
        shift
      else
        info_msg "[-mob]: No oblique profile parameters specified. Using az=$PERSPECTIVE_AZ, inc=$PERSPECTIVE_INC, exag=$PERSPECTIVE_EXAG, res=$PERSPECTIVE_RES"
      fi
    else
      PERSPECTIVE_AZ="${2}"
      shift
    fi
    if arg_is_flag $2; then
      if [[ $2 =~ ^[-+]?[0-9]*.*[0-9]+$ || $2 =~ ^[-+]?[0-9]+$ ]]; then
        PERSPECTIVE_INC="${2}"
        shift
      else
        info_msg "[-mob]: No view inclination specified. Using $PERSPECTIVE_INC"
      fi
    else
      PERSPECTIVE_INC="${2}"
      shift
    fi
    if arg_is_flag $2; then
      info_msg "[-mob]: No vertical exaggeration specified. Using $PERSPECTIVE_EXAG"
    else
      PERSPECTIVE_EXAG="${2}"
      shift
    fi
    if arg_is_flag $2; then
      info_msg "[-mob]: No resampling resolution specified. Using $PERSPECTIVE_RES"
    else
      PERSPECTIVE_RES="${2}"
      shift
    fi
    info_msg "[-mob]: az=$PERSPECTIVE_AZ, inc=$PERSPECTIVE_INC, exag=$PERSPECTIVE_EXAG, res=$PERSPECTIVE_RES"

    ;;

  -proftopo)
  # PROFTOPOHEIGHT will not be set unless -proftopo is called
  PROFTOPOHEIGHT="0.3i"
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-proftopo:    Plot simplified, exaggerated topo on top of profiles
Usage: -proftopo [[height=${PROFTOPOHEIGHT}]]

--------------------------------------------------------------------------------
EOF
shift && continue
fi
  if ! arg_is_flag $2; then
    PROFTOPOHEIGHT=$2
    shift
  fi
  ;;

  -profsize)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-profsize:     Change default size of profiles
Usage: -profsize [x_size] [[y_size]]

  x_size and y_size must have unit letter (e.g. 2i)

--------------------------------------------------------------------------------
EOF
shift && continue
fi

  if arg_is_flag $2; then
    echo "[-profsize]: Must specify at least one size"
    exit 1
  else
    PROFILE_WIDTH_IN=$2
    shift
  fi

  if ! arg_is_flag $2; then
    PROFILE_HEIGHT_IN=$2
    shift
  fi
  ;;

  -lprof)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-lprof:       Create equally spaced profiles locally orthogonal to a polyline
Usage: -lprof [line_file] [profile_length] [resolution] [distance_sep]

  line_file                   file containing at least one polyline (1 used only)
  profile_length              length of each cross-profile (e.g. 100k)
  resolution                  sampling interval for grid data (e.g. 1k)
  distance_sep                along-profile spacing of cross-profile lines

  Input line formats accepted:
  Google Earth KML
  ESRI Shapefile (polyline)

--------------------------------------------------------------------------------
EOF
shift && continue
fi

  if [[ ! -s ${2} ]]; then
    info_msg "[-lprof]: Input file ${2} doesn't exist or is empty."
    exit 1
  else
    LPROFFILE=$(abs_path ${2})
    shift
  fi

  if arg_is_flag $2; then
    info_msg "[-lprof]: No profile length specified. Using 100k"
    LPROF_LENGTH="100k"
  else
    LPROF_LENGTH="${2}"
    shift
  fi

  if arg_is_flag $2; then
    info_msg "[-lprof]: No sampling interval specified. Using 1k"
    SPROF_RES="1k"
  else
    SPROF_RES="${2}"
    shift
  fi

  if arg_is_flag $2; then
    info_msg "[-lprof]: No cross-line spacing specified. Using 100k"
    LPROF_SPACE="100k"
  else
    LPROF_SPACE="${2}"
    shift
  fi

  if [[ $2 == "flip" ]]; then
    lprofflipflag=1
    shift
  fi

  lprofflag=1

  ;;

  -kprof)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-kprof:        Plot profiles using multiple XY lines extracted from a KML file
Usage: -kprof [kmlfile] [resolution]

  Formats accepted:
  Google Earth KML
  ESRI Shapefile (polyline)

--------------------------------------------------------------------------------
EOF
shift && continue
fi

  if [[ ! -s ${2} ]]; then
    info_msg "[-kprof]: Input file ${2} doesn't exist or is empty."
    exit 1
  else
    KPROFFILE=$(abs_path ${2})
    shift
  fi

  if arg_is_flag $2; then
    info_msg "[-aprof]: No sampling interval specified. Using 1k"
    SPROF_RES="1k"
  else
    SPROF_RES="${2}"
    shift
  fi

  if [[ $2 == "clip" ]]; then
    sprofclipflag=1
    shift
  fi

  kprofflag=1
  ;;

  -profras)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-profras:     Choose an alternative raster to sample using profile tools
Usage: -profras [file] [[z_mult]]

  This will replace the top tile raster and swath sampling raster for
  -sprof, -kprof, -cprof, etc tools with the specified raster. This
  allows sampling of a raster other than topography, or sampling of
  high-resolution topography over a large area while plotting lower
  resolution topography on the basemap.

--------------------------------------------------------------------------------
EOF
shift && continue
fi


  case $2 in
    grav)
      PROFRASTER_SCALE=0.001
      PROFRASTER="grav"
      profrasflag=1
      shift
    ;;
    mag)
      PROFRASTER="mag"
      profrasflag=1
      shift
    ;;
    *)
      if [[ -s $2 ]]; then
        PROFRASTER_SCALE=0.001
        PROFRASTER=$(abs_path $2)
        profrasflag=1
        shift
        if arg_is_float $2; then
          PROFRASTER_SCALE=$2
          shift
        fi
      else
          PROFRASTER=$2
          profrasflag=1

          shift
      fi
      #   echo "[-profras]: File $2 does not exist or is empty; specify file or grav or mag"
      #   exit 1
      # fi
    ;;
  esac
  ;;

  -profbox)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-profbox:     Plot box-and-whisker instead of swath envelope
Usage: -profbox
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  SWATHORBOX="W"
  ;;

  -xprof)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-xprof:        create an across-profile swath
Usage: -sprof [lon1] [lat1] [lon2] [lat2] ... [resolution]

  width is the full profile width
  resolution is the along- and across-profile sample spacing
  width and resolution are specified with a unit (e.g. 100k)

  This option can be called multiple times to add several profiles.
  The width and resolution must be specified for each profile but
  the last values specified will apply to all profiles.

Example:
tectoplot -t -xprof 156.2 -7.5 158.5 -9 1k -pw 100k -o example_xprof
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    # Create a single profile across by constructing a new mprof) file with relevant data types
    # Needs some argument checking logic as too few arguments will mess things up spectacularly
    xprofflag=1
    ((xprofnumber++))

    while arg_is_float $2; do
      if arg_is_float $2 && arg_is_float $3; then
        XPROFPTS[${xprofnumber}]="${XPROFPTS[${xprofnumber}]}$2 $3 "
      else
        echo "[-xprof]: profile points require lon lat pairs"
        exit 1
      fi
      shift
      shift
    done

    if ! arg_is_flag $2; then
      SPROF_RES="${2}"
      shift
    else
      echo "[-xprof]: sample spacing argument required (e.g. 1k)"
      exit 1
    fi

  ;;

  -mprof)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-mprof:        create profiles using a speficied profile control file
Usage: -mprof [filename] [[width=${PROFILE_WIDTH_IN}]] [[height=${PROFILE_HEIGHT_IN}]] [[X=${PROFILE_X}]] [[Y=${PROFILE_Y}]]

  Outputs: Profiles are plotted on map and stored in temp/profiles/ directory

  Control file format:
    # or whitespace lines are comments
    First line starts with @
  ZSCALE is a factor that is used to match z coordinate data [.001] (km -> m)
  SWATH_WIDTH, SAMPLE_SPACING, SWATH_SUBSAMPLE_DISTANCE, SWATH_D_SPACING
     all require a unit [20k]

Profile control file format:
---
# First line begins with @ and sets the data range, zero crossing line, zmatch
@ XMIN[auto] XMAX[auto] ZMIN[auto] ZMAX[auto] CROSSINGZEROLINE_FILE ZMATCH_FLAG[match|null]
# Profile axes labels
L |Label X|Label Y|Label Z
# Various flags to affect plotting behavior
M ...
# Focal mechanism data file
C CMTFILE SWATH_WIDTH ZSCALE GMT_arguments
# Earthquake (scaled) xyzm data file
E EQFILE SWATH_WIDTH ZSCALE GMT_arguments
# XYZ data file
X XYZFILE SWATH_WIDTH ZSCALE GMT_arguments
# Grid line profile
T GRIDFILE ZSCALE SAMPLE_SPACING GMT_arguments
# Grid swath profile
S GRIDFILE ZSCALE SWATH_SUBSAMPLE_DISTANCE SWATH_WIDTH SWATH_D_SPACING
# Top grid for oblique profile
G GRIDFILE ZSCALE SWATH_SUBSAMPLE_DISTANCE SWATH_WIDTH SWATH_D_SPACING CPT
# Point labels
B LABELFILE SWATH_WIDTH ZSCALE FONTSTRING
# Profiles are defined with P command
# XOFFSET/ZOFFSET can be a value, 0 (allow shifting), or null (0 and don't shift)
P PROFILE_ID color XOFFSET ZOFFSET LON1 LAT1 ... ... LONN LATN

Example: Make oblique perspective cross section the Eastern Mediterranean
printf "@ auto auto -30 5 null\n" > ./profile.control
printf "S topo/dem.nc 0.001 1k 1k\n" >> ./profile.control
printf "G topo/dem.nc 0.001 1k 1k cpts/topo.cpt\n" >> ./profile.control
printf "P P_LT black 0 N 29 27.8 32.2 37.4\n" >> ./profile.control
tectoplot -r 21 37 23 39 -t -mprof profile.control -litho1 Vp -mob -profdepth -30 5 -o example_mprof
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if arg_is_flag $2; then
      info_msg "[-mprof]: No profile control file specified."
    else
      if [[ -s $2 ]]; then
        MPROFFILE=$(abs_path $2)
        shift
      else
        info_msg "[-mprof]: Control file ${2} does not exist or has no contents"
        exit 1
      fi
    fi

    if arg_is_flag $2; then
      info_msg "[-mprof]: No profile width specified. Using default ${PROFILE_WIDTH_IN}"
    else
      PROFILE_WIDTH_IN="${2}"
      shift
      PROFILE_HEIGHT_IN="${2}"
      shift
      PROFILE_X="${2}"
      shift
      PROFILE_Y="${2}"
      shift
    fi
    plots+=("mprof")
    clipdemflag=1
    ;;

  -profpts)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-profpts:   plot points sampled by the profile
Usage: -profpts
--------------------------------------------------------------------------------
EOF
shift && continue
fi

PLOT_PROFILEPOINTS=1
  ;;

  -profmatch)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-profmatch:   set profile width in inches to match total length on map
Usage: -profmatch
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  profilematchmaplengthflag=1
  ;;

  -profauto)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-profauto:     allow auto adjust of profile depth but without violating min/max
Usage: -profauto [mindepth] [maxdepth]

  Depths are negative into the Earth, in km, no unit [-30] [5]

--------------------------------------------------------------------------------
EOF
shift && continue
fi
  setprofautodepthflag=1
  SPROF_MINELEV_AUTO="${2}"
  shift
  SPROF_MAXELEV_AUTO="${2}"
  shift
  ;;

  -profdepth)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-profdepth:    set default depth range for profiles
Usage: -profdepth [maxdepth] [mindepth]

  Depths are negative into the Earth and require a unit [-30] [5]

--------------------------------------------------------------------------------
EOF
shift && continue
fi
  setprofdepthflag=1
  SPROF_MINELEV="${2}"
  shift
  SPROF_MAXELEV="${2}"
  shift
  ;;

  -msd)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-msd:          use signed distance for dem generation for multipoint profiles
Usage: -msd

  Kinked profiles will have large zones of no data or data overlap. This option
  uses a 'signed distance' type formulation that measures the distance to the
  closest point on the profile, and the distance along the profile of that
  closest point, to generate X-Y coordinates of swath grid data.

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    info_msg "[-msd]: Note: using signed distance for DEM generation for profiles to avoid kink artifacts."
    DO_SIGNED_DISTANCE_DEM=1
    ;;

  -msl)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-msl:          use only left half of swath domain for perspective diagrams
Usage: -msl

  Swath profiles project data from both sides of a volume. This option will
  display only one half of the volume in a perspective diagram so that the
  projected data fall directly beneath the profile line.

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    info_msg "[-msl]: Plotting only left half of DEM on block profile"
    PERSPECTIVE_TOPO_HALF="+l"
    ;;

  -nocleanup)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-nocleanup:    keep all intermediate files
Usage: -nocleanup

  tectoplot usually deletes various intermediate files; this option keep them.

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    CLEANUP_FILES=0
    ;;

  -noplot)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-noplot:       do not plot anything - exit after initial data management
Usage: -noplot

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    noplotflag=1
    ;;

	-o)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-o:            specify name of output pdf
Usage: -o [filename]

  Final PDF is saved as filename.pdf

--------------------------------------------------------------------------------
EOF
shift && continue
fi
		outflag=1
		MAPOUT="${2}"
		shift
		info_msg "[-o]: Output file is ${MAPOUT}"

    if ! arg_is_flag "${2}"; then
      if [[ -d "${2}" ]]; then
        outputdirflag=1
        OUTPUTDIRECTORY=$(abs_path "${2}")
        shift
      else
        echo "Output directory ${2} does not exist. Exiting."
        exit 1
      fi
    fi
	  ;;

  -ob)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ob:           plot oblique perspective of topography
Usage: -ob [[options...]]

  options:
  az [number=${OBLIQUEAZ}]         direction looking FROM, CW from north
  inc [number=${OBLIQUEINC}]       downward look angle, from horizontal
  vexag [number=${OBLIQUE_VEXAG}]   vertical exaggeration factor
  floor [number=${OBBOXLEVEL}]     plot reference level and fence edges, meters, negative down
  frame [string=${OBBAXISTYPE}]   plain | fancy

Example:
tectoplot -r IT -t -ob 120 20 4 -20000 fancy -o example_ob
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    info_msg "[-ob]: Getting parameters for oblique perspective image."
    obliqueflag=1
    obplotboxflag=0
    OBBAXISTYPE="plain"
    OBBCOMMAND=""
    OBBOXLEVEL=-9999

    while ! arg_is_flag $2; do
      case $2 in
        az)
          shift
          if arg_is_float $2; then
            OBLIQUEAZ=$2
            shift
          else
            echo "[-ob]: az option requires number argument"
            exit 1
          fi
        ;;
        inc)
          shift
          if arg_is_float $2; then
            OBLIQUEINC=$2
            shift
          else
            echo "[-ob]: inc option requires number argument"
            exit 1
          fi
        ;;
        vexag)
          shift
          if arg_is_float $2; then
            OBLIQUE_VEXAG=$2
            shift
          else
            echo "[-ob]: vexag option requires number argument"
            exit 1
          fi
        ;;
        floor)
          shift
          if arg_is_float $2; then
            OBBOXLEVEL=$2
            obplotboxflag=1
            shift
          else
            echo "[-ob]: floor option requires number argument"
            exit 1
          fi
        ;;
        frame)
          shift
          OBBCOMMAND="-Bxaf -Byaf -Bzaf"
          if [[ $2 == "plain" || $2 == "fancy" ]]; then
            OBBAXISTYPE="${2}"
            shift
          else
            echo "[-ob]: frame option requires plain or fancy argument"
            exit 1
          fi
        ;;
        *)
          echo "[-ob]: Option $2 not recognized"
          exit 1
        ;;
      esac
    done
    ;;

  -colorinfo)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-colorinfo:       print info about GMT and colorcet CPTs, GMT color names
Usage: -colorinfo

--------------------------------------------------------------------------------
EOF
shift && continue
fi

    echo ".------------------------------"
    echo "GMT builtin CPTs:"
    cat ${GMTCPTS} | column
    echo ".------------------------------"
    echo "Colorcet CPTs:"
    for cfile in ${CPTDIR}colorcet/*.cpt; do

      gawk < $cfile '
        (NR==1) {
          split($2,str,"/")
          split(str[2],atr,".")
          split(atr[1],btr,"-")

          printf("%s : ", btr[2])
        }
        (NR==5) {
          gsub(/#/,"")
          print
        }'
    done
    echo "-------------------------------"
    echo "GMT colors:"
    cat ${GMTCOLORS} | column
    exit 1
    ;;

  -preview)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-preview:     open low-res preview image only
Usage: -preview [[res]]

--------------------------------------------------------------------------------
EOF
shift && continue
fi
  openflag=0
  previewflag=1
  if arg_is_float $2; then
    PREVIEWRES=$2
    shift
  fi
  ;;

  -noopen)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-noopen:       don't open PDF at end of processing
Usage: -noopen

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    openflag=0
    ;;

  -oto)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-oto:          specify the horizontal=vertical scaling of all profiles
Usage: -oto [[method=${OTO_METHOD}]] [[vert_exag=${PROFILE_VERT_EX}]]

  Options are
    change_h: Change the height of the profile on the page to make H=V*W
    change_z: Change the maximum depth of the profile to make H=V*W
    off:      Turn off any H=V*W scaling
    vert_exag (V) is the vertical exaggeration factor

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    profileonetooneflag=1
    if [[ $2 =~ "change_h" || $2 =~ "change_z" ]]; then
      OTO_METHOD=${2}
      shift
    fi
    if [[ $2 =~ "off" ]]; then
      profileonetooneflag=0
      shift
    fi
    if arg_is_positive_float $2; then
      PROFILE_VERT_EX="${2}"
      shift
    fi
    ;;

	-p) # args: string
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-p:            use plate motion model for plotting or calculations
Usage: -p [[model=${PLATEMODEL}]] [[reference plate ID=${DEFREF}]]

  Use a published plate motion model.
  Models that currently come with tectoplot are:
    MORVEL
    GSRM
    GBM

Example:
tectoplot -r g -p MORVEL -pe -pf 1500 -pa -o example_p
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
		plotplates=1
		if arg_is_flag $2; then
			info_msg "[-p]: No plate model specified. Assuming MORVEL"
      PLATEMODEL="MORVEL"
			POLESRC=$MORVELSRC
			PLATES=$MORVELPLATES
      MIDPOINTS=$MORVELMIDPOINTS
      EDGES=$MORVELPLATEEDGES
			POLES=$MORVELPOLES
      PLATENAMES=$MORVELPLATENAMES

			DEFREF="NNR"
      echo $MORVEL_SHORT_SOURCESTRING >> ${SHORTSOURCES}
      echo $MORVEL_SOURCESTRING >> ${LONGSOURCES}
		else
			PLATEMODEL="${2}"
      shift
	  	case $PLATEMODEL in
			MORVEL)
				POLESRC=$MORVELSRC
				PLATES=$MORVELPLATES
				POLES=$MORVELPOLES
        MIDPOINTS=$MORVELMIDPOINTS
        EDGES=$MORVELPLATEEDGES
				DEFREF="NNR"
        PLATENAMES=$MORVELPLATENAMES

        echo $MORVEL_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        echo $MORVEL_SOURCESTRING >> ${LONGSOURCES}
				;;
			GSRM)
				POLESRC=$KREEMERSRC
				PLATES=$KREEMERPLATES
				POLES=$KREEMERPOLES
        MIDPOINTS=$KREEMERMIDPOINTS
        EDGES=$KREEMERPLATEEDGES
				DEFREF="ITRF08"
        echo $GSRM_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        echo $GSRM_SOURCESTRING >> ${LONGSOURCES}
				;;
			GBM)
				POLESRC=$GBMSRC
				PLATES=$GBMPLATES
				POLES=$GBMPOLES
				DEFREF="ITRF08"
        EDGES=$GBMPLATEEDGES
        MIDPOINTS=$GBMMIDPOINTS
        echo $GBM_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        echo $GBM_SOURCESTRING >> ${LONGSOURCES}
        ;;
      PB)
        POLESRC=$PB2003SRC
        PLATES=$PB2003PLATES
        POLES=$PB2003POLES
        DEFREF="PA"
        EDGES=$PB2003PLATEEDGES
        MIDPOINTS=$PB2003MIDPOINTS
        echo $PB2003_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        echo $PB2003_SOURCESTRING >> ${LONGSOURCES}
        ;;
			*) # Unknown plate model
				info_msg "[-p]: Unknown plate model $PLATEMODEL... using MORVEL56 instead"
				PLATEMODEL="MORVEL"
				POLESRC=$MORVELSRC
				PLATES=$MORVELPLATES
				POLES=$MORVELPOLES
        MIDPOINTS=$MORVELMIDPOINTS
        PLATENAMES=$MORVELPLATENAMES
				DEFREF="NNR"
				;;
			esac
      # Check for a reference plate ID
      if arg_is_flag $2; then
  			info_msg "[-p]: No manual reference plate specified."
      else
        MANUALREFPLATE="${2}"
        shift
        if [[ $MANUALREFPLATE =~ $DEFREF ]]; then
          manualrefplateflag=1
          info_msg "[-p]: Using default reference frame $DEFREF"
          defaultrefflag=1
        else
          info_msg "[-p]: Manual reference plate $MANUALREFPLATE specified. Checking."
          isthere=$(grep $MANUALREFPLATE $POLES | wc -l)
          if [[ $isthere -eq 0 ]]; then
            info_msg "[-p]: Could not find manually specified reference plate $MANUALREFPLATE in plate file $POLES."
            exit
          fi
          manualrefplateflag=1
        fi
      fi
		fi
		info_msg "[-p]: Plate tectonic model is ${PLATEMODEL}"
	  ;;

  -ppole)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ppole:              plot Euler pole locations
Usage: -ppole [[Pole1]] [[Pole2]] [[...]]

  Plotted poles are relative to reference plate set by -p
  If no poles are specified, plot all poles.

  Poles are colored and labeled by rotation rate.

Example:
tectoplot -r g -p MORVEL -pe -ppole -o example_ppole
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  plots+=("eulerpoles")
  while ! arg_is_flag ${2}; do
    PP_SELECT+=("${2}")
    shift
  done

  ;;

  -printpole)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ppole:           print Euler pole of specified plate relative to reference plate
Usage: -ppole [PlateID1] [[PlateID2]] ...

--------------------------------------------------------------------------------
EOF
shift && continue
fi

  while ! arg_is_flag ${2}; do
    PPOLE_PLATE+=("${2}")
    shift
  done
  printplatesflag=1

  ;;

  -pc)              # PlateID1 color1 PlateID2 color2
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pc:           color plates
Usage: -pc [[random]] [[transparency]]
Usage: -pc [[ID1]] [[ColorID1]] [[TransID1]] [[ID2]] ...

  Color plate polygons using two different schemes:
  random: color all plates randomly using specified transparency
  ID1... : color specified plates using specified colors and transparencies

Example:
tectoplot -r g -p MORVEL -pe -pf 1500 -pc random -o example_pc
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if [[ $2 =~ "random" ]]; then
      shift
      if arg_is_positive_float $2; then
        P_POLYTRANS+=("${2}")
        shift
      else
        P_POLYTRANS+=("50")
      fi
      plots+=("platepolycolor_all")
    else
      while : ; do
        arg_is_flag $2 && break
        P_POLYLIST+=("${2}")
        P_COLORLIST+=("${3}")
        shift
        shift
        if arg_is_positive_float $2; then
          P_POLYTRANS+=("${2}")
          shift
        else
          P_POLYTRANS+=("50")
        fi
      done
      info_msg "[-pc]: Plates to color: ${P_POLYLIST[@]}, colors: ${P_COLORLIST[@]}, trans: ${P_POLYTRANS[@]}"
      plots+=("platepolycolor_list")
    fi
    ;;

  -pa)
  PLATEVEC_TEXT_PLOT=1
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pa:           plot plate motion vectors at grid points
Usage: -pa [[notext]]

  Requires -p to load a plate model
  Requires -px, -pf (evenually add -g -wg???) to create grid point locations.

  notext  : do not plot plate velocity text

Example:
tectoplot -r g -p MORVEL -pe -pf 1500 -pa -o example_pa
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  if [[ $2 == "notext" ]]; then
    PLATEVEC_TEXT_PLOT=0
    shift
  fi

    plots+=("grid")
    ;;

  -ptj)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ptj:         plot plate triple junction points as stars
Usage: -ptj

  Finds triple junctions in the plate edge database and plots them as stars

Example:
tectoplot -r g -a -p MORVEL -ptj -o example_ptj
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  plots+=("triplejunctions")
  ;;

  -pe)  # args: none
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pe:           plot plate boundary lines
Usage: -pe [[width=${PLATELINE_WIDTH}]] [[color=${PLATELINE_COLOR}]]

  Draw lines along plate boundaries.

Example:
tectoplot -r g -p MORVEL -pe -o example_pe
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    if ! arg_is_flag $2; then
      PLATELINE_WIDTH="${2}"       # plate edge line width
      shift
    fi
    if ! arg_is_flag $2; then
      PLATELINE_COLOR="${2}"       # plate edge line color
      shift
    fi
    plots+=("plateedge")
    ;;

  -pf) # args: number
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pf:           create grid of almost equally spaced points with fibonacci spiral
Usage: -pf [[distance=${FIB_KM}]] [[nolabels]]

  Grid points are located at approximately equal spacing using a Fibonacci
  spiral.

Example:
tectoplot -r g -p MORVEL -pe -pf 1500 -pa -o example_pf
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    gridfibonacciflag=1
    makegridflag=1
    FIB_KM="${2}"
    # FIB_N=$(echo "510000000 / ( $FIB_KM * $FIB_KM - 1 ) / 2" | bc)
    FIB_N=$(echo "510000000 / ( $FIB_KM * $FIB_KM ) / 2" | bc)

    shift
    if arg_is_flag $2; then
      info_msg "[-pf]: Plotting text labels for plate motion vectors"
    elif [[ $2 == "nolabels" ]]; then
      PLATEVEC_TEXT_PLOT=0
      shift
    fi
    ;;

  -pi)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pi:           create grid from a file of specified points
Usage: -pi [file]

--------------------------------------------------------------------------------
EOF
shift && continue
fi

    if arg_is_flag "${2}"; then
      info_msg "[-pi]: No file specified"
    else
      PI_GRIDFILE=$(abs_path "${2}")
      shift

      if [[ ${PI_GRIDFILE} == *".kml" ]]; then
        # echo "KML input file"
        kml_to_points ${PI_GRIDFILE} kml_points.xy
        PI_GRIDFILE=$(abs_path kml_points.xy)
      fi

      # if [[ ! -s "${2}" ]]; then
      #   info_msg "[-pi]: File ${2} does not exist. Assuming it will when plotting happens."
      #   shift
      # else
      #   PI_GRIDFILE=$(abs_path "${2}")
      #   shift



      makegridflag_gridfile=1
      makegridflag=1
      # fi
    fi

    ;;

  -ppf)  # -ppf: plot grid points
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ppf:          plot grid points
Usage: -ppf

--------------------------------------------------------------------------------
EOF
shift && continue
fi

    plots+=("gridpoints")
    ;;

  -pg)   # -pg: use polygon file to select data
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pg:           use polygon file to select data
Usage: -pg [ filename | GMTcode | fe ] [[show]]

  Select seismicity data within polygon.
  Polygon file is either XY format or is the first feature in a KML file
  GMTcode is any GMT region code consistent with pscoast -E{code} -M, e.g. US.MT
  fe: use the Flinn-Engdahl polygons specified by -feg or -fes
  show: plot the polygon boundary

Example:
printf "23 37\n23 40\n27 40\n27 38\n" > ./poly.xy
tectoplot -r GR -a -pg ./poly.xy show -z -o example_pg
rm -f ./poly.xy
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    while ! arg_is_flag "${2}"; do
      case "${2}" in
        show)
          info_msg "[-pg]: Plotting polygon AOI"
          plots+=("polygonaoi")
        ;;
        fe)
          info_msg "[-pg]: Using Flinn-Engdahl polygons from -fe"
          POLYGONAOI=$(abs_path ${TMP}"fe_region.txt")
          polygonselectflag=1
          fixselectpolygonsflag=1
        ;;
        *)
          if [[ ! -s "${2}" ]]; then
            info_msg "[-pg]: Polygon file ${2} does not exist or is empty. Treating string as a GMT region code!"
            gmt pscoast -E"${2}" -M > gmt_polyselect.txt
            if [[ -s gmt_polyselect.txt ]]; then
              POLYGONAOI=$(abs_path gmt_polyselect.txt)
              polygonselectflag=1
              fixselectpolygonsflag=1
            fi
          else
            POLYGONAOI=$(abs_path "${2}")
            if [[ ${POLYGONAOI} =~ ".kml" ]]; then
              kml_to_first_xy ${POLYGONAOI} pg_poly.xy
              POLYGONAOI=$(abs_path pg_poly.xy)
            fi
            polygonselectflag=1
            fixselectpolygonsflag=1
          fi
        ;;
      esac
      shift
    done

    ;;

  -whiteframe)
  WHITEFRAME_WIDTH=10p
  WHITEFRAME_COLOR="white"
  whiteframeflag=0

if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-whiteframe:     plot a thick white map frame before any other layers
Usage: -whiteframe [[width=${WHITEFRAME_WIDTH}]]

Example:
tectoplot -r GR -a -noframe -o example_noframe
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  if ! arg_is_flag $2; then
    WHITEFRAME_WIDTH=$2
    shift
  fi
  if ! arg_is_flag $2; then
    WHITEFRAME_COLOR=$2
    shift
  fi
  whiteframeflag=1
  ;;

  -navticks)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-navticks:     plot navigation ticks
Usage: -navticks
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  plots+=("navticks")

  ;;

  -noframe) # -noframe: do not plot coordinate grid or map frame
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-noframe:      do not plot coordinate grid or map frame
Usage: -noframe [[top]] [[left]] [[bottom]] [[right]]

  If no options are given, do not label the border at all.
  If options are given, label all borders EXCEPT those listed.

Example:
tectoplot -r GR -a -noframe -o example_noframe
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    GRIDCALL="NESW"

    if arg_is_flag "${2}"; then
      GRIDCALL="blrt"
      dontplotgridflag=1
    else
      while ! arg_is_flag "${2}"; do
        case "${2}" in
          top)
            GRIDCALL=$(echo $GRIDCALL | tr 'N' 't')
            ;;
          left)
            GRIDCALL=$(echo $GRIDCALL | tr 'W' 'l')
            ;;
          bottom)
            GRIDCALL=$(echo $GRIDCALL | tr 'S' 'b')
            ;;
          right)
            GRIDCALL=$(echo $GRIDCALL | tr 'E' 'r')
            ;;
        esac
        shift
      done
    fi
    ;;

  -cutframe) # -cutframe: plot a frame element to facilitate cutting
  # Default cutframe distance is 2 inches
  CUTFRAME_DISTANCE=2
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-cutframe:       plot frame element to facilitate cutting
Usage: -cutframe [[distance=${CUTFRAME_DISTANCE}]]

  Places an unadorned rectangular frame around the map beyond the label extent
  in order to allow uniform cropping of the page to make superimposition of
  PDFs easier.

  distance is given without units, and is in inches

Example:
tectoplot -a -cutframe -o example_cutframe
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
cutframeflag=1

  if arg_is_positive_float $2; then
    CUTFRAME_DISTANCE="${2}"
    shift
  fi

  plots+=("cutframe")
  ;;

  -pgo) # -pgo: plot parallel and meridian lines as a map layer
  GRIDLINE_COLOR=black
  GRIDLINE_WIDTH=0.2p
  GRIDLINE_TRANS=0
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pgo:      plot parallel and meridian lines as a map layer
Usage: -pgo [[options]]

  Spacing is determined automatically by tectoplot or by setting -pgs [interval]

  Options:
  color [color]                  Gridline color
  width [width]                  Gridline width
  trans [transparency %]         Gridline transparency

Example:
tectoplot -a -pgo -o example_pgo
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    while ! arg_is_flag $2; do
      case $2 in
        color)
          shift
          GRIDLINE_COLOR=$2
          shift
        ;;
        width)
          shift
          GRIDLINE_WIDTH=$2
          shift
        ;;
        trans)
          shift
          GRIDLINE_TRANS=$2
          shift
        ;;
        *)
          echo "[-pgo]: Option $2 not recognized"
          exit 1
        ;;
      esac
    done

    plots+=("graticule_grid")
    ;;

  -pgs) # -pgs: override automatic axis interals and gridline spacing
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pgs:          override automatic axis interals and gridline spacing
Usage: -pgs [degree]

  Use -pgo to plot gridlines.

Example:
tectoplot -a -pgo -pgs 0.3 -o example_pgs
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    overridegridlinespacing=1
    OVERRIDEGRID="${2}"
    shift
    ;;

  -pl) # -pl: label plates with their id code
PLATELABEL_COLOR="black"     # color of plate label
PLATELABEL_SIZE="10p"         # size of plate label
PLATELABEL_FONT=${PLATELABEL_SIZE},Helvetica,${PLATELABEL_COLOR}
PLATELABEL_FULL=0
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pl:           label plates with their id code
Usage: -pl [[font]] [[full]]

  Use -p to set plate model.

  font: set font for labels
  full: print the full plate name if available; otherwise print plate ID

Example:
tectoplot -r =EU -p -pe -pl -o example_pl
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    if ! arg_is_flag $2; then
      PLATELABEL_FONT=$2
      shift
    fi

    if [[ $2 == "full" ]]; then
      PLATELABEL_FULL=1
    fi

    plots+=("platelabel")
    ;;

  -pos) # -pos:  shift origin of plot before plotting
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pos:          shift origin of plot before plotting
Usage: -pos [xshift=${PLOTSHIFTX}] [yshift=${PLOTSHIFTY}]

  shift amount includes unit (e.g. 3i for 3 inches)
  This command is mostly used with -ips when plotting onto an open EPS file.
  Normally, the map is plotted on a very large canvas and then cropped

--------------------------------------------------------------------------------
EOF
shift && continue
fi
  # args: string string (e.g. 5i)
    plotshiftflag=1
    PLOTSHIFTX="${2}"
    PLOTSHIFTY="${3}"
    shift
    shift
    ;;

  -plist) # -plist: print rotation poles relative to reference frame
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-plist:        print rotation poles relative to reference frame
Usage: -plist

--------------------------------------------------------------------------------
EOF
shift && continue
fi
  plistflag=1
  ;;

  -pr) # -pr: plot plate rotation small circles with arrows
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pr:           plot plate rotation small circles with arrows
Usage: -pr [[latstep=${LATSTEPS}]]

  Note: This routine is kind of broken for some reason? Some plates do not
  produce small circles from gmt project....

  visualizes plate motions via small circles centered on the pole of rotation.
  The spacing between small circles is given as a colatitude step in degrees.

Example:
tectoplot -r PA -p MORVEL -t -pr -o example_pr
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    if arg_is_flag $2; then
      info_msg "[-pr]: No colatitude step specified: using ${LATSTEPS}"
    else
      LATSTEPS="${2}"
      shift
    fi
    plots+=("platerotation")
    platerotationflag=1
    ;;

  -prv) # plate relative velocity magnitude
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-prv:          plot plate relative velocities
Usage: -prv

  Plots points at plate boundary segment midpoints colored by local plate-plate
  velocity. This is the predicted plate boundary fault full slip rate.

  Maybe should be modified to plot the plate boundary lines themselves?

Example:
tectoplot -r ID -p -prv -a -o example_prv
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    plots+=("platerelvel")
    cpts+=("platerelvel")

    doplateedgesflag=1
    ;;

  -ps) # -ps:  print list of plates in selected plate model, then exit
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ps:           print list of plates in selected plate model, then exit
Usage: -ps

  Prints plates from the selected model and plates within the AOI, then exits.

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    outputplatesflag=1
    ;;

  -psel) # -psel: specify profiles to plot
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-psel:         specify profiles to plot
Usage: -psel PROF_1 PROF_3 ...

  Prints plates from the selected model and plates within the AOI, then exits.

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    selectprofilesflag=1

    if [[ ${2:0:1} == [-] || -z $2  ]]; then
      info_msg "[-psel]: No profile IDs specified on command line"
      exit 1
    else
      while : ; do
        arg_is_flag $2 && break
        PSEL_LIST+=("${2}")
        shift
      done
    fi
    #
    # echo "Profile list is: ${PSEL_LIST[@]}"
    # echo ${PSEL_LIST[0]}
    ;;

  -pss) # -pss: set the width of the map area in inches
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pss:          specify width of map
Usage: -pss {size; inches}

size does not have units and is in inches
Adjusts map frame width. This affects -gres and also the relative size of
symbols vs plotted grid data.

Example:
tectoplot -r TW -a -pss 3 -pgs 1 -o example_pss
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  shift
  ;;

  -pvl) # -pvl: plot plate edges colored by relative motion style
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pvl:           plot plate edges colored by relative motion style
Usage: -pvl

Example:
tectoplot -r g -p MORVEL -pvl -o example_pvl
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  doplateedgesflag=1
  plots+=("plateedgecolor")

  ;;

  -pv) # -pv: plot plate differential velocity vectors
  PVHEAD=0.1i                  # symbol size for strike-slip relative V
  PVFORMAT="0.06/0.18/0.10"    # Experimental head size for plate relative V

if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pv:           plot plate differential velocity vectors
Usage: -pv [[cutoff=${PDIFFCUTOFF}]]

  Plot arrows across plate boundaries indicating direction and sense of relative
  motion. Divergent arrows at divergent boundaries, convergent arrows etc., and
  offset wedges indicating dextral or sinistral slip.

  Cutoff value is the distance in degrees separating plotted velocity elements.
  This is because some plate boundaries are very high resolution producing way
  too many arrows.

Example:
tectoplot -r SB -a -p -pe -pv 1 -o example_pv
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    doplateedgesflag=1
    plots+=("platediffv")
    if arg_is_flag $2; then
      info_msg "[-pv]: No cutoff value specified. Disabling."
      platediffvcutoffflag=0
    else
      PDIFFCUTOFF="${2}"
      info_msg "[-pv]: Cutoff is $PDIFFCUTOFF"
      shift
      platediffvcutoffflag=1
    fi
    ;;

  -pvg) # -pvg: plot plate velocity as a colored grid
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pvg:          plot plate velocity as a colored grid
Usage: -pvg [[resolution=${PLATEVELRES}]]

  Plot colored plate velocity grid calculated at the specified resolution.

Example:
tectoplot -r =SA -a -p -pvg -pe -o example_pvg
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    platevelgridflag=1
    plots+=("platevelgrid")
    cpts+=("platevelgrid")

    if arg_is_flag $2; then
      info_msg "[-pvg]: No resolution or rescaling specified. Using rescale=no; res=${PLATEVELRES}"
    else
      info_msg "[-pvg]: Resolution set to ${2}"
      PLATEVELRES="${2}"
      shift
    fi
    if arg_is_flag $2; then
      info_msg "[-pvg]: No rescaling of CPT specified"
    elif [[ ${2} =~ "rescale" ]]; then
      rescaleplatevecsflag=1
      info_msg "[-pvg]: Rescaling plate velocity CPT"
      shift
    else
      info_msg "[-pvg]: Unrecognized option ${2}"
      shift
    fi
    ;;

  -px) # -px: generate a regularly spaced lat/lon grid
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-px:           generate a regularly spaced lat/lon grid
Usage: -px [interval=${GRIDSTEP}]

  Grid points are at regularly spaced geographic coordinates.

Example: Plot plate velocity vectors in MORVEL NNR around South America
tectoplot -r =SA -a -p -pa -px 5 -pe -i 2 -o example_px
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    makelatlongridflag=1
    makegridflag=1
		GRIDSTEP="${2}"
		shift
    # plots+=("grid")
		info_msg "[-px]: Plate model grid step is ${GRIDSTEP}"
	  ;;

  -pz) # -pz: plot the angle between plate velocity and plate edge direction
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pz:           plot the angle between plate velocity and plate edge direction
Usage: -pz [[scale=${AZDIFFSCALE}]]

  Plot the obliquity of plate motion relative to the plate boundary.
  scale=  size of dots
  Standard colors:
  green=  right lateral
  yellow= left lateral
  red=    divergent
  blue=   convergent

Example: Plot plate velocity vectors and -pz in MORVEL NNR around South America
tectoplot -r =SA -a -p -px 1 -pe -pz -o example_pz
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if arg_is_flag $2; then
      info_msg "[-pz]: No azimuth difference scale indicated. Using default: ${AZDIFFSCALE}"
    else
      AZDIFFSCALE="${2}"
      shift
    fi
    doplateedgesflag=1
    plots+=("plateazdiff")
    ;;

	-r) # -r: specify the area of interest of the map

if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-r:            specify the area of interest of the map
Usage: -r [options]

Global extent (-180:180 longitude and -90:90 latitude)
-r g

Use GMT region ID codes to specify the region:
-r [GMT RegionID]    e.g.   -r ID  OR  -r =NA,SA  OR  -r IT+R5  etc.

Use a saved custom region (-radd, -rdelete, -rlist):
-r [CustomRegionID]  e.g.   -r BaliLombok_1

Use a rectangular region. All arguments are decimal degrees:
-r [MinLon] [MaxLon] [MinLat] [MaxLat]

Use the extent of an existing XY file (lon lat format), KML file, or grid file.
If file is KML, the extent of the first polyline/polygon is used:
-r [filename] [[degree_buffer]]

Square area centered on a catalog earthquake. -z is required. If mapwidth ends
with k, interpret the buffer as kilometer distance N,S,E,W from point
-r eq [EarthquakeID] [[mapwidth=${EQ_REGION_WIDTH}]]

Square area centered on lat/lon or lon/lat coordinate in flexible format:
          Formats are flexible (e.g. 2°8'12.134' or 2d 8m 12.11s et.)
-r latlon [lat] [lon] [[mapwidth]]
-r lonlon [lon] [lat] [[mapwidth]]

Flinn-Engdahl geographic or seismic region code(s)
-r feg IDnum(1-757) ...
-r fes IDnum(1-50) ...

--------------------------------------------------------------------------------
EOF
shift && continue
fi
  called_r_flag=1
	  if ! arg_is_float "${2}"; then
      # If first argument isn't a number, it is interpreted as a global extent (g), an earthquake event, an XY file, a raster file, or finally as a country code.
# Option 1: Global extent from -180:180 longitude

      # Flinn-Engdahl region, geographic
      if [[ "${2}" == "feg" ]]; then
        shift
        while arg_is_positive_float "${2}"; do
          FE_REGION_ID="${2}"
          shift
          if [[ -s ${FE_REGION_POLY}"flinn_engdahl_${FE_REGION_ID}.txt" ]]; then
            cat ${FE_REGION_POLY}"flinn_engdahl_${FE_REGION_ID}.txt" >> ${TMP}fe_region.txt
          fi
        done

      if [[ -s ${TMP}fe_region.txt ]]; then
        FE_RANGE=($(xy_range ${TMP}fe_region.txt))
        MINLON=$(echo "${FE_RANGE[0]} ${FE_RANGE[1]}" | gawk '{ if ($2-$1 > 358) { print $1 } else { print $1-1 } }')
        MAXLON=$(echo "${FE_RANGE[0]} ${FE_RANGE[1]}" | gawk '{ if ($2-$1 > 358) { print $2 } else { print $2+1 } }')
        MINLAT=$(echo "${FE_RANGE[2]}" | gawk '{print ($1-1>-90)?$1-1:-90}')
        MAXLAT=$(echo "${FE_RANGE[3]}" | gawk '{print ($1+1<90)?$1+1:90}')
      else
        echo "[-r]: Flinn-Engdahl geographic region(s) not recognized."
        exit 1
      fi

        if [[ "${2}" == show ]]; then
          plotselectedfeflag=1
          shift
        fi

      # Flinn-Engdahl region, seismic
      elif [[ "${2}" == "fes" ]]; then
        shift
        while arg_is_positive_float "${2}"; do
          FE_REGION_ID="${2}"
          shift
          if [[ -s ${FE_SEISMIC_POLY}"flinn_engdahl_combined_${FE_REGION_ID}.txt" ]]; then
            cat ${FE_SEISMIC_POLY}"flinn_engdahl_combined_${FE_REGION_ID}.txt" >> ${TMP}fe_region.txt
          fi
        done

        if [[ -s ${TMP}fe_region.txt ]]; then
          FE_RANGE=($(xy_range ${TMP}fe_region.txt))
          MINLON=$(echo "${FE_RANGE[0]} ${FE_RANGE[1]}" | gawk '{ if ($2-$1 > 358) { print $1 } else { print $1-1 } }')
          MAXLON=$(echo "${FE_RANGE[0]} ${FE_RANGE[1]}" | gawk '{ if ($2-$1 > 358) { print $2 } else { print $2+1 } }')
          MINLAT=$(echo "${FE_RANGE[2]}" | gawk '{print ($1-1>-90)?$1-1:-90}')
          MAXLAT=$(echo "${FE_RANGE[3]}" | gawk '{print ($1+1<90)?$1+1:90}')
        else
          echo "[-r]: Flinn-Engdahl seismic region(s) not recognized."
          exit 1
        fi

        if [[ "${2}" == show ]]; then
          plotselectedfeflag=1
          shift
        fi
      elif [[ ${2} == "g" ]]; then
        MINLON=-180
        MAXLON=180
        MINLAT=-90
        MAXLAT=90
        globalextentflag=1
        downsampleslabflag=1   # Global AOI requires downsampled slab2.0 for makeply
        shift

      # Centered on an earthquake event from CMT(preferred) or seismicity(second choice) catalogs.
      # Arguments are eq Event_ID [[degwidth]]
      elif [[ "${2}" == "eq" ]]; then
        setregionbyearthquakeflag=1
        REGION_EQ=${3}
        shift
        shift
        if arg_is_positive_float ${2}; then
          info_msg "[-r]: EQ region width is ${2}"
          EQ_REGION_WIDTH="${2}"
          shift
        elif [[ ${2} == *k ]]; then
          EQ_REGION_WIDTH="${2}"
          shift
        else
          info_msg "[-r]: EQ region width is default ${EQ_REGION_WIDTH}"
        fi
        info_msg "[-r]: Region will be centered on EQ $REGION_EQ with width $EQ_REGION_WIDTH degrees"

      # Set region to be the same as an input lat lon point plus width
      elif [[ "${2}" == "latlon" ]]; then
        LATLON_LAT=$(coordinate_parse "${3}")
        LATLON_LON=$(coordinate_parse "${4}")
        LATLON_DEG="${5}"
        shift
        shift
        shift
        shift

        MINLON=$(echo "$LATLON_LON - $LATLON_DEG" | bc -l)
        MAXLON=$(echo "$LATLON_LON + $LATLON_DEG" | bc -l)
        MINLAT=$(echo "$LATLON_LAT - $LATLON_DEG" | bc -l)
        MAXLAT=$(echo "$LATLON_LAT + $LATLON_DEG" | bc -l)
       info_msg "[-r] latlon: Region is ${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}"

      # Set region to be the same as an input lon lat point plus width
      elif [[ "${2}" == "lonlat" ]]; then
        LATLON_LON=$(coordinate_parse "${3}")
        LATLON_LAT=$(coordinate_parse "${4}")
        LATLON_DEG="${5}"
        shift
        shift
        shift
        shift

        MINLON=$(echo "$LATLON_LON - $LATLON_DEG" | bc -l)
        MAXLON=$(echo "$LATLON_LON + $LATLON_DEG" | bc -l)
        MINLAT=$(echo "$LATLON_LAT - $LATLON_DEG" | bc -l)
        MAXLAT=$(echo "$LATLON_LAT + $LATLON_DEG" | bc -l)
        info_msg "[-r] lonlat: Region is ${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}"

      # Set region to be the same as an input file (raster, XY file)
      elif [[ -s "${2}" ]]; then
        info_msg "[-r]: File specified; trying to determine extent."

        EPSG=$(gdalsrsinfo $2 -o epsg 2>/dev/null | grep "^EPSG" | sed '/^$/d' | head -n 1 | cut -f 2 -d ":")

        if [[ $(echo "$EPSG == 0" | bc) -eq 1 ]]; then
          EPSG="4326"
        fi


        # If we got a result, the file is readable by OGR
        if [[ ! -z ${EPSG} ]]; then

          # Try to use ogrinfo to get the extent
          # EXTENT={MINLON MAXLON MINLAT MAXLAT}
          # Extent: (-118.146888, 33.992453) - (-118.144898, 34.716438)

          ogrinfo -al -so $2 >/dev/null 2>&1

          if [[ $? -eq 0 ]]; then
            EXTENT=($(ogrinfo -al -so $2 | grep "Extent" | sed 's/(//g; s/)//g; s/,//g' | gawk '{print $2, $5, $3, $6}'))
          else
            # try GMT grdinfo
            EXTENT=($(gmt grdinfo -C $2 | gawk '{print $2, $3, $4, $5}'))
          fi

          # Try to use gdalinfo to get the extent
          if [[ -z ${EXTENT[3]} ]]; then
            EXTENT[0]=$(gdalinfo $2 | grep "Lower Left" | tr ',' ' ' | gawk '{print $4}')
            EXTENT[1]=$(gdalinfo $2 | grep "Upper Right" | tr ',' ' ' | gawk '{print $4}')
            EXTENT[2]=$(gdalinfo $2 | grep "Lower Left" | tr ')' ' ' | gawk '{print $5}')
            EXTENT[3]=$(gdalinfo $2 | grep "Upper Right" | tr ')' ' ' | gawk '{print $5}')
          fi

          if [[ -z ${EXTENT[3]} ]]; then
            echo "[-r]: Cannot get extent from file $2 even though ogrsrsinfo sees EPSG code"
            exit 1
          fi

          info_msg "[-r]: For file $2, EPSG is ${EPSG} and extent is ${EXTENT[@]}"


          if [[ ${EPSG} -ne 4326 ]]; then

            # Get extent in whatever CRS the file is in, using the LL and UR bounding box

            echo ${EXTENT[0]} ${EXTENT[2]} > ${TMP}crs.proj
            echo ${EXTENT[0]} ${EXTENT[3]} >> ${TMP}crs.proj
            echo ${EXTENT[1]} ${EXTENT[3]} >> ${TMP}crs.proj
            echo ${EXTENT[1]} ${EXTENT[2]} >> ${TMP}crs.proj

            XYRANGE=($(cat ${TMP}crs.proj | gdaltransform -s_srs "EPSG:${EPSG}" -t_srs "EPSG:4326" | gawk -v CONVFMT="%.17g" '
              BEGIN {
                minx=999
                maxx=-999
                miny=999
                maxy=-999
              }
              {
                miny=($2+0<miny)?$2+0:miny
                maxy=($2+0>maxy)?$2+0:maxy
                minx=($1+0<minx)?$1+0:minx
                maxx=($1+0>maxx)?$1+0:maxx
              }
              END {
                printf("%0.12f %0.12f %0.12f %0.12f\n", minx, maxx, miny, maxy)
              }'))

              info_msg "[-r]: Region estimated from projected bounding box is ${XYRANGE[@]}"
              MINLON=${XYRANGE[0]}
              MAXLON=${XYRANGE[1]}
              MINLAT=${XYRANGE[2]}
              MAXLAT=${XYRANGE[3]}
          else # EPSG 4326, we can just use the extent directly
              MINLON=${EXTENT[0]}
              MAXLON=${EXTENT[1]}
              MINLAT=${EXTENT[2]}
              MAXLAT=${EXTENT[3]}
          fi

        # If the EPSG string is empty, we can try a few other file types
        else
          case $2 in
            *.kml)
              kml_to_first_xy ${2} profile_align.xy
              XYRANGE=($(xy_range profile_align.xy))
              MINLON=${XYRANGE[0]}
              MAXLON=${XYRANGE[1]}
              MINLAT=${XYRANGE[2]}
              MAXLAT=${XYRANGE[3]}
            ;;
            # Not a known file extension
            *)
              # First check if it is a text file with X Y coordinates in the first two columns
              case $(file "${2}") in

                # We can try to use plain text from within the file
                (*\ text|*\ text\ *)
                    info_msg "[-r]: Input file is text: assuming X Y data"

                    # Could add different file formats here, KML etc.
                    XYRANGE=($(xy_range "${2}"))
                    MINLON=${XYRANGE[0]}
                    MAXLON=${XYRANGE[1]}
                    MINLAT=${XYRANGE[2]}
                    MAXLAT=${XYRANGE[3]}

                    if [[ $(echo "$MAXLON > $MINLON" | bc) -eq 1 ]]; then
                      if [[ $(echo "$MAXLAT > $MINLAT" | bc) -eq 1 ]]; then
                        info_msg "Set region to $MINLON/$MAXLON/$MINLAT/$MAXLAT using first two text fields (lon/lat)"
                      else
                        echo "[-r]: Extent inferred from text file is not valid: $MINLON/$MAXLON/$MINLAT/$MAXLAT"
                        exit 1
                      fi
                    fi
                    ;;
                (*\ directory|*\ directory\ *)
                    echo "[-r]: Input file is an existing directory. Not a valid extent."
                    exit 1
                    ;;
                # A non-text file unreadable by GDAL is not useable
                (*)
                    echo "[-r]: Cannot determine extent from file ${2}"
                    exit 1
                    ;;
              esac
              ;;
          esac
        fi

        shift

        # Check for a buffer zone around the inferred extent

        if arg_is_float "${2}"; then
          REGION_BUFDEG="${2}"
          shift
          MINLON=$(echo $REGION_BUFDEG $MINLON | gawk  '{print $2-$1}')
          MAXLON=$(echo $REGION_BUFDEG $MAXLON | gawk  '{print $2+$1}')
          MINLAT=$(echo $REGION_BUFDEG $MINLAT | gawk  '{print ($2-$1<-90)?-90:$2-$1}')
          MAXLAT=$(echo $REGION_BUFDEG $MAXLAT | gawk  '{print ($2+$1>90)?90:$2+$1}')
        fi

        if [[ $(echo "$MAXLON > $MINLON" | bc) -eq 1 ]]; then
          if [[ $(echo "$MAXLAT > $MINLAT" | bc) -eq 1 ]]; then
            info_msg "Set region to $MINLON/$MAXLON/$MINLAT/$MAXLAT"
          else
            echo "[-r]: Extent inferred from file is not valid: $MINLON/$MAXLON/$MINLAT/$MAXLAT"
            exit 1
          fi
        fi

      # A single argument which doesn't match any of the above is a country ID OR a custom ID
      # Custom IDs override region IDs, so we search for that first
      else

        if arg_is_flag $2; then
          # Option 7: No arguments at all means no region
          info_msg "[-r]: No country code or custom region ID specified."
          exit 1
        fi

        [[ ! -s $CUSTOMREGIONS ]] && touch $CUSTOMREGIONS

        ISCUSTOMREGION=($(grep "^${2} " $CUSTOMREGIONS))

        # If the ID is not found in the custom regions file

        if [[ -z ${ISCUSTOMREGION[0]} ]]; then
          # Assume that the string is some kind of country ID code (only option left)
          COUNTRYID=${2}
          shift


          RCOUNTRYTL=($(gmt mapproject -R${COUNTRYID} -WjTL ${VERBOSE}))
          if [[ $? -ne 0 ]]; then
            echo "${COUNTRYID} is not a valid region" > /dev/stderr
            exit 1
          fi

          RCOUNTRYBR=($(gmt mapproject -R${COUNTRYID} -WjBR ${VERBOSE}))
          if [[ $? -ne 0 ]]; then
            echo "${COUNTRYID} is not a valid region" > /dev/stderr
            exit 1
          fi

          if [[ $(echo "${RCOUNTRYTL[0]} > 180 && ${RCOUNTRYBR[0]} > 180" | bc) -eq 1 ]]; then
            RCOUNTRYTL[0]=$(echo "${RCOUNTRYTL[0]} - 360" | bc -l)
            RCOUNTRYBR[0]=$(echo "${RCOUNTRYBR[0]} - 360" | bc -l)
          fi

          MINLON=${RCOUNTRYTL[0]}
          MAXLON=${RCOUNTRYBR[0]}
          MINLAT=${RCOUNTRYBR[1]}
          MAXLAT=${RCOUNTRYTL[1]}
          info_msg "Country [$COUNTRYID] bounding box set to $MINLON/$MAXLON/$MINLAT/$MAXLAT"

        else

          # If the ID IS found in the custom regions file
          usingcustomregionflag=1
          CUSTOMREGIONID=${ISCUSTOMREGION[0]}
          shift

          if [[ $(echo "${ISCUSTOMREGION[1]} >= -360 && ${ISCUSTOMREGION[2]} <= 360 && ${ISCUSTOMREGION[3]} >= -90 && ${ISCUSTOMREGION[4]} <= 90" | bc) -eq 1 ]]; then
            MINLON=${ISCUSTOMREGION[1]}
            MAXLON=${ISCUSTOMREGION[2]}
            MINLAT=${ISCUSTOMREGION[3]}
            MAXLAT=${ISCUSTOMREGION[4]}
            info_msg "Region ID [${2}] bounding box set to $MINLON/$MAXLON/$MINLAT/$MAXLAT"
            ind=5
            while ! [[ -z ${ISCUSTOMREGION[${ind}]} ]]; do
              CUSTOMREGIONRJSTRING+=("${ISCUSTOMREGION[${ind}]}")
              ind=$(echo "$ind+1"| bc)
              usecustomregionrjstringflag=1

              # # Check the custom region strings for projections that require a different bounding box method
              # if [[ ${ISCUSTOMREGION[${ind}]} == *"-JOc"* ]]; then
              #   # echo "Found Oblique Mercator"
              #   boundboxfrompsbasemapflag=1
              # fi

            done
            if [[ $usecustomregionrjstringflag -eq 1 ]]; then
              info_msg "[-r]: customID ${CUSTOMREGIONID} has RJSTRING: ${CUSTOMREGIONRJSTRING[@]}"
            else
              info_msg "[-r]: customID ${CUSTOMREGIONID} has no RJSTRING"
            fi
          else
            info_msg "[-r]: MinLon is malformed: $3"
            exit 1
          fi
        fi
      fi

    # Four numbers in lonmin lonmax latmin latmax order
    else
      if ! arg_is_float $3; then
        echo "MaxLon is malformed: $3"
        exit 1
      fi
      if ! arg_is_float $4; then
        echo "MinLat is malformed: $4"
        exit 1
      fi
      if ! arg_is_float $5; then
        echo "MaxLat is malformed: $5"
        exit 1
      fi
      MINLON="${2}"
      MAXLON="${3}"
      MINLAT="${4}"
      MAXLAT="${5}"
      shift # past argument
      shift # past value
      shift # past value
      shift # past value
    fi

    if [[ $setregionbyearthquakeflag -eq 0 ]]; then

      # Rescale longitudes if necessary to match the -180:180 convention used in this script

  		info_msg "[-r]: Range is $MINLON $MAXLON $MINLAT $MAXLAT"
      # [[ $(echo "$MAXLON > 180 && $MAXLON <= 360" | bc -l) -eq 1 ]] && MAXLON=$(echo "$MAXLON - 360" | bc -l)
      # [[ $(echo "$MINLON > 180 && $MINLON <= 360" | bc -l) -eq 1 ]] && MINLON=$(echo "$MINLON - 360" | bc -l)
      if [[ $(echo "$MAXLAT > 90 || $MAXLAT < -90 || $MINLAT > 90 || $MINLAT < -90"| bc -l) -eq 1 ]]; then
      	echo "Latitude out of range"
      	exit
      fi
      info_msg "[-r]: Range after possible rescale is $MINLON $MAXLON $MINLAT $MAXLAT"

    	# if [[ $(echo "$MAXLON > 180 || $MAXLON< -180 || $MINLON > 180 || $MINLON < -180"| bc -l) -eq 1 ]]; then
      # 	echo "Longitude out of range"
      # 	exit
    	# fi
    	# if [[ $(echo "$MAXLON <= $MINLON"| bc -l) -eq 1 ]]; then
      # 	echo "Longitudes out of order: $MINLON / $MAXLON"
      # 	exit
    	# fi
    	if [[ $(echo "$MAXLAT <= $MINLAT"| bc -l) -eq 1 ]]; then
      	echo "Latitudes out of order"
      	exit
    	fi
  		info_msg "[-r]: Map region is -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}"

      # We apparently need to deal with maps that wrap across the antimeridian? Ugh.
      regionsetflag=1
    fi # If the region is not centered on an earthquake and still needs to be determined

    ;;

  -radd) # -radd: add a custom region definition using final aoi/projection of map
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-radd:         add a custom region definition using final aoi/projection of map
Usage: -radd [CustomRegionID]

  Custom regions save the final inferred AOI (GMT -R) and projection (GMT -J)
  including map size (e.g. 7i), associated with a single word ID key.
  The custom regions file has the format:
  RegionID MinLon MaxLon MinLat MaxLat -R... -J...

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if arg_is_flag $2; then
      info_msg "[-radd]: No region ID code specified. Ignoring."
    else
      REGIONTOADD=$(echo ${2} | gawk '{print $1}')
      addregionidflag=1
      info_msg "[-radd]: Adding or updating custom region ${REGIONTOADD} from -r arguments"
      shift
    fi
    ;;

  -rdel) # -rdel: delete a custom region definition
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-rdel:         delete a custom region definition
-rdel [CustomRegionID]

Delete a custom region ID and then exit.

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if arg_is_flag $2; then
      info_msg "[-rdel]: No region ID code to delete was specified."
    else
      REGIONTODEL=$(echo ${2} | gawk '{print $1}')
      info_msg "[-rdel]: Deleting region ID ${REGIONTODEL} and exiting."
      shift
    fi
    if [[ -s $CUSTOMREGIONS ]]; then
      gawk -v id=${REGIONTODEL} < $CUSTOMREGIONS '{
        if ($1 != id) {
          print
        }
      }' > ./regions.tmp
      mv ./regions.tmp ${CUSTOMREGIONS}
    fi
    # Delete the AOI box
    rm -f ${CUSTOMREGIONSDIR}${REGIONTODEL}.xy
    # Delete any saved colored relief image
    rm -f ${SAVEDTOPODIR}${REGIONTODEL}.tif
    exit
    ;;

  -rlist) # -rlist: list custom region definitions and exit
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-rlist:        list custom region definitions and exit
Usage: -rlist

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    cat ${CUSTOMREGIONS}
    exit
    ;;

  -rect) # -rect: make rectangular map for non-rectangular projections
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-rect:         make rectangular map for non-rectangular projections
Usage: -rect

  Confirmed to work with the following map projections:
    UTM
    Albers|B
    Lambert|L
    Equid|D

Example: Make a rectangular map of a high latitude region with a UTM projection
tectoplot -r -160 -150 54 60 -a -RJ UTM -rect -o example_rect
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    MAKERECTMAP=1
    ;;


  -utmgrid)
  utmgridplotlines=""
  utmgridplotlabels=1
  UTMGRIDFONTSIZE="8p"
  UTMGRIDINTERVAL=50000   # UTM grid interval, meters
  UTMGRIDJUST1="L"        # label justification - default is outside map
  UTMGRIDJUST2="R"        # label justification - default is outside map
  UTMGRIDFILL=""
  UTMGRIDCLIP="-N"

if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-utmgrid:         plot a UTM grid for a specified or inferred zone
Usage: -utmgrid [[zone]] ... [[options]]

  If zone is not specified, determine from map centerpoint.

  Options:
  int          grid interval (meters)
  inside       plot labels inside the map frame
  noline       do not plot grid lines
  nolabel      do not plot grid labels
  nogeo        turn of geographic frame labels
  fontsize     set size of grid line labels

--------------------------------------------------------------------------------
EOF
shift && continue
fi

  if arg_is_positive_float $2; then
    UTMGRIDZONES+=("$2")
    shift
  else
    calcutmgridzonelaterflag=1
  fi

  while ! arg_is_flag $2; do
    case $2 in
      fill)
        shift
        UTMGRIDFILL="-Gwhite"
      ;;
      inside)
        shift
        UTMGRIDJUST1="R"
        UTMGRIDJUST2="L"
        UTMGRIDCLIP=""
      ;;
      int)
        shift
        if arg_is_positive_float $2; then
          UTMGRIDINTERVAL=$2
          shift
        else
          echo "[-utmgrid]: option int requires positive number argument"
          exit 1
        fi
      ;;
      noline)
        utmgridplotlines="+i"
        shift
      ;;
      nolabel)
        utmgridplotlabels=0
        shift
      ;;
      nogeo)
        utmgridnogeoflag=1
        shift
      ;;
      fontsize)
        shift
        if arg_is_flag $2; then
          echo "[-utmgrid]: option fontsize requires an argument (eg 2p)"
          exit 1
        else
          UTMGRIDFONTSIZE="$2"
          shift
        fi
      ;;
      *)
        echo "[-utmgrid]: option $2 not recognized"
        exit 1
      ;;
    esac
  done

  overlayplots+=("utmgrid")

  if [[ $utmgridnogeoflag -eq 1 ]]; then
    GRIDCALL="blrt"
  fi

  ;;

  -frameall)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-frameall:         plot grid labels at all grid-frame intersection points
Usage: -frameall

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    setobliqueframeflag=1
    OBFRAMECMD="--MAP_ANNOT_OBLIQUE=anywhere,lon_horizontal"
  ;;

  -projlegend)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-projlegend:        print projection/scale info in legend
Usage: -projlegend

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    plots+=("projlegend")
  ;;

  -RJ) # -RJ: set map projection

if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-RJ:           set map projection

Set a map scale rather than specifying map width (-pss).
Scale is given in the format 1:scalefactor (e.g. 1:100 or 1:250000)
Usage: -RJ [scale] [[projection code and other options]]

Set UTM projection for AOI given by -r
Usage: -RJ UTM [[utmzone]]
    If utmzone is not specified, it will be determined automatically from the
    central longitude inferred from -r

Set global extent [-180:180;-90:90] with central longitude [central_meridian]
Usage: -RJ [projection] [[central_meridian]]
    Hammer|H
    Winkel|R
    Robinson|N
    Mollweide|W
    VanderGrinten|V
    Sinusoidal|I
    Eckert4|Kf
    Eckert6|Ks

Hemisphere:
Region should be -180:180;minlat:maxlat where latitude range depends on view location
Usage: -RJ Hemisphere or A [[central_meridian]] [[central_latitude]]

Circular plots with a specified horizon distance from center point:
Region should be minlon:maxlon;minlat:maxlat depending on view location and distance
If circle contains north (south) pole, then minlon (maxlon) is 90-view latitude? and
longitude is -180:180. If circle does not contain a pole, then range is
viewlon-angle:viewlon+angle;viewlat-angle:viewlat+angle
Usage: -RJ [projection] [[central_meridian]] [[central_parallel]] [[degree_horizon]]
    Gnomonic|F
    Orthographic|G
    Stereo|S

Cassini: specified by center point and scale
Usage: -RJ Cassini|C [[central_meridian]] [[central_parallel]]

Cylindrical Stereographic: specified by central meridian and standard parallel
Usage: -RJ CylStereo|CS [[central_meridian]] [[standard_parallel]]

Mercator:
Usage: -RJ Mercator|M [[central_meridian]] [[central_parallel]]

Oblique Mercator: specified by center point, azimuth, width and height
Usage: -RJ ObMercA|OA [central_lon] [central_lat] [azimuth] [width_km] [height_km]

Oblique Mercator: specified by a center point, pole location, width, height
Usage: -RJ ObMercC|OC [central_lon] [central_lat] [pole_lon] [pole_lat] [width_km] [height_km]

Transverse Mercator:
Usage -RJ T [central_lon] [central_lat]

Projections with standard parallels:
Usage: -RJ [projection] [[central_lon] [central_lat] [parallel_1] [parallel_2]]
    Albers|B
    Lambert|L
    Equid|D

    If no parameters are given for these -RJ B|L|D, the standard parallels
    are taken to be the maximum and minimum latitudes from -r.

Linear transformation of geographic coordinatesw:
Usage: -RJ Cartesian|X

Example:
tectoplot -r IS -RJ UTM -a -title "UTM projection" -keepopenps
tectoplot -r IS -a -pos 0i -3.5i -title "WGS1984" -gridlabels EWSn -ips tempfiles_to_delete/map.ps -o example_RJ
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

#  done -Ja|A<lon0>/<lat0>[/<horizon>]/<scale>|<width> (Lambert Azimuthal Equal Area). <lon0>/<lat0> is the center of the projection, and <horizon> is max distance from center
#     of the projection (<= 180, default 90). The <scale> can also be given as <radius>/<lat>, where <radius> is the distance in cm to the oblique parallel <lat>.
#  done -Jb|B<lon0>/<lat0>/<lat1>/<lat2>/<scale>|<width> (Albers Equal-Area Conic). Give origin, two standard parallels, and true <scale>.
#  done -Jc|C<lon0>/<lat0>/<scale>|<width> (Cassini). Give central point and <scale>.
#  done -Jcyl_stere|Cyl_stere/[<lon0>/[<lat0>/]]<scale>|<width> (Cylindrical Stereographic). Optionally give central meridian and standard parallel and <scale>. Common
#     parallels: <lat0> = 66.159467 (Miller's modified Gall), 55 (Kamenetskiy's First), 45 (Gall Stereographic), 30 (Bolshoi Sovietskii Atlas Mira), and 0 (Braun)
#     [Default].
#  done -Jd|D<lon0>/<lat0>/<lat1>/<lat2>/<scale>|<width> (Equidistant Conic). Give origin, two standard parallels, and true <scale>.
#  done -Je|E<lon0>/<lat0>[/<horizon>]/<scale>|<width> (Azimuthal Equidistant). <lon0>/<lat0> is the center of the projection, and <horizon> is max distance from center of the
#     projection (<= 180, default 180). The <scale> can also be given as <radius>/<lat>, where <radius> is the distance in cm to the oblique parallel <lat0>.
#  done -Jf|F<lon0>/<lat0>[/<horizon>]/<scale>|<width> (Gnomonic). <lon0>/<lat0> is the center of the projection, and <horizon> is max distance from center of the projection
#     (< 90, default 60). The <scale> can also be given as <radius>/<lat>, where <radius> is distance in cm to the oblique parallel <lat0>.
#  done -Jg|G<lon0>/<lat0>/<scale>|<width> (Orthographic). <lon0>/<lat0> is the center of the projection. <scale> can also be given as <radius>/<lat>, where <radius> is
#     distancein cm to the oblique parallel <lat>.
#  -Jg|G<lon0>/<lat0>/<scale>|<width>[+a<azimuth>][+t<tilt>][+v<vwidth>/<vheight>][+w<twist>][+z<altitude>[r|R]|g] (General Perspective). <lon0>/<lat0> is the center of
#    the projection. The <scale> can also be given as <radius>/<lat>, where <radius> is distance in cm to the oblique parallel <lat0>. Several optional modifiers control
#    the perspective:
#    +a Append <azimuth> east of North of view [0].
#    +t Append the upward <tilt> of the plane of projection; if <tilt> < 0 then viewpoint is centered on the horizon [0].
#    +v Append restricted view: <vwidth> is width of the viewpoint in degree, and <vheight> is the height of the viewpoint in degrees [unrestricted].
#    +w Append the CW <twist> of the viewpoint in degree [0].
#    +z Append <altitude> (in km) of viewpoint above local sea level [infinity]. Alternatively, append r to give radius from center of Earth to viewpoint (in km); use R
#       instead if radius is given in Earth radii, or set <altitude> = g to use the altitude of the geosynchronous orbit.
#  done -Jh|H[<lon0>/]<scale>|<width> (Hammer-Aitoff). Give optional central meridian and <scale>.
#  done-Ji|I[<lon0>/]<scale>|<width> (Sinusoidal). Give optional central meridian and <scale>.
#  -Jj|J[<lon0>/]<scale>|<width> (Miller). Give optional central meridian and <scale>.
#  done -Jkf|Kf[<lon0>/]<scale>|<width> (Eckert IV). Give optional central meridian and <scale>).
#  done -Jk|K[s][<lon0>/]<scale>|<width> (Eckert VI). Give optional central meridian and <scale>.
#  done -Jl|L<lon0>/<lat0>/<lat1>/<lat2>/<scale>|<width> (Lambert Conformal Conic). Give origin, 2 standard parallels, and true scale.
#  done -Jm|M[<lon0>/[<lat0>/]]<scale>|<width> (Mercator). Give optional central meridian and true scale parallel, and <scale>.
#  done -Jn|N[<lon0>/]<scale>|<width> (Robinson projection). Give optional central meridian and <scale>.
#  done -Jo|O<parameters>[+v] (Oblique Mercator). Specify one of three definitions:
#    -Jo|O[a|A]<lon0>/<lat0>/<azimuth>/<scale>|<width>. Give origin, azimuth of oblique equator, and scale at oblique equator
#    -Jo|O[b|B]<lon0>/<lat0>/<lon1>/<lat1>/<scale>|<width>. Give origin, second point on oblique equator, and scale at oblique equator.
#    -Jo|Oc|C<lon0>/<lat0>/<lonp>/<latp>/<scale>|<width>.Give origin, pole of projection, and scale at oblique equator.
#    Specify region in oblique degrees OR use -R<...>+r. Uppercase A|B|C removes enforcement of a northern hemisphere pole. Append +v to make the oblique Equator the y-
#    axis [x-axis].
#  -Jp|P<scale>|<width>[+a][+f[e|p|<radius>]][+r<offset>][+t<origin>][+z[p|<radius>]] (Polar (theta,radius)). Linear scaling for polar coordinates. Give <scale> in cm/⏎
#    …units. Optional modifiers:
#    +a Use azimuths (CW from North) instead of directions (CCW from East) [Default].
#    +f Flip radial direction so south is on the outside and north is at the center. Append e to indicate data are elevations in degrees (s/n must be in 0-90 range).
#       Append p to set r = current planetary radius to be the center. Append <radius> to indicate the radius at the center.
#    +r Offset the radial values [0].
#    +t Set <origin> value for angles or azimuths [0].
#    +z Annotate depths rather than radius [Default]. Alternatively, if you provided depths then append p (planetary radius) or <radius> to annotate r = radius - z
#       instead.
#  done -Jpoly|Poly/[<lon0>/[<lat0>/]]<scale>|<width> ((American) Polyconic). Give optional central meridian and reference parallel [Default is equator], and <scale>.
#  -Jq|Q[<lon0>/[<lat0>/]]<scale>|<width> (Equidistant Cylindrical). Give optional central meridian and standard parallel, and <scale>. Common parallels: <lat0> = 61.7
#    (Min. linear distortion), 50.5 (R. Miller equirectangular), 45 (Gall isographic), 43.5 (Min. continental distortion), 42 (Grafarend & Niermann), 37.5 (Min. overall
#    distortion), and 0 (Plate Carree [Default]).
#  done -Jr|R[<lon0>/]<scale>|<width> (Winkel Tripel). Give optional central meridian and <scale>.
#  done -Js|S<lon0>/<lat0>[/<horizon>]/<scale>|<width> (Stereographic). <lon0>/<lat0> is the center or the projection, <horizon> is max distance from center of the projection
#    (< 180, default 90), and <scale> is either <1:xxxx> (true at pole) or <slat>/<1:xxxx> (true at <slat>) or <radius>/<lat> (distance in cm to the (oblique) parallel
#    <lat0>.
#  done -Jt|T<lon0>/[<lat0>/]<scale>|<width> (Transverse Mercator). Give central meridian and scale. Optionally, also give the central parallel [Default is equator].
#  done -Ju|U<zone>/<scale>|<width> (UTM). Give zone (A,B,Y,Z, or 1-60 (negative for S hemisphere) or append code C-X) and <scale>. Or, give -Ju|U<scale>|<width> to have the
#    UTM zone determined from the region.
#  done -Jv|V[<lon0>/]<scale>|<width> (van der Grinten). Give optional central meridian and <scale>.
#  done -Jw|W[<lon0>/]<scale>|<width> (Mollweide). Give optional central meridian and <scale>.
#  -Jy|Y[<lon0>/[<lat0>/]]<scale>|<width> (Cylindrical Equal-area). Give optional central meridian and standard parallel, and <scale>. Common parallels: <lat0> = 50
#    (Balthasart), 45 (Gall), 37.5 (Hobo-Dyer), 37.4 (Trystan Edwards), 37.0666 (Caster), 30 (Behrmann), and 0 (Lambert [Default])
#  done -Jx|X<x-scale|<width>[/<y-scale|height>] (Linear, log, power scaling). <scale> in cm/units (or 1:xxxx). Optionally, append to <x-scale> and/or <y-scale> one of d for
#    Geographic coordinate (in degrees), l for Log10 projection, p<power> for x^power projection, t for calendar time projection using relative time coordinates, or T for
#    Calendar time projection using absolute time coordinates. Use / to specify separate x/y scaling (e.g., -Jx0.5c/0.3c). If 1:xxxxx is used it implies -R is in meters.
#    If -JX is used then give axes lengths rather than scales.

# We need to shift the automatic UTM zone section to AFTER other arguments are processed

    ARG1="${2}"
    shift

    if [[ $ARG1 == "scale" ]]; then
      if [[ $2 == *:* ]]; then
       rjmapscale=$2
       rjmapscaleflag=1
      fi
      shift  # argument
      ARG1="$2"
      shift
    fi

    case $ARG1 in
      {)
      info_msg "[-RJ]: Custom RJ argument string detected"
      while : ; do
          [[ ${2:0:1} != [}] ]] || break
          rj+=("${2}")
          shift
      done
      shift
      RJSTRING="${rj[@]}"
      ;;
      # Projections that take optional <lon0>/[<lat0>/]]<scale>
      Mercator|M) # Mercator
         # -Jm|M[<lon0>/[<lat0>/]]<scale>|<width> (Mercator). Give optional central meridian and true scale parallel, and <scale>.

         CENTRALPARALLEL=$(echo "($MINLAT + $MAXLAT) / 2" | bc -l)
         CENTRALMERIDIAN=$(echo "($MINLON + $MAXLON) / 2" | bc -l)

         if arg_is_float $2; then   # Specified a central meridian
           CENTRALMERIDIAN=$2
           shift
           if arg_is_float $2; then   # Specified a central meridian
             CENTRALPARALLEL=$2
             shift
           fi
         fi

        if [[ $(echo "$MAXLAT == 90" | bc -l) -eq 1 ]]; then
          MAXLAT=89.9
        fi
        if [[ $(echo "$MINLAT == -90" | bc -l) -eq 1 ]]; then
          MINLAT=-89.9
        fi

        rj[0]="-R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}"

        if [[ $rjmapscaleflag -eq 1 ]]; then
          getpssizeflag=1
          rj[1]="-Jm${CENTRALMERIDIAN}/${CENTRALPARALLEL}/${rjmapscale}"
          projname="Mercator ${rjmapscale}"
        else
          rj[1]="-JM${CENTRALMERIDIAN}/${CENTRALPARALLEL}/${PSSIZE}i"
          projname="Mercator"
        fi

        RJSTRING="${rj[@]}"
      ;;
      Cassini|C)
        CENTRALPARALLEL=$(echo "($MINLAT + $MAXLAT) / 2" | bc -l)
        CENTRALMERIDIAN=$(echo "($MINLON + $MAXLON) / 2" | bc -l)

        rj[0]="-R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}"

        if [[ $rjmapscaleflag -eq 1 ]]; then
          rj[1]="-Jc${CENTRALMERIDIAN}/${CENTRALPARALLEL}/${rjmapscale}"
          projname="Cassini ${rjmapscale}"
        else
          echo "[-RJ]: Cassini projection requires scale: -RJ scale 1:XXX C and region defined by -r"
          exit 1
        fi
        RJSTRING="${rj[@]}"
      ;;
      Poly|JP)
        CENTRALMERIDIAN=$(echo "($MINLON + $MAXLON) / 2" | bc -l)
        STANDARDPARALLEL=45 # Gall by default

        if arg_is_float $2; then   # Specified a central meridian
          CENTRALMERIDIAN=$2
          shift
          if arg_is_float $2; then   # Specified a central meridian
            STANDARDPARALLEL=$2
            shift
          fi
        fi

        rj[0]="-R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}"

        if [[ $rjmapscaleflag -eq 1 ]]; then
          rj[1]="-Jpoly/${CENTRALMERIDIAN}/${STANDARDPARALLEL}/${rjmapscale}"
          getpssizeflag=1
          projname="Polyconic ${rjmapscale}"
        else
          rj[1]="-JPoly/${CENTRALMERIDIAN}/${STANDARDPARALLEL}/${PSSIZE}i"
          projname="Polyconic"
        fi
        RJSTRING="${rj[@]}"
      ;;
      CylStereo|CS) # -Jcyl_stere|Cyl_stere/[<lon0>/[<lat_nodist>/]]<scale>|<width>
        CENTRALMERIDIAN=$(echo "($MINLON + $MAXLON) / 2" | bc -l)
        STANDARDPARALLEL=45 # Gall by default

        if arg_is_float $2; then   # Specified a central meridian
          CENTRALMERIDIAN=$2
          shift
          if arg_is_float $2; then   # Specified a central meridian
            STANDARDPARALLEL=$2
            shift
          fi
        fi

        rj[0]="-R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}"

        if [[ $rjmapscaleflag -eq 1 ]]; then
          rj[1]="-Jcyl_stere/${CENTRALMERIDIAN}/${STANDARDPARALLEL}/${rjmapscale}"
          getpssizeflag=1
          projname="Cylindrical Stereographic ${rjmapscale}"

        else
          rj[1]="-JCyl_stere/${CENTRALMERIDIAN}/${STANDARDPARALLEL}/${PSSIZE}i"
          projname="Cylindrical Stereographic"

        fi
        RJSTRING="${rj[@]}"
      ;;
      # <lon0>/<lat0>/<central parallel>/<scale>
      T) # Transverse Mercator
        CENTRALPARALLEL=0
        if arg_is_float $2; then   # Specified a central meridian
          CENTRALMERIDIAN=$2
          shift
          if arg_is_float $2; then   # Specified a central meridian
            CENTRALPARALLEL=$2
            shift
          else
            CENTRALPARALLEL=$(echo "($MINLAT + $MAXLAT) / 2" | bc -l)
          fi
        else
          CENTRALMERIDIAN=$(echo "($MINLON + $MAXLON) / 2" | bc -l)
        fi
        rj[0]="-R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}"

        if [[ $rjmapscaleflag -eq 1 ]]; then
          rj[1]="-Jt${CENTRALMERIDIAN}/${CENTRALPARALLEL}/${rjmapscale}"
          projname="Transverse Mercator ${rjmapscale}"
          getpssizeflag=1
        else
          rj[1]="-JT${CENTRALMERIDIAN}/${CENTRALPARALLEL}/${PSSIZE}i"
          projname="Transverse Mercator"
        fi

        RJSTRING="${rj[@]}"
      ;;
      UTM)
        if [[ $2 =~ ^[0-9]+$ ]]; then   # Specified a UTM Zone (positive integer)
          UTMZONE=$2
          shift
          projname="UTM Zone ${UTMZONE}"
        else
          calcutmzonelaterflag=1
        fi
        setutmrjstringfromarrayflag=1

# NOTE: the following line was commented out to avoid gray collars around UTM maps
        # recalcregionflag_lonlat=1
        DEM_LATBUFFER=0.5 # As the map can extend to the north or south due to curve
      ;;

      # Global extents
      Hammer|H|Winkel|R|Robinson|N|Mollweide|W|VanderGrinten|V|Sinusoidal|I|Eckert4|Kf|Eckert6|Ks)
        MINLON=-180; MAXLON=180; MINLAT=-90; MAXLAT=90
        globalextentflag=1

        if arg_is_float $2; then   # Specified a central meridian
          CENTRALMERIDIAN=$2
          shift
        else
          CENTRALMERIDIAN=0
        fi
        rj[0]="-R-180/180/-90/90"

        if [[ $rjmapscaleflag -eq 1 ]]; then
          getpssizeflag=1
          case $ARG1 in
            Eckert4|Kf)      rj[1]="-Jkf${CENTRALMERIDIAN}/${rjmapscale}"; projname="Eckert4" ;;
            Eckert6|Ks)      rj[1]="-Jks${CENTRALMERIDIAN}/${rjmapscale}"; projname="Eckert6" ;;
            Hammer|H)        rj[1]="-Jh${CENTRALMERIDIAN}/${rjmapscale}"; projname="Hammer" ;;
            Mollweide|W)     rj[1]="-Jw${CENTRALMERIDIAN}/${rjmapscale}"; projname="Mollweide" ;;
            Robinson|N)      rj[1]="-Jn${CENTRALMERIDIAN}/${rjmapscale}"; projname="Robinson" ;;
            Sinusoidal|I)    rj[1]="-Ji${CENTRALMERIDIAN}/${rjmapscale}"; projname="Sinusoidal" ;;
            VanderGrinten|V) rj[1]="-Jv${CENTRALMERIDIAN}/${rjmapscale}"; projname="Van der Grinten" ;;
            Winkel|R)        rj[1]="-Jr${CENTRALMERIDIAN}/${rjmapscale}"; projname="Winkel" ;;
          esac
        else
          case $ARG1 in
            Eckert4|Kf)      rj[1]="-JKf${CENTRALMERIDIAN}/${PSSIZE}i"; projname="Eckert4" ;;
            Eckert6|Ks)      rj[1]="-JKs${CENTRALMERIDIAN}/${PSSIZE}i"; projname="Eckert6" ;;
            Hammer|H)        rj[1]="-JH${CENTRALMERIDIAN}/${PSSIZE}i"; projname="Hammer" ;;
            Mollweide|W)     rj[1]="-JW${CENTRALMERIDIAN}/${PSSIZE}i"; projname="Mollweide" ;;
            Robinson|N)      rj[1]="-JN${CENTRALMERIDIAN}/${PSSIZE}i"; projname="Robinson" ;;
            Sinusoidal|I)    rj[1]="-JI${CENTRALMERIDIAN}/${PSSIZE}i"; projname="Sinusoidal" ;;
            VanderGrinten|V) rj[1]="-JV${CENTRALMERIDIAN}/${PSSIZE}i"; projname="Van der Grinten" ;;
            Winkel|R)        rj[1]="-JR${CENTRALMERIDIAN}/${PSSIZE}i"; projname="Winkel" ;;
          esac
        fi

        RJSTRING="${rj[@]}"
        recalcregionflag_lonlat=0
      ;;
      Hemisphere|A)
        MINLON=-180; MAXLON=180; MINLAT=-90; MAXLAT=90
        globalextentflag=1

        if arg_is_float $2; then   # Specified a central meridian
          CENTRALMERIDIAN=$2
          shift
          if arg_is_float $2; then   # Specified a latitude
            CENTRALLATITUDE=$2
            shift
          else
            CENTRALLATITUDE=0
          fi
        else
          CENTRALMERIDIAN=0
          CENTRALLATITUDE=0
        fi
        rj[0]="-Rg"

        if [[ $rjmapscaleflag -eq 1 ]]; then
          getpssizeflag=1
          case $ARG1 in
            Hemisphere|A) rj[1]="-Ja${CENTRALMERIDIAN}/${CENTRALLATITUDE}/${rjmapscale}"; projname="Hemisphere ${rjmapscale}" ;;

          esac
        else
          case $ARG1 in
            Hemisphere|A) rj[1]="-JA${CENTRALMERIDIAN}/${CENTRALLATITUDE}/${PSSIZE}i"; projname="Hemisphere" ;;
          esac
        fi

        RJSTRING="${rj[@]}"
        recalcregionflag_lonlat=0
      ;;
      # Projections that take <lon0>/<lat0>/<range>/<scale>
      Gnomonic|Fg|F|Orthographic|Gg|G|Stereo|Sg|S|AzimEq|E)
        MINLON=-180; MAXLON=180; MINLAT=-90; MAXLAT=90
        globalextentflag=1

        if arg_is_float $2; then   # Specified a central meridian
          CENTRALMERIDIAN=$2
          shift
          if arg_is_float $2; then   # Specified a latitude
            CENTRALLATITUDE=$2
            shift
            if arg_is_float $2; then   # Specified a degree range
              DEGRANGE=$2
              shift
            else
              DEGRANGE=90
            fi
          else
            CENTRALLATITUDE=0
            DEGRANGE=90
          fi
        else
          CENTRALMERIDIAN=0
          CENTRALLATITUDE=0
          DEGRANGE=90
        fi
        rj[0]="-Rg"


        if [[ $rjmapscaleflag -eq 1 ]]; then
          getpssizeflag=1
          case $ARG1 in
            Gnomonic|Fg|F)      [[ $DEGRANGE -ge 90 ]] && DEGRANGE=60   # Gnomonic can't have default degree range
                                rj[1]="-Jf${CENTRALMERIDIAN}/${CENTRALLATITUDE}/${DEGRANGE}/${rjmapscale}"
                                projname="Gnomonic ${rjmapscale}"
                                ;;
            Orthographic|Gg|G)  rj[1]="-Jg${CENTRALMERIDIAN}/${CENTRALLATITUDE}/${DEGRANGE}/${rjmapscale}"
                                projname="Orthographic ${rjmapscale}"
                                ;;
            Stereo|Sg|S)        rj[1]="-Js${CENTRALMERIDIAN}/${CENTRALLATITUDE}/${DEGRANGE}/${rjmapscale}"
                                projname="Stereo ${rjmapscale}"
                                ;;
            AzimEq|E)           rj[1]="-Je${CENTRALMERIDIAN}/${CENTRALLATITUDE}/${DEGRANGE}/${rjmapscale}"
                                ;;
          esac
        else
          case $ARG1 in
            Gnomonic|Fg|F)      [[ $DEGRANGE -ge 90 ]] && DEGRANGE=60   # Gnomonic can't have default degree range
                                rj[1]="-JF${CENTRALMERIDIAN}/${CENTRALLATITUDE}/${DEGRANGE}/${PSSIZE}i"
                                projname="Gnomonic"
                                ;;
            Orthographic|Gg|G)  rj[1]="-JG${CENTRALMERIDIAN}/${CENTRALLATITUDE}/${DEGRANGE}/${PSSIZE}i"
                                projname="Orthographic"
                                ;;
            Stereo|Sg|S)        rj[1]="-JS${CENTRALMERIDIAN}/${CENTRALLATITUDE}/${DEGRANGE}/${PSSIZE}i"
                                projname="Stereo"
                                ;;
            AzimEq|E)           rj[1]="-JE${CENTRALMERIDIAN}/${CENTRALLATITUDE}/${DEGRANGE}/${PSSIZE}i"
                                ;;

          esac
        fi

        RJSTRING="${rj[@]}"
        GRATOPTS="--MAP_ANNOT_MIN_ANGLE=0 --MAP_ANNOT_OBLIQUE=anywhere,tick_normal --MAP_ANNOT_ORTHO=wesn"

        if [[ ${ARG1:1:2} == "g" ]]; then
          info_msg "[-RJ]: using global circle map ($ARG1)"
        else
          info_msg "[-RJ]: will recalculate data region using circle method"
          # recalcregionflag_lonlat=1
          recalcregionflag_circle=1
        fi
      ;;
      # Oblique Mercator A (lon lat azimuth widthkm heightkm)
      ObMercA|OA|OAv)
        # Set up default values
        projname="Oblique Mercator (azimuth)"
        CENTRALLON=0
        CENTRALLAT=0
        ORIENTAZIMUTH=0
        MAPWIDTH="200"
        MAPHEIGHT="100"
        if arg_is_float $2; then   # Specified a central meridian
          CENTRALLON=$2
          shift
          if arg_is_float $2; then   # Specified a latitude
            CENTRALLAT=$2
            shift
            if arg_is_float $2; then   # Specified a degree range
              ORIENTAZIMUTH=$2
              shift

              # Have to divide by two to get full cross-map width+height
              if [[ $2 =~ ^[-+]?[0-9]*.*[0-9]+ ]]; then   # Specified a width with unit k
                MAPWIDTH=$(echo $2 | gawk '{print ($1+0)/2 }')
                shift
                if [[ $2 =~ ^[-+]?[0-9]*.*[0-9]+ ]]; then   # Specified a width with unit k
                  MAPHEIGHT=$(echo $2 | gawk '{print ($1+0)/2 }')
                  shift
                fi
              fi
            fi
          fi
        fi

        if [[ $ARG1 == "OAv" ]]; then
          OAvert="+v"
        else
          OAvert=""
        fi

        rj[0]="-R-${MAPWIDTH}/${MAPWIDTH}/-${MAPHEIGHT}/${MAPHEIGHT}+uk"

        if [[ $rjmapscaleflag -eq 1 ]]; then
          getpssizeflag=1
          rj[1]="-Joa${CENTRALLON}/${CENTRALLAT}/${ORIENTAZIMUTH}/${rjmapscale}${OAvert}"
          projname"Oblique Mercator Azimuthal ${rjmapscale}"

        else
          rj[1]="-JOa${CENTRALLON}/${CENTRALLAT}/${ORIENTAZIMUTH}/${PSSIZE}i${OAvert}"
          projname="Oblique Mercator"
        fi

        RJSTRING="${rj[@]}"
        GRATOPTS="--MAP_ANNOT_MIN_ANGLE=0 --MAP_ANNOT_OBLIQUE=anywhere"
        recalcregionflag_bounds=1
        projcoordsflag=1
      ;;
      # Lon Lat lonpole latPole widthkm heightkm
      ObMercC|OC)
        # Set up default values
        CENTRALLON=0
        CENTRALLAT=0
        POLELON=0
        POLELAT=0
        MAPWIDTH="200"
        MAPHEIGHT="100"
        if arg_is_float $2; then   # Specified a central meridian
          CENTRALLON=$2
          shift
          if arg_is_float $2; then   # Specified a latitude
            CENTRALLAT=$2
            shift
            if arg_is_float $2; then   # Specified a latitude
              POLELON=$2
              shift
              if arg_is_float $2; then   # Specified a latitude
                POLELAT=$2
                shift
                if [[ $2 =~ ^[-+]?[0-9]*.*[0-9]+ ]]; then   # Specified a width with unit k
                  MAPWIDTH=$(echo $2 | gawk '{print ($1+0)/2 }')
                  shift
                  if [[ $2 =~ ^[-+]?[0-9]*.*[0-9]+ ]]; then   # Specified a width with unit k
                    MAPHEIGHT=$(echo $2 | gawk '{print ($1+0)/2 }')
                    shift
                  fi
                fi
              fi
            fi
          fi
        fi

        # As of GMT 6.1.1, the KM width is such that 20000 ~ a full circle, so
        # Length of small circle at angle A from a pole is 6371*cos(90-theta)

        # Calculate circumference of a small circle with given pole passing through center point
        # Note that there are too many conversions back and forth, not great...
        SMALLC_CIRC=$(gawk -v lon1=${CENTRALLON} -v lat1=${CENTRALLAT} -v lon2=${POLELON} -v lat2=${POLELAT} '
          @include "tectoplot_functions.awk"
          BEGIN {
            val=haversine_m(lon1, lat1, lon2, lat2)
            print 6371*2*getpi()*cos(getpi()/2-val/6371000)
          }
          ')

        # This calculation (as far as I can tell) will set the length of the map box closest to
        # the pole!

        MAPWIDTH=$(echo $MAPWIDTH | gawk -v circ=${SMALLC_CIRC} '{print ($1+0)*38921.6/circ }')
        MAPHEIGHT=$(echo $MAPHEIGHT | gawk -v circ=${SMALLC_CIRC} '{print ($1+0)*38921.6/circ }')

        rj[0]="-R-${MAPWIDTH}/${MAPWIDTH}/-${MAPHEIGHT}/${MAPHEIGHT}+uk"

        if [[ $rjmapscaleflag -eq 1 ]]; then
          getpssizeflag=1
          rj[1]="-Joc${CENTRALLON}/${CENTRALLAT}/${POLELON}/${POLELAT}/${rjmapscale}"
          projname="Oblique Mercator (pole) ${rjmapscale}"

        else
          rj[1]="-JOc${CENTRALLON}/${CENTRALLAT}/${POLELON}/${POLELAT}/${PSSIZE}i"
          projname="Oblique Mercator (pole)"
        fi

        RJSTRING="${rj[@]}"
        GRATOPTS="--MAP_ANNOT_MIN_ANGLE=0 --MAP_ANNOT_OBLIQUE=anywhere"

        recalcregionflag_bounds=1
        projcoordsflag=1
      ;;

      # Projections that take <lon0>/<lat0>/<parallel1>/<parallel2><scale>

      Albers|B|Lambert|L|Equid|D)

        if [[ ! $called_r_flag -eq 1 ]]; then
          info_msg "[-RJ]: Albers|B option requires -r to set map region first!"
        fi
        if arg_is_float $2; then   # Specified a central meridian
          CENTRALLON=$2
          shift
        else
          CENTRALLON=$(echo "($MINLON + $MAXLON) / 2" | bc -l)
        fi
        if arg_is_float $2; then   # Specified a latitude
          CENTRALLAT=$2
          shift
        else
          CENTRALLAT=$(echo "($MINLAT + $MAXLAT) / 2" | bc -l)
        fi
        if arg_is_float $2; then   # Specified a standard parallel
          STANDARD_PARALLEL_1=$2
          shift
        else
          STANDARD_PARALLEL_1=${MINLAT}
        fi
        if arg_is_float $2; then   # Specified a standard parallel
          STANDARD_PARALLEL_2=$2
          shift
        else
          STANDARD_PARALLEL_2=${MAXLAT}
        fi

        rj[0]="-R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}"

        if [[ $rjmapscaleflag -eq 1 ]]; then
          getpssizeflag=1

          case $ARG1 in
            Albers|B)      rj[1]="-Jb${CENTRALLON}/${CENTRALLAT}/${STANDARD_PARALLEL_1}/${STANDARD_PARALLEL_2}/${rjmapscale}"
                           projname="Albers ${rjmapscale}"
                           ;;
            Lambert|L)     rj[1]="-Jl${CENTRALLON}/${CENTRALLAT}/${STANDARD_PARALLEL_1}/${STANDARD_PARALLEL_2}/${rjmapscale}"
                           projname="Lambert ${rjmapscale}"
                           ;;
            Equid|D)       rj[1]="-Jd${CENTRALLON}/${CENTRALLAT}/${STANDARD_PARALLEL_1}/${STANDARD_PARALLEL_2}/${rjmapscale}"
                           projname="Equidistant ${rjmapscale}"
                           ;;
          esac
        else
          case $ARG1 in
            Albers|B)      rj[1]="-JB${CENTRALLON}/${CENTRALLAT}/${STANDARD_PARALLEL_1}/${STANDARD_PARALLEL_2}/${PSSIZE}i"
                           projname="Albers"
                           ;;
            Lambert|L)     rj[1]="-JL${CENTRALLON}/${CENTRALLAT}/${STANDARD_PARALLEL_1}/${STANDARD_PARALLEL_2}/${PSSIZE}i"
                           projname="Lambert"
                           ;;
            Equid|D)       rj[1]="-JD${CENTRALLON}/${CENTRALLAT}/${STANDARD_PARALLEL_1}/${STANDARD_PARALLEL_2}/${PSSIZE}i"
                           projname="Equidistant"
                           ;;
          esac
        fi

        RJSTRING="${rj[@]}"
        recalcregionflag_bounds=1
        projcoordsflag=1
      ;;
      Cartesian|X)

        # X and Y spacing are uniform
        PSSIZE_ALT=$(gawk -v size=${PSSIZE} -v minlon=${MINLON} -v maxlon=${MAXLON} -v minlat=${MINLAT} -v maxlat=${MAXLAT} '
          BEGIN {
            print size*(minlat-maxlat)/(minlon-maxlon)
          }')

        rj[0]="-R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}"
        rj[1]="-JX${PSSIZE}i/${PSSIZE_ALT}id"


        if [[ $rjmapscaleflag -eq 1 ]]; then
          echo "[-RJ]: scale option 1:XXX cannot be used with Cartesian (X) projection. Ignoring scale."
        fi


        RJSTRING="${rj[@]}"
        projname="Cartesian"
      ;;
      *)
        echo "[-RJ]: projection ${ARG1} not recognized."
        exit 1
      ;;
    esac

    usecustomrjflag=1

    if [[ $getpssizeflag -eq 1 ]]; then
      gmt psbasemap ${rj[0]} ${rj[1]} -Btlbr --PS_MEDIA=0.01ix0.01i 1> rjtest.ps 2> cat.txt
      plotsize=($(grep WxH cat.txt | gawk '{print $7/2.54, $9/2.54}'))
      PSSIZE=${plotsize[0]}
      info_msg "[-RJ]: Calculated PSSIZE = ${PSSIZE} inches"
    fi
    # echo args ar $@
    # echo rj0 is ${rj[0]}
    # echo rj1 is ${rj[1]}
    # echo RJSTRING is ${RJSTRING}

    # Need to calculate the AOI using the RJSTRING. Otherwise, have to specify a
    # region manually using -r which may not be so obvious.

    # How?
    ;;

  -setdatadir) # -setdatadir: define location of downloaded data directory
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-setdatadir:   set location of downloaded data directory
Usage: -setdatadir [directory_path]

  The path to the data directory is stored in the tectoplot.dataroot file

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if arg_is_flag $2; then
      info_msg "[-setdatadir]: No data directory specified. Current data directory is: "
      cat ${OPTDIR}"tectoplot.dataroot"
      exit 1
    else
      datadirpath=$(abs_dir "${2}")
      # Directory will end with / after abs_path
      shift
      if [[ -d ${datadirpath} ]]; then
        echo "[-setdatadir]: Setting data directory to ${datadirpath}"
        echo "${datadirpath}" > ${OPTDIR}"tectoplot.dataroot"
      else
        echo "[-setdatadir]: Creating new data directory ${datadirpath}"
        mkdir -p "${datadirpath}"
        echo "${datadirpath}" > ${OPTDIR}"tectoplot.dataroot"
      fi
    fi
    exit
    ;;

  -setopen) # -setopen: define the program that is used to open pdf files
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-setopen:      set the program that is used to open pdf files
Usage: -setopen [application]

  The path to the open program is stored in the ${OPTDIR}tectoplot.pdfviewer file

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if arg_is_flag $2; then
      echo "[-setopen]: PDFs are opened using: ${OPENPROGRAM}"
    else
      OPENPROGRAM="${2}"
      shift
      if command -v ${OPENPROGRAM} &> /dev/null; then
        echo "${OPENPROGRAM}" > ${OPTDIR}"tectoplot.pdfviewer"
      else
        if command open -a ${OPENPROGRAM}; then
          echo "open -a ${OPENPROGRAM}" > ${OPTDIR}"tectoplot.pdfviewer"
        else
          echo "Program ${OPENPROGRAM} cannot be called using open -a! Not setting."
        fi
      fi
    fi
    exit
    ;;

  -scale) # -scale: plot a scale bar

  # Default is a 2 inch wide scale bar with 5 intervals

  SCALE_WIDTH="2i"
  SCALE_NUMDIVS=16
  scalebarbywidthflag=1
  scaleskiplabelflag=1
  scaleskiplabelinc=4
  scaletextoverbarflag=0  # should we plot text above the bar instead of in?

  SCALE_LENGTH=""  # Default
  SCALEBAR_WIDTH_P=20
  SCALE_MAPLENGTH="1.25" # inches or cm???
  SCALE_MAPLENGTH_DIVISIBLE=0   # Increment that we round to; 0 by default
  SCALE_JUST_CODE="TL"
  SCALE_ONOFFCODE="j"
  SCALE_BORDERON="no"
  SCALE_MARGIN=0  # inches
  SCALE_BORDER_WIDTH="0.75p"
  SCALE_BORDER_COLOR="black"
  SCALE_FONTSIZE="6p"
  SCALE_FONT="Helvetica"
  SCALE_FONTCOLOR="black"
  SCALE_MAJOR_TICK_LENGTH="7"    # Length in points
  SCALE_MINOR_TICK_LENGTH="4"    # Length in points
  SCALE_FRAME_WIDTH="1.5p"
  SCALE_FRAME_COLOR="black"
  bigtickformat="0.5p,black"
  smalltickformat="0.3p,black"

  SCALEFILL=""
  SCALE_TRANS=0
  scalenolabelflag=0     # Don't plot interior text
  scaleautorefptflag=1   # Use center of map by default
  scaleplotNflag=0       # Plot north arrow at start of scale
  scalehorzflag=0        # Enforce horizontality of scale
  scalebarorthogonalflag=0  # not implemented


  SCALE_FONTDEF=${SCALE_FONTSIZE},${SCALE_FONT},${SCALE_FONTCOLOR}
  SCALE_BORDER="+p${SCALE_BORDER_WIDTH},${SCALE_BORDER_COLOR}"
  SCALE_FRAME_PEN="${SCALE_FRAME_WIDTH},${SCALE_FRAME_COLOR}"

if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-scale:        plot a scale bar

    Default is a 2 inch wide scale plotted at onmap TL justification

Usage: -scale [[options]]

  [[options]]
  horz                  Force the scale bar to be horizontal
  length [length]       Specify length of scale in projected units
  height [points]       Specify height of scale box; fonts scale also
  maplength [length]    Specify width of scale in inches; requires refpt
                        Produces an approximate scale with reasonable bounds
  refpt [lon] [lat]     Reference location for scale
  refpt [aprofcode]     Reference location for scale
  marker                Plot marker indicating scale reference point on map
  atref                 Plot scale bar on the map, ll corner at refpt location
  onmap [just]          Justification of scale bar, on map
  offmap [just]         Justification of scale bar, off map
  divs [number]         Number of divisions of the scale bar
  skiplabel [number]    Set major tick interval and skip intermediate labels
  noskip                Do not skip any intervals and to not have major ticks
  nolabel               Do not label internal divisions
  box [color]           Plot a colored box behind scale
  border                Plot a border around the box
  trans [percent]       Transparency of fill boxes
  inlegend              Add PS of scalebar to legend; do not plot on map
                           (only works with onmap, offmap, maplength NOT atref)
  north                 Plots a north arrow and N at start of scale
  simple                Plot a simple line with ticks

  length has unit (e.g. 100k)
  The scale bar is centered on the reference point or aprofcode point
  aprofcode is an uppercase letter map location ID (plot using -aprofcodes)

Example:
tectoplot -r US.CO -t -scale 200k C -o example_scale
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    # We just use this section to create the SCALECMD values

    # Adjust position and buffering of scale bar using either letter combinations OR Lat/Lon location

    # Look for positioning arguments

    while ! arg_is_flag "${2}"; do
      case "${2}" in
        simple)
          shift
          SCALEBAR_WIDTH_P=0
          SCALE_FRAME_PEN=${bigtickformat}
          scaletextoverbarflag=1
        ;;
        horz)
          shift
          scalehorzflag=1
        ;;
        height)
          shift
          if arg_is_positive_float $2; then
            SCALEBAR_WIDTH_P=$2
            shift
          else
            echo "[-scale]: height option requires number argument [number]p (eg 6p)"
            exit 1
          fi
        ;;
        north)
          shift
          scaleplotNflag=1
        ;;
        inlegend)
          shift
          scalebaronlegendflag=1
        ;;
        maplength)
          shift
          if arg_is_positive_float $2; then
            SCALE_MAPLENGTH=$2
            shift
          fi
          if arg_is_positive_float $2; then
            SCALE_MAPLENGTH_DIVISIBLE=$2
            shift
          fi
          scalebarbywidthflag=1
          scaleatrefflag=0
        ;;
        trans)
          shift
          if arg_is_positive_float $2; then
            SCALE_TRANS=$2
            shift
          else
            echo "[-scale]: option trans requires number argument"
            exit 1
          fi
        ;;
        atref)
          shift
          scaleatrefflag=1
        ;;
        skiplabel)
          shift
          if arg_is_positive_float $2; then
            scaleskiplabelflag=1
            scaleskiplabelinc=${2}
            shift
          fi
        ;;
        noskip)
          shift
          scaleskiplabelflag=0
        ;;
        nolabel)
          shift
          scalenolabelflag=1
        ;;
        box)
          shift
          if ! arg_is_flag $2; then
            SCALEFILL="-F+c2p+g${2}"
            shift
          fi
        ;;
        length)
          shift
          if arg_is_flag $2; then
            info_msg "[-scale]: length option requires distance argument (e.g. 100k)"
            exit 1
          else
            SCALE_LENGTH="${2}"
            # turn off maplength behavior
            scalebarbywidthflag=0
            shift
          fi
        ;;
        marker)
          shift
          scalemarkerflag=1
        ;;
        divs)
          shift
          if arg_is_positive_float $2; then
            SCALE_NUMDIVS=$2
            shift
          else
            echo "[-scale]: divs option requires number argument"
            exit 1
          fi
        ;;
        border)
          shift
          SCALE_BORDERON="yes"
        ;;
        onmap|offmap)
          # The first time we call this, reset the default
          offmapflag=0
          [[ ${2} == "offmap" ]] && offmapflag=1
          shift
          if [[ ${2:0:1} =~ [B,M,T,L,C,R] && ${2:1:1} =~ [B,M,T,L,C,R] ]]; then
            SCALE_JUST_CODE="${2:0:2}"
            shift
          fi
          [[ $offmapflag -eq 1 ]] && SCALE_ONOFFCODE="J" || SCALE_ONOFFCODE="j"
          ;;
      refpt)
        shift

        if arg_is_float $2; then
          SCALEREFLON="${2}"
          shift
          if arg_is_float $2; then
            SCALEREFLAT="${2}"
            shift
          else
            info_msg "[-scale]: Only longitude and not latitude specified. Using $MAXLAT"
            SCALEREFLAT=$MINLAT
          fi
        elif [[ ${2:0:1} =~ [B,M,T,L,C,R] && ${2:1:1} =~ [B,M,T,L,C,R] ]]; then
          scalejustflag=1
          SCALE_JUST_CODE="${2:0:2}"
          shift
        elif [[ "${2}" =~ [A-Z] ]]; then  # This is an aprofcode location
          info_msg "[-scale]: aprofcode ${2:0:1} found."
          SCALE_APROFCODE="${2:0:1}"
          scaleaprofflag=1
          shift
        else
          echo "[-scale]: option refpt argument not recognized: ${2}"
          exit 1
        fi
        scaleautorefptflag=0
        ;;
      *)
        echo "[-scale]: Argument ${2} not recognized"
        exit 1
        ;;
      esac
    done

    plots+=("mapscale")
    ;;

  -north) # -north: plot a north arrow
  ARROWFANCY=""
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-north:        plot a north arrow
Usage: -north [size] [[lon]] [[lat]] [[white]] [[fancy]]
Usage: -north [size] [[aprofcode]] [[white]] [[fancy]]

  Arrow is centered on the reference point
  aprofcode is an uppercase letter map location ID (plot using -aprofcodes)

Example:
tectoplot -r US.CO -t -north 1i C -o example_north
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    # We just use this section to create the SCALECMD values

    if [[ $2 == *i ]]; then
      ARROWSIZE="${2}"
      shift
    else
      info_msg "[-north]: No north arrow size specified. Using 0.5i"
      ARROWSIZE="0.5i"
    fi
    # Adjust position and buffering of scale bar using either letter combinations OR Lat/Lon location

    if arg_is_float $2; then
      ARROWREFLON="${2}"
      shift
      if arg_is_float $2; then
        ARROWREFLAT="${2}"
        ARROWLENLAT="${2}"
        shift
      else
        info_msg "[-north]: Only longitude and not latitude specified. Using $MAXLAT"
        ARROWREFLAT=$MINLAT
        ARROWLENLAT=$MINLAT
      fi
    elif [[ "${2}" =~ [A-Z] ]]; then  # This is an aprofcode location
      info_msg "[-north]: aprofcode ${2:0:1} found."
      NORTHARROWAPROFCODE="${2}"
      shift
      northarrowaprofflag=1
    else
      NORTHARROWAPROFCODE="E"
      northarrowaprofflag=1
    fi

    while ! arg_is_flag ${2}; do
      case $2 in
        white)
          ARROWFILL="-F+gwhite"
          shift
        ;;
        fancy)
          ARROWFANCY="+f+l,,,N"
          shift
        ;;
        *)
          echo "[-north]: option $2 not recognized"
          exit 1
        ;;
      esac
    done

    plots+=("northarrow")
    ;;

  -scrapedata) # -scrapedata: download and manage online seismic data
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-scrapedata:   download and update online seismic data catalogs
Usage: -scrapedata [[controlstring]]  [[rebuild date]]

  letters in controlstring determine what gets scraped/updated:
  Default = giace
  g = GCMT focal mechanisms
  i = ISC focal mechanisms
  a = ANSS (Comcat) seismicity  - rebuildable
  c = ISC seismicity catalog
  e = ISC-EHB seismicity catalog  
  m = EMSC seismicity catalog  - rebuildable

  z = GFZ focal mechanisms (optional - takes a long time!)


  [[rebuild date]] example: tectoplot -scrapedata a rebuild 2023-01-01
  This option removes all events updated after the specified datetime and
  then rebuilds the unique id index in the GPKG file to ensure nonduplication 
  of events. Subsequent scrapedata commands will update the catalog.

  Equivalent mechanisms from each subsequent dataset are removed by default

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if arg_is_flag $2; then
      info_msg "[-scrapedata]: No datasets specified. Scraping all catalogs."
      SCRAPESTRING="giacem"
    else
      SCRAPESTRING="${2}"
      shift
    fi

    if arg_is_flag $2; then
      info_msg "[-scrapedata]: No rebuild command specified"
      REBUILD=""
    elif [[ $2 =~ "rebuild" ]]; then
      REBUILD="rebuild"
      shift
      if ! arg_is_flag $2; then
        REBUILDARG="${2}"
        shift
      fi
    fi

    if [[ ${SCRAPESTRING} =~ .*g.* ]]; then
      info_msg "Scraping GCMT focal mechanisms"
      source $SCRAPE_GCMT
    fi
    if [[ ${SCRAPESTRING} =~ .*e.* ]]; then
      info_msg "Scraping ISC-EHB seismic data"
      source $SCRAPE_ISCEHB ${REBUILD}
    fi
    if [[ ${SCRAPESTRING} =~ .*i.* ]]; then
      info_msg "Scraping ISC focal mechanisms"
      source $SCRAPE_ISCFOC ${ISCDIR} ${REBUILD}
    fi
    if [[ ${SCRAPESTRING} =~ .*a.* ]]; then
      info_msg "Scraping ANSS seismic data"
      source $SCRAPE_ANSS ${ANSSDIR} ${REBUILD} ${REBUILDARG}
    fi
    if [[ ${SCRAPESTRING} =~ .*c.* ]]; then
      info_msg "Scraping ISC seismic data"
      source $SCRAPE_ISCSEIS ${ISC_EQS_DIR} ${REBUILD}
    fi
    if [[ ${SCRAPESTRING} =~ .*z.* ]]; then
      info_msg "Scraping GFZ focal mechanisms"
      source $SCRAPE_GFZ ${GFZDIR} ${REBUILD}
    fi
    if [[ ${SCRAPESTRING} =~ .*m.* ]]; then
      info_msg "Scraping EMSC seismicity"
      echo       source $SCRAPE_EMSC ${EMSCDIR} ${REBUILD} ${REBUILDARG}

      source $SCRAPE_EMSC ${EMSCDIR} ${REBUILD} ${REBUILDARG}
    fi

    # if [[ ${SCRAPESTRING} =~ .*m.* ]]; then
    #   info_msg "Merging focal catalogs"
    #   source $MERGECATS
    # fi
    exit
    ;;

  -seissum) # -seissum: compute a moment magnitude seismic release map
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-seissum:      compute a moment magnitude seismic release map
Usage: -seissum [[resolution=${SSRESC}]] [[transparency]] [[uniform]]

  Sums the moment magnitude of catalog seismicity per grid cell.
  Usually used with -znoplot to suppress plotting of the seismicity data

  resolution is in the form Xd (e.g. 0.1d)

  uniform:  sum earthquake counts and not magnitudes

Example:
tectoplot -z noplot -seissum 0.05d -o example_seissum
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if [[ "$2" =~ "d" ]]; then
      SSRESC="${2}"
      shift
    else
      info_msg "[-seissum]: Using default resolution command ${SSRESC}"
    fi

    if arg_is_positive_float $2; then
      SSTRANS="${2}"
      shift
    else
      SSTRANS="0"
    fi

    if [[ $2 == "uniform" ]]; then
      SSUNIFORM=1
      shift
    fi

    plots+=("seissum")
    ;;

  -setvars) # -setvars: set the value of an internal tectoplot variable
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-setvars:      set the value of an internal tectoplot variable
Usage: -setvars { Var1 Val1 [[Var2 Val2 ...]] }

  Sets the value of an internal tectoplot variable.

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if [[ ${2:0:1} != [{] ]]; then
      info_msg "[-setvars]: { VAR1 val1 VAR2 val2 VAR3 val3 }"
      exit 1
    else
      shift
      while : ; do
        [[ ${2:0:1} != [}] ]] || break
        VARIABLE="${2}"
        shift
        VAL="${2}"
        shift
        export $VARIABLE=$VAL
      done
      shift
    fi
    ;;

  -showprof) # -showprof: plot a selected profile or stacked profile on map PDF
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-showprof:     plot a selected profile or stacked profile on map PS file
Usage: -showprof [[all]] [[stacked]] [[ID1 ... IDN]]

  Places profile EPS files below the map.

  all          plot every generated profile on the map (-showprof all)
  IDN          plot the Nth generated profile (e.g. -showprof 1 3 5)
  stacked      plot the stacked profile

--------------------------------------------------------------------------------
EOF
shift && continue
fi

  # if [[ $2 == "right" ]]; then
  #   showprofrightflag=1
  #   shift
  # fi

  if [[ $2 =~ "stacked" ]]; then
    showprofstackedflag=1
    shift
  fi

  if [[ $2 =~ "all" ]]; then
    showprofallflag=1
    shift
  fi

  while arg_is_positive_float $2; do
    SHOWPROFLIST+=(${2})
    shift
  done

  info_msg "Profiles to plot on map: ${SHOWPROFLIST[@]}"

  plotprofileonmapflag=1

  ;;

  -profileaxes) # -profileaxes: set label strings for profile X, Y, Z axes
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-profileaxes:  set label strings for profile X, Y, Z axes
Usage: -profileaxes [x=\"${PROFILE_X_LABEL}\"] [[y=\"${PROFILE_Y_LABEL}\"]] [[z=\"${PROFILE_Z_LABEL}\"]]

  Sets the label strings for all profile X, Y, Z axes

--------------------------------------------------------------------------------
EOF
shift && continue
fi

  echo 1 is $1
  while ! arg_is_flag $2; do
    echo 2 is $2
    case $2 in
      x) shift; PROFILE_X_LABEL="$2"; shift ;;
      y) shift; PROFILE_Y_LABEL="$2"; shift ;;
      z) shift; PROFILE_Z_LABEL="$2"; shift ;;
      right) shift; PROFILE_RIGHT_LABEL="$2"; shift ;;
      *)
        echo "[-profileaxes]: option $2 not recognized"
        exit 1
      ;;
    esac
  done

  PROFILE_CUSTOMAXES_FLAG=1
  ;;

  -tomoslice) # -tomoslice: plot depth slice of Submachine tomography data
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tomoslice:    Plot depth slice of Submachine tomography data
Usage: -tomoslice [file]

--------------------------------------------------------------------------------
EOF
shift && continue
fi
  TOMOSLICE_TRANS=0

  if [[ -s "${2}" ]]; then
    TOMOSLICEFILE=$(abs_path "${2}")
    shift
    plots+=("tomoslice")
    cpts+=("tomography")
  fi

  if arg_is_positive_float "${2}"; then
    TOMOSLICE_TRANS="${2}"
    shift
  fi

  ;;

  -prof3dgrid)
  THREEDGRIDRES="1k"
  THREEDGRIDVAR="vs"
  THREEDCPT=""
  THREED_DEFAULTCPT="sealand"

if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-prof3dgrid:       plot slices of 3D interpolated dasets on profiles
Usage: -prof3dgrid [xyzvfile] [varname] [res] [[options]]
Usage: -prof3dgrid [netcdf_file] [varname] [res] [[options]]

  Import (or create) a NetCDF data cube and slice it along profiles.

  X,Y: degrees longitude/latitude
  Z: depth (km, positive downward)
  V: number - define name with [var] option (default=cube)

  Option res is required for both usage cases!

  xyzv [file]  Create a NetCDF 3D data cube from the input data (X Y Z V)
               Resolution and domain are determined automatically from the data.

 [netcdf]:     Plot profiles through an existing NetCDF datacube

  Options:
    cpt             Name of or path to CPT
    resid           Remove horizontal average value from each profile

--------------------------------------------------------------------------------
EOF
shift && continue
fi

  prof3dgridflag=1

  # If the file is not NetCDF by name, assume it is XYZV and create a datacube
  if [[ $2 != *.nc ]]; then
    makexyzvflag=1
  fi

  if [[ -s ${2} ]]; then
    PROF3DGRIDFILE=$(abs_path ${2})
    shift
  else
    echo "[-prof3dgrid]: Input file ${2} does not exist or is empty"
    exit 1
  fi

  if ! arg_is_flag $2; then
    THREEDGRIDVAR="${2}"
    shift
  fi

  if ! arg_is_flag $2; then
    THREEDGRIDRES="${2}"
    shift
  fi

  if [[ $makexyzvflag -eq 1 ]]; then
    echo "Making 3D NetCDF: ${DATACUBE_SH} ${PROF3DGRIDFILE} ${TMP}datacube.nc ${THREEDGRIDVAR} 0"
    ${DATACUBE_SH} ${PROF3DGRIDFILE} ${TMP}datacube.nc ${THREEDGRIDVAR} 0
    if [[ -s ${TMP}datacube.nc ]]; then
      PROF3DGRIDFILE=${TMP}datacube.nc
    else
      echo "[-prof3dgrid]: Creation of datacube failed"
      exit 1
    fi
  fi

  while ! arg_is_flag $2; do
    case $2 in
      cpt)
        shift
        if ! arg_is_flag $2; then
          if [[ -s ${2} ]]; then
            THREEDCPT=$(abs_path ${2})
          else
            THREEDCPT="${2}"
          fi
          shift
        else
          echo "[-prof3dgrid]: option cpt requires argument (eg turbo or ./my.cpt)"
          exit 1
        fi
      ;;
      resid)
        shift
        threedresidflag=1
      ;;
      buf)
        shift
        THREEDBUF=$2
        shift
      ;;
      *)
        echo "[-prof3dgrid]: option ${2} not recognized"
        exit 1
      ;;
    esac
  done
  ;;

  -proflabel)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-proflabel:      label distances along profile lines on map
Usage: -proflabel

  Profile labels will be placed at same location as major intervals on each
  profile.

--------------------------------------------------------------------------------
EOF
shift && continue
fi
  profiledistlabelsflag=1
  ;;

  -profgrid) # -profgrid: Interpolate XYZV data for profile grid
  gridsubsampleX=1  # Subsampling factor. 1=no subsampling
  gridsubsampleY=1  # Subsampling factor. 1=no subsampling
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-profgrid:       Interpolate XYZ data and plot grid on profiles
Usage: -profgrid [file] [[options]]

  XYZV data are projected onto profile plane and then interpolated.

  This method can be problematic because the interpolation is done in X'-Z
  projected space rather than geographic space.

  Options:
  cpt [file | cptname]     CPT for interpolated grid
  resx [value]             resolution, X' coordinate (km)
  resy [value]             resolution, Z coordinate (km)
  subx [value]             grid subsampling factor, X' coordinate
  suby [value]             grid subsampling factor, Z coordinate

  Notes:
    Data file has format X Y Z V
    Resolution is calculated from data spacing in the input file

--------------------------------------------------------------------------------
EOF
shift && continue
fi

  # Check if a file or CPT file should be loaded
  if [[ -s $2 ]]; then
    profgridfile=$(abs_path "${2}")
    profgridflag=1
    shift
  else
    profgridfile=$2
    shift
    # echo "[-profgrid]: Input file ${2} does not exist or is empty"
    # exit 1
  fi
  gridresautoflag=1
  while ! arg_is_flag $2; do
    case $2 in
      cpt)
        shift
        if [[ -s ${2} ]]; then
          profgridcpt=$(abs_path $2)
        else
          profgridcpt="${2}"
        fi
        shift
      ;;
      resx)
        shift
        gridresautoflag=0
        if arg_is_positive_float $2; then
          gridresolutionX=$2
          shift
        else
          echo "[-profgrid]: X' resolution should be a positive float"
          exit 1
        fi
      ;;
      resy)
        shift
        gridresautoflag=0
        if arg_is_positive_float $2; then
          gridresolutionY=$2
          shift
        else
          echo "[-profgrid]: Z resolution should be a positive float"
          exit 1
        fi
      ;;
      subx)
        shift
        if arg_is_positive_float $2; then
          gridsubsampleX=$2  # Subsampling factor. 1=no subsampling
        else
          echo "[-profgrid]: option subx requires a positive number argument"
          exit 1
        fi
        shift
      ;;
      suby)
        shift
        if arg_is_positive_float $2; then
          gridsubsampleY=$2  # Subsampling factor. 1=no subsampling
        else
          echo "[-profgrid]: option subx requires a positive number argument"
          exit 1
        fi
        shift
      ;;
      *)
        echo "[-profgrid]: option $2 not recognized"
        exit 1
      ;;
    esac
  done
  ;;

  -tomo) # -tomo: plot submachine tomography slice on profiles
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tomo:         plot submachine tomography slice on profiles
Usage: -tomo [file1] [[file2]] ... [[cptfile]]

  Notes: Data file needs to already have been downloaded from Submachine
         Data file has format X Y Z V
         Data will be added to -sprof, -aprof, etc profiles where close to lines
         If file ends in .cpt it will be used as the tomography CPT

--------------------------------------------------------------------------------
EOF
shift && continue
fi

  # Check if a file exists, if so, translate it to lon lat depth V
  while [[ -s $2 ]]; do

    if [[ "${2}" == *.cpt ]]; then
      tomocpt=$(abs_path $2)
      tomoowncptflag=1
    else
      gawk < $2 '
      function sqr(x)        { return x*x                     }
      function getpi()       { return atan2(0,-1)             }
      function rad2deg(rad)  { return (180 / getpi()) * rad   }
      ($1+0==$1 && $2+0==$2 && $3+0==$3) {
        x=$1
        y=$2
        z=$3
        rxy = sqrt(sqr(x)+sqr(y))
        # print "rxy:", rxy
        lon = rad2deg(atan2($2, $1))
        lat = rad2deg(atan2($3, rxy))
        val=($1*$1) + ($2*$2) + ($3*$3)
        if (val<0) {
          print "What:", $1, $2, $3, val
        }
        rxyz = sqrt(sqr(x)+sqr(y)+sqr(z))
        depth = 6371.0 - rxyz

        print lon, lat, depth, $4
      }' >> ${TMP}tomography.txt
    fi
    shift
  done

  if [[ -s ${TMP}tomography.txt ]]; then
    tomographyflag=1
    cpts+=("tomography")
  fi
  ;;

  -sprof) # -sprof: create an automatic profile between two geographic points
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-sprof:        create an automatic profile between two geographic points
Usage: -sprof [lon1] [lat1] [lon2] [lat2] [resolution]

  width is the full profile width
  resolution is the along-profile sample spacing
  width and resolution is specified with a unit (e.g. 100k)

  This option can be called multiple times to add several profiles.
  The width and resolution must be specified for each profile

Example:
tectoplot -t -sprof 156.2 -7.5 158.5 -9 1k -pw 10k -showprof 1 -o example_sprof
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    # Create a single profile across by constructing a new mprof) file with relevant data types
    # Needs some argument checking logic as too few arguments will mess things up spectacularly
    sprofflag=1
    ((sprofnumber++))
    unset SPROFPTS

    while arg_is_float $2; do
      if arg_is_float $2 && arg_is_float $3; then
        SPROFPTS="${SPROFPTS}$2 $3 "
      else
        echo "[-sprof]: profile points require lon lat pairs"
        exit 1
      fi
      shift
      shift
    done
    echo ${SPROFPTS} >> ${TMP}sprof.lines

    if ! arg_is_flag $2; then
      SPROF_RES="${2}"
      shift
    else
      echo "[-sprof]: sample spacing argument required (e.g. 1k)"
      exit 1
    fi
    clipdemflag=1
    ;;

  -sun) # -sun: set the solar position for hillshading
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-sun:          set the solar position for hillshading
Usage: -sun [[sun_az=${SUN_AZ}]] [[sun_el=${SUN_EL}]]

  Used with -tshad and -tuni

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if arg_is_float $2; then
      SUN_AZ=$2
      HS_AZ=$2
      shift
    fi
    if arg_is_positive_float $2; then
      SUN_EL=$2
      HS_EL=$2
      shift
    fi
    ;;

  -sv) # -sv: plot slip vector azimuths specified in a file
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-sv:           plot slip vector azimuths specified in a file
Usage: -sv [filename] [[scale fieldnum]]

  file format is (lon lat azimuth [length])
  If option "scale" is given, it is followed by a field number
    (first field is 1, default field is 4 (4th column))
  containing length of the bar to plot

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    SVDATAFILE=$(abs_path $2)
    shift

    if [[ ! -s $SVDATAFILE ]]; then
      echo "-s: data file $SVDATAFILE is empty or missing"
      exit 1
    fi

    if [[ $2 == "scale" ]]; then
      plots+=("slipvecs_scale")
      shift
      if arg_is_positive_float $2; then
        SVSCALEFIELD=$2
        shift
      else
        SVSCALEFIELD=4
      fi
    else
      plots+=("slipvecs")
    fi
    ;;

  -tnobar)
  tsentflag=1
  ;;


  -zarea)

  zareaflag=1

  ;;

  -tnoload)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tnoload:        do not attempt to load saved colored relief image
Usage: -tnoload

--------------------------------------------------------------------------------
EOF
shift && continue
fi

  toponoloadflag=0

  ;;

  -t) # -t: visualize topography
  TMIN=-12000 # Challenger Deep
  TMAX=9000 # Everest summit
  TOPO_MODIFIER=1
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-t:            download and visualize topography
Usage: -t [[datasource=determined by extent]]

  -t without arguments will choose a resolution from the GMT download
  server such that the DEM area will not exceed ~4000 pixels width.

  DATA SOURCE:

  Custom DEM file:
  -t [demfile] [[reproject]] [[rescale zmin zmax]]

  Local large datasets downloaded using -getdata:
  -t SRTM15 | SRTM30 | GEBCO20 | GEBCO21 | GEBCO1

  Dynamically downloaded data (tiles managed by tectoplot + GMT)
  -t GMRT | BEST

    BEST is a fusion of GMRT from online and SRTM 30 tiles from the GMT server.

  Dynamically downloaded data from GMT server (tiles managed by GMT)
  Default dataset is IPGG EarthRelief
  -t 01d | 30m | 20m | 15m | 10m | 06m | 05m | 04m | 03m | 02m | 01m
         | 15s | 03s | 01s


  Use downloaded dataset that achieves the desired resolution:
  -t dpi [dpi]

  Use GMT GEBCO21 online data
  -t [[options]] gebco

  Don't clip the DEM to the map area when processing
  -t [[options]] noclip

  The default visualization is GMT standard CPT+hillshade.

  Note: Use -tcpt to adjust the color stretch

Example:
tectoplot -r AU -t 10m -o example_t
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if arg_is_flag $2; then
			info_msg "[-t]: No topo file specified: determining dataset from extent"
			BATHYMETRY=""
      selecttopofromextentflag=1
      plottopo=1
      plots+=("topo")
    else
			BATHYMETRY="${2}"
			shift

      clipdemflag=1
      GRIDDIR=$TILETOPODIR

      case $BATHYMETRY in
        01d|30m|20m|15m|10m|06m|05m|04m|03m|02m|01m|15s|03s|01s|auto)
          plottopo=1
          GRIDDIR=$EARTHRELIEFDIR
          GRIDFILE=${EARTHRELIEFPREFIX}_${BATHYMETRY}
          plots+=("topo")
          echo $EARTHRELIEF_SHORT_SOURCESTRING >> ${SHORTSOURCES}
          echo $EARTHRELIEF_SOURCESTRING >> ${LONGSOURCES}

          [[ ! -d $EARTHRELIEFDIR ]] && mkdir -p $EARTHRELIEFDIR

          ;;
        BEST)
          BATHYMETRY="01s"
          plottopo=1
          GRIDDIR=$EARTHRELIEFDIR
          GRIDFILE=${EARTHRELIEFPREFIX}_${BATHYMETRY}
          plots+=("topo")
          besttopoflag=1
          echo $GMRT_SHORT_SOURCESTRING >> ${SHORTSOURCES}
          echo $GMRT_SOURCESTRING >> ${LONGSOURCES}
          echo $SRTM_SHORT_SOURCESTRING >> ${SHORTSOURCES}
          echo $SRTM_SOURCESTRING >> ${LONGSOURCES}

          [[ ! -d $EARTHRELIEFDIR ]] && mkdir -p $EARTHRELIEFDIR

          ;;
        SRTM15)
          plottopo=1
          GRIDFILE=$SRTM15FILE
          plots+=("topo")
          echo $SRTM_SHORT_SOURCESTRING >> ${SHORTSOURCES}
          echo $SRTM_SOURCESTRING >> ${LONGSOURCES}
          ;;
        SRTM30)
          plottopo=1
          # GRIDDIR=$SRTM30DIR
          GRIDFILE=$SRTM30FILE
          plots+=("topo")
          echo $SRTM_SHORT_SOURCESTRING >> ${SHORTSOURCES}
          echo $SRTM_SOURCESTRING >> ${LONGSOURCES}
          ;;
        GEBCO20)
          plottopo=1
          # GRIDDIR=$GEBCO20DIR
          GRIDFILE=$GEBCO20FILE
          plots+=("topo")
          echo $GEBCO_SHORT_SOURCESTRING >> ${SHORTSOURCES}
          echo $GEBCO_SOURCESTRING >> ${LONGSOURCES}
          ;;
        GEBCO21)
          plottopo=1
          # GRIDDIR=$GEBCO20DIR
          GRIDFILE=$GEBCO21FILE
          plots+=("topo")
          echo $GEBCO_SHORT_SOURCESTRING >> ${SHORTSOURCES}
          echo $GEBCO_SOURCESTRING >> ${LONGSOURCES}
          ;;
        GEBCO1)
          plottopo=1
          # GRIDDIR=$GEBCO1DIR
          GRIDFILE=$GEBCO1FILE
          plots+=("topo")
          echo $GEBCO_SHORT_SOURCESTRING >> ${SHORTSOURCES}
          echo $GEBCO_SOURCESTRING >> ${LONGSOURCES}
          ;;
        GMRT)
          plottopo=1
          # GRIDDIR=$GMRTDIR
          plots+=("topo")
          echo $GMRT_SHORT_SOURCESTRING >> ${SHORTSOURCES}
          echo $GMRT_SOURCESTRING >> ${LONGSOURCES}
          ;;
        auto|*)
          plottopo=1
          plotcustomtopo=1

          info_msg "Using custom grid"
          # GRIDDIR=$(abs_dir $BATHYMETRY)
          GRIDFILE=$(abs_path $BATHYMETRY)  # We already shifted
          if [[ ! -s ${GRIDFILE} ]]; then
            echo "Custom topography file $GRIDFILE does not exist or is empty"
            exit 1
          fi
          plots+=("topo")
          ;;
      esac

      while ! arg_is_flag "${2}"; do
        case $2 in
          # This is wrong as it will double the sourcestrings
          dpi)
            shift
            if arg_is_positive_integer $2; then
              TOPO_DPI=${2}i
              shift
            else
              echo "[-t]: dpi option requires a positive integer argument"
              exit 1
            fi
            gmt set GMT_GRAPHICS_DPU ${TOPO_DPI}

          ;;
          gebco)
            shift
            EARTHRELIEFPREFIX="@earth_gebco"
            EARTHRELIEF_SHORT_SOURCESTRING="GEBCO21"
            EARTHRELIEF_SOURCESTRING="GEBCO 2021 bathymetry (https://www.gebco.net/data_and_products/gridded_bathymetry_data/gebco_2021/) retrieved from GMT Earth Relief server at resolution $BATHYMETRY"
          ;;
          reproject)
            shift
            reprojecttopoflag=1
          ;;
          noclip)
            shift
            clipdemflag=0
          ;;
          # rescale)
          #   shift
          #   if arg_is_float $2; then
          #     TMIN=$2
          #     shift
          #   else
          #     echo "[-t]: rescale requires min max arguments"
          #     exit 1
          #   fi
          #   if arg_is_float $2; then
          #     TMAX=$2
          #     shift
          #   else
          #     echo "[-t]: rescale requires min max arguments"
          #     exit 1
          #   fi
          # ;;
          *)
            echo "[-t]: Argument ${2} not recognized"
            exit 1
          ;;
        esac
      done

		fi


    cpts+=("topo")
    fasttopoflag=1

    MULFACT=$(echo "1 / $HS_Z_FACTOR * 111120" | bc -l)     # Effective z factor for geographic DEM with m elevation

    ;;

  -tfillnan) # -tfillnan: fill NaN values in topography dataset
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tfillnan:     Fill NaN values in topography dataset
-tfillnan [[value]]
-tfillnan spline [[tension=${FILLGRIDNANS_SPLINE_TENSION}]]

  If no option is specified, fill NaN with value of closest cell
  If [[value]] is specified, fill NaN with that value
  If spline is specified, use a spline in tension to fill NaN (can hang CPU)

--------------------------------------------------------------------------------
EOF
shift && continue
fi

    if arg_is_float $2; then
      FILLGRIDVALUE=$2
      shift
      FILLGRIDNANS_VALUE=1
    elif [[ $2 == "spline" ]]; then
      shift
      FILLGRIDNANS_SPLINE=1
      if arg_is_positive_float $2; then
        FILLGRIDNANS_SPLINE_TENSION=$2
        shift
      fi
    else
      FILLGRIDNANS_CLOSEST=1
    fi
    ;;

  -text) # -text: plot simple text strings at points
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-text:         plot simple text strings at points
Usage: -text [file] [[options...]]

  Plots text strings in white boxes at specified locations.

  options are:
  default           Use 10p,Helvetica,black 0 ML
                    Input file has lon lat as first columns, followed by text
  box [[color]]:    plot boxes behind text with fill color
  line:             plot a line to origin location if offsetting text
  offset [[Xoff]] [[Yoff]]   shift text by Xoff/Yoff [e.g. 0.1i 0.1i]

  data file has columns in the format:
    lon lat font angle justification text strings go here
  e.g.
    34.0 -21.1 12p,Helvetica,black 0 ML This is a string

  xoffset: shift all text sidways by this amount (requires unit, e.g. 0.5i)
  yoffset: shift all text up/down by this amount (requires unit, e.g. 0.5i)

Example:
echo "155 -9.5 20p,Helvetica,white 10 ML Woodlark Basin" > tectoplot_text.txt
echo "160 -6 15p,Arial,black 0 ML Pacific Ocean" >> tectoplot_text.txt
tectoplot -t -text tectoplot_text.txt -o example_text
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

# -text [file] [xoff] [yoff]
    if ! arg_is_flag "${2}"; then
      TEXTFILE=$(abs_path "${2}")
      shift
    else
      info_msg "[-text]: text file needed as argument"
      exit
    fi
    TEXTLINE=""
    TEXTXOFF=0
    TEXTYOFF=0

    while ! arg_is_flag $2; do
      case $2 in
        default)
          shift
          TEXTDEFAULT=1
        ;;
        box)
          shift
          if ! arg_is_flag $2; then
            TEXTBOX="-G${2} -W0.25p,black"
            shift
          else
            echo "[-text]: box option requires color argument"
            exit 1
          fi
        ;;
        line)
          shift
          TEXTLINE="+v1p,black"
        ;;
        offset)
          shift
          if ! arg_is_flag "${2}"; then
            TEXTXOFF="${2}"
            shift
          fi
          if ! arg_is_flag "${2}"; then
            TEXTYOFF="${2}"
            shift
          fi
        ;;
      esac
    done
    plots+=("text")
    ;;

  -tflat) # -tflat: flatten bathymetry with elevation less than zero to zero
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tflat:        flatten bathymetry with elevation less than zero to zero
Usage: -tflat

  This function alters the DEM to have a flat sea surface. Use with -tunsetflat
  to make maps of land areas with shadows that extend onto the sea surface.

--------------------------------------------------------------------------------
EOF
shift && continue
fi
      fasttopoflag=0
      tflatflag=1
    ;;

  -ti) # -ti: adjust illumination for GMT style topography
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ti:           adjust illumination for gmt style topography
Usage: -ti [[azimuth]]

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if [[ $2 =~ ^[-+]?[0-9]*.*[0-9]+$ || $2 =~ ^[-+]?[0-9]+$ ]]; then   # first arg is a number
      ILLUM="-I+a${2}+nt1+m0"
      shift
    elif arg_is_flag $2; then   # first arg doesn't exist or starts with - but isn't a number
      info_msg "[-ti]: No options specified. Ignoring."
    elif [[ ${2} =~ "off" ]]; then
      ILLUM=""
      shift
    else
      info_msg "[-ti]: option $2 not understood. Ignoring"
      shift
    fi
    ;;

  -timeme) # -timeme: print script total run time on completion
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-timeme:       print script total run time on completion
Usage: -timeme

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    scripttimeflag=1
    ;;

  -time) # -time: select seismic data from a continuous time range
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-time:         select seismic data from a continuous epoch
Usage: -time [start_time] [[end_time]]
Usage: -time [[day number]] [[week number]] [[month number]] [[year number]]
Usage: -time [eq] [earthquake_ID] [years_before]

  Times are in IS8601 YYYY-MM-DDTHH:MM:SS format.
  YYYY, YYYY-MM, etc. will work.

  To plot the last two weeks plus one day: -time day 1 week 2

  If an earthquake ID is specified, set the start time to [buffer] years before
  the earthquake, and set the end time to the present moment.

Example: Solomon Islands seismicity between Jan 1 2001 and Jan 1 2005
tectoplot -r SB -t -z -c -time 2001-01-01 2005-01-01 -o example_time
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    STARTTIME=$(date_shift_utc $daynum 0 0 0)
    ENDTIME=$(date_shift_utc)    # COMPATIBILITY ISSUE WITH GNU date

    timeselectflag=1
    if [[ "${2}" == "day" || $2 == "year" || $2 == "week" || $2 == "month" ]]; then
      daynum=0
      hournum=0
      minutenum=0
      secondnum=0
      while ! arg_is_flag $2; do
        case "${2}" in
          "day")
            shift
            if arg_is_positive_float $2; then
              thisdaynum=${2}
              shift
            else
              info_msg "[-time]: day requires a positive float argument"
              exit 1
            fi
            daynum=$(echo "$daynum + -1 * $thisdaynum" | bc -l)
            ;;
          "week")
            shift
            if arg_is_positive_float $2; then
              weeknum=${2}
              shift
            else
              info_msg "[-time]: week requires a positive float argument"
              exit 1
            fi
            daynum=$(echo "$daynum + -1 * $weeknum * 7" | bc -l)
            ;;
          "month")
            shift
            if arg_is_positive_float $2; then
              yearnum=${2}
              shift
            else
              info_msg "[-time]: month requires a positive float argument"
              exit 1
            fi
            daynum=$(echo "$daynum + -1 * $yearnum * 30" | bc -l)
            ;;
          "year")
            shift
            if arg_is_positive_float $2; then
              yearnum=${2}
              shift
            else
              info_msg "[-time]: year requires a positive float argument"
              exit 1
            fi
            daynum=$(echo "$daynum + -1 * $yearnum * 365.25" | bc -l)
            ;;
          "second")
            shift
            if arg_is_positive_float $2; then
              secondnum=${2}
              shift
            else
              info_msg "[-time]: second requires a positive float argument"
              exit 1
            fi
            ;;
          "hour")
            shift
            if arg_is_positive_float $2; then
              hournum=${2}
              shift
            else
              info_msg "[-time]: hour requires a positive float argument"
              exit 1
            fi
            ;;
          "minute")
            shift
            if arg_is_positive_float $2; then
              minutenum=${2}
              shift
            else
              info_msg "[-time]: minute requires a positive float argument"
              exit 1
            fi
            ;;
        esac
      done
      # Calculate
      info_msg "[-time]: Selecting from last $daynum days $hournum hours $minutenum minutes and $secondnum seconds before present date"
      STARTTIME=$(date_shift_utc $daynum $hournum $minutenum $secondnum)
      ENDTIME=$(date_shift_utc)    # COMPATIBILITY ISSUE WITH GNU date
    elif [[ $2 == "eq" ]]; then
      shift
      settimebyearthquakeflag=1
      if ! arg_is_flag "${2}"; then
        TIME_EQID="${2}"
        shift
      else
        echo "[-time eq]: Earthquake ID argument required"
        exit 1
      fi
      if ! arg_is_flag "${2}"; then
        TIME_BEFORE_BUFFER="${2}"
        shift
      else
        echo "[-time eq]: Years before buffer argument required"
        exit 1
      fi
    else
      if ! arg_is_flag "${2}"; then
        STARTTIME=$(echo "${2}" | iso8601_from_partial)
        shift
      fi
      if ! arg_is_flag "${2}"; then
        ENDTIME=$(echo "${2}" | iso8601_from_partial)
        shift
      fi
      info_msg "Time constraints: $STARTTIME to $ENDTIME"
    fi
    ;;

  -theme) # -theme: activate a predefined map theme
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-theme:        select a predefined map theme
Usage: -theme [theme_id]

  Theme IDs:
  avant
  avantsmall
  classic

Example:
tectoplot -theme avant -a -o example_theme
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    if ! arg_is_flag "${2}"; then
      THEME_ID="${2}"
      shift
    fi
    ;;

  -title) # -title: set and display a plot title
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-title:        set and display plot title
Usage: -title "Title of Map"

Example: Solomon Islands
tectoplot -r SB -a -title "Solomon Islands" -o example_title
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    PLOTTITLE=""
    while : ; do
      arg_is_flag $2 && break
      TITLELIST+=("${2}")
      shift
    done
    PLOTTITLE="${TITLELIST[@]}"
    plottitleflag=1
    plots+=("maptitle")
    ;;



#   -tn) # -tn: plot topographic contours
# if [[ $USAGEFLAG -eq 1 ]]; then
# cat <<-EOF
# -tn:           plot topographic contours
# Usage: -tn [[options]]
#
#   Plot contours of -t topography.
#
#   Options:
#
#   int [number | auto]
#       Contour interval
#   fontsize [number]
#       Set font size for contour labels
#   index [number]
#       Set specified contour to be a major contour
#   list [level1,level2,...]
#       Use the comma-specified list, plot all as major contours
#   minsize [arg]
#       Suppresses plotting of small closed contours
#       specify minimum numbner of points (e.g. 500) or length (e.g. 10k)
#   smooth [arg]
#       Smooth contours by a factor (e.g. 3)
#   major [width] [[color]]
#       Set appearance of major contours
#   minor [width] [[color]]
#       Set appearance of minor contours
#   trans [percent]
#       Set transparency of all contours
#   space [distance]
#       Set spacing between contour labels (inches, e.g. 0.5i)
#
#
#
# Example:
# tectoplot -t -tn 1000 -o example_tn
# ExampleEnd
# --------------------------------------------------------------------------------
# EOF
# shift && continue
# fi
#     TOPOCONTOURTRANS=""
#     TOPOCONTOURSPACE=""
#     TOPOCONTOURMINSIZE=""
#     TOPOCONTOURSMOOTH=""
#     TOPOCONTOURINDEX=0       # Value of an index contour
#     TOPOCONTOURINT=100       # Default contour interval
#     TOPOCONTOURFONTSIZE=2    # small labels
#
#     topocontourindexflag=0
#     CONTOURMAJORSPACE=5
#     TOPOCONTOURSPACE=""
#     TOPOCONTOURLABELSEP="0.5i"
#
#     TOPOCONTOURMINORWIDTH=0.1
#     TOPOCONTOURMAJORWIDTH=0.25
#     TOPOCONTOURMINORCOLOR="black"
#     TOPOCONTOURMAJORCOLOR="black"
#
#     while ! arg_is_flag $2; do
#       case $2 in
#         fontsize)
#           shift
#           if arg_is_positive_float $2; then
#             TOPOCONTOURFONTSIZE="${2}"
#             shift
#           else
#             echo "[-tn]: fontsize option requires positive number argument"
#             exit 1
#           fi
#         ;;
#         int)
#           shift
#           if arg_is_positive_float $2; then
#             TOPOCONTOURINT="${2}"
#             shift
#           elif [[ $2 == "auto" ]]; then
#             topocontourcalcflag=1
#             shift
#           else
#             echo "[-tn]: int option requires positive number argument"
#             exit 1
#           fi
#         ;;
#         index)
#           shift
#           if arg_is_float $2; then
#             topocontourindexflag=1
#             TOPOCONTOURINDEX="${2}"
#             shift
#           else
#             echo "[-tn]: index option requires number argument"
#             exit 1
#           fi
#         ;;
#         list)
#           shift
#           if [[ $2 == "" ]]; then
#             echo "[-tn]: list option requires comma-separated list argument"
#             exit 1
#           else
#             if [[ $2 == *,* ]]; then
#               TOPOCONTOURLIST="${2}"
#             else
#               TOPOCONTOURLIST="${2},"
#             fi
#             topocontourlistflag=1
#             shift
#           fi
#           ;;
#         number)
#           shift
#           if arg_is_positive_integer $2; then
#             TOPOCONTOURNUMDEF=$2
#             shift
#           else
#             echo "[-tn]: number option requires positive integer argument"
#             exit 1
#           fi
#           ;;
#         minsize)
#           shift
#           if ! arg_is_flag $2; then
#             TOPOCONTOURMINSIZE="-Q${2}"
#             shift
#           else
#             echo "[-tn]: minsize requires argument"
#             exit 1
#           fi
#         ;;
#         smooth) # int
#           shift
#           if arg_is_positive_float $2; then
#             TOPOCONTOURSMOOTH="-S${2}"
#             shift
#           else
#             echo "[-tn]: smooth requires positive float argument"
#             exit 1
#           fi
#         ;;
#         major) # [width] [[color]]
#           shift
#           if arg_is_positive_float $2; then
#             TOPOCONTOURMAJORWIDTH=$2
#             shift
#             if ! arg_is_flag $2; then
#               TOPOCONTOURMAJORCOLOR=$2
#               shift
#             fi
#           else
#             echo "[-tn]: major requires positive float width argument"
#             exit 1
#           fi
#         ;;
#         minor) # [width] [[color]]
#           shift
#           if arg_is_positive_float $2; then
#             TOPOCONTOURMINORWIDTH=$2
#             shift
#             if ! arg_is_flag $2; then
#               TOPOCONTOURMINORCOLOR=$2
#               shift
#             fi
#           else
#             echo "[-tn]: minor requires positive float width argument"
#             exit 1
#           fi
#         ;;
#         trans) # [percent]
#           shift
#           if arg_is_positive_float $2; then
#             TOPOCONTOURTRANS="-t$2"
#             shift
#           else
#             echo "[-tn]: trans requires positive float width argument"
#             exit 1
#           fi
#         ;;
#         space) # [degrees]
#           shift
#           if ! arg_is_flag $2; then
#             TOPOCONTOURLABELSEP="$2"
#             shift
#           else
#             echo "[-tn]: space requires positive float width argument"
#             exit 1
#           fi
#         ;;
#         *)
#           echo "[-tn]: option $2 not recognized"
#           exit 1
#         ;;
#       esac
#     done
#
#     plots+=("contours")
    # ;;



  -tr) # -tr: rescale topography color stretch to data range
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tr:           rescale topography color stretch to data range
Usage: -tr [[options]]

  Stretch the CPT color scheme across the topographic range in the DEM (default),
  or between given values. Spacing dictates width of CPT z-slices.

  Default behavior is to respect a hinge at elevation 0 to avoid mixing sea and
  land colors.

  Options:
  minmax [min] [max]           set range of rescaled topography
  nohinge                      turn of hinge behavior in the rescaled cpt
  shiftzero [value]            shift CPT slices by constant value after rescale

Example:
tectoplot -t -tr -o example_tr
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    while ! arg_is_flag $2; do
      case $2 in
        minmax)
          shift
          if arg_is_float "${2}"; then
            RESCALE_TMIN="${2}"
            rescaletopominflag=1
            shift
          else
            echo "[-tr]: option minmax requires minimum number argument"
            exit 1
          fi

          if arg_is_float "${2}"; then
            RESCALE_TMAX="${2}"
            rescaletopomaxflag=1
            shift
          else
            echo "[-tr]: option minmax requires maximum number argument"
            exit 1
          fi
        ;;
        nohinge)
          shift
          cptnohingeflag=1
        ;;
        nostretch)
          shift
          cptnostretchflag=1
        ;;
        shiftzero)
          shift
          cptshiftzeroflag=1
          if arg_is_float $2; then
            CPT_SHIFTZERO=$2
            shift
          else
            echo "[-tr]: option shiftzero requires number argument"
            exit 1
          fi
        ;;
        *)
          echo "[-tr]: option $2 not recognized"
          exit 1
        ;;
      esac
    done
    [[ $cptnostretchflag -ne 1 ]] && rescaletopoflag=1
    ;;

  -trp) # -trp: rescale cpt by two different factors, above and below 0
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-trp:           rescale cpt by two different factors, above and below 0
Usage: -trp [below] [above]

  Stretch the CPT color scheme by multiplying values > 0 by [above] and
  values < 0 by [below].

  above, below are scale factors greater than 0

  above|below < 1: CPT colors are compressed toward 0
  above|below > 1: CPT colors are stretched away from 0

Example:
tectoplot -t -trp 1.5 0.1 -o example_trp
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

      if arg_is_float "${2}"; then
        MULT_CPT_BELOW="${2}"
        shift
      else
        MULT_CPT_BELOW=1
      fi
      if arg_is_float "${2}"; then
        MULT_CPT_ABOVE="${2}"
        shift
      else
        MULT_CPT_ABOVE="none"
      fi

      multiplyrescaletopoflag=1
      ;;

  -ts) # -ts: do topo calculations but don't plot the final topography image

if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ts:           do topo calculations but don't plot the final topography image
Usage: -ts

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    dontplottopoflag=1
    ;;

  -tt) # -tt: set the transparency of shaded relief
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tt:           set the transparency of shaded relief
Usage: -tt [transparency]

Example:
tectoplot -a -t -tt 50 -o example_tt
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    TOPOTRANS=${2}
    shift
    ;;

  -tx) # -tx: don't color topography (plot grayscale intensity only)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tx:           don"t color the topography - plot grayscale intensity only
Usage: -tx

  Only works with non-GMT visualization schemes (-tmult etc)

Example:
tectoplot -t -tsl -tx -o example_tx
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    dontcolortopoflag=1
    ;;

  -t0) # -t0: recipe for slopeshade terrain visualization
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-t0:           slopeshade terrain visualization
Usage: -t0

  Plot shaded relief map using fused multiple hillshade and slope.

Example: Slopeshade map
tectoplot -t -t0 -o example_t0
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    topoctrlstring="msg"
    useowntopoctrlflag=1
    fasttopoflag=0
    SLOPE_FACT=0.5
    HS_GAMMA=1.4
    HS_ALT=45
    ;;


  -tzero) # -tzero: subtract 0.1 meters from any topo cells with elevation=0
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tzero:        fix 0 elevation to -0.1 meters before plotting topo
Usage: -tzero [[value]]
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  tzeroadjustflag=1
  TZEROADJUSTVAL=-0.1
  if arg_is_float $2; then
    TZEROADJUSTVAL=${2}
    shift
  fi
  ;;

  -tdenoise) # -tdenoise: Use Xianfang Sun's mdenoise to smooth the DEM
  DENOISE_THRESHOLD=0.9
  DENOISE_ITERS=5
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tdenoise:     Use Xianfang Sun's mdenoise to smooth DEM
Usage: -tdenoise [[threshold=${DENOISE_THRESHOLD}]] [[iterations=${DENOISE_ITERS}]]

  Apply mdenoise algorithm to DEM. This algorithm is a mesh-based smoothing
  routine that can reduce bumps and pits while preserving facets.

  threshold [0-1]: controls how far the mesh can deviate from the original.
                   low values allow larger deviations from true
  iterations [1-N]: the number of times the smoothing is applied. more=smoother

--------------------------------------------------------------------------------
EOF
shift && continue
fi

  tdenoiseflag=1


  if arg_is_positive_float $2; then
    DENOISE_THRESHOLD=$2
    shift
  fi
  if arg_is_positive_float $2; then
    DENOISE_ITERS=$2
    shift
  fi
  ;;

  -tshad) # tshad: add cast shadows to intensity
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tshad:        add cast shadows to terrain intensity
Usage: -tshad [[sun_azimuth]] [[sun_elevation]] [[alpha]] [[fast]]

  Include cast shadows in shaded relief.

  sun_azimuth: angle CW from north, degrees
  sun_elevation: angle up from horizon, degrees
  alpha: transparency of cast shadows

Example: Cast shadows
tectoplot -t -t0 -tshad 45 2 -o example_tshad
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    fasttopoflag=0
    SHADOW_FAST=""
    if arg_is_float $2; then   # first arg is a number
      SUN_AZ="$2"
      shift
    fi
    if arg_is_positive_float $2; then   #
      SUN_EL=${2}
      shift
    fi
    if arg_is_float $2; then
      SHADOW_ALPHA=$2
      shift
    fi
    if [[ $2 == "fast" ]]; then
      SHADOW_FAST="-fast"
      shift
    fi
    info_msg "[-tshad]: Sun azimuth=${SUN_AZ}; elevation=${SUN_EL}; alpha=${SHADOW_ALPHA}"
    topoctrlstring=${topoctrlstring}"d"
    useowntopoctrlflag=1
    ;;

  -ttext) # ttext: add Leland Brown's texture mapping to intensity
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ttext:        add Leland Brown's texture mapping to intensity
Usage: -ttext [[frac=${TS_FRAC}]] [[stretch=${TS_STRETCH}]] [[fact=${TS_FACT}]]

  The texture map visualization by Leland Brown uses a DCT calculation to
  visualize relief.
  frac: detail parameter
  stretch: contrast stretch parameter
  fact: blend factor with white before blending to terrain intensity [0-1]

Example: Texture map
tectoplot -t -ttext 1.5 5 0.7 -tpct 1 99 -tgam 0.6 -o example_ttext
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    fasttopoflag=0
    if arg_is_positive_float $2; then   #
      TS_FRAC=${2}
      shift
    fi
    if arg_is_positive_float $2; then   #
      TS_STRETCH=${2}
      shift
    fi
    if arg_is_positive_float $2; then   #
      TS_FACT=${2}
      shift
    fi
    info_msg "[-ttext]: Texture detail=${TS_FRAC}; contrast stretch=${TS_STRETCH}; combine factor=${TS_FACT}"
    topoctrlstring=${topoctrlstring}"t"
    useowntopoctrlflag=1
    ;;

  -tmultcolor) # -tmultcolor:   make a vibrant multiple direction hillshade
  TMULT_COLOR_ALT=35
  TMULT_COLOR_AZ=315
  TMULT_COLOR_TRANS=0
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tmultcolor:   make a vibrant multiple direction hillshade
Usage: -tmultcolor

  Multiple hillshade is a combination of illumination from different directions
  under a constant solar altitude. This version uses three different hillshades
  as the R/G/B bands of a tiff

Example: Multiple hillshade map
tectoplot -t -tmultcolor -o example_tmultcolor
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  plots+=("tmultcolor")
   ;;

  -tmult) # -tmult: add multiple direction hillshade (grayscale) to terrain intensity

if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tmult:        add multiple direction hillshade (grayscale) to terrain intensity
Usage: -tmult [[sun_alt=${HS_ALT}]] [[fact=${MULTIHS_FACT}]]

  Multiple hillshade is a combination of illumination from different directions
  under a constant solar altitude.

Example: Multiple hillshade map
tectoplot -t -tmult -o example_tmult
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    fasttopoflag=0
    if arg_is_positive_float $2; then   #
      HS_ALT=${2}
      shift
    fi
    if arg_is_float $2; then
      MULTIHS_FACT=$2
      shift
    fi
    info_msg "[-tmult]: Sun elevation=${HS_ALT}; combine factor=${MULTIHS_FACT}"
    topoctrlstring=${topoctrlstring}"m"
    useowntopoctrlflag=1
    ;;

  -tdc) # -tdc: Add color stretch to custom topo

if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tdc:        Add color stretch to topo
Usage: -tdc

tectoplot -t -tdc -o example_tdc
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    fasttopoflag=0
    topoctrlstring=${topoctrlstring}"c"
    useowntopoctrlflag=1
    ;;

  -tuni) # -tuni: add unidirectional hillshade to intensity
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tuni:         add unidirectional hillshade to terrain intensity
-tuni [[sun_az=${HS_AZ}]] [[sun_alt=${HS_ALT}]] [[fact=${UNIHS_FACT}]]

  Unidirectional hillshade is illumination from one direction and solar
  altitude.

Example: Unidirectional hillshade
tectoplot -r -113 -112.3 36 36.5 -t 01s -tuni -o example_tuni
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    fasttopoflag=0
    if arg_is_float $2; then   # first arg is a number
      HS_AZ="$2"
      shift
    fi
    if arg_is_positive_float $2; then   #
      HS_ALT=${2}
      shift
    fi
    if arg_is_float $2; then
      UNIHS_FACT=$2
      shift
    fi
    info_msg "[-tuni]: Sun azimuth=${SUN_AZ}; elevation=${SUN_EL}; combine factor=${UNIHS_FACT}"
    topoctrlstring=${topoctrlstring}"h"
    useowntopoctrlflag=1
    ;;

  -cptrescale) # -cptrescale: rescale an input cpt

if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-cptrescale:    rescale cpt
Usage: -cptrescale [cptfile] [low] [high]

  Rescale an input CPT file and replace color names with RGB values.

--------------------------------------------------------------------------------
EOF
shift && continue
fi

    rescale_cpt $2 $3 $4
    replace_gmt_colornames_rgb $2
    shift
    shift
    shift
    exit 0
    ;;

  -tmix)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tmix:         Combine two cpt files using spacing of first CPT, then exit
Usage: -tmix [cpt1] [cpt2] [[type=multiply]]

  Combined CPT is in ${TMP}/mix.cpt

Example:
tectoplot -t -tmix geo turbo -tcpt mix.cpt -o example_tmix
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  cpt1=$2
  shift
  cpt2=$2
  shift
  range1=$2
  shift
  range2=$2
  shift
  step=$2
  shift
  mode=$2
  shift

  gmt makecpt -Fr -C${cpt1} -T${range1}/${range2}/${step} -Vn > ${TMP}mix1.cpt
  gmt makecpt -Fr -C${cpt2} -T${range1}/${range2}/${step} -Vn > ${TMP}mix2.cpt

  merge_cpts ${TMP}mix1.cpt ${TMP}mix2.cpt ${TMP}mix.cpt ${mode}
  exit 0

  ;;


  -tcpt) # -tcpt: specify the CPT file defining topography color stretch
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tcpt:         specify the CPT file defining topography color stretch
Usage: -tcpt [cpt=${TOPO_CPT_DEF}] [[direct]]

  cpt = path to CPT file or builtin CPT name

  If the "direct" option is given, CPT is used without any modification

  Note: Use -tr to rescale a default CPT to the topographic elevation range

Example:
tectoplot -t -tcpt turbo -tr -o example_tcpt
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

# type:
# d = discrete
# c = continuous


  # Check if it's a file path;
  # If not, check if its a builtin GMT CPT

  if ! arg_is_flag "${2}"; then
    if get_cpt_path ${2}; then
      info_msg "[-tcpt]: Setting CPT to ${CPT_PATH}"
      TOPO_CPT_DEF=${CPT_PATH}
    fi
    shift
  fi

  if [[ $2 == "direct" ]]; then
    cptdirectflag=1
    shift
    if [[ -s ${CPT_PATH} ]]; then
      CUSTOM_TOPO_CPT=${CPT_PATH}
    else
      echo "[-tcpt]: direct option requires ${CPT_PATH} to be an existing file"
      exit 1
    fi
  fi
  ;;

  -tpct) # -tpct: contrast enhancement by percent cut (lo/hi) of terrain intensity

if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tpct:         contrast enhancement by percent cut (lo/hi) of terrain intensity
Usage: -tpct [[lowcut=${TPCT_MIN}]] [[highcut=${TPCT_MAX}]]

  Operates on the existing terrain intensity at the moment of application.
  Cells with intensity below (lowcut) and above (highcut) the given percentages
  are assigned to 1 or 254. All values between are stretched to fit.

Example: Percent cut on a multiple hillshade
tectoplot -r -113 -112.3 36 36.5 -t 01s -tmult -tpct 25 75 -o example_tpct
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    fasttopoflag=0
    if arg_is_float $2; then   # first arg is a number
      TPCT_MIN="$2"
      shift
    fi
    if arg_is_positive_float $2; then   #
      TPCT_MAX=${2}
      shift
    fi
    info_msg "[-tpct]"
    topoctrlstring=${topoctrlstring}"x"
    useowntopoctrlflag=1
    ;;

  -tsea) # -tsea: recolor sentinel satellite imagery in ocean areas
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tsea:         recolor sentinel satellite imagery in ocean areas
Usage: -tsea [[red]] [[green]] [[blue]]

  Requires -tsent or -tblue option prior to -tsea

  Sentinel imagery above the oceans has baked in subaqueous relief or clouds.
  Set the ocean areas (z=0) to a fixed color.

Example: Recolor the ocean around Yemen
tectoplot -t -t0 -tsent -tsea -o example_tsea
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    fasttopoflag=0
    if ! arg_is_flag $2; then
      SENTINEL_RECOLOR_R=${2}
      shift
    fi
    if ! arg_is_flag $2; then
      SENTINEL_RECOLOR_G=${2}
      shift
    fi
    if ! arg_is_flag $2; then
      SENTINEL_RECOLOR_B=${2}
      shift
    fi
    sentinelrecolorseaflag=1
    ;;

  -imblue)
  IMBLUE_TRANS=0
  IMBLUE_RES=10m
  imbluedontplotimageflag=0
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-imblue:        nasa blue marble imagery
Usage: -imblue [[resolution=${IMBLUE_RES}]] [[trans=${IMBLUE_TRANS}]]

  Plot dynamically downloaded NASA Blue Marble imagery.
  The image is automatically saved in an archive based on extent and resolution

  Creates earthday.tif in ${TMP}

Example: Blue Marble
tectoplot -t -r YE -t0 -imblue -o example_imblue
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if [[ $2 == "noplot" ]]; then
      imbluedontplotimageflag=1
      shift
    fi
    if ! arg_is_flag $2; then
      info_msg "[-imblue]: Blue Marble image resolution set to $2"
      IMBLUE_RES=${2}
      shift
    fi
    if arg_is_positive_float $2; then
      info_msg "[-imblue]: Blue Marble image transparency set to $2"
      IMBLUE_TRANS=${2}
      shift
    fi

    plots+=("bluemarble")
  ;;

  -tblue) # -tblue: NASA blue marble imagery

if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tblue:        nasa blue marble imagery
Usage: -tblue [[fact=${SENTINEL_FACT}]] [[gamma=${SENTINEL_GAMMA}]]

  Use dynamically downloaded NASA Blue Marble imagery as the color that is
  multiplied with terrain intensity.
  The image is automatically saved in an archive based on extent and resolution

Example: Blue Marble
tectoplot -t -r YE -t0 -tblue -o example_tblue
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    fasttopoflag=0
    SENTINEL_TYPE="bluemarble"
    SENTINEL_FACT=0.5
    if arg_is_positive_float $2; then
      info_msg "[-tblue]: Blue Marble image alpha values set to $2"
      SENTINEL_FACT=${2}
      shift
    fi
    if arg_is_positive_float $2; then
      info_msg "[-tblue]: Blue Marble image gamma correction set to $2"
      SENTINEL_GAMMA=${2}
      shift
    fi

    touch ./sentinel_img.jpg
    sentineldownloadflag=1
    shift
    set -- "blank" "$@" "-timg" "img" "sentinel_img.jpg" "${SENTINEL_FACT}"
    ;;

  -tn)
    shift
    set -- "blank" "-cn" "topo/dem.tif" "$@"
  ;;

  -tw) # set intensity raster to white
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tw:        set terrain intensity to white
Usage: -tw
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  useowntopoctrlflag=1
  fasttopoflag=0
  topoctrlstring=${topoctrlstring}"b"

  ;;

  -tsave) # -tsave: archive terrain visualization for a named region
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tsave:        archive terrain data for a named region
Usage: -tsave

  If using -r RegionID, save the rendered terrain image for later rapid use.
  Requires -radd RegionID prior to calling tectoplot with -tsave or -tload

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    tsaveflag=1
    ;;

  -tload) # -tload: load archived terrain data for a named region
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tload:        load archived terrain data for a named region
Usage: -tload

  If using -r RegionID, load a saved rendered terrain image.
  Requires -radd RegionID prior to calling tectoplot with -tsave or -tload

  [[Currently requires -t0, -tsl, or another -txxx call in order to not have the
  fast topo visualization run...]]

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    fasttopoflag=0
    tloadflag=1
    ;;

  -tdelete) # -tdelete: delete archived terrain data for a named region
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tdelete:      delete archived terrain data for a named region (or all data)
Usage: -tdelete [[all]]

  If using -r RegionID, delete a saved rendered terrain image.
  Requires -radd RegionID prior to calling

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    tdeleteflag=1

    if [[ $2 == "all" ]]; then
      tedeleteallflag=1
      shift
    fi

    ;;

  -notopobar)
notopobarflag=1
  ;;

  -tsent) # -tsent: color terrain using downloaded sentinel cloud-free image
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tsent:        color terrain using downloaded sentinel cloud-free image
Usage: -tsent [[fact=${SENTINEL_FACT}]] [[options]] [[img imgoptions]]

  Note: There is still an issue with blending against pure black/white.

  Options:
  gamma        apply gamma adjustment
  notopo       don't plot topo, only sentinel image
  upsample      upsample image

  imgoptions are any further options recognized by -timg


Example: Sentinel cloud free image draped onto multi-hillshade, Arizona USA
tectoplot -r -113 -112.3 36 36.5 -t 01s -tmult -tsent 0.2 -o example_tsent
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    fasttopoflag=0
    tsentflag=1
    SENTINEL_TYPE="s2cloudless-2019"
    SENTINEL_FACT=0.5
    if arg_is_positive_float $2; then
      info_msg "[-tsent]: Sentinel image alpha values set to $2"
      SENTINEL_FACT=${2}
      shift
    fi

    while ! arg_is_flag $2; do
      case $2 in
        gamma)
          shift
          if arg_is_positive_float $2; then
            info_msg "[-tsent]: Sentinel image gamma correction set to $2"
            SENTINEL_GAMMA=${2}
            shift
          else
            echo "[-tsent]: gamma option requires number argument"
            exit 1
          fi
        ;;
        notopo)
          info_msg "[-tsent]: No topo plotted with Sentinel data"
          sentinelnotopoflag=1
          shift
        ;;
        upsample)
          shift
          SENTINEL_DOWNSAMPLE=0
        ;;
        img)
          shift
          while ! arg_is_flag $2; do
            SENT_IMOPTS+=("$2")
            shift
          done
        ;;
        *)
          echo "[-tsent]: option $2 not recognized"
          exit 1
        ;;
      esac
    done

    touch ./sentinel_img.jpg
    sentineldownloadflag=1
    # Replace -tsent with -timg [[sentinel_img.jpg]] [[alpha]]
    shift
    set -- "blank" "$@" "-timg" "img" "sentinel_img.jpg" "${SENTINEL_FACT}" ${SENT_IMOPTS[@]}
    ;;

  -tsky) # -tsky: add sky view factor to intensity
  NUM_SVF_DIST=45
  NUM_SVF_SKIP=5
  NUM_SVF_ANGLES=8 
  NUM_SVF_CORES=8

if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tsky:         add sky view factor to terrain intensity
Usage: -tsky [[num_angles=${NUM_ANGLES}]] [[fact=${SKYVIEW_FACT}]]

  Include sky view factor in shaded relief.

Example: Sky view factor of Pennsylvania, UTM
tectoplot -r -113 -112.3 36 36.5 -t 01s -tsky -o example_tsky
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    fasttopoflag=0

    while ! arg_is_flag $2; do
      case $2 in
        skip)
          shift
          if ! arg_is_float $2; then
            echo "[-tsky]: skip option requires positive integer argument"
            exit 1
          fi
          NUM_SVF_SKIP=$2
          shift
        ;;
        dist)
          shift
          if ! arg_is_float $2; then
            echo "[-tsky]: skip option requires positive integer argument"
            exit 1
          fi
          NUM_SVF_DIST=$2
          shift
        ;;
        angles)
          shift
          if ! arg_is_float $2; then
            echo "[-tsky]: skip option requires positive integer argument"
            exit 1
          fi
          NUM_SVF_ANGLES=$2
          shift
        ;;
        cores)
          shift
          if ! arg_is_float $2; then
            echo "[-tsky]: skip option requires positive integer argument"
            exit 1
          fi
          NUM_SVF_CORES=$2
          shift
        ;;
        fact)
          shift
          if ! arg_is_float $2; then
            echo "[-tsky]: fact option requires positive float argument"
            exit 1
          fi
          SKYVIEW_FACT=$2
          shift
        ;;
        *)
          echo "[-tsky]: unknown option $2"
          exit 1
        ;;

      esac
    done

    info_msg "[-tsky]: Number of angles=${NUM_ANGLES}; combine factor=${SKYVIEW_FACT}"
    topoctrlstring=${topoctrlstring}"v"
    useowntopoctrlflag=1
    ;;

  -makeply) # -makeply: make a 3D Sketchfab model including topo, FMS, seismicity, Slab2.0

if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-makeply:      make a 3D Sketchfab model including topo, FMS, seismicity, Slab2.0
Usage: -makeply [[option1 value1]] [[option2 value2]] ...

    Topo, seismicity, focal mechanisms, GPS velocities, volcanoes, and Slab2 geometries will be generated
    automatically if the equivalent -t, -z, -c, -g, -vf, or -b commands are given.

    Options:
    [[landkm spacing=${PLY_FIB_KM}]]
       Spacing of surface grid pts if no DEM given
    [[scale factor=${PLY_SCALE}]]
       Rescale scaleable items by multiplying by this factor
    [[vexag factor=${PLY_VEXAG}]]
       Vertical exaggeration of data
    [[topoexag factor=${PLY_VEXAG_TOPO}]]
       Vertical exaggeration of DEM
    [[demonly]]
       Only make DEM mesh and texture, not other 3D data
    [[addz offset=${PLY_ZOFFSET}]]
       Vertical shift (positive away from Earth center) in km
    [[maxsize size=${PLY_MAXSIZE}]]
       Resample DEM to given maximum width (cells) before meshing
    [[alpha value=${PLY_ALPHACUT}]]
       Apply alpha mask to DEM texture using transparent PNG
    [[sidebox depth=${PLY_SIDEBOXDEPTH} color=${PLY_SIDEBOXCOLOR}]]
       Make sides and bottom of box under topo
    [[sidetext on|off v_int h_int]]
       Plot text on sidebox? If on, v_int in km, h_int in degrees
    [[maptiff]]
       Use rendered map TIFF as topo texture
    [[mtl name=${PLY_MTLNAME}]]
       Set name of DEM OBJ and its corresponding material
    [[fault file1 file2 ...]]
       Make colored mesh of gridded fault(s) data
    [[ocean]]
       Make ocean layer at given ocean depth
    [[box depth(km)=${PLY_BOXDEPTH}]]
       Draw box encompassing seismicity OR at fixed depth
    [[text depth(km) string of words ]]
       Print text at center of plane defined by corner points
    [[floattext lon lat depth scale string of words]]
       Generate 3d text at specified location and scale
    [[seisball minmag=${PLT_POLYMAG} power=${PLY_POLYMAG_POWER} scale=${PLY_POLYSCALE}]]
       Generate 3d balls for seismicity above the specified magnitude
    [[noply]]
       Do not add PLY vertices for earthquakes to the model
    [[nomesh]]
       Do not create mesh from DEM

    See also: -addobj    Include OBJ files from specified directory

--------------------------------------------------------------------------------
EOF
shift && continue
fi
  makeplyflag=1
  addseisplyflag=1
  makeplydemmeshflag=1
  plydemonlyflag=0
  makeplysurfptsflag=0

  while ! arg_is_flag "${2}"; do

    case "${2}" in
    nomesh)
      shift
      makeplydemmeshflag=0
    ;;
    contour)
      shift
      makeplydemcontourflag=1
      ;;
    noply)
      addseisplyflag=0
      shift
      ;;
    seisball)
      shift
      PLY_SEISBALL=1
      if arg_is_float "${2}"; then
        PLY_POLYMAG="${2}"      # Minimum magnitude of earthquakes drawn as polygons instead of points
        shift
      fi
      if arg_is_positive_float "${2}"; then
        PLY_POLYMAG_POWER="${2}"    # Radius of polymag eqs is multiplied by magnitude to this power
        shift
      fi
      if arg_is_positive_float "${2}"; then
        PLY_POLYSCALE="${2}"    # Scale factor (radius of M=1) for earthquake polygons 1 = 100km
        shift
      fi
      ;;
    # center)
    #   shift
    #   PLY_CENTERFLAG=1
    #   ;;
    # shift)
    #   shift
    #   PLY_SHIFTFLAG=1
    #   ;;
    sidetext)
      shift
      echo 2 is now ${2}
      if [[ ${2} =~ "off" ]]; then
        PLY_SIDEBOXTEXT=0
        shift
      fi
      if [[ ${2} =~ "on" ]]; then
        PLY_SIDEBOXTEXT=1
        shift
      fi
      if arg_is_positive_float "${2}"; then
        PLY_SIDEBOXINTERVAL_SPECIFY=1
        PLY_SIDEBOXINTERVAL_VERT="${2}"
        shift
      fi
      if arg_is_positive_float "${2}"; then
        PLY_SIDEBOXINTERVAL_SPECIFY=1
        PLY_SIDEBOXINTERVAL_HORZ="${2}"
        shift
      fi
      ;;
      line)
        shift
         if [[ -s $2 ]]; then
           PLY_POLYLINEFILE=$(abs_path $2)
           shift
         else
           echo "[-makeply]: polyline file $2 is empty or does not exist"
           exit 1
         fi
      ;;
      text)
      shift
      plymaketextflag=1
      PLY_TEXTSTRING=""
      PLY_TEXTDEPTH=100
      PLY_PCT=100
      if arg_is_float ${2}; then
        PLY_TEXTDEPTH="${2}"
        shift
      fi
      while ! arg_is_flag ${2}; do
        PLY_TEXTSTRING=${PLY_TEXTSTRING}" ${2}"
        shift
      done
      ;;
      floattext)
        shift
        if [[ -z ${plyfloattextnum} ]]; then
          plyfloattextnum=1
        else
          plyfloattextnum=$(echo "${plyfloattextnum} + 1" | bc)
        fi
        plyfloatingtextflag=1
        PLY_FLOAT_TEXT_STRING[$plyfloattextnum]=""
        PLY_FLOAT_TEXT_DEPTH[$plyfloattextnum]=100
        PLY_FLOAT_TEXT_SCALE[$plyfloattextnum]=0.1

        if arg_is_float ${2}; then
          PLY_FLOAT_TEXT_LON[$plyfloattextnum]="${2}"
          shift
        fi
        if arg_is_float ${2}; then
          PLY_FLOAT_TEXT_LAT[$plyfloattextnum]="${2}"
          shift
        fi
        if arg_is_float ${2}; then
          PLY_FLOAT_TEXT_DEPTH[$plyfloattextnum]="${2}"
          shift
        fi
        if arg_is_float ${2}; then
          PLY_FLOAT_TEXT_SCALE[$plyfloattextnum]="${2}"
          shift
        fi

        while ! arg_is_flag ${2}; do
          if [[ $2 == "floattext" ]]; then
            break
          fi
          if [[ -z $PLY_FLOAT_TEXT_STRING[$plyfloattextnum] ]]; then
            PLY_FLOAT_TEXT_STRING[$plyfloattextnum]="$2"
          else
            PLY_FLOAT_TEXT_STRING[$plyfloattextnum]="${PLY_FLOAT_TEXT_STRING[$plyfloattextnum]} ${2}"
          fi
          shift
        done
        ;;
    box)
      shift
      plymakeboxflag=1
      if arg_is_float ${2}; then
        PLY_BOXDEPTH="${2}"
        plyboxdepthflag=1
        shift
      fi
      ;;
    landkm)
      shift
      if arg_is_positive_float "${2}"; then
        PLY_FIB_KM="${2}"
        shift
        makeplydemmeshflag=0
        makeplysurfptsflag=1
      else
        info_msg "[-makeply]: landkm option requires positive float argument"
        exit 1
      fi
      ;;
    ocean)
      shift
      plymakeoceanflag=1
      ;;
    mtl)
      shift
      PLY_MTLNAME="${2}"    # Name of material for DEM mesh OBJ
      PLY_TEXNAME="${PLY_MTLNAME}_texture.png"
      shift
      ;;
    demonly)
      plydemonlyflag=1
      shift
      ;;

    fault)
      shift
      numgridfault=1
      cpts+=("seisdepth")
      while ! arg_is_flag "${2}"; do
        if [[ -s "${2}" ]]; then
          gridfault[$numgridfault]=$(abs_path "${2}")
          makeplyfaultmeshflag=1
          ((numgridfault++))
        else
          echo "[-makeply]: Fault grid ${2} does not exist or is empty"
          exit 1
        fi
        shift
      done
      ;;
    addz)
      shift
      if arg_is_float "${2}"; then
        PLY_ZOFFSET=$(echo "${2}" | bc -l)  # Offset of mesh (+ out)
      else
        info_msg "[-makeply]: addz expects a float argument"
        exit 1
      fi
      shift
      ;;
    alpha)
      shift
      plymakealphaflag=1
      if arg_is_positive_float "${2}"; then
        PLY_ALPHACUT=${2}
        shift
      fi
      ;;
    vexag)
      shift
      if arg_is_positive_float "${2}"; then
        PLY_VEXAG="${2}"
        shift
      else
        info_msg "[-makeply]: vexag option requires positive float argument"
        exit 1
      fi
      ;;
    topoexag)
      shift
      if arg_is_positive_float "${2}"; then
        PLY_VEXAG_TOPO="${2}"
        shift
      else
        info_msg "[-makeply]: vexag topo option requires positive float argument"
        exit 1
      fi
      ;;
    maxsize)
      shift
      if arg_is_positive_float "${2}"; then
        PLY_MAXSIZE="${2}"
        plymaxsizeflag=1
        shift
      else
        info_msg "[-makeply]: maxsize option requires positive integer argument"
        exit 1
      fi
      ;;
    maptiff)
      plymaptiffflag=1
      shift
      ;;
    sidebox)
      shift
      plysideboxflag=1

      if arg_is_positive_float "${2}"; then
        PLY_SIDEBOXDEPTH="${2}"
        shift
      else
        info_msg "[-makeply]: sidebox option requires positive integer argument"
        exit 1
      fi
      if ! arg_is_flag "${2}"; then
        if [[ "${2}" =~ ([0-9]*\/[0-9]*\/[0-9]*) ]]; then
          PLY_SIDEBOXCOLOR=${2}
        else
          THISCOLOR=$(gmt_colorname_to_rgb "${2}")
          if [[ -z $THISCOLOR ]]; then
            info_msg "[-makeply]: Color ${2} not recognized. Using default ${PLY_SIDEBOXCOLOR}"
            PLY_SIDEBOXCOLOR="255/255/255"
          else
            PLY_SIDEBOXCOLOR=${THISCOLOR}
          fi
        fi
        shift
      fi
      ;;
    scale)
      shift
      if arg_is_positive_float "${2}"; then
        PLY_SCALE="${2}"
        shift
      else
        info_msg "[-makeply]: scale option requires positive number argument"
        exit 1
      fi
      ;;
    *)
      echo "[-makeply]: Option ${2} not recognized... ignoring"
      shift
      ;;
    esac
  done
  ;;

  -addply) #
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-addobj:       add existing PLY file to 3D model
Usage: -addply [file] [[file ...]]

  files are added to folder 3d/

--------------------------------------------------------------------------------
EOF
shift && continue
fi
  while [[ -s ${2} ]]; do
    ADDPLYFILE+=("$(abs_path ${2})")
    shift
    addplyflag=1
  done
  ;;


  -addobj) # -addobj: add existing OBJ file and material file to 3D model
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-addobj:       add existing OBJ file and material file to 3D model
Usage: -addobj [file.obj] [[file.mtl]] [[file.jpg/png/etc]]

  file.obj is added to 3d/
    - Materials library command should be "mtllib materials.mtl"
  file.jpg/png/etc is placed in 3d/Textures/
  file.mtl is concatenated to 3d/materials.mtl; values are ajusted to avoid
       having identical materials that cause meshes to be merged in Sketchfab

  Can be called multiple times

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if [[ -s ${2} ]]; then
      ADDOBJFILE+=("$(abs_path ${2})")
      shift
      addobjflag=1
    else
      echo "[-addobj]: OBJ file $2 does not exist or is empty"
      exit 1
    fi
    if [[ -s ${2} ]]; then
      ADDOBJMTL+=("$(abs_path ${2})")
      shift
      addmtlflag=1
    fi
    if [[ -s ${2} ]]; then
      ADDOBJTEX+=("$(abs_path ${2})")
      shift
      addtexflag=1
    fi
  ;;

  -tsl) # -tsl: add slope to terrain intensity
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tsl:          add slope to terrain intensity
Usage: -tsl [[fact=${SLOPE_FACT}]]

Example: Slope map of Madagascar, UTM
tectoplot -r -113 -112.3 36 36.5 -t 01s -tsl -o example_tsl
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    fasttopoflag=0
    if arg_is_float $2; then
      SLOPE_FACT=$2
      shift
    fi
    info_msg "[-tsl]: Combine factor=${SLOPE_FACT}"

    topoctrlstring=${topoctrlstring}"s"
    useowntopoctrlflag=1
    ;;

  -ttri) # -ttri: add terrain ruggedness index to terrain intensity
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ttri:         add terrain ruggedness index to terrain intensity
Usage: -ttri

Example: TRI of Nevada, USA, UTM
tectoplot -t -ttri -o example_ttri
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    fasttopoflag=0
    topoctrlstring=${topoctrlstring}"i"
    useowntopoctrlflag=1

    if arg_is_float $2; then
      TRI_FACT=$2
      shift
    fi

    ;;

  -tint) # -tint: derive terrain intensity directly from input grid dataset
  TINT_FACT=0.7
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tint:         derive terrain intensity directly from input grid dataset
Usage: -tint [grid] [[fact]]

  Renders grid data with grayscale CPT and uses the result as the terrain
  intensity. Input data will be resampled to match DEM.

--------------------------------------------------------------------------------
EOF
shift && continue
fi

  if [[ ! -s $2 ]]; then
    echo "[-tint]: input file $2 does not exist or is empty"
    exit 1
  fi

  TINTFILE=$(abs_path $2)
  shift
  topoctrlstring=${topoctrlstring}"a"

  if arg_is_positive_float $2; then
    TINT_FACT=$2
    shift
  fi


  ;;

  -timg) # -timg: color terrain intensity using one or more georeferenced images
  TIMG_RESAMPLE="near"
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-timg:         color terrain intensity one or more georeferenced images
Usage: -timg [[options]] [img filename1 [[fact1]]] [img filename2 [[fact2]]]  ...

  Blends georeferenced RGB images to form an overlay that is then
  multiply combined with terrain intensity.

  If more than one grid is specified, then subsequent grids will be
  resampled to the extent and resolution of the first grid, and will
  be overlay combined with the first grid before fusing with terrain.

  fact [0-1]     blending factor with terrain intensity image
                 0 or 1 is fully opaque; 0.9 is highly transparent

  Options:
  noterrain      override terrain blending; just use the fused images
  resample       resampling method when resizing grid
                 choose from: near (default), bilinear, cubic, cubicspline,
                              lanczos, average, rms, mode,  max, min, med, Q1,
                              Q3, sum

--------------------------------------------------------------------------------
EOF
shift && continue
fi

    fasttopoflag=0
    timgnotopoflag=0
    timg_index=1

    while ! arg_is_flag $2; do
      case $2 in
        noterrain)
          shift
          timgnotopoflag=1
          ;;
        resample)
          shift
          if ! arg_is_flag $2; then
            TIMG_RESAMPLE=$2
            shift
          else
            echo "[-timg]: resample option requires argument"
            exit 1
          fi
        ;;
        img)
          shift
          if [[ -s "${2}" ]]; then
            TIMG_IMAGES[$timg_index]=$(abs_path "${2}")
            shift
          else
            TIMG_IMAGES[$timg_index]="${2}"
            shift
          fi

          if arg_is_positive_float $2; then
            TIMG_FACTS[$timg_index]="${2}"
            shift
          else
            TIMG_FACTS[$timg_index]=0.01  # Default value is fully opaque
          fi
          ((timg_index++))
          ;;
        *)
          echo "[-timg]: option $2 not recognized"
          exit 1
          ;;
      esac
    done
    ((timg_index--))

    # if [[ -s ${2} ]]; then
    #       # if [[ ! -s ${2} && "${2}" != "sentinel_img.jpg" && ]]; then
    #       #   echo "[-timg]: File $2 not found or is empty"
    #       #   exit 1
    #       # else
    #   P_IMAGE=$(abs_path ${2})
    #   shift
    # else
    #   P_IMAGE="${2}"
    #   shift
    # fi

    # Specific to sentinel imagery,
    if [[ $timgnotopoflag -eq 1 ]]; then
      topoctrlstring="p"
    else
      topoctrlstring=${topoctrlstring}"p"
    fi
    useowntopoctrlflag=1
    ;;

  -tclip) # -tclip: cut DEM to specified lon/lat aoi
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tclip:        cut DEM to specified lon/lat aoi
Usage: -tclip [MinLon] [MaxLon] [MinLat] [MaxLat]

  Only the clipped DEM region will be extracted by -t, etc.

Example:
tectoplot -t -tclip 156 158 -9 -7 -t0 -o example_tclip
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    if arg_is_float $2; then
      DEM_MINLON="${2}"
      DEM_MAXLON="${3}"
      DEM_MINLAT="${4}"
      DEM_MAXLAT="${5}"
      shift # past argument
      shift # past value
      shift # past value
      shift # past value
    elif [[ -e ${2} ]]; then
      CLIP_XY_FILE=$(abs_path ${2})
      # Assume that this is an XY file whose extents we want to use for DEM clipping
      CLIPRANGE=($(xy_range ${CLIP_XY_FILE}))
      shift
      # Only adopt the new range if the max/min values are numbers and their order is OK
      usecliprange=1
      [[ ${CLIPRANGE[0]} =~ ^[-+]?[0-9]*.*[0-9]+$ ]] || usecliprange=0
      [[ ${CLIPRANGE[1]} =~ ^[-+]?[0-9]*.*[0-9]+$ ]] || usecliprange=0
      [[ ${CLIPRANGE[2]} =~ ^[-+]?[0-9]*.*[0-9]+$ ]] || usecliprange=0
      [[ ${CLIPRANGE[3]} =~ ^[-+]?[0-9]*.*[0-9]+$ ]] || usecliprange=0
      [[ $(echo "${CLIPRANGE[0]} < ${CLIPRANGE[1]}" | bc -l) -eq 1 ]] || usecliprange=0
      [[ $(echo "${CLIPRANGE[2]} < ${CLIPRANGE[3]}" | bc -l) -eq 1 ]] || usecliprange=0

      if [[ $usecliprange -eq 1 ]]; then
        info_msg "Clip range taken from XY file: ${CLIPRANGE[0]}/${CLIPRANGE[1]}/${CLIPRANGE[2]}/${CLIPRANGE[3]}"
        DEM_MINLON=${CLIPRANGE[0]}
        DEM_MAXLON=${CLIPRANGE[1]}
        DEM_MINLAT=${CLIPRANGE[2]}
        DEM_MAXLAT=${CLIPRANGE[3]}
      else
        info_msg "Could not assign DEM clip using XY file."
      fi
    fi

    demisclippedflag=1
    # topoctrlstring="w"${topoctrlstring}   # Clip before other actions
    ;;

  -tposwhite) # -tposwhite: set color of areas above sea level to white in DEM stretch
TPOSWHITEVAL=255
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tposwhite:  set color of areas above sea level to white in DEM stretch
Usage: -tposwhite

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    tposwhiteflag=1

    if arg_is_positive_float $2; then
      TPOSWHITEVAL=$2
      shift
    fi
    ;;

  -tnegwhite) # -tposwhite: set color of areas above sea level to white in DEM stretch
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tnegwhite:  set color of areas below sea level to white in DEM stretch
Usage: -tnegwhite

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    tnegwhiteflag=1
    ;;

  -tunsetflat) # -tunsetflat: set regions with elevation = 0 to white in terrain intensity
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tunsetflat:   set regions with elevation = 0 to white in terrain intensity
Usage: -tunsetflat

Example: Topo shadows on a flat sea surface
tectoplot -t -tflat -tmult -tsl -tunsetflat -tshad 65 1 -o example_tunsetflat
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    fasttopoflag=0
    topoctrlstring=${topoctrlstring}"u"
    ;;

  -tquant) # -tquant: terrain intensity from height above local quantile elevation
  DEM_QUANTILE_RADIUS=1k
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tquant:       terrain intensity from height above local quantile elevation
Usage: -tquant [[quantile=${DEM_QUANTILE}]] [[radius=${DEM_QUANTILE_RADIUS}]] [[fact=${QUANTILE_FACT}]]

  This option will help shade areas lower than surrounding relief while
  lightening areas higher than surrounding relief. It is particularly useful
  for blending with other terrain visualizations as a subtle effect.

Example:
tectoplot -t -tquant 0.1 1k -tsl 0.5 -tpct 1 99 -o example_tquant
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    fasttopoflag=0
    topoctrlstring=${topoctrlstring}"q"
    useowntopoctrlflag=1

    if arg_is_positive_float "${2}"; then
      DEM_QUANTILE="${2}"
      shift
    fi
    if ! arg_is_flag $2; then
      DEM_QUANTILE_RADIUS="${2}"
      shift
    fi
    if arg_is_positive_float "${2}"; then
      QUANTILE_FACT="${2}"
      shift
    fi
    ;;

  -tsmooth) # -tsmooth: smooth input DEM before processing
  DEM_SMOOTH_RAD=1
    if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tsmooth:       smooth input DEM before processing
Usage: -tquant [[radius=${DEM_SMOOTH_RAD}]]

  Gaussian smoothing, radius is in km, no units given

Example:
tectoplot -t -tsmooth 5m -o example_tsmooth
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    if ! arg_is_flag "${2}"; then
      DEM_SMOOTH_RAD="${2}"
      shift
    fi
    DEM_SMOOTH_FLAG=1
    ;;

  -tca) # -tca: set alpha value for DEM color stretch
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tca:          set alpha value for DEM color stretch
Usage: -tca [[alpha=${DEM_ALPHA}]]

  alpha is accomplished by blending with white before multiply overlay

  alpha=1 -> fully transparent
  alpha=0 -> fully opaque

Example:
tectoplot -t -tca 0.2 -o example_tca
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  if arg_is_positive_float "${2}"; then
    DEM_ALPHA="${2}"
    shift
  fi
  ;;

  -tgam) # -tgam: apply gamma correction to terrain intensity image
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tgam:         apply gamma correction to terrain intensity image
Usage: -tgam [[gamma=${HS_GAMMA}]]

  Gamma correction adjusts the contrast of an image.
  Gamma > 1 : darken
  Gamma < 1 : lighten

Example:
tectoplot -t -ttext -tgam 0.5 -o example_tgam
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    fasttopoflag=0
    if arg_is_positive_float $2; then
      HS_GAMMA=$2
      shift
    else
      info_msg "[-tgam]: Positive number expected. Using ${HS_GAMMA}."
    fi
    topoctrlstring=${topoctrlstring}"g"
    useowntopoctrlflag=1
    ;;

	-v) # -v: plot global gravity data
  GMIN=-500
  GMAX=500
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-v:            plot global gravity data and related data
Usage: -v [[model=${GRAVMODEL}]] [[trans=${GRAVTRANS}]] [[rescale [[min max]] ]]
  [[nograd]]   do not use gradient for intensity
  model:
    BG = WGM2012 Bouguer
    FA = WGM2012 Free Air
    IS = WGM2012 Isostatic
    SW = Sandwell 2019 Free Air

  rescale  :  adjusts the range of the CPT to match range of data in the AOI or
              to between specified values.

Example:
tectoplot -v BG 0 rescale -a -o example_v
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    GRAVCPT=$WGMFREEAIR_CPT
    GRAVGRAD="-I+d"

    while ! arg_is_flag $2; do

      if [[ $2 == "BG" || $2 == "FA" || $2 == "IS" || $2 == "SW " ]]; then
  		  GRAVMODEL="${2}"
        shift
      elif arg_is_positive_float $2; then
  	    GRAVTRANS="${2}"
        shift
      elif [[ ${2} =~ "rescale" ]]; then
        rescalegravflag=1
  			info_msg "[-v]: Rescaling gravity CPT to AOI"
  			shift
        if arg_is_float $2; then
          rescalegravspecifiedflag=1
          GMIN=${2}
          shift
        fi
        if arg_is_float $2; then
          rescalegravspecifiedflag=1
          GMAX=${2}
          shift
        fi
      elif [[ $2 == "nograd" ]]; then
        GRAVGRAD=""
        shift
      fi
    done

		case $GRAVMODEL in
			FA)
				GRAVDATA=$WGMFREEAIR
				# GRAVCPT=$WGMFREEAIR_CPT
				GRAVCPT=turbo
        echo $GRAV_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        echo $GRAV_SOURCESTRING >> ${LONGSOURCES}
				;;
			BG)
				GRAVDATA=$WGMBOUGUER
				# GRAVCPT=$WGMBOUGUER_CPT
        GRAVCPT=turbo
        echo $GRAV_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        echo $GRAV_SOURCESTRING >> ${LONGSOURCES}
				;;
			IS)
				GRAVDATA=$WGMISOSTATIC
				GRAVCPT=$WGMISOSTATIC_CPT
        echo $GRAV_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        echo $GRAV_SOURCESTRING >> ${LONGSOURCES}
				;;
      SW)
        GRAVDATA=$SANDWELLFREEAIR
        GRAVCPT=$WGMFREEAIR_CPT
        echo $SANDWELL_SOURCESTRING >> ${LONGSOURCES}
        echo $SANDWELL_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        ;;
			*)
				echo "Gravity model not recognized."
				exit 1
				;;
		esac
		info_msg "[-v]: Gravity data to plot is ${GRAVDATA}, transparency is ${GRAVTRANS}"
		plots+=("grav")
    cpts+=("grav")
    clipgravflag=1

	  ;;

#   -rotate)
#   ROTATE_ANGLE=-90
# if [[ $USAGEFLAG -eq 1 ]]; then
# cat <<-EOF
# -rotate:         rotate the map by the given angle
# Usage: -rotate [[rotangle=${ROTATE_ANGLE}]]
#
# --------------------------------------------------------------------------------
# EOF
# shift && continue
# fi
#   rotatemapflag=1
#   if arg_is_float $2; then
#     ROTATE_ANGLE=$2
#     shift
#   fi
#   ;;

  -vcurv) # -vcurv: plot curvature of sandwell 2019 global gravity data
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-vcurv:        plot curvature of sandwell 2019 global gravity data
Usage: -vcurv

Example: Gravity curvature of spreading ridge SE of Madagascar
tectoplot -vcurv -o example_vcurv
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  GRAV_CURV_DATA=${SANDWELLFREEAIR_CURV}

  plots+=("gravcurv")
  cpts+=("gravcurv")

  ;;

  -vars) # -vars: define variables from a bash format file by sourcing it
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-vars:         define variables from a bash format file by sourcing it
-vars [filename]

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    VARFILE=$(abs_path $2)
    shift
    info_msg "[-vars]: Sourcing variable assignments from $VARFILE"
    source $VARFILE
    cp ${VARFILE} ${TMP}input_vars.txt
    ;;

  -verbose) # -verbose: turn on gmt verbose option to get LOTS of feedback
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-verbose:      turn on gmt verbose option to get LOTS of feedback
Usage: -verbose

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    ;;

  -w) # -w: plot velocity field from a specified euler pole on grid points
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-w:            plot velocity field from a specified euler pole on grid points
Usage: -w [pole_lat] [pole_lon] [omega] [[pole_lat_2]] [[pole_lon_2]] [[pole_omega_2]]

  Requires -px, -pf, or -pi option to generate grid points

  If two Euler poles are specified, add them and use the resulting Euler pole

Example: Global Euler pole velocity field on a Fibonacci grid
tectoplot -RJ Kf -a -pf 1000 -w 10 20 0.2 -i 2 -o example_w
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    # Check the number of arguments
    if [[ $(number_nonflag_args "${@}") -eq 3 ]]; then
      eulerlat="${2}"
      eulerlon="${3}"
      euleromega="${4}"
      shift
      shift
      shift
      eulervecflag=1

    elif [[ $(number_nonflag_args "${@}") -eq 6 ]]; then

      EULER_SUM=($(echo $2 $3 $4 $5 $6 $7 | gawk -f $EULERADD_AWK))

      eulerlat="${EULER_SUM[0]}"
      eulerlon="${EULER_SUM[1]}"
      euleromega="${EULER_SUM[2]}"
      echo "[-w]: Using Euler sum of poles [$2, $3, $4] and [$5, $6, $7] is [${EULER_SUM[0]}, ${EULER_SUM[1]}, ${EULER_SUM[2]}]"
      shift
      shift
      shift
      shift
      shift
      shift
      eulervecflag=1
    fi

    plots+=("euler")
    ;;

  -wg) # -wg: plot euler pole velocity field at gps sites instead of grid
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-wg:           plot euler pole velocity field at gps sites instead of grid
Usage: -wg [[residual scaling=${WRESSCALE}]]

  Requires -g option to set GPS site locations
  If residual scaling is indicated, plot difference between GPS+Euler velocity

Example: Turkey, random Euler pole velocity field vs GPS relative to Europe
tectoplot -r TR+R2 -RJ B -rect -a -g eu color black -w 36 32 1 -wg -i 2 -o example_wg
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    euleratgpsflag=1
    if arg_is_flag $2; then
			info_msg "[-wg]: No residual scaling specified... not plotting residuals"
		else
      ploteulerobsresflag=1
			WRESSCALE="${2}"
			info_msg "[-wg]: Plotting only residuals with scaling factor $WRESSCALE"
			shift
		fi
    ;;

  -wp) # args: string string
  # -wp is currently broken:
  # cp: gridswap.txt: No such file or directory

if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-wp:           plot euler pole velocity of one plate relative to another at grid/gps sites
Usage: -wp [PlateID1] [PlateID2]

  Requires -p option to load plate data and -x/-g options to set site locations

Example: GPS velocity of Arabia relative to Europe, with MORVEL Euler poles
tectoplot -r SA -a -g eu -w 36 32 1 -wp ar eu -i 2 -o example_wp
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
#     twoeulerflag=1
#     plotplates=1
#     eulerplate1="${2}"
#     eulerplate2="${3}"
#     plots+=("euler")
#     shift
  ;;

  -ztext) # -ztext: plot magnitude text over earthquakes
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ztext:            plot magnitude or year text over earthquakes
Usage: -ztext [[minmag=${ZTEXT_MINMAG}]]] "year"


Example:
tectoplot -z -ztext 7
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  if arg_is_float "${2}"; then
    ZTEXT_MINMAG="${2}"
    shift
  fi

  if [[ $2 == "year" ]]; then
    ztextyearflag=1
    shift
  fi

  plots+=("ztext")
  ;;

  -ztarget)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ztarget:            plot concentric circles around earthquake
Usage: -ztarget [id]

Example:
tectoplot -z -ztarget usp000f83m -o example_ztarget
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  if ! arg_is_flag $2; then
    ztarget_id=$2
    shift
  else
    echo "[-ztarget]: id argument required"
    exit 1
  fi

  plots+=("ztarget")

  ;;

  -zhigh)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zhigh:           highlight a specific earthquake by re-plotting
Usage: -zhigh [id1] [[id 2]] ...
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  while ! arg_is_flag $2; do
    zhigh+=("$2")
    shift
  done
  zhighlightflag=1
  ;;

  -zbox) # Plot a large text box containing earthquake information
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zbox:            plot information box about specified earthquake
Usage: -zbox [id]

Example:
tectoplot -z -zbox usp000f83m -o example_zbox
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  if ! arg_is_flag $2; then
    zbox_id=$2
    shift
  else
    echo "[-zbox]: id argument required"
    exit 1
  fi

  plots+=("zbox")

  ;;

  -zproj)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zproj:      test module for seismicity streaking
Usage: -zhigh [id] -zproj [radius]

Requires use of -zhigh to select an earthquake
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  if arg_is_positive_float $2; then
    zproj_radius=$2
    shift
  else
    echo "[-zproj]: requires a distance argument (positive float)"
    exit 1
  fi
  plots+=("zproj")
  ;;

  -zcull)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zcull:           remove an event based on ID
Usage: -zcull [id]
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  zcullflag=1
  zcullid=$2
  shift
  ;;

  -cullparams)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-cullparams:          set the parameters used to cull CMT and earthquake catalogs
Usage: -cullparams [param] [value] [[...]]
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  while ! arg_is_flag $2; do
    case $2 in
      lat) shift; zccull_lat=$2; shift;;
      lon) shift; zccull_lon=$2; shift ;;
      dep) shift; zccull_depth=$2; shift ;;
      mag) shift; zccull_mag=$2; shift ;;
      sec) shift; zccull_sec=$2; shift ;;
      *) echo "[-cullparams]: parameter not recognized ${2}"; exit 1 ;;
    esac
  done

  ;;

  -epoch)
  iso8601_to_epoch $2
  exit 1
  ;;

  -addsources)
  while ! arg_is_flag $2; do
    echo $2 >> $SHORTSOURCES
    shift
  done
  ;;

  -znonquake)
  notearthquakeflag=1
  ;;

# Convert GPS velocities using an Euler rotation
  -gpscor)
  gpscorflag=1
  gpscorlat=$2
  shift
  gpscorlon=$2
  shift
  gpscorw=$2
  shift
  ;;

  -credit)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-credit:          Add credit and date information to map legend
Usage: -credit [string]
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    makecreditline=1
    if ! arg_is_flag $2; then
      CREDITLINE="${2}"
      shift
    fi
    while ! arg_is_flag $2; do
      CREDITLINE="${CREDITLINE} $2"
      shift
    done
    CREDITLINE="${CREDITLINE} ($(date +"%Y-%m-%d"))"

  ;;

  -getdate)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-getdate:         print iso8601 time for given epoch (seconds since 1970-01-01T00:00:00)
Usage: -getdate [date1] [[...]]

Example:
tectoplot -getdate 315532800
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  while ! arg_is_flag $2; do
    epoch_to_iso8601 $2
    shift
  done
  exit 0
  ;;

  -getepoch)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-getepoch:         print epoch time (seconds since 1970-01-01T00:00:00)
Usage: -getepoch [date1] [[...]]

Example:
tectoplot -getepoch 1970-01-01T00:00:00
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  while ! arg_is_flag $2; do
    if [[ $2 == "now" ]]; then
      thisdate=$(date -u +"%FT%T")
      iso8601_to_epoch $thisdate
    else
      iso8601_to_epoch $2
    fi
    shift
  done
  exit 0
  ;;

	-z) # -z: plot seismicity
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-z:            plot seismicity
Usage: -z [[scale=${SEISSCALE}]] [[trans=${SEISTRANS}]]

Example:
tectoplot -z -o example_z
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
		plotseis=1
		if arg_is_flag $2; then
			info_msg "[-z]: No scaling for seismicity specified... using default $SEISSIZE"
		else
			SEISSCALE="${2}"
			info_msg "[-z]: Seismicity scale updated to $SEIZSIZE * $SEISSCALE"
			shift
		fi
    if arg_is_positive_float $2; then
      info_msg "[-z]: Setting transparency to ${2}"
      SEISTRANS="${2}"
      shift
    fi
		plots+=("seis")
    cpts+=("seisdepth")

    # If we haven't called -zadd -replace, set flag to add EQ sourcestring
    [[ $ADD_EQ_SOURCESTRING -ne 2 ]] && ADD_EQ_SOURCESTRING=1

    ;;

  -zmodifymags) # -zmodifymags: convert magnitudes to GCMT Mw equivalent when possible
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zmodifymags:    Convert magnitudes to GCMT Mw equivalent when possible
Usage: -zmodifymags

Example:
tectoplot -z -zmodifymags -o example_zcnoscale
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  modifymagnitudes=1
  ;;

  -zcnoscale) # -zcnoscale: do not adjust scaling of earthquake/focal mechanism symbols
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zcnoscale:    do not adjust scaling of earthquake/focal mechanism symbols
Usage: -zcnoscale [[size=${NOSCALE_SEISSIZE}]]

Example:
tectoplot -z -zcnoscale -o example_zcnoscale
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if arg_is_flag $2; then
      info_msg "[-zcnoscale]:  No earthquake scale given. Using ${NOSCALE_SEISSIZE}."
    else
      NOSCALE_SEISSIZE="${2}"
      shift
    fi
    # SCALEEQS=0
    zcnoscaleflag=1
    ;;

  -zcfixsize) # -zcfixsize: earthquake/focal mechanisms have only one specified size
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zcfixsize:    earthquake/focal mechanisms have only one specified size
Usage: -zcfixsize [[size=${SEISSCALE}]]

  Size has unit, e.g. 0.01i

Example:
tectoplot -z -zcfixsize 0.01i -o example_zcfixsize
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

      if arg_is_flag $2; then
        info_msg "[-zcfixsize]:  No earthquake symbol size given. Using ${SEISSCALE}."
      else
        SEISSCALE="${2}"
        shift
      fi
      SCALEEQS=0
      zcnoscaleflag=1
      ;;

  -zcrescale) # -zcrescale: adjust size of seismicity/focal mechanisms by a multiplied factor
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zcrescale:    adjust size of seismicity/focal mechanisms by a multiplied factor
Usage: -zcrescale [scale=${SEISSCALE}] [[seisstretch=${SEISSTRETCH}]] [[refmag=${SEISSTRETCH_REFMAG}]]

  Modify magnitude of earthquake/focal mechanisms to allow non-linear rescaling
  of plotted earthquake hypocenters.

  Mw_new = (Mw^seisstretch)/(refmag^(seisstretch-1))

Example:
tectoplot -z -zcrescale 2 5 8 -o example_zcrescale
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if ! arg_is_flag $2; then
      SEISSCALE="${2}"
      info_msg "[-zcrescale]: Multiplying default seismicity size by ${SEISSCALE}"
      shift
    else
      info_msg "[-zcrescale]: Requires size scale factor (e.g. 2)"
    fi
    if arg_is_positive_float $2; then
      SEISSTRETCH="${2}"
      info_msg "[-zcrescale]: Using stretch factor ${SEISSTRETCH}."
      shift
    else
      info_msg "[-zcrescale]: Requires two positive float arguments"
    fi
    if arg_is_positive_float $2; then
      SEISSTRETCH_REFMAG="${2}"
      info_msg "[-zcrescale]: Using reference magnitude ${SEISSTRETCH_REFMAG}."
      shift
    else
      info_msg "[-zcrescale]: Requires two positive float arguments"
    fi
  ;;

  -seistimeline_eq)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-seistimeline_eq:  use earthquake ID to set start time for seistimeline_c
Usage: -seistimeline_eq [ID] [[years_before]]
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  SEISTIMELINE_TIME_BEFORE_BUFFER=0
  if ! arg_is_flag $2; then
    SEISTIMELINE_C_START_EQID=$2
    shift
  else
    echo "[-seistimeline_c]: Start date is required"
    exit 1
  fi
  if arg_is_positive_float $2; then
    SEISTIMELINE_TIME_BEFORE_BUFFER=$2
    shift
  fi
  ;;

  -seistimeline_c) # -seistimeline_c: create a seismicity vs time plot to the right of the map
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-seistimeline_c:  create a seismicity vs time plot to the right of the map
Usage: -seistimeline_c [startdate] [[breakdate1 panelwidth1]] ...

  This option creates a -seistimeline plot with any number of panels, each of
  which has a specified width and break date. The start date must be specified.

  Dates are specified in ISO8601 YYYY-MM-DDThh:mm:ss format (1900-01-0T00:00:00)
  width is given in inches, without unit (e.g. 5)

Example:
tectoplot -a -z -c -zline 0 -seistimeline_c 1970-01-01 2010-01-01 4 \
          2022-01-01 2 -o example_seistimeline_c
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

seistime_c_num=0

if ! arg_is_flag $2; then
  SEISTIMELINE_C_START_TIME=$2
  shift
else
  echo "[-seistimeline_c]: Start date is required"
  exit 1
fi

while ! arg_is_flag $2; do
  ((seistime_c_num++))

  if [[ $2 == "today" ]]; then
    SEISTIMELINE_C_BREAK_TIME[$seistime_c_num]=$(date_shift_utc)
  else
    SEISTIMELINE_C_BREAK_TIME[$seistime_c_num]=$2
  fi

  shift
  if arg_is_flag $2; then
    echo "[-seistimeline_c]: Must specify break time and panel width."
    exit 1
  else
    if arg_is_positive_float $2; then
      SEISTIMELINE_C_WIDTH[$seistime_c_num]=$2
      shift
    else
      echo "[-seistimeline_c]: Panel width must be a positive float"
      exit 1
    fi
  fi
done

# for i in $(seq 1 $seistime_c_num); do
#   echo "SC: ${SEISTIMELINE_C_BREAK_TIME[$i]} / ${SEISTIMELINE_C_WIDTH[$i]}"
# done

plotseistimeline_c=1
  ;;

  -seistimeline) # -seistimeline: create a seismicity vs time plot to the right of the map
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-seistimeline:  create a seismicity vs time plot to the right of the map
Usage: -seistimeline [[startdate]] [[breakdate]] [[enddate]] [[panelwidth]]

  Dates are specified in ISO8601 YYYY-MM-DDThh:mm:ss format (1900-01-0T00:00:00)
  width is given in inches, without unit (e.g. 5)
  Note: Use the -noframe right option to avoid overlapping with map labels

; use seistimeline_c
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  SEISTIMELINE_START_TIME="1900-01-01T00:00:00"
  SEISTIMELINE_BREAK_TIME="2010-01-01T00:00:00"
  SEISTIMELINE_END_TIME=$(date_shift_utc)
  SEISTIMELINEWIDTH=5 # inches

  if ! arg_is_flag $2; then
    SEISTIMELINE_START_TIME=$2
    shift
  fi
  if ! arg_is_flag $2; then
    SEISTIMELINE_BREAK_TIME=$2
    shift
  fi
  if ! arg_is_flag $2; then
    SEISTIMELINE_END_TIME=$2
    shift
  fi
  if ! arg_is_flag $2; then
    SEISTIMELINEWIDTH=$2
    shift
  fi
  plotseistimeline=1
  ;;

  -seisproj) # -seisproj: create a seismicity (X) vs depth (Y) projected panel below or to right of map
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-seisproj:     create a seismicity (X) vs depth (Y) projected panel below or to right of map
Usage: -seisproj [dim1=${SEISPROJ_DIM1} size1=${SEISPROJHEIGHT_DIM1}] [[dim2 size2]]

  Use -noframe bottom, -noframe right, or -noframe bottom right to avoid overlapping labels

  dim1 and dim2 can be X or Y

  SEISPROJ_DIMS="X"           # Can be X, Y, or XY
  SEISPROJHEIGHT_X=3          # Height in inches of -seisproj panel (X dimension)
  SEISPROJWIDTH_Y=3           # Width in inches of -seisproj panel (Y dimension)

Example:
tectoplot -t -t0 -z -zline 0 -seisproj X 3 Y 3 -noframe bottom right -o example_seisproj
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  while ! arg_is_flag "${2}"; do
    if [[ $2 == "X" ]]; then
      plotseisprojflag_x=1
      shift
      if arg_is_positive_float "${2}"; then
        SEISPROJHEIGHT_X="${2}"
        shift
      fi
    fi
    if [[ $2 == "Y" ]]; then
      plotseisprojflag_y=1
      shift
      if arg_is_positive_float "${2}"; then
        SEISPROJWIDTH_Y="${2}"
        shift
      fi
    fi
  done

  plotseisprojflag=1
  ;;

  -zccluster) # -zccluster: decluster seismicity and color by cluster ID rather than depth
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zccluster:    decluster seismicity and color by cluster ID rather than depth
Usage: -zccluster [[options]] [[method=${DECLUSTER_METHOD}]] [[minsize=${DECLUSTER_MINSIZE}]]

  Seismic catalog declustering separates independent events from those that can
  be labelled as aftershocks or foreshocks (dependent events). This option
  implements window-based declustering methods:

  Options:
  remove             remove non-mainshock events from the seismicity catalog.
  lines              plot colored lines connecting mainshocks to dependent events
  nocolor            do not change color scheme to color by cluster ID


  Methods:
  gk = Gardner and Knopoff, 1974
  urhammer = Urhammer, 1976
  gruenthal = Gruenthal, personal communication, to somebody at some point (?)
  rb = Reasenberg using cluster2000x FORTRAN code, slightly modified
               (only clusters the last 100 years of the input catalog)

  minsize = clusters with fewer than this number of events have all events
            assigned to independent class - highlight EQs with large # of events

Example:
tectoplot -z -zccluster rb -seistime onmap -o example_zccluster
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  while [[ $2 == "remove" || $2 == "lines" || $2 == "nocolor" ]]; do
    case $2 in
      remove)
        DECLUSTER_REMOVE=1
        shift
      ;;
      lines)
        zcclusterplotlinesflag=1
        shift
      ;;
      nocolor)
        zcclusternocolorflag=1
        shift
      ;;
    esac
  done

  if [[ $2 =~ "urhammer" || $2 =~ "gk" || $2 =~ "gruenthal" || $2 =~ "rb" || $2 == "zp" ]]; then
    DECLUSTER_METHOD="${2}"
    shift
  fi
  if arg_is_positive_float $2; then
    DECLUSTER_MINSIZE="${2}"
    shift
  fi

  seisdeclusterflag=1

  if [[ $zcclusternocolorflag -ne 1 ]]; then
    zcclusterflag=1

    # Replace one occurrence of seisdepth with eqtime in cpts list
    for thiscpt_num in ${#cpts[@]}; do
      ((thiscpt_num--))
      if [[ ${cpts[$thiscpt_num]} =~ "seisdepth" ]]; then
        replaceseiscptflag=1
        cpts[$thiscpt_num]="eqcluster"
        break
      fi
    done

    [[ $replaceseiscptflag -eq 0 ]] && cpts+=("eqcluster")

  fi

  plots+=("eqcluster")
  ;;

  -zconland) # -zconland: select FMS/seismicity with origin epicenter beneath land
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zconland:     select FMS/seismicity with origin epicenter beneath land
Usage: -zconland

  Currently broken.

--------------------------------------------------------------------------------
EOF
  shift && continue
  fi

  zconlandflag=1
  zc_land_or_sea=1
  ;;

  -zconsea) # -zconsea: select FMS/seismicity with origin epicenter beneath the sea
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zconsea:      select FMS/seismicity with origin epicenter beneath the sea
-zconsea

  Currently broken

--------------------------------------------------------------------------------
EOF
shift && continue
fi

  zconlandflag=1
  zc_land_or_sea=0

  ;;

  -zctime) # -zctime: color seismicity by time rather than depth
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zctime:       color seismicity by time rather than depth
Usage: -zctime [start_time] [[end_time=$(date_shift_utc)]]
       -zctime break [break_time] [[colorbefore]] [[colorafter]]

  The default start time is epoch 0 (1970-01-01T00:00:00)
  The default end time is the current UTC time when tectoplot runs.

Example:
tectoplot -a -z -zmag 6 -zctime 1990 2010 -o example_zctime
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    # Set default epochs for visualizing seismicity by time; override by command line args in iso8601
    COLOR_TIME_START_TEXT="1970-01-01T00:00:00"
    COLOR_TIME_END_TEXT=$(date_shift_utc)

    if [[ $2 == "break" ]]; then
      shift
      zccolorbefore="black"
      zccolorafter="red"
      if ! arg_is_flag $2; then
        zccolorbreakflag=1
        COLOR_TIME_BREAK_TEXT_ORIG="${2}"
        COLOR_TIME_BREAK_TEXT=$(echo "${2}" | iso8601_from_partial)
        shift
      fi
      if ! arg_is_flag $2; then
        zccolorbefore=$2
        shift
      fi
      if ! arg_is_flag $2; then
        zccolorafter=$2
        shift
      fi
    else
      if ! arg_is_flag $2; then
        COLOR_TIME_START_TEXT=$(echo "${2}" | iso8601_from_partial)
        shift
      fi
      if ! arg_is_flag $2; then
        COLOR_TIME_END_TEXT=$(echo "${2}" | iso8601_from_partial)
        shift
      fi
    fi

    info_msg "[-zctime]: Text start and end times are: $COLOR_TIME_START_TEXT $COLOR_TIME_END_TEXT"

    zctimeflag=1
    replaceseiscptflag=0

    # Replace one occurrance of seisdepth with eqtime in cpts list
    for thiscpt_num in ${#cpts[@]}; do
      ((thiscpt_num--))
      if [[ $thiscpt_num -ge 0 && ${cpts[$thiscpt_num]} =~ "seisdepth" ]]; then
        replaceseiscptflag=1
        cpts[$thiscpt_num]="eqtime"
        break
      fi
    done

    [[ $replaceseiscptflag -eq 0 ]] && cpts+=("eqtime")
    plots+=("eqtime")

  ;;

  -cdep) # -zdep: filter seismicity by depth
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-cdep:         filter focal mechanisms by depth
Usage: -cdep [min_depth] [max_depth]

  Both depths are in km without k unit.

Example:
tectoplot -a -c -cdep 50 100 -o example_cdep
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    if [[ ! $(number_nonflag_args "${@}") -eq 2 ]]; then
      echo "[-cdep]: Two arguments required. tectoplot usage -cdep"
      exit
    fi
    EQCUTMINDEPTH=${2}
    shift
    EQCUTMAXDEPTH=${2}
    shift
    info_msg "[-zdep]: Plotting seismic data between ${EQCUTMINDEPTH} km and ${EQCUTMAXDEPTH} km"
  ;;


  -zdep) # -zdep: filter seismicity by depth
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zdep:         filter seismicity by depth
Usage: -zdep [min_depth] [max_depth]

  Both depths are in km without k unit.

Example:
tectoplot -a -z -zdep 50 100 -o example_zdep
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    if arg_is_float $2; then
      EQCUTMINDEPTH=${2}
      shift
    fi
    if arg_is_float $2; then
      EQCUTMAXDEPTH=${2}
      shift
    fi
    info_msg "[-zdep]: Plotting seismic data between ${EQCUTMINDEPTH} km and ${EQCUTMAXDEPTH} km"
  ;;

  -zfill) # -zfill: color seismicity with a constant fill color
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zfill:        color seismicity with a constant fill color
Usage: -zfill [color]

  Color is a GMT color word or R/G/B triplet in the form 255/255/255

Example:
tectoplot -a -z -zmag 7 -zfill red -o example_zfill
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    seisfillcolorflag=1
    if arg_is_flag $2; then
      info_msg "[-zfill]:  No color specified. Using black."
      ZSFILLCOLOR="black"
    else
      ZSFILLCOLOR="${2}"
      shift
    fi
    ;;

  -ccat) # -ccat: select focal mechanism catalog(s)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ccat:         select focal mechanism catalog(s) and add custom focal mechanism files
Usage: -ccat [catalogID1] [[catalogfile1 code1 ]] ...  [[nocull]]

  catalogID: GCMT | ISC | GFZ | usgs
  catalogfile: Any file in a format importable by cmt_tools.sh

  usgs catalog requires use of -usgs command

  format codes:

  Note: Only m has been updated to take cluster_id and iso8601 time as output
        by tectoplot in cmt.dat etc.

  Code   GMT or other format info
  ----   -----------------------------------------------------------------------
    a/A   psmeca Aki and Richards format (mag= 28. MW)
          X Y depth strike dip rake mag [newX newY] [event_title] [newdepth] ...
          [epoch]
    c/C   psmeca GCMT format
          X Y depth strike1 dip1 rake1 aux_strike dip2 rake2 moment ...
          [newX newY] [event_title] [newdepth] [epoch]
   /x    psmeca principal axes (Not implemented yet)
   /       X Y depth T_value T_azim T_plunge N_value N_azim N_plunge P_value ...
   /       P_azim P_plunge exp [newX newY] [event_title] [newdepth] [epoch]
    m/M   psmeca moment tensor format
          X Y depth mrr mtt mff mrt mrf mtf exp [newX newY] [event_title] ...
          [newdepth] [epoch] [cluster_id] [iso8601_time]

    a,c,/x,m import as ORIGIN locations; use A,C,/X,M to import as CENTROID

    I    ISC, CSV format without header/footer lines (e.g. from ISC website)
         EVENT_ID,AUTHOR, DATE, TIME, LAT, LON, DEPTH, CENTROID, AUTHOR, EX, ...
         MO, MW, EX,MRR, MTT, MPP, MRT, MTP, MPR, STRIKE1, DIP1, RAKE1, ...
         STRIKE2, DIP2, RAKE2, EX,T_VAL, T_PL, T_AZM, P_VAL, P_PL, P_AZM, ...
         N_VAL, N_PL, N_AZM
    K    NDK format (e.g. from GCMT website)
    Z    GFZ MT format (e.g. from GFZ website)
    T    tectoplot native format (no processing done)

  By default, if multiple catalogs are specified, then the mechanisms will be
  culled to remove likely duplicate events, with the event from the earlier
  specified catalog being retained. [[nocull]] turns off this behavior.

  Culled events are stored in ${F_FOC}culled_focal_mechanisms.txt

Example:
tectoplot -a -c -ccat GFZ -o example_ccat
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if arg_is_flag $2; then
      info_msg "[-ccat]: No catalog specified. Using default $CMT_CATALOG_TYPE."
    else
      unset CCAT_STRING
      # Everything except G, I, Z
      CUSTOMCATSTR="ABCDEFHJKLMNOPQRSTVWXYZ"
      unset CMT_CATALOG_TYPE
      while ! arg_is_flag ${2}; do
        CCATARG="${2}"
        shift
        case $CCATARG in
          ISC)
            CMT_CATALOG_TYPE+=("ISC")
            CCAT_STRING=${CCAT_STRING}"I"
            # EQ_SOURCESTRING=$ISC_EQ_SOURCESTRING
            # EQ_SHORT_SOURCESTRING=$ISC_EQ_SHORT_SOURCESTRING
          ;;
          GFZ)
            CMT_CATALOG_TYPE+=("GFZ")
            CCAT_STRING=${CCAT_STRING}"Z"
            # EQ_SOURCESTRING=$ISCEHB_EQ_SOURCESTRING
            # EQ_SHORT_SOURCESTRING=$ISCEHB_EQ_SHORT_SOURCESTRING
          ;;
          GCMT)
            CMT_CATALOG_TYPE+=("GCMT")
            CCAT_STRING=${CCAT_STRING}"G"
            # EQ_SOURCESTRING=$ANSS_EQ_SOURCESTRING
            # EQ_SHORT_SOURCESTRING=$ANSS_EQ_SHORT_SOURCESTRING
            ;;
          nocull)
            CULL_CMT_CATALOGS=0
          ;;
          cull) # Not used?
            forcecmtcullflag=1
            CULL_CMT_CATALOGS=1
          ;;
          replace)  # Not used?
            cmtcatalogreplaceflag=1
            ADD_CMT_SOURCESTRING=2
          ;;
          *)
            # If we are plotting a USGS focal mechanism, check whether it exists before adding as catalog file
            if [[ -s "${CCATARG}" || ( "${CCATARG}" == "usgs" && -s ${TMP}${F_CMT}usgs_foc.cat ) ]]; then

              cmtfilenumber=$(echo "$cmtfilenumber+1" | bc)
              CCAT_LETTER[$cmtfilenumber]=${CUSTOMCATSTR:${cmtfilenumber}:1}
              CCAT_STRING=${CCAT_STRING}${CCAT_LETTER[$cmtfilenumber]}
              # Add a custom catalog file

              if [[ "${CCATARG}" == "usgs" ]]; then
                CCATARG=${TMP}${F_CMT}usgs_foc.cat
                # Mark as a custom CMT with type T (tectoplot format)
                CMTADDFILE_TYPE[$cmtfilenumber]="T"
              else
                # Custom catalogs require a format code
                CMTADDFILE_TYPE[$cmtfilenumber]="${2}"
                shift
              fi
              CMTADDFILE[$cmtfilenumber]=$(abs_path $CCATARG)
              CMT_CATALOG_TYPE+=("custom")
            else
              info_msg "Seismicity file ${CMTADDFILE[$cmtfilenumber]} does not exist"
            fi
          ;;
        esac
      done
    fi
    info_msg "[-ccat]: CMT Catalogs are ${CMT_CATALOG_TYPE[@]}"
    ;;

  -zcat) # -zcat: select seismicity catalog(s) and add custom seismicity files
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zcat:         select seismicity catalog(s) and add custom seismicity files
Usage: -zcat [catalogID1] [[catalogid2...]] [[catalogfile1...]] [[catalogfile2...]]
      [[nocull]]

  catalogID: ANSS | ISC
  catalogfile: Any file in the format lon lat depth mag [[timecode]] [[ID]] [[epoch]]

  By default, if multiple catalogs are specified, then the seismicity will be
  culled to remove likely duplicate events, with the event from the earlier
  specified catalog, or the earlier event from the same catalog, being
  retained. [[nocull]] turns off this behavior. Culled events are stored in
  ${F_SEIS}culled_seismicity.txt

Example:
tectoplot -z -zcat ISC -o example_zcat
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if arg_is_flag $2; then
      info_msg "[-zcat]: No catalog specified. Using default $EQ_CATALOG_TYPE."
    else
      unset EQ_CATALOG_TYPE
      while ! arg_is_flag ${2}; do
        ZCATARG="${2}"
        shift
        if [[ $ZCATARG == "usgs" ]]; then
          ZCATARG=${TMP}${F_SEIS}usgs.cat
        fi
        case $ZCATARG in
          ISC)
            EQ_CATALOG_TYPE+=("ISC")
            EQ_SOURCESTRING=("$ISC_EQ_SOURCESTRING")
            EQ_SHORT_SOURCESTRING=("$ISC_EQ_SHORT_SOURCESTRING")
          ;;
          EMSC)
            EQ_CATALOG_TYPE+=("EMSC")
            EQ_SOURCESTRING=("$EMSC_EQ_SOURCESTRING")
            EQ_SHORT_SOURCESTRING=("$EMSC_EQ_SHORT_SOURCESTRING")
          ;;
          EHB)
            EQ_CATALOG_TYPE+=("EHB")
            EQ_SOURCESTRING=("$ISCEHB_EQ_SOURCESTRING")
            EQ_SHORT_SOURCESTRING+=("$ISCEHB_EQ_SHORT_SOURCESTRING")
          ;;
          ANSS)
            EQ_CATALOG_TYPE+=("ANSS")
            EQ_SOURCESTRING=("$ANSS_EQ_SOURCESTRING")
            EQ_SHORT_SOURCESTRING+=("$ANSS_EQ_SHORT_SOURCESTRING")
          ;;
          GHEC)
            EQ_CATALOG_TYPE+=("GHEC")
            EQ_SOURCESTRING="($GEMGHEC_SOURCESTRING)"
            EQ_SHORT_SOURCESTRING+=("$GEMGHEC_SHORT_SOURCESTRING")
          ;;
          nocull)
            CULL_EQ_CATALOGS=0
          ;;
          cull)
            forceeqcullflag=1
            CULL_EQ_CATALOGS=1
          ;;
          replace)
            eqcatalogreplaceflag=1
            ADD_EQ_SOURCESTRING=2
          ;;
          *)
            if [[ -s "${ZCATARG}" ]]; then
              seisfilenumber=$(echo "$seisfilenumber+1" | bc)
              SEISADDFILE[$seisfilenumber]=$(abs_path $ZCATARG)
              EQ_CATALOG_TYPE+=("custom")
            else
              info_msg "Seismicity file ${SEISADDFILE[$seisfilenumber]} does not exist"
            fi
          ;;
        esac
      done
    fi
    ;;

  -zccpt) # -zccpt: select CPT for seismicity and focal mechanisms
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zccpt:       select CPT for seismicity and focal mechanisms
Usage: -zccpt [cpt_name] [[inv]]

  cpt_name is a builtin CPT (GMT, tectoplot) or a CPT file.
  inv  :  invert the CPT direction

Example:
tectoplot -z -zccpt turbo inv -o example_zccpt
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  if ! arg_is_flag "${2}"; then
    if get_cpt_path "${2}"; then
      SEIS_CPT="${CPT_PATH}"
    else
      echo "[-zccpt]: CPT $2 not recognized."
    fi
    shift
  fi

  if [[ $2 == "inv" ]]; then
    SEIS_CPT_INV="-I"
    shift
  else
    SEIS_CPT_INV=""
  fi

  ;;

  -zcolor) # -zcolor: select depth range for color cpt for seismicity
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zcolor:       select depth range for color cpt for seismicity
Usage: -zcolor [[mindepth=${EQMINDEPTH_COLORSCALE}]] [[maxdepth=${EQMAXDEPTH_COLORSCALE}]]

  mindepth, maxdepth are in positive down km without unit character
  Affects any data that use the seismicity depth CPT (focals, Slab2 contours,...)

Example: Plot seismicity with deep yellow-blue transition
tectoplot -a -z -zcolor 0 150 -o example_zcolor
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if arg_is_flag $2; then
      info_msg "[-zcolor]: No min/max depth specified. Using default $EQMINDEPTH_COLORSCALE/$EQMAXDEPTH_COLORSCALE"
    else
      EQMINDEPTH_COLORSCALE=$2
      shift
    fi
    if arg_is_flag $2; then
      info_msg "[-zcolor]: No max depth specified. Using default $EQMAXDEPTH_COLORSCALE"
    else
      EQMAXDEPTH_COLORSCALE=$2
      shift
    fi
    ;;

  -zmag) # -zmag: filter seismicity data by magnitude
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zmag:         filter seismicity data by magnitude
Usage: -zmag [[minmag=${EQ_MINMAG}]] [[maxmag=${EQ_MAXMAG}]]

Example: Plot large magnitude seismicity
tectoplot -a -z -zmag 7.5 10 -o example_zmag
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if arg_is_flag $2; then
      info_msg "[-zmax]: No limits specified [minmag] [maxmag]"
    else
      EQ_MINMAG="${2}"
      shift
      if arg_is_flag $2; then
        info_msg "[-zmax]: No maximum magnitude specified. Using default."
      else
        EQ_MAXMAG="${2}"
        shift
      fi
    fi
    eqmagflag=1
    ;;

  -cline) # -cline: set width of focal mechanism symbol outline and nodal plane lines
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-cline:        set width of focal mechanism symbol outline and nodal plane lines
Usage: -cline [width=${CMT_LINEWIDTH}] [color=${CMT_LINECOLOR}]

  width is specified with units of p [e.g. 1p]
  if width==0 | 0p, then no line will be drawn

Example:
tectoplot -c -cline 0 -o example_cline
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if arg_is_flag "${2}"; then
      info_msg "[-cline]: No line width given. Using default=${CMT_LINEWIDTH}"
    else
      CMT_LINEWIDTH="${2}"
      shift
    fi
    if ! arg_is_flag "${2}"; then
      CMT_LINECOLOR="${2}"
      shift
    fi
    ;;

  -zline) # -zline: set width of seismicity symbol outline line
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zline:        set width of seismicity symbol outline line
Usage: -zline [width=${EQLINEWIDTH}]

  width is specified with units of p [e.g. 1p]
  if width==0 | 0p, then no line will be drawn

Example:
tectoplot -z -zline 0 -o example_zline
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if arg_is_flag "${2}"; then
      info_msg "[-zline]: No line width given. Using default=${EQLINEWIDTH}"
    else
      EQLINEWIDTH="${2}"
      shift
    fi
    if ! arg_is_flag "${2}"; then
      EQLINECOLOR="${2}"
      shift
    fi
    ;;

  -znoplot) # -znoplot: process seismicity but don't plot to map
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-znoplot:      process seismicity but don't plot to map
Usage: -znoplot

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    dontplotseisflag=1
    ;;


  -cnoplot)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-cnoplot:      process focal mechanisms but don't plot to map
Usage: -cnoplot

--------------------------------------------------------------------------------
EOF
shift && continue
fi
    dontplotcmtflag=1
    ;;

  -zcsort) # -zcsort: sort seismicity and focal mechanisms
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zcsort:       sort seismicity and focal mechanisms
Usage: -zcsort [[dimension]] [[direction]]

  dimension: depth | time | mag    (magnitude)
  direction: up | down

  mag down = put larger earthquakes on top of smaller
  map up   = put smaller earthquakes on top of larger

Example:
tectoplot -z -zcsort mag down -o example_zcsort
ExampleEnd
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if arg_is_flag $2; then
      info_msg "[-zcsort]:  No sort dimension specified. Using depth."
      ZSORTTYPE="depth"
    else
      ZSORTTYPE="${2}"
      shift
    fi
    if arg_is_flag $2; then
      info_msg "[-zcsort]:  No sort direction specified. Using down."
      ZSORTDIR="down"
    else
      ZSORTDIR="${2}"
      shift
    fi
    dozsortflag=1
    ;;

	*)    # unknown option.

    # SECTION MODULE ARGS

    for this_mod in ${TECTOPLOT_MODULES[@]}; do

      if type "tectoplot_args_${this_mod}" >/dev/null 2>&1; then
        cmd="tectoplot_args_${this_mod}"
        "$cmd" "$@"

        # Shift away the arguments processed by the module
        if [[ $tectoplot_module_shift -gt 0 ]]; then
          shift ${tectoplot_module_shift}
        fi

        if [[ $tectoplot_module_caught -eq 1 ]]; then
        # only add if not already in there 
          if [[ ! " ${TECTOPLOT_ACTIVE_MODULES[@]} "  =~ " ${this_mod} " ]]; then
            TECTOPLOT_ACTIVE_MODULES+=("${this_mod}")
          fi
          break
        fi
      fi
    done

    # If we aren't doing usage and we didn't catch the option in a module, it is unknown
    if [[ $tectoplot_module_caught -eq 0 && $usageskipflag -ne 1 ]]; then
		    echo "Unknown argument encountered: ${1}" 1>&2
        exit 1
    fi
    ;;
  esac
  shift
done


#### END OF ARGUMENT PROCESSING SECTION

[[ $USAGEFLAG -eq 1 ]] && exit

### MODULE DOWNLOAD DATA

for this_mod in ${TECTOPLOT_ACTIVE_MODULES[@]}; do
  if type "tectoplot_download_${this_mod}" >/dev/null 2>&1; then
    info_msg "Running module data download ${this_mod}"
    cmd="tectoplot_download_${this_mod}"
    "$cmd"
  fi
done

BOOKKEEPINGFLAG=1

CMTRESCALE=$(echo "$CMTSCALE * $SEISSCALE " | bc -l)  # * $SEISSCALE

#### BEGINNING OF BOOKKEEPING SECTION

if [[ $BOOKKEEPINGFLAG -eq 1 ]]; then

  if [[ $plotselectedfeflag -eq 1 ]]; then
    plots+=("selected-flinn-engdahl")
  fi

  # If we are asked to delete the topo for a custom region
  if [[ $tdeleteflag -eq 1 && $usingcustomregionflag -eq 1 ]]; then
    info_msg "[-tdelete]: Deleting saved topo for $CUSTOMREGIONID: ( ${SAVEDTOPODIR}${CUSTOMREGIONID}.tif)"
    rm -f ${SAVEDTOPODIR}${CUSTOMREGIONID}.tif
    rm -f ${SAVEDTOPODIR}${CUSTOMREGIONID}.command
  fi


  if [[ $setregionbyearthquakeflag -eq 1 ]]; then

    if [[ "${REGION_EQ}" == "usgs" ]]; then
      if [[ -s ${TMP}${F_CMT}usgs_foc.cat ]]; then
        REGION_EQ_LON=$(tail -n 1 ${TMP}${F_CMT}usgs_foc.cat | gawk '{print $5}')
        REGION_EQ_LAT=$(tail -n 1 ${TMP}${F_CMT}usgs_foc.cat | gawk '{print $6}')
      elif [[ -s ${TMP}${F_SEIS}usgs.cat ]]; then
        REGION_EQ_LON=$(tail -n 1 ${TMP}${F_SEIS}usgs.cat | gawk '{print $1}')
        REGION_EQ_LAT=$(tail -n 1 ${TMP}${F_SEIS}usgs.cat | gawk '{print $2}')
      else
        echo "Region cannot be set by USGS earthquake event... not found"
        exit 1
      fi
    else

      for this_catalog in ${EQ_CATALOG_TYPE[@]}; do
        case ${this_catalog} in
          ANSS)
          info_msg "[-r eq]: Looking for ANSS event ${REGION_EQ}"
          
          mytmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'mytmpdir')

          if [[ -s ${ANSSDIR}anss.gpkg ]]; then
            ogr2ogr -f CSV -lco SEPARATOR=TAB  -dialect sqlite -sql "SELECT X(geom), Y(geom), Z(geom), mag, magType, id, CAST(time as VARCHAR) FROM anss WHERE id=='${REGION_EQ}'" ${mytmpdir}/anss_result.csv ${ANSSDIR}anss.gpkg


            if [[ -s ${mytmpdir}/anss_result.csv ]]; then

            cat ${mytmpdir}/anss_result.csv
              # info_msg "[-r eq]: Found event in ANSS catalog"
              # echo "Found EQ region hypocenter $REGION_EQ"
              REGION_EQ_LON=$(gawk < ${mytmpdir}/anss_result.csv '(NR==2) {print $1}')
              REGION_EQ_LAT=$(gawk < ${mytmpdir}/anss_result.csv '(NR==2) {print $2}')
              REGION_EQ_DEPTH=$(gawk < ${mytmpdir}/anss_result.csv '(NR==2) {print $3}')
              REGION_EQ_MAG=$(gawk < ${mytmpdir}/anss_result.csv '(NR==2) {print $4}')
              REGION_EQ_MAGTYPE=$(gawk < ${mytmpdir}/anss_result.csv '(NR==2) {print $5}')
              REGION_EQ_AUTHOR=$(gawk < ${mytmpdir}/anss_result.csv '(NR==2) {print $6}')
              REGION_EQ_TIME=$(gawk < ${mytmpdir}/anss_result.csv '(NR==2) { print substr($7,1,19)}')
              REGION_EQ_TYPE="ANSS"
              rm -f ${mytmpdir}/anss_result.txt

              echo REGION_EQ_LAT=${REGION_EQ_LAT} time is ${REGION_EQ_TIME}
              break
            fi
            rm ${mytmpdir}/*
            rmdir ${mytmpdir}
          fi
          ;;
        ISC)
          grep -h ${REGION_EQ} -r ${ISC_TILE_DIR} | sed 's/[[:blank:]]//g' | gawk -F, -v key=${REGION_EQ} '
          {
            if ($1==key) {
              print
            }
          }' | head -n 1 > isc_result.txt
          if [[ -s isc_result.txt ]]; then
            info_msg "[-r eq]: Found event in ISC tile data: ${EQ_SEARCH}"
            # echo "Found EQ region hypocenter $REGION_EQ"
            REGION_EQ_LON=$(gawk -F, < isc_result.txt '{print $7}')
            REGION_EQ_LAT=$(gawk -F, < isc_result.txt '{print $6}')
            REGION_EQ_DEPTH=$(gawk -F, < isc_result.txt '{print $8}')
            REGION_EQ_MAG=$(gawk -F, < isc_result.txt '{print $12}')
            REGION_EQ_MAGTYPE=$(gawk -F, < isc_result.txt '{print $11}')
            REGION_EQ_AUTHOR=$(gawk -F, < isc_result.txt '{print $10}')
            REGION_EQ_TIME=$(gawk -F, < isc_result.txt '{print $4 "T" $5}')
            REGION_EQ_TYPE="ISC"
            rm -f isc_result.txt
            break
          fi
          ;;
        GHEC)
# 109.700 34.500 10 8.25 1556-02-02T01:01:01 1556.0202000 -1
          EQ_SEARCH=$(gawk < ${GEMGHEC_DATA} -v id=${REGION_EQ} '($6 == id) { print }')
          # grep -h -m 1 ${REGION_EQ} ${GEMGHEC_DATA} | head -1)
          if [[ $EQ_SEARCH != "" ]]; then
            info_msg "[-r eq]: Found event in GHEC data: ${EQ_SEARCH}"
            # echo "Found EQ region hypocenter $REGION_EQ"
            REGION_EQ_LON=$(echo $EQ_SEARCH | gawk '{print $1}')
            REGION_EQ_LAT=$(echo $EQ_SEARCH | gawk '{print $2}')
            REGION_EQ_DEPTH=$(echo $EQ_SEARCH | gawk '{print $3}')
            REGION_EQ_MAG=$(echo $EQ_SEARCH | gawk '{print $4}')
            REGION_EQ_MAGTYPE="Historic"
            REGION_EQ_AUTHOR="GHEC"
            REGION_EQ_TIME=$(echo $EQ_SEARCH | gawk '{print $5}')
            REGION_EQ_TYPE="GHEC"
            break
          fi

          break
          ;;
        esac

      # fi
      done
    fi

    # Check if width is in km or in degrees
    if [[ ${EQ_REGION_WIDTH} == *k ]]; then
      info_msg "[-r eq]: Detected km for region size"
      MINLON=$(gmt project -C${REGION_EQ_LON}/${REGION_EQ_LAT} -A-90 -Q -G${EQ_REGION_WIDTH} -L0/$(echo ${EQ_REGION_WIDTH} | gawk '{print $1+0}') | tail -n 1 | gawk  '{print $1}')
      MAXLON=$(gmt project -C${REGION_EQ_LON}/${REGION_EQ_LAT} -A90 -Q -G${EQ_REGION_WIDTH} -L0/$(echo ${EQ_REGION_WIDTH} | gawk '{print $1+0}') | tail -n 1 | gawk  '{print $1}')
      MAXLAT=$(gmt project -C${REGION_EQ_LON}/${REGION_EQ_LAT} -A0 -Q -G${EQ_REGION_WIDTH} -L0/$(echo ${EQ_REGION_WIDTH} | gawk '{print $1+0}') | tail -n 1 | gawk  '{print $2}')
      MINLAT=$(gmt project -C${REGION_EQ_LON}/${REGION_EQ_LAT} -A180 -Q -G${EQ_REGION_WIDTH} -L0/$(echo ${EQ_REGION_WIDTH} | gawk '{print $1+0}') | tail -n 1 | gawk  '{print $2}')
    else
      MINLON=$(echo "$REGION_EQ_LON - $EQ_REGION_WIDTH" | bc -l)
      MAXLON=$(echo "$REGION_EQ_LON + $EQ_REGION_WIDTH" | bc -l)
      MINLAT=$(echo "$REGION_EQ_LAT - $EQ_REGION_WIDTH" | bc -l)
      MAXLAT=$(echo "$REGION_EQ_LAT + $EQ_REGION_WIDTH" | bc -l)
    fi


    if [[ $(echo "${MAXLON} < ${MINLON}" | bc) -eq 1 ]]; then
      echo "Longitude range is messed up. Trying to adjust"
      MAXLON=$(echo "${MAXLON}+360" | bc -l)
    fi

    info_msg "[-r]: Earthquake centered region: $MINLON/$MAXLON/$MINLAT/$MAXLAT centered at $REGION_EQ_LON/$REGION_EQ_LAT"
  fi

  #### Set time using earthquake,

  if [[ $EQ_SEARCH != "" && $settimebyearthquakeflag -eq 1 ]]; then

    info_msg "Resetting time based on earthquake"

    STARTTIME=$(echo $REGION_EQ_TIME| gawk -v shiftyear=${TIME_BEFORE_BUFFER} '{
      split($1, a, "-")
      printf("%04d-%s",a[1]-shiftyear,substr($1, 6, length($1)-5))
    }')

    ENDTIME=$(date_shift_utc)    # COMPATIBILITY ISSUE WITH GNU date

  fi




  ################################################################################
  ###### Calculate some sizes for the final map document based on AOI aspect ratio

  LATSIZE=$(echo "$MAXLAT - $MINLAT" | bc -l)
  LONSIZE=$(echo "$MAXLON - $MINLON" | bc -l)

  CENTERLON=$(echo "($MINLON + $MAXLON) / 2" | bc -l)
  CENTERLAT=$(echo "($MINLAT + $MAXLAT) / 2" | bc -l)

  # Calculate the ideal FORMAT_FLOAT_OUT number of decimals given the range '%.2f'

  # echo $LATSIZE $LONSIZE | gawk '
  #   {
  #     avesize=($1+$2)/2
  #     numtens=log(avesize)
  #   }'

  if [[ ! $usecustomrjflag -eq 1 ]]; then
    rj[0]="-R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}"
    rj[1]="-JQ${CENTERLON}/${PSSIZE}i"

    RJSTRING="${rj[@]}"
    info_msg "Basic RJSTRING is $RJSTRING"
    usecustomrjflag=1
  fi


  # For a standard run, we want something like this. For other projections, unlikely to be sufficient
  # We want a page that is PSSIZE wide with a MARGIN. It scales vertically based on the
  # aspect ratio of the map region

  INCH=$PSSIZE

  # If MAKERECTMAP is set to 1, the RJSTRING will be changed to a different format
  # to allow plotting of a rectangular map not bounded by parallels/meridians.
  # However, data that does not fall within the AOI region given by MINLON/MAXLON/etc
  # will not be processed or plotted. So we would need to recalculate these parameters
  # based on the maximal range present in the final plot. I would usually do this by
  # rendering the map frame as populated polylines and finding the maximal coordinates of the vertices.

  # It is important that if MAKERECTMAP is set to 1, then also
  # rj[0] contains the -R string and rj[1] contains the -J string

  if [[ $calcutmzonelaterflag -eq 1 ]]; then
    # This breaks terribly if the average longitude is not between -180 and 180
    UCENTERLON=$(gmt mapproject -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} -WjCM ${VERBOSE} | gawk '{print $1}')
    AVELONp180o6=$(echo "(($UCENTERLON) + 180)/6" | bc -l)
    UTMZONE=$(echo $AVELONp180o6 1 | gawk  '{val=int($1)+($1>int($1)); print (val>0)?val:1}')
    info_msg "Using UTM Zone $UTMZONE"
    projname="UTM zone ${UTMZONE}"

    rj[0]="-R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}"

    if [[ ${rjmapscaleflag} -eq 1 ]]; then
      rj[1]="-JU${UTMZONE}/${rjmapscale}"
    else
      rj[1]="-JU${UTMZONE}/${INCH}i"
    fi
    RJSTRING="${rj[@]}"
  fi



  if [[ $MAKERECTMAP -eq 1 && ${rj[0]} == -R* && ${rj[1]} == -J* ]]; then
    rj[0]="-R${MINLON}/${MINLAT}/${MAXLON}/${MAXLAT}r"
    RJSTRING="${rj[@]}"

    NEWRANGE=($(gmt mapproject ${RJSTRING} -Wr))

    if [[ $(echo "${NEWRANGE[0]} > 180 && ${NEWRANGE[1]} >= 180" | bc) -eq 1 ]]; then
      NEWRANGE[0]=$(echo "${NEWRANGE[0]} - 360" | bc -l)
      NEWRANGE[1]=$(echo "${NEWRANGE[1]} - 360" | bc -l)
    fi

    MINLON=${NEWRANGE[0]}
    MAXLON=${NEWRANGE[1]}
    MINLAT=${NEWRANGE[2]}
    MAXLAT=${NEWRANGE[3]}

  fi
  # We have to set the RJ flag after setting the plot size (INCH)

  # if [[ $setutmrjstringfromarrayflag -eq 1 ]]; then
  #
  #
  #   if [[ $MAKERECTMAP -eq 1 ]]; then
  #     rj[0]="-R${MINLON}/${MINLAT}/${MAXLON}/${MAXLAT}r"
  #     rj[1]="-JU${UTMZONE}/${INCH}i"
  #     RJSTRING="${rj[@]}"
  #
  #     # echo "Making map outline"
  #     # echo     gmt psbasemap -A $RJSTRING ${VERBOSE}
  #     NEWRANGE=($(gmt mapproject ${RJSTRING} -Wr))
  #
  #     if [[ $(echo "${NEWRANGE[0]} > 180 && ${NEWRANGE[1]} >= 180" | bc) -eq 1 ]]; then
  #       NEWRANGE[0]=$(echo "${NEWRANGE[0]} - 360" | bc -l)
  #       NEWRANGE[1]=$(echo "${NEWRANGE[1]} - 360" | bc -l)
  #     fi
  #
  #     MINLON=${NEWRANGE[0]}
  #     MAXLON=${NEWRANGE[1]}
  #     MINLAT=${NEWRANGE[2]}
  #     MAXLAT=${NEWRANGE[3]}
  #
  #   else
  #     rj[0]="-R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}"
  #     rj[1]="-JU${UTMZONE}/${INCH}i"
  #   fi
  #   RJSTRING="${rj[@]}"
  #   info_msg "[-RJ]: Custom region and projection string is: ${RJSTRING}"
  # fi


  # Estimate the AOI by sampling a grid of lon/lat points
  if [[ $recalcregionflag_lonlat -eq 1 ]]; then

    # Check if the box is very small, and if so don't expand the AOI
    MAPDEGSQ=$(echo ${MINLON} ${MAXLON} ${MINLAT} ${MAXLAT} | gawk '
      {
        lonrange=$2-$1
        latrange=$4-$3
        print (lonrange < 1.5 || latrange < 1.5)?1:0
      }')

    if [[ $MAPDEGSQ -eq 0 ]]; then

    info_msg "Recalculating region using grid points method."

    # Get the bounds using a grid of points. For some reason, sometimes gmtselect will return
    # lon+360 (e.g. 276 instead of -84), so fix that as needed...
      gawk '
      BEGIN {
        for(i=-90;i<=90;i++) {
          for(j=-180;j<=180;j++) {
            print j, i
          }
        }
      }' | gmt gmtselect ${RJSTRING} ${VERBOSE} | gawk '{ if ($1>180) { $1=$1-360 } else if ($1<-180) { $1=$1+360}; print }'> selectbounds.txt

      NEWRANGE=($(gawk < selectbounds.txt -v buffer_d=1 '
        BEGIN {
          found_m180=0
          found_180=0
          getline
          minlon=$1
          maxlon=$1
          minlat=$2
          maxlat=$2
          maxneglon=-180
          minposlon=180
        }
        {

          minlon=($1<minlon)?$1:minlon
          maxlon=($1>maxlon)?$1:maxlon
          minlat=($2<minlat)?$2:minlat
          maxlat=($2>maxlat)?$2:maxlat
          maxneglon=($1>maxneglon && $1<=0)?$1:maxneglon
          minposlon=($1<minposlon && $1>=0)?$1:minposlon

          # if ($1==-180) {
          #   found_m180=1
          # } else if ($1==180) {
          #   found_180=1
          # }

          foundlon[$1]=1
          lon[NR]=$1
          lat[NR]=$2
        }
        END {

          # print "minlon/maxlon/minlat/maxlat", minlon, maxlon, minlat, maxlat > "/dev/stderr"
          # print "maxneglon/minposlon", maxneglon, minposlon > "/dev/stderr"
          if (minlon==-180 && maxlon==180) {
            crosses_meridian=0
            # Either it is a global extent, or crosses the antimeridian

            if (length(foundlon)==361) {
              # print "Detected global longitude range"  > "/dev/stderr"
              if (minlon >= -180+buffer_d) {
                minlon-=buffer_d
              }
              if (maxlon <= 180-buffer_d ) {
                maxlon += buffer_d
              }
              if (minlat >= -90+buffer_d) {
                minlat-=buffer_d
              }
              if (maxlat <= 90-buffer_d) {
                maxlat+=buffer_d
              }
              print minlon, maxlon, minlat, maxlat
            } else {
              # print "Detected non-global longitude range crossing antimeridian"  > "/dev/stderr"
              maxneglon+=360
              if (minposlon >= buffer_d+0) {
                minposlon-=buffer_d
              }
              if (maxneglon <= 180-buffer_d ) {
                maxneglon += buffer_d
              }
              if (minlat >= -90+buffer_d) {
                minlat-=buffer_d
              }
              if (maxlat <= 90-buffer_d) {
                maxlat+=buffer_d
              }
              print minposlon, maxneglon, minlat, maxlat

            }
          } else {
            # print "Detected reasonable longitude range"  > "/dev/stderr"
            if (minlon >= -180+buffer_d) {
              minlon-=buffer_d
            }
            if (maxlon <= 180-buffer_d ) {
              maxlon += buffer_d
            }
            if (minlat >= -90+buffer_d) {
              minlat-=buffer_d
            }
            if (maxlat <= 90-buffer_d) {
              maxlat+=buffer_d
            }
            print minlon, maxlon, minlat, maxlat
          }

        }'))

      # range=$(xy_range selectbounds.txt)
      # Points at -180 and 180 indicates crossing of the antimeridian. In that case, we choose the positive longitude

      MINLON=${NEWRANGE[0]}
      MAXLON=${NEWRANGE[1]}
      MINLAT=${NEWRANGE[2]}
      MAXLAT=${NEWRANGE[3]}

    else
      info_msg "[lonlat]: Map area is too small for lonlat AOI determination... using original AOI"
    fi # End of MAPDEGSQ >= 5
  fi

  # The default region box is the bounding longitude and latitude

  # echo ${MINLON} ${MAXLAT}> ${TMP}${F_MAPELEMENTS}bounds.txt
  # echo ${MAXLON} ${MAXLAT}>> ${TMP}${F_MAPELEMENTS}bounds.txt
  # echo ${MAXLON} ${MINLAT}>> ${TMP}${F_MAPELEMENTS}bounds.txt
  # echo ${MINLON} ${MINLAT}>> ${TMP}${F_MAPELEMENTS}bounds.txt
  # echo ${MINLON} ${MAXLAT}>> ${TMP}${F_MAPELEMENTS}bounds.txt

  gmt psbasemap ${RJSTRING} -A ${VERBOSE} | gawk '
    ($1!="NaN") {
      while ($1>180) { $1=$1-360 }
      while ($1<-180) { $1=$1+360 }
      if ($1==($1+0) && $2==($2+0)) {
        print
      }
    }' > ${TMP}${F_MAPELEMENTS}bounds.txt


  # This section is needed to make the circular AOI for e.g. stereographic maps with a given horizon.

  if [[ $recalcregionflag_circle -eq 1 ]]; then
    # For science, make a small circle that approximates the map edge
    polelat=${CENTRALLATITUDE}
    polelon=${CENTRALMERIDIAN}
    poledeg=${DEGRANGE}

    # The gmt grdtrack approach doesn't really work
    # echo gmt grdcut to get region
    # gmt grdmath -R-180/180/-90/90 -I1d 1 = ${TMP}1.grd
    # echo     gmt grdcut ${TMP}1.grd -D -S${polelon}/${polelat}/${poledeg}d
    #
    # gmt grdcut ${TMP}1.grd -D -S${polelon}/${polelat}/${poledeg}d
    # echo out

    poleantilat=$(echo "0 - (${polelat}+0.0000001)" | bc -l)
    poleantilon=$(echo "${polelon}" | gawk  '{if ($1 < 0) { print $1+180 } else { print $1-180 } }')

    gmt_init_tmpdir
      gmt project -T${polelon}/${polelat} -C${poleantilon}/${poleantilat} -G0.5/${poledeg} -L-360/0 $VERBOSE | gawk '{print $1, $2}' > ${TMP}${F_MAPELEMENTS}mapedge_smallcircle.txt
    gmt_remove_tmpdir

    gotrange=0
    # Special case of map centered at equator with 90 degree deg_range
    if [[ $(echo "$CENTRALLATITUDE == 0 && $DEGRANGE == 90" | bc) -eq 1 ]]; then
        MINLON=$(echo "$CENTRALMERIDIAN - 90" | bc -l)
        MAXLON=$(echo "$CENTRALMERIDIAN + 90" | bc -l)
        MINLAT=-90
        MAXLAT=90
        gotrange=1
    # Case of map centered above the equator - can exclude low latitude areas
    # Calculate the distance in degrees from the center point to the north pole
    elif [[ $(echo "$CENTRALLATITUDE >= 0" | bc) -eq 1 ]]; then
      if [[ $(echo "$CENTRALLATITUDE + $DEGRANGE > 90" | bc) -eq 1 ]]; then
        MINLON=-180
        MAXLON=180
        MINLAT=$(echo "$CENTRALLATITUDE - $DEGRANGE" | bc -l)
        MAXLAT=90
        gotrange=1
      fi
    # Case of map centered below equator - can exclude high latitude areas
    else # Negative latitude
      if [[ $(echo "$CENTRALLATITUDE - $DEGRANGE < -90" | bc) -eq 1 ]]; then
        MINLON=-180
        MAXLON=180
        MINLAT=-90
        MAXLAT=$(echo "$CENTRALLATITUDE + $DEGRANGE" | bc -l)
        gotrange=1
      fi
    fi

    # The circle does not overlap a pole, so just take the min and max longitudes
    # and latitudes from the mapedge

    # We need to check whether the mapedge goes over the dateline and fix it

    if [[ $gotrange -eq 0 ]]; then
      fix_dateline_poly ${TMP}${F_MAPELEMENTS}mapedge_smallcircle.txt > ${TMP}${F_MAPELEMENTS}mapedge_smallcircle_fixed.txt
      MAPEDGERANGE=($(xy_range ${TMP}${F_MAPELEMENTS}mapedge_smallcircle_fixed.txt))
      MINLON=${MAPEDGERANGE[0]}
      MAXLON=${MAPEDGERANGE[1]}
      MINLAT=${MAPEDGERANGE[2]}
      MAXLAT=${MAPEDGERANGE[3]}
    fi
    rj[0]="-R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}"
    RJSTRING="${rj[@]}"
  fi

  # If we read the RJ string from the custom regions file, set it here before we
  # determine the bounding box and projected bounding box

  if [[ $usecustomregionrjstringflag -eq 1 ]]; then
    rj[0]=${CUSTOMREGIONRJSTRING[0]}
    rj[1]=${CUSTOMREGIONRJSTRING[1]}
    RJSTRING="${rj[@]}"
    info_msg "[-r]: Using customID RJSTRING: ${RJSTRING}"
  fi

  # This section is needed to determine the region and bounding box for oblique Mercator type projections
  # Not yet tested for maps crossing the dateline!

  if [[ $recalcregionflag_bounds -eq 1 ]]; then
      NEWRANGE=($(gmt mapproject ${RJSTRING} -Wr))
      info_msg "Updating AOI to new map extent: ${NEWRANGE[0]}/${NEWRANGE[1]}/${NEWRANGE[2]}/${NEWRANGE[3]}"
      MINLON=${NEWRANGE[0]}
      MAXLON=${NEWRANGE[1]}
      MINLAT=${NEWRANGE[2]}
      MAXLAT=${NEWRANGE[3]}

      gmt psbasemap ${RJSTRING} -A ${VERBOSE} | gawk '
        ($1!="NaN") {
          while ($1>180) { $1=$1-360 }
          while ($1<-180) { $1=$1+360 }
          if ($1==($1+0) && $2==($2+0)) {
            print
          }
        }' > ${TMP}${F_MAPELEMENTS}bounds.txt
  fi

  # Find the center point of the map

  NEWRANGECM=($(gmt mapproject ${RJSTRING} -WjCM ${VERBOSE}))
  CENTERLON=${NEWRANGECM[0]}
  CENTERLAT=${NEWRANGECM[1]}

  info_msg "RJSTRING: ${RJSTRING}; CENTERLON/CENTERLAT=${CENTERLON}/${CENTERLAT} MINLON/MAXLON/MINLAT/MAXLAT= ${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}"

  # Convert the bounding box to projected coordinates

  gmt mapproject ${TMP}${F_MAPELEMENTS}bounds.txt ${RJSTRING} ${VERBOSE} > ${TMP}${F_MAPELEMENTS}projbounds.txt

  ##### Define the output filename for the map, in PDF
  if [[ $outflag == 0 ]]; then
  	MAPOUT="tectomap_"$MINLAT"_"$MAXLAT"_"$MINLON"_"$MAXLON
    MAPOUTLEGEND="tectomap_"$MINLAT"_"$MAXLAT"_"$MINLON"_"$MAXLON"_legend.pdf"
    info_msg "Output file is $MAPOUT, legend is $MAPOUTLEGEND"
  else
    info_msg "Output file is $MAPOUT, legend is legend.pdf"
    MAPOUTLEGEND="legend.pdf"
  fi

  ##### If we are adding a region code to the custom regions file, do it now #####

  if [[ $addregionidflag -eq 1 ]]; then
    #REGIONTOADD
    # ${CUSTOMREGIONSDIR}${REGIONTOADD}.xy
    if [[ -s $CUSTOMREGIONS ]]; then
      gawk -v id=${REGIONTOADD} < $CUSTOMREGIONS '{
        if ($1 != id) {
          print
        }
      }' > ./regions.tmp
    else
      touch ./regions.tmp
    fi
    echo "${REGIONTOADD} ${MINLON} ${MAXLON} ${MINLAT} ${MAXLAT} ${RJSTRING}" >> ./regions.tmp
    mv ./regions.tmp ${CUSTOMREGIONS}
    cp ${TMP}${F_MAPELEMENTS}bounds.txt ${CUSTOMREGIONSDIR}${REGIONTOADD}.xy
  fi

  # Move the data source files into the temporary directory

  [[ -e ${LONGSOURCES} ]] && mv ${LONGSOURCES} ${TMP} && LONGSOURCES=${TMP}${LONGSOURCES_FILE}
  [[ -e ${SHORTSOURCES} ]] && mv ${SHORTSOURCES} ${TMP} && SHORTSOURCES=${TMP}${SHORTSOURCES_FILE}

  if [[ $overplotflag -eq 1 ]]; then
     info_msg "[-ips]: Moving copy basemap postscript file into temporary directory"
     mv "${THISDIR}"/tmpmap.ps "${TMP}map.ps"
  fi

  if [[ $selecttopofromextentflag -eq 1 ]]; then
    if [[ ${DEM_MINLON} == "unset" ]]; then
      DEM_MINLON=${MINLON}
      DEM_MAXLON=${MAXLON}
      DEM_MINLAT=${MINLAT}
      DEM_MAXLAT=${MAXLAT}
    fi

    # query GMT server for data type
    topo_auto_res=$(gmt grdcut ${EARTHRELIEFPREFIX} ${RJSTRING} -D -Vq --GMT_GRAPHICS_DPU=${TOPO_DPI} | gawk '{print $5}')

    case ${topo_auto_res} in
      0.000277777*) TOPOTYPE=01s  ;;
      0.000833333*) TOPOTYPE=03s  ;;
      0.004166666*) TOPOTYPE=15s  ;;
      0.008333333*) TOPOTYPE=15s  ;;   # 30s is not working in a lot of cases!
      0.016666666*) TOPOTYPE=01m  ;;
      0.033333333*) TOPOTYPE=02m  ;;
      0.050000000*|0.05) TOPOTYPE=03m  ;;
      0.066666666*) TOPOTYPE=04m  ;;
      0.083333333*) TOPOTYPE=05m  ;;
      0.100000000*|0.1) TOPOTYPE=06m  ;;
      0.166666666*) TOPOTYPE=10m  ;;
      0.333333333*) TOPOTYPE=20m  ;;
      0.250000000*|0.25) TOPOTYPE=15m  ;;
      0.500000000*|0.5) TOPOTYPE=30m  ;;
      1.000000000*|1|1.0) TOPOTYPE=01d  ;;
    esac

    info_msg "[-t]: Automatically selected remote dataset ${EARTHRELIEFPREFIX}_${TOPOTYPE}"
    # TOPOTYPE=$(echo ${DEM_MINLON} ${DEM_MAXLON} ${DEM_MINLAT} ${DEM_MAXLAT} | gawk -v modif=${TOPO_MODIFIER} '
    # function abs(x) { return (x>0)?x:-x}
    # {
    #   maxrange=modif*((abs($2-$1) > abs($4-$3))?abs($2-$1):abs($4-$3))
    #   print "maxrange is", maxrange > "/dev/stderr"
    #   if (maxrange < 1) {
    #     print "01s"
    #   } else if (maxrange < 3) {
    #     print "03s"
    #   } else if (maxrange < 15) {
    #     print "15s"
    #   } else if (maxrange < 60) {
    #     print "01m"
    #   } else if (maxrange < 100) {
    #     print "05m"
    #   } else  {
    #     print "10m"
    #   }
    # }')
    #
    # echo "Auto DEM is ${TOPOTYPE}"
    #
    clipdemflag=1
    BATHYMETRY=${TOPOTYPE}
    GRIDDIR=$EARTHRELIEFDIR
    GRIDFILE=${EARTHRELIEFPREFIX}_${TOPOTYPE}
    echo $EARTHRELIEF_SHORT_SOURCESTRING >> ${SHORTSOURCES}
    echo $EARTHRELIEF_SOURCESTRING >> ${LONGSOURCES}
    [[ ! -d $EARTHRELIEFDIR ]] && mkdir -p $EARTHRELIEFDIR
  fi

  #### Change into our temporary directory for the rest of the script

  cd "${TMP}"

#   ### Set up font names from the fonts/ directory
#   gawk '{print $1, 0.700, 0}' <<- EOF > PSL_custom_fonts.txt
# LinBiolinumO
# LinBiolinumOI
# LinBiolinumOB
# LinLibertineOB
# Unifont
# EOF

# # Add the included fonts directory
# GS_FONTPATH="/Users/kylebradley/fonts"
# gmt set PS_CONVERT="C-sFONTPATH=${GS_FONTPATH}"
# gmt set PS_CHAR_ENCODING="ISOLatin1+"
# gmt set PS_CHAR_ENCODING ISO-8859-5
# export LC_CTYPE="en_US.UTF-8"

  echo "${RJSTRING}" > ${F_MAPELEMENTS}rjstring.txt

  #### Adjust selection polygon file to conform to gmt select requirements (split
  # at dateline and have correct -180/180 longitude for the given polygon)

  if [[ $fixselectpolygonsflag -eq 1 ]]; then
    gmt spatial -Ss ${POLYGONAOI} ${VERBOSE} | gawk '
    BEGIN {
      numpoly=0
    }
    {
      if ($1==">") {
        print
        numpoly++
      } else if ($1 == -180 || $1 == 180) {
        print "P" numpoly, $2
      } else {
        if ($1>180) {
          $1=$1-360
        }
        if ($1 < 0) {
          whatkind[numpoly]--
        } else {
          whatkind[numpoly]++
        }
        print
      }
    } END {
      for (key in whatkind) {
        printf("s/P%d/%d/\n", key, (whatkind[key]>=0)?180:-180) > "./fixpoly.sed"
      }
    }' > ./polygon.prep

    sed -f ./fixpoly.sed < polygon.prep > ${F_MAPELEMENTS}fixed_polygon.xy
    cleanup ./polygon.prep ./fixpoly.sed
    POLYGONAOI=$(abs_path ${F_MAPELEMENTS}fixed_polygon.xy)
  fi




  # Create some template (empty) maps to get basic info about the map itself
  # Determine the range of projected coordinates for the bounding box and save them
  # DEFINE BSTRING

  if [[ $PLOTTITLE == "" ]]; then
    TITLE=""
  else
    TITLE="+t\"${PLOTTITLE}\""
  fi



  # We allow GMT to decide where to place the lon/lat labels, but we still
  # need to set the number of decimal places manually based on the AOI.

  # Number of desired ticks is ~6
  GRIDSPX=$(echo "($MAXLON - $MINLON)/${TICK_NUMBER}" | bc -l)
  # Number of desired ticks is ~6
  GRIDSPY=$(echo "($MAXLAT - $MINLAT)/${TICK_NUMBER}" | bc -l)

  # Take the lower of the two numbers
  GRIDSP=$(echo $GRIDSPX $GRIDSPY | gawk '{print ($1<$2)?$1:$2}')

  if [[ $overridegridlinespacing -eq 1 ]]; then
    GRIDSP=$OVERRIDEGRID
    info_msg "Override spacing of map grid is $GRIDSP"
  fi

  info_msg "Initial grid spacing = $GRIDSP"
  MAP_FORMAT_FLOAT_OUT='%.0f'
  if [[ $(echo "$GRIDSP > 30" | bc) -eq 1 ]]; then
    GRIDSP=30
    MAP_FORMAT_FLOAT_OUT='%.0f'
  elif [[ $(echo "$GRIDSP > 10" | bc) -eq 1 ]]; then
    GRIDSP=10
    MAP_FORMAT_FLOAT_OUT='%.0f'
  elif [[ $(echo "$GRIDSP > 5" | bc) -eq 1 ]]; then
  	GRIDSP=5
    MAP_FORMAT_FLOAT_OUT='%.0f'
  elif [[ $(echo "$GRIDSP > 2" | bc) -eq 1 ]]; then
  	GRIDSP=2
    MAP_FORMAT_FLOAT_OUT='%.0f'
  elif [[ $(echo "$GRIDSP > 1" | bc) -eq 1 ]]; then
  	GRIDSP=1
    MAP_FORMAT_FLOAT_OUT='%.0f'
  elif [[ $(echo "$GRIDSP > 0.5" | bc) -eq 1 ]]; then
  	GRIDSP=0.5
    MAP_FORMAT_FLOAT_OUT='%.1f'
  elif [[ $(echo "$GRIDSP > 0.2" | bc) -eq 1 ]]; then
  	GRIDSP=0.2
    MAP_FORMAT_FLOAT_OUT='%.1f'
  elif [[ $(echo "$GRIDSP > 0.1" | bc) -eq 1 ]]; then
  	GRIDSP=0.1
    MAP_FORMAT_FLOAT_OUT='%.1f'
  elif [[ $(echo "$GRIDSP > 0.05" | bc) -eq 1 ]]; then
    GRIDSP=0.05
    MAP_FORMAT_FLOAT_OUT='%.2f'
  elif [[ $(echo "$GRIDSP > 0.02" | bc) -eq 1 ]]; then
    GRIDSP=0.02
    MAP_FORMAT_FLOAT_OUT='%.2f'
  elif [[ $(echo "$GRIDSP > 0.01" | bc) -eq 1 ]]; then
    GRIDSP=0.01
    MAP_FORMAT_FLOAT_OUT='%.2f'
  else
  	GRIDSP=0.005
    MAP_FORMAT_FLOAT_OUT='%.3f'
  fi

  # info_msg "Grid spacing is $GRIDSP and decimal place code is ${MAP_FORMAT_FLOAT_OUT}"

  if [[ $overridegridlinespacing -eq 1 ]]; then
    GRIDSP=$OVERRIDEGRID
    info_msg "Override spacing of map grid is $GRIDSP"
  else
    GRIDSP="a"
  fi

  if [[ $usecustombflag -eq 0 ]]; then
    bcmds+=("-Bx${GRIDSP}")
    bcmds+=("-By${GRIDSP}")
    bcmds+=("-B${GRIDCALL}")
    # bcmds+=("-B${GRIDCALL}${TITLE}")
    BSTRING=("${bcmds[@]}")
    # echo ${BSTRING[@]}
  fi

  if [[ $plottitleflag -eq 1 ]]; then
    gmt psbasemap ${RJSTRING} "${BSTRING[@]}" $VERBOSE -K > base_fake.ps
    gmt psbasemap "-B+t\"${PLOTTITLE}\"" -R -J $VERBOSE -O >> base_fake.ps
  else
    gmt psbasemap ${RJSTRING} "${BSTRING[@]}" $VERBOSE > base_fake.ps
  fi

  # Turn of the axis labels and make a map, then read its dimensions from the PS file
  # directly. Units are in points, so we multiply by 2.54in/72pts to get inches

  gmt psbasemap ${RJSTRING} $VERBOSE -Btlbr > base_fake_nolabels.ps

  PROJDIM=($(grep GMTBoundingBox base_fake_nolabels.ps | gawk '{print $4/72*2.54, $5/72*2.54}'))

  # XYRANGE=($(xy_range ${F_MAPELEMENTS}projbounds.txt))
  XYRANGE[0]=0
  XYRANGE[1]=${PROJDIM[0]}
  XYRANGE[2]=0
  XYRANGE[3]=${PROJDIM[1]}

  echo ${XYRANGE[@]} > ${F_MAPELEMENTS}projxyrange.txt

  MINPROJ_X=0
  MAXPROJ_X=${PROJDIM[0]}
  MINPROJ_Y=0
  MAXPROJ_Y=${PROJDIM[1]}

  # Here I have replaced the bounding box size estimation with a direct reading of the PS
  # file GMTBoundingBox for the label-free map. This seems to work for oblique projections.

  # Could it possibly fail if the bounding box is weird? I guess!

  # XYRANGE=($(xy_range ${F_MAPELEMENTS}projbounds.txt))
  # echo ${XYRANGE[@]} > ${F_MAPELEMENTS}projxyrange.txt
  #
  # MINPROJ_X=${XYRANGE[0]}
  # MAXPROJ_X=${XYRANGE[1]}
  # MINPROJ_Y=${XYRANGE[2]}
  # MAXPROJ_Y=${XYRANGE[3]}

  gawk -v minlon=${XYRANGE[0]} -v maxlon=${XYRANGE[1]} -v minlat=${XYRANGE[2]} -v maxlat=${XYRANGE[3]} '
  BEGIN {
      row[1]="AFKPU"
      row[2]="BGLQV"
      row[3]="CHMRW"
      row[4]="DINSX"
      row[5]="EJOTY"
      difflat=maxlat-minlat
      difflon=maxlon-minlon

      newdifflon=difflon*8/10
      newminlon=minlon+difflon*1/10
      newmaxlon=maxlon-difflon*1/10

      newdifflat=difflat*8/10
      newminlat=minlat+difflat*1/10
      newmaxlat=maxlat-difflat*1/10

      minlon=newminlon
      maxlon=newmaxlon
      minlat=newminlat
      maxlat=newmaxlat
      difflat=newdifflat
      difflon=newdifflon

      for(i=1;i<=5;i++) {
        for(j=1; j<=5; j++) {
          char=toupper(substr(row[i],j,1))
          lats[char]=minlat+(i-1)/4*difflat
          lons[char]=minlon+(j-1)/4*difflon
          print lons[char], lats[char], char
        }
      }
  }' > ${F_MAPELEMENTS}aprof_database_proj.txt

  # Project aprof_database.txt back to geographic coordinates and rearrange
  gmt mapproject ${F_MAPELEMENTS}aprof_database_proj.txt ${RJSTRING} -I ${VERBOSE} | tr '\t' ' ' | gawk '($1!="NaN"){print}' > ${F_MAPELEMENTS}aprof_database.txt

  ################################################################################
  ##### Check if the reference point is within the data frame

  if [[ $REFPTLAT == "" || $REFPTLON == "" ]]; then
    info_msg "Reference point $REFPTLON $REFPTLAT undefined. Moving to center of frame."
  	REFPTLAT=$(echo "($MINLAT + $MAXLAT) / 2" | bc -l)
  	REFPTLON=$(echo "($MINLON + $MAXLON) / 2" | bc -l)
  fi
  if [[ $(echo "$REFPTLAT > $MINLAT && $REFPTLAT < $MAXLAT && $REFPTLON < $MAXLON && $REFPTLON > $MINLON" | bc -l) -eq 0 ]]; then
    info_msg "Reference point $REFPTLON $REFPTLAT falls outside the frame. Moving to center of frame."
  	REFPTLAT=$(echo "($MINLAT + $MAXLAT) / 2" | bc -l)
  	REFPTLON=$(echo "($MINLON + $MAXLON) / 2" | bc -l)
  fi


  # If grid isn't explicitly turned on but is also not turned off, add it to plots
  for plot in ${plots[@]}; do
    [[ $plot == "graticule" ]] && gridisonflag=1
  done

  if [[ $dontplotgridflag -eq 0 && $gridisonflag -eq 0 ]]; then
    plots+=("graticule")
  fi

  # Add the inset on top of everything else so the grid won't ever cover it
  if [[ $addinsetplotflag -eq 1 ]]; then
    plots+=("inset")
  fi

  info_msg ">>>>>>>>> Plotting order is ${plots[@]} <<<<<<<<<<<<<"
  info_msg ">>>>>>>>> Legend order is ${legendwords[@]} <<<<<<<<<<<<<"

fi # if [[ $BOOKKEEPINGFLAG -eq 1 ]]; then

#### END OF BOOKKEEPING SECTION




#### BEGIN DATA PROCESSING SECTION

if [[ $DATAPROCESSINGFLAG -eq 1 ]]; then

  # GRAVITY CLIP

  if [[ $clipgravflag -eq 1 ]]; then
    gmt grdcut $GRAVDATA -G${F_GRAV}grav.nc -R -J $VERBOSE
  fi

  ################################################################################
  #####         Download imagery from tiles.maps.eox.at                      #####
  ################################################################################


  if [[ $sentineldownloadflag -eq 1 ]]; then



    SENT_RES=4096
    LONDIFF=$(echo "${MAXLON} - ${MINLON}" | bc -l)
    LATDIFF=$(echo "${MAXLAT} - ${MINLAT}" | bc -l)

    if [[ $(echo "${LATDIFF} > ${LONDIFF}" | bc) -eq 1 ]]; then
      # Taller than wide
      SENT_YRES=$SENT_RES
      SENT_XRES=$(echo $SENT_RES ${LATDIFF} ${LONDIFF} | gawk '
        {
          printf("%d", $1*$3/$2)
        }
        ')
    else
      # Wider than tall
      SENT_XRES=$SENT_RES
      SENT_YRES=$(echo $SENT_RES ${LATDIFF} ${LONDIFF} | gawk '
        {
          printf("%d", $1*$2/$3)
        }
        ')
    fi

    SENT_FNAME="sentinel_${SENTINEL_TYPE}_${MINLON}_${MAXLON}_${MINLAT}_${MAXLAT}_${SENT_XRES}_${SENT_YRES}.jpg"
    SENT_TFWNAME="sentinel_${SENTINEL_TYPE}_${MINLON}_${MAXLON}_${MINLAT}_${MAXLAT}_${SENT_XRES}_${SENT_YRES}.jgw"

    if ! [[ -d ${SENT_DIR} ]]; then
      mkdir -p ${SENT_DIR}
    fi

    if [[ -e ${SENT_DIR}${SENT_FNAME} ]]; then
      info_msg "Sentinel imagery $SENT_FNAME exists. Not redownloading."
      cp ${SENT_DIR}${SENT_FNAME} sentinel_img.jpg
      cp ${SENT_DIR}${SENT_TFWNAME} sentinel_img.jgw
    else

      echo "getting image for ${MINLON} ${MAXLAT} ${MAXLON} ${MINLAT}"
      curl "https://tiles.maps.eox.at/wms?service=wms&request=getmap&version=1.1.1&layers=${SENTINEL_TYPE}&bbox=${MINLON},${MINLAT},${MAXLON},${MAXLAT}&width=$SENT_XRES&height=$SENT_YRES&srs=epsg:4326" > sentinel_img.jpg

      # gdal_translate -of GTiff -outsize $SENT_XRES $SENT_YRES "WMS:https://tiles.maps.eox.at/?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&LAYERS=${SENTINEL_TYPE}&SRS=EPSG:4326&BBOX=-${MINLON},${MINLAT},${MAXLON},${MAXLAT}" setntry.tif

      # Create world file for JPG
      echo "$LONDIFF / $SENT_XRES" | bc -l > sentinel_img.jgw
      echo "0" >> sentinel_img.jgw
      echo "0" >> sentinel_img.jgw
      echo "- (${LATDIFF}) / $SENT_YRES" | bc -l >> sentinel_img.jgw
      echo "$MINLON" >> sentinel_img.jgw
      echo "$MAXLAT" >> sentinel_img.jgw

      # gmt convert
      # echo gdal_translate -projwin ${MINLON} ${MAXLAT} ${MAXLON} ${MINLAT} -of GTiff sentinel_img.jpg sentinel_img.jpg
      # gdal_translate -projwin ${MINLON} ${MAXLAT} ${MAXLON} ${MINLAT} -of GTiff sentinel_img.jpg sentinel_img.jpg
      cp sentinel_img.jpg ${SENT_DIR}${SENT_FNAME}
      cp sentinel_img.jgw ${SENT_DIR}${SENT_TFWNAME}
    fi

    echo $SENTINEL_SOURCESTRING >> ${LONGSOURCES}
    echo $SENTINEL_SHORT_SOURCESTRING >> ${SHORTSOURCES}

  fi

  ################################################################################
  #####          Manage SLAB2 data                                           #####
  ################################################################################

  if [[ $plotslab2 -eq 1 ]]; then

    numslab2inregion=0
    echo $CENTERLON $CENTERLAT > inpoint.file
    cleanup inpoint.file

    # Select the slab2 models to examine if requested; otherwise do all
    if [[ $slab2selectflag -eq 1 ]]; then
      for thisselect in ${SLAB2SELECT[@]}; do
        slabclist+=($(ls -1a ${SLAB2_CLIPDIR}${thisselect}*.csv))
      done
    else
      slabclist=($(ls -1a ${SLAB2_CLIPDIR}*.csv))
    fi

    # slabindex=0
    gmt_init_tmpdir

      for slabcfile in ${slabclist[@]}; do
        numinregion=$(gmt select ${slabcfile} -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} ${VERBOSE} -fg | wc -l)
        # If we found one or more points, then add the to the slab2inregion array
        if [[ $(echo "${numinregion} >= 1" | bc -l) -eq 1 ]]; then
          numslab2inregion=$(echo "$numslab2inregion+1" | bc)
          slab2inregion[$numslab2inregion]=$(basename -s .csv $slabcfile)
        else
          # # If the slab wasn't selected above, try another approach
          # # This is intended to select slabs when the view is so close that we don't
          # # encompass any of the edge points. But it is breaking for some reason, likely
          # # due to projection issues or longitude range issues
          numinregion=$(gmt select inpoint.file -F${slabcfile} -fg ${VERBOSE} | wc -l)
          if [[ $numinregion -eq 1 ]]; then
            numslab2inregion=$(echo "$numslab2inregion+1" | bc)
            slab2inregion[$numslab2inregion]=$(basename -s .csv $slabcfile)
          fi
        fi
      done
    gmt_remove_tmpdir

    if [[ $numslab2inregion -eq 0 ]]; then
      info_msg "[-b]: No slabs within AOI"
    else
      for i in $(seq 1 $numslab2inregion); do
        info_msg "[-b]: Found slab2 slab ${slab2inregion[$i]}"
        thisslabid=$(echo ${slab2inregion[i]} | cut -f 1 -d '_')
        echo ${thisslabid} > ${F_SLAB}"slab_ids.txt"
      done
    fi
  fi



  # for slabcfile in $(ls -1a ${SLAB2_CLIPDIR}*.csv); do
  #   # echo "Looking at file $slabcfile"
  #   gawk < $slabcfile '{
  #     if ($1 > 180) {
  #       print $1-360, $2
  #     } else {
  #       print $1, $2
  #     }
  #   }' > tmpslabfile.dat
  #   numinregion=$(gmt select inpoint.file -Ftmpslabfile.dat ${VERBOSE} | wc -l)
  #   if [[ $numinregion -ge 1 ]]; then
  #     numslab2inregion=$(echo "$numslab2inregion+1" | bc)
  #     slab2inregion[$numslab2inregion]=$(basename -s .csv $slabcfile)
  #   fi
  # done

  #     ((slabindex++))
  #     echo $slabcfile
  #     gawk < $slabcfile '
  #       BEGIN {
  #         found_m180=0
  #         found_180=0
  #         getline
  #         if ($1 > 180) {
  #           $1=$1-360
  #         }
  #         minlon=$1
  #         maxlon=$1
  #         minlat=$2
  #         maxlat=$2
  #         maxneglon=-180
  #         minposlon=180
  #         lon[NR]=$1
  #         lat[NR]=$1
  #       }
  #       {
  #         if ($1 > 180) {
  #           $1=$1-360
  #         }
  #         minlon=($1<minlon)?$1:minlon
  #         maxlon=($1>maxlon)?$1:maxlon
  #         minlat=($2<minlat)?$2:minlat
  #         maxlat=($2>maxlat)?$2:maxlat
  #         maxneglon=($1>maxneglon && $1<=0)?$1:maxneglon
  #         minposlon=($1<minposlon && $1>=0)?$1:minposlon
  #
  #         foundlon[$1]=1
  #         lon[NR]=$1
  #         lat[NR]=$2
  #       }
  #       END {
  #
  #         # print "minlon/maxlon/minlat/maxlat", minlon, maxlon, minlat, maxlat > "/dev/stderr"
  #         # print "maxneglon/minposlon", maxneglon, minposlon > "/dev/stderr"
  #         if (maxneglon < -140 && minposlon > 140) {
  # #            print "Detected non-global longitude range crossing antimeridian"  > "/dev/stderr"
  #             adjustlon=1
  #             maxneglon+=360
  #         } else {
  # #          print "Detected reasonable longitude range"  > "/dev/stderr"
  #         }
  #
  #       }
  #       END {
  #         for(i=1;i<=NR;i++) {
  #           if (lon[i]<0) {
  #             print lon[i]+adjustlon*360, lat[i]
  #           } else {
  #             print lon[i], lat[i]
  #           }
  #         }
  #       }' > new_tmpslabfile_${slabindex}.dat
  #
  #     # Count the number of points within the processed slab file within region
      # echo gmt select new_tmpslabfile_${slabindex}.dat -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} ${VERBOSE}
      # numinregion=$(gmt select new_tmpslabfile_${slabindex}.dat -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} ${VERBOSE} | wc -l)
      # echo gmt select ${slabcfile} -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} ${VERBOSE}



  ################################################################################
  #####          Manage topography/bathymetry data                           #####
  ################################################################################

  # We have to manage several cases:

  # GMRT: Download and manage GMRT tiles
  # BEST: Get GMRT/01s tiles and merge ourselves
  # GMT online datasets: download but let GMT manage them
  # Built-in tectoplot datasets: GEBCO20, GEBCO1, SRTM30, etc: Just use
  # Custom datasets: Just use

  # For each dataset, we automatically save a clipped version of the dataset in
  # order to minimize the time for re-plotting and to allow calculations to be
  # run (e.g. hillshading and advanced topo visualizations) on subsets of very
  # large DEMS (e.g. GEBCO20)

  # Change to use DEM_MAXLON and allow -tclip to set, to avoid downloading too much data
  # when we are clipping the DEM anyway.

  # DEM_MINLON=${MINLON}
  # DEM_MAXLON=${MAXLON}
  # DEM_MINLAT=${MINLAT}
  # DEM_MAXLAT=${MAXLAT}

  if [[ $DEM_MINLON =~ "unset" ]]; then
    DEM_MINLON=$(echo "${MINLON} ${DEM_LONBUFFER}" | gawk '{print $1-$2}')
    DEM_MAXLON=$(echo "${MAXLON} ${DEM_LONBUFFER}" | gawk '{print $1+$2}')
    DEM_MINLAT=$(echo "${MINLAT} ${DEM_LATBUFFER}" | gawk '{print ($1-$2)>=-90?$1:$1-$2}')
    DEM_MAXLAT=$(echo "${MAXLAT} ${DEM_LATBUFFER}" | gawk '{print ($1+$2)<=90?$1:$1+$2}')
  fi

  if [[ $plottopo -eq 1 ]]; then

    # Check if we are plotting best quality topography and look for a merged tile with the DEM AOI
    if [[ $besttopoflag -eq 1 ]]; then
      if [[ ! -d ${BESTDIR} ]]; then
        info_msg "Creating BEST topo directory ${BESTDIR}"
        mkdir -p ${BESTDIR}
      fi
      bestname=$BESTDIR"best_${DEM_MINLON}_${DEM_MAXLON}_${DEM_MINLAT}_${DEM_MAXLAT}.tif"
      if [[ -e $bestname ]]; then
        info_msg "Best merged topography tile already exists."
        cp $bestname ${F_TOPO}dem.tif
        BATHY=${F_TOPO}dem.tif
        bestexistsflag=1
        demiscutflag=1
      fi
    fi

    # We manage GMRT tiling ourselves
    # If we are plotting GMRT data, either alone or as BEST, then...

    # Don't we want to just download the whole area given the size of GMRT data anywaY?

    if [[ $BATHYMETRY =~ "GMRT" || $besttopoflag -eq 1 && $bestexistsflag -eq 0 ]]; then
      name=$GMRTDIR"GMRT_${DEM_MINLON}_${DEM_MAXLON}_${DEM_MINLAT}_${DEM_MAXLAT}.tif"

      if [[ ! -d ${GMRTDIR} ]]; then
        mkdir -p ${GMRTDIR}
      fi

      if [[ ! -s ${name} ]]; then
        info_msg "Downloading GMRT_${DEM_MINLON}_${DEM_MAXLON}_${DEM_MINLAT}_${DEM_MAXLAT}.tif"
        curl "https://www.gmrt.org:443/services/GridServer?minlongitude=${DEM_MINLON}&maxlongitude=${DEM_MAXLON}&minlatitude=${DEM_MINLAT}&maxlatitude=${DEM_MAXLAT}&format=geotiff&resolution=max&layer=topo" > $GMRTDIR"GMRT_${DEM_MINLON}_${DEM_MAXLON}_${DEM_MINLAT}_${DEM_MAXLAT}.tif"
        # gmt grdsample -T $GMRTDIR"GMRT_${DEM_MINLON}_${DEM_MAXLON}_${DEM_MINLAT}_${DEM_MAXLAT}.tif"
      else
        info_msg "GMRT data file ${name} already exists."
      fi
    fi

    #
    # # I'm amazed that this logic expression works...
    # if [[ $BATHYMETRY =~ "GMRT" || $besttopoflag -eq 1 && $bestexistsflag -eq 0 ]]; then
    #
    #   minlon360=$(echo $DEM_MINLON | gawk  '{ if ($1<0) {print $1+360} else {print $1} }')
    #   maxlon360=$(echo $DEM_MAXLON | gawk  '{ if ($1<0) {print $1+360} else {print $1} }')
    #
    #   minlonfloor=$(echo $minlon360 | cut -f1 -d".")
    #   maxlonfloor=$(echo $maxlon360 | cut -f1 -d".")
    #
    #   if [[ $(echo "$DEM_MINLAT < 0" | bc -l) -eq 1 ]]; then
    #     minlatfloor1=$(echo $DEM_MINLAT | cut -f1 -d".")
    #     minlatfloor=$(echo "$minlatfloor1 - 1" | bc)
    #   else
    #     minlatfloor=$(echo $DEM_MINLAT | cut -f1 -d".")
    #   fi
    #
    #   maxlatfloor=$(echo $DEM_MAXLAT | cut -f1 -d".")
    #   maxlatceil=$(echo "$maxlatfloor + 1" | bc)
    #   maxlonceil=$(echo "$maxlonfloor + 1" | bc)
    #
    #   if [[ $(echo "$minlonfloor > 180" | bc) -eq 1 ]]; then
    #     minlonfloor=$(echo "$minlonfloor-360" | bc -l)
    #   fi
    #   if [[ $(echo "$maxlonfloor > 180" | bc) -eq 1 ]]; then
    #     maxlonfloor=$(echo "$maxlonfloor-360" | bc -l)
    #     maxlonceil=$(echo "$maxlonfloor + 1" | bc)
    #   fi
    #
    #   if [[ ! -d $GMRTDIR ]]; then
    #     info_msg "Making GMRT directory ${GMRTDIR}"
    #     mkdir -p $GMRTDIR
    #   fi
    #
    #   # How many tiles is this?
    #   GMRTTILENUM=$(echo "($maxlonfloor - $minlonfloor + 1) * ($maxlatfloor - $minlatfloor + 1)" | bc)
    #   tilecount=1
    #   for i in $(seq $minlonfloor $maxlonfloor); do
    #     for j in $(seq $minlatfloor $maxlatfloor); do
    #       iplus=$(echo "$i + 1" | bc)
    #       jplus=$(echo "$j + 1" | bc)
    #       if [[ ! -e $GMRTDIR"GMRT_${i}_${iplus}_${j}_${jplus}.tif" ]]; then
    #
    #         info_msg "Downloading GMRT_${i}_${iplus}_${j}_${jplus}.tif ($tilecount out of $GMRTTILENUM)"
    #         curl "https://www.gmrt.org:443/services/GridServer?minlongitude=${i}&maxlongitude=${iplus}&minlatitude=${j}&maxlatitude=${jplus}&format=geotiff&resolution=max&layer=topo" > $GMRTDIR"GMRT_${i}_${iplus}_${j}_${jplus}.tif"
    #
    #         # Test whether the file was correctly downloaded
    #         fsize=$(wc -c < $GMRTDIR"GMRT_${i}_${iplus}_${j}_${jplus}.tif")
    #         if [[ $(echo "$fsize < 12000000" | bc) -eq 1 ]]; then
    #           info_msg "File GMRT_${i}_${iplus}_${j}_${jplus}.tif was not properly downloaded: too small ($fsize bytes). Removing."
    #           rm -f $GMRTDIR"GMRT_${i}_${iplus}_${j}_${jplus}.tif"
    #         fi
    #
    #       else
    #         info_msg "File GMRT_${i}_${iplus}_${j}_${jplus}.tif exists ($tilecount out of $GMRTTILENUM)"
    #       fi
    #       filelist+=($GMRTDIR"GMRT_${i}_${iplus}_${j}_${jplus}.tif")
    #       tilecount=$(echo "$tilecount + 1" | bc)
    #     done
    #   done
    #
    #   # We apparently need to fill NaNs when making the GMRT mosaic grid with gdal_merge.py...
    #   if [[ ! -e $GMRTDIR"GMRT_${minlonfloor}_${maxlonceil}_${minlatfloor}_${maxlatceil}.tif" ]]; then
    #     info_msg "Merging tiles to form GMRT_${minlonfloor}_${maxlonceil}_${minlatfloor}_${maxlatceil}.tif: " ${filelist[@]}
    #     echo gdal_merge.py -o tmp.tif -of "GTiff" ${filelist[@]} -q > ./merge.sh
    #     echo gdal_fillnodata.py  -of GTiff tmp.tif $GMRTDIR"GMRT_${minlonfloor}_${maxlonceil}_${minlatfloor}_${maxlatceil}.tif" >> ./merge.sh
    #     # echo rm -f ./tmp.tif >> ./merge.sh
    #     . ./merge.sh
    #     # gdal_merge.py -o $GMRTDIR"GMRT_${minlonfloor}_${maxlonceil}_${minlatfloor}_${maxlatceil}.nc" ${filelist[@]}
    #
    #   else
    #     info_msg "GMRT_${minlonfloor}_${maxlonceil}_${minlatfloor}_${maxlatceil}.tif exists"
    #   fi
      # name=$GMRTDIR"GMRT_${minlonfloor}_${maxlonceil}_${minlatfloor}_${maxlatceil}.tif"

      if [[ $BATHYMETRY =~ "GMRT" ]]; then
        # We have to cut GMRT to our -R domain or else our downloaded tiles will bug out
        # in subsequent grdimage commands for some reason
        BATHY=$name
        gmt grdcut ${BATHY} -G${F_TOPO}dem.tif -R${DEM_MINLON}/${DEM_MAXLON}/${DEM_MINLAT}/${DEM_MAXLAT} $VERBOSE
        clipdemflag=0
        name=${F_TOPO}dem.tif
        TOPOGRAPHY_DATA=${F_TOPO}dem.tif
      elif [[ $besttopoflag -eq 1 && $bestexistsflag -eq 0 ]]; then
        # If we are making BEST bathymetry, the negative elevations are equivalent to the GMRT tile
        gmt grdcut ${name} -G${F_TOPO}negbathy.tif -R${DEM_MINLON}/${DEM_MAXLON}/${DEM_MINLAT}/${DEM_MAXLAT} $VERBOSE
        NEGBATHYGRID=${F_TOPO}negbathy.tif
      fi
    # fi


    # If we are NOT using GMRT data, either alone or in BEST mode
    if [[ ! $BATHYMETRY =~ "GMRT" && $bestexistsflag -eq 0 ]]; then

      # We have specified a custom topo file
      if [[ $plotcustomtopo -eq 1 ]]; then
    #     info_msg "[-t]: Using custom topography file ${GRIDFILE}"
        if [[ $reprojecttopoflag -eq 1 ]]; then
          info_msg "[-t]: reprojecting source file to WGS1984"
          gdalwarp ${GRIDFILE} ${F_TOPO}custom_wgs.tif -te ${DEM_MINLON} ${DEM_MINLAT} ${DEM_MAXLON} ${DEM_MAXLAT} -of "GTiff" -et 2 -t_srs "+proj=longlat +ellps=WGS84"
          GRIDFILE=$(abs_path ${F_TOPO}custom_wgs.tif)
        fi
    #   # gmt grdcut sometimes does strange things with DEMs
    #   # Probably need some logic here to not use -projwin for some rasters...
    #     echo "gdal_translate -q -of "NetCDF" -projwin ${DEM_MINLON} ${DEM_MAXLAT} ${DEM_MAXLON} ${DEM_MINLAT} ${GRIDFILE} ${F_TOPO}dem.tif"
    #     gdal_translate -q -of "NetCDF" -projwin ${DEM_MINLON} ${DEM_MAXLAT} ${DEM_MAXLON} ${DEM_MINLAT} ${GRIDFILE} ${F_TOPO}dem.tif
    #     GRDINFO=($(gmt grdinfo -C ${F_TOPO}dem.tif ${VERBOSE}))
    #     DEM_MINLON=${GRDINFO[1]}
    #     DEM_MAXLON=${GRDINFO[2]}
    #     DEM_MINLAT=${GRDINFO[3]}
    #     DEM_MAXLAT=${GRDINFO[4]}
    #     BATHY=${F_TOPO}dem.tif
    #     TOPOGRAPHY_DATA=${F_TOPO}dem.tif
        BATHYMETRY="custom_$(basename ${GRIDFILE})"
        # gmt grdcut ${GRIDFILE} -G${BATHYMETRY} -R${DEM_MINLON}/${DEM_MAXLON}/${DEM_MINLAT}/${DEM_MAXLAT} $VERBOSE
        gmt grdcut ${GRIDFILE} -G${BATHYMETRY} -R${DEM_MINLON}/${DEM_MAXLON}/${DEM_MINLAT}/${DEM_MAXLAT} $VERBOSE
        # We should have a different way of marking these types of files by basename
      fi

      # We have not specified a custom topo file. GRIDDIR is the destination directory for tiles
      # and BATHYMETRY contains the code for the data type

      info_msg "[-t]: Using grid file $GRIDFILE"

      if [[ $BATHYMETRY == "auto" ]]; then
        projection=$(echo "${RJSTRING}" | gawk '{print $(NF)}')
        res=$(gmt grdcut ${EARTHRELIEFPREFIX} -D+t -R${DEM_MINLON}/${DEM_MAXLON}/${DEM_MINLAT}/${DEM_MAXLAT} ${projection} --GMT_GRAPHICS_DPU=${TOPO_DPI} -Vq | gawk -F/ '{print $(NF)}')

        case $res in
          01d|30m|20m|15m|10m|06m|05m|04m|03m|02m|01m|30s|15s|03s|01s)
            BATHYMETRY=$res
          ;;
          *)
            BATHYMETRY=10m
          ;;
        esac
        GRIDFILE=${EARTHRELIEFPREFIX}_${BATHYMETRY}
        info_msg "[-t]: auto resolution was determined to be ${BATHYMETRY}"
      fi

      # BIG CHANGE: NOW STORING TILES AS GEOTIFF due to some issues with NetCDF files 
    	name=${GRIDDIR}"${EARTHRELIEFPREFIX}_${BATHYMETRY}_${DEM_MINLON}_${DEM_MAXLON}_${DEM_MINLAT}_${DEM_MAXLAT}.tif"

    	if [[ -s $name ]]; then
    		info_msg "DEM file $name already exists"
        demiscutflag=1
      else

        case $BATHYMETRY in
          01d|30m|20m|15m|10m|06m|05m|04m|03m|02m|01m|30s|15s|03s|01s)
            name="${GRIDDIR}${EARTHRELIEFPREFIX}_${BATHYMETRY}_${DEM_MINLON}_${DEM_MAXLON}_${DEM_MINLAT}_${DEM_MAXLAT}.tif"

            if [[ ${BATHYMETRY} == "15s" ]]; then
              gmt grdcut ${GRIDFILE}_p -G${name}=gd:GTiff -R${DEM_MINLON}/${DEM_MAXLON}/${DEM_MINLAT}/${DEM_MAXLAT}
            else
              gmt grdcut ${GRIDFILE}_g -G${name}=gd:GTiff -R${DEM_MINLON}/${DEM_MAXLON}/${DEM_MINLAT}/${DEM_MAXLAT}
            fi

            if [[ $? != 0 ]]; then
              rm -f ${name}
            fi
            if [[ ! -s ${name} ]]; then
              echo "[-t]: Could not extract GMT online EarthRelief dataset ${BATHYMETRY}. Using 15s instead."
              GRIDDIR=$EARTHRELIEFDIR
              GRIDFILE=${EARTHRELIEFPREFIX}_15s
              # BIG CHANGE: NOW STORING TILES AS GEOTIFF
            	name=${GRIDDIR}${EARTHRELIEFPREFIX}_"15s_${DEM_MINLON}_${DEM_MAXLON}_${DEM_MINLAT}_${DEM_MAXLAT}.tif"

              if [[ ! -s ${name} ]]; then
                gmt grdcut ${GRIDFILE}_p -G${name}=gd:GTiff -R${DEM_MINLON}/${DEM_MAXLON}/${DEM_MINLAT}/${DEM_MAXLAT} -Vq
              fi
            fi

            cp ${name} ${F_TOPO}dem.tif
            clipdemflag=0
            name=${F_TOPO}dem.tif
            TOPOGRAPHY_DATA=${F_TOPO}dem.tif
          ;;
          SRTM15|SRTM30|GEBCO20|GEBCO1)
          # GMT grdcut works on these rasters, including across the dateline
            gmt grdcut ${GRIDFILE} -G${name}=gd:GTiff -R${DEM_MINLON}/${DEM_MAXLON}/${DEM_MINLAT}/${DEM_MAXLAT} $VERBOSE
            cp ${name} ${F_TOPO}dem.tif
            clipdemflag=0
            name=${F_TOPO}dem.tif
            TOPOGRAPHY_DATA=${F_TOPO}dem.tif
          ;;
          GEBCO21)
            gdal_translate -q -of "GTiff" -projwin ${DEM_MINLON} ${DEM_MAXLAT} ${DEM_MAXLON} ${DEM_MINLAT} ${GRIDFILE} ${name}
            # gmt grdcut ${GRIDFILE} -G${name} -R${DEM_MINLON}/${DEM_MAXLON}/${DEM_MINLAT}/${DEM_MAXLAT} $VERBOSE
            cp ${name} ${F_TOPO}dem.tif
            clipdemflag=0
            name=${F_TOPO}dem.tif
            TOPOGRAPHY_DATA=${F_TOPO}dem.tif
          ;;
          custom*)
            # GMT grdcut works on many files but FAILS on many others... can we use gdal_translate?

            # gdal_translate -q -of "GTiff" -projwin ${DEM_MINLON} ${DEM_MAXLAT} ${DEM_MAXLON} ${DEM_MINLAT} ${GRIDFILE} cutfirst.tif
            # Assume grdcut will work with the file
            # gmt grdcut ${GRIDFILE} -G${F_TOPO}dem.tif=gd:GTiff -R${DEM_MINLON}/${DEM_MAXLON}/${DEM_MINLAT}/${DEM_MAXLAT} $VERBOSE
            # gmt grdconvert cutfirst.tif ${F_TOPO}dem.tif=gd:GTiff

            # gmt grdconvert ${GRIDFILE} ${F_TOPO}dem.tif=gd:GTiff -R${DEM_MINLON}/${DEM_MAXLON}/${DEM_MINLAT}/${DEM_MAXLAT} $VERBOSE


            gmt grdcut ${GRIDFILE} -G${F_TOPO}dem.tif -R${DEM_MINLON}/${DEM_MAXLON}/${DEM_MINLAT}/${DEM_MAXLAT} $VERBOSE
            # Just convert the whole grid to tiff?
            # gdal_translate -q -of "GTiff" -r bilinear -projwin ${DEM_MINLON} ${DEM_MAXLAT} ${DEM_MAXLON} ${DEM_MINLAT} ${GRIDFILE} ${F_TOPO}dem.tif
            # gdal_translate -q -of "GTiff" -projwin ${DEM_MINLON} ${DEM_MAXLAT} ${DEM_MAXLON} ${DEM_MINLAT} ${GRIDFILE} ${F_TOPO}dem.tif

            name=${F_TOPO}dem.tif
            clipdemflag=0
            TOPOGRAPHY_DATA=${F_TOPO}dem.tif
            # demiscutflag=1
          ;;
        esac
        demiscutflag=1
    	fi
    	BATHY=$name
    fi
  fi

  # At this point, if best topo flag is set, combine POSBATHYGRID and BATHY into one grid and make it the new BATHY grid

  if [[ $besttopoflag -eq 1 && $bestexistsflag -eq 0 ]]; then
    info_msg "Combining GMRT ($NEGBATHYGRID) and 01s ($BATHY) grids to form best topo grid"

  # # Sample grid file A (the low resolution one, if they aren't equal) to the same resolution as B (the high res version). Use grdsample for this.
  #   grdsample A.grd -R -Iresolution -Ghires_A.grd
  #
  #   # Use grdcut to make sure both have the same dimensions. Ensure that they both use the same projection.
  #   # grdcut A.grd -Rregion -Ghires_A_trimmed.grd
  #   # Use grdmask to define a polygon. This polygon will be used to replace a section of grid file A with grid file B. The NaN part is important because it defines all the values inside the polygon as being NaN, which will be replaced later with new values from grid file B. The polygon used here is a closed triangle.
  #   grdmask -Rregion -Iresolution -N1/1/NaN << END -Gclip.grd
  #   x1 y1
  #   x2 y1
  #   x2 y2
  #   x1 y1
  #   END
  #   Apply this polygon "mask" to A using grdmath. This will set all values inside the polygon to NaN, but wont touch values outside the polygon.
  #   grdmath B.grd clip.grd MUL = B_clipped.grd
  #   Finally use grdmath to combine the two files using XOR (A will replace B only where B has NaN values). This will create a merged grid file, called merged.grd. Its a somewhat complicated procedure, but very powerful.
  #   grdmath B_clipped.grd hires_A_trimmed.grd XOR = merged.grd


    # We run into a major problem if NEGBATHYGRID has longitudes like -175:-170 and BATHY has longitudes like 185:190
    # As far as I can tell, GMRT will have negative longitudes while the 01s grid will have positive ones, so fix negbathygrid
    gmt grdedit -L+p $NEGBATHYGRID

    # echo "neg"
    # gmt grdinfo $NEGBATHYGRID
    # echo "pos"
    # gmt grdinfo $BATHY
    #
    # gmt grdsample ${BATHY} -R -I0.00055555555 -Gpos.tif
    # gmt grdsample ${NEGBATHYGRID} -R -I0.00055555555 -G${F_TOPO}neg.tif

    # Is it best to resample SRTM to the BATHY resolution

    gmt_init_tmpdir

    gridres=($(gmt grdinfo -C ${BATHY} | gawk '{print $10, $11}'))
    echo ${gridres[@]}
    gdal_translate -q -of "GTiff" -outsize ${gridres[0]} ${gridres[1]} -projwin ${DEM_MINLON} ${DEM_MAXLAT} ${DEM_MAXLON} ${DEM_MINLAT} ${BATHY} ${F_TOPO}neg.tif
    # gmt grdsample ${NEGBATHYGRID} -R${BATHY} -G${F_TOPO}neg.tif=gd:GTiff
    gmt_remove_tmpdir

    # gdalwarp -q -et 0.01 -r cubic -dstnodata NaN -te $DEM_MINLON $DEM_MINLAT $DEM_MAXLON $DEM_MAXLAT -tr .00055555555 .00055555555 -of GTiff $NEGBATHYGRID ${F_TOPO}neg.tif
    # gdalwarp -q -et 0.01 -r cubic -dstnodata NaN -te $DEM_MINLON $DEM_MINLAT $DEM_MAXLON $DEM_MAXLAT -tr .00055555555 .00055555555 -of GTiff $BATHY pos.tif

    GMRT_MERGELEVEL_BOTTOM=-500
    GMRT_MERGELEVEL_TOP=0
    #
    GMRT_MERGELEVEL=-100

    # This is a straight merge with a hard line
    #gdal_calc.py --overwrite --type=Float32 --format=GTiff --quiet -A ${BATHY} -B ${F_TOPO}neg.tif --calc="((A>=${GMRT_MERGELEVEL})*A + (A<${GMRT_MERGELEVEL})*B)" --outfile=merged.tif

    # This is a linear interpolation over the defined topographic interval
    gdal_calc.py --overwrite --type=Float32 --format=GTiff --quiet -A ${BATHY} -B ${F_TOPO}neg.tif --calc="((A>${GMRT_MERGELEVEL_TOP})*A + (A<${GMRT_MERGELEVEL_BOTTOM})*B+(A>=${GMRT_MERGELEVEL_BOTTOM})*(A<=${GMRT_MERGELEVEL_TOP})*(B*(${GMRT_MERGELEVEL_TOP}-A)+A*(A - ${GMRT_MERGELEVEL_BOTTOM}))/(${GMRT_MERGELEVEL_TOP}-${GMRT_MERGELEVEL_BOTTOM}))" --outfile=merged.tif

    cp merged.tif $bestname
    # cp neggdal.tif $bestname
    BATHY=$bestname
  fi

  if [[ $tflatflag -eq 1 ]]; then
    clipdemflag=1
  fi

  # At this stage, BATHY contains a path to the DEM and can be replaced by TOPOGRAPHY_DATA

  if [[ $clipdemflag -eq 1 && -s ${BATHY} ]]; then
    info_msg "[-clipdem]: saving DEM as ${F_TOPO}dem.tif"
    if [[ $demiscutflag -eq 1 ]]; then
      if [[ $tflatflag -eq 1 ]]; then
        echo flattening
        flatten_sea ${BATHY} ${F_TOPO}dem.tif -1
      else
        # This assumes that BATHY is a tif file.
        if [[ ${BATHY} == *tif ]]; then
          if [[ ! -s ${F_TOPO}dem.tif ]]; then
            cp ${BATHY} ${F_TOPO}dem.tif
          fi
        else
          echo "${BATHY} is not a TIF file? Aborting"
          exit 1
        fi
      fi
    else
      if [[ $tflatflag -eq 1 ]]; then
        gmt grdcut ${BATHY} -G${F_TOPO}dem_preflat.tif=gd:GTiff -R${DEM_MINLON}/${DEM_MAXLON}/${DEM_MINLAT}/${DEM_MAXLAT} $VERBOSE
        flatten_sea ${F_TOPO}dem_preflat.tif ${F_TOPO}dem.tif -1
        cleanup ${F_TOPO}dem_preflat.tif
      else
        if [[ -s ${BATHY} && ! -s ${F_TOPO}dem.tif ]]; then
          gdal_translate -q -of "GTiff" -projwin ${DEM_MINLON} ${DEM_MAXLAT} ${DEM_MAXLON} ${DEM_MINLAT} ${BATHY} ${F_TOPO}dem.tif

          # In this case we may need to fill NaNs...

          # Somehow the gmt grdcut command was messing up GMRT tiles by being off by 1 pixel in X dimension...???
          # gmt grdcut ${GRIDFILE} -G${name} -R${DEM_MINLON}/${DEM_MAXLON}/${DEM_MINLAT}/${DEM_MAXLAT} $VERBOSE
          # gmt grdcut ${BATHY} -G${F_TOPO}dem.tif=gd:GTiff -N -R${DEM_MINLON}/${DEM_MAXLON}/${DEM_MINLAT}/${DEM_MAXLAT} $VERBOSE
        fi
      fi
    fi
    TOPOGRAPHY_DATA=${F_TOPO}dem.tif
  else
    TOPOGRAPHY_DATA=${BATHY}
  fi

  # Adjust the DEM if asked (setting 0 values to something else, can be useful sometimes)

  if [[ $tzeroadjustflag -eq 1 ]]; then
    gdal_calc.py --overwrite --type=Float32 --format=GTiff --quiet -A ${TOPOGRAPHY_DATA} --calc="((A<=0)*(A>=${TZEROADJUSTVAL})*${TZEROADJUSTVAL} + (A>0)*A + (A<${TZEROADJUSTVAL})*A)" --outfile=${F_TOPO}dem_zero.tif
    if [[ -s ${F_TOPO}dem_zero.tif ]]; then
      TOPOGRAPHY_DATA=${F_TOPO}dem_zero.tif
    fi
  fi

  if [[ $tdenoiseflag -eq 1 ]]; then
    demwidth=$(gmt grdinfo -C ${TOPOGRAPHY_DATA} ${VERBOSE} | gawk '{print $10}')
    demheight=$(gmt grdinfo -C ${TOPOGRAPHY_DATA} ${VERBOSE} | gawk '{print $11}')
    demxmin=$(gmt grdinfo -C ${TOPOGRAPHY_DATA} ${VERBOSE} | gawk '{print $2}')
    demxmax=$(gmt grdinfo -C ${TOPOGRAPHY_DATA} ${VERBOSE} | gawk '{print $3}')
    demymin=$(gmt grdinfo -C ${TOPOGRAPHY_DATA} ${VERBOSE} | gawk '{print $4}')
    demymax=$(gmt grdinfo -C ${TOPOGRAPHY_DATA} ${VERBOSE} | gawk '{print $5}')

    gdalwarp -t_srs EPSG:3395 -s_srs EPSG:4326 -r bilinear -if GTiff -of AAIGrid ${TOPOGRAPHY_DATA} ${F_TOPO}dem_denoise.asc -q
    ${MDENOISE} -i ${F_TOPO}dem_denoise.asc -t ${DENOISE_THRESHOLD} -n ${DENOISE_ITERS} -o ${F_TOPO}dem_denoise_DN.asc
    # using -te and -ts seems to fix errors with GMT -R and -I not matching
    gdalwarp -q -if AAIGrid -of GTiff -t_srs EPSG:4326 -s_srs EPSG:3395 -r bilinear -te $demxmin $demymin $demxmax $demymax -ts $demwidth $demheight ${F_TOPO}dem_denoise_DN.asc ${F_TOPO}dem_denoised_ddd.tif
    [[ -s ${F_TOPO}dem_denoised.tif ]] && TOPOGRAPHY_DATA=${F_TOPO}dem_denoised.tif
  fi

  ################################################################################
  #####           Manage earthquake hypocenters                              #####
  ################################################################################

  SEISDATA=${F_SEIS}eqs.txt

  if [[ $plotseis -eq 1 ]]; then
    touch ${F_SEIS}eqs.txt
    NUMEQCATS=0
    ##############################################################################
    # Initial select of seismicity based on geographic coords, mag, and depth
    # Takes into account crossing of antimeridian (e.g lon in range [120 220] or [-190 -170])

    # Data are selected from either ANSS, ISC, ISC-EHB, or custom data files
    # Tectoplot catalog eqs.txt is Lon Lat Depth Mag Timecode ID epoch clusterid


    # The ultimate goal is to end up with a single GPKG containing the
    # seismicity data that will ultimately be plotted by tectoplot.  Functions of this
    # section include:
    # - importing earthquake data from various sources, filtering out incomplete entries
    # - selecting data during import according to
    #   1. bounding box
    #   2. specified closed polygon
    # - etc

    # For now, we just extract the data from the GPKG databases into text files

    customseisindex=1

    if [[ $zareaflag -eq 1 ]]; then
      # 34.815785267353 40.500000000036 35.249999999050 38.759625502224
      # nowdate=
      # echo downloading ANSS for AOI
      # echo curl "https://earthquake.usgs.gov/fdsnws/event/1/query?format=csv&starttime=1900-01-01T00:00:00&endtime=$(date -u '+%Y-%m-%dT%H:%M:%S')&minlatitude=${MINLAT}&maxlatitude=${MAXLAT}&minlongitude=${MINLON}&maxlongitude=${MAXLON}&orderby=time-asc"
      # curl "https://earthquake.usgs.gov/fdsnws/event/1/query?format=csv&starttime=1900-01-01T00:00:00&endtime=$(date -u '+%Y-%m-%dT%H:%M:%S')&minlatitude=${MINLAT}&maxlatitude=${MAXLAT}&minlongitude=${MINLON}&maxlongitude=${MAXLON}&orderby=time-asc" > ${F_SEIS}anss_zarea.txt

      echo downloading EMSC for AOI
      curl "https://seismicportal.eu/fdsnws/event/1/query?format=json&starttime=2023-02-01T00:00:00&endtime=$(date -u '+%Y-%m-%dT%H:%M:%S')&minlatitude=${MINLAT}&maxlatitude=${MAXLAT}&minlongitude=${MINLON}&maxlongitude=${MAXLON}&orderby=time-asc" > ${F_SEIS}emsc_zarea.json
      # id,lastupdate,magtype,evtype,lon,auth,lat,depth,mag,time,source_id,source_catalog,flynn_region,unid

      ogr2ogr -f CSV ${F_SEIS}emsc_zarea.csv ${F_SEIS}emsc_zarea.json -select "lon","lat","depth","mag","time","id" -lco SEPARATOR=TAB

      gawk < ${F_SEIS}emsc_zarea.csv -F'\t' '(NR>1) { gsub(/\//,"-",$5); split($5,a,"+" ); split(a[1],b," "); $5=sprintf("%sT%s", b[1], b[2]); print $0}' >> ${F_SEIS}eqs.txt

    else
      for eqcattype in ${EQ_CATALOG_TYPE[@]}; do

        if [[ $notearthquakeflag -eq 1 ]]; then
          noteqstring="NOT "
        else
          noteqstring=""
        fi
        if [[ $timeselectflag -eq 1 ]]; then
          timeselstring="AND time <= '$ENDTIME' AND time >= '$STARTTIME'"
        else
          timeselstring=""
        fi
        magselstring="AND mag <= ${EQ_MAXMAG} AND mag >= ${EQ_MINMAG}"
        depselstring="AND Z(geom) <= ${EQCUTMAXDEPTH} AND Z(geom) >= ${EQCUTMINDEPTH}"

        if [[ $eqcattype =~ "EMSC" ]]; then
          if [[ -s ${EMSCDIR}emsc.gpkg ]]; then
            depselstring_emsc="AND ((source_catalog = 'EMSC-RTS' AND 0-Z(geom) <= ${EQCUTMAXDEPTH}) OR (source_catalog != 'EMSC-RTS' AND Z(geom) <= ${EQCUTMAXDEPTH})) AND ((source_catalog = 'EMSC-RTS' AND 0-Z(geom) >= ${EQCUTMINDEPTH}) OR (source_catalog != 'EMSC-RTS' AND Z(geom) >= ${EQCUTMINDEPTH}))"

            echo "SUBSTRING(evtype,2,1) IS ${noteqstring}'e' ${timeselstring} ${magselstring} ${depselstring_emsc}" > ogr2ogr_spat.where
            ogr2ogr_spat ${MINLON} ${MAXLON} ${MINLAT} ${MAXLAT} ${F_SEIS}emsc_selected.gpkg ${EMSCDIR}emsc.gpkg
            rm -f ogr2ogr_spat.where

            ogr2ogr -lco SEPARATOR=TAB -f "CSV" -sql @${SQLDIR}emsc_select.sql emsc_selected.csv ${F_SEIS}emsc_selected.gpkg
          
            gawk < emsc_selected.csv '
              @include "tectoplot_functions.awk"
              (NR==1) {
                if ($1!="X(geom)") {
                  print
                }
              }
              (NR>1) {
                $(NF+1) = iso8601_to_epoch($5)
                print
              }'>> ${F_SEIS}eqs.txt
          else
            echo "No EMSC GPKG file found. Delete EMSC directory and rerun -scrapedata to rebuild from scratch?"
            exit 1
          fi
          ((NUMEQCATS+=1))
          echo "${EMSC_EQ_SHORT_SOURCESTRING}" >> ${SHORTSOURCES}
          echo "${EMSC_EQ_SOURCESTRING}" >> ${LONGSOURCES}
        fi

        if [[ $eqcattype =~ "ANSS" ]]; then

          if [[ -s ${ANSSDIR}anss.gpkg ]]; then
          echo "type IS ${noteqstring}'earthquake' ${timeselstring} ${magselstring} ${depselstring}" > ogr2ogr_spat.where
          ogr2ogr_spat ${MINLON} ${MAXLON} ${MINLAT} ${MAXLAT} ${F_SEIS}anss_selected.gpkg ${ANSSDIR}anss.gpkg
          rm -f ogr2ogr_spat.where
            CPL_LOG=/dev/null ogr2ogr -lco SEPARATOR=TAB -f "CSV" -sql @${SQLDIR}anss_select.sql anss_selected.csv ${F_SEIS}anss_selected.gpkg
            gawk < anss_selected.csv '
              @include "tectoplot_functions.awk"
              (NR==1) {
                if ($1!="X(geom)") {
                  print
                }
              }
              (NR>1) {
                $(NF+1) = iso8601_to_epoch($5)
                print
              }'>> ${F_SEIS}eqs.txt
          else
            echo "No ANSS GPKG file found. Delete ANSS directory and rerun -scrapedata to rebuild from scratch?"
            exit 1
          fi
          ((NUMEQCATS+=1))
          echo "${ANSS_EQ_SHORT_SOURCESTRING}" >> ${SHORTSOURCES}
          echo "${ANSS_EQ_SOURCESTRING}" >> ${LONGSOURCES}
        fi
        if [[ $eqcattype =~ "GHEC" ]]; then
          F_SEIS_FULLPATH=$(abs_path ${F_SEIS})

          # lon, lat, depth, mag, timestring, id, epoch, type
          # type = "mw" or "ms" or "mb"
            gawk < ${GEMGHEC_DATA} -v mindepth="${EQCUTMINDEPTH}" -v maxdepth="${EQCUTMAXDEPTH}" -v minlat="$MINLAT" -v maxlat="$MAXLAT" -v minlon="$MINLON" -v maxlon="$MAXLON" -v minmag=${EQ_MINMAG} -v maxmag=${EQ_MAXMAG} -v mindate=$STARTTIME -v maxdate=$ENDTIME -v modifymagsflag=${modifymagnitudes} '
              @include "tectoplot_functions.awk"
              {
                lon=$1
                lat=$2
                depth=$3
                mag=$4
                datestring=$5

                if ((mindate <= datestring && datestring <= maxdate) && (depth >= mindepth && depth <= maxdepth) && (lat >= minlat && lat <= maxlat) && (mag >= minmag && mag <= maxmag)) {
                  if (test_lon(minlon, maxlon, lon) == 1) {
                    print
                  }
                }
              }
            ' >> ${F_SEIS}GHEC.txt
            cat ${F_SEIS}GHEC.txt >> ${F_SEIS}eqs.txt
            ((NUMEQCATS+=1))
            ((customseisindex+=1))
            echo "${GEMGHEC_SHORT_SOURCESTRING}" >> ${SHORTSOURCES}
            echo "${GEMGHEC_SOURCESTRING}" >> ${LONGSOURCES}
        fi
        if [[ $eqcattype =~ "ISC" ]]; then

          if [[ -s ${ISC_EQS_DIR}iscseis.gpkg ]]; then
            # ISC event types have 'e' in the second character position if the event is a natural earthquake
            eqselstring="SUBSTRING(type,2,1) IS ${noteqstring}'e'"
            # eqselstring="SUBSTRING(type,2,1) IS ${noteqstring}'m'"
            echo "${eqselstring} ${timeselstring} ${magselstring} ${depselstring}" > ogr2ogr_spat.where
            ogr2ogr_spat ${MINLON} ${MAXLON} ${MINLAT} ${MAXLAT} ${F_SEIS}iscseis_selected.gpkg ${ISC_EQS_DIR}iscseis.gpkg
            rm -f ogr2ogr_spat.where
            CPL_LOG=/dev/null ogr2ogr -lco SEPARATOR=TAB -f "CSV" -sql @${SQLDIR}isc_select.sql iscseis_selected.csv ${F_SEIS}iscseis_selected.gpkg
            gawk < iscseis_selected.csv '
              @include "tectoplot_functions.awk"
              (NR==1) {
                if ($1!="X(geom)") {
                  print
                }
              }
              (NR>1) {
                $(NF+1) = iso8601_to_epoch($5)
                print
              }'>> ${F_SEIS}eqs.txt
          else
            echo "No ISC seismicity GPKG file found. Delete ISC_SEIS directory and rerun -scrapedata to rebuild from scratch?"
            exit 1
          fi
          ((NUMEQCATS+=1))
          echo "${ISC_EQ_SHORT_SOURCESTRING}" >> ${SHORTSOURCES}
          echo "${ISC_EQ_SOURCESTRING}" >> ${LONGSOURCES}
        fi
        if [[ $eqcattype =~ "EHB" ]]; then

          # lon, lat, depth, mag, timestring, id, epoch, type
          # type = "mw" or "ms" or "mb"

            gawk < ${ISCEHB_DATA} -v mindepth="${EQCUTMINDEPTH}" -v maxdepth="${EQCUTMAXDEPTH}" -v minlat="$MINLAT" -v maxlat="$MAXLAT" -v minlon="$MINLON" -v maxlon="$MAXLON" -v minmag=${EQ_MINMAG} -v maxmag=${EQ_MAXMAG} -v mindate=$STARTTIME -v maxdate=$ENDTIME -v modifymagsflag=${modifymagnitudes} '
              @include "tectoplot_functions.awk"
              {
                lon=$1
                lat=$2
                depth=$3
                mag=$4
                datestring=$5
                id=$6
                epoch=$7
                type=$8


                if ((mindate <= datestring && datestring <= maxdate) && (depth >= mindepth && depth <= maxdepth) && (lat >= minlat && lat <= maxlat) && (mag >= minmag && mag <= maxmag)) {
                  if (test_lon(minlon, maxlon, lon) == 1) {

                    if (modifymagsflag==1) {
                      if (tolower(type) == "mb" && mag >= 3.5 && mag <=7.0) {
                        # ISC mb > Mw(GCMT) Weatherill, 2016
                        oldval=mag
                        $4 = 1.084 * mag - 0.142
                        print $6, type "=" oldval, "to Mw(GCMT)=", $4 >> "./mag_conversions.dat"
                      } else if (tolower(type) == "ms") {
                        # ISC Ms > Mw(GCMT) Weatherill, 2016
                        oldval=mag
                        if (mag >= 3.5 && mag <= 6.0) {
                            $4 = 0.616 * mag + 2.369
                            print $6, type "=" oldval, "to Mw(GCMT)=", $4 >> "./mag_conversions.dat"
                        } else if (mag > 6.0 && mag <= 8.0) { # Weatherill, 2016, ISC
                          $4 = 0.994 * mag + 0.1
                          print $6, type "=" oldval, "to Mw(GCMT)=", $4 >> "./mag_conversions.dat"
                        }
                      }
                    }
                    $8=""
                    print
                  }
                }
              }
            ' > ${F_SEIS}ISC_EHB_extract.cat
            cat ${F_SEIS}ISC_EHB_extract.cat >> ${F_SEIS}eqs.txt
            ((NUMEQCATS+=1))
            ((customseisindex+=1))
            echo "${ISCEHB_EQ_SHORT_SOURCESTRING}" >> ${SHORTSOURCES}
            echo "${ISCEHB_EQ_SOURCESTRING}" >> ${LONGSOURCES}
        fi
        ##############################################################################
        # Add additional user-specified seismicity files. This needs to be expanded
        # to import from various common formats. Currently needs tectoplot format data
        # and only ingests lines with 4-7 fields.

        # lon lat depth mag iso8601_time ID [epoch=iso8601 time]

    #-69.1646 -19.8668 113.23 3.977 2021-10-13T12:06:13 us6000fu7b 1634097973
    #-69.602026 -21.532711 18.254 1.3 2014-12-31T22:07:13 iquique18964 none

        if [[ $eqcattype =~ "custom" ]]; then
          info_msg "[-z]: Loading custom seismicity file ${SEISADDFILE[$customseisindex]}"
            gawk < ${SEISADDFILE[$customseisindex]} -v minlat="$MINLAT" -v maxlat="$MAXLAT" -v minlon="$MINLON" -v maxlon="$MAXLON" -v mindate=$STARTTIME -v maxdate=$ENDTIME -v mindepth=${EQCUTMINDEPTH} -v maxdepth=${EQCUTMAXDEPTH} -v minmag=${EQ_MINMAG} -v maxmag=${EQ_MAXMAG} '
              @include "tectoplot_functions.awk"
              {
                # We have at least lon lat depth mag
                if (NF >= 4) {
                  if ($5=="") {
                    $5=0
                    checkdate=0
                  } else {
                    checkdate=1
                  }

                  # If there is no ID
                  if (NF<6) {
                    $6="None"
                  }
                  # If there is no epoch
                  if (NF<7) {
                    $7="none"
                  }
                  if ($3 >= mindepth && $3 <= maxdepth && $4 <= maxmag && $4 >= minmag && $2 >= minlat && $2 <= maxlat) {
                    if (test_lon(minlon, maxlon, $1) == 1) {
                      if (checkdate==1) {
                        if (mindate <= $5 && $5 <= maxdate) {
                          if ($7=="none") {
                            $7=iso8601_to_epoch($5)
                          }
                          print $1, $2, $3, $4, $5, $6, $7
                        }
                      } else {
                        print $1, $2, $3, $4, $5, $6, $7
                      }
                    }
                  }
                }
              }' > ${F_SEIS}custom_${customseisindex}.cat
              cat ${F_SEIS}custom_${customseisindex}.cat >> ${F_SEIS}eqs.txt
            ((NUMEQCATS+=1))
            ((customseisindex+=1))
            echo "${CUSTOMEQCREDIT}" >> ${SHORTSOURCES}
            echo "Seismicity from ${SEISADDFILE[$seisfilenumber]}" >> ${LONGSOURCES}
        fi
      done
    fi

    [[ -s ./mag_conversions.dat ]] && mv ./mag_conversions.dat ${F_SEIS}
    [[ -s ./mag_selections.dat ]] && mv ./mag_selections.dat ${F_SEIS}

    if [[ -s ${F_SEIS}eqs.txt && $recenteqprintandexitflag -eq 1 ]]; then
      case ${LATESTEQSORTTYPE} in
        date)
          cat ${F_SEIS}eqs.txt | sort -n -k 5
          ;;
        mag)
          cat ${F_SEIS}eqs.txt | sort -n -k 4
          ;;
        esac
    fi

    # Select seismicity / focal mechanisms from eqlist
    # Pull the event back from the culled list if necessary
    if [[ $eqlistselectflag -eq 1 ]]; then
      echo ${eqlistarray[@]} | tr ' ' '\n' > ${F_SEIS}eqselectlist.txt
      if [[ -s ${F_SEIS}eqs.txt ]]; then
        gawk '
        NR==FNR {
          A[$1]=1 ; next
        }
        $6 in A {
          print
        }' ${F_SEIS}eqselectlist.txt ${F_SEIS}eqs.txt > ${F_SEIS}eqselected.cat
      fi

      [[ -s ${F_SEIS}eqselected.cat ]] && cp ${F_SEIS}eqselected.cat ${F_SEIS}eqs.txt && echo replaced
    else

        # Cull the combined catalogs by removing equivalent events based on a
        # specified space-time-magnitude window, keeping first-specified catalog

      [[ $NUMEQCATS -le 1 ]] && CULL_EQ_CATALOGS=0
      [[ $forceeqcullflag -eq 1 ]] && CULL_EQ_CATALOGS=1

      if [[ $CULL_EQ_CATALOGS -eq 1 ]]; then
        info_msg "Culling multiple input seismic catalogs..."

        # Copy the extracted catalog to the precull catalog
        cp ${F_SEIS}eqs.txt ${F_SEIS}eqs_precull.txt

        # Find the number of events in the precull catalog
        num_eqs_precull=$(wc -l < ${F_SEIS}eqs_precull.txt | tr -d ' ')

        # Do the culling.
        gawk < ${F_SEIS}eqs_precull.txt -v n=${num_eqs_precull} -v verbose=0 '
        @include "tectoplot_functions.awk"
        BEGIN {
          epoch_cutoff=8  # Seconds between events
          mag_cutoff=0.3   # Magnitude difference
          lon_cutoff=0.3   # Longitude difference
          lat_cutoff=0.3   # Latitude difference
          depth_cutoff=300  # depth difference
        }
        (NR <= n) {
          data[NR]=$5"\x99"$0"\x99"1"\x99"iso8601_to_epoch($5)"\x99"NR
        }
        # (NR > n) {
        #   data[NR]=$5"\x99"$0"\x99"0"\x99"iso8601_to_epoch($5)"\x99"NR
        #   print "Event", NR, "is not imported" > "/dev/stderr"
        # }
        END {
          if (verbose==1) {
            print "EQ cull: sorting data (N==" n ")" > "/dev/stderr"
          }
          asort(data)
          if (verbose==1) {
            print "EQ cull: Data have been sorted" > "/dev/stderr"
          }
          for(i=1;i<=NR;i++)
          {
            split(data[i],x,"\x99")

            # x[1] = timecode, x[2] = full data string, x[3] = is_imported flag
            # x[4] = epoch time (seconds) x[5]=line number in input file

            # event_timecode[i]=x[1]
            event[i]=x[2]
            split(x[2], evec, " ")
            lon[i]=evec[1]
            lat[i]=evec[2]
            depth[i]=evec[3]
            mag[i]=evec[4]
            is_imported[i]=x[3]
            m_epoch[i]=x[4]
            linenumber[i]=x[5]
          }
          if (verbose==1) {
            print "EQ cull: Data have been extracted" > "/dev/stderr"
          }
          oldcompleted=0
          for(i=1;i<=NR;i++)
          {
            # For each event in the combined catalog
            printme=1
            # if (is_imported[i]==0) {
            #   printme=1
              # Check only the 10 closest events in time
            if (verbose==1) {
              newcompleted=int(i/n*100)
              if (newcompleted != oldcompleted) {
                printf("%d% ", newcompleted) > "/dev/stderr"
              }
              oldcompleted=newcompleted
            }

            for(j=i-5;j<=i+5;++j)
            {
              # is_imported[] is no longer used and should be removed
              if (j>=1 && j<=NR && j != i && is_imported[j] == 1)
              {
                if ((abs(m_epoch[i]-m_epoch[j]) < epoch_cutoff) && (abs(mag[i]-mag[j]) < mag_cutoff) && (abs(lon[i]-lon[j]) < lon_cutoff) && (abs(lat[i]-lat[j]) < lat_cutoff) && (abs(depth[i]-depth[j]) < depth_cutoff) && (linenumber[i] > linenumber[j]) )
                {
                      # There is an equivalent event in the catalog that has a
                      # lower line number, so do not print this event
                      print event[i] > "./culled_seismicity.txt"
                      print event[i], "[" linenumber[i], m_epoch[i] "]", "was removed because it matches", event[j], "[" linenumber[j], m_epoch[j] "]" > "./culled_seismicity_info.txt"
                      printme=0
                      break
                }
              }
            }
            if (printme==1) {
              print event[i]
            }
          }
          if (verbose==1) {
            printf("\n") > "/dev/stderr"
          }

        }' > ${F_SEIS}eqs_notculled.txt

        [[ -s culled_seismicity.txt ]] && mv culled_seismicity.txt ${F_SEIS}culled_seismicity.txt

        [[ -s ${F_SEIS}eqs_notculled.txt ]] && cp ${F_SEIS}eqs_notculled.txt ${F_SEIS}eqs.txt

        num_after_cull=$(wc -l < ${F_SEIS}eqs.txt | tr -d ' ')
        info_msg "Before culling: ${num_eqs_precull}.  After culling: ${num_after_cull}"
      fi

      # Retain only the seismicity falling within the map region
      select_in_gmt_map ${F_SEIS}eqs.txt "${RJSTRING}"

      ##############################################################################
      # Select seismicity that falls within a specified polygon.

      if [[ $polygonselectflag -eq 1 ]]; then
        info_msg "Selecting seismicity within specified AOI polygon ${POLYGONAOI}"
        mv ${F_SEIS}eqs.txt ${F_SEIS}eqs_preselect.txt
        gmt select ${F_SEIS}eqs_preselect.txt -F${POLYGONAOI} -Vn | tr '\t' ' ' > ${F_SEIS}eqs.txt
        # gmt select ${F_SEIS}eqs_preselect.txt -F${POLYGONAOI} -Vn | tr '\t' ' ' > ${F_SEIS}eqs.txt
        # cleanup ${F_SEIS}eqs_preselect.txt
      fi
      # info_msg "Polygon selection: $(wc -l < ${F_SEIS}eqs.txt)"

      ##############################################################################
      # Select seismicity on land

      if [[ $zconlandflag -eq 1 && -s ${F_SEIS}eqs.txt ]]; then
        info_msg "Selecting seismicity on land or at sea"
        if [[ -s ${TOPOGRAPHY_DATA} ]]; then

          gmt grdtrack ${F_SEIS}eqs.txt -N -Z -Vn -G${TOPOGRAPHY_DATA} | gawk -v landorsea=${zc_land_or_sea} '
          {
            if (landorsea==1) {
              # Land
              print ($1>0)?1:0
            } else {
              # sea
              print ($1<=0)?1:0
            }
          }'> ${F_SEIS}eqs_onland_sel.txt
          gawk '
          (NR==FNR) {
            toprint[NR]=$1
          }
          (NR!=FNR) {
            if (toprint[NR-length(toprint)]==1) {
              print
            }
          }' ${F_SEIS}eqs_onland_sel.txt ${F_SEIS}eqs.txt > ${F_SEIS}eqs_onland.txt
        fi
        if [[ -s ${F_SEIS}eqs_onland.txt ]]; then
          cp ${F_SEIS}eqs.txt ${F_SEIS}eqs_land.txt
          mv ${F_SEIS}eqs_onland.txt ${F_SEIS}eqs.txt
        fi
      fi



    # Select seismicity based on proximity to Slab2
      ZSLAB2VERT=${CMTSLAB2VERT}
      [[ $cmtslab2filterflag -eq 1 ]] && zslab2filterflag=1
      [[ $cmtslab2_shallow_filterflag -eq 1 ]] && zslab2_shallow_filterflag=1
      [[ $cmtslab2_deep_filterflag -eq 1 ]] && zslab2_deep_filterflag=1

      if [[ $zslab2filterflag -eq 1 || $zslab2_shallow_filterflag -eq 1 || $zslab2_deep_filterflag -eq 1 ]]; then
        if [[ ! $numslab2inregion -eq 0 ]]; then

          # For each slab in the region

          for i in $(seq 1 $numslab2inregion); do
            depthfile=$(echo ${SLAB2_GRIDDIR}${slab2inregion[$i]}.grd | sed 's/clp/dep/')

            # -N flag is needed in case events fall outside the domain
            # echo gmt grdtrack ${F_SEIS}eqs.txt -G$depthfile -Z -N \>\> ${F_SEIS}seis_slab2_sample_${slab2inregion[$i]}_pre.txt
            # gmt grdtrack ${F_SEIS}eqs.txt -G$depthfile -Z -N >> ${F_SEIS}seis_slab2_sample_${slab2inregion[$i]}_pre.txt

            sample_grid_360 ${F_SEIS}eqs.txt $depthfile >>  ${F_SEIS}seis_slab2_sample_${slab2inregion[$i]}_pre.txt

            paste ${F_SEIS}eqs.txt ${F_SEIS}seis_slab2_sample_${slab2inregion[$i]}_pre.txt >> ${F_SEIS}seis_slab2_sample_${slab2inregion[$i]}.txt

            # Select interplate seismicity
            if [[ $zslab2filterflag -eq 1 ]]; then
              info_msg "Selecting interplate seismicity for slab ${slab2inregion[$i]}"
              gawk < ${F_SEIS}seis_slab2_sample_${slab2inregion[$i]}.txt -v vertdiff=${ZSLAB2VERT} '
                function abs(v) { return (v>0)?v:-v}
                ($(NF)!="NaN"){
                  depth=$3
                  slab2depth=(0-$(NF))     # now it is positive down, matching EQ depth

                  # If it is in the slab region and the depth is within the offset
                  if (slab2depth != "NaN" && abs(depth-slab2depth)<vertdiff) {
                    $(NF)=""   # Destroy the last column - slab depth
                    print $0
                  }
                }' >> ${F_SEIS}seis_slabselect.txt
            fi
            # Select seismicity above plate interface
            if [[ $zslab2_shallow_filterflag -eq 1 ]]; then
              info_msg "Selecting interplate seismicity above plate interface for slab ${slab2inregion[$i]}"
              gawk < ${F_SEIS}seis_slab2_sample_${slab2inregion[$i]}.txt -v vertdiff=${ZSLAB2VERT} '
                function abs(v) { return (v>0)?v:-v}
                ($(NF)!="NaN"){
                  depth=$3
                  slab2depth=(0-$(NF))     # now it is positive down, matching earthquake depth

                  # If it is in the slab region and the depth is within the offset
                  if (slab2depth != "NaN" && slab2depth-depth>vertdiff) {
                    $(NF)=""   # Destroy the last column - slab depth
                    print $0
                  }
                }' >> ${F_SEIS}seis_slabselect.txt
            fi

            if [[ $zslab2_deep_filterflag -eq 1 ]]; then
              info_msg "Selecting interplate seismicity below plate interface for ${slab2inregion[$i]}"
              gawk < ${F_SEIS}seis_slab2_sample_${slab2inregion[$i]}.txt -v vertdiff=${ZSLAB2VERT} '
                function abs(v) { return (v>0)?v:-v}
                ($(NF)!="NaN"){

                  depth=$3
                  slab2depth=(0-$(NF))     # now it is positive down, matching earthquake depth

                  # If it is in the slab region and the depth is within the offset
                  if (slab2depth != "NaN" && depth-slab2depth>vertdiff) {
                    $(NF)=""   # Destroy the last column - slab depth
                    print $0
                  }
                }' >> ${F_SEIS}seis_slabselect.txt
            fi

          done
        fi
        [[ -s ${F_SEIS}seis_slabselect.txt ]] && cp ${F_SEIS}eqs.txt ${F_SEIS}eqs_preslab2.txt && cp ${F_SEIS}seis_slabselect.txt ${F_SEIS}eqs.txt
      fi

      # Remove events based on id

      if [[ $zcullflag -eq 1 ]]; then
        gawk < ${F_SEIS}eqs.txt -v id=${zcullid} '
        ($6 != id) {
          print
        }' > ${F_SEIS}eqs_2.txt
        [[ -s ${F_SEIS}eqs_2.txt ]] && mv ${F_SEIS}eqs_2.txt ${F_SEIS}eqs.txt

      fi

      #### Decluster seismicity using one of several available algorithms

      if [[ $seisdeclusterflag -eq 1 ]]; then
        info_msg "Declustering seismicity catalog..."
        case ${DECLUSTER_METHOD} in
          zp)
            info_msg "Using Zaliapin 2008 declustering method"

          ;;
          rb)
            info_msg "Using Reasenberg declustering method"

            if [[ ! -x ${REASENBERG_EXEC} ]]; then
              echo "Compiling Reasenberg declustering code"
              ${F90COMPILER} ${REASENBERG_SCRIPT} -o ${REASENBERG_EXEC}
            fi

            if [[ -x ${REASENBERG_EXEC} ]]; then
              ${REASENBERG_SH} ${F_SEIS}eqs.txt ${REASENBERG_EXEC} ${DECLUSTER_MINSIZE}
            fi
          ;;
          *)
            info_msg "Using Gardner-Knopoff window declustring method ${DECLUSTER_METHOD}"
            ${DECLUSTER_GK} ${F_SEIS}eqs.txt ${DECLUSTER_METHOD} ${DECLUSTER_MINSIZE}
            cp ${F_SEIS}eqs.txt ${F_SEIS}eqs_predecluster.txt
          ;;
        esac
        if [[ ${DECLUSTER_REMOVE} -eq 1 ]]; then
          cp ./catalog_declustered.txt ${F_SEIS}eqs.txt
        else
          cat ./catalog_declustered.txt ./catalog_clustered.txt > ${F_SEIS}eqs.txt
        fi
        mv ./catalog_declustered.txt ./catalog_clustered.txt ${F_SEIS}

        # Create a file of lines connecting dependent to independent events
        gawk '
        # First, we load the independent events (mainshocks) that have clusterID > 1.
        (NR==FNR && $8 > 1) {
          clustered[$8]=$0
          found[$8]=1
          lon[$8]=$1
          lat[$8]=$2
        }
        # For each dependent event (aftershocks/foreshocks), make the line
        (NR!=FNR && $8 > 1) {
          # If there is an independent event with the same ID
          if (found[$8]==1) {
            print "> -Z" $3
            print lon[$8], lat[$8]
            print $1, $2
          }
        }' ${F_SEIS}catalog_declustered.txt ${F_SEIS}catalog_clustered.txt  > ${F_SEIS}cluster_lines.txt

      fi

      ##############################################################################
      # Sort seismicity file so that certain events plot on top of / below others

      if [[ $dozsortflag -eq 1 ]]; then
        info_msg "Sorting earthquakes by $ZSORTTYPE"
        case $ZSORTTYPE in
          "depth")
            SORTFIELD=3
          ;;
          "time")
            SORTFIELD=7
          ;;
          "mag")
            SORTFIELD=4
          ;;
          *)
            info_msg "[-zcsort]: Sort field $ZSORTTYPE not recognized. Using depth."
            SORTFIELD=3
          ;;
        esac
        [[ $ZSORTDIR =~ "down" ]] && sort -n -k $SORTFIELD,$SORTFIELD ${F_SEIS}eqs.txt > ${F_SEIS}eqsort.txt
        [[ $ZSORTDIR =~ "up" ]] && sort -n -r -k $SORTFIELD,$SORTFIELD ${F_SEIS}eqs.txt > ${F_SEIS}eqsort.txt
        [[ -e ${F_SEIS}eqsort.txt ]] && cp ${F_SEIS}eqsort.txt ${F_SEIS}eqs.txt
      fi
    fi # end of section where we do NOT use only selected earthquakes
  fi # if [[ $plotseis -eq 1 ]]


  ################################################################################
  #####           Manage focal mechanisms and hypocenters                    #####
  ################################################################################

  # Fixed scaling of the kinematic vectors from size of focal mechanisms

  # SYMSIZES are apparently in units of cm (default size unit???)
  # Length of slip vector azimuth
  SYMSIZE1=$(echo "${KINSCALE} * 3.5" | bc -l)
  # Length of dip line
  SYMSIZE2=$(echo "${KINSCALE} * 1" | bc -l)
  # Length of strike line
  SYMSIZE3=$(echo "${KINSCALE} * 3.5" | bc -l)

  if [[ $calccmtflag -eq 1 ]]; then

    [[ $CMTFORMAT =~ "GlobalCMT" ]]     && CMTLETTER="c"
    [[ $CMTFORMAT =~ "MomentTensor" ]]  && CMTLETTER="m"
    [[ $CMTFORMAT =~ "TNP" ]] && CMTLETTER="y"

    # New code to process CMT
    cmt_priority=1
    for this_ccat in ${CMT_CATALOG_TYPE[@]}; do
      info_msg "[-c]: Extracting CMT events from ${this_ccat}"
      this_customcmtnum=1
      case $this_ccat in
        GCMT)
          THIS_CMTFILE=${GCMTCATALOG}
        ;;
        ISC)
          THIS_CMTFILE=${ISCCATALOG}
        ;;
        GFZ)
          THIS_CMTFILE=${GFZCATALOG}
        ;;
        custom)  # Slurp the custom CMT file using the specified format and the alphabetical ID
          # THIS_CMTFILE=${CMTADDFILE[$this_customcmtnum]}
          # THIS_CMTFORMAT=${CMTADDFILE_TYPE[$this_customcmtnum]}
          # THIS_CMTLETTER=${CCAT_LETTER[$cmtfilenumber]}
          # echo ${CMTSLURP} ${CMTADDFILE[$this_customcmtnum]} ${CMTADDFILE_TYPE[$this_customcmtnum]} ${CCAT_LETTER[$this_customcmtnum]}
          if [[ ${CMTADDFILE_TYPE[$this_customcmtnum]} == "T" ]]; then
            cp ${CMTADDFILE[$this_customcmtnum]} ${F_CMT}custom_cmt_${this_customcmtnum}.txt
          else
            ${CMTSLURP} ${CMTADDFILE[$this_customcmtnum]} ${CMTADDFILE_TYPE[$this_customcmtnum]}  ${CCAT_LETTER[$this_customcmtnum]} > ${F_CMT}custom_cmt_${this_customcmtnum}.txt
          fi
          THIS_CMTFILE=${F_CMT}custom_cmt_${this_customcmtnum}.txt
        ;;
        *)
        ;;
      esac

      # Do the initial AOI scrape and filter events by CENTROID/ORIGIN location.
      # We should have a cmt_tools.sh option to set events as centroid/origin when importing!

# FileINFO cmt_global_aoi.dat
# Contains the original tectoplot-format focal mechanism data imported from various catalogs
# prior to any manipulations such as culling of equivalent events

      if [[ $THIS_CMTFILE == "${F_CMT}usgs_foc.cat" ]]; then
        # This is a special case where the catalog is directly added without additional checks
        cat $THIS_CMTFILE >> ${F_CMT}cmt_global_aoi.dat
      elif [[ -s $THIS_CMTFILE ]]; then
        # For other catalogs (tectoplot format), filter by location in lon/lat box, magnitude range
        gawk < $THIS_CMTFILE -v orig=$ORIGINFLAG -v cent=$CENTROIDFLAG -v mindepth="${EQCUTMINDEPTH}" -v maxdepth="${EQCUTMAXDEPTH}" -v minlat="$MINLAT" -v maxlat="$MAXLAT" -v minlon="$MINLON" -v maxlon="$MAXLON" -v minmag=${CMT_MINMAG} -v maxmag=${CMT_MAXMAG} '
        @include "tectoplot_functions.awk"
        {
          mag=$13
          if (cent==1) {
            lon=$5
            lat=$6
            depth=$7
          } else {
            lon=$8
            lat=$9
            depth=$10
          }
          if ((depth >= mindepth && depth <= maxdepth) && (lat >= minlat && lat <= maxlat) && (mag >= minmag && mag <= maxmag)) {
            if (test_lon(minlon, maxlon, lon) == 1) {
              if (lon!="none" && lat!="none") {
                print
              }
            }
          }
        }' > ${F_CMT}sub_extract.cat
        info_msg "Extracted $(wc -l < ${F_CMT}sub_extract.cat) CMT events from $THIS_CMTFILE"
        cat ${F_CMT}sub_extract.cat >> ${F_CMT}cmt_global_aoi.dat
        rm -f ${F_CMT}sub_extract.cat
      fi
    done

    # Restrict events to those falling within the map region.
    # Should we remove the above filtering based on lon/lat range?

    case $CMTTYPE in
      CENTROID)
          select_in_gmt_map_by_columns 5 6 ${F_CMT}cmt_global_aoi.dat ${RJSTRING}
        ;;
      ORIGIN)
          select_in_gmt_map_by_columns 8 9 ${F_CMT}cmt_global_aoi.dat ${RJSTRING}
        ;;
    esac

    # A list of various CMT-related files to cleanup
    cleanup ${F_CMT}sub_extract.cat
    # cleanup ${F_CMT}cmt_global_aoi.dat
    cleanup ${F_CMT}cmt_merged_ids.txt
    cleanup ${F_CMT}cmt_presort.txt
    cleanup ${F_CMT}cmt_typefilter.dat
    # cleanup ${F_CMT}equiv_presort.txt

    if [[ ${#CCAT_STRING} -gt 1 && ${CULL_CMT_CATALOGS} -eq 1 ]]; then

      info_msg "[-c]: Sorting, finding clashes, and prioritizing using order of CCAT_STRING=${CCAT_STRING}"

      before_e=$(wc -l < ${F_CMT}cmt_global_aoi.dat)

      CMT_WINDOW_DELTALON=2
      CMT_WINDOW_DELTALAT=2
      CMT_WINDOW_DELTASEC=15
      CMT_WINDOW_DELTADEPTH=30
      CMT_WINDOW_DELTAMAG=0.5

      sort ${F_CMT}cmt_global_aoi.dat -k3,3 | uniq -u > ${F_CMT}cmt_presort.txt
      gawk < ${F_CMT}cmt_presort.txt -v removedfile=${F_CMT}"cmt_removed_cull.cat" -v cent=$CENTROIDFLAG \
            -v ccatstring=${CCAT_STRING} -v delta_lon=${CMT_WINDOW_DELTALON} -v delta_lat=${CMT_WINDOW_DELTALAT} \
            -v delta_sec=${CMT_WINDOW_DELTASEC} -v delta_depth=${CMT_WINDOW_DELTADEPTH} -v delta_mag=${CMT_WINDOW_DELTAMAG} '
      function abs(v) { return (v>0)?v:-v }
      function build_index(ccstr) {
        for(i=1; i<=length(ccstr); i++) {
          ccindex[substr(ccstr, i, 1)]=i
        }
      }
      BEGIN {
        # Define the window for potentially equivalent earthquakes
        #delta_lon=2
        #delta_lat=2
        #delta_sec=15
        #delta_depth=30
        #delta_mag=0.5

        # Build the priority index
        build_index(ccatstring)
      }
      {
        data[NR]=$0
        date[NR]=substr($3,1,10)
        epoch[NR]=$4
        eventid[NR]=$2
        numfields=NF
        if (cent==1) {
          lon[NR]=$5
          lat[NR]=$6
          depth[NR]=$7
        } else {
          lon[NR]=$8
          lat[NR]=$9
          depth[NR]=$10
        }
        mag[NR]=$13
        idcode[NR]=substr($1,1,1)
        prioritynum[NR]=ccindex[idcode[NR]]
      }
      END {
        numentries=NR

        # The strategy is to mark any event that is superceded by another event, and then output only
        # the unmarked events

        # For each entry (target event)
        for(i=1;i<=numentries;i++) {
          # If input event has no date, then obliterate any other events in the whole file that fall
          # within the spatial-temporal-magnitude window. This takes a long time as we cannot sort
          # the data and look at a sub-window.
          if(date[i]=="0000-00-00") {
            for(j=1;j<=numentries;j++) {
              if (j != i && idcode[i] != idcode[j]) {
                # Does the comparison event fall in the spatial-magnitude window of the target event?
                if ( (abs(lon[i]-lon[j])<=delta_lon) && (abs(lat[i]-lat[j])<=delta_lat) &&
                   (abs(depth[i]-depth[j])<=delta_depth) && (abs(mag[i]-mag[j])<=delta_mag) ) {
                   # Is the target event higher priority?
                   if (prioritynum[j] > prioritynum[i]) {
                     markedfordeath_nodate[j]=1
                     # print "Removing event",  j, eventid[j], idcode[j], "which is killed by no-date event", i, eventid[i], idcode[i] > "/dev/stderr"
                   } else {
                     markedfordeath_nodate[i]=1
                    print "Removing nodate event:" > "/dev/stderr"
                    print data[i] > "/dev/stderr"
                    print "which is killed by event:" > "/dev/stderr"
                    print data[j] > "/dev/stderr"

                   }
                   break
                }
              }
            }
          } else {
            # For the entries surrounding each entry (before and after)
            for(j=i-3; j<=i+3; j++) {
              if (j>=1 && j<=numentries && j != i && idcode[i] != idcode[j]) {
                # Does the comparison event fall in the spatial-magnitude window of the target event?
                if ( (abs(lon[i]-lon[j])<=delta_lon) && (abs(lat[i]-lat[j])<=delta_lat) &&
                   (abs(depth[i]-depth[j])<=delta_depth) && (abs(mag[i]-mag[j])<=delta_mag) ) {
                   # Does the comparison event fall in the time window OR an event has time 0000-00-00?
                   if ( (abs(epoch[i]-epoch[j])<=delta_sec) || date[i]=="0000-00-00" || date[j] == "0000-00-00") {
                     # Does the target event fall behind the comparison event in priority order?
                     # print "Event", i, eventid[i], idcode[i], "is in window of", j, eventid[j], idcode[j] > "/dev/stderr"
                     if (prioritynum[i] > prioritynum[j]) {
                       markedfordeath[i]=1
                       # print "Removing event", i, eventid[i], idcode[i], "which is superceded by event", j eventid[j] idcode[j] > "/dev/stderr"
                     }
                     break
                   }
                }
              }
            }
          }
        }
        for(i=1;i<=numentries;i++) {
          if (markedfordeath[i]!=1 && markedfordeath_nodate[i]!=1) {
            print data[i]
          } else if (markedfordeath[i]==1) {
            print "Removed using time-space-magnitude:", data[i] > removedfile
          } else if (markedfordeath_nodate[i]==1) {
            print "Removed due to collision with nodate:", data[i] > removedfile
          }
        }
      }
      ' > ${F_CMT}cmt_global_aoi.dat

      after_e=$(wc -l < ${F_CMT}cmt_global_aoi.dat)

      info_msg "[-c]: Before equivalent CMT culling: $before_e events ; after culling: $after_e events."
    fi

    CMTFILE=${F_CMT}cmt_global_aoi.dat

    if [[ $eqlistselectflag -eq 1 ]]; then
      echo ${eqlistarray[@]} | tr ' ' '\n' > ${F_SEIS}eqselectlist.txt

      gawk '
        NR==FNR {
          A[$1]=1 ; next
        }
        $2 in A {
          print
        }' ${F_SEIS}eqselectlist.txt ${CMTFILE} > ${F_CMT}cmtselected.dat
        [[ -s ${F_CMT}cmtselected.dat ]] && CMTFILE=${F_CMT}cmtselected.dat
    fi


    gawk < $CMTFILE -v dothrust=$cmtthrustflag -v donormal=$cmtnormalflag -v doss=$cmtssflag '{
      if (substr($1,2,1) == "T" && dothrust == 1) {
        print
      } else if (substr($1,2,1) == "N" && donormal == 1) {
        print
      } else if (substr($1,2,1) == "S" && doss == 1) {
        print
      }
    }' > ${F_CMT}cmt_typefilter.dat

    CMTFILE=$(abs_path ${F_CMT}cmt_typefilter.dat)

    # Select focal mechanisms from the eqlist
    if [[ $eqlistselectflag -eq 1 ]]; then
      info_msg "Selecting focal mechanisms from eqlist"
      echo ${eqlistarray[@]} | tr ' ' '\n' > ${F_CMT}selectfile.dat
      gawk '
        NR==FNR
        {
          A[$1]=1
          next
        }
        $2 in A { print }' ${CMTFILE} ${F_CMT}selectfile.dat > ${F_CMT}cmt_eqlistsel.dat

      CMTFILE=$(abs_path ${F_CMT}cmt_eqlistsel.dat)
    fi

    # Select CMT data between start and end times
    if [[ $timeselectflag -eq 1 ]]; then
      gawk < $CMTFILE -v mintime=$STARTTIME -v maxtime=$ENDTIME '{
        if (mintime <= $3 && $3 <= maxtime) {
          print
        }
      }' > ${F_CMT}cmt_timesel.dat
      CMTFILE=$(abs_path ${F_CMT}cmt_timesel.dat)
      echo "Seismic/CMT [${STARTTIME} to ${ENDTIME}]" >> ${SHORTSOURCES}
    fi



    # This abomination of a command is because I don't know how to use gmt select
    # to print the full record based only on the lon/lat in specified columns.

    if [[ $polygonselectflag -eq 1 ]]; then
      info_msg "Selecting focal mechanisms within user polygon ${POLYGONAOI} using ${CMTTYPE} location"

      case $CMTTYPE in
        CENTROID)  # Lon=Column 5, Lat=Column 6
          gawk < $CMTFILE '{
            for (i=5; i<=NF; i++) {
              printf "%s ", $(i) }
              print $1, $2, $3, $4;
            }' | gmt select -F${POLYGONAOI} ${VERBOSE} | tr '\t' ' ' | gawk  '{
            printf "%s %s %s %s", $(NF-3), $(NF-2), $(NF-1), $(NF);
            for (i=1; i<=NF-4; i++) {
              printf " %s", $(i)
            }
            printf "\n";
          }' > ${F_CMT}cmt_polygonselect.dat
          ;;
        ORIGIN)  # Lon=Column 8, Lat=Column 9
          gawk < $CMTFILE '{
            for (i=8; i<=NF; i++) {
              printf "%s ", $(i) }
              print $1, $2, $3, $4, $5, $6, $7;
            }' > ${F_CMT}tmp.dat
            gmt select ${F_CMT}tmp.dat -F${POLYGONAOI} ${VERBOSE} | tr '\t' ' ' | gawk  '{
            printf "%s %s %s %s %s %s %s", $(NF-6), $(NF-5), $(NF-4), $(NF-3), $(NF-2), $(NF-1), $(NF);
            for (i=1; i<=NF-6; i++) {
              printf " %s", $(i)
            } printf "\n";
          }' > ${F_CMT}cmt_polygonselect.dat
          ;;
      esac
      CMTFILE=$(abs_path ${F_CMT}cmt_polygonselect.dat)
    fi

    ##### Select focal mechanisms using cfilter
    if [[ $cfilterflag -eq 1 ]]; then
      cp ${CMTFILE} ${F_CMT}cmt_cfilter.txt
      FILTERFILE=$(abs_path ${F_CMT}cmt_cfilter.txt)

      for thiscmd in ${cfiltercommand[@]}; do
        info_msg "[-cfilter]: Processing ${thiscmd} beginning with $(wc -l < ${FILTERFILE}) lines"

        case $thiscmd in
          maxstrike)
            gawk < ${FILTERFILE} -v strike=${CF_MAXSTRIKE} '{
               if ($16 <= strike || $19 <= strike) {
                 print
               }
            }' > ${F_CMT}filter.out
             mv ${F_CMT}filter.out ${FILTERFILE}
          ;;
          minstrike)
            gawk < ${FILTERFILE} -v strike=${CF_MINSTRIKE} '{
               if ($16 >= strike || $19 >= strike) {
                 print
               }
            }' > ${F_CMT}filter.out
             mv ${F_CMT}filter.out ${FILTERFILE}
          ;;
          maxdip)
            gawk < ${FILTERFILE} -v dip=${CF_MAXDIP} '{
               if ($17 <= dip || $20 <= dip) {
                 print
               }
            }' > ${F_CMT}filter.out
             mv ${F_CMT}filter.out ${FILTERFILE}
          ;;
          mindip)
            gawk < ${FILTERFILE} -v dip=${CF_MINDIP} '{
             if ($17 >= dip || $20 >= dip) {
               print
             }
            }' > ${F_CMT}filter.out
            mv ${F_CMT}filter.out ${FILTERFILE}
          ;;
          rakerange)
            gawk < ${FILTERFILE} -v minrake=${CF_MINRAKE} -v maxrake=${CF_MAXRAKE} '{
             if (minrake < maxrake) {
               if (($18 >= minrake && $18 <= maxrake) || ($21 >= minrake && $21 <= maxrake)) {
                 print
               }
             } else {
               if ( ($18 <= maxrake && $18 >= -180) || ($21 >= minrake && $21 <= 180) ) {
                 print
               }
             }
            }' > ${F_CMT}filter.out
            mv ${F_CMT}filter.out ${FILTERFILE}
          ;;
        esac
      done
      [[ -s ${FILTERFILE} ]] && CMTFILE=$(abs_path ${FILTERFILE})
    fi

    ##### Select focal mechanisms on land

    if [[ $zconlandflag -eq 1 && -s $CMTFILE ]]; then
      if [[ -s ${TOPOGRAPHY_DATA} ]]; then
        case $CMTTYPE in
          ORIGIN)
            gawk < ${CMTFILE} '{print $8, $9}' > ${F_CMT}cmt_epicenter.dat
            ;;
          CENTROID)
            gawk < ${CMTFILE} '{print $5, $6}' > ${F_CMT}cmt_epicenter.dat
            ;;
        esac

        gmt grdtrack ${F_CMT}cmt_epicenter.dat -N -Z -Vn -G${TOPOGRAPHY_DATA} | gawk -v landorsea=${zc_land_or_sea} '
        {
          if (landorsea==1) {
            # Land
            print ($1>0)?1:0
          } else {
            # sea
            print ($1<=0)?1:0
          }
        }'> ${F_CMT}cmt_onland_sel.txt
        gawk '
        (NR==FNR) {
          toprint[NR]=$1
        }
        (NR!=FNR) {
          if (toprint[NR-length(toprint)]==1) {
            print
          }
        }' ${F_CMT}cmt_onland_sel.txt ${CMTFILE} > ${F_CMT}cmt_onland.txt
      fi
      [[ -s ${F_CMT}cmt_onland.txt ]] && CMTFILE=$(abs_path ${F_CMT}cmt_onland.txt)
    fi

    ##### Select focal mechanisms based on SLAB2 interface

    ##### Filter GMT format thrust CMTs based on proximity to Slab2 surface and
    #     consistency of at least one nodal plane with the fault surface

    #     In case the same event is selected multiple times, only take first one

    if [[ $cmtslab2filterflag -eq 1 || $cmtslab2_deep_filterflag -eq 1 || $cmtslab2_shallow_filterflag -eq 1 ]]; then
      if [[ ! $numslab2inregion -eq 0 ]]; then

        # Extract the lon, lat of all focal mechanisms based on CMTTYPE

        gawk < $CMTFILE -v cmttype=$CMTTYPE '
          {
            if (cmttype=="CENTROID") {
              lon=$5; lat=$6; depth=$7;
            } else {
              lon=$8; lat=$9; depth=$10;
            }
            print lon, lat
          }' > ${F_CMT}cmt_lonlat.txt

        # For each slab in the region

        for i in $(seq 1 $numslab2inregion); do
          info_msg "Sampling CMT events near plate interface of ${slab2inregion[$i]}"
          depthfile=$(echo ${SLAB2_GRIDDIR}${slab2inregion[$i]}.grd | sed 's/clp/dep/')
          strikefile=$(echo ${SLAB2_GRIDDIR}${slab2inregion[$i]}.grd | sed 's/clp/str/')
          dipfile=$(echo ${SLAB2_GRIDDIR}${slab2inregion[$i]}.grd | sed 's/clp/dip/')

          # # -N flag is needed in case events fall outside the domain
          # gmt grdtrack -G$depthfile -G$strikefile -G$dipfile -Z -N ${F_CMT}cmt_lonlat.txt ${VERBOSE} >> ${F_CMT}cmt_slab2_sample_${slab2inregion[$i]}.txt

          sample_grid_360 ${F_CMT}cmt_lonlat.txt $depthfile $strikefile $dipfile >>  ${F_CMT}cmt_slab2_sample_${slab2inregion[$i]}.txt

          paste ${CMTFILE} ${F_CMT}cmt_slab2_sample_${slab2inregion[$i]}.txt > ${F_CMT}cmt_slab2_sample_${slab2inregion[$i]}_pasted.txt

          # If we are looking for plate interface events
          if [[ $cmtslab2filterflag -eq 1 ]]; then
            info_msg "Selecting interplate thrust focal mechanisms: v ${CMTSLAB2VERT} / s ${CMTSLAB2STR} / d ${CMTSLAB2DIP}"
            touch ${F_CMT}cmt_nodalplane.txt
            gawk < ${F_CMT}cmt_slab2_sample_${slab2inregion[$i]}_pasted.txt -v incout=${SLAB2_INCLUDEOUT} -v cmttype=${CMTTYPE} -v strikediff=${CMTSLAB2STR} -v dipdiff=${CMTSLAB2DIP} -v vertdiff=${CMTSLAB2VERT} '
              function abs(v) { return (v>0)?v:-v}
              ($40 != "NaN") {
                slab2depth=(0-$40)     # now it is positive down, matching CMT depth
                slab2strike=$41
                slab2dip=$42
                events1=$16; eventd1=$17;  # Strike and dip of nodal planes
                events2=$19; eventd2=$20;
                if (cmttype=="ORIGIN") {
                  lon=$8; lat=$9; depth=$10
                } else {
                  lon=$5; lat=$6; depth=$7
                }

                # If it is in the slab region and the depth is within the offset
                if (abs(depth-slab2depth)<vertdiff)
                {
                  # If the strike and dip of one nodal plane matches the slab
                  printme=0
                  if (abs(slab2strike-events1) < strikediff && (abs(slab2dip-eventd1)<dipdiff)) {
                    printme=1
                    nodalplane=1
                  } else if (abs(slab2strike-events2) < strikediff && (abs(slab2dip-eventd2)<dipdiff)) {
                    printme=1
                    nodalplane=2
                  }
                  if (printme==1) {
                    $42=""
                    $41=""
                    $40=""
                    print $0
                    print nodalplane, $3, $16, vertdiff >> "./cmt_thrust_nodalplane.txt"
                  }
                }
              }

              ($40=="NaN" && incout==1) {
                  $42=""
                  $41=""
                  $40=""
                  print $0
              }
              ' >> ${F_CMT}cmt_slabselected.txt
            #   wc -l ../${F_CMT}cmt_thrust_nearslab.txt
            #   cat ./cmt_thrust_nodalplane.txt >> ../${F_CMT}cmt_thrust_nodalplane.txt
            #   rm -f ./cmt_thrust_nodalplane.txt
          fi
          # If we are looking for shallow events
          if [[ $cmtslab2_shallow_filterflag -eq 1 ]]; then
            gawk < ${F_CMT}cmt_slab2_sample_${slab2inregion[$i]}_pasted.txt -v incout=${SLAB2_INCLUDEOUT} -v cmttype=${CMTTYPE} -v strikediff=${CMTSLAB2STR} -v dipdiff=${CMTSLAB2DIP} -v vertdiff=${CMTSLAB2VERT} '
              function abs(v) { return (v>0)?v:-v}
              ($40 != "NaN") {
                slab2depth=(0-$40)     # now it is positive down, matching CMT depth
                slab2strike=$41
                slab2dip=$42
                events1=$16; eventd1=$17;  # Strike and dip of nodal planes
                events2=$19; eventd2=$20;
                if (cmttype=="ORIGIN") {
                  lon=$8; lat=$9; depth=$10
                } else {
                  lon=$5; lat=$6; depth=$7
                }

                # If it is in the slab region and the depth is within the offset
                if (depth<slab2depth-vertdiff)
                {
                  $42=""
                  $41=""
                  $40=""
                  print $0
                }
              }

              ($40=="NaN" && incout==1) {
                  $42=""
                  $41=""
                  $40=""
                  print $0
              }
              ' >> ${F_CMT}cmt_slabselected.txt
          fi

          # If we are looking for deep events
          if [[ $cmtslab2_deep_filterflag -eq 1 ]]; then
            gawk < ${F_CMT}cmt_slab2_sample_${slab2inregion[$i]}_pasted.txt -v incout=${SLAB2_INCLUDEOUT} -v cmttype=${CMTTYPE} -v strikediff=${CMTSLAB2STR} -v dipdiff=${CMTSLAB2DIP} -v vertdiff=${CMTSLAB2VERT} '
              function abs(v) { return (v>0)?v:-v}
              ($40 != "NaN") {
                slab2depth=(0-$40)     # now it is positive down, matching CMT depth
                slab2strike=$41
                slab2dip=$42
                events1=$16; eventd1=$17;  # Strike and dip of nodal planes
                events2=$19; eventd2=$20;
                if (cmttype=="ORIGIN") {
                  lon=$8; lat=$9; depth=$10
                } else {
                  lon=$5; lat=$6; depth=$7
                }
                # If it is in the slab region and the depth is within the offset
                ## AND the strike-dip of both nodal planes do not match slab2
                if (depth-slab2depth>vertdiff || (incout==1 && $40=="NaN"))
                {
                  # If the strike and dip of one nodal plane matches the slab
                  printme=1
                  if (abs(slab2strike-events1) < strikediff && (abs(slab2dip-eventd1)<dipdiff)) {
                    printme=0
                    nodalplane=1
                  } else if (abs(slab2strike-events2) < strikediff && (abs(slab2dip-eventd2)<dipdiff)) {
                    printme=0
                    nodalplane=2
                  }
                  if (printme==1) {
                    $42=""
                    $41=""
                    $40=""
                    print $0
                  }
                }
              }

              ($40=="NaN" && incout==1) {
                  $42=""
                  $41=""
                  $40=""
                  print $0
              }
              ' >> ${F_CMT}cmt_slabselected.txt
          fi
        done
      fi
      [[ -s ${F_CMT}cmt_slabselected.txt ]] && CMTFILE=$(abs_path ${F_CMT}cmt_slabselected.txt)
    fi

  # Backtilt focal mechanisms based on Slab2 strike and dip.

  if [[ $slab2_unfold_focalsflag -eq 1 ]]; then
    info_msg "[-cunfold]: Rotating focal mechanisms based on Slab2 strike/dip"
    gawk < $CMTFILE -v cmttype=$CMTTYPE '
      {
        if (cmttype=="CENTROID") {
          lon=$5; lat=$6; depth=$7;
        } else {
          lon=$8; lat=$9; depth=$10;
        }
        print lon, lat
      }' > ${F_CMT}cmt_rotate_lonlat.txt


    for i in $(seq 1 $numslab2inregion); do
      rot_depthfile+="-G"$(echo ${SLAB2_GRIDDIR}${slab2inregion[$i]}.grd | sed 's/clp/dep/')" "
      rot_strikefile+="-G"$(echo ${SLAB2_GRIDDIR}${slab2inregion[$i]}.grd | sed 's/clp/str/')" "
      rot_dipfile+="-G"$(echo ${SLAB2_GRIDDIR}${slab2inregion[$i]}.grd | sed 's/clp/dip/')" "
    done

      # -N flag is needed in case events fall outside the domain
    gmt grdtrack ${rot_depthfile[@]} -Z -N ${F_CMT}cmt_rotate_lonlat.txt ${VERBOSE} > ${F_CMT}cmt_rotate_depth_sample.txt
    gmt grdtrack ${rot_strikefile[@]} -Z -N ${F_CMT}cmt_rotate_lonlat.txt ${VERBOSE} > ${F_CMT}cmt_rotate_strike_sample.txt
    gmt grdtrack ${rot_dipfile[@]} -Z -N ${F_CMT}cmt_rotate_lonlat.txt ${VERBOSE} > ${F_CMT}cmt_rotate_dip_sample.txt

    paste ${CMTFILE} ${F_CMT}cmt_rotate_depth_sample.txt ${F_CMT}cmt_rotate_strike_sample.txt ${F_CMT}cmt_rotate_dip_sample.txt > ${F_CMT}cmt_rotate_paste.txt
    gawk < ${F_CMT}cmt_rotate_paste.txt -v numsamples=$numslab2inregion -v cmttype=$CMTTYPE '
      @include "tectoplot_functions.awk"
      {
      mindepth=-9999
      # if (cmttype=="CENTROID") {
      #   lon=$5; lat=$6; depth=$7;
      # } else {
      #   lon=$8; lat=$9; depth=$10;
      # }
      # find the index of the sample with least slab2 depth
      for(i=40;i<40+numsamples;i++) {
        if ($(i) != "NaN") {
          mindepth=($(i)>mindepth)?$(i):mindepth  # Backwards looking because slab2 depth is negative downward
          mindepth_ind=i
        }
      }
      if (mindepth==-9999) {   # For example if all NaNs
        strike=0
        dip=0
      } else {
        strike=$(numsamples+mindepth_ind)
        dip=$(2*numsamples+mindepth_ind)
      }

      moment_tensor_rotate($33,$34,$35,$36,$37,$38,strike,0,dip)
      moment_tensor_diagonalize_ntp(r_Mxx, r_Myy, r_Mzz, r_Mxy, r_Mxz, r_Myz)
      ntp_to_sdr(d_AZ0, d_PL0, d_AZ2, d_PL2, SDR)

      print $1,$2"-rotated",$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,SDR[1],SDR[2],SDR[3],SDR[4],SDR[5],SDR[6],$22,d_EV0,d_AZ0,d_PL0,d_EV1,d_AZ1,d_PL1,d_EV2,d_AZ2,d_PL2,$32,r_Mxx,r_Myy,r_Mzz,r_Mxy,r_Mxz,r_Myz,$39
    }' > ${F_CMT}cmt_rotated_slab2.dat
    [[ -s ${F_CMT}cmt_rotated_slab2.dat ]] && CMTFILE=$(abs_path ${F_CMT}cmt_rotated_slab2.dat)
  fi

  #  # (This section is for a very specific application and probably should be removed)
  #  ##############################################################################
  #  # Rotate PTN axes based on back-azimuth to a pole (-cr)
  #
   if [[ $cmtrotateflag -eq 1 && -e $CMTFILE ]]; then
     info_msg "Rotating principal axes by back azimuth to ${CMT_ROTATELON}/${CMT_ROTATELAT}"
     case $CMTTYPE in
       ORIGIN)
         gawk < $CMTFILE '{ print $8, $9 }' | gmt mapproject -Ab${CMT_ROTATELON}/${CMT_ROTATELAT} ${VERBOSE} > ${F_CMT}cmt_backaz.txt
       ;;
       CENTROID)
         gawk < $CMTFILE '{ print $5, $6 }' | gmt mapproject -Ab${CMT_ROTATELON}/${CMT_ROTATELAT} ${VERBOSE} > ${F_CMT}cmt_backaz.txt
       ;;
     esac
     paste $CMTFILE ${F_CMT}cmt_backaz.txt > ${F_CMT}cmt_backscale.txt
     gawk < ${F_CMT}cmt_backscale.txt -v refaz=$CMT_REFAZ '{ for (i=1; i<=22; i++) { printf "%s ", $(i) }; printf "%s %s %s %s %s %s %s %s %s", $23, ($24-$42+refaz)%360, $25, $26, ($27-$42+refaz)%360, $28, $29,($30-$42+refaz)%360, $31;  for(i=32;i<=39;i++) {printf " %s", $(i)}; printf("\n");  }' > ${F_CMT}cmt_rotated.dat
     CMTFILE=$(abs_path ${F_CMT}cmt_rotated.dat)
  fi

    ##### EQUIVALENT EARTHQUAKES

    # If the REMOVE_EQUIVS variable is set, compare eqs.txt with cmt.dat to remove
    # earthquakes that have a focal mechanism equivalent, using a spatio-temporal
    # proximity metric

    # If CMTFILE exists but we aren't plotting CMT's this will really cull a lot of EQs! Careful!
    # CMTFILE should arguably be AOI selected by now in all cases (can we check?)

    # This section is very sensitive to file formats and any change will break it.

    if [[ $REMOVE_EQUIVS -eq 1 && -e $CMTFILE && -e ${F_SEIS}eqs.txt ]]; then

      before_e=$(wc -l < ${F_SEIS}eqs.txt)

      # $7 is epoch seconds for eqs.txt
      # $4 is epoch seconds for focal mechanisms

      # Put the epoch at the beginning of each line, then sort by epoch
      # Could also just sort by timestring
      gawk '
      (NR==FNR) { # Read in EQs first
        print $7, $0
      }
      (NR>FNR) { # Now read in focal mechanisms
        print $4, $0
      }
      ' ${F_SEIS}eqs.txt $CMTFILE | sort -n -k 1,1 > ${F_CMT}equiv_presort.txt

      # echo cull parameters are -v delta_lat=${zccull_lat} -v delta_lon=${zccull_lon} -v delta_sec=${zccull_sec} -v delta_depth=${zccull_depth} -v delta_mag=${zccull_mag} 
      gawk < ${F_CMT}equiv_presort.txt -v numsurround=20 -v delta_lat=${zccull_lat} -v delta_lon=${zccull_lon} -v delta_sec=${zccull_sec} -v delta_depth=${zccull_depth} -v delta_mag=${zccull_mag} '
        @include "tectoplot_functions.awk"
        {
          data[NR]=$0
          epoch[NR]=$1
          numfields[NR]=NF

          if ($14 != "") {
          # focal mechanism entries have data in field 14
            iscmt[NR]=1
            lon[NR]=$9
            lat[NR]=$10
            depth[NR]=$11
            mag[NR]=$14
            idcode[NR]=$3
          } else {
          # Seismicity entries do not have data in field 14
          # EPOCH LON LAT DEPTH MAG TIMECODE ID EPOCH CLUSTERID+0
            iscmt[NR]=0
            lon[NR]=$2
            lat[NR]=$3
            depth[NR]=$4
            mag[NR]=$5
            idcode[NR]=$7
          }
        }
        END {
          numentries=NR
          # Check each entry in the merged file
          for(indd=1;indd<=numentries;indd++) {
            # print "Examining", indd, "iscmt:" iscmt[indd] > "/dev/stderr"

            # For each seismicity event, decide if there is a focal mechanism equivalent
            if (iscmt[indd]==0) {
              # Print by default
              printme=1
              for(j=indd-numsurround; j<=indd+numsurround; j++) {
                # For the surrounding events, if one is a focal mechanism
                if (j>=1 && j<=numentries && j != indd && iscmt[j]==1) {

                  # if (mag[j] >= 7) {
                  #   delta_lon=3
                  #   delta_lat=3
                  # }
                  # if (mag[j] >= 8) {
                  #   delta_lon=5
                  #   delta_lat=5
                  # }

# print "EVENT", i, j  > "/dev/stderr"
#                        print lon[indd], lon[j], "(" abs(lon[indd]-lon[j]), "<", delta_lon  ")" > "/dev/stderr"
#                        print lat[indd], lat[j],  "(" abs(lat[indd]-lat[j]), "<", delta_lat ")" > "/dev/stderr"
#                        print depth[indd], depth[j], "("  abs(depth[indd]-depth[j]), "<", delta_depth ")" > "/dev/stderr"
#                        print mag[indd], mag[j],  "(" abs(mag[indd]-mag[j]), "<", delta_mag ")" > "/dev/stderr"
#                        print epoch[indd], epoch[j],  "(" abs(epoch[indd]-epoch[j]), "<", delta_sec ")" > "/dev/stderr"

                # Remove the depth comparison as this is the worst constrained dimension
                # (abs(depth[indd]-depth[j])<=delta_depth) && 
                 if ( (abs(lon[indd]-lon[j])<=delta_lon) && (abs(lat[indd]-lat[j])<=delta_lat) &&
                       (abs(epoch[indd]-epoch[j])<=delta_sec && (abs(mag[indd]-mag[j])<=delta_mag) ) ) {
                      #  This CMT [j] is a duplicate of the seismicity event [i]
                      #  print "Matched:" > "/dev/stderr"
                      #  print "---" > "/dev/stderr"
                      #  print data[indd] > "/dev/stderr"
                      #  print data[j] > "/dev/stderr"
                      #  print "---" > "/dev/stderr"
                      #  print lon[indd], lon[j], "(" abs(lon[indd]-lon[j]), "<", delta_lon  ")" > "/dev/stderr"
                      #  print lat[indd], lat[j],  "(" abs(lat[indd]-lat[j]), "<", delta_lat ")" > "/dev/stderr"
                      # #  print depth[indd], depth[j], "("  abs(depth[indd]-depth[j]), "<", delta_depth ")" > "/dev/stderr"
                      #  print mag[indd], mag[j],  "(" abs(mag[indd]-mag[j]), "<", delta_mag ")" > "/dev/stderr"
                      #  print epoch[indd], epoch[j],  "(" abs(epoch[indd]-epoch[j]), "<", delta_sec ")" > "/dev/stderr"
                      #  print "time: " abs(epoch[indd]-epoch[j]) > "/dev/stderr"
                      # #  print "depth: " abs(depth[indd]-depth[j]) > "/dev/stderr"
                      printme=0
                      # mixedid = sprintf("'s/%s/%s+%s/'",idcode[j],idcode[j],idcode[indd])
                      mixedid = sprintf("%s %s+%s",idcode[j],idcode[j],idcode[indd])
                      break
                  }
                }
              }
              numf=split(data[indd], printout, " ")
              if (printme==1) {
                for (i=2; i<numf;i++) {
                  printf("%s ", printout[i])
                }
                printf("%s\n", printout[numf])
              } else {
                for (i=2; i<numf;i++) {
                  printf("%s ", printout[i]) >> "./eq_culled.txt"
                }
                printf("%s\n", printout[numf]) >> "./eq_culled.txt"
                print mixedid >> "./eq_idcull.dat"
              }
            }
          }
        }
        ' > ${F_SEIS}eqs_notculled.txt

        [[ -s ${F_SEIS}eqs_notculled.txt ]] && cp ${F_SEIS}eqs_notculled.txt ${F_SEIS}eqs.txt
        [[ -s ./eq_culled.txt ]] && cp ./eq_culled.txt ${F_SEIS}

        after_e=$(wc -l < ${F_SEIS}eqs.txt)

        info_msg "Before equivalent EQ culling: $before_e events ; after culling: $after_e events."

        info_msg "Replacing IDs in CMT catalog with combined CMT/Seis IDs"

        if [[ -s ./eq_idcull.dat ]]; then
          gawk '
            # Populate an array with key / replacement
            (NR==FNR) {
              replace[$1]=$2
            }
            # Replace second entry with replacement if key exists
            (NR!=FNR) {
              if (replace[$2]!="") {
                $2=replace[$2]
              }
              print $0
            }
          ' eq_idcull.dat ${CMTFILE} > ${F_CMT}cmt_merged_ids.txt
          CMTFILE=$(abs_path ${F_CMT}cmt_merged_ids.txt)
          rm -f ./eq_idcull.dat
        fi


    fi

    if [[ -s ${F_SEIS}eq_culled.txt && -s ${F_SEIS}catalog_clustered.txt && -s $CMTFILE ]]; then
      info_msg "Merging cluster IDs with CMT catalog"

      # cat ${F_SEIS}catalog_clustered.txt ${F_SEIS}catalog_clustered.txt > ${F_SEIS}pre_cluster_cmt.txt
      cat ${F_SEIS}eq_culled.txt ${F_SEIS}eqs.txt > ${F_SEIS}pre_cluster_cmt.txt
      gawk '
        (FNR==NR){
          id[$6]=$6;
          cluster[$6]=$8
        }
        (FNR != NR) {
          split($2, ids, "+")
          if (ids[2] in id) {
            print $0, cluster[ids[2]]
          } else {
            print $0, 1
          }
        }' ${F_SEIS}pre_cluster_cmt.txt $CMTFILE > ${F_CMT}cmt_declustered.txt
      if [[ -s ${F_CMT}cmt_declustered.txt ]]; then
        CMTFILE=$(abs_path  ${F_CMT}cmt_declustered.txt)
      fi
    fi

    # Now sort the remaining focal mechanisms in the same manner as the seismicity

    if [[ $dozsortflag -eq 1 ]]; then
      info_msg "Sorting focal mechanisms by $ZSORTTYPE"
        case $ZSORTTYPE in
          "depth")
            case $CMTTYPE in
              CENTROID) SORTFIELD=7;;
              ORIGIN) SORTFIELD=10;;
            esac
          ;;
          "time")
            SORTFIELD=4
          ;;
          "mag")
            SORTFIELD=13
          ;;
          *)
            info_msg "[-zcsort]: CMT Sort field $ZSORTTYPE not recognized. Using depth."
            SORTFIELD=3
          ;;
        esac
      [[ $ZSORTDIR =~ "down" ]] && sort -n -k $SORTFIELD,$SORTFIELD $CMTFILE > ${F_CMT}cmt_sort.dat
      [[ $ZSORTDIR =~ "up" ]] && sort -n -r -k $SORTFIELD,$SORTFIELD $CMTFILE > ${F_CMT}cmt_sort.dat
      CMTFILE=$(abs_path ${F_CMT}cmt_sort.dat)
    fi

    # Rescale CMT magnitudes to match rescaled seismicity, if that option is set
    # This function assumes that the CMT file included the epoch seconds

    # Ideally we would do the rescaling at the moment of plotting and not make new
    # files, but I'm not sure how to do that with psmeca

    # CMTRESCALE=$(echo "$CMTSCALE * $SEISSCALE " | bc -l)  # * $SEISSCALE

    # if [[ $SCALEEQS -eq 1 ]]; then
    #   info_msg "Scaling CMT earthquake magnitudes for display only"
    #
    #   # This script applies a stretch function to the magnitudes to allow
    #   # non-linear rescaling of focal mechanisms.
    #
    #   gawk < $CMTFILE -v str=$SEISSTRETCH -v sref=$SEISSTRETCH_REFMAG '{
    #     mw=$13
    #     mwmod = (mw^str)/(sref^(str-1))
    #     a=sprintf("%E", 10^((mwmod + 10.7)*3/2))
    #     split(a,b,"+")  # mantissa
    #     split(a,c,"E")  # exponent
    #     oldmantissa=$14
    #     oldexponent=$15
    #     $14=c[1]
    #     $15=b[2]
    #     # New exponent for principal axes
    #     $22=b[2]
    #     # Scale principal axes by ratio of mantissas
    #     $23=$23*c[1]/$14
    #     $26=$26*c[1]/$14
    #     $29=$29*c[1]/$14
    #
    #     # New exponent for moment tensor
    #     $32=b[2]
    #     # Scale moment tensor components by the ratio of the mantissas
    #     $33=$33*c[1]/$14
    #     $34=$34*c[1]/$14
    #     $35=$35*c[1]/$14
    #     $36=$36*c[1]/$14
    #     $37=$37*c[1]/$14
    #     $38=$38*c[1]/$14
    #
    #     # Output the rescaled focal mechanism file line by line
    #     print
    #   }' > ${F_CMT}cmt_scale.dat
    #   CMTFILE=$(abs_path ${F_CMT}cmt_scale.dat)
    # fi


    ##############################################################################
    # Save focal mechanisms in a psmeca+ format based on the selected format type
    # so that we can plot them with psmeca.
    # Also calculate and save focal mechanism axes, nodal planes, and slip vectors

    touch ${F_CMT}cmt_thrust.txt ${F_CMT}cmt_normal.txt ${F_CMT}cmt_strikeslip.txt
    touch ${F_KIN}t_axes_thrust.txt ${F_KIN}n_axes_thrust.txt ${F_KIN}p_axes_thrust.txt  \
          ${F_KIN}t_axes_normal.txt ${F_KIN}n_axes_normal.txt ${F_KIN}p_axes_normal.txt \
          ${F_KIN}t_axes_strikeslip.txt ${F_KIN}n_axes_strikeslip.txt ${F_KIN}p_axes_strikeslip.txt

    #   1             	2	 3      4 	          5	           6              	7	         8	         9	          10	             11	           12 13        14	      15	     16	  17	   18	     19  	20	   21	      22	  23	 24 	25	 26 	 27	  28	  29	 30	  31	      32	 33 34	 35  36	 37	 38	         39
    # idcode	event_code	id	epoch	lon_centroid	lat_centroid	depth_centroid	lon_origin	lat_origin	depth_origin	author_centroid	author_origin	MW	mantissa	exponent	strike1	dip1	rake1	strike2	dip2	rake2	exponent	Tval	Taz	Tinc	Nval	Naz	Ninc	Pval	Paz	Pinc	exponent	Mrr	Mtt	Mpp	Mrt	Mrp	Mtp	centroid_dt

    # This should go into an external utility script that converts from tectoplot->psmeca format

    cd ${F_KIN}
    gawk < $CMTFILE -v doscale=${SCALEEQS} -v str=${SEISSTRETCH} -v sref=${SEISSTRETCH_REFMAG} -v fmt=$CMTFORMAT -v cmttype=$CMTTYPE -v minmag="${CMT_MINMAG}" -v maxmag="${CMT_MAXMAG}" '
      @include "tectoplot_functions.awk"
      # function abs(v) { return (v>0)?v:-v}
      BEGIN { pi=atan2(0,-1) }
      {
        if (cmttype=="CENTROID") {
          lon=$5; lat=$6; depth=$7;
          altlon=$8; altlat=$9; altdepth=$10;
        } else {
          lon=$8; lat=$9; depth=$10;
          altlon=$5; altlat=$6; altdepth=$7;
        }

        if (lon != "none" && lat != "none") {

          event_code=$2
          iso8601_code=$3
          Mw=$13
          mantissa=$14;exponent=$15
          strike1=$16;dip1=$17;rake1=$18;strike2=$19;dip2=$20;rake2=$21
          Mrr=$33; Mtt=$34; Mpp=$35; Mrt=$36; Mrp=$37; Mtp=$38
          Tval=$23; Taz=$24; Tinc=$25; Nval=$26; Naz=$27; Ninc=$28; Pval=$29; Paz=$30; Pinc=$31;
          clusterid=($40+0==$40)?$40:0

          epoch=iso8601_to_epoch(iso8601_code)

          timecode=$3

          mwmod = (Mw^str)/(sref^(str-1))
          split_a=sprintf("%E", 10^((mwmod + 10.7)*3/2))
          split(split_a,split_b,"+")  # mantissa
          split(split_a,split_c,"E")  # exponent

          # New mantissa and exponent
          scale_mantissa=split_c[1]
          scale_exponent=split_b[2]

          # Scale principal axes by ratio of the new and old mantissas
          scale_Tval=Tval*scale_mantissa/mantissa
          scale_Nval=Nval*scale_mantissa/mantissa
          scale_Pval=Pval*scale_mantissa/mantissa

          # Scale moment tensor components by the ratio of the new and old mantissas
          scale_Mrr=Mrr*scale_mantissa/mantissa
          scale_Mtt=Mtt*scale_mantissa/mantissa
          scale_Mpp=Mpp*scale_mantissa/mantissa
          scale_Mrt=Mrt*scale_mantissa/mantissa
          scale_Mrp=Mrp*scale_mantissa/mantissa
          scale_Mtp=Mtp*scale_mantissa/mantissa

          if (fmt == "MomentTensor") {
            # 1   2   3     4   5   6   7   8   9   10  11     12     13       14       15    16        17
            # lon lat depth mrr mtt mff mrt mrf mtf exp altlon altlat event_id altdepth epoch clusterid timecode

            # We simultaneously output a non-scaled data file (cmt.dat) and a scaled data file (cmt_scale.dat)

            if (doscale==1) {
              if (substr($1,2,1) == "T") {
                print lon, lat, depth, scale_Mrr, scale_Mtt, scale_Mpp, scale_Mrt, scale_Mrp, scale_Mtp, scale_exponent, altlon, altlat, event_code, altdepth, epoch, clusterid, iso8601_code > "cmt_thrust.txt"
              } else if (substr($1,2,1) == "N") {
                print lon, lat, depth, scale_Mrr, scale_Mtt, scale_Mpp, scale_Mrt, scale_Mrp, scale_Mtp, scale_exponent, altlon, altlat, event_code, altdepth, epoch, clusterid, iso8601_code  > "cmt_normal.txt"
              } else {
                print lon, lat, depth, scale_Mrr, scale_Mtt, scale_Mpp, scale_Mrt, scale_Mrp, scale_Mtp, scale_exponent, altlon, altlat, event_code, altdepth, epoch, clusterid, iso8601_code  > "cmt_strikeslip.txt"
              }
            } else {
              if (substr($1,2,1) == "T") {
                print lon, lat, depth, Mrr, Mtt, Mpp, Mrt, Mrp, Mtp, exponent, altlon, altlat, event_code, altdepth, epoch, clusterid, iso8601_code > "cmt_thrust.txt"
              } else if (substr($1,2,1) == "N") {
                print lon, lat, depth, Mrr, Mtt, Mpp, Mrt, Mrp, Mtp, exponent, altlon, altlat, event_code, altdepth, epoch, clusterid, iso8601_code  > "cmt_normal.txt"
              } else {
                print lon, lat, depth, Mrr, Mtt, Mpp, Mrt, Mrp, Mtp, exponent, altlon, altlat, event_code, altdepth, epoch, clusterid, iso8601_code  > "cmt_strikeslip.txt"
              }
            }
            print lon, lat, depth, Mrr, Mtt, Mpp, Mrt, Mrp, Mtp, exponent, altlon, altlat, event_code, altdepth, epoch, clusterid, iso8601_code  > "cmt_noscale.dat"
            print lon, lat, depth, scale_Mrr, scale_Mtt, scale_Mpp, scale_Mrt, scale_Mrp, scale_Mtp, scale_exponent, altlon, altlat, event_code, altdepth, epoch, clusterid, iso8601_code  > "cmt_rescale.dat"
          }

          if (substr($1,2,1) == "T") {
            print lon, lat, Taz, Tinc > "t_axes_thrust.txt"
            print lon, lat, Naz, Ninc > "n_axes_thrust.txt"
            print lon, lat, Paz, Pinc > "p_axes_thrust.txt"
          } else if (substr($1,2,1) == "N") {
            print lon, lat, Taz, Tinc> "t_axes_normal.txt"
            print lon, lat, Naz, Ninc > "n_axes_normal.txt"
            print lon, lat, Paz, Pinc > "p_axes_normal.txt"
          } else if (substr($1,2,1) == "S") {
            print lon, lat, Taz, Tinc > "t_axes_strikeslip.txt"
            print lon, lat, Naz, Ninc > "n_axes_strikeslip.txt"
            print lon, lat, Paz, Pinc > "p_axes_strikeslip.txt"
          }

          if (Mw >= minmag && Mw <= maxmag) {
            if (substr($1,2,1) == "T") {
              print lon, lat, depth, strike1, dip1, rake1, strike2, dip2, rake2, mantissa, exponent, altlon, altlat, event_code, altdepth, epoch, clusterid > "kin_thrust.txt"
            } else if (substr($1,2,1) == "N") {
              print lon, lat, depth, strike1, dip1, rake1, strike2, dip2, rake2, mantissa, exponent, altlon, altlat, event_code, altdepth, epoch, clusterid > "kin_normal.txt"
            } else {
              print lon, lat, depth, strike1, dip1, rake1, strike2, dip2, rake2, mantissa, exponent, altlon, altlat, event_code, altdepth, epoch, clusterid > "kin_strikeslip.txt"
            }
          }
        }
      }'

      [[ -e cmt_thrust.txt ]] && mv cmt_thrust.txt ../${F_CMT}
      [[ -e cmt_normal.txt ]] && mv cmt_normal.txt ../${F_CMT}
      [[ -e cmt_strikeslip.txt ]] && mv cmt_strikeslip.txt ../${F_CMT}
      [[ -e cmt_noscale.dat ]] && mv cmt_noscale.dat ../${F_CMT}
      [[ -e cmt_rescale.dat ]] && mv cmt_rescale.dat ../${F_CMT}

      if [[ $SCALEEQS -eq 1 ]]; then
        ln -s ../${F_CMT}cmt_rescale.dat ../${F_CMT}cmt.dat
      else
        ln -s ../${F_CMT}cmt_noscale.dat ../${F_CMT}cmt.dat
      fi

    touch kin_thrust.txt kin_normal.txt kin_strikeslip.txt

  	# Generate the kinematic vectors
  	# For thrust faults, take the slip vector associated with the shallower dipping nodal plane

    gawk < kin_thrust.txt -v symsize=$SYMSIZE1 '{if($8 > 45) print $1, $2, ($7+270) % 360, symsize; else print $1, $2, ($4+270) % 360, symsize;  }' > thrust_gen_slip_vectors_np1.txt
    gawk < kin_thrust.txt -v symsize=$SYMSIZE2 '{if($8 > 45) print $1, $2, ($4+90) % 360, symsize; else print $1, $2, ($7+90) % 360, symsize;  }' > thrust_gen_slip_vectors_np1_downdip.txt
    gawk < kin_thrust.txt -v symsize=$SYMSIZE3 '{if($8 > 45) print $1, $2, ($4) % 360, symsize ; else print $1, $2, ($7) % 360, symsize ;  }' > thrust_gen_slip_vectors_np1_str.txt

    gawk  < kin_thrust.txt -v symsize=$SYMSIZE1 '{if($8 > 45) print $1, $2, ($4+270) % 360, symsize; else print $1, $2, ($7+270) % 360, symsize;  }' > thrust_gen_slip_vectors_np2.txt
    gawk < kin_thrust.txt -v symsize=$SYMSIZE2 '{if($8 > 45) print $1, $2, ($7+90) % 360, symsize; else print $1, $2, ($4+90) % 360, symsize ;  }' > thrust_gen_slip_vectors_np2_downdip.txt
    gawk < kin_thrust.txt -v symsize=$SYMSIZE3 '{if($8 > 45) print $1, $2, ($7) % 360, symsize ; else print $1, $2, ($4) % 360, symsize ;  }' > thrust_gen_slip_vectors_np2_str.txt

    gawk < kin_strikeslip.txt -v symsize=$SYMSIZE1 '{ print $1, $2, ($7+270) % 360, symsize }' > strikeslip_slip_vectors_np1.txt
    gawk < kin_strikeslip.txt  -v symsize=$SYMSIZE1 '{ print $1, $2, ($4+270) % 360, symsize }' > strikeslip_slip_vectors_np2.txt

    gawk < kin_normal.txt  -v symsize=$SYMSIZE1 '{ print $1, $2, ($7+270) % 360, symsize }' > normal_slip_vectors_np1.txt
    gawk < kin_normal.txt -v symsize=$SYMSIZE1 '{ print $1, $2, ($4+270) % 360, symsize }' > normal_slip_vectors_np2.txt

    cd ..
  fi


  #### Back to seismicity for some reason

  if [[ $REMOVE_DEFAULTDEPTHS -eq 1 && -e ${F_SEIS}eqs.txt ]]; then
    echo "Removing earthquakes with poorly determined origin depths ${REMOVE_DEFAULTDEPTHS_MAXMAG}"
    [[ $REMOVE_DEFAULTDEPTHS_WITHPLOT -eq 1 ]] && info_msg "Plotting removed events separately"
    # Plotting in km instead of in map geographic coords.
    gawk < ${F_SEIS}eqs.txt -v defdepmag=$REMOVE_DEFAULTDEPTHS_MAXMAG '{
      if ($4 <= defdepmag) {
        if ($3 == 10 || $3 == 30 || $3 == 33 || $3 == 5 ||$3 == 1 || $3 == 6  || $3 == 35 ) {
          seen[$3]++
          print > "/dev/stderr"
        } else {
          print
        }
      } else {
        print
      }
    }
    ' > ${F_SEIS}tmp.dat 2>${F_SEIS}removed_eqs.txt
    mv ${F_SEIS}tmp.dat ${F_SEIS}eqs.txt
  fi

  if [[ $zcnoscaleflag -eq 1 ]]; then
    if [[ -e ${F_SEIS}eqs.txt ]]; then
      gawk < ${F_SEIS}eqs.txt -v nssize=${NOSCALE_SEISSIZE} '{print $1, $2, $3, nssize, $5, $6, $7, $8}' > ${F_SEIS}eqs_scaled.txt
    fi
  else
    # Print 8 fields in case we are declustering
    if [[ $SCALEEQS -eq 1 && -e ${F_SEIS}eqs.txt ]]; then
      [[ -e ${F_SEIS}removed_eqs.txt ]] && gawk < ${F_SEIS}removed_eqs.txt -v str=$SEISSTRETCH -v sref=$SEISSTRETCH_REFMAG '{print $1, $2, $3, ($4^str)/(sref^(str-1)), $5, $6, $7, $8}' > ${F_SEIS}removed_eqs_scaled.txt
      gawk < ${F_SEIS}eqs.txt -v str=$SEISSTRETCH -v sref=$SEISSTRETCH_REFMAG 'BEGIN{OFMT="%f"} {print $1, $2, $3, ($4^str)/(sref^(str-1)), $5, $6, $7, $8}' > ${F_SEIS}eqs_scaled.txt
    fi
  fi

  if [[ $zhighlightflag -eq 1 ]]; then
    for this_z in ${zhigh[@]}; do
      gawk -v id=${this_z} < ${F_SEIS}eqs.txt '($6==id) { print }' >> ${F_SEIS}eqs_highlight.txt
    done
  fi

  ################################################################################
  #####          Manage grid spacing and style                               #####
  ################################################################################

  ##### Create the grid of lat/lon points to resolve as plate motion vectors
  # Default is a lat/lon spaced grid

  ##### MAKE FIBONACCI GRID POINTS
  if [[ $gridfibonacciflag -eq 1 ]]; then
    FIB_PHI=1.618033988749895

    echo "" | gawk -v n=$FIB_N  -v minlat="$MINLAT" -v maxlat="$MAXLAT" -v minlon="$MINLON" -v maxlon="$MAXLON" '
    @include "tectoplot_functions.awk"
    # function asin(x) { return atan2(x, sqrt(1-x*x)) }
    BEGIN {
      phi=1.618033988749895;
      pi=3.14159265358979;
      phi_inv=1/phi;
      ga = 2 * phi_inv * pi;
    } END {
      for (i=-n; i<=n; i++) {
        longitude = ((ga * i)*180/pi)%360;

        latitude = asin((2 * i)/(2*n+1))*180/pi;
        # LON EDIT TAG - TEST
        if ( (latitude <= maxlat) && (latitude >= minlat)) {
          if (test_lon(minlon, maxlon, longitude)==1) {
            if (longitude < -180) {
              longitude=longitude+360;
            }
            if (longitude > 180) {
              longitude=longitude-360
            }
            print longitude, latitude
          }
        }
      }
    }' > gridfile.txt
    gawk < gridfile.txt '{print $2, $1}' > gridswap.txt
  fi

  if [[ $makegridflag_gridfile -eq 1 ]]; then
    echo getting $PI_GRIDFILE
    cp $PI_GRIDFILE gridfile.txt
    gawk < $PI_GRIDFILE '{print $2, $1}' > gridswap.txt
  fi

  ##### MAKE LAT/LON REGULAR GRID
  if [[ $makelatlongridflag -eq 1 ]]; then
    for i in $(seq $MINLAT $GRIDSTEP $MAXLAT); do
    	for j in $(seq $MINLON $GRIDSTEP $MAXLON); do
    		echo $j $i >> gridfile.txt
    		echo $i $j >> gridswap.txt
    	done
    done
  fi

  ################################################################################
  #####           Calculate plate motions                                    #####
  ################################################################################

  if [[ $plotplates -eq 1 ]]; then

    info_msg "[-p]: $PLATES $POLES"

    # Calculates relative plate motion along plate boundaries - most time consuming!
    # Calculates plate edge midpoints and plate edge azimuths
    # Calculates relative motion of grid points within plates
    # Calculates reference plate from reference point location
    # Calculates small circle rotations for display

    # MORVEL, GBM, and GSRM plate data are sanitized for CW polygons cut at the anti-meridian and
    # with pole cap plates extended to 90 latitude. TDEFNODE plates are expected to
    # satisfy the same criteria but can be CCW oriented; we cut the plates by the ROI
    # and then change their CW/CCW direction anyway.

    # Euler poles are searched for using the ID component of any plate called ID_N.
    # This allows us to have multiple clean polygons for a given Euler pole.

    # We calculate plate boundary segment azimuths on the fly to infer tectonic setting

    # We should probably pre-process things because global datasets can have a lot of points
    # and take up a lot of time to determine plate pairs, etc. But exactly how to deal with
    # clipped data is a problem.

    # STEP 1: Identify the plates that fall within the AOI and extract their polygons and Euler poles

    # Cut the plate file by the ROI.


    # PLATES is a file containing closed, oriented plate polygons
    # > ID_N
    # lon1 lat1
    # lon2 lat2
    # ...
    # lonN latN

    # POLES is a file containing Euler poles:
    # ID LON LAT RATE

    # gawk < $PLATES '{
    #   print $1, $2, $3
    # }'


    # Not sure why we need to clip the plate polygons in any case?

    # This step FAILS to select plates on the other side of the dateline...

    gmt spatial $PLATES -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} -C $VERBOSE | gawk  '{print $1, $2}' > ${F_PLATES}map_plates_clip_b.txt

    # Sometimes gmt spatial will produce a zero-area polygon due to strange geometry issues
    # So strip out any polygons with zero area

    gmt spatial ${F_PLATES}map_plates_clip_b.txt -Q > ${F_PLATES}plate_areas.txt

    gawk '
    BEGIN {
      dontprint=0
      numplate=1
    }
    (NR==FNR) {
      area[NR]=$1
    }
    (NR != FNR) {
      if ($1 == ">") {
        if (area[numplate++] == 0) {
          dontprint=1
        } else {
          dontprint=0
        }
      }
      if (dontprint==0) {
        print
      }
    }' ${F_PLATES}plate_areas.txt ${F_PLATES}map_plates_clip_b.txt  > ${F_PLATES}map_plates_clip_a.txt


    # Stupid tests for longitude range because gmt spatial has problem cutting everywhere

    # Possibly this is due to not having -fg in gmt spatial
    if [[ $(echo "$MINLON < -180 && $MAXLON > -180" | bc) -eq 1 ]]; then
      # echo "Also cutting on other side of dateline neg:"
      MINLONCUT=$(echo "${MINLON}+360" | bc -l)
      # echo gmt spatial $PLATES -R${MINLONCUT}/180/$MINLAT/$MAXLAT -C
      gmt spatial $PLATES -R${MINLONCUT}/180/$MINLAT/$MAXLAT -C $VERBOSE | gawk  '{print $1, $2}' >> ${F_PLATES}map_plates_clip_a.txt
    elif [[ $(echo "$MINLON < 180 && $MAXLON > 180" | bc) -eq 1 ]]; then
      # echo "Also cutting on other side of dateline pos:"
      MAXLONCUT=$(echo "${MAXLON}-360" | bc -l)
      # echo gmt spatial $PLATES -R-180/${MAXLONCUT}/$MINLAT/$MAXLAT -C
      gmt spatial $PLATES -R-180/${MAXLONCUT}/$MINLAT/$MAXLAT -C $VERBOSE | gawk  '{print $1, $2}' >> ${F_PLATES}map_plates_clip_a.txt
    elif [[ $(echo "$MINLON >= 180 && $MAXLON > 180 && $MAXLON <= 360" | bc) -eq 1 ]]; then
      MINLONFIX=$(echo "${MINLON} - 360" | bc -l)
      MAXLONFIX=$(echo "${MAXLON} - 360" | bc -l)
      # echo gmt spatial $PLATES -R${MINLONFIX}/${MAXLONFIX}/$MINLAT/$MAXLAT -C
      gmt spatial $PLATES -R${MINLONFIX}/${MAXLONFIX}/$MINLAT/$MAXLAT -C $VERBOSE | gawk  '{print $1, $2}' >> ${F_PLATES}map_plates_clip_a.txt
    fi

    # Ensure CW orientation of clipped polygons.
    # GMT spatial strips out the header labels for some reason.
    gmt spatial ${F_PLATES}map_plates_clip_a.txt -E+n $VERBOSE > ${F_PLATES}map_plates_clip_orient.txt

    # Check the special case that there are no polygon boundaries within the region
    numplates=$(grep ">" ${F_PLATES}map_plates_clip_a.txt | wc -l)
    numplatesorient=$(grep ">" ${F_PLATES}map_plates_clip_orient.txt | wc -l)

    if [[ $numplates -eq 1 && $numplatesorient -eq 0 ]]; then
      grep ">" ${F_PLATES}map_plates_clip_a.txt > ${F_PLATES}new.txt
      cat ${F_PLATES}map_plates_clip_orient.txt >> ${F_PLATES}new.txt
      cp ${F_PLATES}new.txt ${F_PLATES}map_plates_clip_orient.txt
    fi

    grep ">" ${F_PLATES}map_plates_clip_a.txt > ${F_PLATES}map_plates_clip_ids.txt

    IFS=$'\n' read -d '' -r -a pids < ${F_PLATES}map_plates_clip_ids.txt
    i=0

    # Now read through the file and replace > with the next value in the pids array. This replaces names that GMT spatial stripped out for no good reason at all...
    while read p; do
      if [[ ${p:0:1} == '>' ]]; then
        printf  "%s\n" "${pids[i]}" >> ${F_PLATES}map_plates_clip.txt
        i=$i+1
      else
        printf "%s\n" "$p" >> ${F_PLATES}map_plates_clip.txt
      fi
    done < ${F_PLATES}map_plates_clip_orient.txt

    grep ">" ${F_PLATES}map_plates_clip.txt | uniq | gawk  '{print $2}' > ${F_PLATES}plate_id_list.txt



    if [[ $outputplatesflag -eq 1 ]]; then
      echo "Plates in model:"

      if [[ -s $PLATENAMES ]]; then
        cat $PLATENAMES
        echo "Plates within AOI"
        gawk '
          (NR == FNR) {
            key=$1
            $1=""
            string=$0
            plate[key]=string
          }
          (NR!=FNR) {
            split($1, v, "_")
            print v[1], plate[v[1]]
          }
        ' ${PLATENAMES} ${F_PLATES}plate_id_list.txt | tr '\n' '\t'
        echo ""
      else
        echo "Plates within AOI"
        gawk < ${F_PLATES}plate_id_list.txt '{
          split($1, v, "_");
          for(i=1; i<length(v); i++) {
            printf "%s\n", v[i]
          }
        }' | tr '\n' '\t'
        echo ""
        gawk < $POLES '{print $1}' | tr '\n' '\t'
        echo ""
      fi
      exit
    fi

    info_msg "Found plates ..."
    [[ $narrateflag -eq 1 ]] && cat ${F_PLATES}plate_id_list.txt
    info_msg "Extracting the full polygons of intersected plates..."

    v=($(cat ${F_PLATES}plate_id_list.txt | tr ' ' '\n'))
    i=0
    j=1;
    rm -f ${F_PLATES}plates_in_view.txt
    echo "> END" >> ${F_PLATES}map_plates_clip.txt

    # STEP 2: Calculate midpoint locations and azimuth of segment for plate boundary segments

  	# Calculate the azimuth between adjacent line segment points (assuming clockwise oriented polygons)
  	rm -f ${F_PLATES}plateazfile.txt

    # We are too clever by half and just shift the whole plate file one line down and then calculate the azimuth between points:
  	sed 1d < ${F_PLATES}map_plates_clip.txt > ${F_PLATES}map_plates_clip_shift1.txt
  	paste ${F_PLATES}map_plates_clip.txt ${F_PLATES}map_plates_clip_shift1.txt | grep -v "\s>" > ${F_PLATES}geodin.txt

    # Script to return azimuth and midpoint between a pair of input points.
    # Comes within 0.2 degrees of geod() results over large distances, while being symmetrical which geod isn't
    # We need perfect symmetry in order to create exact point pairs in adjacent polygons

    gawk < ${F_PLATES}geodin.txt '{print $1, $2, $3, $4}' | gawk  '
    @include "tectoplot_functions.awk"
    # function acos(x) { return atan2(sqrt(1-x*x), x) }
        {
          if ($1 == ">") {
            print $1, $2;
          }
          else {
            lon1 = $1*3.14159265358979/180;
            lat1 = $2*3.14159265358979/180;
            lon2 = $3*3.14159265358979/180;
            lat2 = $4*3.14159265358979/180;
            Bx = cos(lat2)*cos(lon2-lon1);
            By = cos(lat2)*sin(lon2-lon1);
            latMid = atan2(sin(lat1)+sin(lat2), sqrt((cos(lat1)+Bx)*(cos(lat1)+Bx)+By*By));
            lonMid = lon1+atan2(By, cos(lat1)+Bx);
            theta = atan2(sin(lon2-lon1)*cos(lat2), cos(lat1)*sin(lat2)-sin(lat1)*cos(lat2)*cos(lon2-lon1));
            d = acos(sin(lat1)*sin(lat2) + cos(lat1)*cos(lat2)*cos(lon2-lon1) ) * 6371;
            printf "%.5f %.5f %.3f %.3f\n", lonMid*180/3.14159265358979, latMid*180/3.14159265358979, (theta*180/3.14159265358979+360-90)%360, d;
          };
        }' > ${F_PLATES}plateazfile.txt

# Not needed for now
        # gawk < ${F_PLATES}geodin.txt '{print $1, $2, $3, $4}' | gawk  '
        # @include "tectoplot_functions.awk"
        # # function acos(x) { return atan2(sqrt(1-x*x), x) }
        #     {
        #       if ($1 == ">") {
        #         # nothing
        #         # print $1, $2;
        #         fake=1
        #       }
        #       else {
        #         lon1 = $1*3.14159265358979/180;
        #         lat1 = $2*3.14159265358979/180;
        #         lon2 = $3*3.14159265358979/180;
        #         lat2 = $4*3.14159265358979/180;
        #         Bx = cos(lat2)*cos(lon2-lon1);
        #         By = cos(lat2)*sin(lon2-lon1);
        #         latMid = atan2(sin(lat1)+sin(lat2), sqrt((cos(lat1)+Bx)*(cos(lat1)+Bx)+By*By));
        #         lonMid = lon1+atan2(By, cos(lat1)+Bx);
        #         theta = atan2(sin(lon2-lon1)*cos(lat2), cos(lat1)*sin(lat2)-sin(lat1)*cos(lat2)*cos(lon2-lon1));
        #         d = acos(sin(lat1)*sin(lat2) + cos(lat1)*cos(lat2)*cos(lon2-lon1) ) * 6371;
        #         printf "%.5f %.5f %.3f %.3f %s %s %s %s\n", lonMid*180/3.14159265358979, latMid*180/3.14159265358979, (theta*180/3.14159265358979+360-90)%360, d, $1, $2, $3, $4;
        #       };
        #     }' > ${F_PLATES}plateazfile_withpts.txt

    # plateazfile.txt now contains midpoints with azimuth and distance of segments. Multiple
    # headers per plate are possible if multiple disconnected lines were generated
    # outfile is midpointlon midpointlat azimuth

    # This removes the lines starting with >
    cat ${F_PLATES}plateazfile.txt | gawk  '{if (!/^>/) print $1, $2}' > ${F_PLATES}halfwaypoints.txt
    # output is lat1 lon1 midlat1 midlon1 az backaz distance

  	cp ${F_PLATES}plate_id_list.txt ${F_PLATES}map_ids_end.txt
  	echo "END" >> ${F_PLATES}map_ids_end.txt

    # Extract the Euler poles for the map_ids.txt plates
    # We need to match XXX from XXX_N
    v=($(cat ${F_PLATES}plate_id_list.txt | tr ' ' '\n'))
    i=0
    while [[ $i -lt ${#v[@]} ]]; do
        pid="${v[$i]%_*}"
        repid="${v[$i]}"
        info_msg "Looking for pole $pid and replacing with $repid"
        grep "$pid\s" < $POLES | sed "s/$pid/$repid/" >> ${F_PLATES}polesextract_init.txt
        i=$i+1
    done

    # Extract the unique Euler poles
    gawk '!seen[$1]++' ${F_PLATES}polesextract_init.txt > ${F_PLATES}polesextract.txt

    # Define the reference plate (zero motion plate) either manually or using reference point (reflon, reflat)
    if [[ $manualrefplateflag -eq 1 ]]; then
      REFPLATE=$(grep ^$MANUALREFPLATE ${F_PLATES}polesextract.txt | head -n 1 | gawk  '{print $1}')
      info_msg "Manual reference plate is $REFPLATE"
    else
      # We use a tiny little polygon to clip the map_plates and determine the reference polygon.
      # Not great but GMT spatial etc don't like the map polygon data...
      REFWINDOW=0.001

      Y1=$(echo "$REFPTLAT-$REFWINDOW" | bc -l)
      Y2=$(echo "$REFPTLAT+$REFWINDOW" | bc -l)
      X1=$(echo "$REFPTLON-$REFWINDOW" | bc -l)
      X2=$(echo "$REFPTLON+$REFWINDOW" | bc -l)

      nREFPLATE=$(gmt spatial ${F_PLATES}map_plates_clip.txt -R$X1/$X2/$Y1/$Y2 -C $VERBOSE  | grep "> " | head -n 1 | gawk  '{print $2}')
      info_msg "Automatic reference plate is $nREFPLATE"

      if [[ -z "$nREFPLATE" ]]; then
          info_msg "Could not determine reference plate from reference point"
          REFPLATE=$DEFREF
      else
          REFPLATE=$nREFPLATE
      fi
    fi

    # Set Euler pole for reference plate
    if [[ $defaultrefflag -eq 1 ]]; then
      info_msg "Using Euler pole $DEFREF = [0 0 0]"
      reflat=0
      reflon=0
      refrate=0
    else
    	info_msg "Defining reference pole from $POLESRC | $REFPLATE vs $DEFREF pole"
    	info_msg "Looking for reference plate $REFPLATE in pole file $POLES"

    	# Have to search for lines beginning with REFPLATE with a space after to avoid matching e.g. both Burma and BurmanRanges
    	reflat=`grep "^$REFPLATE\s" < ${F_PLATES}polesextract.txt | gawk  '{print $2}'`
    	reflon=`grep "^$REFPLATE\s" < ${F_PLATES}polesextract.txt | gawk  '{print $3}'`
    	refrate=`grep "^$REFPLATE\s" < ${F_PLATES}polesextract.txt | gawk  '{print $4}'`

    	info_msg "Found reference plate Euler pole $REFPLATE vs $DEFREF $reflat $reflon $refrate"
    fi

  	# Set the GPS to the reference plate if not overriding it from the command line

  	if [[ $gpsoverride -eq 0 ]]; then
      info_msg "[-p]: REFPLATE is ${REFPLATE}"
      if [[ $defaultrefflag -eq 1 ]]; then
        # ITRF08 is likely similar to other reference frames.
        GPS_FILE=$(echo ${GPSDIR}"/GPS_ITRF08.gmt")
      else
        # REFPLATE now ends in a _X code to accommodate multiple subplates with the same pole.
        # This will break if _X becomes _XX (10 or more sub-plates)
        if [[ -z $REFPLATE ]]; then
          REFPLATE=$DEFREF
        else
          RGP=${REFPLATE::${#REFPLATE}-2}
        fi
        if [[ -e ${GPSDIR}"/GPS_${RGP}.gmt" ]]; then
          GPS_FILE=$(echo ${GPSDIR}"/GPS_${RGP}.gmt")
        else
          info_msg "No GPS file ${GPSDIR}/GPS_${RGP}.gmt exists. Keeping default"
        fi
      fi
    fi


    if [[ $printplatesflag -eq 1 ]]; then
      echo "looking"
      for this_plate in ${PPOLE_PLATE[@]}; do
        # Calculate Euler poles relative to reference plate
        pllat=`grep "^${this_plate}\s" < ${F_PLATES}polesextract.txt | gawk  '{print $2}'`
        pllon=`grep "^${this_plate}\s" < ${F_PLATES}polesextract.txt | gawk  '{print $3}'`
        plrate=`grep "^${this_plate}\s" < ${F_PLATES}polesextract.txt | gawk  '{print $4}'`
        # Calculate resultant Euler pole
        info_msg "Euler poles ${this_plate} vs $DEFREF: $pllat $pllon $plrate vs $reflat $reflon $refrate"
        echo $pllat $pllon $plrate $reflat $reflon $refrate | gawk -f $EULERADD_AWK

      done
    fi

    # Iterate over the plates. We create plate polygons, identify Euler poles, etc.

    # Slurp the plate IDs from map_plates_clip.txt
    v=($(grep ">" ${F_PLATES}map_plates_clip.txt | gawk  '{print $2}' | tr ' ' '\n'))
  	i=0
  	j=1
  	while [[ $i -lt ${#v[@]}-1 ]]; do

      # Create plate files .pldat
      info_msg "Extracting between ${v[$i]} and ${v[$j]}"
  		sed -n '/^> '${v[$i]}'$/,/^> '${v[$j]}'$/p' ${F_PLATES}map_plates_clip.txt | sed '$d' > "${F_PLATES}${v[$i]}.pldat"
  		echo " " >> "${F_PLATES}${v[$i]}.pldat"
  		# PLDAT files now contain the X Y coordinates and segment azimuth with a > PL header line and a single empty line at the end

  		# Calculate the true centroid of each polygon and output it to the label file
  		sed -e '2,$!d' -e '$d' "${F_PLATES}${v[$i]}.pldat" | gawk  '{
  			x[NR] = $1;
  			y[NR] = $2;
  		}
  		END {
  		    x[NR+1] = x[1];
  		    y[NR+1] = y[1];

  			  SXS = 0;
  		    SYS = 0;
  		    AS = 0;
  		    for (i = 1; i <= NR; ++i) {
  		    	J[i] = (x[i]*y[i+1]-x[i+1]*y[i]);
  		    	XS[i] = (x[i]+x[i+1]);
  		    	YS[i] = (y[i]+y[i+1]);
  		    }
  		    for (i = 1; i <= NR; ++i) {
  		    	SXS = SXS + (XS[i]*J[i]);
  		    	SYS = SYS + (YS[i]*J[i]);
  		    	AS = AS + (J[i]);
  			}
  			AS = 1/2*AS;

        # If AS is 0 which happens for degenerate polygons, return the first
        # coordinate. Otherwise, calculate and return the center point
        if (AS==0) {
          print x[1] "," y[1]
        } else {
          CX = 1/(6*AS)*SXS;
          CY = 1/(6*AS)*SYS;
          print CX "," CY
        }

  		}' > "${F_PLATES}${v[$i]}.centroid"

      cat "${F_PLATES}${v[$i]}.centroid" >> ${F_PLATES}map_centroids.txt

      # Calculate Euler poles relative to reference plate
      pllat=`grep "^${v[$i]}\s" < ${F_PLATES}polesextract.txt | gawk  '{print $2}'`
      pllon=`grep "^${v[$i]}\s" < ${F_PLATES}polesextract.txt | gawk  '{print $3}'`
      plrate=`grep "^${v[$i]}\s" < ${F_PLATES}polesextract.txt | gawk  '{print $4}'`
      # Calculate resultant Euler pole
      info_msg "Euler poles ${v[$i]} vs $DEFREF: $pllat $pllon $plrate vs $reflat $reflon $refrate"

      echo $pllat $pllon $plrate $reflat $reflon $refrate | gawk  -f $EULERADD_AWK  > ${F_PLATES}${v[$i]}.pole

      # Calculate motions of grid points from their plate's Euler pole

      if [[ $makegridflag -eq 1 ]]; then
      	# gridfile is in lat lon
      	# gridpts are in lon lat
        # Select the grid points within the plate amd calculate plate velocities at the grid points

        cat gridfile.txt | gmt select -: -F${F_PLATES}${v[$i]}.pldat $VERBOSE | gawk  '{print $2, $1}' > ${F_PLATES}${v[$i]}_gridpts.txt
        # gawk -f $EULERVEC_AWK -v eLat_d1=$pllat -v eLon_d1=$pllon -v eV1=$plrate -v eLat_d2=$reflat -v eLon_d2=$reflon -v eV2=$refrate ${F_PLATES}${v[$i]}_gridpts.txt > ${F_PLATES}${v[$i]}_velocities.txt
      
        gawk '
            @include "tectoplot_functions.awk" 
            NF {
              eulervec('${pllat}', '${pllon}', '${plrate}', '${reflat}', '${reflon}', '${refrate}', $2, $1)
              print eulervec_E, eulervec_N 
            }
          ' ${F_PLATES}${v[$i]}_gridpts.txt > ${F_PLATES}${v[$i]}_velocities.txt
 
      	paste -d ' ' ${F_PLATES}${v[$i]}_gridpts.txt ${F_PLATES}${v[$i]}_velocities.txt | gawk  '{print $2, $1, $3, $4, 0, 0, 1, "ID"}' > ${F_PLATES}${v[$i]}_platevecs.txt
      fi

      # Small circles for showing plate relative motions. Not the greatest or worst concept; partially broken???

      if [[ $platerotationflag -eq 1 ]]; then

        polelat=$(cat ${F_PLATES}${v[$i]}.pole | gawk '{print $1}')
        polelon=$(cat ${F_PLATES}${v[$i]}.pole | gawk '{print $2}')
        polerate=$(cat ${F_PLATES}${v[$i]}.pole | gawk '{print $3}')

        if [[ $(echo "$polerate == 0" | bc -l) -eq 1 ]]; then
          info_msg "Not generating small circles for reference plate"
          touch ${F_PLATES}${v[$i]}.smallcircles
        else
          centroidlat=`cat ${F_PLATES}${v[$i]}.centroid | gawk  -F, '{print $1}'`
          centroidlon=`cat ${F_PLATES}${v[$i]}.centroid | gawk  -F, '{print $2}'`
          info_msg "Generating small circles around pole $polelat $polelon"

          # Calculate the minimum and maximum colatitudes of points in .pldat file relative to Euler Pole
          #cos(AOB)=cos(latA)cos(latB)cos(lonB-lonA)+sin(latA)sin(latB)
          grep -v ">" ${F_PLATES}${v[$i]}.pldat | grep "\S" | gawk -v plat=$polelat -v plon=$polelon '
          @include "tectoplot_functions.awk"
          # function acos(x) { return atan2(sqrt(1-x*x), x) }
            BEGIN {
              maxdeg=0; mindeg=180;
            }
            {
              lon1 = plon*3.14159265358979/180;
              lat1 = plat*3.14159265358979/180;
              lon2 = $1*3.14159265358979/180;
              lat2 = $2*3.14159265358979/180;

              degd = 180/3.14159265358979*acos( cos(lat1)*cos(lat2)*cos(lon2-lon1)+sin(lat1)*sin(lat2) );
              if (degd < mindeg) {
                mindeg=degd;
              }
              if (degd > maxdeg) {
                maxdeg=degd;
              }
            }
            END {
              maxdeg=maxdeg+1;
              if (maxdeg >= 179) { maxdeg=179; }
              mindeg=mindeg-1;
              if (mindeg < 1) { mindeg=1; }
              printf "%.0f %.0f\n", mindeg, maxdeg
          }' > ${F_PLATES}${v[$i]}.colatrange.txt
          colatmin=$(cat ${F_PLATES}${v[$i]}.colatrange.txt | gawk  '{print $1}')
          colatmax=$(cat ${F_PLATES}${v[$i]}.colatrange.txt | gawk  '{print $2}')

          # Find the antipode for GMT project
          poleantilat=$(echo "0 - (${polelat})" | bc -l)
          poleantilon=$(echo "$polelon" | gawk  '{if ($1 < 0) { print $1+180 } else { print $1-180 } }')
          info_msg "Pole $polelat $polelon has antipode $poleantilat $poleantilon"

          # Generate small circle paths in colatitude range of plate
          echo making small circles for plate ${v[$i]}
          rm -f ${F_PLATES}${v[$i]}.smallcircles
          for j2 in $(seq $colatmin $LATSTEPS $colatmax); do
            echo "> -Z${j2}" >> ${F_PLATES}${v[$i]}.smallcircles
            # echo gmt project -T${polelon}/${polelat} -C${poleantilon}/${poleantilat} -G0.5/${j2} -L-360/0
            gmt project -T${polelon}/${polelat} -C${poleantilon}/${poleantilat} -G0.5/${j2} -L-360/0 $VERBOSE | gawk  '{print $1, $2}' >> ${F_PLATES}${v[$i]}.smallcircles
          done

          # Clip the small circle paths by the plate polygon
          gmt spatial ${F_PLATES}${v[$i]}.smallcircles -T${F_PLATES}${v[$i]}.pldat $VERBOSE | gawk  '{print $1, $2}' > ${F_PLATES}${v[$i]}.smallcircles_clip_1

          # We have trouble with gmt spatial giving us two-point lines segments. Remove all two-point segments by building a sed script
          grep -n ">" ${F_PLATES}${v[$i]}.smallcircles_clip_1 | gawk  -F: 'BEGIN { oldval=0; oldline=""; }
          {
            val=$1;
            diff=val-oldval;
            if (NR>1) {
              if (diff != 3) {
                print oldval ", " val-1 " p";
              }
            }
            oldval=val;
            oldline=$0
          }' > ${F_PLATES}lines_to_extract.txt

          # Execute sed commands to build sanitized small circle file
          sed -n -f ${F_PLATES}lines_to_extract.txt < ${F_PLATES}${v[$i]}.smallcircles_clip_1 > ${F_PLATES}${v[$i]}.smallcircles_clip

          # GMT plot command that exports label locations for points at a specified interval distance along small circles.
          # These X,Y locations are used as inputs to the vector arrowhead locations.
          cat ${F_PLATES}${v[$i]}.smallcircles_clip | gmt psxy -O -R$MINLON/$MAXLON/$MINLAT/$MAXLAT -JQ$MINLON/${INCH}i -W0p -Sqd0.25i:+t"${F_PLATES}${v[$i]}labels.txt"+l" " $VERBOSE >> /dev/null

          # Reformat points
          gawk < ${F_PLATES}${v[$i]}labels.txt '{print $2, $1}' > ${F_PLATES}${v[$i]}_smallcirc_gridpts.txt

          # Calculate the plate velocities at the points
          gawk -f $EULERVEC_AWK -v eLat_d1=$pllat -v eLon_d1=$pllon -v eV1=$plrate -v eLat_d2=$reflat -v eLon_d2=$reflon -v eV2=$refrate ${F_PLATES}${v[$i]}_smallcirc_gridpts.txt > ${F_PLATES}${v[$i]}_smallcirc_velocities.txt

          gawk '
            @include "tectoplot_functions.awk" 
            NF {
              eulervec('${pllat}', '${pllon}', '${plrate}', '${reflat}', '${reflon}', '${refrate}', $2, $1)
              print eulervec_E, eulervec_N 
            }
            ' ${F_PLATES}${v[$i]}_smallcirc_gridpts.txt > ${F_PLATES}${v[$i]}_smallcirc_velocities.txt

          # Transform to psvelo format for later plotting
          paste -d ' ' ${F_PLATES}${v[$i]}_smallcirc_gridpts.txt ${F_PLATES}${v[$i]}_smallcirc_velocities.txt | gawk  '{print $1, $2, $3*100, $4*100, 0, 0, 1, "ID"}' > ${F_PLATES}${v[$i]}_smallcirc_platevecs.txt
        fi # small circles
      fi

  	  i=$i+1
  	  j=$j+1
    done # while (Iterate over plates calculating pldat, centroids, and poles

    # Create the plate labels at the centroid locations
    if [[ -s $PLATENAMES && ${PLATELABEL_FULL} -eq 1 ]]; then
      gawk '
        (NR == FNR) {
          key=$1
          $1=""
          string=$0
          plate[key]=string
        }
        (NR!=FNR) {
          split($1, v, "_")
          print plate[v[1]], "Plate"
        }
      ' ${PLATENAMES} ${F_PLATES}plate_id_list.txt > ${F_PLATES}plate_id_names.txt
      paste -d ',' ${F_PLATES}map_centroids.txt ${F_PLATES}plate_id_names.txt > ${F_PLATES}map_labels.txt

  	else
      paste -d ',' ${F_PLATES}map_centroids.txt ${F_PLATES}plate_id_list.txt > ${F_PLATES}map_labels.txt
    fi
    # EDGE CALCULATIONS. Determine the relative motion of each plate pair for each plate edge segment
    # by extracting the two Euler poles and calculating predicted motions at the segment midpoint.
    # This calculation is time consuming for large areas because my implementation is... algorithmically
    # poor. So, intead we load the data from a pre-calculated results file if it already exists.



    # I can certainly do this faster and better with gawk




    if [[ $doplateedgesflag -eq 1 ]]; then
      # Load pre-calculated data if it exists - MUCH faster but may need to recalc if things change
      # To re-build, use a global region -r -180 180 -90 90 and copy id_pts_euler.txt to $MIDPOINTS file

      if [[ -e $MIDPOINTS ]]; then
        gawk < $MIDPOINTS -v minlat="$MINLAT" -v maxlat="$MAXLAT" -v minlon="$MINLON" -v maxlon="$MAXLON" '{
          # LON EDIT TEST
          if ((($1 <= maxlon && $1 >= minlon) || ($1+360 <= maxlon && $1+360 >= minlon)) && $2 >= minlat && $2 <= maxlat) {
            print
          }
        }' > ${F_PLATES}id_pts_euler_2.txt
      else
        echo "Midpoints file $MIDPOINTS does not exist"
        if [[ $MINLAT -eq "-90" && $MAXLAT -eq "90" && $MINLON -eq "-180" && $MAXLON -eq "180" ]]; then
          echo "Your region is global. After this script ends, you can copy id_pts_euler.txt and define it as a MIDPOINT file."
        fi
        #
      	# # Create a file with all points one one line beginning with the plate ID only
        # # The sed '$d' deletes the 'END' line
        # gawk < ${F_PLATES}plateazfile.txt '{print $1, $2 }' | tr '\n' ' ' | sed -e $'s/>/\\\n/g' | grep '\S' | tr -s '\t' ' ' | sed '$d' > ${F_PLATES}map_plates_oneline.txt
        #
      	# # Create a list of unique block edge points.  Not sure I actually need this
        # gawk -F" " '!_[$1][$2]++' ${F_PLATES}plateazfile.txt | gawk  '($1 != ">") {print $1, $2}' > ${F_PLATES}map_plates_uniq.txt
        #
        # # Primary output is id_pts.txt, containing properties of segment midpoints
        # # id_pts.txt
        # # lon lat seg_az seg_dist plate1_id plate2_id p1lat p1lon p1rate p2lat p2lon p2rate
        # # > nba_1
        # # -0.23807 -54.76466 322.920 32.154 nba_1 an_1 65.42 -118.11 0.25 47.68 -68.44 0.292
        #
        # while read p; do
        #   if [[ ${p:0:1} == '>' ]]; then  # We encountered a plate segment header. All plate pairs should be referenced to this plate
        #     curplate=$(echo $p | gawk  '{print $2}')
        #     echo $p >> ${F_PLATES}id_pts.txt
        #     pole1=($(grep "${curplate}\s" < ${F_PLATES}polesextract.txt))
        #     info_msg "Current plate is $curplate with pole ${pole1[1]} ${pole1[2]} ${pole1[3]}"
        #   else
        #     q=$(echo $p | gawk '{print $1, $2}')
        #     resvar=($(grep -n -- "${q}" < ${F_PLATES}map_plates_oneline.txt | gawk  -F" " '{printf "%s\n", $2}'))
        #     numres=${#resvar[@]}
        #     if [[ $numres -eq 2 ]]; then   # Point is between two plates
        #       if [[ ${resvar[0]} == $curplate ]]; then
        #         plate1=${resvar[0]}
        #         plate2=${resvar[1]}
        #       else
        #         plate1=${resvar[1]} # $curplate
        #         plate2=${resvar[0]}
        #       fi
        #     else                          # Point is not between plates or is triple point
        #         plate1=${resvar[0]}
        #         plate2=${resvar[0]}
        #     fi
        #     pole2=($(grep "${plate2}\s" < ${F_PLATES}polesextract.txt))
        #     info_msg " Plate 2 is $plate2 with pole ${pole2[1]} ${pole2[2]} ${pole2[3]}"
        #     echo -n "${p} " >> ${F_PLATES}id_pts.txt
        #     echo ${plate1} ${plate2} ${pole2[1]} ${pole2[2]} ${pole2[3]} ${pole1[1]} ${pole1[2]} ${pole1[3]} | gawk  '{printf "%s %s ", $1, $2; print $3, $4, $5, $6, $7, $8}' >> ${F_PLATES}id_pts.txt
        #   fi
        # done < ${F_PLATES}plateazfile.txt
        # #
        # #
        # #
        # # Do the plate relative motion calculations all at once.
        # gawk -f $EULERVECLIST_AWK ${F_PLATES}id_pts.txt > ${F_PLATES}id_pts_euler_2.txt

      fi

      gawk '
        @include "tectoplot_functions.awk"
        function midpoint_azimuth_distance(lon1_d, lat1_d, lon2_d, lat2_d) {
          lon1 = deg2rad(lon1_d)
          lat1 = deg2rad(lat1_d)
          lon2 = deg2rad(lon2_d)
          lat2 = deg2rad(lat2_d)
          Bx = cos(lat2)*cos(lon2-lon1)
          By = cos(lat2)*sin(lon2-lon1)
          latMid = rad2deg(atan2(sin(lat1)+sin(lat2), sqrt((cos(lat1)+Bx)*(cos(lat1)+Bx)+By*By)))
          lonMid = rad2deg(lon1+atan2(By, cos(lat1)+Bx))
          theta_a = atan2(sin(lon2-lon1)*cos(lat2), cos(lat1)*sin(lat2)-sin(lat1)*cos(lat2)*cos(lon2-lon1))
          theta=(rad2deg(theta_a)+270)%360
          d = acos(sin(lat1)*sin(lat2) + cos(lat1)*cos(lat2)*cos(lon2-lon1) ) * 6371
        }

        # Load the Euler poles
        (NR==FNR) {
          poleid[$1]=$1
          polelat[$1]=$2
          polelon[$1]=$3
          polerate[$1]=$4
        }
        # Load the plate edges
        (NR != FNR) {
          if ($1==">") {
            # Store the actual plate ID_N
            thisplate=$2
            # Find the ID
            split($2,pn,"_")
            thisplateshort=pn[1]
            plates[thisplateshort]=thisplateshort
            thisplatecount=0
            lastlon=""
            lastlat=""
            # print "starting plate", thisplateshort > "/dev/stderr"

          } else {

            newlon=sprintf("%0.05f", $1)
            newlat=sprintf("%0.05f", $2)

            # print "Examining point", newlon, newlat, "following from", lastlon, lastlat > "/dev/stderr"

            # If we have moved to a new vertex from a plate vertex
            if (thisplatecount >= 1) {
              if (! (lastlon == newlon && lastlat == newlat)) {
                midpoint_azimuth_distance(lastlon, lastlat, newlon, newlat)
                midpointsegment[lonMid][latMid]=sprintf("%s %s %s %s", lastlon, lastlat, newlon, newlat)
                midpointaz[thisplateshort][lonMid][latMid]=theta
                midpointdist[thisplateshort][lonMid][latMid]=d
                midpointcount[lonMid][latMid]++
                if (midpointlist[lonMid][latMid]=="") {
                  midpointlist[lonMid][latMid]=thisplate
                } else {
                  midpointlist[lonMid][latMid]=sprintf("%s %s", midpointlist[lonMid][latMid], thisplateshort)
                }
            #    print lastlon, lastlat, newlon, newlat, lonMid, latMid, theta, d, thisplateshort
              }
            }
            lastlon=newlon
            lastlat=newlat
            thisplatecount++
          }
        }
        END {
          for (lon in midpointcount) {
            for (lat in midpointcount[lon]) {

              # If there is a shared Euler pole along this midpoint

              if (midpointcount[lon][lat]>=2) {

                split(midpointlist[lon][lat], thislist, " ")
                # for (element in thislist) {
                #   print thislist[element], polelat[thislist[element]], polelon[thislist[element]], polerate[thislist[element]]
                # }
                # midlon midlat seg_az seg_dist plate1_id plate2_id p1lat p1lon p1rate p2lat p2lon p2rate
                split(thislist[1], short, "_")
                thisplate=short[1]
                split(thislist[2], short, "_")
                thatplate=short[1]

                print lon, lat, midpointaz[thisplate][lon][lat], midpointdist[thisplate][lon][lat], thisplate, thatplate, polelat[thatplate], polelon[thatplate], polerate[thatplate], polelat[thisplate], polelon[thisplate], polerate[thisplate] >> "./id_pts.txt"

                # print lon, lat, midpointaz[thatplate][lon][lat], midpointdist[thatplate][lon][lat], thatplate, thisplate, polelat[thisplate], polelon[thisplate], polerate[thisplate], polelat[thatplate], polelon[thatplate], polerate[thatplate] >> "./id_pts.txt"

                print midpointsegment[lon][lat], midpointaz[thatplate][lon][lat] > "./segaz.txt"
              }
            }
          }
        }' $POLES ${F_PLATES}map_plates_clip.txt

        mv ./id_pts.txt ${F_PLATES}id_pts.txt

        echo gothere - need to troubleshoot and possibly revert code to EULERVECLIST_AWK until proved
       # gawk -f $EULERVECLIST_AWK ${F_PLATES}id_pts.txt > ${F_PLATES}id_pts_euler_half.txt

        gawk '
            @include "tectoplot_functions.awk" 
            NF {
	            if ($1 == ">") { 
                printf("%s %s\n", $1, $2) 
              } else { 
                ORS=" "
                print
                eulervec($7, $8, $9, $10, $11, $12, $1, $2); 
                print eulervec_E, eulervec_N 
                printf "\n"
              }
            }
            ' ${F_PLATES}id_pts.txt > ${F_PLATES}id_pts_euler_half.txt

        



      # Concatenate back with the file that contains segment information

      # paste ${F_PLATES}plateazfile_withpts.txt ${F_PLATES}id_pts_euler.txt | gawk '{
      #   diff=$23-$11
      #   while (diff > 180) { diff -= 360 }
      #   while (diff < -180) { diff += 360 }
      #
      #   print "> -Z" diff
      #   print $5, $6
      #   print $7, $8
      # }'> ${F_PLATES}segment_obliquity.txt

      paste segaz.txt ${F_PLATES}id_pts_euler_half.txt | gawk '{
        diff=$5-$20+180
        while (diff > 180) { diff -= 360 }
        while (diff <= -180) { diff += 360 }

        print "> -Z" diff
        print $1, $2
        print $3, $4
      }'> ${F_PLATES}segment_obliquity.txt

      gawk < ${F_PLATES}id_pts_euler_half.txt '{
        # 156.896 -8.6285 199.522 8.98173 au pa -63.58 114.7 0.651 33.86 37.94 0.632 -94.9869 -29.4279 252.786
        print
        az=$3-180
        while (az > 180) { az -= 360 }
        while (az < -180) { az += 360 }
        eaz=$15-180
        while (eaz > 180) { eaz -= 360 }
        while (eaz < -180) { eaz += 360 }
        print $1, $2, az, $4, $6, $5, $10, $11, $12, $7, $8, $9, -$13, -$14, eaz
      }' > ${F_PLATES}id_pts_euler.txt

    	grep "^[^>]" < ${F_PLATES}id_pts_euler.txt | gawk  '{print $1, $2, $3, 0.5}' >  ${F_PLATES}paz1.txt
    	grep "^[^>]" < ${F_PLATES}id_pts_euler.txt | gawk  '{print $1, $2, $15, 0.5}' >  ${F_PLATES}paz2.txt

      grep "^[^>]" < ${F_PLATES}id_pts_euler.txt | gawk  '{print $1, $2, $3-$15}' >  ${F_PLATES}azdiffpts.txt
      #grep "^[^>]" < id_pts_euler.txt | gawk  '{print $1, $2, $3-$15, $4}' >  azdiffpts_len.txt

      # Right now these values don't go from -180:180...
      grep "^[^>]" < ${F_PLATES}id_pts_euler.txt | gawk  '{
          val = $3-$15
          if (val > 180) { val = val - 360 }
          if (val < -180) { val = val + 360 }
          print $1, $2, val, $4
        }' >  ${F_PLATES}azdiffpts_len.txt

    	# currently these kinematic arrows are all the same scale. Can scale to match psvelo... but how?

      grep "^[^>]" < ${F_PLATES}id_pts_euler.txt | gawk  '
        @include "tectoplot_functions.awk"
        # function abs(v) {return v < 0 ? -v : v} function ddiff(u) { return u > 180 ? 360 - u : u}
        {
        diff=$15-$3;
        if (diff > 180) { diff = diff - 360 }
        if (diff < -180) { diff = diff + 360 }
        if (diff >= -70 && diff <= 70) { print $1, $2, $15, sqrt($13*$13+$14*$14) }}' >  ${F_PLATES}paz1thrust.txt

      grep "^[^>]" < ${F_PLATES}id_pts_euler.txt | gawk  '
        @include "tectoplot_functions.awk"
        # function abs(v) {return v < 0 ? -v : v} function ddiff(u) { return u > 180 ? 360 - u : u}
        {
        diff=$15-$3;
        if (diff > 180) { diff = diff - 360 }
        if (diff < -180) { diff = diff + 360 }
        if (diff > 70 && diff < 110) { print $1, $2, $15, sqrt($13*$13+$14*$14) }}' >  ${F_PLATES}paz1ss1.txt

      grep "^[^>]" < ${F_PLATES}id_pts_euler.txt | gawk  '
        @include "tectoplot_functions.awk"
        # function abs(v) {return v < 0 ? -v : v} function ddiff(u) { return u > 180 ? 360 - u : u}
        {
        diff=$15-$3;
        if (diff > 180) { diff = diff - 360 }
        if (diff < -180) { diff = diff + 360 }
        if (diff > -90 && diff < -70) { print $1, $2, $15, sqrt($13*$13+$14*$14) }}' > ${F_PLATES}paz1ss2.txt

      grep "^[^>]" < ${F_PLATES}id_pts_euler.txt | gawk  '
        @include "tectoplot_functions.awk"
        # function abs(v) {return v < 0 ? -v : v} function ddiff(u) { return u > 180 ? 360 - u : u}
        {
        diff=$15-$3;
        if (diff > 180) { diff = diff - 360 }
        if (diff < -180) { diff = diff + 360 }
        if (diff >= 110 || diff <= -110) { print $1, $2, $15, sqrt($13*$13+$14*$14) }}' > ${F_PLATES}paz1normal.txt
    fi #  if [[ $doplateedgesflag -eq 1 ]]; then

    if [[ $plistflag -eq 1 ]]; then
      cd ${F_PLATES}
      echo "PlateID-RefID Lat Lon Rate(deg/Myr)"
      for polefile in *.pole; do
        echo ${polefile} ${REFPLATE} | gawk '{ split($1,a,"_"); split($2,b,"_"); printf("%s-%s ", a[1], b[1])}'
        head -n 1 $polefile
      done
      cd ..
    fi


  fi # if [[ $plotplates -eq 1 ]]

  # Extract the aprof list to make the profiles
  for code in ${aproflist[@]}; do
    profpts=""
    len=$(echo "${#code} - 1" | bc)
    for i in $(seq 0 $len); do
      thispt=($(grep "[${code:i:1}]" ${F_MAPELEMENTS}aprof_database.txt))
      profpts="${profpts} ${thispt[0]} ${thispt[1]}"
    done
    echo "P A_${code} black 0 N ${profpts}" >> ${F_PROFILES}aprof_profs.txt
    # p1=($(grep "[${code:0:1}]" ${F_MAPELEMENTS}aprof_database.txt))
    # p2=($(grep "[${code:1:1}]" ${F_MAPELEMENTS}aprof_database.txt))
    # if [[ ${#p1[@]} -eq 3 && ${#p2[@]} -eq 3 ]]; then
    #   echo "P P_${code} black 0 N ${p1[0]} ${p1[1]} ${p2[0]} ${p2[1]}" >> ${F_PROFILES}aprof_profs.txt
    # fi
  done

  # Build the cprof profiles

  if [[ -s ${F_PROFILES}cprof_prep.txt ]]; then
    while read pin; do
      p=(${pin})
      CPAZ=${p[0]}
      CPLON=${p[1]}
      if [[ ${CPLON} =~ "eqlon" ]]; then
        CPLON=$REGION_EQ_LON
      fi
      CPLAT=${p[2]}
      if [[ ${CPLAT} =~ "eqlat" ]]; then
        CPLAT=$REGION_EQ_LAT
      fi
      CPHALFLEN=${p[3]}
      if [[ ${CPHALFLEN} =~ "map" ]]; then
        TL=($(gmt mapproject -R -J -WjTL ${VERBOSE}))
        BR=($(gmt mapproject -R -J -WjBR ${VERBOSE}))
        DI=($(echo ${TL[0]} ${TL[1]} | gmt mapproject -G${BR[0]}/${BR[1]} ${VERBOSE}))
        CPHALFLEN=$(echo ${DI[2]} | gawk '{print ($1+0)/1000/6}')
        echo New CPHALFLEN=${CPHALFLEN}
      fi

      # CPAZ=90
      if [[ $CPAZ =~ "slab2" ]]; then
      # Check for Slab2 strike here
        shift
        info_msg "[-cprof]: Querying Slab2 to determine azimuth of profile."

        # First try to check whether the profile point falls within any SLAB2
        # polygon

        echo $CPLON $CPLAT > inpoint.file
        cleanup inpoint.file



        for slabcfile in $(ls -1a ${SLAB2_CLIPDIR}*.csv); do

          numinregion=$(gmt select ${slabcfile} -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} ${VERBOSE} -fg | wc -l)
          # If we found one or more points, then add the to the slab2inregion array
          if [[ $(echo "${numinregion} >= 1" | bc -l) -eq 1 ]]; then
            numslab2inregion=$(echo "$numslab2inregion+1" | bc)
            slab2inregion[$numslab2inregion]=$(basename -s .csv $slabcfile)
          fi

          # # echo "Looking at file $slabcfile"
          # gawk < $slabcfile '{
          #   if ($1 > 180) {
          #     print $1-360, $2
          #   } else {
          #     print $1, $2
          #   }
          # }' > tmpslabfile.dat
          # numinregion=$(gmt select inpoint.file -Ftmpslabfile.dat ${VERBOSE} -fg | wc -l)
          # if [[ $numinregion -ge 1 ]]; then
          #   numslab2inregion=$(echo "$numslab2inregion+1" | bc)
          #   slab2inregion[$numslab2inregion]=$(basename -s .csv $slabcfile)
          # fi
        done

        if [[ $numslab2inregion -eq 0 ]]; then
          info_msg "[-b]: No slabs within entire region. Using default azimuth of 90 degrees."
          # or could use some other kind of method for picking a profile azimuth
          CPAZ=90
        else
          minslab2depth=-9999
          for i in $(seq 1 $numslab2inregion); do
            info_msg "[-b]: Found slab2 slab ${slab2inregion[$i]} in map region. Querying strike raster"
            gridfile=$(echo ${SLAB2_GRIDDIR}${slab2inregion[$i]}.grd | sed 's/clp/str/')
            depfile=$(echo ${SLAB2_GRIDDIR}${slab2inregion[$i]}.grd | sed 's/clp/dep/')

            # Query the grid file at the profile center location, add 90 degrees to get cross-strike profile
            slabsampledepth=$(echo "${CPLON} ${CPLAT}" | gmt grdtrack -G$depfile ${VERBOSE} -fg | gawk '($3+0==$3){print $3}')
            slabsamplestrike=$(echo "${CPLON} ${CPLAT}" | gmt grdtrack -G$gridfile ${VERBOSE} -fg | gawk '($3+0==$3){print $3 + 90}')

            if [[ ! -z ${slabsampledepth} ]]; then
              if [[ $(echo "${slabsampledepth} > ${minslab2depth}" | bc -l) -eq 1 ]]; then
                minslab2depth=${slabsampledepth}
                CPAZ=${slabsamplestrike}
              fi
            fi
          done
          if [[ $(echo "$minslab2depth == -9999" | bc) -eq 1 ]]; then
            # No slabs beneath the actual point. We could calculate the average strike of
            # the nearest point at each slab???

            # Try to draw a profile through the closest point on a plate boundary
            foundcpaz=0

            if [[ -s ${F_PLATES}map_plates_clip.txt ]]; then
                closestpoint=($(echo "${CPLON} ${CPLAT}" | gmt mapproject -L${F_PLATES}map_plates_clip.txt -o3,4))
                if [[ ! -z ${closestpoint[0]} ]]; then
                  CPAZ=$(echo ${closestpoint[0]} ${closestpoint[1]} | gmt mapproject -Af${CPLON}/${CPLAT} -o2)
                  info_msg "[-cprof]: Set CPAZ to ${CPAZ} using closest plate boundary point"
                  foundcpaz=1
                fi
            fi

            if [[ $foundcpaz -ne 1 ]]; then
              for i in $(seq 1 $numslab2inregion); do
                  info_msg "[-cprof]: Querying strike rasters of nearby slabs"
                  gridfile=$(echo ${SLAB2_GRIDDIR}${slab2inregion[$i]}.grd | sed 's/clp/str/')
                  # depfile=$(echo ${SLAB2_GRIDDIR}${slab2inregion[$i]}.grd | sed 's/clp/dep/')
                  gmt grd2xyz ${gridfile} ${VERBOSE} | grep -v NaN | gmt select ${RJSTRING} ${VERBOSE} -fg > slabpts_${i}.xyz
                  # Find the closest point
                  gmt mapproject slabpts_${i}.xyz -G${CPLON}/${CPLAT} ${VERBOSE} > slabdist.xyz
              done

              if [[ -s slabdist.xyz ]]; then
                CPAZ=$(sort -n -k 4 slabdist.xyz | gawk '(NR==1){ print $1, $2 }' | gmt mapproject -Af${CPLON}/${CPLAT} -o2)
                if ! arg_is_float $CPAZ; then
                  info_msg "[-cprof]: failed to get final az, setting to 90"
                  CPAZ=90
                else
                  info_msg "[-cprof]: set CPAZ to ${CPAZ} using azimuth to nearest slab2 node"
                fi
              else
                # Could use line to nearest plate boundary point if a plate model is used

                info_msg "[-cprof]: Failed to find any close points; using azimuth=90"
                # if [[ -s ${F_TOPO}dem.tif ]]; then
                #   echo "Using DEM to make profile"
                # fi
                CPAZ=90
              fi
            fi
          fi
        fi
     fi

     ANTIAZ=$(echo "${CPAZ}" | bc -l)
     FOREAZ=$(echo "${CPAZ}+180" | bc -l)

     POINT1=($(gmt project -C${CPLON}/${CPLAT} -A${FOREAZ} -Q -G${CPHALFLEN}k -L0/${CPHALFLEN} ${VERBOSE} | tail -n 1 | gawk  '{print $1, $2}'))
     POINT2=($(gmt project -C${CPLON}/${CPLAT} -A${ANTIAZ} -Q -G${CPHALFLEN}k -L0/${CPHALFLEN} ${VERBOSE} | tail -n 1 | gawk  '{print $1, $2}'))

     # Flip the order of the start and end points so the higher longitude is last.

     if [[ $(echo "${POINT1[0]} > ${POINT2[0]}" | bc -l ) -eq 1 ]]; then
       info_msg "[-cprof]: Flipping CPROF order based on longitude order"
       tmp1=${POINT2[0]}
       tmp2=${POINT2[1]}
       POINT2[0]=${POINT1[0]}
       POINT2[1]=${POINT1[1]}
       POINT1[0]=${tmp1}
       POINT1[1]=${tmp2}
     else
       if [[ $(echo "${POINT1[0]} < -100 && ${POINT2[0]} > 100" | bc -l ) -eq 1 ]]; then
         info_msg "[-cprof]: Flipping CPROF order due to dateline crossing"
         tmp1=${POINT2[0]}
         tmp2=${POINT2[1]}
         POINT2[0]=$(echo "${POINT1[0]} + 360" | bc -l) # Adjust the longitude lower than 0 to be greater than 0
         POINT2[1]=${POINT1[1]}
         POINT1[0]=${tmp1}
         POINT1[1]=${tmp2}
       fi
     fi

     echo "P C_${cprofnum} black 0 N ${POINT1[0]} ${POINT1[1]} ${POINT2[0]} ${POINT2[1]}" >> ${F_PROFILES}cprof_profs.txt
     cprofnum=$(echo "${cprofnum} + 1" | bc)

     info_msg "[-cprof]: Added profile ${CPLON}/${CPLAT}/${CPROFAZ}/${CPHALFLEN}; Updated res to ${SPROF_RES}"

    done < ${F_PROFILES}cprof_prep.txt
  fi

  # Build lprof profiles

  if [[ $lprofflag -eq 1 ]]; then
    if [[ ${LPROFFILE} =~ ".kml" ]]; then
      info_msg "[-lprof]: KML file specified for XY file. Converting lines to XY format."
      CPL_LOG=/dev/null ogr2ogr -f "OGR_GMT" ${F_PROFILES}lprof_profiles.gmt ${LPROFFILE}
    elif [[ ${LPROFFILE} =~ ".shp" ]]; then
      info_msg "[-lprof]: SHP file specified for XY file. Converting lines to XY format."
      CPL_LOG=/dev/null ogr2ogr -f "OGR_GMT" ${F_PROFILES}lprof_profiles.gmt ${LPROFFILE}
    elif [[ ${LPROFFILE} =~ ".gmt" ]]; then
      info_msg "[-lprof]: GMT file specified for XY file. Using lines in XY format."
      cp ${LPROFFILE} ${F_PROFILES}lprof_profiles.gmt
    else
      gawk < ${LPROFFILE} '
        ($1+0==$1) { print }
        ($1==">") {
          line++
          if (line==2) { exit }
        }' > ${F_PROFILES}lprof_profile.xy
    fi
    # Extract only the first polyline to use as the profile
    if [[ -s ${F_PROFILES}lprof_profiles.gmt ]]; then
      gawk < ${F_PROFILES}lprof_profiles.gmt '
        BEGIN {
          isnum=0
        }
        {
          if ($1+0==$1) {
            isnum=1
            print $1, $2
          } else {
            if (isnum==1) {
              exit
            }
          }
        }' > ${F_PROFILES}lprof_profile.xy
    fi

    if [[ $lprofflipflag -eq 1 ]]; then
      tecto_tac ${F_PROFILES}lprof_profile.xy > ${F_PROFILES}lprof_profile_flip.xy
      mv ${F_PROFILES}lprof_profile_flip.xy ${F_PROFILES}lprof_profile.xy
    fi

    if [[ -s ${F_PROFILES}lprof_profile.xy ]]; then
       gmt grdmath -R-180/180/-90/90 -I1d 1 = 1.grd
       gmt grdtrack -G1.grd ${F_PROFILES}lprof_profile.xy -C${LPROF_LENGTH}/${SPROF_RES}/${LPROF_SPACE} -F -Ar | gawk -v align=${PROFILE_ALIGNZ} '
        BEGIN {
          count=1
        }
        ($7!="NaN" && $10 != "NaN") {
          printf("P L_%d black 0 %s %s %s %s %s\n", count++, align, $7, $8, $10, $11)
        }
        ' >> ${F_PROFILES}lprof_profs.txt
       rm -f 1.grd
    fi
  fi

  # Build kprof profiles

  if [[ $kprofflag -eq 1 ]]; then

    # CPL_LOG is set to suppress Warnings from ogr2ogr

    if [[ ${KPROFFILE} =~ ".kml" ]]; then
      info_msg "[-kprof]: KML file specified for XY file. Converting lines to XY format."
      CPL_LOG=/dev/null ogr2ogr -f "OGR_GMT" ${F_PROFILES}kprof_profiles.gmt ${KPROFFILE}
    fi
    if [[ ${KPROFFILE} =~ ".shp" ]]; then
      info_msg "[-kprof]: SHP file specified for XY file. Converting lines to XY format."
      CPL_LOG=/dev/null ogr2ogr -f "OGR_GMT" ${F_PROFILES}kprof_profiles.gmt ${KPROFFILE}
    fi
    if [[ ${KPROFFILE} =~ ".gmt" ]]; then
      info_msg "[-kprof]: GMT file specified for XY file. Using lines in XY format."
      cp ${KPROFFILE} ${F_PROFILES}kprof_profiles.gmt
    fi

    if [[ $sprofclipflag -eq 1 ]]; then
      ogr2ogr -f "OGR_GMT" -clipsrc ${MINLON} ${MINLAT} ${MAXLON} ${MAXLAT} ${F_PROFILES}kprof_profs_clipped.gmt ${F_PROFILES}kprof_profiles.gmt
      if [[ -s ${F_PROFILES}kprof_profs_clipped.gmt ]]; then
        cp ${F_PROFILES}kprof_profs_clipped.gmt ${F_PROFILES}kprof_profiles.gmt
      fi
    fi

    gawk < ${F_PROFILES}kprof_profiles.gmt -v align=${PROFILE_ALIGNZ} '
      BEGIN {
        count=0
      }
      ($1==">") {
        count++
        if (count>1) {
          printf("\n")
        }
        printf("P K_%d black 0 %s ", count, align)
      }
      ($1+0==$1) {
        printf("%s %s ", $1, $2)
      }
      END {
        printf("\n")
      }' >> ${F_PROFILES}kprof_profs.txt



  fi

  ### MODULE CALCULATION FUNCTIONS

  # tectoplot_calculate_module() is currently run for every call from 
  # a function within that module. That is likely not the right 
  # behavior.

  # tectoplot_calculate_module() should run ONCE and be used to
  # derive datasets that are not sensitive to multiple calls to 
  # module functions. 

  for this_mod in ${TECTOPLOT_ACTIVE_MODULES[@]}; do

    eval "((${this_mod}_calculate_callnum++))"
    eval "tt=\${${this_mod}_calculate_callnum}"

    if type "tectoplot_calculate_${this_mod}" >/dev/null 2>&1; then
      info_msg "Running module data calculations for ${this_mod}"
      cmd="tectoplot_calculate_${this_mod}"
      "$cmd"
      # ${this_mod}
    fi
  done

  # tectoplot_calc_module() is registered by functions within modules
  # using calcs+=("module_id"). Any module that relies on calculating
  # data to be used in plot() should run calcs+=("module_id")
  # along with plots+=("module_id") to ensure synchronization of
  # the [$tt] variable. 

  for this_calc in ${calcs[@]}; do
    tectoplot_calc_caught=0

    # Increment the ${routine_callnum} variable here.
    # The reserved variable $tt contains the number of times a given
    # routine has been called

    eval "((${this_calc}_calc_callnum++))"
    eval "tt=\${${this_calc}_calc_callnum}"

    for this_mod in ${TECTOPLOT_ACTIVE_MODULES[@]}; do
      if type "tectoplot_calc_${this_mod}" >/dev/null 2>&1; then
        cmd="tectoplot_calc_${this_mod}"
        "$cmd" ${this_calc}
      fi
      if [[ $tectoplot_calc_caught -eq 1 ]]; then
        break
      fi
    done
  done


  # Profiling plots go to the end

  if [[ $sprofflag -eq 1 || $aprofflag -eq 1 || $cprofflag -eq 1 || $kprofflag -eq 1 || $lprofflag -eq 1 || $xprofflag -eq 1 ]]; then
    plots+=("mprof")
    cpts+=("seisdepth")
  fi

  # After-profile plots go after that
  plots+=(${after_plots[@]})
fi # if [[ $DATAPROCESSINGFLAG -eq 1 ]]; then

################################################################################
################################################################################
#####           Create CPT files for coloring grids and data               #####
################################################################################
################################################################################

# These are a series of fixed CPT files that we can refer to when we wish. They
# are not modified and don't need to be copied to tempdir.

[[ ! -e $CPTDIR"grayhs.cpt" || $remakecptsflag -eq 1 ]] && gmt makecpt -Fr -Cgray,gray -T-10000/10000/10000 ${VERBOSE} > $CPTDIR"grayhs.cpt"
[[ ! -e $CPTDIR"whitehs.cpt" || $remakecptsflag -eq 1 ]] && gmt makecpt -Fr -Cwhite,white -T-10000/10000/10000 ${VERBOSE} > $CPTDIR"whitehs.cpt"
[[ ! -e $CPTDIR"cycleaz.cpt" || $remakecptsflag -eq 1 ]] && gmt makecpt -Fr -Cred,green,blue,yellow,red -T-180/180/1 -Z $VERBOSE > $CPTDIR"cycleaz.cpt"
[[ ! -e $CPTDIR"defaultpt.cpt" || $remakecptsflag -eq 1 ]] && gmt makecpt -Fr -Cred,yellow,green,blue,orange,purple,brown -T0/2000/1 -Z $VERBOSE > $CPTDIR"defaultpt.cpt"
[[ ! -e $CPTDIR"platevel_one.cpt" || $remakecptsflag -eq 1 ]] && gmt makecpt -Fr -Chaxby -T0/1/0.05 -Z $VERBOSE > $CPTDIR"platevel_one.cpt"

################################################################################
##### Create required CPT files in the temporary directory

for cptfile in ${cpts[@]} ; do
	case $cptfile in

    tomography)
      if [[ $tomoowncptflag -eq 1 ]]; then
        cp $tomocpt ${F_CPTS}tomography.cpt
      else
        gmt makecpt -Fr -C${CPTDIR}tomography.cpt -I -T-1/1/0.1 -D -Z > ${F_CPTS}tomography.cpt
      fi
    ;;

    eqtime)

      if [[ $zccolorbreakflag -eq 1 ]]; then
        # Make the actual CPT 
        echo "0000-01-01T00:00:00 ${zccolorbefore} ${COLOR_TIME_BREAK_TEXT} ${zccolorbefore}" > ${F_CPTS}eqtime_text.cpt
        echo "${COLOR_TIME_BREAK_TEXT} ${zccolorafter} $(date -u +"%FT%T") ${zccolorafter}" >> ${F_CPTS}eqtime_text.cpt
        echo "B black" >> ${F_CPTS}eqtime_text.cpt
        echo "F white" >> ${F_CPTS}eqtime_text.cpt
        echo "N gray" >> ${F_CPTS}eqtime_text.cpt

        # Make the CPT for the legend        
        zc_st_3=$(date_shift_utc_given ${COLOR_TIME_BREAK_TEXT} -9 0 0 0)

        zc_st_2=$(date_shift_utc_given ${COLOR_TIME_BREAK_TEXT} -8 0 0 0)
        zc_st=$(date_shift_utc_given ${COLOR_TIME_BREAK_TEXT} -7 0 0 0)
        zc_et=$(date_shift_utc_given ${COLOR_TIME_BREAK_TEXT} 7 0 0 0)
        zc_et_2=$(date_shift_utc_given ${COLOR_TIME_BREAK_TEXT} 8 0 0 0)

        echo "${zc_st_2} ${zccolorbefore} ${zc_st} ${zccolorbefore} L; Before " > ${F_CPTS}eqtime_text_legend.cpt
        echo "${zc_st} ${zccolorbefore} ${COLOR_TIME_BREAK_TEXT} ${zccolorbefore};  " >> ${F_CPTS}eqtime_text_legend.cpt
        echo "${COLOR_TIME_BREAK_TEXT} ${zccolorafter} ${zc_et} ${zccolorafter} L; ${COLOR_TIME_BREAK_TEXT_ORIG}" >> ${F_CPTS}eqtime_text_legend.cpt
        echo "${zc_et} ${zccolorafter} ${zc_et_2} ${zccolorafter} U; After" >> ${F_CPTS}eqtime_text_legend.cpt
        echo "B ${zccolorbefore}" >> ${F_CPTS}eqtime_text_legend.cpt
        echo "F ${zccolorafter}" >> ${F_CPTS}eqtime_text_legend.cpt
        echo "N ${zccolorbefore}" >> ${F_CPTS}eqtime_text_legend.cpt


      else
        gmt makecpt -Fr -T${COLOR_TIME_START_TEXT}/${COLOR_TIME_END_TEXT}/30+n -C${EQ_TIME_DEF} ${SEIS_CPT_INV} ${VERBOSE} -Z | gawk '
        {
          if ($1=="B") {
            print $0 "@70"
          } else {
            print
          }
        }' > ${F_CPTS}eqtime_text.cpt
      fi
      
      ;;

    eqcluster)
      # Make a random color CPT
      gawk 'BEGIN {
        srand(1)
        print 1, "0/0/0", "L"
        for(i=2;i<=20000;i++) {
          print i, int(rand()*255) "/" int(rand()*255) "/" int(rand()*255), "L"
        }
        print "B black"
        print "F white"
        print "N 127.5"
      }' > ${F_CPTS}"eqcluster.cpt"
    ;;

    # faultslip)
    #   gmt makecpt -Fr -Chot -I -Do -T$SLIPMINIMUM/$SLIPMAXIMUM/0.1 -N $VERBOSE > $FAULTSLIP_CPT
    #   ;;

    # geoage)
    #   cp ${CPTDIR}geoage.cpt ${GEOAGE_CPT}
    # ;;

    plateid)
      gmt makecpt -Fr -Ccategorical -Ww -T0/100/1 ${VERBOSE} > ${PLATEID_CPT}
    ;;

    grav) # WGM gravity maps
      touch $GRAV_CPT
      GRAV_CPT=$(abs_path $GRAV_CPT)

      if [[ $rescalegravflag -eq 1 && $legendonlyflag -eq 0 && $rescalegravspecifiedflag -ne 1 ]]; then
        # gmt grdcut $GRAVDATA -R$MINLON/$MAXLON/$MINLAT/$MAXLAT -Ggravtmp.nc
        zrange=$(grid_zrange $GRAVDATA -R$MINLON/$MAXLON/$MINLAT/$MAXLAT)
        GMIN=$(echo $zrange | gawk  '{print int($1/100)*100}')
        GMAX=$(echo $zrange | gawk  '{print int($2/100)*100}')
        # GRAVCPT is set by the type of gravity we selected (BG, etc) and is not the same as GRAV_CPT
        gmt makecpt -Fr -C$GRAVCPT -T$GMIN/$GMAX -Z $VERBOSE > $GRAV_CPT
      else
        gmt makecpt -Fr -C$GRAVCPT -T$GMIN/$GMAX -Z $VERBOSE > $GRAV_CPT
      fi
      ;;

    gravcurv)
      touch $GRAV_CURV_CPT
      GRAV_CURV_CPT=$(abs_path $GRAV_CURV_CPT)

      if [[ $rescalegravflag -eq 1 ]]; then

        zrange=$(grid_zrange $GRAV_CURV_DATA -R$MINLON/$MAXLON/$MINLAT/$MAXLAT)
        info_msg "Grav curvature raster range is: $zrange"
        MIN=$(echo $zrange | gawk  '{print int($1/100)*100}')
        MAX=$(echo $zrange | gawk  '{print int($2/100)*100}')

        # GRAVCPT is set by the type of gravity we selected (BG, etc) and is not the same as GRAV_CPT
        info_msg "Rescaling gravity curvature CPT to $MIN/$MAX"
        gmt makecpt -Fr -C$GRAV_CURV_DEF -T$MIN/$MAX $VERBOSE > $GRAV_CURV_CPT
      else
        gmt makecpt -Fr -C$GRAV_CURV_DEF -T-100/100 $VERBOSE > $GRAV_CURV_CPT
      fi

      ;;

    litho1)

      gmt makecpt -Fr -T${LITHO1_MIN_DENSITY}/${LITHO1_MAX_DENSITY}/10 -C${LITHO1_DENSITY_BUILTIN} -Z $VERBOSE > $LITHO1_DENSITY_CPT
      gmt makecpt -Fr -T${LITHO1_MIN_VELOCITY}/${LITHO1_MAX_VELOCITY}/10 -C${LITHO1_VELOCITY_BUILTIN} -Z $VERBOSE > $LITHO1_VELOCITY_CPT
      ;;

    # oceanage)
    #   if [[ $stretchoccptflag -eq 1 ]]; then
    #     # The ocean CPT has a long 'purple' tail that isn't useful when stretching the CPT
    #     gawk < $OC_AGE_CPT '{ if ($1 < 180) print }' > ./oceanage_cut.cpt
    #     printf "B\twhite\n" >> ./oceanage_cut.cpt
    #     printf "F\tblack\n" >> ./oceanage_cut.cpt
    #     printf "N\t128\n" >> ./oceanage_cut.cpt
    #     gmt makecpt -Fr -C./oceanage_cut.cpt -T0/$OC_MAXAGE/10 $VERBOSE > ./oceanage.cpt
    #     OC_AGE_CPT="./oceanage.cpt"
    #   fi
    #   ;;

    platevelgrid)
      gmt makecpt -Fr -T0/100/1 -C$CPTDIR"platevel_one.cpt" -Z ${VERBOSE} > $PLATEVELGRID_CPT
      ;;

    platerelvel)
      gmt makecpt -Fr -T0/100/1 -C$CPTDIR"platevel_one.cpt" -Z ${VERBOSE} > $PLATEVEL_CPT
    # Don't do anything until we move the calculation from the plotting section to above
      ;;

    slipratedeficit)
      gmt makecpt -Fr -Cseis -Do -I -T0/1/0.01 -N > $SLIPRATE_DEF_CPT
      ;;

    topo)

      if [[ $useowntopoctrlflag -eq 0 ]]; then
        topoctrlstring=$DEFAULT_TOPOCTRL
      fi
      if [[ $dontcolortopoflag -eq 0 ]]; then
        info_msg "Adding color stretch to topoctrlstring"
        topoctrlstring=${topoctrlstring}"c"
      fi

      info_msg "[-t]: Creating topography CPT"

      touch $TOPO_CPT
      TOPO_CPT=$(abs_path $TOPO_CPT)
      if [[ $cptdirectflag -eq 1 ]]; then
        info_msg "Copying custom CPT file $CUSTOMCPT to temporary directory"
        cp $CUSTOM_TOPO_CPT $TOPO_CPT
      else

# Criteria for generating a topography CPT file from a standard OR custom CPT
# 1. Respect hinge at Z=0
# 2. Exceed the range [zmin, zmax] of the dataset only through rounding
# 3. Either stretch or not stretch the CPT range as required by -tr
# 4. Not bug out when the grid range exceeds the input CPT range (-9234 m vs -8000 m defaults)
# 5. Have a reasonable annotation interval in the map legend

        # Determine the range of data if it exists

        if [[ -s ${TOPOGRAPHY_DATA} ]]; then
          zrange=($(grid_zrange ${TOPOGRAPHY_DATA} -R${DEM_MINLON}/${DEM_MAXLON}/${DEM_MINLAT}/${DEM_MAXLAT}))
          TMIN=${zrange[0]}
          TMAX=${zrange[1]}
        fi

        # Check and see if the CPT has a zero slice
        CPT_HAS_ZERO=$(gmt makecpt -Fr -C${TOPO_CPT_DEF} -Vn | gawk '
          BEGIN {
            endval=0
          }
          ($1+0==0) {
            endval=1
            exit
          }
          END {
            print endval
          }')

        [[ $CPT_HAS_ZERO -eq 1 && $cptnohingeflag -ne 1 ]] && echo "# HARD_HINGE" > ${F_CPTS}topo_prep.cpt

        if [[ $rescaletopoflag -ne 1 ]]; then

          gmt makecpt -C${TOPO_CPT_DEF} -T-11000/9000 -Fr -Vn >> ${F_CPTS}topo_prep.cpt

          # Make the new CPT by truncating the prep CPT to the data range
          gmt makecpt -Fr -C${F_CPTS}topo_prep.cpt -G${TMIN}/${TMAX} -Z -Vn > ${F_CPTS}topo_temp.cpt
        else
          [[ $rescaletopominflag -eq 1 ]] && TMIN=${RESCALE_TMIN}
          [[ $rescaletopomaxflag -eq 1 ]] && TMAX=${RESCALE_TMAX}

          # If we ARE rescaling the CPT, make a hard hinge CPT from -1 to 1
          gmt makecpt -C${TOPO_CPT_DEF} -T-1/1 -Fr -Vn >> ${F_CPTS}topo_prep.cpt

          # Then resample it to rescale
          gmt makecpt -C${F_CPTS}topo_prep.cpt -T${TMIN}/${TMAX} -Fr -Vn > ${F_CPTS}topo_temp.cpt

        fi
        cleanup ${F_CPTS}topo_prep.cpt
      fi

      # Shift the CPT if requires

      if [[ $cptshiftzeroflag -eq 1 ]]; then

        gawk < ${F_CPTS}topo_temp.cpt -v shft=${CPT_SHIFTZERO} '
        {
          if ($1+0==$1) {
            $1=$1+shft
            $3=$3+shft
          }
          print
        }' > ${F_CPTS}topo_temp2.cpt
        mv ${F_CPTS}topo_temp2.cpt ${F_CPTS}topo_temp.cpt
      fi

      # Determine the range of the CPT directly
      CPT_ZRANGE_2=($(gawk < ${F_CPTS}topo_temp.cpt '
        BEGIN {
          getline
          minz=($1<$3)?$1:$3
          maxz=($1>$3)?$1:$3
          haszero=0
        }
        ($1+0==$1){
          minz=($1<minz)?$1:minz
          minz=($3<minz)?$3:minz

          maxz=($1>maxz)?$1:maxz
          maxz=($3>maxz)?$3:maxz
        }
        ($1==0) {
          haszero=1
        }
        END {
          print minz, maxz
        }'))

      # Determine the label interval for the CPT
      BATHYXINC=$(echo ${CPT_ZRANGE_2[0]} ${CPT_ZRANGE_2[1]} | gawk '
        {
          if ($2-$1 > 8000) {
            print 2000/1000
          } else if ($2-$1 > 5000) {
            print 1000/1000
          } else if ($2-$1 > 2000) {
            print 500/1000
          } else if ($2-$1 > 500) {
            print 200/1000
          } else if ($2-$1 > 200) {
            print 50/1000
          } else if ($2-$1 > 100) {
            print 30/1000
          } else {
            print 10/1000
          }
        }')

      # Finalize the CPT


      # Create a cyclic CPT and merge with the input CPT

      if [[ $tcyclecptflag -eq 1 ]]; then

        tcyclecptnummul=$(echo "(${tcyclecptnum} - 1) * ${tcyclestepval}" | bc -l)
        rm -f cyclegray.cpt

        for i in $(seq 0 ${tcyclestepval} ${tcyclecptnummul}); do
          j=$(echo "$i + 0.5*${tcyclestepval}" | bc)
          k=$(echo "$i + 1*${tcyclestepval}" | bc)

          gmt makecpt -C${tcyclecptcpt} -N -Fr -Z -T${i}/${j}/1 -G${tcycle_cptlow}/${tcycle_cpthigh} >> cyclegray.cpt
          gmt makecpt -C${tcyclecptcpt} -I -N -Fr -Z -T${j}/${k}/1 -G${tcycle_cptlow}/${tcycle_cpthigh} >> cyclegray.cpt
        done

        (
          mkdir ./newrun
          cp ${F_CPTS}topo_temp.cpt ./cyclegray.cpt ./newrun
          cd ./newrun
          tectoplot -tmix ./topo_temp.cpt ./cyclegray.cpt ${CPT_ZRANGE_2[0]} ${CPT_ZRANGE_2[1]} 1 ${tcyclemethod}
          cp tempfiles_to_delete/mix.cpt ..

        )
        TOPO_CPT=mix.cpt
      else
        cp ${F_CPTS}topo_temp.cpt ${TOPO_CPT}
      fi
      cleanup ${F_CPTS}topo_temp.cpt
    ;;

    seisdepth)
      info_msg "Making seismicity vs depth CPT: maximum depth EQs at ${EQMAXDEPTH_COLORSCALE}"
      touch $SEISDEPTH_CPT
      # Make a constant color CPT
      if [[ $seisfillcolorflag -eq 1 ]]; then
        gmt makecpt -Fr -C${ZSFILLCOLOR} -Do -T0/6371 -Z $VERBOSE > $SEISDEPTH_CPT
      else
        # Make a color stretch CPT
        SEISDEPTH_CPT=$(abs_path $SEISDEPTH_CPT)
        gmt makecpt -Fr -C${SEIS_CPT} ${SEIS_CPT_INV} > ${F_CPTS}origseis.cpt
        gmt makecpt -N -C${SEIS_CPT} ${SEIS_CPT_INV} -Fr -Do -T"${EQMINDEPTH_COLORSCALE}"/"${EQMAXDEPTH_COLORSCALE}"/1 -Z $VERBOSE > $SEISDEPTH_CPT
        cp $SEISDEPTH_CPT $SEISDEPTH_NODEEPEST_CPT

        CPTBOUNDS=($(gawk < $SEISDEPTH_CPT '
        BEGIN {
          hasfirst=0
        }
        ($1+0==$1) {
          if (hasfirst==0) {
            hasfirst=1
            firstval=$1
            firstrgb=$2
          }
          lastrgb=$2
          if ($3+0==$3) {
            lastval=$3
            lastrgb=$4
          }
        }
        END {
          print firstval, firstrgb, lastval, lastrgb
        }'))

        # echo CPT bounds ${CPTBOUNDS[@]}

        # This needs to be customized!
        echo "${CPTBOUNDS[2]}	${CPTBOUNDS[3]}	6370	${CPTBOUNDS[3]}" >> $SEISDEPTH_CPT
        echo "B	${CPTBOUNDS[1]}" >> $SEISDEPTH_CPT
        echo "F	${CPTBOUNDS[3]}" >> $SEISDEPTH_CPT
        echo "N	127.5" >> $SEISDEPTH_CPT
        echo "B	${CPTBOUNDS[1]}" >> $SEISDEPTH_NODEEPEST_CPT
        echo "F	${CPTBOUNDS[3]}" >> $SEISDEPTH_NODEEPEST_CPT
        echo "N	127.5" >> $SEISDEPTH_NODEEPEST_CPT
      fi

    ;;
    *) # Likely a module CPT

    tectoplot_cpt_caught=0

    eval "((${cptfile}_cpt_callnum++))"
    eval "tt=\${${cptfile}_cpt_callnum}"

    for this_cpt_mod in ${TECTOPLOT_ACTIVE_MODULES[@]}; do
      if type "tectoplot_cpt_${this_cpt_mod}" >/dev/null 2>&1; then
        info_msg "Running module CPT for ${this_cpt_mod}"
        cmd="tectoplot_cpt_${this_cpt_mod}"
        # Pass the cptfile name as argument to the tectoplot_cpt function
        "$cmd" ${cptfile}
      fi
      if [[ $tectoplot_cpt_caught -eq 1 ]]; then
        break
      fi
    done
    ;;

  esac
done


# Set the seismicity Z-column and CPT

# echo SEIS_CPT ${SEIS_CPT}  CMT_CPT ${CMT_CPT}

SEIS_ZCOL=3
SEIS_CPT=$SEISDEPTH_CPT
CMT_CPT=$SEISDEPTH_CPT


if [[ $zctimeflag -eq 1 ]]; then
  SEIS_ZCOL=5
  CMT_ZCOL=17
  SEIS_CPT=${F_CPTS}"eqtime_text.cpt"
  CMT_CPT=${F_CPTS}"eqtime_text.cpt"
elif [[ $zcclusterflag -eq 1 ]]; then
  SEIS_CPT=${F_CPTS}"eqcluster.cpt"
  CMT_CPT=${F_CPTS}"eqcluster.cpt"
  SEIS_ZCOL=8
  CMT_ZCOL=16
fi



################################################################################
################################################################################
##### Plot the postscript file by calling the sections listed in $plots[@] #####
################################################################################
################################################################################

  # Add a PS comment with the command line used to invoke tectoplot. Use >> as we might
  # be adding this line onto an already existing PS file

  echo "% Map created using tectoplot v.${TECTOPLOT_VERSION} on $(date -u): ${COMMAND}" >> map.ps

  # Before we plot anything but after we have done the data processing, set any
  # GMT variables that are given on the command line using -gmtvars { A val ... }

  ################################################################################
  #####          GMT media and map style management                          #####
  ################################################################################

  # # Page options
  # # Just make a giant page and trim it later using gmt psconvert -A+m

  gmt gmtset PS_PAGE_ORIENTATION portrait PS_MEDIA 1000ix1000i

  # # Map frame options

  gmt gmtset MAP_FRAME_TYPE fancy MAP_FRAME_WIDTH 0.12c MAP_FRAME_PEN 0.25p,black
  # gmt gmtset FORMAT_GEO_MAP D

  # # Font options
  # gmt gmtset FONT_ANNOT_PRIMARY 10 FONT_LABEL 10 FONT_TITLE 12p,Helvetica,black

  # # Symbol options
  # gmt gmtset MAP_VECTOR_SHAPE 0.5 MAP_TITLE_OFFSET 24p

  if [[ -s ${DEFDIR}${THEME_ID}.theme ]]; then
    info_msg "Setting theme to ${THEME_ID}"

    gawk < ${DEFDIR}${THEME_ID}.theme -v thistheme="${2}" '
    BEGIN {
      printf "gmt gmtset "
    }
    {
      if (substr($1,1,1) != "#") {
        if ($2 != "null") {
          printf "%s %s ", $1, $2
        }
      }
    }
    END {
      printf "\n"
    }' > theme.sh

    # cat theme.sh
    source theme.sh
  elif [[ -s ${OPTDIR}${THEME_ID}.theme ]]; then
    info_msg "Setting theme to user theme ${THEME_ID}"

    gawk < ${OPTDIR}${THEME_ID}.theme -v thistheme="${2}" '
    BEGIN {
      printf "gmt gmtset "
    }
    {
      if (substr($1,1,1) != "#") {
        if ($2 != "null") {
          printf "%s %s ", $1, $2
        }
      }
    }
    END {
      printf "\n"
    }' > theme.sh

    # cat theme.sh
    source theme.sh
  fi

  if [[ $framefontflag -eq 1 ]];  then
    gmt gmtset FONT_ANNOT_PRIMARY 6p,black
  fi

  if [[ $insideframeflag -eq 1 ]]; then
    gmt gmtset MAP_FRAME_TYPE inside
  fi

  if [[ $tifflag -eq 1 ]]; then
    gmt gmtset MAP_FRAME_TYPE inside
  fi

  if [[ $kmlflag -eq 1 ]]; then
    gmt gmtset MAP_FRAME_TYPE inside
  fi

  # Page color

  # gmt gmtset PS_PAGE_COLOR ${PAGE_COLOR}
  # gmt gmtset MAP_FRAME_PEN 1p,black

  if [[ $usecustomgmtvars -eq 1 ]]; then
    info_msg "gmt gmtset ${GMTVARS[@]}"
    gmt gmtset ${GMTVARS[@]}
  fi


  # The strategy for adding items to the legend is to make little baby EPS files
  # and then place them onto the master PS using gmt psimage. We initialize these
  # files here and then we have to keep track of whether to close the master PS
  # file or keep it open for subsequent plotting (-keepopenps)

  # The frame presents a bit of a problem as we have to manage different calls to
  # psbasemap based on a range of options (title, no title, grid, no grid, etc.)

  cleanup base_fake.ps base_fake.eps base_fake_nolabels.ps base_fake_nolabels.eps

  gmt psxy -T -X$PLOTSHIFTX -Y$PLOTSHIFTY $OVERLAY $VERBOSE -K ${RJSTRING} >> map.ps

  if [[ $whiteframeflag -eq 1 ]]; then
    gmt psbasemap "${BSTRING[@]}+gwhite" --MAP_FRAME_PEN=${WHITEFRAME_WIDTH},${WHITEFRAME_COLOR} $RJOK $VERBOSE >> map.ps
  fi

  # We can just use cp instead of running GMT so many times...

  gmt psxy -T -X0i -Yc $OVERLAY $VERBOSE -K ${RJSTRING} > kinsv.ps
  gmt psxy -T -X0i -Yc $OVERLAY $VERBOSE -K ${RJSTRING} > plate.ps
  gmt psxy -T -X0i -Yc $OVERLAY $VERBOSE -K ${RJSTRING} > mecaleg.ps
  gmt psxy -T -X0i -Yc $OVERLAY $VERBOSE -K ${RJSTRING} > seissymbol.ps
  gmt psxy -T -X0i -Yc $OVERLAY $VERBOSE -K ${RJSTRING} > eqlabel.ps
  gmt psxy -T -X0i -Yc $OVERLAY $VERBOSE -K ${RJSTRING} > velarrow.ps
  gmt psxy -T -X0i -Yc $OVERLAY $VERBOSE -K ${RJSTRING} > velgps.ps

  cleanup kinsv.ps
  cleanup eqlabel.ps
  cleanup plate.ps
  cleanup mecaleg.ps
  cleanup seissymbol.ps
  cleanup volcanoes.ps
  cleanup velarrow.ps
  cleanup velgps.ps
  cleanup base_fake.ps
  cleanup base_fake.eps
  cleanup base_fake_nolabels.ps
  cleanup gmt.conf
  cleanup gmt.history

  # Something about map labels messes up the psconvert call making the bounding box wrong.
  # So check the label-free width and if it is significantly less than the with-label
  # width, use it instead. Shouldn't change too much honestly.


  # This outputs a single string with two values

  # MAP_PS_DIM=($(gmt psconvert base_fake.ps -Te -A+m0i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10/2.54, $17/2.54}'))
  # echo MAP_PS_DIM is ${MAP_PS_DIM[0]} ${MAP_PS_DIM[1]}
  # MAP_PS_NOLABELS_DIM=$(gmt psconvert base_fake_nolabels.ps -Te -A+m0i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')

  MAP_PS_DIM=($(grep GMTBoundingBox base_fake.ps | gawk '{print $4/72+0.5, $5/72+0.5}'))


  MAP_PS_NOLABELS_DIM_IN=($(grep GMTBoundingBox base_fake_nolabels.ps | gawk '{print $4/72, $5/72}'))


  # MAP_PS_NOLABELS_BB=($(gmt psconvert base_fake_nolabels.ps -Te -A0.01i 2> >(grep -v Processing | grep -v Find | grep -v Figure | grep -v Format | head -n 1) | gawk -F'[[]' '{print $3}' | gawk -F '[]]' '{print $1}'))
  # MAP_PS_WITHLABELS_BB=($(gmt psconvert base_fake.ps -Te -A0.01i 2> >(grep -v Processing | grep -v Find | grep -v Figure | grep -v Format | head -n 1) | gawk -F'[[]' '{print $3}' | gawk -F '[]]' '{print $1}'))
  # MAP_ANNOT_VDIFF=$(echo )

  MAP_PS_WIDTH_IN=$(echo ${MAP_PS_DIM[0]})
  MAP_PS_HEIGHT_IN=$(echo ${MAP_PS_DIM[1]})

  # MAP_PS_WIDTH_NOLABELS_IN=$(echo $MAP_PS_NOLABELS_DIM | gawk  '{print $1/2.54}')
  # MAP_PS_HEIGHT_NOLABELS_IN=$(echo $MAP_PS_NOLABELS_DIM | gawk  '{print $2/2.54}')

  MAP_PS_WIDTH_NOLABELS_IN=${MAP_PS_NOLABELS_DIM_IN[0]}
  MAP_PS_HEIGHT_NOLABELS_IN=${MAP_PS_NOLABELS_DIM_IN[1]}

  info_msg "Labeled map dimensions (in) are W: $MAP_PS_WIDTH_IN, H: $MAP_PS_HEIGHT_IN"
  info_msg "Unlabeled map frame dimensions (in) are W: $MAP_PS_WIDTH_NOLABELS_IN, H: $MAP_PS_HEIGHT_NOLABELS_IN"

  # If difference is more than 50% of map width
  if [[ $(echo "$MAP_PS_WIDTH_IN - $MAP_PS_WIDTH_NOLABELS_IN > $MAP_PS_WIDTH_IN/2" | bc) -eq 1 ]]; then
    if [[ $(echo "$MAP_PS_WIDTH_NOLABELS_IN > 1" | bc) -eq 1 ]]; then
      info_msg "Using label-free width instead."
      MAP_PS_WIDTH_IN=$MAP_PS_WIDTH_NOLABELS_IN
    else
      info_msg "Width of label free PS is 0... not using as alternative."
    fi
  fi

  # This is the distance from the top of the map to the base of the legend text

  MAP_PS_HEIGHT_IN_plus=$(echo "$MAP_PS_HEIGHT_IN+${LEGEND_V_OFFSET}" | bc -l )

  # cleanup base_fake.ps base_fake.eps

  ######
  # These variables are array indices and must be zero at start. They allow multiple
  # instances of various commands.

  # current_userpointfilenumber=1
  # current_usergridnumber=1
  # current_userlinefilenumber=1
  current_usergpsfilenumber=1


  # Print the author information, date, and command used to generate the map,
  # beneath the map.
  # There are options for author only, command only, and author+command

  # Honestly, it is a bit strange to do this here as we haven't plotted anything
  # including the profile. So our text will overlap the profile. We can fix this
  # by calling the profile psbasemap to add onto base_fake.ps and moving this
  # section to AFTER the plotting commands. But that happens in multi_profile_tectoplot.sh...
  # Currently there is no solution except pushing the profile downward

  # We need to SUBTRACT the AUTHOR_YSHIFT as we are SUBTRACTING $OFFSETV

  if [[ $printcommandflag -eq 1 || $authorflag -eq 1 ]]; then
    OFFSETV=$(echo $COMMAND_FONTSIZE $AUTHOR_YSHIFT | gawk '{print ($1+8)/72 - $2}')
    OFFSETV_M=$(echo $OFFSETV | gawk '{print 0-$1}')

    if [[ $printcommandflag -eq 1 ]]; then
      echo "T $COMMAND" >> command.txt
    fi

    gmt psxy -T -Y${OFFSETV_M}i $RJOK $VERBOSE >> map.ps
    gmt psxy -T -X${AUTHOR_XSHIFT}i $RJOK $VERBOSE >> map.ps

    AUTHOR_XSHIFTM=$(echo $AUTHOR_XSHIFT | gawk '{print 0-$1}')

    if [[ $authorflag -eq 1 && $printcommandflag -eq 1 ]]; then
      echo "T ${AUTHOR_ID}" >> author.txt
      if [[ $authortimestampflag -eq 1 ]]; then
        echo "G 1l" >> author.txt
        echo "T ${DATE_ID}" >> author.txt
      fi
      # Offset the plot down from the map lower left corner
      AUTHOR_W=$(echo "$MAP_PS_WIDTH_IN / 4" | bc -l)
      COMMAND_W=$(echo "$MAP_PS_WIDTH_IN * (3/4 - 2/10)" | bc -l)
      COMMAND_S=$(echo "$MAP_PS_WIDTH_IN * (1/4 + 1/10)" | bc -l)
      COMMAND_M=$(echo "0 - $COMMAND_S" | bc -l)
      # Make the paragraph with the author info first (using 1/4 of the space)
      gmt pslegend author.txt -Dx0/0+w${AUTHOR_W}i+jTL+l1.1 $RJOK $VERBOSE >> map.ps
      # Move to the right
      gmt psxy -T -X${COMMAND_S}i $RJOK $VERBOSE >> map.ps
      gmt pslegend command.txt -DjBL+w${COMMAND_W}i+jTL+l1.1 $RJOK $VERBOSE >> map.ps
      # Return to original location
      gmt psxy -T -Y${OFFSETV}i -X${COMMAND_M}i $RJOK $VERBOSE >> map.ps
    elif [[ $authorflag -eq 1 && $printcommandflag -eq 0 ]]; then
      if [[ $authortimestampflag -eq 1 ]]; then
        echo "T ${AUTHOR_ID} | ${DATE_ID}" >> author.txt
      else
        echo "T ${AUTHOR_ID} " >> author.txt
      fi
      AUTHOR_W=$(echo "$MAP_PS_WIDTH_IN * 8 / 10" | bc -l)
      gmt pslegend author.txt -Dx0/0+w${AUTHOR_W}i+jTL+l1.1 $RJOK $VERBOSE >> map.ps
      gmt psxy -T -Y${OFFSETV}i $RJOK $VERBOSE >> map.ps
    elif [[ $authorflag -eq 0 && $printcommandflag -eq 1 ]]; then
      COMMAND_W=$(echo "$MAP_PS_WIDTH_IN * 9 / 10" | bc -l)
      gmt pslegend command.txt -Dx0/0+w${COMMAND_W}i+jTL+l1.1 $RJOK $VERBOSE >> map.ps
      gmt psxy -T -Y${OFFSETV}i $RJOK $VERBOSE >> map.ps
    fi

    gmt psxy -T -X${AUTHOR_XSHIFTM}i $RJOK $VERBOSE >> map.ps
  fi

if [[ $DATAPLOTTINGFLAG -eq 1 ]]; then

  #### SECTION PLOT BEGIN

  for plot in ${plots[@]} ; do
  	case $plot in
      zproj)

        # This is a custom implementation for Sumatra - needs to be generalized

        # if [[ $zhighlightflag -eq 1 ]]; then
        #   for this_z in ${zhigh[@]}; do
            zprojloc[0]=141
            zprojloc[1]=36.65
            # zprojloc[0]=141.8
            # zprojloc[1]=36.8
            # zprojloc=($(gawk -v id=${this_z} < ${F_SEIS}eqs.txt '($6==id) { print $1, $2, $6 }'))
            gmt mapproject ${F_SEIS}eqs.txt  -G${zprojloc[0]}/${zprojloc[1]} ${VERBOSE} | gawk -v dist=${zproj_radius} '($(NF) <= dist*1000){print}' > proj_${this_z}.txt
            # Make the line
            echo ${zprojloc[0]} ${zprojloc[1]} | gmt psxy -St0.1i -Gblack ${RJOK} ${VERBOSE} >> map.ps

            for azimuth in $(seq 0 1 179); do

              # Create the line we will project the points onto
              ANTIAZ=$(echo "${azimuth} - 180" | bc -l)
              echo "> -Z${azimuth}" > zproj_profile.txt
              gmt project -C${zprojloc[0]}/${zprojloc[1]} -A${azimuth} -Q -G${zproj_radius}k -L0/${zproj_radius} -fg | tail -n 1 | gawk  '{print $1, $2}' >> zproj_profile.txt
              gmt project -C${zprojloc[0]}/${zprojloc[1]} -A${ANTIAZ} -Q -G${zproj_radius}k -L0/${zproj_radius} -fg | tail -n 1 | gawk  '{print $1, $2}' >> zproj_profile.txt
              gmt psxy zproj_profile.txt -W0.5p,black ${RJOK} >> map.ps

              # Project the points onto the line
              gmt mapproject proj_${this_z}.txt -Lzproj_profile.txt -fg | gawk '{print $(NF-1), $(NF) }'> zproj_projected_1.txt
              # gmt psxy zproj_projected_1.txt -St0.04i -Gblue ${RJOK} >> map.ps

              pointsX=$(gawk < zproj_profile.txt '(NR==2){print $1}')
              pointsY=$(gawk < zproj_profile.txt '(NR==2){print $2}')

              gmt mapproject zproj_projected_1.txt -G${pointsX}/${pointsY}+uk -Vn | gawk -v dist=${zproj_radius} '($3+0==$3){print $3/(dist*2)}'> zproj_distance_1.txt

              echo "Azimuth $azimuth"

              echo $azimuth $(gmt pshistogram zproj_distance_1.txt -T0/1/0.01 -Io | wc -l) >> zproj_results.txt
            done

            echo numbins was ${zproj_numbins[@]}

        #   done
        # fi
      ;;
      zhigh)

      ;;
      projlegend)
        echo "" > /dev/null
      ;;

      navticks)
        gmt psbasemap -Bg ${RJOK} >> map.ps
        gmt psbasemap -Bsg5d -Bpg1d --MAP_GRID_CROSS_SIZE_PRIMARY=-3p --MAP_GRID_CROSS_SIZE_SECONDARY=+5p --MAP_GRID_PEN_PRIMARY=default,blue --MAP_GRID_PEN_SECONDARY=default,red ${RJOK} >> map.ps
      ;;

      pstrain)
        PSTRAIN_MAXSTR=($(gawk < ${PSTRAIN_FILE} '
        BEGIN {
          max=0
        }
        ($1+0==$1) {
          thisid[NR]=$0
          thismag=sqrt($3*$3+$4*$4)
          max=(thismag>max)?thismag:max
          if (max==thismag) {
            maxNR=NR
          }
        }
        END {
          print thisid[maxNR]
        }'))

        PSTRAIN_SIZE_ADJ=$(echo ${PSTRAIN_MAXSTR[@]} | gawk -v insize=${PSTRAIN_SIZE} '
          {
            s=sqrt($3*$3+$4*$4)
            print insize/s
          }')

          gawk < ${PSTRAIN_FILE} '{print $1, $2, $3, 0, $5}' | gmt psvelo  -Sx${PSTRAIN_SIZE_ADJ}p -W${PSTRAIN_WIDTH},${PSTRAIN_COLOR_MAX} -A0.01/0.3/0.12 ${RJOK} ${VERBOSE} >> map.ps
          gawk < ${PSTRAIN_FILE} '{print $1, $2, 0, $4, $5}' | gmt psvelo  -Sx${PSTRAIN_SIZE_ADJ}p -W${PSTRAIN_WIDTH},${PSTRAIN_COLOR_MIN} -A0.01/0.3/0.12 ${RJOK} ${VERBOSE} >> map.ps
      ;;

      front)
        while read p; do
          if [[ ! -z $p && ! ${p:0:1} == "#" ]]; then
            pargs=($(echo $p))
            if [[ ! -s ${pargs[0]} ]]; then
              echo "File ${pargs[0]} does not exist or is empty"
            else
              # Fix the defaults
              [[ -z ${pargs[1]} ]] && pargs[1]="t"
              [[ -z ${pargs[2]} ]] && pargs[2]="l"
              [[ -z ${pargs[3]} ]] && pargs[3]="1c"
              [[ -z ${pargs[4]} ]] && pargs[4]="3p"
              [[ -z ${pargs[5]} ]] && pargs[5]="black"
              [[ -z ${pargs[6]} ]] && pargs[6]="1p"
              [[ -z ${pargs[7]} ]] && pargs[7]="black"

              if [[ ${pargs[0]} == *kml ]]; then
                kml_to_all_xy ${pargs[0]} tmp_line.xy
                # cat tmp_line.xy
                pargs[0]=tmp_line.xy
              fi

              # Plot the line with smoothing if asked
              if [[ $frontsmoothflag -eq 1 ]]; then
                # gmt sample1d a.txt
                # gawk < ${pargs[0]} '{ if ($1+0==$1) { print inc++, $1, $2 } else { print; inc=0 } }' > a.txt
                # gmt mapproject ${pargs[0]} -G+a+uk -o2,0,1 -hi1 | gmt sample1d -I$(echo ${FRONTSMOOTHINC} | gawk '{print $1+0}') -Fa -Ar
                gmt mapproject ${pargs[0]} -G+a+uk -o2,0,1 -hi1 | gmt sample1d -I$(echo ${FRONTSMOOTHINC} | gawk '{print $1+0}') -Fa -Ar | gawk '($1+0==$1) {print $2, $3} ($1+0!=$1) { print }' > spline.txt
                # cat spline.txt
                oldfile=${pargs[0]}
                pargs[0]="spline.txt"
              fi


              if [[ $frontspaceflag -eq 1 ]]; then
                pargs[3]=${FRONTSPACE}
              fi

              if [[ $frontscaleflag -eq 1 ]]; then
                pargs[4]=$(echo ${pargs[4]} | gawk -v mul=${FRONTSCALE} '{print ($1+0)*mul "p"}')
                pargs[6]=$(echo ${pargs[6]} | gawk -v mul=${FRONTSCALE} '{print ($1+0)*mul "p"}')
              fi
              # FRONTSCALE
              gmt psxy ${pargs[0]} -Sf${pargs[3]}/${pargs[4]}+${pargs[2]}+${pargs[1]}+p -W${pargs[6]},${pargs[5]} -G${pargs[7]} -t${FRONTTRANS} ${RJOK} ${VERBOSE} >> map.ps
              # gmt psxy ${pargs[0]} -Sc0.05i  -Gred ${RJOK} ${VERBOSE} >> map.ps
              # gmt psxy ${oldfile} -Sc0.05i  -Gblack ${RJOK} ${VERBOSE} >> map.ps

            fi
          fi
        done < ${FRONTFILE}

      ;;

      cutframe)
        MINPROJ_X=$(echo "(0 - ${CUTFRAME_DISTANCE})" | bc -l)
        MAXPROJ_X=$(echo "(${PROJDIM[0]}/2.54 + 2*${CUTFRAME_DISTANCE})" | bc -l)
        MINPROJ_Y=$(echo "(0 - ${CUTFRAME_DISTANCE})" | bc -l)
        MAXPROJ_Y=$(echo "(${PROJDIM[1]}/2.53 + 2*${CUTFRAME_DISTANCE})" | bc -l)

        gmt_init_tmpdir

        gmt psbasemap -R0/${MAXPROJ_X}/0/${MAXPROJ_Y} -JX${MAXPROJ_X}i/${MAXPROJ_Y}i -Xa-${CUTFRAME_DISTANCE}i -Ya-${CUTFRAME_DISTANCE}i  -Bltrb -O -K --MAP_FRAME_PEN=0.1p,black >> map.ps

        gmt_remove_tmpdir
      ;;

      mmi)

cat<<-EOF > mmi.cpt
0 255 255 255 1 255 255 255
1 255 255 255 2 191 204 255
2 191 204 255 3 160 230 255
3 160 230 255 4 128 255 255
4 128 255 255 5 122 255 147
5 122 255 147 6 255 255 0
6 255 255 0 7 255 200 0
7 255 200 0 8 255 145 0
8 255 145 0 9 255 0 0
9 255 0 0 10 200 0 0
10 200 0 0 13 128 0 0
B 255 255 255
F 128 0 0
N 255 255 255
EOF

  # <contlevel> [<angle>] C|c|A|a [<pen>]
cat<<-EOF > mmi.contourdef
1 c 0.5p,200/200/200
2 c 0.5p,191/204/255
3 A 1p,160/230/255
3.5 c 0.5p,160/230/255
4 A 1p,128/255/255
4.5 c 0.5p,128/255/255
5 A 1p,122/255/147
5.5 c 0.5p,122/255/147
6 A 1p,255/255/0
6.5 c 0.5p,255/255/0
7 A 1p,255/200/0
7.5 c 0.5p,255/200/0
8 A 1p,255/145/0
8.5 c 0.5p,255/145/0
9 A 1p,255/0/0
9.5 c 0.5p,255/0/0
10 A 1p,200/0/0
EOF

      for THIS_MMI_EVENTID in ${MMI_EVENTID[@]}; do
        echo ${THIS_MMI_EVENTID} is id
        info_msg "[-mmi]: Processing event ${THIS_MMI_EVENTID}"

        if [[ -s ${THIS_MMI_EVENTID} ]]; then
          THISMMIFILE=${THIS_MMI_EVENTID}
          cp ${THISMMIFILE} ./raster.zip
          echo copying
        else

          curl -s "https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson&eventid=${THIS_MMI_EVENTID}&producttype=shakemap" > event.geojson

          if [[ -s event.geojson ]]; then
            rm -f mmi_mean.nc mmi_filt.nc
            rm -f raster.zip

            # Find the url that ends in raster.zip and has the latest epoch of update
            raster_url=$(tr < event.geojson '{' '\n' | grep raster.zip | gawk -F\" '{ for(i=1; i<=NF; i++) { if ($(i)=="url") { print $(i+2) } } }' | grep "raster.zip$" | gawk -F/ 'BEGIN{max=0}{url[NR]=$0; if ($8>max) { max=$8; maxind=NR }} END { print url[maxind] }')

            info_msg "[-mmi]: Trying to download raster.zip from ${raster_url}"
            curl -s "${raster_url}" > raster.zip
            THISMMIFILE="raster.zip"
          fi
        fi
        if [[ -s raster.zip ]]; then
          info_msg "[-mmi]: Downloaded a raster.zip file"
          mkdir -p ./raster_zip_extract/
          rm -f ./raster_zip_extract/*
          unzip -qq raster.zip -d ./raster_zip_extract/
          rm -f raster.zip

          if [[ -s ./raster_zip_extract/mi.fit ]]; then
            info_msg "[-mmi]: Found a mi.fit file"
            gdal_translate -q -of "NetCDF" ./raster_zip_extract/mi.fit mmi_mean.nc
          elif [[ -s ./raster_zip_extract/mmi_mean.flt ]]; then
            info_msg "[-mmi]: Found a mmi_mean.flt file"
            gdal_translate -q -of "NetCDF" ./raster_zip_extract/mmi_mean.flt mmi_mean.nc
          else
            info_msg "[-mmi]: Didn't find a MMI file"
          fi

          # Plot and contour the MMI raster
          if [[ -s mmi_mean.nc ]]; then
            info_msg "[-mmi]: Processing mmi raster"
            # Gaussian filter to smooth the data to avoid crazy contours
            gmt grdfilter -Fg9 mmi_mean.nc -Gmmi_filt.nc -D2
            # Set anything less to MMI=3 to 0
            MMI_GRIDNAME="mmi_filt.nc"
            if [[ $MMI_CLIPGRID -eq 1 ]]; then
              gmt grdclip mmi_filt.nc -Sb3.45/NaN -Gmmi_clip.nc
              [[ -s mmi_clip.nc ]] && MMI_GRIDNAME="mmi_clip.nc"
            fi
            if [[ ${MMI_PLOTGRID} -eq 1 ]]; then
              gmt grdimage ${MMI_GRIDNAME} -Cmmi.cpt -t80 -Q ${RJOK} >> map.ps
            fi
            gmt grdcontour ${MMI_GRIDNAME} -A+f12p,Helvetica,${MMI_LABELCOLOR} -Cmmi.contourdef -S3  -Q50k ${RJOK}  >> map.ps
          fi
        fi

      done
      ;;

      tomoslice)

        gmt_init_tmpdir
        gawk < ${TOMOSLICEFILE} '($1+0==$1){print ($1>=180)?$1-360:$1, $2, $3}' | gmt surface  -R-180/180/-90/90 -G${TMP}tomography_slice.nc -i0,1,2 -I0.5 ${VERBOSE} >/dev/null 2>&1
        gmt_remove_tmpdir
        gmt grdimage tomography_slice.nc -t${TOMOSLICE_TRANS} -C${F_CPTS}tomography.cpt ${RJOK} ${VERBOSE} >> map.ps

      ;;

      caxes)

        for kinfile in ${F_KIN}*_axes_*.txt; do
          gawk < $kinfile -v scale=${CMTAXESSCALE} '
            @include "tectoplot_functions.awk"
            {
              print $1, $2, sin(deg2rad($3))*cos(deg2rad($4))*scale, cos(deg2rad($3))*cos(deg2rad($4))*scale, 0, 0, 0
              print $1, $2, sin(deg2rad($3-180))*cos(deg2rad($4))*scale, cos(deg2rad($3-180))*cos(deg2rad($4))*scale, 0, 0, 0

            }' > $kinfile".xy"
        done

        psvelostroke="-W1p,black"
        psvelostroke="-W0p"

        if [[ $axescmtthrustflag -eq 1 ]]; then
          # [[ $axestflag -eq 1 ]] && gawk  < ${F_KIN}t_axes_thrust.txt     -v scalev=${CMTAXESSCALE} 'function abs(v) { return (v>0)?v:-v} {print $1, $2, $3, abs(cos($4*pi/180))*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,purple -Gblack $RJOK $VERBOSE >> map.ps
          [[ $axestflag -eq 1 ]] && gmt psvelo ${F_KIN}t_axes_thrust.txt.xy ${psvelostroke} -G${T_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> map.ps
          [[ $axespflag -eq 1 ]] && gmt psvelo ${F_KIN}p_axes_thrust.txt.xy ${psvelostroke} -G${P_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> map.ps
          [[ $axesnflag -eq 1 ]] && gmt psvelo ${F_KIN}n_axes_thrust.txt.xy ${psvelostroke} -G${N_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> map.ps
          # [[ $axespflag -eq 1 ]] && gawk  < ${F_KIN}p_axes_thrust.txt     -v scalev=${CMTAXESSCALE} 'function abs(v) { return (v>0)?v:-v} {print $1, $2, $3, abs(cos($4*pi/180))*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,blue   -Gblack $RJOK $VERBOSE >> map.ps
          # [[ $axesnflag -eq 1 ]] && gawk  < ${F_KIN}n_axes_thrust.txt     -v scalev=${CMTAXESSCALE} 'function abs(v) { return (v>0)?v:-v} {print $1, $2, $3, abs(cos($4*pi/180))*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,green  -Gblack $RJOK $VERBOSE >> map.ps
        fi
        if [[ $axescmtnormalflag -eq 1 ]]; then
          [[ $axestflag -eq 1 ]] && gmt psvelo ${F_KIN}t_axes_normal.txt.xy ${psvelostroke} -G${T_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> map.ps
          [[ $axespflag -eq 1 ]] && gmt psvelo ${F_KIN}p_axes_normal.txt.xy ${psvelostroke} -G${P_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> map.ps
          [[ $axesnflag -eq 1 ]] && gmt psvelo ${F_KIN}n_axes_normal.txt.xy ${psvelostroke} -G${N_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> map.ps
          #
          # [[ $axestflag -eq 1 ]] && gawk  < ${F_KIN}t_axes_normal.txt     -v scalev=${CMTAXESSCALE} 'function abs(v) { return (v>0)?v:-v} {print $1, $2, $3, abs(cos($4*pi/180))*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,purple -Gblack $RJOK $VERBOSE >> map.ps
          # [[ $axespflag -eq 1 ]] && gawk  < ${F_KIN}p_axes_normal.txt     -v scalev=${CMTAXESSCALE} 'function abs(v) { return (v>0)?v:-v} {print $1, $2, $3, abs(cos($4*pi/180))*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,blue   -Gblack $RJOK $VERBOSE >> map.ps
          # [[ $axesnflag -eq 1 ]] && gawk  < ${F_KIN}n_axes_normal.txt     -v scalev=${CMTAXESSCALE} 'function abs(v) { return (v>0)?v:-v} {print $1, $2, $3, abs(cos($4*pi/180))*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,green  -Gblack $RJOK $VERBOSE >> map.ps
        fi
        if [[ $axescmtssflag -eq 1 ]]; then
          [[ $axestflag -eq 1 ]] && gmt psvelo ${F_KIN}t_axes_strikeslip.txt.xy ${psvelostroke} -G${T_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> map.ps
          [[ $axespflag -eq 1 ]] && gmt psvelo ${F_KIN}p_axes_strikeslip.txt.xy ${psvelostroke} -G${P_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> map.ps
          [[ $axesnflag -eq 1 ]] && gmt psvelo ${F_KIN}n_axes_strikeslip.txt.xy ${psvelostroke} -G${N_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> map.ps

          # [[ $axestflag -eq 1 ]] && gawk  < ${F_KIN}t_axes_strikeslip.txt -v scalev=${CMTAXESSCALE} 'function abs(v) { return (v>0)?v:-v} {print $1, $2, $3, abs(cos($4*pi/180))*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,purple -Gblack $RJOK $VERBOSE >> map.ps
          # [[ $axespflag -eq 1 ]] && gawk  < ${F_KIN}p_axes_strikeslip.txt -v scalev=${CMTAXESSCALE} 'function abs(v) { return (v>0)?v:-v} {print $1, $2, $3, abs(cos($4*pi/180))*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,blue   -Gblack $RJOK $VERBOSE >> map.ps
          # [[ $axesnflag -eq 1 ]] && gawk  < ${F_KIN}n_axes_strikeslip.txt -v scalev=${CMTAXESSCALE} 'function abs(v) { return (v>0)?v:-v} {print $1, $2, $3, abs(cos($4*pi/180))*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,green  -Gblack $RJOK $VERBOSE >> map.ps
        fi
        ;;

      # clipon)
      #   echo "[-clipon]: Activating interior clipping using ${CLIP_POLY_FILE}"
      #   [[ -s ${CLIP_POLY_FILE} ]] && gmt psclip ${CLIP_POLY_FILE} ${RJOK} ${VERBOSE} >> map.ps
      #   ;;
      #
      # clipout)
      #   echo "[-clipout]: Activating exterior clipping using ${CLIP_POLY_FILE}"
      #   [[ -s ${CLIP_POLY_FILE} ]] && gmt psclip -N ${CLIP_POLY_FILE} ${RJOK} ${VERBOSE} >> map.ps
      #   ;;
      #
      # clipoff)
      #   echo "[-clipoff]: Deactivating clipping"
      #   gmt psclip -C -K -O ${VERBOSE} >> map.ps
      #   ;;
      #
      # clipline)
      #   info_msg "[-clipline]: Plotting clipping path using ${CLIP_POLY_FILE}"
      #   [[ -s ${CLIP_POLY_FILE} ]] && gmt psxy ${CLIP_POLY_FILE} ${CLIP_POLY_PEN} ${RJOK} ${VERBOSE} >> map.ps
      #   ;;

      cmt)
        info_msg "Plotting focal mechanisms"

        if [[ $dontplotcmtflag -eq 0 ]]; then
          # This code only worked with the GlobalCMT format, not MomentTensor.
          # MomentTensor
          # 96.32 3.400000 33.000000 2.430 -0.020 -2.410 1.120 -1.680 1.840 30 96.24 3.18 C062076A 19.1 204124993

          if [[ $connectalternatelocflag -eq 1 ]]; then
            gawk < ${F_CMT}cmt_thrust.txt '{
              # If the event has an alternative position
              if ($11 != "none" && $12 != "none")  {
                print ">:" $1, $2, $3 ":" $11, $12, $14 >> "./cmt_alt_lines_thrust.xyz"
                print $11, $12, $14 >> "./cmt_alt_pts_thrust.xyz"
              } else {
              # Print the same start and end locations so that we don not mess up the number of lines in the file
                print ">:" $1, $2, $3 ":" $1, $2, $3  >> "./cmt_alt_lines_thrust.xyz"
                print $1, $2, $3 >> "./cmt_alt_pts_thrust.xyz"
              }
            }'
            gawk < ${F_CMT}cmt_normal.txt '{
              if ($11 != "none" && $12 != "none")  {  # Some events have no alternative position depending on format
                print ">:" $1, $2, $3 ":" $11, $12, $14 >> "./cmt_alt_lines_normal.xyz"
                print $11, $12, $14 >> "./cmt_alt_pts_normal.xyz"
              } else {
              # Print the same start and end locations so that we don not mess up the number of lines in the file
                print ">:" $1, $2, $3 ":" $1, $2, $3 >> "./cmt_alt_lines_normal.xyz"
                print $1, $2, $3 >> "./cmt_alt_pts_normal.xyz"
              }
            }'
            gawk < ${F_CMT}cmt_strikeslip.txt '{
              if ($11 != "none" && $12 != "none")  {  # Some events have no alternative position depending on format
                print ">:" $1, $2, $3 ":" $11, $12, $14 >> "./cmt_alt_lines_strikeslip.xyz"
                print $11, $12, $14 >> "./cmt_alt_pts_strikeslip.xyz"
              } else {
              # Print the same start and end locations so that we don not mess up the number of lines in the file
                print ">:" $1, $2, $3 ":" $1, $2, $3 >> "./cmt_alt_lines_strikeslip.xyz"
                print $1, $2, $3 >> "./cmt_alt_pts_strikeslip.xyz"
              }
            }'
            [[ -e cmt_alt_pts_thrust.xyz ]] && mv cmt_alt_pts_thrust.xyz ${F_CMT}
            [[ -e cmt_alt_pts_normal.xyz ]] && mv cmt_alt_pts_normal.xyz ${F_CMT}
            [[ -e cmt_alt_pts_strikeslip.xyz ]] && mv cmt_alt_pts_strikeslip.xyz ${F_CMT}

            [[ -e cmt_alt_lines_thrust.xyz ]] && mv cmt_alt_lines_thrust.xyz ${F_CMT}
            [[ -e cmt_alt_lines_normal.xyz ]] && mv cmt_alt_lines_normal.xyz ${F_CMT}
            [[ -e cmt_alt_lines_strikeslip.xyz ]] && mv cmt_alt_lines_strikeslip.xyz ${F_CMT}

            # Confirmed that the X,Y plot works with the .xyz format
            cat ${F_CMT}cmt_alt_lines_thrust.xyz | tr ':' '\n' | gmt psxy -W0.1p,black $RJOK $VERBOSE >> map.ps
            cat ${F_CMT}cmt_alt_lines_normal.xyz | tr ':' '\n' | gmt psxy -W0.1p,black $RJOK $VERBOSE >> map.ps
            cat ${F_CMT}cmt_alt_lines_strikeslip.xyz | tr ':' '\n' | gmt psxy -W0.1p,black $RJOK $VERBOSE >> map.ps

            gmt psxy ${F_CMT}cmt_alt_pts_thrust.xyz -Sc0.03i -Gblack $RJOK $VERBOSE >> map.ps
            gmt psxy ${F_CMT}cmt_alt_pts_normal.xyz -Sc0.03i -Gblack $RJOK $VERBOSE >> map.ps
            gmt psxy ${F_CMT}cmt_alt_pts_strikeslip.xyz -Sc0.03i -Gblack $RJOK $VERBOSE >> map.ps
          fi

          if [[ $zctimeflag -eq 1 ]]; then
            case ${CMTFORMAT} in
              GlobalCMT) #
              ;;
              MomentTensor) # 15 total fields, 0-14; epoch is in 14
                [[ -e ${F_CMT}cmt_thrust.txt ]] && gawk < ${F_CMT}cmt_thrust.txt '{temp=$3; $3=$15; print}' > ${F_CMT}cmt_thrust_time.txt
                CMT_THRUSTPLOT=$(abs_path ${F_CMT}cmt_thrust_time.txt)
                [[ -e ${F_CMT}cmt_normal.txt ]] && gawk < ${F_CMT}cmt_normal.txt '{temp=$3; $3=$15;print}' > ${F_CMT}cmt_normal_time.txt
                CMT_NORMALPLOT=$(abs_path ${F_CMT}cmt_normal_time.txt)
                [[ -e ${F_CMT}cmt_strikeslip.txt ]] && gawk < ${F_CMT}cmt_strikeslip.txt '{temp=$3; $3=$15; print}' > ${F_CMT}cmt_strikeslip_time.txt
                CMT_STRIKESLIPPLOT=$(abs_path ${F_CMT}cmt_strikeslip_time.txt)
              ;;
              TNP) #
              ;;
            esac
            # CMT_CPT=${F_CPTS}"eqtime_cmt.cpt"
          elif [[ $zcclusterflag -eq 1 ]]; then
            case ${CMTFORMAT} in
              GlobalCMT) #
              ;;
              MomentTensor) # 15 total fields, 0-14; epoch is in 14
                [[ -e ${F_CMT}cmt_thrust.txt ]] && gawk < ${F_CMT}cmt_thrust.txt '{temp=$3; $3=$16; $16=temp; print}' > ${F_CMT}cmt_thrust_cluster.txt
                CMT_THRUSTPLOT=$(abs_path ${F_CMT}cmt_thrust_cluster.txt)
                [[ -e ${F_CMT}cmt_normal.txt ]] && gawk < ${F_CMT}cmt_normal.txt '{temp=$3; $3=$16; $16=temp; print}' > ${F_CMT}cmt_normal_cluster.txt
                CMT_NORMALPLOT=$(abs_path ${F_CMT}cmt_normal_cluster.txt)
                [[ -e ${F_CMT}cmt_strikeslip.txt ]] && gawk < ${F_CMT}cmt_strikeslip.txt '{temp=$3; $3=$16; $16=temp; print}' > ${F_CMT}cmt_strikeslip_cluster.txt
                CMT_STRIKESLIPPLOT=$(abs_path ${F_CMT}cmt_strikeslip_cluster.txt)
              ;;
              TNP) #
              ;;
            esac
            # CMT_CPT=${F_CPTS}"eqcluster.cpt"
          else
            CMT_THRUSTPLOT=$(abs_path ${F_CMT}cmt_thrust.txt)
            CMT_NORMALPLOT=$(abs_path ${F_CMT}cmt_normal.txt)
            CMT_STRIKESLIPPLOT=$(abs_path ${F_CMT}cmt_strikeslip.txt)
            # CMT_CPT=$SEISDEPTH_CPT
          fi

          if [[ $cmtthrustflag -eq 1 ]]; then
            gmt psmeca -Z${CMT_CPT}  -E"${CMT_THRUSTCOLOR}" -T0/${CMT_LINEWIDTH},${CMT_LINECOLOR} -S${CMTLETTER}"$CMTRESCALE"i/0 ${CMT_THRUSTPLOT} -L${CMT_LINEWIDTH},${CMT_LINECOLOR} -i0-12 $RJOK $VERBOSE >> map.ps
            # gmt_psmeca_wrapper ${SEIS_CPT} -E"${CMT_THRUSTCOLOR}" -Tn/${CMT_LINEWIDTH},${CMT_LINECOLOR} -S${CMTLETTER}"$CMTRESCALE"i/0 ${CMT_THRUSTPLOT} -L${CMT_LINEWIDTH},${CMT_LINECOLOR} $RJOK $VERBOSE >> map.ps
          fi
          if [[ $cmtnormalflag -eq 1 ]]; then
            gmt psmeca -Z${CMT_CPT} -E"${CMT_NORMALCOLOR}" -T0/${CMT_LINEWIDTH},${CMT_LINECOLOR} -S${CMTLETTER}"$CMTRESCALE"i/0 ${CMT_NORMALPLOT} -L${CMT_LINEWIDTH},${CMT_LINECOLOR} -i0-12 $RJOK $VERBOSE >> map.ps
          fi
          if [[ $cmtssflag -eq 1 ]]; then
            gmt psmeca -Z${CMT_CPT} -E"${CMT_SSCOLOR}" -T0/${CMT_LINEWIDTH},${CMT_LINECOLOR} -S${CMTLETTER}"$CMTRESCALE"i/0 ${CMT_STRIKESLIPPLOT} -L${CMT_LINEWIDTH},${CMT_LINECOLOR} -i0-12 $RJOK $VERBOSE >> map.ps
          fi
        fi
        ;;

      contours)

        # We want to plot contours intelligently and nicely including major-minor
        # contour thickness and labeling only of major contours, without double
        # plotting of contours. We also want to cut contours to 32,000 points to
        # allow them to appear in Adobe Illustrator

        if [[ $topocontourlistflag -eq 1 ]]; then
          gmt grdcontour ${TOPOGRAPHY_DATA} -A+f2p,Helvetica,black -C${TOPOCONTOURLIST} ${TOPOCONTOURSMOOTH} ${TOPOCONTOURTRANS} ${TOPOCONTOURSPACE} ${TOPOCONTOURMINSIZE} $RJOK ${VERBOSE} -D > majorcontourlines.dat
        else
          # Contour interval for grid if not specified using -tn
          zrange=($(grid_zrange ${TOPOGRAPHY_DATA} -R${DEM_MINLON}/${DEM_MAXLON}/${DEM_MINLAT}/${DEM_MAXLAT}))
          if [[ $topocontourcalcflag -eq 1 ]]; then
            TOPOCONTOURINT=$(echo "(${zrange[1]} - ${zrange[0]}) / $TOPOCONTOURNUMDEF" | bc -l)
            # If the contour interval is greater than 1, use an integer interval
            if [[ $(echo "$TOPOCONTOURINT > 1" | bc -l) -eq 1 ]]; then
              TOPOCONTOURINT=$(echo "$TOPOCONTOURINT / 1" | bc)
            fi
          fi

          gawk -v minz=${zrange[0]} -v maxz=${zrange[1]} -v cint=$TOPOCONTOURINT -v majorspace=${CONTOURMAJORSPACE} \
               -v minwidth=${TOPOCONTOURMINORWIDTH} -v maxwidth=${TOPOCONTOURMAJORWIDTH} -v mincolor=${TOPOCONTOURMINORCOLOR} \
               -v maxcolor=${TOPOCONTOURMAJORCOLOR} -v annotate=0 -v indexflag=${topocontourindexflag} -v indexval=${TOPOCONTOURINDEX} '
            BEGIN {
              if (annotate==1) {
                annotateflag="A"
              } else {
                annotateflag="c"
              }

              while (indexval <= maxz) {
                indexval+=majorspace*cint
              }
              while (indexval >= minz) {
                indexval-=majorspace*cint
              }

            # Ensure indexval is a major contour
              ismaj=0

              print indexval, annotateflag, maxwidth "p," maxcolor >> "topo.major.contourdef"
              for(i=indexval-cint; i>=minz; i-=cint) {
                if (++ismaj == majorspace) {
                  print i, annotateflag, maxwidth "p," maxcolor >> "topo.major.contourdef"
                  ismaj=0
                } else {
                  print i, "c", minwidth "p," mincolor >> "topo.minor.contourdef"
                }
              }
              ismaj=0
              for(i=indexval+cint; i<=maxz; i+=cint) {
                if (++ismaj == majorspace) {
                  print i, annotateflag, maxwidth "p," maxcolor >> "topo.major.contourdef"
                  ismaj=0
                } else {
                  print i, "c", minwidth "p," mincolor >> "topo.minor.contourdef"
                }
              }
            }
            '

          if [[ -s topo.major.contourdef ]]; then
             gmt grdcontour ${TOPOGRAPHY_DATA} -Ctopo.major.contourdef -D ${TOPOCONTOURSMOOTH} ${TOPOCONTOURSPACE} ${TOPOCONTOURMINSIZE} ${VERBOSE} > majorcontourlines.dat
          fi

          if [[ -s topo.minor.contourdef ]]; then
             gmt grdcontour ${TOPOGRAPHY_DATA} -Ctopo.minor.contourdef -D ${TOPOCONTOURSMOOTH} ${TOPOCONTOURTRANS} ${TOPOCONTOURSPACE} ${TOPOCONTOURMINSIZE} ${VERBOSE} > minorcontourlines.dat
          fi
        fi

        if [[ -s majorcontourlines.dat ]]; then
           # Adobe Illustrator only draws the first 32,000 points in a path for SOME STUPID REASON
           gawk < majorcontourlines.dat -v maxpts=2000 '
           BEGIN {
             curcount=0
             linecount=0
           }
           ($1+0!=$1) {
             header=$0
             curcount=0
             linecount++
           }
           ($1+0==$1) {

             curcount++
             if (curcount==maxpts) {
               print header
               print lastline
               curcount=0
             }
             lastline=$0
           }
           {
             print
           }' > splitmajorcontourlines.dat

           gmt psxy splitmajorcontourlines.dat -Sqn1+r${TOPOCONTOURLABELSEP}:+f${TOPOCONTOURFONTSIZE}p,Helvetica,black+Lh+e -W${TOPOCONTOURMAJORWIDTH},${TOPOCONTOURMAJORCOLOR} ${TOPOCONTOURTRANS} ${RJOK} >> map.ps
           # gmt psxy splitmajorcontourlines.dat ${TOPOCONTOURTRANS} -W${TOPOCONTOURMAJORWIDTH},${TOPOCONTOURMAJORCOLOR} ${RJOK} >> map.ps
           # gmt psclip -C ${RJOK} >> map.ps
           # gmt psxy majorcontourlines.dat -W${TOPOCONTOURMAJORWIDTH},${TOPOCONTOURMAJORCOLOR} ${RJOK} >> map.ps
        fi

        if [[ -s minorcontourlines.dat ]]; then
             gawk < minorcontourlines.dat -v maxpts=2000 '
             BEGIN {
               curcount=0
               linecount=0
             }
             ($1+0!=$1) {
               header=$0
               curcount=0
               linecount++
             }
             ($1+0==$1) {

               curcount++
               if (curcount==maxpts) {
                 print header
                 print lastline
                 curcount=0
               }
               lastline=$0
             }
             {
               print
             }' > splitminorcontourlines.dat
             # gmt psxy splitminorcontourlines.dat -Sqn1:+f2p,Helvetica,black+Lh+i+e ${RJOK} >> map.ps
             gmt psxy splitminorcontourlines.dat ${TOPOCONTOURTRANS} -W${TOPOCONTOURMINORWIDTH},${TOPOCONTOURMINORCOLOR} ${RJOK} >> map.ps
             # gmt psclip -C ${RJOK} >> map.ps
             # gmt psxy minorcontourlines.dat -W${TOPOCONTOURMINORWIDTH},${TOPOCONTOURMINORCOLOR} ${RJOK} >> map.ps
        fi
        ;;

      customtopo)
        if [[ $dontplottopoflag -eq 0 ]]; then
          info_msg "Plotting custom topography $CUSTOMBATHY"
          gmt grdimage $CUSTOMBATHY $GRID_PRINT_RES ${ILLUM} -C$TOPO_CPT -t$TOPOTRANS $RJOK $VERBOSE >> map.ps
          # -I+d
        else
          info_msg "Custom topo image plot suppressed using -ts"
        fi
        ;;

        regionreport)


          rm -f range.dat
          # Plot AOI boxes of GMRT tiles
          for sfile in ${SAVEDTOPODIR}*.tif; do
            gdalinfo ${sfile} | gawk '
              ($1=="Upper" && $2 == "Left") {
                split($0, ts, "(")
                split(ts[2], tt, ",")
                split(tt[2], tu, ")")
                minlon=tt[1]
                maxlat=tu[1]
              }
              ($1=="Lower" && $2 == "Right") {
                split($0, ts, "(")
                split(ts[2], tt, ",")
                split(tt[2], tu, ")")
                maxlon=tt[1]
                minlat=tu[1]
              }
              END {
                print ">"
                print minlon, minlat
                print minlon, maxlat
                print maxlon, maxlat
                print maxlon, minlat
                print minlon, minlat
              }' >> range.dat
          done
          gmt psxy range.dat -W0p -Gblack -t70 ${RJOK} ${VERBOSE} >> map.ps

          for bfile in ${CUSTOMREGIONSDIR}*.xy; do
            gmt psxy $bfile -W1p,red ${RJOK} ${VERBOSE} >> map.ps

            # Calculate the centroid of the XY file
            # Calculate the true centroid of each polygon and output it to the label file
            gawk < $bfile -v region=$(basename ${bfile}) '{
              x[NR] = $1;
              y[NR] = $2;
            }
            END {
                x[NR+1] = x[1];
                y[NR+1] = y[1];

                SXS = 0;
                SYS = 0;
                AS = 0;
                for (i = 1; i <= NR; ++i) {
                  J[i] = (x[i]*y[i+1]-x[i+1]*y[i]);
                  XS[i] = (x[i]+x[i+1]);
                  YS[i] = (y[i]+y[i+1]);
                }
                for (i = 1; i <= NR; ++i) {
                  SXS = SXS + (XS[i]*J[i]);
                  SYS = SYS + (YS[i]*J[i]);
                  AS = AS + (J[i]);
              }
              AS = 1/2*AS;
              CX = 1/(6*AS)*SXS;
              CY = 1/(6*AS)*SYS;

              region_cut=substr(region, 1, length(region)-3)
              print CX, CY, "10p,Helvetica,black", 0, "CM", region_cut
            }' | gmt pstext -F+f+a+j $RJOK $VERBOSE >> map.ps
    # -67.69	-31.22	10p,Helvetica,black	0	TR	Z112377A+usp0000rp1(7.5)
          done

      ;;

      datareport)

        shopt -s nullglob

        for this_id in ${datareport_ids[@]}; do
          case $this_id in
            cuttopo)
              for erfile in ${EARTHRELIEFDIR}*.tif; do
                this_erfile=$(echo $erfile | gawk -F_ '{print $3}')
                case $this_erfile in
                  01m) COLOR=200/200/200 ;;
                  05m) COLOR=170/170/170 ;;
                  10m) COLOR=140/140/140 ;;
                  15s) COLOR=110/110/110 ;;
                  03s) COLOR=80/80/80 ;;
                  01s) COLOR=50/50/50 ;;
                  *) COLOR=10/10/10 ;;
                esac
                gmt grdinfo -C ${erfile} | gawk '
                  ($2+0==$2 && $3+0==$3 && $4+0==$4 && $5+0==$5 && ($3-$2)<360 && ($4-$5)<180){
                    # $1 = filename $2=minlon $3=maxlon $4=minlat $5=maxlat
                    print ">"
                    print $2, $4
                    print $2, $5
                    print $3, $5
                    print $3, $4
                    print $2, $4
                  }' | gmt psxy -A -G$COLOR ${RJOK} ${VERBOSE} -t50 >> map.ps
              done
            ;;
            EARTHRELIEF)
              sequence=(30m 05m 04m 01m 15s 03s 01s)
              this_color=0
              for this_seq in ${sequence[@]}; do
                rm -f range.dat
                if [[ -d ~/.gmt/server/earth/ ]]; then
                  search_files=($(find ~/.gmt/server/earth/earth_relief \( -name '*.nc' -or -name '*.grd' \) | grep $this_seq))
                  for this_search_file in ${search_files[@]}; do
                    gmt grdinfo -C $this_search_file | gawk '
                      ($2+0==$2 && $3+0==$3 && $4+0==$4 && $5+0==$5){
                        # $1 = filename $2=minlon $3=maxlon $4=minlat $5=maxlat
                        print ">"
                        print $2, $4
                        print $2, $5
                        print $3, $5
                        print $3, $4
                        print $2, $4
                      }' >> range.dat
                   done
                fi
                [[ -s range.dat ]] && gmt psxy range.dat -A -G$this_color/0/0 ${RJOK} ${VERBOSE} >> map.ps
                ((this_color+=30))
              done
            ;;
            GMRT)
              rm -f range.dat
              # Plot AOI boxes of GMRT tiles
              for gmrtfile in ${GMRTDIR}*.tif; do
                gmt grdinfo -C ${gmrtfile} | gawk '
                  ($2+0==$2 && $3+0==$3 && $4+0==$4 && $5+0==$5){
                    # $1 = filename $2=minlon $3=maxlon $4=minlat $5=maxlat
                    print ">"
                    print $2, $4
                    print $2, $5
                    print $3, $5
                    print $3, $4
                    print $2, $4
                  }' >> range.dat
              done
              [[ -s range.dat ]] && gmt psxy range.dat -A -Gblue -t50 ${RJOK} ${VERBOSE} >> map.ps
            ;;
            sentinel)
              rm -f range.dat
              # Plot AOI boxes of GMRT tiles
              for sentinelfile in ${SENT_DIR}*.jpg; do
                gdalinfo ${sentinelfile} | gawk '
                  ($1=="Upper" && $2 == "Left") {
                    split($0, ts, "(")
                    split(ts[2], tt, ",")
                    split(tt[2], tu, ")")
                    minlon=tt[1]
                    maxlat=tu[1]
                  }
                  ($1=="Lower" && $2 == "Right") {
                    split($0, ts, "(")
                    split(ts[2], tt, ",")
                    split(tt[2], tu, ")")
                    maxlon=tt[1]
                    minlat=tu[1]
                  }
                  END {
                    print ">"
                    print minlon, minlat
                    print minlon, maxlat
                    print maxlon, maxlat
                    print maxlon, minlat
                    print minlon, minlat
                  }' >> range.dat
              done
              [[ -s range.dat ]] && gmt psxy range.dat -A -Ggreen ${RJOK} ${VERBOSE} >> map.ps
            ;;
          esac
        done
        ;;

      eqlabel)

        # The goal is to create labels for selected events that don't extend off the
        # map area. Currently, the labels will overlap for closely spaced events.
        # There may be space for a more intelligent algorithm that tries to
        # avoid conflicts by limiting the number of events at the same 'latitude'

        FONTSTR=$(echo "${EQ_LABEL_FONTSIZE},${EQ_LABEL_FONT},${EQ_LABEL_FONTCOLOR}")

        if [[ -e $CMTFILE ]]; then
          if [[ $labeleqlistflag -eq 1 && ${#eqlistarray[@]} -ge 1 ]]; then
            for i in ${!eqlistarray[@]}; do
              grep -- "${eqlistarray[$i]}" $CMTFILE >> ${F_CMT}cmtlabel.sel
            done
          fi

          if [[ $labeleqmagflag -eq 1 ]]; then
            gawk < $CMTFILE -v minmag=$labeleqminmag '($13>=minmag) {print}'  >> ${F_CMT}cmtlabel.sel
          fi

          # 39 fields in cmt file. NR=texc NR-1=font

          gawk < ${F_CMT}cmtlabel.sel -v clon=$CENTERLON -v clat=$CENTERLAT -v font=$FONTSTR -v ctype=$CMTTYPE '{
            if (ctype=="ORIGIN") { lon=$8; lat=$9; depth=$10 } else { lon=$5; lat=$6; depth=$7 }
            id=$2
            timecode=$3
            mag=int($13*10)/10
            epoch=$4
            if (lon > clon) {
              hpos="R"
            } else {
              hpos="L"
            }
            if (lat < clat) {
              vpos="B"
            } else {
              vpos="T"
            }
            print lon, lat, depth, mag, timecode, id, epoch, font, vpos hpos
          }' > ${F_CMT}cmtlabel_pos.sel

          cat ${F_CMT}cmtlabel_pos.sel >> ${F_PROFILES}profile_labels.dat

          # GT Z112377A+usp0000rp1 1977-11-23T09:26:24 249098184 -67.69 -31.22 20.8 -67.77 -31.03 13 GCMT MLI 7.47968 3.059403 33 183 44 90 4 46 90 27 1.860 289 89 0.020 184 0 -1.870 94 1 27 1.855 0.008 -1.863 0.013 0.065 -0.119 23.7 10p,Helvetica,black TR

          # idcode event_code timecode epoch lon_centroid lat_centroid depth_centroid lon_origin lat_origin depth_origin author_centroid author_origin magnitude mantissa exponent strike1 dip1 rake1 strike2 dip2 rake2 exponent tval taz tinc nval naz ninc pval paz pinc exponent mrr mtt mpp mrt mrp mtp centroid_dt
          # GT S201509162318A+us20003k7w 2015-09-16T23:18:41 1442416721 -71.95 -31.79 35.7 -71.43 -31.56 28.4 GCMT PDEW 7.13429 1.513817 31 349 30 87 173 60 92 26 5.912 87 75 -0.538 352 1 -5.371 261 15 26 5.130 -0.637 -4.490 0.265 -2.850 0.641 10.3 10p,Helvetica,black TL

          # Lon lat depth mag timecode ID epoch font just
          # -72.105 -35.155 35 7.7 1928-12-01T04:06:17 iscgem908986 -1296528823 10p,Helvetica,black BL

          # lon lat font 0 just ID
          # -67.69	-31.22	10p,Helvetica,black	0	TR	Z112377A+usp0000rp1(7.5)

          # -67.69	-31.22	10p,Helvetica,black	0	TR	Z112377A+usp0000rp1(7.5)

          [[ $EQ_LABELFORMAT == "idmag" ]] && gawk  < ${F_CMT}cmtlabel_pos.sel '{ printf "%s\t%s\t%s\t%s\t%s\t%s(%0.1f)\n", $1, $2, $8, 0, $9, $6, $4 }' >> ${F_CMT}cmt.labels
          [[ $EQ_LABELFORMAT == "datemag" ]] && gawk  < ${F_CMT}cmtlabel_pos.sel '{ split($5,tmp,"T"); printf "%s\t%s\t%s\t%s\t%s\t%s(%0.1f)\n", $1, $2, $8, 0, $9, tmp[1], $4 }' >> ${F_CMT}cmt.labels
          [[ $EQ_LABELFORMAT == "datetime" ]] && gawk  < ${F_CMT}cmtlabel_pos.sel '{ split($5,tmp,"T"); printf "%s\t%s\t%s\t%s\t%s\t%s %s\n", $1, $2, $8, 0, $9, tmp[1], tmp[2] }' >> ${F_CMT}cmt.labels
          [[ $EQ_LABELFORMAT == "dateid" ]] && gawk  < ${F_CMT}cmtlabel_pos.sel '{ split($5,tmp,"T"); printf "%s\t%s\t%s\t%s\t%s\t%s(%s)\n", $1, $2, $8, 0, $9, tmp[1], $6 }' >> ${F_CMT}cmt.labels
          [[ $EQ_LABELFORMAT == "id" ]] && gawk  < ${F_CMT}cmtlabel_pos.sel '{ printf "%s\t%s\t%s\t%s\t%s\t%s\n", $1, $2, $8, 0, $9, $6 }' >> ${F_CMT}cmt.labels
          [[ $EQ_LABELFORMAT == "date" ]] && gawk  < ${F_CMT}cmtlabel_pos.sel '{ split($5,tmp,"T"); printf "%s\t%s\t%s\t%s\t%s\t%s\n", $1, $2, $8, 0, $9, tmp[1] }' >> ${F_CMT}cmt.labels
          [[ $EQ_LABELFORMAT == "year" ]] && gawk  < ${F_CMT}cmtlabel_pos.sel '{ split($5,tmp,"T"); split(tmp[1],tmp2,"-"); printf "%s\t%s\t%s\t%s\t%s\t%s\n", $1, $2, $8, 0, $9, tmp2[1] }' >> ${F_CMT}cmt.labels
          [[ $EQ_LABELFORMAT == "yearmag" ]] && gawk  < ${F_CMT}cmtlabel_pos.sel '{ split($5,tmp,"T"); split(tmp[1],tmp2,"-"); printf "%s\t%s\t%s\t%s\t%s\t%s(%s)\n", $1, $2, $8, 0, $9, tmp2[1], $4 }' >> ${F_CMT}cmt.labels
          [[ $EQ_LABELFORMAT == "mag" ]] && gawk  < ${F_CMT}cmtlabel_pos.sel '{ printf "%s\t%s\t%s\t%s\t%s\t%0.1f\n", $1, $2, $8, 0, $9, $4  }' >> ${F_CMT}cmt.labels
          [[ $EQ_LABELFORMAT == "time" ]] && gawk  < ${F_CMT}cmtlabel_pos.sel '{ split($5,tmp,"T"); printf "%s\t%s\t%s\t%s\t%s\t%s\n", $1, $2, $8, 0, $9, tmp[2] }' >> ${F_CMT}cmt.labels


          if [[ $LABELSONMAP -eq 1 ]]; then
            uniq -u ${F_CMT}cmt.labels | gmt pstext -Dj${EQ_LABEL_DISTX}/${EQ_LABEL_DISTY}+v0.7p,black -Gwhite -F+f+a+j -W0.5p,black $RJOK $VERBOSE >> map.ps
          else
            # Create a 'labels only' map for easier editing
            gmt psbasemap "${BSTRING[@]}" ${RJSTRING} $VERBOSE -K  > cmtlabel_map.ps
            uniq -u ${F_CMT}cmt.labels | gmt pstext -Dj${EQ_LABEL_DISTX}/${EQ_LABEL_DISTY}+v0.7p,black -Gwhite  -F+f+a+j -W0.5p,black ${RJSTRING} -O $VERBOSE >> cmtlabel_map.ps
          fi
        fi

        if [[ -e ${F_SEIS}eqs.txt ]]; then
          if [[ $labeleqlistflag -eq 1 && ${#eqlistarray[@]} -ge 1 ]]; then
            for i in ${!eqlistarray[@]}; do
              grep -- "${eqlistarray[$i]}" ${F_SEIS}eqs.txt >> ${F_SEIS}eqlabel.sel
            done
          fi
          if [[ $labeleqmagflag -eq 1 ]]; then
            gawk < ${F_SEIS}eqs.txt -v minmag=$labeleqminmag '($4>=minmag) {print}'  >> ${F_SEIS}eqlabel.sel
          fi

          # eqlabel_pos.sel is in the format:
          # lon lat depth mag timecode ID epoch font justification
          # -70.3007 -33.2867 108.72 4.1 2021-02-19T11:49:05 us6000diw5 1613706545 10p,Helvetica,black TL

          gawk < ${F_SEIS}eqlabel.sel -v clon=$CENTERLON -v clat=$CENTERLAT -v font=$FONTSTR '{
            if ($1 > clon) {
              hpos="R"
            } else {
              hpos="L"
            }
            if ($2 < clat) {
              vpos="B"
            } else {
              vpos="T"
            }
            print $1, $2, $3, int($4*10)/10, $5, $6, $7, font, vpos hpos
          }' > ${F_SEIS}eqlabel_pos.sel

          cat ${F_SEIS}eqlabel_pos.sel >> ${F_PROFILES}profile_labels.dat

          # eq.labels is in the format:
          # lon lat font 0 justification labeltext
          # -70.3007	-33.2867	10p,Helvetica,black	0	TL	us6000diw5(4.1)


          [[ $EQ_LABELFORMAT == "idmag"   ]] && gawk  < ${F_SEIS}eqlabel_pos.sel '{ printf "%s\t%s\t%s\t%s\t%s\t%s M%0.1f\n", $1, $2, $8, 0, $9, $6, $4  }' >> ${F_SEIS}eq.labels
          [[ $EQ_LABELFORMAT == "datemag" ]] && gawk  < ${F_SEIS}eqlabel_pos.sel '{ split($5,tmp,"T"); printf "%s\t%s\t%s\t%s\t%s\t%s M%0.1f\n", $1, $2, $8, 0, $9, tmp[1], $4 }' >> ${F_SEIS}eq.labels
          [[ $EQ_LABELFORMAT == "datetime" ]] && gawk  < ${F_SEIS}eqlabel_pos.sel '{ split($5,tmp,"T"); printf "%s\t%s\t%s\t%s\t%s\t%s %s\n", $1, $2, $8, 0, $9, tmp[1], tmp[2] }' >> ${F_SEIS}eq.labels
          [[ $EQ_LABELFORMAT == "dateid"   ]] && gawk  < ${F_SEIS}eqlabel_pos.sel '{ split($5,tmp,"T"); printf "%s\t%s\t%s\t%s\t%s\t%s(%s)\n", $1, $2, $8, 0, $9, tmp[1], $6 }' >> ${F_SEIS}eq.labels
          [[ $EQ_LABELFORMAT == "id"   ]] && gawk  < ${F_SEIS}eqlabel_pos.sel '{ printf "%s\t%s\t%s\t%s\t%s\t%s\n", $1, $2, $8, 0, $9, $6  }' >> ${F_SEIS}eq.labels
          [[ $EQ_LABELFORMAT == "date"   ]] && gawk  < ${F_SEIS}eqlabel_pos.sel '{ split($5,tmp,"T"); printf "%s\t%s\t%s\t%s\t%s\t%s\n", $1, $2, $8, 0, $9, tmp[1] }' >> ${F_SEIS}eq.labels
          [[ $EQ_LABELFORMAT == "year"   ]] && gawk  < ${F_SEIS}eqlabel_pos.sel '{ split($5,tmp,"T"); split(tmp[1],tmp2,"-"); printf "%s\t%s\t%s\t%s\t%s\t%s\n", $1, $2, $8, 0, $9, tmp2[1] }' >> ${F_SEIS}eq.labels
          [[ $EQ_LABELFORMAT == "yearmag"   ]] && gawk  < ${F_SEIS}eqlabel_pos.sel '{ split($5,tmp,"T"); split(tmp[1],tmp2,"-"); printf "%s\t%s\t%s\t%s\t%s\t%s M%0.1f\n", $1, $2, $8, 0, $9, tmp2[1], $4 }' >> ${F_SEIS}eq.labels
          [[ $EQ_LABELFORMAT == "mag"   ]] && gawk  < ${F_SEIS}eqlabel_pos.sel '{ printf "%s\t%s\t%s\t%s\t%s\tM%0.1f\n", $1, $2, $8, 0, $9, $4  }' >> ${F_SEIS}eq.labels
          [[ $EQ_LABELFORMAT == "time" ]] && gawk  < ${F_SEIS}eqlabel_pos.sel '{ split($5,tmp,"T"); printf "%s\t%s\t%s\t%s\t%s\t%s\n", $1, $2, $8, 0, $9, tmp[2] }' >> ${F_SEIS}eq.labels

          if [[ $LABELSONMAP -eq 1 ]]; then
              # output the X and Y page coordinates of the labeled points

              #
              # gmt mapproject ${F_SEIS}eq.labels ${RJSTRING} -Dp -i0,1 | gawk 'BEGIN{OFS="\t"} { print $1, $2 }' > eq.labels.xy
              # LABEL_WIDTH_P=$(echo "${MAP_PS_WIDTH_NOLABELS_IN} * 72" | bc -l)
              # LABEL_HEIGHT_P=$(echo "${MAP_PS_HEIGHT_NOLABELS_IN} * 72" | bc -l)
              # paste eq.labels.xy ${F_SEIS}eq.labels > eq.labels.combined
              #
              # EQ_LABEL_DISTX_1=".1i"
              # EQ_LABEL_DISTY_1=".1i"
              # EQ_LABEL_DIST=$(echo "${EQ_LABEL_DISTX}" | gawk '{print ($1+0)*72}')
              # EQ_LABEL_DISTX_2=$(echo "${EQ_LABEL_DISTX_1}" | gawk '{print ($1+0)*1.5 "i"}')
              # EQ_LABEL_DISTY_2=$(echo "${EQ_LABEL_DISTY_1}" | gawk '{print ($1+0)*1.5 "i"}')
              # EQFONTSIZE=$(echo ${EQ_LABEL_FONTSIZE} | gawk '{print $1+0}')
              # python ~/Dropbox/scripts/tectoplot/pythonscripts/labelme_extended.py eq.labels.combined ${LABEL_WIDTH_P} ${LABEL_HEIGHT_P} ${EQ_LABEL_DIST} ${EQFONTSIZE}
              #
              # # uniq -u ${F_SEIS}eq.labels | gmt pstext -DJ${EQ_LABEL_DISTX}/${EQ_LABEL_DISTY}+v0.7p,black -Gred  -F+f+a+j -W0.5p,black $RJOK $VERBOSE >> map.ps
              #
              # gawk < newlabels.txt '
              #   BEGIN {
              #     IFS="\t"
              #     OFS="\t"
              #   }
              #   {
              #     id=$1
              #     outstring=$2
              #     for(i=3; i<=NF; i++) {
              #       outstring=sprintf("%s\t%s", outstring, $(i))
              #     }
              #     print outstring >> "newlabels_" id ".txt"
              #   }
              # '
              #
              # if [[ -s newlabels_1.txt ]]; then
              #   uniq -u newlabels_1.txt | gmt pstext -Dj${EQ_LABEL_DISTX_1}/${EQ_LABEL_DISTY_1}+v0.7p,black -Gwhite  -F+f+a+j -W0.5p,black $RJOK $VERBOSE >> map.ps
              # fi
              # if [[ -s newlabels_2.txt ]]; then
              #   uniq -u newlabels_2.txt | gmt pstext -Dj${EQ_LABEL_DISTX_2}/${EQ_LABEL_DISTY_2}+v0.7p,black -Gwhite  -F+f+a+j -W0.5p,black $RJOK $VERBOSE >> map.ps
              # fi

              LABEL_FILE=${F_SEIS}eq.labels
              LABEL_FONTSIZE=$(echo ${EQ_LABEL_FONTSIZE})
              LABEL_DIST=${EQ_LABEL_DISTX}
              LABEL_PSFILE=map.ps
              LABEL_BOXLINE="0.1p,black"
              LABEL_BOXCOLOR="white"

              source ${PLOTLABELS}

          else
              # Create a 'labels only' map for easier editing
              gmt psbasemap "${BSTRING[@]}" ${RJSTRING} $VERBOSE -K  > eqlabel_map.ps
              uniq -u ${F_SEIS}eq.labels | gmt pstext -Dj${EQ_LABEL_DISTX}/${EQ_LABEL_DISTY}+v0.7p,black -Gwhite  -F+f+a+j -W0.5p,black ${RJSTRING} -O $VERBOSE >> eqlabel_map.ps
          fi
        fi
        ;;

      execute)
        info_msg "Executing script $EXECUTEFILE. Be Careful!"
        source "${EXECUTEFILE}" ${EXEC_ARGS[@]}
        ;;

      extragps)

        # info_msg "Plotting extra GPS dataset ${USERGPSDATAFILE[$current_userlinefilenumber]}"
        # if [[ ${USERGPSLOG_arr[$current_usergpsfilenumber]} -eq 1 ]]; then
        #   # gawk < ${USERGPSDATAFILE[$current_usergpsfilenumber]} '
        #   #   function abs(x) { return (x>0)?x:-x }
        #   #   function sign(x) { return (x>1)?1:-1 }
        #   #   {
        #   #     print $1, $2, sign($3)*log(abs($3)), sign($4)*log(abs($4)), sign($5)*log(abs($5)), sign($6)*log(abs($6)), $7
        #   #   }
        #   #   '
        #   #   # | gmt psvelo  -W${EXTRAGPS_LINEWIDTH},${EXTRAGPS_LINECOLOR} -G${USERGPSCOLOR_arr[$current_usergpsfilenumber]} -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 -L $RJOK $VERBOSE >> map.ps 2>/dev/null
        # else

        if [[ ${USERGPSNOPLOT_arr[$current_usergpsfilenumber]} -ne 1 ]]; then
          gawk < ${USERGPSDATAFILE[$current_usergpsfilenumber]} -v minsig=${GPS_MINSIG} '
          {
            $5 = ($5+0 < minsig) ? minsig : $5
            $6 = ($6+0 < minsig) ? minsig : $6
            $7 = ($7+0 > 0) ? $7+0 : 0
            print $0
          }' > ${F_GPS}custom_gps_$current_usergpsfilenumber.txt
          gmt psvelo ${F_GPS}custom_gps_$current_usergpsfilenumber.txt -W${EXTRAGPS_LINEWIDTH},${EXTRAGPS_LINECOLOR} -G${USERGPSCOLOR_arr[$current_usergpsfilenumber]} -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 -L $RJOK $VERBOSE >> map.ps 2>/dev/null
        fi

        if [[ ${USERGPSMERGE_arr[$current_usergpsfilenumber]} -eq 1 ]]; then
          cat ${F_GPS}custom_gps_$current_usergpsfilenumber.txt >> ${F_GPS}gps.txt
        fi

        # fi
        # Generate XY data for reference
        # gawk -v gpsscalefac=$VELSCALE '{ az=atan2($3, $4) * 180 / 3.14159265358979; if (az > 0) print $1, $2, az, sqrt($3*$3+$4*$4)*gpsscalefac; else print $1, $2, az+360, sqrt($3*$3+$4*$4)*gpsscalefac; }' ${USERGPSDATAFILE[$current_userlinefilenumber]} > ${F_GPS}extragps_${$current_usergpsfilenumber}.xy.txt

        current_usergpsfilenumber=$(echo "$current_usergpsfilenumber + 1" | bc -l)

        ;;

      euler)
        info_msg "Plotting Euler pole derived velocities"

        # Plots Euler Pole velocities as requested. Either on the XY spaced grid or at GPS points.
        # Requires polesextract.txt to be present.
        # Requires gridswap.txt if we are not plotting at GPS stations
        # eulergrid.txt needs to be in lat lon order
        # currently uses full global datasets?

        if [[ $euleratgpsflag -eq 1 ]]; then    # If we are looking at GPS data (-wg)
          if [[ $plotgps -eq 1 ]]; then         # If the GPS data are regional
                  echo herea

            cat $GPS_FILE | gawk  '{print $2, $1}' > ${F_PLATES}eulergrid.txt   # lon lat -> lat lon
            cat $GPS_FILE > ${F_GPS}gps.obs
          fi
          if [[ $tdefnodeflag -eq 1 ]]; then    # If the GPS data are from a TDEFNODE model
            gawk '{ if ($5==1 && $6==1) print $8, $9, $12, $17, $15, $20, $27, $1 }' ${TDPATH}${TDMODEL}.vsum > ${TDMODEL}.obs   # lon lat order
            gawk '{ if ($5==1 && $6==1) print $9, $8 }' ${TDPATH}${TDMODEL}.vsum > ${F_PLATES}eulergrid.txt  # lat lon order
            cat ${TDMODEL}.obs > ${F_GPS}gps.obs
          fi
        else
          cp gridswap.txt ${F_PLATES}eulergrid.txt  # lat lon order
        fi

        if [[ $eulervecflag -eq 1 ]]; then   # If we specified our own Euler Pole on the command line
          # gawk -f $EULERVEC_AWK -v eLat_d1=$eulerlat -v eLon_d1=$eulerlon -v eV1=$euleromega -v eLat_d2=0 -v eLon_d2=0 -v eV2=0 ${F_PLATES}eulergrid.txt > ${F_PLATES}gridvelocities.txt

          gawk '
            @include "tectoplot_functions.awk" 
            NF {
              eulervec('${eulerlat}', '${eulerlon}', '${euleromega}', 0, 0, 0, $2, $1)
              print eulervec_E, eulervec_N 
            }
          ' ${F_PLATES}eulergrid.txt > ${F_PLATES}gridvelocities.txt
        
        fi
        if [[ $twoeulerflag -eq 1 ]]; then   # If we specified two plates (moving plate vs ref plate) via command line

          # Search for the first line with the plate ID (plates are in ID_N format at this point)
          EPOLE1=($(grep "^${eulerplate1}_*[0-9]*\s" < ${F_PLATES}polesextract.txt | head -n 1))
          EPOLE2=($(grep "^${eulerplate2}_*[0-9]*\s" < ${F_PLATES}polesextract.txt | head -n 1))

          lat1=${EPOLE1[1]}
          lon1=${EPOLE1[2]}
          rate1=${EPOLE1[3]}
          lat2=${EPOLE2[1]}
          lon2=${EPOLE2[2]}
          rate2=${EPOLE2[3]}

          # echo EPOLE1=${EPOLE1[@]} EPOLE2=${EPOLE2[@]}
          #
          # lat1=`grep "^$eulerplate1\s" < ${F_PLATES}polesextract.txt | gawk  '{print $2}'`
        	# lon1=`grep "^$eulerplate1\s" < ${F_PLATES}polesextract.txt | gawk  '{print $3}'`
        	# rate1=`grep "^$eulerplate1\s" < ${F_PLATES}polesextract.txt | gawk  '{print $4}'`
          #
          # lat2=`grep "^$eulerplate2\s" < ${F_PLATES}polesextract.txt | gawk  '{print $2}'`
        	# lon2=`grep "^$eulerplate2\s" < ${F_PLATES}polesextract.txt | gawk  '{print $3}'`
        	# rate2=`grep "^$eulerplate2\s" < ${F_PLATES}polesextract.txt | gawk  '{print $4}'`

          [[ $narrateflag -eq 1 ]] && info_msg "Plotting velocities of $eulerplate1 [ $lat1 $lon1 $rate1 ] relative to $eulerplate2 [ $lat2 $lon2 $rate2 ]"
          # Should add some sanity checks here?
          echo here
          # gawk -f $EULERVEC_AWK -v eLat_d1=$lat1 -v eLon_d1=$lon1 -v eV1=$rate1 -v eLat_d2=$lat2 -v eLon_d2=$lon2 -v eV2=$rate2 ${F_PLATES}eulergrid.txt > ${F_PLATES}gridvelocities.txt

          gawk '
            @include "tectoplot_functions.awk" 
            NF {
              eulervec('${lat1}', '${lon1}', '${rate1}', '${lat2}', '${lon2}', '${rate2}', $2, $1)
              print eulervec_E, eulervec_N 
            }
          ' ${F_PLATES}eulergrid.txt > ${F_PLATES}gridvelocities.txt

        fi

        # If we are plotting only the residuals of GPS velocities vs. estimated site velocity from Euler pole (gridvelocities.txt)
        if [[ $ploteulerobsresflag -eq 1 ]]; then
           info_msg "plotting residuals of block motion and gps velocities"
           paste ${F_GPS}gps.obs ${F_PLATES}gridvelocities.txt | gawk  '{print $1, $2, $10-$3, $11-$4, 0, 0, 1, $8 }' > gpsblockres.txt   # lon lat order, mm/yr
           # Scale at print is OK
           gawk -v gpsscalefac=$(echo "$VELSCALE * $WRESSCALE" | bc -l) '{ az=atan2($3, $4) * 180 / 3.14159265358979; if (az > 0) print $1, $2, az, sqrt($3*$3+$4*$4)*gpsscalefac; else print $1, $2, az+360, sqrt($3*$3+$4*$4)*gpsscalefac; }' gpsblockres.txt > grideulerres.pvec
           gmt psxy -SV$ARROWFMT -W0p,green -Ggreen grideulerres.pvec $RJOK $VERBOSE >> map.ps  # Plot the residuals
        fi

        paste -d ' ' ${F_PLATES}eulergrid.txt ${F_PLATES}gridvelocities.txt | gawk  '{print $2, $1, $3, $4, 0, 0, 1, "ID"}' > ${F_PLATES}gridplatevecs.txt

        # gridplatevecs: field2 from eulergrid, field1 from eulergrid, field 1 and 2 from gridvelocities

        # Calculate the azimuth and the velocity of each point from the VE/VN data
        # atan2(x,y) -> atan2(E,N) -> North clockwise azimuth
        cat ${F_PLATES}gridplatevecs.txt | gawk -v gpsscalefac=$VELSCALE '{ az=atan2($3, $4) * 180 / 3.14159265358979; if (az > 0) print $1, $2, az, sqrt($3*$3+$4*$4)*gpsscalefac; else print $1, $2, az+360, sqrt($3*$3+$4*$4)*gpsscalefac; }'  > ${F_PLATES}grideuler.pvec

        gmt psxy -SV$ARROWFMT -W0p,${EULER_VEC_LINECOLOR} -G${EULER_VEC_FILLCOLOR} ${F_PLATES}grideuler.pvec $RJOK $VERBOSE >> map.ps
        ;;
      eqtime)
        # Nothing. Placeholder for legend.
        ;;

      selected-flinn-engdahl)
        gmt psxy fe_region.txt -W1p,red $RJOK $VERBOSE >> map.ps
        ;;

      flinn-engdahl)
        case $FE_TYPE in
          region)
            gmt psxy ${FE_REGION_ZONES} -W1p,red $RJOK $VERBOSE >> map.ps
            gmt pstext ${FE_REGION_LABELS}  -Gwhite -F+f+a+j -W0.25p,black $RJOK $VERBOSE >> map.ps

          ;;
          seismic)
            gmt psxy ${FE_SEISMIC_ZONES} -W1p,red $RJOK $VERBOSE >> map.ps
            gmt pstext ${FE_SEISMIC_LABELS} -Gwhite -F+f+a+j -W0.25p,black $RJOK $VERBOSE >> map.ps

          ;;

        esac
        ;;

      gebcotid)
        gmt makecpt -Fr -Ccategorical -T1/100/1 ${VERBOSE} > ${F_CPTS}gebco_tid.cpt
        gmt grdimage $GEBCO20_TID $GRID_PRINT_RES -t50 -C${F_CPTS}gebco_tid.cpt $RJOK $VERBOSE >> map.ps

        ;;
      gemfaults)
        info_msg "Plotting GEM active faults"
        echo "GEM" >> ${SHORTSOURCES}
        gmt psxy $GEMFAULTS -W$AFLINEWIDTH,$AFLINECOLOR $RJOK $VERBOSE >> map.ps
        ;;

      gps)
        info_msg "Plotting GPS"

        # Select by polygon if specified
        if [[ -s ${POLYGONAOI} ]]; then
          gmt select $GPS_FILE -F${POLYGONAOI} -Vn | tr '\t' ' ' > ${F_GPS}gps_aoi.txt
          GPS_FILE=${F_GPS}gps_aoi.txt
        fi
  		  ##### Plot GPS velocities if possible (requires Kreemer plate to have same ID as model reference plate, or manual specification)
        if [[ $tdefnodeflag -eq 0 ]]; then
    			if [[ -e $GPS_FILE ]]; then
    				info_msg "GPS data is taken from $GPS_FILE and are plotted relative to plate $REFPLATE in that model"

            if [[ $(echo "$GPS_MINSIG > 0" | bc) -eq 1 ]]; then
              gmt select $GPS_FILE -R -fg | gawk -v minsig=${GPS_MINSIG} '
                {
                  $5 = ($5 < minsig ? minsig : $5)
                  $6 = ($6 < minsig ? minsig : $6)
                  print $0
                }' > ${F_GPS}gps.txt
            else
              gmt select $GPS_FILE -R -fg > ${F_GPS}gps.txt
            fi

            gawk '{ az=atan2($3, $4) * 180 / 3.14159265358979; if (az > 0) print $1, $2, az, sqrt($3*$3+$4*$4); else print $1, $2, az+360, sqrt($3*$3+$4*$4); }' < ${F_GPS}gps.txt > ${F_GPS}gps.xy
            GPSMAXVEL=$(gawk < ${F_GPS}gps.xy 'BEGIN{ maxv=0 } {if ($4>maxv) { maxv=$4 } } END {print maxv}')

            if [[ $GPS_NOPLOT -ne 1 ]]; then

    				  gmt psvelo ${F_GPS}gps.txt -W${GPS_LINEWIDTH},${GPS_LINECOLOR} -G${GPS_FILLCOLOR} -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 -L $RJOK $VERBOSE >> map.ps 2>/dev/null

              if [[ $gpstextflag -eq 1 ]]; then
                gawk < ${F_GPS}gps.xy '{printf("%s %s %.1f\n", $1, $2, $4)}' | gmt pstext -Dj2p -F+f${gpsfontsize}p,Helvetica,black+jBL ${RJOK} >> map.ps
              fi
            fi
          else
    				info_msg "No relevant GPS data available for given plate model ($GPS_FILE)"
    				GPS_FILE="None"
    			fi
        fi
  			;;

      gps_gg)

      if [[ -s ${F_GPS}gps.txt ]]; then

        gawk < ${F_GPS}gps.txt '
          {
            seen[$1,$2]++
            if(seen[$1,$2]==1) {
              if (NF<5) {
                $5=0
                $6=0
                $7=0
              }
              print $1, $2, $3, $4, $5, $6, $7
            }
          }' > ${F_GPS}gps_init.txt

        gmt_init_tmpdir

        # Use blockmean to avoid aliasing
        gmt blockmean -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} -I1m ${F_GPS}gps_init.txt -fg -i0,1,2,4 -W ${VERBOSE} > blk.llu
        gmt blockmean -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} -I1m ${F_GPS}gps_init.txt -fg -i0,1,3,5 -W ${VERBOSE} > blk.llv
        gmt convert -A blk.llu blk.llv -o0-2,6,3,7 > ${F_GPS}gps_cull.txt

        # cp ${F_GPS}gps_init.txt ${F_GPS}gps_cull.txt

        num_eigs=$(wc -l < ${F_GPS}gps_cull.txt | gawk '{print $1/2}')

        gmt gpsgridder ${F_GPS}gps_cull.txt -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} -Cn$num_eigs+eigen.txt -S${GPS_GG_VAL} -I${GPS_GG_RES} -Fd4 -fg -W -r -G${F_GPS}gps_strain_%s.nc ${VERBOSE}

        # The following code is from Hackl et al., 2009; it generates various strain rate grids

        crosssize=0.0001					# scaling factor for direction of max shear strain
        orderofmagnitude=1000000	# scaling factor for colorbar of strain rate magnitude

        # ---------------------------------------------------
        # calculate velo gradient
        #-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        gmt grdgradient ${F_GPS}gps_strain_u.nc -Gtmp.grd -A270 ${VERBOSE} -M
        gmt grdmath ${VERBOSE} tmp.grd $orderofmagnitude MUL = e_e.grd
        gmt grdgradient ${F_GPS}gps_strain_u.nc -Gtmp.grd -A180 ${VERBOSE} -M
        gmt grdmath ${VERBOSE} tmp.grd $orderofmagnitude MUL = e_n.grd
        gmt grdgradient ${F_GPS}gps_strain_v.nc -Gtmp.grd -A270 ${VERBOSE} -M
        gmt grdmath ${VERBOSE} tmp.grd $orderofmagnitude MUL = n_e.grd
        gmt grdgradient ${F_GPS}gps_strain_v.nc -Gtmp.grd -A180 ${VERBOSE} -M
        gmt grdmath ${VERBOSE} tmp.grd $orderofmagnitude MUL = n_n.grd

        # i,j component of strain tensor (mean of e_n and n_e component):
        gmt grdmath ${VERBOSE} e_n.grd n_e.grd ADD 0.5 MUL = mean_e_n.grd

        # second invariant of strain rate tensor is
        # ell = (exx^2 + eyy^2 + 2*exy^2)^(1/2)
        gmt grdmath ${VERBOSE} e_e.grd SQR n_n.grd SQR ADD mean_e_n.grd SQR 2 MUL ADD SQRT = second_inv.grd

        #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        # calc eigenvalues, max shear strain rate, and dilatational strain rate
        #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        gmt grdmath ${VERBOSE} e_e.grd n_n.grd ADD e_e.grd n_n.grd SUB 2 POW mean_e_n.grd 2 POW 4 MUL ADD SQRT ADD 2 DIV = lambda1.grd
        gmt grdmath ${VERBOSE} e_e.grd n_n.grd ADD e_e.grd n_n.grd SUB 2 POW mean_e_n.grd 2 POW 4 MUL ADD SQRT SUB 2 DIV = lambda2.grd
        gmt grdmath ${VERBOSE} lambda1.grd lambda2.grd SUB 2 DIV = max_shear.grd

        gmt grdmath ${VERBOSE} lambda1.grd lambda2.grd ADD = str_dilatational.grd

        #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        # calc strain crosses
        #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

        gmt grdmath ${VERBOSE} 90 0.5 2 mean_e_n.grd MUL e_e.grd n_n.grd SUB DIV 1 ATAN2 MUL 180 MUL 3.14 DIV SUB 45 ADD = phi1.grd
        gmt grdmath ${VERBOSE} 90 lambda2.grd e_e.grd SUB mean_e_n.grd DIV 1 ATAN2 180 MUL 3.14 DIV SUB = phi2.grd

        if [[ $GG_SUBSAMPLE -eq 1 ]]; then

          GG_SUBSAMPLE_VAL=$(echo "$GPS_GG_RES $GG_SUBSAMPLE_NUM ${GPS_GG_RES: -1}" | gawk '{print (($1+0)*$2) $3}')

          echo subsampling crosses to ${GG_SUBSAMPLE_VAL}

          gmt grdsample max_shear.grd -I${GG_SUBSAMPLE_VAL}/${GG_SUBSAMPLE_VAL} -Gmax_shear_resample.grd ${VERBOSE}
          gmt grdsample lambda1.grd -I${GG_SUBSAMPLE_VAL}/${GG_SUBSAMPLE_VAL} -Glambda1_resample.grd ${VERBOSE}
          gmt grdsample lambda2.grd -I${GG_SUBSAMPLE_VAL}/${GG_SUBSAMPLE_VAL} -Glambda2_resample.grd ${VERBOSE}
          gmt grdsample phi1.grd -I${GG_SUBSAMPLE_VAL}/${GG_SUBSAMPLE_VAL} -Gphi1_resample.grd ${VERBOSE}
          gmt grdsample phi2.grd -I${GG_SUBSAMPLE_VAL}/${GG_SUBSAMPLE_VAL} -Gphi2_resample.grd ${VERBOSE}

          gmt grd2xyz max_shear_resample.grd > max_shear.xyz
          gmt grd2xyz phi1_resample.grd > phi1.xyz
          gmt grd2xyz phi2_resample.grd > phi2.xyz
          gmt grd2xyz lambda1_resample.grd > lambda1.xyz
          gmt grd2xyz lambda2_resample.grd > lambda2.xyz


        else

          gmt grd2xyz max_shear.grd > max_shear.xyz
          gmt grd2xyz phi1.grd > phi1.xyz
          gmt grd2xyz phi2.grd > phi2.xyz
          gmt grd2xyz lambda1.grd > lambda1.xyz
          gmt grd2xyz lambda2.grd > lambda2.xyz

        fi


        paste lambda1.xyz lambda2.xyz phi2.xyz | gawk '{print($1, $2, $3/100, $6/100, $9)}'  > phi_shear.xyl1l2p

        # paste max_shear.xyz phi1.xyz | awk '{print($1, $2, $3, $6)}'  > phi_shear.xysp
        # 	gawk '
        # 		function acos(x) { return atan2((1.-x^2)^0.5,x) }
        # 		function asin(x) { return atan2(x,(1.-x^2)^0.5) }
        # 		{
        # 		    pi = atan2(0,-1)
        #         lat = $2
        #         lon = $1
        #         alpha = $4*pi/180
        #         a = $3*'${crosssize}';
        # 		    lat_right = 90 - acos(cos(a)*cos((90 - lat)*pi/180) + sin(a)*sin((90 - lat)*pi/180)*cos(alpha)) *180/pi
        # 		    lon_right = lon + asin(sin(a)/sin((90-lat_right)*pi/180) * sin(alpha)) * 180/pi
        # 		    lat_left = 90 - acos(cos(a)*cos((90 - lat)*pi/180) + sin(a)*sin((90 - lat)*pi/180)*cos(alpha-pi)) *180/pi
        # 		    lon_left = lon - asin(sin(a)/sin((90-lat_right)*pi/180) * sin(alpha)) * 180/pi
        #     }
        # 		{
        #       printf ("> -Z%.2f\n %9.5f %9.5f \n %9.5f %9.5f \n %9.5f %9.5f \n", a, lon_left, lat_left, lon, lat, lon_right, lat_right)
        #     }' phi_shear.xysp > dir1
        # 	gawk '
        # 		function acos(x) { return atan2((1.-x^2)^0.5,x) }
        # 		function asin(x) { return atan2(x,(1.-x^2)^0.5) }
        # 		{
        # 		    pi = atan2(0,-1)
        #         lat = $2; lon = $1
        #         alpha = $4*pi/180+pi/2
        #         a = $3*'${crosssize}'
        # 		    lat_right = 90 - acos(cos(a)*cos((90 - lat)*pi/180) + sin(a)*sin((90 - lat)*pi/180)*cos(alpha)) *180/pi
        # 		    lon_right = lon + asin(sin(a)/sin((90-lat_right)*pi/180) * sin(alpha)) * 180/pi
        # 		    lat_left = 90 - acos(cos(a)*cos((90 - lat)*pi/180) + sin(a)*sin((90 - lat)*pi/180)*cos(alpha-pi)) *180/pi
        # 		    lon_left = lon - asin(sin(a)/sin((90-lat_right)*pi/180) * sin(alpha)) * 180/pi;
        #     }
        # 		{
        #         printf ("> -Z%.2f\n %9.5f %9.5f \n %9.5f %9.5f \n %9.5f %9.5f \n", a, lon_left, lat_left, lon, lat, lon_right, lat_right)
        #     }' phi_shear.xysp > dir2
        #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        # calc rotational strain rate
        #------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
        gmt grdmath ${VERBOSE} n_e.grd e_n.grd SUB 0.5 MUL = omega.grd

        gmt_remove_tmpdir

        # gmt psxy dir1 -W2p,black ${RJOK} ${VERBOSE} >> map.ps
        # gmt psxy dir2 -W2p,red ${RJOK} ${VERBOSE} >> map.ps


        if [[ $GG_PLOT_ROT -eq 1 ]]; then
          gmt grdimage omega.grd -Ccyclic ${RJOK} ${VERBOSE} >> map.ps
        fi
        if [[ $GG_PLOT_STR_DIL -eq 1 ]]; then
          gmt grdimage str_dilatational.grd -Cturbo ${RJOK} ${VERBOSE} >> map.ps
        fi

        if [[ $GG_PLOT_MAX_SHEAR -eq 1 ]]; then
          gmt makecpt -Fr -T0/300/0.1 -Z -Cjet > shear.cpt
          gmt grdimage max_shear.grd -t50 -Q -Cjet ${RJOK} ${VERBOSE} >> map.ps
        fi

        if [[ $GG_PLOT_2INV -eq 1 ]]; then
          gmt makecpt -Fr -T1/2000/1+l -Q -Z -D -Cjet > ${F_CPTS}secinv.cpt
          gmt grdimage second_inv.grd -t50 -Q -C${F_CPTS}secinv.cpt ${RJOK} ${VERBOSE} >> map.ps
          legendbarwords+=("secinv")
        fi

        # Plot strain crosses

        if [[ $GG_PLOT_CROSS -eq 1 ]]; then
          gmt psvelo phi_shear.xyl1l2p -Sx0.15i -W0.2p,black -Gblack ${RJOK} ${VERBOSE} >> map.ps
        fi


        # Plot velocity arrows

        if [[ -s ${F_GPS}gps_strain_u.nc && -s ${F_GPS}gps_strain_v.nc ]]; then

          gmt_init_tmpdir

          gmt grdmath ${F_GPS}gps_strain_u.nc SQR ${F_GPS}gps_strain_v.nc SQR ADD SQRT = ${F_GPS}gps_vel.nc
          # gmt grdimage ${F_GPS}gps_vel.nc -Cturbo ${RJOK} ${VERBOSE} >> map.ps

          # Recover the GPS velocity components
          gmt grd2xyz ${F_GPS}gps_strain_u.nc > ${F_GPS}gps_strain_u.txt
          gmt grd2xyz ${F_GPS}gps_strain_v.nc | gawk '{print $3, 0, 0, 0}' > ${F_GPS}gps_strain_v.txt

          if [[ $GG_SUBSAMPLE -eq 1 ]]; then

            GG_SUBSAMPLE_VAL=$(echo "$GPS_GG_RES $GG_SUBSAMPLE_NUM ${GPS_GG_RES: -1}" | gawk '{print (($1+0)*$2) $3}')

            echo subsampling to ${GG_SUBSAMPLE_VAL}

            gmt grdsample ${F_GPS}gps_strain_u.nc -I${GG_SUBSAMPLE_VAL}/${GG_SUBSAMPLE_VAL} -G${F_GPS}gps_strain_u_resample.nc ${VERBOSE}
            gmt grdsample ${F_GPS}gps_strain_v.nc -I${GG_SUBSAMPLE_VAL}/${GG_SUBSAMPLE_VAL} -G${F_GPS}gps_strain_v_resample.nc ${VERBOSE}
            gmt grd2xyz ${F_GPS}gps_strain_u_resample.nc > ${F_GPS}gps_strain_u_resample.txt
            gmt grd2xyz ${F_GPS}gps_strain_v_resample.nc > ${F_GPS}gps_strain_v_resample.txt

            paste ${F_GPS}gps_strain_u_resample.txt ${F_GPS}gps_strain_v_resample.txt | gawk '{print $1, $2, $3, $6, 0, 0, 0} '> ${F_GPS}gps_strain.txt

            # gmt blockmean ${F_GPS}gps_cull.txt -Sn -R${F_GPS}gps_strain_v_resample.nc -C -E -fg | gawk '{print $1, $2, $3}' > ${F_GPS}gps_ptnum.txt
            gmt xyz2grd ${F_GPS}gps_cull.txt -R${F_GPS}gps_strain_v_resample.nc -An -G${F_GPS}gps_number.nc

          else
            paste ${F_GPS}gps_strain_u.txt ${F_GPS}gps_strain_v.txt > ${F_GPS}gps_strain.txt

            # Get the number of GPS velocities within each cell
            # gmt blockmean ${F_GPS}gps_cull.txt -Sn -R${F_GPS}gps_strain_v.nc -C -E -fg | gawk '{print $1, $2, $3}' > ${F_GPS}gps_ptnum.txt
            gmt xyz2grd ${F_GPS}gps_cull.txt -R${F_GPS}gps_strain_v.nc -An -G${F_GPS}gps_number.nc
          fi

          gmt grdtrack ${F_GPS}gps_strain.txt -G${F_GPS}gps_number.nc -Z -N | gawk '
            {
              if ($1=="NaN") {
                $1=0
              }
              printf("%.0f\n", $1)
            } '> ${F_GPS}near_num.txt

          paste ${F_GPS}near_num.txt ${F_GPS}gps_strain.txt | gawk '
            {
              if ($1>1) {
                $1=""
                print $0 > "./gps_g_withdata.txt"
              } else if ($1==1){
                $1=""
                print $0 > "./gps_g_withonedata.txt"
              } else {
                $1=""
                print $0 > "./gps_g_withoutdata.txt"
              }
            }'

          mv gps_g_* ${F_GPS}

          gmt_remove_tmpdir

          if [[ $GG_NO_AVE -ne 1 ]]; then
            [[ -s ${F_GPS}gps_g_withdata.txt ]] && gmt psvelo ${F_GPS}gps_g_withdata.txt -W${GPS_LINEWIDTH},${GPS_LINECOLOR} -Gblack -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 -L $RJOK $VERBOSE >> map.ps
            [[ -s ${F_GPS}gps_g_withonedata.txt ]] && gmt psvelo ${F_GPS}gps_g_withonedata.txt -W${GPS_LINEWIDTH},${GPS_LINECOLOR} -Ggray -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 -L $RJOK $VERBOSE >> map.ps

            if [[ $GG_NO_AVE_0 -ne 1 ]]; then
              [[ -s ${F_GPS}gps_g_withoutdata.txt ]] && gmt psvelo ${F_GPS}gps_g_withoutdata.txt -W${GPS_LINEWIDTH},${GPS_LINECOLOR} -Gwhite -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 -L $RJOK $VERBOSE >> map.ps
            fi
          fi
          # gmt grdvector -Ix10/10 ${F_GPS}gps_strain_u.nc ${F_GPS}gps_strain_v.nc ${RJOK} ${VERBOSE} -Q0.03i+e -Gblue -W.4,blue -S120i --MAP_VECTOR_SHAPE=0.2  >> map.ps
        fi

        if [[ $GG_PLOT_RESIDUALS -eq 1 ]]; then
          # Calculate and plot the residuals
          gmt grdtrack ${F_GPS}gps_cull.txt -G${F_GPS}gps_strain_u.nc -G${F_GPS}gps_strain_v.nc -Z > ${F_GPS}gps_extract.txt
          paste ${F_GPS}gps_cull.txt ${F_GPS}gps_extract.txt | gawk '{ print $1, $2, $3-$8, $4-$9, 0, 0, 0}' > ${F_GPS}gps_g_residual.txt

          if [[ -s ${F_GPS}gps_g_residual.txt ]]; then
            gmt psvelo ${F_GPS}gps_g_residual.txt -W${GPS_LINEWIDTH},${GPS_LINECOLOR} -Ggreen -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 -L $RJOK $VERBOSE >> map.ps
          fi
        fi
      fi
        ;;

      graticule_grid)
        gmt psbasemap -Bxg${GRIDSP} -Byg${GRIDSP} -t${GRIDLINE_TRANS} -Btlbr --MAP_GRID_PEN_PRIMARY=${GRIDLINE_WIDTH},${GRIDLINE_COLOR} --MAP_FRAME_PEN=0p $RJOK $VERBOSE >> map.ps
        ;;

      graticule)

        if [[ ${overridegridlinespacing} -eq 1 ]]; then
          OLD_FORMAT_FLOAT_OUT=$(gmt gmtget FORMAT_FLOAT_OUT -Vn)
          gmt gmtset FORMAT_FLOAT_OUT ${MAP_FORMAT_FLOAT_OUT}
        fi

        if [[ $graticulefontflag -eq 1 ]]; then
          gmt gmtset FONT_ANNOT_PRIMARY ${graticulefont}
        fi

        mapfont=($(gmt gmtget FONT_ANNOT_PRIMARY | tr ',' '\n'))

        whitegraticuleflag=1
        if [[ $whitegraticuleflag -eq 1 ]]; then
          gmt psbasemap "${BSTRING[@]}" ${OBFRAMECMD} ${RJSTRING} -O -K $VERBOSE --FONT_ANNOT_PRIMARY=${mapfont[0]},${mapfont[1]},white=${whitegraticulewidth},white --FORMAT_FLOAT_OUT=${MAP_FORMAT_FLOAT_OUT} --FORMAT_FLOAT_MAP=${MAP_FORMAT_FLOAT_OUT} --FORMAT_GEO_OUT=D --FORMAT_GEO_MAP=D  ${GRATOPTS} >> map.ps
        fi
        gmt psbasemap "${BSTRING[@]}" ${OBFRAMECMD} ${RJSTRING} -O -K $VERBOSE --FORMAT_FLOAT_OUT=${MAP_FORMAT_FLOAT_OUT} --FORMAT_FLOAT_MAP=${MAP_FORMAT_FLOAT_OUT} --FORMAT_GEO_OUT=D --FORMAT_GEO_MAP=D ${GRATOPTS} >> map.ps
        if [[ ${overridegridlinespacing} -eq 1 ]]; then
          gmt gmtset FORMAT_FLOAT_OUT ${OLD_FORMAT_FLOAT_OUT}
        fi

    #  gmt psbasemap "${BSTRING[@]}" ${SCALECMD} $RJOK $VERBOSE >> map.ps
        ;;

      grav)
        gmt grdimage $GRAVDATA $GRID_PRINT_RES ${GRAVGRAD} -C$GRAV_CPT -t$GRAVTRANS $RJOK $VERBOSE >> map.ps
        ;;

      gravcurv)
        gmt grdimage $SANDWELLFREEAIR_CURV $GRID_PRINT_RES -C$GRAV_CURV_CPT -t$GRAVTRANS $RJOK $VERBOSE >> map.ps
        ;;

  #### CHECK CAREFULLY
      grid)
        # Plot the gridded plate velocity field
        # Requires *_platevecs.txt to plot velocity field
        # Input data are in mm/yr
        info_msg "Plotting grid arrows"

        # For stereo plots with a horizon, londiff can actually be way too large!

        LONDIFF=$(echo "$MAXLON - $MINLON" | bc -l)
        pwnum=$(echo "5p" | gawk  '{print $1+0}')
        POFFS=$(echo "$LONDIFF/8*1/72*$pwnum*3/2" | bc -l)
        GRIDMAXVEL=0

  # Works with ${F_PLATES}?
        if [[ $plotplates -eq 1 ]]; then
          for i in ${F_PLATES}*_platevecs.txt; do
            # Use azimuth/velocity data in platevecs.txt to infer VN/VE
            gawk < $i '{ az=atan2($3, $4) * 180 / 3.14159265358979; if (az > 0) print $1, $2, az, sqrt($3*$3+$4*$4); else print $1, $2, az+360, sqrt($3*$3+$4*$4); }' > ${i}.pvec
            GRIDMAXVEL=$(gawk < ${i}.pvec -v prevmax=$GRIDMAXVEL 'BEGIN {max=prevmax} {if ($4 > max) {max=$4} } END {print max}' )
            gmt psvelo ${i} -W0p,$PLATEVEC_COLOR@$PLATEVEC_TRANS -G$PLATEVEC_COLOR@$PLATEVEC_TRANS -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 -L $RJOK $VERBOSE >> map.ps 2>/dev/null            
            [[ $PLATEVEC_TEXT_PLOT -eq 1 ]] && gawk  < ${i}.pvec -v poff=$POFFS '($4 != 0) { print $1 - sin($3*3.14159265358979/180)*poff, $2 - cos($3*3.14159265358979/180)*poff, sprintf("%d", $4) }' | gmt pstext -F+f${PLATEVEC_TEXT_SIZE},${PLATEVEC_TEXT_FONT},${PLATEVEC_TEXT_COLOR}+jCM $RJOK $VERBOSE  >> map.ps
          done
        fi
        ;;

      gridpoints)
        [[ -s gridfile.txt ]] && gmt psxy gridfile.txt -Sc0.05i -Gblack $RJOK $VERBOSE >> map.ps
        ;;


      inset)

          if [[ $insetprojflag -ne 1 ]]; then
            INSET_PROJSTRING="-RJ G ${CENTERLON} ${CENTERLAT} ${INSET_DEGWIDTH}"
          else
            INSET_PROJSTRING="${INSET_PROJ}"
          fi

          info_msg "[-inset]: tectoplot ${INSET_PROJSTRING} -f ${CENTERLON} ${CENTERLAT} -keepopenps ${INSET_ARGS} -li mapelements/bounds.txt stroke ${INSET_LINE_WIDTH},${INSET_LINE_COLOR}  -tm insetmap ${MEGADEBUGFLAG} ${DEBUGFLAG}"

          # Open a new shell and create a new directory to avoid contaminating the current tectoplot 
          # folder with different GMT settings that might arise from plotting (e.g. grid spacing)
          (
            mkdir insetmap_tmp/
            cd insetmap_tmp/
            tectoplot ${INSET_PROJSTRING} -f ${CENTERLON} ${CENTERLAT} -keepopenps ${INSET_ARGS} -li ../mapelements/bounds.txt stroke ${INSET_LINE_WIDTH},${INSET_LINE_COLOR} -tm insetmap ${MEGADEBUGFLAG} ${DEBUGFLAG}
            cd ..
            mv insetmap_tmp/insetmap/* insetmap_tmp/
            rmdir insetmap_tmp/insetmap/
            mv insetmap_tmp insetmap
          )

          # Close the inset PS file
          gmt psxy -T -O >> insetmap/map.ps

          PS_DIM=$(gmt psconvert insetmap/map.ps -TG -E700 -Finset -A+m0.01i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
          INSET_PS_WIDTH="$(echo $PS_DIM | gawk '{print $1/2.54}')"
          INSET_PS_HEIGHT="$(echo $PS_DIM | gawk '{print $2/2.54}')"

          if [[ $insetplacedflag -eq 1 ]]; then
            thisJ=""
            if [[ ${INSET_ONOFFCODE} == "J" ]]; then
              # Place outside the map frame
              case ${INSET_JUST_CODE} in
                TL) shifth=0;   shiftv=${INSET_DV}; thisJ="+jBL";; # top edge, left side
                TM) INSET_JUST_CODE="TC"
                    shifth=0;   shiftv=${INSET_DV}; thisJ="+jBC";; # top edge, middle
                TR) shifth=0;   shiftv=${INSET_DV}; thisJ="+jBR";; # top edge, right side

                BL) shifth=0;   shiftv=${INSET_DV}; thisJ="+jTL";; # bottom edge, left
                BM) INSET_JUST_CODE="BC"
                    shifth=0;   shiftv=${INSET_DV}; thisJ="+jTC";; # bottom edge, center
                BR) shifth=0;   shiftv=${INSET_DV}; thisJ="+jTR";; # bottom edge, right

                RT) shifth=${INSET_DH};  shiftv=0;  thisJ="+jTL";; # right edge, top
                RM) INSET_JUST_CODE="CR"
                    shifth=${INSET_DH};  shiftv=0;  thisJ="+jML";; # right edge, center
                RB) shifth=${INSET_DH};  shiftv=0;  thisJ="+jBL";; # right edge, bottom

                LT) shifth=${INSET_DH};  shiftv=0;  thisJ="+jTR";;  # left edge, top
                LM) INSET_JUST_CODE="CL"
                    shifth=${INSET_DH};  shiftv=0;  thisJ="+jMR";;  # left edge, center
                LB) shifth=${INSET_DH};  shiftv=0;  thisJ="+jBR";; # left edge, bottom

                UL) INSET_JUST_CODE="TL"
                    shifth=${INSET_DH};  shiftv=${INSET_DV}; thisJ="+jBR";;
                UR) INSET_JUST_CODE="UR"
                    shifth=${INSET_DH};  shiftv=${INSET_DV}; thisJ="+jBL";;
                LL) INSET_JUST_CODE="BL"
                    shifth=${INSET_DH};  shiftv=${INSET_DV}; thisJ="+jTR";;
                LR) INSET_JUST_CODE="BR"
                    shifth=${INSET_DH};  shiftv=${INSET_DV}; thisJ="+jTL";;

                *)
                  echo "Outside justification ${INSET_JUST_CODE} not recognized. Using TL."
                  INSET_JUST_CODE="TL"
                  shifth=0;   shiftv=30;   thisJ="+jBL"  # top edge, left side
                ;;
              esac
            else
              # Place inside the map frame
              case ${INSET_JUST_CODE} in
                TR|RT) shifth=${INSET_DH};  shiftv=${INSET_DV}  ;;
                CR|RC) INSET_JUST_CODE="CR"
                       shifth=${INSET_DH};  shiftv=0   ;;
                BR|RB) shifth=${INSET_DH};  shiftv=${INSET_DV}  ;;
                TM|MT) INSET_JUST_CODE="CT"
                       shifth=0;   shiftv=${INSET_DV}  ;;
                CM|MC)  INSET_JUST_CODE="CM"
                       shifth=0;   shiftv=0   ;;
                BM|MB) INSET_JUST_CODE="CB"
                       shifth=0;   shiftv=${INSET_DV}  ;;
                TL|LT) shifth=${INSET_DH};  shiftv=${INSET_DV}  ;;
                CL|LC) INSET_JUST_CODE="LC"
                       shifth=${INSET_DH};  shiftv=0   ;;
                BL|LB) shifth=${INSET_DH};  shiftv=${INSET_DV}  ;;
                *)
                echo "Inside justification ${INSET_JUST_CODE} not recognized. Using BL"
                  INSET_JUST_CODE="BL"; shifth=${INSET_DH};  shiftv=${INSET_DV}
                ;;
              esac
            fi

            if [[ $(echo "${shifth} == 0 && ${shiftv} == 0" | bc -l) -eq 1 ]]; then
              shifth=0.01
              shiftv=0.01
            fi

            gmt psimage -D${INSET_ONOFFCODE}${INSET_JUST_CODE}+o${shifth}p/${shiftv}p+w${INSET_SIZE}i/0${thisJ} inset.png ${INSET_FILL} ${RJSTRING} -Xa${INSET_XOFF} -Ya${INSET_YOFF} -O -K ${VERBOSE} >> map.ps
          fi

          ;;

      kinsv)
        # Plot the slip vectors for focal mechanism nodal planes
        info_msg "Plotting kinematic slip vectors; kinthrustflag=$kinthrustflag; kinnormalflag=$kinnormalflag; kinssflag=$kinssflag, NP1_COLOR=$NP1_COLOR, NP2_COLOR=$NP2_COLOR"

        if [[ $kinthrustflag -eq 1 ]]; then
          [[ $np1flag -eq 1 ]] && gmt psxy -SV0.1i+jb+e -W1p,${NP1_COLOR} -G${NP1_COLOR} ${F_KIN}thrust_gen_slip_vectors_np1.txt $RJOK $VERBOSE >> map.ps
          [[ $np2flag -eq 1 ]] && gmt psxy -SV0.1i+jb+e -W1p,${NP2_COLOR} -G${NP2_COLOR} ${F_KIN}thrust_gen_slip_vectors_np2.txt $RJOK $VERBOSE >> map.ps
        fi
        if [[ $kinnormalflag -eq 1 ]]; then
          [[ $np1flag -eq 1 ]] && gmt psxy -SV0.1i+jb+e -W1p,${NP1_COLOR} -G${NP1_COLOR} ${F_KIN}normal_slip_vectors_np1.txt $RJOK $VERBOSE >> map.ps
          [[ $np2flag -eq 1 ]] && gmt psxy -SV0.1i+jb+e -W1p,${NP2_COLOR} -G${NP2_COLOR} ${F_KIN}normal_slip_vectors_np2.txt $RJOK $VERBOSE >> map.ps
        fi
        if [[ $kinssflag -eq 1 ]]; then
          [[ $np1flag -eq 1 ]] && gmt psxy -SV0.1i+jb+e -W1p,${NP1_COLOR} -G${NP1_COLOR} ${F_KIN}strikeslip_slip_vectors_np1.txt $RJOK $VERBOSE >> map.ps
          [[ $np2flag -eq 1 ]] && gmt psxy -SV0.1i+jb+e -W1p,${NP2_COLOR} -G${NP2_COLOR} ${F_KIN}strikeslip_slip_vectors_np2.txt $RJOK $VERBOSE >> map.ps
        fi
        ;;

      kingeo)
        info_msg "Plotting kinematic data"
        # Currently only plotting strikes and dips of thrust mechanisms
        if [[ kinthrustflag -eq 1 ]]; then
          # Plot dip line of NP1
          [[ np1flag -eq 1 ]] && gmt psxy -SV0.05i+jb -W0.5p,${NP1_COLOR} -G${NP1_COLOR} ${F_KIN}thrust_gen_slip_vectors_np1_downdip.txt $RJOK $VERBOSE >> map.ps
          # Plot strike line of NP1
          [[ np1flag -eq 1 ]] && gmt psxy -SV0.05i+jc -W0.5p,${NP1_COLOR} -G${NP1_COLOR} ${F_KIN}thrust_gen_slip_vectors_np1_str.txt $RJOK $VERBOSE >> map.ps
          # Plot dip line of NP2
          [[ np2flag -eq 1 ]] && gmt psxy -SV0.05i+jb -W0.5p,${NP2_COLOR} -G${NP2_COLOR} ${F_KIN}thrust_gen_slip_vectors_np2_downdip.txt $RJOK $VERBOSE >> map.ps
          # Plot strike line of NP2
          [[ np2flag -eq 1 ]] && gmt psxy -SV0.05i+jc -W0.5p,${NP2_COLOR} -G${NP2_COLOR} ${F_KIN}thrust_gen_slip_vectors_np2_str.txt $RJOK $VERBOSE >> map.ps
        fi
        plottedkinsd=1
        ;;

      litho1_depth)
        # This is super slow and annoying.
        deginc=0.1
        rm -f litho1_${LITHO1_DEPTH}.xyz
        info_msg "Plotting LITHO1.0 depth slice (0.1 degree resolution) at depth=$LITHO1_DEPTH"
        for lat in $(seq $MINLAT $deginc $MAXLAT); do
          echo $MINLAT - $lat - $MAXLAT
          for lon in $(seq $MINLON $deginc $MAXLON); do
            ${LITHO1_PROG} -p $lat $lon -d $LITHO1_DEPTH  -l ${LITHO1_LEVEL} 2>/dev/null | gawk -v lat=$lat -v lon=$lon -v extfield=$LITHO1_FIELDNUM '{
              print lon, lat, $(extfield)
            }' >> litho1_${LITHO1_DEPTH}.xyz
          done
        done
        gmt_init_tmpdir
        gmt xyz2grd litho1_${LITHO1_DEPTH}.xyz -R$MINLON/$MAXLON/$MINLAT/$MAXLAT -fg -I${deginc}d -Glitho1_${LITHO1_DEPTH}.nc $VERBOSE
        gmt_remove_tmpdir
        gmt grdimage litho1_${LITHO1_DEPTH}.nc $GRID_PRINT_RES -C${LITHO1_CPT} $RJOK $VERBOSE >> map.ps
        ;;


      mapscale)

        # If we are plotting a horizontal scalebar, then we have to turn off the
        # scaleatrefflag and the north arrow plotting.
        if [[ $scalehorzflag -eq 1 ]]; then
          # scaleatrefflag=0
          scaleplotNflag=0
        fi

        # The center of the map is the reference lon/lat point by default
        if [[ $scaleautorefptflag -eq 1 ]]; then
          SCALEREFLON=${CENTERLON}
          SCALEREFLAT=${CENTERLAT}
        fi

        if [[ $scaleaprofflag -eq 1 ]]; then
          p1=($(grep "[${SCALE_APROFCODE}]" ${F_MAPELEMENTS}aprof_database.txt))
          SCALEREFLON=${p1[0]}
          SCALEREFLAT=${p1[1]}
        fi

        if [[ ${SCALEREFLON} == "" || ${SCALEREFLAT} == "" ]]; then
          SCALEREFLON=${CENTERLON}
          SCALEREFLAT=${CENTERLAT}
        fi

        if [[ $scalebarbywidthflag -eq 1 ]]; then
        # Plot a scale bar with a given width in inches, place on map as PS file.

          MAPXY=($(echo "${SCALEREFLON} ${SCALEREFLAT}" | gmt mapproject ${RJSTRING}))
          # echo "MapXY is ${MAPXY[@]}"
          # inches to CM
          MAPXY_END[0]=$(echo "${MAPXY[0]} + $SCALE_MAPLENGTH*2.54" | bc -l)
          MAPXY_END[1]=${MAPXY[1]}
          SCALE_END=($(echo "${MAPXY_END[@]}" | gmt mapproject -I ${RJSTRING}))

          # Calculate the new scale length that is rounded for nice internal divisions
          SCALE_LENGTH=$(echo ${SCALE_END[@]} | gmt mapproject -G${SCALEREFLON}/${SCALEREFLAT} ${RJSTRINGp[@]} | gawk -v nd=${SCALE_NUMDIVS} -v ni=${SCALE_MAPLENGTH_DIVISIBLE} '
            @include "tectoplot_functions.awk"
            {
              roundval=(ni==0)?nd:ni
              # Round up and down by the
              rdres=rd($3/1000, roundval)
              rures=ru($3/1000, roundval)

              print ((rures-$3/1000)>($3/1000-rdres))?rdres:rures "k"
            }')
        fi

        # If we are plotting a geographic scale directly onto the map
        if [[ $scaleatrefflag -eq 1 ]]; then
          SCALEPSFILE=map.ps
        else
          # If we are plotting onto the legend or off of the map
          gmt psxy -T -R -J -K > scale.ps
          SCALEPSFILE=scale.ps
        fi

        # Length without unit
        scalenot=$(echo $SCALE_LENGTH | gawk '{print ($1+0)}')
        # Half length without unit
        scalehalf=$(echo $SCALE_LENGTH | gawk '{print ($1+0)/2}')
        # Tenth length without unit
        scaletenth=$(echo $SCALE_LENGTH | gawk '{print ($1+0)/10}')
        # The scale unit - only km currently works but could use info from
        # geod to convert units to km
        scaleunit=$(echo $SCALE_LENGTH | sed 's/[^A-Za-z]*//g')

        # Allow k unit as synonym of km
        if [[ $scaleunit == "" || $scaleunit == "k" ]]; then
          scaleunit="km"
        fi

        # Origpoint is the lon lat coords of the reference point
        Origpoint[0]=${SCALEREFLON}
        Origpoint[1]=${SCALEREFLAT}

        # Point 1 is the eastward projection from the starting point by the given
        # distance. The path connecting Origpoint and Point1 might curve, so
        # a Cartesian distance calculation isn't actually correct.

        Point1=($(project_point_parallel_wgs84 ${SCALEREFLON} ${SCALEREFLAT} ${scalenot} ${scaleunit}))

        # Meridian distance projection not yet implemented!
        # Point2=($(project_point_dist_az ${SCALEREFLON} ${SCALEREFLAT} 0 ${scalenot} ${scaleunit}))

        # Point1Half is halfway between Origpoint and Point1
        Point1Half=($(project_point_parallel_wgs84 ${SCALEREFLON} ${SCALEREFLAT} ${scalehalf} ${scaleunit}))

        SCALEBAR_HALFWIDTH_P=$(echo "$SCALEBAR_WIDTH_P / 2" | bc -l)


        # SCALE_MINOR_TICK_LENGTH=$(echo "$SCALEBAR_WIDTH_P / 6" | bc -l)
        # SCALE_MAJOR_TICK_LENGTH=$(echo "$SCALEBAR_WIDTH_P / 3" | bc -l)

        if [[ $scaletextoverbarflag -eq 1 ]]; then
          SCALEBARFONTSIZE=8
          INSIDESCALEBARFONTSIZE=6
        else
          SCALEBARFONTSIZE=$(echo "$SCALEBAR_HALFWIDTH_P * 0.75"  | bc -l)
          INSIDESCALEBARFONTSIZE=$(echo "$SCALEBAR_HALFWIDTH_P * 0.6"  | bc -l)
        fi


        DIVEND=$(echo "$SCALE_NUMDIVS - 1" | bc)

        # We plot alternating color rectangles behind the scale
        iseven=1
        evencolor="white"
        oddcolor="lightgray"
        thiscolor=$evencolor

        # For horizontal scales, start map distance at 0
        TOTALMAPDIST=0

        # Horizontal scale bar section
        if [[ $scalehorzflag -eq 100 ]]; then

          # Calculate the length in map space of the Origpoint-Point 1 curve, using
          # the specified number of segments
          for subindex in $(seq 0 $DIVEND); do
            DIVLOW=$(echo "$scalenot * $subindex / ${SCALE_NUMDIVS}" | bc -l)
            DIVHIGH=$(echo "$scalenot * ($subindex + 1) / ${SCALE_NUMDIVS}" | bc -l)
            PointU=($(project_point_parallel_wgs84 ${SCALEREFLON} ${SCALEREFLAT} ${DIVLOW} ${scaleunit}))
            PointV=($(project_point_parallel_wgs84 ${SCALEREFLON} ${SCALEREFLAT} ${DIVHIGH} ${scaleunit}))

            # Find the distance on the map for this increment of the scale
            DIVMAPDIST=$(onmap_distance_between_points ${PointU[@]} ${PointV[@]})
          done
          exit 1

        else
          # Non-horizontal scale bar section
          for subindex in $(seq 0 $DIVEND); do
            DIVLOW=$(echo "$scalenot * $subindex / ${SCALE_NUMDIVS}" | bc -l)
            DIVHIGH=$(echo "$scalenot * ($subindex + 1) / ${SCALE_NUMDIVS}" | bc -l)
            DIVPAST=$(echo "$scalenot * ($subindex + 2) / ${SCALE_NUMDIVS}" | bc -l)

            PointU=($(project_point_parallel_wgs84 ${SCALEREFLON} ${SCALEREFLAT} ${DIVLOW} ${scaleunit}))
            PointV=($(project_point_parallel_wgs84 ${SCALEREFLON} ${SCALEREFLAT} ${DIVHIGH} ${scaleunit}))
            PointPast=($(project_point_parallel_wgs84 ${SCALEREFLON} ${SCALEREFLAT} ${DIVPAST} ${scaleunit}))

            # Calculate on-map azimuth and distance between PointU to PointV
            # Angles are only useful for fully geographic scales
            ANGLE1=$(onmap_angle_between_points ${PointU[@]} ${PointV[@]})
            ANGLE2=$(onmap_angle_between_points ${PointV[@]} ${PointPast[@]})

            # IF we are plotting a horizontal scale, we need to set ANGLE1=ANGLE2=90

            if [[ $scalehorzflag -eq 1 ]]; then
              # PointPast is not relevant as the angle is 90 anyway
              ANGLE1=90
              ANGLE2=90

              DIVMAPDIST=$(onmap_distance_between_points ${PointU[@]} ${PointV[@]})
              TOTALMAPDISTPREV=${TOTALMAPDIST}
              TOTALMAPDIST=$(echo "${TOTALMAPDIST} + ${DIVMAPDIST}*72" | bc -l)
              TOTALMAPDISTPAST=$(echo "${TOTALMAPDIST} + 2*${DIVMAPDIST}*72" | bc -l)  # inches

              # echo DIVMAPDIST is ${DIVMAPDIST} totalmap ${TOTALMAPDIST}

              # Now we need to set Point U/V to be the point exactly to the right of OriginPoint
              PointU=($(point_map_offset ${Origpoint[@]} ${TOTALMAPDISTPREV} 0))
              PointV=($(point_map_offset ${Origpoint[@]} ${TOTALMAPDIST} 0))
            fi


            if [[ $subindex -eq 0 ]]; then
              # The upper left corner of the horizontal scale bar
              # ANGLE=$ANGLE1
              NorthPt[1]=${Origpoint[1]}
              NorthPt[0]=$(echo "${Origpoint[0]}+0.1" | bc -l)
              ANGLE=$(onmap_angle_between_points ${Origpoint[@]} ${NorthPt[@]})

              # For horizontal flags, we fix the angle to 0
              if [[ $scalehorzflag -eq 1 ]]; then
                ANGLE=90
              fi

              STARTANGLE=$ANGLE
              OrigpointPlusH=($(point_map_offset_rotate_m90 ${Origpoint[@]} 0 ${SCALEBAR_WIDTH_P} ${ANGLE}))

              OrigpointPlusH=($(point_map_offset_rotate_m90 ${Origpoint[@]} 0 ${SCALEBAR_HALFWIDTH_P}  ${ANGLE}))
              OrigpointHalfPlusH=($(point_map_offset_rotate_m90 ${Origpoint[@]} ${SCALEBAR_HALFWIDTH_P} 0  ${ANGLE}))
              OrigpointHalfPlusHY=($(point_map_offset_rotate_m90 ${Origpoint[@]} 0 ${SCALEBAR_HALFWIDTH_P}  ${ANGLE}))

              Point1PlusH=($(point_map_offset_rotate_m90 ${Point1[@]} 0 ${SCALEBAR_HALFWIDTH_P}  ${ANGLE}))

              TickV=($(point_map_offset_rotate_m90 ${Origpoint[@]} 0 -${SCALE_MINOR_TICK_LENGTH} ${ANGLE}))
              PointW=($(point_map_offset_rotate_m90 ${Origpoint[@]} 0 ${SCALEBAR_WIDTH_P} ${ANGLE}))
              TickW=($(point_map_offset_rotate_m90 ${PointW[@]} 0 ${SCALE_MINOR_TICK_LENGTH} ${ANGLE}))

              echo "${Origpoint[@]}T${TickV[@]}" | tr 'T' '\n' | gmt psxy -W0.25p,black ${RJOK} ${VERBOSE} >> $SCALEPSFILE
              echo "${PointW[@]}T${TickW[@]}" | tr 'T' '\n' | gmt psxy -W0.25p,black ${RJOK} ${VERBOSE} >> $SCALEPSFILE

              # Plot the north arrow and letter N
              if [[ $scaleplotNflag -eq 1 ]]; then
                TickW2=($(point_map_offset_rotate_m90 ${PointW[@]} 0 $(echo "${SCALE_MINOR_TICK_LENGTH}" | bc -l) ${ANGLE}))
                echo "${Origpoint[@]}T${TickW2[@]}" | tr 'T' '\n' | gmt psxy -W0.35p,black+ve0.075i+l+h0+p0.35p,black+gwhite ${RJOK} ${VERBOSE} >> $SCALEPSFILE
                rotang=$(echo "90 - $ANGLE" | bc -l)
                rotfont=$(echo "${INSIDESCALEBARFONTSIZE}*0.8" | bc -l)
                echo "${TickW[@]} $rotang N" | gmt pstext -F+f${rotfont}p,Helvetica,black+A+jBL -D1p ${RJOK} ${VERBOSE} >> $SCALEPSFILE
              fi
            fi

            ANGLEPAST=$ANGLE

            ANGLE=$(echo $ANGLE1 $ANGLE2 | gawk '
              function rad2deg(rad)  { return (180 / getpi()) * rad   }
              function deg2rad(deg)  { return (getpi() / 180) * deg   }
              function getpi()       { return atan2(0,-1)             }
              function ave_dir(d1, d2) {
                sumcos=cos(deg2rad(d1))+cos(deg2rad(d2))
                sumsin=sin(deg2rad(d1))+sin(deg2rad(d2))
                val=rad2deg(atan2(sumsin, sumcos))
                return val
              }
              {
                print (ave_dir($1, $2) + 360) % 360
              }')

            PointW=($(point_map_offset_rotate_m90 ${PointV[@]} 0 ${SCALEBAR_WIDTH_P} ${ANGLE}))
            PointX=($(point_map_offset_rotate_m90 ${PointU[@]} 0 ${SCALEBAR_WIDTH_P} ${ANGLEPAST}))
            PointVHalf=($(point_map_offset_rotate_m90 ${PointV[@]} 0 ${SCALEBAR_HALFWIDTH_P} ${ANGLE}))

            if [[ $scaleskiplabelflag -eq 1 && $(echo "($subindex + 1) % $scaleskiplabelinc == 0" | bc) -eq 1 ]]; then
              TickV=($(point_map_offset_rotate_m90 ${PointV[@]} 0 -${SCALE_MAJOR_TICK_LENGTH} ${ANGLE}))
              TickW=($(point_map_offset_rotate_m90 ${PointW[@]} 0 ${SCALE_MAJOR_TICK_LENGTH} ${ANGLE}))
              echo ">T${PointV[@]}T${TickV[@]}" | tr 'T' '\n' >> bigticks.txt
              echo ">T${PointW[@]}T${TickW[@]}" | tr 'T' '\n' >> bigticks.txt
            else
              TickV=($(point_map_offset_rotate_m90 ${PointV[@]} 0 -${SCALE_MINOR_TICK_LENGTH} ${ANGLE}))
              TickW=($(point_map_offset_rotate_m90 ${PointW[@]} 0 ${SCALE_MINOR_TICK_LENGTH} ${ANGLE}))
              echo ">T${PointV[@]}T${TickV[@]}" | tr 'T' '\n' >> smallticks.txt
              echo ">T${PointW[@]}T${TickW[@]}" | tr 'T' '\n' >> smallticks.txt
            fi

            if [[ $thiscolor == $oddcolor ]]; then
              echo ">T${PointU[@]}T${PointV[@]}T${PointW[@]}T${PointX[@]}T${PointU[@]}" | tr 'T' '\n' >> oddcolor.txt
            else
              echo ">T${PointU[@]}T${PointV[@]}T${PointW[@]}T${PointX[@]}T${PointU[@]}" | tr 'T' '\n' >> evencolor.txt
            fi

            # Build up the boundary polygon
            if [[ $subindex -eq 0 ]]; then
              therestring=${PointV[@]}"T"${Origpoint[@]}
              herestring=${Origpoint[@]}"T"${PointX[@]}"T"${PointW[@]}
            else
              therestring=${PointV[@]}"T"${therestring}
              herestring=${herestring}"T"${PointW[@]}
            fi

            PointVHalfPlus=($(point_map_offset_rotate_m90 ${PointV[@]} 0 ${SCALEBAR_HALFWIDTH_P} ${ANGLE}))

            DIV2DP=$(printf "%.2f" $DIVHIGH)
            if [[ "${DIV2DP}" == *.* ]]; then
              DIVLABELTEXT=$(echo ${DIV2DP} | sed 's/[0]*$//g' | sed 's/[.]*$//g')
            else
              DIVLABELTEXT=${DIV2DP}
            fi

            TEXTANGLE=$(echo "90-$ANGLE" | bc -l)

            if [[ $subindex -ne $DIVEND ]]; then
              if [[ $scaleskiplabelflag -eq 1 ]]; then
                if [[ $(echo "($subindex + 1) % $scaleskiplabelinc == 0" | bc) -eq 1 ]]; then
                  if [[ $scaletextoverbarflag -eq 1 ]]; then
                    echo "${TickW[@]} ${TEXTANGLE} ${DIVLABELTEXT}" >> scaletext.txt
                  else
                    echo "${PointVHalf[@]} ${TEXTANGLE} ${DIVLABELTEXT}" >> scaletext.txt
                  fi
                fi
              else
                if [[ $scaletextoverbarflag -eq 1 ]]; then
                  echo "${TickW[@]} ${TEXTANGLE} ${DIVLABELTEXT}" >> scaletext.txt
                else
                  echo "${PointVHalf[@]} ${TEXTANGLE} ${DIVLABELTEXT}" >> scaletext.txt
                fi
              fi
            fi

            if [[ $iseven -eq 1 ]]; then
              iseven=0
              thiscolor=$oddcolor
            else
              iseven=1
              thiscolor=$evencolor
            fi
          done
        fi  # End non-horizontal scale bar section

        # At this point, we need these files:
        # oddcolor.txt/evencolor.txt are polygons in >Tlon latT... format
        # bigticks/smallticks.txt are lines
        # scaletext.txt are text locations and strings

        # If the scale bar is done in geographic coordinates, plotting is in ${RJSTRING} space
        # If the scale bar is done in Cartesian coordinates, ploggins is in -R -JX space

        # Plot the frame
        echo ${herestring}"T"${therestring} | tr 'T' '\n' | gmt psxy -W${SCALE_FRAME_PEN} -A --PS_LINE_CAP=round ${RJOK} ${VERBOSE} >> $SCALEPSFILE

        [[ -s oddcolor.txt ]] && gmt psxy oddcolor.txt -t${SCALE_TRANS} -G${oddcolor} -A ${RJOK} ${VERBOSE} >> $SCALEPSFILE
        [[ -s evencolor.txt ]] && gmt psxy evencolor.txt -t${SCALE_TRANS} -G${evencolor} -A ${RJOK} ${VERBOSE} >> $SCALEPSFILE
        [[ -s bigticks.txt ]] && gmt psxy bigticks.txt -W$bigtickformat ${RJOK} ${VERBOSE} >> $SCALEPSFILE
        [[ -s smallticks.txt ]] && gmt psxy smallticks.txt -W$smalltickformat ${RJOK} ${VERBOSE} >> $SCALEPSFILE
        if [[ -s scaletext.txt && $scalenolabelflag -ne 1 ]]; then
          if [[ $scaletextoverbarflag -eq 1 ]]; then
            SCALEBARTEXTJUST=CB
            SCALEBARTEXTYOFF=2p
          else
            SCALEBARTEXTJUST=CM
            SCALEBARTEXTYOFF=0p
          fi

          gmt pstext scaletext.txt -D-0.1p/${SCALEBARTEXTYOFF} -F+A+f${INSIDESCALEBARFONTSIZE}p,Helvetica-bold,black+j${SCALEBARTEXTJUST} -C0.2p/0.2p ${RJOK} ${VERBOSE} >> $SCALEPSFILE
        fi
        # If horizontal scale, we need to recalculate Point1 using the summed on-map distances
        if [[ $scalehorzflag -eq 1 ]]; then
          Point1=($(point_map_offset ${Origpoint[@]} ${TOTALMAPDIST} 0))
          Point1PlusH=($(point_map_offset ${Point1[@]} 0 ${SCALEBAR_HALFWIDTH_P}))
        fi


        # Labels need to be properly justified and also be parallel to the scale (it can curve)
        STARTJUST=$(azimuth_to_justcode $STARTANGLE)
        echo "${OrigpointPlusH[@]} 0" | gmt pstext -Dj2p -F+A$(echo "90-${STARTANGLE}" | bc -l)+f${SCALEBARFONTSIZE}p,Helvetica-bold,black+j${STARTJUST} ${RJOK} ${VERBOSE} >> $SCALEPSFILE
        ENDANGLE=$(echo $ANGLE | gawk '{print ($1 + 180) % 360}')
        ENDJUST=$(azimuth_to_justcode $ENDANGLE)
        echo "${Point1PlusH[@]} ${scalenot} ${scaleunit}" | gmt pstext -Dj2p -F+A$(echo "90-${ENDANGLE}" | bc -l)+f${SCALEBARFONTSIZE}p,Helvetica-bold,black+j${ENDJUST} ${RJOK} ${VERBOSE} >> $SCALEPSFILE


        # If we are using the onmap or offmap option, place on the map.
        if [[ $scaleatrefflag -ne 1 ]]; then
          [[ $scalemarkerflag -eq 1 ]] && echo "${OrigpointHalfPlusHY[@]}" | gmt psxy -Xa-0.2i -Skcrosshair/0.15i -W0.1p,black ${RJOK} ${VERBOSE} >> $SCALEPSFILE

          gmt psxy -T -R -J -O ${VERBOSE} >> scale.ps
          PS_DIM=$(gmt psconvert scale.ps -Te -A+m0.01i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
          SCALE_PS_WIDTH="$(echo $PS_DIM | gawk '{print $1/2.54}')"
          SCALE_PS_HEIGHT="$(echo $PS_DIM | gawk '{print $2/2.54}')"

          if [[ $scalebaronlegendflag -eq 1 ]]; then
            LEGEND_ITEM_PATHS+=("scale.eps")
            LEGEND_ITEM_WIDTHS+=(${SCALE_PS_WIDTH})
            LEGEND_ITEM_HEIGHTS+=(${SCALE_PS_HEIGHT})
          fi


          [[ $scalemarkerflag -eq 1 ]] && echo "${SCALEREFLON} ${SCALEREFLAT}" | gmt psxy -Skcrosshair/0.15i -W0.1p,black ${RJOK} ${VERBOSE} >> map.ps
          # [[ $scalemarkerflag -eq 1 ]] && echo "${PointV[@]}" | gmt psxy -Skcrosshair/0.15i -W0.1p,black ${RJOK} ${VERBOSE} >> map.ps


          # PS_DIM=$(gmt psconvert ${LEGENDDIR}${1}.ps -Te -A+m0.05i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
          # LEGEND_ITEM_PATHS+=("${LEGENDDIR}${1}.eps")
          # LEGEND_ITEM_WIDTHS+=("$(echo $PS_DIM | gawk '{print $1/2.54}')")
          # LEGEND_ITEM_HEIGHTS+=("$(echo $PS_DIM | gawk '{print $2/2.54}')")


          # SCALE_ONOFFCODE="j"
          # SCALE_JUST="TR"
          # SCALE_BORDERON="yes"

          thisJ=""
          if [[ ${SCALE_ONOFFCODE} == "J" ]]; then
            # Place outside the map frame
            case ${SCALE_JUST_CODE} in
              TL) shifth=0;   shiftv=30;   thisJ="+jBL";; # top edge, left side
              TM) SCALE_JUST="TC"; shifth=0;  shiftv=30;    thisJ="+jBC";; # top edge, middle
              TR) shifth=0;  shiftv=30;   thisJ="+jBR";; # top edge, right side
              BL) shifth=0;  shiftv=30;    thisJ="+jTL";; # bottom edge, left
              BM) SCALE_JUST_CODE="BC"; shifth=0;  shiftv=30;    thisJ="+jTC";; # bottom edge, center
              BR) shifth=0;  shiftv=30;    thisJ="+jTR";; # bottom edge, right
              RT) shifth=50;  shiftv=30;   thisJ="+jTL";; # right edge, top
              RM) SCALE_JUST_CODE="CR"; shifth=50;  shiftv=0; thisJ="+jML";; # right edge, center
              RB) shifth=50;  shiftv=0;   thisJ="+jBL";; # right edge, bottom
              LT) shifth=50;  shiftv=0;    thisJ="+jTR";;  # left edge, top
              LM) SCALE_JUST_CODE="CL"; shifth=50;  shiftv=0; thisJ="+jMR";;  # left edge, center
              LB) shifth=50;  shiftv=0;   thisJ="+jBR";; # left edge, bottom
              *)
                echo "Outside justification ${SCALE_JUST_CODE} not recognized. Using TL."
                SCALE_JUST_CODE="TL"
                shifth=0;   shiftv=30;   thisJ="+jBL"  # top edge, left side
              ;;
            esac
          else
            # Place inside the map frame
            case ${SCALE_JUST_CODE} in
              TR|RT) shifth=10; shiftv=10 ;;
              CR|RC) shifth=10;  shiftv=0  ;;
              BR|RB) shifth=10;  shiftv=10  ;;
              TC|CT) shifth=0;  shiftv=10  ;;
              CM|MC) shifth=0; shiftv=0 ;;
              BC|CB) shifth=0;  shiftv=10  ;;
              TL|LT) shifth=10;  shiftv=10  ;;
              CL|LC) shifth=10;  shiftv=0  ;;
              BL|LB) shifth=10;  shiftv=10  ;;
              *)
              echo "Inside justification ${SCALE_JUST_CODE} not recognized. Using BL"
                SCALE_JUST_CODE="BL"; shifth=10;  shiftv=10
              ;;
            esac
          fi

          if [[ ${SCALE_BORDERON} == "yes" ]]; then
            SCALE_BORDER_CALL=${SCALE_BORDER}
          else
            SCALE_BORDER_CALL=""
          fi

          if [[ $SCALE_BORDERCALL != "" && $SCALEFILL="" ]]; then
            SCALE_BORDERCALLnew="-F${SCALE_BORDERCALL}"
            SCALE_BORDERCALL=${SCALE_BORDERCALLnew}
          fi

          if [[ $scalebaronlegendflag -ne 1 ]]; then
            gmt psimage -D${SCALE_ONOFFCODE}${SCALE_JUST_CODE}+o${shifth}p/${shiftv}p+w${SCALE_PS_WIDTH}i/0${thisJ} ${SCALEFILL}${SCALE_BORDER_CALL} scale.eps $RJOK ${VERBOSE} >> map.ps
          fi
        fi
        ;;

      northarrow)

        if [[ $northarrowaprofflag -eq 1 ]]; then
          p1=($(grep "[${NORTHARROWAPROFCODE:0:1}]" ${F_MAPELEMENTS}aprof_database.txt))
          ARROWREFLON=${p1[0]}
          ARROWREFLAT=${p1[1]}
        fi

        # The values of SCALECMD will be set by the scale) section
        ARROWCMD="-Tdg${ARROWREFLON}/${ARROWREFLAT}${ARROWFANCY}+w${ARROWSIZE}"
        gmt psbasemap ${ARROWCMD} $RJOK $VERBOSE --MAP_TITLE_OFFSET=4p --FONT_TITLE=8p,Helvetica,black >> map.ps
        ;;

      maptitle)
        gmt psbasemap "-B+t${PLOTTITLE}" --FONT_TITLE=20p,Helvetica-bold,black $RJOK $VERBOSE >> map.ps
        ;;

      aprofcodes)
        grep "[$APROFCODES]" ${F_MAPELEMENTS}aprof_database.txt > ${F_MAPELEMENTS}aprof_codes.txt
        gmt pstext ${F_MAPELEMENTS}aprof_codes.txt -F+f14p,Helvetica,black $RJOK $VERBOSE >> map.ps
        ;;

      pagegrid)
        case ${PAGE_GRID_UNIT} in
          i)
            PAGE_GRID_XSIZE=$(echo ${PROJDIM[0]} | gawk '
              @include "tectoplot_functions.awk"
              {
                print ru($1/2.54+1,1)
              }')
            PAGE_GRID_YSIZE=$(echo ${PROJDIM[1]} | gawk '
              @include "tectoplot_functions.awk"
              {
                print ru($1/2.54+1,1)
              }')
            PAGE_GRID_XSIZE_P2=$(echo ${PROJDIM[0]} | gawk '
              @include "tectoplot_functions.awk"
              {
                print ru(($1)/2.54+1,1)
              }')
            PAGE_GRID_YSIZE_P2=$(echo ${PROJDIM[1]} | gawk '
              @include "tectoplot_functions.awk"
              {
                print ru(($1)/2.54+1,1)
              }')
          ;;
          c)
            PAGE_GRID_XSIZE=$(echo ${PROJDIM[0]} | gawk '
              @include "tectoplot_functions.awk"
              {
                print ru($1+1,1)
              }')
            PAGE_GRID_YSIZE=$(echo ${PROJDIM[1]} | gawk '
              @include "tectoplot_functions.awk"
              {
                print ru($1+1,1)
              }')
            PAGE_GRID_XSIZE_P2=$(echo ${PROJDIM[0]} | gawk '
              @include "tectoplot_functions.awk"
              {
                print ru($1+1,1)
              }')
            PAGE_GRID_YSIZE_P2=$(echo ${PROJDIM[1]} | gawk '
              @include "tectoplot_functions.awk"
              {
                print ru($1+1,1)
              }')
            ;;
          esac

          # echo "Xsize: ${PAGE_GRID_XSIZE}${PAGE_GRID_UNIT}, Ysize: ${PAGE_GRID_YSIZE}${PAGE_GRID_UNIT}"

          # Plot -1 X and -i Y
          gmt_init_tmpdir

          gmt psbasemap -R0/1/0/1 -JX0${PAGE_GRID_UNIT}/${PAGE_GRID_YSIZE_P2}${PAGE_GRID_UNIT} -Xa-1${PAGE_GRID_UNIT} -Ya-1${PAGE_GRID_UNIT} -Br  -O -K --MAP_FRAME_PEN=0.1p,gray,4_8 >> map.ps

          gmt psbasemap -R0/1/0/1 -JX${PAGE_GRID_XSIZE_P2}${PAGE_GRID_UNIT}/0${PAGE_GRID_UNIT} -Ya-1${PAGE_GRID_UNIT} -Xa-1${PAGE_GRID_UNIT} -Bt  -O -K --MAP_FRAME_PEN=0.1p,gray,4_8 >> map.ps

          pagegrid_ind=0
          while [[ $(echo "$pagegrid_ind <= $PAGE_GRID_XSIZE_P2" | bc) -eq 1 ]]; do
            textoff=$(echo "$pagegrid_ind - 1" | bc )
            echo "0 0 ${textoff}${PAGE_GRID_UNIT}" | gmt pstext -R0/1/0/1 -C0.1+t -F+f10p,Helvetica,gray+jLB -JX${pagegrid_ind}${PAGE_GRID_UNIT}/${PAGE_GRID_YSIZE_P2}${PAGE_GRID_UNIT} -Xa${textoff}${PAGE_GRID_UNIT} -Ya-1${PAGE_GRID_UNIT} $VERBOSE -O -K >> map.ps

            gmt psbasemap -R0/1/0/1 -JX${pagegrid_ind}${PAGE_GRID_UNIT}/${PAGE_GRID_YSIZE_P2}${PAGE_GRID_UNIT} -Xa-1${PAGE_GRID_UNIT} -Ya-1${PAGE_GRID_UNIT} -Br  -O -K --MAP_FRAME_PEN=0.1p,gray,4_8_5_8 >> map.ps
            ((pagegrid_ind++))
          done

          pagegrid_ind=0
          while [[ $(echo "$pagegrid_ind < $PAGE_GRID_YSIZE_P2" | bc) -eq 1 ]]; do
            textoff=$(echo "$pagegrid_ind - 1" | bc )

            echo "0 0 ${textoff}${PAGE_GRID_UNIT}" | gmt pstext -R0/1/0/1 -C0.1+t -F+f10p,Helvetica,gray+jLB -JX${pagegrid_ind}${PAGE_GRID_UNIT}/${PAGE_GRID_YSIZE_P2}${PAGE_GRID_UNIT} -Xa-1${PAGE_GRID_UNIT} -Ya${textoff}${PAGE_GRID_UNIT} $VERBOSE -O -K >> map.ps

            gmt psbasemap -R0/1/0/1 -JX${PAGE_GRID_XSIZE_P2}${PAGE_GRID_UNIT}/${pagegrid_ind}${PAGE_GRID_UNIT} -Xa-1${PAGE_GRID_UNIT} -Bt  -O -K --MAP_FRAME_PEN=0.1p,gray,4_8_5_8 >> map.ps
            ((pagegrid_ind++))
          done
          gmt_remove_tmpdir
          # gmt psbasemap -R0/1/0/1 -JX${i}${PAGE_GRID_UNIT}/${PAGE_GRID_MAX_NUM}${PAGE_GRID_UNIT} -Ya-${PAGE_GRID_MAX_NUM}${PAGE_GRID_UNIT} -Br  -O -K --MAP_FRAME_PEN=0.1p,black,- >> map.ps
          # gmt psbasemap -R0/1/0/1 -JX${PAGE_GRID_MAX_NUM}${PAGE_GRID_UNIT}/${i}${PAGE_GRID_UNIT} -Xa-1${PAGE_GRID_UNIT} -Ya-1${PAGE_GRID_UNIT} -Bt  -O -K --MAP_FRAME_PEN=0.1p,black,4_8_5_8 >> map.ps
        ;;

      mprof)

        if [[ $sprofflag -eq 1 || $aprofflag -eq 1 || $cprofflag -eq 1 || $kprofflag -eq 1 || $lprofflag -eq 1 || $xprofflag -eq 1 ]]; then
          info_msg "Updating mprof to use a newly generated sprof.control file"
          # PROFILE_WIDTH_IN="7i"
          # PROFILE_HEIGHT_IN="2i"
          PROFILE_X="0"
          PROFILE_Y=$(echo $PROFILE_HEIGHT_IN | gawk -F'i' '{print -($1+1) "i"}')
          MPROFFILE="sprof.control"

          if [[ $PROFILE_ALIGNZ == "0" ]]; then
            ALIGN_MATCH="match"
          else
            ALIGN_MATCH=""
          fi

          if [[ $setprofdepthflag -eq 1 ]]; then
            echo "@ auto auto ${SPROF_MINELEV} ${SPROF_MAXELEV} ${ALIGNXY_FILE} ${ALIGN_MATCH}" > sprof.control
          else
            echo "@ auto auto auto auto ${ALIGNXY_FILE} ${ALIGN_MATCH}" > sprof.control
          fi
          if [[ $PROFILE_CUSTOMAXES_FLAG -eq 1 ]]; then
            info_msg "Adding custom axes labels to sprof"
            echo "L ${PROFILE_X_LABEL}|${PROFILE_Y_LABEL}|${PROFILE_Z_LABEL}|${PROFILE_RIGHT_LABEL}" >> sprof.control
          fi

          if [[ $profwidthflag -eq 1 ]]; then
            echo "Z ${PROFWIDTH}" >> sprof.control
          fi

          if [[ $profrasflag -eq 1 ]]; then
            case $PROFRASTER in
              grav)
                echo "Adding gravity grid to sprof as swath and top tile"
                echo "${SWATHORBOX} ${F_GRAV}grav.nc 0.1 ${SPROF_RES} ${SPROF_RES} ${GRAV_CPT}" >> sprof.control
                echo "G ${F_GRAV}grav.nc 0.1 ${SPROF_RES} ${SPROF_RES} ${GRAV_CPT}" >> sprof.control
                PROFILE_Z_LABEL="Gravity (mgal*0.1)"
                # Make the gravity top tile and set
                gmt grdimage $GRAVDATA -A${F_GRAV}grav.tif ${GRAVGRAD} -t$GRAVTRANS -C${GRAV_CPT} -R -J ${VERBOSE}
                COLORED_RELIEF=${F_GRAV}grav.tif
                echo "M USE_SHADED_RELIEF_TOPTILE" >> sprof.control
              ;;
              mag)
                info_msg "Adding magnetics grid to sprof as swath and top tile"
                echo "${SWATHORBOX} ${F_MAG}mag.nc 0.1 ${SPROF_RES} ${SPROF_RES} ${MAG_CPT}" >> sprof.control
                echo "G ${F_MAG}mag.nc 0.1 ${SPROF_RES} ${SPROF_RES} ${MAG_CPT}" >> sprof.control
                PROFILE_Z_LABEL="Magnetization (nT*0.1)"

                # Make the magnetics top tile and set
                gmt grdimage ${F_MAG}mag.nc -A${F_MAG}mag.tif ${MAGGRAD} -t$MAGTRANS -C${MAG_CPT} -R -J ${VERBOSE}
                COLORED_RELIEF=${F_MAG}mag.tif
                echo "M USE_SHADED_RELIEF_TOPTILE" >> sprof.control
              ;;
              *)
                info_msg "Adding custom grid to sprof as swath / shaded relief toptile WITH topo cpt"
                echo "${SWATHORBOX} ${PROFRASTER} ${PROFRASTER_SCALE} ${SPROF_RES} ${SPROF_RES} ${TOPO_CPT}" >> sprof.control
                # echo "G ${PROFRASTER} ${PROFRASTER_SCALE} ${SPROF_RES} ${SPROF_RES} ${TOPO_CPT}" >> sprof.control
              ;;
            esac
            # if [[ -s ${F_GRAV}grav.nc ]]; then
            #
            # elif [[ -s ${F_MAG}mag.nc ]]; then
            #
            # fi
            # echo "G ${TOPOGRAPHY_DATA} ${PROFRASTER_SCALE} ${SPROF_RES} ${SPROF_RES} ${PROFRASTER_CPT}" >> sprof.control
          # elif [[ $plotcustomtopo -eq 1 ]]; then
          #   info_msg "Adding custom grid to sprof"
          #   echo "S ${TOPOGRAPHY_DATA} 0.001 ${SPROF_RES} ${SPROF_RES}" >> sprof.control

          elif [[ -s ${TOPOGRAPHY_DATA} ]]; then
            info_msg "Adding topography/bathymetry from map to sprof as swath and top tile"
            # echo "S ${TOPOGRAPHY_DATA} 0.001 ${SPROF_RES} ${SPROF_RES}" >> sprof.control
            echo "${SWATHORBOX} ${TOPOGRAPHY_DATA} 0.001 ${SPROF_RES} ${SPROF_RES} ${TOPO_CPT}" >> sprof.control
            echo "G ${TOPOGRAPHY_DATA} 0.001 ${SPROF_RES} ${SPROF_RES} ${TOPO_CPT}" >> sprof.control
            echo "M USE_SHADED_RELIEF_TOPTILE" >> sprof.control
          fi

          if [[ $profgridflag -eq 1 ]]; then
            info_msg "Adding profgrid to sprof as gridded-xyz"
            echo "I $profgridfile -1 ${profgridcpt}" >> sprof.control
          fi

          if [[ $prof3dgridflag -eq 1 ]]; then
            info_msg "Adding 3D datacube"
            echo "Q $PROF3DGRIDFILE ${THREEDGRIDVAR} ${THREEDGRIDRES} ${THREEDCPT} ${THREEDBUF}" >> sprof.control
          fi

          if [[ -s tomography.txt ]]; then
            info_msg "Adding tomography to sprof as gridded-xyz"
            echo "I tomography.txt -1" >> sprof.control
          fi

          if [[ -e ${F_SEIS}eqs.txt ]]; then
            info_msg "Adding eqs to sprof as seis-xyz"

            if [[ -s ${F_SEIS}eqs.txt ]]; then
              echo "E ${F_SEIS}eqs.txt -1 stroke ${EQLINEWIDTH},${EQLINECOLOR} trans ${SEISTRANS} symbol ${SEISSYMBOL} scale ${SEISSCALE} stretch ${SEISSTRETCH} refmag ${SEISSTRETCH_REFMAG} cpt ${SEIS_CPT} zcol ${SEIS_ZCOL}" >> sprof.control
            fi

            if [[ $zhighlightflag -eq 1 ]]; then
              echo "E ${F_SEIS}eqs_highlight.txt -1 stroke 2p,black trans ${SEISTRANS} symbol ${SEISSYMBOL} scale ${SEISSCALE} stretch ${SEISSTRETCH} refmag ${SEISSTRETCH_REFMAG} cpt ${SEIS_CPT} zcol ${SEIS_ZCOL}" >> sprof.control
            fi
          fi

          if [[ -s ${F_CMT}cmt_normal.txt ]]; then
            info_msg "Adding cmt normal to sprof"
            echo "C ${F_CMT}cmt_normal.txt -1 -E${CMT_NORMALCOLOR}" >> sprof.control
          fi
          if [[ -s ${F_CMT}cmt_strikeslip.txt ]]; then
            info_msg "Adding cmt normal to sprof"
            echo "C ${F_CMT}cmt_strikeslip.txt -1 -E${CMT_SSCOLOR}" >> sprof.control
          fi
          if [[ -s ${F_CMT}cmt_thrust.txt ]]; then
            info_msg "Adding cmt normal to sprof"
            echo "C ${F_CMT}cmt_thrust.txt -1 -E${CMT_THRUSTCOLOR}" >> sprof.control
          fi

          if [[ -e ${F_VOLC}volcanoes.dat ]]; then
            # We need to sample the DEM at the volcano point locations, or else use 0 for elevation.
            info_msg "Adding volcanoes to sprof as xyz"
            echo "X ${F_VOLC}volcanoes.dat 0.001 -St0.1i -W0.1p,black" >> sprof.control
          fi

          if [[ -e ${F_PROFILES}profile_labels.dat ]]; then
            info_msg "Adding profile labels to sprof as xyz [lon/lat/km]"
            echo "B ${F_PROFILES}profile_labels.dat 1 ${FONTSTR}"  >> sprof.control
          fi

          if [[ -s ${F_PROFILES}profile_commands.txt ]]; then
            echo "Adding additional profile commands to sprof.control"
            cat ${F_PROFILES}profile_commands.txt >> sprof.control
          fi


          if [[ $plotfaultgridflag -eq 1 ]]; then
            for thisfault in $(seq 1 $faultgridnum); do
              echo "T ${FAULTGRIDFILES[$thisfault]} ${FAULTGRIDFILEMUL[$thisfault]} ${FAULTGRIDFILERES[$thisfault]} -W1p+cl -C$SEISDEPTH_CPT" >> sprof.control
            done
          fi

          if [[ $plotslab2 -eq 1 ]]; then
            if [[ ! $numslab2inregion -eq 0 ]]; then
              for i in $(seq 1 $numslab2inregion); do
                info_msg "Adding slab grid ${slab2inregion[$i]} to sprof"
                gridfile=$(echo ${SLAB2_GRIDDIR}${slab2inregion[$i]}.grd | sed 's/clp/dep/')
                echo "T $gridfile -1 5k -W1p+cl -C$SEISDEPTH_CPT" >> sprof.control
              done
            fi
          fi

          # Keep track of the current profile number
          thissprof=0

          if [[ $sprofflag -eq 1 ]]; then
            while read p; do
              ((thissprof++))
              # echo "P P${thissprof} black N N ${SPROFLON1[${thissprof}]} ${SPROFLAT1[${thissprof}]} ${SPROFLON2[${thissprof}]} ${SPROFLAT2[${thissprof}]}" >> sprof.control
              echo "P P${thissprof} black N N ${p}" >> sprof.control
            done < ${TMP}sprof.lines
          fi
          if [[ $xprofflag -eq 1 ]]; then
            for thisxprof in $(seq 1 $xprofnumber); do
              ((thissprof++))
              echo "A A${thissprof} black N N ${XPROFPTS[${xprofnumber}]}" >> sprof.control
            done
          fi

          if [[ $cprofflag -eq 1 ]]; then
            cat ${F_PROFILES}cprof_profs.txt >> sprof.control
          fi
          if [[ $aprofflag -eq 1 ]]; then
            cat ${F_PROFILES}aprof_profs.txt >> sprof.control
          fi
          if [[ $kprofflag -eq 1 ]]; then
            cat ${F_PROFILES}kprof_profs.txt >> sprof.control
          fi
          if [[ $lprofflag -eq 1 ]]; then
            cat ${F_PROFILES}lprof_profs.txt >> sprof.control
          fi
        fi

        # I can calculate the map coordinates of the start and end points for
        # each profile and then set PROFILE_WIDTH/PROFILE_HEIGHT accordingly?

# SECTION PROFILES
        info_msg "Drawing profile(s)"

        MAP_PSFILE=$(abs_path map.ps)

        cp gmt.history gmt.history.preprofile
        . $MPROFILE_SH_SRC
        cp gmt.history.preprofile gmt.history

        # If using -lprof, plot the track line


        if [[ -s ${F_PROFILES}lprof_profile.xy ]]; then
          gmt psxy ${F_PROFILES}lprof_profile.xy -W1p,black,- ${RJOK} >> map.ps
        fi


        # Plot the profile lines with the assigned color on the map
        # echo TRACKFILE=...$TRACKFILE


#         k=$(wc -l < $TRACKFILE | gawk  '{print $1}')
#         for ind in $(seq 1 $k); do
#           linetext=$(head -n ${ind} $TRACKFILE | tail -n 1)
#           FIRSTWORD=$(head -n ${ind} $TRACKFILE | tail -n 1 | gawk  '{print $1}')
#
#           if [[ ${FIRSTWORD:0:1} == "P" ]]; then
#             COLOR=$(head -n ${ind} $TRACKFILE | tail -n 1 | gawk  '{print $3}')
#
#
#             # Can plot plain line or with annotated distances along the line
#             head -n ${ind} $TRACKFILE | tail -n 1 | cut -f 6- -d ' ' | xargs -n 2 | gmt psxy $RJOK -W${PROFILE_TRACK_WIDTH},${COLOR} >> map.ps
#
#
#
# # Plot a line with distance ticks... but need to know the spacing somehow!
# #            head -n ${ind} $TRACKFILE | tail -n 1 | cut -f 6- -d ' ' | xargs -n 2 | \
# #              gmt psxy $RJOK -S~D100k/1:+s-5p+a90 -W${PROFILE_TRACK_WIDTH},${COLOR} >> map.ps
#             head -n ${ind} $TRACKFILE | tail -n 1 | cut -f 6- -d ' ' | gawk '{print $1, $2}' | gmt psxy -Si0.1i -W0.5p,${COLOR} -G${COLOR} $RJOK  >> map.ps
#             head -n ${ind} $TRACKFILE | tail -n 1 | cut -f 6- -d ' ' | xargs -n 2 | sed '1d' | gmt psxy -Si0.1i -W0.5p,${COLOR} $RJOK  >> map.ps
#           fi
#         done

        while read trackline; do
          trackentries=($(echo $trackline))
          FIRSTWORD=${trackentries[0]}

          if [[ ${FIRSTWORD:0:1} == "P" || ${FIRSTWORD:0:1} == "A" ]]; then
            LINEID=${trackentries[1]}
            COLOR=${trackentries[2]}

            if [[ -s ${F_PROFILES}${LINEID}_interval.txt && $profiledistlabelsflag -eq 1 ]]; then

              # Plot profile line with distance markers and labels

              read interval1 < ${F_PROFILES}${LINEID}_interval.txt

              echo $trackline | cut -f 6- -d ' ' | xargs -n 2 | \
                gmt psxy $RJOK -S~D${interval1}k/1:+sc2p+ap+gblack -W${PROFILE_TRACK_WIDTH},${COLOR} >> map.ps
              echo $trackline | cut -f 6- -d ' ' | xargs -n 2 | \
                gmt psxy $RJOK -SqD${interval1}k/1:+uk+i+LDk+ap+N0/-8p >> map.ps
            else

              # Plot a plain profile line
              echo $trackline | cut -f 6- -d ' ' | xargs -n 2 | gmt psxy $RJOK -W${PROFILE_TRACK_WIDTH},${COLOR} >> map.ps
            fi

            echo $trackline | cut -f 6- -d ' ' | gawk '{print $1, $2}' | gmt psxy -Si0.1i -W${PROFILE_TRACK_WIDTH},${COLOR} -G${COLOR} $RJOK  >> map.ps
            echo $trackline | cut -f 6- -d ' ' | xargs -n 2 | sed '1d' | gmt psxy -Si0.1i -W${PROFILE_TRACK_WIDTH},${COLOR} $RJOK  >> map.ps
          fi
        done < $TRACKFILE

        # PROFILETRACKS=1
        # Plot the gridtrack tracks, for debugging
        if [[ ${PROFILETRACKS} -eq 1 ]]; then
          for track_file in ${F_PROFILES}*_profiletable.txt; do
             # echo $track_file
            gmt psxy $track_file -W0.15p,black $RJOK $VERBOSE >> map.ps
          done
        fi

        # PLOT_PROFILEPOINTS=1
        if [[ ${PLOT_PROFILEPOINTS} -eq 1 ]]; then
          for track_file in ${F_PROFILES}*_profiletable.txt; do
            gmt psxy $track_file -Sc0.01i -Gblack $RJOK $VERBOSE >> map.ps
          done
        fi

        # Plot the buffers around the polylines, for debugging
        # if [[ -e buf_poly.txt ]]; then
        #   info_msg "Plotting buffers"
        #   gmt psxy buf_poly.txt -W0.5p,red $RJOK $VERBOSE >> map.ps
        # fi

        # end_points.txt contains lines with the origin point and azimuth of each plotted profile
        # 110 -2 281.365 0.909091 0/0/0
        # Lon Lat Azimuth Width(deg) R/G/Bcolor  ID

        # If we have plotted profiles, we need to plot decorations that accurately
        # show the maximum swath width. This could be extended to plot multiple
        # swath widths if they exist, but for now we go with the maximum one.

        for this_file in ${F_PROFILES}*_trackfile_final_buffer.txt; do
          gmt psxy ${this_file} -W0.5p,black,- ${RJOK} ${VERBOSE} >> map.ps
        done

        if [[ -e ${F_PROFILES}end_points.txt ]]; then
          while read d; do
            p=($(echo $d))
            # echo END POINT ${p[0]}/${p[1]} azimuth ${p[2]} width ${p[3]} color ${p[4]}
            ANTIAZ=$(echo "${p[2]} - 180" | bc -l)
            FOREAZ=$(echo "${p[2]} - 90" | bc -l)
            WIDTHKM=$(echo "${p[3]} / 2" | bc -l) # Half width
            SUBWIDTH=$(echo "${p[3]} / 110 * 0.1" | bc -l)
            echo ">" >> ${F_PROFILES}end_profile_lines.txt
            # echo "${p[0]} ${p[1]}" | gmt vector -Tt${p[2]}/${p[3]}k > endpoint1.txt
            # echo "${p[0]} ${p[1]}" | gmt vector -Tt${ANTIAZ}/${p[3]}k > endpoint2.txt
            gmt project -C${p[0]}/${p[1]} -A${p[2]} -Q -G${WIDTHKM}k -L0/${WIDTHKM} | tail -n 1 | gawk  '{print $1, $2}' > ${F_PROFILES}endpoint1.txt
            gmt project -C${p[0]}/${p[1]} -A${ANTIAZ} -Q -G${WIDTHKM}k -L0/${WIDTHKM} | tail -n 1 | gawk  '{print $1, $2}' > ${F_PROFILES}endpoint2.txt
            cat ${F_PROFILES}endpoint1.txt | gmt vector -Tt${FOREAZ}/${SUBWIDTH}d >> ${F_PROFILES}end_profile_lines.txt
            cat ${F_PROFILES}endpoint1.txt >> ${F_PROFILES}end_profile_lines.txt
            echo "${p[0]} ${p[1]}" >> ${F_PROFILES}end_profile_lines.txt
            cat ${F_PROFILES}endpoint2.txt >> ${F_PROFILES}end_profile_lines.txt
            cat ${F_PROFILES}endpoint2.txt | gmt vector -Tt${FOREAZ}/${SUBWIDTH}d >> ${F_PROFILES}end_profile_lines.txt
            # gmt psxy ${F_PROFILES}end_profile_lines.txt -W${PROFILE_TRACK_WIDTH},${p[4]} $RJOK $VERBOSE >> map.ps
            rm -f ${F_PROFILES}end_profile_lines.txt
          done < ${F_PROFILES}end_points.txt

          while read d; do
            p=($(echo $d))
            # echo START POINT ${p[0]}/${p[1]} azimuth ${p[2]} width ${p[3]} color ${p[4]}
            ANTIAZ=$(echo "${p[2]} - 180" | bc -l)
            FOREAZ=$(echo "${p[2]} + 90" | bc -l)
            WIDTHKM=$(echo "${p[3]} / 2" | bc -l) # Half width
            SUBWIDTH=$(echo "${p[3]}/110 * 0.1" | bc -l)
            echo ">" >>  ${F_PROFILES}start_profile_lines.txt
            gmt project -C${p[0]}/${p[1]} -A${p[2]} -Q -G${WIDTHKM}k -L0/${WIDTHKM}k | tail -n 1 | gawk  '{print $1, $2}' > ${F_PROFILES}startpoint1.txt
            gmt project -C${p[0]}/${p[1]} -A${ANTIAZ} -Q -G${WIDTHKM}k -L0/${WIDTHKM}k | tail -n 1 | gawk  '{print $1, $2}' > ${F_PROFILES}startpoint2.txt
            # echo "${p[0]} ${p[1]}" | gmt vector -Tt${p[2]}/${p[3]}d >  startpoint1.txt
            # echo "${p[0]} ${p[1]}" | gmt vector -Tt${ANTIAZ}/${p[3]}d >  startpoint2.txt
            cat  ${F_PROFILES}startpoint1.txt | gmt vector -Tt${FOREAZ}/${SUBWIDTH}d >>  ${F_PROFILES}start_profile_lines.txt
            cat  ${F_PROFILES}startpoint1.txt >>  ${F_PROFILES}start_profile_lines.txt
            echo "${p[0]} ${p[1]}" >> ${F_PROFILES}start_profile_lines.txt
            cat  ${F_PROFILES}startpoint2.txt >>  ${F_PROFILES}start_profile_lines.txt
            cat  ${F_PROFILES}startpoint2.txt | gmt vector -Tt${FOREAZ}/${SUBWIDTH}d >>  ${F_PROFILES}start_profile_lines.txt
            # gmt psxy ${F_PROFILES}start_profile_lines.txt -W${PROFILE_TRACK_WIDTH},${p[4]} $RJOK $VERBOSE >> map.ps
            rm -f ${F_PROFILES}start_profile_lines.txt
          done < ${F_PROFILES}start_points.txt

          # gmt psxy ${F_PROFILES}end_profile_lines.txt -W${PROFILE_TRACK_WIDTH},black $RJOK $VERBOSE >> map.ps
          # gmt psxy ${F_PROFILES}start_profile_lines.txt -W${PROFILE_TRACK_WIDTH},black $RJOK $VERBOSE >> map.ps
        fi

        if [[ -e ${F_PROFILES}mid_points.txt ]]; then
          while read d; do
            p=($(echo $d))
            # echo MID POINT ${p[0]}/${p[1]} azimuth ${p[2]} width ${p[3]} color ${p[4]}
            ANTIAZ=$(echo "${p[2]} - 180" | bc -l)
            FOREAZ=$(echo "${p[2]} + 90" | bc -l)
            FOREAZ2=$(echo "${p[2]} - 90" | bc -l)
            WIDTHKM=$(echo "${p[3]} / 2" | bc -l) # Half width
            SUBWIDTH=$(echo "${p[3]}/110 * 0.1" | bc -l)
            echo ">" >>  ${F_PROFILES}mid_profile_lines.txt
            gmt project -C${p[0]}/${p[1]} -A${p[2]} -Q -G${WIDTHKM}k -L0/${WIDTHKM}k | tail -n 1 | gawk  '{print $1, $2}' >  ${F_PROFILES}midpoint1.txt
            gmt project -C${p[0]}/${p[1]} -A${ANTIAZ} -Q -G${WIDTHKM}k -L0/${WIDTHKM}k | tail -n 1 | gawk  '{print $1, $2}' > ${F_PROFILES}midpoint2.txt

            # echo "${p[0]} ${p[1]}" | gmt vector -Tt${p[2]}/${p[3]}d >  midpoint1.txt
            # echo "${p[0]} ${p[1]}" | gmt vector -Tt${ANTIAZ}/${p[3]}d >  midpoint2.txt

            cat  ${F_PROFILES}midpoint1.txt | gmt vector -Tt${FOREAZ}/${SUBWIDTH}d >>  ${F_PROFILES}mid_profile_lines.txt
            cat  ${F_PROFILES}midpoint1.txt | gmt vector -Tt${FOREAZ2}/${SUBWIDTH}d >>  ${F_PROFILES}mid_profile_lines.txt
            cat  ${F_PROFILES}midpoint1.txt >>  ${F_PROFILES}mid_profile_lines.txt
            echo "${p[0]} ${p[1]}" >>  ${F_PROFILES}mid_profile_lines.txt
            cat  ${F_PROFILES}midpoint2.txt >>  ${F_PROFILES}mid_profile_lines.txt
            cat  ${F_PROFILES}midpoint2.txt | gmt vector -Tt${FOREAZ}/${SUBWIDTH}d >>  ${F_PROFILES}mid_profile_lines.txt
            cat  ${F_PROFILES}midpoint2.txt | gmt vector -Tt${FOREAZ2}/${SUBWIDTH}d >>  ${F_PROFILES}mid_profile_lines.txt
            # gmt psxy ${F_PROFILES}mid_profile_lines.txt -W${PROFILE_TRACK_WIDTH},${p[4]} $RJOK $VERBOSE >> map.ps
            rm -f ${F_PROFILES}mid_profile_lines.txt
          done <  ${F_PROFILES}mid_points.txt

        fi

  cleanup ${F_PROFILES}mid_profile_lines.txt ${F_PROFILES}end_profile_lines.txt ${F_PROFILES}start_profile_lines.txt
  cleanup ${F_PROFILES}startpoint1.txt ${F_PROFILES}startpoint2.txt
  cleanup ${F_PROFILES}midpoint1.txt ${F_PROFILES}midpoint2.txt
  cleanup ${F_PROFILES}endpoint1.txt ${F_PROFILES}endpoint2.txt

        # Plot the intersection point of the profile with the 0-distance datum line as triangle
        if [[ -e ${F_PROFILES}all_intersect.txt ]]; then
          info_msg "Plotting intersection of tracks with zeroline"
          gmt psxy ${F_PROFILES}xy_intersect.txt -W0.5p,black $RJOK $VERBOSE >> map.ps
          gmt psxy ${F_PROFILES}all_intersect.txt -St0.1i -Gwhite -W0.7p,black $RJOK $VERBOSE >> map.ps
        fi

        # This is used to offset the profile name so it doesn't overlap the track line
        PTEXT_OFFSET=$(echo ${PROFILE_TRACK_WIDTH} | gawk  '{ print ($1+0)*2 "p" }')

        plotlineidflag=1
        if [[ $plotlineidflag -eq 1 ]]; then

          while read d; do
            p=($(echo $d))
            # echo "${p[0]},${p[1]},${p[5]}  angle ${p[2]}"
            echo "${p[0]},${p[1]},${p[5]}" | gmt pstext -A -Dj${PTEXT_OFFSET} -F+f${PROFILE_FONT_LABEL_SIZE},Helvetica+jRB+a$(echo "${p[2]}-90" | bc -l) $RJOK $VERBOSE >> map.ps
          done < ${F_PROFILES}start_points.txt
        fi

        MAP_PROF_SPACING=0.25 # inches
        # If we are placing one or more profiles onto the map, do it here.
        if [[ $plotprofileonmapflag -eq 1 ]]; then
          PS_HEIGHT_IN=$MAP_PROF_SPACING

          # Select the flat profiles
          if [[ $MAKE_OBLIQUE_PROFILES -eq 1 ]]; then
            grep "^[P]" ${F_PROFILES}control_file.txt | gawk '{printf("%s_perspective_profile\n", $2)}' > ${F_PROFILES}profile_filenames.txt
          else
            grep "^[P]" ${F_PROFILES}control_file.txt | gawk '{printf("%s_flat_profile\n", $2)}' > ${F_PROFILES}profile_filenames.txt
          fi


          if [[ $showprofallflag -eq 1 ]]; then
            SHOWPROFLIST=($(cat ${F_PROFILES}profile_filenames.txt))
          else
            PROFLIST=($(cat ${F_PROFILES}profile_filenames.txt))
            for profile_number in ${SHOWPROFLIST[@]}; do
              SHOWPROFLIST+=(${PROFLIST[$profile_number]})
            done
          fi

          if [[ $showprofstackedflag -eq 1 ]]; then
            SHOWPROFLIST+=("stacked_profiles")
          fi

          for profile_name in ${SHOWPROFLIST[@]}; do
            # if [[ $profile_number -eq 0 ]]; then
            #   # Find size of ${F_PROFILES}stacked_profiles.ps
            #   PS_DIM=$(gmt psconvert ${F_PROFILES}stacked_profiles.ps -F${F_PROFILES}stacked_profiles -Te -A+m0i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
            #   PS_WIDTH_IN=$(echo $PS_DIM | gawk '{print $1/2.54} ')
            #   PS_WIDTH_SHIFT=$(echo $PS_DIM | gawk -v p_orig=${MAP_PS_WIDTH_NOLABELS_IN} '{print ($1/2.54-(p_orig+0))/2}')
            #   PS_HEIGHT_IN=$(echo $PS_DIM | gawk -v prevheight=$PS_HEIGHT_IN -v vbuf=${MAP_PROF_SPACING} '{print $2/2.54+vbuf + prevheight}')
            #   gmt psimage -Dx"-${PS_WIDTH_SHIFT}i/-${PS_HEIGHT_IN}i"+w${PS_WIDTH_IN}i ${F_PROFILES}stacked_profiles.eps $RJOK ${VERBOSE} >> map.ps
            # else
              # SLURP_PROFID=$(gawk < ${F_PROFILES}profile_filenames.txt -v ind=${profile_number} '(NR==ind) {print}')
              # if [[ -s ${F_PROFILES}$SLURP_PROFID.ps ]]; then
                PS_DIM=$(gmt psconvert ${F_PROFILES}${profile_name}.ps -F${F_PROFILES}${profile_name} -Te -A+m0i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
                PS_WIDTH_IN=$(echo $PS_DIM | gawk '{print $1/2.54} ')
                PS_WIDTH_SHIFT=$(echo $PS_DIM | gawk -v p_orig=${MAP_PS_WIDTH_NOLABELS_IN} '{print ($1/2.54-(p_orig+0))/2}')
                PS_HEIGHT_IN=$(echo $PS_DIM | gawk -v prevheight=$PS_HEIGHT_IN -v vbuf=${MAP_PROF_SPACING} '{print $2/2.54+vbuf + prevheight}')
                gmt psimage -Dx"-${PS_WIDTH_SHIFT}i/-${PS_HEIGHT_IN}i"+w${PS_WIDTH_IN}i ${F_PROFILES}${profile_name}.eps -Xa${PROFILE_X_SHIFT} $RJOK ${VERBOSE} >> map.ps
              # fi
            # fi
          done
        fi
        ;;

      # oceanage)
      #   gmt grdimage $MULLER_OCAGE $GRID_PRINT_RES -C${OCA_CPT} -Q -t$OC_TRANS $RJOK $VERBOSE >> map.ps
      #   ;;

      plateazdiff)
        info_msg "Drawing plate azimuth differences"

        # This should probably be changed to obliquity
        # Plot the azimuth of relative plate motion across the boundary
        # azdiffpts_len.txt should be replaced with id_pts_euler.txt
        [[ $plotplates -eq 1 ]] && gawk  < ${F_PLATES}azdiffpts_len.txt -v minlat="$MINLAT" -v maxlat="$MAXLAT" -v minlon="$MINLON" -v maxlon="$MAXLON" '{
          if ($1 != minlon && $1 != maxlon && $2 != minlat && $2 != maxlat) {
            print $1, $2, $3
          }
        }' | gmt psxy -C$CPTDIR"cycleaz.cpt" -t0 -Sc${AZDIFFSCALE}/0 $RJOK $VERBOSE >> map.ps

        # Break this for now as it is secondary and should probably be a different option
        # mkdir az_histogram
        # cd az_histogram
        #   gawk < ../azdiffpts_len.txt '{print $3, $4}' | gmt pshistogram -C$CPTDIR"cycleaz.cpt" -JX5i/2i -R-180/180/0/1 -Z0+w -T2 -W0.1p -I -Ve > azdiff_hist_range.txt
        #   ADR4=$(gawk < azdiff_hist_range.txt '{print $4*1.1}')
        #   gawk < ../azdiffpts_len.txt '{print $3, $4}' | gmt pshistogram -C$CPTDIR"cycleaz.cpt" -JX5i/2i -R-180/180/0/$ADR4 -BNESW+t"$POLESRC $MINLON/$MAXLON/$MINLAT/$MAXLAT" -Bxa30f10 -Byaf -Z0+w -T2 -W0.1p > ../az_histogram.ps
        # cd ..
        # gmt psconvert -Tf -A0.3i az_histogram.ps
        ;;

      plateedgecolor)

        gmt makecpt -Fr -Ccyclic -D -T-180/180/1 > ${F_CPTS}az.cpt
        if [[ -s ${F_PLATES}segment_obliquity.txt ]]; then
          gmt psxy ${F_PLATES}segment_obliquity.txt -W${PLATELINE_WIDTH}+cl -C${F_CPTS}az.cpt ${RJOK} ${VERBOSE} >> map.ps
        fi
        # Plot segment midpoints for debugging purposes
        # gawk < ${F_PLATES}id_pts_euler_half.txt '{print $1, $2}' | gmt psxy -Sc0.1i -Gorange -W0.3p,black ${RJOK} ${VERBOSE} >> map.ps
        ;;

      platediffv)
        # Plot velocity across plate boundaries
        # Excludes plotting of adjacent points closer than a cutoff distance (Degrees).
        # Plots any point with [lat,lon] values that have already been plotted.
        # input data are in what m/yr
        # Convert to PSVELO?


        info_msg "Drawing plate relative velocities"
        info_msg "velscale=$VELSCALE"
        MINVV=0.15

          gawk -v cutoff=$PDIFFCUTOFF 'BEGIN {dist=0;lastx=9999;lasty=9999} {
            # If we haven not seen this point before
            if (seenx[$1,$2] == 0) {
                seenx[$1,$2]=1
                newdist = ($1-lastx)*($1-lastx)+($2-lasty)*($2-lasty);
                if (newdist > cutoff) {
                  lastx=$1
                  lasty=$2
                  doprint[$1,$2]=1
                  print
                }
              } else {   # print any point that we have already printed
                if (doprint[$1,$2]==1) {
                  print
                }
              }
            }' < ${F_PLATES}paz1normal.txt > ${F_PLATES}paz1normal_cutoff.txt

          gawk -v cutoff=$PDIFFCUTOFF 'BEGIN {dist=0;lastx=9999;lasty=9999} {
            # If we have not seen this point before
            if (seenx[$1,$2] == 0) {
                seenx[$1,$2]=1
                newdist = ($1-lastx)*($1-lastx)+($2-lasty)*($2-lasty);
                if (newdist > cutoff) {
                  lastx=$1
                  lasty=$2
                  doprint[$1,$2]=1
                  print
                }
              } else {   # print any point that we have already printed
                if (doprint[$1,$2]==1) {
                  print
                }
              }
            }' < ${F_PLATES}paz1thrust.txt > ${F_PLATES}paz1thrust_cutoff.txt

            gawk -v cutoff=$PDIFFCUTOFF 'BEGIN {dist=0;lastx=9999;lasty=9999} {
              # If we have not seen this point before
              if (seenx[$1,$2] == 0) {
                  seenx[$1,$2]=1
                  newdist = ($1-lastx)*($1-lastx)+($2-lasty)*($2-lasty);
                  if (newdist > cutoff) {
                    lastx=$1
                    lasty=$2
                    doprint[$1,$2]=1
                    print
                  }
                } else {   # print any point that we have already printed
                  if (doprint[$1,$2]==1) {
                    print
                  }
                }
              }' < ${F_PLATES}paz1ss1.txt > ${F_PLATES}paz1ss1_cutoff.txt

              gawk -v cutoff=$PDIFFCUTOFF 'BEGIN {dist=0;lastx=9999;lasty=9999} {
                # If we have not seen this point before
                if (seenx[$1,$2] == 0) {
                    seenx[$1,$2]=1
                    newdist = ($1-lastx)*($1-lastx)+($2-lasty)*($2-lasty);
                    if (newdist > cutoff) {
                      lastx=$1
                      lasty=$2
                      doprint[$1,$2]=1
                      print
                    }
                  } else {   # print any point that we have already printed
                    if (doprint[$1,$2]==1) {
                      print
                    }
                  }
                }' < ${F_PLATES}paz1ss2.txt > ${F_PLATES}paz1ss2_cutoff.txt

          # If the scale is too small, normal opening will appear to be thrusting due to arrowhead offset...!
          # Set a minimum scale for vectors to avoid improper plotting of arrowheads

          LONDIFF=$(echo "$MAXLON - $MINLON" | bc -l)
          pwnum=$(echo $PLATELINE_WIDTH | gawk '{print $1+0}')
          POFFS=$(echo "$LONDIFF/8*1/72*$pwnum*3/2" | bc -l)

          # Old formatting works but isn't exactly great

          # We plot the half-velocities across the plate boundaries instead of full relative velocity for each plate

          gawk < ${F_PLATES}paz1normal_cutoff.txt -v poff=$POFFS -v minv=$MINVV -v gpsscalefac=$VELSCALE '{ if ($4<minv && $4 != 0) {print $1 + sin($3*3.14159265358979/180)*poff, $2 + cos($3*3.14159265358979/180)*poff, $3, $4*gpsscalefac/2} else {print $1 + sin($3*3.14159265358979/180)*poff, $2 + cos($3*3.14159265358979/180)*poff, $3, $4*gpsscalefac/2}}' | gmt psxy -SV"${PVFORMAT}" -W0p,$PLATEARROW_NORMAL_COLOR@$PLATEARROW_TRANS -G$PLATEARROW_NORMAL_COLOR@$PLATEARROW_TRANS $RJOK $VERBOSE >> map.ps
          gawk < ${F_PLATES}paz1thrust_cutoff.txt -v poff=$POFFS -v minv=$MINVV -v gpsscalefac=$VELSCALE '{ if ($4<minv && $4 != 0) {print $1 - sin($3*3.14159265358979/180)*poff, $2 - cos($3*3.14159265358979/180)*poff, $3, $4*gpsscalefac/2} else {print $1 - sin($3*3.14159265358979/180)*poff, $2 - cos($3*3.14159265358979/180)*poff, $3, $4*gpsscalefac/2}}' | gmt psxy -SVh"${PVFORMAT}" -W0p,$PLATEARROW_THRUST_COLOR@$PLATEARROW_TRANS -G$PLATEARROW_THRUST_COLOR@$PLATEARROW_TRANS $RJOK $VERBOSE >> map.ps

          # # Shift symbols based on azimuth of line segment to make nice strike-slip half symbols
          gawk < ${F_PLATES}paz1ss1_cutoff.txt -v poff=$POFFS -v gpsscalefac=$VELSCALE '{ if ($4!=0) { print $1 + cos($3*3.14159265358979/180)*poff, $2 - sin($3*3.14159265358979/180)*poff, $3, 0.1/2}}' | gmt psxy -SV"${PVHEAD}"+r+jb+m+a33+h0 -W0p,${PLATEARROW_SS_COLOR1}@$PLATEARROW_TRANS -G${PLATEARROW_SS_COLOR1}@$PLATEARROW_TRANS $RJOK $VERBOSE >> map.ps
          gawk < ${F_PLATES}paz1ss2_cutoff.txt -v poff=$POFFS -v gpsscalefac=$VELSCALE '{ if ($4!=0) { print $1 - cos($3*3.14159265358979/180)*poff, $2 - sin($3*3.14159265358979/180)*poff, $3, 0.1/2 }}' | gmt psxy -SV"${PVHEAD}"+l+jb+m+a33+h0 -W0p,${PLATEARROW_SS_COLOR2}@$PLATEARROW_TRANS -G${PLATEARROW_SS_COLOR2}@$PLATEARROW_TRANS $RJOK $VERBOSE >> map.ps
        ;;


      eulerpoles)

        gmt makecpt -Fr -Croma -T0/2/0.01 -Z > ${F_CPTS}polerate.cpt

        if [[ ${#PP_SELECT[@]} -gt 0 ]]; then
          echo "Plotting only selected poles"
          for this_plate in ${PP_SELECT[@]}; do
            polefile=$(ls -1q ${F_PLATES}${this_plate}*.pole | head -n 1)
            echo Polefile is ${polefile}
            if [[ -s ${polefile} ]]; then
              echo "plotting ${polefile}"
              POLEDATA=($(head -n 1 ${polefile}))
              gmt psxy ${polefile} -: -Sc0.1i -C${F_CPTS}polerate.cpt -W1p,black+cf $RJOK $VERBOSE >> map.ps
              printf "%f %f 5p,Helvetica,black 0 TR %s-%s(%0.1f d/M)\n" ${POLEDATA[1]} ${POLEDATA[0]} $(basename ${polefile} | gawk -F_ '{print $1}') $DEFREF ${POLEDATA[2]} >> polelabels.txt
            fi
          done
        else
          for polefile in ${F_PLATES}*.pole; do
            # echo "Plotting pole ${polefile}"
            POLEDATA=($(head -n 1 ${polefile}))
            gmt psxy ${polefile} -: -Sc0.1i -C${F_CPTS}polerate.cpt -W1p,black+cf $RJOK $VERBOSE >> map.ps
            printf "%f %f 5p,Helvetica,black 0 TR %s-%s(%0.1f d/M)\n" ${POLEDATA[1]} ${POLEDATA[0]} $(basename ${polefile} | gawk -F_ '{print $1}') $DEFREF ${POLEDATA[2]} >> polelabels.txt
          done
        fi
        [[ -s polelabels.txt ]] && gmt pstext polelabels.txt -F+f+a+j $RJOK $VERBOSE >> map.ps
      ;;

      plateedge)
        info_msg "Drawing plate edges"
        # Plot edges of plates

        if [[ -s ${F_PLATES}map_plates_clip.txt ]]; then

          # Fix the splitting of plates along the dateline (by simply omitting)
          # line segments that are no good

          gawk < ${F_PLATES}map_plates_clip.txt '
          BEGIN {
            platenum=0
            lastlon180=0
          }
          {
            if ($1==">") {
              platenum++
              plateid[platenum]=$2
              dataindex=1
            } else {
              londata[platenum][dataindex]=$1+0
              latdata[platenum][dataindex]=$2+0
              lengthdata[platenum]=++dataindex
            }
          }
          END {
            # for each plate that we read in

            for(i=1;i<=platenum;i++) {
              # If the start and end points are on the dateline, cut first segment
              if (londata[i][1]==180 && londata[i][lengthdata[i]-1]==180) {
                startid=2
              } else if (londata[i][1]==-180 && londata[i][lengthdata[i]-1]==-180) {
                startid=2
              } else {
                startid=1
              }
              printf("> %s\n", plateid[i])
              last180=0
              for(j=startid; j<lengthdata[i]; j++) {
                # If we are repeating a datline point, skip and add a line
                if (last180==1 && (londata[i][j]==180 || londata[i][j]==-180)) {
                  print ">"
                } else if (latdata[i][j] != 90 && latdata[i][j] != -90) {
                  # If a node is a the pole, start a new line instead of plotting it
                  printf("%s %s\n", londata[i][j], latdata[i][j])
                } else {
                  print ">"
                }
                if (londata[i][j]==180||londata[i][j]==-180) {
                  last180=1
                } else {
                  last180=0
                }
              }
            }
          }' > ${F_PLATES}map_plates_fixed180.txt
          gmt psxy -A ${F_PLATES}map_plates_fixed180.txt -W$PLATELINE_WIDTH,$PLATELINE_COLOR@$PLATELINE_TRANS $RJOK $VERBOSE >> map.ps
        fi
        ;;


      triplejunctions)

        # Find the locations of points that are shared by more than two polygons
        # These are the triple (or quadruple+) junctions.
        gawk < ${EDGES} '
          ($1==">") {
            # We are on a different plate
            platecount++
          }
          ($1+0==$1 && $2+0==$2) {
              # Do not count same points from same plate - these close the plate polygon!
              if (lastcount[$1][$2] != platecount) {
                seen[$1][$2]++
                lastcount[$1][$2]=platecount
              }
          }
          END {
            for (i in seen) {
              for (j in seen[i]) {
                if (seen[i][j] > 2) {
                  print i, j, seen[i][j]
                }
              }
            }
          }' | gmt psxy -St0.075i -W0.75p,black -Gred ${RJOK} >> map.ps
      ;;

      platelabel)
        info_msg "Labeling plates"

        # Label the plates if we calculated the centroid locations
        # Remove the trailing _N from all plate labels
        if [[ $plotplates -eq 1 ]]; then

          if [[ -s ${F_PLATES}plate_id_names.txt && ${PLATELABEL_FULL} -eq 1 ]]; then
            numlabels=$(wc -l < ${F_PLATES}plate_id_names.txt)

            shiftplatelabel=""
            if [[ $numlabels -eq 1 ]]; then
              shiftplatelabel="-Xa-1i -Ya1i"
            fi

            gmt pstext ${F_PLATES}map_labels.txt -C0.1+t -F+f${PLATELABEL_FONT}=1p,white+jCB ${shiftplatelabel} -t50 $RJOK $VERBOSE  >> map.ps
            gmt pstext ${F_PLATES}map_labels.txt -C0.1+t -F+f${PLATELABEL_FONT}+jCB ${shiftplatelabel} $RJOK $VERBOSE  >> map.ps
          else
            gawk  < ${F_PLATES}map_labels.txt -F, '{print $1, $2, substr($3, 1, length($3)-2)}' | gmt pstext -C0.1+t -t50 -F+f${PLATELABEL_FONT}=1p,white+jCB ${shiftplatelabel} $RJOK $VERBOSE  >> map.ps
            gawk  < ${F_PLATES}map_labels.txt -F, '{print $1, $2, substr($3, 1, length($3)-2)}' | gmt pstext -C0.1+t -F+f${PLATELABEL_FONT}+jCB ${shiftplatelabel} $RJOK $VERBOSE  >> map.ps
          fi
        fi
        ;;

      platepolycolor_all)
          plate_files=($(ls ${F_PLATES}*.pldat 2>/dev/null))
          if [[ ${#plate_files} -gt 0 ]]; then
            gmt makecpt -Fr -T0/${#plate_files[@]}/1 -Cwysiwyg ${VERBOSE} | gawk '{print $2}' | head -n ${#plate_files[@]} > ${F_PLATES}platecolor_pre.dat
            randomize_lines 2 ${F_PLATES}platecolor_pre.dat ${F_PLATES}platecolor.dat
            P_COLORLIST=($(cat ${F_PLATES}platecolor.dat))
            this_index=0
            for p_example in ${plate_files[@]}; do
              # echo gmt psxy ${p_example} -G"${P_COLORLIST[$this_index]}" -t${P_POLYTRANS} $RJOK ${VERBOSE}
              gmt psxy ${p_example} -G"${P_COLORLIST[$this_index]}" -t${P_POLYTRANS} $RJOK ${VERBOSE} >> map.ps
              this_index=$(echo "$this_index + 1" | bc)
            done
          else
            info_msg "[-pc]: No plate files found."
          fi
        ;;

      platepolycolor_list)
        declare -p P_POLYLIST
        numplatepoly=$(echo "${#P_POLYLIST[@]}-1" | bc)
        for p_index in $(seq 0 $numplatepoly); do
          plate_files=($(ls ${F_PLATES}${P_POLYLIST[$p_index]}_*.pldat 2>/dev/null))
          if [[ ${#plate_files} -gt 0 ]]; then
            for p_example in ${plate_files[@]}; do
              gmt psxy ${p_example} -G${P_COLORLIST[$p_index]} -t${P_POLYTRANS[$p_index]} $RJOK ${VERBOSE} >> map.ps
            done
          else
            info_msg "Plate file ${P_POLYLIST[$p_index]} does not exist."
          fi
        done
        ;;

      platerelvel)
        cat ${F_PLATES}paz1*.txt > ${F_PLATES}all.txt
        gmt psxy ${F_PLATES}all.txt -Sc0.1i -C$PLATEVEL_CPT -i0,1,3 $RJOK >> map.ps

        # gmt psxy paz1ss2.txt -Sc0.1i -Cpv.cpt -i0,1,3 $RJOK >> map.ps
        # gmt psxy paz1normal.txt -Sc0.1i -Cpv.cpt -i0,1,3 $RJOK >> map.ps
        # gmt psxy paz1thrust.txt -Sc0.1i -Cpv.cpt -i0,1,3 $RJOK >> map.ps
        ;;

      platerotation)
        info_msg "Plotting small circle rotations"

        # Plot small circles and little arrows for plate rotations
        for i in ${F_PLATES}*_smallcirc_platevecs.txt; do
          cat $i | gawk -v scalefac=0.01 '{ az=atan2($3, $4) * 180 / 3.14159265358979; if (az > 0) print $1, $2, az, scalefac; else print $1, $2, az+360, scalefac; }' > ${i}.pvec
          gmt psxy -SV0.0/0.12/0.06 -: -W0p,$PLATEVEC_COLOR@70 -G$PLATEVEC_COLOR@70 ${i}.pvec -t70 $RJOK $VERBOSE >> map.ps
        done
        for i in ${F_PLATES}*smallcircles_clip; do
         info_msg "Plotting small circle file ${i}"
         cat ${i} | gmt psxy -W1p,${PLATEVEC_COLOR}@50 -t70 $RJOK $VERBOSE >> map.ps
        done
        ;;

      platevelgrid)
        # Probably should move the calculation to the calculation zone of the script
        # Plot a colored plate velocity grid
        info_msg "Calculating plate velocity grids"
        mkdir -p pvdir
        mkdir -p pvdir/${F_PLATES}

        MAXV_I=0
        MINV_I=99999

        for i in ${F_PLATES}*.pole; do
          LEAD=${i%.pole*}
          # info_msg "i is $i LEAD is $LEAD"
          info_msg "Calculating $LEAD velocity raster"
          gawk < $i '{print $2, $1}' > pvdir/pole.xy
          POLERATE=$(gawk < $i '{print $3}')
          cat "$LEAD.pldat" | sed '1d' > pvdir/plate.xy

          cd pvdir
          # # Determine the latitude/longitude extent of the polygon within the map extent
          pl_max_x=$(grep "^[-*0-9]" plate.xy | sort -n -k 1 | tail -n 1 | gawk -v mx=$MAXLON '{print ($1>mx)?mx:$1}')
          pl_min_x=$(grep "^[-*0-9]" plate.xy | sort -n -k 1 | head -n 1 | gawk -v mx=$MINLON '{print ($1<mx)?mx:$1}')
          pl_max_y=$(grep "^[-*0-9]" plate.xy | sort -n -k 2 | tail -n 1 | gawk -v mx=$MAXLAT '{print ($2>mx)?mx:$2}')
          pl_min_y=$(grep "^[-*0-9]" plate.xy | sort -n -k 2 | head -n 1 | gawk -v mx=$MINLAT '{print ($2<mx)?mx:$2}')
          info_msg "Polygon region $pl_min_x/$pl_max_x/$pl_min_y/$pl_max_y"

          # this approach requires a final GMT grdblend command

          # Calculate the velocity of a rectangular grid encompassing the plate, assuming a spherical earth
          # Note: The -I has option +e to suppress warnings

          gmt grdmath ${VERBOSE} -R$pl_min_x/$pl_max_x/$pl_min_y/$pl_max_y -fg -I$PLATEVELRES+e pole.xy PDIST 6378.13696669 DIV SIN $POLERATE MUL 6378.13696669 MUL .01745329251944444444 MUL = "$LEAD"_velraster.nc

          # Mask out the velocities that are not on the plate
          gmt grdmask plate.xy ${VERBOSE} -R"$LEAD"_velraster.nc -fg -NNaN/1/1 -Gmask.nc
          info_msg "Calculating $LEAD masked raster"
          gmt grdmath -fg ${VERBOSE} "$LEAD"_velraster.nc mask.nc MUL = "$LEAD"_masked.nc
          cd ../
        done

        info_msg "Merging velocity rasters"

        PVRESNUM=$(echo "" | gawk -v v=$PLATEVELRES 'END {print v+0}')
        info_msg "gdal_merge.py -o plate_velocities.nc -of NetCDF -ps $PVRESNUM $PVRESNUM -ul_lr $MINLON $MAXLAT $MAXLON $MINLAT ${F_PLATES}*_masked.nc"
        cd pvdir
          gdal_merge.py -o plate_velocities.nc -q -of NetCDF -ps $PVRESNUM $PVRESNUM -ul_lr $MINLON $MAXLAT $MAXLON $MINLAT ${F_PLATES}*_masked.nc
          # Fill NaNs with nearest neighbor
          info_msg "Filling NaN values in plate velocity raster"
          gmt grdfill plate_velocities.nc -An -Gfilled_plate_velocities.nc ${VERBOSE}
          mv filled_plate_velocities.nc plate_velocities.nc
          zrange=$(grid_zrange plate_velocities.nc -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT})
        cd ..

        info_msg "Velocities range: $zrange"

        # Turn of rescaling for now

        # # This isn't working because I can't seem to read the max values from this raster this way or with gdalinfo
        # if [[ $rescaleplatevecsflag -eq 1 ]]; then
        #   MINV=$(echo $zrange | gawk  '{ print int($1/10)*10 }')
        #   MAXV=$(echo $zrange | gawk  '{ print int($2/10)*10 +10 }')
        #   echo MINV MAXV $MINV $MAXV
        #   gmt makecpt -C$CPTDIR"platevel_one.cpt" -T0/$MAXV -Z > $PLATEVEL_CPT
        # else
        # fi

        # cd ..
        info_msg "Plotting velocity raster."

        gmt grdimage ./pvdir/plate_velocities.nc -C$PLATEVELGRID_CPT $GRID_PRINT_RES $RJOK $VERBOSE >> map.ps
        info_msg "Plotted velocity raster."
        ;;

      polygonaoi)
        info_msg "Plotting polygon AOI"
        gmt psxy ${POLYGONAOI} -L -W0.5p,black $RJOK ${VERBOSE} >> map.ps
        ;;

      refpoint)
        info_msg "Plotting reference point"

        if [[ $REFPTLON == "" || $REFPTLAT == "" ]]; then
          REFPTLON=${CENTERLON}
          REFPTLAT=${CENTERLAT}
        fi

        if [[ $refptflag -eq 1 ]]; then
        # Plot the reference point as a circle around a triangle
          echo $REFPTLON $REFPTLAT| gmt psxy -W0.1,black -Gblack -St0.05i $RJOK $VERBOSE >> map.ps
          echo $REFPTLON $REFPTLAT| gmt psxy -W0.1,black -Sc0.1i $RJOK $VERBOSE >> map.ps
        fi
        ;;

      ztarget)
          # Find the relevant item in eqs.txt
          gawk < ${F_SEIS}eqs_precull.txt -v id=${EQID} '($6==id){ print; exit }' > ztarget.cat

          ztargetloc=($(gawk -F, < ztarget.cat '{print $1, $2}'))


          echo ${ztargetloc[@]} | gmt psxy -Skcircle/43p -W4p,white@40  ${RJOK} ${VERBOSE} >> map.ps
          echo ${ztargetloc[@]} | gmt psxy -Skcircle/29p -W4p,white@40  ${RJOK} ${VERBOSE} >> map.ps

          echo ${ztargetloc[@]} | gmt psxy -Skcircle/50p -W2.5p,black@50 ${RJOK} ${VERBOSE} >> map.ps
          echo ${ztargetloc[@]} | gmt psxy -Skcircle/36p -W3.5p,black@40  ${RJOK} ${VERBOSE} >> map.ps
          echo ${ztargetloc[@]} | gmt psxy -Skcircle/22p -W4p,black@30  ${RJOK} ${VERBOSE} >> map.ps
      ;;

      zbox)
          # Find the relevant item in seismicity catalogs
          ZBOX_WIDTH=3
          just="BL"

# 1991-10-11T02:26:29.000Z, 21.926, 105.213, 10, 4.1, mb,,,,1.4,us,usp0004xnq,2014-11-07T00:49:23.288Z,"11 km N of Tuyên Quang, Vietnam",earthquake,,,,2,reviewed,us,us

          # create a shapefile with the query point
          # echo "Lon,Lat" > time.csv
          # echo "${REGION_EQ_LON},${REGION_EQ_LAT}" >> time.csv
          # ogr2ogr -s_srs EPSG:4326 -t_srs EPSG:4326 -oo X_POSSIBLE_NAMES=Lon* -oo Y_POSSIBLE_NAMES=Lat*  -f "ESRI Shapefile" mytime.shp time.csv

          # If the time zone shapefile still has hyphens in its name

          # Query the time zone shapefile
          if [[ -s ${TIMEZONESHP} ]]; then
            ogr2ogr -f "CSV" mytime_selected.csv ${TIMEZONESHP} -dialect sqlite -sql "select tzid from \"combined-shapefile-with-oceans\" where within(GeomFromText('POINT(${REGION_EQ_LON} ${REGION_EQ_LAT})'),\"combined-shapefile-with-oceans\".Geometry)"
            timezone=$(tail -n 1 mytime_selected.csv)
            loctime=$(echo "${REGION_EQ_TIME}" | localtime_from_utc ${timezone})
          else
            loctime="none"
          fi

          gawk -v id=${REGION_EQ} -v origtime=${REGION_EQ_TIME} -v lon=${REGION_EQ_LON} -v lat=${REGION_EQ_LAT} -v loctime=${loctime} -v source=${REGION_EQ_AUTHOR} -v depth=${REGION_EQ_DEPTH} -v mag=${REGION_EQ_MAG} -v magtype=${REGION_EQ_MAGTYPE} '
          BEGIN {
              month["01"]="January"
              month["02"]="February"
              month["03"]="March"
              month["04"]="April"
              month["05"]="May"
              month["06"]="June"
              month["07"]="July"
              month["08"]="August"
              month["09"]="September"
              month["10"]="October"
              month["11"]="November"
              month["12"]="December"

              split(origtime, a, "T")
              split(a[1], b, "-")

              print "L 12p,AvantGarde-Book L @%15%" b[3] " " month[b[2]] " " b[1] " " substr(a[2],1,8) " (UTC)@%%"
              print "L 12p,AvantGarde-Book L @%15%Magnitude: " mag " (" magtype ")@%%"

              print "G 0.1i"
              if (loctime != "none") {
                split(loctime, a2, "T")
                split(a2[1], b2, "-")
                print "L 10p,Times-Roman L Local time: " b2[3] " " month[b2[2]] " " b2[1] " " substr(a2[2],1,8)
              }
              print "L 10p,Times-Roman L Longitude: " lon "@.  Latitude: " lat "@."
              print "L 10p,Times-Roman L Depth: " depth " km"
              print "L 10p,Times-Roman L Event ID: " id " (source: " toupper(source) ")"

          }' > zbox.box

          # echo "${REGION_EQ_LON} ${REGION_EQ_LAT} 10p,Helvetica,black 0 ${just} " | gmt pstext -Dj0.5i+v0.7p,black -F+f+a+j ${RJOK} ${VERBOSE} >> map.ps
          # gmt pslegend zbox.box -F+gwhite+s+p -Dg${REGION_EQ_LON}/${REGION_EQ_LAT}+o0.5i+j${just} -C0.05i/0.05i --FONT_ANNOT_PRIMARY=10p,Helvetica,black ${RJOK} ${VERBOSE} >> map.ps
          gmt pslegend zbox.box -F+gwhite+p -DjTL -C0.1i/0.1i --FONT_ANNOT_PRIMARY=10p,Helvetica,black ${RJOK} ${VERBOSE} >> map.ps
      ;;

      seis)

        if [[ $dontplotseisflag -eq 0 ]]; then

          info_msg "Plotting seismicity; should include options for CPT/fill color"

          if [[ $zcclusterplotlinesflag -eq 1 && -s ${F_SEIS}cluster_lines.txt ]]; then
            gmt psxy ${F_SEIS}cluster_lines.txt -C$SEIS_CPT -W0.1p+z ${RJOK} ${VERBOSE} -t50 >> map.ps
          fi

          if [[ $REMOVE_DEFAULTDEPTHS_WITHPLOT -eq 1 && -s ${F_SEIS}removed_eqs_scaled.txt ]]; then
            cat ${F_SEIS}removed_eqs.txt | gmt_psxy scale ${SEISSCALE} stretch ${SEISSTRETCH} refmag ${SEISSTRETCH_REFMAG} cpt ${SEIS_CPT} trans ${SEISTRANS} stroke ${EQLINEWIDTH},darkgray ${RJOK} ${VERBOSE} >> map.ps
          fi

          if [[ -s ${F_SEIS}eqs.txt ]]; then
            cat ${F_SEIS}eqs.txt | gmt_psxy scale ${SEISSCALE} stretch ${SEISSTRETCH} refmag ${SEISSTRETCH_REFMAG} cpt ${SEIS_CPT} zcol ${SEIS_ZCOL} trans ${SEISTRANS} stroke ${EQLINEWIDTH},${EQLINECOLOR} ${RJOK} ${VERBOSE} >> map.ps
          fi

          if [[ $zhighlightflag -eq 1 ]]; then
            for this_z in ${zhigh[@]}; do
                grep ${this_z} ${F_SEIS}eqs.txt | gmt_psxy scale ${SEISSCALE} stretch ${SEISSTRETCH} refmag ${SEISSTRETCH_REFMAG} stroke 2p,black cpt ${SEIS_CPT} zcol ${SEIS_ZCOL} $RJOK $VERBOSE >> map.ps
            done
          fi
        fi

  			;;

      seissum)

        # Convert Mw to M0 and sum within grid nodes, then take the log10 and plot.

        if [[ $SSUNIFORM -eq 1 ]]; then
          # Use a magnitude of 4 for all events
          gawk < ${F_SEIS}eqs.txt '{print $1, $2, 1}' | gmt blockmean -Ss -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} -I${SSRESC} -G${F_SEIS}seissum.nc ${VERBOSE}
          gmt grd2cpt -Qo -I -Chot ${F_SEIS}seissum.nc ${VERBOSE} > ${F_CPTS}seissum.cpt
          gmt grdimage ${F_SEIS}seissum.nc -C${F_CPTS}seissum.cpt -Q ${RJSTRING} -O -K ${VERBOSE} -t${SSTRANS} >> map.ps
        else
          # Use the true magnitude for all events
          gawk < ${F_SEIS}eqs.txt '{print $1, $2, 10^(($4+10.7)*3/2)}' | gmt blockmean -Ss -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} -I${SSRESC} -G${F_SEIS}seissum.nc ${VERBOSE}
          gmt grdmath ${VERBOSE} ${F_SEIS}seissum.nc LOG10 = ${F_SEIS}seisout.nc
          gmt grd2cpt -Qo -I -Chot ${F_SEIS}seisout.nc ${VERBOSE} > ${F_CPTS}seissum.cpt
          gmt grdimage ${F_SEIS}seisout.nc -C${F_CPTS}seissum.cpt -Q ${RJSTRING} -O -K ${VERBOSE} -t${SSTRANS} >> map.ps
        fi

        ;;

      # slab2)
      #
      #   if [[ ${SLAB2STR} =~ .*d.* ]]; then
      #     info_msg "Plotting SLAB2 depth grids"
      #     SLAB2_CONTOUR_BLACK=1
      #     for i in $(seq 1 $numslab2inregion); do
      #       gridfile=$(echo ${SLAB2_GRIDDIR}${slab2inregion[$i]}.grd | sed 's/clp/dep/')
      #       if [[ -e $gridfile ]]; then
      #         gmt grdmath ${VERBOSE} $gridfile -1 MUL = tmpgrd.grd
      #         gmt grdimage tmpgrd.grd -Q -t${SLAB2GRID_TRANS} -C$SEISDEPTH_CPT $RJOK $VERBOSE >> map.ps
      #         rm -f tmpgrd.grd
      #       fi
      #     done
      #   else
      #     SLAB2_CONTOUR_BLACK=0
      #   fi
      #
  		# 	if [[ ${SLAB2STR} =~ .*c.* ]]; then
  		# 		info_msg "Plotting SLAB2 contours"
      #     for i in $(seq 1 $numslab2inregion); do
      #       contourfile=$(echo ${SLAB2_CONTOURDIR}${slab2inregion[$i]}_contours.in | sed 's/clp/dep/')
      #       if [[ -s $contourfile ]]; then
      #         gawk < $contourfile '{
      #           if ($1 == ">") {
      #             print $1, "-Z" 0-$2
      #           } else {
      #             print $1, $2, 0 - $3
      #           }
      #         }' > contourtmp.dat
      #         if [[ -s contourtmp.dat ]]; then
      #           if [[ $SLAB2_CONTOUR_BLACK -eq 0 ]]; then
      #             gmt psxy contourtmp.dat -C$SEISDEPTH_CPT -W0.5p+z $RJOK $VERBOSE >> map.ps
      #           else
      #             gmt psxy contourtmp.dat -W0.5p,black+z $RJOK $VERBOSE >> map.ps
      #           fi
      #         fi
      #       fi
      #     done
      #     rm -f contourtmp.dat
  		# 	fi
  		# 	;;

      slipvecs)
        info_msg "Slip vectors"
        # Plot a file containing slip vector azimuths
        gawk < ${SVDATAFILE} '($1 != "end") {print $1, $2, $3, 0.2}' | gmt psxy -SV0.05i+jc -W1.5p,blue $RJOK $VERBOSE >> map.ps
        ;;

      slipvecs_scale)
        info_msg "Slip vectors"
        # Plot a file containing slip vector azimuths
        gawk < ${SVDATAFILE} -v field=${SVSCALEFIELD} '($1 != "end") {print $1, $2, $3, $(field)}' | gmt psxy -SV0.05i+jc -W1.5p,red $RJOK $VERBOSE >> map.ps
        ;;

      text)
        if [[ $TEXTDEFAULT -eq 1 ]]; then
          gawk < ${TEXTFILE} '{
            print $1, $2, "10p,Helvetica,black 0 ML", $3
          }' > text.tmp
          gmt pstext text.tmp -D${TEXTXOFF}/${TEXTYOFF}${TEXTLINE} ${TEXTBOX} -F+f+a+j  $RJOK $VERBOSE >> map.ps

        else
          gmt pstext ${TEXTFILE} -D${TEXTXOFF}/${TEXTYOFF}${TEXTLINE} ${TEXTBOX} -F+f+a+j  $RJOK $VERBOSE >> map.ps

        fi
        # gmt pstext ${TEXTFILE} -Xa${TEXTXOFF} -Ya${TEXTYOFF} ${TEXTBOX} -F+f+a+j  $RJOK $VERBOSE >> map.ps
        # -Dj-0.05i/0.025i+v0.7p,black
      ;;

      ztext)

        if [[ -s ${F_SEIS}eqs.txt ]]; then
          gawk < ${F_SEIS}eqs.txt -v minmag=${ZTEXT_MINMAG} -v yearflag=${ztextyearflag} '
          ($4 >= minmag) {
            print $1, $2, (yearflag==1)?substr($5,1,4):int($4*10)/10
          }' | gmt pstext -F+f5p,Helvetica,black=~0.5,white+jCM -t20 ${RJOK} ${VERBOSE} >> map.ps
        fi
      ;;


      tmultcolor)
        if [[ -s ${F_TOPO}dem.tif ]]; then

          TMULT_Z_FACTOR=0.5
          TMULT_MULFACT=$(echo "1 / $TMULT_Z_FACTOR * 111120" | bc -l)

          gdaldem hillshade -q -alt ${TMULT_COLOR_ALT} -az ${TMULT_COLOR_AZ} -s ${MULFACT} ${F_TOPO}dem.tif ${F_TOPO}315.tif
          gdaldem hillshade -q -alt ${TMULT_COLOR_ALT} -az $(echo "scale=0; (${TMULT_COLOR_AZ} + 120) % 360" | bc -l) -s ${MULFACT} ${F_TOPO}dem.tif ${F_TOPO}195.tif
          gdaldem hillshade -q -alt ${TMULT_COLOR_ALT} -az $(echo "scale=0; (${TMULT_COLOR_AZ} + 240) % 360" | bc -l) -s ${MULFACT} ${F_TOPO}dem.tif ${F_TOPO}75.tif
          gdal_merge.py -q -separate -o ${F_TOPO}mhs.tif ${F_TOPO}315.tif ${F_TOPO}195.tif ${F_TOPO}75.tif
          gmt grdimage ${F_TOPO}mhs.tif -t${TMULT_COLOR_TRANS} ${RJOK} ${VERBOSE} >> map.ps
        fi
      ;;

      bluemarble)

          gmt_init_tmpdir

          gmt grdmath -Rd -I${IMBLUE_RES} -r $(gmt solar -C -o0:1 -I+d2000-06-22T24:00+z-10) 2 DAYNIGHT = w.grd
          gmt grdcut @earth_day_${IMBLUE_RES} -Gearthday_pct.tif ${RJSTRING} ${VERBOSE}
          gmt grdcut @earth_night_${IMBLUE_RES} -Gearthnight_pct.tif ${RJSTRING} ${VERBOSE}

          gmt grdcut w.grd -Rearthnight_pct.tif -Gwout.grd


          pct2rgb.py earthday_pct.tif earthday_prescale.tif >/dev/null 2>&1 && rm -f earthday_pct.tif
          pct2rgb.py earthnight_pct.tif earthnight.tif >/dev/null 2>&1 && rm -f earthnight_pct.tif
          gdal_translate -scale 20 180 0 255 -ot Byte earthday_prescale.tif earthday.tif
          # gdalwarp -r cubic -ot Byte earthday_prescale.tif earthday.tif

          smooth_rgb_tiff earthday.tif earthdaysmooth.tif
          # gmt grdfilter earthday.tif -Dp -Fg3 -Gearthdaysmooth.tif
          gmt grdmix earthdaysmooth.tif earthnight.tif -Wwout.grd -Gearthcombo.tif


          # pct2rgb.py earthday_pct.tif earthday_prescale.tif >/dev/null 2>&1 && rm -f earthday_pct.tif
          # gdal_translate -of GTiff -ot Byte -scale 20 210 0 255 earthday_prescale.tif earthday.tif
        gmt_remove_tmpdir

        if [[ $imbluedontplotimageflag -ne 1 ]]; then
          gmt grdimage earthcombo.tif ${RJOK} ${VERBOSE} >> map.ps
        fi


      ;;

      topo)

     # Somehow, we need to handle the case where no topo is plotted but Sentinel
     # data are plotted.

     # This section should probably be outsourced to a separate script or function
     # to allow equivalent DEM visualization for along-profile DEMs, etc.
     # Requires: dem.nc sentinel_img.jpg TOPO_CPT
     # Variables: topoctrlstring MINLON/MAXLON/MINLAT/MAXLAT P_IMAGE F_TOPO *_FACT
     # Flags: FILLGRIDNANS SMOOTHGRID ZEROHINGE

      # echo gdalinfo ${F_TOPO}dem.tif
     rasterinfo=($(gdalinfo ${F_TOPO}dem.tif | grep "Size is" | gawk '{print substr($3,1,length($3)-1), $4}'))
     info_msg "[-t]: dpi is $(echo "$rasterinfo / ${PSSIZE}" | bc)"
     # info_msg "[-t]: topography dpi is $(echo "")"

     # if [[ -s osmcoasts.gmt && ${OSM_FIXDEMFLAG} -eq 1 ]]; then
     #   info_msg "[-aosm]: Setting land polygons in DEM to positive"
     #   ogr2ogr -a_srs "EPSG:4326" -s_srs "EPSG:4326" -nlt POLYGON osmcoasts.shp osmcoasts.gmt
     #   rasterinfo=($(gdalinfo ${F_TOPO}dem.tif | grep "Size is" | gawk '{print substr($3,1,length($3)-1), $4}'))
     #   # rasterinfo=($(gdalinfo ${F_TOPO}dem.tif | grep "Pixel Size" | gawk 'function abs(a) { return (a>$1)?a:-a } {str1=substr($4,2,length($4)-2); split(str1,a,","); if (substr(a[2],1,1)=="-") { a[2]=substr(a[2],2,length(a[2])); print a[1], a[2]} }'))
     #   # gdal_rasterize -a_srs "EPSG:4326" -at -te ${MINLON} ${MINLAT} ${MAXLON} ${MAXLAT} -burn 1 -tr ${rasterinfo[0]} ${rasterinfo[1]} osmcoasts.shp shapemask.tif
     #   gdal_rasterize -q -a_srs "EPSG:4326" -at -te ${MINLON} ${MINLAT} ${MAXLON} ${MAXLAT} -burn 1 -ts ${rasterinfo[0]} ${rasterinfo[1]} osmcoasts.shp shapemask.tif
     #   gdal_calc.py --quiet --format=GTiff -A shapemask.tif -B ${F_TOPO}dem.tif --calc="((A==1)*(B>=0)*B + (A==1)*(B<0)*1 + (A==0)*B)" --outfile=fixeddem.tif
     #   # gdal_calc.py --overwrite --type=Float32 --format=GTiff --quiet -A ${BATHY} -B ${F_TOPO}neg.tif --calc="((A>=${GMRT_MERGELEVEL})*A + (A<${GMRT_MERGELEVEL})*B)" --outfile=merged.tif
     #   [[ -s fixeddem.tif ]] && mv fixeddem.tif ${F_TOPO}dem.tif
     # fi


        if [[ $FILLGRIDNANS_CLOSEST -eq 1 ]]; then
         info_msg "Filling topo grid file NaN values with nearest non-NaN value"
         gmt grdfill ${TOPOGRAPHY_DATA} -An -G${F_TOPO}dem_no_nan.tif=gd:GTiff ${VERBOSE}
         TOPOGRAPHY_DATA=${F_TOPO}dem_no_nan.tif
        elif [[ $FILLGRIDNANS_SPLINE -eq 1 ]]; then
         info_msg "Filling topo grid file NaN values using spline with tension $FILLGRIDNANS_SPLINE_TENSION"
         gmt grdfill ${TOPOGRAPHY_DATA} -As${FILLGRIDNANS_SPLINE_TENSION} -G${F_TOPO}dem_no_nan.tif=gd:GTiff ${VERBOSE}
         TOPOGRAPHY_DATA=${F_TOPO}dem_no_nan.tif
        elif [[ $FILLGRIDNANS_VALUE -eq 1 ]]; then
         info_msg "Filling topo grid file NaN values with constant value ${FILLGRIDVALUE}"
         gmt grdfill ${TOPOGRAPHY_DATA} -Ac${FILLGRIDVALUE} -G${F_TOPO}dem_no_nan.tif=gd:GTiff ${VERBOSE}
         TOPOGRAPHY_DATA=${F_TOPO}dem_no_nan.tif
        fi

        if [[ $DEM_SMOOTH_FLAG -eq 1 ]]; then
         info_msg "[-tsmooth]: Smoothing DEM"
         # MODIFIED DEM DATA FILE
         gmt grdfilter -D2 -Fg${DEM_SMOOTH_RAD} ${TOPOGRAPHY_DATA} -fg -G${F_TOPO}dem_smooth.tif=gd:GTiff
         TOPOGRAPHY_DATA=${F_TOPO}dem_smooth.tif
        fi

        plottedtopoflag=1
        if [[ $fasttopoflag -eq 0 ]]; then   # If we are doing more complex topo visualization

          # Look for the saved final image

          info_msg "Looking for topoimg_${BATHYMETRY}_${MINLON}_${MAXLON}_${MINLAT}_${MAXLAT}_${topoctrlstring}.tif"

          # If we are loading a saved image for a region, do so.
          if [[ $tloadflag -eq 1 && $usingcustomregionflag -eq 1 ]]; then
            COLORED_RELIEF=${SAVEDTOPODIR}${CUSTOMREGIONID}.tif

            if [[ ! -s ${COLORED_RELIEF} ]]; then
              info_msg "Saved topo for region ${CUSTOMREGIONID} (${COLORED_RELIEF}) does not exist. Not plotting topo."
              dontplottopoflag=1
            fi
          # Otherwise, calculate the colored relief.
        ### -tnoload is currently turned off
        elif [[ $toponoloadflag -ne 0 && -s ${SAVEDTOPODIR}topoimg_${BATHYMETRY}_${MINLON}_${MAXLON}_${MINLAT}_${MAXLAT}_${topoctrlstring}.tif ]]; then
            info_msg "Found saved image... using"
            COLORED_RELIEF=${SAVEDTOPODIR}topoimg_${BATHYMETRY}_${MINLON}_${MAXLON}_${MINLAT}_${MAXLAT}_${topoctrlstring}.tif
          else
            # If a topography dataset exists, then...
            if [[ -s ${TOPOGRAPHY_DATA} ]]; then


              # If we are visualizing Sentinel imagery, resample DEM to match the resolution of sentinel_img.jpg
              if [[ ${topoctrlstring} =~ .*p.* && ${P_IMAGE} =~ "sentinel_img.jpg" ]]; then
                  # Absolute path is needed here as GMT 6.1.1 breaks for a relative path... BUG?
                  sentinel_dim=($(gdalinfo sentinel_img.jpg | grep "Size is" | sed 's/,//' | gawk '{print $3, $4}'))

                  sent_dimx=${sentinel_dim[0]}
                  sent_dimy=${sentinel_dim[1]}

                  dem_dim=($(gmt grdinfo ${TOPOGRAPHY_DATA} -C -L -Vn))
                  dem_dimx=${dem_dim[9]}
                  dem_dimy=${dem_dim[10]}

                  if [[ $SENTINEL_DOWNSAMPLE -eq 1 ]]; then
                    info_msg "Resampling DEM to match downloaded Sentinel image size"
                    gdalwarp -r bilinear -of GTiff -q -te ${DEM_MINLON} ${DEM_MINLAT} ${DEM_MAXLON} ${DEM_MAXLAT} -ts ${sent_dimx} ${sent_dimy} ${TOPOGRAPHY_DATA} ${F_TOPO}dem_warp.tif
                    # gdalwarp nukes the z values for some stupid reason leaving a raster that GMT interprets as all 0s
                    # cp ${F_TOPO}dem.tif ${F_TOPO}demold.nc
                    rm -f ${F_TOPO}dem.tif
                    gmt grdcut ${F_TOPO}dem_warp.tif -R${F_TOPO}dem_warp.tif -G${F_TOPO}dem.tif ${VERBOSE}
                    TOPOGRAPHY_DATA=${F_TOPO}dem.tif
                  else
                    info_msg "Resampling Sentinel image to match DEM resolution"
                    gdalwarp -r bilinear -q -ts ${dem_dimx} ${dem_dimy} ./sentinel_img.jpg ./sentinel_warp.jpg
                    # gdalwarp nukes the z values for some stupid reason leaving a raster that GMT interprets as all 0s
                    cp ./sentinel_warp.tif ./sentinel_img.jpg
                    # gmt grdcut ${F_TOPO}dem_warp.nc -R${F_TOPO}dem_warp.nc -G${F_TOPO}dem.tif=gd:GTiff ${VERBOSE}
                  fi

                  # # If we have set a specific flag, then calculate the average color of areas at or below zero
                  # # elevation and set all cells in sentinel_img.jpg to that color (to make a uniform ocean color?)
                  # if [[ $sentinelrecolorseaflag -eq 1 ]]; then
                  #   info_msg "Recoloring sea areas of Sentinel image"
                  #   gmt grdinfo ${F_TOPO}dem.tif
                  #   gmt grdinfo ./sentinel_img.jpg
                  #   recolor_sea ${F_TOPO}dem.tif ./sentinel_img.jpg ${SENTINEL_RECOLOR_R} ${SENTINEL_RECOLOR_G} ${SENTINEL_RECOLOR_B} ./sentinel_recolor.jpg
                  #   mv ./sentinel_recolor.jpg ./sentinel_img.jpg
                  # fi


              fi



              if [[ $SMOOTHGRID -eq 1 ]]; then
                info_msg "Smoothing grid before DEM calculations"
                # Not implemented
              fi

              CELL_SIZE=$(gmt grdinfo -C ${TOPOGRAPHY_DATA} -Vn | gawk '{print $8}')
              info_msg "Grid cell size = ${CELL_SIZE}"
              # We now do all color ramps via gdaldem and derive intensity maps from
              # the selected procedures. We fuse them using gdal_calc.py. This gives us
              # a more streamlined process for managing CPTs, etc.

              if [[ $ZEROHINGE -eq 1 ]]; then
                # We need to make a gdal color file that respects the CPT hinge value (usually 0)
                # gdaldem is a bit funny about coloring around the hinge, so do some magic to make
                # the color from land not bleed to the hinge elevation.
                # CPTHINGE=0

                replace_gmt_colornames_rgb ${TOPO_CPT} ${CPTHINGE} > ./cpttmp.cpt
                cpt_to_gdalcolor ./cpttmp.cpt 0 > ${F_CPTS}topocolor.dat
                rm -f ./cpttmp.cpt

                # gawk < $TOPO_CPT -v hinge=$CPTHINGE '{
                #   if ($1 != "B" && $1 != "F" && $1 != "N" ) {
                #     if (count==1) {
                #       print $1+0.01, $2
                #       count=2
                #     } else {
                #       print $1, $2
                #     }
                #
                #     if ($3 == hinge) {
                #       if (count==0) {
                #         print $3-0.0001, $4
                #         count=1
                #       }
                #     }
                #   }
                # }' | tr '/' ' ' | gawk '{
                #   if ($2==255) {$2=254.9}
                #   if ($3==255) {$3=254.9}
                #   if ($4==255) {$4=254.9}
                #   print
                # }' > ${F_CPTS}topocolor.dat
              else
                replace_gmt_colornames_rgb ${TOPO_CPT} > ./cpttmp.cpt
                cpt_to_gdalcolor ./cpttmp.cpt 0 > ${F_CPTS}topocolor.dat
                # gawk < $TOPO_CPT '{ print $1, $2 }' | tr '/' ' ' > ${F_CPTS}topocolor.dat
              fi
            fi
            # ########################################################################
            # Create and render a colored shaded relief map using a topoctrlstring
            # e.g. command string = "csmhvdtg"


            # a = custom intensity from grid data                              [WEIGHTED AVE]
            # b = set intensity to white based on DEM
            # c = color stretch  [ DEM_ALPHA CPT_NAME HINGE_VALUE HIST_EQ ]    [MULTIPLY]
            # d = cast shadows [ SUN_ELEV SUN_AZ ]                             [MULTIPLY]
            # g = stretch/gamma on intensity [ HS_GAMMA ]                      [DIRECT]
            # h = unidirectional hillshade (gdaldem)  [ SUN_ELEV SUN_AZ ]      [WEIGHTED AVE]
            # i = terrain ruggedness index                                     [WEIGHTED AVE]
            # m = multiple hillshade (gdaldem)  [ SUN_ELEV ]                   [WEIGHTED AVE]
            # p = use TIFF image(s) instead of color stretch
            # q = height above local quantile                                  [WEIGHTED AVE]
            # s = slope map                                                    [WEIGHTED AVE]
            # t = texture shade [ TFRAC TSTRETCH ]                             [WEIGHTED AVE]
            # u = tunsetflat
            # v = sky view factor                                              [WEIGHTED AVE]
            # w = clip to alternative AOI
            # x = percent cut on intensity layer

            while read -n1 character; do
              case $character in

              a)
              info_msg "Blending rendered grid ${TINTFILE} with intensity image"
              dem_dim=($(gmt grdinfo ${TOPOGRAPHY_DATA} -C -L -Vn))
              dem_dimx=${dem_dim[9]}
              dem_dimy=${dem_dim[10]}
              gmt_init_tmpdir
              gmt grdimage ${TINTFILE} -R${TOPOGRAPHY_DATA} -JX5i -Cgray -Atintimage_pre.tif=gd:GTiff
              gmt_remove_tmpdir

              gdalwarp -overwrite -r cubic -q -ts ${dem_dimx} ${dem_dimy} ./tintimage_pre.tif ./tintimage.tif
              weighted_average_combine ./tintimage.tif ${F_TOPO}intensity.tif ${TINT_FACT} ${F_TOPO}intensity.tif
              # cp ./tintimage.tif ${F_TOPO}intensity.tif
              # gdalwarp nukes the z values for some stupid reason leaving a raster that GMT interprets as all 0s
              ;;

              b)
              echo white tiff
              white_tiff ${TOPOGRAPHY_DATA} ${F_TOPO}intensity.tif
              ;;

              c)
                info_msg "Creating and blending color stretch from ${TOPOGRAPHY_DATA} (alpha=$DEM_ALPHA)."

                # GMT can be used to make the color stretch but gdaldem seems better?
                # gmt_init_tmpdir
                # gmt grdimage ${TOPOGRAPHY_DATA} -C${TOPO_CPT} -R${TOPOGRAPHY_DATA} -JX5i ${VERBOSE} -A${F_TOPO}colordem_gmt.tif=gd:GTiff+cCOMPRESS=NONE
                # gdal_edit.py -colorinterp_1 red -colorinterp_2 green -colorinterp_3 blue ${F_TOPO}colordem_gmt.tif
                # gmt_remove_tmpdir
                gdaldem color-relief ${TOPOGRAPHY_DATA} ${F_CPTS}topocolor.dat ${F_TOPO}colordem.tif -q
                if [[ $tposwhiteflag -eq 1 ]]; then
                  # If raster $2 has value above $3, outval=$4, else outval=raster $1, put into $5
                  image_setabove ${F_TOPO}colordem.tif ${TOPOGRAPHY_DATA} 0 ${TPOSWHITEVAL} ${F_TOPO}colordemwhite.tif
                  [[ -s ${F_TOPO}colordemwhite.tif ]] && mv ${F_TOPO}colordemwhite.tif ${F_TOPO}colordem.tif
                fi
                if [[ $tnegwhiteflag -eq 1 ]]; then
                  image_setbelow ${F_TOPO}colordem.tif ${TOPOGRAPHY_DATA} 0 254 ${F_TOPO}colordemwhite.tif
                  [[ -s ${F_TOPO}colordemwhite.tif ]] && mv ${F_TOPO}colordemwhite.tif ${F_TOPO}colordem.tif
                fi

                alpha_value ${F_TOPO}colordem.tif ${DEM_ALPHA} ${F_TOPO}colordem_alpha.tif
              ;;

              w)
                info_msg "Clipping DEM to new AOI"

                gdal_translate -q -of GTiff -projwin ${CLIP_MINLON} ${CLIP_MAXLAT} ${CLIP_MAXLON} ${CLIP_MINLAT} ${TOPOGRAPHY_DATA} ${F_TOPO}dem_clip.tif
                DEM_MINLON=${CLIP_MINLON}
                DEM_MAXLON=${CLIP_MAXLON}
                DEM_MINLAT=${CLIP_MINLAT}
                DEM_MAXLAT=${CLIP_MAXLAT}
                # mkdir -p ./tmpcut
                # cd ./tmpcut
                # gmt grdcut ../${F_TOPO}dem.tif -R${CLIP_MINLON}/${CLIP_MAXLON}/${CLIP_MINLAT}/${CLIP_MAXLAT} -G../${F_TOPO}clip.nc ${VERBOSE}
                # cd ..

                cp ${F_TOPO}dem_clip.tif ${F_TOPO}dem.tif
                TOPOGRAPHY_DATA=${F_TOPO}dem.tif
              ;;

              i)
                info_msg "Calculating terrain ruggedness index"
                gdaldem TRI -q -of GTiff ${TOPOGRAPHY_DATA} ${F_TOPO}tri.tif
                zrange=($(grid_zrange ${F_TOPO}tri.tif -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}))
                gdal_translate -of GTiff -ot Byte -a_nodata 0 -scale ${zrange[0]} ${zrange[1]} 254 1 ${F_TOPO}tri.tif ${F_TOPO}tri2.tif -q
                weighted_average_combine ${F_TOPO}tri2.tif ${F_TOPO}intensity.tif ${TRI_FACT} ${F_TOPO}intensity.tif
              ;;

              q)
                gmt_init_tmpdir
                info_msg "Calculating height above local quantile"
                gmt grdfilter ${TOPOGRAPHY_DATA} -D2 -Fm${DEM_QUANTILE_RADIUS}+q${DEM_QUANTILE}  -G${F_TOPO}quantile.nc
                gmt grdmath ${TOPOGRAPHY_DATA} ${F_TOPO}quantile.nc SUB = ${F_TOPO}quantile_diff.nc ${VERBOSE}
                gmt_remove_tmpdir

                zrange=($(grid_zrange ${F_TOPO}quantile_diff.nc -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}))
                gdal_translate -of GTiff -ot Byte -a_nodata 0 -scale ${zrange[0]} ${zrange[1]} 1 254 ${F_TOPO}quantile_diff.nc ${F_TOPO}quantile_gray.tif -q
                weighted_average_combine ${F_TOPO}quantile_gray.tif ${F_TOPO}intensity.tif ${QUANTILE_FACT} ${F_TOPO}intensity.tif
              ;;


              t)
                demwidth=$(gmt grdinfo -C ${TOPOGRAPHY_DATA} ${VERBOSE} | gawk '{print $10}')
                demheight=$(gmt grdinfo -C ${TOPOGRAPHY_DATA} ${VERBOSE} | gawk '{print $11}')
                demxmin=$(gmt grdinfo -C ${TOPOGRAPHY_DATA} ${VERBOSE} | gawk '{print $2}')
                demxmax=$(gmt grdinfo -C ${TOPOGRAPHY_DATA} ${VERBOSE} | gawk '{print $3}')
                demymin=$(gmt grdinfo -C ${TOPOGRAPHY_DATA} ${VERBOSE} | gawk '{print $4}')
                demymax=$(gmt grdinfo -C ${TOPOGRAPHY_DATA} ${VERBOSE} | gawk '{print $5}')

                info_msg "Calculating and rendering texture map"

                # Calculate the texture shade
                # Project from WGS1984 to Mercator / HDF format
                # The -dstnodata option is a kluge to get around unknown NaNs in dem_flt.flt even if ${TOPOGRAPHY_DATA} has NaNs filled.

                [[ ! -e ${F_TOPO}dem_flt.flt ]] && gdalwarp -dstnodata -9999 -t_srs EPSG:3395 -s_srs EPSG:4326 -if GTiff -of EHdr -ot Float32 -ts $demwidth $demheight ${TOPOGRAPHY_DATA} ${F_TOPO}dem_flt.flt -q

                # texture the DEM. Pipe output to /dev/null to silence the program
                if [[ $(echo "$DEM_MAXLAT >= 90" | bc) -eq 1 ]]; then
                  MERCMAXLAT=89.999
                else
                  MERCMAXLAT=$DEM_MAXLAT
                fi
                if [[ $(echo "$DEM_MINLAT <= -90" | bc) -eq 1 ]]; then
                  MERCMINLAT=-89.999
                else
                  MERCMINLAT=$DEM_MINLAT
                fi

                ${TEXTURE} ${TS_FRAC} ${F_TOPO}dem_flt.flt ${F_TOPO}texture.flt -mercator ${MERCMINLAT} ${MERCMAXLAT} > /dev/null
                # make the image. Pipe output to /dev/null to silence the program
                ${TEXTURE_IMAGE} +${TS_STRETCH} ${F_TOPO}texture.flt ${F_TOPO}texture_merc.tif > /dev/null
                # project back to WGS1984

                # Need to convert to NC for some reason
                gdal_translate -of NetCDF ${F_TOPO}texture_merc.tif ${F_TOPO}texture_merc.nc > /dev/null 2>&1
                gdalwarp -if NetCDF -of GTiff -s_srs EPSG:3395 -t_srs EPSG:4326 -ts $demwidth $demheight -te $demxmin $demymin $demxmax $demymax ${F_TOPO}texture_merc.nc ${F_TOPO}texture_2byte.tif -q > /dev/null 2>&1

                # Change to 8 bit unsigned format
                gdal_translate -of GTiff -ot Byte -scale 0 65535 0 255 ${F_TOPO}texture_2byte.tif ${F_TOPO}texture.tif -q > /dev/null 2>&1
                cleanup ${F_TOPO}texture_2byte.tif ${F_TOPO}texture_merc.tif ${F_TOPO}dem_flt.flt ${F_TOPO}dem.hdr ${F_TOPO}dem_flt.flt.aux.xml ${F_TOPO}dem.prj ${F_TOPO}texture.flt ${F_TOPO}texture.hdr ${F_TOPO}texture.prj ${F_TOPO}texture_merc.prj ${F_TOPO}texture_merc.tfw

                # Combine it with the existing intensity
                weighted_average_combine ${F_TOPO}texture.tif ${F_TOPO}intensity.tif ${TS_FACT} ${F_TOPO}intensity.tif
              ;;

              m)
                info_msg "Creating multidirectional hillshade"
                gdaldem hillshade -multidirectional -compute_edges -alt ${HS_ALT} -s $MULFACT ${TOPOGRAPHY_DATA} ${F_TOPO}multiple_hillshade.tif -q
                weighted_average_combine ${F_TOPO}multiple_hillshade.tif ${F_TOPO}intensity.tif ${MULTIHS_FACT} ${F_TOPO}intensity.tif
              ;;

              # Compute and render a one-sun hillshade
              h)
                info_msg "Creating unidirectional hillshade"
                gdaldem hillshade -combined -compute_edges -alt ${HS_ALT} -az ${HS_AZ} -s $MULFACT ${TOPOGRAPHY_DATA} ${F_TOPO}single_hillshade.tif -q
                weighted_average_combine ${F_TOPO}single_hillshade.tif ${F_TOPO}intensity.tif ${UNI_FACT} ${F_TOPO}intensity.tif
              ;;

              # Compute and render the slope map
              s)
                info_msg "Creating slope map"
                gdaldem slope -compute_edges -s $MULFACT ${TOPOGRAPHY_DATA} ${F_TOPO}slopedeg.tif -q
                echo "5 254 254 254" > ${F_TOPO}slope.txt
                echo "80 30 30 30" >> ${F_TOPO}slope.txt
                gdaldem color-relief ${F_TOPO}slopedeg.tif ${F_TOPO}slope.txt ${F_TOPO}slope.tif -q
                
                weighted_average_combine ${F_TOPO}slope.tif ${F_TOPO}intensity.tif ${SLOPE_FACT} ${F_TOPO}intensity.tif
                # multiply_combine ${F_TOPO}slope.tif ${F_TOPO}intensity.tif ${F_TOPO}intensity.tif
                # overlay_combine ${F_TOPO}slope.tif ${F_TOPO}intensity.tif ${F_TOPO}intensity.tif
                # darken_combine_alpha ${F_TOPO}slope.tif ${F_TOPO}intensity.tif ${F_TOPO}intensity.tif
              ;;

              # Compute and render the sky view factor
              v)
                demwidth=$(gmt grdinfo -C ${TOPOGRAPHY_DATA} ${VERBOSE} | gawk '{print $10}')
                demheight=$(gmt grdinfo -C ${TOPOGRAPHY_DATA} ${VERBOSE} | gawk '{print $11}')
                demxmin=$(gmt grdinfo -C ${TOPOGRAPHY_DATA} ${VERBOSE} | gawk '{print $2}')
                demxmax=$(gmt grdinfo -C ${TOPOGRAPHY_DATA} ${VERBOSE} | gawk '{print $3}')
                demymin=$(gmt grdinfo -C ${TOPOGRAPHY_DATA} ${VERBOSE} | gawk '{print $4}')
                demymax=$(gmt grdinfo -C ${TOPOGRAPHY_DATA} ${VERBOSE} | gawk '{print $5}')

                info_msg "Creating sky view factor"

                gdal_fillnodata.py ${TOPOGRAPHY_DATA} fill.tif


                [[ ! -e ${F_TOPO}dem_flt.flt ]] && gdalwarp -srcnodata nan -dstnodata -9999 -t_srs EPSG:3395 -s_srs EPSG:4326 -if GTiff -of EHdr -ot Float32 -ts $demwidth $demheight fill.tif ${F_TOPO}dem_flt.flt -q

                # texture the DEM. Pipe output to /dev/null to silence the program
                if [[ $(echo "$DEM_MAXLAT >= 90" | bc) -eq 1 ]]; then
                  MERCMAXLAT=89.999
                else
                  MERCMAXLAT=$DEM_MAXLAT
                fi
                if [[ $(echo "$DEM_MINLAT <= -90" | bc) -eq 1 ]]; then
                  MERCMINLAT=-89.999
                else
                  MERCMINLAT=$DEM_MINLAT
                fi

                # We currently calclate both positive and negative openness and use pos as the sky view factor layer...

                # cp ${F_TOPO}dem_flt.hdr ${F_TOPO}dem_flt_fill.hdr
                start_time=`date +%s`
                ${SVF} ${F_TOPO}dem_flt.flt ${F_TOPO}pos.flt ${F_TOPO}neg.flt -dist ${NUM_SVF_DIST} -skip ${NUM_SVF_SKIP} -angles ${NUM_SVF_ANGLES} -cores ${NUM_SVF_CORES} -mercator ${MERCMINLAT} ${MERCMAXLAT} > /dev/null
                echo svf run time is $(expr `date +%s` - $start_time) s
                # project back to WGS1984
                gdalwarp -s_srs EPSG:3395 -t_srs EPSG:4326 -ts $demwidth $demheight -te $demxmin $demymin $demxmax $demymax ${F_TOPO}pos.flt ${F_TOPO}svf_back.tif -q

                zrange=($(grid_zrange ${F_TOPO}svf_back.tif -R${F_TOPO}svf_back.tif  -Vn))
                gdal_translate -of GTiff -ot Byte -a_nodata 255 -scale ${zrange[1]} ${zrange[0]} 1 254 ${F_TOPO}svf_back.tif ${F_TOPO}svf.tif -q

                # histogram stretch it
                zrange=($(grid_zrange ${F_TOPO}svf.tif -R${F_TOPO}svf.tif  -Vn))

                histogram_percentcut_byte ${F_TOPO}svf.tif 1 99 ${F_TOPO}svf_cut.tif

                # Combine it with the existing intensity
                weighted_average_combine ${F_TOPO}svf_cut.tif ${F_TOPO}intensity.tif ${SKYVIEW_FACT} ${F_TOPO}intensity.tif
                # multiply_combine ${F_TOPO}svf.tif ${F_TOPO}intensity.tif ${F_TOPO}intensity_svmult.tif
              ;;

              # Compute and render the cast shadows
              d)
                info_msg "Creating cast shadow map"

                demwidth=$(gmt grdinfo -C ${TOPOGRAPHY_DATA} ${VERBOSE} | gawk '{print $10}')
                demheight=$(gmt grdinfo -C ${TOPOGRAPHY_DATA} ${VERBOSE} | gawk '{print $11}')
                demxmin=$(gmt grdinfo -C ${TOPOGRAPHY_DATA} ${VERBOSE} | gawk '{print $2}')
                demxmax=$(gmt grdinfo -C ${TOPOGRAPHY_DATA} ${VERBOSE} | gawk '{print $3}')
                demymin=$(gmt grdinfo -C ${TOPOGRAPHY_DATA} ${VERBOSE} | gawk '{print $4}')
                demymax=$(gmt grdinfo -C ${TOPOGRAPHY_DATA} ${VERBOSE} | gawk '{print $5}')


# echo "Test"
# gdal_translate -of GTiff -co profile=baseline -co tfw=yes ${TOPOGRAPHY_DATA} ${F_TOPO}shadow_baseline.tif
# gawk < ${F_TOPO}shadow_baseline.tfw -v angle=${SUN_AZ} '
# function getpi()       { return atan2(0,-1)             }
# function deg2rad(deg)  { return (getpi() / 180) * deg   }
#
# BEGIN {
#   rads=deg2rad(angle)
# }
# (NR==1) {
#   A=$1
# }
# (NR==2) {
#   B=$1
# }
# (NR==3) {
#   C=$1
# }
# (NR==4) {
#   D=$1
# }
# (NR==5) {
#   E=$1
# }
# (NR==6) {
#   F=$1
# }
# END {
#   print A*cos(rads)
#   print A*sin(rads)
#   print -D*sin(rads)
#   print D*sin(rads)
#   print E
#   print F
# }
# ' > ${F_TOPO}shadow_baseline_new.tfw
#
# mv ${F_TOPO}shadow_baseline.tif ${F_TOPO}shadow_baseline_new.tif
#
# echo
#
# gdalwarp -dstnodata -9999 -r bilinear -if GTiff -of EHdr -ot Float32 ${F_TOPO}shadow_baseline_new.tif ${F_TOPO}dem_flt_rot.flt  -q
#
# echo "End test"

                # echo filling flt file
                # gdal_fillnodata.py ${TOPOGRAPHY_DATA} -of GTiff ${F_TOPO}dem_prefill.tif
                [[ ! -e ${F_TOPO}dem_flt.flt ]] && gdalwarp -r cubic -dstnodata -9999 -t_srs EPSG:3395 -s_srs EPSG:4326 -r bilinear -if GTiff -of EHdr -ot Float32 -ts $demwidth $demheight ${TOPOGRAPHY_DATA} ${F_TOPO}dem_flt.flt -q
                #
                # gdal_fillnodata [-q] [-md max_distance] [-si smooth_iterations]
                #   [-o name=value] [-b band]
                #   srcfile [-nomask] [-mask filename] [-of format] [-co name=value]* [dstfile]

                # texture the DEM. Pipe output to /dev/null to silence the program
                if [[ $(echo "$MAXLAT >= 90" | bc) -eq 1 ]]; then
                  MERCMAXLAT=89.999
                else
                  MERCMAXLAT=$MAXLAT
                fi
                if [[ $(echo "$MINLAT <= -90" | bc) -eq 1 ]]; then
                  MERCMINLAT=-89.999
                else
                  MERCMINLAT=$MINLAT
                fi

                # echo "DEM"
                # gdalinfo ${F_TOPO}dem.tif
                # echo "DEMFLT"
                # gdalinfo ${F_TOPO}dem_flt.flt
                SUN_AZ_M1=$(echo "${SUN_AZ} - 2" | bc -l)
                SUN_AZ_M05=$(echo "${SUN_AZ} - 1" | bc -l)
                SUN_AZ_P05=$(echo "${SUN_AZ} + 1" | bc -l)
                SUN_AZ_P1=$(echo "${SUN_AZ} + 2" | bc -l)

                SHADOW_START_TIME="$(date -u +%s)"

shadowalldirflag=0

                if [[ $shadowalldirflag -eq 1 ]]; then
                #  This code creates a kind of 'shadow map from all direction'
                  for this_az in $(seq 1 5 360); do
                    echo doing azimuth $this_az
                    ${SHADOW} ${this_az} ${SUN_EL} ${F_TOPO}dem_flt.flt ${F_TOPO}shadow_360.flt -mercator ${MERCMINLAT} ${MERCMAXLAT} ${SHADOW_FAST} > /dev/null
                    gdalwarp -s_srs EPSG:3395 -t_srs EPSG:4326  -ts $demwidth $demheight -te $demxmin $demymin $demxmax $demymax ${F_TOPO}shadow_360.flt ${F_TOPO}shadow_360.tif -q
                    if [[ -s ${F_TOPO}shadow_360_sum.tif ]]; then
                      gdal_calc.py --overwrite --type=Float32 --format=GTiff --quiet -A ${F_TOPO}shadow_360.tif -B ${F_TOPO}shadow_360_sum.tif --calc="A+B" --outfile=${F_TOPO}shadow_360_sum_2.tif
                      mv ${F_TOPO}shadow_360_sum_2.tif ${F_TOPO}shadow_360_sum.tif
                      rm -f ${F_TOPO}shadow_360.tif
                    else
                      mv ${F_TOPO}shadow_360.tif ${F_TOPO}shadow_360_sum.tif
                    fi
                  done
                  mv ${F_TOPO}shadow_360_sum.tif ${F_TOPO}shadow_back_add.tif
                else

                  ${SHADOW} ${SUN_AZ_M1} ${SUN_EL} ${F_TOPO}dem_flt.flt ${F_TOPO}shadow_m1.flt -mercator ${MERCMINLAT} ${MERCMAXLAT} ${SHADOW_FAST} > /dev/null
                  ${SHADOW} ${SUN_AZ_M05} ${SUN_EL} ${F_TOPO}dem_flt.flt ${F_TOPO}shadow_m05.flt -mercator ${MERCMINLAT} ${MERCMAXLAT} ${SHADOW_FAST} > /dev/null
                  ${SHADOW} ${SUN_AZ} ${SUN_EL} ${F_TOPO}dem_flt.flt ${F_TOPO}shadow.flt -mercator ${MERCMINLAT} ${MERCMAXLAT} ${SHADOW_FAST} > /dev/null
                  ${SHADOW} ${SUN_AZ_P05} ${SUN_EL} ${F_TOPO}dem_flt.flt ${F_TOPO}shadow_p05.flt -mercator ${MERCMINLAT} ${MERCMAXLAT} ${SHADOW_FAST} > /dev/null
                  ${SHADOW} ${SUN_AZ_P1} ${SUN_EL} ${F_TOPO}dem_flt.flt ${F_TOPO}shadow_p1.flt -mercator ${MERCMINLAT} ${MERCMAXLAT} ${SHADOW_FAST} > /dev/null

                  # bilinear interpolation was really messing up the output resolution... removed
                  gdalwarp -s_srs EPSG:3395 -t_srs EPSG:4326  -ts $demwidth $demheight -te $demxmin $demymin $demxmax $demymax ${F_TOPO}shadow_m1.flt ${F_TOPO}shadow_back_m1.tif -q
                  gdalwarp -s_srs EPSG:3395 -t_srs EPSG:4326  -ts $demwidth $demheight -te $demxmin $demymin $demxmax $demymax ${F_TOPO}shadow_m05.flt ${F_TOPO}shadow_back_m05.tif -q
                  gdalwarp -s_srs EPSG:3395 -t_srs EPSG:4326  -ts $demwidth $demheight -te $demxmin $demymin $demxmax $demymax ${F_TOPO}shadow.flt ${F_TOPO}shadow_back.tif -q
                  gdalwarp -s_srs EPSG:3395 -t_srs EPSG:4326  -ts $demwidth $demheight -te $demxmin $demymin $demxmax $demymax ${F_TOPO}shadow_p1.flt ${F_TOPO}shadow_back_p1.tif -q
                  gdalwarp -s_srs EPSG:3395 -t_srs EPSG:4326  -ts $demwidth $demheight -te $demxmin $demymin $demxmax $demymax ${F_TOPO}shadow_p05.flt ${F_TOPO}shadow_back_p05.tif -q

                  gdal_calc.py --overwrite --type=Float32 --format=GTiff --quiet -A ${F_TOPO}shadow_back.tif -B ${F_TOPO}shadow_back_p1.tif -C ${F_TOPO}shadow_back_m1.tif -D ${F_TOPO}shadow_back_m05.tif -E ${F_TOPO}shadow_back_p05.tif --calc="(((A>0)*1+(B>0)*1+(C>0)*1+(D>0)*1+(E>0)*1)==5)*log(A*A+B*B+C*C+D*D+E*E+1)" --outfile=${F_TOPO}shadow_back_add.tif

                fi
                MAX_SHADOW=$(gmt grdinfo -C ${F_TOPO}shadow_back_add.tif | gawk '{print $7}')

                # Change to 8 bit unsigned format
                gdal_translate -r cubic -of GTiff -ot Byte -a_nodata 255 -scale $MAX_SHADOW 0 1 254 ${F_TOPO}shadow_back_add.tif ${F_TOPO}shadowed.tif -q

                # cp ${F_TOPO}shadowed.tif ${F_TOPO}shadowed_fixed.tif
                gmt grdmath ${F_TOPO}shadowed.tif ISNAN 254 ${F_TOPO}shadowed.tif IFELSE = ${F_TOPO}shadowed_fixed.tif=gd:GTiff/u8
                # gdal_calc.py -A ${F_TOPO}shadowed.tif --outfile=${F_TOPO}shadowed_fixed.tif --calc="nan_to_num(A, nan=254)" --NoDataValue=254
                # gdal_fillnodata.py -q -md 5 ${F_TOPO}shadowed.tif ${F_TOPO}shadowed_fixed.tif
                # gdal_calc.py --overwrite --type=Byte --format=GTiff --quiet -A ${F_TOPO}shadowed.tif --calc="((A==127)*254 + (A!=127)*A)" --outfile=${F_TOPO}shadowed_fixed.tif

                # gdalbuildvrt -srcnodata 255 -vrtnodata 0 /vsistdout/ ${F_TOPO}shadowed.tif | gdal_translate -a_nodata 1 /vsistdin/ ${F_TOPO}shadowed_fixed.tif
                SHADOW_END_TIME="$(date -u +%s)"
                elapsed="$(($SHADOW_END_TIME - $SHADOW_START_TIME))"
                echo "Shadow run time was $elapsed seconds"



                # echo "SHADOW"
                # gdalinfo ${F_TOPO}shadow.tif
                smoothshadowsflag=0
                if [[ $smoothshadowsflag -eq 1 ]]; then
                  info_msg Smoothing shadow map
                  gmt grdfilter -fg -Fg3 ${F_TOPO}shadowed_fixed.tif -G${F_TOPO}shadow_smoothed.tif=gd:GTiff/u8 -D2
                  shadowtoplot=${F_TOPO}shadow_smoothed.tif
                else
                  shadowtoplot=${F_TOPO}shadowed_fixed.tif
                fi

                # Smooth the shadows using cubic interpolation

                # Combine it with the existing intensity
                alpha_value ${shadowtoplot} ${SHADOW_ALPHA} ${F_TOPO}shadow_alpha.tif

                multiply_combine ${F_TOPO}shadow_alpha.tif ${F_TOPO}intensity.tif ${F_TOPO}intensity.tif
              ;;
              # Rescale and gamma correct the intensity layer
              g)
                info_msg "Rescale stretching and gamma correcting intensity layer"
                cp ${F_TOPO}intensity.tif ${F_TOPO}intensity_pre.tif
                zrange=($(grid_zrange ${F_TOPO}intensity.tif))

                histogram_rescale_stretch ${F_TOPO}intensity.tif ${zrange[0]} ${zrange[1]} 1 254 $HS_GAMMA ${F_TOPO}intensity_cor.tif

                mv ${F_TOPO}intensity_cor.tif ${F_TOPO}intensity.tif
              ;;

              # Percent cut the intensity layer
              x)
                info_msg "Executing percent cut on intensity layer"
                histogram_percentcut_byte ${F_TOPO}intensity.tif $TPCT_MIN $TPCT_MAX ${F_TOPO}intensity_percentcut.tif
                cp ${F_TOPO}intensity_percentcut.tif ${F_TOPO}intensity.tif
              ;;

              # Set intensity of DEM values with elevation=0 to 254
              # This is tunsetflat
              u)
                info_msg "Resetting 0 elevation cells to white"
                image_setval ${F_TOPO}intensity.tif ${TOPOGRAPHY_DATA} 0 254 ${F_TOPO}unset.tif
                cp ${F_TOPO}unset.tif ${F_TOPO}intensity.tif
              ;;

              esac
            done < <(echo -n "$topoctrlstring")

            INTENSITY_RELIEF=${F_TOPO}intensity.tif

            # Handle the TIFF images we will blend onto the intensity file

            if [[ ${topoctrlstring} =~ .*p.* ]]; then

                dem_dim=($(gmt grdinfo ${TOPOGRAPHY_DATA} -C -L -Vn))
                dem_dimx=${dem_dim[9]}
                dem_dimy=${dem_dim[10]}

                for this_image_ind in $(seq 1 $timg_index); do
                  this_image=${TIMG_IMAGES[$this_image_ind]}
                  this_fact=${TIMG_FACTS[$this_image_ind]}

                  # gmt grdinfo ${this_image}

                  # Detect an alpha channel and remove it if necessary
                  gdal_translate -b 1 -b 2 -b 3 ${this_image} temp_image.tif
                  this_image=temp_image.tif

                  info_msg "Rendering georeferenced RGB image ${this_image} as colored texture."

                  # THIS CODE CAN BREAK SOME THINGS SOMETIMES - NOT SURE WHY
                  if [[ $(echo "${this_fact} != 0" | bc) -eq 1 ]]; then
                    info_msg "Adjusting opacity of RGB image ${this_image}: alpha=${this_fact}"
                    rm -f ${F_TOPO}image_alpha.tif
                    alpha_value temp_image.tif ${this_fact} ${F_TOPO}image_alpha.tif
                    gdal_edit.py -unsetnodata ${F_TOPO}image_alpha.tif
                    this_image=${F_TOPO}image_alpha.tif
                    cp ${F_TOPO}image_alpha.tif ${F_TOPO}image_alpha_saved.tif
                  fi

                  # quickreport ${this_image}

                  info_msg "Rescaling ${this_image} to match DEM"
                  gdalwarp -overwrite -q -r ${TIMG_RESAMPLE} -te  ${DEM_MINLON} ${DEM_MINLAT} ${DEM_MAXLON} ${DEM_MAXLAT} -ts ${dem_dimx} ${dem_dimy} ${this_image} ${F_TOPO}image_pre.tif
                  gdal_edit.py -colorinterp_1 red -colorinterp_2 green -colorinterp_3 blue ${F_TOPO}image_pre.tif

                  # quickreport ${F_TOPO}image_pre.tif

                  # Change sea color if asked
                  if [[ $sentinelrecolorseaflag -eq 1 ]]; then
                    info_msg "Recoloring sea areas of image"
                    recolor_sea ${F_TOPO}dem.tif ${F_TOPO}image_pre.tif ${SENTINEL_RECOLOR_R} ${SENTINEL_RECOLOR_G} ${SENTINEL_RECOLOR_B} ${F_TOPO}image_pre_recolor.tif
                    mv ${F_TOPO}image_pre_recolor.tif ${F_TOPO}image_pre.tif
                  fi

                  # Either copy (first) or overlay (subsequent) the rescaled image
                  if [[ ! -s ${F_TOPO}image.tif ]]; then
                    cp ${F_TOPO}image_pre.tif ${F_TOPO}image.tif
                  else
                    info_msg "Overlay combining ${this_image}"
                    white_pixels_combine ${F_TOPO}image_pre.tif ${F_TOPO}image.tif ${F_TOPO}image_out.tif
                    cp ${F_TOPO}image_out.tif ${F_TOPO}image.tif
                  fi

      # This is the problematic command that overly brightens the image sometimes
      #              histogram_rescale_stretch ${F_TOPO}image_pre.tif 1 180 1 254 ${SENTINEL_GAMMA} ${F_TOPO}image.tif
      # Causes major clipping of white areas in original image.
                done

                # if [[ $(echo "${IMAGE_FACT} == 1" | bc) -ne 1 ]]; then
                #   info_msg "Applying alpha ${IMAGE_FACT} to image"
                #   alpha_value ${F_TOPO}image.tif ${IMAGE_FACT} ${F_TOPO}image_alpha.tif
                #   # values of 255 in image.tif are set to nodata in image_alpha.tif
                #   # This seems to have fixed the issue?
                #   gdal_edit.py -unsetnodata ${F_TOPO}image_alpha.tif
                #   info_msg "Multiply combine of color with intensity."
                #   multiply_combine ${F_TOPO}image_alpha.tif $INTENSITY_RELIEF ${F_TOPO}colored_intensity.tif
                # else
                # # weighted_average_combine ${F_TOPO}image.tif ${F_TOPO}intensity.tif ${IMAGE_FACT} ${F_TOPO}intensity.tif

                  multiply_combine ${F_TOPO}image.tif $INTENSITY_RELIEF ${F_TOPO}colored_intensity.tif
                # fi
                INTENSITY_RELIEF=${F_TOPO}colored_intensity.tif
            fi


            # If we have a color stretch but NOT an image overlay
            if [[ ${topoctrlstring} =~ .*c.* && ! ${topoctrlstring} =~ .*p.* ]]; then
              multiply_combine ${F_TOPO}colordem_alpha.tif $INTENSITY_RELIEF ${F_TOPO}colored_intensity.tif
              COLORED_RELIEF=${F_TOPO}colored_intensity.tif
            else
              # colored relief is already generated from an image overlay OR is the blank intensity
              COLORED_RELIEF=$INTENSITY_RELIEF
            fi
            # BATHY=${TOPOGRAPHY_DATA}

            if [[ $toponoloadflag -ne 0 ]]; then
              echo "Saving finished tile to ${SAVEDTOPODIR}topoimg_${BATHYMETRY}_${MINLON}_${MAXLON}_${MINLAT}_${MAXLAT}_${topoctrlstring}.tif"
              cp ${COLORED_RELIEF} ${SAVEDTOPODIR}topoimg_${BATHYMETRY}_${MINLON}_${MAXLON}_${MINLAT}_${MAXLAT}_${topoctrlstring}.tif
            fi
          fi

        fi  # fasttopoflag = 0

        # If we are doing more complex topo visualization, we already have COLORED_RELIEF calculated

        # As of GMT 6.5.0_ffc5eba_2022.09.14, plotting a GDAL TIFF with grdimage
        # can sometimes fail with an improper -srcwin error. This can be fixed
        # by recasting the file to PNG and plotting that...!

        if [[ $fasttopoflag -eq 0 ]]; then
          if [[ $dontplottopoflag -eq 0 ]]; then
            info_msg "[-t]: Plotting GDAL topo from ${COLORED_RELIEF}"
            #  gmt grdconvert ${COLORED_RELIEF} ${F_TOPO}convert.nc
            gmt grdimage ${COLORED_RELIEF} $RJOK -t$TOPOTRANS > tmp.ps 2>/dev/null
            if [ ! -s tmp.ps ]; then
              gdal_translate -of PNG ${COLORED_RELIEF} ${F_TOPO}convert.png
              gmt grdimage ${F_TOPO}convert.png $RJOK -t$TOPOTRANS ${VERBOSE} >> map.ps
            else
              cat tmp.ps >> map.ps
              rm -f tmp.ps
            fi
          fi
        else
        # If we are doing fast topo visualization, calculate COLORED_RELIEF and plot it
          gmt_init_tmpdir
            info_msg "[-t]: Plotting GMT topo from ${TOPOGRAPHY_DATA}"
            gmt grdimage ${TOPOGRAPHY_DATA} ${ILLUM} -C${TOPO_CPT} -R${TOPOGRAPHY_DATA} -JQ5i ${VERBOSE} -A${F_TOPO}colored_relief.tif
            # Change the coordinate info to match ${TOPOGRAPHY_DATA}
            gdal_edit.py -a_srs "None" ${F_TOPO}colored_relief.tif
            COLORED_RELIEF=$(abs_path ${F_TOPO}colored_relief.tif)
          gmt_remove_tmpdir

          if [[ $dontplottopoflag -eq 0 ]]; then
            # Note that plotting the colored_relief image doesn't work due to strange GMT issues
            # with -srcwin through gdal... so just plot again with grdimage
            # gmt grdimage ${COLORED_RELIEF} -t$TOPOTRANS ${RJOK} ${VERBOSE} >> map.ps
            # echo "Plotting GMT topo..."
            # gdal_translate -of NetCDF ${TOPOGRAPHY_DATA} ${F_TOPO}convert.nc

            gmt grdimage ${COLORED_RELIEF} -t$TOPOTRANS ${RJOK} ${VERBOSE} >> map.ps

            # > tmp.ps 2>/dev/null
            # gdal_translate -of PNG ${TOPOGRAPHY_DATA} ${F_TOPO}convert.png
            #
            # if [ ! -s tmp.ps ]; then
            #   gdal_translate -of PNG ${COLORED_RELIEF} ${F_TOPO}convert.png
            #   gmt grdimage ${F_TOPO}convert.png $RJOK -t$TOPOTRANS ${VERBOSE} >> map.ps
            # else
            #   cat tmp.ps >> map.ps
            #   rm -f tmp.ps
            # fi

          fi
        fi
        info_msg "Done"
        ;;


      # usergrid)
      #   # Each time usergrid) is called, plot the grid and increment to the next
      #   info_msg "Plotting user grid $current_usergridnumber: ${GRIDADDFILE[$current_usergridnumber]} with CPT ${GRIDADDCPT[$current_usergridnumber]}"
      #   gmt grdimage ${GRIDADDFILE[$current_usergridnumber]} -Q -I+d -C${GRIDADDCPT[$current_usergridnumber]} $GRID_PRINT_RES -t${GRIDADDTRANS[$current_usergridnumber]} $RJOK ${VERBOSE} >> map.ps
      #   current_usergridnumber=$(echo "$current_usergridnumber + 1" | bc -l)
      #   ;;

      # Anything not in the above list is probably a module.
      *)

        # Try all registered module _plot_ routines using the current plot keyword
        # This allows multiple plotting commands to be registered in a given module

        tectoplot_plot_caught=0

        # Increment the ${routine_callnum} variable here.
        # The reserved variable $tt contains the number of times a given
        # routine has been called

        eval "((${plot}_plot_callnum++))"
        eval "tt=\${${plot}_plot_callnum}"

        # Maybe need to change back to TECTOPLOT_MODULES???
        for this_mod in ${TECTOPLOT_ACTIVE_MODULES[@]}; do
          if type "tectoplot_plot_${this_mod}" >/dev/null 2>&1; then

            cmd="tectoplot_plot_${this_mod}"
            "$cmd" ${plot}
          fi
          if [[ $tectoplot_plot_caught -eq 1 ]]; then
            break
          fi
        done
        #
        #
        # if type "tectoplot_plot_${plot}" >/dev/null 2>&1; then
        #   # info_msg "Running module post-processing for ${plot}"
        #   cmd="tectoplot_plot_${plot}"
        #
        #   # Pass the name of the plot command to the plotting function to allow
        #   # multiple different plotting routines per module
        #   echo  "$cmd" ${plot}
        #   "$cmd" ${plot}
        # else
        #   echo "Unrecognized plot command: $plot"
        # fi
      ;;

  	esac
  done

  for plot in ${overlayplots[@]}; do
    case $plot in
      utmgrid)

        gmt_init_tmpdir

        if [[ $calcutmgridzonelaterflag -eq 1 ]]; then
          unset UTMGRIDZONES

          # UTMGRIDZONES+=($(echo "" | gmt mapproject -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} -Ju5i -C 2>&1 | grep "selected" | gawk '{print $8}'))

          # This breaks terribly if the average longitude is not between -180 and 180
          UCENTERLON=$(gmt mapproject -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} -WjCM ${VERBOSE} | gawk '{print $1}')
          AVELONp180o6=$(echo "(($UCENTERLON) + 180)/6" | bc -l)
          UTMGRIDZONES+=($(echo $AVELONp180o6 1 | gawk  '{val=int($1)+($1>int($1)); print (val>0)?val:1}'))
        fi
        gmt_remove_tmpdir

        # Strategy: Define the range of eastings and northings represented by
        # the map region for the given UTM zone.


        for thiszone in ${UTMGRIDZONES[@]}; do

            gmt_init_tmpdir

            info_msg "[-utmgrid]: using UTM Zone $thiszone"
            UTL=($(gmt mapproject -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} -WjTL ${VERBOSE} | gawk '{print $1, $2}'))
            UBR=($(gmt mapproject -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} -WjBR ${VERBOSE} | gawk '{print $1, $2}'))

            echo ${UTL[@]} > utmcorners.txt
            echo ${UBR[@]} >> utmcorners.txt

            gawk < utmcorners.txt '{print $2, $1}' | cs2cs EPSG:4326 EPSG:326${thiszone} > utmcorners.utm

            # gmt mapproject utmcorners.txt -R0/1/0/1 -JU${thiszone}/1i -F -C > utmcorners.utm

            UTMRANGE=($(gawk < utmcorners.utm '
            BEGIN {
              getline
              minE=$1
              maxE=$1
              minN=$2
              maxN=$2
            }
            {
              minE=($1<minE)?$1:minE
              maxE=($1>maxE)?$1:maxE
              minN=($2<minN)?$2:minN
              maxN=($2>maxN)?$2:maxN
            }
            END {
              print minE, maxE, minN, maxN
            }'))

            gawk -v fontsize=${UTMGRIDFONTSIZE} -v interval=${UTMGRIDINTERVAL} -v minE=${UTMRANGE[0]} -v maxE=${UTMRANGE[1]} -v minN=${UTMRANGE[2]} -v maxN=${UTMRANGE[3]} '
            @include "tectoplot_functions.awk"
            BEGIN {
              fontsmall=(fontsize+0)*0.75
              # Loop through the Eastings
              for(i=-2000000; i<=3000000; i=i+interval) {
                if (i >= minE-2*interval && i <= maxE+2*interval) {
                  stri=sprintf("%06d", i)
                  # Loop through the Northings
                  isub=substr(stri, 1, length(stri)-3)
                  iend=substr(stri, length(stri)-2, length(stri))

                  print "> -L" isub "@:" fontsmall ":" iend "@::"

                  for(j=-10000000; j<=10000000; j=j+interval) {
                    if (j >= minN-2*interval && j <= maxN+2*interval) {
                      print stri, j
                    }
                  }
                }
              }
            }' > utmgrid_lon.txt

            gawk -v fontsize=${UTMGRIDFONTSIZE} -v interval=${UTMGRIDINTERVAL} -v minE=${UTMRANGE[0]} -v maxE=${UTMRANGE[1]} -v minN=${UTMRANGE[2]} -v maxN=${UTMRANGE[3]} '
            BEGIN {
              fontsmall=(fontsize+0)*0.75
              # Loop through the Northings
              for(j=-10000000; j<=10000000; j=j+interval) {
                if (j >= minN-2*interval && j <= maxN+2*interval) {
                  jfix=sprintf("%07d", (j>0)?j:10000000+j)
                  jsub=substr(jfix, 1, length(jfix)-3)
                  jend=substr(jfix, length(jfix)-2, length(jfix))

                  print "> -L" jsub "@:" fontsmall ":" jend "@::"
                  for(i=-2000000; i<=3000000; i=i+interval) {
                    # Loop through the Eastings
                    if (i >= minE-2*interval && i <= maxE+2*interval) {
                      print i, j
                    }
                  }
                }
              }
            }' > utmgrid_lat.txt

            gawk -v fontsize=${UTMGRIDFONTSIZE} -v interval=${UTMGRIDINTERVAL} -v minE=${UTMRANGE[0]} -v maxE=${UTMRANGE[1]} -v minN=${UTMRANGE[2]} -v maxN=${UTMRANGE[3]} '
            BEGIN {
              fontsmall=(fontsize+0)*0.75
              # Loop through the Northings
              for(j=-10000000; j<=10000000; j=j+interval) {
                if (j >= minN-2*interval && j <= maxN+2*interval) {
                  jfix=sprintf("%s", (j>0)?j:10000000+j)
                  jsub=substr(jfix, 1, length(jfix)-3)
                  jend=substr(jfix, length(jfix)-2, length(jfix))

                  print "> -L" jsub "@:" fontsmall ":" jend "@::"
                  for(i=-2000000; i<=3000000; i=i+interval) {
                    # Loop through the Eastings
                    if (i >= minE-2*interval && i <= maxE+2*interval) {
                      print i, j
                    }
                  }
                }
              }
            }' > utmgrid_lat_ne.txt


            # Project gridlines to lon/lat
            cs2cs EPSG:326${thiszone} EPSG:4326 -f %.12f utmgrid_lat.txt | sed 's/.*>/>/' | gawk '{ if ($1+0==$1) {print $2, $1} else {print} }' > utmgrid_lat.wgs
            cs2cs EPSG:326${thiszone} EPSG:4326 -f %.12f utmgrid_lon.txt | sed 's/.*>/>/' | gawk '{ if ($1+0==$1) {print $2, $1} else {print} }' > utmgrid_lon.wgs

          gmt_remove_tmpdir

          # Plot the gridlines using psxy and the labels using psxy -Sq + pstext

          if [[ $utmgridplotlabels -eq 1 ]]; then
            gmt psxy utmgrid_lon.wgs -W0.1p,black ${RJOK} ${VERBOSE} >> map.ps
            gmt psxy utmgrid_lat.wgs -W0.1p,black ${RJOK} ${VERBOSE} >> map.ps

            gmt psxy utmgrid_lon.wgs -SqN-1:+Lh+a90+t -W0.1p,black ${RJOK} ${VERBOSE} > /dev/null
            mv Line_labels.txt labelsbottom.txt
            gmt psxy utmgrid_lon.wgs -SqN+1:+Lh+a90+t -W0.1p,black ${RJOK} ${VERBOSE} > /dev/null
            mv Line_labels.txt labelstop.txt
            gmt psxy utmgrid_lat.wgs -SqN-1:+Lh+a0+t ${RJOK} ${VERBOSE} > /dev/null
            mv Line_labels.txt labelsleft.txt
            gmt psxy utmgrid_lat.wgs -SqN+1:+Lh+a0+t ${RJOK} ${VERBOSE} > /dev/null
            mv Line_labels.txt labelsright.txt

            gmt pstext labelstop.txt ${UTMGRIDCLIP} ${UTMGRIDFILL} -F+f${UTMGRIDFONTSIZE},Helvetica,black+a+jM${UTMGRIDJUST1} -Dj2p ${RJOK} >> map.ps
            gmt pstext labelsbottom.txt ${UTMGRIDCLIP} ${UTMGRIDFILL} -F+f${UTMGRIDFONTSIZE},Helvetica,black+a+jM${UTMGRIDJUST2} -Dj2p ${RJOK} >> map.ps
            gmt pstext labelsleft.txt ${UTMGRIDCLIP} ${UTMGRIDFILL} -F+f${UTMGRIDFONTSIZE},Helvetica,black+a+jM${UTMGRIDJUST2} -Dj2p ${RJOK} >> map.ps
            gmt pstext labelsright.txt ${UTMGRIDCLIP} ${UTMGRIDFILL} -F+f${UTMGRIDFONTSIZE},Helvetica,black+a+jM${UTMGRIDJUST1} -Dj2p ${RJOK} >> map.ps
          else
            gmt psxy utmgrid_lon.wgs -W0.1p,black ${RJOK} ${VERBOSE} >> map.ps
            gmt psxy utmgrid_lat.wgs -W0.1p,black ${RJOK} ${VERBOSE} >> map.ps
          fi
        done

      ;;
    esac
  done




  # This is likely not compatible with the above section

  if [[ $plotbigbarflag -eq 1 ]]; then

    if [[ ! -e ${BIGBARCPT} ]]; then
      echo "No CPT file for big bar found"
    fi
    gmt psscale -DJCB+w${PSSIZE}i+o0/1c+h+e -C${BIGBARCPT} -Bxaf+l"${BIGBARANNO}" -G${BIGBARLOW}/${BIGBARHIGH} $RJOK ${VERBOSE} >> map.ps
  fi

  current_usergridnumber=1

fi  # if [[ $DATAPLOTTINGFLAG -eq 1 ]]; then


# We currently build a legend by first rendering the psscale color bars and then
# adding legend items from bottom to top, left to right.

# Change to rendering the colorbars and then concatenating legend items upward.
# Each legend item has to be exactly 2 inches wide in order to match the color
# bars and can be any height

##### SECTION LEGEND
if [[ $makelegendflag -eq 1 ]]; then
  gmt gmtset MAP_TICK_LENGTH_PRIMARY 0.5p MAP_ANNOT_OFFSET_PRIMARY 1.5p MAP_ANNOT_OFFSET_SECONDARY 2.5p MAP_LABEL_OFFSET 2.5p FONT_LABEL 6p,Helvetica,black

  # Plan is to plot legend to a file for EVERY call to tectoplot, and only
  # push onto the map using gmt psimage AFTER making the legend.

  info_msg "Plotting legend in its own file"
  COLORBARLEGEND=${LEGENDDIR}colorbars.ps
  gmt psxy -T ${RJSTRING} -X$PLOTSHIFTX -Y$PLOTSHIFTY -K $VERBOSE > ${COLORBARLEGEND}

  # Add the plot commands to the legend color bar command list

  # Should we have to explicitly register these per module instead of spamming plots[@]?

  for plot in ${plots[@]} ; do
    legendbarwords+=("$plot")
  done

  info_msg "Updated legend commands are >>>>> ${legendbarwords[@]} <<<<<"

  echo "# Legend " > ${LEGENDDIR}legendbars.txt
  echo "# Legend " > ${LEGENDDIR}legendbars.txt

  barplotcount=0
  plottedneiscptflag=0

  info_msg "Plotting colorbar legend items"

  # First, plot the color bars in a column.

  LEGENDBAR_OPTS="--MAP_FRAME_PEN=${LEGEND_FRAME_PEN} --FONT_ANNOT_PRIMARY=${LEGEND_FONTDEF}"

  for legendbar_plot in ${legendbarwords[@]} ; do
  	case $legendbar_plot in

# REQUIRES CPT
      secinv)
        echo "G ${LEGEND_BAR_GAP}" >> ${LEGENDDIR}legendbars.txt
        echo "B ${F_CPTS}secinv.cpt 0.2i ${LEGEND_BAR_HEIGHT}+malu ${LEGENDBAR_OPTS} -Bxaf+l\"Second invariant of strain rate\"" >> ${LEGENDDIR}legendbars.txt
        barplotcount=$barplotcount+1
      ;;

# REQUIRES CPT
      tomoslice)
        echo "G ${LEGEND_BAR_GAP}" >> ${LEGENDDIR}legendbars.txt
        echo "B ${F_CPTS}tomography.cpt 0.2i ${LEGEND_BAR_HEIGHT}+malu ${LEGENDBAR_OPTS} -Bxa1f0.2+l\"Velocity anomaly (percent)\"" >> ${LEGENDDIR}legendbars.txt
        barplotcount=$barplotcount+1
      ;;

# REQUIRES CPT
      eulerpoles)
        echo "G ${LEGEND_BAR_GAP}" >> ${LEGENDDIR}legendbars.txt
        echo "B ${F_CPTS}polerate.cpt 0.2i ${LEGEND_BAR_HEIGHT}+malu ${LEGENDBAR_OPTS} -Bxa1f0.2+l\"Rotation rate (degrees/Myr)\"" >> ${LEGENDDIR}legendbars.txt
        barplotcount=$barplotcount+1
      ;;

# REQUIRES CPT
      plateedgecolor)
        echo "G ${LEGEND_BAR_GAP}" >> ${LEGENDDIR}legendbars.txt
        echo "B ${F_CPTS}az.cpt 0.2i ${LEGEND_BAR_HEIGHT}+malu ${LEGENDBAR_OPTS} -Bxa90f45+l\"Obliquity (degrees)\"" >> ${LEGENDDIR}legendbars.txt
        barplotcount=$barplotcount+1
      ;;

# REQUIRES CPT and various flags
      cmt|seis)
        if [[ $plottedneiscptflag -eq 0 && ! $seisfillcolorflag -eq 1 && $zctimeflag -ne 1 && $zcclusterflag -ne 1 ]]; then
          plottedneiscptflag=1

          # Don't plot a color bar if we already have plotted one OR the seis CPT is a solid color
          echo "G ${LEGEND_BAR_GAP}" >> ${LEGENDDIR}legendbars.txt
          echo "B $SEISDEPTH_NODEEPEST_CPT 0.2i ${LEGEND_BAR_HEIGHT}+malu+e ${LEGENDBAR_OPTS} -Bxaf+l\"Depth (km)\"" >> ${LEGENDDIR}legendbars.txt
          barplotcount=$barplotcount+1
        fi
        ;;

# REQUIRES CPT to be set for eqcluster
      eqcluster)
        # Calculate the number of clusters to display in the legend bar?
        gawk < $SEIS_CPT '
          ($1+0==$1 && $1 < 30) {
            print
          }
          ($1+0!=$1) {
            print
          }' > ${F_CPTS}cluster_truncate.cpt
        echo "G ${LEGEND_BAR_GAP}" >> ${LEGENDDIR}legendbars.txt
        echo "B ${F_CPTS}cluster_truncate.cpt 0.2i ${LEGEND_BAR_HEIGHT}+malu+e ${LEGENDBAR_OPTS} -S+c+s -Bxa10 -B+l\"Earthquake cluster ID\"" >> ${LEGENDDIR}legendbars.txt
        barplotcount=$barplotcount+1
        ;;

# REQUIRES CPT
      eqtime)
          if [[ ${zccolorbreakflag} -eq 1 ]]; then
            echo "G ${LEGEND_BAR_GAP}" >> ${LEGENDDIR}legendbars.txt
            echo "B ${F_CPTS}eqtime_text_legend.cpt 0.2i ${LEGEND_BAR_HEIGHT}+malu+e ${LEGENDBAR_OPTS} -L -S+c+s" >> ${LEGENDDIR}legendbars.txt
          else
            echo "G ${LEGEND_BAR_GAP}" >> ${LEGENDDIR}legendbars.txt
            echo "B $SEIS_CPT 0.2i ${LEGEND_BAR_HEIGHT}+malu+e ${LEGENDBAR_OPTS} -S+c+s -Bxa+l\"Earthquake time\"" >> ${LEGENDDIR}legendbars.txt
          fi
          barplotcount=$barplotcount+1
        ;;

      # geoage)
      #   if [[ -e $GEOAGE_CPT ]]; then
      #
      #     # Reduce the CPT to the used scale range
      #     gmt makecpt -C$GEOAGE_CPT -G${GEOAGE_COLORBAR_MIN}/${GEOAGE_COLORBAR_MAX} -T${GEOAGE_COLORBAR_MIN}/${GEOAGE_COLORBAR_MAX}/10 ${VERBOSE} > ${F_CPTS}geoage_colorbar.cpt
      #
      #     echo "G ${LEGEND_BAR_GAP}" >> ${LEGENDDIR}legendbars.txt
      #     echo "B ${F_CPTS}geoage_colorbar.cpt 0.2i ${LEGEND_BAR_HEIGHT}+malu -Bxa100f50+l\"Age (Ma)\"" >> ${LEGENDDIR}legendbars.txt
      #     barplotcount=$barplotcount+1
      #   fi
      #   ;;

# Requires CPT
  		grav)
        if [[ -e $GRAV_CPT ]]; then
          echo "G ${LEGEND_BAR_GAP}" >> ${LEGENDDIR}legendbars.txt
          echo "B $GRAV_CPT 0.2i ${LEGEND_BAR_HEIGHT}+malu ${LEGENDBAR_OPTS} -Bxaf+l\"$GRAVMODEL gravity (mgal)\"" >> ${LEGENDDIR}legendbars.txt
          barplotcount=$barplotcount+1
        fi
  			;;

# Requires CPT
      gravcurv)
        if [[ -e $GRAV_CURV_CPT ]]; then
          echo "G ${LEGEND_BAR_GAP}" >> ${LEGENDDIR}legendbars.txt
          echo "B $GRAV_CURV_CPT 0.2i ${LEGEND_BAR_HEIGHT}+malu ${LEGENDBAR_OPTS} -Bxa100f50+l\"$GRAVMODEL curvature (mgal)\"" >> ${LEGENDDIR}legendbars.txt
          barplotcount=$barplotcount+1
        fi
        ;;

# Requires CPT and LITHO1_TYPE variable
      litho1)
        if [[ $LITHO1_TYPE == "density" ]]; then
          echo "G ${LEGEND_BAR_GAP}" >> ${LEGENDDIR}legendbars.txt
          echo "B $LITHO1_DENSITY_CPT 0.2i ${LEGEND_BAR_HEIGHT}+malu ${LEGENDBAR_OPTS} -t${LITHO1_TRANS}+f -Bxa500f50+l\"LITHO1.0 density (kg/m^3)\"" >> ${LEGENDDIR}legendbars.txt
          barplotcount=$barplotcount+1
        elif [[ $LITHO1_TYPE == "Vp" ]]; then
          echo "G ${LEGEND_BAR_GAP}" >> ${LEGENDDIR}legendbars.txt
          echo "B $LITHO1_VELOCITY_CPT 0.2i ${LEGEND_BAR_HEIGHT}+malu ${LEGENDBAR_OPTS} -t${LITHO1_TRANS}+f -Bxa1000f250+l\"LITHO1.0Vp velocity (m/s)\"" >> ${LEGENDDIR}legendbars.txt
          barplotcount=$barplotcount+1
        elif [[ $LITHO_TYPE == "Vs" ]]; then
          echo "G ${LEGEND_BAR_GAP}" >> ${LEGENDDIR}legendbars.txt
          echo "B $LITHO1_VELOCITY_CPT 0.2i ${LEGEND_BAR_HEIGHT}+malu ${LEGENDBAR_OPTS} -t${LITHO1_TRANS}+f -Bxa1000f250+l\"LITHO1.0 Vs velocity (m/s)\"" >> ${LEGENDDIR}legendbars.txt
          barplotcount=$barplotcount+1
        fi
        ;;


      # oceanage)
      #   echo "G ${LEGEND_BAR_GAP}" >> ${LEGENDDIR}legendbars.txt
      #   echo "B $OC_AGE_CPT 0.2i ${LEGEND_BAR_HEIGHT}+malu -Bxa50+l\"Ocean crust age (Ma)\"" >> ${LEGENDDIR}legendbars.txt
      #   barplotcount=$barplotcount+1
      #   ;;

# Requires CPT
      plateazdiff)
        echo "G ${LEGEND_BAR_GAP}" >> ${LEGENDDIR}legendbars.txt
        echo "B ${CPTDIR}cycleaz.cpt 0.2i ${LEGEND_BAR_HEIGHT}+malu ${LEGENDBAR_OPTS} -Bxa90f30+l\"Azimuth difference (°)\"" >> ${LEGENDDIR}legendbars.txt
        barplotcount=$barplotcount+1
        ;;

# Requires CPT
      platevelgrid)
        echo "G ${LEGEND_BAR_GAP}" >> ${LEGENDDIR}legendbars.txt
        echo "B $PLATEVELGRID_CPT 0.2i ${LEGEND_BAR_HEIGHT}+malu ${LEGENDBAR_OPTS} -Bxa50f10+l\"Plate velocity (mm/yr)\"" >> ${LEGENDDIR}legendbars.txt
        barplotcount=$barplotcount+1
        ;;

# Requires CPT and SSUNIFORM variable
      seissum)
        if [[ $SSUNIFORM -eq 1 ]]; then
          echo "G ${LEGEND_BAR_GAP}" >> ${LEGENDDIR}legendbars.txt
          echo "B ${F_CPTS}seissum.cpt 0.2i ${LEGEND_BAR_HEIGHT}+malu ${LEGENDBAR_OPTS} -Bxaf+l\"Earthquake count\"" >> ${LEGENDDIR}legendbars.txt
        else
          echo "G ${LEGEND_BAR_GAP}" >> ${LEGENDDIR}legendbars.txt
          echo "B ${F_CPTS}seissum.cpt 0.2i ${LEGEND_BAR_HEIGHT}+malu ${LEGENDBAR_OPTS} -Bxaf+l\"M0 (x10^N) dyne*cm\"" >> ${LEGENDDIR}legendbars.txt
        fi
        barplotcount=$barplotcount+1
        ;;

# Requires CPT and BATHYINC
      topo)
        if [[ $dontplottopoflag -ne 1 && $tsentflag -ne 1 && $notopobarflag -ne 1 ]]; then
          topotranslevel=$(echo "$DEM_ALPHA * 100" | bc -l)
          if [[ $fasttopoflag -eq 0 ]]; then
            gmt makecpt -Fr -C${TOPO_CPT} -A$topotranslevel > ${F_CPTS}topotrans.cpt
            echo "G ${LEGEND_BAR_GAP}" >> ${LEGENDDIR}legendbars.txt
            echo "B ${F_CPTS}topotrans.cpt 0.2i ${LEGEND_BAR_HEIGHT}+malu ${LEGENDBAR_OPTS} -Bxa${BATHYXINC}f1+l\"Elevation (km)\"" -W0.001 >> ${LEGENDDIR}legendbars.txt
          else
            echo "G ${LEGEND_BAR_GAP}" >> ${LEGENDDIR}legendbars.txt
            echo "B ${TOPO_CPT} 0.2i ${LEGEND_BAR_HEIGHT}+malu ${LEGENDBAR_OPTS} -Bxa${BATHYXINC}+l\"Elevation (km)\"" -W0.001 >> ${LEGENDDIR}legendbars.txt
          fi
          barplotcount=$barplotcount+1
        fi
        ;;

# Modules
      *)
        tectoplot_legendbar_caught=0

        eval "((${legendbar_plot}_legendbar_callnum++))"
        eval "tt=\${${legendbar_plot}_legendbar_callnum}"

        for this_mod in ${TECTOPLOT_MODULES[@]}; do
          if type "tectoplot_legendbar_${this_mod}" >/dev/null 2>&1; then
            cmd="tectoplot_legendbar_${this_mod}"
            "$cmd" ${legendbar_plot}
          fi
          if [[ $tectoplot_legendbar_caught -eq 1 ]]; then
            break
          fi
        done
        ;;

  	esac
  done

  velboxflag=0
  # [[ $barplotcount -eq 0 ]] && LEGEND_WIDTH=0.01


  LEG2_X=c
  LEG2_Y=c

  # The non-colorbar plots come next.
  GPS_ELLIPSE_TEXT=$(gawk -v c=0.95 'BEGIN{print c*100 "%" }')

  if [[ $legendnotextflag -ne 1 ]]; then
    info_msg "Legend: printing data sources"
    # gmt pstext tectoplot.shortplot -F+f6p,Helvetica,black $KEEPOPEN $VERBOSE >> map.ps
    # x y fontinfo angle justify linespace parwidth parjust
    LEGEND_SOURCES_WIDTH=$(gawk -v lw=${LEGEND_WIDTH} 'BEGIN{print (lw+0) - 0.7}' )
    echo "> ${CENTERLON} ${CENTERLAT} 0.1i ${LEGEND_SOURCES_WIDTH}i l" > datasourceslegend.txt
    [[ -s ${SHORTSOURCES} ]] && uniq ${SHORTSOURCES} | tr '\n' ' ' >> datasourceslegend.txt
  fi

#
function init_legend_item() {
  # $1 = ID
  info_msg "Opening legend item: $1"

  gmt psxy -T ${RJSTRING} -Xc -Yc -K ${VERBOSE} > ${LEGENDDIR}${1}.ps
  LEGFILE="${LEGENDDIR}${1}.ps"
}

function close_legend_item() {
  # $1 = ID
  gmt psxy -T -R -J -O ${VERBOSE} >> ${LEGENDDIR}${1}.ps
  PS_DIM=$(gmt psconvert ${LEGENDDIR}${1}.ps -Te -A+m0.05i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
  LEGEND_ITEM_PATHS+=("${LEGENDDIR}${1}.eps")
  LEGEND_ITEM_WIDTHS+=("$(echo $PS_DIM | gawk '{print $1/2.54}')")
  LEGEND_ITEM_HEIGHTS+=("$(echo $PS_DIM | gawk '{print $2/2.54}')")
  LEGEPSFILE="${LEGENDDIR}${1}.eps"

  info_msg "Closing legend item: $1"

}


  if [[ $makecolorbarsflag -eq 1 ]]; then
    # Split the color bars apart so they can be added horizontally
    if [[ $colorbarshorizontalflag -eq 1 ]]; then
      xoffset=0
      while read p; do
        if [[ ${p:0:1} == "B" ]]; then
          echo "${p}" > tmplegend.txt
          gmt pslegend tmplegend.txt -Dx0i/0i+w${LEGEND_WIDTH}i+jBL -C0.05i/0.05i ${VERBOSE} -X${x_offset}i --FONT_ANNOT_PRIMARY=${LEGEND_FONTDEF} --FONT_LABEL=${LEGEND_FONTDEF} --MAP_TICK_LENGTH_PRIMARY="${LEGEND_TICK_LENGTH}"  ${RJOK} >> ${COLORBARLEGEND}
          x_offset=$(echo ${LEGEND_WIDTH} | gawk '{print $1}')
        fi
      done < ${LEGENDDIR}legendbars.txt
      gmt psxy -T -J -R -O >> ${COLORBARLEGEND}
    else
      gmt pslegend ${LEGENDDIR}legendbars.txt -Dx0i/0i+w${LEGEND_WIDTH}i+jBL -C0.05i/0.05i -J -R -O ${VERBOSE} --FONT_ANNOT_PRIMARY=${LEGEND_FONTDEF} --FONT_LABEL=${LEGEND_FONTDEF} --MAP_TICK_LENGTH_PRIMARY="${LEGEND_TICK_LENGTH}" >> ${COLORBARLEGEND}
    fi
  fi

  if [[ $makenoncolorbarsflag -eq 1 ]]; then

    NONCOLORBARLEGEND=${LEGENDDIR}noncolorbars.ps
    # Offset origin to above the legend bar plots and offset X so left side of box
    # is around the start of the rectangular bar plot
    # Initialize the non-colorbar legend
    gmt psxy -T ${RJSTRING} -Xc -Yc -K $VERBOSE > ${NONCOLORBARLEGEND}

    info_msg "Plotting non-colorbar legend items: ${plots[@]}"

    for legend_plot in ${plots[@]} ; do
    	case $legend_plot in
        projlegend)
          init_legend_item "projlegend"
          echo "$CENTERLON $CENTERLAT Projection: ${projname}" | gmt pstext -F+f6p,Helvetica,black+jRB -D-32p/2p $VERBOSE -J -R -O -K >> ${LEGFILE}
          close_legend_item "projlegend"

        ;;
        pstrain)
        info_msg "Legend: pstrain"
        init_legend_item "pstrain"

          echo "$CENTERLON $CENTERLAT ${PSTRAIN_TYPE}" | gmt pstext -F+f6p,Helvetica,black+jRB -D-32p/2p $VERBOSE -J -R -O -K >> ${LEGFILE}
          echo "$CENTERLON $CENTERLAT @%12%e@-11@-@%%=${PSTRAIN_MAXSTR[2]} / @%12%e@-33@-@%%=${PSTRAIN_MAXSTR[3]}" | gmt pstext -F+f6p,Helvetica,black+jRT -D-32p/-2p $VERBOSE -J -R -O -K >> ${LEGFILE}

          echo ${PSTRAIN_MAXSTR[@]} | gawk -v clon=${CENTERLON} -v clat=${CENTERLAT} '{print clon, clat, $3, 0, $5 }' | \
            gmt psvelo -Sx${PSTRAIN_SIZE_ADJ}p -W${PSTRAIN_WIDTH},${PSTRAIN_COLOR_MAX} -A0.01/0.3/0.12 ${RJOK} ${VERBOSE}  >> ${LEGFILE}

          echo ${PSTRAIN_MAXSTR[@]} | gawk -v clon=${CENTERLON} -v clat=${CENTERLAT} '{print clon, clat, 0, $4, $5 }' | \
            gmt psvelo -Sx${PSTRAIN_SIZE_ADJ}p -W${PSTRAIN_WIDTH},${PSTRAIN_COLOR_MIN} -A0.01/0.3/0.12 ${RJOK} ${VERBOSE}  >> ${LEGFILE}

        close_legend_item "pstrain"
        ;;

        cmt)
        info_msg "Legend: cmt"
        init_legend_item "cmt"

          CMAXMAG=$(echo ${CMT_MAXMAG} 7 | gawk '{print ($2<$1)?$2:$1}')

          MEXP_V_N=${CMAXMAG}
          MEXP_V_S=${CMAXMAG}
          MEXP_V_T=${CMAXMAG}

          MEXP_N=($(stretched_m0_from_mw $MEXP_V_N))
          MEXP_S=($(stretched_m0_from_mw $MEXP_V_S))
          MEXP_T=($(stretched_m0_from_mw $MEXP_V_T))

          echo "$CENTERLON $CENTERLAT Focal" | gmt pstext -F+f6p,Helvetica,black+jCM+a90 $VERBOSE -J -R -O -K >> ${LEGFILE}
          echo "$CENTERLON $CENTERLAT mechanism" | gmt pstext -F+f6p,Helvetica,black+jCM+a90 $VERBOSE -X6p -J -R -O -K >> ${LEGFILE}

          psvelostroke="-W1p,black"
          psvelostroke="-W0p"
          CMT_AXESSCALE_LEGEND=0.007

          echo "$CENTERLON $CENTERLAT 10 -2.960 0.874 2.090 -0.215 -0.075 -0.842 ${MEXP_N[1]}" | gmt_psmeca_wrapper $CMT_CPT -E"${CMT_NORMALCOLOR}" -L${CMT_LINEWIDTH},${CMT_LINECOLOR}  -Tn/${CMT_LINEWIDTH},${CMT_LINECOLOR} -S${CMTLETTER}0.1i/0 $RJOK -X0.27i ${VERBOSE} >> ${LEGFILE}
          if [[ $axescmtnormalflag -eq 1 ]]; then
            [[ $axestflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT -44.5503 -22.6995 0 0 0" | gmt psvelo ${psvelostroke} -G${T_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE_LEGEND}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> ${LEGFILE}
            [[ $axestflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 44.5503 22.6995 0 0 0" | gmt psvelo ${psvelostroke} -G${T_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE_LEGEND}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> ${LEGFILE}
            echo "$CENTERLON $CENTERLAT T" | gmt pstext -F+f4p,Helvetica,${T_AXIS_COLOR}+jCB $VERBOSE -J -R -Xa-.16i -Ya-0.085i -O -K >> ${LEGFILE}

            [[ $axespflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT -1.30656 3.23385 0 0 0" | gmt psvelo ${psvelostroke} -G${P_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE_LEGEND}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> ${LEGFILE}
            [[ $axespflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 1.30656 -3.23385 0 0 0" | gmt psvelo ${psvelostroke} -G${P_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE_LEGEND}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> ${LEGFILE}

            [[ $axesnflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 22.6442 -44.4418 0 0 0" | gmt psvelo ${psvelostroke} -G${N_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE_LEGEND}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> ${LEGFILE}
            [[ $axesnflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT -22.6442 44.4418 0 0 0" | gmt psvelo ${psvelostroke} -G${N_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE_LEGEND}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> ${LEGFILE}
            echo "$CENTERLON $CENTERLAT N" | gmt pstext -F+f4p,Helvetica,${N_AXIS_COLOR}+jCB $VERBOSE -J -R -Xa.09i -Ya-0.17i -O -K >> ${LEGFILE}

          fi
          echo "$CENTERLON $CENTERLAT Normal" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE -J -R -Ya0.15i -O -K >> ${LEGFILE}

          echo "$CENTERLON $CENTERLAT 10 -0.378 -0.968 1.350 -2.330 0.082 4.790 ${MEXP_S[1]}" | gmt_psmeca_wrapper $CMT_CPT -E"${CMT_SSCOLOR}" -L${CMT_LINEWIDTH},${CMT_LINECOLOR} -Tn/${CMT_LINEWIDTH},${CMT_LINECOLOR} -S${CMTLETTER}0.1i/0 -X0.5i ${RJOK} ${VERBOSE} >> ${LEGFILE}
          if [[ $axescmtssflag -eq 1 ]]; then
            [[ $axestflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 36.6146 -31.8286 0 0 0" | gmt psvelo ${psvelostroke} -G${T_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE_LEGEND}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> ${LEGFILE}
            [[ $axestflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT -36.6146 31.8286 0 0 0" | gmt psvelo ${psvelostroke} -G${T_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE_LEGEND}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> ${LEGFILE}
            echo "$CENTERLON $CENTERLAT T" | gmt pstext -F+f4p,Helvetica,${T_AXIS_COLOR}+jCB $VERBOSE -J -R -Xa0.12i -Ya-0.14i -O -K >> ${LEGFILE}

            [[ $axespflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 26.774 38.2372 0 0 0" | gmt psvelo ${psvelostroke} -G${P_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE_LEGEND}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> ${LEGFILE}
            [[ $axespflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT -26.774 -38.2372 0 0 0" | gmt psvelo ${psvelostroke} -G${P_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE_LEGEND}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> ${LEGFILE}
            echo "$CENTERLON $CENTERLAT P" | gmt pstext -F+f4p,Helvetica,${P_AXIS_COLOR}+jCB $VERBOSE -J -R -Xa-.10i -Ya-0.15i -O -K >> ${LEGFILE}

            [[ $axesnflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT -20.8458 -6.77321 0 0 0" | gmt psvelo ${psvelostroke} -G${N_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE_LEGEND}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> ${LEGFILE}
            [[ $axesnflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 20.8458 6.77321 0 0 0" | gmt psvelo ${psvelostroke} -G${N_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE_LEGEND}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> ${LEGFILE}

          fi
          echo "$CENTERLON $CENTERLAT Strike-slip" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE -J -R -Ya0.15i -O -K >> ${LEGFILE}
          # echo "$CENTERLON $CENTERLAT strike-slip" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE -J -R -Y0.20i -O -K >> ${LEGFILE}

          # Plot thrust event in legend

          echo "$CENTERLON $CENTERLAT 15 5.260 -0.843 -4.410 3.950 -2.910 2.100 ${MEXP_T[1]}" | gmt_psmeca_wrapper $CMT_CPT -E"${CMT_THRUSTCOLOR}" -L${CMT_LINEWIDTH},${CMT_LINECOLOR} -Tn/${CMT_LINEWIDTH},${CMT_LINECOLOR} -S${CMTLETTER}0.1i/0 -X0.5i ${RJOK} ${VERBOSE} >> ${LEGFILE}

          if [[ $axescmtthrustflag -eq 1 ]]; then
            [[ $axestflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 7.57264 19.7274 0 0 0" | gmt psvelo ${psvelostroke} -G${T_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE_LEGEND}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> ${LEGFILE}
            [[ $axestflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT -7.57264 -19.7274 0 0 0" | gmt psvelo ${psvelostroke} -G${T_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE_LEGEND}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> ${LEGFILE}

            [[ $axespflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT -39.8452 -24.8981 0 0 0" | gmt psvelo ${psvelostroke} -G${P_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE_LEGEND}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> ${LEGFILE}
            [[ $axespflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 39.8452 24.8981 0 0 0" | gmt psvelo ${psvelostroke} -G${P_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE_LEGEND}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> ${LEGFILE}
            echo "$CENTERLON $CENTERLAT P" | gmt pstext -F+f4p,Helvetica,${P_AXIS_COLOR}+jCB $VERBOSE -J -R -Xa-.14i -Ya-0.09i -O -K >> ${LEGFILE}

            [[ $axesnflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 29.1969 -38.7456 0 0 0" | gmt psvelo ${psvelostroke} -G${N_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE_LEGEND}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> ${LEGFILE}
            [[ $axesnflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT -29.1969 38.7456 0 0 0" | gmt psvelo ${psvelostroke} -G${N_AXIS_COLOR} -A${ARROWFMT} -Se${CMT_AXESSCALE_LEGEND}/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> ${LEGFILE}
            echo "$CENTERLON $CENTERLAT N" | gmt pstext -F+f4p,Helvetica,${N_AXIS_COLOR}+jCB $VERBOSE -J -R -Xa.12i -Ya-0.15i -O -K >> ${LEGFILE}

          fi
          echo "$CENTERLON $CENTERLAT Reverse" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE ${RJOK} -Ya0.15i >> ${LEGFILE}

          close_legend_item "cmt"

          # PS_DIM=$(gmt psconvert ${LEGFILE} -Te -A+m0.05i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
          # PS_WIDTH_IN=$(echo $PS_DIM | gawk  '{print $1/2.54}')
          # PS_HEIGHT_IN=$(echo $PS_DIM | gawk  '{print $2/2.54}')
          # # plot_legend_item "cmt" ${NONCOLORBARLEGEND}
          #
          # gmt psimage -Dx"${LEG2_X}i/${LEG2_Y}i"+w${PS_WIDTH_IN}i ${LEGEPSFILE} $RJOK ${VERBOSE} >> ${NONCOLORBARLEGEND}
          # if [[ $horizlegendflag -eq 1 ]]; then
          #   LEG2_X=$(echo "$LEG2_X + $PS_WIDTH_IN + 0.2" | bc -l)
          # else
          #   LEG2_Y=$(echo "$LEG2_Y + $PS_HEIGHT_IN + 0.02" | bc -l)
          # fi
          ;;

        eqlabel)
          info_msg "Legend: eqlabel"
          init_legend_item "eqlabel"

          [[ $EQ_LABELFORMAT == "idmag"   ]]  && echo "$CENTERLON $CENTERLAT ID Mw" | gawk '{ printf "%s %s %s %s\n", $1, $2, $3, $4 }'      > eqlabel.legend.txt
          [[ $EQ_LABELFORMAT == "datemag" ]]  && echo "$CENTERLON $CENTERLAT Date Mw" | gawk '{ printf "%s %s %s %s\n", $1, $2, $3, $4 }'    > eqlabel.legend.txt
          [[ $EQ_LABELFORMAT == "datetime" ]]  && echo "$CENTERLON $CENTERLAT Date Time (UTC)" | gawk '{ printf "%s %s %s %s\n", $1, $2, $3, $4 }'    > eqlabel.legend.txt
          [[ $EQ_LABELFORMAT == "dateid"  ]]  && echo "$CENTERLON $CENTERLAT Date ID" | gawk '{ printf "%s %s %s(%s)\n", $1, $2, $3, $4 }'    > eqlabel.legend.txt
          [[ $EQ_LABELFORMAT == "id"      ]]  && echo "$CENTERLON $CENTERLAT ID" | gawk '{ printf "%s %s %s\n", $1, $2, $3 }'                 > eqlabel.legend.txt
          [[ $EQ_LABELFORMAT == "date"    ]]  && echo "$CENTERLON $CENTERLAT Date" | gawk '{ printf "%s %s %s\n", $1, $2, $3 }'               > eqlabel.legend.txt
          [[ $EQ_LABELFORMAT == "year"    ]]  && echo "$CENTERLON $CENTERLAT Year" | gawk '{ printf "%s %s %s\n", $1, $2, $3 }'               > eqlabel.legend.txt
          [[ $EQ_LABELFORMAT == "yearmag" ]]  && echo "$CENTERLON $CENTERLAT Year Mw" | gawk '{ printf "%s %s %s %s\n", $1, $2, $3, $4 }'    > eqlabel.legend.txt
          [[ $EQ_LABELFORMAT == "mag"     ]]  && echo "$CENTERLON $CENTERLAT Mw" | gawk '{ printf "%s %s %s\n", $1, $2, $3 }'                 > eqlabel.legend.txt
          [[ $EQ_LABELFORMAT == "time" ]]  && echo "$CENTERLON $CENTERLAT Time (UTC)" | gawk '{ printf "%s %s %s %s\n", $1, $2, $3, $4}'    > eqlabel.legend.txt

          cat eqlabel.legend.txt | gmt pstext -Gwhite -W0.2p,black -F+f${EQ_LABEL_FONTSIZE},${EQ_LABEL_FONT},${EQ_LABEL_FONTCOLOR}+j${EQ_LABEL_JUST} ${RJOK} ${VERBOSE} >> ${LEGFILE}

          close_legend_item "eqlabel"

          ;;

        graticule)
          echo "none" > /dev/null
        ;;

        grid)
          info_msg "Legend: velocity grid"
          init_legend_item "grid"


          # GRIDMAXVEL_INT=$(echo "scale=0;($GRIDMAXVEL)/1" | bc)
          GRIDMAXVEL_INT=20

          GRIDMESSAGE="Plate velocity/$(echo ${REFPLATE} | gawk -F_ '{print $1}') ($GRIDMAXVEL_INT mm/yr)"
          GRIDoffset=$(echo "(${#GRIDMESSAGE} + 2)* 6 * 0.5" | bc -l)

          echo "$CENTERLON $CENTERLAT ${GRIDMESSAGE}" | gmt pstext -F+f6p,Helvetica,black+jLM -X0.15i ${RJOK} ${VERBOSE} >> ${LEGFILE}
          if [[ $PLATEVEC_COLOR =~ "white" ]]; then
            echo "$CENTERLON $CENTERLAT $GRIDMAXVEL_INT 0 0 0 0 0 ID" | gmt psvelo -W0p,gray@$PLATEVEC_TRANS -Ggray@$PLATEVEC_TRANS -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 -L $RJOK -X${GRIDoffset}p $VERBOSE >> ${LEGFILE} 2>/dev/null
          else
            echo "$CENTERLON $CENTERLAT $GRIDMAXVEL_INT 0 0 0 0 0 ID" | gmt psvelo -W0p,$PLATEVEC_COLOR@$PLATEVEC_TRANS -G$PLATEVEC_COLOR@$PLATEVEC_TRANS -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 -L -X${GRIDoffset}p $RJOK $VERBOSE >> ${LEGFILE} 2>/dev/null
          fi

          close_legend_item "grid"
          ;;

        gps)
          info_msg "Legend: gps"
          init_legend_item "gps"

          GPSMAXVEL_INT=$(echo "scale=0;($GPSMAXVEL)/1" | bc)
          GPSMESSAGE="GPS ($GPSMAXVEL_INT mm/yr / ${GPS_ELLIPSE_TEXT})"
          GPSoffset=$(echo "(${#GPSMESSAGE} + 2)* 6 * 0.5" | bc -l)
          echo "$CENTERLON $CENTERLAT ${GPSMESSAGE}" | gmt pstext -F+f6p,Helvetica,black+jLM -X0.15i ${RJOK} ${VERBOSE} >> ${LEGFILE}
          echo "$CENTERLON $CENTERLAT $GPSMAXVEL_INT 0 1 1 0 ID" | gmt psvelo -W${GPS_LINEWIDTH},${GPS_LINECOLOR} -G${GPS_FILLCOLOR} -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 -X${GPSoffset}p -L ${RJOK} $VERBOSE >> ${LEGFILE} 2>/dev/null

          close_legend_item "gps"
          ;;

        kinsv)
          info_msg "Legend: kinsv"
          init_legend_item "kinsv"

          echo "$CENTERLON $CENTERLAT" | gmt psxy -Ss0.4i -W0p,lightblue -Glightblue $RJOK -X0.4i $VERBOSE >> ${LEGFILE}
          echo "$CENTERLON $CENTERLAT 31 .35" | gmt psxy -SV0.05i+jb+e -W0.4p,${NP1_COLOR} -G${NP1_COLOR} $RJOK $VERBOSE >> ${LEGFILE}
          if [[ $plottedkinsd -eq 1 ]]; then # Don't close
            echo "$CENTERLON $CENTERLAT 235 .35" | gmt psxy -SV0.05i+jb+e -W0.4p,${NP2_COLOR} -G${NP2_COLOR} $RJOK $VERBOSE >> ${LEGFILE}
          else
            echo "$CENTERLON $CENTERLAT 235 .35" | gmt psxy -SV0.05i+jb+e -W0.4p,${NP2_COLOR} -G${NP2_COLOR} $RJOK $VERBOSE >> ${LEGFILE}
          fi
          if [[ $plottedkinsd -eq 1 ]]; then
            echo "$CENTERLON $CENTERLAT 55 .1" | gmt psxy -SV0.05i+jb -W0.5p,${NP1_COLOR} -G${NP1_COLOR} $RJOK $VERBOSE >> ${LEGFILE}
            echo "$CENTERLON $CENTERLAT 325 0.35" | gmt psxy -SV0.05i+jc -W0.5p,${NP1_COLOR} -G${NP1_COLOR} $RJOK $VERBOSE >> ${LEGFILE}
            echo "$CENTERLON $CENTERLAT 211 .1" | gmt psxy -SV0.05i+jb -W0.5p,${NP2_COLOR} -G${NP2_COLOR} $RJOK $VERBOSE >> ${LEGFILE}
            echo "$CENTERLON $CENTERLAT 121 0.35" | gmt psxy -SV0.05i+jc -W0.5p,${NP2_COLOR} -G${NP2_COLOR} $RJOK $VERBOSE >> ${LEGFILE}
          fi
          KINMESSAGE="CMT slip vectors"
          echo "$CENTERLON $CENTERLAT $KINMESSAGE" | gmt pstext -F+f6p,Helvetica,black+jLC $VERBOSE ${RJOK} -Y.03i -X0.55i >> ${LEGFILE}
          echo "$CENTERLON $CENTERLAT plane 1 " | gmt pstext -F+f6p,Helvetica,${NP1_COLOR}+jRC $VERBOSE ${RJOK} -Ya-.12i -Xa-0.15i >> ${LEGFILE}
          echo "$CENTERLON $CENTERLAT plane 2 " | gmt pstext -F+f6p,Helvetica,${NP2_COLOR}+jRLC $VERBOSE ${RJOK} -Ya-.12i -Xa0.15i >> ${LEGFILE}

          close_legend_item "kinsv"
         ;;

        plate)
          # echo "$CENTERLON $CENTERLAT 90 1" | gmt psxy -SV$ARROWFMT -W${GPS_LINEWIDTH},${GPS_LINECOLOR} -G${GPS_FILLCOLOR} $RJOK $VERBOSE >> plate.ps
          # echo "$CENTERLON $CENTERLAT Kinematics stuff" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE -J -R -X0.2i -Y0.1i -O >> plate.ps
          # PS_DIM=$(gmt psconvert plate.ps -Te -A0.05i 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
          # PS_WIDTH_IN=$(echo $PS_DIM | gawk  '{print $1/2.54}')
          # PS_HEIGHT_IN=$(echo $PS_DIM | gawk  '{print $2/2.54}')
          # gmt psimage -Dx"${LEG2_X}i/${LEG2_Y}i"+w${PS_WIDTH_IN}i plate.ps $RJOK >> ${NONCOLORBARLEGEND}
          # LEG2_Y=$(echo "$LEG2_Y + $PS_HEIGHT_IN + 0.02" | bc -l)
          ;;

        seis)
          info_msg "Legend: seis"
          init_legend_item "seis"

          OLD_PROJ_LENGTH_UNIT=$(gmt gmtget PROJ_LENGTH_UNIT -Vn)
          gmt gmtset PROJ_LENGTH_UNIT p

          echo "$CENTERLON $CENTERLAT Earthquake" | gmt pstext -F+f6p,Helvetica,black+jCM+a90 $VERBOSE -J -R -O -K >> ${LEGFILE}
          echo "$CENTERLON $CENTERLAT magnitude" | gmt pstext -F+f6p,Helvetica,black+jCM+a90 $VERBOSE -X6p -J -R -O -K >> ${LEGFILE}
          gmt psxy -T -X0.07i ${RJOK} >> ${LEGFILE}

          EQ_LEG_MAX=$(gawk < ${F_SEIS}eqs.txt '
          @include "tectoplot_functions.awk"
          BEGIN {
            getline
            maxmag=$4
          }
          {
            maxmag=($4>maxmag)?$4:maxmag
          }
          END {
            print ceil(maxmag)
          }')

          # # EQ_LEG_MAX=

          # if [[ $(echo "(${EQ_MAXMAG} == ${EQ_MAXMAG_DEF})" | bc) -eq 1 ]]; then
          #   EQ_LEG_MAX=8
          # fi

          for thismag in $(seq 2 $EQ_LEG_MAX); do
            if [[ $(echo "$thismag <= $EQ_MAXMAG && $thismag >= $EQ_MINMAG" | bc) -eq 1 ]]; then
              # stretched_mag is the diameter of the earthquake symbol in points
              stretched_mag=$(stretched_mw_from_mw $thismag ${SEISSTRETCH} ${SEISSTRETCH_REFMAG})
              stretched_mag_over_2_plus_2=$(echo "$stretched_mag / 2 + 2" | bc -l)
              stretched_mag_over_2_plus_10=$(echo "$stretched_mag / 2 + 8 + ($stretched_mag-8>=0)*($stretched_mag-8)/2" | bc -l)
              yshift=$(echo "($thismag * 2 - 2)/100" | bc -l)
              echo "$CENTERLON $CENTERLAT $stretched_mag DATESTR ID" | gmt psxy -W0.5p,black -G${ZSFILLCOLOR} -i0,1,2+s${SEISSCALE} -S${SEISSYMBOL} -t${SEISTRANS} $RJOK -X${stretched_mag_over_2_plus_10}p ${VERBOSE} >> ${LEGFILE}
              # echo "$CENTERLON $CENTERLAT $stretched_mag DATESTRE ID" | gmt psxy -St${stretched_mag}p -W0.2p,red ${RJOK} >> ${LEGFILE}
              echo "$CENTERLON $CENTERLAT $thismag" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE -J -R -Ya${stretched_mag_over_2_plus_10}p -O -K >> ${LEGFILE}
            fi
          done

          gmt gmtset PROJ_LENGTH_UNIT $OLD_PROJ_LENGTH_UNIT

          close_legend_item "seis"
          ;;

        *)  # Any unrecognized command is potentially a module command that needs a legend

        eval "((${legend_plot}_legend_callnum++))"
        eval "tt=\${${legend_plot}_legend_callnum}"

        tectoplot_legend_caught=0
        for this_mod in ${TECTOPLOT_MODULES[@]}; do

          if type "tectoplot_legend_${this_mod}" >/dev/null 2>&1; then
            # info_msg "Running module post-processing for ${plot}"
            cmd="tectoplot_legend_${this_mod}"
            "$cmd" ${legend_plot}
          fi
          if [[ $tectoplot_legend_caught -eq 1 ]]; then
            break
          fi
        done

        ;;
      esac
    done


    if [[ -s datasourceslegend.txt ]]; then
      info_msg "[-legend]: adding data sources"
      numsources=$(wc -l < datasourceslegend.txt)
          if [[ $makecreditline -eq 1 ]]; then
        echo "" >> datasourceslegend.txt
        echo "" >> datasourceslegend.txt
        echo ${CREDITLINE} >> datasourceslegend.txt
    fi

      if [[ $numsources -ge 1 ]]; then
        init_legend_item "datasources"
        echo "${CENTERLON} ${CENTERLAT} Data sources " | gmt pstext -F+f6p,Helvetica-bold,black+jLM ${RJOK} ${VERBOSE} >> ${LEGFILE}
        gmt pstext datasourceslegend.txt -M -N -Xa0.6i -F+f6p,Helvetica,black+jLM ${RJOK} ${VERBOSE} >> ${LEGFILE}
        close_legend_item "datasources"
      fi
    fi

    # if [[ $makecreditline -eq 1 ]]; then
    #   init_legend_item "credit"
    #   echo "$CENTERLON $CENTERLAT ${CREDITLINE}" | gmt pstext -F+f5p,Helvetica-bold,black+jCB $VERBOSE ${RJOK} >> ${LEGFILE}
    #   close_legend_item "credit"
    # fi


    gmt psxy -T ${RJSTRING} -Xc -Yc -K $VERBOSE > ${NONCOLORBARLEGEND}
    LEG2_X=0
    LEG2_Y=0
    OLD_LEG2_X=0
    OLD_LEG2_Y=0

    if [[ $noncolorbarhorizontalflag -eq 1 ]]; then
      # Calculate the maximum height of the input objects
      TALLEST_Y=$(echo "${LEGEND_ITEM_HEIGHTS[@]}" | tr ' ' '\n' | sort -nr | head -n1)
      # Assemble the final legend either horizontally or vertically
      # Create the legend separator

      gmt psxy -T ${RJSTRING} -Xc -Yc -K ${VERBOSE} > ${LEGENDDIR}separator.ps
      lat2=$(echo "${CENTERLAT}+1"| bc -l)
      # echo "${CENTERLON} ${CENTERLAT}t${CENTERLON} ${lat2}" | tr 't' '\n' | gmt psxy -W0.2p,black $VERBOSE -J -R -O -K >> ${LEGENDDIR}separator.ps
      gmt psxy -T -R -J -O ${VERBOSE} >> ${LEGENDDIR}separator.ps
      gmt psconvert ${LEGENDDIR}separator.ps -Te -A+m0.05i -Vn
      if [[ ${#LEGEND_ITEM_PATHS[@]} -gt 0 ]]; then
        for ind in $(seq 1 ${#LEGEND_ITEM_PATHS[@]}); do
          ((ind--))
          LEG_Y=$(echo "(${TALLEST_Y} - ${LEGEND_ITEM_HEIGHTS[$ind]}) / 2" | bc -l)
          gmt psimage -Dx0i/0i+w${LEGEND_ITEM_WIDTHS[$ind]}i+jCL ${LEGEND_ITEM_PATHS[$ind]} -X${OLD_LEG2_X}i -Ya${LEG_Y}i $RJOK ${VERBOSE} >> ${NONCOLORBARLEGEND}
          OLD_LEG2_X=${LEGEND_ITEM_WIDTHS[$ind]}
          if [[ $(echo "($ind + 1) != ${#LEGEND_ITEM_HEIGHTS[@]}" | bc) -eq 1 ]]; then
            offset=$(echo "${OLD_LEG2_X}+0" | bc -l)
            OLD_LEG2_X=$(echo "${OLD_LEG2_X}+0.1" | bc -l)
            gmt psimage -Dx0i/0i+w0.1i/${TALLEST_Y}i+jCL ${LEGENDDIR}separator.eps -Xa${offset}i $RJOK ${VERBOSE} >> ${NONCOLORBARLEGEND}
          fi
        done
      fi
    else
      # Calculate the maximum width of the input objects
      WIDEST_X=$(echo "${LEGEND_ITEM_WIDTHS[@]}" | tr ' ' '\n' | sort -nr | head -n1)
      # Assemble the final legend either horizontally or vertically
      if [[ ${#LEGEND_ITEM_PATHS[@]} -gt 0 ]]; then
        for ind in $(seq 1 ${#LEGEND_ITEM_PATHS[@]}); do
          ((ind--))
          LEG_X=$(echo "(${WIDEST_X} - ${LEGEND_ITEM_WIDTHS[$ind]}) / 2" | bc -l)
          gmt psimage -Dx0i/0i+w${LEGEND_ITEM_WIDTHS[$ind]}i+jCL ${LEGEND_ITEM_PATHS[$ind]} -Xa${LEG_X}i -Y${OLD_LEG2_Y}i $RJOK ${VERBOSE} >> ${NONCOLORBARLEGEND}
          OLD_LEG2_Y=${LEGEND_ITEM_HEIGHTS[$ind]}
        done
      fi
    fi
    gmt psxy -T -R -J -O $VERBOSE >> ${NONCOLORBARLEGEND}
  fi


  # If necessary, combine the non-colorbar legend into a single legend file.
  # This happens if we have only 1 justification code

  if [[ $(echo "${#LEGEND_JUST_CODES[@]} == 1" | bc) -eq 1 ]]; then

    # If we have both, then combine them
    if [[ $makecolorbarsflag -eq 1 && $makenoncolorbarsflag -eq 1 ]]; then

      PS_DIM=$(gmt psconvert ${COLORBARLEGEND} -Te -A+m0.05i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
      LEG_COLOR_WIDTH_IN=$(echo $PS_DIM | gawk  '{print $1/2.54}')
      LEG_COLOR_HEIGHT_IN=$(echo $PS_DIM | gawk  '{print $2/2.54}')

      PS_DIM=$(gmt psconvert ${NONCOLORBARLEGEND} -Te -A+m0.05i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
      LEG_NONCOLOR_WIDTH_IN=$(echo $PS_DIM | gawk  '{print $1/2.54}')
      LEG_NONCOLOR_HEIGHT_IN=$(echo $PS_DIM | gawk  '{print $2/2.54}')

      # Calculate the shift needed to center the colorbar and non-colorbar
      if [[ $(echo "(${LEG_COLOR_WIDTH_IN} > ${LEG_NONCOLOR_WIDTH_IN}) == 1" | bc ) -eq 1 ]]; then
        SHIFT_LEG_NONCOLOR=$(echo "(${LEG_COLOR_WIDTH_IN} - ${LEG_NONCOLOR_WIDTH_IN}) / 2" | bc -l)
        SHIFT_LEG_COLOR=0
      else
        SHIFT_LEG_COLOR=$(echo "(${LEG_NONCOLOR_WIDTH_IN} - ${LEG_COLOR_WIDTH_IN}) / 2" | bc -l)
        SHIFT_LEG_NONCOLOR=0
      fi

      gmt psxy -T ${RJSTRING} -Xc -Yc -K ${VERBOSE} > ${LEGENDDIR}maplegend.ps
      [[ -s ${LEGENDDIR}colorbars.eps ]] && gmt psimage -Dx0/0+w${LEG_COLOR_WIDTH_IN}i -Xa${SHIFT_LEG_COLOR}i ${LEGENDDIR}colorbars.eps ${RJOK} ${VERBOSE} >> ${LEGENDDIR}maplegend.ps
      [[ -s ${LEGENDDIR}noncolorbars.eps ]] && gmt psimage -Dx0/${LEG_COLOR_HEIGHT_IN}i+w${LEG_NONCOLOR_WIDTH_IN}i -Xa${SHIFT_LEG_NONCOLOR}i ${LEGENDDIR}noncolorbars.eps ${RJOK} ${VERBOSE} >> ${LEGENDDIR}maplegend.ps
      gmt psxy -T -R -J -O ${VERBOSE} >> ${LEGENDDIR}maplegend.ps
    elif [[ $makecolorbarsflag -eq 1 ]]; then
      cp ${COLORBARLEGEND} ${LEGENDDIR}maplegend.ps
    elif [[ $makenoncolorbarsflag -eq 1 ]]; then
      cp ${NONCOLORBARLEGEND} ${LEGENDDIR}maplegend.ps
    fi

    LEGENDITEMS+=("${LEGENDDIR}maplegend.ps")
  else
    # Otherwise, convert the PS to EPS for placement on the map
    [[ -s ${COLORBARLEGEND} ]] && LEGENDITEMS+=("${COLORBARLEGEND}")
    [[ -s ${NONCOLORBARLEGEND} ]] && LEGENDITEMS+=("${NONCOLORBARLEGEND}")
  fi

  if [[ $legendonlyflag -eq 1 && $cutframeflag -eq 1 ]]; then

    MINPROJ_X=$(echo "(0 - ${CUTFRAME_DISTANCE})" | bc -l)
    MAXPROJ_X=$(echo "(${PROJDIM[0]}/2.54 + 2*${CUTFRAME_DISTANCE})" | bc -l)
    MINPROJ_Y=$(echo "(0 - ${CUTFRAME_DISTANCE})" | bc -l)
    MAXPROJ_Y=$(echo "(${PROJDIM[1]}/2.53 + 2*${CUTFRAME_DISTANCE})" | bc -l)

    # Plot the cutframe as we have skipped the PLOT section

    gmt psbasemap -R0/${MAXPROJ_X}/0/${MAXPROJ_Y} -JX${MAXPROJ_X}i/${MAXPROJ_Y}i -Xa-${CUTFRAME_DISTANCE}i -Ya-${CUTFRAME_DISTANCE}i -Bltrb --MAP_FRAME_PEN=0.1p,black -O -K >> map.ps
    gmt psxy -T ${RJSTRING} -K -O ${VERBOSE} >> map.ps

    # Create the PDF and name it after the current temporary folder, move to ../
    # thisname=$(pwd | gawk -F/ '{print $(NF)}')
    # gmt psconvert -T map.ps -A+m0.5i
  fi

  if [[ $legendovermapflag -eq 1 ]]; then
    numlegenditems=$(echo "${#LEGENDITEMS[@]} - 1" | bc)
    for i in $(seq 0 ${numlegenditems}); do
      LEGEND_JUST=${LEGEND_JUST_CODES[$i]}
      rm -f placeme.eps
      PS_DIM=$(gmt psconvert ${LEGENDITEMS[$i]} -Te -Fplaceme -A+m0.05i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
      LEG_WIDTH_IN=$(echo $PS_DIM | gawk  '{print $1/2.54}')
      LEG_HEIGHT_IN=$(echo $PS_DIM | gawk  '{print $2/2.54}')
      LEG_WIDTH_P=$(echo $PS_DIM | gawk  '{print $1/2.54*72}')
      LEG_HEIGHT_P=$(echo $PS_DIM | gawk  '{print $2/2.54*72}')

      thisJ=""
      if [[ ${LEGEND_ONOFFCODES[$i]} == "J" ]]; then
        # Place outside the map frame
        case ${LEGEND_JUST} in
          TL) shifth=0;   shiftv=30;   thisJ="+jBL";; # top edge, left side
          TM) LEGEND_JUST="TC"; shifth=0;  shiftv=30;    thisJ="+jBC";; # top edge, middle
          TR) shifth=0;  shiftv=30;   thisJ="+jBR";; # top edge, right side
          BL) shifth=0;  shiftv=30;    thisJ="+jTL";; # bottom edge, left
          BM) LEGEND_JUST="BC"; shifth=0;  shiftv=30;    thisJ="+jTC";; # bottom edge, center
          BR) shifth=0;  shiftv=30;    thisJ="+jTR";; # bottom edge, right
          RT) shifth=50;  shiftv=0;   thisJ="+jTL";; # right edge, top
          RM) LEGEND_JUST="CR"; shifth=50;  shiftv=0; thisJ="+jML";; # right edge, center
          RB) shifth=50;  shiftv=0;   thisJ="+jBL";; # right edge, bottom
          LT) shifth=50;  shiftv=0;    thisJ="+jTR";;  # left edge, top
          LM) LEGEND_JUST="CL"; shifth=50;  shiftv=0; thisJ="+jMR";;  # left edge, center
          LB) shifth=50;  shiftv=0;   thisJ="+jBR";; # left edge, bottom
          *)
            echo "Outside justification ${LEGEND_JUST} not recognized. Using TL."
            LEGEND_JUST="TL"
            shifth=0;   shiftv=30;   thisJ="+jBL"  # top edge, left side
          ;;
        esac
      else
        # Place inside the map frame

        case ${LEGEND_JUST} in



          TR|RT) shifth=10; shiftv=10 ;;
          CR|RC) LEGEND_JUST="CR"; shifth=10;  shiftv=0  ;;
          BR|RB) shifth=10;  shiftv=10  ;;
          TM|MT) LEGEND_JUST="CT"; shifth=0;  shiftv=10  ;;
          CM|MC) shifth=0; shiftv=0 ;;
          BM|MB) LEGEND_JUST="CB"; shifth=0;  shiftv=10  ;;
          TL|LT) shifth=10;  shiftv=10  ;;
          CL|LC) LEGEND_JUST="LC"; shifth=10;  shiftv=0  ;;
          BL|LB) shifth=10;  shiftv=10  ;;
          *)
          echo "Inside justification ${LEGEND_JUST} not recognized. Using BL"
            LEGEND_JUST="BL"; shifth=10;  shiftv=10
          ;;
        esac
      fi

      if [[ ${LEGEND_BORDERON[$i]} == "yes" ]]; then
        LEGEND_BORDER_CALL=${LEGEND_BORDER}
      else
        LEGEND_BORDER_CALL=""
      fi

      gmt psimage -D${LEGEND_ONOFFCODES[$i]}${LEGEND_JUST}+o${shifth}p/${shiftv}p+w${LEG_WIDTH_IN}i${thisJ} -F+gwhite${LEGEND_BORDER_CALL} placeme.eps $RJOK ${VERBOSE} >> map.ps
    done
  else
    # Convert just the legend to a PDF
    gmt psconvert -Tf -A+m${LEGEND_MARGIN}i ${VERBOSE} ${NONCOLORBARLEGEND}
  fi
fi  # [[ $makelegendflag -eq 1 ]]

# If we are saving the colored relief, check for region code and do so here
if [[ $tsaveflag -eq 1 ]]; then
  if [[ $usingcustomregionflag -eq 1 ]]; then
    info_msg "Saving custom topo visualization to (${SAVEDTOPODIR}${CUSTOMREGIONID}.tif)"
    RELIEF_OUTFILE=${SAVEDTOPODIR}${CUSTOMREGIONID}.tif
    cp ${COLORED_RELIEF} ${RELIEF_OUTFILE}
    echo ${COMMAND} > ${SAVEDTOPODIR}${CUSTOMREGIONID}.command
  else
    info_msg "[-tsave]: Requires custom region ID (-radd; -r RegionID)"
  fi
fi

#### SECTION: DATA FRAMES BELOW OR BESIDE THE MAP (currently incompatible with onmap profiles)
#### Hopefully can be moved to modules

### Plot seismicty vs time in a projected frame to the right of the map frame

#### -seistimeline

# Variables expected:
# MAP_PS_WIDTH_NOLABELS_IN

if [[ $plotseistimeline -eq 1 ]]; then

  PS_OFFSET_IN_NOLABELS=${MAP_PS_WIDTH_NOLABELS_IN}
  secondX=$(echo "$PS_OFFSET_IN_NOLABELS + $SEISTIMELINEWIDTH" | bc -l)

  if [[ -s ${F_SEIS}eqs.txt ]]; then
    seistimeline_plotted=1
    gmt mapproject ${RJSTRING} ${F_SEIS}eqs.txt -f0x,1y,s > ${F_SEIS}proj_eqs.txt

    gmt_init_tmpdir
      cat ${F_SEIS}proj_eqs.txt | gmt_psxy zcol ${SEIS_ZCOL} xcol 5 scale ${SEISSCALE} stretch ${SEISSTRETCH} refmag ${SEISSTRETCH_REFMAG} cpt ${SEIS_CPT} trans ${SEISTRANS} stroke ${EQLINEWIDTH},${EQLINECOLOR} -Xa${PS_OFFSET_IN_NOLABELS}i -R${SEISTIMELINE_START_TIME}/${SEISTIMELINE_BREAK_TIME}/${MINPROJ_Y}/${MAXPROJ_Y} -JX${SEISTIMELINEWIDTH}i/${MAP_PS_HEIGHT_NOLABELS_IN}i -B+gwhite -K -O ${VERBOSE} >> map.ps
      cat ${F_SEIS}proj_eqs.txt | gmt_psxy zcol ${SEIS_ZCOL} xcol 5 scale ${SEISSCALE} stretch ${SEISSTRETCH} refmag ${SEISSTRETCH_REFMAG} cpt ${SEIS_CPT} trans ${SEISTRANS} stroke ${EQLINEWIDTH},${EQLINECOLOR} -Xa${secondX}i -R${SEISTIMELINE_BREAK_TIME}/${SEISTIMELINE_END_TIME}/${MINPROJ_Y}/${MAXPROJ_Y} -JX${SEISTIMELINEWIDTH}i/${MAP_PS_HEIGHT_NOLABELS_IN}i -B+gwhite ${VERBOSE} -K -O >> map.ps
    gmt_remove_tmpdir
  fi
  if [[ -s $CMTFILE ]]; then
    seistimeline_plotted=1

    PS_OFFSET_IN_NOLABELS=$(echo $MAP_PS_WIDTH_NOLABELS_IN | gawk  '{print $1}')

    # OLD_PROJ_LENGTH_UNIT=$(gmt gmtget PROJ_LENGTH_UNIT -Vn)
    # gmt gmtset PROJ_LENGTH_UNIT p
    secondX=$(echo "$PS_OFFSET_IN_NOLABELS + $SEISTIMELINEWIDTH" | bc -l)

    if [[ $cmtthrustflag -eq 1 ]]; then

      gmt mapproject ${RJSTRING} ${CMT_THRUSTPLOT} -f0x,1y,s > ${F_CMT}proj_cmt_thrust_2.txt
      # Match the CMTs to the projected coordinates and print time, Yval as X,Y coordinates
      # 1   2   3     4   5   6   7   8   9   10  11     12     13       14       15    16        17
      # lon lat depth mrr mtt mff mrt mrf mtf exp altlon altlat event_id altdepth epoch clusterid timecode

      gawk '
        (NR==FNR) {
          # Store the projected values for each line
          projx[NR]=$1
          projy[NR]=$2
        }
        (NR>FNR) {
          $1=$17
          $2=projy[FNR]
          print
        }' ${F_CMT}proj_cmt_thrust.txt ${CMT_THRUSTPLOT} > ${F_CMT}proj_thrust_scaled_y.txt

      gmt_init_tmpdir
      gmt_psmeca_wrapper ${CMT_CPT} -E"${CMT_THRUSTCOLOR}" -Tn/${CMT_LINEWIDTH},${CMT_LINECOLOR} -S${CMTLETTER}"$CMTRESCALE"i/0 ${F_CMT}proj_thrust_scaled_y.txt -L${CMT_LINEWIDTH},${CMT_LINECOLOR} -Xa${PS_OFFSET_IN_NOLABELS}i -R${SEISTIMELINE_START_TIME}/${SEISTIMELINE_BREAK_TIME}/${MINPROJ_Y}/${MAXPROJ_Y} -JX${SEISTIMELINEWIDTH}i/${MAP_PS_HEIGHT_NOLABELS_IN}i -K -O $VERBOSE >> map.ps

      gmt_psmeca_wrapper ${CMT_CPT} -E"${CMT_THRUSTCOLOR}" -Tn/${CMT_LINEWIDTH},${CMT_LINECOLOR} -S${CMTLETTER}"$CMTRESCALE"i/0 ${F_CMT}proj_thrust_scaled_y.txt -L${CMT_LINEWIDTH},${CMT_LINECOLOR} -Xa${secondX}i -R${SEISTIMELINE_BREAK_TIME}/${SEISTIMELINE_END_TIME}/${MINPROJ_Y}/${MAXPROJ_Y} -JX${SEISTIMELINEWIDTH}i/${MAP_PS_HEIGHT_NOLABELS_IN}i -K -O $VERBOSE >> map.ps
      gmt_remove_tmpdir
    fi

    if [[ $cmtnormalflag -eq 1 ]]; then
      gmt mapproject ${RJSTRING} ${CMT_NORMALPLOT} -f0x,1y,s > ${F_CMT}proj_cmt_normal.txt
      # Match the CMTs to the projected coordinates and print time, Yval as X,Y coordinates
      # 1   2   3     4   5   6   7   8   9   10  11     12     13       14       15    16        17
      # lon lat depth mrr mtt mff mrt mrf mtf exp altlon altlat event_id altdepth epoch clusterid timecode

      gawk '
        (NR==FNR) {
          # Store the projected values for each line
          projx[NR]=$1
          projy[NR]=$2
        }
        (NR>FNR) {
          $1=$17
          $2=projy[FNR]
          print
        }' ${F_CMT}proj_cmt_normal.txt ${CMT_NORMALPLOT} > ${F_CMT}proj_normal_scaled_y.txt

      gmt_init_tmpdir
      gmt_psmeca_wrapper ${CMT_CPT} -E"${CMT_NORMALCOLOR}" -Tn/${CMT_LINEWIDTH},${CMT_LINECOLOR} -S${CMTLETTER}"$CMTRESCALE"i/0 ${F_CMT}proj_normal_scaled_y.txt -L${CMT_LINEWIDTH},${CMT_LINECOLOR} -Xa${PS_OFFSET_IN_NOLABELS}i -R${SEISTIMELINE_START_TIME}/${SEISTIMELINE_BREAK_TIME}/${MINPROJ_Y}/${MAXPROJ_Y} -JX${SEISTIMELINEWIDTH}i/${MAP_PS_HEIGHT_NOLABELS_IN}i -K -O $VERBOSE >> map.ps

      gmt_psmeca_wrapper ${CMT_CPT} -E"${CMT_NORMALCOLOR}" -Tn/${CMT_LINEWIDTH},${CMT_LINECOLOR} -S${CMTLETTER}"$CMTRESCALE"i/0 ${F_CMT}proj_normal_scaled_y.txt -L${CMT_LINEWIDTH},${CMT_LINECOLOR} -Xa${secondX}i -R${SEISTIMELINE_BREAK_TIME}/${SEISTIMELINE_END_TIME}/${MINPROJ_Y}/${MAXPROJ_Y} -JX${SEISTIMELINEWIDTH}i/${MAP_PS_HEIGHT_NOLABELS_IN}i -K -O $VERBOSE >> map.ps
      gmt_remove_tmpdir

    fi

    if [[ $cmtssflag -eq 1 ]]; then

      gmt mapproject ${RJSTRING} ${CMT_STRIKESLIPPLOT} -f0x,1y,s > ${F_CMT}proj_cmt_strikeslip.txt
      # Match the CMTs to the projected coordinates and print time, Yval as X,Y coordinates
      # 1   2   3     4   5   6   7   8   9   10  11     12     13       14       15    16        17
      # lon lat depth mrr mtt mff mrt mrf mtf exp altlon altlat event_id altdepth epoch clusterid timecode

      gawk '
        (NR==FNR) {
          # Store the projected values for each line
          projx[NR]=$1
          projy[NR]=$2
        }
        (NR>FNR) {
          $1=$17
          $2=projy[FNR]
          print
        }' ${F_CMT}proj_cmt_strikeslip.txt ${CMT_STRIKESLIPPLOT} > ${F_CMT}proj_strikeslip_scaled_y.txt

      gmt_init_tmpdir
      gmt_psmeca_wrapper ${CMT_CPT} -E"${CMT_SSCOLOR}" -Tn/${CMT_LINEWIDTH},${CMT_LINECOLOR} -S${CMTLETTER}"$CMTRESCALE"i/0 ${F_CMT}proj_strikeslip_scaled_y.txt -L${CMT_LINEWIDTH},${CMT_LINECOLOR} -Xa${PS_OFFSET_IN_NOLABELS}i -R${SEISTIMELINE_START_TIME}/${SEISTIMELINE_BREAK_TIME}/${MINPROJ_Y}/${MAXPROJ_Y} -JX${SEISTIMELINEWIDTH}i/${MAP_PS_HEIGHT_NOLABELS_IN}i -K -O $VERBOSE >> map.ps

      gmt_psmeca_wrapper ${CMT_CPT} -E"${CMT_SSCOLOR}" -Tn/${CMT_LINEWIDTH},${CMT_LINECOLOR} -S${CMTLETTER}"$CMTRESCALE"i/0 ${F_CMT}proj_strikeslip_scaled_y.txt -L${CMT_LINEWIDTH},${CMT_LINECOLOR} -Xa${secondX}i -R${SEISTIMELINE_BREAK_TIME}/${SEISTIMELINE_END_TIME}/${MINPROJ_Y}/${MAXPROJ_Y} -JX${SEISTIMELINEWIDTH}i/${MAP_PS_HEIGHT_NOLABELS_IN}i -K -O $VERBOSE >> map.ps
      gmt_remove_tmpdir
    fi

  fi
  # Plot frame
  if [[ $seistimeline_plotted -eq 1 ]]; then
    gmt psbasemap -Xa${PS_OFFSET_IN_NOLABELS}i -R${SEISTIMELINE_START_TIME}/${SEISTIMELINE_BREAK_TIME}/${MINPROJ_Y}/${MAXPROJ_Y} -JX${SEISTIMELINEWIDTH}i/${MAP_PS_HEIGHT_NOLABELS_IN}i -Bxaf+l"Before ${SEISTIMELINE_BREAK_TIME}" -BlSrN  ${VERBOSE} -K -O >> map.ps
    gmt psbasemap -Xa${secondX}i -R${SEISTIMELINE_BREAK_TIME}/${SEISTIMELINE_END_TIME}/${MINPROJ_Y}/${MAXPROJ_Y} -JX${SEISTIMELINEWIDTH}i/${MAP_PS_HEIGHT_NOLABELS_IN}i -Bxaf+l"After ${SEISTIMELINE_BREAK_TIME}" -BlSrN  ${VERBOSE} -K -O >> map.ps
  fi
fi

if [[ $plotseistimeline_c -eq 1 ]]; then
  PS_OFFSET_IN_NOLABELS=${MAP_PS_WIDTH_NOLABELS_IN}
  SEISTIMELINEWIDTH=0

  if [[ ! -z ${SEISTIMELINE_C_START_EQID} ]]; then
    ststarttime=$(gawk < ${F_SEIS}eqs.txt -v id=${SEISTIMELINE_C_START_EQID} '($6==id) { print $5 }')
    SEISTIMELINE_C_BREAK_TIME[0]=$(echo $ststarttime | gawk -v shiftyear=${SEISTIMELINE_TIME_BEFORE_BUFFER} '{
      split($1, a, "-")
      printf("%04d-%s",a[1]-shiftyear,substr($1, 6, length($1)-5))
    }')
    info_msg "[-seistimeline_c]: setting to orig time to ${SEISTIMELINE_C_BREAK_TIME[0]} based on earthquake ${SEISTIMELINE_C_START_EQID}"
  else
    SEISTIMELINE_C_BREAK_TIME[0]=${SEISTIMELINE_C_START_TIME}
  fi

  if [[ -s ${F_SEIS}eqs.txt ]]; then
    # Project the earthquake data
    gmt mapproject ${RJSTRING} ${F_SEIS}eqs.txt -f0x,1y,s > ${F_SEIS}proj_eqs.txt
  fi

  # Prepare the focal mechanism data
  if [[ -s $CMTFILE ]]; then

    if [[ $cmtthrustflag -eq 1 ]]; then

      gmt mapproject ${RJSTRING} ${CMT_THRUSTPLOT} -i0,1 > ${F_CMT}proj_cmt_thrust.txt
      # Match the CMTs to the projected coordinates and print time, Yval as X,Y coordinates
      # 1   2   3     4   5   6   7   8   9   10  11     12     13       14       15    16        17
      # lon lat depth mrr mtt mff mrt mrf mtf exp altlon altlat event_id altdepth epoch clusterid timecode

      gawk '
        (NR==FNR) {
          # Store the projected values for each line
          projx[NR]=$1
          projy[NR]=$2
        }
        (NR>FNR) {
          $1=$17
          $2=projy[FNR]
          print
        }' ${F_CMT}proj_cmt_thrust.txt ${CMT_THRUSTPLOT} > ${F_CMT}proj_thrust_scaled_y.txt

    fi

    if [[ $cmtnormalflag -eq 1 ]]; then
      gmt mapproject ${RJSTRING} ${CMT_NORMALPLOT} -i0,1 > ${F_CMT}proj_cmt_normal.txt
      # Match the CMTs to the projected coordinates and print time, Yval as X,Y coordinates
      # 1   2   3     4   5   6   7   8   9   10  11     12     13       14       15    16        17
      # lon lat depth mrr mtt mff mrt mrf mtf exp altlon altlat event_id altdepth epoch clusterid timecode

      gawk '
        (NR==FNR) {
          # Store the projected values for each line
          projx[NR]=$1
          projy[NR]=$2
        }
        (NR>FNR) {
          $1=$17
          $2=projy[FNR]
          print
        }' ${F_CMT}proj_cmt_normal.txt ${CMT_NORMALPLOT} > ${F_CMT}proj_normal_scaled_y.txt
    fi

    if [[ $cmtssflag -eq 1 ]]; then
      gmt mapproject ${RJSTRING} ${CMT_STRIKESLIPPLOT} -i0,1 > ${F_CMT}proj_cmt_strikeslip.txt
      # Match the CMTs to the projected coordinates and print time, Yval as X,Y coordinates
      # 1   2   3     4   5   6   7   8   9   10  11     12     13       14       15    16        17
      # lon lat depth mrr mtt mff mrt mrf mtf exp altlon altlat event_id altdepth epoch clusterid timecode

      gawk '
        (NR==FNR) {
          # Store the projected values for each line
          projx[NR]=$1
          projy[NR]=$2
        }
        (NR>FNR) {
          $1=$17
          $2=projy[FNR]
          print
        }' ${F_CMT}proj_cmt_strikeslip.txt ${CMT_STRIKESLIPPLOT} > ${F_CMT}proj_strikeslip_scaled_y.txt
    fi
  fi

  gmt_init_tmpdir


  for sc_count in $(seq 1 $seistime_c_num); do

    backindex=$(echo "$sc_count - 1" | bc)

    secondX=$(echo "$PS_OFFSET_IN_NOLABELS + $SEISTIMELINEWIDTH" | bc -l)


    SC_START_TIME=${SEISTIMELINE_C_BREAK_TIME[$backindex]}
    SC_END_TIME=${SEISTIMELINE_C_BREAK_TIME[$sc_count]}
    PANEL_WIDTH=${SEISTIMELINE_C_WIDTH[$sc_count]}

    # Keep track of the total width of the timeline
    SEISTIMELINEWIDTH=$(echo "${SEISTIMELINEWIDTH} + ${PANEL_WIDTH}" | bc -l)


    # echo "Plotting panel ${SC_START_TIME} to ${SC_END_TIME} with width ${PANEL_WIDTH} and offset ${secondX}"

    # If we are in the last panel, the label is AFTER START_TIME, otherwise
    # it is BEFORE END_TIME
    if [[ $sc_count -eq $seistime_c_num ]]; then
      SC_LABEL="Year (CE)"
    else
      SC_LABEL="Year (CE)"
    fi

    # Plot the panel
    plotframe=0

    if [[ -s ${F_SEIS}proj_eqs.txt || -s ${F_CMT}proj_normal_scaled_y.txt || -s ${F_CMT}proj_thrust_scaled_y.txt || -s ${F_CMT}proj_strikeslip_scaled_y.txt ]]; then
      plotframe=1
      gmt psbasemap -Xa${secondX}i -R${SC_START_TIME}/${SC_END_TIME}/${MINPROJ_Y}/${MAXPROJ_Y} -JX${PANEL_WIDTH}i/${MAP_PS_HEIGHT_NOLABELS_IN}i -Blrtb+gwhite  ${VERBOSE} -K -O >> map.ps
    fi

    if [[ -s ${F_SEIS}proj_eqs.txt ]]; then

      cat ${F_SEIS}proj_eqs.txt | gmt_psxy xcol 5 scale ${SEISSCALE} stretch ${SEISSTRETCH} refmag ${SEISSTRETCH_REFMAG} cpt ${SEIS_CPT} zcol ${SEIS_ZCOL} trans ${SEISTRANS} stroke ${EQLINEWIDTH},${EQLINECOLOR} -Xa${secondX}i -R${SC_START_TIME}/${SC_END_TIME}/${MINPROJ_Y}/${MAXPROJ_Y} -JX${PANEL_WIDTH}i/${MAP_PS_HEIGHT_NOLABELS_IN}i -K -O ${VERBOSE} >> map.ps

      if [[ $zhighlightflag -eq 1 ]]; then
        for this_z in ${zhigh[@]}; do
            grep ${this_z} ${F_SEIS}proj_eqs.txt | gmt_psxy xcol 5 scale ${SEISSCALE} stretch ${SEISSTRETCH} refmag ${SEISSTRETCH_REFMAG} stroke 2p,black cpt ${SEIS_CPT} zcol ${SEIS_ZCOL} -Xa${secondX}i -R${SC_START_TIME}/${SC_END_TIME}/${MINPROJ_Y}/${MAXPROJ_Y} -JX${PANEL_WIDTH}i/${MAP_PS_HEIGHT_NOLABELS_IN}i -K -O $VERBOSE >> map.ps
        done
      fi
    fi

    if [[ -s ${F_CMT}proj_normal_scaled_y.txt ]]; then
      gmt_psmeca_wrapper ${CMT_CPT} -E"${CMT_NORMALCOLOR}" -Tn/${CMT_LINEWIDTH},${CMT_LINECOLOR} -S${CMTLETTER}"$CMTRESCALE"i/0 ${F_CMT}proj_normal_scaled_y.txt -L${CMT_LINEWIDTH},${CMT_LINECOLOR} -Xa${secondX}i -R${SC_START_TIME}/${SC_END_TIME}/${MINPROJ_Y}/${MAXPROJ_Y} -JX${PANEL_WIDTH}i/${MAP_PS_HEIGHT_NOLABELS_IN}i -K -O $VERBOSE >> map.ps
    fi

    if [[ -s ${F_CMT}proj_thrust_scaled_y.txt ]]; then
      gmt_psmeca_wrapper ${CMT_CPT} -E"${CMT_THRUSTCOLOR}" -Tn/${CMT_LINEWIDTH},${CMT_LINECOLOR} -S${CMTLETTER}"$CMTRESCALE"i/0 ${F_CMT}proj_thrust_scaled_y.txt -L${CMT_LINEWIDTH},${CMT_LINECOLOR} -Xa${secondX}i -R${SC_START_TIME}/${SC_END_TIME}/${MINPROJ_Y}/${MAXPROJ_Y} -JX${PANEL_WIDTH}i/${MAP_PS_HEIGHT_NOLABELS_IN}i -K -O $VERBOSE >> map.ps
    fi

    if [[ -s ${F_CMT}proj_strikeslip_scaled_y.txt ]]; then
      gmt_psmeca_wrapper ${CMT_CPT} -E"${CMT_SSCOLOR}" -Tn/${CMT_LINEWIDTH},${CMT_LINECOLOR} -S${CMTLETTER}"$CMTRESCALE"i/0 ${F_CMT}proj_strikeslip_scaled_y.txt -L${CMT_LINEWIDTH},${CMT_LINECOLOR} -Xa${secondX}i -R${SC_START_TIME}/${SC_END_TIME}/${MINPROJ_Y}/${MAXPROJ_Y} -JX${PANEL_WIDTH}i/${MAP_PS_HEIGHT_NOLABELS_IN}i -K -O $VERBOSE >> map.ps
    fi

    if [[ $plotframe -eq 1 ]]; then

      if [[ $sc_count -ne $seistime_c_num ]]; then
        framecmd="-Br"
      else
        framecmd="-Br"
      fi

      gmt psbasemap -Xa${secondX}i -R${SC_START_TIME}/${SC_END_TIME}/${MINPROJ_Y}/${MAXPROJ_Y} -JX${PANEL_WIDTH}i/${MAP_PS_HEIGHT_NOLABELS_IN}i -Bxaf+l"${SC_LABEL}" --FONT_LABEL=12p,Helvetica,black -BSN  ${VERBOSE} -K -O >> map.ps
      gmt psbasemap ${framecmd} -Bxa -Bya -Xa${PANEL_WIDTH}i ${OBFRAMECMD} ${RJSTRING} -O -K $VERBOSE --FORMAT_FLOAT_OUT=${MAP_FORMAT_FLOAT_OUT} --MAP_TICK_LENGTH_PRIMARY=6p >> map.ps
    fi

  done
  gmt_remove_tmpdir

fi

# ##### -seisproj
# ### Plot seismicty vs depth in a projected (X) frame below the map frame
#
if [[ $plotseisprojflag_x -eq 1 && -s ${F_SEIS}eqs.txt ]]; then

  depth_range=($(gawk < ${F_SEIS}eqs.txt '
    BEGIN {
      getline
      maxdepth=$3
      mindepth=$3
    }
    {
      maxdepth=($3>maxdepth)?$3:maxdepth
      mindepth=($3<mindepth)?$3:mindepth
    }
    END {
      range=maxdepth-mindepth
      print -(maxdepth+range/20), -(mindepth-range/10)
    }'))

    gmt mapproject ${RJSTRING} ${F_SEIS}eqs.txt -f0x,1y,s > ${F_SEIS}proj_eqs.txt

    gmt psbasemap -R${MINPROJ_X}/${MAXPROJ_X}/${depth_range[0]}/${depth_range[1]} -JX${PSSIZE}i/${SEISPROJHEIGHT_X}i -Btlbr $VERBOSE > ${TMP}seisdepth_fake.ps
    PS_DIM=$(gmt psconvert seisdepth_fake.ps -Te -A+m0i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
    PS_HEIGHT_IN_NOLABELS=$(echo $PS_DIM | gawk  '{print $2/2.54 + 0.15}')

    # the -Cwhite option here is so that we can pass the removed EQs in the same file format as the non-scaled events
    cat ${F_SEIS}proj_eqs.txt | gmt_psxy xcol 1 ycol 3 ymul -1 scale ${SEISSCALE} stretch ${SEISSTRETCH} refmag ${SEISSTRETCH_REFMAG} cpt ${SEIS_CPT} zcol ${SEIS_ZCOL} trans ${SEISTRANS} stroke ${EQLINEWIDTH},${EQLINECOLOR} -Ya-${PS_HEIGHT_IN_NOLABELS}i -R${MINPROJ_X}/${MAXPROJ_X}/${depth_range[0]}/${depth_range[1]} -JX${PSSIZE}i/${SEISPROJHEIGHT_X}i -Bxaf -Byaf+l"Depth" -BrbWt -O -K $VERBOSE --MAP_FRAME_PEN=thick,black --MAP_FRAME_TYPE=plain >> map.ps
fi

#### Plot seismicty vs depth in a projected (Y) frame to the right of the map frame

if [[ $plotseisprojflag_y -eq 1 && -s ${F_SEIS}eqs_scaled.txt ]]; then

  depth_range=($(gawk < ${F_SEIS}eqs_scaled.txt '
    BEGIN {
      getline
      maxdepth=$3
      mindepth=$3
    }
    {
      maxdepth=($3>maxdepth)?$3:maxdepth
      mindepth=($3<mindepth)?$3:mindepth
    }
    END {
      range=maxdepth-mindepth
      print -(maxdepth+range/20), -(mindepth-range/10)
    }'))

    info_msg "[-seisproj Y]: ${depth_range[0]}/${depth_range[1]}/${MINPROJ_Y}/${MAXPROJ_Y}"

    gmt mapproject ${RJSTRING} ${F_SEIS}eqs.txt -f0x,1y,s > ${F_SEIS}proj_eqs.txt

    PS_OFFSET_IN_NOLABELS=$(echo $MAP_PS_WIDTH_NOLABELS_IN | gawk  '{print $1+ 0.15}')

    # gmt psxy ${F_SEIS}proj_eqs_scaled_y.txt -C$SEIS_CPT ${SEIS_INPUTORDER1} ${EQWCOM} -S${SEISSYMBOL} -t${SEISTRANS} -O -K $VERBOSE --MAP_FRAME_PEN=thick,black --MAP_FRAME_TYPE=plain >> map.ps
    cat ${F_SEIS}proj_eqs.txt | gmt_psxy xcol 3 ycol 2 xmul -1 scale ${SEISSCALE} stretch ${SEISSTRETCH} refmag ${SEISSTRETCH_REFMAG} cpt ${SEIS_CPT} zcol ${SEIS_ZCOL} trans ${SEISTRANS} stroke ${EQLINEWIDTH},${EQLINECOLOR} -Xa${PS_OFFSET_IN_NOLABELS}i -R${depth_range[0]}/${depth_range[1]}/${MINPROJ_Y}/${MAXPROJ_Y} -JX-${SEISPROJWIDTH_Y}i/${MAP_PS_HEIGHT_NOLABELS_IN}i -Bxaf+l"Depth" -Byaf -BlNrb  -O -K $VERBOSE --MAP_FRAME_PEN=thick,black --MAP_FRAME_TYPE=plain >> map.ps
fi

# RUN MODULE POST-PROCESSING
# Maybe this should be outside the if..fi $noplotflag -eq 1?


for this_mod in ${TECTOPLOT_ACTIVE_MODULES[@]}; do
  if type "tectoplot_post_${this_mod}" >/dev/null 2>&1; then
    info_msg "Running module post-processing for ${this_mod}"
    cmd="tectoplot_post_${this_mod}"
    "$cmd" ${this_mod}
  fi
done

# Export TECTOPLOT call and GMT command history from PS file to .history file

# Close the PS if we need to
# if [[ $legendonlyflag -ne 1 ]]; then
gmt psxy -T -R -J -O $KEEPOPEN $VERBOSE >> map.ps


# # rotate the map?
#
#   if [[ $rotatemapflag -eq 1 ]]; then
#     mv map.ps prerotate.ps
#     PS_DIM=$(gmt psconvert prerotate.ps -TG -A+m0i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
#     PS_WIDTH="$(echo $PS_DIM | gawk '{print $1/2.54}')"
#     PS_HEIGHT="$(echo $PS_DIM | gawk '{print $2/2.54}')"
#     echo w is ${PS_WIDTH}
#
# # -D${LEGEND_ONOFFCODES[$i]}${LEGEND_JUST}+o${shifth}p/${shiftv}p+w${LEG_WIDTH_IN}i${thisJ}
#     gmt psimage prerotate.png -Dx0/0+w${PS_WIDTH}i ${RJSTRING} -p${ROTATE_ANGLE} > map.ps
#   fi

  echo ${COMMAND} > ${MAPOUT}.history

  # Save the record to tectoplot.history along with the UTC time it was run
  thisdate=$(date -u)
  echo -n "$thisdate: " >> ${OPTDIR}tectoplot.history
  echo ${COMMAND} >> ${OPTDIR}tectoplot.history

  grep "%@GMT:" map.ps | sed -e 's/%@GMT: //' >> ${MAPOUT}.history

  ##### MAKE PDF OF MAP
  if [[ $keepopenflag -eq 0 ]]; then
     if [[ $epsoverlayflag -eq 1 ]]; then
       gmt psconvert -C-dALLOWPSTRANSPARENCY -Tf -A+m${MAPMARGIN} -Mf${EPSOVERLAY} $VERBOSE map.ps
     else
       gmt psconvert -C-dALLOWPSTRANSPARENCY -Tf -A+m${MAPMARGIN} $VERBOSE map.ps
    fi

    if [[ $outputdirflag -eq 1 ]]; then
      mv map.pdf ${MAPOUT}.pdf
      move_exit ${MAPOUT}.pdf
      move_exit ${MAPOUT}.history
      info_msg "Map is at ${OUTPUTDIRECTORY}${MAPOUT}.pdf"
      [[ $openflag -eq 1 ]] && open_pdf "$MAPOUT.pdf"
    else
      mv map.pdf "${THISDIR}/${MAPOUT}.pdf"
      mv ${MAPOUT}.history $THISDIR"/"$MAPOUT".history"
      info_msg "Map is at $THISDIR/$MAPOUT.pdf"
      [[ $openflag -eq 1 ]] && open_pdf "$THISDIR/$MAPOUT.pdf"
    fi
  fi

  ##### MAKE GEOTIFF OF MAP
  if [[ $tifflag -eq 1 ]]; then
    # echo gmt psconvert map.ps -Tt -A -W+g -E${GEOTIFFRES} ${VERBOSE}
    gmt psconvert map.ps -C-dALLOWPSTRANSPARENCY -Tt -A -W+g -E${GEOTIFFRES} ${VERBOSE}


    # map.tiff is created from map.tif and is smaller, so keep it

    # Reset the coordinates of map.tiff for some reason or another. This
    # produces a TIFF with variable X and Y resolution
    gdal_edit.py -a_ullr ${MINLON} ${MAXLAT} ${MAXLON} ${MINLAT} map.tiff
    # Rename
    mv map.tiff map.tif
    [[ $openflag -eq 1 ]] && open_pdf "map.tif"
  fi

if [[ $previewflag -eq 1 ]]; then
  gmt psconvert -F${THISDIR}/${MAPOUT} -C-dALLOWPSTRANSPARENCY -Tj -A+m${MAPMARGIN} -E${PREVIEWRES} $VERBOSE map.ps
  # gmt psconvert map.ps -Fpreview -Tt -A+m${MAPMARGIN} -W+g -E30 ${VERBOSE}
fi

# fi
##### Copy QGIS project into temporary directory

cp ${TECTOPLOTDIR}"qgis/tempfiles_to_delete/tectoplot.qgz" ./

##### Make script to plot oblique view of topography, execute if option is set
#     If we are
if [[ $plottedtopoflag -eq 1 ]]; then
  info_msg "Oblique map (${OBLIQUEAZ}/${OBLIQUEINC})"
  PSSIZENUM=$(echo $PSSIZE | gawk  '{print $1+0}')

  # zrange is the elevation change across the DEM
  zrange=($(grid_zrange ${TOPOGRAPHY_DATA} -R${TOPOGRAPHY_DATA}))

  if [[ $obplotboxflag -eq 1 ]]; then
    OBBOXCMD="-N${OBBOXLEVEL}+gwhite -Wf0.1p,black"
    # If the box goes upward for some reason???
    if [[ $(echo "${zrange[1]} < $OBBOXLEVEL" | bc -l) -eq 1 ]]; then
      zrange[1]=$OBBOXLEVEL;
    elif [[ $(echo "${zrange[0]} > $OBBOXLEVEL" | bc -l) -eq 1 ]]; then
      # The box base falls below the zrange minimum (typical example)
      zrange[0]=$OBBOXLEVEL
    fi
  else
    OBBOXCMD=""
  fi

  # make_oblique.sh takes up to three arguments: vertical exaggeration, azimuth, inclination

cat<<-EOF > ./make_oblique.sh
#!/usr/bin/env bash
if [[ \$# -ge 1 ]]; then
  OBLIQUE_VEXAG=\${1}
else
  OBLIQUE_VEXAG=${OBLIQUE_VEXAG}
fi

if [[ \$# -ge 2 ]]; then
  OBLIQUEAZ=\${2}
else
  OBLIQUEAZ=${OBLIQUEAZ}
fi

if [[ \$# -ge 3 ]]; then
  OBLIQUEINC=\${3}
else
  OBLIQUEINC=${OBLIQUEINC}
fi

if [[ \$# -ge 4 ]]; then
  OBLIQUERES=\${4}
else
  OBLIQUERES=${OBLIQUERES}
fi
GEOTIFFRES=${GEOTIFFRES}

OBRSTRING=\$(gawk -v minlon=$MINLON -v maxlon=$MAXLON -v minlat=$MINLAT -v maxlat=$MAXLAT '
BEGIN {
  londiff=maxlon-minlon
  latdiff=maxlat-minlat
  maxdiff=((londiff>latdiff)?londiff:latdiff)
  maxlatnew=(maxlat+maxdiff*2>90)?90:maxlat+maxdiff*2
  minlatnew=(minlat-maxdiff*2<-90)?-90:minlat-maxdiff*2
  maxlonnew=maxlon+maxdiff*2
  minlonnew=maxlon-maxdiff*2
  print "-R" minlonnew "/" maxlonnew "/" minlatnew "/" maxlatnew
}')

OBJSTRING=\$(echo ${RJSTRING} | gawk '
{
  for(i=1;i<=NF;i++) {
    if (substr(\$(i),1,2) == "-J") {
      print \$(i)
      break
    }
  }
}
')

DELTAZ_IN=\$(echo "\${OBLIQUE_VEXAG} * ${PSSIZENUM} * (${zrange[1]} - ${zrange[0]})/ ( (${DEM_MAXLON} - ${DEM_MINLON}) * 111000 )"  | bc -l)

if [[ -s map.tif ]]; then
  gmt grdview -Xc -Yc ${TOPOGRAPHY_DATA} -Gmap.tif \${OBRSTRING} \${OBJSTRING} -JZ\${DELTAZ_IN}i ${OBBOXCMD} -Qi\${GEOTIFFRES} -p\${OBLIQUEAZ}/\${OBLIQUEINC} --PS_MEDIA=100ix100i --GMT_HISTORY=false --MAP_FRAME_TYPE=$OBBAXISTYPE ${VERBOSE} > oblique.ps
  [[ "${OBBCOMMAND}" != "" ]] && gmt psbasemap -Xc -Yc ${RJSTRING} ${OBBCOMMAND} -JZ\${DELTAZ_IN}i -p\${OBLIQUEAZ}/\${OBLIQUEINC} --PS_MEDIA=100ix100i --MAP_FRAME_TYPE=$OBBAXISTYPE  ${VERBOSE} > oblique_grid.ps
  gmt psconvert oblique_tiff.ps -Tf -A+m0.5i --GMT_HISTORY=false ${VERBOSE}
else
  gmt grdview -Xc -Yc ${TOPOGRAPHY_DATA} -G${COLORED_RELIEF} \${OBRSTRING} \${OBJSTRING} -JZ\${DELTAZ_IN}i ${OBBOXCMD} -Qi\${OBLIQUERES} -p\${OBLIQUEAZ}/\${OBLIQUEINC} --PS_MEDIA=100ix100i --GMT_HISTORY=false --MAP_FRAME_TYPE=$OBBAXISTYPE ${VERBOSE} > oblique.ps
  [[ "${OBBCOMMAND}" != "" ]] && gmt psbasemap -Xc -Yc ${RJSTRING} ${OBBCOMMAND} -JZ\${DELTAZ_IN}i -p\${OBLIQUEAZ}/\${OBLIQUEINC} --PS_MEDIA=100ix100i --MAP_FRAME_TYPE=$OBBAXISTYPE ${VERBOSE} > oblique_grid.ps
  gmt psconvert oblique.ps -Tf -A+m0.5i --GMT_HISTORY=false ${VERBOSE}
fi

EOF
  # Drape map.tif if it exists, otherwise drape colored relief
  chmod a+x ./make_oblique.sh

  if [[ $obliqueflag -eq 1 ]]; then
    ./make_oblique.sh
  fi
fi

##### MAKE KML OF MAP
if [[ $kmlflag -eq 1 ]]; then

  echo "Creating tiled kml"

  gmt psconvert map.ps -Tt -A -E${KMLRES} ${VERBOSE}
  # A different approach uses
  # gdal2tiles.py map.tif -p geodetic -k --s_srs EPSG:4326
  # -gcp 0 0 minlon maxlat -gcp xnum 0 maxlon maxlat -gcp xnum ynum maxlon minlat
  #
  ncols=$(gmt grdinfo map.tif -C ${VERBOSE} | gawk  '{print $10}')
  nrows=$(gmt grdinfo map.tif -C ${VERBOSE} | gawk  '{print $11}')

  gdal_translate -of VRT -a_srs EPSG:4326 -gcp 0 0 ${MINLON} ${MAXLAT} -gcp $ncols 0 ${MAXLON} ${MAXLAT} -gcp $ncols $nrows ${MAXLON} ${MINLAT} map.tif map.vrt
  gdal2tiles.py -p geodetic -k map.vrt

  # Set the KML files to be clamped to seafloor
  info_msg "[-kml]: Resetting tiles to be clamped to ground+seafloor"
  find . -name "*.kml" > kmlfiles.txt
  while read p; do
    # echo "Processing KML file ${p}"
    if grep GroundOverlay $p >/dev/null; then
      # echo "Found GroundOverlay element... updating KML tags"
      gawk < $p '{
        if ($0 ~ "<kml xmlns=\"http://www.opengis.net/kml/2.2\">") {
          print "<kml xmlns=\"http://www.opengis.net/kml/2.2\" xmlns:gx=\"http://www.google.com/kml/ext/2.2\">"
        } else if ($0 ~ "<GroundOverlay>") {
          print("<GroundOverlay>")
          printf("\t<gx:altitudeMode>clampToSeaFloor</gx:altitudeMode>\n")
        } else {
          print
        }
      }' > $p.new
      mv $p.new $p
    fi
  done < kmlfiles.txt
fi




## Source the 3d modeling script

source "${MAKE3D_SCRIPT}"

##

mv ${FILETMP}tectoplot.last ${TMP}

if [[ $outputdirflag -eq 1 ]]; then
  move_exit ${TMP}
fi

if [[ $openflag -eq 1 ]]; then
  PDF_FILES=($(find . -type f -name "*.pdf"))
  for open_file in ${PDF_FILES[@]}; do
    open_pdf $open_file
  done
fi

if [[ $scripttimeflag -eq 1 ]]; then
  SCRIPT_END_TIME="$(date -u +%s)"
  elapsed="$(($SCRIPT_END_TIME - $SCRIPT_START_TIME))"
  echo "Script run time was $elapsed seconds"
fi

# Run all tectoplot_test_* functions

TECTOPLOT_TEST_FUNCTIONS=0
if [[ $TECTOPLOT_TEST_FUNCTIONS -eq 1 ]]; then
  test_functions=($(declare -f | grep tectoplot_test_ | gawk '{print $1}'))

  for this_function in ${test_functions[@]}; do
    echo executing ${this_function}
    ${this_function}
  done
fi


exit 0

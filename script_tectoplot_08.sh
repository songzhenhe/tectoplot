#!/bin/bash
#
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

VERSION="0.4.2"
TECTOPLOT_VERSION="TECTOPLOT ${VERSION}, July 2021"


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
# October  20, 2020: Added -clipdem to save a ${F_TOPO}dem.nc file in the temporary data folder, mainly for in-place profile control
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
# Add option to smooth/filter the DEM before hillshading?

# Add option to specify only a profile and plot default data onto that profile and a map within that AOI
# Add routines to plot existing cached data tile extents (e.g. GMRT, other topo) and clear cached data
# Need to formalize argument checking approach and apply it to all options
# Need to change program structure so that multiple grids can be overlaid onto shaded relief.
# Add option to plot a USGS event from a URL?
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

################################################################################
# Define paths and defaults

THISDIR=$(pwd)

GMTREQ="6.1"
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

# gmt gmtset GMT_AUTO_DOWNLOAD on

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
#
# if [[ "${OPENPROGRAM}" == "open -a Preview" ]]; then
#   openprogramflag=1
# else
#
#   if [[ ! -x ${OPENPROGRAM} ]]; then
#     echo "PDF viewer ${OPENPROGRAM} cannot be called. Setting default based on OS..."
#
#
#     if [[ ! -x ${OPENPROGRAM} ]]; then
#       "Default PDF viewer ${OPENPROGRAM} cannot be called."
#       openprogramflag=0
#     else
#       openprogramflag=1
#     fi
#
#   else
#     openprogramflag=1
#   fi
# fi

GMTVERSION=$(gmt --version)
# if [[ $(echo $GMTVERSION | gawk '{ if ($1 >= "6.2.0") { print 0 } else {print 1 }}') -eq 1 ]]; then
#   echo "GMT greater than 6.2"
#   GMTVERSION="6.2"
#
# fi

GDAL_VERSION_GT_3_2=$(gdalinfo --version | gawk -F, '{split($1, a, " "); if (a[2] > "3.2.0") { print 1 } else { print 0 }}')

if [[ ! -s ${OPTDIR}"tectoplot.dataroot" ]]; then
  echo "Error: data directory not defined; using /dev/null as placeholder. Run tectoplot -setdatadir"
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

# if [[ ! -d ${DATAROOT} ]]; then
#   echo "Warning: Data directory ${DATAROOT} does not exist. Set using tectoplot -setdatadir"
# fi

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

# echo INFO_MSG="\$(abs_path ./${INFO_MSG_NAME})"

INFO_MSG="./${INFO_MSG_NAME}"
rm -f ${INFO_MSG}
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

# DEFINE FLAGS
  calccmtflag=0
  customgridcptflag=0
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

# Load default variables from all modules

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
  info_msg "Rerunning last tectoplot command executed in this directory"
  cat tectoplot.last
  . tectoplot.last
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
-query:        query and print information from files produced by prior call
-query [filename] [options...] [field1] ... [fieldn]

Options:
  noheader: don't print field ID/units
  nounits:  don't print units
  csv:      print in CSV format
  data:     print data from file

field1 ... fieldn are field IDs of fields to be selected

Example:
  tectoplot -r GR -z
  tectoplot -query eqs.txt csv data latitude magnitude
--------------------------------------------------------------------------------
EOF
else
  USAGEFLAG=1
fi


  shift
  # echo "Entered query processing block"
  if [[ ! $tempdirqueryflag -eq 1 ]]; then
    if [[ ! -d ${TMP} ]]; then
      echo "Temporary directory $TMP does not exist"
      exit 1
    else
      cd ${TMP}
    fi
  fi
  query_headerflag=1

  # First argument to -query needs to be a filename.

  if [[ ! -e $1 ]]; then
    # IF the file doesn't exist in the temporary directory, search for it in a
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
      [0-9]*)
        # echo "Detected number argument $key"
        keylist+=("$key")
        if [[ "${headerline[$key]}" == "" ]]; then
          fieldlist+=("none")
        else
          fieldlist+=("${headerline[$key]}")
        fi
        ;;
      noheader)
        query_headerflag=0
        ;;
      nounits)
        query_nounitsflag=1
        ;;
      csv)
        query_csvflag=1
        ;;
      data)
        query_dataflag=1
        ;;
      *) # should get index of field coinciding with argument
        # echo "Other argument $key"
        ismatched=0
        for ((i=1; i < ${#headerline[@]}; ++i)); do
          # This needs to exactly match the field name before [...]
          lk=${#key}
          # echo $key $lk ${headerline[$i]:0:$lk} ${headerline[$i]:$lk:1}
          if [[ "${headerline[$i]:0:$lk}" == "${key}" && "${headerline[$i]:$lk:1}" == "[" ]]; then
            # echo "Found likely index for $key at index $i"
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

  if [[ ${#fieldlist[@]} -eq 0 ]]; then
    # echo "No fields: header is"
    fieldlist=(${headerline[@]:1})
    # echo ${fieldlist[@]}
  fi

  if [[ $query_headerflag -eq 1 ]]; then
    if [[ $query_nounitsflag -eq 1 ]]; then
      if [[ $query_csvflag -eq 1 ]]; then
        echo "${fieldlist[@]}" | sed 's/\[[^][]*\]//g' | tr ' ' ','
      else
        echo "${fieldlist[@]}" | sed 's/\[[^][]*\]//g'
      fi
    else
      if [[ $query_csvflag -eq 1 ]]; then
        echo "${fieldlist[@]}" | tr ' ' ','
      else
        echo "${fieldlist[@]}"
      fi
    fi
  fi

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

# This file needs to be reset as they are used before the tempdir is created
rm -f ${LONGSOURCES}
rm -f ${SHORTSOURCES}

DONTRESETCOMSFLAG=0

##### Look for high priority arguments that need to be executed first
saved_args=( "$@" );
while [[ $# -gt 0 ]]
do
  key="${1}"
  case ${key} in

 -ips) # args: file
   overplotflag=1
   PLOTFILE=$(abs_path $2)
   shift
   info_msg "[-ips]: Plotting over previous PS file: $PLOTFILE"
   ;;

  -megadebug)
    set -x
    ;;

  -n|--narrate)
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

  -addpath)   # Add tectoplot source directory to ~/.profile and exit
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

  -checkdep)
    if [[ ! $USAGEFLAG -eq 1 ]]; then
      source ${BASHSCRIPTDIR}"test_dependencies.sh" verbose
      exit
    fi
    ;;

  -compile)
    if [[ ! $USAGEFLAG -eq 1 ]]; then
      echo "Compiling texture shading code in ${TEXTUREDIR}"
      ${TEXTURE_COMPILE_SCRIPT} ${TEXTUREDIR} ${CCOMPILER}

      echo "Compiling Reasenberg declustering tool"
      if [[ -x $(which ${F90COMPILER}) ]]; then
        # This seems to work with OSX gfortran but not with GCC on miniconda/Linux...
        ${F90COMPILER} ${REASENBERG_SCRIPT} -w -std=legacy -o ${REASENBERG_EXEC}
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

  -countryid)
    if [[ ! $USAGEFLAG -eq 1 ]]; then
      if arg_is_flag $2; then
        gawk -F, < $COUNTRY_CODES '{ print $1, $4 }'
      else
        gawk -F, < $COUNTRY_CODES '{ print $1, $4 }' | grep "${2}"
      fi
      exit
    fi
    ;;

  -data)
    if [[ ! $USAGEFLAG -eq 1 ]]; then
      datamessage
      exit 1
    fi
    ;;

  -defaults)
    if [[ ! $USAGEFLAG -eq 1 ]]; then
      defaultsmessage
      exit 1
    fi
    ;;

  -formats)
    if [[ ! $USAGEFLAG -eq 1 ]]; then
      formats
      exit 1
    fi
    ;;

  -getdata)
    if [[ ! $USAGEFLAG -eq 1 ]]; then
      narrateflag=1
      # info_msg "Checking and updating downloaded datasets: GEBCO1 GEBCO20 EMAG2 SRTM30 WGM Geonames GCDM Slab2.0 OC_AGE LITHO1.0"

      # To download a ZIP file:
      # Checks whether the destination file exists within the destination directory and is the right size.
      # If so, skip. If not, check the ZIP file exists and is the right size. If so, unzip check. If not, try to
      # redownload the ZIP file.
      # CHECKFILE path needs to include DESTDIR
      # check_and_download_dataset "IDCODE" $SOURCEURL "yes" $DESTDIR $CHECKFILE $DESTDIR"data.zip" $CHECKFILE_BYTES $ZIP_BYTES

      # # First do the EarthByte datasets
      # check_and_download_dataset "EB-ISO" $EARTHBYTE_ISOCHRONS_SOURCEURL "yes" $TECTFABRICSDIR $EARTHBYTE_ISOCHRONS_SHP $TECTFABRICSDIR"iso.zip" $EARTHBYTE_ISOCHRONS_SHP_BYTES $EARTHBYTE_ISOCHRONS_ZIP_BYTES
      # # Convert EB_ISO shapefile to GMT format for psxy usage
      # [[ ! -s $EARTHBYTE_ISOCHRONS_GMT ]] && ogr2ogr -f "OGR_GMT" $EARTHBYTE_ISOCHRONS_GMT $EARTHBYTE_ISOCHRONS_SHP
      #
      # check_and_download_dataset "EB-HOT" $EARTHBYTE_HOTSPOTS_SOURCEURL "yes" $TECTFABRICSDIR $EARTHBYTE_HOTSPOTS_SHP $TECTFABRICSDIR"hot.zip" $EARTHBYTE_HOTSPOTS_SHP_BYTES $EARTHBYTE_HOTSPOTS_ZIP_BYTES
      # # Convert EB_ISO shapefile to GMT format for psxy usage
      # [[ ! -s $EARTHBYTE_HOTSPOTS_GMT ]] && ogr2ogr -f "OGR_GMT" $EARTHBYTE_HOTSPOTS_GMT $EARTHBYTE_HOTSPOTS_SHP
      #
      # # Download GSFML seafloor data
      # check_and_download_dataset "GSFML" $GSFML_SOURCEURL "yes" $GSFMLDIR $GSFML_CHECK $GSFMLDIR"gsfml.tbz" $GSFML_CHECK_BYTES $GSFML_ZIP_BYTES



      if [[ "${2}" == "dropbox" ]]; then
        shift
        if [[ -d $GCMTDIR || -d $GFZDIR || -d $ISCDIR || -d $ISC_EQS_DIR || -d $ANSSDIR ]]; then
          echo "[-getdata]: dropbox option will not run if any of the following directories exist. Delete and re-run."
          echo $GCMTDIR
          echo $GFZDIR
          echo $ISCDIR
          echo $ISC_EQS_DIR
          echo $ANSSDIR
        else
          if [[ -s EarthquakeData.zip ]]; then
            echo "Earthquake data archive already exists in current folder. Not downloading or extracting."
            echo "Delete $(pwd)/EarthquakeData.zip and call tectoplot -getdata dropbox again to re-download"
          else
            echo "Getting earthquake data from Dropbox link"
            if curl https://dl.dropboxusercontent.com/s/0jt228tmcgy2cfz/EarthquakeData_30July2021.zip -o EarthquakeData.zip; then
              echo "Earthquake archive downloaded. Testing..."
              if unzip -t EarthquakeData.zip >/dev/null; then
                echo "Earthquake data archive is OK"
                if unzip EarthquakeData.zip -d ${DATAROOT}/; then
                  echo "Unzip operation succeeded - removing earthquake data archive."
                  rm -f EarthquakeData.zip
                else
                  echo "Unzip operation failed. Remove EarthquakeData.zip and retry?"
                fi
              fi
            else
              echo "curl download failed. Removing archive"
              rm -f EarthquakeData.zip
            fi
          fi
        fi
        exit 0
      else
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

        check_and_download_dataset "Geonames-Cities" $CITIES_SOURCEURL "yes" $CITIESDIR $CITIES500 $CITIESDIR"data.zip" "none" "none"

        [[ -s $CITIESDIR"cities500.txt" ]] && info_msg "Processing cities data to correct format" && gawk  < $CITIESDIR"cities500.txt" -F'\t' '{print $6 "," $5 "," $2 "," $15}' > $CITIES

        check_and_download_dataset "GlobalCurieDepthMap" $GCDM_SOURCEURL "no" $GCDMDIR $GCDMDATA_ORIG "none" $GCDM_BYTES "none"
        [[ ! -e $GCDMDATA ]] && info_msg "Processing GCDM data to grid format" && gmt xyz2grd -R-180/180/-80/80 $GCDMDATA_ORIG -I10m -G$GCDMDATA

        check_and_download_dataset "SLAB2" $SLAB2_SOURCEURL "yes" $SLAB2_DATADIR $SLAB2_CHECKFILE $SLAB2_DATADIR"data.zip" $SLAB2_CHECK_BYTES $SLAB2_ZIP_BYTES
        [[ ! -d $SLAB2DIR ]] && [[ -e $SLAB2_CHECKFILE ]] && tar -xvf $SLAB2_DATADIR"Slab2Distribute_Mar2018.tar.gz" --directory $SLAB2_DATADIR

        # # Change the format of the Slab2 grids so that longitudes go from -180:180
        # # If we don't do this now, some regions will have profiles/maps fail.
        # for slab2file in $SLAB2DIR/*.grd; do
        #   echo gmt grdedit -L $slab2file
        # done

        # check_and_download_dataset "GMT_DAY" $GMT_EARTHDAY_SOURCEURL "no" $GMT_EARTHDIR $GMT_EARTHDAY "none" $GMT_EARTHDAY_BYTES "none"
        # check_and_download_dataset "GMT_NIGHT" $GMT_EARTHNIGHT_SOURCEURL "no" $GMT_EARTHDIR $GMT_EARTHNIGHT "none" $GMT_EARTHNIGHT_BYTES "none"

        check_and_download_dataset "OC_AGE" $OC_AGE_URL "no" $OC_AGE_DIR $OC_AGE "none" $OC_AGE_BYTES "none"
        check_and_download_dataset "OC_AGE_CPT" $OC_AGE_CPT_URL "no" $OC_AGE_DIR $OC_AGE_CPT "none" $OC_AGE_CPT_BYTES "none"

        check_and_download_dataset "LITHO1.0" $LITHO1_SOURCEURL "yes" $LITHO1DIR $LITHO1FILE $LITHO1DIR"data.tar.gz" $LITHO1_BYTES $LITHO1_ZIP_BYTES

        check_and_download_dataset "SW2019_GRAV" $SANDWELL2019_SOURCEURL "no" $SANDWELLDIR $SANDWELLFREEAIR "none" $SANDWELL2019_bytes "none"
        check_and_download_dataset "SW2019_CURV" $SANDWELL2019_CURV_SOURCEURL "no" $SANDWELLDIR $SANDWELLFREEAIR_CURV "none" $SANDWELL2019_CURV_bytes "none"

        # Save the biggest downloads for last.
        check_and_download_dataset "GEBCO20" $GEBCO20_SOURCEURL "yes" $GEBCO20DIR $GEBCO20FILE $GEBCO20DIR"data.zip" $GEBCO20_BYTES $GEBCO20_ZIP_BYTES

        check_and_download_dataset "SRTM30" $SRTM30_SOURCEURL "yes" $SRTM30DIR $SRTM30FILE "none" $SRTM30_BYTES "none"
        exit 0
      fi
    fi
    ;;
-h|--help|-help)
    if [[ ! ${USAGEFLAG} -eq 1 ]]; then
      print_usage
    	exit 1
    fi
    ;;
  -setup)
    if [[ ! $USAGEFLAG -eq 1 ]]; then
      print_setup
      exit 1
    fi
    ;;
  -variables)
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

if [[ ! ${USAGEFLAG} -eq 1 ]]; then
  # Create the temporary directory but don't change into it yet to avoid
  # breaking arguments to files in current working directory

  ################################################################################
  #####          Create and change into the temporary directory              #####
  ################################################################################

  # Delete and remake the temporary directory where interim files will be stored
  # Only delete the temporary directory if it is a subdirectory of the current
  # directory to prevent accidents

  # First copy the .ps base file, which can be in an already existing temporary
  # folder that is doomed to be overwritten.

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

  # Create directories registered by modules
  mkdir -p "${TMP}${F_VOLC}"


fi

##### Parse main command line arguments
USAGEFLAG=0  # Reset to 0... if -usage is called it will work again.

while [[ $# -gt 0 ]]
do
  key="${1}"
  case ${key} in

# Options from high priority suite above need to be skipped intelligently
# The options from the above parsing just need to be skipped...?
  -n|--narrate)
  ;;
  -addpath)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-addpath:      add tectoplot script directory to path environment (~/.profile)
-addpath
Example:
  tectoplot -addpath
--------------------------------------------------------------------------------
EOF
  shift && continue
fi
  ;;

  -whichutm)
  if arg_is_float $2; then
    AVELONp180o6=$(echo "(($2) + 180)/6" | bc -l)
    UTMZONE=$(echo $AVELONp180o6 1 | gawk  '{val=int($1)+($1>int($1)); print (val>0)?val:1}')
    echo "UTM Zone for longitude ${2}: ${UTMZONE}"
  fi
  exit 0
  ;;

  -checkdep)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-checkdep:     check program dependencies
-checkdep

  Runs tests to check primary dependencies, then exits

Example: None
--------------------------------------------------------------------------------
EOF
  shift && continue
fi
  ;;

  -colorblind)
    if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-colorblind:   use colorblind-friendlier CPTs from Colorcet or other sources
-colorblind

  Seismicity:
  Topography:

Example:
  tectoplot -colorblind
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  colorblindflag=1
  # Do the required changes now
    SEIS_CPT=${CPTDIR}"colorcet/CET-CBL2.cpt"
    SEIS_CPT_INV="-I"
  ;;

  -compile)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-compile:      compile accompanying codes
-compile

  Compiles:
    access_litho (C)
    texture_shader (C)
      texture
      sky
      shadow
    reasenberg (Fortran)

Example:
  tectoplot -compile
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  ;;
  -countryid)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-countryid:    print list of recognized country codes and exit
-countryid

Example:
  tectoplot -countryid | grep "Ireland"
--------------------------------------------------------------------------------
EOF
    shift && continue
  fi
  ;;
  -data)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-data:         list data source info
-data

Example:
    tectoplot -data
--------------------------------------------------------------------------------
EOF
    shift && continue
  fi
  ;;

  -defaults)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-defaults:     print tectoplot defaults
-defaults

Example:
  tectoplot -defaults
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  ;;
  -formats)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-formats:      print information about file formats (input and output) and exit
-formats

Example: None
--------------------------------------------------------------------------------
EOF
  shift && continue
  fi
  ;;
  -getdata)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-getdata:      download datasets and compile c / Fortran programs
-getdata

    This option will attempt to download and minimally process data files.
    It will download files or compressed archives and verify the expected byte
    count. If the byte count is wrong due to updates, the download may fail.
    The function will extract archives and will try to redownload data if it
    is not marked as complete. Several basic C programs are compiled using gcc.

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
  fi
  ;;
  -ips)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ips:          plot over an existing, non-closed ps file
-ips [filename]

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
 tectoplot -r PA -t -ips tempfiles_to_delete/map.ps -pos 0i 3.7i
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
  ;;

  -setup)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-setup:        print setup information and exit
-setup
--------------------------------------------------------------------------------
EOF
shift && continue
  fi
  ;;

  -variables)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-variables:    print information about tectoplot variables
-variables
--------------------------------------------------------------------------------
EOF
shift && continue
  fi
  ;;

  -usage)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
--------------------------------------------------------------------------------
-usage:        basic description of tools
-usage   [command containing any number of -flags and arguments]
-usage   [all|what|args]
-usage   [topo]

Print explanations of options, arguments, and outputs for commands.

General:
 all:  Print usage messages for all commands
 what: Print short descriptions of commands
 args: Print information about arguments, for all commands

Collections of related commands:
 topo: Print short descriptions of topo-related commands

Outputs:
 None

Example:
 tectoplot usage args
--------------------------------------------------------------------------------
EOF
fi
USAGEFLAG=1

 if [[ $2 =~ "all" ]]; then
   shift
   SCRIPTFILE="${BASH_SOURCE[0]}"
   COMMANDLIST=$(grep "^-" ${SCRIPTFILE} | grep -v -- "---" | gawk '(substr($1,length($1),1) != ":" && substr($1,length($1),1) != ")") { print $1 }' | uniq | sort -f)
   echo tectoplot commands: ${COMMANDLIST[@]} | fold -s
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
     grep "^-" ${f} | grep -v -- "---" | gawk '(substr($1,length($1),1) == ":") { print " ", $0 }' | uniq | sort -f
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
 else
   # Assume we will read flags one by one
   usageskipflag=1
   echo "--------------------------------------------------------------------------------"
 fi

  ;;

  -tm|--tempdir) # Relative temporary directory placed into pwd
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tm:           define a custom temporary results directory
-tm [directory_path]

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  shift
  ;;

  -recenteq) # args: none | days
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-recenteq:     earthquakes in last n days
-recenteq      [[number_of_days=${LASTDAYNUM}]] [[print]]
  Sets options -a a -z -c -time date1 date2 where date1 is number_of_days ago
  and date2 is current date and time (both in UTC).
  Specification of -r is required, or the default region will be used.
Example: Plot last 1 month of earthquakes in USA
  tectoplot -r US -t 01d -recenteq 31
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
-seismo
  Plot a basic seismotectonic map for a region using default options
  Sets options -t -b c -z -c
  Specification of -r is required, or the default region will be used.
Example: Plot a seismotectonic map of Iran
  tectoplot -r IR -seismo
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    shift
    set -- "blank" "-t" "-b" "c" "-z" "-c" "$@"
    ;;

  -topog)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-topog:        plot a basic topographic map
-topog
  Plot a basic topographic map for a region and make an oblique view
  Sets options -t -ob 45 20 3
  Specification of -r is required, or the default region will be used.
  The oblique view PDF is stored in \${TMP}/oblique.pdf and script to adjust
  is in \${TMP}/make_oblique.sh [vexag] [az] [inc]
Example: Plot a topographic map of Venezuela
  tectoplot  -r VE -topog
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    shift
    set -- "blank" "-t" "-t1" "-ob" "45" "20" "3" "$@"
    ;;

  -sunlit)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-sunlit:       plot topo with unidirectional hillshade and cast shadows
-sunlit
  Plot a basic topographic map for a region with cast shadows, and oblique view
  Sets options -t -tuni -tshad -ob 45 20 3
  Specification of -r is required, or the default region will be used.
  The oblique view PDF is stored in \${TMP}/oblique.pdf and script to adjust
  is in \${TMP}/make_oblique.sh [vexag] [az] [inc]
Example: Plot a topographic map of Switzherland with cast shadows
  tectoplot -r CH -sunlit
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    shift
    set -- "blank" "-t" "-tuni" "-tshad" "-ob" "45" "20" "3" "$@"
    ;;

  -eventmap)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-eventmap:     plot an earthquake summary map
-eventmap [earthquakeID] [[degree_width]]
  Plot a basic seismotectonic map and cross section centered on an earthquake
  Includes topography, Slab2.0, seismicity, focal mechanisms (ORIGIN location).
  Labels the selected earthquake on map and cross-section.
  Plots a 1:1 (V=H) E-W profile, or orients the profile along the dip-direction
  if a Slab2.0 grid exists beneath the event.
  Plots a legend and sets the title to the earthquake ID.
Example: Plot a seismotectonic map of the M7.8 2015 Gorkha, Nepal earthquake
  tectoplot -eventmap us20002926
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
    if arg_is_flag $2; then
      info_msg "[-eventmap]: No degree buffer specified. Using 2 degrees"
      EVENTMAP_DEGBUF=2
    else
      EVENTMAP_DEGBUF="${2}"
      shift
    fi
    shift # Gets rid of EVENTMAP_ID somehow...
    #
    set -- "blank" "-r" "eq" ${EVENTMAP_ID} ${EVENTMAP_DEGBUF} "-t" "-b" "c" "-z" "-c" "ORIGIN" "-eqlist" "{" "${EVENTMAP_ID}" "}" "-eqlabel" "list" "-legend" "onmap" "-title" "Earthquake $EVENTMAP_ID" "$@" # "-cprof" "eq" "eq" "slab2" "map" "100k" "-oto" "-mob"
    ;;

  # Normal commands

  -af) # args: string string
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-af:           plot global earthquake model (gem) active faults
-af [[line width=${AFLINEWIDTH}]] [[line color=${AFLINECOLOR}]]
Example: Plot a map of GEM active faults around India
  tectoplot -r IN -a -af 0.5p red
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
-alignz [filename]

  Use -alignxy to set the intersection line.

Example: Stack topographic profiles across SE Indian continental margin
  echo "80 16" > line.xy && echo "88 22" >> line.xy
  tectoplot -r IN -t -alignxy line.xy -aprof QM LH 20k 0.1k -alignz
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
-alignxy [filename]
Example: Stack topographic profiles across SE Indian continental margin
  echo "80 16" > line.xy && echo "88 22" >> line.xy
  tectoplot -r IN -t -alignxy line.xy -aprof QM LH 20k 0.1k
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
-bigbar [cpt_name] [["Explanation string"]]
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
-cprof [centerlon or "eq"] [centerlat or "eq"] [azimuth or "slab2"] [length] [width] [resolution]
  [centerlon]/[centerlat] are coordinates at profile center (degrees)
    eq = use earthquake ID location
  [azimuth] is profile azimuth (CW from north, degrees)
    slab2 = use slab2 down-dip direction
  [length] is profile length in km (no units specified on command line)
  [width] is profile swath width with k units specified (e.g. 25k)
  [resolution] is sampling resolution with k units specified (e.g 1k)
Example: Create a topographic swath profile across the Straits of Gibraltar
  tectoplot -r -6.5 -4.5 35 37 -t -a -cprof -5.5 36 350 100 10k 0.05k
            -setvars { SPROF_MAXELEV 2 SPROF_MINELEV -4 }
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  # Create profiles by constructing a new mprof) file with relevant data types
  # where the profile is specified by central point and azimuth

  # Sprof and cprof share SPROFWIDTH and SPROF_RES

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
      info_msg "[-cprof]: No width specified. Using 100k"
      SPROFWIDTH="100k"
    else
      SPROFWIDTH="${2}"
      shift
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

    # Create the template file that will be used to generate the cprof_profs.txt file
    # antiaz foreaz centerlon|eqlon centerlat|eqlat cprofhalflen
    pwd
    echo $CPROFAZ $CPROFLON $CPROFLAT $CPROFHALFLEN \>\> ${TMP}${F_PROFILES}cprof_prep.txt
    echo $CPROFAZ $CPROFLON $CPROFLAT $CPROFHALFLEN >> ${TMP}${F_PROFILES}cprof_prep.txt
    # Calculate the profile start and end points based on the given information
  ;;

  -aprof) # args: aprofcode1 aprofcode2 ... width res
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-aprof:        specify automatic profiles using a coordinate grid on the map
-aprof [code1] [[code2...]] [width] [resolution]
  [codeN] are [A-Y][A-Y] (e.g. CW, AE) letter pairs denoting profile start/end
    -> (you can plot letters on the map using -aprofcodes)
  [width] is profile swath width with k units specified (e.g. 25k)
  [resolution] is sampling resolution with k units specified (e.g 1k)
  Profile vertical range is fixed to ${SPROF_MINELEV}/${SPROF_MAXELEV}
Example: Create a topographic swath profile across Guatemala
  tectoplot -r GT -t -aprof AS 100k 1k
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    # Create profiles by constructing a new mprof) file with relevant data types
    aprofflag=1

    while [[ "${2}" == [A-Y][A-Y] ]]; do
      aproflist+=("${2}")
      shift
    done

    if arg_is_flag $2; then
      info_msg "[-aprof]: No width specified. Using 100k"
      SPROFWIDTH="100k"
    else
      SPROFWIDTH="${2}"
      shift
    fi

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
-aprofcodes
Example: Plot letter coordinates for a map of Guatemala
  tectoplot -r GT -t -aprofcodes
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
-arrow [narrower | narrow | normal | wide | wider]

Example: Plot GPS velocities with wide arrows
  tectoplot -a -g pa -arrow wide
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
-datareport:   plot footprints of downloaded data (DEM/Sentinel)
-datareport

  GMRT: red
  EARTHRELIEF (GMT server): blue
  Sentinel: green
  Saved topography: shaded gray
  Custom DEMs: purple
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  plots+=("datareport")

  ;;

  -regionreport)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-regionreport: plot and label footprints of custom regions / saved shaded relief
-regionreport

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

-author
  Plot author and datestring at lower left corner of map
-author reset
  Delete stored author information and then exit
-author print
  Print stored author information and then exit
-author nodate
  Plot author but not timestamp on map.
-author "Author ID"
  Store author information in ${OPTDIR}tectoplot.author

Example: Reset a stored author ID and then update it to "Author 1"
  tectoplot -author print
  tectoplot -author reset
  tectoplot -author "Author 1"
  tectoplot -author print

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
-authoryx [YSHIFT] [XSHITY]
Example: Shift -author text to the right and up
  tectoplot -r GT -a -author -authoryx 3 3
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
-B { opt1 opt2 ... }
  This option is not well tested!

Example: Plot Slab2.0 around Japan with custom longitude markings.
  tectoplot -r JP -a -B { -Bxa1f1 }
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

	-c|--cmt) # args: none || number
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-c:            plot focal mechanism beach balls (cmt)
-c [[TYPE=${CMTTYPE}]] [[scale=${CMTSCALE}]]
  Plots focal mechanisms from combined catalog (or custom file using -ccat)
  Scraped catalog includes harmonized GCMT, ISC, and GFZ solutions
  TYPE: CENTROID or ORIGIN  (reflecting XYZ location)
  scale: multiplication factor on the default seismicity scale ${SEISSCALE}

Example: Plot focal mechanisms around New Zealand
  tectoplot -r NZ -c -a
--------------------------------------------------------------------------------
EOF
shift && continue
fi

		calccmtflag=1
		plotcmtfromglobal=1
    cmtsourcesflag=1
    # CMTFILE=$FOCALCATALOG

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
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ca:           plot CMT kinematic axes (tpn) for different types (nts)
-ca [[axesstring=${CMTAXESSTRING}]] [[cmttypestring=${CMTAXESTYPESTRING}]]
  Plots principal axes
  axesstring characters: t = T axis (tensional)     color = purple
                         p = P axis (compressional) color = blue
                         n = N axis (neutral)       color = green
  cmttypestring:         t = thrust, n = normal, s = strike slip

Example: Plot P axes for thrust-type focal mechanisms around New Zealand
  tectoplot -r NZ -ca t t -a
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    calccmtflag=1
    cmtsourcesflag=1
    plotcmtfromglobal=1

    if arg_is_flag $2; then
      info_msg "[-ca]: CMT axes eq type not specified. Using default ($CMTAXESSTRING)"
    else
      CMTAXESSTRING="${2}"
      shift
      if arg_is_flag $2; then
        info_msg "[-ca]: CMT axes selection string not specfied. Using default ($CMTAXESTYPESTRING)"
      else
        CMTAXESTYPESTRING="${2}"
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
-cc:           connect focal mechanisms to alternate location (centroid/origin)
-cc
  Plots a line connecting focal mechanism to a dot at the alternate location,
  on both map and cross section plots.
Example: Show shift of CENTROID and ORIGIN locations near New Zealand
  tectoplot -r NZ -c -cc -a
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    connectalternatelocflag=1
    ;;

#   -cf) # args: string
# if [[ $USAGEFLAG -eq 1 ]]; then
# cat <<-EOF
# -cf:           set gmt format of focal mechanism files and plotting method
# -cf [[format=${CMTFORMAT}]]
#   Plots a line connecting focal mechanism to a dot at the alternate location,
#   on both map and cross section plots.
#   format=GlobalCMT|c       is GCMT SDR format
#   format=MomentTensor|m    is moment tensor (possibly derived)
#   format=TNP|y             is best double couple principal axes
#
# Example: Plot CMT data with MomentTensor method, New Zealand
#   tectoplot -r NZ -c -cf m -a
# --------------------------------------------------------------------------------
# EOF
# shift && continue
# fi
#     if arg_is_flag $2; then
#       info_msg "[-cf]: CMT format not specified (GlobalCMT, MomentTensor, PrincipalAxes). Using default ${CMTFORMAT}"
#     else
#       CMTFORMAT="${2}"
#       shift
#       #CMTFORMAT="PrincipalAxes"        # Choose from GlobalCMT / MomentTensor/ PrincipalAxes
#       case $CMTFORMAT in
#       GlobalCMT|c)
#         CMTFORMAT="GlobalCMT"
#         CMTLETTER="c"
#         CMTEXTRA=""
#         ;;
#       MomentTensor|m)
#         CMTFORMAT="MomentTensor"
#         CMTLETTER="m"
#         CMTEXTRA="-Fz"
#         ;;
#
#       TNP|y)
#         CMTFORMAT="TNP"
#         CMTLETTER="y"
#         CMTEXTRA=""
#         ;;
#       *)
#         info_msg "[-cf]: CMT format ${CMTFORMAT} not recognized. Using GlobalCMT"
#         CMTFORMAT="GlobalCMT"
#         CMTLETTER="c"
#         ;;
#       esac
#     fi
#     ;;

# Filter focal mechanisms by various criteria
# maxdip: at least one nodal plane dip is lower than this value

  -cfilter)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-cfilter:      filter CMT by nodal plane dip or rake range
-cfilter [command1] [arg1] [[command2]] [[arg2]] ...

The criteria are evaluated separately, and an event is rejected only
if neither nodal plane meets each criterion. rakerange takes two
arguments.

commands (all arguments are in degrees)

  maxdip    [dip]
  mindip    [dip]
  maxstrike [strike]
  minstrike [strike)]
  rakerange [minrake] [maxrake]

Example: Plot CMT data with a nodal plane with a rake between 160 and 130, New Zealand
  tectoplot -r NZ -a -c -cfilter rakerange 130 160
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
-clipdem

  This process is done for virtually all plots anyway.

Example: Clip a DEM to the AOI of Albania
  tectoplot -r AL -clipdem
  gmt grdinfo tempfiles_to_delete/topo/dem.nc
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    clipdemflag=1
    ;;

#   -clipgrav)
# if [[ $USAGEFLAG -eq 1 ]]; then
# cat <<-EOF
# -clipgrav:     save clipped gravity file as grav.nc
# -clipgrav
#
# Example: Clip a Bouguer gravity anomaly to the AOI of Albania
#   tectoplot -r AL -v BG 0 -clipgrav
#   gmt grdinfo tempfiles_to_delete/grav/grav.nc
# --------------------------------------------------------------------------------
# EOF
# shift && continue
# fi
#     clipgravflag=1
    # ;;

  -clipon|-clipout)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-clipon:       activate clipping polygon (inside)
-clipout:      activate clipping polygon (outside)
-clipon [ polygonFile or regionID ]
-clipout [ polygonFile or regionID ]

  Turn on PS clipping to mask areas that are subsequently plotted into.

  polygonFile is a potentially multisegment (> dividing lines) LON LAT file.
  regionID is any GMT region recognized by pscoast (e.g. =NA ; FR,ES ; etc.)
  -clipline [ polygonFile | regionID ] will plot the clipping line
  -clipoff is necessary to release clipping before closing the PS file.

Example: Use -clipon, -clipout, -clipoff to make a composite map of New Zealand
  tectoplot -r NZ -clipon NZ -t -clipoff -clipout NZ -v BG 0 rescale -clipoff -clipline
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    clipcmd=$1
    CLIP_POLY_FILE=$(abs_path $2)
    if [[ -e ${CLIP_POLY_FILE} ]]; then
      info_msg "[-clipon|clipout]: Using polygon file ${CLIP_POLY_FILE}"
      shift
      [[ $clipcmd =~ "-clipon" ]] && plots+=("clipon")
      [[ $clipcmd =~ "-clipout" ]] && plots+=("clipout")
    else
      info_msg "[-clipon|clipout]: No polygon file ${CLIP_POLY_FILE} found. Interpreting as GMT ID"
      # Extract the DCW borders and fix the longitude range if necessary
      gmt pscoast -E${2} -M ${VERBOSE} | gawk '
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
      }' > ${TMP}tectoplot_path.clip

      CLIP_POLY_FILE=$(abs_path ${TMP}tectoplot_path.clip)

      # gmt pscoast -E${2} -M ${VERBOSE}  > tectoplot_path.clip
      shift
      if [[ -s ${TMP}tectoplot_path.clip ]]; then
        copyandsetclippolyfileflag=1
        [[ $clipcmd =~ "-clipon" ]] && plots+=("clipon")
        [[ $clipcmd =~ "-clipout" ]] && plots+=("clipout")
      fi
    fi
    ;;

  -clipoff)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-clipoff:      deactivate clipping polygon

  Turn off all PS clipping.

Example: Use -clipon, -clipout, -clipoff to make a composite map of New Zealand
  tectoplot -r NZ -clipon NZ -t -clipoff -clipout NZ -v BG 0 rescale -clipoff -clipline
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    plots+=("clipoff")
    ;;

  -clipline)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-clipoff:      deactivate clipping polygon

  Plot previously defined clipping polygon as a line.

Example: Use -clipon, -clipout, -clipoff to make a composite map of New Zealand
  tectoplot -r NZ -clipon NZ -t -clipoff -clipout NZ -v BG 0 rescale -clipoff -clipline
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    plots+=("clipline")
    ;;

  -cmag) # args: number number
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-cmag:         set magnitude range for focal mechanisms
-cmag [minmag] [[maxmag]]

  Set magnitude range of focal mechanisms.

Example: Plot a map of focal mechanisms in Albania between M5 and M6
  tectoplot -r AL -t -c -cmag 5 6
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

#   -cn|--contour)
# if [[ $USAGEFLAG -eq 1 ]]; then
# cat <<-EOF
# -cn:           plot contours of a grid
# -cn [gridfile] [[ { GMT GRID COMMANDS } ]]
#
#   Contour a grid using GMT format options
#
# Example:
#    None yet
# --------------------------------------------------------------------------------
# EOF
# shift && continue
# fi
#     if arg_is_flag $2; then
#       info_msg "[-cn]: Grid file not specified"
#     else
#       CONTOURGRID=$(abs_path $2)
#       shift
#       if arg_is_flag $2; then
#         info_msg "[-cn]: Contour interval not specified. Calculating automatically from Z range using $CONTOURNUMDEF contours"
#         gridcontourcalcflag=1
#       else
#         CONTOURINTGRID="${2}"
#         shift
#       fi
#     fi
#     if [[ ${2:0:1} == [{] ]]; then
#       info_msg "[-cn]: GMT argument string detected"
#       shift
#       while : ; do
#           [[ ${2:0:1} != [}] ]] || break
#           gridvars+=("${2}")
#           shift
#       done
#       shift
#       CONTOURGRIDVARS="${gridvars[@]}"
#     fi
#     info_msg "[-cn]: Custom GMT grid contour commands: ${CONTOURGRIDVARS[@]}"
#     plots+=("gridcontour")
#     ;;

  -command)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-command:      print the complete tectoplot command on the map
-command

  If -author is specified, justify lower right. If not, lower left.

Example:
   tectoplot -r AL -a -command
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    printcommandflag=1
    ;;

#   -countries)
# if [[ $USAGEFLAG -eq 1 ]]; then
# cat <<-EOF
# -countries:    print randomly colored country polygons
# -countries [trans] [[cpt]]
#   trans is percent in 0-100
#   cpt is any GMT recognized CPT file
#
#   Currently, the colors change each time the plot is produced!
#
# Example:
#    tectoplot -r =AF -countries 0 wysiwyg -a
# --------------------------------------------------------------------------------
# EOF
# shift && continue
# fi
#
#     if arg_is_positive_float $2; then
#       COUNTRIES_TRANS="${2}"
#       shift
#     fi
#     if ! arg_is_flag $2; then
#       COUNTRIESCPT="${2}"
#       shift
#     fi
#     plots+=("countries")
#     ;;

  -cpts)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-cpts:         remake tectoplot cpts
-cpts

Example:
   tectoplot -cpts
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    remakecptsflag=1
    ;;

  -cr|-cmtrotate) # args: number number
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-cmtrotate:    rotate focal mechanisms based on back-azimuth to pole
-cmtrotate [pole lon] [pole lat] [reference azimuth]
   This is a very specific routine that is likely to be removed.

Example:
   tectoplot -c -cmtrotate 120 20 90
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

#   -cs) # args: none
# if [[ $USAGEFLAG -eq 1 ]]; then
# cat <<-EOF
# -cs:           plot cmt axes on stereonet
# -cs
#    Not currently working. Output file is stereo.pdf in temporary directory.
#
# Example:
#    tectoplot -r PY -c -cs
# --------------------------------------------------------------------------------
# EOF
# shift && continue
# fi
#     caxesstereonetflag=1
#     ;;

-cslab2)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-cslab2:       select thrust CMTs consistent with rupture of slab2.0 surface
-cslab2 [[distance]] [[strike_diff]] [[dip_diff]]

  From CMT catalog, for already selected thrust mechanisms, retain only those
  within a specified vertical distance from slab2, and with at least one nodal
  plane with similar strike and dip.

  distance is in km
  strike_diff and dip_diff are in degrees


Example: None
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

  Rotate focal mechanisms around a horizontal axis parallel to local slab strike
  by an angle equal to slab dip. This is an approximate correction to restore
  subducted faults to their pre-subduction orientation.

Example: None
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
-cdeep [[buffer_distance=${CMTSLAB2VERT}]]

  Buffer distance shifts the Slab2 model down (negative) or up (positive) [km]
  For this option only, buffer_distance also applies to Earth's surface so
  buffer_distance=-30 will select only regional events (not below Slab2 model)
  below depths of 30 km.

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  cmtslab2_deep_filterflag=1
  if arg_is_float $2; then
    CMTSLAB2VERT=${2}
    shift
  fi
  ;;

-cshallow)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-cshallow:     select focal mechanisms in upper plate above slab2 model
-cshallow [[buffer_distance=${CMTSLAB2VERT}]]

  Buffer distance shifts the Slab2 model down (negative) or up (positive) [km]

Example: None
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

  -ct|--cmttype) # args: string
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ct:           choose focal mechanism classes (thrust, normal, strike-slip)
-ct [optstring]
   n: Select normal mechanisms
   t: Select thrust mechanisms
   s: Select strike-slip mechanisms

Example: Plot strike-slip focal mechanisms in Tajikistan
   tectoplot -r TJ -c -ct s
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
-cw

Example: Plot focal mechanisms in Idaho, USA
    tectoplot -t -r US.ID -c -cw
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    CMT_THRUSTCOLOR="gray100"
    CMT_NORMALCOLOR="gray100"
    CMT_SSCOLOR="gray100"
    ;;

  -e|--execute) # args: file
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-e:            execute custom script
-e [script.sh]

  Execute a script via bash sourcing (. script.sh). The script will run in the
  current tectoplot environment and will have access to its variables.
  Please be careful about running scripts in this fashion as there are no checks
  on whether the script is safe.

Example:
    echo "echo \"AOI: \${MINLON}/\${MAXLON}/\${MINLAT}/\${MAXLAT}\"" > script.sh
    tectoplot -r BR -t 10m -e ./script.sh -a
    rm -f ./script.sh
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    EXECUTEFILE=$(abs_path $2)
    shift
    plots+=("execute")
    ;;

  -eps)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-eps:          overlay eps file when producing final pdf
-eps [filename.eps]

  Overlay an existing EPS file. This option currently doesn't work reliably.

Example:
    None
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    epsoverlayflag=1
    EPSOVERLAY=$(abs_path $2)
    shift
    ;;

  -eqlabel)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-eqlabel:      label earthquake events using various criteria
-eqlabel [selectoptions] [formatoptions]

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

Example: Label focal mechanisms of earthquakes in Peru larger than Mw=7
    tectoplot -r PE -c -a -eqlabel 7 mag
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
        elif [[ $2 == "idmag" || $2 == "datemag" || $2 == "datetime" || $2 == "dateid" || $2 == "id" || $2 == "date" || $2 == "mag" || $2 == "year" || $2 == "yearmag" ]]; then
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
-eqlist  [filename] { eqID1 eqID2 ... }

  Populate a list from a file of earthquake IDs and/or a bracketed list.
  Use with -eqlabel and -eqselect.

Example: None
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
-eqselect

  Use this option to select earthquakes using a list.

Example:
  tectoplot -r TW -t -c -eqlist { C092099D C061000J } -eqselect -eqlabel 1
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    eqlistselectflag=1;
    ;;

	-f|--refpt)   # args: number number
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-f:            specify reference point for plate motion models
-f [lon] [lat]

  The stationary plate will be set to the one containing the reference point.
  A circled triangle will be plotted at the reference point.

Example: Plate motions around Puerto Rico and Cuba, Puerto Rico fixed
  tectoplot -r PR,CU -t -p MORVEL -pe -pf 100 -f -74 19
--------------------------------------------------------------------------------
EOF
shift && continue
fi
		refptflag=1
		REFPTLON="${2}"
		REFPTLAT="${3}"
		shift
		shift
		info_msg "[-f]: Reference point is ${REFPTLON}/${REFPTLAT}"
    plots+=("refpoint")
	   ;;

  -fe)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-fe:           plot Flinn-Engdahl geographic or seismic regions
-fe [[seismic]]

  By default, plots and labels Flinn-Engdahl regions

  seismic: plot seismic regions instead of geographic regions

Example: None
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

#   # Plot tectonic fabrics
#   -tf)
# if [[ $USAGEFLAG -eq 1 ]]; then
# cat <<-EOF
# -tf:           plot tectonic fabrics
# -tf [code1] [[code2]] ...
#
#   codes
#   all: Plot all codes except cp
#
#   cp: continental polygons (Matthews et al., 2016; via Gplates2.2.0)
#   dz: discordant zones (EarthByte)
#   fz: fracture zones (EarthByte)
#   pf: pseudo faults (EarthByte)
#   pr: propagating ridges (EarthByte)
#   sr: spreading ridges (active and extinct) (Muller et al., 2016; via Gplates2.2.0)
#   va: v-anomalies, classified and unclassified (EarthByte)
#   vp: volcanic provinces (Johansson et al., 2018; via Gplates2.2.0)
#
# Example: None
# --------------------------------------------------------------------------------
# EOF
# shift && continue
# fi
#
#   unset tectonic_fabrics
#   if [[ "${2}" == "all" ]]; then
#     tectonic_fabrics+=("vp")
#     tectonic_fabrics+=("dz")
#     tectonic_fabrics+=("fz")
#     tectonic_fabrics+=("pf")
#     tectonic_fabrics+=("pr")
#     tectonic_fabrics+=("sr")
#     tectonic_fabrics+=("va")
#     cpts+=("geoage")
#     plots+=("geoage")  # Fake
#
#     echo $EARTHBYTE_SOURCESTRING >> ${LONGSOURCES}
#     echo $EARTHBYTE_SHORT_SOURCESTRING >> ${SHORTSOURCES}
#     echo $TECTFABRICS_SR_SOURCESTRING >> ${LONGSOURCES}
#     echo $TECTFABRICS_SR_SHORT_SOURCESTRING >> ${SHORTSOURCES}
#     echo $TECTFABRICS_VP_SOURCESTRING >> ${LONGSOURCES}
#     echo $TECTFABRICS_VP_SHORT_SOURCESTRING >> ${SHORTSOURCES}
#     shift
#   else
#     while ! arg_is_flag "${2}"; do
#         case "${2}" in
#           cp)
#             tectonic_fabrics+=("cp")
#             echo $TECTFABRICS_CP_SOURCESTRING >> ${LONGSOURCES}
#             echo $TECTFABRICS_CP_SHORT_SOURCESTRING >> ${SHORTSOURCES}
#             cpts+=("plateid")
#           ;;
#           dz)
#             tectonic_fabrics+=("dz")
#             echo $EARTHBYTE_SOURCESTRING >> ${LONGSOURCES}
#             echo $EARTHBYTE_SHORT_SOURCESTRING >> ${SHORTSOURCES}
#           ;;
#           fz)
#             tectonic_fabrics+=("fz")
#             # plots+=("fracturezones")
#             echo $EARTHBYTE_SOURCESTRING >> ${LONGSOURCES}
#             echo $EARTHBYTE_SHORT_SOURCESTRING >> ${SHORTSOURCES}
#           ;;
#           pf)
#             tectonic_fabrics+=("pf")
#             echo $EARTHBYTE_SOURCESTRING >> ${LONGSOURCES}
#             echo $EARTHBYTE_SHORT_SOURCESTRING >> ${SHORTSOURCES}
#           ;;
#           pr)
#             tectonic_fabrics+=("pr")
#             echo $EARTHBYTE_SOURCESTRING >> ${LONGSOURCES}
#             echo $EARTHBYTE_SHORT_SOURCESTRING >> ${SHORTSOURCES}
#           ;;
#           sr)
#             tectonic_fabrics+=("sr")
#             echo $TECTFABRICS_SR_SOURCESTRING >> ${LONGSOURCES}
#             echo $TECTFABRICS_SR_SHORT_SOURCESTRING >> ${SHORTSOURCES}
#             # plots+=("spreadingridges")
#           ;;
#           va)
#             tectonic_fabrics+=("va")
#             echo $EARTHBYTE_SOURCESTRING >> ${LONGSOURCES}
#             echo $EARTHBYTE_SHORT_SOURCESTRING >> ${SHORTSOURCES}
#           ;;
#           vp)
#             tectonic_fabrics+=("vp")
#             # plots+=("volcanicprovinces")
#             echo $TECTFABRICS_VP_SOURCESTRING >> ${LONGSOURCES}
#             echo $TECTFABRICS_VP_SHORT_SOURCESTRING >> ${SHORTSOURCES}
#             makegeoageflag=1
#           ;;
#         esac
#     shift
#     done
#   fi
#   if [[ $makegeoageflag -eq 1 ]]; then
#     cpts+=("geoage")
#     plots+=("geoage")  # Fake
#   fi
#   plots+=("tectonic_fabrics")
#   ;;

	-g|--gps) # args: none || string
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-g:            plot gps velocities from builtin catalog
-g [refplate]

  GPS velocities exist for all plates in Kreemer et al., 2014 supplementary
  database. If -p is used, -g will assume the same plate ID as -p unless it is
  overridden with [refplate].
  Velocity vector lengths can be scaled using -i.

Example: Plate motions and GPS velocities around Puerto Rico and Cuba (plate na)
  tectoplot -r PR,CU -t -p MORVEL -pe -pl -pf 100 -g
--------------------------------------------------------------------------------
EOF
shift && continue
fi
		plotgps=1
		info_msg "[-g]: Plotting GPS velocities"
		if arg_is_flag $2; then
			info_msg "[-g]: No override GPS reference plate specified"
		else
			GPSID="${2}"
			info_msg "[-g]: Ovveriding GPS plate ID = ${GPSID}"
			gpsoverride=1
			GPS_FILE=`echo $GPSDIR"/GPS_$GPSID.gmt"`
			shift
      echo $GPS_SOURCESTRING >> ${LONGSOURCES}
      echo $GPS_SHORT_SOURCESTRING >> ${SHORTSOURCES}
		fi
		plots+=("gps")
		;;

  -gadd) # args: file
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-gadd:         plot custom gps velocity file in gmt psvelo format
-gadd [velocityFile] [[color colorID=$EXTRAGPS_FILLCOLOR]]

  GPS velocities are plotted with filled arrows. The reference frame
  is assumed to be correct for the given map.

  This command can be called multiple times

  NOTE: psvelo format is:
  lon lat VE VN SVE SVN XYCOR SITEID INFO

Example: Plot a hypothetical plate velocity in Turkey
  echo "39 39 -45 45 1 1 0.1 KEB Fake-GPS" > gps.dat
  tectoplot -r TR -t -p MORVEL -pe -pl -pf 100 -g eu -gadd gps.dat
  rm -f gps.dat
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
        log)
          shift
          USERGPSLOG_arr[$usergpsfilenumber]=1
        ;;
      esac
    done

    plots+=("extragps")

    ;;

-fixcpt)
replace_gmt_colornames_rgb $2
exit
;;

  -gebcotid)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-gebcotid:     plot gebco20 tid raster (data source id)
-gebcotid

  GEBCO20 includes both observed and interpolated data. The TID map indicates
  which type of data populates each raster cell.

  Progress needs to be made to create an effective legend for this option.

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    plots+=("gebcotid")
    clipdemflag=1
    ;;

  -geotiff)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-geotiff:      create a georeferenced rgb geotiff from the map document
-geotiff [[resolution]]

    This option will reset the map projection and region to the Cartesian
    projection required for export to GeoTIFF using gmt psconvert.

    The output file is saved with the same name as the output PDF, but as .tif

    resolution: the resolution (in dpi) of the output GeoTIFF file.
Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    if [[ $regionsetflag -ne 1 ]]; then
      info_msg "[-geotiff]: WARNING: Region should be set with -r before -geotiff flag is set. Using default region."
    fi
    gmt gmtset MAP_FRAME_TYPE inside
    RJSTRING="-R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} -JX${PSSIZE}id"
    usecustomrjflag=1
    insideframeflag=1
    tifflag=1

    if arg_is_positive_float $2; then
      GEOTIFFRES="${2}"
      shift
    fi

    ;;

  -gls)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-gls:          list all gps reference frames (plates)
-gls

Example:
  tectoplot -gls
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
-gmtvars { PARAMETER1 value1 PARAMETER2 val2 ... }

  Changes the state of a GMT variable (e.g. MAP_FRAME_PEN) using gmtset

Example:
  tectoplot -gmtvars { MAP_ANNOT_OFFSET_PRIMARY 4p MAP_FRAME_TYPE fancy } -r BR -a
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

  # -ebiso) # Seafloor isochrons
  #   plots+=("ebiso")
  #   cpts+=("geoage")
  #   ;;
  #
  # -ebhot) # Seafloor isochrons
  #   plots+=("ebhot")
  #   cpts+=("geoage")
  #   ;;

  -gridlabels) # args: string (quoted)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-gridlabels:   specify how map axes are presented and labeled
-gridlabels [optstring]

  This option is used to set map axis labeling. Lower case
  letters indicate no labelling, upper case letters indicate labeling.
  b/S: bottom unlabeled / bottom labeled
  l/W: left unlabeled / left labeled
  t/N: top unlabeled / top labeled
  r/E: right unlabeled / right labeled


Example:
  tectoplot -r CR -gridlabels EWns -a
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
-gres [dpi]

  GMT plots grids at their native resolution, creating very large files in some
  cases. Use this option to set the dpi of plotted grids. Resampling is done at
  the plotting step.

Example:
  tectoplot -r CR -t -gres 30
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

  -i|--vecscale) # args: number
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-i:            rescale velocity vectors
-i [factor]

  Rescale GPS, plate motion, and other velocity vectors by the given factor.

Example:
  tectoplot -r CR -g -i 3 -a
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    VELSCALE=$(echo "${2} * $VELSCALE" | bc -l)
    info_msg "[-i]: Vectors scaled by factor of ${2}, result is ${VELSCALE}"
    shift
    ;;

#   -im|--image) # args: file { arguments }
# if [[ $USAGEFLAG -eq 1 ]]; then
# cat <<-EOF
# -im:           plot a referenced RGB grid file (e.g. GeoTiff)
# -im [filename] { GMT OPTIONS }
#
#   gmt options (to psimage) might include { -t50 }
#
# Example: None
# --------------------------------------------------------------------------------
# EOF
# shift && continue
# fi
#     IMAGENAME=$(abs_path $2)
#     shift
#     # Args come in the form $ { -t50 -cX.cpt }
#     if [[ ${2:0:1} == [{] ]]; then
#       info_msg "[-im]: image argument string detected"
#       shift
#       while : ; do
#           [[ ${2:0:1} != [}] ]] || break
#           imageargs+=("${2}")
#           shift
#       done
#       shift
#       info_msg "[-im]: Found image args ${imageargs[@]}"
#       IMAGEARGS="${imageargs[@]}"
#     fi
#     plotimageflag=1
#     plots+=("image")
#     ;;

  -inset)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-inset:        place an inset globe showing map aoi
-inset [[size=${INSET_SIZE}]] [[degree_width=${INSET_DEGREE}]] [[x_shift=${INSET_XOFF}]] [[y_shift=${INSET_YOFF}]]

  Plot an inset globe. Default location is lower left of map; can be modified
  with x_shift and y_shift values.

Example: Plot a map of Panama with a strategically placed location inset
  tectoplot -r PA -a -inset 1i 30 4i 0.15i
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if arg_is_flag $2; then
      info_msg "[-inset]: No inset size specified. Using ${INSET_SIZE}".
    else
      INSET_SIZE="${2}"
      shift
    fi
    if arg_is_flag $2; then
      info_msg "[-inset]: No horizon degree width specified. Using ${INSET_DEGREE}".
    else
      INSET_DEGWIDTH="${2}"
      shift
    fi
    if arg_is_flag $2; then
      info_msg "[-inset]: No x shift relative to bottom left corner specified. Using ${INSET_XOFF}".
    else
      INSET_XOFF="${2}"
      shift
    fi
    if arg_is_flag $2; then
      info_msg "[-inset]: No y shift relative to bottom left corner specified. Using ${INSET_YOFF}".
    else
      INSET_YOFF="${2}"
      shift
    fi
    addinsetplotflag=1
    ;;


  -keepopenps) # args: none
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-keepopens:    keep ps file open for subsequent plotting
-keepopenps

  Allow subsequent plotting and don't attempt to convert unclosed PS to PDF.

Example: Keep a PS file open
  tectoplot -r PA -a -keepopenps
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    keepopenflag=1
    KEEPOPEN="-K"
    ;;

	-kg|--kingeo) # args: none
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-kg:           plot strike and dip symbols for focal mechanism nodal planes
-kg

  Currently only works for thrust type focal mechanisms. [TO UPDATE]

  The N1 nodal plan has the lower dip value; N2 has a higher dip. The N1/N2
  planes can be selected using the option -kl.

Example: Plot strike and dip of both nodal planes for thrust CMTs in California
  tectoplot -r US.CA -kg -a
--------------------------------------------------------------------------------
EOF
shift && continue
fi
		calccmtflag=1
    plotcmtfromglobal=1

		strikedipflag=1
		plots+=("kingeo")
		;;

  -kl|--nodalplane) # args: string
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-kl:           select nodal planes 1 or 2
-kl [number]

  The N1 nodal plan has the lower dip value; N2 has a higher dip.
  1: Use only the N1 nodal planes
  2: Use only the N2 nodal planes
  3: Use both N1 and N2 nodal planes (Default)

Example: Plot strike/dip of shallowest dipping nodal planes for CMTs in Tonga
  tectoplot -r TO -kg -kl 1 -a
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

  -km|--kinmag) # args: number number
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-km:           set magnitude range of cmt kinematics events
-km [minmag] [maxmag]

Example: None
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
-kml:          output kml file of borderless map for google earth
-kml [[kmlres=${KMLRES}]]
  File is output to map.kml in the temporary directory.

Example: KML of Great Britain topography
  tectoplot -r GB -t -kml
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
    usecustomrjflag=1
    insideframeflag=1
    kmlflag=1
    ;;

	-ks|--kinscale)  # args: number
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ks:           set the scale of kinematic objects (strike/dip, slip vectors)
-ks [scale=${KINSCALE}]

  Scale units are currently in default map units (cm???)

Example: Make a strike/dip plot of nodal planes with large symbols
  tectoplot -r CR -t -kg -ks 0.25
--------------------------------------------------------------------------------
EOF
shift && continue
fi
		calccmtflag=1
		KINSCALE="${2}"
		shift
    info_msg "[-ks]: CMT kinematics scale updated to $KINSCALE"
	  ;;

	-kt|--kintype) # args: string
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-kt:           select focal mechanism kinematic data based on earthquake type
-kt [typestring]

  Mechanisms are classified by N-T-P axes plunges.

  typestring:
  n: Select normal type mechanisms
  t: Select thrust type mechanisms
  s: Select strike-slip type mechanisms

Example: Plot slip vectors of slip on nodal plane 2, for normal events in Greece
  tectoplot -r GR -t -kv -kt n -kl 2
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

 	-kv|--kinsv)  # args: none
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-kv:           plot focal mechanism slip vectors
-kv [typestring]

  The slip vector of a nodal plane is oriented 90° from the strike of the other
  nodal plane, and represents the horizontal component of motion. It is directly
  related to rake, but is a directional azimuth. Each focal mechanism has two
  slip vectors, only one of which represents the actual earthquake slip.

Example: Plot slip vectors of slip on nodal plane 2, for thrust events in Greece
  tectoplot -r GR -t -kv -kt t -kl 1
--------------------------------------------------------------------------------
EOF
shift && continue
fi
 		calccmtflag=1
    plotcmtfromglobal=1
 		svflag=1
		plots+=("kinsv")
 		;;

#   -li|--line) # args: file color width
# if [[ $USAGEFLAG -eq 1 ]]; then
# cat <<-EOF
# -li:           plot one or more polyline files
# -li [filename] [[linecolor]] [[linewidth]]
#
#   Can be called multiple times to plot multiple datasets.
#   Currently does not handle complex symbologies (ornamented, CPT, etc.)
#
# Example: Plot a few lines across Romania
#   printf ">\n21 44\n26 48\n>\n22 46\n27 45\n" > ./xy.dat
#   tectoplot -r RO -t -li xy.dat red 1p
#   rm -f ./xy.dat
# --------------------------------------------------------------------------------
# EOF
# shift && continue
# fi
#       # Required arguments
#       userlinefilenumber=$(echo "$userlinefilenumber + 1" | bc -l)
#       USERLINEDATAFILE[$userlinefilenumber]=$(abs_path $2)
#       shift
#       if [[ ! -e ${USERLINEDATAFILE[$userlinefilenumber]} ]]; then
#         info_msg "[-li]: User line data file ${USERLINEDATAFILE[$userlinefilenumber]} does not exist."
#         exit 1
#       fi
#       # Optional arguments
#       # Look for symbol code
#       if arg_is_flag $2; then
#         info_msg "[-li]: No color specified. Using $USERLINECOLOR."
#         USERLINECOLOR_arr[$userlinefilenumber]=$USERLINECOLOR
#       else
#         USERLINECOLOR_arr[$userlinefilenumber]="${2}"
#         shift
#         info_msg "[-li]: User line color specified. Using ${USERLINECOLOR_arr[$userlinefilenumber]}."
#       fi
#
#       # Then look for width
#       if arg_is_flag $2; then
#         info_msg "[-li]: No width specified. Using $USERLINEWIDTH."
#         USERLINEWIDTH_arr[$userlinefilenumber]=$USERLINEWIDTH
#       else
#         USERLINEWIDTH_arr[$userlinefilenumber]="${2}"
#         shift
#         info_msg "[-li]: Line width specified. Using ${USERLINEWIDTH_arr[$userlinefilenumber]}."
#       fi
#
#       if [[ "${2}" == "fill" ]]; then
#         info_msg "[-li]: Fillling polygon"
#         USERLINEFILL_arr[$userlinefilenumber]="-Gred"
#         shift
#       else
#         USERLINEFILL_arr[$userlinefilenumber]=""
#       fi
#
#       info_msg "[-li]: LINE${userlinefilenumber}: ${USERLINEDATAFILE[$userlinefilenumber]}"
#
#       plots+=("userline")
#
#     ;;

  -legend) # args: none
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-legend:       plot a map legend above the main map area
-legend [width_in=${LEGEND_WIDTH}] [[onmap]] [[notext]]

  Plots colorbars and various map elements depending on what has been plotted on
  the map. Also printes the short data source tags of included data.
  width_in: width of color bars, requires a unit (2.5i)
  onmap: Place the legend above the map


Example: Plot a map of Kosovo with large cities and CMT, with a basic legend
   tectoplot -r XK -t -pp -ppl 100000 -c -legend -g
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    makelegendflag=1
    legendovermapflag=0

    while ! arg_is_flag "${2}"; do

      # legend by default goes into new file
      if [[ ${2} =~ "onmap" ]]; then
        shift
        legendovermapflag=1
      elif [[ ${2} =~ "notext" ]]; then
        shift
        legendnotextflag=1
      elif [[ $2 == *"i" ]]; then
        LEGEND_WIDTH="${2}"
        shift
      else
        echo "[-legend]: Argument ${2} not recognized"
        exit 1
      fi
    done
    ;;

  -litho1)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-litho1:       plot litho1 3d data on cross section
-litho1 [type]

  [type]: "density" | "Vp" | "Vs"

Example: Plot litho1 cross section across the Red Sea
   tectoplot -r 31.8 42.8 20 24 -t -aprof CW 10k 1k -litho1 density
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    litho1profileflag=1
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

    cpts+=("litho1")
    plots+=("litho1")
    ;;

  -litho1_depth)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-litho1_depth: plot a depth slice of litho1
-litho1_depth [type=${LITHO1_TYPE}] [depth=${LITHO1_DEPTH}]

  Plots a colored depth slice across LITHO1. Not really tested at all.

Example: None
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

  -megadebug)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-megadebug:    turn on set -x option in bash to see EVERYTHING
-megadebug

Example: None
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
-mob [[az=${PERSPECTIVE_AZ}]] [[inc=${PERSPECTIVE_INC}]] [[exag=${PERSPECTIVE_EXAG}]] [[res=${PERSPECTIVE_RES}]]

  Outputs: Profile PDFS are stored in ${TMP}/profiles/*.pdf

Example: Make oblique perspective cross section the Eastern Mediterranean
  tectoplot -r 21 37 23 39 -t -aprof LT 10k 1k -litho1 Vp -mob -profdepth -30 5
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    clipdemflag=1
    PLOT_SECTIONS_PROFILEFLAG=1
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

  -kprof)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-kprof:        Plot profiles using multiple XY lines extracted from a KML file
-kprof [kmlfile] [width] [resolution]


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
    info_msg "[-kprof]: No width specified. Using 100k"
    SPROFWIDTH="100k"
  else
    SPROFWIDTH="${2}"
    shift
  fi

  if arg_is_flag $2; then
    info_msg "[-aprof]: No sampling interval specified. Using 1k"
    SPROF_RES="1k"
  else
    SPROF_RES="${2}"
    shift
  fi

  kprofflag=1

  ;;

  -mprof)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-mprof:        create profiles using a speficied profile control file
-mprof [filename] [[width=${PROFILE_WIDTH_IN}]] [[height=${PROFILE_HEIGHT_IN}]] [[X=${PROFILE_X}]] [[Y=${PROFILE_Y}]]

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
  printf "S topo/dem.nc 0.001 1k 10k 1k\n" >> ./profile.control
  printf "G topo/dem.nc 0.001 1k 10k 1k cpts/topo.cpt\n" >> ./profile.control
  printf "P P_LT black 0 N 29 27.8 32.2 37.4\n" >> ./profile.control
  tectoplot -r 21 37 23 39 -t -mprof profile.control -litho1 Vp -mob -profdepth -30 5
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


-profauto)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-profauto:     allow auto adjust of profile depth but without violating min/max
-profauto [mindepth] [maxdepth]

  Depths are negative into the Earth, in km, no unit [-30] [5]

Example: None
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
-profdepth:    set default depth range for profiles (can be overridden by auto)
-profdepth [maxdepth] [mindepth]

  Depths are negative into the Earth and require a unit [-30] [5]

Example: None
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
-msd

  Kinked profiles will have large zones of no data or data overlap. This option
  uses a 'signed distance' type formulation that measures the distance to the
  closest point on the profile, and the distance along the profile of that
  closest point, to generate X-Y coordinates of swath grid data.

Example: None yet
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
-msl

  Swath profiles project data from both sides of a volume. This option will
  display only one half of the volume in a perspective diagram so that the
  projected data fall directly beneath the profile line.

Example: None yet
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
-nocleanup

  tectoplot usually deletes various intermediate files; this option keep them.

Example: None
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
-noplot

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    noplotflag=1
    ;;

	-o|--out)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-o:            specify name of output pdf
-o [filename]

  Final PDF is saved as filename.pdf

Example: None
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
-ob [[azimuth=${OBLIQUEAZ}]] [[inclination=${OBLIQUEINC}]] [[vexag=${OBLIQUE_VEXAG}]] [[floorlevel=${OBBOXLEVEL}]] [[gridlabelstring=${OBBCOMMAND}]]

  tectoplot always generates a script that can be used to plot an oblique view
  of the shaded relief (tempdir/make_oblique.sh)
  This command runs that script and adjusts its arguments.
  azimuth = direction topo is viewed from, degrees CW from north
  inclination = angle above horizon, degrees
  vexag = vertical exaggeration
  floorlevel = plot a reference level and vertical edge fences (m, negative down)
  gridlabelstring = plain | fancy

Example:
  tectoplot -r IT -t -ob 120 20 4 -20000 fancy
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    info_msg "[-ob]: Plotting oblique view of bathymetry data."
    obliqueflag=1
    OBBAXISTYPE="plain"
    if arg_is_flag $2; then
      info_msg "[-ob]: No azimuth/inc specified. Using default ${OBLIQUEAZ}/${OBLIQUEINC}."
    else
      OBLIQUEAZ="${2}"
      shift
    fi
    if arg_is_flag $2; then
      info_msg "[-ob]: Azimuth but no inclination specified. Using default ${OBLIQUEINC}."
    else
      OBLIQUEINC="${2}"
      shift
    fi
    if arg_is_float $2; then
      OBLIQUE_VEXAG="${2}"
      shift
      info_msg "[-ob]: Vertical exaggeration is ${OBLIQUE_VEXAG}."
    else
      info_msg "[-ob]: No vertical exaggeration given. Using ${OBLIQUE_VEXAG}."
    fi
    if arg_is_float $2; then
      obplotboxflag=1
      OBBOXLEVEL="${2}"
      shift
      info_msg "[-ob]: Plotting box with base level ${OBBOXLEVEL}."
    else
      info_msg "[-ob]: No floor level specified. Not plotting box."
      obplotboxflag=0
      OBBOXLEVEL=-9999
    fi
    if arg_is_flag $2; then
      info_msg "[-ob]: No grid label indicated. Not labeling."
      OBBCOMMAND=""
    else
      if [[ $2 == "plain" ]]; then
        OBBCOMMAND="-Bxaf -Byaf -Bzaf"
      elif [[ $2 == "fancy" ]]; then
        OBBCOMMAND="-Bxaf -Byaf -Bzaf"
        OBBAXISTYPE="fancy"
      fi
      shift
    fi

    ;;


    -colorinfo)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-colorinfo:       print info about GMT and colorcet CPTs, GMT color names
-colorinfo

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    echo "-------------------------------"
    echo "GMT builtin CPTs:"
    cat ${GMTCPTS} | column
    echo "-------------------------------"
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
#   -oca)
# if [[ $USAGEFLAG -eq 1 ]]; then
# cat <<-EOF
# -oca:          plot ocean crust age raster
# -oca [[transparency]] [[cpt]]
#
#   transparency is in percent
#   cpt is the filename of a CPT file to use (default is geoage)
#
# Example:
#   tectoplot -RJ S 120 20 -t 01d -oca
# --------------------------------------------------------------------------------
# EOF
# shift && continue
# fi
#     plots+=("oceanage")
#     cpts+=("geoage")
#
#     echo $OC_AGE_SOURCESTRING >> ${LONGSOURCES}
#     echo $OC_AGE_SHORT_SOURCESTRING >> ${SHORTSOURCES}
#
#     if arg_is_flag $2; then
#       info_msg "[-oc]: No transparency set. Using default $OC_TRANS"
#     else
#       OC_TRANS="${2}"
#       shift
#     fi
#     if arg_is_flag $2; then
#       info_msg "[-oc]: No ocean age CPT specified. Using $OCA_CPT"
#     else
#       if [[ -s $(abs_path ${2}) ]]; then
#         OCA_CPT="$(abs_path ${2})"
#         # cp $(abs_path ${2}) custom_oca.cpt
#         # OCA_CPT=custom_oca.cpt
#       fi
#       shift
#     fi
#     ;;

  -open)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-open:         open main PDF at end (NO LONGER USED - LEGACY OPTION)
-open

  Uses program specified in ${OPTDIR}/tectoplot.pdfviewer

Example:
  tectoplot -r IN -oca -a
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    ;;

  -noopen)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-noopen:       don't open PDF at end of processing
-noopen

Example:
  tectoplot -r g -a -noopen
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    openflag=0
    ;;

  -oto)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-oto:          specify one-to-one horizontal=vertical scaling of all profiles
-oto [[method=${OTO_METHOD}]]

  Adjusts the maximum depth of the profile to ensure 1:1 H=W ratio
  Options are
    change_h: Change the height of the profile on the page to make H=W
    change_z: Change the maximum depth of the profile to make H=W
    off:      Turn of H=W scaling

Example: None
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
    ;;

	-p|--plate) # args: string
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-p:            use plate motion model for plotting or calculations
-p [[model=${PLATEMODEL}]] [[reference plate ID=${DEFREF}]]

  Use a published plate motion model.
  Models that currently come with tectoplot are:
    MORVEL
    GSRM
    GBM

Example:
  tectoplot -r g -p MORVEL -pe -pf 1500
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
-ppole [[Pole1]] [[Pole2]]

Example: None
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

  -ppole)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ppole:           print Euler pole of specified plate relative to reference plate
-ppole [PlateID1] [[PlateID2]] ...

Examples:
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
-pc [[random]] [[transparency]]
-pc [[ID1]] [[ColorID1]] [[TransID1]] [[ID2]] ...

  Color plate polygons using two different schemes:
  random: color all plates randomly using specified transparency
  ID1... : color specified plates using specified colors and transparencies

Examples:
  tectoplot -r g -p MORVEL -pe -pf 1500 -pc random
  tectoplot -r g -p MORVEL -pe -pf 1500 -pc sa blue 50 na red 50
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
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pa:           plot plate motion vectors at grid points
-pa

  Requires -p to load a plate model
  Requires -px, -pf (evenually add -g -wg???) to create grid point locations.

Example:
  tectoplot -r g -p MORVEL -pe -pf 1500 -pa
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    plots+=("grid")
    ;;

  -ptj)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ptj:         plot plate triple junction points as stars
-ptj

  Finds triple junctions in the plate edge database and plots them as stars

Example:
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  plots+=("triplejunctions")
  ;;

  -pe|--plateedge)  # args: none
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pe:           plot plate boundary lines
-pe [[width=${PLATELINE_WIDTH}]] [[color=${PLATELINE_COLOR}]]

  Draw lines along plate boundaries.

Example:
  tectoplot -r g -p MORVEL -pe
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

  -pf|--fibsp) # args: number
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pf:           create grid of almost equally spaced points with fibonacci spiral
-pf [[distance=${FIB_KM}]] [[nolabels]]

  Grid points are located at approximately equal spacing using a Fibonacci
  spiral.

Example:
  tectoplot -r g -p MORVEL -pe -pf 1500 -pa
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
-pi [file]]

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    if arg_is_flag "${2}"; then
      info_msg "[-pi]: No file specified"
    else
      if [[ ! -s "${2}" ]]; then
        info_msg "[-pi]: File ${2} does not exist"
      else
        PI_GRIDFILE=$(abs_path "${2}")
        shift

        if [[ ${PI_GRIDFILE} == *".kml" ]]; then
          # echo "KML input file"
          kml_to_points ${PI_GRIDFILE} kml_points.xy
          PI_GRIDFILE=$(abs_path kml_points.xy)
        fi

        makegridflag_gridfile=1
        makegridflag=1
      fi
    fi

    ;;

  -ppf)
    plots+=("gridpoints")
    ;;

  -pg) # args: file
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pg:           use polygon file to select data
-pg [ filename | GMTcode | fe ] [[show]]

  Select seismicity data within polygon.
  Polygon file is either XY format or is the first feature in a KML file
  GMTcode is any GMT region code consistent with pscoast -E{code} -M, e.g. US.MT
  fe: use the Flinn-Engdahl polygons specified by -feg or -fes
  show: plot the polygon boundary

Example:
  printf "23 37\n23 40\n27 40\n27 38\n" > ./poly.xy
  tectoplot -r GR -a -pg ./poly.xy show -z
  rm -f ./poly.xy
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
          info_msg "[-pg]: Using Flinn-Engdahl polygons from -feg or -fes"
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

    # Now we have to fix the polygon file in case polygons cross the dateline.
    # [[ -s ${POLYGONAOI} ]] && fixselectpolygonsflag=1

    ;; # args: none

  -noframe)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-noframe:      do not plot coordinate grid or map frame
-noframe [[top]] [[left]] [[bottom]] [[right]]

  If no options are given, do not label the border at all.
  If options are given, label all borders EXCEPT those listed.

Example:
  tectoplot -r GR -a -noframe
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

  -pgo)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pgo:          plot gridlines
-pgo

  Plot parallel and meridian gridlines (overridden by -noframe).

Example:
  tectoplot -r GR -a -pgo
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    GRIDLINESON=1
    ;;

  -pgs) # args: number
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pgs:          override automatic axis interals and gridline spacing
-pgs [degree]

  Use -pgo to plot gridlines.

Example:
  tectoplot -r GR -a -pgo -pgs 0.3
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    overridegridlinespacing=1
    OVERRIDEGRID="${2}"
    shift
    ;;

  -pl) # args: none
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pl:           label plates with their id code
-pl

  Use -p to set plate model.

Example:
  tectoplot -r =EU -p -pe -pl
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    plots+=("platelabel")
    ;;

#   -pp|--cities)
# if [[ $USAGEFLAG -eq 1 ]]; then
# cat <<-EOF
# -pp:           plot populated places above a specified population
# -pp [[population=${CITIES_MINPOP}]]
#
#   Source data is from Geonames.
#   Label populated places using -ppl
#
# Example:
#   tectoplot -r =EU -a -pp 500000
# --------------------------------------------------------------------------------
# EOF
# shift && continue
# fi
#     if arg_is_flag $2; then
#       info_msg "[-pp]: No minimum population specified. Using ${CITIES_MINPOP}"
#     else
#       CITIES_MINPOP="${2}"
#       shift
#     fi
#     if ! arg_is_flag $2; then
#       CITIES_CPT="${2}"
#       shift
#     fi
#
#     plots+=("cities")
#     cpts+=("population")
#     echo $CITIES_SHORT_SOURCESTRING >> ${SHORTSOURCES}
#     echo $CITIES_SOURCESTRING >> ${LONGSOURCES}
#     ;;
#
#   -ppl)
# if [[ $USAGEFLAG -eq 1 ]]; then
# cat <<-EOF
# -ppl:          label populated places above a specified population
# -ppl [[population=${CITIES_LABEL_MINPOP}]]
#
#   Use -pp to plot cities.
#   Source data is from Geonames
#
# Example:
#   tectoplot -r =EU -pp 500000 -ppl 500000
# --------------------------------------------------------------------------------
# EOF
# shift && continue
# fi
#     if arg_is_flag $2; then
#       info_msg "[-pp]: No minimum population for labeling specified. Using ${CITIES_LABEL_MINPOP}"
#     else
#       CITIES_LABEL_MINPOP="${2}"
#       shift
#     fi
#     citieslabelflag=1
#     ;;

  -pos)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pos:          shift origin of plot before plotting
-pos [xshift=${PLOTSHIFTX}] [yshift=${PLOTSHIFTY}]

  shift amount includes unit (e.g. 3i for 3 inches)
  This command is mostly used with -ips when plotting onto an open EPS file.
  Normally, the map is plotted on a very large canvas and then cropped

Example: None
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

  -plist)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-plist:        print rotation poles relative to reference frame
-plist

Example:
  tectoplot -p MORVEL WL -plist
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  plistflag=1
  ;;

  -pr) # args: number
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pr:           plot plate rotation small circles with arrows
-pr [[latstep=${LATSTEPS}]]

  Note: This routine is kind of broken for some reason? Some plates do not
  produce small circles from gmt project....

  visualizes plate motions via small circles centered on the pole of rotation.
  The spacing between small circles is given as a colatitude step in degrees.

Example:
  tectoplot -r PA -p MORVEL -t -pr
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
-prv

  Plots points at plate boundary segment midpoints colored by local plate-plate
  velocity. This is the predicted plate boundary fault full slip rate.

  Maybe should be modified to plot the plate boundary lines themselves?

Example:
  tectoplot -r ID -p -prv -a
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    plots+=("platerelvel")
    doplateedgesflag=1
    ;;

  -ps)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ps:           print list of plates in selected plate model, then exit
-ps

  Prints plates from the selected model and plates within the AOI, then exits.

Example:
  tectoplot -r ID -p MORVEL -ps
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    outputplatesflag=1
    ;;

  -psel)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-psel:         specify profiles to plot (must be in profile command file)
-psel PROF_1 PROF_3 ...

  Prints plates from the selected model and plates within the AOI, then exits.

Example: None
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

  # This is a high priority argument that is processed in the previous loop.
  # This command remains for -usage
  -pss) # args: string
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pss:          specify width of map (inches)
-pss 4

  Adjusts map frame width. This affects -gres and also the relative size of
  symbols vs plotted grid data.

Example:
  tectoplot -r TW -a -pss 3 -pgs 1
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    shift
    ;;

#   -pt|--point)
# if [[ $USAGEFLAG -eq 1 ]]; then
# cat <<-EOF
# -pt:           plot point dataset with specified size, fill, cpt
# -pt [filename] [[symbol=${POINT_SYMBOL}]] [[size=${POINTSIZE}]] [[@ color]]
# -pt [filename] [[symbol=${POINT_SYMBOL}]] [[size=${POINTSIZE}]] [[cpt_filename]]
#
#   symbol is a GMT psxy -S code:
#     +(plus), st(a)r, (b|B)ar, (c)ircle, (d)iamond, (e)llipse,
#  	  (f)ront, octa(g)on, (h)exagon, (i)nvtriangle, (j)rotated rectangle,
#  	  pe(n)tagon, (p)oint, (r)ectangle, (R)ounded rectangle, (s)quare,
#     (t)riangle, (x)cross, (y)dash,
#
#   Multiple calls to -pt can be made; they will plot in map layer order.
#
# Example: None
# --------------------------------------------------------------------------------
# EOF
# shift && continue
# fi
#     # COUNTER userpointfilenumber
#     # Required arguments
#     userpointfilenumber=$(echo "$userpointfilenumber + 1" | bc -l)
#     POINTDATAFILE[$userpointfilenumber]=$(abs_path $2)
#     shift
#     if [[ ! -e ${POINTDATAFILE[$userpointfilenumber]} ]]; then
#       info_msg "[-pt]: Point data file ${POINTDATAFILE[$userpointfilenumber]} does not exist."
#       exit 1
#     fi
#     # Optional arguments
#     # Look for symbol code
#     if arg_is_flag $2; then
#       info_msg "[-pt]: No symbol specified. Using $POINTSYMBOL."
#       POINTSYMBOL_arr[$userpointfilenumber]=$POINTSYMBOL
#     else
#       POINTSYMBOL_arr[$userpointfilenumber]="${2:0:1}"
#       shift
#       info_msg "[-pt]: Point symbol specified. Using ${POINTSYMBOL_arr[$userpointfilenumber]}."
#     fi
#
#     # Then look for size
#     if arg_is_flag $2; then
#       info_msg "[-pt]: No size specified. Using $POINTSIZE."
#       POINTSIZE_arr[$userpointfilenumber]=$POINTSIZE
#     else
#       POINTSIZE_arr[$userpointfilenumber]="${2}"
#       shift
#       info_msg "[-pt]: Point size specified. Using ${POINTSIZE_arr[$userpointfilenumber]}."
#     fi
#
#     # Finally, look for CPT file
#     if arg_is_flag $2; then
#       info_msg "[-pt]: No cpt specified. Using ${POINTCOLOR} fill for -G"
#       pointdatafillflag[$userpointfilenumber]=1
#       pointdatacptflag[$userpointfilenumber]=0
#     elif [[ ${2:0:1} == "@" ]]; then
#       shift
#       POINTCOLOR=${2}
#       info_msg "[-pt]: No cpt specified using @. Using POINTCOLOR for -G"
#       shift
#       pointdatafillflag[$userpointfilenumber]=1
#       pointdatacptflag[$userpointfilenumber]=0
#     else
#       POINTDATACPT[$userpointfilenumber]=$(abs_path $2)
#       shift
#       if [[ ! -e ${POINTDATACPT[$userpointfilenumber]} ]]; then
#         info_msg "[-pt]: CPT file $POINTDATACPT does not exist. Using default $POINTCPT"
#         POINTDATACPT[$userpointfilenumber]=$(abs_path $POINTCPT)
#       else
#         info_msg "[-pt]: Using CPT file $POINTDATACPT"
#       fi
#       pointdatacptflag[$userpointfilenumber]=1
#       pointdatafillflag[$userpointfilenumber]=0
#     fi
#
#     info_msg "[-pt]: PT${userpointfilenumber}: ${POINTDATAFILE[$userpointfilenumber]}"
#     plots+=("points")
#     ;;

  -pvl)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pvl:           plot plate edges colored by (convergent, divergent, transform)
-pvl

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  doplateedgesflag=1
  plots+=("plateedgecolor")

  ;;

  -pv) # args: none
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pv:           plot plate differential velocity vectors
-pv [[cutoff=${PDIFFCUTOFF}]]

  Plot arrows across plate boundaries indicating direction and sense of relative
  motion. Divergent arrows at divergent boundaries, convergent arrows etc., and
  offset wedges indicating dextral or sinistral slip.

  Cutoff value is the distance in degrees separating plotted velocity elements.
  This is because some plate boundaries are very high resolution producing way
  too many arrows.

Example:
  tectoplot -r SB -a -p -pe -pv 1
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

  -pvg)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pvg:          plot plate velocity as a colored grid
-pvg [[resolution=${PLATEVELRES}]] [[rescale]]

  Plot colored plate velocity grid calculated at the specified resolution.
  rescale: rescale the CPT so that plate velocities in the AOI span the range.

Example: Plot colored plate velocity in MORVEL NNR around South America
  tectoplot -r =SA -a -p -pvg -pe
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    platevelgridflag=1
    plots+=("platevelgrid")
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
      info_msg "[-pvg]: Rescaling gravity CPT to AOI"
      shift
    else
      info_msg "[-pvg]: Unrecognized option ${2}"
      shift
    fi
    ;;

  -px|--gridsp) # args: number
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-px:           generate lat/lon grid
-px [interval=${GRIDSTEP}]

  Grid points are at regularly spaced geographic coordinates.

Example: Plot plate velocity vectors in MORVEL NNR around South America
  tectoplot -r =SA -a -p -pa -px 1 -pe
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

  -pz) # args: number
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-pz:           plot the angle between plate velocity and plate edge direction
-pz [scale=${AZDIFFSCALE}]

  Plot the obliquity of plate motion relative to the plate boundary.
  scale=  size of dots
  Standard colors:
  green=  right lateral
  yellow= left lateral
  red=    divergent
  blue=   convergent

Example: Plot plate velocity vectors and -pz in MORVEL NNR around South America
  tectoplot -r =SA -a -p -px 1 -pe -pz
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

	-r|--range) # args: number number number number

if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-r:            specify the area of interest of the map

Option 1: Use GMT region ID codes to specify the region
-r [GMT RegionID]    e.g.   -r ID  OR  -r =NA,SA  OR  -r IT+R5  etc.

Option 2: Use a saved custom region (-radd, -rdelete, -rlist)
-r [CustomRegionID]  e.g.   -r BaliLombok_1

Option 3: Use a rectangular region. All arguments are decimal degrees.
-r [MinLon] [MaxLon] [MinLat] [MaxLat]

Option 4: Use the extent of an existing XY file (lon lat format) or grid file
-r [filename] [[degree_buffer]]

Option 5: Rectangular area centered on a catalog earthquake. -z is required.
-r eq [EarthquakeID] [[mapwidth=${EQ_REGION_WIDTH}]]

Option 6: Rectangular area centered on lat/lon coordinate in flexible format.
          Formats are flexible (e.g. 2°8'12.134' or 2d 8m 12.11s et.)
-r latlon [lat] [lon] [[mapwidth]]

Option 7: Same as option 6 but lonlat format.
-r lonlon [lon] [lat] [[mapwidth]]

Option 8: Flinn-Engdahl geographic or seismic region code
-r feg IDnum(1-757)
-r fes IDnum(1-50)

Example: Plot coastlines of Great Britain
  tectoplot -r GB -a
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
          cat ${FE_REGION_POLY}"flinn_engdahl_${FE_REGION_ID}.txt" >> ${TMP}fe_region.txt
        done

        FE_RANGE=($(xy_range ${TMP}fe_region.txt))
        MINLON=$(echo "${FE_RANGE[0]} ${FE_RANGE[1]}" | gawk '{ if ($2-$1 > 358) { print $1 } else { print $1-1 } }')
        MAXLON=$(echo "${FE_RANGE[0]} ${FE_RANGE[1]}" | gawk '{ if ($2-$1 > 358) { print $2 } else { print $2+1 } }')
        MINLAT=$(echo "${FE_RANGE[2]}" | gawk '{print ($1-1>-90)?$1-1:-90}')
        MAXLAT=$(echo "${FE_RANGE[3]}" | gawk '{print ($1+1<90)?$1+1:90}')

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
          cat ${FE_SEISMIC_POLY}"flinn_engdahl_combined_${FE_REGION_ID}.txt" >> ${TMP}fe_region.txt
        done

        FE_RANGE=($(xy_range ${TMP}fe_region.txt))
        MINLON=$(echo "${FE_RANGE[0]} ${FE_RANGE[1]}" | gawk '{ if ($2-$1 > 358) { print $1 } else { print $1-1 } }')
        MAXLON=$(echo "${FE_RANGE[0]} ${FE_RANGE[1]}" | gawk '{ if ($2-$1 > 358) { print $2 } else { print $2+1 } }')
        MINLAT=$(echo "${FE_RANGE[2]}" | gawk '{print ($1-1>-90)?$1-1:-90}')
        MAXLAT=$(echo "${FE_RANGE[3]}" | gawk '{print ($1+1<90)?$1+1:90}')

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
      elif [[ -e "${2}" ]]; then
        info_msg "[-r]: File specified; trying to determine extent."

        if [[ $2 == *".kml" ]]; then
          kml_to_first_xy ${2} profile_align.xy
          XYRANGE=($(xy_range profile_align.xy))
          MINLON=${XYRANGE[0]}
          MAXLON=${XYRANGE[1]}
          MINLAT=${XYRANGE[2]}
          MAXLAT=${XYRANGE[3]}
          shift
        else
          # First check if it is a text file with X Y coordinates in the first two columns
          case $(file "${2}") in
            (*\ text|*\ text\ *)
                info_msg "[-r]: Input file is text: assuming X Y data"

                # Could add different file formats here, KML etc.
                XYRANGE=($(xy_range "${2}"))
                MINLON=${XYRANGE[0]}
                MAXLON=${XYRANGE[1]}
                MINLAT=${XYRANGE[2]}
                MAXLAT=${XYRANGE[3]}
                ;;
            (*\ directory|*\ directory\ *)
                info_msg "[-r]: Input file is an existing directory. Not a valid extent."
                exit 1
                ;;
            (*)
                info_msg "[-r]: Input file is binary: assuming it is a grid file"
                rasrange=$(gmt grdinfo $(abs_path $2) -C -Vn)
                MINLON=$(echo $rasrange | gawk  '{print $2}')
                MAXLON=$(echo $rasrange | gawk  '{print $3}')
                MINLAT=$(echo $rasrange | gawk  '{print $4}')
                MAXLAT=$(echo $rasrange | gawk  '{print $5}')
                ;;
            esac
          shift
        fi

        if arg_is_positive_float "${2}"; then
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


          RCOUNTRYTL=($(gmt mapproject -R${COUNTRYID} -WjTL -WjTL ${VERBOSE}))
          if [[ $? -ne 0 ]]; then
            echo "${COUNTRYID} is not a valid region" > /dev/stderr
            exit 1
          fi

          RCOUNTRYBR=($(gmt mapproject -R${COUNTRYID} -WjTL -WjBR ${VERBOSE}))
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

              # Check the custom region strings for projections that require a different bounding box method
              if [[ ${ISCUSTOMREGION[${ind}]} == *"-JOc"* ]]; then
                # echo "Found Oblique Mercator"
                boundboxfrompsbasemapflag=1
              fi

            done
            if [[ $usecustomregionrjstringflag -eq 1 ]]; then
              info_msg "[-r]: customID ${2} has RJSTRING: ${CUSTOMREGIONRJSTRING[@]}"
            else
              info_msg "[-r]: customID ${2} has no RJSTRING"
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

  -radd)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-radd:         add a custom region definition using final aoi/projection of map
-radd [CustomRegionID]

  Custom regions save the final inferred AOI (GMT -R) and projection (GMT -J)
  including map size (e.g. 7i), associated with a single word ID key.
  The custom regions file has the format:
  RegionID MinLon MaxLon MinLat MaxLat -R... -J...

Example: Plot coastlines of South America and add as custom region
  tectoplot -r =SA -radd SouthAmerica -a
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

  -rdel)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-rdel:         delete a custom region definition
-rdel [CustomRegionID]

  Delete a custom region ID and then exit.

Example: Delete SouthAmerica region ID created by -radd SouthAmerica
  tectoplot -rdel SouthAmerica
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

  -rlist)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-rlist:        list custom region definitions and exit
-rlist

Example: List custom regions.
  tectoplot -rlist
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    cat ${CUSTOMREGIONS}
    exit
    ;;

  -rect)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-rect:         make rectangular map for non-rectangular projections
-rect

  Confirmed to work with the following map projections:
    UTM
    Albers|B
    Lambert|L
    Equid|D

Example: Make a rectangular map of a high latitude region with a UTM projection
   tectoplot -r -160 -150 54 60 -a -RJ UTM -rect
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    MAKERECTMAP=1
    ;;

  -reportdates)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-reportdates:  print range of scraped seismic/focal mechanism data, then exit
-reportdates

Example:
   tectoplot -reportdates
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    echo -n "Focal mechanisms: "
    echo "$(head -n 1 $FOCALCATALOG | cut -d ' ' -f 3) to $(tail -n 1 $FOCALCATALOG | cut -d ' ' -f 3)"
    # echo -n "Earthquake hypocenters: "
    # echo "$(head -n 1 $EQCATALOG | cut -d ' ' -f 5) to $(tail -n 1 $EQCATALOG | cut -d ' ' -f 5)"
    exit
    ;;

#   -rivers)
# if [[ $USAGEFLAG -eq 1 ]]; then
# cat <<-EOF
# -rivers:       plot rivers if -a command is called
# -rivers
#
# Example:
#    tectoplot -r BR -a -rivers
# --------------------------------------------------------------------------------
# EOF
# shift && continue
# fi
#     RIVER_COMMAND="-I1/${RIVER_LINEWIDTH},${RIVER_LINECOLOR} -I2/${RIVER_LINEWIDTH},${RIVER_LINECOLOR}"
#     ;;

  -RJ) # args: { ... }

if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-RJ:           set map projection
-RJ

Set UTM projection for AOI given by -r:
-RJ UTM [[utmzone]]
    If utmzone is not specified, it will be determined automatically from the
    central longitude inferred from -r

Set global extent [-180:180;-90:90] with central longitude [central_meridian]
-RJ [projection] [[central_meridian]]
    Hammer|H
    Winkel|R
    Robinson|N
    Mollweide|W
    VanderGrinten|V
    Sinusoidal|I
    Eckert4|Kf
    Eckert6|Ks

Hemisphere:
-RJ Hemisphere or A [[central_meridian]] [[central_latitude]]

Circular plots with a specified horizon distance from center point:
-RJ [projection] [[central_meridian]] [[central_latitude]] [[degree_horizon]]
    Gnomonic|F
    Orthographic|G
    Stereo|S

Oblique Mercator: specified by center point, azimuth, width and height
-RJ ObMercA or OA [central_lon] [central_lat] [azimuth] [width_km] [height_km]

Oblique Mercator: specified by a center point, pole location, width, height
-RJ ObMercC or OC [central_lon] [central_lat] [pole_lon] [pole_lat] [width_km] [height_km]

Projections with standard parallels:
-RJ [projection] [[central_lon] [central_lat] [parallel_1] [parallel_2]]
    Albers|B
    Lambert|L
    Equid|D

    If no parameters are given for these -RJ B|L|D, the standard parallels
    are taken to be the maximum and minimum latitudes from -r.

Examples:
   tectoplot -r BR -RJ UTM -a
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    # We need to shift the automatic UTM zone section to AFTER other arguments are processed

    ARG1="${2}"
    shift

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

      UTM)
        if [[ $2 =~ ^[0-9]+$ ]]; then   # Specified a UTM Zone (positive integer)
          UTMZONE=$2
          shift
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
        rj+=("-Rg")
        case $ARG1 in
          Eckert4|Kf)      rj+=("-JKf${CENTRALMERIDIAN}/${PSSIZE}i")    ;;
          Eckert6|Ks)      rj+=("-JKs${CENTRALMERIDIAN}/${PSSIZE}i")    ;;
          Hammer|H)        rj+=("-JH${CENTRALMERIDIAN}/${PSSIZE}i")     ;;
          Mollweide|W)     rj+=("-JW${CENTRALMERIDIAN}/${PSSIZE}i")     ;;
          Robinson|N)      rj+=("-JN${CENTRALMERIDIAN}/${PSSIZE}i")     ;;
          Sinusoidal|I)    rj+=("-JI${CENTRALMERIDIAN}/${PSSIZE}i")     ;;
          VanderGrinten|V) rj+=("-JV${CENTRALMERIDIAN}/${PSSIZE}i")     ;;
          Winkel|R)        rj+=("-JR${CENTRALMERIDIAN}/${PSSIZE}i")     ;;
        esac
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
        rj+=("-Rg")
        case $ARG1 in
          Hemisphere|A) rj+=("-JA${CENTRALMERIDIAN}/${CENTRALLATITUDE}/${PSSIZE}i")   ;;
        esac
        RJSTRING="${rj[@]}"
        recalcregionflag_lonlat=0
      ;;
      Gnomonic|Fg|F|Orthographic|Gg|G|Stereo|Sg|S)
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
        rj+=("-Rg")
        case $ARG1 in
          Gnomonic|Fg|F)      [[ $DEGRANGE -ge 90 ]] && DEGRANGE=60   # Gnomonic can't have default degree range
                           rj+=("-JF${CENTRALMERIDIAN}/${CENTRALLATITUDE}/${DEGRANGE}/${PSSIZE}i")     ;;
          Orthographic|Gg|G)  rj+=("-JG${CENTRALMERIDIAN}/${CENTRALLATITUDE}/${DEGRANGE}/${PSSIZE}i")     ;;
          Stereo|Sg|S)        rj+=("-JS${CENTRALMERIDIAN}/${CENTRALLATITUDE}/${DEGRANGE}/${PSSIZE}i")     ;;
        esac
        RJSTRING="${rj[@]}"

        if [[ ${ARG1:1:2} == "g" ]]; then
          info_msg "[-RJ]: using global circle map ($ARG1)"
        else
          info_msg "[-RJ]: will recalculate data region using lonlat"
          recalcregionflag_lonlat=1
        fi
      ;;
      # Oblique Mercator A (lon lat azimuth widthkm heightkm)
      ObMercA|OA)
        # Set up default values
        CENTRALLON=0
        CENTRALLAT=0
        ORIENTAZIMUTH=0
        MAPWIDTHKM="200k"
        MAPHEIGHTKM="100k"
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
              if [[ $2 =~ ^[-+]?[0-9]*.*[0-9]+[k]$ ]]; then   # Specified a width with unit k
                MAPWIDTHKM=$(echo $2 | gawk '{print ($1+0)/2 "k"}')
                shift
                if [[ $2 =~ ^[-+]?[0-9]*.*[0-9]+[k]$ ]]; then   # Specified a width with unit k
                  MAPHEIGHTKM=$(echo $2 | gawk '{print ($1+0)/2 "k"}')
                  shift
                fi
              fi
            fi
          fi
        fi

        rj+=("-Rk-${MAPWIDTHKM}/${MAPWIDTHKM}/-${MAPHEIGHTKM}/${MAPHEIGHTKM}")
        rj+=("-JOa${CENTRALLON}/${CENTRALLAT}/${ORIENTAZIMUTH}/${PSSIZE}i")
        RJSTRING="${rj[@]}"
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
        MAPWIDTHKM="200k"
        MAPHEIGHTKM="100k"
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
                if [[ $2 =~ ^[-+]?[0-9]*.*[0-9]+[k]$ ]]; then   # Specified a width with unit k
                  MAPWIDTHKM=$2
                  shift
                  if [[ $2 =~ ^[-+]?[0-9]*.*[0-9]+[k]$ ]]; then   # Specified a width with unit k
                    MAPHEIGHTKM=$2
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

        MAPWIDTHNUM=$(echo $MAPWIDTHKM | gawk -v circ=${SMALLC_CIRC} '{print ($1+0)*38921.6/circ }')
        MAPHEIGHTNUM=$(echo $MAPHEIGHTKM | gawk -v circ=${SMALLC_CIRC} '{print ($1+0)*38921.6/circ }')

        # rj+=("-Rk-${MAPWIDTHKM}/${MAPWIDTHKM}/-${MAPHEIGHTKM}/${MAPHEIGHTKM}")
        rj+=("-Rk-${MAPWIDTHNUM}k/${MAPWIDTHNUM}k/-${MAPHEIGHTNUM}k/${MAPHEIGHTNUM}k")
        rj+=("-JOc${CENTRALLON}/${CENTRALLAT}/${POLELON}/$POLELAT/${PSSIZE}i")
        RJSTRING="${rj[@]}"
        recalcregionflag_bounds=1
        projcoordsflag=1
      ;;
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

        rj+=("-R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}")

        case $ARG1 in
          Albers|B)      rj+=("-JB${CENTRALLON}/${CENTRALLAT}/${STANDARD_PARALLEL_1}/${STANDARD_PARALLEL_2}/${PSSIZE}i")    ;;
          Lambert|L)     rj+=("-JL${CENTRALLON}/${CENTRALLAT}/${STANDARD_PARALLEL_1}/${STANDARD_PARALLEL_2}/${PSSIZE}i")    ;;
          Equid|D)       rj+=("-JD${CENTRALLON}/${CENTRALLAT}/${STANDARD_PARALLEL_1}/${STANDARD_PARALLEL_2}/${PSSIZE}i")    ;;
        esac

        RJSTRING="${rj[@]}"
        # echo ${RJSTRING[@]}
        recalcregionflag_lonlat=1
        projcoordsflag=1
      ;;
      *)
        echo "[-RJ]: projection ${ARG1} not recognized."
        exit 1
      ;;
    esac

    usecustomrjflag=1

    # Need to calculate the AOI using the RJSTRING. Otherwise, have to specify a
    # region manually using -r which may not be so obvious.

    # How?
    ;;

  -setdatadir)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-setdatadir:   set location of downloaded data directory
-setdatadir [directory_path]

  The path to the data directory is stored in the tectoplot.dataroot file

Example:
  tectoplot -setdatadir /Users/kylebradley/Dropbox/TectoplotData/
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

  -setopen)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-setopen:      set the program that is used to open pdf files
-setopen [application]

  The path to the open program is stored in the ${OPTDIR}tectoplot.pdfviewer file

Example:
  tectoplot -setopen Preview
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



  -scale)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-scale:        plot a scale bar
-scale [length] [[lon]] [[lat]] [[white]]
-scale [length] [[aprofcode]] [[white]]

  length has unit (e.g. 100k)
  scale bar is centered on the reference point
  aprofcode is an uppercase letter map location ID (plot using -aprofcodes)

Example:
  tectoplot -r US.CO -t -scale 200k C
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    # We just use this section to create the SCALECMD values

    if arg_is_flag $2; then
      info_msg "[-scale]: No scale length specified. Using 100km"
      SCALELEN="100k"
    else
      SCALELEN="${2}"
      shift
    fi
    # Adjust position and buffering of scale bar using either letter combinations OR Lat/Lon location

    if arg_is_float $2; then
      SCALEREFLON="${2}"
      shift
      if arg_is_float $2; then
        SCALEREFLAT="${2}"
        SCALELENLAT="${2}"
        shift
      else
        info_msg "[-scale]: Only longitude and not latitude specified. Using $MAXLAT"
        SCALEREFLAT=$MINLAT
        SCALELENLAT=$MINLAT
      fi
    fi

    if [[ "${2}" =~ [A-Z] ]]; then  # This is an aprofcode location
      info_msg "[-scale]: aprofcode ${2:0:1} found."
      SCALEAPROF=($(echo $2 | gawk -v minlon=$MINLON -v maxlon=$MAXLON -v minlat=$MINLAT -v maxlat=$MAXLAT '
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
              # print char, lons[char], lats[char]
            }
          }
      }
      {
        for(i=1;i<=length($0);++i) {
          char1=toupper(substr($0,i,1));
          print lons[char1], lats[char1]
        }
      }'))
      SCALEREFLON=${SCALEAPROF[0]}
      SCALEREFLAT=${SCALEAPROF[1]}
      SCALELENLAT=${SCALEAPROF[1]}
      shift
    fi

    if [[ $2 =~ "white" ]]; then
      SCALEFILL="-F+gwhite"
      shift
    else
      SCALEFILL=""
    fi

    plots+=("mapscale")
    ;;

  -north)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-north:        plot a north arrow
-north [size] [[lon]] [[lat]]
-north [size] [[aprofcode]]

  arrow is centered on the reference point
  aprofcode is an uppercase letter map location ID (plot using -aprofcodes)

Example:
  tectoplot -r US.CO -t -north 1i C
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    # We just use this section to create the SCALECMD values

    if arg_is_flag $2; then
      info_msg "[-north]: No north arrow size specified. Using 0.5i"
      ARROWSIZE="0.5i"
    else
      ARROWSIZE="${2}"
      shift
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
    fi

    if [[ "${2}" =~ [A-Z] ]]; then  # This is an aprofcode location
      info_msg "[-north]: aprofcode ${2:0:1} found."
      NORTHARROWAPROFCODE="${2}"
      shift
      northarrowaprofflag=1
    fi
    #   ARROWAPROF=($(echo $2 | gawk -v minlon=$MINLON -v maxlon=$MAXLON -v minlat=$MINLAT -v maxlat=$MAXLAT '
    #   BEGIN {
    #       row[1]="AFKPU"
    #       row[2]="BGLQV"
    #       row[3]="CHMRW"
    #       row[4]="DINSX"
    #       row[5]="EJOTY"
    #       difflat=maxlat-minlat
    #       difflon=maxlon-minlon
    #
    #       newdifflon=difflon*8/10
    #       newminlon=minlon+difflon*1/10
    #       newmaxlon=maxlon-difflon*1/10
    #
    #       newdifflat=difflat*8/10
    #       newminlat=minlat+difflat*1/10
    #       newmaxlat=maxlat-difflat*1/10
    #
    #       minlon=newminlon
    #       maxlon=newmaxlon
    #       minlat=newminlat
    #       maxlat=newmaxlat
    #       difflat=newdifflat
    #       difflon=newdifflon
    #
    #       for(i=1;i<=5;i++) {
    #         for(j=1; j<=5; j++) {
    #           char=toupper(substr(row[i],j,1))
    #           lats[char]=minlat+(i-1)/4*difflat
    #           lons[char]=minlon+(j-1)/4*difflon
    #           # print char, lons[char], lats[char]
    #         }
    #       }
    #   }
    #   {
    #     for(i=1;i<=length($0);++i) {
    #       char1=toupper(substr($0,i,1));
    #       print lons[char1], lats[char1]
    #     }
    #   }'))
    #   ARROWREFLON=${ARROWAPROF[0]}
    #   ARROWREFLAT=${ARROWAPROF[1]}
    #   ARROWLENLAT=${ARROWAPROF[1]}
    #   shift
    # fi

    if [[ $2 =~ "white" ]]; then
      ARROWFILL="-F+gwhite"
      shift
    else
      ARROWFILL=""
    fi

    plots+=("northarrow")
    ;;


  -scrapedata) # args: none | gia
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-scrapedata:   download and manage online seismic data
-scrapedata [[controlstring]]

  letters in controlstring determine what gets scraped/updated:
  g = GCMT focal mechanisms
  i = ISC focal mechanisms
  z = GFZ focal mechanisms
  m = merge focal mechanism catalogs to avoid duplications
  a = ANSS (Comcat) seismicity
  c = ISC seismicity catalog
  e = ISC-EHB seismicity catalog

  Focal mechanism catalog merging is done by priority of source institution

Example:
  tectoplot -r US.CO -t -scale 200k C
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if arg_is_flag $2; then
      info_msg "[-scrapedata]: No datasets specified. Scraping all catalogs."
      SCRAPESTRING="gizmace"
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
      source $SCRAPE_ISCFOC ${ISCDIR}
    fi
    if [[ ${SCRAPESTRING} =~ .*a.* ]]; then
      info_msg "Scraping ANSS seismic data"
      source $SCRAPE_ANSS ${ANSSDIR} ${REBUILD}
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
      info_msg "Merging focal catalogs"
      source $MERGECATS
    fi
    exit
    ;;

  -seissum)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-seissum:      compute a moment magnitude seismic release map
-seissum [[resolution=${SSRESC}]] [[transparency]] [[uniform]]

  Sums the moment magnitude of catalog seismicity per grid cell.
  Usually used with -znoplot to suppress plotting of the seismicity data

  resolution is in the form Xd (e.g. 0.1d)

  uniform:  sum earthquake counts and not magnitudes


Example:
  tectoplot -r US.CO -t -scale 200k C
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

  -setvars) # args: { VAR1 val1 VAR2 val2 VAR3 val3 }
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-setvars:      set a tectoplot variable
-setvars { Var1 Val1 Var2 Val2 ... }

  Sums the moment magnitude of catalog seismicity per grid cell.
  Usually used with -znoplot to suppress plotting of the seismicity data

Example:
  tectoplot -r US.CO -t -scale 200k C
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

  -showprof)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-showprof:     plot a selected profile or stacked profile on map PS file
-showprof [all | ID]

  Places a profile EPS file below the map.

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  if [[ $2 =~ "all" ]]; then
    SHOWPROFLIST+=(0)
    shift
  fi
  while arg_is_positive_float $2; do
    SHOWPROFLIST+=(${2})
    shift
  done

  info_msg "Profiles to plot on map: ${SHOWPROFLIST[@]}"

  plotprofileonmapflag=1

  ;;

  -profileaxes)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-profileaxes:  set label strings for profile X, Y, Z axes
-profileaxes [x=\"${PROFILE_X_LABEL}\"] [[y=\"${PROFILE_Y_LABEL}\"]] [[z=\"${PROFILE_Z_LABEL}\"]]

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  if ! arg_is_flag $2; then
    PROFILE_X_LABEL="$2"
    shift
  fi
  if ! arg_is_flag $2; then
    PROFILE_Y_LABEL="$2"
    shift
  fi
  if ! arg_is_flag $2; then
    PROFILE_Z_LABEL="$2"
    shift
  fi
  PROFILE_CUSTOMAXES_FLAG=1
  ;;

  -tomoslice)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tomoslice:    Plot depth slice of Submachine tomography data
-tomoslice [file]


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

  -tomo)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tomo:         Load Submachine tomography profile data
-tomo [file1] [[file2]] ...

  Notes: Data file needs to already have been downloaded from Submachine
         Data file has format X Y Z V
         Data will be added to -sprof, -aprof, etc profiles where close to lines


--------------------------------------------------------------------------------
EOF
shift && continue
fi

  # Check if a file exists, if so, translate it to lon lat depth V
  while [[ -s $2 ]]; do

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

    shift
  done

  if [[ -s ${TMP}tomography.txt ]]; then
    tomographyflag=1
    cpts+=("tomography")
  fi




  ;;

  -sprof) # args lon1 lat1 lon2 lat2 width res
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-sprof:        create an automatic profile between two geographic points
-sprof [lon1] [lat1] [lon2] [lat2] [width] [resolution]

  width is the full profile width
  resolution is the along-profile sample spacing
  width and resolution is specified with a unit (e.g. 100k)

  This option can be called multiple times to add several profiles.
  The width and resolution must be specified for each profile

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    # Create a single profile across by constructing a new mprof) file with relevant data types
    # Needs some argument checking logic as too few arguments will mess things up spectacularly
    sprofflag=1
    ((sprofnumber++))
    SPROFLON1[${sprofnumber}]="${2}"
    SPROFLAT1[${sprofnumber}]="${3}"
    SPROFLON2[${sprofnumber}]="${4}"
    SPROFLAT2[${sprofnumber}]="${5}"
    SPROFWIDTH="${6}"
    SPROF_RES="${7}"
    shift
    shift
    shift
    shift
    shift
    shift
    clipdemflag=1
    ;;

  -sun)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-sun:          set the solar position (declination, inclination above horizon)
-sun [[sun_az=${SUN_AZ}]] [[sun_el=${SUN_EL}]]

  Used with -tshad and -tuni

Example: None
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

  -sv|--slipvector) # args: filename
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-sv:           plot slip vector azimuths specified in a file (lon lat azimuth [length])
-sv [filename] [[scale fieldnum]]

  If option "scale" is given, it is followed by a field number
    (first field is 1, default field is 4 (4th column))
  containing length of the bar to plot

Example: None
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

  -t|--topo) # args: ID | filename { args }
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-t:            download and visualize topography (~wgs1984 only)
-t [[datasource=SRTM30]] [[ { gmt topo args } ]]

  DATA SOURCE:

  Custom DEM file:
  -t [demfile] [[reproject]]

  Local large datasets downloaded using -getdata:
  -t SRTM30 | GEBCO20 | GEBCO1

  Dynamically downloaded data (tiles managed by tectoplot + GMT)
  -t GMRT | BEST

    BEST is a fusion of GMRT from online and SRTM 30 tiles from the GMT server.

  Dynamically downloaded data from GMT server (tiles managed by GMT)
  -t 01d | 30m | 20m | 15m | 10m | 06m | 05m | 04m | 03m | 02m | 01m
         | 15s | 03s | 01s

  The default visualization is GMT standard CPT+hillshade.

  Note: Use -tcpt to adjust the color stretch

Example:
  tectoplot -r AU -t 10m
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if arg_is_flag $2; then
			info_msg "[-t]: No topo file specified: SRTM30 assumed"
			BATHYMETRY="SRTM30"
		else
			BATHYMETRY="${2}"
			shift
		fi
    clipdemflag=1
		case $BATHYMETRY in
      01d|30m|20m|15m|10m|06m|05m|04m|03m|02m|01m|15s|03s|01s)
        plottopo=1
        GRIDDIR=$EARTHRELIEFDIR
        GRIDFILE=${EARTHRELIEFPREFIX}${BATHYMETRY}
        plots+=("topo")
        remotetileget=1
        echo $EARTHRELIEF_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        echo $EARTHRELIEF_SOURCESTRING >> ${LONGSOURCES}

        [[ ! -d $EARTHRELIEFDIR ]] && mkdir -p $EARTHRELIEFDIR

        ;;
      BEST)
        BATHYMETRY="01s"
        plottopo=1
        GRIDDIR=$EARTHRELIEFDIR
        GRIDFILE=${EARTHRELIEFPREFIX}${BATHYMETRY}
        plots+=("topo")
        remotetileget=1
        besttopoflag=1
        echo $GMRT_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        echo $GMRT_SOURCESTRING >> ${LONGSOURCES}
        echo $SRTM_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        echo $SRTM_SOURCESTRING >> ${LONGSOURCES}

        [[ ! -d $EARTHRELIEFDIR ]] && mkdir -p $EARTHRELIEFDIR

        ;;
			SRTM30)
			  plottopo=1
				GRIDDIR=$SRTM30DIR
				GRIDFILE=$SRTM30FILE
				plots+=("topo")
        echo $SRTM_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        echo $SRTM_SOURCESTRING >> ${LONGSOURCES}
        remotetileget=1
				;;
      GEBCO20)
        plottopo=1
        GRIDDIR=$GEBCO20DIR
        GRIDFILE=$GEBCO20FILE
        plots+=("topo")
        echo $GEBCO_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        echo $GEBCO_SOURCESTRING >> ${LONGSOURCES}
        ;;
      GEBCO1)
        plottopo=1
        GRIDDIR=$GEBCO1DIR
        GRIDFILE=$GEBCO1FILE
        plots+=("topo")
        echo $GEBCO_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        echo $GEBCO_SOURCESTRING >> ${LONGSOURCES}
        ;;
      GMRT)
        plottopo=1
        GRIDDIR=$GMRTDIR
        plots+=("topo")
        echo $GMRT_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        echo $GMRT_SOURCESTRING >> ${LONGSOURCES}
        ;;
      *)
        plottopo=1
        plotcustomtopo=1
        info_msg "Using custom grid"
        BATHYMETRY="custom"
        GRIDDIR=$(abs_dir $1)
        GRIDFILE=$(abs_path $1)  # We already shifted
        plots+=("topo")
        ;;
    esac

    # Read any topo arguments we might want to specify... not sure g would be used?
    if [[ ${2:0:1} == [{] ]]; then
      info_msg "[-t]: Topo args detected... slurping"
      shift
      while : ; do
        [[ ${2:0:1} != [}] ]] || break
        topoargs+=("${2}")
        shift
      done
      shift
      info_msg "[-t]: Found topo args ${imageargs[@]}"
      TOPOARGS="${imageargs[@]}"
    fi
    if [[ "${2}" =~ "reproject" ]]; then
      reprojecttopoflag=1
      shift
    fi
    # # Specify a CPT file
    # if arg_is_flag $2; then
    #   info_msg "[-t]: No topo CPT specified. Using default."
    # else
    #   customgridcptflag=1
    #   CPTNAME="${2}"
    #   CUSTOMCPT=$(abs_path $2)
    #   shift
    #   if ! [[ -e $CUSTOMCPT ]]; then
    #     info_msg "CPT $CUSTOMCPT does not exist... looking for $CPTNAME in $CPTDIR"
    #     if [[ -e $CPTDIR$CPTNAME ]]; then
    #       CUSTOMCPT=$CPTDIR$CPTNAME
    #       info_msg "Found CPT $CPTDIR$CPTNAME"
    #     else
    #       info_msg "No CPT could be assigned. Using $TOPO_CPT_DEF"
    #       CUSTOMCPT=$TOPO_CPT_DEF
    #     fi
    #   fi
    # fi
    #
    cpts+=("topo")
    fasttopoflag=1

    MULFACT=$(echo "1 / $HS_Z_FACTOR * 111120" | bc -l)     # Effective z factor for geographic DEM with m elevation

    ;;
  #
  # -tc|--cpt) # args: filename
  #   customgridcptflag=1
  #   CPTNAME="${2}"
  #   CUSTOMCPT=$(abs_path $2)
  #   shift
  #   if ! [[ -e $CUSTOMCPT ]]; then
  #     info_msg "CPT $CUSTOMCPT does not exist... looking for $CPTNAME in $CPTDIR"
  #     if [[ -e $CPTDIR/$CPTNAME ]]; then
  #       CUSTOMCPT=$CPTDIR/$CPTNAME
  #       info_msg "Found CPT $CPTDIR/$CPTNAME"
  #     else
  #       info_msg "No CPT could be assigned. Using $TOPO_CPT"
  #       CUSTOMCPT=$TOPO_CPT
  #     fi
  #   fi
  #   ;;

# Plot text from a file
# lon lat font 0 justification labeltext
    -text)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-text:         Plot simple text strings at points
-text [file] [[xoffset]] [[yoffset]]

  Plots text strings in white boxes at specified locations.
  file has columns in the format:
    lon lat font 0 justification text strings go here
  e.g.
    34.0 -21.1 12p,Helvetica,black 0 ML This is a string
  xoffset: shift all text sidways by this amount (requires unit, e.g. 0.5i)
  yoffset: shift all text up/down by this amount (requires unit, e.g. 0.5i)

Example: None
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

    TEXTXOFF=0
    TEXTYOFF=0

    if ! arg_is_flag "${2}"; then
      TEXTXOFF="${2}"
      shift
    fi

    if ! arg_is_flag "${2}"; then
      TEXTYOFF="${2}"
      shift
    fi

    plots+=("text")
    ;;

    -tflat)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tflat:        flatten bathymetry with elevation less than zero to zero
-tflat

  This function alters the DEM to have a flat sea surface. Use with -tunsetflat
  to make maps of land areas with shadows that extend onto the sea surface.

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi
      fasttopoflag=0
      tflatflag=1
    ;;

  -ti)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ti:           adjust illumination for gmt style topography (-t)
-ti [[azimuth]]

Example: None
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

  -timeme)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-timeme:       print script total run time on completion
-timeme

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    SCRIPT_START_TIME="$(date -u +%s)"
    scripttimeflag=1
    ;;

  -time)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-time:         select seismic data from a continuous epoch
-time [[start_time]] [[end_time]]

  Times are in IS8601 YYYY-MM-DDTHH:MM:SS format.
  YYYY, YYYY-MM, etc. will work.

Example: Solomon Islands seismicity between Jan 1 2001 and Jan 1 2005
  tectoplot -r SB -t -z -c -time 2001 2005
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    STARTTIME=$(date_shift_utc $daynum 0 0 0)
    ENDTIME=$(date_shift_utc)    # COMPATIBILITY ISSUE WITH GNU date

    timeselectflag=1
    if [[ "${2}" == "day" ]]; then
      daynum=1
      shift
      if arg_is_positive_float $2; then
        daynum=${2}
        shift
      fi
      daynum=$(echo "-1 * $daynum" | bc -l)
      STARTTIME=$(date_shift_utc $daynum 0 0 0)
      ENDTIME=$(date_shift_utc)    # COMPATIBILITY ISSUE WITH GNU date
    elif [[ "${2}" == "week" ]]; then
      weeknum=1
      shift
      if arg_is_positive_float $2; then
        weeknum=${2}
        shift
      fi
      daynum=$(echo "-1 * $weeknum * 7" | bc -l)
      STARTTIME=$(date_shift_utc $daynum 0 0 0)
      ENDTIME=$(date_shift_utc)    # COMPATIBILITY ISSUE WITH GNU date
    elif [[ "${2}" == "year" ]]; then
      yearnum=1
      shift
      if arg_is_positive_float $2; then
        yearnum=${2}
        shift
      fi
      daynum=$(echo "-1 * $yearnum * 365.25" | bc -l)
      STARTTIME=$(date_shift_utc $daynum 0 0 0)
      ENDTIME=$(date_shift_utc)    # COMPATIBILITY ISSUE WITH GNU date
    else
      if ! arg_is_flag "${2}"; then
        STARTTIME="${2}"
        shift
      fi
      if ! arg_is_flag "${2}"; then
        ENDTIME="${2}"
        shift
      fi
    fi
    info_msg "Time constraints: $STARTTIME to $ENDTIME"
    ;;

    # Set GMT variables to fit a certain theme
    # The default GMT themes will only work with more recent GMT6 versions; classic will work for anything?
  -theme)
    if ! arg_is_flag "${2}"; then
      THEME_ID="${2}"
      shift
    fi
    ;;


  -title) # args: string
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-title:        set and display plot title
-title "Title of Map"

Example: Solomon Islands
  tectoplot -r SB -a -title "Solomon Islands"
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

  -tn)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tn:           plot topographic contours
-tn [contour_interval] [[ { GMT ARGS } ]]

  Plot contours of -t topography.

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    # CONTOUR_INTERVAL="${2}"
    # shift
    # info_msg "[-tn]: Plotting topo contours at interval $CONTOUR_INTERVAL"
    # plots+=("contours")
    if arg_is_flag $2; then
      info_msg "[-tn]: Contour interval not specified. Calculating automatically from Z range using $TOPOCONTOURNUMDEF contours"
      topocontourcalcflag=1
    else
      TOPOCONTOURINT="${2}"
      shift
    fi
    if [[ ${2:0:1} == [{] ]]; then
      info_msg "[-tn]: GMT argument string detected"
      shift
      while : ; do
          [[ ${2:0:1} != [}] ]] || break
          topocvars+=("${2}")
          shift
      done
      shift
      CONTOURGRIDVARS="${topocvars[@]}"
    fi
    info_msg "[-tn]: Custom GMT topo contour commands: ${TOPOCONTOURVARS[@]}"
    plots+=("contours")
    ;;

  -tr)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tr:           rescale cpt to data range
-tr   [min] [[max]] [[spacing]]

  Stretch the CPT color scheme across the topographic range in the DEM (default),
  or between given values. Spacing dictates width of CPT z-slices.

Example:
  tectoplot -r 45 46 33 34 -t -tr
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    if arg_is_float "${2}"; then
      RESCALE_CPT_MIN="${2}"
      shift
    else
      RESCALE_CPT_MIN="none"
    fi
    if arg_is_float "${2}"; then
      RESCALE_CPT_MAX="${2}"
      shift
    else
      RESCALE_CPT_MAX="none"
    fi
    if arg_is_positive_float "${2}"; then
      RESCALE_CPT_SPACING="${2}"
      shift
    else
      RESCALE_CPT_SPACING="none"
    fi

    rescaletopoflag=1
    ;;

    -trp)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tr:           rescale cpt by two factors, above and below 0
-tr   [below] [above]

  Stretch the CPT color scheme by multiplying values > 0 by [above] and
  values < 0 by [below]

Example:
  tectoplot -r 45 46 33 34 -t -tr
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

  -ts)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ts:           do topo calculations but don't plot the final topography image
-ts

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    dontplottopoflag=1
    ;;

  -tt)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tt:           set the transparency of the topo image
-tt

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    TOPOTRANS=${2}
    shift
    ;;

  -tx) #                                                  don't color topography (plot intensity directly)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tx:           don"t color the topography - plot intensity only
-tx

  Only works with non-GMT visualization schemes (-tmult etc)

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    dontcolortopoflag=1
    ;;

  # Popular recipes for topo visualization
  -t0)  #  Slope/50% Multiple hillshade 45°/50% Gamma=1.4
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-t0:           slopeshade terrain visualization
-t0

  Use gdal tools to create a slope-hillshade composite shaded relief map.

Example: Slopeshade map of Sierra Leone
  tectoplot -r SL -t -t0
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

#Build your own topo visualization using these commands in sequence.
#  [[fact]] is the blending factor (0-1) used to combine each layer with existing intensity map

  -tshad) #         [[sun_az]] [[sun_el]]   [[fact]]    add cast shadows to intensity (fact=opacity)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tshad:        add cast shadows to terrain intensity
-tshad [[sun_azimuth]] [[sun_elevation]] [[alpha]]

  Use gdal tools to create a slope-hillshade composite shaded relief map.
  sun_azimuth: angle CW from north, degrees
  sun_elevation: angle up from horizon, degrees
  alpha: transparency of cast shadows

Example: Slopeshade map of Sierra Leone
  tectoplot -r SL -t -t0
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    fasttopoflag=0
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
    info_msg "[-tshad]: Sun azimuth=${SUN_AZ}; elevation=${SUN_EL}; alpha=${SHADOW_ALPHA}"
    topoctrlstring=${topoctrlstring}"d"
    useowntopoctrlflag=1
    ;;

  -ttext) #           [[frac]]   [[stretch]]  [[fact]]    add texture shade to intensity
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ttext:        add texture map to terrain intensity
-ttext [[frac=${TS_FRAC}]] [[stretch=${TS_STRETCH}]] [[fact=${TS_FACT}]]

  The texture map visualization by Leland Brown uses a DCT calculation to
  visualize relief.
  frac: detail parameter
  stretch: contrast stretch parameter
  fact: blend factor with white before blending to terrain intensity [0-1]

Example: Slopeshade map of Sierra Leone
  tectoplot -r SL -t -t0
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

  -tmult) #           [[sun_el]]              [[fact]]    add multiple hillshade to intensity
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tmult:        add multiple direction hillshade (grayscale) to terrain intensity
-tmult [[sun_alt=${HS_ALT}]] [[fact=${MULTIHS_FACT}]]

  Multiple hillshade is a combination of illumination from different directions
  under a constant solar altitude.

Example: Multiple hillshade map of Laos
  tectoplot -r LA -t -tmult -tx
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

  -tuni) #            [[sun_az]] [[sun_el]]   [[fact]]    add unidirectional hillshade to intensity
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tuni:         add unidirectional hillshade to terrain intensity
-tuni [[sun_az=${HS_AZ}]] [[sun_alt=${HS_ALT}]] [[fact=${UNIHS_FACT}]]

  Unidirectional hillshade is illumination from one direction and solar
  altitude.

Example: Multiple hillshade map of Laos
  tectoplot -r LA -t -tuni -tx
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

  -cptrescale)

    echo "Rescaling"
    rescale_cpt $2 $3 $4
    echo "Replacing colornames"
    replace_gmt_colornames_rgb $2
    shift
    shift
    shift
    exit
    ;;

  -tcpt)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tcpt:         specify the color scheme for topography
-tcpt [[cpt=${TOPO_CPT_DEF}]] [[type="${TOPO_CPT_TYPE}"]]

  cpt = CPT file or builtin CPT name

Example: None
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
      echo "[-tcpt]: Setting CPT to ${CPT_PATH}"
      TOPO_CPT_DEF=${CPT_PATH}
    else
      info_msg "[-tcpt]: $2 is not a valid CPT specification"
      exit 1
    fi

    # if [[ -s "${2}" ]]; then
    #   TOPO_CPT_DEF=$(abs_path ${2})
    #   info_msg "[-tcpt]: Setting CPT to ${TOPO_CPT_DEF}"
    # elif gmt makecpt -C${2} > /dev/null 2>&1; then
    #   info_msg "[-tcpt]: CPT ${2} is a builtin GMT CPT."
    #   TOPO_CPT_DEF="${2}"
    # elif [[ -s ${CPTDIR}${2} ]]; then
    #   info_msg "[-tcpt]: CPT ${2} is a builtin tectoplot CPT in ${CPTDIR}."
    #   TOPO_CPT_DEF=$(abs_path ${CPTDIR}${2})
    # elif [[ -s ${CPTDIR}${2}.cpt ]]; then
    #   info_msg "[-tcpt]: CPT ${2}.cpt is a builtin tectoplot CPT in ${CPTDIR}."
    #   TOPO_CPT_DEF=$(abs_path ${CPTDIR}${2}.cpt)
    # elif [[ -s ${CPTDIR}colorcet/CET-${2}.cpt ]]; then
    #   info_msg "[-tcpt]: CET-${2}.cpt is colorcet CPT in ${CPTDIR}/colorcet/"
    #   TOPO_CPT_DEF=$(abs_path ${CPTDIR}colorcet/CET-${2}.cpt)
    # elif [[ -s ${CPTDIR}colorcet/${2} ]]; then
    #   info_msg "[-tcpt]: CPT ${2} is colorcet CPT in ${CPTDIR}/colorcet/"
    #   TOPO_CPT_DEF=$(abs_path ${CPTDIR}"colorcet/"${2})
    # else
    #   echo "[-tcpt]: ${2} is not a valid CPT"
    #   echo -n "GMT builtin CPTS (see gmt -makecpt): "
    #   gmt makecpt 2>&1 | gawk '($2==":"){printf("%s "), $1} END { printf("\n")}'
    #   exit 1
    # fi
    shift
  fi


  # if ! arg_is_flag "${2}"; then
  #   case "${2}" in
  #     c)
  #       TOPO_CPT_TYPE="-Z"
  #       ;;
  #     d)
  #       TOPO_CPT_TYPE=""
  #       ;;
  #   esac
  #   shift
  # fi

  ;;

  -tpct) # percent cut
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tpct:         contrast enhancement by percent cut (lo/hi) of terrain intensity
-tpct [[lowcut=${TPCT_MIN}]] [[highcut=${TPCT_MAX}]]

  Operates on the existing terrain intensity at the moment of application.
  Cells with intensity below (lowcut) and above (highcut) the given percentages
  are assigned to 1 or 254. All values between are stretched to fit.

Example: Percent cut on a multiple hillshade
  tectoplot -r LA -t -tmult -tpct 1 99 -tx
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

  -tsea)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tsea:         recolor sentinel satellite imagery in ocean areas
-tsea [[color=${SENTINEL_RECOLOR}]]

  Sentinel imagery above the oceans has baked in subaqueous relief or clouds.
  Set the ocean areas (z=0) to a fixed color.
  Needs -tsent or -tblue option prior to -tsea

Example: Recolor the ocean around Yemen
  tectoplot -r YE -t -tsent -tsea
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    fasttopoflag=0
    if ! arg_is_flag $2; then
      SENTINEL_RECOLOR=${2}
      shift
    fi
    sentinelrecolorseaflag=1
    ;;

  -tblue)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tblue:        nasa blue marble imagery
-tblue [[fact=${SENTINEL_FACT}]] [[gamma=${SENTINEL_GAMMA}]]

  Use dynamically downloaded NASA Blue Marble imagery as the color that is
  multiplied with terrain intensity.
  The image is automatically saved in an archive based on extent and resolution

Example: Blue Marble map of Yemen
  tectoplot -r YE -t -tblue -tsea
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

    touch ./sentinel.tif
    sentineldownloadflag=1
    shift
    set -- "blank" "$@" "-timg" "sentinel.tif" "${SENTINEL_FACT}"
    ;;

  -tsave)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tsave:        archive terrain data for a named region
-tsave

  If using -r RegionID, save the rendered terrain image for later rapid use.
  Requires -radd RegionID prior to calling tectoplot with -tsave or -tload

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    tsaveflag=1
    ;;

  -tload)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tload:        load archived terrain data for a named region
-tload

  If using -r RegionID, load a saved rendered terrain image.
  Requires -radd RegionID prior to calling tectoplot with -tsave or -tload

  [[Currently requires -t0, -tsl, or another -txxx call in order to not have the
  fast topo visualization run...]]

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    fasttopoflag=0
    tloadflag=1
    ;;

  -tdelete)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tdelete:      delete archived terrain data for a named region
-tdelete

  If using -r RegionID, delete a saved rendered terrain image.
  Requires -radd RegionID prior to calling

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    tdeleteflag=1
    ;;


  -tsent)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tsent:        color terrain using downloaded sentinel cloud-free image
-tsent [[fact=${SENTINEL_FACT}]] [[gamma=${SENTINEL_GAMMA}]]

  Options
  notopo        : Plot only the imagery, don't plot topo. Still needs -t option


  If using -r RegionID, load a saved rendered terrain image.
  Requires -radd RegionID prior to calling tectoplot with -tsave or -tload

  [[Currently requires -t0, -tsl, or another -txxx call in order to not have the
  fast topo visualization run...]]

Example: Sentinel cloud free image draped onto multi-hillshade, Arizona USA
  tectoplot -r US.AZ -t -tmult -tsent
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    fasttopoflag=0
    SENTINEL_TYPE="s2cloudless-2019"
    SENTINEL_FACT=0.5
    if arg_is_positive_float $2; then
      info_msg "[-tsent]: Sentinel image alpha values set to $2"
      SENTINEL_FACT=${2}
      shift
    fi
    if arg_is_positive_float $2; then
      info_msg "[-tsent]: Sentinel image gamma correction set to $2"
      SENTINEL_GAMMA=${2}
      shift
    fi
    if [[ $2 =~ "notopo" ]]; then
      info_msg "[-tsent]: No topo plotted with Sentinel data"
      sentinelnotopoflag=1
      shift
    fi
    touch ./sentinel.tif
    sentineldownloadflag=1
    # Replace -tsent with -timg [[sentinel.tif]] [[alpha]]
    shift
    set -- "blank" "$@" "-timg" "sentinel.tif" "${SENTINEL_FACT}"
    ;;

  -tsky) #            [[num_angles]]          [[fact]]    add sky view factor to intensity
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tsky:         add sky view factor to terrain intensity
-tsky [[num_angles=${NUM_ANGLES}]] [[fact=${SKYVIEW_FACT}]]

  If using -r RegionID, load a saved rendered terrain image.
  Requires -radd RegionID prior to calling tectoplot with -tsave or -tload

  [[Currently requires -t0, -tsl, or another -txxx call in order to not have the
  fast topo visualization run...]]

Example: Sky view factor of Pennsylvania, UTM
  tectoplot -r US.PA -t -tsky -tx -RJ UTM
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    fasttopoflag=0
    if arg_is_float $2; then   # first arg is a number
      NUM_ANGLES="$2"
      shift
    fi
    if arg_is_float $2; then
      SKYVIEW_FACT=$2
      shift
    fi
    info_msg "[-tsky]: Number of angles=${NUM_ANGLES}; combine factor=${SKYVIEW_FACT}"
    topoctrlstring=${topoctrlstring}"v"
    useowntopoctrlflag=1
    ;;


  -makeply)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-makeply:      make a 3D Sketchfab model including topo, FMS, seismicity, Slab2.0
-makeply [[option1 value1]] [[option2 value2]] ...

    Topo, seismicity, focal mechanisms, GPS velocities, volcanoes, and Slab2 geometries will be generated
    automatically if the equivalent -t, -z, -c, -g, -vf, or -b commands are given.

    Options:
    [[landkm spacing=${PLY_FIB_KM}]]          Spacing of surface grid pts if no DEM given
    [[scale factor=${PLY_SCALE}]]            Rescale scaleable items by multiplying by this factor
    [[vexag factor=${PLY_VEXAG}]]            Vertical exaggeration of data
    [[topoexag factor=${PLY_VEXAG_TOPO}]]    Vertical exaggeration of DEM
    [[demonly]]                       Only make DEM mesh and texture, not other 3D data
    [[addz offset=${PLY_ZOFFSET}]]           Vertical shift (positive away from Earth center) in km
    [[maxsize size=${PLY_MAXSIZE}]]        Resample DEM to given maximum width (cells) before meshing
    [[alpha value=${PLY_ALPHACUT}]]         Apply alpha mask to DEM texture using transparent PNG
    [[sidebox depth=${PLY_SIDEBOXDEPTH} color=${PLY_SIDEBOXCOLOR}]]   Make sides and bottom of box under topo
    [[sidetext on|off v_int h_int]]   Plot text on sidebox? If on, v_int in km, h_int in degrees
    [[maptiff]]  Use the rendered map TIFF and not just shaded relief as the texture for the DEM
    [[mtl name=${PLY_MTLNAME}]]            Name of DEM OBJ and its corresponding material
    [[fault file1 file2 ...]]         Make colored mesh of gridded fault data
    [[ocean]]                         Make ocean layer at given ocean depth
    [[box depth(km)=${PLY_BOXDEPTH}]]                 Draw box encompassing seismicity OR at fixed depth
    [[text depth(km) string of words ]]   Print text at center of plane defined by corner points
    [[floattext lon lat depth scale string of words]]

    See also: -addobj    Include OBJ files from specified directory
Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  makeplyflag=1
  makeplydemmeshflag=1
  plydemonlyflag=0
  makeplysurfptsflag=0

  while ! arg_is_flag "${2}"; do

    case "${2}" in
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
        plyfloatingtextflag=1
        PLY_FLOAT_TEXT_STRING=""
        PLY_FLOAT_TEXT_DEPTH=100
        PLY_FLOAT_TEXT_SCALE=0.1

        if arg_is_float ${2}; then
          PLY_FLOAT_TEXT_LON="${2}"
          shift
        fi
        if arg_is_float ${2}; then
          PLY_FLOAT_TEXT_LAT="${2}"
          shift
        fi
        if arg_is_float ${2}; then
          PLY_FLOAT_TEXT_DEPTH="${2}"
          shift
        fi
        if arg_is_float ${2}; then
          PLY_FLOAT_TEXT_SCALE="${2}"
          shift
        fi

        while ! arg_is_flag ${2}; do
          PLY_FLOAT_TEXT_STRING="${PLY_FLOAT_TEXT_STRING} ${2}"
          shift
        done
        echo gawk \< ${F_3D}sentence.obj -v text_lat=${PLY_FLOAT_TEXT_LAT} -v text_lon=${PLY_FLOAT_TEXT_LON} -v text_depth=${PLY_FLOAT_TEXT_DEPTH} -v text_scale=${PLY_FLOAT_TEXT_SCALE}


        ;;


    box)
      shift
      plymakeboxflag=1
      if arg_is_float ${2}; then
        PLY_BOXDEPTH="${2}"
        plyboxdepthflag=1
        shift
      fi
      echo "box: ${PLY_BOXDEPTH}"
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

  -addobj)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-addobj:       add existing OBJ file and material file to 3D model
-addobj [file.obj] [file.mtl] [file.jpg/png/etc]

  file.obj is added to 3d/
    - Materials library command should be "mtllib materials.mtl"
  file.jpg/png/etc is placed in 3d/Textures/
  file.mtl is concatenated to 3d/materials.mtl; values are ajusted to avoid
       having identical materials that cause meshes to be merged in Sketchfab

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  if [[ -s ${2} ]]; then
    ADDOBJFILE+=("$(abs_path ${2})")
    shift
    addobjflag=1
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

  -tsl)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tsl:          add slope to terrain intensity
-tsl [[fact=${SLOPE_FACT}]]

Example: Slope map of Madagascar, UTM
  tectoplot -r MG -t -tsl -tx -RJ UTM
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

  -ttri)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ttri:         add terrain ruggedness index to terrain intensity
-ttri

Example: TRI of Nevada, USA, UTM
  tectoplot -r US.NV -t -ttri -tx -RJ UTM
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    fasttopoflag=0
    topoctrlstring=${topoctrlstring}"i"
    useowntopoctrlflag=1
    ;;

  -timg)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-timg:         color terrain intensity using a georeferenced image (e.g. tiff)
-timg [filename] [fact=${IMAGE_FACT}]

Example: TRI of Nevada, USA, UTM
  tectoplot -r US.NV -t -ttri -tx -RJ UTM
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    echo "${@}"
    fasttopoflag=0
    if arg_is_flag $2; then
      info_msg "[-timg]: No image given. Ignoring."
    else

      if [[ ! -s ${2} && "${2}" != "sentinel.tif" ]]; then
        echo "[-timg]: File $2 not found or is empty"
        exit 1
      else
        P_IMAGE=$(abs_path ${2})
        shift
        if [[ $sentinelnotopoflag -eq 1 ]]; then
          topoctrlstring="p"
        else
          topoctrlstring=${topoctrlstring}"p"
        fi
        useowntopoctrlflag=1
      fi
    fi
    if arg_is_positive_float $2; then
      IMAGE_FACT=$2
      shift
    fi
    ;;

  -tclip) # Shouldn't I just clip the DEM here? Why have it as part of processing when that can mess things up?
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tclip:        clip dem to specified lon/lat aoi before terrain visualization
-tclip [MinLon] [MaxLon] [MinLat] [MaxLat]

  [ Doesn't seem to work currently ]

Example: Terrain map of selected part of Nevada, USA, UTM
  tectoplot -r US.NV -t -tclip -118 -115 37 39 -t0 -tx -RJ UTM
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

  -tunsetflat)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tunsetflat:   set regions with elevation = 0 to white in terrain intensity
-tunsetflat

Example: Kerguelen with shadows on the flat sea
  tectoplot -r 68 71 -50.5 -48 -t 03s -tflat -tmult -tunsetflat -tshad 65 1 -tx -RJ UTM
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    fasttopoflag=0
    topoctrlstring=${topoctrlstring}"u"
    ;;

  -tquant)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tquant:       terrain intensity from height above local quantile elevation
-tquant [[quantile=${DEM_QUANTILE}]] [[radius=${DEM_QUANTILE_RADIUS}]] [[fact=${QUANTILE_FACT}]]

Example: None
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
    if arg_is_positive_float "${2}"; then
      DEM_QUANTILE_RADIUS="${2}"
      shift
    fi
    if arg_is_positive_float "${2}"; then
      QUANTILE_FACT="${2}"
      shift
    fi

    ;;

    -tsmooth)
    if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tsmooth:       smooth input DEM before plotting (Gaussian)
-tquant [[radius=${DEM_SMOOTH_RAD}]]

  radius is in pixels

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    if arg_is_positive_float "${2}"; then
      DEM_SMOOTH_RAD="${2}"
      shift
    fi
    DEM_SMOOTH_FLAG=1
    ;;

  -tca)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tca:          set alpha value for DEM color stretch
-tca [[alpha=${DEM_ALPHA}]]

  alpha is accomplished by blending with white before multiply overlay

  alpha=1 -> fully transparent
  alpha=0 -> fully opaque

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  if arg_is_positive_float "${2}"; then
    DEM_ALPHA="${2}"
    shift
  fi
  ;;

  -tgam) #            [gamma]                           add gamma correction to intensity
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-tgam:         apply gamma correction to terrain intensity image
-tgam [[gamma=${HS_GAMMA}]]

  Gamma correction adjusts the contrast of an image.
  Gamma > 1 : darken
  Gamma < 1 : lighten

Example: None
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

	-v|--gravity) # args: string number
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-v:            plot global gravity data and related data
-v [[model=${GRAVMODEL}]] [[trans=${GRAVTRANS}]] [[rescale]]

  model:
    BG = WGM2012 Bouguer
    FA = WGM2012 Free Air
    IS = WGM2012 Isostatic
    SW = Sandwell 2019 Free Air

  rescale adjusts the range of the CPT to match range of data in the AOI
Example: TRI of Nevada, USA, UTM
  tectoplot -r US.NV -t -ttri -tx -RJ UTM
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
      elif [[ $2 == "nograd" ]]; then
        GRAVGRAD=""
        shift
      fi
    done

		case $GRAVMODEL in
			FA)
				GRAVDATA=$WGMFREEAIR
				GRAVCPT=$WGMFREEAIR_CPT
        echo $GRAV_SHORT_SOURCESTRING >> ${SHORTSOURCES}
        echo $GRAV_SOURCESTRING >> ${LONGSOURCES}
				;;
			BG)
				GRAVDATA=$WGMBOUGUER
				GRAVCPT=$WGMBOUGUER_CPT
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

  -vcurv)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-vcurv:        plot curvature of sandwell 2019 global gravity data
-vcurv

Example: Gravity curvature of spreading ridge SE of Madagascar
  tectoplot -r 46 66 -40 -24 -vcurv
--------------------------------------------------------------------------------
EOF
shift && continue
fi
  GRAV_CURV_DATA=${SANDWELLFREEAIR_CURV}

  plots+=("gravcurv")
  cpts+=("gravcurv")

  ;;

  -vars) # argument: filename
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-vars:         define variables from a bash format file by sourcing it
-vars [filename]

  This function is identical to -e and should be removed?

Example: None
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

#   -vc|--volc) # args: none
# if [[ $USAGEFLAG -eq 1 ]]; then
# cat <<-EOF
# -vc:           plot volcanoes
# -vc [[fill color=${V_FILL}]] [[line width=${V_LINEW}]] [[size=${V_SIZE}]]
#
#   Data from a variety of sources; Smithsonian, Whelley 2015, Japan
#   Currently uses the GMT custom volcano symbol.
#
# Example: Volcanoes of Japan
#   tectoplot -r JP -a -vc
# --------------------------------------------------------------------------------
# EOF
# shift && continue
# fi
#     if arg_is_flag $2; then
#       info_msg "[-vc]: No volcano line width or fill color specified."
#     else
#       V_FILL="${2}"
#       shift
#     fi
#     if arg_is_flag $2; then
#       info_msg "[-vc]: No volcano line width specified."
#     else
#       V_LINEW="${2}"
#       shift
#     fi
#     if arg_is_flag $2; then
#       info_msg "[-vc]: No volcano size specified."
#     else
#       V_SIZE="${2}"
#       shift
#     fi
#
#     plots+=("volcanoes")
#     volcanoesflag=1
#     echo $VOLC_SHORT_SOURCESTRING >> ${SHORTSOURCES}
#     echo $VOLC_SOURCESTRING >> ${LONGSOURCES}
#     ;;

  # A high priority option processed in the prior loop
  -verbose) # args: none
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-verbose:      turn on gmt verbose option to get lots of feedback
-verbose

Example: Volcanoes of Japan with verbosity
  tectoplot -r JP -a -vc -verbose
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    # VERBOSE="-V"
    ;;

  -w|--euler) # args: number number number
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-w:            plot velocity field from a specified euler pole on grid points
-w [pole_lat] [pole_lon] [omega] [[pole_lat_2]] [[pole_lon_2]] [[pole_omega_2]]

  Requires -px, -pf, or -pi option to generate grid points

  If two Euler poles are specified, add them and use the resulting Euler pole

Example: Global Euler pole velocity field on a Fibonacci grid
  tectoplot -RJ W -a -pf 1000 -w 10 20 0.2
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



    # if ! arg_is_flag $2; then
    #   EULER_VEC_FILLCOLOR="${2}"
    #   shift
    # fi

    plots+=("euler")
    ;;

  -wg) # args: number
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-wg:           plot euler pole velocity field at gps sites instead of grid
-wg [[residual scaling=${WRESSCALE}]]

  Requires -g option to set GPS site locations
  If residual scaling is indicated, plot difference between GPS+Euler velocity

Example: Turkey, random Euler pole velocity field vs GPS relative to Europe
  tectoplot -r TR -a -g eu -w 36 32 1 black -wg -i 2
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
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-wp:           plot euler pole velocity of one plate relative to another at grid/gps sites
-wp [PlateID1] [PlateID2]

  Requires -p option to load plate data and -x/-g options to set site locations

Example: GPS velocity of Arabia relative to Europe, with MORVEL Euler poles
  tectoplot -r SA -a -g eu -w 36 32 1 black -wp ar eu -i 2
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    twoeulerflag=1
    plotplates=1
    eulerplate1="${2}"
    eulerplate2="${3}"
    plots+=("euler")
    shift
    shift
    ;;

	-z|--seis) # args: number
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-z:            plot seismicity catalog data
-z [[scale=${SEISSCALE}]] [[trans=${SEISTRANS}]]

Example: Seismicity of region surrounding Panama
  tectoplot -r PA+R3 -a -z
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

#   -zadd) # args: file   - supplemental seismicity catalog in lon lat depth mag [datestr] [id] format
# if [[ $USAGEFLAG -eq 1 ]]; then
# cat <<-EOF
# -zadd:         include local seismicity catalog in seismicity
# -zadd [filename] [[replace]] [[cull]]
#
#   If "replace" option is given, do not plot global catalog data.
#   If "cull" option is given, attempt to remove duplicate events between the added
#     and original catalog, preferring the added catalog over the original.
#
#   Input format is tectoplot seismicity format:
#   longitude[degrees] latitude[degrees] depth[km] magnitude[mw] timecode[YYYY-MM-DDTHH:MM:SS] id[string] epoch[seconds]
#
# Example: None
# --------------------------------------------------------------------------------
# EOF
# shift && continue
# fi
#     eqcatalogreplaceflag=0
#
#     seisfilenumber=$(echo "$seisfilenumber+1" | bc)
#     if arg_is_flag $2; then
#       info_msg "[-zadd]: Seismicity file must be specified"
#     else
#       SEISADDFILE[$seisfilenumber]=$(abs_path $2)
#       if [[ ! -e "${SEISADDFILE[$seisfilenumber]}" ]]; then
#         info_msg "Seismicity file ${SEISADDFILE[$seisfilenumber]} does not exist"
#       else
#         suppseisflag=1
#       fi
#       shift
#     fi
#
#     if [[ "${2}" == "nocull" ]]; then
#       info_msg "[-zadd]: Culling catalog to remove equivalent events."
#       CULL_EQ_CATALOGS=0
#       shift
#     else
#       CULL_EQ_CATALOGS=1
#     fi
#
#     if [[ "${2}" == "replace" ]]; then
#       info_msg "[-zadd]: Seis replace flag specified. Replacing catalog hypocenters."
#       eqcatalogreplaceflag=1
#       ADD_EQ_SOURCESTRING=2
#       shift
#     else
#       eqcatalogreplaceflag=0
#     fi
#
#     echo "CustomEQs" >> ${SHORTSOURCES}
#     echo "Seismicity from custom file ${SEISADDFILE[$seisfilenumber]}" >> ${LONGSOURCES}
#
#     ;;

  -zcnoscale)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zcnoscale:    do not adjust scaling of earthquake/focal mechanism symbols
-zcnoscale

Example: None
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

    -zcfixsize)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zcfixsize:    earthquake/focal mechanisms have only one specified size
-zcfixsize [[size=${SEISSCALE}]]

  Size has unit, e.g. 0.01i

Example: None
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


  -zcrescale)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zcrescale:    adjust size of seismicity/focal mechanisms by a multiplied factor
-zcrescale [scale=${SEISSCALE}] [[seisstretch=${SEISSTRETCH}]] [[refmag=${SEISSTRETCH_REFMAG}]]

  Modify magnitude of earthquake/focal mechanisms to allow non-linear rescaling
  of plotted earthquake data.

  Mw_new = (Mw^seisstretch)/(refmag^(seisstretch-1))

Example: None
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

  -seisproj)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-seisproj:     create a seismicity (X) vs depth (Y) projected panel below or to right of map
-seisproj [dim1=${SEISPROJ_DIM1} size1=${SEISPROJHEIGHT_DIM1}] [[dim2 size2]]

  Use -noframe bottom, -noframe right, or -noframe bottom right to avoid overlapping labels

  dim1 and dim2 can be X or Y

  SEISPROJ_DIMS="X"           # Can be X, Y, or XY
  SEISPROJHEIGHT_X=3          # Height in inches of -seisproj panel (X dimension)
  SEISPROJWIDTH_Y=3           # Width in inches of -seisproj panel (Y dimension)

Example: None
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

-zccluster)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zccluster:    decluster seismicity and color by cluster ID rather than depth
-zccluster [[remove]] [[method=${DECLUSTER_METHOD}]] [[minsize=${DECLUSTER_MINSIZE}]]

  Seismic catalog declustering separates independent events from those that can
  be labelled as aftershocks or foreshocks (dependent events). This option
  implements window-based declustering methods:

  remove = remove non-mainshock events from the seismicity catalog.

  gk = Gardner and Knopoff, 1974
  urhammer = Urhammer, 1976
  gruenthal = Gruenthal, personal communication, to somebody at some point (?)
  rb = Reasenberg using cluster2000x FORTRAN code, slightly modified
               (only clusters the last 100 years of the input catalog)

  minsize = clusters with fewer than this number of events have all events
            assigned to independent class - highlight EQs with large # of events

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  if [[ $2 =~ "remove" ]]; then
    DECLUSTER_REMOVE=1
    shift
  fi
  if [[ $2 =~ "urhammer" || $2 =~ "gk" || $2 =~ "gruenthal" || $2 =~ "rb" ]]; then
    DECLUSTER_METHOD="${2}"
    shift
  fi
  if arg_is_positive_float $2; then
    DECLUSTER_MINSIZE="${2}"
    shift
  fi



  zcclusterflag=1
  seisdeclusterflag=1

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
  plots+=("eqcluster")

  ;;

  -zconland)
  if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zconland:     select FMS/seismicity with origin epicenter beneath land
-zconland

Example: None
--------------------------------------------------------------------------------
EOF
  shift && continue
  fi

  zconlandflag=1
  zc_land_or_sea=1

  ;;

  -zconsea)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zconsea:      select FMS/seismicity with origin epicenter beneath the sea
-zconsea

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi

  zconlandflag=1
  zc_land_or_sea=0

  ;;

  -zctime)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zctime:       color seismicity by time rather than depth
-zctime [start_time] [[end_time=$(date_shift_utc)]]

Example: Color seismicity in Greece by years from 1990 to 2010
  tectoplot -r GR -a -z -zctime 1990 2010
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    # Set default epochs for visualizing seismicity by time; override by command line args in iso8601
    COLOR_TIME_START_TEXT="1970-01-01T00:00:00"
    COLOR_TIME_END_TEXT=$(date_shift_utc)

    if ! arg_is_flag $2; then
      COLOR_TIME_START_TEXT=${2}
      shift
    fi
    if ! arg_is_flag $2; then
      COLOR_TIME_END_TEXT=${2}
      shift
    fi
    COLOR_TIME_START=$(echo "$COLOR_TIME_START_TEXT" | gawk '
      @include "tectoplot_functions.awk"
      {
        print iso8601_to_epoch($1)
      }')
    COLOR_TIME_END=$(echo "$COLOR_TIME_END_TEXT" | gawk '
      @include "tectoplot_functions.awk"
      {
        print iso8601_to_epoch($1)
      }')
    info_msg "[-zctime]: Epoch start and end times are: $COLOR_TIME_START $COLOR_TIME_END"
    zctimeflag=1

    replaceseiscptflag=0

    # Replace one occurrance of seisdepth with eqtime in cpts list
    for thiscpt_num in ${#cpts[@]}; do
      ((thiscpt_num--))
      if [[ ${cpts[$thiscpt_num]} =~ "seisdepth" ]]; then
        replaceseiscptflag=1
        cpts[$thiscpt_num]="eqtime"
        break
      fi
    done

    [[ $replaceseiscptflag -eq 0 ]] && cpts+=("eqtime")
    # legendbarwords+=("eqtime")
    # cpts+=("eqtime")
    plots+=("eqtime")
  ;;

  -zdep)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zdep:         set depth range of selected seismicity
-zdep [min_depth] [max_depth]

  Both depths are in km without k unit.

Example: Plot seismicity in Italy between 50 and 100 km
  tectoplot -r IT -a -z -zdep 50 100
--------------------------------------------------------------------------------
EOF
shift && continue
fi

    if [[ ! $(number_nonflag_args "${@}") -eq 2 ]]; then
      echo "[-zdep]: Two arguments required. tectoplot usage -zdep"
      exit
    fi
    EQCUTMINDEPTH=${2}
    shift
    EQCUTMAXDEPTH=${2}
    shift
    info_msg "[-zdep]: Plotting seismic data between ${EQCUTMINDEPTH} km and ${EQCUTMAXDEPTH} km"
  ;;

  -zfill)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zfill:        color seismicity with a constant fill color
-zfill [color]

  Color is a GMT color word or R/G/B triplet in the form 255/255/255

Example: Plot seismicity in Timor-Leste
  tectoplot -r TL -a -z -zfill 100/100/100
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


    # GFZ)
    #   EQ_CATALOG_TYPE+=("GFZ")
    #   EQ_SOURCESTRING=$GFZ_SOURCESTRING
    #   EQ_SHORT_SOURCESTRING=$GFZ_SHORT_SOURCESTRING
    # ;;
  -ccat) #
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-ccat:         select focal mechanism catalog(s) and add custom focal mechanism files
-ccat [catalogID1] [[catalogfile1 code1 ]] ...  [[nocull]]

  catalogID: GCMT | ISC | GFZ
  catalogfile: Any file in a format importable by cmt_tools.sh

  format codes:

  Code   GMT or other format info
  ----   -----------------------------------------------------------------------
    a    psmeca Aki and Richards format (mag= 28. MW)
          X Y depth strike dip rake mag [newX newY] [event_title] [newdepth] ...
          [timecode]
    c    psmeca GCMT format
          X Y depth strike1 dip1 rake1 aux_strike dip2 rake2 moment ...
          [newX newY] [event_title] [newdepth] [timecode]
   /x    psmeca principal axes (Not implemented yet)
   /       X Y depth T_value T_azim T_plunge N_value N_azim N_plunge P_value ...
   /       P_azim P_plunge exp [newX newY] [event_title] [newdepth] [timecode]
    m    psmeca moment tensor format
          X Y depth mrr mtt mff mrt mrf mtf exp [newX newY] [event_title] ...
          [newdepth] [timecode]

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

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    if arg_is_flag $2; then
      info_msg "[-ccat]: No catalog specified. Using default $CMT_CATALOG_TYPE."
    else
      unset CCAT_STRING
      # Everything except G, I, Z
      CUSTOMCATSTR="ABCDEFHJKLMNOPQRSTUVWXYZ"
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
            if [[ -s "${CCATARG}" ]]; then

              cmtfilenumber=$(echo "$cmtfilenumber+1" | bc)
              CCAT_LETTER[$cmtfilenumber]=${CUSTOMCATSTR:${cmtfilenumber}:1}
              CCAT_STRING=${CCAT_STRING}${CCAT_LETTER[$cmtfilenumber]}
              # Add a custom catalog file
              CMTADDFILE[$cmtfilenumber]=$(abs_path $CCATARG)

              # Custom catalogs require a format code
              CMTADDFILE_TYPE[$cmtfilenumber]="${2}"
              shift
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


  -zcat) #            [ANSS or ISC OR custom seismicity files]
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zcat:         select seismicity catalog(s) and add custom seismicity files
-zcat [catalogID1] [[catalogid2...]] [[catalogfile1...]] [[catalogfile2...]]
      [[nocull]]

  catalogID: ANSS | ISC
  catalogfile: Any file in the format lon lat depth mag [[timecode]] [[ID]] [[epoch]]

  By default, if multiple catalogs are specified, then the seismicity will be
  culled to remove likely duplicate events, with the event from the earlier
  specified catalog, or the earlier event from the same catalog, being
  retained. [[nocull]] turns off this behavior. Culled events are stored in
  ${F_SEIS}culled_seismicity.txt

Example: Plot ISC seismicity in Idaho
  tectoplot -r US.ID -t -z -zcat ISC
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
        case $ZCATARG in
          ISC)
            EQ_CATALOG_TYPE+=("ISC")
            EQ_SOURCESTRING=$ISC_EQ_SOURCESTRING
            EQ_SHORT_SOURCESTRING=$ISC_EQ_SHORT_SOURCESTRING
          ;;
          EHB)
            EQ_CATALOG_TYPE+=("EHB")
            EQ_SOURCESTRING=$ISCEHB_EQ_SOURCESTRING
            EQ_SHORT_SOURCESTRING=$ISCEHB_EQ_SHORT_SOURCESTRING
          ;;
          ANSS)
            EQ_CATALOG_TYPE+=("ANSS")
            EQ_SOURCESTRING=$ANSS_EQ_SOURCESTRING
            EQ_SHORT_SOURCESTRING=$ANSS_EQ_SHORT_SOURCESTRING
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

  -zccpt)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zcccpt:       select CPT for seismicity
-zccpt [cpt_name]

Example: None
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

  -zcolor)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zcolor:       select depth range for color cpt for seismicity
-zcolor [[mindepth=${EQMINDEPTH_COLORSCALE}]] [[maxdepth=${EQMAXDEPTH_COLORSCALE}]]

  mindepth, maxdepth are in positive down km without unit character
  Affects any data that use the seismicity depth CPT (focals, Slab2 contours,...)

Example: Plot seismicity in Costa Rica with deep yellow-blue transition
  tectoplot -r CR+R1 -a -z -zcolor 0 150
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

  -zmag)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zmag:         select magnitude range for seismicity
-zmag [[minmag=${EQ_MINMAG}]] [[maxmag=${EQ_MAXMAG}]]

Example: Plot large magnitude seismicity in Indonesia
  tectoplot -r ID -a -z -zmag 7.5 10
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

  -zline)

if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zline:        set width of seismicity symbol outline line
-zline [width=${EQLINEWIDTH}]

  width is specified with units of p [e.g. 1p]
  if width==0 | 0p, then no line will be drawn

Example: None
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
    ;;

  -znoplot)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-znoplot:      download and process seismicity but don't plot to map
-znoplot

Example: None
--------------------------------------------------------------------------------
EOF
shift && continue
fi
    dontplotseisflag=1
    ;;

  -zcsort)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-zcsort:       sort seismicity and focal mechanisms by a specified dimension
-zcsort [[dimension]] [[direction]]

  dimension: depth | time | mag    (magnitude)
  direction: up | down

Example: None
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
          TECTOPLOT_ACTIVE_MODULES+=("${this_mod}")
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


#### BEGINNING OF BOOKKEEPING SECTION

[[ $USAGEFLAG -eq 1 ]] && exit

if [[ $plotselectedfeflag -eq 1 ]]; then
  plots+=("selected-flinn-engdahl")
fi


if [[ $ADD_EQ_SOURCESTRING -eq 1 ]]; then
  echo $EQ_SOURCESTRING >> ${LONGSOURCES}
  echo $EQ_SHORT_SOURCESTRING >> ${SHORTSOURCES}
fi

# If we are asked to delete the topo for a custom region
if [[ $tdeleteflag -eq 1 && $usingcustomregionflag -eq 1 ]]; then
  info_msg "[-tdelete]: Deleting saved topo for $CUSTOMREGIONID: ( ${SAVEDTOPODIR}${CUSTOMREGIONID}.tif)"
  rm -f ${SAVEDTOPODIR}${CUSTOMREGIONID}.tif
  rm -f ${SAVEDTOPODIR}${CUSTOMREGIONID}.command
fi

# We made it to the calc/plotting sections, so record the command
echo $COMMAND > tectoplot.last

if [[ $setregionbyearthquakeflag -eq 1 ]]; then
  # This needs to be changed
  LOOK1=$(grep $REGION_EQ $FOCALCATALOG | head -n 1)
  if [[ $LOOK1 != "" ]]; then
    # echo "Found EQ region focal mechanism $REGION_EQ"
    case $CMTTYPE in
      ORIGIN)
        REGION_EQ_LON=$(echo $LOOK1 | gawk  '{print $8}')
        REGION_EQ_LAT=$(echo $LOOK1 | gawk  '{print $9}')
        ;;
      CENTROID)
        REGION_EQ_LON=$(echo $LOOK1 | gawk  '{print $5}')
        REGION_EQ_LAT=$(echo $LOOK1 | gawk  '{print $6}')
        ;;
    esac
  else
    if [[ $EQ_CATALOG_TYPE[1] =~ "ANSS" ]]; then
      echo "Looking for event ${REGION_EQ}"
      LOOK2=$(zipgrep $REGION_EQ ${ANSS_TILENEWZIP})

      if [[ $LOOK2 != "" ]]; then
        echo "Found event in new data: ${LOOK2}"
        # echo "Found EQ region hypocenter $REGION_EQ"
        REGION_EQ_LON=$(echo $LOOK2 | gawk -F, '{print $3}')
        REGION_EQ_LAT=$(echo $LOOK2 | gawk -F, '{print $2}')
        # Remove quotation marks before getting title
        PLOTTITLE="Event $REGION_EQ, $(echo $LOOK2 | gawk -F'"' -v OFS='' '{ for (i=2; i<=NF; i+=2) gsub(",", "", $i) } 1' | gawk -F, '{print $14}'), Depth=$(echo $LOOK2 | gawk -F, '{print $4}') km"
      else
        LOOK2=$(zipgrep $REGION_EQ ${ANSS_TILEOLDZIP})
        if [[ $LOOK2 != "" ]]; then
          echo "Found event in old data: ${LOOK2}"
          # echo "Found EQ region hypocenter $REGION_EQ"
          REGION_EQ_LON=$(echo $LOOK2 | gawk -F, '{print $3}')
          REGION_EQ_LAT=$(echo $LOOK2 | gawk -F, '{print $2}')
          # Remove quotation marks before getting title
          PLOTTITLE="Event $REGION_EQ, $(echo $LOOK2 | gawk -F'"' -v OFS='' '{ for (i=2; i<=NF; i+=2) gsub(",", "", $i) } 1' | gawk -F, '{print $14}'), Depth=$(echo $LOOK2 | gawk -F, '{print $4}') km"
        else
          echo "Earthquake ${REGION_EQ} not found in ANSS catalog."
          exit 1
        fi
      fi
    elif [[ $EQ_CATALOG_TYPE[1] =~ "ISC" ]]; then
      echo "ISC grep for event"
    elif [[ $EQ_CATALOG_TYPE[1] =~ "NONE" ]]; then
      echo "No EQ catalog"
    fi
  fi
  MINLON=$(echo "$REGION_EQ_LON - $EQ_REGION_WIDTH" | bc -l)
  MAXLON=$(echo "$REGION_EQ_LON + $EQ_REGION_WIDTH" | bc -l)
  MINLAT=$(echo "$REGION_EQ_LAT - $EQ_REGION_WIDTH" | bc -l)
  MAXLAT=$(echo "$REGION_EQ_LAT + $EQ_REGION_WIDTH" | bc -l)

  if [[ $(echo "${MAXLON} < ${MINLON}" | bc) -eq 1 ]]; then
    echo "Longitude range is messed up. Trying to adjust"
    MAXLON=$(echo "${MAXLON}+180" | bc -l)
  fi
  info_msg "[-r]: Earthquake centered region: $MINLON/$MAXLON/$MINLAT/$MAXLAT centered at $REGION_EQ_LON/$REGION_EQ_LAT"
fi


################################################################################
###### Calculate some sizes for the final map document based on AOI aspect ratio

LATSIZE=$(echo "$MAXLAT - $MINLAT" | bc -l)
LONSIZE=$(echo "$MAXLON - $MINLON" | bc -l)

CENTERLON=$(echo "($MINLON + $MAXLON) / 2" | bc -l)
CENTERLAT=$(echo "($MINLAT + $MAXLAT) / 2" | bc -l)

if [[ ! $usecustomrjflag -eq 1 ]]; then
  rj+=("-R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}")
  rj+=("-JQ${CENTERLON}/${PSSIZE}i")
  RJSTRING="${rj[@]}"
  # echo "Basic RJSTRING is $RJSTRING"
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

if [[ $MAKERECTMAP -eq 1 && ${rj[0]} == -R* && ${rj[1]} == -J* ]]; then
  rj[0]="-R${MINLON}/${MINLAT}/${MAXLON}/${MAXLAT}r"
  RJSTRING="${rj[@]}"
fi
# We have to set the RJ flag after setting the plot size (INCH)

if [[ $setutmrjstringfromarrayflag -eq 1 ]]; then

  if [[ $calcutmzonelaterflag -eq 1 ]]; then
    # This breaks terribly if the average longitude is not between -180 and 180
    UCENTERLON=$(gmt mapproject -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} -WjCM ${VERBOSE} | gawk '{print $1}')
    AVELONp180o6=$(echo "(($UCENTERLON) + 180)/6" | bc -l)
    UTMZONE=$(echo $AVELONp180o6 1 | gawk  '{val=int($1)+($1>int($1)); print (val>0)?val:1}')
  fi
  info_msg "Using UTM Zone $UTMZONE"


  if [[ $MAKERECTMAP -eq 1 ]]; then
    rj[1]="-R${MINLON}/${MINLAT}/${MAXLON}/${MAXLAT}r"
    rj[2]="-JU${UTMZONE}/${INCH}i"
    RJSTRING="${rj[@]}"

    # echo "Making map outline"
    # echo     gmt psbasemap -A $RJSTRING ${VERBOSE}

    gmt psbasemap -A $RJSTRING ${VERBOSE} | grep -v "#" > mapoutline.txt
    MINLONNEW=$(gawk < mapoutline.txt 'BEGIN {getline;min=$1} NF { min=(min>$1)?$1:min } END{print min}')
    MAXLONNEW=$(gawk < mapoutline.txt 'BEGIN {getline;max=$1} NF { max=(max>$1)?max:$1 } END{print max}')
    MINLATNEW=$(gawk < mapoutline.txt 'BEGIN {getline;min=$2} NF { min=(min>$2)?$2:min } END{print min}')
    MAXLATNEW=$(gawk < mapoutline.txt 'BEGIN {getline;max=$2} NF { max=(max>$2)?max:$2} END{print max}')
    info_msg "Updating AOI from ${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} to ${MINLONNEW}/${MAXLONNEW}/${MINLATNEW}/${MAXLATNEW}"
    MINLON=$MINLONNEW
    MAXLON=$MAXLONNEW
    MINLAT=$MINLATNEW
    MAXLAT=$MAXLATNEW

  else
    rj[1]="-R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}"
    rj[2]="-JU${UTMZONE}/${INCH}i"
  fi
  rj[2]="-JU${UTMZONE}/${INCH}i"
  RJSTRING="${rj[@]}"
  info_msg "[-RJ]: Custom region and projection string is: ${RJSTRING[@]}"
fi


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
    }' | gmt gmtselect ${RJSTRING[@]} ${VERBOSE} | gawk '{ if ($1>180) { $1=$1-360 } else if ($1<-180) { $1=$1+360}; print }'> selectbounds.txt

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

echo ${MINLON} ${MAXLAT}> ${TMP}${F_MAPELEMENTS}bounds.txt
echo ${MAXLON} ${MAXLAT}>> ${TMP}${F_MAPELEMENTS}bounds.txt
echo ${MAXLON} ${MINLAT}>> ${TMP}${F_MAPELEMENTS}bounds.txt
echo ${MINLON} ${MINLAT}>> ${TMP}${F_MAPELEMENTS}bounds.txt
echo ${MINLON} ${MAXLAT}>> ${TMP}${F_MAPELEMENTS}bounds.txt

#
# # The reason to do this is because our -R/// string needs to change based on
# # various earlier settings, so we need to update MINLON/MAXLON/MINLAT/MAXLAT
#
# if [[ $recalcregionflag_lonlat -eq 1 ]]; then
#
#     NEWRANGETL=($(gmt mapproject ${RJSTRING[@]} -WjTL ${VERBOSE}))
#     NEWRANGETR=($(gmt mapproject ${RJSTRING[@]} -WjTR ${VERBOSE}))
#     NEWRANGEBL=($(gmt mapproject ${RJSTRING[@]} -WjBL ${VERBOSE}))
#     NEWRANGEBR=($(gmt mapproject ${RJSTRING[@]} -WjBR ${VERBOSE}))
#     # NEWRANGECM=($(gmt mapproject ${RJSTRING[@]} -WjCM ${VERBOSE}))
#
#     # echo "TL: ${NEWRANGETL[@]}"
#     # echo "BR: ${NEWRANGEBR[@]}"
#     # echo "CM: ${NEWRANGECM[@]}"
#
#     NEWRANGE=($(echo ${NEWRANGETL[0]} ${NEWRANGEBR[0]} ${NEWRANGEBR[1]} ${NEWRANGETL[1]}))
#     info_msg "mapproject points method: Suggested updated range is: ${NEWRANGE[0]}/${NEWRANGE[1]}/${NEWRANGE[2]}/${NEWRANGE[3]}"
#
#     # # Only adopt the new range if the max/min values are numbers and their order is OK
#     usenewrange=1
#     if [[ ${NEWRANGE[0]} =~ "NaN" || ${NEWRANGE[1]} =~ "NaN" || ${NEWRANGE[2]} =~ "NaN" || ${NEWRANGE[3]} =~ "NaN" ]]; then
#       info_msg "recalcregion: The corner method has NaN outputs. Try the bounds method."
#       recalcregionflag_bounds=1
#
#     fi
#     # [[ ${NEWRANGE[1]} =~ ^[-+]?[0-9]*.*[0-9]+$ ]] || usenewrange=0
#     # [[ ${NEWRANGE[2]} =~ ^[-+]?[0-9]*.*[0-9]+$ ]] || usenewrange=0
#     # [[ ${NEWRANGE[3]} =~ ^[-+]?[0-9]*.*[0-9]+$ ]] || usenewrange=0
#     # # [[ $(echo "${NEWRANGE[0]} < ${NEWRANGE[1]}" | bc -l) -eq 1 ]] || usenewrange=0
#     # # [[ $(echo "${NEWRANGE[2]} < ${NEWRANGE[3]}" | bc -l) -eq 1 ]] || usenewrange=0
#
#     # This newrange needs to take into account longitudes below -180 and above 180...
#
#     if [[ $usenewrange -eq 1 ]]; then
#       info_msg "Updating AOI to new map extent: ${NEWRANGE[0]}/${NEWRANGE[1]}/${NEWRANGE[2]}/${NEWRANGE[3]}"
#       MINLON=${NEWRANGE[0]}
#       MAXLON=${NEWRANGE[1]}
#       MINLAT=${NEWRANGE[2]}
#       MAXLAT=${NEWRANGE[3]}
#     else
#       info_msg "Could not update AOI based on map extent."
#     fi
# fi
#

# This section is needed to make the circular AOI for e.g. stereographic maps with a given horizon.
# Not yet implemented

if [[ $recalcregionflag_circle -eq 1 ]]; then
  echo "Trying to make AOI bounds.txt using gmt project"
  # COMEBACK
fi


# If we read the RJ string from the custom regions file, set it here before we
# determine the bounding box and projected bounding box

if [[ $usecustomregionrjstringflag -eq 1 ]]; then
  unset RJSTRING
  ind=0
  while ! [[ -z ${CUSTOMREGIONRJSTRING[$ind]} ]]; do
    RJSTRING+=("${CUSTOMREGIONRJSTRING[$ind]}")
    ind=$(echo "$ind+1" | bc)
  done
  info_msg "[-r]: Using customID RJSTRING: ${RJSTRING[@]}"
fi

# This section is needed to determine the region and bounding box for oblique Mercator type projections
# Not yet tested for maps crossing the dateline!

if [[ $boundboxfrompsbasemapflag -eq 1 || $recalcregionflag_bounds -eq 1 ]]; then
  gmt psbasemap ${RJSTRING[@]} -A ${VERBOSE} | gawk '
    ($1!="NaN") {
      while ($1>180) { $1=$1-360 }
      while ($1<-180) { $1=$1+360 }
      if ($1==($1+0) && $2==($2+0)) {
        print
      }
    }' > ${TMP}${F_MAPELEMENTS}bounds.txt
fi

if [[ $recalcregionflag_bounds -eq 1 ]]; then

    # Recalculate the bounding box using RJSTRING; this replaces the MINLON/MAXLON/MINLAT/MAXLAT bounding box

    # Calculate the range in longitude and latitude in order to set MINLON...etc

    # Split the polygon across the dateline if necessary - xy_range should still work!
    gmt spatial -Ss ${TMP}${F_MAPELEMENTS}bounds.txt > ${TMP}${F_MAPELEMENTS}ss_bounds.txt

    NEWRANGE=($(xy_range ${TMP}${F_MAPELEMENTS}ss_bounds.txt))

    # We need to account for boundary box crossing the dateline here.


    info_msg "Bounds method: Suggested updated range is: ${NEWRANGE[0]}/${NEWRANGE[1]}/${NEWRANGE[2]}/${NEWRANGE[3]}"

    # # Only adopt the new range if the max/min values are numbers and their order is OK
    usenewrange=1
    [[ ${NEWRANGE[0]} =~ "NaN" || ${NEWRANGE[1]} =~ "NaN" || ${NEWRANGE[2]} =~ "NaN" || ${NEWRANGE[3]} =~ "NaN" ]] && usenewrange=0

    # Outdated rules... not used
    # [[ ${NEWRANGE[0]} =~ ^[-+]?[0-9]*.*[0-9]+$ ]] || usenewrange=0
    # [[ ${NEWRANGE[1]} =~ ^[-+]?[0-9]*.*[0-9]+$ ]] || usenewrange=0
    # [[ ${NEWRANGE[2]} =~ ^[-+]?[0-9]*.*[0-9]+$ ]] || usenewrange=0
    # [[ ${NEWRANGE[3]} =~ ^[-+]?[0-9]*.*[0-9]+$ ]] || usenewrange=0
    # # [[ $(echo "${NEWRANGE[0]} < ${NEWRANGE[1]}" | bc -l) -eq 1 ]] || usenewrange=0
    # # [[ $(echo "${NEWRANGE[2]} < ${NEWRANGE[3]}" | bc -l) -eq 1 ]] || usenewrange=0

    # Not sure what happens if we cross the dateline...

    if [[ $usenewrange -eq 1 ]]; then
      info_msg "Updating AOI to new map extent: ${NEWRANGE[0]}/${NEWRANGE[1]}/${NEWRANGE[2]}/${NEWRANGE[3]}"
      MINLON=${NEWRANGE[0]}
      MAXLON=${NEWRANGE[1]}
      MINLAT=${NEWRANGE[2]}
      MAXLAT=${NEWRANGE[3]}

    else
      info_msg "Could not update AOI based on map extent."
    fi
fi

# Find the center point of the map

NEWRANGECM=($(gmt mapproject ${RJSTRING[@]} -WjCM ${VERBOSE}))
CENTERLON=${NEWRANGECM[0]}
CENTERLAT=${NEWRANGECM[1]}

info_msg "RJSTRING: ${RJSTRING[@]}; CENTERLON/CENTERLAT=${CENTERLON}/${CENTERLAT} MINLON/MAXLON/MINLAT/MAXLAT= ${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT}"

# Convert the bounding box to projected coordinates

gmt mapproject ${TMP}${F_MAPELEMENTS}bounds.txt ${RJSTRING[@]} ${VERBOSE} > ${TMP}${F_MAPELEMENTS}projbounds.txt

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
  echo "${REGIONTOADD} ${MINLON} ${MAXLON} ${MINLAT} ${MAXLAT} ${RJSTRING[@]}" >> ./regions.tmp
  mv ./regions.tmp ${CUSTOMREGIONS}
  cp ${TMP}${F_MAPELEMENTS}bounds.txt ${CUSTOMREGIONSDIR}${REGIONTOADD}.xy
fi


# Move the data source files into the temporary directory

[[ -e ${LONGSOURCES} ]] && mv ${LONGSOURCES} ${TMP}
[[ -e ${SHORTSOURCES} ]] && mv ${SHORTSOURCES} ${TMP}

if [[ $overplotflag -eq 1 ]]; then
   info_msg "[-ips]: Moving copy basemap postscript file into temporary directory"
   mv "${THISDIR}"/tmpmap.ps "${TMP}map.ps"
fi

cd "${TMP}"

echo "${RJSTRING[@]}" > ${F_MAPELEMENTS}rjstring.txt

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

# Determine the range of projected coordinates for the bounding box and save them
XYRANGE=($(xy_range ${F_MAPELEMENTS}projbounds.txt))
echo ${XYRANGE[@]} > ${F_MAPELEMENTS}projxyrange.txt

MINPROJ_X=${XYRANGE[0]}
MAXPROJ_X=${XYRANGE[1]}
MINPROJ_Y=${XYRANGE[2]}
MAXPROJ_Y=${XYRANGE[3]}


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
gmt mapproject ${F_MAPELEMENTS}aprof_database_proj.txt ${RJSTRING[@]} -I ${VERBOSE} | tr '\t' ' ' | gawk '($1!="NaN"){print}' > ${F_MAPELEMENTS}aprof_database.txt

# Extract the aprof list to make the profiles
for code in ${aproflist[@]}; do
  p1=($(grep "[${code:0:1}]" ${F_MAPELEMENTS}aprof_database.txt))
  p2=($(grep "[${code:1:1}]" ${F_MAPELEMENTS}aprof_database.txt))
  if [[ ${#p1[@]} -eq 3 && ${#p2[@]} -eq 3 ]]; then
    echo "P P_${code} black 0 N ${p1[0]} ${p1[1]} ${p2[0]} ${p2[1]}" >> ${F_PROFILES}aprof_profs.txt
  fi
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
      echo $CPLON $CPLAT > inpoint.file
      cleanup inpoint.file
      for slabcfile in $(ls -1a ${SLAB2_CLIPDIR}*.csv); do
        # echo "Looking at file $slabcfile"
        gawk < $slabcfile '{
          if ($1 > 180) {
            print $1-360, $2
          } else {
            print $1, $2
          }
        }' > tmpslabfile.dat
        numinregion=$(gmt select inpoint.file -Ftmpslabfile.dat ${VERBOSE} | wc -l)
        if [[ $numinregion -ge 1 ]]; then
          numslab2inregion=$(echo "$numslab2inregion+1" | bc)
          slab2inregion[$numslab2inregion]=$(basename -s .csv $slabcfile)
        fi
      done
      if [[ $numslab2inregion -eq 0 ]]; then
        info_msg "[-b]: No slabs beneath the CPROF point. Using default azimuth of 90 degrees."
        CPAZ=90
      else
        for i in $(seq 1 $numslab2inregion); do
          info_msg "[-b]: Found slab2 slab ${slab2inregion[$i]} beneath the CPROF point. Querying strike raster"
          gridfile=$(echo ${SLAB2_GRIDDIR}${slab2inregion[$i]}.grd | sed 's/clp/str/')
          # Query the grid file at the profile center location, add 90 degrees to get cross-strike profile
          CPAZ=$(echo "${CPLON} ${CPLAT}" | gmt grdtrack -G$gridfile ${VERBOSE} | gawk '{print $3 + 90}')
        done
      fi
   fi

   ANTIAZ=$(echo "${CPAZ}" | bc -l)
   FOREAZ=$(echo "${CPAZ}+180" | bc -l)

   POINT1=($(gmt project -C${CPLON}/${CPLAT} -A${FOREAZ} -Q -G${CPHALFLEN}k -L0/${CPHALFLEN} ${VERBOSE} | tail -n 1 | gawk  '{print $1, $2}'))
   POINT2=($(gmt project -C${CPLON}/${CPLAT} -A${ANTIAZ} -Q -G${CPHALFLEN}k -L0/${CPHALFLEN} ${VERBOSE} | tail -n 1 | gawk  '{print $1, $2}'))

   echo "P C_${cprofnum} black 0 N ${POINT1[0]} ${POINT1[1]} ${POINT2[0]} ${POINT2[1]}" >> ${F_PROFILES}cprof_profs.txt
   cprofnum=$(echo "${cprofnum} + 1" | bc)

   info_msg "[-cprof]: Added profile ${CPLON}/${CPLAT}/${CPROFAZ}/${CPHALFLEN}; Updated width/res to ${SPROFWIDTH}/${SPROF_RES}"

  done < ${F_PROFILES}cprof_prep.txt
fi

# Build kprof profiles

if [[ $kprofflag -eq 1 ]]; then
  if [[ ${KPROFFILE} =~ ".kml" ]]; then
    info_msg "[-kprof]: KML file specified for XY file. Converting lines to XY format."
    ogr2ogr -f "OGR_GMT" ${F_PROFILES}kprof_profiles.gmt ${KPROFFILE}
    gawk < ${F_PROFILES}kprof_profiles.gmt -v align=${PROFILE_ALIGNZ} '
      BEGIN {
        count=0
      }
      ($1==">") {
        count++
        if (count>1) {
          printf("\n")
        }
        printf("P P_%d black 0 %s ", count, align)
      }
      ($1+0==$1) {
        printf("%f %f ", $1, $2)
      }
      END {
        printf("\n")
      }' >> ${F_PROFILES}kprof_profs.txt
  fi
fi


################################################################################
#####          Manage grid spacing and style                               #####
################################################################################

##### Create the grid of lat/lon points to resolve as plate motion vectors
# Default is a lat/lon spaced grid

##### MAKE FIBONACCI GRID POINTS
if [[ $gridfibonacciflag -eq 1 ]]; then
  FIB_PHI=1.618033988749895

  echo "" | gawk  -v n=$FIB_N  -v minlat="$MINLAT" -v maxlat="$MAXLAT" -v minlon="$MINLON" -v maxlon="$MAXLON" '
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
##### Check if the reference point is within the data frame

if [[ $(echo "$REFPTLAT > $MINLAT && $REFPTLAT < $MAXLAT && $REFPTLON < $MAXLON && $REFPTLON > $MINLON" | bc -l) -eq 0 ]]; then
  info_msg "Reference point $REFPTLON $REFPTLAT falls outside the frame. Moving to center of frame."
	REFPTLAT=$(echo "($MINLAT + $MAXLAT) / 2" | bc -l)
	REFPTLON=$(echo "($MINLON + $MAXLON) / 2" | bc -l)
  info_msg "Reference point moved to $REFPTLON $REFPTLAT"
fi


GRIDSP=$(echo "($MAXLON - $MINLON)/6" | bc -l)

info_msg "Initial grid spacing = $GRIDSP"

if [[ $(echo "$GRIDSP > 30" | bc) -eq 1 ]]; then
  GRIDSP=30
elif [[ $(echo "$GRIDSP > 10" | bc) -eq 1 ]]; then
  GRIDSP=10
elif [[ $(echo "$GRIDSP > 5" | bc) -eq 1 ]]; then
	GRIDSP=5
elif [[ $(echo "$GRIDSP > 2" | bc) -eq 1 ]]; then
	GRIDSP=2
elif [[ $(echo "$GRIDSP > 1" | bc) -eq 1 ]]; then
	GRIDSP=1
elif [[ $(echo "$GRIDSP > 0.5" | bc) -eq 1 ]]; then
	GRIDSP=0.5
elif [[ $(echo "$GRIDSP > 0.2" | bc) -eq 1 ]]; then
	GRIDSP=0.2
elif [[ $(echo "$GRIDSP > 0.1" | bc) -eq 1 ]]; then
	GRIDSP=0.1
elif [[ $(echo "$GRIDSP > 0.05" | bc) -eq 1 ]]; then
  GRIDSP=0.05
elif [[ $(echo "$GRIDSP > 0.02" | bc) -eq 1 ]]; then
  GRIDSP=0.02
elif [[ $(echo "$GRIDSP > 0.01" | bc) -eq 1 ]]; then
  GRIDSP=0.01
else
	GRIDSP=0.005
fi

info_msg "updated grid spacing = $GRIDSP"

if [[ $overridegridlinespacing -eq 1 ]]; then
  GRIDSP=$OVERRIDEGRID
  info_msg "Override spacing of map grid is $GRIDSP"
fi

if [[ $GRIDLINESON -eq 1 ]]; then
  GRIDSP_LINE="g${GRIDSP}"
else
  GRIDSP_LINE=""
fi

# DEFINE BSTRING

if [[ $PLOTTITLE == "" ]]; then
  TITLE=""
else
  TITLE="+t\"${PLOTTITLE}\""
fi
if [[ $usecustombflag -eq 0 ]]; then
  bcmds+=("-Bxa${GRIDSP}${GRIDSP_LINE}")
  bcmds+=("-Bya${GRIDSP}${GRIDSP_LINE}")
  bcmds+=("-B${GRIDCALL}")
  # bcmds+=("-B${GRIDCALL}${TITLE}")
  BSTRING=("${bcmds[@]}")
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

#### END OF BOOKKEEPING SECTION

#### BEGIN DATA PROCESSING SECTION

# GRAVITY CLIP

if [[ $clipgravflag -eq 1 ]]; then
  gmt grdcut $GRAVDATA -G${F_GRAV}grav.nc -R -J $VERBOSE
fi

################################################################################
#####         Download Sentinel image                                      #####
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

  SENT_FNAME="sentinel_${SENTINEL_TYPE}_${MINLON}_${MAXLON}_${MINLAT}_${MAXLAT}_${SENT_XRES}_${SENT_YRES}.tif"

  if ! [[ -d ${SENT_DIR} ]]; then
    mkdir -p ${SENT_DIR}
  fi

  if [[ -e ${SENT_DIR}${SENT_FNAME} ]]; then
    info_msg "Sentinel imagery $SENT_FNAME exists. Not redownloading."
    cp ${SENT_DIR}${SENT_FNAME} sentinel.tif
  else

    curl "https://tiles.maps.eox.at/wms?service=wms&request=getmap&version=1.1.1&layers=${SENTINEL_TYPE}&bbox=${MINLON},${MINLAT},${MAXLON},${MAXLAT}&width=$SENT_XRES&height=$SENT_YRES&srs=epsg:4326" > sentinel.jpg

    # Create world file for JPG
    echo "$LONDIFF / $SENT_XRES" | bc -l > sentinel.jgw
    echo "0" >> sentinel.jgw
    echo "0" >> sentinel.jgw
    echo "- (${LATDIFF}) / $SENT_YRES" | bc -l >> sentinel.jgw
    echo "$MINLON" >> sentinel.jgw
    echo "$MAXLAT" >> sentinel.jgw
    echo gdal_translate -projwin ${MINLON} ${MAXLAT} ${MAXLON} ${MINLAT} -of GTiff sentinel.jpg sentinel.tif
    gdal_translate -projwin ${MINLON} ${MAXLAT} ${MAXLON} ${MINLAT} -of GTiff sentinel.jpg sentinel.tif
    cp sentinel.tif ${SENT_DIR}${SENT_FNAME}
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
  for slabcfile in $(ls -1a ${SLAB2_CLIPDIR}*.csv); do
    # echo "Looking at file $slabcfile"
    # gawk <  '{
    #   if ($1 > 180) {
    #     print $1-360, $2
    #   } else {
    #     print $1, $2
    #   }
    # }' > tmpslabfile.dat

    gawk < $slabcfile '
      BEGIN {
        found_m180=0
        found_180=0
        getline
        if ($1 > 180) {
          $1=$1-360
        }
        minlon=$1
        maxlon=$1
        minlat=$2
        maxlat=$2
        maxneglon=-180
        minposlon=180
        lon[NR]=$1
        lat[NR]=$1
      }
      {
        if ($1 > 180) {
          $1=$1-360
        }
        minlon=($1<minlon)?$1:minlon
        maxlon=($1>maxlon)?$1:maxlon
        minlat=($2<minlat)?$2:minlat
        maxlat=($2>maxlat)?$2:maxlat
        maxneglon=($1>maxneglon && $1<=0)?$1:maxneglon
        minposlon=($1<minposlon && $1>=0)?$1:minposlon

        foundlon[$1]=1
        lon[NR]=$1
        lat[NR]=$2
      }
      END {

        # print "minlon/maxlon/minlat/maxlat", minlon, maxlon, minlat, maxlat > "/dev/stderr"
        # print "maxneglon/minposlon", maxneglon, minposlon > "/dev/stderr"
        if (maxneglon < -140 && minposlon > 140) {
#            print "Detected non-global longitude range crossing antimeridian"  > "/dev/stderr"
            adjustlon=1
            maxneglon+=360
        } else {
#          print "Detected reasonable longitude range"  > "/dev/stderr"
        }

      }
      END {
        for(i=1;i<=NR;i++) {
          if (lon[i]<0) {
            print lon[i]+adjustlon*360, lat[i]
          } else {
            print lon[i], lat[i]
          }
        }
      }' > new_tmpslabfile.dat


    # echo gmt select tmpslabfile.dat -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} ${VERBOSE}
    # gmt select new_tmpslabfile.dat -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} ${VERBOSE}
    numinregion=$(gmt select new_tmpslabfile.dat -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} ${VERBOSE} | wc -l)
    # echo $numinregion
    if [[ $numinregion -ge 1 ]]; then
      numslab2inregion=$(echo "$numslab2inregion+1" | bc)
      slab2inregion[$numslab2inregion]=$(basename -s .csv $slabcfile)
      # echo added ${slab2inregion[$numslab2inregion]}
    else

      # If the slab wasn't selected above, try another approach
      # This is intended to select slabs when the view is so close that we don't
      # encompass any of the edge points. But it is breaking for some reason, likely
      # due to projection issues or longitude range issues
      numinregion=$(gmt select inpoint.file -Fnew_tmpslabfile.dat ${VERBOSE} | wc -l)

      # echo $numinregion
      if [[ $numinregion -eq 1 ]]; then

        numslab2inregion=$(echo "$numslab2inregion+1" | bc)
        # echo added x ${slab2inregion[$numslab2inregion]}

        slab2inregion[$numslab2inregion]=$(basename -s .csv $slabcfile)
      fi
    fi
  done
  if [[ $numslab2inregion -eq 0 ]]; then
    info_msg "[-b]: No slabs within AOI"
  else
    for i in $(seq 1 $numslab2inregion); do
      info_msg "[-b]: Found slab2 slab ${slab2inregion[$i]}"
      echo ${slab2inregion[i]} | cut -f 1 -d '_' > ${F_SLAB}"slab_ids.txt"
    done
  fi
fi

################################################################################
#####          Manage topography/bathymetry data                           #####
################################################################################

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
  info_msg "Making basemap $BATHYMETRY"

  if [[ $besttopoflag -eq 1 ]]; then
    bestname=$BESTDIR"best_${DEM_MINLON}_${DEM_MAXLON}_${DEM_MINLAT}_${DEM_MAXLAT}.nc"
    if [[ -e $bestname ]]; then
      info_msg "Best topography already exists."
      BATHY=$bestname
      bestexistsflag=1
      demiscutflag=1
    fi
  fi

  if [[ $BATHYMETRY =~ "GMRT" || $besttopoflag -eq 1 && $bestexistsflag -eq 0 ]]; then   # We manage GMRT tiling ourselves

    minlon360=$(echo $DEM_MINLON | gawk  '{ if ($1<0) {print $1+360} else {print $1} }')
    maxlon360=$(echo $DEM_MAXLON | gawk  '{ if ($1<0) {print $1+360} else {print $1} }')

    minlonfloor=$(echo $minlon360 | cut -f1 -d".")
    maxlonfloor=$(echo $maxlon360 | cut -f1 -d".")

    if [[ $(echo "$DEM_MINLAT < 0" | bc -l) -eq 1 ]]; then
      minlatfloor1=$(echo $DEM_MINLAT | cut -f1 -d".")
      minlatfloor=$(echo "$minlatfloor1 - 1" | bc)
    else
      minlatfloor=$(echo $DEM_MINLAT | cut -f1 -d".")
    fi

    maxlatfloor=$(echo $DEM_MAXLAT | cut -f1 -d".")
    maxlatceil=$(echo "$maxlatfloor + 1" | bc)

    #echo $MINLON $MAXLON "->" $minlonfloor $maxlonfloor
    #echo $MINLAT $MAXLAT "->" $minlatfloor $maxlatfloor

    maxlonceil=$(echo "$maxlonfloor + 1" | bc)

    if [[ $(echo "$minlonfloor > 180" | bc) -eq 1 ]]; then
      minlonfloor=$(echo "$minlonfloor-360" | bc -l)
    fi
    if [[ $(echo "$maxlonfloor > 180" | bc) -eq 1 ]]; then
      maxlonfloor=$(echo "$maxlonfloor-360" | bc -l)
      maxlonceil=$(echo "$maxlonfloor + 1" | bc)
    fi

    # How many tiles is this?
    GMRTTILENUM=$(echo "($maxlonfloor - $minlonfloor + 1) * ($maxlatfloor - $minlatfloor + 1)" | bc)
    tilecount=1
    for i in $(seq $minlonfloor $maxlonfloor); do
      for j in $(seq $minlatfloor $maxlatfloor); do
        iplus=$(echo "$i + 1" | bc)
        jplus=$(echo "$j + 1" | bc)
        if [[ ! -e $GMRTDIR"GMRT_${i}_${iplus}_${j}_${jplus}.nc" ]]; then

          info_msg "Downloading GMRT_${i}_${iplus}_${j}_${jplus}.nc ($tilecount out of $GMRTTILENUM)"
          curl "https://www.gmrt.org:443/services/GridServer?minlongitude=${i}&maxlongitude=${iplus}&minlatitude=${j}&maxlatitude=${jplus}&format=netcdf&resolution=max&layer=topo" > $GMRTDIR"GMRT_${i}_${iplus}_${j}_${jplus}.nc"
          # We have to set the coordinate system information ourselves
          # This command was for when we downloaded GeoTiff tiles and is no longer needed (we get NC now)
          # gdal_edit.py -a_srs "+proj=longlat +datum=WGS84 +no_defs" $GMRTDIR"GMRT_${i}_${iplus}_${j}_${jplus}.tif"
          #
          # Test whether the file was correctly downloaded
          fsize=$(wc -c < $GMRTDIR"GMRT_${i}_${iplus}_${j}_${jplus}.nc")
          if [[ $(echo "$fsize < 12000000" | bc) -eq 1 ]]; then
            info_msg "File GMRT_${i}_${iplus}_${j}_${jplus}.nc was not properly downloaded: too small ($fsize bytes). Removing."
            rm -f $GMRTDIR"GMRT_${i}_${iplus}_${j}_${jplus}.nc"
          fi

        else
          info_msg "File GMRT_${i}_${iplus}_${j}_${jplus}.nc exists ($tilecount out of $GMRTTILENUM)"
        fi
        filelist+=($GMRTDIR"GMRT_${i}_${iplus}_${j}_${jplus}.nc")
        tilecount=$(echo "$tilecount + 1" | bc)
      done
    done

    # We apparently need to fill NaNs when making the GMRT mosaic grid with gdal_merge.py...
    if [[ ! -e $GMRTDIR"GMRT_${minlonfloor}_${maxlonceil}_${minlatfloor}_${maxlatceil}.nc" ]]; then
      info_msg "Merging tiles to form GMRT_${minlonfloor}_${maxlonceil}_${minlatfloor}_${maxlatceil}.nc: " ${filelist[@]}
      echo gdal_merge.py -o tmp.nc -of "NetCDF" ${filelist[@]} -q > ./merge.sh
      echo gdal_fillnodata.py  -of NetCDF tmp.nc $GMRTDIR"GMRT_${minlonfloor}_${maxlonceil}_${minlatfloor}_${maxlatceil}.nc" >> ./merge.sh
      echo rm -f ./tmp.nc >> ./merge.sh
      . ./merge.sh
      # gdal_merge.py -o $GMRTDIR"GMRT_${minlonfloor}_${maxlonceil}_${minlatfloor}_${maxlatceil}.nc" ${filelist[@]}

    else
      info_msg "GMRT_${minlonfloor}_${maxlonceil}_${minlatfloor}_${maxlatceil}.nc exists"
    fi
    name=$GMRTDIR"GMRT_${minlonfloor}_${maxlonceil}_${minlatfloor}_${maxlatceil}.nc"

    if [[ $BATHYMETRY =~ "GMRT" ]]; then
      BATHY=$name
    elif [[ $besttopoflag -eq 1 ]]; then
      NEGBATHYGRID=$name
    fi
  fi

  if [[ ! $BATHYMETRY =~ "GMRT" && $bestexistsflag -eq 0 ]]; then

    if [[ $plotcustomtopo -eq 1 ]]; then
      name="${F_TOPO}dem.nc"
      info_msg "[-t]: Using custom topography file ${GRIDFILE}"
      if [[ $reprojecttopoflag -eq 1 ]]; then
        info_msg "[-t]: reprojecting source file to WGS1984"
        gdalwarp ${GRIDFILE} ${F_TOPO}custom_wgs.nc -q -of "NetCDF" -t_srs "+proj=longlat +ellps=WGS84"
        GRIDFILE=$(abs_path ${F_TOPO}custom_wgs.nc)
      fi
    # gmt grdcut sometimes does strange things with DEMs...
      info_msg "gdal_translate -of "NetCDF" -projwin ${DEM_MINLON} ${DEM_MAXLAT} ${DEM_MAXLON} ${DEM_MINLAT} ${GRIDFILE} ${name}"
      gdal_translate -of "NetCDF" -projwin ${DEM_MINLON} ${DEM_MAXLAT} ${DEM_MAXLON} ${DEM_MINLAT} ${GRIDFILE} ${name}
  #    gmt grdcut ${GRIDFILE} -G${name} -R${DEM_MINLON}/${DEM_MAXLON}/${DEM_MINLAT}/${DEM_MAXLAT} $VERBOSE
      BATHY=$name
    else
      info_msg "[-t]: Using grid file $GRIDFILE"

      # Output is a NetCDF format grid
    	name=$GRIDDIR"${BATHYMETRY}_${DEM_MINLON}_${DEM_MAXLON}_${DEM_MINLAT}_${DEM_MAXLAT}.nc"

    	if [[ -e $name ]]; then
    		info_msg "DEM file $name already exists"
        demiscutflag=1
    	else
        case $BATHYMETRY in
          SRTM30|GEBCO20|GEBCO1|01d|30m|20m|15m|10m|06m|05m|04m|03m|02m|01m|15s|03s|01s)
          gmt grdcut ${GRIDFILE} -G${name} -R${DEM_MINLON}/${DEM_MAXLON}/${DEM_MINLAT}/${DEM_MAXLAT} $VERBOSE
          demiscutflag=1
          ;;
        esac
    	fi
    	BATHY=$name
    fi
  fi
fi

# At this point, if best topo flag is set, combine POSBATHYGRID and BATHY into one grid and make it the new BATHY grid

if [[ $besttopoflag -eq 1 && $bestexistsflag -eq 0 ]]; then
  info_msg "Combining GMRT ($NEGBATHYGRID) and 01s ($BATHY) grids to form best topo grid"
  # grdsample might return NaN?
  # gmt grdsample -R$MINLON/$MAXLON/$MINLAT/$MAXLAT -I2s $NEGBATHYGRID -Gneg.nc -fg ${VERBOSE}
  gdalwarp -q -dstnodata NaN -te $MINLON $MINLAT $MAXLON $MAXLAT -tr .00055555555 .00055555555 -of NetCDF $NEGBATHYGRID neggdal.nc
  gdalwarp -q -dstnodata NaN -te $MINLON $MINLAT $MAXLON $MAXLAT -tr .00055555555 .00055555555 -of NetCDF $BATHY posgdal.nc
  gdal_calc.py --overwrite --type=Float32 --format=NetCDF --quiet -A posgdal.nc -B neggdal.nc --calc="((A>=0)*A + (B<=0)*B)" --outfile=merged.nc
  # gmt grdsample -Rneg.nc $BATHY -Gpos.nc -fg ${VERBOSE}
  # gmt grdclip -Sb0/0 pos.nc -Gposclip.nc ${VERBOSE}
  # gmt grdclip -Si0/10000000/0 neg.nc -Gnegclip.nc ${VERBOSE}
  # gmt grdmath posclip.nc negclip.nc ADD = merged.nc ${VERBOSE}
  mv merged.nc $bestname
  BATHY=$bestname
fi

if [[ $tflatflag -eq 1 ]]; then
  clipdemflag=1
fi

if [[ $clipdemflag -eq 1 && -e $BATHY ]]; then
  info_msg "[-clipdem]: saving DEM as ${F_TOPO}dem.nc"
  if [[ $demiscutflag -eq 1 ]]; then
    if [[ $tflatflag -eq 1 ]]; then
      flatten_sea ${BATHY} ${F_TOPO}dem.nc -1
    else
      cp $BATHY ${F_TOPO}dem.nc
    fi
  else
    if [[ $tflatflag -eq 1 ]]; then
      gmt grdcut ${BATHY} -G${F_TOPO}dem_preflat.nc -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} $VERBOSE
      flatten_sea ${F_TOPO}dem_preflat.nc ${F_TOPO}dem.nc -1
      cleanup ${F_TOPO}dem_preflat.nc
    else
      # echo gmt grdcut ${BATHY} -G${F_TOPO}dem.nc -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} $VERBOSE
      gmt grdcut ${BATHY} -G${F_TOPO}dem.nc -R${MINLON}/${MAXLON}/${MINLAT}/${MAXLAT} $VERBOSE
    fi
  fi
fi

# If the grid has longitudes greater than 180 or less than -180, shift it into the -180:180 range.
# This happens for some GMT EarthRelief DEMs for rotated globes

# This might still be necessary for some plots but messes up plots crossing the dateline!!!
# Leaving here for now in case the issue arises again

# if [[ -e ${F_TOPO}dem.nc ]]; then
#   GRDINFO=($(gmt grdinfo -C ${F_TOPO}dem.nc ${VERBOSE}))
#   GRDMINLON=${GRDINFO[1]}
#   GRDMAXLON=${GRDINFO[2]}
#
#   if [[ $(echo "(${GRDINFO[1]} < -180) || (${GRDINFO[2]} > 180)" | bc ) -eq 1 ]]; then
#     info_msg "Topo raster has coordinates outside of [-180:180] range. Rotating."
#     XRES=${GRDINFO[7]}
#     YRES=${GRDINFO[8]}
#     gdalwarp -s_srs "+proj=longlat +ellps=WGS84" -t_srs WGS84 ${F_TOPO}dem.nc dem180.nc -if "netCDF" -of "netCDF" -tr $XRES $YRES --config CENTER_LONG 0 -q
#     mv dem180.nc ${F_TOPO}dem.nc
#   fi
# fi

################################################################################
#####          Grid contours                                               #####
################################################################################

# Contour interval for grid if not specified using -cn
if [[ $gridcontourcalcflag -eq 1 ]]; then
  zrange=$(grid_zrange $CONTOURGRID -R$MINLON/$MAXLON/$MINLAT/$MAXLAT -C -Vn)
  MINCONTOUR=$(echo $zrange | gawk  '{print $1}')
  MAXCONTOUR=$(echo $zrange | gawk  '{print $2}')
  CONTOURINTGRID=$(echo "($MAXCONTOUR - $MINCONTOUR) / $CONTOURNUMDEF" | bc -l)
  if [[ $(echo "$CONTOURINTGRID > 1" | bc -l) -eq 1 ]]; then
    CONTOURINTGRID=$(echo "$CONTOURINTGRID / 1" | bc)
  fi
fi

# Contour interval for grid if not specified using -cn
if [[ $topocontourcalcflag -eq 1 ]]; then
  zrange=$(grid_zrange $BATHY -R$MINLON/$MAXLON/$MINLAT/$MAXLAT -C -Vn)
  MINCONTOUR=$(echo $zrange | gawk  '{print $1}')
  MAXCONTOUR=$(echo $zrange | gawk  '{print $2}')
  TOPOCONTOURINT=$(echo "($MAXCONTOUR - $MINCONTOUR) / $TOPOCONTOURNUMDEF" | bc -l)
  if [[ $(echo "$TOPOCONTOURINT > 1" | bc -l) -eq 1 ]]; then
    TOPOCONTOURINT=$(echo "$TOPOCONTOURINT / 1" | bc)
  fi
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

  customseisindex=1

  for eqcattype in ${EQ_CATALOG_TYPE[@]}; do
    if [[ $eqcattype =~ "ANSS" ]]; then
      F_SEIS_FULLPATH=$(abs_path ${F_SEIS})
      info_msg "[-z]: $EXTRACT_ANSS_TILES $ANSS_TILEOLDZIP $ANSS_TILENEWZIP ${OLDCAT_DATE} $MINLON $MAXLON $MINLAT $MAXLAT $STARTTIME $ENDTIME $EQ_MINMAG $EQ_MAXMAG $EQCUTMINDEPTH $EQCUTMAXDEPTH ${F_SEIS_FULLPATH}anss_extract_tiles.cat"
      $EXTRACT_ANSS_TILES $ANSS_TILEOLDZIP $ANSS_TILENEWZIP ${OLDCAT_DATE} $MINLON $MAXLON $MINLAT $MAXLAT $STARTTIME $ENDTIME $EQ_MINMAG $EQ_MAXMAG $EQCUTMINDEPTH $EQCUTMAXDEPTH ${F_SEIS_FULLPATH}anss_extract_tiles.cat

      # ANSS CSV format is:
      # 1    2        3         4     5   6       7   8   9    10  11  12 13      14    15   16              17         18       19     20     21             22
      # time,latitude,longitude,depth,mag,magType,nst,gap,dmin,rms,net,id,updated,place,type,horizontalError,depthError,magError,magNst,status,locationSource,magSource

      # Tectoplot catalog is Lon,Lat,Depth,Mag,Timecode,ID,epoch (or -1)
      TZ=UTC
      gawk -F, < ${F_SEIS}anss_extract_tiles.cat '
      @include "tectoplot_functions.awk"
      {
        type=tolower($6)
        if (tolower(type) == "mb" && $5 >= 3.5 && $5 <=7.0) {
          # NEIC mb > Mw Weatherill, 2016
          oldval=$5
          $5 = 1.159 * $5 - 0.659
          print $12, type "=", oldval, "to Mw(GCMT)=", $5 >> "./mag_conversions.dat"
        } else if (tolower(type) == "mw") {
          # NEIC Mw > Mw(GCMT) Weatherill, 2016
          oldval=mag
          $11 = 1.021 * mag - 0.091
          print $1, type "=" oldval, "to Mw(GCMT)=", $11 >> "./mag_conversions.dat"
        } else if (tolower(type) == "ms") {
          oldval=$5
          if (tolower(substr($6,1,3))=="msz") {
            # NEIC Msz > Mw Weatherill, 2016
            if ($5 >= 3.5 && $5 <= 6.47) {
                $5 = 0.707 * $5 + 19.33
                print $12, "Msz=", oldval, "to Mw(GCMT)=", $5 >> "./mag_conversions.dat"
            }
            if ($5 > 6.47 && $5 <= 8.0) {
              $5 = 0.950 * $5 + 0.359
              print $12, "Msz=", oldval, "to Mw(GCMT)=", $5 >> "./mag_conversions.dat"
            }
            print $1, tolower(substr($6,1,3)) "=" oldval, "to Mw=", $5 >> "./mag_conversions.dat"
          } else {
            # NEIC Ms > Mw(GCMT) Weatherill, 2016
            if ($5 >= 3.5 && $5 <= 6.47) {
                $5 = 0.723 * $5 + 1.798
                print $12, type "=", oldval, "to Mw(GCMT)=", $5 >> "./mag_conversions.dat"
            }
            if ($5 > 6.47 && $5 <= 8.0) {
              $5 = 1.005 * $5 - 0.026
              print $12, type "=", oldval, "to Mw(GCMT)=", $5 >> "./mag_conversions.dat"
            }
          }
        }
      else if (tolower(type) == "ml") { # Mereu, 2020
          oldval=$5
          $5 = 0.62 * $5 + 1.09
          print $12, type "=" oldval, "to Mw(GCMT)=", $5 >> "./mag_conversions.dat"
        }
        epoch=iso8601_to_epoch(substr($1,1,19))
        print $3, $2, $4, $5, substr($1,1,19), $12, epoch
      }' >> ${F_SEIS}eqs.txt
      ((NUMEQCATS+=1))
    fi
    if [[ $eqcattype =~ "ISC" ]]; then
      F_SEIS_FULLPATH=$(abs_path ${F_SEIS})
      info_msg "[-z]: $EXTRACT_ANSS_TILES $ANSS_TILEOLDZIP $ANSS_TILENEWZIP ${OLDCAT_DATE} $MINLON $MAXLON $MINLAT $MAXLAT $STARTTIME $ENDTIME $EQ_MINMAG $EQ_MAXMAG $EQCUTMINDEPTH $EQCUTMAXDEPTH ${F_SEIS_FULLPATH}isc_extract_tiles.cat"
      $EXTRACT_ISC_TILES $ISC_TILEOLDZIP $ISC_TILENEWZIP ${OLDCAT_DATE} $MINLON $MAXLON $MINLAT $MAXLAT $STARTTIME $ENDTIME $EQ_MINMAG $EQ_MAXMAG $EQCUTMINDEPTH $EQCUTMAXDEPTH ${F_SEIS_FULLPATH}isc_extract_tiles.cat

      # 1       2         3           4          5        6         7     8      9         10     11   12+
      # EVENTID,AUTHOR   ,DATE      ,TIME       ,LAT     ,LON      ,DEPTH,DEPFIX,AUTHOR   ,TYPE  ,MAG  [, extra...]
      #  752622,ISC      ,1974-01-14,03:59:31.48, 28.0911, 131.4943, 10.0,TRUE  ,ISC      ,mb    , 4.3

      gawk -F, < ${F_SEIS}isc_extract_tiles.cat '
      @include "tectoplot_functions.awk"
      {
        type=tolower(substr($10,1,2))
        mag=$11
        typeindex=10
        magindex=11
        while($(typeindex)!="") {
          newtype=tolower(substr($(typeindex),1,2))
          newmag=$(magindex)
          if (newmag > mag) {
            print "Selecting largest reported magnitude of event", $1, ":", newtype, newmag > "./mag_selections.dat"
            type=newtype
            mag=newmag
          }
          typeindex+=3
          magindex+=3
        }
        if (tolower(type) == "mb" && mag >= 3.5 && mag <=7.0) {
          # ISC mb > Mw(GCMT) Weatherill, 2016
          oldval=mag
          $11 = 1.084 * mag - 0.142
          print $1, type "=" oldval, "to Mw(GCMT)=", $11 >> "./mag_conversions.dat"
        } else if (tolower(type) == "ms") {
          # ISC Ms > Mw(GCMT) Weatherill, 2016
          oldval=mag
          if (mag >= 3.5 && mag <= 6.0) {
              $11 = 0.616 * mag + 2.369
              print $1, type "=" oldval, "to Mw(GCMT)=", $11 >> "./mag_conversions.dat"

          } else if (mag > 6.0 && mag <= 8.0) { # Weatherill, 2016, ISC
            $11 = 0.994 * mag + 0.1
            print $1, type "=" oldval, "to Mw(GCMT)=", $11 >> "./mag_conversions.dat"
          }
        } else if (tolower(type) == "ml") {
          # Is it more wrong to use a local ml->Mw conversion or leave the ml alone? Not sure!
          # Mereu, 2020
          oldval=mag
          $11 = 0.62 * mag + 1.09
          print $1, type "=" oldval, "to Mw(GCMT)=", $11 >> "./mag_conversions.dat"
        }
        timestring=sprintf("%sT%s", $3, substr($4, 1, 8))
        epoch=iso8601_to_epoch(timestring)
        print $6, $5, $7, $11, timestring, $1, epoch
      }' >> ${F_SEIS}eqs.txt
      ((NUMEQCATS+=1))
    fi
    if [[ $eqcattype =~ "EHB" ]]; then

      # lon, lat, depth, mag, timestring, id, epoch, type
      # type = "mw" or "ms" or "mb"

        gawk < ${ISCEHB_DATA} -v mindepth="${EQCUTMINDEPTH}" -v maxdepth="${EQCUTMAXDEPTH}" -v minlat="$MINLAT" -v maxlat="$MAXLAT" -v minlon="$MINLON" -v maxlon="$MAXLON" -v minmag=${EQ_MINMAG} -v maxmag=${EQ_MAXMAG} -v mindate=$STARTTIME -v maxdate=$ENDTIME '
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

                $8=""


                print
              }
            }


          }
        ' >> ${F_SEIS}eqs.txt
        ((NUMEQCATS+=1))
        ((customseisindex+=1))
        echo "${ISCEHB_EQ_SHORT_SOURCESTRING}" >> ${SHORTSOURCES}
        echo "${ISCEHB_EQ_SOURCESTRING}" >> ${LONGSOURCES}
    fi
    ##############################################################################
    # Add additional user-specified seismicity files. This needs to be expanded
    # to import from various common formats. Currently needs tectoplot format data
    # and only ingests lines with 4-7 fields.

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
              if ($6=="") {
                $6=0
              }
              if ($7=="") {
                $7="none"
              }
              if ($3 >= mindepth && $3 <= maxdepth && $4 <= maxmag && $4 >= minmag && $2 >= minlat && $2 <= maxlat) {
                if (test_lon(minlon, maxlon, $1) == 1) {
                  if (checkdate==1) {
                    if (mindate <= $5 && $5 <= maxdate) {
                      print $1, $2, $3, $4, $5, $6, $7
                    }
                  } else {
                    print $1, $2, $3, $4, $5, $6, $7
                  }
                }
              }
            }
          }' >> ${F_SEIS}eqs.txt
        ((NUMEQCATS+=1))
        ((customseisindex+=1))
        echo "CustomEQ" >> ${SHORTSOURCES}
        echo "Seismicity from ${SEISADDFILE[$seisfilenumber]}" >> ${LONGSOURCES}
    fi
  done

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


    # Cull the combined catalogs by removing global events that fall within a
    # specified space-time-magnitude window of an event in the custom catalog
[[ $NUMEQCATS -le 1 ]] && CULL_EQ_CATALOGS=0
[[ $forceeqcullflag -eq 1 ]] && CULL_EQ_CATALOGS=1

    # We keep the first event, so prioritization is by order of specified catalogs
if [[ $CULL_EQ_CATALOGS -eq 1 ]]; then
    info_msg "Culling multiple input seismic catalogs..."

    # Copy the extracted catalog to the precull catalog
    cp ${F_SEIS}eqs.txt ${F_SEIS}eqs_precull.txt

    # Find the number of events in the precull catalog
    num_eqs_precull=$(wc -l < ${F_SEIS}eqs_precull.txt | tr -d ' ')

    # Do the culling. n=
    gawk < ${F_SEIS}eqs_precull.txt -v n=${num_eqs_precull} '
    @include "tectoplot_functions.awk"
    BEGIN {
      epoch_cutoff=30  # Seconds between events
      mag_cutoff=0.3   # Magnitude difference
      lon_cutoff=0.2   # Longitude difference
      lat_cutoff=0.2   # Latitude difference
      depth_cutoff=20  # depth difference
    }
    (NR <= n) {
      data[NR]=$5"\x99"$0"\x99"1"\x99"iso8601_to_epoch($5)"\x99"NR
    }
    # (NR > n) {
    #   data[NR]=$5"\x99"$0"\x99"0"\x99"iso8601_to_epoch($5)"\x99"NR
    #   print "Event", NR, "is not imported" > "/dev/stderr"
    # }
    END {
      asort(data)
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
        epoch[i]=x[4]
        linenumber[i]=x[5]
      }
      for(i=1;i<=NR;i++)
      {
        # For each event in the combined catalog
        printme=1
        # if (is_imported[i]==0) {
        #   printme=1
          # Check only the 10 closest events in time
        for(j=i-5;j<=i+5;++j)
        {
          # is_imported[] is no longer used and should be removed
          if (j>=1 && j<=NR && j != i && is_imported[j] == 1)
          {
            if ((abs(epoch[i]-epoch[j]) < epoch_cutoff) && (abs(mag[i]-mag[j]) < mag_cutoff) && (abs(lon[i]-lon[j]) < lon_cutoff) && (abs(lat[i]-lat[j]) < lat_cutoff) && (abs(depth[i]-depth[j]) < depth_cutoff) && (linenumber[i] > linenumber[j]) )
            {
                  # There is an equivalent event in the catalog that has a
                  # lower line number, so do not print this event
                  print event[i], "[" linenumber[i] "]", "was removed because it matches", event[j], "[" linenumber[j] "]" > "./culled_seismicity.txt"
                  printme=0
                  break
            }
          }
        }
        if (printme==1) {
          print event[i]
        }
      }
    }' > ${F_SEIS}eqs_culled.txt
    [[ -s culled_seismicity.txt ]] && mv culled_seismicity.txt ${F_SEIS}
    [[ -s ${F_SEIS}eqs_culled.txt ]] && cp ${F_SEIS}eqs_culled.txt ${F_SEIS}eqs.txt

    num_after_cull=$(wc -l < ${F_SEIS}eqs.txt | tr -d ' ')
    info_msg "Before culling: ${num_eqs_precull}.  After culling: ${num_after_cull}"
  fi

  # Secondary select of combined seismicity using the actual AOI polygon which
  # may differ from the lat/lon box.
  #
  # # In most cases this won't be necessary so maybe we should move into if-fi above?
  # info_msg "Selecting seismicity within AOI polygon"
  # # This command is screwing up some fields in the output file. WHY???


  # if [[ -s ${F_SEIS}eqs.txt ]]; then
  #   mv ${F_SEIS}eqs.txt ${F_SEIS}eqs_aoipreselect.txt
  #   gmt select ${F_SEIS}eqs_aoipreselect.txt -R -J -Vn | tr '\t' ' ' > ${F_SEIS}eqs.txt
  # fi

  # Alternative method using the bounding box which really doesn't work with global extents
  # gmt select ${F_SEIS}eqs_aoipreselect.txt -F${F_MAPELEMENTS}bounds.txt -Vn | tr '\t' ' ' > ${F_SEIS}eqs.txt
  cleanup ${F_SEIS}eqs_aoipreselect.txt
  info_msg "AOI selection: $(wc -l < ${F_SEIS}eqs.txt)"

  ##############################################################################
  # Select seismicity that falls within a specified polygon.

  if [[ $polygonselectflag -eq 1 ]]; then
    info_msg "Selecting seismicity within specified AOI polygon ${POLYGONAOI}"
    mv ${F_SEIS}eqs.txt ${F_SEIS}eqs_preselect.txt
    gmt select ${F_SEIS}eqs_preselect.txt -F${POLYGONAOI} -Vn | tr '\t' ' ' > ${F_SEIS}eqs.txt
    # gmt select ${F_SEIS}eqs_preselect.txt -F${POLYGONAOI} -Vn | tr '\t' ' ' > ${F_SEIS}eqs.txt
    # cleanup ${F_SEIS}eqs_preselect.txt
  fi
  info_msg "Polygon selection: $(wc -l < ${F_SEIS}eqs.txt)"

  ##############################################################################
  # Select seismicity on land

  if [[ $zconlandflag -eq 1 && -s ${F_SEIS}eqs.txt ]]; then
    info_msg "Selecting seismicity on land or at sea"
    if [[ -s ${F_TOPO}dem.nc ]]; then

      gmt grdtrack ${F_SEIS}eqs.txt -N -Z -Vn -G${F_TOPO}dem.nc | gawk -v landorsea=${zc_land_or_sea} '
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


  # Select seismicity from eqlist

  if [[ $eqlistselectflag -eq 1 ]]; then
    echo ${eqlistarray[@]} | tr ' ' '\n' > ${F_SEIS}eqselectlist.txt

    gawk '
      NR==FNR {
        A[$1]=1 ; next
      }
      $6 in A {
        print
      }' ${F_SEIS}eqselectlist.txt ${F_SEIS}eqs.txt > ${F_SEIS}eqselected.dat
    [[ -s ${F_SEIS}eqselected.dat ]] && cp ${F_SEIS}eqselected.dat ${F_SEIS}eqs.txt
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



  #### Decluster seismicity using one of several available algorithms

  if [[ $seisdeclusterflag -eq 1 ]]; then
    info_msg "Declustering seismicity catalog..."
    if [[ ${DECLUSTER_METHOD} =~ "rb" ]]; then
      info_msg "Using Reasenberg method"

      if [[ ! -x ${REASENBERG_EXEC} ]]; then
        echo "Compiling Reasenberg declustering code"
        ${F90COMPILER} ${REASENBERG_SCRIPT} -o ${REASENBERG_EXEC}
      fi

      if [[ -x ${REASENBERG_EXEC} ]]; then
        ${REASENBERG_SH} ${F_SEIS}eqs.txt ${REASENBERG_EXEC} ${DECLUSTER_MINSIZE}
      fi

    else
      info_msg "Using Gardner-Knopoff window method ${DECLUSTER_METHOD}"
      ${DECLUSTER_GK} ${F_SEIS}eqs.txt ${DECLUSTER_METHOD} ${DECLUSTER_MINSIZE}
      cp ${F_SEIS}eqs.txt ${F_SEIS}eqs_predecluster.txt
    fi
    if [[ ${DECLUSTER_REMOVE} -eq 1 ]]; then
      cp ./catalog_declustered.txt ${F_SEIS}eqs.txt
    else
      cat ./catalog_declustered.txt ./catalog_clustered.txt > ${F_SEIS}eqs.txt
    fi
    mv ./catalog_declustered.txt ./catalog_clustered.txt ${F_SEIS}
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

##### FOCAL MECHANISMS


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

    if [[ -s $THIS_CMTFILE ]]; then
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
    fi
  done

  if [[ ${#CCAT_STRING} -gt 1 && ${CULL_CMT_CATALOGS} -eq 1 ]]; then

    info_msg "[-c]: Sorting, finding clashes, and prioritizing using order of CCAT_STRING=${CCAT_STRING}"


    before_e=$(wc -l < ${F_CMT}cmt_global_aoi.dat)

    # Column  Data              Units
    # ------  ----              -----
    # 1.      idcode            A source data letter (G=GCMT, I=ISC, Z=GFZ, etc) and a
    #                           EQ type letter (N=Normal, T=Thrust, S=Strike slip)
    # 2.      event_code	      Any event ID from the source catalog
    # 3.      id	              YYYY-MM-DDTHH:MM:SS time string
    # 4.      epoch             (seconds) since Jan 1, 1970
    # 5.      lon_centroid	    (°)
    # 6.      lat_centroid	    (°)
    # 7.      depth_centroid	  (km)
    # 8.      lon_origin	      (°)
    # 9.      lat_origin	      (°)
    # 10.     depth_origin	    (km)
    # 11.     author_centroid	  string    (e.g. GCMT)
    # 12.     author_origin	    string    (e.g. NEIC)
    # 13.     MW	              number
    # 14.     mantissa	        number
    # 15.     exponent	        integer
    # 16.     strike1	          (°)
    # 17.     dip1	            (°)
    # 18.     rake1	            (°)
    # 19.     strike2	          (°)
    # 20.     dip2	            (°)
    # 21.     rake2	            (°)
    # 22.     exponent	        same as field 15
    # 23.     Tval	            number
    # 24.     Taz	              (°) azimuth of T axis
    # 25.     Tinc	            (°) plunge of T axis
    # 26.     Nval	            number
    # 27.     Naz	              (°)
    # 28.     Ninc	            (°)
    # 29.     Pval	            number
    # 30.     Paz	              (°)
    # 31.     Pinc	            (°)
    # 32.     exponent	        same as 15
    # 33.     Mrr	              number
    # 34.     Mtt	              number
    # 35.     Mpp	              number
    # 36.     Mrt	              number
    # 37.     Mrp	              number
    # 38.     Mtp	              number
    # 39.     centroid_dt       (seconds)   Time between origin and centroid

    sort ${F_CMT}cmt_global_aoi.dat -k3,3 | uniq -u > ${F_CMT}cmt_presort.txt
    gawk < ${F_CMT}cmt_presort.txt -v removedfile=${F_CMT}"cmt_removed_cull.cat" -v cent=$CENTROIDFLAG -v ccatstring=${CCAT_STRING} '
    function abs(v) { return (v>0)?v:-v }
    function build_index(ccstr) {
      for(i=1; i<=length(ccstr); i++) {
        ccindex[substr(ccstr, i, 1)]=i
      }
    }
    BEGIN {
      # Define the window for potentially equivalent earthquakes
      delta_lon=2
      delta_lat=2
      delta_sec=15
      delta_depth=30
      delta_mag=0.5

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
          # For the two entries surrounding each entry (before and after)
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


  # if [[ $globalextentflag -ne 1  ]]; then
  #   info_msg "Selecting focal mechanisms within non-global map AOI using ${CMTTYPE} location"
  #
  #   case $CMTTYPE in
  #     CENTROID)  # Lon=Column 5, Lat=Column 6
  #       gawk < $CMTFILE '{
  #         for (i=5; i<=NF; i++) {
  #           printf "%s ", $(i) }
  #           print $1, $2, $3, $4;
  #         }' | gmt select -F${F_MAPELEMENTS}bounds.txt ${VERBOSE} | tr '\t' ' ' | gawk  '{
  #         printf "%s %s %s %s", $(NF-3), $(NF-2), $(NF-1), $(NF);
  #         for (i=1; i<=NF-4; i++) {
  #           printf " %s", $(i)
  #         }
  #         printf "\n";
  #       }' > ${F_CMT}cmt_aoipolygonselect.dat
  #       ;;
  #     ORIGIN)  # Lon=Column 8, Lat=Column 9
  #       gawk < $CMTFILE '{
  #         for (i=8; i<=NF; i++) {
  #           printf "%s ", $(i) }
  #           print $1, $2, $3, $4, $5, $6, $7;
  #         }' > ${F_CMT}tmp.dat
  #         gmt select ${F_CMT}tmp.dat -F${F_MAPELEMENTS}bounds.txt ${VERBOSE} | tr '\t' ' ' | gawk  '{
  #         printf "%s %s %s %s %s %s %s", $(NF-6), $(NF-5), $(NF-4), $(NF-3), $(NF-2), $(NF-1), $(NF);
  #         for (i=1; i<=NF-6; i++) {
  #           printf " %s", $(i)
  #         } printf "\n";
  #       }' > ${F_CMT}cmt_aoipolygonselect.dat
  #       ;;
  #   esac
  #   CMTFILE=$(abs_path ${F_CMT}cmt_aoipolygonselect.dat)
  # fi

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

  # 16.     strike1	          (°)
  # 17.     dip1	            (°)
  # 18.     rake1	            (°)
  # 19.     strike2	          (°)
  # 20.     dip2	            (°)
  # 21.     rake2	            (°)

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
    if [[ -s ${F_TOPO}dem.nc ]]; then
      case $CMTTYPE in
        ORIGIN)
          gawk < ${CMTFILE} '{print $8, $9}' > ${F_CMT}cmt_epicenter.dat
          ;;
        CENTROID)
          gawk < ${CMTFILE} '{print $5, $6}' > ${F_CMT}cmt_epicenter.dat
          ;;
      esac

      gmt grdtrack ${F_CMT}cmt_epicenter.dat -N -Z -Vn -G${F_TOPO}dem.nc | gawk -v landorsea=${zc_land_or_sea} '
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
          gawk < ${F_CMT}cmt_slab2_sample_${slab2inregion[$i]}_pasted.txt -v cmttype=${CMTTYPE} -v strikediff=${CMTSLAB2STR} -v dipdiff=${CMTSLAB2DIP} -v vertdiff=${CMTSLAB2VERT} '
            function abs(v) { return (v>0)?v:-v}
            {
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
              if (slab2depth != "NaN" && abs(depth-slab2depth)<vertdiff)
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
            }' >> ${F_CMT}cmt_slabselected.txt
          #   wc -l ../${F_CMT}cmt_thrust_nearslab.txt
          #   cat ./cmt_thrust_nodalplane.txt >> ../${F_CMT}cmt_thrust_nodalplane.txt
          #   rm -f ./cmt_thrust_nodalplane.txt
        fi
        # If we are looking for shallow events
        if [[ $cmtslab2_shallow_filterflag -eq 1 ]]; then
          gawk < ${F_CMT}cmt_slab2_sample_${slab2inregion[$i]}_pasted.txt -v cmttype=${CMTTYPE} -v strikediff=${CMTSLAB2STR} -v dipdiff=${CMTSLAB2DIP} -v vertdiff=${CMTSLAB2VERT} '
            function abs(v) { return (v>0)?v:-v}
            {
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
              if (slab2depth != "NaN" && depth<slab2depth-vertdiff)
              {
                $42=""
                $41=""
                $40=""
                print $0
              }
            }' >> ${F_CMT}cmt_slabselected.txt
        fi

        # If we are looking for deep events
        if [[ $cmtslab2_deep_filterflag -eq 1 ]]; then
          gawk < ${F_CMT}cmt_slab2_sample_${slab2inregion[$i]}_pasted.txt -v cmttype=${CMTTYPE} -v strikediff=${CMTSLAB2STR} -v dipdiff=${CMTSLAB2DIP} -v vertdiff=${CMTSLAB2VERT} '
            function abs(v) { return (v>0)?v:-v}
            {
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
              if (slab2depth != "NaN" && depth>slab2depth+vertdiff)
              {
                $42=""
                $41=""
                $40=""
                print $0
              }
            }' >> ${F_CMT}cmt_slabselected.txt
        fi
      done
    fi
    [[ -s ${F_CMT}cmt_slabselected.txt ]] && CMTFILE=$(abs_path ${F_CMT}cmt_slabselected.txt)
  fi

##### Filter to select only earthquakes NOT above a Slab2 model
#
# if [[ $cmtslab2_deep_filterflag -eq 1 ]]; then
#   if [[ ! $numslab2inregion -eq 0 ]]; then
#
#     # Extract the lon, lat of all focal mechanisms based on CMTTYPE
#
#     gawk < $CMTFILE -v cmttype=$CMTTYPE '
#       {
#         if (cmttype=="CENTROID") {
#           lon=$5; lat=$6; depth=$7;
#         } else {
#           lon=$8; lat=$9; depth=$10;
#         }
#         print lon, lat
#       }' > ${F_CMT}cmt_lonlat.txt
#
#     # For each slab in the region
#
#     for i in $(seq 1 $numslab2inregion); do
#       info_msg "Sampling earthquake events on ${slab2inregion[$i]}"
#       ss_depthfile+=$(echo ${SLAB2_GRIDDIR}${slab2inregion[$i]}.grd | sed 's/clp/dep/')" "
#     done
#
#     sample_grid_360 ${F_CMT}cmt_lonlat.txt ${ss_depthfile[@]} >>  ${F_CMT}cmt_under_slab2_sample.txt
#
#       # -N flag is needed in case events fall outside the domain
#     # gmt grdtrack ${ss_depthfile[@]} -Z -N ${F_CMT}cmt_lonlat.txt ${VERBOSE} > ${F_CMT}cmt_under_slab2_sample.txt
#
#
#
#     paste ${CMTFILE} ${F_CMT}cmt_under_slab2_sample.txt > ${F_CMT}cmt_under_slab2_sample_pasted.txt
#
#     info_msg "Selecting focal mechanisms beneath or away from slab"
#     touch ${F_CMT}cmt_nodalplane.txt
#
#     # Fields 40+ are slab depth samples.
#     # If one of them is not NaN and is less than slab2depth, exclude the
#     gawk < ${F_CMT}cmt_under_slab2_sample_pasted.txt -v cmttype=${CMTTYPE} -v buf=${SLAB2_BUFFER} '
#       {
#           if (cmttype=="ORIGIN") {
#             lon=$8; lat=$9; depth=$10
#           } else {
#             lon=$5; lat=$6; depth=$7
#           }
#           printme=1
#           for (i=40; i<= NF; i++) {
#             # If the focal mechanism is above the slab interface (0-$(i) is positive down)
#             if (depth < (0-$(i)) - buf ) {
#               printme=0
#             }
#             # Delete the field for eventual printing
#             $(i)=""
#           }
#
#           # If it is outside the slab2 region OR is beneath the slab
#           if (printme==1)
#           {
#             print $0
#           }
#       }' >> ${F_CMT}cmt_underslab.txt
#
#
#     # Problem: if there are multiple slabs, then all mechanisms will appear
#     # because of NaN... we really want to EXCLUDE strike slip events in the
#     # UPPER PLATE.
#
#   fi
#   [[ -s ${F_CMT}cmt_underslab.txt ]] && CMTFILE=$(abs_path ${F_CMT}cmt_underslab.txt)
# fi

##### Filter to select only earthquakes ABOVE a Slab2 model
#
# if [[ $cmtslab2_shallow_filterflag -eq 1 ]]; then
#   if [[ ! $numslab2inregion -eq 0 ]]; then
#
#     # Extract the lon, lat of all focal mechanisms based on CMTTYPE
#
#     gawk < $CMTFILE -v cmttype=$CMTTYPE '
#       {
#         if (cmttype=="CENTROID") {
#           lon=$5; lat=$6; depth=$7;
#         } else {
#           lon=$8; lat=$9; depth=$10;
#         }
#         print lon, lat
#       }' > ${F_CMT}cmt_lonlat.txt
#
#     # For each slab in the region
#
#     for i in $(seq 1 $numslab2inregion); do
#       info_msg "Sampling earthquake events on ${slab2inregion[$i]}"
#       ss_depthfile+="-G"$(echo ${SLAB2_GRIDDIR}${slab2inregion[$i]}.grd | sed 's/clp/dep/')" "
#     done
#
#       # -N flag is needed in case events fall outside the domain
#     gmt grdtrack ${ss_depthfile[@]} -Z -N ${F_CMT}cmt_lonlat.txt ${VERBOSE} > ${F_CMT}cmt_shallow_slab2_sample.txt
#
#     paste ${CMTFILE} ${F_CMT}cmt_shallow_slab2_sample.txt > ${F_CMT}cmt_shallow_slab2_sample_pasted.txt
#
#     info_msg "Selecting focal mechanisms beneath or away from slab"
#     touch ${F_CMT}cmt_nodalplane.txt
#
#     # Fields 40+ are slab depth samples.
#     # If one of them is not NaN and is less than slab2depth, exclude the
#     gawk < ${F_CMT}cmt_shallow_slab2_sample_pasted.txt -v cmttype=${CMTTYPE} -v buf=${SLAB2_BUFFER} '
#       {
#           if (cmttype=="ORIGIN") {
#             lon=$8; lat=$9; depth=$10
#           } else {
#             lon=$5; lat=$6; depth=$7
#           }
#           printme=0
#           for (i=40; i<= NF; i++) {
#             # Select if the focal mechanism is above a slab interface (0-$(i) is positive down)
#             if ($(i) != "NaN" && depth < (0-$(i)) - buf ) {
#               printme=1
#             }
#             # Delete the field for eventual printing
#             $(i)=""
#           }
#
#           # If it is outside the slab2 region OR is beneath the slab
#           if (printme==1)
#           {
#             print $0
#           }
#       }' >> ${F_CMT}cmt_aboveslab.txt
#
#
#     # Problem: if there are multiple slabs, then all mechanisms will appear
#     # because of NaN... we really want to EXCLUDE strike slip events in the
#     # UPPER PLATE.
#
#   fi
#   [[ -s ${F_CMT}cmt_aboveslab.txt ]] && CMTFILE=$(abs_path ${F_CMT}cmt_aboveslab.txt)
# fi

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

    moment_tensor_rotate($33,$34,$35,$36,$37,$38,strike,dip,dip)
    moment_tensor_diagonalize_ntp(r_Mxx, r_Myy, r_Mzz, r_Mxy, r_Mxz, r_Myz)
    ntp_to_sdr(d_AZ0, d_PL0, d_AZ2, d_PL2, SDR)

    print $1,$2"-rotated",$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,SDR[1],SDR[2],SDR[3],SDR[4],SDR[5],SDR[6],$22,d_EV0,d_AZ0,d_PL0,d_EV1,d_AZ1,d_PL1,d_EV2,d_AZ2,d_PL2,$32,r_Mxx,r_Myy,r_Mzz,r_Mxy,r_Mxz,r_Myz,$39
  }' > ${F_CMT}cmt_rotated_slab2.txt
  [[ -s ${F_CMT}cmt_rotated_slab2.txt ]] && CMTFILE=$(abs_path ${F_CMT}cmt_rotated_slab2.txt)
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
  # earthquakes that have a focal mechanism equivalent, using a spatiotemporal
  # proximity metric

  # If CMTFILE exists but we aren't plotting CMT's this will really cull a lot of EQs! Careful!
  # CMTFILE should arguably be AOI selected by now in all cases (can we check?)

  # This section is very sensitive to file formats and any change will break it.

  if [[ $REMOVE_EQUIVS -eq 1 && -e $CMTFILE && -e ${F_SEIS}eqs.txt ]]; then

    before_e=$(wc -l < ${F_SEIS}eqs.txt)

    gawk '
    (NR==FNR) { # Read in EQs first
      print $7, $0
    }
    (NR>FNR) { # Now read in focal mechanisms
      print $4, $0
    }
    ' ${F_SEIS}eqs.txt $CMTFILE | sort -n -k 1,1 > ${F_CMT}equiv_presort.txt

    gawk < ${F_CMT}equiv_presort.txt '
      function abs(v) { return (v>0)?v:-v }
      BEGIN {
        delta_lon=2
        delta_lat=2
        delta_sec=15
        delta_depth=30
        delta_mag=0.5
      }
      {
        data[NR]=$0
        epoch[NR]=$1
        numfields[NR]=NF

        if ($14 != "") {
        # CMT entry
          iscmt[NR]=1
          lon[NR]=$9
          lat[NR]=$10
          depth[NR]=$11
          mag[NR]=$14
          idcode[NR]=$3
        } else {
        # Seismicity entry
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
        # Check each earthquake entry
        for(indd=1;indd<=numentries;indd++) {

          # For seismicity event, decide if there is a focal mechanism equivalent
          if (iscmt[indd]==0) {
            printme=1
            for(j=indd-2; j<=indd+2; j++) {
              # For the surrounding two events, if one is a CMT event
              if (j>=1 && j<=numentries && j != indd && iscmt[j]==1) {
                if ( (abs(lon[indd]-lon[j])<=delta_lon) && (abs(lat[indd]-lat[j])<=delta_lat) &&
                     (abs(depth[indd]-depth[j])<=delta_depth) && (abs(epoch[indd]-epoch[j])<=delta_sec &&
                     (abs(mag[indd]-mag[j])<=delta_mag) ) ) {
                     # This CMT [j] is a duplicate of the seismicity event [i]
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
      [[ -s ./eq_culled.txt ]] && mv ./eq_culled.txt ${F_SEIS}

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

  CMTRESCALE=$(echo "$CMTSCALE * $SEISSCALE " | bc -l)  # * $SEISSCALE

  if [[ $SCALEEQS -eq 1 ]]; then
    info_msg "Scaling CMT earthquake magnitudes for display only"
    gawk < $CMTFILE -v str=$SEISSTRETCH -v sref=$SEISSTRETCH_REFMAG '{
      mw=$13
      mwmod = (mw^str)/(sref^(str-1))
      a=sprintf("%E", 10^((mwmod + 10.7)*3/2))
      split(a,b,"+")  # mantissa
      split(a,c,"E")  # exponent
      $14=c[1]
      $15=b[2]
      print
      # print $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, c[1], b[2], $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $30, $31, $32, $33, $34, $35, $36, $37, $38, $39
    }' > ${F_CMT}cmt_scale.dat
    CMTFILE=$(abs_path ${F_CMT}cmt_scale.dat)
  fi


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
  gawk < $CMTFILE -v fmt=$CMTFORMAT -v cmttype=$CMTTYPE -v minmag="${CMT_MINMAG}" -v maxmag="${CMT_MAXMAG}" '
    @include "tectoplot_functions.awk"
    # function abs(v) { return (v>0)?v:-v}
    BEGIN { pi=atan2(0,-1) }
    {
      event_code=$2
      iso8601_code=$3
      Mw=$13
      mantissa=$14;exponent=$15
      strike1=$16;dip1=$17;rake1=$18;strike2=$19;dip2=$20;rake2=$21
      Mrr=$33; Mtt=$34; Mpp=$35; Mrt=$36; Mrp=$37; Mtp=$38
      Tval=$23; Taz=$24; Tinc=$25; Nval=$26; Naz=$27; Ninc=$28; Pval=$29; Paz=$30; Pinc=$31;
      clusterid=$40

      epoch=iso8601_to_epoch(iso8601_code)

      timecode=$3
      if (cmttype=="CENTROID") {
        lon=$5; lat=$6; depth=$7;
        altlon=$8; altlat=$9; altdepth=$10;
      } else {
        lon=$8; lat=$9; depth=$10;
        altlon=$5; altlat=$6; altdepth=$7;
      }

      if (lon != "none" && lat != "none") {

        # if (fmt == "GlobalCMT") {
        #   #  lon lat depth strike1 dip1 rake1 aux_strike dip2 rake2 moment altlon altlat [event_title] altdepth [timecode]
        #   if (substr($1,2,1) == "T") {
        #     print lon, lat, depth, strike1, dip1, rake1, strike2, dip2, rake2, mantissa, exponent, altlon, altlat, event_code, altdepth, epoch, clusterid > "cmt_thrust.txt"
        #   } else if (substr($1,2,1) == "N") {
        #     print lon, lat, depth, strike1, dip1, rake1, strike2, dip2, rake2, mantissa, exponent, altlon, altlat, event_code, altdepth, epoch, clusterid > "cmt_normal.txt"
        #   } else {
        #     print lon, lat, depth, strike1, dip1, rake1, strike2, dip2, rake2, mantissa, exponent, altlon, altlat, event_code, altdepth, epoch, clusterid > "cmt_strikeslip.txt"
        #   }
        #   print lon, lat, depth, strike1, dip1, rake1, strike2, dip2, rake2, mantissa, exponent, altlon, altlat, event_code, altdepth, epoch, clusterid > "cmt.dat"
        #
        # } else
        if (fmt == "MomentTensor") {
          # lon lat depth mrr mtt mff mrt mrf mtf exp altlon altlat [event_title] altdepth [timecode]
            if (substr($1,2,1) == "T") {
              print lon, lat, depth, Mrr, Mtt, Mpp, Mrt, Mrp, Mtp, exponent, altlon, altlat, event_code, altdepth, epoch, clusterid > "cmt_thrust.txt"
            } else if (substr($1,2,1) == "N") {
              print lon, lat, depth, Mrr, Mtt, Mpp, Mrt, Mrp, Mtp, exponent, altlon, altlat, event_code, altdepth, epoch, clusterid  > "cmt_normal.txt"
            } else {
              print lon, lat, depth, Mrr, Mtt, Mpp, Mrt, Mrp, Mtp, exponent, altlon, altlat, event_code, altdepth, epoch, clusterid  > "cmt_strikeslip.txt"
            }
            print lon, lat, depth, Mrr, Mtt, Mpp, Mrt, Mrp, Mtp, exponent, altlon, altlat, event_code, altdepth, epoch, clusterid  > "cmt.dat"
        }
      # else if (fmt == "TNP") {
      #      # y  Best double couple defined from principal axis:
  	  #      # X Y depth T_value T_azim T_plunge N_value N_azim N_plunge P_value P_azim P_plunge exp [newX newY] [event_title]
      #     if (substr($1,2,1) == "T") {
      #       print lon, lat, depth, Tval, Taz, Tinc, Nval, Naz, Ninc, Pval, Paz, Pinc, exponent, altlon, altlat, event_code, altdepth, epoch, clusterid > "cmt_thrust.txt"
      #     } else if (substr($1,2,1) == "N") {
      #       print lon, lat, depth, Tval, Taz, Tinc, Nval, Naz, Ninc, Pval, Paz, Pinc, exponent, altlon, altlat, event_code, altdepth, epoch, clusterid  > "cmt_normal.txt"
      #     } else {
      #       print lon, lat, depth, Tval, Taz, Tinc, Nval, Naz, Ninc, Pval, Paz, Pinc, exponent, altlon, altlat, event_code, altdepth, epoch, clusterid  > "cmt_strikeslip.txt"
      #     }
      #     print lon, lat, depth, Tval, Taz, Tinc, Nval, Naz, Ninc, Pval, Paz, Pinc, exponent, altlon, altlat, event_code, altdepth, epoch, clusterid   > "cmt.dat"
      #   }

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
    [[ -e cmt.dat ]] && mv cmt.dat ../${F_CMT}

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
  info_msg "Removing earthquakes with poorly determined origin depths"
  [[ $REMOVE_DEFAULTDEPTHS_WITHPLOT -eq 1 ]] && info_msg "Plotting removed events separately"
  # Plotting in km instead of in map geographic coords.
  gawk < ${F_SEIS}eqs.txt -v defdepmag=$REMOVE_DEFAULTDEPTHS_MAXMAG '{
    if ($4 <= defdepmag) {
      if ($3 == 10 || $3 == 30 || $3 == 33 || $3 == 5 ||$3 == 1 || $3 == 6  || $3 == 35 ) {
        seen[$3]++
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
    gawk < ${F_SEIS}eqs.txt -v str=$SEISSTRETCH -v sref=$SEISSTRETCH_REFMAG '{print $1, $2, $3, ($4^str)/(sref^(str-1)), $5, $6, $7, $8}' > ${F_SEIS}eqs_scaled.txt
  fi
fi



################################################################################
#####           Calculate plate motions                                    #####
################################################################################

if [[ $plotplates -eq 1 ]]; then

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
  gmt spatial $PLATES -R$MINLON/$MAXLON/$MINLAT/$MAXLAT -C $VERBOSE | gawk  '{print $1, $2}' > ${F_PLATES}map_plates_clip_a.txt

  # Some cases will fail with the Antarctica plate being included but only along the lower
  # edge of the map, messing up everything.

  # THIS NEEDS TO BE ACTUALLY SOLVED - THIS IS CURRENTLY A HACK THAT REMOVES an FROM ALL MODELS!

  gawk < ${F_PLATES}map_plates_clip_a.txt -v minlat="$MINLAT" -v maxlat="$MAXLAT" -v minlon="$MINLON" -v maxlon="$MAXLON" '
  BEGIN {
    dontprint=0
  }
  ($1 == ">") {
    if (substr($2,1,2) == "an") {
      dontprint=1
    } else {
      dontprint=0
    }
  }
  {
    if (dontprint==0) {
      print
    }
  }' > stripan.txt
  mv stripan.txt ${F_PLATES}map_plates_clip_a.txt



  # Stupid tests for longitude range because gmt spatial has problem cutting everywhere
  if [[ $(echo "$MINLON < -180 && $MAXLON > -180" | bc) -eq 1 ]]; then
    echo "Also cutting on other side of dateline neg:"
    MINLONCUT=$(echo "${MINLON}+360" | bc -l)
    echo gmt spatial $PLATES -R${MINLONCUT}/180/$MINLAT/$MAXLAT -C
    gmt spatial $PLATES -R${MINLONCUT}/180/$MINLAT/$MAXLAT -C $VERBOSE | gawk  '{print $1, $2}' >> ${F_PLATES}map_plates_clip_a.txt
  elif [[ $(echo "$MINLON < 180 && $MAXLON > 180" | bc) -eq 1 ]]; then
    echo "Also cutting on other side of dateline pos:"
    MAXLONCUT=$(echo "${MAXLON}-360" | bc -l)
    echo gmt spatial $PLATES -R-180/${MAXLONCUT}/$MINLAT/$MAXLAT -C
    gmt spatial $PLATES -R-180/${MAXLONCUT}/$MINLAT/$MAXLAT -C $VERBOSE | gawk  '{print $1, $2}' >> ${F_PLATES}map_plates_clip_a.txt
  elif [[ $(echo "$MINLON >= 180 && $MAXLON > 180 && $MAXLON <= 360" | bc) -eq 1 ]]; then
    MINLONFIX=$(echo "${MINLON} - 360" | bc -l)
    MAXLONFIX=$(echo "${MAXLON} - 360" | bc -l)
    echo gmt spatial $PLATES -R${MINLONFIX}/${MAXLONFIX}/$MINLAT/$MAXLAT -C
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
    gawk < $POLES '{print $1}' | tr '\n' '\t'
    echo ""
    echo "Plates within AOI":
    gawk < ${F_PLATES}plate_id_list.txt '{
      split($1, v, "_");
      for(i=1; i<length(v); i++) {
        printf "%s\n", v[i]
      }
    }' | tr '\n' '\t'
    echo ""
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


      gawk < ${F_PLATES}geodin.txt '{print $1, $2, $3, $4}' | gawk  '
      @include "tectoplot_functions.awk"
      # function acos(x) { return atan2(sqrt(1-x*x), x) }
          {
            if ($1 == ">") {
              # nothing
              # print $1, $2;
              fake=1
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
              printf "%.5f %.5f %.3f %.3f %s %s %s %s\n", lonMid*180/3.14159265358979, latMid*180/3.14159265358979, (theta*180/3.14159265358979+360-90)%360, d, $1, $2, $3, $4;
            };
          }' > ${F_PLATES}plateazfile_withpts.txt

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
    echo "REFPLATE is ${REFPLATE}"
    if [[ $defaultrefflag -eq 1 ]]; then
      # ITRF08 is likely similar to other reference frames.
      GPS_FILE=$(echo ${GPSDIR}"/GPS_ITRF08.gmt")
    else
      # REFPLATE now ends in a _X code to accommodate multiple subplates with the same pole.
      # This will break if _X becomes _XX (10 or more sub-plates)
      RGP=${REFPLATE::${#REFPLATE}-2}
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
			CX = 1/(6*AS)*SXS;
			CY = 1/(6*AS)*SYS;
			print CX "," CY
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
      gawk -f $EULERVEC_AWK -v eLat_d1=$pllat -v eLon_d1=$pllon -v eV1=$plrate -v eLat_d2=$reflat -v eLon_d2=$reflon -v eV2=$refrate ${F_PLATES}${v[$i]}_gridpts.txt > ${F_PLATES}${v[$i]}_velocities.txt
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
        grep -v ">" ${F_PLATES}${v[$i]}.pldat | grep "\S" | gawk  -v plat=$polelat -v plon=$polelon '
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

        # Transform to psvelo format for later plotting
        paste -d ' ' ${F_PLATES}${v[$i]}_smallcirc_gridpts.txt ${F_PLATES}${v[$i]}_smallcirc_velocities.txt | gawk  '{print $1, $2, $3*100, $4*100, 0, 0, 1, "ID"}' > ${F_PLATES}${v[$i]}_smallcirc_platevecs.txt
      fi # small circles
    fi

	  i=$i+1
	  j=$j+1
  done # while (Iterate over plates calculating pldat, centroids, and poles

  # Create the plate labels at the centroid locations
	paste -d ',' ${F_PLATES}map_centroids.txt ${F_PLATES}plate_id_list.txt > ${F_PLATES}map_labels.txt

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

      gawk -f $EULERVECLIST_AWK ${F_PLATES}id_pts.txt > ${F_PLATES}id_pts_euler_half.txt

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

### MODULE CALCULATION FUNCTIONS

for this_mod in ${TECTOPLOT_ACTIVE_MODULES[@]}; do
  if type "tectoplot_calculate_${this_mod}" >/dev/null 2>&1; then
    info_msg "Running module data calculations for ${this_mod}"
    cmd="tectoplot_calculate_${this_mod}"
    "$cmd"
  fi
done




if [[ $sprofflag -eq 1 || $aprofflag -eq 1 || $cprofflag -eq 1 || $kprofflag -eq 1 ]]; then
  plots+=("mprof")
fi

################################################################################
################################################################################
#####           Create CPT files for coloring grids and data               #####
################################################################################
################################################################################

# These are a series of fixed CPT files that we can refer to when we wish. They
# are not modified and don't need to be copied to tempdir.

[[ ! -e $CPTDIR"grayhs.cpt" || $remakecptsflag -eq 1 ]] && gmt makecpt -Cgray,gray -T-10000/10000/10000 ${VERBOSE} > $CPTDIR"grayhs.cpt"
[[ ! -e $CPTDIR"whitehs.cpt" || $remakecptsflag -eq 1 ]] && gmt makecpt -Cwhite,white -T-10000/10000/10000 ${VERBOSE} > $CPTDIR"whitehs.cpt"
[[ ! -e $CPTDIR"cycleaz.cpt" || $remakecptsflag -eq 1 ]] && gmt makecpt -Cred,green,blue,yellow,red -T-180/180/1 -Z $VERBOSE > $CPTDIR"cycleaz.cpt"
[[ ! -e $CPTDIR"defaultpt.cpt" || $remakecptsflag -eq 1 ]] && gmt makecpt -Cred,yellow,green,blue,orange,purple,brown -T0/2000/1 -Z $VERBOSE > $CPTDIR"defaultpt.cpt"
[[ ! -e $CPTDIR"platevel_one.cpt" || $remakecptsflag -eq 1 ]] && gmt makecpt -Chaxby -T0/1/0.05 -Z $VERBOSE > $CPTDIR"platevel_one.cpt"

################################################################################
##### Create required CPT files in the temporary directory




for cptfile in ${cpts[@]} ; do
	case $cptfile in

    tomography)
      gmt makecpt -C${CPTDIR}tomography.cpt -I -T-1/1/0.1 -D > ${F_CPTS}tomography.cpt
    ;;

    eqtime)

      gmt makecpt -T${COLOR_TIME_START}/${COLOR_TIME_END}+n10 -C${EQ_TIME_DEF} ${VERBOSE} | gawk -v timestart=${COLOR_TIME_START_TEXT} -v timeend=${COLOR_TIME_END_TEXT} -v timestart_s=${COLOR_TIME_START} -v timeend_s=${COLOR_TIME_END} '
        BEGIN {
          if (timeend_s-timestart_s > 60*60*24*365.25 * 5) {
            # Greater than 5 years
            endstr_start=4
            endstr_end=4
          } else if (timeend_s-timestart_s >= 60*60*24*365.25 * 1) {
            # Greater than or equal to 1 year but less than 5 years
            endstr_start=4
            endstr_end=4
          } else if (timeend_s-timestart_s < 60*60*24*365.25 * 1) {
            # Less than one year - use full timestring
            endstr_start=19
            endstr_end=19
            if (substr(timeend, 17, 3) == ":00") {
              endstr_end=16
            }
            if (substr(timestart, 17, 3) == ":00") {
              endstr_start=16
            }
          }
          gsub(/T/, " ", timestart)
          gsub(/T/, " ", timeend)
          gsub(/-/, "/", timestart)
          gsub(/-/, "/", timeend)
        }

        {
          if ($1=="B") {
            print oldstr, ";", substr(timeend,1,endstr_end)
          } else if ($1+0 != $1) {
            if ($2=="white") {
              $2="gray"
            }
            print
          } else {
            if (NR!=1) {
              if (NR==2) {
                print oldstr, ";" substr(timestart,1,endstr_start)
              } else {
                print oldstr, ";"
              }
            }
            oldstr=$0
          }
        }' > ${F_CPTS}"eqtime.cpt"

        # echo gmt makecpt -T${COLOR_TIME_START}/${COLOR_TIME_END}+n10 -C${EQ_TIME_DEF} ${VERBOSE}
        gmt makecpt -T${COLOR_TIME_START}/${COLOR_TIME_END}+n10 -C${EQ_TIME_DEF} ${VERBOSE} | gawk -v timestart=${COLOR_TIME_START_TEXT} -v timeend=${COLOR_TIME_END_TEXT} '
          BEGIN {
            OFMT="%.12f"
            if (timeend_s-timestart_s > 60*60*24*365.25 * 5) {
              # Greater than 5 years
              endstr_start=4
              endstr_end=4
            } else if (timeend_s-timestart_s >= 60*60*24*365.25 * 1) {
              # Greater than or equal to 1 year but less than 5 years
              endstr_start=4
              endstr_end=4
            } else if (timeend_s-timestart_s < 60*60*24*365.25 * 1) {
              # Less than one year - use full timestring
              endstr_start=19
              endstr_end=19
              if (substr(timeend, 17, 3) == ":00") {
                endstr_end=16
              }
              if (substr(timestart, 17, 3) == ":00") {
                endstr_start=16
              }
            }
            gsub(/T/, " ", timestart)
            gsub(/T/, " ", timeend)
            gsub(/-/, "/", timestart)
            gsub(/-/, "/", timeend)
          }

          {
            if ($1=="B") {
              print oldstr, ";", substr(timeend,1,endstr_end)
              print
            } else if ($1+0 != $1) {
              if ($2=="white") {
                $2="gray"
              }
              print
            } else {
              if (NR!=1) {
                if (NR==2) {
                  print oldstr, ";" substr(timestart,1,endstr_start)
                } else {
                  print oldstr, ";"
                }
              }
              $1=$1/10000000
              $3=$3/10000000
              oldstr=sprintf("%f %s %f %s", $1, $2, $3, $4)
            }
          }' > ${F_CPTS}"eqtime_cmt.cpt"
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
    #   gmt makecpt -Chot -I -Do -T$SLIPMINIMUM/$SLIPMAXIMUM/0.1 -N $VERBOSE > $FAULTSLIP_CPT
    #   ;;

    # geoage)
    #   cp ${CPTDIR}geoage.cpt ${GEOAGE_CPT}
    # ;;

    plateid)
      gmt makecpt -Ccategorical -Ww -T0/100/1 ${VERBOSE} > ${PLATEID_CPT}
    ;;

    grav) # WGM gravity maps
      touch $GRAV_CPT
      GRAV_CPT=$(abs_path $GRAV_CPT)
      if [[ $rescalegravflag -eq 1 ]]; then
        # gmt grdcut $GRAVDATA -R$MINLON/$MAXLON/$MINLAT/$MAXLAT -Ggravtmp.nc
        zrange=$(grid_zrange $GRAVDATA -R$MINLON/$MAXLON/$MINLAT/$MAXLAT -C -Vn)
        info_msg "Grav raster range is: $zrange"
        MINZ=$(echo $zrange | gawk  '{print int($1/100)*100}')
        MAXZ=$(echo $zrange | gawk  '{print int($2/100)*100}')
        # GRAVCPT is set by the type of gravity we selected (BG, etc) and is not the same as GRAV_CPT
        info_msg "Rescaling gravity CPT to $MINZ/$MAXZ"
        gmt makecpt -C$GRAVCPT -T$MINZ/$MAXZ $VERBOSE > $GRAV_CPT
      else
        gmt makecpt -C$GRAVCPT -T-500/500 $VERBOSE > $GRAV_CPT
      fi
      ;;

    gravcurv)
      touch $GRAV_CURV_CPT
      GRAV_CURV_CPT=$(abs_path $GRAV_CURV_CPT)
      if [[ $rescalegravflag -eq 1 ]]; then
        # gmt grdcut $GRAVDATA -R$MINLON/$MAXLON/$MINLAT/$MAXLAT -Ggravtmp.nc
        zrange=$(grid_zrange $GRAV_CURV_DATA -R$MINLON/$MAXLON/$MINLAT/$MAXLAT -C -Vn)
        info_msg "Grav curvature raster range is: $zrange"
        MINZ=$(echo $zrange | gawk  '{print int($1/100)*100}')
        MAXZ=$(echo $zrange | gawk  '{print int($2/100)*100}')
        # GRAVCPT is set by the type of gravity we selected (BG, etc) and is not the same as GRAV_CPT
        info_msg "Rescaling gravity curvature CPT to $MINZ/$MAXZ"
        gmt makecpt -C$GRAV_CURV_DEF -T$MINZ/$MAXZ $VERBOSE > $GRAV_CURV_CPT
      else
        gmt makecpt -C$GRAV_CURV_DEF -T-100/100 $VERBOSE > $GRAV_CURV_CPT
      fi
      ;;

    litho1)

      gmt makecpt -T${LITHO1_MIN_DENSITY}/${LITHO1_MAX_DENSITY}/10 -C${LITHO1_DENSITY_BUILTIN} -Z $VERBOSE > $LITHO1_DENSITY_CPT
      gmt makecpt -T${LITHO1_MIN_VELOCITY}/${LITHO1_MAX_VELOCITY}/10 -C${LITHO1_VELOCITY_BUILTIN} -Z $VERBOSE > $LITHO1_VELOCITY_CPT
      ;;


    # oceanage)
    #   if [[ $stretchoccptflag -eq 1 ]]; then
    #     # The ocean CPT has a long 'purple' tail that isn't useful when stretching the CPT
    #     gawk < $OC_AGE_CPT '{ if ($1 < 180) print }' > ./oceanage_cut.cpt
    #     printf "B\twhite\n" >> ./oceanage_cut.cpt
    #     printf "F\tblack\n" >> ./oceanage_cut.cpt
    #     printf "N\t128\n" >> ./oceanage_cut.cpt
    #     gmt makecpt -C./oceanage_cut.cpt -T0/$OC_MAXAGE/10 $VERBOSE > ./oceanage.cpt
    #     OC_AGE_CPT="./oceanage.cpt"
    #   fi
    #   ;;

    platevel)
    # Don't do anything until we move the calculation from the plotting section to above
      ;;

    # population)
    #   touch $POPULATION_CPT
    #   POPULATION_CPT=$(abs_path $POPULATION_CPT)
    #   gmt makecpt -C${CITIES_CPT} -I -Do -T0/1000000/100000 -N $VERBOSE > $POPULATION_CPT
    #   ;;

    slipratedeficit)
      gmt makecpt -Cseis -Do -I -T0/1/0.01 -N > $SLIPRATE_DEF_CPT
      ;;

    topo)

      if [[ $useowntopoctrlflag -eq 0 ]]; then
        topoctrlstring=$DEFAULT_TOPOCTRL
      fi
      if [[ $dontcolortopoflag -eq 0 ]]; then
        info_msg "Adding color stretch to topoctrlstring"
        topoctrlstring=${topoctrlstring}"c"
      fi

      info_msg "Plotting topo from $BATHY: control string is ${topoctrlstring}"
      touch $TOPO_CPT
      TOPO_CPT=$(abs_path $TOPO_CPT)
      if [[ $customgridcptflag -eq 1 ]]; then
        info_msg "Copying custom CPT file $CUSTOMCPT to temporary directory"
        cp $CUSTOMCPT $TOPO_CPT
      else
        # info_msg "Building default TOPO CPT file from $TOPO_CPT_DEF"
        # gmt makecpt -Fr -C${TOPO_CPT_DEF} -T${TOPO_CPT_DEF_MIN}/${TOPO_CPT_DEF_MAX}/${TOPO_CPT_DEF_STEP}  $VERBOSE > $TOPO_CPT

      # Now we need to generate a reasonable CPT file
      # Requirements:
      # 1. Respect hinge at Z=0 (ensure Z=0 is a slice)
      # 2. Not exceed the vertical range zmin, zmax of the dataset except for rounding
      # 3. Either stretch or not stretch the CPT range as required by -tr
      # 4. Not bug out when the grid range exceeds the input CPT range (-9234 m vs -8000 m)
      # 5. The annotation interval is known and reasonable

      # Strategy:

      # 1. Determine the range of the DEM

      zrange=$(grid_zrange $BATHY -R$MINLON/$MAXLON/$MINLAT/$MAXLAT -C -Vn)
      MINZ=$(echo $zrange | gawk  '{printf "%d\n", $1}')
      MAXZ=$(echo $zrange | gawk  '{printf "%d\n", $2}')

      # if [[ $(echo "$MINZ < 0 && $MAXZ > 0" | bc) -eq 1 ]]; then
      #   # echo "Grid range crosses 0"
      #   zrangecrosses0flag=1
      # fi

      # 2. Determine the (rounded) z-range of the CPT file

      gmt makecpt -C${TOPO_CPT_DEF} > ${F_CPTS}first.cpt

      if [[ $usedirectcptflag -eq 1 ]]; then
        mv ${F_CPTS}first.cpt ${F_CPTS}new_extended_2.cpt
      else

        # 1.1. Use a 1 meter step spacing to avoid losing contrast

        SPACING_D=1
        # $(echo ${MINZ} ${MAXZ} | gawk '
        #   {
        #     if ($2-$1 > 5000) {
        #       print 1
        #     } else if ($2-$1 > 2500) {
        #       print 5000
        #     } else if ($2-$1 > 1250) {
        #       print 250
        #     } else if ($2-$1 > 500) {
        #       print 100
        #     } else {
        #       print 10
        #     }
        #   }')

        CPT_ZRANGE=($(gawk <  ${F_CPTS}first.cpt '
          BEGIN {
            getline
            haszero=0
            minz=($1<$3)?$1:$3
            maxz=($1>$3)?$1:$3
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
            print minz, maxz, haszero
          }'))


        # CPT_HAS_ZERO=${CPT_ZRANGE[2]}

        # If the input CPT is symmetric about 0 and has a 0 slice, then rescaling will by symmetric about 0
        # If


        if [[ $rescaletopoflag -eq 1 ]]; then

          # Stretch the CPT to fit the requested range
          if [[ ${RESCALE_CPT_MIN} == "none" ]]; then
            RESCALE_CPT_MIN=${MINZ}
          fi
          if [[ ${RESCALE_CPT_MAX} == "none" ]]; then
            RESCALE_CPT_MAX=${MAXZ}
          fi
          if [[ ${RESCALE_CPT_SPACING} == "none" ]]; then
            RESCALE_CPT_SPACING=${SPACING_D}
          fi
          gmt makecpt ${TOPO_CPT_TYPE} -C${TOPO_CPT_DEF} -T${RESCALE_CPT_MIN}/${RESCALE_CPT_MAX}/${RESCALE_CPT_SPACING} -Fr > ${F_CPTS}respaced.cpt
        else
          gmt makecpt ${TOPO_CPT_TYPE} -C${TOPO_CPT_DEF} -T${CPT_ZRANGE[0]}/${CPT_ZRANGE[1]}/${SPACING_D} -Fr > ${F_CPTS}respaced.cpt
        fi

        if [[ $multiplyrescaletopoflag -eq 1 ]]; then
          multiply_scale_cpt ${F_CPTS}respaced.cpt ${MULT_CPT_BELOW} ${MULT_CPT_ABOVE} > ${F_CPTS}mult_scaled.cpt
          cp ${F_CPTS}mult_scaled.cpt ${F_CPTS}respaced.cpt
        fi

        replace_gmt_colornames_rgb  ${F_CPTS}respaced.cpt >  ${F_CPTS}respaced_rgb1.cpt

        # Check whether a z-slice line starts with 0.

        # CPT_HAS_ZERO=($(gawk <  ${F_CPTS}respaced_rgb1.cpt '
        #   BEGIN {
        #     haszero=0
        #   }
        #   ($1==0) {
        #     haszero=1
        #   }
        #   END {
        #     print haszero
        #   }'))

        # Detect whether the CPT file crosses 0 but does not have a 0 z slice


        CPT_ZRANGE=($(gawk <  ${F_CPTS}respaced_rgb1.cpt '
          BEGIN {
            getline
            haszero=0
            minz=($1<$3)?$1:$3
            maxz=($1>$3)?$1:$3
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
            print minz, maxz, haszero
          }'))

          CPT_HAS_ZERO=${CPT_ZRANGE[2]}
          # echo range is ${CPT_ZRANGE[@]} "/" ${CPT_HAS_ZERO}
          # echo "${CPT_ZRANGE[1]} > 0 && ${CPT_ZRANGE[0]} < 0"

        if [[ $(echo "${CPT_ZRANGE[1]} > 0 && ${CPT_ZRANGE[0]} < 0" | bc) -eq 1 ]]; then
          if [[ $CPT_HAS_ZERO -eq 0 ]]; then
            echo "CPT needs to have a 0 slice added"
            gawk <  ${F_CPTS}respaced_rgb1.cpt '
              BEGIN {
                getline
                last_c1=$2
                last_c2=$4
                printed_zero=0
                print
              }
              ($1+0==$1) {
                if ($1>0 && printed_zero==0) {
                  print 0, last_c2, $1, last_c2
                  printed_zero=1
                }
                print
                last_c1=$2
                last_c2=$4
              }
              ($1+0!=$1) {
                print
              }' >  ${F_CPTS}new_0slice.cpt
            cp  ${F_CPTS}new_0slice.cpt  ${F_CPTS}respaced_rgb.cpt
            CPT_HAS_ZERO=1
          else
            cp ${F_CPTS}respaced_rgb1.cpt ${F_CPTS}respaced_rgb.cpt
          fi
        else
            if [[ -s ${F_CPTS}respaced_rgb1.cpt ]]; then
              cp ${F_CPTS}respaced_rgb1.cpt  ${F_CPTS}respaced_rgb.cpt
            fi
        fi


        # echo "Need to extend range of CPT file to cover data: $MINZ $MAXZ ${CPT_ZRANGE[0]} ${CPT_ZRANGE[1]}?"

        # If our data range crosses 0, minZ<=0 and maxz>=0
          EXTEND_D=($(echo ${MINZ} ${MAXZ} | gawk '
            {
              if ($1<0 && $2<0) {
                endv=0-$1
              } else if ($1<0 && $2>0) {
                if ((0-$1) > $2) {
                  endv=0-$1
                } else {  # ($1>0 and $2 > 0)
                  endv=$2
                }
              } else if ($1>= 0 && $2 >= 0) {
                endv=$2
              }
              # print "range", $2-$1 > "/dev/stderr"
              if ($2-$1 > 5000) {
                x=10**(length(int(endv))-1);
                print x*int((endv/x)+0.5)+1000, 2000
              } else if ($2-$1 > 2500) {
                x=10**(length(int(endv))-1);
                print x*int((endv/x)+0.5)+1000, 1000
              } else if ($2-$1 > 1250) {
                x=10**(length(int(endv))-1);
                print x*int((endv/x)+0.5)+1000, 500
              } else if ($2-$1 > 500) {
                x=10**(length(int(endv))-1);
                print x*int((endv/x)+0.5)+1000, 200
              } else {
                x=10**(length(int(endv))-1);
                print x*int((endv/x)+0.5)+1000, 20
              }
            }'))

          extend_val=${EXTEND_D[0]}
          extend_int=${EXTEND_D[1]}

          # echo "minz=${MINZ} maxz=${MAXZ} extend val is ${extend_val} range is ${extend_int}"

          gawk < ${F_CPTS}respaced_rgb.cpt -v extv=${extend_val} '
            BEGIN {
              getline
              if ($1 > 0-extv) {
                print 0-extv, $2, $1, $2
              }
              print $1, $2, $3, $4
              last1=$1
              last2=$2
              last3=$3
              last4=$4
            }
            ($1=="B") {
              # if (last3 != extv) {
                # Ensure we do not have a zslice with dz=0
              print last3, last4, extv, last4
              # }
              print
            }
            ($1+0==$1) {

              if ($1+0 <= extv) {
                print $1, $2, $3, $4
                last1=$1
                last2=$2
                last3=$3
                last4=$4
              }

              # if ($1+0 < extv) {
              #   print $1, $2, $3, $4

              # } else {
              #   print "Did not qualify", $0
              # }

            }
            ($1+0!=$1 && $1 != "B") {
              print
            }' >  ${F_CPTS}new_extended.cpt

            # If the maximum between-slice interval of the CPT is larger than extend_int, we can't proceed.

            # cat ${F_CPTS}new_extended.cpt

            # gawk < ${F_CPTS}new_extended.cpt '
            #   BEGIN {
            #     getline
            #     last_z=$1
            #     min_dz=0
            #   }
            #   ($1+0==$1) {
            #     # print "examining", $1, "last is", last_z > "/dev/stderr"
            #     if ($1-last_z > min_dz) {
            #       min_dz=$1-last_z
            #       # print "Grew to " $1 " - " last_z " = " min_dz
            #     }
            #     last_z=$1
            #   }
            #   # ($1+0 != $1) {
            #   #   print "Not:"
            #   #   print
            #   # }
            #   END {
            #     print "min_dz is", min_dz
            #   }'


            # echo gmt makecpt -C${F_CPTS}new_extended.cpt -T-${extend_val}/${extend_val}/${extend_int} -Fr
            # gmt makecpt ${TOPO_CPT_TYPE} -C${F_CPTS}new_extended.cpt -G-${extend_val}/${extend_val} -T-${extend_val}/${extend_val}/${extend_int} -Fr >  ${F_CPTS}new_resampled.cpt
            gawk <  ${F_CPTS}new_extended.cpt -v minz=${MINZ} -v maxz=${MAXZ} '
              ($1+0==$1) {
                if ($3 > minz && $1 < maxz) {
                  if ($3 > maxz) {
                    $3=maxz
                  }
                  if ($1 < minz) {
                    $1=minz
                  }
                  print
                }
              }
              ($1+0!=$1) {
                print
              }' > ${F_CPTS}new_extended_2.cpt

              gmt makecpt ${TOPO_CPT_TYPE} -C${F_CPTS}new_extended_2.cpt -T-${extend_val}/${extend_val}/${extend_int} -Fr > ${F_CPTS}new_resampled.cpt


        # gmt makecpt
        # 	-T Make evenly spaced color boundaries from <min> to <max> in steps of <inc>.
        # 	-F Select the color model for output (R for r/g/b or grayscale or colorname,
  	    #      r for r/g/b only, h for h-s-v, c for c/m/y/k) [Default uses the input model]
        #	  -G Truncate incoming CPT to be limited to the z-range <zlo>/<zhi>.
  	    #      To accept one of the incoming limits, set that limit to NaN.
        #   -D Set back- and foreground color to match the bottom/top limits
  	    #      in the output CPT [Default uses color table]. Append i to match the
  	    #      bottom/top values in the input CPT.

        # COMEBACK

        # if [[ $rescaletopoflag -eq 1 ]]; then
        #   info_msg "Rescaling topo $BATHY with CPT to $MINZ/$MAXZ with hinge at 0"
        #   gmt makecpt -Fr -C$TOPO_CPT_DEF -T$MINZ/$MAXZ/${TOPO_CPT_DEF_STEP}  ${VERBOSE} > topotmp.cpt
        #
        # else
        #   info_msg "Resampling topo $BATHY  CPT to within existing $MINZ/$MAXZ"
        #   # gmt makecpt -Fr -C$TOPO_CPT_DEF -G$MINZ/$MAXZ -T$MINZ/$MAXZ/${TOPO_CPT_DEF_STEP}  ${VERBOSE} > topotmp.cpt
        #   gmt makecpt -Fr -C$TOPO_CPT_DEF -T$MINZ/$MAXZ/${TOPO_CPT_DEF_STEP}  ${VERBOSE} > topotmp.cpt
        # fi
        #
        # mv topotmp.cpt $TOPO_CPT
        # GDIFFZ=$(echo "($MAXZ - $MINZ) > 4000" | bc)  # Scale range is greater than 4 km
        # # Set the interval value for the legend scale based on the range of the data
        # if [[ $GDIFFZ -eq 1 ]]; then
        #   BATHYXINC=2
        # else
        #   BATHYXINC=$(echo "($MAXZ - $MINZ) / 6 / 1000" | bc -l | gawk  '{ print int($1/0.1)*0.1}')
        # fi
        # GDIFFZ=$(echo "($MAXZ - $MINZ) < 1000" | bc) # Scale range is lower than 1 km
        # # Set the interval value for the legend scale based on the range of the data
        # if [[ $GDIFFZ -eq 1 ]]; then # Just use 100 meters for now
        #   BATHYXINC=0.1
        # fi
        # GDIFFZ=$(echo "($MAXZ - $MINZ) < 100" | bc) # Scale range is lower than 1 km
        # # Set the interval value for the legend scale based on the range of the data
        # if [[ $GDIFFZ -eq 1 ]]; then # Just use 100 meters for now
        #   BATHYXINC=0.01
        # fi
      fi
    fi

    CPT_ZRANGE_2=($(gawk <  ${F_CPTS}new_extended_2.cpt '
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

      # echo here ${CPT_ZRANGE_2[@]} $(echo "${CPT_ZRANGE_2[1]} - ${CPT_ZRANGE_2[0]}" | bc -l )

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

      # echo BATHYXINC=${BATHYXINC}

      cp ${F_CPTS}new_extended_2.cpt ${TOPO_CPT}


    ;;

    seisdepth)
      info_msg "Making seismicity vs depth CPT: maximum depth EQs at ${EQMAXDEPTH_COLORSCALE}"
      touch $SEISDEPTH_CPT
      # Make a constant color CPT
      if [[ $seisfillcolorflag -eq 1 ]]; then
        gmt makecpt -C${ZSFILLCOLOR} -Do -T0/6371 -Z $VERBOSE > $SEISDEPTH_CPT
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
    for this_mod in ${TECTOPLOT_MODULES[@]}; do
      if type "tectoplot_cpt_${this_mod}" >/dev/null 2>&1; then
        # info_msg "Running module post-processing for ${cptfile}"
        cmd="tectoplot_cpt_${this_mod}"
        "$cmd" ${cptfile}
      fi
      if [[ $tectoplot_cpt_caught -eq 1 ]]; then
        break
      fi
    done
    ;;

  esac
done

if [[ $noplotflag -ne 1 ]]; then

################################################################################
################################################################################
##### Plot the postscript file by calling the sections listed in $plots[@] #####
################################################################################
################################################################################

# Add a PS comment with the command line used to invoke tectoplot. Use >> as we might
# be adding this line onto an already existing PS file

echo "%TECTOPLOT: ${COMMAND}" >> map.ps

# Before we plot anything but after we have done the data processing, set any
# GMT variables that are given on the command line using -gmtvars { A val ... }

################################################################################
#####          GMT media and map style management                          #####
################################################################################

# Page options
# Just make a giant page and trim it later using gmt psconvert -A+m

gmt gmtset PS_PAGE_ORIENTATION portrait PS_MEDIA 100ix100i

# Map frame options

echo "gmt gmtset FORMAT_GEO_MAP=D" >> makemap.sh

gmt gmtset MAP_FRAME_TYPE fancy MAP_FRAME_WIDTH 0.12c MAP_FRAME_PEN 0.5p,black
gmt gmtset FORMAT_GEO_MAP=D

# Font options
gmt gmtset FONT_ANNOT_PRIMARY 10 FONT_LABEL 10 FONT_TITLE 12p,Helvetica,black

# Symbol options
gmt gmtset MAP_VECTOR_SHAPE 0.5 MAP_TITLE_OFFSET 24p

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

gmt gmtset PS_PAGE_COLOR ${PAGE_COLOR}

if [[ $usecustomgmtvars -eq 1 ]]; then
  info_msg "gmt gmtset ${GMTVARS[@]}"
echo "gmt gmtset ${GMTVARS[@]}" >> makemap.sh
  gmt gmtset ${GMTVARS[@]}
fi

# The strategy for adding items to the legend is to make little baby EPS files
# and then place them onto the master PS using gmt psimage. We initialize these
# files here and then we have to keep track of whether to close the master PS
# file or keep it open for subsequent plotting (-keepopenps)

# The frame presents a bit of a problem as we have to manage different calls to
# psbasemap based on a range of options (title, no title, grid, no grid, etc.)

cleanup base_fake.ps base_fake.eps base_fake_nolabels.ps base_fake_nolabels.eps

# gmt psbasemap ${BSTRING[@]} ${SCALECMD} $RJOK $VERBOSE >> map.ps

# Note that BSTRING needs to be quoted as it has a title with spaces...

gmt psbasemap ${RJSTRING[@]} $VERBOSE -Btlbr > base_fake_nolabels.ps
if [[ $plottitleflag -eq 1 ]]; then
  gmt psbasemap ${RJSTRING[@]} "${BSTRING[@]}" $VERBOSE -K > base_fake.ps
  gmt psbasemap "-B+t\"${PLOTTITLE}\"" -R -J $VERBOSE -O >> base_fake.ps
else
  gmt psbasemap ${RJSTRING[@]} "${BSTRING[@]}" $VERBOSE > base_fake.ps
fi
gmt psxy -T -X$PLOTSHIFTX -Y$PLOTSHIFTY $OVERLAY $VERBOSE -K ${RJSTRING[@]} >> map.ps

# We can just use cp instead of running GMT so many times...

gmt psxy -T -X0i -Yc $OVERLAY $VERBOSE -K ${RJSTRING[@]} > kinsv.ps
gmt psxy -T -X0i -Yc $OVERLAY $VERBOSE -K ${RJSTRING[@]} > plate.ps
gmt psxy -T -X0i -Yc $OVERLAY $VERBOSE -K ${RJSTRING[@]} > mecaleg.ps
gmt psxy -T -X0i -Yc $OVERLAY $VERBOSE -K ${RJSTRING[@]} > seissymbol.ps
gmt psxy -T -X0i -Yc $OVERLAY $VERBOSE -K ${RJSTRING[@]} > eqlabel.ps
gmt psxy -T -X0i -Yc $OVERLAY $VERBOSE -K ${RJSTRING[@]} > velarrow.ps
gmt psxy -T -X0i -Yc $OVERLAY $VERBOSE -K ${RJSTRING[@]} > velgps.ps

cleanup kinsv.ps eqlabel.ps plate.ps mecaleg.ps seissymbol.ps volcanoes.ps velarrow.ps velgps.ps

# Something about map labels messes up the psconvert call making the bounding box wrong.
# So check the label-free width and if it is significantly less than the with-label
# width, use it instead. Shouldn't change too much honestly.

MAP_PS_DIM=$(gmt psconvert base_fake.ps -Te -A0.01i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
MAP_PS_NOLABELS_DIM=$(gmt psconvert base_fake_nolabels.ps -Te -A0.01i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
# MAP_PS_NOLABELS_BB=($(gmt psconvert base_fake_nolabels.ps -Te -A0.01i 2> >(grep -v Processing | grep -v Find | grep -v Figure | grep -v Format | head -n 1) | gawk -F'[[]' '{print $3}' | gawk -F '[]]' '{print $1}'))
# MAP_PS_WITHLABELS_BB=($(gmt psconvert base_fake.ps -Te -A0.01i 2> >(grep -v Processing | grep -v Find | grep -v Figure | grep -v Format | head -n 1) | gawk -F'[[]' '{print $3}' | gawk -F '[]]' '{print $1}'))
# MAP_ANNOT_VDIFF=$(echo )

MAP_PS_WIDTH_IN=$(echo $MAP_PS_DIM | gawk  '{print $1/2.54}')
MAP_PS_HEIGHT_IN=$(echo $MAP_PS_DIM | gawk  '{print $2/2.54}')
MAP_PS_WIDTH_NOLABELS_IN=$(echo $MAP_PS_NOLABELS_DIM | gawk  '{print $1/2.54}')
MAP_PS_HEIGHT_NOLABELS_IN=$(echo $MAP_PS_NOLABELS_DIM | gawk  '{print $2/2.54}')
info_msg "Map dimensions (in) are W: $MAP_PS_WIDTH_IN, H: $MAP_PS_HEIGHT_IN"
info_msg "No label map dimensions (in) are W: $MAP_PS_WIDTH_NOLABELS_IN, H: $MAP_PS_HEIGHT_NOLABELS_IN"

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


#### SECTION PLOT BEGIN


for plot in ${plots[@]} ; do
	case $plot in

    #  gmt psvelo ${USERGPSDATAFILE[$current_usergpsfilenumber]} -W${EXTRAGPS_LINEWIDTH},${EXTRAGPS_LINECOLOR} -G${USERGPSCOLOR_arr[$current_usergpsfilenumber]} -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0

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

      if [[ $axescmtthrustflag -eq 1 ]]; then
        # [[ $axestflag -eq 1 ]] && gawk  < ${F_KIN}t_axes_thrust.txt     -v scalev=${CMTAXESSCALE} 'function abs(v) { return (v>0)?v:-v} {print $1, $2, $3, abs(cos($4*pi/180))*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,purple -Gblack $RJOK $VERBOSE >> map.ps
        [[ $axestflag -eq 1 ]] && gmt psvelo ${F_KIN}t_axes_thrust.txt.xy -W1p,black -Gpurple -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> map.ps
        [[ $axespflag -eq 1 ]] && gmt psvelo ${F_KIN}p_axes_thrust.txt.xy -W1p,black -Gdarkblue -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> map.ps
        [[ $axesnflag -eq 1 ]] && gmt psvelo ${F_KIN}n_axes_thrust.txt.xy -W1p,black -Gdarkgreen -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> map.ps
        # [[ $axespflag -eq 1 ]] && gawk  < ${F_KIN}p_axes_thrust.txt     -v scalev=${CMTAXESSCALE} 'function abs(v) { return (v>0)?v:-v} {print $1, $2, $3, abs(cos($4*pi/180))*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,blue   -Gblack $RJOK $VERBOSE >> map.ps
        # [[ $axesnflag -eq 1 ]] && gawk  < ${F_KIN}n_axes_thrust.txt     -v scalev=${CMTAXESSCALE} 'function abs(v) { return (v>0)?v:-v} {print $1, $2, $3, abs(cos($4*pi/180))*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,green  -Gblack $RJOK $VERBOSE >> map.ps
      fi
      if [[ $axescmtnormalflag -eq 1 ]]; then
        [[ $axestflag -eq 1 ]] && gmt psvelo ${F_KIN}t_axes_normal.txt.xy -W1p,black -Gpurple -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> map.ps
        [[ $axespflag -eq 1 ]] && gmt psvelo ${F_KIN}p_axes_normal.txt.xy -W1p,black -Gdarkblue -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> map.ps
        [[ $axesnflag -eq 1 ]] && gmt psvelo ${F_KIN}n_axes_normal.txt.xy -W1p,black -Gdarkgreen -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> map.ps
        #
        # [[ $axestflag -eq 1 ]] && gawk  < ${F_KIN}t_axes_normal.txt     -v scalev=${CMTAXESSCALE} 'function abs(v) { return (v>0)?v:-v} {print $1, $2, $3, abs(cos($4*pi/180))*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,purple -Gblack $RJOK $VERBOSE >> map.ps
        # [[ $axespflag -eq 1 ]] && gawk  < ${F_KIN}p_axes_normal.txt     -v scalev=${CMTAXESSCALE} 'function abs(v) { return (v>0)?v:-v} {print $1, $2, $3, abs(cos($4*pi/180))*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,blue   -Gblack $RJOK $VERBOSE >> map.ps
        # [[ $axesnflag -eq 1 ]] && gawk  < ${F_KIN}n_axes_normal.txt     -v scalev=${CMTAXESSCALE} 'function abs(v) { return (v>0)?v:-v} {print $1, $2, $3, abs(cos($4*pi/180))*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,green  -Gblack $RJOK $VERBOSE >> map.ps
      fi
      if [[ $axescmtssflag -eq 1 ]]; then
        [[ $axestflag -eq 1 ]] && gmt psvelo ${F_KIN}t_axes_strikeslip.txt.xy -W1p,black -Gpurple -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> map.ps
        [[ $axespflag -eq 1 ]] && gmt psvelo ${F_KIN}p_axes_strikeslip.txt.xy -W1p,black -Gdarkblue -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> map.ps
        [[ $axesnflag -eq 1 ]] && gmt psvelo ${F_KIN}n_axes_strikeslip.txt.xy -W1p,black -Gdarkgreen -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 $RJOK $VERBOSE >> map.ps

        # [[ $axestflag -eq 1 ]] && gawk  < ${F_KIN}t_axes_strikeslip.txt -v scalev=${CMTAXESSCALE} 'function abs(v) { return (v>0)?v:-v} {print $1, $2, $3, abs(cos($4*pi/180))*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,purple -Gblack $RJOK $VERBOSE >> map.ps
        # [[ $axespflag -eq 1 ]] && gawk  < ${F_KIN}p_axes_strikeslip.txt -v scalev=${CMTAXESSCALE} 'function abs(v) { return (v>0)?v:-v} {print $1, $2, $3, abs(cos($4*pi/180))*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,blue   -Gblack $RJOK $VERBOSE >> map.ps
        # [[ $axesnflag -eq 1 ]] && gawk  < ${F_KIN}n_axes_strikeslip.txt -v scalev=${CMTAXESSCALE} 'function abs(v) { return (v>0)?v:-v} {print $1, $2, $3, abs(cos($4*pi/180))*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,green  -Gblack $RJOK $VERBOSE >> map.ps
      fi
      ;;

    clipon)
      info_msg "[-clipon]: Activating interior clipping using ${CLIP_POLY_FILE}"
      [[ -s ${CLIP_POLY_FILE} ]] && gmt psclip ${CLIP_POLY_FILE} ${RJOK} ${VERBOSE} >> map.ps
      ;;

    clipout)
      info_msg "[-clipout]: Activating exterior clipping using ${CLIP_POLY_FILE}"
      [[ -s ${CLIP_POLY_FILE} ]] && gmt psclip -N ${CLIP_POLY_FILE} ${RJOK} ${VERBOSE} >> map.ps
      ;;

    clipoff)
      info_msg "[-clipoff]: Deactivating clipping"
      gmt psclip -C -K -O ${VERBOSE} >> map.ps
      ;;

    clipline)
      info_msg "[-clipline]: Plotting clipping path using ${CLIP_POLY_FILE}"
      [[ -s ${CLIP_POLY_FILE} ]] && gmt psxy ${CLIP_POLY_FILE} ${CLIP_POLY_PEN} ${RJOK} ${VERBOSE} >> map.ps
      ;;

    cmt)
      info_msg "Plotting focal mechanisms"

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
            [[ -e ${F_CMT}cmt_thrust.txt ]] && gawk < ${F_CMT}cmt_thrust.txt '{temp=$3; $3=$15/10000000; $15=temp; print}' > ${F_CMT}cmt_thrust_time.txt
            CMT_THRUSTPLOT=$(abs_path ${F_CMT}cmt_thrust_time.txt)
            [[ -e ${F_CMT}cmt_normal.txt ]] && gawk < ${F_CMT}cmt_normal.txt '{temp=$3; $3=$15/10000000; $15=temp; print}' > ${F_CMT}cmt_normal_time.txt
            CMT_NORMALPLOT=$(abs_path ${F_CMT}cmt_normal_time.txt)
            [[ -e ${F_CMT}cmt_strikeslip.txt ]] && gawk < ${F_CMT}cmt_strikeslip.txt '{temp=$3; $3=$15/10000000; $15=temp; print}' > ${F_CMT}cmt_strikeslip_time.txt
            CMT_STRIKESLIPPLOT=$(abs_path ${F_CMT}cmt_strikeslip_time.txt)
          ;;
          TNP) #
          ;;
        esac
        SEIS_CPT=${F_CPTS}"eqtime_cmt.cpt"
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
        SEIS_CPT=${F_CPTS}"eqcluster.cpt"
      else
        CMT_THRUSTPLOT=$(abs_path ${F_CMT}cmt_thrust.txt)
        CMT_NORMALPLOT=$(abs_path ${F_CMT}cmt_normal.txt)
        CMT_STRIKESLIPPLOT=$(abs_path ${F_CMT}cmt_strikeslip.txt)
        SEIS_CPT=$SEISDEPTH_CPT
      fi

      if [[ $cmtthrustflag -eq 1 ]]; then
        gmt_psmeca ${SEIS_CPT} -E"${CMT_THRUSTCOLOR}" ${CMTEXTRA} -S${CMTLETTER}"$CMTRESCALE"i/0 ${CMT_THRUSTPLOT} -L${FMLPEN} $RJOK $VERBOSE >> map.ps
      fi
      if [[ $cmtnormalflag -eq 1 ]]; then
        gmt_psmeca ${SEIS_CPT} -E"${CMT_NORMALCOLOR}"  ${CMTEXTRA} -S${CMTLETTER}"$CMTRESCALE"i/0 ${CMT_NORMALPLOT} -L${FMLPEN} $RJOK $VERBOSE >> map.ps
      fi
      if [[ $cmtssflag -eq 1 ]]; then
        gmt_psmeca $SEIS_CPT -E"${CMT_SSCOLOR}" ${CMTEXTRA} ${CMT_INPUTORDER} -S${CMTLETTER}"$CMTRESCALE"i/0 ${CMT_STRIKESLIPPLOT} -L${FMLPEN} $RJOK $VERBOSE >> map.ps
      fi
      ;;

#     coasts)
#       info_msg "Plotting coastlines"
#
#       gmt pscoast $COAST_QUALITY ${RIVER_COMMAND} -W1/$COAST_LINEWIDTH,$COAST_LINECOLOR -W2/$LAKE_LINEWIDTH,$LAKE_LINECOLOR $FILLCOASTS -A$COAST_KM2 $RJOK $VERBOSE >> map.ps
#
# #      gmt pscoast $COAST_QUALITY -W1/$COAST_LINEWIDTH,$COAST_LINECOLOR $FILLCOASTS -A$COAST_KM2 $RJOK $VERBOSE >> map.ps
#       # [[ $coastplotbordersflag -eq 1 ]] &&
#       ;;

    contours)
      # Exclude options that are contained in the ${CONTOURGRIDVARS[@]} array
      AFLAG=-A$TOPOCONTOURINT
      CFLAG=-C$TOPOCONTOURINT
      SFLAG=-S$TOPOCONTOURSMOOTH

      for i in ${TOPOCONTOURVARS[@]}; do
        if [[ ${i:0:2} =~ "-A" ]]; then
          AFLAG=""
        fi
        if [[ ${i:0:2} =~ "-C" ]]; then
          CFLAG=""
        fi
        if [[ ${i:0:2} =~ "-S" ]]; then
          SFLAG=""
        fi
      done
      info_msg "Plotting topographic contours using $BATHY and contour options ${CONTOUROPTSTRING[@]}"
      gmt grdcontour $BATHY $AFLAG $CFLAG $SFLAG -W$TOPOCONTOURWIDTH,$TOPOCONTOURCOLOUR ${TOPOCONTOURVARS[@]} -Q${TOPOCONTOURMINPTS} $RJOK ${VERBOSE} >> map.ps

      ;;

    # countries)
    #   gmt pscoast -E+l -Vn | gawk -F'\t' '{print $1}' > ${F_MAPELEMENTS}countries.txt
    #   NUMCOUNTRIES=$(wc -l < ${F_MAPELEMENTS}countries.txt | gawk '{print $1+0}')
    #   gmt makecpt -N -T0/${NUMCOUNTRIES}/1 -C${COUNTRIESCPT} -Vn  | gawk '{print $2}' | sort -R > ${F_MAPELEMENTS}country_colors.txt
    #   paste ${F_MAPELEMENTS}countries.txt ${F_MAPELEMENTS}country_colors.txt | gawk '{printf("-E%s+g%s ", $1, $2)}' > ${F_MAPELEMENTS}combined.txt
    #   string=($(cat ${F_MAPELEMENTS}combined.txt))
    #   gmt pscoast ${string[@]} ${RJOK} ${VERBOSE} -t${COUNTRIES_TRANS} -Slightblue >> map.ps
    #   ;;
    #
    # countryborders)
    #   gmt pscoast ${BORDER_QUALITY} -N1/${BORDER_LINEWIDTH},${BORDER_LINECOLOR} $RJOK $VERBOSE >> map.ps
    #   ;;
    #
    # stateborders)
    #   gmt pscoast ${BORDER_STATE_QUALITY} -N2/${BORDER_STATE_LINEWIDTH},${BORDER_STATE_LINECOLOR} $RJOK $VERBOSE >> map.ps
    #   ;;
    #
    # countrylabels)
    #   gawk -F, < $COUNTRY_CODES '{ print $3, $2, $4}' | gmt pstext -F+f${COUNTRY_LABEL_FONTSIZE},${COUNTRY_LABEL_FONT},${COUNTRY_LABEL_FONTCOLOR}+jLM $RJOK ${VERBOSE} >> map.ps
    #   ;;

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

      rm -f range.dat
      # Plot AOI boxes of GMRT tiles
      for gmrtfile in ${GMRTDIR}*.nc; do
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
      gmt psxy range.dat -W1p,red ${RJOK} ${VERBOSE} >> map.ps

      rm -f range.dat
      for erfile in ${EARTHRELIEFDIR}*.nc; do
        gmt grdinfo -C ${erfile} | gawk '
          ($2+0==$2 && $3+0==$3 && $4+0==$4 && $5+0==$5 && ($3-$2)<360 && ($4-$5)<180){
            # $1 = filename $2=minlon $3=maxlon $4=minlat $5=maxlat
            print ">"
            print $2, $4
            print $2, $5
            print $3, $5
            print $3, $4
            print $2, $4
          }' >> range.dat
      done
      gmt psxy range.dat -W1p,blue ${RJOK} ${VERBOSE} >> map.ps

      rm -f range.dat
      # Plot AOI boxes of GMRT tiles
      for sentinelfile in ${SENT_DIR}*.tif; do
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
      gmt psxy range.dat -W1p,green ${RJOK} ${VERBOSE} >> map.ps




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


        if [[ $LABELSONMAP -eq 1 ]]; then
          uniq -u ${F_CMT}cmt.labels | gmt pstext -Dj${EQ_LABEL_DISTX}/${EQ_LABEL_DISTY}+v0.7p,black -Gwhite -F+f+a+j -W0.5p,black $RJOK $VERBOSE >> map.ps
        else
          # Create a 'labels only' map for easier editing
          gmt psbasemap "${BSTRING[@]}" ${RJSTRING[@]} $VERBOSE -K  > cmtlabel_map.ps
          uniq -u ${F_CMT}cmt.labels | gmt pstext -Dj${EQ_LABEL_DISTX}/${EQ_LABEL_DISTY}+v0.7p,black -Gwhite  -F+f+a+j -W0.5p,black ${RJSTRING[@]} -O $VERBOSE >> cmtlabel_map.ps
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


        [[ $EQ_LABELFORMAT == "idmag"   ]] && gawk  < ${F_SEIS}eqlabel_pos.sel '{ printf "%s\t%s\t%s\t%s\t%s\t%s(%0.1f)\n", $1, $2, $8, 0, $9, $6, $4  }' >> ${F_SEIS}eq.labels
        [[ $EQ_LABELFORMAT == "datemag" ]] && gawk  < ${F_SEIS}eqlabel_pos.sel '{ split($5,tmp,"T"); printf "%s\t%s\t%s\t%s\t%s\t%s(%0.1f)\n", $1, $2, $8, 0, $9, tmp[1], $4 }' >> ${F_SEIS}eq.labels
        [[ $EQ_LABELFORMAT == "datetime" ]] && gawk  < ${F_SEIS}eqlabel_pos.sel '{ split($5,tmp,"T"); printf "%s\t%s\t%s\t%s\t%s\t%s %s\n", $1, $2, $8, 0, $9, tmp[1], tmp[2] }' >> ${F_SEIS}eq.labels
        [[ $EQ_LABELFORMAT == "dateid"   ]] && gawk  < ${F_SEIS}eqlabel_pos.sel '{ split($5,tmp,"T"); printf "%s\t%s\t%s\t%s\t%s\t%s(%s)\n", $1, $2, $8, 0, $9, tmp[1], $6 }' >> ${F_SEIS}eq.labels
        [[ $EQ_LABELFORMAT == "id"   ]] && gawk  < ${F_SEIS}eqlabel_pos.sel '{ printf "%s\t%s\t%s\t%s\t%s\t%s\n", $1, $2, $8, 0, $9, $6  }' >> ${F_SEIS}eq.labels
        [[ $EQ_LABELFORMAT == "date"   ]] && gawk  < ${F_SEIS}eqlabel_pos.sel '{ split($5,tmp,"T"); printf "%s\t%s\t%s\t%s\t%s\t%s\n", $1, $2, $8, 0, $9, tmp[1] }' >> ${F_SEIS}eq.labels
        [[ $EQ_LABELFORMAT == "year"   ]] && gawk  < ${F_SEIS}eqlabel_pos.sel '{ split($5,tmp,"T"); split(tmp[1],tmp2,"-"); printf "%s\t%s\t%s\t%s\t%s\t%s\n", $1, $2, $8, 0, $9, tmp2[1] }' >> ${F_SEIS}eq.labels
        [[ $EQ_LABELFORMAT == "yearmag"   ]] && gawk  < ${F_SEIS}eqlabel_pos.sel '{ split($5,tmp,"T"); split(tmp[1],tmp2,"-"); printf "%s\t%s\t%s\t%s\t%s\t%s(%s)\n", $1, $2, $8, 0, $9, tmp2[1], $4 }' >> ${F_SEIS}eq.labels
        [[ $EQ_LABELFORMAT == "mag"   ]] && gawk  < ${F_SEIS}eqlabel_pos.sel '{ printf "%s\t%s\t%s\t%s\t%s\t%0.1f\n", $1, $2, $8, 0, $9, $4  }' >> ${F_SEIS}eq.labels

        if [[ $LABELSONMAP -eq 1 ]]; then
            uniq -u ${F_SEIS}eq.labels | gmt pstext -Dj${EQ_LABEL_DISTX}/${EQ_LABEL_DISTY}+v0.7p,black -Gwhite  -F+f+a+j -W0.5p,black $RJOK $VERBOSE >> map.ps
        else
            # Create a 'labels only' map for easier editing
            gmt psbasemap "${BSTRING[@]}" ${RJSTRING[@]} $VERBOSE -K  > eqlabel_map.ps
            uniq -u ${F_SEIS}eq.labels | gmt pstext -Dj${EQ_LABEL_DISTX}/${EQ_LABEL_DISTY}+v0.7p,black -Gwhite  -F+f+a+j -W0.5p,black ${RJSTRING[@]} -O $VERBOSE >> eqlabel_map.ps
        fi
      fi
      ;;

    execute)
      info_msg "Executing script $EXECUTEFILE. Be Careful!"
      source "${EXECUTEFILE}"
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
        gmt psvelo ${USERGPSDATAFILE[$current_usergpsfilenumber]} -W${EXTRAGPS_LINEWIDTH},${EXTRAGPS_LINECOLOR} -G${USERGPSCOLOR_arr[$current_usergpsfilenumber]} -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 -L $RJOK $VERBOSE >> map.ps 2>/dev/null
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
        gawk -f $EULERVEC_AWK -v eLat_d1=$eulerlat -v eLon_d1=$eulerlon -v eV1=$euleromega -v eLat_d2=0 -v eLon_d2=0 -v eV2=0 ${F_PLATES}eulergrid.txt > ${F_PLATES}gridvelocities.txt
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
        gawk -f $EULERVEC_AWK -v eLat_d1=$lat1 -v eLon_d1=$lon1 -v eV1=$rate1 -v eLat_d2=$lat2 -v eLon_d2=$lon2 -v eV2=$rate2 ${F_PLATES}eulergrid.txt > ${F_PLATES}gridvelocities.txt
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
      cat ${F_PLATES}gridplatevecs.txt | gawk  -v gpsscalefac=$VELSCALE '{ az=atan2($3, $4) * 180 / 3.14159265358979; if (az > 0) print $1, $2, az, sqrt($3*$3+$4*$4)*gpsscalefac; else print $1, $2, az+360, sqrt($3*$3+$4*$4)*gpsscalefac; }'  > ${F_PLATES}grideuler.pvec
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
    # FE_SEISMIC_ZONES=${FE_DIR}"flinn_engdahl_seismic_regions.gmt"
    # FE_SEISMIC_LABELS=${FE_DIR}"flinn_engdahl_seismic_regions_labels.txt"
    # FE_REGION_ZONES=${FE_DIR}"flinn_engdahl_geographic_regions.gmt"
    # FE_REGION_LABELS=${FE_DIR}"flinn_engdahl_geographic_regions_labels.txt"
      ;;


    gebcotid)
      gmt makecpt -Ccategorical -T1/100/1 ${VERBOSE} > ${F_CPTS}gebco_tid.cpt
      gmt grdimage $GEBCO20_TID $GRID_PRINT_RES -t50 -C${F_CPTS}gebco_tid.cpt $RJOK $VERBOSE >> map.ps

      ;;
    gemfaults)
      info_msg "Plotting GEM active faults"
      gmt psxy $GEMFAULTS -W$AFLINEWIDTH,$AFLINECOLOR $RJOK $VERBOSE >> map.ps
      ;;


    # tectonic_fabrics)
    #   for this_fabric in ${tectonic_fabrics[@]}; do
    #     case $this_fabric in
    #       cp)
    #         info_msg "[-tf]: Plotting continental polygons"
    #         gmt psxy ${TECTFABRICS_CP} -W0.1p,black+cf -aZ=PLATEID1 -C${PLATEID_CPT} $RJOK ${VERBOSE} >> map.ps
    #       ;;
    #       dz)
    #         info_msg "[-tf]: Plotting discordant zones"
    #         gmt psxy ${EARTHBYTE_DZ} -W0.5p,green $RJOK ${VERBOSE} >> map.ps
    #       ;;
    #       fz)
    #         info_msg "[-tf]: Plotting fracture zones"
    #         gmt psxy ${EARTHBYTE_FZ} -W0.5p,black $RJOK ${VERBOSE} >> map.ps
    #         gmt psxy ${EARTHBYTE_FZLC} -W0.3p,black $RJOK ${VERBOSE} >> map.ps
    #       ;;
    #       pf)
    #         info_msg "[-tf]: Plotting pseudofaults"
    #         gmt psxy ${EARTHBYTE_PF} -W0.5p,orange $RJOK ${VERBOSE} >> map.ps
    #       ;;
    #       pr)
    #         info_msg "[-tf]: Plotting propagating ridges"
    #         gmt psxy ${EARTHBYTE_PR} -W0.5p,yellow $RJOK ${VERBOSE} >> map.ps
    #       ;;
    #       sr)
    #         info_msg "[-tf]: Plotting spreading ridges"
    #         gmt psxy ${TECTFABRICS_SR} -W0.5p,red $RJOK ${VERBOSE} >> map.ps
    #       ;;
    #       va)
    #         info_msg "[-tf]: Plotting v-shaped anomalies"
    #         gmt psxy ${EARTHBYTE_UNCV} -W0.5p,white $RJOK ${VERBOSE} >> map.ps
    #         gmt psxy ${EARTHBYTE_VANOM} -W0.5p,pink $RJOK ${VERBOSE} >> map.ps
    #       ;;
    #       vp)
    #         info_msg "[-tf]: Plotting volcanic provinces" # including extinct ridges"
    #         gmt psxy ${TECTFABRICS_VP} -W0.1p,black+cf -aZ=FROMAGE -C${GEOAGE_CPT} $RJOK ${VERBOSE} >> map.ps
    #       ;;
    #     esac
    #   done
    #   ;;


    # ebiso)
    #   gmt psxy ${EARTHBYTE_ISOCHRONS_GMT} -aZ=FROMAGE -W1p+cl -C${GEOAGE_CPT} $RJOK ${VERBOSE} >> map.ps
    #   ;;
    #
    # ebhot)
    #   gmt psxy ${EARTHBYTE_HOTSPOTS_GMT} -Sc0.1i -Gred $RJOK ${VERBOSE} >> map.ps
    #   ;;

    gps)
      info_msg "Plotting GPS"
		  ##### Plot GPS velocities if possible (requires Kreemer plate to have same ID as model reference plate, or manual specification)
      if [[ $tdefnodeflag -eq 0 ]]; then
  			if [[ -e $GPS_FILE ]]; then
  				info_msg "GPS data is taken from $GPS_FILE and are plotted relative to plate $REFPLATE in that model"

          gawk < $GPS_FILE -v minlat="$MINLAT" -v maxlat="$MAXLAT" -v minlon="$MINLON" -v maxlon="$MAXLON" '{
            if ($1>180) { lon=$1-360 } else { lon=$1 }
            if (((lon <= maxlon && lon >= minlon) || (lon+360 <= maxlon && lon+360 >= minlon)) && $2 >= minlat && $2 <= maxlat) {
              print
            }
          }' > ${F_GPS}gps.txt
  				gmt psvelo ${F_GPS}gps.txt -W${GPS_LINEWIDTH},${GPS_LINECOLOR} -G${GPS_FILLCOLOR} -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 -L $RJOK $VERBOSE >> map.ps 2>/dev/null
          # generate XY data
          gawk '{ az=atan2($3, $4) * 180 / 3.14159265358979; if (az > 0) print $1, $2, az, sqrt($3*$3+$4*$4); else print $1, $2, az+360, sqrt($3*$3+$4*$4); }' < ${F_GPS}gps.txt > ${F_GPS}gps.xy
          GPSMAXVEL=$(gawk < ${F_GPS}gps.xy 'BEGIN{ maxv=0 } {if ($4>maxv) { maxv=$4 } } END {print maxv}')
    		else
  				info_msg "No relevant GPS data available for given plate model ($GPS_FILE)"
  				GPS_FILE="None"
  			fi
      fi
			;;

    graticule)
      gmt psbasemap "${BSTRING[@]}" $RJOK $VERBOSE >> map.ps
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
        # echo "$MINLON $MINLAT" > aoi_box.txt
        # echo "$MINLON $MAXLAT" >> aoi_box.txt
        # echo "$MAXLON $MAXLAT" >> aoi_box.txt
        # echo "$MAXLON $MINLAT" >> aoi_box.txt
        # echo "$MINLON $MINLAT" >> aoi_box.txt

        gmt_init_tmpdir
        gmt pscoast -Rg -JG${CENTERLON}/${CENTERLAT}/${INSET_DEGWIDTH}/${INSET_SIZE} -Xa${INSET_XOFF} -Ya${INSET_YOFF} -Bg -Df -A5000 -Ggray -Swhite -O -K ${VERBOSE} >> map.ps
        gmt psxy ${F_MAPELEMENTS}"bounds.txt" -W${INSET_AOI_LINEWIDTH},${INSET_AOI_LINECOLOR} -Xa${INSET_XOFF} -Ya${INSET_YOFF} ${VERBOSE} $RJOK >> map.ps
        gmt_remove_tmpdir
        ;;

    kinsv)
      # Plot the slip vectors for focal mechanism nodal planes
      info_msg "Plotting kinematic slip vectors; kinthrustflag=$kinthrustflag; kinnormalflag=$kinnormalflag; kinssflag=$kinssflag, NP1_COLOR=$NP1_COLOR, NP2_COLOR=$NP2_COLOR"

      if [[ $kinthrustflag -eq 1 ]]; then
        [[ $np1flag -eq 1 ]] && gmt psxy -SV0.05i+jb+e -W0.4p,${NP1_COLOR} -G${NP1_COLOR} ${F_KIN}thrust_gen_slip_vectors_np1.txt $RJOK $VERBOSE >> map.ps
        [[ $np2flag -eq 1 ]] && gmt psxy -SV0.05i+jb+e -W0.4p,${NP2_COLOR} -G${NP2_COLOR} ${F_KIN}thrust_gen_slip_vectors_np2.txt $RJOK $VERBOSE >> map.ps
      fi
      if [[ $kinnormalflag -eq 1 ]]; then
        [[ $np1flag -eq 1 ]] && gmt psxy -SV0.05i+jb+e -W0.4p,${NP1_COLOR} -G${NP1_COLOR} ${F_KIN}normal_slip_vectors_np1.txt $RJOK $VERBOSE >> map.ps
        [[ $np2flag -eq 1 ]] && gmt psxy -SV0.05i+jb+e -W0.4p,${NP2_COLOR} -G${NP2_COLOR} ${F_KIN}normal_slip_vectors_np2.txt $RJOK $VERBOSE >> map.ps
      fi
      if [[ $kinssflag -eq 1 ]]; then
        [[ $np1flag -eq 1 ]] && gmt psxy -SV0.05i+jb+e -W0.4p,${NP1_COLOR} -G${NP1_COLOR} ${F_KIN}strikeslip_slip_vectors_np1.txt $RJOK $VERBOSE >> map.ps
        [[ $np2flag -eq 1 ]] && gmt psxy -SV0.05i+jb+e -W0.4p,${NP2_COLOR} -G${NP2_COLOR} ${F_KIN}strikeslip_slip_vectors_np2.txt $RJOK $VERBOSE >> map.ps
      fi
      ;;

    kingeo)
      info_msg "Plotting kinematic data"
      # Currently only plotting strikes and dips of thrust mechanisms
      if [[ kinthrustflag -eq 1 ]]; then
        # Plot dip line of NP1
        [[ np1flag -eq 1 ]] && gmt psxy -SV0.05i+jb -W0.5p,red -Gwhite ${F_KIN}thrust_gen_slip_vectors_np1_downdip.txt $RJOK $VERBOSE >> map.ps
        # Plot strike line of NP1
        [[ np1flag -eq 1 ]] && gmt psxy -SV0.05i+jc -W0.5p,red -Gwhite ${F_KIN}thrust_gen_slip_vectors_np1_str.txt $RJOK $VERBOSE >> map.ps
        # Plot dip line of NP2
        [[ np2flag -eq 1 ]] && gmt psxy -SV0.05i+jb -W0.5p,gray -Ggray ${F_KIN}thrust_gen_slip_vectors_np2_downdip.txt $RJOK $VERBOSE >> map.ps
        # Plot strike line of NP2
        [[ np2flag -eq 1 ]] && gmt psxy -SV0.05i+jc -W0.5p,gray -Ggray ${F_KIN}thrust_gen_slip_vectors_np2_str.txt $RJOK $VERBOSE >> map.ps
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
          ${LITHO1_PROG} -p $lat $lon -d $LITHO1_DEPTH  -l ${LITHO1_LEVEL} 2>/dev/null | gawk  -v lat=$lat -v lon=$lon -v extfield=$LITHO1_FIELDNUM '{
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
      # The values of SCALECMD will be set by the scale) section
      SCALECMD="-Lg${SCALEREFLON}/${SCALEREFLAT}+c${SCALELENLAT}+w${SCALELEN}+l+at+f $SCALEFILL"
      gmt psbasemap ${SCALECMD} $RJOK $VERBOSE >> map.ps
      ;;

    northarrow)

      if [[ $northarrowaprofflag -eq 1 ]]; then
        p1=($(grep "[${NORTHARROWAPROFCODE:0:1}]" ${F_MAPELEMENTS}aprof_database.txt))
        ARROWREFLON=${p1[0]}
        ARROWREFLAT=${p1[1]}
      fi

      # ARROWAPROF=($(echo $2 | gawk -v minlon=$MINLON -v maxlon=$MAXLON -v minlat=$MINLAT -v maxlat=$MAXLAT '
      # BEGIN {
      #     row[1]="AFKPU"
      #     row[2]="BGLQV"
      #     row[3]="CHMRW"
      #     row[4]="DINSX"
      #     row[5]="EJOTY"
      #     difflat=maxlat-minlat
      #     difflon=maxlon-minlon
      #
      #     newdifflon=difflon*8/10
      #     newminlon=minlon+difflon*1/10
      #     newmaxlon=maxlon-difflon*1/10
      #
      #     newdifflat=difflat*8/10
      #     newminlat=minlat+difflat*1/10
      #     newmaxlat=maxlat-difflat*1/10
      #
      #     minlon=newminlon
      #     maxlon=newmaxlon
      #     minlat=newminlat
      #     maxlat=newmaxlat
      #     difflat=newdifflat
      #     difflon=newdifflon
      #
      #     for(i=1;i<=5;i++) {
      #       for(j=1; j<=5; j++) {
      #         char=toupper(substr(row[i],j,1))
      #         lats[char]=minlat+(i-1)/4*difflat
      #         lons[char]=minlon+(j-1)/4*difflon
      #         # print char, lons[char], lats[char]
      #       }
      #     }
      # }
      # {
      #   for(i=1;i<=length($0);++i) {
      #     char1=toupper(substr($0,i,1));
      #     print lons[char1], lats[char1]
      #   }
      # }'))
      # ARROWREFLON=${ARROWAPROF[0]}
      # ARROWREFLAT=${ARROWAPROF[1]}
      # ARROWLENLAT=${ARROWAPROF[1]}
      # shift



      # The values of SCALECMD will be set by the scale) section
      ARROWCMD="-Tdg${ARROWREFLON}/${ARROWREFLAT}+w${ARROWSIZE}"
      # SMALLJ_RJOK=$(echo ${RJSTRING[@]} | tr 'J' 'j')
      echo gmt psbasemap ${ARROWCMD} $SRJOK $VERBOSE
      gmt psbasemap ${ARROWCMD} $RJOK $VERBOSE >> map.ps
      ;;

    maptitle)

      gmt psbasemap "-B+t\"${PLOTTITLE}\"" $RJOK $VERBOSE >> map.ps
 #
 # [[ $PLOTTITLE == "" ]]; then
 #        TITLE=""
 #      else
 #        TITLE="+t\"${PLOTTITLE}\""
 #      fi
 #      if [[ $usecustombflag -eq 0 ]]; then
 #        bcmds+=("-Bxa${GRIDSP}${GRIDSP_LINE}")
 #        bcmds+=("-Bya${GRIDSP}${GRIDSP_LINE}")
 #        bcmds+=("-B${GRIDCALL}${TITLE}")
 #        BSTRING=("${bcmds[@]}")
 #      fi

      ;;

    aprofcodes)
      grep "[$APROFCODES]" ${F_MAPELEMENTS}aprof_database.txt > ${F_MAPELEMENTS}aprof_codes.txt
      gmt pstext ${F_MAPELEMENTS}aprof_codes.txt -F+f14p,Helvetica,black $RJOK $VERBOSE >> map.ps
      ;;

    mprof)

      if [[ $sprofflag -eq 1 || $aprofflag -eq 1 || $cprofflag -eq 1 || $kprofflag -eq 1 ]]; then
        info_msg "Updating mprof to use a newly generated sprof.control file"
        PROFILE_WIDTH_IN="7i"
        PROFILE_HEIGHT_IN="2i"
        PROFILE_X="0"
        PROFILE_Y="-3i"
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
          echo "L ${PROFILE_X_LABEL}|${PROFILE_Y_LABEL}|${PROFILE_Z_LABEL}" >> sprof.control
        fi

        if [[ -s ${F_GRAV}grav.nc ]]; then
          info_msg "Adding gravity grid to sprof as swath and top tile"
          echo "S ${F_GRAV}grav.nc 0.1 ${SPROF_RES} ${SPROFWIDTH} ${SPROF_RES}" >> sprof.control
          echo "G ${F_GRAV}grav.nc 0.1 ${SPROF_RES} ${SPROFWIDTH} ${SPROF_RES} ${GRAV_CPT}" >> sprof.control

          # Make the gravity top tile and set
          gmt grdimage $GRAVDATA -A${F_GRAV}grav.tif ${GRAVGRAD} -t$GRAVTRANS -C${GRAV_CPT} -R -J ${VERBOSE}
          COLORED_RELIEF=${F_GRAV}grav.tif
          echo "M USE_SHADED_RELIEF_TOPTILE" >> sprof.control
        elif [[ -s ${F_MAG}mag.nc ]]; then
          info_msg "Adding magnetics grid to sprof as swath and top tile"
          echo "S ${F_MAG}mag.nc 0.1 ${SPROF_RES} ${SPROFWIDTH} ${SPROF_RES}" >> sprof.control
          echo "G ${F_MAG}mag.nc 0.1 ${SPROF_RES} ${SPROFWIDTH} ${SPROF_RES} ${MAG_CPT}" >> sprof.control

          # Make the magnetics top tile and set
          gmt grdimage ${F_MAG}mag.nc -A${F_MAG}mag.tif ${MAGGRAD} -t$MAGTRANS -C${MAG_CPT} -R -J ${VERBOSE}
          COLORED_RELIEF=${F_MAG}mag.tif
          echo "M USE_SHADED_RELIEF_TOPTILE" >> sprof.control

        elif [[ $plotcustomtopo -eq 1 ]]; then
          info_msg "Adding custom grid to sprof"
          echo "S $CUSTOMGRIDFILE 0.001 ${SPROF_RES} ${SPROFWIDTH} ${SPROF_RES}" >> sprof.control
        elif [[ -e $BATHY ]]; then
          info_msg "Adding topography/bathymetry from map to sprof as swath and top tile"
          echo "S ${F_TOPO}dem.nc 0.001 ${SPROF_RES} ${SPROFWIDTH} ${SPROF_RES}" >> sprof.control
          echo "G ${F_TOPO}dem.nc 0.001 ${SPROF_RES} ${SPROFWIDTH} ${SPROF_RES} ${TOPO_CPT}" >> sprof.control
          echo "M USE_SHADED_RELIEF_TOPTILE" >> sprof.control
        fi

        if [[ -s tomography.txt ]]; then
          info_msg "Adding tomography to sprof as gridded-xyz"
          echo "I tomography.txt ${SPROFWIDTH} -1" >> sprof.control
        fi
        if [[ -e ${F_SEIS}eqs.txt ]]; then
          info_msg "Adding eqs to sprof as seis-xyz"

          EQLWNUM=$(echo $EQLINEWIDTH | gawk '{print $1 + 0}')
          if [[ $(echo "${EQLWNUM} == 0" | bc) -eq 1 ]]; then
            EQWCOM=""
          else
            EQWCOM="-W${EQLINEWIDTH},${EQLINECOLOR}"
          fi

          if [[ -s ${F_SEIS}eqs_scaled.txt ]]; then
            echo "E ${F_SEIS}eqs_scaled.txt ${SPROFWIDTH} -1 ${EQWCOM}" >> sprof.control
          else
            echo "E ${F_SEIS}eqs.txt ${SPROFWIDTH} -1 ${EQWCOM}" >> sprof.control

          fi
        fi
        if [[ -e ${F_CMT}cmt.dat ]]; then
          info_msg "Adding cmt to sprof"
          echo "C ${F_CMT}cmt.dat ${SPROFWIDTH} -1 -L0.25p,black" >> sprof.control
        fi
        if [[ -e ${F_VOLC}volcanoes.dat ]]; then
          # We need to sample the DEM at the volcano point locations, or else use 0 for elevation.
          info_msg "Adding volcanoes to sprof as xyz"
          echo "X ${F_VOLC}volcanoes.dat ${SPROFWIDTH} 0.001 -St0.1i -W0.1p,black -Gred" >> sprof.control
        fi

        if [[ -e ${F_PROFILES}profile_labels.dat ]]; then
          info_msg "Adding profile labels to sprof as xyz [lon/lat/km]"
          echo "B ${F_PROFILES}profile_labels.dat ${SPROFWIDTH} 1 ${FONTSTR}"  >> sprof.control
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
        if [[ $sprofflag -eq 1 ]]; then

          for thissprof in $(seq 1 $sprofnumber); do
            echo "P P${thissprof} black N N ${SPROFLON1[${thissprof}]} ${SPROFLAT1[${thissprof}]} ${SPROFLON2[${thissprof}]} ${SPROFLAT2[${thissprof}]}" >> sprof.control
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
      fi

      info_msg "Drawing profile(s)"

      MAP_PSFILE=$(abs_path map.ps)

      cp gmt.history gmt.history.preprofile
      . $MPROFILE_SH_SRC
      cp gmt.history.preprofile gmt.history

      # Plot the profile lines with the assigned color on the map
      # echo TRACKFILE=...$TRACKFILE

      k=$(wc -l < $TRACKFILE | gawk  '{print $1}')
      for ind in $(seq 1 $k); do
        FIRSTWORD=$(head -n ${ind} $TRACKFILE | tail -n 1 | gawk  '{print $1}')
        # echo FIRSTWORD all=${FIRSTWORD}
        # if [[ ${FIRSTWORD:0:1} != "#" && ${FIRSTWORD:0:1} != "$" && ${FIRSTWORD:0:1} != "%" && ${FIRSTWORD:0:1} != "^" && ${FIRSTWORD:0:1} != "@"  && ${FIRSTWORD:0:1} != ":"  && ${FIRSTWORD:0:1} != ">" ]]; then

        if [[ ${FIRSTWORD:0:1} == "P" ]]; then
          # echo FIRSTWORD=${FIRSTWORD}
          COLOR=$(head -n ${ind} $TRACKFILE | tail -n 1 | gawk  '{print $3}')
          # echo $FIRSTWORD $ind $k

          # NOTE: IT IS UNCLEAR WHETHER WE SHOULD USE psxy -A to draw straight lines or psxy [not -A] to draw
          # geodesic arcs. It will depend on what grdtrack uses...

          head -n ${ind} $TRACKFILE | tail -n 1 | cut -f 6- -d ' ' | xargs -n 2 | gmt psxy $RJOK -W${PROFILE_TRACK_WIDTH},${COLOR} >> map.ps
          # info_msg "is it this"
          head -n ${ind} $TRACKFILE | tail -n 1 | cut -f 6- -d ' ' | xargs -n 2 | head -n 1 | gmt psxy -Si0.1i -W0.5p,${COLOR} -G${COLOR} -Si0.1i $RJOK  >> map.ps
          head -n ${ind} $TRACKFILE | tail -n 1 | cut -f 6- -d ' ' | xargs -n 2 | sed '1d' | gmt psxy -Si0.1i -W0.5p,${COLOR} -Si0.1i $RJOK  >> map.ps
          # info_msg "here"
        fi
      done

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
          gmt psxy $track_file -Sc0.003i -Gblack $RJOK $VERBOSE >> map.ps
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
        done < ${F_PROFILES}start_points.txt

        gmt psxy ${F_PROFILES}end_profile_lines.txt -W0.5p,black $RJOK $VERBOSE >> map.ps
        gmt psxy ${F_PROFILES}start_profile_lines.txt -W0.5p,black $RJOK $VERBOSE >> map.ps
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
        done <  ${F_PROFILES}mid_points.txt

        gmt psxy ${F_PROFILES}mid_profile_lines.txt -W0.5p,black $RJOK $VERBOSE >> map.ps
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

        while read d; do
          p=($(echo $d))
          # echo "${p[0]},${p[1]},${p[5]}  angle ${p[2]}"
          echo "${p[0]},${p[1]},${p[5]}" | gmt pstext -A -Dj${PTEXT_OFFSET} -F+f${PROFILE_FONT_LABEL_SIZE},Helvetica+jRB+a$(echo "${p[2]}-90" | bc -l) $RJOK $VERBOSE >> map.ps
        done < ${F_PROFILES}start_points.txt

      MAP_PROF_SPACING=0.25 # inches
      # If we are placing a profile onto the map, do it here.
      if [[ $plotprofileonmapflag -eq 1 ]]; then
        PS_HEIGHT_IN=$MAP_PROF_SPACING
        grep "^[P]" ${F_PROFILES}control_file.txt | gawk '{printf("%s_flat_profile\n", $2)}' > ${F_PROFILES}profile_filenames.txt
        for profile_number in ${SHOWPROFLIST[@]}; do
          if [[ $profile_number -eq 0 ]]; then
            # Find size of ${F_PROFILES}all_profiles.ps
            PS_DIM=$(gmt psconvert ${F_PROFILES}all_profiles.ps -F${F_PROFILES}all_profiles -Te -A+m0i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
            PS_WIDTH_IN=$(echo $PS_DIM | gawk '{print $1/2.54} ')
            PS_WIDTH_SHIFT=$(echo $PS_DIM | gawk -v p_orig=${PROFILE_WIDTH_IN} '{print ($1/2.54-(p_orig+0))/2}')
            PS_HEIGHT_IN=$(echo $PS_DIM | gawk -v prevheight=$PS_HEIGHT_IN -v vbuf=${MAP_PROF_SPACING} '{print $2/2.54+vbuf + prevheight}')
            gmt psimage -Dx"-${PS_WIDTH_SHIFT}i/-${PS_HEIGHT_IN}i"+w${PS_WIDTH_IN}i ${F_PROFILES}all_profiles.eps $RJOK ${VERBOSE} >> map.ps
          else
            SLURP_PROFID=$(gawk < ${F_PROFILES}profile_filenames.txt -v ind=${profile_number} '(NR==ind) {print}')
            if [[ -s ${F_PROFILES}$SLURP_PROFID.ps ]]; then
              echo "Plotting line ${profile_number} from file $SLURP_PROFID.ps"
              PS_DIM=$(gmt psconvert ${F_PROFILES}${SLURP_PROFID}.ps -F${F_PROFILES}${SLURP_PROFID} -Te -A+m0i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
              PS_WIDTH_IN=$(echo $PS_DIM | gawk '{print $1/2.54} ')
              PS_WIDTH_SHIFT=$(echo $PS_DIM | gawk -v p_orig=${PROFILE_WIDTH_IN} '{print ($1/2.54-(p_orig+0))/2}')
              PS_HEIGHT_IN=$(echo $PS_DIM | gawk -v prevheight=$PS_HEIGHT_IN -v vbuf=${MAP_PROF_SPACING} '{print $2/2.54+vbuf + prevheight}')
              gmt psimage -Dx"-${PS_WIDTH_SHIFT}i/-${PS_HEIGHT_IN}i"+w${PS_WIDTH_IN}i ${F_PROFILES}${SLURP_PROFID}.eps $RJOK ${VERBOSE} >> map.ps
            fi
          fi
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

      gmt makecpt -Ccyclic -D -T-180/180/1 > ${F_CPTS}az.cpt
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
        # gawk < ${F_PLATES}paz1ss1_cutoff.txt -v poff=$POFFS -v gpsscalefac=$VELSCALE '{ if ($4!=0) { print $1 + cos($3*3.14159265358979/180)*poff, $2 - sin($3*3.14159265358979/180)*poff, $3, 0.1/2}}' | gmt psxy -SV"${PVHEAD}"+r+jb+m+a33+h0 -W0p,${PLATEARROW_SS_COLOR1}@$PLATEARROW_TRANS -G${PLATEARROW_SS_COLOR1}@$PLATEARROW_TRANS $RJOK $VERBOSE >> map.ps
        # gawk < ${F_PLATES}paz1ss2_cutoff.txt -v poff=$POFFS -v gpsscalefac=$VELSCALE '{ if ($4!=0) { print $1 - cos($3*3.14159265358979/180)*poff, $2 - sin($3*3.14159265358979/180)*poff, $3, 0.1/2 }}' | gmt psxy -SV"${PVHEAD}"+l+jb+m+a33+h0 -W0p,${PLATEARROW_SS_COLOR2}@$PLATEARROW_TRANS -G${PLATEARROW_SS_COLOR2}@$PLATEARROW_TRANS $RJOK $VERBOSE >> map.ps
      ;;


    eulerpoles)

      gmt makecpt -Croma -T0/2/0.01 -Z > ${F_CPTS}polerate.cpt

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

      # gmt psxy $EDGES -W$PLATELINE_WIDTH,$PLATELINE_COLOR@$PLATELINE_TRANS $RJOK $VERBOSE >> map.ps
      gmt psxy $PLATES -W$PLATELINE_WIDTH,$PLATELINE_COLOR@$PLATELINE_TRANS $RJOK $VERBOSE >> map.ps

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
      [[ $plotplates -eq 1 ]] && gawk  < ${F_PLATES}map_labels.txt -F, '{print $1, $2, substr($3, 1, length($3)-2)}' | gmt pstext -C0.1+t -F+f$PLATELABEL_SIZE,Helvetica,$PLATELABEL_COLOR+jCB $RJOK $VERBOSE  >> map.ps
      ;;

    platepolycolor_all)
        plate_files=($(ls ${F_PLATES}*.pldat 2>/dev/null))
        if [[ ${#plate_files} -gt 0 ]]; then
          gmt makecpt -T0/${#plate_files[@]}/1 -Cwysiwyg ${VERBOSE} | gawk '{print $2}' | head -n ${#plate_files[@]} > ${F_PLATES}platecolor.dat
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
      gmt makecpt -T0/100/1 -C$CPTDIR"platevel_one.cpt" -Z ${VERBOSE} > $PLATEVEL_CPT
      gmt makecpt -T0/100/1 -Ctokyo -Z ${VERBOSE} > $PLATEVEL_CPT
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
        # # Determine the extent of the polygon within the map extent
        pl_max_x=$(grep "^[-*0-9]" plate.xy | sort -n -k 1 | tail -n 1 | gawk  -v mx=$MAXLON '{print ($1>mx)?mx:$1}')
        pl_min_x=$(grep "^[-*0-9]" plate.xy | sort -n -k 1 | head -n 1 | gawk  -v mx=$MINLON '{print ($1<mx)?mx:$1}')
        pl_max_y=$(grep "^[-*0-9]" plate.xy | sort -n -k 2 | tail -n 1 | gawk  -v mx=$MAXLAT '{print ($2>mx)?mx:$2}')
        pl_min_y=$(grep "^[-*0-9]" plate.xy | sort -n -k 2 | head -n 1 | gawk  -v mx=$MINLAT '{print ($2<mx)?mx:$2}')
        info_msg "Polygon region $pl_min_x/$pl_max_x/$pl_min_y/$pl_max_y"
        # this approach requires a final GMT grdblend command
        # echo platevelres=$PLATEVELRES
        gmt grdmath ${VERBOSE} -R$pl_min_x/$pl_max_x/$pl_min_y/$pl_max_y -fg -I$PLATEVELRES pole.xy PDIST 6378.13696669 DIV SIN $POLERATE MUL 6378.13696669 MUL .01745329251944444444 MUL = "$LEAD"_velraster.nc
        gmt grdmask plate.xy ${VERBOSE} -R"$LEAD"_velraster.nc -fg -NNaN/1/1 -Gmask.nc
        info_msg "Calculating $LEAD masked raster"
        gmt grdmath -fg ${VERBOSE} "$LEAD"_velraster.nc mask.nc MUL = "$LEAD"_masked.nc
        # zrange=$(grid_zrange ${LEAD}_velraster.nc -C -Vn)
        # MINZ=$(echo $zrange | gawk  '{print $1}')
        # MAXZ=$(echo $zrange | gawk  '{print $2}')
        # MAXV_I=$(echo $MAXZ | gawk  -v max=$MAXV_I '{ if ($1 > max) { print $1 } else { print max } }')
        # MINV_I=$(echo $MINZ | gawk  -v min=$MINV_I '{ if ($1 < min) { print $1 } else { print min } }')
        # unverified code above...
        # MAXV_I=$(gmt grdinfo ${LEAD}_velraster.nc 2>/dev/null | grep "z_max" | gawk  -v max=$MAXV_I '{ if ($5 > max) { print $5 } else { print max } }')
        # MINV_I=$(gmt grdinfo ${LEAD}_velraster.nc 2>/dev/null | grep "z_max" | gawk  -v min=$MINV_I '{ if ($3 < min) { print $3 } else { print min } }')
        # # gmt grdedit -fg -A -R$pl_min_x/$pl_max_x/$pl_min_y/$pl_max_y "$LEAD"_masked.nc -G"$LEAD"_masked_edit.nc
        # echo "${LEAD}_masked_edit.nc -R$pl_min_x/$pl_max_x/$pl_min_y/$pl_max_y 1" >> grdblend.cmd
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
        zrange=$(grid_zrange plate_velocities.nc -C -Vn)
      cd ..

      info_msg "Velocities range: $zrange"
      # info_msg "Creating zero raster"
      # gmt grdmath ${VERBOSE} -R$MINLON/$MAXLON/$MINLAT/$MAXLAT -fg -I$PLATEVELRES 0 = plate_velocities.nc
      # for i in pvdir/*_masked.nc; do
      #   info_msg "Adding $LEAD to plate velocity raster"
      #   gmt grdmath ${VERBOSE} -fg plate_velocities.nc $i 0 AND ADD = plate_velocities.nc
      # done

      # cd pvdir
      # echo blending
      # gmt grdblend grdblend.cmd -fg -R$MINLON/$MAXLON/$MINLAT/$MAXLAT -Gplate_velocities.nc -I$PLATEVELRES ${VERBOSE}

      # This isn't working because I can't seem to read the max values from this raster this way or with gdalinfo
      if [[ $rescaleplatevecsflag -eq 1 ]]; then
        MINV=$(echo $zrange | gawk  '{ print int($1/10)*10 }')
        MAXV=$(echo $zrange | gawk  '{ print int($2/10)*10 +10 }')
        echo MINV MAXV $MINV $MAXV
        gmt makecpt -C$CPTDIR"platevel_one.cpt" -T0/$MAXV -Z > $PLATEVEL_CPT
      else
        gmt makecpt -T0/100/1 -C$CPTDIR"platevel_one.cpt" -Z ${VERBOSE} > $PLATEVEL_CPT
      fi

      # cd ..
      info_msg "Plotting velocity raster."

      gmt grdimage ./pvdir/plate_velocities.nc -C$PLATEVEL_CPT $GRID_PRINT_RES $RJOK $VERBOSE >> map.ps
      info_msg "Plotted velocity raster."
      ;;

    polygonaoi)
      info_msg "Plotting polygon AOI"
      gmt psxy ${POLYGONAOI} -L -W0.5p,black $RJOK ${VERBOSE} >> map.ps
      ;;

    refpoint)
      info_msg "Plotting reference point"

      if [[ $refptflag -eq 1 ]]; then
      # Plot the reference point as a circle around a triangle
        echo $REFPTLON $REFPTLAT| gmt psxy -W0.1,black -Gblack -St0.05i $RJOK $VERBOSE >> map.ps
        echo $REFPTLON $REFPTLAT| gmt psxy -W0.1,black -Sc0.1i $RJOK $VERBOSE >> map.ps
      fi
      ;;

    seis)
      if [[ $dontplotseisflag -eq 0 ]]; then

        info_msg "Plotting seismicity; should include options for CPT/fill color"
        OLD_PROJ_LENGTH_UNIT=$(gmt gmtget PROJ_LENGTH_UNIT -Vn)
        gmt gmtset PROJ_LENGTH_UNIT p

        EQLWNUM=$(echo $EQLINEWIDTH | gawk '{print $1 + 0}')
        if [[ $(echo "${EQLWNUM} == 0" | bc) -eq 1 ]]; then
          EQWCOM=""
        else
          EQWCOM="-W${EQLINEWIDTH},${EQLINECOLOR}"
        fi

        # This section is a hack to get time coloring to work... needs to be
        # moved and replaced with a more comprehensive coloring scheme.

        # Potential problems include coloring on profiles, sorting, etc.

        if [[ $SCALEEQS -eq 1 ]]; then

          if [[ $zctimeflag -eq 1 ]]; then
            SEIS_INPUTORDER1="-i0,1,6,3+s${SEISSCALE}"
            SEIS_INPUTORDER2="-i0,1,6"
            SEIS_CPT=${F_CPTS}"eqtime.cpt"
          elif [[ $zcclusterflag -eq 1 ]]; then
            SEIS_INPUTORDER1="-i0,1,7,3+s${SEISSCALE}"
            SEIS_INPUTORDER2="-i0,1,7"
            SEIS_CPT=${F_CPTS}"eqcluster.cpt"
          else
            SEIS_INPUTORDER1="-i0,1,2,3+s${SEISSCALE}"
            SEIS_INPUTORDER2="-i0,1,2"
            SEIS_CPT=$SEISDEPTH_CPT
          fi
        else
          if [[ $zctimeflag -eq 1 ]]; then
            SEIS_INPUTORDER="-i0,1,6"
            SEIS_CPT=${F_CPTS}"eqtime.cpt"
          elif [[ $zcclusterflag -eq 1 ]]; then
            SEIS_INPUTORDER="-i0,1,7"
            SEIS_CPT=${F_CPTS}"eqcluster.cpt"
          else
            SEIS_INPUTORDER="-i0,1,2"
            SEIS_CPT=$SEISDEPTH_CPT
          fi
        fi


        if [[ $SCALEEQS -eq 1 ]]; then

          # the -Cwhite option here is so that we can pass the removed EQs in the same file format as the non-scaled events
          [[ $REMOVE_DEFAULTDEPTHS_WITHPLOT -eq 1 ]] && [[ -e ${F_SEIS}removed_eqs_scaled.txt ]] && gmt psxy ${F_SEIS}removed_eqs_scaled.txt -Cwhite ${EQWCOM} -i0,1,2,3+s${SEISSCALE} -S${SEISSYMBOL} -t${SEISTRANS} $RJOK $VERBOSE >> map.ps
          gmt psxy ${F_SEIS}eqs_scaled.txt -C$SEIS_CPT ${SEIS_INPUTORDER1} ${EQWCOM} -S${SEISSYMBOL} -t${SEISTRANS} $RJOK $VERBOSE >> map.ps
        else
# Does this work?
          [[ $REMOVE_DEFAULTDEPTHS_WITHPLOT -eq 1 ]] && [[ -e ${F_SEIS}removed_eqs_scaled.txt ]] && gmt psxy ${F_SEIS}removed_eqs.txt -Gwhite ${EQWCOM} -i0,1,2,3+s${SEISSCALE} -S${SEISSYMBOL}${SEISSIZE} -t${SEISTRANS} $RJOK $VERBOSE >> map.ps
          gmt psxy ${F_SEIS}eqs.txt -C$SEIS_CPT ${EQWCOM} -S${SEISSYMBOL}${SEISSIZE} ${SEIS_INPUTORDER1} -t${SEISTRANS} $RJOK $VERBOSE >> map.ps
        fi
        gmt gmtset PROJ_LENGTH_UNIT $OLD_PROJ_LENGTH_UNIT
      fi
			;;

    seissum)

      # Convert Mw to M0 and sum within grid nodes, then take the log10 and plot.

      if [[ $SSUNIFORM -eq 1 ]]; then
        # Use a magnitude of 4 for all events
        gawk < ${F_SEIS}eqs.txt '{print $1, $2, 1}' | gmt blockmean -Ss -R -I${SSRESC} -G${F_SEIS}seissum.nc ${VERBOSE}
        gmt grd2cpt -Qo -I -Cturbo ${F_SEIS}seissum.nc ${VERBOSE} > ${F_CPTS}seissum.cpt
        gmt grdimage ${F_SEIS}seissum.nc -C${F_CPTS}seissum.cpt -Q $RJOK ${VERBOSE} -t${SSTRANS} >> map.ps
      else
        # Use the true magnitude for all events
        gawk < ${F_SEIS}eqs.txt '{print $1, $2, 10^(($4+10.7)*3/2)}' | gmt blockmean -Ss -R -I${SSRESC} -G${F_SEIS}seissum.nc ${VERBOSE}
        gmt grdmath ${VERBOSE} ${F_SEIS}seissum.nc LOG10 = ${F_SEIS}seisout.nc
        gmt grd2cpt -Qo -I -Cseis ${F_SEIS}seisout.nc ${VERBOSE} > ${F_CPTS}seissum.cpt
        gmt grdimage ${F_SEIS}seisout.nc -C${F_CPTS}seissum.cpt -Q $RJOK ${VERBOSE} -t${SSTRANS} >> map.ps
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
      gawk < ${SVDATAFILE} '($1 != "end") {print $1, $2, $3, 0.2}' | gmt psxy -SV0.05i+jc -W1.5p,red $RJOK $VERBOSE >> map.ps
      ;;

    slipvecs_scale)
      info_msg "Slip vectors"
      # Plot a file containing slip vector azimuths
      gawk < ${SVDATAFILE} -v field=${SVSCALEFIELD} '($1 != "end") {print $1, $2, $3, $(field)}' | gmt psxy -SV0.05i+jc -W1.5p,red $RJOK $VERBOSE >> map.ps
      ;;

    text)
      gmt pstext ${TEXTFILE} -Xa${TEXTXOFF} -Ya${TEXTYOFF} -Gwhite -F+f+a+j -W0.25p,black $RJOK $VERBOSE >> map.ps
      # -Dj-0.05i/0.025i+v0.7p,black
    ;;

    topo)

   # Somehow, we need to handle the case where no topo is plotted but Sentinel
   # data are plotted.

   # This section should probably be outsourced to a separate script or function
   # to allow equivalent DEM visualization for along-profile DEMs, etc.
   # Requires: dem.nc sentinel.tif TOPO_CPT
   # Variables: topoctrlstring MINLON/MAXLON/MINLAT/MAXLAT P_IMAGE F_TOPO *_FACT
   # Flags: FILLGRIDNANS SMOOTHGRID ZEROHINGE

      plottedtopoflag=1
      if [[ $fasttopoflag -eq 0 ]]; then   # If we are doing more complex topo visualization

        # If we are loading a saved image for a region, do so.
        if [[ $tloadflag -eq 1 && $usingcustomregionflag -eq 1 ]]; then
          COLORED_RELIEF=${SAVEDTOPODIR}${CUSTOMREGIONID}.tif

          if [[ ! -s ${COLORED_RELIEF} ]]; then
            info_msg "Saved topo for region ${CUSTOMREGIONID} (${COLORED_RELIF}) does not exist. Not plotting topo."
            dontplottopoflag=1
          fi
        # Otherwise, calculate the colored relief.
        else

          # If a topography dataset exists, then...
          if [[ -e ${F_TOPO}dem.nc ]]; then


            if [[ $DEM_SMOOTH_FLAG -eq 1 ]]; then
              echo "Smoothing DEM"
              gmt grdfilter -Dp${DEM_SMOOTH_RAD} -Fg${DEM_SMOOTH_RAD} ${F_TOPO}dem.nc -Gdem_smooth.nc
              mv dem_smooth.nc ${F_TOPO}dem.nc
            fi

            if [[ $FILLGRIDNANS -eq 1 ]]; then
              # cp ${F_TOPO}dem.nc olddem.nc
              info_msg "Filling grid file NaN values with nearest non-NaN value"
              gmt grdfill ${F_TOPO}dem.nc -An -Gdem_no_nan.nc ${VERBOSE}
              mv dem_no_nan.nc ${F_TOPO}dem.nc
            fi

            # If we are visualizing Sentinel imagery, resample DEM to match the resolution of sentinel.tif
            if [[ ${topoctrlstring} =~ .*p.* && ${P_IMAGE} =~ "sentinel.tif" ]]; then
                # Absolute path is needed here as GMT 6.1.1 breaks for a relative path... BUG?
                sentinel_dim=($(gmt grdinfo ./sentinel.tif -C -L -Vn))
                sent_dimx=${sentinel_dim[9]}
                sent_dimy=${sentinel_dim[10]}

                dem_dim=($(gmt grdinfo ${F_TOPO}dem.nc -C -L -Vn))
                dem_dimx=${dem_dim[9]}
                dem_dimy=${dem_dim[10]}

                if [[ $SENTINEL_DOWNSAMPLE -eq 1 ]]; then
                  echo "Resampling DEM to match downloaded Sentinel image size"
                  gdalwarp -r bilinear -of NetCDF -q -te ${DEM_MINLON} ${DEM_MINLAT} ${DEM_MAXLON} ${DEM_MAXLAT} -ts ${sent_dimx} ${sent_dimy} ${F_TOPO}dem.nc ${F_TOPO}dem_warp.nc
                  # gdalwarp nukes the z values for some stupid reason leaving a raster that GMT interprets as all 0s
                  cp ${F_TOPO}dem.nc ${F_TOPO}demold.nc
                  gmt grdcut ${F_TOPO}dem_warp.nc -R${F_TOPO}dem_warp.nc -G${F_TOPO}dem.nc ${VERBOSE}
                else
                  echo "Resampling Sentinel image to match DEM resolution"
                  gdalwarp -r bilinear -of GTiff -q -ts ${dem_dimx} ${dem_dimy} ./sentinel.tif ./sentinel_warp.tif
                  # gdalwarp nukes the z values for some stupid reason leaving a raster that GMT interprets as all 0s
                  cp ./sentinel_warp.tif ./sentinel.tif
                  # gmt grdcut ${F_TOPO}dem_warp.nc -R${F_TOPO}dem_warp.nc -G${F_TOPO}dem.nc ${VERBOSE}
                fi


                # If we have set a specific flag, then calculate the average color of areas at or below zero
                # elevation and set all cells in sentinel.tif to that color (to make a uniform ocean color?)
                if [[ $sentinelrecolorseaflag -eq 1 ]]; then
                  info_msg "Recoloring sea areas of Sentinel image"
                  recolor_sea ${F_TOPO}dem.nc ./sentinel.tif ${SENTINEL_RECOLOR_R} ${SENTINEL_RECOLOR_G} ${SENTINEL_RECOLOR_B} ./sentinel_recolor.tif
                  mv ./sentinel_recolor.tif ./sentinel.tif
                fi
            fi

            if [[ $SMOOTHGRID -eq 1 ]]; then
              info_msg "Smoothing grid before DEM calculations"
              # Not implemented
            fi

            CELL_SIZE=$(gmt grdinfo -C ${F_TOPO}dem.nc -Vn | gawk '{print $8}')
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
              cpt_to_gdalcolor ./cpttmp.cpt > ${F_CPTS}topocolor.dat
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
              cpt_to_gdalcolor ./cpttmp.cpt > ${F_CPTS}topocolor.dat
              # gawk < $TOPO_CPT '{ print $1, $2 }' | tr '/' ' ' > ${F_CPTS}topocolor.dat
            fi
          fi
          # ########################################################################
          # Create and render a colored shaded relief map using a topoctrlstring
          # command string = "csmhvdtg"
          #

          # c = color stretch  [ DEM_ALPHA CPT_NAME HINGE_VALUE HIST_EQ ]    [MULTIPLY]
          # s = slope map                                                    [WEIGHTED AVE]
          # m = multiple hillshade (gdaldem)  [ SUN_ELEV ]                   [WEIGHTED AVE]
          # h = unidirectional hillshade (gdaldem)  [ SUN_ELEV SUN_AZ ]      [WEIGHTED AVE]
          # v = sky view factor                                              [WEIGHTED AVE]
          # i = terrain ruggedness index                                     [WEIGHTED AVE]
          # d = cast shadows [ SUN_ELEV SUN_AZ ]                             [MULTIPLY]
          # t = texture shade [ TFRAC TSTRETCH ]                             [WEIGHTED AVE]
          # q = height above local quantile                                  [WEIGHTED AVE]
          # g = stretch/gamma on intensity [ HS_GAMMA ]                      [DIRECT]
          # p = use TIFF image instead of color stretch
          # w = clip to alternative AOI

          while read -n1 character; do
            case $character in

            w)
              info_msg "Clipping DEM to new AOI"

              gdal_translate -q -of NetCDF -projwin ${CLIP_MINLON} ${CLIP_MAXLAT} ${CLIP_MAXLON} ${CLIP_MINLAT} ${F_TOPO}dem.nc ${F_TOPO}dem_clip.nc
              DEM_MINLON=${CLIP_MINLON}
              DEM_MAXLON=${CLIP_MAXLON}
              DEM_MINLAT=${CLIP_MINLAT}
              DEM_MAXLAT=${CLIP_MAXLAT}
              # mkdir -p ./tmpcut
              # cd ./tmpcut
              # gmt grdcut ../${F_TOPO}dem.nc -R${CLIP_MINLON}/${CLIP_MAXLON}/${CLIP_MINLAT}/${CLIP_MAXLAT} -G../${F_TOPO}clip.nc ${VERBOSE}
              # cd ..
              cp ${F_TOPO}dem_clip.nc ${F_TOPO}dem.nc
            ;;

            i)
              info_msg "Calculating terrain ruggedness index"
              gdaldem TRI -q -of NetCDF ${F_TOPO}dem.nc ${F_TOPO}tri.nc
              zrange=($(grid_zrange ${F_TOPO}tri.nc -C -Vn))
              gdal_translate -of GTiff -ot Byte -a_nodata 0 -scale ${zrange[0]} ${zrange[1]} 254 1 ${F_TOPO}tri.nc ${F_TOPO}tri.tif -q
              weighted_average_combine ${F_TOPO}tri.tif ${F_TOPO}intensity.tif ${TRI_FACT} ${F_TOPO}intensity.tif
            ;;

            q)
              info_msg "Calculating height above local quantile"
              gmt grdfilter ${F_TOPO}dem.nc -Dp -Fm${DEM_QUANTILE_RADIUS}+q${DEM_QUANTILE} -R${F_TOPO}dem.nc -G${F_TOPO}quantile.nc
              gmt grdmath ${F_TOPO}dem.nc ${F_TOPO}quantile.nc SUB = ${F_TOPO}quantile_diff.nc ${VERBOSE}

              zrange=($(grid_zrange ${F_TOPO}quantile_diff.nc -C -Vn))
              gdal_translate -of GTiff -ot Byte -a_nodata 0 -scale ${zrange[0]} ${zrange[1]} 1 254 ${F_TOPO}quantile_diff.nc ${F_TOPO}quantile_gray.tif -q
              weighted_average_combine ${F_TOPO}quantile_gray.tif ${F_TOPO}intensity.tif ${QUANTILE_FACT} ${F_TOPO}intensity.tif
            ;;


            t)
              demwidth=$(gmt grdinfo -C ${F_TOPO}dem.nc ${VERBOSE} | gawk '{print $10}')
              demheight=$(gmt grdinfo -C ${F_TOPO}dem.nc ${VERBOSE} | gawk '{print $11}')
              demxmin=$(gmt grdinfo -C ${F_TOPO}dem.nc ${VERBOSE} | gawk '{print $2}')
              demxmax=$(gmt grdinfo -C ${F_TOPO}dem.nc ${VERBOSE} | gawk '{print $3}')
              demymin=$(gmt grdinfo -C ${F_TOPO}dem.nc ${VERBOSE} | gawk '{print $4}')
              demymax=$(gmt grdinfo -C ${F_TOPO}dem.nc ${VERBOSE} | gawk '{print $5}')

              info_msg "Calculating and rendering texture map"

              # Calculate the texture shade
              # Project from WGS1984 to Mercator / HDF format
              # The -dstnodata option is a kluge to get around unknown NaNs in dem.flt even if ${F_TOPO}dem.nc has NaNs filled.
              [[ ! -e ${F_TOPO}dem.flt ]] && gdalwarp -dstnodata -9999 -t_srs EPSG:3395 -s_srs EPSG:4326 -r bilinear -if netCDF -of EHdr -ot Float32 -ts $demwidth $demheight ${F_TOPO}dem.nc ${F_TOPO}dem.flt -q

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

              ${TEXTURE} ${TS_FRAC} ${F_TOPO}dem.flt ${F_TOPO}texture.flt -mercator ${MERCMINLAT} ${MERCMAXLAT} > /dev/null
              # make the image. Pipe output to /dev/null to silence the program
              ${TEXTURE_IMAGE} +${TS_STRETCH} ${F_TOPO}texture.flt ${F_TOPO}texture_merc.tif > /dev/null
              # project back to WGS1984

              gdalwarp -s_srs EPSG:3395 -t_srs EPSG:4326 -r bilinear  -ts $demwidth $demheight -te $demxmin $demymin $demxmax $demymax ${F_TOPO}texture_merc.tif ${F_TOPO}texture_2byte.tif -q

              # Change to 8 bit unsigned format
              gdal_translate -of GTiff -ot Byte -scale 0 65535 0 255 ${F_TOPO}texture_2byte.tif ${F_TOPO}texture.tif -q
              cleanup ${F_TOPO}texture_2byte.tif ${F_TOPO}texture_merc.tif ${F_TOPO}dem.flt ${F_TOPO}dem.hdr ${F_TOPO}dem.flt.aux.xml ${F_TOPO}dem.prj ${F_TOPO}texture.flt ${F_TOPO}texture.hdr ${F_TOPO}texture.prj ${F_TOPO}texture_merc.prj ${F_TOPO}texture_merc.tfw

              # Combine it with the existing intensity
              weighted_average_combine ${F_TOPO}texture.tif ${F_TOPO}intensity.tif ${TS_FACT} ${F_TOPO}intensity.tif
            ;;

            m)
              info_msg "Creating multidirectional hillshade"
              gdaldem hillshade -multidirectional -compute_edges -alt ${HS_ALT} -s $MULFACT ${F_TOPO}dem.nc ${F_TOPO}multiple_hillshade.tif -q
              weighted_average_combine ${F_TOPO}multiple_hillshade.tif ${F_TOPO}intensity.tif ${MULTIHS_FACT} ${F_TOPO}intensity.tif
            ;;

            # Compute and render a one-sun hillshade
            h)
              info_msg "Creating unidirectional hillshade"
              gdaldem hillshade -compute_edges -alt ${HS_ALT} -az ${HS_AZ} -s $MULFACT ${F_TOPO}dem.nc ${F_TOPO}single_hillshade.tif -q
              weighted_average_combine ${F_TOPO}single_hillshade.tif ${F_TOPO}intensity.tif ${UNI_FACT} ${F_TOPO}intensity.tif
            ;;

            # Compute and render the slope map
            s)
              info_msg "Creating slope map"
              gdaldem slope -compute_edges -s $MULFACT ${F_TOPO}dem.nc ${F_TOPO}slopedeg.tif -q
              echo "5 254 254 254" > ${F_TOPO}slope.txt
              echo "80 30 30 30" >> ${F_TOPO}slope.txt
              gdaldem color-relief ${F_TOPO}slopedeg.tif ${F_TOPO}slope.txt ${F_TOPO}slope.tif -q
              weighted_average_combine ${F_TOPO}slope.tif ${F_TOPO}intensity.tif ${SLOPE_FACT} ${F_TOPO}intensity.tif
            ;;

            # Compute and render the sky view factor
            v)

              demwidth=$(gmt grdinfo -C ${F_TOPO}dem.nc ${VERBOSE} | gawk '{print $10}')
              demheight=$(gmt grdinfo -C ${F_TOPO}dem.nc ${VERBOSE} | gawk '{print $11}')
              demxmin=$(gmt grdinfo -C ${F_TOPO}dem.nc ${VERBOSE} | gawk '{print $2}')
              demxmax=$(gmt grdinfo -C ${F_TOPO}dem.nc ${VERBOSE} | gawk '{print $3}')
              demymin=$(gmt grdinfo -C ${F_TOPO}dem.nc ${VERBOSE} | gawk '{print $4}')
              demymax=$(gmt grdinfo -C ${F_TOPO}dem.nc ${VERBOSE} | gawk '{print $5}')

              info_msg "Creating sky view factor"

              [[ ! -e ${F_TOPO}dem.flt ]] && gdalwarp -dstnodata -9999 -t_srs EPSG:3395 -s_srs EPSG:4326 -r bilinear -if netCDF -of EHdr -ot Float32 -ts $demwidth $demheight ${F_TOPO}dem.nc ${F_TOPO}dem.flt -q

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

              # start_time=`date +%s`
              ${SVF} ${NUM_SVF_ANGLES} ${F_TOPO}dem.flt ${F_TOPO}svf.flt -mercator ${MERCMINLAT} ${MERCMAXLAT} > /dev/null
              # echo run time is $(expr `date +%s` - $start_time) s
              # project back to WGS1984
              gdalwarp -s_srs EPSG:3395 -t_srs EPSG:4326 -r bilinear  -ts $demwidth $demheight -te $demxmin $demymin $demxmax $demymax ${F_TOPO}svf.flt ${F_TOPO}svf_back.tif -q

              zrange=($(grid_zrange ${F_TOPO}svf_back.tif -Vn))
              gdal_translate -of GTiff -ot Byte -a_nodata 255 -scale ${zrange[1]} ${zrange[0]} 1 254 ${F_TOPO}svf_back.tif ${F_TOPO}svf.tif -q

              # Combine it with the existing intensity
              weighted_average_combine ${F_TOPO}svf.tif ${F_TOPO}intensity.tif ${SKYVIEW_FACT} ${F_TOPO}intensity.tif
            ;;

            # Compute and render the cast shadows
            d)
              info_msg "Creating cast shadow map"

              demwidth=$(gmt grdinfo -C ${F_TOPO}dem.nc ${VERBOSE} | gawk '{print $10}')
              demheight=$(gmt grdinfo -C ${F_TOPO}dem.nc ${VERBOSE} | gawk '{print $11}')
              demxmin=$(gmt grdinfo -C ${F_TOPO}dem.nc ${VERBOSE} | gawk '{print $2}')
              demxmax=$(gmt grdinfo -C ${F_TOPO}dem.nc ${VERBOSE} | gawk '{print $3}')
              demymin=$(gmt grdinfo -C ${F_TOPO}dem.nc ${VERBOSE} | gawk '{print $4}')
              demymax=$(gmt grdinfo -C ${F_TOPO}dem.nc ${VERBOSE} | gawk '{print $5}')


              [[ ! -e ${F_TOPO}dem.flt ]] && gdalwarp -dstnodata -9999 -t_srs EPSG:3395 -s_srs EPSG:4326 -r bilinear -if netCDF -of EHdr -ot Float32 -ts $demwidth $demheight ${F_TOPO}dem.nc ${F_TOPO}dem.flt -q

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

              ${SHADOW} ${SUN_AZ} ${SUN_EL} ${F_TOPO}dem.flt ${F_TOPO}shadow.flt -mercator ${MERCMINLAT} ${MERCMAXLAT} > /dev/null
              # project back to WGS1984

              gdalwarp -s_srs EPSG:3395 -t_srs EPSG:4326 -r bilinear  -ts $demwidth $demheight -te $demxmin $demymin $demxmax $demymax ${F_TOPO}shadow.flt ${F_TOPO}shadow_back.tif -q

              MAX_SHADOW=$(grep "max_value" ${F_TOPO}shadow.hdr | gawk '{print $2}')

              # Change to 8 bit unsigned format
              gdal_translate -of GTiff -ot Byte -a_nodata 255 -scale $MAX_SHADOW 0 1 254 ${F_TOPO}shadow_back.tif ${F_TOPO}shadow.tif -q
              # Combine it with the existing intensity
              alpha_value ${F_TOPO}shadow.tif ${SHADOW_ALPHA} ${F_TOPO}shadow_alpha.tif

              multiply_combine ${F_TOPO}shadow_alpha.tif ${F_TOPO}intensity.tif ${F_TOPO}intensity.tif
            ;;

            # Rescale and gamma correct the intensity layer
            g)
              info_msg "Rescale stretching and gamma correcting intensity layer"
              zrange=($(grid_zrange ${F_TOPO}intensity.tif -C -Vn))

              histogram_rescale_stretch ${F_TOPO}intensity.tif ${zrange[0]} ${zrange[1]} 1 254 $HS_GAMMA ${F_TOPO}intensity_cor.tif

              # echo histogram_rescale_stretch ${F_TOPO}intensity.tif ${zrange[0]} ${zrange[1]} 1 254 $HS_GAMMA ${F_TOPO}intensity_cor.tif

              mv ${F_TOPO}intensity_cor.tif ${F_TOPO}intensity.tif
            ;;

            # Percent cut the intensity layer
            x)
              info_msg "Executing percent cut on intensity layer"
              histogram_percentcut_byte ${F_TOPO}intensity.tif $TPCT_MIN $TPCT_MAX ${F_TOPO}intensity_percentcut.tif
              cp ${F_TOPO}intensity_percentcut.tif ${F_TOPO}intensity.tif
            ;;

            # Set intensity of DEM values with elevation=0 to 254
            u)
              info_msg "Resetting 0 elevation cells to white"
              image_setval ${F_TOPO}intensity.tif ${F_TOPO}dem.nc 0 254 ${F_TOPO}unset.tif
              cp ${F_TOPO}unset.tif ${F_TOPO}intensity.tif
            ;;

            esac
          done < <(echo -n "$topoctrlstring")

          INTENSITY_RELIEF=${F_TOPO}intensity.tif

          if [[ ${topoctrlstring} =~ .*p.* ]]; then

              # if [[ $demisclippedflag -eq 1 ]]; then
              #   P_MAXLON=${CLIP_MAXLON}
              #   P_MINLON=${CLIP_MINLON}
              #   P_MAXLAT=${CLIP_MAXLAT}
              #   P_MINLAT=${CLIP_MINLAT}
              # else
              #   P_MAXLON=${MAXLON}
              #   P_MINLON=${MINLON}
              #   P_MAXLAT=${MAXLAT}
              #   P_MINLAT=${MINLAT}
              # fi
              dem_dim=($(gmt grdinfo ${F_TOPO}dem.nc -C -L -Vn))
              dem_dimx=${dem_dim[9]}
              dem_dimy=${dem_dim[10]}
              info_msg "Rendering georeferenced RGB image ${P_IMAGE} as colored texture."
              if [[ ${P_IMAGE} =~ "sentinel.tif" ]]; then
                info_msg "Rendering Sentinel image"
                gdalwarp -q -te ${DEM_MINLON} ${DEM_MINLAT} ${DEM_MAXLON} ${DEM_MAXLAT} -ts ${dem_dimx} ${dem_dimy} sentinel.tif ${F_TOPO}image_pre.tif
                cp ${F_TOPO}image_pre.tif ${F_TOPO}image.tif
  # This is the problematic command that overly brightens the image sometimes
  #              histogram_rescale_stretch ${F_TOPO}image_pre.tif 1 180 1 254 ${SENTINEL_GAMMA} ${F_TOPO}image.tif
  # Causes major clipping of white areas in original image.
              else
                gdalwarp -q -te ${DEM_MINLON} ${DEM_MINLAT} ${DEM_MAXLON} ${DEM_MAXLAT} -ts ${dem_dimx} ${dem_dimy} ${P_IMAGE} ${F_TOPO}image.tif
              fi
              if [[ $(echo "${IMAGE_FACT} == 1" | bc) -ne 1 ]]; then
                alpha_value ${F_TOPO}image.tif ${IMAGE_FACT} ${F_TOPO}image_alpha.tif
                # values of 255 in image.tif are set to nodata in image_alpha.tif
                # This seems to have fixed the issue?
                gdal_edit.py -unsetnodata ${F_TOPO}image_alpha.tif
                multiply_combine ${F_TOPO}image_alpha.tif $INTENSITY_RELIEF ${F_TOPO}colored_intensity.tif
              else
              # weighted_average_combine ${F_TOPO}image.tif ${F_TOPO}intensity.tif ${IMAGE_FACT} ${F_TOPO}intensity.tif

                multiply_combine ${F_TOPO}image.tif $INTENSITY_RELIEF ${F_TOPO}colored_intensity.tif
              fi
              INTENSITY_RELIEF=${F_TOPO}colored_intensity.tif
          fi

          if [[ ${topoctrlstring} =~ .*c.* && ! ${topoctrlstring} =~ .*p.* ]]; then
            info_msg "Creating and blending color stretch (alpha=$DEM_ALPHA)."
            gdaldem color-relief ${F_TOPO}dem.nc ${F_CPTS}topocolor.dat ${F_TOPO}colordem.tif -q
            alpha_value ${F_TOPO}colordem.tif ${DEM_ALPHA} ${F_TOPO}colordem_alpha.tif
            multiply_combine ${F_TOPO}colordem_alpha.tif $INTENSITY_RELIEF ${F_TOPO}colored_intensity.tif
            COLORED_RELIEF=${F_TOPO}colored_intensity.tif
          else
            COLORED_RELIEF=$INTENSITY_RELIEF
          fi
          BATHY=${F_TOPO}dem.nc
        fi
      fi  # fasttopoflag = 0

      if [[ $fasttopoflag -eq 0 ]]; then   # If we are doing more complex topo visualization
        [[ $dontplottopoflag -eq 0 ]] && gmt grdimage ${COLORED_RELIEF} $GRID_PRINT_RES -t$TOPOTRANS $RJOK ${VERBOSE} >> map.ps
      else # If we are doing fast topo visualization
        [[ $dontplottopoflag -eq 0 ]] && gmt grdimage ${F_TOPO}dem.nc ${ILLUM} -C${TOPO_CPT} $GRID_PRINT_RES -t$TOPOTRANS $RJOK ${VERBOSE} >> map.ps

        # Do save the colored_relief.tif though
        gmt_init_tmpdir
          gmt grdimage ${F_TOPO}dem.nc ${ILLUM} -C${TOPO_CPT} -t$TOPOTRANS -R${F_TOPO}dem.nc -JQ5i ${VERBOSE} -A${F_TOPO}colored_relief.tif
        gmt_remove_tmpdir
        COLORED_RELIEF=$(abs_path ${F_TOPO}colored_relief.tif)
      fi

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
      for this_mod in ${TECTOPLOT_MODULES[@]}; do
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


#### SECTION: DATA FRAMES BELOW OR BESIDE THE MAP (incompatible with onmap profiles)

### Plot seismicty vs depth in a projected (X) frame below the map frame

if [[ $plotseisprojflag_x -eq 1 && -s ${F_SEIS}eqs_scaled.txt ]]; then

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

    gmt mapproject ${RJSTRING[@]} ${F_SEIS}eqs.txt -i0,1 | gawk '{print $1, $2}' > ${F_SEIS}proj_eqs.txt
    gawk '
      (NR==FNR) {
        projx[NR]=$1
        projy[NR]=$2
      }
      (NR>FNR) {
        $1=projx[FNR]
        $2=-$3
        print
      }' ${F_SEIS}proj_eqs.txt ${F_SEIS}eqs_scaled.txt > ${F_SEIS}proj_eqs_scaled.txt

    if [[ $zctimeflag -eq 1 ]]; then
      SEIS_INPUTORDER1="-i0,1,6,3+s${SEISSCALE}"
      SEIS_INPUTORDER2="-i0,1,6"
      SEIS_CPT=${F_CPTS}"eqtime.cpt"
    elif [[ $zcclusterflag -eq 1 ]]; then
      SEIS_INPUTORDER1="-i0,1,7,3+s${SEISSCALE}"
      SEIS_INPUTORDER2="-i0,1,7"
      SEIS_CPT=${F_CPTS}"eqcluster.cpt"
    else
      SEIS_INPUTORDER1="-i0,1,2,3+s${SEISSCALE}"
      SEIS_INPUTORDER2="-i0,1,2"
      SEIS_CPT=$SEISDEPTH_CPT
    fi

    if [[ $SCALEEQS -eq 1 ]]; then
      gmt_init_tmpdir

      gmt psbasemap -R${MINPROJ_X}/${MAXPROJ_X}/${depth_range[0]}/${depth_range[1]} -JX${PSSIZE}i/${SEISPROJHEIGHT_X}i -Btlbr $VERBOSE > ${TMP}seisdepth_fake.ps
      PS_DIM=$(gmt psconvert seisdepth_fake.ps -Te -A+m0i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
      PS_HEIGHT_IN_NOLABELS=$(echo $PS_DIM | gawk  '{print $2/2.54 + 0.15}')

      OLD_PROJ_LENGTH_UNIT=$(gmt gmtget PROJ_LENGTH_UNIT -Vn)
      gmt gmtset PROJ_LENGTH_UNIT p
      # the -Cwhite option here is so that we can pass the removed EQs in the same file format as the non-scaled events
      gmt psxy ${F_SEIS}proj_eqs_scaled.txt -Ya-${PS_HEIGHT_IN_NOLABELS}i -R${MINPROJ_X}/${MAXPROJ_X}/${depth_range[0]}/${depth_range[1]} -JX${PSSIZE}i/${SEISPROJHEIGHT_X}i -Bxaf -Byaf+l"Depth" -BrbWt -C$SEIS_CPT ${SEIS_INPUTORDER1} ${EQWCOM} -S${SEISSYMBOL} -t${SEISTRANS} -O -K $VERBOSE --MAP_FRAME_PEN=thick,black --MAP_FRAME_TYPE=plain >> map.ps
      gmt gmtset PROJ_LENGTH_UNIT $OLD_PROJ_LENGTH_UNIT

      gmt_remove_tmpdir
    fi
fi

# plotbinprojflag=1
#
# # grdtrack an XY line on a grid, and plot box-and-whisker diagrams of the resulting values
# PROJXY_TRACKFILE="/Users/kylebradley/Dropbox/regionalplots/ecuador/badtrench.kml"
# PROJXY_GRIDFILE="/Users/kylebradley/Dropbox/TectoplotData/SRTM30_plus/topo30.grd"
# PROJXY_WIDTH=50k
# PROJXY_SPACING=2k
# PROJXY_SAMPLING=40k
# SEISPROJHEIGHT_X=2
#
# if [[ $plotbinprojflag -eq 1 ]]; then
#
#
#   kml_to_first_xy ${PROJXY_TRACKFILE} track.txt
#
#   gmt grdtrack track.txt -G${PROJXY_GRIDFILE} -C${PROJXY_WIDTH}/${PROJXY_SPACING}/${PROJXY_SAMPLING} -Ar -Sm+sstack.txt > proj_table.txt
#
#   # Assemble the data samples from the grdtrack table
#   gawk '{
#     if ($1 == ">") {
#       printf("\n")
#     } else {
#       printf("%g ", $5)
#     }
#   }' < proj_table.txt | sed '1d' > proj_data.txt
#
#   # These are the lon/lat locations of the crossline intersections with the profile line
#   gawk '{
#     if ($1 == ">") {
#       printf("\n%s ", $7)
#     }
#   }' < proj_table.txt | sed '1d' | tr '/' ' ' > proj_pts.txt
#
#   # projstats contains the quantile information for each crossline
#   while read p; do
#     echo "$p" | tr ' ' '\n' | st --summary | tail -n 1 >> proj_stats.txt
#   done <  proj_data.txt
#
#   GRID_RANGE=($(gawk < proj_table.txt '
#     BEGIN {
#       getline
#       min=$5
#       max=$5
#     }
#     {
#       min=(min<$5)?min:$5
#       max=(max>$5)?max:$5
#     }
#     END {
#       range=max-min
#       print  min-range/20, max+range/20
#     }'))
#
#     echo Data range is ${GRID_RANGE[@]}
#
#   # Project the data points into the Cartesian XY space
#   gmt mapproject ${RJSTRING[@]} proj_pts.txt > proj_xy.txt
#
#   paste proj_xy.txt proj_stats.txt | tr '\t' ' ' > proj_box.txt
#
#   cat proj_box.txt | gawk '{print $1, $5, $5, $3, $4, $6, $7}' > long_box.txt
#
#   gmt psxy track.txt -W1p,red ${RJOK} ${VERBOSE} >> map.ps
#   gmt psxy proj_table.txt -W0.5p,black ${RJOK} ${VERBOSE} >> map.ps
#
#       gmt_init_tmpdir
#
#       gmt psbasemap -R${MINPROJ_X}/${MAXPROJ_X}/${GRID_RANGE[0]}/${GRID_RANGE[1]} -JX${PSSIZE}i/${SEISPROJHEIGHT_X}i -Btlbr $VERBOSE > ${TMP}proj_fake.ps
#       PS_DIM=$(gmt psconvert proj_fake.ps -Te -A+m0i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
#       PS_HEIGHT_IN_NOLABELS=$(echo $PS_DIM | gawk  '{print $2/2.54 + 0.15}')
#
#       gmt psxy long_box.txt -Ya-${PS_HEIGHT_IN_NOLABELS}i -R${MINPROJ_X}/${MAXPROJ_X}/${GRID_RANGE[0]}/${GRID_RANGE[1]} -JX${PSSIZE}i/${SEISPROJHEIGHT_X}i -EY+p0.1p+w2p -Sp -C${F_CPTS}topo.cpt -Bxaf -Byaf -BEbWt -O -K $VERBOSE --MAP_FRAME_PEN=thick,black --MAP_FRAME_TYPE=plain >> map.ps
#
#       gmt_remove_tmpdir
# fi
#


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


    gmt mapproject ${RJSTRING[@]} ${F_SEIS}eqs.txt -i0,1 | gawk '{print $1, $2}' > ${F_SEIS}proj_eqs.txt
    gawk '
      (NR==FNR) {
        projx[NR]=$1
        projy[NR]=$2
      }
      (NR>FNR) {
        $1=-$3
        $2=projy[FNR]
        print
      }' ${F_SEIS}proj_eqs.txt ${F_SEIS}eqs_scaled.txt > ${F_SEIS}proj_eqs_scaled_y.txt

    if [[ $zctimeflag -eq 1 ]]; then
      SEIS_INPUTORDER1="-i0,1,6,3+s${SEISSCALE}"
      SEIS_INPUTORDER2="-i0,1,6"
      SEIS_CPT=${F_CPTS}"eqtime.cpt"
    elif [[ $zcclusterflag -eq 1 ]]; then
      SEIS_INPUTORDER1="-i0,1,7,3+s${SEISSCALE}"
      SEIS_INPUTORDER2="-i0,1,7"
      SEIS_CPT=${F_CPTS}"eqcluster.cpt"
    else
      SEIS_INPUTORDER1="-i0,1,2,3+s${SEISSCALE}"
      SEIS_INPUTORDER2="-i0,1,2"
      SEIS_CPT=$SEISDEPTH_CPT
    fi

    if [[ $SCALEEQS -eq 1 ]]; then
      gmt_init_tmpdir

      PS_DIM=$(gmt psconvert base_fake_nolabels.ps -Te -A+m0i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
      MAP_PS_HEIGHT_IN_NOLABELS=$(echo $PS_DIM | gawk  '{print $2/2.54}')
      MAP_PS_WIDTH_IN_NOLABELS=$(echo $PS_DIM | gawk  '{print $1/2.54}')

      # gmt psbasemap -R${depth_range[0]}/${depth_range[1]}/${MINPROJ_Y}/${MAXPROJ_Y} -JX${SEISPROJHEIGHT_Y}i/${MAP_PS_HEIGHT_IN_NOLABELS}i -Btlbr $VERBOSE > ${TMP}seisdepth_fake.ps

      # PS_DIM=$(gmt psconvert seisdepth_fake.ps -Te -A+m0i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
      # PANEL_WIDTH=$(echo $PS_DIM | gawk  '{print $1/2.54}')

      PS_OFFSET_IN_NOLABELS=$(echo $MAP_PS_WIDTH_IN_NOLABELS | gawk  '{print $1+ 0.15}')

      OLD_PROJ_LENGTH_UNIT=$(gmt gmtget PROJ_LENGTH_UNIT -Vn)
      gmt gmtset PROJ_LENGTH_UNIT p

      gmt psxy ${F_SEIS}proj_eqs_scaled_y.txt -Xa${PS_OFFSET_IN_NOLABELS}i -R${depth_range[0]}/${depth_range[1]}/${MINPROJ_Y}/${MAXPROJ_Y} -JX${SEISPROJWIDTH_Y}i/${MAP_PS_HEIGHT_IN_NOLABELS}i -Bxaf+l"Depth" -Byaf -BlNrb -C$SEIS_CPT ${SEIS_INPUTORDER1} ${EQWCOM} -S${SEISSYMBOL} -t${SEISTRANS} -O -K $VERBOSE --MAP_FRAME_PEN=thick,black --MAP_FRAME_TYPE=plain >> map.ps
      gmt gmtset PROJ_LENGTH_UNIT $OLD_PROJ_LENGTH_UNIT

      gmt_remove_tmpdir
    fi
fi



# This is likely not compatible with the above section

if [[ $plotbigbarflag -eq 1 ]]; then

  if [[ ! -e ${BIGBARCPT} ]]; then
    echo "No CPT file for big bar found"
  fi
  gmt psscale -DJCB+w${PSSIZE}i+o0/1c+h+e -C${BIGBARCPT} -Bxaf+l"${BIGBARANNO}" -G${BIGBARLOW}/${BIGBARHIGH} $RJOK ${VERBOSE} >> map.ps
fi

current_usergridnumber=1

##### SECTION LEGEND
if [[ $makelegendflag -eq 1 ]]; then
  gmt gmtset MAP_TICK_LENGTH_PRIMARY 0.5p MAP_ANNOT_OFFSET_PRIMARY 1.5p MAP_ANNOT_OFFSET_SECONDARY 2.5p MAP_LABEL_OFFSET 2.5p FONT_LABEL 6p,Helvetica,black

  # Plan is to plot legend to a file for EVERY call to tectoplot, and only
  # push onto the map using gmt psimage AFTER making the legend.

  info_msg "Plotting legend in its own file"
  LEGMAP="maplegend.ps"
  gmt psxy -T ${RJSTRING[@]} -X$PLOTSHIFTX -Y$PLOTSHIFTY -K $VERBOSE > maplegend.ps


  # Add the plot commands to the legend color bar command list

  # Should we have to explicitly register these per module instead of spamming plots[@]?

  for plot in ${plots[@]} ; do
    legendbarwords+=("$plot")
  done

  info_msg "Updated legend commands are >>>>> ${legendbarwords[@]} <<<<<"

  echo "# Legend " > legendbars.txt
  barplotcount=0
  plottedneiscptflag=0

  info_msg "Plotting colorbar legend items"

  # First, plot the color bars in a column. How many could you possibly have anyway?
  # We should probably be using -Bxaf for everything instead of overthinking things

  for legend_plot in ${legendbarwords[@]} ; do
  	case $legend_plot in

      tomoslice)
        echo "G 0.2i" >> legendbars.txt
        echo "B ${F_CPTS}tomography.cpt 0.2i 0.1i+malu -Bxa1f0.2+l\"Velocity anomaly (percent)\"" >> legendbars.txt
        barplotcount=$barplotcount+1
      ;;

      eulerpoles)
        echo "G 0.2i" >> legendbars.txt
        echo "B ${F_CPTS}polerate.cpt 0.2i 0.1i+malu -Bxa1f0.2+l\"Rotation rate (degrees/Myr)\"" >> legendbars.txt
        barplotcount=$barplotcount+1
      ;;

      plateedgecolor)
        echo "G 0.2i" >> legendbars.txt
        echo "B ${F_CPTS}az.cpt 0.2i 0.1i+malu -Bxa90f45+l\"Obliquity (degrees)\"" >> legendbars.txt
        barplotcount=$barplotcount+1
      ;;

      cmt|seis)
        # Don't plot a color bar if we already have plotted one OR the seis CPT is a solid color
        if [[ $plottedneiscptflag -eq 0 && ! $seisfillcolorflag -eq 1 && $replaceseiscptflag -eq 0 ]]; then
          plottedneiscptflag=1
          echo "G 0.2i" >> legendbars.txt
          echo "B $SEISDEPTH_NODEEPEST_CPT 0.2i 0.1i+malu+e -Bxaf+l\"Earthquake / slab depth (km)\"" >> legendbars.txt
          barplotcount=$barplotcount+1
        fi
        ;;

      eqcluster)

        # Calculate the number of clusters to display in the legend bar?
        gawk < $SEIS_CPT '
          ($1+0==$1 && $1 < 30) {
            print
          }
          ($1+0!=$1) {
            print
          }' > ${F_CPTS}cluster_truncate.cpt
        echo "G 0.2i" >> legendbars.txt
        echo "B ${F_CPTS}cluster_truncate.cpt 0.2i 0.1i+malu+e -S+c+s -Bxa10 -B+l\"EQ cluster number\"" >> legendbars.txt
        barplotcount=$barplotcount+1
        ;;

      eqtime)
          echo "G 0.2i" >> legendbars.txt
          echo "B $SEIS_CPT 0.2i 0.1i+malu+e -S+c+s -B+l\"Earthquake time\"" >> legendbars.txt
          barplotcount=$barplotcount+1
        ;;

      # geoage)
      #   if [[ -e $GEOAGE_CPT ]]; then
      #
      #     # Reduce the CPT to the used scale range
      #     gmt makecpt -C$GEOAGE_CPT -G${GEOAGE_COLORBAR_MIN}/${GEOAGE_COLORBAR_MAX} -T${GEOAGE_COLORBAR_MIN}/${GEOAGE_COLORBAR_MAX}/10 ${VERBOSE} > ${F_CPTS}geoage_colorbar.cpt
      #
      #     echo "G 0.2i" >> legendbars.txt
      #     echo "B ${F_CPTS}geoage_colorbar.cpt 0.2i 0.1i+malu -Bxa100f50+l\"Age (Ma)\"" >> legendbars.txt
      #     barplotcount=$barplotcount+1
      #   fi
      #   ;;

  		grav)
        if [[ -e $GRAV_CPT ]]; then
          echo "G 0.2i" >> legendbars.txt
          echo "B $GRAV_CPT 0.2i 0.1i+malu -Bxa100f50+l\"$GRAVMODEL gravity (mgal)\"" >> legendbars.txt
          barplotcount=$barplotcount+1
        fi
  			;;

      gravcurv)
        if [[ -e $GRAV_CURV_CPT ]]; then
          echo "G 0.2i" >> legendbars.txt
          echo "B $GRAV_CURV_CPT 0.2i 0.1i+malu -Bxa100f50+l\"$GRAVMODEL curvature (mgal)\"" >> legendbars.txt
          barplotcount=$barplotcount+1
        fi
        ;;

      litho1)
        if [[ $LITHO1_TYPE == "density" ]]; then
          echo "G 0.2i" >> legendbars.txt
          echo "B $LITHO1_DENSITY_CPT 0.2i 0.1i+malu -Bxa500f50+l\"LITHO1.0 density (kg/m^3)\"" >> legendbars.txt
          barplotcount=$barplotcount+1
        elif [[ $LITHO1_TYPE == "Vp" ]]; then
          echo "G 0.2i" >> legendbars.txt
          echo "B $LITHO1_VELOCITY_CPT 0.2i 0.1i+malu -Bxa1000f250+l\"LITHO1.0Vp velocity (m/s)\"" >> legendbars.txt
          barplotcount=$barplotcount+1
        elif [[ $LITHO_TYPE == "Vs" ]]; then
          echo "G 0.2i" >> legendbars.txt
          echo "B $LITHO1_VELOCITY_CPT 0.2i 0.1i+malu -Bxa1000f250+l\"LITHO1.0 Vs velocity (m/s)\"" >> legendbars.txt
          barplotcount=$barplotcount+1
        fi
        ;;


      # oceanage)
      #   echo "G 0.2i" >> legendbars.txt
      #   echo "B $OC_AGE_CPT 0.2i 0.1i+malu -Bxa50+l\"Ocean crust age (Ma)\"" >> legendbars.txt
      #   barplotcount=$barplotcount+1
      #   ;;

      plateazdiff)
        echo "G 0.2i" >> legendbars.txt
        echo "B ${CPTDIR}cycleaz.cpt 0.2i 0.1i+malu -Bxa90f30+l\"Azimuth difference (°)\"" >> legendbars.txt
        barplotcount=$barplotcount+1
        ;;

      platevelgrid)
        echo "G 0.2i" >> legendbars.txt
        echo "B $PLATEVEL_CPT 0.2i 0.1i+malu -Bxa50f10+l\"Plate velocity (mm/yr)\"" >> legendbars.txt
        barplotcount=$barplotcount+1
        ;;

      # seis)
      #   if [[ $plottedneiscptflag -eq 0 ]]; then
      #     plottedneiscptflag=1
      #     echo "G 0.2i" >> legendbars.txt
      #     echo "B $SEISDEPTH_NODEEPEST_CPT 0.2i 0.1i+malu -Bxa100f50+l\"Earthquake / slab depth (km)\"" >> legendbars.txt
      #     barplotcount=$barplotcount+1
      #   fi
  		# 	;;

  		# slab2)
      #   if [[ $plottedneiscptflag -eq 0 ]]; then
      #     plottedneiscptflag=1
      #     echo "G 0.2i" >> legendbars.txt
      #     echo "B ${SEISDEPTH_NODEEPEST_CPT} 0.2i 0.1i+malu -Bxa100f50+l\"Earthquake / slab depth (km)\"" >> legendbars.txt
      #     barplotcount=$barplotcount+1
      #   fi
  		# 	;;

      seissum)
        if [[ $SSUNIFORM -eq 1 ]]; then
          echo "G 0.2i" >> legendbars.txt
          echo "B ${F_CPTS}seissum.cpt 0.2i 0.1i+malu -Bxaf+l\"Earthquake count\"" >> legendbars.txt
        else
          echo "G 0.2i" >> legendbars.txt
          echo "B ${F_CPTS}seissum.cpt 0.2i 0.1i+malu -Bxaf+l\"M0 (x10^N)\"" -W0.001 >> legendbars.txt
        fi
        barplotcount=$barplotcount+1

        ;;

      topo)
        echo "G 0.2i" >> legendbars.txt
        echo "B ${TOPO_CPT} 0.2i 0.1i+malu -Bxa${BATHYXINC}f1+l\"Elevation (km)\"" -W0.001 >> legendbars.txt
        barplotcount=$barplotcount+1
        ;;

      # usergrid)
      #   echo "G 0.2i" >> legendbars.txt
      #   echo "B ${GRIDADDCPT[$current_usergridnumber]} 0.2i 0.1i+malu -Bxaf+l\"$(basename ${GRIDADDFILE[$current_usergridnumber]})\"" >> legendbars.txt
      #   barplotcount=$barplotcount+1
      #   current_usergridnumber=$(echo "$current_usergridnumber + 1" | bc -l)
      #   ;;
      *)

        tectoplot_legendbar_caught=0
        for this_mod in ${TECTOPLOT_MODULES[@]}; do
          if type "tectoplot_legendbar_${this_mod}" >/dev/null 2>&1; then
            cmd="tectoplot_legendbar_${this_mod}"
            "$cmd" ${legend_plot}
          fi
          if [[ $tectoplot_legendbar_caught -eq 1 ]]; then
            break
          fi
        done

        # if type "tectoplot_legendbar_${plot}" >/dev/null 2>&1; then
        #   # info_msg "Running module post-processing for ${plot}"
        #   cmd="tectoplot_legendbar_${plot}"
        #   "$cmd"
        # else
        #   info_msg "Unrecognized legend bar command: $plot"
        # fi

        ;;

  	esac
  done

  velboxflag=0
  [[ $barplotcount -eq 0 ]] && LEGEND_WIDTH=0.01
  LEG2_X=$(echo "$LEGENDX $LEGEND_WIDTH 0.1i" | gawk  '{print $1+$2+$3 }' )
  LEG2_Y=${MAP_PS_HEIGHT_IN_plus}

  # The non-colorbar plots come next. pslegend can't handle a lot of things well,
  # and scaling is difficult. Instead we make small eps files and plot them,
  # keeping track of their size to allow relative positioning
  # Not sure how robust this is... but it works...

  # NOTE: Velocities need to be scaled by gpsscalefactor to fit with the map

  # We will plot items vertically in increments of 3, and then add an X_INC and send Y to MAP_PS_HEIGHT_IN
  count=0
  # Keep track of the largest width we have used and make next column not overlap it.
  NEXTX=0
  GPS_ELLIPSE_TEXT=$(gawk -v c=0.95 'BEGIN{print c*100 "%" }')

  info_msg "Plotting non-colorbar legend items: ${plots[@]}"

  for legend_plot in ${plots[@]} ; do
  	case $legend_plot in
      cmt)
        info_msg "Legend: cmt"

        MEXP_TRIPLE=$(gawk < $CMTFILE '
          @include "tectoplot_functions.awk"
          # function ceil(x){return int(x)+(x>int(x))}
          BEGIN {
            getline;
            maxmag=$13
          }
          {
            maxmag=($13>maxmag)?$13:maxmag
          }
          END {
            if (maxmag>9) {
              maxmag=9
            }
            printf "%0.1d %0.1d %0.1d", ceil(maxmag)-2, ceil(maxmag)-1, ceil(maxmag)
          }')

        MEXP_ARRAY=($(echo $MEXP_TRIPLE))
        MEXP_V_N=${MEXP_ARRAY[0]}
        MEXP_V_S=${MEXP_ARRAY[1]}
        MEXP_V_T=${MEXP_ARRAY[2]}

        # MEXP_V_N=${MEXP_ARRAY[1]}
        # MEXP_V_S=${MEXP_ARRAY[1]}
        # MEXP_V_T=${MEXP_ARRAY[1]}

        MEXP_N=$(stretched_m0_from_mw $MEXP_V_N)
        MEXP_S=$(stretched_m0_from_mw $MEXP_V_S)
        MEXP_T=$(stretched_m0_from_mw $MEXP_V_T)

        # if [[ $CMTLETTER == "c" ]]; then
        #   echo "$CENTERLON $CENTERLAT 15 322 39 -73 121 53 -104 $MEXP_N 126.020000 13.120000 C021576A" | gmt_psmeca $SEISDEPTH_CPT -E"${CMT_NORMALCOLOR}" -L0.25p,black ${CMTEXTRA} -S${CMTLETTER}"$CMTRESCALE"i/0 $RJOK ${VERBOSE} >> mecaleg.ps
        #   if [[ $axescmtnormalflag -eq 1 ]]; then
        #     [[ $axestflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 220 0.99" | gawk  -v scalev=${CMTAXESSCALE} '{print $1, $2, $3, $4*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,purple -Gblack $RJOK $VERBOSE >>  mecaleg.ps
        #     [[ $axespflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 342 0.23" | gawk  -v scalev=${CMTAXESSCALE} '{print $1, $2, $3, $4*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,blue -Gblack $RJOK $VERBOSE >>  mecaleg.ps
        #     [[ $axesnflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 129 0.96" | gawk  -v scalev=${CMTAXESSCALE} '{print $1, $2, $3, $4*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,green -Gblack $RJOK $VERBOSE >>  mecaleg.ps
        #   fi
        #   echo "$CENTERLON $CENTERLAT N/${MEXP_V_N}" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE -J -R -Y0.14i -O -K >> mecaleg.ps
        #   echo "$CENTERLON $CENTERLAT 14 92 82 2 1 88 172 $MEXP_S 125.780000 8.270000 B082783A" | gmt_psmeca $SEISDEPTH_CPT -E"${CMT_SSCOLOR}" -L0.25p,black ${CMTEXTRA} -S${CMTLETTER}"$CMTRESCALE"i/0 $RJOK -X0.35i -Y-0.15i ${VERBOSE} >> mecaleg.ps
        #   if [[ $axescmtssflag -eq 1 ]]; then
        #     [[ $axestflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 316 0.999" | gawk  -v scalev=${CMTAXESSCALE} '{print $1, $2, $3, $4*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,purple -Gblack $RJOK $VERBOSE >>  mecaleg.ps
        #     [[ $axespflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 47 0.96" | gawk  -v scalev=${CMTAXESSCALE} '{print $1, $2, $3, $4*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,blue -Gblack $RJOK $VERBOSE >>  mecaleg.ps
        #     [[ $axesnflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 167 0.14" | gawk  -v scalev=${CMTAXESSCALE} '{print $1, $2, $3, $4*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,green -Gblack $RJOK $VERBOSE >>  mecaleg.ps
        #   fi
        #   echo "$CENTERLON $CENTERLAT SS/${MEXP_V_S}" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE -J -R -Y0.15i -O -K >> mecaleg.ps
        #   echo "$CENTERLON $CENTERLAT 33 321 35 92 138 55 89 $MEXP_T 123.750000 7.070000 M081676B" | gmt_psmeca $SEISDEPTH_CPT -E"${CMT_THRUSTCOLOR}" -L0.25p,black  ${CMTEXTRA} -S${CMTLETTER}"$CMTRESCALE"i/0 -X0.35i -Y-0.15i -R -J -O -K ${VERBOSE} >> mecaleg.ps
        #   if [[ $axescmtthrustflag -eq 1 ]]; then
        #     [[ $axestflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 42 0.17" | gawk  -v scalev=${CMTAXESSCALE} '{print $1, $2, $3, $4*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,purple -Gblack $RJOK $VERBOSE >>  mecaleg.ps
        #     [[ $axespflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 229 0.999" | gawk  -v scalev=${CMTAXESSCALE} '{print $1, $2, $3, $4*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,blue -Gblack $RJOK $VERBOSE >>  mecaleg.ps
        #     [[ $axesnflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 139 0.96" | gawk  -v scalev=${CMTAXESSCALE} '{print $1, $2, $3, $4*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,green -Gblack $RJOK $VERBOSE >>  mecaleg.ps
        #   fi
        #   # echo "$CENTERLON $CENTERLAT R/${MEXP_V_T}" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE -J -R -Y0.16i -O >> mecaleg.ps
        #   echo "$CENTERLON $CENTERLAT reverse" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE -J -R -Y0.16i -O >> mecaleg.ps
        # fi
        if [[ $CMTLETTER == "m" ]]; then
          echo "$CENTERLON $CENTERLAT 10 -3.19 1.95 1.24 -0.968 -0.425 $MEXP_N 0 0 " | gmt_psmeca $SEISDEPTH_CPT -E"${CMT_NORMALCOLOR}" -L0.25p,black  ${CMTEXTRA} -S${CMTLETTER}"$CMTRESCALE"i/0 $RJOK -X0.15i ${VERBOSE} >> mecaleg.ps
          if [[ $axescmtnormalflag -eq 1 ]]; then
            [[ $axestflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 220 0.99" | gawk  -v scalev=${CMTAXESSCALE} '{print $1, $2, $3, $4*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,purple -Gblack $RJOK $VERBOSE >>  mecaleg.ps
            [[ $axespflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 342 0.23" | gawk  -v scalev=${CMTAXESSCALE} '{print $1, $2, $3, $4*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,blue -Gblack $RJOK $VERBOSE >>  mecaleg.ps
            [[ $axesnflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 129 0.96" | gawk  -v scalev=${CMTAXESSCALE} '{print $1, $2, $3, $4*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,green -Gblack $RJOK $VERBOSE >>  mecaleg.ps
          fi
          echo "$CENTERLON $CENTERLAT N/${MEXP_V_N}" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE -J -R -Y0.20i -O -K >> mecaleg.ps
          # echo "$CENTERLON $CENTERLAT normal" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE -J -R -Y0.20i -O -K >> mecaleg.ps
          echo "$CENTERLON $CENTERLAT 10 0.12 -1.42 1.3 0.143 -0.189 $MEXP_S 0 0 " | gmt_psmeca $SEISDEPTH_CPT -E"${CMT_SSCOLOR}" -L0.25p,black ${CMTEXTRA} -S${CMTLETTER}"$CMTRESCALE"i/0 $RJOK -X0.4i -Y-0.20i ${VERBOSE} >> mecaleg.ps
          if [[ $axescmtssflag -eq 1 ]]; then
            [[ $axestflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 316 0.999" | gawk  -v scalev=${CMTAXESSCALE} '{print $1, $2, $3, $4*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,purple -Gblack $RJOK $VERBOSE >>  mecaleg.ps
            [[ $axespflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 47 0.96" | gawk  -v scalev=${CMTAXESSCALE} '{print $1, $2, $3, $4*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,blue -Gblack $RJOK $VERBOSE >>  mecaleg.ps
            [[ $axesnflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 167 0.14" | gawk  -v scalev=${CMTAXESSCALE} '{print $1, $2, $3, $4*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,green -Gblack $RJOK $VERBOSE >>  mecaleg.ps
          fi
          echo "$CENTERLON $CENTERLAT SS/${MEXP_V_S}" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE -J -R -Y0.20i -O -K >> mecaleg.ps
          # echo "$CENTERLON $CENTERLAT strike-slip" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE -J -R -Y0.20i -O -K >> mecaleg.ps
          echo "$CENTERLON $CENTERLAT 15 2.12 -1.15 -0.97 0.54 -0.603 $MEXP_T 0 0 2016-12-08T17:38:46" | gmt_psmeca $SEISDEPTH_CPT -E"${CMT_THRUSTCOLOR}" -L0.25p,black ${CMTEXTRA} -S${CMTLETTER}"$CMTRESCALE"i/0 -X0.4i -Y-0.20i -R -J -O -K ${VERBOSE} >> mecaleg.ps
          if [[ $axescmtthrustflag -eq 1 ]]; then
            [[ $axestflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 42 0.17" | gawk  -v scalev=${CMTAXESSCALE} '{print $1, $2, $3, $4*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,purple -Gblack $RJOK $VERBOSE >>  mecaleg.ps
            [[ $axespflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 229 0.999" | gawk  -v scalev=${CMTAXESSCALE} '{print $1, $2, $3, $4*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,blue -Gblack $RJOK $VERBOSE >>  mecaleg.ps
            [[ $axesnflag -eq 1 ]] && echo "$CENTERLON $CENTERLAT 139 0.96" | gawk  -v scalev=${CMTAXESSCALE} '{print $1, $2, $3, $4*scalev}' | gmt psxy -SV${CMTAXESARROW}+jc+b+e -W0.4p,green -Gblack $RJOK $VERBOSE >>  mecaleg.ps
          fi
          echo "$CENTERLON $CENTERLAT R/${MEXP_V_T}" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE -J -R -Y0.20i -O >> mecaleg.ps
          # echo "$CENTERLON $CENTERLAT reverse" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE -J -R -Y0.20i -O >> mecaleg.ps
        fi

        PS_DIM=$(gmt psconvert mecaleg.ps -Te -A0.05i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
        PS_WIDTH_IN=$(echo $PS_DIM | gawk  '{print $1/2.54}')
        PS_HEIGHT_IN=$(echo $PS_DIM | gawk  '{print $2/2.54}')
        gmt psimage -Dx"${LEG2_X}i/${LEG2_Y}i"+w${PS_WIDTH_IN}i mecaleg.eps $RJOK ${VERBOSE} >> $LEGMAP
        LEG2_Y=$(echo "$LEG2_Y + $PS_HEIGHT_IN + 0.02" | bc -l)
        count=$count+1
        NEXTX=$(echo $PS_WIDTH_IN $NEXTX | gawk  '{if ($1>$2) { print $1 } else { print $2 } }')
        ;;

      eqlabel)
        info_msg "Legend: eqlabel"

        [[ $EQ_LABELFORMAT == "idmag"   ]]  && echo "$CENTERLON $CENTERLAT ID Mw" | gawk  '{ printf "%s %s %s(%s)\n", $1, $2, $3, $4 }'      > eqlabel.legend.txt
        [[ $EQ_LABELFORMAT == "datemag" ]]  && echo "$CENTERLON $CENTERLAT Date Mw" | gawk  '{ printf "%s %s %s(%s)\n", $1, $2, $3, $4 }'    > eqlabel.legend.txt
        [[ $EQ_LABELFORMAT == "dateid"  ]]  && echo "$CENTERLON $CENTERLAT Date ID" | gawk  '{ printf "%s %s %s(%s)\n", $1, $2, $3, $4 }'    > eqlabel.legend.txt
        [[ $EQ_LABELFORMAT == "id"      ]]  && echo "$CENTERLON $CENTERLAT ID" | gawk  '{ printf "%s %s %s\n", $1, $2, $3 }'                 > eqlabel.legend.txt
        [[ $EQ_LABELFORMAT == "date"    ]]  && echo "$CENTERLON $CENTERLAT Date" | gawk  '{ printf "%s %s %s\n", $1, $2, $3 }'               > eqlabel.legend.txt
        [[ $EQ_LABELFORMAT == "year"    ]]  && echo "$CENTERLON $CENTERLAT Year" | gawk  '{ printf "%s %s %s\n", $1, $2, $3 }'               > eqlabel.legend.txt
        [[ $EQ_LABELFORMAT == "yearmag" ]]  && echo "$CENTERLON $CENTERLAT Year Mw" | gawk  '{ printf "%s %s %s(%s)\n", $1, $2, $3, $4 }'    > eqlabel.legend.txt
        [[ $EQ_LABELFORMAT == "mag"     ]]  && echo "$CENTERLON $CENTERLAT Mw" | gawk  '{ printf "%s %s %s\n", $1, $2, $3 }'                 > eqlabel.legend.txt

        cat eqlabel.legend.txt | gmt pstext -Gwhite -W0.5p,black -F+f${EQ_LABEL_FONTSIZE},${EQ_LABEL_FONT},${EQ_LABEL_FONTCOLOR}+j${EQ_LABEL_JUST} -R -J -O ${VERBOSE} >> eqlabel.ps
        PS_DIM=$(gmt psconvert eqlabel.ps -Te -A0.05i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
        PS_WIDTH_IN=$(echo $PS_DIM | gawk  '{print $1/2.54}')
        PS_HEIGHT_IN=$(echo $PS_DIM | gawk  '{print $2/2.54}')
        gmt psimage -Dx"${LEG2_X}i/${LEG2_Y}i"+w${PS_WIDTH_IN}i eqlabel.eps $RJOK ${VERBOSE} >> $LEGMAP
        LEG2_Y=$(echo "$LEG2_Y + $PS_HEIGHT_IN + 0.02" | bc -l)
        count=$count+1
        NEXTX=$(echo $PS_WIDTH_IN $NEXTX | gawk  '{if ($1>$2) { print $1 } else { print $2 } }')
        ;;

      grid)
        info_msg "Legend: grid"

        GRIDMAXVEL_INT=$(echo "scale=0;($GRIDMAXVEL+5)/1" | bc)
        V100=$(echo "$GRIDMAXVEL_INT" | bc -l)
        if [[ $PLATEVEC_COLOR =~ "white" ]]; then
          echo "$CENTERLON $CENTERLAT $GRIDMAXVEL_INT 0 0 0 0 0 ID" | gmt psvelo -W0p,gray@$PLATEVEC_TRANS -Ggray@$PLATEVEC_TRANS -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 -L $RJOK $VERBOSE >> velarrow.ps 2>/dev/null
        else
          echo "$CENTERLON $CENTERLAT $GRIDMAXVEL_INT 0 0 0 0 0 ID" | gmt psvelo -W0p,$PLATEVEC_COLOR@$PLATEVEC_TRANS -G$PLATEVEC_COLOR@$PLATEVEC_TRANS -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 -L $RJOK $VERBOSE >> velarrow.ps 2>/dev/null
        fi
        echo "$CENTERLON $CENTERLAT Plate velocity ($GRIDMAXVEL_INT mm/yr)" | gmt pstext -F+f6p,Helvetica,black+jLB $VERBOSE -J -R -Y0.1i -O >> velarrow.ps
        PS_DIM=$(gmt psconvert velarrow.ps -Te -A0.05i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
        PS_WIDTH_IN=$(echo $PS_DIM | gawk  '{print $1/2.54}')
        PS_HEIGHT_IN=$(echo $PS_DIM | gawk  '{print $2/2.54}')
        gmt psimage -Dx"${LEG2_X}i/${LEG2_Y}i"+w${PS_WIDTH_IN}i velarrow.eps $RJOK ${VERBOSE} >> $LEGMAP
        LEG2_Y=$(echo "$LEG2_Y + $PS_HEIGHT_IN + 0.02" | bc -l)
        count=$count+1
        NEXTX=$(echo $PS_WIDTH_IN $NEXTX | gawk  '{if ($1>$2) { print $1 } else { print $2 } }')
        ;;

      gps)
        info_msg "Legend: gps"

        GPSMAXVEL_INT=$(echo "scale=0;($GPSMAXVEL+5)/1" | bc)
        echo "$CENTERLON $CENTERLAT $GPSMAXVEL_INT 0 5 5 0 ID" | gmt psvelo -W${GPS_LINEWIDTH},${GPS_LINECOLOR} -G${GPS_FILLCOLOR} -A${ARROWFMT} -Se$VELSCALE/${GPS_ELLIPSE}/0 -L $RJOK $VERBOSE >> velgps.ps 2>/dev/null
        GPSMESSAGE="GPS: $GPSMAXVEL_INT mm/yr (${GPS_ELLIPSE_TEXT})"
        echo "$CENTERLON $CENTERLAT $GPSMESSAGE" | gmt pstext -F+f6p,Helvetica,black+jLB -J -R -Y0.1i -O ${VERBOSE} >> velgps.ps
        PS_DIM=$(gmt psconvert velgps.ps -Te -A0.05i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
        PS_WIDTH_IN=$(echo $PS_DIM | gawk  '{print $1/2.54}')
        PS_HEIGHT_IN=$(echo $PS_DIM | gawk  '{print $2/2.54}')
        gmt psimage -Dx"${LEG2_X}i/${LEG2_Y}i"+w${PS_WIDTH_IN}i velgps.eps $RJOK ${VERBOSE} >> $LEGMAP
        LEG2_Y=$(echo "$LEG2_Y + $PS_HEIGHT_IN + 0.02" | bc -l)
        count=$count+1
        NEXTX=$(echo $PS_WIDTH_IN $NEXTX | gawk  '{if ($1>$2) { print $1 } else { print $2 } }')
        ;;

      kinsv)
        info_msg "Legend: kinsv"
        echo "$CENTERLON $CENTERLAT" | gmt psxy -Sc0.01i -W0p,white -Gwhite $RJOK $VERBOSE >> kinsv.ps
        echo "$CENTERLON $CENTERLAT" | gmt psxy -Ss0.4i -W0p,lightblue -Glightblue $RJOK -X0.4i $VERBOSE >> kinsv.ps
        KINMESSAGE=" EQ kinematic vectors "
        echo "$CENTERLON $CENTERLAT $KINMESSAGE" | gmt pstext -F+f6p,Helvetica,black+jLB $VERBOSE -J -R -Y0.2i -X-0.35i -O -K >> kinsv.ps
        echo "$CENTERLON $CENTERLAT 31 .35" | gmt psxy -SV0.05i+jb+e -W0.4p,${NP1_COLOR} -G${NP1_COLOR} $RJOK -X0.35i  -Y-0.2i $VERBOSE >> kinsv.ps

        if [[ $plottedkinsd -eq 1 ]]; then # Don't close
          echo "$CENTERLON $CENTERLAT 235 .35" | gmt psxy -SV0.05i+jb+e -W0.4p,${NP2_COLOR} -G${NP2_COLOR} $RJOK $VERBOSE >> kinsv.ps
        else
          echo "$CENTERLON $CENTERLAT 235 .35" | gmt psxy -SV0.05i+jb+e -W0.4p,${NP2_COLOR} -G${NP2_COLOR} -R -J -O $VERBOSE >> kinsv.ps
        fi
        if [[ $plottedkinsd -eq 1 ]]; then
          echo "$CENTERLON $CENTERLAT 55 .1" | gmt psxy -SV0.05i+jb -W0.5p,white -Gwhite $RJOK $VERBOSE >> kinsv.ps
          echo "$CENTERLON $CENTERLAT 325 0.175" | gmt psxy -SV0.05i+jb -W0.5p,white -Gwhite $RJOK $VERBOSE >> kinsv.ps
          echo "$CENTERLON $CENTERLAT 211 .1" | gmt psxy -SV0.05i+jb -W0.5p,gray -Ggray $RJOK $VERBOSE >> kinsv.ps
          echo "$CENTERLON $CENTERLAT 121 0.175" | gmt psxy -SV0.05i+jb -W0.5p,gray -Ggray -R -J -O $VERBOSE >> kinsv.ps
        fi
        PS_DIM=$(gmt psconvert kinsv.ps -Te -A0.05i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
        PS_WIDTH_IN=$(echo $PS_DIM | gawk  '{print $1/2.54}')
        PS_HEIGHT_IN=$(echo $PS_DIM | gawk  '{print $2/2.54}')
        gmt psimage -Dx"${LEG2_X}i/${LEG2_Y}i"+w${PS_WIDTH_IN}i kinsv.eps $RJOK ${VERBOSE} >> $LEGMAP
        LEG2_Y=$(echo "$LEG2_Y + $PS_HEIGHT_IN + 0.02" | bc -l)
        count=$count+1
        NEXTX=$(echo $PS_WIDTH_IN $NEXTX | gawk  '{if ($1>$2) { print $1 } else { print $2 } }')
       ;;

      plate)
        # echo "$CENTERLON $CENTERLAT 90 1" | gmt psxy -SV$ARROWFMT -W${GPS_LINEWIDTH},${GPS_LINECOLOR} -G${GPS_FILLCOLOR} $RJOK $VERBOSE >> plate.ps
        # echo "$CENTERLON $CENTERLAT Kinematics stuff" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE -J -R -X0.2i -Y0.1i -O >> plate.ps
        # PS_DIM=$(gmt psconvert plate.ps -Te -A0.05i 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
        # PS_WIDTH_IN=$(echo $PS_DIM | gawk  '{print $1/2.54}')
        # PS_HEIGHT_IN=$(echo $PS_DIM | gawk  '{print $2/2.54}')
        # gmt psimage -Dx"${LEG2_X}i/${LEG2_Y}i"+w${PS_WIDTH_IN}i plate.ps $RJOK >> $LEGMAP
        # LEG2_Y=$(echo "$LEG2_Y + $PS_HEIGHT_IN + 0.02" | bc -l)
        # count=$count+1
        # NEXTX=$(echo $PS_WIDTH_IN $NEXTX | gawk  '{if ($1>$2) { print $1 } else { print $2 } }')
        ;;

      seis)
        info_msg "Legend: seis"

        if [[ -e $CMTFILE ]]; then
          # Get magnitude range from CMT
          SEIS_QUINT=$(gawk < $CMTFILE '
            @include "tectoplot_functions.awk"
            # function ceil(x){return int(x)+(x>int(x))}
            BEGIN {
              getline;
              maxmag=$13
            }
            {
              maxmag=($13>maxmag)?$13:maxmag
            }
            END {
              if (maxmag>9) {
                maxmag=9
              }
              print (maxmag>8)?"5.0 6.0 7.0 8.0 9.0":(maxmag>7)?"4.0 5.0 6.0 7.0 8.0":(maxmag>6)?"3.0 4.0 5.0 6.0 7.0":(maxmag>5)?"2.0 3.0 4.0 5.0 6.0":"1.0 2.0 3.0 4.0 5.0"
            }')
        else  # Get magnitude range from seismicity
          SEIS_QUINT=$(gawk < ${F_SEIS}eqs.txt '
            BEGIN {
              getline;
              maxmag=$4
            }
            {
              maxmag=($4>maxmag)?$4:maxmag
            }
            END {
              print (maxmag>8)?"5.0 6.0 7.0 8.0 9.0":(maxmag>7)?"4.0 5.0 6.0 7.0 8.0":(maxmag>6)?"3.0 4.0 5.0 6.0 7.0":(maxmag>5)?"2.0 3.0 4.0 5.0 6.0":"1.0 2.0 3.0 4.0 5.0"
            }')
        fi

        SEIS_ARRAY=($(echo $SEIS_QUINT))

        MW_A=$(stretched_mw_from_mw ${SEIS_ARRAY[0]})
        MW_B=$(stretched_mw_from_mw ${SEIS_ARRAY[1]})
        MW_C=$(stretched_mw_from_mw ${SEIS_ARRAY[2]})
        MW_D=$(stretched_mw_from_mw ${SEIS_ARRAY[3]})
        MW_E=$(stretched_mw_from_mw ${SEIS_ARRAY[4]})

        OLD_PROJ_LENGTH_UNIT=$(gmt gmtget PROJ_LENGTH_UNIT -Vn)
        gmt gmtset PROJ_LENGTH_UNIT p

        echo "$CENTERLON $CENTERLAT $MW_A DATESTR ID" | gmt psxy -W0.5p,black -G${ZSFILLCOLOR} -i0,1,2+s${SEISSCALE} -S${SEISSYMBOL} -t${SEISTRANS} $RJOK ${VERBOSE} >> seissymbol.ps
        echo "$CENTERLON $CENTERLAT ${SEIS_ARRAY[0]}" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE -J -R -Y0.13i -O -K >> seissymbol.ps
        echo "$CENTERLON $CENTERLAT $MW_B DATESTR ID" | gmt psxy -W0.5p,black -G${ZSFILLCOLOR} -i0,1,2+s${SEISSCALE} -S${SEISSYMBOL} -t${SEISTRANS} $RJOK -Y-0.13i -X0.25i ${VERBOSE} >> seissymbol.ps
        echo "$CENTERLON $CENTERLAT ${SEIS_ARRAY[1]}" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE -J -R -Y0.13i -O -K >> seissymbol.ps
        echo "$CENTERLON $CENTERLAT $MW_C DATESTR ID" | gmt psxy -W0.5p,black -G${ZSFILLCOLOR} -i0,1,2+s${SEISSCALE} -S${SEISSYMBOL} -t${SEISTRANS} $RJOK -Y-0.13i -X0.3i ${VERBOSE} >> seissymbol.ps
        echo "$CENTERLON $CENTERLAT ${SEIS_ARRAY[2]}" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE -J -R -Y0.14i -O -K >> seissymbol.ps
        echo "$CENTERLON $CENTERLAT $MW_D DATESTR ID" | gmt psxy -W0.5p,black -G${ZSFILLCOLOR} -i0,1,2+s${SEISSCALE} -S${SEISSYMBOL} -t${SEISTRANS} $RJOK -Y-0.13i -X0.3i ${VERBOSE} >> seissymbol.ps
        echo "$CENTERLON $CENTERLAT ${SEIS_ARRAY[3]}" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE -J -R -Y0.15i -O -K >> seissymbol.ps
        echo "$CENTERLON $CENTERLAT $MW_E DATESTR ID" | gmt psxy -W0.5p,black -G${ZSFILLCOLOR} -i0,1,2+s${SEISSCALE} -S${SEISSYMBOL} -t${SEISTRANS} $RJOK -Y-0.13i -X0.35i ${VERBOSE} >> seissymbol.ps
        echo "$CENTERLON $CENTERLAT ${SEIS_ARRAY[4]}" | gmt pstext -F+f6p,Helvetica,black+jCB $VERBOSE -J -R -Y0.16i -O >> seissymbol.ps

        gmt gmtset PROJ_LENGTH_UNIT $OLD_PROJ_LENGTH_UNIT

        PS_DIM=$(gmt psconvert seissymbol.ps -Te -A0.05i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
        PS_WIDTH_IN=$(echo $PS_DIM | gawk  '{print $1/2.54}')
        PS_HEIGHT_IN=$(echo $PS_DIM | gawk  '{print $2/2.54}')
        gmt psimage -Dx"${LEG2_X}i/${LEG2_Y}i"+w${PS_WIDTH_IN}i seissymbol.eps $RJOK ${VERBOSE} >> $LEGMAP
        LEG2_Y=$(echo "$LEG2_Y + $PS_HEIGHT_IN + 0.02" | bc -l)
        count=$count+1
        NEXTX=$(echo $PS_WIDTH_IN $NEXTX | gawk  '{if ($1>$2) { print $1 } else { print $2 } }')
        ;;

      *)  # Any unrecognized command is potentially a module command


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
    if [[ $count -eq 4 ]]; then
      count=0
      LEG2_X=$(echo "$LEG2_X + $NEXTX" | bc -l)
      # echo "Updated LEG2_X to $LEG2_X"
      LEG2_Y=$(echo "${MAP_PS_HEIGHT_IN} + 0.1" | bc -l)
    fi
  done


  if [[ $legendnotextflag -ne 1 ]]; then
    info_msg "Legend: printing data sources"
    # gmt pstext tectoplot.shortplot -F+f6p,Helvetica,black $KEEPOPEN $VERBOSE >> map.ps
    # x y fontinfo angle justify linespace parwidth parjust
    echo "> 0 0 9p Helvetica,black 0 l 0.1i ${INCH}i l" > datasourceslegend.txt
    uniq ${SHORTSOURCES} | gawk  'BEGIN {printf "T Data sources: "} {print}'  | tr '\n' ' ' >> datasourceslegend.txt
  else
    touch datasourceslegend.txt
  fi
  # gmt gmtset FONT_ANNOT_PRIMARY 8p,Helvetica-bold,black

  # NUMLEGBAR=$(wc -l < legendbars.txt)
  # if [[ $NUMLEGBAR -eq 1 ]]; then
  #   gmt pslegend datasourceslegend.txt -Dx0.0i/${MAP_PS_HEIGHT_IN_minus}i+w${LEGEND_WIDTH}+w${INCH}i+jBL -C0.05i/0.05i -J -R -O $KEEPOPEN ${VERBOSE} >> $LEGMAP
  # else
  #
  # if [[ $plottitleflag -eq 1 ]]; then
  #   # MAP_PS_HEIGHT_IN=$(echo "${MAP_PS_HEIGHT_IN} + 1" | bc -l)
  #   MAP_PS_HEIGHT_IN_plus=$(echo "${MAP_PS_HEIGHT_IN} + 1" | bc -l)
  # else
  #   MAP_PS_HEIGHT_IN_plus=${MAP_PS_HEIGHT_IN}
  # fi

  gmt pslegend datasourceslegend.txt -Dx0.0i/${MAP_PS_HEIGHT_IN}i+w${LEGEND_WIDTH}+w${INCH}i+jBL -C0.05i/0.05i -J -R -O -K ${VERBOSE} --FONT_ANNOT_PRIMARY=${FONT_ANNOT_COLORBAR} >> $LEGMAP
  gmt pslegend legendbars.txt -Dx0i/${MAP_PS_HEIGHT_IN_plus}i+w${LEGEND_WIDTH}+jBL -C0.05i/0.05i -J -R -O -K ${VERBOSE} --FONT_ANNOT_PRIMARY=${FONT_ANNOT_COLORBAR} >> $LEGMAP
  # fi



  # If we are closing the separate legend file, PDF it
  # if [[ $keepopenflag -eq 0 && $legendovermapflag -eq 0 ]]; then
    gmt psxy -T -R -J -O ${VERBOSE} >> ${LEGMAP}
    gmt psconvert -Tf -A+m0.5i ${VERBOSE} ${LEGMAP}
    # mv maplegend.pdf $THISDIR"/"$MAPOUTLEGEND
    # info_msg "Map legend is at $THISDIR/$MAPOUTLEGEND"
    # [[ $openflag -eq 1 ]] && open -a $OPENPROGRAM $THISDIR"/"$MAPOUTLEGEND
  # fi

  if [[ $legendovermapflag -eq 1 ]]; then
    PS_DIM=$(gmt psconvert maplegend.ps -Te -A+m0.05i -V 2> >(grep Width) | gawk  -F'[ []' '{print $10, $17}')
    LEG_WIDTH_IN=$(echo $PS_DIM | gawk  '{print $1/2.54}')
    LEG_HEIGHT_IN=$(echo $PS_DIM | gawk  '{print $2/2.54}')
    gmt psimage -Dx0i/${MAP_PS_HEIGHT_IN_plus}i+w${LEG_WIDTH_IN}i maplegend.eps $RJOK ${VERBOSE} >> map.ps
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


# Export TECTOPLOT call and GMT command history from PS file to .history file

# Close the PS if we need to
gmt psxy -T -R -J -O $KEEPOPEN $VERBOSE >> map.ps

echo "${COMMAND}" > "$MAPOUT.history"
echo "${COMMAND}" >> $OPTDIR"tectoplot.history"

grep "%@GMT:" map.ps | sed -e 's/%@GMT: //' >> "$MAPOUT.history"

##### MAKE PDF OF MAP
# Requires gs 9.26 and not later as they nuked transparency in later versions
if [[ $keepopenflag -eq 0 ]]; then
   if [[ $epsoverlayflag -eq 1 ]]; then
     gmt psconvert -Tf -A0.5i -Mf${EPSOVERLAY} $VERBOSE map.ps
   else
     gmt psconvert -Tf -A0.5i $VERBOSE map.ps
  fi

  if [[ $outputdirflag -eq 1 ]]; then
    mv map.pdf ${MAPOUT}.pdf
    move_exit ${MAPOUT}.pdf
    move_exit ${MAPOUT}.history
    # mv map.pdf "${OUTPUTDIRECTORY}/${MAPOUT}.pdf"
    # mv "$MAPOUT.history" $OUTPUTDIRECTORY"/"$MAPOUT".history"
    info_msg "Map is at ${OUTPUTDIRECTORY}${MAPOUT}.pdf"
    [[ $openflag -eq 1 ]] && open_pdf "$MAPOUT.pdf"
  else
    mv map.pdf "${THISDIR}/${MAPOUT}.pdf"
    mv "$MAPOUT.history" $THISDIR"/"$MAPOUT".history"
    info_msg "Map is at $THISDIR/$MAPOUT.pdf"
    [[ $openflag -eq 1 ]] && open_pdf "$THISDIR/$MAPOUT.pdf"
  fi
fi

##### MAKE GEOTIFF OF MAP
if [[ $tifflag -eq 1 ]]; then
  gmt psconvert map.ps -Tt -A -W+g -E${GEOTIFFRES} ${VERBOSE}


  # For some reason the TFW file often comes out with funky latitude/longitude values...

  gawk < map.tfw -v maxlat=${MAXLAT} -v minlon=${MINLON} '{
    if (NR==6) {
      print maxlat
    } else if (NR==5) {
      print minlon
    } else {
      print
    }
  }' > map2.tfw

  mv map2.tfw map.tfw

  # For some reason the latitudes come out as +270 degrees...?
  # mv map.tif "${THISDIR}/${MAPOUT}.tif"
  # mv map.tfw "${THISDIR}/${MAPOUT}.tfw"


  [[ $openflag -eq 1 ]] && open_pdf "map.tif"
fi

##### Copy QGIS project into temporary directory

cp ${TECTOPLOTDIR}"qgis/tempfiles_to_delete/tectoplot.qgz" ./

##### Make script to plot oblique view of topography, execute if option is set
#     If we are
if [[ $plottedtopoflag -eq 1 ]]; then
  info_msg "Oblique map (${OBLIQUEAZ}/${OBLIQUEINC})"
  PSSIZENUM=$(echo $PSSIZE | gawk  '{print $1+0}')

  # if [[ $demisclippedflag -eq 1 ]]; then
  #   P_MAXLON=${CLIP_MAXLON}
  #   P_MINLON=${CLIP_MINLON}
  #   P_MAXLAT=${CLIP_MAXLAT}
  #   P_MINLAT=${CLIP_MINLAT}
  # else
  #   P_MAXLON=${MAXLON}
  #   P_MINLON=${MINLON}
  #   P_MAXLAT=${MAXLAT}
  #   P_MINLAT=${MINLAT}
  # fi


  # zrange is the elevation change across the DEM
  zrange=($(grid_zrange $BATHY -C -Vn))

  if [[ $obplotboxflag -eq 1 ]]; then
    OBBOXCMD="-N${OBBOXLEVEL}+gwhite"
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

  echo "#!/bin/sh" >> ./make_oblique.sh
  echo "if [[ \$# -ge 1 ]]; then" >> ./make_oblique.sh
  echo "  OBLIQUE_VEXAG=\${1}" >> ./make_oblique.sh
  echo "else" >> ./make_oblique.sh
  echo "  OBLIQUE_VEXAG=${OBLIQUE_VEXAG}"  >> ./make_oblique.sh
  echo "fi" >> ./make_oblique.sh

  echo "if [[ \$# -ge 2 ]]; then" >> ./make_oblique.sh
  echo "  OBLIQUEAZ=\${2}" >> ./make_oblique.sh
  echo "else" >> ./make_oblique.sh
  echo "  OBLIQUEAZ=${OBLIQUEAZ}"  >> ./make_oblique.sh
  echo "fi" >> ./make_oblique.sh

  echo "if [[ \$# -ge 3 ]]; then" >> ./make_oblique.sh
  echo "  OBLIQUEINC=\${3}" >> ./make_oblique.sh
  echo "else" >> ./make_oblique.sh
  echo "  OBLIQUEINC=${OBLIQUEINC}"  >> ./make_oblique.sh
  echo "fi" >> ./make_oblique.sh

  echo "if [[ \$# -ge 4 ]]; then" >> ./make_oblique.sh
  echo "  OBLIQUERES=\${4}" >> ./make_oblique.sh
  echo "else" >> ./make_oblique.sh
  echo "  OBLIQUERES=${OBLIQUERES}"  >> ./make_oblique.sh
  echo "fi" >> ./make_oblique.sh

  echo "DELTAZ_IN=\$(echo \"\${OBLIQUE_VEXAG} * ${PSSIZENUM} * (${zrange[1]} - ${zrange[0]})/ ( (${DEM_MAXLON} - ${DEM_MINLON}) * 111000 )\"  | bc -l)"  >> ./make_oblique.sh

  # echo "gmt grdview $BATHY -G${COLORED_RELIEF} -R$MINLON/$MAXLON/$MINLAT/$MAXLAT -JM${MINLON}/${PSSIZENUM}i -JZ\${DELTAZ_IN}i ${OBBOXCMD} -Qi${OBLIQUERES} ${OBBCOMMAND} -p\${OBLIQUEAZ}/\${OBLIQUEINC} --GMT_HISTORY=false --MAP_FRAME_TYPE=$OBBAXISTYPE ${VERBOSE} > oblique.ps" >> ./make_oblique.sh
  if [[ $plotimageflag -eq 1 ]]; then
    echo "gmt grdimage im.tiff ${RJSTRING[@]} ${OBBOXCMD} -Qi\${OBLIQUERES} ${OBBCOMMAND} -p\${OBLIQUEAZ}/\${OBLIQUEINC} --GMT_HISTORY=false --MAP_FRAME_TYPE=$OBBAXISTYPE ${VERBOSE} > ob2.ps" >> ./make_oblique.sh
  fi
  echo "gmt grdview $BATHY -G${COLORED_RELIEF} ${RJSTRING[@]} -JZ\${DELTAZ_IN}i ${OBBOXCMD} -Qi\${OBLIQUERES} ${OBBCOMMAND} -p\${OBLIQUEAZ}/\${OBLIQUEINC} --GMT_HISTORY=false --MAP_FRAME_TYPE=$OBBAXISTYPE ${VERBOSE} > oblique.ps" >> ./make_oblique.sh
  echo "gmt psconvert oblique.ps -Tf -A0.5i --GMT_HISTORY=false ${VERBOSE}" >> ./make_oblique.sh
  chmod a+x ./make_oblique.sh

  if [[ $obliqueflag -eq 1 ]]; then
    ./make_oblique.sh
  fi
fi

##### MAKE KML OF MAP
if [[ $kmlflag -eq 1 ]]; then

  echo RJSTRING="${RJSTRING[@]}"

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
  #
  # echo "($MAXLON - $MINLON) / $ncols" | bc -l > map.tfw
  # echo "0" >> map.tfw
  # echo "0" >> map.tfw
  # echo "- ($MAXLAT - $MINLAT) / $nrows" | bc -l >> map.tfw
  # echo "$MINLON" >> map.tfw
  # echo "$MAXLAT" >> map.tfw
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


fi ### if [[ $noplotflag -ne 1 ]]; then....

## Source the 3d modeling script

source "${MAKE3D_SCRIPT}"

##

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

# # Create a utility data projection script matching the current map setup
# # Will take a whitespace delimited text file and the numbers of the lon/lat
# # columns and will output the same file with projected coordinates
#
# # data_project.sh lon_col_num lat_col_num
# echo "#!/bin/bash" > ${F_MAPELEMENTS}data_project.sh
# for element in ${RJSTRING[@]}; do
#   echo "RJSTRING+=(\"$element\")" >> ${F_MAPELEMENTS}data_project.sh
# done
# echo "echo \${RJSTRING[@]}"  >> ${F_MAPELEMENTS}data_project.sh
# echo ""
exit 0

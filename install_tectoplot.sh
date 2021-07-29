#!/usr/bin/env bash

# UPDATE 9
# Script modified from https://raw.githubusercontent.com/mtbradley/brewski/master/mac-brewski.sh by Mark Bradley

set -o errexit
set -o pipefail

if [ ! -w $(pwd) ]; then
  echo "Current directory $(pwd) is not writeable. Exiting."
  exit
fi

GMTREQ="6.1"
GAWKREQ="5"

CCOMPILER="gcc"
CXXCOMPILER="g++"
F90COMPILER="gfortran"

UPDATEFLAG=1
UPGRADEFLAG=1

# Try to set up path to C Compiler
if [[ ! -z $CONDA_DEFAULT_ENV ]]; then
  [[ ! -z ${CC} ]] && CCOMPILER=$(which ${CC})
  [[ ! -z ${CXX} ]] && CXXCOMPILER=$(which ${CXX})
  [[ ! -z ${F90} ]] && F90COMPILER=$(which ${F90})
fi


tectoplot_folder_dir="${HOME}"
miniconda_folder_dir="${HOME}"

# Function to output details of script.
function script_info() {
    cat <<EOF

Name:           install_tectoplot.sh
Description:    Automated installation of tectoplot + tectoplot-examples, +
                installation of dependencies using Homebrew or miniconda
Author:         Kyle Bradley, Nanyang Technological University
Tested:         MacOS Catalina, Mojave, Big Sur, Ubuntu Linux (regular + WSL)
Usage:          /usr/bin/env bash install_tectoplot.sh

The following directories will be created          :   Default location
Home directory of tectoplot and tectoplot-examples :   ${HOME}/tectoplot/
Miniconda directory (if installing)                :   ${HOME}/miniconda/
tectoplot data directory                           :   ${HOME}/TectoplotData/

Installation of dependencies using Homebrew may require root access via sudo


EOF
}

function report_storage() {
  local this_folder="${1}"
  echo
  kb_home=$(df -k $this_folder | sed '1d' | awk '{print $4/1024/1024}')
  echo "Disk containing directory $this_folder has ~${kb_home} Gb of storage remaining. "
  echo
}

function clone_tectoplot() {
  if [[ -d ${tectoplot_folder_dir}/tectoplot ]]; then
    echo "tectoplot directory ${tectoplot_folder_dir}/tectoplot already exists. Delete before reinstalling!"
  else
    if git clone https://github.com/kyleedwardbradley/tectoplot.git ${tectoplot_folder_dir}/tectoplot; then
      echo "tectoplot succesfully cloned to ${tectoplot_folder_dir}/tectoplot/"
    else
      echo "ERROR: Could not clone tectoplot repository to ${tectoplot_folder_dir}/tectoplot/"
    fi
  fi
}

function clone_tectoplot_examples() {
  if [[ -d ${tectoplot_folder_dir}/tectoplot-examples/ ]]; then
    echo "tectoplot directory ${tectoplot_folder_dir}/tectoplot-examples/ already exists. Delete before reinstalling!"
  else
    if git clone https://github.com/kyleedwardbradley/tectoplot-examples ${tectoplot_folder_dir}/tectoplot-examples; then
      echo "tectoplot-examples succesfully cloned to ${tectoplot_folder_dir}/tectoplot-examples/"
    else
      echo "ERROR: Could not clone tectoplot examples repository to ${tectoplot_folder_dir}/tectoplot-examples/"
    fi
  fi
}

function check_tectoplot() {
  while true; do
    read -r -p "Do you want to install tectoplot and/or tectoplot-examples from Github? Default is yes. [Yy|Nn] " response1
    case $response1 in
      Y|y|yes|"")
        read -r -p "Which components do you want to install? Default is both. [ tectoplot | examples | both ] " response
        case $response in
          tectoplot)
            INSTALL_TECTOPLOT_REPO="true"
            INSTALL_TECTOPLOT_EXAMPLES="false"
            break
          ;;
          examples)
            INSTALL_TECTOPLOT_REPO="false"
            INSTALL_TECTOPLOT_EXAMPLES="true"
            break
          ;;
          both|"")
            INSTALL_TECTOPLOT_REPO="true"
            INSTALL_TECTOPLOT_EXAMPLES="true"
            break
          ;;
        esac
        break
      ;;
      *)
        echo "Not installing tectoplot or tectoplot-examples"
        break
      ;;
    esac
  done

  if [[ ${INSTALL_TECTOPLOT_REPO} =~ "true" || ${INSTALL_TECTOPLOT_EXAMPLES} =~ "true" ]]; then

    while true; do
      echo "Define the installation directory for tectoplot and/or tectoplot-examples."
      echo "To accept default (${tectoplot_folder_dir}/tectoplot/), press enter. Otherwise, type a complete path and press enter."
      read -r -p "" response
      case $response in
        "")
          echo
          if [[ ! -d $tectoplot_folder_dir ]]; then
            echo "Directory $tectoplot_folder_dir does not exist. Not installing tectoplot or tectoplot-examples."
            INSTALL_TECTOPLOT_REPO="false"
            INSTALL_TECTOPLOT_EXAMPLES="false"
          else
            if [[ ${INSTALL_TECTOPLOT_REPO} =~ "true" && -d ${tectoplot_folder_dir}/tectoplot/ ]]; then
              echo "ERROR: tectoplot folder ${tectoplot_folder_dir}/tectoplot/ already exists!"
              echo "Not installing tectoplot over existing folder. Delete if reinstalling."
              INSTALL_TECTOPLOT_REPO="false"
            else
              echo "tectoplot: Target directory is ${tectoplot_folder_dir}/tectoplot/"
              INSTALL_TECTOPLOT_REPO="true"
            fi
            if [[ ${INSTALL_TECTOPLOT_EXAMPLES} =~ "true" && -d ${tectoplot_folder_dir}/tectoplot-examples/ ]]; then
              echo "ERROR: tectoplot folder ${tectoplot_folder_dir}/tectoplot-examples/ already exists!"
              echo "Not installing tectoplot-examples over existing folder. Delete if reinstalling."
              INSTALL_TECTOPLOT_EXAMPLES="false"
            else
              echo "tectoplot-examples: Target directory is ${tectoplot_folder_dir}/tectoplot-examples/"
              INSTALL_TECTOPLOT_EXAMPLES="true"
            fi
          fi
          break
        ;;
        none)
          echo
          INSTALL_TECTOPLOT_REPO="false"
          INSTALL_TECTOPLOT_EXAMPLES="false"
          break
        ;;
        *)
          echo
          if [[ ! -d $response ]]; then
            echo "Installation directory $response does not exist. Creating folder."
            mkdir -p "$response"
            tectoplot_folder_dir=$response
          else
            if [[ ${INSTALL_TECTOPLOT_REPO} =~ "true" && -d ${response}/tectoplot/ ]]; then
              echo "ERROR: tectoplot folder ${response}/tectoplot/ already exists!"
              echo "Not installing over existing folder.  Delete if reinstalling."
              INSTALL_TECTOPLOT_REPO="false"
            else
              tectoplot_folder_dir=$response
              echo "Target directory is ${tectoplot_folder_dir}/tectoplot/"
              INSTALL_TECTOPLOT_REPO="true"
            fi
            if [[ ${INSTALL_TECTOPLOT_EXAMPLES} =~ "true" && -d ${response}/tectoplot-examples/ ]]; then
              echo "ERROR: tectoplot-examples folder ${response}/tectoplot-examples/ already exists!"
              echo "Not installing over existing folder.  Delete if reinstalling."
              INSTALL_TECTOPLOT_EXAMPLES="false"
            else
              tectoplot_folder_dir=$response
              echo "Target directory is ${tectoplot_folder_dir}/tectoplot-examples/"
              INSTALL_TECTOPLOT_EXAMPLES="true"
            fi
          fi
          break
        ;;
      esac
    done

    if [[ ${INSTALL_TECTOPLOT_EXAMPLES} =~ "true" || ${INSTALL_TECTOPLOT_REPO} =~ "true" ]]; then
      report_storage ${tectoplot_folder_dir}
      while true; do
        read -r -p "Install selected repositories into ${tectoplot_folder_dir}/ ? Default is yes. [Yy|Nn] " response
        case "${response}" in
        Y|y|"")
          break
          ;;
        N|n|*)
          INSTALL_TECTOPLOT_EXAMPLES="false"
          INSTALL_TECTOPLOT_REPO="false"
          break
          ;;
        *)
          echo "Unrecognized input ${response}. Not installing."
          INSTALL_TECTOPLOT_EXAMPLES="false"
          INSTALL_TECTOPLOT_REPO="false"
          break
          ;;
        esac
      done
    fi


  fi
}


function set_miniconda_folder() {
  echo "Default installation directory for miniconda: ${miniconda_folder_dir}/miniconda/"
  while true; do
    read -r -p "Enter alternative installation directory for miniconda/ (e.g. ${miniconda_folder_dir}/): [enter for default]   " response
    case $response in
      "")
        echo "Using default miniconda folder: $miniconda_folder_dir/miniconda/"
        break
      ;;
      *)
      if [[ ! -d $response ]]; then
        echo "Miniconda installation folder ${response} does not exist."
        exit 1
      else
        if [[ -d ${response}/miniconda/ ]]; then
          echo "WARNING: miniconda folder ${response}/miniconda/ already exists!"
        fi
        miniconda_folder_dir=$response
      fi
      break
      ;;
    esac
  done
  echo "Note: A miniconda installation of tectoplot requires ~3.2 Gb of storage space. "
}

function select_manager() {
  local response
  while true; do
    read -r -p "Do you want to use homebrew or miniconda to install/upgrade the dependencies? Default is no. [Yy|Nn] " response1
    case "${response1}" in
      Y|y)
        read -r -p "Which package manager do you want to install? Default is miniconda. [ homebrew | miniconda ] " response2
        case "${response2}" in
          homebrew)
            echo
            INSTALLTYPE="homebrew"
            echo "Assuming Homebrew Cellar will install onto disk holding directory $HOME..."
            report_storage $HOME
            break
            ;;
          miniconda|"")
            echo
            INSTALLTYPE="miniconda"
            break
            ;;
          *)
            echo "Unrecognized option. Trying again!"
            ;;
         esac
         ;;
     *)
       break
       ;;
     esac
  done
}

# Function check command exists
function command_exists() {
  command -v "${@}" >/dev/null 2>&1
}

function check_xcode() {
  if command -v xcode-select --version >/dev/null 2>&1; then
    echo "OSX: Xcode command line tools are already installed."
  else
    read -r -p "Installation on OSX requires Xcode command line tools. Install? Default=yes [Yy|Nn] " installxcode
    case $installxcode in
      Y|y|"")
        if xcode-select --install >/dev/null 2>&1; then
            echo "Re-run script after Xcode command line tools have finished installing."
            exit 1
        else
            echo "Xcode command line tools install failed."
            exit 1
        fi
        break
        ;;
      N|n)
        break
        ;;
      *)
        echo "Response ${installxcode} not recognized. Try again."
        ;;
    esac
    exit 1
  fi
}

function install_homebrew() {
  echo "Checking for Homebrew..."
  if command_exists "brew"; then
    echo "Homebrew is already installed."

    # Is there really any reason to update/upgrade? As they take significant
    # time to complete.

    if [[ $UPDATEFLAG -eq 1 ]]; then
      echo "Running brew update..."
      if brew update ; then
        echo "Brew update completed."
      else
        echo "Brew update failed."
      fi
    fi

    if [[ $UPGRADEFLAG -eq 1 ]]; then
      echo "Running brew upgrade..."
      if brew upgrade; then
        echo "Brew upgrade completed."
      else
        echo "Brew upgrade failed."
      fi
    fi

  else
    echo
    echo "Homebrew is not found. Attempting to install via curl..."
    if command_exists "curl"; then
      if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        echo "Homebrew was installed."

        # Linux / WSL
        if [[ -d /home/linuxbrew/ ]]; then
          echo "/home/linuxbrew/ exists: Adding brew to ~/.profile and activating brew in current environment"

          echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ${HOME}/.profile
          eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        fi
        # Other cases not yet known! E.g. OSX
      else
        echo "Homebrew install failed."
        exit 1
      fi
    else
      echo "curl not found... cannot install Homebrew."
      exit 1
    fi
  fi
}

function brew_packages() {

  echo "Installing packages using homebrew"
  # addition taps to enable packages not included in core tap
  tap_list=""
  # term_list includes packages which run from terminal without GUI
  term_list="git gawk proj gcc ghostscript evince"
  # "gmt@6"
  # cask_list includes packages macOS apps, fonts and plugins and other non-open source software
  cask_list=""

  # Install gmt 6.1.1 instead of GMT 6.2 until tectoplot is stable with 6.2
  if command -v gmt --version; then
	GMTVERSION=$(gmt --version)
	if brew list --versions gmt; then
		homebrew_gmt=$(brew list --versions gmt)
		if [[ $homebrew_gmt == "gmt 6.2"* ]]; then
			read -r -p "GMT 6.2 is already installed with homebrew. Uninstall? Default=yes [Yy|Nn] " douninstall
			case $douninstall in
			  Y|y|"")
				brew uninstall gmt
				;;
			  N|n)
			  echo exiting
				break
				;;
			  *)
				echo "Response $douninstall not recognized. Exiting"
				exit 1
				;;
			esac
		fi
	fi
  fi

  echo "Installing GMT 6.1.1_6 using homebrew"
  # This is the formula for GMT 6.1.1_6
  curl -L "https://raw.githubusercontent.com/Homebrew/homebrew-core/1179e1a8bfa9b8f985ee6f004a1ce65d3cba9a85/Formula/gmt.rb" > gmt.rb && HOMEBREW_NO_AUTO_UPDATE=1 brew install gmt.rb && rm -f gmt.rb

  echo "Pinning GMT 6.1.1"
  brew pin gmt

  echo "Installing other packages"
  for tap in ${tap_list}; do
    echo "Checking for tap > ${tap}"
    if brew tap | grep "${tap}" >/dev/null 2>&1 || command_exists "${tap}"; then
      echo "Tap ${tap} already added."
    else
      echo
      print_msg"Attempting to add tap ${tap}..."
      if brew tap "${tap}"; then
        echo "Tap ${tap} added."
      else
        echo "Unable to add tap ${tap}."
      fi
    fi
  done

  for pkg in ${term_list}; do
    echo "Checking for package > ${pkg}"
    if brew list "${pkg}" >/dev/null 2>&1 || command_exists "${pkg}"; then
      echo "Package ${pkg} already installed."
    else
      echo
      echo "Attempting to install ${pkg}..."
      if brew install "${pkg}"; then
        echo "Package ${pkg} installed."
      else
        echo "Package ${pkg} install failed."
      fi
    fi
  done
  # echo "Installing brew cask packages..."
  for cask in ${cask_list}; do
    echo "Checking for cask package > ${cask}"
    if brew list --cask "${cask}" >/dev/null 2>&1; then
      echo "Package ${cask} already installed."
    else
      echo
      echo "Attempting to install ${cask}..."
      if brew install --cask "${cask}"; then
          echo "Package ${cask} installed."
      else
          echo "Package ${cask} install failed."
      fi
    fi
  done
}

function install_evince() {
  if command_exists "brew"; then
    brew install evince
  else
    echo "Homebrew is not found. Installing Homebrew and evince."
    install_homebrew
    brew install evince
  fi
}

function exit_msg() {
  echo "Previous step failed... exiting"
  exit 1
}

function install_miniconda() {
  if [[ -d "${HOME}"/miniconda ]]; then
    echo "Miniconda already installed? ${HOME}/miniconda/ already exists."
  else
    case "$OSTYPE" in
      linux*)
        echo "Detected linux... assuming x86_64"
        curl https://repo.anaconda.com/miniconda/Miniconda2-latest-Linux-x86_64.sh > miniconda.sh
        ;;
      darwin*)
        echo "Detected OSX... assuming x86_64"
        curl https://repo.anaconda.com/miniconda/Miniconda2-latest-MacOSX-x86_64.sh >  miniconda.sh
      ;;
    esac
    if [[ -s ./miniconda.sh ]]; then
      echo "Executing miniconda installation script..."
      bash ./miniconda.sh -b -p $HOME/miniconda
    else
      echo "Could not execute miniconda.sh... exiting"
      exit 1
    fi
  fi
}

function miniconda_deps() {
  if [[ -x "${HOME}"/miniconda/bin/conda ]]; then
    source "${HOME}/miniconda/etc/profile.d/conda.sh"
    echo "Running conda hook..."
    eval $("${HOME}"/miniconda/bin/conda shell.bash hook)

    echo "Updating conda..."

    conda update -n base -c defaults conda

    echo "Activating conda..."
    conda activate || exit_msg

    echo "Initializing conda to use bash..."
    conda init bash || exit_msg

    echo "Creating tectoplot environment..."
    conda create --name tectoplot || exit_msg

    echo "Activating tectoplot environment..."
    conda activate tectoplot || exit_msg

    echo "Installing GMT 6.1.1 and dependencies into new tectoplot environment..."
    conda install python=3.9 git gmt=6.1.1 gawk ghostscript mupdf -c conda-forge

    case "$OSTYPE" in
      linux*)
        echo "Detected linux... assuming x86_64"
        conda install gcc_linux-64 gxx_linux-64 gfortran_linux-64 -c conda-forge
        ;;
      darwin*)
        echo "Detected OSX... assuming x86_64"
        conda install clang_osx-64 clangxx_osx-64 gfortran_osx-64 -c conda-forge
      ;;
    esac

    echo "After installation, from the command line run this command to"
    echo "use the installed tectoplot environment:"
    echo "conda activate tectoplot"
  else
    echo "Cannot call miniconda from ./miniconda/bin/conda. Exiting"
    exit 1
  fi
}



function install_evince_anyway() {
  while true; do
    read -r -p "PDF viewer evince cannot be installed using conda. Use homebrew to install? " response
    case "${response}" in
    Y|y|"")
      echo
      install_homebrew
      install_evince
      ;;
    *)
      ;;
    esac
  done
}

# This function tests for the presence of required software

function check_dependencies() {

  echo "Checking dependencies..."
  NEED_GIT=0
  unset needed

  case "$OSTYPE" in
    darwin*)
      check_xcode
    ;;
  esac


  # Check bash major version
  if [[ $(echo ${BASH_VERSION} $BASHREQ | awk '{if($1 >= $2){print 1}}') -ne 1 ]]; then
    echo "bash version $BASHREQ or greater is required (detected ${BASH_VERSION})"
    echo "Please manually upgrade bash"
    exit 1
  else
    echo "Found bash: $(which bash) ${BASH_VERSION}"
  fi

  # Check git version
  if [ `which git` ]; then
    echo -n "Found git: " && which git | awk '{ printf("%s ", $0)}' && git --version
  else
    echo "Error: git is not found"
    needed+=("git")
    NEED_GIT=1
  fi

  # Check gmt version
  if [ `which gmt` ]; then
  	GMT_VERSION=$(gmt --version)
  	if [[ $(echo ${GMT_VERSION} $GMTREQ | awk '{if($1 >= $2){print 1}}') -ne 1 ]]; then
  		echo "gmt version $GMTREQ or greater is required (detected ${GMT_VERSION})"
      needed+=("gmt")
  	else
      echo "Found gmt ${GMT_VERSION}: $(which gmt | awk '{ printf("%s ", $0)}')"
      GSHHG_DIR=$(gmt gmtget DIR_GSHHG)
      if [[ -d "${GSHHG_DIR}" ]]; then
         echo "  GSHHG data are present in ${GSHHG_DIR}"
      else
        needed+=("ghssg")
      fi
    fi
  else
  	echo "Error: gmt is not found"
    needed+=("gmt")
  fi

  if [ `which gawk` ]; then
  	GAWK_VERSION=$(gawk --version | gawk '(NR==1) { print substr($0,9,1) }')
  	if [[  $(echo ${GAWK_VERSION} $GAWKREQ | gawk '{if($1 >= $2){print 1}}') -ne 1 ]]; then
  		echo "gawk version $GAWKREQ or greater is required (detected ${GAWK_VERSION})"
      needed+=("gawk")
    else
      echo -n "Found gawk: " && which gawk | gawk '{ printf("%s ", $0)}' && gawk --version | head -n 1
  	fi
  else
  	echo "Error: gawk is not found"
    needed+=("gawk")
  fi

  if [ `which ${CCOMPILER}` ]; then
    echo -n "Found C compiler: " && which ${CCOMPILER} | awk '{ printf("%s ", $0)}' && ${CCOMPILER} -dumpversion
  else
  	echo "Error: Cannot call C compiler ${CCOMPILER}"
    needed+=("gcc")
  fi

  if [ `which ${CXXCOMPILER}` ]; then
    echo -n "Found C++ compiler: " && which ${CXXCOMPILER} | awk '{ printf("%s ", $0)}' && ${CXXCOMPILER} -dumpversion
  else
  	echo "Error: Cannot call C++ compiler ${CXXCOMPILER}."
    needed+=("g++")
  fi

  if [ `which ${F90COMPILER}` ]; then
    echo -n "Found fortran compiler: " && which ${F90COMPILER}
  else
  	echo "Error: Cannot call fortran compiler ${F90COMPILER}"
    needed+=("gfortran")
  fi

  if [ `which geod` ]; then
    echo -n "Found geod: " && which geod | awk '{ printf("%s ", $0)}' && geod 2>&1 | head -n 1
  else
  	echo "Error: geod not found"
    needed+=("geod")
  fi

  need_gdal=0
  if [ `which gdalinfo` ]; then
    echo -n "Found gdalinfo: " && which gdalinfo | awk '{ printf("%s ", $0)}' && gdalinfo --version
    GDAL_VERSION=$(gdalinfo --version | awk -F, '{split($1, tr, " "); print tr[2]}')

    if [[ $(echo ${GDAL_VERSION} $GDALREQ | awk '{if($1 >= $2){print 1}}') -ne 1 ]]; then
      echo "GDAL version ${GDAL_VERSION} is not up to date (requires ${GDALREQ})"
      need_gdal=1
    else
      if [ `which gdal_calc.py` ]; then
        echo -n "   Found gdal_calc.py: " && which gdal_calc.py
      else
        echo "   gdal_calc.py not found"
        need_gdal=1
      fi

      if [ `which gdalwarp` ]; then
        if [ `which gdaldem` ]; then
            echo -n "   Found gdalwarp: "
            which gdalwarp
        else
          echo "   gdalwarp not found"
          need_gdal=1
        fi
      fi

      if [ `which gdaldem` ]; then
          echo -n "   Found gdaldem: "
          which gdaldem
      else
        echo "   gdaldem not found"
        need_gdal=1
      fi
    fi

  else
  	echo "Error: gdalinfo not found"
    need_gdal=1
  fi

  [[ $need_gdal -eq 1 ]] && needed+=("gdal")

  if [[ -z ${needed[@]} ]]; then
    echo
    echo "All dependencies are present. Nothing needs to be installed/upgraded."
    echo
  else
    echo
    echo "These packages need to be updated or installed: ${needed[@]}"
    echo
  fi

}

function configure_tectoplot() {
  while true; do
    read -r -p "Configure (or reconfigure) tectoplot? Default is yes [Yy|Nn] " response
    case "${response}" in
    Y|y|"")
      echo
      CONFIGURE_TECTOPLOT=1
      break
      ;;
    N|n)
      break
      ;;
    *)
      ;;
    esac
  done



  if [[ $CONFIGURE_TECTOPLOT -eq 1 && -d ${tectoplot_folder_dir}/tectoplot/ ]]; then

    while true; do
      read -r -p "Activate tectoplot conda environment before configuring? Default is no [Yy|Nn] " response
      case "${response}" in
      Y|y|"")
        echo
        eval "$(conda shell.bash hook)"
        conda activate tectoplot
        break
        ;;
      N|n)
        break
        exit
        ;;
      *)
        ;;
      esac
    done

    cd ~/
    echo "Adding tectoplot to PATH variable in ~/.profile."
    echo

    ${tectoplot_folder_dir}/tectoplot/tectoplot -addpath
    source ~/.profile

    while true; do
      read -r -p "Set tectoplot data directory? It will be created if it doesn't exist. Default is yes. [Yy|Nn] " response
      case "${response}" in
        Y|y|"")
          read -r -p "Enter directory path (default is ${HOME}/TectoplotData/)" response2
          case "${response2}" in
            "")
              response2="${HOME}/TectoplotData/"
            ;;
          esac
          ${tectoplot_folder_dir}/tectoplot/tectoplot -setdatadir "${response2}/"
          break
          ;;
        N|n)
          echo
          break
          ;;
        *)
          echo Response ${response} not recognized. Try again.
        ;;
      esac
    done

    while true; do
      read -r -p "Set PDF viewer? Default is yes. [Yy|nn] " response
      case "${response}" in
        Y|y|"")
          if [[ $(grep microsoft /proc/version) ]]; then
            echo "Detected Windows Subsystem for Linux. Setting wslview as default viewer."
            ${tectoplot_folder_dir}/tectoplot/tectoplot -setopen wslview
          else
            read -r -p "OSX/Linux: Choose from evince, mupdf-gl, Preview, or name another program: " pdfviewer
            ${tectoplot_folder_dir}/tectoplot/tectoplot -setopen $pdfviewer
          fi
          break
          ;;
        N|n)
          echo
          break
          ;;
        *)
          echo Response ${response} not recognized. Try again.
        ;;
      esac
    done

    while true; do
      read -r -p "Compile companion codes? [Yy|Nn] " response
      case "${response}" in
        Y|y|"")
          ${tectoplot_folder_dir}/tectoplot/tectoplot -compile
          break
          ;;
        N|n)
          echo
          break
          ;;
        *)
          echo Response ${response} not recognized. Try again.
        ;;
      esac
    done

    echo "IMPORTANT: Run tectoplot -getdata and tectoplot -scrapedata to download datasets."

  fi
}

# Main logic
main() {
  clear
  script_info

  check_dependencies

  select_manager

  case $INSTALLTYPE in
    homebrew)
      install_homebrew
      brew_packages
    ;;
    miniconda)
      # In case we want evince, we need to install homebrew anyway.
      set_miniconda_folder
      report_storage $miniconda_folder_dir
      install_miniconda
      miniconda_deps
    ;;
  esac

  # If we ran an installation, check dependencies again!
  if [[ ! -z ${INSTALLTYPE} ]]; then

    # Try to set up path to compilers again
    if [[ ! -z $CONDA_DEFAULT_ENV ]]; then
      [[ ! -z ${CC} ]] && CCOMPILER=$(which ${CC})
      [[ ! -z ${CXX} ]] && CXXCOMPILER=$(which ${CXX})
      [[ ! -z ${F90} ]] && F90COMPILER=$(which ${F90})
    fi

    check_dependencies

    if [[ ! -z ${needed[@]} ]]; then
      echo "Remaining dependencies are not sufficient: ${needed[@]}"
      echo "Please manually fix using homebrew/miniconda or retry install_tectoplot.sh"

      while true; do
        read -r -p "Exit before cloning tectoplot? Default=yes [Yy|Nn] " response
        case "${response}" in
          Y|y|"")
            exit
            break
            ;;
          N|n)
            break
            ;;
          *)
            echo Response ${response} not recognized. Try again.
          ;;
        esac
      done

    fi
  fi

  # Determine what components of tectoplot should be installed, and where
  check_tectoplot

  if [[ $INSTALL_TECTOPLOT_REPO =~ "true" ]]; then
    clone_tectoplot
  fi

  if [[ $INSTALL_TECTOPLOT_EXAMPLES =~ "true" ]]; then
    clone_tectoplot_examples
  fi

  configure_tectoplot

  # if ! command_exists "evince"; then
  #   install_evince_anyway
  # fi

  echo "Script completed."
}

main "${@}"

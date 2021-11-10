tectoplot
=========

See the (thus far imaginary, hopefully soon actual) [project website][tectoplot] for documentation of tectoplot's features.

tectoplot is a bash script and associated helper scripts/programs that makes it easier to create seismotectonic maps, cross sections, and oblique block diagrams. It tries to simplify the process of making programmatic maps and figures from the command line in a Unix environment. tectoplot started as a basic script to automate making shaded relief maps with GMT, and has snowballed over time to incorporate many other functions.

Caveat Emptor
-------------

tectoplot is software written by a field geologist, and is in very early stages of development. Most of the code 'works', but the overall structure and design needs much improvement. None of the routines have been rigorously tested and there are certainly bugs in the code. tectoplot operates using bash, which means it can theoretically read or delete anything it has permission to access. I am making tectoplot publicly available at this early stage because my students and colleagues are already using it in a lot of ways, and their advice is helping me improve the code. With that being said, if you use tectoplot, please be sure to:

 * Only run tectoplot on a computer that is backed up, and run from an account that doesn't have root privileges or access to critical directories.

 * Sanity check all data, maps, and figures produced by tectoplot.

 * Appropriately cite datasets that you use, and please also cite [GMT 6][gmt6] if presenting a figure made using GMT.

 * Let me know if you find a bug or problem, and I will try to fix it!

An example tectoplot command
-----------------------

Here's an example tectoplot command that plots a seismotectonic map of Guatemala, showing topography, the Slab2.0 plate interface and seismicity colored by depth, volcanoes, and a 40 km wide swath cross section at 1:1 scale (no vertical exaggeration)

```proto
tectoplot -r GT+R2 -RJ B -t -tmult -tsl -b -z -vc -legend onmap -sprof -93 12.5 -90.5 16 30k 0.5k -oto -showprof 1 -o Guatemala
```

Let's break down the command to see what it does:

|Command|Effect|
|--|--|
|-r GT+R2|Set the map region to encompass Guatemala plus a 2 degree buffer|
|-RJ B|Select an Albers map projection|
|-t|Plot shaded topographic relief|
|-tmult|Calculate a multidirectional hillshade|
|-tsl|Calculate surface slope and fuse with hillshade|
|-z|Plot earthquake epicenters (default data are from USGS/ANSS)|
|-vc|Plot volcanoes (Smithsonian)|
|-legend onmap|Create a legend and place it onto the map pdf|
|-sprof -93 12.5 -90.5 16 30k 0.5k|Create a swath profile|
|-oto|Make the profile have 1:1 scaling|
|-showprof 1|Place the first (and only) profile onto the map PDF|
|-o Guatemala|Save the resulting PDF map to Guatemala.pdf|


The resulting figure is here (click to see the original PDF):

<a href=examples/Guatemala.pdf><img src=examples/Guatemala.png height=1200></a>

Credits and redistributed source code
-------------------------------------

tectoplot relies very heavily on the following open-source tools:

[GMT 6][gmt6]

[gdal][gdal]

tectoplot includes modified source redistributions of:

[Texture shading][text] by Leland Brown (C source with very minor modifications)

NDK import is heavily modified from [ndk2meca.awk][ndk2meca] by Thorsten Becker

Various focal mechanism calculations are modified from GMT's classic [psmeca.c/utilmeca.c][utilmeca] by G. Patau (IPGP)

Data
----

tectoplot is distributed with, or will download and manage, a wide variety of open geological and geophysical data, including data from:

* Topography/Bathymetry: SRTM - GEBCO - GMRT

* Satellite imagery: Sentinel cloud-free

* Earthquake hypocenters: ANSS - ISC - ISC-EHB

* Focal mechanisms: GCMT - ISC - GFZ

* Gravity: WGM - Sandwell2019

* Magnetics: EMAG_V2

* Lithospheric structure, stress: LITHO1 - SubMachine - WSM

* Faults and tectonic fabrics: SLAB2.0 - GEM active faults - EarthByte/GPlates

* Interseismic GPS velocities: GSRM

* Plate motion models: MORVEL56 - PB2003 - GSRM - GBM

* Earthquake slip models: SRCMOD

* Population centers - Geonames


Methods
-------

Code and general analytical approaches have been adopted from or inspired by the following research papers. There is no guarantee that the algorithms have been correctly implemented. Please cite these or related papers if they are particularly relevant to your own study.

[Reasenberg, 1985][rb]: Seismicity declustering (Fortran source, minor modifications).

[Zaliapin et al., 2008][zaliapin]: Seismicity declustering (Python code by Mark Williams, UNR)

[Weatherill et al., 2016][weatherill]:  Seismic catalog homogenization

[Kreemer et al., 2014][kreemer]: GPS velocity data and Global Strain Rate Map

[Hackl et al., 2009][hackl]: Strain rate tensor calculations

[Sandwell and Wessel, 2016][sandwess]: GPS interpolation using elastic Green functions

Pre-Installation notes
----------------------

**OSX**:

tectoplot will partially work with a pre-Catalina OS, but dependencies like GDAL 3.3.1 won't work so major functionality can disappear.

Before installing tectoplot on OSX, install the XCode command line tools:

```proto
xcode-select --install
```

**Older miniconda installations**:

If you have miniconda2 already installed, you won't be able to use the automated script to install the miniconda3 environment. These commands might fix the problem:

```proto
rm -rf ~/miniconda2
rm -rf ~/.condarc ~/.conda ~/.continuum
bash Miniconda3-latest-MacOSX-x86_64.sh # after downloading the installable

And when prompted to confirm the location, change it to miniconda instead of miniconda3.
```

**Ghostscript messages**

Note that gs 9.53 will pipe harmless warnings to stdout about transparency because we are still using GMT 6.1.1. It's fine to downgrade to an earlier version like gs 9.26 to avoid these messages.

Installation
============

tectoplot is confirmed to work on OSX (Catalina+), Ubuntu linux, and Windows 10 (WSL using Ubuntu). Other platforms are possible - let me know if you get something to work!

To install tectoplot and/or its dependencies using an interactive script, run the following command from a terminal. You may wish to read through the following sections first to understand the choices you will be presented!

```proto
/usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/kyleedwardbradley/tectoplot/main/install_tectoplot.sh)"
```

When running this script, you will need to know the following information in advance:

* Are you installing dependencies using Homebrew (see below)?
* Are you installing dependencies using miniconda (see below)?
* Are you installing tectoplot from the Github repository?
* Are you installing tectoplot-examples from the Github repository?

Do you know which directories you want to install tectoplot and it's data folder into?

|Directory | Default path |
|---|---|
|tectoplot installation directory|${HOME}/tectoplot/|
|tectoplot data directory|${HOME}/TectoplotData/|
|miniconda directory (only if installing miniconda environment)|${HOME}/miniconda/|



Installation without dependencies
---------------------------------

tectoplot should run on any linux-like system that has the following dependencies installed (version numbers are indicative). These can often be quickly installed using (for example) apt-get on Ubuntu, which can be much faster than using Homebrew or miniconda.

  gmt (6.1.1)
  geod (7.2.1)
  gawk (5.1.0)
  gdal (3.2.0)
  python (3.9)
  gs (9.26-9.53)
  gcc / g++ / gfortran or similar.

  If you have these already, use the **interactive installation script above** and decline to install any dependencies. The script will then help you install and configure tectoplot.

Installing dependencies using Homebrew or miniconda
---------------------------------------------------

Homebrew is a package manager that installs programs into a directory and links them into your active path so that you can simply call them from the command line. miniconda allows you to have an isolated environment for tectoplot that will not interfere with your existing system, but does need to be activated before using tectoplot.

Use the **interactive installation script above** and choose how you want to install dependencies (homebrew or miniconda). The script will then prompt you to install tectoplit and tectoplot-examples, and will help you configure your installation.

Installing dependencies via **homebrew** will try to install the following packages and their own dependencies:
(OSX + Linux): git gawk proj gcc gmt@6 ghostscript evince

Installing dependencies via **miniconda** will try to install the following packages and their own dependencies from conda-forge, and will configure tectoplot to use the miniconda compilers when a conda environment is active:

(OSX): python=3.9 git gmt=6.1.1 gawk ghostscript clang_osx-64 clangxx_osx-64 gfortran_osx-64
(Linux): python=3.9 git gmt=6.1.1 gawk ghostscript mupdf gcc_linux-64 gxx_linux-64 gfortran_linux-64

Configuring tectoplot and downloading data
------------------------------------------

The automated installation script will walk you through configuration of tectoplot. If you didn't use it, you will need to perform the following steps:


*  Add the new directory to your path environment variable. You may need to **restart your terminal** or otherwise ensure that your path has been updated. If you are not using bash, you may need to manually add the tectoplot folder to your path environment variable.

```proto
cd tectoplot
./tectoplot -addpath
source ~/.profile
```

Once tectoplot is in your path and can be called from anywhere, do the following steps:

* Check the status of your dependencies. Use `conda activate tectoplot` if necessary first.

```proto
tectoplot -checkdep
```

*	Define the directory where downloaded data will reside. tectoplot will
    download a lot of data if asked, and will also store cached DEM tiles in this
    directory, so make sure you have ~20 GB of disk space and a lot of time.

```proto
tectoplot -setdatadir "/full/path/to/data/directory/"
```

* Compile accompanying Fortran/C codes

```proto
tectoplot -compile
```

*	Set the program that will be called to open all PDFs generated (unless the -noopen option is given)

```proto
tectoplot -setopen evince
```

Downloading the builtin datasets
--------------------------------

* Download the online datasets into the data directory. If an error occurs,
   run this command again until all downloads clear. If something seems really broken,
   please let me know.

```proto
tectoplot -getdata
```

*	Scrape and process the seismicity and focal mechanism catalogs. This will
     take a **very** long time! The code is also a bit touchy and it's possible that things
     can get messed up - if that happens, delete the folders containing the offending
     data and scrape it again.

```proto
tectoplot -scrapedata
```

Updating tectoplot
------------------

tectoplot is under active development in my spare time, and I push bug fixes or new options on a regular basis. To keep up to date, change into the tectoplot directory and run:

```proto
git pull
```

License
-------

tectoplot is distributed under the following license. Redistributed source code retains its original license; see the source code for details.

tectoplot
Copyright (c) 2021 Kyle Bradley, all rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors
   may be used to endorse or promote products derived from this software without
   specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.



 [text]: http://www.textureshading.com/Home.html
 [utilmeca]: https://github.com/GenericMappingTools/gmt/blob/master/src/seis/utilmeca.c
 [gdal]: gdal.org
 [ndk2meca]: http://www-udc.ig.utexas.edu/external/becker/software/ndk2meca.awk
 [gmt6]: http://www.generic-mapping-tools.org
 [gmtcite]: https://www.generic-mapping-tools.org/cite/
 [tectoplot]: https://kyleedwardbradley.github.io/tectoplot/

 [rb]: https://doi.org/10.1029/JB090iB07p05479
 [zaliapin]: https://doi.org/10.1103/PhysRevLett.101.018501
 [weatherill]: https://doi.org/10.1093/gji/ggw232
 [kreemer]: https://doi.org/10.1002/2014GC005407
 [hackl]: https://doi.org/10.5194/nhess-9-1177-2009
 [sandwess]: doi.org/10.1002/2016GL070340

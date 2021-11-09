tectoplot
=========

See the [project website][tectoplot] for documentation of tectoplot's features.

tectoplot is a bash script and associated helper scripts/programs that makes it easier to create seismotectonic maps, cross sections, and oblique block diagrams. It tries to simplify the process of making programmatic maps and figures from the command line in a Unix environment. tectoplot started as a basic script to automate making shaded relief maps with GMT, and has snowballed over time to incorporate many other functions.

Caveat Emptor
-------------

tectoplot is software written by a field geologist, and is in very early stages of development. Most of the code 'works', but the overall structure and design needs much improvement. None of the routines have been rigorously tested and there are certainly bugs in the code. tectoplot operates using bash, which means it can theoretically access or delete anything it has permission to access. I am making tectoplot publicly available at this early stage because my students and colleagues are already using it and their advice is helping me improve the code. With that being said, if you use tectoplot, please be sure to:

 * Only run tectoplot on a computer that is backed up, and run from an account that doesn't have root privileges or access to critical directories.

 * Be sure to validate all data, maps, and figures produced by tectoplot.

 * Appropriately cite datasets that you use, and please also cite [GMT 6][gmt]

 * If you find a bug or problem, let me know and I will try to fix it!

What does tectoplot do?
-----------------------

Here's an example tectoplot command that plots seismicity and volcanoes in Guatemala.

```proto
tectoplot -r GT -t -tmult -tsl -z -vc -legend onmap
```

The resulting PDF figure looks like:

Let's break down the command to see what it does:

 * -r GT           Set the map region to encompass Guatemala
 * -t              Plot shaded topographic relif
 * -tmult          Calculate a multidirectional hillshade
 * -tsl            Calculate surface slope and fuse with hillshade
 * -z              Plot earthquake epicenters (default data are from USGS/ANSS)
 * -vc             Plot volcanoes (Smithsonian)
 * -legend onmap   Create a legend and place it onto the map pdf

Credits
-------

tectoplot relies very heavily on the following open-source tools:
[GMT 6][gmt6] - [gdal][gdal]

NDK import is heavily modified from [ndk2meca.awk][ndk2meca] by Thorsten Becker
Various CMT calculations are modified from GMT's classic [psmeca.c/utilmeca.c][utilmeca] by G. Patau (IPGP)

tectoplot includes modified source redistributions from:

[Texture shading][text] by Leland Brown (C source with very minor modifications)

Data and Methods
----------------

Code, data, and general analytical approaches have been adopted from or inspired by the following research papers. There is no guarantee that the algorithms have been correctly implemented. Please cite these papers if they are particularly relevant to your own study.

[Reasenberg, 1985][rb]: Seismicity declustering (Fortran source, minor modifications).

[Zaliapin et al., 2008][zaliapin]: Seismicity declustering (Python code by Mark Williams, UNR)

[Weatherill et al., 2016][weatherill]:  Seismic catalog homogenization

[Kreemer et al., 2014][kreemer]: GPS velocity data and Global Strain Rate Map

Installation
------------

 [text]: http://www.textureshading.com/Home.html
 [utilmeca]: https://github.com/GenericMappingTools/gmt/blob/master/src/seis/utilmeca.c
 [gdal]: gdal.org
 [ndk2meca]: http://www-udc.ig.utexas.edu/external/becker/software/ndk2meca.awk
 [gmt6]: http://www.generic-mapping-tools.org
 [gmtcite]: https://www.generic-mapping-tools.org/cite/
 [tectoplot]: https://kyleedwardbradley.github.io/tectoplot/

 [rb]: https://doi.org/10.1029/JB090iB07p05479
 [zaliapin]: https://journals.aps.org/prl/abstract/10.1103/PhysRevLett.101.018501
 [weatherill]: https://doi.org/10.1093/gji/ggw232
 [kreemer]: https://doi.org/10.1002/2014GC005407

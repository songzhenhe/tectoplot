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


Installation
------------


 [gmt]: https://www.generic-mapping-tools.org/cite/
 [tectoplot]: https://kyleedwardbradley.github.io/tectoplot/

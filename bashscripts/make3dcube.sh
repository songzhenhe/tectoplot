#!/usr/bin/env bash

if [[ $# -eq 1 ]]; then
  echo "make3dcube.sh [inputfile] [outputfile] [datalabel] [buffernumber]"
  echo "Create a 3D NetCDF data cube from regularly spaced geographic data"
  echo "inputfile is a text file with format: X (lon,deg) Y (lon,deg) Z (depth) V"
  echo "outputfile should have extension .nc"
  echo "datalabel is the name of the V data in the cube (e.g. vs)"
  echo "buffernumber is the number of NaN padding cells on X/Y sides of the cube"
fi

xyzvfile=$1
cubefile=$2
datalabel=$3
buffernumber=${4-0}  # 0 by default

xlabel="longitude [deg]"
ylabel="latitude [deg]"
zlabel="depth [km]"

# Get the data region and the list of z-slices
cubeinfo=($(gawk < $xyzvfile -v bufnum=${buffernumber} '
  BEGIN {
    ind=1
    xind=1
    yind=1
    zind=1

    xs[xind]=$1
    ys[yind]=$2
    zs[zind]=$3
    seenx[$1]++
    seeny[$2]++
    seenz[$3]++

  }
  {
    if (seenx[$1]++ == 0) {
      xs[xind++]=$1
    }
    if (seeny[$2]++ == 0) {
      ys[yind++]=$2
    }
    if (seenz[$3]++ == 0) {
      zs[zind++]=$3
    }

  }
  END {
    asort(xs)
    asort(ys)
    asort(zs)
    for (i=1;i<=length(zs);i++) {
      print zs[i] > "./depths.txt"
    }
    xint=xs[2]-xs[1]
    yint=ys[2]-ys[1]
    print xs[1]-xint*bufnum, xs[length(xs)]+xint*bufnum, ys[1]-yint*bufnum, ys[length(ys)]+yint*bufnum, xint, yint
  }'))

rm -f *.ttt
rm -f data_*.nc
depths=""
while read depth; do
  outfile="data_${depth}.nc"
  gawk < $xyzvfile -v dep=${depth} '($3 == dep) {print $1, $2, $4}' | gmt xyz2grd -R${cubeinfo[0]}/${cubeinfo[1]}/${cubeinfo[2]}/${cubeinfo[3]} -I${cubeinfo[4]}/${cubeinfo[5]} -G${outfile}
  grids+=(${outfile})
  if [[ $depths == "" ]]; then
    depths=${depth}
  else
    depths=${depths},${depth}
  fi
  ((ind++))
done < depths.txt

# gmt grdinterpolate $(cat gridslist.txt) -R0/vs_0.grd -Z -D+x"Longitude; positive east"+y"Latitude; positive north"+z"depth below Earth surface [km]"+dvs+vvs -Gvs.nc


gmt grdinterpolate ${grids[@]} -R${grids[0]} -Z${depths} -D+x"${xlabel}"+y"${ylabel}"+z"${zlabel}"+d${datalabel}+v${datalabel} -G${cubefile}

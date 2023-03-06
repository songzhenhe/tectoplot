#!/usr/bin/env bash

# tsurf to PLY format, projected from UTM to WGS1984 coordinates

ORIGPROJ="EPSG:26711"

# Newdepth is depth=(6371-rawdepth*v_exag)/100

# VRTX n E N Z
# E is easting in meters
# N is northing in meters
# Z is depth in meters, negative down

rm -f ./vertices.txt
rm -f ./tris.txt

# phi=deg2rad($1)
# theta=deg2rad(90-$2)
# depth=(6371-$3*v_exag)/100
# print depth*sin(theta)*cos(phi), depth*sin(theta)*sin(phi), depth*cos(theta), red[curcolor_ind], green[curcolor_ind], blue[curcolor_ind]

# convert depth in meters negative down to km positive down
gawk < $1 '
  ($1=="VRTX" ) {
    print $3, $4, $5/1000 > "./vertices.txt"
  }
  '

cs2cs -f "%g" ${ORIGPROJ} EPSG:4326 ./vertices.txt  | gawk '
BEGIN {
  maxlon=-999
  minlon=999
  maxlat=-99
  minlat=99
}
{
  minlat=($1<minlat)?$1:minlat
  maxlat=($1>maxlat)?$1:maxlat
  minlon=($2<minlon)?$2:minlon
  maxlon=($2>maxlon)?$2:maxlon
  print $2, $1, $3
}
END {
  print "-R" minlon "/" maxlon "/" minlat "/" maxlat > "./bounds.txt"
}' > ./wgsvertices.txt

gawk '
(NR==FNR) {
  vertlon[NR]=$1
  vertlat[NR]=$2
  vertdep[NR]=$3
}
(NR!=FNR) {
  if ($1=="TRGL") {
    v1=$2
    v2=$3
    v3=$4
    print ">", "face" ++trgl
    print vertlon[v1], vertlat[v1]
    print (vertlon[v1]+vertlon[v2])/2, (vertlat[v1]+vertlat[v2])/2

    print vertlon[v2], vertlat[v2]
    print (vertlon[v2]+vertlon[v3])/2, (vertlat[v2]+vertlat[v3])/2

    print vertlon[v3], vertlat[v3]
    print (vertlon[v3]+vertlon[v1])/2, (vertlat[v3]+vertlat[v1])/2

    print vertlon[v1], vertlat[v1]
  }
}
' ./wgsvertices.txt $1 > trianglepoly.gmt

gmt grdmask $(cat ./bounds.txt) -I0.005 trianglepoly.gmt -NNaN/1/1 -Gmask.nc
gmt grdfill mask.nc -An1 -Gmaskfill.nc
gmt triangulate wgsvertices.txt $(cat ./bounds.txt) -I0.005 -Gout.nc
gmt grdmath maskfill.nc out.nc MUL = $(basename $1 ".ts").tif=gd:GTiff

#!/bin/bash


gawk < $1 '
function abs(x) { return (x>0)?x:-x }
function addf(u,v, a, b) {
  split(u,a,".")
  # leading zeros are a problem for the second part.
  return sprintf("%d.%d", a[1]+v, a[2])
}

BEGIN {
  getmore=1
  while (getmore==1) {
    getline
    if ($1+0==$1) {
      oldlon=$1+0
      oldlat=$2+0
      getmore=0
    }
    print
  }
  modifier=0
}

($1+0!=$1) {
  getmore=1
  print
  while (getmore==1) {
    getline
    if ($1+0==$1) {
      oldlon=$1
      oldlat=$2
      getmore=0
    }
    print
    modifier=0
  }
}
($1+0==$1) {
  lon=$1
  lat=$2
  # Check to see if we crossed the dateline
  if (abs(lon-oldlon)>350) {
    if (oldlon > lon) {
      modifier=modifier+360
    } else {
      modifier=modifier-360
    }
  }
  oldlon=lon
  oldlat=lat
  print addf(lon,modifier), lat
}'

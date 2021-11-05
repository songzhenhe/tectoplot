# Process Submachine cross section data into lon lat depth val format
# Input is X Y Z val in Cartesian coordinates, downloaded from Submachine

gawk < $1 '
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
}' > tomography.txt

# tomography.txt is now in lon lat depth value format

# At this point, tomography.txt needs to be projected as an X object

# Discover the distance and depth ranges of the projected data
PROJRANGE=($(xy_range finaldist_P1_5projdist.txt))

# Generate the tomographic image over the relevant XY range
# Outer core is at 2200 km depth
gmt surface finaldist_P1_5projdist.txt -R${PROJRANGE[0]}/${PROJRANGE[1]}/${PROJRANGE[2]}/${PROJRANGE[3]} -Gtomography.nc -i0,1,3 -I10

# gmt grdimage tomography.nc -Cseis

# This lon lat depth z data can now be projected onto a profile using the typical projection approach
# But might also need interpolation

# In profile.sh, I need to add an interpolated, projected data class

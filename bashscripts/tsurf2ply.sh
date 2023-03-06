#!/usr/bin/env bash

# TSURF to PLY format, projected from UTM to WGS1984 coordinates

# TSURF file has vertices with the format:
# VRTX n E N Z
# n is the vertex index (starting at 1)
# E is easting in meters
# N is northing in meters
# Z is depth in kilometers, negative down

# NOTE: PLY vertices are indexed from 0, TSURF are indexed from 1. We have to
# subtract 1 from each vertex index to convert from TSURF->PLY

# Define the projection
ORIGPROJ="EPSG:26711"

MINLON=-118.55
MAXLON=-117.75
MINLAT=34
MAXLAT=34.7

cpt="categorical"

totalverts=0
outputobj=multifault.obj
outputobj_line=multifault_lines.obj

faultnum=0

rm -f ${outputobj} ${outputobj_line}

# Create a bunch of different RGB colors
colors=($(gmt makecpt -${cpt} -T0/255/1 -Fr | gawk '{print $2}'))

while [[ $1 == *.ts ]]; do

  ((faultnum++))

  echo "Making fault ${faultnum}: $1"

  rm -f ./cutvertices.txt ./vertices_cleaned.txt ./wgsvertices.txt ./tris.txt ./vertices.txt

  # Extract vertices and triangles, correcting for index 0/1
  gawk < $1 '
    ($1=="VRTX" ) {
      print $3, $4, 0-$5/1000 > "./vertices.txt"
    }
    ($1=="TRGL") {
    print 3, $2-1, $3-1, $4-1 > "./tris.txt"
    }'

  # Project vertices into EPSG:4326 coordinates

  cs2cs -f "%g" ${ORIGPROJ} EPSG:4326 ./vertices.txt  > ./wgsvertices.txt

  # We can theoretically exaggerate the faults vertically if we want, using v_exag

  # We can also mark the vertices that need to be trimmed based on longitude/latitude box

  gawk < ./wgsvertices.txt -v v_exag=1 -v minlon=$MINLON -v maxlon=$MAXLON -v minlat=$MINLAT -v maxlat=$MAXLAT '
  @include "/Users/kylebradley/Dropbox/scripts/tectoplot/awkscripts/tectoplot_functions.awk"
  {
    # $2 is longitude
    # $1 is latitude

    phi=deg2rad($2)
    theta=deg2rad(90-$1)
    depth=(6371-$3*v_exag)/100

    # Vertices are cut if they fall outside the AOI
    if ($2 < minlon || $2 > maxlon || $1 < minlat || $1 > maxlat) {
      print NR > "./cutvertices.txt"
    }
    print depth*sin(theta)*cos(phi), depth*sin(theta)*sin(phi), depth*cos(theta)
  }' > vertices_proj.txt

  numverts=$(wc -l < vertices_proj.txt | gawk '{print $1}')

  # Fix the PLY file to exclude cut vertices and update vertex numbers for faces
  if [[ -s ./cutvertices.txt ]]; then
    gawk '
    BEGIN {
      ind=0
    }
    (NR==FNR) {
      # indexed from 0 for PLY
      cut[$1-1]=1
    }
    (NR!=FNR) {
      if (cut[ind++]!=1) {
        print
      }
    }' ./cutvertices.txt vertices_proj.txt > vertices_cleaned.txt

    gawk -v numverts=$numverts '
    BEGIN {
      ind=0
      # Set up an array with the original indices
      for(i=0; i<numverts;i++) {
        fixedind[i]=i
      }
    }
    (NR==FNR) {
      # print "Cut", $1-1 > "/dev/stderr"
      cut[$1-1]=1
      # Remove an index from all following vertex indices
      # print "Trimming from", $1-1, "to", numverts-1 > "/dev/stderr"
      for(i=$1; i<numverts;i++) {
        fixedind[i]=fixedind[i]-1
      }
    }
    (NR!=FNR) {
      # print "checking tri", $2, $3, $4 > "/dev/stderr"

      # If all three vertices are inside the AOI, simply print the face
      if (cut[$2] != 1 && cut[$3] != 1 && cut[$4] != 1 ) {
        print 3, fixedind[$2], fixedind[$3], fixedind[$4]
      }
    }

    # We can make new vertices and new faces based on the cut faces.


    # END {
    #   # print "TABLE" > "/dev/stderr"
    #   for(i=0;i<numverts;i++) {
    #     print i, fixedind[i] > "/dev/stderr"
    #   }
    # }
    ' ./cutvertices.txt ./tris.txt > tris_cleaned.txt

    mv vertices_cleaned.txt vertices_proj.txt
    mv tris_cleaned.txt tris.txt

  fi

  # PLY header needs an exact count of vertices and faces
  numverts=$(wc -l < vertices_proj.txt | gawk '{print $1}')
  numfaces=$(wc -l < ./tris.txt | gawk '{print $1}')

  outputfile=$(basename $1 ".ts").ply

cat <<-EOF > ${outputfile}
ply
format ascii 1.0
element vertex ${numverts}
property float x
property float y
property float z
element face ${numfaces}
property list uchar int vertex_indices
end_header
EOF

  cat vertices_proj.txt >> ${outputfile}
  cat tris.txt >> ${outputfile}

  # Convert PLY to OBJ

  # We need at least three vertices to make a triangle
  if [[ $(echo "${numverts} > 2" | bc) -eq 1 ]]; then

    if [[ ! -s ${outputobj} ]]; then
      echo "mtllib materials.mtl" > ${outputobj}
    fi
    if [[ ! -s ${outputobj_line} ]]; then
      echo "mtllib materials.mtl" > ${outputobj_line}
    fi

    echo "o " $(basename $1 ".ts") >> ${outputobj}
    echo "usemtl SCECFaultSurface" >> ${outputobj}

    echo "o " $(basename $1 ".ts") >> ${outputobj_line}
    echo "usemtl SCECFaultLine" >> ${outputobj_line}

    gawk < vertices_proj.txt -v rgb=${colors[$faultnum]} '
    {
      split(rgb,r,"/")
      print "v", $1, $2, $3, r[1], r[2], r[3]
    }' >> ${outputobj}

    # Make an OBJ file with the mesh lines as well
    gawk < vertices_proj.txt '
    {
      print "v", $1, $2, $3
    }' >> ${outputobj_line}

    gawk < tris.txt -v totalverts=${totalverts} '
    {
      tri1=$2+1+totalverts
      tri2=$3+1+totalverts
      tri3=$4+1+totalverts
      print "f", tri1 "/" tri1 "/" tri1, tri2 "/" tri2 "/" tri2, tri3 "/" tri3 "/" tri3
    }' >> ${outputobj}

    gawk < tris.txt -v totalverts=${totalverts} '
    {
      tri1=$2+1+totalverts
      tri2=$3+1+totalverts
      tri3=$4+1+totalverts
      if (line[tri1][tri2] != 1) {
        print "l", tri1, tri2
        line[tri1][tri2]=1
      }
      if (line[tri2][tri3] != 1) {
        print "l", tri2, tri3
        line[tri2][tri3]=1
      }
      if (line[tri3][tri1] != 1) {
        print "l", tri3, tri1
        line[tri3][tri1]=1
      }
    }' >> ${outputobj_line}

    totalverts=$(echo "$totalverts + $numverts" | bc)
  fi

  shift

done

cat <<-EOF > SCECFaultSurface.mtl
newmtl SCECFaultSurface
Ka 1.000000 1.000000 1.000000
Kd 1.000000 1.000000 1.000000
Ks 0.000011 0.000000 0.000000
Tr 1.0
illum 1
Ns 0.000000
EOF

cat <<-EOF > SCECFaultLine.mtl
newmtl SCECFaultLine
Ka 1.000000 1.000000 1.000000
Kd 1.000000 1.000000 1.000000
Ks 0.000008 0.000000 0.000000
Tr 1.0
illum 1
Ns 0.000000
EOF

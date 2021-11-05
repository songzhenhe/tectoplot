# sample_slab2.sh

# Sampling Slab2 grids runs into problems when the region is 360° shifted from
# the Slab2 grid file. GMT grdtrack does not manage to do the sampling in this
# case, resulting in NaN for all points.

# This issue plagues sampling at earthquake locations (-cslab2) and also -vc

# Our approach is to resample with points / points + 360 / points - 360 in order
# and accept the file when any non-NaN sample is returned.

function sample_slab2_grid() {

  grid_file=$1
  points_file=$2
  output_file=$3

  # Try to sample the grid

  gmt grdtrack $points_file -G$grid_file ${VERBOSE} -Z -N > $output_file

  # Check whether we just got NaNs

  shouldredo=$(gawk < $output_file '
    BEGIN {
      redo=1
    }
    ($(NF) != "NaN") {
      redo=0
      exit
    }
    END {
      print redo
    }
  ')

  if [[ $shouldredo -eq 1 ]]; then
    gawk < $points_file '
    {
      $1=$1+360
      print $0
    }' > newfile.txt

    gmt grdtrack newfile.txt -G$grid_file ${VERBOSE} -Z -N > $output_file

    shouldredo=$(gawk < $output_file '
      BEGIN {
        redo=1
      }
      ($(NF) != "NaN") {
        redo=0
        exit
      }
      END {
        print redo
      }
    ')

    if [[ $shouldredo -eq 1 ]]; then
      gawk < $points_file '
      {
        $1=$1-360
        print $0
      }' > newfile.txt

      gmt grdtrack newfile.txt -G$grid_file ${VERBOSE} -Z -N > $output_file

      shouldredo=$(gawk < $output_file '
        BEGIN {
          redo=1
        }
        ($(NF) != "NaN") {
          redo=0
          exit
        }
        END {
          print redo
        }
      ')

      if [[ $shouldredo -eq 1 ]]; then
        echo "Warning: Could not sample Slab2 with input points... all NaN in output."
      fi
    fi
  fi

}

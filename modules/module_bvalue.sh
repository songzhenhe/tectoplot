
TECTOPLOT_MODULES+=("bvalue")

# EXPECTS THESE VARIABLES TO BE SET
# zcclusterflag : flag to plot colors by cluster ID
# SEIS_CPT      : CPT for plotting seismicity

function tectoplot_defaults_bvalue() {
  BVALUE_MC=4       # Default Mc value for b-value calculation
  BVALUE_USEMCFLAG=0   # If 1, use default or specified Mc value
}

function tectoplot_args_bvalue()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -bvalue)
if [[ $USAGEFLAG -eq 1 ]]; then
cat <<-EOF
-bvalue:     plot cumulative frequency number distribution of seismicity
-bvalue [[Mc]]

  Uses only seismicity - "b" careful if using CMTs with culling!

Example: None
--------------------------------------------------------------------------------
EOF
fi

    shift

    if arg_is_float "${1}"; then
      BVALUE_USEMC=1
      BVALUE_MC=${1}
      shift
      ((tectoplot_module_shift++))
    fi

    tectoplot_module_caught=1
    ;;
  esac
}

function tectoplot_post_bvalue() {
  if [[ -s ${F_SEIS}eqs.txt ]]; then


      mkdir "module_stereonet"

      # Non-cumulative data
      # Bin centers using -F

      gmt pshistogram ${F_SEIS}eqs.txt -F -IO -i3 -T0.2 > ./module_stereonet/histdata.txt

      # Calculate cumulative histogram and year span of data per bin.
      # gawk < histdata.txt '
      #   BEGIN {
      #     cumsum=0
      #   }
      #   {
      #     bin[NR]=$1
      #     val[NR]=$2
      #   }
      #   END {
      #     for(i=1; i<=NR; ++i) {
      #       print bin[i], cumval[i]
      #     }
      #     print cumval[1]*10 > "cumsum_max.txt"
      #   }' > cum_histdata.txt

      # Outputs bin center value, bin count, reverse cumulative bin count, time span of data [years]

        gawk '
        function floor(x) { return (x==int(x))?x:sprintf("%.f", x-0.5)}
        BEGIN {
          markedbins=0
          eqindex=1
        }

        # Read in the bin centerpoints
        (NR==FNR) {
            bin[NR]=$1
            val[NR]=$2
            maxtime[NR]=-9999999999
            mintime[NR]=9999999999
        }
        # Read in the earthquakes
        (NR!=FNR) {
          if (markedbins==0) {
            numbins=NR-1
            binhalfwidth=(bin[2]-bin[1])/2
            # Data are in interval [l,u)
            l=bin[1]-binhalfwidth
            u=bin[NR-1]+binhalfwidth
            # print "l=", l, "u=", u

            for(i=numbins;i>=1; --i) {
              cumsum+=val[i]
              cumval[i]=cumsum
            }
            print cumval[1]*10 > "cumsum_max.txt"

            markedbins=1


          }
          # Calculate the bin number of the event
          binnum[eqindex]=floor(numbins*($4-l)/(u-l))
          maxtime[binnum[eqindex]]=($7>maxtime[binnum[eqindex]])?$7:maxtime[binnum[eqindex]]
          mintime[binnum[eqindex]]=($7<mintime[binnum[eqindex]])?$7:mintime[binnum[eqindex]]
          eqindex++
        }
        END {
          for(i=1;i<=numbins;++i) {
            if (mintime[i]==9999999999 || maxtime[i]==-9999999999) {
              mintime[i]=0
              maxtime[i]=0
            }
            print bin[i], val[i], cumval[i], (maxtime[i]-mintime[i])/(60*60*24*365.25)
          }

        }
        ' ./module_stereonet/histdata.txt ${F_SEIS}eqs.txt > ./module_stereonet/histcalcs.txt

      maxcumval=$(cat cumsum_max.txt)
      rm -f cumsum_max.txt

      # Aki-Bender algorithm for b value and uncertainty
      b_aki=($(gawk < ./module_stereonet/histcalcs.txt -v usemc=${BVALUE_USEMC} -v mcval=${BVALUE_MC} '
      function floor(x) { return (x==int(x))?x:sprintf("%.f", x-0.5)}
      {
          fmag[NR]=$1
          n[NR]=$2
          cumn[NR]=$3

          # max_n is the maximum number of earthquakes in a bin
          if ($2>max_n) {
            max_n=$2
            mc_index=NR
          }
      }
      END {
          numbins=NR
          dmag=fmag[2]-fmag[1]

          if (usemc==1) {
            binhalfwidth=(fmag[2]-fmag[1])/2
            l=fmag[1]-binhalfwidth
            u=fmag[NR-1]+binhalfwidth
            mc_index=floor(numbins*(mcval-l)/(u-l))
          } else {
            if (mc_index==NR) {
              print "No data" > "/dev/stderr"
              exit
            }
          }

          # m_min is the magnitude of Mc
          m_min = fmag[mc_index]

          for(i=mc_index; i<= NR; i++) {
            neq+=cumn[i]
            m_ave+=fmag[i]*cumn[i]
            if (n[i]>0) {
              max_mag_index=i
            }
          }

          # m_ave is the average magnitude
          m_ave/=neq

          if (neq <= 1) {
            print "Not enough data:", neq > "/dev/stderr"
            exit
          }

          bval = 1/log(10) * 1/(m_ave - m_min + (dmag / 2.))

          # This is the Bender estimate of sigma_bval
          for(i=mc_index; i<=NR; i++) {
            sigma_bval += (cumn[i]*((mval[i]-m_ave) ^ 2)) / (neq * (neq-1))
          }
          sigma_bval=log(10) * (bval^2) * sqrt(sigma_bval)
          print m_min, cumn[mc_index], fmag[max_mag_index], bval, sigma_bval
      }'))


      gmt psxy ./module_stereonet/histcalcs.txt -i0,1 -Ss0.1i -R1.5/10.0/1/${maxcumval} -JX6i/2il -Gblack -BSWtr -Bpaf -Bx+l"Magnitude" -By+l"Binned frequency" -K > ./module_stereonet/bvalue.ps
      gmt psxy ./module_stereonet/histcalcs.txt -i0,2 -Ss0.1i -W1p,red -R1.5/10.0/1/${maxcumval} -JX6i/2il -O -K >> ./module_stereonet/bvalue.ps

      echo ">" > ./module_stereonet/mc_line.txt
      echo "${b_aki[0]} 1" >> ./module_stereonet/mc_line.txt
      echo "${b_aki[0]} ${maxcumval}" >> ./module_stereonet/mc_line.txt
      gmt psxy ./module_stereonet/mc_line.txt -W1p,black,- -R1.5/10.0/1/${maxcumval} -JX6i/2il -O -K >> ./module_stereonet/bvalue.ps

      # Mc NMc Mmax b sigmab
      echo "${b_aki[0]} ${b_aki[1]} ${b_aki[2]} ${b_aki[3]} ${b_aki[4]}" | gawk '{
        Mc=$1
        Nmc=$2
        mmax=$3
        b=$4
        sigmab=$5

        a=log(Nmc)/log(10)+b*Mc
        mmax=a/b
        nmax=10^(a-b*mmax)

        print "> -W1p,green"
        print $1, $2
        print mmax, nmax

        a=log(Nmc)/log(10)+(b+sigmab)*Mc
        mmax=a/b
        nmax=10^(a-b*mmax)

        print "> -W0.4p,green"
        print $1, $2
        print mmax, nmax

        a=log(Nmc)/log(10)+(b-sigmab)*Mc
        mmax=a/b
        nmax=10^(a-b*mmax)

        print "> -W0.4p,green"
        print $1, $2
        print mmax, nmax

        print a > "a_value.txt"

      }' > ./module_stereonet/b_line.txt

      gmt psxy ./module_stereonet/b_line.txt -R1.5/10.0/1/${maxcumval} -JX6i/2il -O -K >> ./module_stereonet/bvalue.ps
      A_VAL=$(cat a_value.txt)
      rm -f a_value.txt

      printf "Mc=%0.2f, a=%0.2f, b=%0.2f+-%0.2f" ${b_aki[0]} ${A_VAL} ${b_aki[3]} ${b_aki[4]} | gmt pstext -D-4p/-4p -R -J -F+cTR -O >> ./module_stereonet/bvalue.ps

      # gmt psxy histcalcs.txt -i0,3 -St0.1i -Ggreen -R -J -O >> bvalue.ps

      gmt psconvert ./module_stereonet/bvalue.ps -Tf -A+m0.5i
  fi
}

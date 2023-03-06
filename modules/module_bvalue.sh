
TECTOPLOT_MODULES+=("bvalue")

# UPDATED
# NEW OPT

function tectoplot_defaults_bvalue() {
  m_bvalue_usemc=0
}

function tectoplot_args_bvalue()  {
  # The following line is required for all modules
  tectoplot_module_caught=0
  tectoplot_module_shift=0

  # The following case statement mimics the argument processing for tectoplot
  case "${1}" in

  -bvalue)
  tectoplot_get_opts_inline '
des -bvalue Plot cumulative frequency number distribution of seismicity
opn mc m_bvalue_mc float 4.0
  magnitude of completeness for earthquake catalog
mes mc is the magnitude of completeness of the input catalog, which is set to be
mes the earthquake bin with highest event count, if not specified directly.
mes Note: -bvalue plots only seismicity; be careful if using CMTs with culling!
exa tectoplot -z -bvalue mc 5
' "${@}" || return

    if [[ $(echo "${m_bvalue_mc} != 4.0" | bc -l) -eq 1 ]]; then
      m_bvalue_usemc=1
    fi
    ;;
  esac
}

function tectoplot_post_bvalue() {

  if [[ -s ${F_SEIS}eqs.txt ]]; then

    mkdir "module_bvalue"

    # Non-cumulative data
    # Bin centers using -F

    gmt pshistogram ${F_SEIS}eqs.txt -F -IO -i3 -T0.2 > ./module_bvalue/histdata.txt

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
      ' ./module_bvalue/histdata.txt ${F_SEIS}eqs.txt > ./module_bvalue/histcalcs.txt

    maxcumval=$(cat cumsum_max.txt)
    rm -f cumsum_max.txt

    # Aki-Bender algorithm for b value and uncertainty
    b_aki=($(gawk < ./module_bvalue/histcalcs.txt -v usemc=${m_bvalue_usemc} -v mcval=${m_bvalue_mc} '
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


    gmt psxy ./module_bvalue/histcalcs.txt -i0,1 -Ss0.1i -R1.5/10.0/1/${maxcumval} -JX6i/2il -Gblack -BSWtr -Bpaf -Bx+l"Magnitude" -By+l"Binned frequency" -K > ./module_bvalue/bvalue.ps
    gmt psxy ./module_bvalue/histcalcs.txt -i0,2 -Ss0.1i -W1p,red -R1.5/10.0/1/${maxcumval} -JX6i/2il -O -K >> ./module_bvalue/bvalue.ps

    echo ">" > ./module_bvalue/mc_line.txt
    echo "${b_aki[0]} 1" >> ./module_bvalue/mc_line.txt
    echo "${b_aki[0]} ${maxcumval}" >> ./module_bvalue/mc_line.txt
    gmt psxy ./module_bvalue/mc_line.txt -W1p,black,- -R1.5/10.0/1/${maxcumval} -JX6i/2il -O -K >> ./module_bvalue/bvalue.ps

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

    }' > ./module_bvalue/b_line.txt

    gmt psxy ./module_bvalue/b_line.txt -R1.5/10.0/1/${maxcumval} -JX6i/2il -O -K >> ./module_bvalue/bvalue.ps
    A_VAL=$(cat a_value.txt)
    rm -f a_value.txt

    printf "Mc=%0.2f, a=%0.2f, b=%0.2f+-%0.2f" ${b_aki[0]} ${A_VAL} ${b_aki[3]} ${b_aki[4]} | gmt pstext -D-4p/-4p -R -J -F+cTR -O >> ./module_bvalue/bvalue.ps

    # gmt psxy histcalcs.txt -i0,3 -St0.1i -Ggreen -R -J -O >> bvalue.ps

    gmt psconvert ./module_bvalue/bvalue.ps -Tf -A+m0.5i
  fi
}

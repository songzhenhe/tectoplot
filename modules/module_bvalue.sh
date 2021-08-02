
TECTOPLOT_MODULES+=("bvalue")

# EXPECTS THESE VARIABLES TO BE SET
# zcclusterflag : flag to plot colors by cluster ID
# SEIS_CPT      : CPT for plotting seismicity

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
-bvalue

  Uses only seismicity - "b" careful if using CMTs with culling active!

Example: None
--------------------------------------------------------------------------------
EOF
fi
    tectoplot_module_shift=1
    tectoplot_module_caught=1
    ;;
  esac
}

# The following functions are not necessary for this module

# function tectoplot_calculate_stereonet()  {
#   echo "Doing stereonet calculations"
# }
#
# function tectoplot_plot_stereonet() {
#   echo "Doing stereonet plot"
# }
#
# function tectoplot_legend_stereonet() {
#   echo "Doing stereonet legend"
# }

function tectoplot_post_bvalue() {
  if [[ -s ${F_SEIS}eqs.txt ]]; then

      # Non-cumulative data
      # Bin centers using -F

      gmt pshistogram ${F_SEIS}eqs.txt -F -IO -i3 -T0.2 > histdata.txt

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
        ' histdata.txt ${F_SEIS}eqs.txt > histcalcs.txt

      maxcumval=$(cat cumsum_max.txt)

      # Aki-Bender algorithm for b value and uncertainty
      b_aki=($(gawk < histcalcs.txt '
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
          # id0 = mval >= m_c

          # print "max_n=", max_n

          if (mc_index==NR) {
            print "No data" > "/dev/stderr"
            exit
          }
        # else {
        #     print "mc_index=" mc_index, "mag is", fmag[mc_index]
        #   }

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
            sigma_bval += (cumn[i]*((mval[i]-m_ave) ^ 2)) / (neq * (neq -1))
          }
          sigma_bval=log(10) * (bval^2) * sqrt(sigma_bval)
          print m_min, cumn[mc_index], fmag[max_mag_index], bval, sigma_bval
      }'))


      gmt psxy histcalcs.txt -i0,1 -Ss0.1i -R1.5/10.0/1/${maxcumval} -JX6i/2il -Gblack -BSWtr -Bpaf -Bx+l"Magnitude" -By+l"Binned frequency" -K > bvalue.ps
      gmt psxy histcalcs.txt -i0,2 -Ss0.1i -W1p,red -R1.5/10.0/1/${maxcumval} -JX6i/2il -O -K >> bvalue.ps

      echo ">" > mc_line.txt
      echo "${b_aki[0]} 1" >> mc_line.txt
      echo "${b_aki[0]} ${maxcumval}" >> mc_line.txt
      gmt psxy mc_line.txt -W1p,black,- -R1.5/10.0/1/${maxcumval} -JX6i/2il -O -K >> bvalue.ps

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

      }' > b_line.txt

      gmt psxy b_line.txt -R1.5/10.0/1/${maxcumval} -JX6i/2il -O -K >> bvalue.ps
      A_VAL=$(cat a_value.txt)

      printf "Mc=%0.2f, a=%0.2f, b=%0.2f+-%0.2f" ${b_aki[0]} ${A_VAL} ${b_aki[3]} ${b_aki[4]} | gmt pstext -D-4p/-4p -R -J -F+cTR -O >> bvalue.ps

      # gmt psxy histcalcs.txt -i0,3 -St0.1i -Ggreen -R -J -O >> bvalue.ps


      gmt psconvert bvalue.ps -Tf -A+m0.5i
  fi
}

  # for(i=1;i<=numbins; i++) {
  #
  #   ### Scale X coordinate (magnitude) from linear to logarithmic using current beta value
  #   #              beta_exp = np.exp(-beta * fmag)
  #   beta_exp[i]=exp(-beta * fmag[i])
  #   # print "beta_exp[" i "]=" beta_exp[i]
  #
  #   ###
  #   #              tjexp = tper * beta_exp
  #   tjexp[i]=tper[i]*beta_exp[i]
  #   # print "tjexp[" i "]=" tjexp[i]
  #
  #   ### tmexp is scaled Y value times not-scaled X value???
  #   #              tmexp = tjexp * fmag
  #   tmexp[i]=tjexp[i]*fmag[i]
  #   # print "tmexp[" i "]=" tmexp[i]
  #
  # }

###          snm = np.sum(nobs * fmag)
# Assuming that nobs*fmag is element-wise multiplication (e.g. this is the dot product)
# snm+=($2*$1)
#           nkount = np.sum(nobs)
# nkount+=$2
# ### sumexp is the sum of the scaled X values
#
# # sumexp = np.sum(beta_exp)
# sumexp=sumarray(beta_exp, numbins)
# print "sumexp=" sumexp
#
# ### stmex is the sum of the scaled Y values
# # stmex = np.sum(tmexp)
# stmex=sumarray(tmexp, numbins)
# print "stmex=" stmex
#
# #sumtex = np.sum(tjexp)
# sumtex=sumarray(tjexp, numbins)
#
# # stm2x = np.sum(fmag * tmexp)
# for(i=1; i<=numbins; i++) {
#   stm2x+=(fmag[i]*tmexp[i])
# }
#
#
# # print "stm2x=" stm2x
#
#
# dldb = stmex / sumtex
#
# # if np.isnan(stmex) or np.isnan(sumtex):
# #     warnings.warn("NaN occurs in Weichert iteration")
# #     return np.nan, np.nan, np.nan, np.nan, np.nan, np.nan
# #     #raise ValueError("NaN occers in Weichert iteration")
#
# d2ldb2 = nkount * ((dldb * dldb) - (stm2x / sumtex))
#
# print "d2ldb2=" d2ldb2
#
# dldb = (dldb * nkount) - snm
#
# betl = beta
#
# beta = beta - (dldb/d2ldb2)
# sigbeta = sqrt(-1/d2ldb2)
#
#
# print "abs(beta-betl)=" abs(beta-betl)
#
# if (abs(beta - betl) <= itstab) {
#     # Iteration has reached convergence
#     bval = beta / log(10)
#     sigb = sigbeta / log(10)
#     fngtm0 = nkount * (sumexp / sumtex)
#     fn0 = fngtm0 * exp((beta) * (fmag[1] - (d_m / 2.0)))
#     stdfn0 = fn0 / sqrt(nkount)
#     a_m = fngtm0 *exp((-beta) * (mrate - (fmag[1] - (d_m / 2.0))))
#     siga_m = a_m / sqrt(nkount)
#     itbreak = 1
# } else {
#     iteration += 1
#     if (iteration > maxiter) {
#         print "Maximum Number of Iterations reached" > "/dev/null"
#         print "NaN NaN NaN NaN NaN NaN"
#     }
# }


# def weichert_algorithm(self, tper, fmag, nobs, mrate=0.0, bval=1.0,
#                            itstab=1E-5, maxiter=1000):
#         """
#         Weichert algorithm
#
#         :param tper: length of observation period corresponding to magnitude
#         :type tper: numpy.ndarray (float)
#         = years spanned by events in bin, 0 for 1 event?
#         :param fmag: central magnitude
#         :type fmag: numpy.ndarray (float)
#         :param nobs: number of events in magnitude increment
#         :type nobs: numpy.ndarray (int)
#         :keyword mrate: reference magnitude
#         :type mrate: float
#         :keyword bval: initial value for b-value
#         :type beta: float
#         :keyword itstab: stabilisation tolerance
#         :type itstab: float
#         :keyword maxiter: Maximum number of iterations
#         :type maxiter: Int
#         :returns: b-value, sigma_b, a-value, sigma_a
#         :rtype: float
#         """
#         beta = bval * np.log(10.)
        # d_m = fmag[1] - fmag[0]
        # itbreak = 0
        # snm = np.sum(nobs * fmag)
        # nkount = np.sum(nobs)
        # iteration = 1
        # while (itbreak != 1):
        #     beta_exp = np.exp(-beta * fmag)
        #     tjexp = tper * beta_exp
        #     tmexp = tjexp * fmag
        #     sumexp = np.sum(beta_exp)
        #     stmex = np.sum(tmexp)
        #     sumtex = np.sum(tjexp)
        #     stm2x = np.sum(fmag * tmexp)
        #     dldb = stmex / sumtex
        #     if np.isnan(stmex) or np.isnan(sumtex):
        #         warnings.warn('NaN occurs in Weichert iteration')
        #         return np.nan, np.nan, np.nan, np.nan, np.nan, np.nan
        #         #raise ValueError('NaN occers in Weichert iteration')
        #
        #     d2ldb2 = nkount * ((dldb ** 2.0) - (stm2x / sumtex))
        #     dldb = (dldb * nkount) - snm
        #     betl = np.copy(beta)
        #     beta = beta - (dldb / d2ldb2)
        #     sigbeta = np.sqrt(-1. / d2ldb2)
        #
        #     if np.abs(beta - betl) <= itstab:
        #         # Iteration has reached convergence
        #         bval = beta / np.log(10.0)
        #         sigb = sigbeta / np.log(10.)
        #         fngtm0 = nkount * (sumexp / sumtex)
        #         fn0 = fngtm0 * np.exp((beta) * (fmag[0] - (d_m / 2.0)))
        #         stdfn0 = fn0 / np.sqrt(nkount)
        #         a_m = fngtm0 * np.exp((-beta) * (mrate -
        #                                          (fmag[0] - (d_m / 2.0))))
        #         siga_m = a_m / np.sqrt(nkount)
        #         itbreak = 1
        #     else:
        #         iteration += 1
        #         if iteration > maxiter:
        #             warnings.warn('Maximum Number of Iterations reached')
        #             return np.nan, np.nan, np.nan, np.nan, np.nan, np.nan
        # return bval, sigb, a_m, siga_m, fn0, stdfn0


        #       # Weichert algorithm
        #       gawk < histcalcs.txt -v mrate=0 -v bval=1 -v istab=0.0001 -v maxiter=1000 '
        #       function sumarray(a, len,        i, sumval) { for(i=1; i<=len; i++) { sumval+=a[i]}; return sumval }
        #       function abs(v) { return (v>0)?v:-v }
        #       {
        #           fmag[NR]=$1
        #           n[NR]=$2
        #           it[NR]=$3
        #           maxtime=($3>maxtime)?$3:maxtime
        #       }
        #       END {
        #           numbins=NR
        #
        #           for(i=1;i<=NR;++i) {
        #             it[i]=it[i]/maxtime
        #           }
        #
        #
        #           low=16
        #           high=35
        #           beta=bval*log(10)
        #           binwidth=fmag[2]-fmag[1]
        #           itbreak=0
        #           iteration=1
        #
        #           print "binwidth=", binwidth
        #           print "beta=", beta
        #           beta=1.5
        #           itcount=0
        #           while (itbreak != 1) {
        #             itcount++
        #
        #             snm=0
        #             nkount=0
        #             stmex=0
        #             sumtex=0
        #             stm2x=0
        #             sumexp=0
        # print "beta=", beta
        #             for(k=low; k<= high; k++) {
        #               snm=snm+n[k]*fmag[k]
        #               nkount=nkount+n[k]
        #               tjexp=it[k]*exp(-beta*fmag[k])
        #               tmexp=tjexp*fmag[k]
        #               sumexp=sumexp+exp(-beta*fmag[k])
        #               stmex=stmex+tmexp
        #               sumtex=sumtex+tjexp
        #               stm2x=stm2x+fmag[k]*tmexp
        #               print "...k=", k, "nkount", nkount, "dldb", dldb, "stm2x", stm2x, "sumtex", sumtex
        #
        #             }
        #             print "danger"
        #             dldb=stmex/sumtex
        #             print"out"
        #             print "danger2"
        #             print "nkount", nkount, "dldb", dldb, "stm2x", stm2x, "sumtex", sumtex
        #             d2ldb2=nkount*((dldb*dldb)-stm2x/sumtex)
        #             print "dldb", dldb, "nkount", nkount, "- snm: - " snm
        #
        #             dldb=(dldb*nkount)-snm
        #             print "dldb=", dldb
        #             print "d2ldb2=", d2ldb2
        #
        #             betl=beta
        #             print "danger3"
        #             beta=beta-dldb/d2ldb2
        #             print "danger3out"
        #             stdv=sqrt(-1/d2ldb2)
        #             if (abs(beta-betl) <= istab || itcount > 1000) {
        #               itbreak=1
        #             }
        #             print "beta=" beta, "stdv=", stdv
        #           }
        #           b=beta/log(10)
        #           stdb=stdv/log(10)
        #           fngtmo=nkount*sumexp/sumtex
        #           fn0=fngmto*exp(beta*(fmag[low]-binwidth/2))
        #           flgn0=log(fn0)/log(10)
        #           fn5=fngmt*exp(-beta*(5-(fmag[low]-bindwidth/2)))
        #           stdfn5=fn5/sqrt(nkount)
        #
        #           print beta, b, stdb, fn5, stdfn5, fn0, stdfn0
        #       }'

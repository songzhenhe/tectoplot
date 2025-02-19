# tectoplot
# awkscripts/tectoplot_functions.awk
# Copyright (c) 2021 Kyle Bradley, all rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors
#    may be used to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


# Include in scripts using gawk:
# AWKPATH="/directory/containing/scripts"
# @include "tectoplot_functions.awk"

# Math functions

function sqr(x)        { return x*x                     }
function max(x,y)      { return (x>y)?x:y               }
function min(x,y)      { return (x<y)?x:y               }
function getpi()       { return atan2(0,-1)             }
function abs(v)        { return v < 0 ? -v : v          }
function tan(x)        { return sin(x)/cos(x)           }
function atan(x)       { return atan2(x,1)              }
function asin(x)       { return atan2(x, ssqrt(1-x*x))  }
function acos(x)       { return atan2(ssqrt(1-x*x), x)  }
function rad2deg(rad)  { return (180 / getpi()) * rad   }
function deg2rad(deg)  { return (getpi() / 180) * deg   }
function hypot(x,y)    { return ssqrt(x*x+y*y)          }
function ssqrt(x)      { return (x<0)?0:sqrt(x)         }
function ddiff(u)      { return u > 180 ? 360 - u : u   }
function ceil(x)       { return int(x)+(x>int(x))       }
function floor(x)      { return ceil(x)-1               }
function sinsq(x)      { return sin(x)*sin(x)           }
function cossq(x)      { return cos(x)*cos(x)           }
function d_atan2d(y,x) { return (x == 0.0 && y == 0.0) ? 0.0 : rad2deg(atan2(y,x)) }
function square(x)     { return x*x }

# Rescale a value val that comes from data with range [xmin, xmax] into range [ymin, ymax]

function rescale_value(val, xmin, xmax, ymin, ymax) {
  return (val-xmin)/(xmax-xmin)*(ymax-ymin)+ymin
}

# Trim whitespace at beginning of string
function ltrim(s)       { sub(/^[ \t\r\n]+/, "", s); return s }

# Trim whitespace at end of string
function rtrim(s)       { sub(/[ \t\r\n]+$/, "", s); return s }

# Trim whitespace around string
function trim(s)        { return rtrim(ltrim(s)); }

# Various 3-vector math operations

# The normalized cross product
# Set global variables w_cross_1, w_cross_2, w_cross_3 as the resultant of u cross v, normalized

function v_cross(u1,u2,u3,v1,v2,v3) {
  w_cross_1 = u2*v3 - u3*v2
  w_cross_2 = u3*v1 - u1*v3
  w_cross_3 = u1*v2 - u2*v1
  v_cross_l = ssqrt(w_cross_1*w_cross_1+w_cross_2*w_cross_2+w_cross_3*w_cross_3)
  w_cross_1 = w_cross_1 / v_cross_l
  w_cross_2 = w_cross_2 / v_cross_l
  w_cross_3 = w_cross_3 / v_cross_l
}

# The non-normalized (regular) cross product
# Set global variables w_cross_1, w_cross_2, w_cross_3 as the resultant of u cross v, not normalized

function v_cross_nonorm(u1,u2,u3,v1,v2,v3) {
  w_cross_1 = u2*v3 - u3*v2
  w_cross_2 = u3*v1 - u1*v3
  w_cross_3 = u1*v2 - u2*v1
}

# Set global variables w_sub_1, w_sub_2, and w_sub_3 as the resultant of u - v
function v_subtract(u1,u2,u3,v1,v2,v3) {
  w_sub_1 = u1-v1
  w_sub_2 = u2-v2
  w_sub_3 = u3-v3
}

# Dot product
# Set global variables w_dot

function v_dot(u1,u2,u3,v1,v2,v3) {
  w_dot = u1*v1+u2*v2+u3*v3
}


# moment_tensor_diagonalize_ntp(Mxx,Myy,Mzz,Mxy,Mxz,Myz)
# This function takes the 6 components of a focal mechanism and calculates its
# eigenvalues, eigenvectors, and azimuth and plunge of the principal axes.

# Upon successful execution, these global variables will be set and return 0:

# d_E00, d_E01, d_E02 : Eigenvector components of eigenvalue 0   (largest)
# d_E10, d_E11, d_E12 : Eigenvector components of eigenvalue 1   (intermediate)
# d_E20, d_E21, d_E22 : Eigenvector components of eigenvalue 2   (smallest)
# d_EV0, d_EV1, d_EV2 : Eigenvalues (0=largest, 2=smallest)
# d_AZ0, d_AZ1, d_AZ2 : Azimuths of eigenvectors
# d_PL0, d_PL1, d_PL2 : Plunges of eigenvectors

# Failure is indicated by all above values being 0 and return code being -1

# Diagonalization code is based on the following code:
# Numerical diagonalization of 3x3 matrcies
# Copyright (C) 2006  Joachim Kopp (GPL 2.1)

function moment_tensor_diagonalize_ntp(Mxx,Myy,Mzz,Mxy,Mxz,Myz,     i) {

  # Initialize the relevant part of the A matrix

  A[0][0]=Mxx;
  A[1][1]=Myy;
  A[2][2]=Mzz;
  A[0][1]=Mxy;
  A[0][2]=Mxz;
  A[1][2]=Myz;

  # Initialize Q to the identity matrix
  for (i=0; i < 3; i++)
  {
    Q[i][i] = 1.0;
    for (j=0; j < i; j++) {
      Q[i][j] = Q[j][i] = 0.0;
    }
  }

  # Initialize w to diag(A)
  for (i=0; i < 3; i++) {
    w[i] = A[i][i];
  }

  # Calculate SQR(tr(A))
  sd = 0.0;
  for (i=0; i < 3; i++) {
    sd += abs(w[i]);
  }
  sd = sd*sd;
  success=0;

  # Main iteration loop
  for (nIter=0; nIter < 50; nIter++)
  {
    # Test for convergence
    so = 0.0;
    for (p=0; p < 3; p++) {
      for (q=p+1; q < 3; q++) {
        so += abs(A[p][q]);
      }
    }
    if (so == 0.0) {
      success=1;
      break;   # Break the main loop
    }
    if (nIter < 4) {
      thresh = 0.2 * so / 9;
    } else {
      thresh = 0.0;
    }

    # Do sweep
    for (p=0; p < 3; p++)
    {
      for (q=p+1; q < 3; q++)
      {
        g = 100.0 * abs(A[p][q]);
        if ((nIter > 4)  &&  ((abs(w[p]) + g) == abs(w[p])) &&  ((abs(w[q]) + g) == abs(w[q])))
        {
          A[p][q] = 0.0;
        } else if (abs(A[p][q]) > thresh) {
          # Calculate Jacobi transformation
          h = w[q] - w[p];
          if ((abs(h) + g) == abs(h))
          {
            t = A[p][q] / h;
          }
          else
          {
            theta = 0.5 * h / A[p][q];
            if (theta < 0.0) {
              t = -1.0 / (ssqrt(1.0 + theta*theta) - theta);
            } else {
              t = 1.0 / (ssqrt(1.0 + theta*theta) + theta);
            }
          }
          c = 1.0/ssqrt(1.0 + t*t);
          s = t * c;
          z = t * A[p][q];

          # Apply Jacobi transformation
          A[p][q] = 0.0;
          w[p] -= z;
          w[q] += z;
          for (r=0; r < p; r++)
          {
            t = A[r][p];
            A[r][p] = c*t - s*A[r][q];
            A[r][q] = s*t + c*A[r][q];
          }
          for (r=p+1; r < q; r++)
          {
            t = A[p][r];
            A[p][r] = c*t - s*A[r][q];
            A[r][q] = s*t + c*A[r][q];
          }
          for (r=q+1; r < 3; r++)
          {
            t = A[p][r];
            A[p][r] = c*t - s*A[q][r];
            A[q][r] = s*t + c*A[q][r];
          }

          # Update eigenvectors
          for (r=0; r < 3; r++)
          {
            t = Q[r][p];
            Q[r][p] = c*t - s*Q[r][q];
            Q[r][q] = s*t + c*Q[r][q];
          }
        }
      }
    }
  }

  if (success==1) {

    # Q contains eigenvectors
    # w contains eigenvalues

    maxeig=max(max(w[0], w[1]), w[2]);
    mineig=min(min(w[0], w[1]), w[2]);

    for(i=0; i<3; i++) {
      if (w[i]==maxeig) {
        d_EV0=w[i];
        d_E00=Q[0][i];
        d_E01=Q[1][i];
        d_E02=Q[2][i];
      } else if (w[i]==mineig) {
        d_EV2=w[i];
        d_E20=Q[0][i];
        d_E21=Q[1][i];
        d_E22=Q[2][i];
      } else {
        d_EV1=w[i];
        d_E10=Q[0][i];
        d_E11=Q[1][i];
        d_E12=Q[2][i];
      }
    }

    # d_AZ0, d_AZ1, d_AZ2 : Azimuths of eigenvectors
    # d_PL0, d_PL1, d_PL2 : Plunges of eigenvectors

    d_PL0 = rad2deg(asin(-d_E00));
    d_AZ0 = rad2deg(atan2(d_E02,-d_E01));
    d_PL1 = rad2deg(asin(-d_E10));

    d_AZ1 = rad2deg(atan2(d_E12,-d_E11));
    d_PL2 = rad2deg(asin(-d_E20));
    d_AZ2 = rad2deg(atan2(d_E22, -d_E21));

    // T axis
    if (d_PL0 <= 0) {
      d_PL0 = -d_PL0;
      d_AZ0 = d_AZ0 + 180;
    }
    if (d_AZ0 < 0) {
      d_AZ0 = d_AZ0 + 360;
    } else if (d_AZ0 > 360) {
      d_AZ0 = d_AZ0 - 360;
    }

    // N axis
    if (d_PL1 <= 0) {
      d_PL1 = -d_PL1;
      d_AZ1 = d_AZ1 + 180;
    }
    if (d_AZ1 < 0) {
      d_AZ1 = d_AZ1 + 360;
    } else if (d_AZ1 > 360) {
      d_AZ1 = d_AZ1 - 360;
    }

    // P axis
    if (d_PL2 <= 0) {
      d_PL2 = -d_PL2;
      d_AZ2 = d_AZ2 + 180;
    }
    if (d_AZ2 < 0) {
      d_AZ2 = d_AZ2 + 360;
    } else if (d_AZ2 > 360) {
      d_AZ2 = d_AZ2 - 360;
    }
    return 0;
  } else {
    d_E00=0; d_E01=0; d_E02=0;
    d_E10=0; d_E11=0; d_E12=0;
    d_E20=0; d_E21=0; d_E22=0;
    d_EV0=0; d_EV1=0; d_EV2=0;
    d_AZ0=0; d_AZ1=0; d_AZ2=0;
    d_PL0=0; d_PL1=0; d_PL2=0;
    return -1;
  }
}

# Rotate a moment tensor around a specified plunging axis, by a specified angle.

# Generate the rotation matrix
# Output variables:
#   r_R[0-2][0-2]        rotation matrix
#   r_R_t[0-2][0-2]      transposed rotation matrix

function build_rotation_matrices(r_trend, r_plunge, r_alpha,       ux,uy,uz,ct,st) {
  # plunge here is the angle up the horizontal plane [-90=down; 90=up];
  # trend is the azimuth angle CW from north [0-360]

  trend=deg2rad(r_trend);
  plunge=deg2rad(r_plunge);
  angle=deg2rad(r_alpha);

  # GCMT focal mechanisms are in Up, South, East coordinates

  ux = sin(plunge);
  uy = -cos(plunge)*cos(trend);
  uz = cos(plunge)*sin(trend);

  ct = cos(angle);
  st = sin(angle);

  # r_R is the rotation matrix
  r_R[0][0] = ct + ux*ux*(1-ct);
  r_R[0][1] = ux*uy*(1-ct)-uz*st;
  r_R[0][2] = ux*uz*(1-ct)+uy*st;
  r_R[1][0] = uy*ux*(1-ct)+uz*st;
  r_R[1][1] = ct+uy*uy*(1-ct);
  r_R[1][2] = uy*uz*(1-ct)-ux*st;
  r_R[2][0] = uz*ux*(1-ct)-uy*st;
  r_R[2][1] = uz*uy*(1-ct)+ux*st;
  r_R[2][2] = ct+uz*uz*(1-ct);

  # r_R_t is the transposed rotation matrix
  r_R_t[0][0] = r_R[0][0];
  r_R_t[0][1] = r_R[1][0];
  r_R_t[0][2] = r_R[2][0];
  r_R_t[1][0] = r_R[0][1];
  r_R_t[1][1] = r_R[1][1];
  r_R_t[1][2] = r_R[2][1];
  r_R_t[2][0] = r_R[0][2];
  r_R_t[2][1] = r_R[1][2];
  r_R_t[2][2] = r_R[2][2];
}

function print_matrix(m) {
  for(i=0;i<3;i++) {
    for (j=0;j<3;j++) {
      printf("%lf ", m[i][j]);
    }
    printf("\n");
  }
}

# Calculate the azimuth between two lon/lat points
# sets global variable azimuth_2pt_d to be the km distance between the points

function azimuth_2pt(d_lon1, d_lat1, d_lon2, d_lat2,        lon1, lat1, lon2, lat2, theta) {
  lon1 = deg2rad(d_lon1);
  lat1 = deg2rad(d_lat1);
  lon2 = deg2rad(d_lon2);
  lat2 = deg2rad(d_lat2);
  theta = atan2(sin(lon2-lon1)*cos(lat2), cos(lat1)*sin(lat2)-sin(lat1)*cos(lat2)*cos(lon2-lon1));
  azimuth_2pt_d = acos(sin(lat1)*sin(lat2) + cos(lat1)*cos(lat2)*cos(lon2-lon1) ) * 6371;

  return((rad2deg(theta)+360)%360)
}


function dip_2pt(d_lon1, d_lat1, d_depth1, d_lon2, d_lat2, d_depth2,        lon1, lat1, lon2, lat2, theta, dip) {
  lon1 = deg2rad(d_lon1);
  lat1 = deg2rad(d_lat1);
  lon2 = deg2rad(d_lon2);
  lat2 = deg2rad(d_lat2);
  theta = atan2(sin(lon2-lon1)*cos(lat2), cos(lat1)*sin(lat2)-sin(lat1)*cos(lat2)*cos(lon2-lon1));
  azimuth_2pt_d = acos(sin(lat1)*sin(lat2) + cos(lat1)*cos(lat2)*cos(lon2-lon1) ) * 6371;

  # distance
  d = acos(sin(lat1)*sin(lat2) + cos(lat1)*cos(lat2)*cos(lon2-lon1) ) * 6371;
  dip=atan((d_depth2 - d_depth1) / d)

  return(rad2deg(dip))
}

# Calculate the average of two azimuthal directions

function ave_dir(d1, d2) {
  sumcos=cos(deg2rad(d1))+cos(deg2rad(d2))
  sumsin=sin(deg2rad(d1))+sin(deg2rad(d2))
  val=rad2deg(atan2(sumsin, sumcos))
  return val
}

# Calculate an azimuth from north and east XY components (in degrees)

function azimuth_from_en(east, north,      res) {
  res=rad2deg(atan2(east, north))
  while (res<0) {
    res+=360
  }
  return res
}

# The following function will take a string in the (approximate) form
# +-[deg][chars][min][chars][sec][chars][north|*n*]|[south|*s*]|[east|*e*]|[west|*w*][chars]
# and return the appropriately signed decimal degree value
# -125°12'18" -> -125.205
# 125 12 18 WEST -> -125.205

function coordinate_decimal(str) {
  neg=1
  ss=tolower(str)
  gsub("south", "s", ss)
  gsub("west", "w", ss)
  gsub("east", "e", ss)

  if (ss ~ /s/ || ss ~ /w/ || substr($0,1,1)=="-") {
    neg=-1;
  }
  gsub(/[^0-9\s\.]/, " ", ss)
  split(ss, arr);
  val=neg*(arr[1]+arr[2]/60+arr[3]/3600)
  return val
}

# Round down n to the nearest multiple of multipleOf

function rd(n, multipleOf)
{
  if (n % multipleOf == 0) {
    num = n
  } else {
     if (n > 0) {
        num = n - n % multipleOf;
     } else {
        num = n + (-multipleOf - n % multipleOf);
     }
  }
  return num
}

function ru(n, multipleOf)
{
  return rd(n, multipleOf) + multipleOf
}

################################################################################
# Data selection by longitude range potentially spanning dateline
# Returns 1 if longitude is within AOI of minlon/maxlon, 0 otherwise

function test_lon(minlon, maxlon, lon) {
  while (lon>180) {lon=lon-360}
  while (lon<-180) {lon=lon+360}
  if (minlon < -180) {
    if (maxlon <= -180) {
      return (lon-360 <= maxlon && lon-360 >= minlon)?1:0
    } else { # (maxlon >= -180)
      return (lon-360 >= minlon || lon <= maxlon)?1:0
    }
  } else {   # (minlon >= -180)
    if (minlon < 180){
      if (maxlon <= 180) {
        return (lon <= maxlon && lon >= minlon)?1:0
      } else { # maxlon > 180
        return (lon >= minlon || lon+360 <= maxlon)?1:0
      }
    } else {  # (minlon >= 180)
      return (lon+360 >= minlon && lon+360 <= maxlon)?1:0
    }
  }
}

################################################################################
# Focal mechanism functions

# moment_tensor_rotate()
#
# Variables that will be set upon successful execution:
# ------------------------------------------------------------------------------
# r_rotated[0-2][0-2]: Rotated matrix
# r_Mxx, r_Myy, r_Mzz, r_Mxy, r_Mxz, r_Myz: Rotated moment tensor components
# ------------------------------------------------------------------------------

function moment_tensor_rotate(Mxx,Myy,Mzz,Mxy,Mxz,Myz, r_trend, r_plunge, r_alpha,            i,j,u) {

  # Create the rotation matrix r_R[0-2][0-2] and its transpose r_R_t[0-2][0-2]
  build_rotation_matrices(r_trend, r_plunge, r_alpha);

  # This is the symmetric moment tensor matrix that we will rotate
  r_M[0][0] = Mxx;
  r_M[0][1] = Mxy;
  r_M[0][2] = Mxz;
  r_M[1][0] = Mxy;  # Myx
  r_M[1][1] = Myy;
  r_M[1][2] = Myz;
  r_M[2][0] = Mxz;  # Mzx
  r_M[2][1] = Myz;  # Mzy
  r_M[2][2] = Mzz;

  # Clear the arrays
  for (i = 0; i < 3; i++) {
    for (j = 0; j < 3; j++) {
      r_res1[i][j]=0;
      r_rotated[i][j]=0;
    }
  }

  # First matrix multiplication
  for (i = 0; i < 3; i++) {
    for (j = 0; j < 3; j++) {
      for (u = 0; u < 3; u++) {
        r_res1[i][j] += r_R_t[i][u] * r_M[u][j];
      }
    }
  }

  # second matrix multiplication
  for (i = 0; i < 3; i++) {
    for (j = 0; j < 3; j++) {
      for (u = 0; u < 3; u++) {
        r_rotated[i][j] += r_res1[i][u] * r_R[u][j];
      }
    }
  }

  r_Mxx=r_rotated[0][0];
  r_Myy=r_rotated[1][1];
  r_Mzz=r_rotated[2][2];
  r_Mxy=r_rotated[0][1];
  r_Mxz=r_rotated[0][2];
  r_Myz=r_rotated[1][2];
}


# moment_tensor_to_m0() 

# return the moment magnitude m0 based on the formula m0 = 1/sqrt(2) * (Mij^2)^1/2

# sdr_mantissa_exponent_to_full_moment_tensor()
# Calculate the six components of the moment tensor from strike, dip, rake and M0 in mantissa, exponent form
#
# Variables that will be set upon successful execution:
# ------------------------------------------------------------------------------
# Mf[1]-Mf[6]: Mrr, Mtt, Mpp, Mrt, Mrp, Mtp
# ------------------------------------------------------------------------------

# We want NED coordinates

function sdr_mantissa_exponent_to_full_moment_tensor(strike_d, dip_d, rake_d, mantissa, exponent, Mf,    strike, dip, rake)
{
  strike=deg2rad(strike_d)
  dip=deg2rad(dip_d)
  rake=deg2rad(rake_d)

  M0=mantissa*(10^exponent)

  # print "M0:", M0 > "/dev/stderr"

# Mrr Mtt Mpp Mrt Mrp Mtp
  M[1]=M0*sin(2*dip)*sin(rake)
  M[2]=-M0*(sin(dip)*cos(rake)*sin(2*strike)+sin(2*dip)*sin(rake)*sin(strike)*sin(strike))
  M[3]=M0*(sin(dip)*cos(rake)*sin(2*strike)-sin(2*dip)*sin(rake)*cos(strike)*cos(strike))
  M[4]=-M0*(cos(dip)*cos(rake)*cos(strike)+cos(2*dip)*sin(rake)*sin(strike))
  M[5]=M0*(cos(dip)*cos(rake)*sin(strike)-cos(2*dip)*sin(rake)*cos(strike))
  M[6]=-M0*(sin(dip)*cos(rake)*cos(2*strike)+0.5*sin(2*dip)*sin(rake)*sin(2*strike))

  # Do we need to adjust the scale if one of the M components is too large? Not sure but...
  maxscale=0
  for (key in M) {
    scale=int(log(M[key]>0?M[key]:-M[key])/log(10))
    maxscale=scale>maxscale?scale:maxscale
  }

# Testing some different approaches to making good files here
  Mf[1]=M[1]/10^maxscale
  Mf[2]=M[2]/10^maxscale
  Mf[3]=M[3]/10^maxscale
  Mf[4]=M[4]/10^maxscale
  Mf[5]=M[5]/10^maxscale
  Mf[6]=M[6]/10^maxscale
  #Mf[1]=sprintf("%0.3f", (M[1]==0)?0.001:M[1]/10^maxscale)
  #Mf[2]=sprintf("%0.3f", (M[2]==0)?0.001:M[2]/10^maxscale)
  #Mf[3]=sprintf("%0.3f", (M[3]==0)?0.001:M[3]/10^maxscale)
  #Mf[4]=sprintf("%0.3f", (M[4]==0)?0.001:M[4]/10^maxscale)
  #Mf[5]=sprintf("%0.3f", (M[5]==0)?0.001:M[5]/10^maxscale)
  #Mf[6]=sprintf("%0.3f", (M[6]==0)?0.001:M[6]/10^maxscale)
}

# sdr_to_tnp()
# Calculate the principal axes azimuth and plunge from strike, dip, rake of a nodal plane
#
# Variables that will be set upon successful execution:
# ------------------------------------------------------------------------------
# TNP[1]-TNP[9]: Tval, Taz, Tinc, Nval, Naz, Ninc, Pval, Paz, Pinc (angles in degrees)
# ------------------------------------------------------------------------------

function sdr_to_tnp(strike_d, dip_d, rake_d, TNP,      n,N,T,P,l,strike,dip,rake,Taz,Tinc,Tval,Pval,Paz,Pinc,Nval,Naz,Ninc) {
  strike=deg2rad(strike_d)
  dip=deg2rad(dip_d)
  rake=deg2rad(rake_d)

  # l is the slick vector
  l[1]=sin(strike)*cos(rake)-cos(strike)*cos(dip)*sin(rake)
  l[2]=cos(strike)*cos(rake)+sin(strike)*cos(dip)*sin(rake)
  l[3]=sin(dip)*sin(rake)

  # n is the normal vector
  n[1]=cos(strike)*sin(dip)
  n[2]=-sin(strike)*sin(dip)
  n[3]=cos(dip)

  P[1]=1/ssqrt(2)*(n[1]-l[1])
  P[2]=1/ssqrt(2)*(n[2]-l[2])
  P[3]=1/ssqrt(2)*(n[3]-l[3])

  T[1]=1/ssqrt(2)*(n[1]+l[1])
  T[2]=1/ssqrt(2)*(n[2]+l[2])
  T[3]=1/ssqrt(2)*(n[3]+l[3])

  Paz = rad2deg(atan2(P[1],P[2]))
  Pinc = rad2deg(asin(P[3]))
  if (Pinc>0) {
    Paz=(Paz+180)%360
  }
  if (Pinc<0) {
    Pinc=-Pinc
    Paz=(Paz+360)%360
  }
  Taz = rad2deg(atan2(T[1],T[2]))
  Tinc = rad2deg(asin(T[3]))
  if (Tinc>0) {
    Taz=(Taz+180)%360
  }
  if (Tinc<0) {
    Tinc=-Tinc
    Taz=(Taz+360)%360
  }

  # N = n × l
  N[1]=(n[2]*l[3]-n[3]*l[2])
  N[2]=-(n[1]*l[3]-n[3]*l[1])
  N[3]=(n[1]*l[2]-n[2]*l[1])

  Naz = rad2deg(atan2(N[1],N[2]))
  Ninc = rad2deg(asin(N[3]))
  if (Ninc>0) {
    Naz=(Naz+180)%360
  }
  if (Ninc<0) {
    Ninc=-Ninc
    Naz=(Naz+360)%360
  }

  # When using this method to get principal axes, we have lost all information
  # about the relative magnitudes of the eigenvalues.
  Tval=1
  Nval=0
  Pval=-1

  TNP[1]=Tval
  TNP[2]=Taz
  TNP[3]=Tinc
  TNP[4]=Nval
  TNP[5]=Naz
  TNP[6]=Ninc
  TNP[7]=Pval
  TNP[8]=Paz
  TNP[9]=Pinc
}

# mechanism_type_from_TNP()
# Calculate the focal mechanism type
# Returns: mechanism class (N=normal, S=strike slip, T=thrust)

function mechanism_type_from_TNP(Tinc, Ninc, Pinc) {
  if (Pinc >= Ninc && Pinc >= Tinc) {
   class="N"
 } else if (Ninc >= Pinc && Ninc >= Tinc) {
   class="S"
  } else {
   class="T"
  }
  return class
}

# aux_sdr()
# Calculate the auxilliary fault plane from strike, dip, rake of a nodal plane
# Modified from code by Utpal Kumar, Li Zhao, IESCODERS
#
# Variables that will be set upon successful execution:
# ------------------------------------------------------------------------------
# SDR[1]-SDR[3]: Strike, Dip, Rake (all in degrees)
# ------------------------------------------------------------------------------

function aux_sdr(strike_d, dip_d, rake_d, SDR) {
  strike = deg2rad(strike_d)
  dip = deg2rad(dip_d)
  rake = deg2rad(rake_d)

  aux_dip = acos(sin(rake)*sin(dip))

  if (aux_dip==0) {
    print "auxdip div by 0 for strike/dip/rake=" rad2deg(strike) "/" rad2deg(dip) "/" rad2deg(rake) "/" > "/dev/stderr"
    aux_dip=0.0001
  }
  r2 = atan2(cos(dip)/sin(aux_dip), -sin(dip)*cos(rake)/sin(aux_dip))
  if (dip==0) {
    print "Div by 0 for strike/dip/rake=" rad2deg(strike) "/" rad2deg(dip) "/" rad2deg(rake) "/" > "/dev/stderr"
    SDR[1]=strike
    SDR[2]=90
    SDR[3]=rad2deg(r2)
  } else {
    aux_strike = rad2deg(strike - atan2(cos(rake)/sin(aux_dip), -1/(tan(dip)*tan(aux_dip))))
    aux_dip = rad2deg(aux_dip)
    aux_rake = rad2deg(r2)

    if (aux_dip > 90) {
        aux_strike = aux_strike + 180
        aux_dip = 180 - aux_dip
        aux_rake = 360 - aux_rake
    }

    while (aux_strike > 360) {
        aux_strike = aux_strike - 360
    }
    while (aux_strike < 00) {
        aux_strike = aux_strike + 360
    }
  }

  SDR[1]=aux_strike
  SDR[2]=aux_dip
  SDR[3]=aux_rake
}

# rake_from_twosd_im()
# Calculate rake of a nodal plane from two nodal plane strike/dips and a sign
# factor that defines the slip direction. Modified from GMT psmeca (G. Patau, IPGP)
#
# Returns: rake angle (degrees)

function rake_from_twosd_im(S1, D1, S2, D2, im) {

    ss=sin(deg2rad(S1-S2))
    cs=cos(deg2rad(S1-S2))

  	sd = sin(deg2rad(D1));
    cd = cos(deg2rad(D2));

  	if ( abs(D2 - 90.0) < 0.1) {
  		sinrake2 = im * cd;
    } else {
  		sinrake2 = -im * sd * cs / cd;
    }

  	rake2 = d_atan2d(sinrake2, -im*sd*ss);
    return rake2
}

# ntp_to_sdr()
# Calculate the strike, dip, and rake of both nodal planes from principal axes
# Modified from GMT psutil.c (G Patau, IPGP)
#
# Variables that will be set upon successful execution:
# ------------------------------------------------------------------------------
# SDR[1]=strike1, SDR[2]=dip1, SDR[3]=rake1 SDR[4]=strike2 SDR[5]=dip2 SDR[6]=rake2
# ------------------------------------------------------------------------------

function ntp_to_sdr(Taz, Tinc, Paz, Pinc, SDR,        sdp,cdp,spp,cpp,sdt,cdt,spt,cpt,amz,d1,p1,d2,p2,rake1,rake2) {

  sdp=sin(deg2rad(Pinc))
  cdp=cos(deg2rad(Pinc))
  spp=sin(deg2rad(Paz))
  cpp=cos(deg2rad(Paz))

  sdt=sin(deg2rad(Tinc))
  cdt=cos(deg2rad(Tinc))
  spt=sin(deg2rad(Taz))
  cpt=cos(deg2rad(Taz))

	cpt=cpt*cdt;
  spt=spt*cdt;
	cpp=cpp*cdp;
  spp=spp*cdp;

  amz = sdt + sdp; amx = spt + spp; amy = cpt + cpp;
  d1 = rad2deg(atan2(hypot(amx, amy), amz));
  p1 = rad2deg(atan2(amy, -amx));

  if (d1 > 90.0) {
    d1 = 180.0 - d1;
    p1 = p1 - 180.0;
  }
  if (p1 < 0.0) {
    p1 = p1 + 360.0;
  }

  amz = sdt - sdp; amx = spt - spp; amy = cpt - cpp;
  d2 = rad2deg(atan2(hypot(amx, amy), amz));
  p2 = rad2deg(atan2(amy, -amx));
  if (d2 > 90.0) {
    d2 = 180.0 - d2;
    p2 = p2 - 180.0;
  }
  if (p2 < 0.0) {
    p2 = p2 + 360.0;
  }

  if (Pinc > Tinc) {
    im = -1;
  } else {
    im = 1
  }

  rake1=rake_from_twosd_im(p2, d2, p1, d1, im)
  rake2=rake_from_twosd_im(p1, d1, p2, d2, im)

  SDR[1]=p1
  SDR[2]=d1
  SDR[3]=rake1

  SDR[4]=p2
  SDR[5]=d2
  SDR[6]=rake2
}

# Check if ID is in tectoplot YYYY:MM:DDTHH:MM:SS format. If not, return a dummy ID with a 0 date/time

function make_tectoplot_id(proposed_id) {
  if (proposed_id ~ /[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]T[0-9][0-9]:[0-9][0-9]:[0-9][0-9]/) {
    return proposed_id
  } else {
    return sprintf("0000-00-00T00:00:00%s", proposed_id)
  }
}

function isnumber(val) {
  if ((val ~ /^[-+]?[0-9]*\.?[0-9]+$/) || (val == "none")) {
    return 1
  } else {
    return 0
  }
}

# gawk 'function ceil(x)       { return int(x)+(x>int(x))       }
# function floor(x)      { return ceil(x)-1               }
function leapyearsbefore(year, month,     y) {
  y=year
  if (year==0 && month<2) {
    return 0
  }
  if (month>2) {
    y=year+1
  }
  return 1 + floor(y / 4) - floor(y / 100) + floor(y / 400)
}
# { print leapyearsbefore($1, $2) }'


# 1     the first leap year, Feb 29 0000
# 2     floor(y / 4) number of years divided by 4; 0==0 1==0 2==0 3==0 4==1
#         so if month==3 then Y=4 (no) goes to Y=5 (yes)
#         but if month==3 then Y=4 is still no
# 3


# 0  L        1           2           3             4  L
# |...........|...........|...........|.............|............]
#

# Return the number of leap years between year=start and later year=end
function leapyearsbetween(start, startmonth, end) {
  return leapyearsbefore(end, 1) - leapyearsbefore(start, startmonth);
}

function iso8601_to_epoch(timestring,        a,b,c) {
  ENVIRON["TZ"] = "UTC"
  timecode=substr(timestring, 1, 19)
  split(timecode, a, "-")

  year=a[1]
  month=a[2]
  split(a[3],b,"T")
  day=b[1]
  split(b[2],c,":")

  hour=c[1]
  minute=c[2]
  second=c[3]

  if (year < 1900) {
    # we need to account for the seconds backward from 1900
    # seconds thus far in the year at hand
    short_time=sprintf("%04i %02i %02i %02i %02i %02i",1970,month,day,hour,minute,int(second+0.5));
    shortepoch=mktime(short_time);
    # 1900-01-01T00:00:00 is epoch -2208988800
    # assume 31536000 seconds per year without leap years
    #
    leapyears=leapyearsbetween(year, month, 1900)
    # print leapyears > "/dev/stderr"
    epoch=-2208988800-(1900-year)*31536000-24*60*60*leapyears+shortepoch
    return epoch
  }

  the_time=sprintf("%04i %02i %02i %02i %02i %02i",year,month,day,hour,minute,int(second+0.5));
  return mktime(the_time);
}

function epoch_to_iso8601(time) {
  ENVIRON["TZ"] = "UTC"
  return strftime("%FT%T", time)
}

#
function time_increments_from_date(timestring_start, timestring_end, timestring_inc) {
  ENVIRON["TZ"] = "UTC"
  timecode=substr(timestring_start, 1, 19)
  split(timecode, a, "-")
  year=a[1]
  month=a[2]
  split(a[3],b,"T")
  day=b[1]
  split(b[2],c,":")
  hour=c[1]
  minute=c[2]
  second=c[3]

  timecode=substr(timestring_end, 1, 19)
  split(timecode, a, "-")
  year_end=a[1]
  month_end=a[2]
  split(a[3],b,"T")
  day_end=b[1]
  split(b[2],c,":")
  hour_end=c[1]
  minute_end=c[2]
  second_end=c[3]

  # Calculate the epoch of the start time
  start_time=sprintf("%04i %02i %02i %02i %02i %02i",year,month,day,hour,minute,int(second+0.5));
  epoch_start=mktime(start_time);

  # Calculate the epoch of the end time
  end_time=sprintf("%04i %02i %02i %02i %02i %02i",year_end,month_end,day_end,hour_end,minute_end,int(second_end+0.5));
  epoch_end=mktime(end_time);


  if (timestring_inc+0 != timestring_inc) {
    # third argument is the number of divisions to generate between start and
    # end times
    timecode_inc=substr(timestring_inc, 1, 19)
    split(timecode_inc, d, "-")
    year_inc=d[1]
    month_inc=d[2]
    split(d[3],e,"T")
    day_inc=e[1]
    split(e[2],f,":")
    hour_inc=f[1]
    minute_inc=f[2]
    second_inc=f[3]
  } else {
    # third argument is the number of divisions to generate between start and
    # end times
    year_inc=0
    month_inc=0
    day_inc=0
    hour_inc=0
    minute_inc=0
    second_inc=(epoch_end-epoch_start)/timestring_inc
  }

  newtime=timestring_start

  for(increment=1; newtime<timestring_end;increment++ ) {
    the_time=sprintf("%04i %02i %02i %02i %02i %02i", year+increment*year_inc, month+increment*month_inc, day+increment*day_inc, hour+increment*hour_inc, minute+increment*minute_inc, int(second+increment*second_inc+0.5));
    newtime=strftime("%FT%T",i+mktime(the_time))
    if (newtime>timestring_end) {
      break
    }
    print newtime

  }
}


# Functions for 3D focal mechanisms (rotations)

# Produce a rotation matrix that transforms a reference CMT object using
# specified yaw, pitch, and roll angles

function calc_rotation_matrix(yaw_deg, pitch_deg, roll_deg,     alpha, beta, gamma)
{
  alpha=deg2rad(yaw_deg)
  beta=deg2rad(pitch_deg)
  gamma=deg2rad(roll_deg)

  if (havematrix == 0) {
    R_ypr[0][0]=cos(alpha)*cos(beta)
    R_ypr[0][1]=cos(alpha)*sin(beta)*sin(gamma)-sin(alpha)*cos(gamma)
    R_ypr[0][2]=cos(alpha)*sin(beta)*cos(gamma)+sin(alpha)*sin(gamma)
    R_ypr[1][0]=sin(alpha)*cos(beta)
    R_ypr[1][1]=sin(alpha)*sin(beta)*sin(gamma)+cos(alpha)*cos(gamma)
    R_ypr[1][2]=sin(alpha)*sin(beta)*cos(gamma)-cos(alpha)*sin(gamma)
    R_ypr[2][0]=-sin(beta)
    R_ypr[2][1]=cos(beta)*sin(gamma)
    R_ypr[2][2]=cos(beta)*cos(gamma)

    # printf("| %.02f %.02f %.02f |\n", R_ypr[0][0], R_ypr[0][1], R_ypr[0][2]) > "/dev/stderr"
    # printf("| %.02f %.02f %.02f |\n", R_ypr[1][0], R_ypr[1][1], R_ypr[1][2]) > "/dev/stderr"
    # printf("| %.02f %.02f %.02f |\n", R_ypr[2][0], R_ypr[2][1], R_ypr[2][2]) > "/dev/stderr"
  }
}

# Calculate rotation matrix about arbitrary axis [u, v, w] through angle theta
# where theta is in degrees

function calc_rotation_matrix_axis(u, v, w, theta_deg,      theta, uu, vv, ww, uv, vw, uw, l, L, c, s)
{
  theta=deg2rad(theta_deg)
  uu=u*u
  uv=u*v
  uw=u*w
  vw=v*w
  vv=v*v
  ww=w*w
  c=cos(theta)
  s=sin(theta)
  L=uu+vv+ww
  l=sqrt(L)

  print "u v w", u, v, w > "/dev/stderr"
  print "L is", L > "/dev/stderr"

  if (havematrix == 0) {
    R_ypr[0][0]=(uu+(vv+ww)*cos(theta))/L
    R_ypr[0][1]=(uv*(1-c)-w*l*s)/L
    R_ypr[0][2]=(uw*(1-c)+v*l*s)/L
    R_ypr[1][0]=(uv*(1-c)+w*l*s)/L
    R_ypr[1][1]=(vv+(uu+ww)*c)/L
    R_ypr[1][2]=(vw*(1-c)-u*l*s)/L
    R_ypr[2][0]=(uw*(1-c)-v*l*s)/L
    R_ypr[2][1]=(vw*(1-c)+u*l*s)/L
    R_ypr[2][2]=(ww+(uu+vv)*c)/L

    # printf("| %.02f %.02f %.02f |\n", R_ypr[0][0], R_ypr[0][1], R_ypr[0][2]) > "/dev/stderr"
    # printf("| %.02f %.02f %.02f |\n", R_ypr[1][0], R_ypr[1][1], R_ypr[1][2]) > "/dev/stderr"
    # printf("| %.02f %.02f %.02f |\n", R_ypr[2][0], R_ypr[2][1], R_ypr[2][2]) > "/dev/stderr"
  }
}




function calc_ecef_to_enu_matrix(lon_deg, lat_deg,    lambda, phi) {

  lambda=deg2rad(lon_deg)
  phi=deg2rad(lat_deg)

  R_ecef[0][0]=-sin(lambda)
  R_ecef[0][1]=-cos(lambda)*sin(phi)
  R_ecef[0][2]=cos(lambda)*cos(phi)
  R_ecef[1][0]=cos(lambda)
  R_ecef[1][1]=-sin(lambda)*sin(phi)
  R_ecef[1][2]=sin(lambda)*cos(phi)
  R_ecef[2][0]=0
  R_ecef[2][1]=cos(phi)
  R_ecef[2][2]=sin(phi)

#  printf("| %.02f %.02f %.02f |\n", R_ecef[0][0], R_ecef[0][1], R_ecef[0][2]) > "/dev/stderr"
#  printf("| %.02f %.02f %.02f |\n", R_ecef[1][0], R_ecef[1][1], R_ecef[1][2]) > "/dev/stderr"
#  printf("| %.02f %.02f %.02f |\n", R_ecef[2][0], R_ecef[2][1], R_ecef[2][2]) > "/dev/stderr"

}

function sdr_rotation_matrix(strike_deg, dip_deg, rake_deg) {
  calc_rotation_matrix(0-strike_deg, dip_deg-90, 90+rake_deg)
}

function multiply_rotation_matrix(x, y, z,    i,j) {
  u[0]=x
  u[1]=y
  u[2]=z
  for(i=0; i<3; i++) {
      v[i] = 0.0;
      for(j=0; j<3; j++) {
          v[i] += (R_ypr[i][j] * u[j]);
      }
  }
}

function multiply_ecef_matrix(x, y, z,    i,j) {
  u[0]=x
  u[1]=y
  u[2]=z
  for(i=0; i<3; i++) {
      w[i] = 0.0;
      for(j=0; j<3; j++) {
          w[i] += (R_ecef[i][j] * u[j]);
      }
  #    print "w[" i "]=" w[i] > "/dev/stderr"
  }
}

# Returns distance across earth's spherical surface in meters, inputs are in degrees
# Earth radius is 6371000 meters

function haversine_m(lon1, lat1, lon2, lat2,      hav_lon1_r, hav_lat1_r, hav_lon2_r, hav_lat2_r) {
  hav_lon1_r=deg2rad(lon1)
  hav_lat1_r=deg2rad(lat1)
  hav_lon2_r=deg2rad(lon2)
  hav_lat2_r=deg2rad(lat2)

  return 2*6371000*asin(ssqrt( sqr(sin((hav_lat2_r-hav_lat1_r)/2)) + cos(hav_lat1_r)*cos(hav_lat2_r)*sqr(sin((hav_lon2_r-hav_lon1_r)/2))))
}

# Returns angular distance between two points, in degrees. Inputs are in degrees

function angulardistance_m(lon1, lat1, lon2, lat2,      hav_lon1_r, hav_lat1_r, hav_lon2_r, hav_lat2_r) {
  hav_lon1_r=deg2rad(lon1)
  hav_lat1_r=deg2rad(lat1)
  hav_lon2_r=deg2rad(lon2)
  hav_lat2_r=deg2rad(lat2)

  return rad2deg(acos(sin(hav_lat1_r)*sin(hav_lat2_r) + cos(hav_lat1_r)*cos(hav_lat2_r)*cos(hav_lon1_r-hav_lon2_r)))
}


# Return the radius of the Earth at a specified latitude. 

function radiusEarth(latitude_r) {
	r_equator=6378.137
	r_pole=6356.752
	a=r_equator
	b=r_pole

	cs=cos(latitude_r)
	ss=sin(latitude_r)

	return sqrt(((a*a*cs)^2+(b*b*ss)^2)/((a*cs)^2+(b*ss)^2))
}

# Calculate the East and North velocity of a site at Earth sea level given two
# Euler poles of rotation that are subtracted. This is useful if we have a pole
# of rotation relative to a reference plate, which itself is described by a pole
# of rotation relative to a reference frame (e.g. ITRF or NNR)

# Inputs are longitude, latitude, w (degrees/Myr) for both poles of rotation, followed
# by the longitude and latitude of the point of interest.

# Note that this function is off by a small fraction (<<1%) from the published conversions
# of Kreemer et al., 2014, suggesting a different treatment of either the figure
# of the Earth, geocentric vs geodetic latitude, etc. More investigation is needed.

# Global variables that will be set after calling this function:
# eulervec_N, eulervec_E, eulervec_U

function eulervec(eLat_d1, eLon_d1, eV1, eLat_d2, eLon_d2, eV2, tLon_d, tLat_d,         eLat_r1, eLat_r2, eLon_r1, eLon_r2, tLat_r, tLat_r_adj, tLon_r, earthrad, a1, a2, a3, b1, b2, b3, V1, V2, V3, R11, R12, R13, R21, R22, R23, R31, R32, R33) {
	eLat_r1 = deg2rad(eLat_d1)
	eLon_r1 = deg2rad(eLon_d1)
	eLat_r2 = deg2rad(eLat_d2)
	eLon_r2 = deg2rad(eLon_d2)

	tLat_r = deg2rad(tLat_d)
	tLon_r = deg2rad(tLon_d)

	# Convert geodetic to geocentric latitude
  e=0.081819
	tLat_r_adj=atan((1-e*e)*tan(tLat_r))

	a11 = deg2rad(eV1)*cos(eLat_r1)*cos(eLon_r1)
	a21 = deg2rad(eV1)*cos(eLat_r1)*sin(eLon_r1)
	a31 = deg2rad(eV1)*sin(eLat_r1)

	a12 = deg2rad(eV2)*cos(eLat_r2)*cos(eLon_r2)
	a22 = deg2rad(eV2)*cos(eLat_r2)*sin(eLon_r2)
	a32 = deg2rad(eV2)*sin(eLat_r2)

	# a = [a1, a2, a3] is in units of rad/Myr
	a1 = a11-a12
	a2 = a21-a22
	a3 = a31-a32

	# unit vector
	b1 = cos(tLat_r)*cos(tLon_r)
	b2 = cos(tLat_r)*sin(tLon_r)
  b3 = sin(tLat_r)

	# V is in units of km*deg/Myr 

	V1 = a2*b3-a3*b2
	V2 = a3*b1-a1*b3
	V3 = a1*b2-a2*b1

	# Conversion from ECEF to NEU coordinates
	R11 = -sin(tLat_r_adj)*cos(tLon_r)
	R12 = -sin(tLat_r_adj)*sin(tLon_r)
	R13 = cos(tLat_r_adj)
  R21 = -sin(tLon_r)
  R22 = cos(tLon_r)
  R23 = 0
  R31 = cos(tLat_r_adj)*cos(tLon_r)
  R32 = cos(tLat_r_adj)*sin(tLon_r)
  R33 = sin(tLat_r_adj)

	# Multiply by the Earth radius to get velocity at Earth's surface in km/Myr = mm/yr
  earthrad=radiusEarth(tLat_r_adj)
  eulervec_N=earthrad*(R11*V1 + R12*V2 + R13 * V3)
  eulervec_E=earthrad*(R21*V1 + R22*V2 + R23 * V3)
  eulervec_U=earthrad*(R31*V1 + R32*V2 + R33 * V3)
}


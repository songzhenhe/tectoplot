# tectoplot
# eulervec_2pole_cart.awk
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
#
# eulervec_2pole_cart.awk
#
# gawk function to calculate Euler velocity vectors (azimuth, velocity) at all
# input locations on Earth's surface, given an input file with lat lon data. 
# This function takes as arguments two Euler poles of rotation given in the form 
# Lat/Lon/w (°/Myr). The output is the east and north components of velocity 
# in units of mm/yr. Input geodetic latitudes are converted to geocentric 
# latitudes prior to calculation.

# Example call:
# awk -f eulervec_2pole.awk -v eLat_d1=17.69 -v eLon_d1=134.30 -v eV1=1.763 -v eLat_d2=7.69 -v eLon_d2=34.30 -v eV2=0.3 testlatlon.txt
#

function tan(x)       { return sin(x)/cos(x)               }
function atan(x)      { return atan2(x,1)                  }
function acos(x)      { return atan2(sqrt(1-x*x), x)       }
function deg2rad(Deg) { return ( 4.0*atan(1.0)/180 ) * Deg }
function rad2deg(Rad) { return ( 45.0/atan(1.0) ) * Rad    }

function radiusEarth(latitude_r) {
	r_equator=6378.137
	r_pole=6356.752
	a=r_equator
	b=r_pole

	cs=cos(latitude_r)
	ss=sin(latitude_r)

	return sqrt(((a*a*cs)^2+(b*b*ss)^2)/((a*cs)^2+(b*ss)^2))
}

# Take data in lon lat format

function eulervec(eLat_d1, eLon_d1, eV1, eLat_d2, eLon_d2, eV2, tLon_d, tLat_d) {
	pi = atan2(0, -1)

	# earthrad is in units of km
	# earthrad = 6378.137
	e=0.081819
	
	eLat_r1 = deg2rad(eLat_d1)
	eLon_r1 = deg2rad(eLon_d1)
	eLat_r2 = deg2rad(eLat_d2)
	eLon_r2 = deg2rad(eLon_d2)

	tLat_r = deg2rad(tLat_d)
	tLon_r = deg2rad(tLon_d)

	# Convert geodetic to geocentric latitude
	tLat_r_adj=atan((1-e*e)*tan(tLat_r))

	earthrad=radiusEarth(tLat_r_adj)

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
	# # https://www.mathworks.com/help/aeroblks/directioncosinematrixeceftoned.html 
	# # (reference is for ECEF to NED - we multiply R3* by -1 below to get NEU)

	R11 = -sin(tLat_r_adj)*cos(tLon_r)
	R12 = -sin(tLat_r_adj)*sin(tLon_r)
	R13 = cos(tLat_r_adj)
    R21 = -sin(tLon_r)
  	R22 = cos(tLon_r)
  	R23 = 0
  	R31 = cos(tLat_r_adj)*cos(tLon_r)
  	R32 = cos(tLat_r_adj)*sin(tLon_r)
  	R33 = sin(tLat_r_adj)

	# L1 is NORTH and L2 is east and L3 is UP
	L1 = R11*V1 + R12*V2 + R13 * V3
	L2 = R21*V1 + R22*V2 + R23 * V3
	L3 = R31*V1 + R32*V2 + R33 * V3

	# Multiply by the Earth radius to get velocity at Earth's surface in km/Myr = mm/yr
  	printf("%0.4f %0.4f\n", earthrad*L2, earthrad*L1)
}

BEGIN{
}
# Note that input is lat lon order, but data are passed to the function in lon lat order...
NF {
	eulervec(eLat_d1, eLon_d1, eV1, eLat_d2, eLon_d2, eV2, $2, $1)
}

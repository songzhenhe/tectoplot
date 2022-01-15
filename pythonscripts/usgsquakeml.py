# usgs_focal.py
# Kyle Edward Bradley, NTU, 2022
# modified from original code by Charles Ammon
# https://sites.psu.edu/charlesammon/2017/01/31/parsing-usgs-quakeml-files-with-python/

from xml.etree import cElementTree as ElementTree
import urllib2
import time, sys, os
# from __future__ import print_function

# Some generic utilities I use to parse the xml
#
#---------------------------------------------------------------------------------
# function to search an xml item for the value specified by the key
#   returns the value if the item is not found, the string 'None' is returned
#   if the value is not found.
#---------------------------------------------------------------------------------
def get_xitem_as_text(item,key):
    anItem = item.find(key,ns)
    if(anItem != None):
        return anItem.text
    else:
        return 'None'
#
#---------------------------------------------------------------------------------
#  same type of function as above, but this one also checks that the item
#     has a value provided.
#---------------------------------------------------------------------------------
def get_xitem_value_as_text(item,key,valuekey):
    anItem = item.find(key,ns)
    if(anItem == None):
        return 'None'
    else:
        value = anItem.find(valuekey,ns)
        if(value != None):
            return value.text
        else:
            return 'None'
#
#---------------------------------------------------------------------------------
def search_pdicts(key, value, list_of_dictionaries):
    return [element for element in list_of_dictionaries if element[key] == value]
#
#
# To make outputting information simple, I insure that certain values are in each dictionary,
#   whether they are defined in the xml or not. These dictionaries set up default values,
#   but as the xml is parsed, defined key value pairs are updated.
#
defaultPick = {'stationCode':'--','networkCode':'--','channelCode':'--',
                         'locationCode':'--','phase':'NA','time':'NA'}
#
defaultArrival = {'genericAmplitude':'NA','type':'NA','unit':'NA',
                  'period':'NA', 'evaluationMode':'NA','timeResidual':'NA',
                  'timeWeight':'NA'}
#
defaultAmplitude = {'pickID':'NA','genericAmplitude':'NA','period':'NA',
                  'unit':'NA', 'evaluationMode':'NA'}
#
#---------------------------------------------------------------------------------
# def getEventOrigins(xevent):
#     xorigins = xevent.findall('d:origin',ns)
#     return xorigins
#
#---------------------------------------------------------------------------------
def parse_origins(xevent):
    xorigins = xevent.findall('d:origin',ns)
    origins = []
    for xorigin in xorigins:
        anOrigin = xorigin.attrib.copy()
        anOrigin.update({
        'otime': get_xitem_value_as_text(xorigin,'d:time','d:value').split("Z")[0].split(".")[0],
        'latitude' : get_xitem_value_as_text(xorigin,'d:latitude','d:value'),
        'longitude' : get_xitem_value_as_text(xorigin,'d:longitude','d:value'),
        'depth' : str(float(get_xitem_value_as_text(xorigin,'d:depth','d:value'))/1000),
        'dotime' : get_xitem_value_as_text(xorigin,'d:time','d:uncertainty'),
        'dlatitude' : get_xitem_value_as_text(xorigin,'d:latitude','d:uncertainty'),
        'dlongitude' : get_xitem_value_as_text(xorigin,'d:longitude','d:uncertainty'),
        'ddepth' : get_xitem_value_as_text(xorigin,'d:depth','d:uncertainty')
        })
        #
        origins.append(anOrigin)
    #
    return origins
#
#---------------------------------------------------------------------------------
def list_origins(orgs):
    print 'time\tlon\tlat\tdepth'
    for org in orgs:
        print "%s\t%s\t%s\t%s" % (org['otime'], org['longitude'],org['latitude'],org['depth'])
#
#---------------------------------------------------------------------------------
def parse_magnitudes(xevent):
    xmags = xevent.findall('d:magnitude',ns)
    # print(xmags)
    mags = []
    for xmag in xmags:
        mdict = xmag.attrib.copy()
        mdict.update({'mag': get_xitem_value_as_text(xmag,'d:mag','d:value')})
        mdict.update({'magType': get_xitem_as_text(xmag,'d:type')})
        value = get_xitem_as_text(xmag,'d:evaluationMode')
        if(value!='NA'):
            mdict.update({"evaluationMode" : value})

        value = get_xitem_as_text(xmag,'d:originID')
        if(value!='NA'):
            mdict.update({"originID" : value})

        value = get_xitem_value_as_text(xmag,'d:creationInfo', 'd:agencyID')
        if(value!='NA'):
            mdict.update({"agencyID" : value})
        #
        mdict.update({"publicID" : mdict['publicID']})
        # print "%s" % (value)
        mags.append(mdict)
    return mags

# mechanism_type_from_TNP()
# Calculate the focal mechanism type
# Returns: mechanism class (N=normal, S=strike slip, T=thrust)

def mechanism_type_from_TNP(Tinc, Ninc, Pinc):
    if Pinc >= Ninc and Pinc >= Tinc:
        fclass="N"
    elif Ninc >= Pinc and Ninc >= Tinc:
        fclass="S"
    else:
        fclass="T"
    return fclass

def parse_moment_tensors(xevent):
    # Find the focal mechanism sections
    xmoms = xevent.findall('d:focalMechanism',ns)
    moms = []
    # For each focal mechanism
    for xmom in xmoms:
        # Each focal mechanism will have attributes
        anMom = xmom.attrib.copy()
        anMom.update({"agency" : get_xitem_value_as_text(xmom,'d:creationInfo','d:agencyID')})

        # Find the momentTensor section(s) - should only be one!
        momtens=xmom.findall('d:momentTensor',ns)
        for thistens in momtens:
            anMom.update({"scalarMoment" : get_xitem_value_as_text(thistens,'d:scalarMoment','d:value')})
            anMom.update({"centroid_dt" : get_xitem_value_as_text(thistens,'d:sourceTimeFunction','d:riseTime')})
            anMom.update({"mantissa" : get_xitem_value_as_text(thistens,'d:scalarMoment','d:value').split("e")[0]})

            tensors=thistens.findall('d:tensor',ns)
            for tensor in tensors:
                mrr_exp=int(get_xitem_value_as_text(tensor,'d:Mrr','d:value').lower().split("+")[-1])
                mtt_exp=int(get_xitem_value_as_text(tensor,'d:Mtt','d:value').lower().split("+")[-1])
                mpp_exp=int(get_xitem_value_as_text(tensor,'d:Mpp','d:value').lower().split("+")[-1])
                mrt_exp=int(get_xitem_value_as_text(tensor,'d:Mrr','d:value').lower().split("+")[-1])
                mrp_exp=int(get_xitem_value_as_text(tensor,'d:Mrp','d:value').lower().split("+")[-1])
                mtp_exp=int(get_xitem_value_as_text(tensor,'d:Mtp','d:value').lower().split("+")[-1])
                max_exponent=max(mrr_exp, mtt_exp, mpp_exp, mrt_exp, mrp_exp, mtp_exp)

                mrr=float(get_xitem_value_as_text(tensor,'d:Mrr','d:value').lower().split("e")[0])*10**(mrr_exp-max_exponent)
                mtt=float(get_xitem_value_as_text(tensor,'d:Mtt','d:value').lower().split("e")[0])*10**(mtt_exp-max_exponent)
                mpp=float(get_xitem_value_as_text(tensor,'d:Mpp','d:value').lower().split("e")[0])*10**(mpp_exp-max_exponent)
                mrt=float(get_xitem_value_as_text(tensor,'d:Mrt','d:value').lower().split("e")[0])*10**(mrt_exp-max_exponent)
                mrp=float(get_xitem_value_as_text(tensor,'d:Mrp','d:value').lower().split("e")[0])*10**(mrp_exp-max_exponent)
                mtp=float(get_xitem_value_as_text(tensor,'d:Mtp','d:value').lower().split("e")[0])*10**(mtp_exp-max_exponent)

                anMom.update({"Mrr" : mrr})
                anMom.update({"Mtt" : mtt})
                anMom.update({"Mpp" : mpp})
                anMom.update({"Mrt" : mrt})
                anMom.update({"Mrp" : mrp})
                anMom.update({"Mtp" : mtp})
                anMom.update({"Mexp" : max_exponent})

        # Find the nodalPlanes section(s) - should only be one!
        nodalplanes=xmom.findall('d:nodalPlanes',ns)
        for thisnodal in nodalplanes:
            nodals=thisnodal.findall('d:nodalPlane1',ns)
            for nodal in nodals:
                anMom.update({"strike1" : get_xitem_value_as_text(nodal,'d:strike','d:value')})
                anMom.update({"dip1" : get_xitem_value_as_text(nodal,'d:dip','d:value')})
                anMom.update({"rake1" : get_xitem_value_as_text(nodal,'d:rake','d:value')})
            nodals=thisnodal.findall('d:nodalPlane2',ns)
            for nodal in nodals:
                anMom.update({"strike2" : get_xitem_value_as_text(nodal,'d:strike','d:value')})
                anMom.update({"dip2" : get_xitem_value_as_text(nodal,'d:dip','d:value')})
                anMom.update({"rake2" : get_xitem_value_as_text(nodal,'d:rake','d:value')})

        # Find the nodalPlanes section(s) - should only be one!
        principalaxes=xmom.findall('d:principalAxes',ns)
        for thisaxis in principalaxes:
            axes=thisaxis.findall('d:tAxis',ns)
            for axis in axes:
                anMom.update({"Taz" : get_xitem_value_as_text(axis,'d:azimuth','d:value')})
                anMom.update({"Tinc" : get_xitem_value_as_text(axis,'d:plunge','d:value')})
                texp=int(get_xitem_value_as_text(axis,'d:length','d:value').lower().split("+")[-1])
                anMom.update({"Tval" : float(get_xitem_value_as_text(axis,'d:length','d:value').lower().split("e")[0])*10**(texp-max_exponent)})
            axes=thisaxis.findall('d:pAxis',ns)
            for axis in axes:
                anMom.update({"Paz" : get_xitem_value_as_text(axis,'d:azimuth','d:value')})
                anMom.update({"Pinc" : get_xitem_value_as_text(axis,'d:plunge','d:value')})
                # anMom.update({"Pval" : get_xitem_value_as_text(axis,'d:length','d:value')})
                pexp=int(get_xitem_value_as_text(axis,'d:length','d:value').lower().split("+")[-1])
                anMom.update({"Pval" : float(get_xitem_value_as_text(axis,'d:length','d:value').lower().split("e")[0])*10**(pexp-max_exponent)})

            axes=thisaxis.findall('d:nAxis',ns)
            for axis in axes:
                anMom.update({"Naz" : get_xitem_value_as_text(axis,'d:azimuth','d:value')})
                anMom.update({"Ninc" : get_xitem_value_as_text(axis,'d:plunge','d:value')})
                # anMom.update({"Nval" : get_xitem_value_as_text(axis,'d:length','d:value')})
                nexp=int(get_xitem_value_as_text(axis,'d:length','d:value').lower().split("+")[-1])
                anMom.update({"Nval" : float(get_xitem_value_as_text(axis,'d:length','d:value').lower().split("e")[0])*10**(nexp-max_exponent)})

        # Append this focal mechanism
        moms.append(anMom)

        # Append the focal mechanism section to the dictionary
    if len(moms) > 0:
        return moms[0]
    else:
        return moms
#
#---------------------------------------------------------------------------------

def list_moment_tensors(moms):
    for mom in moms:
        # print mom
        print "%s %s %s %s %s %s %s %s : %s %s %s %s %s %s : %s %s %s %s %s %s %s %s %s" % (mom['scalarMoment'], mom['Mexp'], mom['Mrr'], mom['Mtt'], mom['Mpp'], mom['Mrt'], mom['Mrp'], mom['Mtp'], mom['strike1'], mom['dip1'], mom['rake1'], mom['strike2'], mom['dip2'], mom['rake2'], mom['Taz'], mom['Tinc'], mom['Tval'], mom['Naz'], mom['Ninc'], mom['Nval'], mom['Paz'], mom['Pinc'], mom['Pval'])

#---------------------------------------------------------------------------------
def list_magnitudes(mags):
    print 'mag\tmagType\tagencyID\tmagnitude\tevaluationMode'
    for mag in mags:
        print "%s\t%s\t%s\t%s\t%s" % (mag['mag'], mag['magType'], mag['agencyID'], mag['originID'], mag['publicID'])

# Output a tectoplot focal mechanism format line
# Column  Data              Units
# ------  ----              -----
# 1.      idcode            A source data letter (G=GCMT, I=ISC, Z=GFZ, etc) and a
#                           EQ type letter (N=Normal, T=Thrust, S=Strike slip)
# 2.      event_code	      Any event ID from the source catalog
# 3.      id	              YYYY-MM-DDTHH:MM:SS time string
# 4.      epoch             (seconds) since Jan 1, 1970
# 5.      lon_centroid	    (deg)
# 6.      lat_centroid	    (deg)
# 7.      depth_centroid	  (km)
# 8.      lon_origin	      (deg)
# 9.      lat_origin	      (deg)
# 10.     depth_origin	    (km)
# 11.     author_centroid	  string    (e.g. GCMT)
# 12.     author_origin	    string    (e.g. NEIC)
# 13.     MW	              number
# 14.     mantissa	        number
# 15.     exponent	        integer
# 16.     strike1	          (deg)
# 17.     dip1	            (deg)
# 18.     rake1	            (deg)
# 19.     strike2	          (deg)
# 20.     dip2	            (deg)
# 21.     rake2	            (deg)
# 22.     exponent	        same as field 15
# 23.     Tval	            number
# 24.     Taz	              (deg) azimuth of T axis
# 25.     Tinc	            (deg) plunge of T axis
# 26.     Nval	            number
# 27.     Naz	              (deg)
# 28.     Ninc	            (deg)
# 29.     Pval	            number
# 30.     Paz	              (deg)
# 31.     Pinc	            (deg)
# 32.     exponent	        same as 15
# 33.     Mrr	              number
# 34.     Mtt	              number
# 35.     Mpp	              number
# 36.     Mrt	              number
# 37.     Mrp	              number
# 38.     Mtp	              number
# 39.     centroid_dt       (seconds)   Time between origin and centroid


def print_focal_tectoplot(e):
    p = '%Y-%m-%dT%H:%M:%S'
    epoch=int(time.mktime(time.strptime(e['origin']['otime'], p)))
    if len(e['focal'])!=0:
        print "%s%s %s%s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s %s" % (
            "U", mechanism_type_from_TNP(float(e['focal']['Tinc']), float(e['focal']['Ninc']), float(e['focal']['Pinc'])),
            e['focal']['agency'], e['eventInfo']['eventid'],
            e['origin']['otime'],
            epoch,
            e['origin']['longitude'],
            e['origin']['latitude'],
            e['origin']['depth'],
            e['origin']['longitude'],
            e['origin']['latitude'],
            e['origin']['depth'],
            e['focal']['agency'],
            e['focal']['agency'],
            e['magnitude']['mag'],
            e['focal']['mantissa'],
            e['focal']['Mexp'],
            e['focal']['strike1'],
            e['focal']['dip1'],
            e['focal']['rake1'],
            e['focal']['strike2'],
            e['focal']['dip2'],
            e['focal']['rake2'],
            e['focal']['Mexp'],
            e['focal']['Tval'],
            e['focal']['Taz'],
            e['focal']['Tinc'],
            e['focal']['Nval'],
            e['focal']['Naz'],
            e['focal']['Ninc'],
            e['focal']['Pval'],
            e['focal']['Paz'],
            e['focal']['Pinc'],
            e['focal']['Mexp'],
            e['focal']['Mrr'],
            e['focal']['Mtt'],
            e['focal']['Mpp'],
            e['focal']['Mrt'],
            e['focal']['Mrp'],
            e['focal']['Mtp'],
            e['focal']['centroid_dt']
            )
#---------------------------------------------------------------------------------
# get the preferred origin from the eventInfo dict and the origins list
#
def get_preferred_origin(eventInfo,origins):
        preforigin = eventInfo['preferredOriginID'].lower().split("/")[-1]
        for origin in origins:
            pID = origin['publicID'].lower().split("/")[-1]
            if(pID == preforigin):
                return origin
#
def get_preferred_magnitude(eventInfo,mags):
        prefmag = eventInfo['preferredMagnitudeID'].lower().split("/")[-1]
        for mag in mags:
            pID = mag['publicID'].lower().split("/")[-1]
            if(pID == prefmag):
                return mag

# name spaces employed at USGS
# need to find a way to parse these from the file.

ns = {"q":"http://quakeml.org/xmlns/quakeml/1.2",
       "d":"http://quakeml.org/xmlns/bed/1.2",
        "catalog":"http://anss.org/xmlns/catalog/0.1",
        "tensor":"http://anss.org/xmlns/tensor/0.1"}

def parse_usgs_xml(event_id_code):
    #
    # you can import xml from online:

    # test if the argument is a file that exists
    if os.path.isfile(event_id_code):
        xtree = ElementTree.parse(event_id_code)
        xroot = xtree.getroot()
    else:
        url = 'https://earthquake.usgs.gov/earthquakes/feed/v1.0/detail/{}.quakeml'.format(event_id_code)
        # print "Getting QuakeML from {}".format(url)
        response = urllib2.urlopen(url)
        xmlstring = response.read()

        if len(xmlstring)==0:
            quit()

        xroot = ElementTree.fromstring(xmlstring)

    xeventParameters = xroot.findall('d:eventParameters',ns)
    for ep in xeventParameters:
        xevents = ep.findall('d:event',ns)
    events = []
    i = 0
    for xev in xevents:
        # build an event dictionary
        ev = {}
        # Get the eventID
        ev['eventid'] = xev.attrib["{http://anss.org/xmlns/catalog/0.1}eventid"]
        ev['publicID'] = xev.attrib['publicID']
        ev['eventsource'] = xev.attrib['{http://anss.org/xmlns/catalog/0.1}eventsource']
        ev['datasource'] = xev.attrib['{http://anss.org/xmlns/catalog/0.1}datasource']
        ev['preferredOriginID'] = xev.find("d:preferredOriginID",ns).text
        ev['preferredMagnitudeID'] = xev.find("d:preferredMagnitudeID",ns).text

        # Get moment tensors - but only one will come out!
        moment_tensors=parse_moment_tensors(xev)

        origins=parse_origins(xev)
        oneorigin=get_preferred_origin(ev,origins)

        # Parse all magnitudes
        mags = parse_magnitudes(xev)
        # Retrieve the preferred magniude
        onemag=get_preferred_magnitude(ev,mags)

        events.append({'eventInfo':ev,'origin':oneorigin,'magnitude':onemag,'focal':moment_tensors})

        i += 1
    return events

if len(sys.argv) > 1:

    events = parse_usgs_xml(sys.argv[1])
    for thisevent in events:
        print_focal_tectoplot(thisevent)

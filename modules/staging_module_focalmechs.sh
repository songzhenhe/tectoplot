staging_module_focalmechs.sh

These are the global variables that are related to focal mechanisms (CMTs)

CMT_MAXMAG
CMT_MINMAG

CMTTYPE (ORIGIN or CENTROID)

How do we handle multiple calls to -c?

-c loads specified datasets

        --->    cmt_1.dat    from first -c call   ->  cmt_normal_1, cmt_thrust_1, cmt_strikeslip_1, etc.
                cmt_2.dat    from second -c call... etc

        ---> combine into cmt.dat (with culling of equivalent events)

Profiles:
    Focal mechanisms are handled in profile.sh by passing of files and symbology commands through sprof.control - so nothing to do there 

Shared options:

-cw, -cmag, etc should apply to ALL focal mechanisms 

Can we specify how modules 

-cslab2 depends on data loaded using -c, -z, -b




-zarea:              download EMSC seismicity within the AOI, do not use scraped datasets


Seismicity functions:

-z 

-z:                  plot seismicity
-zcat:               select seismicity catalog(s) and add custom seismicity files
-zccluster:          decluster seismicity and color by cluster ID rather than depth
-zccpt:              select CPT for seismicity and focal mechanisms
-zctime:             color seismicity by time rather than depth
-zdep:               filter seismicity by depth
-zfill:              color seismicity with a constant fill color
-zline:              set width of seismicity symbol outline line
-zmag:               filter seismicity data by magnitude

Step 1: LOAD DATA and DEFINE SYMBOLOGY

-z 
    cat                       = ANSS ISC EMSC 
    cluster                   = rb 
    cpt                       = seis.cpt
    minm 0                    = 0
    maxm 10                   = 10
    mint 1970-01-01T00:00:00  = 0000-01-01T00:00:00
    maxt 1980-01-01T00:00:00  = $(date -u)
    mind 0                    = -10
    maxd 100                  = 6371
    fill gray                 = ""
    line 0                    = 0.1p,black


Functions that apply to all seismicity datasets
-zcsort:             sort seismicity and focal mechanisms
-zcrescale:          adjust size of seismicity/focal mechanisms by a multiplied factor
-zcfixsize:          earthquake/focal mechanisms have only one specified size
-zcnoscale:          do not adjust scaling of earthquake/focal mechanism symbols


Post-processing functions that can work on all datasets
-zbox:               plot information box about specified earthquake
-zcull:              remove an event based on ID
-zhigh:              highlight a specific earthquake by re-plotting
-zmodifymags:        Convert magnitudes to GCMT Mw equivalent when possible
-znoplot:            process seismicity but don't plot to map
-zproj:              test module for seismicity streaking
-ztext:              plot magnitude or year text over earthquakes
-ztarget:            plot concentric circles around earthquake

-zconland:           select FMS/seismicity with origin epicenter beneath land
-zconsea:            select FMS/seismicity with origin epicenter beneath the sea
-zcolor:             select depth range for color cpt for seismicity

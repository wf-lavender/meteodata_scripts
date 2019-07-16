#!/bin/csh -f

# Download GDAS global observations in burf/prepbufr format.

#setenv TODAY `date +"%Y%m%d"`
#setenv TODAY_JULIAN `date -u +"%Y%j"`
#setenv TODAY_DAYOFWEEK `date -u +"%u"`
setenv YESTERDAY `date +%Y%m%d -d "-1 days"`
# GETTIME must be fit to the GDAS initial time
setenv GETTIME `date -u +%Y%m%d%H -d "-6 hours"`
setenv GDASSTART `echo $GETTIME | cut -c9-10`
setenv TODAY `echo $GETTIME | cut -c1-8`

echo GDASSTART
setenv CLEANDAY `date +%Y%m%d -d "-7 days"`

setenv BASEDATA /data/gdas_obs/

#    setenv TODAY $YESTERDAY
#if ($GDASSTART == 18 || $GDASSTART == 12) then
#    setenv TODAY $YESTERDAY
#endif

#setenv TODAY 20180412
setenv GDASDIR $BASEDATA/${TODAY}${GDASSTART}

# rm -rf ${BASEDATA}/${CLEANDAY}${GDASSTART}


if ( ! -d $GDASDIR ) mkdir -p $GDASDIR

cd $GDASDIR

# GFS URL
set url_dir = ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gdas.${TODAY}/


foreach url_file(gdas.t${GDASSTART}z.1bamua.tm00.bufr_d  gdas.t${GDASSTART}z.1bmhs.tm00.bufr_d  gdas.t${GDASSTART}z.prepbufr.nr gdas.t${GDASSTART}z.1bhrs4.tm00.bufr_d  gdas.t${GDASSTART}z.gpsro.tm00.bufr_d)

# Download GDAS files
echo
echo `date` "Downloading GDAS DATA FCST=${GDASSTART}Z"

wget -t 100 -O ./${url_file} ${url_dir}/${url_file}
set m = $?

set n = 0
while { test ! -s ./${url_file} }
   wget -t 100 -O ./${url_file} ${url_dir}/${url_file}
#   wget -t 0 -O ./${url_file} ${url_dir}/${url_file}  # "-t 0" means infinite retrying
   set m = $?

   sleep 30
   @ n++
   if ( $n > 120 ) then
      echo Time out: `date`
      exit 1
   endif
end

echo $m
while { test ! $m = 0 }
wget -t 100 -c -O ./${url_file} ${url_dir}/${url_file}
set m = $?
end

end

if ($GDASSTART == 18 || $GDASSTART == 06) then
    scp -r -P 11999 ${GDASDIR} wangf@hpc.bj:/data/wangf/gdas_obs/
endif

echo `date` "*** Finished GDAS data download ***"
exit(0)

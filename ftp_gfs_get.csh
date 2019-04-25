#!/bin/csh -fx

# Download GFS global longitude-latitude grid in grib2 format

setenv TODAY `date -u +"%Y%m%d"`
setenv TODAY_JULIAN `date -u +"%Y%j"`
setenv TODAY_DAYOFWEEK `date -u +"%u"`
setenv YESTERDAY `date +%Y%m%d -d "-1 days"`

setenv GFSSTART $1
if $GFSSTART == 18 then
    setenv TODAY $YESTERDAY
endif

setenv CLEANDAY `date +%Y%m%d -d "-10 days"`

# setenv TODAY 20181106
setenv BASEDATA /data/GFS/
setenv GFSDIR $BASEDATA/${TODAY}${GFSSTART}

echo "rm -rf ${BASEDATA}/${CLEANDAY}${GFSSTART}"
rm -rf ${BASEDATA}/${CLEANDAY}${GFSSTART}c

if ( ! -d $GFSDIR ) mkdir -p $GFSDIR

cd $GFSDIR

# GFS URL
if $2 == "cloudhpc" then
    # domestic mirror site, begin synchronization at UTC 03:25, 09:25, 15:25, 21:25
    set url_dir = http://fast.cloudhpc.com.cn/gfs/gfs.${TODAY}${GFSSTART}
else
    set url_dir = ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/prod/gfs.${TODAY}${GFSSTART}
    #set url_dir = ftp://ftpprd.ncep.noaa.gov/pub/data/nccf/com/gfs/para/gfs.${TODAY}${GFSSTART}
endif

# 3.25 days
foreach lead_hour (000 003 006 009 012 015 018 021 024 027 030 033 036 039 042 045 048 051 054 057 060 063 066 069 072 075 078 081 084 087 090 093 096)
# Obtain sufficient data for 5 days forecasting
#foreach lead_hour (000 003 006 009 012 015 018 021 024 027 030 033 036 039 042 045 048 051 054 057 060 063 066 069 072 075 078 081 084 087 090 093 096 099 102 105 108 111 114 117 120)

#foreach lead_hour (000 003 006 009 012 015 018 021 024 027 030 033 036 039 042 045 048 051 054 057 060 063 066 069 072 075 078 081 084 087 090 093 096 099 102 105 108 111 114 117 120 123 126 129 132 135 138 141 144 147 150 153 156 159 162 165 168 171 174 177 180 183 186 189 192 195 198 201 204 207 210 213 216 219 222 225 228 231 234 237 240)

# foreach lead_hour (000 003 006 009 012 015 018 021 024 027 030 033 036 039 042 045 048 051 054 057 060 063 066 069 072 075 078 081 084 087 090 093 096 099 102 105 108 111 114 117 120 123 126 129 132 135 138 141 144 147 150 153 156 159 162 165 168 171 174 177 180 183 186 189 192 195 198 201 204 207 210 213 216 219 222 225 228 231 234 237 240 252 264 276 288 300 312 324 336 348 360 372 384)

# GFS file
# 1.0 degree GFS file identifier: pgrb (pressure-based grib)
#     longitude-latitude grid 360x181 & forecast hour 00-384
#     data format in grib2
#set url_file = gfs.t${GFSSTART}z.pgrbf${lead_hour}.grib2

# 0.5 degree GFS file identifier: pgrb2 (pressure-based grib)
#     longitude-latitude grid 720x361 & forecast hour 00-240
#     data format in grib2
#set url_file = gfs.t${GFSSTART}z.pgrb2f${lead_hour}
 set url_file = gfs.t${GFSSTART}z.pgrb2.0p50.f${lead_hour}

# 0.25 degree GFS files
#set url_file = gfs.t${GFSSTART}z.pgrb2.0p25.f${lead_hour}


# Download GFS files
echo
echo `date` "Downloading GFS DATA FCST=${GFSSTART}Z, Lead=${lead_hour}hr"

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

mv $GFSDIR ${GFSDIR}c
if $GFSSTART == 00 then
    scp -r -P 11999 ${GFSDIR}c wangf@hpc.bj:/data/wangf/gfs_forecast/
endif

echo `date` "*** Finished GFS data download ***"

exit(0)

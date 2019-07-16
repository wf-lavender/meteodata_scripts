#!/bin/csh -fx

# Download HSD full disk data

setenv DATETIME `date -u +"%Y%m%d%H"`

#setenv CLEANDAY `date +%Y%m%d -d "-10 days"`

# setenv DATETIME 2018110100

setenv BASEDATA /data/Himawari-8/HSD/

set YYYYMM=`echo $DATETIME | cut -c 1-6`
set YYYY=`echo $DATETIME | cut -c 1-4`
set DD=`echo $DATETIME | cut -c 7-8`
set HH=`echo $DATETIME | cut -c 9-10`
set mm=00

setenv HSDDIR $BASEDATA/${YYYY}/${DATETIME}

if ( ! -d $HSDDIR ) mkdir -p $HSDDIR
cd $HSDDIR

# GFS URL
set url_dir = ftp://aliwanan_126.com:SP+wari8@ftp.ptree.jaxa.jp/jma/hsd/${YYYYMM}/${DD}/${HH}

foreach band (01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16)

    foreach disk (S0110 S0210 S0310 S0410 S0510 S0610 S0710 S0810 S0910 S1010)

        if ( $band == 03 ) then
            set res=05
        else if ( $band == 01 || $band == 02 || $band == 04 ) then
            set res=10
        else
            set res=20
        endif

        set url_file=HS_H08_${YYYYMM}${DD}_${HH}${mm}_B${band}_FLDK_R${res}_${disk}.DAT.bz2
        wget  ${url_dir}/${url_file}
        sleep 3

    end
end

#if (( $HH == 00 ) || ( $HH == 06 ) || ( $HH == 12 ) || ( $HH == 18 )) then 
#    scp -r -P 11999 ${HSDDIR} wangf@hpc.bj:/data/wangf/Himawari-8/HSD/${YYYY}/
#endif

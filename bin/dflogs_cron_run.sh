#!/bin/bash
inputyear=`date --date="yesterday" +%Y`
inputmonth=`date --date="yesterday" +%m` 
inputday=`date --date="yesterday" +%d`
inputfile='/var/log/'$inputyear'/'$inputmonth'/'$inputday'/messages'
exportpath='/dflogs/data/'$inputyear'/'$inputmonth
exportpathday='/dflogs/data/'$inputyear'/'$inputmonth'/'$inputday
archivepath='/archives/'$inputyear'/'$inputmonth'/'$inputday
#inputfile='/tmp/test'
if [ ! -d $exportpathday ]; then mkdir -p $exportpathday
fi
/dflogs/bin/logparser.pl --daily $exportpathday --monthly $exportpath $inputfile && /dflogs/bin/metaparser.pl --output $exportpath
if [ ! -d $archivepath ]; then mkdir -p $archivepath
fi
gzip $inputfile && mv -v $inputfile.gz $archivepath

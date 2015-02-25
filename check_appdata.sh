#!/bin/bash

if [ -f appdata_tmp ]
then
	rm appdata_tmp
fi

for i in `ls`
do
	find $i -maxdepth 4 -iname "*appdata.xml*" >> appdata_tmp
done

mkdir temp

for j in `cat appdata_tmp`
do
	cp $j temp
done

tar -zcf appdata_files.tar.gz temp/

rm appdata_tmp
rm -rf temp

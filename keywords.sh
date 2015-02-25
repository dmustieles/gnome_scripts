#!/bin/bash

##
# The script desktopfilecheck.py must be in your PATH (i.e. «/usr/local/bin» is a good place for it)
##

RELEASE="gnome-3-8"
DL_URL="https://l10n.gnome.org/languages"
WGET_OPTS="--no-check-certificate -q"

##
# Get all language codes from DL
##

wget -q http://l10n.gnome.org/releases/$RELEASE/ -O temp.html

grep doc temp.html |awk -F "/" {'print $3'} |grep -v ^C$ >>languages

rm temp.html

LINGUAS=`cat languages | tr '\n' ' '`

rm languages

echo $LINGUAS

##
# Get all the UI PO files from Damned-Lies
##

echo

echo -ne "Downloading PO files for: "

for i in `echo $LINGUAS`
do
	echo -ne "\e[1;32m$i \e[0m"
	mkdir $i

	wget $WGET_OPTS $DL_URL/$i/$RELEASE/ui.tar.gz -O $i/$i.tar.gz ; tar -zxf $i/$i.tar.gz -C $i ; rm $i/$i.tar.gz
#	wget $WGET_OPTS $DL_URL/$i/external-deps/ui.tar.gz -O $i/external.tar.gz && tar -zxf $i/external.tar.gz -C $i && rm $i/external.tar.gz
#	wget $WGET_OPTS $DL_URL/$i/gnome-office/ui.tar.gz -O $i/office.tar.gz && tar -zxf $i/office.tar.gz -C $i && rm $i/office.tar.gz
#	wget $WGET_OPTS $DL_URL/$i/gnome-infrastructure/ui.tar.gz -O $i/infraestructure.tar.gz && tar -zxf $i/infraestructure.tar.gz -C $i && rm $i/infraestructure.tar.gz
#	wget $WGET_OPTS $DL_URL/$i/gnome-gimp/ui.tar.gz -O $i/gimp.tar.gz && tar -zxf $i/gimp.tar.gz -C $i && rm $i/gimp.tar.gz
#	wget $WGET_OPTS $DL_URL/$i/gnome-extras/ui.tar.gz -O $i/extras.tar.gz && tar -zxf $i/extras.tar.gz -C $i && rm $i/extras.tar.gz
done

##
# Check PO files with gtxml and create a report file for each language
##
echo -e "\n\nGenerating report..."

for j in `echo $LINGUAS`
do
	ls $j/*.po | xargs desktopfilecheck.py >> $j-report.txt
	rm -rf $j
done

##
# Remove files with zero size (language with no errors) and pack all reports in a .tar.gz file, ready to send to i18n mail list
##
find . -size 0 -exec rm {} \;

tar -zcf keywords-reports.tar.gz *.txt
rm *.txt

echo -e "\nReport generated succesfully. You can find it at\e[1;32m «keywords-reports.tar.gz»\e[0m"


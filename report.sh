#!/bin/bash

# Copyright (C) 2015 Daniel Mustieles, <daniel.mustieles@gmail.com>

#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
#

RELEASE="gnome-3-18"
DL_URL="https://l10n.gnome.org/languages"
WGET_OPTS="wget --no-check-certificate -q"

##
# Get languages list from Damned Lies
##

#wget http://l10n.gnome.org/releases/$RELEASE/ -O temp.html

#grep doc temp.html |awk -F "/" {'print $3'} >>languages

#rm temp.html

#LINGUAS=`cat languages | tr '\n' ' '`

if [ $# -eq 0 ]
then
	LINGUAS="ar bg bn_IN ca cs da de el en_GB es eu fa fi fr gl gu hi hu id it ja ko lv mk nds nl oc pa pl pt pt_BR ro ru sl sr sr@latin sv ta te th tr uk vi zh_CN zh_HK zh_TW"
else
	LINGUAS=$@
fi


##
# Get all the documentation PO file from Damned-Lies, using languages with at least one string in DL
##
for i in `echo $LINGUAS`
do
	echo
	echo -e "Downloading PO files for:\e[1;32m $i \e[0m"
	mkdir $i

	$WGET_OPTS $DL_URL/$i/$RELEASE/doc.tar.gz -O $i/$i.tar.gz ; tar -zxf $i/$i.tar.gz -C $i ; rm $i/$i.tar.gz
	$WGET_OPTS $DL_URL/$i/external-deps/doc.tar.gz -O $i/external.tar.gz && tar -zxf $i/external.tar.gz -C $i && rm $i/external.tar.gz
	$WGET_OPTS $DL_URL/$i/gnome-office/doc.tar.gz -O $i/office.tar.gz && tar -zxf $i/office.tar.gz -C $i && rm $i/office.tar.gz
	$WGET_OPTS $DL_URL/$i/gnome-infrastructure/doc.tar.gz -O $i/infraestructure.tar.gz && tar -zxf $i/infraestructure.tar.gz -C $i && rm $i/infraestructure.tar.gz
	$WGET_OPTS $DL_URL/$i/gnome-gimp/doc.tar.gz -O $i/gimp.tar.gz && tar -zxf $i/gimp.tar.gz -C $i && rm $i/gimp.tar.gz
	$WGET_OPTS $DL_URL/$i/gnome-extras/doc.tar.gz -O $i/extras.tar.gz && tar -zxf $i/extras.tar.gz -C $i && rm $i/extras.tar.gz
done

##
# Check PO files with gtxml and create a report file for each language
##
echo -e "\nGenerating report..."

for j in `echo $LINGUAS`
do
	gtxml $j/*.po >>$j-report.txt
	rm -rf $j

   	##
	# Remove files with zero size (language with no errors) and pack all reports in a .tar.gz file, ready to send to i18n mail list
	##
	find . -size 0 -exec rm {} \;

	##
	# If there is any .txt file it means we've found errors, so report must be generated
	##

	if [ -f $j-report.txt ]
	then
		tar -rf gtxml-doc-reports.tar *.txt
		rm *.txt
	fi
done

gzip gtxml-doc-reports.tar

echo -e "\nThis is the list of the affected languages:"

REP_LIST=`tar -tf gtxml-doc-reports.tar.gz |awk -F '-' {'print $1'}`

echo -e "\e[1;31m$REP_LIST \e[0m\n"

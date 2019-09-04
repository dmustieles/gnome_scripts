#!/bin/bash

# Copyright (C) 2019 Daniel Mustieles, <daniel.mustieles@gmail.com>

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

RELEASE="gnome-3-34"
DL_URL="https://l10n.gnome.org/languages"
WGET_OPTS="wget --no-check-certificate -q"

if [ $# -eq 0 ]
then
	LINGUAS="ar bg bn_IN ca cs da de el en_GB es eu fa fi fr gl gu hi hr hu id it ja ko lv mk nds nl oc pa pl pt pt_BR ro ru sl sr sr@latin sv ta te th tr uk vi zh_CN zh_HK zh_TW"
else
	LINGUAS=$@
fi

# Get all the documentation PO files from Damned-Lies, using languages with at least one string in DL
for i in `echo $LINGUAS`
do
	echo -e "Downloading PO files for:\e[1;32m $i \e[0m"
	mkdir -p $i/core $i/infrastructure $i/gimp $i/gnome-extras $i/gnome-extras-stable

	$WGET_OPTS $DL_URL/$i/$RELEASE/doc.tar.gz -O $i/core/$i.tar.gz ; tar -zxf $i/core/$i.tar.gz -C $i/core ; rm $i/core/$i.tar.gz
	$WGET_OPTS $DL_URL/$i/gnome-infrastructure/doc.tar.gz -O $i/infrastructure/infrastructure.tar.gz && tar -zxf $i/infrastructure/infrastructure.tar.gz -C $i/infrastructure && rm $i/infrastructure/infrastructure.tar.gz
	$WGET_OPTS $DL_URL/$i/gnome-gimp/doc.tar.gz -O $i/gimp/gimp.tar.gz && tar -zxf $i/gimp/gimp.tar.gz -C $i/gimp && rm $i/gimp/gimp.tar.gz
	$WGET_OPTS $DL_URL/$i/gnome-extras/doc.tar.gz -O $i/gnome-extras/extras.tar.gz && tar -zxf $i/gnome-extras/extras.tar.gz -C $i/gnome-extras && rm $i/gnome-extras/extras.tar.gz

	$WGET_OPTS $DL_URL/$i/gnome-extras-stable/doc.tar.gz -O $i/gnome-extras-stable/gnome-extras-stable.tar.gz && tar -zxf $i/gnome-extras-stable/gnome-extras-stable.tar.gz -C $i/gnome-extras-stable && rm $i/gnome-extras-stable/gnome-extras-stable.tar.gz
done


# Check PO files with gtxml and create a report file for each language
echo -e "\nGenerating report..."

for lang in `echo $LINGUAS`
do
	# Remove POT files and folders with only POT files
	find $lang -iname *.pot -exec rm {} \;
	find $lang -type d -empty -exec rm -r {} \; >/dev/null 2>&1

	for moduleset in `ls $lang`
	do
		gtxml $lang/$moduleset/*.po >> $lang/$moduleset-$lang.txt
	done

	rm -rf $lang/core $lang/infrastructure $lang/gimp $lang/gnome-extras $lang/gnome-extras-stable
done

# Remove empty files/folders (language with no errors)
find . -size 0 -exec rm {} \;
find . -type d -empty -exec rm -r {} \; >/dev/null 2>&1

# Pack all reports in a .tar.gz file, ready to send to i18n mail list
for i in `ls -d */`
do
	if [ -n `ls -A $i >/dev/null 2>&1` ]
	then
		tar -rf gtxml-doc-reports.tar $i
		rm -rf $i
	else
		rm -rf $i
	fi
done

gzip gtxml-doc-reports.tar

REP_LIST=`tar -tf gtxml-doc-reports.tar.gz |awk -F '/' {'print $1'} | uniq`

echo -e "\nThis is the list of the affected languages:"
echo -e "\e[1;31m$REP_LIST \e[0m\n"

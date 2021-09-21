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

RELEASE="gnome-41"
DL_URL="https://l10n.gnome.org/languages"
WGET_OPTS="wget --no-check-certificate -q"
REPORTS_DIR="gtxml-doc-reports"

if [ $# -eq 0 ]
then
	LINGUAS="ar bg bn_IN ca cs da de el en_GB es eu fa fi fr gl gu hi hr hu id it ja ko lv mk nds nl oc pa pl pt pt_BR ro ru sl sr sr@latin sv ta te th tr uk vi zh_CN zh_HK zh_TW"
else
	LINGUAS=$@
fi

mkdir $REPORTS_DIR

# Get all the documentation PO files from Damned-Lies, using languages with at least one string in DL
for i in `echo $LINGUAS`
do
	BASE_DIR=$REPORTS_DIR/$i
	echo -e "Downloading PO files for:\e[1;32m $i \e[0m"
	mkdir -p $BASE_DIR/core $BASE_DIR/infrastructure $BASE_DIR/gimp $BASE_DIR/gnome-extras $BASE_DIR/gnome-extras-stable

	$WGET_OPTS $DL_URL/$i/$RELEASE/doc.tar.gz -O $BASE_DIR/core/$i.tar.gz
	tar -zxf $BASE_DIR/core/$i.tar.gz -C $BASE_DIR/core
	rm $BASE_DIR/core/$i.tar.gz

	$WGET_OPTS $DL_URL/$i/gnome-infrastructure/doc.tar.gz -O $BASE_DIR/infrastructure/infrastructure.tar.gz
	tar -zxf $BASE_DIR/infrastructure/infrastructure.tar.gz -C $BASE_DIR/infrastructure
	rm $BASE_DIR/infrastructure/infrastructure.tar.gz

	$WGET_OPTS $DL_URL/$i/gnome-gimp/doc.tar.gz -O $BASE_DIR/gimp/gimp.tar.gz
	tar -zxf $BASE_DIR/gimp/gimp.tar.gz -C $BASE_DIR/gimp
	rm $BASE_DIR/gimp/gimp.tar.gz

	$WGET_OPTS $DL_URL/$i/gnome-extras/doc.tar.gz -O $BASE_DIR/gnome-extras/extras.tar.gz
	tar -zxf $BASE_DIR/gnome-extras/extras.tar.gz -C $BASE_DIR/gnome-extras
	rm $BASE_DIR/gnome-extras/extras.tar.gz

	$WGET_OPTS $DL_URL/$i/gnome-extras-stable/doc.tar.gz -O $BASE_DIR/gnome-extras-stable/gnome-extras-stable.tar.gz
	tar -zxf $BASE_DIR/gnome-extras-stable/gnome-extras-stable.tar.gz -C $BASE_DIR/gnome-extras-stable
	rm $BASE_DIR/gnome-extras-stable/gnome-extras-stable.tar.gz
done


# Check PO files with gtxml and create a report file for each language
echo -e "\nGenerating report..."

for lang in `echo $LINGUAS`
do
	BASE_DIR=$REPORTS_DIR/$lang

	# Remove POT files and folders with only POT files
	find $BASE_DIR -iname *.pot -exec rm {} \;
	find $BASE_DIR -type d -empty -exec rm -r {} \; >/dev/null 2>&1

	for moduleset in `ls $BASE_DIR`
	do
		gtxml $BASE_DIR/$moduleset/*.po >> $BASE_DIR/$moduleset-$lang.txt
	done

	rm -rf $BASE_DIR/core $BASE_DIR/infrastructure $BASE_DIR/gimp $BASE_DIR/gnome-extras $BASE_DIR/gnome-extras-stable
done

# Remove empty files/folders (language with no errors)
find $REPORTS_DIR -size 0 -exec rm {} \;
find $REPORTS_DIR -type d -empty -exec rm -r {} \; >/dev/null 2>&1


# Pack all reports in a .tar.gz file, ready to send to i18n mail list
for i in `ls gtxml-doc-reports`
do
	if [ -n `ls -A $REPORTS_DIR/$i >/dev/null 2>&1` ]
	then
		echo $i >> lang_list
	else
		rm -rf $i
	fi
done


tar zcf gtxml-doc-reports.tar.gz gtxml-doc-reports --exclude report.sh

REP_LIST=`cat lang_list`

echo -e "\nThis is the list of the affected languages:"
echo -e "\e[1;31m$REP_LIST \e[0m\n"

rm -rf gtxml-doc-reports lang_list

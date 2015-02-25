#!/bin/bash

RELEASE="gnome-3-16"
DL_URL="https://l10n.gnome.org/languages/es"
WGET_OPTS="wget --no-check-certificate -q"

if [ ! -d $HOME/mt-files ]
then
	mkdir -p $HOME/mt-files
fi

cd $HOME/mt-files

echo -e "Downloading PO files..."

$WGET_OPTS $DL_URL/$RELEASE/ui.tar.gz -O core-ui.tar.gz; tar -zxf core-ui.tar
$WGET_OPTS $DL_URL/$RELEASE/doc.tar.gz -O core-doc.tar.gz; tar -zxf core-doc.tar.gz; rm core-doc.tar.gz

$WGET_OPTS $DL_URL/external-deps/ui.tar.gz -O external-ui.tar.gz; tar -zxf external-ui.tar.gz; rm external-ui.tar.gz
$WGET_OPTS $DL_URL/external-deps/doc.tar.gz -O external-doc.tar.gz; tar -zxf external-doc.tar.gz; rm external-doc.tar.gz

$WGET_OPTS $DL_URL/gnome-office/ui.tar.gz -O office-ui.tar.gz; tar -zxf office-ui.tar.gz; rm office-ui.tar.gz
$WGET_OPTS $DL_URL/gnome-office/doc.tar.gz -O office-doc.tar.gz; tar -zxf office-doc.tar.gz; rm office-doc.tar.gz

$WGET_OPTS $DL_URL/gnome-infrastructure/ui.tar.gz -O infrastructure-ui.tar.gz; tar -zxf infrastructure-ui.tar.gz; rm infrastructure-ui.tar.gz
$WGET_OPTS $DL_URL/gnome-infrastructure/doc.tar.gz -O infrastructure-doc.tar.gz; tar -zxf infrastructure-doc.tar.gz; rm infrastructure-doc.tar.gz

$WGET_OPTS $DL_URL/gnome-gimp/ui.tar.gz -O gimp-ui.tar.gz; tar -zxf gimp-ui.tar.gz; rm gimp-ui.tar.gz
$WGET_OPTS $DL_URL/gnome-gimp/doc.tar.gz -O gimp-doc.tar.gz; tar -zxf gimp-doc.tar.gz; rm gimp-doc.tar.gz

$WGET_OPTS $DL_URL/gnome-extras/ui.tar.gz -O extras-ui.tar.gz; tar -zxf extras-ui.tar.gz; rm extras-ui.tar.gz
$WGET_OPTS $DL_URL/gnome-extras/doc.tar.gz -O extras-doc.tar.gz; tar -zxf extras-doc.tar.gz; rm extras-doc.tar.gz





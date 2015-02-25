#!/bin/bash

RELEASE="gnome-3-8"

##
# Get all language codes from DL
##

#wget http://l10n.gnome.org/releases/$RELEASE/ -O temp.html

#grep doc temp.html |awk -F "/" {'print $3'} >>languages

#rm temp.html

#LINGUAS=`cat languages | tr '\n' ' '`

#echo $LINGUAS

#rm languages

LINGUAS="es id pl gl el sr sr@latin en_GB zh_TW zh_HK sl fr de pt ru hu pt_BR cs zh_CN it sv bg da ca te uk vi pa lv ko fi ta eu ja hi ro tr nl gu ar mk th fa bn_IN nds oc"
#LINGUAS="es"

##
# Get all the documentation PO file from Damned-Lies, using languages with at least one string in DL
##
for i in `echo $LINGUAS`
do
	echo
	echo -e "Downloading PO files for:\e[1;32m $i \e[0m"
	mkdir $i

	wget -q http://l10n.gnome.org/languages/$i/$RELEASE/doc.tar.gz -O $i/$i.tar.gz && tar -zxf $i/$i.tar.gz -C $i && rm $i/$i.tar.gz
	wget -q http://l10n.gnome.org/languages/$i/external-deps/doc.tar.gz -O $i/external.tar.gz && tar -zxf $i/external.tar.gz -C $i && rm $i/external.tar.gz
	wget -q http://l10n.gnome.org/languages/$i/gnome-office/doc.tar.gz -O $i/office.tar.gz && tar -zxf $i/office.tar.gz -C $i && rm $i/office.tar.gz
	wget -q http://l10n.gnome.org/languages/$i/gnome-infrastructure/doc.tar.gz -O $i/infraestructure.tar.gz && tar -zxf $i/infraestructure.tar.gz -C $i && rm $i/infraestructure.tar.gz
	wget -q http://l10n.gnome.org/languages/$i/gnome-gimp/doc.tar.gz -O $i/gimp.tar.gz && tar -zxf $i/gimp.tar.gz -C $i && rm $i/gimp.tar.gz
	wget -q http://l10n.gnome.org/languages/$i/gnome-extras/doc.tar.gz -O $i/extras.tar.gz && tar -zxf $i/extras.tar.gz -C $i && rm $i/extras.tar.gz
done

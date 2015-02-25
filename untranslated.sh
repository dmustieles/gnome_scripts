#!/bin/bash

# Copyright (C) 2015 Daniel Mustieles <daniel.mustieles@gmail.com>

#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
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


##
# Script para descargar todos los archivos PO sin traducir de los distintos conjuntos de módulos de Damned Lies
##

RELEASE="gnome-3-16"
FOLDER=$HOME/po-files
DL_URL="https://l10n.gnome.org/languages/es"
WGET_OPTS="wget --no-check-certificate -q"

if [ $# -ne 0 ]
then
	if [ ! -d $FOLDER ]
	then
		mkdir -p $FOLDER
	fi

	cd $FOLDER

	echo -e "Descargando archivos PO..."
else
	echo -e "\nDebe especificar al menos una de las siguientes opciones: --core --core-doc --external --external-doc --gimp --gimp-doc --extra --extra-doc\n"
	exit 1
fi

for i in "$@"
do
	case $i in
		--core)
			$WGET_OPTS $DL_URL/$RELEASE/ui.tar.gz -O core-ui.tar.gz; tar -zxf core-ui.tar.gz; rm core-ui.tar.gz
		;;

		--core-doc)
			$WGET_OPTS $DL_URL/$RELEASE/doc.tar.gz -O core-doc.tar.gz; tar -zxf core-doc.tar.gz; rm core-doc.tar.gz
		;;

		--external)
			$WGET_OPTS $DL_URL/external-deps/ui.tar.gz -O external-ui.tar.gz; tar -zxf external-ui.tar.gz; rm external-ui.tar.gz
		;;

		--external-doc)
			$WGET_OPTS $DL_URL/external-deps/doc.tar.gz -O external-doc.tar.gz; tar -zxf external-doc.tar.gz; rm external-doc.tar.gz
		;;

		--gimp)
			$WGET_OPTS $DL_URL/gnome-gimp/ui.tar.gz -O gimp-ui.tar.gz; tar -zxf gimp-ui.tar.gz; rm gimp-ui.tar.gz
		;;

		--gimp-doc)
			$WGET_OPTS $DL_URL/gnome-gimp/doc.tar.gz -O gimp-doc.tar.gz; tar -zxf gimp-doc.tar.gz; rm gimp-doc.tar.gz
		;;

		--extra)
			$WGET_OPTS $DL_URL/gnome-extras/ui.tar.gz -O extras-ui.tar.gz; tar -zxf extras-ui.tar.gz; rm extras-ui.tar.gz
		;;

		--extra-doc)
			$WGET_OPTS $DL_URL/gnome-extras/doc.tar.gz -O extras-doc.tar.gz; tar -zxf extras-doc.tar.gz; rm extras-doc.tar.gz
		;;

		--all)
			$WGET_OPTS $DL_URL/$RELEASE/ui.tar.gz -O core-ui.tar.gz; tar -zxf core-ui.tar.gz; rm core-ui.tar.gz
			$WGET_OPTS $DL_URL/$RELEASE/doc.tar.gz -O core-doc.tar.gz; tar -zxf core-doc.tar.gz; rm core-doc.tar.gz
			$WGET_OPTS $DL_URL/external-deps/ui.tar.gz -O external-ui.tar.gz; tar -zxf external-ui.tar.gz; rm external-ui.tar.gz
			$WGET_OPTS $DL_URL/external-deps/doc.tar.gz -O external-doc.tar.gz; tar -zxf external-doc.tar.gz; rm external-doc.tar.gz
			$WGET_OPTS $DL_URL/gnome-infrastructure/ui.tar.gz -O infrastructure-ui.tar.gz; tar -zxf infrastructure-ui.tar.gz; rm infrastructure-ui.tar.gz
			$WGET_OPTS $DL_URL/gnome-infrastructure/doc.tar.gz -O infrastructure-doc.tar.gz; tar -zxf infrastructure-doc.tar.gz; rm infrastructure-doc.tar.gz
			$WGET_OPTS $DL_URL/gnome-extras/ui.tar.gz -O extras-ui.tar.gz; tar -zxf extras-ui.tar.gz; rm extras-ui.tar.gz
			$WGET_OPTS $DL_URL/gnome-extras/doc.tar.gz -O extras-doc.tar.gz; tar -zxf extras-doc.tar.gz; rm extras-doc.tar.gz
		;;

		*)
			echo "Parámetro $i incorrecto. Especifique uno o varios de --core, --core-doc, --external, --external-doc, --extra, --extra-doc, --all"
	esac
done

for i in `ls *.po`
do
	STR_COUNT=`poselect -u -f -c $i`

	if [ $STR_COUNT -eq 0 ]
	then
		rm $i
	fi
done

exit 0


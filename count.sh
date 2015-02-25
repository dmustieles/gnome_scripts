#!/bin/bash

##
# Script para contar el número de apariciones de archivos es.po en un módulo, sin contar la interfaz.
# Modificando el segundo if, se pueden obtener los que sólo tienen una carpeta de ayuda, los que tienen 2, etc
##






CARPETA_GIT="/home/daniel.mustieles/gnome"

for i in `ls $CARPETA_GIT`
do

if [ -d $i ]
then
	count=`find $CARPETA_GIT/$i -iname "es.po" |egrep -v 'po.*es.po'|wc -l`

	if [ $count -gt 1 ] && [ $count -ne 0 ]
	then
		echo -e "$i: \033[1;31m $count resultados \033[0m"
	fi
fi

done

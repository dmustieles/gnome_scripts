#!/bin/bash


##
# Script para eliminar todas las ramas antiguas de todos los módulos
# descargados y situarse en la rama «master»
##


#Carpeta donde tenemos los clones de git
CARPETA_GIT="/home/daniel.mustieles/gnome"


for i in `ls $CARPETA_GIT`
do
	if [ -d $i ]
	then
		cd $CARPETA_GIT/$i

		#Obtengo el número de ramas descargadas
		NUMERO_RAMAS=`git branch |wc -l`


		if [ "$NUMERO_RAMAS" -gt "1" ]
		then
			#Si hay más de una rama, me sitúo en «master»
			git checkout master >/dev/null 2>&1
			echo -e "\033[1;32m $i \033[0m"

			#Obtengo todas las ramas descargadas, quito el «*» a la rama actual («master») y las elimino
			RAMAS=`git branch |sed 's/\*//'|grep -v master`
			for j in `echo $RAMAS`
			do
				git branch -D $j
				echo
			done
		fi
	cd ..
	fi


done

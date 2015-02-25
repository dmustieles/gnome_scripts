#!/bin/bash

#Carpeta donde estan los archivos .po listos para subir a Git
CARPETA_SUBIR="/home/daniel.mustieles/Escritorio/GNOME/en-revision/subir/"

#Carpeta donde tenemos los clones de git
CARPETA_GIT="/home/daniel.mustieles/gnome"


#Obtenemos los nombres de los modulos que hay que actualizar, en funcion de los archivos .po que tenemos que subir.
#No importa si tenemos nombre.master.po y nombre-help.master.po: solo se actualiza una vez
for i in `ls $CARPETA_SUBIR |awk -F ".master|-help.master" {'print $1'} |uniq`
do
	if [ -d $i ]
	then
		cd $CARPETA_GIT/$i
		echo
		echo -e "Actualizando:\t \033[1;32m $i \033[0m"
		git pull >/dev/null 2>&1
		cd ..
	else
		 echo
		 echo -e "Error:\t\t \033[1;31m $i \033[0m"
	fi
done

echo

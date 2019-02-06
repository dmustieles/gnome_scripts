#!/bin/bash

# Copyright (C) 2012 - 2019 Daniel Mustieles <daniel.mustieles@gmail.com>

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


# Idioma del traductor
GTTK_LANG="es"

# Carpeta donde estan los archivos .po listos para subir a Git
GTTK_UPLOAD="$HOME/Descargas/po-files/subir"
GTTK_GIMP_UPLOAD="$HOME/Descargas/po-files/subir/gimp"

# Carpeta donde tenemos los clones de git
GTTK_GIT_CLONES="$HOME/gnome"
GTTK_GIMP_HELP_FOLDER="$GTTK_GIT_CLONES/gimp-help/po/$GTTK_LANG"

# Carpeta de papelera, para mover los archivo Po ya subido
GTTK_TRASH="$HOME/.local/share/Trash/files/"

# Flag para comprobación de GTXML
GTTK_XML_CHECK="FALSE"

# Flag para la función de registro de errores
GTTK_ERROR="FALSE"

# Variables con nombres de módulos especiales para la documentación
GTTK_GNOME_USER_DOCS="gnome-help system-admin-guide"
GTTK_GNOME_DEVEL_DOCS="accessibility-devel-guide hig integration-guide optimization-guide platform-demos platform-overview programming-guidelines"
GTTK_GNOME_APPLETS="battstat char-palette stickynotes trashapplet accessx-status invest-applet multiload drivemount geyes cpufreq charpick gweather mixer command-line"
GTTK_GNOME_SYSTEM_TOOLS="network users shares services time"
GTTK_GNOME_PANEL="clock fish"


# Actualizar todos los módulos
function UpdateAll {

	for i in `ls $GTTK_GIT_CLONES`
	do
		if [ -d $i ]
		then
			cd $GTTK_GIT_CLONES/$i
			echo -e "Actualizando:\t \e[1;32m $i \e[0m"
			git pull > /dev/null 2>&1
			cd ..
		fi
	done
}


# Documentación de Gimp (gimp-help)
function CommitGimpHelp {

	if [ ! -d $GTTK_GIMP_UPLOAD ]
	then
		echo -e "No hay traducciones de GIMP para subir\n"
		exit 0
	fi

        cd $GTTK_GIT_CLONES/gimp-help
	echo -e "Actualizando:\t \e[1;32m GIMP - help \e[0m"
	git pull > /dev/null 2>&1

        for i in `ls $GTTK_GIMP_UPLOAD`
        do
                unset GIMP_SUBFOLDER
                unset GIMP_SUBNAME
                unset GIMP_MODULE

                COUNT=`echo $i | grep -o '~' | wc -l`

                case $COUNT in
		0)
			# En este caso no existe $GIMP_SUBFOLDER

			GIMP_MODULE=`echo $i | awk -F "." {'print $1'}`
			MODULE_PATH=$GTTK_GIMP_HELP_FOLDER/$GIMP_MODULE.po
		;;

                1)
			GIMP_SUBFOLDER=`echo $i | awk -F "~" {'print $1'}`
			GIMP_MODULE=`echo $i | awk -F "~" {'print $2'} | awk -F "." {'print $1'}`
			MODULE_PATH=$GTTK_GIMP_HELP_FOLDER/$GIMP_SUBFOLDER/$GIMP_MODULE.po
		;;

		2)
			GIMP_SUBFOLDER=`echo $i | awk -F "~" {'print $1"/"$2'}`
			GIMP_MODULE=`echo $i | awk -F "~" {'print $3'} | awk -F "." {'print $1'}`
			MODULE_PATH=$GTTK_GIMP_HELP_FOLDER/$GIMP_SUBFOLDER/$GIMP_MODULE.po
		;;
		esac
                
		diff $GTTK_GIMP_UPLOAD/$i $MODULE_PATH  > /dev/null 2>&1

	        if [ $? -eq 0 ]
        	then
                	echo -e "Error en diff:\t \e[1;31m $GIMP_MODULE \e[0m\n" |tee -a /tmp/gttk_error.log
	                GTTK_ERROR="TRUE"
                	continue
        	else
			echo -e "\e[37m$GIMP_MODULE \e[0m\n"
        	        mv $GTTK_GIMP_UPLOAD/$i $MODULE_PATH
		fi
	done

        git commit -a -m "Updated Spanish translation" > /dev/null 2>&1

	# Si al hacer el commit hay algún error, no hago el push y devuelvo un error
	if [ $? -eq 0 ]
	then
		git push >/dev/null 2>&1

		# Al hacer el push puede dar algún error.
		if [ $? -ne 0 ]
		then
			echo -e "Error en push: \e[1;31m $GIMP_MODULE \e[0m\n" |tee -a /tmp/gttk_error.log
			GTTK_ERROR="TRUE"
		fi
	else
		echo -e "Error en commit: \e[1;31m $GIMP_MODULE \e[0m\n" |tee -a /tmp/gttk_error.log
		GTTK_ERROR="TRUE"
	fi
}

# Cambiar todos los módulos a la rama «master», eliminando el resto de ramas
function ChangeToMasterClean {

	for i in `ls $GTTK_GIT_CLONES`
	do
		if [ -d $i ]
		then
			cd $GTTK_GIT_CLONES/$i

			# Obtengo el número de ramas descargadas
			NUMERO_RAMAS=`git branch |wc -l`

			if [ "$NUMERO_RAMAS" -gt "1" ]
			then
				# Si hay más de una rama, me sitúo en «master»
				git checkout master > /dev/null 2>&1
				echo -e "\e[1;32m $i \e[0m"

				# Obtengo todas las ramas descargadas, quito el «*» a la rama actual («master») y las elimino
				RAMAS=`git branch |sed 's/\*//'|grep -v master`

				for j in `echo $RAMAS`
				do
					git branch -D $j > /dev/null 2>&1
					echo -e "\e[37m $j \e[0m eliminada\n"
				done
			fi
		cd ..

		fi
	done
}


# Función auxiliar para seleccionar la carpeta del módulo. Distingue entre IGU y documentación, así como los casos especiales.
function SelectFolders {

	nombre=`echo $i|awk -F "." {'print $1'}|uniq`

	rama=`echo $i|awk -F "." {'print $2'}|uniq`

	# Miramos primero si el módulo tiene la coletilla «-help» en el nombre. Si la tiene, buscamos la carpeta del módulo a partir del nombre.
	# La variable $nombre viene del bucle de la función CommitPO
	echo $nombre |grep -q "\-help"

	if [ $? -eq 0 ]
	then
		# Si es un módulo de documentación, activamos el flag para realizar posteriormente la comprobación del archivo con gtmxl
		GTTK_XML_CHECK="TRUE"

		# Obtengo el nombre del módulo objetivo
		modulo_help=`echo $nombre| awk -F "-help" {'print $1'}`

		# Primero miro si se trata del módulo gnome-help, que forma parte de gnome-user-docs
		if [ $modulo_help == "gnome" ]
		then
			PO_FOLDER="gnome-user-docs/gnome-help/es/"
			return
		fi

		# Si no existe el módulo, lo clono.
		if [ ! -d $modulo_help ]
		then
			echo -e "Actualizando:\t \e[1;32m $modulo_help \e[0m"
			tput sc
			printf "\e[3m\e[36mDescargando módulo...\e[0m"
			git clone git@gitlab.gnome.org:GNOME/$modulo_help.git >/dev/null 2>&1

			if [ $? -ne 0 ]
			then
				tput rc
				tput el
				echo -e "Error en clone:\t \e[1;31m $modulo_help \e[0m" |tee -a /tmp/gttk_error.log
				GTTK_ERROR="TRUE"
				echo

				PO_FOLDER=""
				return
			fi
			tput rc
			tput el
		fi

		if [ -d $modulo_help ]
		then
			# Si hay varias carpetas, se aborta el proceso, por seguridad.

			# Variable auxiliar para definir el patrón que se debe excluir al contar los archivos PO
			GTTK_PATTERN="po/$GTTK_LANG.po"

			help_count=`find $modulo_help -iname "$GTTK_LANG.po" |egrep -v $GTTK_PATTERN |wc -l`

			if [ $help_count -gt 1 ]
			then
				echo -e "Error en $modulo_help: \e[1;31m Demasiados archivos PO\e[0m" |tee -a /tmp/gttk_error.log
				GTTK_ERROR="TRUE"
			
			else
				# Si sólo hay una carpeta, devuelvo la ruta y puedo subir el archivo
				PO_FOLDER=`dirname $(find $modulo_help -iname "$GTTK_LANG.po" |egrep -v $GTTK_PATTERN) 2>&1`

				if [ $? -eq 1 ]
				then
					# Si dirname falla, salto el módulo y da un error al hacer el commit.
					PO_FOLDER=""
					return
				fi
				return
			fi
		fi	
	else 
	# No tiene la coletilla "-help" en el nombre. Si no es un archivo de la interfaz, es de los casos especiales de documentación

		# Lo primero es suponer que es un archivo de la IGU. Por lo tanto, indico que la carpeta es la del nombre del módulo, y luego verifico si es 
		# de los casos especiales de la documentación.
		#
		# La variable $nombre viene del bucle de la función CommitPO

		PO_FOLDER=$nombre/po

		# Verifico si el módulo es gtk+-properties, ya que aún siendo de la IGU, tiene una carpeta especial
		if [ $nombre == "gtk-properties" ]
                then
                        PO_FOLDER="gtk/po-properties"
                        return
                fi

		# Verifico si el módulo es gnome-web-www, ya que tiene dos submódulos: «static» y «dynamic»
		if [ $nombre == "static" ]
		then
			PO_FOLDER="gnome-web-www/translations/static"
			return
		
		else 
			if [ $nombre == "dynamic" ]
			then
				PO_FOLDER="gnome-web-www/translations/dynamic"
				return
			fi
 		fi


		for modulo_user_docs in $GTTK_GNOME_USER_DOCS
		do
			if [ $modulo_user_docs == $nombre ]
			then
				PO_FOLDER="gnome-user-docs/$modulo_user_docs/es"
				return
			fi
		done

		for modulo_devel_docs in $GTTK_GNOME_DEVEL_DOCS
		do
			if [ $modulo_devel_docs == $nombre ]
			then
				PO_FOLDER="gnome-devel-docs/$modulo_devel_docs/es"
				return
			fi
		done

		for modulo_applets in $GTTK_GNOME_APPLETS
		do
			if [ $modulo_applets == $nombre ]
			then
				PO_FOLDER="gnome-applets/$modulo_applets/docs/es"
				return
			fi
		done


		for modulo_system_tools in $GTTK_GNOME_SYSTEM_TOOLS
		do
			if [ $modulo_system_tools == $nombre ]
			then
				PO_FOLDER="gnome-system-tools/doc/$modulo_system_tools/es"
				return
			fi
		done

		for modulo_panel in $GTTK_GNOME_PANEL
		do
			if [ $modulo_panel == $nombre ]
			then
				PO_FOLDER="gnome-panel/help/$modulo_panel/es"
				return
			fi
		done
	fi
}


# Función para seleccionar la rama correspondiente al módulo
function SelectBranch {

	git pull > /dev/null 2>&1

	# Obtengo la rama activa del módulo descargado, eliminando el asterisco y el espacio
	GTTK_ACTIVE_BRANCH=`git branch |grep "\*" |sed "s/\*\ //g"`

	# Variable auxiliar para indicar si ha habido o no cambio de rama
	GTTK_BRANCH_MODIFIED="FALSE"

	# Verifico si coinciden las ramas. Si no coinciden, descargo la rama correspondiente
	if [ "$GTTK_ACTIVE_BRANCH" != "$rama" ]
	then
		git checkout --track origin/$rama > /dev/null 2>&1
		GTTK_BRANCH_MODIFIED="TRUE"
	fi
}


# Función auxiliar para subir archivos .PO a git (interfaz y documentación). Incluye control de errores.
function UploadModule {

	MODULE_FOLDER=$1
	MODULE_NAME=$2

	# Primero actualizo el módulo, antes de hacer el push
	echo -e "Actualizando:\t \e[1;32m $MODULE_NAME \e[0m(\e[37m$rama\e[0m)"

	# Si no existe la carpeta del módulo, intento descargarla de git. Si no existe en git, devuelve un error y sale de la funcion
	if [ ! -d $MODULE_FOLDER ]
	then
		tput sc
		printf "\e[3m\e[36mDescargando módulo...\e[0m"
		git clone git@gitlab.gnome.org:GNOME/$MODULE_NAME.git > /dev/null 2>&1

		if [ $? -ne 0 ]
		then
			tput rc
			tput el
			echo -e "Error en clone:\t \e[1;31m $MODULE_NAME \e[0m\n" |tee -a /tmp/gttk_error.log
			GTTK_ERROR="TRUE"

			return
		fi
		tput rc
		tput el
	fi

	cd $MODULE_FOLDER

	SelectBranch

	# Antes de hacer el pull, compruebo que los archivos no son iguales, para evitar un error en el commit
	diff $GTTK_UPLOAD/$MODULE_NAME.$rama.$GTTK_LANG.po $MODULE_FOLDER/$GTTK_LANG.po  > /dev/null 2>&1

	if [ $? -eq 0 ]
	then
		echo -e "Error en diff:\t \e[1;31m $MODULE_NAME \e[0m\n" |tee -a /tmp/gttk_error.log
		GTTK_ERROR="TRUE"

		return
	else
		# Compruebo el flag GTTK_XML_CHECK para saber si es un módulo de documentación, para revisar la sintaxis con gtxml.
		# Genero un informe y lo dejo en la carpeta donde están los PO que subir

		# Comprobación desactivada temporalmente para evitar problemas con la línea «translator-credits»
		GTTK_XML_CHECK="FALSE"

		if [ $GTTK_XML_CHECK == "TRUE" ]
		then
			gtxml $GTTK_UPLOAD/$MODULE_NAME.$rama.$GTTK_LANG.po > $GTTK_UPLOAD/$MODULE_NAME-report.txt

			if [ -s $GTTK_UPLOAD/$MODULE_NAME-report.txt ]
                	then
                        	echo -e "Error de gtxml:\t \e[1;31m $MODULE_NAME \e[0m\n" |tee -a /tmp/gttk_error.log
				GTTK_ERROR="TRUE"

                        	return
			else
				rm $GTTK_UPLOAD/$MODULE_NAME-report.txt
                	fi
		fi

		# Copio el archivo .PO en la carpeta /po del módulo correspondiente y me sitúo en esa carpeta para hacer el commit
		
		msgfmt -vc $GTTK_UPLOAD/$MODULE_NAME.$rama.$GTTK_LANG.po -o - > /dev/null 2>&1

		if [ $? -ne 0 ]
		then
			echo -e "Error en msgfmt: \e[1;31m $MODULE_NAME \e[0m\n" |tee -a /tmp/gttk_error.log
			GTTK_ERROR="TRUE"

			return
		fi

		# Compruebo si el archivo PO pasa el test msgfmt antes de hacer el commit, para evitar que el push pueda dar un error
		cp $GTTK_UPLOAD/$MODULE_NAME.$rama.$GTTK_LANG.po $MODULE_FOLDER/$GTTK_LANG.po

		git commit $GTTK_LANG.po -m "Updated Spanish translation" > /dev/null 2>&1
#		head -n1 $MODULE_FOLDER/$GTTK_LANG.po

		# Si al hacer el commit hay algún error, no hago el push y devuelvo un error
		if [ $? -eq 0 ]
		then
			git push >/dev/null 2>&1

			# Al hacer el push puede dar algún error.
			if [ $? -ne 0 ]
			then
				echo -e "Error en push: \e[1;31m $MODULE_NAME \e[0m\n" |tee -a /tmp/gttk_error.log
				GTTK_ERROR="TRUE"
			else
				# Si no hay error en el push, puedo mover el PO original a la papelera
				mv $GTTK_UPLOAD/$MODULE_NAME.$rama.$GTTK_LANG.po $GTTK_TRASH
				
			fi
		else
			echo -e "Error en commit: \e[1;31m $MODULE_NAME \e[0m\n" |tee -a /tmp/gttk_error.log
			GTTK_ERROR="TRUE"
		fi

		# Si se modificó la rama (no era «master»), vuelvo a «master» y elimino la rama descargada
		if [ $GTTK_BRANCH_MODIFIED == "TRUE" ]
		then
			git checkout master >/dev/null 2>&1
			git branch -D $rama >/dev/null 2>&1
		fi
	fi

	cd $GTTK_GIT_CLONES
}


# Función para subir el archivo al repositorio. Primero llama a SelectFolders para averiguar en qué carpeta está el módulo, y luego llama
# a UploadModule para hacer el commit y el push del archivo en git.
function CommitPO {
	if [ -f /tmp/gttk_error.log ]
	then
		rm -f /tmp/gttk_error.log
	fi

	for i in `ls -p $GTTK_UPLOAD | grep -v /`
	do
		SelectFolders

		UploadModule $GTTK_GIT_CLONES/$PO_FOLDER $nombre
	done

	echo

	if [ $GTTK_ERROR == "TRUE" ]
	then
		echo -e "Se han encontrado errores al subir las traducciones. Consulte el informe de error en /tmp/gttk_error.log\n"
	fi
}


#########################################################

echo -e
echo -e "1. Actualizar todos los módulos descargados\n"
echo -e "2. Cambiar todos los módulos a la rama «master», eliminando el resto de ramas\n"
echo -e "3. Subir traducciones de Gimp Help\n"
echo -e "4. Subir traducciones (IGU y documentación) al repositorio\n"
read -p "Opción: " OPCION
echo

case $OPCION in
	# Actualizar todos las módulos
	1 )
		UpdateAll
	;;

	# Cambiar todos los módulos a la rama «master»
	2 )
		ChangeToMasterClean
	;;

	# Subir traducciones de la documentación de GIMP
	3 )
		CommitGimpHelp
	;;

	# Subir archivos .PO de la interfaz (GUI) al repositorio
	4 )
		CommitPO
	;;
esac

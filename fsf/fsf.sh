#!/bin/bash

for i in `cat lista`
do
		echo $i
		cp /home/daniel.mustieles/Escritorio/fsf-patch.sh $i
		cd $i
		chmod +x fsf-patch.sh

		./fsf-patch.sh
		rm fsf-patch.sh

		git commit -a -m "Updated FSF's address"
		git format-patch origin

		mv 0001* /home/daniel.mustieles/Escritorio/fsf/$i-updated-fsf-address.patch
		cd  ..
done

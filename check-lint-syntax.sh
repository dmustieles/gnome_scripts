#!/bin/bash

for i in `find puppet.git/modules -name "*.pp"`
do
	puppet-lint $i > /dev/null 2>&1
	if [ $? -eq 1 ]
	then
		echo $i >> non-compliant-modules.txt
	fi
done

#!/bin/bash

##
# Script to get all unstranslated string from source code files
##

# Patterns to include in the search
INCL1='label.*\(\"'
INCL2='print.*\(\"'

# Patterns to exclude in the search
EXCL1='_('
EXCL2='ngettext'
EXCL3='\(\"\"\)'

egrep -r -e $INCL1 -e $INCL2 $1/* |grep -v -e $EXCL1 -e $EXCL2 -e $EXCL3

#!/bin/bash

# Script to help to identify a .xml or .page containing a tag mismatched in the translated PO file.

# When compiling a GNOME module, maybe you get the following error:
#
#	 Error: Could not merge translations:
#        'NoneType' object has no attribute 'node'
#         make: *** [de/de.stamp] Error 1
#
# This is because there is a mismatched tag in a documentation's PO file. If gtxml doesn't detect it
# you can use this script to know which is the .xml/.page file containing the tag, to help you to identify
# the offending translated string (using the diff between your translation and the previous one will
# reduce the number of strings modified.
#

# Copyright (C) 2013 Daniel Mustieles   <daniel.mustieles@gmail.com>

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



if [ $# -ne 1 ] || [ ! -d $1 ] || [ ! -f $1/$1.po ]
then
  echo -e " \nERROR: Missing parameter\n\n \tUsage: $0 <language>\n"
  echo -e " \t<language> must be a readable folder containing a valid PO file\n"
  exit 1
fi

msgfmt $1/$1.po -o $1/messages.mo

for i in `ls C/*.xml C/*.page`
do
  itstool --strict -m $1/messages.mo -o /dev/null $i >/dev/null 2>&1

  if [ $? -eq 1 ]
  then 
    echo -e "Offending file: \e[1;31m $i \e[0m"
  fi

done

rm $1/messages.mo

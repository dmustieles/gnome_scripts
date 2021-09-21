if [ $# -eq 0 ]
then
  DIR="."
else
  DIR=$1
fi

for i in `ls $DIR/*.po`
do
	STR_COUNT=`poselect -u -f -c $i`

	if [ $STR_COUNT -eq 0 ]
	then
		rm $i
	fi
done

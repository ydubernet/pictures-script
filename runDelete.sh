#!/bin/bash

# list JPG files
echo "Number of JPG files"
find . -maxdepth 1 -iname "*.JPG" | wc -l

# list CR2 files
echo "Number of CR2 files"
find . -maxdepth 1 -iname "*.CR2" | wc -l

echo "Do you want to run script which deletes CR2 files not existing as JPG files ? [y/n]"
read answ_equalization;

if  [ $answ_equalization = "y" -o $answ_equalization = "Y" ];
then
	./script.sh -d
fi

echo "Script runned."

echo "Do you want to run delete of JPG files ? [y/n]"
read answ;

if [ $answ = "y" -o $answ = "Y" ];
then
	find . -maxdepth 1 -iname "*.JPG" -exec rm {} \;
fi

echo "Do you want to remove script files ? [y/n]"
read answ2;

if [ $answ2 = "y" -o $answ2 = "Y" ];
then
	rm *.sh
fi

echo "Do you want to remove logs files ? [y/n]"
read answ3;

if [ $answ3 = "y" -o $answ3 = "Y" ];
then
	rm -r *.txt

	if [ -d log ];
	then
		rm -r log\
	fi
fi



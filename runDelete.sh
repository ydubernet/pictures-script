#!/bin/bash

# list JPG files
echo "Number of JPG files"
ls -l *.JPG | wc -l

# list CR2 files
echo "Number of CR2 files"
ls -l *.CR2 | wc -l

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
	rm *.JPG
fi

echo "Do you want to remove the script file ? [y/n]"
read answ2;

if [ $answ2 = "y" -o $answ2 = "Y" ];
then
	rm script.sh
fi

echo "Do you want to remove logs files ? [y/n]"
read answ3;

if [ $answ3 = "y" -o $answ3 = "Y" ];
then
	rm -r *.txt
fi



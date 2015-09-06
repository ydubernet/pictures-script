#! /bin/bash

# This script is a batch to do batch CR2 to JPG conversion

# © Copyright 2015 - Yoann DUBERNET - yoann [dot] dubernet [ at ] gmail.com

# ############################################## #
#    Date    #            Remark                 #
# 02/09/2015 # First version with basic algorithm#
# 04/09/2015 # Help function                     #
# 06/09/2015 # Managing both with and without    #
#            # input text file for the converter #
#            # function                          #
#            #                                   #
# ############################################## #


# TODO Zone :
# TODO : Implement a recursively converter
# TODO : Implement a default comportment
# TODO : Check if annex softwares are installed
# TODO : Add a verbose option implementation
# TODO : Define commands at the begining of the file so that they could be modified easily (cf. when we'll include reverse option)


#Global variables

#A POSIX variable
OPTIND=1               # Reset in case getopts has been used previously in the shell.

# This value represents the number of files which have already been converted
evol=0

# This value represents the number of files which have to be converted
number_of_files_to_convert=0

# A boolean which will make the converter also work on subfolders if set to true
recursive=0

# A boolean which will ask our tool to be verbose for the user if set to true
verbose=0


# -------------------------------------------------------------------------------------------------------------------------
# Functions :


# This function explains to the user everything he can do with this script
# DO NOT FORGET TO EDIT THE HELP WHEN YOU ADD/REMOVE a tool.
function help_script(){
	echo -e "This script is a little tool to do batch CR2 to JPG format conversion."
	echo -e "Usage : "
	echo -e "Without any argument, will take the current directory and ls *.CR2 as a base for files"
	echo -e "With one argument, will take this input to get CR2 files it will convert"
	echo -e "Options :"
	echo -e "-h : shows you this help"
	echo -e "-r : will convert recursively in subfolders, usefull only in the 0 argument case"
	echo -e "-v : verbose"
}

# This function is the main function of this script. Is manages the batch CR2 to JPG conversion
# If $1 exists, then cat $1 | wc -l
# Else, then cat ls (recursively if asked by the user) | wc -l
# This will give us the number of files which will have to be converted.

# If number_of_files_to_convert > 50, then pop-up a message to prevent the user it's gonna be long.
function convert_CR2_to_JPG(){

	if [ $# -eq 1 ]
	then
		number_of_files_to_convert=`cat $1 | wc -l`
	else
		number_of_files_to_convert=`ls -1 | wc -l`
	fi

	echo "The number of files to convert is : " $number_of_files_to_convert
	echo "Please consider it takes nearly one minute per file."
	echo "Are you sure to start conversion ? [y/n] "
	read answ;

	if [ $answ = "y" -o $answ = "Y" ]; then
		for i in `cat $1`
			do echo "Processing file $i";
			filename=`basename $i .CR2`;
			dcraw -T -w -c $filename.CR2 > $filename.tiff;
			convert $filename.tiff $filename.jpg;
			rm -v $filename.tiff
			echo "Conversion done.";

			let evol=$evol+1
			let progress=(100 * $evol)/number_of_files_to_convert;
			echo "Progress : " $progress "%";	
			echo "";
		done;
	else
		echo "Conversion process cancelled."
	fi
}



# ------------------------------------------------------------------------------------

# script

# First of all, check dcraw and convert softwares are installed
# If not, return and ask admin rights to then install those softwares.

# Then, come back to normal. :)

#extracts option values
while getopts "h?rv" opt; do
    case "$opt" in
    h|\?)
        help_script
        exit 0
        ;;
	r)  recursive=1
		;;
	v)  verbose=1
		;;
    esac
done

shift $((OPTIND-1))


if [ $# -eq 1 ]
then
	convert_CR2_to_JPG $1
else
	convert_CR2_to_JPG
fi








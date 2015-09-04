#! /bin/bash

# This script is a batch to do batch CR2 to JPG conversion

# © Copyright 2015 - Yoann DUBERNET - yoann [dot] dubernet [ at ] gmail.com

# ############################################## #
#    Date    #            Remark                 #
# 02/09/2015 # First version with basic algorithm#
# 04/09/2015 # Help function                     #
#            #                                   #
# ############################################## #


# TODO Zone :
# TODO : Implement a recursively converter
# TODO : Implement a default comportment
# TODO : Check if annex softwares are installed
# TODO : Add a verbose option implementation
# TODO : Make this script work when called by script.sh by reorganising the code order



#Global variables

#A POSIX variable
OPTIND=1               # Reset in case getopts has been used previously in the shell.

# This value represents the number of files whic have already been converted
evol=0

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

# If number_of_files_to_be_converted > 50, then pop-up a message to prevent the user it's gonna be long.
function convert_CR2_to_JPG(){
	for i in $1
		do echo "Processing file $i";
		filename=`basename $i .CR2`;
		dcraw -T -w -c $filename.CR2 > $filename.tiff;
		convert $filename.tiff $filename.jpg;
		rm -v $filename.tiff
		echo "Conversion done";

		let progress=(100 * $evol)/`ls | wc -l`;
		echo "Progress : " $progress "%";
		let evol=$evol+1
		echo "";
	done;

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








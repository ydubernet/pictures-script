#!/bin/bash

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



#Global variables

# This value represents the number of files whic have already been converted
evol=0


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
	echo -e "-r : will convert recursively in subfolders"
}

function convert_CR2_to_JPG() {
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


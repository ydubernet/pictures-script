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
#            # Installation of dcraw and         #
#            # imagemagick                       #
#            #                                   #
# 14/02/2016 # Remove root issue                 #
#            # Correct number_of_files_to_convert#
#            # bug                               #
#            # Change jpg to JPG as output value #
#            # Time warning message only if more #
#            # than 50 pictures to convert       #
# 15/02/2016 # Check for updates if we are root  #
#            # + some doc                        #
# 28/02/2016 # Add libjpg for the cjpg program   #
# ############################################## #


# TODO Zone :
# TODO : Implement a recursively converter
# TODO : Add a verbose option implementation
# TODO : Define commands at the begining of the file so that they could be modified easily (cf. when we'll include reverse option)
# TODO : Add a renaming function (renaming by the date the picture was taken)
# TODO : Add the possibility to directly take into parameters the name of the CR2 files to be converted
# TODO : Solve the issue when the script says it needs an external library but continues to run.

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
	echo -e "If you launch this script with root rights, it will check for third parties software updates including imagemagick"
	echo -e "Options :"
	echo -e "-h : shows you this help"
	echo -e "-r : will convert recursively in subfolders, usefull only in the 0 argument case"
	echo -e "-v : verbose"
}

# This function checks if the current user has root rights
function check_root(){
	if [ `id -u` -ne 0 ] 
	then # Not root
		return 1
	else # Root
		return 0
	fi
}

# This function checks if needed softwares are installed
function check_for_needed_softwares(){
	check_root
	if [ $? -eq 1 ];
	then
		# No root rights. If some softwares are not installed, just inform the user I need root rights to install those softwares.
		command -v convert >/dev/null 2>&1 || echo >&2 "I require imagemagick software but it is not installed. Please restart this script with root rights."
		command -v cjpeg >/dev/null 2>&1 || echo >&2 "I require libjpg-progs library but it is not installed. Please restart this script with root rights."
		command -v exiftool >/dev/null 2>&1 || echo >&2 "I require exiftool library but is is not installed. Please restart this script with root rights."
	else
		# Root rights. If some softwares are not installed, gonna install them.
		command -v convert >/dev/null 2>&1 || echo >&2 "Installing imagemagick..."; apt-get install imagemagick
		command -v cjpeg >/dev/null 2>&1 || echo >&2 "Installing libjpg-progs..."; apt-get install libjpg-progs
		command -v exiftool >/dev/null 2>&1 || echo >&2 "Installing exiftoll..."; apt-get install libimage-exiftool-perl

	fi
}

# This functions checks if needed softwares could be updated
function check_for_updates(){
	check_root
	if [ $? -eq 0 ];
	then
		# Root rights. Let's check if we have some updates on third parties softwares.
		apt-get upgrade imagemagick
		apt-get upgrade libjpg-progs
		apt-get upgrade libimage-exiftool-perl
	fi
}

function rename_by_date(){
	identify -format "%[EXIF:DateTimeOriginal]" "$fichier" | awk -F " " '{print $1}' | awk -F ":" '{print $3"-"$2"-"$1}'

}


# If $1 exists, then cat $1 | wc -l
# Else, then cat ls (recursively if asked by the user) | wc -l
# This will give us the number of files which will have to be converted.
# If number_of_files_to_convert > 50, then pop-up a message to prevent the user it's gonna be long.
# And in all cases, this function calls the main converter function
function convert_CR2_to_JPG(){

	if [ $# -eq 1 ]
	then
		files=`cat $1`
		number_of_files_to_convert=`cat $1 |wc -l`
	else
		#files=`$find . -name "*.CR2"`
		files=`ls -1R *.CR2`
		number_of_files_to_convert=`ls -1R *.CR2 |wc -l`
	fi

	echo "The number of files to convert is : "$number_of_files_to_convert

	if [ $number_of_files_to_convert -ge 50 ]
	then	
		echo "Please consider it takes nearly one minute per file."
		echo "Are you sure to start conversion ? [y/n] "
		read answ;

		if [ $answ = "y" -o $answ = "Y" ]; then
			echo $files
			convert_CR2_to_JPG_core $files
		else
			echo "Conversion process cancelled."
		fi
	else
		convert_CR2_to_JPG_core $files
	fi
}

# This function is the main function of this script. Is manages the batch CR2 to JPG conversion
function convert_CR2_to_JPG_core(){
	
	for i in $@
		do echo "Processing file $i";
		filename=`basename $i .CR2`;
		
		#Version 1
		# dcraw -T -w -c $filename.CR2 > $filename.tiff;
		# convert $filename.tiff $filename.JPG;
		# rm $filename.tiff
		# mv $filename.JPG V1
		
		#Version 2
		# dcraw -T $filename.CR2 > $filename.tiff;
		# convert $filename.tiff $filename.JPG;
		# rm $filename.tiff
		# mv $filename.JPG V2
		
		# Version 3 : the better one when pictures are taken in an outside context
		dcraw -c -q 3 -a -w -H 5 -b 5 $filename.CR2 > $filename.tiff
		cjpeg -quality 95 -optimize -progressive $filename.tiff > $filename.JPG;
		exiftool -overwrite_original -tagsFromFile "$filename.CR2" "$filename.JPG"
		rm $filename.tiff
		
		# Version 4
		# dcraw -t 0 -c -w -o 1 -v -h $filename.CR2 > $filename.tiff
		# cjpeg -quality 95 -optimize -progressive $filename.tiff $filename.JPG
		# rm $filename.tiff
		# mv $filename.JPG V4
		
		# Version 5
		# dcraw -c -q 0 -w -H 5 -b 8 $filename.CR2 > $filename.tiff
		# cjpeg -quality 95 -optimize -progressive $filename.tiff $filename.JPG
		# rm $filename.tiff
		# mv $filename.JPG V5
		
		echo "Conversion done.";

		let evol=$evol+1
		let progress=(100 * $evol)/number_of_files_to_convert;
		echo "Progress : " $progress "%";	
		echo "";
	done;
}

# ------------------------------------------------------------------------------------

# script

# First of all, check imagemagick software is installed
# If not, return and ask admin rights to then install those softwares.
check_for_needed_softwares
if [ ${PIPESTATUS[0]} -eq 1 ];
then
	exit 1;
fi

# Then, check if it exists some upgrades
check_for_updates

# Then, come back to normal. :)
check_root
if [ $? -eq 0 ];
then
	sudo -k # To lose root rights. Otherwise, root will own our files and that might be a mess...
fi

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

# And finally call the CR2 to JPG converter script
if [ $# -eq 1 ]
then
	convert_CR2_to_JPG $1
else
	convert_CR2_to_JPG
fi








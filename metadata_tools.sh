#! /bin/bash

# This script is a batch to deal with pictures metadata

# © Copyright 2016 - Yoann DUBERNET - yoann [dot] dubernet [ at ] gmail.com

# ############################################## #
#    Date    #            Remark                 #
# 09/03/2016 # First version                     #
#            # Help function                     #
# 11/03/2016 # Adding possibility to rename      #
#            # regarding the creation date       #
# 13/03/2016 # Remove the rename functionality   #
# ############################################## #


# TODO Zone :
# TODO : Same way of running than rename_tools

# Global variables :

# -------------------------------------------------------------------------------------------------------------------------
# Functions :


# This function explains to the user everything he can do with this script
# DO NOT FORGET TO EDIT THE HELP WHEN YOU ADD/REMOVE a tool.
function help_script(){
	echo -e "This script is a little tool to do manage your pictures metadata"
	echo -e "Usage : "
	echo -e "With one argument, removes metadata from the filename passed as an argument"
	echo -e "With two arguments, will take this input to get CR2 files it will convert"
	echo -e "If you launch this script with root rights, it will check for third parties software updates including exiftool"
	echo -e "Options :"
	echo -e "-h : shows you this help"
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
		command -v exiftool >/dev/null 2>&1 || echo >&2 "I require exiftool library but is is not installed. Please restart this script with root rights."
	else
		# Root rights. If some softwares are not installed, gonna install them.
		command -v exiftool >/dev/null 2>&1 || echo >&2 "Installing exiftool..."; apt-get install libimage-exiftool-perl
	fi
}

# This functions checks if needed softwares could be updated
function check_for_updates(){
	check_root
	if [ $? -eq 0 ];
	then
		# Root rights. Let's check if we have some updates on third parties softwares.
		apt-get upgrade libimage-exiftool-perl
	fi
}

# ------------------------------------------------------------------------------------

# script

#extracts option values
while getopts "h?" opt; do
    case "$opt" in
    h|\?)
        help_script
        exit 0
        ;;
    esac
done

#shift $((OPTIND-1))


# Call the exiftool library

# First of all, copy or remove metadata
if [ $# -eq 1 ]; then
	# Remove metadata from the considered file
	echo "Removing metadata of $1"
	exiftool -overwrite_original -all= $1
elif [ $# -eq 2 ]; then
	# Copy all metadata from the first parameter to the second parameter
	echo "Copying metadata from $1 to $2"
	exiftool -overwrite_original -tagsFromFile $1 $2
fi




#exiftool -b -PreviewImage -w _preview.jpg -ext cr2 -r . # To extract the JPG preview image of a raw


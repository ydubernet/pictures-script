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
# 14/03/2016 # Possible to remove all metadata   #
#            # if no picture in parameter        #
# ############################################## #


# TODO Zone :
# Solve the bug when trying to remove metadata from a jpg file : also removes them in the _original file

# Global variables :

# A POSIX variable
OPTIND=1               # Reset in case getopts has been used previously in the shell.

# A boolean to know if the script has to rename on subdirectories or not
recursive=0

# Extension of the files which will be renamed
extension=""

# -------------------------------------------------------------------------------------------------------------------------
# Functions :


# This function explains to the user everything he can do with this script
# DO NOT FORGET TO EDIT THE HELP WHEN YOU ADD/REMOVE a tool.
function help_script(){
	echo -e "This script is a little tool to do manage your pictures metadata"
	echo -e "Usage : "
	echo -e "Not any argument : metadata of all the current folder will be removed"
	echo -e "With one argument, removes metadata from the filename passed as an argument"
	echo -e "With two arguments, will take this input to get CR2 files it will convert"
	echo -e "If you launch this script with root rights, it will check for third parties software updates including exiftool"
	echo -e "Options :"
	echo -e "-h : shows you this help"
	echo -e "-r : Remove metadata on the current directory and all its subdirectories (ignored if you give an argument)"
	echo -e "-e : extension : Usefull in order to set the extension of files you want to remove metadata, if many extensions are in the directory or its subdirectories"
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
while getopts "h?re:" opt; do
    case "$opt" in
    h|\?)
        help_script
        exit 0
        ;;
    r)
		recursive=1
		;;
	e)
		extension=$OPTARG
		;;
    esac
done

shift $((OPTIND-1))

options=""

if [ "$extension" != "" ]; then
	options="$options -ext $extension "
fi
if [ $recursive -eq 1 ] && [ $# -eq 0 ]; then
	# Not recursive option if the script is runned for only one picture
	options="$options -r "
fi

# Call the exiftool library
# !!!!!!! NEVER overwrite the original picture when trying to remove metadata !!!!!!!
if [ $# -eq 0 ]; then
	# Remove metadata from all the current folder
	echo "Are you sure you want to delete metadata of all files ? [y/n]"
	read answ;

	if [ $answ = "y" -o $answ = "Y" ]; then
		exiftool $options -all= .
	fi
elif [ $# -eq 1 ]; then
	# Remove metadata from the considered file
	echo "Removing metadata of $1"
	exiftool -all= "$1"
elif [ $# -eq 2 ]; then
	# Copy all metadata from the first parameter to the second parameter
	echo "Copying metadata from $1 to $2"
	exiftool -overwrite_original -tagsFromFile "$1" "$2"
fi

#exiftool -b -PreviewImage -w _preview.jpg -ext cr2 -r . # To extract the JPG preview image of a raw
#! /bin/bash

# This script is a batch to deal with pictures metadata

# © Copyright 2016 - Yoann DUBERNET - yoann [dot] dubernet [ at ] gmail.com

# ############################################## #
#    Date    #            Remark                 #
# 01/03/2016 # First version                     #
#            # Help function                     #
# ############################################## #

# Official documentation : 
#  http://www.sno.phy.queensu.ca/~phil/exiftool/filename.html
#  http://ninedegreesbelow.com/photography/exiftool-commands.html


# TODO Zone :

# Global variables :

# A POSIX variable
OPTIND=1               # Reset in case getopts has been used previously in the shell.

# Default rename format rule
rename_format="%Y-%m-%d_%H-%M-%S_%%f%%-c.%%ue"

# A boolean to know if the script has to rename on subdirectories or not
recursive=0

# Extension of the files which will be renamed
extension=""

# -------------------------------------------------------------------------------------------------------------------------
# Functions :


# This function explains to the user everything he can do with this script
# DO NOT FORGET TO EDIT THE HELP WHEN YOU ADD/REMOVE a tool.
function help_script(){
	echo -e "This script is a little tool to do rename your pictures regarding their metadata"
	echo -e "Usage : "
	echo -e "Not any argument : all the pictures of the current directory will be renamed"
	echo -e "1 Argument : the name of the picture you want to rename"
	echo -e "If you launch this script with root rights, it will check for third parties software updates including exiftool"
	echo -e "Options :"
	echo -e "-h : shows you this help"
	echo -e "-p rename_pattern : Override renaming pattern (see exiftool documentation for more help about available renaming patterns)"
	echo -e "                    The default rename pattern is : $rename_format"
	echo -e "-r : rename on the current directory and all its subdirectories (ignored if you give an argument)"
	echo -e "-e : extension : Usefull in order to set the extension of files you want to rename, if many extensions are in the directory or its subdirectories"
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
while getopts "h?p:re:" opt; do
    case "$opt" in
    h|\?)
        help_script
        exit 0
        ;;
 	p)
		rename_format=$OPTARG
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

echo "Options : " $options

if [ $# -eq 1 ]; then
	#echo "Renaming the file $1 regarding its creation date"
	exiftool '-filename<CreateDate' $options -d $rename_format $1
else
	#echo "Renaming all files in current and subdirectories regarding their creation date"
	exiftool '-filename<CreateDate' $options -d $rename_format .
fi

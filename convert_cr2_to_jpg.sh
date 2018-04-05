#! /bin/bash

# This script is a batch to do batch CR2 to JPG conversion

# © Copyright 2015-2016 - Yoann DUBERNET - yoann [dot] dubernet [ at ] gmail.com

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
# 28/02/2016 # Add libjpeg for the cjpg program  #
#            #                                   #
# 06/03/2016 # Dealing with metadatas by adding  #
#            # possibility to remove them        #
#            #                                   #
# 09/03/2016 # Move metadatas code to a new      #
#            # script in order to make it usable #
#            # without necessarly needing to     #
#            # convert                           #
# 13/03/2016 # Remove any call to a rename script#
#            #                                   #
# 14/03/2016 # Possible to take into parameter   #
#            # names of CR2 files to be converted#
#            # Ignore in the main converter if   #
#            # the input is not a raw file       #
#            #                                   #
# 15/03/2016 # Implement a recursively converter #
#            #                                   #
# 26/04/2016 # No more conversion, just extract  #
#            # the preview image which stays the #
#            # best rendering output             #
#            # Change JPG to jpg                 #
#            # Edit more easily the max number of#
#            # files before displaying the       #
#            # user warning message              #
#            #                                   #
# 28/04/2016 # Solved the issue when a library is#
#            # needed but the script continues to#
#            # run                               #
# 30/04/2016 # Remove the error which happens    #
#            # when launching the script if not  #
#            # any CR2 exist                     #
# 14/05/2016 # Improve treatment with files in   #
#            # subdirectories                    #
#            # + clean code                      #
# 02/04/2017 # Use exiftool instead of convert   #
#            # (issues on Windows 10 for dcraw)  #
# ############################################## #


# TODO Zone :
# TODO : Add an option to set the Author name with exiftool
# TODO : A chown to be sure root does not own output files if runned in root mode ? Or quit the program once installed
# TODO : Make this script work if we take into parameter a file located in a folder which has a space in its name
# TODO : Fix the issue when running the script with pictures to convert located in a subfolder : exports the jpg file in current folder instead of the subfolder it should have been in

# Global variables

# A POSIX variable
OPTIND=1               # Reset in case getopts has been used previously in the shell.

# This value represents the number of files which have already been converted
evol=0

# This value represents the number of files which have to be converted
number_of_files_to_convert=0

# A boolean which will make the converter also work on subfolders if set to true
recursive=0

# An option to launch the metadata script in copy or delete mode
metadata=""

# This value represents the suffix output name of dcraw extract thumbnail image of RAW format
dcraw_thumbnail_suffix=".thumb"

# This value represents the max number of files before we display a warning message to the user regarding the running time it will take
warning_message_number_of_pictures=200

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
	echo -e "[-m c[opy]] : copies metadata of the input CR2 to the output JPG picture (default)"
	echo -e "-m d[elete] : deletes metadata of the output JPG picture"
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
		command -v exiftool >/dev/null 2>&1 || (echo >&2 "I require exiftool library but is is not installed. Please restart this script with root rights." && exit 1;)
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
		apt-get upgrade imagemagick
	fi
}

# If not any argument, converts all the available CR2 files of the current folder
# If arguments : converts the arguments or the listed files in the file in arguement
# If number_of_files_to_convert > 50, then pop-up a message to prevent the user it's gonna be long.
# And in all cases, this function calls the main converter function
function convert_CR2_to_JPG(){
	# In order to be able to run on directories which may have spaces, 
	# we save the IFS value and replace it by the "new line" caracter
	SAVEIFS=$IFS
	IFS=$(echo -en "\n\b")

	if [ $# -eq 0 ]
	then
		# Not any argument : convert all the CR2 pictures present inside the current folder
		if [ $recursive -eq 1 ]; then
			files=`find . -name "*.CR2"`
			number_of_files_to_convert=`find . -name "*.CR2" |wc -l`
		else
			
			files=`ls -1R *.CR2 2> /dev/null`
			number_of_files_to_convert=`ls -1R *.CR2 2> /dev/null|wc -l`
		fi
		
	elif [ $# -eq 1 ]
	then
		if [[ $1 == *.CR2 ]]
		then
			# The parameter is a CR2
			files=$1
			number_of_files_to_convert=1
		else
			# The parameter is the file containing all the files to be converted
			files=`cat $1`
			number_of_files_to_convert=`cat $1 |wc -l`
		fi
	else
		# More than 1 argument : these are the files which have to be converted
		for i in $@
			do 
			files="$files $i"
			let number_of_files_to_convert=number_of_files_to_convert+1
		done;	
	fi

	echo "The number of files to convert is : "$number_of_files_to_convert

	if [ $number_of_files_to_convert -ge $warning_message_number_of_pictures ]
	then	
		echo "Please consider it takes nearly about 3 seconds per file."
		echo "Are you sure to start conversion ? [y/n] "
		read answ;

		if [ $answ = "y" -o $answ = "Y" ]; then
			convert_CR2_to_JPG_core $files
		else
			echo "Conversion process cancelled."
		fi
	else
		convert_CR2_to_JPG_core $files
	fi

	# Put the IFS value back to its normal value
	IFS=$SAVEIFS
}

# This function is the main function of this script. Is manages the batch CR2 to JPG conversion
function convert_CR2_to_JPG_core(){

	for i in $@
		do echo "Processing file $i";

		if [[ $i != *.CR2 ]]; then
			echo "The file $i is not a RAW file. Ignoring it...";
		else
			directory=`dirname $i`
			filename=`basename $i .CR2`;

			# Version 1
			# dcraw -T -w -c $filename.CR2 > $filename.tiff;
			# convert $filename.tiff $filename.jpg;
			
			# Version 2
			# dcraw -T $filename.CR2 > $filename.tiff;
			# convert $filename.tiff $filename.jpg;
			
			# Version 3 : the better one when pictures are taken in an outside context
			# dcraw -c -q 3 -a -w -H 5 -b 5 "$directory/$filename.CR2" > $filename.tiff
			# cjpeg -quality 95 -optimize -progressive $filename.tiff > $filename.jpg;
			# rm $filename.tiff
			
			# Version 4
			# dcraw -t 0 -c -w -o 1 -v -h $filename.CR2 > $filename.tiff
			# cjpeg -quality 95 -optimize -progressive $filename.tiff $filename.jpg
			
			# Version 5
			# dcraw -c -q 0 -w -H 5 -b 8 $filename.CR2 > $filename.tiff
			# cjpeg -quality 95 -optimize -progressive $filename.tiff $filename.jpg
			
			# Version which just extracts the thumbnail image
			#dcraw -e $i
			#mv "$directory/$filename$dcraw_thumbnail_suffix.jpg" "$directory/$filename.jpg" # For 72 files, 3'50
			exiftool -b -PreviewImage $filename.CR2 > $filename.jpg # For 72 files, 4'40

			# And we add metadata management
			if [ "$metadata" == "copy" ] || [ "$metadata" == "c" ] || [ "$metadata" == "" ]
			then
				bash metadata_tools.sh "$directory/$filename.CR2" "$directory/$filename.jpg"
			fi

			if [ "$metadata" == "delete" ] || [ "$metadata" == "d" ]
			then
				bash metadata_tools.sh "$directory/$filename.jpg"
			fi
			
			echo "Conversion done.";
		fi

		let evol=$evol+1
		let progress=(100 * $evol)/number_of_files_to_convert;
		echo "Progress : " $progress "%";	
		echo "";
	done;
}

# ------------------------------------------------------------------------------------

# script

#extracts option values
while getopts "h?rm:" opt; do
    case "$opt" in
    h|\?)
        help_script
        exit 0
        ;;
	r)  
		recursive=1
		;;
	m)  
		metadata=$OPTARG
		;;
    esac
done

shift $((OPTIND-1))

# First of all, check imagemagick software is installed
# If not, return and ask admin rights to then install those softwares.
check_for_needed_softwares
if [ ${PIPESTATUS[0]} -eq 1 ];
then
	exit 1;
fi

# Then, check if it exists some upgrades
check_for_updates

# Then, come back to normal.
check_root
if [ $? -eq 0 ];
then
	sudo -k # To lose root rights. Otherwise, root will own our files and that might be a mess...
fi

# And finally call the CR2 to JPG converter script
convert_CR2_to_JPG $@


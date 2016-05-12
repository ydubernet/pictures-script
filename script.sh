#! /bin/bash

# This script is a tool to manage a lot of files depending on some formats.
# It mainly logs them, but if an option is set, it also can perform write operations such as deletes.

# © Copyright 2014-2015-2016 - Yoann DUBERNET - yoann [dot] dubernet [ at ] gmail.com

# ############################################## #
#    Date    #            Remark                 #
# 31/08/2014 # First version with basic rules    #
# 01/09/2014 # Asking if the user is sure in case#
#            # of deleting process               #
#            # Adding a success counter          #
#            # Adding usage                      #
# 03/09/2014 # Adding a default comportment      #
# 18/08/2015 # Adding a function to extract CR2  #
#            # pictures                          #
# 26/08/2015 # Adding an options parser          #
#            # Avoiding call of look_for_pictures#
#            # if we do not have an input file   #
#            # Possible for the user not to have #
#            # an input file and if so, directly #
#            # ls the content.   				 #
#            # Adding an option to choose which  #
#            # extract function will be used 	 #
#            # (default JPG) 					 #
#            # Removing the without argument     #
#            # show help call                    #
# 30/08/2015 # Making grep work with dashes      #
#            # Simplifying a lot the regex to    #
#            # match any file name               #
#            # Doc the new help function         #
# 02/09/2015 # Renaming options                  #
#            # Generic format extracting type    # 
# 04/09/2015 # Working on CR2 to JPG converter   #
#            # algorithm                         #
# 07/03/2016 # Adding metadata option to call    #
#            # the metadata script               #
# 30/04/2016 # Add the look_for_missing_files    #
#            # method                            #
# 09/05/2016 # Remove the delete option idea     #
# 10/05/2016 # Copy all log files to a log       #
#            # directory                         #
# ############################################## #


# TODO Zone :

# TODO : Permit the user to look for files non recursively
# TODO : Solve the issue with the -i option


# Global variables
# The counter variable counts how many operations succeeded.
counter=0;

# A POSIX variable
OPTIND=1               # Reset in case getopts has been used previously in the shell.

# The files format the user wants to work on
extract_format=""

# The input file the user can set to work on a given content
input_file=""

# The output file from an look_for_files call 
filtered_file="filtered.txt"

# A folder we can set to ignore a subdirectory in the current folder when calling look_for_files
ignored_folder=""

# The output file from a extract_format call
output_file="out.txt"

# The output file from a list_missing_files call
missing_files="missing.txt"

# The input file of a list of files to be deleted
to_delete_file=$missing_files

# A boolean which will generate a call to delete_files function if it is true
delete=0

# A boolean which will make a call to convert CR2 to JPG batch if it is true
convert=0

# An option to launch the metadata script in copy or delete mode
metadata=1

# An option which tells if the scripts saves log files or not
save=1

# -------------------------------------------------------------------------------------------------------------------------
# Functions :

# This function explains to the user everything he can do with this script.
# DO NOT FORGET TO EDIT THE HELP WHEN YOU ADD/REMOVE a tool.
function help_script() {
	echo -e "This script is a little tool to help you gain some time in managing pictures."
	echo -e "Default comportment : this script will grep all jpg files and put them in a out.txt file."
	echo -e "Options :"
	echo -e "-h : shows you this help"
	echo -e "-f extract_format : to set the file format which will be grepped. By default, JPG format." 
	echo -e "-i input_file : if set, will look recursively for the given input files in the current directory and return the existing ones in a filtered.txt file"
	echo -e "-a avoided_folder : if set, -i option has to be set and the script will look for the given input files in the current 
		    directory but ignoring the avoided subdirectory"	
    echo -e "-o output_file : to set another output file name than the default out.txt one"
    echo -e "-c : Will call a script which converts CR2 to JPG files"
    echo -e "-m : Used with -c, will remove metadata from the list of output files"
	echo -e "-d : Will delete the missing file listed content (after asking confirmation, of course). So BE CAREFULL using it."
	echo -e "-s : enable/disable saving log files. You can set the default value by editing this script."
}

# This function deletes all the temporary files before starting the important job.
function delete_temporary_files() {
	if [ -f $filtered_file ]
	then
		rm $filtered_file
	fi

	if [ -f $output_file ]
	then
		rm $output_file
	fi
	
	if [ -f "CR2$output_file" ]
	then
		rm "CR2$output_file"
	fi

	if [ -f $missing_files ]
	then
		rm $missing_files
	fi
}

# This function deletes all files writen in the temporary text file in param
function delete_files() {
	echo "Are you sure you want to delete those files ? [y/n] " ;
	read answ;

	SAVEIFS=$IFS
	IFS=$'\r\n'
	
	if [ $answ = "y" -o $answ = "Y" ]; then
		while read line;
		do
		    echo -e "Trying to delete $line";
			rm $line
			if [ $? -eq 0 ]; then
				counter_plus
				echo "Success in deleting $line";
			else
				echo "Failure in deleting $line";
			fi
		done < $1
		echo -e "Deleting process done.";
		echo -e "$counter files have been deleted.";
	else
		echo -e "Deleting process canceled.";
	fi
	
	IFS=$SAVEIFS
}

# This function increments a global counter which counts the number of actions done.
function counter_plus() {
  let counter=$counter+1;
}

# To extract all the JPG files from a file obtained by a ls -l or a dir on Windows.
# Specific function for JPG format which can be both JPG and JPEG
function extract_JPG_pictures() {
	grep -E -x -i "^.*\.(JPE?G)$" $1 > $2
	echo "`cat $2 | wc -l` JPG file(s) have been grepped in the $2 file.";
}

# To extract all the files with a specified $3 format from a file obtained by a ls -l or a dir on Windows.
function extract_files() {
	grep -E -x -i "^.*\.($3)$" $1 > $2
	echo "`cat $2 | wc -l` $3 file(s) have been grepped in the $2 file.";
}

# We read the input file and look for files from the current folder
# We can exclude a folder
# Then, all found files are put in the filtered file
function look_for_files() {
	while read line;
		do
		if [ $# -eq 3 ]
		then
			find . -name $line | grep -v $3 >> $2; #exclude a folder
		else
			find . -name $line >> $2
		fi
	done < $1

	echo "`cat $2 |wc -l` file(s) grepped in the $1 have been found from the current folder.";
}

# With two arguments base_format and to_check_format,
# Will give the list of files which are not in the base format
# but in the to check format
function list_missing_files()
{
	# In order to be able to run on directories which may have spaces, 
	# we save the IFS value and replace it by the "new line" caracter
	SAVEIFS=$IFS
	IFS=$(echo -en "\n\b")
	
	base_format=$1
	to_check_format=$2
	
	# TODO : add recursive option
	recursive=0
	
	if [ $recursive -eq 1 ]; then
		base_files=`find . -iname "*.$1"`
		to_check_files=`find . -iname "*.$2"`
	else
		base_files=`ls -1R *.$1`
		to_check_files=`ls -1R *.$2`
	fi
	
	found_files=""
	
	for file in $to_check_files
	do
		filename=`basename $file .$2` 
		if [[ $base_files !=  *$filename* ]] # And if we want the ones which exist, we replace != by ==.
                                             # an option could be a nice idea for that
		then
			found_files="$found_files"$'\r\n'"$file"
		fi
	done

	echo "$found_files" >> $3
	number_of_missing_files=`cat $3 | wc -l`
	let number_of_missing_files=$number_of_missing_files-1
	echo "$number_of_missing_files $2 missing file(s) have been grepped in the $3 file.";
	
	# Put the IFS value back to its normal value
	IFS=$SAVEIFS
}

# ------------------------------------------------------------------------------------
# script

#first, we delete temporary files
delete_temporary_files

#extracts option values
while getopts "h?i:f:o:dcms" opt; do
    case "$opt" in
    h|\?)
        help_script
        exit 0
        ;;
    f)
        extract_format=$OPTARG
        ;;
    i)
        input_file=$OPTARG
        ;;
    a)
		ignored_folder=$OPTARG
		;;
	o)
		output_file=$OPTARG
		;;
	d) 
		delete=1
		;;
	c)
		convert=1
		;;
	m)  
        metadata=0
		;;
	s)
		if [ $save -eq 1 ]
		then
			save=0
		elif [ $save -eq 0 ]
		then
			save=1
		fi
    esac
done

shift $((OPTIND-1))

if [ "$input_file" != "" ]
then
	if [ "$ignored_folder" != "" ]
	then
		look_for_files $input_file $filtered_file $ignored_folder
	else
		look_for_files $input_file $filtered_file
	fi
else
	`ls >> "$filtered_file"`
fi


if [ "$extract_format" != "" ]
then
    extract_files $filtered_file $output_file $extract_format
else 
	# default files format type we work on
	# Also default comportment if no option set
	extract_JPG_pictures $filtered_file $output_file
fi

if [ $convert -eq 1 ]
then

	# Deal with converter bash options
	options=""

	if [ $metadata -eq 1 ]
	then 
		# Default : we copy metadata to the generated JPG files
		options="$options -m copy "
	else
		# We remove metadata from the generated JPG files
		options="$options -m remove "
	fi

	if [ -f $output_file ]
	then
		cr2output_file="CR2$output_file" # To avoid overriding previous output file
	fi
	# To make sure the input file contains only CR2 files, we first call extract_files function on CR2 format
	extract_files $filtered_file $cr2output_file "CR2"

	bash convert_cr2_to_jpg.sh $options $cr2output_file
fi

if [ $delete -eq 1 ]
then 
	list_missing_files "jpg" "CR2" $missing_files
	delete_files $to_delete_file
fi

# At the end, save logs files to an appropriated log directory
if [ $save -eq 1 ]
then
	log_directory="log/`date +%Y%m%d_%H%M%S`/"
	mkdir -p $log_directory

	if [ -f $filtered_file ]
	then
		cp $filtered_file $log_directory
	fi
	if [ -f $missing_files ]
	then
		cp $missing_files $log_directory
	fi
	if [ -f $output_file ]
	then
		cp $output_file $log_directory
	fi
	if [ -f "CR2$output_file" ]
	then
		cp "CR2$output_file" $log_directory
	fi
fi

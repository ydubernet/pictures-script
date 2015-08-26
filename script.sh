#! /bin/bash

# This script is set to check in a folder if some pictures given in an input file exist
# if so, the default comportment is to show them on the screen
# The user can param the execution of the script so that instead of showing them on the screen, it deletes them.

# © Copyright 2014-2015 - Yoann DUBERNET - yoann [dot] dubernet [ at ] gmail.com

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
# ############################################## #

# TODO : Solve the space problems so that we could execute this script without renaming all repositories
# TODO : Choose a license
# TODO : Make the grep work for pictures whose name contains dashes
# TODO : Take into parameter the location of the pictures software so that the user could launch the script from everywhere
# TODO : Make this script work with a lot of other formats. After all, we do nt necessarly need to work with pictures, given the commands we use in this script.
# TODO : Test the exclude a folder functionality
# TODO : Fully reimplement the help function


#Global variables
#The counter variable counts how many operations succeeded.
counter=0;

#A POSIX variable
OPTIND=1               # Reset in case getopts has been used previously in the shell.

#The files format the user wants to work on
extract_format=""

#The input file the user can set to work on a given content
input_file=""

#The output file from an look_for_files call 
filtered_file="filtered.txt"

#A folder we can set to ignore a subdirectory in the current folder when calling look_for_files
ignored_folder=""

#The output file from a extract_[PictureFormat]_pictures call
output_file="out.txt"

#A boolean which will generate a call to delete_files function if it is true
delete=0

# -------------------------------------------------------------------------------------------------------------------------
# Functions :

# This function explains to the user everything he can do with.
# DO NOT FORGET TO EDIT THE HELP WHEN YOU ADD/REMOVE a tool.
function help_script(){
	echo -e "This script has been made to help you doing automatically some boring tasks :";
	echo -e "Version 0.1 : looks for all pictures taken into parameter in the current folder,";
	echo -e "              shows them on the Terminal or deletes them if the user want to.";
	echo -e ;
	echo -e "Usage : ";
	echo -e "./script.sh";
	echo -e "Will show you this help.";
	echo -e "./script.sh help";
	echo -e "Will show you this help.";
	echo -e "./script.sh your_input_file";
	echo -e "Will show you on the Terminal if some of the input files exist from the current folder.";
	echo -e "./script.sh your_input_file delete";
	echo -e "Will search from the current folder all the files and delete them (after asking confirmation).";
	echo -e "./script.sh your_input_file folder_name_where_the_script_should_be_executed";
	echo -e "Will move to the input folder and look for the input files.";
	echo -e "./script.sh your_input_file folder_name_where_the_script_should_be_executed delete";
	echo -e "Will move to the input folder and delete all the input files found (after asking confirmation).";
	echo -e "./script.sh your_input_file folder_name_where_the_script_should_be_executed a_non_watching_folder";
	echo -e "Will move to the input folder and look for the input files, except in the non watching repotitory.";
	echo -e "./script.sh your_input_file folder_name_where_the_script_should_be_executed a_non_watching_folder delete";
	echo -e "Will move to the input folder and look for the input files, exception in the non watching folder, and delete them (after asking confirmation).";
}

# This function deletes all the temporary files before starting the important job.
function delete_temporary_files(){
	if [ -f $filtered_file ]
	then
		rm $filtered_file
	fi

	if [ -f $output_file ]
	then
		rm $output_file
	fi
}


# This function deletes all files writen in the temporary text file in param
function delete_files(){
	echo "Are you sure you want to delete those files ? [y/n] " ;
	read answ;

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
}

# This function increments a global counter which counts the number of actions done.
function counter_plus() {
  counter = $counter + 1;
}


# To extract all the JPG files from a file obtained by a ls -l or a dir on Windows.
function extract_JPG_pictures() {
	grep -E -o "[A-Z0-9_]*[\(0-9\)]*.JPE?G|[A-Z0-9_]*[\(0-9\)]*.jpe?g" $1 > $2

	echo "`cat $2 | wc -l` JPG file(s) have been grepped in the $2 file.";
}

# To extract all the CR2 (Canon RAW format) files from a file obtained by a ls -l or a dir on Windows.
function extract_CR2_pictures() {
	grep -E -o "[A-Z0-9_]*[\(0-9\)]*.CR2" $1 > $2

	echo "`cat $2 | wc -l` CR2 file(s) have been grepped in the $2 file.";
}


# We read the input file and look for files from the current folder
# We can exclude a folder
# Then, all found files are put in the filtered file
function look_for_files() {
	while read line;
		do
		#touch $4          # 2015-08-19 : Why this ???
		#echo -e "$line";
		if [ $# -eq 3 ]
		then
			find . -name $line | grep -v $3 >> $2; #exclude a folder ; 2015-08-27 : Bugged
		else
			find . -name $line >> $2
		fi
	done < $1

	echo "`cat $2 |wc -l` file(s) grepped in the $1 have been found from the current folder.";
}




# ------------------------------------------------------------------------------------

# script

#first, we delete temporary files
delete_temporary_files

# Shows the help
#if [ $# -eq 1 -a $1 == "help" ]
#	then
#		help_script
#		exit 0
#fi

#extracts option values
while getopts "h?e:i:f:o:d" opt; do
    case "$opt" in
    h|\?)
        help_script
        exit 0
        ;;
    e)
        extract_format=$OPTARG
        ;;
    f)
        input_file=$OPTARG
        ;;
    i)
		ignored_folder=$OPTARG
		;;
	o)
		output_file=$OPTARG
		;;
	d)  delete=1
		;;
    esac
done

shift $((OPTIND-1)) # TODO : Test

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


if [ "$extract_format" = "CR2" ] || [ "$extract_format" = "cr2" ]
then
    extract_CR2_pictures $filtered_file $output_file
else 
	# default pictures format type we work on
	extract_JPG_pictures $filtered_file $output_file
fi

if [ $delete -eq 1 ]
then 
	delete_files $output_file
fi


#if [ $# -ge 1 ]
#then
#
#	extractJPGPictures $1 edite_out.txt
#fi

#if [ $# -ge 3 ]
#then
#	lookForPictures edite_out.txt a_supprimer.txt $3
#else
#	lookForPictures edite_out.txt a_supprimer.txt
#fi

#if [ $# -eq 2 -a "$2" == "delete" ]
#then
#	delete_files a_supprimer.txt;
#elif [ $# -eq 3 -a "$3" == "delete" ]
#then
#	delete_files a_supprimer.txt;
#elif [ $# -eq 4 -a "$4" == "delete" ]
#then
#	delete_files a_supprimer.txt;
#fi


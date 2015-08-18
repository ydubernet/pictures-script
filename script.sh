#! /bin/bash

# This script is set to check in a repository if some pictures given in an input file exist
# if so, the default comportment is to show them on the screen
# The user can param the execution of the script so that instead of showing them on the screen, it deletes them.

# © Copyright 2014 - Yoann DUBERNET - contact@yoanndubernet.com

# ############################################## #
#    Date    #            Remark                 #
# 31/08/2014 # First version with basic rules    #
# 01/09/2014 # Asking if the user is sure in case#
#            # of deleting process               #
#            # Adding a success counter          #
#            # Adding usage                      #
#            #                                   #
# ############################################## #

# TODO : Solve the space problems so that we could execute this script without renaming all repositories
# TODO : Usage and a default comportment
# TODO : Choose a license
# TODO : Make the grep work for pictures whose name contains dashes
# TODO : Take into parameter the location of the pictures software so that the user could launch the script from everywhere

#Global variables
#The counter variable counts how many operations succeeded.
counter=0;

# -------------------------------------------------------------------------------------------------------------------------
# Functions :

# This function explains to the user everything he can do with.
# DO NOT FORGET TO EDIT THE HELP WHEN YOU ADD/REMOVE a tool.
function help_script(){
	echo -e "This script has been made to help you doing automatically some boring tasks :";
	echo -e "Version 0.1 : looks for all pictures taken into parameter in the current repository,";
	echo -e "              shows them on the Terminal or deletes them if the user want to.";
	echo -e ;
	echo -e "Usage : ";
	echo -e "./script.sh";
	echo -e "Will show you this help.";
	echo -e "./script.sh help";
	echo -e "Will show you this help.";
	echo -e "./script.sh your_input_file";
	echo -e "Will show you on the Terminal if some of the input files exist from the current repository.";
	echo -e "./script.sh your_input_file delete";
	echo -e "Will search from the current repository all the files and delete them (after asking confirmation).";
	echo -e "./script.sh your_input_file repository_name_where_the_script_should_be_executed";
	echo -e "Will move to the input repository and look for the input files.";
	echo -e "./script.sh your_input_file repository_name_where_the_script_should_be_executed delete";
	echo -e "Will move to the input repository and delete all the input files found (after asking confirmation).";
	echo -e "./script.sh your_input_file repository_name_where_the_script_should_be_executed a_non_watching_repository";
	echo -e "Will move to the input repository and look for the input files, except in the non watching repotitory.";
	echo -e "./script.sh your_input_file repository_name_where_the_script_should_be_executed a_non_watching_repository delete";
	echo -e "Will move to the input repository and look for the input files, exception in the non watching repository, and delete them (after asking confirmation).";
}

# This function deletes all the temporary files before starting the important job.
function delete_temporary_files(){
	if [ -f $4 ]
	then
		rm $4
	fi

	if [ -f $2 ]
	then
		rm $2
	fi
}


# This function deletes all files writen in the temporary text file in param
function delete_files(){
	echo "Are you sure you want to delete those files ? [y/n] " ;
	read answ;

	if [ $answ = "y" ]; then
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
function counter_plus(){
  counter = $counter + 1;
}


# ------------------------------------------------------------------------------------

# script
# Shows the help
if [ $# -eq 0 ] 
	then
		help_script
		exit 0
fi

if [ $# -eq 1 -a $1 == "help" ]
	then
		help_script
		exit 0
fi


# We extract all the pictures names from a file obtained by a ls -l or a dir on Windows.
grep -E -o "[A-Z0-9_]*[\(0-9\)]*.JPE?G|[A-Z0-9_]*[\(0-9\)]*.jpe?g" $1 > $2

echo "`cat $2 | wc -l` file(s) have been grepped in the $2 file.";


# We read the file with the pictures names and look for pictures from the current repository
# We can exclude a repository
# Then, all found pictures are put in the file we previously deleted
while read line;
	do
	touch $4
	#echo -e "$line";
	find . -name $line | grep -v $3 >> $4
done < $2

echo "`cat $4 |wc -l` file(s) grepped in the $2 have been found from the current repository.";


delete_files $4


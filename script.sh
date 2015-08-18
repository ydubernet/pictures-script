cd #! /bin/bash

# This script is set to check in a repository if some pictures given in an input file exist
# if so, the default comportment is to show them on the screen
# The user can param the execution of the script so that instead of showing them on the screen, it deletes them.

# © Copyright 2014 - Yoann DUBERNET - contact@yoanndubernet.com

# ############################################## #
#    Date    #            Remark                 #
# 31/08/2014 # First version with basic rules    #
#            #                                   #
#            #                                   #
# ############################################## #

# TODO : Solve the space problems so that we could execute this script without renaming all repositories
# TODO : Asking a confirmation to the user if he decides to delete files
# TODO : Usage and a default comportment
# TODO : Choose a license
# TODO : Make the grep work for pictures whose name contains dashes
# TODO : Take into parameter the location of the pictures software so that the user could launch the script from everywhere

# We extract all the pictures names from a file obtained by a ls -l or a dir on Windows.
grep -E -o "[A-Z0-9_]*[\(0-9\)]*.JPE?G|[A-Z0-9_]*[\(0-9\)]*.jpe?g" $1 > $2

echo "`cat $2 | wc -l` file(s) have been grepped in the $2 file.";

# We delete all the temporary files
if [ -f $4 ]
 then
  rm $4
fi

if [ -f $2 ]
 then
  rm $2
fi

# We read the file with the pictures names and look for pictures from the current repository
# We can exclude a repository
# Then, all found pictures are put in the file we previously deleted
while read line;
 do
   #echo -e "$line";
   find . -name $line | grep -v $3 >> $4
 done < $2

echo "`cat $4 |wc -l` file(s) grepped in the $2 have been found from the current repository.";

# This function deletes all files writen in the temporary text file in param
function delete_files(){
 while read line;
  do
   echo -e "Trying to delete $line";
   rm $line
   if [ $? -eq 0 ]; then
     echo "Success in deleting $line";
   else
     echo "Failure in deleting $line";
   fi
  done < $1
}

delete_files $4



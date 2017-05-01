#!/bin/bash


function help {
	echo -e "This script will extract jpg pictures from their corresponding raw and put them in the folder of your choice."
	echo -e "Usage : ./runExtract.sh [-z] your_input_raw_directory your_output_directory"
	echo -e "Option : -z : will zip the output directory at the end"
}

# Extract jpg from RAW:
echo "Extracting jpg from RAW"
./convert_cr2_to_jpg.sh # or ./script.sh -c

# Get current folder name
input_directory=`basename "$0"`

# Get output folder name
output_directory=$1

# If output directory does not exist, create it
if [ ! -d "$output_directory" ];
then
	echo "Creating the output directory"
	mkdir $output_directory
fi

# Move local jpg outpout to that directory
echo "Moving JPG files to the output directory"
find . -iname "*.jpg" -exec mv {} $output_directory \;

# Option : zip the folder once output jpg directory filed
while getopts ":h:z" opt; do
	case $opt in
		h)
			help
			;;
		z)
			echo "Zipping folder $output_directory"
			zip -r `basename $output_directory` `basename $output_directory`
			echo "Folder zipped."
			;;

	esac
done

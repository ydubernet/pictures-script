#!/bin/bash

for i in `ls *.CR2`
	do echo "Processing file $i";
	filename=`basename $i .CR2`;
	dcraw -T -w -c -v $filename.CR2 > $filename.tiff;
	convert -verbose $filename.tiff $filename.jpg;
	rm -v $filename.tiff
	echo "Conversion done";
	echo "";
done;

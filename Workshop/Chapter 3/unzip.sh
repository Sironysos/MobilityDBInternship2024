#!/bin/bash

#Make sure to have the right arguments
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <path to file to unzip> <path to where you want to move the unzipped files>"
    echo "Example: If you want to unzip files like /home/blob/Downloads/file.tar into the folder /home/blob/Documents/Data/Rennes, you should run $0 /home/blob/Downloads/ /home/blob/Documents/Data/Rennes"
    exit 1
fi

#Use the first argument as the base path
BASEPATH=$1
DIRECTIONPATH=$2

# Unzip the files one by one
for ((i=0; i<=9; i++))
do
    # Specify the path to the downloaded files
    file="${BASEPATH}/states_2020-06-01-0$i.csv.tar"

    # Unzip the file and move it to the new folder
    tar -xf "$file" -C ${DIRECTIONPATH}
done
for ((i=10; i<=23; i++))
do
    # Specify the path to the downloaded files
    file="${BASEPATH}/states_2020-06-01-$i.csv.tar"

    # Unzip the file and move it to the new folder
    tar -xf "$file" -C ${DIRECTIONPATH}
done
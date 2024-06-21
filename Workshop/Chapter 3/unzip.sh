#!/bin/bash

# Create the new folder in the desired location
mkdir -p /home/alice/Documents/Stage/MobilityDBInternship2024/Workshop/Chapter\ 3/stage

# Unzip the files one by one
for ((i=1; i<=24; i++))
do
    # Specify the path to the downloaded files
    file="/home/alice/Downloads/file$i.zip"

    # Unzip the file and move it to the new folder
    unzip "$file" -d /home/alice/Documents/Stage/MobilityDBInternship2024/Workshop/Chapter\ 3/stage
done
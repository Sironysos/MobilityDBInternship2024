#!/bin/bash

# Unzip the files one by one
for ((i=0; i<=9; i++))
do
    # Specify the path to the downloaded files
    file="/home/alice/Downloads/states_2020-06-01-0$i.csv.tar"

    # Unzip the file and move it to the new folder
    tar -xf "$file" -C /home/alice/Documents/Stage/Opensky
done
for ((i=10; i<=23; i++))
do
    # Specify the path to the downloaded files
    file="/home/alice/Downloads/states_2020-06-01-$i.csv.tar"

    # Unzip the file and move it to the new folder
    tar -xf "$file" -C /home/alice/Documents/Stage/Opensky
done
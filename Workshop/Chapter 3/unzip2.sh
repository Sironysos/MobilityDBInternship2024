#!/bin/bash

#!/bin/bash

#Make sure to have the right arguments
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path to files to unzip>"
    echo "Example: If you want to unzip files like /home/blob/Documents/Data/Rennes, you should run $0 /home/blob/Documents/Data/Rennes"
    exit 1
fi

#Use the first argument as the base path
BASEPATH=$1

gunzip ${BASEPATH}/*.gz

#!/bin/bash

#Make sure to have the right arguments
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path>"
    echo "Example: If you want to copy files like /home/blob/Documents/Data/Rennes/agency.txt, you should run $0 /home/blob/Documents/Data/Rennes"
    exit 1
fi

#Use the first argument as the base path
BASEPATH=$1

for ((i=0; i<=9; i++))
do
    psql -d opensky -c "\copy flights(et, icao24, lat, lon, velocity, heading,vertrate, callsign, onground, alert, spi, squawk,baroaltitude, geoaltitude, lastposupdate, lastcontact) FROM '${BASEPATH}/states_2020-06-01-0$i.csv' DELIMITER  ',' CSV HEADER;"
done
for ((i=10; i<=23; i++))
do
    psql -d opensky -c "\copy flights(et, icao24, lat, lon, velocity, heading,vertrate, callsign, onground, alert, spi, squawk,baroaltitude, geoaltitude, lastposupdate, lastcontact) FROM '${BASEPATH}/states_2020-06-01-$i.csv' DELIMITER  ',' CSV HEADER;"
done
#!/bin/bash
for ((i=0; i<=9; i++))
do
    psql -d opensky -c "\copy flights(et, icao24, lat, lon, velocity, heading,vertrate, callsign, onground, alert, spi, squawk,baroaltitude, geoaltitude, lastposupdate, lastcontact) FROM '/home/alice/Documents/Stage/Opensky/states_2020-06-01-0$i.csv' DELIMITER  ',' CSV HEADER;"
done
for ((i=10; i<=23; i++))
do
    psql -d opensky -c "\copy flights(et, icao24, lat, lon, velocity, heading,vertrate, callsign, onground, alert, spi, squawk,baroaltitude, geoaltitude, lastposupdate, lastcontact) FROM '/home/alice/Documents/Stage/Opensky/states_2020-06-01-$i.csv' DELIMITER  ',' CSV HEADER;"
done
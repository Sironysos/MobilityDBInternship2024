#!/bin/bash

#Make sure to have the right arguments
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path to files to copy>"
    echo "Example: If you want to copy files like /home/blob/Documents/Data/Rennes, you should run $0 /home/blob/Documents/Data/Rennes"
    exit 1
fi

#Use the first argument as the base path
BASEPATH=$1

psql -d stib -c "\copy calendar(service_id,monday,tuesday,wednesday,thursday,friday,saturday,sunday, start_date,end_date) FROM '${BASEPATH}/calendar.txt' DELIMITER ',' CSV HEADER;"

psql -d stib -c "\copy calendar_dates(service_id,date,exception_type) FROM '${BASEPATH}/calendar_dates.txt' DELIMITER ',' CSV HEADER;"

psql -d stib -c "\copy stop_times(trip_id,arrival_time,departure_time,stop_id,stop_sequence, pickup_type,drop_off_type) FROM '${BASEPATH}/stop_times.txt' DELIMITER ',' CSV HEADER;"

psql -d stib -c "\copy trips(route_id,service_id,trip_id,trip_headsign,direction_id,block_id,shape_id) FROM '${BASEPATH}/trips.txt' DELIMITER ',' CSV HEADER;"

psql -d stib -c "\copy agency(agency_id,agency_name,agency_url,agency_timezone,agency_lang,agency_phone) FROM '${BASEPATH}/agency.txt' DELIMITER ',' CSV HEADER;"

psql -d stib -c "\copy routes(route_id,route_short_name,route_long_name,route_desc,route_type,route_url, route_color,route_text_color) FROM '${BASEPATH}/routes.txt' DELIMITER ',' CSV HEADER;"

psql -d stib -c "\copy shapes(shape_id,shape_pt_lat,shape_pt_lon,shape_pt_sequence, shape_dist_traveled) FROM '${BASEPATH}/shapes.txt' DELIMITER ',' CSV HEADER;"

psql -d stib -c "\copy stops(stop_id,stop_code,stop_name,stop_desc,stop_lat,stop_lon,zone_id,stop_url, location_type,parent_station) FROM '${BASEPATH}/stops.txt' DELIMITER ',' CSV HEADER;"
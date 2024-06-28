#!/bin/bash

#Make sure to have the right arguments
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path>"
    echo "Example: If you want to copy files like /home/blob/Documents/Data/Rennes/agency.txt, you should run $0 /home/blob/Documents/Data/Rennes"
    exit 1
fi

# Use the first argument as the base path
BASEPATH=$1

psql -d star -c "\copy agency(agency_id,agency_name,agency_url,agency_timezone,agency_lang,agency_phone, agency_fare_url, agency_email) FROM '${BASEPATH}/agency.txt' DELIMITER ',' CSV HEADER;"

psql -d star -c "\copy calendar(service_id,monday,tuesday,wednesday,thursday,friday,saturday,sunday, start_date,end_date) FROM '${BASEPATH}/calendar.txt' DELIMITER ',' CSV HEADER;"

psql -d star -c "\copy calendar_dates(service_id,date,exception_type) FROM '${BASEPATH}/calendar_dates.txt' DELIMITER ',' CSV HEADER;"

psql -d star -c "\copy fare_attributes(agency_id, fare_id, price, currency_type, payment_method, transfers, transfer_duration) FROM '${BASEPATH}/fare_attributes.txt' DELIMITER ',' CSV HEADER;"

psql -d star -c "\copy feed_info(feed_publisher_name,feed_publisher_url,feed_lang,feed_start_date,feed_end_date,feed_version, feed_contact_email, feed_contact_url) FROM '${BASEPATH}/feed_info.txt' DELIMITER ',' CSV HEADER;"

psql -d star -c "\copy routes(route_id,agency_id, route_short_name,route_long_name,route_desc,route_type,route_url, route_color,route_text_color, route_sort_order) FROM '${BASEPATH}/routes.txt' DELIMITER ',' CSV HEADER;"

psql -d star -c "\copy shapes(shape_id,shape_pt_lat,shape_pt_lon,shape_pt_sequence, shape_dist_traveled) FROM '${BASEPATH}/shapes.txt' DELIMITER ',' CSV HEADER;"

psql -d star -c "\copy stops(stop_id,stop_code,stop_name,stop_desc,stop_lat,stop_lon,zone_id,stop_url, location_type,parent_station,wheelchair_boarding,platform_code,stop_timezone) FROM '${BASEPATH}/stops.txt' DELIMITER ',' CSV HEADER;"

psql -d star -c "\copy stop_times(trip_id,arrival_time,departure_time,stop_id,stop_sequence,stop_headsign,pickup_type,drop_off_type,shape_dist_traveled,timepoint) FROM '${BASEPATH}/stop_times.txt' DELIMITER ',' CSV HEADER;"

psql -d star -c "\copy trips(route_id,service_id,trip_id,trip_headsign,trip_short_name,direction_id,block_id,shape_id,wheelchair_accessible,bikes_allowed) FROM '${BASEPATH}/trips.txt' DELIMITER ',' CSV HEADER;"

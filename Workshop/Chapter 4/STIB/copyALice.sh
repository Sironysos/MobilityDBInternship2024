#!/bin/bash

psql -d stib -c "\copy calendar(service_id,monday,tuesday,wednesday,thursday,friday,saturday,sunday, start_date,end_date) FROM '/home/alice/Documents/Stage/MobilityDBInternship2024/Workshop/Chapter 4/STIB/calendar.txt' DELIMITER ',' CSV HEADER;"

psql -d stib -c "\copy calendar_dates(service_id,date,exception_type) FROM '/home/alice/Documents/Stage/MobilityDBInternship2024/Workshop/Chapter 4/STIB/calendar_dates.txt' DELIMITER ',' CSV HEADER;"

psql -d stib -c "\copy stop_times(trip_id,arrival_time,departure_time,stop_id,stop_sequence, pickup_type,drop_off_type) FROM '/home/alice/Documents/Stage/MobilityDBInternship2024/Workshop/Chapter 4/STIB/stop_times.txt' DELIMITER ',' CSV HEADER;"

psql -d stib -c "\copy trips(route_id,service_id,trip_id,trip_headsign,direction_id,block_id,shape_id) FROM '/home/alice/Documents/Stage/MobilityDBInternship2024/Workshop/Chapter 4/STIB/trips.txt' DELIMITER ',' CSV HEADER;"

psql -d stib -c "\copy agency(agency_id,agency_name,agency_url,agency_timezone,agency_lang,agency_phone) FROM '/home/alice/Documents/Stage/MobilityDBInternship2024/Workshop/Chapter 4/STIB/agency.txt' DELIMITER ',' CSV HEADER;"

psql -d stib -c "\copy routes(route_id,route_short_name,route_long_name,route_desc,route_type,route_url, route_color,route_text_color) FROM '/home/alice/Documents/Stage/MobilityDBInternship2024/Workshop/Chapter 4/STIB/routes.txt' DELIMITER ',' CSV HEADER;"

psql -d stib -c "\copy shapes(shape_id,shape_pt_lat,shape_pt_lon,shape_pt_sequence, shape_dist_traveled) FROM '/home/alice/Documents/Stage/MobilityDBInternship2024/Workshop/Chapter 4/STIB/shapes.txt' DELIMITER ',' CSV HEADER;"

psql -d stib -c "\copy stops(stop_id,stop_code,stop_name,stop_desc,stop_lat,stop_lon,zone_id,stop_url, location_type,parent_station) FROM '/home/alice/Documents/Stage/MobilityDBInternship2024/Workshop/Chapter 4/STIB/stops.txt' DELIMITER ',' CSV HEADER;"
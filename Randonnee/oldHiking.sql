DROP EXTENSION IF EXISTS mobilitydb CASCADE;
CREATE EXTENSION mobilityDB CASCADE;

DROP TABLE IF EXISTS trips_input;
CREATE TABLE trips_input (
	id int,
	lon float,
	lat float,
	time timestamptz
);

INSERT INTO trips_input VALUES
(0,NULL,NULL,NULL);


-- Here you need to import each trip file separatly. 
-- This allows you to put a different ID on each trip, because if you import all of them at the same time it becomes difficult to tell apart the trips from one another.

-- First run the following SQL command (you need to change the name of the file you want to import and the path to it)
COPY trips_input(lon, lat, time) FROM
'/home/gpx_data/example.csv' DELIMITER ',' CSV HEADER;

-- Do the above or run the command below in a terminal if you have a permission error
-- (you need to change the name of the database, and the name and path to the file you want to import)
-- psql -d DataBaseName -c "\copy trips_input(lon, lat, time) FROM '/home/gpx_data/exemple.csv' DELIMITER ',' CSV HEADER;"

-- Then run this command to update the ID
WITH max_id_cte AS (
    SELECT MAX(id)+1 AS max_id FROM trips_input
),
rows_to_update AS (
    SELECT id, (SELECT max_id FROM max_id_cte) AS new_id
    FROM trips_input
    WHERE id IS NULL
)
UPDATE trips_input SET id = rows_to_update.new_id
FROM rows_to_update
WHERE trips_input.id IS NULL;

-- Now you can repeat the last two steps for each trip file you want to import. Don’t forget to change the name of the file each time!


DROP TABLE IF EXISTS trips_mdb;
CREATE TABLE trips_mdb (
	id int,
	date date,
	trip tgeompoint,
	trajectory geometry,
	PRIMARY KEY (id)
);

INSERT INTO trips_mdb(id, date, trip)
SELECT id, date(time), tgeompointSeq(array_agg(tgeompoint(
  ST_SetSRID(ST_Point(lon, lat), 4326), time) ORDER BY time))
FROM trips_input
WHERE id != 0
GROUP BY id, date;

UPDATE trips_mdb
SET trajectory = trajectory(trip);
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


-- COPY trips_input(lon, lat, time) FROM
-- '/home/gpx_data/example.csv' DELIMITER ',' CSV HEADER;

-- Do the above or run the below in a terminal
-- psql -d Randonnee -c "\copy trips_input(lon, lat, time) FROM '/home/gpx_data/exemple.csv' DELIMITER ',' CSV HEADER;"


WITH max_id_cte AS (
    SELECT MAX(id)+1 AS max_id FROM trips_input
),
rows_to_update AS (
    SELECT
        id,
        (SELECT max_id FROM max_id_cte) AS new_id
    FROM trips_input
    WHERE id IS NULL
)
UPDATE trips_input
SET id = rows_to_update.new_id
FROM rows_to_update
WHERE trips_input.id IS NULL;

select * from trips_input;

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

select * from trips_mdb;
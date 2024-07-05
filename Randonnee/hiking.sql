DROP EXTENSION IF EXISTS mobilitydb CASCADE;
CREATE EXTENSION mobilityDB CASCADE;

DROP TABLE IF EXISTS trips_input;
CREATE TABLE trips_input (
	date date,
	lon float,
	lat float,
	time timestamptz
);

COPY trips_input(lon, lat, time) FROM
'/home/gpx_data/example.csv' DELIMITER ',' CSV HEADER;

UPDATE trips_input
SET date = date(time);

DROP TABLE IF EXISTS trips_mdb;
CREATE TABLE trips_mdb (
	date date NOT NULL,
	trip tgeompoint,
	trajectory geometry,
	PRIMARY KEY (date)
);

INSERT INTO trips_mdb(date, trip)
SELECT date, tgeompoint_seq(array_agg(tgeompoint_inst(
  ST_SetSRID(ST_Point(lon, lat), 4326), time) ORDER BY time))
FROM trips_input
GROUP BY date;

UPDATE trips_mdb
SET trajectory = trajectory(trip);
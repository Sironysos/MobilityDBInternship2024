DROP EXTENSION IF EXISTS mobilitydb CASCADE;
CREATE EXTENSION mobilityDB CASCADE;

DROP TABLE IF EXISTS agency CASCADE;
CREATE TABLE agency (
  agency_id text DEFAULT '',
  agency_name text DEFAULT NULL,
  agency_url text DEFAULT NULL,
  agency_timezone text DEFAULT NULL,
  agency_lang text DEFAULT NULL,
  agency_phone text DEFAULT NULL,
  agency_fare_url text DEFAULT NULL,
  agency_email text DEFAULT NULL,
  CONSTRAINT agency_pkey PRIMARY KEY (agency_id)
);

DROP TABLE IF EXISTS calendar CASCADE;
CREATE TABLE calendar (
  service_id text,
  monday int NOT NULL,
  tuesday int NOT NULL,
  wednesday int NOT NULL,
  thursday int NOT NULL,
  friday int NOT NULL,
  saturday int NOT NULL,
  sunday int NOT NULL,
  start_date date NOT NULL,
  end_date date NOT NULL,
  CONSTRAINT calendar_pkey PRIMARY KEY (service_id)
);
DROP INDEX IF EXISTS calendar_service_id;
CREATE INDEX calendar_service_id ON calendar (service_id);

DROP TABLE IF EXISTS exception_types CASCADE;
CREATE TABLE exception_types (
  exception_type int PRIMARY KEY,
  description text
);

DROP TABLE IF EXISTS calendar_dates CASCADE;
CREATE TABLE calendar_dates (
  service_id text,
  date date NOT NULL,
  exception_type int REFERENCES exception_types(exception_type)
);
DROP INDEX IF EXISTS calendar_dates_service_id;
CREATE INDEX calendar_dates_dateidx ON calendar_dates (date);

DROP TABLE IF EXISTS fare_attributes CASCADE;
CREATE TABLE fare_attributes (
  agency_id int,
  fare_id int,
  price double precision CHECK (price >= 0),
  currency_type text,
  payment_method int,
  transfers text,
  transfer_duration int,
  CONSTRAINT fare_attributes_pkey PRIMARY KEY (fare_id)
);

DROP TABLE IF EXISTS feed_info CASCADE;
CREATE TABLE feed_info (
  feed_publisher_name text,
  feed_publisher_url text,
  feed_lang text,
  feed_start_date date,
  feed_end_date date,
  feed_version bigint,
  feed_contact_email text,
  feed_contact_url text,
  CONSTRAINT feed_info_pkey PRIMARY KEY (feed_publisher_name)
);

DROP TABLE IF EXISTS route_types CASCADE;
CREATE TABLE route_types (
  route_type int PRIMARY KEY,
  description text
);

DROP TABLE IF EXISTS routes CASCADE;
CREATE TABLE routes (
  route_id text,
  agency_id integer,
  route_short_name text DEFAULT '',
  route_long_name text DEFAULT '',
  route_desc text DEFAULT '',
  route_type int REFERENCES route_types(route_type),
  route_url text DEFAULT NULL,
  route_color text,
  route_text_color text,
  route_sort_order integer,
  CONSTRAINT routes_pkey PRIMARY KEY (route_id)
);

DROP TABLE IF EXISTS shapes CASCADE;
CREATE TABLE shapes (
  shape_id text NOT NULL,
  shape_pt_lat double precision NOT NULL,
  shape_pt_lon double precision NOT NULL,
  shape_pt_sequence int NOT NULL,
  shape_dist_traveled float
);
DROP INDEX IF EXISTS shapes_shape_key;
CREATE INDEX shapes_shape_key ON shapes (shape_id);

DROP TABLE IF EXISTS shape_geoms CASCADE;
-- Create a table to store the shape geometries
CREATE TABLE shape_geoms (
  shape_id text NOT NULL,
  shape_geom geometry('LINESTRING', 2154),
  CONSTRAINT shape_geom_pkey PRIMARY KEY (shape_id)
);
DROP INDEX IF EXISTS shape_geoms_key;
CREATE INDEX shape_geoms_key ON shapes (shape_id);

DROP TABLE IF EXISTS location_types CASCADE;
CREATE TABLE location_types (
  location_type int PRIMARY KEY,
  description text
);

DROP TABLE IF EXISTS stops CASCADE;
CREATE TABLE stops (
  stop_id text,
  stop_code text,
  stop_name text DEFAULT NULL,
  stop_desc text DEFAULT NULL,
  stop_lat double precision,
  stop_lon double precision,
  zone_id text,
  stop_url text,
  location_type integer REFERENCES location_types(location_type),
  parent_station text DEFAULT NULL,
  wheelchair_boarding int,
  stop_geom geometry('POINT', 2154),
  platform_code text DEFAULT NULL,
  stop_timezone text DEFAULT NULL,
  CONSTRAINT stops_pkey PRIMARY KEY (stop_id)
);

DROP TABLE IF EXISTS pickup_dropoff_types CASCADE;
CREATE TABLE pickup_dropoff_types (
  type_id int PRIMARY KEY,
  description text
);

DROP TABLE IF EXISTS stop_times CASCADE;
CREATE TABLE stop_times (
  trip_id text NOT NULL,
  -- Check that casting to time interval works.
  arrival_time interval CHECK (arrival_time::interval = arrival_time::interval),
  departure_time interval CHECK (departure_time::interval = departure_time::interval),
  stop_id text,
  stop_sequence int NOT NULL,
  stop_headsign text,
  pickup_type int REFERENCES pickup_dropoff_types(type_id),
  drop_off_type int REFERENCES pickup_dropoff_types(type_id),
  shape_dist_traveled float,
  timepoint int,
  CONSTRAINT stop_times_pkey PRIMARY KEY (trip_id, stop_sequence)
);
DROP INDEX IF EXISTS stop_times_key;
DROP INDEX IF EXISTS arr_time_index;
DROP INDEX IF EXISTS dep_time_index;
CREATE INDEX stop_times_key ON stop_times (trip_id, stop_id);
CREATE INDEX arr_time_index ON stop_times (arrival_time);
CREATE INDEX dep_time_index ON stop_times (departure_time);

DROP TABLE IF EXISTS trips CASCADE;
CREATE TABLE trips (
  route_id text NOT NULL,
  service_id text NOT NULL,
  trip_id text NOT NULL,
  trip_headsign text,
  trip_short_name text,
  direction_id int,
  block_id text,
  shape_id text,
  wheelchair_accessible int,
  bikes_allowed int,
  CONSTRAINT trips_pkey PRIMARY KEY (trip_id)
);
DROP INDEX IF EXISTS trips_trip_id;
CREATE INDEX trips_trip_id ON trips (trip_id);

INSERT INTO exception_types (exception_type, description) VALUES
(1, 'service has been added'),
(2, 'service has been removed');

INSERT INTO location_types(location_type, description) VALUES
(0,'stop'),
(1,'station'),
(2,'station entrance'),
(3,'generic node'),
(4,'boarding area');

INSERT INTO pickup_dropoff_types (type_id, description) VALUES
(0,'Regularly Scheduled'),
(1,'Not available'),
(2,'Phone arrangement only'),
(3,'Driver arrangement only');

INSERT INTO route_types (route_type, description) VALUES
(0,'Tram, Streetcar, Light rail'),
(1,'Subway, Metro'),
(2,'Rail'),
(3,'Bus'),
(4,'Ferry'),
(5,'Cable tram'),
(6,'Aerial lift, Suspended cable car'),
(7,'Funicular'),
(11,'Trolleybus'),
(12,'Monorail');


/* Here import the GTFS data by running copyGTFS.sh */


INSERT INTO shape_geoms
SELECT shape_id, ST_MakeLine(array_agg(
  ST_Transform(ST_Point(shape_pt_lon, shape_pt_lat, 4326), 2154) ORDER BY shape_pt_sequence))
FROM shapes
GROUP BY shape_id;

UPDATE stops
SET stop_geom = ST_Transform(ST_Point(stop_lon, stop_lat, 4326), 2154);

DROP TABLE IF EXISTS service_dates;
CREATE TABLE service_dates AS (
SELECT service_id, date_trunc('day', d)::date AS date
FROM calendar c, generate_series(start_date, end_date, '1 day'::interval) AS d
WHERE (
	(monday = 1 AND extract(isodow FROM d) = 1) OR
	(tuesday = 1 AND extract(isodow FROM d) = 2) OR
	(wednesday = 1 AND extract(isodow FROM d) = 3) OR
	(thursday = 1 AND extract(isodow FROM d) = 4) OR
	(friday = 1 AND extract(isodow FROM d) = 5) OR
	(saturday = 1 AND extract(isodow FROM d) = 6) OR
	(sunday = 1 AND extract(isodow FROM d) = 7)
)
EXCEPT
SELECT service_id, date
FROM calendar_dates WHERE exception_type = 2
UNION
SELECT c.service_id, date
FROM calendar c JOIN calendar_dates d ON c.service_id = d.service_id
WHERE exception_type = 1 AND start_date <= date AND date <= end_date
);

DROP TABLE IF EXISTS trip_stops;
CREATE TABLE trip_stops (
  trip_id text,
  stop_sequence integer,
  no_stops integer,
  route_id text,
  service_id text,
  shape_id text,
  stop_id text,
  arrival_time interval,
  perc float
);

INSERT INTO trip_stops (trip_id, stop_sequence, no_stops, route_id, service_id,
  shape_id, stop_id, arrival_time)
SELECT t.trip_id, stop_sequence, MAX(stop_sequence) OVER (PARTITION BY t.trip_id),
  route_id, service_id, shape_id, stop_id, arrival_time
FROM trips t JOIN stop_times s ON t.trip_id = s.trip_id;

UPDATE trip_stops t
SET perc = CASE
WHEN stop_sequence =  1 then 0.0
WHEN stop_sequence =  no_stops then 1.0
ELSE ST_LineLocatePoint(g.shape_geom, s.stop_geom)
END
FROM shape_geoms g, stops s
WHERE t.shape_id = g.shape_id AND t.stop_id = s.stop_id;
	
DELETE FROM trip_stops
	WHERE perc IS NULL;

DROP TABLE IF EXISTS trip_segs;
CREATE TABLE trip_segs (
  trip_id text,
  route_id text,
  service_id text,
  stop1_sequence integer,
  stop2_sequence integer,
  no_stops integer,
  shape_id text,
  stop1_arrival_time interval,
  stop2_arrival_time interval,
  perc1 float,
  perc2 float,
  seg_geom geometry,
  seg_length float,
  no_points integer,
  PRIMARY KEY (trip_id, stop1_sequence)
);

INSERT INTO trip_segs (trip_id, route_id, service_id, stop1_sequence, stop2_sequence,
  no_stops, shape_id, stop1_arrival_time, stop2_arrival_time, perc1, perc2)  
WITH temp AS (
  SELECT trip_id, route_id, service_id, stop_sequence,
    LEAD(stop_sequence) OVER w AS stop_sequence2,
 	no_stops,
	shape_id, arrival_time, LEAD(arrival_time) OVER w, perc, LEAD(perc) OVER w	
  FROM trip_stops WINDOW w AS (PARTITION BY trip_id ORDER BY stop_sequence)
)
SELECT * FROM temp WHERE stop_sequence2 IS NOT null;

-- Ici on delete ce qui ne va pas, à expliquer…
DELETE FROM trip_segs
	where perc1 >= perc2;

UPDATE trip_segs t
SET seg_geom = ST_LineSubstring(g.shape_geom, perc1, perc2)
FROM shape_geoms g
WHERE t.shape_id = g.shape_id;

UPDATE trip_segs
SET seg_length = ST_Length(seg_geom), no_points = ST_NumPoints(seg_geom);

DROP TABLE IF EXISTS trip_points;
CREATE TABLE trip_points (
  trip_id text,
  route_id text,
  service_id text,
  stop1_sequence integer,
  point_sequence integer,
  point_geom geometry,
  point_arrival_time interval,
  PRIMARY KEY (trip_id, stop1_sequence, point_sequence)
);

INSERT INTO trip_points (trip_id, route_id, service_id, stop1_sequence,
  point_sequence, point_geom, point_arrival_time)
WITH temp1 AS (
  SELECT trip_id, route_id, service_id, stop1_sequence, stop2_sequence,
	no_stops, stop1_arrival_time, stop2_arrival_time, seg_length,
	(dp).path[1] AS point_sequence, no_points, (dp).geom as point_geom
FROM trip_segs, ST_DumpPoints(seg_geom) AS dp
),
temp2 AS (
SELECT trip_id, route_id, service_id, stop1_sequence, stop1_arrival_time,
	stop2_arrival_time, seg_length, point_sequence, no_points, point_geom
FROM temp1
WHERE point_sequence <> no_points OR stop2_sequence = no_stops
),
temp3 AS (
SELECT trip_id, route_id, service_id, stop1_sequence, stop1_arrival_time,
	stop2_arrival_time, point_sequence, no_points, point_geom,
	ST_Length(ST_MakeLine(array_agg(point_geom) OVER w)) / seg_length AS perc
FROM temp2 WINDOW w AS (PARTITION BY trip_id, service_id, stop1_sequence
	ORDER BY point_sequence)
)
SELECT trip_id, route_id, service_id, stop1_sequence, point_sequence, point_geom,
CASE
WHEN point_sequence = 1 then stop1_arrival_time
WHEN point_sequence = no_points then stop2_arrival_time
ELSE stop1_arrival_time + ((stop2_arrival_time - stop1_arrival_time) * perc)
END AS point_arrival_time
FROM temp3;

DROP TABLE IF EXISTS trips_input;
CREATE TABLE trips_input (
  trip_id text,
  route_id text,
  service_id text,
  date date,
  point_geom geometry,
  t timestamptz
);

INSERT INTO trips_input
SELECT trip_id, route_id, t.service_id, date, point_geom, date + point_arrival_time AS t
FROM trip_points t JOIN
( SELECT service_id, MIN(date) AS date FROM service_dates GROUP BY service_id) s
ON t.service_id = s.service_id;

DELETE FROM trips_input
WHERE trip_id in (
	SELECT distinct t1.trip_id FROM trips_input t1
	JOIN trips_input t2 ON t2.trip_id = t1.trip_id and t2.service_id = t1.service_id and t2.route_id = t1.route_id and t2.t = t1.t and NOT ST_Equals(t2.point_geom,t1.point_geom)
)and t in (
	SELECT distinct t1.t FROM trips_input t1
	JOIN trips_input t2 ON t2.trip_id = t1.trip_id and t2.service_id = t1.service_id and t2.route_id = t1.route_id and t2.t = t1.t and NOT ST_Equals(t2.point_geom,t1.point_geom)
);

DROP TABLE IF EXISTS trips_mdb;
CREATE TABLE trips_mdb (
	trip_id text NOT NULL,
	service_id text NOT NULL,
	route_id text NOT NULL,
	date date NOT NULL,
	trip tgeompoint,
	PRIMARY KEY (trip_id, date)
);

INSERT INTO trips_mdb(trip_id, service_id, route_id, date, trip)
SELECT trip_id, service_id, route_id, date, tgeompointSeq(array_agg(tgeompoint(point_geom, t) ORDER BY T))
FROM trips_input
GROUP BY trip_id, service_id, route_id, date;

INSERT INTO trips_mdb(trip_id, service_id, route_id, date, trip)
SELECT trip_id, route_id, t.service_id, d.date,
  shiftTime(trip, make_interval(days => d.date - t.date))
FROM trips_mdb t JOIN service_dates d ON t.service_id = d.service_id AND t.date <> d.date;
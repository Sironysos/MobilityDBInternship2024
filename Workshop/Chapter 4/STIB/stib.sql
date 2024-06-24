CREATE EXTENSION mobilityDB CASCADE;

DROP TABLE agency CASCADE;
CREATE TABLE agency (
  agency_id text DEFAULT '',
  agency_name text DEFAULT NULL,
  agency_url text DEFAULT NULL,
  agency_timezone text DEFAULT NULL,
  agency_lang text DEFAULT NULL,
  agency_phone text DEFAULT NULL,
  CONSTRAINT agency_pkey PRIMARY KEY (agency_id)
);

DROP TABLE calendar CASCADE;
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

DROP TABLE exception_types CASCADE;
CREATE TABLE exception_types (
  exception_type int PRIMARY KEY,
  description text
);

DROP TABLE calendar_dates CASCADE;
CREATE TABLE calendar_dates (
  service_id text,
  date date NOT NULL,
  exception_type int REFERENCES exception_types(exception_type)
);
DROP INDEX IF EXISTS calendar_dates_service_id;
CREATE INDEX calendar_dates_dateidx ON calendar_dates (date);

DROP TABLE route_types CASCADE;
CREATE TABLE route_types (
  route_type int PRIMARY KEY,
  description text
);

DROP TABLE routes CASCADE;
CREATE TABLE routes (
  route_id text,
  route_short_name text DEFAULT '',
  route_long_name text DEFAULT '',
  route_desc text DEFAULT '',
  route_type int,
  route_url text,
  route_color text,
  route_text_color text,
  CONSTRAINT routes_pkey PRIMARY KEY (route_id)
);

DROP TABLE shapes CASCADE;
CREATE TABLE shapes (
  shape_id text NOT NULL,
  shape_pt_lat double precision NOT NULL,
  shape_pt_lon double precision NOT NULL,
  shape_pt_sequence int NOT NULL,
  shape_dist_traveled float
);
DROP INDEX IF EXISTS shapes_shape_key;
CREATE INDEX shapes_shape_key ON shapes (shape_id);

DROP TABLE shape_geoms CASCADE;
-- Create a table to store the shape geometries
CREATE TABLE shape_geoms (
  shape_id text NOT NULL,
  shape_geom geometry('LINESTRING', 4326),
  CONSTRAINT shape_geom_pkey PRIMARY KEY (shape_id)
);
DROP INDEX IF EXISTS shape_geoms_key;
CREATE INDEX shape_geoms_key ON shapes (shape_id);

DROP TABLE location_types CASCADE;
CREATE TABLE location_types (
  location_type int PRIMARY KEY,
  description text
);

DROP TABLE stops CASCADE;
CREATE TABLE stops (
  stop_id text,
  stop_code text,
  stop_name text DEFAULT NULL,
  stop_desc text DEFAULT NULL,
  stop_lat double precision,
  stop_lon double precision,
  zone_id text,
  stop_url text,
  location_type integer  REFERENCES location_types(location_type),
  parent_station integer,
  stop_geom geometry('POINT', 4326),
  platform_code text DEFAULT NULL,
  CONSTRAINT stops_pkey PRIMARY KEY (stop_id)
);

DROP TABLE pickup_dropoff_types CASCADE;
CREATE TABLE pickup_dropoff_types (
  type_id int PRIMARY KEY,
  description text
);

DROP TABLE stop_times CASCADE;
CREATE TABLE stop_times (
  trip_id text NOT NULL,
  -- Check that casting to time interval works.
  arrival_time interval CHECK (arrival_time::interval = arrival_time::interval),
  departure_time interval CHECK (departure_time::interval = departure_time::interval),
  stop_id text,
  stop_sequence int NOT NULL,
  pickup_type int REFERENCES pickup_dropoff_types(type_id),
  drop_off_type int REFERENCES pickup_dropoff_types(type_id),
  CONSTRAINT stop_times_pkey PRIMARY KEY (trip_id, stop_sequence)
);
DROP INDEX IF EXISTS stop_times_key;
DROP INDEX IF EXISTS arr_time_index;
DROP INDEX IF EXISTS dep_time_index;
CREATE INDEX stop_times_key ON stop_times (trip_id, stop_id);
CREATE INDEX arr_time_index ON stop_times (arrival_time);
CREATE INDEX dep_time_index ON stop_times (departure_time);

DROP TABLE trips CASCADE;
CREATE TABLE trips (
  route_id text NOT NULL,
  service_id text NOT NULL,
  trip_id text NOT NULL,
  trip_headsign text,
  direction_id int,
  block_id text,
  shape_id text,
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
(2,'station entrance');

INSERT INTO pickup_dropoff_types (type_id, description) VALUES
(0,'Regularly Scheduled'),
(1,'Not available'),
(2,'Phone arrangement only'),
(3,'Driver arrangement only');

INSERT INTO shape_geoms
SELECT shape_id, ST_MakeLine(array_agg(
  ST_SetSRID(ST_MakePoint(shape_pt_lon, shape_pt_lat),4326) ORDER BY shape_pt_sequence))
FROM shapes
GROUP BY shape_id;

UPDATE stops
SET stop_geom = ST_SetSRID(ST_MakePoint(stop_lon, stop_lat),4326);

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
  MAX(stop_sequence) OVER (PARTITION BY trip_id),
  shape_id, arrival_time, LEAD(arrival_time) OVER w, perc, LEAD(perc) OVER w
  FROM trip_stops WINDOW w AS (PARTITION BY trip_id ORDER BY stop_sequence)
)
SELECT * FROM temp WHERE stop_sequence2 IS NOT null;

UPDATE trip_segs t
SET seg_geom = ST_LineSubstring(g.shape_geom, perc1, perc2)
FROM shape_geoms g
WHERE t.shape_id = g.shape_id;

UPDATE trip_segs
SET seg_length = ST_Length(seg_geom), no_points = ST_NumPoints(seg_geom);
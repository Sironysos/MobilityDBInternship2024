DROP EXTENSION IF EXISTS mobilitydb CASCADE;
CREATE EXTENSION mobilityDB CASCADE;

-- do the command gtfs-to-sql to import the GTFS data into the database.

ALTER TABLE stops ADD COLUMN stop_geom geometry('POINT', 2154);

UPDATE stops
SET stop_geom = ST_SetSRID(stop_loc::geometry,2154);

DROP TABLE IF EXISTS shape_geoms CASCADE;
-- Create a table to store the shape geometries
CREATE TABLE shape_geoms (
  shape_id text NOT NULL,
  shape_geom geometry('LINESTRING', 2154),
  CONSTRAINT shape_geom_pkey PRIMARY KEY (shape_id)
);
DROP INDEX IF EXISTS shape_geoms_key;
CREATE INDEX shape_geoms_key ON shapes (shape_id);

INSERT INTO shape_geoms
SELECT shape_id, ST_MakeLine(array_agg(
  ST_SetSRID(shape_pt_loc::geometry,2154) ORDER BY shape_pt_sequence))
FROM shapes
GROUP BY shape_id;

DROP TABLE IF EXISTS service_dates;
CREATE TABLE service_dates AS (
SELECT service_id, date_trunc('day', d)::date AS date
FROM calendar c, generate_series(start_date, end_date, '1 day'::interval) AS d
WHERE (
	(monday = 'available' AND extract(isodow FROM d) = 1) OR
	(tuesday = 'available' AND extract(isodow FROM d) = 2) OR
	(wednesday = 'available' AND extract(isodow FROM d) = 3) OR
	(thursday = 'available' AND extract(isodow FROM d) = 4) OR
	(friday = 'available' AND extract(isodow FROM d) = 5) OR
	(saturday = 'available' AND extract(isodow FROM d) = 6) OR
	(sunday = 'available' AND extract(isodow FROM d) = 7)
)
EXCEPT
SELECT service_id, date
FROM calendar_dates WHERE exception_type = 'removed'
UNION
SELECT c.service_id, date
FROM calendar c JOIN calendar_dates d ON c.service_id = d.service_id
WHERE exception_type = 'added' AND start_date <= date AND date <= end_date
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

select * from trips_mdb;

INSERT INTO trips_mdb(trip_id, service_id, route_id, date, trip)
SELECT trip_id, route_id, t.service_id, d.date,
  shiftTime(trip, make_interval(days => d.date - t.date))
FROM trips_mdb t JOIN service_dates d ON t.service_id = d.service_id AND t.date <> d.date;
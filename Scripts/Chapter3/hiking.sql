DROP EXTENSION IF EXISTS mobilitydb CASCADE;
CREATE EXTENSION mobilityDB CASCADE;

-- here, do "ogr2ogr -append -f PostgreSQL PG:dbname=hiking ./data/Chapter3/11390305.gpx"
-- and "ogr2ogr -append -f PostgreSQL PG:dbname=hiking ./data/Chapter3/11390306.gpx"
-- you can change the paths to the gpx files to the ones you have in your system

SELECT * FROM track_points;
SELECT * FROM tracks;

ALTER TABLE track_points ADD COLUMN track_number int;

WITH NumberedTracks AS (
    SELECT *, LAG(track_seg_point_id) OVER (ORDER BY ogc_fid) AS prev_value
    FROM track_points
),
TrackIdentifiers AS (
    SELECT ogc_fid, SUM(CASE WHEN track_seg_point_id < prev_value THEN 1 ELSE 0 END) OVER (ORDER BY ogc_fid) + 1 AS track_id
    FROM NumberedTracks
)
UPDATE track_points tp
SET track_number = ti.track_id
FROM TrackIdentifiers ti
WHERE tp.ogc_fid = ti.ogc_fid;

DROP TABLE IF EXISTS trips_mdb;
CREATE TABLE trips_mdb (
	id int,
	date date,
	trip tgeompoint,
	trajectory geometry,
	PRIMARY KEY (id)
);

INSERT INTO trips_mdb(id, date, trip)
SELECT track_number, date(time), tgeompointSeq(array_agg(tgeompoint(
  wkb_geometry, time) ORDER BY time))
FROM track_points
GROUP BY track_number, date;

UPDATE trips_mdb
SET trajectory = trajectory(trip);

SELECT * from trips_mdb;
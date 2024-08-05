CREATE EXTENSION IF NOT EXISTS mobilityDB CASCADE;

DROP TABLE IF EXISTS bikes CASCADE;
CREATE TABLE IF NOT EXISTS bikes (
	time timestamp,
	bike_id VARCHAR(100),
	lat float,
	lon float,
	is_reserved int,
	is_disabled int,
	PRIMARY key(bike_id, time)
);

DROP TABLE IF EXISTS raw_json_data;
CREATE TABLE IF NOT EXISTS raw_json_data (
    timestamp TIMESTAMP,
    json_data JSON
);
SELECT * FROM raw_json_data;



-- INSERT_bikes using bikeJSONtoPSQL.sh



INSERT INTO bikes (time, bike_id, lat, lon, is_reserved, is_disabled)
SELECT 
    timestamp,
	bike->>'bike_id' AS bike_id,
    (bike->>'lat')::float AS lat,
    (bike->>'lon')::float AS lon,
    (bike->>'is_reserved')::int AS is_reserved,
    (bike->>'is_disabled')::int AS is_disabled
FROM 
    raw_json_data,
    json_array_elements(json_data->'data'->'bikes') AS bike;

SELECT * FROM bikes;

DROP TABLE IF EXISTS bike2;
CREATE TABLE IF NOT EXISTS bike2 (
	time timestamp,
	lat float,
	lon float,
	bikes int,
	disabled int,
	reserved int
);

INSERT INTO bike2(time,lat,lon,bikes,disabled,reserved)
SELECT time, lat, lon, COUNT(*) AS bikes, COUNT(*) FILTER(WHERE is_disabled=1) AS disabled, COUNT(*)FILTER(WHERE is_reserved=1) AS reserved
FROM bikes GROUP BY time,lat,lon;

SELECT * FROM bike2 order BY time, lat, lon;


DROP TABLE IF EXISTS temporal;
CREATE TABLE IF NOT EXISTS temporal(
	lat float,
	lon float,
	tbikes tint(SEQUENCE),
	tdisabled tint(SEQUENCE),
	treserved tint(SEQUENCE)
);


WITH bbike AS (
    SELECT lat, lon,
		tintSeq(array_agg(tint(bikes, time) ORDER BY time)) AS sorted_tbikes,
        tintSeq(array_agg(tint(disabled, time) ORDER BY time)) AS sorted_tdisabled,
        tintSeq(array_agg(tint(reserved, time) ORDER BY time)) AS sorted_treserved
    FROM bike2
    GROUP BY lat, lon
)
INSERT INTO temporal(lat, lon, tbikes, tdisabled, treserved)
SELECT lat, lon,
       sorted_tbikes AS tbikes,
       sorted_tdisabled AS tdisabled,
       sorted_treserved AS treserved
FROM bbike;

SELECT * FROM temporal order BY lat, lon;
CREATE EXTENSION IF NOT EXISTS mobilityDB CASCADE;

-- INSERT_bikes using bikeJSONtoPSQL.sh
SELECT * FROM raw_json_bike;

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

INSERT INTO bikes (time, bike_id, lat, lon, is_reserved, is_disabled)
SELECT 
    timestamp,
	bike->>'bike_id' AS bike_id,
    (bike->>'lat')::float AS lat,
    (bike->>'lon')::float AS lon,
    (bike->>'is_reserved')::int AS is_reserved,
    (bike->>'is_disabled')::int AS is_disabled
FROM 
    raw_json_bike,
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










-- INSERT station information using stationJSONtoPSQL.sh --
select * from raw_json_station;

drop table if exists prestation;
CREATE table prestation(
	id int primary key,
	name varchar(100),
	position geometry(point),
	capacity int
);

insert into prestation(id, name, position, capacity)
select
	(stations->>'station_id')::int,
    stations->>'name',
	ST_SetSRID(ST_MakePoint((stations->>'lon')::float,(stations->>'lat')::float),2154),
	(stations->>'capacity')::int
FROM 
    raw_json_station,
    json_array_elements(json_data->'data'->'stations') AS stations;

select * from prestation;










-- INSERT station status using statusJSONtoPSQL.sh --
select * from raw_json_status;

drop table if exists docks;
CREATE table docks(
	id int,
	time timestamp,
	docks int
);

INSERT INTO docks (id, time, docks)
SELECT 
	(dock->>'station_id')::int,
    timestamp,
    (dock->>'num_docks_available')::int
FROM 
    raw_json_status,
    json_array_elements(json_data->'data'->'stations') AS dock;

select * from docks;

DROP TABLE IF EXISTS tempdocks;
CREATE TABLE IF NOT EXISTS tempdocks(
	id int,
	tdocks tint(SEQUENCE)
);

WITH ddocks AS (
    SELECT 
		id,
        tintSeq(array_agg(tint(docks, time) ORDER BY time)) AS sorted_tdocks
    FROM docks
    GROUP BY id
)
INSERT INTO tempdocks(id, tdocks)
SELECT id,
       sorted_tdocks AS tdocks
FROM ddocks;

SELECT * FROM tempdocks order BY id;










-- final JOIN --
CREATE OR REPLACE VIEW station_view AS
SELECT 
    prestation.id,
    prestation.name,
    prestation.position,
    prestation.capacity,
    tbikes,
    tdisabled,
    treserved,
    tdocks
FROM
    prestation
	JOIN temporal ON ST_SetSRID(ST_MakePoint(temporal.lon,temporal.lat),2154)=prestation.position
	JOIN tempdocks ON tempdocks.id=prestation.id;

SELECT * FROM station_view ORDER BY id;
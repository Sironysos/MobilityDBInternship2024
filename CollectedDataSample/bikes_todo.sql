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

-- INSERT_bikes using bikeJSONtoPSQL.sh
SELECT * FROM raw_json_bike;



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


-- INSERT station information + station status using stationJSONtoPSQL.sh + statusJSONtoPSQL.sh
select * from raw_json_station;
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











-- on doit transformer ce qu'il y a dans docks pour mettre un tint sequence dans station --












drop table if exists station;
create table station(
	id int primary key,
	name varchar(100),
	position geometry(point),
	capacity int,
	tbikes tint(SEQUENCE),
	tdisabled tint(SEQUENCE),
	treserved tint(SEQUENCE),
    tdocks_available tint(SEQUENCE)
);

insert into station(id, name, position, capacity, tbikes, tdisabled, treserved, docks_available)
select (
	(stations->>'station_id')::int AS id,
    stations->>'name' AS name,
	ST_SetSRID(ST_MakePoint((stations->>'lon')::float,(stations->>'lat')::float),2154),
	capacity int,
	tbikes tint(SEQUENCE),
	tdisabled tint(SEQUENCE),
	treserved tint(SEQUENCE),
	
)
from
	(raw_json_station,
    json_array_elements(json_data->'data'->'stations') AS stations)
	JOIN temporal ON temporal.lon=raw_json_station.lon and temporal.lat=raw_json_station.lat
	JOIN docks ON docks.id=raw_json_station.id
	;
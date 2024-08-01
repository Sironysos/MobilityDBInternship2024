create extension mobilityDB cascade;

create TABLE bikes (
	time timestamp,
	bike_id VARCHAR(100),
	lat float,
	lon float,
	is_reserved int,
	is_disabled int,
	PRIMARY key(bike_id, time)
);
drop table bikes cascade;

drop TABLE raw_json_data;
CREATE TABLE raw_json_data (
    timestamp TIMESTAMP,
    json_data JSON
);
select * from raw_json_data;



-- insert_bikes using bikeJSONtoPSQL.sh



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

select * from bikes;

create table bike2 (
	time timestamp,
	lat float,
	lon float,
	bikes int,
	disabled int,
	reserved int
);
drop table bike2;

insert into bike2(time,lat,lon,bikes,disabled,reserved)
select time,lat,lon,count(*) as bikes, count(*) filter(where is_disabled=0) as disabled, count(*)filter(where is_reserved=0) as reserved from bikes group by time,lat,lon;

select * from bike2 order by time, lat, lon;


drop table if exists temporal;
create table temporal(
	lat float,
	lon float,
	tbikes tint[],
	tdisabled tint[],
	treserved tint[]
);


WITH bbike AS (
    SELECT lat, lon,
           array_agg(tint(bikes, time) ORDER BY time) AS sorted_tbikes,
           array_agg(tint(disabled, time) ORDER BY time) AS sorted_tdisabled,
           array_agg(tint(reserved, time) ORDER BY time) AS sorted_treserved
    FROM bike2
    GROUP BY lat, lon
)
INSERT INTO temporal(lat, lon, tbikes, tdisabled, treserved)
SELECT lat, lon,
       sorted_tbikes AS tbikes,
       sorted_tdisabled AS tdisabled,
       sorted_treserved AS treserved
FROM bbike;



select * from temporal order by lat, lon;


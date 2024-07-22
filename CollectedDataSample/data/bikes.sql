create TABLE bikes (
	time timestamp,
	bike_id VARCHAR(100),
	lat float,
	lon float,
	is_reserved int,
	is_disabled int,
	PRIMARY key(bike_id, time)
);
drop table bikes;

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
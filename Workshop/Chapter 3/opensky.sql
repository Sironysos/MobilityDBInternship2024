CREATE EXTENSION MobilityDB CASCADE;
DROP TABLE flights CASCADE;
CREATE TABLE flights(
    et              bigint,
    icao24          varchar(20),
    lat             float,
    lon             float,
    velocity        float,
    heading         float,
    vertrate        float,
    callsign        varchar(10),
    onground        boolean,
    alert           boolean,
    spi             boolean,
    squawk          integer,
    baroaltitude    numeric(7,2),
    geoaltitude     numeric(7,2),
    lastposupdate   numeric(13,3),
    lastcontact     numeric(13,3)
);

/*copy.sh script*/

select count(*) from flights;

ALTER TABLE flights
    ADD COLUMN et_ts timestamp,
    ADD COLUMN lastposupdate_ts timestamp,
    ADD COLUMN lastcontact_ts timestamp;

UPDATE flights
    SET et_ts = to_timestamp(et),
        lastposupdate_ts = to_timestamp(lastposupdate),
        lastcontact_ts = to_timestamp(lastcontact);

SELECT pg_size_pretty( pg_total_relation_size('flights') );

WITH icao24_with_null_lat AS (
    SELECT icao24, COUNT(lat)
    FROM flights
    GROUP BY icao24
    HAVING COUNT(lat) = 0
      )
DELETE
FROM flights
WHERE icao24 IN
(SELECT icao24 FROM icao24_with_null_lat);

ALTER TABLE flights
    ADD COLUMN geom geometry(Point, 4326);

UPDATE flights SET
  geom = ST_SetSRID( ST_MakePoint( lon, lat ), 4326);

CREATE INDEX icao24_time_index
    ON flights (icao24, et_ts);

CREATE TABLE airframe_traj(icao24, trip, velocity, heading, vertrate, callsign, squawk,
                           geoaltitude) AS
SELECT icao24,
       tgeompointSeq(array_agg(tgeompoint(geom, et_ts) ORDER BY et_ts)
                      FILTER (WHERE geom IS NOT NULL)),
       tfloatSeq(array_agg(tfloat(velocity, et_ts) ORDER BY et_ts)
                  FILTER (WHERE velocity IS NOT NULL)),
       tfloatSeq(array_agg(tfloat(heading, et_ts) ORDER BY et_ts)
                  FILTER (WHERE heading IS NOT NULL)),
       tfloatSeq(array_agg(tfloat(vertrate, et_ts) ORDER BY et_ts)
                  FILTER (WHERE vertrate IS NOT NULL)),
       ttextSeq(array_agg(ttext(callsign, et_ts) ORDER BY et_ts)
                 FILTER (WHERE callsign IS NOT NULL)),
       tintSeq(array_agg(tint(squawk, et_ts) ORDER BY et_ts)
                FILTER (WHERE squawk IS NOT NULL)),
       tfloatSeq(array_agg(tfloat(geoaltitude, et_ts) ORDER BY et_ts)
                  FILTER (WHERE geoaltitude IS NOT NULL))
FROM flights
GROUP BY icao24;

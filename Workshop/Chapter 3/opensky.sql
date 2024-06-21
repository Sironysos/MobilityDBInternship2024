CREATE EXTENSION MobilityDB CASCADE;

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



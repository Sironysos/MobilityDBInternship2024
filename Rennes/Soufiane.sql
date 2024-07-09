-- Scripts for pgtilesserv backend visualisation change the trips_ variable if you want a personal view

CREATE OR REPLACE
FUNCTION public.linesimpl(
            z integer, x integer, y  integer,s float[],algo text[],mmsi_ integer)
RETURNS bytea
AS $$
    WITH bounds AS (
        SELECT ST_TileEnvelope(z,x,y) as geom
    ),
    trips_ AS (
       SELECT *,unnest(s) AS s_value,unnest(algo) as a_values ,generate_series(1, array_length(s, 1)) - 1 AS index from aistrips as a where a.mmsi = mmsi_ or mmsi_ = -1
    )
    ,
    vals AS (
        SELECT mmsi,index,numInstants(trip) as size,asMVTGeom(transform(trip,3857), (bounds.geom)::stbox)
            as geom_times
        FROM (
          SELECT
          mmsi,index,
          CASE
             WHEN a_values = 'SQUISH-E' THEN
                SquishESimplify(trip, s_value)
             WHEN  a_values = 'DOUGLAS' THEN
                DouglasPeuckerSimplify(trip, s_value)
             WHEN  a_values = 'MINDIST' THEN
                minDistSimplify(trip, s_value)
             ELSE
                trip
          END AS trip
             FROM
          trips_

       ) as ego, bounds
    ),
    mvtgeom AS (
        SELECT (geom_times).geom, (geom_times).times,index,size,mmsi
        FROM vals
    )
SELECT ST_AsMVT(mvtgeom) FROM mvtgeom
                                  $$
    LANGUAGE 'sql'
STABLE
PARALLEL SAFE;

CREATE OR REPLACE
FUNCTION public.linesimplanim(
            z integer, x integer, y  integer,s float[],algo text[],mmsi_ integer,p_start text, p_end text)
RETURNS bytea
AS $$
    WITH bounds AS (
        SELECT ST_TileEnvelope(z,x,y) as geom
    ),
    trips_ AS (
       SELECT *,unnest(s) AS s_value,unnest(algo) as a_values ,generate_series(1, array_length(s, 1)) - 1 AS index from aistrips as a where a.mmsi = mmsi_ or mmsi_ = -1
    )
    ,
    vals AS (
        SELECT mmsi,index,numInstants(trip) as size,asMVTGeom(transform(attime(trip,span(p_start::timestamptz, p_end::timestamptz, true, true)),3857), transform((bounds.geom)::stbox,3857))
            as geom_times
        FROM (
          SELECT
          mmsi,index,
          CASE
             WHEN a_values = 'SQUISH-E' THEN
                SquishESimplify(trip, s_value)
             WHEN  a_values = 'DOUGLAS' THEN
                DouglasPeuckerSimplify(trip, s_value)
             WHEN  a_values = 'MINDIST' THEN
                minDistSimplify(trip, s_value)
             ELSE
                trip
          END AS trip
             FROM
          trips_

       ) as ego, bounds
    ),
    mvtgeom AS (
        SELECT (geom_times).geom, (geom_times).times,index,size,mmsi
        FROM vals
    )
SELECT ST_AsMVT(mvtgeom) FROM mvtgeom
                                  $$
    LANGUAGE 'sql'
STABLE
PARALLEL SAFE;

CREATE OR REPLACE
FUNCTION public.simplAnim(
            z integer, x integer, y  integer,mmsi_ integer,p_start text, p_end text)
RETURNS bytea
AS $$
    WITH bounds AS (
        SELECT ST_TileEnvelope(z,x,y) as geom
    ),
    trips_ AS (
       SELECT *,1 AS index from aistripssq as a where a.mmsi = mmsi_ or mmsi_ = -1
    )
    ,
    vals AS (
        SELECT mmsi,index,numInstants(trip) as size,asMVTGeom(transform(attime(trip,span(p_start::timestamptz, p_end::timestamptz, true, true)),3857), transform((bounds.geom)::stbox,3857))
            as geom_times
        FROM (
          SELECT
          mmsi,index,
          trip AS trip
          FROM
          trips_

       ) as ego, bounds
    ),
    mvtgeom AS (
        SELECT (geom_times).geom, (geom_times).times,index,size,mmsi
        FROM vals
    )
SELECT ST_AsMVT(mvtgeom) FROM mvtgeom
                                  $$
    LANGUAGE 'sql'
STABLE
PARALLEL SAFE;
 




























CREATE OR REPLACE
FUNCTION public.simplAnim(
            z integer, x integer, y  integer,mmsi_ integer,p_start text, p_end text)
RETURNS bytea
AS $$
    WITH bounds AS (
        SELECT ST_TileEnvelope(z,x,y) as geom
    ),
    trips_ AS (
       SELECT *,1 AS index from aistripssq as a where a.mmsi = mmsi_ or mmsi_ = -1
    )
    ,
    vals AS (
        SELECT mmsi,index,numInstants(trip) as size,asMVTGeom(transform(attime(trip,span(p_start::timestamptz, p_end::timestamptz, true, true)),3857), transform((bounds.geom)::stbox,3857))
            as geom_times
        FROM (
          SELECT
          mmsi,index,
          trip AS trip
          FROM
          trips_

       ) as ego, bounds
    ),
    mvtgeom AS (
        SELECT (geom_times).geom, (geom_times).times,index,size,mmsi
        FROM vals
    )
SELECT ST_AsMVT(mvtgeom) FROM mvtgeom
                                  $$
    LANGUAGE 'sql'
STABLE
PARALLEL SAFE;
 
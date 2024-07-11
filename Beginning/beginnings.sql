DROP TABLE IF EXISTS postgrepoints;
CREATE TABLE postgrePoints(
	time timetz,
	longitude float,
	latitude float
);

INSERT INTO postgrePoints VALUES
('00:00:00+00', 0, 0),
('02:00:00+00', 1, 1),
('03:00:00+00', 0.5, 2),
('04:00:00+00', 0, 1),
('06:00:00+00', 1, 1),
('07:00:00+00', 1, 0);

SELECT * FROM postgrePoints;


DROP EXTENSION IF EXISTS PostGIS CASCADE;
CREATE EXTENSION PostGIS;

DROP TABLE IF EXISTS postgispoints CASCADE;
CREATE TABLE postgisPoints(
	time timestamptz,
	point geometry(point)
);

INSERT INTO postgispoints ("time", point)
SELECT '2000-01-01'::date + time::time, ST_MakePoint(longitude, latitude)
FROM postgrePoints;

SELECT * FROM postgispoints;


DROP TABLE IF EXISTS postgisline;
CREATE TABLE postgisLine(
	line geometry
);

INSERT INTO postgisLine (line)
SELECT ST_MakeLine(ARRAY(SELECT point FROM postgisPoints ORDER BY time));

SELECT * FROM postgisLine;


DROP EXTENSION IF EXISTS mobilityDB CASCADE;
CREATE EXTENSION mobilityDB CASCADE;

DROP TABLE IF EXISTS mdbTraj CASCADE;
CREATE TABLE mdbTraj(
	traj tgeogpoint
);

INSERT INTO mdbtraj(traj)
SELECT tgeogpointSeq(array_agg(tgeogpoint(point, time) ORDER BY time))
FROM postgisPoints;

SELECT * FROM mdbTraj;
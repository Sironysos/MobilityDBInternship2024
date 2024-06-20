CREATE EXTENSION mobilitydb CASCADE;

CREATE TABLE AISInput(
  T timestamp,
  TypeOfMobile varchar(100),
  MMSI integer,
  Latitude float,
  Longitude float,
  navigationalStatus varchar(100),
  ROT float,
  SOG float,
  COG float,
  Heading integer,
  IMO varchar(100),
  Callsign varchar(100),
  Name varchar(100),
  ShipType varchar(100),
  CargoType varchar(100),
  Width float,
  Length float,
  TypeOfPositionFixingDevice varchar(100),
  Draught float,
  Destination varchar(100),
  ETA varchar(100),
  DataSourceType varchar(100),
  SizeA float,
  SizeB float,
  SizeC float,
  SizeD float,
  Geom geometry(Point, 4326)
);
DROP TABLE AISInput;

COPY AISInput(T, TypeOfMobile, MMSI, Latitude, Longitude, NavigationalStatus,
  ROT, SOG, COG, Heading, IMO, CallSign, Name, ShipType, CargoType, Width, Length,
  TypeOfPositionFixingDevice, Draught, Destination, ETA, DataSourceType,
  SizeA, SizeB, SizeC, SizeD, Geom)
FROM '/home/alice/Documents/Stage/DanishAIS/ais.csv' DELIMITER  ',' CSV HEADER;

UPDATE AISInput SET
  NavigationalStatus = CASE NavigationalStatus WHEN 'Unknown value' THEN NULL END,
  IMO = CASE IMO WHEN 'Unknown' THEN NULL END,
  ShipType = CASE ShipType WHEN 'Undefined' THEN NULL END,
  TypeOfPositionFixingDevice = CASE TypeOfPositionFixingDevice
  WHEN 'Undefined' THEN NULL END,
  Geom = ST_SetSRID( ST_MakePoint( Longitude, Latitude ), 432

DROP TABLE AISInputFiltered;

CREATE TABLE AISInputFiltered AS
SELECT DISTINCT ON(MMSI,T) *
FROM AISInput
WHERE Longitude BETWEEN -16.1 and 32.88 AND Latitude BETWEEN 40.18 AND 84.17;

SELECT count(*) FROM AISInputFiltered;

DROP TABLE Ships;

CREATE TABLE Ships(MMSI, Trip, SOG, COG) AS
SELECT MMSI,
  tgeompointSeq(array_agg(tgeompoint(ST_Transform(Geom, 25832), T) ORDER BY T)),
  tfloatSeq(array_agg(tfloat(SOG, T) ORDER BY T) FILTER (WHERE SOG IS NOT NULL)),
  tfloatSeq(array_agg(tfloat(COG, T) ORDER BY T) FILTER (WHERE COG IS NOT NULL))
FROM AISInputFiltered
GROUP BY MMSI;

ALTER TABLE Ships ADD COLUMN Traj geometry;
UPDATE Ships SET Traj = trajectory(Trip);

SELECT SUM(length(Trip)) FROM Ships;

WITH buckets (bucketNo, RangeKM) AS (
  SELECT 1, floatspan '[0, 0]' UNION
  SELECT 2, floatspan '(0, 50)' UNION
  SELECT 3, floatspan '[50, 100)' UNION
  SELECT 4, floatspan '[100, 200)' UNION
  SELECT 5, floatspan '[200, 500)' UNION
  SELECT 6, floatspan '[500, 1500)' UNION
  SELECT 7, floatspan '[1500, 10000)' ),
histogram AS (
  SELECT bucketNo, RangeKM, count(MMSI) as freq
  FROM buckets left outer join Ships on (length(Trip)/1000) <@ RangeKM
  GROUP BY bucketNo, RangeKM
  ORDER BY bucketNo, RangeKM
)
SELECT bucketNo, RangeKM, freq,
  repeat('▪', ( freq::float / max(freq) OVER () * 30 )::int ) AS bar 
FROM histogram;

DELETE FROM Ships
WHERE length(Trip) = 0 OR length(Trip) >= 1500000;

SELECT ABS(twavg(SOG) * 1.852 - twavg(speed(Trip))* 3.6 ) SpeedDifference
FROM Ships WHERE SOG IS NOT NULL AND
  ABS(twavg(SOG) * 1.852 - twavg(speed(Trip))* 3.6 ) > 10.0
ORDER BY SpeedDifference DESC;

DELETE FROM Ships 
WHERE ABS(twavg(SOG) * 1.852 - twavg(speed(Trip))* 3.6 ) > 10;

SELECT ABS(twavg(COG) - twavg(azimuth(Trip)) * 180.0/pi()) AzimuthDifference 
FROM Ships 
WHERE ABS(twavg(COG) - twavg(azimuth(Trip)) * 180.0/pi()) > 45.0 
ORDER BY AzimuthDifference DESC;

CREATE INDEX Ships_Trip_Idx ON Ships USING GiST(Trip);

WITH Ports(Rodby, Puttgarden) AS (
  SELECT ST_MakeEnvelope(651135, 6058230, 651422, 6058548, 25832),
    ST_MakeEnvelope(644339, 6042108, 644896, 6042487, 25832) )
SELECT S.*, Rodby, Puttgarden
FROM Ports P, Ships S
WHERE eintersects(S.Trip, P.Rodby) AND eintersects(S.Trip, P.Puttgarden);
/*The query above gives all the ships that at some point did a trip between the two ports*/

WITH Ports(Rodby, Puttgarden) AS (
  SELECT ST_MakeEnvelope(651135, 6058230, 651422, 6058548, 25832),
    ST_MakeEnvelope(644339, 6042108, 644896, 6042487, 25832) )
SELECT MMSI, (numSequences(atGeometry(S.Trip, P.Rodby)) +
  numSequences(atGeometry(S.Trip, P.Puttgarden)))/2.0 AS NumTrips
FROM Ports P, Ships S
WHERE eintersects(S.Trip, P.Rodby) AND eintersects(S.Trip, P.Puttgarden);
/*The query above gives the number of trips between the two ports done by each ship*/
CREATE EXTENSION IF NOT EXISTS MobilityDB CASCADE;

DROP TABLE IF EXISTS BusInput;
CREATE TABLE  IF NOT EXISTS BusInput(
	T timestamp,
	BusID int,
	BusNumber int,
	State varchar(20),
	LineID int,
	LineName varchar(5),
	Direction int,
	Destination varchar(50),
	Position varchar(30),
	Points GEOMETRY(Point, 4326),
	Delay int
);

COPY BusInput (T, BusID, BusNumber, State, LineID, LineName,Direction, Destination, Position, Delay)
FROM 'path/to/tposition-bus-clean.csv' DELIMITER ';' CSV HEADER;
-- If the copy does not work, run copyBus.sh

UPDATE BusInput
SET Points = ST_SetSRID(ST_MakePoint(SPLIT_PART(Position, ',', 2)::FLOAT, SPLIT_PART(Position, ',', 1)::FLOAT), 4326);

DELETE FROM BusInput WHERE T IN (
	SELECT DISTINCT b1.T FROM BusInput b1 JOIN BusInput b2
	ON b2.BusID = b1.BusID AND b2.T = b1.T AND NOT ST_Equals(b1.Points, b2.Points)
) OR (BusID, Points, T) IN (
	SELECT BusID, Points, T
    FROM BusInput
    GROUP BY BusID, Points, T
    HAVING COUNT(*) > 1
);

DROP TABLE IF EXISTS Busses;
CREATE TABLE IF NOT EXISTS Busses(ID, Trip) AS
SELECT BusID, tgeompointSeq(array_agg(tgeompoint(ST_Transform(Points, 4326), T) ORDER BY T))
FROM (
    SELECT BusID, Points, T
    FROM BusInput
    ORDER BY BusID, T
) AS SortedBusInput
GROUP BY BusID;

ALTER TABLE Busses ADD COLUMN Traj geometry;
UPDATE Busses SET Traj = trajectory(Trip);

Select * from Busses;
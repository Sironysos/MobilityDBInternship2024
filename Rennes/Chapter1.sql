CREATE EXTENSION mobilitydb CASCADE;

set datestyle to DMY;

DROP TABLE RennesInput;
CREATE TABLE RennesInput(
  DateFreq date,
  TimeSlot15mn time,
  Timeo integer,
  StopName varchar(50),
  TownName varchar(50),
  LineID integer,
  LineName varchar(50),
  Direction varchar(20),
  NbPersBoarding varchar(50)
);

COPY RennesInput(DateFreq, TimeSlot15mn, Timeo, StopName, TownName, LineID, LineName, Direction, NbPersBoarding)
FROM '/home/raph/Documents/Apprentissage/Stage/Rennes/Data/Freq_Mars2024_data.csv' DELIMITER ';' CSV HEADER;

SELECT * FROM RennesInput LIMIT 30;

UPDATE RennesInput 
SET NbPersBoarding =  REPLACE(NbPersBoarding , ',', '.');
UPDATE RennesInput 
SET NbPersBoarding =  CAST(NbPersBoarding AS float);
DROP EXTENSION IF EXISTS mobilitydb CASCADE;
CREATE EXTENSION mobilitydb CASCADE;

set datestyle to DMY;
set lc_numeric to 'fr_FR.UTF-8';

DROP TABLE IF EXISTS RennesInput;
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
FROM '/home/alice/Documents/Stage/MobilityDBInternship2024/Rennes/data/Freq_Mars2024_data.csv' DELIMITER ';' CSV HEADER;

--psql -d workshop -c "\copy RennesInput(DateFreq, TimeSlot15mn, Timeo, StopName, TownName, LineID, LineName, Direction, NbPersBoarding) FROM '/home/alice/Documents/Stage/MobilityDBInternship2024/Rennes/data/Freq_Mars2024_data.csv' DELIMITER  ';' CSV HEADER;"

SELECT * FROM RennesInput LIMIT 30;

UPDATE RennesInput 
SET NbPersBoarding =  REPLACE(NbPersBoarding , ',', '.');

/* To test */
ALTER TABLE RennesInput
    ADD COLUMN NbPersBoarding_num float;
UPDATE RennesInput
    SET NbPersBoarding_num = CAST(NbPersBoarding AS float);

ALTER TABLE RennesInput DROP COLUMN nbpersboarding;

SELECT * FROM RennesInput LIMIT 30;

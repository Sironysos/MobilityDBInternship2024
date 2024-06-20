CREATE EXTENSION mobilitydb CASCADE;

set datestyle to [DMY]

CREATE TABLE RennesInput(
  DateFreq date,
  TimeSlot15mn time,
  Timeo integer,
  StopName varchar(50),
  TownName varchar(50),
  LineID integer,
  LineName varchar(50),
  Direction varchar(10),
  NbPersBoarding float
);
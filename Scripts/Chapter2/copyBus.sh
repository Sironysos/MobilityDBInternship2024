psql -d RennesBusTrajectories -c "\copy BusInput (T, BusID, BusNumber, State, LineID, LineName,Direction, Destination, Position, Delay) FROM '/path/to/tposition-bus-clean.csv' DELIMITER ';' CSV HEADER;"

#!/bin/bash

input_file="../../data/Chapter5/station_information.json"

# Drop the raw_json_data table if it exists
psql -d bikes -c "DROP TABLE IF EXISTS raw_json_station;"

# Create the raw_json_data table
psql -d bikes -c "CREATE TABLE IF NOT EXISTS raw_json_station (json_data JSON);"

# Read the JSON data and escape single quotes
json_data=$(cat "$input_file" | sed "s/'/''/g")

# Insert the JSON data into the table
psql -d bikes -c "INSERT INTO raw_json_station (json_data) VALUES ('$json_data');"

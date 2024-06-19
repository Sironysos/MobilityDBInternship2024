#!/bin/bash

input_file="../../data/Chapter5/station.json"
temp_file="/tmp/processed_data.sql"

# Drop the raw_json_data table if it exists
psql -d bikes -c "DROP TABLE IF EXISTS raw_json_status;"

# Create the raw_json_data table
psql -d bikes -c "CREATE TABLE IF NOT EXISTS raw_json_status (timestamp TIMESTAMP, json_data JSON);"

# Initialize the temporary file
> $temp_file

# Read the input file line by line
while IFS= read -r line
do
    # Check if the line is a timestamp
    if [[ "$line" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2} ]]
    then
        timestamp="$line"
    else
        # Write an INSERT statement to the temporary file
        echo "INSERT INTO raw_json_status (timestamp, json_data) VALUES ('$timestamp', '$line');" >> $temp_file
    fi
done < $input_file

# Execute the SQL commands to insert data
psql -d bikes -f $temp_file

# Clean up
rm $temp_file

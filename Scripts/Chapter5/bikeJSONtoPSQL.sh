#!/bin/bash

input_file="../../data/Chapter5/free_bike.json"
temp_file="/tmp/processed_data.sql"

# Drop the raw_json_data table if it exists
psql -d bikes -c "DROP TABLE IF EXISTS raw_json_bike;"

# Create raw_json_data table if it doesn't exist
psql -d bikes -c "CREATE TABLE raw_json_bike (timestamp TIMESTAMP, json_data JSON);"

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
        echo "INSERT INTO raw_json_bike (timestamp, json_data) VALUES ('$timestamp', '$line');" >> $temp_file
    fi
done < $input_file

# Execute the SQL commands to insert data
psql -d bikes -f $temp_file

# Clean up
rm $temp_file

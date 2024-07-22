#!/bin/bash

# Initialize a variable to hold the timestamp
timestamp=""

# Process the input file line by line
while IFS= read -r line; do
    # Check if the line is a timestamp
    if [[ "$line" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2} ]]; then
        timestamp="$line"
    else
        # Process the JSON data with jq, using the current timestamp
        echo "$line" | jq -r --arg timestamp "$timestamp" '
        .data.bikes[] | {
            timestamp: $timestamp,
            bike_id,
            lat,
            lon,
            is_reserved,
            is_disabled
        } | [.timestamp, .bike_id, .lat, .lon, .is_reserved, .is_disabled] | @csv'
    fi
done < free_bike.json > bike_data.csv

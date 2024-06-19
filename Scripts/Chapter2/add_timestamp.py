import csv

# File paths (relative to the current working directory)
input_file_path = 'data/Chapter2/position-bus.csv'
output_file_path = 'data/Chapter2/tposition-bus.csv'

# Define the header row to detect repeated headers
header_row = ['Bus (ID)', 'Bus (numéro)', 'Etat', 'Ligne (ID)', 'Ligne (nom court)', 'Code du sens', 'Destination', 'Coordonnées', 'Avance / Retard']

# Open the input and output files
with open(input_file_path, 'r', newline='') as infile, open(output_file_path, 'w', newline='') as outfile:
    reader = csv.reader(infile, delimiter=';')
    writer = csv.writer(outfile, delimiter=';')
    
    current_timestamp = None
    header_written = False
    
    for row in reader:
        if len(row) == 1 and row[0].startswith("2024"):  # Check if the row contains a timestamp
            current_timestamp = row[0]
        elif row[1:] == header_row[1:] and header_written:  # Check if it's a repeated header
            continue  # Skip repeated headers
        else:
            if not header_written:
                writer.writerow(['Timestamp'] + row)  # Write the first header
                header_written = True
            else:
                writer.writerow([current_timestamp] + row)

print("Transformation complete. The output is saved in 'tposition-bus.csv'.")

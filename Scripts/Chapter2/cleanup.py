import csv


input_file = 'data/Chapter2/tposition-bus.csv'
output_file = 'data/Chapter2/tposition-bus-clean.csv'

def remove_invalid_lines(input_file, output_file):
    with open(input_file, 'r', newline='') as infile, open(output_file, 'w', newline='') as outfile:
        reader = csv.reader(infile, delimiter=';')
        writer = csv.writer(outfile, delimiter=';')
        
        first_row = True
        for row in reader:
            if first_row:
                writer.writerow(row)
                first_row = False
                continue
            # Check if the row has at least two columns and if the second column is an integer
            if len(row) > 1:
                try:
                    int(row[1])
                    writer.writerow(row)
                except ValueError:
                    # Skip the row if the second column is not an integer
                    pass

remove_invalid_lines(input_file, output_file)
print("Cleanup complete. The output is saved in 'tposition-bus-clean.csv'.")

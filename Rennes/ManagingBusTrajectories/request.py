import requests
import os

def get_filepaths():
    # Get the current working directory
    cwd = os.path.dirname(os.path.realpath(__file__))

    # Name of the 7 files to create
    filename1 = 'free_bike.json'
    filename2 = 'station.json'
    filename3 = 'alert.json'
    filename4 = 'position-bus.csv'
    filename5 = 'GTFS-vehicule'
    filename6 = 'GTFS-trip'
    filename7 = 'GTFS-alert'

    # Full paths of the 7 files
    filepath1 = os.path.join(cwd, filename1)
    filepath2 = os.path.join(cwd, filename2)
    filepath3 = os.path.join(cwd, filename3)
    filepath4 = os.path.join(cwd, filename4)
    filepath5 = os.path.join(cwd, filename5)
    filepath6 = os.path.join(cwd, filename6)
    filepath7 = os.path.join(cwd, filename7)

    return filepath1, filepath2, filepath3, filepath4, filepath5, filepath6, filepath7

# Use of the function above
filepath1, filepath2, filepath3, filepath4, filepath5, filepath6, filepath7 = get_filepaths()

# 7 download links
url1 = 'https://eu.ftp.opendatasoft.com/star/gbfs/free_bike_status.json'
url2 = 'https://eu.ftp.opendatasoft.com/star/gbfs/station_status.json'
url3 = 'https://eu.ftp.opendatasoft.com/star/gbfs/system_alerts.json'
url4 = 'https://data.explore.star.fr/api/explore/v2.1/catalog/datasets/tco-bus-vehicules-position-tr/exports/csv?lang=fr&timezone=Europe%2FBerlin&use_labels=true&delimiter=%3B'
url5 = 'https://proxy.transport.data.gouv.fr/resource/star-rennes-integration-gtfs-rt-vehicle-position'
url6 = 'https://proxy.transport.data.gouv.fr/resource/star-rennes-integration-gtfs-rt-trip-update'
url7 = 'https://proxy.transport.data.gouv.fr/resource/star-rennes-integration-gtfs-rt-alerts'

# Function to download the data
def download_data():
    urls = [url1, url2, url3, url4, url5, url6, url7]
    filepaths = [filepath1, filepath2, filepath3, filepath4, filepath5, filepath6, filepath7]

    for url, filepath in zip(urls, filepaths):
        try:
            response = requests.get(url)
            response.raise_for_status()  # Check for HTTP errors
            # Save the data to a file
            with open(filepath, 'ab') as file:
                file.write(response.content)
            print(f"Data {filepaths.index(filepath) + 1} downloaded successfully.")
        except requests.exceptions.RequestException as e:
            print(f"Error downloading data {filepaths.index(filepath) + 1}: {e}")

if __name__ == "__main__":
    download_data()

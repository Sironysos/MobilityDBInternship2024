import requests

# URL de téléchargement des données
url = 'http://example.com/data'

# Fonction pour télécharger les données
def download_data():
    try:
        response = requests.get(url)
        response.raise_for_status()  # Vérifie les erreurs HTTP
        # Sauvegarde des données dans un fichier
        with open('data.csv', 'wb') as file:
            file.write(response.content)
        print("Données téléchargées avec succès.")
    except requests.exceptions.RequestException as e:
        print(f"Erreur lors du téléchargement des données: {e}")

if __name__ == "__main__":
    download_data()

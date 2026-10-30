import requests as rq
import pandas as pd

url = "https://odre.opendatasoft.com/api/v2/catalog/datasets/eco2mix-national-tr/records?limit=1"

response = rq.get(url)

data = response.json()

liste_champs = [record["record"]["fields"] for record in data["records"]]

df = pd.DataFrame(liste_champs)

print("-- Aperçu du DataFrame --")
print(df[["date_heure", "consommation", "nucleaire", "eolien", "solaire"]].head())
print("\nDimensions du tableau (lignes et colonnes) : ", df.shape)
import requests
import random

# met_url = "https://collectionapi.metmuseum.org/public/collection/v1/objects"

def random_art():

    #get number of art peices
    met_url = "https://collectionapi.metmuseum.org/public/collection/v1/objects"
    response = requests.get(met_url)
    get_total = response.json()
    total = int(get_total['total'])

    max_attempts = 1000

    for _ in range(max_attempts):
        #get random art piece
        art_piece_url = f"https://collectionapi.metmuseum.org/public/collection/v1/objects/{str(random.randint(1, total))}"
        response = requests.get(art_piece_url)
        art_piece = response.json()

        if art_piece['primaryImage'] and 'primaryImage' in art_piece:
            # print(art_piece['primaryImage'])
            return art_piece['primaryImage']

    return "Ask again"

    # else:
    #     return art_piece['primaryImage']


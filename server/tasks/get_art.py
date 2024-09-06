import requests
import random

# met_url = "https://collectionapi.metmuseum.org/public/collection/v1/objects"

def random_art():

    #get number of art peices
    met_url = "https://collectionapi.metmuseum.org/public/collection/v1/objects"
    response = requests.get(met_url)
    get_total = response.json()
    total = int(get_total['total'])

    # max_attempts = 1000

    #initialize art_piece
    art_piece = {}

    while not art_piece.get('primaryImage'):

    # for _ in range(max_attempts):
        #get random art piece
        art_piece_url = f"https://collectionapi.metmuseum.org/public/collection/v1/objects/{str(random.randint(1, total))}"
        response = requests.get(art_piece_url)
        art_piece = response.json()

    #get the primary image attribute from the response
        primary_image = art_piece.get('primaryImage')
        # if exists else while loop continues.  A lot of objects from the met api don't have a primary-image.  weird
        if primary_image:
            # print(art_piece['primaryImage'])
            return primary_image
    
    return "Sorry - ask pyChat to do that again"



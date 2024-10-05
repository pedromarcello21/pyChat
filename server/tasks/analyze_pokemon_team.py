import json

def analyze_pokemon_team(team):
    current_team = {
        "pokemon1":team.pokemon1,
        "pokemon2":team.pokemon2,
        "pokemon3":team.pokemon3,
        "pokemon4":team.pokemon4,
        "pokemon5":team.pokemon5,
        "pokemon6":team.pokemon6,
    }
    return json.dumps(current_team)
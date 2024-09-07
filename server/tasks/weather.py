import requests
import os
import json
from dotenv import load_dotenv
load_dotenv()

weather_key = os.environ.get("WEATHER_API")

def get_weather(location):
    #get location key.  need this key to search weather conditions
    weather_location_url = f"http://dataservice.accuweather.com/locations/v1/cities/search?apikey={weather_key}&q={location}"
    response = requests.get(weather_location_url)
    results = response.json()
    # print(results[0]['LocalizedName'])
    location_key = results[0]['Key']

    weather_condition_url = f"http://dataservice.accuweather.com/currentconditions/v1/{location_key}?apikey={weather_key}"
    weather_response = requests.get(weather_condition_url)
    weather_result = weather_response.json()
    print(weather_result[0])

    current_weather = {
        "location": results[0]['LocalizedName'],
        "conditions":weather_result[0]['WeatherText'],
        "isRaining":weather_result[0]['HasPrecipitation'],
        "temp":weather_result[0]['Temperature']['Imperial']['Value']
    }

    return json.dumps(current_weather)

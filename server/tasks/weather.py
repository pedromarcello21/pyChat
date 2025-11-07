import requests
import os
import json
from dotenv import load_dotenv
load_dotenv()

weather_key = os.environ.get("WEATHER_API")

def get_weather():
    #get location key.  need this key to search weather conditions
    LATITUDE = "40.7736"
    LONGITUDE = "-73.9566"
    weather_location_url = f"https://weather.googleapis.com/v1/currentConditions:lookup?key={weather_key}&location.latitude={LATITUDE}&location.longitude={LONGITUDE}&unitsSystem=IMPERIAL"
    response = requests.get(weather_location_url)
    results = response.json()
    # print(results)
    # location_key = results[0]['Key']

    # weather_condition_url = f"http://dataservice.accuweather.com/currentconditions/v1/{location_key}?apikey={weather_key}"
    # weather_response = requests.get(weather_condition_url)
    # weather_result = weather_response.json()
    # print(weather_result[0])

    current_weather = {
        "description": results['weatherCondition']['description']['text'],
        "temperature":results['temperature']['degrees'],
        "precipitation":results['precipitation']['probability']
    }
    print(json.dumps(current_weather))

    return json.dumps(current_weather)
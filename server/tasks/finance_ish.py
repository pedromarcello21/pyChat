import requests
import os
import json
from dotenv import load_dotenv
load_dotenv()

alpha_vantage_key = os.environ.get("ALPHA_VANTAGE_API")


# replace the "demo" apikey below with your own key from https://www.alphavantage.co/support/#api-key
url = f'https://www.alphavantage.co/query?function=DIGITAL_CURRENCY_DAILY&symbol=BTC&market=USD&apikey={alpha_vantage_key}'
r = requests.get(url)
data = r.json()

print(data['Time Series (Digital Currency Daily)']['2024-09-06'])
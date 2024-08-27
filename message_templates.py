from datetime import datetime, timedelta
import json

def introduction_at_company(company):
    return f"Hi, I'm Pedro Vincenty and I'd love to learn more about the culture at {company}."

def get_flight_info(loc_origin, loc_destination):
    """Get flight information between two locations."""
    flight_info = {
        "loc_origin": loc_origin,
        "loc_destination": loc_destination,
        "datetime": str(datetime.now() + timedelta(hours=2)),
        "airline": "LIT",
        "flight": "LIT21",
    }
    return json.dumps(flight_info)

#email ish

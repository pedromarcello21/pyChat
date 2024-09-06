from datetime import datetime, timedelta
import json

def introductory_linkedin_msg(company, name, purpose = "Recruiter"):
    if purpose == "Flatiron":
        return f"Hi {name},\nI'm Pedro, a fellow Flatiron School alum. I see you're now at {company}- I'd love to connect and hear about your journey for navigating the job market post-graduation.\nThanks!"
    elif purpose == "Recruiter":
        return f"Hi {name},\nI'm Pedro, an entry-level developer passionate about supporting mission-driven teams. Do you have time to connect soon? I'd love to learn more about the roles staffed by {company}."    
    elif purpose == "Hiring Manager":
        return f"Hi {name},\nI'm Pedro, an entry level software developer passionate about providing technical advantages for mission driven teams. I'd love to learn more about the roles at {company}."
    elif purpose == "Fordham":
        return f"Hi {name},\nI'm Pedro, a fellow Fordham alum. I'd love to connect and lear about the culture at {company}.\nThanks!"



def wellfound_msg(company, name):
    return f"""Hi {name},

I hope you're doing well. I'm Pedro Vincenty, a multi-disciplined problem solver with a strong programming background. I recently completed Flatiron’s Software Engineering program, which has equipped me with full stack development skills. Prior to that, my experience as a Data Engineer gave me valuable exposure to collaborating with cross-functional teams and contributing effectively from a technical standpoint.  My MBA from Fordham University provided me a tremendous experience to connect with like-minded professionals and hone both my technical and intrapersonal skills.

I have a demonstrated ability to simplify complex technical concepts for diverse audiences, enhancing both communication and project outcomes. I'd love the opportunity to connect and discuss how my skills could support your team at {company}.

Best,
Pedro"""

# def get_flight_info(loc_origin, loc_destination):
#     """Get flight information between two locations."""
#     flight_info = {
#         "loc_origin": loc_origin,
#         "loc_destination": loc_destination,
#         "datetime": str(datetime.now() + timedelta(hours=2)),
#         "airline": "LIT",
#         "flight": "LIT21",
#     }
#     return json.dumps(flight_info)

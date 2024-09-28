from dotenv import load_dotenv
import os
import openai

import json
import requests
# Remote library imports
from flask import request, session, jsonify
from flask_restful import Resource
from sqlalchemy import and_



from datetime import datetime, timedelta
from tasks.message_templates import introductory_linkedin_msg, wellfound_msg #get_flight_info, 
from tasks.email_script import send_email
from tasks.selenium_tasks import find_flight
from tasks.open_applications import open_application
from tasks.get_art import random_art
from tasks.weather import get_weather

from config import app, db, api

from models import Lead, Contact, Reminder

# Load environment variables from .env file
load_dotenv()

# Access the environment variable for OpenAI API key
openai.api_key = os.getenv('API_KEY')

############################ FUNCTION DESCRIPTIONS ###############################

function_descriptions = [
    # {
    #     "name": "get_flight_info",
    #     "description": "Get flight information between two locations",
    #     "parameters": {
    #         "type": "object",
    #         "properties": {
    #             "loc_origin": {
    #                 "type": "string",
    #                 "description": "The departure airport, e.g. DUS",
    #             },
    #             "loc_destination": {
    #                 "type": "string",
    #                 "description": "The destination airport, e.g. HAM",
    #             },
    #         },
    #         "required": ["loc_origin", "loc_destination"],
    #     },
    # },
    {
        "name": "get_weather",
        "description": "Get weather information for give location.  In response say the name of the location rather than 'your location'",
        "parameters": {
            "type": "object",
            "properties": {
                "location": {
                    "type": "string",
                    "description": "the location to retrive weather information for",
                }
            },
            "required": ["location"],
        },
    },
    {
        "name": "introductory_linkedin_msg",
        "description": "Get the message template returned by the introductory_linkedin_msg function that's relevant to the purpose of the message.  I.e. who the message is intended for.",
        "parameters": {
            "type": "object",
            "properties": {
                "purpose": {
                    "type": "string",
                    "description": "The message to be returned depending on the nature of the recipient.  If the purpose is to connect with a flatiron graduate return Flatiron.  If the purpose is to connect with a recruiter return Recruiter.If the purpose is to connect with a hiring manager return Hiring Manager.If the purpose is to connect with a Fordham alum return Fordham. If the purpose is to connect with a Loyola alum return Loyola",
                },                
                "company": {
                    "type": "string",
                    "description": "The name of the company",
                },
                "name": {
                    "type": "string",
                    "description": "The name of the recipient",
                }

            },
            "required": ["company", "name", "purpose"]
        }
    },
    {
        "name": "wellfound_msg",
        "description": "Get the message template returned by the wellfound_msg function to write a message to the hiring manager when browsing jobs on wellfound.",
        "parameters": {
            "type": "object",
            "properties": {              
                "company": {
                    "type": "string",
                    "description": "The name of the company",
                },
                "name": {
                    "type": "string",
                    "description": "The name of the recipient",
                }

            },
            "required": ["company", "name"]
        }
    },
    {
        "name": "send_email",
        "description": "Send an introductory email",
        "parameters": {
            "type": "object",
            "properties": {
                "receiver": {
                    "type": "string",
                    "description": "The email of the recepient we are writing to. E.G. vincentypedro@gmail.com",
                },
                "company": {
                    "type": "string",
                    "description": "The company the receiver works for",
                },
                "name": {
                    "type": "string",
                    "description": "The name the person the email is addressed to",
                },
                "purpose": {
                    "type": "string",
                    "description": "The message to be returned depending on the nature of the recipient.  If the purpose is to connect with a flatiron graduate return Flatiron. If the purpose is to connect with a Fordham alum return Fordham.",
                }, 
                "resume": {
                    "type": "string",
                    "description": "Option to include resume.  If resume is included set it as True.  Else set it as False.",
                },
            },
            "required": ["receiver", "company", "name", "purpose","resume"]
        }
    },
    {
        "name": "open_application",
        "description": "Open Desktop Application",
        "parameters": {
            "type": "object",
            "properties": {
                "application": {
                    "type": "string",
                    "description": "The application to open in the mac environment",
                }
            },
            "required": ["application"]
        }
    },
    {
        "name": "find_flight",
        "description": "Find flight to destination",
        "parameters": {
            "type": "object",
            "properties": {
                "destination": {
                    "type": "string",
                    "description": "The destination the user would like to travel to",
                },
                # annoying bug that gives me a random date
                "date": {
                    "type": "string",
                    "description": "The date provided by the user to find flights for. Date needs to be in format 'YYYY-mm-dd'.  If no date provided the function will use a default value",
                }

            },
            "required": ["destination"]
        }
    },
        {
        "name": "random_art",
        "description": "get random piece of art from the MET"
        # "parameters": {
        #     "type": "object",
        #     "properties": {
        #         "destination": {
        #             "type": "string",
        #             "description": "The destination the user would like to travel to",
        #         }
        #     },
        #     "required": ["destination"]
        # }
    }


]

# --------------------------------------------------------------
# Function to Handle Chat with Optional Function Calling
# --------------------------------------------------------------

def chat_with_pychat(prompt):
    completion = openai.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": prompt}],
        functions=function_descriptions,
        #automatically detect the function call
        function_call="auto", 
    )
    
    output = completion.choices[0].message
    
    # Check if the output contains a function call
    if output.function_call != None:
        print(output)
        if output.function_call.name in ["get_flight_info", "get_weather"] :
            # Here we add the function output back to the messages with role: function
            
            # Parse the function call and arguments
            function_name = output.function_call.name
            params = json.loads(output.function_call.arguments)
            
            # Dynamically call the appropriate function
            chosen_function = eval(function_name)
            answer = chosen_function(**params)

            second_completion = openai.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[
                    # {"role":"user", "content":user_input},
                    {"role":"function", "name":function_name, "content":answer}
                ],
                functions=function_descriptions,
            )


            response = second_completion.choices[0].message.content

            # Print the final response from GPT
            return response



        # else:
        # Parse the function call and arguments
        function_name = output.function_call.name
        params = json.loads(output.function_call.arguments)
        
        if len(params) > 0:
            # Dynamically call the appropriate function
            chosen_function = eval(function_name)
            answer = chosen_function(**params)
            
            # Return the function result as the response
            return answer
        else:
            # Dynamically call the appropriate function
            chosen_function = eval(function_name)
            answer = chosen_function()
            
            # Return the function result as the response
            return answer


    # If no function call, return the content directly
    else:
        return output.content.strip()


# --------------------------------------------------------------
# Main Loop for Continuous Conversation
# --------------------------------------------------------------

# if __name__ == "__main__":
#     while True:
#         user_input = input(">>> ")
#         if user_input.lower() in ["bye", "exit", "quit"]:
#             break
        
#         response = chat_with_pychat(user_input)
#         print("pyChat:", response)

######### Routes ############
@app.post('/prompt')
def send_prompt():
    data = request.json
    prompt = data.get("prompt", "")
    respose = chat_with_pychat(prompt)
    return respose

#### Routes for Leads ####
@app.post('/leads')
def add_lead():
    data = request.json
    new_lead = Lead(**data)
    db.session.add(new_lead)
    db.session.commit()
    return new_lead.to_dict(), 201

@app.get('/leads')
def get_leads():
    all_leads = Lead.query.all()
    return [leads.to_dict() for leads in all_leads], 200

@app.delete('/leads/<int:id>')
def remove_lead(id):
    found_lead = Lead.query.where(Lead.id == id).first()
    if found_lead:
        db.session.delete(found_lead)
        db.session.commit()
        return {}, 204
    else:
        return "Lead not found"

@app.patch('/leads/<int:id>')
def update_lead(id):
    found_lead = Lead.query.where(Lead.id == id).first()
    data = request.json

    for key, value in data.items():
        if hasattr(found_lead, key):
            setattr(found_lead, key, value)
    db.session.add(found_lead)
    db.session.commit()
    return found_lead.to_dict(), 200

#### Routes for Contacts
@app.post('/contacts')
def add_contact():
    data = request.json
    found_contact = Lead.query.filter_by(id=data['company_id']).first() 
    if found_contact:
        new_contact = Contact(
            company_id = found_contact.id,
            name = data['name'],
            email = data['email'],
            number = data['number']
        )
        db.session.add(new_contact)
        db.session.commit()

        return new_contact.to_dict(), 200
    else:
        return {'error': "lead not found"}
    
##GET all contacts

@app.get('/contacts')
def get_all_contacts():
    contacts = Contact.query.all()
    return [contact.to_dict() for contact in contacts]

# get contacts from specific company
@app.get('/contacts/<int:id>')
def get_contacts(id):
    company = Lead.query.where(Lead.id == id).first()
    contacts = company.contacts
    return [contact.to_dict() for contact in contacts]

# update contact
@app.patch('/contacts/<int:id>')
def update_contact(id):
    found_contact = Contact.query.where(Contact.id == id).first()
    data = request.json
    for key, value in data.items():
        if hasattr(found_contact, key):
            setattr(found_contact, key, value)
    db.session.add(found_contact)
    db.session.commit()
    return found_contact.to_dict(), 200

# delete contact
@app.delete('/contacts/<int:id>')
def delete_contact(id):
    found_contact = Contact.query.where(Contact.id == id).first()
    db.session.delete(found_contact)
    db.session.commit()
    return {}, 204

##Reminders Routes
#Create reminder

@app.post('/reminders')
def add_reminder():
    data = request.json
    date = datetime.strptime(data['alert'],'%Y-%m-%d %H:%M')
    new_reminder = Reminder(
        contact_id = data['contact_id'],
        alert = date,
        note = data['note']
    )
    db.session.add(new_reminder)
    db.session.commit()
    return new_reminder.to_dict(), 201

#Get reminder

@app.get('/reminders')
def get_reminders():
    #handle specific searches.  i.e. /reminders?contact_id=1
    contact_id = request.args.get('contact_id')
    try:
        if contact_id:
            reminders = Reminder.query.where(Reminder.contact_id == contact_id).all()
        else:
            reminders = Reminder.query.all()
        return [reminder.to_dict() for reminder in reminders]
    except:
        return {"error":"no reminders"}

#get upcoming reminders
@app.get('/upcoming-reminders')
def get_upcoming_reminders():
    time_limit = datetime.now() + timedelta(days=3)

    upcoming_reminders = Reminder.query.where(
        and_(
            Reminder.alert < time_limit,
            Reminder.alert > datetime.now()  # This ensures reminders are in the future
        )
    ).all()    
    return [upcoming_reminder.to_dict() for upcoming_reminder in upcoming_reminders]






if __name__ == '__main__':
    app.run(port=5555, debug=True)





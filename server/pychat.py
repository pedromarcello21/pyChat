from dotenv import load_dotenv
import os
import openai

import json
import requests
# Remote library imports
from flask import request, session, jsonify
from flask_restful import Resource


from datetime import datetime, timedelta
from tasks.message_templates import introductory_linkedin_msg, wellfound_msg #get_flight_info, 
from tasks.email_script import send_email
from tasks.selenium_tasks import find_flight
from tasks.open_applications import open_application
from tasks.get_art import random_art

from config import app, db, api

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
        "name": "introductory_linkedin_msg",
        "description": "Get the message template returned by the introductory_linkedin_msg function that's relevant to the purpose of the message.  I.e. who the message is intended for.",
        "parameters": {
            "type": "object",
            "properties": {
                "purpose": {
                    "type": "string",
                    "description": "The message to be returned depending on the nature of the recipient.  If the purpose is to connect with a flatiron graduate return Flatiron.  If the purpose is to connect with a recruiter return Recruiter.If the purpose is to connect with a hiring manager return Hiring Manager.If the purpose is to connect with a Fordham alum return Fordham.",
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
                "resume": {
                    "type": "string",
                    "description": "Option to include resume.  If resume is included set it as True.  Else set it as False.",
                },
            },
            "required": ["receiver", "company", "name", "resume"]
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
                #annoying bug that gives me a random date
                # "date": {
                #     "type": "string",
                #     "description": "The date provided by the user to find flights for. If date is not provided use today's date. If year not provided assume current year.  Date needs to be in format YYYY-mm-dd",
                # }

            },
            "required": ["destination", "date"]
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
        # if output.function_call.name=="get_flight_info":
        #     # Here we add the function output back to the messages with role: function
            
        #     # Parse the function call and arguments
        #     function_name = output.function_call.name
        #     params = json.loads(output.function_call.arguments)
            
        #     # Dynamically call the appropriate function
        #     chosen_function = eval(function_name)
        #     answer = chosen_function(**params)

        #     second_completion = openai.chat.completions.create(
        #         model="gpt-3.5-turbo",
        #         messages=[
        #             {"role":"user", "content":user_input},
        #             {"role":"function", "name":function_name, "content":answer}
        #         ],
        #         functions=function_descriptions,
        #     )


        #     response = second_completion.choices[0].message.content

        #     # Print the final response from GPT
        #     return response



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

@app.post('/prompt')
def send_prompt():
    data = request.json
    prompt = data.get("prompt", "")
    respose = chat_with_pychat(prompt)
    return respose

if __name__ == '__main__':
    app.run(port=5555, debug=True)





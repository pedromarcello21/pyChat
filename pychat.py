from dotenv import load_dotenv
import os
import openai

import json
import requests
# Remote library imports
from flask import request, session
from flask_restful import Resource


from datetime import datetime, timedelta
from message_templates import get_flight_info, introduction_at_company
from email_script import send_email

from config import app, db, api

# Load environment variables from .env file
load_dotenv()

# Access the environment variable for OpenAI API key
openai.api_key = os.getenv('API_KEY')

############################ FUNCTION DESCRIPTIONS ###############################

function_descriptions = [
    {
        "name": "get_flight_info",
        "description": "Get flight information between two locations",
        "parameters": {
            "type": "object",
            "properties": {
                "loc_origin": {
                    "type": "string",
                    "description": "The departure airport, e.g. DUS",
                },
                "loc_destination": {
                    "type": "string",
                    "description": "The destination airport, e.g. HAM",
                },
            },
            "required": ["loc_origin", "loc_destination"],
        },
    },
    {
        "name": "introduction_at_company",
        "description": "Get the message returned by the introduction_at_company function",
        "parameters": {
            "type": "object",
            "properties": {
                "company": {
                    "type": "string",
                    "description": "The name of the company",
                }
            },
            "required": ["company"]
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
                    "description": "The email of the recepient we are writing to",
                },
                "company": {
                    "type": "string",
                    "description": "The company the receiver works for",
                },
            },
            "required": ["receiver", "company"]
        }
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
        function_call="auto",  # Automatically detect the function call
    )
    
    output = completion.choices[0].message
    
    # Check if the output contains a function call
    if output.function_call != None:
        print(output)
        if output.function_call.name=="get_flight_info":
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
                    {"role":"user", "content":user_input},
                    {"role":"function", "name":function_name, "content":answer}
                ],
                functions=function_descriptions,
            )


            response = second_completion.choices[0].message.content

            # Print the final response from GPT
            return response



        else:
            # Parse the function call and arguments
            function_name = output.function_call.name
            params = json.loads(output.function_call.arguments)
            
            # Dynamically call the appropriate function
            chosen_function = eval(function_name)
            answer = chosen_function(**params)
            
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





import os

def open_application(application):
    try:
        os.system(f"open /Applications/{application.capitalize()}.app")
        return f"Opening {application}..."
    except:
        return "Coundn't find that application"

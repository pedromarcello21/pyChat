import os

def open_application(application):

    #define apple specific applications.  follows below syntax
    apple_apps = {
        "reminders":"com.apple.reminders",
        "messages":"com.apple.MobileSMS"
    }
    try:
        if application.lower() in apple_apps:
            #to open apple specific applications
            os.system(f"open -b {apple_apps[application.lower()]}")
            return f"Opening {application}..."
        else:
            os.system(f"open /Applications/{application.capitalize()}.app")
            return f"Opening {application}..."
    except:
        return "Coundn't find that application"

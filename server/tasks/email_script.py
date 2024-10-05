import os
from dotenv import load_dotenv

from email.message import EmailMessage
#layer of security for keeping information secure
import ssl
import smtplib

load_dotenv()


def send_email(receiver, company, name, role, link = "", purpose = "cold", resume = "False"):
    """Send introductory email"""
    email_sender="vincentypedro@gmail.com"
    email_password = os.environ.get("EMAIL_PASSWORD")
    email_receiver = receiver

    subject = "Introduction | Pedro Vincenty"
    if purpose == "Fordham":
        body= f"Hi {name.capitalize()},\n\nI'm Pedro Vincenty and I came across your contact information as I was browsing the Fordham Alumni Database. I'd love to connect and learn more about the positions staffed by {company.title()}.  \n\nIf you have any availability in the coming days, I'd love to schedule a 10 minute conversation.\n\nBest,\nPedro"
    elif purpose == "Flatiron":
        body= f"Hi {name.capitalize()},\n\nI'm Pedro Vincenty, a fellow Flatiron Alum! I'd love to connect and learn more about the culture at {company.title()}.  \n\nIf you have any availability in the coming days, I'd love to schedule a 10 minute conversation.\n\nBest,\nPedro"
    elif purpose == "Recruiter":
        resume = "True"
        body = f"Hi {name.capitalize()},\n\nI'm Pedro Vincenty, and I just applied for the {role.title()} role below recently posted by your company. I'd love to connect to further introduce myself and share how my candidacy can contribute effecticvely towards your clientele.  \n\nIf you have any availability in the coming days, I'd love to schedule a 10 minute conversation.  Attached is my resume for your review.\n\n{link}\n\nBest,\nPedro"
    else:
        resume = "True"
        body= f"Hi {name.capitalize()},\n\nI'm Pedro Vincenty, and I just applied for the {role.title()} role recently posted by your company. I'd love to connect and learn more about the culture at {company.title()} and how my candidacy can contribute effecticvely towards your team.  \n\nIf you have any availability in the coming days, I'd love to schedule a 10 minute conversation.  Attached is my resume for your review.  \n\nBest,\nPedro"



    em = EmailMessage()

    em['From'] = "Pedro Vincenty"
    em['To'] = email_receiver
    em['Subject'] = subject

    em.set_content(body)



    ##Attach resume

    #Chat completion passes resume value as True of False but as a string.  So need to compare to string value of True or False
    if resume == "True":

        #not reading resume in relative path rather the one on my machine
        resume_path = "/Users/pedro/Desktop/Job Ish/Pedro Vincenty's Resume.pdf"
        try:
            with open(resume_path, 'rb') as file:
                file_data = file.read() 
                file_name = os.path.basename(resume_path) 
                em.add_attachment(file_data, maintype='application', subtype='octet-stream', filename=file_name)
            # I wish this would work but it does't
            # body +="\n\nI've attached my resume for your review."

        except Exception as e:
            return f"Error opening file: {e}"
        
    
    context = ssl.create_default_context()


    try:
        #from stack overflow
        with smtplib.SMTP_SSL('smtp.gmail.com', 465, context = context) as smtp:
            smtp.login(email_sender, email_password)
            smtp.send_message(em)
            return "Sent!"
    except:
        return "error sending email"
import os
from dotenv import load_dotenv

from email.message import EmailMessage
#layer of security for keeping information secure
import ssl
import smtplib

load_dotenv()


def send_email(receiver, company, name, resume = "False"):
    """Send introductory email"""
    email_sender="vincentypedro@gmail.com"
    email_password = os.environ.get("EMAIL_PASSWORD")
    email_receiver = receiver

    subject = "Introduction | Pedro Vincenty"
    body= f"Hi {name.capitalize()},\n\nI'm Pedro Vincenty and I came across your contact information as I was browsing the Fordham Alumni Database. I'd love to connect and learn more about the culture at {company.title()}.  \n\nIf you have any availability in the coming days, I'd love to schedule a 10 minute conversation."

    em = EmailMessage()

    em['From'] = "Pedro Vincenty"
    em['To'] = email_receiver
    em['Subject'] = subject


    ##Attach resume

    #Chat completion passes resume value as True of False but as a string.  So need to compare to string value of True or False
    if resume == "True":

        #not reading resume in relative path rather the one on my machine
        resume_path = "/Users/pedro/Desktop/Pedro Vincenty's Resume.pdf"
        try:
            with open(resume_path, 'rb') as file:
                file_data = file.read() 
                file_name = os.path.basename(resume_path) 
                em.add_attachment(file_data, maintype='application', subtype='octet-stream', filename=file_name)
            # I wish this would work but it does't
            # body +="\n\nI've attached my resume for your review."

        except Exception as e:
            return f"Error opening file: {e}"
        

    body +="\n\nBest,\nPedro"

    em.set_content(body)

    
    context = ssl.create_default_context()


    try:
        #from stack overflow
        with smtplib.SMTP_SSL('smtp.gmail.com', 465, context = context) as smtp:
            smtp.login(email_sender, email_password)
            smtp.send_message(em)
            return "Sent!"
    except:
        return "error sending email"
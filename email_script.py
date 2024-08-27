import os
from dotenv import load_dotenv

from email.message import EmailMessage
#layer of security for keeping information secure
import ssl
import smtplib

load_dotenv()


def send_email(receiver, company):
    """Send introductory email"""
    email_sender="vincentypedro@gmail.com"
    email_password = os.environ.get("EMAIL_PASSWORD")
    email_receiver = receiver

    subject = "Introduction | Pedro Vincenty and resume"
    body= f"Hi,\n\nI'm Pedro Vincenty and I came across your information as I was looking at the Fordham Alumni Database.  I'd love to connect and learn more about the culture at {company}.  \n\nIf you share some availability I'd be happy to schedule a 10 minute conversation.\n\nBest,\n\nPedro"

    em = EmailMessage()

    em['From'] = "Pedro Vincenty"
    em['To'] = email_receiver
    em['Subject'] = subject
    em.set_content(body)

    ##Attach resume

    resume_path="/Users/pedro/Desktop/pychat/Pedro Vincenty's Tech Resume.pdf"
    with open(resume_path, 'rb') as file:
        file_data = file.read()
        file_name = os.path.basename(resume_path)
        em.add_attachment(file_data, maintype='application', subtype='octet-stream', filename=file_name)

    context = ssl.create_default_context()


    try:
        with smtplib.SMTP_SSL('smtp.gmail.com', 465, context = context) as smtp:
            smtp.login(email_sender, email_password)
            smtp.sendmail(email_sender, email_receiver, em.as_string())
            return "Sent!"
    except:
        return "error sending email"
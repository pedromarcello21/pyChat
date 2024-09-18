from sqlalchemy_serializer import SerializerMixin
from sqlalchemy.ext.associationproxy import association_proxy
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import validates


from config import db, bcrypt
import re

class Lead(db.Model):
    __tablename__ = 'leads'

    id = db.Column(db.Integer, primary_key=True)
    company = db.Column(db.String)
    postings = db.Column(db.Boolean)
    alumni = db.Column(db.Boolean)

    #Relationships

    contacts = db.relationship('Contact', back_populates='lead', cascade="all, delete-orphan")

    def to_dict(self):
        return {
            'company':self.company,
            'postings':self.postings,
            'alumni':self.alumni,
            'contacts':[contact.to_dict() for contact in self.contacts]
        }

    def __repr__(self):
        return f"Lead(company={self.company}, contact={self.contact})"

class Contact(db.Model):
    __tablename__ = 'contacts'
    id = db.Column(db.Integer, primary_key=True)
    company_id = db.Column(db.Integer, db.ForeignKey('leads.id'))
    name = db.Column(db.String)
    email = db.Column(db.String)
    number = db.Column(db.String)

    #Relationships
    lead = db.relationship('Lead', back_populates='contacts')
    reminder = db.relationship('Reminder', uselist = False, back_populates='contact', cascade='all, delete-orphan')

    def to_dict(self):
        return {
            'company':self.company_id,
            'name':self.name,
            'email':self.email,
            'number':self.number
        }
    def __repr__(self):
        return f"Contact(company={self.company_id}, name={self.name}, email={self.email}, number={self.number})"

class Reminder(db.Model):
    __tablename__ = 'reminders'
    id = db.Column(db.Integer, primary_key=True)
    contact_id = db.Column(db.Integer, db.ForeignKey('contacts.id'))
    alert = db.Column(db.DateTime)

    #Relationship
    contact = db.relationship('Contact', back_populates='reminder')

    def to_dict(self):
        return{
            'contact':self.contact.to_dict(),
            'alert':self.alert

        }
    def __repr__(self):
        return f"Reminder(contact_id={self.contact_id}, alert={self.alert})"
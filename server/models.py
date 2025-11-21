from sqlalchemy_serializer import SerializerMixin
from sqlalchemy.ext.associationproxy import association_proxy
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import validates

######## flask --app pychat db migrate -m "9/28  work"   


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
            'id':self.id,
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
    reminders = db.relationship('Reminder', back_populates='contact', cascade='all, delete-orphan')

    def to_dict(self):
        return {
            'id':self.id,
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
    contact_id = db.Column(db.Integer, db.ForeignKey('contacts.id'), nullable = True)
    alert = db.Column(db.DateTime)
    note = db.Column(db.String)

    #Relationship
    contact = db.relationship('Contact', back_populates='reminders')

    def to_dict(self):
        return{
            'id':self.id,
            'contact':self.contact.to_dict() if self.contact else None,
            'alert': self.alert.strftime('%Y-%m-%d %H:%M'),  # Format the datetime
            'note':self.note

        }
    def __repr__(self):
        return f"Reminder(contact_id={self.contact_id}, alert={self.alert}, note = {self.note})"

class PokemonTeam(db.Model):
    __tablename__ = 'pokemon_teams'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String)
    pokemon_1 = db.Column(db.String)
    pokemon_2 = db.Column(db.String)
    pokemon_3 = db.Column(db.String)
    pokemon_4 = db.Column(db.String)
    pokemon_5 = db.Column(db.String)
    pokemon_6 = db.Column(db.String)
    analysis = db.Column(db.String)

    def to_dict(self):
        return{
            'id':self.id,
            'name':self.name,
            'pokemon_1':self.pokemon_1,
            'pokemon_2':self.pokemon_2,
            'pokemon_3':self.pokemon_3,
            'pokemon_4':self.pokemon_4,
            'pokemon_5':self.pokemon_5,
            'pokemon_6':self.pokemon_6,
            'analysis':self.analysis
        }
    def __repr__(self):
        return f"Pokemon Team(id={self.id}, name={self.name}, pokemon_1={self.pokemon_1}, pokemon_2={self.pokemon_2}, pokemon_3={self.pokemon_3}, pokemon_4={self.pokemon_4}, pokemon_5={self.pokemon_5}, pokemon_6={self.pokemon_6}, analysis={self.analysis})"

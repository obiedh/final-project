"""
This module defines the User model, representing the users in the system.

Attributes:
    - uid (UUID): Primary key for each user.
    - username (String): Unique username for the user.
    - password (String): Encrypted password for the user.
    - phonenum (String): Unique phone number for the user.
    - user_type (String): Type of user (e.g., "manager", "regular").
    - preference (String): User preferences (optional).
    - favorites: Relationship to the Favorites model, representing the user's favorite fields.
    - ratings: Relationship to the Ratings model, representing the user's ratings.
    - fields_managed: Relationship to the Field model, representing the fields managed by the user.
    - payments: Relationship to the Payments model, representing the user's payment methods.
"""

from sqlalchemy import String
from svc.db import db

class User(db.Model):
    __tablename__ = 'users'

    uid = db.Column(db.UUID(as_uuid=True), unique=True, nullable=False, primary_key=True)
    username = db.Column(String(50), unique=True)
    password = db.Column(String(250))
    phonenum = db.Column(String(12), unique=True)
    user_type = db.Column(String(20))
    preference = db.Column(String, nullable=True)

    favorites = db.relationship('Favorites', back_populates='user')
    ratings = db.relationship('Ratings', back_populates='user')
    fields_managed = db.relationship('Field', back_populates='manager')
    payments = db.relationship('Payments', back_populates='user')

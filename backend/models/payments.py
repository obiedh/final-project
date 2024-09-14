"""
This module defines the Payments model, representing user payment information.

Attributes:
    - holder_id (Integer): The ID of the cardholder.
    - card_number (String): The primary key representing the card number.
    - digit_code (String): The security code of the card.
    - month (String): The expiration month of the card.
    - card_name (String): The name on the card.
    - year (String): The expiration year of the card.
    - user_uid (UUID): Foreign key linking to the user who owns the payment method.
    - user: Relationship to the User model, representing the owner of the payment method.
"""

from sqlalchemy import Column, ForeignKey
from svc.db import db

class Payments(db.Model):
    __tablename__ = 'payments'

    holder_id = db.Column(db.Integer)
    card_number = db.Column(db.String(100), primary_key=True)
    digit_code = db.Column(db.String(100))
    month = db.Column(db.String(100))
    card_name = db.Column(db.String(100))
    year = db.Column(db.String(100))
    user_uid = Column(db.UUID(as_uuid=True), ForeignKey('users.uid'), nullable=False)

    # Define a reference to the user model
    user = db.relationship('User', back_populates='payments')

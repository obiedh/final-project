"""
This module provides the Data Access Object (DAO) for the Payments model, managing database interactions for user payments.

Methods:
    - create_payment(data): Creates a new payment record based on the provided data.
    - get_payment_by_id(user_id): Retrieves all payment records for a specific user by their user ID.
    - get_payment_by_card_number(card_number): Retrieves a payment record by the card number.
    - delete_payment_by_card_number(card_number): Deletes a payment record by the card number.
"""

from models.payments import Payments
from svc.db import db

class PaymentsDAO:
    def create_payment(self, data):
        """Creates a new payment record for a user."""
        new_payment = Payments(
            user_uid=data['userid'],
            holder_id=data['carHolderID'],
            card_number=data['cardNumber'],
            card_name=data['name'],
            digit_code=data['digitCode'],
            month=data['month'],
            year=data['year']
        )
        db.session.add(new_payment)
        db.session.commit()
        return {"message": "Payment created successfully"}
    
    def get_payment_by_id(self, user_id):
        """Retrieves all payment records for a specific user by their user ID."""
        return db.session.query(Payments).filter(Payments.user_uid == user_id).all()

    def get_payment_by_card_number(self, card_number):
        """Retrieves a payment record by the card number."""
        return db.session.query(Payments).filter(Payments.card_number == card_number).first()
    
    def delete_payment_by_card_number(self, card_number):
        """Deletes a payment record by the card number."""
        payment = db.session.query(Payments).filter(Payments.card_number == card_number).first()
        if payment:
            db.session.delete(payment)
            db.session.commit()
            return True
        return False

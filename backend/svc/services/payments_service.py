"""
This module provides the service layer for managing payments, handling business logic and interacting with the PaymentsDAO and UserDAO.

Methods:
    - create_payments(data): Creates a new payment for a user after validating the necessary information.
    - get_payment(user_id): Retrieves all payment methods for a specific user.
    - delete_payment(data): Deletes a payment by card number, validating the user and payment existence.
"""

from flask import jsonify
from svc.dao.payments_dao import PaymentsDAO
from svc.dao.user_dao import UserDAO

class PaymentsService:

    def __init__(self):
        self.payments_dao = PaymentsDAO()
        self.user_dao = UserDAO()

    def create_payments(self, data):
        """Creates a new payment for a user after validating necessary fields and ensuring the user exists."""
        user_id = data.get('userid')
        if not user_id:
            return {"error": "User ID is required"}, 400

        # Check if the user exists
        user = self.user_dao.get_user_by_id(user_id)
        if not user:
            return {"error": "User does not exist"}, 404

        # Validate required fields
        required_fields = ['carHolderID', 'cardNumber', 'digitCode', 'month', 'year', 'name']
        for field in required_fields:
            if not data.get(field):
                return {"error": f"{field} is required"}, 400

        # Check if a payment with the same card number already exists
        existing_payment = self.payments_dao.get_payment_by_card_number(data['cardNumber'])
        if existing_payment:
            return {"error": "A payment with this card number already exists"}, 400

        return self.payments_dao.create_payment(data), 201

    def get_payment(self, user_id):
        """Retrieves all payment methods for a specific user."""
        if not user_id:
            return "User ID is required", 400
        
        payments = self.payments_dao.get_payment_by_id(user_id)
        if payments:
            payment_response = [{"cardNumber": payment.card_number, "name": payment.card_name} for payment in payments]
            return payment_response, 200
        return {"message": "No payments found for this user"}, 404

    def delete_payment(self, data):
        """Deletes a payment by card number after validating user and payment existence."""
        payment_id = data["cardNumber"]
        user_id = data["user_id"]
        
        if not payment_id:
            return {"error": "Card Number is required"}, 400
        
        user = self.user_dao.get_user_by_id(user_id)
        if not user:
            return {"error": "User does not exist"}, 404

        # Check if the payment exists
        payment = self.payments_dao.get_payment_by_card_number(payment_id)
        if not payment:
            return {"error": "Card not found"}, 404

        # Delete the payment by card number
        if self.payments_dao.delete_payment_by_card_number(payment_id):
            return {"message": "Payment deleted successfully"}, 200
        return {"error": "Failed to delete payment"}, 500

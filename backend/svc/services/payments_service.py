from flask import jsonify
from svc.dao.payments_dao import PaymentsDAO
from svc.dao.user_dao import UserDAO

class PaymentsService():

    def __init__(self):
        self.payments_dao = PaymentsDAO()
        self.user_dao = UserDAO()

    def create_payments(self, data):
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

        response = self.payments_dao.create_payment(data)
        return response, 201

    def get_payment(self, user_id):
        if not user_id:
            return "User ID is required", 400
        
        payments = self.payments_dao.get_payment_by_id(user_id)
        if payments:
            payment_response = []
            for payment in payments:
                payment_response.append({
                    "cardNumber": payment.card_number,
                    "name": payment.card_name,
                })
            return payment_response, 200
        return {"message": "No payments found for this user"}, 404

    def delete_payment(self, data):
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
        response = self.payments_dao.delete_payment_by_card_number(payment_id)
        if response:
            return {"message": "Payment deleted successfully"}, 200
        return {"error": "Failed to delete payment"}, 500

from models.payments import Payments
from svc.db import db

class PaymentsDAO():

    def create_payment(self, data):
        new_payment = Payments(

            user_uid=data['userid'],
            holder_id = data['carHolderID'],
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
        return db.session.query(Payments).filter(Payments.user_uid == user_id).all()

    def get_payment_by_card_number(self, card_number):
        return db.session.query(Payments).filter(Payments.card_number == card_number).first()
    
    def delete_payment_by_card_number(self, card_number):
        payment = db.session.query(Payments).filter(Payments.card_number == card_number).first()
        if payment:
            db.session.delete(payment)
            db.session.commit()
            return True
        return False
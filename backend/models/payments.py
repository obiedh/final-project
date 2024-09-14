from sqlalchemy import Column, ForeignKey
from svc.db import db

class Payments(db.Model):
    __tablename__ = 'payments'

    holder_id = db.Column(db.Integer)
    card_number = db.Column(db.String(100), primary_key=True)
    digit_code = db.Column(db.String(100))
    month= db.Column(db.String(100))
    card_name = db.Column(db.String(100))
    year = db.Column(db.String(100))
    user_uid = Column(db.UUID(as_uuid=True), ForeignKey('users.uid'), nullable=False)

    # Define a reference to the user model
    user = db.relationship('User', back_populates='payments')
    #field = db.relationship('Field', back_populates='reservations')

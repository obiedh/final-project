from sqlalchemy import ForeignKey
from svc.db import db


class Reservations(db.Model):
    __tablename__ = 'reservations'

    id = db.Column(db.UUID(as_uuid=True), unique=True, nullable=False, primary_key=True)
    field_id = db.Column(db.UUID(as_uuid=True), ForeignKey('fields.uid'), nullable=False)
    date = db.Column(db.String(100))
    interval_time = db.Column(db.String(100))
    status = db.Column(db.String(20))  
    du_date = db.Column(db.String(100))
    du_time = db.Column(db.String(100))
    user_uuid = db.Column(db.UUID(as_uuid=True), ForeignKey('users.uid'), nullable=False)
    price = db.Column(db.Integer)
    field_name = db.Column(db.String(100))
    location = db.Column(db.String(100))
    imageURL = db.Column(db.String(100)) 




    field = db.relationship('Field', back_populates='reservations')

    def asdict_reservation(self):
     return {
        'uid': self.id,
        'field_id': self.field_id,
        'date': self.date,
        'interval_time': self.interval_time,
        'status': self.status,
        'du_date': self.du_date,
        'du_time': self.du_time,
        'user_uuid': self.user_uuid,
        'price': self.price,
        'name': self.field_name,
        'location':self.location,
        'imageURL': self.imageURL

     }
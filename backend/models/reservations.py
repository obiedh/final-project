"""
This module defines the Reservations model, representing field reservations made by users.

Attributes:
    - id (UUID): Primary key for each reservation.
    - field_id (UUID): Foreign key linking to the reserved field.
    - date (String): Date of the reservation.
    - interval_time (String): Time interval for the reservation.
    - status (String): Status of the reservation (e.g., "confirmed", "canceled").
    - du_date (String): Due date for payment or confirmation.
    - du_time (String): Due time for payment or confirmation.
    - user_uuid (UUID): Foreign key linking to the user who made the reservation.
    - price (Integer): Price of the reservation.
    - field_name (String): Name of the field reserved.
    - location (String): Location of the reserved field.
    - imageURL (String): Image URL for the field.
    - is_deleted (Boolean): Indicates if the reservation has been soft deleted (True if deleted).
    - field: Relationship to the Field model, representing the reserved field.

Methods:
    - asdict_reservation: Returns the reservation data as a dictionary.
"""

from sqlalchemy import Boolean, ForeignKey
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
    is_deleted = db.Column(Boolean, default=False)  


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
        'location': self.location,
        'imageURL': self.imageURL
     }

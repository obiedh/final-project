import uuid
from models.reservations import Reservations
from models.fields import Field
from sqlalchemy import and_
from flask import  jsonify
from svc.db import db

class ReservationDAO():

    def create_reservation(self, data):
        uid = str(uuid.uuid4())  # Generate a new UID
        new_reservation = Reservations(
            id=uid,
            field_id=data['field_id'],
            date=data['date'],
            interval_time=data['interval_time'],
            status=data['status'],
            du_date=data['du_date'],
            du_time=data['du_time'],
            user_uuid=data['user_uuid'],
            price=data['price'],
            field_name=data['field_name'],
            location=data['location'],
            imageURL=data['imageURL']
        )
        db.session.add(new_reservation)
        db.session.commit()
        return jsonify({'message': 'Reservation created successfully'}), 200
    
    def get_reservations_by_user_uuid(self, uuid):
        reservations = db.session.query(Reservations).filter(Reservations.user_uuid == uuid).all()
        return reservations
    
    def get_reservation_by_reservation_uuid(self, uuid):
        reservations = db.session.query(Reservations).filter(Reservations.id == uuid).all()
        return reservations
    
    def update_reservation_status(self, uuid, status):
        try:
            reservation = db.session.query(Reservations).filter(Reservations.id == uuid).first()

            if reservation:
                reservation.status = status
                db.session.commit()
                return True
            else:
                return False
        except Exception as e:
            db.session.rollback()
            return False
        
    def get_reservations_by_manager_id(self, manager_id):
        reservations = db.session.query(Reservations).join(Field).filter(
            Field.manager_id == manager_id,
            Reservations.field_id == Field.uid
        ).all()
        return reservations


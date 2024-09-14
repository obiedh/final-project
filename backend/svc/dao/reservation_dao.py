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
    
    def get_reservations_by_date(self, field_id, date):
        reservations = Reservations.query.filter(
            and_(
                Reservations.field_id == field_id,
                Reservations.date == date,
                Reservations.status != 'canceled'
            )
        ).all()
        return reservations
    
    def get_reservations_by_field_and_year(self, field_id, year):
        reservations = db.session.query(Reservations).filter(
            and_(
                Reservations.field_id == field_id,
                Reservations.date.like(f'%.{year}')
            )
        ).all()
        return reservations

    def get_reservations_by_field_and_month(self, field_id, year, month):
        # Ensure month is zero-padded
        formatted_month = f'{int(month):02}.{year}'
        print(f"Querying reservations for field_id: {field_id}, month: {formatted_month}")
        
        # Ensure the date format in the query matches the stored date format
        reservations = db.session.query(Reservations).filter(
            Reservations.field_id == field_id,
            Reservations.date.like(f'%.{formatted_month}'),
            Reservations.status == 'Accepted'
        ).all()
        
        print(f"Reservations fetched: {reservations}")
        return reservations
    
    def get_accepted_reservations_by_field_and_date(self, field_id, date):
        return db.session.query(Reservations).filter(
            Reservations.field_id == field_id,
            Reservations.date == date,
            Reservations.status == 'Accepted'
        ).all()


"""
This module provides the Data Access Object (DAO) for the Reservations model, managing database interactions for field reservations.

Methods:
    - create_reservation(data): Creates a new reservation based on the provided data.
    - get_reservations_by_user_uuid(uuid): Retrieves all active reservations (non-deleted) for a specific user by their UUID.
    - get_reservation_by_reservation_uuid(uuid): Retrieves a specific active reservation (non-deleted) by its UUID.
    - update_reservation_status(uuid, status): Updates the status of an active reservation (non-deleted) by its UUID.
    - get_reservations_by_manager_id(manager_id): Retrieves active reservations for fields managed by a specific manager.
    - get_reservations_by_date(field_id, date): Retrieves all active reservations for a specific field and date, excluding canceled ones.
    - get_reservations_by_field_and_year(field_id, year): Retrieves all active reservations for a field in a specific year.
    - get_reservations_by_field_and_month(field_id, year, month): Retrieves active reservations for a field during a specific month and year.
    - get_accepted_reservations_by_field_and_date(field_id, date): Retrieves all accepted and active reservations for a field on a specific date.
"""

import uuid
from models.reservations import Reservations
from models.fields import Field
from sqlalchemy import and_
from flask import jsonify
from svc.db import db

class ReservationDAO:
    def create_reservation(self, data):
        """Creates a new reservation based on the provided data."""
        uid = str(uuid.uuid4())
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
        """Retrieves all reservations for a specific user by their UUID."""
        reservations = db.session.query(Reservations).filter(Reservations.user_uuid == uuid, Reservations.is_deleted == False).all()
        return reservations
    
    def get_reservation_by_reservation_uuid(self, uuid):
        """Retrieves a reservation by its UUID."""
        reservations = db.session.query(Reservations).filter(Reservations.id == uuid, Reservations.is_deleted == False).all()
        return reservations
        
    def update_reservation_status(self, uuid, status):
        """Updates the status of a reservation by its UUID."""
        try:
            reservation = db.session.query(Reservations).filter(Reservations.id == uuid).first()
            if reservation:
                reservation.status = status
                db.session.commit()
                return True
            return False
        except Exception:
            db.session.rollback()
            return False
        
    def get_reservations_by_manager_id(self, manager_id):
        """Retrieves reservations for fields managed by a specific manager."""
        reservations = db.session.query(Reservations).join(Field).filter(Field.manager_id == manager_id, Reservations.is_deleted == False).all()
        return reservations
    
    def get_reservations_by_date(self, field_id, date):
        """Retrieves all reservations for a specific field and date, excluding canceled ones."""
        return Reservations.query.filter(
            and_(
                Reservations.field_id == field_id,
                Reservations.date == date,
                Reservations.status != 'canceled'
            )
        ).all()
    
    def get_reservations_by_field_and_year(self, field_id, year):
        """Retrieves all reservations for a specific field in a given year."""
        reservations = db.session.query(Reservations).filter(Reservations.field_id == field_id, Reservations.is_deleted == False, Reservations.date.like(f'%.{year}')).all()
        return reservations

    def get_reservations_by_field_and_month(self, field_id, year, month):
        """Retrieves reservations for a field during a specific month and year."""
        formatted_month = f'{month}.{year}'
        reservations = db.session.query(Reservations).filter(
            Reservations.field_id == field_id,
            Reservations.date.like(f'%.{formatted_month}'),
            Reservations.status == 'Accepted',
            Reservations.is_deleted == False  # Add the is_deleted filter
        ).all()
        return reservations
    
    def get_accepted_reservations_by_field_and_date(self, field_id, date):
        """Retrieves all accepted reservations for a field on a specific date."""
        return db.session.query(Reservations).filter(
            Reservations.field_id == field_id,
            Reservations.date == date,
            Reservations.status == 'Accepted',
            Reservations.is_deleted == False  # Add the is_deleted filter
        ).all()

"""
This module provides the Data Access Object (DAO) for the Field model, managing database interactions for sports fields.

Methods:
    - create_field(data): Creates a new field if no field with the same name, location, and sport type exists.
    - update_conf_interval(field_id, conf_interval): Updates the confidence interval for a field.
    - update_field_details(field_id, name, utilities): Updates the details of a field such as name and utilities.
    - get_fields_by_sport_type(sport_type): Retrieves all fields for a given sport type.
    - delete_field(field_id, manager_id): Deletes a field if the manager owns the field.
    - get_fields_by_manager_id(manager_id): Retrieves all fields managed by a specific manager.
    - get_field_by_id(field_id): Retrieves a field by its ID.
    - get_average_rating(field_id): Calculates and returns the average rating for a field.
    - get_filtered_fields(data): Retrieves fields filtered by sport type.
    - get_fields_by_sport_type_and_location(sport_type, location): Retrieves fields filtered by sport type and location.
    - cancel_reservations(field_id): Cancels all reservations for a specific field.
"""

from models.fields import Field
from models.ratings import Ratings
from models.reservations import Reservations
from flask import jsonify
from sqlalchemy import func
from svc.db import db
import uuid

class FieldDAO:
    def create_field(self, data):
        """Creates a new field if no duplicate exists based on name, location, and sport type."""
        existing_field = db.session.query(Field).filter_by(
            name=data['name'], location=data['location'], sport_type=data['sport_type']
        ).first()
        if existing_field:
            return jsonify({'error': 'Field with the same name, location, and sport type already exists'}), 409

        uid = str(uuid.uuid4())
        new_field = Field(
            uid=uid, name=data['name'], location=data['location'],
            latitude=data['latitude'], longitude=data['longitude'],
            sport_type=data['sport_type'], conf_interval=data['conf_interval'],
            imageURL=data['imageURL'], manager_id=data['manager_id'],
            utilities=data['utilities']
        )
        db.session.add(new_field)
        db.session.commit()
        return jsonify({'Field_id': new_field.uid}), 201

    def update_conf_interval(self, field_id, conf_interval):
        """Updates the confidence interval for the specified field."""
        field = db.session.query(Field).filter(Field.uid == field_id).first()
        if not field:
            return None
        field.conf_interval = conf_interval
        db.session.commit()
        return field

    def update_field_details(self, field_id, name, utilities):
        """Updates the field's name and utilities."""
        field = db.session.query(Field).filter(Field.uid == field_id).first()
        if not field:
            return None
        if name:
            field.name = name
        if utilities:
            field.utilities = utilities
        db.session.commit()
        return field

    def get_fields_by_sport_type(self, sport_type):
        """Retrieves all fields by sport type."""
        return db.session.query(Field).filter(Field.sport_type == sport_type).all()

    def delete_field(self, field_id, manager_id):
        """Deletes a field if it belongs to the manager with the provided manager_id."""
        field = db.session.query(Field).filter(Field.uid == field_id).first()
        if not field:
            return None, "Field not found"
        if str(field.manager_id).strip() != manager_id.strip():
            return None, "Field does not belong to this manager"
        db.session.delete(field)
        db.session.commit()
        return field, "Field deleted successfully"

    def get_fields_by_manager_id(self, manager_id):
        """Retrieves all fields managed by the specified manager."""
        return db.session.query(Field).filter(Field.manager_id == manager_id).all()

    def get_field_by_id(self, field_id):
        """Retrieves a field by its ID."""
        return db.session.query(Field).filter(Field.uid == field_id).first()

    def get_average_rating(self, field_id):
        """Calculates the average rating for a given field."""
        avg_rating = db.session.query(func.avg(Ratings.rating)).filter(Ratings.field_id == field_id).scalar()
        return avg_rating if avg_rating is not None else 0

    def get_filtered_fields(self, data):
        """Retrieves fields filtered by sport type."""
        sportType = data['sport_type']
        return db.session.query(Field).filter(Field.sport_type == sportType).all()

    def get_fields_by_sport_type_and_location(self, sport_type, location):
        """Retrieves fields filtered by sport type and location."""
        return Field.query.filter_by(sport_type=sport_type, location=location).all()

    def cancel_reservations(self, field_id):
        """Cancels all reservations for the specified field."""
        reservations = db.session.query(Reservations).filter(Reservations.field_id == field_id).all()
        for reservation in reservations:
            reservation.status = "canceled"
        db.session.commit()

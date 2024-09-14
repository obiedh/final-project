from models.fields import Field
from models.ratings import Ratings
from models.reservations import Reservations
from flask import  jsonify
from sqlalchemy import func
from svc.db import db
import uuid

class FieldDAO():

    def create_field(self, data):
        # Check if a field with the same name, location, and sport type already exists
        existing_field = db.session.query(Field).filter_by(
            name=data['name'],
            location=data['location'],
            sport_type=data['sport_type']
        ).first()

        if existing_field:
            return jsonify({'error': 'Field with the same name, location, and sport type already exists'}), 409

        uid = str(uuid.uuid4())  # Generate a new UID
        new_field = Field(
            uid=uid,
            name=data['name'],
            location=data['location'],
            latitude=data['latitude'],  
            longitude=data['longitude'],  
            sport_type=data['sport_type'],
            conf_interval=data['conf_interval'],  # Store conf_interval as string
            imageURL=data['imageURL'],
            manager_id=data['manager_id'],
            utilities=data['utilities']  
        )
        db.session.add(new_field)
        db.session.commit()
        return jsonify({'Field_id': new_field.uid }), 201
    
    def update_conf_interval(self, field_id, conf_interval):
        field = db.session.query(Field).filter(Field.uid == field_id).first()
        if not field:
            return None
        
        field.conf_interval = conf_interval
        db.session.commit()
        return field
    
    def update_field_details(self, field_id, name, utilities):
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
        fields = db.session.query(Field).filter(Field.sport_type == sport_type).all()
        return fields
    
    def delete_field(self, field_id, manager_id):
        field = db.session.query(Field).filter(Field.uid == field_id).first()
        if not field:
            return None, "Field not found"

        # Ensure the manager_id is a string and strip any whitespaces
        if str(field.manager_id).strip() != manager_id.strip():
            return None, "Field does not belong to this manager"
        
        db.session.delete(field)
        db.session.commit()
        return field, "Field deleted successfully"
    
    def get_fields_by_manager_id(self, manager_id):
        fields = db.session.query(Field).filter(Field.manager_id == manager_id).all()
        return fields
    
    def get_field_by_id(self, field_id):
        field = db.session.query(Field).filter(Field.uid == field_id).first()
        return field
    
    def get_average_rating(self, field_id):
        avg_rating = db.session.query(func.avg(Ratings.rating)).filter(Ratings.field_id == field_id).scalar()
        return avg_rating if avg_rating is not None else 0
    
    def get_filtered_fields(self, data):
        sportType=data['sport_type']
        # Query the fields that match the specified sport_type
        fields_with_reservations = db.session.query(Field).filter(Field.sport_type == sportType).all()
        return fields_with_reservations
    
    def get_fields_by_sport_type_and_location(self, sport_type, location):
        return Field.query.filter_by(sport_type=sport_type, location=location).all()
    
    def cancel_reservations(self, field_id):
        reservations = db.session.query(Reservations).filter(Reservations.field_id == field_id).all()
        for reservation in reservations:
            reservation.status = "canceled"
        db.session.commit()
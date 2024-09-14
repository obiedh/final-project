"""
This module provides the Data Access Object (DAO) for the Favorites model, managing the database interactions for user favorites.

Methods:
    - create_favorite(user_id, field_id): Adds a new favorite for a user and field.
    - get_favorite_by_user_and_field(user_id, field_id): Retrieves a favorite record by user and field.
    - delete_favorite(favorite): Deletes a favorite record.
    - get_favorite_fields_by_user(user_id): Retrieves all favorite fields for a specific user.
"""

import uuid
from models.favorites import Favorites
from svc.db import db
from flask import jsonify

class FavoritesDAO:
    def create_favorite(self, user_id, field_id):
        """Adds a new favorite for the given user and field."""
        favorite_uid = str(uuid.uuid4())
        favorite = Favorites(uid=favorite_uid, user_id=user_id, field_id=field_id)
        db.session.add(favorite)
        db.session.commit()
        return jsonify({'message': 'Field added to favorites successfully'}), 201

    def get_favorite_by_user_and_field(self, user_id, field_id):
        """Retrieves a favorite record based on user ID and field ID."""
        favorite = db.session.query(Favorites).filter_by(user_id=user_id, field_id=field_id).first()
        return favorite

    def delete_favorite(self, favorite):
        """Deletes a favorite record."""
        db.session.delete(favorite)
        db.session.commit()
        return jsonify({'message': 'Field removed from favorites successfully'}), 200

    def get_favorite_fields_by_user(self, user_id):
        """Retrieves all favorite fields for a specific user."""
        try:
            favorite_fields = db.session.query(Favorites).filter(Favorites.user_id == user_id).all()
            return favorite_fields
        except Exception as e:
            return None

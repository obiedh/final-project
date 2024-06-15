import uuid
from models.favorites import Favorites
from svc.db import db
from flask import jsonify

class FavoritesDAO():
    def create_favorite(self, user_id, field_id):
        # Generate a UUID for the "uid" column
        favorite_uid = str(uuid.uuid4())

        favorite = Favorites(uid=favorite_uid, user_id=user_id, field_id=field_id)
        db.session.add(favorite)
        db.session.commit()

        return jsonify({'message': 'Field added to favorites successfully'}), 201

    def get_favorite_by_user_and_field(self, user_id, field_id):
        # Retrieve a favorite record by user and field
        favorite = db.session.query(Favorites).filter_by(user_id=user_id, field_id=field_id).first()
        return favorite

    def delete_favorite(self, favorite):
        # Delete a favorite record
        db.session.delete(favorite)
        db.session.commit()
        return jsonify({'message': 'Field removed from favorites successfully'}), 200
    
    def get_favorite_fields_by_user(self, user_id):
        try:
            favorite_fields = db.session.query(Favorites).filter(Favorites.user_id == user_id).all()
            return favorite_fields
        except Exception as e:
            # Handle any exceptions, such as database errors
            return None
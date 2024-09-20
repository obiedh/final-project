"""
This module provides the Data Access Object (DAO) for the Ratings model, managing database interactions for user ratings on fields.

Methods:
    - create_rating(user_id, field_id, rating): Creates a new rating or updates an existing rating for a specific user and field, excluding deleted ratings.
"""

import uuid
from models.ratings import Ratings
from svc.db import db

class RatingsDAO:
    def create_rating(self, user_id, field_id, rating):
        """Creates a new rating or updates an existing one for the given user and field."""
        existing_rating = db.session.query(Ratings).filter_by(user_id=user_id, field_id=field_id, is_deleted=False).first()
        if existing_rating:
            existing_rating.rating = rating
            db.session.commit()
            return {'message': 'Rating updated successfully'}, 200

        uid = str(uuid.uuid4())
        new_rating = Ratings(uid=uid, user_id=user_id, field_id=field_id, rating=rating)
        db.session.add(new_rating)
        db.session.commit()
        return {'message': 'Rating created successfully'}, 201

import uuid
from models.ratings import Ratings
from svc.db import db


class RatingsDAO():

    def create_rating(self, user_id, field_id, rating):
        # Check if the rating already exists for the same user and field
        existing_rating = db.session.query(Ratings).filter_by(user_id=user_id, field_id=field_id).first()
        if existing_rating:
            existing_rating.rating = rating
            db.session.commit()
            return {'message': 'Rating updated successfully'}, 200
        
        uid = str(uuid.uuid4())  # Generate a new UID
        new_rating = Ratings(
            uid=uid,
            user_id=user_id,
            field_id=field_id,
            rating=rating,
        )
        
        db.session.add(new_rating)
        db.session.commit()
        return {'message': 'Rating created successfully'}, 201
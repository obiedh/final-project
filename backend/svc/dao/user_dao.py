"""
This module provides the Data Access Object (DAO) for the User model, managing database interactions for users.

Methods:
    - create_user(data): Creates a new user with the provided data.
    - get_user_by_username(username): Retrieves a user by their username.
    - get_user_by_id(user_id): Retrieves a user by their unique ID.
    - update_preference(user_name, preference): Updates the preferences for a given user by username.
"""

from svc.db import db
from models.user import User
import uuid

class UserDAO:
    def create_user(self, data):
        """Creates a new user with the provided data."""
        uid = str(uuid.uuid4())  # Generate a new UID
        new_user = User(uid=uid, username=data['username'], password=data['password'], phonenum=data['phonenum'])
        db.session.add(new_user)
        db.session.commit()
        return new_user
    
    def get_user_by_username(self, username):
        """Retrieves a user by their username."""
        return User.query.filter_by(username=username).first()
    
    def get_user_by_id(self, user_id):
        """Retrieves a user by their unique ID."""
        return db.session.query(User).filter_by(uid=user_id).first()

    def update_preference(self, user_name, preference):
        """Updates the preference for a user by their username."""
        user = db.session.query(User).filter(User.username == user_name).first() 
        user.preference = preference
        db.session.commit()
        return "Preference updated successfully", 200

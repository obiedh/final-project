"""
This module provides the service layer for managing users, handling business logic related to user creation, authentication, preferences, and favorites.

Methods:
    - create_user(data): Creates a new user with a hashed password and validates required fields.
    - user_verification(username, password): Verifies user credentials during login.
    - update_preference(user_id, preference): Updates a user's preferences.
    - add_favorite(data): Adds a field to the user's favorites after validating user and field existence.
    - remove_favorite(user_id, field_id): Removes a field from the user's favorites.
    - get_user_favorite_fields(user_id): Retrieves a list of the user's favorite fields.
"""

from svc.dao.user_dao import UserDAO
from svc.dao.favorites_dao import FavoritesDAO
from svc.dao.fields_dao import FieldDAO
from flask import jsonify
from sqlalchemy.exc import IntegrityError
from flask_bcrypt import Bcrypt
from flask_bcrypt import check_password_hash

bcrypt = Bcrypt()

class UserService:

    def __init__(self):
        self.user_dao = UserDAO()
        self.favorites_dao = FavoritesDAO()
        self.fields_dao = FieldDAO()

    def create_user(self, data):
        """Creates a new user with a hashed password and validates required fields."""
        if not data:
            return jsonify({'error': 'Userinfo is required'}), 400
        if 'password' not in data:
            return jsonify({'error': 'Password and user_type are required'}), 400

        hashed_password = bcrypt.generate_password_hash(data['password']).decode('utf-8')
        data['password'] = hashed_password

        try:
            user = self.user_dao.create_user(data=data)
            return jsonify({
                'message': 'User created successfully',
                'username': user.username,
                'phonenum': user.phonenum,
            }), 201
        except IntegrityError as e:
            print("IntegrityError:", str(e))
            if "UniqueViolation" in str(e):
                if "users_username_key" in str(e):
                    return jsonify({'error': 'User with this username already exists'}), 409
                elif "users_phonenum_key" in str(e):
                    return jsonify({'error': 'User with this phone number already exists'}), 409
        return jsonify({'error': 'An unexpected error occurred'}), 500

    def user_verification(self, username, password):
        """Verifies user credentials during login."""
        user = self.user_dao.get_user_by_username(username)
        if user and check_password_hash(user.password, password):
            return jsonify({
                'message': 'User Verified',
                'userid': user.uid,
                'user_type': user.user_type
            }), 200
        return jsonify({'error': 'Invalid username or password'}), 401

    def update_preference(self, user_id, preference):
        """Updates a user's preferences."""
        user, message = self.user_dao.update_preference(user_id, preference)
        if not user:
            return {'message': message}, 404
        return {'message': message}, 200

    def add_favorite(self, data):
        """Adds a field to the user's favorites after validating user and field existence."""
        user_id = data['user_id']
        field_id = data['field_id']
        if not user_id or not field_id:
            return jsonify({'error': 'User ID and Field ID are required'}), 400

        user = self.user_dao.get_user_by_id(user_id)
        if not user:
            return jsonify({'error': 'User does not exist'}), 404

        field = self.fields_dao.get_field_by_id(field_id)
        if not field:
            return jsonify({'error': 'Field does not exist'}), 404

        existing_favorite = self.favorites_dao.get_favorite_by_user_and_field(user_id, field_id)
        if existing_favorite:
            return jsonify({'error': 'This field is already in your favorites'}), 400

        return self.favorites_dao.create_favorite(user_id, field_id)

    def remove_favorite(self, user_id, field_id):
        """Removes a field from the user's favorites."""
        if not user_id or not field_id:
            return jsonify({'error': 'User ID and Field ID are required'}), 400

        existing_favorite = self.favorites_dao.get_favorite_by_user_and_field(user_id, field_id)
        if not existing_favorite:
            return jsonify({'error': 'This field is not in your favorites'}), 400

        return self.favorites_dao.delete_favorite(existing_favorite)

    def get_user_favorite_fields(self, user_id):
        """Retrieves a list of the user's favorite fields."""
        if not user_id:
            return {"error": "user_id is required."}, 400

        favorite_fields = self.favorites_dao.get_favorite_fields_by_user(user_id)
        if not favorite_fields:
            return {"message": "No favorite fields found for this user."}, 404

        favorite_fields_details = []
        for favorite in favorite_fields:
            field_id = favorite.field_id
            field = self.fields_dao.get_field_by_id(field_id)
            if field:
                field_info = {
                    "uid": field.uid,
                    "name": field.name,
                    "location": field.location,
                    "latitude": field.latitude,
                    "longitude": field.longitude,
                    "sport_type": field.sport_type,
                    "imageURL": field.imageURL,
                    "manager_id": field.manager_id,
                    "utilities": field.utilities
                }
                favorite_fields_details.append(field_info)

        return favorite_fields_details, 200

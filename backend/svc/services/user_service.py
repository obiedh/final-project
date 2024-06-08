from svc.dao.user_dao import UserDAO
from flask import jsonify
from sqlalchemy.exc import IntegrityError
from flask_bcrypt import Bcrypt
from flask_bcrypt import check_password_hash


bcrypt = Bcrypt()

class UserService():
    def __init__(self):
        self.user_dao = UserDAO()

    def create_user(self, data):
        if not data:
            return jsonify({'error': 'Userinfo is required'}), 400

        if 'password' not in data:  
            return jsonify({'error': 'Password and user_type are required'}), 400

        hashed_password = bcrypt.generate_password_hash(data['password']).decode('utf-8')

        try:
            data['password'] = hashed_password


            user = self.user_dao.create_user(data=data)
            return jsonify({
                'message': 'User created successfully',
                'username': user.username,
                'phonenum': user.phonenum,
            }), 201

        except IntegrityError as e:
            # Log the exception message for debugging
            print("IntegrityError:", str(e))

            # Check if the exception is due to a unique constraint violation
            if "UniqueViolation" in str(e):
                if "users_username_key" in str(e):
                    return jsonify({'error': 'User with this username already exists'}), 409  # HTTP 409 Conflict
                elif "users_phonenum_key" in str(e):
                    return jsonify({'error': 'User with this phone number already exists'}), 409  # HTTP 409 Conflict

    # If we reach this point, return a generic error response
        return jsonify({'error': 'An unexpected error occurred'}), 500  # HTTP 500 Internal Server Error
    
        # Verify user credentials during login
    def user_verification(self, username, password):
        user = self.user_dao.get_user_by_username(username)
        if user and check_password_hash(user.password, password):
           return jsonify({
                'message': 'User Verified',
                'userid': user.uid,
                'user_type': user.user_type
            }), 200

        return jsonify({'error': 'Invalid username or password'}), 401  # HTTP 401 Unauthorized
    
    def update_preference(self, user_id, preference):
        user, message = self.user_dao.update_preference(user_id, preference)
        if not user:
            return {'message': message}, 404
        return {'message': message}, 200
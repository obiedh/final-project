import uuid
from flask import Blueprint
from flask import request, Blueprint, jsonify,send_file
from svc.services.user_service import UserService
#API EXAMPLES ARE INSIDE THE FILE API_EXAMPLES.

api_bp = Blueprint('api', __name__)

def is_valid_uuid(uuid_to_test, version=4):
    try:
        uuid_obj = uuid.UUID(uuid_to_test, version=version)
    except ValueError:
        return False
    return str(uuid_obj) == uuid_to_test


@api_bp.route('/create_user', methods=['POST'])
def create_user():
    data = request.json
    user_service = UserService()
    response = user_service.create_user(data=data)
    return response

@api_bp.route('/user_verfication', methods=['POST'])
def user_verification():
    data = request.json
    username = data.get('username')
    password = data.get('password')
    user_service = UserService()
    response = user_service.user_verification(username=username, password=password)
    return response

@api_bp.route('/update_preference', methods=['PUT'])
def update_preference():
    user_id = request.json.get('user_id')
    preference = request.json.get('preference')
    
    if not user_id or not preference:
        return jsonify({'error': 'User ID and preference are required'}), 400

    if not is_valid_uuid(user_id):
        return jsonify({'error': 'User ID must be a valid UUID'}), 400
    
    user_service = UserService()
    response, status_code = user_service.update_preference(user_id, preference)
    return jsonify(response), status_code
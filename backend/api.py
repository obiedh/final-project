import uuid
from flask import Blueprint
from flask import request, Blueprint, jsonify,send_file
from svc.services.user_service import UserService
from svc.services.fields_service import FieldService
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
    user_name = request.json.get('username')
    preference = request.json.get('preference')
    
    if not user_name or not preference:
        return jsonify({'error': 'User name and preference are required'}), 400
    
    user_service = UserService()
    response, status_code = user_service.update_preference(user_name, preference)
    return jsonify(response), status_code

@api_bp.route('/create_field', methods=['POST'])
def create_field():
    data = request.json
    manager_id = data['manager_id']
    if not is_valid_uuid(manager_id):
        return jsonify({'error': 'Manager ID must be a valid UUID'}), 400
    field_service = FieldService()
    response = field_service.create_field(data=data)
    return response

@api_bp.route('/update_conf_interval', methods=['PUT'])
def update_conf_interval():
    field_id = request.json.get('field_id')
    conf_interval = request.json.get('conf_interval')
    if not field_id or not conf_interval:
        return jsonify({'error': 'Field ID and conf_interval are required'}), 400
    if not is_valid_uuid(field_id):
        return jsonify({'error': 'Field ID must be a valid UUID'}), 400
    
    field_service = FieldService()
    field, status_code = field_service.update_conf_interval(field_id, conf_interval)
    return jsonify(field), status_code

@api_bp.route('/update_field_details', methods=['PUT'])
def update_field_details():
    field_id = request.json.get('field_id')
    name = request.json.get('name')
    utilities = request.json.get('utilities')
    
    if not field_id:
        return jsonify({'error': 'Field ID is required'}), 400
    
    if not is_valid_uuid(field_id):
        return jsonify({'error': 'Field ID must be a valid UUID'}), 400
    
    field_service = FieldService()
    field, status_code = field_service.update_field_details(field_id, name, utilities)
    return jsonify(field), status_code

@api_bp.route('/delete_field', methods=['DELETE'])
def delete_field():
    field_id = request.json.get('field_id')
    manager_id = request.json.get('manager_id')
    
    if not field_id or not manager_id:
        return jsonify({'error': 'Field ID and Manager ID are required'}), 400

    if not is_valid_uuid(field_id) or not is_valid_uuid(manager_id):
        return jsonify({'error': 'Field ID and Manager ID must be valid UUIDs'}), 400
    
    field_service = FieldService()
    response, status_code = field_service.delete_field(field_id, manager_id)
    return jsonify(response), status_code

@api_bp.route('/get_fields_by_sport_type', methods=['POST'])
def get_fields_by_sport_type():
    sport_type = request.json.get('sport_type')
    if not sport_type:
        return jsonify({'error': 'Sport type parameter is required'}), 400
    
    field_service = FieldService()
    fields, status_code = field_service.get_fields_by_sport_type(sport_type)
    return jsonify(fields), status_code

@api_bp.route('/get_fields_by_manager_id', methods=['POST'])
def get_fields_by_manager_id():
    manager_id = request.json.get('manager_id')
    if not manager_id:
        return jsonify({'error': 'Manager ID parameter is required'}), 400
    if not is_valid_uuid(manager_id):
        return jsonify({'error': 'Manager ID must be a valid UUID'}), 400
    
    field_service = FieldService()
    fields, status_code = field_service.get_fields_by_manager_id(manager_id)
    return jsonify(fields), status_code
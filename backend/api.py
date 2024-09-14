import json
import uuid
from flask import Blueprint
from flask import request, Blueprint, jsonify
from svc.services.user_service import UserService
from svc.services.fields_service import FieldService
from svc.services.ratings_service import RatingsService
from svc.services.reservation_service import ReservationService
from svc.services.payments_service import PaymentsService

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
    data['utilities'] = json.dumps(data['utilities']) 
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
    utilities = json.dumps(request.json.get('utilities'))  # Ensure utilities is a JSON string
    
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

@api_bp.route('/get_field_by_id', methods=['POST'])
def get_football_field_by_id():
    data = request.json
    field_service = FieldService()
    response = field_service.get_available_time_slots(data=data)
    print(response)
    return response

@api_bp.route('/add_favorite', methods=['POST'])
def add_favorite():
    data = request.json
    user_id = data.get('user_id')
    field_id = data.get('field_id')
    if not is_valid_uuid(user_id):
        return jsonify({'error': 'User ID must be a valid UUID'}), 400
    if not is_valid_uuid(field_id):
        return jsonify({'error': 'Field ID must be a valid UUID'}), 400

    user_service = UserService()
    response = user_service.add_favorite(data)
    return response

@api_bp.route('/remove_favorite', methods=['POST'])
def remove_favorite():
    user_id = request.json.get('user_id')
    field_id = request.json.get('field_id')
    if not is_valid_uuid(user_id):
        return jsonify({'error': 'User ID must be a valid UUID'}), 400
    if not is_valid_uuid(field_id):
        return jsonify({'error': 'Field ID must be a valid UUID'}), 400

    user_service = UserService()
    response = user_service.remove_favorite(user_id, field_id)
    return response

@api_bp.route('/get_user_favorites', methods=['POST'])
def get_user_favorites():
    user_id = request.json.get('user_id')
    if not is_valid_uuid(user_id):
        return jsonify({'error': 'User ID must be a valid UUID'}), 400

    user_service = UserService()
    favorite_fields, status_code = user_service.get_user_favorite_fields(user_id)
    return jsonify(favorite_fields), status_code

@api_bp.route('/add_rating', methods=['POST'])
def create_rating():
    data = request.json
    field_id = data["field_id"]
    if not is_valid_uuid(field_id):
        return jsonify({"error": "Field ID must be a valid UUID"}), 400
    user_id = data["user_id"]
    if not is_valid_uuid(user_id):
        return jsonify({"error": "User ID must be a valid UUID"}), 400
    ratings_service = RatingsService()
    response, status_code = ratings_service.create_rating(data)
    return jsonify(response), status_code


@api_bp.route('/create_reservation', methods=['POST'])
def create_reservation():
    data = request.json
    reservation_service = ReservationService()
    response = reservation_service.create_reservation(data=data)
    return response

@api_bp.route('/get_reservation', methods=['POST'])
def get_reservation():
    user_id = request.json.get('uuid')
    if not is_valid_uuid(user_id):
        return jsonify({'error': 'User ID must be a valid UUID'}), 400
    
    reservation_service = ReservationService()
    response, status_code = reservation_service.get_reservation(user_id)
    return jsonify(response), status_code

@api_bp.route('/update_reservation_status', methods=['PUT'])
def update_reservation_status():
    reservation_uuid = request.json.get('reservation_uuid')
    status = request.json.get('status')

    if not reservation_uuid:
        return jsonify({"error": "Reservation UUID is required"}), 400
    if not is_valid_uuid(reservation_uuid):
        return jsonify({'error': 'Reservation UUID must be a valid UUID'}), 400
    
    if not status:
        return jsonify({"error": "Status is required"}), 400

    reservation_service = ReservationService()
    success = reservation_service.update_reservation_status(reservation_uuid, status)

    if success:
        return jsonify({"message": "Reservation status updated successfully"}), 200
    else:
        return jsonify({"error": "Reservation not found or status update failed"}), 404
    
@api_bp.route('/get_reservations_by_manager', methods=['POST'])
def get_reservations_by_manager():
    manager_id = request.json.get('manager_id')
    if not manager_id:
        return jsonify({'error': 'Manager ID parameter is required'}), 400
    if not is_valid_uuid(manager_id):
        return jsonify({'error': 'Manager ID must be a valid UUID'}), 400
    
    reservation_service = ReservationService()
    reservations, status_code = reservation_service.get_reservations_by_manager(manager_id)
    return jsonify(reservations), status_code

@api_bp.route('/create_payment', methods=['POST'])
def create_payment():
    data = request.json
    user_id = data.get('userid')
    if not is_valid_uuid(user_id):
        return jsonify({'error': 'User ID must be a valid UUID'}), 400
    payments_service = PaymentsService()
    response, status_code = payments_service.create_payments(data=data)
    return jsonify(response), status_code

@api_bp.route('/get_payment_by_id', methods=['POST'])
def get_payment_by_id():
    user_id = request.json.get('userid')
    if not is_valid_uuid(user_id):
        return jsonify({'error': 'User ID must be a valid UUID'}), 400
    payments_service = PaymentsService()
    response, status_code = payments_service.get_payment(user_id)
    return jsonify(response), status_code

@api_bp.route('/delete_payment', methods=['DELETE'])
def delete_payment():
    user_id = request.json.get('user_id')
    data = request.json
    if not is_valid_uuid(user_id):
        return jsonify({'error': 'User ID must be a valid UUID'}), 400
    payments_service = PaymentsService()
    response, status_code = payments_service.delete_payment(data)
    return jsonify(response), status_code

@api_bp.route('/get_filtered_fields', methods=['POST'])
def get_filtered_fields():
    user_id = request.json.get('user_id')
    user_longitude = request.json.get('user_longitude')
    user_latitude = request.json.get('user_latitude')
    
    if not user_id or not user_latitude or not user_longitude :
        return jsonify({'error': 'User ID and User Longitude and User Latitude are required'}), 400

    if not is_valid_uuid(user_id):
        return jsonify({'error': 'User ID must be valid UUIDs'}), 400
    data = request.json
    field_service = FieldService()
    response = field_service.get_filtered_fields(data=data)
    return response

@api_bp.route('/get_best_fields', methods=['POST'])
def get_best_fields():
    user_id = request.json.get('user_id')
    sport_type = request.json.get('sport_type')
    
    if not user_id or not sport_type:
        return jsonify({'error': 'Field ID and Manager ID are required'}), 400

    if not is_valid_uuid(user_id):
        return jsonify({'error': 'User ID must be valid UUIDs'}), 400
    
    data = request.json
    field_service = FieldService()
    response, status_code = field_service.get_best_fields(data=data)
    return jsonify(response), status_code

@api_bp.route('/get_reservation_count_per_month_report', methods=['POST'])
def get_reservation_report():
    data = request.json
    year = data.get('year')
    manager_id = data.get('manager_id')
    
    if not year or not manager_id:
        return jsonify({'error': 'Year and Manager ID are required'}), 400

    if not is_valid_uuid(manager_id):
        return jsonify({'error': 'Manager ID must be a valid UUID'}), 400
    
    field_service = FieldService()
    response, status_code = field_service.get_reservation_report(manager_id,year)
    return jsonify(response), status_code

@api_bp.route('/get_hourly_reservations_report', methods=['POST'])
def get_hourly_reservations_report():
    data = request.json
    manager_id = data.get('manager_id')
    date = data.get('date')

    if not manager_id or not date:
        return jsonify({'error': 'Manager ID and date are required'}), 400

    if not is_valid_uuid(manager_id):
        return jsonify({'error': 'Manager ID must be a valid UUID'}), 400

    field_service = FieldService()
    response, status_code = field_service.get_hourly_reservations_report(manager_id, date)
    return jsonify(response), status_code
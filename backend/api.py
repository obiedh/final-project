from flask import Blueprint
from flask import request, Blueprint, jsonify,send_file
from svc.services.user_service import UserService
#API EXAMPLES ARE INSIDE THE FILE API_EXAMPLES.

api_bp = Blueprint('api', __name__)


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

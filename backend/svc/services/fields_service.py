import json
from flask import jsonify
from svc.dao.fields_dao import FieldDAO
from svc.dao.user_dao import UserDAO

class FieldService():

    def __init__(self):
        self.field_dao = FieldDAO()
        self.user_dao = UserDAO()

    def create_field(self, data):
        user_id = data['manager_id']
        user_info = self.user_dao.get_user_by_id(user_id)

        if not user_info or user_info.user_type != 'manager':
            print(user_info.user_type)
            return jsonify({'error': 'Only managers can create fields'}), 403
        
        data['utilities'] = json.loads(data['utilities']) 
        response = self.field_dao.create_field(data=data)
        return response
    
    def update_conf_interval(self, field_id, conf_interval):
        field = self.field_dao.update_conf_interval(field_id, conf_interval)
        if not field:
            return {'message': 'Field not found'}, 404
        field_dict = field.asdict()
        field_dict['average_rating'] = self.field_dao.get_average_rating(field.uid)
        return field_dict, 200
    
    def update_field_details(self, field_id, name, utilities):
        utilities = json.loads(utilities)  # Parse utilities JSON string
        field = self.field_dao.update_field_details(field_id, name, utilities)
        if not field:
            return {'message': 'Field not found'}, 404
        field_dict = field.asdict()
        field_dict['average_rating'] = self.field_dao.get_average_rating(field.uid)
        return field_dict, 200
    
    def delete_field(self, field_id, manager_id):
        field, message = self.field_dao.delete_field(field_id, manager_id)
        if not field:
            return {'message': message}, 404
        return {'message': message}, 200
    
    def get_fields_by_sport_type(self, sport_type):
        fields = self.field_dao.get_fields_by_sport_type(sport_type)
        if not fields or len(fields) == 0:
            return {'message': 'No fields found for the given sport type'}, 200

        all_fields = []
        for field in fields:
            field_dict = field.asdict()
            field_dict['average_rating'] = self.field_dao.get_average_rating(field.uid)
            all_fields.append(field_dict)
        return all_fields, 200
    
    def get_fields_by_manager_id(self, manager_id):
        fields = self.field_dao.get_fields_by_manager_id(manager_id)
        if fields is None or len(fields) == 0:
            return {'message': 'No fields found for the given Manager ID'}, 200

        all_fields = []
        for field in fields:
            field_dict = field.asdict()
            field_dict['average_rating'] = self.field_dao.get_average_rating(field.uid)
            all_fields.append(field_dict)
        return all_fields, 200
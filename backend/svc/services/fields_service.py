import json
from flask import jsonify
from svc.dao.fields_dao import FieldDAO
from svc.dao.user_dao import UserDAO
from svc.dao.reservation_dao import ReservationDAO


class FieldService():

    def __init__(self):
        self.field_dao = FieldDAO()
        self.user_dao = UserDAO()
        self.reservation_dao = ReservationDAO()


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
    
    def get_available_time_slots(self, data):
            field_id = data.get('field_id')
            date = data.get('date')

            if not field_id or not date:
                return {"error": "Field ID and date are required."}, 400

            field = self.field_dao.get_field_by_id(field_id)

            if not field:
                return {"error": "Field not found."}, 404
            
            # Split the string by space to separate each time interval and price pair
            conf_intervals = field.conf_interval.split(' ')

            # Extract time intervals and prices as pairs and store them in a dictionary
            time_price_map = {}
            for interval in conf_intervals:
                time_slot, price = interval.split(',')
                time_price_map[time_slot] = price

            reservations = self.reservation_dao.get_reservations_by_date(field_id, date)
            reserved_time_slots = [reservation.interval_time for reservation in reservations]

            free_conf_interval = []
            for time_slot, price in time_price_map.items():
                if time_slot not in reserved_time_slots:
                    free_conf_interval.append(f"{time_slot},{price}")

            response_str = ' '.join(free_conf_interval)

            return response_str, 200
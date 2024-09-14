import json
import math
from math import exp, sqrt
from flask import jsonify
from models.fields import Field
from svc.dao.fields_dao import FieldDAO
from svc.dao.user_dao import UserDAO
from svc.dao.reservation_dao import ReservationDAO


class FieldService():

    def __init__(self):
        self.field_dao = FieldDAO()
        self.field = Field()
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
    
    def get_best_fields(self, data):
        sport_type = data.get('sport_type')
        user_longitude = float(data.get('longitude', 0))
        user_latitude = float(data.get('latitude', 0))
        permission = data.get('permission', 'false').lower() == 'true'
        user_id = data.get('user_id')  # Assuming user_id is included in the request

        fields = self.field_dao.get_fields_by_sport_type(sport_type)
        user = self.user_dao.get_user_by_id(user_id)

        if not fields or not user:
            return {'message': 'No fields or user found'}, 200

        return self.calculate_field_scores(user, fields, user_latitude, user_longitude, permission), 200
    
    def calculate_field_scores(self, user, fields, user_latitude, user_longitude, permission):
        user_preferences = self._parse_preferences(user.preference)
        field_scores = []

        for field in fields:
            proximity_score = self._calculate_proximity_score(user_latitude, user_longitude, field, permission)
            rating_score = self._calculate_rating_score(field.uid)
            facilities_score = self._calculate_facilities_score(user_preferences, field.utilities)

            total_score = proximity_score + rating_score + facilities_score
            field_details = field.asdict()
            field_details['average_rating'] = self.field_dao.get_average_rating(field.uid)
            field_details['total_score'] = total_score
            field_scores.append(field_details)

        sorted_fields = sorted(field_scores, key=lambda x: x['total_score'], reverse=True)
        return sorted_fields

    def _calculate_proximity_score(user_latitude, user_longitude, field, permission=True):
        if not permission:
            return 0
        field_latitude = float(field['latitude'])
        field_longitude = float(field['longitude'])

        distance = calculate_haversine_distance(user_latitude, user_longitude, field_latitude, field_longitude)
        if distance == 0:
            distance = 1  # Avoid division by zero
        return 1 / distance

    def _calculate_rating_score(self, field_id):
        avg_rating = self.field_dao.get_average_rating(field_id)
        return 1 / (1 + exp(-avg_rating))

    def _calculate_facilities_score(self, user_preferences, field_utilities):
        user_vector = [user_preferences.get(util, 0) for util in user_preferences]
        field_vector = [field_utilities.get(util, 0) for util in user_preferences]

        dot_product = sum(u * f for u, f in zip(user_vector, field_vector))
        user_magnitude = sqrt(sum(u ** 2 for u in user_vector))
        field_magnitude = sqrt(sum(f ** 2 for f in field_vector))

        if user_magnitude == 0 or field_magnitude == 0:
            return 0

        return dot_product / (user_magnitude * field_magnitude)

    def _parse_preferences(self, preferences_str):
        preferences = {}
        if preferences_str:
            prefs = preferences_str.split(',')
            for pref in prefs:
                util, value = pref.split('-')
                preferences[util.strip()] = int(value.strip())
        return preferences
    
    def get_filtered_fields(self, data):
        date = data.get('date')
        start_time = data.get('start_time')
        end_time = data.get('end_time')
        location = data.get('location')
        sport_type = data.get('sport_type')
        user_id = data.get('user_id')
        user_latitude = float(data.get('user_latitude'))
        user_longitude = float(data.get('user_longitude'))

        # Fetch fields based on sport_type and location
        if location == 'All':
            fields = self.field_dao.get_fields_by_sport_type(sport_type)
        else:
            fields = self.field_dao.get_fields_by_sport_type_and_location(sport_type, location)

        user = self.user_dao.get_user_by_id(user_id)

        if not fields or not user:
            return {'message': 'No fields or user found'}, 200

        filtered_fields = []
        for field in fields:
            available_intervals = self._is_field_available(field, date, start_time, end_time)
            if available_intervals:
                field_details = field.asdict()
                field_details['conf_interval'] = ' '.join(available_intervals)
                field_obj = self.field.from_dict(field_details)
                filtered_fields.append(field_obj)

        return self.calculate_field_scores(user, filtered_fields, user_latitude, user_longitude, True), 200

    def _is_field_available(self, field, date, start_time, end_time):
        reservations = self.reservation_dao.get_accepted_reservations_by_field_and_date(field.uid, date)
        available_intervals = []

        for interval in field.conf_interval.split():
            time_range, _ = interval.split(',')
            interval_start, interval_end = time_range.split('-')

            # Special handling for edge case when interval ends at 00:00
            if interval_end == "00:00" and (end_time < "23:59" or start_time > "00:00"):
                continue

            # Check if the time slot is within the requested range
            if start_time <= interval_start and end_time >= interval_end:
                # Check if this interval is free from reservations
                is_available = True
                for reservation in reservations:
                    res_start_time, res_end_time = reservation.interval_time.split('-')
                    if not (interval_end <= res_start_time or interval_start >= res_end_time):
                        is_available = False
                        break
                if is_available:
                    available_intervals.append(interval)

        return available_intervals
    
def degrees_to_radians(degrees):
        return degrees * (math.pi / 180.0)
    
def calculate_haversine_distance(lat1, lon1, lat2, lon2):
        earth_radius_km = 6371.0

        lat1 = degrees_to_radians(lat1)
        lon1 = degrees_to_radians(lon1)
        lat2 = degrees_to_radians(lat2)
        lon2 = degrees_to_radians(lon2)

        dlat = lat2 - lat1
        dlon = lon2 - lon1

        a = math.sin(dlat / 2) ** 2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon / 2) ** 2
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))

        distance = earth_radius_km * c
        return distance
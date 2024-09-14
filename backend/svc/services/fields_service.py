"""
This module provides the service layer for managing sports fields, handling business logic and interacting with the FieldDAO, UserDAO, and ReservationDAO.

Methods:
    - create_field(data): Creates a new field if the user is a manager.
    - update_conf_interval(field_id, conf_interval): Updates the confidence interval for a field.
    - update_field_details(field_id, name, utilities): Updates the field's name and utilities.
    - delete_field(field_id, manager_id): Deletes a field if it belongs to the manager.
    - get_fields_by_sport_type(sport_type): Retrieves fields by sport type.
    - get_fields_by_manager_id(manager_id): Retrieves fields managed by a specific manager.
    - get_available_time_slots(data): Returns available time slots for a field on a given date.
    - get_best_fields(data): Returns the best fields for a user based on proximity, rating, and facilities.
    - calculate_field_scores(user, fields, user_latitude, user_longitude, permission): Calculates the total score for each field based on user preferences.
    - get_filtered_fields(data): Retrieves fields filtered by sport type, location, and availability.
    - get_reservation_report(manager_id, year): Generates a reservation report for a manager by year.
    - get_hourly_reservations_report(manager_id, date): Generates an hourly reservation report for a manager for a specific date.

Helper Methods:
    - _calculate_proximity_score(user_latitude, user_longitude, field, permission): Calculates proximity score based on user and field coordinates.
    - _calculate_rating_score(field_id): Calculates rating score for a field.
    - _calculate_facilities_score(user_preferences, field_utilities): Calculates facilities score based on user preferences and field utilities.
    - _parse_preferences(preferences_str): Parses user preferences from a string.
    - _is_field_available(field, date, start_time, end_time): Checks if a field is available for a given time range.
    - degrees_to_radians(degrees): Converts degrees to radians.
    - calculate_haversine_distance(lat1, lon1, lat2, lon2): Calculates the Haversine distance between two points on Earth.
"""

import json
import math
from math import exp, sqrt
from flask import jsonify
from models.fields import Field
from svc.dao.fields_dao import FieldDAO
from svc.dao.user_dao import UserDAO
from svc.dao.reservation_dao import ReservationDAO

class FieldService:

    def __init__(self):
        self.field_dao = FieldDAO()
        self.field = Field()
        self.user_dao = UserDAO()
        self.reservation_dao = ReservationDAO()

    def create_field(self, data):
        """Creates a new field if the user is a manager."""
        user_id = data['manager_id']
        user_info = self.user_dao.get_user_by_id(user_id)
        if not user_info or user_info.user_type != 'manager':
            return jsonify({'error': 'Only managers can create fields'}), 403
        data['utilities'] = json.loads(data['utilities'])
        return self.field_dao.create_field(data=data)

    def update_conf_interval(self, field_id, conf_interval):
        """Updates the confidence interval for a field."""
        field = self.field_dao.update_conf_interval(field_id, conf_interval)
        if not field:
            return {'message': 'Field not found'}, 404
        field_dict = field.asdict()
        field_dict['average_rating'] = self.field_dao.get_average_rating(field.uid)
        return field_dict, 200

    def update_field_details(self, field_id, name, utilities):
        """Updates the field's name and utilities."""
        utilities = json.loads(utilities)
        field = self.field_dao.update_field_details(field_id, name, utilities)
        if not field:
            return {'message': 'Field not found'}, 404
        field_dict = field.asdict()
        field_dict['average_rating'] = self.field_dao.get_average_rating(field.uid)
        return field_dict, 200

    def delete_field(self, field_id, manager_id):
        """Deletes a field if it belongs to the manager."""
        field, message = self.field_dao.delete_field(field_id, manager_id)
        if not field:
            return {'message': message}, 404
        return {'message': message}, 200

    def get_fields_by_sport_type(self, sport_type):
        """Retrieves fields by sport type."""
        fields = self.field_dao.get_fields_by_sport_type(sport_type)
        if not fields:
            return {'message': 'No fields found for the given sport type'}, 200
        all_fields = []
        for field in fields:
            field_dict = field.asdict()
            field_dict['average_rating'] = self.field_dao.get_average_rating(field.uid)
            all_fields.append(field_dict)
        return all_fields, 200

    def get_fields_by_manager_id(self, manager_id):
        """Retrieves fields managed by a specific manager."""
        fields = self.field_dao.get_fields_by_manager_id(manager_id)
        if not fields:
            return {'message': 'No fields found for the given Manager ID'}, 200
        all_fields = []
        for field in fields:
            field_dict = field.asdict()
            field_dict['average_rating'] = self.field_dao.get_average_rating(field.uid)
            all_fields.append(field_dict)
        return all_fields, 200

    def get_available_time_slots(self, data):
        """Returns available time slots for a field on a given date."""
        field_id = data.get('field_id')
        date = data.get('date')
        if not field_id or not date:
            return {"error": "Field ID and date are required."}, 400
        field = self.field_dao.get_field_by_id(field_id)
        if not field:
            return {"error": "Field not found."}, 404
        conf_intervals = field.conf_interval.split(' ')
        time_price_map = {interval.split(',')[0]: interval.split(',')[1] for interval in conf_intervals}
        reservations = self.reservation_dao.get_reservations_by_date(field_id, date)
        reserved_time_slots = [reservation.interval_time for reservation in reservations]
        free_conf_interval = [f"{time_slot},{price}" for time_slot, price in time_price_map.items() if time_slot not in reserved_time_slots]
        return ' '.join(free_conf_interval), 200

    def get_best_fields(self, data):
        """Returns the best fields for a user based on proximity, rating, and facilities."""
        sport_type = data.get('sport_type')
        user_longitude = float(data.get('longitude', 0))
        user_latitude = float(data.get('latitude', 0))
        permission = data.get('permission', 'false').lower() == 'true'
        user_id = data.get('user_id')
        fields = self.field_dao.get_fields_by_sport_type(sport_type)
        user = self.user_dao.get_user_by_id(user_id)
        if not fields or not user:
            return {'message': 'No fields or user found'}, 200
        return self.calculate_field_scores(user, fields, user_latitude, user_longitude, permission), 200

    def calculate_field_scores(self, user, fields, user_latitude, user_longitude, permission):
        """Calculates the total score for each field based on user preferences."""
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
        return sorted(field_scores, key=lambda x: x['total_score'], reverse=True)

    def get_filtered_fields(self, data):
        """Retrieves fields filtered by sport type, location, and availability."""
        date = data.get('date')
        start_time = data.get('start_time')
        end_time = data.get('end_time')
        location = data.get('location')
        sport_type = data.get('sport_type')
        user_id = data.get('user_id')
        user_latitude = float(data.get('user_latitude'))
        user_longitude = float(data.get('user_longitude'))
        fields = self.field_dao.get_fields_by_sport_type_and_location(sport_type, location) if location != 'All' else self.field_dao.get_fields_by_sport_type(sport_type)
        user = self.user_dao.get_user_by_id(user_id)
        if not fields or not user:
            return {'message': 'No fields or user found'}, 200
        filtered_fields = [self.field.from_dict(field.asdict()) for field in fields if self._is_field_available(field, date, start_time, end_time)]
        return self.calculate_field_scores(user, filtered_fields, user_latitude, user_longitude, True), 200

    def get_reservation_report(self, manager_id, year):
        """Generates a reservation report for a manager by year."""
        fields = self.field_dao.get_fields_by_manager_id(manager_id)
        if not fields:
            return {'message': 'No fields found for the given Manager ID'}, 200
        report = {field.name: {year: {month: 0 for month in range(1, 12)}} for field in fields}
        for field in fields:
            reservations = self.reservation_dao.get_reservations_by_field_and_year(field.uid, year)
            for reservation in reservations:
                if reservation.status == 'Accepted':
                    month = int(reservation.date.split('.')[1])
                    report[field.name][year][month] += 1
        return report, 200

    def get_hourly_reservations_report(self, manager_id, date):
        """Generates an hourly reservation report for a manager for a specific date."""
        month, year = date.split('.')
        fields = self.field_dao.get_fields_by_manager_id(manager_id)
        if not fields:
            return {'message': 'No fields found for the given Manager ID'}, 200
        hourly_report = {f"{int(month):02}.{year}": {}}
        for field in fields:
            conf_intervals = field.conf_interval.split(' ')
            reservations = self.reservation_dao.get_reservations_by_field_and_month(field.uid, year, month)
            for interval in conf_intervals:
                try:
                    time_slot, _ = interval.split(',')
                    if time_slot not in hourly_report[f"{int(month):02}.{year}"]:
                        hourly_report[f"{int(month):02}.{year}"][time_slot] = []
                    count = sum(1 for reservation in reservations if reservation.interval_time == time_slot)
                    existing_entry = next((entry for entry in hourly_report[f"{int(month):02}.{year}"][time_slot] if entry['field_name'] == field.name), None)
                    if existing_entry:
                        existing_entry['count'] += count
                    else:
                        hourly_report[f"{int(month):02}.{year}"][time_slot].append({'field_name': field.name, 'count': count})
                except ValueError:
                    continue
        return hourly_report, 200

def degrees_to_radians(degrees):
    """Converts degrees to radians."""
    return degrees * (math.pi / 180.0)

def calculate_haversine_distance(lat1, lon1, lat2, lon2):
    """Calculates the Haversine distance between two points on Earth."""
    earth_radius_km = 6371.0
    lat1, lon1, lat2, lon2 = map(degrees_to_radians, [lat1, lon1, lat2, lon2])
    dlat, dlon = lat2 - lat1, lon2 - lon1
    a = math.sin(dlat / 2) ** 2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon / 2) ** 2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return earth_radius_km * c

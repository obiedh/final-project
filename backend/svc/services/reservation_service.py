"""
This module provides the service layer for managing reservations, handling business logic and interacting with the ReservationDAO and UserDAO.

Methods:
    - create_reservation(data): Creates a new reservation based on the provided data.
    - get_reservation(user_id): Retrieves all reservations for a specific user by their user ID.
    - update_reservation_status(uuid, Upstatus): Updates the status of a reservation by its UUID.
    - get_reservations_by_manager(manager_id): Retrieves all reservations for fields managed by a specific manager.
"""

from svc.dao.reservation_dao import ReservationDAO
from svc.dao.user_dao import UserDAO

class ReservationService:

    def __init__(self):
        self.reservation_dao = ReservationDAO()
        self.user_dao = UserDAO()

    def create_reservation(self, data):
        """Creates a new reservation based on the provided data."""
        return self.reservation_dao.create_reservation(data=data)
    
    def get_reservation(self, user_id):
        """Retrieves all reservations for a specific user by their user ID."""
        user = self.user_dao.get_user_by_id(user_id)
        if not user:
            return {"error": "User does not exist"}, 404
        
        reservations = self.reservation_dao.get_reservations_by_user_uuid(user_id)
        if not reservations:
            return {"message": "No reservations found for the given user ID"}, 200

        return [reservation.asdict_reservation() for reservation in reservations], 200
    
    def update_reservation_status(self, uuid, Upstatus):
        """Updates the status of a reservation by its UUID."""
        reservation = self.reservation_dao.get_reservation_by_reservation_uuid(uuid)
        if not reservation:
            return False  # Reservation not found

        return self.reservation_dao.update_reservation_status(uuid, status=Upstatus)
    
    def get_reservations_by_manager(self, manager_id):
        """Retrieves all reservations for fields managed by a specific manager."""
        reservations = self.reservation_dao.get_reservations_by_manager_id(manager_id)
        if not reservations:
            return {"message": "No reservations found for the given manager ID"}, 200
        return [reservation.asdict_reservation() for reservation in reservations], 200

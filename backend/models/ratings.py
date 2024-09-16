"""
This module defines the Ratings model, representing user ratings for sports fields.

Attributes:
    - uid (UUID): Primary key for each rating entry.
    - user_id (UUID): Foreign key linking to the user who provided the rating.
    - field_id (UUID): Foreign key linking to the field being rated.
    - rating (Integer): The rating value (e.g., from 1 to 5).
    - is_deleted (Boolean): Indicates if the rating has been soft deleted (True if deleted).
    - user: Relationship to the User model, representing the user who made the rating.
    - field: Relationship to the Field model, representing the rated field.
"""

from sqlalchemy import Boolean, Column, Integer, ForeignKey
from svc.db import db
from sqlalchemy.dialects.postgresql import UUID

class Ratings(db.Model):
    __tablename__ = 'ratings'

    uid = Column(UUID(as_uuid=True), unique=True, nullable=False, primary_key=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.uid'), nullable=False)
    field_id = Column(UUID(as_uuid=True), ForeignKey('fields.uid'), nullable=False)
    rating = Column(Integer, nullable=False)
    is_deleted = db.Column(Boolean, default=False) 


    # Define relationships
    user = db.relationship('User', back_populates='ratings')
    field = db.relationship('Field', back_populates='ratings')

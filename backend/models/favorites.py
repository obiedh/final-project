"""
This module defines the Favorites model, representing a user's favorite fields.

Attributes:
    - uid (UUID): Primary key for each favorite entry.
    - user_id (UUID): Foreign key linking to the user who favorited the field.
    - field_id (UUID): Foreign key linking to the favorited field.
    - created_at (DateTime): Timestamp when the favorite was created.
    - user: Relationship to the User model.
"""

from svc.db import db
from sqlalchemy import UUID, Column, DateTime

class Favorites(db.Model):
    __tablename__ = 'favorites'

    uid = Column(UUID(as_uuid=True), unique=True, nullable=False, primary_key=True)
    user_id = Column(UUID(36), db.ForeignKey('users.uid'))
    field_id = Column(UUID(36), db.ForeignKey('fields.uid'))
    created_at = Column(DateTime, default=db.func.now())

    user = db.relationship('User', back_populates='favorites')

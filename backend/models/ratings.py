from sqlalchemy import Column, Integer, ForeignKey
from svc.db import db
from sqlalchemy.dialects.postgresql import UUID

# Define the Ratings model
class Ratings(db.Model):
    __tablename__ = 'ratings'

    uid = Column(UUID(as_uuid=True), unique=True, nullable=False, primary_key=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey('users.uid'), nullable=False)
    field_id = Column(UUID(as_uuid=True), ForeignKey('fields.uid'), nullable=False)
    rating = Column(Integer, nullable=False)

    # Define relationships
    user = db.relationship('User', back_populates='ratings')
    field = db.relationship('Field', back_populates='ratings')

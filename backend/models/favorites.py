from svc.db import db
from sqlalchemy import UUID, Column, DateTime


class Favorites(db.Model):
    __tablename__ = 'favorites'

    uid = Column(UUID(as_uuid=True), unique=True, nullable=False, primary_key=True)
    user_id = Column(UUID(36), db.ForeignKey('users.uid'))
    field_id = Column(UUID(36), db.ForeignKey('fields.uid'))
    created_at = Column(DateTime, default=db.func.now())

    user = db.relationship('User', back_populates='favorites')

from sqlalchemy import Column, String
from svc.db import db


class User(db.Model):
    __tablename__ = 'users'

    uid = Column(db.UUID(as_uuid=True), unique=True, nullable=False, primary_key=True)
    username = Column(String(50), unique=True)
    password = Column(String(250))
    phonenum = Column(String(12), unique=True)
    user_type = Column(String(20))

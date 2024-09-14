"""
This module initializes the SQLAlchemy object to be used for database interactions across the application.

Attributes:
    - db: An instance of SQLAlchemy, used for ORM (Object-Relational Mapping) functionality.
"""

from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

"""
This module initializes and runs the Flask application, sets up the database, and registers the API routes.

Attributes:
    - app: The Flask application instance.
    - db: SQLAlchemy instance initialized with the Flask app for database interactions.
    - bcrypt: Bcrypt instance for handling password hashing.

Configuration:
    - SQLALCHEMY_DATABASE_URI: PostgreSQL connection string for the database.
    - SQLALCHEMY_TRACK_MODIFICATIONS: Disabled to reduce overhead.

Functions:
    - Registers the API blueprint with the URL prefix '/api'.
    - Initializes the database and creates tables.
    - Runs the application in development mode with debugging enabled.
"""
from flask import Flask
from svc.db import db
from api import api_bp
from flask_bcrypt import Bcrypt

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://postgres:123456@localhost/postgres'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db.init_app(app)
bcrypt = Bcrypt(app)

app.register_blueprint(api_bp, url_prefix='/api')

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)#for deveolpminet env





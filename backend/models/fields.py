from svc.db import db
from sqlalchemy.dialects import postgresql


class Field(db.Model):
    __tablename__ = 'fields'

    uid = db.Column(db.UUID(as_uuid=True), unique=True, nullable=False, primary_key=True)
    name = db.Column(db.String(100))
    location = db.Column(db.String(100))
    latitude = db.Column(db.String(30)) 
    longitude = db.Column(db.String(30))  
    sport_type = db.Column(db.String(100))  
    conf_interval = db.Column(db.String, nullable=True)  
    imageURL = db.Column(db.String(100))
    manager_id = db.Column(db.UUID(as_uuid=True), db.ForeignKey('users.uid'), nullable=False)
    utilities = db.Column(postgresql.JSON, nullable=True) 

    def asdict(self):
        return {
            'uid': self.uid,
            'name': self.name,
            'location': self.location,
            'latitude': self.latitude,
            'longitude': self.longitude,
            'sport_type': self.sport_type,
            'imageURL': self.imageURL,
            'utilities': self.utilities
        }
from svc.db import db
from models.user import User
import uuid



class UserDAO():
        
    def create_user(self, data):
        uid = str(uuid.uuid4())  # Generate a new UID
        new_user = User(uid=uid, username=data['username'], password=data['password'], phonenum=data['phonenum'])
        db.session.add(new_user)
        db.session.commit()
        return new_user
    
    def get_user_by_username(self, username):
        user = User.query.filter_by(username=username).first()
        return user
    
    def get_user_by_id(self, user_id):
        return db.session.query(User).filter_by(uid=user_id).first()

    def update_preference(self, user_name, preference):
        user = db.session.query(User).filter(User.username == user_name).first() 
        user.preference = preference
        db.session.commit()
        return "Preference updated successfully"
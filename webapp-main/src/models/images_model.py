from .. import db
from datetime import datetime, timezone
import uuid

class Image(db.Model):
    __tablename__ = 'images'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()), unique=True, nullable=False)
    file_name = db.Column(db.String(36), nullable=False)  
    url = db.Column(db.String(400), nullable=False)        
    upload_date = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=False)

    user = db.relationship("User", backref="images")

   

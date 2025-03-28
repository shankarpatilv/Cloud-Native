# app/models/models.py
from .. import db
from datetime import datetime, timezone
import uuid


class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()), unique=True, nullable = False)
    email = db.Column(db.String(50),nullable=False, unique=True)    
    password = db.Column(db.String(500),nullable=False)  
    first_name = db.Column(db.String(50),nullable=False)  
    last_name = db.Column(db.String(50),nullable=False)  
    # Use datetime.now with timezone-aware UTC
    account_created = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc))
    account_updated = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc))
    

    
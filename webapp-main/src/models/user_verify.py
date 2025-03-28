from .. import db
from datetime import datetime, timezone
import uuid

class UserVerification(db.Model):
    __tablename__ = 'user_verify'

    id = db.Column(db.String(36), primary_key=True, default=lambda: str(uuid.uuid4()), unique=True, nullable=False)
    user_id = db.Column(db.String(36), db.ForeignKey('users.id'), nullable=False)
    token = db.Column(db.String(255), nullable=False, unique=True)  # Unique verification token
    created_at = db.Column(db.DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)
    verified = db.Column(db.Boolean, default=False, nullable=False)

    # Establish relationship with the User model
    user = db.relationship("User", backref="user_verify")

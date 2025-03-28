from flask import Blueprint, request, jsonify
from sqlalchemy.exc import OperationalError
from datetime import datetime, timezone, timedelta
from .. import db
from ..models.user_verify import UserVerification
from ..models.user_model import User
from ..utilities import handle_response
import logging

logger = logging.getLogger(__name__)
verification_bp = Blueprint('verification_bp', __name__)

@verification_bp.route('/verify', methods=['GET'])
def verify_user():
    try:
        email = request.args.get('user')
        token = request.args.get('token')

        if not email or not token:
            logger.warning("Missing email or token in verification request.")
            return jsonify({"error": "Email and token are required."}), 400

        verification_record = db.session.query(UserVerification).join(User).filter(
            User.email == email,
            UserVerification.token == token
        ).first()

        if not verification_record:
            logger.warning("Invalid email or token provided for verification.")
            return jsonify({"error": "Invalid email or token."}), 400

        if verification_record.verified:
            logger.info(f"User {email} has already been verified.")
            return jsonify({"message": "User already verified."}), 200


        created_at_aware = verification_record.created_at
        if created_at_aware.tzinfo is None:
            created_at_aware = created_at_aware.replace(tzinfo=timezone.utc)

        expiration_time = created_at_aware + timedelta(minutes=2)
        if datetime.now(timezone.utc) > expiration_time:
            logger.warning(f"Token for user {email} has expired.")
            return jsonify({"error": "Verification token has expired."}), 400

        verification_record.verified = True
        db.session.commit()

        logger.info(f"User {email} verified successfully.")
        return jsonify({"message": "User verified successfully."}), 200

    except OperationalError:
        logger.error("Database connection error during verification.")
        return jsonify({"error": "Database error. Please try again later."}), 503
    except Exception as e:
        logger.error(f"An error occurred during verification: {str(e)}")
        return jsonify({"error": "An internal server error occurred."}), 500

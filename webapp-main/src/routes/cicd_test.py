from flask import Blueprint, request, g
from .. import db
from sqlalchemy import text
from ..utilities import handle_response 
from flask_httpauth import HTTPBasicAuth
from ..metrics.metrics import count_api_call, time_api_call, time_db_query, Timer
import time



cicd_bp = Blueprint('cicd_bp', __name__)

@cicd_bp.before_request
def before_request():
    g.start_time = time.time()  # Start the timer for API call duration
    count_api_call(request.endpoint)  # Increment the API call count

@cicd_bp.after_request
def after_request(response):
    duration = (time.time() - g.start_time) * 1000  # Duration in milliseconds
    time_api_call(request.endpoint, duration)  # Record API call duration
    return response

@cicd_bp.route('/cicd', methods=['GET'])
# @auth.login_required
def health_check():
    if request.content_length or request.data or request.query_string or request.form:
        return handle_response(400)
    elif request.method in ['GET']:
        with Timer("db.query.duration"):
            try:
                db.session.execute(text('SELECT 1'))
                db.session.commit()
                return handle_response(200)
            except Exception as e:
                return handle_response(503)
    else:
       return handle_response(405)



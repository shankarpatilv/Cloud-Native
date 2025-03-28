from asyncio.log import logger
from flask import Blueprint, request,jsonify, g, make_response
from flask_httpauth import HTTPBasicAuth
from sqlalchemy.exc import OperationalError
from sqlalchemy import text
from .. import db
import json
from ..utilities import handle_response , get_user_data_by_email ,hash_password 
from  ..models.user_model import User
import bcrypt 
from flask import abort, make_response
from flask import Blueprint, request, jsonify, abort
from datetime import datetime, timezone
from .. import db
from ..models.images_model import Image  
from ..models.user_verify import UserVerification  
import boto3
import uuid
from ..metrics.metrics import count_api_call, time_api_call, time_db_query, time_s3_call, Timer
import time, os
from ..logging.logging_config import logger

user_bp = Blueprint('user_bp', __name__)

auth = HTTPBasicAuth()
# logger = logging.getLogger(__name__)

@auth.verify_password
def verify(username, password):
    with Timer("db.query.duration"):
        try:
            ## checking database is still ON
            db.session.execute(text('SELECT 1'))  
            db.session.commit()

            ## if On, access the data 
            engine = db.engine
            connection = engine.connect()
            query = text("SELECT * FROM users WHERE email = :email")
            result = connection.execute(query,{"email": {username}})
            user = result.fetchone()
            
            logger.info(f"User {username} login attempt.") 

        except Exception as e:
            logger.error("Database connection error during login verification.") 
            return handle_response(503)

    if  not user:
        logger.warning("Authentication failed for unknown user.")
        # abort(handle_response(401))
        return  abort(handle_response(401))
    
    # userName =""
    # passWord =""
    # userName = user.email
    # passWord = user.password
    # result = bcrypt.checkpw(password.encode('utf-8') , passWord.encode('utf-8'))

    # if userName == username and bcrypt.checkpw(password.encode('utf-8') , passWord.encode('utf-8')):
    #     logger.info(f"User {username} authenticated successfully.")
    #     # send_email(username, "Logged IN", "You have logged!!!!!")
    #     return username
    # else:
    #     logger.warning(f"Invalid password attempt for user {username}.")
    #     # return make_response(jsonify({"error": "Unauthorized access"}), 401)
    #     abort(handle_response(401))

    userName = user.email
    passWord = user.password

    if not bcrypt.checkpw(password.encode('utf-8'), passWord.encode('utf-8')):
        logger.warning(f"Invalid password attempt for user {username}.")
        abort(handle_response(401))

    

    verification_query = text("""
        SELECT verified FROM user_verify WHERE user_id = :user_id
    """)
    verification_result = connection.execute(verification_query, {"user_id": user.id})
    verification_record = verification_result.fetchone()

    if not verification_record or not verification_record.verified:
        logger.warning(f"User {username} attempted to login without verification.")
        abort(handle_response(403))  




    logger.info(f"User {username} authenticated and verified successfully.")
    return username


@user_bp.before_request
def before_request():
    g.start_time = time.time()

@user_bp.after_request
def after_request(response):
    duration = (time.time() - g.start_time) * 1000  
    endpoint = request.endpoint
    count_api_call(endpoint)  
    time_api_call(endpoint, duration)  
    logger.info(f"Processed request for {endpoint} in {duration:.2f}ms.")
    return response


sns_client = boto3.client('sns', region_name='us-east-1')
SNS_TOPIC_ARN = os.getenv('SNS_TOPIC_ARN') 


@user_bp.route('/v3/user', methods=['POST'])
def add_user():
        try:            
            if request.query_string or request.form:
                logger.warning("Unexpected query string or form data in request.")
                return handle_response(400)
            db.session.execute(text('SELECT 1')) 
            db.session.commit()
            data = request.get_json()
            required_fields = ['email', 'password', 'first_name', 'last_name']
            missing_fields = [field for field in required_fields if field not in data or not data[field]]
            ## allowed fields handling
            allowed_fields = {"first_name", "last_name", "password","email"}
            for key in data.keys():
                if key not in allowed_fields:
                    
                    return handle_response(400) 
        
            if missing_fields:
                logger.warning("Missing required fields in the user registration request.")
                return handle_response(400)
            
            if  not str(data.get('first_name')).isalpha():
                return handle_response(400)
            if  not str(data.get('last_name')).isalpha():
                return handle_response(400)
            
            email = data['email']
            from email_validator import validate_email
            if not email:
                logger.warning("Invalid email format.")
                handle_response(400)
            elif not validate_email(email):
                handle_response(400)  
            # hashing the password 
            hash=hash_password(data.get('password'))
            new_user = User(email=data.get('email'), first_name=data.get('first_name'), last_name=data.get('last_name'),password=hash)
            
            db.session.add(new_user)
            db.session.commit()


            verification_token = str(uuid.uuid4())

            new_verification = UserVerification(
                user_id=new_user.id,  
                token=verification_token
            )

            db.session.add(new_verification)
            db.session.commit()

            sns_payload = {
                "user_id": new_user.id,  
                "email": new_user.email,
                "verification_token": verification_token,
                "created_at": datetime.now(timezone.utc).isoformat()
            }

            sns_client.publish(
                TopicArn=SNS_TOPIC_ARN,
                Message=json.dumps(sns_payload)
            )

            logger.info(f"User {email} created successfully.")
            return get_user_data_by_email(db, data.get('email')), 201
        except OperationalError:
                logger.error("Database operational error while adding user.")
                return handle_response(503)
        except Exception as e:
                 logger.fatal("Critical error while adding user.")
                 return handle_response(400)


@user_bp.route('/v3/user/self', methods=['GET'])
@auth.login_required
def login_user():
        
        if request.content_length or request.data or request.query_string or request.form:
                return handle_response(400)
        try:
                user_data = get_user_data_by_email(db,auth.username())
                print(user_data)
                logger.debug(f"Retrieved user data for {auth.username()}.")
                return jsonify(user_data),200
        except Exception as e:
                logger.error("Failed to retrieve user data.")
                return handle_response(503)
       
        

@user_bp.route('/v3/user/self', methods=['PUT'])
@auth.login_required
def update_user():
    try:
        if request.query_string or request.form:
                logger.warning("Unexpected query string or form data in update request.")
                return handle_response(400)
        email = auth.username()
        user = db.session.query(User).filter_by(email=email).first()
       
        if user is None:
            logger.warning(f"User {email} not found.")

            return handle_response(404) 
        ## json error handling 
        try:
            data = request.get_json()
        except Exception as e:
             
             return handle_response(400)
        
        ## empty data handling
        if not data:
            logger.error("Empty data or missing fields in update request.")
            return handle_response(400)  
        
        empty_fields = [key for key, value in data.items() if not value]
        
        ## empty fields handling
        if empty_fields :
            return handle_response(400)
        
        ## allowed fields handling
        allowed_fields = {"first_name", "last_name", "password"}
        for key in data.keys():
            if key not in allowed_fields:
                return handle_response(400) 
        
            
            if  not str(data.get('first_name')).isalpha():
                return handle_response(400)
            
            if  not str(data.get('last_name')).isalpha():
                return handle_response(400) 

        if "first_name" in data:            
            user.first_name = data["first_name"]
        
        if "last_name" in data:
            user.last_name = data["last_name"]
        if "password" in data:
            hash = hash_password(data['password'])
            user.password = hash

        db.session.commit()
        logger.info(f"User {email} updated successfully.")
        return handle_response(204) 

    except Exception as e:
        # db.session.rollback()
        logger.error("Failed to update user data.")
        return handle_response(503)  

sts_client = boto3.client('sts')
accountID = os.getenv('ACCOUNT_ID')
assumed_role = sts_client.assume_role(
    RoleArn=f"arn:aws:iam::{accountID}:role/s3_management_role",
    RoleSessionName="S3AccessSession"
)

credentials = assumed_role['Credentials']

s3 = boto3.client(
    's3',
    aws_access_key_id=credentials['AccessKeyId'],
    aws_secret_access_key=credentials['SecretAccessKey'],
    aws_session_token=credentials['SessionToken']
)


s3_bucket_name = os.getenv('BUCKET_NAME')
 

@user_bp.route('/v3/user/self/pic', methods=['POST'])
@auth.login_required
def upload_profile_pic():
    user_email = auth.username()
    user_data = get_user_data_by_email(db, user_email)
    user_id = user_data["id"]
    existing_image = db.session.query(Image).filter_by(user_id=user_id).first()
    if existing_image:
        logger.warning(f"User {user_email} already has a profile picture.")
        return  abort(handle_response(409))

    if not user_data or "id" not in user_data:
        return handle_response(400) 
    
    user_id = user_data["id"]

    if 'file' not in request.files:
        logger.warning("No file provided in upload request.")
        return handle_response(400)

    file = request.files['file']
    if file.filename == '':
        return handle_response(400)

    file_name = file.filename
    s3_key = f"{user_id}/{file_name}"

    
    try:
        with Timer("s3.upload.duration"):
            s3.upload_fileobj(file, s3_bucket_name, s3_key, ExtraArgs={"ContentType": file.content_type})
        logger.info(f"Profile picture for {user_email} uploaded successfully.")
    except Exception as e:
        logger.error(f"Failed to upload profile picture for {user_email}.")
        return handle_response(503)
    
    image_url = f"https://{s3_bucket_name}.s3.amazonaws.com/{s3_key}"
    new_image = Image(
        file_name=file_name,
        id=str(uuid.uuid4()),  
        url=image_url,
        user_id=user_id,
        upload_date=datetime.now(timezone.utc)
    )
    
    with Timer("db.query.duration"):
        db.session.add(new_image)
        db.session.commit()
    
    response_data = {
        "file_name": new_image.file_name,
        "id": new_image.id,
        "url": new_image.url,
        "upload_date": new_image.upload_date.isoformat(),
        "user_id": new_image.user_id
    }
    # send_email(user_email, "User Pic Uploaded", "Your Account Picture has been added!!!")
    return jsonify(response_data), 201
    

@user_bp.route('/v3/user/self/pic', methods=['GET'])
@auth.login_required
def get_profile_pic():
    user_email = auth.username()
    user_data = get_user_data_by_email(db, user_email)
    if not user_data or "id" not in user_data:
        return handle_response(400)
    
    user_id = user_data["id"]

    existing_image = db.session.query(Image).filter_by(user_id=user_id).first()
    if not existing_image:
        return handle_response(404)

    response_data = {
        "file_name": existing_image.file_name,
        "id": existing_image.id,
        "url": existing_image.url,
        "upload_date": existing_image.upload_date.isoformat(),
        "user_id": existing_image.user_id
    }

    return jsonify(response_data), 200

@user_bp.route('/v3/user/self/pic', methods=['DELETE'])
@auth.login_required
def delete_profile_pic():
    user_email = auth.username()
    user_data = get_user_data_by_email(db, user_email)
    if not user_data or "id" not in user_data:
        abort(400, "User Id not found")
    
    user_id = user_data["id"]

    existing_image = db.session.query(Image).filter_by(user_id=user_id).first()
    if not existing_image:
        return handle_response(404)

    s3_key = f"{user_id}/{existing_image.file_name}"
    try:
        s3.delete_object(Bucket=s3_bucket_name, Key=s3_key)
    except Exception as e:
        return handle_response(503)
    try:
        db.session.delete(existing_image)
        db.session.commit()
    except Exception as e:
        db.session.rollback()
        return handle_response(503)
    return  handle_response(200)

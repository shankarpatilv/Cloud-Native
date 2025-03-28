from flask import make_response
from sqlalchemy import text
import bcrypt 
# utilities.py
import os
import requests
import logging

def handle_response(status_code):
    response = make_response('', status_code)
    response.headers['Cache-Control'] = 'no-cache'
    response.headers['Content-Length'] = '0'
    return response

def hash_password (password):
    generate_password = password
    bytes = generate_password.encode('utf-8')
    salt = bcrypt.gensalt()
    hash = bcrypt.hashpw(bytes, salt)
    return hash

def get_user_data_by_email(db, email):
    user_data = {
        "id": '',
        "first_name": '',
        "last_name": '',
        "email": '',
        "account_created": '',
        "account_updated": ''
    }

    engine = db.engine
    connection = engine.connect()
    try:
        query = text("SELECT * FROM users WHERE email = :email")
        result = connection.execute(query, {"email": email})
        
        for row in result:
            user_data["id"] = row.id
            user_data["first_name"] = row.first_name
            user_data["last_name"] = row.last_name
            user_data["email"] = row.email
            user_data["account_created"] = row.account_created.isoformat()
            user_data["account_updated"] = row.account_updated.isoformat()    
    finally:
        connection.close()  
        
    return user_data




# SENDGRID_API_KEY = os.getenv("SENDGRID_API_KEY")
# FROM_EMAIL = os.getenv("FROM_EMAIL")

# def send_email(to_email, subject, content):

#     if not SENDGRID_API_KEY:
#         logging.error("SENDGRID_API_KEY is missing. Cannot send email.")
#         return False
    
#     url = "https://api.sendgrid.com/v3/mail/send"
#     headers = {
#         "Authorization": f"Bearer {SENDGRID_API_KEY}",
#         "Content-Type": "application/json"
#     }
#     data = {
#         "personalizations": [
#             {
#                 "to": [{"email": to_email}],
#                 "subject": subject
#             }
#         ],
#         "from": {"email": FROM_EMAIL},
#         "content": [{"type": "text/plain", "value": content}]
#     }
    
#     response = requests.post(url, headers=headers, json=data)
#     if response.status_code == 202:
#         logging.info(f"Email sent successfully to {to_email} with subject '{subject}'")

#     else:
#         logging.error(f"Failed to send email to {to_email}. Response: {response.status_code}, {response.text}")

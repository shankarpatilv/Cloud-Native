import os
import requests
import json
import boto3

def send_verification_email(to_email, verification_link):
    """
    Send the verification email using a third-party email service like SendGrid.
    """

    secrets_client = boto3.client('secretsmanager')
    secret_name = os.getenv("SENDGRID_SECRET_NAME")
    
    secret_response = secrets_client.get_secret_value(SecretId=secret_name)
    secret = json.loads(secret_response['SecretString'])

    sendgrid_api_key = secret['api_key']
    fromemail = os.getenv("email")
    headers = {
        "Authorization": f"Bearer {sendgrid_api_key}",
        "Content-Type": "application/json"
    }
    payload = {
        "personalizations": [{"to": [{"email": to_email}]}],
        "from": {"email": fromemail},
        "subject": "Verify Your Email",
        "content": [
            {
                "type": "text/plain",
                "value": f"Please verify your email by clicking this link: {verification_link}"
            }
        ]
    }
    response = requests.post("https://api.sendgrid.com/v3/mail/send", headers=headers, json=payload)

    if response.status_code != 202:
        raise Exception(f"Failed to send email: {response.status_code}, {response.text}")

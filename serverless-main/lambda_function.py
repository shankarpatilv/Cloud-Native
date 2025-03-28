import json
from email_service import send_verification_email
import os
url=os.getenv("BASE_URL")

def lambda_handler(event, context):
    """
    Lambda handler for processing SNS messages and sending verification emails.
    """
    try:
        record = event['Records'][0]
        message = json.loads(record['Sns']['Message'])

        user_id = message.get("user_id")
        email = message.get("email")
        token = message.get("verification_token")
        created_at = message.get("created_at")


        if not user_id or not email or not token:
            raise ValueError("Invalid payload: Missing required fields.")


        # Send the verification email
        verification_link = f"http://{url}/verify?user={email}&token={token}"
        send_verification_email(email, verification_link)

        # Log the email send event in the database
        # log_to_database(user_id, email, token, created_at)

        return {"statusCode": 200, "body": "Verification email sent successfully."}

    except Exception as e:
        print(f"Error processing SNS message: {e}")
        return {"statusCode": 500, "body": "Internal server error."}

# 🌐 Cloud-Native Web Application (Flask + AWS)

This project is a backend-only cloud-native web application developed using **Python (Flask)** and deployed on **AWS**. It supports user management features and integrates cloud services to ensure scalability, high availability, and security.

---

## 📌 Features

- User management APIs: create, retrieve, update, delete users
- Email verification with AWS SNS + Lambda + SendGrid
- Profile image upload/download via AWS S3
- Secure database operations using Amazon RDS (MySQL)
- Logging and monitoring with CloudWatch
- Scalable infrastructure with EC2, ALB, Auto Scaling

---

## 🏗️ Tech Stack

- **Backend**: Python (Flask)
- **Database**: MySQL on Amazon RDS
- **Infrastructure**: AWS (EC2, S3, RDS, IAM, SNS, Lambda, CloudWatch), Terraform, Packer
- **CI/CD**: GitHub Actions
- **Email Service**: SendGrid

---

## 🚀 Deployment Workflow

1. **Infrastructure Provisioning**:  
   Terraform provisions VPC, subnets, EC2, RDS, IAM, ALB, and security groups.

2. **Custom AMI**:  
   Packer builds a pre-configured AMI with Flask app, Python dependencies, and CloudWatch agent.

3. **CI/CD Pipeline**:  
   GitHub Actions automates testing, AMI creation, and instance refresh on code push.

4. **Auto-Scaling & Load Balancing**:  
   CloudWatch metrics trigger scaling; ALB distributes traffic and checks EC2 health.

---

## 🔐 Security Features

- IAM roles with least-privilege access
- RDS in private subnet (no public access)
- SSL/TLS enabled via AWS Certificate Manager
- S3 objects encrypted using SSE-C (KMS)

---

## 🌍 Domain Setup

- Domain purchased via Namecheap
- DNS configured with AWS Route 53 to point to ALB

---

## 📊 Monitoring & Logging

- CloudWatch Logs: EC2 logs, app logs
- CloudWatch Metrics: CPU, memory, request latency
- Alarms and notifications via SNS

---

## ✅ How to Run (For Testing Locally)

```bash
# Clone the repository
git clone https://github.com/your-username/cloud-app.git
cd cloud-app

# Set up virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Set environment variables (example: .env file)
export DB_HOST=...
export DB_USER=...
export DB_PASSWORD=...
export SENDGRID_API_KEY=...
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...

# Run Flask App
python app.py


# AWS Networking Setup using Terraform

## Overview
This repository contains Terraform configurations for setting up a multi-VPC networking infrastructure in AWS. The configuration includes the creation of multiple VPCs, subnets, Internet Gateways, and Route Tables dynamically based on user input parameters. Each VPC will have three public and three private subnets spread across different availability zones.

## Prerequisites
Before you begin, ensure you have the following tools installed and configured on your local machine:

1. **Terraform** (>= 0.12)
2. **AWS CLI** (with the correct IAM permissions)
3. **AWS Account** (with a user having permissions to create VPCs, subnets, and route tables)

### Install Terraform
Follow the instructions on [Terraform's official documentation](https://learn.hashicorp.com/tutorials/terraform/install-cli) to install Terraform.

### Configure AWS CLI
Set up the AWS CLI by running:

```bash
aws configure
```

Provide your:
- AWS Access Key ID
- AWS Secret Access Key
- Default region name (e.g., `us-east-1`)
- Default output format (e.g., `json`)



## Input Variables
The configuration uses several input variables defined in the `variables.tf` file. The key variables include:

- **`aws_region`**: The AWS region where resources should be created (e.g., `us-east-1`).
- **`vpc_cidr_base`**: The base CIDR block for VPCs (e.g., `10.0`).
- **`no_of_vpcs`**: The number of VPCs to create.
  

  
You can customize these values either by editing the `terraform.tfvars` file or by passing them as command-line arguments.

## Setup Instructions

### Step 1: Clone the Repository
Clone this repository to your local machine using:

```bash
git clone https://github.com/your-username/terraform-networking.git


```

### Step 2: Initialize Terraform
Run the following command to initialize the working directory. This will download the necessary providers and set up your environment:

```bash
terraform init
```

### Step 3: Customize the Configuration (Optional)
If you want to customize the VPC CIDR block, region, or number of VPCs, update the `terraform.tfvars` file:

```hcl
aws_region = "us-east-1"
cidr = "10.0"
vpc_name = "custom-vpc"
```

### Step 4: Review the Configuration
Before applying, you can review the changes Terraform will make by running:

```bash
terraform plan 
```

### Step 5: Apply the Configuration
To create the infrastructure, run the following command. This command will prompt you to confirm before creating the resources:

```bash
terraform apply 
```

When prompted, type `yes` to apply the changes.

### Step 6: Verify the Deployment
After the Terraform apply completes, you can log in to your [AWS Management Console](https://aws.amazon.com/console/) and navigate to the **VPC Dashboard**. 

### Step 7: Clean Up Resources
If you want to destroy the created infrastructure, run:

```bash
terraform destroy 
```

### Step 7: SSL Certificate
```bash
sudo aws acm import-certificate \
    --certificate fileb:///Users/vivekspatil/Downloads/demo_bannu_me/demo_bannu_me.crt \
    --private-key fileb:///Users/vivekspatil/private.key \    
    --certificate-chain fileb:///Users/vivekspatil/Downloads/demo_bannu_me/demo_bannu_me.ca-bundle \
    --profile demo

Output after succesfull import
{
    "CertificateArn": "arn:aws:acm:us-east-1:******:certificate/****"
}
```



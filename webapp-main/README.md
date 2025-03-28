
# Packer & Terraform: Custom AMI Build and EC2 Deployment Assigment 04

## Overview 
This repository contains Terraform and Packer configurations for building a custom AMI and deploying it to an EC2 instance in AWS. The AMI includes necessary application dependencies, and Terraform handles networking and EC2 instance deployment.

## Prerequisites
Ensure the following tools are installed and configured:

- **Terraform (>= 0.12)**
- **Packer (>= 1.5)**
- **AWS CLI** (with the appropriate IAM permissions)
- **AWS Account** (permissions to create VPCs, EC2 instances, AMIs, etc.)


### Install Terraform and Packer
Follow the official installation guides:

- [Terraform Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [Packer Installation Guide](https://learn.hashicorp.com/tutorials/packer/getting-started-install)

### Configure AWS CLI
Run the following command to configure your AWS credentials:

```bash
aws configure
```

You’ll need to enter:

- **AWS Access Key ID**
- **AWS Secret Access Key**
- **Default region name** (e.g., `us-east-1`)
- **Default output format** (e.g., `json`)

## Packer: Building the Custom AMI

### Input Variables
The following input variables are defined in the `packer-template.pkr.hcl` file:

- **AWS region**
- **VPC Subnet ID**
- **AMI name**
  
You can customize these values in the `variables.pkr.hcl` file or pass them as command-line arguments.

### Steps to Build AMI with Packer

1. **Clone the Repository:**

   ```bash
   git clone https://github.com/your-username/packer-terraform-ami.git
   ```

2. **Initialize Packer:**

   Navigate to the `packer` directory:

   ```bash
   cd packer
   ```

   Run the following to initialize and validate the Packer template:

   ```bash
   packer init .
   packer validate packer-template.pkr.hcl
   ```

3. **Build the AMI:**

   Run the following command to build the AMI:

   ```bash
   packer build -var "artifact_path=artifact/application_artifact.zip" packer-template.pkr.hcl
   ```

   The AMI will be created and shared with the specified account(s) if configured.

4. **Verify the AMI:**
   After the build completes, verify the AMI in the **EC2 Dashboard > AMIs** section of the AWS Management Console.

## Terraform: Deploying EC2 with Custom AMI



### Terraform Variables
The following input variables are defined in the `variables.tf` file:

- **AWS region**
- **AMI ID**
- **VPC Subnet ID**

Customize these values in the `terraform.tfvars` file.

### Steps to Deploy EC2 Using the Custom AMI

1. **Initialize Terraform:**

   Navigate to the `terraform` folder and initialize the environment:

   ```bash
   cd terraform
   terraform init
   ```

2. **Customize the Variables (Optional):**

   You can update the AWS region, AMI ID, and other configurations in the `terraform.tfvars` file:

   ```hcl
   aws_region  = "us-east-1"
   cidr        = "10.0.0.0/16"
   vpc_name    = "custom-vpc"
   ami_id      = "ami-01826cd3d4bc56521"
   ssh_key     = "aws-ec2-mac"
   DB_USERNAME = "csye6225"
   DB_PASSWORD = "slazzon1234"
   DB_NAME     = "healthcheck"
   ```

3. **Review the Plan:**

   Before applying the changes, you can preview the infrastructure changes with:

   ```bash
   terraform plan
   ```

4. **Apply the Terraform Configuration:**

   To deploy the EC2 instance, run:

   ```bash
   terraform apply
   ```

   Type `yes` to confirm the deployment.

5. **Verify the Deployment:**
   Once completed, verify the EC2 instance in the **EC2 Dashboard > Instances** section of the AWS Management Console.

### Clean Up Resources

To delete the created infrastructure, run:

```bash
terraform destroy
```

Confirm by typing `yes` when prompted.

## Submission Instructions

1. **Prepare the submission**:
   - Create a folder named `firstname_lastname_neuid_##`.
   - Clone the repository into this directory using `git clone`.
   - Zip the folder and verify its contents.

2. **Submit**:
   - Upload the zip file to the assignment submission portal.


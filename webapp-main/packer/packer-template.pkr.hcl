packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8, < 2.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  default = "us-east-1"
}

variable "aws_vpc_id" {
  description = "The default VPC ID where the instance will be launched"
  default     = "vpc-0392ea5d138c4810d"
}

variable "aws_subnet_id" {
  description = "The default VPC subnet ID"
  default     = "subnet-095ee09200c88b7f8"
}

variable "demo_user" {
  description = "Demo user id"
  default     = "440744240103"
}
variable "artifact_path" {
  description = "The path to the application artifact"
  default     = "../webapp.zip"
}

source "amazon-ebs" "ubuntu" {
  ami_name      = "WebAMI_${formatdate("YYYY_MM_DD_hh_mm_ss", timestamp())}"
  instance_type = "t2.micro"
  region        = var.aws_region
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
  ami_users    = [var.demo_user]
  vpc_id       = var.aws_vpc_id
  subnet_id    = var.aws_subnet_id
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "file" {
    source = var.artifact_path

    # source      = "../webapp.zip"
    destination = "/tmp/application_artifact.zip"
  }

  provisioner "file" {
    source      = "./scripts/artifact.sh"
    destination = "/tmp/artifact.sh"
  }

  provisioner "file" {
    source      = "./scripts/run.sh"
    destination = "/tmp/run.sh"
  }

  provisioner "file" {
    source      = "./scripts/setup.sh"
    destination = "/tmp/setup1.sh"
  }
  provisioner "file" {
    source      = "./app.service"
    destination = "/tmp/app.service"
  }
  provisioner "file" {
    source      = "./cloudwatch-config.json"
    destination = "/tmp/cloudwatch-config.json"
  }


  provisioner "shell" {
    inline = [

      "sudo mv /tmp/app.service /etc/systemd/system/app.service",

      "chmod +x /tmp/setup1.sh",
      "/tmp/setup1.sh",


      # MOve the CloudWatch configuration to the correct location
      "sudo mv /tmp/cloudwatch-config.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json",



      # sEtup the AMi with Python and flask 


      "sudo groupadd csye6225 || true",

      # Create a new user 'csye6225' and add to 'csye6225' group with no login shell
      "sudo useradd -r -M -s /usr/sbin/nologin -g csye6225 csye6225 || true",
      "echo 'csye6225 ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/csye6225",

      # Get the webapp appplication here
      "chmod +x /tmp/artifact.sh",
      "sudo -u csye6225 /tmp/artifact.sh",

      # Run the flask application

      "chmod +x /tmp/run.sh",
      "sudo -u csye6225 /tmp/run.sh",

    ]
  }
}

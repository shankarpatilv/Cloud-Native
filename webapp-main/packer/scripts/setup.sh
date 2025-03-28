#!/bin/bash
sudo apt update 
sudo apt install python3 python3-pip curl -y
pip3 install Flask 

sudo apt-get update
curl -O https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

# sudo apt-get install -y amazon-cloudwatch-agent
# sudo apt-get install -y statsd
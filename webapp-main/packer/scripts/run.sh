#!/bin/bash


cd /opt/webapp || { echo 'could not change to /opt/webapp directory'; exit 1; }

sudo systemctl start mysql 
sudo apt-get update
sudo apt-get install python3-venv -y 


python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt 


sudo systemctl daemon-reload
sudo systemctl enable app.service

sudo systemctl enable amazon-cloudwatch-agent


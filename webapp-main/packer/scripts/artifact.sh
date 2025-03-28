#!/bin/bash
sudo apt-get install -y unzip python3-pip 
sudo mkdir -p /opt/webapp
sudo chown -R csye6225:csye6225 /opt/webapp 

sudo unzip /tmp/application_artifact.zip -d /opt/ 

sudo mkdir -p /opt/webapp/logs
sudo touch /opt/webapp/logs/app.log


sudo chown -R csye6225:csye6225 /opt/webapp
sudo chmod -R 755 /opt/webapp
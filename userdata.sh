#!/bin/bash
yum install -y git
git clone https://github.com/cs399f24/voting_dynamodb_s3_ec2.git
cd voting_dynamodb_s3_ec2
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
cp voting.service /etc/systemd/system
systemctl enable voting
systemctl start voting

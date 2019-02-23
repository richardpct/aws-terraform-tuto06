#!/bin/bash

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y upgrade
sudo apt-get -y install awscli
INSTANCE_ID="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
aws --region eu-west-3 ec2 associate-address --instance-id $INSTANCE_ID --allocation-id ${eip_web_id}
sudo apt-get -y install golang
sudo go get github.com/richardpct/go-example-tuto04
sudo /root/go/bin/go-example-tuto04 -redishost ${database_host} -redispass ${database_pass} -env ${environment}

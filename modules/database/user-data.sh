#!/bin/bash

exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get -y install redis
sudo sed -i -e 's/^\(bind 127.0.0.1 ::1\)/#\1/' /etc/redis/redis.conf
sudo sed -i -e 's/# \(requirepass\) foobared/\1 ${database_pass}/' /etc/redis/redis.conf
sudo systemctl restart redis

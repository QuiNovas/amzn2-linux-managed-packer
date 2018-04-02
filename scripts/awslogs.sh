#!/usr/bin/env bash

sudo yum -y install awslogs

sudo systemctl enable awslogsd.service
sudo systemctl start awslogsd

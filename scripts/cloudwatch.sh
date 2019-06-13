#!/bin/bash

set -ex

cd /tmp

wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm

wget -q https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm.sig

KEY=$(curl https://s3.amazonaws.com/amazoncloudwatch-agent/assets/amazon-cloudwatch-agent.gpg 2>/dev/null| gpg --import 2>&1 |  cut -d: -f2 | grep 'key' | sed -r 's/\s*|key//g')

FINGERPRINT=$(echo "9376 16F3 450B 7D80 6CBD 9725 D581 6730 3B78 9C72" | sed 's/\s//g')

if ! gpg --fingerprint $KEY| sed -r 's/\s//g' | grep -q "${FINGERPRINT}"; then
  echo "AWS Cloudwatch rpm gpg key fingerprint is invalid"
  exit 1
fi

if ! gpg --verify ./amazon-cloudwatch-agent.rpm.sig ./amazon-cloudwatch-agent.rpm; then
  echo "AWS Cloudwatch signature does not match rpm"
  exit 1
fi

sudo rpm -U ./amazon-cloudwatch-agent.rpm

sudo cp /tmp/files/cloudwatch.json /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

sudo rm -f ./amazon-cloudwatch-agent*

sudo systemctl enable amazon-cloudwatch-agent

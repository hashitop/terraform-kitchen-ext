#! /usr/bin/env bash

# Make a directory to contain the key
mkdir -p test/assets

# Generate a 4096 bit RSA key with a blank passphrase in the directory
ssh-keygen \
  -b 4096 \
  -C "Kitchen-Terraform AWS provider tutorial" \
  -f test/assets/key_pair \
  -N "" \
  -t rsa \
  -m PEM

export AWS_ACCESS_KEY_ID="${1}"
export AWS_DEFAULT_REGION="${3}"
export AWS_SECRET_ACCESS_KEY="${2}"

if [ "${3}" == "ap-southeast-1" ]; then
    platform="centos"
elif [ "${3}" == "ap-southeast-2" ]; then
    platform="ubuntu"
else
    echo "Region is missing, please specify a supported region [\"ap-southeast-1\",\"ap-southeast-2\"]"
    exit -1
fi

bundle exec kitchen converge ${platform} diagnose --all

#Add a slight delay to ensure the DNS is publicly available
sleep 5

bundle exec kitchen verify ${platform} diagnose --all

bundle exec kitchen destroy ${platform} diagnose --all

unset AWS_ACCESS_KEY_ID
unset AWS_DEFAULT_REGION
unset AWS_SECRET_ACCESS_KEY

# Cleanup assets directory
rm -rf test/assets
#!/usr/bin/env bash
$(aws ecr get-login --region us-east-1 --no-include-email)
ACCOUNT=$(aws sts get-caller-identity --output text --query 'Account')
docker build . --no-cache -t $ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/ecr_webserver
docker push $ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/ecr_webserver
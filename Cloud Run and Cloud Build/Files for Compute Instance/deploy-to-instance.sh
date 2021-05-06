#!/bin/bash
ADDRESS=$1
USERNAME=$2

ssh -i build.pem $USERNAME@$ADDRESS "mkdir -p /git && git clone $GIT_REPO /git/ats; cd /git/ats && git reset --hard && git pull && docker-compose up --build"
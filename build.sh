#!/bin/env bash


now=$(date +'%Y-%m-%d_%T')

if [ "$1" = "install" ]
then
    go install -ldflags "-X main.sha1ver=`git rev-parse HEAD` -X main.buildTime=$now" 
exit 0

fi

go build -ldflags "-X main.sha1ver=`git rev-parse HEAD` -X main.buildTime=$now"

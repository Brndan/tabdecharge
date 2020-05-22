#!/usr/bin/env bash

# Script de construction du programme
# bash build.sh install → installe le programme dans le GOPATH
# bash build.sh         → compile pour Windows, Linux et macOS

# Variables dans le code GO changées au moment du link
# -X main.sha1ver → ajoute au moment du link l'identifiant git du commit
# -X main.buildTime → Date et heure de compilation

# -w -s → supprime les infos de débogage : diminue le poids du binaire

now=$(date +'%Y-%m-%d_%T')

if [ "$1" = "install" ]
then
    go install -ldflags "-X main.sha1ver=`git rev-parse --short HEAD` -X main.buildTime=$now" 
exit 0

fi

rm -r dist/
mkdir -p dist/{linux,macos,windows}

env GOOS=linux GOARCH=amd64 go build -ldflags "-X main.sha1ver=`git rev-parse --short HEAD` -X main.buildTime=$now -w -s"  -o dist/linux/ github.com/Brndn/tabdecharge
env GOOS=windows GOARCH=amd64 go build -ldflags "-X main.sha1ver=`git rev-parse --short HEAD` -X main.buildTime=$now -w -s" -o dist/windows/ github.com/Brndn/tabdecharge
env GOOS=darwin GOARCH=amd64 go build -ldflags "-X main.sha1ver=`git rev-parse --short HEAD` -X main.buildTime=$now -w -s" -o dist/macos/ github.com/Brndn/tabdecharge

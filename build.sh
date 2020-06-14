#!/usr/bin/env bash

# Script de construction du programme
# bash build.sh install     → installe le programme dans le GOPATH
# bash build.sh             → compile pour Windows, Linux et macOS
# bash build.sh compress    → compile pour les 3 plateformes et compresse (upx)

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

if [ "$1" = "compress" ]
then

    command -v upx >/dev/null 2>&1 || { echo >&2 "upx n’est pas installé."; exit 1; }
    
    (
        cd dist/linux || exit
        for i in *
        do
            upx --best "$i"
        done
    )

    (
        cd dist/macos || exit
        for i in *
        do
            upx --best "$i"
        done
    )

    (
        cd dist/windows || exit
        for i in *
        do
            upx --best "$i"
        done
    )
fi

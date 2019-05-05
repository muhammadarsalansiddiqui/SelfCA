#!/bin/bash

dpkg -s libnss3-tools &> /dev/null

if [ $? -eq 0 ]; then
    certfile=$1
    certname=$2

    for certDB in $(find ~/ -name "cert8.db")
    do
        certdir=$(dirname "$certDB");
        certutil -A -n "$certname" -t "TCu,Cu,Tu" -i "$certfile" -d dbm:"$certdir"
    done

    for certDB in $(find ~/ -name "cert9.db")
    do
        certdir=$(dirname "$certDB");
        certutil -A -n "$certname" -t "TCu,Cu,Tu" -i "$certfile" -d sql:"$certdir"
    done
else
    echo "Please install 'libnss3-tools'";
    exit 1;
fi

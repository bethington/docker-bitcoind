#!/bin/bash
git pull
mv ./data ../data
docker build --build-arg VERSION=v0.18.0 -t bethington/bitcoind .
docker build --build-arg VERSION=v0.18.0 -t bethington/bitcoind:v0.18.0 .
mv ../data ./data

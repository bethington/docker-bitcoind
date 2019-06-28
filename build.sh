#!/bin/bash
mv ./data ../data
docker build --build-arg VERSION=v0.18.0 --build-arg USER_ID=1000 --build-arg GROUP_ID=1000 -t bethington/bitcoind .
docker build --build-arg VERSION=v0.18.0 --build-arg USER_ID=1000 --build-arg GROUP_ID=1000 -t bethington/bitcoind:v0.18.0 .
mv ../data ./data

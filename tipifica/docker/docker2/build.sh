#!/bin/sh
docker build --build-arg=HTTPS_PROXY=http://10.38.97.65:8118 -t csuarez/php:2 .

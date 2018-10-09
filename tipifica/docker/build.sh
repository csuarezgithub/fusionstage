#!/bin/sh
docker build --build-arg=HTTPS_PROXY=http://10.38.97.65:8118 -t webdevops/php:centos-7-php7 .

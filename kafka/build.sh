#!/bin/sh
docker build --build-arg=HTTP_PROXY=http://10.38.97.65:8118 -t csuarez/kafka:1 .

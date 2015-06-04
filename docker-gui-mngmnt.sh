#!/bin/bash

# docker container monitoring with cadvisor:
# https://github.com/google/cadvisor

# How to use:
# http://127.0.0.1:8080
sudo docker run \
  --volume=/:/rootfs:ro \
  --volume=/var/run:/var/run:rw \
  --volume=/sys:/sys:ro \
  --volume=/var/lib/docker/:/var/lib/docker:ro \
  --publish=8080:8080 \
  --detach=true \
  --name=cadvisor \
  google/cadvisor:latest

# docker GUI management with Seagull:
# https://github.com/tobegit3hub/seagull

# How to use:
# http://127.0.0.1:10086
docker run -d -p 10086:10086 -v /var/run/docker.sock:/var/run/docker.sock tobegit3hub/seagull

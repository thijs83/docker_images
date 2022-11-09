#!/bin/bash

xhost +local:docker

docker run -it \
    --privileged \
    --volume="/dev/:/dev/" \
    --network="host" \
    --runtime nvidia \
    realsense \
    bash

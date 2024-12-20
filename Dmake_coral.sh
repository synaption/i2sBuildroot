#!/bin/bash

# Define the Docker image
DOCKER_IMAGE="custom-ubuntu:22.04"

# Define the working directory inside the container
WORKINGDIR=$(pwd)

# Get the UID and GID of the host user
# Check if the custom Docker image exists, if not, build it
if [[ "$(docker images -q $DOCKER_IMAGE 2> /dev/null)" == "" ]]; then
    docker build --build-arg UID=$UID --build-arg GID=$GID -t $DOCKER_IMAGE .
fi

#docker build -t custom-ubuntu:20.04 .


# Run the Docker container and execute the build commands as non-root user
docker run --rm  -v $WORKINGDIR:/home/builduser/i2sBuildroot -u $(id -u):$(id -g) --privileged --network host -w "/home/builduser/i2sBuildroot" $DOCKER_IMAGE /bin/bash -c "sh make_coral.sh $1"
#  docker run --rm -it -v $WORKINGDIR:/home/builduser/i2sBuildroot -u $(id -u):$(id -g) --privileged --network host -w "/home/builduser/i2sBuildroot" $DOCKER_IMAGE /bin/bash 

#!/bin/bash

# Build and push to DockerHub multi architecture images
# for all of the containers used by FarmData2.

DOCKER_HUB_USER="farmdata2"
PLATFORMS=linux/amd64,linux/arm64

# Check for the local build flag -d
LOCAL_BUILD=0
getopts 'd' opt 2> /dev/null
if [ $opt == 'd' ];
then 
  LOCAL_BUILD=1
  shift
fi

if [ $# -lt 1 ];
then
  echo "Please specify one or more images to build."
  echo "E.g. build-images.bash dev farmOS"
  echo "  Valid images to build are the directories in the docker folder"
  echo "  that contain a Dockerfile. (e.g. dev farmos mariaDB phpmyadmin)."
  exit 255
fi

# Only check the login and make the builder if we are pushing the images.
if [ $LOCAL_BUILD == 0 ];
then

    # Check that the DockerHub user identified above is logged in.
    LOGGED_IN=$(docker-credential-desktop list | grep "$DOCKER_HUB_USER" | wc -l | cut -f 8 -d ' ')
    if [ "$LOGGED_IN" == "0" ];
    then
        echo "Please log into Docker Hub as $DOCKER_HUB_USER before building images."
        echo "  Use: docker login"
        echo "This allows multi architecture images to be pushed."
        exit 255
    fi

    # Create the builder if it doesn't exist.
    FD2_BUILDER=$(docker buildx ls | grep "fd2builder" | wc -l | cut -f 8 -d ' ')
    if [ "$FD2_BUILDER" == "0" ];
    then
        echo "Making new builder for FarmData2 images."
        docker buildx create --name fd2builder
    fi

    # Switch to use the fd2builder.
    echo "Using the fd2bilder."
    docker buildx use fd2builder
fi

# Build and push each of the images to Docker Hub.
for IMAGE in "$@"
do
  if [ ! -f $IMAGE/Dockerfile ] | [ ! -f $IMAGE/repo.txt ];
  then
    echo "Error: $IMAGE/Dockerfile or $IMAGE/repo.txt does not exit."
    echo "       Skipping $IMAGE"
  else
    echo "Building $IMAGE..."

    cd $IMAGE

    if [ -f before.bash ];
    then
      echo "  Running before.bash..."
      source ./before.bash
    fi

    TAG=$(cat repo.txt)
    REPO="$DOCKER_HUB_USER/$TAG"
    echo "  Performing docker build using tag $REPO ..."
    docker buildx build --platform $PLATFORMS -t $REPO --push .

    if [ -f after.bash ];
    then
      echo "  Running after.bash..."
      source ./after.bash
    fi 

    cd ..

    echo "Done building $IMAGE."
  fi
done

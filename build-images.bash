#!/bin/bash

# Build and push to DockerHub multi architecture images
# for all of the containers used by FarmData2.

DOCKER_HUB_USER="farmdata2"
PLATFORMS=linux/amd64,linux/arm64

LOCAL_BUILD=0
PUSH=0
while getopts ":dp:" opt
do
  case $opt in
    d) LOCAL_BUILD=1;;
    p) PUSH=1;;
    *) echo "Invalid option: -$opt";;
  esac
done

if [ $# -lt 1 ];
then
  echo "Please specify one or more images to build."
  echo "E.g. build-images.bash dev farmOS"
  echo "  Valid images to build are the directories in the docker folder"
  echo "  that contain a Dockerfile. (e.g. dev farmos mariaDB phpmyadmin)."
  exit 255
fi

# Only check the login if we are pushing the images.
if [ "$LOCAL_BUILD" = "0" ] && [ "$PUSH" = "1" ];
then
  # Check that the DockerHub user identified above is logged in.
  if [ "$(which docker-credential-desktop)" != "" ];
  then
    LOGGED_IN=$(docker-credential-desktop list | grep "$DOCKER_HUB_USER" | wc -l | cut -f 8 -d ' ')
  else
    LOGGED_IN=$(docker system info | grep -E 'Username|Registry' | grep "$DOCKER_HUB_USER" | wc -l | cut -f 8 -d ' ')
  fi

  if [ "$LOGGED_IN" = "0" ];
  then
    echo "Please log into Docker Hub as $DOCKER_HUB_USER before building images."
    echo "  Use: docker login"
    echo "This allows multi architecture images to be pushed."
    exit 255
  fi
fi

if [ "$LOCAL_BUILD" = "0" ];
then
  # Create the builder if it doesn't exist.
  FD2_BUILDER=$(docker buildx ls | grep "fd2builder" | wc -l | cut -f 8 -d ' ')
  if [ "$FD2_BUILDER" = "0" ];
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
  if [ ! -f "$IMAGE"/Dockerfile ] | [ ! -f "$IMAGE"/repo.txt ];
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

    if [ "$LOCAL_BUILD" = "1" ];
    then
      echo "  Building image locally."
      docker build -t "$REPO" .
    elif [ "$PUSH" = "0" ];
    then
      echo "  Building multi architecture image."
      docker buildx build --platform "$PLATFORMS" -t "$REPO" .
    else
      echo "  Building multi architecture image and pushing to dockerhub."
      docker buildx build --platform "$PLATFORMS" -t "$REPO" --push .
    fi

    if [ -f after.bash ];
    then
      echo "  Running after.bash..."
      source ./after.bash
    fi 

    cd ..

    echo "Done building $IMAGE."
  fi
done

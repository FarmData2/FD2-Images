#!/bin/bash

# Build and push to DockerHub multi architecture images
# for all of the containers used by FarmData2.

REPO_DIR=$(git rev-parse --show-toplevel)
DOCKER_HUB_USER="farmdata2"
PLATFORMS=linux/amd64,linux/arm64

# Make sure we can connect to the Docker daemon.
source "$REPO_DIR/lib/checkDocker.bash"

LOCAL_BUILD=0
PUSH=0
while getopts ":dp:" opt
do
  case $opt in
    d) LOCAL_BUILD=1;;
    p) PUSH=1;;
    *) echo "Invalid option: -$opt";;
  esac
  shift
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
  source "$REPO_DIR/lib/dockerhubLogin.bash"
fi

if [ "$LOCAL_BUILD" = "0" ];
then
  # Create the builder if it doesn't exist.
  source "$REPO_DIR/lib/makeBuilder.bash"
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

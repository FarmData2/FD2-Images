#!/bin/bash

# This script will build the dev container and optionally
# push it to DockerHub.  To push to docker hub it is necessary
# to be logged into dockerhub via docker as a FarmData2 admin.

function usage {
  echo ""
  echo "preBuildDevContainer.bash Usage:"
  echo "  -b | --build: Build but do not push the image."
  echo "  -p | --push: Push the most recently built image image to dockerhub."
  echo "          If --build is specified the built image is pushed."
  echo "          Otherwise push the previously built image if one exists."
  echo "          Note: Requires farmdata2 admin login for dockerhub."
  echo " -n | --no-cache: Build the image without using Docker cache."
  echo " -h | --help: Display this message."
  echo ""
  exit 255
}

REPO_DIR=$(git rev-parse --show-toplevel)

if [ $# -lt 1 ]; then
  usage
fi

TAG=$(cat repo.txt)
DOCKER_HUB_USER="farmdata2"
REPO="$DOCKER_HUB_USER/$TAG"
#PLATFORMS=linux/amd64
PLATFORMS=linux/arm64
#PLATFORMS=linux/amd64,linux/arm64

DEVCONTAINER_PATH=devcontainer.json

# Make sure we can connect to the Docker daemon.
source "$REPO_DIR/lib/checkDocker.bash"

PUSH=0
BUILD=0
USE_CACHE=1
FLAGS=$(getopt -o bpnh \
  --long build,push,no-cache,help \
  -- "$@" 2> /dev/null)
if [ $? -ne 0 ]; then
  echo "Error: Invalid options provided."
  usage
fi

eval set -- "$FLAGS"
while true; do
  case $1 in
    -b | --build)
      BUILD=1
      shift
      ;;
    -p | --push)
      PUSH=1
      shift
      ;;
    -n | --no-cache)
      USE_CACHE=0
      shift
      ;;
    -h | --help)
      usage
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Unrecognized option: $1"
      usage
      ;;
  esac
done

if [ "$BUILD" = "1" ]; then
  echo "Building dev container image for platforms: $PLATFORMS"

  # Create the builder if it doesn't exist.
  source "$REPO_DIR/lib/makeBuilder.bash"

  if [ "$USE_CACHE" = "0" ]; then
    devcontainer build \
      --workspace-folder "$REPO_DIR" \
      --config "$DEVCONTAINER_PATH" \
      --image-name "$REPO" \
      --platform "$PLATFORMS" \
      --push false \
      --no-cache
  else
    devcontainer build \
      --workspace-folder "$REPO_DIR" \
      --config "$DEVCONTAINER_PATH" \
      --image-name "$REPO" \
      --platform "$PLATFORMS" \
      --push false
  fi
fi

# Only check the login if we are pushing the image.
if [ "$PUSH" = "1" ]; then
  echo "Pushing $REPO image to dockerhub..."
  # Check that the DockerHub user identified above is logged in.
  source "$REPO_DIR/lib/dockerhubLogin.bash"

  docker push "$REPO"
  echo "Pushed."
fi

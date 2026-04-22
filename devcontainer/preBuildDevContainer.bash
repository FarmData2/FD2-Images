#!/bin/bash

# This script will build the dev container and optionally
# push it to DockerHub.  To push to docker hub it is necessary
# to be logged into dockerhub via docker as a FarmData2 admin.

REPO_DIR=$(git rev-parse --show-toplevel)

function usage {
  echo ""
  echo "preBuildDevContainer.bash Usage:"
  echo " -d | --debug: Build but do not the push images to dockerhub."
  echo " -a | --amd64: Build and push the amd64 image and push to dockerhub."
  echo " -n | --no-cache: Build the image without using Docker cache."
  echo " -h | --help: Display this message."
  echo ""
  exit 255
}

DOCKER_HUB_USER="farmdata2"
DEVCONTAINER_PATH=devcontainer.json

TAG=$(cat repo.txt)
REPO="$DOCKER_HUB_USER/$TAG"

AMD_PLATFORM=linux/amd64
PLATFORMS="$AMD_PLATFORM"

PUSH=0
BUILD=0
USE_CACHE=1
FLAGS=$(getopt -o danh \
  --long debug,amd64,no-cache,help \
  -- "$@" 2> /dev/null)
if [ $? -ne 0 ]; then
  echo "Error: Invalid options provided."
  usage
fi

DEBUG=0
USE_CACHE=1
PUSH_VALUE=true
eval set -- "$FLAGS"
while true; do
  case $1 in
    -d | --debug)
      DEBUG=1
      PUSH_VALUE=false
      shift
      ;;
    -a | --amd64)
      PLATFORMS="$AMD_PLATFORM"
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

# If we are pushing to dockerhub, check that we are logged in.
if [ "$DEBUG" = "0" ]; then
  # Check that the DOCKER_HUB_USER is logged in.
  source "$REPO_DIR/lib/dockerhubLogin.bash"
fi

# Build and push (if not debugging) the dev container image.
echo "Building dev container image for platforms: $PLATFORMS..."
if [ "$USE_CACHE" = "0" ]; then
  echo "without using the Docker cache..."  
fi  
if [ "$DEBUG" = "0" ]; then
  echo "and pushing to DockerHub as $REPO..."
fi

if [ "$USE_CACHE" = "0" ]; then
  devcontainer build \
    --workspace-folder "$REPO_DIR" \
    --config "$DEVCONTAINER_PATH" \
    --image-name "$REPO" \
    --platform "$PLATFORMS" \
    --push "$PUSH_VALUE" \
    --no-cache
else
  devcontainer build \
    --workspace-folder "$REPO_DIR" \
    --config "$DEVCONTAINER_PATH" \
    --image-name "$REPO" \
    --platform "$PLATFORMS" \
    --push "$PUSH_VALUE"
fi

echo "Done."
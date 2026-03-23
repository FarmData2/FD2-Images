#!/bin/bash

# This script will build the dev container and optionally
# push it to DockerHub.  To push to docker hub it is necessary
# to be logged into dockerhub via docker as a farmdata2 admin.

function usage {
  echo ""
  echo "preBuildDevContainer.bash Usage:"
  echo " -m | --multi: Build the multi-architecture image and push to dockerhub."
  echo " -d | --debug: Build the amd64 image but do not push."
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
#PLATFORMS=linux/arm64
PLATFORMS=linux/amd64,linux/arm64
EMULATORS=arm64

DEVCONTAINER_PATH=devcontainer.json

# Make sure we can connect to the Docker daemon.
source "$REPO_DIR/lib/checkDocker.bash"


#
# Need to rework this to use the -d and -m flags.
# If -d then set the platform to just amd64 and push to false.
# If -m then set the platform to all of them, push to true, register the emulator, check for dockerhub login.
# Then be sure the pushing is handled correctly.
# 

# Register the necessary emulators with docker for the multi-architecture build.
docker run --privileged --rm tonistiigi/binfmt --install "$EMULATORS" 2> /dev/null
quit

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

# Only check the login if we are pushing the image.
if [ "$PUSH" = "1" ]; then
  # Check that the DockerHub user identified above is logged in.
  source "$REPO_DIR/lib/dockerhubLogin.bash"
fi

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
      --push true \
      --no-cache
  else
    devcontainer build \
      --workspace-folder "$REPO_DIR" \
      --config "$DEVCONTAINER_PATH" \
      --image-name "$REPO" \
      --platform "$PLATFORMS" \
      --push true
  fi
fi


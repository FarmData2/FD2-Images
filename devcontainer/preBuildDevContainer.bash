#!/bin/bash

# This script will build the dev container and optionally
# push it to DockerHub.  To push to docker hub it is necessary
# to be logged into dockerhub via docker as a FarmData2 admin.

function usage {
  echo ""
  echo "preBuildDevContainer.bash Usage:"
  echo " -d | --debug: Build the amd64 image but do not push."
  echo " -m | --multi: Build the multi-architecture image and push to dockerhub."
  echo " -n | --no-cache: Build the image without using Docker cache."
  echo " -h | --help: Display this message."
  echo ""
  echo " Note: One and only one of -d or -m must be used."
  exit 255
}

REPO_DIR=$(git rev-parse --show-toplevel)
TAG=$(cat repo.txt)
DOCKER_HUB_USER="farmdata2"
REPO="$DOCKER_HUB_USER/$TAG"
AMD_PLATFORM=linux/amd64
ARM_PLATFORM=linux/arm64
EMULATORS=arm64
DEVCONTAINER_PATH=devcontainer.json

# Make sure we can connect to the Docker daemon.
source "$REPO_DIR/lib/checkDocker.bash"

PUSH=0
BUILD=0
USE_CACHE=1
FLAGS=$(getopt -o dmnh \
  --long debug,multi-arch,no-cache,help \
  -- "$@" 2> /dev/null)
if [ $? -ne 0 ]; then
  echo "Error: Invalid options provided."
  usage
fi

DEBUG=0
MULTI_ARCH=0
USE_CACHE=1
eval set -- "$FLAGS"
while true; do
  case $1 in
    -d | --debug)
      DEBUG=1
      PUSH_VALUE=false
      PLATFORMS=$AMD_PLATFORM
      shift
      ;;
    -m | --multi-arch)
      MULTI_ARCH=1
      PUSH_VALUE=true
      PLATFORMS="$AMD_PLATFORM,$ARM_PLATFORM"
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

if [ $DEBUG -eq 1 ] && [ $MULTI_ARCH -eq 1 ]; then
  echo "Error: Cannot use both debug ( -d ) and multi-arch ( -m ) options together."
  echo ""
  usage
fi

if [ $DEBUG -eq 0 ] && [ $MULTI_ARCH -eq 0 ]; then
  echo "Error: One of debug ( -d ) or multi-arch ( -m ) must be specified."
  echo ""
  usage
fi

# If we are pushing to dockerhub, check that we are logged in.
if [ "$MULTI_ARCH" = "1" ]; then
  # Check that the DOCKER_HUB_USER is logged in.
  source "$REPO_DIR/lib/dockerhubLogin.bash"
fi

# If building the multi-arch image, we need to make sure qemu is installed and configured.
if ! which qemu-system-x86_64 &> /dev/null; then
  echo "Installing qemu emulators..."
  sudo apt-get update &> /dev/null
  sudo apt-get install -y --no-install-recommends qemu-system &> /dev/null
  docker run --privileged --rm tonistiigi/binfmt --install "$EMULATORS" &> /dev/null
  echo "Installed."
fi

# Create the docker buildx builder if it doesn't exist.
source "$REPO_DIR/lib/makeBuilder.bash"

# Build and push (if multi-arch) the dev container image.
echo "Building dev container image for platforms: $PLATFORMS..."
if [ "$USE_CACHE" = "0" ]; then
  echo "without using the Docker cache..."  
fi  
if [ "$MULTI_ARCH" = "1" ]; then
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
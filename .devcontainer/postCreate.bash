#!/bin/bash

REPO_DIR=$(git rev-parse --show-toplevel)

# Install the devcontainers cli that is needed to do the pre-build.
echo "Installing devcontainers CLI..."
sudo npm install -g @devcontainers/cli &> /dev/null
echo "Installed."

# qemu needs to be installed and configured to build multi-architecture images.
echo "Installing qemu emulators..."
sudo apt-get update &> /dev/null
sudo apt-get install -y --no-install-recommends qemu-system &> /dev/null
docker run --privileged --rm tonistiigi/binfmt --install "$EMULATORS" &> /dev/null
echo "Installed."

# Create the docker buildx builder if it doesn't exist.
source "$REPO_DIR/lib/makeBuilder.bash"
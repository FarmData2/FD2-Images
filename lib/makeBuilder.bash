 # Create the builder if it doesn't exist.
FD2_BUILDER=$(docker buildx ls | grep -c "^fd2builder")
if [ "$FD2_BUILDER" = "0" ]; then
echo "Making new builder for FarmData2 images."
docker buildx create \
    --name fd2builder \
    --driver=docker-container \
    --bootstrap
fi

echo "Installing arm64 QEMU emulation..."
docker run --privileged --rm tonistiigi/binfmt --install arm64
echo "Installed."

# Switch to use the fd2builder.
echo "Setting up to use the fd2builder."
docker buildx use fd2builder
echo "Setup."
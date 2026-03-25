 # Create the builder if it doesn't exist.
FD2_BUILDER=$(docker buildx ls | grep -c "^fd2builder")
if [ "$FD2_BUILDER" = "0" ]; then
  echo "Creating new builder for FarmData2 images."
  docker buildx create \
    --name fd2builder \
    --driver=docker-container \
    --bootstrap
  echo "Created."
fi

# Switch to use the fd2builder.
echo "Switching to use the fd2builder."
docker buildx use fd2builder
echo "Switched."
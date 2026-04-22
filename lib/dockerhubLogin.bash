# Check that the DockerHub user identified above is logged in.
LOGGED_IN=$(docker system info | grep -E 'Username|Registry' | grep -c "$DOCKER_HUB_USER")

if [ "$LOGGED_IN" = "0" ]; then
echo "Please log into Docker Hub as $DOCKER_HUB_USER before prebuilding the devcontainer image."
echo "  Use: docker login --username $DOCKER_HUB_USER"
echo "       Then run this script again."
echo "       This allows multi architecture images to be pushed to dockerhub."
echo "       Note: Password will not be displayed as it is typed."
exit 255
fi
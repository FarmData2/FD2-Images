source "$REPO_DIR/../FarmData2/bin/lib/checkServices.lib.bash"

checkDocker
DOCKER=$?
if ((!DOCKER)); then
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo "Could not connect to the Docker daemon."
  echo ""
  echo "Try stopping and restarting the codespace."
  echo "If that does not work try creating a new one."
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo ""
  exit 1
fi
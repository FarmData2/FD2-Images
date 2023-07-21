#!/bin/bash

echo "startup.bash running..."

# Cleanup from past vnc session that may hav been running in the container.
# This clean-up is not done if the container is stopped (not deleted).
if [ -f "/tmp/.S11-unix/X1" ]
then
  echo "Cleaning up residual X11 session."
  rm /tmp/.X11-unix/X1 2> /dev/null
  rm /tmp/.X1-lock 2> /dev/null
fi

# Get the GID of the docker group on the host os. 
# If a group with that GID already exists in the container use it.
# Otherwise create a new fd2docker group with that GID in the container.
echo "Establishing docker/fd2docker group in the container."
HOST_DOCKER_GID=$(cat ~/.fd2/gids/docker.gid)
HOST_DOCKER_GID_IN_CONTAINER=$(echo /etc/group | grep ":$HOST_DOCKER_GID:")
if [ -z "$HOST_DOCKER_GID_IN_CONTAINER" ];
then
  echo "  Creating new fd2docker group with GID=$HOST_DOCKER_GID."
  echo "fd2dev" | sudo -S groupadd --gid $HOST_DOCKER_GID fd2docker
  echo "  fd2docker group Created."
fi

# Ensure that the fd2dev user can rwx /var/run/docker.sock
# in the container.
echo "  Adding fd2dev user to docker/fd2docker group."
echo "fd2dev" | sudo -S usermod -a -G $HOST_DOCKER_GID fd2dev
echo "  Setting docker/fd2docker as group for the /var/run/docker.sock."
echo "fd2dev" | sudo -S chgrp +$HOST_DOCKER_GID /var/run/docker.sock
echo "  Giving group rwx permissions on /var/run/docker.sock."
echo "fd2dev" | sudo -S chmod g+rwx /var/run/docker.sock

# Get the GID of the fd2grp on the host os.
# If a group with tht GID already exists in the container use it.
# Otherwise create a new fd2grp group with that GID in the container.
echo "Establishing the fd2grp in the container."
HOST_FD2GRP_GID=$(cat ~/.fd2/gids/fd2grp.gid)
HOST_FD2GRP_GID_IN_CONTAINER=$(echo /etc/group | grep ":$HOST_FD2GRP_GID:")
if [ -z "$HOST_FD2GRP_GID_IN_CONTAINER" ];
then
  echo "  Creating new fd2grp group with GID=$HOST_FD2GRP_GID."
  echo "fd2dev" | sudo -S groupadd --gid $HOST_FD2GRP_GID fd2grp
  echo "  fd2grp created."
fi

# Ensure that the fd2grp and fd2dev has rw access to all of the stuff
# in the home directory, including the FarmData2 repo.  Note: The UIDs
# may not match on Linux/WSL which is why the fd2grp is necessary.
echo "  Adding fd2dev user to the fd2grp."
echo "fd2dev" | sudo -S usermod -a -G $HOST_FD2GRP_GID fd2dev

# Only reset group ownership if necessary.  This should only be the 
# first time the docker volume for /home/fd2dev is mounted.
FD2DEV_HOME_GROUP=$(ls -ld /home/fd2dev | cut -d' ' -f4)
if [ ! "$FD2DEV_HOME_GROUP" == "fd2grp" ]
then
  echo "  Setting fd2grp as group for everything /home/fd2dev recursively."
  echo "fd2dev" | sudo -S chgrp -R fd2grp /home/fd2dev
  echo "  Giving fd2grp rw permissoins on /home/fd2dev recursively."
  echo "fd2dev" | sudo -S chmod -R g+rw /home/fd2dev
fi

# Ensure that the dbus service is running.
echo "Starting the dbus service."
echo "fd2dev" | sudo /etc/init.d/dbus restart
echo "  dbus Started."

# Launch the VNC server
echo "Launching the vncserver."
vncserver \
  -localhost no \
  -geometry 1024x768 -depth 16 \
  -SecurityTypes None --I-KNOW-THIS-IS-INSECURE
echo "  vnc server launched."

# Launch the noVNC server.
echo "Launching the novnc server."
/usr/share/novnc/utils/launch.sh --vnc localhost:5901 --listen 6901 &
echo "  novnc server launched."

echo "Whew... I'm tired... sleeping now."
sleep infinity
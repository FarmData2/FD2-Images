#!/bin/bash

# Cleanup from past vnc session that may hav been running in the container.
# This clean-up is not done when the container is stopped (not deleted).
rm /tmp/.X11-unix/X1 2> /dev/null
rm /tmp/.X1-lock 2> /dev/null

# Get the GID of the docker group on the host os. 
# If a group with that GID already exists in the container use it.
# Otherwise create a new fd2docker group with that GID in the container.
HOST_DOCKER_GID=$(cat ~/.fd2/gids/docker.gid)
HOST_DOCKER_GID_IN_CONTAINER=$(echo /etc/group | grep ":$HOST_DOCKER_GID:")
if [ -z "$HOST_DOCKER_GID_IN_CONTAINER" ];
then
  echo "fd2dev" | sudo -S groupadd --gid $HOST_DOCKER_GID fd2docker
fi

# Ensure that the fd2dev user can rwx /var/run/docker.sock
# in the container.
echo "fd2dev" | sudo -S usermod -a -G $HOST_DOCKER_GID fd2dev
echo "fd2dev" | sudo -S chgrp +$HOST_DOCKER_GID /var/run/docker.sock
echo "fd2dev" | sudo -S chmod g+rwx /var/run/docker.sock

# Get the GID of the fd2grp on the host os.
# If a group with tht GID already exists in the container use it.
# Otherwise create a new fd2grp group with that GID in the container.
HOST_FD2GRP_GID=$(cat ~/.fd2/gids/fd2grp.gid)
HOST_FD2GRP_GID_IN_CONTAINER=$(echo /etc/group | grep ":$HOST_FD2GRP_GID:")
if [ -z "$HOST_FD2GRP_GID_IN_CONTAINER" ];
then
  echo "fd2dev" | sudo -S groupadd --gid $HOST_FD2GRP_GID fd2grp
fi

# Ensure that the fd2dev user has rw access to all of the stuff
# in the FarmData2 repo via the fd2grp group.
echo "fd2dev" | sudo -S usermod -a -G $HOST_FD2GRP_GID fd2dev
echo "fd2dev" | sudo -S chgrp -R fd2grp /home/fd2dev/FarmData2
echo "fd2dev" | sudo -S chmod -R g+rw /home/fd2dev/FarmData2

# Ensure that the dbus service is running.
echo "fd2dev" | sudo /etc/init.d/dbus restart

# Launch the VNC server
vncserver \
  -localhost no \
  -geometry 1024x768 -depth 16 \
  -SecurityTypes None --I-KNOW-THIS-IS-INSECURE

# Launch the noVNC server.
/usr/share/novnc/utils/launch.sh --vnc localhost:5901 --listen 6901 &

sleep infinity
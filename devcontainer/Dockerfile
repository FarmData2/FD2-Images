FROM debian:bookworm-slim

# Install additional packages needed for the development environment.
RUN apt update \
  && apt install -y --no-install-recommends \
    build-essential \
    zip \
    jq \
    sudo \
    git \
    openssl \
  && apt-get clean -y \
  && apt-get autoclean -y \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/*

# Create a non-root user with UID that matches the UID of
# the postgres user in the fd2_postgres container (999) and a GID
# that matches the docker group in the devcontainer (1001).  This
# ensure proper permissions to the mounted docker/db directory
# and that the user can access /var/run/docker.sock.
ARG USERNAME=fd2dev
ARG USER_UID=999
ARG USER_GID=1001
RUN groupadd --gid $USER_GID $USERNAME \
  && useradd --system --uid $USER_UID --gid $USER_GID -s /bin/bash -m $USERNAME \
  && usermod -aG sudo $USERNAME \
  && echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USERNAME

# Do some additional configuration so that:
#  - node runs with a self-signed certificate.
#  - bash has autocmopletion.
#  - bash runs the dash shell in fluxbox.
RUN echo "export NODE_TLS_REJECT_UNAUTHORIZED='0'" >> /home/$USERNAME/.bashrc \
  && echo "" >> /home/$USERNAME/.bashrc \
  && echo "source /usr/share/bash-completion/completions/git" >> /home/$USERNAME/.bashrc \
  && rm /bin/dash \
  && ln -s /bin/bash /bin/dash

USER $USERNAME

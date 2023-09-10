FROM farmdata2/fd2-vnc-novnc-base:1.2.1

USER root
RUN curl -sL https://deb.nodesource.com/setup_18.x -o /tmp/nodesource_setup.sh \
  && bash /tmp/nodesource_setup.sh \
  && apt install nodejs \
  && rm /tmp/nodesource_setup.sh \
  && npm install -g create-vue

# Install extensions into firefox.
# Add: JsonView, Hoppscotch and Vue.JS Devtools
RUN cd /usr/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384} \
  && wget https://addons.mozilla.org/firefox/downloads/file/4115735/jsonview-2.4.2.xpi \
  && mv jsonview-2.4.2.xpi jsonview@brh.numbera.com.xpi \
  && wget https://addons.mozilla.org/firefox/downloads/file/3991522/hoppscotch-0.25.xpi \
  && mv hoppscotch-0.25.xpi postwoman-firefox@postwoman.io.xpi \
  && wget https://addons.mozilla.org/firefox/downloads/file/4059290/vue_js_devtools-6.5.0.xpi \
  && mv vue_js_devtools-6.5.0.xpi {5caff8cc-3d2e-4110-a88a-003cc85b3858}.xpi

# Add environment variable to /etc/profile so that VSCodium
# launches on Windows with WSL without a warning.
ENV DONT_PROMPT_WSL_INSTALL=1

# Install Docker because we use Docker On Docker to allow some scripts
# (e.g. docker/setDB.bash and buildSampleDB.bash) to stop and start 
# containers.
 COPY docker.bash .
 RUN ./docker.bash \
  && rm docker.bash

# Modify the default umask for the sytsem so that when files
# or directories are created the group has RW permisison as
# well as the owner.  That will ensure tha that any new files
# or directories created in the container are writeable on
# a Linux host.
COPY ./umask.bash .
RUN ./umask.bash \
 && rm ./umask.bash

USER fd2dev
WORKDIR /home/fd2dev

# Install some useful VSCodium extensions
RUN codium --install-extension vue.volar \
  && codium --install-extension dbaeumer.vscode-eslint \
  && codium --install-extension esbenp.prettier-vscode \
  && codium --install-extension timonwong.shellcheck

# Add project bin to the path
RUN echo "" >> .bashrc \
  && echo "export PATH=$PATH:~/FarmData2/bin" >> ~/.bashrc

# Augment the .bashrc file so that anytime a terminal is opened in the
# development environemnt it is ensured that the fd2dev user is in the 
# fd2docker group and that fd2grp is the users primary group.  This ensures
# that fd2dev can access the /var/run/docker.sock file for Docker On Docker. 
# And that new files and directories that are created are in the fd2grp group.
COPY --chown=$USERNAME:$USERNAME ./bashrc_addition .
RUN cat ./bashrc_addition >> .bashrc \
  && rm ./bashrc_addition

# startup.bash is run when the container starts.  It sets the ownership and group
# for the FarmData2 repo and the fd2test directories and starts the VNC and noVNC
# servers.
COPY --chown=$USERNAME:$USERNAME --chmod=755 ./startup.bash ./.contconf/startup.bash

# Run the startup.bash script to ensure that file permissions are correct
# and that the VNC and noVNC servers are running.
ENTRYPOINT ./.contconf/startup.bash
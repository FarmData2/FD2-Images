# FarmData2 Images

A collection of tools for building the devcontainer and sidecar docker images used by the FarmData2 development environment.

## Usage:

### Setup

1. Ensure that the FarmData2 Development environment is running in a Codespace.
   - If you will be building multi-architecture images create the codespace as a 4-core machine.
2. Clone this repository into the home directory along side FarmData2
3. Create or use an existing GitHub PAT to access this repository.
4. `export GITHUB_TOKEN=<your PAT>`
5. Follow the relevant directions below.

### Building the Devcontainer Image

The devcontainer image is the main image used in codespaces or in VSCode.  It contains all of the necessary dependencies for setting up the development environment and running the sidecar containers.

1. `cd devcontainer`
2. edit `repo.txt` to update the version number for the image.
3. `./preBuildDevcontainer.bash --build --push`
   - Using `--push` requires logging into dockerhub as `farmdata2` as a project maintainer.
   - Omit `--push` to test the build without pushing.
   - Use with just `--push` to push an already built image.
   - Use `--no-cache` to rebuild without docker cache for image layers.
4. Edit and commit the `.devcontainer/devcontainer.json` file in `FarmData2` to use the new image.

### Building Sidecar Images

The sidecar images provide the services necessary to run farmOS and thus FarmData2.  These include the postgres database, the farmOS server and an nginx reverse proxy to provide access to farmOS via https.

#### Local Builds for Sidecar Images

The following command will build the image described by the `Dockerfile` in `<dir>` for the architecture of the host machine.
```
cd sidecarContainers
./build-images.bash -d <dir>
```

For example, the following command builds the `farmos3` image locally for the architecture of the host machine:
```
./build-images.bash -d farmos3
```

Multiple images can be built with a single command by listing each of their directory names.  For example, the following command builds the farmos3 and the postgres images:
```
./build-images.bash -d farmos3 postgres
```

#### Building and Pushing Multi Architecture Sidecar Images

To build multi architecture images:
* Use `docker login` to log into dockerhub as `farmdata2`.
* Use the commands as above but:
  - omit the `-d` flag.
  - add the `-p` flag.
  
```
cd sidecarContainers
./build-images.bash -p fd2dev
```

Notes:
* Logging in to dockerhub as `farmdata2` requires authentication that is available only to project maintainers.
* To modify the architectures for which images are built edit the `PLATFORMS` variable in the `build-images.bash` script.
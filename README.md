# FarmData2 Images

A collection of tools for building the devcontainer and sidecar docker images used by the FarmData2 development environment.

## Usage:

### Setup

1. Create a new Codespace from this repository (or from your own fork).
2. Follow the relevant directions below.

### Building the Devcontainer Image

The devcontainer image is the main image used in FarmData2 development environment either in a Codespace or in VSCode.  It contains all of the necessary dependencies for setting up the development environment and running the sidecar containers.

1. `cd devcontainer` (Note: Not `.devcontainer`).
2. Edit `repo.txt` in `devcontainer` to update the version number for the image.
3. `docker image ls`
4. `docker image rm ...` 
   - Remove all images to ensure there is sufficent disk space for the build.
   - If disk space issues still arrise use: `docker system prune -a --volumes -f`
5. `./preBuildDevcontainer.bash`
   - Options include:
     - `--debug` (`-d`) - will build just the `amd64` image and will not push to dockerhub.
     - `--amd64` (`-a`) - will build the `amd64` image and push it to dockerhub. This is the default behavior if no option is specified.
     - `--no-cache` (`-n`) - will not use the Docker build cache.
     - `--help` (`-h`) - will display information about all options.
6. Edit and commit the `.devcontainer/devcontainer.json` file in `FarmData2` to use the new image spedified in `repo.txt`.

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
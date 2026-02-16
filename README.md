# FarmData2 Images

A collection of tools for building the docker images used by the FarmData2 development environment.

## Usage:

### Setup

1. Ensure that the FarmData2 Development environment is running in a Codespace.
2. Clone this repository into the home directory along side FarmData2
3. Create or use an existing GitHub PAT to access this repository.
4. `export GITHUB_TOKEN=<your PAT>`
5. Follow the relevant directions below.

### Local Builds for Development of Images

The following command will build the image described by the `Dockerfile` in `<dir>` for the architecture of the host machine.
```
./build-images.bash -d <dir>
```

For example, the following command builds the `farmos2` image locally for the architecture of the host machine:
```
./build-images.bash -d farmos2
```

Multiple images can be built with a single command by listing each of their directory names.  For example, the following command builds the farmos2 and the postgres images:
```
./build-images.bash -d farmos2 postgres
```

### Building and Pushing Multi Architecture Images

To build multi architecture images:
* Use `docker login` to log into dockerhub as `farmdata2`.
* Use the commands as above but:
  - omit the `-d` flag.
  - add the `-p` flag.
  
```
./build-images.bash -p fd2dev
```

Notes:
* Logging in to dockerhub as `farmdata2` requires authentication that is available only to project maintainers.
* To modify the architectures for which images are built edit the `PLATFORMS` variable in the `build-images.bash` script.
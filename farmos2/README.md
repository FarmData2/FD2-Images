# farmOS 2-x Image

The files in this directory are copied from the farmOS project at:
* https://github.com/farmOS/farmOS/tree/2.x/docker

They are duplicated here so that we can build multi architecture images for the FarmData2 project.

The `services.yml` file is included here (and copied into the container) to enable CORS access to the farmOS API for development purposes.  This allows the FarmData2 Vue apps to run in the dev server outside of farmOS while still accessing the API.

In addition, we build and store our own images so that we can upgrade / update in a fully controlled way.
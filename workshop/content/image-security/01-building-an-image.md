Various tools are available to help you run applications in containers. The most well known tool is called `docker`.

In this workshop, we will be not be using `docker`, but will instead be using an application called `podman`.

The `podman` application is an alternative to `docker`. It is able to produce container images compatible with what `docker` produces, as both build [OCI compliant container images](https://www.opencontainers.org/). To build the images `podman` relies on the `buildah` application.

The `podman` application accepts the same sub commands that `docker` accepts. All the `podman` commands you run in this workshop, you can use with `docker` by replacing `podman` with `docker` in the command line. We are using `podman` rather than `docker` as it isn't safe to enable the use of the `docker` daemon within this workshop environment.

To create our first container, change to the `~/greeting-v3` sub directory.

```execute
cd ~/greeting-v3
```

List the files in the directory.

```execute
ls -las
```

The `Dockerfile` defines the details of the base image from which a new container image is to be created, along with the instructions to create it. View the contents of the `Dockerfile` by running:

```execute
cat Dockerfile
```

To build a container image using the instructions in the `Dockerfile` run:

```execute
podman build -t greeting .
```

To run the container image, run:

```execute
podman run --rm greeting
```

Or to run an alternative command, use:

```execute
podman run --rm greeting /goodbye
```

We now have a basic container image, but the issue is whether good security principles are being applied in how this was done. The remainder of this workshop will look at some issues which are often glossed over in guides available on using containers.

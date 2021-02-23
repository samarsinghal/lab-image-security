Various tools are available to help you run applications in containers. The most well known tool is called `docker`, so we will be using it in this workshop.

To create our first container, change to the `~/building-an-image` sub directory.

```execute
clear
cd ~/building-an-image
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
docker build -t greeting .
```

To run the container image, run:

```execute
docker run --rm greeting
```

Or to run an alternative command, use:

```execute
docker run --rm greeting /goodbye
```

We now have a basic container image, but the issue is whether good security principles are being applied in how this was done. The remainder of this workshop will look at some issues which are often glossed over in guides available on using containers.

# Omnia Linux Anvil

This repo houses the Dockerfiles that extend the
[Conda Forge Linux Anvil](https://github.com/conda-forge/docker-images) to support packages in
[Omnia](http://www.omnia.md/). The extended linux anvil includes header files for GPU support from AMD and Nvidia for
compute-based calculations and TeX packages for doc building.

## Image Features and Extensions

* TeXLive 2018
* CUDA 10.1

## Building the Image

This repository is monitored by [Docker Hub](https://hub.docker.com/) and every branch is automatically built
and compiled to be accessed as a [Docker](https://www.docker.com/) container.

Builds can be found [here](https://hub.docker.com/r/jchodera/omnia-linux-anvil/)

## Accessing and this Image

The compiled images will be available to pull from Docker Hub. The image can be accessed with the following command:

`docker pull jchodera/omnia-linux-anvil:texlive18-cuda100`

or

`docker pull omniamd/omnia-linux-anvil:texlive18-cuda100`

In future versions, the `omniamd/omnia-linux-anvil` will be the preferred source, however, they are identical for now as
we plan out the transition.

An example of a this docker image in action can be found on the
[Omnia MD Conda recipes channel](https://github.com/omnia-md/conda-recipes).

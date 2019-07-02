# Omnia Linux Anvil

This repo houses the Dockerfiles that extend the
[Conda Forge Linux Anvil](https://github.com/conda-forge/docker-images) to support packages in
[Omnia](http://www.omnia.md/). The extended linux anvil includes header files for GPU support from AMD and Nvidia for
compute-based calculations and TeX packages for doc building.

## Image Features and Extensions

* TeXLive 2017
* AMD APP SDK 3.0
* CUDA 7.5 through 10.1

## Building the Image

This repository is monitored by [Docker Hub](https://hub.docker.com/) and every branch is automatically built
and compiled to be accessed as a [Docker](https://www.docker.com/) container.

Builds can be found [here](https://hub.docker.com/r/omnia/omnia-linux-anvil/)

## Accessing and this Image

The compiled images will be available to pull from Docker Hub. The image can be accessed with the following command:

`docker pull omnia/omnia-linux-anvil:condaforge-texlive18-cuda75to100`

An example of a this docker image in action can be found on the
[Omnia MD Conda recipes channel](https://github.com/omnia-md/conda-recipes).

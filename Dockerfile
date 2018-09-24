FROM jchodera/omnia-linux-anvil:texlive18

# Install NVIDIA driver
RUN wget -q http://us.download.nvidia.com/XFree86/Linux-x86_64/410.57/NVIDIA-Linux-x86_64-410.57.run && \
    chmod +x NVIDIA-Linux-x86_64-410.57.run && \
    ./NVIDIA-Linux-x86_64-410.57.run --silent --accept-license --no-kernel-module --no-kernel-module-source --no-nvidia-modprobe --no-rpms --no-drm --no-libglx-indirect --no-distro-scripts && \
    rm -f NVIDIA-Linux-x86_64-410.57.run

# Install CUDA 10.0
RUN wget -q https://developer.nvidia.com/compute/cuda/10.0/Prod/local_installers/cuda_10.0.130_410.48_linux && \
    chmod +x cuda_10.0.130_410.48_linux && \
    source /opt/docker/bin/entrypoint_source && \
    ./cuda_10.0.130_410.48_linux --silent --no-opengl-libs --toolkit && \
    rm -f cuda_10.0.130_410.48_linux && \
    rm -rf /usr/local/cuda-10.0/doc && \
    rm -rf /usr/local/cuda-10.0/samples

# Clean up
RUN yum clean -y --quiet expire-cache && \
    yum clean -y --quiet all

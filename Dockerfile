FROM jchodera/omnia-linux-anvil:texlive18

# Install NVIDIA driver
RUN wget -q http://us.download.nvidia.com/XFree86/Linux-x86_64/390.67/NVIDIA-Linux-x86_64-390.67.run && \
    chmod +x NVIDIA-Linux-x86_64-390.67.run && \
    ./NVIDIA-Linux-x86_64-390.67.run --silent --accept-license --no-kernel-module --no-kernel-module-source --no-nvidia-modprobe --no-rpms --no-drm --no-libglx-indirect --no-distro-scripts && \
    rm -f NVIDIA-Linux-x86_64-390.67.run

# Install CUDA 9.2
RUN wget -q https://developer.nvidia.com/compute/cuda/9.2/Prod/local_installers/cuda_9.2.88_396.26_linux && \
    chmod +x cuda_9.2.88_396.26_linux && \
    source /opt/docker/bin/entrypoint_source && \
    ./cuda_9.2.88_396.26_linux --silent --no-opengl-libs --toolkit && \
    rm -f cuda_9.2.88_396.26_linux && \
    rm -rf /usr/local/cuda-9.2/doc && \
    rm -rf /usr/local/cuda-9.2/samples

# Install CUDA 9.2 patch 1
RUN wget -q https://developer.nvidia.com/compute/cuda/9.2/Prod/patches/1/cuda_9.2.88.1_linux && \
    chmod +x cuda_9.2.88.1_linux && \
    source /opt/docker/bin/entrypoint_source && \
    ./cuda_9.2.88.1_linux -s --accept-eula && \
    rm -f cuda_9.2.88.1_linux

# Clean up
RUN yum clean -y --quiet expire-cache && \
    yum clean -y --quiet all

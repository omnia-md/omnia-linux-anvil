FROM jchodera/omnia-linux-anvil:texlive18

# Install NVIDIA driver 390.67
RUN wget -q http://us.download.nvidia.com/XFree86/Linux-x86_64/390.67/NVIDIA-Linux-x86_64-390.67.run && \
    chmod +x NVIDIA-Linux-x86_64-390.67.run && \
    ./NVIDIA-Linux-x86_64-390.67.run --silent --accept-license --no-kernel-module --no-kernel-module-source --no-nvidia-modprobe --no-rpms --no-drm --no-libglx-indirect --no-distro-scripts && \
    rm -f NVIDIA-Linux-x86_64-390.67.run

# install CUDA 9.0
RUN wget -q https://developer.nvidia.com/compute/cuda/9.0/Prod/local_installers/cuda_9.0.176_384.81_linux-run && \
    chmod +x cuda_9.0.176_384.81_linux-run && \
    source /opt/docker/bin/entrypoint_source && \
    ./cuda_9.0.176_384.81_linux-run --silent --no-opengl-libs --toolkit && \
    rm -f cuda_9.0.176_384.81_linux-run && \
    rm -rf /usr/local/cuda-9.0/doc && \
    rm -rf /usr/local/cuda-9.0/samples

# CUDA 9.0 patch 1, patch2
RUN wget -q https://developer.nvidia.com/compute/cuda/9.0/Prod/patches/1/cuda_9.0.176.1_linux-run && \
    chmod +x cuda_9.0.176.1_linux-run && \
    source /opt/docker/bin/entrypoint_source && \
    ./cuda_9.0.176.1_linux-run -s --accept-eula && \
    rm -f cuda_9.0.176.1_linux-run
RUN wget -q https://developer.nvidia.com/compute/cuda/9.0/Prod/patches/2/cuda_9.0.176.2_linux-run && \
    chmod +x cuda_9.0.176.2_linux-run && \
    source /opt/docker/bin/entrypoint_source && \
    ./cuda_9.0.176.2_linux-run -s --accept-eula && \
    rm -f cuda_9.0.176.2_linux-run

# Clean up
RUN yum clean -y --quiet expire-cache && \
    yum clean -y --quiet all

FROM jchodera/omnia-linux-anvil:texlive18

# Install NVIDIA driver 390.67
RUN wget -q http://us.download.nvidia.com/XFree86/Linux-x86_64/390.67/NVIDIA-Linux-x86_64-390.67.run && \
    chmod +x NVIDIA-Linux-x86_64-390.67.run && \
    ./NVIDIA-Linux-x86_64-390.67.run --silent --accept-license --no-kernel-module --no-kernel-module-source --no-nvidia-modprobe --no-rpms --no-drm --no-libglx-indirect --no-distro-scripts && \
    rm -f NVIDIA-Linux-x86_64-390.67.run

# Install CUDA 7.5
RUN wget -q http://developer.download.nvidia.com/compute/cuda/7.5/Prod/local_installers/cuda_7.5.18_linux.run && \
    chmod +x cuda_7.5.18_linux.run && \
    source /opt/docker/bin/entrypoint_source && \
    ./cuda_7.5.18_linux.run --silent --no-opengl-libs --toolkit && \
    rm -f cuda_7.5.18_linux.run && \
    rm -rf /usr/local/cuda-7.5/doc && \
    rm -rf /usr/local/cuda-7.5/samples

# Clean up
RUN yum clean -y --quiet expire-cache && \
    yum clean -y --quiet all

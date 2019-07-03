FROM jchodera/omnia-linux-anvil:texlive18

# Install NVIDIA driver
RUN wget -q http://us.download.nvidia.com/XFree86/Linux-x86_64/430.26/NVIDIA-Linux-x86_64-430.26.run && \
    chmod +x NVIDIA-Linux-x86_64-430.26.run && \
    ./NVIDIA-Linux-x86_64-430.26.run --silent --accept-license --no-kernel-module --no-kernel-module-source --no-nvidia-modprobe --no-rpms --no-drm --no-libglx-indirect --no-distro-scripts && \
    rm -f NVIDIA-Linux-x86_64-430.26.run

# Install CUDA 10.1
RUN wget -q https://developer.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda_10.1.168_418.67_rhel6.run && \
    chmod +x cuda_10.1.168_418.67_rhel6.run && \
    source /opt/docker/bin/entrypoint_source && \
    ./cuda_10.1.168_418.67_rhel6.run --silent --no-opengl-libs --toolkit && \
    rm -f cuda_10.1.168_418.67_rhel6.run && \
    rm -rf /usr/local/cuda-10.1/doc && \
    rm -rf /usr/local/cuda-10.1/samples

# Clean up
RUN yum clean -y --quiet expire-cache && \
    yum clean -y --quiet all

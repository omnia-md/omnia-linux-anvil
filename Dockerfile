FROM jchodera/omnia-linux-anvil:texlive18

# Install CUDA 9.1
RUN wget -q https://developer.nvidia.com/compute/cuda/9.1/Prod/local_installers/cuda_9.1.85_387.26_linux && \
    chmod +x cuda_9.1.85_387.26_linux && \
    source /opt/docker/bin/entrypoint_source && \
    ./cuda_9.1.85_387.26_linux --silent --no-opengl-libs --toolkit && \
    rm -f cuda_9.1.85_387.26_linux && \
    rm -rf /usr/local/cuda-9.1/doc && \
    rm -rf /usr/local/cuda-9.1/samples

# Install CUDA 9.1 patch 1, patch2, patch3
RUN wget -q https://developer.nvidia.com/compute/cuda/9.1/Prod/patches/1/cuda_9.1.85.1_linux && \
    chmod +x cuda_9.1.85.1_linux && \
    source /opt/docker/bin/entrypoint_source && \
    ./cuda_9.1.85.1_linux -s --accept-eula && \
    rm -f cuda_9.1.85.1_linux
RUN wget -q https://developer.nvidia.com/compute/cuda/9.1/Prod/patches/2/cuda_9.1.85.2_linux && \
    chmod +x cuda_9.1.85.2_linux && \
    source /opt/docker/bin/entrypoint_source && \
    ./cuda_9.1.85.2_linux -s --accept-eula && \
    rm -f cuda_9.1.85.2_linux
RUN wget -q https://developer.nvidia.com/compute/cuda/9.1/Prod/patches/3/cuda_9.1.85.3_linux && \
    chmod +x cuda_9.1.85.3_linux && \
    source /opt/docker/bin/entrypoint_source && \
    ./cuda_9.1.85.3_linux -s --accept-eula && \
    rm -f cuda_9.1.85.3_linux

# Clean up
RUN yum clean -y --quiet expire-cache && \
    yum clean -y --quiet all

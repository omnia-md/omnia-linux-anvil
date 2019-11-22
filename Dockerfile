FROM omniamd/omnia-linux-anvil:condaforge-texlive19

#
# Install all the CUDA variants in their minimal Forms
#

# NOTE: This might be more than is needed for OpenMM
# NOTE: Installing by RPM is much smaller than installing it "automatically"
# Caveat: Installing this way causes the lib64 and include directory to be symlinked to
#         targets/x86_64-linux/lib and targets/x86_64-linux/include respectively
#         A full install moves these but we don't need to, UNLESS we install the patch (e.g. the 3 patches for 9.1)

# NOTE: NONE of these install the actual CUDA *DRIVER* as they would conflict with each other
# We instead install 1 driver at the end which is backwards compatible with the various CUDA versions and adds a single
# libcuda.so to /usr/lib64, which is needed by OpenMM to detect CUDA_CUDA_LIBRARY [sic] and different from /usr/local
# installs of the cuda veersions below.
# Unsure if we need the driver or the files in the `cuda-XX.Y/lib64/stubs` folder for each CUDA version

# CUDA 9.1
# Have to unlink the lib64 and include directory for the patches
RUN curl -L https://developer.nvidia.com/compute/cuda/9.1/Prod/local_installers/cuda-repo-rhel6-9-1-local-9.1.85-1.x86_64 > cuda-repo-rhel6-9-1-local-9.1.85-1.x86_64.rpm && \
    rpm --quiet -i cuda-repo-rhel6-9-1-local-9.1.85-1.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-9-1-local/cuda-minimal-build-9-1-9.1.85-1.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-9-1-local/cuda-cufft-dev-9-1-9.1.85-1.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-9-1-local/cuda-driver-dev-9-1-9.1.85-1.x86_64.rpm && \
    rpm --quiet -i --nodeps --nomd5 /var/cuda-repo-9-1-local/cuda-nvrtc-9-1-9.1.85-1.x86_64.rpm && \
    rpm --quiet -i --nodeps --nomd5 /var/cuda-repo-9-1-local/cuda-nvrtc-dev-9-1-9.1.85-1.x86_64.rpm && \
    rpm --quiet -i --nodeps --nomd5 /var/cuda-repo-9-1-local/cuda-runtime-9-1-9.1.85-1.x86_64.rpm && \
    unlink /usr/local/cuda-9.1/include && mv /usr/local/cuda-9.1/targets/*-linux/include /usr/local/cuda-9.1/ && \
    unlink /usr/local/cuda-9.1/lib64 && mv /usr/local/cuda-9.1/targets/*-linux/lib /usr/local/cuda-9.1/lib64 && \
    rm -rf /cuda-repo-rhel6-9-1-local-9.1.85-1.x86_64.rpm /var/cuda-repo-9-1-local/*.rpm /var/cache/yum/cuda-9-1-local/ && \
    yum clean -y --quiet expire-cache && \
    yum clean -y --quiet all
# CUDA 9.1 Patch 1, 2, and 3
# The patches add the cublas libraries to lib64, which are not installed with the base and add to the size (~120MB)
# The 3rd patch also adds libcublas 9.1.181 alongside 9.1.128, changing only symlinks. Adds >50 MB more
# Add these as separate commands since all cleanup is done before, if we reduce sizes after install, we can
# cleanup then
RUN wget -q https://developer.nvidia.com/compute/cuda/9.1/Prod/patches/1/cuda_9.1.85.1_linux && \
    chmod +x cuda_9.1.85.1_linux && \
    ./cuda_9.1.85.1_linux -s --accept-eula && \
    rm -f cuda_9.1.85.1_linux
RUN wget -q https://developer.nvidia.com/compute/cuda/9.1/Prod/patches/2/cuda_9.1.85.2_linux && \
    chmod +x cuda_9.1.85.2_linux && \
    ./cuda_9.1.85.2_linux -s --accept-eula && \
    rm -f cuda_9.1.85.2_linux
RUN wget -q https://developer.nvidia.com/compute/cuda/9.1/Prod/patches/3/cuda_9.1.85.3_linux && \
    chmod +x cuda_9.1.85.3_linux && \
    ./cuda_9.1.85.3_linux -s --accept-eula && \
    rm -f cuda_9.1.85.3_linux

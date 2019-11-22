FROM omniamd/omnia-linux-anvil:condaforge-texlive18

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

# Cuda 9.2
# Have to unlink the lib64 and include directory for the patch
RUN curl -L https://developer.nvidia.com/compute/cuda/9.2/Prod2/local_installers/cuda-repo-rhel6-9-2-local-9.2.148-1.x86_64 > cuda-repo-rhel6-9-2-local-9.2.148-1.x86_64.rpm && \
    rpm --quiet -i cuda-repo-rhel6-9-2-local-9.2.148-1.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-9-2-local/cuda-minimal-build-9-2-9.2.148-1.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-9-2-local/cuda-cufft-dev-9-2-9.2.148-1.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-9-2-local/cuda-driver-dev-9-2-9.2.148-1.x86_64.rpm && \
    rpm --quiet -i --nodeps --nomd5 /var/cuda-repo-9-2-local/cuda-nvrtc-9-2-9.2.148-1.x86_64.rpm && \
    rpm --quiet -i --nodeps --nomd5 /var/cuda-repo-9-2-local/cuda-nvrtc-dev-9-2-9.2.148-1.x86_64.rpm && \
    rpm --quiet -i --nodeps --nomd5 /var/cuda-repo-9-2-local/cuda-runtime-9-2-9.2.148-1.x86_64.rpm && \
    unlink /usr/local/cuda-9.2/include && mv /usr/local/cuda-9.2/targets/*-linux/include /usr/local/cuda-9.2/ && \
    unlink /usr/local/cuda-9.2/lib64 && mv /usr/local/cuda-9.2/targets/*-linux/lib /usr/local/cuda-9.2/lib64 && \
    rm -rf /cuda-repo-rhel6-9-2-local-9.2.148-1.x86_64.rpm /var/cuda-repo-9-2-local/*.rpm /var/cache/yum/cuda-9-2-local/ && \
    yum clean -y --quiet expire-cache && \
    yum clean -y --quiet all
# CUDA 9.2 Patch 1
RUN wget -q https://developer.nvidia.com/compute/cuda/9.2/Prod/patches/1/cuda_9.2.88.1_linux && \
    chmod +x cuda_9.2.88.1_linux && \
    ./cuda_9.2.88.1_linux -s --accept-eula && \
    rm -f cuda_9.2.88.1_linux

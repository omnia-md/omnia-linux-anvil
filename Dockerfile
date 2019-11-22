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

# Cuda 10.1
RUN curl -L https://developer.nvidia.com/compute/cuda/10.1/Prod/local_installers/cuda-repo-rhel6-10-1-local-10.1.168-418.67-1.0-1.x86_64.rpm > cuda-repo-rhel6-10-1-local-10.1.168-418.67-1.0-1.x86_64.rpm && \
    rpm --quiet -i cuda-repo-rhel6-10-1-local-10.1.168-418.67-1.0-1.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-10-1-local-10.1.168-418.67/cuda-minimal-build-10-1-10.1.168-1.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-10-1-local-10.1.168-418.67/cuda-cufft-dev-10-1-10.1.168-1.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-10-1-local-10.1.168-418.67/cuda-driver-dev-10-1-10.1.168-1.x86_64.rpm && \
    rpm --quiet -i --nodeps --nomd5 /var/cuda-repo-10-1-local-10.1.168-418.67/cuda-nvrtc-10-1-10.1.168-1.x86_64.rpm && \
    rpm --quiet -i --nodeps --nomd5 /var/cuda-repo-10-1-local-10.1.168-418.67/cuda-nvrtc-dev-10-1-10.1.168-1.x86_64.rpm && \
    rm -rf /cuda-repo-rhel6-10-1-local-10.1.168-418.67-1.0-1.x86_64.rpm /var/cuda-repo-10-1-local-10.1.168-418.67/*.rpm /var/cache/yum/cuda-repo-10-1-local-10.1.168-418.67/ && \
    yum clean -y --quiet expire-cache && \
    yum clean -y --quiet all
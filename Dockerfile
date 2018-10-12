FROM omnia-linux-anvil:cf-texlive18

#
# Install all the CUDA variants in their minimal Forms
#

# NOTE: This might be more than is needed for OpenMM
# NOTE: Installing by RPM is much smaller than installing it "automatically"

# CUDA 7.5
RUN curl -L http://developer.download.nvidia.com/compute/cuda/7.5/Prod/local_installers/cuda-repo-rhel6-7-5-local-7.5-18.x86_64.rpm > cuda-repo-rhel6-7-5-local-7.5-18.x86_64.rpm && \
    rpm --quiet -i cuda-repo-rhel6-7-5-local-7.5-18.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-7-5-local/cuda-minimal-build-7-5-7.5-18.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-7-5-local/cuda-cufft-dev-7-5-7.5-18.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-7-5-local/cuda-driver-dev-7-5-7.5-18.x86_64.rpm && \
    rpm --quiet -i --nodeps --nomd5 /var/cuda-repo-7-5-local/xorg-x11-drv-nvidia-libs-352.39-1.el6.x86_64.rpm && \
    rpm --quiet -i --nodeps --nomd5 /var/cuda-repo-7-5-local/xorg-x11-drv-nvidia-devel-352.39-1.el6.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-7-5-local/cuda-driver-dev-7-5-7.5-18.x86_64.rpm && \
    rm -rf /cuda-repo-rhel6-7-5-local-7.5-18.x86_64.rpm /var/cuda-repo-7-5-local/*.rpm /var/cache/yum/cuda-7-5-local/cal/ && \
    yum clean -y --quiet expire-cache && \
    yum clean -y --quiet all

# CUDA 8.0
# Install minimal CUDA components (this may be more than needed)
RUN curl -L https://developer.nvidia.com/compute/cuda/8.0/prod/local_installers/cuda-repo-rhel6-8-0-local-8.0.44-1.x86_64-rpm > cuda-repo-rhel6-8-0-local-8.0.44-1.x86_64.rpm && \
    rpm --quiet -i cuda-repo-rhel6-8-0-local-8.0.44-1.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-8-0-local/cuda-minimal-build-8-0-8.0.44-1.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-8-0-local/cuda-cufft-dev-8-0-8.0.44-1.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-8-0-local/cuda-driver-dev-8-0-8.0.44-1.x86_64.rpm && \
    rpm --quiet -i --nodeps --nomd5 /var/cuda-repo-8-0-local/xorg-x11-drv-nvidia-libs-367.48-1.el6.x86_64.rpm && \
    rpm --quiet -i --nodeps --nomd5 /var/cuda-repo-8-0-local/xorg-x11-drv-nvidia-devel-367.48-1.el6.x86_64.rpm && \
    rpm --quiet -i --nodeps --nomd5 /var/cuda-repo-8-0-local/cuda-nvrtc-8-0-8.0.44-1.x86_64.rpm && \
    rpm --quiet -i --nodeps --nomd5 /var/cuda-repo-8-0-local/cuda-nvrtc-dev-8-0-8.0.44-1.x86_64.rpm && \
    rpm --quiet -i --nodeps --nomd5 /var/cuda-repo-8-0-local/cuda-runtime-8-0-8.0.44-1.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-8-0-local/cuda-driver-dev-8-0-8.0.44-1.x86_64.rpm && \
    rm -rf /cuda-repo-rhel6-8-0-local-8.0.44-1.x86_64.rpm /var/cuda-repo-8-0-local/*.rpm /var/cache/yum/cuda-8-0-local/ && \
    yum clean -y --quiet expire-cache && \
    yum clean -y --quiet all
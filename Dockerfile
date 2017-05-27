FROM jchodera/omnia-linux-anvil:texlive-amd30-cuda80

# Install minimal CUDA 7.5 components (this may be more than needed)
ADD http://developer.download.nvidia.com/compute/cuda/7.5/Prod/local_installers/cuda-repo-rhel6-7-5-local-7.5-18.x86_64.rpm .
RUN rpm --quiet -i cuda-repo-rhel6-7-5-local-7.5-18.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-7-5-local/cuda-minimal-build-7-5-7.5-18.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-7-5-local/cuda-cufft-dev-7-5-7.5-18.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-7-5-local/cuda-driver-dev-7-5-7.5-18.x86_64.rpm && \
    rpm --quiet -i --nodeps --nomd5 /var/cuda-repo-7-5-local/xorg-x11-drv-nvidia-libs-352.39-1.el6.x86_64.rpm && \
    rpm --quiet -i --nodeps --nomd5 /var/cuda-repo-7-5-local/xorg-x11-drv-nvidia-devel-352.39-1.el6.x86_64.rpm && \
    yum --nogpgcheck localinstall -y --quiet /var/cuda-repo-7-5-local/cuda-driver-dev-7-5-7.5-18.x86_64.rpm && \
    rm -rf /cuda-repo-rhel6-7-5-local-7.5-18.x86_64.rpm /var/cuda-repo-7-5-local/*.rpm /var/cache/yum/cuda-7-5-local/cal/

RUN yum clean -y --quiet expire-cache && \
    yum clean -y --quiet all

FROM condaforge/linux-anvil

# Install TeXLive, AMD APP SDK 3.0, and NVIDIA CUDA 9.1 for building OpenMM and Omnia projects

#
# Install EPEL and extra packages
#

# CUDA requires dkms libvdpau
# TeX installation requires wget and perl
# The other TeX packages installed with `tlmgr install` are required for OpenMM's sphinx docs
# libXext libSM libXrender are required for matplotlib to work

# Download and install EPEL, install extra packages for TeX, AMD, and CUDA, cleanup yum
RUN curl -L http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm --output epel-release-6-8.noarch.rpm && \
    rpm -i --quiet epel-release-6-8.noarch.rpm && \
    rm -rf epel-release-6-8.noarch.rpm && \
    yum install -y --quiet perl dkms libvdpau git wget libXext libSM libXrender groff && \
    yum clean -y --quiet expire-cache && \
    yum clean -y --quiet all

#
# Install TeXLive 2017
#

# Add config file from repo
#ADD texlive.profile .
# Download, untar, install, remove install files, install additional packages, make symlinks for all users
#RUN curl -L http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz --output install-tl-unx.tar.gz && \
#    tar -xzf install-tl-unx.tar.gz && \
#    cd install-tl-* &&  ./install-tl -profile /texlive.profile && cd - && \
#    rm -rf install-tl-unx.tar.gz install-tl-* texlive.profile && \
#    /usr/local/texlive/2017/bin/x86_64-linux/tlmgr install \
#          cmap fancybox titlesec framed fancyvrb threeparttable \
#          mdwtools wrapfig parskip upquote float multirow hyphenat caption \
#          xstring fncychap tabulary capt-of eqparbox environ trimspaces && \
#    ln -s /usr/local/texlive/2017/bin/x86_64-linux/* /usr/local/sbin/
#ENV PATH=/usr/local/texlive/2017/bin/x86_64-linux:$PATH


#
# Install AMD APP SDK 3.0
#


# Download, untar, install AMD APP SDK, remove tarball, install script, and samples
RUN curl -L http://debian.nullivex.com/amd/AMD-APP-SDKInstaller-v3.0.130.136-GA-linux64.tar.bz2 > AMD-APP-SDKInstaller-v3.0.130.136-GA-linux64.tar.bz2 && \
    tar xjf AMD-APP-SDKInstaller-v3.0.130.136-GA-linux64.tar.bz2 && \
    ./AMD-APP-SDK-v3.0.130.136-GA-linux64.sh -- -s -a yes && \
    rm -f AMD-APP-SDK-v3.0.130.136-GA-linux64.sh AMD-APP-SDKInstaller-v3.0.130.136-GA-linux64.tar.bz2 && \
    rm -rf /opt/AMDAPPSDK-3.0/samples/
ENV OPENCL_HOME=/opt/AMDAPPSDK-3.0 OPENCL_LIBPATH=/opt/AMDAPPSDK-3.0/lib/x86_64

#
# Install CUDA
#

# install CUDA 8.0 in the same container
RUN wget -q https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda_8.0.61_375.26_linux-run && \
    chmod +x cuda_8.0.61_375.26_linux-run && \
    source /opt/docker/bin/entrypoint_source && \
    ./cuda_8.0.61_375.26_linux-run --silent --no-opengl-libs --toolkit && \
    rm -f cuda_8.0.61_375.26_linux-run

# install CUDA 9.0 in the same container
RUN wget -q https://developer.nvidia.com/compute/cuda/9.0/Prod/local_installers/cuda_9.0.176_384.81_linux-run && \
    chmod +x cuda_9.0.176_384.81_linux-run && \
    source /opt/docker/bin/entrypoint_source && \
    ./cuda_9.0.176_384.81_linux-run --silent --no-opengl-libs --toolkit && \
    rm -f cuda_9.0.176_384.81_linux-run

# patch 1, patch2
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

# install CUDA 9.1 in the same container
RUN wget -q https://developer.nvidia.com/compute/cuda/9.1/Prod/local_installers/cuda_9.1.85_387.26_linux && \
    chmod +x cuda_9.1.85_387.26_linux && \
    source /opt/docker/bin/entrypoint_source && \
    ./cuda_9.1.85_387.26_linux --silent --no-opengl-libs --toolkit && \
    rm -f cuda_9.1.85_387.26_linux

# patch 1, patch2, patch3
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

# install CUDA 9.2 in the same container
RUN wget -q https://developer.nvidia.com/compute/cuda/9.2/Prod/local_installers/cuda_9.2.88_396.26_linux && \
    chmod +x cuda_9.2.88_396.26_linux && \
    source /opt/docker/bin/entrypoint_source && \
    ./cuda_9.2.88_396.26_linux --silent --no-opengl-libs --toolkit && \
    rm -f cuda_9.2.88_396.26_linux

# Clean up
RUN yum clean -y --quiet expire-cache && \
    yum clean -y --quiet all

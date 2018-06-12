FROM condaforge/linux-anvil

# Install TeXLive, AMD APP SDK 3.0, and NVIDIA CUDA 9.1 for building OpenMM and Omnia projects

#
# Install EPEL and extra packages
#

# CUDA requires dkms libvdpau
# TeX installation requires wget and perl
# The other TeX packages installed with `tlmgr install` are required for OpenMM's sphinx doc
# libXext libSM libXrender are required for matplotlib to work

# Download and install EPEL, install extra packages for TeX, AMD, and CUDA, cleanup yum
RUN curl -L http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm --output epel-release-6-8.noarch.rpm && \
    rpm -i --quiet epel-release-6-8.noarch.rpm && \
    rm -rf epel-release-6-8.noarch.rpm && \
    yum install -y --quiet perl dkms libvdpau git wget libXext libSM libXrender groff && \
    yum clean -y --quiet expire-cache && \
    yum clean -y --quiet all

#
# Install GLIBC 2.14 for TeXLive 2018 which needs full C++11 to run

RUN curl -L https://ftp.gnu.org/gnu/libc/glibc-2.14.tar.gz --output glibc-2.14.tar.gz && \
    tar -zxf glibc-2.14.tar.gz && \
    cd glibc-2.14 && \
    mkdir build && \
    cd build && \
    source /opt/docker/bin/entrypoint_source && \
    ../configure --prefix=/opt/glibc-2.14 && \
    make -s && make -s install && \
    cd / && rm -rf glibc*

#
# Install TeXLive 2018
#

# Add config file from repo
ADD texlive.profile .
# Download, untar, install, remove install files, install additional packages, make symlinks for all users
RUN export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/glibc-2.14/lib && \
    curl -L http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz --output install-tl-unx.tar.gz && \
    tar -xzf install-tl-unx.tar.gz && \
    cd install-tl-* && ./install-tl -profile /texlive.profile && cd - && \
    rm -rf install-tl-unx.tar.gz install-tl-* texlive.profile && \
    /usr/local/texlive/2018/bin/x86_64-linux/tlmgr install \
          cmap fancybox titlesec framed fancyvrb threeparttable \
          mdwtools wrapfig parskip upquote float multirow hyphenat caption \
          xstring fncychap tabulary capt-of eqparbox environ trimspaces && \
    ln -s /usr/local/texlive/2018/bin/x86_64-linux/* /usr/local/sbin/
ENV PATH=/usr/local/texlive/2018/bin/x86_64-linux:$PATH

#
# Install CUDA
#

# install CUDA 7.5

RUN wget -q http://developer.download.nvidia.com/compute/cuda/7.5/Prod/local_installers/cuda_7.5.18_linux.run && \
    chmod +x cuda_7.5.18_linux.run && \
    source /opt/docker/bin/entrypoint_source && \
    ./cuda_7.5.18_linux.run --silent --no-opengl-libs --toolkit && \
    rm -f cuda_7.5.18_linux.run && \
    rm -rf /usr/local/cuda-7.5/doc && \
    rm -rf /usr/local/cuda-7.5/samples

# install CUDA 8.0
RUN wget -q https://developer.nvidia.com/compute/cuda/8.0/Prod2/local_installers/cuda_8.0.61_375.26_linux-run && \
    chmod +x cuda_8.0.61_375.26_linux-run && \
    source /opt/docker/bin/entrypoint_source && \
    ./cuda_8.0.61_375.26_linux-run --silent --no-opengl-libs --toolkit && \
    rm -f cuda_8.0.61_375.26_linux-run && \
    rm -rf /usr/local/cuda-8.0/doc && \
    rm -rf /usr/local/cuda-8.0/samples

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

# install CUDA 9.1
RUN wget -q https://developer.nvidia.com/compute/cuda/9.1/Prod/local_installers/cuda_9.1.85_387.26_linux && \
    chmod +x cuda_9.1.85_387.26_linux && \
    source /opt/docker/bin/entrypoint_source && \
    ./cuda_9.1.85_387.26_linux --silent --no-opengl-libs --toolkit && \
    rm -f cuda_9.1.85_387.26_linux && \
    rm -rf /usr/local/cuda-9.1/doc && \
    rm -rf /usr/local/cuda-9.1/samples

# CUDA 9.1 patch 1, patch2, patch3
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

# install CUDA 9.2
RUN wget -q https://developer.nvidia.com/compute/cuda/9.2/Prod/local_installers/cuda_9.2.88_396.26_linux && \
    chmod +x cuda_9.2.88_396.26_linux && \
    source /opt/docker/bin/entrypoint_source && \
    ./cuda_9.2.88_396.26_linux --silent --no-opengl-libs --toolkit && \
    rm -f cuda_9.2.88_396.26_linux && \
    rm -rf /usr/local/cuda-9.2/doc && \
    rm -rf /usr/local/cuda-9.2/samples

# Clean up
RUN yum clean -y --quiet expire-cache && \
    yum clean -y --quiet all

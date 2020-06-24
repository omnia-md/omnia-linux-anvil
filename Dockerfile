FROM centos:6

MAINTAINER omnia <john.chodera@choderalab.org>

# Set locale and encoding to make things work smoothly
# See http://jaredmarkell.com/docker-and-locales/
#RUN locale-gen en_US.UTF-8 # not present in CentOS 6
RUN localedef -c -i en_US -f UTF-8 en_US.UTF-8
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8  

# Add a file for users to source to activate the `conda`
# environment `root` and the devtoolset compiler. Also
# add a file that wraps that for use with the `ENTRYPOINT`.
COPY entrypoint_source /opt/docker/bin/entrypoint_source
COPY entrypoint /opt/docker/bin/entrypoint

# Add a timestamp for the build. Also, bust the cache.
#ADD https://now.httpbin.org/when/now /opt/docker/etc/timestamp

# Resolves a nasty NOKEY warning that appears when using yum.
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6

# Install basic requirements.
RUN yum update -y && \
    yum install -y \
                   bzip2 \
                   make \
                   patch \
                   sudo \
                   tar \
                   which \
                   libXext-devel \
                   libXrender-devel \
                   libSM-devel \
                   libX11-devel \
                   mesa-libGL-devel && \
    yum clean all

# Install devtoolset 2.
RUN yum update -y && \
    yum install -y \
                   centos-release-scl \
                   yum-utils && \
    yum-config-manager --add-repo http://people.centos.org/tru/devtools-2/devtools-2.repo && \
    yum update -y && \
    yum install -y \
                   devtoolset-2-binutils \
                   devtoolset-2-gcc \
                   devtoolset-2-gcc-gfortran \
                   devtoolset-2-gcc-c++ && \
    yum clean -y --quiet expire-cache && \
    yum clean -y --quiet all


# Install conda

# give sudo permission for conda user to run yum (user creation is postponed
# to the entrypoint, so we can create a user with the same id as the host)
RUN echo 'conda ALL=NOPASSWD: /usr/bin/yum' >> /etc/sudoers

# Install Miniconda with Python 3 and update everything.
# NOTE: This step differs from condaforge/linux-anvil
RUN curl -s -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh > miniconda.sh && \
    sha256sum miniconda.sh | grep bb2e3cedd2e78a8bb6872ab3ab5b1266a90f8c7004a22d8dc2ea5effeb6a439a && \
    bash miniconda.sh -b -p /opt/conda && \
    rm miniconda.sh && \
    export PATH=/opt/conda/bin:$PATH && \
    conda config --set show_channel_urls True && \
    conda config --add channels conda-forge && \
    touch /opt/conda/conda-meta/pinned && \
    conda upgrade --yes conda && \
    conda update --all --yes && \
    conda install --yes --quiet conda-build anaconda-client jinja2 setuptools git && \
    conda build purge-all && \
    #export CONDA_CONDA_INFO=( `conda list conda | grep conda` ) && \
    #echo "conda ${CONDA_CONDA_INFO[1]}" >> /opt/conda/conda-meta/pinned && \
    rm -rf /opt/conda/pkgs/*

# Install conda build and deployment tools
# NOTE: This step differs from condaforge/linux-anvil
RUN export PATH="/opt/conda/bin:${PATH}" && \
    export CONDA_BUILD_INFO=( `conda list conda-build | grep conda-build` ) && \
    echo "conda-build ${CONDA_BUILD_INFO[1]}" >> /opt/conda/conda-meta/pinned && \
    conda build purge-all && \
    rm -rf /opt/conda/pkgs/*

# Install docker tools.
RUN export PATH="/opt/conda/bin:${PATH}" && \
    conda install --yes gosu && \
    export CONDA_GOSU_INFO=( `conda list gosu | grep gosu` ) && \
    echo "gosu ${CONDA_GOSU_INFO[1]}" >> /opt/conda/conda-meta/pinned && \
    conda install --yes tini && \
    export CONDA_TINI_INFO=( `conda list tini | grep tini` ) && \
    echo "tini ${CONDA_TINI_INFO[1]}" >> /opt/conda/conda-meta/pinned && \
    . /opt/conda/bin/activate root && \
    conda build purge-all && \
    rm -rf /opt/conda/pkgs/*

#
# Install TeXLive on top of conda-forge linux-anvil image
#

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
          xstring fncychap tabulary capt-of eqparbox environ trimspaces \
          varwidth latexmk etoolbox framed \
          xcolor fancyvrb float wrapfig parskip upquote \
          capt-of needspace && \          
    ln -s /usr/local/texlive/2018/bin/x86_64-linux/* /usr/local/sbin/
ENV PATH=/usr/local/texlive/2018/bin/x86_64-linux:$PATH

# Show current packages.
RUN export PATH="/opt/conda/bin:${PATH}" && \
    conda list

# Install NVIDIA driver
RUN wget -q http://us.download.nvidia.com/XFree86/Linux-x86_64/390.67/NVIDIA-Linux-x86_64-390.67.run && \
    chmod +x NVIDIA-Linux-x86_64-390.67.run && \
    ./NVIDIA-Linux-x86_64-390.67.run --silent --accept-license --no-kernel-module --no-kernel-module-source --no-nvidia-modprobe --no-rpms --no-drm --no-libglx-indirect --no-distro-scripts && \
    rm -f NVIDIA-Linux-x86_64-390.67.run

# Install CUDA 9.2
RUN wget -q https://developer.nvidia.com/compute/cuda/9.2/Prod/local_installers/cuda_9.2.88_396.26_linux && \
    chmod +x cuda_9.2.88_396.26_linux && \
    source /opt/docker/bin/entrypoint_source && \
    ./cuda_9.2.88_396.26_linux --silent --no-opengl-libs --toolkit && \
    rm -f cuda_9.2.88_396.26_linux && \
    rm -rf /usr/local/cuda-9.2/doc && \
    rm -rf /usr/local/cuda-9.2/samples

# Install CUDA 9.2 patch 1
RUN wget -q https://developer.nvidia.com/compute/cuda/9.2/Prod/patches/1/cuda_9.2.88.1_linux && \
    chmod +x cuda_9.2.88.1_linux && \
    source /opt/docker/bin/entrypoint_source && \
    ./cuda_9.2.88.1_linux -s --accept-eula && \
    rm -f cuda_9.2.88.1_linux


# Ensure that all containers start with tini and the user selected process.
# Activate the `conda` environment `root` and the devtoolset compiler.
# Provide a default command (`bash`), which will start if the user doesn't specify one.
ENTRYPOINT [ "/opt/conda/bin/tini", "--", "/opt/docker/bin/entrypoint" ]
CMD [ "/bin/bash" ]

# Clean up
RUN yum clean -y --quiet expire-cache && \
    yum clean -y --quiet all



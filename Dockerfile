FROM condaforge/linux-anvil

# EPEL adds additional packages not in the main centos repositories
# dkms and libvdpau are here (see below)
ADD https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm . 
RUN rpm --quiet -i epel-release-latest-6.noarch.rpm && \
    rm -rf epel-release-latest-6.noarch.rpm

# Linux standard base (LSB) required for AMD APP SDK install
# wget (optionally??) required for AMD APP SDK install
# dkms libvdpau required for CUDA install
# kernel headers needed for CUDA
# xs and cmake for building clang
RUN yum install -y --quiet redhat-lsb wget \
    dkms libvdpau kernel-devel-$(uname -r) kernel-headers-$(uname -r) \
    xz cmake

# Install Clang 3.8.1
ADD http://llvm.org/releases/3.8.1/llvm-3.8.1.src.tar.xz /tmp
RUN xzcat /tmp/llvm-3.8.1.src.tar.xz | tar xf -
ADD http://llvm.org/releases/3.8.1/cfe-3.8.1.src.tar.xz /tmp
RUN xzcat /tmp/cfe-3.8.1.src.tar.xz | tar xf - && mv cfe-3.8.1.src llvm-3.8.1.src/tools/clang
RUN source /opt/rh/devtoolset-2/enable && \
    source /opt/conda/bin/activate root && \
    mkdir llvm-build && cd llvm-build && \
    CC=gcc CXX=g++ cmake ../llvm-3.8.1.src/ \
        -DCMAKE_INSTALL_PREFIX=/opt/clang \
        -DCMAKE_BUILD_TYPE=Release \
        -DLLVM_TARGETS_TO_BUILD=X86 \
        -DGCC_INSTALL_PREFIX=/opt/rh/devtoolset-2/root/usr/ \
        && \
    NCORES=$(grep -c '^processor' /proc/cpuinfo) && \
    make -j $NCORES && \
    make install/strip
RUN rm -rf /llvm-3.8.1.src /tmp/llvm-3.8.1.src.tar.xz /tmp/cfe-3.8.1.src.tar.xz /llvm-build

# Install AMD APP SDK
ADD http://s3.amazonaws.com/omnia-ci/AMD-APP-SDKInstaller-v3.0.130.135-GA-linux64.tar.bz2 .
RUN tar xjf AMD-APP-SDKInstaller-v3.0.130.135-GA-linux64.tar.bz2 && \
    ./AMD-APP-SDK-v3.0.130.135-GA-linux64.sh -- -s -a yes && \
    rm -f AMD-APP-SDK-v3.0.130.135-GA-linux64.sh AMD-APP-SDKInstaller-v3.0.130.135-GA-linux64.tar.bz2 && \
    rm -rf /opt/AMDAPPSDK-3.0/samples/
ENV OPENCL_HOME=/opt/AMDAPPSDK-3.0 OPENCL_LIBPATH=/opt/AMDAPPSDK-3.0/lib/x86_64

# Install CUDA
ADD https://developer.nvidia.com/compute/cuda/8.0/prod/local_installers/cuda-repo-rhel6-8-0-local-8.0.44-1.x86_64-rpm .
RUN rpm --quiet -i cuda-repo-rhel6-8-0-local-8.0.44-1.x86_64-rpm && \
    rm -rf cuda-repo-rhel6-8-0-local-8.0.44-1.x86_64-rpm && \
    yum clean -y --quiet expire-cache && \
    yum install -y --quiet cuda

# Install texlive
ADD http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz .
ADD texlive.profile .
RUN tar -xzf install-tl-unx.tar.gz && \
    cd install-tl-* &&  ./install-tl -profile /texlive.profile && cd - && \
    rm -rf install-tl-unx.tar.gz install-tl-* texlive.profile && \
    /usr/local/texlive/2015/bin/x86_64-linux/tlmgr install \
        cmap fancybox titlesec framed fancyvrb threeparttable \
        mdwtools wrapfig parskip upquote float multirow hyphenat caption \
        xstring
ENV PATH=/usr/local/texlive/2016/bin/x86_64-linux:$PATH


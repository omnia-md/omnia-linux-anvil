FROM condaforge/linux-anvil

# Install TeXLive 2018 for Omnia Projects

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
    CC=/opt/rh/devtoolset-2/root/usr/bin/gcc ../configure --prefix=/opt/glibc-2.14 && \
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

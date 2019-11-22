FROM condaforge/linux-anvil-comp7

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
#
# The localedata and localedef lines are there for the following conditions:
#  1. Conda Forge sets en_US.UTF-8 as LANG in its env
#  2. Adding the new GLIBC to LD_LIBRARY_PATH causes Perl to try and use it
#  3. The Locales are not built by default with a GLIBC
#  4. Perl then complains because the UTF-8 Locale is not compiled
#  5. Running localedef uses the system one, and there does not appear to be a way to change the new one's pointer
#  6. Finding the exact combination of commands to get the new localedef to work required digging through the Makefile
#  7. These 2 commands create the pre-requisite folder to drop the locale file, and then compile ONLY en_US.UTF-8
#  8. Using the built in Makefile commands installs all of the locales, which is >100MB
#  9. locale-gen does not exist on CentOS 6
# 10. Debugging this was a pain, especially since if you unset LANG, the errors go away (but may cause texlive to segfault later)

RUN curl -L https://ftp.gnu.org/gnu/libc/glibc-2.14.tar.gz --output glibc-2.14.tar.gz && \
    tar -zxf glibc-2.14.tar.gz && \
    cd glibc-2.14 && \
    mkdir build && \
    cd build && \
    CC=/opt/rh/devtoolset-2/root/usr/bin/gcc ../configure --prefix=/opt/glibc-2.14 && \
    make -s && make -s install && \
    make localedata/install-locales-dir && \
    locale/localedef --alias-file=../intl/locale.alias -i ../localedata/locales/en_US -c -f ../localedata/charmaps/UTF-8 en_US.UTF-8 && \
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
          xstring fncychap tabulary capt-of eqparbox environ trimspaces varwidth latexmk \
          etoolbox framed xcolor fancyvrb float wrapfig parskip upquote \
          capt-of needspace && \
    ln -s /usr/local/texlive/2018/bin/x86_64-linux/* /usr/local/sbin/
ENV PATH=/usr/local/texlive/2018/bin/x86_64-linux:$PATH

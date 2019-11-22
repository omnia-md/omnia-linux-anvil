FROM omniamd/omnia-linux-anvil:condaforge-texlive19-cuda80-NoDrive

# Finally, install *a* NVIDIA driver, use the "long lived branch"  one
# https://www.nvidia.com/object/unix.html
RUN wget -q http://us.download.nvidia.com/XFree86/Linux-x86_64/440.36/NVIDIA-Linux-x86_64-440.36.run && \
    chmod +x NVIDIA-Linux-x86_64-440.36.run && \
    ./NVIDIA-Linux-x86_64-440.36.run --silent --accept-license --no-kernel-module --no-kernel-module-source --no-nvidia-modprobe --no-rpms --no-drm --no-libglx-indirect --no-distro-scripts && \
    rm -f NVIDIA-Linux-x86_64-440.36.run

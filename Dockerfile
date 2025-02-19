FROM ubuntu:24.04

# Environment variables.
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Packages to install.
ARG PKGS="\
apt-transport-https \
binfmt-support \
build-essential \
ca-certificates \
fdisk \
qemu-system \
qemu-user-static \
sudo \
unzip \
vim \
wget \
xz-utils \
zsh \
"

# Apt update, install.
RUN apt update \
    && apt install --no-install-recommends -y ${PKGS} \
    && apt upgrade -y \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user.
RUN useradd -m -s /bin/bash souschef \
    && echo "souschef ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/souschef \
    && chmod 0440 /etc/sudoers.d/souschef

# Switch to the non-root user.
USER souschef
WORKDIR /home/souschef

ENTRYPOINT [ "/bin/bash" ]

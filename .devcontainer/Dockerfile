FROM public.ecr.aws/lts/ubuntu:jammy

# Packages to install
ARG PKGS="\
build-essential \
ca-certificates \
git \
openssh-client \
qemu-system \
qemu-user-static \
sudo \
unzip \
vim \
wget \
xz-utils \
zsh \
"

# Apt update, install
RUN apt update && \
    apt install --no-install-recommends -y ${PKGS} && \
    apt upgrade -y

# Install Packer (depends on `wget` and `unzip`).
ENV PACKER_VERSION=1.12.0
ENV PACKER_LOG=1
ENV PACKER_CACHE_DIR="/build/.packer_cache"
RUN if [ "$(uname -m)" = "aarch64" ]; then PACKER_ARCH="arm64"; else PACKER_ARCH="amd64"; fi && \
    wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_${PACKER_ARCH}.zip -q -O /tmp/packer.zip && \
    unzip /tmp/packer.zip -d /bin && \
    chmod +x /bin/packer && \
    rm /tmp/packer.zip

# # Apt cleanup
# RUN apt autoremove --purge -y && \
#     find /opt /usr/lib -name __pycache__ -print0 | xargs --null rm -rf && \
#     rm -rf /var/lib/apt/lists/*

WORKDIR /app

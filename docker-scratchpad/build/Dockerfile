FROM ubuntu:26.04

# Git, Python, and generic CLI tooling.
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    dnsmasq \
    docker.io \
    git \
    gnupg \
    hostname \
    iproute2 \
    iptables \
    jq \
    less \
    lsb-release \
    openssh-client \
    procps \
    python3 \
    python3-pip \
    python3-venv \
    sudo \
    unzip \
  && rm -rf /var/lib/apt/lists/*

# Basic networking tools.
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    dnsutils \
    iputils-ping \
    net-tools \
    netcat-openbsd \
    traceroute \
    wget \
  && rm -rf /var/lib/apt/lists/*

# Replace the stock `ubuntu` user with a `coder` user on UID 1000 so the
# mounted home volume has the right ownership. Passwordless sudo lets the
# agent start the Docker daemon and manage system services.
RUN userdel -r ubuntu 2>/dev/null || true \
  && useradd -m -d /home/coder -s /bin/bash -u 1000 coder \
  && usermod -aG docker coder \
  && echo "coder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/coder \
  && chmod 440 /etc/sudoers.d/coder

USER coder
WORKDIR /home/coder
ENV HOME=/home/coder

# Stage 1: Base image with apt packages
FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbullseye-8446af38-ls104 AS base

ENV TITLE=MetaTrader
ENV WINEARCH=win64
ENV WINEPREFIX="/config/.wine"
ENV DISPLAY=:0

# Ensure the directory exists with correct permissions
RUN mkdir -p /config/.wine /config/.cache && \
    chown -R abc:abc /config && \
    chmod -R 755 /config

# Update package lists and upgrade packages
RUN apt-get update && apt-get upgrade -y

# Install required packages
RUN apt-get install -y \
    dos2unix \
    python3-pip \
    wget \
    python3-pyxdg \
    netcat \
    xvfb && \
    pip3 install --upgrade pip

# Add WineHQ repository key and APT source
RUN wget -q https://dl.winehq.org/wine-builds/winehq.key && \
    apt-key add winehq.key && \
    add-apt-repository 'deb https://dl.winehq.org/wine-builds/debian/ bullseye main' && \
    rm winehq.key

# Add i386 architecture and update package lists
RUN dpkg --add-architecture i386 && apt-get update

# Install WineHQ stable package and dependencies
RUN apt-get install --install-recommends -y \
    winehq-stable \
    winetricks && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Stage 2: Final image
FROM base

WORKDIR /app

# Copy the scripts directory and convert to Unix format
COPY scripts /scripts
RUN dos2unix /scripts/*.sh && chmod +x /scripts/*.sh

# Copy root filesystem
COPY /root /

# Ensure abc user has proper shell for su
RUN chsh -s /bin/bash abc

# ⚠️ Removed /var/log/mt5_setup.log block to avoid permission issues

# Pre-download VC++ redistributable (optional but useful for speed)
RUN mkdir -p /config/.cache/winetricks/vcrun2015 && \
    wget -q -O /config/.cache/winetricks/vcrun2015/vc_redist.x86.exe \
    https://aka.ms/vs/17/release/vc_redist.x86.exe && \
    chown -R abc:abc /config/.cache

# Custom init script to bootstrap MT5
RUN mkdir -p /custom-cont-init.d && \
    cat > /custom-cont-init.d/99-mt5-init.sh << 'EOF'
#!/bin/bash
set -e

echo "Starting MT5 initialization..."

# Ensure Wine directory exists
if [ ! -d "/config/.wine" ]; then
    echo "Creating Wine directory..."
    mkdir -p /config/.wine /config/.cache
    chown -R abc:abc /config
    chmod -R 755 /config
fi

# Start the MT5 setup script as abc user
su - abc -c "/scripts/01-start.sh" &

echo "MT5 initialization started"
EOF

RUN chmod +x /custom-cont-init.d/99-mt5-init.sh

EXPOSE 3000 5001
VOLUME /config

CMD ["su", "-", "abc", "-c", "/scripts/07-start-wine-flask.sh"]
FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbullseye

# Set environment variables
ENV TITLE=MetaTrader
ENV WINEARCH=win64
ENV WINEPREFIX="/config/.wine"
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8

# Enable 32-bit architecture for Wine
RUN dpkg --add-architecture i386

# Install dependencies
RUN apt-get update && apt-get install -y     software-properties-common     wget     curl     gnupg2     dos2unix     python3-pip     python3-pyxdg     netcat     xvfb     locales     && locale-gen en_US.UTF-8

# Add Wine repository using the new method (avoiding deprecated apt-key)
RUN wget -nc -O /usr/share/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key &&     echo "deb [signed-by=/usr/share/keyrings/winehq-archive.key] https://dl.winehq.org/wine-builds/debian/ bullseye main" > /etc/apt/sources.list.d/winehq.list &&     apt-get update &&     apt-get install -y --install-recommends winehq-stable winetricks &&     apt-get clean &&     rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip3 install --upgrade pip

# Create directories with proper permissions (do this ONCE)
RUN mkdir -p /config /config/.wine /config/.cache/winetricks/vcrun2015 /scripts &&     chown -R abc:abc /config &&     chmod -R 755 /config

# Copy scripts and fix line endings
COPY scripts /scripts
RUN dos2unix /scripts/*.sh && chmod +x /scripts/*.sh

# Copy root filesystem
COPY /root /

# Pre-download VC++ redistributable (but don't install at build time)
RUN wget -q -O /tmp/vc_redist.x86.exe https://aka.ms/vs/17/release/vc_redist.x86.exe &&     mkdir -p /config/.cache/winetricks/vcrun2015 &&     mv /tmp/vc_redist.x86.exe /config/.cache/winetricks/vcrun2015/ &&     chown -R abc:abc /config/.cache

# Create custom init script
RUN mkdir -p /custom-cont-init.d &&     cat > /custom-cont-init.d/99-mt5-init.sh << 'EOF'
#!/bin/bash
set -e

echo "Starting MT5 initialization..."

# Start Xvfb for Wine
Xvfb :99 -screen 0 1024x768x16 &
sleep 2

# Export environment
export DISPLAY=:99
export WINEARCH=win64
export WINEPREFIX=/config/.wine
export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export WINEDLLOVERRIDES="mscoree,mshtml=d"

# Ensure directories exist with correct permissions
mkdir -p /config/.wine /config/.cache
chown -R abc:abc /config

# Initialize Wine prefix as abc user if needed
if [ ! -f "$WINEPREFIX/system.reg" ]; then
    echo "Initializing Wine prefix..."
    su - abc -c "export DISPLAY=:99 && export WINEARCH=win64 && export WINEPREFIX=/config/.wine && export WINEDLLOVERRIDES='mscoree,mshtml=d' && wineboot --init"
    sleep 5
fi

# Start MT5 setup as abc user
echo "Starting MT5 setup script..."
su - abc -c "export DISPLAY=:99 && export WINEARCH=win64 && export WINEPREFIX=/config/.wine && export LC_ALL=C.UTF-8 && export LANG=C.UTF-8 && /scripts/01-start.sh" &

echo "MT5 initialization complete"
EOF

RUN chmod +x /custom-cont-init.d/99-mt5-init.sh

# Set the volume
VOLUME /config

# The entrypoint is inherited from the base image

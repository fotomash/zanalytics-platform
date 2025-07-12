# Stage 1: Base image with apt packages
FROM ghcr.io/linuxserver/baseimage-kasmvnc:debianbullseye-8446af38-ls104 AS base

ENV TITLE=MetaTrader
ENV WINEARCH=win32
ENV WINEPREFIX="/config/.wine"
ENV DISPLAY=:0

# Ensure the directory exists with correct permissions
RUN mkdir -p /config/.wine && \
    chown -R abc:abc /config/.wine && \
    chmod -R 755 /config/.wine

# Update package lists and upgrade packages
RUN apt-get update && apt-get upgrade -y

# Install required packages
RUN apt-get install -y \
    dos2unix \
    python3-pip \
    wget \
    python3-pyxdg \
    netcat \
    && pip3 install --upgrade pip

# Add WineHQ repository key and APT source
RUN wget -q https://dl.winehq.org/wine-builds/winehq.key > /dev/null 2>&1\
    && apt-key add winehq.key \
    && add-apt-repository 'deb https://dl.winehq.org/wine-builds/debian/ bullseye main' \
    && rm winehq.key

# Add i386 architecture and update package lists
RUN dpkg --add-architecture i386 \
    && apt-get update

# Install WineHQ stable package and dependencies
RUN apt-get install --install-recommends -y \
    winehq-stable \
    winetricks \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Ensure abc owns /config, /config/.wine, and /config/.cache after package installs
RUN mkdir -p /config/.wine /config/.cache && \
    chown -R abc:abc /config /config/.wine /config/.cache

# Ensure runtime directory exists for abc (needed for some X apps)
RUN mkdir -p /tmp/runtime-abc && \
    chown abc:abc /tmp/runtime-abc && \
    chmod 700 /tmp/runtime-abc

# Stage 2: Final image
FROM base

# Copy the scripts directory and convert start.sh to Unix format
COPY app /appcheck
COPY scripts /scripts
RUN dos2unix /scripts/*.sh && \
    chmod +x /scripts/*.sh

COPY root/defaults/autostart /etc/xdg/openbox/autostart
COPY root/defaults/menu.xml /etc/xdg/openbox/menu.xml
RUN touch /var/log/mt5_setup.log && \
    chown abc:abc /var/log/mt5_setup.log && \
    chmod 644 /var/log/mt5_setup.log

USER abc

# Fast-fail on bad permissions for /config/.wine (fail container if not writable)
RUN ls -ld /config /config/.wine || true
ENTRYPOINT ["/bin/bash", "-c", "if [ ! -w /config/.wine ]; then echo 'ERROR: /config/.wine is not writable by user abc'; ls -ld /config /config/.wine; exit 1; fi; exec /scripts/01-start.sh"]

EXPOSE 3000 5000 5001 8001 18812
VOLUME /config

FROM kasmweb/core-ubuntu-noble:1.19.0

USER root

# System-Update
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    wget curl git htop neofetch fuse3 libfuse2 \
    nautilus gnome-terminal mousepad gedit eog evince vlc flameshot locales \
    && rm -rf /var/lib/apt/lists/*

# Deutsche Sprache
RUN locale-gen de_DE.UTF-8
ENV LANG=de_DE.UTF-8 LANGUAGE=de_DE:de LC_ALL=de_DE.UTF-8

# Offizielle Kasm-Skripte
COPY ./src/ubuntu/install/firefox/ $INST_SCRIPTS/firefox/
COPY ./src/ubuntu/install/firefox/firefox.desktop $HOME/Desktop/
RUN bash $INST_SCRIPTS/firefox/install_firefox.sh && rm -rf $INST_SCRIPTS/firefox/

COPY ./src/ubuntu/install/thunderbird/ $INST_SCRIPTS/thunderbird/
RUN bash $INST_SCRIPTS/thunderbird/install_thunderbird.sh && rm -rf $INST_SCRIPTS/thunderbird/

COPY ./src/ubuntu/install/nextcloud/ $INST_SCRIPTS/nextcloud/
RUN bash $INST_SCRIPTS/nextcloud/install_nextcloud.sh && rm -rf $INST_SCRIPTS/nextcloud/

COPY ./src/ubuntu/install/signal/ $INST_SCRIPTS/signal/
RUN bash $INST_SCRIPTS/signal/install_signal.sh && rm -rf $INST_SCRIPTS/signal/

COPY ./src/ubuntu/install/chromium/ $INST_SCRIPTS/chromium/
RUN bash $INST_SCRIPTS/chromium/install_chromium.sh && rm -rf $INST_SCRIPTS/chromium/

# Install Obsidian
COPY ./src/ubuntu/install/obsidian $INST_SCRIPTS/obsidian/
RUN bash $INST_SCRIPTS/obsidian/install_obsidian.sh  && rm -rf $INST_SCRIPTS/obsidian/

# Joplin (AppImage)
RUN VERSION=$(curl -s https://api.github.com/repos/laurent22/joplin/releases/latest | grep '"tag_name"' | cut -d '"' -f 4) \
    && wget -qO /tmp/Joplin.AppImage https://github.com/laurent22/joplin/releases/download/${VERSION}/Joplin-${VERSION#v}.AppImage \
    && chmod +x /tmp/Joplin.AppImage && mkdir -p /opt/joplin && cd /opt/joplin \
    && /tmp/Joplin.AppImage --appimage-extract && rm /tmp/Joplin.AppImage \
    && ln -s /opt/joplin/squashfs-root/AppRun /usr/local/bin/joplin

# Claude Desktop (direkte .deb)
RUN curl -fLO "https://downloads.claude.ai/claude-desktop/apt/stable/$(curl -s "https://downloads.claude.ai/claude-desktop/apt/stable/dists/stable/main/binary-$(dpkg --print-architecture)/Packages" | grep '^Filename: pool/main/c/claude-desktop/claude-desktop_' | sort -V | tail -n 1 | cut -d' ' -f2)" \
    && apt-get install -y ./claude-desktop_*.deb \
    && rm claude-desktop_*.deb

# Desktop Icons
RUN mkdir -p /home/kasm-default-profile/Desktop

RUN chown -R 1000:1000 /home/kasm-default-profile /opt

USER 1000

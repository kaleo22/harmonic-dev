ARG BASE_IMAGE=osrf/ros
ARG BASE_TAG=jazzy-desktop

FROM ${BASE_IMAGE}:${BASE_TAG}

ENV DEBIAN_FRONTEND=noninteractive
ENV GZ_VERSION=harmonic
ARG DISTRO=jazzy

RUN apt-get update

# --- deine ROS/Gazebo Pakete (wie gehabt) ---
RUN apt-get install -y ros-${DISTRO}-plotjuggler
RUN apt-get install -y ros-${DISTRO}-ros-gz
RUN apt-get install -y \
    ros-${DISTRO}-joint-state-publisher \
    ros-${DISTRO}-joint-state-publisher-gui \
    ros-${DISTRO}-gz-ros2-control \
    ros-${DISTRO}-teleop-twist-joy \
    ros-${DISTRO}-teleop-twist-joy \
    ros-${DISTRO}-joy \
    ros-${DISTRO}-pinocchio \
    ros-${DISTRO}-ros2-control \
    ros-${DISTRO}-ros2-controllers \
    ros-${DISTRO}-xacro \
    ros-${DISTRO}-rosbag2-storage-mcap \
    ros-${DISTRO}-plotjuggler-ros \
    chrony \
    tmux \
    python3-pip \
    xterm \
    libeigen3-dev \
    nano \
    ros-${DISTRO}-rviz2 \
    nautilus \
    iputils-ping \
    iproute2 \
    python3-rosdep \
    curl \
    lsb-release \
    gnupg \
    xserver-xorg-core xserver-xorg-video-dummy x11-xserver-utils xauth \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY 10-dummy.conf /etc/X11/xorg.conf.d/10-dummy.conf

RUN apt-get update && apt-get install -y ros-${DISTRO}-rmw-cyclonedds-cpp && apt-get clean

# Gazebo repo key + list (als root ohne sudo)
RUN curl -fsSL https://packages.osrfoundation.org/gazebo.gpg \
    -o /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/gazebo-stable.list

    # VirtualGL Debian Package 
ARG VIRTUALGL_VERSION=3.1.3

RUN set -eux; \
  apt-get update; \
  apt-get install -y --no-install-recommends ca-certificates curl; \
  arch="$(dpkg --print-architecture)"; \
  case "$arch" in \
    amd64) vgl_arch="amd64" ;; \
    arm64) vgl_arch="arm64" ;; \
    *) echo "Unsupported arch: $arch" >&2; exit 1 ;; \
  esac; \
  curl -fsSL -o /tmp/virtualgl.deb \
    "https://github.com/VirtualGL/virtualgl/releases/download/${VIRTUALGL_VERSION}/virtualgl_${VIRTUALGL_VERSION}_${vgl_arch}.deb"; \
  apt-get install -y --no-install-recommends /tmp/virtualgl.deb; \
  rm -f /tmp/virtualgl.deb; \
  rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y gz-harmonic && apt-get clean

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg \
    && rm -rf /var/lib/apt/lists/*

# add TurboVNC packagecloud repo (key + source list)
RUN set -eux; \
    curl -s https://packagecloud.io/install/repositories/dcommander/turbovnc/script.deb.sh?any=true | sudo bash; \
    # echo "deb https://packagecloud.io/dcommander/turbovnc" \
    #   > /etc/apt/sources.list.d/turbovnc.list; \
    apt-get update

# --- NEU: GUI Remote Desktop Pakete ---
# XFCE als leichter Desktop, Xorg als Server, dbus für Desktop-Sitzung
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-terminal dbus-x11 \
    xorg xauth x11-xserver-utils x11-utils \
    mesa-utils \
    net-tools \
    turbovnc=2.2.5-20200507 \
    virtualgl \
    xauth xfonts-base xfonts-100dpi xfonts-75dpi fontconfig \
    && apt-get clean

ENV PATH="/opt/TurboVNC/bin:/opt/VirtualGL/bin:${PATH}"
# Create user (wie bei dir)
ARG USERNAME=ros
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

RUN if id -u ${USER_UID} ; then userdel `id -un ${USER_UID}` ; fi
RUN groupadd --gid ${USER_GID} ${USERNAME}
RUN useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} \
    && apt-get update \
    && apt-get install -y sudo \
    && echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME}

ENV HOME=/home/${USERNAME}
ENV USER=${USERNAME}

# VirtualGL: user in video/render (du machst das eh schon)
RUN usermod -a -G render,video ${USERNAME}

# Startskript rein
COPY start-vnc.sh /usr/local/bin/start-vnc.sh
RUN chmod +x /usr/local/bin/start-vnc.sh

ARG WORKSPACE=docker_simulation_ws
WORKDIR /home/${USERNAME}/${WORKSPACE}

USER ${USERNAME}

RUN echo "source /opt/ros/${DISTRO}/setup.bash" >> ~/.bashrc
RUN echo "if [ -f ~/${WORKSPACE}/install/setup.bash ]; then source ~/${WORKSPACE}/install/setup.bash; fi" >> ~/.bashrc

RUN mkdir -p /usr/share/glvnd/egl_vendor.d && \
    printf '%s\n' \
    '{' \
    '  "file_format_version" : "1.0.0",' \
    '  "ICD" : { "library_path" : "libEGL_nvidia.so.0" }' \
    '}' \
    > /usr/share/glvnd/egl_vendor.d/10_nvidia.json

# --- VNC xstartup: Openbox Session starten ---
# ACHTUNG: Das muss NACHDEM der User "ros" existiert passieren.
# Falls du im Dockerfile später auf USER ros wechselst, kannst du das auch ohne chown machen.
RUN mkdir -p /home/ros/.vnc && \
    printf '%s\n' \
      '#!/bin/sh' \
      'unset SESSION_MANAGER' \
      'unset DBUS_SESSION_BUS_ADDRESS' \
      '' \
      'export XDG_RUNTIME_DIR="/tmp/runtime-'${USERNAME:-ros}'"' \
      'mkdir -p "$XDG_RUNTIME_DIR"' \
      'chmod 700 "$XDG_RUNTIME_DIR"' \
      '' \
      'if command -v dbus-launch >/dev/null 2>&1; then' \
      '  eval "$(dbus-launch --sh-syntax --exit-with-session)"' \
      'fi' \
      '' \
      'xrdb "$HOME/.Xresources" 2>/dev/null || true' \
      '' \
      'exec openbox-session' \
      > /home/ros/.vnc/xstartup && \
    chmod +x /home/ros/.vnc/xstartup && \
    chown -R 1000:1000 /home/ros/.vnc

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash","/usr/local/bin/start-vnc.sh"]

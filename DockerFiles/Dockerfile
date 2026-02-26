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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y ros-${DISTRO}-rmw-cyclonedds-cpp && apt-get clean

# Gazebo repo key + list (als root ohne sudo)
RUN curl -fsSL https://packages.osrfoundation.org/gazebo.gpg \
    -o /usr/share/keyrings/pkgs-osrf-archive-keyring.gpg

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/pkgs-osrf-archive-keyring.gpg] http://packages.osrfoundation.org/gazebo/ubuntu-stable $(lsb_release -cs) main" \
    > /etc/apt/sources.list.d/gazebo-stable.list

RUN apt-get update && apt-get install -y gz-harmonic && apt-get clean

# --- NEU: GUI Remote Desktop Pakete ---
# XFCE als leichter Desktop, Xorg als Server, dbus für Desktop-Sitzung
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-terminal dbus-x11 \
    xorg xauth x11-xserver-utils x11-utils \
    mesa-utils \
    turbovnc virtualgl \
    net-tools \
    && apt-get clean

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

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["/usr/local/bin/start-vnc.sh"]

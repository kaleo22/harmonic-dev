#!/bin/bash
DISTRO=jazzy
BASE_IMAGE=osrf/ros
BASE_TAG=$DISTRO-desktop
IMAGE_NAME=docker_control_simulation
IMAGE_TAG=0.1

# NEU (optional):
ENABLE_GUI=1          # 1 = VNC/VirtualGL installieren, 0 = headless
ENABLE_NOVNC=0        # 1 = noVNC (Browser), 0 = nur nativer VNC-Client

USERNAME=ros
USER_UID="$(id -u $USER)"
USER_GID="$(id -g $USER)"
WORKSPACE=docker_simulation_ws

docker compose build \
  --build-arg BASE_IMAGE=$BASE_IMAGE \
  --build-arg BASE_TAG=$BASE_TAG \
  --build-arg IMAGE_NAME=$IMAGE_NAME \
  --build-arg IMAGE_TAG=$IMAGE_TAG \
  --build-arg USERNAME=$USERNAME \
  --build-arg USER_UID=$USER_UID \
  --build-arg USER_GID=$USER_GID \
  --build-arg WORKSPACE=$WORKSPACE \
  --build-arg DISTRO=$DISTRO \
  --build-arg ENABLE_GUI=$ENABLE_GUI \
  --build-arg ENABLE_NOVNC=$ENABLE_NOVNC
#!/bin/sh
set -eu

# 1) Ensure X socket dir exists & is usable by Xvnc
mkdir -p /tmp/.X11-unix
# make it world-writable; sticky bit is fine
chmod 1777 /tmp/.X11-unix || true
# remove stale VNC lock/socket if present
rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null || true

# 2) IMPORTANT: Do not force global XAUTHORITY to the host gdm file.
# TurboVNC will manage its own Xauthority for DISPLAY=:1.
unset XAUTHORITY

# ROS setup
. /opt/ros/humble/setup.sh
. /home/${WORKSPACE}/install/setup.sh

exec "$@"
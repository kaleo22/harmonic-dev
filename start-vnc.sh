#!/usr/bin/env bash
set -euo pipefail

export PATH="/opt/TurboVNC/bin:/opt/VirtualGL/bin:$PATH"

# VNC display (desktop you connect to)
export DISPLAY="${DISPLAY:-:1}"
VNC_GEOMETRY="${VNC_GEOMETRY:-1920x1080}"
VNC_DEPTH="${VNC_DEPTH:-24}"
VNC_PASSWORD="${VNC_PASSWORD:-}"

# Runtime dir for Qt apps (removes warning)
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/tmp/runtime-${USER}}"
mkdir -p "${XDG_RUNTIME_DIR}"
chmod 700 "${XDG_RUNTIME_DIR}"

# --- Start a "3D X server" on :0 (headless) ---
# VirtualGL will use this display for GPU rendering.
if ! pgrep -x Xorg >/dev/null 2>&1; then
  echo "Starting Xorg on :0 ..."
  rm -f /tmp/.X0-lock /tmp/.X11-unix/X0 || true
  mkdir -p /tmp/.X11-unix
  chmod 1777 /tmp/.X11-unix

  # Start Xorg headless
  Xorg :0 -noreset -nolisten tcp -logfile /tmp/Xorg.0.log &
  sleep 1
fi

# --- TurboVNC setup ---
mkdir -p "${HOME}/.vnc"

if [[ -n "${VNC_PASSWORD}" ]]; then
  printf "%s\n" "${VNC_PASSWORD}" | vncpasswd -f > "${HOME}/.vnc/passwd"
  chmod 600 "${HOME}/.vnc/passwd"
fi

cat > "${HOME}/.vnc/xstartup" <<'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
xrdb $HOME/.Xresources
startxfce4 &
EOF
chmod +x "${HOME}/.vnc/xstartup"

vncserver -kill "${DISPLAY}" >/dev/null 2>&1 || true

vncserver "${DISPLAY}" \
  -geometry "${VNC_GEOMETRY}" \
  -depth "${VNC_DEPTH}"

echo ""
echo "VNC started:"
echo "  VNC DISPLAY=${DISPLAY} (connect to port 5901 for :1)"
echo ""
echo "To test OpenGL renderer inside VNC desktop:"
echo "  glxinfo -B | egrep \"OpenGL vendor|OpenGL renderer\""
echo ""
echo "To run Gazebo with GPU via VirtualGL (inside VNC desktop terminal):"
echo "  vglrun -d :0 gz sim"
echo ""
echo "Xorg log (3D display): /tmp/Xorg.0.log"
echo ""

tail -f /dev/null
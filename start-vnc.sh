#!/usr/bin/env bash
set -euo pipefail
export PATH="/opt/TurboVNC/bin:/opt/VirtualGL/bin:$PATH"

# Defaults
export DISPLAY="${DISPLAY:-:1}"
VNC_GEOMETRY="${VNC_GEOMETRY:-1920x1080}"
VNC_DEPTH="${VNC_DEPTH:-24}"
VNC_PASSWORD="${VNC_PASSWORD:-}"

# TurboVNC nutzt ~/.vnc
mkdir -p "${HOME}/.vnc"

# Passwort setzen (falls gegeben)
if [[ -n "${VNC_PASSWORD}" ]]; then
  # vncpasswd -f erzeugt hash; turbovnc akzeptiert ~/.vnc/passwd
  printf "%s\n" "${VNC_PASSWORD}" | vncpasswd -f > "${HOME}/.vnc/passwd"
  chmod 600 "${HOME}/.vnc/passwd"
fi

# xstartup: startet XFCE
cat > "${HOME}/.vnc/xstartup" <<'EOF'
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
xrdb $HOME/.Xresources
startxfce4 &
EOF
chmod +x "${HOME}/.vnc/xstartup"

# Alte Session ggf. weg
vncserver -kill "${DISPLAY}" >/dev/null 2>&1 || true

# TurboVNC Server starten
# -localhost no => erreichbar im LAN (sonst nur localhost)
vncserver "${DISPLAY}" \
  -geometry "${VNC_GEOMETRY}" \
  -depth "${VNC_DEPTH}"

echo ""
echo "VNC started:"
echo "  DISPLAY=${DISPLAY}"
echo "  Connect with a VNC client to: <HOST-IP>:$(echo "${DISPLAY}" | sed 's/^://')590"
echo "  (For :1 the port is 5901)"
echo ""
echo "Inside the VNC desktop, start Gazebo with GPU via:"
echo "  vglrun -d /dev/dri/card0 gz sim"
echo "  or: vglrun gz sim"
echo ""

# Block forever so container stays up
tail -f /dev/null
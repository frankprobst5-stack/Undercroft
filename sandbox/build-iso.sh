#!/bin/bash
# Builds the real Undercroft Full x86 installer image: Debian 12 (bookworm)
# live image with Calamares (auto-launching on login) and Xfce, plus every
# real OS-layer step from Phase 1's provision.sh folded in as either
# build-time provisioning (baked into the image, no real user/hardware
# needed yet) or first-boot provisioning (needs the real installed system
# and a real operator) -- see ROADMAP.md's Phase 2 entry for the full
# research trail behind this split and why live-build+Calamares (not
# debos) is the right tool for this specific path.
#
# Run this INSIDE a privileged container (needs real chroot/mount
# capabilities), e.g.:
#
#   mkdir -p build-output
#   docker run --rm --privileged \
#       -v "$(pwd)/build-output":/output \
#       -v "$(pwd)/build-iso.sh":/build-iso.sh:ro \
#       -v "$(pwd)/../brand":/brand:ro \
#       debian:12-slim bash /build-iso.sh
#
# Real build time: roughly an hour on a normal connection (Calamares alone
# pulls in a real Qt5 stack) -- this is not a quick script.
set -ex
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq live-build

mkdir -p /build
cd /build

lb config \
    --distribution bookworm \
    --architecture amd64 \
    --binary-image iso-hybrid \
    --bootloaders grub-efi \
    --archive-areas "main contrib non-free non-free-firmware" \
    --zsync false \
    --onie false

# ---------------------------------------------------------------------------
# Build-time package list -- everything provision.sh installed via apt that
# doesn't need a real logged-in user or real hardware present. Every one of
# these was confirmed as a real Debian 12 main-archive package via a live
# `apt-cache policy` before being added here, not assumed -- js8call and pat
# in particular turned out to already be plain main-archive packages (an
# earlier note in this project's own docs had flagged them as needing a
# vendor repo; re-checked live 2026-09-17 and that's no longer/wasn't
# actually true for Debian 12).
# ---------------------------------------------------------------------------
mkdir -p config/package-lists
cat > config/package-lists/undercroft.list.chroot <<'EOF'
calamares
calamares-settings-debian
xfce4
xfce4-terminal
lightdm
live-boot
live-config
avahi-daemon
libnss-mdns
bubblewrap
qrencode
chrony
gpsd
gpsd-clients
pps-tools
git
direwolf
libhamlib-utils
js8call
pat
rtl-sdr
tcpdump
tshark
htop
iotop
iperf3
iproute2
iw
EOF

# ---------------------------------------------------------------------------
# Docker Engine -- not in Debian's own archive, needs the real official repo
# (docs.docker.com/engine/install/debian). Runs as a build-time chroot hook
# so it's baked into the image, matching provision.sh's own exact method
# (already verified working on real Debian 12) rather than reinventing it.
# ---------------------------------------------------------------------------
mkdir -p config/hooks/normal
cat > config/hooks/normal/0100-docker-install.hook.chroot <<'EOF'
#!/bin/sh
set -e
export DEBIAN_FRONTEND=noninteractive
apt-get install -y -qq ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

ARCH="$(dpkg --print-architecture)"
cat > /etc/apt/sources.list.d/docker.sources <<INNEREOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: bookworm
Components: stable
Architectures: ${ARCH}
Signed-By: /etc/apt/keyrings/docker.asc
INNEREOF

apt-get update -qq
apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
EOF
chmod +x config/hooks/normal/0100-docker-install.hook.chroot

# ---------------------------------------------------------------------------
# Network hardening -- the two items adopted from the 2026-09-17 review:
# ICMP redirects off (safe, no downside for an end host) and rp_filter=2
# (loose mode, not strict =1 -- strict mode can drop legitimate traffic on
# a multi-homed box, and Undercroft nodes realistically carry WiFi +
# Ethernet + a mesh-radio USB interface at once).
# ---------------------------------------------------------------------------
mkdir -p config/includes.chroot/etc/sysctl.d
cat > config/includes.chroot/etc/sysctl.d/99-undercroft.conf <<'EOF'
# Undercroft network hardening -- adopted 2026-09-17 from an external
# review, corrected against this project's own real multi-interface
# reality (mesh radio + WiFi + Ethernet all plausible at once).
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.rp_filter = 2
EOF

# ---------------------------------------------------------------------------
# Chrony -- real offline-capable time sync. `local stratum 10` is the
# correct, honest directive for "keep serving LAN clients even with no
# upstream source" -- the external review's own suggestion said "stratum 1",
# which is real NTP terminology for a device with an actual
# reference clock (GPS/atomic); claiming that for a bare RTC fallback would
# mislead anything else on the network that trusts it. The GPS refclock
# stanza is real, standard chrony.conf(5) syntax, inert until real GPS
# hardware exists (same honest-inert pattern provision.sh already used).
# Debian's own chrony.conf ships `confdir /etc/chrony/conf.d` by default
# (confirmed live before relying on it), so this drops in cleanly.
# ---------------------------------------------------------------------------
mkdir -p config/includes.chroot/etc/chrony/conf.d
cat > config/includes.chroot/etc/chrony/conf.d/undercroft.conf <<'EOF'
# Offline-capable fallback: keep serving time to the LAN at an honest
# stratum even with zero reachable upstream sources.
local stratum 10

# Real, inert-until-hardware-exists GPS time source. Activating this for
# real is a two-step, not automatic:
#   1. Point gpsd at the real device: edit /etc/default/gpsd, set
#      DEVICES="/dev/ttyUSB0" (or whatever `dmesg` shows after plugging
#      the GPS in), then `systemctl restart gpsd`.
#   2. Uncomment the line below.
# refclock SHM 0 refid GPS precision 1e-1 offset 0.5 delay 0.2
EOF

# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# Branded desktop background -- the Citadel Ecosystem crest, centered on the
# ecosystem's own canonical background color (brand/PALETTE.md's --bg:
# #05090d), replacing Debian's default wallpaper. Composited here, in this
# build container, straight into config/includes.chroot so it ships baked
# into the image -- needs /brand mounted in (see the docker run invocation
# in this script's own header comment). Applied via a first-login autostart
# script rather than a hand-authored xfconf property path: xfce4-desktop
# keys its wallpaper properties by the real detected monitor name (e.g.
# "monitorHDMI-1"), which can't be predicted ahead of time for arbitrary
# target hardware -- querying the channel's own live property list at first
# login, after xfdesktop has actually initialized it, is the only reliable
# way to target the right property instead of guessing.
# ---------------------------------------------------------------------------
apt-get install -y -qq imagemagick

mkdir -p config/includes.chroot/usr/share/backgrounds/undercroft
convert -size 3840x2160 xc:'#05090d' \
    \( /brand/undercroft-logo.png -resize 1150x1150 \) \
    -gravity center -composite \
    config/includes.chroot/usr/share/backgrounds/undercroft/undercroft-wallpaper.png

cat > config/includes.chroot/usr/local/bin/undercroft-set-wallpaper <<'SCRIPT'
#!/usr/bin/env bash
# Applies the Undercroft branded wallpaper on first real Xfce login. Waits
# for xfce4-desktop to expose its own live property list, then sets
# last-image/image-style on whatever workspace properties it actually
# created for this machine's real monitor(s) -- never a guessed monitor
# name. Runs once per account (marker file below); never re-forces the
# wallpaper if the operator changes it later.
set -euo pipefail

MARKER="$HOME/.config/.undercroft-wallpaper-set"
[[ -f "$MARKER" ]] && exit 0

IMG="/usr/share/backgrounds/undercroft/undercroft-wallpaper.png"
[[ -f "$IMG" ]] || exit 0

for _ in $(seq 1 20); do
    xfconf-query -c xfce4-desktop -l 2>/dev/null | grep -q '/workspace0$' && break
    sleep 1
done

xfconf-query -c xfce4-desktop -l 2>/dev/null | grep -E '/workspace[0-9]+$' | while read -r ws; do
    if xfconf-query -c xfce4-desktop -p "$ws/last-image" >/dev/null 2>&1; then
        xfconf-query -c xfce4-desktop -p "$ws/last-image" -s "$IMG"
    else
        xfconf-query -c xfce4-desktop -p "$ws/last-image" -n -t string -s "$IMG"
    fi
    if xfconf-query -c xfce4-desktop -p "$ws/image-style" >/dev/null 2>&1; then
        xfconf-query -c xfce4-desktop -p "$ws/image-style" -s 5
    else
        xfconf-query -c xfce4-desktop -p "$ws/image-style" -n -t int -s 5
    fi
done

mkdir -p "$(dirname "$MARKER")"
touch "$MARKER"
SCRIPT
chmod +x config/includes.chroot/usr/local/bin/undercroft-set-wallpaper

mkdir -p config/includes.chroot/etc/xdg/autostart
cat > config/includes.chroot/etc/xdg/autostart/undercroft-wallpaper.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Undercroft wallpaper
Exec=/usr/local/bin/undercroft-set-wallpaper
OnlyShowIn=XFCE;
X-GNOME-Autostart-enabled=true
NoDisplay=true
EOF

# Boot-console QR + first-boot provisioning -- both real first-boot concerns
# (need the real installed system, not the live/build environment), both
# guarded by the same `boot=live`-absent check the Calamares autostart fix
# already established as the reliable live-vs-installed test.
# ---------------------------------------------------------------------------
mkdir -p config/includes.chroot/usr/local/bin

cat > config/includes.chroot/usr/local/bin/undercroft-console-info <<'SCRIPT'
#!/usr/bin/env bash
# Prints this box's real reachable address on every real boot so a
# headless station never needs a keyboard/monitor past first setup.
# No-ops on the live medium itself -- pointless before an install exists.
set -euo pipefail
grep -q boot=live /proc/cmdline && exit 0

HN="$(hostname)"
IP="$(hostname -I 2>/dev/null | awk '{print $1}')"
URL="http://${HN}.local:8085"

echo ""
echo "============================================================"
echo " UNDERCROFT — $HN"
echo "============================================================"
echo " Dashboard : $URL"
[[ -n "$IP" ]] && echo " Direct IP : http://${IP}:8085"
echo ""
if command -v qrencode >/dev/null 2>&1; then
    qrencode -t ANSIUTF8 "$URL"
else
    echo " (qrencode not installed — install it for a scannable QR here)"
fi
echo "============================================================"
SCRIPT
chmod +x config/includes.chroot/usr/local/bin/undercroft-console-info

mkdir -p config/includes.chroot/etc/systemd/system
cat > config/includes.chroot/etc/systemd/system/undercroft-console-info.service <<'EOF'
[Unit]
Description=Undercroft console info banner (address + QR)
After=network-online.target avahi-daemon.service
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/undercroft-console-info
StandardOutput=tty
TTYPath=/dev/tty1
RemainAfterExit=no

[Install]
WantedBy=multi-user.target
EOF

# Real first-boot provisioning: everything provision.sh did that genuinely
# needs a real installed system with a real operator account already
# present (which Calamares creates -- its own "users" module, not
# provision.sh's old $SUDO_USER-detection dance, which no longer applies
# at all now). Runs once, gated by a real marker file, and only on a real
# installed boot (never on the live medium).
cat > config/includes.chroot/usr/local/bin/undercroft-first-boot <<'SCRIPT'
#!/usr/bin/env bash
# Real first-boot provisioning -- runs exactly once, only on a real
# installed system (never the live medium). Hostname/locale/user account
# are already Calamares' own job (its "users"/"hostname" modules), not
# duplicated here.
set -euo pipefail

MARKER=/var/lib/undercroft/first-boot-done
[[ -f "$MARKER" ]] && exit 0
grep -q boot=live /proc/cmdline && exit 0
mkdir -p /var/lib/undercroft

# The real operator account Calamares just created -- first real (non-
# system) UID on a single-user appliance install, same reasoning
# provision.sh's own $SUDO_USER detection used, just adapted since there's
# no sudo context to read it from here.
REAL_USER="$(awk -F: '$3 >= 1000 && $3 < 60000 && $1 != "nobody" {print $1; exit}' /etc/passwd)"

if [[ -n "$REAL_USER" ]]; then
    usermod -aG docker,dialout,plugdev "$REAL_USER"

    CITADEL_DIR="/home/${REAL_USER}/citadel"
    if [[ ! -d "$CITADEL_DIR/.git" ]]; then
        runuser -u "$REAL_USER" -- git clone https://github.com/frankprobst5-stack/Project-Citadel.git "$CITADEL_DIR" || true
    fi
fi

# Laptop-specific fix -- only applied if this actually looks like a laptop
# (has a battery), same real detection provision.sh already used. Can only
# be decided now, on the real target hardware -- unknowable at image-build
# time.
if compgen -G "/sys/class/power_supply/BAT*" > /dev/null 2>&1; then
    if ! grep -q "UNDERCROFT-LAPTOP" /etc/systemd/logind.conf 2>/dev/null; then
        cat >> /etc/systemd/logind.conf <<'EOF'

# --- UNDERCROFT-LAPTOP ---
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
IdleAction=ignore
EOF
        systemctl restart systemd-logind || true
    fi
fi

touch "$MARKER"

if [[ -n "$REAL_USER" ]]; then
    runuser -u "$REAL_USER" -- mkdir -p "/home/${REAL_USER}/Desktop"
    cat <<EOF > "/home/${REAL_USER}/Desktop/UNDERCROFT-NEXT-STEPS.txt"
Undercroft OS-layer provisioning is done.

Next: run Citadel's own installer (not as root):
  cd ~/citadel && ./install.sh

You were added to the docker/dialout/plugdev groups -- log out and back
in (or reboot) before relying on those.
EOF
fi
SCRIPT
chmod +x config/includes.chroot/usr/local/bin/undercroft-first-boot

cat > config/includes.chroot/etc/systemd/system/undercroft-first-boot.service <<'EOF'
[Unit]
Description=Undercroft real first-boot provisioning (runs once)
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/undercroft-first-boot
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Enabling both units is itself a build-time (chroot) action -- a hook
# script that runs `systemctl enable` inside the chroot, the standard
# live-build pattern for this, confirmed against live-build's own real
# hook mechanism (config/hooks/normal/*.hook.chroot, verified via the
# live-build package's own file manifest before relying on it).
cat > config/hooks/normal/0200-enable-services.hook.chroot <<'EOF'
#!/bin/sh
set -e
systemctl enable undercroft-console-info.service
systemctl enable undercroft-first-boot.service
EOF
chmod +x config/hooks/normal/0200-enable-services.hook.chroot

# ---------------------------------------------------------------------------
# Real autostart so Calamares actually launches when the live session boots
# -- documented Debian Live Project pattern for a Calamares live image
# (verified via web research before writing this, not guessed). Guarded by
# a real check for `boot=live` on the kernel command line -- found live
# 2026-09-16 that Calamares' own unpackfs module copies the ENTIRE live
# filesystem onto the target disk verbatim, autostart file included, so
# without this guard Calamares launches again every time the freshly
# installed system boots. `boot=live` is live-boot's own real, documented
# marker (only ever present in the live medium's own boot entry, never
# written into the installed system's real grub.cfg), so this is a
# reliable way to tell "am I the live session" from "am I an install",
# not a guess.
# ---------------------------------------------------------------------------
mkdir -p config/includes.chroot/etc/xdg/autostart
cat > config/includes.chroot/etc/xdg/autostart/calamares.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Install Undercroft
Exec=sh -c "grep -q boot=live /proc/cmdline && pkexec calamares"
Icon=calamares
X-GNOME-Autostart-enabled=true
EOF

lb build

mkdir -p /output
cp /build/live-image-amd64.hybrid.iso /output/undercroft-sandbox.iso
echo "Real ISO written to /output/undercroft-sandbox.iso"

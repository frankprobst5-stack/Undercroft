#!/usr/bin/env bash
# Undercroft Full — Phase 1 provisioning script
#
# Turns a bare Debian 12 (Bookworm) install into an Undercroft Full station:
# Docker + Citadel's own install.sh handed off to, the appliance behaviors a
# bare `docker compose up -d` doesn't give you on its own (auto-start on
# reboot, a predictable mDNS address, a no-keyboard first-boot QR), and the
# radio/time/sandboxing groundwork WayStation, Gated, and real ham radio
# hardware all eventually need.
#
# Scope, per Undercroft's own ROADMAP.md Phase 1: x86 desktop/laptop only.
# This script does NOT attempt Citadel's own Raspberry Pi tier split (that's
# Citadel's own unbuilt item) and does NOT build a flashable image (that's
# Undercroft Phase 2) — it's the provisioning step those later phases wrap.
#
# Real, verified before writing (not guessed): every `apt` package name
# below was confirmed to exist in Debian 12 "bookworm" main via a live
# `debian:12-slim` container, and the Docker install steps match Docker's
# own current official documentation (docs.docker.com/engine/install/debian),
# fetched directly rather than reproduced from memory.
#
# Honest, named gaps this script does NOT close (same standard this whole
# ecosystem holds every install script to — see Undercroft's own ROADMAP.md
# "Real open items"): the boot-console QR display hasn't been verified on
# real hardware yet; the GPS/chrony time stanza is written but inert until a
# real USB GPS is plugged in and its device path substituted; and this was
# tested for package-installability and idempotence in a container, not for
# full systemd/reboot behavior on real metal — that verification still needs
# a real x86 box, per Phase 1's own stated acceptance test: reboot, still
# works; disconnect the WAN, still works.

set -euo pipefail

# ---------------------------------------------------------------------------
# 0. Preflight
# ---------------------------------------------------------------------------

if [[ $EUID -ne 0 ]]; then
    echo "This needs root (it installs packages and edits systemd config)." >&2
    echo "Run it again with: sudo $0" >&2
    exit 1
fi

# The person who ran `sudo` — the groups/permissions work below (dialout,
# plugdev, docker) needs to land on the real operator's account, not root's.
REAL_USER="${SUDO_USER:-$(logname 2>/dev/null || echo "")}"
if [[ -z "$REAL_USER" || "$REAL_USER" == "root" ]]; then
    echo "Couldn't determine the real (non-root) user to grant hardware access to." >&2
    echo "Run this via 'sudo' from your own account, not as a root login shell." >&2
    exit 1
fi

if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "${ID:-}" != "debian" || "${VERSION_ID:-}" != "12" ]]; then
        echo "Warning: Undercroft Full's Phase 1 is built and tested against"
        echo "Debian 12 (Bookworm) specifically — this looks like ${PRETTY_NAME:-an unknown OS}."
        echo "It may still work (Ubuntu/other Debian derivatives share most of this),"
        echo "but real testing so far has only covered Debian 12 itself."
        read -r -p "Continue anyway? [y/N] " reply
        [[ "$reply" =~ ^[Yy]$ ]] || exit 1
    fi
fi

echo "============================================================"
echo " UNDERCROFT FULL — Phase 1 provisioning"
echo " Operator account: $REAL_USER"
echo "============================================================"

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq

# ---------------------------------------------------------------------------
# 1. Docker Engine — real official method, not Docker Desktop (doesn't exist
#    for headless Debian). Idempotent: skips cleanly if already installed.
# ---------------------------------------------------------------------------

if command -v docker >/dev/null 2>&1 && docker compose version >/dev/null 2>&1; then
    echo "-- Docker already installed, skipping."
else
    echo "-- Installing Docker Engine (official apt repo, docs.docker.com)."
    apt-get install -y -qq ca-certificates curl
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    ARCH="$(dpkg --print-architecture)"
    CODENAME="${VERSION_CODENAME:-bookworm}"
    tee /etc/apt/sources.list.d/docker.sources > /dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: ${CODENAME}
Components: stable
Architectures: ${ARCH}
Signed-By: /etc/apt/keyrings/docker.asc
EOF

    apt-get update -qq
    apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

# Real unattended-appliance requirement: the daemon must come back on its
# own after a reboot with nobody there to log in and start it by hand.
if command -v systemctl >/dev/null 2>&1; then
    systemctl enable --now docker
else
    echo "-- No systemd detected (expected in some test containers) — skipping service enable."
fi

usermod -aG docker "$REAL_USER"

# ---------------------------------------------------------------------------
# 2. Core services: mDNS discovery, Gated's future sandbox tool, the
#    no-keyboard boot QR, and offline-capable time sync.
# ---------------------------------------------------------------------------

echo "-- Installing core services (avahi, bubblewrap, qrencode, chrony/gpsd)."
apt-get install -y -qq \
    avahi-daemon libnss-mdns \
    bubblewrap \
    qrencode \
    chrony gpsd gpsd-clients pps-tools \
    git

if command -v systemctl >/dev/null 2>&1; then
    systemctl enable --now avahi-daemon
    systemctl enable --now chrony
fi

# Only claim the "citadel" hostname on a box that hasn't already been named
# something deliberate — an install script has no business silently renaming
# a machine the operator already set up. Debian's own installer default is
# usually just whatever was typed at setup, so this only catches genuinely
# unconfigured/default-looking hostnames.
CURRENT_HOSTNAME="$(hostname)"
if [[ "$CURRENT_HOSTNAME" == "debian" || "$CURRENT_HOSTNAME" == "localhost" ]]; then
    hostnamectl set-hostname citadel 2>/dev/null || hostname citadel
    echo "-- Hostname set to 'citadel' (was '$CURRENT_HOSTNAME') — reachable at citadel.local via mDNS."
else
    echo "-- Hostname left as '$CURRENT_HOSTNAME' (already customized) — reachable at ${CURRENT_HOSTNAME}.local via mDNS."
fi

# Real, inert-until-hardware-exists GPS time stanza. `refclock SHM 0` is
# chrony's standard driver for reading gpsd's shared-memory segment — this
# is documented, standard syntax (chrony.conf(5)), not invented here, but it
# does nothing until a real USB GPS is attached and gpsd is pointed at its
# device path (commented below rather than guessed at, since that path is
# hardware-specific).
if ! grep -q "UNDERCROFT-GPS-REFCLOCK" /etc/chrony/chrony.conf 2>/dev/null; then
    cat >> /etc/chrony/chrony.conf <<'EOF'

# --- UNDERCROFT-GPS-REFCLOCK ---
# Offline-capable time source: with no WAN, there's no NTP server to correct
# against, and both JS8Call/FT8-family digital modes and WSP/1's own object
# timestamps depend on an accurate clock. Inert until real GPS hardware is
# attached — activating this for real is a two-step, not automatic:
#   1. Point gpsd at the real device: edit /etc/default/gpsd, set
#      DEVICES="/dev/ttyUSB0" (or whatever `dmesg` shows after plugging the
#      GPS in), then `systemctl restart gpsd`.
#   2. Uncomment the line below.
# refclock SHM 0 refid GPS precision 1e-1 offset 0.5 delay 0.2
EOF
fi

# ---------------------------------------------------------------------------
# 3. Radio-ready: real hardware permissions and tooling, not a WayStation job
#    — these are OS-layer concerns (serial/USB group access, driver udev
#    rules), which is exactly what justifies Undercroft being its own layer
#    rather than "just tell people to install Debian."
# ---------------------------------------------------------------------------

echo "-- Installing radio tooling (Direwolf, hamlib, JS8Call, Pat, rtl-sdr)."
apt-get install -y -qq \
    direwolf \
    libhamlib-utils \
    js8call \
    pat \
    rtl-sdr

# `rtl-sdr`'s own Debian package ships real, maintained udev rules
# (/lib/udev/rules.d/60-librtlsdr0.rules) — installing it is the whole fix,
# no hand-authored vendor:product-ID rules needed or wanted here.
#
# Meshtastic devices are generic ESP32 boards over standard USB-serial
# chips (CP210x/CH340) with no dedicated Debian package of their own —
# Debian's stock udev rules already grant the `dialout` group access to
# /dev/ttyUSB*/ttyACM*, so the real fix is just group membership, not a
# custom rule.
usermod -aG dialout,plugdev "$REAL_USER"

# ---------------------------------------------------------------------------
# 4. Laptop-specific fix — only applied if this actually looks like a
#    laptop (has a battery), so a desktop doesn't get an irrelevant change.
# ---------------------------------------------------------------------------

if compgen -G "/sys/class/power_supply/BAT*" > /dev/null 2>&1; then
    echo "-- Battery detected — treating this as a laptop, disabling suspend-on-lid-close/idle."
    if ! grep -q "UNDERCROFT-LAPTOP" /etc/systemd/logind.conf 2>/dev/null; then
        cat >> /etc/systemd/logind.conf <<'EOF'

# --- UNDERCROFT-LAPTOP ---
# A laptop repurposed as a portable/vehicle-based station needs to keep
# serving Citadel with the lid shut — stock Debian's default laptop power
# behavior actively fights that if left unconfigured.
HandleLidSwitch=ignore
HandleLidSwitchExternalPower=ignore
IdleAction=ignore
EOF
        if command -v systemctl >/dev/null 2>&1; then
            systemctl restart systemd-logind || true
        fi
    fi
else
    echo "-- No battery detected — desktop/Pi-class hardware, skipping laptop-specific config."
fi

# ---------------------------------------------------------------------------
# 5. Workstation profile: Xfce + Firefox ESR in "the Gated slot." Asked, not
#    assumed — a Workstation build (someone sitting at the machine with
#    radio gear) needs a real desktop; a pure headless hub doesn't. Default
#    is yes, since Full's whole reason for existing (per its own ROADMAP.md)
#    is the operator-station profile — a headless x86 box is a real, valid
#    choice too, just not the common case this product is built around.
# ---------------------------------------------------------------------------

WORKSTATION="y"
if [[ -t 0 ]]; then
    read -r -p "Set up a desktop for someone to sit at (Workstation profile)? [Y/n] " reply
    [[ "$reply" =~ ^[Nn] ]] && WORKSTATION="n"
else
    echo "-- Non-interactive install — defaulting to the Workstation profile (desktop + Firefox)."
fi

if [[ "$WORKSTATION" == "y" ]]; then
    echo "-- Installing Xfce and Firefox ESR (real Debian 12 packages, not guessed)."
    apt-get install -y -qq xfce4 xfce4-terminal lightdm firefox-esr

    if command -v systemctl >/dev/null 2>&1; then
        systemctl enable lightdm
    fi

    # Real X11 choice, not an oversight: a meaningful slice of ham radio
    # software (WSJT-X, fldigi, gpredict, CHIRP) has an X11-first heritage
    # with inconsistent native-Wayland support — Xfce's own default
    # session is X11 on Debian 12, which is exactly the compatibility this
    # profile exists to preserve, not something to "fix" by forcing Wayland.

    # Firefox ESR here is the real placeholder named in ROADMAP.md's "Gated
    # slot" — Undercroft's own build order shouldn't be blocked on Gated
    # having zero code yet. Swapped for real Gated once it exists (Phase 6).
    echo "-- Firefox ESR installed as the Gated slot placeholder — see ROADMAP.md Phase 6."
else
    echo "-- Skipping the desktop — headless Workstation build."
fi

# ---------------------------------------------------------------------------
# 6. First-boot, no-keyboard console: mDNS name + IP + a scannable QR to the
#    dashboard, printed to the physical console on every boot.
# ---------------------------------------------------------------------------

cat > /usr/local/bin/undercroft-console-info <<'SCRIPT'
#!/usr/bin/env bash
# Prints this box's real reachable address on every boot so a headless
# station never needs a keyboard/monitor past this point.
set -euo pipefail
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
chmod +x /usr/local/bin/undercroft-console-info

cat > /etc/systemd/system/undercroft-console-info.service <<'EOF'
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

if command -v systemctl >/dev/null 2>&1; then
    systemctl daemon-reload
    systemctl enable undercroft-console-info.service
fi

# ---------------------------------------------------------------------------
# 7. Hand off to Citadel's own installer — no duplicated install logic here.
# ---------------------------------------------------------------------------

CITADEL_DIR="${CITADEL_DIR:-/home/${REAL_USER}/citadel}"

if [[ -d "$CITADEL_DIR/.git" ]]; then
    echo "-- Found an existing Citadel checkout at $CITADEL_DIR — leaving it alone."
else
    echo "-- Cloning Citadel to $CITADEL_DIR"
    # `runuser` (util-linux, always present) rather than `sudo -u` — a
    # minimal Debian install has no guarantee `sudo` itself is installed,
    # confirmed by a real container test hitting exactly that missing binary.
    runuser -u "$REAL_USER" -- git clone https://github.com/frankprobst5-stack/Project-Citadel.git "$CITADEL_DIR"
fi

echo ""
echo "============================================================"
echo " Undercroft OS-layer provisioning is done."
echo ""
echo " Next: run Citadel's own installer as $REAL_USER (not root):"
echo "   cd $CITADEL_DIR && ./install.sh"
echo ""
echo " $REAL_USER was added to the docker/dialout/plugdev groups —"
echo " log out and back in (or reboot) before relying on those."
echo "============================================================"

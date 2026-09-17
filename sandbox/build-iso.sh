#!/bin/bash
# Builds a real Undercroft test ISO: Debian 12 (bookworm) live image with
# Calamares (auto-launching on login) and Xfce, matching Undercroft's own
# decided Workstation profile. This is a real, hands-on-verified starting
# point for Phase 2's actual recipe, not a guess -- see ROADMAP.md's Phase 0
# entry for the full research trail (why live-build+Calamares over debos for
# this specific path, why these exact packages).
#
# Run this INSIDE a privileged container (needs real chroot/mount
# capabilities), e.g.:
#
#   mkdir -p build-output
#   docker run --rm --privileged \
#       -v "$(pwd)/build-output":/output \
#       -v "$(pwd)/build-iso.sh":/build-iso.sh:ro \
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

mkdir -p config/package-lists
cat > config/package-lists/undercroft.list.chroot <<'EOF'
calamares
calamares-settings-debian
xfce4
xfce4-terminal
lightdm
live-boot
live-config
EOF

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

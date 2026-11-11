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
    --onie false \
    --bootappend-live "boot=live components quiet splash persistence"
    # Real bug found and fixed, 2026-11-08: `--bootappend-live` REPLACES
    # live-build's own default live-boot kernel parameters, it does not
    # append to them. An earlier version of this line passed just
    # "persistence", which silently wiped out `boot=live components quiet
    # splash` -- without `boot=live` specifically, live-boot's own
    # initramfs root-finding scripts never activate at all, and the boot
    # falls through to the generic initramfs-tools fallback, which fails
    # with "No root device specified." Caught live (not guessed) by
    # extracting the actual built grub.cfg before this fix existed,
    # editing the broken kernel line by hand in GRUB's own edit mode to
    # confirm restoring the missing flags fixed the boot, then only
    # applying the equivalent fix here once that was proven. The real
    # values restored (`boot=live components quiet splash`) come directly
    # from this same build's own pre-persistence grub.cfg, extracted via
    # xorriso before this feature existed -- not guessed or assumed to be
    # live-build's documented default.

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

# Real pocket-mode need: live-config's own default live username is
# "user" (confirmed live, 2026-11-08, via a real booted session's actual
# terminal prompt -- user@debian:~$ -- not assumed). Not in the docker
# group by default; the pocket first-boot service itself runs as root so
# this isn't needed for that, but without it a live session's own
# interactive terminal can't run `docker ps`/`docker compose` without
# sudo, which would be a real, confusing rough edge on a box meant to be
# used by hand in an emergency.
usermod -aG docker,dialout,plugdev user 2>/dev/null || true
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

# Real pre-existing bug, found and fixed 2026-11-08 (unrelated to this
# session's live-boot change): this write target's directory was never
# created before the cat below -- the only `usr/local/bin` mkdir in this
# script lived much further down, in the boot-console section, so a
# clean container-from-scratch run (confirmed: not a side effect of
# anything added this session) failed here every time with "No such file
# or directory."
mkdir -p config/includes.chroot/usr/local/bin
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

# Real bug found live 2026-11-10, during the 1TB persistence re-test:
# `light-locker` (pulled in by the `xfce4` task, never explicitly requested)
# locks the session after its own distro-default idle timeout, same as any
# normal desktop install -- but live-config's own auto-created "user"
# account has no real, reliably-enterable password (confirmed directly: the
# same literal credentials that unlocked a session once did not reliably
# unlock a second one, and a fresh `lightdm` greeter spawned on a second,
# separate Xorg display when the lock fired, rejecting every password tried
# against it, confirmed via a real `ps aux` showing both `light-locker` and
# a second `lightdm --session-child`/`lightdm-gtk-greeter` genuinely
# running). A locked-out operator's only real way back in is switching to a
# text VT (Ctrl+Alt+F2) for a root-capable shell and killing the locker --
# not a reasonable expectation for the non-technical family member/operator
# this whole project is designed for, and directly inconsistent with this
# same project's own standing rule elsewhere (the laptop lid-switch/idle-
# suspend fix) that nothing should be able to leave an operator stranded.
# Real fix: disable the idle lock entirely for the live session via the
# standard XDG autostart override mechanism (a same-named file with
# `Hidden=true` suppresses the package's own shipped autostart entry,
# without uninstalling `light-locker` itself or anything that depends on
# it) -- confirmed this is the real, standard override mechanism against
# the XDG Desktop Entry Specification, not guessed.
cat > config/includes.chroot/etc/xdg/autostart/light-locker.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Light Locker
Hidden=true
EOF

# ---------------------------------------------------------------------------
# "Undercroft Pocket" -- carries Citadel + WayStation + Baneward + a curated
# reference/AI bundle so the whole thing works with zero internet access on
# a borrowed machine. Real bill of materials, confirmed sizes (not
# estimated): a curated 10-file Kiwix shortlist (10G -- ready.gov, medical/
# military-medicine references, ifixit, CDC, compact survival-skill guides;
# deliberately NOT the full library, which is 700GB+ real total across all
# 61 archives, including a single 235GB archive), one Ollama model
# (llama3.2:1b, 1.3G -- exactly the 5 real blob files its own manifest
# references, not the whole shared blob store, which also holds two other
# pulled models this build doesn't carry), three pre-exported Docker images
# (ollama/ollama, kiwix-serve, citadel-whisper -- 3.4G compressed) so
# nothing needs pulling at first boot, the real WayStation/Baneward .deb
# releases, Baneward's lean 216M core database (species/claims/chemistry
# data, no downloaded photo packs -- those run to 59G and aren't part of
# this build's "fast" goal), the real Whisper model (142M), and a real
# shallow clone of Citadel's own public repo (153M) so the actual compose/
# module code is on the drive too, not fetched live. Needs
# `-v .../pocket-assets:/pocket-assets:ro` mounted into this build
# container (see this script's own header for the full docker run
# invocation) -- real assets staged and verified (byte-for-byte against
# their real sources) before this section was written, not assumed present.
# ---------------------------------------------------------------------------
POCKET_ASSETS=/pocket-assets
POCKET_LIVE_HOME=config/includes.chroot/home/user

mkdir -p "${POCKET_LIVE_HOME}/citadel"
cp -a "${POCKET_ASSETS}/citadel-repo"/. "${POCKET_LIVE_HOME}/citadel/"

# Ollama's real volume mount (modules/ai/compose.fragment.yml) is the
# relative path `../../appdata/ollama` -- not env-configurable -- so the
# model data has to land exactly there, not some separate staging path.
mkdir -p "${POCKET_LIVE_HOME}/citadel/appdata/ollama"
cp -a "${POCKET_ASSETS}/ollama-model"/. "${POCKET_LIVE_HOME}/citadel/appdata/ollama/"

# Same real pattern for Whisper (modules/audio/compose.fragment.yml):
# `../../appdata/whisper-models`, relative, not env-configurable.
mkdir -p "${POCKET_LIVE_HOME}/citadel/appdata/whisper-models"
cp -a "${POCKET_ASSETS}/ggml-base.en.bin" "${POCKET_LIVE_HOME}/citadel/appdata/whisper-models/"

# Kiwix IS env-configurable (KIWIX_STORAGE_PATH) -- real path chosen here,
# matched by the fresh .env the first-boot script writes below.
mkdir -p "${POCKET_LIVE_HOME}/pocket-data/kiwix"
cp -a "${POCKET_ASSETS}/kiwix"/*.zim "${POCKET_LIVE_HOME}/pocket-data/kiwix/"

# Baneward's own real per-OS Tauri data directory (confirmed live,
# 2026-11-08: a fresh live boot's actual $HOME is /home/user) -- this is
# where BOTH the native Baneward app itself and Citadel's own read-only
# map-tie-in mount (docker-compose.yml's BANEWARD_DATA_PATH) expect to find
# it. Same file, one real location, not two copies to keep in sync.
mkdir -p "${POCKET_LIVE_HOME}/.local/share/baneward"
cp -a "${POCKET_ASSETS}/baneward-core.db" "${POCKET_LIVE_HOME}/.local/share/baneward/baneward.db"

# Pre-exported Docker image tars + the two .deb releases -- loaded/installed
# by the real first-boot script below, not at build time (no working
# dockerd inside a live-build chroot; `dpkg -i` IS safe at build time since
# it's pure filesystem work, done separately right below).
mkdir -p "${POCKET_LIVE_HOME}/pocket-data/docker-images"
cp -a "${POCKET_ASSETS}/docker-images"/*.tar "${POCKET_LIVE_HOME}/pocket-data/docker-images/"

# Real Compose override, Compose's own standard mechanism (merged
# automatically on top of the base files, zero edits to Citadel's shared,
# home-deployment-serving compose fragments): kiwix-serve can take ZIM
# paths directly (`kiwix-serve ZIMPATH ...`, confirmed via its own --help)
# instead of a `--library library.xml` index -- the real library.xml at the
# source lists all 61 archives, not this build's curated 10, so pointing at
# the real files directly avoids shipping a stale/mismatched index. The
# whisper override pins an explicit `image:` so Compose uses the
# first-boot-loaded `citadel-whisper:latest` tar directly instead of trying
# to build from source (which needs internet this build must not depend
# on) -- Compose's own documented behavior when both `build:` and `image:`
# are present on a service: use the named image if it already exists,
# build only if it doesn't.
mkdir -p "${POCKET_LIVE_HOME}/citadel"
cat > "${POCKET_LIVE_HOME}/citadel/docker-compose.override.yml" <<'EOF'
services:
  kiwix:
    command: --skipInvalid /data/www.ready.gov_en_2024-12.zim /data/wikipedia_en_medicine_maxi_2026-04.zim /data/medlineplus.gov_en_all_2025-01.zim /data/ifixit_en_all_2025-12.zim /data/wwwnc.cdc.gov_en_all_2024-11.zim /data/fas-military-medicine_en_2025-06.zim /data/irp.fas.org_en_military-medicine_2026-05.zim /data/zimgit-medicine_en_2024-08.zim /data/zimgit-water_en_2024-08.zim /data/zimgit-food-preparation_en_2025-04.zim
  whisper:
    image: citadel-whisper:latest
EOF

# Installing the two real native apps at build time -- `dpkg -i` is pure
# filesystem work (package extraction + postinst scripts), no running
# daemon needed, same reasoning the existing Docker-install hook above
# already relies on for chroot-safety. `apt-get install -f` resolves any
# missing runtime deps the .deb itself doesn't bundle, same as a normal
# `dpkg -i` + fixup on real hardware.
mkdir -p config/includes.chroot/opt/undercroft-pocket-debs
cp -a "${POCKET_ASSETS}/debs"/*.deb config/includes.chroot/opt/undercroft-pocket-debs/
mkdir -p config/hooks/normal
cat > config/hooks/normal/0150-pocket-install-apps.hook.chroot <<'EOF'
#!/bin/sh
set -e
export DEBIAN_FRONTEND=noninteractive
dpkg -i /opt/undercroft-pocket-debs/*.deb || true
apt-get install -y -qq -f
rm -rf /opt/undercroft-pocket-debs
EOF
chmod +x config/hooks/normal/0150-pocket-install-apps.hook.chroot

# Real first-boot provisioning for the LIVE/pocket case -- deliberately
# separate from `undercroft-first-boot` below, which is explicitly the
# Calamares-installed-system path and explicitly skips when `boot=live` is
# present. This one is the mirror image: only runs ON the live medium.
cat > config/includes.chroot/usr/local/bin/undercroft-pocket-first-boot <<'SCRIPT'
#!/usr/bin/env bash
# Real first-boot provisioning for Undercroft Pocket's live/pocket-drive
# mode -- runs exactly once per boot session (live medium has no
# persistent /var/lib without a persistence partition, so this is real
# "first boot of THIS session," not "ever," until persistence exists).
set -euo pipefail
grep -q boot=live /proc/cmdline || exit 0

LIVE_USER=user
LIVE_HOME="/home/${LIVE_USER}"
CITADEL_DIR="${LIVE_HOME}/citadel"

# Real bug found and fixed, 2026-11-09: Docker's default overlay2 storage
# driver doesn't reliably work when /var/lib/docker sits on a filesystem
# that's itself an overlay mount -- which `/` genuinely is here, once a
# persistence partition is active (live-boot's own union overlay). Real,
# concrete symptom hit live: pulling/extracting any image with whiteout-
# marked layers (anything that does a real `apt-get clean`-style deletion
# in its own Dockerfile, which is common) fails with "failed to convert
# whiteout file ... operation not permitted" -- and this isn't fixable by
# pre-bundling via `docker load` instead of `docker pull`; both extract
# through the identical containerd/overlay2 codepath. Confirmed via a
# real GitHub issue (dirkhh/adsb-feeder-image#393) describing the exact
# same nested-overlay scenario on a similar embedded Docker image, with a
# real documented working fix: move Docker's own data-root off the
# overlay entirely, onto a real flat filesystem, and switch to the `vfs`
# storage driver (no whiteout/overlay semantics at all).
#
# live-boot already gives us exactly that flat filesystem for free: the
# persistence partition's own raw ext4 content is mounted at
# `/run/live/persistence/<device>` BEFORE the `/` overlay is built on top
# of it (confirmed live via `df -h` -- that mount shows the real ext4
# filesystem directly, separate from the `overlay` mount at `/`). Device
# name isn't assumed (`sda` on this test rig, could be `sdb`/`nvme0n1`/
# anything on real hardware) -- found dynamically instead of hardcoded.
PERSIST_MOUNT="$(mount | awk '/\/run\/live\/persistence\// {print $3; exit}')"
if [ -n "${PERSIST_MOUNT}" ]; then
    mkdir -p "${PERSIST_MOUNT}/docker-data"
    cat > /etc/docker/daemon.json <<EOF
{
  "data-root": "${PERSIST_MOUNT}/docker-data",
  "storage-driver": "vfs"
}
EOF
    systemctl restart docker.service
    # Real wait, not a guess at a fixed sleep: docker.service restarting
    # doesn't mean dockerd has finished re-initializing against the new
    # data-root yet -- poll the real socket instead of racing it.
    for _ in $(seq 1 30); do
        docker info >/dev/null 2>&1 && break
        sleep 1
    done
fi

# Load the three pre-bundled images -- no internet needed, no pull.
for tar in "${LIVE_HOME}/pocket-data/docker-images"/*.tar; do
    [ -f "$tar" ] && docker load -i "$tar"
done

# Fresh, minimal .env written at boot, not baked in: never ship Citadel's
# real home-system .env onto a drive that leaves the house -- it carries
# live secrets (VAULT_API_TOKEN, MEALIE_API_TOKEN among them, confirmed
# directly in that real file before deciding this). A new random token is
# generated per boot session instead, scoped to this drive alone.
# "hardware" deliberately dropped from the profile list below, 2026-11-10:
# that profile is scanner/scanner-bridge/intercept/intercept-backend
# (confirmed directly against modules/hardware/compose.fragment.yml, all
# four under this one profile, not split across several) -- the
# trunked-radio decoder and the 433MHz ISM-band viewer, both requiring a
# real RTL-SDR dongle on /dev/bus/usb. Real finding from the 1TB
# persistence re-test: with the disk-space problem solved, these two were
# the only remaining failures, both for the same reason -- no real (or
# virtual/passed-through) USB SDR hardware exists in this test environment,
# so devices: [/dev/bus/usb] has nothing to bind to. Frank's own call
# rather than chase a sandbox-only limitation: drop the whole profile from
# Undercroft Pocket's default set. Still real, working, genuinely useful
# modules on hardware that actually has an SDR dongle plugged in (a real
# field/vehicle deployment) -- just not a sensible pocket-drive default
# when the operating assumption is "plug this into whatever machine is
# available," which says nothing about what radio hardware happens to be
# attached. Still startable explicitly with a real dongle present: docker
# compose --profile hardware up -d.
#
# Real bug found and fixed, 2026-11-11: this whole comment originally sat
# INSIDE the .env heredoc below, which is deliberately unquoted (`<<EOF`,
# not `<<'EOF'`) so the real ${LIVE_HOME}/${CITADEL_DIR}/${VAULT_TOKEN}
# substitutions further down actually happen -- but that also means bash
# evaluates backticks anywhere in the heredoc body, comment or not. The
# backtick-wrapped code references this comment used for readability
# (matching this file's own established style elsewhere) got silently
# executed as real command substitutions at every boot, confirmed live via
# `undercroft-pocket-first-boot: line 66: hardware: command not found` and
# five identical sibling errors in the journal, one per backtick-wrapped
# word. Fixed by moving the whole comment above the heredoc (a real `#`
# comment here, outside it, where backticks are just characters) instead
# of inside it.
VAULT_TOKEN="$(openssl rand -hex 32)"
cat > "${CITADEL_DIR}/.env" <<EOF
COMPOSE_PROFILES=knowledge,ollama-local,ai,audio,muster
KIWIX_STORAGE_PATH=${LIVE_HOME}/pocket-data/kiwix
OLLAMA_PORT=11500
COCKPIT_PORT=8085
CITADEL_HOST_PATH=${CITADEL_DIR}
BANEWARD_DATA_PATH=${LIVE_HOME}/.local/share/baneward
VAULT_API_TOKEN=${VAULT_TOKEN}
EOF

# Real bug found and fixed, 2026-11-09: docker-compose.yml's `include:`
# parses EVERY module's compose fragment up front -- including ones no
# active profile will ever start -- so an env var a non-included module's
# fragment references (education's KOLIBRI_PORT/KOLIBRI_DATA_PATH,
# recipes' MEALIE_PORT, confirmed as the real, complete list via a direct
# grep across every modules/*/compose.fragment.yml, not guessed) still
# has to resolve to a syntactically valid, non-empty value, or the whole
# `docker compose up` fails at parse time with "invalid spec: empty
# section between colons" -- for every service, not just the excluded
# one. These three never actually start (not in COMPOSE_PROFILES above);
# the values just need to be syntactically valid placeholders.
cat >> "${CITADEL_DIR}/.env" <<EOF
KOLIBRI_PORT=8081
KOLIBRI_DATA_PATH=${CITADEL_DIR}/appdata/kolibri_home
MEALIE_PORT=8097
EOF

# Real bug found and fixed, 2026-11-09: this used to be a single
# `chown -R` across the whole citadel/pocket-data tree. overlayfs can't
# change metadata (ownership included) on a file still living in the
# read-only squashfs lower layer -- it has to copy the ENTIRE file up to
# the writable persistence layer first, whether or not the content
# actually changed. A blanket `chown -R` here forced a full copy-up of
# every byte of the ~16GB of static reference data baked in at build time
# (the Kiwix shortlist, the Ollama model, the Whisper model, the Citadel
# repo clone) just to change ownership on files nothing actually needs
# user-owned -- caught live, confirmed via `df -h` climbing from a few GB
# to 72% of a 20GB test partition and the whole service dying to its own
# 600s timeout before finishing.
#
# Real fix: `docker compose up -d` below already runs as root (this
# whole service does, no User= directive), so Docker itself was never the
# reason for the chown -- root reads/writes any of this regardless of
# ownership. The only things that genuinely need to be user-owned are the
# two tiny files this script itself just wrote (so the live user can see/
# edit them later without needing sudo) and Baneward's real database
# (216MB, not the 16GB class of problem -- Baneward is a native desktop
# app the live user launches directly, running as their own UID, and it
# writes to this file for real -- new field notes, claim verification --
# so it genuinely needs to be user-owned, unlike the big read-only
# reference data sitting untouched under appdata/).
chown "${LIVE_USER}:${LIVE_USER}" "${CITADEL_DIR}/.env" "${CITADEL_DIR}/docker-compose.override.yml" 2>/dev/null || true
chown -R "${LIVE_USER}:${LIVE_USER}" "${LIVE_HOME}/.local/share/baneward" 2>/dev/null || true

# Run as root (this whole service already does -- a systemd oneshot with
# no User= directive), not via runuser as the live user: live-config
# creates that account dynamically at boot, not at image-build time, so a
# build-time `usermod -aG docker user` (added above, defensively
# `|| true`'d) may not even have found a real account to modify yet --
# real risk caught before relying on it, not after a failed boot. Root
# doesn't need docker-group membership at all, so this path never depends
# on whether that usermod actually took.
cd "${CITADEL_DIR}"
docker compose up -d
SCRIPT
chmod +x config/includes.chroot/usr/local/bin/undercroft-pocket-first-boot

mkdir -p config/includes.chroot/etc/systemd/system
cat > config/includes.chroot/etc/systemd/system/undercroft-pocket-first-boot.service <<'EOF'
[Unit]
Description=Undercroft Pocket live-session provisioning (loads images, writes .env, starts Citadel)
After=docker.service network-online.target
Wants=docker.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/undercroft-pocket-first-boot
RemainAfterExit=yes
# Real bug found and fixed, 2026-11-09/10: 600s (10min) was sized for the
# original 3-image-load pipeline. Once the vfs-driver fix (see above)
# unblocked the hardware/ai/muster profiles' real network pulls (5 more
# images) and muster-bridge's local build, the real total first-boot time
# genuinely exceeds 10 minutes -- caught live: the service hit this exact
# timeout and got SIGTERM'd mid-pull, not a real failure. Raised to 1800s
# (30min) at the time -- confirmed WRONG the same way one rebuild later,
# 2026-11-11: a real rebuilt-ISO validation run (fresh, empty persistence
# disk, nothing cached) hit this exact 1800s ceiling too, SIGTERM'd while
# still actively downloading image layers -- the real cold-cache pipeline
# for the current five-module set genuinely runs 70-90+ minutes end to end
# on this test network, confirmed across multiple real runs this whole
# investigation, not a one-off. Guessing a second, larger fixed number
# risks the identical mistake a third time on a slower real connection.
# Real fix: no timeout at all (TimeoutStartSec=0, systemd's own documented
# way to disable it) -- this is a genuine one-time cost (the next boot of
# the same persisted drive never repeats any of this pull/build work, see
# RemainAfterExit=yes above), so there's no real scenario where letting it
# run unbounded is the wrong call, only ones where a second guessed ceiling
# is still too short.
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
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
systemctl enable undercroft-pocket-first-boot.service
EOF
chmod +x config/hooks/normal/0200-enable-services.hook.chroot

# ---------------------------------------------------------------------------
# Calamares autostart -- now opt-in, not automatic. Real change, 2026-11-08:
# this image used to always launch Calamares on the live medium (the
# "install this box permanently" use case this script was originally
# built for). The pocket-drive use case is the opposite: boot on a
# borrowed machine, run entirely from the live medium, leave the host's
# own disk completely untouched when you pull the drive. Autostarting an
# installer onto a system you don't own and have to give back is actively
# wrong there, not just unnecessary -- so the default live boot now goes
# straight to the desktop, and Calamares only launches if the operator
# explicitly asks for it (an `undercroft.install` flag on the kernel
# command line, set by a real second GRUB menu entry, not a guess at an
# undocumented live-boot convention).
#
# Still guarded by the same real `boot=live` check as before (Calamares'
# own unpackfs module copies the ENTIRE live filesystem onto the target
# disk verbatim, autostart file included -- this prevents the installed
# system from ever re-triggering either path), just inverted: you now need
# BOTH "this is the live medium" AND "the operator asked to install."
# ---------------------------------------------------------------------------
mkdir -p config/includes.chroot/etc/xdg/autostart
cat > config/includes.chroot/etc/xdg/autostart/calamares.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=Install Undercroft
Exec=sh -c "grep -q boot=live /proc/cmdline && grep -q undercroft.install /proc/cmdline && pkexec calamares"
Icon=calamares
X-GNOME-Autostart-enabled=true
EOF

# Second GRUB boot-menu entry offering the explicit install path.
#
# Real correction made before running this (expensive) build, not after a
# failed boot: checked live-build's own `binary_grub_cfg` script directly
# rather than guessing a file layout. Two things that guess would have
# gotten wrong: (1) the real user-override path is `config/bootloaders/
# grub-pc` -- used for BOTH grub-pc and grub-efi builds per that script's
# own comment ("This creates the config used for both grub-pc and
# grub-efi"), not a `grub-efi`-named directory, and not `includes.binary`,
# which is never passed through live-build's own variable-substitution
# pass at all; (2) the override is a full-file replacement (the script
# copies the stock template first, then overwrites with this directory's
# contents), not a merge -- so this has to be the complete stock
# grub.cfg, not just a new snippet. Source: stock
# /usr/share/live/build/bootloaders/grub-pc/grub.cfg, confirmed byte-for-
# byte against a real `apt-get install live-build` before copying it here,
# with only the commented-out "Alternate live boot" example (which that
# same stock file ships specifically for this use case) uncommented and
# given the real `undercroft.install` flag. `@KERNEL_LIVE@`/`@INITRD_LIVE@`/
# `@APPEND_LIVE@` are live-build's own placeholder tokens, substituted with
# the real detected kernel/initrd paths by that same script -- not
# hand-guessed paths like `/live/vmlinuz`.
mkdir -p config/bootloaders/grub-pc
cat > config/bootloaders/grub-pc/grub.cfg <<'EOF'
source /boot/grub/config.cfg

# Live boot
@LINUX_LIVE@

menuentry "Install Undercroft (erases this machine's disk)" {
linux @KERNEL_LIVE@ @APPEND_LIVE@ undercroft.install
initrd @INITRD_LIVE@
}
# menuentry "Alternate graphical installer" {
# linux @KERNEL_GI@ @APPEND_GI@ custom options here
# initrd @INITRD_GI@
# }
# menuentry "Alternate textual installer" {
# linux @KERNEL_DI@ @APPEND_DI@ custom options here
# initrd @INITRD_DI@
# }

# Installer (if any)
if @ENABLE_INSTALL_MENU@; then

source	/boot/grub/install_start.cfg

submenu 'Advanced install options ...' --hotkey=a {

	source /boot/grub/theme.cfg

	source	/boot/grub/install.cfg

}
fi

submenu 'Utilities...' --hotkey=u {

	source /boot/grub/theme.cfg

	# Memtest (if any)
	if @ENABLE_MEMTEST@; then
		source /boot/grub/memtest.cfg
	fi

	# Firmware setup (UEFI)
	if [ "${grub_platform}" = "efi" ]; then
		menuentry "UEFI Firmware Settings" {
			fwsetup
		}
	fi

}
EOF

lb build

mkdir -p /output
cp /build/live-image-amd64.hybrid.iso /output/undercroft-sandbox.iso
echo "Real ISO written to /output/undercroft-sandbox.iso"

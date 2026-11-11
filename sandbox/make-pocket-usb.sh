#!/bin/bash
# Writes a built Undercroft Pocket ISO onto a real USB stick, then carves a
# second real partition out of whatever free space is left and formats it
# as live-boot's own persistence overlay.
#
# This is the standard, well-documented way a live-USB-with-persistence
# actually gets built: the ISO itself (iso-hybrid) only ever contains its
# own content -- there is no "bake a second partition into the ISO" step,
# because the ISO's own size is whatever it is and the persistence
# partition's size depends on how big a real USB stick someone plugs in,
# which isn't known until flash time. Confirmed directly against
# live-boot's own source (`/usr/lib/live/boot/9990-overlay.sh`,
# `0001-init-vars.sh`) before writing this, not assumed: the real default
# label live-boot scans for is literally "persistence"
# (`custom_overlay_label="persistence"`), the real config file it looks
# for at that partition's root is `persistence.conf`
# (`persistence_list="persistence.conf"`), and the real boot parameter
# that activates the scan at all is the literal word `persistence`
# (`9990-cmdline-old`'s `persistence)` case) -- already baked into this
# project's default live boot entry via `lb config`'s
# `--bootappend-live "persistence"`.
#
# Usage:
#   sudo ./make-pocket-usb.sh /dev/sdX build-output/undercroft-sandbox.iso
#
# DESTROYS everything currently on the target device. Confirms the real
# device size and asks before doing anything, same as this project's own
# standing "never silently destructive" rule.
#
# Real target drive, decided 2026-11-10: a 1TB USB 3.2 stick (SanDisk
# Extreme PRO class, ~$105-130 at the time of research) -- not guessed at,
# sized from a real measured failure. A 64GB test persistence partition
# filled completely (100%, 0 bytes free) running the full six-module set
# under the `vfs` Docker storage driver before two of its containers could
# even be created (see ROADMAP.md's "vfs fix re-tested at 64GB" entry for
# the full `dockerd`-log-confirmed root cause). `vfs` has no cross-container
# layer sharing and no cross-service image-tag dedup, so real usage is
# meaningfully larger than the sum of each image's own size. The jump from
# 512GB to 1TB in real retail pricing was negligible, so 1TB was chosen
# over continuing to guess at a smaller number.
set -euo pipefail

# Soft minimum, not a hard wall -- a deliberately trimmed, smaller module
# set is a real, legitimate use of this same script (see ROADMAP.md's own
# "scaled-down pocket drive" design principle), so this warns rather than
# refuses. 150GB is this project's own real measured floor for the full
# default six-module set (`knowledge,ollama-local,ai,audio,hardware,muster`)
# under `vfs`, with only modest margin above the 64GB-test's observed 60GB
# used before failing -- not a number pulled from a spec sheet.
RECOMMENDED_MIN_PERSISTENCE_BYTES=$((150 * 1000 * 1000 * 1000))

DEVICE="${1:?Usage: $0 /dev/sdX path/to/undercroft-sandbox.iso}"
ISO="${2:?Usage: $0 /dev/sdX path/to/undercroft-sandbox.iso}"

if [[ ! -b "$DEVICE" ]]; then
    echo "Error: $DEVICE is not a real block device." >&2
    exit 1
fi
if [[ ! -f "$ISO" ]]; then
    echo "Error: $ISO not found." >&2
    exit 1
fi

DEVICE_BYTES="$(blockdev --getsize64 "$DEVICE")"
ISO_BYTES="$(stat -c%s "$ISO")"
DEVICE_GB="$((DEVICE_BYTES / 1000 / 1000 / 1000))"
ISO_GB="$((ISO_BYTES / 1000 / 1000 / 1000))"

echo "Target device : $DEVICE (${DEVICE_GB}GB real capacity)"
echo "ISO           : $ISO (${ISO_GB}GB)"

if (( DEVICE_BYTES <= ISO_BYTES + 1000000000 )); then
    echo "Error: device needs to be at least 1GB larger than the ISO to leave any" >&2
    echo "real room for a persistence partition -- this device doesn't." >&2
    exit 1
fi

PERSISTENCE_BUDGET_BYTES=$((DEVICE_BYTES - ISO_BYTES))
if (( PERSISTENCE_BUDGET_BYTES < RECOMMENDED_MIN_PERSISTENCE_BYTES )); then
    BUDGET_GB="$((PERSISTENCE_BUDGET_BYTES / 1000 / 1000 / 1000))"
    echo ""
    echo "Warning: this device leaves roughly ${BUDGET_GB}GB for the persistence" >&2
    echo "partition, below the ~150GB this project has actually measured the full" >&2
    echo "six-module set needing under the vfs Docker storage driver (see" >&2
    echo "ROADMAP.md) -- fine for a deliberately trimmed module set, but the full" >&2
    echo "default set will likely hit 'no space left on device' again on a drive" >&2
    echo "this size." >&2
fi

echo ""
echo "THIS WILL ERASE EVERYTHING ON $DEVICE. Type 'yes' to continue:"
read -r CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo "Aborted."
    exit 1
fi

echo "Writing the ISO (this takes a while for ${ISO_GB}GB)..."
dd if="$ISO" of="$DEVICE" bs=4M status=progress conv=fsync
sync

echo "Re-reading the real partition table live-boot's own hybrid image just wrote..."
partprobe "$DEVICE" 2>/dev/null || true
sleep 2

# The iso-hybrid image itself defines partition 1 (and an EFI partition --
# real `iso-hybrid` layout includes one). Rather than guess the exact
# partition count/numbering the hybrid image used (varies by exact
# live-build/xorriso version), ask the kernel directly for the real next
# free sector after whatever partitions the hybrid image's own partition
# table already defines.
LAST_END="$(parted -s "$DEVICE" unit s print | awk '/^ *[0-9]/{print $3}' | sed 's/s$//' | sort -n | tail -1)"
echo "Real last-used sector on $DEVICE: ${LAST_END}s -- persistence partition starts right after it."

parted -s "$DEVICE" -- mkpart primary ext4 "$((LAST_END + 1))s" 100%
partprobe "$DEVICE" 2>/dev/null || true
sleep 2

PERSIST_PART="$(lsblk -lnpo NAME "$DEVICE" | tail -1)"
echo "Real new persistence partition: $PERSIST_PART"

mkfs.ext4 -F -L persistence "$PERSIST_PART"

MOUNT_DIR="$(mktemp -d)"
mount "$PERSIST_PART" "$MOUNT_DIR"
echo "/ union" > "$MOUNT_DIR/persistence.conf"
umount "$MOUNT_DIR"
rmdir "$MOUNT_DIR"

echo ""
echo "Done. $DEVICE now boots Undercroft Pocket with a real persistence"
echo "partition -- field data captured on a borrowed machine survives a"
echo "reboot of this same drive, not just this session."

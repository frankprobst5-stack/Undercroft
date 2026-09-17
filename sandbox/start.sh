#!/bin/bash
# Boots whatever ISO is mounted at /iso/undercroft-sandbox.iso in QEMU/KVM
# (falls back to plain TCG emulation if /dev/kvm isn't passed through --
# much slower, but still real, not a fake/mocked boot), with its display
# bridged to a browser via noVNC/websockify.
set -euo pipefail

ISO="${ISO_PATH:-/iso/undercroft-sandbox.iso}"
if [[ ! -f "$ISO" ]]; then
    echo "No ISO found at $ISO -- mount one with: -v /path/to/your.iso:$ISO:ro" >&2
    exit 1
fi

# Optional real virtual disk -- without one, Calamares correctly refuses to
# proceed past "no partitions to install on" (real validation working as
# intended, not a bug), which is fine for a quick boot check but not for
# clicking all the way through a real install. Mount a real qcow2/raw disk
# at /disk/disk.qcow2 to get the full click-through experience.
DISK="${DISK_PATH:-/disk/disk.qcow2}"
DISK_ARGS=()
if [[ -f "$DISK" ]]; then
    echo "Real virtual disk found at $DISK -- attaching, Calamares can install to it for real."
    DISK_ARGS=(-drive file="$DISK",if=virtio,format=qcow2)
else
    echo "No virtual disk mounted -- Calamares will boot but can't complete a real install."
    echo "Mount one with: -v /path/to/disk.qcow2:$DISK"
fi

KVM_ARGS=()
if [[ -e /dev/kvm ]]; then
    echo "Real /dev/kvm present -- using hardware-accelerated KVM."
    KVM_ARGS=(-enable-kvm -cpu host)
else
    echo "No /dev/kvm passed through -- falling back to plain (slow) software emulation."
fi

# Real UEFI firmware, matching Undercroft's own --bootloaders grub-efi
# choice -- a plain BIOS boot wouldn't actually prove the real boot path.
OVMF_CODE=/usr/share/OVMF/OVMF_CODE.fd
OVMF_VARS=/usr/share/OVMF/OVMF_VARS.fd
cp "$OVMF_VARS" /tmp/OVMF_VARS.fd

qemu-system-x86_64 \
    "${KVM_ARGS[@]}" \
    -m 2048 \
    -smp 2 \
    -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
    -drive if=pflash,format=raw,file=/tmp/OVMF_VARS.fd \
    "${DISK_ARGS[@]}" \
    -cdrom "$ISO" \
    -boot d \
    -vnc :0 \
    -vga std \
    -netdev user,id=net0 -device e1000,netdev=net0 \
    &
QEMU_PID=$!

echo "QEMU booting (pid $QEMU_PID) -- starting noVNC on :6080"
websockify --web=/usr/share/novnc 6080 localhost:5900 &
WS_PID=$!

trap 'kill $QEMU_PID $WS_PID 2>/dev/null || true' EXIT
wait $QEMU_PID

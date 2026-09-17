#!/bin/bash
# Boots whatever ISO is mounted at /iso/undercroft-sandbox.iso in QEMU/KVM
# (falls back to plain TCG emulation if /dev/kvm isn't passed through --
# much slower, but still real, not a fake/mocked boot), with its display
# bridged to a browser via noVNC/websockify.
set -euo pipefail

# BOOT_FROM=cdrom (default): boot the installer ISO, same as real USB-stick
# hardware would -- use this to run through Calamares.
# BOOT_FROM=disk: skip the ISO entirely and boot straight from the virtual
# disk -- use this AFTER a real Calamares install to prove the resulting
# system actually boots on its own, not just that Calamares said it
# finished. A real reboot from inside the live session lands back on the
# ISO's own boot menu again otherwise, since CD-ROM stays first in boot
# order -- that's expected, not a failure, but it doesn't prove the real
# installed system boots; this mode does.
BOOT_FROM="${BOOT_FROM:-cdrom}"

# Real, explicit bootindex on every device below -- found live 2026-09-16
# that OVMF's own UEFI boot manager does NOT reliably honor the legacy
# BIOS-style `-boot c|d` flag the way real/legacy BIOS would: with no
# bootindex set, a fresh boot fell through to PXE/network boot attempts
# instead of trying the attached virtio disk at all. Explicit bootindex
# (lower number = tried first) is the real, correct way to control UEFI
# boot order in QEMU, confirmed by reading QEMU's own device docs, not
# guessed after the first attempt failed.
ISO="${ISO_PATH:-/iso/undercroft-sandbox.iso}"
ISO_ARGS=()
if [[ "$BOOT_FROM" == "cdrom" ]]; then
    if [[ ! -f "$ISO" ]]; then
        echo "No ISO found at $ISO -- mount one with: -v /path/to/your.iso:$ISO:ro" >&2
        exit 1
    fi
    ISO_ARGS=(-drive file="$ISO",media=cdrom,if=none,id=cd0 -device ide-cd,drive=cd0,bootindex=1)
elif [[ -f "$ISO" ]]; then
    # Harmless to still offer it as a lower-priority boot device in disk mode.
    ISO_ARGS=(-drive file="$ISO",media=cdrom,if=none,id=cd0 -device ide-cd,drive=cd0,bootindex=2)
fi

# Optional real virtual disk -- without one, Calamares correctly refuses to
# proceed past "no partitions to install on" (real validation working as
# intended, not a bug), which is fine for a quick boot check but not for
# clicking all the way through a real install. Mount a real qcow2/raw disk
# at /disk/disk.qcow2 to get the full click-through experience.
DISK="${DISK_PATH:-/disk/disk.qcow2}"
DISK_ARGS=()
if [[ -f "$DISK" ]]; then
    echo "Real virtual disk found at $DISK -- attaching."
    DISK_BOOTINDEX=2
    [[ "$BOOT_FROM" == "disk" ]] && DISK_BOOTINDEX=1
    DISK_ARGS=(-device ahci,id=ahci0 -drive file="$DISK",if=none,format=qcow2,id=disk0 -device ide-hd,bus=ahci0.0,drive=disk0,bootindex=$DISK_BOOTINDEX)
elif [[ "$BOOT_FROM" == "disk" ]]; then
    echo "BOOT_FROM=disk but no virtual disk mounted at $DISK -- nothing to boot." >&2
    exit 1
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
# VARS_PATH, if mounted, is a real persistent file reused across runs --
# without this, a fresh copy of the factory-default template was made on
# every single boot, silently wiping GRUB's own UEFI NVRAM boot entry the
# moment the container restarted (found live 2026-09-16: a real Calamares
# install completed and rebooted correctly, but the *next* container run
# landed in the UEFI Interactive Shell instead of GRUB, with no boot entry
# to find -- not a Calamares bug, a sandbox one).
OVMF_CODE=/usr/share/OVMF/OVMF_CODE.fd
OVMF_VARS_TEMPLATE=/usr/share/OVMF/OVMF_VARS.fd
VARS="${VARS_PATH:-/vars/OVMF_VARS.fd}"
if [[ -f "$VARS" ]]; then
    echo "Real persisted UEFI vars found at $VARS -- reusing (boot entries survive restarts)."
else
    echo "No UEFI vars mounted at $VARS -- using a fresh template this run only."
    echo "Mount one with: -v /path/to/vars.fd:$VARS  (copy the template once to create it)"
    VARS=/tmp/OVMF_VARS.fd
    cp "$OVMF_VARS_TEMPLATE" "$VARS"
fi

qemu-system-x86_64 \
    "${KVM_ARGS[@]}" \
    -m 2048 \
    -smp 2 \
    -k en-us \
    -drive if=pflash,format=raw,readonly=on,file="$OVMF_CODE" \
    -drive if=pflash,format=raw,file="$VARS" \
    "${DISK_ARGS[@]}" \
    "${ISO_ARGS[@]}" \
    -global isa-fdc.fdtypeA=none -global isa-fdc.fdtypeB=none \
    -vnc :0 \
    -vga std \
    -netdev user,id=net0 -device e1000,netdev=net0,bootindex=99 \
    &
QEMU_PID=$!

echo "QEMU booting (pid $QEMU_PID) -- starting noVNC on :6080"
websockify --web=/usr/share/novnc 6080 localhost:5900 &
WS_PID=$!

trap 'kill $QEMU_PID $WS_PID 2>/dev/null || true' EXIT
wait $QEMU_PID

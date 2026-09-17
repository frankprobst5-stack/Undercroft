# Undercroft hands-on test sandbox

Boots a real Undercroft installer ISO in QEMU/KVM, with its screen bridged to
a browser via noVNC — so you can click through the actual Calamares
installer and desktop yourself, on this machine, before ever writing a real
image to a real USB stick.

Built from real, individually-verified Debian 12 packages (`qemu-system-x86`,
`ovmf`, `novnc`, `websockify`) — no unaudited third-party image.

## Build a real test ISO first

`build-iso.sh` produces a real Debian 12 + Xfce + Calamares live ISO (the
same recipe already hands-on verified — see ROADMAP.md's Phase 0 entry).
Real build time is roughly an hour (Calamares pulls in a full Qt5 stack):

```bash
mkdir -p build-output
docker run --rm --privileged \
    -v "$(pwd)/build-output":/output \
    -v "$(pwd)/build-iso.sh":/build-iso.sh:ro \
    debian:12-slim bash /build-iso.sh
```

This writes `build-output/undercroft-sandbox.iso` (~1.1GB). `build-output/`
is gitignored — the ISO itself never belongs in version control.

## Build the sandbox image (once)

```bash
cd sandbox
docker build -t undercroft-sandbox .
```

## Run it against a real ISO

```bash
# First, create a blank virtual disk to actually install onto (once):
qemu-img create -f qcow2 disk.qcow2 20G

docker run --rm -it \
    --device /dev/kvm \
    -v /path/to/your/undercroft.iso:/iso/undercroft-sandbox.iso:ro \
    -v $(pwd)/disk.qcow2:/disk/disk.qcow2 \
    -p 6080:6080 \
    undercroft-sandbox
```

Leave off the `-v .../disk.qcow2` mount for a quick boot-only check — Calamares
will still launch, it'll just correctly refuse to proceed past "no partitions
to install on" since there's nothing to install onto.

Then open **http://localhost:6080/vnc.html** in a browser and click Connect.
You'll see the real boot sequence, then Calamares (or, after installing,
whatever the resulting desktop looks like) exactly as it would on real
hardware.

`--device /dev/kvm` gives real hardware-accelerated virtualization — leave
it off and it still works, just much slower (plain software emulation).

## Reused later for Gated

Once Gated has real code (Undercroft ROADMAP.md Phase 6), the exact same
sandbox boots the same Xfce desktop — Gated just takes over the browser slot
Firefox ESR occupies today. No separate sandbox needed for that.

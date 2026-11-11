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
    -v "$(pwd)/../brand":/brand:ro \
    -v "$(pwd)/pocket-assets":/pocket-assets:ro \
    debian:12-slim bash /build-iso.sh
```

The `/brand` mount is the ecosystem's own crest artwork (`../brand/`,
alongside `provision.sh` at the repo root) — `build-iso.sh` composites it
into the branded desktop wallpaper baked into the image. `/pocket-assets`
is Undercroft Pocket's own curated offline bundle (Kiwix ZIMs, the Ollama
model, pre-bundled Docker image tars, Baneward's core DB, the Whisper
model, a Citadel repo clone) — real, large (~16GB), and gitignored, so it
has to be staged locally before a build that includes Pocket; see the main
[README.md](../README.md)'s Pocket section for exactly what's in it and
why. Leave this mount off for a Full-only build.

This writes `build-output/undercroft-sandbox.iso` — real size is ~16-17GB
with Pocket's offline bundle baked in, much smaller without it.
`build-output/` is gitignored — the ISO itself never belongs in version
control. Real build time is roughly 90 minutes with Pocket's assets
included (`mksquashfs`'s own `xz` compression of that much data is the
real long pole).

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

To make a completed Calamares install actually bootable on a *later* run
(otherwise GRUB's UEFI boot entry gets wiped every restart — a real bug
found and fixed 2026-09-16), create and mount a persistent vars file:

```bash
cp /usr/share/OVMF/OVMF_VARS.fd vars.fd   # or extract from the image, see Dockerfile
docker run ... -v $(pwd)/vars.fd:/vars/OVMF_VARS.fd ...
```

Then to boot the installed system directly instead of the ISO:

```bash
docker run --rm -it \
    --device /dev/kvm \
    -e BOOT_FROM=disk \
    -v $(pwd)/disk.qcow2:/disk/disk.qcow2 \
    -v $(pwd)/vars.fd:/vars/OVMF_VARS.fd \
    -p 6080:6080 \
    undercroft-sandbox
```

## Testing Undercroft Pocket's own persistence (real gotcha, found live)

The run command above (plain `docker run ... undercroft-sandbox`, no extra flags)
uses the image's own default `/start.sh` entrypoint, which only knows about a
single `disk.qcow2`-style install-target disk and `6080`'s noVNC bridge — it
has no idea about Pocket's own second, pre-formatted `persistence`-labeled
disk, since that's a genuinely different QEMU invocation (an extra
`-device ide-hd` for the persistence disk, host-forwarded ports for Pocket's
own services instead of noVNC). **A real mistake made and caught during this
project's own Pocket validation**: passing a custom qemu command as a bare
`docker run` `CMD` doesn't replace `/start.sh` — Docker runs the image's
`ENTRYPOINT` and `CMD` together, so `/start.sh` silently *ignores* the custom
command and runs its own hardcoded default instead (no persistence disk, no
Pocket ports, and a much smaller `-m` than intended). The fix is
`--entrypoint bash`, which genuinely replaces the entrypoint:

```bash
# Build a fresh sparse persistence disk once (real ext4, "persistence" label,
# the same way make-pocket-usb.sh formats a real USB stick's second partition):
truncate -s 1T persistence-test.raw
mkfs.ext4 -F -L persistence persistence-test.raw
echo "/ union" > /tmp/persistence.conf
debugfs -w -R "write /tmp/persistence.conf persistence.conf" persistence-test.raw

docker run -d --name undercroft-test \
    --entrypoint bash \
    --device /dev/kvm \
    -v "$(pwd)/build-output/undercroft-sandbox.iso":/iso/undercroft-sandbox.iso:ro \
    -v "$(pwd)/persistence-test.raw":/disk/persistence-test.raw \
    -p 5900:5900 -p 18085:8085 -p 18095:8095 -p 18096:8096 -p 11600:11500 \
    undercroft-sandbox \
    -c '
set -euo pipefail
VARS=/tmp/OVMF_VARS.fd
cp /usr/share/OVMF/OVMF_VARS.fd "$VARS"
qemu-system-x86_64 -enable-kvm -cpu host -m 8192 -smp 4 -k en-us \
    -drive if=pflash,format=raw,readonly=on,file=/usr/share/OVMF/OVMF_CODE.fd \
    -drive if=pflash,format=raw,file="$VARS" \
    -drive file=/iso/undercroft-sandbox.iso,media=cdrom,if=none,id=cd0 -device ide-cd,drive=cd0,bootindex=1 \
    -device ahci,id=ahci0 -drive file=/disk/persistence-test.raw,if=none,format=raw,id=disk0 -device ide-hd,bus=ahci0.0,drive=disk0,bootindex=2 \
    -global isa-fdc.fdtypeA=none -global isa-fdc.fdtypeB=none \
    -vnc 0.0.0.0:0 -vga std \
    -netdev user,id=net0,hostfwd=tcp::8085-:8085,hostfwd=tcp::8095-:8095,hostfwd=tcp::11500-:11500,hostfwd=tcp::8096-:8096 -device e1000,netdev=net0,bootindex=99
'
```

Connect with any real VNC client at `localhost:5900` (not noVNC/6080 — this
invocation skips that bridge and exposes raw VNC directly). **Always verify
the override actually took** right after creating the container —
`docker exec undercroft-test ps aux` should show `qemu-system-x86_64` itself
as PID 1 with your real flags, not `/start.sh` still running underneath a
second, differently-configured qemu process.

8GB RAM (`-m 8192`) is a deliberately realistic test floor, not this
project's own dev-machine capacity — see the main README's Pocket section
for why 4GB genuinely isn't enough for the full module set running
concurrently.

## Reused later for Gated

Once Gated has real code (Undercroft ROADMAP.md Phase 6), the exact same
sandbox boots the same Xfce desktop — Gated just takes over the browser slot
Firefox ESR occupies today. No separate sandbox needed for that.

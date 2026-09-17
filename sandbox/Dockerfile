# Undercroft hands-on test sandbox
#
# Boots a real Undercroft installer ISO (built by ../provision.sh's eventual
# live-build/Calamares pipeline -- see ROADMAP.md Phase 2) in QEMU/KVM, with
# its display bridged to a browser via noVNC. Point a browser at
# http://<this-host>:6080/vnc.html to click through the real Calamares
# installer and the resulting desktop exactly like real hardware would show
# it -- before ever writing a real image to a real USB stick.
#
# Deliberately built from real, individually-verified Debian 12 main
# packages (qemu-system-x86, novnc, websockify -- all confirmed present via
# a live `apt-cache policy` before this was written) rather than an
# unaudited third-party image, so it's something this project can actually
# read and maintain, not a black box.
#
# Same base sandbox is meant to be reused once Gated has real code (see
# Undercroft ROADMAP.md Phase 6) -- boot the same Xfce desktop, with Gated
# in the browser slot instead of Firefox ESR, no separate setup needed.

FROM debian:12-slim

RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
        qemu-system-x86 \
        ovmf \
        novnc \
        websockify \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY start.sh /start.sh
RUN chmod +x /start.sh

# noVNC web client (browser-facing)
EXPOSE 6080

ENTRYPOINT ["/start.sh"]

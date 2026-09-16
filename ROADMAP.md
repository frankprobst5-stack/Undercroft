# Undercroft — Roadmap

**The ground everything else stands on.**

Undercroft (formerly "Bedrock," renamed 2026-09-16 over real, live USPTO trademark
conflicts) is the fourth project in the Citadel ecosystem (after Citadel, WayStation, and
Gated): a planned custom appliance OS/install path so Citadel — and eventually Gated — runs
on Raspberry Pi, desktop, and laptop hardware instead of a shared desktop machine. Ships as
two real products from one shared foundation, built and released in that order: **Undercroft
Full** (desktop/laptop, the operator-station profile) and **Undercroft Lite** (Raspberry Pi,
the headless-hub profile) — see the Third planning session below for why that order.

---

## Naming (2026-09-16): renamed from Bedrock after a real USPTO search

Bedrock was locked in on 2026-09-15 (see history below) but had never had a real USPTO
trademark search run against it — same outstanding caveat every name in this ecosystem
carried until checked. Frank asked for real searches on both Gated and Bedrock via
`https://tmsearch.uspto.gov` (the actual government database, not general web search).
Gated came back clear. **Bedrock did not:**

- **Serial 87578826 — "BEDROCK"** (bare word), **LIVE/REGISTERED**, IC 009: "Software
  development kits (SDK); Software for monitoring and..." — owned by **Digital Bazaar, LLC**
  (Virginia). A live, exact-match trademark in a software class.
- **Serial 98532872 — "BEDROCK"** (bare word), **LIVE/PENDING**, IC 042: SaaS software —
  Bedrock Labs, Inc.
- **Serial 97399043 — "BEDROCK"** (bare word), **LIVE/REGISTERED**, IC 042: software
  development/product development — BeanStock Ventures.
- **Serial 79285084 — "BEDROCK"** (bare word), **LIVE/REGISTERED**, IC 009/035/042:
  downloadable software — Business Foundations Limited (New Zealand, registered in the US).
- **Amazon Technologies, Inc.** holds live-pending "BEDROCK AGENTCORE" / "AMAZON BEDROCK
  AGENTCORE" (IC 009/042, AI software) — compound marks, but they tie to Amazon's real,
  extremely well-known "Amazon Bedrock" generative-AI platform. Real-world brand recognition
  around that exact word in tech is a practical confusion risk on top of the formal
  registrations above.
- **BedRock Systems, Inc.** (Delaware, a real embedded/cybersecurity software company) held
  several now-abandoned "BEDROCK"-family marks (BEDROCK WORX, BEDROCK ZEROTRUST
  ARCHITECTURE/DESIGN) — dead now, but real history of commercial use in the
  embedded-OS/security-software space, adjacent to what this project actually is.

Verdict: real, live conflict in the exact software space this project occupies — not a
"someone might get annoyed" risk, a "there is already a registered SDK trademark called
Bedrock" risk. Decision: rename now, while nothing is built, rather than build on a name
with a live SDK trademark and Amazon's own AI-brand recognition sitting on top of it.

**Replacement candidates, checked the same way:**
- **"Grounded"** — rejected. Serial 88881559, bare word, **LIVE/REGISTERED**, IC 009:
  "Downloadable computer game software..." — owned by **Microsoft Corporation** (their real
  Xbox/Obsidian game). A live Microsoft software trademark is about as direct a collision as
  it gets. 414 total results for the term, heavily noisy.
- **"Undercroft"** — chosen. Only **1 result in the entire USPTO database**
  (`OF THE UNDERCROFT`, Serial 87319761, DEAD/CANCELLED, IC 033 — wine), completely unrelated
  field. Keeps the same castle-architecture naming logic as Citadel (stronghold), WayStation
  (waypoint), and Gated (gate mechanism): an undercroft is the vaulted foundation chamber a
  castle or great hall is physically built on — the same "ground everything else stands on"
  role Bedrock was reaching for, without the trademark exposure.

Project folder created fresh at `/home/frank/Desktop/undercroft/` (Bedrock never had its own
folder or repo — it was name-only until this point). All cross-references in
`citadel-ecosystem/ARCHITECTURE.md`, Muster's own ROADMAP.md, and this ecosystem's memory
files updated from Bedrock to Undercroft as part of this rename.

## Naming history (pre-rename, for the record — not rewritten)

**"Bedrock" itself was locked in 2026-09-15** after an earlier candidate, **"Fortress OS,"**
was considered and rejected — "fortress" and "citadel" mean nearly the same thing, so it
would have read as "Citadel OS" with extra steps and blurred the ecosystem's naming logic
(each project owns a *different, specific* piece of the fortress metaphor, not a restatement
of the same one). Two other candidates were considered and passed over at the time for
reasons unrelated to trademark: **"Keep"** (a castle's innermost core — good fit, lost out
for being less immediately self-explanatory) and **"Motte"** (the mound a keep is built on —
thematically close to Undercroft's own role, judged too obscure for a public-facing name at
the time).

## Why this exists

Not a from-scratch OS/kernel — a pre-configured appliance image or install path so Citadel
(and later Gated) runs on dedicated headless hardware instead of a shared desktop machine,
independently identified as Citadel's single biggest remaining reliability gap.

## First planning session (2026-09-16): real device scope, base OS, and a phased build order

Frank's explicit scope for this session: **"im going to want it to run a raspberry pi a
desk top a lap top"** — not a Pi-only appliance OS, and not an x86-only one either. Every
decision below was made against that three-device-class requirement, not a single assumed
target.

**Guiding principle, new**: one universal install path across Raspberry Pi (ARM64), desktop
(x86_64), and laptop (x86_64) — not three separate builds that happen to share a name. The
three original options from the naming/scoping pass are now resolved into a real phased plan
rather than left as an unchosen menu:

1. **Phase 1 (build first): a universal appliance install script.** Runs identically on any
   machine already booted into a base Linux install — Pi, desktop, or laptop — because at
   the shell-script level a booted Debian install is a booted Debian install regardless of
   CPU architecture. This is option 1 from the original scoping (an install script on stock
   Debian/Ubuntu Server), now locked as the real starting point specifically *because* it's
   the one approach that doesn't require solving "how do we build one image for two totally
   different install experiences (SD card flash vs. USB/ISO boot)" before writing a single
   line — that problem gets solved in Phase 2, once Phase 1 has proven what the script
   actually needs to do on real hardware of all three kinds.
2. **Phase 2 (after Phase 1 is proven): a unified flashable-image pipeline.** The real
   "flash it and plug it in" experience, built from the *same* base configuration as Phase
   1's script (so Phase 1 isn't throwaway work) but packaged two ways from one pipeline:
   a `.img` for Raspberry Pi SD cards (`pi-gen`-based, matching Raspberry Pi OS's own
   tooling) and a `.iso` for x86 desktop/laptop USB installers (a preseeded Debian
   installer via `packer`/`live-build`). One shared first-boot/provisioning script, two
   packaging targets — not two unrelated builds that happen to ship together.
3. **Immutable/atomic container-OS base (Flatcar, Fedora CoreOS) — deprioritized, likely
   dropped.** This was left open in the original scoping; resolved now. This ecosystem's own
   established culture is hands-on fixability — WayStation/Citadel's whole "verify, don't
   guess" discipline assumes an operator can SSH in and directly inspect/fix a real problem
   in the field, which is exactly what an immutable OS's Ignition/Butane provisioning model
   makes harder, not easier. The attack-surface benefit is real but doesn't outweigh that
   cost for this audience. Not fully closed off forever, just correctly ordered last and not
   assumed to happen at all unless a real need shows up.

**Base OS decision: Debian 12 (Bookworm), not Ubuntu Server.** Reasoning, not just
preference:
- **Raspberry Pi OS itself is a Debian derivative** (currently tracking Bookworm) — building
  Undercroft's own base on Debian directly means the Pi and x86 targets are running the
  literal same distro version, not two different distros that happen to both run Docker.
  Minimizes divergence between the three device classes this project now explicitly serves.
- **Avoids Ubuntu Server's snapd-by-default install**, which has caused real, documented
  friction with Docker's own networking/iptables setup in other deployments — one less
  moving part on a box meant to run headless and unattended for months.
- **Debian's slower release cadence fits an appliance better than Ubuntu's** — stability over
  novelty is the right tradeoff for something meant to boot itself back up correctly after a
  power blip with nobody watching, not get novel features on a faster cadence.
- **Real, concrete laptop-specific gotcha to build around, not guess past**: Debian's
  installer historically didn't bundle non-free WiFi/Bluetooth firmware by default (unlike
  Raspberry Pi OS, which ships what the Pi needs already) — a real problem for repurposing an
  old laptop whose WiFi chip needs proprietary firmware to associate at all. Debian 12
  changed this — official installer images now include common non-free firmware by default
  specifically to fix this class of problem — but this needs live verification on real
  laptop hardware before being trusted, not assumed correct from memory of Debian's release
  notes.

**Phase 1 scope, concretely — what the install script actually does:**
- Installs Docker Engine + the Compose plugin directly (not assuming Docker Desktop, which
  doesn't exist for headless Debian) — this is a real gap versus Citadel's own `install.sh`,
  which currently only checks whether Docker is already installed and tells the user to go
  install it themselves. Undercroft's script installs Docker itself as its first real job,
  then calls Citadel's own `install.sh` for everything after that point — no duplicated
  installer logic between the two projects, single source of truth stays with Citadel.
- **Makes the box a real unattended appliance**, which a bare `docker compose up -d` doesn't
  by itself: enables and starts the `docker` systemd service so it survives reboots with no
  login required (Docker's own official install already does this on Debian, but it's worth
  stating as an explicit requirement this script verifies rather than assumes); sets a
  predictable mDNS hostname (`citadel.local`, via `avahi-daemon` — the same mDNS mechanism
  already proven elsewhere in this ecosystem, not a new one invented here) so "what's this
  box's address" has one honest answer across all three device classes without needing a
  router's DHCP lease table.
- **Laptop-specific real fix, not a Pi/desktop concern**: disables suspend-on-lid-close and
  suspend-on-idle via `/etc/systemd/logind.conf` (`HandleLidSwitch=ignore`,
  `IdleAction=ignore`) — a laptop repurposed as a portable/vehicle-based Citadel node needs to
  keep serving with the lid shut, which stock Debian's default laptop power behavior actively
  fights against if left unconfigured.
- **Bakes in Gated's future namespace-helper dependency now, cheaply**: installs
  `bubblewrap` as part of the base image even though Gated doesn't exist yet — see
  [[project_gated_browser]]'s own note that Gated's sealed-mode toggle needs exactly this
  tool. Costs nothing to include now; saves Gated from needing its own separate
  first-install step later.
- **Explicitly does NOT attempt Citadel's own Pi-tier service split.** Checked Citadel's own
  ROADMAP.md Phase 1 directly rather than guessing: Citadel has already identified that its
  heavy services (`ollama`, `kolibri`, `open-webui`) are not realistically Pi-plausible and
  named a real fix (a `docker-compose.pi.yml` / Compose-profile split, lightweight tier vs.
  heavy tier) — but that split **has not been built yet**, is still Citadel's own open item,
  not this project's to solve. Real, honest sequencing: Undercroft's installer runs the full
  Citadel stack on every device class for now (Pi included), same as running it on a
  desktop, with a clearly documented caveat that Pi performance for the heavy AI/education
  tier is unproven — exactly the same open question Citadel's own roadmap already names, not
  a new one invented here. Once Citadel ships that tier split, Undercroft's installer gets a
  real, small follow-up: detect Pi-class hardware (or ask) and pass the right Compose profile
  through automatically.

**First-boot, no-keyboard experience — decided, not just floated:** a boot-time console
script (a systemd unit on the physical console, run on every boot) prints the box's mDNS
name, current IP, and a scannable QR code encoding the dashboard URL, using `qrencode -t
ANSIUTF8` to render the QR directly as terminal text — a real, existing `libqrencode`
capability, not something built from scratch. **Needs live verification on real hardware
before being trusted** — matching this ecosystem's own standing rule about claims like this,
same as the Debian non-free-firmware claim above. Worth being precise this is a different
tool for a different job than Keith B. Phillips's `qrcoder` (that one erasure-codes real data
for offline transport; this one just encodes a URL for a phone camera to read) even though
both happen to produce QR codes.

**Update mechanism — decided, deliberately conservative.** A systemd timer periodically
checks Citadel's GitHub Releases for a newer tag than what's installed and sets a flag
Citadel's own dashboard can read and display ("update available") — it never pulls or
applies anything automatically. An unattended appliance that silently updates itself and
fails to come back up has no operator standing next to it to notice or fix it; the actual
update/apply step stays a deliberate, explicit operator action, consistent with WSP/1's own
binding rule elsewhere in this ecosystem that nothing changes silent-and-automatic when a
real failure mode would leave someone stranded.

**License: GPL-3.0-or-later**, matching Citadel and WayStation — no reason to diverge for a
project that's mostly shell scripts and image-build configuration.

## Second planning session (2026-09-16, same day): external architecture review incorporated

Frank brought a detailed external review of the whole "what should Undercroft actually be"
question (written before the rename, using the old "Bedrock" name throughout — read as
applying to Undercroft). Same discipline as every other external review in this ecosystem:
incorporated critically, kept/corrected/adopted, not taken wholesale.

**Independently confirmed, no change needed**: the "this is a distribution, not a
from-scratch OS" framing; Debian as the base; and the Phase-1-inside-Phase-2 build strategy
(prove the script, then wrap it in an image, so nothing gets thrown away) — all match what
the first planning session already landed on, arrived at independently. Good convergent
signal, not new information, so nothing to change here.

**Adopted — genuinely better or new than what was here before:**
- **Sharper reason to kill the immutable-OS option.** The first planning session's own reason
  ("fights this ecosystem's hands-on-debugging culture") is true but soft. The real, harder
  reason: Flatcar/Fedora CoreOS have **no desktop environment at all** — if an operator
  station needs to run WayStation's Tauri GUI and a browser locally (see the new profile
  split below), an immutable container-only OS structurally can't host them. This replaces
  the softer reasoning as the primary justification.
- **`debos`** (Collabora's Debian image builder, one YAML recipe format targeting multiple
  architectures) replaces the vaguer "somehow unify `pi-gen` and `packer`/`live-build`" plan
  from the first session — a real, existing tool built for exactly this problem, worth
  researching first before assuming a custom two-toolchain pipeline is needed. Not yet used
  hands-on in this project — that's real Phase 2 research, not a decision made from memory.
- **RAUC** (A/B system partitions, automatic rollback if a new slot fails to boot, offline
  update bundles deliverable via USB stick) replaces the first session's "just flag that an
  update exists, operator applies it manually" as the real target update mechanism. Strictly
  better for this audience: an operator can still choose *when* to apply an update (nothing
  auto-applies unannounced), but the update itself becomes safe to apply on a machine nobody
  can drive to for weeks, since a failed boot rolls back on its own. Now Phase 4 (below),
  correctly sequenced after the image pipeline exists, not before.
- **Splitting the image work into two phases** — a Raspberry Pi `.img` first, then a
  separate x86 `.iso` — instead of building both from one pipeline simultaneously. More
  realistic incremental delivery; adopted as the new Phase 2/Phase 3 split below.
- **Hardware-profile naming for Raspberry Pi**: Pi 5 (8GB) as the reference "full" profile,
  Pi 4 as a "lite" profile. This names *which hardware SKUs* Undercroft's own install script
  and images target — it does **not** replace or resolve Citadel's own still-unbuilt
  Pi-tier Compose-profile split (which decides *which Citadel services* run in a "lite" vs.
  "full" configuration). Two complementary halves of the same open problem, now both named
  instead of one being silently assumed to cover the other.
- **Tablets scoped out entirely, redirected to Muster.** Correct and worth stating plainly:
  Android/iPad tablets have locked bootloaders and cannot run a custom Linux OS at all — this
  isn't a resourcing choice, it's a hard platform wall. Muster already exists specifically as
  the phone/tablet-reachable browser/PWA piece of this ecosystem (see [[project_muster]]).
  Undercroft's only tablet-shaped surface is x86 Windows-style convertibles, treated as a
  variant of the desktop/laptop target (touch/rotation support), not a fourth device class.
  Naming this now heads off a real scope-creep risk before any work starts on it.
- **Offline GPS time sync via `chrony`, with an optional cheap USB GPS named in the hardware
  profile.** The single best catch in the review — connects two already-real concerns
  neither planning session had tied to the OS layer before: JS8Call/FT8-family digital modes
  need accurate timing to decode at all, and WSP/1's own object revisions and future
  replay-protection work (see [[citadel_ecosystem_architecture]]'s open questions) depend on
  honest timestamps. A grid-down station has no NTP server to correct against — GPS is the
  only offline-capable accurate time source available. Real, adopted, not previously
  considered.
- **Radio-ready udev rules + Direwolf/hamlib/Pat preinstalled**, framed correctly as an
  OS-layer job, not WayStation's: serial/USB device permissions (`dialout`/`plugdev` group
  membership, udev rules for RTL-SDR and Meshtastic devices) are exactly the kind of
  appliance-specific customization that justifies Undercroft being its own project rather
  than "just tell people to install Debian." Adopted.
- **Ship Firefox ESR now in "the Gated slot," swap for real Gated once it exists.** Smart
  de-risking — Undercroft's own build order shouldn't be blocked on Gated's current zero-code
  status. Adopted as Phase 5 (below).
- **First-boot wizard, merged with the existing boot-console QR mechanism rather than treated
  as a separate thing.** The review proposes a first-boot wizard for hardware profile,
  station callsign, and module selection — correct instinct, but on a genuinely headless Pi
  with no monitor there's nowhere to run a console wizard. Resolved: the wizard is a **web
  page served by the box itself**, reached by scanning the QR code the boot-console script
  already prints — one mechanism doing both jobs (address discovery and first-run setup)
  instead of two.

**Corrected — real but overstated claims, not rejections:**
- **"Ollama... available for Debian"** is imprecise. Ollama isn't a native Debian package,
  and in this ecosystem it already runs as one of Citadel's own Docker containers — Undercroft
  doesn't need to install it at the OS layer at all, Citadel's `docker-compose.yml` already
  does. Doesn't change the Debian decision, just corrects the framing.
- **"JS8Call, Pat... available for Debian"** — both real and installable on Debian, but via
  their own vendor-provided repos/`.deb` packages, not Debian's own main archive. Worth
  confirming the exact package sources before Phase 1 build work starts rather than assuming
  `apt install` just works, matching this ecosystem's own verify-don't-guess standard.
- **"WayStation's Linux build already targets that world [Debian]"** — checked directly
  against WayStation's own README: its actual Linux target is **Ubuntu 22.04**, and its
  `.deb`/`.AppImage` builds are produced on Ubuntu 22.04's own toolchain, not Debian's. Debian
  12 (Bookworm) ships a newer glibc than Ubuntu 22.04 (Jammy), so the existing `.deb` should
  install and run cleanly on it — but "should" isn't "verified." Real Phase 1 test item: does
  WayStation's actual released `.deb` install and run correctly on Debian 12, or does
  WayStation's own release pipeline need a Debian-targeted build added.

**Real new architectural clarification, not in either planning session before this: two
device profiles, not one.** The review's push for "a lightweight desktop that still works on
a Pi" surfaces a real distinction that had stayed implicit until now:
- **Headless hub profile** — no desktop environment, no monitor expected, reached entirely
  over the network/dashboard. This is what a Pi acting purely as Citadel's always-on backend
  needs, and it's what most of the first planning session was actually describing.
- **Operator station profile** — the same Citadel backend, plus a real lightweight desktop
  environment so WayStation's Tauri app, a browser (Firefox ESR now, Gated later), and
  Citadel's own dashboard can all run locally for someone sitting at the machine with radio
  gear plugged in directly. This is the natural shape for most desktop/laptop installs, and
  optionally a Pi with a screen attached.

Both profiles share Phase 1's install script and radio-readiness work; they differ only in
whether a desktop environment and the operator-facing apps get installed. Which specific
lightweight desktop environment to use is deliberately **left open, not decided here** — it's
a real design question, not just an engineering one: a conventional choice (Xfce, LXQt) is
lower-effort and more familiar to a family member who isn't technical, while a minimal
Wayland compositor (Sway, Labwc) could be skinned to genuinely match the "NASA command
center" brand direction from [[citadel_ecosystem_architecture]] at real extra engineering
cost. Worth Frank's own call when this phase actually starts, not something to decide
unilaterally here.

**Also real and worth naming honestly, not resolved here**: full-disk encryption is
straightforward on x86 (desktop/laptop) but the Raspberry Pi has no TPM, so Pi encryption
means typing a passphrase at every boot — directly in tension with "unattended appliance
that comes back up on its own after a power blip with nobody there." This is a genuine
security-vs-availability tradeoff tied to Frank's own real deployment context (family homes,
not a data center), not a default either of us should pick silently. Left open for Phase 0
of the revised build order below.

## Third planning session (2026-09-16, same day): Full ships completely before Lite starts

Frank's own real sequencing call: **"would we be better off building the version for laptop
desk top....when done coming out with a lte version for raspberry pi? ... i dont mind having
a full version and a lte version."** This supersedes the "prove it on one Pi and one x86
machine at the same time" framing in the second planning session's build order — good, sound
reasoning, not just a preference:

- **Desktop/laptop is already the easier target** (named as such in the second session's own
  external review) — proving the install script there first means the very first real,
  shippable thing isn't also fighting ARM64/SD-card/thermal unknowns at the same time.
- **It sidesteps Citadel's own unbuilt Pi-tier Compose-profile split as a blocker on shipping
  anything at all.** That split only matters on Pi-class hardware (Citadel's own ROADMAP.md
  names `ollama`/`kolibri`/`open-webui` as the heavy services that don't fit a Pi's resource
  envelope) — desktop/laptop hardware doesn't hit that limit, so **Undercroft Full can ship a
  complete, real release without waiting on Citadel's own open item at all.** Lite becomes the
  point where that dependency actually has to be resolved, which is a cleaner, more honest
  place for it to live than trying to solve it before anything ships.
- **This maps directly onto the two device profiles from the second planning session, it
  doesn't add a third thing to track**: **Undercroft Full = the operator-station profile**
  (desktop environment, WayStation, a browser, radio gear, full Citadel stack) and
  **Undercroft Lite = the headless-hub profile** (no desktop, network-only, trimmed to what a
  Pi can actually carry once Citadel's tier split exists). Same underlying architecture
  already decided, now given real product names and a real shipping order.
- **Most of Phase 1's actual work doesn't get redone for Lite** — Docker install, the
  Citadel `install.sh` hand-off, systemd/mDNS appliance behavior, `bubblewrap` preinstall,
  radio udev rules, and `chrony` GPS time sync are all architecture-agnostic bash that runs
  the same on ARM64 or x86_64. Building Full first proves that shared foundation for real;
  Lite reuses it rather than rebuilding it. What Full does NOT cover, and what Lite's own
  work actually is: real Pi hardware validation, applying Citadel's tier split once it
  exists, and one genuine new Pi-only concern — **SD card wear**. Unlike a desktop/laptop's
  SSD, a Pi's boot media is usually a consumer SD card, which degrades under the kind of
  sustained write load a database/logging-heavy stack like Citadel's produces. Real, named
  Lite-phase research item (log rotation tuned for flash, or recommending USB-SSD boot for
  any serious Lite deployment) — not solved now, correctly deferred to when Lite is actually
  built rather than guessed at speculatively here.

## Revised build order (supersedes the phase list in the second planning session)

1. **Phase 0 — decide**: base (Debian, decided), image tool (`debos` vs. a
   `pi-gen`+`packer`/`live-build` pair, still to research hands-on), desktop environment for
   Full's operator-station profile (open, Frank's call), and the Pi encryption stance for
   Lite (open, real tradeoff named above — doesn't block Full at all, x86 FDE is
   straightforward).
2. **Phase 1 — Undercroft Full, the appliance script.** Built and proven on real x86
   desktop/laptop hardware only — no Pi testing yet, deliberately. Docker install + hand-off
   to Citadel's own `install.sh`, systemd/mDNS appliance behavior, the laptop lid-close fix,
   `bubblewrap` preinstalled for Gated, radio udev rules + Direwolf/hamlib/Pat, `chrony` GPS
   time sync, and the operator-station desktop environment + Firefox ESR in the Gated slot.
3. **Phase 2 — Undercroft Full, x86 USB installer image**, built from Phase 1's proven
   script (`debos` or the fallback pair), with the web-based first-boot wizard (hardware
   profile, callsign, module selection) reached via the boot-console QR code. **Full ships
   here** — a complete, real, usable release, not blocked on anything Pi-related.
4. **Phase 3 — Undercroft Lite, ported to real Raspberry Pi hardware.** Takes Phase 1's
   proven script, validates it on real Pi 5/Pi 4 hardware, strips to the headless-hub profile
   by default (no desktop environment), tackles the SD-card-wear question named above, and
   applies Citadel's own Pi-tier Compose-profile split — **this is the real, honest trigger
   point for that dependency**, not something Lite can start seriously before Citadel ships
   it.
5. **Phase 4 — Undercroft Lite, flashable Raspberry Pi `.img`**, same pipeline tooling as
   Phase 2, packaged for SD card instead of USB.
6. **Phase 5 — offline A/B updates via RAUC**, applied to both Full and Lite once both images
   exist, with update bundles deliverable on a USB stick and automatic rollback if a new slot
   fails to boot.
7. **Phase 6 — Gated replaces the Firefox ESR placeholder** in Full's operator-station
   profile once Gated itself has real code, plus the x86-convertible touch/rotation profile.

This also gives [[citadel_ecosystem_architecture]]'s own open question a real, honestly
sequenced answer: "what is a Pi deployment" gets resolved at Phase 3, once Citadel's own
tier split exists — not before, and not by Undercroft guessing at it independently in the
meantime. WayStation's and Muster's own Pi-performance work can reasonably wait on that same
milestone rather than an earlier, less certain one.

## Nice-to-haves floated for later, not yet decided on

- Extending the boot-splash QR/IP display into Citadel's own dashboard as a persistent
  "connect a new device" panel, not just a one-time boot-console thing.

## Cross-project dependency: Gated's sealed-mode namespace

Gated's online/offline toggle is designed to work via a **Linux network namespace**
(`bubblewrap` or a small helper) for the sealed profile — a route to the LAN subnet only, no
WAN route — not OS-level firewall rules (rejected specifically because firewall rules are a
shared, system-wide resource that could cut off Citadel's own containers on the same
machine; a namespace's missing route is structural instead). Worth remembering when this
project's own design work starts: since this is the OS Gated would eventually run on, it
could bake in clean, pre-configured system-level support for creating and tearing down these
sandboxed namespaces on toggle (a well-defined helper service/permission model for the
privileged parts of that operation) rather than leaving Gated to solve namespace creation and
privilege escalation from scratch on an arbitrary desktop OS. Still Linux-specific — Gated's
own Windows-equivalent mechanism is unresearched, so this doesn't yet cover a Windows story
for this project either, if one is ever needed. Not a decision, just a real
dependency/opportunity to keep in mind.

## Status as of 2026-09-16

Renamed from Bedrock to Undercroft after a real, completed USPTO search found a live
conflict, then given three real planning sessions the same day: an internal one establishing
device scope/base OS/initial phases, a second incorporating a detailed external architecture
review (kept/corrected/adopted explicitly above, not taken wholesale), and a third resolving
the real shipping order — **Undercroft Full (desktop/laptop) ships completely before
Undercroft Lite (Raspberry Pi) work starts**, Frank's own sequencing call, chosen because it
avoids fighting two hardware classes at once and lets Full ship without waiting on Citadel's
own unbuilt Pi-tier split at all. **With this pass, every project in the Citadel ecosystem
has a real plan**: Citadel and WayStation are public and released, Gated and Muster are fully
scoped with private repos, and Undercroft now has a seven-phase build order, a decided base
OS, two named products mapped onto the two device profiles (Full/operator-station,
Lite/headless-hub), and its real dependencies — on Citadel's own unfinished Pi-tiering work,
now correctly sequenced to matter only at Lite's Phase 3, and on two design questions that
are genuinely Frank's call — named explicitly rather than glossed over. From here, per
Frank's own framing, "then it's just building it" — see [[citadel_ecosystem_architecture]]
for the ecosystem-wide phased build order this project's own Phase 1 now slots into.

**Real open items, honestly still open:**
- Citadel's own Pi-tier Compose-profile split — still Citadel's item, not this project's, but
  now only actually blocking at Lite's Phase 3, not blocking Full at all.
- Two decisions that are genuinely Frank's to make, not defaulted here: which desktop
  environment Full's operator-station profile uses (conventional vs. brand-matched but
  higher-effort), and Lite's Raspberry Pi full-disk-encryption tradeoff
  (passphrase-at-every-boot vs. staying unencrypted for true unattended operation).
- Several claims need live verification on real hardware before being trusted, not assumed
  correct from memory: the boot-console QR/IP display, Debian 12's non-free-firmware
  inclusion, WayStation's `.deb` actually installing cleanly on Debian 12, and the exact
  package sources for JS8Call/Pat on Debian.
- `debos` and RAUC are both real, existing tools identified as the right research targets for
  the image-pipeline and update-mechanism phases respectively — neither used hands-on yet.
- Lite's own new real item: SD-card wear under Citadel's write-heavy workload — named, not
  solved, correctly deferred to Phase 3 rather than guessed at now.
- No code written yet. Phase 1 (Full's install script, x86 only) is the concrete next build
  task whenever this project's turn comes up in the ecosystem's phased build order.

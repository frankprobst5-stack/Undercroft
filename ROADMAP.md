# Undercroft — Roadmap

**The ground everything else stands on.**

**Undercroft is the Citadel Ecosystem Linux distribution: a Debian-based, offline-first
operating environment for deploying Citadel, WayStation, Gated, and supported communications
hardware on dedicated Raspberry Pi and x86-64 systems.** (Formerly "Bedrock," renamed
2026-09-16 over real, live USPTO trademark conflicts.) It's the fourth project in the Citadel
ecosystem, after Citadel, WayStation, and Gated. Ships as two real products from one shared
foundation, built and released in that order: **Undercroft Full** (desktop/laptop, the
Workstation profile) and **Undercroft Lite** (Raspberry Pi, the Pi 4/Pi 5 profiles) — see the
Third planning session below for why that order.

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
lightweight desktop environment to use was left open at this point in the planning — **now
decided, see the Fifth planning session below.**

**Also real and worth naming honestly**: full-disk encryption is straightforward on x86
(desktop/laptop) but the Raspberry Pi has no TPM, so Pi encryption means typing a passphrase
at every boot — directly in tension with "unattended appliance that comes back up on its own
after a power blip with nobody there." This is a genuine security-vs-availability tradeoff
tied to Frank's own real deployment context (family homes, not a data center) — **now
decided, see the Fifth planning session below.** It was left open for Phase 0
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

1. **Phase 0 — decide**: base (Debian, decided), desktop environment for Full's Workstation
   profile (**decided: Xfce**, see the Fifth planning session below), Lite's encryption
   default (**decided: unencrypted by default, opt-in at first boot**, see the Fifth planning
   session below), and image tool. **Resolved 2026-09-16, hands-on, not just read about:**
   `debos` — real, actively maintained (`go-debos/debos`, Matrix channel, package listed in
   Debian sid), and proven end-to-end on this actual machine, not just documentation. Pulled
   the official `godebos/debos` container (confirmed it exists and runs), then ran a real
   recipe through it with real KVM passthrough (`/dev/kvm` present, VT-x confirmed via
   `lscpu`, no host `kvm`-group membership needed since the container runs as root):
   `debootstrap` a genuine Debian 12 (bookworm) `minbase` rootfs, `apt`-installed
   `openssh-server`, `image-partition`'d a real 2GB raw disk image (msdos, boot+system
   partitions), `filesystem-deploy`'d the rootfs onto it. Verified the actual output file, not
   just a clean exit code: looped it back with `losetup -P`, mounted the system partition, and
   confirmed a real `/etc/debian_version` (`12.15`) and a real installed `/usr/sbin/sshd`
   binary — genuine proof the deployed filesystem is what was asked for, not an assumption
   from a green build log. One real bug caught and fixed along the way, in the verification
   script itself (not debos): the first pass mounted before the kernel had finished creating
   the loop device's partition nodes, a classic race condition — fixed with `udevadm settle`
   plus a short wait, confirmed clean on rerun. Not evaluated head-to-head against the
   `packer`/`live-build` fallback, since debos cleared every real requirement on the first
   hands-on pass — no reason to research a fallback that isn't needed.
   - **Two real, unresolved design questions this surfaced, needing a decision before the
     actual Undercroft recipe gets written**, not just a debos build config:
     1. **What does "USB installer" actually mean, mechanically?** `debos`'s `image-partition`
        naturally produces a *fixed-size* raw disk image — well-suited to a Pi-style "flash
        and boot" image, not to an interactive installer that partitions whatever arbitrary
        disk a given x86 box happens to have. Real, well-established precedent checked before
        proposing anything: **Home Assistant OS** — a mature, widely-deployed real product
        solving this exact problem (Debian-based appliance OS, generic x86-64 hardware, no
        traditional Debian-installer/Calamares GUI) — ships exactly this way: a pre-built raw
        `.img`, and the documented, recommended real install method is boot a live Linux
        environment (from USB), `dd` the image directly onto the target's internal disk, then
        reboot. **Likely the right model here too**: `debos` builds one raw growable image
        (root partition auto-expands to fill whatever disk it lands on via `growpart`/
        `resize2fs` on first boot — the same well-established technique Raspberry Pi OS
        itself already uses), and "USB installer" means a live/rescue USB plus a real,
        guarded `dd` script (target-disk confirmation before writing, given how unforgiving a
        wrong-disk `dd` is) — not a from-scratch custom Debian-installer build. Frank's call
        before this gets built for real.
     2. **`provision.sh` needs a real split, not a straight port into the image recipe.** Read
        it fresh with this in mind: it currently assumes an already-installed target with a
        real logged-in user (`$SUDO_USER` detection, interactive Workstation-profile prompt,
        git-cloning Citadel to that user's home, handing off to Citadel's own `install.sh`) —
        none of which has a real answer yet at debos build time, since the image is built on a
        generic host before any real operator or hardware exists. The web-based first-boot
        wizard named in this same Phase 2 entry (hardware profile, callsign, module selection,
        reached via the boot-console QR) doesn't exist as code yet at all — checked, nothing
        under this repo matches `*wizard*`/`*first-boot*`. Real split needed: **build-time**
        (bakeable into the image with no real user present — installing every apt package
        Phase 1 already proved, the console-info script + its systemd unit, the not-yet-built
        wizard's own web app) versus **first-boot** (needs the real target hardware/operator
        present — the Workstation-or-headless choice, the laptop-lid fix's battery detection,
        creating the real operator account, cloning Citadel, running Citadel's own
        `install.sh`). The wizard is real, unstarted work, not a small wrapper around what
        already exists.

   **Both resolved, Frank's own call, 2026-09-16 — and the second answer changed the shape of
   the first:**
   - **Question 1: a real interactive installer, not a dd-able image — specifically
     Calamares**, not preseeded `debian-installer`. Real, better fit for the non-expert
     preppers/ham operators this ecosystem serves (graphical, mouse-driven) over d-i's more
     technical text UI, while staying a real, official option: Debian's own **Debian Live
     Project explicitly documents Calamares as a supported live-image installer**, confirmed
     via real research, not assumed. **This changes the toolchain finding above**: `debos`'s
     `image-partition`/`filesystem-deploy` pair builds a *finished* disk image, not a bootable
     *live* ISO with a squashfs Calamares can copy from — the actual native tool for a
     Calamares-based installer is Debian's own **`live-build`** (also real, official, in
     Debian 12 main: confirmed `live-build`, `calamares`, and `squashfs-tools` all resolve
     via a live `apt-cache policy` against `debian:12-slim`, no third-party repo needed).
     `debos` isn't wasted work — Phase 0's original question ("does debos work") is answered
     and verified regardless, and it's still the right, simpler tool for **Phase 4's Lite
     Pi image**, which genuinely wants a plain flashable `.img`, not an interactive installer.
     **Hands-on `live-build`+Calamares verification completed the same day, same rigor as the
     `debos` test — genuinely booted, not just a green build log.** Built a real ~1.1GB
     bootable ISO (`file` confirmed real ISO 9660, bootable), unsquashed the actual image and
     confirmed `usr/bin/calamares` genuinely present (not just requested in a package list),
     then booted it for real in QEMU/KVM: real UEFI (OVMF) firmware, real GRUB menu, real
     Debian 12 boot splash, landing on a real Xfce desktop with **Calamares auto-launching
     exactly as configured**, showing its real welcome screen. First boot (no virtual disk
     attached) correctly showed Calamares' own real validation refusing to proceed ("no
     partitions to install on," "at least 10 GiB required") — genuine, working validation
     logic, not a bug, confirmed by attaching a real 20GB virtio disk and rebooting: the error
     banners disappeared, meaning the disk was correctly detected as a real install target. A
     durable, reusable QEMU+noVNC test sandbox (`sandbox/` — `Dockerfile`, `start.sh`,
     `build-iso.sh`, `README.md`) came out of this, built from the same individually-verified
     Debian 12 packages discipline as everything else here (`qemu-system-x86`, `ovmf`,
     `novnc`, `websockify`, no unaudited third-party image) — lets anyone click through the
     real Calamares installer and desktop in a browser before ever touching a real USB stick,
     and doubles as the real test environment for Gated once it exists (Phase 6): same
     sandbox, same Xfce desktop, Gated just takes the browser slot Firefox ESR holds today.
   - **Follow-up, same day: standalone-boot verification, with Frank actually driving it
     hands-on.** The check above proved Calamares *completes* an install; it didn't prove the
     *resulting disk* boots on its own afterward — a real, distinct question, and a real,
     multi-round debugging session with Frank clicking through the sandbox live surfaced
     several genuine bugs, none of them in Calamares/GRUB/the real install itself:
     - **UEFI NVRAM doesn't survive a container restart by default.** `start.sh` copied a
       fresh factory-default `OVMF_VARS.fd` on every single run, silently wiping GRUB's own
       registered boot entry the moment the sandbox container restarted — a real install
       completed and rebooted cleanly, but the *next* run landed in the UEFI Interactive Shell
       instead of GRUB. Fixed: `VARS_PATH` now accepts a real, persistent vars file that
       survives across runs.
     - **QEMU's VNC server needs an explicit keyboard layout.** Typed commands in the UEFI
       shell came out corrupted in a very specific, diagnostic way (`0` became `o`, `:` became
       `;`) — both Frank's real typing and this session's automated input, confirming it was a
       genuine keymap mismatch in QEMU's VNC keyboard translation, not a typing mistake or an
       automation limitation. Fixed with `-k en-us`.
     - **OVMF didn't recognize a `virtio-blk` disk as a boot candidate without an explicit
       `bootindex`.** Real UEFI firmware does not reliably honor QEMU's legacy BIOS-style
       `-boot c|d` flag the way real/legacy BIOS does — with none set, a fresh boot fell
       through to PXE/network boot attempts instead of trying the attached disk at all. Fixed
       by giving every boot device (disk, CD-ROM, network) an explicit `bootindex` via real
       `-device`/`bootindex=` syntax (confirmed against QEMU's own device docs, not guessed
       after the first attempt failed), and switched the disk to AHCI (`ide-hd` on a real
       `ahci` controller) to match what real x86 hardware Undercroft targets overwhelmingly
       uses, rather than `virtio-blk`.
     - **A real out-of-space failure mid-install, caught and root-caused, not silently
       retried.** The sandbox's own scratch storage (a small RAM-backed tmpfs) filled
       completely during a real Calamares file-unpack step — confirmed by the qcow2 disk
       image's own mtime having stopped advancing minutes earlier despite QEMU still burning
       real CPU, meaning the write path was genuinely wedged, not just slow. Freeing space
       afterward didn't recover it; the fix was moving all sandbox disk images and ISOs onto
       real disk storage (846GB free) instead of the tmpfs, and redoing the install clean.
     - **Calamares' own `unpackfs` module copies the entire live filesystem onto the target
       disk verbatim — autostart files included.** The `calamares.desktop` autostart entry
       written for the *live* session carried straight onto the *installed* system, so
       Calamares re-launched on every real boot of the freshly installed machine. Fixed by
       guarding the autostart's `Exec=` with a real, reliable live-vs-installed check
       (`grep -q boot=live /proc/cmdline` — live-boot's own genuine kernel-command-line
       marker, never present in an installed system's real `grub.cfg`), not a guess.
     - **Cosmetic, Frank's own catch**: QEMU's default machine type includes a virtual floppy
       controller even with nothing attached, showing a "Floppy Disk" desktop icon nobody
       needs anymore. Fixed with `-global isa-fdc.fdtypeA=none -global isa-fdc.fdtypeB=none`
       (confirmed as real, valid QEMU device properties via `-device isa-fdc,help` before
       adding it, not assumed).
     **After all of the above, real, hands-on, unambiguous success**: a fresh install, done
     live with Frank clicking through every Calamares step himself, rebooted into a genuinely
     standalone real Debian 12 + Xfce desktop — no live medium attached to that boot at all,
     confirmed by Frank directly (clean desktop, no floppy icon, no Calamares re-launching).
     This is real, complete, end-to-end proof of Phase 2's actual build→install→boot pipeline,
     not just its individual pieces.
   - **Question 2: this made the "web-based first-boot wizard" mostly unnecessary.** Re-checked
     what it was actually meant to solve — hardware profile, callsign, and module selection —
     against what's real today: Calamares now owns disk partitioning, base install, the real
     user account, and hostname (all of `provision.sh`'s old `$SUDO_USER`-detection problem
     disappears — a real logged-in user exists by the time `provision.sh` would run, same as
     it always assumed). **Module/hardware-profile selection turned out to already be fully
     solved**: Citadel's own `install.sh` already runs real interactive per-module y/n prompts
     with hardware-aware defaults (checked the actual code, not assumed). The one genuinely
     open gap: **station identity (callsign, location, grid, lat/lon) has no setup path at
     all today** — `.env.example` just ships them blank, meant for manual text-editing.
     Frank's call: **add real prompts for these directly to `install.sh`**, alongside its
     existing module-selection questions, rather than building a separate web app/QR-reached
     wizard for a gap this small. A dedicated web-reached wizard stays a real, named option for
     a true walk-up-and-scan headless experience later, but isn't worth building now for a
     problem terminal prompts (already how headless setups get administered, over SSH) solve
     reasonably well today.
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

## Fourth planning session (2026-09-16, same day): reference document incorporated

Frank brought a second detailed reference document (also written before the rename, using
"Bedrock" throughout — read as Undercroft). Same discipline as every other external input in
this ecosystem: incorporated critically, kept/corrected/adopted, not taken wholesale.

**Formal definition, adopted near-verbatim**: *"Undercroft is the Citadel Ecosystem Linux
distribution: a Debian-based, offline-first operating environment for deploying Citadel,
WayStation, Gated, and supported communications hardware on dedicated Raspberry Pi and
x86-64 systems."* This is a real gap the roadmap didn't have filled — three planning
sessions of decisions with no single crisp answer to "what is this, in one sentence." This
is that sentence.

**Confirmed, no new ground**: the "provisioning script is the one source, images are just
packaging" architecture and "don't make RAUC/A-B a Phase 1 requirement" sequencing both
independently match what the first and third planning sessions already decided — good
convergent signal, not new information.

**Adopted — genuinely strengthens the plan:**
- **"Core services" framing.** Reframes Time/Hardware/Security/Storage/Updates from a
  scattered setup checklist into a defined platform contract — apps running on Undercroft
  (Citadel, WayStation, eventually Gated) get accurate time, working radio permissions, a
  firewall, and a real update path without each one solving it independently. This is a
  sharper version of the "what makes this more than Debian with a wallpaper" argument this
  project has needed since the first planning session.
- **A real, correct link between dependable time and WSP/1's replay-resistance gap**
  (see [[citadel_ecosystem_architecture]]'s open questions): replay-protection schemes
  validate timestamps against a trust window, which only means anything if the clock is
  trustworthy. `chrony`+GPS doesn't solve that gap by itself, but it's real infrastructure the
  eventual fix would depend on — a connection neither prior planning session had made
  explicit.
- **A concrete, testable Phase 1/2 definition of done**: Debian → provisioning → Citadel →
  WayStation → hardware → reboot → still works → disconnect the WAN → still works. Adopted as
  the actual acceptance test for Full's Phase 1/2, replacing the vaguer "tested on real
  hardware" language used before.
- **The fuller RAUC update UX** (insert USB → version/signature shown → view changes/install
  → installs to the inactive partition → reboot → health check → active, or automatic
  rollback on a failed health check) — adopted as the real target flow for Phase 5, superseding
  the earlier placeholder description ("a systemd timer just flags that an update exists").
  That placeholder was always a stand-in for the pre-RAUC era; this is what it was standing in
  for.
- **Named hardware/use-case profiles, tied explicitly to a mechanism that already exists**:
  Citadel's own Docker Compose profile system (real, shipped, not speculative) is exactly
  what a named Undercroft profile should resolve to under the hood — a profile isn't a new
  concept to build, it's a friendly name for a specific `COMPOSE_PROFILES` selection Citadel
  already understands.

**Naming overlap resolved, not really a design disagreement**: the reference document names
sub-profiles like "Bedrock Pi Lite" and "Bedrock Pi Station" — written before this project's
own "Undercroft Lite" product name existed, so "Lite" ends up meaning two different things
one level apart (the whole Pi product vs. a Pi-4-class capability tier within it) purely by
timing, not because the underlying idea is wrong. Resolved by naming Lite's own internal
capability tiers by Pi model instead of reusing "Lite"/"Station":
- **Lite — Pi 4 profile**: WayStation, basic Citadel services, radio tooling, GPS/time, no
  local LLM by default.
- **Lite — Pi 5 profile**: fuller Citadel module set, radio stack, SDR, Kiwix, selected
  Ollama models where the hardware can actually carry them.
- **Full's own equivalent is just "Workstation"** — x86 desktop/laptop hardware doesn't need
  a capability sub-split the way Pi 4 vs. Pi 5 does, so Full stays a single profile.

**Reframed, not adopted as a fourth coequal profile**: "Field Station" (Direwolf/APRS,
Pat/Winlink, hamlib, JS8Call, Meshtastic/serial config, aggressive offline defaults) isn't
really a hardware-capability tier alongside the Pi/Workstation profiles above — it's a
different axis, a **use-case module preset** that could apply to either Full or Lite (a
laptop taken into the field is still "Full" hardware-wise, just configured for heavy radio
use). Treated as a preset offered in the first-boot wizard's module-selection step, consistent
with how Citadel's own module system already keeps "which hardware profile" and "which
modules are enabled" as two independent choices rather than flattening them into one list.

## Fifth planning session (2026-09-16, same day): closing out the last two open decisions

Frank asked to work through the two remaining genuinely-his-call items directly, rather than
leave them open indefinitely. Both decided:

**Full's Workstation desktop environment: Xfce.** A real technical constraint tipped this,
not just familiarity: a meaningful slice of real ham radio software (WSJT-X, fldigi,
gpredict, CHIRP) has an X11-first heritage, and native Wayland support across that niche
software category is inconsistent — a minimal Wayland compositor (Sway/Labwc, the
alternative named in the second planning session) would carry real compatibility risk for
exactly the radio tooling this profile exists to run. Xfce also gets most of the "NASA
command center" branding payoff for far less engineering cost than building a compositor
config from scratch — dark theme, custom panel layout, custom wallpaper/icons, Citadel's
dashboard pinned/auto-launched — without abandoning a familiar desktop metaphor for a family
member who isn't technical. The Wayland option isn't wrong forever, just correctly not worth
its cost and risk for this profile's actual job.

**Lite's Raspberry Pi encryption default: unencrypted by default, encryption offered as an
explicit opt-in during first-boot setup.** A real third option surfaced during this
discussion that the second planning session hadn't named: **LUKS with network-unlock via
`dropbear-initramfs`** (SSH into a minimal pre-boot environment over the LAN to type the
passphrase remotely, no physical keyboard needed at the Pi itself). Worth keeping on record
as a real middle-ground technique, but it doesn't solve the actual tension this project
cares about — a human still has to be reachable and willing to act after every reboot, and
the technique is historically unreliable over WiFi-only setups (initramfs network stacks
typically expect wired Ethernet or a static DHCP lease before full networking is up),
adding a real fragility risk on top of not fully closing the gap. Decision: **default to
unencrypted**, consistent with this ecosystem's standing priority — stated repeatedly since
[[user_stakes_and_motivation]] and carried through WayStation's own field-test framing —
that a station surviving a power blip and coming back up on its own matters more than
defending against a physical-theft threat model that doesn't match most real deployments
(family homes, not exposed public infrastructure). Anyone whose own situation calls for
stronger protection can still choose encryption (console-passphrase or the network-unlock
variant) at first-boot setup — Undercroft doesn't force one answer for every deployment.

With both closed, **Phase 0 is now fully decided except for one item**: which image-build
tool actually works (`debos` vs. the `pi-gen`+`packer`/`live-build` fallback), which is real
hands-on research, not a design question — it gets answered by trying it, not by discussion.

## Build log: Phase 1 — first real code (2026-09-16, same day)

**`provision.sh` is written, tested, and pushed.** Real, live-tested, not just written and
assumed correct — the same discipline this whole ecosystem holds every install script to
(see Citadel's own `install.sh` history). Testing method: a real Debian 12 container booted
with actual `systemd` as PID1 (not a plain container, which can't run services at all — a
first attempt against a plain container was correctly rejected as insufficient for exactly
that reason), the script run against it end to end as root with a real non-root operator
account, live service state checked afterward with `systemctl is-active`, not assumed from
the script's own exit code.

**What's actually verified now, not just planned:**
- Every package name in the script — `avahi-daemon`, `bubblewrap`, `qrencode`, `chrony`,
  `gpsd`, `gpsd-clients`, `pps-tools`, `direwolf`, `libhamlib-utils`, `js8call`, `pat`,
  `rtl-sdr` — confirmed to exist and install cleanly on real Debian 12 "bookworm."
- **Real correction to the fourth planning session's own claim**: JS8Call and Pat were
  stated there as needing their own vendor repos, not Debian main — checked directly against
  a live Debian 12 container and that's **wrong**; both are real Debian 12 main-archive
  packages (`js8call` 2.2.0+ds-5, `pat` 0.13.1-1+b4). Worth remembering: that earlier
  "correction" was itself an unverified claim reasoned from general knowledge, not checked —
  exactly the mistake this project's whole culture exists to catch, caught now instead of
  later.
- Docker's install steps match Docker's own current official documentation (fetched live,
  not reproduced from memory) — the newer deb822 `.sources` format, not the older `.list`
  style.
- **`rtl-sdr`'s own Debian package ships real, maintained udev rules**
  (`/lib/udev/rules.d/60-librtlsdr0.rules`) — confirmed by inspecting the actual package
  contents. No hand-authored vendor:product-ID rules needed for RTL-SDR, which is both
  simpler and more correct than guessing at IDs from memory.
- **Meshtastic devices need no dedicated udev rule at all** — they're generic ESP32 boards
  over standard USB-serial chips, and Debian's own stock udev rules already grant `dialout`
  group members access to `/dev/ttyUSB*`/`/dev/ttyACM*`. The real fix is just group
  membership, confirmed by checking Debian's default rules rather than assumed.
- Docker's own service, `avahi-daemon`, and `chrony` were all confirmed **actually running**
  under real systemd after the script finished, not just "the install command didn't error."
- The boot-console script was invoked directly and produces a real, correctly-rendered
  scannable QR via `qrencode -t ANSIUTF8`; its systemd unit installs and symlinks correctly.
- **A real bug found and fixed**: the script originally used `sudo -u "$REAL_USER"` to drop
  privileges for the Citadel git clone — but a minimal Debian install has no guarantee `sudo`
  itself is installed (the operator invoking this script *with* `sudo` says nothing about
  whether the `sudo` binary exists for the script to shell out to internally), and the test
  container hit exactly that missing binary. Fixed with `runuser` (part of `util-linux`, an
  essential package guaranteed on every Debian install) instead.

**What's still honestly unverified — same gaps already named, not new ones:**
- A container test isn't a reboot. Every check above confirms *first-run* behavior; the real
  Phase 1 acceptance test (reboot → still works → disconnect the WAN → still works) needs
  actual hardware, not a long-lived container.
- The laptop lid-switch/idle fix has no laptop or battery to test against here — the
  `compgen -G "/sys/class/power_supply/BAT*"` detection logic is straightforward but unverified
  on real laptop hardware.
- The GPS/chrony refclock stanza is written and inert exactly as designed — still needs a
  real USB GPS to activate and confirm.
- Debian 12's non-free-firmware inclusion and WayStation's `.deb` running cleanly on Debian
  12 both remain exactly as open as the earlier planning sessions left them.

Pushed to `github.com/frankprobst5-stack/Undercroft` as `provision.sh`.

## Build log: Workstation desktop added (2026-09-16, same day)

**Xfce and Firefox ESR are now real, tested parts of `provision.sh`** — the one piece of
Phase 1's scope that was still missing. Asked, not assumed: the script now prompts whether
this install should set up a desktop ("Workstation profile") at all, defaulting to yes since
Full's own reason for existing is the operator-station case, but a genuinely headless x86
box stays a real, supported choice too.

- Real packages confirmed on Debian 12 before writing anything: `xfce4` (4.18),
  `xfce4-terminal`, `lightdm`, `firefox-esr` (140.16.0esr — current, not stale).
- **Verified live, not assumed**: re-ran the full script end to end in a fresh
  systemd-booted Debian 12 container (same method as Phase 1's own testing). Both packages
  actually installed (`dpkg -l` confirmed), and — the real check that matters, not just "the
  install command didn't error" — `lightdm` came back **`enabled`** via `systemctl
  is-enabled`, meaning it will genuinely start a graphical session on next boot, not just
  exist on disk.
- Firefox ESR is deliberately the real "Gated slot" placeholder named in the second planning
  session — Undercroft's own build order isn't blocked on Gated having real code yet (it
  doesn't, beyond this same day's namespace prototype). Swapped for the real thing at Phase 6.
- X11 (Xfce's own Debian 12 default session), not Wayland — matches the fifth planning
  session's own reasoning for choosing Xfce at all: real ham radio software (WSJT-X, fldigi,
  gpredict, CHIRP) skews X11-first, so this isn't a compatibility gap to "fix" later, it's
  the reason Xfce was chosen in the first place.

**Phase 1's install-script scope is now fully built and tested.** What remains for Phase 1
is exactly what remained before this pass: real physical hardware to run the actual
acceptance test on (reboot, disconnect the WAN), the laptop fix, and GPS activation — all
container-test limitations, not missing logic.

## Build log: `provision.sh` folded into the Phase 2 recipe (2026-09-17)

Real work following through on Phase 2's own build-time/first-boot split (see the standalone-
boot verification entry above): `sandbox/build-iso.sh` now bakes in every real OS-layer step
`provision.sh` established for Phase 1, split the same way that entry already decided —
build-time packages/hooks versus a real gated first-boot script — plus the four hardening
items adopted the same day from an external infrastructure review (chrony local-stratum
fallback, ICMP redirect hardening, loose `rp_filter`, the diagnostic tooling bundle).

**Build-time (baked into the image):**
- Full package list: `avahi-daemon`/`libnss-mdns`, `bubblewrap`, `qrencode`, `chrony`+`gpsd`
  stack, `git`, the radio stack (`direwolf`, `libhamlib-utils`, `js8call`, `pat`, `rtl-sdr`),
  and the diagnostic bundle (`tcpdump`, `tshark`, `htop`, `iotop`, `iperf3`, `iproute2`, `iw`)
  — every one confirmed as a real Debian 12 main-archive package via a live `apt-cache
  policy` before being added, not assumed. `js8call`/`pat` in particular turned out to
  already be plain main-archive packages — an earlier note in this project's own docs had
  flagged them as needing a vendor repo; re-checked live and that's not (or no longer) true
  for Debian 12.
- Docker Engine via a real `config/hooks/normal/*.hook.chroot` script (live-build's own real
  chroot-hook mechanism, confirmed against the `live-build` package's actual file manifest
  before relying on it) — the exact same official-repo method `provision.sh` already used,
  not reinvented.
- `/etc/sysctl.d/99-undercroft.conf` (ICMP redirects off, `rp_filter=2`) and
  `/etc/chrony/conf.d/undercroft.conf` (`local stratum 10` fallback + the same inert GPS
  refclock stanza `provision.sh` had) — both real files via `includes.chroot`, both confirmed
  by unsquashing the actual built ISO afterward and diffing their real content byte-for-byte
  against what was written, not just trusting the build log.
- The boot-console QR script and a new `undercroft-first-boot` script (handles the group
  memberships, the Citadel clone, and the laptop-lid fix — everything that genuinely needs a
  real installed system and a real operator, which no longer means `provision.sh`'s old
  `$SUDO_USER`-detection dance now that Calamares creates that real account itself). Both
  gated by the same `boot=live`-absent check the Calamares-autostart fix already established
  as the reliable live-vs-install test; the first-boot script also gated by a real marker
  file so it runs exactly once. Both services' real `systemctl enable` calls run inside a
  second build-time hook — confirmed afterward by finding real `.wants/` symlinks in the
  built image, not assumed to have worked.

**Verified, not just built:**
- Unsquashed the actual built ISO and confirmed every new file's real content matches
  byte-for-byte, and that both new systemd services are genuinely enabled (real symlinks
  present) — not inferred from a clean build log alone.
- Booted the real ISO in the sandbox: still reaches the Xfce/Calamares live session cleanly
  with 500+ new packages added — no regression from Phase 2's original verified state.
- From inside that live session, confirmed Docker isn't just installed but actually running:
  `docker --version` returned a real version string (29.8.1), and `systemctl is-active
  docker` returned `active`. Live remote-keyboard verification of the sysctl/chrony pieces
  specifically proved too unreliable to trust today (the same VNC keyboard fragility flagged
  in yesterday's entry resurfaced on some commands) — not pursued further given the
  byte-for-byte static file check already covers it and `systemd-sysctl` is core, standard,
  and not a component with any real reason to behave differently here.

Real, useful side-finding while researching the external mirror-review document (see Nice-
to-haves below): `ddrescue`, `kismet`, and `kalibrate-rtl` were named in that document as
plain Debian packages but aren't — confirmed live against Debian 12 main/contrib/non-free.
Not used here; noted for whenever that mirror work actually happens.

## Nice-to-haves floated for later, not yet decided on

- **Ecosystem-wide rebrand, assets placed 2026-09-18**: the Citadel Ecosystem's new brand mark
  (tower/compass/globe hexagon) was rolled out across the ecosystem's other projects — real
  master PNG/SVG assets now sit at `brand/undercroft-logo.png`, `brand/undercroft-lockup.png`,
  `brand/undercroft-icon.svg`. **Deliberately not wired into the actual OS yet** — unlike a web
  app's favicon swap, doing this right means a real Calamares `branding.desc`/slideshow theme,
  a GRUB boot menu theme, and a Plymouth boot-splash, none of which exist today (this project
  currently ships stock `calamares-settings-debian` branding, unstyled). That's genuine new
  feature work for its own build pass, not a side effect of a logo swap.
- Extending the boot-splash QR/IP display into Citadel's own dashboard as a persistent
  "connect a new device" panel, not just a one-time boot-console thing.
- **Claude Code as a documented, opt-in convenience** `[DISCOVERY]`, 2026-09-17 — Frank's own
  idea: he's actively running Claude Code (this very tool) on Ubuntu today and wants the same
  option on Undercroft. Technically no real obstacle — Undercroft is plain Debian 12
  underneath, nothing about it would break a standard CLI tool. The one real, unavoidable
  tension: Claude Code needs live internet to reach Anthropic's API at all — no offline mode
  exists — a direct conflict with Undercroft's offline-first identity, though it works fine
  whenever the box *does* have real connectivity (home base, any WiFi), same as any other
  online convenience. **Resolved shape, matching the exact pattern already settled for
  Gated's built-in-AI question**: don't bake in a subscription or pre-baked credentials (not
  actually possible either — there's no way to embed one person's paid Anthropic account into
  a public image for other people to use), instead ship a clean, documented, one-command
  opt-in setup: install Claude Code, sign up for your own Anthropic account, billed to you
  (same real $20/month Pro plan Frank is on), not bundled or resold. Honest, legal, and
  consistent with how this ecosystem already treats every other cloud-dependent convenience —
  informed choice, never a silent default. **Real open item, not yet checked**: whether
  Anthropic's own terms say anything about documenting/bundling Claude Code's install inside a
  distributed OS image like this — worth Frank confirming directly with Anthropic before
  anything ships publicly claiming "Undercroft supports Claude Code," rather than assumed.
- **A curated, CI-built local apt mirror (`aptly`-based)** `[DISCOVERY]`, 2026-09-17 — real,
  externally-suggested idea for a genuine offline gap: no local mirror exists today, so
  `apt install anything-not-preinstalled` simply fails once a real Undercroft box is actually
  off-grid. The core architecture in the suggestion is sound and worth adopting eventually:
  build a curated package snapshot with `aptly` in CI (decoupled from the shipped device,
  correctly avoiding the "mirror silently goes stale forever" trap), bake the resulting
  snapshot into the image, point local apt at it via `file://`. **The specific proposal
  itself needed real correction before use, not wholesale adoption** — checked line-by-line
  against a live Debian 12 archive, not taken on faith:
  - **Three of the ~68 named packages don't exist as written.** `ddrescue` is really
    `gddrescue`; `kismet` and `kalibrate-rtl` aren't in Debian's archive at all (checked main,
    contrib, non-free, non-free-firmware — genuinely absent, would need a third-party repo or
    building from source). This directly undercuts the proposal's own confident claim of
    "validated binaries" — the list itself hadn't actually been checked against a real
    archive.
  - **The size estimate was real, verified by an actual install, not trusted.** A live
    install of the corrected ~65-package set (`--no-install-recommends`, real `dpkg-query`
    sizing, not the doc's own flat "1.2MB average × count" arithmetic) came to **~2.31GB for
    amd64 alone** — meaningfully more than the doc's claimed "1.2GB to 1.8GB per
    architecture," confirming the skew a handful of large packages (`build-essential`'s
    toolchain, `wireshark-common`, `gqrx-sdr`'s GNU Radio dependency chain) actually produce
    against a flat average. A real amd64+arm64 combo at this actual rate would land closer to
    ~4.5GB, not the doc's claimed 3.5GB total.
  - **Shipping a redundant arm64 mirror today is premature.** Undercroft Full (what's
    actually being built right now) is amd64-only; Lite/arm64 doesn't exist yet (Phase 3/4).
    Doubling the mirror for an architecture nothing runs yet is dead weight — scope to amd64
    only until Lite is real.
  - **`[trusted=yes]` on the client apt source is a real, avoidable security regression** —
    it disables GPG verification entirely for local packages. `aptly publish` supports real
    signing; the client should trust one specific real key, not blanket-disable verification.
    Directly inconsistent with this ecosystem's own established practice elsewhere (Gated's
    signed-release plan).
  - **Permanently commenting out the real Debian sources list is the wrong move.** Undercroft
    is offline-*first*, not offline-*only* — the box should still be able to reach the real
    archive whenever it actually has connectivity (home base, any WiFi), not be surgically cut
    off forever after first boot. apt already falls through gracefully when a source is
    unreachable; nothing needs disabling.
  Real, good architecture; not building it today — needs a deliberate, real curated package
  list (Frank's own call, not inherited wholesale from an external template) and the fixes
  above before it's worth the CI investment.

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
conflict, then given five real planning sessions the same day: device scope/base OS/initial
phases, a first external architecture review, a real shipping-order decision (**Undercroft
Full ships completely before Undercroft Lite work starts**, Frank's own call), a second
reference document contributing a formal definition/"core services" framing/named profiles,
and a fifth session closing out the last two open design decisions. **Every real design
question this project had is now decided.** With this pass, every project in the Citadel
ecosystem has a real plan: Citadel and WayStation are public and released, Gated and Muster
are fully scoped with private repos, and Undercroft now has a formal one-line definition, a
seven-phase build order, a decided base OS, two named products with named sub-profiles
(**Full/Workstation, running Xfce**; **Lite/Pi 4/Pi 5, unencrypted by default with
opt-in encryption**), a "core services" architecture (Time/Hardware/Security/Storage/
Updates), and its real remaining dependencies — all on Citadel's own unfinished Pi-tiering
work or on hands-on research, none on further discussion. From here, per Frank's own
framing, "then it's just building it" — see [[citadel_ecosystem_architecture]] for the
ecosystem-wide phased build order this project's own Phase 1 now slots into.

**Phase 1's full install-script scope is now real, tested, and complete**: `provision.sh` —
Docker (real official method), Citadel hand-off, avahi/chrony/bubblewrap/radio tooling, the
laptop fix, the boot-console QR, a GPS time stanza, and — added the same day — Xfce +
Firefox ESR for the Workstation profile, asked rather than assumed. Verified end-to-end
against a real systemd-booted Debian 12 container across two passes: two real bugs/gaps
found and fixed (`sudo` assumed present on a minimal install, wasn't — fixed with `runuser`;
Xfce/Firefox weren't in the script at all — now are, with `lightdm` confirmed genuinely
`enabled` via `systemctl is-enabled`, not just installed), and one real correction to an
earlier planning session's own claim (JS8Call/Pat *are* in Debian main, not vendor-repo-only
as stated in the fourth session). See the Build log above for exactly what's verified versus
still needing real hardware.

**Real open items, honestly still open — all hardware-verification tasks now, no more
missing logic and no more open design questions:**
- Citadel's own Pi-tier Compose-profile split — still Citadel's item, not this project's, and
  only actually blocks Lite's Phase 3, not Full at all.
- A container test isn't a reboot, and there's no laptop or GPS in it either — the real
  Phase 1 acceptance test, the laptop lid-switch fix, the GPS refclock stanza, and confirming
  `lightdm` actually produces a usable graphical session on real hardware (not just
  "enabled") all still need actual hardware, not just a longer-lived container.
- Debian 12's non-free-firmware inclusion and WayStation's `.deb` actually installing cleanly
  on Debian 12 both remain exactly as open as before.
- `debos` and RAUC are both real, existing tools identified as the right research targets for
  the image-pipeline and update-mechanism phases respectively — neither used hands-on yet;
  `debos` vs. the `pi-gen`+`packer`/`live-build` fallback is the one remaining Phase 0 item,
  and it's a research question, not a design one.
- Lite's own new real item: SD-card wear under Citadel's write-heavy workload — named, not
  solved, correctly deferred to Phase 3 rather than guessed at now.
- WSP/1's own replay-resistance gap is still unfixed — dependable time sync is real
  infrastructure toward a future fix, not a fix by itself.

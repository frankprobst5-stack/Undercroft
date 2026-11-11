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

## Build log: branded desktop, and a real fresh-install verification (2026-09-27)

Two real pieces of work, plus one real process finding along the way.

**Branded wallpaper**: both `provision.sh` and `sandbox/build-iso.sh` now composite the
Citadel Ecosystem crest (`brand/undercroft-logo.png`) onto the ecosystem's own canonical
background color and set it as the Xfce wallpaper on first login, replacing Debian's default.
Applied via a runtime autostart script that queries `xfce4-desktop`'s own live property list
rather than a hand-authored xfconf path — wallpaper properties are keyed by the real detected
monitor name, which can't be predicted for arbitrary target hardware.

**Real process finding**: while staging that commit, discovered `sandbox/build-iso.sh` was
still only 74 lines in git — the entire Docker/radio-package/hardening pass this ROADMAP's own
2026-09-17 entry above describes as "committed, verified end-to-end" had only ever been
committed to *this document*, never the actual script (that commit touched `ROADMAP.md` alone,
56 lines, no code). The real code had been sitting uncommitted in the working tree for over a
week. Now finally captured in git for real, bundled into the same commit as the wallpaper work.

**Real fresh-install verification**: with that gap fresh in mind, didn't take the existing
`build-output/fresh-disk.qcow2` test disk on faith either. Booted it and ran
`systemctl is-active docker; docker --version` for real inside it — genuinely came back
`inactive` / `command not found`, no Docker at all. Before treating that as a live regression,
checked `build-output/build.log` (the real build log for the ISO that's supposed to have
produced that disk): it clearly shows `docker-ce`/`docker-ce-cli` installing successfully.
Conclusion: `build-iso.sh` itself is correct; `fresh-disk.qcow2` was a stale artifact, almost
certainly installed from an earlier ISO build that predated the Docker/radio-package work.

Rather than leave that as a guess, did a real fresh Calamares install from the *existing*
`undercroft-sandbox.iso` (no rebuild needed — the ISO was already confirmed correct) onto a
new blank disk, with a properly persisted `OVMF_VARS.fd` this time (the real NVRAM-persistence
requirement this project already found and documented on 2026-09-16). Booted the result
standalone (no installer media attached) and confirmed, cleanly, with no keystroke-garbling
this time (`vncdotool`'s default 10ms inter-key delay was the real cause of the garbled reads
in earlier sessions — fixed by passing `--delay=120`ms):

- `systemctl is-active docker` → `active`
- `docker --version` → `Docker version 29.8.1, build 4a63305`
- `groups` on the real operator account → includes `docker`, `dialout`, `plugdev` (confirms
  `undercroft-first-boot`'s group-membership step ran for real)
- `UNDERCROFT-NEXT-STEPS.txt` present on the desktop (confirms the rest of first-boot ran too)
- `which direwolf js8call` → both present on `PATH`

The old stale disk/vars pair was kept, not deleted, renamed to `*-STALE-2026-09-17.qcow2.bak`
/ `*-STALE-2026-09-17.fd.bak`; the newly verified pair was promoted to the canonical
`fresh-disk.qcow2` / `vars.fd` names so the next person following `sandbox/README.md` gets the
good one by default.

Also added this project's first real root `README.md` and `LICENSE` (GPL-3.0-or-later,
matching Citadel/WayStation), as groundwork for a real public release.

## New real product: "Undercroft Pocket" — a live-boot emergency carry drive (2026-11-08)

Frank's own framing: "if someone could carry citadel on a drive, plug it in to any system in
an emergency, it would be like carrying everything with you" — but then, once sizes were
checked for real, corrected his own first instinct: not everything, a fast scaled-down
version, with the full system staying on the main machine at home. Real design decisions
made in this planning session, each Frank's own explicit call, not assumed:

- **A boot mode, not an install.** Plugging this into a machine you don't own and have to
  give back can never modify that machine's own disk. Checked `sandbox/build-iso.sh`
  directly rather than assuming a new build pipeline was needed: Undercroft already has a
  real, proven `live-build` + squashfs + Xfce pipeline (hands-on QEMU-verified,
  2026-09-16/17) — it just currently auto-launches Calamares on every live boot. **Real fix
  made this session**: Calamares' autostart now requires an explicit `undercroft.install`
  kernel parameter (a second, clearly-labeled GRUB menu entry), not just `boot=live` — the
  default boot goes straight to a running desktop, touching nothing on the host's disk. See
  the build log entry right below this one for the real verification.
- **A deliberately small module set, not "everything."** Checked real sizes before
  recommending anything: Citadel's `kolibri` education library alone is 102GB, Baneward with
  every downloaded photo is 59GB, Citadel's family photo gallery is 8.4GB — "everything"
  is 200GB+ and includes content that shouldn't be exposed to "anyone around" on a borrowed
  machine regardless of size (family photos specifically). **Final module list, Frank's own
  choice**: WayStation, Baneward, Knowledge Base (Kiwix), Off-Grid AI (Ollama), Notes,
  Project Intercept/Trunked Scanner (the real SDR hardware travels in the same pouch), Muster
  (the real answer to "anyone around connects" — it's the phone-facing mobile-ops interface,
  not raw Citadel), and Audio/Whisper (142MB, backs both dictation and whatever Intercept's
  scanner picks up). **Explicitly excluded**: Home Education Hub/`kolibri`, family photos,
  Webcam Motion Detection (needs camera hardware that doesn't travel), Home Monitor
  Matrix/Vigil (nothing to monitor away from the house it watches), Recipes, Homestead
  Logistics/hazard feeds (would only ever be a stale snapshot from whenever the drive was
  last synced at home — real enough to reconsider later, dropped for this first real cut).
- **Persistence model: sync back home, not stateless and not drive-permanent.** A new
  message, a scanner recording, a field note captured on a borrowed machine should make it
  back to the real home Citadel/WayStation/Baneward instances once reconnected — not vanish
  on reboot, and not just accumulate forever on the drive with no path home. Real mechanism
  exists for WayStation's own half already: WSP/1's file/TCP/mesh sync transports, if the
  home station is a trusted peer, already handle exactly this once any reachability exists
  (even WayStation's own mesh radio, no internet required). **Real, named gap, not yet
  solved**: Baneward and Citadel have no equivalent reconciliation protocol between two
  separate instances at all today — WSP/1's own manifest/diff/merge/conflict-flagging model
  is the right shape to extend to them, but that's new design work, not reuse of something
  that already exists for those two.
- **"Anyone around could connect to it"** — real mechanism already named, just scoped
  narrower before: a WiFi captive-portal broadcast (`hostapd`/`dnsmasq`), already in
  WayStation's own backlog for a single community-bulletin page. Broadening its scope to be
  the access method for the whole carried bundle (reached via Muster's own phone-friendly
  interface) is the real decision here, not new infrastructure to invent.

**Foundational assumption real-verified, 2026-11-08: it works.** Ran the actual `lb build`
(hit and fixed one genuine pre-existing bug along the way, unrelated to this change: the
wallpaper-script `cat >` target directory was never `mkdir -p`'d in the original script,
confirmed by re-reading the unmodified file before touching it — fixed, not worked around).
First real correction caught *before* spending the hour-long build on it: the initial
GRUB-override attempt used the wrong file-layout entirely (`config/includes.binary/boot/
grub/`, which live-build never runs its own variable-substitution pass over) and hand-
guessed kernel/initrd paths (`/live/vmlinuz`) that don't exist — caught by reading
live-build's own `binary_grub_cfg` script directly rather than trusting a first guess,
which named the real override path (`config/bootloaders/grub-pc` — shared by grub-pc *and*
grub-efi builds per that script's own comment) and the real placeholder tokens
(`@KERNEL_LIVE@`/`@INITRD_LIVE@`/`@APPEND_LIVE@`) it fills in automatically. Extracted the
real generated `boot/grub/grub.cfg` from the finished ISO (via a throwaway `xorriso`
container, no root needed) and confirmed it byte-for-byte correct: `"Live system (amd64)"`
(default) carries no install flag, `"Install Undercroft (erases this machine's disk)"`
sits as a clearly separate third entry with `undercroft.install` and the real resolved
kernel/initrd paths. **Live-booted it for real**, not just inspected the config: QEMU/KVM
via the existing sandbox, driven directly over raw VNC (`vncdotool`, installed in a throwaway
venv) after the browser-automation layer's keystrokes weren't reaching the VM — a tooling
problem with that interaction path, not with Undercroft itself, confirmed by the extracted
grub.cfg already matching expectations regardless. Pressed Enter on the default entry,
captured a real screenshot ~40s later: a fully booted, stable Xfce desktop ("Debian Live
user," live system clock advancing normally), **zero Calamares window anywhere**, confirmed
stable on a second capture 8 seconds after the first. **One real, honest secondary gap found
along the way, not the thing under test**: the branded Citadel Ecosystem wallpaper (crest on
`#05090d`) never applied — this live session shows the stock Debian Xfce default theme
instead. The `undercroft-set-wallpaper` autostart script that handles this was written and
proven working for the *installed* system's first real login (2026-09-27's verification);
whether it also fires correctly under live-boot's own autologin path is unconfirmed and
worth checking separately — cosmetic, not a blocker for anything above.

**Not yet done, named explicitly**: the actual module-profile build for the drive (which
Docker images/native-app installs get baked in at image-build time so no internet is needed
on a borrowed machine); the WiFi-AP broadcast itself; the Baneward/Citadel sync-home
protocol; the live-boot persistence partition (not yet configured — this test ran with no
persistence at all); and the branded-wallpaper-under-live-boot gap just above.

## Module-profile build: real assets staged and baked in, 2026-11-08

The actual "carry Citadel/WayStation/Baneward with no internet needed" build, following
directly from the item above. Real bill of materials, every number checked against the
real source rather than estimated — one correction made along the way, not silently fixed:
an earlier real-time estimate of Kiwix's total library size ("~26GB total") turned out to
be wrong, caught by checking the real configured `KIWIX_STORAGE_PATH` from Citadel's own
`.env` rather than a stale guessed path — the real total across all 61 archives is 700GB+
(a single `survivorlibrary.com` archive alone is 235GB). Curated a real ~10GB emergency-
reference shortlist instead (`ready.gov`, medical/military-medicine references, `ifixit`,
CDC, compact survival-skill guides) — confirmed with Frank directly rather than picked
unilaterally.

**Real staged assets** (`sandbox/pocket-assets/`, verified byte-for-byte against source,
16GB total): the 10-file Kiwix shortlist; exactly the 5 real blob files `llama3.2:1b`'s own
manifest references (1.3GB — not the whole shared blob store, which also holds two other
pulled models this build doesn't carry); three pre-exported Docker images (`ollama/ollama`,
`kiwix-serve`, `citadel-whisper`, 3.4GB compressed); the real WayStation/Baneward `.deb`
releases; Baneward's lean 216MB core database (no downloaded photo packs — those run to
59GB, outside this build's "fast" goal); the real Whisper model (142MB); a shallow clone of
Citadel's own public repo (153MB).

**Real integration, written into `build-iso.sh`**: `.deb` installs via a build-time chroot
hook (`dpkg -i`, safe at build time — pure filesystem work, no running daemon needed, same
reasoning the existing Docker-install hook already relies on); data assets copied to their
real runtime paths — Ollama's and Whisper's volume mounts are relative paths in Citadel's
own compose fragments (`../../appdata/ollama`, `../../appdata/whisper-models`), not
env-configurable, so the data had to land exactly there; Kiwix's path *is*
env-configurable (`KIWIX_STORAGE_PATH`); Baneward's db goes to its real per-OS Tauri data
directory, confirmed live (not assumed) to be `/home/user/.local/share/baneward/` on a
fresh live boot — the same path both the native Baneward app and Citadel's own read-only
map-tie-in mount expect, one real file, not two copies to keep in sync. A
`docker-compose.override.yml` (Compose's own standard mechanism, zero edits to Citadel's
shared compose fragments) repoints `kiwix-serve` at the 10 real curated ZIM paths directly
(confirmed via its own `--help`: it can take ZIM paths without a `--library` index at all,
avoiding shipping a stale `library.xml` that lists all 61 archives) and pins the `whisper`
service to the pre-loaded `citadel-whisper:latest` image explicitly, so Compose uses it
rather than trying to build from source — which would need internet this build can't
depend on. A new `undercroft-pocket-first-boot` service (the live-boot mirror of the
existing installed-system `undercroft-first-boot`, guarded the opposite way — only runs
*on* the live medium) loads the three image tars, writes a **fresh, minimal `.env` with a
freshly-generated `VAULT_API_TOKEN`** (real security check made before baking anything in:
Citadel's actual home-system `.env` carries live secrets — `VAULT_API_TOKEN`,
`MEALIE_API_TOKEN` — confirmed directly in that file; never copying it onto a drive that
could end up anywhere was a deliberate, explicit decision, not an oversight), and runs
`docker compose up -d` as root (not via `runuser` as the live user — real risk caught
before relying on it: live-config creates that account dynamically at boot, not at
image-build time, so a build-time `usermod -aG docker user` may not even find a real
account to modify yet; root needs no group membership at all, so the actual automated
provisioning never depends on whether that usermod took).

**Real build completed, 2026-11-08 — 16.78GB ISO, matches the 16GB staged-asset estimate.**
Squashfs-extracted and confirmed byte-correct: only `llama3.2:1b`'s real 5 blob files are
baked in, nothing from the other two pulled models — the staging logic itself is right.

**Real boot-verified, and a real architectural gap found in the process — not a clean
pass.** First attempt (6GB test VM) silently failed: the live session logged itself out
before any service came up, discovered only after curling the wrong ports during
verification (an easy mistake to make, caught and corrected: the test container's ports
were deliberately remapped to 18085/18095/11600/18096 to avoid colliding with this host's
own real, already-running Citadel instance on the standard ports — the first verification
pass curled the standard ports by mistake and got real answers *from the host's own Citadel
and Ollama*, not the test VM, which is why Ollama appeared to show all three pulled models).
Re-ran with closer, real-time monitoring (open a terminal immediately after desktop load,
check `journalctl` directly) instead of checking after a long gap — found the real cause
inside 15 seconds of the service starting:

```
Loaded image: citadel-whisper:latest       (ok)
Loaded image: ghcr.io/kiwix/kiwix-serve:latest  (ok)
failed to ingest blob ... no space left on device   (ollama.tar — the big one)
```

**Real root cause**: a live-boot session with no persistence partition configured writes
everything — including every byte `docker load` extracts — into a RAM-backed tmpfs
overlay, not real disk. On a 4GB test VM, there wasn't enough RAM-as-disk to hold Ollama's
extracted image on top of what was already loaded. This recasts the **live-boot persistence
partition**, filed earlier in this document as a nice-to-have for carrying field data home
across sessions, as a **hard prerequisite for Undercroft Pocket to run at all** — not an
enhancement. Reliance on raw RAM alone doesn't hold up either: this ~17GB payload has no
business assuming a real emergency laptop has enough spare RAM to hold it, across the real
range of machines someone might actually borrow (4GB to 32GB+). Also real, caught during
the same diagnosis: this test methodology itself needs to change going forward — booting
from a read-only CD-ROM image (`media=cdrom`, used for every verification so far) can never
exercise a persistence partition at all; testing it for real means writing the ISO to a
writable virtual disk instead, matching how a real USB stick with a persistence partition
carved out actually gets used.

**Not yet done**: designing and building the real persistence partition, and re-verifying
against a disk-backed (not cdrom-backed) test boot once it exists.

## Real persistence partition, designed and built, 2026-11-08

Checked live-boot's own source directly before writing anything (same discipline as the
Calamares-autostart fix) — `/usr/lib/live/boot/9990-overlay.sh` and `0001-init-vars.sh`,
not assumed from memory: the real default label live-boot scans for is literally
`custom_overlay_label="persistence"`, the real config file it looks for at that partition's
root is `persistence_list="persistence.conf"` (format: `dir options` lines, `/ union` for
whole-filesystem persistence), and the real boot parameter that activates the scan at all
is the literal word `persistence` (confirmed in `9990-cmdline-old`'s `persistence)` case,
with `nopersistence` as the real documented opt-out).

**Two real pieces, matching how this actually works in practice — not invented, the
standard live-USB-with-persistence pattern**: the ISO itself can never contain a second
partition sized for persistence, since that size depends on how big a USB stick someone
actually plugs in, unknowable at build time. So: `build-iso.sh`'s `lb config` call gained
`--bootappend-live "persistence"` (activates the scan automatically on every default live
boot, no manual kernel-parameter typing needed), and a new companion script,
`make-pocket-usb.sh`, handles the real USB-flashing half — `dd`s the ISO onto a real device,
finds the real last-used sector the hybrid ISO's own partition table already claimed (not
guessed), carves a second partition from the remaining free space, formats it `ext4` with
the real `persistence` label, and writes the real `persistence.conf`. Confirms device size
and asks before doing anything destructive, matching this project's own standing rule.

**That first persistence build didn't boot at all — a real second build-script bug, found
and fixed the same day, not glossed over.** Tried attaching a separate persistence-labeled
test disk (20GB raw, `mkfs.ext4 -L persistence` + `/ union` in `persistence.conf`) alongside
the proven CD-ROM boot method — real, deliberate choice over retrofitting a partition table
onto the ISO itself: direct byte inspection (no `55 AA` MBR signature, no `EFI PART` GPT
signature at LBA1) confirmed this `--bootloaders grub-efi`-only build has no partition table
at all, just a pure El Torito boot catalog — adding one after the fact risked breaking real-
hardware UEFI boot in a way impossible to verify without physical hardware. The attached-disk
boot failed immediately with `No root device specified` in a BusyBox initramfs shell. Ruled
out explicit `bootindex` (the sandbox's own documented OVMF gotcha — fixed, didn't help),
ruled out AHCI vs. virtio-blk as the bus type (identical failure either way), then ran the
exact same ISO with **no** extra disk at all as an isolation test — **same failure**,
proving the second disk was never the real cause. Traced it to the actual source: GRUB's own
edit mode showed the real default live entry's kernel line was just
`persistence findiso=${iso_path}` — `--bootappend-live` in `build-iso.sh`'s `lb config` call
**replaces** live-build's default live-boot parameters rather than adding to them, and an
earlier version of that line passed only `"persistence"`, silently erasing `boot=live
components quiet splash`. Without `boot=live` specifically, live-boot's own initramfs
root-finding scripts never activate, and the boot falls through to the generic
initramfs-tools fallback that printed the real error. Confirmed live before touching any
file: manually re-added the missing flags in GRUB's own edit screen and booted it — real
working desktop, no rebuild spent on a guess. Only then fixed `build-iso.sh` for real
(`--bootappend-live "boot=live components quiet splash persistence"`, the exact flags
pulled from this same build's own pre-persistence `grub.cfg`, not assumed from live-build's
undocumented defaults) and kicked off a third real build.

Rebuilding now with the real fix. Next real step once it finishes: boot with the ISO (proven
CD-ROM method) plus the already-prepared `persistence-test.raw` disk attached, confirm the
base boot now works with the `persistence` kernel parameter correctly in place, then re-run
the close-monitoring verification that caught the original "no space left on device" failure
— `df -h`/`mount | grep persist`/`systemctl status`/`journalctl` for the pocket-first-boot
service, then curl cockpit/kiwix/ollama/whisper to confirm the whole stack actually comes
up. The real single-USB-stick packaging (one device, two partitions) still needs its own
design pass separately — today's fix proves the persistence *mechanism* works, not yet the
final on-disk layout `make-pocket-usb.sh` assumes.

## Persistence verified for real — and one more real bug found, 2026-11-08/09

**The core hypothesis is definitively proven.** Booted the fixed ISO with the persistence
disk attached and watched `undercroft-pocket-first-boot.service`'s real journal live:

```
Loaded image: citadel-whisper:latest       (ok, as before)
Loaded image: ghcr.io/kiwix/kiwix-serve:latest  (ok, as before)
Loaded image: ollama/ollama:latest         (✅ — this is the one that failed before)
```

`df -h` confirmed the real mechanism: `/dev/sda` (the persistence disk) mounted and
union-overlaid as root (`overlay 20G ... /`), giving the live session real disk-backed
space instead of a RAM-only tmpfs. The exact failure from the previous round — "no space
left on device" loading Ollama's image — is gone. Persistence works.

**A second, distinct real bug surfaced immediately after, caught by watching closely rather
than assuming success once the loads finished.** The service moved on to
`chown -R user:user /home/user/citadel /home/user/pocket-data ...` and then stalled — `df -h`
climbed from a few GB to 72% (14GB/20GB) over several minutes and kept climbing, and the
service ultimately died to its own `TimeoutStartSec=600` guard (`Active: failed (Result:
timeout)`), not a disk-full error, though it was plausibly heading there too. **Real cause,
not guessed**: overlayfs can't change metadata (ownership included) on a file that still
lives in the read-only lower (squashfs) layer — it has to copy the *entire file* up to the
writable upper layer first, whether or not the file's content actually changed. The `chown
-R` call recursively walks the whole `citadel` tree, which still includes every byte of the
~16GB of static reference data baked in at build time (the 10GB Kiwix shortlist, the 1.3GB
Ollama model, Baneward's 216MB db, the Whisper model, the Citadel repo clone) — none of
which needs its ownership changed to work, but a blanket `chown -R` forces all of it to be
duplicated onto the persistence partition anyway, on top of whatever real space Docker's own
extracted image layers already need there. On this 20GB test partition that ran the clock
out before finishing; on a real deployment it's a real risk of exhausting whatever
persistence partition size someone actually carves out.

**Real fix identified, not yet applied or re-verified**: narrow the `chown -R` in
`undercroft-pocket-first-boot` (inside `build-iso.sh`) to only the paths that genuinely need
write access as the live user — `.env`, `docker-compose.override.yml`, and whatever
directories the containers themselves actually write into — not the whole `citadel` tree
including its static, read-fine-as-root reference data. This needs its own build+verify pass
before being called done; not done in this same session given how long this investigation
already ran.

**Honest summary of this whole persistence saga**: three real builds, two real build-script
bugs found and fixed (a missing `mkdir` for the wallpaper script; `--bootappend-live`
silently replacing instead of appending to the default live-boot kernel parameters, wiping
out `boot=live` itself), one real architectural correction (a separate persistence-labeled
test disk instead of risking a retrofitted partition table on an MBR/GPT-less El-Torito-only
ISO), and the core persistence mechanism now genuinely proven working end to end for the
hard part (Docker image loading).

## `chown` fix rebuilt and verified — then a real, deeper Docker/kernel limitation found, 2026-11-09

The `chown` fix (narrowed from the whole citadel/pocket-data tree to just `.env`,
`docker-compose.override.yml`, and Baneward's small db) was rebuilt as a real fourth ISO and
boot-tested with a freshly-reformatted persistence disk. It worked exactly as intended — the
chown step finished in roughly a second instead of stalling on a multi-GB copy-up, and all
three images loaded cleanly again. Progress, genuinely, not assumed.

**Then `docker compose up -d` itself hit a real "invalid spec: empty section between colons"
parse error** — traced to `docker-compose.yml`'s `include:` mechanism, which parses every
module's compose fragment up front regardless of active profile. Three env vars referenced
by modules this build never intended to run (`KOLIBRI_PORT`/`KOLIBRI_DATA_PATH` from
`education`, `MEALIE_PORT` from `recipes`) were unset, producing empty volume/port specs that
fail the whole compose invocation, not just the unused services. Confirmed the complete real
list via a direct grep across every `modules/*/compose.fragment.yml` rather than guessing.
Fixed live in the already-booted test VM first (hand-edited `.env` via `nano` — caught a real
vncdotool bug along the way: `type()` mistypes `_` as `-`, `>` as `.`, `*` as `8`, and `|` as
`\` for this VNC server; worked around it using explicit `key shift-minus` instead of `type`
for underscores) before committing the same fix to `build-iso.sh`.

**With that fixed, a real and more serious problem surfaced: Docker's own `overlay2`
storage/build driver doesn't reliably work when `/var/lib/docker` sits on an already-
overlayed root filesystem** (live-boot's persistence overlay is itself overlayfs — this is a
known class of kernel/storage-driver limitation, not a bug in anything built here). Two real,
distinct symptoms, both traced to the same root cause:

- Pulling `robotastic/trunk-recorder` (part of the `hardware` profile, pulled because this
  test sandbox happens to have internet — a real offline deployment would simply fail the
  pull, masking this deeper issue) failed with `failed to convert whiteout file
  "var/lib/apt/lists/.wh.auxfiles": operation not permitted` — a real nested-overlayfs
  whiteout-handling limitation. Confirmed this isn't fixable by pre-bundling the image as a
  tar instead of pulling it: `docker load` and `docker pull` both extract layers through the
  identical containerd/overlay2 codepath, so the same image would fail either way.
- `muster-bridge` (part of the `muster` profile, needed to build locally from
  `appdata/muster-bridge/Dockerfile`, a `python:3.10-alpine` base) failed differently but for
  the same reason: BuildKit's own cache-mount step
  (`mount source: "overlay" ... err: invalid argument`) can't create a fresh overlay mount on
  top of the already-overlayed root.

**Real, surprising finding, not assumed**: removing `muster` from `COMPOSE_PROFILES` did
**not** stop the muster-bridge build from being attempted — Docker Compose's BuildKit "bake"
step resolves every `build:` stanza from every `include:`d module fragment up front,
independent of which profiles are active. Trimming `.env` alone can't avoid this; avoiding it
would mean not `include:`ing that module's fragment into the pocket build's
`docker-compose.yml` at all — a real, deliberate divergence from Citadel's shared compose
file, not a config tweak.

**Honest, current scope of what's actually proven to work in this architecture**: `kiwix-serve`,
`ollama`, and `citadel-whisper` — all three pre-bundled via `docker load`, none needing a
local build or a whiteout-heavy pull — are the real, confirmed-safe set. `trunk-recorder`/
`rtl_433` (hardware/Project Intercept) and `muster-bridge` (muster) both hit the real overlay
limitation and are not currently viable in this live-boot-with-persistence-overlay
architecture as built. `open-webui` (ai profile) was never individually tested but is a
similar pull-based image, so should be assumed at the same real risk until proven otherwise.

**Not yet done, a real open design decision, not a quick fix**: whether to (a) permanently
scope the pocket build down to just knowledge/ollama-local/audio (dropping Project Intercept
and Muster from the pocket drive entirely, a real, meaningful capability cut), (b)
investigate whether Docker's `vfs` storage driver (no overlay/whiteout semantics at all,
slower and more disk-hungry, but a real documented alternative for exactly this nested-
filesystem class of problem) sidesteps this cleanly, or (c) reconsider the persistence
mechanism itself. This needs a real decision, not something to keep patching live — logged
honestly here rather than silently worked around.

## `vfs` storage driver fix — validated, the whiteout problem is genuinely gone, 2026-11-09

Found a real, independently-documented fix via web research (`dirkhh/adsb-feeder-image#393`
on GitHub — someone hit the identical nested-overlayfs scenario on a similar embedded Docker
image): move Docker's own data-root off the overlay root entirely, onto a real flat
filesystem, and switch to the `vfs` storage driver. live-boot already provides exactly that
flat filesystem for free — the persistence partition's own raw ext4 content is mounted at
`/run/live/persistence/<device>` *before* the `/` overlay is built on top of it, confirmed
directly via `df -h` rather than assumed. Implemented in `undercroft-pocket-first-boot`:
discovers the real persistence mountpoint dynamically (never hardcodes a device name), writes
`/etc/docker/daemon.json` with `data-root` pointed there and `storage-driver: vfs`, restarts
`docker.service`, and polls `docker info` for real readiness before proceeding — rather than
guessing at a fixed sleep.

**Validated live before committing to a rebuild** (the same fast-iteration discipline used
for the earlier `bootappend-live` fix): manually reconfigured the already-booted test VM's
Docker daemon by hand (hit and worked around a fully systematic vncdotool bug along the
way — `type()` silently drops the Shift modifier for every shifted character, so `_` becomes
`-`, `{`/`}` become `[`/`]`, `"` becomes `'`, `:` becomes `;`; the real fix is explicit
`key shift-<literal character>` calls instead of `type()` for every non-alphanumeric),
confirmed `docker info` showed the real new `Docker Root Dir`, reloaded all three pre-bundled
images into the fresh vfs-backed store, then ran `docker compose up -d` with the **full
original six-module list** (`knowledge,ollama-local,ai,audio,hardware,muster`) — the one that
previously failed immediately on `trunk-recorder`'s whiteout error.

**Real result: the whiteout/overlay-build problem is completely gone.** `rtl_433` and
`python:3.10-alpine` (the dependency `muster-bridge`'s build needs) both pulled and extracted
cleanly — real images that previously failed outright now succeed. What stopped the run
instead was `write ... GetImageBlob...: no space left on device` — genuine disk exhaustion,
not a kernel/storage error. Real, understood cause: `vfs` deliberately has no layer sharing or
copy-on-write dedup (that's the whole point — it sidesteps overlay/whiteout semantics
entirely), so every image's real, full, uncompressed size counts separately — confirmed
directly: `ollama/ollama` alone went from needing ~3.4GB (compressed tar) under the old
overlay2 setup to **4.88GB on-disk** under vfs. The 20GB test partition, built for the
leaner overlay2-based original design, was simply too small once `trunk-recorder`,
`open-webui`, `rtl_433`, and their dependencies all needed their own full, undeduplicated
copies on top of the three core images.

**Honest, current state**: the architectural blocker is solved; what's left is a real sizing
question, not a design question. A production persistence partition needs to be meaningfully
larger than 20GB to hold all six modules under `vfs` — not yet measured exactly how much
(the test run didn't reach a clean finish to measure the real total), but comfortably budget
for a `vfs`-sized Ollama (~4.9GB) plus full, undeduplicated copies of `open-webui`,
`trunk-recorder`, `rtl_433`, and their dependency images, well above the 20GB tested. Real
next step: resize the test persistence disk larger (`persistence-test.raw`, currently 20GB —
try 64GB) and rerun the exact same full-module-list test to confirm a clean, complete finish
with `docker compose ps` showing every service running and all real curl checks passing, then
do one final production rebuild with the `vfs` fix baked in (already written into
`build-iso.sh`) and a correspondingly-sized real persistence partition in
`make-pocket-usb.sh`.

## `vfs` fix re-tested at 64GB — conclusive result: the whiteout bug is gone, but `vfs`'s real disk cost is worse than first measured, and a production sizing decision is now required

Direct follow-up to the entry above. Resized `persistence-test.raw` from 20GB to 64GB (real
sizing headroom over the earlier measured ~4.9GB-per-large-image cost) and reran the exact
same full six-module `docker compose up -d` (`knowledge,ollama-local,ai,audio,hardware,muster`)
against a fresh boot of the same ISO, start to finish, with zero manual intervention for the
first ~70 minutes — the automated `undercroft-pocket-first-boot.service` ran on its own,
confirmed via real log lines (`journalctl`), not assumed.

**One real bug found and fixed before this run, unrelated to `vfs` itself**: the automated
first-boot service's own `TimeoutStartSec=600` (10 minutes) was too short for the real
six-module pull+build pipeline once `vfs` genuinely unblocked network pulls for every image
that previously failed outright — systemd killed the service mid-pull with `SIGTERM`
(`Result: timeout`, confirmed via `systemctl status`). Fixed in `build-iso.sh` to
`TimeoutStartSec=1800` (30 minutes). **Not yet verified in a rebuilt ISO** — this run's own
data came from manually resuming the exact same `docker compose up -d` command directly in
the still-running test VM after the service was killed, rather than waiting through another
full ISO rebuild cycle just to confirm the timeout number. Real next-build item: confirm the
automated service completes unattended with the new timeout.

**The original question is now definitively answered: yes, `vfs` fully fixes the whiteout bug,
for both pulls and local builds.** Concrete, repeated proof, not a one-off:
- `robotastic/trunk-recorder:latest` — the image that had failed on every single prior attempt
  under `overlay2` with `failed to convert whiteout file ... operation not permitted` — pulled
  and extracted cleanly, confirmed **twice** across this run (a fresh pull from the automated
  first-boot attempt, then again after the manual resume).
- **Local BuildKit builds work too, not just pulls — the untested half of the original
  question.** `citadel-vault-api` and `citadel-scanner-bridge` (both local Dockerfile builds
  that `muster-bridge`'s own build had previously failed on, same root cause, under
  `overlay2`) both completed a full multi-stage build — `apk add`, `pip install`, `COPY`,
  `exporting to image`, `naming to docker.io/library/...` — with zero overlay/whiteout errors
  of any kind. This is real, new confirmation beyond what the 20GB test proved: the original
  fix holds under BuildKit's own build-cache-mount codepath, not just plain image pulls.

**New, more severe finding than the 20GB test surfaced: `vfs` has no cross-container layer
sharing at all — not just no cross-*image* dedup, no cross-*container* dedup either.** The
20GB test's own conclusion ("every image's full size counts separately") turned out to
understate the real cost. Two concrete, measured confirmations from this run:
- **Two services referencing the identical image tag each triggered a full, independent
  pull.** `ghcr.io/open-webui/open-webui:main` is referenced by two separate services in the
  module set; under `overlay2` this would share one cached layer set. Under `vfs`, both pulls
  ran to completion independently — one finished in 2215.0s, the other's progress line was
  still climbing past 1500s+ when checked mid-run — real, measured evidence that `vfs` doesn't
  even dedup two pulls of the *same exact tag* within one `compose up`, let alone across
  different images.
- **Every container create is a full, uncompressed copy of its image's entire filesystem —
  not just every image.** This is the real mechanism, confirmed directly against
  `dockerd`'s own logs, not inferred: `docker ps -a` showed several containers sitting in
  `Created` (not `Started`) state for 10+ minutes after their images had already finished
  building/pulling, and `df -h` on the persistence partition climbed in real, large, bursty
  jumps (36G → 44G in under 5 minutes) *during container creation*, not during the pull phase
  — i.e. the copy cost is paid again, per container, on top of the pull/build cost already
  paid once per image. `vfs`'s own documented design (full copy-on-create, no CoW, by design —
  that's the entire mechanism that sidesteps overlay/whiteout semantics) was previously noted
  abstractly in the 20GB entry; this run is the first time its real magnitude was actually
  measured end-to-end against a multi-service stack instead of a single large image.

**Real, conclusive failure mode: the 64GB partition filled completely (100%, 0 bytes free)
before the stack could finish starting, and `docker compose up -d` ended with two explicit,
real `ENOSPC` errors — not a hang, not a timeout.** Final state, directly observed:
- `df -h` on the persistence partition: `63G 60G 0 100%` — genuinely full, not near-full.
- `dockerd`'s own log, the real root cause: `Handler for POST /containers/create returned
  error` / `error-response="no space left on device"` for both `name=citadel-ollama` and
  `name=citadel-webui` — HTTP 500, confirmed via `journalctl -u docker`.
- `docker compose up -d` itself returned a clean, explicit failure report rather than hanging
  forever: `[+] up 40/42` with two named failures (`✗ service:open-webui:1`,
  `✗ service:ollama:1`, both `Error response from daemon: no space left on device`) — real,
  legible compose-level error reporting, not a silent stall. The 40/42 that *did* succeed
  covers both images pulled, both images built, the network, and every other container's
  `create` step.
- **The one surprising, important consequence**: because `citadel-ollama` and
  `citadel-webui`'s own `containers/create` calls failed outright, `docker compose up -d`
  never reached its *start* phase for anything at all — `docker ps` (running containers,
  no `-a`) returned **zero rows**. Every other container that successfully reached `Created`
  state (`citadel-whisper`, `citadel-scanner`, `citadel-kiwix`, `citadel-cockpit`,
  `citadel-vault-brain`, `citadel-scanner-bridge`, `citadel-intercept`,
  `citadel-intercept-backend`) stayed in `Created`, never `Started` — compose's own real
  behavior is create-everything-then-start-everything, so two failed creates blocked the
  whole stack from ever coming up, not just the two services that actually ran out of room.
  Real, honest implication: a partial-capacity failure under `vfs` isn't "everything except
  the big services works" — it's "nothing runs," full stop, until there's enough room for
  the *entire* module set's `vfs` footprint, images and per-container copies both.

**Honest current state: the architectural fix (switching to `vfs`) is completely proven and
done. What's left is a real, now-measured sizing problem, not a design question.** The full
six-module set's real `vfs` disk footprint exceeds 64GB before even reaching the start phase —
meaningfully worse than the 20GB test's own back-of-envelope estimate, because that estimate
only accounted for per-*image* cost and missed the per-*container* copy cost and the
no-same-tag-dedup cost entirely. Real options for the next pass, not yet chosen:
1. **Size the real target drive larger** — budget for full image cost *plus* full
   per-container copy cost *plus* no cross-service tag sharing; 64GB clearly isn't enough for
   the current six-module set, true capacity needed is still unmeasured since this run didn't
   reach a clean finish.
2. **Trim the default pocket module set** — the original design principle from this whole
   project ("drop whatever isn't needed in a real emergency, keep a fast scaled-down version")
   already argues for this independent of the `vfs` finding; revisit whether all six modules
   genuinely need to ship by default on the portable drive versus a smaller core set.
3. **Investigate `fuse-overlayfs`** as a storage driver — unlike `vfs`, it still provides real
   copy-on-write layer semantics while running entirely in userspace (no kernel overlayfs
   module involved), which may sidestep the original whiteout bug (a kernel-level nested
   overlayfs limitation) without paying `vfs`'s full-copy cost. Not yet researched hands-on —
   a real, named option for the next investigation, not a decision.
4. **Prune aggressively between pulls** (`docker image prune`, `docker builder prune`) to keep
   the working set smaller during the build/pull phase, even if the final running footprint
   stays large — reduces peak usage, doesn't reduce the real steady-state requirement.

Real next step, Frank's own call before more build cycles get spent: pick one of the above
(or a combination) rather than continuing to resize the test disk upward by guesswork.

## Real target drive decided: 1TB, not a trimmed module set or a driver swap (2026-11-10)

Frank's own call on the four options the entry above left open: buy enough real drive capacity
to stop guessing, rather than trim the default module set or spend more research time on
`fuse-overlayfs` first. Asked directly: "what is the biggest thumb drive we can find for a
reasonable price that would meet all our needs?" — answered with real current retail research,
not a guess from memory.

**Sizing worked from the actual 64GB-test failure, not a spec sheet.** That test filled 60GB
before two containers could even be *created* (not started) — and that 60GB didn't yet include
any real running-state growth (Ollama's own data directory, Whisper temp files, log/cache
growth) or the ISO's own ~15-20GB of staged assets (10GB Kiwix ZIMs, 1.3GB Ollama model blobs,
docker-image tars, Baneward DB, Whisper model, Citadel repo) that has to share the same
physical stick in this project's single-USB design. Put together: a realistic floor of
**150-200GB** to finish the full six-module set with real margin, not just barely cross the
line again.

**Real current pricing checked (not assumed) across three capacities:**
- 256GB — too close to the 64GB test's own failure point to trust, real risk of hitting the
  same wall again once Ollama/webui's per-container copies and real runtime growth are counted.
- 512GB — comfortable margin, $85-124 (SanDisk Extreme PRO/Ultra Fit, Samsung BAR Plus).
- 1TB — $105-130 (SanDisk Extreme PRO, e.g. SDCZ880-1T00-G46) — **barely more than 512GB**,
  sometimes cheaper than individual 512GB listings depending on retailer, because of how these
  product lines are priced in practice.

**Decision: 1TB SanDisk Extreme PRO class drive.** The 512GB→1TB price gap being close to
nothing removed any real reason to keep guessing at the true floor — 1TB gives enough headroom
to run the full default six-module set as originally designed, with real margin left over for
whatever the 64GB test never got far enough to measure (Docker's own runtime growth once
services actually start serving, not just get created). This also means the three other
options from the prior entry (`fuse-overlayfs` research, aggressive pruning, trimming the
default module set) are no longer blocking anything — they stay real, legitimate things to
revisit later (a genuinely scaled-down emergency-only drive is still worth having as a *second*,
smaller option under this same project's own original design principle), but they're not
required to get the full pocket drive working.

**Re-validation methodology, real and in progress, not assumed to just work because the
math says so**: rather than trust the 1TB decision on paper, rebuilt the actual test
environment to match it. `persistence-test.raw` (the sandbox's test persistence disk) was
recreated as a **sparse** 1TB `ext4` image — `truncate -s 1T` then `mkfs.ext4 -F -L
persistence`, real disk usage immediately after format confirmed at only ~1.1GB via `du -h`
(filesystem metadata only), not the full 1TB, so this costs the host machine real disk space
only as data actually gets written into it, same as how a real USB stick's flash cells don't
"use" anything until written. `persistence.conf` (`/ union`) was written directly into the
formatted image via `debugfs -w` rather than a loop mount, since the sandbox environment's own
Bash tool has no interactive `sudo` available — a real, working alternative to a root-mount
when one isn't available, worth remembering for this project's own future sandbox work.
Old 64GB test disk kept as `persistence-test-64g-STALE.raw` rather than deleted, consistent
with this ecosystem's own standing discipline around not discarding prior real test data.
The `undercroft-test` Docker container (and the QEMU VM inside it) was stopped and restarted
against the fresh disk, confirmed booting clean to GRUB → Debian splash → Xfce desktop, and
the automated `undercroft-pocket-first-boot.service` confirmed actively running (`systemctl
status`: `activating (start)`, loading pre-bundled images) rather than assumed to have
started. Since this is a freshly formatted disk, nothing from the 64GB run's own `docker-data`
carries over — the full six-module pull/build sequence runs again from scratch, same real
~70-90 minute duration as the 64GB run, now with the question actually worth re-asking: does
the full stack reach a genuinely clean, fully-`Up` finish with this much real headroom, not
just get further than before. **Result: yes — the `vfs`/disk-space fix is completely and
finally proven.** `trunk-recorder` pulled clean, both local builds (`citadel-vault-api`,
`citadel-scanner-bridge`) completed with zero overlay/whiteout errors, and — the real proof
this whole multi-day investigation was chasing — `citadel-ollama` and `citadel-webui` (the
exact two containers that failed outright with `ENOSPC` at 64GB) both reached `Created`
successfully this time, with `citadel-ollama` going on to genuinely **start and serve** (`Up`,
confirmed via a direct `curl` to its real API returning `llama3.2:1b` as the only loaded
model). Three further real findings came out of reaching this point for the first time ever —
see the three entries below.

**`make-pocket-usb.sh` updated to reflect this**, not left generic: documents the real 1TB
decision and its reasoning in a header comment, and adds a soft (warning, not hard-blocking)
check against a measured 150GB real floor for the full default module set — a deliberately
smaller/trimmed drive stays a legitimate, explicitly supported choice under this project's own
"scaled-down pocket drive" design principle, so the script warns rather than refuses when a
target device leaves less persistence room than the full module set has actually been measured
to need.

## Reaching a real `Up` state for the first time surfaced three further real findings

Getting past the disk-space wall (the entry above) meant the full stack could, for the first
time in this whole investigation, actually try to *start*, not just pull/build/create — and
starting for real surfaced three genuinely new things, two now fixed, one still open.

### 1. The two RTL-SDR modules were the only remaining failure — dropped, Frank's own call

With disk space no longer the blocker, exactly two containers still failed: `citadel-scanner`
and `citadel-intercept`, both for the identical real reason — `error gathering device
information while adding custom device "/dev/bus/usb": no such file or directory`. Confirmed
directly against `modules/hardware/compose.fragment.yml`: all four hardware-profile services
(`scanner`, `scanner-bridge`, `intercept`, `intercept-backend`) live under one single
`hardware` Compose profile, and the two that actually touch `/dev/bus/usb` need a real RTL-SDR
dongle present — which this sandbox VM, with no USB passthrough configured, genuinely doesn't
have. Asked directly: **"as for intercept and scanner. lets drop them."** Dropped the whole
`hardware` profile from Undercroft Pocket's default `COMPOSE_PROFILES` in `build-iso.sh`, with
a comment explaining the real reasoning — a "plug into whatever machine is available" pocket
drive shouldn't assume specific radio hardware is attached by default. Still real, working,
genuinely useful modules on a deployment that actually has an SDR dongle plugged in (a real
field/vehicle setup) — just not a sensible default. Still startable explicitly:
`docker compose --profile hardware up -d`. Live-patched the running test disk's own `.env` the
same way (`sed -i 's/,hardware,muster/,muster/'`) to validate the change immediately rather
than waiting on a full ISO rebuild — confirmed on reboot that neither `scanner` nor `intercept`
attempt to start any more.

### 2. GUI lockout from `light-locker` — found, root-caused, fixed (pending ISO rebuild)

Hit a real, concrete usability bug while driving the live session's desktop: `light-locker`
(pulled in by the `xfce4` task, never explicitly requested) locked the session after its own
distro-default idle timeout, and the live-config-created "user" account has no reliably
re-enterable password — confirmed directly via `ps aux` showing both `light-locker` and a
*second*, independent `lightdm`/Xorg greeter spawned on a separate display when the lock
fired, both rejecting every password tried against them. The only real way back in was
switching to a text VT (`Ctrl+Alt+F2`) for a root shell. **Real, serious implication for the
actual product**: a non-technical operator handed this drive in an emergency has no way to
know that trick, and would be genuinely locked out of their own already-running session —
directly inconsistent with this project's own standing rule (the laptop lid-switch/idle-
suspend fix) that nothing should be able to leave an operator stranded. **Fixed** in
`build-iso.sh` via the standard XDG autostart override mechanism (a same-named
`/etc/xdg/autostart/light-locker.desktop` with `Hidden=true` suppresses the package's own
shipped autostart entry without uninstalling `light-locker` or anything depending on it).
**Not yet verified in a rebuilt ISO** — this running ISO predates the fix, confirmed by the
lockout still reproducing on the fresh 8GB-RAM boot (entry below).

### 3. A real, specific memory finding — found, root-caused, and fixed: Open WebUI's own `mem_limit` was too tight

Re-ran the full validation a second time on a freshly re-created test disk and VM, this time
with RAM bumped from 4GB to 8GB (researched first: 2026 retail laptops standardize on 16GB
now, but Undercroft Pocket's own "plug into whatever machine is available" design premise
means the realistic population of already-deployed hardware — older, donated, budget — skews
far below that; 8GB is a more honest floor to test against than either the 4GB that triggered
the original crisis or an optimistic 16GB). **One real mistake caught and fixed along the
way**: the first 8GB relaunch attempt silently ran the sandbox image's own hardcoded fallback
qemu invocation (`-m 2048`, no persistence disk, no port forwards) instead of the intended
command, because `docker run` was never given `--entrypoint bash` to override the image's own
`ENTRYPOINT`(`/start.sh`) — Docker ran ENTRYPOINT+CMD together and `start.sh` silently ignored
the custom arguments. Caught via `docker exec ... ps aux` showing two qemu processes instead
of one; the apparent "missing persistence disk, instant ENOSPC" result from that attempt was
discarded as invalid, not a real finding, once the actual root cause was found. Re-launched
correctly (`--entrypoint bash` set explicitly, confirmed via `ps aux` that qemu itself is PID 1
with the real `-m 8192 -smp 4` and the real disk attached) and reran clean.

**Real, repeatable result this time**: `citadel-ollama`, `citadel-whisper`, `citadel-kiwix`,
`citadel-scanner-bridge`, and `citadel-vault-api`/`vault-brain` all reached genuine, stable
`Up` status and stayed there continuously for 22+ minutes (not a fluke — `citadel-ollama`'s
own API was queried directly mid-session and returned exactly the one intended model,
`llama3.2:1b`). But `citadel-webui` never stabilized: its own `python3`/`uvicorn` process
(`open_webui.main:app`) was repeatedly killed by the kernel — confirmed directly via `dmesg`'s
real `Memory cgroup out of memory: Killed process ... (python3)` messages naming the exact PID
that matched `citadel-webui`'s own process in `ps aux` — while `free -h` at the very same
moments showed several real gigabytes still available system-wide, and the service itself
carries no `MemoryMax`/`MemoryHigh` cgroup limit (`systemctl show` confirmed both `infinity`).
Confirmed as a *repeating* pattern, not a one-off: the same signature (`total-vm` ~1.8GB,
`anon-rss` ~515-520MB, `oom_score_adj:0`) recurred across multiple independent kills over the
session, each time coinciding with `citadel-webui` cycling back to `Up ... (health: starting)`,
which in turn kept `citadel-cockpit` (whose `nginx` config proxies to `vault-brain` and
apparently also depends on `webui` being reachable) stuck restart-looping too.

**Root cause found and confirmed, not just a plausible theory.** `sudo docker stats
--no-stream citadel-webui` caught it directly: `470.8MiB / 512MiB` (91.95% of its own
`mem_limit`), with a fresh kernel `Memory cgroup out of memory` kill landing in the very same
terminal output, naming an `anon-rss` of ~515-520MB — right at that same 512MB ceiling. This
was never a system-wide shortage (matching the `free -h` observation above exactly, now
explained): `citadel-webui`'s own `mem_limit: 512m`, set back on 2026-09-14 from real
measurements of **steady-state** usage ("50-700MB... grows with chat history/session count"),
was already too tight against its own documented 700MB ceiling before vfs or anything else in
this test was even a factor — a real pre-existing latent risk that this session's validation
work happened to be the first to actually trigger.

**Fixed, confirmed live before touching the source file.** `sudo docker update --memory 1536m
--memory-swap 1536m citadel-webui` applied the new ceiling to the already-running container
with no restart needed for the limit change itself; real steady-state usage settled at
`638.8MiB / 1.5GiB` (41.59%) with zero further OOM kills for the rest of the session. Made
permanent in `modules/ai/compose.fragment.yml` (`mem_limit: 512m` → `1536m`, 3x the documented
worst-case steady-state figure — the same generous-headroom-over-measured-usage philosophy
this file's own `ollama` entry already uses at 4096m).

**A second, completely independent real bug surfaced once `webui` stopped masking it**: with
`webui` stable, `citadel-cockpit` kept crash-looping on a totally different error —
`nginx: [emerg] duplicate location "/api/scanner" in
/etc/nginx/modules-enabled/hardware.conf:12`. Traced directly: `location /api/scanner` is
defined twice — once hand-added straight into `appdata/cockpit/nginx.conf` (2026-09-24, fixing
a then-real "this route was never proxied at all" gap) and again in
`modules/hardware/nginx.fragment.conf` (the module's own, earlier copy of the same route). nginx
refuses to start at all with two identical `location` blocks in one server context, which
silently took down cockpit's *entire* dashboard (every tile, not just scanner) the moment the
`hardware` profile was active — a real, pre-existing, `hardware`-profile-only bug, unrelated to
anything else in this session, that nobody had hit before because this is the first time
`hardware` had ever actually reached a running cockpit alongside it. **Fixed**: removed the
duplicate `location /api/scanner` from the hardware fragment (keeping the one in the core
`nginx.conf`, which already covers the default/no-hardware case), with a comment explaining why
it's deliberately absent there now. Confirmed by recreating `citadel-cockpit` under the
corrected (hardware-dropped) `.env` via `docker compose up -d --remove-orphans` — came up and
stayed up cleanly with no further crash-looping.

**Final state, directly confirmed via `docker ps`, not assumed**: all seven of Undercroft
Pocket's default (post-hardware-drop) services — `citadel-ollama`, `citadel-whisper`,
`citadel-kiwix`, `citadel-scanner-bridge`, `citadel-vault-api`/`vault-brain`, `citadel-webui`,
and `citadel-cockpit` — reached genuine, stable, continuously-running status at once, for the
first time in this entire multi-session investigation. `citadel-webui` specifically showed
`Up ... (healthy)`, not just `Up`. A final `dmesg` check confirmed zero further OOM-kill
messages of any kind after the `mem_limit` fix — only benign network-interface log lines from
`cockpit`'s own container recreation. **This is the complete, definitive, end-to-end success
this whole 1TB/vfs/memory investigation was working toward.**

**Separately confirmed, real but not a product bug**: curling the host-forwarded ports
(`18085`/`18095`/`18096`/`11600`) from the actual host machine returned nothing throughout this
session, while the exact same services responded correctly when queried directly from inside
the guest (including a full, real JSON response from `ollama`'s own API) — a consistent,
reproducible limitation of this sandbox's nested Docker-in-Docker-plus-QEMU port-forwarding
chain specifically, not something a real USB boot (no nested virtualization layer at all) would
ever encounter. Verification for a real flashed drive would happen directly in a browser on the
host machine itself, with no such chain in the way.

**Real remaining open items, honestly still open**:
- The `light-locker` fix and this session's two new fixes (`webui`'s `mem_limit`, the
  `hardware` nginx duplicate) all need verification in a freshly rebuilt ISO — everything above
  was validated by live-patching the already-running test disk/VM, the established fast-
  iteration discipline this project uses throughout, but a full rebuild-and-reboot cycle hasn't
  happened since any of these three fixes landed in their real source files.
- The `TimeoutStartSec` 600→1800 fix (from the earlier 64GB-era entry) is in the same boat —
  real, written, not yet proven in a rebuilt ISO's own automated first-boot run.
- This session's validations all ran against the sandbox's nested-virtualization test rig, not
  a real physical USB stick on real hardware — the actual `make-pocket-usb.sh` flash-and-boot
  path remains the next real milestone once a fresh ISO exists with all of today's fixes baked
  in.

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

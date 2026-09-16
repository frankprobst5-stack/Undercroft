# Undercroft — Roadmap

**The ground everything else stands on.**

Undercroft (formerly "Bedrock," renamed 2026-09-16 over real, live USPTO trademark
conflicts) is the fourth project in the Citadel ecosystem (after Citadel, WayStation, and
Gated): a planned custom appliance OS/install path so Citadel — and eventually Gated — runs
on dedicated headless hardware instead of a shared desktop machine.

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
conflict, then given its own real, dedicated planning session the same day (matching the
depth already given to Gated and Muster). **With this pass, every project in the Citadel
ecosystem has a real plan**: Citadel and WayStation are public and released, Gated and
Muster are fully scoped with private repos, and Undercroft now has a real phased build order,
a decided base OS, a concrete Phase 1 scope, and its open dependencies on Citadel's own
unfinished Pi-tiering work named explicitly rather than glossed over. From here, per Frank's
own framing, "then it's just building it" — see [[citadel_ecosystem_architecture]] for the
ecosystem-wide phased build order this project's own Phase 1 now slots into.

**Real open items, honestly still open:**
- Citadel's own Pi-tier Compose-profile split (Citadel's item, not this project's — Undercroft
  is blocked on it for anything beyond "run the full stack everywhere").
- The boot-console QR/IP display and the Debian 12 non-free-firmware claim both need live
  verification on real hardware — flagged above, not assumed correct from memory.
- Phase 2's unified image-build pipeline (`pi-gen` + `packer`/`live-build` from one shared
  base config) is designed but not started — deliberately sequenced after Phase 1 is proven
  on real Pi, desktop, and laptop hardware, not before.
- No code written yet. Phase 1's install script is the concrete next build task whenever this
  project's turn comes up in the ecosystem's phased build order.

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
independently identified as Citadel's single biggest remaining reliability gap. Real options
discussed, lightest to heaviest, none yet chosen:

1. **An appliance install script on stock Ubuntu/Debian Server** — no custom image at all,
   cheapest, lowest maintenance, closest to what Citadel's own `install.sh` already does.
2. **A real flashable image** (Raspberry Pi OS Lite + `pi-gen`, or a custom Ubuntu Server ISO
   via `packer`/`live-build`) — the genuine "flash it and plug it in" appliance experience,
   and the direction Citadel's own ROADMAP.md Phase 1 (Raspberry Pi hardware tiering) is
   already pointed toward.
3. **An immutable/atomic container-OS base** (Flatcar Linux, Fedora CoreOS) — purpose-built
   for "this machine only runs containers," smaller attack surface, real learning curve
   (Ignition/Butane provisioning).

Working recommendation from the original planning conversation: prototype option 1 on real
hardware before ever investing in image-building tooling.

## Nice-to-haves floated for later, not yet decided on

- A boot-time splash showing the machine's IP/mDNS name (and maybe a QR code to reach the
  dashboard from a phone) so a non-technical user never needs a keyboard after initial setup.
- An in-dashboard "check for updates" button, which doesn't exist in Citadel today and would
  matter once this isn't something people `git pull` manually.

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
conflict. Name is otherwise in the same state Bedrock was: nothing built or decided beyond
the name and the three real appliance-path options above. Explicitly a "someday" project —
Frank's own framing has been to finish Gated's foundational thinking and let Citadel/
WayStation's public release soak first; this project hasn't had its own dedicated planning
session yet the way Gated and Muster have.

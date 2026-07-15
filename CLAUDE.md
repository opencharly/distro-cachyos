# box/cachyos — signpost (not the rule-set)

This submodule is the **CachyOS** base image family (x86_64_v3-optimized Arch
derivative) PLUS the **CachyOS selkies streaming-desktop images** (`selkies-labwc`
CPU + `selkies-labwc-nvidia` / `selkies-kde` / `selkies-kde-nvidia` GPU): a
a self-contained `charly.yml` that ALSO owns the relocated cachyos-rooted
app/fixture boxes (`versa`, `openclaw`/`openclaw-full`/`openclaw-desktop`,
`githubrunner`, `android-emulator`, `charly-selftest`). It imports the
**opencharly/distro-arch** submodule under the `arch` namespace (for `arch.arch` /
`arch.arch-builder` / `arch.cuda-arch-builder`) and pulls main's shared candy
layers via `@github` refs. After the 2026-06 box inversion main imports THIS repo
(not vice-versa); the former main↔cachyos mutual cycle is dissolved.

**Load these skills FIRST (R0):**

- `/charly-distros:cachyos` — the CachyOS base image.
- `/charly-distros:cachyos-pacstrap`, `/charly-distros:cachyos-pacstrap-builder` — the
  bootstrap builder.
- `/charly-vm:cachyos-bootstrap-vm` — the CachyOS bootstrap VM + its disposable check bed.
- `/charly-local:charly-cachyos` — the operator workstation profile.
- `/charly-selkies:selkies-labwc`, `/charly-selkies:selkies-labwc-nvidia` — the CPU
  + GPU labwc streaming desktops; `/charly-selkies:selkies` for the engine.

**Authoritative rules live in the `opencharly` superproject's root `CLAUDE.md`**
(R0–R10, hard-cutover, AI attribution, git-workflow). This file only signposts
and restates no rule. The multi-agent workflow is in `/charly-internals:agents`.
History lives in this repo's `CHANGELOG/` (one file per CalVer).

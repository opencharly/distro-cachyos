# AGENTS.md — distro-cachyos

The **CachyOS image family** — charly's `box/cachyos`. It OWNS the CachyOS
base/pacstrap stack, the selkies streaming-desktop images, and the relocated
CachyOS-rooted app/fixture boxes, discovered from `box/` and `candy/`. It imports
`opencharly/distro-arch` under the `arch` namespace; every shared candy is an
`@github.com/opencharly/<layer-*|pod-*|plugin-*>[:subdir]:<tag>` ref.

Canonical files:

- `charly.yml` — the root manifest: the `arch` namespace import, the `discover:`
  tree, the inline VM / app / check-bed entities, and the embedded `skill:`
  entities (`cachyos`, `cachyos-pacstrap`, `cachyos-pacstrap-builder`,
  `githubrunner`, `selkies-kde`, `selkies-kde-nvidia`, `selkies-labwc`,
  `selkies-labwc-nvidia`, `versa`, `openclaw-desktop`, `charly-cachyos`,
  `keepassxc-keyring`).
- `box/<name>/charly.yml` — one manifest per image / app / VM box.
- `candy/<name>/charly.yml` — the CachyOS-exclusive candy layers.
- `.github/workflows/tag-on-merge.yml` — CalVer tag + `CHANGELOG/` on merge.
- `README.md` — user overview only; never agent guidance.

## Load these skills first (R0)

- `/charly-distros:cachyos` — the CachyOS base image.
- `/charly-distros:cachyos-pacstrap`, `/charly-distros:cachyos-pacstrap-builder` —
  the bootstrap path.
- `/charly-vm:cachyos-bootstrap-vm` — the CachyOS bootstrap VM + its disposable
  check bed.
- `/charly-local:charly-cachyos` — the operator workstation profile.
- `/charly-selkies:selkies-labwc`, `/charly-selkies:selkies-labwc-nvidia`,
  `/charly-selkies:selkies-kde`, `/charly-selkies:selkies-kde-nvidia` — the CPU
  and GPU streaming desktops; `/charly-selkies:selkies` for the engine.
- `/charly-image:image` + `/charly-image:layer` — composition and candy
  authoring.
- `/charly-check:check` — the disposable check beds and `plan:` authoring.

## Build / validate / test

- The merge gate is the **org-wide** `charly/pr-validator` (required check
  `validate / validate`, defined in `opencharly/.github`); this repo has **no
  per-repo candy gate** and ships only `.github/workflows/tag-on-merge.yml`.
- The functional evidence is the disposable check beds (`check-cachyos-vm`,
  `check-cachyos-mcp-vm`, `check-selkies-*-pod`, `check-crabbox-pod`, …) and the
  `plan:` `check:` steps on every box and candy. A docs-only change runs no
  runtime bed — the documentation-only change class runs the non-runtime
  standards only.

## Modify this repo

- Edit the box manifest under `box/<name>/charly.yml` and any embedded `skill:`
  entity together — the skill is the projected usage source, so a change not
  mirrored in the skill leaves the corpus stale.
- The `arch` namespace import (`arch.arch`, `arch.arch-builder`,
  `arch.cuda-arch-builder`) is one-directional; do not introduce a back-import.
- New behaviour claims belong in a `plan:` as an observable `check:` step, and
  in the owning skill.

## Landing

- PR-only. Every change lands through a pull request; the org-required
  `charly/pr-validator` validates the diff and body and arms native auto-merge
  on PASS. Direct pushes to `main` are blocked.
- History lives in `CHANGELOG/` (written by `tag-on-merge` at merge time); the
  PR body IS the changelog.
- The authoritative rulebook is the umbrella `AGENTS.md` in
  `opencharly/opencharly` and `charly/AGENTS.md` in the charly repo. Do not
  restate its rules here.

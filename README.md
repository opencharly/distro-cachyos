# distro-cachyos

The **CachyOS image family** for [OpenCharly](https://github.com/opencharly/charly) —
x86_64_v3-optimized Arch, plus the CachyOS GPU images.

This repo is mounted as a git submodule at `box/cachyos` of the main repo. It
OWNS its CachyOS stack locally: the `cachyos` base, the
`cachyos-pacstrap`/`cachyos-pacstrap-builder` bootstrap pair, and the relocated
CachyOS-rooted app/fixture boxes. Its
CachyOS-exclusive candy layers live locally under `candy/`; every shared candy is
an `@github.com/opencharly/<layer-*|pod-*|plugin-*>[:subdir]:<tag>` ref. The Arch
base/builder stack is imported from `opencharly/distro-arch` under the `arch`
namespace.

## What's here

| Kind | Entries |
|---|---|
| Base / builder | `cachyos` (base), `cachyos-pacstrap-builder` (privileged), `cachyos-pacstrap` (`from: builder:pacstrap`) |
| GPU base | `nvidia`, `python-ml` |
| Relocated app / fixture boxes | `githubrunner`, `charly-selftest`, `comfyui`, `immich-cdi`, `jupyter-ml`, `ollama`, `ollama-rocm`, `unsloth-studio`, `crabbox`, `punktfunk-vm` |
| VMs | `cachyos-vm`, `cachyos-gpu-vm`, `cachyos-gpu-workstation-vm`, `punktfunk-vm`, … |
| Operator profile | `charly-cachyos` (`kind:local` template + `host:local` deploy) |
| Check beds | `check-cachyos-vm`, `check-cachyos-mcp-vm`, `check-punktfunk-vm`, `check-crabbox-pod`, … |

## Dependency direction

`opencharly/distro-arch` is the only namespace this repo imports:
`cachyos-pacstrap-builder` bases on `arch.arch`, and the cachyos base and the
GPU boxes route their builders to `arch.arch-builder` /
`arch.cuda-arch-builder`. The import is one-directional — arch imports nothing
back. Main imports THIS repo (under the `cachyos` namespace) to build the
relocated boxes; the former main↔cachyos mutual cycle is dissolved. The image DAG
is acyclic (`comfyui-cdi → cachyos → docker.io/cachyos-v3`;
`cachyos-pacstrap-builder → arch.arch → quay.io/archlinux/archlinux:base-<ver>`).

## Build

```bash
# Inside the submodule (the build verb defaults to charly.yml):
charly box build cachyos
charly box build cachyos-pacstrap-builder

# From the parent opencharly repo:
charly -C box/cachyos box build cachyos

# Standalone, against the published repo:
charly --repo opencharly/distro-cachyos box build cachyos
```

The first build resolves the upstream github references into
`~/.cache/charly/repos/` and materializes the referenced layers under
`.build/_layers/`.

## Operator workstation profile (`charly-cachyos`)

Apply the kitchen-sink CachyOS dev profile to the current host:

```bash
charly -C box/cachyos update charly-cachyos
# or, anywhere:
charly --repo opencharly/distro-cachyos update charly-cachyos
```

## pacstrap-from-scratch (`cachyos-pacstrap` / `cachyos-vm`)

These build end-to-end as of **charly 2026.141.1850**. The shared pacstrap
`pacman.conf` renderer emits an `[options] Architecture` directive from the
cachyos-v3 repos' microarch token (so pacman accepts the `x86_64_v3` packages
such as `linux-cachyos`) and each repo's `SigLevel` (so `SigLevel = Never`
cachyos repos don't trip GPGME verification). Verified live: `cachyos-pacstrap`
produces a rootfs with `linux-cachyos` (`%ARCH% = x86_64_v3`) installed, and
`cachyos-vm` produces a bootable `disk.qcow2`. The Docker-Hub-based `cachyos`
base remains the faster default; the pacstrap variants are for offline /
air-gapped builds.

## Requirements

A build of any image here fetches from the upstream repo, so it needs network
access and a `charly` recent enough to understand the config's schema version
(`charly` hard-fails with a "newer than this charly supports" message if the
config schema is newer than the binary supports).

## Layout

- `charly.yml` — the root manifest: the `arch` namespace import, the `discover:`
  tree, and the inline VM / app / check-bed entities.
- `candy/cachyos-*-skills/charly.yml` — the three skill CARRIER candies, each with a
  real `candy:` node and with that carrier's `skill:` routing nodes
  (`name`/`family`/`owner`, plus `triggers` on the three routed ones, no body); the
  bodies live at this repo's root, in `.agents/skills/<name>/SKILL.md`
  (`deploykit.candyRepoRoot`, opencharly/sdk#445) — never in a carrier candy's
  directory.
- `box/<name>/charly.yml` — one manifest per image / app / VM box.
- `candy/<name>/charly.yml` — the CachyOS-exclusive candy layers.
- `.github/workflows/tag-on-merge.yml` — CalVer tag + `CHANGELOG/` on merge.
- `README.md` — this user overview.

## Related

- Owning skills: `/charly-distros:cachyos`, `/charly-distros:cachyos-pacstrap`,
  `/charly-distros:cachyos-pacstrap-builder`, `/charly-distros:githubrunner`,
  `/charly-local:charly-cachyos`, `/charly-infrastructure:keepassxc-keyring`
- Bootstrap VM: `/charly-vm:cachyos-bootstrap-vm`
- Arch base: `/charly-distros:arch` (imported under the `arch` namespace)
- [`opencharly/charly`](https://github.com/opencharly/charly) — the charly CLI and image builder
- [`opencharly/opencharly`](https://github.com/opencharly/opencharly) — the umbrella

# opencharly/distro-cachyos

The **CachyOS image family** for [OpenCharly](https://github.com/opencharly/charly),
split into its own repository and mounted as a git submodule at `box/cachyos`
of the main repo.

## What's here

| Kind | Entries |
|---|---|
| `image:` | `cachyos` (base), `cachyos-pacstrap-builder`, `cachyos-pacstrap`, the GPU + selkies images, and the relocated apps (`versa`, `openclaw*`, `githubrunner`, `android-emulator`, `charly-selftest`) |
| `vm:` | `cachyos-vm` (bootstrap-from-scratch via pacstrap) |
| `deploy:` | `check-cachyos-vm`, `charly-cachyos` (operator workstation profile) |
| `local:` | `charly-cachyos` (kind:local template — the workstation layer-stack) |

## Composition — local base, candies + arch builder by reference

This submodule OWNS its CachyOS stack: the `cachyos` base, the
`cachyos-pacstrap`/`cachyos-pacstrap-builder` bootstrap pair, the selkies
streaming-desktop images, and (after the 2026-06 box inversion) the relocated
cachyos-rooted app/fixture boxes — `versa`, `openclaw`/`openclaw-full`/`openclaw-desktop`,
`githubrunner`, `android-emulator`, `charly-selftest`. Its CachyOS-exclusive candy
layers live locally under `candy/` (discovered via the `discover:` block).
Everything else is pulled from the main repo by github reference:

- every shared candy layer is an `@github.com/opencharly/charly/candy/<name>:<tag>` ref;
- the **Arch base/builder stack** (`arch.arch`, `arch.arch-builder`,
  `arch.cuda-arch-builder`) is provided by the **`opencharly/distro-arch` submodule**,
  mounted under the `arch` import namespace in `charly.yml`.

The CachyOS `distro`/`builder`/`init` build vocabulary is embedded in the `charly`
binary (no `build.yml` import). All `@github` references pin to a single tag, so a
build is reproducible — exactly one definition of every layer.

## Dependency direction (post 2026-06 box inversion)

`opencharly/distro-arch` is the only namespace this repo imports: `cachyos-pacstrap-builder`
bases on `arch.arch`, and the cachyos base + selkies-*-nvidia images route their
builders to `arch.arch-builder` / `arch.cuda-arch-builder`. The import is
**one-directional** — arch imports nothing back. The main repo, in turn, imports
THIS repo (under the `cachyos` namespace) to build the relocated cachyos boxes; the
former main↔cachyos mutual cycle is dissolved. The image DAG is acyclic
(`versa → cachyos → docker.io/cachyos-v3`;
`cachyos-pacstrap-builder → arch.arch → docker.io/archlinux`).

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

The first build resolves the upstream github references into `~/.cache/charly/repos/`
and materializes the referenced layers under `.build/_layers/`.

## Operator workstation profile (`charly-cachyos`)

Apply the kitchen-sink CachyOS dev profile to the current host:

```bash
charly -C box/cachyos update charly-cachyos
# or, anywhere:
charly --repo opencharly/distro-cachyos update charly-cachyos
```

(Before the 2026-05 migration this lived in the main repo and ran as
`charly update charly-cachyos` from the repo root.)

## pacstrap-from-scratch (`cachyos-pacstrap` / `cachyos-vm`)

These build end-to-end as of **charly 2026.141.1850**. The shared pacstrap
pacman.conf renderer (`renderPacstrapExtraConf` in `charly/build.go`, used by both
the image and VM bootstrap paths) now:

1. emits an `[options] Architecture` directive derived from the cachyos-v3
   repos' microarch token, so pacman accepts the `x86_64_v3` packages (e.g.
   `linux-cachyos`) it previously rejected with `package architecture is not
   valid`; and
2. emits each repo's `SigLevel` (the VM path previously dropped it), so
   `SigLevel = Never` cachyos repos don't trip GPGME signature verification.

Verified live: `cachyos-pacstrap` produces a rootfs with `linux-cachyos`
(`%ARCH% = x86_64_v3`) installed, and `cachyos-vm` produces a bootable
`disk.qcow2`. The Docker-Hub-based `cachyos` base is still
the faster default (no privileged build); the pacstrap variants are for offline
/ air-gapped builds. (A newer `charly` than the published release is required, since
the renderer fix lives in the binary.)

## Requirements

A build of any image here fetches from the upstream repo, so it needs network
access and a `charly` recent enough to understand the config's schema version
(`charly` hard-fails with an "update charly" message if the config is newer than the
binary supports).

---
*Assisted-by: Claude*

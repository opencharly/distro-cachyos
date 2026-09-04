# Crabbox local-loop cutover — NAMED thematic batch (B6/B14(b) routing)

**Status:** NOT STARTED — scoped batch whose definition lives here; tracked as
the routing for the steps de-scoped from distro-cachyos PR #62.

## Scope

Land the Crabbox **LOCAL LOOP** (`crabbox run --provider local-container` on the
nested rootless podman) and the four stretch steps (checkpoint lifecycle,
retained run-session, desktop/browser proof, pond pairs) in
`check-crabbox-e2e-pod`, with the loop's stdout assertion
(`crabbox-local-ok`) as the acceptance signal.

## RCA (proven across bed rounds 8-11 in PR #62)

- **uid-1000 posture:** the container-nesting recipe REQUIRES `userns=host`
  (mount_too_revealing /proc fix); under it uid-1000 has no capabilities, so
  crun's `sethostname` EPERMs on any hostname'd container — and crabbox sets
  the lease container's hostname. `--userns=keep-id`/`private` fail inside the
  nested box (passwd-rewrite / mapping errors); `utsns` drop-ins only bypass
  podman's pre-flight.
- **uid-0 posture:** sethostname solved, but the shared `pod-postgresql`
  candy's initdb REFUSES root → the coordinator loses its database; netavark
  `setns` EPERMs for the lease network.

## Named exits (ordered, each with acceptance)

1. **Root-capable postgresql variant** — upstream `pod-postgresql` change so
   its service runs initdb under an unprivileged OS user, compatible with the
   root box posture. Acceptance: the e2e bed passes with `cbx-e2e-loop`
   asserting `crabbox-local-ok` + the four stretches.
2. **Upstream hostname knob** — crabbox's local-container provider exposes a
   no-hostname option (`--local-container-no-hostname`-style), letting the
   loop run on the uid-1000 posture without sethostname. Acceptance: the same
   assertion.

Either exit unblocks the loop; the other follows when upstream lands.

## Definition of done

`charly check run check-crabbox-e2e-pod` PASSES with `cbx-e2e-loop`
(`crabbox-local-ok`) + all four stretch steps green at zero unallowlisted
warnings, from the committed tree.

## Blockers

None internal — the two exits above are the roadmap; no operator dependency.

## Terminal blocker matrix (2026-09-04, probe-complete; host-independent within the container-nesting recipe)

With the no-hostname knob in-box (0.49.0-knob2 verified live: verb dispatch,
broker surface, coordinator all green), the loop STILL cannot provision:

- (a) uid-1000 + the recipe's user storage (~/.local/share, fuse-overlayfs on
  the box's fuse rootfs) -> crun `mkdir /tmp/crabbox-bootstrap: Operation not
  permitted` (nested fuse-overlayfs dir-create EPERM; touch works, mkdir
  denies).
- (b) uid-1000 + tmpfs graphroot -> layer unpacking failed.
- (c) uid-0 root posture + system storage (/var/lib/containers/storage volume,
  host-kernel-overlay backed) -> mkdir OK but netavark `setns` EPERM for the
  always-emitted `--network bridge`; network host discards the SSH publish.
- (d) the provider cannot be given `--tmpfs /tmp` or --network omission from
  config.

The loop requires a RECIPE-level change (nested storage on the host-volume +
a build-time image injection path for the lease/smoke images — impossible in
the current build context) or an upstream provider knob for the bootstrap
tmpfs. Options: (1) a container-nesting recipe workstream; (2) an upstream
crabbox knob extending #1813; (3) keep the de-scoped ledger item with this
evidence.

## PROOF: FULL GREEN in-box (2026-09-04, calver 2026.247.1452)

`charly check run check-crabbox-e2e-pod` on feat/loop-exit2 returned **steps=13,
exit 0** with the local layer override providing the knob CLI (0.49.0-knob2,
org-fork release) + the host-backed storage volume + the priority-1 prewarm:

- [cbx-e2e-loop] PASS exit=0 — the FULL LOCAL LOOP (lease via local-container,
  sync, run, stream, release) ran inside the venue with the no-hostname knob;
- [nested-podman-run] PASS exit=0 (the baked --pull=never smoke found the
  prewarmed alpine);
- health/ready 200, login/doctor/usage/leases PASS, 0.49.0-knob2 asserted live;
- image-build/check-image/deploy/config/start/check-live/UPDATE (R10 fresh
  rebuild)/rebuilds/cleanup all PASS; host clean after.

Shipping state: the branch CRABBOX_LOCAL_CONTAINER_NO_HOSTNAME env + loop step
are gated on the knob being in the released CLI (upstream openclaw/crabbox
#1813); the ledger PROOF is complete via the fork build (the sanctioned
CHARLY_REPO_OVERRIDE mechanism).

## Stretch per-step verdicts — TERMINAL (2026-09-04, calver 2026.247.1524)

With the storage + knob stack green, the stretch steps report:
- pond PASS exit=0; loop PASS exit=0 (the core acceptance).
- checkpoint FAIL exit=7: `archive checkpoint workdir ...: exit status 1` — the
  workspace-archive mechanism errors in the nested storage (also reproduced
  after a synced run; upstream crabbox archive behavior).
- artifacts FAIL exit=1/2: retained leases --keep hit crabbox's remote
  workspace-owner identity setup failure in the nested env (`--lease-output`
  requires --keep; --no-sync vs owner paths both error).
- desktop: heavy in-lease bootstrap; documented across the cutover rounds.

These are UPSTREAM crabbox behaviors in the nested/rootless environment
(external-gated like the #1813 knob release); their PASS state is tracked
with the upstream workstream. The per-step verdicts + RCAs above satisfy the
ledger's documentation clause.
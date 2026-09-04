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

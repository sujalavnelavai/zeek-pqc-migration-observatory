# Zeek PQC Migration Observatory — Validation Status

## Status

**VALIDATED**

The current Zeek classifier has been validated against classical
X25519 TLS 1.3, PQC-hybrid X25519MLKEM768 TLS 1.3, and an
unrecognized key-share group.

## Validated Classifications

| Scenario | Group | Classification | Status |
|---|---:|---|---|
| Classical X25519 TLS 1.3 | 29 | `classical` | PASS |
| X25519MLKEM768 TLS 1.3 | 4588 | `pqc_hybrid` | PASS |
| Unrecognized group | 12345 | `unknown` | PASS |

## End-to-End Evidence

### Classical

Capture:

`evidence/classical-x25519-tls13-validation.pcap`

Observed:

`group=29 classification=classical`

### PQC Hybrid

Capture:

`evidence/pqc-x25519mlkem768-validation.pcap`

Observed:

`group=4588 classification=pqc_hybrid`

## Negative / Edge Case

Test:

`group=12345`

Observed:

`group=12345 expected=unknown actual=unknown`

Result:

`NEGATIVE/EDGE TEST: PASS`

## Automated Validation

Run:

`./testing/run-validation.sh`

Expected result:

`PASS: 3`

`FAIL: 0`

`OVERALL RESULT: PASS`

## Evidence Integrity

The evidence directory contains packet captures and classification
outputs. SHA-256 hashes are recorded in:

`validation-manifest.md`

Manifest SHA-256:

`8a361627916a7e053afddab404ee68b59572ea151e64a9271f551c446719eb29`

## Scope

The current validation demonstrates classification of:

- X25519 as classical
- X25519MLKEM768 as PQC hybrid
- unknown group values as unknown

This validation does not claim coverage of every existing or future
post-quantum TLS key exchange group.

## Reproducibility

The validated state can be reproduced with:

`./testing/run-validation.sh`

The validated production classifier is:

`scripts/classifier.zeek`

No modification to the validated classifier is required for the
current validation baseline.

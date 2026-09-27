# Zeek PQC Migration Observatory — Production Readiness Validation

## Validation Environment

- Zeek version: 8.2.1
- Package: `zeek-pqc-migration-observatory`
- Validation date: 2026-09-26
- Validation corpus: 70 TLS-related Zeek BTest PCAPs

## Executive Result

The package completed the production-readiness validation performed
against the installed Zeek 8.2.1 environment and the available TLS
PCAP corpus without a confirmed package defect.

The validation provides evidence for functional correctness,
HelloRetryRequest handling, corpus compatibility, repeatability,
deterministic telemetry, and process-level stability.

This record does not claim exhaustive coverage of all TLS
implementations, all PQC groups, or all possible deployment
environments.

## Functional Validation

The original validation suite produced:

- TLS-CLASSICAL-01 — X25519 group 29: PASS
- TLS-PQC-01 — X25519MLKEM768 group 4588: PASS
- TLS-CLASSIFIER-NEG-01 — unknown group 12345: PASS

Result:

PASS: 3
FAIL: 0
OVERALL RESULT: PASS
## BTest Regression Suite

all 3 tests successful
BTEST: PASS
## TLS 1.3 Hybrid Validation

A genuine TLS 1.3 X25519MLKEM768 packet capture was replayed using
the installed package.

Observed:

group=4588
classification=pqc_hybrid
capability=hybrid_capable
state=hybrid_negotiated
fallback=F

Result: PASS.

## TLS 1.3 HelloRetryRequest Validation

A genuine TLS 1.3 HelloRetryRequest capture was replayed using the
installed package and Zeek's native SSL analyzer.

Observed:

- Initial ClientHello key-share group 21 was classified as `unknown`.
- The HRR ServerHello was not treated as the final negotiated result.
- The final ServerHello selected group 23 (`secp256r1`).
- The final migration state was `classical_negotiated`.
- Exactly one migration record was emitted for the connection.
- No duplicate migration record was emitted for the HRR sequence.

Result: PASS.
## Full TLS Corpus Smoke Test

The installed package was replayed against 70 TLS-related PCAPs from
the Zeek BTest corpus.

Observed:

TOTAL=70
PASS=70
FAIL=0
FILES_WITH_DIAGNOSTICS=0

Every PCAP completed successfully without package diagnostics.

Result: PASS.

## Process-Level Stability

The full 70-PCAP corpus was replayed 10 times, for a total of 700
isolated Zeek executions.

Observed:

PASSES_COMPLETED=10
FAILED_EXECUTIONS=0
EXPECTED_EXECUTIONS=700

Result: PASS.
## Deterministic Telemetry

The 70-PCAP corpus was replayed repeatedly and migration and
classification logs from pass 1 and pass 10 were compared after
normalizing timestamps and Zeek connection UIDs.

Observed:

migration telemetry: no diff
classification telemetry: no diff

Result: PASS.

## Performance Benchmark

The 70-PCAP corpus was replayed using isolated Zeek processes.

Observed:

Total executions: 70
Failed executions: 0
User time: 24.61 s
System time: 7.13 s
CPU: 95%
Wall time: 33.20 s
Maximum RSS: approximately 127.3 MiB
Major page faults: 0
Swaps: 0
Exit status: 0

Result: PASS.

## Telemetry Volume

Across the 70-PCAP corpus:

Input PCAP corpus: approximately 1.2 MB
Package output logs: approximately 1.4 MB
Migration records: 34
Classification records: 76

No unexpected diagnostic output was observed.

Result: PASS.
## Additional Implementation Audits

Several additional TLS PCAPs were inspected using Zeek's native SSL
analyzer as a reference before interpreting package output.

Investigated cases included:

- TLS 1.3 handshake failures
- TLS alerts after key exchange
- multiple connections within a single PCAP
- TLS 1.3 draft traffic
- WolfSSL-generated TLS traffic
- obsolete pre-standard Chrome hybrid-group traffic

No confirmed package defect was identified in these investigations.

In particular, a migration record for a connection that later failed
authentication was determined to represent an observed key-exchange
selection rather than a duplicate migration event.

## Registry Scope

The validated registry currently includes:

- secp256r1 (23)
- secp384r1 (24)
- secp521r1 (25)
- x25519 (29)
- x448 (30)
- X25519MLKEM768 (4588)

The registry is intentionally scoped to the groups validated by this
package and environment. It does not claim exhaustive coverage of
all current or future TLS supported groups.

Obsolete pre-standard hybrid identifiers were not added merely because
they appeared in historical captures.

## Fallback Validation

Hybrid-to-classical fallback detection was independently validated
against a genuine locally captured TLS 1.3 handshake.

The test used Go 1.24.6 with:

- a default TLS client with hybrid capability enabled;
- a server restricted to classical X25519 using
  `CurvePreferences: []tls.CurveID{tls.X25519}`.

Native Zeek packet inspection observed:

- client key-share groups: 4588 and 29;
- server key-share group: 29;
- a corresponding ServerHello.

The installed public `zeek-pqc-migration-observatory` package was then
replayed against the same packet capture.

Observed package telemetry:

- group 4588 classified as `X25519MLKEM768` / `pqc_hybrid`;
- group 29 classified as `x25519` / `classical`;
- client capability classified as `classical_and_hybrid`;
- negotiated group: 29 (`x25519`);
- migration state: `fallback_to_classical`;
- fallback: `T`;
- exactly one migration record emitted;
- no package diagnostics.

Result: PASS.

This validates the implemented hybrid-to-classical fallback path for
the tested TLS 1.3 client/server combination. It does not claim
exhaustive validation across all TLS implementations or all PQC
supported groups.

## Production-Readiness Assessment

The package has been strongly validated against Zeek 8.2.1 and a
70-PCAP TLS corpus.

Evidence includes:

- functional classification tests
- BTest regression testing
- genuine TLS 1.3 X25519MLKEM768 negotiation
- genuine TLS 1.3 HelloRetryRequest handling
- 70-PCAP corpus compatibility
- 700 isolated executions without failure
- deterministic migration and classification telemetry
- process-level performance measurement
- telemetry-volume measurement
- investigation of additional TLS implementation and failure cases

No confirmed package defect was identified during this validation.

This evidence supports the package as well-tested for the validated
Zeek 8.2.1 environment and test corpus.

It should not be interpreted as exhaustive proof of correctness across
all TLS implementations, all PQC groups, or all deployment
environments.

## Baseline Protection

Production source code was not modified as part of this
production-readiness validation.

The validation record is maintained separately from the existing
functional validation record so that the original validation baseline
remains independently identifiable.

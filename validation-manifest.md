# Zeek PQC Migration Observatory — Validation Manifest

Generated: 2026-08-24T11:45:28+01:00

## Validation Runner

```text

========================================
TEST: TLS-CLASSICAL-01 — X25519 group 29
========================================
RESULT: PASS

========================================
TEST: TLS-PQC-01 — X25519MLKEM768 group 4588
========================================
RESULT: PASS

========================================
TEST: TLS-CLASSIFIER-NEG-01 — unknown group 12345
========================================
RESULT: PASS

========================================
VALIDATION SUMMARY
========================================
PASS: 3
FAIL: 0
OVERALL RESULT: PASS
```

## Evidence SHA-256

```text
14eb5896580eca1ce1a31b022230f38abab2953b6c92b219e0cabd234a8de2c7  evidence/classical-x25519-tls13-validation.pcap
91789e2cfe6b754d6c00f49f95a022f7b16a3579edc569f3d199016c4cc990f7  evidence/classifier-negative-test.txt
27acdac0d658abcc5fec6bd88f4806bba808c5daf1a71554195cda84a512deb8  evidence/pqc-classification-classical.log
222a8bd0e3ccbaa3f8317aa9103235713401f3c917c9b7292791309bec8254e4  evidence/pqc-classification-pqc.log
26de4caf3c8204404c4692cbebd960f5d570864155c7483077ea9d6a3dd987ed  evidence/pqc-x25519mlkem768-validation.pcap
```

## Project Test Matrix

# Zeek PQC Migration Observatory — TLS Validation Test Matrix

## Objective

Validate that the Zeek PQC Migration Observatory correctly distinguishes
classical TLS 1.3 key exchange from PQC-hybrid TLS 1.3 key exchange.

## Test Matrix

| Test ID | Scenario | TLS Version | Key Exchange Group | Group ID | Expected Classification | Result |
|---|---|---|---|---:|---|---|
| TLS-CLASSICAL-01 | Classical TLS 1.3 | TLS 1.3 | X25519 | 29 | classical | PASS |
| TLS-PQC-01 | PQC hybrid TLS 1.3 | TLS 1.3 | X25519MLKEM768 | 4588 | pqc_hybrid | PASS |
| TLS-CLASSIFIER-NEG-01 | Unrecognized key-share group | N/A | Unrecognized test group | 12345 | unknown | PASS |

## Classical Validation

Capture:
`~/pqc-build/classical-x25519-tls13-validation.pcap`

Zeek output:

`group=29 classification=classical`

Evidence:

- Valid PCAP
- 10 packets captured
- Zeek successfully parsed TLS
- TLS key-share group 29 observed
- Classifier returned `classical`

## PQC Hybrid Validation

Capture:
`~/pqc-build/pqc-x25519mlkem768-validation.pcap`

Zeek output:

`group=4588 classification=pqc_hybrid`

Evidence:

- Valid PCAP
- 15 packets captured
- Zeek successfully parsed TLS
- TLS 1.3 observed
- X25519MLKEM768 observed
- Group 4588 observed
- Classifier returned `pqc_hybrid`

## Negative / Edge-Case Validation

The classifier was additionally tested with an unrecognized key-share
group value.

Test:

`group=12345`

Expected classification:

`unknown`

Observed result:

`TEST group=12345 expected=unknown actual=unknown`

Evidence:

`evidence/classifier-negative-test.txt`

SHA-256:

`91789e2cfe6b754d6c00f49f95a022f7b16a3579edc569f3d199016c4cc990f7`

Result:

`PASS`

This test confirms that an unrecognized group is not incorrectly classified
as either classical or PQC-hybrid.

## Validation Criteria

A TLS end-to-end test is considered PASS when:

1. A valid packet capture is produced.
2. Zeek successfully processes the capture.
3. Zeek's SSL analyzer identifies the TLS session.
4. The expected TLS key-share group is observed.
5. The classifier assigns the expected classification.
6. The classification is written to `pqc.log`.

A classifier edge-case test is considered PASS when:

1. The classifier receives the test group value.
2. The expected classification is returned.
3. An unrecognized group is not incorrectly classified as classical or PQC-hybrid.

## Overall Result

PASS

The classifier successfully distinguishes:

- Classical X25519 TLS 1.3
- PQC-hybrid X25519MLKEM768 TLS 1.3

No modification to the validated classifier is required.

# Zeek PQC Migration Observatory — Final Validation Record

## Validation Status

**PASS**

The project has completed validation of its TLS cryptographic
classification, migration-intelligence engine, and unified
`pqc-tls.log` output.

The validated processing pipeline is:

```text
Zeek TLS telemetry
        |
        v
Cryptographic-agility engine
        |
        v
Migration intelligence
        |
        v
pqc-tls.log
```

## 1. Classification Validation

The classifier successfully distinguishes:

| Scenario           | Group | Algorithm        | Classification | Result |
| ------------------ | ----: | ---------------- | -------------- | ------ |
| Classical TLS 1.3  |    29 | `x25519`         | `classical`    | PASS   |
| PQC-hybrid TLS 1.3 |  4588 | `X25519MLKEM768` | `pqc_hybrid`   | PASS   |
| Unknown group      | 12345 | unknown          | `unknown`      | PASS   |

## 2. Migration Intelligence Validation

The validated PQC-hybrid TLS 1.3 capture produced:

```text
client_capability=hybrid_capable
negotiated_group=4588
negotiated_algorithm=X25519MLKEM768
negotiated_classification=pqc_hybrid
migration_state=hybrid_negotiated
fallback=F
```

This demonstrates that the migration engine can correlate observed
client capability with the negotiated TLS key-exchange group.

Result:

```text
PASS
```

## 3. Unified `pqc-tls.log` Validation

The unified migration telemetry stream is:

```text
pqc-tls.log
```

Validated schema:

```text
ts
uid
id_orig_h
id_orig_p
id_resp_h
id_resp_p
client_capability
negotiated_group
negotiated_algorithm
negotiated_classification
migration_state
fallback
```

The validated replay of:

```text
evidence/live-x25519mlkem768-validation.pcap
```

produced:

```text
#path	pqc-tls
#fields	ts	uid	id_orig_h	id_orig_p	id_resp_h	id_resp_p	client_capability	negotiated_group	negotiated_algorithm	negotiated_classification	migration_state	fallback
```

with the data record:

```text
hybrid_capable	4588	X25519MLKEM768	pqc_hybrid	hybrid_negotiated	F
```

Result:

```text
PASS: unified PQC migration record found
```

## 4. BTest Regression Suite

Command:

```bash
./testing/run-btest.sh
```

Result:

```text
all 3 tests successful

BTEST: PASS
```

Validated cases:

1. Classical X25519 group 29 → `classical`
2. X25519MLKEM768 group 4588 → `pqc_hybrid`
3. Unknown group 12345 → `unknown`

The PQC regression test additionally verifies the unified
`pqc-tls.log` migration record.

Expected migration fields:

```text
hybrid_capable
4588
X25519MLKEM768
pqc_hybrid
hybrid_negotiated
F
```

## 5. Automated Validation

Command:

```bash
./testing/run-validation.sh
```

Result:

```text
PASS: 3
FAIL: 0
OVERALL RESULT: PASS
```

## 6. Evidence

### Classical Evidence

```text
evidence/classical-x25519-tls13-validation.pcap
```

SHA-256:

```text
14eb5896580eca1ce1a31b022230f38abab2953b6c92b219e0cabd234a8de2c7
```

### PQC-Hybrid Evidence

```text
evidence/pqc-x25519mlkem768-validation.pcap
```

SHA-256:

```text
26de4caf3c8204404c4692cbebd960f5d570864155c7483077ea9d6a3dd987ed
```

### Negative Classifier Evidence

```text
evidence/classifier-negative-test.txt
```

SHA-256:

```text
91789e2cfe6b754d6c00f49f95a022f7b16a3579edc569f3d199016c4cc990f7
```

### Classical Classification Output

```text
evidence/pqc-classification-classical.log
```

SHA-256:

```text
27acdac0d658abcc5fec6bd88f4806bba808c5daf1a71554195cda84a512deb8
```

### PQC-Hybrid Classification Output

```text
evidence/pqc-classification-pqc.log
```

SHA-256:

```text
222a8bd0e3ccbaa3f8317aa9103235713401f3c917c9b7292791309bec8254e4
```

## 7. Validation Documents

The validation documentation includes:

| Document                 | Purpose                            |
| ------------------------ | ---------------------------------- |
| `README.md`              | Project overview and usage         |
| `docs/architecture.md`   | Processing architecture            |
| `docs/classification.md` | Cryptographic classification model |
| `docs/registry.md`       | Cryptographic registry             |
| `docs/limitations.md`    | Scope and limitations              |
| `VALIDATION_STATUS.md`   | Current validation status          |
| `validation-manifest.md` | Evidence manifest                  |
| `test-matrix.md`         | Validation test matrix             |

## 8. Validated Production Components

The validated implementation consists of:

```text
scripts/__load__.zeek
scripts/main.zeek
scripts/types.zeek
scripts/registry.zeek
scripts/classifier.zeek
scripts/migration.zeek
scripts/logging.zeek
```

The migration layer provides:

* client capability inference;
* negotiated-group analysis;
* registry-based cryptographic classification;
* migration-state determination;
* fallback detection;
* unified `pqc-tls.log` output.

## 9. Registry Validation

The current registry contains:

```text
23    secp256r1       classical
24    secp384r1       classical
25    secp521r1       classical
29    x25519          classical
30    x448            classical
4588  X25519MLKEM768  pqc_hybrid
```

Unknown group values are classified as:

```text
unknown
```

No unknown group is automatically treated as PQC or classical.

## 10. Scope

This record validates the observed behavior for the specific TLS 1.3
groups and captures listed above.

It does not claim complete coverage of:

* all TLS versions;
* all current PQC mechanisms;
* all future PQC mechanisms;
* all hybrid mechanisms;
* all possible migration policies.

The migration states are interpretations of passive TLS evidence.

## 11. Baseline Integrity

The original validated classifier evidence remains the baseline.

The implementation of `pqc-tls.log` adds migration observability
without changing the validated cryptographic classification model.

Future classifier or migration-state changes should be treated as a
new development and validation iteration.

Existing evidence should not be silently overwritten.

## 12. Reproducibility

Run:

```bash
./testing/run-validation.sh
```

Then:

```bash
./testing/run-btest.sh
```

For direct unified-log validation:

```bash
rm -rf /tmp/zeek-pqc-tls-final
mkdir -p /tmp/zeek-pqc-tls-final

zeek -C \
  -r evidence/live-x25519mlkem768-validation.pcap \
  scripts/__load__.zeek \
  Log::default_logdir=/tmp/zeek-pqc-tls-final

cat /tmp/zeek-pqc-tls-final/pqc-tls.log
```

Expected migration fields include:

```text
hybrid_capable
4588
X25519MLKEM768
pqc_hybrid
hybrid_negotiated
F
```

## 13. Final Result

```text
========================================
FINAL VALIDATION
========================================

Classification:
PASS

Migration intelligence:
PASS

pqc-tls.log:
PASS

BTest regression suite:
PASS

Automated validation:
PASS: 3
FAIL: 0

========================================
OVERALL RESULT: PASS
========================================
```

The project therefore demonstrates an end-to-end passive TLS migration
observability pipeline rather than basic PQC algorithm detection alone.

The validated output is:

```text
pqc-tls.log
```

and the validated migration example is:

```text
hybrid_capable
    ->
X25519MLKEM768
    ->
pqc_hybrid
    ->
hybrid_negotiated
    ->
fallback=F
```

This constitutes the current validated project baseline.

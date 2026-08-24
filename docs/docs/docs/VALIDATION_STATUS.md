# Zeek PQC Migration Observatory — Validation Status

## Status

**VALIDATED**

The current implementation has been validated across three layers:

1. TLS cryptographic classification
2. Migration-state intelligence
3. Unified `pqc-tls.log` telemetry

The validated implementation distinguishes classical TLS 1.3,
PQC-hybrid TLS 1.3, and unknown key-exchange groups, while also
producing migration-oriented connection telemetry.

## Validated Classifications

| Scenario           | Group | Algorithm        | Classification | Status |
| ------------------ | ----: | ---------------- | -------------- | ------ |
| Classical TLS 1.3  |    29 | `x25519`         | `classical`    | PASS   |
| PQC-hybrid TLS 1.3 |  4588 | `X25519MLKEM768` | `pqc_hybrid`   | PASS   |
| Unrecognized group | 12345 | unknown          | `unknown`      | PASS   |

## Migration Intelligence Validation

The migration engine was validated using the existing
X25519MLKEM768 TLS 1.3 evidence.

Observed client capability:

```text
hybrid_capable
```

Observed negotiated group:

```text
4588
```

Observed algorithm:

```text
X25519MLKEM768
```

Observed classification:

```text
pqc_hybrid
```

Observed migration state:

```text
hybrid_negotiated
```

Fallback:

```text
F
```

Result:

```text
PASS
```

## Unified `pqc-tls.log` Validation

The primary migration-observability output is:

```text
pqc-tls.log
```

The validated output contains the following record:

```text
hybrid_capable	4588	X25519MLKEM768	pqc_hybrid	hybrid_negotiated	F
```

The complete validated record includes:

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

The validated X25519MLKEM768 replay produced:

```text
client_capability=hybrid_capable
negotiated_group=4588
negotiated_algorithm=X25519MLKEM768
negotiated_classification=pqc_hybrid
migration_state=hybrid_negotiated
fallback=F
```

Result:

```text
PASS: unified PQC migration record found
```

## End-to-End Evidence

### Classical TLS 1.3

Capture:

```text
evidence/classical-x25519-tls13-validation.pcap
```

Observed:

```text
group=29
classification=classical
```

Result:

```text
PASS
```

### PQC-Hybrid TLS 1.3

Capture:

```text
evidence/pqc-x25519mlkem768-validation.pcap
```

Observed:

```text
group=4588
classification=pqc_hybrid
```

Result:

```text
PASS
```

### Unified Migration Telemetry

Capture:

```text
evidence/live-x25519mlkem768-validation.pcap
```

Observed:

```text
group=4588
algorithm=X25519MLKEM768
classification=pqc_hybrid
migration_state=hybrid_negotiated
fallback=F
```

Result:

```text
PASS
```

## Negative / Edge Case

Test:

```text
group=12345
```

Expected:

```text
unknown
```

Observed:

```text
group=12345 expected=unknown actual=unknown
```

Result:

```text
PASS
```

This confirms that an unrecognized group is not incorrectly classified
as either classical or PQC-hybrid.

## BTest Regression Suite

The Zeek BTest regression suite was executed after implementation of
the unified `pqc-tls.log` output.

Command:

```bash
./testing/run-btest.sh
```

Result:

```text
all 3 tests successful
BTEST: PASS
```

Validated BTest cases:

* Classical X25519 group 29 → `classical`
* X25519MLKEM768 group 4588 → `pqc_hybrid`
* Unrecognized group 12345 → `unknown`

The PQC BTest also verifies the unified migration record in
`pqc-tls.log`:

```text
hybrid_capable
4588
X25519MLKEM768
pqc_hybrid
hybrid_negotiated
F
```

## Automated Validation

Run:

```bash
./testing/run-validation.sh
```

Expected result:

```text
PASS: 3
FAIL: 0
OVERALL RESULT: PASS
```

Observed validation result:

```text
PASS: 3
FAIL: 0
OVERALL RESULT: PASS
```

## Validation Pipeline

The validated project flow is:

```text
TLS packet capture
        |
        v
Zeek TLS telemetry
        |
        v
Cryptographic classification
        |
        v
Client capability analysis
        |
        v
Negotiated-group analysis
        |
        v
Migration-state classification
        |
        v
pqc-tls.log
```

## Evidence Integrity

The evidence directory contains packet captures and validation outputs.

Evidence SHA-256 values are recorded in:

```text
validation-manifest.md
```

The evidence includes:

* classical TLS 1.3 packet capture;
* PQC-hybrid TLS 1.3 packet capture;
* live X25519MLKEM768 validation capture;
* classical classification output;
* PQC-hybrid classification output;
* negative classifier evidence.

## Scope

The current validation demonstrates:

* X25519 as `classical`;
* X25519MLKEM768 as `pqc_hybrid`;
* unknown group values as `unknown`;
* hybrid-capable client detection;
* hybrid negotiation detection;
* unified `pqc-tls.log` generation;
* migration state `hybrid_negotiated`;
* fallback indication.

The validation does not claim exhaustive coverage of every existing
or future post-quantum TLS key-exchange group.

## Limitations

The migration state is derived from passive TLS telemetry.

`hybrid_capable` means that hybrid capability was observed in the
client handshake.

`fallback_to_classical` means that hybrid capability was observed but
a classical group was subsequently negotiated.

This is migration evidence, not proof of endpoint policy or the reason
for a particular cryptographic selection.

Unknown algorithms remain classified as `unknown` until explicitly
added to the cryptographic registry and validated.

## Reproducibility

The validated state can be reproduced with:

```bash
./testing/run-validation.sh
./testing/run-btest.sh
```

A direct unified-log replay can be performed with:

```bash
zeek -C \
  -r evidence/live-x25519mlkem768-validation.pcap \
  scripts/__load__.zeek \
  Log::default_logdir=/tmp/zeek-pqc-tls-final
```

The resulting directory should contain:

```text
pqc-tls.log
```

with a record showing:

```text
hybrid_capable
4588
X25519MLKEM768
pqc_hybrid
hybrid_negotiated
F
```

## Validation Conclusion

**PASS**

The project now demonstrates an end-to-end migration-observability
pipeline:

```text
Zeek TLS telemetry
        ->
cryptographic-agility classification
        ->
migration intelligence
        ->
pqc-tls.log
```

The implementation is therefore validated beyond basic PQC detection.
It provides a unified telemetry record for observing cryptographic
migration state from passive TLS evidence.

# Zeek PQC Migration Observatory

`zeek-pqc-migration` is a Zeek community package for passive TLS
cryptographic-migration observability.

The project is designed to complement algorithm-specific PQC detection
packages rather than duplicate their basic detection functionality.

Its purpose is to observe TLS cryptographic telemetry, classify
cryptographic-agility signals, and produce migration intelligence about
what clients appear capable of, what is negotiated, and whether a
hybrid-capable client falls back to a classical key exchange.

## Installation

Install the package using the Zeek Package Manager (`zkg`):

```bash
zkg refresh
zkg install zeek/sujalavnelavai/zeek-pqc-migration-observatory.git
```

Then load the package when running Zeek:

```bash
zeek zeek-pqc-migration-observatory
```

To analyze a packet capture:

```bash
zeek -C -r capture.pcap zeek-pqc-migration-observatory
```

The package writes the following logs by default:

- `pqc.log` — observed TLS key-exchange groups and classifications.
- `pqc-migration.log` — migration state and fallback telemetry.
- `pqc-tls.log` — TLS migration telemetry with connection metadata.


## Architecture

The project follows this processing model:

```text
Zeek TLS telemetry
        |
        v
Cryptographic-agility engine
        |
        v
Algorithm / group registry
        |
        v
Migration intelligence
        |
        v
pqc-tls.log
```

The package currently focuses on TLS 1.3 key-exchange groups.

## What the package observes

The implementation tracks:

* client-supported TLS key-exchange groups
* client key-share groups
* server key-share groups
* negotiated key-exchange group
* algorithm name
* cryptographic classification
* client cryptographic capability
* migration state
* fallback indication

The migration layer distinguishes between observed capability and the
key exchange actually selected by the TLS session.

## Unified migration output

The primary migration-observability output is:

```text
pqc-tls.log
```

Each record contains:

| Field                       | Description                                  |
| --------------------------- | -------------------------------------------- |
| `ts`                        | Network timestamp                            |
| `uid`                       | Zeek connection identifier                   |
| `id_orig_h`                 | Originating host                             |
| `id_orig_p`                 | Originating port                             |
| `id_resp_h`                 | Responding host                              |
| `id_resp_p`                 | Responding port                              |
| `client_capability`         | Observed client cryptographic capability     |
| `negotiated_group`          | Negotiated TLS key-exchange group            |
| `negotiated_algorithm`      | Registry algorithm name                      |
| `negotiated_classification` | `classical`, `pqc_hybrid`, or `unknown`      |
| `migration_state`           | Algorithm-independent migration state        |
| `fallback`                  | Whether fallback to classical was identified |

For example, a validated hybrid negotiation produces:

```text
client_capability=hybrid_capable
negotiated_group=4588
negotiated_algorithm=X25519MLKEM768
negotiated_classification=pqc_hybrid
migration_state=hybrid_negotiated
fallback=F
```

## Migration states

The migration engine currently supports these states:

### `hybrid_negotiated`

A PQC-hybrid group was selected and the client was observed to have
hybrid capability.

### `fallback_to_classical`

A client with observed hybrid capability negotiated a classical group.

This state is intended to provide migration intelligence rather than
merely report that a classical algorithm was observed.

### `classical_negotiated`

A classical group was negotiated and no hybrid capability was observed.

### `hybrid_selected_without_observed_capability`

A hybrid group was selected, but the available passive telemetry did not
show corresponding client hybrid capability.

### `handshake_failure`

A TLS handshake failed after relevant client cryptographic capability
was observed, but no negotiated key-exchange group could be established.

### `unknown_negotiation`

The observed negotiation cannot be mapped to a known migration state.

## Cryptographic registry

Algorithm-specific information is kept in the registry rather than
embedded throughout the migration logic.

The current validated registry includes:

|  Group | Algorithm        | Classification |
| -----: | ---------------- | -------------- |
|   `23` | `secp256r1`      | `classical`    |
|   `24` | `secp384r1`      | `classical`    |
|   `25` | `secp521r1`      | `classical`    |
|   `29` | `x25519`         | `classical`    |
|   `30` | `x448`           | `classical`    |
| `4588` | `X25519MLKEM768` | `pqc_hybrid`   |

The migration logic consumes the registry classification instead of
hard-coding individual algorithm names into migration decisions.

This allows additional algorithms to be incorporated through the
registry as the supported TLS ecosystem evolves.

## Relationship to PQC detection

The project is intentionally not positioned as a replacement for
algorithm-specific PQC detection.

The distinction is:

```text
PQC detection:
    "Was a PQC or hybrid algorithm observed?"

Migration observability:
    "What cryptographic capability was observed,
     what was negotiated,
     and what does that imply about migration state?"
```

The existing `pqc.log` output remains useful as passive classification
telemetry.

The `pqc-migration.log` output provides the migration-oriented record.

The `pqc-tls.log` output provides the unified TLS migration record.

## Validation

The current implementation has been validated against:

| Scenario               |   Group | Expected classification | Result |
| ---------------------- | ------: | ----------------------- | ------ |
| Classical TLS 1.3      |    `29` | `classical`             | PASS   |
| X25519MLKEM768 TLS 1.3 |  `4588` | `pqc_hybrid`            | PASS   |
| Unrecognized group     | `12345` | `unknown`               | PASS   |

The migration output has additionally been validated against the
X25519MLKEM768 TLS 1.3 evidence.

Expected unified record:

```text
hybrid_capable
4588
X25519MLKEM768
pqc_hybrid
hybrid_negotiated
F
```

## Automated tests

Run the BTest regression suite:

```bash
./testing/run-btest.sh
```

Expected result:

```text
all 3 tests successful
BTEST: PASS
```

Run the validation suite:

```bash
./testing/run-validation.sh
```

Expected result:

```text
PASS: 3
FAIL: 0
OVERALL RESULT: PASS
```

## Evidence

Validation packet captures and classification evidence are stored under:

```text
evidence/
```

The evidence includes classical TLS 1.3, PQC-hybrid TLS 1.3, and
negative/unknown-group validation cases.

## Scope

The current implementation focuses on passive TLS 1.3 key-exchange
telemetry and migration classification.

It does not claim complete coverage of every current or future PQC,
hybrid, TLS, or cryptographic-agility mechanism.

The classification registry is deliberately extensible, but individual
future algorithms must still be added and validated before they can be
classified.

## Limitations

Passive TLS telemetry is constrained by what Zeek can observe from the
TLS handshake.

The package does not infer cryptographic intent that is not present in
observable protocol metadata.

A passive observer may also be unable to distinguish every possible
reason for a classical negotiation. Therefore a migration state should
be interpreted as evidence derived from observed TLS telemetry, not as
proof of administrative policy or endpoint configuration.

## Project status

The current implementation provides:

* TLS 1.3 cryptographic telemetry collection
* cryptographic-agility classification
* algorithm registry abstraction
* client capability detection
* migration-state classification
* fallback identification
* unified `pqc-tls.log` output
* BTest regression coverage
* validated classical, hybrid, and unknown-group evidence

The project is suitable for continued community review and expansion
of the cryptographic registry and migration-state model.

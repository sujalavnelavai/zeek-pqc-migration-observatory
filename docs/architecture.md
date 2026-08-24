# Architecture

## Overview

Zeek PQC Migration Observatory separates TLS telemetry collection,
cryptographic classification, and migration intelligence.

```text
                 TLS traffic
                     |
                     v
              Zeek SSL analyzer
                     |
                     v
             TLS observation layer
                     |
                     v
          connection_state table
                     |
          +----------+----------+
          |                     |
          v                     v
   cryptographic          negotiated
    capability               group
          |                     |
          +----------+----------+
                     |
                     v
             registry lookup
                     |
                     v
        cryptographic classification
                     |
                     v
           migration intelligence
                     |
                     v
                pqc-tls.log
```

## Components

### `scripts/main.zeek`

Maintains per-connection TLS cryptographic state.

The state includes:

* client-supported groups
* server-supported groups
* client key-share groups
* server key-share groups
* HelloRetryRequest state

TLS extension events populate this state as handshake telemetry is
observed.

### `scripts/registry.zeek`

Provides the cryptographic registry.

The registry maps TLS group identifiers to:

* algorithm name
* cryptographic classification

The migration engine therefore consumes a classification abstraction
rather than directly depending on every individual algorithm.

### `scripts/classifier.zeek`

Provides algorithm/group classification and the existing passive
classification output.

Its role is cryptographic identification.

It does not make migration decisions.

### `scripts/migration.zeek`

Provides migration intelligence.

It:

1. determines observed client capability;
2. observes the selected server-side key share;
3. classifies the selected group;
4. determines an algorithm-independent migration state;
5. writes migration telemetry;
6. emits the unified `pqc-tls.log` record.

## Client capability

Client capability is derived from observed client TLS handshake
telemetry.

The current implementation considers both:

* client key-share groups
* client supported groups

The capability model currently distinguishes:

```text
hybrid_capable
classical_only
classical_and_hybrid
unknown
```

## Negotiation processing

The migration engine treats the server-side key share as the selected
negotiated group for the validated TLS 1.3 evidence.

This avoids treating every client-offered key share as a negotiated
algorithm.

The resulting group is passed through the registry before migration
classification.

## Migration decision model

The current decision model is:

```text
                negotiated group
                       |
             +---------+---------+
             |                   |
          hybrid              classical
             |                   |
             v                   v
     client hybrid?       client hybrid?
        /      \             /      \
      yes       no         yes       no
       |         |          |         |
       v         v          v         v
   hybrid_   hybrid_    fallback_  classical_
 negotiated  selected_  to_classical negotiated
             without
             observed
             capability
```

Handshake failures are handled separately because a failed handshake
does not establish a negotiated cryptographic group.

## Unified output

The migration record is written to:

```text
pqc-tls.log
```

The output combines connection identity, client capability, negotiated
cryptographic information, migration state, and fallback status.

This is the primary migration-observability interface of the package.

## Separation of concerns

The architecture deliberately separates:

```text
Telemetry
    |
    +--> Classification
    |
    +--> Migration intelligence
```

This allows the cryptographic registry to evolve without requiring the
migration-state logic to be rewritten for every new algorithm.

## Extensibility

A future registry entry can provide:

```text
TLS group
    -> algorithm name
    -> classification
```

The migration engine can then consume that classification through the
existing abstraction.

New migration states should be added only when they represent a
distinct and defensible interpretation of observable TLS telemetry.

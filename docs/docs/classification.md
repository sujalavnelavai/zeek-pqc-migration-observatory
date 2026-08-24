# Cryptographic Classification

## Purpose

The classification layer maps observed TLS key-exchange group identifiers
to an algorithm name and cryptographic category.

The current categories are:

* `classical`
* `pqc_hybrid`
* `unknown`

## Current registry

|  Group | Algorithm        | Classification |
| -----: | ---------------- | -------------- |
|   `23` | `secp256r1`      | `classical`    |
|   `24` | `secp384r1`      | `classical`    |
|   `25` | `secp521r1`      | `classical`    |
|   `29` | `x25519`         | `classical`    |
|   `30` | `x448`           | `classical`    |
| `4588` | `X25519MLKEM768` | `pqc_hybrid`   |

## Unknown groups

An unrecognized group is classified as:

```text
unknown
```

Unknown values are not automatically classified as either classical or
PQC.

This prevents the migration engine from making unsupported assumptions
about future or unrecognized cryptographic mechanisms.

## Classification versus migration

Classification answers:

```text
What cryptographic category does this group belong to?
```

Migration intelligence answers:

```text
What does the relationship between observed client capability
and negotiated cryptography indicate about migration?
```

For example:

```text
Group:
    4588

Classification:
    pqc_hybrid

Client capability:
    hybrid_capable

Migration state:
    hybrid_negotiated
```

These are deliberately separate concepts.

## Extensible design

Algorithm names are maintained in the registry.

Migration decisions consume the resulting classification rather than
matching every algorithm name individually.

This makes the migration logic less dependent on individual PQC
algorithm names and allows future registry expansion.

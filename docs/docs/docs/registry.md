# Cryptographic Registry

## Purpose

The cryptographic registry provides a central mapping between TLS
key-exchange group identifiers and cryptographic metadata.

Each entry contains:

```text
group ID
algorithm name
classification
```

## Current entries

| Group ID | Algorithm        | Classification |
| -------: | ---------------- | -------------- |
|     `23` | `secp256r1`      | `classical`    |
|     `24` | `secp384r1`      | `classical`    |
|     `25` | `secp521r1`      | `classical`    |
|     `29` | `x25519`         | `classical`    |
|     `30` | `x448`           | `classical`    |
|   `4588` | `X25519MLKEM768` | `pqc_hybrid`   |

## Registry API

The migration layer uses registry functions to obtain:

```text
registry_name(group)
registry_classify(group)
```

An unknown group receives:

```text
algorithm = group-<id>
classification = unknown
```

This ensures that an unrecognized group does not silently receive an
incorrect cryptographic classification.

## Why a registry is used

The migration engine should not contain logic such as:

```text
if group == 4588
    ...
```

Instead, the migration engine operates on the abstract classification:

```text
classical
pqc_hybrid
unknown
```

This provides a cleaner separation between cryptographic knowledge and
migration policy.

## Adding future algorithms

A future supported group should be added to the registry with:

1. the TLS group identifier;
2. the canonical algorithm name;
3. the appropriate classification;
4. validation evidence;
5. regression-test coverage.

Registry additions should not be considered validated until the
corresponding TLS evidence has been tested.

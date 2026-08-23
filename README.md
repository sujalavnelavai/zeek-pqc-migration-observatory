# Zeek PQC Migration Observatory

`zeek-pqc-migration` is a Zeek community package for passive
cryptographic migration observability in TLS networks.

The project separates:

- observation of TLS handshake evidence
- classification of cryptographic migration state

The initial scope is TLS 1.3.

The project is intended to provide visibility into:

- cryptographic capability
- negotiated key-exchange groups
- classical / hybrid / PQ behaviour
- migration state
- fallback evidence

The package is designed to complement, rather than replace,
algorithm-specific PQC detection packages.

## Status

Early development.

The package skeleton is currently being established before
implementation of the TLS observation and classification layers.

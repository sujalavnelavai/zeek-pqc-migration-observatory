# Zeek PQC Migration Observatory

`zeek-pqc-migration-observatory` is a Zeek community package for passive observability of post-quantum cryptographic (PQC) migration in TLS 1.3 traffic.

The project observes TLS handshake key-exchange evidence and classifies the observed migration state as classical, PQC-hybrid, or other registered states. It is designed to provide migration visibility without requiring decryption of application traffic.

## Project Status

**Validated working state**

The observatory has been validated against:

* classical TLS 1.3 X25519 traffic
* negative classifier cases
* PQC-hybrid TLS 1.3 traffic
* a live TLS 1.3 handshake using `X25519MLKEM768`
* a captured live PCAP subsequently processed by Zeek

The final live validation successfully produced:

```text
group=4588
algorithm=X25519MLKEM768
classification=pqc_hybrid
client_capability=hybrid_capable
migration_state=hybrid_negotiated
fallback=F
```

The complete validation record is available in `FINAL_VALIDATION_RECORD.md`.

## Architecture

The observatory separates:

1. **TLS observation** — obtains key-exchange evidence from the TLS handshake.
2. **Algorithm registry** — maps TLS group identifiers to algorithm names and migration classifications.
3. **Classification** — identifies classical, hybrid, and PQC-related groups.
4. **Migration state** — combines capability and negotiated-group evidence.
5. **Logging** — records the resulting migration observations in Zeek logs.

The main Zeek loading path is:

```text
scripts/__load__.zeek
        |
        +-- types.zeek
        +-- registry.zeek
        +-- logging.zeek
        +-- main.zeek
        +-- classifier.zeek
        +-- migration.zeek
```

## PQC Validation

The live validation used a custom OpenSSL 3.2.4 installation with liboqs and the OQS provider.

The validated TLS group was:

```text
X25519MLKEM768
```

The live TLS 1.3 client successfully connected to a local OpenSSL TLS server with:

```text
Protocol version: TLSv1.3
Ciphersuite: TLS_AES_256_GCM_SHA384
```

The certificate used for the isolated test was intentionally self-signed. The resulting certificate verification warning is therefore expected and is unrelated to the PQC key-exchange negotiation.

The important migration evidence was obtained from the TLS handshake itself and from the resulting Zeek classification.

## Live PCAP Evidence

The primary live evidence file is:

```text
evidence/live-x25519mlkem768-validation.pcap
```

Validation properties:

* PCAP format: libpcap
* captured packets: 15
* transport: TCP
* endpoint: `127.0.0.1:4433`
* TLS version: TLS 1.3
* negotiated group: `X25519MLKEM768`
* Zeek classification: `pqc_hybrid`
* migration state: `hybrid_negotiated`
* fallback: `F`

SHA-256:

```text
8baef39c0a3d9e6f4a3aacaf642d3aad5f4886dc6f0fcd9199b0542fcc9d7560
```

## Automated Tests

The project currently has three BTests:

```text
classical-pcap.test       PASS
classifier-negative.test  PASS
pqc-pcap.test             PASS
```

Final result:

```text
all 3 tests successful
BTEST: PASS
```

The non-fatal warning concerning `PQC::is_classical_group` does not prevent successful execution or validation.

## Evidence and Documentation

### Documentation

* `docs/architecture.md` — system architecture
* `docs/classification.md` — classification model
* `docs/registry.md` — algorithm/group registry
* `docs/limitations.md` — known limitations
* `test-matrix.md` — validation matrix

### Validation records

* `FINAL_VALIDATION_RECORD.md`
* `VALIDATION_STATUS.md`
* `validation-manifest.md`
* `validation-evidence.csv`

### PCAP evidence

* `evidence/classical-x25519-tls13-validation.pcap`
* `evidence/pqc-x25519mlkem768-validation.pcap`
* `evidence/live-x25519mlkem768-validation.pcap`
* `evidence/classifier-negative-test.txt`

## Reproducing the Zeek Validation

From the repository root:

```bash
bash testing/run-btest.sh
```

For the live PCAP:

```bash
zeek -C \
    -r evidence/live-x25519mlkem768-validation.pcap \
    scripts/__load__.zeek
```

The expected classification includes:

```text
PQC_CLASSIFICATION ... group=4588 classification=pqc_hybrid
PQC_MIGRATION ... capability=hybrid_capable group=4588 state=hybrid_negotiated fallback=F
```

## Scope and Limitations

This project provides **observability**, not cryptographic decryption.

It does not claim that every TLS implementation exposes identical handshake metadata, nor does a captured TLS group by itself prove that every cryptographic operation in an application is post-quantum.

The current implementation focuses on TLS 1.3 key-exchange-group evidence and a registry-driven classification model.

The isolated live test uses a self-signed certificate. Certificate verification was therefore intentionally not used as a trust validation mechanism for the demonstration.

## Safety and Isolation

The live PQC demonstration uses a local TLS endpoint on `127.0.0.1:4433` and an isolated test certificate.

The custom OpenSSL installation is kept separate from the system OpenSSL installation. The system OpenSSL remains unchanged.

## License

See `LICENSE`.

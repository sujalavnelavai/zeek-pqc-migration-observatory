# Zeek PQC Migration Observatory — Final Validation Record

## Validation Status

**PASS**

The validated classifier successfully distinguishes:

- Classical TLS 1.3 using X25519 (group 29)
- PQC-hybrid TLS 1.3 using X25519MLKEM768 (group 4588)
- Unrecognized group values as `unknown`

## Automated Validation

Command:

`./testing/run-validation.sh`

Result:

PASS: 3
FAIL: 0
OVERALL RESULT: PASS

## Evidence

| Artifact | SHA-256 |
|---|---|
| `evidence/classical-x25519-tls13-validation.pcap` | `14eb5896580eca1ce1a31b022230f38abab2953b6c92b219e0cabd234a8de2c7` |
| `evidence/classifier-negative-test.txt` | `91789e2cfe6b754d6c00f49f95a022f7b16a3579edc569f3d199016c4cc990f7` |
| `evidence/pqc-classification-classical.log` | `27acdac0d658abcc5fec6bd88f4806bba808c5daf1a71554195cda84a512deb8` |
| `evidence/pqc-classification-pqc.log` | `222a8bd0e3ccbaa3f8317aa9103235713401f3c917c9b7292791309bec8254e4` |
| `evidence/pqc-x25519mlkem768-validation.pcap` | `26de4caf3c8204404c4692cbebd960f5d570864155c7483077ea9d6a3dd987ed` |

## Validation Documents

| Document | SHA-256 |
|---|---|
| `test-matrix.md` | `e8db6542cd4c250048eab9ba69ca876e16807f60447b5fd99623fb348d4cd3ac` |
| `validation-evidence.csv` | `9f48bb80f50fbbba18128246cb963fb5baae0b3076d6f0a80ba2010ffa6a1e31` |
| `validation-manifest.md` | `8a361627916a7e053afddab404ee68b59572ea151e64a9271f551c446719eb29` |
| `VALIDATION_STATUS.md` | `a223a933143a776b604455179dbb749a81891fc5fc2ed12df0e5fe63b06135d7` |
| `testing/classifier-negative.zeek` | `15c8c9dc1ab37c0b8711f3567deb3d114c44a3cb142f398c3f43b39fa0306d65` |
| `testing/run-validation.sh` | `b3ad3bf85a6c13fb5e465f58c1ace889c701af65a19d265a8dbc9d5d75fff2d1` |

## Classifier

Validated production classifier:

`scripts/classifier.zeek`

No modification to the validated classifier is required.

## Scope

This record validates the observed classification behaviour for the
specific TLS 1.3 groups and captures listed above. It does not claim
complete coverage of all current or future post-quantum TLS groups.

## Reproducibility

The validation can be rerun with:

`./testing/run-validation.sh`

Expected result:

PASS: 3
FAIL: 0
OVERALL RESULT: PASS

## Baseline

The project is considered validated at this state. Further classifier
changes should be treated as a new development or validation iteration
and should not overwrite the evidence captured by this baseline.

## BTest Regression Suite

The Zeek BTest regression suite was executed successfully.

Command:

`./testing/run-btest.sh`

Result:

all 3 tests successful

BTEST: PASS

Validated BTest cases:

- Classical X25519 group 29 → `classical`
- X25519MLKEM768 group 4588 → `pqc_hybrid`
- Unrecognized group 12345 → `unknown`

BTest runner SHA-256:

`8037bfdeda73264fc32fbf6a837cadb2a87f804bbc34cd5a0702e24c7992b466`


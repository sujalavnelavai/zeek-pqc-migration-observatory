#!/bin/bash
set -u

PROJECT="$HOME/zeek-pqc-migration-observatory"
EVIDENCE="$PROJECT/evidence"

cd "$PROJECT" || exit 1

PASS=0
FAIL=0

run_test() {
    local name="$1"
    local command="$2"

    echo
    echo "========================================"
    echo "TEST: $name"
    echo "========================================"

    if eval "$command"; then
        echo "RESULT: PASS"
        PASS=$((PASS + 1))
    else
        echo "RESULT: FAIL"
        FAIL=$((FAIL + 1))
    fi
}

run_test \
    "TLS-CLASSICAL-01 — X25519 group 29" \
    "zeek -C -r '$EVIDENCE/classical-x25519-tls13-validation.pcap' scripts/__load__.zeek >/tmp/zeek-classical.out 2>&1 &&
     grep -q 'classification=classical' /tmp/zeek-classical.out"

run_test \
    "TLS-PQC-01 — X25519MLKEM768 group 4588" \
    "zeek -C -r '$EVIDENCE/pqc-x25519mlkem768-validation.pcap' scripts/__load__.zeek >/tmp/zeek-pqc.out 2>&1 &&
     grep -q 'classification=pqc_hybrid' /tmp/zeek-pqc.out"

run_test \
    "TLS-CLASSIFIER-NEG-01 — unknown group 12345" \
    "zeek testing/classifier-negative.zeek >/tmp/zeek-negative.out 2>&1 &&
     grep -q 'NEGATIVE/EDGE TEST: PASS' /tmp/zeek-negative.out"

echo
echo "========================================"
echo "VALIDATION SUMMARY"
echo "========================================"
echo "PASS: $PASS"
echo "FAIL: $FAIL"

if [ "$FAIL" -eq 0 ]; then
    echo "OVERALL RESULT: PASS"
    exit 0
else
    echo "OVERALL RESULT: FAIL"
    exit 1
fi

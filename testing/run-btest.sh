#!/bin/bash
set -u

PROJECT="$HOME/zeek-pqc-migration-observatory"

cd "$PROJECT" || exit 1

echo "===== ZEek PQC MIGRATION OBSERVATORY — BTEST ====="
echo

btest -D \
    testing/classical-pcap \
    testing/pqc-pcap \
    testing/classifier-negative

RESULT=$?

echo
echo "===== BTEST RESULT ====="

if [ "$RESULT" -eq 0 ]; then
    echo "BTEST: PASS"
else
    echo "BTEST: FAIL"
fi

exit "$RESULT"

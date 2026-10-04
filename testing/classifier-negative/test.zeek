@TEST-EXEC: zeek -C %DIR/../classifier-negative.zeek > /tmp/pqc-btest-negative.out
@TEST-EXEC: grep -q 'TEST group=29 expected=classical actual=classical' /tmp/pqc-btest-negative.out
@TEST-EXEC: grep -q 'TEST group=4588 expected=pqc_hybrid actual=pqc_hybrid' /tmp/pqc-btest-negative.out
@TEST-EXEC: grep -q 'TEST group=12345 expected=unknown actual=unknown' /tmp/pqc-btest-negative.out
@TEST-EXEC: grep -q 'NEGATIVE/EDGE TEST: PASS' /tmp/pqc-btest-negative.out

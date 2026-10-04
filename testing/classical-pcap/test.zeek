@TEST-EXEC: rm -f pqc.log && zeek -C -r %DIR/../../evidence/classical-x25519-tls13-validation.pcap %DIR/../../scripts/__load__.zeek
@TEST-EXEC: grep -Pq '(^|\t)29\tx25519\tclassical$' pqc.log

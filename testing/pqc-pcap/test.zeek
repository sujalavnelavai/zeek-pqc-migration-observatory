@TEST-EXEC: rm -f pqc.log pqc-migration.log pqc-tls.log && zeek -C -r %DIR/../../evidence/pqc-x25519mlkem768-validation.pcap %DIR/../../scripts/__load__.zeek
@TEST-EXEC: grep -Pq '(^|\t)4588\tX25519MLKEM768\tpqc_hybrid$' pqc.log
@TEST-EXEC: grep -Pq '(^|\t)hybrid_capable\t4588\tX25519MLKEM768\tpqc_hybrid\thybrid_negotiated\tF$' pqc-tls.log

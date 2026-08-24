@TEST-EXEC: cd /home/sujala/zeek-pqc-migration-observatory && rm -f pqc.log pqc-migration.log pqc-tls.log && zeek -C -r evidence/pqc-x25519mlkem768-validation.pcap scripts/__load__.zeek
@TEST-EXEC: cd /home/sujala/zeek-pqc-migration-observatory && grep -Pq '(^|\t)4588\tX25519MLKEM768\tpqc_hybrid$' pqc.log
@TEST-EXEC: cd /home/sujala/zeek-pqc-migration-observatory && grep -Pq '(^|\t)hybrid_capable\t4588\tX25519MLKEM768\tpqc_hybrid\thybrid_negotiated\tF$' pqc-tls.log

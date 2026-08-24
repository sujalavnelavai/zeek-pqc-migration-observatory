@TEST-EXEC: cd /home/sujala/zeek-pqc-migration-observatory && rm -f pqc.log && zeek -C -r evidence/classical-x25519-tls13-validation.pcap scripts/__load__.zeek
@TEST-EXEC: cd /home/sujala/zeek-pqc-migration-observatory && grep -Pq '(^|\t)29\tx25519\tclassical$' pqc.log

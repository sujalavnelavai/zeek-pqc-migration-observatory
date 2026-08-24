function is_classical_group(group: count): bool
	{
	if ( group == 23 ||
	     group == 24 ||
	     group == 25 ||
	     group == 29 ||
	     group == 30 ||
	     (group >= 256 && group <= 260) )
		return T;

	return F;
	}

function classify_group_test(group: count): string
	{
	if ( is_classical_group(group) )
		return "classical";

	if ( group == 4588 )
		return "pqc_hybrid";

	return "unknown";
	}

event zeek_init()
	{
	local result29 = classify_group_test(29);
	local result4588 = classify_group_test(4588);
	local result12345 = classify_group_test(12345);

	print fmt("TEST group=29 expected=classical actual=%s", result29);
	print fmt("TEST group=4588 expected=pqc_hybrid actual=%s", result4588);
	print fmt("TEST group=12345 expected=unknown actual=%s", result12345);

	if ( result29 == "classical" &&
	     result4588 == "pqc_hybrid" &&
	     result12345 == "unknown" )
		print "NEGATIVE/EDGE TEST: PASS";
	else
		print "NEGATIVE/EDGE TEST: FAIL";

	terminate();
	}

module PQC;

export {
	type AlgorithmInfo: record {
		name: string;
		classification: string;
	};

	global algorithm_registry: table[count] of AlgorithmInfo;
}

event zeek_init()
	{
	# Classical TLS groups
	algorithm_registry[23] = [
		$name = "secp256r1",
		$classification = "classical"
	];

	algorithm_registry[24] = [
		$name = "secp384r1",
		$classification = "classical"
	];

	algorithm_registry[25] = [
		$name = "secp521r1",
		$classification = "classical"
	];

	algorithm_registry[29] = [
		$name = "x25519",
		$classification = "classical"
	];

	algorithm_registry[30] = [
		$name = "x448",
		$classification = "classical"
	];

	# X25519MLKEM768 hybrid group used by the validated environment.
	algorithm_registry[4588] = [
		$name = "X25519MLKEM768",
		$classification = "pqc_hybrid"
	];
	}

function registry_classify(group: count): string
	{
	if ( group in algorithm_registry )
		return algorithm_registry[group]$classification;

	return "unknown";
	}

function registry_name(group: count): string
	{
	if ( group in algorithm_registry )
		return algorithm_registry[group]$name;

	return fmt("group-%d", group);
	}

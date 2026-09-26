module PQC;

export {
	redef enum Log::ID += {
		MIGRATION_LOG,
		TLS_LOG
	};

	type MigrationInfo: record {
		ts: time &log;
		uid: string &log;

		client_capability: string &log;

		negotiated_group: count &log;
		negotiated_algorithm: string &log;
		negotiated_classification: string &log;

		migration_state: string &log;
		fallback: bool &log;
	};

	type TLSInfo: record {
		ts: time &log;
		uid: string &log;

		id_orig_h: addr &log;
		id_orig_p: port &log;
		id_resp_h: addr &log;
		id_resp_p: port &log;

		client_capability: string &log;

		negotiated_group: count &log;
		negotiated_algorithm: string &log;
		negotiated_classification: string &log;

		migration_state: string &log;
		fallback: bool &log;
	};

	global migration_observed:
		event(c: connection, group: count, state: string, fallback: bool);
}

event zeek_init()
	{
	Log::create_stream(PQC::MIGRATION_LOG,
		[$columns=MigrationInfo, $path="pqc-migration"]);

	Log::create_stream(PQC::TLS_LOG,
		[$columns=TLSInfo, $path="pqc-tls"]);
	}

function has_classification(groups: index_vec, wanted: string): bool
	{
	for ( i in groups )
		{
		if ( classify_group(groups[i]) == wanted )
			return T;
		}

	return F;
	}

function client_capability(c: connection): string
	{
	local uid = c$uid;

	if ( uid !in connection_state )
		return "unknown";

	local state = connection_state[uid];

	local client_hybrid =
		has_classification(state$initial_client_key_share_groups,
		                   "pqc_hybrid");

	local client_classical =
		has_classification(state$initial_client_key_share_groups,
		                   "classical");

	if ( ! client_hybrid )
		client_hybrid =
			has_classification(state$initial_client_supported_groups,
			                   "pqc_hybrid");

	if ( ! client_classical )
		client_classical =
			has_classification(state$initial_client_supported_groups,
			                   "classical");

	# Fall back to current ClientHello state when no initial
	# capability was preserved.
	if ( ! client_hybrid && ! client_classical )
		{
		client_hybrid =
			has_classification(state$client_key_share_groups,
			                   "pqc_hybrid");

		client_classical =
			has_classification(state$client_key_share_groups,
			                   "classical");

		if ( ! client_hybrid )
			client_hybrid =
				has_classification(state$client_supported_groups,
				                   "pqc_hybrid");

		if ( ! client_classical )
			client_classical =
				has_classification(state$client_supported_groups,
				                   "classical");
		}

	if ( client_hybrid && client_classical )
		return "classical_and_hybrid";

	if ( client_hybrid )
		return "hybrid_capable";

	if ( client_classical )
		return "classical_only";

	return "unknown";
	}

function write_migration(c: connection, capability: string,
                         group: count, state: string,
                         fallback: bool)
	{
	local classification = classify_group(group);
	local algorithm = registry_name(group);

	Log::write(PQC::MIGRATION_LOG, [
		$ts = network_time(),
		$uid = c$uid,
		$client_capability = capability,
		$negotiated_group = group,
		$negotiated_algorithm = algorithm,
		$negotiated_classification = classification,
		$migration_state = state,
		$fallback = fallback
	]);

	Log::write(PQC::TLS_LOG, [
		$ts = network_time(),
		$uid = c$uid,
		$id_orig_h = c$id$orig_h,
		$id_orig_p = c$id$orig_p,
		$id_resp_h = c$id$resp_h,
		$id_resp_p = c$id$resp_p,
		$client_capability = capability,
		$negotiated_group = group,
		$negotiated_algorithm = algorithm,
		$negotiated_classification = classification,
		$migration_state = state,
		$fallback = fallback
	]);

	print fmt("PQC_MIGRATION uid=%s capability=%s group=%s state=%s fallback=%s",
		c$uid, capability, group, state, fallback);

	event migration_observed(c, group, state, fallback);
	}

event key_share_observed(c: connection, is_client: bool, group: count)
	{
	# Server key shares are only candidates until the corresponding
	# ServerHello is known not to be a HelloRetryRequest.
	if ( is_client )
		return;

	local uid = c$uid;

	if ( uid !in connection_state )
		return;

	local state = connection_state[uid];
	state$server_key_share_groups = vector();
	state$server_key_share_groups[0] = group;
	connection_state[uid] = state;
	}

event ssl_server_hello(c: connection, version: count,
                           record_version: count, possible_ts: time,
                           server_random: string, session_id: string,
                           cipher: count, comp_method: count)
	{
	if ( ! c?$ssl )
		return;

	local uid = c$uid;

	if ( uid !in connection_state )
		return;

	# Zeek's native SSL analyzer marks HRR ServerHello messages
	# with c$ssl$hrr_seen before this handler runs.
	if ( c$ssl$hrr_seen )
		return;

	local state = connection_state[uid];

	if ( |state$server_key_share_groups| == 0 )
		return;

	local group = state$server_key_share_groups[0];
	local capability = client_capability(c);
	local negotiated = classify_group(group);
	local migration = "unknown_negotiation";
	local fallback = F;

	if ( negotiated == "pqc_hybrid" )
		{
		if ( capability == "hybrid_capable" ||
		     capability == "classical_and_hybrid" )
			migration = "hybrid_negotiated";
		else
			migration = "hybrid_selected_without_observed_capability";
		}
	else if ( negotiated == "classical" )
		{
		if ( capability == "hybrid_capable" ||
		     capability == "classical_and_hybrid" )
			{
			migration = "fallback_to_classical";
			fallback = T;
			}
		else
			migration = "classical_negotiated";
		}

	write_migration(c, capability, group, migration, fallback);

	# Prevent duplicate migration emission if another non-HRR
	# ServerHello event is observed for the same connection.
	state$server_key_share_groups = vector();
	connection_state[uid] = state;
	}

event ssl_alert(c: connection, is_client: bool, level: count, desc: count)
	{
	# A TLS alert by itself does not establish a migration outcome.
	# The final connection state is evaluated when the SSL analyzer
	# is finalized.
	}

hook SSL::finalize_ssl(c: connection)
	{
	if ( ! c?$ssl )
		return;

	# Successful negotiations are already handled by
	# key_share_observed(). Do not emit a second migration record.
	if ( c$ssl$established )
		return;

	# A failed TLS handshake is evidence of failure, not negotiation.
	# Record it only when we observed a client key-share capability
	# and the connection actually ended unsuccessfully.
	local capability = client_capability(c);

	if ( capability == "unknown" )
		return;

	local uid = c$uid;

	if ( uid !in connection_state )
		return;

	local state = connection_state[uid];

	if ( |state$client_key_share_groups| == 0 &&
	     |state$client_supported_groups| == 0 )
		return;

	Log::write(PQC::MIGRATION_LOG, [
		$ts = network_time(),
		$uid = uid,
		$client_capability = capability,
		$negotiated_group = 0,
		$negotiated_algorithm = "-",
		$negotiated_classification = "unknown",
		$migration_state = "handshake_failure",
		$fallback = F
	]);

	print fmt("PQC_MIGRATION uid=%s capability=%s group=0 state=handshake_failure fallback=F",
		uid, capability);

	event migration_observed(c, 0, "handshake_failure", F);
	}

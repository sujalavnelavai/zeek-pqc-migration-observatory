module PQC;

global connection_state: table[string] of ConnectionState &write_expire=1hr;

function ensure_connection_state(c: connection): string
	{
	local uid = c$uid;

	if ( uid !in connection_state )
		{
		connection_state[uid] = [
			$client_supported_groups = vector(),
			$server_supported_groups = vector(),
			$client_key_share_groups = vector(),
			$server_key_share_groups = vector(),
			$saw_hrr = F
		];
		}

	return uid;
	}

event ssl_extension_elliptic_curves(c: connection, is_client: bool,
                                    curves: index_vec)
	{
	local uid = ensure_connection_state(c);
	local state = connection_state[uid];

	if ( is_client )
		state$client_supported_groups = curves;
	else
		state$server_supported_groups = curves;

	connection_state[uid] = state;
	}

event ssl_extension_key_share(c: connection, is_client: bool,
                              curves: index_vec)
	{
	local uid = ensure_connection_state(c);
	local state = connection_state[uid];

	if ( is_client )
		state$client_key_share_groups = curves;
	else
		state$server_key_share_groups = curves;

	connection_state[uid] = state;
	}

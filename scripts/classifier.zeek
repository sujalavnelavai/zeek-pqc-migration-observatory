module PQC;

export {
	redef enum Log::ID += {
		LOG
	};

	type Info: record {
		ts: time &log;
		uid: string &log;
		id_orig_h: addr &log;
		id_orig_p: port &log;
		id_resp_h: addr &log;
		id_resp_p: port &log;

		group: count &log;
		algorithm: string &log;
		classification: string &log;
	};

	global log_pqc: event(rec: Info);

	global key_share_observed:
		event(c: connection, is_client: bool, group: count);
	}

function classify_group(group: count): string
	{
	return registry_classify(group);
	}

event zeek_init()
	{
	Log::create_stream(PQC::LOG, [$columns=Info, $path="pqc"]);
	}

event ssl_extension_key_share(c: connection, is_client: bool, curves: index_vec)
	{
	for ( i in curves )
		{
		local group = curves[i];
		local classification = classify_group(group);

		if ( is_client )
			{
			Log::write(PQC::LOG, [
				$ts = network_time(),
				$uid = c$uid,
				$id_orig_h = c$id$orig_h,
				$id_orig_p = c$id$orig_p,
				$id_resp_h = c$id$resp_h,
				$id_resp_p = c$id$resp_p,
				$group = group,
				$algorithm = registry_name(group),
				$classification = classification
			]);

			print fmt("PQC_CLASSIFICATION uid=%s group=%s classification=%s",
			          c$uid, group, classification);
			}

		event key_share_observed(c, is_client, group);
		}
	}

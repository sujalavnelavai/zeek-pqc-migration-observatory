module PQC;

type ConnectionState: record {
    client_supported_groups: index_vec;
    server_supported_groups: index_vec;

    client_key_share_groups: index_vec;
    server_key_share_groups: index_vec;

    initial_client_supported_groups: index_vec;
    initial_client_key_share_groups: index_vec;

    saw_hrr: bool &default=F;
};

enum VpnStage {
  prepare,
  authenticating,
  connecting,
  authentication,
  connected,
  disconnected,
  disconnecting,
  denied,
  error,
  // ignore: constant_identifier_names
  wait_connection,
  // ignore: constant_identifier_names
  vpn_generate_config,
  // ignore: constant_identifier_names
  get_config,
  // ignore: constant_identifier_names
  tcp_connect,
  // ignore: constant_identifier_names
  udp_connect,
  // ignore: constant_identifier_names
  assign_ip,
  resolve,
  exiting,
  unknown,
}

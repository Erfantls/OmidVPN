part of 'home_controller.dart';

class ServerInfoAsyncNotifier extends AsyncNotifier<ServerInfo?> {
  @override
  Future<ServerInfo?> build() async {
    // Get the server name from the VPN service
    final openvpnService = await ref.watch(openvpnServiceProvider.future);

    // Return the cached server info if available
    if (openvpnService.cachedServerInfo != null) {
      return openvpnService.cachedServerInfo;
    }

    // Fallback to minimal server info with just the hostname
    if (openvpnService.serverName != null) {
      return ServerInfo.empty().copyWith(hostName: openvpnService.serverName);
    }

    return null;
  }

  void setServerInfo(ServerInfo? server) {
    state = AsyncData(server);
  }
}

final _serverInfoNotifier = AsyncNotifierProvider(ServerInfoAsyncNotifier.new);

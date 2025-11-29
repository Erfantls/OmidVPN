part of 'server_list_controller.dart';

mixin ServerListState {
  AsyncValue<List<ServerInfo>> serverListState(WidgetRef ref) =>
      ref.watch(serverListAsyncNotifier);

  AsyncValue<List<ServerInfo>> filteredServerListState(WidgetRef ref) {
    final serverList = ref.watch(serverListAsyncNotifier);
    final selectedCountry = ref.watch(selectedCountryProvider);

    return serverList.whenData((servers) {
      final sortedServers = List<ServerInfo>.from(servers)
        ..sort((a, b) => toDays(a.uptime).compareTo(toDays(b.uptime)));

      if (selectedCountry == null) {
        return sortedServers;
      }
      return sortedServers
          .where(
            (server) =>
                server.countryShort.toLowerCase() ==
                selectedCountry.toLowerCase(),
          )
          .toList();
    });
  }

  int toMegaBytes(int bytes) {
    return (bytes / 1000 / 1000).round();
  }

  int toDays(int milliseconds) {
    return (milliseconds / 1000 / 60 / 60 / 24).round();
  }
}

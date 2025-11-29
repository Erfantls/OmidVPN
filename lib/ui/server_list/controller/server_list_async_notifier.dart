part of 'server_list_controller.dart';

class ServerListAsyncNotifier extends AsyncNotifier<List<ServerInfo>> {
  @override
  Future<List<ServerInfo>> build() async {
    final VpnRepository vpngateRepository = await ref.watch(
      vpngateRepositoryProvider.future,
    );
    return await vpngateRepository.getServerList(getCache: true);
  }

  void getServerList({bool forceRefresh = false, bool getCache = false}) async {
    state = AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final vpngateRepository = await ref.read(
        vpngateRepositoryProvider.future,
      );
      return vpngateRepository.getServerList(
        forceRefresh: forceRefresh,
        getCache: getCache,
      );
    });
  }

  /// Filter the current server list by country
  void filterByCountry(String? countryCode) {
    // Update the selected country provider
    ref.read(selectedCountryProvider.notifier).state = countryCode;
  }
}

final serverListAsyncNotifier = AsyncNotifierProvider(
  ServerListAsyncNotifier.new,
);

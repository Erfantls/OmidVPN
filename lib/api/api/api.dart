import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:omidvpn/api/domain/entity/vpn_stage.dart';
import 'package:omidvpn/api/lang/en.dart';
import 'package:omidvpn/ui/shared/openvpn_service.dart';
import 'package:omidvpn/ui/server_list/data/data_source/json_server_source.dart';
import 'package:omidvpn/ui/server_list/data/repository/json_server_repository.dart';
import 'package:omidvpn/ui/shared/one_day_cache.dart';

final langProvider = Provider((ref) => LangEN());
final oneDayFileCacheManagerProvider = FutureProvider(
  (ref) => OneDayFileCacheManager.create(appname: 'omidvpn', dirname: 'cache'),
);

final dioProvider = Provider((ref) => Dio());

final vpngateRepositoryProvider = FutureProvider((Ref ref) async {
  final dio = ref.watch(dioProvider);
  final cacheManager = await ref.watch(oneDayFileCacheManagerProvider.future);

  return JsonServerRepository(
    remoteSource: JsonServerRemoteSource(
      dio: dio,
      baseURL:
          'https://raw.githubusercontent.com/fdciabdul/Vpngate-Scraper-API/refs/heads/main/json/data.json',
    ),
    localSource: cacheManager,
    cacheKey: 'json_servers.json',
  );
});

final openvpnServiceProvider = FutureProvider((ref) async {
  final cacheManager = await ref.watch(oneDayFileCacheManagerProvider.future);

  final openvpnService = OpenvpnService(
    cacheManager: cacheManager,
    configCipherFix: true,
    serverNameCacheKey: 'servername.txt',
    serverInfoCacheKey: 'serverinfo.txt',
  );

  openvpnService.ensureInitialized();

  return openvpnService;
});

final vpnStageProvider = StreamProvider<VpnStage>((ref) async* {
  final openvpnService = await ref.watch(openvpnServiceProvider.future);
  await for (final value in openvpnService.stageStream) {
    yield value;
  }
});

import 'dart:convert';

import 'package:omidvpn/api/domain/entity/server_info.dart';
import 'package:omidvpn/api/domain/repository/vpn_repository.dart';
import 'package:omidvpn/ui/server_list/data/data_source/json_server_source.dart';
import 'package:omidvpn/ui/server_list/data/mapper/json_server_list_mapper.dart';
import 'package:omidvpn/ui/shared/one_day_cache.dart';

class JsonServerRepository implements VpnRepository {
  final JsonServerRemoteSource remoteSource;
  final OneDayFileCacheManager localSource;

  final String _cacheKey;

  JsonServerRepository({
    required this.remoteSource,
    required this.localSource,
    required cacheKey,
  }) : _cacheKey = cacheKey;

  @override
  Future<List<ServerInfo>> getServerList({
    bool forceRefresh = false,
    bool getCache = false,
  }) async {
    assert((forceRefresh && getCache) != true);

    final String? cachedJson = await localSource.read(
      key: _cacheKey,
      getExpired: getCache,
    );
    if (cachedJson != null && !forceRefresh) {
      final List<dynamic> jsonData = cachedJson.startsWith('[')
          ? (jsonDecode(cachedJson) as List<dynamic>)
          : [];
      return JsonServerListMapper.fromJson(jsonData: jsonData);
    }

    final List<dynamic> jsonData = await remoteSource.getServerList();
    final jsonString = jsonEncode(jsonData);
    localSource.save(key: _cacheKey, content: jsonString);
    return JsonServerListMapper.fromJson(jsonData: jsonData);
  }
}

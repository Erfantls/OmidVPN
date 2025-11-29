import 'package:omidvpn/api/domain/entity/server_info.dart';

abstract class VpnRepository {
  Future<List<ServerInfo>> getServerList({
    bool forceRefresh = false,
    bool getCache = false,
  });
}

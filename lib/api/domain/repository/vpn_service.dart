import 'package:omidvpn/api/domain/entity/vpn_stage.dart';

abstract class VpnService {
  VpnStage get vpnstage;
  String? get serverName;

  static VpnStage defaultVpnStage = VpnStage.disconnected;

  Stream<VpnStage> get stageStream;

  void connect({required String serverName, required String config}) {}

  void disconnect() {}
}

///To store datas of VPN Connection's status detail
class VpnStat {
  VpnStat({
    this.duration,
    this.connectedOn,
    this.byteIn,
    this.byteOut,
    this.packetsIn,
    this.packetsOut,
  });

  final DateTime? connectedOn;
  final String? duration;
  final String? byteIn;
  final String? byteOut;
  final String? packetsIn;
  final String? packetsOut;

  factory VpnStat.empty() => VpnStat(
    duration: "00:00:00",
    connectedOn: null,
    byteIn: "0",
    byteOut: "0",
    packetsIn: "0",
    packetsOut: "0",
  );

  Map<String, dynamic> toJson() => {
    "connected_on": connectedOn,
    "duration": duration,
    "byte_in": byteIn,
    "byte_out": byteOut,
    "packets_in": packetsIn,
    "packets_out": packetsOut,
  };

  @override
  String toString() => toJson().toString();
}

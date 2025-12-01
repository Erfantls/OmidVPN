class ServerInfo {
  final String hostName;
  final String ip;
  final int score;
  final int ping;
  final int speed;
  final String countryShort;
  final String countryLong;
  final int numVpnSessions;
  final int uptime;
  final int totalUsers;
  final int totalTraffic;
  final String logType;
  final String operator;
  final String message;
  final String vpnConfig;
  final bool isPremium; // Add this field to track premium servers

  ServerInfo({
    required this.hostName,
    required this.ip,
    required this.score,
    required this.ping,
    required this.speed,
    required this.countryShort,
    required this.countryLong,
    required this.numVpnSessions,
    required this.uptime,
    required this.totalUsers,
    required this.totalTraffic,
    required this.logType,
    required this.operator,
    required this.message,
    required this.vpnConfig,
    this.isPremium = false, // Default to false
  });

  ServerInfo.empty()
    : hostName = '',
      ip = '',
      score = -1,
      ping = -1,
      speed = -1,
      countryShort = '',
      countryLong = '',
      numVpnSessions = -1,
      uptime = -1,
      totalUsers = -1,
      totalTraffic = 1,
      logType = '',
      operator = '',
      message = '',
      vpnConfig = '',
      isPremium = false;

  copyWith({
    String? hostName,
    String? ip,
    int? score,
    int? ping,
    int? speed,
    String? countryShort,
    String? countryLong,
    int? numVpnSessions,
    int? uptime,
    int? totalUsers,
    int? totalTraffic,
    String? logType,
    String? operator,
    String? message,
    String? vpnConfig,
    bool? isPremium,
  }) {
    return ServerInfo(
      hostName: hostName ?? this.hostName,
      ip: ip ?? this.ip,
      score: score ?? this.score,
      ping: ping ?? this.ping,
      speed: speed ?? this.speed,
      countryShort: countryShort ?? this.countryShort,
      countryLong: countryLong ?? this.countryLong,
      numVpnSessions: numVpnSessions ?? this.numVpnSessions,
      uptime: uptime ?? this.uptime,
      totalUsers: totalUsers ?? this.totalUsers,
      totalTraffic: totalTraffic ?? this.totalTraffic,
      logType: logType ?? this.logType,
      operator: operator ?? this.operator,
      message: message ?? this.message,
      vpnConfig: vpnConfig ?? this.vpnConfig,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
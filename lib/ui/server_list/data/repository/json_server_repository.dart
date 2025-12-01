import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:omidvpn/api/domain/entity/server_info.dart';
import 'package:omidvpn/api/domain/repository/vpn_repository.dart';
import 'package:omidvpn/ui/server_list/data/data_source/json_server_source.dart';
import 'package:omidvpn/ui/server_list/data/mapper/json_server_list_mapper.dart';
import 'package:omidvpn/ui/shared/one_day_cache.dart';

class JsonServerRepository implements VpnRepository {
  final JsonServerRemoteSource remoteSource;
  final OneDayFileCacheManager localSource;
  final List<JsonServerRemoteSource> additionalSources;

  final String _cacheKey;

  JsonServerRepository({
    required this.remoteSource,
    required this.localSource,
    this.additionalSources = const [],
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
      // Parse cached data and ensure we deduplicate it as well
      final List<ServerInfo> cachedServers = [];
      for (final item in jsonData) {
        if (item is Map<String, dynamic>) {
          cachedServers.add(
            ServerInfo(
              hostName: item['hostName'] as String? ?? '',
              ip: item['ip'] as String? ?? '',
              score: item['score'] as int? ?? 0,
              ping: item['ping'] as int? ?? -1,
              speed: item['speed'] as int? ?? 0,
              countryShort: item['countryShort'] as String? ?? '',
              countryLong: item['countryLong'] as String? ?? '',
              numVpnSessions: item['numVpnSessions'] as int? ?? 0,
              uptime: item['uptime'] as int? ?? 0,
              totalUsers: item['totalUsers'] as int? ?? 0,
              totalTraffic: item['totalTraffic'] as int? ?? 0,
              logType: item['logType'] as String? ?? '',
              operator: item['operator'] as String? ?? '',
              message: item['message'] as String? ?? '',
              vpnConfig: item['vpnConfig'] as String? ?? '',
              isPremium: item['isPremium'] as bool? ?? false,
            ),
          );
        }
      }
      
      // Deduplicate cached servers as well
      final Map<String, ServerInfo> uniqueCachedServers = {};
      for (final server in cachedServers) {
        uniqueCachedServers[server.hostName] = server;
      }
      
      return uniqueCachedServers.values.toList();
    }

    // Check if user is continuing without license
    final prefs = await SharedPreferences.getInstance();
    final continueWithoutLicense = prefs.getBool('continue_without_license') ?? false;
    final licenseKey = prefs.getString('premium_license_key');

    // Fetch data from primary source
    final List<dynamic> primaryData = await remoteSource.getServerList();
    
    // Fetch data from additional sources
    List<ServerInfo> combinedServers = [];
    
    // Add primary servers (not premium)
    combinedServers.addAll(
      JsonServerListMapper.fromJson(jsonData: primaryData, isPremiumSource: false)
    );
    
    // Only add premium servers if user has a license or hasn't chosen to continue without one
    if (licenseKey != null && licenseKey.isNotEmpty) {
      // If license exists, add the premium server source
      try {
        final premiumSource = JsonServerRemoteSource(
          dio: remoteSource.dio, // Use the same dio instance
          baseURL:
              'https://raw.githubusercontent.com/code3-dev/omidvpn-api/refs/heads/master/api/$licenseKey/index.json',
        );
        final additionalData = await premiumSource.getServerList();
        // Add premium servers with the premium flag set to true
        combinedServers.addAll(
          JsonServerListMapper.fromJson(jsonData: additionalData, isPremiumSource: true)
        );
      } catch (e) {
        // Continue without premium servers if there's an error
        print('Error fetching premium servers: $e');
      }
    } else if (!continueWithoutLicense) {
      // If user hasn't made a choice about continuing without license,
      // we still try to load premium servers (for backward compatibility)
      try {
        final premiumSource = JsonServerRemoteSource(
          dio: remoteSource.dio, // Use the same dio instance
          baseURL:
              'https://raw.githubusercontent.com/code3-dev/omidvpn-api/refs/heads/master/api/$licenseKey/index.json',
        );
        final additionalData = await premiumSource.getServerList();
        // Add premium servers with the premium flag set to true
        combinedServers.addAll(
          JsonServerListMapper.fromJson(jsonData: additionalData, isPremiumSource: true)
        );
      } catch (e) {
        // Continue without premium servers if there's an error
        print('Error fetching premium servers: $e');
      }
    }
    // If continueWithoutLicense is true, we don't load premium servers
    
    // Also include any additional sources passed in constructor (only if not continuing without license)
    if (!continueWithoutLicense) {
      for (final source in additionalSources) {
        try {
          final additionalData = await source.getServerList();
          // For additional sources, we'll assume they are premium sources
          combinedServers.addAll(
            JsonServerListMapper.fromJson(jsonData: additionalData, isPremiumSource: true)
          );
        } catch (e) {
          // Continue with other sources if one fails
          continue;
        }
      }
    }
    
    // Deduplicate servers based on hostname to prevent duplicates
    final Map<String, ServerInfo> uniqueServers = {};
    for (final server in combinedServers) {
      // Use hostname as the key to identify unique servers
      uniqueServers[server.hostName] = server;
    }
    
    // Convert back to list
    final List<ServerInfo> deduplicatedServers = uniqueServers.values.toList();

    final jsonString = jsonEncode(deduplicatedServers.map((s) => {
      'hostName': s.hostName,
      'ip': s.ip,
      'score': s.score,
      'ping': s.ping,
      'speed': s.speed,
      'countryShort': s.countryShort,
      'countryLong': s.countryLong,
      'numVpnSessions': s.numVpnSessions,
      'uptime': s.uptime,
      'totalUsers': s.totalUsers,
      'totalTraffic': s.totalTraffic,
      'logType': s.logType,
      'operator': s.operator,
      'message': s.message,
      'vpnConfig': s.vpnConfig,
      'isPremium': s.isPremium,
    }).toList());
    localSource.save(key: _cacheKey, content: jsonString);
    return deduplicatedServers;
  }
}
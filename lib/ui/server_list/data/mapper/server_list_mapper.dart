import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart';
import 'package:omidvpn/api/domain/entity/server_info.dart';

sealed class ServerListMapper {
  static List<ServerInfo> fromCSV({required String csv}) {
    int rowLength = 15;

    List<ServerInfo> list = [];
    final csvList = const CsvToListConverter().convert(csv);
    for (int i = 0; i < csvList.length; i++) {
      final row = csvList[i];
      if (row.length != rowLength) {
        continue;
      }
      try {
        list.add(
          ServerInfo(
            hostName: row[0] as String,
            ip: row[1] as String,
            score: row[2] as int,
            ping: int.tryParse(row[3].toString()) ?? -1,
            speed: row[4] as int,
            countryLong: row[5] as String,
            countryShort: row[6] as String,
            numVpnSessions: row[7] as int,
            uptime: row[8] as int,
            totalUsers: row[9] as int,
            totalTraffic: row[10] as int,
            logType: row[11] as String,
            operator: row[12] as String,
            message: row[13] as String,
            vpnConfig: utf8.decode(base64Decode(row[14] as String)),
          ),
        );
      } catch (e) {
        debugPrint('row $i is not parsed');
        continue;
      }
    }
    return list;
  }
}

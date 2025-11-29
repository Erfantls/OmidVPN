import 'dart:io';

import 'package:omidvpn/api/domain/repository/local_storage.dart';
import 'package:omidvpn/ui/shared/utils/app_date.dart';
import 'package:omidvpn/ui/shared/utils/app_paths.dart';
import "package:path/path.dart" as p;

class OneDayFileCacheManager implements LocalStorage<String> {
  final String path;

  OneDayFileCacheManager._({required this.path});

  static Future<OneDayFileCacheManager> create({
    required String appname,
    required String dirname,
  }) async {
    final String cacheDir = await AppPaths.getCacheDirPath();
    final String path = p.join(cacheDir, appname, dirname);
    final dir = Directory(path);
    dir.create(recursive: true);
    return OneDayFileCacheManager._(path: path);
  }

  @override
  Future<String?> read({required String key, bool? getExpired}) async {
    final f = File(p.join(path, key));
    if (f.existsSync() &&
        AppDate.daysBetween(f.statSync().changed, DateTime.now()) <= 1) {
      return await f.readAsString();
    }
    return null;
  }

  @override
  void save({required String key, required String content}) async {
    final f = File(p.join(path, key));
    await f.writeAsString(content);
  }
}

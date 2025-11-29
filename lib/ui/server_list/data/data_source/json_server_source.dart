import 'dart:convert';

import 'package:dio/dio.dart';

class JsonServerRemoteSource {
  final String baseURL;
  final Dio dio;

  JsonServerRemoteSource({required this.dio, required this.baseURL});

  Future<List<dynamic>> getServerList() async {
    final response = await dio.get<String>(
      baseURL,
      options: Options(
        contentType: Headers.jsonContentType,
        responseType: ResponseType.plain,
      ),
    );

    final jsonData = json.decode(response.data as String);
    return jsonData as List<dynamic>;
  }
}

import 'package:flutter/material.dart';

@immutable
class NetworkTileProvider {
  final String baseUrl;
  final Map<String, String> headers;

  const NetworkTileProvider({required this.baseUrl, this.headers = const {}});

  Map<String, dynamic> toJson() {
    return {'baseUrl': baseUrl, 'headers': headers};
  }
}

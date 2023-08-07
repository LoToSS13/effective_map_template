import 'package:flutter/material.dart';

@immutable
class EffectiveNetworkTileProvider {
  final String baseUrl;
  final Map<String, String> headers;

  const EffectiveNetworkTileProvider(
      {required this.baseUrl, this.headers = const {}});

  Map<String, dynamic> toJson() {
    return {'baseUrl': baseUrl, 'headers': headers};
  }
}

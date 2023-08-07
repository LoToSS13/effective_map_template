import 'package:flutter/foundation.dart';

@immutable
class EffectiveLatLng {
  final double latitude;
  final double longitude;

  const EffectiveLatLng({required this.latitude, required this.longitude});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EffectiveLatLng &&
        other.latitude == latitude &&
        other.longitude == longitude;
  }

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() => '$latitude  $longitude';
}

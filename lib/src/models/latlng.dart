import 'dart:math' as math;
import 'package:effective_map/src/utils/geometry_converter.dart';
import 'package:flutter/foundation.dart';

@immutable
class LatLng {
  final double latitude;
  final double longitude;

  const LatLng({required this.latitude, required this.longitude});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LatLng && other.latitude == latitude && other.longitude == longitude;
  }

  double get latitudeInRad => degToRadian(latitude);

  double get longitudeInRad => degToRadian(longitude);

  LatLng max(LatLng other) => LatLng(
        latitude: math.max(latitude, other.latitude),
        longitude: math.max(longitude, other.longitude),
      );

  LatLng min(LatLng other) => LatLng(
        latitude: math.min(latitude, other.latitude),
        longitude: math.min(longitude, other.longitude),
      );

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;

  @override
  String toString() => '$latitude  $longitude';
}

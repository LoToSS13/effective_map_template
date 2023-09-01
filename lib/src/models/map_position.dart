import 'package:effective_map/src/models/latlng.dart';
import 'package:flutter/material.dart';

@immutable
class MapPosition {
  final LatLng? center;
  final double? zoom;

  const MapPosition({this.center, this.zoom});
}

import 'package:effective_map/src/models/effective_latlng.dart';
import 'package:flutter/material.dart';

@immutable
class EffectiveMapPosition {
  final EffectiveLatLng? center;
  final double? zoom;

  const EffectiveMapPosition({this.center, this.zoom});
}

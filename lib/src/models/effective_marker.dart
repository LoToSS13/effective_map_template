import 'package:effective_map/src/models/effective_latlng.dart';
import 'package:flutter/material.dart';

@immutable
class EffectiveMarker {
  final EffectiveLatLng position;
  final Key? key;

  const EffectiveMarker({this.key, required this.position});
}

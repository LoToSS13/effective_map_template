import 'package:effective_map/src/models/latlng.dart';
import 'package:flutter/material.dart';

@immutable
class Marker {
  final LatLng position;
  final Key? key;
  final bool selected;

  const Marker({this.key, required this.position, this.selected = false});
}

import 'package:effective_map/src/models/bbox.dart';
import 'package:effective_map/src/models/latlng.dart';
import 'package:flutter/material.dart';

abstract class MapController {
  Future<double> get zoom;
  Future<BBox?> get bbox;

  Future<void> zoomIn();
  Future<void> zoomOut();
  Future<void> fitBBox(BBox bbox, {EdgeInsets padding = const EdgeInsets.all(12)});
  Future<void> moveTo(LatLng latlng);
}

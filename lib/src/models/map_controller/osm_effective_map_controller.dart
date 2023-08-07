import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';

import 'package:effective_map/src/models/bbox.dart';
import 'package:effective_map/src/models/effective_latlng.dart';
import 'package:effective_map/src/models/map_controller/effective_map_controller.dart';
import 'package:effective_map/src/utils/flutter_map_extension.dart';
import 'package:effective_map/src/utils/bbox_extension.dart';

const _maxCameraZoom = 19.0;
const _interactivePolygonVisibilityThreshold = 17.3;

class OSMEffectiveMapController extends EffectiveMapController {
  final AnimatedMapController _controller;
  final double maxCameraZoom;
  final double interactivePolygonVisibilityThreshold;

  OSMEffectiveMapController(
      {required AnimatedMapController controller,
      this.maxCameraZoom = _maxCameraZoom,
      this.interactivePolygonVisibilityThreshold =
          _interactivePolygonVisibilityThreshold})
      : _controller = controller;

  @override
  Future<void> moveTo(EffectiveLatLng latlng) async => _controller.animateTo(
        dest: latlng.toLatLng(),
        zoom: max(interactivePolygonVisibilityThreshold, _controller.zoom),
      );

  @override
  Future<void> zoomFitBBox(BBox bbox) async => _controller.animatedFitBounds(
        bbox.toBounds(),
        options: FitBoundsOptions(
          padding: const EdgeInsets.all(12),
          maxZoom: maxCameraZoom,
        ),
      );

  @override
  Future<void> zoomIn() async => _controller.animatedZoomIn();

  @override
  Future<void> zoomOut() async => _controller.animatedZoomOut();

  @override
  Future<BBox?> get bbox async => _controller.bounds?.toBBox();

  @override
  Future<double> get zoom async => _controller.zoom;
}

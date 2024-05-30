import 'dart:math';

import 'package:effective_map/src/maps/flutter/utils/bbox_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';

import 'package:effective_map/src/models/bbox.dart';
import 'package:effective_map/src/models/latlng.dart';
import 'package:effective_map/src/models/map_controller/map_controller.dart' as mc;
import 'package:effective_map/src/maps/flutter/utils/flutter_map_extension.dart';

const _maxCameraZoom = 19.0;
const _interactivePolygonVisibilityThreshold = 17.3;

class FlutterMapController extends mc.MapController {
  final AnimatedMapController _controller;
  final double maxCameraZoom;
  final double interactivePolygonVisibilityThreshold;

  FlutterMapController(
      {required AnimatedMapController controller,
      this.maxCameraZoom = _maxCameraZoom,
      this.interactivePolygonVisibilityThreshold = _interactivePolygonVisibilityThreshold})
      : _controller = controller;

  @override
  Future<void> moveTo(LatLng latlng) async => _controller.animateTo(
        dest: latlng.toLatLng(),
        zoom: max(interactivePolygonVisibilityThreshold, _controller.mapController.camera.zoom),
      );

  @override
  Future<void> fitBBox(BBox bbox, {EdgeInsets padding = const EdgeInsets.all(12)}) async =>
      _controller.animatedFitCamera(
        cameraFit: CameraFit.bounds(
          bounds: bbox.toBounds(),
          padding: padding,
          maxZoom: maxCameraZoom,
        ),
      );

  @override
  Future<void> zoomIn() async => _controller.animatedZoomIn();

  @override
  Future<void> zoomOut() async => _controller.animatedZoomOut();

  @override
  Future<BBox?> get bbox async => _controller.mapController.camera.visibleBounds.toBBox();

  @override
  Future<double> get zoom async => _controller.mapController.camera.zoom;
}

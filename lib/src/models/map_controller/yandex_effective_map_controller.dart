import 'dart:math';

import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:effective_map/src/models/bbox.dart';
import 'package:effective_map/src/models/effective_latlng.dart';
import 'package:effective_map/src/models/map_controller/effective_map_controller.dart';
import 'package:effective_map/src/utils/bbox_extension.dart';

const _zoomAnimation = MapAnimation(duration: 0.25);
const _interactivePolygonVisibilityThreshold = 17.3;

class YandexEffectiveMapController extends EffectiveMapController {
  final YandexMapController _controller;
  final MapAnimation zoomAnimation;
  final double interactivePolygonVisibilityThreshold;

  YandexEffectiveMapController(
      {required YandexMapController controller,
      this.zoomAnimation = _zoomAnimation,
      this.interactivePolygonVisibilityThreshold =
          _interactivePolygonVisibilityThreshold})
      : _controller = controller;

  @override
  Future<BBox?> get bbox async =>
      (await _controller.getVisibleRegion()).toBBox();

  @override
  Future<void> moveTo(EffectiveLatLng latlng) async {
    final zoom = await this.zoom;
    await _controller.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: latlng.latitude,
            longitude: latlng.longitude,
          ),
          zoom: max(_interactivePolygonVisibilityThreshold, zoom),
        ),
      ),
      animation: const MapAnimation(duration: 1),
    );
  }

  @override
  Future<double> get zoom async => (await _controller.getCameraPosition()).zoom;

  @override
  Future<void> fitBBox(BBox bbox) async => _controller.moveCamera(
        CameraUpdate.newBounds(bbox.toBoundringBox()),
        animation: const MapAnimation(duration: 1),
      );

  @override
  Future<void> zoomIn() async => _controller.moveCamera(
        CameraUpdate.zoomIn(),
        animation: zoomAnimation,
      );

  @override
  Future<void> zoomOut() async => _controller.moveCamera(
        CameraUpdate.zoomOut(),
        animation: _zoomAnimation,
      );
}

import 'dart:math';

import 'package:effective_map/src/maps/yandex/utils/bbox_extension.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart' as yandex;

import 'package:effective_map/src/models/bbox.dart';
import 'package:effective_map/src/models/latlng.dart';
import 'package:effective_map/src/models/map_controller/map_controller.dart';

const _zoomAnimation = yandex.MapAnimation(duration: 0.25);
const _interactivePolygonVisibilityThreshold = 17.3;

class YandexMapController extends MapController {
  final yandex.YandexMapController _controller;
  final yandex.MapAnimation zoomAnimation;
  final double interactivePolygonVisibilityThreshold;

  YandexMapController(
      {required yandex.YandexMapController controller,
      this.zoomAnimation = _zoomAnimation,
      this.interactivePolygonVisibilityThreshold =
          _interactivePolygonVisibilityThreshold})
      : _controller = controller;

  @override
  Future<BBox?> get bbox async =>
      (await _controller.getVisibleRegion()).toBBox();

  @override
  Future<void> moveTo(LatLng latlng) async {
    final zoom = await this.zoom;
    await _controller.moveCamera(
      yandex.CameraUpdate.newCameraPosition(
        yandex.CameraPosition(
          target: yandex.Point(
            latitude: latlng.latitude,
            longitude: latlng.longitude,
          ),
          zoom: max(interactivePolygonVisibilityThreshold, zoom),
        ),
      ),
      animation: const yandex.MapAnimation(duration: 1),
    );
  }

  @override
  Future<double> get zoom async => (await _controller.getCameraPosition()).zoom;

  @override
  Future<void> fitBBox(BBox bbox) async => _controller.moveCamera(
        yandex.CameraUpdate.newBounds(bbox.toBoundringBox()),
        animation: const yandex.MapAnimation(duration: 1),
      );

  @override
  Future<void> zoomIn() async => _controller.moveCamera(
        yandex.CameraUpdate.zoomIn(),
        animation: zoomAnimation,
      );

  @override
  Future<void> zoomOut() async => _controller.moveCamera(
        yandex.CameraUpdate.zoomOut(),
        animation: _zoomAnimation,
      );
}

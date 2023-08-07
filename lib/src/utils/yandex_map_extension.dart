import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:effective_map/src/models/effective_map_position.dart';
import 'package:effective_map/src/models/effective_marker.dart';
import 'package:effective_map/src/models/effective_network_tiles_provider.dart';
import 'package:effective_map/src/models/effective_latlng.dart';

extension LatLngConverter on Point {
  EffectiveLatLng toEffectiveLatLng() => EffectiveLatLng(
        latitude: latitude,
        longitude: longitude,
      );
}

extension YandexPointConverter on EffectiveLatLng {
  Point toPoint() => Point(latitude: latitude, longitude: longitude);
}

extension EffectiveMapPositionConverter on CameraPosition {
  EffectiveMapPosition toEffectiveMapPosition() =>
      EffectiveMapPosition(center: target.toEffectiveLatLng(), zoom: zoom);
}

extension NetworkTileProviderConverter on EffectiveNetworkTileProvider {
  NetworkTileProvider toYandexTile() =>
      NetworkTileProvider(baseUrl: baseUrl, headers: headers);
}

extension NetworkTilesProviderConverter on List<EffectiveNetworkTileProvider> {
  List<NetworkTileProvider> toYandexTiles() => map(
        (e) => e.toYandexTile(),
      ).toList();
}

extension EffectiveMarkerConverter on PlacemarkMapObject {
  EffectiveMarker toEffectiveMerker() => EffectiveMarker(
      key: ValueKey(mapId.value), position: point.toEffectiveLatLng());
}

const _point = Point(latitude: 55.796391, longitude: 49.108891);

extension CameraPositionConverter on EffectiveMapPosition {
  CameraPosition toCameraPosition() =>
      CameraPosition(target: center?.toPoint() ?? _point, zoom: zoom ?? 15);
}

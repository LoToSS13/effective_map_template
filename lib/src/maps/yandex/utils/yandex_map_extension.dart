import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:effective_map/src/models/map_position.dart';
import 'package:effective_map/src/models/marker.dart';
import 'package:effective_map/src/models/network_tiles_provider.dart' as tile;
import 'package:effective_map/src/models/latlng.dart';

extension YandexLatLngConverter on Point {
  LatLng toLatLng() => LatLng(
        latitude: latitude,
        longitude: longitude,
      );
}

extension YandexPointConverter on LatLng {
  Point toPoint() => Point(latitude: latitude, longitude: longitude);
}

extension YandexMapPositionConverter on CameraPosition {
  MapPosition toMapPosition() =>
      MapPosition(center: target.toLatLng(), zoom: zoom);
}

extension NetworkTileProviderConverter on tile.NetworkTileProvider {
  NetworkTileProvider toYandexTile() =>
      NetworkTileProvider(baseUrl: baseUrl, headers: headers);
}

extension NetworkTilesProviderConverter on List<tile.NetworkTileProvider> {
  List<NetworkTileProvider> toYandexTiles() => map(
        (e) => e.toYandexTile(),
      ).toList();
}

extension MarkerConverter on PlacemarkMapObject {
  Marker toMarker() =>
      Marker(key: ValueKey(mapId.value), position: point.toLatLng());
}

const _point = Point(latitude: 55.796391, longitude: 49.108891);

extension CameraPositionConverter on MapPosition {
  CameraPosition toCameraPosition() =>
      CameraPosition(target: center?.toPoint() ?? _point, zoom: zoom ?? 15);
}

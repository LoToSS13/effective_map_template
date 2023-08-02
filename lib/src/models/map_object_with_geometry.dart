import 'package:meta/meta.dart';

import 'map_object_geometry.dart';

typedef ObjectsChunk = List<MapObjectWithGeometry>;

@immutable
class MapObjectWithGeometry {
  final String id;
  final MapObjectGeometry geometry;

  const MapObjectWithGeometry({required this.id, required this.geometry});

  factory MapObjectWithGeometry.fromJson(Map<String, dynamic> json) =>
      MapObjectWithGeometry(
        id: json['id'] as String,
        geometry: MapObjectGeometry.fromJson(
          json['geometry'] as Map<String, dynamic>,
        ),
      );
}

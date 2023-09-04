import 'package:meta/meta.dart';

import 'package:effective_map/src/models/map_object_geometry.dart';

typedef ObjectsChunk = List<MapObjectWithGeometry>;

@immutable
class MapObjectWithGeometry {
  final String id;
  final MapObjectGeometry geometry;
  final bool selected;

  const MapObjectWithGeometry(
      {required this.id, required this.geometry, this.selected = false});

  factory MapObjectWithGeometry.fromJson(Map<String, dynamic> json) =>
      MapObjectWithGeometry(
        id: json['id'] as String,
        geometry: MapObjectGeometry.fromJson(
          json['geometry'] as Map<String, dynamic>,
        ),
      );
}

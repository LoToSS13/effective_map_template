import 'package:flutter_map/flutter_map.dart';

import 'map_object.dart';

class MultiPolygonWrapper implements MapObject {
  @override
  final Object id;
  @override
  late final LatLngBounds bounds;
  final List<Polygon> polygons;

  MultiPolygonWrapper({required this.id, required this.polygons}) {
    final bounds = polygons.first.boundingBox;
    for (final polygon in polygons.skip(1)) {
      bounds.extendBounds(polygon.boundingBox);
    }
    this.bounds = bounds;
  }

  MultiPolygonWrapper copyWith({
    Object? id,
    List<Polygon>? polygons,
  }) =>
      MultiPolygonWrapper(
        id: id ?? this.id,
        polygons: polygons ?? this.polygons,
      );
}

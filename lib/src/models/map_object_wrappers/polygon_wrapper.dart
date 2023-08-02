import 'package:flutter_map/flutter_map.dart';

import 'map_object.dart';

class PolygonWrapper implements MapObject {
  @override
  final Object id;
  @override
  final LatLngBounds bounds;
  final Polygon polygon;

  PolygonWrapper({required this.id, required this.polygon})
      : bounds = polygon.boundingBox;

  PolygonWrapper copyWith({
    Object? id,
    Polygon? polygon,
  }) =>
      PolygonWrapper(
        id: id ?? this.id,
        polygon: polygon ?? this.polygon,
      );
}

import 'package:flutter_map/flutter_map.dart';

import 'package:effective_map/src/models/map_object_wrappers/map_object.dart';

class PolylineWrapper implements MapObject {
  @override
  final Object id;
  @override
  final LatLngBounds bounds;
  final Polyline polyline;

  PolylineWrapper({required this.id, required this.polyline})
      : bounds = polyline.boundingBox;

  PolylineWrapper copyWith({
    Object? id,
    Polyline? polyline,
  }) =>
      PolylineWrapper(
        id: id ?? this.id,
        polyline: polyline ?? this.polyline,
      );
}

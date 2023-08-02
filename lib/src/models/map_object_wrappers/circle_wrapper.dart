import 'package:effective_map/src/models/map_object_wrappers/map_object.dart';
import 'package:flutter_map/flutter_map.dart';

class CircleWrapper implements MapObject {
  @override
  final Object id;
  @override
  final LatLngBounds bounds;
  final CircleMarker circle;

  CircleWrapper({required this.id, required this.circle})
      : bounds = LatLngBounds.fromPoints([circle.point]);

  CircleWrapper copyWith({
    Object? id,
    CircleMarker? circle,
  }) =>
      CircleWrapper(
        id: id ?? this.id,
        circle: circle ?? this.circle,
      );
}

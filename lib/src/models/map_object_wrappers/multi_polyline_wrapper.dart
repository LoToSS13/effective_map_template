import 'package:flutter_map/flutter_map.dart';

import 'package:effective_map/src/models/map_object_wrappers/map_object.dart';

class MultiPolylineWrapper implements MapObject {
  @override
  final Object id;
  @override
  late final LatLngBounds bounds;
  final List<Polyline> polylines;

  MultiPolylineWrapper({required this.id, required this.polylines}) {
    final bounds = polylines.first.boundingBox;
    for (final polyline in polylines.skip(1)) {
      bounds.extendBounds(polyline.boundingBox);
    }
    this.bounds = bounds;
  }

  MultiPolylineWrapper copyWith({
    Object? id,
    List<Polyline>? polylines,
  }) =>
      MultiPolylineWrapper(
        id: id ?? this.id,
        polylines: polylines ?? this.polylines,
      );
}

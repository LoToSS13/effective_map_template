import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:effective_map/src/models/map_object_wrappers/circle_wrapper.dart';
import 'package:effective_map/src/models/map_object_wrappers/map_object.dart';
import 'package:effective_map/src/models/map_object_wrappers/multi_polygon_wrapper.dart';
import 'package:effective_map/src/models/map_object_wrappers/multi_polyline_wrapper.dart';
import 'package:effective_map/src/models/map_object_wrappers/polygon_wrapper.dart';
import 'package:effective_map/src/models/map_object_wrappers/polyline_wrapper.dart';

class AnyMapObjectLayer extends StatelessWidget {
  final List<MapObject> mapObjects;

  const AnyMapObjectLayer({
    required this.mapObjects,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          CircleLayer(
            circles: mapObjects
                .whereType<CircleWrapper>()
                .map((e) => e.circle)
                .toList(),
          ),
          PolygonLayer(
            polygons: mapObjects
                .whereType<PolygonWrapper>()
                .map((e) => e.polygon)
                .toList(),
          ),
          PolygonLayer(
            polygons: mapObjects
                .whereType<MultiPolygonWrapper>()
                .map((e) => e.polygons)
                .flattened
                .toList(),
          ),
          PolylineLayer(
            polylines: mapObjects
                .whereType<PolylineWrapper>()
                .map((e) => e.polyline)
                .toList(),
          ),
          PolylineLayer(
            polylines: mapObjects
                .whereType<MultiPolylineWrapper>()
                .map((e) => e.polylines)
                .flattened
                .toList(),
          ),
        ],
      );
}

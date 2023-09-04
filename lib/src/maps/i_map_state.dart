import 'package:effective_map/src/models/map_layers/i_map_layer.dart';
import 'package:effective_map/src/models/marker.dart' as marker;
import 'package:effective_map/src/models/map_object_with_geometry.dart';

import 'package:effective_map/src/models/styles/marker_style.dart';
import 'package:effective_map/src/models/styles/object_style.dart';

abstract class IMapState<O, Marker, L> {
  L? convertLayer(MapLayer layer);
  O? convertObject(MapObjectWithGeometry mapObject, ObjectStyle style);
  Marker? convertMarker(marker.Marker effectiveMarker, MarkerStyle style);

  List<L> get layers;
}

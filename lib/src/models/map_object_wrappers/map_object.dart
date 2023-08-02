import 'package:flutter_map/flutter_map.dart';

abstract interface class MapObject {
  abstract final Object id;
  abstract final LatLngBounds bounds;
}

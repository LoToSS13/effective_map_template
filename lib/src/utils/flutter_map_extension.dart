import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/bbox.dart';

extension FlutterMapExtension on BBox {
  LatLngBounds toBounds() => LatLngBounds(
        LatLng(lowerCorner.latitude, lowerCorner.longitude),
        LatLng(upperCorner.latitude, upperCorner.longitude),
      );
}

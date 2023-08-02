import 'package:effective_map/src/models/bbox.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../models/latlng.dart';

extension VisibleRegionConverter on VisibleRegion {
  BBox toBBox() => BBox(
        upperCorner: LatLng(
          latitude: bottomRight.latitude,
          longitude: topLeft.longitude,
        ),
        lowerCorner: LatLng(
          latitude: topLeft.latitude,
          longitude: bottomRight.longitude,
        ),
      );
}

extension LatLngBoundsConverter on LatLngBounds {
  BBox toBBox() => BBox(
        upperCorner: LatLng(
          latitude: southEast.latitude,
          longitude: northWest.longitude,
        ),
        lowerCorner: LatLng(
          latitude: northWest.latitude,
          longitude: southEast.longitude,
        ),
      );
}

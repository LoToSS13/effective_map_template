import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:effective_map/src/models/bbox.dart';
import 'package:effective_map/src/models/latlng.dart' as lat_lng;

extension LatLngBoundsConverter on LatLngBounds {
  BBox toBBox() => BBox(
        upperCorner: lat_lng.LatLng(
          latitude: southEast.latitude,
          longitude: northWest.longitude,
        ),
        lowerCorner: lat_lng.LatLng(
          latitude: northWest.latitude,
          longitude: southEast.longitude,
        ),
      );
}

extension BoundsConverter on BBox {
  LatLngBounds toBounds() => LatLngBounds(
        LatLng(lowerCorner.latitude, lowerCorner.longitude),
        LatLng(upperCorner.latitude, upperCorner.longitude),
      );
}

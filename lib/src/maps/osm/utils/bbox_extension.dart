import 'package:effective_map/src/models/bbox.dart';
import 'package:effective_map/src/models/effective_latlng.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

extension EffectiveLatLngBoundsConverter on LatLngBounds {
  BBox toBBox() => BBox(
        upperCorner: EffectiveLatLng(
          latitude: southEast.latitude,
          longitude: northWest.longitude,
        ),
        lowerCorner: EffectiveLatLng(
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

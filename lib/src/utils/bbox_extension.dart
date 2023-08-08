import 'package:effective_map/src/models/bbox.dart';
import 'package:effective_map/src/models/effective_latlng.dart';
import 'package:effective_map/src/utils/yandex_map_extension.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:yandex_mapkit/yandex_mapkit.dart';

extension VisibleRegionConverter on VisibleRegion {
  BBox toBBox() => BBox(
        upperCorner: EffectiveLatLng(
          latitude: bottomRight.latitude,
          longitude: topLeft.longitude,
        ),
        lowerCorner: EffectiveLatLng(
          latitude: topLeft.latitude,
          longitude: bottomRight.longitude,
        ),
      );
}

extension EffectiveLatLngBBoxConverter on BoundingBox {
  BBox toBBox() => BBox(
        upperCorner: northEast.toEffectiveLatLng(),
        lowerCorner: southWest.toEffectiveLatLng(),
      );
}

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
  BoundingBox toBoundringBox() => BoundingBox(
        northEast: upperCorner.toPoint(),
        southWest: lowerCorner.toPoint(),
      );

  LatLngBounds toBounds() => LatLngBounds(
        LatLng(lowerCorner.latitude, lowerCorner.longitude),
        LatLng(upperCorner.latitude, upperCorner.longitude),
      );
}

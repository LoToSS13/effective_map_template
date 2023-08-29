import 'package:effective_map/src/models/bbox.dart';
import 'package:effective_map/src/models/effective_latlng.dart';
import 'package:effective_map/src/maps/yandex/utils/yandex_map_extension.dart';

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

extension BoundsConverter on BBox {
  BoundingBox toBoundringBox() => BoundingBox(
        northEast: upperCorner.toPoint(),
        southWest: lowerCorner.toPoint(),
      );
}

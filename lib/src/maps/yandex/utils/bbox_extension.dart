import 'package:effective_map/src/models/bbox.dart';
import 'package:effective_map/src/models/latlng.dart';
import 'package:effective_map/src/maps/yandex/utils/yandex_map_extension.dart';

import 'package:yandex_mapkit/yandex_mapkit.dart';

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

extension LatLngBBoxConverter on BoundingBox {
  BBox toBBox() => BBox(
        upperCorner: northEast.toLatLng(),
        lowerCorner: southWest.toLatLng(),
      );
}

extension BoundsConverter on BBox {
  BoundingBox toBoundringBox() => BoundingBox(
        northEast: upperCorner.toPoint(),
        southWest: lowerCorner.toPoint(),
      );
}

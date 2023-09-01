import 'package:meta/meta.dart';

import 'package:effective_map/src/models/latlng.dart';

@immutable
class BBox {
  final LatLng upperCorner;
  final LatLng lowerCorner;

  const BBox({required this.upperCorner, required this.lowerCorner});

  @override
  String toString() =>
      '${upperCorner.longitude},${upperCorner.latitude},${lowerCorner.longitude},${lowerCorner.latitude}';

  bool contains(BBox other) {
    if (other.upperCorner.latitude >= upperCorner.latitude &&
        other.upperCorner.longitude >= upperCorner.longitude &&
        other.lowerCorner.latitude <= lowerCorner.latitude &&
        other.lowerCorner.longitude <= lowerCorner.longitude) {
      return true;
    }
    return false;
  }

  bool includes(LatLng latLng) {
    if (latLng.latitude >= upperCorner.latitude &&
        latLng.longitude >= upperCorner.longitude &&
        latLng.latitude <= lowerCorner.latitude &&
        latLng.longitude <= lowerCorner.longitude) {
      return true;
    }
    return false;
  }
}

import 'dart:math' as math;
import 'package:effective_map/src/utils/geometry_converter.dart';
import 'package:meta/meta.dart';

import 'package:effective_map/src/models/latlng.dart';

@immutable
class BBox {
  final LatLng _upperCorner;
  final LatLng _lowerCorner;

  BBox({required LatLng upperCorner, required LatLng lowerCorner})
      : _upperCorner = upperCorner.max(lowerCorner),
        _lowerCorner = lowerCorner.min(upperCorner);

  LatLng get upperCorner => _upperCorner;
  LatLng get lowerCorner => _lowerCorner;

  LatLng get center {
    /* https://stackoverflow.com/a/4656937
       http://www.movable-type.co.uk/scripts/latlong.html

       coord 1: lowerCorner
       coord 2: upperCorner

       phi: lat
       lambda: lng
    */

    final phi1 = lowerCorner.latitudeInRad;
    final lambda1 = lowerCorner.longitudeInRad;
    final phi2 = upperCorner.latitudeInRad;

    final dLambda = degrees2Radians * (upperCorner.longitude - lowerCorner.longitude); // delta lambda = lambda2-lambda1

    final bx = math.cos(phi2) * math.cos(dLambda);
    final by = math.cos(phi2) * math.sin(dLambda);
    final phi3 =
        math.atan2(math.sin(phi1) + math.sin(phi2), math.sqrt((math.cos(phi1) + bx) * (math.cos(phi1) + bx) + by * by));
    final lambda3 = lambda1 + math.atan2(by, math.cos(phi1) + bx);

    // phi3 and lambda3 are actually in radians and LatLng wants degrees
    return LatLng(latitude: radianToDeg(phi3), longitude: radianToDeg(lambda3));
  }

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

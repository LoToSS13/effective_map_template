import 'dart:math';

import 'package:effective_map/src/models/effective_latlng.dart';
import 'package:effective_map/src/models/map_object_geometry.dart';

const _earthRadius = 6373.0;

class GeometryCenterConverter {
  const GeometryCenterConverter._();

  static EffectiveLatLng fromLine(List<PointObjectGeometry> geometry) {
    var latCenter = 0.0;
    var lonCenter = 0.0;
    final pointsCount = geometry.length;
    for (final point in geometry) {
      latCenter += point.center.latitude;
      lonCenter += point.center.longitude;
    }
    latCenter /= pointsCount;
    lonCenter /= pointsCount;

    final center = EffectiveLatLng(latitude: latCenter, longitude: lonCenter);

    if (geometry.length == 2) {
      return center;
    }

    final neariestPoint = _getNeariestPointOf(center, geometry);

    return EffectiveLatLng(
      latitude: neariestPoint.center.latitude,
      longitude: neariestPoint.center.longitude,
    );
  }

  static EffectiveLatLng fromMultiLine(List<LineObjectGeometry> geometry) {
    var latCenter = 0.0;
    var lonCenter = 0.0;
    var pointsCount = 0;
    final allPoints = <PointObjectGeometry>[];
    for (final line in geometry) {
      for (final point in line.points) {
        latCenter += point.center.latitude;
        lonCenter += point.center.longitude;
      }
      allPoints.addAll(line.points);
      pointsCount += line.points.length;
    }
    latCenter /= pointsCount;
    lonCenter /= pointsCount;

    final center = EffectiveLatLng(latitude: latCenter, longitude: lonCenter);

    final neariestPoint = _getNeariestPointOf(center, allPoints);

    return EffectiveLatLng(
      latitude: neariestPoint.center.latitude,
      longitude: neariestPoint.center.longitude,
    );
  }

  static EffectiveLatLng fromPolygon(List<PointObjectGeometry> geometry) {
    var latCenter = 0.0;
    var lonCenter = 0.0;

    for (final point in geometry) {
      latCenter += point.center.latitude;
      lonCenter += point.center.longitude;
    }
    latCenter /= geometry.length;
    lonCenter /= geometry.length;

    return EffectiveLatLng(latitude: latCenter, longitude: lonCenter);
  }

  static EffectiveLatLng fromMultiPolygon(
      List<PolygonObjectGeometry> geometry) {
    PolygonObjectGeometry? biggestPolygon;
    var maxPolygonLength = 0.0;
    for (final polygon in geometry) {
      var polygonLength = 0.0;
      for (var i = 1; i < polygon.outerRing.points.length; i++) {
        final lat1 = polygon.outerRing.points[i - 1].center.latitude;
        final lat2 = polygon.outerRing.points[i].center.latitude;
        final lon1 = polygon.outerRing.points[i - 1].center.longitude;
        final lon2 = polygon.outerRing.points[i].center.longitude;
        polygonLength += _distanceBetween(lat1, lon1, lat2, lon2);
      }
      if (polygonLength > maxPolygonLength) {
        maxPolygonLength = polygonLength;
        biggestPolygon = polygon;
      }
    }
    if (biggestPolygon == null) {
      throw ArgumentError('There is no polygons in object!');
    }
    return fromPolygon(biggestPolygon.outerRing.points);
  }

  static PointObjectGeometry _getNeariestPointOf(
    EffectiveLatLng startPoint,
    List<PointObjectGeometry> points,
  ) {
    var neariestPoint = points.first;
    var minDistance = _distanceBetween(
      startPoint.latitude,
      startPoint.longitude,
      neariestPoint.center.latitude,
      neariestPoint.center.longitude,
    );
    for (final point in points.skip(1)) {
      final distance = _distanceBetween(
        startPoint.latitude,
        startPoint.longitude,
        point.center.latitude,
        point.center.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
        neariestPoint = point;
      }
    }
    return neariestPoint;
  }

  static double _distanceBetween(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dlat = lat2 - lat1;
    final dlon = lon2 - lon1;
    final a =
        pow(sin(dlat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dlon / 2), 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return _earthRadius * c;
  }
}

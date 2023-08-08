import 'package:effective_map/src/models/effective_latlng.dart';
import 'package:effective_map/src/models/converters/geometry_center_converter.dart';
import 'package:effective_map/src/models/map_object_geometry.dart';

class GeometryConverter {
  final GeometryType type;

  const GeometryConverter({this.type = GeometryType.polygon});

  MapObjectGeometry fromJson(List<dynamic> json) {
    switch (type) {
      case GeometryType.point:
        return _parsePoint(json);
      case GeometryType.line:
        return _parseLine(json);
      case GeometryType.multiline:
        return _parseMultiLine(json);
      case GeometryType.polygon:
        return _parsePolygon(json);
      case GeometryType.multipolygon:
        return _parseMultiPolygon(json);
      case GeometryType.linearRing:
        return _parseLinearRing(json);
    }
  }

  MultiPolygonObjectGeometry _parseMultiPolygon(List<dynamic> coordinates) {
    final polygons = <PolygonObjectGeometry>[];
    for (final coord in coordinates) {
      polygons.add(_parsePolygon(coord as List));
    }
    final center = GeometryCenterConverter.fromMultiPolygon(polygons);
    return MultiPolygonObjectGeometry(polygons: polygons, center: center);
  }

  PolygonObjectGeometry _parsePolygon(List<dynamic> coordinates) {
    final outerRing = _parseLinearRing(coordinates.first as List<dynamic>);
    final center = GeometryCenterConverter.fromPolygon(outerRing.points);
    if (coordinates.length == 1) {
      return PolygonObjectGeometry(outerRing: outerRing, center: center);
    }
    final rings = <LinearRingObjectGeometry>[];
    for (final coord in coordinates.skip(1)) {
      rings.add(_parseLinearRing(coord as List));
    }
    return PolygonObjectGeometry(
      outerRing: outerRing,
      innerRings: rings,
      center: center,
    );
  }

  LinearRingObjectGeometry _parseLinearRing(List<dynamic> coordinates) {
    final points = <PointObjectGeometry>[];
    for (final coord in coordinates) {
      points.add(_parsePoint(coord as List));
    }
    final center = GeometryCenterConverter.fromLine(points);
    return LinearRingObjectGeometry(points: points, center: center);
  }

  MultiLineObjectGeometry _parseMultiLine(List<dynamic> coordinates) {
    final lines = <LineObjectGeometry>[];
    for (final coord in coordinates) {
      lines.add(_parseLine(coord as List));
    }
    final center = GeometryCenterConverter.fromMultiLine(lines);
    return MultiLineObjectGeometry(lines: lines, center: center);
  }

  LineObjectGeometry _parseLine(List<dynamic> coordinates) {
    final points = <PointObjectGeometry>[];
    for (final coord in coordinates) {
      points.add(_parsePoint(coord as List));
    }
    final center = GeometryCenterConverter.fromLine(points);
    return LineObjectGeometry(points: points, center: center);
  }

  PointObjectGeometry _parsePoint(List<dynamic> coordinates) =>
      PointObjectGeometry(
        center: EffectiveLatLng(
          latitude: coordinates[1] as double,
          longitude: coordinates[0] as double,
        ),
      );
}

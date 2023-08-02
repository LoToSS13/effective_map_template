import 'converters/geometry_converter.dart';
import 'latlng.dart';

enum GeometryType { point, line, multiline, polygon, multipolygon, linearRing }

const _geometryTypeEncoder = <String, GeometryType>{
  'Point': GeometryType.point,
  'LineString': GeometryType.line,
  'MultiLineString': GeometryType.multiline,
  'Polygon': GeometryType.polygon,
  'MultiPolygon': GeometryType.multipolygon,
};

sealed class MapObjectGeometry {
  final LatLng center;

  const MapObjectGeometry({required this.center});

  GeometryType get type => switch (this) {
        PointObjectGeometry() => GeometryType.point,
        LineObjectGeometry() => GeometryType.line,
        MultiLineObjectGeometry() => GeometryType.multiline,
        PolygonObjectGeometry() => GeometryType.polygon,
        MultiPolygonObjectGeometry() => GeometryType.multipolygon,
        LinearRingObjectGeometry() => GeometryType.linearRing,
      };

  T? mapOrNull<T extends Object?>({
    T? Function(PointObjectGeometry value)? point,
    T? Function(LineObjectGeometry value)? line,
    T? Function(MultiLineObjectGeometry value)? multiline,
    T? Function(LinearRingObjectGeometry value)? linearRing,
    T? Function(PolygonObjectGeometry value)? polygon,
    T? Function(MultiPolygonObjectGeometry value)? multipolygon,
  }) =>
      switch (this) {
        PointObjectGeometry() => point?.call(this as PointObjectGeometry),
        LineObjectGeometry() => line?.call(this as LineObjectGeometry),
        MultiLineObjectGeometry() =>
          multiline?.call(this as MultiLineObjectGeometry),
        PolygonObjectGeometry() => polygon?.call(this as PolygonObjectGeometry),
        MultiPolygonObjectGeometry() =>
          multipolygon?.call(this as MultiPolygonObjectGeometry),
        LinearRingObjectGeometry() =>
          linearRing?.call(this as LinearRingObjectGeometry),
      };

  const factory MapObjectGeometry.point({
    required LatLng center,
  }) = PointObjectGeometry;

  const factory MapObjectGeometry.line({
    required List<PointObjectGeometry> points,
    required LatLng center,
  }) = LineObjectGeometry;

  const factory MapObjectGeometry.multiline({
    required List<LineObjectGeometry> lines,
    required LatLng center,
  }) = MultiLineObjectGeometry;

  const factory MapObjectGeometry.linearRing({
    required List<PointObjectGeometry> points,
    required LatLng center,
  }) = LinearRingObjectGeometry;

  const factory MapObjectGeometry.polygon({
    required LinearRingObjectGeometry outerRing,
    required LatLng center,
    List<LinearRingObjectGeometry>? innerRings,
  }) = PolygonObjectGeometry;

  const factory MapObjectGeometry.multipolygon({
    required List<PolygonObjectGeometry> polygons,
    required LatLng center,
  }) = MultiPolygonObjectGeometry;

  factory MapObjectGeometry.fromJson(Map<String, dynamic> json) {
    final type = _geometryTypeEncoder[json['type']];
    if (type == null) {
      throw ArgumentError('type can not be null');
    }
    return GeometryConverter(type: type).fromJson(json['coordinates'] as List);
  }
}

class PointObjectGeometry extends MapObjectGeometry {
  const PointObjectGeometry({required super.center});
}

class LineObjectGeometry extends MapObjectGeometry {
  final List<PointObjectGeometry> points;
  const LineObjectGeometry({required this.points, required super.center});
}

class MultiLineObjectGeometry extends MapObjectGeometry {
  final List<LineObjectGeometry> lines;
  const MultiLineObjectGeometry({required this.lines, required super.center});
}

class LinearRingObjectGeometry extends MapObjectGeometry {
  final List<PointObjectGeometry> points;
  const LinearRingObjectGeometry({required this.points, required super.center});
}

class PolygonObjectGeometry extends MapObjectGeometry {
  final LinearRingObjectGeometry outerRing;
  final List<LinearRingObjectGeometry>? innerRings;

  const PolygonObjectGeometry(
      {required this.outerRing, required super.center, this.innerRings});
}

class MultiPolygonObjectGeometry extends MapObjectGeometry {
  final List<PolygonObjectGeometry> polygons;

  const MultiPolygonObjectGeometry(
      {required this.polygons, required super.center});
}

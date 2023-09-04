import 'package:yandex_mapkit/yandex_mapkit.dart';

import 'package:effective_map/src/models/map_object_geometry.dart';

class MapGeometryCreator {
  const MapGeometryCreator._();

  static Circle createPoint(Point center, double radius) =>
      Circle(center: center, radius: radius);

  static Polyline createPolyline(List<PointObjectGeometry> geometry) =>
      Polyline(
        points: geometry
            .map(
              (e) => Point(
                latitude: e.center.latitude,
                longitude: e.center.longitude,
              ),
            )
            .toList(),
      );

  static List<MapObject<dynamic>> createMultiPolyline(
    List<LineObjectGeometry> geometry,
  ) =>
      geometry.map((e) => createPolyline(e.points) as MapObject).toList();

  static Polygon createPolygon(
    LinearRingObjectGeometry outerRing,
    List<LinearRingObjectGeometry> innerRings,
  ) =>
      Polygon(
        outerRing: LinearRing(
          points: outerRing.points
              .map(
                (e) => Point(
                  latitude: e.center.latitude,
                  longitude: e.center.longitude,
                ),
              )
              .toList(),
        ),
        innerRings: innerRings
            .map(
              (e) => LinearRing(
                points: e.points
                    .map(
                      (e) => Point(
                        latitude: e.center.latitude,
                        longitude: e.center.longitude,
                      ),
                    )
                    .toList(),
              ),
            )
            .toList(),
      );

  static List<MapObject<dynamic>> createMultiPolygon(
    List<PolygonObjectGeometry> polygons,
  ) =>
      polygons
          .map(
            (e) => createPolygon(e.outerRing, e.innerRings ?? []) as MapObject,
          )
          .toList();
}

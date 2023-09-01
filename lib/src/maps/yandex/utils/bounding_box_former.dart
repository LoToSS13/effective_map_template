import 'package:yandex_mapkit/yandex_mapkit.dart';

const _coordOfZoomStep = 0.0004;

BoundingBox createPaddedBoundingBoxFrom(List<Point> points) {
  if (points.isEmpty) throw ArgumentError('points can not be empty');
  final firstPoint = points.first;
  var eastest = firstPoint.latitude;
  var northest = firstPoint.longitude;
  var westest = firstPoint.latitude;
  var southest = firstPoint.longitude;
  for (final point in points) {
    if (point.latitude < eastest) {
      eastest = point.latitude;
    }
    if (point.longitude < northest) {
      northest = point.longitude;
    }
    if (point.latitude > westest) {
      westest = point.latitude;
    }
    if (point.longitude > southest) {
      southest = point.longitude;
    }
  }
  final box = BoundingBox(
    northEast: Point(
      latitude: eastest - _coordOfZoomStep,
      longitude: northest - _coordOfZoomStep,
    ),
    southWest: Point(
      latitude: westest + _coordOfZoomStep,
      longitude: southest + _coordOfZoomStep,
    ),
  );
  return box;
}
